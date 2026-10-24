# Prototype Architecture & Requirements — otoscope validation client

Status: **working spec, v1.0 (2026-10-24)** — the single source of truth for implementation *and*
testing of this prototype. Identity of the document: `prototype/docs/ARCHITECTURE.md`.

This prototype is a **validation lab for the reverse-engineering analysis**, not a product.
It runs a PyQt6 window that (a) displays the live video stream of the currently supported device
(Bouffalo-Lab "BL384"/BoliU unit at `192.168.169.1`) and (b) displays **all metadata transported in
the UDP packets** in a separate panel to the right of the video, in a *device-generic* schema so that
future device families connect without UI changes.

---

## 1. Non-goals

- Production hardening, packaging/installers, auto-start.
- Recording (H.264/AAC/MP4), still-image capture UI, cloud, preferences storage.
- Beken-7080 / UVC / other transports beyond the registry seam (they are the *extension point*, not scope).
- No new protocol knowledge assumed beyond `analysis/04-live-device-validation.md` (§10b of the arc42 doc).

## 2. Design principles

1. **Spec-first, test-first**: every functional increment must have a REQ id here before code exists.
2. **Extension point**: exactly one abstract seam (`DeviceTransport`); *no device-specific code leaves
   its own module*. Telemetry/UI code must not import specific transports.
3. **Telemetry-first**: every parsed or rejected datagram, every frame, every ping becomes a
   normalized, device-generic `TelemetryEvent` — the UI is a generic viewer of that stream.
4. **Thin threading**: network in a worker thread; UI polls a thread-safe store every 100 ms — no
   GUI code in the network path, no per-datagram GUI wakeups.

## 3. Module layout (contract — tests import these exact paths)

```
prototype/
├─ pytest.ini                     (pythonpath=src, QT_QPA_PLATFORM=offscreen via conftest)
├─ README.md                      (how to run)
├─ docs/ARCHITECTURE.md           (this file)
├─ src/otoscope_proto/
│  ├─ telemetry.py                (REQ-TEL-*: event schema, thread-safe store)
│  ├─ jpeg_frames.py              (REQ-BOL-pure-logic: JPEG header table, frame assembler)
│  ├─ device/
│  │  ├─ __init__.py              (REQ-ARCH-*: DeviceTransport ABC + registry)
│  │  └─ boliu.py                 (REQ-BOL-*: the live-validated BL384 UDP protocol)
│  ├─ ui/
│  │  ├─ main.py                  (REQ-OPS-*: QApplication bootstrap, CLI)
│  │  ├─ main_window.py           (REQ-UI-*: window, layout, wiring, polling)
│  │  └─ metadata_panel.py        (REQ-UI-META-*: generic metadata widgets)
│  └─ data/jhdr_Q100.bin          (607 B — byte-identical copy of analysis/artifacts/jhdr_Q100.bin)
└─ tests/                          (written by spec-only testing agents; see REQ-TEST-*)
```

Entry point: `python -m otoscope_proto` (package must define `otoscope_proto.main_mod`-equivalent
`if __name__ == "__main__"` via `src/otoscope_proto/__main__.py`).

## 4. Requirements

Requirement ids are stable; tests must cite them in their docstrings (`REQ-BOL-003` etc.).
**No code implements behavior that is not written here.** New needs => new REQ ids added by the
implementer *to this file first*.

### 4a. REQ-ARCH — device abstraction & extension point

