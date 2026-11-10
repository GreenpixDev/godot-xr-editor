#!/usr/bin/env python3
"""Builds Godot 4.7.2 with an engine profiler for docs/performance_plan.md, steps 1.5
and 1.6 (docs/decisions.md, D-160; how to measure with them: docs/profiling_builds.md).

  py scripts/build_engine.py tracy      the Windows editor with Tracy (step 1.5)
  py scripts/build_engine.py perfetto   the Horizon OS (Quest) editor APK with Perfetto (step 1.6)
  py scripts/build_engine.py tools      only the PC tools: Tracy's capture and CSV export,
                                        Perfetto's trace processor

Everything lives outside the repository, in XRE_ENGINE_DIR (default %LOCALAPPDATA%\\xre):
  godot/                    the engine's source at 4.7.2-stable, unchanged (the script refuses
                            to build if tracked files differ from the tag)
  tracy-<ver>/              Tracy's client source, compiled into the engine (profiler_path)
  tracy-<ver>-windows/      Tracy's release for Windows: tracy-profiler (the UI), tracy-capture,
                            tracy-csvexport; the same version as the client, their protocol must match
  perfetto-<ver>-windows/   trace_processor_shell, to read Perfetto traces on the PC
AccessKit, ANGLE and the D3D12 libraries go in %LOCALAPPDATA%\\Godot\\build_deps, where the
engine's Windows build looks for them by default, at the versions the engine's install scripts
pin; only x86_64 MSVC ones, and only when missing (those scripts fetch every architecture every
time). Builds run without Git Bash's MSYSTEM, which would move that folder into the source tree.

Flags follow the official build (godot-build-scripts: production=yes debug_symbols=yes, D3D12,
ANGLE and AccessKit on Windows; swappy and store_release=yes for the Android editor), plus the
profiler. Differences, all in D-160: Windows uses MSVC instead of MinGW GCC (Tracy reads PDB
symbols, not DWARF); Android builds arm64 only; the APK is signed with the debug key, so its
package is org.godotengine.editor.v4.meta.release and it installs next to the Store editor.

Builds run one at a time: both use the same source tree and SCons database.
Standard library only; needs Git, Visual Studio with MSVC, SCons (py -m pip install scons),
and for the APK the Android SDK with NDK r29 and a JDK 17 or newer.
"""

from __future__ import annotations

import argparse
import io
import os
import re
import shutil
import subprocess
import sys
import sysconfig
import urllib.request
import zipfile
from pathlib import Path

GODOT_TAG = "4.7.2-stable"
GODOT_COMMIT = "ed1daf0bf001b61586d9930840f2f1394092c079"
# Contemporary with 4.7.2 (August 2026); the engine's docs were written against 0.13.
TRACY_VERSION = "0.14.1"
# install_perfetto.py takes whatever is latest; pinned here so builds repeat (D-160).
PERFETTO_VERSION = "v58.2"
NDK_VERSION = "29.0.14206865"

ROOT = Path(os.environ.get("XRE_ENGINE_DIR") or Path(os.environ["LOCALAPPDATA"]) / "xre")
GODOT = ROOT / "godot"
TRACY_SRC = ROOT / f"tracy-{TRACY_VERSION}"
TRACY_TOOLS = ROOT / f"tracy-{TRACY_VERSION}-windows"
PERFETTO_TOOLS = ROOT / f"perfetto-{PERFETTO_VERSION}-windows"
# Where the engine's install scripts and its Windows build put and look for AccessKit, ANGLE, D3D12.
DEPS = Path(os.environ["LOCALAPPDATA"]) / "Godot" / "build_deps"
EDITOR_EXE = GODOT / "bin" / "godot.windows.editor.x86_64.exe"
EDITOR_CONSOLE = GODOT / "bin" / "godot.windows.editor.x86_64.console.exe"
APK_BUILT = GODOT / "bin" / "android_editor_builds" / "android_editor-horizonos-release.apk"
APK = GODOT / "bin" / "android_editor_builds" / "android_editor-horizonos-release-perfetto.apk"
APK_PACKAGE = "org.godotengine.editor.v4.meta.release"
JOBS = max(1, (os.cpu_count() or 2) - 1)


