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
  datagram with a 0-B page is impossible per the framing (page data begins at **56 on every
  fragment**; frag0 additionally carries 11 trailing bytes at d[len-11:len] — amended
  REQ-BOL-004 2026-10-27, so ≥68 B ⇒ page_len ≥ 1; the old "67/56" wording pre-dated the
  slice amendment); do not test the impossible shape.
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

## 2026-10-24 — orchestrator: REQ-BOL-005/006 AMENDED (JPEG header per frame, 605 B)

Root cause found while the user reported "washed-out grey video and choppy stream"
in the live prototype run. Analysis (archived under `analysis/artifacts/decoded/`,
disassembly `analysis/artifacts/bl.asm` / `libbl_vii_jni.so`):

1. **Extraction bug (the old "607 B" fact was wrong).** The six embedded
   `jpeg_header_640x360_Q…` symbols sit at a 605-byte stride (0x4c1a, 0x4e77,
   0x50d4, 0x5331, 0x558e, 0x57eb). The upstream extraction copied 607 bytes per
   head, so every `analysis/artifacts/jhdr_Q*.bin` carries a 2-byte stray tail
   (the next head/pool's bytes — literal `FF D8` for Q5..Q75, `5D 02` for Q100).
   Consequences: Q5..Q75 fail with "broken data stream" (the `FF D8` tail is an
   invalid entropy-stream marker); Q100 "decodes" but with a 2-byte-shifted
   entropy stream → tiny dequantized coefficients → the washed-out grey look.

2. **Native selection rule (disassembly, `handle_mcu_msg_frag` @0x267e..0x2698).**
   The announced quality byte (low byte of the u16 at offset 48) is compared
   against 5/100/25/50/75/10 and the matching embedded head is selected; no
   match → no new head (sticky previous head). The announced byte is the
   **encoder's actual quality**: live trace shows per-frame q = 25/50/75.

3. **Amended spec.** REQ-BOL-005/006 + REQ-TEST-004 + REQ-OPS-004 + §3 tree were
   amended in `docs/ARCHITECTURE.md`: six **605 B** heads as package data files
   (`src/otoscope_proto/data/jhdr_Q{5,10,25,50,75,100}.bin`, extracted fresh from
   the .so; SHA-256s in README), reconstruction = `header_for(low byte of q) +
   Σ pages + FF D9`, unknown q → sticky previous head, initial fallback
   `jhdr_Q100.bin`. JPEG length changes by −2 vs the old pinned numbers:
   `jpeg_size(p) = 605 + p + 2` → artifact case 14 666 (old pinned 14 668),
   fake-device case **2707** (old pinned 2709).

4. Tests updated by the orchestrator under this amendment (the tester-agents'
   spec-only pass was executed against the pre-amendment spec): test_jpeg_frames.py
   (six-head table, byte-identity vs artifacts[:605], artifact case with the
   Q25 head per frame0's announced q=25), test_reassembly.py (605/2707 numbers;
   two new tests pinning quality-byte selection → Q75 head and the sticky rule),
   test_fakedevice_integration.py (§5 fake pins q=0x4B → first 605 bytes ==
   `data/jhdr_Q75.bin`, 2707). Full suite: **72 passed, 0 failed** (QT_QPA_PLATFORM=offscreen).

5. **Still open (live-awaited):** visual A/B of the corrected pipeline against the
   original app needs the device ON (it was powered off during this analysis).
   Choppy-stream diagnosis likewise needs a live capture while the ORIGINAL APP
   streams (its ping cadence / batch behavior on the wire is unmeasured — existing
   captures only contain idle heartbeats + our own probes).

## Amendment 2026-10-26 — REQ-BOL-008 (report mode), from the original-app capture

**Basis** (analysis, no hardware regression): monitor-mode capture of the ORIGINAL
app streaming (`analysis/artifacts/app_stream_2026-10-26/`, doc-04 §9.5, arc42
§10b.10). The app streams at **≈14.1 fps sustained** (1119 fids over 79.4 s) while
our ping-only client gets ~3.9 fps (§9.2 cadence sweep — fps NOT ping-gated). On the
wire the app sends **no `EF 00 04 00`**: it sends `[EF][02][len][body]`
receive-progress reports (~8.8/s; `fid` = last fully received frame; per-record
fragment bitmasks for in-flight frames; body magic `02 02 00 01`, const
`0a 4b 14 2d`; `len16` counts the whole datagram) and `[EF][08][08 00][u32]`
keepalive every 1.64 s whose u32 counts stream seconds — mirrored by the device
heartbeat `seq`. Device-side: per-frame last page is a short datagram (78–345 B
reminders) — already handled by REQ-BOL-004 arithmetic.

**New spec:** REQ-BOL-008 in `docs/ARCHITECTURE.md` — `BoliUReportTransport`
mentions *ack-gating hypothesis H-1 (live test pending)*: EF-02 report cadence
(≈9 Hz) is the suspected pacing lever; mode exists to sweep report rate
(3/9/30 Hz) against fps once the device slot is free.

**Test plan (tests/test_report_mode.py, citing REQ-BOL-008):** exact report
datagram bytes at fid 0 and after completed frames; byte-exact interval-zero case
suppressed until first completion? — no: spec says fid=0 until completion, sends
continue; keepalive byte format + seq initialization from first heartbeat seq;
heartbeat-driven seq; no `EF 00 04 00` ever sent in report mode; inherited
reassembly + stop semantics.

## Amendment 2026-10-26 (later) — REQ-BOL-008: no fid-0 reports; EF-00-04 arming is required

**Live falsifications (first report-mode sweep against the real unit):**

1. **Pure report mode (no EF-00-04) is dead**: 3 × 15 s runs at report rates
   8.9/3.0/30.3 Hz — zero frames, zero heartbeats. The device did not even open a
   session ⇒ *"any datagram to 8800 re-arms"* (AGENTS.md fact) is WRONG; `EF 00 04 00`
   arming is required (or at least EF-02 alone does not arm).
2. **Combined ping + fid-0 report**: session opens (8 heartbeats in 14 s, our
   keepalive seq initialized from heartbeat seq ≈ 977) but **zero video frames** —
   reports claiming `fid=0 (state=complete)` while the device is ~977 frames ahead
   poison/hold the stream.
   ⇒ Strong support for ACK gating (H-1): the device *does* read the reports.

**Spec amendment:** report sends are silent until the first real frame completes
(`fid > 0`); tests updated accordingly (`test_report_bytes_at_fid_zero` → "no
report_ack before first completion"). Ping sweetens nothing else in report mode;
the combined-mode variant (ping@90 ms + reports) is the live-sweep vehicle.

## Amendment 2026-10-26 (later) — REQ-BOL-009: bootstrap decoded; report mode goes app-exact

**Decisive evidence** (`/tmp/opencode/session_start5.pcapng` — full app restart,
client-side captured essentially lossless; + the 45 s lossless steady-state tape
`live_stream_now.pcapng`):

- Session start (t = first video datagram − 0.10 s):
  `EF 00 04 00` ×2 (0.10 s apart) → `EF 02 28 00` ×2 → continuous reports.
  **The 4-byte ping IS sent — exactly twice, at bootstrap only, never again.**
- First video fragment reaches the client **+0.10 s** after the first ping;
  first record-bearing report **+0.21 s** with `fid=2`.
- Per-session fid counter starts at **1** (app fresh session: 1..463/29.3 s) —
  our small fids are correct after all.
- Report rate sustained **~26.4/s** (778/29.5 s); earlier "8.8/s" was a duty
  artifact of the lossy capture. Keepalive EF-08 every ~1.3–1.6 s.
- Lossless steady state: **16.1–16.2 fps** (fid slope), inter-fragment p50
  0.5 ms, and **720 duplicate (fid,idx) fragments** — real retransmits, so the
  report fragment bitmasks do trigger device retransmission.

**Spec work**: new REQ-BOL-009 (bootstrap sequence + `report_empty` event +
`build_empty_report()` + `BOOTSTRAP_PING_GAP_S=0.10`), REQ-BOL-008 interval
default amended 0.112 → 0.038. Continuous ping loops forbidden in this mode
(live: ≈3.7 fps cap); pure-report without bootstrap ping → no session at all
(live). Tests: bootstrap order, exactly-2-pings-lifetime, empty-report bytes +
event fields, steady-state wire has no ping after first report_ack. Suite 87/87.

## Amendment 2026-10-26 (late) — REQ-BOL-010: SOF0 dims patch; "bogus 480" corrected; artifact attribution revised

> *(log hygiene 2026-10-28: the "device-side artifact attribution" half of this entry was
> superseded by the 2026-10-27 entry below — the stripes were OUR `d[67:]` slice bug;
> the REQ-BOL-010 SOF0-patch half stands.)*

**Trigger**: user-reported stripes/color-shift + adversarial validation round (5 agents,
gate FAILED 3/5 — conclusion rescope). Decisive new facts:

- Native `libbl_vii_jni.so` helper @0x2640 patches the head copy's **SOF0 dims per frame**
  from the wire (caller stashes h=d[46]→slot[158], w=d[44]→slot[156] @0x240c/0x2414;
  helper reads them @0x26c8/0x26d2 and writes BE16 into head+145/147 @0x26dc/0x26e4).
- **The wire's h=480 is the REAL raster height** (1 061/1 061 frag0 datagrams in both
  tapes announce w=640, h=480). Canvas-480 decode reproduces the app's full render
  (incl. the bottom 120 rows); top-360 rows are pixel-identical under both canvases;
  the pre-EOI "surplus entropy" (~6.4–11.2 kB, earlier called live-only) is the
  bottom-raster rows' encoded data the 360-canvas head could not consume
  (fid 2080: 8374 → 3 extraneous bytes). P fixes: REQ-BOL-010.
- **User-visible top-left stripes exist in the device's own stream** (7/10 complete
  app-session tape frames show a foreign-palette top band; 2080/2303/2153 strongly
  match OTHER frames' content). Attribution: device-side encoder content at scan
  start — NOT a reassembly bug, NOT our delivery regime. The native machine has an
  additional exposure the prototype lacks: its completion scan never tests page-0's
  bit and recycles ring slots (fid−4) without clearing buffers → a page0-loss frame
  completes with stale slot content in the APP (prototype drops such frames instead).
- Empirical instrument correction: **PIL (venv Pillow 13) swallows libjpeg
  warnings** — "decode clean / no warnings" findings must be re-checked with `djpeg`.

**Spec work**: REQ-BOL-010 (assemble_jpeg gets width/height kwargs, `_collect` passes
entry.w/entry.h); REQ-BOL-005 wording unchanged (h is a real field, not bogus).
Tests to add: patch function byte-exactness (Q25 head + (640,480) → `01 e0 02 80` at
145..149), no-patch default, transport pop delivers announced dims.

## Amendment 2026-10-27 — REQ-BOL-004: frag0 wire-exact layout (gate-1 validator, adversarial round 0)

Disassembly-driven correction (native block `0x26e8–0x2704` incl. — addr corrected 2026-10-28 gate round 1: the old `0x2702` stop missed the second-half store at 0x26fa — in `libbl_vii_jni.so`, exhaustive store sweep over `0x230c–0x2760`): **frag0's "11 extra bytes" are TRAILING, not leading.** Every fragment's header is 56 B; frag0 datagrams append 11 trailing ASCII metadata bytes at `d[len-11:len]` (e.g. `-0214,-0894`; natively stashed at `slot+0x1000a4..0x1000af`, ring slot stride `0x1000b0`). The previously documented `page0 = d[67:]` slice (67-B frag0 header) shifted the entropy stream by 11 B — the "3 extraneous bytes on fid 2080"/"premature end" residual-warnings and much of the top-band artifact attribution were artifacts of that slice.

- REQ-BOL-004 text amended (page0 = `d[56:len-11]`, `cnt==1` → `size-11` B *(corrected 2026-10-28, gate-1 round 1 V4-K5/V3-C5: `size` B — the datagram is 56+size+11 so the tail sits past the page end; the `size-11` reading would have called every conforming cnt==1 frame malformed)*; framing totals unchanged: frag0 datagrams stay 1091 B).
- Code: `boliu.py` `FRAG0_HDR=67` removed → `FRAG_HDR=56` + `FRAG0_TAIL=11`, slice updated; `fake_device.py` + all four test `fragment()` builders emit the wire-exact layout; `test_fakedevice_integration` page0 slice updated. Suite: 96/96 after the change.
- Offline tape re-verification (corrected recipe): see `analysis/artifacts/frag0_layout_2026-10-27/` (per-frame djpeg warnings old-vs-new slice at 640×480; top-band metrics old-vs-new).
- OPEN items: (1) the 11-B tail's meaning — ASCII sensor-value-like strings (candidate link to the open heartbeat "drift word" question; would give the wire a sensor channel — arc42 §10b previously recorded "no sensor channel on this unit" and that needs a re-check / candidate REQ-BOL-011 to surface `tail` in an event field); (2) `cnt==1` frag0-tail arithmetic is derived, not live-validated (no cnt==1 frame in any tape); (3) page0-tail behavior at `size < 1024` mid-frames not yet observed.
- Note: the 7 short `[0x93][01]` control datagrams (58–67 B, body `02 02 00 01` + fid-triple, no fragment fields) documented by the same recounted tapes are NOT fragments and stay out of REQ-BOL-004 parsing (they hit `malformed`/too-short paths). *(REVERSED 2026-10-28, gate round 1 validator 2: they ARE fragments — short last pages, `len == 56 + size−(cnt−1)·1024`; see the "gate round 2" amendment below.)*

## Amendment 2026-10-28 — REQ-BOL-004 naming note (no behavioral change): fragment `u32@8` is a ring-slot id

> *(REFINED 2026-10-28, gate round 2 validator 3: the ring-slot reading holds **only under
> ping-only delivery**; canonically `u32@8` is the frame id — monotonic under the app's
> report mode and equal to the EF-02 report fid (2105/2111, 830/869) — with
> `u16@48` high byte = **(frame id − 1) mod 2** (alternation bit, 38 710/38 727 across all
> tapes), and `u32@24` = previous frame id. Detailed record: doc-04 §9.10 + §9.9 G.)*

Live confirm session on fresh hardware (`analysis/artifacts/live_confirm_2026-10-28/`, doc-04 §9.10):
the fragment header's `u32@8` (and its duplicate @16) cycles within a tiny set — {1,2} today (~29
frames per slot, each frame with a DIFFERENT size), {1,2,3} in the 2026-10-27 tape — i.e. it is a
native **ring-buffer slot id**, not a monotonic frame id. Cross-check: `u16@48` high byte
(`d[49]`) == (frame id − 1) mod 2 in 60/60 live and 54/55 archived frag0s. Under the app's
report mode `u32@8` is monotonic — the EF-02 `fid` IS this identifier (round-2 reversal).

