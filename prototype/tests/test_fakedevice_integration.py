"""End-to-end tests over loopback — BoliU/BL384 transport + TelemetryStore + §5 fake device.

Spec source: docs/ARCHITECTURE.md ONLY (REQ-TEST-001). Cites:
- REQ-ARCH-001/004/005 (transport ABC seam, network only after start(), bounded frame queue)
- REQ-BOL-002 (90 ms ping EF 00 04 00), REQ-BOL-003/004 (byte layout of §5 fake datagrams)
- REQ-BOL-005 (per-frame head selection, jpeg = header_for(q)|sticky + pages + FF D9), REQ-BOL-007 (stop ≤ 2 s, no events after)
- REQ-TEL-002/003/004 (store counters, snapshot, pings_tx)
- §5 (reference fake: ephemeral port, one frame per datagram, heartbeat 1.6 s ± 0.8 s, sticky)

NOTE (resolved, docs/coordination.md): REQ-BOL-001's source-port filter is now defined against
a `stream_port` constructor parameter (default 1234 for the real-device flow); §5 item 5 pins
`stream_port=fake.port` for the ephemeral fake — asserted by the e2e below. jpeg length follows
the spec formula jpeg_size(payload) = 605 + payload + 2 (2707 for the default size-2100 frame).
Amended (2026-10-24, REQ-BOL-005/006): the §5 fake pins q=0x4B (=75), so reconstruction uses
the packaged data/jhdr_Q75.bin head (605 B) — first 605 bytes of every fake-reconstructed JPEG.
"""
from __future__ import annotations

import socket
import struct
import time
from pathlib import Path

import pytest

from fake_device import PING_BYTES, FakeDevice, build_heartbeat, payload_bytes
from otoscope_proto.device.boliu import BoliUTransport
from otoscope_proto.telemetry import TelemetryStore

PROTOTYPE_DIR = Path(__file__).resolve().parents[1]
# §5 item 5: the fake announces q=0x4B (=75) -> REQ-BOL-006 selects the Q75 head.
JHDR_PATH = PROTOTYPE_DIR / "src" / "otoscope_proto" / "data" / "jhdr_Q75.bin"


def _read_packaged_header() -> bytes | None:
    """REQ-BOL-006 packaged Q75 head under src/; None while the file does not exist yet."""
    if JHDR_PATH.is_file():
        return JHDR_PATH.read_bytes()
    return None


def _jpeg_size(payload_len: int) -> int:
    """REQ-BOL-006 spec formula: jpeg = header_for(q) (605 B) + payload + FF D9 (2 B)."""
    return 605 + payload_len + 2


_FRAME_PAYLOAD = 2100  # §5 item 2 default frame size (cnt=3 -> 1024+1024+52)
_EXPECTED_JPEG_LEN = _jpeg_size(_FRAME_PAYLOAD)  # 2707 (pre-amendment: 2709 — counted the stray tail)


def _assert_is_full_fake_jpeg(frame: bytes) -> None:
    """REQ-BOL-005: jpeg_len == jpeg_size(2100) == 605+2100+2 == 2707 and correct payload/tail.

    The §5 payload bytes ([i % 251 ...]) and the FF D9 tail are asserted unconditionally;
    the first-605-bytes byte-identity (REQ-BOL-006, amended) fires automatically now that
    the packaged data/jhdr_Q75.bin exists (605 B; §5 pins q=0x4B).
    """
    assert len(frame) == _EXPECTED_JPEG_LEN, (
        f"REQ-BOL-005/REQ-BOL-006: jpeg_len must be jpeg_size(2100)=2707, got {len(frame)}"
    )
    assert frame[-2:] == b"\xff\xd9", "REQ-BOL-005: reconstructed JPEG must end with FF D9"
    assert frame[605:-2] == payload_bytes(2100), "REQ-§5: payload must be [i%251 for ...]"
    hdr = _read_packaged_header()
    if hdr is not None:
        assert len(hdr) == 605
        assert frame[:605] == hdr, (
            "REQ-BOL-006 (amended): first 605 bytes must equal data/jhdr_Q75.bin "
            "(the §5 fake announces q=0x4B)"
        )


def _recv_frame_fragments(sock: socket.socket, *, want: int = 3, timeout: float = 2.0) -> list[bytes]:
    """Receive loop for frame-fragment datagrams (`0x93`, type `01`) from the fake;
    datagrams shorter than one fragment (heartbeat = 16 B, REQ-BOL-003) are ignored."""
    deadline = time.monotonic() + timeout
    dgrams: list[bytes] = []
    while len(dgrams) < want and time.monotonic() < deadline:
        try:
            data, _addr = sock.recvfrom(2048)
        except socket.timeout:
            continue
        if len(data) >= 108 and data[:2] == b"\x93\x01":
            dgrams.append(data)
    return dgrams


# --------------------------------------------------------------------------- §5 fake only


