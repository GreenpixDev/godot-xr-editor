#!/usr/bin/env bash
# Check of the project without a headset:
#   1. every GDScript parses and type-checks (warnings configured as errors in project.godot);
#   2. the VR tools pass their headless tests (picking, snapping, manipulation, the palette and
#      deleting, with fake controllers), and so do the panels, the controller models and play mode;
#   3. the plugin loads in a headless editor without errors, and the inspector in the headset
#      works there with the editor's own EditorInspector.
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
run -s res://scripts/test_tools.gd # tests XREPicker, XRESnap, XREIcons, XREManipulator, XREPalette and XRELocomotion
run -s res://scripts/test_controller_model.gd # tests XREControllerModel
run -s res://scripts/test_play_mode.gd # tests XREPlayMode and the game's way back to the editor
run -s res://scripts/test_panels.gd # tests XREPanels, its tabs and XREInspectorProxy with fake controllers
run -s res://scripts/test_blueprints.gd # tests standalone visual scripting and generated runtime code
run -s res://scripts/test_blueprint_picking.gd # tests card edges, sides and ports against their visible geometry
run -s res://scripts/test_blueprint_routing.gd # tests native curved routes against cached card obstacles
run --editor --quit-after 60       # runs the plugin's _enter_tree / _exit_tree
# Tests the inspector tab and XREPluginDocument in an editor (scripts/test_inspector.gd); quits when done.
run --editor --quit-after 3000 res://benchmarks/manipulation_check.tscn -- --xre-test-inspector
run --editor --quit-after 3000 res://benchmarks/blueprint_door.tscn -- --xre-test-blueprint-editor
run --editor --quit-after 3000 res://benchmarks/play_check.tscn -- --xre-test-blueprint-vr

if grep -E "SCRIPT ERROR|ERROR:|WARNING:|: FAILED" "$log"; then
	echo "check: FAILED" >&2
	exit 1
fi
# A test run that died or hung prints no summary.
for test in test_tools test_controller_model test_play_mode test_panels test_inspector test_blueprints test_blueprint_picking test_blueprint_routing test_blueprint_editor test_blueprint_vr; do
	if ! grep -q "$test: 0 of [0-9]* checks failed" "$log"; then
		echo "check: FAILED, $test didn't finish" >&2
		exit 1
	fi
done
grep -E "parse_all:|test_tools:|test_controller_model:|test_play_mode:|test_panels:|test_inspector:|test_blueprints:|test_blueprint_picking:|test_blueprint_routing:|test_blueprint_editor:|test_blueprint_vr:" "$log"
echo "check: OK"
