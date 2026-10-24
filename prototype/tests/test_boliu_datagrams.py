"""Datagram-level tests for the BoliU/BL384 UDP transport (REQ-BOL-001..004).

Black-box, hand-crafted vectors per REQ-TEST-004 (no pcaps), byte layout from
REQ-BOL-003/004:

- transport head: d[0]=0x93, d[1] in {1,4}, len16 = LE16(d[2:4]) == len(datagram)
- fragment datagrams: sig ``02 02 00 01`` @4, frame_id u32 LE @8, dup u32 LE @16,
  idx u32 LE @32, cnt u32 LE @36, size u32 LE @40, w u16 LE @44, h u16 LE @46,
  q u16 LE @48; page data = d[67:] when idx == 0 (frag0, expects 1024 B),
  else d[56:] (mid: 1024 B, last: size - (cnt-1)*1024 B). Amended REQ-BOL-004:
  field access needs >= 50 B (shorter type-1 datagrams -> malformed); a parsed
  fragment yielding a zero-length page (datagram shorter than its head length)
  is also malformed.
- heartbeat: 16 B total, seq = LE32(d[4:8]), pad = LE32(d[8:12]), drift = LE32(d[12:16])

Playbook per REQ-BOL-001 (fixed ``local_port``) and REQ-TEST-003 (localhost only):
``BoliUTransport(host="127.0.0.1", port=<ephemeral ping-sink port>, store,
local_port=<fixed>)``; the "device" side is a plain UDP socket bound to
127.0.0.1:1234 (source port mandated by REQ-BOL-001); wrong-source tests bind
127.0.0.2:1234 / an ephemeral port.

Queue-drain side effects are asserted through ``store.pop_frame()`` (REQ-TEL-002).
"""

import socket
import struct
import time

import pytest

from otoscope_proto.device.boliu import BoliUTransport
from otoscope_proto.telemetry import TelemetryStore

# --- test profile constants ------------------------------------------------

# Field values chosen so a wrong offset parse shows up as an exact value
# mismatch (every field below is unique except w=640 which REQ-BOL-004 fixes).
W, H, Q = 640, 444, 77
DEVICE_SRC_IP = "127.0.0.1"  # == transport's `host` (REQ-BOL-001 filter)
DEVICE_SRC_PORT = 1234  # REQ-BOL-001: only datagrams from this port are accepted


def mkpage(tag: int, length: int) -> bytes:
    """Deterministic tag-flavored page payload (not JPEG-decodable, per spec §5)."""
    return bytes((tag * 31 + 7 * i) % 251 for i in range(length))


def fragment(frame_id, idx, cnt, size, page, *, w=W, h=H, q=Q, dup=0):
    """Build one [0x93][01][len16] fragmented-video datagram per REQ-BOL-004."""
    head = 67 if idx == 0 else 56
    d = bytearray(head + len(page))
    d[0] = 0x93
    d[1] = 1
    struct.pack_into("<H", d, 2, len(d))
    d[4:8] = b"\x02\x02\x00\x01"
    struct.pack_into("<I", d, 8, frame_id)
    struct.pack_into("<I", d, 16, dup)
    struct.pack_into("<I", d, 32, idx)
    struct.pack_into("<I", d, 36, cnt)
    struct.pack_into("<I", d, 40, size)
    struct.pack_into("<H", d, 44, w)
    struct.pack_into("<H", d, 46, h)
    struct.pack_into("<H", d, 48, q)
    d[head:] = page
    return bytes(d)


def heartbeat(seq: int, pad: int, drift: int, extra: int = 0) -> bytes:
    """Build a [0x93][04][len16] heartbeat datagram per REQ-BOL-003 (+padding)."""
    d = bytearray(16 + extra)
    d[0] = 0x93
    d[1] = 4
    struct.pack_into("<H", d, 2, 16 if extra == 0 else len(d))
    struct.pack_into("<I", d, 4, seq)
    struct.pack_into("<I", d, 8, pad)
    struct.pack_into("<I", d, 12, drift)
    return bytes(d)


