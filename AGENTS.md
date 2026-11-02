# Project instructions (SL_ylz — WiFi/USB otoscope reverse engineering)

Persistent guidance for any OpenCode agent working in this directory. This file is
loaded via the `instructions` entry in `opencode.jsonc` (OpenCode V2 does not load
it by name alone). It serves the same role as a `CLAUDE.md` in Claude Code projects.

## What this project is

Reverse engineering of the Chinese ear-wax-remover otoscope app
`SL+ylz/V1.0.23.251121/SL+ylz_V1.0.23.251121_APKPure.xapk`
(package `com.xiaozhen.beauty.shenglong`)
as the basis for a free/open-source replacement. Phase 1 is **analysis only —
no implementation code**. Deliverables live in `analysis/`:

- `analysis/01-arc42-architecture.md` — arc42 doc, protocol answers, §10a device-config surface,
  §10b empirically validated protocol of the physical unit
- `analysis/02-component-map.md` — Mermaid component/sequence diagrams (+ §2a live device trace)
- `analysis/03-reimplementation-proposal.md` — FOSS rewrite plan (Android first, then desktop)
- `analysis/04-live-device-validation.md` — live-probe evidence and retest log (artifacts under
  `analysis/artifacts/`)

Never modify or delete anything under `SL+ylz/V1.0.23.251121/unzipped/` (APK artifacts,
split configs, native `.so` files) — these are read-only source material for the analysis.

## Environment and tooling

- All Python analysis runs in the repo-local venv: `.venv/bin/python`.
  `androguard` is installed there, plus **capstone** (ARM/THUMB disassembly) and
  **pillow** (JPEG decode checks); `arm-none-eabi-objdump` is also available on
  the host for THUMB listings.
- androguard noise: `loguru` floods output. Call `logger.remove()` at the top
  of every analysis script before any androguard API call.
- androguard 4.x API notes (they cost several debugging rounds; do not re-learn
  them):
  - `AnalyzeDex` works on `.dex` files, not on the `.apk`. Use
    `SL+ylz/V1.0.23.251121/unzipped/com.xiaozhen.beauty.shenglong/classes{,2,3}.dex`.
  - `d.get_methods()` on a raw `DEX` returns `MethodIdItem`s (no bytecode).
    Iterate `d.get_classes()` → `c.get_methods()` to get `EncodedMethod`s.
  - String extraction per instruction: `ins.get_string()` (try/except), it only
    works for `const-string`; method references go through `ins.get_operands()`.
  - Method-level `m.source()` decompilation (DAD) does not work from a bare
    `DEX` object; readable bytecode listings come from
    `ins.get_name()` + `ins.get_operands()` + `ins.get_string()`.
- Write one-off analysis scripts inline (heredoc via shell) or to `/tmp/opencode/`,
  not into the repo — the repo only holds the xapk, artifacts of unzipping, and
  the `analysis/` docs.

## Established protocol facts (do not re-derive; cite arc42 §10b for live-validated facts)

**Two controller families ship in this product family — their wire protocols are unrelated.**
A FOSS implementation must keep transports pluggable (DeviceTransport extension point,
`03-reimplementation-proposal.md` §2.2 / arc42 §10b.9). The delivered physical unit is a
**BoliU "BL384" (Bouffalo Lab, MAC OUI F4:42:50)** — everything under "live-validated" is
empirical from `analysis/04-live-device-validation.md` + `analysis/artifacts/`.