| id | requirement |
|---|---|
| REQ-ARCH-001 | `DeviceTransport` is an ABC with at least: `name: str` (unique registry key), `start()`, `stop()`, `events() -> dict` (statistics snapshot; see REQ-TEL-004), `frames() -> Frame objects` — where a frame carries `jpeg_bytes: bytes` and monotonic `recv_ts`. **It is valid to implement frames/events as consumed via a shared `TelemetryStore`/frame queue (see REQ-ARCH-005).** |
| REQ-ARCH-002 | A module-level registry `TRANSPORTS: dict[str, type[DeviceTransport]]` maps `name → class` and `create_transport(name, host, port, store) -> DeviceTransport`; unknown name raises `KeyError` containing the name. |
| REQ-ARCH-003 | Isolation: `telemetry.py` and `ui/*` must NOT import `device.boliu` (nor any concrete transport). The registry is the only coupling. |
| REQ-ARCH-004 | Transport constructors accept `(host: str, port: int, store: TelemetryStore)` and must not touch the network or spawn threads before `start()`; `stop()` must be idempotent. |
| REQ-ARCH-005 | Frames are distributed through a bounded queue owned by the store/transport layer (`maxsize=64`); when full, the OLDEST frame is dropped and a `frame_dropped` telemetry event (kind `frame_dropped`) is emitted — video display must never block the network thread. |

### 4b. REQ-TEL — telemetry: the generic metadata representation

| id | requirement |
|---|---|
| REQ-TEL-001 | Every wire-level observation is normalized into a `TelemetryEvent` dataclass (frozen): fields `ts: float` (monotonic), `transport: str`, `kind: str`, `addr: str` ("ip:port" of the peer as seen), `datagram_len: int` (bytes on wire; 0 for synthesized logic events like `frame_complete`), `fields: dict[str, int | str | float]`. Enumerated `kind`s: `video_fragment`, `frame_complete`, `heartbeat`, `ping`, `malformed`, `unknown_type`, `decode_error`, `stats_sample`, `frame_dropped`. Transports may add kinds but must not change the field set. |
| REQ-TEL-002 | `TelemetryStore` is thread-safe (internal lock or queue): `add_event(ev)`, `get_since(idx) -> (list[TelemetryEvent], next_idx)`, `snapshot() -> dict` (counters). Ring capacity 5000 events, oldest evicted. Entry point also exposes `push_frame(jpeg_bytes, ts)` with the REQ-ARCH-005 drop policy. |
| REQ-TEL-003 | `snapshot()` returns plain dicts/lists (JSON-serializable) — used by `--out` and by the Stats panel. |
| REQ-TEL-004 | Store maintains cumulative counters at least: `datagrams_rx`, `by_kind: dict[str,int]`, `bytes_rx`, `frames_complete`, `decode_ok`, `decode_failed`, `pings_tx`. **Counter increments happen on `add_event`:** kind `frame_complete` → `frames_complete`; kind `ping` → `pings_tx`; kind `decode_error` → `decode_failed`; any event with `datagram_len > 0` → `datagrams_rx` and `bytes_rx += datagram_len` (so a transport observes its own sent bytes with `ping` events too). `decode_ok` is incremented only via an explicit store method `TelemetryStore.mark_decode(ok: bool)` (called by the UI decoder). `stats_sample` events (rate ≈ 1/s) carry `fps_5s` (completed frames per second over trailing 5 s window), `kbps_rx` (kilobytes/s of wire datagrams) and are *derived*, not wire observations. |
| REQ-TEL-005 | Video frames and all fragment metadata are stored as events; the UI renders metadata exclusively from telemetry snapshots — there is no metadata side-channel into the video widget. |

### 4c. REQ-BOL — BoliU/BL384 transport (the live-validated device)

All facts below are from the validated analysis (bold = hard constants tested):