def test_fake_device_reference_behavior() -> None:
    """Spec §5 conformance of the fake itself (no src/ involved): REQ-BOL-003/004 wire
    layout, §5 items 1-4 (one frame per datagram, id cycle, payload, heartbeat, sticky)."""
    fake = FakeDevice()
    fake.start()
    c = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    c.bind(("127.0.0.1", 0))
    c.settimeout(2.0)
    try:
        fake_addr = ("127.0.0.1", fake.port)

        # first contact -> immediately one complete frame streamed to the sender (§5 item 1)
        c.sendto(PING_BYTES, fake_addr)
        frags = _recv_frame_fragments(c, want=3, timeout=2.0)
        assert [len(f) for f in frags] == [1091, 1080, 108], (
            "§5/REQ-BOL-004: frag lengths must be 1091/1080/108 for size=2100"
        )
        for f in frags:
            # REQ-BOL-003 head: 0x93, type 1, len16 == datagram length
            assert f[0] == 0x93 and f[1] == 1 and struct.unpack("<H", f[2:4])[0] == len(f)
        fids = [struct.unpack("<I", f[8:12])[0] for f in frags]
        idxs = [struct.unpack("<I", f[32:36])[0] for f in frags]
        cnts = [struct.unpack("<I", f[36:40])[0] for f in frags]
        sizes = [struct.unpack("<I", f[40:44])[0] for f in frags]
        assert fids == [1, 1, 1], "§5 item 2: first frame_id must be 1"
        assert idxs == [0, 1, 2] and set(cnts) == {3} and set(sizes) == {2100}
        page0 = frags[0][56:1080]  # amended REQ-BOL-004: d[56:len-11]; 11-B tail excluded
        page1 = frags[1][56:]
        page2 = frags[2][56:]
        assert (len(page0), len(page1), len(page2)) == (1024, 1024, 52)
        assert page0 + page1 + page2 == payload_bytes(2100), "§5 item 2 payload mismatch"

        # second frame cycles frame_id -> 2 (§5 item 2)
        c.sendto(PING_BYTES, fake_addr)
        frags2 = _recv_frame_fragments(c, want=3, timeout=2.0)
        assert len(frags2) == 3
        fids2 = [struct.unpack("<I", f[8:12])[0] for f in frags2]
        assert fids2 == [2, 2, 2], "§5 item 2: frame_id must cycle 1,2,1,..."

        # counters: one ping datagram per contact (client only ever sent EF 00 04 00)
        assert fake.pings_rx >= 2 and fake.frames_sent >= 2
        assert all(p == PING_BYTES and len(p) == 4 for _, p in list(fake.received))

        # heartbeat: 1.6 s (+-0.8 s) after first datagram while activity < 5 s ago (§5 item 3)
        c.sendto(PING_BYTES, fake_addr)
        _recv_frame_fragments(c, want=3, timeout=2.0)
        time.sleep(3.8)
        assert len(fake.heartbeat_ts) >= 2, "§5 item 3: expected >=2 heartbeats within ~4 s"
        assert fake.heartbeat_seqs == list(range(len(fake.heartbeat_seqs))), (
            "heartbeat seq must be plausible (monotonic ints)"
        )
        gaps = [b - a for a, b in zip(fake.heartbeat_ts, fake.heartbeat_ts[1:])]
        assert all(0.8 <= g <= 2.4 for g in gaps), f"heartbeat cadence 1.6 s ± 0.8 s: {gaps}"

        # sticky/retarget (§5 item 4): a NEW sender becomes the stream target
        s2 = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s2.bind(("127.0.0.1", 0))
        s2.settimeout(2.0)
        try:
            s2.sendto(PING_BYTES, fake_addr)
            got = _recv_frame_fragments(s2, want=3, timeout=2.0)
            assert len(got) == 3, "§5 item 4: fake must stream the complete frame to the newest sender"
            frag0 = got[0]
            assert len(frag0) == 1091 and frag0[:2] == b"\x93\x01"
        finally:
            s2.close()
    finally:
        fake.stop()
        c.close()


# ------------------------------------------------------------------- transport integration


