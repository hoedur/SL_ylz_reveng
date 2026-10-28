#!/home/stefan/reveng/SL_ylz/.venv/bin/python
"""H-1 live test: does EF-02 report cadence unlock the ~14 fps stream?

REQ-BOL-008 report-mode sweep against the live BL384 (192.168.169.1:8800).
Connect our host first:  iwctl station wlan0 connect Earpick-AFD030
Short runs to spare the battery; stop with Ctrl-C.

Usage: report_mode.py [report_interval ...]  (default 0.112 0.333 0.033)
"""
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path("/home/stefan/reveng/SL_ylz/prototype/src")))

from otoscope_proto.device.boliu import BoliUReportTransport
from otoscope_proto.telemetry import TelemetryStore

DEVICE = ("192.168.169.1", 8800)


def run(report_interval: float, seconds: float = 12.0) -> None:
    print(f"\n=== report_interval={report_interval:.3f}s ({1/report_interval:.1f}/s) "
          f"for {seconds:.0f}s + 3s settle ===")
    store = TelemetryStore("boliu")
    t = BoliUReportTransport(*DEVICE, store, report_interval=report_interval)
    t.start()
    t0 = time.monotonic()
    frames = []  # frame_completion ts
    counts = {"report_ack": 0, "keepalive_tx": 0, "heartbeat": 0, "malformed": 0}
    idx = 0
    while time.monotonic() - t0 < seconds + 3:
        evs, idx = store.get_since(idx)
        for e in evs:
            if e.kind == "frame_complete":
                frames.append(e.ts)
            elif e.kind in counts:
                counts[e.kind] += 1
        time.sleep(0.05)
    t.stop()
    if len(frames) > 2:
        span = frames[-1] - frames[0]
        gaps = sorted(b - a for a, b in zip(frames, frames[1:]))
        burst = [x for x in gaps if x < 0.2]
        stall = [x for x in gaps if x >= 0.2]
        print(f"frames={len(frames)} span={span:.1f}s -> effective fps={len(frames)/span:.2f}")
        if burst:
            print(f"  burst gaps: n={len(burst)} median={sorted(burst)[len(burst)//2]*1000:.0f}ms")
        if stall:
            print(f"  stalls: n={len(stall)} mean={sum(stall)/len(stall)*1000:.0f}ms")
    else:
        print(f"frames={len(frames)} (insufficient)")
    print("events:", counts)


if __name__ == "__main__":
    intervals = [float(a) for a in sys.argv[1:]] or [0.112, 0.333, 0.033]
    for iv in intervals:
        try:
            run(iv)
        except KeyboardInterrupt:
            print("\nstopped.")
            break
