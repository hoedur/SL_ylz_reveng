# otoscope_proto

PyQt6 **validation prototype** for the reverse-engineered ear-otoscope stream —
a spec-first lab, not a product. It validates the live protocol of the BoliU
"BL384" unit (UDP, pings + fragmented JPEG stream) and renders all UDP metadata
in a device-generic telemetry panel. Binding spec:
`docs/ARCHITECTURE.md` (protocol background: `../analysis/01-arc42-architecture.md` §10b).

Scope: single transport (`boliu`, REQ-BOL-\*), the `DeviceTransport` registry as
the only extension point (REQ-ARCH-\*), no recording/cloud/config features.

## Run

The package is not installed in the venv — always prepend `PYTHONPATH=src`
(`pytest.ini` only adds it for pytest, not for application runs):

```bash
# headless validation run (window not required):
cd prototype
PYTHONPATH=src QT_QPA_PLATFORM=offscreen /home/stefan/reveng/SL_ylz/.venv/bin/python -m otoscope_proto

# options (REQ-OPS-001): --host 192.168.169.1 | --port 8800 | --transport boliu
#                        --duration S | --out FILE
```

`QT_QPA_PLATFORM=offscreen` is required for headless CI/validation (no display).

## Tests

```bash
cd /home/stefan/reveng/SL_ylz/prototype
QT_QPA_PLATFORM=offscreen /home/stefan/reveng/SL_ylz/.venv/bin/python -m pytest tests/ -q
```

## Data integrity

`src/otoscope_proto/data/jhdr_Q{5,10,25,50,75,100}.bin` (605 B each) are the
six embedded JPEG heads of `libbl_vii_jni.so`
(`jpeg_header_640x360_Q5@0x4c1a … Q100@0x57eb`, 605-byte stride; they end right
after the SOS segment). Reconstruction picks the head matching the frame's
announced quality byte (low byte of `q`; amended REQ-BOL-005/006):

```
jhdr_Q5.bin   SHA-256: df9ee8fb8538f67d5f1ea85030220e4105e714be2302328435833f2d52a8c1b1
jhdr_Q10.bin  SHA-256: af72e0e8fe55ca5fa455a62c38781fbd16ce73166e3b2d7ffd9f22873148f51f
jhdr_Q25.bin  SHA-256: 0d24f2c66974c35d155d29befcda6791d4c3247ae36888da6f25629d264541cb
jhdr_Q50.bin  SHA-256: ef4c70ec8777ed2036923d0ad059dc9b44bed96ecdba38be62f1243dc7307a17
jhdr_Q75.bin  SHA-256: 4fd75a4cf4141f0a4a9666ce537f38da541744bccb9e7656400156a06b132e63
jhdr_Q100.bin SHA-256: aa02c7b99cf81bb695f325835fca17ab7cbed7d2dd14448d3f52d7016200ee84
```

The old `analysis/artifacts/jhdr_Q*.bin` files are 607 B: their 2-byte tails
are over-extraction artifacts (stray bytes of the adjacent data pool) that must
be stripped before use — see REQ-BOL-006.
