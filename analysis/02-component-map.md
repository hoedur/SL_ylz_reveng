# Component & Building-Block Map — `SL+ylz` v1.0.23

All nodes are verified against DEX classes / native symbols / manifest entries of the analyzed APK. Legend: 🟥 vendor binary blob · 🟧 OSS library (bundled copy) · 🟩 in-house analysis base code

---

## 1. Overall architecture map

```mermaid
flowchart LR
    subgraph HW["Probe hardware"]
        direction TB
        MCU["MCU / camera SoC 🟥\n(Beken or BoliU variant)\nor UVC camera chip"]
        GS["2-axis G-sensor (accelerometer)"]
        AP["WiFi AP in device\n(default 192.168.0.1)"]
        MCU --- GS
    end

    subgraph APP["com.xiaozhen.beauty.shenglong — Android app"]
        direction TB
        UI["UI layer 🟩\nSplash / Home / Connect / Help /\nLicenseAgreement / Preview / PreviewFull / PreviewUsb\nwidgets: MySurfaceView, PlayerControllerGestureLayout"]
        SOCFAC["ISocSdk 🟩\nstrategies: SOC_BEKEN | SOC_BOLIU | SOC_USB\n+ DevType (85 ear, 86 sex-360, 87 teeth, 16 no-G-sensor)"]
        BEKEN["BekenSdk 🟩\nUDP 7080 client, fragment reassembly\n(1472-B datagrams, 102400-B buffer)\n— no live unit matched (§10b)"]
        BLS["BlSdk (Bl384SDK) 🟩 facade\n+ libbl_vii_jni.so 🟥\nmjpeg_ndk_* C API, JPEG-hdr Q5..Q100,\nJNI: onStart/setQPara/setActiveCameraIndex/onDestroy\n— protocol LIVE-VALIDATED §10b\n(UDP 8800 ping / 1234 data)"]
        CMD["CmdDataServer 🟩\nTCP 2271 control/gyro channel\n— Beken family only,\nno live counterpart"]
        GYRO["G-sensor parsers 🟩\nGsensorParser2D / GsensorParserSimple2D /\nGyroParser2DOld / FpsStatis\natan2 × 100/π"]
        PREV["Preview engine 🟩\nBitmapFactory/jpeg-turbo → Matrix(postTranslate+postScale+postRotate)\n→ SurfaceView (RefreshFrameThread, 2-frame angle/img pairing)"]
        ENCLIB["lib.encoder 🟩 (copy of serenegiant)\nMediaVideoBufferEncoder / MediaSurfaceEncoder (H.264, 15 fps, BPP 0.63)\nMediaAudioEncoder (AAC 44.1k/64k mic) / MediaMuxerWrapper"]
        REC["RecordHandler 🟩\nEGL FBO + Bitmap path, H.264/AAC → MP4 via MediaMuxer"]
        UVC["com.serenegiant.* 🟧 (saki4510150 UVCCamera)\nUSBMonitor / UVCCamera / UVCControl\nEGLBase10/14, GLDrawer2D, RendererHolder,\nAspectRatioTextureView"]
        UVCAPP["com.herohan.uvcapp 🟧 (herohan fork)\nCameraHelper / ImageCapture / VideoCapture\nCameraPreviewConfig / ImageSaver"]
        USBNATIVE["libUVCCamera.so 🟥 + libuvc.so 🟥 + libusb1.0.so 🟥\n+ libjpeg-turbo212.so 🟥"]
        CLOUD["handler.cloud 🟩\nSvrApi (api.6zhentan.com:8443) / PhoneNao+PhoneService (IMEI, CPU, model telemetry)"]
        OBS["Huawei OBS/OEF SDK 🟥\nObsClient, HttpProxyConfiguration"]
        VIDURE["vidure lib 🟥\nTCP/UDP/HTTP transport, SoC phrasers\n(AllWin/Hisilicon/MStar/NVT/Nello/Goplus/Jieli),\nparallel downloader, OTA"]
        MISC["Utility libs 🟧\nokhttp3/okio, jackson, hutool,commons-compress,\nXXPermissions, AndroidX, Material, coroutines,\nprofileinstaller, multidex"]
    end

    BACKEND["Vendor backend\napi.6zhentan.com:8443 (HTTPS)\n+ Huawei OBS buckets 🟥"]

    MCU -- "UDP 7080: JPEG ≤1472-B fragments\n(bytecode-derived; Beken units)" --> BEKEN
    MCU -- "TCP 2271: angle +\ndev-type + cmd ACK (Beken units)" --> CMD
    MCU -- "UDP 8800 ping / 1234 data:\nJPEG 640×360, ≤1091-B fragments\n(LIVE-VALIDATED §10b)" --> BLS
    MCU -- "USB: UVC MJPEG\n(class 239/sub 2)" --> USBNATIVE
    GS --> MCU

    SOCFAC --> BEKEN & BLS & UVCAPP
    BEKEN --> GYRO
    BLS --> GYRO
    CMD --> GYRO
    BEKEN & BLS --> PREV
    GYRO --> PREV
    UVCAPP --> UVC --> USBNATIVE
    UVCAPP --> PREV
    PREV --> REC
    ENCLIB --> REC
    REC --> PH_STOR["MediaStore / File+\nFileProvider shares/"]
    CLOUD --> BACKEND
    OBS <--> BACKEND
    VIDURE --> BACKEND
    VIDURE -.-> ENCLIB
    UVCAPP --> PH_STOR
    UI --> SOCFAC & REC & CLOUD
    MISC -.-> APP
```

