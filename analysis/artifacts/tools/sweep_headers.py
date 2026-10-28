#!/home/stefan/reveng/SL_ylz/.venv/bin/python
"""Decode captured frame payloads with every embedded JPEG header (Q5..Q100).

For each header: assemble jhdr + payload + FF D9, decode with PIL, and report
structural result (warnings/errors) plus image statistics that discriminate the
correct quantization table:
  - luma std (contrast)
  - chroma spread (saturation proxy): mean abs U/V deviation from 128
  - raw byte stats of the DQT values in the header
"""
import io
import warnings
from pathlib import Path

from PIL import Image

ART = Path("/home/stefan/reveng/SL_ylz/analysis/artifacts")
QS = [5, 10, 25, 50, 75, 100]


def dqt_stats(header: bytes) -> list[tuple[str, int, int]]:
    """Parse DQT segments; return (table_id, min, max) per table."""
    out = []
    i = 0
    while i < len(header) - 4:
        if header[i] == 0xFF and header[i + 1] == 0xDB:
            seg_len = int.from_bytes(header[i + 2 : i + 4], "big")
            seg = header[i + 4 : i + 2 + seg_len]
            p = 0
            while p < len(seg):
                pq = seg[p] >> 4
                tq = seg[p] & 0x0F
                vlen = 64 if pq else 128  # wrong for 8-bit but harmless bounds
                vals_start = p + 1 + 64 * (pq and 0 or 0)
                n = 64
                vals = seg[p + 1 : p + 1 + n]
                if pq:
                    n = 128
                    p += 1 + 128
                    p = p  # 16-bit tables unlikely here
                    p_out = True
                else:
                    p += 1 + 64
                if vals:
                    out.append((f"t{tq}", min(vals), max(vals)))
                if pq:
                    break
        else:
            i += 1
            continue
        i += 2 + seg_len
    return out


def stats(img: Image.Image):
    rgb = img.convert("RGB")
    px = list(rgb.getdata())
    n = len(px)
    mr = sum(p[0] for p in px) / n
    mg = sum(p[1] for p in px) / n
    mb = sum(p[2] for p in px) / n
    lum = [(0.299 * p[0] + 0.587 * p[1] + 0.114 * p[2]) for p in px]
    mlum = sum(lum) / n
    lstd = (sum((l - mlum) ** 2 for l in lum) / n) ** 0.5
    # saturation proxy: mean chroma deviation from neutral
    chroma = (sum(abs(p[0] - p[1]) + abs(p[1] - p[2]) for p in px) / n)
    return mr, mg, mb, mlum, lstd, chroma


for fname in ["frame0.bin", "frame1.bin", "frame2.bin", "frame3.bin"]:
    payload = (ART / fname).read_bytes()
    print(f"\n=== {fname} ({len(payload)} B payload) ===")
    for q in QS:
        header = (ART / f"jhdr_Q{q}.bin").read_bytes()
        jpeg = header + payload + b"\xff\xd9"
        dt = dqt_stats(header)
        with warnings.catch_warnings(record=True) as wlist:
            warnings.simplefilter("always")
            try:
                img = Image.open(io.BytesIO(jpeg))
                img.load()
                mr, mg, mb, mlum, lstd, chroma = stats(img)
                ws = "; ".join(str(w.message)[:60] for w in wlist)
                print(
                    f"  Q{q:>3}: OK size={img.size} mean=({mr:5.1f},{mg:5.1f},"
                    f"{mb:5.1f}) lum_std={lstd:6.2f} chroma={chroma:5.2f} "
                    f"dqt={dt} warn={ws}"
                )
                if q == 75:
                    out = Path(f"/tmp/opencode/{fname}.Q75.png")
                    img.convert("RGB").save(out)
            except Exception as e:
                dt = dqt_stats(header)
                print(f"  Q{q:>3}: FAIL {type(e).__name__}: {str(e)[:80]} dqt={dt}")
