"""What the frame's `process` phase (main/main.cpp: the scene tree's _process of every node, scripts included)
is made of, from Tracy captures of a graph lab run on the PC (scripts/xr_editor.py --tracy; docs/profiling_builds.md).

Usage: py benchmarks/tracy_process.py logs/editor_<runtime>_<time> [--top N] [--steps a,b] [--summary]
  logs/editor_<runtime>_<time>   the run's stem: its captures are logs/editor_<runtime>_<time>_tracy_<n>_<step>.tracy

Unlike benchmarks/tracy_steps.py, which sums zones over the whole frame, this nests the zones of the main thread
(the one with Main::iteration) by their start and length and counts only those inside `process`. Prints, for each
step: own time by group (the plugin's folders, its lab and simulator apart, other scripts, and the C++ of `process`
itself, which holds the editor's and the engine's nodes: they have no zones of their own); the direct children of
`process` (each node's _process) with what they hold; the zones inside it by total and by own time. With
--summary, one table of the steps instead: the parts the graph lab also times on the headset (graph scripts, the
panels' ray routing, the manipulator) beside the rest. GDScript zones come twice in a chain (the call in the
caller's file and the function in its own), so their totals overlap; own times don't. ms per frame throughout.
Tracy's zone on every GDScript call inflates short, frequent functions: compare its numbers with its own only,
and carry shares, not milliseconds, to the headset.
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
PLUGIN = "res://addons/xr_editor/"
ENGINE_DIRS = ("editor", "scene", "servers", "modules", "core", "main", "drivers", "platform")
# The plugin's parts, by a piece of the script's path; the first that matches wins.
GROUPS = (
    ("lab (telemetry/graph_lab.gd)", "telemetry/graph_lab.gd"),
    ("telemetry, other", "telemetry/"),
    ("simulator (xr/simulator.gd)", "xr/simulator.gd"),
    ("graph (logic_graph/)", "logic_graph/"),
    ("panels and UI (ui/)", "ui/"),
    ("controllers, rays, rig (xr/)", "xr/"),
    ("tools (tools/)", "tools/"),
    ("core (core/)", "core/"),
)

Row = tuple[int, int, str, str, str]  # start ns, length ns, name, file, line


def short(file: str) -> str:
    path = file.replace("\\", "/")
    if path.startswith(PLUGIN):
        return path[len(PLUGIN):]
    if path.startswith("res://"):
        return path
    match = re.search(r"/(" + "|".join(ENGINE_DIRS) + r")/(.*)", path)
    return match.group(1) + "/" + match.group(2) if match else path


def group(file: str) -> str:
    path = file.replace("\\", "/")
    if path.startswith(PLUGIN):
        rest = path[len(PLUGIN):]
        for name, piece in GROUPS:
            if piece in rest:
                return "plugin: " + name
        return "plugin: other (" + rest.split("/")[0] + ")"
    if path.startswith("res://"):
        return "other GDScript"
    return "engine C++ " + short(file).split("/")[0] + "/"


def is_process(row: Row) -> bool:
    return row[2] == "process" and row[3].replace("\\", "/").endswith("main/main.cpp")


def load(capture: Path) -> tuple[list[Row], int]:
    """The main thread's zones, sorted parents first, and its frame count."""
    tool = build_engine.TRACY_TOOLS / "tracy-csvexport.exe"
    if not tool.is_file():
        sys.exit(f"tracy_process: {tool} isn't there; run py scripts/build_engine.py tools")
    out = subprocess.run([str(tool), "-u", str(capture)], capture_output=True, text=True, errors="replace", check=True).stdout
    by_thread: dict[str, list[Row]] = defaultdict(list)
    frames: dict[str, int] = defaultdict(int)
    for row in csv.DictReader(out.splitlines()):
        try:
            entry = (int(row["ns_since_start"]), int(row["exec_time_ns"]), row["name"], row["src_file"], row["src_line"])
        except (KeyError, ValueError, TypeError):
            continue
        by_thread[row["thread"]].append(entry)
        if entry[2] == "Main::iteration":
            frames[row["thread"]] += 1
    if not frames:
        return [], 0
    thread = max(frames, key=lambda t: frames[t])
    return sorted(by_thread[thread], key=lambda r: (r[0], -r[1])), frames[thread]


def analyse(capture: Path, top: int) -> dict[str, object] | None:
    rows, frames = load(capture)
    if frames == 0:
        return None
    own = [r[1] for r in rows]
    inside = [False] * len(rows)
    child_of = [-1] * len(rows)  # the direct child of `process` a zone lies in
    stack: list[int] = []
    for i, row in enumerate(rows):
        while stack and rows[stack[-1]][0] + rows[stack[-1]][1] <= row[0]:
            stack.pop()
        if stack:
            parent = stack[-1]
            own[parent] -= row[1]
            inside[i] = inside[parent] or is_process(rows[parent])
            child_of[i] = i if is_process(rows[parent]) else child_of[parent]
        stack.append(i)
    ms = 1.0 / frames / 1e6
    process_total = sum(r[1] for r in rows if is_process(r)) * ms
    process_own = sum(own[i] for i, r in enumerate(rows) if is_process(r)) * ms
    groups: dict[str, float] = defaultdict(float)
    own_by: dict[tuple[str, str], list[float]] = defaultdict(lambda: [0.0, 0])
    total_by: dict[tuple[str, str], float] = defaultdict(float)
    children: dict[tuple[str, str], list[float]] = defaultdict(lambda: [0.0, 0])
    for i, row in enumerate(rows):
        if not inside[i]:
            continue
        key = (row[2], short(row[3]) + ":" + row[4])
        groups[group(row[3])] += own[i] * ms
        own_by[key][0] += own[i] * ms
        own_by[key][1] += 1
        total_by[key] += row[1] * ms
        if child_of[i] == i:
            children[key][0] += row[1] * ms
            children[key][1] += 1
    return {"frames": frames, "frame": sum(r[1] for r in rows if r[2] == "Main::iteration") * ms, "total": process_total,
            "own": process_own, "groups": groups, "own_by": own_by, "total_by": total_by, "children": children, "top": top}


