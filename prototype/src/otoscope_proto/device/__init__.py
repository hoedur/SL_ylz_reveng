"""Device abstraction: the single extension seam (REQ-ARCH-001..005).

Concrete transports live in their own modules (``boliu.py`` …) and register
themselves into :data:`TRANSPORTS`. ``telemetry`` and the UI must never import
them (REQ-ARCH-003).
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import ClassVar

from otoscope_proto.telemetry import TelemetryStore

__all__ = ["DeviceTransport", "Frame", "TRANSPORTS", "create_transport"]


@dataclass(frozen=True)
class Frame:
    """One reconstructed video frame delivered to the UI (REQ-ARCH-001)."""

    jpeg_bytes: bytes
    recv_ts: float  # monotonic seconds


class DeviceTransport(ABC):
    """Abstract transport seam.

    Constructors accept ``(host, port, store)`` and must not touch the network
    or spawn threads before :meth:`start` (REQ-ARCH-004). ``stop()`` must be
    idempotent.
    """

    #: Unique registry key (REQ-ARCH-001/002).
    name: ClassVar[str]

    def __init__(self, host: str, port: int, store: TelemetryStore) -> None:
        self.host = str(host)
        self.port = int(port)
        self.store = store

    @abstractmethod
    def start(self) -> None: ...

    @abstractmethod
    def stop(self) -> None: ...

    def events(self) -> dict:
        """Statistics snapshot (REQ-ARCH-001) — implemented via the shared
        store (REQ-ARCH-005)."""
        return self.store.snapshot() if self.store is not None else {}

    def frames(self) -> list[Frame]:
        """Drain currently queued frames (REQ-ARCH-001/005)."""
        out: list[Frame] = []
        if self.store is not None:
            while True:
                item = self.store.pop_frame()
                if not item:
                    break
                out.append(Frame(jpeg_bytes=item[0], recv_ts=item[1]))
        return out


#: Module-level registry: name -> class (REQ-ARCH-002).
TRANSPORTS: dict[str, type[DeviceTransport]] = {}


def create_transport(
    name: str, host: str, port: int, store: TelemetryStore
) -> DeviceTransport:
    """Instantiate a registered transport; unknown names raise KeyError."""
    try:
        cls = TRANSPORTS[name]
    except KeyError:
        raise KeyError(name) from None
    return cls(host, port, store)


# --- registry population (REQ-ARCH-003: the registry is the only coupling) ---
from .boliu import BoliUTransport  # noqa: E402  (imported after the ABC)

TRANSPORTS[BoliUTransport.name] = BoliUTransport
