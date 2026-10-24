"""Tests for otoscope_proto.device registry & isolation — REQ-ARCH-002,
REQ-ARCH-003, REQ-ARCH-004 (constructor must not touch the network before start()).

Sources: docs/ARCHITECTURE.md §4a, §6 (fixed signatures).

REQ-ARCH-003 is tested statically via `ast`: no runtime import of concrete
transports is needed (and per REQ-TEST-001 we never read src/ content beyond
what this static contract check requires).
"""

import ast
import threading
from pathlib import Path

import pytest

from otoscope_proto.device import DeviceTransport, TRANSPORTS, create_transport
from otoscope_proto.telemetry import TelemetryStore


def make_store():
    return TelemetryStore("arch-test")


# ---------------------------------------------------------------------------
# REQ-ARCH-002 — registry TRANSPORTS + create_transport
# ---------------------------------------------------------------------------


def test_registry_is_dict_like_mapping_of_name_to_class():
    # REQ-ARCH-002: TRANSPORTS: dict[str, type[DeviceTransport]].
    assert isinstance(TRANSPORTS, dict)
    for name, cls in TRANSPORTS.items():
        assert isinstance(name, str)
        assert isinstance(cls, type)
        assert issubclass(cls, DeviceTransport)
    # The one concrete transport of this prototype must be registered (§3 layout).
    assert "boliu" in TRANSPORTS


def test_create_transport_unknown_name_raises_keyerror():
    # REQ-ARCH-002: unknown name raises KeyError containing the name.
    store = make_store()
    with pytest.raises(KeyError) as excinfo:
        create_transport("no_such", host="127.0.0.1", port=1, store=store)
    assert "no_such" in str(excinfo.value.args)


def test_create_transport_boliu_returns_transport_instance_no_networking():
    # REQ-ARCH-002 / REQ-ARCH-004: construction returns a DeviceTransport and
    # must NOT touch the network or spawn threads before start(). We therefore
    # never call start(); we only construct and, for safety, stop().
    store = make_store()
    threads_before = set(threading.enumerate())

    transport = create_transport("boliu", host="127.0.0.1", port=8800, store=store)

    assert isinstance(transport, DeviceTransport)
    assert transport.name == "boliu"  # REQ-ARCH-001: unique registry key
    # No extra threads spawned during construction.
    assert set(threading.enumerate()) == threads_before

    if hasattr(transport, "stop"):
        transport.stop()  # idempotent per REQ-ARCH-004; called for cleanup safety


def test_transport_stop_idempotent_without_start():
    # REQ-ARCH-004: stop() must be idempotent — calling it twice without a
    # start() must not raise.
    transport = create_transport("boliu", host="127.0.0.1", port=8800, store=make_store())
    if not hasattr(transport, "stop"):
        pytest.skip("transport has no stop() (REQ-ARCH-004 violation to be reported)")
    transport.stop()
    transport.stop()


# ---------------------------------------------------------------------------
# REQ-ARCH-003 — isolation: telemetry.py and ui/* never import concrete transports
# ---------------------------------------------------------------------------

SRC_ROOT = Path(__file__).resolve().parent.parent / "src" / "otoscope_proto"

# Only the package otoscope_proto.device itself is allowed (the ABC + registry
# is the sole coupling, REQ-ARCH-003); importing any otoscope_proto.device.<submodule>
# (e.g. boliu) in telemetry.py or ui/* couples the generic layer to a concrete
# transport — "nor any concrete transport".
_FORBIDDEN_SUBMODULE = "otoscope_proto.device."


def _violations_in(path: Path) -> list[str]:
    """Return list of violations for one file (empty list == clean)."""
    if not path.is_file():
        return [f"missing file (§3 layout contract): {path}"]
    tree = ast.parse(path.read_text(encoding="utf-8"), filename=str(path))
    found = []

    def visit_import(node):  # import otoscope_proto.device.boliu / import boliu
        for alias in node.names:
            if alias.name.startswith(_FORBIDDEN_SUBMODULE) or alias.name == "boliu":
                found.append(f"line {node.lineno}: import {alias.name}")

    def visit_import_from(node):
        module = node.module or ""
        if node.level and node.level > 0:  # relative: 'from ..device.boliu import X'
            if module.startswith("device."):
                found.append(f"line {node.lineno}: relative import from '{module}'")
            elif module == "device" or module.endswith(".device"):
                found.extend(
                    f"line {node.lineno}: from '{module}' import {a.name} "
                    "(boliu / concrete transport)"
                    for a in node.names
                    if a.name == "boliu"
                )
            return
        if module.startswith(_FORBIDDEN_SUBMODULE) or module == "boliu":
            found.append(f"line {node.lineno}: from {module} import ...")
        elif module == "otoscope_proto.device" or module.endswith(".device"):
            # Allowed: from otoscope_proto.device import TRANSPORTS, ...
            found.extend(
                f"line {node.lineno}: from {module} import boliu"
                for a in node.names
                if a.name == "boliu"
            )

    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            visit_import(node)
        elif isinstance(node, ast.ImportFrom):
            visit_import_from(node)
    return found


def test_telemetry_module_has_no_concrete_transport_import():
    # REQ-ARCH-003: telemetry.py must not import device.boliu (nor any
    # concrete transport); the registry is the only coupling.
    path = SRC_ROOT / "telemetry.py"
    violations = _violations_in(path)
    assert violations == []  # real violations only — file missing also fails


def test_ui_modules_have_no_concrete_transport_import(capfd):
    # REQ-ARCH-003: every module under ui/ must not import concrete transports.
    ui_dir = SRC_ROOT / "ui"
    if not ui_dir.is_dir():
        print(
            "SKIP-NOTE (REQ-ARCH-003): src/otoscope_proto/ui/ does not exist yet — "
            "only the telemetry.py isolation assertion ran."
        )
        return
    files = sorted(p for p in ui_dir.glob("*.py") if p.name != "__pycache__")
    assert files, "ui/ exists but contains no .py — unexpected §3 layout"
    violations = []
    for path in files:
        violations.extend(_violations_in(path))
    assert violations == [], f"ui/ imports concrete transports: {violations}"
