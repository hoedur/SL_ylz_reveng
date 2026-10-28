#!/home/stefan/reveng/SL_ylz/.venv/bin/python
# SUPERSEDED 2026-10-27: parses the retracted d[67:] frag0 layout (FRAG0=67, adversarial-gate round 0); every band/warning number THIS script produced is an artifact of that slice — see ../frag0_layout_2026-10-27/ and doc-04 §9.9 D.
"""Quantify the top-left stale band per complete tape frame:
- per-row-band mean color & interior distance
- compare band palette to frame's own interior vs other frames' snippets
"""
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

imgs = {}
for fid in sorted(meta):
    if len(frames.get(fid, {})) != meta[fid][0]: continue
    cnt, size, q = meta[fid]
    w, h = wire[fid]
    payload = b"".join(frames[fid][i] for i in range(cnt))
    hh = bytearray(tab.header_for(q)); hh[145:147]=struct.pack(">H",h); hh[147:149]=struct.pack(">H",w)
    imgs[fid] = dec(bytes(hh) + payload + b"\xff\xd9")

def band_sig(im, y0, y1, x0, x1, step=2):
    px = im.load()
    # mean color + per-pixel mean abs deviation within region (texture proxy)
    vals = [px[x,y] for y in range(y0,y1,step) for x in range(x0,x1,step)]
    n = len(vals)
    mean = [sum(v[i] for v in vals)/n for i in range(3)]
    var  = sum(sum(abs(v[i]-mean[i]) for i in range(3))/3 for v in vals)/n
    return mean, var

def dist(a, b):
    return sum(abs(a[i]-b[i]) for i in range(3))

complete = sorted(imgs)
print(f"complete frames: {complete}")
out = []
for fid in complete:
    im = imgs[fid]
    band,_   = band_sig(im, 0, 14, 0, 320)      # top band (left half)
    own_next,_ = band_sig(im, 18, 32, 0, 320)   # just below the band
    own_far,_  = band_sig(im, 200, 260, 100, 420)
    near = 0
    for ofid in complete:
        if ofid == fid: continue
        oim = imgs[ofid]
        for oy in (0, 16, 464):
            b2,_ = band_sig(oim, oy, oy+14, 0, 320)
            if dist(band, b2) < dist(band, own_next):
                near += 1
    out.append({
        "fid": fid, "q": meta[fid][2],
        "band_rgb": [round(v) for v in band],
        "below_rgb": [round(v) for v in own_next],
        "interior_rgb": [round(v) for v in own_far],
        "d(band,own_below)": dist(band, own_next),
        "d(band,own_interior)": dist(band, own_far),
        "other_frames_closer_than_own": near,
    })
print(json.dumps(out, indent=1))
