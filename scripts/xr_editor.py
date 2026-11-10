#!/usr/bin/env python3
"""Starts the Godot editor on this project, in VR if a headset is available.

Picks the OpenXR runtime itself, in this order:
1. SteamVR, if it is already running and sees a headset (Quest through Steam Link);
2. Meta Horizon, if it sees a headset (Quest Link);
3. no VR (--xr-mode off), or with --fallback sim the VR view in a window.
--runtime sim skips the headset: the VR view opens in a window of its own,
with the keyboard and mouse for controllers (docs/decisions.md, D-057).
--mirror also shows what the headset shows in a window on the desktop
(D-118); without a headset, in the VR view in a window or without VR, it does
nothing. --hide-ui hides the editor's 2D UI and minimizes its window while
the headset shows the editor or, with sim, while the VR view's window is open;
restoring the window from the taskbar shows it until the next trigger or grip,
and with sim closing the VR view's window closes the editor (D-119). Without
VR it does nothing.
A runtime sees a headset when xrGetSystem finds a head-mounted display. The
check creates and destroys an OpenXR instance, without a session, in a child
process that exits before Godot starts. SteamVR is never checked unless it is
already running: creating an instance on it would launch it.

Godot gets XR_RUNTIME_JSON for the runtime picked, so a value left in the shell
by an earlier run can't redirect it. The log goes to
logs/editor_<runtime>_<time>.log. Before anything else the script closes an
editor already open on this project and waits until it lets go of the
plugin's native library: a second editor on this project starts without it,
and without it VR doesn't work (docs/decisions.md, D-005). Unsaved changes in
the editor closed are lost; --no-restart fails instead.

--tracy (docs/performance_plan.md step 1.5, D-160) starts the editor built with Tracy
(scripts/build_engine.py tracy) unless --godot or GODOT names another, and records a Tracy
capture inside every graph lab step: --tracy-delay seconds after the step's line, for
--tracy-sec seconds, into logs/editor_<runtime>_<time>_tracy_<n>_<step>.tracy (open one in
tracy-profiler.exe to look); benchmarks/tracy_steps.py makes the tables after the run, so that
exporting doesn't load the CPU during it. The engine's lines then pass through this script.

Usage: py scripts/xr_editor.py [--runtime auto|steamvr|meta|off|sim] [--fallback off|sim] [--mirror] [--hide-ui] [--engine=ARG ...] [--godot PATH] [--tracy [--tracy-delay S] [--tracy-sec S]] [--check] [--no-restart] [scene] [-- arguments for the plugin]
  py scripts/xr_editor.py --engine=--gpu-profile res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress   (the engine prints its GPU time by stage every second)
  py scripts/xr_editor.py --tracy --fallback sim --hide-ui res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress   (CPU by function in every step)
  py scripts/xr_editor.py res://benchmarks/manipulation_check.tscn
  py scripts/xr_editor.py --fallback sim --mirror    (the headset with its view on the desktop, else the window)
  py scripts/xr_editor.py --runtime meta res://benchmarks/empty.tscn -- --xre-benchmark
  py scripts/xr_editor.py --runtime sim res://benchmarks/play_check.tscn
  py scripts/xr_editor.py --fallback sim    (Rider's XR Editor: the headset if one is found, else the window)
--runtime steamvr or meta skips the order above and fails if that runtime
sees no headset (steamvr launches SteamVR if needed). --check only reports
the runtime that would be used, without starting Godot. Override the Godot
binary with --godot or GODOT=path/to/Godot_..._console.exe. Windows only, standard library only.
"""

from __future__ import annotations

import argparse
import ctypes
import json
import os
import re
import shutil
import subprocess
import sys
import threading
import time
import winreg
from ctypes import POINTER, byref, c_char, c_char_p, c_int32, c_uint32, c_uint64, c_void_p
from pathlib import Path
from typing import Any

import build_engine
from quest import LAB_AWAY, StepAttempts
from xr_extensions import load_runtime, xr_make_version

REPO = Path(__file__).resolve().parent.parent
# The graph lab's line that starts a step (quest.py and benchmarks/*_steps.py read the same).
LAB_STEP = re.compile(r"XR Editor: graph lab: ([a-z_0-9]+)\s*$")
# Where an unattended graph lab run ends here: done, or off to a second editor on Compatibility,
# which runs on its own and isn't measured from this script.
LAB_END = ("XR Editor: graph lab: done", "XR Editor: graph lab: leaving for Compatibility")
# Seconds without a graph lab line after which an unattended run gives up.
LAB_SILENCE = 240
NATIVE_BIN = REPO / "addons" / "xr_editor" / "bin"
DEFAULT_META_MANIFEST = Path(r"C:\Program Files\Meta Horizon\Support\oculus-runtime\oculus_openxr_64.json")
# A runtime that doesn't answer in this time counts as having no headset, in seconds.
PROBE_TIMEOUT = 30

