"""Tests for otoscope_proto.telemetry — REQ-TEL-001..004 (only; REQ-TEL-005 is a
UI-layer design constraint tested by the UI tester).

Sources: docs/ARCHITECTURE.md §4b (REQ-TEL-*), §6 (fixed signatures), and
REQ-ARCH-005 (bounded frame queue, drop-oldest + frame_dropped event).

Spec-derived assumptions (see docs/coordination.md for OPEN entries):
- Counter deltas are probed via the public API fixed in §6 (add_event / push_frame);
  add_event is the only EVENT entry point the spec defines, so event-derived
  counters must be reachable through it; decode_ok goes through mark_decode.
"""

import json
import threading

import pytest

from otoscope_proto.telemetry import TelemetryEvent, TelemetryStore

# REQ-TEL-001: the complete enumerated kind list (transports may add kinds,
# but these must all be constructible).
ENUMERATED_KINDS = (
    "video_fragment",
    "frame_complete",
    "heartbeat",
    "ping",
    "malformed",
    "unknown_type",
    "decode_error",
    "stats_sample",
    "frame_dropped",
)

# REQ-ARCH-005: bounded frame queue owned by the store/transport layer.
QUEUE_MAXSIZE = 64

_PARSED_TYPES = (int, float, str, bool, type(None))


def make_event(ts, kind, datagram_len=0, fields=None, transport="test"):
    """Build a TelemetryEvent per REQ-TEL-001 field set (§6 signature)."""
    return TelemetryEvent(
        ts=ts,
        transport=transport,
        kind=kind,
        addr="127.0.0.1:1234",
        datagram_len=datagram_len,
        fields=fields or {},
    )


# ---------------------------------------------------------------------------
# REQ-TEL-001 — TelemetryEvent schema
# ---------------------------------------------------------------------------


def test_event_defaults_raw_hex_empty():
    ev = TelemetryEvent(
        ts=1.0,
        transport="test",
        kind="ping",
        addr="127.0.0.1:1234",
        datagram_len=0,
        fields={},
    )
    assert ev.raw_hex == ""  # REQ-TEL-001: raw_hex default ""


def test_event_frozen_raises_on_attribute_set():
    ev = make_event(0.0, "ping", 4, {"bytes": "ef000400"})
    # FrozenInstanceError subclasses AttributeError.
    with pytest.raises(AttributeError):
        ev.ts = 99.0


def test_all_enumerated_kinds_constructible():
    # REQ-TEL-001: the nine listed kinds must all be constructible with the
    # fixed field set (ts, transport, kind, addr, datagram_len, fields[, raw_hex]).
    for kind in ENUMERATED_KINDS:
        ev = make_event(0.5, kind, datagram_len=(4 if kind == "ping" else 0))
        assert ev.kind == kind


def test_synthesized_event_datagram_len_zero_allowed():
    # REQ-TEL-001: datagram_len is 0 for synthesized logic events like frame_complete.
    ev = make_event(1.5, "frame_complete", 0, {"frame_id": 1})
    assert ev.datagram_len == 0


# ---------------------------------------------------------------------------
# REQ-TEL-002 — TelemetryStore: thread safety, get_since, ring, frame queue
# ---------------------------------------------------------------------------


def test_store_empty_initial_state():
    store = TelemetryStore("test")
    evs, next_idx = store.get_since(0)
    assert list(evs) == []
    # next_idx must be sane for a fresh store: calling again with it returns nothing.
    evs2, next2 = store.get_since(next_idx)
    assert list(evs2) == []


def test_get_since_returns_newer_events_and_monotonic_idx():
    store = TelemetryStore("test")
    for i in range(10):
        store.add_event(make_event(float(i), "stats_sample", 0, {"seq": i}))
    evs, next_idx = store.get_since(0)
    assert len(evs) == 10
    assert evs[0].fields["seq"] == 0
    assert evs[-1].fields["seq"] == 9
    # "newer than idx": passing the returned next_idx yields nothing new.
    evs2, next2 = store.get_since(next_idx)
    assert list(evs2) == []
    # next_idx is monotonic under repeated reads.
    evs3, next3 = store.get_since(0)
    assert next3 == next_idx


def test_thread_safety_counters_and_event_walk():
    # REQ-TEL-002: add_event from many threads; final counters consistent with
    # N*M adds; get_since walk yields every event exactly once; next_idx monotonic.
    n_threads, per_thread = 8, 100
    store = TelemetryStore("test")

    def worker(tid):
        for j in range(per_thread):
            # fields carry int values per the REQ-TEL-001 fields constraint
            # (int|str|float), and act as unique keys for exactly-once checking.
            ev = make_event(float(j), "stats_sample", 0, {"tid": tid, "seq": j})
            store.add_event(ev)

    threads = [threading.Thread(target=worker, args=(t,)) for t in range(n_threads)]
    for t in threads:
        t.start()
    for t in threads:
        t.join(timeout=10)
    assert not any(t.is_alive() for t in threads)

    seen = []
    idx = 0
    last_idx = -1
    while True:
        evs, nxt = store.get_since(idx)
        assert nxt >= idx and nxt >= last_idx, "next_idx must be monotonic"
        last_idx = nxt
        if not evs:
            break
        seen.extend(evs)
        idx = nxt

    assert len(seen) == n_threads * per_thread
    keys = [(e.fields["tid"], e.fields["seq"]) for e in seen]
    assert len(set(keys)) == n_threads * per_thread, "every event exactly once"
    # Counter consistency: datagrams_rx is not incremented here because these are
    # synthesized events (datagram_len=0); the by_kind total must match N*M.
    snap = store.snapshot()
    assert snap["by_kind"]["stats_sample"] == n_threads * per_thread