def run(command: list[str], cwd: Path | None = None, env: dict[str, str] | None = None) -> None:
    shown = ["scons" if part == SCONS_WITH_PREVIEW_MSVC else part for part in command]
    print(f"build_engine: {' '.join(shown)}", flush=True)
    result = subprocess.run(command, cwd=cwd, env=env)
    if result.returncode != 0:
        sys.exit(f"build_engine: failed ({result.returncode}): {' '.join(command)}")


def git(*args: str, cwd: Path) -> str:
    return subprocess.run(["git", "-c", "core.longpaths=true", *args], cwd=cwd, capture_output=True,
                          text=True, check=True).stdout.strip()


def download_zip(url: str, target: Path, strip_top: bool = False) -> None:
    print(f"build_engine: downloading {url}", flush=True)
    with urllib.request.urlopen(url) as response:
        data = response.read()
    with zipfile.ZipFile(io.BytesIO(data)) as archive:
        if not strip_top:
            archive.extractall(target)
            return
        for member in archive.infolist():
            parts = Path(member.filename).parts[1:]
            if not parts:
                continue
            path = target.joinpath(*parts)
            if member.is_dir():
                path.mkdir(parents=True, exist_ok=True)
            else:
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(archive.read(member))


def ensure_godot() -> None:
    if not (GODOT / ".git").is_dir():
        ROOT.mkdir(parents=True, exist_ok=True)
        run(["git", "-c", "core.longpaths=true", "clone", "--depth", "1", "-b", GODOT_TAG,
             "https://github.com/godotengine/godot.git", str(GODOT)])
    head = git("rev-parse", "HEAD", cwd=GODOT)
    if head != GODOT_COMMIT:
        sys.exit(f"build_engine: {GODOT} is at {head}, not {GODOT_TAG} ({GODOT_COMMIT})")
    # Unchanged source: no tracked file differs from the tag. Untracked files are the
    # profiler SDK and swappy the install scripts put in thirdparty/, and build output.
    changed = git("status", "--porcelain", "--untracked-files=no", cwd=GODOT)
    if changed:
        sys.exit(f"build_engine: the engine's source is modified, refusing to build:\n{changed}")


def ensure_tracy_source() -> None:
    if (TRACY_SRC / "public" / "TracyClient.cpp").is_file():
        return
    run(["git", "-c", "core.longpaths=true", "clone", "--depth", "1", "-b", f"v{TRACY_VERSION}",
         "https://github.com/wolfpld/tracy.git", str(TRACY_SRC)])


def ensure_tracy_tools() -> None:
    if not (TRACY_TOOLS / "tracy-capture.exe").is_file():
        download_zip(f"https://github.com/wolfpld/tracy/releases/download/v{TRACY_VERSION}/windows-{TRACY_VERSION}.zip",
                     TRACY_TOOLS)
    for name in ("tracy-profiler.exe", "tracy-capture.exe", "tracy-csvexport.exe"):
        if not (TRACY_TOOLS / name).is_file():
            sys.exit(f"build_engine: {name} is missing from Tracy's release in {TRACY_TOOLS}")
    print(f"build_engine: Tracy {TRACY_VERSION} tools in {TRACY_TOOLS}")


def ensure_perfetto_tools() -> None:
    if not (PERFETTO_TOOLS / "trace_processor_shell.exe").is_file():
        download_zip(f"https://github.com/google/perfetto/releases/download/{PERFETTO_VERSION}/windows-amd64.zip",
                     PERFETTO_TOOLS, strip_top=True)
    if not (PERFETTO_TOOLS / "trace_processor_shell.exe").is_file():
        sys.exit(f"build_engine: trace_processor_shell.exe is missing from Perfetto's release in {PERFETTO_TOOLS}")
    print(f"build_engine: Perfetto {PERFETTO_VERSION} trace processor in {PERFETTO_TOOLS}")


