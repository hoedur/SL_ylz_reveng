#!/home/stefan/reveng/SL_ylz/.venv/bin/python
"""D-A decisive test: rebuild frame with SOF0 h/w patched from the wire (app-native
behavior) vs our unpatched head; compare djpeg warnings, consumed entropy, pixels."""
import struct, subprocess, tempfile, os, sys
sys.path.insert(0, "/home/stefan/reveng/SL_ylz/prototype/src")
from otoscope_proto.jpeg_frames import JPEG_HEADER_TABLE as tab

FRAG0, FRAG = 67, 56

def build(path, src_port=None):
    frames, meta, wire_h = {}, {}, {}
    for row in open(path):
        p = row.rstrip("\n").split("\t")
        if len(p) < 6 or not p[5]:
            continue
        d = bytes.fromhex(p[5])
        if p[1] != "192.168.169.1" or d[:2] != b"\x93\x01" or len(d) < 68:
            continue
        fid = struct.unpack_from("<I", d, 8)[0]
        idx, cnt, size = struct.unpack_from("<III", d, 32)
        if not (0 < cnt <= 4096 and idx < cnt):
            continue
        page = d[FRAG0 if idx == 0 else FRAG:]
        exp = size - (cnt - 1) * 1024 if idx == cnt - 1 else 1024
        if len(page) != exp:
            continue
        frames.setdefault(fid, {})[idx] = page
        meta[fid] = (cnt, size, int(struct.unpack_from("<H", d, 48)[0]) & 0xFF)
        w, h = struct.unpack_from("<HH", d, 44)
        wire_h[fid] = (w, h)
    return frames, meta, wire_h

def djpeg(jpg):
    r = subprocess.run(["djpeg", "-ppm", "-outfile", "/dev/null", "/dev/stdin"],
                       input=jpg, capture_output=True)
    return r.stdout, r.stderr.decode(errors="replace")

def ppm(b): return b  # djpeg returns via /dev/null; use pipe instead

# patches: SOF0 dims at head 145..149 (BE h then BE w)
def patched_head(head, w, h):
    hh = bytearray(head)
    hh[145:147] = struct.pack(">H", h)
    hh[147:149] = struct.pack(">H", w)
    return bytes(hh)

frames, meta, wire_h = build("/tmp/opencode/live_now.tsv")
complete = sorted(f for f, pg in frames.items() if f in meta and len(pg) == meta[f][0])
print("complete:", complete)
for fid in complete[:3]:
    cnt, size, q = meta[fid]
    w, h = wire_h[fid]
    payload = b"".join(frames[fid][i] for i in range(cnt))
    for label, head in [("canvas360(ts gold)", tab.header_for(q)),
                        (f"canvas{h} (patched)", patched_head(tab.header_for(q), w, h))]:
        jpg = head + payload + b"\xff\xd9"
        r = subprocess.run(["djpeg", "-ppm", "-outfile", "/dev/null", "/dev/stdin"],
                           input=jpg, capture_output=True)
        err = r.stderr.decode(errors="replace").strip()
        # get ppm data through a temp file
        p = tempfile.mktemp(suffix=".ppm")
        subprocess.run(["djpeg", "-ppm", "-outfile", p, "/dev/stdin"], input=jpg, capture_output=True)
        ppm = open(p, "rb").read(); os.unlink(p)
        print(f"fid={fid} q={q} wire w={w} h={h}  [{label}] ppm={len(ppm)}B err='{err[:90]}'")
    print()
