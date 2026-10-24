# Live-device validation of the BoliU/BouffaloLab streaming stack (Phase-0 packet capture)

**Status:** empirical results from live probing of the actual otoscope unit on 2026-10-22/23, cross-checked
against static APK knowledge. Read together with `01-arc42-architecture.md` §10/§10a (mandatory corrections
proposed in §8 below — **not yet applied**).

**Device under test:** SL+ ear-cameras unit, IP `192.168.169.1` (WiFi AP, gateway of DHCP to client
`192.168.169.2` on `wlan1`, MAC `00:60:b3:b2:91:88`), device MAC `f4:42:50:af:d0:30`.
All evidence files in `analysis/artifacts/` (pcapng captures, extracted frame bins, JPEG header bins,
failed decode sample, full disassembly listing `bl.asm` of `libbl_vii_jni.so`; the 2026-10-24 session
added `raw2.bin`, `fps1.tsv`, `motion.tsv` and the successful decodes under `decoded/`).

> Probes were run with `tshark` (passive) + throwaway Python UDP sockets (active). No packets were ever
> sent to anything but `192.168.169.1` UDP unicast. Device was powered off by the user before the last
> (failed) continuous-stream test, so that test is inconclusive — redo list in §7.

---

## 1. Hardware identification — corrects the "Beken" label

| Fact | Evidence |
|---|---|
| Device MAC OUI `F4:42:50` = **Bouffalo Lab (Nanjing)** | pcap `cap1.pcapng: eth.src=f4:42:50:af:d0:30` |
| This matches the APK's **BoliU** drivers exactly: `com.xiaozhen.beauty.lib.jpeg.BlSdk` (log tag **BL384**), native `libbl_vii_jni.so` | strings in `.so`: `jpeg server end!`, `BL384`, `get_ip_port` |
| TCP: **zero open ports** (`nmap -sS -p-`: all 65535 closed/reset) → the APK's `com.xiaozhen.beauty.lib.tcp.CmdDataServer` / **TCP 2271 does not exist on this firmware** | `notes.md` nmap output |
| UDP listeners (open\|filtered): **67 (DHCP server), 1234, 8800, 63736** | `notes.md` |
| The APK's Java **Beken** path (`BekenSdk`, UDP 7080, local bind 7080, 2-byte datagrams `{0x20,0x36}` start / `{0x20,0x37}` stop / `{0x30,0x67}`/`{0x30,0x68}` voice) was **sent live to device ports 7080, 1234, 8800, 63736 — zero responses, zero stream ever triggered** | `probe1.pcapng` |
| Device answers our stray UDP (e.g. DNS on port 53) with ICMP port-unreachable — it *does* close uncaught UDP sockets, so "open\|filtered" = real listeners | `cap2.pcapng` |

**Conclusion:** this unit is a **Bouffalo Lab BoliU-class ("BL384") device**, not Beken. The streaming
protocol is the one implemented in `libbl_vii_jni.so`, not the Java Beken stack. UDP 7080 is not part of
this device's protocol at all (7080 appears only once, inside `libUVCCamera.so`).

## 2. Idle state: the 16-byte heartbeat

Without any client active (or with our sockets unbound), the device pushes every **1.60 s**:

```
192.168.169.1:1234 → 192.168.169.2:47922, TLUDP len 16
payload: 93 04 10 00 <seq u32 LE>  04 00 00 00  5e <xx> 00 00
```
- `93` = device→phone packet magic (§3), `04` = msg type, `10 00` = 16 = packet length (LE16).
- `[4..7]` = sequence counter, +1 per beat (`5b 05 00 00` → `83 06 00 00` over ~70 s ≈ 0.6 beats/s ✓).
- `[8..11]` = u32 constant 4; `[12..15]` = `5e 38 00 00`→`5e 32 00 00…` slow drift — **suspected sensor/status word, not yet confirmed** (see §7 rotation test).
- The destination port `47922` is **sticky**: the device remembers the (ip, port) of the *last active viewer socket* across sessions and keeps poking it. Merely sending 2 garbage bytes from a fresh port did **not** re-target the heartbeat (`probe2.pcapng`).
- Same framing is used for the video packets (§4): `[0x93][type][len LE16]`.

## 3. Native protocol (static RE of `libbl_vii_jni.so`, symbols unstripped)

