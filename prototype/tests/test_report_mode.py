"""Report-mode transport tests (REQ-BOL-008/009, added 2026-10-26).

Vectors per the original-app monitor capture (doc-04 §9.5, arc42 §10b.10):

- report datagram: ``EF 02 40 00`` + body ``02 02 00 01 | 01 00 00 00 | 12×00 |
  0A 4B 14 2D | fid LE32 | 00 00 00 00 | 01 00 00 00 | 18 00 00 00 | FF×8 |
  00 00 00 00 00 00 00 00`` (64 B total, len16 = 64 counts the whole datagram;
  4×00 before fid — const ``0A 4B 14 2D`` at datagram offset 24);
  ``fid`` = most recently completed frame_id, 0 until the first completion.
- keepalive: ``EF 08 08 00`` + one LE32 = seconds since transport start,
  initialized from the seq of the first received heartbeat.
- no ``EF 00 04 00`` ping is ever sent in report mode.

Loopback harness mirrors test_boliu_datagrams.py: fixed ``local_port``, ping
sink bound on 127.0.0.1 (absorbs keepalive/reports), fake device socket from
127.0.0.1:1234.
"""

import socket
import struct
import time

import pytest

from otoscope_proto.device.boliu import BoliUReportTransport, BoliUTransport
from otoscope_proto.telemetry import TelemetryStore

W, H, Q = 640, 444, 77
DEVICE_SRC_IP = "127.0.0.1"
DEVICE_SRC_PORT = 1234

REPORT_INTERVAL = 0.02  # fast cadence so tests do not sleep long
KEEPALIVE_INTERVAL = 0.05  # shortened only for test throughput

# amended REQ-BOL-004 (gate-1): frag0's trailing ASCII metadata on the wire
# (example bytes observed at d[len-11:len]; stashed natively, not page data)
FRAG0_TAIL = b"-0214,-0894"


def mkpage(tag: int, length: int) -> bytes:
    return bytes((tag * 31 + 7 * i) % 251 for i in range(length))


def fragment(frame_id, idx, cnt, size, page, *, w=W, h=H, q=Q):
    head = 56
    tail = FRAG0_TAIL if idx == 0 else b""
    d = bytearray(head + len(page) + len(tail))
    d[0] = 0x93
    d[1] = 1
    struct.pack_into("<H", d, 2, len(d))
    d[4:8] = b"\x02\x02\x00\x01"
    struct.pack_into("<I", d, 8, frame_id)
    struct.pack_into("<I", d, 16, 0)
    struct.pack_into("<I", d, 32, idx)
    struct.pack_into("<I", d, 36, cnt)
    struct.pack_into("<I", d, 40, size)
    struct.pack_into("<H", d, 44, w)
    struct.pack_into("<H", d, 46, h)
    struct.pack_into("<H", d, 48, q)
    d[head : head + len(page)] = page
    if tail:
        d[len(d) - len(tail) :] = tail
    return bytes(d)


def heartbeat(seq: int, pad: int = 0x4, drift: int = 0x505E) -> bytes:
    d = bytearray(16)
    d[0] = 0x93
    d[1] = 4
    struct.pack_into("<H", d, 2, 16)
    struct.pack_into("<I", d, 4, seq)
    struct.pack_into("<I", d, 8, pad)
    struct.pack_into("<I", d, 12, drift)
    return bytes(d)


def expected_report(fid: int) -> bytes:
    d = bytearray(64)
    d[0:4] = b"\xEF\x02\x40\x00"
    d[4:8] = b"\x02\x02\x00\x01"
    struct.pack_into("<I", d, 8, 1)
    d[24:28] = b"\x0a\x4b\x14\x2d"  # const position per the app capture
    struct.pack_into("<I", d, 32, fid)
    d[40:44] = b"\x01\x00\x00\x00"
    struct.pack_into("<I", d, 44, 0x18)
    d[48:56] = b"\xff" * 8
    return bytes(d)


def expected_keepalive(seq: int) -> bytes:
    return b"\xEF\x08\x08\x00" + struct.pack("<I", seq)


def free_udp_port() -> int:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]
    finally:
        s.close()


class Collector:
    def __init__(self, store: TelemetryStore) -> None:
        self.store = store
        self.idx = 0
        self.events = []

    def pump(self):
        evs, self.idx = self.store.get_since(self.idx)
        self.events.extend(evs)
        return evs

    def wait_for(self, desc, pred, timeout=5.0):
        deadline = time.monotonic() + timeout
        while True:
            self.pump()
            for ev in self.events:
                if pred(ev):
                    return ev
            if time.monotonic() >= deadline:
                seen = {}
                for e in self.events:
                    seen[e.kind] = seen.get(e.kind, 0) + 1
                pytest.fail(f"timeout after {timeout:.1f}s waiting for {desc}; saw {seen}")
            time.sleep(0.01)

    def settle(self, seconds=0.3):
        time.sleep(seconds)
        self.pump()

    def by_kind(self, kind):
        return [e for e in self.events if e.kind == kind]


