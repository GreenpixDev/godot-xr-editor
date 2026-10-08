@tool
extends EditorPlugin
## Spike, not part of the XR Editor plugin: can the Godot editor on Horizon OS
## run in its immersive activity, the one it keeps for XR games?
##
## The Android editor (4.7.2) opens every launch with [code]--editor[/code] or
## [code]-e[/code] in its panel activity, and the XR game activity relaunches
## itself as a panel when it sees them ([code]BaseGodotGame.onGodotSetupCompleted[/code]).
## A path ending in [code]project.godot[/code] also starts the editor
## ([code]main/main.cpp[/code]) but isn't on that list, so
## [method OS.create_instance] with [code]--xr-mode on[/code] and that path
## opens the editor in the XR game activity.
## [br][br]
## In the panel editor the probe adds a Project → Tools item that does this.
## In the editor started that way it shows the edited scene in the headset,
## as the XR Editor plugin does on PC, and measures frame pacing: once the
## session is focused, four segments of [constant SEGMENT_SEC] seconds each,
## ABBA, with the editor's UI (invisible in the headset) shown and hidden.
## Every line goes to the Output (logcat tag [code]godot[/code]) and to a file
## in [code]probe_logs/[/code].
## [br][br]
## With the XR Editor's native library built for Android ([code]build_android.sh[/code]),
## its XREEditorFrameLoop keeps xrWaitFrame and the editor's draws paired from
## the session's first frame, as on PC (D-005).

const LAUNCH_MENU := "Horizon Probe: Open Editor in Immersive Mode"
## User argument that marks the editor the probe started.
const IMMERSIVE_ARG := "--horizon-probe-immersive"
const SCENE_PATH := "res://probe_scene.tscn"
const LOG_DIR := "res://probe_logs"
## Seconds between status lines, in real time.
const STATUS_INTERVAL := 5.0
## Focused seconds before the first segment.
const WARMUP_SEC := 5.0
## Focused seconds per segment.
const SEGMENT_SEC := 30.0
## Whether the editor UI is shown in each segment (ABBA, as XREFrameBenchmark).
const SEGMENT_DESKTOP: Array[bool] = [true, false, false, true]
## A frame interval up to this many display periods counts as on time.
const ON_TIME_RATIO := 1.25
## Names of [enum OpenXRInterface.SessionState] values, indexed by value.
const _STATE_NAMES: Array[String] = [
	"UNKNOWN", "IDLE", "READY", "SYNCHRONIZED", "VISIBLE",
	"FOCUSED", "STOPPING", "LOSS_PENDING", "EXITING",
]

var _log_file: FileAccess
var _menu_added := false
var _xr: OpenXRInterface
var _viewport: SubViewport
var _root_rid: RID
var _editor_viewport_rid: RID
var _focused_at := -1.0
var _session_ends := 0
var _last_usec := 0
var _last_status_usec := 0
var _was_focused := false
var _desktop_drawn := true
## Frames and their intervals since the last status line.
var _status_frames := 0
var _status_max_usec := 0
## -1 while warming up, SEGMENT_DESKTOP.size() when done.
var _segment := -1
var _warmup_usec := 0
var _seg_usec := 0
var _seg_frames := 0
var _seg_on_time := 0
var _seg_max_usec := 0
var _seg_xr_cpu := 0.0
var _seg_xr_gpu := 0.0
var _seg_root_cpu := 0.0
var _seg_root_gpu := 0.0
var _seg_editor_gpu := 0.0
var _seg_process := 0.0
var _segment_fps: Array[float] = []