XR_TYPE_INSTANCE_CREATE_INFO = 3
XR_TYPE_SYSTEM_GET_INFO = 4
XR_TYPE_SYSTEM_PROPERTIES = 5
XR_FORM_FACTOR_HEAD_MOUNTED_DISPLAY = 1
XR_ERRORS = {
    -2: "XR_ERROR_RUNTIME_FAILURE",
    -4: "XR_ERROR_API_VERSION_UNSUPPORTED",
    -6: "XR_ERROR_INITIALIZATION_FAILED",
    -10: "XR_ERROR_LIMIT_REACHED",
    -13: "XR_ERROR_INSTANCE_LOST",
    -35: "XR_ERROR_FORM_FACTOR_UNAVAILABLE",
    -51: "XR_ERROR_RUNTIME_UNAVAILABLE",
}


class ApplicationInfo(ctypes.Structure):
    _fields_ = [
        ("applicationName", c_char * 128),
        ("applicationVersion", c_uint32),
        ("engineName", c_char * 128),
        ("engineVersion", c_uint32),
        ("apiVersion", c_uint64),
    ]


class InstanceCreateInfo(ctypes.Structure):
    _fields_ = [
        ("type", c_int32),
        ("next", c_void_p),
        ("createFlags", c_uint64),
        ("applicationInfo", ApplicationInfo),
        ("enabledApiLayerCount", c_uint32),
        ("enabledApiLayerNames", POINTER(c_char_p)),
        ("enabledExtensionCount", c_uint32),
        ("enabledExtensionNames", POINTER(c_char_p)),
    ]


class SystemGetInfo(ctypes.Structure):
    _fields_ = [("type", c_int32), ("next", c_void_p), ("formFactor", c_int32)]


class SystemProperties(ctypes.Structure):
    _fields_ = [
        ("type", c_int32),
        ("next", c_void_p),
        ("systemId", c_uint64),
        ("vendorId", c_uint32),
        ("systemName", c_char * 256),
        ("maxSwapchainImageHeight", c_uint32),
        ("maxSwapchainImageWidth", c_uint32),
        ("maxLayerCount", c_uint32),
        ("orientationTracking", c_uint32),
        ("positionTracking", c_uint32),
    ]


# XrInstance is a pointer-sized handle, XrSystemId a 64-bit atom.
PFN_CreateInstance = ctypes.CFUNCTYPE(c_int32, POINTER(InstanceCreateInfo), POINTER(c_uint64))
PFN_DestroyInstance = ctypes.CFUNCTYPE(c_int32, c_uint64)
PFN_GetSystem = ctypes.CFUNCTYPE(c_int32, c_uint64, POINTER(SystemGetInfo), POINTER(c_uint64))
PFN_GetSystemProperties = ctypes.CFUNCTYPE(c_int32, c_uint64, c_uint64, POINTER(SystemProperties))


def error_name(result: int) -> str:
    return XR_ERRORS.get(result, f"XrResult {result}")


def probe(manifest: str) -> dict:
    """Asks the runtime of [manifest] for a head-mounted display. Run in a child
    process: the runtime stays loaded in the process that asked."""
    runtime = load_runtime(manifest)

    def function(instance: int, name: str, prototype: Any) -> Any:
        pointer = c_void_p()
        result = runtime.get_instance_proc_addr(instance, name.encode(), byref(pointer))
        if result < 0:
            raise RuntimeError(f"{name}: {error_name(result)}")
        return prototype(pointer.value)

    info = InstanceCreateInfo()
    info.type = XR_TYPE_INSTANCE_CREATE_INFO
    info.applicationInfo.applicationName = b"XR Editor headset check"
    info.applicationInfo.engineName = b"Godot"
    info.applicationInfo.apiVersion = xr_make_version(1, 0, 0)
    instance = c_uint64()
    result = function(0, "xrCreateInstance", PFN_CreateInstance)(byref(info), byref(instance))
    if result < 0:
        return {"headset": False, "reason": f"xrCreateInstance: {error_name(result)}"}
    try:
        system_info = SystemGetInfo(XR_TYPE_SYSTEM_GET_INFO, None, XR_FORM_FACTOR_HEAD_MOUNTED_DISPLAY)
        system = c_uint64()
        result = function(instance.value, "xrGetSystem", PFN_GetSystem)(instance, byref(system_info), byref(system))
        if result < 0:
            return {"headset": False, "reason": f"xrGetSystem: {error_name(result)}"}
        properties = SystemProperties()
        properties.type = XR_TYPE_SYSTEM_PROPERTIES
        get_properties = function(instance.value, "xrGetSystemProperties", PFN_GetSystemProperties)
        name = properties.systemName.decode(errors="replace") \
            if get_properties(instance, system, byref(properties)) >= 0 else "?"
        return {"headset": True, "system": name}
    finally:
        function(instance.value, "xrDestroyInstance", PFN_DestroyInstance)(instance)


