# Coordination log (REQ-TEST-002)

Append questions/answers below. Format:
`- [OPEN] <tester>: question re REQ-xxx` / `- [ANSWERED] <implementer>: ...`

- [OPEN] test-protocol: REQ-BOL-004 says fragment parsing applies to "datagram ≥ 68 B", but the
  desired malformed-matrix includes the case *page length 0* — a frag0 with an empty page is a
  67-byte datagram (a mid with an empty page is 56 bytes), both below 68 B. Should such
  zero-page fragments be treated as `malformed`, or silently dropped under the ≥68 B reading?
  (The page-length-0 test is on hold until this is answered; the >1024 / short-mid / long-last /
  cnt=0 / idx>=cnt / size=0 cases are tested.)
- [ANSWERED] test-protocol: resolved by spec amendment of REQ-BOL-004: a type-1 datagram that
  parses as a fragment but yields a zero-length page (i.e. shorter than its head length —
  frag0 head 67 B, mid head 56 B) is also `malformed` (drop + event, no frame_complete). The
  same amendment pins the field-access rule at ≥ 50 B: shorter type-1 datagrams are dropped
  with a `malformed` event, no crash. Tests added: `test_zero_page_fragment_is_malformed`
  (frag0 + mid) and `test_type1_datagram_shorter_than_50_bytes_is_malformed_no_crash` (8 B /
  49 B) in tests/test_boliu_datagrams.py.
- [OPEN] test-protocol: is the tester's "never open src/" rule meant to include *reading*
  `src/otoscope_proto/data/jhdr_Q100.bin` for the REQ-BOL-006 byte-identity check against
  `analysis/artifacts/jhdr_Q100.bin` (data file, not code)? Currently untested for that reason.
- [ANSWERED] test-protocol: resolved by spec amendment of REQ-TEST-004: data files under
  `src/otoscope_proto/data/` are test vectors, not code — reading them for byte-identity
  checks is permitted (source-code files under src/ remain off-limits). Byte-identity test
  added: `test_packaged_data_header_is_byte_identical_to_artifact` (also asserts 607 B) in
  tests/test_jpeg_frames.py; the artifact-based assembly tests are unchanged.

- [RESOLVED] test-telemetry: REQ-TEL-004 counter-mapping under-specified (`frames_complete`/`decode_ok`/`decode_failed`) — skipped guessing, see its test comments. Closed 2026-10-24: mapping pinned by the spec amendment (next line); coverage added in tests/test_telemetry.py.
- [ANSWERED] orchestrator: resolved by spec amendment (REQ-TEL-004 + §6 `mark_decode(ok: bool)`): add_event(kind frame_complete)→frames_complete, (ping)→pings_tx, (decode_error)→decode_failed, datagram_len>0→datagrams_rx/bytes_rx; decode_ok ONLY via store.mark_decode(True) from the UI decoder. impl-core applies this delta in the fix-loop.

- [RESOLVED] test-telemetry: REQ-TEL-004 counter mapping is under-specified — which store call increments which counter is not stated for `frames_complete`, `decode_ok` and `decode_failed` (e.g. `frames_complete`: on the `frame_complete` event kind via `add_event`, or on `push_frame`?). Name-level mapping assumed for testable counters: `by_kind[k] += 1` per `add_event`; `datagrams_rx`/`bytes_rx` talleried from wire observations via `add_event` (tested with `datagram_len > 0` events only); `pings_tx` per `add_event(kind="ping")` (confirmed by the orchestrator brief). The three skipped counters are left unchecked in `tests/test_telemetry.py` (see note in REQ-TEL-004 section) until clarified here. Closed 2026-10-24: superseded by the amended REQ-TEL-004 in docs/ARCHITECTURE.md §4b; the skipped-counter note was removed from the test file and the three counters are now tested (see bottom [ANSWERED] test-telemetry).

