#!/usr/bin/env python3
"""Ping-mode client for the BoliU/BL384 otoscope (live confirm session).

Binds an ephemeral UDP socket, pings device:8800 every 100 ms for ~15 s,
logs every received datagram (TSV: t sec\tsrc:port\tlen\thex). Short session
per the battery rule: exit code 0, socket closed.
"""
import socket, sys, time

DST = ("192.168.169.1", 8800)
OUT = sys.argv[1] if len(sys.argv) > 1 else "/tmp/opencode/live_prefrag0fix.pcapng"
PING = b"\xef\x00\x04\x00"
DURATION = 15.0

s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind(("0.0.0.0", 0))
s.setblocking(False)
dev_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)  # logging side only
lines = []
t0 = time.monotonic()
next_ping = t0
n_ping = 0
while time.monotonic() - t0 < DURATION:
    now = time.monotonic()
    if now >= next_ping:
        s.sendto(PING, DST)
        n_ping += 1
        next_ping = now + 0.100
    try:
        d, a = s.recvfrom(4096)
    except BlockingIOError:
        time.sleep(0.002)
        continue
    lines.append(f"{time.monotonic()-t0:.3f}\t{a[0]}:{a[1]}\t{len(d)}\t{d.hex()}")
# drain a final moment
time.sleep(0.2)
end = time.monotonic() - t0
while True:
    try:
        d, a = s.recvfrom(4096)
        lines.append(f"{time.monotonic()-t0:.3f}\t{a[0]}:{a[1]}\t{len(d)}\t{d.hex()}")
    except BlockingIOError:
        break
s.close()
with open(OUT, "w") as f:
    f.write("\n".join(lines))
frags = sum(1 for l in lines if "\t" in l and False)
print(f"pings={n_ping} recv={len(lines)} dur={end:.1f}s -> {OUT}")
