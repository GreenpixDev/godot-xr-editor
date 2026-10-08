#!/usr/bin/env python3
"""Frame rate on a standalone headset across play mode (docs/decisions.md, D-018):
the editor in VR before the game, the game, and the editor after it.

On a standalone headset the editor and the game are separate processes of the
Godot app, one after the other (the game replaces the editor's process and back).
Both are measured the same way, by the Meta runtime itself: once a second it
logs for the application in focus (logcat tag VrApi) the frames the application
delivered (FPS=delivered/display rate), the frames the compositor had to show
again (Stale), the application's GPU time per frame (App, ms) and GPU and CPU
utilization (GPU%, CPU%). The editor's own status line (XRESession, every 5 s)
adds its main loop rate and late frames.

Reads a log written by scripts/quest.py (logs/quest_<time>.log), finds the
Godot processes in the headset's XR activity — the editor (started with
project.godot) or a game (started with --scene) — and summarizes each one from
WARMUP_SEC after its session reached FOCUSED until it lost focus for good or
ended. Prints a Markdown summary, and writes it with the per-second rows next
to the other benchmark results:
benchmarks/results/quest_fps_<log time>.csv and _report.md.

Protocol (2026-10-07): py scripts/quest.py --scene res://benchmarks/play_check.tscn,
then in the headset stand still about 60 s in the editor, press Y, about 60 s in
the game, hold Y, about 60 s in the editor again.

Usage: py benchmarks/quest_fps_report.py logs/quest_<time>.log
Standard library only.
"""

from __future__ import annotations

import csv
import re
import statistics
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

PACKAGE = "org.godotengine.editor.v4.meta"
# Seconds after the session reached FOCUSED that are left out: the editor
# finishes loading, the game its scene.
WARMUP_SEC = 10.0
RESULTS = Path(__file__).resolve().parent / "results"

LINE = re.compile(r"^(\d\d-\d\d) (\d\d:\d\d:\d\d\.\d+)\s+(\d+)\s+\d+\s+\w\s+(\S+?)\s*: (.*)$")
START = re.compile(r"Start proc (\d+):" + re.escape(PACKAGE) + r":GodotXRGame/")
LAUNCH = re.compile(r"Launch intent .* with parameters \[(.*)\]")
STATE = re.compile(r"PostSessionStateChange:\[pid: (\d+)\] XR_SESSION_STATE_(\w+) -> XR_SESSION_STATE_(\w+)")
VRAPI_FIELD = re.compile(r"([A-Za-z0-9%&/]+)=([^,]+)")
STATUS = re.compile(r"XR Editor: (\d+) fps, (\d+) frame\(s\) late, slowest ([\d.]+) ms, session (\w+)")
MEMORY = re.compile(r"App memory usage: PSS=(\d+) MiB")


@dataclass
class Second:
    time: float
    delivered: int
    display_hz: int
    stale: int
    app_gpu_ms: float | None
    gpu_util: float | None
    cpu_util: float | None
    gpu_level: str
    temperature: str


@dataclass
class Process:
    pid: str
    kind: str = "?"
    detail: str = ""
    focused_at: float | None = None
    unfocused_at: float | None = None
    seconds: list[Second] = field(default_factory=list)
    statuses: list[tuple[float, int, int, float]] = field(default_factory=list)
    memory_mib: list[int] = field(default_factory=list)

    def name(self) -> str:
        return f"{self.kind} {self.detail}".strip()


def seconds_of_day(clock: str) -> float:
    moment = datetime.strptime(clock, "%H:%M:%S.%f")
    return moment.hour * 3600 + moment.minute * 60 + moment.second + moment.microsecond / 1e6


def number(text: str | None) -> float | None:
    if text is None:
        return None
    match = re.match(r"-?[\d.]+", text)
    return float(match.group()) if match else None


def read(log: Path) -> list[Process]:
    processes: dict[str, Process] = {}
    order: list[str] = []
    for raw in log.read_bytes().decode("utf-8", errors="replace").splitlines():
        match = LINE.match(raw)
        if not match:
            continue
        _, clock, pid, tag, message = match.groups()
        now = seconds_of_day(clock)
        started = START.search(message)
        if started:
            processes[started.group(1)] = Process(started.group(1))
            order.append(started.group(1))
            continue
        process = processes.get(pid)
        state = STATE.search(message)
        if state and state.group(1) in processes:
            process = processes[state.group(1)]
            if state.group(3) == "FOCUSED" and process.focused_at is None:
                process.focused_at = now
            elif state.group(2) == "FOCUSED" and process.focused_at is not None:
                process.unfocused_at = now
            continue
        if process is None:
            continue
        launch = LAUNCH.search(message)
        if launch:
            args = [arg.strip() for arg in launch.group(1).split(",")]
            if "--scene" in args:
                process.kind, process.detail = "game", args[args.index("--scene") + 1]
            elif any(arg.endswith("project.godot") for arg in args):
                process.kind = "editor"
        elif tag == "VrApi" and message.startswith("FPS="):
            fields = dict(VRAPI_FIELD.findall(message))
            delivered, display = fields["FPS"].split("/")
            levels = fields.get("CPU4/GPU", "?/?").split("/")
            process.seconds.append(Second(
                now, int(delivered), int(display), int(fields.get("Stale", "0")),
                number(fields.get("App")), number(fields.get("GPU%")), number(fields.get("CPU%")),
                levels[1] if len(levels) > 1 else "?", fields.get("Temp", "?").split("/")[0]))
        elif tag == "godot" and (status := STATUS.search(message)):
            process.statuses.append((now, int(status.group(1)), int(status.group(2)), float(status.group(3))))
        elif (memory := MEMORY.search(message)):
            process.memory_mib.append(int(memory.group(1)))
    return [processes[pid] for pid in order if processes[pid].kind != "?"]


