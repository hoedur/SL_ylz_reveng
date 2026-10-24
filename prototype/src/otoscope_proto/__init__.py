"""otoscope_proto — PyQt6 validation prototype for the reverse-engineered ear otoscope.

Validation lab for the live-validated UDP protocol of the physical unit (arc42 §10b).
Public seams (see prototype/docs/ARCHITECTURE.md — that document is binding):

- ``telemetry``    : device-generic TelemetryEvent / TelemetryStore (REQ-TEL-*)
- ``jpeg_frames``  : pure JPEG reconstruction helpers (REQ-BOL-005/006)
- ``device``       : DeviceTransport ABC + TRANSPORTS registry (REQ-ARCH-*) — the only
                     place concrete transports are coupled.

``python -m otoscope_proto`` starts the PyQt6 UI (implemented in ``ui/``).

Core modules are stdlib-only; no decode happens inside the transport path.
"""

__version__ = "0.1.0"

__all__ = ["__version__"]
