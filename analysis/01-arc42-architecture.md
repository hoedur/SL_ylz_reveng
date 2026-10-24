# arc42 Architecture Documentation — "SL+ylz" Wi-Fi/USB Ear Otoscope App

Reverse-engineered from `SL+ylz_V1.0.23.251121_APKPure.xapk`\
Package: `com.xiaozhen.beauty.shenglong` · Version 1.0.23 (code 23) · minSdk 23, targetSdk 35\
Analysis date: 2026-10-17 (live-device validation 2026-10-23/24, §10b) · Method: manifest/resource decode (androguard), DEX bytecode inspection, native `.so` symbol/string analysis

---

## 1. Introduction and Goals

An Android consumer app for three related probe devices sold under one product family:

1. **Ear mirror / otoscope with integrated camera** (WiFi based), types 85 (ear mirror), 87 (teeth-cleaning mirror), 86 ("SEX" type — an adult-oriented full-360 variant with distinct packet framing), 16 ("XiHeiTou", a device **without** a G-sensor).
2. A **USB (UVC) ear scope** variant supported in addition to the WiFi variant.
3. Full text/video manual playback and sharing, plus vendor cloud connectivity (usage telemetry + OTA file distribution).

### Quality goals
- Very low-latency 640×360 preview (~15–30 fps) of a probe camera that is moved inside the ear canal.
- **Auto-orientation of the video** by the device's G-sensor (accelerometer only, no gyroscope / no 3D attitude) so the visible image stays "upright" while the user rocks the probe.
- Offline-first: no account needed for preview; cloud is an optional background feature.
- Support a wide zoo of camera SoC/API families for future devices (Vidure SDK: Allwinner, Hisilicon, MStar, NVT, Goplus, Jieli, Nello, Beken, BoliU, USB-UVC).

### Stakeholder / threat context (user's motivation)
The app is closed-source, phones home, and its privacy posture is poor (see §10.4). The decision context of this document: gather enough API/protocol knowledge to build a **FOSS replacement** on Android + Linux/Windows/macOS.

---

## 2. Constraints

| Constraint | Evidence |
|---|---|
| minSdk 23 / targetSdk 35 | Manifest |
| `android.hardware.usb.host` (required), `android.hardware.usb.accessory`, `CAMERA`, media/storage permissions, `FOREGROUND_SERVICE` | Manifest |
| USB device filter: **class 239 (0xEF, AV class from IAD), subclass 2** → standard UVC camera with interface association | `res/xml/device_filter.xml` |
| App must be launched by/attached to USB device attach (`USB_DEVICE_ATTACHED/DETACHED` intent filters) | Manifest |
| Text-traffic (HTTP) allowed globally | `network_security.xml` (`cleartextTrafficPermitted="true"`) |
| Native code only built for **armeabi-v7a** (no arm64!) — works only via 32-bit ABI or vendor support | `config.armeabi_v7a.apk` |
| Device camera is a WiFi AP. Two controller families ship: "Beken"-driven units (Java stack, UDP 7080, default IP `192.168.0.1`) and **BoliU/Bouffalo-Lab units** (native stack, UDP 8800/1234). The delivered physical unit is a **BoliU "BL384"** (§10b): MAC OUI `F4:42:50` (Bouffalo Lab Nanjing), IP `192.168.169.1`, UDP-only. For unit types, `BlSdk.start(ip)` / `BekenSdk.start(ip)` take the IP as a parameter | DEX + `notes.md` nmap + §10b pcaps |
| Sensor hardware on device = 2-axis accelerometer ("G-sensor") on the **Beken** family, reported over its own TCP channel; **no gyroscope in any family**. *The validated BoliU unit streams no sensor channel at all* (§10b) | `GsensorParser2D`, 2D angle math only + §10b |

---

## 3. Context and Scope

```
                      ┌────────────────────────────┐
   WiFi variant       │  Ear-otoscope probe device │      USB variant
   ┌────────────────► │  camera MCU + WiFi SoC     │ ◄──────────────┐
   │  Beken: UDP 7080 │  (Beken ── Java driver     │  USB UVC       │
   │  TCP 2271 gyro   │   BoliU ── native driver)  │  (MJPEG)       │
   │  BoliU: UDP 8800 └────────────────────────────┘                │
   │  /1234 ←─ live unit                                            │
   │                                                    ┌──────────┴─────────┐
┌──┴──────────────┐                                     │  PC / Android      │
│ WiFi AP/phone   │   HTTPS                             │  FOSS replacement  │
│ hotspot on phone├─► https://api.6zhentan.com:8443 ▲──►└────────────────────┘
└─────────────────┘   (app gateway, Huawei OBS SDK) │
```

> Live validation (§10b): the delivered BL384/BoliU unit exposes **no TCP at all** — the "TCP 2271 gyro"
> channel exists only in the shipped APK's Beken code path and is not part of this unit's firmware.
> The BoliU protocol rides entirely on UDP (device ports 8800/1234 + a client-chosen ephemeral port).