def check_runtime(label: str, manifest: Path) -> bool:
    """Probes [manifest] in a child process and reports what it found."""
    try:
        child = subprocess.run([sys.executable, __file__, "--probe", str(manifest)],
                               capture_output=True, text=True, timeout=PROBE_TIMEOUT)
        answer = json.loads(child.stdout.strip().splitlines()[-1])
    except subprocess.TimeoutExpired:
        answer = {"headset": False, "reason": f"no answer in {PROBE_TIMEOUT} s"}
    except (ValueError, IndexError):
        answer = {"headset": False, "reason": f"check failed: {child.stderr.strip() or child.stdout.strip()}"}
    if answer["headset"]:
        print(f"xr_editor: {label}: headset {answer['system']}")
        return True
    print(f"xr_editor: {label}: no headset ({answer['reason']})")
    return False


def steamvr_manifest() -> Path | None:
    """SteamVR's runtime manifest, found where SteamVR registers its install folder."""
    vrpath = Path(os.environ.get("LOCALAPPDATA", "")) / "openvr" / "openvrpaths.vrpath"
    try:
        folders = json.loads(vrpath.read_text(encoding="utf-8"))["runtime"]
    except (OSError, ValueError, KeyError, TypeError):
        return None
    for folder in folders:
        manifest = Path(folder) / "steamxr_win64.json"
        if manifest.is_file():
            return manifest
    return None


def meta_manifest() -> Path | None:
    """Meta Horizon's runtime manifest: the registered one, or the default install."""
    candidates = []
    try:
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Khronos\OpenXR\1") as key:
            try:
                candidates.append(winreg.QueryValueEx(key, "ActiveRuntime")[0])
            except OSError:
                pass
            try:
                with winreg.OpenKey(key, "AvailableRuntimes") as available:
                    index = 0
                    while True:
                        candidates.append(winreg.EnumValue(available, index)[0])
                        index += 1
            except OSError:
                pass
    except OSError:
        pass
    candidates.append(str(DEFAULT_META_MANIFEST))
    for candidate in candidates:
        if "oculus_openxr" in candidate.lower() and Path(candidate).is_file():
            return Path(candidate)
    return None


def is_process_running(image: str) -> bool:
    listing = subprocess.run(["tasklist", "/FI", f"IMAGENAME eq {image}", "/NH", "/FO", "CSV"],
                             capture_output=True, text=True, errors="replace")
    return image.lower() in listing.stdout.lower()


def native_library_in_use() -> bool:
    """Whether another editor has loaded the native library. Godot loads a copy
    (~xre_native...dll), and Windows doesn't let anyone write a loaded DLL."""
    for copy in NATIVE_BIN.glob("~xre_native*.dll"):
        try:
            with open(copy, "r+b"):
                pass
        except PermissionError:
            return True
        except OSError:
            pass
    return False


def running_editors() -> list[int]:
    """Process ids of the Godot editors open on this project: the console
    wrapper and the editor it started, if both are there."""
    script = ("Get-CimInstance Win32_Process -Filter \"Name like 'Godot%'\" | "
              "Select-Object ProcessId, CommandLine | ConvertTo-Json -Compress")
    listing = subprocess.run(["powershell", "-NoProfile", "-NonInteractive", "-Command", script],
                             capture_output=True, text=True, errors="replace")
    try:
        found = json.loads(listing.stdout) if listing.stdout.strip() else []
    except json.JSONDecodeError:
        return []
    if isinstance(found, dict):
        found = [found]
    repo = str(REPO).lower().rstrip("\\")
    editors: list[int] = []
    for process in found:
        command = (process.get("CommandLine") or "").lower().replace("/", "\\")
        if "--editor" in command and repo in command:
            editors.append(int(process["ProcessId"]))
    return editors


