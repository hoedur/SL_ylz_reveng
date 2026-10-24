# otoscope_proto

PyQt6 **validation prototype** for the reverse-engineered ear-otoscope stream —
a spec-first lab, not a product. It validates the live protocol of the BoliU
"BL384" unit (UDP, pings + fragmented JPEG stream) and renders all UDP metadata
in a device-generic telemetry panel. Binding spec:
`docs/ARCHITECTURE.md` (protocol background: `../analysis/01-arc42-architecture.md` §10b).

Scope: single transport (`boliu`, REQ-BOL-\*), the `DeviceTransport` registry as
the only extension point (REQ-ARCH-\*), no recording/cloud/config features.

## Run

```bash
# headless validation run (window not required):
QT_QPA_PLATFORM=offscreen /home/stefan/reveng/SL_ylz/.venv/bin/python -m otoscope_proto

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

`src/otoscope_proto/data/jhdr_Q100.bin` (607 B) is byte-identical to
`analysis/artifacts/jhdr_Q100.bin`:

```
SHA-256: 3cb1b987c1a58ae529fa9e858d8b29ad78445d4379c869145042184fa9da71b9
```