def test_boliu_transport_e2e_frames_and_heartbeat() -> None:
    """Integration over loopback (§6 signatures): REQ-ARCH-004 (network only after start),
    REQ-BOL-002 (pings), REQ-BOL-003/004 (fragment parse), REQ-BOL-005 (reassembly + JPEG),
    REQ-TEL-002/003/004 (store/counters), §5 fake + heartbeat, REQ-§5 item 4 sticky."""
    fake = FakeDevice()
    fake.start()
    store = TelemetryStore("boliu")

    # REQ-ARCH-004: nothing on the wire before start()
    time.sleep(0.3)
    assert fake.pings_rx == 0, "REQ-ARCH-004: transport must not touch the network before start()"

    t = BoliUTransport(host="127.0.0.1", port=fake.port, store=store, local_port=0,
                       stream_port=fake.port)  # amended REQ-BOL-001/§5 item 5
    t.start()
    t0 = time.monotonic()
    try:
        # >= 3 completed frames within 5 s (90 ms ping loop vs ping-serve fake)
        ok = False
        while time.monotonic() - t0 < 5.0:
            if store.snapshot()["frames_complete"] >= 3:
                ok = True
                break
            time.sleep(0.05)
        assert ok, (
            "REQ-BOL-002/005 + §5: no >=3 completed frames within 5 s — wire state at timeout: "
            f"fake.pings_rx={fake.pings_rx}, fake.frames_sent={fake.frames_sent}, "
            f"snapshot={store.snapshot()}. If pings reached the fake and frames were sent on "
            "the wire but no video_fragment event exists, see the REQ-BOL-001-vs-§5 OPEN "
            "entry in docs/coordination.md (ephemeral fake source port vs port-1234 rule)."
        )

        # keep running >= 3.2 s total so >= 1 heartbeat is guaranteed (1.6 s ± 0.8 s)
        while time.monotonic() - t0 < 3.2:
            time.sleep(0.05)

        snap = store.snapshot()
        assert snap["frames_complete"] >= 3, "REQ-TEL-004 frames_complete"
        assert snap["pings_tx"] >= 3, "REQ-TEL-004/REQ-BOL-002 pings_tx"
        assert snap["bytes_rx"] >= 3 * (1091 + 1080 + 108), "REQ-TEL-004 bytes_rx"
        # NB: no decode_ok/decode_failed assertions here — the §5 payload is deliberately
        # not JPEG-decodable (§5 item 2); decode assertions live in the UI tests (REQ-UI-009,
        # REQ-OPS-003) and in REQ-BOL-006 (real artifacts).

        # pop frames: REQ-ARCH-001/005 + §6 push_frame/pop_frame bounded queue
        frames = []
        for _ in range(200):
            popped = store.pop_frame()
            if popped == ():
                break
            frames.append(popped)
        assert len(frames) >= 3, "REQ-ARCH-001: frames() must deliver the completed frames"
        for jb, ts in frames:
            assert isinstance(ts, float) and ts > 0
            _assert_is_full_fake_jpeg(jb)  # REQ-BOL-005/006

        # telemetry events were normalized (REQ-TEL-001) with kinds per REQ-BOL-002..004
        events = store.get_since(0)[0]
        kinds = [e.kind for e in events]
        assert kinds.count("ping") >= 3, "REQ-BOL-002: one ping event per send"
        for e in events:
            if e.kind == "ping":
                assert e.fields == {"bytes": "EF000400"}, "REQ-BOL-002 ping fields"
        assert kinds.count("video_fragment") >= 9, "REQ-BOL-004: 3 frames x 3 fragments"
        assert kinds.count("frame_complete") >= 3, "REQ-BOL-005 frame_complete"
        assert kinds.count("malformed") == 0 and kinds.count("unknown_type") == 0, (
            "no malformed/unknown_type expected for well-formed §5 fake datagrams"
        )
        frame_completes = [e for e in events if e.kind == "frame_complete"]
        assert set(frame_completes[0].fields) >= {"frame_id", "size", "cnt", "w", "h", "q"}, (
            "REQ-BOL-005: frame_complete fields"
        )
        heartbeats = [e for e in events if e.kind == "heartbeat"]
        assert len(heartbeats) >= 1, "§5 item 3: heartbeat present within 3.2 s runtime"
        assert set(heartbeats[0].fields) >= {"seq", "pad", "drift"}, "REQ-BOL-003 heartbeat fields"
        assert isinstance(heartbeats[0].fields["seq"], int) and heartbeats[0].fields["seq"] >= 0

        # ---- sticky/retarget while streaming (§5 item 4): second client becomes target ----
        s2 = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s2.bind(("127.0.0.1", 0))
        s2.settimeout(2.0)
        try:
            s2.sendto(PING_BYTES, ("127.0.0.1", fake.port))
            frags = _recv_frame_fragments(s2, want=3, timeout=2.0)
            assert len(frags) == 3, "§5 item 4: fake must stream the complete frame to the newest sender"
            for f in frags:
                assert struct.unpack("<H", f[2:4])[0] == len(f)  # REQ-BOL-003 head intact
        finally:
            s2.close()
        # every datagram the fake ever received (transport pings + sticky datagram) was a ping
        assert fake.pings_rx >= 4
        assert all(p == PING_BYTES and len(p) == 4 for _, p in list(fake.received)), (
            "REQ-BOL-002: transport must send exactly EF 00 04 00 pings"
        )

        # ---- clean stop: REQ-BOL-007 (<= 2 s join, no events afterwards) ----
        t_stop = time.monotonic()
        t.stop()
        assert time.monotonic() - t_stop <= 2.0, "REQ-BOL-007: stop() must join within 2 s"
        events_after = len(store.get_since(0)[0])  # sampled after stop() fully returned
        time.sleep(0.6)  # anything arriving post-stop would only show up here
        assert len(store.get_since(0)[0]) == events_after, (
            "REQ-BOL-007: no further events after stop()"
        )
    finally:
        t.stop()
        fake.stop()
