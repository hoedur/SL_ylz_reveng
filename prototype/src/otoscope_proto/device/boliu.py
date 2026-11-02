"""BoliU/BL384 UDP transport — the live-validated stream protocol (REQ-BOL-001..007).

Empirical basis: ``analysis/01-arc42-architecture.md`` §10b /
``analysis/04-live-device-validation.md``; the contracts in
``prototype/docs/ARCHITECTURE.md`` are binding and take precedence.

Wire summary (all offsets into the received datagram ``d``):
- framing ``[0x93][01|04][len LE16]``; ``len16`` must equal ``len(d)``;
- fragment (``d[1]==1``): ``frame_id`` LE32 @8, ``idx`` LE32 @32, ``cnt`` LE32 @36,
  ``size`` LE32 @40, ``w``/``h``/``q`` LE16 @44/46/48; page data at ``d[56 : len-11]`` for
  ``idx==0`` (frag0 carries 11 trailing ASCII metadata bytes; every header is 56 B) else
  ``d[56:]``; *(2026-10-28: ``frame_id`` is empirically a ring-buffer slot id cycling in a
  tiny set {1..3} across sessions — frames are distinguished only by the
  ``(frame_id, size)`` key, which is why size is part of it; live confirm
  `analysis/artifacts/live_confirm_2026-10-28/`)*;
- heartbeat (``d[1]==4``, total length 16): ``seq`` LE32 @4, ``pad`` @8, ``drift`` @12;
- ping every 90 ms: ``EF 00 04 00`` to ``host:port`` (default 8800);
- reassembly keyed ``(frame_id, size)``, complete at first ``cnt`` indices,
  >16 pending keys pruned oldest-first; JPEG header picked per frame from the
  announced quality byte (low byte of ``q``, amended REQ-BOL-005/006);
  reconstructed JPEG pushed via the store.

Standard library only; no JPEG decoding here (the UI owns that).
"""

from __future__ import annotations

import socket
import struct
import threading
import time
from collections import OrderedDict
from typing import Any

from ..jpeg_frames import DEFAULT_HEADER, JPEG_HEADER_TABLE, assemble_jpeg
from ..telemetry import TelemetryEvent
from . import DeviceTransport