def child(result: dict[str, object], script: str) -> float:
    """Total of the direct children of `process` from [script] (its nodes' _process)."""
    children: dict[tuple[str, str], list[float]] = result["children"]  # type: ignore[assignment]
    return sum(value[0] for (_name, source), value in children.items() if source.startswith(script + ":"))


def zone_total(result: dict[str, object], name: str, script: str) -> float:
    """A function's total: the larger of its two zones (the call and the function, D-160)."""
    totals: dict[tuple[str, str], float] = result["total_by"]  # type: ignore[assignment]
    return max((ms for (zone, source), ms in totals.items() if zone == name and source.startswith(script + ":")), default=0.0)


def print_step(result: dict[str, object]) -> None:
    total = float(result["total"])  # type: ignore[arg-type]
    top = int(result["top"])  # type: ignore[arg-type]
    print(f"Frames {result['frames']}, mean Main::iteration {float(result['frame']):.2f} ms; "
          f"`process` {total:.3f} ms, of it its own C++ {float(result['own']):.3f} ms.\n")
    print("| Inside `process`: own time by group | ms/frame | Share |\n|---|---|---|")
    print(f"| `process` own C++ (editor and engine nodes, no zones) | {float(result['own']):.3f} | {float(result['own']) / total:.0%} |")
    groups: dict[str, float] = result["groups"]  # type: ignore[assignment]
    for name, value in sorted(groups.items(), key=lambda kv: -kv[1]):
        print(f"| {name} | {value:.3f} | {value / total:.0%} |")
    print("\n| Direct child of `process` (total) | Source | ms/frame | Calls/frame |\n|---|---|---|---|")
    children: dict[tuple[str, str], list[float]] = result["children"]  # type: ignore[assignment]
    for (name, source), (value, calls) in sorted(children.items(), key=lambda kv: -kv[1][0])[:top]:
        print(f"| {name} | {source} | {value:.3f} | {calls / int(result['frames']):.1f} |")
    print("\n| Zone inside `process` (total, with what it calls) | Source | ms/frame |\n|---|---|---|")
    totals: dict[tuple[str, str], float] = result["total_by"]  # type: ignore[assignment]
    for (name, source), value in sorted(totals.items(), key=lambda kv: -kv[1])[:top]:
        print(f"| {name} | {source} | {value:.3f} |")
    print("\n| Zone inside `process` (own) | Source | ms/frame | Calls/frame |\n|---|---|---|---|")
    owns: dict[tuple[str, str], list[float]] = result["own_by"]  # type: ignore[assignment]
    for (name, source), (value, calls) in sorted(owns.items(), key=lambda kv: -kv[1][0])[:top]:
        print(f"| {name} | {source} | {value:.3f} | {calls / int(result['frames']):.1f} |")


def summary_row(step: str, result: dict[str, object]) -> str:
    total = float(result["total"])  # type: ignore[arg-type]
    graph = child(result, "logic_graph/blueprints.gd")
    routing = zone_total(result, "_takes_pointer", "logic_graph/blueprints.gd")
    panels = child(result, "ui/panels.gd")
    manipulator = child(result, "tools/manipulator.gd")
    simulator = child(result, "xr/simulator.gd")
    lab = child(result, "telemetry/graph_lab.gd")
    own = float(result["own"])  # type: ignore[arg-type]
    rest = total - graph - panels - manipulator - simulator - lab - own
    cells = (total, graph, routing, panels - routing, manipulator, own, simulator, lab, rest)
    return f"| {step} | " + " | ".join(f"{value:.3f}" for value in cells) + " |"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("stem")
    parser.add_argument("--top", type=int, default=30)
    parser.add_argument("--steps", default="", help="only these steps, comma-separated")
    parser.add_argument("--summary", action="store_true")
    options = parser.parse_args()
    stem = Path(options.stem)
    captures = sorted((c for c in stem.parent.glob(stem.name + "_tracy_*.tracy") if CAPTURE.search(c.name)),
                      key=lambda c: int(CAPTURE.search(c.name).group(1)))  # type: ignore[union-attr]
    if not captures:
        sys.exit(f"tracy_process: no captures {stem}_tracy_*.tracy")
    wanted = [s for s in options.steps.split(",") if s]
    rows: list[str] = []
    for capture in captures:
        match = CAPTURE.search(capture.name)
        assert match is not None
        step = f"{match.group(1)} {match.group(2)}"
        if wanted and match.group(2) not in wanted:
            continue
        result = analyse(capture, options.top)
        if result is None:
            print(f"\n### {step}\n\nNo Main::iteration zones.")
            continue
        if options.summary:
            rows.append(summary_row(step, result))
        else:
            print(f"\n### {step}\n")
            print_step(result)
    if options.summary:
        print("| Step | `process` | Graph scripts (`blueprints.gd` _process) | Ray routing from the panels (`_takes_pointer`) "
              "| Panels without the routing | Manipulator | `process` own C++ | Simulator | Lab | Other scripts |")
        print("|---|---|---|---|---|---|---|---|---|---|")
        print("\n".join(rows))


if __name__ == "__main__":
    main()
