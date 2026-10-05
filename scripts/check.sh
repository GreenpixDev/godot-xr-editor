#!/usr/bin/env bash
# Static check of the project without a headset:
#   1. every GDScript parses and type-checks (warnings configured as errors in project.godot);
#   2. the plugin loads in a headless editor without errors.
# Exits non-zero on any error. Override the binary with GODOT=/path/to/godot.
set -uo pipefail
cd "$(dirname "$0")/.."
GODOT="${GODOT:-godot}"

log="$(mktemp)"
trap 'rm -f "$log"' EXIT

# XR off: checks must not depend on a headset or try to start OpenXR.
run() { timeout 300 "$GODOT" --headless --xr-mode off --path . "$@" >>"$log" 2>&1; }

run --import                       # builds the global class cache class_name lookups need
run -s res://scripts/parse_all.gd  # loads every script, including ones nothing references yet
run --editor --quit-after 60       # runs the plugin's _enter_tree / _exit_tree

if grep -E "SCRIPT ERROR|ERROR:|WARNING:|parse_all: FAILED" "$log"; then
	echo "check: FAILED" >&2
	exit 1
fi
grep "parse_all:" "$log"
echo "check: OK"
