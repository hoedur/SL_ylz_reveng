"""Offscreen PyQt6 UI tests — docs/ARCHITECTURE.md §4d (REQ-UI-001..009) + REQ-OPS-003.

Spec source: docs/ARCHITECTURE.md ONLY (REQ-TEST-001). Cites:
- REQ-UI-001: title "Otoscope Prototype — <transport.name>", 1280x720 default / 1024x576 min,
  horizontal QSplitter with VideoPanel (left) + metadata_panel (right), exactly 2 children.
- REQ-UI-002: before any frame, placeholder "No signal — pinging <host>:<port>" on black;
  NO telemetry text/widgets inside the video widget (placeholder label exempt).
- REQ-UI-003: metadata panel = QTabWidget right side; >= 360 px at default size; video >= 480 px.
- REQ-UI-004: Events tab = generic table (ts/kind/datagram_len/summary) fed from the store.
- REQ-UI-005: Frame tab rows frame_id, size, cnt, w, h, q, jpeg_len, decode_ts (NOT in video).
- REQ-UI-006: Stats tab counters + fps_5s/kbps_rx labels, refreshed each 100 ms poll.
- REQ-UI-007: Raw event tab = pretty fields + hexdump of raw_hex; "no wire payload" otherwise.
- REQ-UI-008: UI polls store every 100 ms (tested implicitly via qtbot.waitUntil on the poll).
- REQ-UI-009: video decode in UI thread from the frame queue; REQ-OPS-003 decode_error path.

Rendering-format note (see docs/coordination.md): the spec names the fields/labels but does not
pin their on-screen formatting, so the assertions look up the exact spec names/numbers as text
tokens inside the respective tab widget (labels, line edits, text widgets, or tables).
"""
from __future__ import annotations

import io
import re
import time

import pytest

from fake_device import build_heartbeat
from otoscope_proto.telemetry import TelemetryEvent, TelemetryStore

# impl-ui is a later phase — keep collection clean without it: this raises Skipped at
# collection time, so the Qt imports and the otoscope_proto.ui import below never run.
pytest.importorskip("otoscope_proto.ui", reason="impl-ui pending")
from PyQt6.QtCore import Qt
from PyQt6.QtWidgets import (
    QAbstractItemView,
    QLabel,
    QLineEdit,
    QMainWindow,
    QPlainTextEdit,
    QSplitter,
    QTabWidget,
    QTableView,
    QTextEdit,
)
from otoscope_proto.ui.main_window import build_window

HOST, PORT = "127.0.0.1", 8800
TOKEN_RE = re.compile(r"[A-Za-z0-9_]+")


# ------------------------------------------------------------------- small helpers (spec)


def _splitter(win: QMainWindow) -> QSplitter:
    assert isinstance(win.centralWidget(), QSplitter), "REQ-UI-001: central = horizontal QSplitter"
    return win.centralWidget()


def _video(win: QMainWindow):
    return _splitter(win).widget(0)


def _meta(win: QMainWindow) -> QTabWidget:
    return _splitter(win).widget(1)


def _tokenize(text: str) -> set[str]:
    return set(TOKEN_RE.findall(text))


def _table_text(view: QAbstractItemView) -> str:
    model = view.model()
    parts = []
    for r in range(model.rowCount()):
        for c in range(model.columnCount()):
            val = model.data(model.index(r, c))
            if val is not None:
                parts.append(str(val))
    return "\n".join(parts)


def _texts_of(widget) -> str:
    """All human-visible text of a widget, regardless of the concrete display class used."""
    parts = []
    for lbl in widget.findChildren(QLabel):
        parts.append(lbl.text())
    for le in widget.findChildren(QLineEdit):
        parts.append(le.text())
    for te in widget.findChildren(QPlainTextEdit):
        parts.append(te.toPlainText())
    for te in widget.findChildren(QTextEdit):  # includes QTextBrowser subclasses
        parts.append(te.toPlainText())
    for tv in widget.findChildren(QTableView):  # includes QTableWidget subclasses
        parts.append(_table_text(tv))
    return "\n".join(parts)


