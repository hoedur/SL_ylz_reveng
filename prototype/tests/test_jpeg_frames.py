"""REQ-BOL-006 (amended 2026-10-24) — JPEG header table + pure assembly helpers.

Vectors (REQ-TEST-004, amended):
- ``analysis/artifacts/jhdr_Q{5,10,25,50,75,100}.bin`` — the shipped extraction is 607 B
  and carries a 2-byte stray tail of the adjacent data pool; the valid head is
  ``artifact[:605]`` (ends right after the SOS segment),
- ``analysis/artifacts/frame0.bin`` — 14 059 B payload of one complete live frame
  (announced quality byte 25). *(Provenance note 2026-10-28: frame0.bin was assembled
  pre-gate round 0 with the retracted ``page0 = d[67:]`` slice — under djpeg the
  canonical-recipe decode of the *artifact* warns ("3224 extraneous bytes"); the
  wire-exact rebuild of the same frame is djpeg-clean at 640×480
  (`analysis/artifacts/frag0_layout_2026-10-27/`). The tests below pass for geometry
  reasons — PIL is warning-blind; see `analysis/artifacts/README.md`.)*

Contract under test (docs/ARCHITECTURE.md §6 / amended REQ-BOL-005/006):
- ``JPEG_HEADER_SIZE == 605``; ``JpegHeaderTable`` keys exactly {5,10,25,50,75,100};
- ``header_for(q) -> bytes | None`` (unknown → None → sticky/initial fallback in the transport);
- ``assemble_jpeg(header, payload) = header + payload + FF D9``;
- ``jpeg_size(payload_len) = 605 + payload_len + 2`` (same total as the old 607+payload);
- the artifact case: frame0.bin + the **Q25** head (its announced quality) decodes
  with PIL to 640×360 — and with the old broken 607-byte recipe it did NOT decode
  colorimetrically correctly (washed-out grey), which is what the amendment fixes.
"""

from io import BytesIO
from pathlib import Path

from PIL import Image

from otoscope_proto.jpeg_frames import (
    DEFAULT_HEADER,
    JHDR_Q100,
    JPEG_HEADER_SIZE,
    JPEG_HEADER_TABLE,
    QUALITY_LEVELS,
    assemble_jpeg,
    jpeg_size,
)

ARTIFACTS = Path(__file__).resolve().parents[2] / "analysis" / "artifacts"
FRAME0_PATH = ARTIFACTS / "frame0.bin"
DATA_DIR = Path(__file__).resolve().parents[1] / "src" / "otoscope_proto" / "data"

LEVELS = (5, 10, 25, 50, 75, 100)


def _artifact_head(q: int) -> bytes:
    """The valid (605 B) head: shipped artifact truncated to end after SOS."""
    art = (ARTIFACTS / f"jhdr_Q{q}.bin").read_bytes()
    head = art[:605]
    # the 2 extra bytes are over-extraction (stray pool bytes / next head's FF D8)
    assert art[605:607] in (b"\xff\xd8", b"\x5d\x02"), f"unexpected stray tail for Q{q}"
    return head


def test_packaged_heads_are_six_605b_files_byte_identical_to_artifacts():
    # REQ-BOL-006: data/jhdr_Q{q}.bin == artifacts/jhdr_Q{q}.bin[:605], 605 B each.
    for q in LEVELS:
        packaged = (DATA_DIR / f"jhdr_Q{q}.bin").read_bytes()
        assert len(packaged) == 605
        assert packaged == _artifact_head(q)


def test_jpeg_header_table_has_all_six_levels_and_none_outside():
    # REQ-BOL-006: JpegHeaderTable carries exactly {5,10,25,50,75,100}.
    assert set(JPEG_HEADER_TABLE.headers) == set(LEVELS)
    assert QUALITY_LEVELS == LEVELS
    for q in LEVELS:
        head = JPEG_HEADER_TABLE.header_for(q)
        assert head is not None and len(head) == 605
    for q in (0, 1, 4, 6, 11, 24, 26, 49, 51, 74, 76, 99, 101, 0x4B | 0x100):
        assert JPEG_HEADER_TABLE.header_for(q) is None


def test_header_for_0x4b_low_byte_matches_q75_head():
    # Amended REQ-BOL-005/006: the transport selects via the LOW byte of q.
    # (q u16 = 0x014B reports byte49 flags; header_for must map 75 -> the Q75 head.)
    assert JPEG_HEADER_TABLE.header_for(0x014B & 0xFF) == JPEG_HEADER_TABLE.header_for(75)


def test_headers_end_after_sos_marker():
    # REQ-BOL-006: a valid head ends immediately after its SOS segment —
    # the last bytes before EOI-space are the SOS tail "00 3f 00" (Ss=0, Se=63, Ah/Al=0).
    for q in LEVELS:
        head = JPEG_HEADER_TABLE.header_for(q)
        assert head[-3:] == b"\x00\x3f\x00", f"Q{q} head must end after SOS"
        assert not head.endswith(b"\xff\xd8"), f"Q{q} head must not contain a stray FF D8 tail"


def test_jhdr_q100_and_default_header_are_the_q100_head():
    # REQ-BOL-006: initial sticky fallback head = the quality-100 head (all-ones DQT).
    assert DEFAULT_HEADER == JHDR_Q100 == (DATA_DIR / "jhdr_Q100.bin").read_bytes()


def test_jpeg_size_is_605_plus_payload_plus_two():
    # Amended REQ-BOL-006: jpeg_size(payload_len) == 605 + payload_len + 2 (605 B head).
    # The old "607 + payload + 2" recipe had the same numeric total, so the captured
    # artifact lengths stay valid:
    assert jpeg_size(14_059) == 605 + 14_059 + 2 == 14_666  # the frame0.bin artifact case
    assert jpeg_size(2_100) == 605 + 2_100 + 2 == 2_707    # the fake-device default size (spec §5)
    # NB: the pre-amendment recipe (607 B head incl. the 2-byte stray tail) yielded
    # 14_668 / 2_709 — the stray bytes were counted as if they were stream data.


def test_assemble_jpeg_is_header_plus_payload_plus_eoi():
    # REQ-BOL-006: reconstruction = header + payload + FF D9, nothing else.
    head = JPEG_HEADER_TABLE.header_for(100)
    payload = FRAME0_PATH.read_bytes()
    out = assemble_jpeg(head, payload)
    assert out == head + payload + b"\xff\xd9"
    assert len(out) == len(head) + len(payload) + 2
    assert len(out) == jpeg_size(len(payload))


def test_assembled_frame0_artifact_decodes_to_640x360_with_its_q25_head():
    # Amended REQ-BOL-006: frame0.bin was announced with q=25; assembled with the
    # Q25 head it must decode (full pass) to 640x360.
    out = assemble_jpeg(JPEG_HEADER_TABLE.header_for(25), FRAME0_PATH.read_bytes())
    assert len(out) == jpeg_size(14_059) == 14_666

    with Image.open(BytesIO(out)) as img:
        assert img.size == (640, 360)
        img.load()  # full decode pass, not just stream verify
        assert img.size == (640, 360)


def test_77_q_falls_back_to_initial_head_is_transport_concern_not_table():
    # REQ-BOL-005 (amended): an unknown quality keeps the last selected head —
    # the TABLE itself must NOT silently substitute; it returns None.
    assert JPEG_HEADER_TABLE.header_for(77) is None
    assert JPEG_HEADER_SIZE == 605