- REQ-BOL-004's field name `frame_id` stays (implementation terminology), with this comment-level
  clarification; **the `(frame_id, size)` reassembly key already in REQ-BOL-004/010 is required**
  and is what makes small-cycling (ping-mode) ids safe — no code change, suite 96/96 *(98/98
  after the round-2 short-page fix)*.
- Same session validates the amended frag0 slice end-to-end on live hardware: **60/60 wire
  cycles complete; all 58 distinctly-keyed decodes djpeg-clean at 640×480**, MCU-row edge
  spikes ≤ 1.12 luma, delivery 3.91 fps (ping-serve band now 3.43–3.91 across n=3 sessions).
  Prototype e2e on the real tape: 1892 fragments / 60 frame_completes / 0 malformed;
  58/59 independent rebuilds byte-match pushed JPEGs. Edge case found: two cycles sharing
  `(slot, size)` within the LRU window overwrite silently (benign; doc-04 §9.10).
- Gate-1 follow-up corrections (addresses only): native stash block is `0x26e8–0x2704` incl.
  (`subs r0,#56` @0x26e2, second-half store @0x26fa); EOI `strh` @0x266c (docs updated).
- New datagram observation: the 7 short 58–67 B `[0x93][01]` control datagrams of 2026-10-27 did
  NOT appear on this boot (0 in 15 s) — *(superseded same day: they are short LAST-page fragments,
  not control datagrams; the correct statement is that no last page under 12 B occurred this
  boot — doc-04 §9.9 F.4 / §9.10).*
