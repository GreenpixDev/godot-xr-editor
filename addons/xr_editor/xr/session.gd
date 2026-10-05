@tool
class_name XRESession
extends Node
## Runs the VR view inside the editor process while OpenXR is active.
##
## The editor starts OpenXR only when launched with [code]--xr-mode on[/code];
## otherwise this node stays dormant and leaves the desktop editor untouched.
## The VR view is a [SubViewport] with [member Viewport.use_xr] that renders the
## same [World3D] as the desktop 3D viewport, so there is nothing to copy or sync.
## While the session runs, the main loop is paced by the headset alone:
## window V-Sync is off, and the native XREEditorFrameLoop keeps low-processor
## mode off (it must be, from the first frame, or the runtime drops the session).
## After the session ends, both are restored from the editor settings.

## Display refresh rate the spike is measured against: 11.1 ms per frame (docs/plan.md).
const TARGET_REFRESH_RATE := 90.0
## Seconds between status lines in the log.
const STATUS_INTERVAL := 5.0

const _LOG_PREFIX := "XR Editor: "
## Names of [enum OpenXRInterface.SessionState] values, indexed by value.
const _STATE_NAMES: Array[String] = [
	"UNKNOWN", "IDLE", "READY", "SYNCHRONIZED", "VISIBLE",
	"FOCUSED", "STOPPING", "LOSS_PENDING", "EXITING",
]

var _xr: OpenXRInterface
var _viewport: SubViewport
var _rig: XRERig
var _status_timer: Timer
var _vr_loop_active := false
var _saved_max_fps := 0
var _released := false
## What reacquire_session() restores, saved by release_session().
var _released_play_area_mode := XRInterface.XR_PLAY_AREA_UNKNOWN
var _released_size := Vector2.ZERO
## Render target size multiplier before any reacquire_session() changed it.
var _base_size_multiplier := 1.0
var _size_nudged := false


func _enter_tree() -> void:
	var xr := XRServer.find_interface("OpenXR") as OpenXRInterface
	if xr == null or not xr.is_initialized():
		_log("OpenXR is not running, VR view is off. Start the editor with --xr-mode on to enable it.")
		return
	var editor_viewport := EditorInterface.get_editor_viewport_3d(0)
	if editor_viewport == null:
		_log("no 3D editor viewport, VR view is off.")
		return
	_xr = xr
	_log_system_info()

	_xr.session_begun.connect(_on_session_begun)
	_xr.session_synchronized.connect(_on_session_state.bind("synchronized"))
	_xr.session_visible.connect(_on_session_state.bind("visible"))
	_xr.session_focussed.connect(_on_session_state.bind("focused"))
	_xr.session_stopping.connect(_on_session_ended.bind("stopping"))
	_xr.session_loss_pending.connect(_on_session_ended.bind("loss pending"))
	_xr.instance_exiting.connect(_on_session_ended.bind("instance exiting"))
	_xr.refresh_rate_changed.connect(_on_refresh_rate_changed)
	_xr.pose_recentered.connect(_on_pose_recentered)

	_viewport = SubViewport.new()
	_viewport.name = "XREViewport"
	_viewport.use_xr = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.world_3d = editor_viewport.find_world_3d()
	_rig = XRERig.new()
	_viewport.add_child(_rig)
	add_child(_viewport)

	_status_timer = Timer.new()
	_status_timer.wait_time = STATUS_INTERVAL
	_status_timer.timeout.connect(_log_status)
	add_child(_status_timer)
	_status_timer.start()

	# The session usually begins while the editor is still loading, before plugins.
	if OpenXRAPIExtension.new().is_running():
		_on_session_begun()


func _exit_tree() -> void:
	if _xr == null:
		return
	# The session keeps running without the plugin, so low-processor mode stays off.
	_exit_vr_frame_loop(false)
	if _released and not EditorInterface.is_playing_scene():
		reacquire_session()
	_xr.session_begun.disconnect(_on_session_begun)
	_xr.session_synchronized.disconnect(_on_session_state)
	_xr.session_visible.disconnect(_on_session_state)
	_xr.session_focussed.disconnect(_on_session_state)
	_xr.session_stopping.disconnect(_on_session_ended)
	_xr.session_loss_pending.disconnect(_on_session_ended)
	_xr.instance_exiting.disconnect(_on_session_ended)
	_xr.refresh_rate_changed.disconnect(_on_refresh_rate_changed)
	_xr.pose_recentered.disconnect(_on_pose_recentered)
	_viewport.queue_free()
	_status_timer.queue_free()
	_viewport = null
	_rig = null
	_status_timer = null
	_xr = null
	_log("VR view closed.")


