# App gold capture + H-1 RF experiment (2026-10-28, evening)

Two sessions on the same boot. Device ON throughout; host left DISCONNECTED after
(`wlan0`, slot free for the phone). Radio: `wlan0` station + `mon1` monitor (pre-existing).

## Session A — app gold capture (lossless, 74.2 s)

- Rig: `dumpcap -i wlan0 -I` (monitor, 0 dropped) + `adb logcat` + `adb screenrecord`
  (50 s) started BEFORE the user tapped connect; phone on USB.
- Files: `app_go.pcapng`/`app_go.tsv` (radiotap→TSV: ts, src MAC, sport, dport, hex),
  `rec_go.mp4` (screen), `logcat_go.txt`.
- App bootstrap (matches REQ-BOL-009 exactly): 2× `EF 00 04 00` at +16.76/+16.86 s,
  first fragment +0.093 s after first ping, first EF-02 report +0.203 s.
- App stream (892 frag0s, fid 1..942): **16.66 fps** fid-slope over 57.2 s
  (2026-10-26 band 16.08–16.22 → still 16.1–16.7). fid steps {1:742, 2:80, 0:58
  (retransmit frag0s), 3:9, 5:1, 7:1}. q: 843×75, 46×50, 2×25, 1×10; w,h = 640×480 100 %.
  **6 short last pages** (<68 B) in 27 189 fragment datagrams.
- **Zero delivery stalls**: 6 inter-fragment gaps >100 ms, max 0.143 s — the app sees
  none of the ~0.5-s device stalls our ping-mode client sees. Ping-mode "bursty
  cadence" is a client-condition property, not a device law.
- Reports: 1596 EF-02 (27.9/s) + 33 EF-08 (median 1.632 s). EF-02 shapes: 64 B ×1030,
  60 B ×211, **40 B empty ×122**, 96 B ×73, 104 B ×48, 88 B ×57, 76 B ×36, 80 B ×11,
  100 B ×8. 64-B fid = last completed frame, monotonic 48..940.
- **Report burst structure (this boot):** 972 bursts, median **1 report/burst**,
  burst interval median **32.7 ms** (~31/s singles); multi-report bursts exist
  (in-burst gap median 0.3 ms); 76/972 bursts led by a 40-B empty. The 2026-10-26
  "8.78 bursts/s × ~3.2 reports" was the LONG-session regime, not fresh-session.
  **Empty reports are burst-correlated with fragments (median 0.030 s after a
  fragment), concentrated at bootstrap (+16.96..+17.19: 40,40,76,76,76,40 …).**
- Device heartbeats: 39 to the phone port, median 1.641 s, seq 29..35+ (continuing
  counter, no reset visible mid-session).

## Session B — our report-mode client + simultaneous RF monitor (decisive for H-1)

- Rig: `sessionB_rf.pcapng`/`sessionB_rf.tsv` on `mon1` (43.9 s, 0 dropped) while
  `report_mode.py 0.037` ran the standard `BoliUReportTransport` (27/s reports,
  REQ-BOL-008/009 app-exact bootstrap) on `wlan0` (192.168.169.2).
- Client telemetry: 15 frames complete, span 1.0 s → **14.90 fps intra-burst**
  (burst gaps median 69 ms), then the classic halt; 398 report acks, 0 malformed,
  9 keepalives, 9 heartbeats.
- **RF ground truth: the device halted at the air interface, not on our host.**
  Fragments flow +1.40..+2.40 s after capture start (bootstrap +1.20): 335 datagrams,
  fid 1..15 complete, no gap >115 ms, 30 retransmit dups — then **zero fragments on
  RF for the remaining ~41 s** while the client kept reporting at 27/s (s3..s16) and
  device heartbeats continued at 1.6 s throughout. The client received essentially
  every fragment sent (15×~22 ≈ 335): **no host-side loss at all**.
- Consequence: H-1 is a **device-side condition** — the device stops fragment
  delivery ~1 s after bootstrap despite well-formed, app-cadence EF-02/EF-08 traffic.
  Client-side fixes (buffering, power-save, driver) are ruled out; H-2 deprioritized
  (see doc-04 §9.9 G item 6: the app holds NO Wi-Fi lock — static DEX evidence).
- Variant probe (`probe_empty.py`, archived under `analysis/artifacts/tools/`):
  +1 empty report after EVERY frame_complete (+4 rapid-fire post-bootstrap):
  **2 frames — no unlock** (run-to-run halt variance 0.3–1.2 s). Empties look like a
  symptom of the app's engine, not the unlock cause.

## Open (next H-1 lever, offline-derivable then live-confirmable)

The one structural difference left: the **report state machine** — the app mixes
record shapes (16/20/24-B records, 1..3 per report, state 1/0/3, partial bitmasks)
as its reassembly evolves, at ~31/s singles; our client sends uniform 64-B
state=1-full-mask. Derive the per-report state machine from this tape's report
sequence vs fragment arrivals, replay it live in one short session.
