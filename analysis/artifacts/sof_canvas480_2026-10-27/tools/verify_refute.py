#!/home/stefan/reveng/SL_ylz/.venv/bin/python
# SUPERSEDED 2026-10-27: parses the retracted d[67:] frag0 layout (FRAG0=67, adversarial-gate round 0); every band/warning number THIS script produced is an artifact of that slice — see ../frag0_layout_2026-10-27/ and doc-04 §9.9 D.
"""Independent spot-check of the refuting agent's two decisive claims:
(1) PIL is warning-blind; djpeg shows surplus entropy on tape frames.
(2) Trimming payload to (size - junk) yields byte-identical pixel output."""
import struct, io, subprocess, sys, warnings
sys.path.insert(0, "/home/stefan/reveng/SL_ylz/prototype/src")
from PIL import Image
from otoscope_proto.jpeg_frames import JPEG_HEADER_TABLE as tab

FRAG0, FRAG = 67, 56
frames, meta = {}, {}
for row in open("/tmp/opencode/live_now.tsv"):
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
        print("BOUNDARY VIOLATION", fid)
        continue
    frames.setdefault(fid, {})[idx] = page
    meta[fid] = (cnt, size, int(struct.unpack_from("<H", d, 48)[0]) & 0xFF)

complete = sorted(fid for fid, pg in frames.items() if fid in meta and len(pg) == meta[fid][0])
print(f"complete: {len(complete)}")

for fid in complete[:4]:
    cnt, size, q = meta[fid]
    payload = b"".join(frames[fid][i] for i in range(cnt))
    jpg = tab.header_for(q) + payload + b"\xff\xd9"
    # PIL warning capture
    with warnings.catch_warnings(record=True) as wrec:
        warnings.simplefilter("always")
        im = Image.open(io.BytesIO(jpg)); im.load()
    pil_warns = len(wrec)
    # djpeg
    r = subprocess.run(["djpeg", "-ppm", "-outfile", "/dev/null", "/dev/stdin"],
                       input=jpg, capture_output=True)
    djpeg_err = r.stderr.decode(errors="replace")
    # junk count from djpeg warning
    import re
    m = re.search(r"(\d+) extraneous bytes", djpeg_err)
    junk = int(m.group(1)) if m else 0
    # trimmed decode
    trimmed = tab.header_for(q) + payload[: size - junk] + b"\xff\xd9" if junk else jpg
    r2 = subprocess.run(["djpeg", "-ppm", "-outfile", "/dev/null", "/dev/stdin"],
                        input=trimmed, capture_output=True)
    clean2 = len(r2.stderr) == 0
    # pixel equality: trimmed vs full (PPM bytes)
    def ppm(b): 
        import tempfile, os
        p = tempfile.mktemp(suffix=".ppm")
        subprocess.run(["djpeg", "-ppm", "-outfile", p, "/dev/stdin"], input=b, capture_output=True)
        data = open(p, "rb").read(); os.unlink(p); return data
    equal = ppm(jpg) == ppm(trimmed) if junk else None
    # now PIL-visible? try via PIL open of trimmed (also silent?) -- just note
    print(f"fid={fid} q={q} size={size} pil_warns={pil_warns} djpeg_warn={bool(djpeg_err)} junk={junk} "
          f"trim_clean={clean2} pixels_identical={equal}")
    if not junk:
        print("   !! no extraneous-bytes warning found (regex miss?)")
    if djpeg_err:
        print("   djpeg stderr:", djpeg_err.strip().replace("\n", " | ")[:200])