def _make_event(kind: str, fields: dict, *, datagram_len: int = 0, raw_hex: str = "") -> TelemetryEvent:
    return TelemetryEvent(
        ts=time.monotonic(),
        transport="boliu",
        kind=kind,
        addr=f"{HOST}:1234",
        datagram_len=datagram_len,
        fields=fields,
        raw_hex=raw_hex,
    )


def _make_jpeg() -> bytes:
    """REQ-UI-003: a real, decodable 640x360 JPEG via PIL."""
    from PIL import Image

    buf = io.BytesIO()
    Image.new("RGB", (640, 360), (88, 2, 4)).save(buf, format="JPEG", quality=100)
    return buf.getvalue()


def _pixmap_label(video) -> QLabel | None:
    """The video widget's frame QLabel with a non-null pixmap (REQ-UI-003/009)."""
    for lbl in video.findChildren(QLabel):
        pm = lbl.pixmap()
        if pm is not None and not pm.isNull():
            return lbl
    return None


def _build(qtbot, store: TelemetryStore) -> QMainWindow:
    win = build_window(store, "boliu", HOST, PORT)
    qtbot.addWidget(win)
    win.show()
    return win


# ------------------------------------------------------------------------------- the tests


def test_ui_001_window_layout_geometry(qtbot) -> None:
    """REQ-UI-001 + REQ-UI-003(a/b): title, size bounds, splitter layout, panel sizes."""
    store = TelemetryStore("boliu")
    win = _build(qtbot, store)

    # title contains the spec prefix (full title is "Otoscope Prototype — <transport.name>")
    assert "Otoscope Prototype" in win.windowTitle(), "REQ-UI-001 window title"
    # fixed minimum size per REQ-UI-001
    assert (win.minimumWidth(), win.minimumHeight()) == (1024, 576), "REQ-UI-001 minimum 1024x576"

    sw = _splitter(win)
    assert sw.orientation() == Qt.Orientation.Horizontal, "REQ-UI-001 horizontal splitter"
    assert sw.count() == 2, "REQ-UI-001: exactly two children (VideoPanel | metadata_panel)"
    assert isinstance(_meta(win), QTabWidget), "REQ-UI-003: metadata panel is a QTabWidget"

    # default size 1280x720 (REQ-UI-001)
    qtbot.waitUntil(lambda: win.width() >= 1278 and win.height() >= 718, timeout=2000)
    # video left >= 480 px, metadata right >= 360 px (REQ-UI-002/REQ-UI-003)
    def sizes_ok() -> bool:
        sizes = sw.sizes()
        return len(sizes) == 2 and sizes[0] >= 480 and sizes[1] >= 360
    qtbot.waitUntil(sizes_ok, timeout=2000)


def test_ui_002_placeholder_no_telemetry_in_video(qtbot) -> None:
    """REQ-UI-002: 'No signal — pinging <host>:<port>' before any frame; no telemetry text
    or tabular widgets inside the video widget (placeholder label exempt)."""
    store = TelemetryStore("boliu")
    win = _build(qtbot, store)
    video = _video(win)

    placeholders = [l for l in video.findChildren(QLabel) if l.text().startswith("No signal")]
    assert placeholders, "REQ-UI-002: 'No signal' placeholder missing before first frame"
    assert f"pinging {HOST}:{PORT}" in placeholders[0].text(), (
        f"REQ-UI-002: placeholder must contain 'No signal — pinging {HOST}:{PORT}'"
    )
    # no telemetry widgets inside the video widget (metadata lives OUTSIDE)
    assert video.findChildren(QTableView) == [], "REQ-UI-002: no table inside video widget"
    assert video.findChildren(QTabWidget) == [], "REQ-UI-002: no tabs inside video widget"