- [OPEN] test-integration: REQ-BOL-001 vs §5 — REQ-BOL-001 says "Source port must be 1234;
  payloads from other device ports are ignored", but §5 mandates the reference fake device
  binds an *ephemeral* UDP socket. If the transport drops datagrams whose source port != 1234,
  the loopback integration test (`tests/test_fakedevice_integration.py`, ≥ 3 completed frames)
  can never pass. Please clarify: relax the source-port filter for the §5 fake (e.g. enforce it
  only against the real device flow), or let `FakeDevice` offer a configurable data port (e.g.
  reuse 1234 when free)? Tests currently assert the §5 ping-serve flow (frames DO complete).
- [OPEN] test-integration: REQ-BOL-004/§5 — no w/h/q values are fixed for the fake device's
  fragment header. `tests/fake_device.py` announces w=640, h=360, q=0x4B(75). No test asserts
  these values (REQ-BOL-005 only requires them to be carried into `frame_complete`); confirm if
  they should be pinned (e.g. the live unit profile w=640/h=480/q=75) in a spec revision.
- [OPEN] test-integration: REQ-BOL-005/REQ-BOL-006 — at integration-test authoring time
  `src/otoscope_proto/data/jhdr_Q100.bin` did not exist yet (concurrent implementation).
  `tests/test_fakedevice_integration.py` handles this dynamically: while the file is absent the
  integration asserts jpeg length 2611 + FF D9 tail + §5 payload bytes only; once the file
  exists the first-607-bytes byte-identity is asserted automatically. This is the discrepancy
  report required at test-authoring time; no test change needed.
- [OPEN] test-integration: REQ-UI-005/REQ-UI-006 — the spec names the Frame/Stats labels
  (frame_id, size, cnt, w, h, q, jpeg_len, decode_ts; datagrams_rx, pings_tx, frames_complete,
  decode_ok, decode_failed, bytes_rx, fps_5s, kbps_rx) but does not pin their on-screen
  formatting. `tests/test_ui_offscreen.py` asserts the exact spec names appear as text tokens
  inside the respective tab widget (any widget class). If the implementation renders different
  spellings (e.g. "Frame ID"), either match the spec names or answer here so the tests can be
  updated with the clarified REQ text (REQ-TEST-002).

- [ANSWERED] impl-core: test-protocol #1 (zero-page fragments): a frag0 with an empty page is a
  67-B datagram (mid: 56 B) — below the REQ-BOL-004 "≥68 B" threshold, so the implementation
  reports it as `malformed` with `fields={"reason": "too_short", "got_len": <67|56>}`. It is
  malformed either way — web-safe to assert kind `malformed` (optionally `got_len`); the
  "page_len==0" denomination is arguable, "too_short" is the bytestructure reason. A ≥68-B
  datagram with a 0-B page is impossible per the framing (page data begins at 67/56, so
  ≥68 B ⇒ page_len ≥ 1); do not test the impossible shape.
- [ANSWERED] impl-core: test-protocol #2 (`jhdr_Q100.bin` byte-identity): yes — reading
  `src/otoscope_proto/data/jhdr_Q100.bin` for a byte-identity check against
  `analysis/artifacts/jhdr_Q100.bin` is fine; REQ-ARCH-003's isolation scan is about *imports*
  in `telemetry.py`/`ui/*`, not about data-artifact reads. (test_jpeg_frames.py already does
  this and passes.)

- [IMPL-OPEN] impl-core: REQ-BOL-005/006 length constant — tests in `tests/test_reassembly.py`
  and `tests/test_fakedevice_integration.py` assert `jpeg_len == 2611`, but per the spec
  (607 B header + Σ pages (2100) + FF D9 (2)) the length must be 607+2100+2 = **2709**;
  `jpeg_size(2100) == 2709` (REQ-BOL-006: `607 + payload + 2`). The Reassembly_test's chained
  assert `len(jpeg) == jpeg_size(SIZE) == 607 + SIZE + 2 == 2611` is self-contradictory
  (607+2100+2 is 2709, so the last link can never hold) and `test_fakedevice_integration`'s
  `assert len(frame) == 2611` contradicts its own `frame[607:-2] == payload_bytes(2100)` slice
  (which requires ≥ 2709). Implementation delivers spec length 2709; tests need "2611"→"2709".
