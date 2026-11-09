#!/usr/bin/env python3
"""The graph lab's steps on a standalone headset or on this PC (docs/decisions.md, D-152, D-155, D-157).

Reads a log written by scripts/quest.py or scripts/xr_editor.py and splits it by the
lab's "graph lab: <step>" lines.
On a headset: for each step the medians of the Meta runtime's lines (logcat tag VrApi,
one a second) without the first seconds, and the GPU's clock and foveation the runtime had
in it, as they follow the load.
Without VrApi lines (the PC, the simulator): the lab's own "graph lab: frames" lines, which are
the frame rate, the VR view's render time, the process time and the draw calls of the last report of the step.
Then, if the run measured viewports (--xre-graph-lab-base, -stress, -views), for each step what each
viewport that rendered cost and drew in its last report (D-157, step 1.1), and the stress steps' sizes.

Usage: py benchmarks/quest_lab_steps.py [--no-views] logs/quest_<time>.log [more logs]
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
FRAMES = re.compile(r"graph lab: frames (\d+) fps, VR view render CPU ([\d.]+) ms, GPU ([\d.]+) ms, process ([\d.]+) ms, (\d+) draw calls")
VIEW = re.compile(r"graph lab: view (\S+): render CPU ([\d.]+) ms, GPU ([\d.]+) ms, visible (\d+) call\(s\) (\d+) object\(s\) (\d+) primitive\(s\), shadow (\d+) call\(s\), canvas (\d+) call\(s\)")
SIZE = re.compile(r"graph lab: (graph of \d+ block\(s\), \d+ wire\(s\)|scene of \d+ object\(s\) added)")
STEP_FIELDS = ("fps", "stale", "fov", "cpu_level", "gpu_level", "cpu_mhz", "gpu_mhz", "tw", "app", "cpu_gpu", "gpu_load")
VIEW_FIELDS = ("cpu", "gpu", "calls", "objects", "primitives", "shadow", "canvas")


def summarize(step: str, rows: list[dict[str, str]], calls: list[int], frames: list[tuple[str, ...]],
              views: dict[str, dict[str, float]], sizes: list[str]) -> dict[str, object] | None:
    extra = {"views": views, "sizes": sizes}
    body = rows[SKIPPED_SEC:]
    if not body:
        if not frames:
            return None
        last = frames[-1]
        return {"step": step, "seconds": len(frames), "pc": True, "fps": float(last[0]), "view_cpu": float(last[1]),
                "view_gpu": float(last[2]), "process": float(last[3]), "calls": int(last[4]), **extra}
    median = lambda field: statistics.median(float(row[field]) for row in body)
    common = lambda field: Counter(row[field] for row in body).most_common(1)[0][0]
    return {"step": step, "seconds": len(body), "fps": median("fps"), "stale": median("stale"), "app": median("app"),
            "rest": median("cpu_gpu") - median("app"), "gpu_load": median("gpu_load"), "gpu_mhz": median("gpu_mhz"),
            "gpu_level": common("gpu_level"), "cpu_level": common("cpu_level"), "fov": common("fov"),
            "calls": calls[-1] if calls else 0, **extra}


def read_steps(path: str) -> list[dict[str, object]]:
    steps: list[dict[str, object]] = []
    step = ""
    rows: list[dict[str, str]] = []
    calls: list[int] = []
    frames: list[tuple[str, ...]] = []
    views: dict[str, dict[str, float]] = {}
    sizes: list[str] = []

    def flush() -> None:
        summary = summarize(step, rows, calls, frames, views, sizes) if step else None
        if summary:
            steps.append(summary)

    with open(path, encoding="utf-8", errors="replace") as log:
        for line in log:
            if "graph lab: done" in line or "graph lab: leaving" in line:
                flush()
                step, rows, calls, frames, views, sizes = "", [], [], [], {}, []
            elif "XR Editor" in line and (found := STEP.search(line)):
                flush()
                step, rows, calls, frames, views, sizes = found.group(1), [], [], [], {}, []
            elif "XR Editor" in line and (found := FRAMES.search(line)):
                frames.append(found.groups())
                calls.append(int(found.group(5)))
            elif "XR Editor" in line and (found := VIEW.search(line)):
                # The last report of the step wins: the first one holds the step's start.
                views[found.group(1)] = dict(zip(VIEW_FIELDS, map(float, found.groups()[1:])))
            elif "XR Editor" in line and (found := SIZE.search(line)):
                sizes.append(found.group(1))
            elif "VrApi" in line and (found := LINE.search(line)):
                rows.append(dict(zip(STEP_FIELDS, found.groups())))
    flush()
    return steps


def print_steps(steps: list[dict[str, object]]) -> None:
    if all(step.get("pc") for step in steps):
        print("| Step | reports | fps | VR view CPU | VR view GPU | process | Calls |\n|---|---|---|---|---|---|---|")
        for step in steps:
            print(f"| {step['step']} | {step['seconds']} | {step['fps']:.0f} | {step['view_cpu']:.2f} | {step['view_gpu']:.2f} "
                  f"| {step['process']:.2f} | {step['calls']} |")
        return
    print("| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |\n|---|---|---|---|---|---|---|---|---|---|---|")
    for step in steps:
        if step.get("pc"):
            continue
        print(f"| {step['step']} | {step['seconds']} | {step['fps']:.0f} | {step['stale']:.0f} | {step['app']:.2f} | {step['rest']:.1f} "
              f"| {step['gpu_load']:.2f} | {step['gpu_mhz']:.0f} | {step['cpu_level']}/{step['gpu_level']} | {step['fov']} | {step['calls']} |")


def print_views(steps: list[dict[str, object]]) -> None:
    """Per step, the viewports that drew or took time in its last report, the busiest first."""
    if not any(step["views"] for step in steps):
        return
    print("\nViewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):")
    print("| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |\n|---|---|---|---|---|---|---|---|---|")
    for step in steps:
        views: dict[str, dict[str, float]] = step["views"]  # type: ignore[assignment]
        order = sorted(views.items(), key=lambda item: (item[1]["gpu"] + item[1]["cpu"], item[1]["calls"]), reverse=True)
        for name, data in order:
            print(f"| {step['step']} | {name} | {data['cpu']:.2f} | {data['gpu']:.2f} | {data['calls']:.0f} | {data['objects']:.0f} "
                  f"| {data['primitives']:.0f} | {data['shadow']:.0f} | {data['canvas']:.0f} |")
        for size in step["sizes"]:  # type: ignore[attr-defined]
            print(f"| {step['step']} | ({size}) | | | | | | | |")


def main() -> int:
    paths = [arg for arg in sys.argv[1:] if not arg.startswith("--")]
    if not paths:
        print(__doc__)
        return 2
    for path in paths:
        steps = read_steps(path)
        print(f"\n{path}")
        if not steps:
            print("no steps")
            continue
        print_steps(steps)
        if "--no-views" not in sys.argv:
            print_views(steps)
    return 0


if __name__ == "__main__":
    sys.exit(main())
