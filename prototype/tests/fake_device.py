"""Reference fake BoliU/BL384 device (test-only) — docs/ARCHITECTURE.md §5.

Spec-derived, deterministic, binds 127.0.0.1 (ephemeral UDP) via socketserver + threads
(§5 item 1, REQ-TEST-003). Never talks to a real device.

Rules implemented here (the ONLY source: ARCHITECTURE.md §5 + REQ-BOL-003/004):
- On EVERY received datagram: record sender, immediately stream ONE complete frame to
  the most recent sender (sticky behavior, §5 item 4). Fragments in index order 0..cnt-1,
  no pacing.
- Frame (§5 item 2): frame_id cycles 1,2,1,...; size default 2100 (cnt=3 -> pages
  1024+1024+52); payload = [i % 251 for i in range(size)].
- Fragment datagram layout (§5 item 2 + REQ-BOL-004, amended 2026-10-27 gate-1 wire-exact):
  framing prefix [0x93][01][len LE16] then a 52-B fragment header in every fragment; frag0
  additionally appends 11 trailing ASCII metadata bytes: page data starts at datagram byte 56
  (frag0 = 56 + 1024 + 11 = 1091 B, page = d[56:1080]); mid/last: page at byte 56 with no tail
  (mid = 1080 B, last = 56 + remainder B). REQ-BOL-004 byte offsets inside the datagram:
  frame_id@8 (LE32), idx@32, cnt@36, size@40 (LE32), w@44, h@46, q@48 (LE16). len16 (REQ-BOL-003)
  == full datagram length.
- Heartbeat (§5 item 3, REQ-BOL-003): 93 04 10 00 <seq LE32> 04 00 00 00 <drift LE32>
  (16 B), one per 1.6 s (tolerated +-0.8 s in tests) after the first datagram while any
  datagram arrived in the last 5 s.

Exposed for tests: port, start()/stop(), counters pings_rx / frames_sent, receipt log
``received``, record of heartbeat seq numbers ``heartbeat_seqs`` (+ ``heartbeat_ts``),
and ``sent_frags`` (every frame-fragment datagram sent, in order).

Amended §5 item 5 pins the fake's announced profile: w=640, h=360, q=0x4B (75) — these are the
constructor defaults below. The REQ-BOL-001 source-port question is resolved via the transport's
`stream_port` parameter (§5 item 5: `stream_port=fake.port`).
"""
from __future__ import annotations

import socketserver
import struct
import threading
import time
from collections import deque

#: Client ping on the wire, REQ-BOL-002 (what a conforming transport sends every 90 ms).
PING_BYTES = b"\xEF\x00\x04\x00"

_FRAG0_PAGE_OFFSET = 56  # §5 item 2 + amended REQ-BOL-004 (gate-1): frag0 page starts here
_FRAGN_PAGE_OFFSET = 56  # REQ-BOL-004: page of idx>0 datagrams starts here
_FRAG0_TAIL = b"-0214,-0894"  # frag0-only trailing ASCII metadata, 11 B (amended REQ-BOL-004)
_FRAG0_HEADER = _FRAG0_PAGE_OFFSET - 4   # 52 B after the 4 B framing prefix
_FRAGN_HEADER = _FRAGN_PAGE_OFFSET - 4   # 52 B after the 4 B framing prefix
_PAGE = 1024  # REQ-BOL-004 page length for idx==0 and mid fragments


def payload_bytes(size: int) -> bytes:
    """§5 item 2: deterministic frame payload ``[i % 251 for i in range(size)]``."""
    return bytes(i % 251 for i in range(size))


def build_fragment(
    frame_id: int,
    idx: int,
    cnt: int,
    size: int,
    page: bytes,
    w: int = 640,
    h: int = 360,
    q: int = 0x4B,
) -> bytes:
    """One framing-prefixed fragment datagram (§5 item 2 + REQ-BOL-003/004 layout).

    Byte layout (offsets are into the whole datagram, not the header):
      d[0]=0x93, d[1]=1, d[2:4]=len LE16, d[8:12]=frame_id LE32, d[32:36]=idx LE32,
      d[36:40]=cnt LE32, d[40:44]=size LE32, d[44:46]=w LE16, d[46:48]=h LE16,
      d[48:50]=q LE16, page = d[56:len-11] for idx==0 (11-B trailing tail), d[56:]
      otherwise.
    """
    header_len = _FRAG0_HEADER if idx == 0 else _FRAGN_HEADER
    tail = _FRAG0_TAIL if idx == 0 else b""
    total = 4 + header_len + len(page) + len(tail)
    d = bytearray(total)
    d[0] = 0x93
    d[1] = 0x01
    struct.pack_into("<H", d, 2, total)  # REQ-BOL-003: len16 == datagram length
    struct.pack_into("<I", d, 8, frame_id)
    struct.pack_into("<I", d, 32, idx)
    struct.pack_into("<I", d, 36, cnt)
    struct.pack_into("<I", d, 40, size)
    struct.pack_into("<H", d, 44, w)
    struct.pack_into("<H", d, 46, h)
    struct.pack_into("<H", d, 48, q)
    page_start = _FRAG0_PAGE_OFFSET if idx == 0 else _FRAGN_PAGE_OFFSET
    d[page_start : page_start + len(page)] = page
    if tail:
        d[len(d) - len(tail) :] = tail
    return bytes(d)