def window(process: Process) -> tuple[float, float] | None:
    if process.focused_at is None or not process.seconds:
        return None
    end = process.unfocused_at if process.unfocused_at and process.unfocused_at > process.focused_at \
        else process.seconds[-1].time
    return process.focused_at + WARMUP_SEC, end


def summarize(process: Process) -> dict[str, str]:
    span = window(process)
    if span is None:
        return {"process": process.name(), "seconds": "0"}
    rows = [s for s in process.seconds if span[0] <= s.time <= span[1]]
    statuses = [s for s in process.statuses if span[0] <= s[0] <= span[1]]
    if not rows:
        return {"process": process.name(), "seconds": "0"}
    full = sum(1 for s in rows if s.delivered >= s.display_hz - 1)
    apps = [s.app_gpu_ms for s in rows if s.app_gpu_ms is not None]
    gpus = [s.gpu_util for s in rows if s.gpu_util is not None]
    cpus = [s.cpu_util for s in rows if s.cpu_util is not None]
    summary = {
        "process": process.name(),
        "seconds": str(len(rows)),
        "display": f"{statistics.mode(s.display_hz for s in rows)} Hz",
        "fps mean": f"{statistics.fmean(s.delivered for s in rows):.1f}",
        "fps min": str(min(s.delivered for s in rows)),
        "full-rate seconds": f"{100 * full / len(rows):.0f} %",
        "stale frames": str(sum(s.stale for s in rows)),
        "app GPU ms": f"{statistics.fmean(apps):.2f}" if apps else "—",
        "GPU %": f"{100 * statistics.fmean(gpus):.0f}" if gpus else "—",
        "CPU %": f"{100 * statistics.fmean(cpus):.0f}" if cpus else "—",
        "GPU level": statistics.mode(s.gpu_level for s in rows),
        "memory PSS": f"{max(process.memory_mib)} MiB" if process.memory_mib else "—",
    }
    if statuses:
        summary["editor loop fps"] = f"{statistics.fmean(s[1] for s in statuses):.1f}"
        summary["editor late frames / 5 s"] = f"{statistics.fmean(s[2] for s in statuses):.1f}"
    return summary


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__.strip().splitlines()[-2], file=sys.stderr)
        return 2
    log = Path(sys.argv[1])
    processes = read(log)
    if not processes:
        print(f"quest_fps_report: no editor or game of {PACKAGE} in {log}", file=sys.stderr)
        return 1
    stamp = log.stem.removeprefix("quest_")
    summaries = [summarize(process) for process in processes]
    columns = list(dict.fromkeys(key for summary in summaries for key in summary))
    lines = [
        f"# Frame rate on the standalone headset, {stamp}",
        "",
        f"Source: `{log.as_posix()}` (logcat via scripts/quest.py), Meta runtime counters (VrApi), "
        f"from {WARMUP_SEC:.0f} s after each session reached FOCUSED until it lost focus or ended.",
        "",
        "| " + " | ".join(columns) + " |",
        "|" + "---|" * len(columns),
    ]
    lines += ["| " + " | ".join(summary.get(column, "") for column in columns) + " |" for summary in summaries]
    report = "\n".join(lines) + "\n"
    print(report)

    RESULTS.mkdir(exist_ok=True)
    (RESULTS / f"quest_fps_{stamp}_report.md").write_text(report, encoding="utf-8", newline="\n")
    with open(RESULTS / f"quest_fps_{stamp}.csv", "w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file, lineterminator="\n")
        writer.writerow(["process", "pid", "time_s", "in_window", "delivered_fps", "display_hz", "stale",
                         "app_gpu_ms", "gpu_util", "cpu_util", "gpu_level", "temperature"])
        for process in processes:
            span = window(process)
            for s in process.seconds:
                inside = span is not None and span[0] <= s.time <= span[1]
                writer.writerow([process.name(), process.pid, f"{s.time:.3f}", int(inside), s.delivered,
                                 s.display_hz, s.stale, s.app_gpu_ms if s.app_gpu_ms is not None else "",
                                 s.gpu_util if s.gpu_util is not None else "",
                                 s.cpu_util if s.cpu_util is not None else "", s.gpu_level, s.temperature])
    print(f"quest_fps_report: wrote benchmarks/results/quest_fps_{stamp}.csv and _report.md")
    return 0


if __name__ == "__main__":
    sys.exit(main())
