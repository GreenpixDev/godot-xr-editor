#!/usr/bin/env bash
# Builds the native part of the plugin (gdextension/) into addons/xr_editor/bin/.
# Windows + MSVC: finds Visual Studio with C++ tools via vswhere and builds with
# its bundled CMake and Ninja. Close the editor first: Windows locks a loaded DLL.
# Override the build type with CONFIG=Debug (default RelWithDebInfo: optimized, with a PDB).
set -euo pipefail
cd "$(dirname "$0")/.."
CONFIG="${CONFIG:-RelWithDebInfo}"
GODOT="${GODOT:-godot}"

vswhere="/c/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe"
if [[ ! -x "$vswhere" ]]; then
	echo "build: vswhere not found, install Visual Studio with 'Desktop development with C++'" >&2
	exit 1
fi
vs="$("$vswhere" -latest -prerelease -products '*' \
	-requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath | tr -d '\r')"
if [[ -z "$vs" ]]; then
	echo "build: no Visual Studio installation with MSVC x64 tools" >&2
	exit 1
fi

if [[ ! -f gdextension/godot-cpp/CMakeLists.txt ]]; then
	git submodule update --init gdextension/godot-cpp
fi

# Keep Godot from scanning C++ sources and build trees as project resources.
mkdir -p build && touch build/.gdignore

root="$(cygpath -w "$PWD")"
bat="$(mktemp --suffix=.bat)"
trap 'rm -f "$bat"' EXIT
cat >"$bat" <<EOF
@echo off
call "$vs\\VC\\Auxiliary\\Build\\vcvars64.bat" >nul 2>&1 || exit /b 1
cmake -S "$root\\gdextension" -B "$root\\build\\gdextension" -G Ninja -DCMAKE_BUILD_TYPE=$CONFIG || exit /b 1
cmake --build "$root\\build\\gdextension" || exit /b 1
EOF
cmd //c "$(cygpath -w "$bat")"

# The editor registers a GDExtension at startup only if .godot/extension_list.cfg
# already lists it; a headless import scan writes that list.
"$GODOT" --headless --xr-mode off --path . --import >/dev/null 2>&1 || true
grep -q "xr_editor.gdextension" .godot/extension_list.cfg || {
	echo "build: xr_editor.gdextension is missing from .godot/extension_list.cfg" >&2
	exit 1
}
echo "build: OK ($(ls addons/xr_editor/bin/*.dll))"