- **Live-validated BoliU/BL384 protocol (the one that matters for the in-hand device):**
  - UDP-only; **no TCP at all** (no TCP 2271, no `CmdDataServer` on this firmware; nmap full
    scan: all TCP closed). UDP listeners: 67 (DHCP), **8800**, 1234, 63736 (silent).
  - Client binds an **ephemeral UDP socket**, pings `EF 00 04 00`→`device:8800` every ≤101 ms
    (ping-serve model: one ping ≈ one frame batch; delivery stops ~101 ms without contact; the
    payload is **not** validated — any single datagram to 8800 re-arms/redirects the stream;
    retraction: sustained delivery is NOT guaranteed by arbitrary datagrams — report-mode
    sessions open but then halt 0.3–0.7 s in, EXP3 replayed the app's own bytes and still
    halted — doc-04 §9.9 C). **Scope correction (doc-04 §9.13, 2026-10-29): the ~101-ms TTL
    applies to ping-only sessions only. In the app's bootstrap-established report session the
    device streams on its own encoder clock — NOT ping-pong, NOT datagram-armed: tape-verified
    823 ms of total client silence with full-rate fragment flow (511/s), 118 gaps >101 ms
    carrying 392 frame starts; the gate is claim-CONSISTENCY (silence and count-0 empties
    harmless; fid-0/stale-fid claims halt the stream).**
  - Device streams fragments from `:1234`: `[0x93][01][len LE16]` + 56-byte header on **every**
    fragment (amended 2026-10-27 gate-1: frag0 carries 11 TRAILING ASCII bytes
    `d[len-11:len]`, e.g. `-0214,-0894`; page0 = `d[56:len-11]`; the "67-byte frag0 header"
    reading was inverted) + 1024-B page; datagrams ≤1091 B; **last pages may be short
    (57..67-B band = remainder under 12 B, valid fragments — 2026-10-28)**;
    idx@32, cnt@36, size@40, w=640@44, h=480@46 (REAL raster height); frame id=u32@8
    (monotonic = report fid under the app; cycles {1..3} under ping-only delivery),
    u16@48 high byte = (id−1) mod 2, u32@24 = previous id (2026-10-28 gate round 2);
    out-of-order → reorder by idx.
  - **Decode (corrected 2026-10-24, slice corrected 2026-10-27): `jhdr_Q<q>.bin` (605 B heads,
    from `libbl_vii_jni.so`) + Σ pages (`d[56:1080]` for idx0, `d[56:]` otherwise) + `FF D9` →
    stock JPEG, 640×480 RGB with correct colorimetry (head SOF0 patched per frame to d[44]/d[46],
    2026-10-27).** `q` = low byte of
    the announced u16@48 (device self-varies per frame live: 25/50/75); unknown → sticky
    previous head, initial Q100. The earlier "always Q100 (607 B)" rule was an artifact of a
    2-byte over-extraction (`analysis/04-live-device-validation.md` §5b-2 root cause); no
    XOR/transform exists (sweeps negative — still true).
  - Delivery under our ping-only client is bursty: ~25 fps intra-burst with ~0.45–0.5 s
    device-side stalls, ~3–4 fps effective. Heartbeat `[0x93][04][16 B]` every 1.6 s nominal
    per grid tick (one datagram per tick under any active **client**; with NO ACKing client the
    device storms byte-identical beats 8–694× at ≈0.4 ms spacing — session_start5's 2410-beat
    record; seq does not advance within a storm; 2026-10-28 classified), follows the
    streaming socket; drift word `5e xx` is **not** an accelerometer. **Cadence sweep (2026-10-24):
    fps is NOT ping-gated** — pings 90/40/20/10 ms all yield ~3.4–4.0 fps with ~0.49 s stalls; the
    ping only arms/redirects delivery. Measured ping-regime fps: 3.43/3.72–3.80 (2026-10-24/27),
    3.88 (own_session recount), 3.91 (2026-10-28 fresh-boot) — band **3.43–3.91**.
  - **App-capture (2026-10-26, monitor mode; superseded by the lossless §9.6 results below):**
    the app streams at **~16.1–16.2 fps sustained** (fid slope on a lossless 45 s tape; the
    first "14.1 fps" and "8.8 reports/s" were capture-duty artifacts — real report rate is
    **~26.4/s fresh session, ~39/s long session**; tape #2 2026-10-28: 16.66 fps, 27.9/s,
    ~31/s single-report bursts median 1/burst 32.7 ms — regime-qualified, see doc 04 §9.11).
    The app **sends `EF 00 04 00` exactly
    twice at session start** (+0.00 s, +0.10 s), then two 40 B empty reports, then
    `[EF][02][len][body]` receive-progress reports continuously — never a ping again
    (`fid` = last fully received frame, per-record fragment bitmasks; body magic
    `02 02 00 01`, const `0a 4b 14 2d` at offset 24; len16 = datagram total) +
    `[EF][08][08 00][u32=stream-seconds]` keepalive every 1.64 s (device heartbeat seq
    mirrors that counter; resets to 1 per session; per-session fid counter also starts at 1).
    Report record = `fid u64 | state u32 (1=complete,0=in-flight,3=not-running) | recSize u32
    (0x18=24 B w/ u64 mask, 0x14=20 B w/ u32 mask, 0x10=16 B no mask)`; 8-B zero tail.
    **H-1 ROOT-CAUSED 2026-10-29 (doc 04 §9.12): the device's flow control follows the
    client's report fid — our strict all-pages reassembly freezes rec1 at the first frame
    with an RF-lost page (~4.4 pages/frame lost to invisible 802.11 FCS errors; only 32/940
    app-tape frames are ever complete), and the device stops streaming when the reported
    fid stalls (41 s RF silence in the monitored halt). The app completes frames on
    last-page arrival or supersession (holes allowed, JPEG decoder tolerates gaps — the
    source of its own occasional color shifts), reports rec1=(delivered fid, state 1, full
    mask) + rec2=(in-flight fid, state 3, rs 16), paced ≥25 ms (disasm of build_send_ack/
    thread_timer; page-0 never tested by the completion scan; 2-s stall → full reset).**
    Fix = app-parity delivery + report engine v2 in the prototype.
  - **App-exact bootstrap = 2× ping + 2× empty report (IE doc 04 §9.6 A, tape-verified):** the
    device's first video fragment arrives +0.10 s after the first ping; first record report
    +0.21 s (fid=2). Prototype implementation: `BoliUReportTransport` (REQ-BOL-008/009,
    suite 87/87 at introduction — 102/102 current) — live fps still capped ~4 fps (H-1 open).
  - Interface note (2026-10-26 evening): this boot's radio interface is **`wlan1`** (the
    earlier udev/iwd rename to `wlan0` was session-specific — check `iwctl device list` first).
    Per-frame last page is a short datagram (remainder + 56 B header) — expected by
    the prototype's page arithmetic.
  - **The device AP serves exactly ONE client** (phone showed "accesspoint temporarily full"
    while our host was associated). WLAN: SSID `Earpick-AFD030`, BSS `f4:42:50:af:d0:30`,
    channel 1, **Security Open** → a monitor-mode capture (user is in `wireshark` group;
    `/usr/bin/dumpcap` has cap_net_admin/net_raw; iwd 3.12-2 manages the radio, `iwctl` exists,
    no `iw` binary) can sniff the phone↔AP link in plaintext — **done 2026-10-26**: results in
    §9.5/§9.6 of `04-live-device-validation.md` (app fps 16.1–16.2; EF-02/EF-08 client family;
    full bootstrap tape; H-1 open). **AP-slot handover lesson:** assoc-response status 17 while
    a stale slot is held; our rapid re-associate/disconnect cycles *refresh* the stale slot —
    go radio-silent ~4 min instead. The device AP can appear "gone" to iwd's scan while still
    beaconing on ch 1 (2412); verify with a passive monitor probe, not just `get-networks`.
    Session stop state: device ON, our host wlan0 (this boot: `wlan1` — the udev rename to
    `wlan0` was session-specific!) DISCONNECTED (slot free for the phone);
    reconnect via `iwctl station wlan0 connect Earpick-AFD030`.
  - "Extraneous bytes before marker 0xd9": **not live-only, and explained** (CORRECTED
    2026-10-27, doc-04 §9.8): it is the bottom raster rows' encoded entropy that a
    640×360-canvas head cannot consume. Under `djpeg` it appears on 10/10 lossless tape
    frames too (4.7–11.2 kB); patching the canvas to 640×480 collapses it entirely
    (10/10 djpeg-clean after the amended page0 slice — `frag0_layout_2026-10-27`) — the
    "~3 B on fid 2080" residual was an artifact of the old `d[67:]` slice (retracted,
    doc-04 §9.9). Instrument note: **PIL/Pillow swallows libjpeg warnings** — any "decodes with
    no warnings" claim must be re-checked with `djpeg`.
  - **Decode/reassembly equivalence to the app (2026-10-26; caveat added 2026-10-27 after
    a 5-agent adversarial gate FAILED 3/5; page0 slice corrected after gate round 0 — see
    doc-04 §9.8/§9.9):** the shared semantics hold —
    q byte = d[48] vs LUT {5,10,25,50,75,100}, sticky head on miss; full 605-B head copy
    (SOF0 dims patched per frame to d[44]/d[46], helper base = caller slot +0x80);
    page0 = d[56:len-11] (frag0's 11 ASCII bytes are TRAILING metadata, not page data —
    the d[67:] slice shifted the entropy 11 B; amended REQ-BOL-004), others d[56:]; contiguous
    idx-ordered assembly; retransmit overwrite; EOI `FF D9` appended only when idx==cnt-1
    arrives (`handle_mcu_msg_frag` @0x230c, helper @0x2640; doc-04 §9.7). Page-boundary
    arithmetic: 0 anomalies on all **34 869** fragments (22 158 live_now + 12 711
    session_start5 — all 0x93/01 datagrams are fragments; the 7 short 57..67-B
    datagrams are SHORT LAST PAGES (`len == 56 + size−(cnt−1)·1024`), 10/10 across
    tapes — the "control datagrams" mis-read was retracted 2026-10-28;
    all 78 268 fragments of all taped sessions clean). **Corrections (§9.8)**:
    (1) the wire raster is **640×480** — "bogus 480" was wrong; the native helper patches
    the head copy's SOF0 dims per frame from d[44]/d[46] (@0x26dc/0x26e4, head+145/147);
    the prototype does the same now (REQ-BOL-010, suite 102/102), otherwise the bottom 120
    rows were silently clipped; (2) the native completion scan never tests page-0's mask
    bit and recycles ring slots (fid−4) without clearing buffers — the *app* accepts
    page0-loss frames with stale slot content; the prototype dropped them (deliberate
    divergence, suite 98/98) until 2026-10-29, when the report-mode transport adopted
    app-parity completion as the H-1 fix (REQ-BOL-005 amendment; suite 102/102 current);
    (3) **the user's left/top stripes were OUR OWN slicing bug** — the
    "device-side foreign content" attribution (7/10 tape frames, foreign-palette band) and
    its later "device-side top-row pipeline" refinement were both artifacts of the wrong
    `d[67:]` slice; under the wire-exact slice all 10 tape frames decode clean and every
    MCU-row edge spike vanishes (`analysis/artifacts/frag0_layout_2026-10-27/`).
    Live visual confirmation pending.
  - **No device-config, no quality control, no audio** on this unit; the "no sensor
    channel" record gains a candidate caveat: frag0's trailing 11 ASCII bytes (e.g.
    `-0214,-0894`) look like two signed sensor readouts — unverified, open (doc-04 §9.9 F).
