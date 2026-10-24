"""Shared pytest config: structural imports per docs/ARCHITECTURE.md §5.

(Testing agents own their fixtures; they may extend this file or add conftest.py files
under tests/. Keep this minimal — it exists so `pytest` collects from the repo root.)
"""
import os

os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
