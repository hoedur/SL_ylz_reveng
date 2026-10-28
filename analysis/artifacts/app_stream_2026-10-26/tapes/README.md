# Tapes captured 2026-10-26 (lossless app captures + live probe runners)

Evidence for doc `analysis/04-live-device-validation.md` §9.6 and arc42 §10b.10.

- `session_start5.pcapng` / `.tsv` — 60 s app **restart**, near-lossless client side
  *(caveat 2026-10-28 round-2 validators: some monitor-window loss at the device→AP leg —
  don't read device-denominator counts as exact; client datagrams are complete).*
  Session start at t+29.308 s: 2× `EF 00 04 00` ping (+0.00/+0.10), 2× `EF 02 28 00` empty
  report, first video datagram +0.10 s after the first ping, first record report +0.21 s
  (fid=2); session fid counter starts at 1. **The bootstrap tape.**
- `live_stream_now.pcapng` / `live_now.tsv` — 45 s steady state, near-lossless
  (same caveat; 22 158 fragment datagrams incl. 6 short last pages + 26 heartbeats +
  1 806 client datagrams): fid slope 16.08–16.22 fps,
  report cadence ~39/s (long-running session), 720 duplicate (fid,idx) fragments
  (= real device retransmits), full report-form set (64/60/40/88/76/80/104/96 B).
- `live_counts.py`, `live_rate.py` — live runners for protocol variants (ping-only control,
  report mode with parameterized cadence).
- `live_report2.py` — 2-record (completed + synthesized in-flight bitmask) probe.
- `live_report_sniff.py` — report-mode run with stale-port listeners (43875/38605):
  zero datagrams → the device never diverts video to stale client ports.
- `live_switch.py` — ping→reports phase-switch run (video stops when pings stop).

TSV columns: `frame.time_epoch · ip.src · ip.dst · udp.srcport · udp.dstport · udp.payload (hex)`.
