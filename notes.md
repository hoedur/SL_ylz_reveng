# Portscan result on real device

stefan@arch-desktop ~ % sudo nmap -sS -sU -p- -v 192.168.169.1
Starting Nmap 7.992 ( https://nmap.org ) at 2026-10-22 23:27 +0200
Initiating ARP Ping Scan at 23:27
Scanning 192.168.169.1 [1 port]
Completed ARP Ping Scan at 23:27, 0.02s elapsed (1 total hosts)
Initiating Parallel DNS resolution of 1 host. at 23:27
Completed Parallel DNS resolution of 1 host. at 23:27, 1.00s elapsed
Initiating SYN Stealth Scan at 23:27
Scanning 192.168.169.1 [65535 ports]
SYN Stealth Scan Timing: About 50.37% done; ETC: 23:28 (0:00:30 remaining)
Completed SYN Stealth Scan at 23:28, 47.03s elapsed (65535 total ports)
Initiating UDP Scan at 23:28
Scanning 192.168.169.1 [65535 ports]
UDP Scan Timing: About 37.72% done; ETC: 23:29 (0:00:51 remaining)
Completed UDP Scan at 23:29, 49.78s elapsed (65535 total ports)
Nmap scan report for 192.168.169.1
Host is up (0.0079s latency).
Not shown: 65535 closed tcp ports (reset), 65531 closed udp ports (port-unreach)
PORT      STATE         SERVICE
67/udp    open|filtered dhcps
1234/udp  open|filtered search-agent
8800/udp  open|filtered sunwebadmin
63736/udp open|filtered unknown
MAC Address: F4:42:50:AF:D0:30 (Bouffalo Lab (Nanjing))

Read data files from: /usr/bin/../share/nmap
Nmap done: 1 IP address (1 host up) scanned in 97.93 seconds
           Raw packets sent: 131503 (6.071MB) | Rcvd: 131755 (6.326MB)
