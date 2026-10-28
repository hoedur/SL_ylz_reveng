"""Multi-fragment reassembly tests for the BoliU/BL384 transport (REQ-BOL-005).

Frames are hand-crafted from the REQ-BOL-004 byte layout (see
``test_boliu_datagrams.py`` for the field map); REQ-BOL-005 adds:

- reassembly keyed by ``(frame_id, size)``; frame ids 1 and 2 coexist,
- completeness = first ``cnt`` indices collected,
- pending keys > 16 -> oldest pruned with a ``frame_dropped`` event
  (``fields={"pruned": True}``),
- on completion: one ``frame_complete`` event (fields frame_id, size, cnt, w, h, q)
  and one frame pushed to the queue = ``header_for(q byte) + concat(pages IN INDEX
  ORDER) + FF D9`` (length 605 + size + 2).

Frames use the spec's fake-device size 2100 -> cnt = 3 -> pages 1024/1024/52
(spec §5); page payloads are deterministic tags, deliberately NOT JPEG-decodable.

Amendment 2026-10-24 (REQ-BOL-005/006): the reconstruction header is picked per
frame from the announced quality byte (low byte of ``q``). The datagrams below
use ``q = 0x4D (77)`` — a quality the head table does not know — so the sticky
rule applies and the reconstruction uses the **initial fallback head**,
``data/jhdr_Q100.bin`` (605 B). Dedicated tests below pin the per-quality
selection itself.
"""

import socket
import struct
import time
from pathlib import Path

import pytest

from otoscope_proto.device.boliu import BoliUTransport
from otoscope_proto.jpeg_frames import jpeg_size, patch_sof0_dims
from otoscope_proto.telemetry import TelemetryStore

JHDR_PATH = Path(__file__).resolve().parents[1] / "src" / "otoscope_proto" / "data" / "jhdr_Q100.bin"
JHDR = JHDR_PATH.read_bytes()  # amended REQ-BOL-005/006: the initial fallback head (605 B)

SIZE = 2100  # spec §5 pressure-test size
CNT = 3
PAGES = [1024, 1024, SIZE - (CNT - 1) * 1024]  # 1024 / 1024 / 52
W, H, Q = 640, 444, 77
DEVICE_SRC_IP, DEVICE_SRC_PORT = "127.0.0.1", 1234

# amended REQ-BOL-004 (gate-1): frag0's trailing ASCII metadata on the wire
# (example bytes observed at d[len-11:len]; stashed natively, not page data)
FRAG0_TAIL = b"-0214,-0894"


def mkpage(tag: int, length: int) -> bytes:
    return bytes((tag * 31 + 7 * i) % 251 for i in range(length))


def fragment(frame_id, idx, cnt, size, page, *, w=W, h=H, q=Q, dup=0):
    head = 56
    # amended REQ-BOL-004 (gate-1): every header is 56 B; frag0 appends 11
    # trailing ASCII metadata bytes which are NOT page data.
    tail = FRAG0_TAIL if idx == 0 else b""
    d = bytearray(head + len(page) + len(tail))
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
    d[head : head + len(page)] = page
    if tail:
        d[len(d) - len(tail) :] = tail
    return bytes(d)


def frame_datagrams(frame_id, payload_tag, cnt=CNT, size=SIZE):
    """All fragments of one frame, index order, with their page payloads."""
    pages = [mkpage(payload_tag, ln) for ln in PAGES[:cnt]]
    dgrams = [fragment(frame_id, i, cnt, size, pg) for i, pg in enumerate(pages)]
    return dgrams, pages


def reconstructed(pages):
    # Amended REQ-BOL-005/006: initial-fallback head (unknown q=77 stays Q100,
    # 605 B) + pages in index order + FF D9.
    # REQ-BOL-010: the head bytes shipped to the queue carry the SOF0 dims patch
    # from the datagram's announced (W, H) — native parity, see test_sof0_dims.
    return patch_sof0_dims(JHDR, W, H) + b"".join(pages) + b"\xff\xd9"


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
                pytest.fail(f"timeout after {timeout:.1f}s waiting for {desc}")
            time.sleep(0.02)

    def wait_for_count(self, kind, n, timeout=5.0):
        deadline = time.monotonic() + timeout
        while len(self.by_kind(kind)) < n:
            self.pump()
            if time.monotonic() >= deadline:
                pytest.fail(f"timeout after {timeout:.1f}s waiting for {n}x {kind}")
            time.sleep(0.02)
        self.pump()

    def settle(self, seconds=0.3):
        time.sleep(seconds)
        self.pump()

    def by_kind(self, kind):
        return [e for e in self.events if e.kind == kind]