def test_ui_004_events_table_populates_from_telemetry(qtbot) -> None:
    """REQ-UI-004 (+ REQ-UI-008 polling): a push-added event shows up in the Events table
    within one 100 ms poll cycle; summary is built generically from `fields`."""
    store = TelemetryStore("boliu")
    win = _build(qtbot, store)
    meta = _meta(win)

    def events_view() -> QTableView | None:
        tab = meta.widget(0)
        return tab.findChild(QTableView) if tab is not None else None

    store.add_event(
        _make_event("heartbeat", {"seq": 424242, "pad": 4, "drift": 94}, datagram_len=16)
    )
    # table exists and picked the event up within the 100 ms poll cycle (REQ-UI-008)
    qtbot.waitUntil(
        lambda: (tv := events_view()) is not None and tv.rowCount() >= 1, timeout=3000
    )

    tv = events_view()
    qtbot.waitUntil(lambda: "424242" in _table_text(tv), timeout=3000)  # summary k=v from fields
    cell_text = _table_text(tv)
    assert "1234" in _tokenize(cell_text), "datagram peer address visible"
    assert "heartbeat" in _tokenize(cell_text), "REQ-UI-004: kind column visible"


def test_ui_005_frame_tab_fields(qtbot) -> None:
    """REQ-UI-005: Frame tab shows frame_id, size, cnt, w, h, q, jpeg_len, decode_ts."""
    store = TelemetryStore("boliu")
    win = _build(qtbot, store)
    meta = _meta(win)

    def frame_tab_text() -> str:
        return _texts_of(meta.widget(1))

    store.add_event(
        _make_event(
            "frame_complete",
            {"frame_id": 1, "size": 2100, "cnt": 3, "w": 640, "h": 360, "q": 75},
        )
    )
    qtbot.waitUntil(
        lambda: "frame_id" in _tokenize(frame_tab_text())
        and "2100" in _tokenize(frame_tab_text()),
        timeout=3000,
    )
    tokens = _tokenize(frame_tab_text())
    for name in ("frame_id", "size", "cnt", "w", "h", "q", "jpeg_len", "decode_ts"):
        assert name in tokens, f"REQ-UI-005: Frame tab missing field label '{name}'"
    assert "2100" in tokens, "REQ-UI-005: frame size value shown"


def test_ui_006_stats_labels(qtbot) -> None:
    """REQ-UI-006: Stats tab shows snapshot counters + fps_5s/kbps_rx, refreshed each poll."""
    store = TelemetryStore("boliu")
    win = _build(qtbot, store)
    meta = _meta(win)

    def stats_tab_text() -> str:
        return _texts_of(meta.widget(2))

    # generate some snapshot counter movement, then wait for the 100 ms poll to catch it
    for i in range(3):
        store.add_event(_make_event("ping", {"bytes": "EF000400"}, datagram_len=4, raw_hex="ef000400"))
    qtbot.waitUntil(lambda: "fps_5s" in _tokenize(stats_tab_text()), timeout=3000)
    tokens = _tokenize(stats_tab_text())
    for name in (
        "datagrams_rx",
        "pings_tx",
        "frames_complete",
        "decode_ok",
        "decode_failed",
        "bytes_rx",
        "fps_5s",
        "kbps_rx",
    ):
        assert name in tokens, f"REQ-UI-006: Stats tab missing label '{name}'"
    assert any(ch.isdigit() for ch in stats_tab_text()), "REQ-UI-006: numeric labels render a value"


