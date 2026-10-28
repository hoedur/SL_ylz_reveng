# Re-implementation Proposal — FOSS replacement for the `SL+ylz` otoscope app

Status: proposal, no code yet. Based fully on the reverse engineering in
`01-arc42-architecture.md` and `02-component-map.md`, plus the empirically validated live-device
protocol in `04-live-device-validation.md` (arc42 §10b).

---

## 1. What must be reproduced (functional requirements, order of priority)

| # | Requirement | Blocking? |
|---|---|---|
| R1 | Live 640×360 MJPEG preview from **USB UVC** ear scope, ~15–30 fps, low latency | yes |
| R2 | Live **WiFi-JPEG** preview over the validated **BoliU/Bouffalo-Lab UDP protocol** (ping → UDP 8800, data → 1234, fragment reassembly + phone-side per-frame quality head) — **empirically validated against the physical unit** (`04-live-device-validation.md` / arc42 §10b) | yes (if WiFi hardware in use) |
| R2b | Compatibility driver for the *Beken*-family path (UDP 7080 + framing `{0x20,0x36}`, TCP 2271 gyro) — kept as a pluggable fallback since no live unit exists to validate it | no |
| R3 | **Optional** attitude stream + software rotation with frame↔angle pairing — only for device families that stream one (Beken: TCP 2271 packets; BoliU BL384: **none**). Sources other than the device (phone sensors, manual rotate) must be plug-compatible | yes (as optional source) |
| R4 | Manual rotate for UVC mode (90° steps) + optional: 3-axis phone-sensor assist | yes |
| R5 | Still-image capture from whatever frame is on screen (JPEG passthrough) | yes |
| R6 | Video recording: decoded frames → H.264 + (mic) AAC → MP4 | yes |
| R7 | Storage / gallery / share in a privacy-friendly way (MediaStore + system share sheet) | yes |
| R8 | Light localization (zh/en/or whatever), onboarding + permission flow | yes |
| R9 | OTA / cloud upload | **no — leave out, replaceable by Android share intents** |

Explicitly **not** to be reproduced: telemetry push (IMEI, CPU, location), Huawei OBS dependency, cleartext/invalid-TLS HTTP stack, 32-bit-only NDK.

---

## 2. Recommended architecture (cross-platform core + thin platform shells)

The insight from §4 of the arc42 doc: this app is ~90 % transport + render + encode pipelines that speak only in **bytes, sockets, and JPEG frames** — this is exactly the kind of logic that should live in a **portable core written once** with three thin shells (Android, Linux/PC, and optionally a D-Bus/IPC seam for other hosts).

### 2.1 Core: two tiers

**Tier A — "pure-BLE-ish-style" camera abstraction (portable Kotlin Multiplatform, or C+Rust/C-C++? Recommend Kotlin/JVM for Android + a Rust or C core for other OSes)**

Practical recommendation for an ambitious FOSS project (single codebase, multi-OS):

| Option | Pros | Cons | Verdict |
|---|---|---|---|
| A) **Kotlin Multiplatform + UVC-C via JNI/Cinterop** | Direct fit for Android; iOS/desktop possible via Compose Multiplatform | UVC plumbing must be hand-made per OS | 🟊 heavy investment |
| B) **Rust core crate (`scope-core`) + bindings**: `libuvc`/USB (Rust `nusb`/`libusb`), UDP-JPEG reassembly; exposed as a thin C-ABI; UIs: Android (Kotlin JNI) / desktop (Tauri/GTK/Qt/Slint) | One core for Linux/Windows/macOS/Android, tiny ABI, V4L2/WinUSB idiosyncrasies live in Rust crates (e.g. `nusb`, `v4l2r`) | You write (or wrap/patch existing OSS crates) the probe-protocol reassembly yourself, plus build tooling | 🟩 **recommended** for the cross-platform end goal |
| C) **Pure-cross-platform FFmpeg-based**: get frames on each OS with the most native path (Linux: `v4l2` kernel UVC driver → `/dev/video*`; Windows: `MediaFoundation`/`libuvc`; Android: libuvc + USB host), decode/encode via ffmpeg/pipeline, UI in Qt/QML | Best codec + hardware-encoder coverage, least "core" code | Two code bases (Kotlin for Android UI vs Qt for desktop); heavier binary | 🟊 pragmatic fast path |
| D) Straight-up **reuse existing OSS stacks**: `libuvc` POC + VLC/GStreamer pipelines on desktop, `UVCCamera` fork on Android; no shared core | Fastest to demo | Three diverging code paths → exactly the debt you now see in the analyzed app | 🟨 acceptable Phase-1 MVP |

