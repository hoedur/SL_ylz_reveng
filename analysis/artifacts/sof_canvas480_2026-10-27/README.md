# sof_canvas480_2026-10-27 — canvas-480 verification (PROVENANCE: pre-gate round 0)

This directory documents the REQ-BOL-010 SOF0 dims patch work (wire raster is 640×480,
head SOF0 patched per frame — §9.8), which **survived** the adversarial gates.

**But:** the `tools/*.py` scripts were written before the 2026-10-27 round-0 gate
corrected the frag0 layout — they parse `FRAG0=67` (the retracted "leading 11 bytes"
reading, slicing page0 at `d[67:]`). The retracted slice shifted the JPEG entropy by
11 B and produced:

- the "device-side foreign content / top-band" attribution (retracted),
- MCU-row-edge "spikes" (y=8/16/24) that are absent under the wire-exact slice,
- residual djpeg warnings incl. the retracted "~3 B on fid 2080".

Each script carries a `SUPERSEDED` banner. The corrected-slice evidence lives in
`../frag0_layout_2026-10-27/` (`frag0_verify.json`, README, before/after PNGs) and
doc-04 §9.9 D. The `pngs/` (480-canvas) renders in this directory were also built
from the old slice — treat the *pixel* content of the top rows with the same caution
(the bottom-120-rows existence proof is unaffected: it concerns canvas geometry,
not the 11-B shift).
