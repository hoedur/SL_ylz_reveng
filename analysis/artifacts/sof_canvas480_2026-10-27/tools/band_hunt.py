#!/home/stefan/reveng/SL_ylz/.venv/bin/python
"""Decode all complete tape frames at canvas480; quantify left/top band artifacts:
per-row/per-col luma discontinuity near edges."""
import struct, subprocess, tempfile, os, sys, io, json
sys.path.insert(0, "/home/stefan/reveng/SL_ylz/prototype/src")
from PIL import Image
from otoscope_proto.jpeg_frames import JPEG_HEADER_TABLE as tab

FRAG0, FRAG = 67, 56
frames, meta, wire = {}, {}, {}
for row in open("/tmp/opencode/live_now.tsv"):
    p = row.rstrip("\n").split("\t")
    if len(p) < 6 or not p[5]: continue
    d = bytes.fromhex(p[5])
    if p[1] != "192.168.169.1" or d[:2] != b"\x93\x01" or len(d) < 68: continue
    fid = struct.unpack_from("<I", d, 8)[0]
    idx, cnt, size = struct.unpack_from("<III", d, 32)
    if not (0 < cnt <= 4096 and idx < cnt): continue
    page = d[FRAG0 if idx == 0 else FRAG:]
    exp = size - (cnt - 1) * 1024 if idx == cnt - 1 else 1024
    if len(page) != exp: continue
    frames.setdefault(fid, {})[idx] = page
    meta[fid] = (cnt, size, int(struct.unpack_from("<H", d, 48)[0]) & 0xFF)
    wire[fid] = struct.unpack_from("<HH", d, 44)

def dec(jpg):
    p = tempfile.mktemp(suffix=".ppm")
    subprocess.run(["djpeg", "-ppm", "-outfile", p, "/dev/stdin"], input=jpg, capture_output=True)
    data = open(p, "rb").read(); os.unlink(p)
    return Image.open(io.BytesIO(data)).convert("RGB")

os.makedirs("/tmp/opencode/canvas480_all", exist_ok=True)
summary = []
for fid in sorted(meta):
    if len(frames.get(fid, {})) != meta[fid][0]: continue
    cnt, size, q = meta[fid]
    w, h = wire[fid]
    payload = b"".join(frames[fid][i] for i in range(cnt))
    hh = bytearray(tab.header_for(q)); hh[145:147] = struct.pack(">H", h); hh[147:149] = struct.pack(">H", w)
    im = dec(bytes(hh) + payload + b"\xff\xd9")
    im.save(f"/tmp/opencode/canvas480_all/f{fid}_h{h}_q{q}.png")
    px = im.load()
    # measure dissimilarity of the first/last rows&cols vs the next row/col (edge-band detector)
    import math
    def luma(p): return 0.299*p[0]+0.587*p[1]+0.114*p[2]
    # row diff for rows 0..7 (top band) = mean over x of |row(y)-row(y+16)|
    rowdiff = []
    for y in (0, 8, 16, 24, 32):
        s = sum(abs(luma(px[x, y]) - luma(px[x, y+16])) for x in range(0, 640, 8)) / 80
        rowdiff.append(int(s))
    coldiff = []
    for x in (0, 8, 16, 24, 32):
        s = sum(abs(luma(px[x, y]) - luma(px[x+16, y])) for y in range(0, 480, 8)) / 60
        coldiff.append(int(s))
    summary.append({"fid": fid, "q": q, "size": size, "rowdiff_top": rowdiff, "coldiff_left": coldiff})
print(json.dumps(summary, indent=1))