class ReportHarness:
    """Report transport + loopback ping sink, bounded lifetime (REQ-BOL-008)."""

    def __init__(self, **kwargs) -> None:
        self.sink = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sink.bind(("127.0.0.1", 0))
        self.sink_port = self.sink.getsockname()[1]
        self.local_port = free_udp_port()
        self.store = TelemetryStore("boliu")
        self.transport = BoliUReportTransport(
            "127.0.0.1",
            self.sink_port,
            self.store,
            local_port=self.local_port,
            report_interval=REPORT_INTERVAL,
            keepalive_interval=KEEPALIVE_INTERVAL,
            **kwargs,
        )
        self.col = Collector(self.store)
        self._sender = None
        self.transport.start()
        self.col.wait_for(
            "first report_ack or keepalive_tx",
            lambda e: e.kind in ("report_ack", "keepalive_tx"),
            timeout=5.0,
        )

    def device(self):
        if self._sender is None:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.bind((DEVICE_SRC_IP, DEVICE_SRC_PORT))
            self._sender = s
        return self._sender

    def send(self, payload):
        self.device().sendto(payload, ("127.0.0.1", self.local_port))

    def complete_frame(self, frame_id: int = 7, size: int = 2100) -> None:
        """Feed a fully-receivable 3-fragment frame (1024+1024+52)."""
        self.send(fragment(frame_id, 0, 3, size, mkpage(1, 1024)))
        self.send(fragment(frame_id, 1, 3, size, mkpage(2, 1024)))
        self.send(fragment(frame_id, 2, 3, size, mkpage(3, size - 2048)))

    def drain_sends(self):
        """Anything in the UDP queue at the sink right now, drained once."""
        self.sink.setblocking(False)
        got = []
        while True:
            try:
                got.append(self.sink.recv(2048))
            except BlockingIOError:
                break
        self.sink.setblocking(True)
        return got

    def close(self):
        self.transport.stop()
        self.transport.stop()
        if self._sender is not None:
            self._sender.close()
        self.sink.close()


@pytest.fixture
def h():
    harness = ReportHarness()
    try:
        yield harness
    finally:
        harness.close()


# --- REQ-BOL-008: report datagram bytes --------------------------------------


def test_no_report_before_first_completion(h):
    """"REQ-BOL-008 amendment (live-verified): fid-0 reports poison the stream —
    stay silent until the first real frame completes."""
    h.col.settle(0.5)
    h.col.pump()
    assert h.col.by_kind("report_ack") == []
    # keepalives still flow in the meantime
    h.col.wait_for("keepalive_tx", lambda e: e.kind == "keepalive_tx", timeout=3.0)


def test_report_follows_first_completion(h):
    h.complete_frame(frame_id=6)
    ev = h.col.wait_for(
        "report_ack with fid 6",
        lambda e: e.kind == "report_ack" and e.fields.get("fid") == 6,
        timeout=5.0,
    )
    assert ev.fields == {"fid": 6}


def test_report_datagram_len16_counts_whole_datagram(h):
    h.complete_frame(frame_id=3)
    deadline = time.monotonic() + 2.0
    wire = []
    while time.monotonic() < deadline:
        wire = list(h.drain_sends())
        reports = [d for d in wire if len(d) == 64 and d[:4] == b"\xEF\x02\x40\x00"]
        if reports:
            break
        time.sleep(0.005)
    assert reports, f"no report hit the sink: {[d[:8].hex() for d in wire]}"


def test_wire_report_matches_expected_report_bytes(h):
    """Byte-exact end-to-end: the datagram written to the wire IS expected_report(fid)."""
    h.complete_frame(frame_id=9)
    matched = False
    deadline = time.monotonic() + 2.0
    want = expected_report(9)
    while time.monotonic() < deadline and not matched:
        for d in h.drain_sends():
            if len(d) == 64 and d[:4] == b"\xEF\x02\x40\x00":
                if d == want:
                    matched = True
                    break
        time.sleep(0.005)
    assert matched, "wire report datagram did not equal the expected 64-byte report"


def test_report_fid_tracks_latest_completed_frame(h):
    h.complete_frame(frame_id=2)
    h.complete_frame(frame_id=5)
    ev = h.col.wait_for(
        "report_ack with fid 5",
        lambda e: e.kind == "report_ack" and e.fields.get("fid") == 5,
        timeout=5.0,
    )
    assert ev.fields == {"fid": 5}


# --- REQ-BOL-008: keepalive ----------------------------------------------------


def test_keepalive_seq_initializes_from_first_heartbeat(h):
    h.send(heartbeat(seq=23))
    ev = h.col.wait_for(
        "keepalive_tx",
        lambda e: e.kind == "keepalive_tx" and e.fields.get("seq", 0) > 20,
        timeout=5.0,
    )
    assert ev.fields["seq"] >= 23


