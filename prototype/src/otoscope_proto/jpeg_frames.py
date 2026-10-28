"""Pure JPEG reconstruction helpers for the frame reassembly path.

Amended protocol (REQ-BOL-006, validated 2026-10-24): the phone-side JPEG
header is picked **per frame from the announced quality byte** (the low byte of
the u16 at datagram offset 48), exactly like the shipped native code
(``handle_mcu_msg_frag``, libbl_vii_jni.so): quality ∈ {5, 10, 25, 50, 75, 100}
→ the matching embedded ``jpeg_header_640x360_Q…`` head; unknown → keep the
previously selected head (initially Q100).

The heads are **605 B** each: they end right after the SOS marker, and the old
607-byte ``analysis/artifacts/jhdr_Q*.bin`` extractions were two bytes too long
(stray tails that either broke the entropy stream — Q5..Q75, literal ``FF D8``
tail — or silently misaligned it — Q100, stray ``5d 02`` tail which caused the
"washed-out grey" artifact on live frames).

``src/otoscope_proto/data/jhdr_Q{5,10,25,50,75,100}.bin`` are 605-byte copies
extracted fresh from ``libbl_vii_jni.so`` (SHA-256s recorded in the README).
Reconstruction: ``header_for(q)`` (SOF0 dims patched from the wire's announced
w/h, REQ-BOL-010 native parity — the wire raster is 640×480, not the template's
640×360) ``+ Σ pages`` + ``FF D9``. No decoding happens
inside the transport (performance rule) — the UI owns that.

Standard library only.
"""

from __future__ import annotations

import importlib.resources
from collections.abc import Mapping
from dataclasses import dataclass

__all__ = [
    "JPEG_HEADER_SIZE",
    "EOI",
    "JHDR_Q100",
    "DEFAULT_HEADER",
    "JpegHeaderTable",
    "JPEG_HEADER_TABLE",
    "load_heads",
    "assemble_jpeg",
    "patch_sof0_dims",
    "SOF0_HEIGHT_OFF",
    "SOF0_WIDTH_OFF",
    "jpeg_size",
]

#: Length of a valid embedded JPEG header (amended REQ-BOL-006). The heads end
#: immediately after the SOS marker segment; 607 was an extraction artifact.
JPEG_HEADER_SIZE = 605

#: JPEG end-of-image marker appended after the payload (REQ-BOL-005).
EOI = b"\xff\xd9"

#: Quality levels shipped in ``libbl_vii_jni.so`` (symbols at 0x4c1a … 0x57eb,
#: 605-byte stride), mirrored as data files.
QUALITY_LEVELS = (5, 10, 25, 50, 75, 100)


def _load_head(q: int) -> bytes:
    res = importlib.resources.files("otoscope_proto")
    for part in ("data", f"jhdr_Q{q}.bin"):
        res = res.joinpath(part)
    header = res.read_bytes()
    if len(header) != JPEG_HEADER_SIZE:
        raise RuntimeError(
            f"data/jhdr_Q{q}.bin must be exactly {JPEG_HEADER_SIZE} bytes, got {len(header)}"
        )
    return header


def load_heads() -> Mapping[int, bytes]:
    """Load all embedded heads into a quality -> bytes mapping."""
    return {q: _load_head(q) for q in QUALITY_LEVELS}


#: Quality-100 head — still usable as the initial fallback head (all-ones DQT).
JHDR_Q100: bytes = _load_head(100)

#: Initial fallback header (before any announced quality was seen).
DEFAULT_HEADER: bytes = JHDR_Q100


@dataclass(frozen=True)
class JpegHeaderTable:
    """Per-quality JPEG header table (amended REQ-BOL-005/006).

    The device announces a quality byte per frame and the matching head must
    be prepended (native ``handle_mcu_msg_frag`` behavior). Unknown qualities
    resolve to ``None`` — the caller keeps the last selected head.
    """

    headers: Mapping[int, bytes]

    def header_for(self, quality: int) -> bytes | None:
        return self.headers.get(int(quality))


#: All six embedded heads (the registry of known 605-byte headers).
JPEG_HEADER_TABLE = JpegHeaderTable(load_heads())


#: Byte offset of the SOF0 height field inside the template heads (REQ-BOL-010).
#: Head layout: ``FF D8 | FF DB … | FF C0 00 11 08 <h:2> <w:2> 03 …`` with SOF0 at
#: 141..149; height (big-endian) at 145..147, width (big-endian) at 147..149.
#: All six template heads declare 640×360 there; the native decoder patches these
#: two fields per frame from the wire's announced w/h (helper @0x26c8-0x26e4).
SOF0_HEIGHT_OFF = 145

#: Big-endian width field offset (REQ-BOL-010); ``SOF0_WIDTH_OFF`` = height + 2.
SOF0_WIDTH_OFF = SOF0_HEIGHT_OFF + 2


def assemble_jpeg(
    header: bytes, payload: bytes, *, width: int | None = None, height: int | None = None
) -> bytes:
    """Return ``header + payload + FF D9`` (REQ-BOL-005/006).

    REQ-BOL-010: when both ``width`` and ``height`` are given, the head copy is
    first SOF0-dimension-patched from the wire values (native parity) — call
    sites must pass the announced ``w``/``h`` so a frame decodes on its true
    raster canvas (e.g. 640×480). Without them the head is used unchanged
    (backward-compatible with the 2026-10-24 recipe).
    """
    if (width is None) != (height is None):
        raise ValueError("assemble_jpeg: width and height must be given together")
    if width is not None:
        header = patch_sof0_dims(header, width, height)
    return bytes(header) + bytes(payload) + EOI


def patch_sof0_dims(header: bytes, width: int, height: int) -> bytes:
    """Return a copy of ``header`` with its SOF0 dims set to ``height``/``width``.

    REQ-BOL-010 (native parity): the template heads declare 640×360, but the wire
    announces the frame's real raster w/h per datagram (d[44]/d[46], LE16 —
    empirically 640×480 on every observed frame). The shipped native decoder
    writes the wire values (big-endian) into the head copy's SOF0 at 145..149
    before decoding; the prototype must do the same or every frame decodes on a
    640×360 canvas and silently clips the bottom 120 rows.

    ``width``/``height`` must fit a u16 (JPEG SOF0 constraint).
    """
    if not 0 <= int(width) <= 0xFFFF or not 0 <= int(height) <= 0xFFFF:
        raise ValueError(f"SOF0 dims out of range: {width}x{height}")
    hh = bytearray(header)
    hh[SOF0_HEIGHT_OFF : SOF0_HEIGHT_OFF + 2] = int(height).to_bytes(2, "big")
    hh[SOF0_WIDTH_OFF : SOF0_WIDTH_OFF + 2] = int(width).to_bytes(2, "big")
    return bytes(hh)


def jpeg_size(payload_len: int) -> int:
    """Reconstructed JPEG length for a payload of ``payload_len`` bytes:
    ``605 (header) + payload_len + 2 (EOI)`` = ``607 + payload_len``
    (REQ-BOL-006; the old "607 + payload + 2" description had the same total)."""
    return JPEG_HEADER_SIZE + int(payload_len) + len(EOI)
