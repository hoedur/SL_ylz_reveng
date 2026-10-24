"""Generic metadata widgets — the QTabWidget right of the video (REQ-UI-003..007).

Four tabs of device-generic content, fed exclusively from the telemetry stream
(REQ-TEL-005: no side-channel, and nothing of this lives inside the video widget):

- ``Events``   : newest-first table of TelemetryEvents, generic columns
                 ``ts (s)`` / ``kind`` / ``addr`` / ``datagram_len`` / ``summary``
                 (summary = ``k=v`` of ``fields`` sorted by field name, long
                 values truncated) (REQ-UI-004);
- ``Frame``    : the last completed frame's metadata as label/value rows, field
                 tokens rendered verbatim (REQ-UI-005);
- ``Stats``    : counters from the store snapshot, refreshed each 100 ms poll
                 (REQ-UI-006);
- ``Raw event``: the event currently selected in ``Events`` — pretty-printed
                 fields + hexdump of ``raw_hex`` (first <=128 bytes), or
                 "no wire payload" (REQ-UI-007).

Standard library + PyQt6 only.
"""

from __future__ import annotations

from typing import Any

from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtWidgets import (
    QAbstractItemView,
    QFormLayout,
    QHBoxLayout,
    QHeaderView,
    QLabel,
    QPlainTextEdit,
    QTableWidget,
    QTableWidgetItem,
    QTabWidget,
    QVBoxLayout,
    QWidget,
)

from ..telemetry import TelemetryEvent

__all__ = ["MetadataPanel", "EventsTab", "FrameTab", "StatsTab", "RawTab"]

#: REQ-UI-004: at least 500 event rows are kept.
EVENT_TABLE_MAX_ROWS = 1000

#: Field tokens rendered verbatim on the Frame tab (REQ-UI-005; see
#: docs/coordination.md — styling is free, token text is not).
FRAME_FIELDS = ("frame_id", "size", "cnt", "w", "h", "q", "jpeg_len", "decode_ts")

#: Stat keys rendered verbatim on the Stats tab (REQ-UI-006).
STATS_KEYS = (
    "transport",
    "datagrams_rx",
    "pings_tx",
    "frames_complete",
    "decode_ok",
    "decode_failed",
    "bytes_rx",
    "fps_5s",
    "kbps_rx",
)


def _fmt_value(value: Any) -> str:
    """Human rendering of one field value; long values truncated (REQ-UI-004)."""
    text = str(value)
    if len(text) > 60:
        return text[:57] + "…"
    return text


def _summary(ev: TelemetryEvent) -> str:
    """``k=v`` pairs joined, sorted by field name (REQ-UI-004)."""
    return ", ".join(
        f"{key}={_fmt_value(value)}" for key, value in sorted(ev.fields.items())
    )


def _hexdump(data: bytes) -> str:
    """Classic 16-bytes-per-line hexdump (offset / hex / ascii)."""
    lines = []
    for offset in range(0, len(data), 16):
        chunk = data[offset : offset + 16]
        hexpart = " ".join(f"{byte:02x}" for byte in chunk)
        hexpart = hexpart.ljust(16 * 3 - 1)
        ascii_part = "".join(
            chr(byte) if 32 <= byte < 127 else "." for byte in chunk
        )
        lines.append(f"{offset:04x}  {hexpart}  {ascii_part}")
    return "\n".join(lines)


# --------------------------------------------------------------------------- model


class EventsTab(QWidget):
    """REQ-UI-004: newest-first telemetry table.

    Rows are only ever inserted at the top (one row per new event, newest ends
    up at row 0); existing selections are tracked by the bounded row index and
    survive insertions for the Raw event tab.
    """

    #: emitted whenever the current row changes (drives the Raw event tab).
    selection_changed = pyqtSignal()

    COL_TS, COL_KIND, COL_ADDR, COL_DGRAM, COL_SUMMARY = range(5)
    HEADERS = ("ts (s)", "kind", "addr", "datagram_len", "summary")
    MAX_ROWS = EVENT_TABLE_MAX_ROWS

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._events: list[TelemetryEvent] = []  # index 0 == newest, parallel to rows
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        self._table = QTableWidget(0, len(self.HEADERS), self)
        self._table.setHorizontalHeaderLabels(list(self.HEADERS))
        self._table.setSelectionBehavior(QAbstractItemView.SelectionBehavior.SelectRows)
        self._table.setSelectionMode(QAbstractItemView.SelectionMode.SingleSelection)
        self._table.setEditTriggers(QAbstractItemView.EditTrigger.NoEditTriggers)
        self._table.horizontalHeader().setStretchLastSection(True)
        self._table.verticalHeader().setVisible(False)
        self._table.itemSelectionChanged.connect(self._on_selection_changed)
        layout.addWidget(self._table)

    # -- data ---------------------------------------------------------------

    def add_events(self, events: list[TelemetryEvent]) -> None:
        """Insert events from ``get_since`` (oldest→newest); newest ends at row 0."""
        for ev in events:
            self._insert_row(ev)
        self._trim()

    def _insert_row(self, ev: TelemetryEvent) -> None:
        row = 0
        self._table.insertRow(row)
        cells = (
            f"{ev.ts:.3f}",
            ev.kind,
            ev.addr or "(no addr)",
            str(ev.datagram_len),
            _summary(ev),
        )
        for column, text in enumerate(cells):
            self._table.setItem(row, column, QTableWidgetItem(text))
        self._events.insert(row, ev)

    def selected_event(self) -> TelemetryEvent | None:
        row = self._table.currentRow()
        return self._events[row] if 0 <= row < len(self._events) else None

    def _on_selection_changed(self) -> None:
        self.selection_changed.emit()

    def _trim(self) -> None:
        while len(self._events) > self.MAX_ROWS:
            self._table.removeRow(self._table.rowCount() - 1)
            self._events.pop()