class LoopbackHarness:
    def __init__(self) -> None:
        self.ping_sink = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.ping_sink.bind(("127.0.0.1", 0))
        self.ping_port = self.ping_sink.getsockname()[1]
        probe = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            probe.bind(("127.0.0.1", 0))
            self.local_port = probe.getsockname()[1]
        finally:
            probe.close()
        self.store = TelemetryStore("boliu")
        self.transport = BoliUTransport(
            "127.0.0.1", self.ping_port, self.store, local_port=self.local_port
        )
        self.col = Collector(self.store)
        self.sender = None
        self.transport.start()
        self.col.wait_for("first ping event", lambda e: e.kind == "ping", timeout=5.0)
        time.sleep(0.05)

    def send(self, payload):
        if self.sender is None:
            self.sender = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            self.sender.bind((DEVICE_SRC_IP, DEVICE_SRC_PORT))
        self.sender.sendto(payload, ("127.0.0.1", self.local_port))

    def pop_frames(self):
        frames = []
        while True:
            f = self.store.pop_frame()  # () = none (REQ-TEL-002)
            if not f:
                return frames
            frames.append(f)

    def settle(self, seconds=0.3):
        # Bounded wait (fixed ceiling, < 1 s) for late worker processing,
        # then one drain of the event log — mirrors the datagrams-file helper.
        time.sleep(seconds)
        self.col.pump()

    def assert_no_frames(self):
        # The frame queue (not the event log) is the reassembly side effect;
        # pop_frames() drains it fully and must find it empty.
        assert self.pop_frames() == []

    def wait_frames(self, count, timeout=5.0):
        deadline = time.monotonic() + timeout
        frames = self.pop_frames()
        while len(frames) < count:
            self.col.pump()  # keep the collector warm, not required for the queue
            if time.monotonic() >= deadline:
                pytest.fail(f"timeout waiting for {count} frame(s); got {len(frames)}")
            time.sleep(0.02)
            frames += self.pop_frames()
        return frames

    def close(self):
        self.transport.stop()
        self.transport.stop()  # REQ-ARCH-004 idempotency
        if self.sender is not None:
            self.sender.close()
        self.ping_sink.close()


def assert_complete_fields(ev, frame_id):
    # REQ-BOL-005: fields = {"frame_id","size","cnt","w","h","q"} (six fields;
    # datagram_len == 0 per REQ-TEL-001, it is a synthesized logic event).
    assert ev.fields["frame_id"] == frame_id
    assert ev.fields["size"] == SIZE
    assert ev.fields["cnt"] == CNT
    assert ev.fields["w"] == W
    assert ev.fields["h"] == H
    assert ev.fields["q"] == Q
    assert ev.datagram_len == 0
    assert ev.ts >= 0


@pytest.fixture
def h():
    if len(JHDR) != 605:
        pytest.fail("test vector data/jhdr_Q100.bin is not 605 B (amended REQ-BOL-006)")
    harness = LoopbackHarness()
    try:
        yield harness
    finally:
        harness.close()


def test_complete_in_order_frame_produces_event_and_queue_frame(h):
    dgrams, pages = frame_datagrams(frame_id=10, payload_tag=1)
    for d in dgrams:
        h.send(d)
    h.col.wait_for(
        "frame_complete for frame_id=10",
        lambda e: e.kind == "frame_complete" and e.fields.get("frame_id") == 10,
    )
    h.col.settle()
    completions = h.col.by_kind("frame_complete")
    assert len(completions) == 1
    assert_complete_fields(completions[0], 10)
    # the three fragments were each parsed as video_fragment events
    assert len(h.col.by_kind("video_fragment")) == 3

    frames = h.wait_frames(1)
    jpeg, ts = frames[0]
    assert isinstance(ts, float) and ts >= 0
    expected = reconstructed(pages)
    assert jpeg == expected
    # Amended REQ-BOL-005: length == 605 (head) + 2 (EOI) + size = 2707; framing exact
    assert len(jpeg) == jpeg_size(SIZE) == 605 + SIZE + 2 == 2707
    assert jpeg[:605] == patch_sof0_dims(JHDR, W, H)  # REQ-BOL-010 dims patch
    assert jpeg[-2:] == b"\xff\xd9"
    h.settle(0.3)
    assert h.pop_frames() == []  # exactly one frame in the queue


