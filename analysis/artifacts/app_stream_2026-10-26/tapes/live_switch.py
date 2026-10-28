#!/home/stefan/reveng/SL_ylz/.venv/bin/python
"""Phase switch: ping-only bootstrap -> reports only. Does the stream survive
without pings, and at what fps? (H-1 with app-exact semantics.)"""
import sys, time, collections
sys.path.insert(0, "/home/stefan/reveng/SL_ylz/prototype/src")
from otoscope_proto.device.boliu import BoliUReportTransport
from otoscope_proto.telemetry import TelemetryStore

class SwitchablePing(BoliUReportTransport):
    def __init__(self, *a, **kw):
        super().__init__(*a, **kw)
        self.ping_on = True

    def _ping_loop(self):
        while not self._stop_flag.wait(self.PING_INTERVAL_S):
            sock = self._sock
            if sock is None:
                break
            if not self.ping_on:
                continue
            try:
                sock.sendto(self.PING_PAYLOAD, (self.host, self.port))
            except OSError:
                break
            self._add_event("ping", f"{self.host}:{self.port}",
                            len(self.PING_PAYLOAD), {"bytes": self.PING_FIELD_HEX},
                            self.PING_PAYLOAD)

t = SwitchablePing("192.168.169.1", 8800, TelemetryStore("boliu"), report_interval=0.112)
t.start()
t0 = time.monotonic(); idx = 0; frames = []
kinds = collections.Counter(); phase = "A-ping-only"
b_switch = 0.0
while time.monotonic() - t0 < 20:
    now = time.monotonic() - t0
    if phase == "A-ping-only" and now >= 6:
        t.ping_on = False
        phase = "B-reports-only"
        b_switch = now
    evs, idx = t.store.get_since(idx) if hasattr(t, "store") else (None, idx)
    if evs is None:
        break
    for e in evs:
        if e.kind == "frame_complete":
            frames.append((e.ts, now))
        kinds[e.kind] += 1
    time.sleep(0.03)
t.stop()

fa = [ts for ts, at in frames if at <= b_switch]
fb = [ts for ts, at in frames if at > b_switch]
print(f"phase A (ping-only, 0..{b_switch:.1f}s): {len(fa)} frames")
if len(fa) > 2:
    print(f"  fps={len(fa)/(fa[-1]-fa[0]):.2f}")
print(f"phase B (reports only, {b_switch:.1f}s..): {len(fb)} frames")
if len(fb) > 2:
    span = fb[-1] - fb[0]
    print(f"  span={span:.1f}s fps={len(fb)/span:.2f}")
print("kinds:", dict(kinds))
