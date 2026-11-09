"""Per-frame GPU time by surface from the ovrgpuprofiler traces that `scripts/quest.py --gpu-profile` saves.

Usage: py benchmarks/gpu_trace_steps.py logs/quest_<time>

Reads logs/quest_<time>_gpu_NN_<step>.txt (one `ovrgpuprofiler -t1 -v` trace of one second per step) and prints a
Markdown table: the steps in order, the frames the trace holds, and the mean GPU ms per frame of the surfaces by size:
  eye     1440x1584, the eye buffer (Mobile draws two of them a frame, Compatibility one: the sum is per frame);
  window  3664x1920 and 1920x3664, the editor's own window (the root viewport);
  shadow  2048x2048, the shadow atlas;
  other   what is left (the plugin's panels).
Surfaces run in a pipeline, so their times add up to more than the frame's `App`: compare the steps with each other,
not the sum with `App`. The detailed mode of the profiler is on, about 10 % more GPU time than without it.
"""
import re
import sys
from pathlib import Path

EYE = "1440x1584"
WINDOW = ("3664x1920", "1920x3664")
SHADOW = "2048x2048"
SURFACE = re.compile(r"^Surface \d+\s+\| (\d+) ?x ?(\d+)\s+\|.*?\|\s+([\d.]+) ms \|", re.M)


def main() -> None:
    stem = Path(sys.argv[1])
    print("| Step | Frames | Eye | Window | Shadow | Other |")
    print("|---|---|---|---|---|---|")
    for path in sorted(stem.parent.glob(stem.name + "_gpu_*.txt")):
        if path.name.endswith("_info.txt"):
            continue
        surfaces = SURFACE.findall(path.read_text(encoding="utf-8", errors="replace"))
        totals = {"eye": 0.0, "window": 0.0, "shadow": 0.0, "other": 0.0}
        eyes = 0
        for width, height, ms in surfaces:
            size = width + "x" + height
            kind = "eye" if size == EYE else "window" if size in WINDOW else "shadow" if size == SHADOW else "other"
            totals[kind] += float(ms)
            eyes += kind == "eye"
        if eyes == 0:
            continue
        step = path.name.split("_gpu_")[1][3:-4]
        compat = step.startswith("compat_")
        frames = eyes if compat else eyes / 2
        print("| %s | %d | %.2f | %.2f | %.2f | %.2f |" % (step, frames, totals["eye"] / frames, totals["window"] / frames, totals["shadow"] / frames, totals["other"] / frames))


main()
