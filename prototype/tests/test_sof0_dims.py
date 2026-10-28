"""REQ-BOL-010: SOF0 dims patch — native parity for the per-frame raster size.

Evidence chain (doc-04 §9.7/§9.8): the six template heads declare 640×360 at
SOF0 (head bytes 140..148 = ``FF C0 00 11 08 01 68 02 80`` — ``FF C0`` at
140..141, height BE16 at 145..147, width BE16 at 147..149), but the wire announces
the frame's real raster per frame at d[44]/d[46] — empirically 640×480 on all
1 061 frag0 datagrams of both 2026-10-26 lossless app tapes. The native decoder
(``libbl_vii_jni.so`` helper @0x2640) patches the head copy's SOF0 dims
(head+145 = BE16 height, head+147 = BE16 width, write sites @0x26dc/0x26e4)
before appending pages; the prototype must patch too, else every frame renders
on a 640×360 canvas and the bottom 120 rows are silently clipped (they are the
source of the former "surplus entropy"; under the amended REQ-BOL-004 page0
slice the 480-canvas decodes are djpeg-clean on all tape frames — the old
"8374 → 3 extraneous bytes on fid 2080" pairing was an artifact of the
retracted ``d[67:]`` slice, gate round 0/1).

Test vectors are constructed from the REQ-BOL-004 byte layout (helper
``test_reassembly.fragment``); the ONLY reused binary input is
``analysis/artifacts/frame0.bin`` (same rule as REQ-BOL-006, REQ-TEST-004).
"""

import io
import struct
from pathlib import Path

from PIL import Image

from otoscope_proto.device.boliu import BoliUTransport
from otoscope_proto.jpeg_frames import (
    EOI,
    JPEG_HEADER_SIZE,
    JPEG_HEADER_TABLE,
    SOF0_HEIGHT_OFF,
    SOF0_WIDTH_OFF,
    assemble_jpeg,
    patch_sof0_dims,
)
from otoscope_proto.telemetry import TelemetryStore
from test_reassembly import DEVICE_SRC_PORT, fragment, mkpage

FRAME0_PATH = (
    Path(__file__).resolve().parents[2] / "analysis" / "artifacts" / "frame0.bin"
)
FRAME0 = FRAME0_PATH.read_bytes()

import pytest


def test_template_heads_declare_640x360_at_sof0():
    for q in (5, 10, 25, 50, 75, 100):
        head = JPEG_HEADER_TABLE.header_for(q)
        assert head[SOF0_HEIGHT_OFF - 5 : SOF0_HEIGHT_OFF - 3] == b"\xff\xc0"
        assert head[144] == 0x08  # SOF0 sample precision
        assert int.from_bytes(head[145:147], "big") == 360, q
        assert int.from_bytes(head[147:149], "big") == 640, q


def test_patch_sof0_dims_byte_exact_640x480():
    head = JPEG_HEADER_TABLE.header_for(25)
    patched = patch_sof0_dims(head, 640, 480)
    assert patched[145:149] == struct.pack(">H", 480) + struct.pack(">H", 640)
    assert patched[:145] == head[:145]
    assert patched[149:] == head[149:]
    assert len(patched) == JPEG_HEADER_SIZE


def test_patch_sof0_dims_offests_match_doc_values():
    assert (SOF0_HEIGHT_OFF, SOF0_WIDTH_OFF) == (145, 147)


def test_patch_sof0_dims_rejects_out_of_range():
    head = JPEG_HEADER_TABLE.header_for(75)
    with pytest.raises(ValueError):
        patch_sof0_dims(head, 0x10000, 360)
    with pytest.raises(ValueError):
        patch_sof0_dims(head, 640, -5)


def test_assemble_jpeg_without_dims_is_unchanged_backward_compatible():
    head = JPEG_HEADER_TABLE.header_for(25)
    out = assemble_jpeg(head, FRAME0)
    assert out == head + FRAME0 + EOI


def test_assemble_jpeg_with_dims_patches_and_keeps_tail():
    head = JPEG_HEADER_TABLE.header_for(25)
    out = assemble_jpeg(head, FRAME0, width=640, height=480)
    assert out[:JPEG_HEADER_SIZE][145:149] == struct.pack(">H", 480) + struct.pack(
        ">H", 640
    )
    assert out[JPEG_HEADER_SIZE:] == FRAME0 + EOI
    assert len(out) == JPEG_HEADER_SIZE + len(FRAME0) + 2


def test_assemble_jpeg_rejects_half_specified_dims():
    head = JPEG_HEADER_TABLE.header_for(25)
    with pytest.raises(ValueError):
        assemble_jpeg(head, FRAME0, width=640)
    with pytest.raises(ValueError):
        assemble_jpeg(head, FRAME0, height=480)


def test_patched_frame0_declares_and_decodes_640x480():
    out = assemble_jpeg(JPEG_HEADER_TABLE.header_for(25), FRAME0, width=640, height=480)
    with Image.open(io.BytesIO(out)) as img:
        assert img.size == (640, 480)
        img.load()  # full decode pass
        assert img.size == (640, 480)


# -- transport integration: pushed bytes carry the announced raster dims ------


class _SizedTransport(BoliUTransport):
    def __init__(self):
        super().__init__("203.0.113.9", 8800, TelemetryStore("t"), local_port=0)


def _sof_dims(img: bytes) -> tuple[int, int]:
    sof = img.find(b"\xff\xc0")
    h = int.from_bytes(img[sof + 5 : sof + 7], "big")
    w = int.from_bytes(img[sof + 7 : sof + 9], "big")
    return w, h


def test_transport_pushes_frame_with_wire_raster_dims():
    t = _SizedTransport()
    fid, size, cnt = 7, 2047, 2  # last page = size - 1024 = 1023
    pages = [mkpage(3, 1024), mkpage(4, 1023)]
    dgram0 = fragment(fid, 0, cnt, size, pages[0], w=640, h=480, q=0x4B)
    dgram1 = fragment(fid, 1, cnt, size, pages[1], w=640, h=480, q=0x4B)
    t._handle_datagram(dgram0, f"203.0.113.9:{DEVICE_SRC_PORT}")
    t._handle_datagram(dgram1, f"203.0.113.9:{DEVICE_SRC_PORT}")
    jpeg, ts = t.store.pop_frame()
    assert jpeg is not None and ts is not None
    assert _sof_dims(jpeg) == (640, 480)
    assert len(jpeg) == JPEG_HEADER_SIZE + size + 2
    assert jpeg[:JPEG_HEADER_SIZE][145:149] == b"\x01\xe0\x02\x80"
