#!/home/stefan/reveng/SL_ylz/.venv/bin/python
"""Content of the 480-canvas decode: top-360 equality + bottom rows + row-wise stats."""
import struct, subprocess, tempfile, os, sys, io
sys.path.insert(0, "/home/stefan/reveng/SL_ylz/prototype/src")
from PIL import Image
from otoscope_proto.jpeg_frames import JPEG_HEADER_TABLE as tab

FRAG0, FRAG = 67, 56
frames, meta, wire_h = {}, {}, {}
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
    wire_h[fid] = struct.unpack_from("<HH", d, 44)

def dec(jpg):
    p = tempfile.mktemp(suffix=".ppm")
    subprocess.run(["djpeg", "-ppm", "-outfile", p, "/dev/stdin"], input=jpg, capture_output=True)
    data = open(p, "rb").read(); os.unlink(p)
    im = Image.open(io.BytesIO(data))
    return im

def head_patched(h, w, q): 
    hh = bytearray(tab.header_for(q)); hh[145:147] = struct.pack(">H", h); hh[147:149] = struct.pack(">H", w)
    return bytes(hh)

os.makedirs("/tmp/opencode/reassembly_png480", exist_ok=True)
for fid in [2080, 2035, 2153, 2553]:
    cnt, size, q = meta[fid]
    (w, h) = wire_h[fid]
    payload = b"".join(frames[fid][i] for i in range(cnt))
    im360 = dec(tab.header_for(q) + payload + b"\xff\xd9")
    im480 = dec(head_patched(h, w, q) + payload + b"\xff\xd9")
    a360, b480 = im360.convert("RGB"), im480.convert("RGB")
    top_eq = bytes(b480.crop((0,0,640,360)).tobytes()) == bytes(a360.tobytes())
    bottom = b480.crop((0,360,640,480))
    import collections
    uniq = len(set(bytes(bottom.tobytes())[i:i+30] for i in range(0, len(bytes(bottom.tobytes()))-30, 30)))
    px = list(bottom.getdata())
    sample = [px[int(len(px)*f)] for f in (0.1,0.3,0.5,0.7,0.9)]
    def _range(r):
        vals = list(bottom.crop((0,r,640,r+1)).getdata())
        lum = [0.299*p[0]+0.587*p[1]+0.114*p[2] for p in vals]
        return int(max(lum)-min(lum))
    rowstd = [_range(r) for r in (0, 30, 60, 90, 117)]
    im480.save(f"/tmp/opencode/reassembly_png480/f{fid}_h480_q{q}.png")
    print(f"fid={fid} q={q}: top360_identical={top_eq} bottom120 uniq30B={uniq} sample={sample} rowrange={rowstd}")
