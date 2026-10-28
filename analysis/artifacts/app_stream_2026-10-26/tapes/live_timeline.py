#!/home/stefan/reveng/SL_ylz/.venv/bin/python
"""Combined mode with a per-second timeline: fragments vs completions."""
import sys, time, collections
sys.path.insert(0, "/home/stefan/reveng/SL_ylz/prototype/src")
from otoscope_proto.device.boliu import BoliUReportTransport, BoliUTransport
from otoscope_proto.telemetry import TelemetryStore

class PingedReport(BoliUReportTransport):
    def _ping_loop(self):
        BoliUTransport._ping_loop(self)

t = PingedReport("192.168.169.1", 8800, TelemetryStore("boliu"), report_interval=0.112)
t.start()
t0 = time.monotonic(); idx = 0
kinds = collections.Counter()
timeline = collections.defaultdict(collections.Counter)
while time.monotonic() - t0 < 14:
    now = int(time.monotonic() - t0)
    evs, idx = t.store.get_since(idx)
    for e in evs:
        kinds[e.kind] += 1
        timeline[now][e.kind] += 1
    time.sleep(0.03)
t.stop()
print("combined mode, per-second: frag=video_fragment, done=frame_complete")
for s in sorted(timeline):
    c = timeline[s]
    print(f"  {s:2d}s frag={c.get('video_fragment',0):4d} done={c.get('frame_complete',0):2d}"
          f" hb={c.get('heartbeat',0)} rep={c.get('report_ack',0)}")
print("total:", dict(kinds))
