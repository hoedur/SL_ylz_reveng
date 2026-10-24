"""Device-generic telemetry: normalized events + thread-safe store.

Covers REQ-TEL-001 .. REQ-TEL-005 and the REQ-ARCH-005 frame queue (maxsize 64,
oldest dropped with a ``frame_dropped`` event when full).

This module must stay free of imports of any concrete transport (REQ-ARCH-003:
the TRANSPORTS registry is the only coupling). It depends on the standard
library only.

Thread-safety: one re-entrant lock guards all counters/ring/window state.
``queue.Queue`` provides its own synchronization for the frame queue.
"""

from __future__ import annotations

import queue
import threading
import time
from collections import deque
from dataclasses import dataclass

__all__ = ["TelemetryEvent", "TelemetryStore"]


@dataclass(frozen=True)
class TelemetryEvent:
    """One normalized wire-level (or synthesized) observation.

    REQ-TEL-001: ``ts`` is monotonic seconds; ``addr`` is "ip:port" of the peer
    as seen ("" for synthesized logic events); ``datagram_len`` is bytes on wire
    (0 for synthesized logic events like ``frame_complete``); ``fields`` holds
    kind-specific values (int | str | float). ``raw_hex`` carries the first
    <=128 bytes of the wire payload as lowercase hex, "" if none.
    """

    ts: float
    transport: str
    kind: str
    addr: str
    datagram_len: int
    fields: dict[str, int | str | float]
    raw_hex: str = ""


