"""Per-step tables of the engine's and GDScript's zones from Tracy captures of a graph lab run on the PC
(scripts/xr_editor.py --tracy; docs/performance_plan.md step 1.5, D-160; docs/profiling_builds.md).

Usage: py benchmarks/tracy_steps.py logs/editor_<runtime>_<time> [--top N] [--thread ID] [--zone NAME ...]
  logs/editor_<runtime>_<time>   the run's stem (its log without .log): its captures are
                                 logs/editor_<runtime>_<time>_tracy_<n>_<step>.tracy

Runs tracy-csvexport (scripts/build_engine.py tools) on every capture, zone by zone, and counts only one
thread: the one with the frame zone Main::iteration (the editor's main thread; scripts and the editor's
rendering run there, D-157) unless --thread gives another id. Times are per frame: divided by the
number of Main::iteration zones in the capture. Own time is a zone without its children.
Prints, for each step: frames and the mean frame; the frame's phases (the zones in main/main.cpp, such as
process, physics, RenderingServer::draw, OS::add_frame_delay, with their children); own time summed by
area (plugin scripts, other scripts, the engine's C++ by folder of the zone); the top zones by own time;
and the own time of GDScript zones summed by script file. GDScript zones include engine methods called
from a script (system calls), under the calling script's file and line. --zone lists those zones' total time per frame across the
steps, one column each.
A zone's own time includes work in it that has no zone of its own (C++ without GodotProfileZone).
"""
from __future__ import annotations

import argparse
import csv
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import build_engine  # noqa: E402

CAPTURE = re.compile(r"_tracy_(\d+)_([a-z_0-9]+)\.tracy$")
FRAME_ZONE = "Main::iteration"
PLUGIN = "res://addons/xr_editor/"
# The engine's top folders, for the summary by area; the source paths are absolute (MSVC's __FILE__).
ENGINE_DIRS = ("servers", "scene", "editor", "modules", "core", "main", "drivers", "platform", "thirdparty")

Key = tuple[str, str, str, str]  # name, file, line, thread


def export(capture: Path, self_time: bool) -> dict[Key, list[int]]:
    """(calls, ns) by zone and thread, from tracy-csvexport -u (every zone) streamed."""
    tool = build_engine.TRACY_TOOLS / "tracy-csvexport.exe"
    if not tool.is_file():
        sys.exit(f"tracy_steps: {tool} isn't there; run py scripts/build_engine.py tools")
    process = subprocess.Popen([str(tool), "-u", *(["-e"] if self_time else []), str(capture)],
                               stdout=subprocess.PIPE, text=True, errors="replace")
    assert process.stdout is not None
    totals: dict[Key, list[int]] = defaultdict(lambda: [0, 0])
    for row in csv.DictReader(process.stdout):
        try:
            entry = totals[(row["name"], row["src_file"], row["src_line"], row["thread"])]
            entry[0] += 1
            entry[1] += int(row["exec_time_ns"])
        except (KeyError, ValueError, TypeError):
            continue
    if process.wait() != 0:
        sys.exit(f"tracy_steps: tracy-csvexport failed on {capture.name}")
    return totals


def area(file: str) -> str:
    """Where a zone's own time goes. Engine zones are named after the code that measures them, which is
    often main/main.cpp for whole subsystems: their own time is the subsystem's work without zones."""
    if file.startswith(PLUGIN):
        return "GDScript: plugin (" + PLUGIN + "), with engine calls made from it"
    if file.startswith("res://"):
        return "GDScript: other scripts, with engine calls made from them"
    return "engine C++ (" + (short(file).split("/")[0] or "?") + "/)"