def close_editors(editors: list[int], timeout: float = 20.0) -> bool:
    """Closes the editors [editors] and waits until the native library is
    free. Whether it is."""
    for pid in editors:
        subprocess.run(["taskkill", "/F", "/T", "/PID", str(pid)], capture_output=True)
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if not running_editors() and not native_library_in_use():
            return True
        time.sleep(0.5)
    return False


def godot_binary() -> str | None:
    """The console build of Godot 4.7: GODOT, or the one godot.cmd runs."""
    if os.environ.get("GODOT"):
        return os.environ["GODOT"]
    wrapper = shutil.which("godot.cmd")
    if wrapper:
        builds = sorted(Path(wrapper).parent.glob("Godot_v4.7*_console.exe"), reverse=True)
        if builds:
            return str(builds[0])
    return None


class TracyCapture:
    """Tracy captures inside graph lab steps (docs/performance_plan.md step 1.5, D-160). The engine is
    built with TRACY_ON_DEMAND: it records only while tracy-capture is connected, so every capture is
    its own short connection, and nothing is kept between steps."""

    def __init__(self, stem: Path, delay: float, seconds: float) -> None:
        self.stem = stem
        self.delay = delay
        self.seconds = seconds
        self.count = 0
        self.busy = threading.Lock()
        self.capture = build_engine.TRACY_TOOLS / "tracy-capture.exe"
        self.process: subprocess.Popen[str] | None = None
        self.attempts = StepAttempts("tracy")

    def available(self) -> bool:
        return self.capture.is_file()

    def stop(self) -> None:
        """Ends a capture still running: left behind, it would attach to the next Tracy editor."""
        if self.process is not None and self.process.poll() is None:
            self.process.kill()

    def step_started(self, step: str) -> None:
        threading.Thread(target=self.record, args=(step, self.attempts.start()), daemon=True).start()

    def record(self, step: str, attempt: int) -> None:
        time.sleep(self.delay)
        if not self.busy.acquire(blocking=False):
            print(f"xr_editor: tracy: still capturing, no capture in {step}")
            return
        try:
            self.count += 1
            trace = self.stem.with_name(f"{self.stem.name}_tracy_{self.count:02d}_{step}.tracy")
            self.process = subprocess.Popen([str(self.capture), "-o", str(trace), "-f", "-s", f"{self.seconds:g}"],
                                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, errors="replace")
            output, _ = self.process.communicate()
            if self.process.returncode != 0 or not trace.is_file():
                print(f"xr_editor: tracy: capture in {step} failed: {output.strip()[-300:]}")
                return
            print(f"xr_editor: tracy: {trace.relative_to(REPO).as_posix()} ({self.seconds:g} s of {step})")
            self.attempts.keep(attempt, trace)
        finally:
            self.busy.release()


def kill_tree(process: subprocess.Popen[bytes]) -> None:
    """Ends the editor and what it started (another editor instance, a game): taskkill /T."""
    if process.poll() is None:
        subprocess.run(["taskkill", "/T", "/F", "/PID", str(process.pid)], capture_output=True)