class TelemetryStore:
    """Thread-safe telemetry sink shared between transports and the UI.

    - Event ring with capacity 5000, oldest evicted (REQ-TEL-002).
    - Cumulative counters per REQ-TEL-004; ``decode_failed`` is incremented for
      every ``decode_error`` event (REQ-OPS-003); ``decode_ok`` via
      :meth:`note_decode` (successful PIL decode lives in the UI thread).
    - Bounded frame queue (maxsize 64). When full, the *oldest* frame is
      dropped and a ``frame_dropped`` event is emitted (REQ-ARCH-005); video
      polling must therefore never block the network thread.
    - Derived ``stats_sample`` events (~1/s) with ``fps_5s`` / ``kbps_rx`` are
      emitted by :meth:`maybe_emit_stats` from the transport's receive loop.
    """

    RING_CAPACITY = 5000
    FRAME_QUEUE_MAX = 64
    STATS_WINDOW_S = 5.0
    STATS_MIN_INTERVAL_S = 0.9  # -> emission rate ~1/s

    def __init__(self, transport_name: str) -> None:
        self._transport_name = str(transport_name)
        self._lock = threading.RLock()
        self._seq = 0
        self._ring: deque[tuple[int, TelemetryEvent]] = deque(maxlen=self.RING_CAPACITY)
        self._by_kind: dict[str, int] = {}
        self._datagrams_rx = 0
        self._bytes_rx = 0
        self._decode_ok = 0
        self._frame_ts: deque[float] = deque()
        self._wire: deque[tuple[float, int]] = deque()
        self._last_stats_ts = float("-inf")
        self._frames: queue.Queue[tuple[bytes, float]] = queue.Queue(
            maxsize=self.FRAME_QUEUE_MAX
        )

    # -- events ------------------------------------------------------------

    def add_event(self, ev: TelemetryEvent) -> None:
        """Append one event to the ring and update the counters.

        REQ-TEL-004 (amended): kind ``frame_complete`` -> frames_complete;
        kind ``ping`` -> pings_tx; kind ``decode_error`` -> decode_failed;
        any event with ``datagram_len > 0`` -> datagrams_rx / bytes_rx.
        """
        with self._lock:
            self._seq += 1
            self._ring.append((self._seq, ev))
            self._by_kind[ev.kind] = self._by_kind.get(ev.kind, 0) + 1
            if ev.kind == "frame_complete":
                self._frame_ts.append(ev.ts)
            if ev.datagram_len > 0:
                self._datagrams_rx += 1
                self._bytes_rx += ev.datagram_len
                self._wire.append((ev.ts, ev.datagram_len))

    def get_since(self, idx: int) -> tuple[list[TelemetryEvent], int]:
        """Return (events newer than idx, next idx) — oldest first (REQ-TEL-002)."""
        with self._lock:
            events = [ev for seq, ev in self._ring if seq > idx]
            return events, self._seq

    # -- counters ----------------------------------------------------------

    def record_input(self, ts: float, nbytes: int) -> None:
        """Account one datagram the transport accepted on the socket but which
        produced NO event (REQ-BOL-001 filtered ones are "counter only").
        Datagrams that produce telemetry events are accounted via add_event."""
        with self._lock:
            self._datagrams_rx += 1
            self._bytes_rx += nbytes
            self._wire.append((ts, nbytes))

    def mark_decode(self, ok: bool) -> None:
        """Count a display decode attempt (REQ-TEL-004): ``decode_ok`` only
        from the UI decoder via this method; failures arrive as decode_error
        events (REQ-OPS-003) and are derived there."""
        if ok:
            with self._lock:
                self._decode_ok += 1

    def snapshot(self) -> dict:
        """JSON-serializable snapshot of counters and derived rates (REQ-TEL-003)."""
        with self._lock:
            now = time.monotonic()
            self._prune_windows(now)
            return {
                "transport": self._transport_name,
                "datagrams_rx": self._datagrams_rx,
                "bytes_rx": self._bytes_rx,
                "frames_complete": self._by_kind.get("frame_complete", 0),
                "decode_ok": self._decode_ok,
                "decode_failed": self._by_kind.get("decode_error", 0),
                "pings_tx": self._by_kind.get("ping", 0),
                "by_kind": dict(self._by_kind),
                "fps_5s": round(len(self._frame_ts) / self.STATS_WINDOW_S, 3),
                "kbps_rx": round(
                    sum(n for _ts, n in self._wire) / self.STATS_WINDOW_S / 1024.0, 3
                ),
            }

    # -- derived stats (REQ-TEL-004) ---------------------------------------

    def maybe_emit_stats(self, now: float) -> TelemetryEvent | None:
        """Emit a derived ``stats_sample`` at >= ~1/s. Called from the transport
        receive loop; no-op when the previous sample is too recent."""
        with self._lock:
            if now - self._last_stats_ts < self.STATS_MIN_INTERVAL_S:
                return None
            self._last_stats_ts = now
            self._prune_windows(now)
            fps = len(self._frame_ts) / self.STATS_WINDOW_S
            kbps = sum(n for _ts, n in self._wire) / self.STATS_WINDOW_S / 1024.0
        ev = TelemetryEvent(
            ts=now,
            transport=self._transport_name,
            kind="stats_sample",
            addr="",
            datagram_len=0,
            fields={"fps_5s": round(fps, 3), "kbps_rx": round(kbps, 3)},
        )
        self.add_event(ev)
        return ev

    # -- frame queue (REQ-ARCH-005) ----------------------------------------

    def push_frame(self, jpeg_bytes: bytes, ts: float) -> None:
        """Push one reconstructed JPEG; drop the OLDEST frame when full (and
        emit ``frame_dropped``). Never blocks."""
        try:
            self._frames.put_nowait((jpeg_bytes, ts))
            return
        except queue.Full:
            pass
        try:
            self._frames.get_nowait()  # evict oldest
        except queue.Empty:
            pass
        self.add_event(
            TelemetryEvent(
                ts=time.monotonic(),
                transport=self._transport_name,
                kind="frame_dropped",
                addr="",
                datagram_len=0,
                fields={"reason": "queue_full"},
            )
        )
        try:
            self._frames.put_nowait((jpeg_bytes, ts))
        except queue.Full:  # pragma: no cover - another producer raced the slot
            pass

    def pop_frame(self) -> tuple[bytes, float]:
        """Pop the oldest queued frame; () when empty (REQ-TEL-002)."""
        try:
            return self._frames.get_nowait()
        except queue.Empty:
            return ()

    # -- internals ----------------------------------------------------------

    def _prune_windows(self, now: float) -> None:
        cutoff = now - self.STATS_WINDOW_S
        while self._frame_ts and self._frame_ts[0] < cutoff:
            self._frame_ts.popleft()
        while self._wire and self._wire[0][0] < cutoff:
            self._wire.popleft()