def short(file: str) -> str:
    if file.startswith("res://"):
        return file
    parts = Path(file.replace("\\", "/")).parts
    for i, part in enumerate(parts):
        if part in ENGINE_DIRS:
            return "/".join(parts[i:])
    return file


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("stem")
    parser.add_argument("--top", type=int, default=25)
    parser.add_argument("--thread", help="thread id to count (default: the one with Main::iteration)")
    parser.add_argument("--zone", action="append", default=[], help="a zone to compare across the steps; repeatable")
    options = parser.parse_args()
    stem = Path(options.stem)
    if stem.suffix == ".log":
        stem = stem.with_suffix("")
    captures = sorted((p for p in stem.parent.glob(stem.name + "_tracy_*.tracy") if CAPTURE.search(p.name)),
                      key=lambda p: int(CAPTURE.search(p.name).group(1)))
    if not captures:
        sys.exit(f"tracy_steps: no {stem.name}_tracy_<n>_<step>.tracy in {stem.parent}")
    compared: list[tuple[str, dict[str, float]]] = []
    for capture in captures:
        number, step = CAPTURE.search(capture.name).groups()
        total = export(capture, False)
        own = export(capture, True)
        frames_by_thread = {k[3]: v[0] for k, v in total.items() if k[0] == FRAME_ZONE}
        print(f"\n### {number} {step}\n")
        if not frames_by_thread:
            print(f"No whole {FRAME_ZONE} zone: the capture fell inside one long frame (a graph being built:"
                  " start captures later, --tracy-delay) or didn't connect (empty file).")
            continue
        thread = options.thread or max(frames_by_thread, key=lambda t: frames_by_thread[t])
        frames = frames_by_thread.get(thread, 0)
        if frames == 0:
            print(f"No {FRAME_ZONE} zones on thread {thread}.")
            continue
        per_frame = lambda ns: ns / frames / 1e6
        frame_ms = per_frame(next(v[1] for k, v in total.items() if k[0] == FRAME_ZONE and k[3] == thread))
        other_threads = sorted({k[3] for k in total} - {thread})
        print(f"Thread {thread}: frames {frames}, mean {FRAME_ZONE} {frame_ms:.2f} ms"
              + (f"; zones on other threads left out: {', '.join(other_threads)}" if other_threads else "") + ".\n")
        rows = [(k, own.get(k, [0, 0])[1], v[1], v[0]) for k, v in total.items() if k[3] == thread]
        # The frame's phases are zones in main/main.cpp (process, physics, RenderingServer::draw, the
        # frame delay...): their total time, children included. By own time the frame splits further
        # into scripts and the engine's C++.
        phases = sorted((r for r in rows if short(r[0][1]) == "main/main.cpp" and r[0][0] != FRAME_ZONE),
                        key=lambda r: -r[2])
        print("| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |\n|---|---|---|")
        for k, _, total_ns, calls in phases:
            print(f"| {k[0]} | {per_frame(total_ns):.3f} | {calls / frames:.1f} |")
        by_area: dict[str, float] = defaultdict(float)
        for k, own_ns, _, _ in rows:
            by_area[area(k[1])] += per_frame(own_ns)
        print("\n| Own time by area | ms/frame |\n|---|---|")
        for name, ms in sorted(by_area.items(), key=lambda item: -item[1]):
            print(f"| {name} | {ms:.3f} |")
        rows.sort(key=lambda r: -r[1])
        print("\n| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |\n|---|---|---|---|---|")
        for k, own_ns, total_ns, calls in rows[:options.top]:
            print("| %s | %s:%s | %.3f | %.3f | %.1f |" % (k[0].replace("|", "\\|"), short(k[1]), k[2],
                  per_frame(own_ns), per_frame(total_ns), calls / frames))
        scripts: dict[str, float] = defaultdict(float)
        for k, own_ns, _, _ in rows:
            if k[1].startswith("res://"):
                scripts[k[1]] += per_frame(own_ns)
        if scripts:
            print("\n| GDScript file (own time, summed) | ms/frame |\n|---|---|")
            for file, ms in sorted(scripts.items(), key=lambda item: -item[1])[:options.top]:
                print(f"| {file} | {ms:.3f} |")
        compared.append((step, {z: per_frame(sum(r[2] for r in rows if r[0][0] == z)) for z in options.zone}))
    if options.zone and compared:
        print("\n| Step | " + " | ".join(options.zone) + " |\n|---|" + "---|" * len(options.zone))
        for step, values in compared:
            print(f"| {step} | " + " | ".join(f"{values[z]:.3f}" for z in options.zone) + " |")


main()
