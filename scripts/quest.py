#!/usr/bin/env python3
"""Runs this project's editor on a standalone headset (Quest, Horizon OS) from
this PC, over USB with adb (docs/decisions.md, D-018).

1. Copies the project to the headset, /sdcard/Documents/Godot/<folder>: what git
   tracks plus untracked files git doesn't ignore, minus what only the PC needs
   (C++ sources, docs, spikes, study, scripts, benchmark results), plus the
   plugin's Android library (scripts/build_gdextension.sh android). Only files
   that changed go over (adb push --sync); files deleted here stay there.
   The copy goes one way: changes made in the headset (scenes saved in VR)
   don't come back. A file newer in the headset than here is left alone and
   listed: adb push --sync alone would overwrite it, as it copies any file
   whose time differs.
2. Closes the Godot editor in the headset, without saving, and opens the project
   in its 2D panel, with a request (.godot/xr_editor_open_vr) that the plugin
   answers by opening the editor in VR once the panel has scanned the project
   (XREStandaloneLauncher): on --scene if given, with the --engine arguments
   for its engine and the arguments after -- for the plugin in VR.
3. With --gpu-profile (D-157, steps 1.2 and 1.4): before the editor starts, puts the
   Meta runtime's detailed GPU profiling mode on for the package (ovrgpuprofiler -e),
   which adds about 10 % to the GPU's time; every graph lab step then gets a render
   stage trace (ovrgpuprofiler -t, its output in logs/quest_<time>_gpu_<n>_<step>.txt) a few seconds
   into it, and at the end the mode goes off again (-d). The metrics' lists, the mode's
   state and whether the package is debuggable (per-draw -x needs that) go in
   logs/quest_<time>_gpu_info.txt.
4. Shows the editor's output (logcat, tag godot) and keeps the whole logcat in
   logs/quest_<time>.log, until Ctrl+C. The engine's error that repeats every
   frame in the editor (sync_action_sets, D-004) stays out of the console.

Usage: py scripts/quest.py [--scene res://...] [--engine=ARG ...] [--no-deploy] [--no-open] [--no-log] [--gpu-profile [--gpu-trace-delay S] [--gpu-trace-sec S] [--gpu-trace-args "-v"]] [-- arguments for the plugin in VR]
  py scripts/quest.py
  py scripts/quest.py --scene res://benchmarks/play_check.tscn
  py scripts/quest.py --engine=--benchmark   (the editor's startup phases, in the log)
  py scripts/quest.py -- --xre-benchmark
  py scripts/quest.py --gpu-profile --scene res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-base
Needs the Godot editor from the Horizon Store in the headset (4.7.x), USB
debugging allowed, and adb: ADB, adb on PATH, the Android SDK's, or SideQuest's.
Standard library only.
"""

from __future__ import annotations

import argparse
import atexit
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import threading
import time
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
PACKAGE = "org.godotengine.editor.v4.meta"
PROJECT_MANAGER = f"{PACKAGE}/org.godotengine.editor.ProjectManager"
REMOTE_PARENT = "/sdcard/Documents/Godot"
REMOTE = f"{REMOTE_PARENT}/{REPO.name}"
# The same folder as the editor in the headset sees it.
REMOTE_PROJECT_FILE = f"file:///storage/emulated/0/Documents/Godot/{REPO.name}/project.godot"
ANDROID_LIBRARY = "addons/xr_editor/bin/xre_native.android.template_debug.arm64.so"
# Read and deleted by XREStandaloneLauncher.
OPEN_REQUEST = ".godot/xr_editor_open_vr"
# Only the PC needs these: folders, and native libraries of desktop platforms
# (add-ons ship one per platform; Godot leaves ~...TMP copies of loaded DLLs).
SKIPPED = ("gdextension/", "docs/", "spikes/", "study/", "scripts/", ".run/", "benchmarks/results/")
DESKTOP_NATIVE = (".dll", ".pdb", ".ilk", ".exp", ".lib", ".dylib", ".TMP")
STAGE = REPO / "build" / "quest" / REPO.name
# Console lines: Godot's output, and the editor's processes starting, dying and crashing.
SHOWN = re.compile(r" godot\s+: | Fatal signal |Start proc \d+:" + re.escape(PACKAGE) + "|Process " + re.escape(PACKAGE))
# The graph lab's line that starts a step (benchmarks/quest_lab_steps.py reads the same).
LAB_STEP = re.compile(r"XR Editor: graph lab: ([a-z_0-9]+)\s*$")
# Printed by the engine every frame in the editor (D-004).
NOISE = ('Condition "active_sets.is_empty()" is true', "at: sync_action_sets (")