def test_out_of_order_delivery_reassembles_in_index_order(h):
    dgrams, pages = frame_datagrams(frame_id=11, payload_tag=2)
    h.send(dgrams[2])  # last page first
    h.send(dgrams[1])  # then mid
    h.send(dgrams[0])  # frag0 completes the key
    h.col.wait_for(
        "frame_complete for out-of-order frame_id=11",
        lambda e: e.kind == "frame_complete" and e.fields.get("frame_id") == 11,
    )
    frames = h.wait_frames(1)
    jpeg, _ts = frames[0]
    # Distinguishable page payloads prove concatenation by INDEX, not arrival:
    assert jpeg == reconstructed(pages)  # REQ-BOL-010: dims-patched fallback head
    assert len(jpeg) == jpeg_size(SIZE)


def test_interleaved_frames_1_and_2_complete_without_cross_contamination(h):
    d1, p1 = frame_datagrams(frame_id=1, payload_tag=5)
    d2, p2 = frame_datagrams(frame_id=2, payload_tag=9)
    for i in range(CNT):  # strictly alternating halves
        h.send(d1[i])
        h.send(d2[i])
    h.col.wait_for_count("frame_complete", 2, timeout=5.0)
    h.col.settle()
    completions = h.col.by_kind("frame_complete")
    assert {e.fields["frame_id"] for e in completions} == {1, 2}
    for ev in completions:
        assert_complete_fields(ev, ev.fields["frame_id"])

    frames = h.wait_frames(2)
    assert {f[0] for f in frames} == {reconstructed(p1), reconstructed(p2)}
    assert len(frames[0][0]) == jpeg_size(SIZE) and len(frames[1][0]) == jpeg_size(SIZE)
    h.settle(0.3)
    assert h.pop_frames() == []


def test_more_than_16_pending_keys_prunes_oldest_first(h):
    # 18 frag0-only datagrams -> 18 pending keys; exceeding 16 prunes the two
    # oldest keys (frame_ids 1 and 2) with frame_dropped {"pruned": True}.
    for fid in range(1, 19):
        h.send(fragment(fid, 0, CNT, SIZE, mkpage(fid, 1024)))
    deadline = time.monotonic() + 5.0
    while len(h.col.by_kind("frame_dropped")) < 2:
        h.col.pump()
        if time.monotonic() >= deadline:
            pytest.fail("timeout waiting for 2 frame_dropped prune events")
        time.sleep(0.02)
    h.col.pump()
    for ev in h.col.by_kind("frame_dropped"):
        assert ev.fields.get("pruned") is True
    h.col.settle(0.3)
    assert len(h.col.by_kind("frame_dropped")) == 2  # exactly the two oldest keys

    # Completing every surviving key (3..18) proves pruning removed the OLDEST:
    fid_pages = {}
    for fid in range(3, 19):
        pg = [mkpage(fid, 1024), mkpage(fid + 100, 1024), mkpage(fid + 200, 52)]
        fid_pages[fid] = pg
        h.send(fragment(fid, 1, CNT, SIZE, pg[1]))
        h.send(fragment(fid, 2, CNT, SIZE, pg[2]))
    deadline = time.monotonic() + 5.0
    while len(h.col.by_kind("frame_complete")) < 16:
        h.col.pump()
        if time.monotonic() >= deadline:
            pytest.fail("timeout waiting for 16 completions after pruning")
        time.sleep(0.02)
    h.col.pump()
    completions = h.col.by_kind("frame_complete")
    assert {e.fields["frame_id"] for e in completions} == set(range(3, 19))
    frames = h.wait_frames(16)
    got = {f[0] for f in frames}
    want = {reconstructed(fid_pages[fid]) for fid in range(3, 19)}
    assert got == want
    h.settle(0.3)
    assert h.pop_frames() == []


