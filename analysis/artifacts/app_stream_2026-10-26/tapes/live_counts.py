#!/home/stefan/reveng/SL_ylz/.venv/bin/python
"""Count ALL event kinds during a run — do fragments flow at all?"""
import sys, time, collections
sys.path.insert(0, "/home/stefan/reveng/SL_ylz/prototype/src")
from otoscope_proto.device.boliu import BoliUReportTransport, BoliUTransport
from otoscope_proto.telemetry import TelemetryStore

def run(mode, seconds=14.0, report_interval=0.038):
    store = TelemetryStore("boliu")
    if mode == "ping":
        t = BoliUTransport("192.168.169.1", 8800, store)
    else:
        t = BoliUReportTransport("192.168.169.1", 8800, store, report_interval=report_interval)
    t.start()
    t0 = time.monotonic(); idx = 0; frames = []
    kinds = collections.Counter()
    while time.monotonic() - t0 < seconds:
        evs, idx = store.get_since(idx)
        for e in evs:
            if e.kind == "frame_complete":
                frames.append(e.ts)
            kinds[e.kind] += 1
        time.sleep(0.03)
    t.stop()
    print(f"== mode={mode} {seconds:.0f}s ==")
    if len(frames) > 2:
        span = frames[-1] - frames[0]
        print(f"frames={len(frames)} span={span:.1f}s fps={len(frames)/span:.2f}")
    else:
        print(f"frames={len(frames)}")
    print("  kinds:", dict(kinds))

if __name__ == "__main__":
    run(sys.argv[1] if len(sys.argv) > 1 else "ping")