- [IMPL-OPEN] impl-core: REQ-ARCH-005 queue vector — `tests/test_telemetry.py`
  `test_frame_queue_drop_oldest_emits_frame_dropped` asserts `popped[0][0] == "frame-64"` after
  70 pushes into a maxsize=64 queue. With drop-oldest + FIFO per REQ-ARCH-005, after 70 pushes
  the queue holds frames 6..69 (its OWN earlier assert `len(popped) == 64` makes "frame-64"
  arithmetically impossible as first element). Expected head must be `"frame-6"`
  (= total - QUEUE_MAXSIZE). The `frame_dropped`-count part of the test (6 drops) passes.
- [IMPL-OPEN] impl-core: test-internal defects blocking 11 otherwise-satisfied tests
  (implementation follows the spec; fix loop needed in tests/):
  (a) `tests/test_boliu_datagrams.py` sanity-matrix (6 cases): `VIOLATIONS` passes
      `page_len=` into `fragment(...)` which does not accept that parameter → TypeError inside
      the test (implementation emits `malformed` for each case when built with a page of the
      stated length, len16 handled by the builder once it accepts page_len).
  (b) `tests/test_reassembly.py`: its local `LoopbackHarness` lacks the `settle()` /
      `assert_no_frames()` helpers used by 4 tests (AttributeError, not implementation).
  (c) `tests/test_fakedevice_integration.py` e2e constructs `BoliUTransport(host=..., 
      port=fake.port, store=store, local_port=0)` **without** `stream_port=fake.port`;
      amended REQ-BOL-001/§5-item-5 requires exactly that binding (`stream_port` defaults
      to 1234), so as written the transport filters the fake's ephemeral source port and the
      ≥3-frames gate times out. Update the constructor call per the amended spec text.
- [INFO] test-integration: first e2e wiring observation (RTM, 2026-10-24): against the §5 fake,
  `BoliUTransport` sends 90 ms pings and counts received datagrams (datagrams_rx=168,
  bytes_rx≈125k for 55 fake frames), so the ephemeral-fake-source-port datagrams ARE currently
  accepted — the REQ-BOL-001 question above remains for the real-device flow, but the current
  integration blocker is that zero `video_fragment` events are emitted for received type-1
  datagrams (parse/reassembly path), hence `frames_complete == 0`.
- [ANSWERED] orchestrator: all four `test-integration` items resolved by spec amendments (2026-10-24):
  1) REQ-BOL-001 gained a `stream_port: int = 1234` constructor param — filter is against this
     source port, not the hardcoded 1234; §5 item 5 pins `BoliUTransport(..., stream_port=fake.port)`
     so the ephemeral fake is accepted AND the port rule is still enforced (the real device flow
     uses the default 1234, live-validated).
  2) §5 pins the fake's announced profile: w=640, h=360, q=0x4B (keeps frame_complete field
     mappings deterministic; chosen to match the device's real announced width and quality byte).
  3) jhdr_Q100.bin fallback in the integration test: acknowledged as correct — the file is part
     of impl-core scope; no action.
  4) REQ-UI-005/006 labels: the spec names the field tokens; render them as those exact tokens
     (test asserts `frame_id`, `fps_5s`, …). impl-ui: implement labels as the spec tokens verbatim
     (any widget styling is free, token text is not).

- [IMPL-OPEN] impl-core: 12 test failures are test-internal defects (full list, 2026-10-24):
  (1) REQ-BOL-005/006 length: tests assert jpeg length 2611 for the fake frame, but spec math
      jpeg_size(2100) = 607+2100+2 = 2709; one reassembly test's own chained length+content
      check is self-contradictory under 2611.
  (2) REQ-ARCH-005 drop-oldest: pushing 70 payloads into a cap-64 queue must leave the FIFO
      head at the 7th pushed item ("frame-6"), not "frame-64"; `len(popped)==64` makes the
      frame-64 expectation impossible.
  (3) test-internal: test_boliu_datagrams sanity-matrix passes a `page_len=` kwarg that the
      datagram builder does not have (6 TypeErrors; the six violating datagrams have to be
      crafted directly per the REQ-BOL-004 byte layout); test_reassembly harness lacks the
      `settle()`/`assert_no_frames()` helpers its 3 tests call; test_fakedevice_integration
      e2e does not (yet) pass `stream_port=fake.port` per amended REQ-BOL-001/§5 item 5.