def run_following(command: list[str], env: dict[str, str], tracy: TracyCapture | None, unattended: bool) -> int:
    """Runs Godot with its output passing through, starting a Tracy capture on every graph lab step.
    [unattended]: the editor is closed after the graph lab is done (or leaves for Compatibility, a
    second editor instance that runs on its own), once the capture under way is written; and the run
    is given up after LAB_SILENCE s without a graph lab line."""
    process = subprocess.Popen(command, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    assert process.stdout is not None
    last_lab = [time.monotonic()]
    silent = threading.Event()

    def watch() -> None:
        while process.poll() is None:
            if time.monotonic() - last_lab[0] > LAB_SILENCE:
                silent.set()
                kill_tree(process)
                return
            time.sleep(1)

    if unattended:
        threading.Thread(target=watch, daemon=True).start()
    try:
        for raw in process.stdout:
            # The engine's bytes as they are (UTF-8), not re-encoded to the console's code page.
            sys.stdout.buffer.write(raw)
            sys.stdout.buffer.flush()
            line = raw.decode("utf-8", errors="replace").rstrip("\r\n")
            if "XR Editor: graph lab" in line:
                last_lab[0] = time.monotonic()
            # A step the session left focus in is run again (D-161): the cut attempt's capture gets .void.
            if tracy is not None and LAB_AWAY.search(line):
                tracy.attempts.cut()
            if tracy is not None and (step := LAB_STEP.search(line)):
                tracy.step_started(step.group(1))
            if unattended and any(end in line for end in LAB_END):
                if tracy is not None:
                    time.sleep(tracy.delay)
                    if tracy.busy.acquire(timeout=60):
                        tracy.busy.release()
                print(f"xr_editor: the graph lab is done ({line.split('graph lab: ')[-1]}); closing the editor")
                kill_tree(process)
                process.wait()
                return 0
        code = process.wait()
        if silent.is_set():
            print(f"xr_editor: error: no graph lab line for {LAB_SILENCE} s; the editor was closed, the run failed")
            return 1
        return code
    except KeyboardInterrupt:
        kill_tree(process)
        return 130
    finally:
        if tracy is not None:
            tracy.stop()


def pick_runtime(requested: str, fallback: str = "off") -> tuple[str, Path | None]:
    """Name of the runtime to use ("steamvr", "meta", "off" or "sim") and its manifest.
    With "auto", fallback ("off" or "sim") is used when no runtime sees a headset."""
    if requested in ("off", "sim"):
        return requested, None
    steamvr = steamvr_manifest()
    meta = meta_manifest()
    if requested == "steamvr":
        if steamvr is None:
            sys.exit("xr_editor: SteamVR is not installed (no runtime in openvrpaths.vrpath)")
        if not check_runtime("SteamVR", steamvr):
            sys.exit("xr_editor: connect the headset to SteamVR (Steam Link on the Quest) and try again")
        return "steamvr", steamvr
    if requested == "meta":
        if meta is None:
            sys.exit("xr_editor: the Meta Horizon runtime is not installed")
        if not check_runtime("Meta Horizon", meta):
            sys.exit("xr_editor: start Quest Link in the headset and try again")
        return "meta", meta

    if steamvr is None:
        print("xr_editor: SteamVR: not installed")
    elif not is_process_running("vrserver.exe"):
        print("xr_editor: SteamVR: not running, not checked")
    elif check_runtime("SteamVR", steamvr):
        return "steamvr", steamvr
    if meta is not None and check_runtime("Meta Horizon", meta):
        return "meta", meta
    if fallback == "sim":
        print("xr_editor: no runtime sees a headset, falling back to the VR view in a window")
    return fallback, None


def main() -> int:
    # Its lines come before Godot's in a log or a pipe, not after Godot exits.
    sys.stdout.reconfigure(line_buffering=True)
    if len(sys.argv) == 3 and sys.argv[1] == "--probe":
        try:
            answer = probe(sys.argv[2])
        except (OSError, RuntimeError) as error:
            answer = {"headset": False, "reason": str(error)}
        print(json.dumps(answer))
        return 0

    plugin_args: list[str] = []
    args = sys.argv[1:]
    if "--" in args:
        plugin_args = args[args.index("--") + 1:]
        args = args[:args.index("--")]
    parser = argparse.ArgumentParser(description="Start the Godot editor on this project, in VR if a headset is available.")
    parser.add_argument("--runtime", choices=["auto", "steamvr", "meta", "off", "sim"], default="auto")
    parser.add_argument("--fallback", choices=["off", "sim"], default="off",
                        help="with --runtime auto and no headset: no VR (off) or the VR view in a window (sim)")
    parser.add_argument("--mirror", action="store_true",
                        help="with a headset, also show its view in a window on the desktop")
    parser.add_argument("--hide-ui", action="store_true",
                        help="hide the editor's 2D UI while in VR: the headset, or the VR view in a window")
    parser.add_argument("--check", action="store_true", help="only report the runtime that would be used")
    parser.add_argument("--engine", action="append", default=[], metavar="ARG",
                        help="argument for the engine, e.g. --engine=--gpu-profile; repeatable")
    parser.add_argument("--godot", metavar="PATH", help="the Godot binary (a console build); default GODOT, else godot.cmd's")
    parser.add_argument("--unattended", action="store_true",
                        help="for graph lab runs Claude drives (D-161): the editor is closed once the lab is done or leaves "
                             f"for Compatibility, and the run given up after {LAB_SILENCE} s without a lab line")
    parser.add_argument("--tracy", action="store_true",
                        help="the Tracy build of the editor (scripts/build_engine.py tracy) and a Tracy capture in every graph lab step, files beside the log")
    parser.add_argument("--tracy-delay", type=float, default=3.0, metavar="S", help="seconds into a step before its capture (default 3)")
    parser.add_argument("--tracy-sec", type=float, default=5.0, metavar="S", help="length of a capture (default 5)")
    parser.add_argument("--no-restart", action="store_true",
                        help="fail if an editor is already open on this project instead of closing it")
    parser.add_argument("scene", nargs="?", help="scene to open, e.g. res://benchmarks/manipulation_check.tscn")
    options = parser.parse_args(args)

    editors = running_editors()
    if editors and not options.no_restart and not options.check:
        print(f"xr_editor: closing the editor already open on this project (pid {', '.join(map(str, editors))}); "
              "unsaved changes in it are lost")
        if not close_editors(editors):
            print("xr_editor: the editor didn't close in time", file=sys.stderr)
            return 1
    elif editors and options.check:
        print(f"xr_editor: would close the editor already open on this project (pid {', '.join(map(str, editors))})")
    if native_library_in_use() and not options.check:
        print("xr_editor: another Godot editor has the plugin's native library loaded; close it first.", file=sys.stderr)
        return 1
    godot = options.godot or (os.environ.get("GODOT") or None)
    if godot is None and options.tracy:
        godot = str(build_engine.EDITOR_CONSOLE)
        if not build_engine.EDITOR_CONSOLE.is_file():
            print(f"xr_editor: the Tracy build isn't there ({godot}); run py scripts/build_engine.py tracy", file=sys.stderr)
            return 1
    godot = godot or godot_binary()
    if godot is None:
        print("xr_editor: Godot 4.7 not found: put godot.cmd on PATH or set GODOT", file=sys.stderr)
        return 1

    runtime, manifest = pick_runtime(options.runtime, options.fallback)
    mode = f"in VR on {runtime}" if manifest else "with the VR view in a window, no headset" if runtime == "sim" else "without VR"
    if options.mirror and manifest:
        mode += ", the headset's view on the desktop"
    elif options.mirror:
        print("xr_editor: no headset, so no headset view on the desktop (--mirror)")
    if options.hide_ui and (manifest or runtime == "sim"):
        mode += ", the 2D UI hidden while in VR"
    elif options.hide_ui:
        print("xr_editor: no VR, so the 2D UI stays (--hide-ui)")
    if options.check:
        print(f"xr_editor: would start the editor {mode}")
        return 0
    if runtime == "sim" and "--xre-simulator" not in plugin_args:
        plugin_args.insert(0, "--xre-simulator")
    if options.mirror and manifest and "--xre-mirror" not in plugin_args:
        plugin_args.insert(0, "--xre-mirror")
    if options.hide_ui and (manifest or runtime == "sim") and "--xre-hide-ui" not in plugin_args:
        plugin_args.insert(0, "--xre-hide-ui")
    env = dict(os.environ)
    if manifest is not None:
        env["XR_RUNTIME_JSON"] = str(manifest)
    else:
        env.pop("XR_RUNTIME_JSON", None)
    logs = REPO / "logs"
    logs.mkdir(exist_ok=True)
    log = logs / f"editor_{runtime}_{time.strftime('%Y-%m-%dT%H-%M-%S')}.log"
    print(f"xr_editor: starting the editor {mode}, "
          f"log {log.relative_to(REPO).as_posix()}")
    if godot != godot_binary():
        print(f"xr_editor: Godot binary {godot}")

    command = [godot, "--path", str(REPO), "--editor", "--xr-mode", "on" if manifest else "off", "--log-file", str(log)]
    command += options.engine
    if options.scene:
        command.append(options.scene)
    if plugin_args:
        command += ["--", *plugin_args]
    tracy: TracyCapture | None = None
    if options.tracy:
        tracy = TracyCapture(log.with_suffix(""), options.tracy_delay, options.tracy_sec)
        if not tracy.available():
            print(f"xr_editor: Tracy's tools aren't in {build_engine.TRACY_TOOLS}; run py scripts/build_engine.py tools", file=sys.stderr)
            return 1
        print(f"xr_editor: tracy: a {options.tracy_sec:g} s capture {options.tracy_delay:g} s into every graph lab step")
    if tracy is not None or options.unattended:
        return run_following(command, env, tracy, options.unattended)
    try:
        return subprocess.run(command, env=env).returncode
    except KeyboardInterrupt:
        return 130


if __name__ == "__main__":
    sys.exit(main())
