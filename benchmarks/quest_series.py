#!/usr/bin/env python3
"""A series of graph lab runs on a standalone headset, one after another, and one table of their logs.

  run    Runs every line of a series file through scripts/quest.py --unattended, for runs Claude drives (D-161):
         the project goes to the headset once, before the first run, and every run starts with --no-deploy, so
         the whole series measures one copy of the code whatever happens to the working copy meanwhile. A run
         without "graph lab: done" in its log is run again, alone (--retries, default 1). Each run's log is the
         one quest.py names in its output, never "the newest file"; its trimmed copy (benchmarks/trim_lab_log.py)
         and quest.py's output go to the series' folder, with series.md: the commit, each run's arguments, log,
         attempts and result, and whether the working copy changed while the series ran. Ends with the table.
  table  The steps of several logs side by side: one table a number (fps, App GPU and draw calls on a headset;
         fps, the VR view's GPU time, process and draw calls for logs of this PC), a row a step, a column a log.
         Reads what benchmarks/quest_lab_steps.py reads; a step a log repeats gets its number, as open (2).

A series file: a run a line, "<name>: <arguments of scripts/quest.py>"; # starts a comment. For example
  default: --scene res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress
  merged:  --scene res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress --xre-lab-feature=graph_drawing=card_merged

Usage: py benchmarks/quest_series.py run <series file> [--out FOLDER] [--only a,b] [--retries N] [--no-deploy] [--dry-run]
       py benchmarks/quest_series.py table <log or series folder> [more] [--steps a,b]
  --out      the series' folder (default benchmarks/results/raw_<date>_<series file's name>)
  --only     these runs of the file only: the runs that went wrong, without the rest
  --dry-run  the commands and series.md without a headset
Standard library only.
"""

from __future__ import annotations

import argparse
import hashlib
import re
import shlex
import subprocess
import sys
import time
from pathlib import Path

import quest_lab_steps
import trim_lab_log

REPO = Path(__file__).resolve().parent.parent
QUEST = REPO / "scripts" / "quest.py"
# quest.py's line that names the run's log.
LOG_LINE = re.compile(r"^quest: log (logs/quest_[\w.-]+\.log)")
NAME = re.compile(r"^[a-z0-9_]+$")
HEADSET_FIELDS = (("fps", "fps", "{:.0f}"), ("App GPU, ms", "app", "{:.2f}"), ("Draw calls", "calls", "{:.0f}"))
PC_FIELDS = (("fps", "fps", "{:.0f}"), ("VR view GPU, ms", "view_gpu", "{:.2f}"), ("process, ms", "process", "{:.2f}"),
             ("Draw calls", "calls", "{:.0f}"))


def read_series(path: Path) -> list[tuple[str, list[str]]]:
    runs: list[tuple[str, list[str]]] = []
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        name, colon, rest = line.partition(":")
        name = name.strip()
        if not colon or not NAME.match(name):
            sys.exit(f"quest_series: {path}:{number}: a run is '<name>: <arguments of quest.py>', the name of [a-z0-9_]")
        if name in (run[0] for run in runs):
            sys.exit(f"quest_series: {path}:{number}: a second run named {name}")
        args = [arg for arg in shlex.split(rest) if arg not in ("--unattended", "--no-deploy")]
        for refused in ("--no-log", "--no-open"):
            if refused in args:
                sys.exit(f"quest_series: {path}:{number}: {refused} leaves no log of a run")
        runs.append((name, args))
    if not runs:
        sys.exit(f"quest_series: no runs in {path}")
    return runs


def git(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=REPO, capture_output=True, text=True, errors="replace").stdout


def working_copy() -> tuple[str, str]:
    """The commit, with +changes if tracked files differ from it, and a print of the whole state."""
    commit = git("rev-parse", "--short", "HEAD").strip()
    status = git("status", "--porcelain", "--untracked-files=no")
    state = hashlib.sha1((commit + status + git("diff", "HEAD")).encode("utf-8", errors="replace")).hexdigest()
    return commit + ("+changes" if status.strip() else ""), state