def ensure_tools() -> None:
    ensure_tracy_tools()
    ensure_perfetto_tools()


# SCons finds MSVC with vswhere without -prerelease, so it can't see a Visual Studio preview
# (this machine has only VS 18 Insiders, MSVC 14.51, the same scripts/build_gdextension.sh uses
# with vswhere -prerelease). Runs SCons with its vswhere query widened the same way; the engine's
# source and build scripts stay as they are.
SCONS_WITH_PREVIEW_MSVC = """
import sys
import SCons.Tool.MSCommon.vc as vc
query = vc._VSWhere._vswhere_query_json_output.__func__
def with_preview(cls, exe, args):
    found = query(cls, exe, list(args) + ["-prerelease"])
    for instance in found or []:
        instance["isPrerelease"] = False
    return found
vc._VSWhere._vswhere_query_json_output = classmethod(with_preview)
import SCons.Script
sys.argv[0] = "scons"
SCons.Script.main()
"""


def scons(*args: str, env: dict[str, str] | None = None) -> None:
    run([sys.executable, "-c", SCONS_WITH_PREVIEW_MSVC, f"-j{JOBS}", "warnings=no", "progress=no", *args],
        cwd=GODOT, env=env)


def windows_env() -> dict[str, str]:
    """The environment of a plain Windows shell: under Git Bash (MSYSTEM set) the engine's install
    scripts and platform/windows/detect.py would use bin/build_deps instead of DEPS."""
    env = dict(os.environ)
    env.pop("MSYSTEM", None)
    env.pop("MINGW_PREFIX", None)
    return env


def pinned(script: str, name: str) -> str:
    """A version pinned in one of the engine's install scripts, e.g. angle_version."""
    text = (GODOT / "misc" / "scripts" / script).read_text(encoding="utf-8")
    found = re.search(rf'^{name}\s*=\s*"([^"]+)"', text, re.M)
    if not found:
        sys.exit(f"build_engine: no {name} in misc/scripts/{script}")
    return found.group(1)


def ensure_windows_deps(env: dict[str, str]) -> None:
    """What install_accesskit.py, install_angle.py and install_d3d12_sdk_windows.py install, at their
    versions, but only for x86_64 with MSVC (they fetch every architecture, every time), into DEPS."""
    if not (DEPS / "accesskit").is_dir():
        run([sys.executable, "misc/scripts/install_accesskit.py"], cwd=GODOT, env=env)
    angle = pinned("install_angle.py", "angle_version")
    mesa = pinned("install_d3d12_sdk_windows.py", "mesa_version")
    pix = pinned("install_d3d12_sdk_windows.py", "pix_version")
    agility = pinned("install_d3d12_sdk_windows.py", "agility_sdk_version")
    for folder, url in (
            ("angle-x86_64-msvc", f"https://github.com/godotengine/godot-angle-static/releases/download/{angle}/godot-angle-static-x86_64-msvc-release.zip"),
            ("mesa-x86_64-msvc", f"https://github.com/godotengine/godot-nir-static/releases/download/{mesa}/godot-nir-static-x86_64-msvc-release.zip"),
            ("pix", f"https://www.nuget.org/api/v2/package/WinPixEventRuntime/{pix}"),
            ("agility_sdk", f"https://www.nuget.org/api/v2/package/Microsoft.Direct3D.D3D12/{agility}")):
        if not (DEPS / folder).is_dir():
            partial = DEPS / (folder + ".partial")
            if partial.exists():
                shutil.rmtree(partial)
            download_zip(url, partial)
            partial.rename(DEPS / folder)


