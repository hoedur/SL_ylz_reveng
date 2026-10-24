"""BoliU/BL384 UDP transport — the live-validated stream protocol (REQ-BOL-001..007).

Empirical basis: ``analysis/01-arc42-architecture.md`` §10b /
``analysis/04-live-device-validation.md``; the contracts in
``prototype/docs/ARCHITECTURE.md`` are binding and take precedence.

Wire summary (all offsets into the received datagram ``d``):
- framing ``[0x93][01|04][len LE16]``; ``len16`` must equal ``len(d)``;
- fragment (``d[1]==1``): ``frame_id`` LE32 @8, ``idx`` LE32 @32, ``cnt`` LE32 @36,
  ``size`` LE32 @40, ``w``/``h``/``q`` LE16 @44/46/48; page data at ``d[67:]`` for
  ``idx==0`` (frag0 header is 67 B) else ``d[56:]``;
- heartbeat (``d[1]==4``, total length 16): ``seq`` LE32 @4, ``pad`` @8, ``drift`` @12;
- ping every 90 ms: ``EF 00 04 00`` to ``host:port`` (default 8800);
- reassembly keyed ``(frame_id, size)``, complete at first ``cnt`` indices,
  >16 pending keys pruned oldest-first; reconstructed JPEG pushed via the store.

Standard library only; no JPEG decoding here (the UI owns that).
"""

from __future__ import annotations

import socket
import struct
import threading
import time
from collections import OrderedDict
from typing import Any

from ..jpeg_frames import DEFAULT_HEADER, assemble_jpeg
from ..telemetry import TelemetryEvent
from . import DeviceTransport

__all__ = ["BoliUTransport"]


class _PendingFrame:
    """Reassembly state for one ``(frame_id, size)`` key."""

    __slots__ = ("cnt", "pages", "w", "h", "q")

    def __init__(self, cnt: int, w: int, h: int, q: int) -> None:
        self.cnt = cnt
        self.pages: dict[int, bytes] = {}
        self.w = w
        self.h = h
        self.q = q


