"""REQ-BOL-006 — pure JPEG-assembly helpers, verified against captured artifacts.

Vectors (REQ-TEST-004):
- ``analysis/artifacts/jhdr_Q100.bin``  (607 B),
- ``analysis/artifacts/frame0.bin``     (14 059 B payload of one complete frame).

Contract under test (per docs/ARCHITECTURE.md §6 / REQ-BOL-006):
- ``assemble_jpeg(header: bytes, payload: bytes) -> bytes`` = header + payload + ``FF D9``
- ``jpeg_size(payload_len: int) -> int``    = 607 + payload_len + 2

Note: REQ-BOL-006 also demands ``src/otoscope_proto/data/jhdr_Q100.bin`` be byte-identical
to the artifact. Per the amended REQ-TEST-004, data files under ``src/`` are test
vectors, not code, so that byte-identity check is tested here directly.
"""

from io import BytesIO
from pathlib import Path

from PIL import Image

from otoscope_proto.jpeg_frames import assemble_jpeg, jpeg_size

ARTIFACTS = Path(__file__).resolve().parents[2] / "analysis" / "artifacts"
JHDR_PATH = ARTIFACTS / "jhdr_Q100.bin"
FRAME0_PATH = ARTIFACTS / "frame0.bin"
# Amended REQ-TEST-004: data files under src/ are test vectors, not code,
# so reading the packaged header for a byte-identity check is permitted.
DATA_JHDR_PATH = Path(__file__).resolve().parents[1] / "src" / "otoscope_proto" / "data" / "jhdr_Q100.bin"


def test_artifact_vectors_have_specified_sizes():
    # REQ-BOL-006 / REQ-TEST-004: 607 B JPEG header, 14 059 B frame0 payload.
    assert JHDR_PATH.stat().st_size == 607
    assert FRAME0_PATH.stat().st_size == 14_059


def test_packaged_data_header_is_byte_identical_to_artifact():
    # REQ-BOL-006: src/otoscope_proto/data/jhdr_Q100.bin is byte-identical to
    # analysis/artifacts/jhdr_Q100.bin (607 B); reconstruction must use that
    # exact file. Reading it is sanctioned by the amended REQ-TEST-004.
    packaged = DATA_JHDR_PATH.read_bytes()
    assert len(packaged) == 607
    assert packaged == JHDR_PATH.read_bytes()


def test_jpeg_size_is_607_plus_payload_plus_two():
    # REQ-BOL-006: jpeg_size(payload_len) == 607 + payload_len + 2.
    assert jpeg_size(14_059) == 607 + 14_059 + 2  # the frame0.bin artifact case
    assert jpeg_size(2_100) == 607 + 2_100 + 2  # the fake-device default size (spec §5)


def test_assemble_jpeg_is_header_plus_payload_plus_eoi():
    # REQ-BOL-006: reconstruction = jhdr_Q100 + payload + FF D9, nothing else.
    jhdr = JHDR_PATH.read_bytes()
    payload = FRAME0_PATH.read_bytes()
    out = assemble_jpeg(jhdr, payload)
    assert out == jhdr + payload + b"\xff\xd9"
    assert len(out) == 607 + len(payload) + 2 == len(jhdr) + len(payload) + 2
    assert len(out) == jpeg_size(len(payload))


def test_assembled_frame0_artifact_decodes_to_640x360():
    # REQ-BOL-006: the assembled artifact stream must decode with PIL to 640x360.
    out = assemble_jpeg(JHDR_PATH.read_bytes(), FRAME0_PATH.read_bytes())
    assert len(out) == jpeg_size(14_059) == 14_668

    with Image.open(BytesIO(out)) as img:
        assert img.size == (640, 360)
        img.verify()
    # verify() only checks stream integrity; force one full decode pass as well.
    with Image.open(BytesIO(out)) as img:
        img.load()
        assert img.size == (640, 360)