## 2. Information flow: video + orientation (WiFi probe)

```mermaid
sequenceDiagram
    participant D as Probe (camera MCU)
    participant A as App (BekenSdk or BlSdk)
    participant G as GsensorParser (ring buffer)
    participant R as RefreshFrameThread 1 Outputs (SurfaceView)
    A->>D: UDP 0x20 0x36 "start imaging" (port 7080)
    loop every fragment (≤1472 B)
        D-->>A: UDP: [picId][pkType][len-4][JPEG payload]
        A->>G: pair latest frame with latest angle
    end
    D-->>A: TCP 2271 angle packet (0xFF header, 16-bit x/y, atan2×100/π)
    G->>R: showImgData() JPEG + angle
    R->>R: Matrix reset → postTranslate → postScale → postRotate
    R->>R: bitmap → Canvas → SurfaceView
    A->>D: TCP heartbeat / "sex" cmd
    A->>D: UDP 0x20 0x37 "stop imaging"
```

*Key point:* angle packets are plainly asynchronous from the frames — the app does **nearest-lag pairing** because the G-sensor on device has no concept of frames. The result is a 2-buffer deep "sample & hold" that lets the visible frame *stand still* while the probe body rolls (intention: examine the ear canal as if fixed).

> **Live-unit caveat:** the sequence above is the *Beken-family/bytecode-derived* path. The delivered
> BoliU unit (§10b of the arc42 doc) runs a different exchange — see section 2a below — and streams **no
> orientation data at all**.

## 2a. Physical device trace (empirically validated, `04-live-device-validation.md` §3–§5b)

What actually happens on the wire with the delivered BL384/BoliU unit at `192.168.169.x`:

```mermaid
sequenceDiagram
    participant P as Phone/client (ephemeral UDP port)
    participant D as Probe BL384 (192.168.169.1)

    P->>D: EF 00 04 00 → UDP 8800 (device learns ip:port, payload unvalidated)
    loop every 1.60 s
        D-->>P: 16-B heartbeat [93][04][10 00][seq][04 00 00 00][drift u32] (port 1234 →)
    end
    loop sustained delivery: needs a datagram to 8800 at least every ~101 ms
        loop per frame: cnt fragments (cnt = ceil(size/1024))
            D-->>P: [93][01][len LE16][56-B frag header][1024 B page]
            Note over P: reorder by fragment index (out-of-order ok)
        end
        Note over P: jpeg = jhdr_Q100 (607 B) + Σ pages + FF D9 → decode 640×360 RGB
    end
```

- Charakteristik: ping-serve (one ping ≈ one/frame-batch served), sticky stream target, bursty delivery
  (~25 fps intra-burst, ~0.5 s stalls), no TCP, no sensor channel, no configuration protocol.

## 3. USB/UVC path