class FrameTab(QWidget):
    """REQ-UI-005: last completed frame's metadata as label/value rows.

    Labels render the spec field tokens verbatim (see coordination.md).
    """

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._values: dict[str, QLabel] = {}
        layout = QFormLayout(self)
        for token in FRAME_FIELDS:
            value = QLabel("-", self)
            self._values[token] = value
            layout.addRow(QLabel(token, self), value)

    def show_frame_event(self, ev: TelemetryEvent) -> None:
        """Feed from the newest ``frame_complete`` event (REQ-UI-005)."""
        for key, value in ev.fields.items():
            label = self._values.get(key)
            if label is not None:
                label.setText(_fmt_value(value))

    def show_decode(self, jpeg_len: int, decode_ts: float) -> None:
        """``jpeg_len`` = actual queued bytes, ``decode_ts`` = decode moment."""
        self._values["jpeg_len"].setText(str(int(jpeg_len)))
        self._values["decode_ts"].setText(f"{decode_ts:.3f}")


class StatsTab(QWidget):
    """REQ-UI-006: counters / derived rates from ``store.snapshot()``."""

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self._values: dict[str, QLabel] = {}
        layout = QFormLayout(self)
        for key in STATS_KEYS:
            value = QLabel("-", self)
            self._values[key] = value
            layout.addRow(QLabel(key, self), value)

    def update_snapshot(self, snapshot: dict) -> None:
        for key in STATS_KEYS:
            label = self._values[key]
            if key not in snapshot:
                continue
            value = snapshot[key]
            label.setText(f"{value:.3f}" if isinstance(value, float) else str(value))


class RawTab(QWidget):
    """REQ-UI-007: pretty fields + hexdump of the selected event's ``raw_hex``."""

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        self._text = QPlainTextEdit(self)
        self._text.setReadOnly(True)
        hint = QLabel("selection follows the Events tab", self)
        row = QHBoxLayout()
        row.addWidget(hint)
        row.addStretch(1)
        layout.addLayout(row)
        layout.addWidget(self._text)
        self._text.setPlainText("no event selected — click a row in the Events tab")

    def show_event(self, ev: TelemetryEvent | None) -> None:
        if ev is None:
            self._text.setPlainText("no event selected — click a row in the Events tab")
            return
        lines = [
            f"ts: {ev.ts:.3f}",
            f"transport: {ev.transport}",
            f"kind: {ev.kind}",
            f"addr: {ev.addr or '(none)'}",
            f"datagram_len: {ev.datagram_len}",
            "",
            "fields:",
        ]
        lines.extend(f"  {key} = {_fmt_value(value)}" for key, value in sorted(ev.fields.items()))
        raw = self._raw_bytes(ev)
        if raw:
            lines.extend(
                [
                    "",
                    f"raw ({len(raw)} bytes):",
                    _hexdump(raw),
                ]
            )
        else:
            lines.extend(["", "no wire payload"])
        self._text.setPlainText("\n".join(lines))

    @staticmethod
    def _raw_bytes(ev: TelemetryEvent) -> bytes:
        if not ev.raw_hex:
            return b""
        try:
            return bytes.fromhex(ev.raw_hex)[:128]  # REQ-UI-007: first <=128 bytes
        except ValueError:
            return b""


# --------------------------------------------------------------------- panel


class MetadataPanel(QTabWidget):
    """Right-side metadata panel: Events | Frame | Stats | Raw event (REQ-UI-003)."""

    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setMinimumWidth(360)  # REQ-UI-003(a)
        self._events = EventsTab(self)
        self._frame = FrameTab(self)
        self._stats = StatsTab(self)
        self._raw = RawTab(self)
        self.addTab(self._events, "Events")
        self.addTab(self._frame, "Frame")
        self.addTab(self._stats, "Stats")
        self.addTab(self._raw, "Raw event")
        self._events.selection_changed.connect(self._refresh_raw)

    # Called by the poller (main window) each 100 ms turn: REQ-UI-008.

    def add_events(self, events: list[TelemetryEvent]) -> None:
        self._events.add_events(events)
        frame_events = [ev for ev in events if ev.kind == "frame_complete"]
        if frame_events:
            self._frame.show_frame_event(frame_events[-1])  # newest (REQ-UI-005)

    def note_decode(self, jpeg_len: int, decode_ts: float) -> None:
        self._frame.show_decode(jpeg_len, decode_ts)

    def update_snapshot(self, snapshot: dict) -> None:
        self._stats.update_snapshot(snapshot)

    def _refresh_raw(self) -> None:
        self._raw.show_event(self._events.selected_event())