- Harness note (2026-10-28, gate-3 round 1): the test suite binds the hard-coded loopback
  source port 127.0.0.1:1234; an external occupant of that port makes ~33 tests fail with
  bind OSError (environment flake, no code regression — verified by gate-3 validator).
  Future harness work should bind port 0 with a stream_port override or catch and note.

## Amendment 2026-10-28 (gate round 2) — REQ-BOL-004: the "short control datagrams" were SHORT LAST PAGES; <68-B blanket gate was dropping real fragments (bug fixed)

Gate round 1, validator 2 (own_session tape bookkeeping audit) proved 10/10 short
`56+remainder` datagrams across all three tapes (own_session ×3, live_now ×6, session_start5 ×1)
are **last-page fragments** (`len == 56 + size-(cnt-1)·1024`), not control datagrams — every one
under the blanket `<68 B` gate, i.e. the prototype dropped a real fragment (and its frame became
incomplete) whenever the final page was < 12 B.

- Spec: REQ-BOL-004 floors are now **per index** (frag0 = 68 B = 56+1+11; idx>0 = 57 B = 56+1);
  the "7 short control datagrams" open question is **closed** (they are fragments); fragment
  totals across the 2026-10-26 tapes correct to **34 869** (22 158 live_now + 12 711 session_start5).