__all__ = ["BoliUReportTransport", "BoliUTransport"]


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
    port 1234 (REQ-BOL-001). The reconstruction header is selected per frame
    from the announced quality byte (amended REQ-BOL-005/006): the low byte
    of ``q`` keys ``JPEG_HEADER_TABLE``, an unknown level keeps the last
    selected head (initially ``DEFAULT_HEADER``), mirroring the native
    ``handle_mcu_msg_frag`` selection. All observations flow into the shared
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
    FRAG_HDR = 56  # every fragment's header length (REQ-BOL-004, wire-exact)
    FRAG0_TAIL = 11  # frag0-only trailing ASCII metadata, d[len-11:len] (amended REQ-BOL-004
    HEARTBEAT_LEN = 16  # REQ-BOL-003
    # REQ-BOL-005 amendment 2026-10-29 (doc-04 §9.12): app-parity completion
    # (last-page arrival + supersession, holes zero-filled). False in the base
    # ping-mode transport (strict all-pages; its tapes complete cleanly);
    # True in BoliUReportTransport — the device's flow control follows the
    # reported fid, which freezes under the strict rule when RF page losses
    # (invisible 802.11 FCS drops, ~4.4 pages/frame on tape #2) make an
    # all-pages completion impossible.
    _APP_PARITY_COMPLETION = False

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
        self._last_head: bytes | None = None  # amended REQ-BOL-005/006: sticky
        self._last_completed_frame_id = 0  # most recent fully reassembled frame
        self._newest_fid = 0  # REQ-BOL-005 amendment: newest frame id seen (supersession)

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
        if len(d) < 50:  # REQ-BOL-004: field access needs >= 50 B (q spans 48..50)
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
        # REQ-BOL-004 length floor, per index (amendment 2026-10-28, gate-1
        # round 1 validator 2): every fragment is 56-B header + page; frag0
        # additionally carries the 11-B trailing tail. A short LAST page
        # (page < 12 B -> datagram 57..67 B for idx > 0) is a valid fragment:
        # wire-proven on 10 short last pages across three tapes (the earlier
        # blanket <68 gate mis-classified them as "control datagrams").
        floor = 68 if idx == 0 else 57
        if len(d) < floor:
            self._malformed(addr_s, d, {"reason": "too_short", "got_len": len(d)})
            return
        # Amended REQ-BOL-004 (gate-1, 2026-10-27): frag0's page excludes the 11
        # trailing ASCII metadata bytes; mid/last pages have no tail.
        page = d[self.FRAG_HDR : len(d) - (self.FRAG0_TAIL if idx == 0 else 0)]
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
        fragment frame (cnt == 1, idx == 0) is its own last page: ``size``,
        with frag0's 11-byte trailing metadata sitting past the page end
        (derived from the amended REQ-BOL-004 layout; no cnt==1 frame observed
        live yet — verify on first occurrence)."""
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
            if self._APP_PARITY_COMPLETION and frame_id <= self._newest_fid:
                # REQ-BOL-005 amendment 2026-10-29: a fragment of an already
                # superseded/delivered frame arrives late — the native engine
                # drops it (ring slot no longer active for that fid).
                self._add_event(
                    "frame_dropped",
                    "",
                    0,
                    {"stale_fragment": True, "frame_id": frame_id},
                )
                return
            while len(self._pending) >= self.MAX_PENDING_KEYS:
                oldest = next(iter(self._pending))
                self._pending.popitem(last=False)  # prune oldest key
                if self._APP_PARITY_COMPLETION:
                    # app parity: a pruned elder is delivered (zero-filled),
                    # not dropped — the reported fid must keep advancing
                    self._deliver(oldest, superseded=True)
                else:
                    self._add_event("frame_dropped", "", 0, {"pruned": True})
            entry = _PendingFrame(cnt, w, h, q)
            self._pending[key] = entry
            self._newest_fid = max(self._newest_fid, frame_id)
            if self._APP_PARITY_COMPLETION:
                # REQ-BOL-005 amendment 2026-10-29 (doc-04 §9.12): the native
                # 4-slot ring keyed (fid-1)&3 recycles a slot when frame fid+4
                # opens — the elder frame is report-delivered then (tape: fid 4
                # state1 fired exactly when fid 8 started). Deliver pending
                # frames whose slot gets recycled now; the report fid keeps
                # advancing (H-1 fix).
                for k in [k for k in self._pending if k[0] <= frame_id - 4]:
                    self._deliver(k, superseded=True)
        entry.pages[idx] = page
        if self._APP_PARITY_COMPLETION:
            # REQ-BOL-005 amendment 2026-10-29: the frame completes when its
            # LAST page (idx == cnt-1) arrives — middle holes permitted and
            # zero-filled (the app displays such frames; only ~32/940 app-tape
            # frames are ever strictly complete at RF). Ping-mode transports
            # keep the strict all-pages rule (their tapes complete cleanly).
            if idx != cnt - 1:
                return
            self._deliver(key)
            return
        if len(entry.pages) < entry.cnt:
            return
        self._deliver(key)

    def _deliver(self, key: tuple[int, int], superseded: bool = False) -> None:
        """Assemble + push a frame and emit ``frame_complete`` (REQ-BOL-005).

        App-parity transports zero-fill missing pages (the native decoder
        serves stale ring-buffer content for them; ours are visibly neutral).
        """
        entry = self._pending.pop(key)
        frame_id, size = key
        payload = b"".join(
            entry.pages.get(i, b"\x00" * self._expected_page_len(i, entry.cnt, size))
            for i in range(entry.cnt)
        )
        # Amended REQ-BOL-005/006: pick the head matching the announced
        # quality byte (low byte of q). Unknown level -> sticky previous head
        # (initial DEFAULT_HEADER), like the native handle_mcu_msg_frag path.
        head = JPEG_HEADER_TABLE.header_for(entry.q & 0xFF)
        if head is None:
            head = self._last_head or DEFAULT_HEADER
        else:
            self._last_head = head
        jpeg = assemble_jpeg(head, payload, width=entry.w, height=entry.h)
        self._last_completed_frame_id = frame_id
        # push first (network thread, REQ-ARCH-005), then the completion event
        self.store.push_frame(jpeg, time.monotonic())
        self._add_event(
            "frame_complete",
            "",
            0,
            {
                "frame_id": frame_id,
                "size": size,
                "cnt": entry.cnt,
                "w": entry.w,
                "h": entry.h,
                "q": entry.q,
                **({"superseded": True} if superseded else {}),
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


class BoliUReportTransport(BoliUTransport):
    """REQ-BOL-008 + REQ-BOL-009 (2026-10-26): app-exact report mode, mirroring
    the ORIGINAL app's wire behavior (monitor captures
    `analysis/artifacts/app_stream_2026-10-26/` + the lossless restart tape,
    doc-04 §9.5/§9.6, arc42 §10b.10).

    On ``start()`` it runs the REQ-BOL-009 **bootstrap**: two ``EF 00 04 00``
    pings ~100 ms apart (the device arms the session and starts streaming
    ~0.10 s after the first ping — pure-report sessions never open), then two
    40 B empty reports (``EF 02 28 00``, record count 0). After that **no
    further pings are ever sent** (a continuous ping loop caps delivery at
    ≈3.7 fps, live-falsified); the steady state sends to ``host:port``:

    - receive-progress report every ``report_interval`` s (default 0.025 = the
      native 25-ms pacer, doc-04 §9.12): ``EF 02 40 00`` + magic ``02 02 00 01``,
      record count 1, constant ``0A 4B 14 2D`` at datagram offset 24, ``fid``
      LE32 (most recently completed frame), state 1, record size ``0x18`` and
      the FF×8 fragment bitmask; 64 B total (``len16`` counts the whole
      datagram). Reports stay silent until the first frame completes
      (fid-0 reports poison the stream — live-verified). While a newer frame
      is in flight the report becomes the app's two-record shape (80 B, REQ-BOL-008
      amendment 2026-10-29): record 2 = (in-flight fid, state 3, recSize 16).
    - **H-1 fix (2026-10-29)**: this transport uses app-parity completion
      (frames complete on last-page arrival or supersession, holes zero-filled)
      so the reported fid never freezes — the device halts streaming when the
      client's fid stalls (H-1 root cause, doc-04 §9.12).
    - stream keepalive every 1.64 s: ``EF 08 08 00`` + LE32 counter tracking
      the device heartbeat ``seq`` (the heartbeat mirrors stream age).

    Parsing/reassembly/lifecycle are inherited unchanged (REQ-BOL-001..007).
    """

    name = "boliu-report"

    # REQ-BOL-008 amendment 2026-10-29: default 0.025 s — the native pacer
    # (thread_timer sends build_send_ack when >=25 ms elapsed; libbl_vii_jni.so
    # disasm, doc-04 §9.12) and tape-#2 median report gap 24.9 ms. The earlier
    # 0.038 default (≈26.4/s) predated the pacer discovery.
    REPORT_INTERVAL_S = 0.025
    KEEPALIVE_INTERVAL_S = 1.64  # REQ-BOL-008 (device heartbeat cadence)
    REPORT_BODY_CONST = bytes.fromhex("0A4B142D")
    REPORT_MAGIC = bytes.fromhex("02020001")
    BOOTSTRAP_PING_GAP_S = 0.10  # REQ-BOL-009 (app: 2nd ping +0.10 s after the 1st)
    # REQ-BOL-005 amendment 2026-10-29: app-parity completion (last-page arrival
    # + supersession, holes zero-filled) — H-1 fix; see class docstring.
    _APP_PARITY_COMPLETION = True

    def __init__(
        self,
        host: str,
        port: int,
        store: Any,
        local_port: int = 0,
        stream_port: int = 1234,
        report_interval: float | None = None,
        keepalive_interval: float | None = None,
    ) -> None:
        super().__init__(host, port, store, local_port=local_port, stream_port=stream_port)
        self._report_interval = (
            self.REPORT_INTERVAL_S if report_interval is None else float(report_interval)
        )
        self._keepalive_interval = (
            self.KEEPALIVE_INTERVAL_S
            if keepalive_interval is None
            else float(keepalive_interval)
        )
        self._keepalive_seq = 0
        self._report_thread: threading.Thread | None = None
        self._keepalive_thread: threading.Thread | None = None

    # -- sandbox override: report mode never runs the continuous ping loop
    #    (REQ-BOL-009: the only pings are the two bootstrap pings) -----------

    def _ping_loop(self) -> None:  # REQ-BOL-008/009: no continuous EF 00 04 00
        while not self._stop_flag.is_set():
            if self._stop_flag.wait(self.PING_INTERVAL_S):
                return

    # -- datagram builders (pure, testable) ---------------------------------

    def build_empty_report(self) -> bytes:
        """40 B ``EF 02 28 00`` empty report, record count 0 (REQ-BOL-009).

        Byte layout from the app-restart tape: header + magic + count=0 +
        12 zero bytes + const at offset 24 + 12 zero bytes (8 B tail area).
        """
        d = bytearray(40)
        d[0:4] = b"\xEF\x02\x28\x00"
        d[4:8] = self.REPORT_MAGIC
        struct.pack_into("<I", d, 8, 0)  # record count 0
        d[24:28] = self.REPORT_BODY_CONST
        # everything else stays 0
        return bytes(d)

    def build_report(self, fid: int) -> bytes:
        """64 B ``EF 02 40 00`` receive-progress report (REQ-BOL-008).

        Layout from the original-app capture (artifacts/app_stream_2026-10-26),
        identical for the 88/104 B variants: const ``0A 4B 14 2D`` sits at
        body offset 20 (datagram offset 24), records start at datagram
        offset 32, 8-byte zero trailer at the end.
        """
        d = bytearray(64)
        d[0:4] = b"\xEF\x02\x40\x00"
        d[4:8] = self.REPORT_MAGIC
        struct.pack_into("<I", d, 8, 1)  # one record
        d[24:28] = self.REPORT_BODY_CONST  # position per capture (was wrongly 28)
        struct.pack_into("<I", d, 32, fid & 0xFFFFFFFF)  # fid u64 low word
        # d[12:24], d[28:32], d[36:40] stay 0
        struct.pack_into("<I", d, 40, 1)  # state: complete
        struct.pack_into("<I", d, 44, 0x18)  # record size field per capture
        d[48:56] = b"\xFF" * 8  # fragment bitmask: everything received
        # d[56:64] zero trailer
        return bytes(d)

    def build_keepalive(self, seq: int) -> bytes:
        """8 B ``EF 08 08 00`` stream keepalive (REQ-BOL-008)."""
        return b"\xEF\x08\x08\x00" + struct.pack("<I", seq & 0xFFFFFFFF)

    def build_two_record_report(self, fid: int, inflight_fid: int) -> bytes:
        """80 B two-record report (REQ-BOL-008 amendment 2026-10-29).

        The app's steady-state shape while a newer frame is in flight (tape #2:
        rec1 = completed fid, state 1, full mask; rec2 = in-flight fid, state 3,
        recSize 16 — no mask field; 32 hdr + 24 + 16 + 8 trailer = 80 B). This
        is the device's flow-control ticket: it proves the client is current
        and names the frame it is working on.
        """
        d = bytearray(80)
        d[0:4] = b"\xEF\x02\x50\x00"
        d[4:8] = self.REPORT_MAGIC
        struct.pack_into("<I", d, 8, 2)  # two records
        d[24:28] = self.REPORT_BODY_CONST
        # record 1: completed frame (state 1, recSize 0x18, full FF×8 mask)
        struct.pack_into("<I", d, 32, fid & 0xFFFFFFFF)
        struct.pack_into("<I", d, 40, 1)
        struct.pack_into("<I", d, 44, 0x18)
        d[48:56] = b"\xFF" * 8
        # record 2: in-flight frame (state 3, recSize 0x10, no mask)
        struct.pack_into("<I", d, 56, inflight_fid & 0xFFFFFFFF)
        struct.pack_into("<I", d, 64, 3)
        struct.pack_into("<I", d, 68, 0x10)
        # d[72:80] zero trailer stays 0
        return bytes(d)

    # -- worker threads -----------------------------------------------------

    def start(self) -> None:
        super().start()
        if self._report_thread is None:
            self._report_thread = threading.Thread(
                target=self._report_loop, name=f"{self.name}-report", daemon=True
            )
            self._report_thread.start()
        if self._keepalive_thread is None:
            self._keepalive_thread = threading.Thread(
                target=self._keepalive_loop, name=f"{self.name}-ka", daemon=True
            )
            self._keepalive_thread.start()

    def stop(self) -> None:
        super().stop()
        for thread in (self._report_thread, self._keepalive_thread):
            if thread is not None and thread.is_alive():
                thread.join(timeout=self.STOP_JOIN_TIMEOUT_S)
        self._report_thread = self._keepalive_thread = None

    def _bootstrap(self) -> bool:
        """REQ-BOL-009: 2× ``EF 00 04 00`` ping, then 2× empty report.

        Mirrors the app-restart tape exactly: first ping at +0.00 s, second at
        +0.10 s, empty reports right after (the device's first video fragment
        arrived +0.10 s after the first ping, the app's first record-bearing
        report +0.21 s). Returns False if stopped or the socket died.
        """
        sock = self._sock
        if sock is None:
            return False
        for _ in range(2):
            try:
                sock.sendto(self.PING_PAYLOAD, (self.host, self.port))
            except OSError:
                return False
            self._add_event("ping", f"{self.host}:{self.port}",
                            len(self.PING_PAYLOAD),
                            {"bytes": self.PING_FIELD_HEX}, self.PING_PAYLOAD)
            if self._stop_flag.wait(self.BOOTSTRAP_PING_GAP_S):
                return False
            sock = self._sock
            if sock is None:
                return False
        payload = self.build_empty_report()
        for _ in range(2):
            try:
                sock.sendto(payload, (self.host, self.port))
            except OSError:
                return False
            self._add_event("report_empty", f"{self.host}:{self.port}",
                            len(payload), {"nrec": 0}, payload)
        return True

    def _report_loop(self) -> None:
        # REQ-BOL-009: bootstrap before any steady-state traffic.
        if not self._bootstrap():
            return
        while not self._stop_flag.is_set():
            if self._stop_flag.wait(self._report_interval):
                return
            sock = self._sock
            if sock is None:
                return
            fid = self._last_completed_frame_id
            if fid == 0:
                # REQ-BOL-008 amendment (live-verified): a report claiming fid 0
                # (= "frame 0 complete") while the device is far ahead pauses
                # delivery entirely — falsified fid-0 reports poison the stream.
                # Stay silent until the first real completion.
                continue
            # REQ-BOL-008 amendment 2026-10-29 (H-1 fix, doc-04 §9.12): while a
            # newer frame is in flight, append the app's second record
            # (in-flight fid, state 3, recSize 16) — the flow-control ticket
            # that keeps the device streaming. rec1 keeps advancing thanks to
            # app-parity completion (last-page/supersession), so the device
            # never sees a stuck client.
            inflight = max((k[0] for k in self._pending), default=0)
            if inflight > fid:
                payload = self.build_two_record_report(fid, inflight)
                fields: dict[str, Any] = {"fid": fid, "inflight": inflight}
            else:
                payload = self.build_report(fid)
                fields = {"fid": fid}
            try:
                sock.sendto(payload, (self.host, self.port))
            except OSError:
                return
            self._add_event("report_ack", f"{self.host}:{self.port}", len(payload),
                            fields, payload)

    def _keepalive_loop(self) -> None:
        while not self._stop_flag.is_set():
            if self._stop_flag.wait(self._keepalive_interval):
                return
            sock = self._sock
            if sock is None:
                return
            payload = self.build_keepalive(self._keepalive_seq)
            try:
                sock.sendto(payload, (self.host, self.port))
            except OSError:
                return
            self._add_event("keepalive_tx", f"{self.host}:{self.port}", len(payload),
                            {"seq": self._keepalive_seq}, payload)
            self._keepalive_seq += 1

    def _handle_heartbeat(self, d: bytes, addr_s: str) -> None:
        super()._handle_heartbeat(d, addr_s)
        # REQ-BOL-008: track stream age — the heartbeat seq mirrors the
        # client-side stream-seconds counter of the original app.
        if len(d) == self.HEARTBEAT_LEN:
            (seq,) = struct.unpack_from("<I", d, 4)
            if seq > self._keepalive_seq:
                self._keepalive_seq = seq
