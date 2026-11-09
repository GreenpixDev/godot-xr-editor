#!/usr/bin/env bash
# Builds the spike's layer with the project's MSVC; the SDK's parts must be in sdk/ (see README.md).
set -euo pipefail
cd "$(dirname "$0")"
root="$(cygpath -w "$PWD")"
vs="$("/c/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe" -latest -prerelease -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath | tr -d '')"
bat="$(mktemp --suffix=.bat)"
trap 'rm -f "$bat"' EXIT
cat > "$bat" <<EOF
@echo off
call "$vs\\VC\\Auxiliary\\Build\\vcvars64.bat" >nul 2>&1 || exit /b 1
cmake -S "$root\\layer" -B "$root\\build\\cmake" -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_RUNTIME_OUTPUT_DIRECTORY="$root\build" || exit /b 1
cmake --build "$root\\build\\cmake" || exit /b 1
EOF
cmd.exe //c "$(cygpath -w "$bat")"