- Code: `_handle_fragment` parses fields after a ≥50-B floor, then applies the per-index floor;
  the zero-page frag0 test (67 B → `too_short`) unchanged; two new tests
  (`test_short_last_page_fragment_is_accepted` — 59-B last page completes the frame with the
  correct 3-B page bytes; `test_short_nonlast_fragment_is_still_malformed`). **Suite 98/98.**
- e2e on the archived own_session tape: the fixed transport completes **55/55 blocks**
  (previously 52 — the 3 shorts were the missing last pages), 1966 video_fragments
  (every 0x93/01 datagram), 0 malformed; live_now 10/10 completes with 22 158 fragments.
## Amendment 2026-10-28 (gate round 2) — REQ-BOL-004: the "short control datagrams" were SHORT LAST PAGES; <68-B blanket gate was dropping real fragments (bug fixed)

Gate round 1, validator 2 (own_session tape bookkeeping audit) proved 10/10 short
`56+remainder` datagrams across all three tapes (own_session ×3, live_now ×6, session_start5 ×1)
are **last-page fragments** (`len == 56 + size-(cnt-1)·1024`), not control datagrams — every one
under the blanket `<68 B` gate, i.e. the prototype dropped a real fragment (and its frame became
incomplete) whenever the final page was < 12 B.

