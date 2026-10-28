"""Main window + video panel + the 100 ms poll wiring (REQ-UI-001..003, 008/009, REQ-OPS-003).

Layout (REQ-UI-001): a horizontal :class:`QSplitter` with :class:`VideoPanel`
left and :class:`~otoscope_proto.ui.metadata_panel.MetadataPanel` right.

Polling model (REQ-UI-008/009): a single 100 ms QTimer in the UI thread:
- ``store.get_since(idx)`` → Events table (newest first), Frame tab;
- ``store.snapshot()``       → Stats tab;
- ``store.pop_frame()``      → decode via ``QImage.fromData`` in this thread,
  ``mark_decode(True)`` + pixmap on success; on failure a ``decode_error``
  event goes into the store (REQ-OPS-003) and the "No signal" placeholder
  resumes. The network thread is never touched from here.
"""

from __future__ import annotations

import time

from PyQt6.QtCore import Qt, QTimer
from PyQt6.QtGui import QImage, QPixmap
from PyQt6.QtWidgets import QLabel, QMainWindow, QSplitter, QVBoxLayout, QWidget

from ..telemetry import TelemetryStore
from .metadata_panel import MetadataPanel

__all__ = ["MainWindow", "VideoPanel", "build_window"]

#: REQ-UI-008: fixed UI poll interval.
POLL_INTERVAL_MS = 100


class VideoPanel(QWidget):
    """Left splitter pane (REQ-UI-002).

    One black, centered QLabel carries both modes: "No signal — pinging
    <host>:<port>" placeholder text before/without frames, and the decoded
    pixmap (the decoded canvas's own size — 640×480 live, REQ-BOL-010 — centered
    on black = letterbox) afterwards. No telemetry is ever drawn here
    (REQ-UI-002/REQ-TEL-005).
    """

    def __init__(self, host: str, port: int, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setMinimumWidth(480)  # REQ-UI-003(b) video side >= 480 px
        self._host = str(host)
        self._port = int(port)
        self._label = QLabel(self)
        self._label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self._label.setStyleSheet("background-color: black; color: white;")
        self._label.setMinimumSize(1, 1)
        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.addWidget(self._label)
        self.show_placeholder()

    def show_placeholder(self) -> None:
        self._label.setPixmap(QPixmap())  # null pixmap -> text mode (and clears old)
        self._label.setText(f"No signal — pinging {self._host}:{self._port}")

    def show_frame(self, jpeg_bytes: bytes) -> bool:
        """Decode ``jpeg_bytes`` and display it; False on a null image."""
        image = QImage.fromData(jpeg_bytes)
        if image.isNull():
            return False  # caller emits decode_error and restores the placeholder
        pixmap = QPixmap.fromImage(image)
        # Letterbox: keep the decoded canvas's own aspect — display the pixmap at native
        # size, shrink-only when it is larger than the pane (KeepAspectRatio).
        size = self._label.size()
        if (
            size.isValid()
            and size.width() > 0
            and (pixmap.width() > size.width() or pixmap.height() > size.height())
        ):
            pixmap = pixmap.scaled(
                size,
                Qt.AspectRatioMode.KeepAspectRatio,
                Qt.TransformationMode.FastTransformation,
            )
        self._label.setPixmap(pixmap)  # setPixmap clears previous content
        return True


class MainWindow(QMainWindow):
    """REQ-UI-001 window; owns the poll timer and frame-queue draining."""

    def __init__(
        self,
        store: TelemetryStore,
        transport_name: str,
        host: str,
        port: int,
        parent: QWidget | None = None,
    ) -> None:
        super().__init__(parent)
        self._store = store
        self._transport_name = str(transport_name)
        self._host = str(host)
        self._port = int(port)
        self._poll_idx = 0

        self.setWindowTitle(f"Otoscope Prototype — {self._transport_name}")  # REQ-UI-001
        self.resize(1280, 720)
        self.setMinimumSize(1024, 576)

        video = VideoPanel(self._host, self._port, self)
        metadata = MetadataPanel(self)  # REQ-UI-003: right side, >= 360 px wide
        splitter = QSplitter(Qt.Orientation.Horizontal, self)
        splitter.addWidget(video)
        splitter.addWidget(metadata)
        splitter.setSizes([850, 430])  # video >= 480 px, metadata >= 360 px
        self.setCentralWidget(splitter)

        self._video = video
        self._metadata = metadata

        self._timer = QTimer(self)
        self._timer.setInterval(POLL_INTERVAL_MS)  # REQ-UI-008
        self._timer.timeout.connect(self._poll)
        self._timer.start()

    # -- the one poll turn ---------------------------------------------------

    def _poll(self) -> None:
        events, next_idx = self._store.get_since(self._poll_idx)
        self._poll_idx = next_idx
        if events:
            self._metadata.add_events(events)
        self._metadata.update_snapshot(self._store.snapshot())
        self._drain_frames()

    def _drain_frames(self) -> None:
        """Pop all queued frames (UI thread only, REQ-UI-009) and show the newest."""
        handled = 0
        while True:
            frame = self._store.pop_frame()  # () empty tuple == none (REQ-TEL-002)
            if not frame:
                break
            jpeg_bytes, _recv_ts = frame
            handled += 1
            self._display(jpeg_bytes)
            if handled >= self._store.FRAME_QUEUE_MAX:  # hard bound; queue maxsize is 64
                break

    def _display(self, jpeg_bytes: bytes) -> None:
        if self._video.show_frame(jpeg_bytes):
            self._store.mark_decode(True)  # REQ-TEL-004: decode_ok only from here
            self._metadata.note_decode(len(jpeg_bytes), time.monotonic())
        else:
            # REQ-OPS-003: decode_error event + placeholder resumes; never crash.
            self._store.add_event(self._decode_error_event(jpeg_bytes))
            self._video.show_placeholder()

    def _decode_error_event(self, jpeg_bytes: bytes):
        from ..telemetry import TelemetryEvent  # local import keeps imports shallow

        return TelemetryEvent(
            ts=time.monotonic(),
            transport=self._transport_name,
            kind="decode_error",
            addr="",
            datagram_len=0,
            fields={"reason": "image_decode_failed", "jpeg_len": len(jpeg_bytes)},
        )


def build_window(
    store: TelemetryStore, transport_name: str, host: str, port: int
) -> QMainWindow:
    """REQ-UI-001 factory (§6 fixed signature). Requires a running QApplication."""
    return MainWindow(store, transport_name, host, port)