| id | requirement |
|---|---|
| REQ-BOL-001 | UDP socket: client binds `0.0.0.0:<local_port>` with `local_port: int = 0` constructor parameter (ephemeral by default; localhost tests inject a fixed port). Every datagram received is filtered: `srcaddr.ip == host` else drop silently (counter only). Source port must equal the constructor parameter `stream_port` (**default 1234** — the live-validated device source; loopback tests pass the fake device's port). Datagrams from other peer ports are ignored (counter only). |
| REQ-BOL-002 | Ping loop: every **90 ms** send exactly `bytes.fromhex("EF000400")` to `host:port` (port default **8800**). Sends are counted (`pings_tx` counter and one `ping` event per send, `fields={"bytes": "EF000400"}`). |
| REQ-BOL-003 | Frame datagram head: `d[0] == 0x93`, `d[1] == 1`, `len16 = LE16(d[2:4])`. If `len16 != len(d)` → drop + `malformed` event (`fields={"want_len": int, ...}`). Unknown `d[1]` (`!= 1 and != 4`) → drop + `unknown_type` event (`fields={"type": int}`). Heartbeat: `d[1] == 4` and `len == 16` → `heartbeat` event with `seq = LE32(d[4:8])`, `pad = LE32(d[8:12])`, `drift = LE32(d[12:16])`. Heartboard with wrong length → `malformed`. |
| REQ-BOL-004 | Fragment parsing (type-1 datagrams; field access needs ≥ 50 B): `frame_id = LE32(d[8:12])`, `idx = LE32(d[32:36])`, `cnt = LE32(d[36:40])`, `size = LE32(d[40:44])`, `wfld = LE16(d[44:46])`, `hfld = LE16(d[46:48])`, `qfld = LE16(d[48:50])`; **page data = `d[67:]` when `idx == 0` (expects 1024 B), else `d[56:]` (mid: 1024 B, last: `size - (cnt-1)*1024` B)**. Sanity rules (each violator → drop + `malformed`, keep processing others): `0 < cnt <= 3408`, `idx < cnt`, `size > 0`, page length ≤ 1024 and > 0 — **a type-1 datagram that parses as a fragment but yields a zero-length page (i.e. shorter than its head length) is also `malformed`** — and page length matches expectation (mid/last arithmetic above). `video_fragment` event carries all seven fields. |
| REQ-BOL-005 | Reassembly: keyed by `(frame_id, size)` — frame ids alternate 1/2 between successive frames and both partials may exist simultaneously. A key is complete when the first `cnt` fragment indices are all collected. Keys exceeding 16 pending entries are pruned oldest-first (`frame_dropped` event with `fields={"pruned": True}`). Completing a key: emit `frame_complete` event (`fields={"frame_id","size","cnt","w","h","q"}`) and push to the frame queue the **reconstructed JPEG bytes** = `jhdr_Q100 (607 B) + Σ pages in index order + FF D9` — this reconstructed stream (length `607 + size + 2`) is what `frames()` delivers; `push_frame` happens on the network thread. |
| REQ-BOL-006 | The data file `src/otoscope_proto/data/jhdr_Q100.bin` is byte-identical to `analysis/artifacts/jhdr_Q100.bin` (607 B; SHA-256 recorded in README). Reconstruction uses exactly that file + `b"\xff\xd9"` suffix; it must be performed by pure helpers in `jpeg_frames.py` (`assemble_jpeg(header: bytes, payload: bytes) -> bytes` and `jpeg_size(payload_len) -> int` = `607 + payload + 2`) so unit tests can verify the artifact case (`frame0.bin`, 14 059 B) decodes with PIL to 640×360. |
| REQ-BOL-007 | `stop()` closes the socket and terminates all worker threads within 2 s; no further events after stop. |

### 4d. REQ-UI — window & layout (metadata lives OUTSIDE the video widget)

| id | requirement |
|---|---|
| REQ-UI-001 | Main window title `"Otoscope Prototype — <transport.name>"`, default size 1280×720, minimum 1024×576. Central widget is a horizontal QSplitter: `VideoPanel` (left) and `metadata_panel` (right). |
| REQ-UI-002 | **VideoPanel** occupies the left, shows the newest frame (QPixmap from decoded image), preserving 640×360 aspect with letterbox on black. Before the first frame: placeholder text "No signal — pinging <host>:<port>" centered on black. **No telemetry text may be drawn inside the video widget** (metadata must be visible only outside the video frame area). |
| REQ-UI-003 | **Metadata panel** (right side) is a QTabWidget with ≥ 4 tabs of generic content — tabs: `Events`, `Frame`, `Stats`, `Raw event`. Requirements: (a) it is never smaller than 360 px wide at default size; (b) splitter allows resizing but maintains ≥ 480 px for video at default size. |
| REQ-UI-004 | `Events` tab: table of TelemetryEvents (newest first), built **generically from `fields`**: columns `ts (s)`, `kind`, `datagram_len`, `summary` (joined `k=v` of `fields`; long values truncated); ≥ 500 visible rows kept. |
| REQ-UI-005 | `Frame` tab shows the LAST completed frame's metadata: kind/frame fields (`frame_id`, `size`, `cnt`, `w`, `h`, `q` = the transport's announced video profile) + `decode_ts`, `jpeg_len`; each as label/value rows — NOT inside the video. |
| REQ-UI-006 | `Stats` tab: counters from `snapshot()` (datagrams_rx, pings_tx, frames_complete, decode_ok/failed, bytes_rx) + `fps_5s`, `kbps_rx` numeric labels, refreshed each UI poll (100 ms). |
| REQ-UI-007 | `Raw event` tab: for the currently selected row in `Events`: pretty-printed field list + hexdump of the event's `raw_hex` (first ≤ 128 bytes, from `datagram`). When selected event has no raw bytes: message "no wire payload". |
| REQ-UI-008 | UI polls the store every **100 ms** via QTimer; a full window works headlessly with `QT_QPA_PLATFORM=offscreen` (no visible window required). |
| REQ-UI-009 | GUI never blocks the network thread: decode/emit of display images lives in the UI thread from the (bounded) frame queue only. |