- **Beken family (shipped-APK bytecode-derived, NOT validated on hardware; no live unit):**
  the device is a WiFi AP, video = MJPEG 640×360 over **UDP 7080**, ≤1472-byte fragments
  with a 4-byte framing header (`picId` offset 2, `pkType` offset 3), reassembled into a
  102400-byte buffer. Control datagrams from `<clinit>` fill-array payloads: `{0x20,0x36}`
  start, `{0x20,0x37}` stop, `{0x30,0x67}`/`{0x30,0x68}` voice. Orientation packets arrive on
  a separate **TCP 2271** channel (`CmdDataServer`). Live datagrams to 7080/1234/8800/63736
  produced **zero reaction** on the BL384 unit — do not mix the families up.
- **BoliU static facts** (shipped code): protocol lives in `libbl_vii_jni.so`
  (`create_instance(0, host, "8800")`, embedded JPEG heads `jpeg_header_640x360_Q5..Q100`
  at a **605-byte stride** — heads are 605 B, dispatch by announced quality byte,
  `handle_mcu_msg_frag` @0x267e–0x2698, LUT `05 0a 19 32 4b 64`, `thread_timer` 101 ms resend,
  `movw r1,#0xd9ff` EOI append).
- **USB probes**: plain **UVC** (class 239/subclass 2) via `libuvc` →
  `libUVCCamera.so`; full UVC PU controls (brightness/contrast/gain) are wired.
