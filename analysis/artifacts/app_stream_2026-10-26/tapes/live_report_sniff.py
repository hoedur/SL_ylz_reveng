#!/home/stefan/reveng/SL_ylz/.venv/bin/python
import sys, time, struct, collections, socket
sys.path.insert(0, "/home/stefan/reveng/SL_ylz/prototype/src")
from otoscope_proto.device.boliu import BoliUReportTransport
from otoscope_proto.telemetry import TelemetryStore

STALE = (43875, 38605)
sniffers = []
for p in STALE:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        s.bind(("192.168.169.2", p));
        s.setblocking(False)
        sniffers.append((p, s))
    except OSError as e:
        print("cannot bind", p, e)
s_all = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s_all.bind(("192.168.169.2", 49999))
s_all.setblocking(False)

t = BoliUReportTransport("192.168.169.1", 8800, TelemetryStore("boliu"), report_interval=0.038)
t.start()
t0 = time.monotonic(); idx = 0
kinds = collections.Counter(); stale_hits = collections.Counter()
timeline = collections.defaultdict(collections.Counter)
while time.monotonic() - t0 < 14:
    evs, idx = t.store.get_since(idx)
    for e in evs:
        kinds[e.kind] += 1
        timeline[int(time.monotonic()-t0)][e.kind] += 1
    for p, s in sniffers:
        try:
            d = s.recv(2048)
            stale_hits[p] += 1
        except BlockingIOError:
            pass
t.stop()
for _p, s in sniffers: s.close()
print("== report-mode run with stale-port sniffers ==")
for s in sorted(timeline):
    c = timeline[s]
    print(f"  {s:2d}s frag={c.get('video_fragment',0):4d} done={c.get('frame_complete',0):2d} rep={c.get('report_ack',0):3d} hb={c.get('heartbeat',0)}")
print("kinds:", dict(kinds))
print("datagrams into STALE ports:", dict(stale_hits))