```mermaid
flowchart LR
    USBD["UVC USB probe\n(class 0xEF/0x02 device filter)"] -- iso/bulk MJPEG --> LIBU["libuvc.so + libusb1.0.so"]
    LIBU -- "uvc frames (UVC_FRAME_FORMAT_MJPEG\nH264/YUYV/NV21 also in code)" --> LIBUV["libUVCCamera.so\n(UVCPreview NV21/GL)"]
    LIBUV →|JNI com.serenegiant.usb.UVCCamera| UVCAPP["herohan CameraHelper"]
    UVCAPP -- surface --> GL["EGLBase14 + RendererHolder + GLDrawer2D"]
    GL -- rotate btn (manual) --> VIEW["AspectRatioSurfaceView"]
    GL -- frames --> MEDIA["MediaCodec H.264 → MediaMuxer → MP4\n(+ AudioRecord → AAC)"]
    UVCAPP -- frame capture --> IMG["ImageCapture → JPEG still → FileProvider"]
```

## 4. Deployed packaging

```mermaid
flowchart TD
    X["SL+ylz .xapk (XAPK v2)"] --> B["base apk\n(3 dex, manifest, Java code)"]
    X --> C1["config.armeabi_v7a\nlibUVCCamera.so / libuvc.so /\nlibusb1.0.so / libjpeg-turbo212.so /\nlibbl_vii_jni.so"]
    X --> C2["config.mdpi (res)"]
    X --> C3["config.en / .fr / … (strings)"]
```

## 5. Logical boundaries assessment

| Boundary | Where | Clean? | Notes |
|---|---|---|---|
| **App ↔ probe transport** | `ISocSdk` strategy (`SOC_BEKEN`/`SOC_BOLIU`/`SOC_USB`) | 🟢 good shape, hidden detail | Strategy factory is the right seam — and empirically **essential**: controller families carry their own wire protocols (Beken ≠ BoliU ≠ UVC, see §10b.9 of the arc42 doc); the FOSS design duplicates it as a pluggable `DeviceTransport`. Implementations leak device-type specifics into the UI. |
| **App ↔ orientation** | `lib.gyro.*` | 🟡 | Parser algorithm per device type is embedded; an interface (e.g. `IAttitudeSource`) is a better boundary. **The BoliU unit supplies no attitude data** — for such devices the source is phone-sensor or manual. |
| **App ↔ render pipeline** | `lib.opengl`, `PreserveActivity.RefreshFrameThread` | 🔴 | Rotation+scale+draw is duplicated in 2 activities against 2 different render paths (Bitmap Canvas vs GL). Not factored out. |
| **App ↔ capture/codec** | `lib.encoder` + `handler.RecordHandler` | 🔴 | This is a verbatim copy of the serenegiant sample code path AND another path in `com.herohan.uvcapp.VideoCapture` — two parallel implementations coexist. |
| **App ↔ OS** | `UsbManager`, `SensorManager`, `ConnectivityManager`, `MediaCodec`, `MediaMuxer`, `EGL`, `FileProvider`, `Storage Access` | 🟡 | No service abstraction: state lives in Activities; orientation/config changes handled by `configChanges`-freeze instead of lifecycle-aware design. |
| **App ↔ backend** | `handler.cloud.*` + OBS + vidure | 🟡 | Brand telemetry/push bundled directly into app classpath; no local persistence boundary; metadata pushed without lifecycle gate. |
| **Vendor blobs** | `libbl_vii_jni.so`, `libUVCCamera.so`+children | 🟢 resolved | ⚫ The BoliU UDP protocol was the mystery — **now fully reverse-engineered via black-box capture + native disassembly** (§10b, `04-live-device-validation.md`). `libUVCCamera.so` stays behind the OSS wrapper's documented JNI API, no need to reimplement. |
| **Dead/living code** | `vidure` transport (7 SoC families), OBS SDK, `jackson`+`hutool` (duplicated) | 🔴 | Huge unused/low-use code mass inflates APK & attack surface. |

## 6. Permission / manifest feature map

| Manifest element | Meaning |
|---|---|
| `<uses-feature android:hardware.usb.host>` + class-239 filter | Device is a plug-and-play UVC camera |
| `USB_DEVICE_ATTACHED/DETACHED` launcher filter | App is a USB attach home |
| `CHANGE_WIFI_STATE`, `ACCESS_WIFI_STATE`, `ACCESS_NETWORK_STATE` | WiFi AP switching/detection |
| `CAMERA` | Declared, but probe is not accessed through the camera HAL (legacy or WiFi-preview fallback only) |
| `READ/WRITE_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES/VIDEO` | Still/video storage on legacy path |
| `FOREGROUND_SERVICE` | Declared but no service found → likely dead |
| `android:usesCleartextTraffic=true` + empty TLS bypass | All HTTP is unverified |