### 4e. REQ-OPS — CLI, exit, dumps, live checks

| id | requirement |
|---|---|
| REQ-OPS-001 | CLI: `python -m otoscope_proto [--host H] [--port P] [--transport NAME] [--duration S] [--out FILE]`. Defaults: host `192.168.169.1`, port `8800`, transport `boliu`, duration infinite, out unset. |
| REQ-OPS-002 | `--duration S`: after `S` seconds the window closes (graceful `stop()`), process exit code 0, no threads hang (join ≤ 2 s). `--out FILE`: write JSON with `{"transport", "host", "port", "duration_s", "snapshot"}` at that moment. |
| REQ-OPS-003 | Any `decode_error` event increments `decode_failed` with `fields={"reason": str, "jpeg_len": int}`; display of the placeholder "No signal" resumes on the next empty-poll turn (never crashes the app). |
| REQ-OPS-004 | README documents the run commands (incl. `QT_QPA_PLATFORM=offscreen` for headless validation) and the SHA-256 of `data/jhdr_Q100.bin`. |

**Live validation expectations** (used by integration tests; tolerate ±50 %):

| observable | expected (from analysis §10b) |
|---|---|
| `frames_complete` after ~10 s of running | ≥ 20 |
| decoded image size | exactly 640×360 |
| frame payload sizes | 12 000–40 000 B |
| fps_5s within a stall-free 2 s window | ≥ 10; overall window mean 3–4 |
| heartbeat events | cadence 1.60 s ± 0.8 s |
| data source | `192.168.169.1:1234` |

### 4f. REQ-TEST — the testing process (binding for agents)

| id | requirement |
|---|---|
| REQ-TEST-001 | Tests are written **by dedicated tester agents that have read ONLY `docs/ARCHITECTURE.md`** (never `src/`), cite REQ ids in module docstrings, and live under `tests/` as pytest files. |
| REQ-TEST-002 | A test failing due to a *missing/ambiguous spec* is escalated by the tester writing its question into `docs/coordination.md` (open-questions section) and, if unresolvable, reporting back — it must never guess against `src/`. The implementer answers in `coordination.md` and the affected tests are updated with the clarified REQ text. |
| REQ-TEST-003 | Platform: pytest; Qt tests set `QT_QPA_PLATFORM=offscreen` (conftest). No network in unit tests except localhost (fake devices bind 127.0.0.1). Real-device access is reserved for the *live validation run*, never inside committed tests. |
| REQ-TEST-004 | Every requirement marked in §4c/§4d lists its test vectors: datagrams are constructed per the byte layout in REQ-BOL-003/004 (exact offsets), NOT from recorded pcaps; the only reused binary inputs are `analysis/artifacts/frame0.bin` (14 059 B page-payload of one complete frame) and `analysis/artifacts/jhdr_Q100.bin` (607 B) for REQ-BOL-006. **Data files under `src/otoscope_proto/data/` are test vectors, not code — reading them for byte-identity checks is permitted** (source-code files under `src/` remain off-limits). |