- Device SSID prefixes: `D100`, `BK_`. Camera gateways seen in the DEX:
  `192.168.0.1` (default), `192.168.169.1` (the live unit), `192.168.1.1`.
- Device config: the shipped app implements **no device-configuration protocol**
  (no AP→STA switch, no quality UI call). `BlSdk.setQPara` is exported but has
  zero Java call sites; the whole `com.vidure.libs.transport` provisioning SDK is
  dead code (live-confirmed: the unit runs at a fixed effective quality). See §10a/§10b
  of `analysis/01-arc42-architecture.md`.

## Working conventions

- Distinguish **static-analysis findings** (done, from DEX/.so/native inspection)
  from **empirical confirmations**. The core link protocols are now
  live-validated (`04-live-device-validation.md`): BoliU framing/ping-serve/decode ✅,
  fps profile ✅, heartbeat socket-following ✅. Still open (listed in §7 of that
  doc): heartbeat seq/drift semantics, purpose of the 11 frag0 extra bytes, UDP 63736,
  exact `TBB` type→handler map, Beken-family live confirmation (needs a unit).
- New facts for the arc42 doc / component map / proposal go as increments into
  the existing three files (`04-live-device-validation.md` is the increment log
  for the live probing), not into ad-hoc files, unless the user explicitly asks
  for a new deliverable.
