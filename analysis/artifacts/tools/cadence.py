#!/home/stefan/reveng/SL_ylz/.venv/bin/python
"""Ping-cadence sweep against the live BL384: effective fps vs ping interval.

Uses the prototype transport with PING_INTERVAL_S overridden per run.
Prints frames/s, gap metrics. Short runs (12 s) to spare the battery.
"""
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path("/home/stefan/reveng/SL_ylz/prototype/src")))

from otoscope_proto.device.boliu import BoliUTransport
from otoscope_proto.telemetry import TelemetryStore


def run(interval: float, seconds: float = 12.0) -> dict:
    store = TelemetryStore("boliu")
    BoliUTransport.PING_INTERVAL_S = interval
    t = BoliUTransport("192.168.169.1", 8800, store)
    t.start()
    t0 = time.monotonic()
    tss = []
    while time.monotonic() - t0 < seconds + 2:
        evs = store.get_since(0)[0]
        for e in evs:
            if e.kind == "frame_complete":
                tss.append(e.ts)
        time.sleep(0.05)
    t.stop()
    tss = sorted(set(tss))
    tss = [x for x in tss if x >= t0]
    if len(tss) < 2:
        return {"interval": interval, "fps": 0.0, "n": len(tss)}
    span = tss[-1] - tss[0]
    gaps = [b - a for a, b in zip(tss, tss[1:])]
    burst = [g for g in gaps if g < 0.2]
    stall = [g for g in gaps if g >= 0.2]
    return {
        "interval_ms": interval * 1000,
        "n": len(tss),
        "fps": len(tss) / span if span else 0.0,
        "burst_med_ms": (statistics_median(burst) * 1000) if burst else None,
        "stall_n": len(stall),
        "stall_mean": statistics_mean(stall) if stall else None,
    }


def statistics_mean(xs):
    return sum(xs) / len(xs)


def statistics_median(xs):
    xs = sorted(xs)
    n = len(xs)
    return (xs[n // 2] if n % 2 else (xs[n // 2 - 1] + xs[n // 2]) / 2)


for iv in (0.09, 0.04, 0.02, 0.01):
    r = run(iv)
    print(f"ping={r['interval_ms']:.0f}ms frames={r['n']:3d} fps={r['fps']:5.2f} "
          f"burst_med={r['burst_med_ms'] if r['burst_med_ms'] is not None else '-'}ms "
          f"stalls>=0.2s: n={r['stall_n']} mean={r['stall_mean'] if r['stall_mean'] else 0:.2f}s")