func _enter_tree() -> void:
	var xr := XRServer.find_interface("OpenXR") as OpenXRInterface
	var xr_running := xr != null and xr.is_initialized()
	var marked := OS.get_cmdline_user_args().has(IMMERSIVE_ARG)
	_open_log("immersive" if marked or xr_running else "panel")
	_log_environment()
	_log("started by the probe: %s, OpenXR interface found: %s, initialized: %s, native frame loop (XREEditorFrameLoop) %s." % [
		marked, xr != null, xr_running, "loaded" if ClassDB.class_exists(&"XREEditorFrameLoop") else "missing"])
	if not marked and not xr_running:
		add_tool_menu_item(LAUNCH_MENU, _launch_immersive_editor)
		_menu_added = true
		_log("panel editor: use Project → Tools → \"%s\"." % LAUNCH_MENU)
		return
	if not xr_running:
		_log("RESULT: the editor started, but OpenXR is not running. Nothing to show in the headset.")
		return
	_xr = xr
	_log_xr_info()
	_xr.session_begun.connect(_on_session_begun)
	_xr.session_synchronized.connect(_on_session_state.bind("synchronized"))
	_xr.session_visible.connect(_on_session_state.bind("visible"))
	_xr.session_focussed.connect(_on_session_focused)
	_xr.session_stopping.connect(_on_session_ended.bind("stopping"))
	_xr.session_loss_pending.connect(_on_session_ended.bind("loss pending"))
	_xr.instance_exiting.connect(_on_session_ended.bind("instance exiting"))
	_xr.refresh_rate_changed.connect(_on_refresh_rate_changed)
	_log("Output panel collapse button %s." % ("pressed" if _collapse_output() else "not found"))
	_create_xr_view()
	_last_usec = Time.get_ticks_usec()
	_last_status_usec = _last_usec
	# The editor restores the last open scenes after the plugins load.
	get_tree().create_timer(3.0).timeout.connect(_open_probe_scene)
	if OpenXRAPIExtension.new().is_running():
		_on_session_begun()


func _exit_tree() -> void:
	if _menu_added:
		remove_tool_menu_item(LAUNCH_MENU)
		_menu_added = false
	if _xr != null:
		_set_desktop_drawn(true)
		_xr.session_begun.disconnect(_on_session_begun)
		_xr.session_synchronized.disconnect(_on_session_state)
		_xr.session_visible.disconnect(_on_session_state)
		_xr.session_focussed.disconnect(_on_session_focused)
		_xr.session_stopping.disconnect(_on_session_ended)
		_xr.session_loss_pending.disconnect(_on_session_ended)
		_xr.instance_exiting.disconnect(_on_session_ended)
		_xr.refresh_rate_changed.disconnect(_on_refresh_rate_changed)
		_xr = null
	if _viewport != null:
		_viewport.queue_free()
		_viewport = null
	_log("probe stopped.")
	_log_file = null


func _process(_delta: float) -> void:
	if _xr == null:
		return
	# Low-processor mode skips drawing frames that xrWaitFrame has already started.
	if OS.low_processor_usage_mode:
		OS.low_processor_usage_mode = false
	# Real time: the main loop clamps and smooths the delta.
	var now := Time.get_ticks_usec()
	var interval := now - _last_usec
	_last_usec = now
	_status_frames += 1
	_status_max_usec = maxi(_status_max_usec, interval)
	if now - _last_status_usec >= STATUS_INTERVAL * 1000000.0:
		_log_status(now)
	var focused := _xr.get_session_state() == OpenXRInterface.SESSION_STATE_FOCUSED
	# The first interval after focus comes back spans the time without it.
	var counts := focused and _was_focused
	_was_focused = focused
	if not counts or _segment >= SEGMENT_DESKTOP.size():
		return
	if _segment < 0:
		_warmup_usec += interval
		if _warmup_usec >= WARMUP_SEC * 1000000.0:
			_start_segment(0)
		return
	_seg_usec += interval
	_seg_frames += 1
	_seg_max_usec = maxi(_seg_max_usec, interval)
	if interval <= ON_TIME_RATIO * 1000000.0 / _xr.display_refresh_rate:
		_seg_on_time += 1
	_seg_xr_cpu += RenderingServer.viewport_get_measured_render_time_cpu(_viewport.get_viewport_rid())
	_seg_xr_gpu += RenderingServer.viewport_get_measured_render_time_gpu(_viewport.get_viewport_rid())
	_seg_root_cpu += RenderingServer.viewport_get_measured_render_time_cpu(_root_rid)
	_seg_root_gpu += RenderingServer.viewport_get_measured_render_time_gpu(_root_rid)
	# A viewport that isn't drawn keeps its last measurement.
	if _desktop_drawn:
		_seg_editor_gpu += RenderingServer.viewport_get_measured_render_time_gpu(_editor_viewport_rid)
	_seg_process += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	if _seg_usec >= SEGMENT_SEC * 1000000.0:
		_end_segment()
		if _segment + 1 < SEGMENT_DESKTOP.size():
			_start_segment(_segment + 1)
		else:
			_segment = SEGMENT_DESKTOP.size()
			_set_desktop_drawn(true)
			_log_result()