def unknown_type(tp: int) -> bytes:
    """Datagram with an unsupported d[1] type byte (REQ-BOL-003)."""
    return bytes([0x93, tp]) + struct.pack("<H", 8) + b"\x00\x00\x00\x00"


def free_udp_port() -> int:
    """Probe an ephemeral loopback port; released before the transport binds it."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]
    finally:
        s.close()


class Collector:
    """Accumulating reader of ``TelemetryStore.get_since``."""

    def __init__(self, store: TelemetryStore) -> None:
        self.store = store
        # get_since(idx) yields events NEWER than idx (spec §6). Start at 0 and
        # always feed the returned next_idx back in — robust under either
        # common numbering convention; the only event possibly skipped is the
        # store's very first one (a ping), which no assertion depends on.
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
            time.sleep(0.02)

    def wait_for_count(self, kind, n, timeout=5.0):
        deadline = time.monotonic() + timeout
        while len(self.by_kind(kind)) < n:
            self.pump()
            if time.monotonic() >= deadline:
                seen = {}
                for e in self.events:
                    seen[e.kind] = seen.get(e.kind, 0) + 1
                pytest.fail(
                    f"timeout after {timeout:.1f}s waiting for {n}x {kind}; saw {seen}"
                )
            time.sleep(0.02)
        self.pump()

    def settle(self, seconds=0.3):
        time.sleep(seconds)
        self.pump()

    def by_kind(self, kind):
        return [e for e in self.events if e.kind == kind]


class LoopbackHarness:
    """One BoliUTransport + loopback 'device' sender sockets, bounded lifetime."""

    def __init__(self) -> None:
        # Ping sink absorbs the transport's pings (REQ-BOL-002) so the kernel
        # does not answer ICMP-unreachable on the transport's socket.
        self.ping_sink = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.ping_sink.bind(("127.0.0.1", 0))
        self.ping_port = self.ping_sink.getsockname()[1]
        # REQ-BOL-001: client binds a fixed local port injected via local_port.
        self.local_port = free_udp_port()
        self.store = TelemetryStore("boliu")
        self.transport = BoliUTransport(
            "127.0.0.1", self.ping_port, self.store, local_port=self.local_port
        )
        self.col = Collector(self.store)
        self._senders = {}
        self.transport.start()
        # Gate on the first ping event: proves socket bound + worker running.
        self.col.wait_for("first ping event", lambda e: e.kind == "ping", timeout=5.0)
        time.sleep(0.05)

    def sender(self, ip=DEVICE_SRC_IP, port=DEVICE_SRC_PORT):
        key = (ip, port)
        if key not in self._senders:
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.bind((ip, port))
            self._senders[key] = s
        return self._senders[key]

    def send(self, payload, ip=DEVICE_SRC_IP, port=DEVICE_SRC_PORT):
        self.sender(ip, port).sendto(payload, ("127.0.0.1", self.local_port))

    def pop_frames(self):
        frames = []
        while True:
            f = self.store.pop_frame()  # () = none (REQ-TEL-002)
            if not f:
                return frames
            frames.append(f)

    def assert_no_frames(self):
        assert self.pop_frames() == []

    def close(self):
        self.transport.stop()
        self.transport.stop()  # REQ-ARCH-004: stop() is idempotent
        for s in self._senders.values():
            s.close()
        self.ping_sink.close()


@pytest.fixture
def h():
    harness = LoopbackHarness()
    try:
        yield harness
    finally:
        harness.close()


def assert_fragment_fields(ev, frame_id, idx, cnt, size, *, w=W, h=H, q=Q):
    assert ev.fields["frame_id"] == frame_id
    assert ev.fields["idx"] == idx
    assert ev.fields["cnt"] == cnt
    assert ev.fields["size"] == size
    assert ev.fields["w"] == w
    assert ev.fields["h"] == h
    assert ev.fields["q"] == q


# --- valid fragments: parsed into `video_fragment` events (REQ-BOL-004) ----


def test_valid_frag0_produces_video_fragment_event(h):
    d = fragment(42, 0, 3, 2100, mkpage(1, 1024))  # total 4+63+1024 = 1091 B
    h.send(d)
    ev = h.col.wait_for(
        "video_fragment for frag0 frame_id=42",
        lambda e: e.kind == "video_fragment" and e.fields.get("frame_id") == 42,
    )
    h.col.settle()
    assert len(h.col.by_kind("video_fragment")) == 1
    assert_fragment_fields(ev, 42, idx=0, cnt=3, size=2100)
    assert ev.addr == f"{DEVICE_SRC_IP}:{DEVICE_SRC_PORT}"
    assert ev.datagram_len == len(d) == 1091
    # REQ-TEL-001: wire events carry the payload head as lowercase hex
    assert ev.raw_hex == d[:128].hex()
    # frag0 alone must not complete or push anything
    assert h.col.by_kind("frame_complete") == []
    h.col.settle(0.3)
    h.assert_no_frames()


def test_valid_mid_fragment_produces_video_fragment_event(h):
    d = fragment(43, 1, 3, 2100, mkpage(2, 1024))  # 56 B header + 1024 B page
    h.send(d)
    ev = h.col.wait_for(
        "video_fragment for mid frame_id=43",
        lambda e: e.kind == "video_fragment" and e.fields.get("frame_id") == 43,
    )
    assert_fragment_fields(ev, 43, idx=1, cnt=3, size=2100)
    assert ev.datagram_len == len(d) == 1080
    assert h.col.by_kind("malformed") == []


def test_valid_last_fragment_produces_video_fragment_event(h):
    d = fragment(44, 2, 3, 2100, mkpage(3, 52))  # last = 2100 - 2*1024 = 52 B
    h.send(d)
    ev = h.col.wait_for(
        "video_fragment for last frame_id=44",
        lambda e: e.kind == "video_fragment" and e.fields.get("frame_id") == 44,
    )
    assert_fragment_fields(ev, 44, idx=2, cnt=3, size=2100)
    assert ev.datagram_len == len(d) == 108
    assert h.col.by_kind("malformed") == []


# --- heartbeat (REQ-BOL-003) -----------------------------------------------


def test_valid_heartbeat_yields_heartbeat_event(h):
    d = heartbeat(seq=1001, pad=4, drift=0x5E42)
    assert len(d) == 16
    h.send(d)
    ev = h.col.wait_for("heartbeat seq=1001", lambda e: e.kind == "heartbeat")
    h.col.settle()
    assert ev.fields["seq"] == 1001
    assert ev.fields["pad"] == 4
    assert ev.fields["drift"] == 0x5E42
    assert ev.addr == f"{DEVICE_SRC_IP}:{DEVICE_SRC_PORT}"
    assert ev.datagram_len == 16


def test_heartbeat_wrong_length_is_malformed(h):
    # REQ-BOL-003: "Heartbeat with wrong length -> malformed".
    bad = heartbeat(seq=1, pad=2, drift=3, extra=1)  # 17 B
    h.send(bad)
    h.col.wait_for("malformed event for the 17 B heartbeat", lambda e: e.kind == "malformed")
    h.send(heartbeat(seq=2002, pad=4, drift=5))
    h.col.wait_for("subsequent valid heartbeat", lambda e: e.kind == "heartbeat")
    h.col.settle()
    assert len(h.col.by_kind("malformed")) == 1
    # nothing was pushed to the frame queue by the malformed datagram
    h.col.settle(0.3)
    h.assert_no_frames()


# --- transport head checks (REQ-BOL-003) ------------------------------------


def test_len16_head_mismatch_is_malformed_with_want_len(h):
    d = bytearray(fragment(99, 0, 3, 2100, mkpage(7, 1024)))
    wrong = len(d) + 10
    struct.pack_into("<H", d, 2, wrong)
    h.send(bytes(d))
    ev = h.col.wait_for("malformed len16 mismatch", lambda e: e.kind == "malformed")
    # fields = {"want_len": int, ...}
    assert ev.fields["want_len"] == wrong
    h.col.settle()
    assert len(h.col.by_kind("malformed")) == 1


def test_unknown_type_byte_is_reported_as_unknown_type(h):
    d = unknown_type(7)
    h.send(d)
    ev = h.col.wait_for(
        "unknown_type event for d[1]=7",
        lambda e: e.kind == "unknown_type" and e.fields.get("type") == 7,
    )
    assert ev.fields["type"] == 7
    h.col.settle()
    assert len(h.col.by_kind("unknown_type")) == 1
    assert h.col.by_kind("malformed") == []


# --- fragment sanity rules (REQ-BOL-004): each violator -> one malformed ----
# Crafted directly from the amended REQ-BOL-004 byte layout via the in-file
# builder (no `page_len=` kwarg): each datagram carries an actual page of the
# violating length, so the wire bytes are exactly what the transport receives.

VIOLATIONS = {
    # idx=0 < cnt=0 and idx=0 == cnt: sanity (idx < cnt) impossible -> malformed
    "cnt_zero": dict(frame_id=51, idx=0, cnt=0, size=2100, page=mkpage(11, 1024)),
    # idx=1 >= cnt=1 -> malformed
    "idx_ge_cnt": dict(frame_id=52, idx=1, cnt=1, size=1024, page=mkpage(12, 1024)),
    # size=0 -> malformed
    "size_zero": dict(frame_id=53, idx=1, cnt=3, size=0, page=mkpage(13, 1024)),
    # mid with a 512 B page (< 1024) -> malformed
    "mid_page_shorter_than_1024": dict(frame_id=54, idx=1, cnt=3, size=2100, page=mkpage(14, 512)),
    # last with a 100 B page (> remainder 2100 - 2*1024 = 52) -> malformed
    "last_page_longer_than_remainder": dict(frame_id=55, idx=2, cnt=3, size=2100, page=mkpage(15, 100)),
    # frag0 with a 1030 B page (> 1024) -> malformed
    "page_longer_than_1024": dict(frame_id=56, idx=0, cnt=3, size=2100, page=mkpage(16, 1030)),
}


@pytest.mark.parametrize("case", sorted(VIOLATIONS))
def test_fragment_sanity_violations_are_malformed_and_push_nothing(h, case):
    # REQ-BOL-004: "each violator -> drop + malformed, keep processing others".
    kw = VIOLATIONS[case]
    bad = fragment(**kw)
    h.send(bad)
    h.col.wait_for(f"malformed for {case}", lambda e: e.kind == "malformed")

    # the transport keeps processing following datagrams: a valid frag0 parses
    probe = fragment(90, 0, 3, 2100, mkpage(9, 1024))
    h.send(probe)
    h.col.wait_for(
        "video_fragment of the valid probe after the violation",
        lambda e: e.kind == "video_fragment" and e.fields.get("frame_id") == 90,
    )
    h.col.settle()
    assert len(h.col.by_kind("malformed")) == 1
    assert len(h.col.by_kind("video_fragment")) == 1
    # nothing was reassembled/pushed despite the violation
    assert h.col.by_kind("frame_complete") == []
    h.col.settle(0.3)
    h.assert_no_frames()


# --- zero-page fragments (amended REQ-BOL-004) -------------------------------


@pytest.mark.parametrize("idx,head", [(0, 67), (1, 56)])
def test_zero_page_fragment_is_malformed(h, idx, head):
    # Amended REQ-BOL-004: "a type-1 datagram that parses as a fragment but
    # yields a zero-length page (i.e. shorter than its head length) is also
    # malformed" — a frag0 truncated to exactly its 67 B head, resp. a mid to
    # its 56 B head; both are >= 50 B, so the fields parse.
    bad = fragment(60, idx, 3, 2100, b"")  # page length 0 -> datagram == head
    assert len(bad) == head
    h.send(bad)
    h.col.wait_for(
        f"malformed for zero-page idx={idx}",
        lambda e: e.kind == "malformed",
    )
    h.col.settle()
    # exactly one malformed event; the fragment was dropped, not parsed
    assert len(h.col.by_kind("malformed")) == 1
    assert h.col.by_kind("video_fragment") == []
    assert h.col.by_kind("frame_complete") == []
    h.col.settle(0.3)
    h.assert_no_frames()
    # transport keeps running afterwards: a valid frag0 still parses
    probe = fragment(91, 0, 3, 2100, mkpage(8, 1024))
    h.send(probe)
    h.col.wait_for(
        "video_fragment after the zero-page violation",
        lambda e: e.kind == "video_fragment" and e.fields.get("frame_id") == 91,
    )
    h.col.settle(0.3)
    h.assert_no_frames()


# --- short type-1 datagrams (amended REQ-BOL-004 field-access rule) ----------


@pytest.mark.parametrize("n", [8, 49])
def test_type1_datagram_shorter_than_50_bytes_is_malformed_no_crash(h, n):
    # Amended REQ-BOL-004: "field access needs >= 50 B" — a type-1 datagram
    # with a valid [0x93][01][len16==len] head but shorter than 50 B has no
    # parseable fragment fields: it is dropped with a `malformed` event, must
    # not crash, and the transport keeps processing others.
    d = bytearray(n)
    d[0] = 0x93
    d[1] = 1
    struct.pack_into("<H", d, 2, n)
    d[4:8] = b"\x02\x02\x00\x01"  # only fully present for n >= 8
    h.send(bytes(d))
    h.col.wait_for(
        f"malformed for {n} B type-1 datagram",
        lambda e: e.kind == "malformed",
    )
    h.col.settle()
    assert len(h.col.by_kind("malformed")) == 1  # exactly one event, no crash
    assert h.col.by_kind("video_fragment") == []
    assert h.col.by_kind("frame_complete") == []
    h.col.settle(0.3)
    h.assert_no_frames()
    # the worker is still alive and processing: a valid frag0 parses
    probe = fragment(92, 0, 3, 2100, mkpage(9, 1024))
    h.send(probe)
    h.col.wait_for(
        "video_fragment after the short type-1 datagram",
        lambda e: e.kind == "video_fragment" and e.fields.get("frame_id") == 92,
    )
    h.col.settle(0.3)
    h.assert_no_frames()


# --- REQ-BOL-001 source filtering ------------------------------------------


def test_datagram_from_wrong_source_ip_is_ignored(h):
    # REQ-BOL-001: srcaddr.ip != host -> drop silently.
    try:
        sender = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sender.bind(("127.0.0.2", DEVICE_SRC_PORT))
    except OSError:
        sender = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sender.bind(("127.0.0.2", 0))
    try:
        sender.sendto(fragment(77, 0, 3, 2100, mkpage(1, 1024)), ("127.0.0.1", h.local_port))
    finally:
        sender.close()
    h.col.settle(0.5)
    datagram_kinds = {"video_fragment", "frame_complete", "heartbeat", "malformed",
                      "unknown_type", "frame_dropped", "decode_error"}
    assert [e for e in h.col.events if e.kind in datagram_kinds] == []
    h.assert_no_frames()


def test_datagram_from_wrong_source_port_is_ignored(h):
    # REQ-BOL-001: source port != 1234 (even from the right IP) is ignored.
    h.send(fragment(78, 0, 3, 2100, mkpage(1, 1024)), port=free_udp_port())
    h.col.settle(0.5)
    datagram_kinds = {"video_fragment", "frame_complete", "heartbeat", "malformed",
                      "unknown_type", "frame_dropped", "decode_error"}
    assert [e for e in h.col.events if e.kind in datagram_kinds] == []
    h.assert_no_frames()


# --- REQ-BOL-002 ping observable (readiness gate doubles as coverage) -------

def test_ping_events_carry_the_ping_payload(h):
    ev = h.col.wait_for("ping event", lambda e: e.kind == "ping", timeout=5.0)
    assert ev.fields == {"bytes": "EF000400"}
    h.col.settle()
    # periodic sends: many ping events within a second of running
    assert len(h.col.by_kind("ping")) >= 3


def test_stop_is_idempotent_and_halts_telemetry(h):
    # REQ-BOL-007 / REQ-ARCH-004: stop() terminates cleanly and is idempotent.
    h.transport.stop()
    h.transport.stop()
    snap1 = h.store.snapshot()
    h.col.settle(0.4)
    assert h.store.snapshot() == snap1  # no counters/events move after stop
    h.assert_no_frames()
