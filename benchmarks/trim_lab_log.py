"""Keeps what a graph-lab run's numbers come from, and only the run's own part of a long log.

Usage: py benchmarks/trim_lab_log.py logs/quest_<time>.log benchmarks/results/raw_<date>/<name>.log

`scripts/quest.py` keeps writing the headset's logcat until it is stopped, so the next runs land in the tail of an
earlier run's file: this stops after the first `graph lab: done.` (the end of the first run in the file). The lines kept
are those `benchmarks/quest_lab_steps.py` and `benchmarks/gpu_profile_steps.py` read (step names, per-view lines, VrApi,
the engine's GPU profile, fps lines, the renderer), which is a few hundred KB for a run of 10 MB.
With the editor's window Live, logcat has thousands of `BufferQueueProducer: ... Waiting for available buffer` lines of
the panel nobody sees (10122 in one run of 2026-11-10); they name ProjectManager and are left out.
"""
import re
import sys
from pathlib import Path

KEEP = re.compile(r"graph lab:|VrApi|GPU PROFILE|\t-[A-Z]|XR Editor: \d+ fps|OpenXR runtime|display refresh|Vulkan 1\.|ProjectManager|Starting org\.godotengine")
DROP = "Waiting for available buffer"


def trim(source: Path, target: Path) -> int:
    """Writes the kept lines of [source]'s first run to [target]; their number."""
    target.parent.mkdir(parents=True, exist_ok=True)
    kept = 0
    with source.open(encoding="utf-8", errors="replace") as reader, target.open("w", encoding="utf-8", newline="\n") as writer:
        for line in reader:
            if KEEP.search(line) and DROP not in line:
                writer.write(line)
                kept += 1
            if "graph lab: done." in line:
                break
    return kept


def main() -> None:
    source, target = Path(sys.argv[1]), Path(sys.argv[2])
    kept = trim(source, target)
    print("%s: %d line(s) kept, %.0f KB" % (target, kept, target.stat().st_size / 1024))


if __name__ == "__main__":
    main()
