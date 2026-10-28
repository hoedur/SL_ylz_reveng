#!/home/stefan/reveng/SL_ylz/.venv/bin/python
"""H-1 live probe variant A: completion-correlated EMPTY reports.

App tape (2026-10-28) shows 122x 40-B empty EF-02 reports, burst-correlated
with fragment delivery (median 30 ms after a fragment, esp. bootstrap era).
Our standard report-mode client lacks them and the device halts ~1 s in.
This probe: after EVERY frame_complete event, immediately send ONE empty
report from the SAME socket (+ a 4x rapid-fire burst right after bootstrap).
Throwaway live-probe tooling (like live_ab.py) -- not prototype code.
"""
import sys
import time
from pathlib import Path

sys.path.insert(0, "/home/stefan/reveng/SL_ylz/prototype/src")

from otoscope_proto.device.boliu import BoliUReportTransport
from otoscope_proto.telemetry import TelemetryStore


class EmptyProbeTransport(BoliUReportTransport):
    def send_empty_now(self) -> None:
        sock = self._sock
        if sock is None:
            return
        payload = self.build_empty_report()
        try:
            sock.sendto(payload, (self.host, self.port))
            self._add_event("report_empty", f"{self.host}:{self.port}",
                            len(payload), {"nrec": 0, "probe": 1}, payload)
        except OSError:
            pass


def main(seconds: float = 12.0) -> None:
    store = TelemetryStore("boliu_probe")
    t = EmptyProbeTransport("192.168.169.1", 8800, store, report_interval=0.037)
    t.start()
    # mimic the app's bootstrap-era empty burst: 4 empties over ~0.25 s
    for _ in range(4):
        time.sleep(0.06)
        t.send_empty_now()
    t0 = time.monotonic()
    idx = 0
    frames = []
    counts = {"report_ack": 0, "keepalive_tx": 0, "heartbeat": 0,
              "malformed": 0, "report_empty": 0, "frame_dropped": 0}
    while time.monotonic() - t0 < seconds + 3:
        evs, idx = store.get_since(idx)
        for e in evs:
            if e.kind == "frame_complete":
                frames.append(e.ts)
                t.send_empty_now()          # <- variant A core
            elif e.kind in counts:
                counts[e.kind] += 1
        time.sleep(0.02)
    t.stop()
    print(f"frames={len(frames)}")
    if len(frames) > 2:
        span = frames[-1] - frames[0]
        gaps = sorted(b - a for a, b in zip(frames, frames[1:]))
        stall = [x for x in gaps if x >= 0.2]
        print(f"span={span:.2f}s -> fps={len(frames)/span:.2f}")
        if stall:
            print(f"stalls: n={len(stall)} max={max(stall):.2f}s")
    print("events:", counts)


if __name__ == "__main__":
    main(*(float(a) for a in sys.argv[1:]))
