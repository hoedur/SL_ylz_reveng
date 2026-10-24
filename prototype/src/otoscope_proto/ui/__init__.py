"""PyQt6 UI layer of the validation prototype (REQ-UI-*, REQ-OPS-001..003).

Device-generic viewer of the telemetry stream: the UI knows only the
:class:`otoscope_proto.telemetry.TelemetryStore` seam — it must never import a
concrete transport (REQ-ARCH-003; the ``TRANSPORTS`` registry is the only
coupling, see ``device/__init__.py``).

Modules:
- ``main``         : CLI bootstrap / graceful shutdown / ``--out`` dump (REQ-OPS-*)
- ``main_window``  : window, splitter layout, 100 ms poll, frame decoding (REQ-UI-001..003, 008/009)
- ``metadata_panel``: Events / Frame / Stats / Raw event tabs (REQ-UI-004..007)
"""
