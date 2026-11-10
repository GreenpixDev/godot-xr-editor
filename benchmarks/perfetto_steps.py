"""Per-step tables of the engine's and GDScript's zones from Perfetto traces of a graph lab run on Quest
(scripts/quest.py --perfetto; docs/performance_plan.md step 1.6, D-160; docs/profiling_builds.md).

Usage: py benchmarks/perfetto_steps.py logs/quest_<time> [--top N] [--thread NAME] [--zone NAME ...]
  logs/quest_<time>   the run's stem: its traces are logs/quest_<time>_perfetto_<n>_<step>.pftrace

Reads every trace with Perfetto's trace processor (scripts/build_engine.py tools). Counts only slices of
the categories godot and godot_scripting on one thread: the one with the frame zone Main::iteration (on
Android the engine's render thread, not the app's main thread) unless --thread names another. Times are per frame: divided by the number of Main::iteration slices in the trace.
Prints, for each step: a warning if the trace lost data (the tracing service's loss counters: a buffer
filled), and how many slices had no end and were left out; frames and the mean frame (Main::iteration); the top zones by own time
(the slice without its children); and the own time of all GDScript zones summed by script file.
--zone lists those zones' total time per frame across the steps, one column each.
"""
from __future__ import annotations

import argparse
import csv
import io
import re
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import build_engine  # noqa: E402

TRACE = re.compile(r"_perfetto_(\d+)_([a-z_0-9]+)\.pftrace$")
FRAME_ZONE = "Main::iteration"

QUERY = """
with s as (
  select slice.id, slice.name, slice.category, slice.dur, thread.name as thread, thread.is_main_thread as main,
    coalesce(extract_arg(slice.arg_set_id, 'debug.source file'), extract_arg(slice.arg_set_id, 'args.source file'), '') as file
  from slice join thread_track on slice.track_id = thread_track.id join thread using (utid)
  where slice.category in ('godot', 'godot_scripting') and slice.dur >= 0
),
c as (select parent_id, sum(dur) as child from slice where parent_id is not null group by parent_id)
select s.name, s.file, s.category, s.thread, coalesce(s.main, 0) as main, count(*) as calls,
  sum(s.dur) as total_ns, sum(s.dur - coalesce(c.child, 0)) as self_ns
from s left join c on c.parent_id = s.id
group by s.name, s.file, s.category, s.thread, s.main
order by self_ns desc;
"""


# What a trace lost: slices without an end (dur -1: the frame running when the trace stopped, or
# events dropped when a buffer filled) and the service's own loss counters, which make sums unreliable.
# traced_chunks_discarded is left out: it counts over the service's whole life, not this trace's.
LOSSES = """
select 'unfinished engine slices' as name, count(*) as value from slice
  where category in ('godot', 'godot_scripting') and dur < 0
union all
select name, sum(value) as value from stats
  where value > 0 and (name like 'traced_buf_%discarded%' or name like 'traced_buf_%overwritten%'
    or name like 'traced_buf_patches_failed' or name like 'ftrace_cpu_overrun%' or name like '%data_loss%'
    or name like 'traced_buf_trace_writer_packet_loss')
  group by name;
"""


