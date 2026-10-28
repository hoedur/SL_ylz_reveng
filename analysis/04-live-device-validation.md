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
— a **605-byte stride** (so each head is **605 B**, ending right after the SOS segment `… 00 3f 00`;
the shipped `analysis/artifacts/jhdr_Q*.bin` files are 607 bytes = over-extraction, corrupted tails — §5b-2).
Each head is `FFD8 FFE0(APP0) FFDB(DQT) FFDB FF C0(SOF0: 640×?) FFC4(DHT)×N FFDA(SOS)`. The dispatch compares the device-announced
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
| 46..47 | u16 | height field = 480 (`0x01E0`) — **the REAL raster height** (CORRECTED 2026-10-27: the native decoder patches the head's SOF0 height to this value per frame, doc §9.8; the earlier "misleading/bogus, real 640×360" reading was wrong — see §9.8) | const |
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

> ⚠ **Corrected 2026-10-24 (late session, prototype user report "washed-out grey video").**
> The subsection below was written from the 607-byte artifact extractions and reached the
> wrong header rule ("always Q100", "q byte does not map"). The correct facts are appended
> in **§5b-2**; the text is kept for the historical record — do **not** re-quote its
> conclusions.

The earlier "transformed scan data" hypothesis is **wrong**. The frame payload is untouched JPEG
*entropy-coded scan data* — it just has **no SOI/header** because the phone is supposed to prepend one of
the embedded `jpeg_header_640x360_Qx` heads and append `FF D9` (§3.3).

### 5b-2. CORRECTED header rule (2026-10-24, validated against .so + live traces)

**Root cause of all the confusion: a 2-byte over-extraction of the embedded heads.**
`nm` gave `jpeg_header_640x360_Q5@0x4c1a, Q10@0x4e77, Q25@0x50d4, Q50@0x5331, Q75@0x558e, Q100@0x57eb`
at a **605-byte stride** — the heads are **605 B** (ending immediately after the SOS segment,
SOS tail bytes `00 3f 00`). The extraction copied 607 bytes per head, so each
`artifacts/jhdr_Q*.bin` carries a 2-byte stray tail of the adjacent pool (literal `FF D8`
bytes for Q5..Q75 = the next head's SOI; `5D 02` for Q100 = start of the next data symbol):

- With the stray `FF D8` tail, Q5..Q75 emit libjpeg's "extraneous bytes before marker" /
  "broken data stream" error (invalid entropy-stream start) — this produced the false
  "Q5..Q75 fail" verdict.
- With the stray `5D 02` tail, Q100 structurally "decodes" but the two bytes enter the
  entropy-coded stream *before* the real scan data — the entire coefficient stream is
  misaligned; the same payload decoded with the clean 605-byte Q100 head and the stray
  bytes succeeds/looks completely different (checked byte-diff: the ONLY differing bytes
  between heads are the two DQT tables + the tail).

**Native selection rule (disassembly, libbl_vii_jni.so `handle_mcu_msg_frag` @0x267e–0x2698):**
the announced quality byte (low byte of the u16 @48) is compared against 5 / 100 / 25 / 50 / 75 / 10
and the matching embedded head is prepended. No match → no new head (sticky previous head).
There is no independent "the app changed quality" path — `BlSdk.setQPara` stays dead code,
but the device itself varies the announced quality per frame:

| captured frame | size (B) | announced byte48 | byte49 |
|---|---|---|---|
| id=1 | 14 059 | 25 (0x19) | 0 |
| id=2 | 20 932 | 50 (0x32) | 1 |
| id=1 | 33 518 | 75 (0x4B) | 0 |
| id=2 | 33 634 | 75 (0x4B) | 1 |

(byte49 varies 0/1 per stream — camera/sub-index, semantics open.)

**Corrected working recipe:**

```
jpeg = jhdr_Q<q>.bin (605 B, from libbl_vii_jni.so; q = payload datagram's byte 48)
       + Σ fragment-page data (1024 B each, last one short)  +  FF D9
```

- Quiet libjpeg decode, correct 640×360 geometry **and colorimetry** for every captured
  frame with its announced head (frame0 + Q25 head → warm, contrast-correct render;
  the Q100-head render of the same payload is uniform grey fog — lum std 1.4 vs 43).
- The "always Q100" advice and "the announced quality byte is 0x4b and does not map"
  from §5b are **retracted** — they were artifacts of the broken tails.
- Negative results from the earlier hunt remain valid: XOR-constant sweep (256 keys),
  whole-buffer bit-reverse, nibble-swap, 16-bit byte-swap — none decode; none needed.
- Sample corrected decodes: `artifacts/decoded/frame0_q25_correct.png`,
  `frame1_q50_correct.png` (artifacts frame0/frame1 payloads with their announced heads).
- FOSS client (prototype) implements exactly this rule: `JpegHeaderTable{5,10,25,50,75,100}`
  over the six 605-byte data heads + sticky fallback (initial Q100); see
  `prototype/docs/ARCHITECTURE.md` REQ-BOL-005/006 (amendment) — **prototype-validated**
  code + 72 tests, pending one live A/B against the app (device was off).

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
2. **Video framing:** doc claims ≤1472-byte fragments with `picId@2/pkType@3` into a 102400-byte buffer. Actual BoliU wire: ≤**1091**-byte datagrams `[93][01][len16]` + 56-byte fragment header (67 on frag0, incl. 15-byte extension) + **1024-byte** pages; frame size announced per frame; fragment count/size/idx in the header; JPEG headers are **not transmitted** but inserted phone-side; **decode uses the head matching the announced quality byte (low byte of the u16 @48; §5b-2)**, real resolution 640×360.
3. **Control commands:** the two-byte `{0x20,0x36}` datagrams are the *Beken Java* protocol and are ignored by this device; the working control is `EF 00 04 00` @ UDP 8800 (payload effectively unvalidated — any datagram to 8800 re-arms streaming, §5), plus the `EF 02…` ack and `EF 10…` queryinfo channel.
4. **Heartbeat/orientation:** doc's TCP 2271/`CmdDataServer` doesn't exist here; a 16-byte `type-4` UDP beat every 1.6 s exists instead (drift word **not accelerometer** — see §7.2).

## 7. Open questions / retest list — status after the 2026-10-24 session

1. **Continuous fps** — ✅ done: ~3.2 fps effective (static), bursts at ~25 fps + ~0.5 s device-side stalls (§4a).
2. **Heartbeat semantics** — mostly done: the beat **re-targets the active streaming socket** (19 beats received on a brand-new port in one 30 s run; sticky-port model confirmed). The drift word `5e xx 00 00` is **not a direct accelerometer reading**: it changed by only one LSB (0x49→0x48) during 20 s of vigorous waving; yesterday it drifted 0x32↔0x38 over ~70 s idle. Looks like a slow counter/statistic (temperature? battery? signal?). Open: exact semantics; also the `[4..7]` field that yesterday incremented +1 per beat showed a **constant 0x00000001 for the whole window** after the device rebooted mid-test today (needs one more lap after the next power-cycle).
3. **Scan-data transform** — ✅ SOLVED, was a phantom (§5b): JPEG frames decode with the
   **announced-quality head** (605 B, from the .so) + pages + `FFD9` (corrected rule §5b-2;
   the earlier "always `jhdr_Q100`" wording was an extraction-bug artifact).
9. **Washed-out grey video in the prototype (user report, 2026-10-24)** — ✅ root-caused (§5b-2):
   2-byte over-extraction of every embedded JPEG head + prototype initially always using the
   Q100 head. Fixed in the prototype (six 605-B heads, per-frame `q` selection, sticky
   fallback); visual A/B vs the original app still needs one device-on session.
10. **Stream choppiness (user report, ~3–4 fps effective)** — ❌ open: the original app's wire
    behavior while streaming (ping cadence, frames-per-ping batch size, achievable fps) is
    **unmeasured** — every capture so far either caught the app idle (heartbeats only) or our
    own probes. Needs a live session: capture while the APP streams (its ping pattern),
    then sweep our client's ping interval (e.g. 90 / 40 / 20 ms) and record effective fps.
4. **Height 480 vs "640x360"** — ✅ **re-resolved 2026-10-27 (reversal)**: the height field (480) is NOT bogus: the native decoder patches the copied head's SOF0 to (w=640, h=480) per frame (doc §9.8); the embedded template heads declare 640×360 only because the patch overwrites their SOF0. Our 640×360 output silently clipped the bottom 120 rows (which is exactly the pre-EOI "surplus entropy").
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

## 9. Retest log — 2026-10-24 late session (color-fix verification + cadence sweep)

Device state: ON through the session, reachable at `192.168.169.1` (~1.8 ms ICMP).
**Left in state: device ON, our host wlan1 DISCONNECTED from its AP** (`iwctl station wlan1
disconnect`) — the AP serves exactly **one client**, and the slot was freed for the phone.

### 9.1 Corrected decode recipe verified live ✅

15 s run of the amended prototype (`PYTHONPATH=src`, host 192.168.169.1): as recorded in
`analysis/artifacts/proto_fixed_15s.json` —

| metric | value |
|---|---|
| frames_complete | 56 |
| decode_ok / decode_failed | 56 / **0** |
| fps_5s | 4.0 |
| pings_tx (90 ms cadence) | 166 (~11/s) |
| video_fragment datagrams | 1865 (~1.99 MB) |

Wire-side reassembly from the parallel capture `analysis/artifacts/cap_proto_fixed_15s.pcapng`
(38/38 decodable in the static re-parser): **every frame announced q=75 today**,
sizes 33 211–35 405 B. Visual verification (the whole point): `decoded/live_q75_correct.png`
renders rich natural colors — warm wood, saturated desk details — vs the grey fog of the old
Q100 recipe. App screenshot color reference: `analysis/screenshots/Screenshot_20261024-172432_SL_ylz.png`.
No pixel-level A/B of the *same frame* app-vs-prototype was possible (the app render needs the
phone in the AP).

### 9.2 Ping-cadence sweep: fps is NOT ping-gated ❗

4 × ~14 s runs (`cadence.py`, PingInterval override; 90/40/20/10 ms):

| ping | frames | effective fps | burst-gap median | stalls ≥0.2 s (n, mean) |
|---|---|---|---|---|
| 90 ms | 46 | 3.44 | 58 ms | 22, 0.54 s |
| 40 ms | 50 | 3.65 | 62 ms | 27, 0.46 s |
| 20 ms | 51 | 3.82 | 47 ms | 26, 0.47 s |
| 10 ms | 54 | 3.97 | 58 ms | 27, 0.45 s |

fps is **flat** — the ping-serve model arms delivery but does not set the *rate*. The stall train
(measured ~0.49 ± 0.05 s, n=18 in the capture-window analysis; intra-burst pairs
~44 ms apart → ~2 frames per stall window) is **device-side** (encode/producer pacing, not our
client). The 3–4 fps effective rate stands from all observations.

### 9.3 App-side stream measurement — plan (blocked, continuation point)

The **decisive experiment**: capture the wire while the ORIGINAL app streams. Steps:

1. `iwctl station wlan1 disconnect` FIRST (single-client AP — done this session; PC slot may not
   be holding when the phone must join),
2. monitor capture: `dumpcap -i wlan1 -I -a duration:40` on channel **1** (works without root —
   user is in `wireshark` group, `/usr/bin/dumpcap` has `cap_net_admin,cap_net_raw`; iwd 3.12-2
   manages the radio; no `iw` binary needed),
3. phone connects to the AP, SL ylz app streams ~40 s → analyze ping cadence/payload/gaps/fps
   vs our ~4 fps profile; then tune the prototype.
   Link profile: SSID `Earpick-AFD030`, BSS `f4:42:50:af:d0:30` (Bouffalo OUI), ch 1, **Security
   Open** → monitor frames are plaintext; reconnect our host later via
   `iwctl station wlan1 connect Earpick-AFD030`.

Offline re-parser of the locally-archived capture: `analysis/artifacts/tools/live_ab.py`
(reassembles fragments, applies per-q heads, renders PNGs + cadence stats); cadence-experiment
tool: `analysis/artifacts/tools/cadence.py`; header-sweep tool: `analysis/artifacts/tools/sweep_headers.py`.

### 9.4 New open question (during live decode verification) — ANSWERED, see §9.8

> **Superseded 2026-10-27 (§9.8):** the surplus entropy is *not* live-specific (the PIL
> "clean" tape decode was an instrument artifact — Pillow never surfaces libjpeg warnings;
> under `djpeg` all 10 tape frames warn 4.7–11.2 kB) and it is *benign trailing entropy*:
> the bottom raster rows' encoded data a 640×360-canvas head cannot consume. The device
> raster is 640×480 (SOF0-patched per frame by the native decoder); hypothesis (b) was the
> right family, (a)/(c) are moot. Original text retained for the record:

During the live runs the Qt/QImage decode path emitted libjpeg warnings of the form
**"Corrupt JPEG data: 6356–6413 extraneous bytes before marker 0xd9"** on live frames
(~6.4 kB unconsumed entropy per frame); decodes still succeed (decode_ok=56) and the
rendered images are intact (§9.1). The offline artifacts decode silently clean — so this is
a live-specific artifact. Hypotheses to check once the device is back on the bench:
(a) trailing pad bytes device-side, (b) announced `size` vs actual entropy scan length
(announced count marginally longer), (c) the 11 extra frag0-header bytes related to the
payload start. Re-verify on a live run: decode one frame with `decompress(normed)`-strict PIL
and compare the declared vs consumed scan length.

### 9.5 ✅ §9.3 executed: monitor-mode capture of the ORIGINAL app streaming (2026-10-26)

**Setup.** `wlan1` had been renamed `wlan0` by iwd/udev. Re-association attempts failed
("Operation failed") because the **phone already held the single AP slot** — which enabled the
experiment directly: the app was already streaming. `dumpcap -i wlan0 -I` (monitor) captured
~65 s of plaintext (Open AP, BSS `f4:42:50:af:d0:30`, ch 1, phone MAC `80:5a:04:ce:29:91`
= IP `192.168.169.3` — the device DHCP re-issued our old address). Artifacts:
`analysis/artifacts/app_stream_2026-10-26/{app_stream.pcapng,app_stream.tsv,analyze_app_capture.py}`.
Capture caveat: iwd channel-hopped while the station was disconnected → only ~13% of data
frames captured (p99 inter-datagram gap 1.5 s); fid *slope* estimates remain valid.

**Headline result: the device streams the app at ≈14.1 fps sustained** (OLS fid slope 14.08;
1119 unique frame ids 1373→2492 over 79.4 s). Our prototype's ~3.9 fps is NOT the device's limit.

**Client→device message families (complete list, nothing else observed on :8800):**

| datagram | count | cadence | semantics |
|---|---|---|---|
| `EF 02 40 00 …` (64 B) | 697 | bursts 8.78/s (median in-burst 1 ms, burst interval ~26 ms) | **receive-progress report**: `count`=1 record: `fid` u32 @32 (LE), `00` u32 @40, `01` u32 @44 (state=complete), `0x18` u32 @48 (record size 24), flags `FF×8` @52, zero-trailer @60. `fid` = last fully received frame (median lag −1 vs latest seen fid) |
| `EF 02 58 00 02 02 00 01 …` (88 B) | 32 | sparse | same frame, 2 records: (fid, state=1) + (fid+1, state=0, **partial fragment bitmask** in the flags word, e.g. `ff ff ff ff 00 f0 ff ff`) |
| `EF 02 68 00 02 02 00 01 …` (104 B) | 6 | sparse | 3 records (2 complete + one state=3/0x10) |
| `EF 02 28 00 …` (40 B) | 1 | — | `count`=0 (empty report) |
| `EF 08 08 00 <u32>` (8 B) | 31 | every ~1.64 s (seq 58→105, gaps only from capture loss) | keepalive; u32 = **seconds since stream start**; duplicates (≤9×) = client retransmit storms |

Constant body magic `02 02 00 01` and constant word `0a 4b 14 2d` at @28 (after magic/count +
16 zero bytes); all client datagrams go from app port `47336` to device `:8800`.

**Decisive negative fact: the app NEVER sends `EF 00 04 00`.** Our 4-byte ping is not what
keeps the app's stream flowing; the ~9/s EF-02 reports do (or the app's full-length stream
poll). Yet delivery under our EF-00-04 pings was proven ping-serve-like earlier (§10b.8/§9.2)
— see hypothesis H-1 below.

**Device→client extra facts.**

- Per-frame **last page is a short datagram** (`93 01 <len> …` with remainder bytes, e.g.
  44110 = 43×1024+78 → 78+56=134 B total) — fits `_expected_page_len`; our parser handles it ✓.
- One `93 01 40 00` 64-B device control observed (+19.3 s): fid/fid/fid−2 + `idx=43, cnt=44` —
  consistent with a device-side stream-state/retransmit notice (mirrors the EF-02 frame).
- Device heartbeat seq **matches the client EF-08 seq** (both = seconds since stream start;
  58/104 observed pairwise). Confirms the "drift word" is not an accelerometer and the
  heartbeat is stream-scoped, not boot-scoped.
- Everything decoded cleanly as JPEG here: sizes 43.9–44.6 kB, **q byte always 75** in-window
  (0x14b@frag0 hi/lo → low byte 0x4b), w=640 h=480.

**Hypothesis H-1 (next decisive live test).** The frame rate is *not* ping-gated (§9.2:
90/40/20/10 ms all ≈3.4–4.0 fps) but **ACK-gated**: the device fills its send window to
~4 fps-equivalent for a blind EF-00-04 client, but with the app's EF-02 receive-progress
reports (~9/s) it sustains ~14 fps (and ~25 fps intra-burst inside the app's capture gaps).
Test: prototype sends EF-02-64 reports (last-completed fid, state=1, flags FF×8) at ~9/s +
EF-08 keepalive every 1.64 s and no EF-00-04 pings → measure fps. Then sweep report rate.

**Session state / operational notes.** Capture stopped after ~65 s (pkill dumpcap). dumpcap
left a stale monitor interface `mon1` behind (deletion refused: *Operation not permitted*) —
delete manually (needs CAP_NET_ADMIN; `iw`/`ip link del mon1` as root) — cosmetic. Our host:
`wlan0` **disconnected** while phone streams; device ON throughout (battery consumed; phone
was on the device the whole session).

### 9.6 ✅ §9.5 follow-up: lossless app captures — bootstrap decoded + report-mode falsifications (2026-10-26, later)

Artifacts in `/tmp/opencode/` (should be copied into `analysis/artifacts/app_stream_2026-10-26/`
when preserved): `session_start5.{pcapng,tsv}` (60 s app RESTART with full client side; t+29.3 s
= session start; essentially lossless), `live_stream_now.{pcapng,tsv}` (45 s steady state,
22 184 device frag datagrams + 1 806 reports, essentially lossless). Key enabler: the phone's
app took lease `192.168.169.2` (our old address) — capture duty was meanwhile near-total.

**A. The app's full bootstrap sequence (session_start5, first 25 client datagrams):**

| t after 1st try | datagram |
|---|---|
| +0.00 s | `EF 00 04 00` (4-byte ping — **the app DOES send it, exactly twice, at bootstrap only**) |
| +0.10 s | `EF 00 04 00` again — **never again for the rest of the session** |
| +0.11 s | `EF 02 28 00` (40 B, count=0 empty report) |
| +0.12 s | `EF 02 28 00` again |
| +0.21 s | first record-bearing `EF 02 40 00` report, `fid=2` (video started at +0.10 s!) |
| ongoing | reports at ~26.4/s (fresh session) / ~39/s (long-running session), mixed forms |

The device's **first video fragment reaches the client +0.10 s after the first bootstrap ping**
(nothing else precedes it — checked the full pcap window for other phone traffic: only DNS
to the AP gateway and unrelated chatter). Session frame-id counter starts at **1**
(app fresh session: fids 1..463 over 29.3 s ⇒ ~15.8 fps ≈ the 16.1–16.2 fps fid-slope of the
45 s lossless tape). The prior '14.1 fps' was duty-limited; **16 fps is the real sustained rate**.

**B. Report forms — byte layouts (from the lossless tape; complete set):**

Body = `\xEF 02 [len] 00 | 02 02 00 01 | count u32 | 12×00 | 0A4B142D @24 | 00×4 | records… | 00×8`.
Record = `fid u64 LE | state u32 | recSize u32 | [mask]` with
recSize `0x18` = 24 B (u64 mask), `0x14` = 20 B (u32 mask — e.g. `ffffffff` for cnt ≤ 32
pages), `0x10` = 16 B (no mask). Forms observed (n=1060 in 45 s):
(64,1)=1001 · (60,1)=306 · (40,0)=146 · (104,3)=84 · (96,3)=84 · (88,2)=71 · (76,2)=48 · (80,2)=31.
Empty (40,0) reports occur steadily mid-stream (~2–3/s), not just at bootstrap.
State values seen: 1=complete, 0=in-flight (with partial mask), 3=not-running (no mask).

**In-flight mask semantics UNRESOLVED (important open):** even against the losslessly captured
tape, 89 state-0/u64 masks did **not** match "pages received before the report ts" under LE-bit
or MSB-bit indexing. Masks have run structure (e.g. `0xffffff800007ffff`, `0xfffff00000000fff`:
runs {0..14},{39},…; {0..3},{39..63}-style) and include bits for pages that demonstrably had not
arrived yet ⇒ the mask is NOT a plain received-bitmap. Retransmission evidence: **720 duplicate
(fid,idx) fragments in 45 s** — the app-level report masks DO trigger device retransmits.

**C. Ping-leg/keep-alive leg confirms §9.5:** EF-08 keepalives every ~1.3–1.6 s (first at
+1.31 s after bootstrap), device heartbeat seq mirrors it (both count stream seconds);
per-session reset (heartbeat seq ≈ 1 after a new session opens, was ~977 in the stale session).

**D. Live report-mode tests today (our client, `192.168.169.1:8800`), all AFTER the 2×ping +
2×empty bootstrap replica — ALL HALT ~0.3–0.7 s in:**

| variant | result |
|---|---|
| ping-only @90 ms (control) | 3.72–3.80 fps steady over repeated 14 s runs ✅ baseline |
| reports 8.9/s (const@24 byte-exact 64-B) | arm burst (2–5 fr) → permanent halt; heartbeats continue |
| reports 26/s (`report_interval=0.038` — app nominal) | same halt; 362 reports/14 s confirmed on wire |
| reports 39/s | same halt; 376/10 s |
| 2-record 88-B reports (rec0 completed + rec1 synthesized in-flight LE-bitmask) | same halt (5-frag burst) |
| reports 63/s | no completions (halt even before burst drained, 50 frags/0 frames) |
| reports-after-ping-stop (phase switch) | video stops the moment pings stop; heartbeats continue |
| plain reports with wrong const position (@28) | same halt — const position not the trigger |
| stale-port sniffing during runs | **0 datagrams** ever land on the app's old ports (43875/38605) — the device does not divert video to stale targets; delivery truly stops |

Heartbeat continuity (8–10 per 14 s) in every report-mode run proves the device-side session is
alive while fragment delivery is stopped — the device HALTS the video sender, not the session.
**H-1 conclusion so far:** neither report cadence (9–63/s), const position, nor a synthesized
in-flight record sustains delivery; the device retains its state across variants AND across our
re-associations. The missing device-side condition that makes the *app's* reports sustain 16 fps
is NOT identified — next hypotheses queued: (a) in-flight mask bit-order/meaning (solve from a
fresh lossless app capture; current mask runs don't correlate with received pages at all),
(b) report fid must equal the *device's current send position* (not last completed), (c) an
EF-02 report must be a *reply* to a heartbeat (pairing), (d) device per-client slot refresh via
a longer-lived bootstrap/ping cadence interplay.

**E. Operational data points 2026-10-26 evening:**

- AP-slot mechanics again: after our host left, the phone's app got IEEE assoc-response
  **status 17 ("AP cannot handle any more associated STAs")** repeatedly — the stale slot only
  cleared after a period of radio silence; our own rapid re-associate/disconnect cycles
  *refreshed* the stale slot each time (each cycle re-registered us). One quiet ~4-min window
  was enough for the phone to join. Note resolve: `Earpick-AFD030` DHCP handed the phone
  `192.168.169.2` (our old lease) — device lease reuse makes the client IP a poor identifier.
- Transient AP-loss scare: after `dumpcap -i wlan1 -I` monitor-mode experiments the station
  association dropped; iwd's scan then intermittently failed to list `Earpick-AFD030` although
  the device AP still beaconed on ch 1 (2412) — verified by a passive monitor probe. Re-connect
  via `iwctl station wlan1 scan && iwctl station wlan1 connect Earpick-AFD030` — note this boot's
  interface is named `wlan1` again (udev rename to `wlan0` was session-specific).
- Device unit stayed ON throughout (battery rule).

## 9.7 ✅ JPEG decode/reassembly validated against the app's native algorithm (2026-10-26, late)

Trigger: the user sees *stripes of previous-frame pixels at the left/top edge* and occasional
single-frame color shifts in our prototype's display, and hypothesizes broken frag
reassembly. Validated two ways — against the `.so` static decode path and against the
lossless app sessions of §9.5/§9.6.

### A. The app's native decode path (`libbl_vii_jni.so`, `handle_mcu_msg_frag` @0x230c, 820 B)

Symbol table is unstripped (26 kB `.so`; `objdump -T` lists every function). The fragment
dispatcher plus a helper at `0x2640..0x2734` implement the accept path; semantics:

| What | Native code | Matches prototype? |
| --- | --- | --- |
| Quality dispatch | helper @`0x267e`: `ldrb [r5,#32]` = **single byte at d[48]** (frag0), compared against **5 / 10 / 25 / 50 / 75 / 100** — exactly the six head LUT values | ✅ (u16@48 LE → low byte = d[48]; `JpegHeaderTable.header_for`) |
| Head copy | `0x26bc-26c4` `memcpy(slot+164, head_ptr, len)` = the full 605-B global (`jpeg_header_*_len` = 0x25d) | ✅ (full 605-B head prepended) |
| Unknown q | `0x2696 bne 0x26e8` → head-copy skipped, **sticky previous head** | ✅ (`header_for` → None → caller keeps last; initial Q100) |
| Page area | pages memcpy'd into one contiguous buffer at `idx*1024` (`0x2706-272c`), idx from d[32] | ✅ (`payload = pages[i] for i in range(cnt)`) |
| Retransmit | re-copy into the *same* destination → **last-version-wins overwrite** | ✅ (`pages[idx] = page` overwrite) |
| EOI | `0x2664-266e` `movw r1,#0xd9ff` + `strh`, appended **only when idx == cnt-1**, at payload end | ✅ (`+ FF D9` at completion) |
| frag0's 11 extra header bytes | `0x26e8 sub r0, r9, #11` (r9 = u16@d[2]) + u32 read at d[slen-4] and 8-B read at d[slen-67] — **11 bytes arithmetically skipped as metadata** | ✅ (page0 = d[67:], REQ-BOL-004) |
| frag0 length sanity | d[2] (u16) is read as the datagram's own length field | (informational; not modeled by us) |

Conclusion A: **the app's reassembly is byte-equivalent to ours on every semantic that
exists**: same q byte, same head selection with sticky fallback, same page slicing, same
order, same overwrite policy, same EOI append at completion.

### B. Empirical tape validation (lossless app captures, §9.5/§9.6)

* `live_now.tsv` (45 s steady state, 22 152 device datagrams): **page-boundary arithmetic
  validated per datagram — 0 anomalies** over every (idx, cnt, size) combination:
  `idx==0 → d[67:], 1024 B; idx==cnt-1 → d[56:], size-(cnt-1)*1024 B; else d[56:], 1024 B`.
  Zero exceptions.
* Complete frames: 10 of 731 announced fids had *all* pages captured (the monitor capture
  drops ~30 % of datagrams; app-side completeness is unaffected — see §9.5 duty notes).
  **All 10 decode cleanly in PIL** — no libjpeg warnings, exact 640×360, q=75 ×6 / q=50 ×4
  (PNG samples archived in `analysis/artifacts/sof_canvas480_2026-10-27/pngs360/` —
  note these are the pre-REQ-BOL-010 360-canvas renders; the corrected 480-canvas
  renders live in the sibling `pngs/` directory).
* Retransmission semantics: FIRST-version vs OVERWRITE yields **0 differing frames** on the
  complete set.
* Offline reference artifacts (`analysis/artifacts/frame0.bin` et al.) also decode clean —
  consistent with §5b/§9.1.

### C. Verdict on the user's artifacts (stripes / color shift) — CORRECTED, see §9.8

> **Superseded 2026-10-27 (§9.8):** cause 1's premise "(ii) surplus entropy … does **not**
> reproduce on any lossless tape" is factually wrong (PIL was warning-blind; under `djpeg`
> 10/10 tape frames carry 4.7–11.2 kB of surplus — benign trailing entropy, byte-identical
> pixels after trimming). The stripes themselves **exist in the device's own stream**
> (7/10 complete tape frames show a foreign-palette top band; fids 2080/2303/2153 best-match
> *other* frames' content) — device-side encoder content at scan start, visible in the app's
> session too. The original regime-based attribution below is downgraded to "candidate for
> artifact *frequency*, not existence". Original text retained for the record:

The user-visible stripes at the **left/top** edge = start of the JPEG *scan* = start of
**page 0's payload**; a single-frame color shift = corrupted early entropy. Two live-regime
causes fit; **neither is the reassembly algorithm**:

1. **Device-side page-buffer reuse in our stalled delivery regime (H-1 casualty; favorite).**
   Under our report/ping regime the device's frame ring is NOT drained at the app's 16 fps
   (delivery halts after the arm burst). Overwritten buffer content then surfaces both as
   (i) retransmitted/overlapping pages whose *content* is stale from a PRIOR frame (left/top
   stripes) and (ii) surplus entropy — the live-only ~6.4 kB "extraneous bytes before marker
   0xd9" quirk of §9.4, which does **not reproduce on any lossless tape** (all tape frames
   decode warning-free). The app never hits this because its report channel keeps the ring
   drained at 16 fps.
2. **Render path ruled out:** `VideoPanel.show_frame` = full-draw `QImage.fromData(jpeg)` →
   `QLabel.setPixmap` per frame; complete frames only; no partial paint exists.

Open (retest when the unit is powered on again — after the 2026-10-26 evening session it was
**powered off / AP not beaconing**: two passive ch-1 monitor probes, 400 and 900 packets
@2412 MHz, found **zero** device beacons; the planned own-session datagram capture is
deferred): capture ~10 s of OUR client's live session with a datagram-dumping transport
subclass, reassemble + decode offline, compare against this section's baseline. Expected
result: page-content mixing (stale pages around burst/stall boundaries) instead of any parse
error.

**Session stop state 2026-10-26 23:37:** device appears OFF (not our doing — battery likely
drained across the day's sessions). Verify by beacon probe before the next live session.

## 9.8 Gate outcome (2026-10-27): 3/5 REFUTED aspects — conclusion corrected

The §9.7 conclusion ran the required five-agent adversarial gate and **failed it (3/5)**:
two validators produced decisive refutations, both verified independently:

1. **Instrument error in our harness (validator 3, spot-checked):** PIL/Pillow (venv,
   bundled libjpeg) **never surfaces libjpeg warnings** — the §9.7-B "all 10 tape frames
   decode with no warnings" was measuring nothing. Under real `djpeg`, all 10 complete
   tape frames warn, with **4 710–11 221 extraneous bytes before marker 0xd9** (ratios
   0.20–0.28 of size) — the ~6.4 kB "live-only" framing of §9.4/§9.7-C was WRONG.
2. **Native per-frame SOF0 dims patch missed (validator 5, verified in disassembly):**
   `handle_mcu_msg_frag`'s helper (@0x2640) reads the stashed w/h (caller stores h=d[46]
   → slot[158], w=d[44] → slot[156] @0x240c/0x2414) and writes them **BE16 into the head
   copy's SOF0 at head+145/147** (@0x26dc/0x26e4). All six template heads declare
   640×360 (`01 68 02 80`); the wire announces **w=640, h=480 on 1 061/1 061 frag0s**.
   So "h=480 is bogus" (§4 line, §5b-2 item 4) was wrong — **the device streams 640×480,
   and our 640×360 canvas output silently clipped the bottom 120 raster rows.**

**Resolution — the "surplus entropy" is explained:** rebuilding every complete tape frame
with the SOF0 patch to (640,480):
- the top 360 rows are **pixel-identical** to the old subject-good decode (10/10),
- the assembled PNG now shows the FULL frame incl. the previously-dropped bottom 120 rows
  (real ear-scope content — PNGs in `analysis/artifacts/sof_canvas480_2026-10-27/pngs/`,
  reproduction scripts in its `tools/` subdir),
- the pre-EOI extraneous bytes **collapse to ~0** (fid 2080: 8374 → **3**); frames that
  warn "premature end" instead encode a slightly-truncated scan at the extreme bottom
  margin but still render the full visible picture.

> **Revised 2026-10-27 late (gate round 0, validator 1 + retest): the small residual
> warnings ("3 extraneous bytes on 2080", "premature end") are an artifact of OUR OWN
> frag0 slicing — the page0 slice `d[67:]` treated 11 trailing ASCII bytes as page data.
> Under the wire-exact page0 slice `d[56:len-11]` all 10 live_now frames decode
> djpeg-clean at 640×480. See §9.9 and `analysis/artifacts/frag0_layout_2026-10-27/`.

**Attribution of the user's stripes/color shifts (corrected §9.7-C):** the artifact exists
**in the device's own stream**: 7/10 complete app-session tape frames show a top-left band
(rows 0–14) whose palette is far from both the frame's own interior (Δ up to 334/765) and —
for fids 2080/2303/2153 — closer to *other* frames' content than to the frame's own
(17/27, 16/27, 14/27 best-match hits). I.e. **foreign (previous/other) frame content at
the START of the scan** — the device-side encoder page/ring reuse, not any client bug.

> **REFUTED 2026-10-27 late (gate round 0, validator 1):** the primary clause
> ("device-side foreign content") is retracted — the entire band analysis ran on the
> wrong page0 slice (`d[67:]`, 11-B entropy shift). Under the wire-exact slice
> (`d[56:len-11]`) the top-band deltas collapse (2303: Δ116→19; 2080: Δ100→12;
> 2675: Δ95→31) and every V2-style MCU-row edge spike vanishes (y=8/16/24 spikes up to
> 39.0 → ≤1.35). The user's stripes are most plausibly the prototype's own slicing bug;
> the native app decodes the correct slice. Full table:
> `analysis/artifacts/frag0_layout_2026-10-27/README.md`; gate record: §9.9.
Supported by the native side's own exposure (validator 5, D-B): the app's completion scan
**never tests page-0's mask bit** and ring slots (fid−4) are cleared only for masks, not
buffers — a page0-loss or page0-last frame completes in the APP with the ring slot's
stale head/pages. The prototype instead requires all pages, so it can only show such a
band when the wire's page bytes themselves are stale — which the tape proves happens.
Left/top stripe placement is consistent with scan-start corruption; **still open** (and
now the prime candidate for the adb/screenrecord data source): whether the artifacts'
*frequency* differs between our regime and the app's 16 fps drain (plausible but
unproven), and the exact "color shift" frames' mechanism.

**Prototype fixes shipped (spec-first):** REQ-BOL-010 (SOF0 dims patch,
`assemble_jpeg(..., width=, height=)` / `patch_sof0_dims`, `_collect` passes entry.w/h),
9 new tests in `test_sof0_dims.py`, suite **96/96**. `test_reassembly.py`
REQ-BOL-005/006 expectations updated to the dims-patched form; the render path itself
needed no change — it already full-draws each frame on the decoded image's own size, so
it picks up the 640×480 raster automatically (the VideoPanel keeps its 640×360
letterbox case for canvas-360 sources).

**Retest plan (device needed, powered off since 2026-10-26 evening):** (a) own-session
datagram capture (datagram-logging subclass) to quantify artifact frequency in our regime
vs the app's; (b) adb `screenrecord` + `logcat` while the ORIGINAL app streams — compare
artifact visibility on the phone's display (ground truth for "app never shows stripes");
(c) if the phone-side app shows the same top-left stripes, the striping artifact is
provably device-origin and the §9.7-C question of our regime's contribution reduces to
frequency only.

> **Restated 2026-10-27 late (§9.9):** retest (a) is done and archived; retest (b) still
> pending (waiting for the phone); retest (c)'s premise was retired by the frag0-slice
> discovery below — the striping question is no longer "device vs our regime" but
> "our own slicing bug vs the wire" (live visual confirmation pending).

## 9.9 Round-0 adversarial gate + own-session retest + frag0 layout correction (2026-10-27 evening)

### A. Gate round 0 on the corrected conclusion — FAILED again (<4/5), decisive cause found

Five validators (general-purpose agents, adversarial briefs; tallies in the session log):

- **V1 (SOF0/frag0 native claims): C1–C4 CONFIRM + C5 REFUTED** — the decisive find:
  **the frag0 "11 extra bytes" are TRAILING, not leading.** Every fragment header is
  56 B; frag0 datagrams = 56 + 1024 page + 11 trailing ASCII bytes (`-0214,-0894`),
  which the native helper deliberately stashes (`0x26e8–0x2702` → landing zone
  `slot+0x1000a4`, slot stride `0x1000b0`). The documented `page0 = d[67:]` slice
  (67-B frag0 header) shifted the entropy stream by 11 B; the prototype has been
  decoding every frame 11 bytes off. Also: helper base sign corrected (caller slot
  **+0x80**, docs previously said −0x80); "SOF0 at 141..149" → 140..148 (patch offsets
  145/147 unchanged); C4 exhaustive store sweep (only 4 head-region writes).
- **V2 (striping attribution): PARTIAL** — existence of the anomaly device-side was
  confirmed with strong evidence (frame-synchronous lag-0 palette correlation 0.87/0.92
  over 469 fids; zero stale byte-reuse; all scans Huffman-coherent), but its refined
  "device-side top-row pipeline" mechanism, like the original "foreign content",
  was derived **under the wrong slice** — both are superseded by the re-decode below.
- **V3 (surplus explanation): CONFIRM** with corrections: template heads are
  **4:4:4 (sampling `01 11 02 11 03 11`) → 8×8 MCUs** (80×60@480 / 80×45@360), which
  makes "bottom 120 rows = 25 % of entropy" exact; measured surplus/size mean 0.2447 /
  median 0.2496 (n=22 frames); byte identity `E360 = (C480−C360)+E480` holds exactly
  where evaluable; fragment recount **34 869 → 34 862** (+7 short `[0x93][01]` control
  datagrams of 58–67 B, body `02 02 00 01`+fid-triple, not fragments); third tape
  `session_start4.txt` adds 43 399 fragments, 0 anomalies, 12 complete frames.
- **V4 (prototype @480 end-to-end): CONFIRM 6/6** — REQ-BOL-010 code/tests/render path
  verified byte-exact; suite 96/96 reproduced; comment/spec-text nits queued.
- **V5 (docs sweep): 18 blockers / 20 minors** — doc-consistency gaps only (this
  pass fixes them); no scientific refutation.

Net: the persisted conclusion failed the gate again — because §9.8's decode recipe
itself still contained the frag0 error V1 uncovered. Round 1 (below) shipped the fix.

### B. Own-session datagram capture — retest (a) complete

`analysis/artifacts/own_session_2026-10-27/` (pcapng + TSV). Ping regime: 46 complete
frames, wire fps 3.43, familiar stall structure (26 gaps > 350 ms). Report phase:
**26-fragment burst in the first second, then 9.8 s of zero fragments while 260 EF-02
reports AND device heartbeats continue** — H-1 captured losslessly on the wire.
Heartbeats followed BOTH client sockets (46844 ping socket + 51387 report socket);
pre-association heartbeats broadcast (dst 0.0.0.0:0). Any prior artifact-frequency
comparisons from this capture (29/46 vs 6/10 same-metric) are void — the band metric
was old-slice-based; the striping question retires into §F below.

### C. EXP1/EXP2/EXP3 — the entire report-content surface exonerated

- **EXP1** (live, `/tmp/opencode/live_h1_exp1.py`): continuous in-flight-mask records
  (`state=0`, bitmask mirroring actual fragment reception, 362 sent) → halt unchanged
  (39 fragments, all within the first second; 2 frames).
- **EXP2** (`live_h1_exp2.py`): the 20-B record form (`recSize=0x14`, u32 mask) →
  same halt (46 fragments).
- **EXP3** (`live_h1_exp3.py`): **byte-exact replay** of the app's own client stream
  from the session_start5 tape (513 datagrams = 2×ping + 2×empty + 496 EF-02 + 15
  EF-08 at their recorded relative times) → **still halts** (47 fragments in second 0,
  then 29 s of silence). Nothing we transmit datagram-wise differs the stream; the
  missing device-side condition lies outside the EF/UDP surface (top candidates:
  802.11 link-layer client properties — power-save patterns, PHY negotiation, client
  identity at the AP level).

### D. Round 1: wire-exact frag0 slice implemented (spec-first)

- Spec: REQ-BOL-004 amended 2026-10-27 (`page0 = d[56:len-11]`, `cnt==1` → `size-11`
  B; framing totals unchanged at 1091 B) — `prototype/docs/ARCHITECTURE.md` +
  coordination entry.
- Code: `boliu.py` (`FRAG_HDR=56` + `FRAG0_TAIL=11`, slice updated), `fake_device.py`
  + all four test `fragment()` builders emit the wire-exact layout,
  `test_fakedevice_integration` page0 slice fixed. **Suite 96/96.**
- Tape re-verification (`analysis/artifacts/frag0_layout_2026-10-27/`): corrected
  slice = **djpeg-clean 10/10 live_now complete frames at 640×480** (old slice: 7/10
  warn, incl. "3 extraneous bytes" fid 2080); every MCU-row edge spike (y=8/16/24,
  up to 39.0 luma) collapses to ≤1.35; the remaining top-band mean-deltas (Δ 5–39)
  are scene-level and not MCU-aligned. fid 2303 before/after PNGs in the artifact.
- Consequence for §9.7-C/§9.8: the user's left/top stripes were most plausibly
  **our own 11-B entropy shift** (the shipped app decodes correctly). The wire-level
  confirmations that SURVIVE the slice fix: §9.7-A semantics inventory, the §10b
  decode recipe shape (q-LUT, sticky head, EOI), §9.8's SOF0 dims patch, and V3's
  canvas-360 surplus story (bottom raster rows) now stands with **no residual
  warnings** (E480 = 0, so E360 = C480−C360 exactly = the bottom-120-row entropy).

### E. New environment facts (this machine)

`wlan1` is a **USB 802.11 dongle** (Z-Com 0cde:0006, TX/RX 36 Mbps this boot), not the
internal NIC; iwd applies 802.11 power-save by default and offers no station PS
property; toggling PS needs root (`sudo iw dev wlan1 set power_save off` — pending
user's command, queued as the H-2 experiment); `iw` is not installed.

### F. Open questions after round 1 (supersedes §7's striping items)

1. **H-1** remains open and now content-exonerated: run the power-save-off ping
   experiment; then the phone-comparison round (screenrecord ground truth: does the
   phone display match our corrected decode 1:1? — expected yes).
2. **Live visual check** that user-visible stripes are gone with the corrected slice
   (short ping session; device stays ON).
3. The 11-B ASCII tail = **candidate sensor channel** (`-0214,-0894` reads like two
   signed axis readouts; connects to the open heartbeat drift-word question) — the
   arc42 "no sensor channel on this unit" record needs this caveat; candidate
   REQ-BOL-011 to surface `tail` in an event field (not yet implemented).
4. Classify the 7 short `[0x93][01]` control datagrams (58–67 B, body `02 02 00 01` +
   fid-triple + idx/cnt pair) — type-1 but not fragments; the parser already rejects
   them cleanly under the ≥68 B threshold.
5. `cnt==1` frag0-tail arithmetic is derived, not wire-observed (no cnt==1 frame in
   any tape) — first live occurrence gates the `size-11` claim.
