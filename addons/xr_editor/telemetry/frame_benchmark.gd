@tool
class_name XREFrameBenchmark
extends Node
## Measures the editor's VR frame time for the spike's go/no-go threshold
## (docs/plan.md: at least 95% of frames within 11.1 ms on an empty scene).
##
## [method run] waits until the headset is on (session FOCUSED), warms up and
## records [constant SEGMENTS], each frame by the native XREFrameTimer:
## [br]- [code]ui_visible[/code]: the desktop editor as is, its 3D viewport rendering too;
## [br]- [code]ui_hidden[/code]: the whole 2D editor UI hidden, so only the headset view renders.
## [br]The ABBA order keeps a drift over time (heat, the runtime halving the
## frame rate) from passing for a difference between the variants.
## All segments go to [code]frametime_<stamp>.csv[/code] in [constant RESULTS_DIR]
## (columns [code]segment[/code], [code]variant[/code]), plus [code]frametime_<stamp>_meta.json[/code].
## [br]Start without touching the editor UI (menus are windows of their own and
## disturb the frame pacing): [code]godot --path . --editor --xr-mode on
## res://benchmarks/empty.tscn -- --xre-benchmark[/code]; the editor quits when done.
## Analysis: [code]py benchmarks/frametime_report.py benchmarks/results/frametime_<stamp>.csv[/code].

## User argument (after [code]--[/code]) that runs the benchmark at startup and quits after it.
const CLI_FLAG := "--xre-benchmark"
## Time from putting on the headset to the first segment.
const WARMUP_SEC := 10.0
## Pause after switching variants, before recording.
const SETTLE_SEC := 5.0
const RECORD_SEC := 45.0
## Buffer headroom: frames per second the recorder can hold (120 Hz Quest modes).
const MAX_FPS := 150
const RESULTS_DIR := "res://benchmarks/results"
const SEGMENTS: Array[String] = ["ui_visible", "ui_hidden", "ui_hidden", "ui_visible"]

const _LOG_PREFIX := "XR Editor: "

## Session whose headset viewport is measured; set before [method run].
var session: XRESession
var _running := false


func _ready() -> void:
	if OS.get_cmdline_user_args().has(CLI_FLAG):
		run.call_deferred(true)


func _exit_tree() -> void:
	if _running:
		_running = false
		XREFrameTimer.stop()
		_set_ui_hidden(false)
		_log("frame time benchmark aborted.")


## Runs the whole measurement (about four minutes once the headset is on).
## With [param quit_when_done] the editor quits at the end.
func run(quit_when_done: bool = false) -> void:
	var xr := session.get_xr_interface()
	var xr_viewport := session.get_xr_viewport()
	if _running:
		_log("frame time benchmark is already running.")
		return
	if xr == null or xr_viewport == null:
		_log("frame time benchmark needs a running VR session: start the editor with --xr-mode on.")
		return
	_running = true

	_log("frame time benchmark: waiting for the headset to be put on.")
	while _running and xr.get_session_state() != OpenXRInterface.SESSION_STATE_FOCUSED:
		await _wait(1.0)
	if not _running:
		return

	var stamp := Time.get_datetime_string_from_system().replace(":", "-")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RESULTS_DIR))
	_save_metadata(RESULTS_DIR.path_join("frametime_%s_meta.json" % stamp), xr)
	if not is_equal_approx(xr.display_refresh_rate, 90.0):
		_log("note: the display runs at %.1f Hz, not 90 Hz; set 90 Hz in Meta Horizon Link." % xr.display_refresh_rate)
	_log("frame time benchmark: %d s warm-up, then %s, %d s each." % [WARMUP_SEC, ", ".join(SEGMENTS), RECORD_SEC])
	await _wait(WARMUP_SEC)

	# One buffer for the whole run, saved once at the end: a file write between
	# segments stalls the main loop and disturbs the next segment.
	XREFrameTimer.start(roundi(RECORD_SEC * MAX_FPS * SEGMENTS.size()))
	for index in SEGMENTS.size():
		var variant := SEGMENTS[index]
		var hide_ui := variant == "ui_hidden"
		_set_ui_hidden(hide_ui)
		await _wait(SETTLE_SEC)
		if not _running:
			return
		XREFrameTimer.begin_segment(index + 1, variant, xr_viewport.get_viewport_rid(), _desktop_viewports(hide_ui))
		_log("segment %d/%d: recording %s for %d s." % [index + 1, SEGMENTS.size(), variant, RECORD_SEC])
		await _wait(RECORD_SEC)
		XREFrameTimer.end_segment()
		if not _running:
			return

	_set_ui_hidden(false)
	_running = false
	var frames := XREFrameTimer.stop()
	var csv_path := RESULTS_DIR.path_join("frametime_%s.csv" % stamp)
	var save_error := XREFrameTimer.save_csv(csv_path)
	_log("frame time benchmark done: %d frames saved to %s (%s)." % [frames, csv_path, error_string(save_error)])
	_log("report: py benchmarks/frametime_report.py %s" % ProjectSettings.globalize_path(csv_path))
	if quit_when_done:
		get_tree().quit()