def query(trace: Path, text: str = QUERY) -> list[dict[str, str]]:
    shell = build_engine.PERFETTO_TOOLS / "trace_processor_shell.exe"
    if not shell.is_file():
        sys.exit(f"perfetto_steps: {shell} isn't there; run py scripts/build_engine.py tools")
    sql = trace.with_suffix(".sql.tmp")
    sql.write_text(text, encoding="utf-8")
    try:
        result = subprocess.run([str(shell), "-q", str(sql), str(trace)], capture_output=True, text=True, errors="replace")
    finally:
        sql.unlink(missing_ok=True)
    if result.returncode != 0:
        sys.exit(f"perfetto_steps: trace processor failed on {trace.name}: {result.stderr.strip()[-400:]}")
    # The shell prints the result of the last statement as CSV with a header line.
    lines = [line for line in result.stdout.splitlines() if line.strip()]
    start = next((i for i, line in enumerate(lines) if line.startswith('"name"') or line.startswith("name")), None)
    if start is None:
        return []
    return list(csv.DictReader(io.StringIO("\n".join(lines[start:]))))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("stem")
    parser.add_argument("--top", type=int, default=25)
    parser.add_argument("--thread", help="thread name to count (default: the main thread)")
    parser.add_argument("--zone", action="append", default=[], help="a zone to compare across the steps; repeatable")
    options = parser.parse_args()
    stem = Path(options.stem)
    traces = sorted((p for p in stem.parent.glob(stem.name + "_perfetto_*.pftrace") if TRACE.search(p.name)),
                    key=lambda p: int(TRACE.search(p.name).group(1)))
    if not traces:
        sys.exit(f"perfetto_steps: no {stem.name}_perfetto_<n>_<step>.pftrace in {stem.parent}")
    compared: list[tuple[str, dict[str, float]]] = []
    for trace in traces:
        number, step = TRACE.search(trace.name).groups()
        rows = query(trace)
        counted = [r for r in query(trace, LOSSES) if r["value"] not in ("", "0", "0.0")]
        losses = [f"{r['name']} {r['value']}" for r in counted if r["name"] != "unfinished engine slices"]
        unfinished = next((r["value"] for r in counted if r["name"] == "unfinished engine slices"), "0")
        # On Android the engine's loop runs on its render thread, not the app's main thread:
        # by default the thread with the frame zone.
        thread = options.thread or max((r for r in rows if r["name"] == FRAME_ZONE), key=lambda r: int(r["calls"]),
                                       default={"thread": None})["thread"]
        rows = [r for r in rows if r["thread"] == thread]
        frames = sum(int(r["calls"]) for r in rows if r["name"] == FRAME_ZONE)
        print(f"\n### {number} {step}\n")
        if losses:
            print(f"**The trace lost data, its sums are unreliable:** {'; '.join(losses)}.\n")
        # The frame running when the trace stopped leaves a few (one per nesting level); many more
        # mean events were dropped mid-trace.
        print(f"Slices without an end, left out: {unfinished}.")
        if frames == 0:
            print(f"No whole {FRAME_ZONE} slice: the trace fell inside one long frame (a graph being built), "
                  "or no engine zones reached it (see _perfetto_info.txt).")
            continue
        frame_ms = sum(int(r["total_ns"]) for r in rows if r["name"] == FRAME_ZONE) / frames / 1e6
        print(f"Thread {thread}: frames {frames}, mean {FRAME_ZONE} {frame_ms:.2f} ms.\n")
        print("| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |")
        print("|---|---|---|---|---|")
        for r in rows[:options.top]:
            print("| %s | %s | %.3f | %.3f | %.1f |" % (r["name"].replace("|", "\\|"), r["file"] or r["category"],
                  int(r["self_ns"]) / frames / 1e6, int(r["total_ns"]) / frames / 1e6, int(r["calls"]) / frames))
        scripts: dict[str, float] = {}
        for r in rows:
            if r["category"] == "godot_scripting":
                file = r["file"] or "(no source file)"
                scripts[file] = scripts.get(file, 0.0) + int(r["self_ns"]) / frames / 1e6
        if scripts:
            print("\n| GDScript (own time, summed) | ms/frame |\n|---|---|")
            for file, ms in sorted(scripts.items(), key=lambda item: -item[1])[:options.top]:
                print(f"| {file} | {ms:.3f} |")
        compared.append((step, {z: sum(int(r["total_ns"]) for r in rows if r["name"] == z) / frames / 1e6
                                for z in options.zone}))
    if options.zone and compared:
        print("\n| Step | " + " | ".join(options.zone) + " |\n|---|" + "---|" * len(options.zone))
        for step, values in compared:
            print(f"| {step} | " + " | ".join(f"{values[z]:.3f}" for z in options.zone) + " |")


main()
