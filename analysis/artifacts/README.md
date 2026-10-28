# analysis/artifacts — provenance notes

Scattered working artifacts of the live probes; session-specific documentation lives
in the subdirectories' READMEs (`app_stream_2026-10-26/`, `own_session_2026-10-27/`,
`frag0_layout_2026-10-27/`, `sof_canvas480_2026-10-27/`, `live_confirm_2026-10-28/`).

## ⚠ `frame0.bin` … `frame3.bin` — pre-2026-10-27 builds (old page0 slice)

These four frame payloads were assembled BEFORE the adversarial round-0 gate with the
retracted `page0 = d[67:]` slice (67-B frag0 header reading; amended REQ-BOL-004:
page0 = `d[56:len-11]`, 11 TRAILING ASCII bytes). Under the **canonical recipe**
(head for the announced q + SOF0 patch to 640×480 + `d[56:len-11]` pages + `FF D9`)
they decode with djpeg warnings (e.g. frame0: "3224 extraneous bytes before marker
0xd9") — **do not use them as decode-clean acceptance evidence**, and do not interpret
such warnings as the frag0 round having broken decode. Wire-exact rebuilds of the same
frames are djpeg-clean at 640×480 (`analysis/artifacts/frag0_layout_2026-10-27/`).
The prototype tests that read them (`test_jpeg_frames.py`, `test_sof0_dims.py`) pass
for geometry reasons; PIL is warning-blind.

## `jhdr_Q*.bin` (607 B) — over-extracted head artifacts

The six `jhdr_Q{5,10,25,50,75,100}.bin` files here are 607 B (a 2-byte over-extraction;
root cause of the old "Q5..Q75 fail to decode" claim — doc-04 §5b-2). The canonical
605-B heads are `prototype/src/otoscope_proto/data/jhdr_Q*.bin` (REQ-BOL-006).