def test_ring_capacity_5000_oldest_evicted():
    # REQ-TEL-002: ring capacity 5000; inserting more evicts the oldest, so
    # get_since(0) yields exactly the last 5000 events.
    total = 5500
    store = TelemetryStore("test")
    for i in range(total):
        store.add_event(make_event(float(i), "stats_sample", 0, {"seq": i}))
    evs, _next = store.get_since(0)
    assert len(evs) == 5000
    assert evs[0].fields["seq"] == 500, "oldest 500 must be evicted"
    assert evs[-1].fields["seq"] == total - 1


def test_push_frame_and_pop_frame_queue_semantics():
    # §6: push_frame(jpeg_bytes, ts) / pop_frame() -> () when empty.
    store = TelemetryStore("test")
    assert store.pop_frame() == ()

    frames = [(f"frame-{i}".encode(), float(i)) for i in range(5)]
    for data, ts in frames:
        store.push_frame(data, ts)
    # FIFO order: bytes *and* ts come back in the order they were pushed.
    for expected_data, expected_ts in frames:
        data, ts = store.pop_frame()
        assert data == expected_data
        assert ts == expected_ts
    assert store.pop_frame() == ()


def test_frame_queue_drop_oldest_emits_frame_dropped():
    # REQ-ARCH-005: maxsize=64; when full the OLDEST frame is dropped and a
    # frame_dropped event is emitted (verified via get_since).
    store = TelemetryStore("test")
    total = QUEUE_MAXSIZE + 6  # 70 pushes -> 6 oldest dropped
    for i in range(total):
        store.push_frame(f"frame-{i}".encode(), float(i))

    # Drop-oldest keeps the NEWEST QUEUE_MAXSIZE frames in FIFO order: after
    # 70 pushes the queue holds frames 6..69, so the head is frame-6
    # (total - QUEUE_MAXSIZE == index 6), not frame-64.
    popped = []
    while True:
        frame = store.pop_frame()
        if frame == ():
            break
        popped.append(frame)
    assert len(popped) == QUEUE_MAXSIZE
    assert popped[0][0] == f"frame-{total - QUEUE_MAXSIZE}".encode(), (
        "drop-oldest must keep the newest 64; head is the 7th pushed item"
    )
    assert popped[-1][0] == f"frame-{total - 1}".encode()

    # One frame_dropped event per dropped frame.
    evs, _next = store.get_since(0)
    drops = [e for e in evs if e.kind == "frame_dropped"]
    assert len(drops) == total - QUEUE_MAXSIZE
    for e in drops:
        assert isinstance(e.ts, float)


# ---------------------------------------------------------------------------
# REQ-TEL-003 — snapshot() is plain data and JSON-serializable
# ---------------------------------------------------------------------------


def test_snapshot_is_plain_json_serializable():
    store = TelemetryStore("test")
    store.add_event(make_event(0.0, "ping", 4, {"bytes": "ef000400"}))
    store.add_event(make_event(1.0, "malformed", 20))
    store.push_frame(b"\xff\xd8jpeg", 2.0)

    snap = store.snapshot()
    assert isinstance(snap, dict)

    def check_plain(v):
        if isinstance(v, dict):
            for k, sub in v.items():
                assert isinstance(k, str)
                check_plain(sub)
        elif isinstance(v, (list, tuple)):
            assert not isinstance(v, tuple), "snapshot must contain lists, not tuples"
            for sub in v:
                check_plain(sub)
        elif isinstance(v, _PARSED_TYPES):
            assert not isinstance(v, bytes), "snapshot must not contain bytes"
        else:
            pytest.fail(f"snapshot contains non-plain value {v!r}")

    check_plain(snap)
    # REQ-TEL-003: used by --out and the Stats panel, so json.dumps must work.
    assert json.loads(json.dumps(snap)) == snap


# ---------------------------------------------------------------------------
# REQ-TEL-004 — cumulative counters (mapping pinned by the amended spec)
# ---------------------------------------------------------------------------
# Amended REQ-TEL-004 (docs/ARCHITECTURE.md §4b) fixes the kind -> counter
# mapping: increments happen on add_event — kind "frame_complete" ->
# frames_complete, kind "ping" -> pings_tx, kind "decode_error" ->
# decode_failed; any event with datagram_len > 0 bumps datagrams_rx and
# bytes_rx += datagram_len (a transport observes its own sent ping bytes
# the same way). decode_ok is incremented ONLY via TelemetryStore.mark_decode
# (§6: mark_decode(ok: bool) -> None); mark_decode never touches decode_failed.