Disassembly in `analysis/artifacts/bl.asm` (created with `arm-none-eabi-objdump` / capstone — `pip install` added **capstone** and **pillow** to `.venv` this session).

### 3.1 Connection model (`create_instance`, called from `BlSdk_onStart` JNI)

```
Java_…BlSdk_onStart(env, this, jstring)  →  create_instance(0, hostString, "8800")
```
- Device command/data port hardcoded: **UDP 8800** (string `8800` @ .rodata `0x4644`, passed as `getaddrinfo` service for the *peer*; host string `0.0.0.0` @ `0x46b5` for the *local* bind with NULL service → **phone binds an ephemeral UDP port**).
- Phone *learns* nothing; the **device** learns the phone's ip:port from the first valid datagram and then targets video + heartbeat there (see §4, §5).
- Instance struct (offsets pinned in disasm): `+4 = fd`, `+8 = peer sockaddr(16)`, `+0x7c = pthread_mutex`, command queue `+56`, fragment bitmap + jpeg-header slot and frame records live at `+0xa4`-relative offsets (exact base layout partially resolved; ring of 4 frame records indexed by `(idx-1)&3`).
- Log strings present: `BL384`, `----------- Sending start`, `-----------to 38.4HZ:%d`, `------------ Resetting`, `WARN: unknown msg type: %d`, `----------MCU_MSG_PROTO_CTLMSG invalid------`.

### 3.2 Packet framing (both directions)

* device→phone: `[0x93][msg_type][len LE16]…` — `thread_recv` requires `len == datagram length`; `msg_type` ∈ 1..8 dispatched via a Thumb `TBB` at `0x1fa0` (table bytes `04 0f 14 1a 14 14 14 1f`; the exact type→handler mapping could not be fully pinned from the listing — see §7) into `handle_mcu_msg_frag`, `handle_mcu_msg_ack`, `handle_mcu_msg_ctlmsg`, `handle_mcu_msg_queryinfo_resp`.
* phone→device: `[0xEF][msg_type][len LE16]…`

| phone→device packet | bytes | source |
|---|---|---|
| **"start" keep-alive** | `EF 00 04 00` (type 0, len 4, no payload) — re-sent every time no frame arrived for ≥101 ms | `thread_timer` builds word `0x0004_00EF`, logs `----------- Sending start` |
| ACK / status | `EF 02 …` + fixed body `02 02 00 01`, per-entry 16-byte records, `sendto(fd, …, inst+8 peer)` | `build_send_ack` |
| command enqueue | `EF 04 <total_len LE16> …(payload)` queued at inst+56, drained & sent by `thread_ctl` | partially decoded |
| **queryinfo** | `EF 10 08 00 <u32 arg>` (8 bytes total) | `mjpeg_ndk_queryinfo_cmd_send` |

Exported mirror names confirm the structure: `mjpeg_ndk_startup/stop/command_send/queryinfo_cmd_send/ctlmsg_cb_register/frame_callback_register/set_QPara/set_active_camera_index`, `get_ip_port/get_ip_str`, `handle_mcu_msg_*`, `build_send_ack` (`nm -D`).

### 3.3 JPEG headers embedded in the library

`nm` gives `jpeg_header_640x360_Q5@0x4c1a, Q10@0x4e77, Q25@0x50d4, Q50@0x5331, Q75@0x558e, Q100@0x57eb`
(→ `analysis/artifacts/jhdr_Q*.bin`). All six are **607-byte JPEG heads ending right after the SOS marker**:
`FFD8 FFE0(APP0) FFDB(DQT) FFDB FF C0(SOF0: 640×?) FFC4(DHT)×N FFDA(SOS)`. The dispatch compares the device-announced
quality against exactly `05 0a 19 32 4b 64` (= 5,10,25,50,75,100 — the constant table sits right after the
`_len` symbols @ `0x5a58`) and `memcpy`s the matching header to the frame buffer (`inst+0xa4`), appending
`0xFF 0xD9` (EOI) after the last fragment (`movw r1,#0xd9ff; strh` @ `0x266a`). So the **device never sends a
JPEG header**; the phone-side supplies DQT/DHT/SOF from the embedded table based on the announced quality.
`libjpeg-turbo212.so` is a stock libjpeg decode API (no custom symbols).