func _launch_immersive_editor() -> void:
	var settings := EditorInterface.get_editor_settings()
	if not settings.get_setting("interface/editor/display/update_continuously"):
		_log("warning: Update Continuously is off. The new editor starts in low-processor mode, and the session may not survive until the probe turns it off.")
	var args := PackedStringArray([
		"--xr-mode", "on", ProjectSettings.globalize_path("res://project.godot"), "--", IMMERSIVE_ARG])
	var instance_id := OS.create_instance(args)
	_log("OS.create_instance(%s) returned %d." % [args, instance_id])


func _create_xr_view() -> void:
	var editor_viewport := EditorInterface.get_editor_viewport_3d(0)
	_viewport = SubViewport.new()
	_viewport.name = "HorizonProbeViewport"
	_viewport.use_xr = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.world_3d = editor_viewport.find_world_3d()
	var origin := XROrigin3D.new()
	var camera := XRCamera3D.new()
	camera.current = true
	origin.add_child(camera)
	_viewport.add_child(origin)
	add_child(_viewport)
	# XROrigin3D publishes its transform only outside the editor.
	XRServer.world_origin = Transform3D.IDENTITY
	_root_rid = get_tree().root.get_viewport_rid()
	_editor_viewport_rid = editor_viewport.get_viewport_rid()
	for rid: RID in [_viewport.get_viewport_rid(), _root_rid, _editor_viewport_rid]:
		RenderingServer.viewport_set_measure_render_time(rid, true)
	_log("XR view created on the 3D editor viewport's World3D.")


## The editor window isn't shown in the immersive activity, yet the editor
## draws its UI into it, and the 3D editor viewports draw the scene for it.
## Hiding the UI's root control stops both: the 3D editor viewports update only
## while visible. The window's viewport itself stays active: the XR viewport is
## its descendant (under this plugin, outside the UI) and isn't drawn without it.
func _set_desktop_drawn(drawn: bool) -> void:
	if drawn == _desktop_drawn:
		return
	_desktop_drawn = drawn
	EditorInterface.get_base_control().visible = drawn


func _start_segment(index: int) -> void:
	_segment = index
	_seg_usec = 0
	_seg_frames = 0
	_seg_on_time = 0
	_seg_max_usec = 0
	_seg_xr_cpu = 0.0
	_seg_xr_gpu = 0.0
	_seg_root_cpu = 0.0
	_seg_root_gpu = 0.0
	_seg_editor_gpu = 0.0
	_seg_process = 0.0
	_set_desktop_drawn(SEGMENT_DESKTOP[index])
	_log("segment %d of %d: editor UI %s, %d focused seconds." % [
		index + 1, SEGMENT_DESKTOP.size(), "shown" if _desktop_drawn else "hidden", roundi(SEGMENT_SEC)])


func _end_segment() -> void:
	var frames := maxi(_seg_frames, 1)
	var fps := _seg_frames / (_seg_usec / 1000000.0)
	_segment_fps.append(fps)
	_log("segment %d done, editor UI %s: %.1f fps at %.0f Hz, %.0f%% of frames on time, mean %.1f ms, max %.1f ms; render ms (CPU/GPU): XR %.2f/%.2f, editor window %.2f/%.2f, 3D editor viewport GPU %.2f; process %.2f ms." % [
		_segment + 1, "shown" if _desktop_drawn else "hidden", fps, _xr.display_refresh_rate,
		100.0 * _seg_on_time / frames, _seg_usec / 1000.0 / frames, _seg_max_usec / 1000.0,
		_seg_xr_cpu / frames, _seg_xr_gpu / frames, _seg_root_cpu / frames, _seg_root_gpu / frames,
		_seg_editor_gpu / frames, _seg_process / frames])


func _log_result() -> void:
	var drawn := 0.0
	var not_drawn := 0.0
	for index: int in SEGMENT_DESKTOP.size():
		if SEGMENT_DESKTOP[index]:
			drawn += _segment_fps[index] / 2.0
		else:
			not_drawn += _segment_fps[index] / 2.0
	_log("RESULT: editor in the immersive activity, focused at %.1f s, session ended %d time(s); %.1f fps with the editor UI shown, %.1f fps hidden, display %.0f Hz. Editor UI shown again." % [
		_focused_at, _session_ends, drawn, not_drawn, _xr.display_refresh_rate])


func _open_probe_scene() -> void:
	var root := EditorInterface.get_edited_scene_root()
	if root == null:
		EditorInterface.open_scene_from_path(SCENE_PATH)
		_log("opened %s." % SCENE_PATH)
	else:
		_log("edited scene: %s." % root.scene_file_path)


