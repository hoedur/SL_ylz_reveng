# Frag0 wire-exact layout verification (2026-10-27, gate validator 1 + round-1 retest)

Correction: the frag0 "11 extra bytes" are **trailing** (`d[len-11:len]`, ASCII, e.g.
`-0214,-0894`), not leading. Every fragment header is 56 B; page0 = `d[56:len-11]`
(1024 B). Native proof: `libbl_vii_jni.so` block `0x26e8–0x2704` incl. (idx==0 only; addr
corr. 2026-10-28 gate round 1 — the second-half store completes at 0x2704, `subs r0,#56`
@0x26e2) copies the
last 11 contiguous bytes into a fixed landing zone at `slot+0x1000a4` (ring slot stride
`0x1000b0`); exhaustive store sweep over `0x230c–0x2760` finds exactly four head-region
writes (head copy @0x26bc/26c4, SOF0 dims @0x26dc/0x26e4, EOI `strh` @0x266c) — no others.
Scratch: /tmp/opencode/gate1_sof0/ (callsite.txt, sweep.py, decode outputs).

## Per-frame result (live_now.tsv, 10 complete frames, SOF0-patched 640x480 head)

| fid | q | OLD slice (d[67:]) djpeg          | NEW slice (d[56:len-11]) djpeg | bandΔ old→new | worst MCU-row edge old→new |
|-----|---|-----------------------------------|--------------------------------|---------------|----------------------------|
| 2035|75 | premature end of data segment     | clean                          | 31.5 → 21.6   | 11.5 (y=16) → 0.46         |
| 2080|75 | 3 extraneous bytes before 0xd9    | clean                          | 100.2 → 11.5  | 13.6 (y=8) → 0.81          |
| 2153|75 | premature end of data segment     | clean                          | 77.9 → 22.7   | 1.4 → 0.50                 |
| 2303|75 | clean                             | clean                          | 116.3 → 18.7  | 39.0 (y=16) → 0.29         |
| 2414|75 | clean                             | clean                          | 37.8 → 29.3   | 12.8 → 0.94                |
| 2419|75 | clean                             | clean                          | 71.0 → 30.3   | 20.8 → 1.03                |
| 2553|50 | premature end of data segment     | clean                          | 5.4 → 4.8     | 2.0 → 0.70                 |
| 2561|50 | premature end of data segment     | clean                          | 59.1 → 38.8   | 7.0 (y=24) → 0.02          |
| 2645|50 | premature end of data segment     | clean                          | 52.0 → 29.5   | 39.6 (y=24) → 0.27         |
| 2675|50 | premature end of data segment     | clean                          | 95.0 → 31.0   | 31.8 (y=24) → 0.78         |

- NEW = **10/10 djpeg-clean**; old = 7/10 warning (incl. the "3 extraneous bytes" fid-2080
  headline, now explained as a slicing artifact).
- All V2-style MCU-row edge spikes (y=8/16/24, "top slab") **vanish** under the corrected
  slice: the residual at the *former spike row* is ≤1.35 luma for those frames (worst
  2561: 1.35). Column note: "worst MCU-row edge" quotes the edge **at the old spike's
  row** — the *global* new-slice max over y∈{8,16,24} is ≤1.87 (fid 2553, whose old
  edge was only 2.0); doc-04 §9.9 D therefore says "collapse to ≤1.35 (spike frames)",
  i.e. every frame that HAD a spike is spike-free.
  Under the corrected slice → the §9.8-device-side top-band attribution (and validator 2's
  "device-side top-row pipeline effect" mechanism) is refuted: the artifact was OUR 11-B
  entropy shift. Remaining band-mean deltas are scene-level (not MCU-aligned).
- `frag0_verify.json` holds the full records (bandΔ = mean absolute channel delta rows 0-14
  vs 18-32, old §9.7-C criterion; edges = row-to-row luma discontinuities at y=8/16/24 plus
  baseline max at y≥32).
- `f2303_corrected.png` / `f2303_old67.png`: worst old-slice band frame before/after.

## Implications

1. The user-visible left/top stripes were most plausibly **the prototype's own slicing bug**
   (the app/native decode used the correct slice). Live confirmation pending (§9.9 retest (b)).
2. "Extraneous bytes before 0xd9" numbers derived with the old slice (e.g. 8374→3 B on fid
   2080) are retracted; the large canvas-360 E360 surplus (≈25 % = bottom raster rows, per
   gate validator 3) must be re-derived under the corrected slice before persisting.
3. REQ-BOL-004 amended in `prototype/docs/ARCHITECTURE.md` + `coordination.md`
   (suite 96/96).
