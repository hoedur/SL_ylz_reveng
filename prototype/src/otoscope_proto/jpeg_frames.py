"""Pure JPEG reconstruction helpers for the frame reassembly path.

REQ-BOL-005/006: the reconstructed stream is

    jhdr_Q100.bin (607 B) + fragment pages in index order + b"FF D9"

``src/otoscope_proto/data/jhdr_Q100.bin`` must be byte-identical to
``analysis/artifacts/jhdr_Q100.bin`` (SHA-256 recorded in the README). This is
the only binary input used here; no decoding happens inside the transport
(performance rule) — the UI owns PIL decoding.

Standard library only.
"""

from __future__ import annotations

import importlib.resources
from collections.abc import Mapping
from dataclasses import dataclass

__all__ = [
    "JPEG_HEADER_SIZE",
    "JHDR_Q100",
    "DEFAULT_HEADER",
    "JpegHeaderTable",
    "JPEG_HEADER_TABLE",
    "assemble_jpeg",
    "jpeg_size",
]

#: Length of a valid embedded JPEG header (REQ-BOL-005: 607 B).
JPEG_HEADER_SIZE = 607

#: JPEG end-of-image marker appended after the payload (REQ-BOL-005).
EOI = b"\xff\xd9"

_DATA_PARTS = ("data", "jhdr_Q100.bin")


def _load_default_header() -> bytes:
    res = importlib.resources.files("otoscope_proto")
    for part in _DATA_PARTS:
        res = res.joinpath(part)
    header = res.read_bytes()
    if len(header) != JPEG_HEADER_SIZE:
        raise RuntimeError(
            "data/jhdr_Q100.bin must be exactly "
            f"{JPEG_HEADER_SIZE} bytes, got {len(header)}"
        )
    return header


#: The Q100 header — the one that empirically decodes (arc42 §10b).
JHDR_Q100: bytes = _load_default_header()

#: Header used by :class:`JpegHeaderTable`-equivalent reconstruction paths.
DEFAULT_HEADER: bytes = JHDR_Q100


@dataclass(frozen=True)
class JpegHeaderTable:
    """Quality-byte -> JPEG-header table (REQ-BOL-005/006 header table object).

    The shipped native code embedded a header per announced quality level, but
    the live unit decodes only with the Q100 header regardless of the announced
    quality byte; reconstruction therefore uses the table's Q100 entry.
    """

    headers: Mapping[int, bytes]

    def header_for(self, quality: int) -> bytes | None:
        return self.headers.get(quality)


#: Table seeded with the validated entry — the registry of known headers.
JPEG_HEADER_TABLE = JpegHeaderTable({100: JHDR_Q100})


def assemble_jpeg(header: bytes, payload: bytes) -> bytes:
    """Return ``header + payload + FF D9`` (REQ-BOL-005/006)."""
    return bytes(header) + bytes(payload) + EOI


def jpeg_size(payload_len: int) -> int:
    """Reconstructed JPEG length for a payload of ``payload_len`` bytes:
    ``607 + payload_len + 2`` (REQ-BOL-006)."""
    return JPEG_HEADER_SIZE + int(payload_len) + len(EOI)