def find_adb() -> str | None:
    candidates = [os.environ.get("ADB"), shutil.which("adb")]
    for sdk in (os.environ.get("ANDROID_HOME"), os.environ.get("ANDROID_SDK_ROOT"),
                os.path.join(os.environ.get("LOCALAPPDATA", ""), "Android", "Sdk")):
        if sdk:
            candidates.append(os.path.join(sdk, "platform-tools", "adb.exe"))
    candidates.append(os.path.join(os.environ.get("LOCALAPPDATA", ""), "Programs", "SideQuest",
                                   "resources", "platform-tools", "adb.exe"))
    return next((c for c in candidates if c and Path(c).is_file()), None)


class Adb:
    def __init__(self, path: str) -> None:
        self.path = path

    def run(self, *args: str, check: bool = True) -> str:
        """adb's output; push writes its summary to stderr when not on a console, so both."""
        result = subprocess.run([self.path, *args], capture_output=True, text=True, errors="replace")
        if check and result.returncode != 0:
            sys.exit(f"quest: adb {' '.join(args)} failed: {(result.stderr or result.stdout).strip()}")
        return result.stdout + result.stderr

    def shell(self, command: str) -> str:
        return self.run("shell", command)


def check_headset(adb: Adb) -> None:
    devices = [line.split("\t") for line in adb.run("devices").splitlines()[1:] if "\t" in line]
    if not devices and not os.environ.get("ANDROID_SERIAL"):
        sys.exit("quest: no headset; connect it by USB and allow USB debugging in it")
    if len(devices) > 1 and not os.environ.get("ANDROID_SERIAL"):
        sys.exit("quest: more than one device; pick one with ANDROID_SERIAL")
    if devices and devices[0][1] != "device":
        sys.exit(f"quest: the headset is {devices[0][1]}; allow USB debugging in it")
    version = ""
    for line in adb.shell(f"dumpsys package {PACKAGE}").splitlines():
        if line.strip().startswith("versionName="):
            version = line.strip().removeprefix("versionName=")
            break
    if not version:
        sys.exit(f"quest: the Godot editor ({PACKAGE}) isn't installed in the headset; get it from the Horizon Store")
    if not version.startswith("4.7."):
        print(f"quest: warning: the headset has Godot {version}; the project is pinned to 4.7.x")
    print(f"quest: headset ready, Godot {version}")


def project_files() -> list[str]:
    """Paths relative to the repository, with / separators."""
    listing = subprocess.run(["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"],
                             cwd=REPO, capture_output=True, check=True).stdout.decode("utf-8")
    files = [path for path in listing.split("\0") if path and not path.startswith(SKIPPED)
             and not path.endswith(DESKTOP_NATIVE) and ".framework/" not in path]
    return [path for path in files if (REPO / path).is_file()] + [ANDROID_LIBRARY]


def stage(files: list[str]) -> None:
    """Mirrors [files] into STAGE with hard links: no copying, and the times
    adb push --sync compares stay the originals'."""
    if STAGE.exists():
        shutil.rmtree(STAGE)
    for path in files:
        target = STAGE / path
        target.parent.mkdir(parents=True, exist_ok=True)
        try:
            os.link(REPO / path, target)
        except OSError:
            shutil.copy2(REPO / path, target)


def remote_times(adb: Adb) -> dict[str, int]:
    """Modification times, in seconds, of the project's files in the headset,
    by path relative to the project; .godot/ is left out."""
    listing = adb.shell(f"cd '{REMOTE}' 2>/dev/null && find . -path ./.godot -prune -o -type f -exec stat -c '%Y %n' {{}} +")
    times = {}
    for line in listing.splitlines():
        stamp, _, path = line.partition(" ")
        if stamp.isdigit() and path.startswith("./"):
            times[path[2:]] = int(stamp)
    return times


def deploy(adb: Adb) -> None:
    if not (REPO / ANDROID_LIBRARY).is_file():
        sys.exit("quest: the Android library is missing; run scripts/build_gdextension.sh android")
    files = project_files()
    remote = remote_times(adb)
    if not remote and "yes" in adb.shell(f"test -f '{REMOTE}/project.godot' && echo yes"):
        sys.exit("quest: couldn't list the project in the headset; not copying, so nothing changed there is overwritten")
    newer_there = [path for path in files if remote.get(path, 0) > int((REPO / path).stat().st_mtime)]
    for path in newer_there:
        print(f"quest: kept the headset's newer {path} (changed in the headset; it doesn't come back here)")
    files = [path for path in files if path not in newer_there]
    stage(files)
    print(f"quest: copying {len(files)} files to {REMOTE} (only those that changed)")
    adb.shell(f"mkdir -p '{REMOTE_PARENT}'")
    summary = adb.run("push", "--sync", str(STAGE), f"{REMOTE_PARENT}/").strip().splitlines()
    if summary:
        print(f"quest: {summary[-1]}")


