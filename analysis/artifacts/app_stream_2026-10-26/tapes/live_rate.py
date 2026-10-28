#!/home/stefan/reveng/SL_ylz/.venv/bin/python
import sys, time, collections
sys.path.insert(0, "/home/stefan/reveng/SL_ylz/prototype/src")
from otoscope_proto.device.boliu import BoliUReportTransport
from otoscope_proto.telemetry import TelemetryStore

def run(ri, seconds=10.0):
    t = BoliUReportTransport("192.168.169.1", 8800, TelemetryStore("boliu"), report_interval=ri)
    t.start()
    t0 = time.monotonic(); idx = 0; frames = []
    kinds = collections.Counter()
    while time.monotonic() - t0 < seconds:
        evs, idx = t.store.get_since(idx)
        for e in evs:
            if e.kind == "frame_complete": frames.append(e.ts)
            kinds[e.kind] += 1
        time.sleep(0.03)
    t.stop()
    if len(frames) > 2:
        span = frames[-1] - frames[0]
        g = [b-a for a,b in zip(frames, frames[1:])]
        stalls = [x for x in g if x > 0.35]
        print(f"ri={ri:.3f}: frames={len(frames)} span={span:.1f}s fps={len(frames)/span:.2f}"
              f" stalls>350ms={len(stalls)} maxgap={max(g)*1000:.0f}ms")
    else:
        print(f"ri={ri:.3f}: frames={len(frames)}")
    print(f"   rep_tx={kinds.get('report_ack',0)}/{seconds:.0f}s hb={kinds.get('heartbeat',0)} frag={kinds.get('video_fragment',0)}")

if __name__ == "__main__":
    for ri in [float(x) for x in sys.argv[1:]]:
        run(ri)
        time.sleep(3)