def test_ui_007_raw_event_selection_and_no_payload(qtbot) -> None:
    """REQ-UI-007: Raw event tab follows Events selection; hexdump for raw_hex events,
    'no wire payload' for events without wire bytes."""
    store = TelemetryStore("boliu")
    win = _build(qtbot, store)
    meta = _meta(win)

    ev_raw = _make_event(
        "heartbeat",
        {"seq": 424242, "pad": 4, "drift": 94},
        datagram_len=16,
        raw_hex=build_heartbeat(424242).hex(),
    )
    ev_no_raw = _make_event("frame_complete", {"frame_id": 9, "size": 1, "cnt": 1, "w": 0, "h": 0, "q": 0})
    store.add_event(ev_raw)
    store.add_event(ev_no_raw)  # newest first -> row 0

    def events_view():
        return meta.widget(0).findChild(QTableView)

    qtbot.waitUntil(lambda: events_view() is not None and events_view().rowCount() >= 2, timeout=3000)
    tv = events_view()

    def raw_tab_text() -> str:
        return _texts_of(meta.widget(3))

    # select the OLDER event (row 1) which carries raw bytes -> hexdump + pretty fields
    tv.selectRow(1)
    qtbot.waitUntil(lambda: "424242" in _tokenize(raw_tab_text()), timeout=3000)
    normalized = raw_tab_text().replace(" ", "").lower()
    assert build_heartbeat(424242).hex()[:8] in normalized, (
        "REQ-UI-007: hexdump of the event's raw_hex shown"
    )
    # select the NEWEST event (row 0) without raw bytes -> "no wire payload"
    tv.selectRow(0)
    qtbot.waitUntil(lambda: "no wire payload" in raw_tab_text().lower(), timeout=3000)


def test_ui_003_009_video_shows_decoded_frame(qtbot) -> None:
    """REQ-UI-003/REQ-UI-009: a decoded frame shows as a non-null pixmap in the video
    widget (640x360 exact, or letterboxed aspect); decode_ok is counted (REQ-TEL-004)."""
    store = TelemetryStore("boliu")
    win = _build(qtbot, store)
    video = _video(win)

    store.push_frame(_make_jpeg(), time.monotonic())
    qtbot.waitUntil(lambda: _pixmap_label(video) is not None, timeout=3000)

    pm = _pixmap_label(video).pixmap()
    ratio_ok = abs(pm.width() / max(pm.height(), 1) - 640 / 360) <= 0.15  # letterbox allowed
    assert (pm.width(), pm.height()) == (640, 360) or ratio_ok, (
        f"REQ-UI-003: decoded frame is 640x360 (letterbox allowed); got {pm.width()}x{pm.height()}"
    )

    def decode_ok() -> bool:
        return store.snapshot()["decode_ok"] >= 1
    # decode_ok counter from REQ-TEL-004 (decoded in UI thread per REQ-UI-009)
    qtbot.waitUntil(decode_ok, timeout=2000)


def test_ops_003_decode_error_no_crash(qtbot) -> None:
    """REQ-OPS-003: garbage frame -> decode_error/decode_failed, placeholders resumes,
    app does not crash (REQ-UI-009: decode lives in the UI thread)."""
    store = TelemetryStore("boliu")
    win = _build(qtbot, store)
    video = _video(win)

    # first a valid frame so the video area is showing something decodable
    store.push_frame(_make_jpeg(), time.monotonic())
    qtbot.waitUntil(lambda: _pixmap_label(video) is not None, timeout=3000)

    # then garbage -> decode_error path (kind decode_error, fields reason/jpeg_len)
    store.push_frame(b"\x00" * 32, time.monotonic())
    qtbot.waitUntil(lambda: store.snapshot()["decode_failed"] >= 1, timeout=3000)

    events = store.get_since(0)[0]
    decode_errors = [e for e in events if e.kind == "decode_error"]
    assert decode_errors, "REQ-OPS-003: a decode_error event must exist"
    assert set(decode_errors[0].fields) >= {"reason", "jpeg_len"}, "REQ-OPS-003 decode_error fields"

    # placeholder "No signal" resumes on the next empty poll turn
    qtbot.waitUntil(
        lambda: _pixmap_label(video) is None
        and any(l.text().startswith("No signal") for l in video.findChildren(QLabel)),
        timeout=3000,
    )
    assert isinstance(win, QMainWindow) and win.isVisible(), "REQ-OPS-003: app did not crash"