- Spec: REQ-BOL-004 floors are now **per index** (frag0 = 68 B = 56+1+11; idx>0 = 57 B = 56+1);
  the "7 short control datagrams" open question is **closed** (they are fragments); fragment
  totals across the 2026-10-26 tapes correct to **34 869** (22 158 live_now + 12 711 session_start5).
- Code: `_handle_fragment` parses fields after a ≥50-B floor, then applies the per-index floor;
  the zero-page frag0 test (67 B → `too_short`) unchanged; two new tests
  (`test_short_last_page_fragment_is_accepted` — 59-B last page completes the frame with the
  correct 3-B page bytes; `test_short_nonlast_fragment_is_still_malformed`). **Suite 98/98.**
- e2e on the archived own_session tape: the fixed transport completes **55/55 blocks**
  (previously 52 — the 3 shorts were the missing last pages), 1966 video_fragments
  (every 0x93/01 datagram), 0 malformed; live_now 10/10 completes with 22 158 fragments.
- New nuance for round 2: session_start5 shows **2410 heartbeats in 55.3 s with 2382 ≈0.4-ms
  gaps in dense bursts** (vs our 1.6-s cadence sessions) — heartbeat behavior under the app's
  report-mode client needs classification; doc-04 §9.9 B nuance: ping-mode heartbeat seq stuck
  at 1 for 9 beats.

## Gate round 2 — RESULTS (2026-10-28): 5/5 favorable, ≥4/5 advance threshold met

Formal record: doc-04 §9.9 G (round-2 section). Verdicts by validator (scratch reports in
`/tmp/opencode/r2_gate1..5/verdict.md`):

