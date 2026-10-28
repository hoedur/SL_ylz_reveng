#!/home/stefan/reveng/SL_ylz/.venv/bin/python
"""Live probe: 2-record EF-02 reports — rec0 completed + rec1 in-flight
(state=0, partial LE bitmask of received pages). Does the stream sustain?"""
import sys, time, struct, collections
sys.path.insert(0, "/home/stefan/reveng/SL_ylz/prototype/src")
from otoscope_proto.device.boliu import BoliUReportTransport
from otoscope_proto.telemetry import TelemetryStore

class TwoRecordReport(BoliUReportTransport):
    def build_report2(self):
        # rec0 = completed, rec1 = in-flight (if any pending frame)
        pending_item = None
        if self._pending:
            (fkey, entry) = list(self._pending.items())[-1]
            fid_cur = fkey[0]
            mask = 0
            for idx in entry.pages:
                if idx < 64:
                    mask |= 1 << idx
            pending_item = (fid_cur, entry.cnt, mask)
        d = bytearray(88)
        d[0:4] = b"\xEF\x02\x58\x00"
        d[4:8] = self.REPORT_MAGIC
        struct.pack_into("<I", d, 8, 2)
        d[24:28] = self.REPORT_BODY_CONST
        n = self._last_completed_frame_id
        struct.pack_into("<Q", d, 32, n)          # rec0 fid u64
        struct.pack_into("<I", d, 40, 1)          # state complete
        struct.pack_into("<I", d, 44, 0x18)
        d[48:56] = b"\xFF" * 8
        if pending_item is None:
            struct.pack_into("<Q", d, 56, n + 1)  # tentative next fid
            struct.pack_into("<I", d, 64, 0)      # state in-flight
            struct.pack_into("<I", d, 68, 0x18)
            struct.pack_into("<Q", d, 72, 0)
        else:
            fid_cur, cnt, mask = pending_item
            struct.pack_into("<Q", d, 56, fid_cur)
            struct.pack_into("<I", d, 64, 0)      # state in-flight
            struct.pack_into("<I", d, 68, 0x18)
            struct.pack_into("<Q", d, 72, mask)
        return bytes(d)

    def _report_loop(self) -> None:
        if not self._bootstrap():
            return
        while not self._stop_flag.is_set():
            if self._stop_flag.wait(self._report_interval):
                return
            sock = self._sock
            if sock is None:
                return
            fid = self._last_completed_frame_id
            if fid == 0:
                continue
            payload = self.build_report2()
            try:
                sock.sendto(payload, (self.host, self.port))
            except OSError:
                return
            self._add_event("report_ack", f"{self.host}:{self.port}", len(payload),
                            {"fid": fid}, payload)

t = TwoRecordReport("192.168.169.1", 8800, TelemetryStore("boliu"), report_interval=0.038)
t.start()
t0 = time.monotonic(); idx = 0; frames = []
kinds = collections.Counter()
while time.monotonic() - t0 < 14:
    evs, idx = t.store.get_since(idx)
    for e in evs:
        if e.kind == "frame_complete": frames.append(e.ts)
        kinds[e.kind] += 1
    time.sleep(0.03)
t.stop()
print("== two-record report probe ==")
if len(frames) > 2:
    span = frames[-1] - frames[0]
    print(f"frames={len(frames)} span={span:.1f}s fps={len(frames)/span:.2f}")
else:
    print(f"frames={len(frames)}")
print("kinds:", dict(kinds))