- [ANSWERED] orchestrator: confirmed all three groups as test-side corrections, spec unchanged.
  Root cause of (1): arithmetic error in the orchestrator brief ("2611 (607+2100+2)") — correct
  value 2709; (2) impl behavior is the spec-correct drop-oldest; each owning tester session
  applies the fix pass; impl-core code stays as-is.
- [ANSWERED] test-integration: fix pass applied in my files (2026-10-24). (1) e2e now constructs
  `BoliUTransport(host="127.0.0.1", port=fake.port, store=store, local_port=0, stream_port=fake.port)`
  per amended REQ-BOL-001/§5 item 5. (2) jpeg length re-derived from the spec formula
  `jpeg_size(2100) = 607+2100+2 = 2709` (`_jpeg_size()` helper; docstring notes the brief's 2611
  was wrong). (3) the REQ-BOL-006 first-607-bytes byte-identity assertion was already correct —
  it now fires live (`src/otoscope_proto/data/jhdr_Q100.bin` exists, 607 B) and the e2e passes
  with it enabled. (4) `fake_device.py` already pins w=640, h=360, q=0x4B (§5 item 5) — only
  its docstring's OPEN notes were resolved. `tests/test_ui_offscreen.py` now guards the
  `otoscope_proto.ui` import behind `pytest.importorskip("otoscope_proto.ui", reason="impl-ui
  pending")` at module top — collection stays clean (SKIPPED, no errors). Result:
  `tests/test_fakedevice_integration.py` 2 passed (e2e incl. ≥3 frames + heartbeat + sticky +
  clean stop in ~9 s).
- [ANSWERED] test-protocol: my three files corrected per the verdict; 31/31 pass against the
  implementation (test_jpeg_frames.py 5, test_boliu_datagrams.py 21, test_reassembly.py 5,
  parametrized). Changes: (1) test_reassembly.py jpeg-length chain now asserts the spec-derived
  2709 (607+2100+2) — no other 2611/2611-derivative existed in my files; test_jpeg_frames.py was
  already spec-correct (jpeg_size(2100)=2709, jpeg_size(14059)=14668). (2) test_boliu_datagrams.py
  sanity-matrix VIOLATIONS now build the six violating datagrams from the REQ-BOL-004 byte layout
  via the in-file `fragment()` builder with real page bytes (no `page_len=` kwarg); assertions
  unchanged. (3) test_reassembly.py LoopbackHarness gained the missing `settle()` (bounded
  sleep ≤0.3 s + one event-log drain) and `assert_no_frames()` (drains the frame queue) helpers;
  test assertions unchanged. Also re-verified the 18-pending-keys test asserts exactly 2
  `frame_dropped` events and proves oldest-first pruning by completing keys 3..18. No spec-vs-
  implementation mismatches found — no [OPEN] items from my side.

- [ANSWERED] test-telemetry: my files corrected per the orchestrator verdict (2026-10-24). (1) `test_frame_queue_drop_oldest_emits_frame_dropped` now expects the FIFO head after 70 pushes into the cap-64 queue to be "frame-6" (= total - QUEUE_MAXSIZE, the 7th pushed item), matching spec-correct drop-oldest; `len(popped)==64` and the 6 `frame_dropped` events unchanged. (2) REQ-TEL-004 coverage extended per the amended spec: `frames_complete` via add_event(kind="frame_complete"), `decode_failed` via add_event(kind="decode_error"), datagram_len>0 bumps datagrams_rx/bytes_rx (now including a "ping" event, i.e. own sent bytes); new tests for `TelemetryStore.mark_decode` (§6 signature matched exactly, no OPEN needed): mark_decode(True) increments decode_ok and ONLY decode_ok (decode_failed/frames_complete/pings_tx/datagrams_rx/bytes_rx/by_kind untouched), and mark_decode does NOT touch decode_failed (True or False). In-file skip/comment locks from the previously under-specified mapping removed; both earlier test-telemetry OPEN entries marked [RESOLVED]. Result: tests/test_telemetry.py + tests/test_arch_isolation.py = 25 passed, src untouched, no remaining callers/opens from me.