## The OpenXR interface while the VR view is on, otherwise null.
func get_xr_interface() -> OpenXRInterface:
	return _xr


## The headset's viewport while the VR view is on, otherwise null.
func get_xr_viewport() -> SubViewport:
	return _viewport


## The user's head and controllers while the VR view is on, otherwise null.
## Tools that draw in the headset go under it.
func get_rig() -> XRERig:
	return _rig


## Whether [method release_session] gave the headset up and
## [method reacquire_session] hasn't taken it back yet.
func is_session_released() -> bool:
	return _released


## Destroys the editor's OpenXR session so that a game process can take the
## headset on a runtime that allows one XR application at a time: SteamVR asks
## the previous one to quit and kills it 5 s later. The OpenXR instance stays,
## and [method reacquire_session] creates a new session on it.
## [br][br]
## Godot 4.7.2 has no API for this. [method XRInterface.initialize] on an
## uninitialized interface whose session still exists fails in
## [code]OpenXRAPI::create_session[/code], and [code]initialize_session[/code]
## destroys that session on the way out: the same path a quitting game takes.
## The engine prints two errors for it: [code]Condition "session != nullptr" is true[/code]
## and, from its spatial entity extension, an attempt to disconnect a nonexistent connection.
## [br][br]
## SteamVR files the game under the editor's application (they share the
## executable) and clears that application's process when the game quits.
## [method reacquire_session] then succeeds only if it comes before SteamVR's
## "no more scene app" transition, which starts about 25 ms after the game's
## process is gone (observed 2026-10-05, SteamVR 2.17.10).
func release_session() -> bool:
	if _xr == null or _released:
		return false
	_released_play_area_mode = _xr.xr_play_area_mode
	_released_size = _xr.get_render_target_size()
	if not _size_nudged:
		_base_size_multiplier = _xr.render_target_size_multiplier
	_exit_vr_frame_loop(true)
	_xr.uninitialize()
	var created := _xr.initialize() # Fails on purpose and destroys the session.
	var session_left := OpenXRAPIExtension.new().get_session()
	if created or session_left != 0:
		_log("could not release the OpenXR session (initialize %s, session %d)." % [created, session_left])
		return false
	_released = true
	_log("OpenXR session released.")
	return true


## Creates a new OpenXR session after [method release_session]. The runtime
## starts it from IDLE; the VR view comes back with [signal OpenXRInterface.session_begun].
## [br][br]
## Godot 4.7.2 doesn't reset everything a new session needs, so two settings are
## written again before [method XRInterface.initialize]:
## [br]- the play area mode: the engine creates the play space only when the
## requested reference space changes;
## [br]- the render target size multiplier: the engine creates the headset's
## swapchains only when their size changes, and still holds the old size. It
## alternates between the original and a 1-pixel larger size, so every other
## session renders 1 pixel wider.
func reacquire_session() -> bool:
	if not _released:
		return false
	var nudge := not _size_nudged
	_xr.render_target_size_multiplier = _base_size_multiplier * (1.0 + 1.5 / _released_size.x) \
			if nudge else _base_size_multiplier
	_xr.xr_play_area_mode = _released_play_area_mode
	if not _xr.initialize():
		# Still released: a later call may succeed.
		_log("could not create a new OpenXR session.")
		return false
	_size_nudged = nudge
	_released = false
	_log("OpenXR session created again, render target %s per eye." % _xr.get_render_target_size())
	return true


func _on_session_begun() -> void:
	_log("session begun.")
	_request_refresh_rate()
	_enter_vr_frame_loop()
	_check_output_collapse()


