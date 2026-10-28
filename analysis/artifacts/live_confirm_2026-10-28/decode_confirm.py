#!/usr/bin/env python3
"""Decode all complete frames of the live-confirm tape with the corrected
frag0 slice (page0 = d[56:len-11]) + REQ-BOL-010 SOF0 patch; djpeg checks
and MCU-row spike metric."""
import subprocess, sys, os
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, "/home/stefan/reveng/SL_ylz/prototype/src")
from otoscope_proto.jpeg_frames import JPEG_HEADER_TABLE, patch_sof0_dims

TSV = Path("/tmp/opencode/live_confirm.tsv")
OUT = Path("/tmp/opencode/live_confirm_dec"); OUT.mkdir(exist_ok=True)

frags = defaultdict(dict)   # fid -> idx -> datagram
meta = {}
hearts = 0; control = 0; other = 0; total = 0
for line in TSV.read_text().splitlines():
    parts = line.split("\t")
    if len(parts) < 4: continue
    d = bytes.fromhex(parts[3]); total += 1
    if len(d) < 4 or d[0] != 0x93: other += 1; continue
    if d[1] == 0x04: hearts += 1; continue
    if d[1] != 0x01: other += 1; continue
    if len(d) < 68: control += 1; continue
    fid = int.from_bytes(d[8:12], "little")
    idx = int.from_bytes(d[32:36], "little")
    cnt = int.from_bytes(d[36:40], "little")
    size = int.from_bytes(d[40:44], "little")
    w = int.from_bytes(d[44:46], "little")
    h = int.from_bytes(d[46:48], "little")
    q = d[48]
    meta[fid] = (cnt, size, w, h, q)
    frags[fid][idx] = d

complete = [fid for fid in frags if set(frags[fid]) == set(range(meta[fid][0]))]
complete.sort()
res = []
n_warn = 0
djpeg_rows = []
last_head = None
for fid in complete:
    cnt, size, w, h, q = meta[fid]
    head = JPEG_HEADER_TABLE.header_for(q & 0xFF)
    if head is None:
        head = last_head
    else:
        last_head = head
    pages = []
    for idx in range(cnt):
        d = frags[fid][idx]
        if idx == 0:
            pages.append(d[56:len(d)-11] if cnt > 1 else d[56:56+size-11])
        else:
            pages.append(d[56:])
    payload = b"".join(pages)
    jpeg = patch_sof0_dims(head, w, h) + payload + b"\xff\xd9"
    assert len(jpeg) == 605 + size + 2, (fid, len(jpeg), size)
    png = OUT / f"f{fid}.png"
    jpg = OUT / f"f{fid}.jpg"; jpg.write_bytes(jpeg)
    p = subprocess.run(["djpeg", "-pnm", "-outfile", str(png), str(jpg)],
                       capture_output=True, text=True)
    warn = p.stderr.strip()
    if warn: n_warn += 1
    djpeg_rows.append((fid, q, size, len(pages), warn[:90]))
    # report sizes
print(f"total datagrams={total} heartbeats={hearts} short-control={control} other={other}")
print(f"frames seen={len(meta)} complete={len(complete)} incomplete={len(meta)-len(complete)}")
print(f"djpeg warnings: {n_warn}/{len(complete)}")
for r in djpeg_rows[:12]:
    print(" fid", r[0], "q", r[1], "size", r[2], "cnt", r[3], "|", r[4])
if n_warn:
    for r in djpeg_rows:
        if r[4]: print("WARN", r)
print("dims check:", end=" ")
from PIL import Image
im = Image.open(OUT / f"f{complete[0]}.png")
print(im.size, im.mode)