def open_in_vr(adb: Adb, scene: str | None, engine_args: list[str], plugin_args: list[str]) -> None:
    print("quest: closing the Godot editor in the headset (unsaved changes there are lost)")
    adb.shell(f"am force-stop {PACKAGE}")
    # One item per line, as on Godot's command line: the scene (res://...) and
    # the engine's arguments, then after a -- line the plugin's.
    items = ([scene] if scene else []) + engine_args + (["--"] + plugin_args if plugin_args else [])
    with tempfile.NamedTemporaryFile("w", newline="\n", suffix=".txt", delete=False) as request:
        request.write("".join(f"{item}\n" for item in items))
    try:
        adb.shell(f"mkdir -p '{REMOTE}/.godot'")
        adb.run("push", request.name, f"{REMOTE}/{OPEN_REQUEST}")
    finally:
        os.unlink(request.name)
    adb.run("logcat", "-c")
    adb.shell(f"am start -a android.intent.action.VIEW -d '{REMOTE_PROJECT_FILE}' -n {PROJECT_MANAGER}")
    print("quest: opening the project in the headset; the editor in VR follows once the panel has loaded it")


class GpuProfiler:
    """Meta's ovrgpuprofiler (D-157, steps 1.2 and 1.4): detailed mode for the package, a render stage trace
    inside every graph lab step, files next to the log. The mode is on from before the editor starts until
    the end of the run; its instrumentation adds about 10 % to the GPU's time, so the VrApi lines of such a
    run are compared with each other, not with a run without it (docs/performance_plan.md)."""

    def __init__(self, adb: Adb, stem: Path, delay: float, seconds: float, trace_args: str) -> None:
        self.adb = adb
        self.stem = stem
        self.delay = delay
        self.seconds = seconds
        self.trace_args = shlex.split(trace_args)
        self.count = 0
        self.busy = threading.Lock()
        self.enabled = False

    def write(self, name: str, text: str) -> None:
        path = self.stem.with_name(f"{self.stem.name}_{name}.txt")
        path.write_text(text, encoding="utf-8")
        print(f"quest: gpu profiler: {path.relative_to(REPO).as_posix()}")

    def info(self) -> None:
        """Before the editor starts: what the tool and the package can do."""
        out = []
        for title, command in (("ovrgpuprofiler -i", "ovrgpuprofiler -i"), ("real-time metrics", "ovrgpuprofiler -m"),
                               ("render stage metrics", "ovrgpuprofiler -m -t"), ("per-draw metrics", "ovrgpuprofiler -x -m")):
            out.append(f"## {title}\n{self.adb.run('shell', command, check=False).strip()}\n")
        package = self.adb.shell(f"dumpsys package {PACKAGE}")
        flags = [line.strip() for line in package.splitlines() if "flags=" in line or "pkgFlags=" in line]
        out.append("## package flags (DEBUGGABLE is needed for per-draw metrics, -x)\n" + "\n".join(flags) + "\n")
        self.write("info", "\n".join(out))
        debuggable = any("DEBUGGABLE" in line for line in flags)
        print(f"quest: {PACKAGE} is {'' if debuggable else 'not '}debuggable" + ("" if debuggable else "; per-draw traces (-x) will fail"))

    def enable(self) -> None:
        print(self.adb.run("shell", f"ovrgpuprofiler -e {PACKAGE}", check=False).strip())
        self.enabled = True
        atexit.register(self.disable)
        print(f"quest: gpu profiler: detailed mode on for {PACKAGE}: the app starts in it, about 10 % more GPU time")

    def disable(self) -> None:
        if not self.enabled:
            return
        self.enabled = False
        self.adb.run("shell", "ovrgpuprofiler -d", check=False)
        print("quest: gpu profiler: detailed mode off (an app already running keeps it until it restarts)")

    def step_started(self, step: str) -> None:
        threading.Thread(target=self.trace, args=(step,), daemon=True).start()

    def trace(self, step: str) -> None:
        time.sleep(self.delay)
        if not self.busy.acquire(blocking=False):
            print(f"quest: gpu profiler: still tracing, no trace in {step}")
            return
        try:
            self.count += 1
            started = time.strftime("%H:%M:%S")
            command = f"ovrgpuprofiler -t{self.seconds:g} " + " ".join(shlex.quote(arg) for arg in self.trace_args)
            result = self.adb.run("shell", command, check=False)
            self.write(f"gpu_{self.count:02d}_{step}", f"# {command}\n# step {step}, started {started}, {self.delay:g} s after the step's line\n{result}")
        finally:
            self.busy.release()