def test_keepalive_byte_exact(h):
    h.send(heartbeat(seq=7))
    ev = h.col.wait_for(
        "keepalive_tx",
        lambda e: e.kind == "keepalive_tx",
        timeout=5.0,
    )
    deadline = time.monotonic() + 2.0
    wire = []
    while time.monotonic() < deadline:
        wire = list(h.drain_sends())
        kas = [d for d in wire if d[:4] == b"\xEF\x08\x08\x00"]
        if kas:
            break
        time.sleep(0.005)
    assert kas
    seq = struct.unpack_from("<I", kas[-1], 4)[0]
    assert struct.unpack("<H", kas[-1][2:4])[0] == 8  # len16 == 8 == len(d)
    assert len(kas[-1]) == 8
    assert seq == ev.fields["seq"]


# --- REQ-BOL-009: bootstrap (2× ping, then 2× empty report, then silence) -----


def test_bootstrap_order_pings_then_empty_reports(h):
    """REQ-BOL-009: the first transport-emitted datagram events are
    ping, ping, report_empty, report_empty (app tape: pings 0.10 s apart,
    empties right after) and nothing precedes them."""
    h.col.settle(0.6)
    named = [e.kind for e in h.col.events if e.kind in ("ping", "report_empty")]
    assert named[:4] == ["ping", "ping", "report_empty", "report_empty"], named[:6]


def test_ping_never_after_bootstrap(h):
    """REQ-BOL-009: exactly two pings for the whole transport lifetime —
    a continuous ping loop caps delivery at ≈3.7 fps (live-falsified)."""
    h.complete_frame(frame_id=40)
    h.col.settle(0.6)
    assert len(h.col.by_kind("ping")) == 2


def test_bootstrap_empty_report_wire_bytes(h):
    want = (b"\xEF\x02\x28\x00" + b"\x02\x02\x00\x01" + b"\x00" * 4
            + b"\x00" * 12 + b"\x0a\x4b\x14\x2d" + b"\x00" * 12)
    assert len(want) == 40
    h.col.settle(0.3)
    empties = h.col.by_kind("report_empty")
    assert len(empties) == 2
    # events carry the exact sent bytes (raw_hex covers all 40 B)
    assert bytes.fromhex(empties[0].raw_hex) == want


def test_bootstrap_empty_report_event_fields(h):
    h.col.settle(0.3)
    empties = h.col.by_kind("report_empty")
    assert len(empties) == 2
    assert all(e.fields == {"nrec": 0} for e in empties)


def test_no_ping_datagram_ever(h):
    """REQ-BOL-009 (amended from 'no ping ever'): in steady state the wire
    carries no ping — the two bootstrap pings already happened before the
    first frame completed, so nothing after the first report_ack is a ping."""
    h.complete_frame(frame_id=42)
    h.col.wait_for(
        "first report_ack",
        lambda e: e.kind == "report_ack",
        timeout=5.0,
    )
    h.drain_sends()  # flush datagrams queued during the bootstrap
    h.col.settle(0.2)
    wire = []
    deadline = time.monotonic() + 0.5
    while time.monotonic() < deadline:
        wire.extend(h.drain_sends())
        time.sleep(0.02)
    assert bytes.fromhex("EF000400") not in wire


# --- REQ-BOL-008: inherited behavior intact -------------------------------------


def test_completed_frame_still_reaches_store_with_q_head(h):
    h.complete_frame(frame_id=11)
    deadline = time.monotonic() + 2.0
    got = None
    while time.monotonic() < deadline:
        got = h.store.pop_frame()
        if got:
            break
        time.sleep(0.01)
    assert got, "completed frame not pushed (fragments + reassembly must be inherited)"
    f, _ts = got  # REQ-TEL-002: pop_frame() -> (bytes, monotonic ts)
    # REQ-BOL-005/006: 605-h + payload + FF D9
    assert len(f) == 605 + 2100 + 2


def test_default_report_interval_matches_app_rate():
    # 0.038 s ≈ the original app's sustained ~26.4 reports/s (lossless capture)
    assert BoliUReportTransport.REPORT_INTERVAL_S == pytest.approx(0.038)
    t = BoliUReportTransport("127.0.0.1", 1, TelemetryStore("boliu"))
    assert t._report_interval == pytest.approx(0.038)
    assert t._keepalive_interval == pytest.approx(1.64)
    # REQ-BOL-009
    assert t.BOOTSTRAP_PING_GAP_S == pytest.approx(0.10)



def test_base_transport_unchanged_signature():
    t = BoliUTransport("127.0.0.1", 1, TelemetryStore("boliu"))
    assert t.PING_PAYLOAD == bytes.fromhex("EF000400")