---

## 5. Reference fake device (test-only; deterministic, spec-derived)

Used by integration tests (never talks to a real device; binds 127.0.0.1):

1. `FakeDevice` binds an ephemeral UDP localhost socket. On **every** received datagram it stores
   the sender address (`reply_to`) and immediately transmits **exactly one complete frame** there,
   fragments in index order `0..cnt-1` (δ ≤ 1 ms apart, no pacing required in tests).
2. Frame construction (default): `frame_id` cycles 1, 2, 1, … between frames; `size` (default
   **2100**) is a spec constant; `cnt = ceil(size/1024)` (2100 → 3); payload content is
   deterministic pseudo-random `[i % 251 for …]` (not expected to be JPEG-decodable — decode
   assertions use the real artifacts, see REQ-BOL-006). Fragment bytes: frag0 = header
   (per REQ-BOL-004 layout, 67 B) + first 1024 B; mid = 56-B header + next 1024 B; last = 56-B
   header + remainder; transport framing prefix `[0x93][01][len LE16]`, all from a single UDP
   datagram per fragment.
3. Heartbeats: after the first received datagram, one `93 04 10 00 <seq LE32> 04 00 00 00 <drift LE32>`
   per **1.6 s** while any datagram arrived in the last 5 s (heart rate tolerant ±0.8 s in tests).
4. The fake mirrors the real sticky behavior: it streams to the *most recent* sender address.
5. The fake's announced profile is pinned: `w=640`, `h=360`, `q=0x4B`. Tests bind the transport
   against it via `BoliUTransport(host="127.0.0.1", port=fake.port, store=store, stream_port=fake.port)` —
   the `stream_port` parameter (REQ-BOL-001) replaces the real device's fixed :1234 filter.

---

## 6. Interfaces (signatures fixed by this spec; implementers may add private helpers)

```python
# telemetry.py
@dataclass(frozen=True)
class TelemetryEvent:
    ts: float; transport: str; kind: str; addr: str
    datagram_len: int; fields: dict[str, int | str | float]
    raw_hex: str = ""            # first <=128 bytes of the wire payload (lowercase hex), "" if none

class TelemetryStore:
    def __init__(self, transport_name: str) -> None: ...
    def add_event(self, ev: TelemetryEvent) -> None: ...
    def mark_decode(self, ok: bool) -> None: ...                    # REQ-TEL-004 (decode_ok counter)
    def get_since(self, idx: int) -> tuple[list[TelemetryEvent], int]: ...   # newer than idx
    def snapshot(self) -> dict: ...
    def push_frame(self, jpeg_bytes: bytes, ts: float) -> None: ...
    def pop_frame(self) -> tuple[bytes, float]: ...   # () empty tuple = none

# device/__init__.py
class DeviceTransport(ABC):    # see REQ-ARCH-001
    name: ClassVar[str]
    def __init__(self, host: str, port: int, store: TelemetryStore) -> None: ...
    def start(self) -> None: ...
    def stop(self) -> None: ...
TRANSPORTS: dict[str, type[DeviceTransport]]
def create_transport(name: str, host: str, port: int, store: TelemetryStore) -> DeviceTransport

# device/boliu.py  (class name fixed for the registry)
class BoliUTransport(DeviceTransport):      # name = "boliu"
    # REQ-BOL-001..007; local_port: int = 0 for loopback tests (REQ-BOL-001)
    def __init__(self, host: str, port: int, store: TelemetryStore,
                 local_port: int = 0, stream_port: int = 1234) -> None: ...

# ui/main_window.py
def build_window(store, transport_name: str, host: str, port: int) -> QMainWindow   # REQ-UI-001

# ui/main.py
def run_cli(argv: list[str] | None = None) -> int    # REQ-OPS-001/002; does not parse if argv is None -> sys.argv
```

## 7. Open questions / coordination

See `docs/coordination.md` (created empty; testers append questions, implementers append answers).
