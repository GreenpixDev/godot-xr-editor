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
3. Shows the editor's output (logcat, tag godot) and keeps the whole logcat in
   logs/quest_<time>.log, until Ctrl+C. The engine's error that repeats every
   frame in the editor (sync_action_sets, D-004) stays out of the console.

Usage: py scripts/quest.py [--scene res://...] [--engine=ARG ...] [--no-deploy] [--no-open] [--no-log] [-- arguments for the plugin in VR]
  py scripts/quest.py
  py scripts/quest.py --scene res://benchmarks/play_check.tscn
  py scripts/quest.py --engine=--benchmark   (the editor's startup phases, in the log)
  py scripts/quest.py -- --xre-benchmark
Needs the Godot editor from the Horizon Store in the headset (4.7.x), USB
debugging allowed, and adb: ADB, adb on PATH, the Android SDK's, or SideQuest's.
Standard library only.
"""

from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
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


def follow_log(adb: Adb) -> int:
    logs = REPO / "logs"
    logs.mkdir(exist_ok=True)
    log = logs / f"quest_{time.strftime('%Y-%m-%dT%H-%M-%S')}.log"
    print(f"quest: log {log.relative_to(REPO).as_posix()}; Ctrl+C to stop")
    process = subprocess.Popen([adb.path, "logcat", "-v", "threadtime"], stdout=subprocess.PIPE)
    try:
        with open(log, "wb") as file:
            assert process.stdout is not None
            for raw in process.stdout:
                file.write(raw)
                line = raw.decode("utf-8", errors="replace").rstrip()
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
    if not options.no_deploy:
        deploy(adb)
    if not options.no_open:
        open_in_vr(adb, options.scene, options.engine, plugin_args)
    if not options.no_log:
        return follow_log(adb)
    return 0


if __name__ == "__main__":
    sys.exit(main())
