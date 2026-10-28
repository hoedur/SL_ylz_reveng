# Live confirm session — 2026-10-28 (post frag0-slice fix, device fresh power-on)

Purpose: first **fresh-hardware** validation of the wire-exact frag0 layout
(amended REQ-BOL-004: page0 = `d[56:len-11]`, 11 trailing ASCII bytes) after the
round-0/round-1 adversarial gate. Short ping-only session per the battery rule.

## Session facts

- Radio: Z-Com dongle enumerated as **wlan0** this boot (see AGENTS.md naming note),
  associated to `Earpick-AFD030` (BSS f4:42:50:af:d0:30), our IP 192.168.169.2/24.
- Client: `live_ping.py` — ephemeral UDP socket, `EF 00 04 00` pings to
  192.168.169.1:8800 every 100 ms, 15.2 s (150 pings). Capture: `dumpcap -i wlan0 -a duration:25`
  (lossless), TSV/pcapng archived here (raw hex in `live_confirm.tsv`).
- Device datagrams received: **1902** = 1892 fragment datagrams + 10 heartbeats
  (1.6 s cadence throughout); **none in the 57..67-B band** this boot (ordinary
  sub-1024-B last pages occur on ~every frame; only the 57..67-B band counts as a
  "short last page" — the 2026-10-27 "control datagrams" reading was inverted, they
  were just small last pages).
- Fragment shape: 60 × 1091 B frag0s (56 hdr + 1024 page + 11 tail) +
  1772 × 1080 B mid frags (56 hdr + 1024 page, no tail) + 60 last-page datagrams
  (129–1005 B, incl. 3 retransmit duplicates; none in the 57..67-B band) — exactly
  the amended layout.

## Decode verification (corrected slice, djpeg)

- Frames distinguishable only by **(slot, size)** key — see the ring-slot note below.
  The wire carries **60 complete frame cycles**; two cycles share a key each
  ((1,32473), (1,32537) — static-lens equal-size collision, distinct payloads).
- **58/58 distinctly-keyed complete frames decode djpeg-clean at 640×480 RGB** (zero
  warnings: no "extraneous bytes before marker", no "premature end") under
  `page0 = d[56:len-11]` + REQ-BOL-010 SOF0 patch. The prototype transport, fed the
  same tape, completes **60/60 cycles** with 0 malformed (doc-04 §9.10).
- MCU-row edge metric (round-1 acceptance): max row-to-row delta in rows 0..31
  ≤ **1.12** luma (median 0.64, baseline jitter y≥40 ≈ 0.3–0.5) — **58/58 clean**;
  MCU-aligned spikes (y=8/16/24) ≤ 1.02. The top-band / left-stripe anomalies of
  the pre-fix era are absent from live hardware.
- q distribution: 56×q=75, 1×q=50 (second frame), 1×q=25 (first frame) — device
  self-adjusts quality on boot/startup frames; sticky-head path not stressed live here.

## Delivery profile

- 58 complete frames in 14.8 s span → **3.91 fps effective** (ping-regime band
  **3.43–3.91** across n=3 sessions; this session slightly higher — fresh boot).
- Bursty as usual: whole-frame bursts ~25 fps intra-burst with ~0.5 s device-side stalls
  (patterns consistent with own_session_2026-10-27).

## Ping-tape finding (REFINED by gate round 2 — not the final reading)

- Today's tape: id ∈ {1,2}, 30 frag0s each, ~29 frames per id (each frame has a
  DIFFERENT size 12928/19700/32xxx). 2026-10-27 tape: id ∈ {1,2,3} with ~25 sizes per id.
- Cross-check: `u16@48` high byte (d[49]) == id−1 in **60/60** (this tape) and
  **54/55** archived frag0s — trivially the alternation bit (id−1) mod 2 on an id set {1,2}.
- **REFINEMENT (round-2 validator 3, same day):** the ping-only cycling is NOT the
  general semantics. Under the app's report mode `u32@8` is strictly monotonic AND
  equals the EF-02 report fid (2105/2111, 830/869 across app tapes); canonically
  `u32@8` = frame id, `d[49]` = (fid−1) mod 2 alternation bit (38 710/38 727 overall),
  `u32@24` = previous frame id. See doc-04 §9.9 G / §9.10 + arc42 §10b.4.
- Consequence unchanged: the prototype's `(frame_id, size)` reassembly key
  (REQ-BOL-004/010) handles both regimes — no code change needed.
- Former "corrections" below were applied to the docs then superseded the same day:
  "8..11 frame id (ping: cycles {1..3})" and "48..49 high byte = (id−1) mod 2".

## Files

- `live_confirm.pcapng` / `live_confirm.tsv` — lossless capture (TSV: t, src:port, len, hex).
- `live_ping.py` — the ping client; `decode_confirm.py` — decode/djpeg harness
  (NOTE: decode_confirm.py keys on fid ONLY and is superseded by the inline
  `(slot, size)`-keyed analysis — see the finding above; kept unmodified for honesty).
- `pngs/` — three representative decodes (first q=25 boot frame, q=50 second frame,
  steady-state q=75).