def build_tracy() -> None:
    ensure_godot()
    ensure_tracy_source()
    ensure_tracy_tools()
    env = windows_env()
    ensure_windows_deps(env)
    scons("platform=windows", "arch=x86_64", "target=editor", "production=yes", "debug_symbols=yes", "d3d12=yes",
          "profiler=tracy", f"profiler_path={TRACY_SRC}", env=env)
    for path in (EDITOR_EXE, EDITOR_CONSOLE):
        if not path.is_file():
            sys.exit(f"build_engine: {path} wasn't built")
    print(f"build_engine: OK, the Tracy editor: {EDITOR_CONSOLE}")


def ensure_perfetto_sdk() -> None:
    sdk = GODOT / "thirdparty" / "perfetto"
    stamp = sdk / "xre_version.txt"
    if stamp.is_file() and stamp.read_text().strip() == PERFETTO_VERSION:
        return
    if sdk.exists():
        shutil.rmtree(sdk)
    # What misc/scripts/install_perfetto.py does, at a pinned version.
    download_zip(f"https://github.com/google/perfetto/releases/download/{PERFETTO_VERSION}/perfetto-cpp-sdk-src.zip", sdk)
    stamp.write_text(PERFETTO_VERSION + "\n")


def android_env() -> dict[str, str]:
    env = windows_env()
    sdk = Path(env.get("ANDROID_HOME") or env.get("ANDROID_SDK_ROOT") or Path(env["LOCALAPPDATA"]) / "Android" / "Sdk")
    if not (sdk / "ndk" / NDK_VERSION / "source.properties").is_file():
        sys.exit(f"build_engine: Android NDK {NDK_VERSION} not found in {sdk} (set ANDROID_HOME)")
    env["ANDROID_HOME"] = str(sdk)
    # Gradle's lib project insists on finding scons on PATH while configuring, even though it doesn't
    # run it here (the native library is built before); pip --user puts scons.exe in this folder.
    for scheme in (f"{os.name}_user", None):
        scripts = sysconfig.get_path("scripts", scheme) if scheme else sysconfig.get_path("scripts")
        if scripts and (Path(scripts) / "scons.exe").is_file():
            env["PATH"] = scripts + os.pathsep + env.get("PATH", "")
            break
    if not env.get("JAVA_HOME"):
        java = shutil.which("java")
        jdks = sorted(Path("C:/Program Files/Java").glob("jdk-*"), reverse=True)
        if jdks:
            env["JAVA_HOME"] = str(jdks[0])
        elif not java:
            sys.exit("build_engine: no JDK found; set JAVA_HOME to a JDK 17 or newer")
    return env


def build_perfetto() -> None:
    ensure_godot()
    ensure_perfetto_tools()
    ensure_perfetto_sdk()
    env = android_env()
    run([sys.executable, "misc/scripts/install_swappy_android.py"], cwd=GODOT)
    scons("platform=android", "arch=arm64", "target=editor", "production=yes", "debug_symbols=yes",
          "store_release=yes", "profiler=perfetto", env=env)
    java = GODOT / "platform" / "android" / "java"
    run([str(java / "gradlew.bat"), "generateGodotHorizonOSEditor"], cwd=java, env=env)
    if not APK_BUILT.is_file():
        sys.exit(f"build_engine: {APK_BUILT} wasn't built")
    shutil.copy2(APK_BUILT, APK)
    print(f"build_engine: OK, the Perfetto editor for Quest: {APK} (package {APK_PACKAGE})")


def main() -> int:
    sys.stdout.reconfigure(line_buffering=True)
    parser = argparse.ArgumentParser(description="Build Godot 4.7.2 with Tracy (Windows) or Perfetto (Quest).")
    parser.add_argument("what", choices=["tracy", "perfetto", "tools"])
    options = parser.parse_args()
    {"tracy": build_tracy, "perfetto": build_perfetto, "tools": ensure_tools}[options.what]()
    return 0


if __name__ == "__main__":
    sys.exit(main())