- The phone connects directly to the device (USB or the probe's WiFi AP).
- Vendor cloud (`api.6zhentan.com:8443`) is used for app-gateway calls and telemetry push ("TerminalClient": IMEI/hardware model/CPU info, app vendor & version, location field); files (recordings, OTA packages) are transported with a bundled **Huawei OBS (Object Storage Service) client**.
- No message/1:1 image upload to the probe device; uploads go to the vendor cloud only.

---

## 4. Building Block View (whitebox)

### 4.1 Level 1 — overall modules

| Module (package) | Responsibility | Origin |
|---|---|---|
| `com.xiaozhen.beauty.ui.*` (74 classes) | Activities: Splash, Home, Connect, Help, Preview, PreviewFull, PreviewUsb, LicenseAgreement; custom widgets (MySurfaceView, PlayerControllerGestureLayout, PressImageView) | In-house |
| `com.xiaozhen.beauty.lib` | Device abstraction (`ISocSdk` with `SOC_BEKEN`, `SOC_BOLIU`, `SOC_USB`), `DevType`, params, language, storage | In-house |
| `com.xiaozhen.beauty.lib.beken` | Beken-chip probe driver: UDP JPEG stream reassembly | In-house (+ vendor protocol) |
| `com.xiaozhen.beauty.lib.jpeg` (`BlSdk`, TAG="Bl384SDK") | BoliU probe driver: native UDP client in `.so`, JPEG frame + MCU/ctl-msg callbacks | Vendor (JNI) |
| `com.xiaozhen.beauty.lib.tcp` (`CmdDataServer`) | TCP control/G-sensor channel to the WiFi probe | In-house |
| `com.xiaozhen.beauty.lib.gyro` | G-sensor angle packet parsers: `GsensorParser2D`, `GsensorParserSimple2D`, `GyroParser2DOld`, `FpsStatis` | In-house |
| `com.xiaozhen.beauty.lib.encoder`, `lib.opengl`, `handler.RecordHandler` | Recording pipeline clone of serenegiant's encoder + custom EGL bitmap recorder | Copied from serenegiant UVCCamera sample |
| `com.xiaozhen.beauty.handler.cloud` | Cloud: `SvrApi` (gateway), `PhoneNao`/`PhoneService` (device intelligence push), Huawei OBS usage | In-house + Huawei SDK |
| `com.serenegiant.usb / encoder / opengl / widget` | Full open-source **UVCCamera library by saki4510150** (USBMonitor, UVCCamera, GLRenderer, EGLBase, Media*Encoder, MediaMuxerWrapper) | OSS copy (MIT-ish) |
| `com.serenegiant.uvcapp` → exposed as `com.herohan.uvcapp` | CameraHelper / ImageCapture / VideoCapture high-level UVC facade (herohan fork of the library) | OSS copy |
| `com.vidure.libs.*` | Generic camera-SoC transport stack (TCP/UDP/HTTP, SoC response phrasers, parallel downloader, OTA) | Vendor OSS ("Vidure") |
| `com.obs.*`, `com.oef.*` | Huawei **OBS/OEF** object-storage client SDK | Vendor |
| `okhttp3/okio`, `jackson`, `hutool`, `commons-compress`, `XXPermissions (com.hjq.permissions)`, AndroidX, Material, Coroutines, `libjpeg-turbo212` | Utility libraries | OSS |

### 4.2 Level 2 — the three "camera transports"

#### T2.1 WiFi/Beken UDP mode (`BekenSdk`, `SOC_BEKEN`)
- Camera is a WiFi AP; default address `192.168.0.1` (`XXX_DFT_IPADDR`), **UDP port 7080**.
- Phone binds a UDP socket (local port 7080, 100 ms poll loop), sends 2-byte control datagrams from `<clinit>` (fill-array payloads `0x20 0x36` (start image), `0x20 0x37` (stop image), `0x30 0x67`/`0x30 0x68` (voice)) to `CAMERA_IP:7080`; `CMD_START_OTA` also present (size 100-byte OTA chunks, `UDP_OTA_SIZE=100`).
- Receives frames split into **UDP datagrams of up to 1472 bytes** (`UDP_PKT_SIZE`); `parseAFrame()` demultiplexes payload: byte [2] = picture ID, byte [3] = packet type / sequence, payload length `len − 4`; reassembles JPEG in a **102400-byte** buffer; two SDP-level frame counters (`curPicId`, `curPicPkgCnt`) detect end-of-frame.
- Delivers full JPEG frame bytes to `BlSdk$JpegListener.showJpeg(byte[] data, long ts, byte b, byte[] extra)`.

#### T2.2 WiFi/BoliU native mode (`BlSdk`, `SOC_BOLIU` — TAG `Bl384SDK`)
- Same transport family but implemented **natively in `libbl_vii_jni.so`**: the JNI lib itself creates the UDP socket (`bind`, `sendto`, `getaddrinfo`, `thread_recv`, `thread_timer`), does MCU message handling (`handle_mcu_msg_ctlmsg`, `handle_mcu_msg_frag`, `queryinfo_resp`, `build_send_ack`).
- Exported NDK procs: `mjpeg_ndk_startup/start/stop/command_send/queryinfo_cmd_send/set_active_camera_index/set_QPara/frame_callback_register/ctlmsg_cb_register`.
- Distinguishing detail: static **JPEG headers for 640×360 @ Q5..Q100** are embedded in the .so — the native lib reconstructs a valid JPEG by patching/quantized headers when the MCU only streams payload fragments.
- Camera resolution profile: **640×360 JPEG**, quality configurable (`setQPara(int…)`), `setActiveCameraIndex` — two cameras possible.
- **→ Live-validated protocol of this driver (device ports 8800/1234, `EF`/`0x93` token framing, ping-serve paging, full fragment-header field map and the working Q100 decode recipe): §10b.**

#### T2.3 USB/UVC mode (`SOC_USB`)
- Standard **UVC** camera discovered by `USBMonitor` (serenegiant) with `device_filter.xml` (class 0xEF/0x02).
- libuvc (with MJPEG **and H264** format support in the tree) + `libUSB1.0` + saki's `libUVCCamera` JPEG→NV21/RGB preview via GL.
- High-level wrap via `com.herohan.uvcapp.CameraHelper` (+ `ImageCapture`, `VideoCapture`).
- No G-sensor channel in UVC mode → rotation is manual (`imgRotateBtn`, `isRotate`, `initRotate`).

### 4.3 G-sensor channel & orientation model

- **Transport**: for WiFi probes, separate TCP socket (`CmdDataServer`, **port 2271**, default 10 s conn timeout, 8 KB buffer) carrying small binary packets. This channel is bidirectional: app also sends "sex command"/heartbeat (`sendSexCmd`, `sendHBCmd`) into it.
- **Packet** (`GsensorParserSimple2D.onAngleData`): start marker scan for `0xFF`, then a payload block of predictable length (positions +4/+5, +9/+10 = 16-bit little-endian raw values; +7/+8, +11/+12 for the 87-type). Conversion: `angle_deg = atan2(y_raw, x_raw) × 100 / π` (double constants `0x4059000000000000`=100.0, `0x400921FB54442D18`=Math.PI). Types 86 (360°) use a different lay­out with a wrap-around area (`entered360Area`, `MAX_LEN_SEX`).
- **Device-type detection** arrives on the same channel (`onDeviceTypeData`: byte5=0xFF, byte2=type → 85/86/87/16).
- **Parser strategy**: `GsensorParser2D` keeps a ring-buffer of the last N angles (`GDATA_CACHE_SIZE` derived from 2×2 samples, filter step `filterData` = simple slope/EMA) and pipelines each displayed frame with the **angle at the time the image was taken** (image cache `MAX_IMG_DATA_CACHE=2`); `showImgData()` pairs the freshest JPEG with the freshest angle.
- **Where the rotation happens**: 100 % **in the app**. `PreviewActivity/PreviewFullActivity$RefreshFrameThread` builds an `android.graphics.Matrix` per frame (`postTranslate` → `postScale` → `postRotate`) and draws the JPEG-derived bitmap onto a `SurfaceView`. `ImgUtils.rotaingImageView()` does the same for stills.
- **Phone-sensor fallback** (`PreviewActivity.onCreate`): registers the phone's own accelerometer with `SensorManager`; `onSensorChanged()` → `GsensorParser.onPhoneGData()` → angle is used instead/combined when `DevType.isGSensor()` is false (type 16 "XiHeiTou"). Since the phone can only know *its* rotation, this fallback is a UI aid, not a true device-attitude source.

### 4.4 Recording pipeline (UVC + optional audio)

- Video: `MediaVideoBufferEncoder` / `MediaSurfaceEncoder` — **MediaCodec `video/avc` (H.264)**, `FRAME_RATE=15`, `BPP=0.63` → bitrate ≈ width×height×0.63×fps (e.g. 640×360 ≈ **3.4 Mbps** target, `calcBitRate`).
- Audio: `MediaAudioEncoder` — **AAC-LC (`audio/mp4a-latm`)**, 44.1 kHz, 64 kbps, 1024-sample frames (mic of the phone, not the probe).
- Container: `MediaMuxerWrapper` → `MediaMuxer` (**MP4**); `RecordHandler` offers a second, custom EGL-FBO+Bitmap path for the JPEG sources (draws each frame with rotation, then encodes through the same H.264 encoder).
- Still images: `ImageCapture`/`ImageSaver` (CameraCapture pipeline of herohan fork) → JPEG/PNG file, shared via `FileProvider` (`com.xiaozhen.beauty.shenglong.fileprovider`).

### 4.5 Cloud & file layer
- `SvrApi.APPGW_RELEASE = https://api.6zhentan.com:8443`, constant names `API_IOT`, `PUSH_TERMINAL_CLIENT` (telemetry).
- `PhoneNao.pushTerminalClient()` posts a `TerminalClient` payload: appVendor, appVersion, imei (self-generated or real), model, osInfo, location → the vendor server.
- Huawei **OBS** client (`ObsClient`) for upload/download (recordings, OTA tar/zip; Apache commons-compress stocks un-tar/unzip; parallel HTTP downloader).
- `HttpTransport` supports all the SoC-specific response dialects (`AllWin`, `Hisilicon key=value;`, `MSTAR`, `Nello`, `NVT XML`) → used for **OTA / config file download** in the same family of products.

### 4.6 Permissions & runtime services
- Runtime permission flow: `XXPermissions` (com.hjq) → camera, storage (media images/videos on 13+, legacy external on ≤12).
- `ConnectivityManager` + `NetworkCallback` (`HomeActivity$MyNetworkCallback`), WiFi state access to detect/group the probe's AP.
- USB: `USB_REQUEST` flows only via `UsbManager.requestPermission` (implicit in USBMonitor); app is killed/relaunched by system when the device attaches (no service on 24/7: `FOREGROUND_SERVICE` is declared but unused).
- NDK/R8: 3 dex files, multidex, Baseline Profiles (`profileinstaller`), `largeHeap`, R8 full-mode minification (heavy renaming, e.g. `BekenSdk$$ExternalSyntheticLambda0`), `-$$Nest$` accessor synthetic layer.

---

## 5. Runtime View (sequence — WiFi probe, "open preview")

1. `SplashActivity` → license check → `HomeActivity` → `ConnectActivity` (or system USB-attach event for UVC).
2. App ensures phone is on the probe's WiFi AP (network callback / user guidance).
3. `PreviewActivity` instantiated: `ISocSdk.getSocSdk()` returns BEKEN/BOLIU/USB depending on `DevType`/route.
4. Beken path: bind UDP socket (port 7080) → send `CMD_START_IMG` to `CAMERA_IP:7080` → receive thread loops `DatagramSocket.receive()` → `parseAFrame()` → on last fragment of a picture ID, emit JPEG.
5. In parallel: `CmdDataServer.start()` → TCP 2271 → `GsensorParser.onAngleData()` ring buffer.
6. JPEG frames decoded by `BitmapFactory` (or jpeg-turbo for BoliU via JNI), paired with latest/assigned angle.
7. `RefreshFrameThread` pops frame → `Matrix.postTranslate/postScale/postRotate(angle)` → draws on `MySurfaceView` (15–30 fps target, `FpsStatis` measures both image and G-sensor FPS to detect desync).
8. Record: user taps record → `RecordHandler.startRecording(EncoderConfig(w,h,eglCtx,bitRate,path))` → H.264+AAC → MP4 via `MediaMuxer`; `handleFrameAvailable()` forwards each rendered frame (with rotation) into the encoder input.

(UVC probe: system `USB_DEVICE_ATTACHED` → `Screenshot... USBMonitor.register` → `requestPermission` → `UVCCamera.open` → `setPreviewSize(..., PIXEL_FORMAT_MJPEG...)` → `startPreview(surface)` → GL render; `VideoCapture` optionally encodes H.264 from the GL surface.)

---

## 6. Deployment View
- Single APK (XAPK = base + splits: `config.fr/en/...` language, `config.mdpi` density, `config.armeabi_v7a` ABI).
- All video stack logic is client-side; backend is a single HTTPS gateway plus S3-compatible (Huawei OBS) buckets.
- Device firmware isn't shipped in the APK (no assets besides profile/profileinfo); OTA is downloaded from backend if needed.

## 7. Cross-cutting Concepts
- Message model: hardware protocols are raw byte streams; control messages JSON (jackson, hutool `JsonUtils` with generic key layout).
- Concurrency: `HandlerThread + Message` (RecordHandler), `VThreadPool/VSingleThreadPool` wrappers, coroutines for UI.
- Error/uncertainty: every uploader/wrapper swallows exceptions (silent failure), log via custom `VLog` (creates **log ZIPs stored for crash collection**).
- Locale: app-side language switch (`LanguageMgr`, splits per language).

## 8. Architecture Decisions (their builder's, as far as reconstructable)
1. Reuse the widely copied saki4510150/UVCCamera stack instead of a MediaCodec-based UVC plumbing — fastest route to a working UVC preview on Android.
2. Handle the "cheap ear-probe" SoCs by two in-house thin drivers (Beken UDP / BoliU native SDK) instead of the generic `vidure` transport code they already bundle.
3. G-sensor streamed as *angle packets* to the app and rotation applied **software-side** per frame, so the server/devices stay dumb and cheap (no display in device).
4. Cloud features are secondary: everything essential (preview/capture/share) works over the USB/WiFi link alone.
5. armeabi-v7a-only native build → across-board 32-bit SHAs. (This will be a compliance problem from now: Play Store requires 64-bit; the app gets to work only on 32-bit emulations.)

---

## 9. Risks / Technical Debt in the Shipped App
- `usesCleartextTraffic=true` globally; TLS verification is bypassed in `vidure` HTTP client (`checkClientTrusted`/`checkServerTrusted` no-ops, `X509TrustManager` accepting all).
- Telemetry payload includes **IMEI, CPU info, hardware model, phone/system version** to the vendor; app runs on 32-bit-only.
- Large OSS code copied with each project's `R*` classes duplicated ×3 → 3× class count, 3 dexes.
- No IMU — rotation drifts when the probe is rotated about its own axis (2D accelerometer "level" only, no absolute bearing), no "yaw lock", angle noise filtered only by fixed smoothing.
- Secret constants in plain bytecode (`api.6zhentan.com`), JNI SDK without docs; the whole `vidure` transport (20+ SoC dialects) is dead weight for this exact product.

---

## 10. Answers to Your Three Main Questions

### 10.1 How is the image data transported to the smartphone?
Two independent transports:
1. **WiFi probes (default)**: the phone connects to the probe's **WiFi access point**. Two controller families exist:
   - **Beken** units (shipped-APK Java driver): **UDP port 7080** on the AP subnet (`192.168.0.1` default). Control datagrams and reassembly handshake also on 7080; G-sensor angle packets on a **separate TCP socket, port 2271**. Phone binds UDP locally to 7080 and sends start/stop/voice 2-byte commands; frames arrive as ≤1472-byte fragmented JPEG with 4-byte framing header + app reassembly into a 102 400-byte buffer (bytecode-derived; *no live unit matched this driver*).
   - **BoliU/Bouffalo-Lab units** (shipped-APK native driver `libbl_vii_jni.so`; **the delivered physical unit is this type**, §10b): **UDP 8800** (control + ping gate) / **1234** (data source port), no TCP, no G-sensor channel*. Fragmented JPEG, phone reassembles and prepends its own JPEG header; validated field map + decode recipe in §10b.
2. **USB probes**: image data over **USB host with UVC (USB Video Class)**, i.e. standard isochronous/bulk transfer of an **MJPEG** elementary stream, provided by libusb1.0 → libuvc → `libUVCCamera.so` JNI bridge. (Native code also contains H264 format branches, so the camera is UVC MJPEG first and probably can do H264 too if a different UVC profile is requested.)

### 10.2 Video stream details
- **In-flight (transport) format = JPEG/MJPEG**, **640×360 pix**, native stack contains fixed JPEG headers for quality Q5–Q100 with MJPEG payloads (`jpeg_header_640x360_Q10 … Q100` in `libbl_vii_jni.so`), so every frame is an **independently-coded JPEG (intra-only "MJPG")** — no GOP, no B-frames, trivially cuttable.
- Bitrate: implicit from JPEG quality/fragment size; typical such probes run ~8–15 fps ≈ **1–4 Mbps**, controlled via `setQPara` (quality) — not an encoder bit rate ceiling.
- No audio in the stream; recorded audio is the phone mic (AAC 44.1 kHz/64 kb/s), muxed on-device.
- Recording output: **H.264 MP4**, encoded by Android MediaCodec from the decoded/rendered bitmaps/GL surface (target bitrate ≈ width·height·0.63·15).
- Static still capture = one of the in-flight JPEG frames written to file, no re-encode needed in the clean path.

### 10.3 Is there an IMU / how is orientation used; who rotates?
- **There is a 2-axis accelerometer ("G-sensor") on the device, not a (3-axis) IMU.** No gyroscope, no magnetometer, no quaternions — the app deals only in a single roll angle in degrees in a [-100…+100]-ish 2D frame (`atan2(y,x)·100/π`).
- The angle data is **transported out-of-band** from the video: over the probe's **TCP 2271** channel in the *Beken* WiFi mode; it is not embedded in the UVC/USB mode at all. **The delivered BoliU unit exposes no sensor channel on any port (live-verified, §10b)** — its firmware streams no orientation data, so a FOSS client must fall back to the phone's own sensors or manual rotation for such units.
- **Rotation is applied 100 % in the app**: WiFi mode computes `Matrix.postRotate(angle)` per displayed frame (with a 2-frame-deep image/angle ring buffer and an EMA-like filter + boundary handling for the 360° wrap-around of type 86), then draws the rotated bitmap on the SurfaceView. UVC mode offers a **manual** rotate button (no sensor data available).
- The **device itself does not rotate** the video (no on-device codec or image flip detected; device has no image-processing path in any of the three modes).

---

## 11. System-Infrastructure Elements Used (Android APIs / JNI)

| Domain | API / element | JNI boundary |
|---|---|---|
| USB host | `usb:UseManager`, `UsbDevice`, `USB_DEVICE_ATTACHED` activity filter, `UsbRequest`/`usbfs` via `libusb1.0.so` | `libUVCCamera.so` (Java_com_serenegiant_usb_UVCCamera etc.) |
| Camera | **not** started via `android.hardware.camera*` for the probe (that perm is for WiFi-mode?), neither for Camera2 pipelines — the UVC stack replaces camera HAL | `libUVCCamera.so` |
| Media | `MediaCodec` (H.264 enc, AAC enc), `MediaMuxer`, `AudioRecord` (mic) | none (pure Java/Kotlin) |
| Graphics | `SurfaceView`, `SurfaceTexture`, `EGL14/EGL10`, OpenGL ES 2.0 shaders(external OES, Tex2D); `Matrix`, `BitmapFactory` | none |
| Sensors | `SensorManager`, `SensorEventListener` (phone accelerometer fallback) | none |
| Net | `ConnectivityManager`/`NetworkCallback`, `WifiManager` (add/access network), plain `DatagramSocket/Socket/ServerSocket` | `libbl_vii_jni.so` (BoliU UDP) |
| Storage | MediaStore/ individual `File` + legacy external storage path via `BaseStorage`; sharing via **`FileProvider`** (androidx) | none |
| Process | multidex, `androidx.startup` (emojiCompat, lifecycle, profileinstaller), `ProfileInstallReceiver`, `JobServiceEngine` unused | none |
| Permissions | `XXPermissions` library fragment-based permission flow | none |

**JNI native symbols inventory:**
- `libbl_vii_jni.so`: `Java_com_xiaozhen_beauty_lib_jpeg_BlSdk_onDestroy/onStart/setActiveCameraIndex/setQPara` (+ non-JNI `mjpeg_ndk_*` C API).
- `libUVCCamera.so`: JNI bridge `com/serenegiant/usb/UVCCamera` and `UVCControl`, implemented on **libuvc** (which supports formats `MJPEG, H264, YUYV, UYVY, NV21/NV12, GRAY*, BAYER*`).
- `libjpeg-turbo212.so`: Turbo-JPEG (used by the native MJPEG decode/compress path).

---
## 10a. Device configuration surface
Findings from a full DEX string-pool cross-reference sweep (V1.0.23):

- **Camera IP**: not hardcoded at call sites — `BekenSdk.start(ip)` / `BlSdk.start(ip)` take it as a parameter; `PreviewActivity`/`PreviewFullActivity` fall back to hardcoded `192.168.169.1` when the passed value is empty/invalid. `HomeActivity$DetectRunable` auto-detects camera mode: phone's own IP contains `192.168.169.` or WiFi SSID contains `D100` / `BK_` (probe SSID prefixes). Subnets seen: `192.168.0.1`, `192.168.1.1`, `192.168.169.x` (gateway `192.168.169.1`).
- **WiFi AP↔STA switching / joining an existing WLAN**: *not implemented*. `ConnectActivity.onActionWifiSetup()` only opens the Android system WiFi panel (`SystemUtils.openWifiPanel`); the user manually joins the probe's hotspot. No SSID/password/config command is ever sent to the device.
- **Image quality (WiFi probes)**: `BlSdk.setQPara` / `setActiveCameraIndex` are exported JNI functions but have **zero Java call sites**; only `getInstance / setJpegListener / start / stop` are used. Firmware supports variable JPEG quality (embedded Q5..Q100 header table in `libbl_vii_jni.so`), but the app never exercises it at runtime. **Live corroboration (§10b): the delivered unit streams at a fixed effective quality and ignores the announced quality byte for decode purposes; no quality control could be exercised on the wire.**
- **UVC hardware controls (USB probes)**: complete UVC Processing-Unit control set is exposed by the serenegiant wrapper — `PU_BRIGHTNESS_CONTROL`, `PU_CONTRAST_CONTROL`, `PU_CONTRAST_AUTO_CONTROL`, `PU_GAIN_CONTROL` (UVC `D0/D1/D18/D9`), with get/set + limit probing (`nativeObtain*Limit`). This is the real, usable quality/exposure channel for USB devices.
- **Dead provisioning SDK**: the full `com.vidure.libs.transport` stack (HTTP device login `DEV_LOGIN_SESSION_REQ_NVT/_VY`, TCP/UDP transports, SoC response parsers for **Hisilicon, MStar, NVT, Nello, AllWin, Goplus, Jieli**) is bundled but **never invoked** from any `com.xiaozhen` class; the orphaned config key `XXX_DFT_IPADDR` ("XXX" = vendor placeholder) sits unreferenced in the string pool.
- **Sample/fps/bitrate parameters** are compile-time constants (44.1 kHz, 64 kbps AAC, 15 fps, BPP 0.63) and govern only the **phone-side recording**; the camera device streams no audio and has no on-wire audio-parameter configuration.

---

## 10b. Empirically validated protocol of the delivered BL384/BoliU unit

Full evidence chain in `04-live-device-validation.md` + `artifacts/` (pcapng captures, extracted frames,
decoded sample images, disassembly). Here: the complete, implementation-usage protocol description.

**Device under test:** SL+ ear-otoscope, IP `192.168.169.1` (WiFi AP, DHCP), MAC `f4:42:50:af:d0:30`
(OUI = **Bouffalo Lab, Nanjing** — matches the APK's "BoliU"/`Bl384SDK`/`libbl_vii_jni.so` driver family).
Phone always at DHCP address `192.168.169.2`.

### 10b.1 Port map and connection model

| Port/role | Direction | Finding |
|---|---|---|
| UDP **8800** | client → device | The only reactive port. Control/"ping gate". Port is hardcoded in `create_instance` (`.rodata` `"8800"`), `phones binds an ephemeral port`. `TCP: none` (nmap full scan: all 65535 closed). |
| UDP **1234** | device → client | Source port of video fragments and heartbeats. Accepts nothing (no reaction to any probe). |
| UDP **67** | device → client | DHCP server on the AP. |
| UDP **63736** | device | Accepts nothing, sends nothing (maybe firmware blob/log port). Unresolved, non-blocking. |

**Connection model:** pure UDP, connectionless. The device learns the client's `ip:port` from whatever
datagram arrives at 8800 (payload **not** validated — arbitrary bytes also (re)arm/redirect the stream),
and thereafter targets video + heartbeats to that socket ("sticky port"). The client must keep sending
datagrams to 8800 to sustain delivery — **ping-serve model** (§10b.3).

### 10b.2 Packet framing (both directions)

Device→phone: `[0x93][msg_type][len LE16][payload…]`; `len` == whole datagram length; max 1091 B
(read cap 0x443 in `thread_recv`). Phone→device: `[0xEF][msg_type][len LE16][payload…]`.

| msg side | type | meaning |
|---|---|---|
| dev→phone | **1** | video fragment (payload = 56-byte fragment header, frag0 = 67-byte header incl. 15-byte extension, §10b.4) |
| dev→phone | **4** | 16-byte heartbeat, every 1.60 s (§10b.5) |
| dev→phone | 2/3/5..8 | static handlers exist (`handle_mcu_msg_ack/ctlmsg/queryinfo_resp`); exact TBB mapping unresolved |
| phone→dev | **0** | `EF 00 04 00` — "start"/serve-ping, 4 bytes, no payload (`thread_timer` log `----------- Sending start`) |
| phone→dev | 2 | `EF 02 …` ack/status, body starts `02 02 00 01` (`build_send_ack`) — not needed for streaming |
| phone→dev | 4 | `EF 04 …` command enqueue (`mjpeg_ndk_command_send`) — not needed for streaming |
| phone→dev | 0x10 | `EF 10 08 00 <u32>` queryinfo (`mjpeg_ndk_queryinfo_cmd_send`) |

### 10b.3 Session / ping-serve model (empirical)

1. Client binds an ephemeral UDP socket.
2. Client sends `EF 00 04 00` to `192.168.169.1:8800`. Device immediately starts streaming video from
   `:1234` to the client socket and sends heartbeats there every 1.6 s.
3. **Maintenance:** after a *single* ping only ~1 frame arrives, then delivery stops. Sustained streaming
   requires the client to keep pinging — the shipped app wakes `thread_timer` to resend `EF 00 04 00`
   whenever no frame arrived for **≥101 ms**. Effective rule for a FOSS client: **ping every ~90 ms**;
   any datagram to 8800 re-arms the stream.
4. A second client on a different socket simply steals the stream target. There is no session handshake,
   no auth, no join/leave protocol apart from datagrams arriving at 8800.

### 10b.4 Video fragment format (`msg_type=1`, verified on 29/29 frames)

Datagram budget: frag0 = 67 + 1024 = **1091 B**, middle = 56 + 1024 = **1080 B**, last = 56 + remainder.

Fragment header fields (offsets within the UDP payload; u32 LE unless noted):

| off | type | meaning | observed |
|---|---|---|---|
| 0..3 | — | transport hdr `93 01 <len LE16>` | len == datagram length |
| 4..7 | — | signature `02 02 00 01` | const |
| 8..11 | u32 | frame id (alternates 1/2) | flips per frame |
| 12..15 | u32 | 0 | const |
| 16..19 | u32 | frame id duplicate | = field above |
| 20..31 | — | 0 | const |
| 32..35 | u32 | **fragment index**, 0-based | 0..cnt−1; out-of-order arrival possible → reorder by index |
| 36..39 | u32 | **fragment count** = `ceil(size/1024)` | 22 for 21 962 B ✓ |
| 40..43 | u32 | **frame size in bytes** | e.g. 14059, 20932, 33518, 33634, 21962… |
| 44..45 | u16 | width = 640 (`0x0280`) | const |
| 46..47 | u16 | height field = 480 (`0x01E0`) — **bogus/unused**; real JPEG is 640×360 | const |
| 48..49 | u16 | quality/status word: low byte = quality (`0x19`=25, `0x4b`=75 …), high byte = frame id−1 | don't trust for decode |
| 50..51 | u16 | 2 | const |
| 52..55 | u32 | frag0 only: `0x0438000b` — low u16 = **11** = extra-byte count; high u16 = 1080 | 0 elsewhere |
| 56..66 | — | frag0 only: **11 varying bytes** (unknown, non-critical, skipped by the decode recipe) | varies |
| 67../56.. | — | page data: frag0 from byte 67 (1024 B); others from byte 56 (1024 B; last = `size` remainder) | |

Frame integrity: Σ(fragment data) == field @40 exactly; Σ(header overhead) = 1243 B for cnt=22
(67 + 20·56 + 56) — verified on all captured frames.

### 10b.5 Heartbeat (`msg_type=4`, 16 bytes, every 1.60 s)

```
93 04 10 00 | seq u32 LE | 04 00 00 00 | drift u32 LE
```
- `[4..7]`: sequence/session field. Day 1: +1 per beat; after a mid-test device reboot (day 2): constant
  `0x00000001` for the whole window — semantics changed after power cycle, needs one more observation lap.
- `[12..15]`: slow drift word (`0x4a5e`→`0x485e`, one LSB per ~10–20 s; not accelerometer — unchanged
  during vigorous waving except a single LSB). Meaning unresolved (counter/temperature/battery?).
- The heartbeat **follows the active streaming socket** (sticky target confirmed). Not required for streaming.

### 10b.6 JPEG reconstruction (decode recipe, validated 29/29 + 4/4 legacy frames)

```
jpeg  = jpeg_header_640x360_Q100 (607 B, ends after SOS — from libbl_vii_jni.so)
      + fragment page data in index order (1024 B each, last short)
      + FF D9 (EOI)
```
- Decodes as stock JPEG (PIL / libjpeg-turbo) to **640×360 RGB**.
- ⚠ The announced quality byte (0x4b=75) does **not** identify the correct header — **Q100 is the one
  that decodes** (its finer DQT tolerates the actual coefficient magnitudes; Q5..Q75 fail "broken data
  stream"). FOSS clients should use the Q100 head fixed, or fall back trying heads best-match first.
- The device **never transmits** a JPEG header (no SOI/DQT/DHT/SOF/SOS on the wire); the phone-side
  table is mandatory.
- Frame sizes are motion-dependent (≈12–30 kB at 640×360 → 0.77–1.1 bpp).
- Negative results (decoded-nothing): XOR-constant sweep, bit-reverse, nibble-swap, 16-bit byte-swap —
  no transform exists.

### 10b.7 Throughput profile (empirical)

- Fragment transmission itself is fast (21 fragments in ~22 ms).
- Delivery is **bursty**: clusters of 1–4 frames at 30–45 ms spacing (~25 fps intra-burst) separated by
  ~0.45–0.52 s idles, *independent of motion*. Effective ≈ 3–4 fps (static scene) — the 0.5 s stalls are
  device-side chunky delivery, so a client must buffer/jitter-normalize for a smooth preview.
- Motion increases frame size, not cadence.

### 10b.8 What this unit does **not** implement (corrections to earlier assumptions)

1. **No TCP anywhere** — the `CmdDataServer`/TCP 2271 G-sensor channel is Beken-family Java code, unused
   for the delivered device (`sendSexCmd`/`sendHBCmd` have no live counterpart).
2. **No Beken UDP 7080 protocol** — `{0x20,0x36}` etc. sent live to 7080/1234/8800/63736 produced zero
   reactions on this unit.
3. **No sensor channel** — no orientation data is streamed by this device in any form (heartbeat drift
   word is not an accelerometer).
4. **No device configuration** — live corroboration of §10a: no AP/STA switch, no quality change occurs
   at runtime despite `setQPara`/the Q5..Q100 header table being present (the firmware streams at a
   fixed effective quality regardless of the announced byte).
5. Device reboot mid-session: full state reset (heartbeat seq reset to 1, stream target cleared) —
   clients must re-arm by pinging again.

### 10b.9 Extension point for other controller families (FOSS requirement)

The vendor already navigates this exact zoo via `ISocSdk` strategies (`SOC_BEKEN`, `SOC_BOLIU`, `SOC_USB`) —
and the empirical lesson is that **wire protocols are per-controller-firmware, not per product line**: the
shipped app's "Beken" knowledge does not transfer to the BoliU unit at all. A FOSS replacement must model
this as a **pluggable `DeviceTransport`** with at least these capabilities per implementation:

| Capability | Why it varies | BL384/BoliU example |
|---|---|---|
| frame transport (sockets vs UVC endpoint) | SoC family | UDP 8800 ping / 1234 data |
| fragment / framing format | firmware | 56-byte header (§10b.4), 1024-B pages |
| JPEG header strategy | per-device | phone-side Q100 head prepend + EOI |
| resolution / quality preset | device/firmware | 640×360; quality not adjustable |
| keep-alive / session semantics | firmware | ping-serve ≤101 ms, sticky port |
| attitude/sensor channel | optional, per family | **absent** |
| command set (still capture, voice, OTA) | optional, per family | none exercised |
| device address / discovery | subnet scheme | `192.168.169.1` AP gateway |

Everything downstream (decode → rotate/filter → render → record → capture) is transport-agnostic and
shared; only these rows get new implementations per controller family (Beken `SOC_BEKEN` = the
bytecode-derived UDP 7080/TCP 2271 pair; UVC = traditional USB video; unknown future families = new
plug-in + packet-debug screen, cf. `03-reimplementation-proposal.md` §2.2).

---

## 12. Quality Assessment (architecture opinion)

- **Positives**: clean separation into `ISocSdk` strategies, proper reuse of proven UVC stack, app-side-only rotation keeps hardware cheap, working 1-minute-to-first-frame UX.
- **Negatives**: duplicated 3rd-party code classes ×3 (bundle bloat `androidsupportmultidexversion.txt` + `DebugProbesKt.bin` leftover), 32-bit only, cleared TLS everywhere (security bug), "SEX"/"TEETH" product families unify a data model that has no bearing in the ear-mirror, dead vendor code (vidure transport for 7 SoC dialects) shipped, and no 64-bit compliance. |
- **Requirement reconstruction**: the developers were constrained by (1) exotic WiFi SoC firmware without a UVC endpoint, (2) 32-bit only vendor NDK SDK for the Chinese market, (3) needing to show a stable preview while the patient-facing end rotates freely (hence G-sensor streaming + software rotation with a sample-and-hold pairing of angle↔image to make the ear canal image "stand still" while moving), (4) no backend dependence (works offline) with a soft telemetry/OTA layer on top.
