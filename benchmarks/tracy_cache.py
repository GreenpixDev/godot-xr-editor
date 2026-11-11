"""Keeps what benchmarks/tracy_steps.py and benchmarks/tracy_process.py work out of a Tracy capture, beside the capture.

tracy-csvexport writes every zone of a capture as a CSV line: 37 s for a capture of 6 MB (158 MB of CSV) and 2 min 44 s
for one of 16 MB (720 MB), measured 2026-11-11, and the step tables asked for it again on every call (six logs took
15-20 minutes). The sums the tables are made of are small: they go in <capture>.<kind>.cache, and are read back while the
capture's size and time and the kind's version stay the same. --no-cache of either script works them out again.
The files lie in logs/, which git ignores; delete them freely.
"""
from __future__ import annotations

import pickle
from collections.abc import Callable
from pathlib import Path
from typing import TypeVar

T = TypeVar("T")


def cached(capture: Path, kind: str, version: int, compute: Callable[[], T], use: bool = True) -> T:
    """[compute]'s result for [capture], from its cache file if that was made from this capture by this [version]."""
    path = capture.with_name(f"{capture.name}.{kind}.cache")
    stat = capture.stat()
    stamp = (version, stat.st_size, stat.st_mtime_ns)
    if use and path.is_file():
        try:
            with path.open("rb") as file:
                kept_stamp, value = pickle.load(file)
            if kept_stamp == stamp:
                return value
        except (OSError, EOFError, ValueError, pickle.UnpicklingError):
            pass
    value = compute()
    try:
        with path.open("wb") as file:
            pickle.dump((stamp, value), file, protocol=pickle.HIGHEST_PROTOCOL)
    except OSError:
        pass
    return value
