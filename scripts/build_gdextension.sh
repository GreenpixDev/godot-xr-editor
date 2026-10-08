#!/usr/bin/env bash
# Builds the native part of the plugin (gdextension/) into addons/xr_editor/bin/.
#   scripts/build_gdextension.sh           Windows x86_64 with MSVC (the PC editor)
#   scripts/build_gdextension.sh android   Android arm64 with clang from the NDK
#                                          (the editor on a standalone headset, D-018)
# Both use the CMake and Ninja bundled with Visual Studio, found via vswhere.
# Windows: close the editor first, Windows locks a loaded DLL.
# Override the build type with CONFIG=Debug (default RelWithDebInfo: optimized, with debug info).
# Android: the NDK is the one Godot 4.7.2 itself is built with (platform/android/detect.py);
# override its location with ANDROID_NDK_ROOT.
set -euo pipefail
cd "$(dirname "$0")/.."
PLATFORM="${1:-windows}"
CONFIG="${CONFIG:-RelWithDebInfo}"
GODOT="${GODOT:-godot}"
NDK_VERSION=29.0.14206865

if [[ "$PLATFORM" != windows && "$PLATFORM" != android ]]; then
	echo "usage: scripts/build_gdextension.sh [windows|android]" >&2
	exit 2
fi

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

if [[ "$PLATFORM" == android ]]; then
	ndk="${ANDROID_NDK_ROOT:-$LOCALAPPDATA/Android/Sdk/ndk/$NDK_VERSION}"
	if ! grep -qs "Pkg.Revision = $NDK_VERSION" "$ndk/source.properties"; then
		echo "build: Android NDK $NDK_VERSION not found at $ndk (set ANDROID_NDK_ROOT)" >&2
		exit 1
	fi
	cmake_dir="$vs/Common7/IDE/CommonExtensions/Microsoft/CMake"
	export PATH="$(cygpath -u "$cmake_dir/CMake/bin"):$(cygpath -u "$cmake_dir/Ninja"):$PATH"
	cmake -S gdextension -B build/gdextension-android-arm64 -G Ninja \
		-DCMAKE_TOOLCHAIN_FILE="$(cygpath -m "$ndk/build/cmake/android.toolchain.cmake")" \
		-DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-24 -DANDROID_STL=c++_static \
		-DCMAKE_BUILD_TYPE="$CONFIG"
	cmake --build build/gdextension-android-arm64
	echo "build: OK ($(ls addons/xr_editor/bin/*.android.*.so))"
	exit 0
fi

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