def test_counter_pings_tx_increments_on_ping_event():
    # REQ-TEL-004: pings_tx — the orchestrator brief confirms the kind->counter
    # mapping ("add_event with kind='ping' increments pings_tx").
    store = TelemetryStore("test")
    base = store.snapshot()
    for i in range(3):
        store.add_event(make_event(float(i), "ping", 4, {"bytes": "ef000400"}))
    assert store.snapshot()["pings_tx"] == base["pings_tx"] + 3


def test_counter_by_kind_increments_per_event():
    # REQ-TEL-004: by_kind is a per-kind tally of events added to the store.
    store = TelemetryStore("test")
    store.add_event(make_event(0.0, "ping", 4))
    store.add_event(make_event(1.0, "ping", 4))
    store.add_event(make_event(2.0, "malformed", 20))
    store.add_event(make_event(3.0, "heartbeat", 16))
    snap = store.snapshot()
    by_kind = snap["by_kind"]
    assert by_kind["ping"] == 2
    assert by_kind["malformed"] == 1
    assert by_kind["heartbeat"] == 1
    assert "video_fragment" not in by_kind  # never added -> absent, not zero


def test_counter_datagrams_rx_and_bytes_rx_per_wire_event():
    # REQ-TEL-004: datagrams_rx counts received datagrams and bytes_rx the wire
    # bytes, both accumulated from wire observations via add_event (the only
    # event entry point in the §6 API). The mapping applies to EVERY event kind
    # with datagram_len > 0 — including "ping" events the transport emits for
    # its own sent bytes (synthesized events have datagram_len 0 by
    # REQ-TEL-001 and contribute nothing).
    store = TelemetryStore("test")
    store.add_event(make_event(0.0, "video_fragment", 1091))
    store.add_event(make_event(1.0, "heartbeat", 16))
    store.add_event(make_event(2.0, "malformed", 20))
    store.add_event(make_event(3.0, "ping", 4, {"bytes": "ef000400"}))
    snap = store.snapshot()
    assert snap["datagrams_rx"] == 4
    assert snap["bytes_rx"] == 1091 + 16 + 20 + 4


def test_counter_pings_tx_not_incremented_by_other_kinds():
    # Corollary of the ping mapping in REQ-TEL-004: other kinds must not bump pings_tx.
    store = TelemetryStore("test")
    store.add_event(make_event(0.0, "heartbeat", 16))
    store.add_event(make_event(1.0, "video_fragment", 1091))
    assert store.snapshot()["pings_tx"] == 0


def test_counter_frames_complete_increments_on_frame_complete_events():
    # REQ-TEL-004 (amended): kind "frame_complete" via add_event -> frames_complete.
    store = TelemetryStore("test")
    base = store.snapshot()["frames_complete"]
    for i in range(3):
        store.add_event(make_event(float(i), "frame_complete", 0, {"frame_id": i}))
    assert store.snapshot()["frames_complete"] == base + 3


def test_counter_decode_failed_increments_on_decode_error_events():
    # REQ-TEL-004 (amended): kind "decode_error" via add_event -> decode_failed.
    store = TelemetryStore("test")
    base = store.snapshot()["decode_failed"]
    for i in range(2):
        store.add_event(make_event(float(i), "decode_error", 0, {"frame_id": i}))
    assert store.snapshot()["decode_failed"] == base + 2


def test_mark_decode_true_increments_decode_ok_only():
    # REQ-TEL-004 (amended) / §6: decode_ok is incremented ONLY via
    # TelemetryStore.mark_decode(ok: bool); the call touches decode_ok and
    # nothing else. decode_failed comes from decode_error events exclusively.
    store = TelemetryStore("test")
    store.add_event(make_event(0.0, "decode_error", 0))
    base = store.snapshot()
    store.mark_decode(True)
    snap = store.snapshot()
    assert snap["decode_ok"] == base["decode_ok"] + 1
    # Every other counter is untouched by mark_decode:
    assert snap["decode_failed"] == base["decode_failed"]
    assert snap["frames_complete"] == base["frames_complete"]
    assert snap["pings_tx"] == base["pings_tx"]
    assert snap["datagrams_rx"] == base["datagrams_rx"]
    assert snap["bytes_rx"] == base["bytes_rx"]
    assert snap["by_kind"] == base["by_kind"]


def test_mark_decode_does_not_touch_decode_failed():
    # REQ-TEL-004 (amended): decode_failed is fed exclusively by decode_error
    # events — neither mark_decode(True) nor mark_decode(False) may move it.
    store = TelemetryStore("test")
    store.add_event(make_event(0.0, "decode_error", 0))
    base_fail = store.snapshot()["decode_failed"]

    store.mark_decode(True)
    assert store.snapshot()["decode_failed"] == base_fail

    store.mark_decode(False)
    assert store.snapshot()["decode_failed"] == base_fail
