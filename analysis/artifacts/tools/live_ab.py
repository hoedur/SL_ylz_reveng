#!/home/stefan/reveng/SL_ylz/.venv/bin/python
"""Reassemble live-fix capture frames with per-frame announced-quality heads.

Reports: per-frame q / size / cnt, decode result, timing gaps between
frame completions, and saves the LAST decoded frame as PNG for the
color A/B against the app screenshot.

Slice amended 2026-10-27 (REQ-BOL-004, adversarial gate round 0):
frag0 page = d[56:len-11] — 11 TRAILING ASCII metadata bytes (the old
d[67:] slice shifted the entropy 11 B).
"""
import io
import statistics
from pathlib import Path

from PIL import Image

DATA = Path("/home/stefan/reveng/SL_ylz/prototype/src/otoscope_proto/data")
HEADS = {q: (DATA / f"jhdr_Q{q}.bin").read_bytes() for q in (5, 10, 25, 50, 75, 100)}

frags = []  # (ts, payload_bytes)
for line in Path("/tmp/opencode/live_fix.tsv").read_text().splitlines():
    parts = line.split("\t")
    if len(parts) < 4 or not parts[3]:
        continue
    try:
        d = bytes.fromhex(parts[3])
    except ValueError:
        continue
    # Per-index floors (REQ-BOL-004 amendment 2026-10-28): frag0 = 68 B, idx>0 = 57 B —
    # short last pages (57..67 B) are VALID fragments.
    if len(d) >= (68 if idx == 0 else 57) and d[0] == 0x93 and d[1] == 1:
        parts_ts = float(parts[0])
        frags.append((parts_ts, int.from_bytes(d[2:4], "little"), d))

print(f"fragment datagrams: {len(frags)}")

pending = {}
done = []  # (ts, frame_id, size, q, jpeg)
for ts, want_len, d in frags:
    if want_len != len(d):
        continue
    frame_id = int.from_bytes(d[8:12], "little")
    idx = int.from_bytes(d[32:36], "little")
    cnt = int.from_bytes(d[36:40], "little")
    size = int.from_bytes(d[40:44], "little")
    q = d[48]
    key = (frame_id, size)
    pages = pending.setdefault(key, {})
    pages[idx] = d[56 : len(d) - 11] if idx == 0 else d[56:]
    if len(pages) == cnt:
        payload = b"".join(pages[i] for i in range(cnt))
        del pending[key]
        head = HEADS[q] if q in HEADS else HEADS[100]
        done.append((ts, frame_id, size, q, head + payload + b"\xff\xd9"))

print(f"frames completed: {len(done)}")
qcount: dict[int, int] = {}
sizes = []
for ts, fid, size, q, jpeg in done:
    qcount[q] = qcount.get(q, 0) + 1
    sizes.append(size)
print("quality distribution:", dict(sorted(qcount.items())))
print(f"size: min={min(sizes)} max={max(sizes)} mean={statistics.mean(sizes):.0f}")

# decode every frame; verify geometry, count warnings-ish states
ok = 0
img = None
for ts, fid, size, q, jpeg in done:
    try:
        img = Image.open(io.BytesIO(jpeg))
        img.load()
        ok += 1
    except Exception as e:
        print(f"  FAIL fid={fid} q={q}: {e}")
print(f"decode ok: {ok}/{len(done)}")

# timing: gaps between successive frame completions
tss = [t for t, *_ in done]
gaps = [b - a for a, b in zip(tss, tss[1:])]
burst = [g for g in gaps if g < 0.2]
stall = [g for g in gaps if g >= 0.2]
span = tss[-1] - tss[0]
print(f"span={span:.2f}s effective fps={len(done)/span:.2f}")
print(f"burst gaps(<0.2s): n={len(burst)} median={statistics.median(burst)*1000:.0f}ms")
print(f"stall gaps(>=0.2s): n={len(stall)} min={min(stall):.2f}s max={max(stall):.2f}s "
      f"mean={statistics.mean(stall):.2f}s")
# stall distribution histogram
import collections
hist = collections.Counter(round(g / 0.25) * 0.25 for g in stall)
for k in sorted(hist):
    print(f"   stall ~{k:.2f}s x{hist[k]}")

# save a few likely-interesting renders: first q25, first q75, last frame
saved = set()
for ts, fid, size, q, jpeg in done:
    if q in (25, 50, 75) and q not in saved:
        try:
            im = Image.open(io.BytesIO(jpeg)).convert("RGB")
            im.save(f"/tmp/opencode/live_q{q}.png")
            saved.add(q)
        except Exception:
            pass
    if len(saved) == 3:
        break
Image.open(io.BytesIO(done[-1][4])).save("/tmp/opencode/live_last.png")
print("saved:", sorted(saved), "+ live_last.png; last frame q =", done[-1][3], "size", done[-1][2])