- The FOSS reimplementation (planned, not started) must be: no cloud/telemetry
  (drop Huawei OBS + `api.6zhentan.com`), Android = Kotlin + OSS `UVCCamera`
  behind an owned facade; portability = Rust `scope-core` + Qt/Tauri;
  arm64-first. **Transports are per-controller-firmware — implement the validated
  BoliU UDP driver first-class and keep `DeviceTransport` pluggable for other
  controller families** (`03-reimplementation-proposal.md` §2.2). Any
  implementation scaffolding needs an explicit user go-ahead.
- **Validation prototype** (user-authorized implementation, not production): `prototype/`
  — PyQt6 client with spec-first TDD (`prototype/docs/ARCHITECTURE.md` is binding; no code
  without a REQ id). Tests: `cd prototype && QT_QPA_PLATFORM=offscreen
  /home/stefan/reveng/SL_ylz/.venv/bin/python -m pytest tests/ -q` (102 passing). App runs
  need `PYTHONPATH=src`. The six `data/jhdr_Q{5,10,25,50,75,100}.bin` heads (605 B) are the
  per-frame decode recipe of §10b.6; prior "Q100 always" test expectations are superseded.

## Verification

- Before asserting a protocol claim in a doc, check whether it has a source line
  (class/method or `.so` string) in this repo; prefer quoting the call site over
  paraphrase.
- After editing anything in `analysis/`, re-read the edited section once to
  confirm formatting (tables, Mermaid fences) stayed intact.
