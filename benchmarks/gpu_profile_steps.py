"""Averages the engine's GPU PROFILE blocks (--gpu-profile, printed once a second) by graph-lab step.

Usage: py benchmarks/gpu_profile_steps.py logs/quest_<time>.log

Each block is "GPU PROFILE (total X ms):" followed by "-Stage: Y ms" lines; a block belongs to the step whose
"graph lab: <step>" line came last before it. The first block after a step starts is skipped (it holds the change).
Prints a Markdown table: the steps in order, their blocks, the mean total and the mean of every stage.
"""
import re
import sys
from collections import OrderedDict
from pathlib import Path

STEP = re.compile(r"XR Editor: graph lab: ((?:compat_)?[a-z][a-z0-9_]*)\s*$")
NOT_STEPS = {"done", "framing", "graph", "view", "picture", "rebuilt", "scene", "renderer", "foveation", "frames", "leaving"}
HEAD = re.compile(r"GPU PROFILE \(total ([\d.]+)ms\)")
STAGE = re.compile(r"godot\s*:\s*\t-(.+?): ([\d.]+)ms")


def main() -> None:
    path = Path(sys.argv[1])
    steps: "OrderedDict[str, list]" = OrderedDict()
    stages: list[str] = []
    current = None
    block = None
    skip = 0
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        found = STEP.search(line)
        if found and found.group(1).split("_")[0] not in NOT_STEPS:
            current = found.group(1)
            steps.setdefault(current + "#" + str(len(steps)), [])
            current = list(steps)[-1]
            skip = 1
            block = None
            continue
        head = HEAD.search(line)
        if head:
            if current is None: continue
            if skip > 0:
                skip -= 1
                block = None
                continue
            block = {"total": float(head.group(1))}
            steps[current].append(block)
            continue
        stage = STAGE.search(line)
        if stage and block is not None:
            name = stage.group(1)
            if name not in stages: stages.append(name)
            block[name] = block.get(name, 0.0) + float(stage.group(2))
    # Stages that never reach 0.05 ms in any step are CPU-side markers of single frames: left out.
    stages = [s for s in stages if any(sum(b.get(s, 0.0) for b in blocks) / max(len(blocks), 1) >= 0.05 for blocks in steps.values())]
    print("| Step | Blocks | Total ms | " + " | ".join(stages) + " |")
    print("|---|---|---|" + "---|" * len(stages))
    for key, blocks in steps.items():
        if not blocks:
            continue
        mean = lambda name: sum(b.get(name, 0.0) for b in blocks) / len(blocks)
        print("| %s | %d | %.2f | %s |" % (key.split("#")[0], len(blocks), mean("total"), " | ".join("%.2f" % mean(s) for s in stages)))


main()