## Godot 4.7.2 prints an OpenXR error every frame in the editor. Without
## collapsing, the Output panel slows the editor down once it reaches its line
## limit, about two minutes in (D-004 in the main project). The editor reads the
## setting once at startup, so the probe presses the panel's button itself.
func _collapse_output() -> bool:
	var icon := EditorInterface.get_editor_theme().get_icon(&"CombineLines", &"EditorIcons")
	for node: Node in EditorInterface.get_base_control().find_children("*", "Button", true, false):
		var button := node as Button
		if button.toggle_mode and button.icon == icon:
			button.button_pressed = true
			return true
	return false


func _on_session_begun() -> void:
	_log("session begun.")
	# The window is not shown in the immersive activity; presenting it must not
	# make the main loop wait.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var available := _xr.get_available_display_refresh_rates()
	_log("display %.1f Hz, available %s, V-Sync off, low-processor mode %s." % [
		_xr.display_refresh_rate, available, OS.low_processor_usage_mode])


func _on_session_state(state_name: String) -> void:
	_log("session %s." % state_name)


func _on_session_focused() -> void:
	if _focused_at < 0.0:
		_focused_at = _now()
	_log("session focused.")


func _on_session_ended(reason: String) -> void:
	_session_ends += 1
	_log("session %s." % reason)


func _on_refresh_rate_changed(refresh_rate: float) -> void:
	_log("display refresh rate changed to %.1f Hz." % refresh_rate)


func _log_status(now: int) -> void:
	var seconds := (now - _last_status_usec) / 1000000.0
	var fps := _status_frames / seconds
	var state := _xr.get_session_state()
	_log("%.1f fps, longest frame %.1f ms, session %s, display %.1f Hz, editor UI %s." % [
		fps, _status_max_usec / 1000.0, _STATE_NAMES[state], _xr.display_refresh_rate,
		"shown" if _desktop_drawn else "hidden"])
	if fps < 5.0 and state != OpenXRInterface.SESSION_STATE_FOCUSED:
		_log("frames are stuck: take the headset off and put it back on.")
	_last_status_usec = now
	_status_frames = 0
	_status_max_usec = 0


func _log_environment() -> void:
	var settings := EditorInterface.get_editor_settings()
	var collapse: bool = settings.has_setting("_editor_log_collapse") and settings.get_setting("_editor_log_collapse")
	_log("Godot %s on %s %s, model %s, xr_editor feature %s." % [
		Engine.get_version_info().get("string", "?"), OS.get_name(), OS.get_version(),
		OS.get_model_name(), OS.has_feature("xr_editor")])
	_log("command line %s, user args %s." % [OS.get_cmdline_args(), OS.get_cmdline_user_args()])
	_log("editor hint %s, renderer %s on %s, window %s, low-processor mode %s, Update Continuously %s, Output collapse %s." % [
		Engine.is_editor_hint(), RenderingServer.get_current_rendering_method(),
		RenderingServer.get_video_adapter_name(), DisplayServer.window_get_size(),
		OS.low_processor_usage_mode, settings.get_setting("interface/editor/display/update_continuously"), collapse])


func _log_xr_info() -> void:
	var info := _xr.get_system_info()
	_log("OpenXR runtime %s %s, system %s, render target %s per eye, session %s." % [
		info.get("XRRuntimeName", "?"), info.get("XRRuntimeVersion", "?"), info.get("OpenXRSystemName", "?"),
		_xr.get_render_target_size(), _STATE_NAMES[_xr.get_session_state()]])


func _open_log(role: String) -> void:
	var dir := ProjectSettings.globalize_path(LOG_DIR)
	DirAccess.make_dir_recursive_absolute(dir)
	# Keeps the editor from scanning the logs.
	if not FileAccess.file_exists(dir.path_join(".gdignore")):
		FileAccess.open(dir.path_join(".gdignore"), FileAccess.WRITE).close()
	var stamp := Time.get_datetime_string_from_system().replace(":", "-")
	_log_file = FileAccess.open(dir.path_join("%s_%s.log" % [role, stamp]), FileAccess.WRITE)


func _log(message: String) -> void:
	var line := "HorizonProbe [%.1f s]: %s" % [_now(), message]
	print(line)
	if _log_file != null:
		_log_file.store_line(line)
		_log_file.flush()


func _now() -> float:
	return Time.get_ticks_msec() / 1000.0