def log_stem() -> Path:
    """The log's path without its extension: the profiler's files go beside it."""
    return REPO / "logs" / f"quest_{time.strftime('%Y-%m-%dT%H-%M-%S')}"


def follow_log(adb: Adb, stem: Path, profiler: GpuProfiler | None = None) -> int:
    logs = REPO / "logs"
    logs.mkdir(exist_ok=True)
    log = stem.with_suffix(".log")
    print(f"quest: log {log.relative_to(REPO).as_posix()}; Ctrl+C to stop")
    process = subprocess.Popen([adb.path, "logcat", "-v", "threadtime"], stdout=subprocess.PIPE)
    try:
        with open(log, "wb") as file:
            assert process.stdout is not None
            for raw in process.stdout:
                file.write(raw)
                line = raw.decode("utf-8", errors="replace").rstrip()
                if profiler is not None and (step := LAB_STEP.search(line)):
                    profiler.step_started(step.group(1))
                if SHOWN.search(line) and not any(noise in line for noise in NOISE):
                    print(line[6:] if len(line) > 6 else line)
    except KeyboardInterrupt:
        pass
    finally:
        process.terminate()
    return 0


def main() -> int:
    # Line by line even into a pipe or a file, as the log comes in.
    sys.stdout.reconfigure(line_buffering=True)
    plugin_args: list[str] = []
    args = sys.argv[1:]
    if "--" in args:
        plugin_args = args[args.index("--") + 1:]
        args = args[:args.index("--")]
    parser = argparse.ArgumentParser(description="Run this project's editor on a standalone headset over adb.")
    parser.add_argument("--scene", help="scene to open in VR, e.g. res://benchmarks/play_check.tscn")
    parser.add_argument("--engine", action="append", default=[], metavar="ARG",
                        help="argument for the engine of the editor in VR, e.g. --engine=--benchmark; repeatable")
    parser.add_argument("--no-deploy", action="store_true", help="don't copy the project")
    parser.add_argument("--no-open", action="store_true", help="don't (re)open the editor")
    parser.add_argument("--no-log", action="store_true", help="don't follow the log")
    parser.add_argument("--gpu-profile", action="store_true",
                        help="ovrgpuprofiler: detailed mode for the editor's package from before it starts, a render stage trace in every graph lab step, files beside the log")
    parser.add_argument("--gpu-trace-delay", type=float, default=5.0, metavar="S", help="seconds into a step before its trace (default 5)")
    parser.add_argument("--gpu-trace-sec", type=float, default=1.0, metavar="S", help="length of a trace (default 1)")
    parser.add_argument("--gpu-trace-args", default="-v", metavar="ARGS",
                        help="more arguments of ovrgpuprofiler -t, e.g. \"-v\" (default), \"-l\", or \"-x=1,2,3,4\" for per-draw metrics")
    options = parser.parse_args(args)
    if options.scene and not options.scene.startswith("res://"):
        print("quest: --scene takes a res:// path", file=sys.stderr)
        return 2
    if any(arg == "--" or arg.startswith("res://") for arg in options.engine):
        print("quest: --engine takes engine arguments; the scene goes in --scene", file=sys.stderr)
        return 2

    path = find_adb()
    if path is None:
        print("quest: adb not found: set ADB, put adb on PATH, or install the Android SDK platform-tools", file=sys.stderr)
        return 1
    adb = Adb(path)
    check_headset(adb)
    stem = log_stem()
    profiler: GpuProfiler | None = None
    if options.gpu_profile:
        if options.no_log:
            print("quest: --gpu-profile needs the log: the traces follow its lines", file=sys.stderr)
            return 2
        profiler = GpuProfiler(adb, stem, options.gpu_trace_delay, options.gpu_trace_sec, options.gpu_trace_args)
        profiler.info()
    if not options.no_deploy:
        deploy(adb)
    if profiler is not None:
        profiler.enable()
        if options.no_open:
            print("quest: --no-open: restart the editor in the headset for the detailed mode to take hold")
    try:
        if not options.no_open:
            open_in_vr(adb, options.scene, options.engine, plugin_args)
        if not options.no_log:
            return follow_log(adb, stem, profiler)
        return 0
    finally:
        if profiler is not None:
            profiler.disable()


if __name__ == "__main__":
    sys.exit(main())