## Desktop viewports that render in a variant, for GPU time. Hidden ones keep
## reporting their last measurement, so they must be left out.
func _desktop_viewports(ui_hidden: bool) -> Array[RID]:
	var viewports: Array[RID] = [get_tree().root.get_viewport_rid()]
	if not ui_hidden:
		viewports.append(EditorInterface.get_editor_viewport_3d(0).get_viewport_rid())
	return viewports


## Hiding the base control also stops the 3D viewport: its SubViewportContainer
## disables the viewport's updates when hidden.
func _set_ui_hidden(hidden: bool) -> void:
	EditorInterface.get_base_control().visible = not hidden


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _save_metadata(path: String, xr: OpenXRInterface) -> void:
	var system := xr.get_system_info()
	var settings := EditorInterface.get_editor_settings()
	var scene_root := EditorInterface.get_edited_scene_root()
	var editor_viewport_container := EditorInterface.get_editor_viewport_3d(0).get_parent() as Control
	var meta := {
		"godot": Engine.get_version_info().get("string", ""),
		"git_head": _git_head(),
		"openxr_runtime": "%s %s" % [system.get("XRRuntimeName", ""), system.get("XRRuntimeVersion", "")],
		"openxr_system": system.get("OpenXRSystemName", ""),
		"display_refresh_rate_hz": xr.display_refresh_rate,
		"render_target_size": [xr.get_render_target_size().x, xr.get_render_target_size().y],
		"render_target_size_multiplier": xr.render_target_size_multiplier,
		"gpu": RenderingServer.get_video_adapter_name(),
		"gpu_driver": OS.get_video_adapter_driver_info(),
		"cpu": OS.get_processor_name(),
		"cpu_threads": OS.get_processor_count(),
		"window_size": [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y],
		"editor_3d_viewport_visible": editor_viewport_container != null and editor_viewport_container.is_visible_in_tree(),
		"scene": scene_root.scene_file_path if scene_root != null else "",
		"scene_nodes": _count_nodes(scene_root) if scene_root != null else 0,
		# Output panel: without collapsing, the engine's per-frame OpenXR error fills it
		# up to max_lines, after which every message costs several ms (see CLAUDE.md).
		"editor_log_collapse": settings.get_setting("_editor_log_collapse") if settings.has_setting("_editor_log_collapse") else null,
		"editor_log_max_lines": settings.get_setting("run/output/max_lines"),
		"low_processor_mode": OS.low_processor_usage_mode,
		"vsync_mode": DisplayServer.window_get_vsync_mode(),
		"warmup_sec": WARMUP_SEC,
		"settle_sec": SETTLE_SEC,
		"record_sec": RECORD_SEC,
		"segments": SEGMENTS,
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_log("cannot write %s (%s)." % [path, error_string(FileAccess.get_open_error())])
		return
	file.store_string(JSON.stringify(meta, "\t") + "\n")


func _count_nodes(node: Node) -> int:
	var count := 1
	for child in node.get_children():
		count += _count_nodes(child)
	return count


## Commit the measurement ran on, read straight from .git (no git binary needed).
func _git_head() -> String:
	var head := FileAccess.get_file_as_string("res://.git/HEAD").strip_edges()
	if not head.begins_with("ref: "):
		return head
	var ref := head.trim_prefix("ref: ")
	var commit := FileAccess.get_file_as_string("res://.git".path_join(ref)).strip_edges()
	if commit.is_empty():
		for line in FileAccess.get_file_as_string("res://.git/packed-refs").split("\n"):
			if line.ends_with(" " + ref):
				commit = line.get_slice(" ", 0)
	return commit


func _log(message: String) -> void:
	print(_LOG_PREFIX, message)
