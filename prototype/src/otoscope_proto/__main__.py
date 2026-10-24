"""``python -m otoscope_proto`` entry point (REQ-OPS-001: CLI bootstrap)."""

from otoscope_proto.ui.main import run_cli

if __name__ == "__main__":
    raise SystemExit(run_cli())