def run_quest(args: list[str], output: Path) -> tuple[int, str]:
    """Runs quest.py with [args], shows and keeps its output; its exit code and the log it named."""
    log = ""
    with output.open("w", encoding="utf-8", newline="\n") as kept:
        process = subprocess.Popen([sys.executable, str(QUEST), *args], cwd=REPO, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT, text=True, errors="replace")
        assert process.stdout is not None
        try:
            for line in process.stdout:
                kept.write(line)
                print(line, end="")
                if found := LOG_LINE.match(line):
                    log = found.group(1)
        except KeyboardInterrupt:
            # quest.py gets the same Ctrl+C and sets the headset back before it ends.
            process.wait()
            raise
        return process.wait(), log


def lab_done(log: Path) -> bool:
    with log.open(encoding="utf-8", errors="replace") as file:
        return any("graph lab: done" in line for line in file)


def write_manifest(path: Path, series: Path, started: str, commit: str, rows: list[dict[str, str]], notes: list[str]) -> None:
    lines = [f"# Series {series.name}", "", f"Started {started}, commit `{commit}`.", ""]
    lines += [f"- {note}" for note in notes] + ([""] if notes else [])
    lines += ["| Run | Result | Attempts | Log | Arguments of quest.py |", "|---|---|---|---|---|"]
    lines += [f"| {row['name']} | {row['result']} | {row['attempts']} | {row['log']} | `{row['args']}` |" for row in rows]
    path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def run(options: argparse.Namespace) -> int:
    series = Path(options.series)
    every = read_series(series)
    runs = every
    if options.only:
        wanted = options.only.split(",")
        unknown = [name for name in wanted if name not in (run[0] for run in every)]
        if unknown:
            sys.exit(f"quest_series: no run {', '.join(unknown)} in {series}")
        runs = [run for run in every if run[0] in wanted]
    folder = Path(options.out) if options.out else REPO / "benchmarks" / "results" / f"raw_{time.strftime('%Y-%m-%d')}_{series.stem}"
    folder.mkdir(parents=True, exist_ok=True)
    started = time.strftime("%Y-%m-%d %H:%M")
    # A later start for some of the runs (--only) keeps the first start's record beside its own.
    manifest = folder / "series.md"
    if manifest.exists():
        manifest = folder / f"series_{time.strftime('%Y-%m-%dT%H-%M-%S')}.md"
    commit, state = working_copy()
    notes: list[str] = []
    rows: list[dict[str, str]] = []
    if "+changes" in commit:
        notes.append("The working copy had changes that aren't in the commit when the series started.")
    if options.dry_run:
        notes.append("Dry run: nothing was started.")
    if not options.no_deploy:
        print(f"quest_series: copying the project to the headset ({commit})")
        if not options.dry_run and subprocess.run([sys.executable, str(QUEST), "--no-open", "--no-log"], cwd=REPO).returncode != 0:
            sys.exit("quest_series: the project didn't reach the headset; nothing was run")
        notes.append("The project went to the headset once, before the first run; every run started with --no-deploy.")
    else:
        notes.append("Started with --no-deploy: the headset had the copy of an earlier start, not necessarily this commit.")
    failed = 0
    try:
        for name, args in runs:
            command = ["--unattended", "--no-deploy", *args]
            row = {"name": name, "result": "not run", "attempts": "0", "log": "", "args": " ".join(command)}
            rows.append(row)
            for attempt in range(1, options.retries + 2):
                print(f"\nquest_series: {name}, attempt {attempt}: py scripts/quest.py {row['args']}")
                row["attempts"] = str(attempt)
                if options.dry_run:
                    row["result"] = "dry run"
                    break
                if working_copy()[1] != state and not any("changed while" in note for note in notes):
                    notes.append(f"The working copy changed while the series ran (seen before {name}); "
                                 "the headset kept the copy of the series' start.")
                code, log = run_quest(command, folder / f"{name}.quest.txt")
                row["log"] = log
                if code == 0 and log and lab_done(REPO / log):
                    kept = trim_lab_log.trim(REPO / log, folder / f"{name}.log")
                    row["result"] = "ok"
                    print(f"quest_series: {name}: ok, {kept} line(s) in {(folder / (name + '.log')).as_posix()}")
                    break
                row["result"] = f"failed (quest.py's exit code {code})"
                print(f"quest_series: {name}: the lab didn't finish (exit code {code}, log {log or 'none'})")
            failed += row["result"] not in ("ok", "dry run")
            write_manifest(manifest, series, started, commit, rows, notes)
    except KeyboardInterrupt:
        notes.append("Stopped with Ctrl+C.")
        write_manifest(manifest, series, started, commit, rows, notes)
        return 130
    print(f"\nquest_series: {manifest.as_posix()}; {len(rows) - failed} of {len(rows)} run(s) done")
    # Every run of the file that has a log in the folder, in the file's order: with --only, the earlier ones too.
    done = [folder / f"{name}.log" for name, _ in every if (folder / f"{name}.log").is_file()]
    if done and not options.dry_run:
        print_table(done, [])
    return 1 if failed else 0