class BoliUTransport(DeviceTransport):
    """Client for the BoliU "BL384" unit (Bouffalo Lab firmware).

    Binds ``0.0.0.0:<local_port>`` (ephemeral by default), pings
    ``host:port`` every 90 ms and receives fragmented video from the device's
    port 1234 (REQ-BOL-001). All observations flow into the shared
    :class:`~otoscope_proto.telemetry.TelemetryStore`.
    """

    name = "boliu"

    PING_PAYLOAD = bytes.fromhex("EF000400")
    PING_FIELD_HEX = "EF000400"
    PING_INTERVAL_S = 0.090  # REQ-BOL-002
    STREAM_SRC_PORT = 1234  # REQ-BOL-001 stream_port default
    RECV_TIMEOUT_S = 0.050  # keeps strict stop() latency low
    STOP_JOIN_TIMEOUT_S = 2.0  # REQ-BOL-007
    MAX_PENDING_KEYS = 16  # REQ-BOL-005
    MAX_CNT = 3408  # REQ-BOL-004 sanity: 0 < cnt <= 3408
    MAX_PAGE = 1024  # REQ-BOL-004 sanity: page length <= 1024
    FRAG0_HDR = 67  # frag0 header length (incl. 11 extra bytes)
    FRAG_HDR = 56  # mid/last fragment header length
    HEARTBEAT_LEN = 16  # REQ-BOL-003

    def __init__(
        self,
        host: str,
        port: int,
        store: Any,
        local_port: int = 0,
        stream_port: int = 1234,
    ) -> None:
        super().__init__(host, port, store)
        self._local_port = int(local_port)
        self._stream_port = int(stream_port)  # REQ-BOL-001 (amended): source-port filter
        self._sock: socket.socket | None = None
        self._stop_flag = threading.Event()
        self._ping_thread: threading.Thread | None = None
        self._recv_thread: threading.Thread | None = None
        self._pending: OrderedDict[tuple[int, int], _PendingFrame] = OrderedDict()

    # -- lifecycle (REQ-ARCH-004) ------------------------------------------

    def start(self) -> None:
        """Open the socket and start ping + receive threads."""
        if self._sock is not None:
            return  # already running
        self._stop_flag.clear()
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            sock.bind(("0.0.0.0", self._local_port))  # REQ-BOL-001
            sock.settimeout(self.RECV_TIMEOUT_S)
        except OSError:
            sock.close()
            raise
        self._sock = sock
        self._recv_thread = threading.Thread(
            target=self._recv_loop, name=f"{self.name}-recv", daemon=True
        )
        self._ping_thread = threading.Thread(
            target=self._ping_loop, name=f"{self.name}-ping", daemon=True
        )
        self._recv_thread.start()
        self._ping_thread.start()

    def stop(self) -> None:
        """Idempotent stop: close socket, join all threads within 2 s
        (REQ-BOL-007). No further events afterwards."""
        if self._stop_flag.is_set() and self._sock is None:
            return
        self._stop_flag.set()
        sock, self._sock = self._sock, None
        if sock is not None:
            try:
                sock.close()  # unblocks recvfrom with OSError
            except OSError:
                pass
        for thread in (self._recv_thread, self._ping_thread):
            if thread is not None and thread.is_alive():
                thread.join(timeout=self.STOP_JOIN_TIMEOUT_S)
        self._recv_thread = self._ping_thread = None
        self._pending.clear()

    # -- worker threads -----------------------------------------------------

    def _ping_loop(self) -> None:
        interval = self.PING_INTERVAL_S
        while not self._stop_flag.wait(interval):  # sleep, wake instantly on stop
            sock = self._sock
            if sock is None:
                break
            try:
                sock.sendto(self.PING_PAYLOAD, (self.host, self.port))
            except OSError:
                break
            # REQ-BOL-002: one ping event per send, fields={"bytes": "EF000400"}
            self._add_event(
                "ping",
                f"{self.host}:{self.port}",
                len(self.PING_PAYLOAD),
                {"bytes": self.PING_FIELD_HEX},
                self.PING_PAYLOAD,
            )

    def _recv_loop(self) -> None:
        while not self._stop_flag.is_set():
            sock = self._sock
            if sock is None:
                break
            # Derived stats_sample (~1/s, REQ-TEL-004), also without traffic.
            self.store.maybe_emit_stats(time.monotonic())
            try:
                data, addr = sock.recvfrom(65535)
            except socket.timeout:
                continue
            except OSError:
                break  # socket closed by stop()
            src_ip, src_port = addr[0], addr[1]
            # REQ-BOL-001: wrong source ip -> drop silently (counter only);
            # datagrams from other peer ports are ignored as well (stream_port
            # filter, default 1234 — loopback tests pass the fake's port).
            # Datagrams that pass the filter are accounted via their own
            # telemetry event (REQ-TEL-004 amended: add_event w/ datagram_len>0).
            if src_ip != self.host or src_port != self._stream_port:
                self.store.record_input(time.monotonic(), len(data))
                continue
            try:
                self._handle_datagram(data, f"{src_ip}:{src_port}")
            except Exception:  # a bad datagram must never kill the loop
                self._add_event(
                    "malformed",
                    f"{src_ip}:{src_port}",
                    len(data),
                    {"reason": "parse_exception"},
                    data,
                )

    # -- datagram parsing (REQ-BOL-003/004) ----------------------------------

    def _handle_datagram(self, d: bytes, addr_s: str) -> None:
        if len(d) < 4:
            self._malformed(addr_s, d, {"reason": "too_short", "got_len": len(d)})
            return
        if d[0] != 0x93:
            self._malformed(addr_s, d, {"reason": "magic"})
            return
        dtype = d[1]
        if dtype == 4:
            self._handle_heartbeat(d, addr_s)
            return
        if dtype != 1:  # REQ-BOL-003: unknown d[1] -> unknown_type
            self._add_event("unknown_type", addr_s, len(d), {"type": dtype}, d)
            return
        self._handle_fragment(d, addr_s)

    def _handle_heartbeat(self, d: bytes, addr_s: str) -> None:
        if len(d) != self.HEARTBEAT_LEN:
            self._malformed(
                addr_s, d, {"want_len": self.HEARTBEAT_LEN, "got_len": len(d)}
            )
            return
        seq, pad, drift = struct.unpack("<III", d[4:16])
        self._add_event(
            "heartbeat",
            addr_s,
            len(d),
            {"seq": seq, "pad": pad, "drift": drift},
            d,
        )

    def _handle_fragment(self, d: bytes, addr_s: str) -> None:
        (want,) = struct.unpack_from("<H", d, 2)
        if want != len(d):  # REQ-BOL-003: framing length mismatch
            self._malformed(addr_s, d, {"want_len": want, "got_len": len(d)})
            return
        if len(d) < 68:  # REQ-BOL-004: fragment parsing needs >= 68 B
            self._malformed(addr_s, d, {"reason": "too_short", "got_len": len(d)})
            return
        (frame_id,) = struct.unpack_from("<I", d, 8)
        (idx,) = struct.unpack_from("<I", d, 32)
        (cnt,) = struct.unpack_from("<I", d, 36)
        (size,) = struct.unpack_from("<I", d, 40)
        w, h, q = struct.unpack_from("<HHH", d, 44)
        fields = {
            "frame_id": frame_id,
            "idx": idx,
            "cnt": cnt,
            "size": size,
            "w": w,
            "h": h,
            "q": q,
        }
        # Sanity rules (REQ-BOL-004): each violator -> drop + malformed.
        if not (0 < cnt <= self.MAX_CNT):
            self._malformed(addr_s, d, {"reason": "cnt_range", "cnt": cnt})
            return
        if idx >= cnt:
            self._malformed(
                addr_s, d, {"reason": "idx_range", "idx": idx, "cnt": cnt}
            )
            return
        if size <= 0:
            self._malformed(addr_s, d, {"reason": "size_range", "size": size})
            return
        page = d[self.FRAG0_HDR if idx == 0 else self.FRAG_HDR :]
        page_len = len(page)
        if page_len <= 0 or page_len > self.MAX_PAGE:
            self._malformed(
                addr_s, d, {"reason": "page_len", "page_len": page_len}
            )
            return
        expected = self._expected_page_len(idx, cnt, size)
        if page_len != expected:
            self._malformed(
                addr_s,
                d,
                {
                    "reason": "page_len_mismatch",
                    "page_len": page_len,
                    "expected": expected,
                },
            )
            return
        self._add_event("video_fragment", addr_s, len(d), fields, d)
        self._collect(frame_id, size, idx, cnt, page, w, h, q)

    @staticmethod
    def _expected_page_len(idx: int, cnt: int, size: int) -> int:
        """Expected page length (REQ-BOL-004 mid/last arithmetic); the single-
        fragment frame (cnt == 1, idx == 0) is its own last page: ``size``."""
        if idx == cnt - 1:
            return size - (cnt - 1) * 1024
        return 1024

    # -- reassembly (REQ-BOL-005) --------------------------------------------

    def _collect(
        self,
        frame_id: int,
        size: int,
        idx: int,
        cnt: int,
        page: bytes,
        w: int,
        h: int,
        q: int,
    ) -> None:
        key = (frame_id, size)
        entry = self._pending.get(key)
        if entry is None:
            while len(self._pending) >= self.MAX_PENDING_KEYS:
                self._pending.popitem(last=False)  # prune oldest key
                self._add_event("frame_dropped", "", 0, {"pruned": True})
            entry = _PendingFrame(cnt, w, h, q)
            self._pending[key] = entry
        entry.pages[idx] = page
        if len(entry.pages) < entry.cnt:
            return
        payload = b"".join(entry.pages[i] for i in range(entry.cnt))
        jpeg = assemble_jpeg(DEFAULT_HEADER, payload)
        del self._pending[key]
        # push first (network thread, REQ-ARCH-005), then the completion event
        self.store.push_frame(jpeg, time.monotonic())
        self._add_event(
            "frame_complete",
            "",
            0,
            {
                "frame_id": frame_id,
                "size": size,
                "cnt": cnt,
                "w": w,
                "h": h,
                "q": q,
            },
        )

    # -- event helper ---------------------------------------------------------

    def _add_event(
        self,
        kind: str,
        addr: str,
        datagram_len: int,
        fields: dict[str, Any],
        payload: bytes = b"",
    ) -> None:
        self.store.add_event(
            TelemetryEvent(
                ts=time.monotonic(),
                transport=self.name,
                kind=kind,
                addr=addr,
                datagram_len=datagram_len,
                fields=dict(fields),
                raw_hex=payload[:128].hex() if payload else "",
            )
        )

    def _malformed(
        self, addr_s: str, d: bytes, fields: dict[str, Any]
    ) -> None:
        self._add_event("malformed", addr_s, len(d), fields, d)