Recommendation: **Phase 1 (MVP) with option C/D-shaped shortcuts, evolve to B as the flagship.**
Concretely:
- **Android**: Kotlin app. For UVC keep the OSS `saki4510150/USBHostCamera`-style `UVCCamera` Java library (it is OK under its license) **but through a `IPreviewSource` facade you own**; alternatively use the more current `herohan/UVCameraDemo` CameraHelper. For the WiFi mode implement the **live-validated BoliU UDP 8800/1234 client in plain Kotlin** (`04-live-device-validation.md`; no NDK needed); the Beken 7080/TCP 2271 path is a second, clearly-marked fallback module behind the same trait.
- **Linux/Windows/macOS**: a small **Rust** crate (libuvc binding / `v4l2r` for Linux, `MS Media Foundation` or libuvc for Windows, same crate for macOS), plus the same protocol modules (BoliU first-class, Beken fallback); ffmpeg/gstreamer for recording; UI: **Qt/QML or Tauri**. The Rust core can also be compiled for Android, so it becomes your portable engine behind the Kotlin facade.

### 2.2 The portable "scope protocol" modules to write first (per-device transports)

**Key design consequence of the live validation (arc42 §10b.9):** wire protocols are per-controller
firmware, not per product line — the same product family ships units whose protocols have nothing in
common (the shipped app's entire "Beken" knowledge **does not** transfer to the delivered BoliU unit).
The core therefore must expose a **pluggable `DeviceTransport` extension point**; everything downstream
consumes a uniform frame stream and treats the transport as an implementation detail.

```
scope-core/
 ├─ transport/            ← EXTENSION POINT: trait/interface DeviceTransport
 │   ├─ common            (Frame {bytes, w, h, quality?, ts}; fragment bitmap/reorder helpers,
 │   │                     sticky-target socket, ping-serve pacing timer)
 │   ├─ boliu_udp         ★ FIRST-CLASS — live-validated (Bouffalo Lab "BL384", arc42 §10b):
 │   │                     bind ephemeral UDP; ping EF 00 04 00 → device:8800 at ≤101 ms cadence;
 │   │                     receive [93][01][len16] fragments from :1234 (1091/1080-B datagrams),
 │   │                     reorder by frag index (u32@32), assemble by size (u32@40);
 │   │                     heartbeat [93][04][…16 B / 1.6 s] — optional stats only;
 │   │                     device profile: wire raster 640×480 (head SOF0 patched per frame,
 │   │                     arc42 §10b.11b), sensor channel candidate = frag0's 11 trailing
 │   │                     ASCII bytes (unverified, arc42 §10b.4), no command/quality control;
 │   │                     frame output: jpeg = embedded-header(Q<q>, q = announced byte@48,
 │   │                     SOF0-patched to d[44]/d[46]) + pages (page0 = d[56:len-11]) + FF D9
 │   ├─ beken_udp         ⬆ SECONDARY — bytecode-derived, NOT validated on live hardware:
 │   │                     7080 datagram FSM: cmd = {0x20,0x36} start, {0x20,0x37} stop;
 │   │                     framing: picId@2 pkType@3, len-4 payload, 1472 MTU,
 │   │                     reassembly into 102400-B buffer
 │   ├─ beken_tcp         (⬆ only with beken_udp: 2271 G-sensor angle packets: find 0xFF,
 │   │                     16-B fields, angle = atan2(y,x)·100/π; dev-type frames;
 │   │                     heartbeat + cmd TX — the "sex cmd" family)
 │   ├─ uvc               (libuvc-backed MJPEG frame source; V4L2 backend on Linux)
 │   └─ probe/<new>       (future controller families ship here; the packet-debug screen aids RE)
 ├─ attitude              (AttitudeSource trait: device-TCP stream | phone accelerometer | manual;
 │                         2D angle ring buffer + EMA, frame↔angle pairing hold, 360° wrap for type 86)
 ├─ render                (frame filter trait: rotate by angle → app render is trivial;
 │                         desktop = OpenGL/Qt painter, Android = GL/Surface or Canvas)
 ├─ codec                 (JPEG decode = libjpeg-turbo; encode H.264 = ffmpeg/gst/MediaCodec)
 ├─ capture               (still-file: pass-through frame bytes;
 │                         video-file: H264+AAC→MP4 via ffmpeg/gst/MediaMuxer)
 └─ session               (device lifecycle: attach/detach, AP connect hints, state machine;
                           per-transport profile: resolution, quality preset, sensor channel,
                           command set, address/discovery scheme)
```

**`DeviceTransport` capability surface** — what varies per controller, and therefore what the trait
must expose or parametrize (full evidence in arc42 §10b.9 / `04-live-device-validation.md`):

| Trait surface | BoliU/BL384 (live-validated) | Beken family (bytecode) | UVC |
|---|---|---|---|
| transport | UDP 8800 ping / 1234 data | UDP 7080 (+TCP 2271 side channel) | USB isochronous/bulk |
| framing | 56-B frag header, 1024-B pages | ≤1472-B, picId/pkType, 102400-B buffer | MJPEG frames |
| JPEG headers | none on wire → phone prepends the head matching the frame's announced quality + EOI | self-contained | self-contained |
| resolution/quality | wire raster 640×480 (§10b.11b), fixed effective quality | 640×360 nominal, `setQPara` unused by app | UVC-negotiated + PU controls |
| session | ping-serve (≤101 ms), sticky port | start/stop commands | file/FD open-close |
| attitude | none *(caveat 2026-10-27: frag0's 11 trailing ASCII bytes = unverified candidate sensor channel — arc42 §10b.9)* | TCP 2271 packets | manual/phone |
| commands | none required | `{0x20,0x36}` etc. | UVC PU get/set |

**Validated BoliU client algorithm** (complete; the only facts needed to talk to the physical unit):

1. Bind an ephemeral UDP socket.
2. Send `EF 00 04 00` to `ip:8800` every ≤80–100 ms (delivery stops ~101 ms after the last datagram;
   any payload to 8800 keeps the stream target alive; a single ping yields ~1 frame).
   *(Caveat 2026-10-26/27: "keeps the target alive" ≠ guarantees sustained delivery — our report-mode
   sessions (EF-02/EF-08 replay, EXP1–3) open but then halt; sustained report-mode delivery is
   device-condition-open, H-1, doc-04 §9.6 D / §9.9 C.)*
3. Receive on the same socket (source port 1234):
   - `len == LE16@2`, `type@1 == 1` → fragment: `idx = u32@32`, `cnt = u32@36`, `size = u32@40`;
     page data = `d[56:len-11]` for frag0 (1024 B; 11 TRAILING ASCII metadata bytes at
     `d[len-11:len]` — REQ-BOL-004 amended 2026-10-27) or `d[56:]` for others (last = fragment of
     `size` remainder); set bitmap bit `idx` — fragments may arrive out of order.
     *(Reassembly key = (u32@8 frame id, size); under ping-only delivery the id cycles in a small
     set {1..3} (monotonic under the app's report mode, where it equals the report fid) — 2026-10-28
     gate rounds 1+2, doc-04 §9.9 G/§9.10.)*
   - `type@1 == 4` (16 B) → heartbeat (optional).
   - When all `cnt` bits set → frame complete.
4. Emit frame bytes = `jhdr_Q<q>_bin (605 B, q Low-byte of announced u16@48 — heads from the .so),
   SOF0 dims patched per frame to the announced (w,h) = 640×480 (BE16 at head+145/147; arc42
   §10b.11b) + Σ pages in idx order + FF D9` → stock JPEG decode, 640×480 RGB
   (amended 2026-10-27; the "Q5..Q75 fail to decode / q is not the selection key" claims were
   retracted 2026-10-24 — the announced quality byte IS the head-selection key).
5. Jitter-normalize: device delivers in bursts (~25 fps intra-burst) with ~0.5 s stalls (~3–4 fps
   effective); buffer on the display side.
6. Device reboot/power-cycle clears the stream target — re-arming happens automatically via the pings.

For the **USB mode**: the probe class 239/2 means you can rely on the OS's built-in UVC stack on desktops (a huge simplification vs the Android side). `libuvc`'s frame format constants on Android are the same — so it's one UVC surface for Linux/Windows/macOS/Android.

### 2.3 Android shell specifics

| Concern | Approach |
|---|---|
| UVC | Kotlin + `UVCCamera` OSS lib (already 32/64-bit in recent forks): USBMonitor → UsbManager.requestPermission → `UVCCamera.setPreviewSize(640,360, PIX_FMT_MJPEG)` → `startPreview(surface)` |
| USB attach routing | same `USB_DEVICE_ATTACHED` filter + `device_filter.xml` (class 239/sub 2) |
| WiFi probe | plain Kotlin `DatagramSocket` + `Socket`, `ConnectivityManager.registerNetworkCallback` to steer the user to the probe AP |
| Rotation | apply attitude-stream rotation on the GL shader (single vertex-transform) — replace the old 3-spotwise Matrix/Bitmap path with one rotation uniform per frame; the 2-frame angle hold that softens display jitter is preserved as a small `Pairing` stage |
| Recording | `MediaCodec`+`MediaMuxer` (currentColorFormat surface path) → MP4; reuse the correct herohan path only |
| Storage | MediaStore `Pictures` / `Movies`, sharing with system `FileProvider`/SAF — no OBS |
| Permissions | androidx ActivityResult API, no XXPermissions dependency |
| FOSS hygiene | 100 % open deps; no cleartext traffic except the probe LAN; no telemetry |

### 2.4 Desktop shell specifics (Linux first)

| Concern | Approach |
|---|---|
| UVC | Linux: the camera appears at `/dev/video*` via kernel uvcvideo — use **V4L2** (`v4l2r` in Rust / QCamera in Qt); no libusb needed |
| WiFi probe | `scope-core` UDP/TCP modules; NetworkManager / `wpa_supplicant` hints in the UI |
| Render | Qt RHI / OpenGL texture per frame, rotate uniform, window scaling |
| Recording | ffmpeg via `libav` API (or GST pipeline): `mjpegdec → h264enc (hevc/h264, vaapi/nvenc)` → MP4 |
| Still | write the JPEG payload directly (no recompression → zero quality loss) |
| Windows | same Rust crate with `libuvc`/WinUSB matching the 0xEF/0x02 filter (driverless via WinUSB interface UVC) |

### 2.5 Where "IMU"/attitude could be *better* (opportunity)

The stock app streams a 2D roll angle only — **and the delivered BoliU unit streams no attitude at all**
(the heartbeat drift word is not a sensor)*(caveat 2026-10-27: frag0's 11 trailing ASCII bytes are an
unverified candidate sensor channel — arc42 §10b.9; candidate REQ-BOL-011)*. For the FOSS replacement the attitude source is a pluggable
strategy (R3):
1. **Device stream parser** (Beken families): parse the same TCP-2271 2D packets for absolute compatibility — used only when a device family actually provides the channel.
2. **Phone-sensor fallback (now the default for BoliU units)**: use the phone's `TYPE_ROTATION_VECTOR` / accelerometer. The stock app already implements this fallback for type-16 devices, so the UX pattern exists.
3. **Manual rotate** always available (UVC-style) for when the phone-fusion angle is not wanted.
4. Provide a "show raw sensor/packets" debug panel in the UI showing FPS + angle + transport stats (replacing `FpsStatis`) — this becomes the developer's packet debugger and the community's protocol reverse-engineering aid for yet-unknown controller families (the §2.2 extension point).

### 2.6 Testing / dev plan outline

1. **Phase 0 (done)** — static analysis (`01`/`02`) + live protocol validation (`04`, arc42 §10b):
   framing, ping-serve model, decode recipe and throughput profile are empirically confirmed;
   the "sniff-the-wire" plan item of the original proposal is fulfilled by `04-live-device-validation.md`.
2. **Phase 1 — Android MVP (UVC + WiFi/BoliU)**: repo-first path is now the **validated BoliU UDP
   driver + per-frame-quality decode recipe**, alongside the UVC shell; record via MediaCodec; still capture is a
   frame passthrough (already a complete JPEG!). Remaining pre-code work: none for the core video path.
3. **Phase 2 — attitude pluggability** (phone-sensor fusion default, device-TCP parser for Beken units, manual rotate), recording polish.
4. **Phase 3 — Beken-family driver module** implementing the bytecode-derived protocol behind the same trait (re-validate opportunistically whenever a matching unit appears).
5. **Phase 4 — desktop Rust core + Shell (Qt/Tauri)**; the same protocol modules are the Rust `scope-core` crates.

## 3. Technology summary (recommended stack)

| Layer | Android | Linux/Win/macOS |
|---|---|---|
| Language | Kotlin (JVM) | Rust core + Qt/QML (or Tauri) |
| UVC access | OSS `UVCCamera` (libuvc) behind facade | kernel uvcvideo / libuvc / MediaFoundation |
| WiFi-JPEG | **BoliU UDP 8800/1234 client (validated)**; Beken 7080 FSM as fallback module | Rust crate (same protocol modules) |
| G-sensor | optional: TCP 2271 parser (Beken only) / phone sensors | optional; same |
| Decode | libuvc→NV21 + `BitmapFactory`/jpeg-turbo; **WiFi: jhdr_Q<q> + pages + EOI → stock JPEG** | ffmpeg (libjpeg-turbo inside) |
| Encode | MediaCodec H264 15 fps, AAC 64k/44.1k mic → MediaMuxer MP4 | ffmpeg vaapi/nvenc/h264 + aac → MP4 |
| Rotation | GL shader rotation-uniform (attitude source = device TCP packets or phone sensors or manual) | GL/Qt painter |
| Capture | frame JPEG passthrough → MediaStore; system share | file save; normal FS |
| UI | Jetpack Compose (Material 3) | Qt quick / Tauri web |
| Telemetry | **none** | **none** |

## 4. Risks / unknowns to watch

**Core video path: no blocking unknowns remain** (validated end-to-end against the physical unit,
`04-live-device-validation.md`). Remaining open items, all non-blocking:

- ~~Exact UDP framing semantics~~ — ✅ resolved by capture (arc42 §10b.4); the 4-byte framing, fragment
  indexes and sizes are pinned and integrity-checked.
- Heartbeat internals: the `seq` field changed semantics after a device reboot (+1/beat → constant);
  drift word `5e xx` is not an accelerometer value. Passive stats only — no design impact.
- The 11 extra bytes on every first fragment — **resolved 2026-10-27 (reversal)**: TRAILING ASCII
  metadata at `d[len-11:len]`, candidate sensor readouts (§9.9 F / arc42 §10b.9); ignored safely by
  the validated recipe (page slicing excludes them), surfaceable later as a sensor event (candidate REQ-BOL-011).
- `sendSexCmd`/`sendHBCmd` control bytes (type-86 family) — bytecode-built at runtime; only relevant
  if such a unit is ever driven.
- Quality control (`setQPara`): never exercised by the app, no live effect; the device self-varies quality per frame (25/50/75) and the client must select the matching embedded head (605 B; §10b.6, corrected 2026-10-24); treat device quality as fixed per family (profile table in §2.2).
- armeabi-v7a payload of the vendor — new build can and should be **arm64-first**.
- Controller zoo: the delivered unit is BoliU *this-firmware*; the Beken driver cannot be live-verified
  until such a unit is in hand (hence the pluggable trait + the packet-debug screen).
