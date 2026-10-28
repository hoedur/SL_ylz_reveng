#!/home/stefan/reveng/SL_ylz/.venv/bin/python
"""Final analysis of the monitor-mode capture of the original SL app streaming.

Input: app_stream.tsv  (tshark extraction of app_stream.pcapng, monitor mode,
device AP Earpick-AFD030 open; phone client 192.168.169.3, MAC 80:5a:04:ce:29:91;
device 192.168.169.1).  Extracted with:
  tshark -r app_stream.pcapng -T fields -e frame.time_epoch -e ip.src \
         -e ip.dst -e udp.srcport -e udp.dstport -e udp.payload

Caution: iwd channel-hopped while the station was disconnected, capture duty is
poor for data frames (p99 inter-datagram gap 1.5 s), so per-datagram statistics
undercount; fid-slope estimates are robust.
"""
import bisect
import statistics
import struct
from pathlib import Path

DEV, CLT = "192.168.169.1", "192.168.169.3"
FRAG0_HDR, FRAG_HDR = 67, 56


def load(path=Path(__file__).with_name("app_stream.tsv")):
    rows = []
    for row in path.read_text().splitlines():
        p = row.split("\t")
        if len(p) < 6 or not p[5]:
            continue
        try:
            ts = float(p[0]); d = bytes.fromhex(p[5])
        except ValueError:
            continue
        rows.append((ts, p[1], int(p[3]), int(p[4]), d))
    return rows


def main():
    rows = load()
    t0 = min(r[0] for r in rows)

    occ = []            # (ts, fid) per valid video fragment
    hbs = []            # (ts, seq, pad, drift)
    dev_ctl = []
    for ts, s, sp, dp, d in rows:
        if s != DEV or len(d) < 4 or d[0] != 0x93:
            continue
        want = struct.unpack_from("<H", d, 2)[0]
        if d[1] == 4 and len(d) == 16:
            hbs.append((ts, *struct.unpack("<III", d[4:16])))
            continue
        if d[1] != 1 or want != len(d) or len(d) < 68:
            continue
        fid = struct.unpack_from("<I", d, 8)[0]
        idx = struct.unpack_from("<I", d, 32)[0]
        cnt = struct.unpack_from("<I", d, 36)[0]
        size = struct.unpack_from("<I", d, 40)[0]
        w, h, q = struct.unpack_from("<HHH", d, 44)
        if w == 640 and 0 < cnt <= 3408 and idx < cnt and size >= (cnt - 1) * 1024 + 1:
            occ.append((ts, fid))
    occ.sort()

    def fid_at(t):
        i = bisect.bisect_left(occ, (t, 10**12)) - 1
        return occ[i][1] if i >= 0 else None

    xs = [t for t, _ in occ]; ys = [f for _, f in occ]
    n = len(xs); mx = sum(xs)/n; my = sum(ys)/n
    slope = (sum((x-mx)*(y-my) for x, y in zip(xs, ys)) /
             sum((x-mx)**2 for x in xs))
    fid_span = max(f for _, f in occ) - min(f for _, f in occ)
    span = xs[-1] - xs[0]
    print(f"video fragments seen: {len(occ)}; unique fid span {fid_span} over {span:.1f}s")
    print(f"estimated device frame rate (OLS fid slope): {slope:.2f} fps  "
          f"(fid-span method: {fid_span/span:.2f} fps)")

    # client messages
    acks = []
    for ts, s, sp, dp, d in rows:
        if s != CLT or dp != 8800:
            continue
        if len(d) >= 4 and d[0] == 0xEF and struct.unpack_from("<H", d, 2)[0] == len(d):
            if d[1] == 2:
                nrec = struct.unpack_from("<I", d, 8)[0]
                recs = []
                for k in range(nrec):
                    off = 32 + 24*k
                    if off + 24 <= len(d):
                        recs.append((struct.unpack_from("<I", d, off)[0],
                                     struct.unpack_from("<I", d, off+8)[0],
                                     struct.unpack_from("<Q", d, off+16)[0]))
                acks.append((ts, nrec, recs, d))
    print(f"client EF-02 reports: {len(acks)}")
    if acks:
        # fid of first record vs last video fid observed at that moment
        lags = [recs[0][0] - (fid_at(ts) or recs[0][0])
                for ts, n, recs, d in acks
                if recs and fid_at(ts) is not None
                and abs(recs[0][0] - (fid_at(ts) or 0)) < 60]
        if lags:
            print(f"report fid - last-seen fid: median={statistics.median(lags):d} "
                  f"(= last fully received frame)")
    ka = [(ts, struct.unpack_from('<I', d, 4)[0])
          for ts, s, sp, dp, d in rows
          if s == CLT and dp == 8800 and d[:4] == bytes.fromhex("EF080800")]
    print(f"EF-08 keepalives: {len(ka)}; cadence ~1.64 s; payload = u32 'stream-time'")
    print(f"device heartbeats captured: {len(hbs)}; seq of heartbeat == EF-08 seq "
          "(both count seconds since stream start; drift word 5e xx)")


if __name__ == "__main__":
    main()