def numbered(steps: list[dict[str, object]]) -> dict[str, dict[str, object]]:
    """Steps by name; a name the log repeats gets its number: open, open (2)."""
    seen: dict[str, int] = {}
    out: dict[str, dict[str, object]] = {}
    for step in steps:
        name = str(step["step"])
        seen[name] = seen.get(name, 0) + 1
        out[name if seen[name] == 1 else f"{name} ({seen[name]})"] = step
    return out


def print_table(logs: list[Path], wanted: list[str]) -> None:
    columns = [(log.stem, numbered(quest_lab_steps.read_steps(str(log)))) for log in logs]
    # The rows follow the log with the most steps; what only another log has comes after them.
    order: list[str] = []
    for _, steps in sorted(columns, key=lambda column: -len(column[1])):
        order += [name for name in steps if name not in order]
    if wanted:
        order = [name for name in order if name.split(" (")[0] in wanted]
    if not order:
        print("no steps")
        return
    pc = all(step.get("pc") for _, steps in columns for step in steps.values())
    for title, field, form in (PC_FIELDS if pc else HEADSET_FIELDS):
        print(f"\n{title}\n\n| Step | " + " | ".join(name for name, _ in columns) + " |\n|---|" + "---|" * len(columns))
        for name in order:
            cells = [form.format(float(steps[name][field])) if name in steps and field in steps[name] else "-"  # type: ignore[arg-type]
                     for _, steps in columns]
            print(f"| {name} | " + " | ".join(cells) + " |")


def table(options: argparse.Namespace) -> int:
    logs: list[Path] = []
    for item in map(Path, options.logs):
        found = sorted(item.glob("*.log")) if item.is_dir() else [item]
        if not found or not all(log.is_file() for log in found):
            sys.exit(f"quest_series: no log in {item}")
        logs += found
    print_table(logs, [step for step in options.steps.split(",") if step])
    return 0


def main() -> int:
    # The headset's log has characters a Windows console can't show.
    sys.stdout.reconfigure(line_buffering=True, errors="replace")
    parser = argparse.ArgumentParser(description="A series of graph lab runs on a headset, and one table of their logs.")
    commands = parser.add_subparsers(dest="command", required=True)
    runner = commands.add_parser("run", help="run a series file's runs through quest.py --unattended")
    runner.add_argument("series")
    runner.add_argument("--out", help="the series' folder (default benchmarks/results/raw_<date>_<series file's name>)")
    runner.add_argument("--only", default="", metavar="NAMES", help="these runs only, comma separated")
    runner.add_argument("--retries", type=int, default=1, help="more attempts at a run whose lab didn't finish (default 1)")
    runner.add_argument("--no-deploy", action="store_true", help="don't copy the project first: the headset keeps the copy it has")
    runner.add_argument("--dry-run", action="store_true", help="the commands and series.md without a headset")
    tables = commands.add_parser("table", help="the steps of several logs side by side")
    tables.add_argument("logs", nargs="+", help="logs, or a series' folder")
    tables.add_argument("--steps", default="", help="only these steps, comma separated")
    options = parser.parse_args()
    return run(options) if options.command == "run" else table(options)


if __name__ == "__main__":
    sys.exit(main())