def test_transport_keeps_running_after_malformed_input(h):
    # REQ-BOL-003/004: malformed datagrams are dropped + reported, and the
    # transport "keeps processing others".
    h.send(struct.pack("<4sIII", b"\x93\x04\x10\x00", 1, 2, 3) + b"\x00")  # 17 B heartbeat
    h.send(bytes([0x93, 0x07]) + b"\x08\x00\x00\x00")  # unknown type byte 7
    h.send(fragment(4711, 1, CNT, SIZE, mkpage(3, 512)))  # mid page shorter than 1024
    deadline = time.monotonic() + 5.0
    while len(h.col.by_kind("malformed")) < 2 or len(h.col.by_kind("unknown_type")) < 1:
        h.col.pump()
        if time.monotonic() >= deadline:
            pytest.fail(
                f"timeout waiting for malformed feedback; "
                f"malformed={len(h.col.by_kind('malformed'))} "
                f"unknown_type={len(h.col.by_kind('unknown_type'))}"
            )
        time.sleep(0.02)
    h.col.settle(0.3)
    assert len(h.col.by_kind("malformed")) == 2
    ut = h.col.by_kind("unknown_type")
    assert len(ut) == 1 and ut[0].fields["type"] == 7
    assert h.col.by_kind("frame_complete") == []
    h.assert_no_frames()

    # ...and a complete valid frame sent afterwards still finishes.
    dgrams, pages = frame_datagrams(frame_id=21, payload_tag=4)
    for d in dgrams:
        h.send(d)
    h.col.wait_for(
        "frame_complete after malformed burst",
        lambda e: e.kind == "frame_complete" and e.fields.get("frame_id") == 21,
    )
    frames = h.wait_frames(1)
    assert frames[0][0] == reconstructed(pages)
    assert len(frames[0][0]) == jpeg_size(SIZE)


# ------------------------------------------------------------------ amended REQ-BOL-005/006


def _set_u16_field(dgram: bytes, offset: int, value: int) -> bytes:
    d = bytearray(dgram)
    struct.pack_into("<H", d, offset, value)
    return bytes(d)


def _head(q: int) -> bytes:
    p = Path(__file__).resolve().parents[1] / "src" / "otoscope_proto" / "data" / f"jhdr_Q{q}.bin"
    return p.read_bytes()


def test_announced_quality_byte_selects_matching_head(h):
    # Amended REQ-BOL-005/006: quality byte 75 (0x4B — the §5 fake's pinned value)
    # must reconstruct with the Q75 head, per native handle_mcu_msg_frag behavior.
    dgrams, pages = frame_datagrams(frame_id=30, payload_tag=6)
    dgrams = [_set_u16_field(d, 48, 0x014B) for d in dgrams]  # low byte = 75
    for d in dgrams:
        h.send(d)
    h.col.wait_for(
        "frame_complete with q=0x014B",
        lambda e: e.kind == "frame_complete" and e.fields.get("frame_id") == 30,
    )
    frames = h.wait_frames(1)
    jpeg, _ts = frames[0]
    assert jpeg[:605] == patch_sof0_dims(_head(75), W, H), "quality byte 75 must select the Q75 head (REQ-BOL-010 dims apply)"
    assert jpeg[605:-2] == b"".join(pages)
    assert jpeg[-2:] == b"\xff\xd9" and len(jpeg) == jpeg_size(SIZE)


def test_unknown_quality_keeps_previous_head_sticky(h):
    # Amended REQ-BOL-005/006: unknown quality level -> sticky previous head
    # (native path at libbl 0x2696/0x26e8: unmatched byte keeps the old head).
    d1, _ = frame_datagrams(frame_id=31, payload_tag=7)
    d1 = [_set_u16_field(d, 48, 50) for d in d1]  # valid: selects Q50
    for d in d1:
        h.send(d)
    h.col.wait_for("frame1 q50", lambda e: e.kind == "frame_complete" and e.fields.get("frame_id") == 31)
    h.wait_frames(1)

    d2, _ = frame_datagrams(frame_id=32, payload_tag=8)
    d2 = [_set_u16_field(d, 48, 129) for d in d2]  # unknown level (byte49 stays 0)
    for d in d2:
        h.send(d)
    h.col.wait_for("frame2 unknown-q", lambda e: e.kind == "frame_complete" and e.fields.get("frame_id") == 32)
    frames = h.wait_frames(1)  # the second (unknown-q) frame is the only queued one
    jpeg, _ts = frames[0]
    assert jpeg[:605] == patch_sof0_dims(_head(50), W, H), "unknown quality must keep the previously selected head (REQ-BOL-010 dims apply)"