| # | Validator | Verdict | Canon delta |
|---|---|---|---|
| 1 | short-page fix (all four tapes replayed, adversarial shapes, spec↔code) | **CONFIRM** | 0 violations on 36 835 type-1 datagrams; all 125 pushed JPEGs byte-match; re-push nuance: own_session = 51 keys + 4 late-retransmit re-pushes (benign) |
| 2 | decode-claims recount (rebuilt 60/60 live + 55/55 own_session, djpeg zero-warning) | **PASS with 5 wording corrections** (all applied) | burst = 85 pages + 1 dup = 86; 60 frags + 2 pings = 62 client datagrams; MCU metric pinned: int-rounded row means 58/58 ≤ 1.0 (float 57/58 ≤ 1.167); "short" = 57..67-B band only |
| 3 | ring-slot semantics (38 727 datagrams, 4 tapes) | **CONFIRM with refutations** | **reversal**: canonically `u32@8` = frame id — monotonic under the app and IS the EF-02 report fid (2105/2111, 830/869); ring cycling {1..3} is ping-only; `d[49]` = (id−1) mod 2 alternation bit (38 710/38 727); `u32@24` = previous frame id |
| 4 | docs coherence sweep (canon + formatting + cross-refs) | **CONFIRM with 14 fixes** (all applied) | fps band 3.43–3.91; suite 98/98; 78 268 total; addresses 0x2704/0x266c; REQ-BOL-005 semantics row |
| 5 | heartbeat bursts (session_start5 anomaly) | **CONFIRM (classification ≈95 %)** | storms = byte-identical TX re-submits (seq frozen, 1445 distinct MAC seq over 2415 frames) toward a STALE socket, anchored on the 1.6-s grid, only in no-active-client eras; seq resets on client registration, advances with EF-08 |

- **No shipped code fix was refuted**; the two semantic refinements (frame id / alternation bit;
  heartbeat storm classification) and the wording corrections went into doc-04, arc42 §10b.4,
  AGENTS.md, REQ-BOL-004/005 rows, artifact READMEs, and `live_ab.py` (per-index floors).
- Key upgrades rejected on evidence: `(slot,size,cnt,q)` key (split nothing — cnt/q are
  frame-constant; colliding pairs agree on both); LRU 16 retained (pending peaks 1–2, cap
  never binds at 8/16/32).
- Open after round 2 (round-3 candidates): H-1/H-2 (needs user's sudo power-save test),
  sensor-tail REQ-BOL-011 decision, live `cnt==1` observation, heartbeat settle-experiments
  (client-kill + 60 s monitor capture; crafted `EF 08 08 00 [u32=12345]` probe).

## Amendment 2026-10-28 (evening) — H-1 decider: RF monitoring proves the report-mode halt is DEVICE-side; second app gold tape

Artifacts `analysis/artifacts/app_session_2026-10-28/` (README = full numbers),
record in doc-04 §9.11. Two sessions, same boot:

- **App tape #2 (lossless + screen + logcat):** bootstrap = REQ-BOL-009 exact; **16.66 fps**
  (band now 16.1–16.7); **zero device stalls visible to the app** (max inter-fragment gap
  0.143 s vs our client's ~0.5 s) — ping-mode burstiness is a client-condition property;
  reports 27.9/s in **~31/s single-report bursts (median 1/burst, 32.7 ms interval —
  the 2026-10-26 "8.78 bursts/s × ~3.2" was the long-session regime)**; 122× 40-B empties
  are burst-correlated with fragments (median 30 ms), concentrated at bootstrap.
- **Session B (our client under mon1 RF):** 15 frames at **14.90 fps intra-burst**, then
  the halt — and RF shows the device **stopped transmitting fragments for ~41 s** while
  our reports (27/s, 0 malformed) and its heartbeats (1.6 s) continued. Client-side causes
  (loss/power-save/driver) all excluded in one experiment. Variant probe
  (completion-correlated empties, `probe_empty.py` archived): 2 frames, no unlock.
- H-2 deprioritized: the shipped app holds **no Wi-Fi lock** (static DEX evidence, doc-04
  §9.9 G item 6).
- **Next H-1 lever:** derive the app's **report state machine** (mixed record shapes
  16/20/24 B, 1..3 records, states 1/0/3, partial bitmasks at reassembly moments) offline
  from tape #2, replay live, then gate round 3. No spec/code change in this entry
  (live-probe tooling only); REQ-BOL-008 note updated with the RF result.