def build_heartbeat(seq: int, drift: int = 0x5E) -> bytes:
    """§5 item 3 heartbeat datagram: ``93 04 10 00 <seq LE32> 04 00 00 00 <drift LE32>``.

    16 B total; REQ-BOL-003 parses seq=d[4:8], pad=d[8:12], drift=d[12:16].
    drift defaults to 0x5E (the analysis drift prefix) — spec does not pin its value.
    """
    return (
        b"\x93\x04"
        + struct.pack("<H", 16)
        + struct.pack("<I", seq)
        + b"\x04\x00\x00\x00"  # pad word, literal per §5 item 3
        + struct.pack("<I", drift)
    )


class _Handler(socketserver.BaseRequestHandler):
    def handle(self) -> None:
        # UDP handlers: self.request = (data, socket), peer address = self.client_address
        data, _sock = self.request
        self.server.device._on_datagram(self.client_address, data)


class _FakeUDPServer(socketserver.ThreadingUDPServer):
    allow_reuse_address = True
    daemon_threads = True

    def __init__(self, addr, device: "FakeDevice") -> None:
        self.device = device
        super().__init__(addr, _Handler)


class FakeDevice:
    """§5 reference fake. Bind (and socket creation) happen in __init__ (so ``port``
    is immediately available); threads start only in :meth:`start`."""

    HB_PERIOD_S = 1.6      # §5 item 3 (tests tolerate ±0.8 s)
    ACTIVE_WINDOW_S = 5.0  # §5 item 3: heartbeats continue while activity < 5 s ago

    def __init__(
        self,
        frame_size: int = 2100,
        bind_host: str = "127.0.0.1",
        w: int = 640,
        h: int = 360,
        q: int = 0x4B,
    ) -> None:
        self.frame_size = frame_size
        self.w, self.h, self.q = w, h, q
        self._lock = threading.Lock()
        # --- state exposed to tests ---
        self.pings_rx = 0                 # datagrams received (§5: "on EVERY datagram")
        self.frames_sent = 0
        self.received: deque = deque(maxlen=4096)   # (addr_str, payload) per datagram
        self.sent_frags: list[bytes] = []           # frame fragments, in send order
        self.heartbeat_seqs: list[int] = []
        self.heartbeat_ts: list[float] = []
        # --- internal state ---
        self.reply_to = None
        self._first_rx = None
        self._last_rx = None
        self._hb_marker = None
        self._hb_seq = 0
        self._frame_count = 0
        self._srv = _FakeUDPServer((bind_host, 0), self)
        self.port = self._srv.server_address[1]
        self._server_thread: threading.Thread | None = None
        self._hb_thread: threading.Thread | None = None
        self._stopping = threading.Event()
        self._stopped = False

    # ------------------------------------------------------------------ lifecycle
    def start(self) -> None:
        self._server_thread = threading.Thread(
            target=self._srv.serve_forever, name="fake-device-rx", daemon=True
        )
        self._server_thread.start()
        self._hb_thread = threading.Thread(target=self._hb_loop, name="fake-device-hb", daemon=True)
        self._hb_thread.start()

    def stop(self) -> None:
        if self._stopped:
            return
        self._stopped = True
        self._stopping.set()
        try:
            self._srv.shutdown()
        except Exception:  # noqa: BLE001 - test helper must never raise on teardown
            pass
        try:
            self._srv.server_close()
        except Exception:  # noqa: BLE001
            pass
        if self._server_thread is not None:
            self._server_thread.join(2.0)
        if self._hb_thread is not None:
            self._hb_thread.join(1.0)

    # -------------------------------------------------------------- datagram path
    def _on_datagram(self, addr: tuple, data: bytes) -> None:
        now = time.monotonic()
        with self._lock:
            self.received.append((f"{addr[0]}:{addr[1]}", bytes(data)))
            self.pings_rx += 1
            self.reply_to = (addr[0], addr[1])  # §5 item 4: most recent sender
            if self._first_rx is None:
                self._first_rx = now
                self._hb_marker = now
            self._last_rx = now
        self._stream_one_frame((addr[0], addr[1]))

    def _stream_one_frame(self, addr: tuple) -> None:
        with self._lock:
            frame_id = 1 + (self._frame_count % 2)  # cycles 1,2,1,... (§5 item 2)
            self._frame_count += 1
            self.frames_sent += 1  # counted at dispatch, not after the final sendto
        size = self.frame_size
        cnt = (size + _PAGE - 1) // _PAGE
        payload = payload_bytes(size)
        pages = [payload[i * _PAGE:(i + 1) * _PAGE] for i in range(cnt)]
        datagrams = [
            build_fragment(frame_id, idx, cnt, size, pages[idx], self.w, self.h, self.q)
            for idx in range(cnt)
        ]
        for dgram in datagrams:
            try:
                self._srv.socket.sendto(dgram, addr)
            except OSError:
                return
            with self._lock:
                self.sent_frags.append(dgram)

    def _hb_loop(self) -> None:
        while not self._stopping.wait(0.05):
            now = time.monotonic()
            with self._lock:
                addr = self.reply_to
                first, marker, last = self._first_rx, self._hb_marker, self._last_rx
            if addr is None or first is None:
                continue
            if last is not None and (now - last) > self.ACTIVE_WINDOW_S:
                continue
            if marker is None or (now - marker) < self.HB_PERIOD_S:
                continue
            with self._lock:
                seq = self._hb_seq
                self._hb_seq += 1
                self.heartbeat_seqs.append(seq)
                self.heartbeat_ts.append(now)
                self._hb_marker = now
            try:
                self._srv.socket.sendto(build_heartbeat(seq), addr)
            except OSError:
                pass
