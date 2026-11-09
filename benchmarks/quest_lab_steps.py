#!/usr/bin/env python3
"""The graph lab's steps on a standalone headset (docs/decisions.md, D-152, D-155).

Reads a log written by scripts/quest.py and splits the Meta runtime's lines
(logcat tag VrApi, one a second) by the lab's "graph lab: <step>" lines. For each
step it prints the medians without the first seconds, and the GPU's clock and foveation
the runtime had in it, as they follow the load.

Usage: py benchmarks/quest_lab_steps.py logs/quest_<time>.log [more logs]
Standard library only.
"""

from __future__ import annotations

import re
import statistics
import sys
from collections import Counter

SKIPPED_SEC = 3
LINE = re.compile(r"FPS=(\d+)/.*?Stale=(\d+).*?Fov=(\w+),CPU4/GPU=(\d+)/(\d+),(\d+)/(\d+)MHz.*?TW=([\d.]+)ms,App=([\d.]+)ms.*?CPU&GPU=([\d.]+)ms.*?GPU%=([\d.]+)")
STEP = re.compile(r"graph lab: ([a-z_0-9]+)\s*$")
CALLS = re.compile(r"graph lab: frames .* (\d+) draw calls")
STEP_FIELDS = ("fps", "stale", "fov", "cpu_level", "gpu_level", "cpu_mhz", "gpu_mhz", "tw", "app", "cpu_gpu", "gpu_load")


def summarize(step: str, rows: list[dict[str, str]], calls: list[int]) -> dict[str, object] | None:
    body = rows[SKIPPED_SEC:]
    if not body:
        return None
    median = lambda field: statistics.median(float(row[field]) for row in body)
    common = lambda field: Counter(row[field] for row in body).most_common(1)[0][0]
    return {"step": step, "seconds": len(body), "fps": median("fps"), "stale": median("stale"), "app": median("app"),
            "rest": median("cpu_gpu") - median("app"), "gpu_load": median("gpu_load"), "gpu_mhz": median("gpu_mhz"),
            "gpu_level": common("gpu_level"), "cpu_level": common("cpu_level"), "fov": common("fov"),
            "calls": calls[-1] if calls else 0}


def read_steps(path: str) -> list[dict[str, object]]:
    steps: list[dict[str, object]] = []
    step = ""
    rows: list[dict[str, str]] = []
    calls: list[int] = []

    def flush() -> None:
        summary = summarize(step, rows, calls) if step else None
        if summary:
            steps.append(summary)

    with open(path, encoding="utf-8", errors="replace") as log:
        for line in log:
            if "graph lab: done" in line or "graph lab: leaving" in line:
                flush()
                step, rows, calls = "", [], []
            elif "XR Editor" in line and (found := STEP.search(line)):
                flush()
                step, rows, calls = found.group(1), [], []
            elif "XR Editor" in line and (found := CALLS.search(line)):
                calls.append(int(found.group(1)))
            elif "VrApi" in line and (found := LINE.search(line)):
                rows.append(dict(zip(STEP_FIELDS, found.groups())))
    flush()
    return steps


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    for path in sys.argv[1:]:
        steps = read_steps(path)
        print(f"\n{path}")
        if not steps:
            print("no steps")
            continue
        print("| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |\n|---|---|---|---|---|---|---|---|---|---|---|")
        for step in steps:
            print(f"| {step['step']} | {step['seconds']} | {step['fps']:.0f} | {step['stale']:.0f} | {step['app']:.2f} | {step['rest']:.1f} "
                  f"| {step['gpu_load']:.2f} | {step['gpu_mhz']:.0f} | {step['cpu_level']}/{step['gpu_level']} | {step['fov']} | {step['calls']} |")
    return 0


if __name__ == "__main__":
    sys.exit(main())