## 4. Device→phone video packets (empirical, `cap_jpeg.pcapng`; field map **re-derived 2026-10-24 from `raw2.bin`**)

After sending **8× `EF 00 04 00` to UDP 8800** from an ephemeral port (55555), the device immediately
streams fragments `192.168.169.1:1234 → phone port`:

```
[93][01][len LE16]          ← 4-byte transport header, len == whole datagram
[52-B field block / 56-B data boundary]  ← offsets below; frag0 header = 67 B (incl. 15-B extension)
[1024 bytes scan data]      ← exactly, except the last fragment of a frame
```

**Authoritative fragment field map** (offsets **within the UDP payload**, i.e. including the 4 transport
bytes; verified byte-for-byte on the 2026-10-24 capture `artifacts/raw2.bin`, 29/29 frames consistent):

| off | type | meaning | observed |
|---|---|---|---|
| 0..3 | — | transport: `0x93`, type=1, len LE16 == datagram length | frag0=1091, mid=1080, last=52+r |
| 4..7 | — | fixed signature `02 02 00 01` (= body of the *phone's* `build_send_ack` too) | const |
| 8..11 | u32 | frame alternation id (1 / 2) | flips per frame |
| 12..15 | u32 | 0 | const |
| 16..19 | u32 | duplicate of frame id | matches [8] |
| 20..31 | — | 0 | const |
| 32..35 | u32 | **fragment index**, 0-based | 0..cnt−1 |
| 36..39 | u32 | **fragment count** = `ceil(frame_size/1024)` | 22 for 21 962 B ✓ |
| 40..43 | u32 | **frame size in bytes** | 14059..33634 |
| 44..45 | u16 | width = 640 (`0x0280`) | const |
| 46..47 | u16 | height field = 480 (`0x01E0`) — **misleading**, real JPEG is 640×360 (§5b) | const |
| 48..49 | u16 | quality/status word: low byte = quality (`0x19`=25, `0x4b`=75 …), high byte mirrors frame id−1 | 0x004b / 0x014b |
| 50..51 | u16 | 2 | const |
| 52..55 | u32 | frag0 only: `0x0438000b` — low u16 = **11** = extra-byte count, high u16 = 1080 (`0x0438`) | 0 elsewhere |
| 56..66 | — | frag0 only: **11 varying extra bytes** — purpose unknown | varies |
| 56/67.. | — | page data: frag0 from datagram byte **67** (1024 B), others from byte **56** (1024 B, last = remainder) | |

Datagram budget (constant per frame): frag0 = **1091** (= 67+1024), mid = **1080** (= 56+1024),
last = 56+remainder. Σ(overhead) = 67+20·56+56 = **1243** for cnt=22 — verified identical on **all 29
frames** in `raw2.bin` (overhead distribution: `{1243: 29}`); Σ(data) = declared `size` exactly.

Datagram budget (constant per frame): frag0 = **1091** (= 67+1024), mid = **1080** (= 56+1024),
last = 56+remainder. Σ(overhead) = 67+20·56+56 = **1243** for cnt=22 — verified identical on **all 29
frames** in `raw2.bin` (overhead distribution: `{1243: 29}`); Σ(data) = declared `size` exactly.

Verified arithmetic per frame: with the first fragment treated as a 67-byte header (52 common + 15 frag0 extension) + 1024 B and the rest as 56-byte header + remainder, Σ(datalen) equals the header `size` field exactly in four legacy frames: 14059 / 20932 / 33518 / 33634 ✓, and all 29 frames of the 2026-10-24 capture ✓. Fragments arrive **out of order** → phone reorders via per-index bitmap (the `lsrs #5 / and #0x1f / orrs` bit-set loops in `handle_mcu_msg_frag`).

In the ~40 s capture: 101 big fragments = **4 complete frames** ~0.6–0.1 fps under the burst-start scheme.

### 4a. Frame rate under continuous pinging (2026-10-24, `artifacts/fps1.tsv`, 30 s @ 90 ms pings)

- 115 frame starts, **96 fully received** (all 21-fragment ≈ 21 kB frames; the scene was static).
- Frame transmission is bursty: blocks of 1–4 frames at **30–45 ms** spacing (~25 fps intra-burst)
  separated by ~**0.45–0.52 s** idles. Effective rate ≈ **3.2 fps** (static scene).
- Under vigorous motion (`artifacts/motion.tsv`, 20 s): 72 starts, sizes 12 264–30 259 B (mean 23 033);
  same burst/stall cadence → the 0.5 s stalls are **device-side chunky frame delivery**, not
  motion-dependent encode time. Real-time feel needs continuous display-side buffering.
- Frame sizes are motion-dependent (-quality JPEG, bigger when moving), fragment geometry identical.

## 5. The one empirical handshake that works

```
for i in 1..8:   s.sendto(b'\xEF\x00\x04\x00', ('192.168.169.1', 8800)); sleep(0.12)
then:            recv on the same ephemeral socket
```
→ immediate video stream from `:1234`. Nothing else (Beken datagrams, garbage bytes, different dports) produced any reaction. Revised 2026-10-24: the `EF 00 04 00` payload is **not strictly validated** — sending 8 bytes of garbage to UDP **8800** also (re)starts/redirects the stream to the sender's socket; ports **1234 and 63736** ignore everything (probed 2026-10-24, no response even to valid EF packets). The stream target = the socket that last sent a datagram to 8800.

**Ping-serve model (2026-10-24, silent-listen test):** after a *single* `EF 00 04 00` the device delivers
only ~1 frame (2 frame starts, ~24.5 kB each) within the first ~2 s and then goes silent — heartbeats
continue. Sustained streaming requires a datagram stream from the client (the app does this at ≤101 ms
intervals — `thread_timer`'s "no frame for 101 ms → send start" logic). Effective behaviour: **each
datagram to 8800 arms delivery of (at least) the next frame**; the FOSS client should ping at ~90 ms.

## 5b. JPEG decoding SOLVED (2026-10-24) — frames are plain JPEG; the phone re-sends its own header

The earlier "transformed scan data" hypothesis is **wrong**. The frame payload is untouched JPEG
*entropy-coded scan data* — it just has **no SOI/header** because the phone is supposed to prepend one of
the embedded 607-byte `jpeg_header_640x360_Qx` heads and append `FF D9` (§3.3).

**Working recipe** (validated on 29/29 frames of the 2026-10-24 capture **and** all 4 legacy
`artifacts/frame0..3.bin`):

```
jpeg = artifacts/jhdr_Q100.bin  +  Σ fragment-page data (1024 B each, last one short)  +  FF D9
```

- Decodes to a **640×360 RGB** camera image (PIL / stock libjpeg). The "scan-data transform" that was
  hunted in §7 is a non-issue: the reason yesterday's Q-header attempt failed was a **wrong header** and
  a mis-offset reassembly (67-byte frag0 header including the 15-byte extension, data off by the 11 extra bytes — now pinned by §4).
- **Q100 header works while the announced quality byte is 0x4b (=75).** Q5..Q75 all fail with
  "broken data stream". Reading: the finer Q100 quantization table tolerates the actual coefficient
  magnitudes; i.e. empirically the device streams at the Q100 table. The FOSS client should simply
  always use the Q100 head (or try heads in best-match order).
- The attribute used to key the header lookup (the `quality` u16 @48, per §4 field map) does **not**
  map 1:1 to the header that decodes — do not trust it for decode.
- 21 962-byte frame for a 640×360 image ≈ 0.77 bpp: plausible for the dark/covered-lens scene.
- Byte statistics of the raw page data (no leading FFD8, FF frequency 0.10 %, all 22 FF instances are
  FF00-stuffed pairs, entropy 7.635 bits/byte) are exactly what hidden/stuffed JPEG entropy data looks like.
- Sample decodes: `artifacts/decoded/art_frame0.png`, `art_frame2.png`, `dec_21962_1_q75.png`.

Negative results from the hunt (recorded for completeness): XOR-constant sweep (256 keys), whole-buffer
bit-reverse, nibble-swap, 16-bit byte-swap — none decode; none needed.

## 6. What does *not* match the current arc42 doc / component map

1. **Chip family:** doc says "Beken" + UDP 7080 + TCP 2271 gyro; live device is **Bouffalo Lab BoliU**, UDP-only, cmd/data port **8800**, no TCP anywhere.
2. **Video framing:** doc claims ≤1472-byte fragments with `picId@2/pkType@3` into a 102400-byte buffer. Actual BoliU wire: ≤**1091**-byte datagrams `[93][01][len16]` + 56-byte fragment header (67 on frag0, incl. 15-byte extension) + **1024-byte** pages; frame size announced per frame; fragment count/size/idx in the header; JPEG headers are **not transmitted** but inserted phone-side; **actual decode uses the Q100 head (§5b)**, real resolution 640×360.
3. **Control commands:** the two-byte `{0x20,0x36}` datagrams are the *Beken Java* protocol and are ignored by this device; the working control is `EF 00 04 00` @ UDP 8800 (payload effectively unvalidated — any datagram to 8800 re-arms streaming, §5), plus the `EF 02…` ack and `EF 10…` queryinfo channel.
4. **Heartbeat/orientation:** doc's TCP 2271/`CmdDataServer` doesn't exist here; a 16-byte `type-4` UDP beat every 1.6 s exists instead (drift word **not accelerometer** — see §7.2).

## 7. Open questions / retest list — status after the 2026-10-24 session

1. **Continuous fps** — ✅ done: ~3.2 fps effective (static), bursts at ~25 fps + ~0.5 s device-side stalls (§4a).
2. **Heartbeat semantics** — mostly done: the beat **re-targets the active streaming socket** (19 beats received on a brand-new port in one 30 s run; sticky-port model confirmed). The drift word `5e xx 00 00` is **not a direct accelerometer reading**: it changed by only one LSB (0x49→0x48) during 20 s of vigorous waving; yesterday it drifted 0x32↔0x38 over ~70 s idle. Looks like a slow counter/statistic (temperature? battery? signal?). Open: exact semantics; also the `[4..7]` field that yesterday incremented +1 per beat showed a **constant 0x00000001 for the whole window** after the device rebooted mid-test today (needs one more lap after the next power-cycle).
3. **Scan-data transform** — ✅ SOLVED, was a phantom (§5b): JPEG frames decode with `jhdr_Q100` head + pages + `FFD9`.
4. **Height 480 vs "640x360"** — ✅ resolved: the height header field (480) is bogus/unused; actual JPEG SOF (both in the embedded headers and the decoded output) is **640×360**.
5. **UDP 63736** — ❌ unresolved: accepts nothing (no reaction to EF packets or garbage; also nothing arrives when bound locally).
6. **First-fragment 11 extra bytes** — ❌ purpose still unknown (11 varying bytes at payload offset 56..66, right before frag0's page data; the count is announced in the frag0-only u32 @52).
7. Exact `TBB` type→handler map and the literal-pool pairs (`0x261c–0x263c`) — ❌ still unresolved (static-only).

## 8. Proposed changes to existing docs — ✅ approved & applied 2026-10-24

All proposed edits were folded into the other documents on 2026-10-24 (§10b in the arc42 doc,
§2a live trace + boundary-table updates in the component map, re-scoped §1/§2.2/§2.5/§2.6/§3/§4 in
the reimplementation proposal, and an updated "Established protocol facts" + tooling notes in
`AGENTS.md`). Note: an `OPENCODE.md` does not exist in this repo — its planned content (protocol
essentials + venv tooling) was placed into `AGENTS.md`, which is the file the harness actually loads.

- `01-arc42-architecture.md` §10: add "§10b Empirically validated live protocol (BoliU/BL384 unit)" with §§1–5 above; restate §10 Beken/7080/TCP 2271 facts as *shipped-APK-source-derived, not applicable to the BL384 unit*.
- `01-arc42-architecture.md` §10a: the "no device-config protocol" finding gains live corroboration — but note that `BlSdk` (`BL384SDK`) is precisely the driver this device needs, so the FOSS facade must implement §3–§4 instead of Beken.
- `02-component-map.md`: add the `192.168.169.x` live sequence diagram (8× EF000400 → fragment storm → reassembly) as a separate "physical device trace" block.
- `03-reimplementation-proposal.md`: scope-core must implement **both** transports; put the validated UDP/8800 first-class, Beken/7080 second. **The decode path is fully specified now (§5b)**: reassemble pages, prepend `jhdr_Q100`, append EOI, decode 640×360 — no remaining unknowns for core video; heartbeat drift-word semantics and UDP 63736 remain nice-to-have.
- `OPENCODE.md`/`AGENTS.md`: wiki of established facts gains the UDP-8800/EF-format essentials + note that `.venv` now also has `capstone` and `pillow` and that `arm-none-eabi-objdump` is available for THUMB disassembly.