## Godot 4.7.2 prints an OpenXR error every frame in the editor. Without
## collapsing, each one adds a line to the Output panel, and past its line limit
## every message costs milliseconds: the editor drops below 90 Hz after about two
## minutes (docs/decisions.md, D-004).
func _check_output_collapse() -> void:
	var settings := EditorInterface.get_editor_settings()
	if settings.has_setting("_editor_log_collapse") and settings.get_setting("_editor_log_collapse"):
		return
	push_warning("XR Editor: turn on \"Collapse duplicate messages\" in the Output panel, "
			+ "otherwise the editor drops below 90 Hz after about two minutes in VR (docs/decisions.md, D-004).")


func _on_session_state(state_name: String) -> void:
	_log("session %s." % state_name)


func _on_session_ended(reason: String) -> void:
	_log("session %s." % reason)
	# Emitted while OpenXR handles the state change, before the next xrWaitFrame
	# would run, so restoring low-processor mode here can't break a frame.
	_exit_vr_frame_loop(true)


func _on_refresh_rate_changed(refresh_rate: float) -> void:
	_log("display refresh rate changed to %.1f Hz." % refresh_rate)


func _on_pose_recentered() -> void:
	_log("pose recentered.")


## Turns off what throttles the editor's main loop besides low-processor mode
## (the native library handles that): window V-Sync would make every frame
## wait for the desktop monitor. [member Engine.max_fps] is not applied in the
## editor in 4.7.2 and is reset only for symmetry with the runtime fallback.
func _enter_vr_frame_loop() -> void:
	if _vr_loop_active:
		return
	_vr_loop_active = true
	_saved_max_fps = Engine.max_fps
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	_log("VR frame loop on: V-Sync off, max_fps 0 (was %d), low-processor mode %s."
			% [_saved_max_fps, OS.low_processor_usage_mode])


## Restores the editor's own frame pacing from its settings. Low-processor mode
## only with [param session_ended]: while the session runs it must stay off.
func _exit_vr_frame_loop(session_ended: bool) -> void:
	if not _vr_loop_active:
		return
	_vr_loop_active = false
	var settings := EditorInterface.get_editor_settings()
	var vsync_mode: DisplayServer.VSyncMode = settings.get_setting("interface/editor/display/vsync_mode")
	DisplayServer.window_set_vsync_mode(vsync_mode)
	Engine.max_fps = _saved_max_fps
	if session_ended:
		var update_continuously: bool = settings.get_setting("interface/editor/display/update_continuously")
		OS.low_processor_usage_mode = not update_continuously
	_log("VR frame loop off: V-Sync mode %d, low-processor mode %s." % [vsync_mode, OS.low_processor_usage_mode])


func _request_refresh_rate() -> void:
	var available := _xr.get_available_display_refresh_rates()
	_log("display refresh rate %.1f Hz, available %s." % [_xr.display_refresh_rate, available])
	for rate: float in available:
		if is_equal_approx(rate, TARGET_REFRESH_RATE) and not is_equal_approx(_xr.display_refresh_rate, rate):
			_log("requesting %.1f Hz." % rate)
			_xr.display_refresh_rate = rate


func _log_system_info() -> void:
	var info := _xr.get_system_info()
	_log("OpenXR runtime %s %s, system %s." % [
		info.get("XRRuntimeName", "?"), info.get("XRRuntimeVersion", "?"), info.get("OpenXRSystemName", "?")])
	_log("render target %s per eye, play area mode %d, action sets %s." % [
		_xr.get_render_target_size(), _xr.xr_play_area_mode, _xr.get_action_sets()])


func _log_status() -> void:
	if _released:
		# Display refresh rate and session state would come from the destroyed session.
		_log("%d fps, OpenXR session released, low-processor mode %s." % [
			roundi(Engine.get_frames_per_second()), OS.low_processor_usage_mode])
		return
	var state := _xr.get_session_state()
	var controllers := XRServer.get_trackers(XRServer.TRACKER_CONTROLLER)
	_log("%d fps, session %s, display %.1f Hz, controller trackers %s, low-processor mode %s." % [
		roundi(Engine.get_frames_per_second()), _STATE_NAMES[state], _xr.display_refresh_rate,
		controllers.keys(), OS.low_processor_usage_mode])


func _log(message: String) -> void:
	print(_LOG_PREFIX, message)
