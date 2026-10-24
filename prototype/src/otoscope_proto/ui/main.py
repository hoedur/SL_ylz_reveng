"""CLI bootstrap for the window (REQ-OPS-001/002/003) — ``python -m otoscope_proto``.

``run_cli`` parses the CLI, builds the store/transport via the
``device.TRANSPORTS`` registry (no concrete transport import here, REQ-ARCH-003),
shows the window and runs the Qt loop. Shutdown is always graceful:
after the loop ends (window closed or the ``--duration`` timer fired) the
transport is stopped (joins within 2 s, REQ-BOL-007) and the optional
``--out FILE`` JSON dump is written (REQ-OPS-002).

Non-crashing errors (e.g. unknown transport) print to stderr and return 2.
"""

from __future__ import annotations

import argparse
import json
import sys

from ..telemetry import TelemetryStore

__all__ = ["run_cli", "build_parser"]

DEFAULT_HOST = "192.168.169.1"  # REQ-OPS-001 defaults
DEFAULT_PORT = 8800
DEFAULT_TRANSPORT = "boliu"


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="otoscope_proto",
        description="PyQt6 validation client for the reverse-engineered ear otoscope "
        "(BoliU/BL384 UDP protocol); see prototype/docs/ARCHITECTURE.md.",
    )
    parser.add_argument("--host", default=DEFAULT_HOST, help="device address (default %(default)s)")
    parser.add_argument("--port", type=int, default=DEFAULT_PORT, help="device port (default %(default)s)")
    parser.add_argument(
        "--transport", default=DEFAULT_TRANSPORT, help="registry name of the transport (default %(default)s)"
    )
    parser.add_argument(
        "--duration",
        type=float,
        default=None,
        help="close the window after S seconds (default: run until closed)",
    )
    parser.add_argument(
        "--out",
        default=None,
        help="write a JSON dump {transport, host, port, duration_s, snapshot} on quit",
    )
    return parser


def _write_out(path: str, args: argparse.Namespace, store: TelemetryStore) -> None:
    payload = {
        "transport": args.transport,
        "host": args.host,
        "port": args.port,
        "duration_s": args.duration,
        "snapshot": store.snapshot(),
    }
    with open(path, "w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2, sort_keys=True)


def run_cli(argv: list[str] | None = None) -> int:
    """REQ-OPS-001: run the window until closed (or ``--duration`` elapsed)."""
    args = build_parser().parse_args(argv)  # argv None -> sys.argv

    # The registry is the only coupling to concrete transports (REQ-ARCH-003).
    from ..device import create_transport

    store = TelemetryStore(args.transport)
    try:
        transport = create_transport(args.transport, args.host, args.port, store)
    except KeyError:
        print(f"error: unknown transport {args.transport!r}", file=sys.stderr)
        return 2

    from PyQt6.QtCore import QTimer
    from PyQt6.QtWidgets import QApplication

    from .main_window import build_window

    app = QApplication(sys.argv)
    window = build_window(store, args.transport, args.host, args.port)
    window.show()
    transport.start()
    if args.duration is not None:
        # REQ-OPS-002: auto-quit after S seconds; stop() joins <= 2 s later.
        QTimer.singleShot(int(args.duration * 1000.0), window.close)
    app.exec()
    transport.stop()
    if args.out:
        try:
            _write_out(args.out, args, store)
        except OSError as exc:
            print(f"error: cannot write --out {args.out!r}: {exc}", file=sys.stderr)
            return 2
    return 0
