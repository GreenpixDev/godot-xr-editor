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
## [br][br]
## Without OpenXR the VR view can run without a headset ([method start_simulator],
## D-057): an [XRESimulator] window with the keyboard and mouse for controllers.

## Emitted when the user closes the window of [method start_simulator].
signal simulator_closed

## Display refresh rate the spike is measured against: 11.1 ms per frame (docs/plan.md).
const TARGET_REFRESH_RATE := 90.0
## Display refresh rate on a standalone headset: the Horizon OS default, the
## one its spike measured (docs/decisions.md, D-017, D-018).
const STANDALONE_REFRESH_RATE := 72.0
## Fixed foveated rendering on a standalone headset, from 0 (off) to 3 (high),
## dynamic: the runtime lowers it while the GPU keeps up. A light costs the
## mobile renderer 3.5–4 ms of GPU time per frame there (D-018).
const STANDALONE_FOVEATION_LEVEL := 3
## Multisampling of the VR view on a standalone headset. The tiled mobile GPU
## resolves it on chip; without it every edge of cards, wires and ports crawls.
const STANDALONE_MSAA := Viewport.MSAA_4X
## Seconds between status lines in the log.
const STATUS_INTERVAL := 5.0
## A main loop step longer than this many display frames counts as late in the status line.
const LATE_FRAME_RATIO := 1.5
## Main loop sleep in low-processor mode while the session is released, in
## microseconds. Unfocused, the editor sleeps 100 ms per step, and the user
## would wait that much longer for the headset to come back after the game.
const RELEASED_SLEEP_USEC := 2000

const _LOG_PREFIX := "XR Editor: "
## Names of [enum OpenXRInterface.SessionState] values, indexed by value.
const _STATE_NAMES: Array[String] = [
	"UNKNOWN", "IDLE", "READY", "SYNCHRONIZED", "VISIBLE",
	"FOCUSED", "STOPPING", "LOSS_PENDING", "EXITING",
]
## Totals the status line reports the growth of, in this order.
const _PIPELINE_MONITORS: Array[Performance.Monitor] = [
	Performance.PIPELINE_COMPILATIONS_DRAW, Performance.PIPELINE_COMPILATIONS_SPECIALIZATION,
	Performance.PIPELINE_COMPILATIONS_SURFACE, Performance.PIPELINE_COMPILATIONS_MESH,
	Performance.PIPELINE_COMPILATIONS_CANVAS,
]

var _xr: OpenXRInterface
var _simulator: XRESimulator
var _viewport: SubViewport
var _rig: XRERig
var _status_timer: Timer
var _vr_loop_active := false
var _saved_max_fps := 0
var _released := false
## A session made by reacquire_session() that hasn't changed state yet: until
## it does, the interface still reports the destroyed session's state.
var _fresh_session := false
## The main loop's low-processor sleep when release_session() was called.
var _released_sleep_before := 0
## What reacquire_session() restores, saved by release_session().
var _released_play_area_mode := XRInterface.XR_PLAY_AREA_UNKNOWN
var _released_size := Vector2.ZERO
## Render target size multiplier before any reacquire_session() changed it.
var _base_size_multiplier := 1.0
var _size_nudged := false
## Main loop steps since the last status line that took longer than
## [constant LATE_FRAME_RATIO] display frames, and the longest step, in seconds.
var _late_frames := 0
var _slowest_frame := 0.0
## [constant _PIPELINE_MONITORS] at the last status line.
var _pipeline_totals := PackedInt64Array([0, 0, 0, 0, 0])
## Fixed 60-second history of focused editor main-loop intervals.
var fps_history := XREFPSHistory.new()
var _fps_previous_usec := 0


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
	if XREStandalone.is_standalone():
		# Vulkan applies the runtime's foveation only to a viewport that asks for it.
		_viewport.vrs_mode = Viewport.VRS_XR
		_viewport.msaa_3d = STANDALONE_MSAA
		_log("VR view MSAA %dx." % (1 << STANDALONE_MSAA))
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
	_hide_desktop_ui(false)
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


func _process(delta: float) -> void:
	var now := Time.get_ticks_usec()
	var focused := has_headset_focus()
	fps_history.record_interval((now - _fps_previous_usec) / 1000000.0 if _fps_previous_usec > 0 else 0.0, now / 1000000.0, focused)
	_fps_previous_usec = now if focused else 0
	if _xr == null:
		return
	if _released:
		# The editor restores its own sleep whenever its window gains or loses
		# the focus, and the game's window takes it.
		OS.low_processor_usage_mode_sleep_usec = RELEASED_SLEEP_USEC
		return
	# While the session runs, xrWaitFrame paces the main loop: a step longer
	# than a display frame is a frame the headset didn't get in time.
	if delta > _slowest_frame:
		_slowest_frame = delta
	if delta * _xr.display_refresh_rate > LATE_FRAME_RATIO:
		_late_frames += 1


## The OpenXR interface while the VR view is on, otherwise null.
func get_xr_interface() -> OpenXRInterface:
	return _xr


## Starts the VR view without a headset (D-057), if OpenXR isn't running:
## [method get_rig] is then the simulator's. False if there is a VR view already.
func start_simulator() -> bool:
	if _xr != null or _simulator != null:
		return false
	var editor_viewport := EditorInterface.get_editor_viewport_3d(0)
	if editor_viewport == null:
		_log("no 3D editor viewport, no VR view without a headset.")
		return false
	_simulator = XRESimulator.new(editor_viewport.find_world_3d())
	_simulator.closed.connect(simulator_closed.emit)
	_rig = _simulator.rig
	add_child(_simulator)
	var camera := editor_viewport.get_camera_3d()
	if camera != null:
		# Where the desktop 3D view looks from.
		_simulator.look_from(camera.global_transform)
	return true


## Closes the VR view without a headset, and the tools under its rig with it.
func stop_simulator() -> void:
	if _simulator == null:
		return
	_simulator.queue_free()
	_simulator = null
	_rig = null


## Whether the VR view runs without a headset ([method start_simulator]).
func is_simulating() -> bool:
	return _simulator != null


## The VR view without a headset, or null.
func get_simulator() -> XRESimulator:
	return _simulator


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


## Whether the headset shows the editor and sends it the controllers' input:
## not while a game, the system menu or another application has the headset,
## nor while the session is released. Without a headset: while the
## simulator's window has the keyboard.
func has_headset_focus() -> bool:
	if _simulator != null:
		return _simulator.has_focus()
	return _xr != null and not _released and not _fresh_session \
			and _xr.get_session_state() == OpenXRInterface.SESSION_STATE_FOCUSED


## Status for UI sampled at low frequency, matching the log's state vocabulary.
func session_state_text() -> String:
	if _simulator != null: return "SIMULATED"
	if _xr == null: return "OFF"
	if _released: return "RELEASED"
	return _STATE_NAMES[_xr.get_session_state()]


## Whether a game may take the headset while the editor keeps its session in
## the background (yield, docs/decisions.md, D-004). Not on SteamVR: it runs
## one XR application at a time, asks the editor to quit when a game takes the
## headset and kills it 5 s later ([XREHandoffBenchmark]); there the editor
## releases its session for the game instead (D-012). Only Meta Link and
## SteamVR were tried; other runtimes are assumed to behave like Meta Link.
## Without a headset there is nothing to give up: the game runs on the desktop.
func can_yield_headset() -> bool:
	if _xr == null:
		return _simulator != null
	var runtime: String = _xr.get_system_info().get("XRRuntimeName", "")
	return not runtime.begins_with("SteamVR")


## Whether a game run from the headset replaces this editor's process, and the
## editor opens again after the game: on a standalone headset the editor runs
## in the one activity XR games run in (docs/decisions.md, D-018). Checked
## before [method can_yield_headset].
func game_replaces_editor() -> bool:
	return XREStandalone.is_standalone()


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
	_released_sleep_before = OS.low_processor_usage_mode_sleep_usec
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
	_fresh_session = true
	OS.low_processor_usage_mode_sleep_usec = _released_sleep_before
	_log("OpenXR session created again, render target %s per eye." % _xr.get_render_target_size())
	# A game run as another application (D-012) had the desktop focus; on Meta
	# Link the game runs inside the editor's window and the focus stays there.
	if not DisplayServer.window_is_focused():
		DisplayServer.window_move_to_foreground()
	return true


func _on_session_begun() -> void:
	_fresh_session = false
	_log("session begun.")
	_request_refresh_rate()
	_enter_vr_frame_loop()
	_check_output_collapse()
	_hide_desktop_ui(true)
	_enable_foveation()


## Godot 4.7.2 prints an OpenXR error every frame in the editor. Without
## collapsing, each one adds a line to the Output panel, and past its line limit
## every message costs milliseconds: the editor drops below 90 Hz after about two
## minutes (docs/decisions.md, D-004).
## On a standalone headset nobody sees that panel, so the session presses its
## button itself: the editor reads the setting only at startup.
func _check_output_collapse() -> void:
	var settings := EditorInterface.get_editor_settings()
	if settings.has_setting("_editor_log_collapse") and settings.get_setting("_editor_log_collapse"):
		return
	if XREStandalone.is_standalone() and _press_output_collapse():
		_log("collapsed duplicate messages in the Output panel.")
		return
	push_warning("XR Editor: turn on \"Collapse duplicate messages\" in the Output panel, "
			+ "otherwise the editor drops below 90 Hz after about two minutes in VR (docs/decisions.md, D-004).")


## On a standalone headset nobody sees the editor's 2D window, yet every frame
## it would draw its UI and render the scene once more in the 3D editor
## viewports. There the editor spends about 13 ms more GPU time per frame than
## the game on the same scene (benchmarks/results/quest_fps_*, D-018), and this
## is the part nobody needs. Hidden while the session runs; the
## 3D editor viewports update only while visible, so they stop as well, and the
## headset's view, outside the UI, stays. Not on a PC, where the window is the
## way back to the desktop.
func _hide_desktop_ui(hidden: bool) -> void:
	if not XREStandalone.is_standalone():
		return
	EditorInterface.get_base_control().visible = not hidden
	_log("editor's 2D window %s." % ("hidden while the session runs" if hidden else "shown"))


## On a standalone headset, where the GPU is the limit, shades the edges of
## the view coarser ([constant STANDALONE_FOVEATION_LEVEL]). Not on a PC: the
## study's frame budget is measured there without it.
func _enable_foveation() -> void:
	if not XREStandalone.is_standalone():
		return
	if not _xr.is_foveation_supported():
		_log("the runtime offers no foveated rendering.")
		return
	_xr.foveation_level = STANDALONE_FOVEATION_LEVEL
	_xr.foveation_dynamic = true
	_log("foveated rendering on: level %d, dynamic." % _xr.foveation_level)


## Presses the Output panel's toggle that collapses duplicate messages, found
## by its icon (its tooltip is translated). Returns whether it was found.
func _press_output_collapse() -> bool:
	var icon := EditorInterface.get_editor_theme().get_icon(&"CombineLines", &"EditorIcons")
	for node: Node in EditorInterface.get_base_control().find_children("*", "Button", true, false):
		var button := node as Button
		if button.toggle_mode and button.icon == icon:
			button.button_pressed = true
			return true
	return false


func _on_session_state(state_name: String) -> void:
	_fresh_session = false
	_log("session %s." % state_name)


func _on_session_ended(reason: String) -> void:
	_log("session %s." % reason)
	# Emitted while OpenXR handles the state change, before the next xrWaitFrame
	# would run, so restoring low-processor mode here can't break a frame.
	_exit_vr_frame_loop(true)
	_hide_desktop_ui(false)


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
	var target := STANDALONE_REFRESH_RATE if XREStandalone.is_standalone() else TARGET_REFRESH_RATE
	for rate: float in available:
		if is_equal_approx(rate, target) and not is_equal_approx(_xr.display_refresh_rate, rate):
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
		_late_frames = 0
		_slowest_frame = 0.0
		return
	var state := _xr.get_session_state()
	var controllers := XRServer.get_trackers(XRServer.TRACKER_CONTROLLER)
	_log("%d fps, %d frame(s) late, slowest %.1f ms, session %s, display %.1f Hz, editor window focused %s, controller trackers %s, low-processor mode %s." % [
		roundi(Engine.get_frames_per_second()), _late_frames, _slowest_frame * 1000.0, _STATE_NAMES[state],
		_xr.display_refresh_rate, DisplayServer.window_is_focused(), controllers.keys(), OS.low_processor_usage_mode])
	_late_frames = 0
	_slowest_frame = 0.0
	_log_pipeline_compilations()


## Pipeline compilations since the last status line, if there were any. A new
## kind of thing on screen (a light, a material) needs new pipelines; until
## they compile in the background the renderer draws with slower general shaders
## (the SPECIALIZATION counter), and drawing may wait for one (DRAW).
func _log_pipeline_compilations() -> void:
	var counts := PackedInt64Array()
	var changed := false
	for index: int in _PIPELINE_MONITORS.size():
		var total := int(Performance.get_monitor(_PIPELINE_MONITORS[index]))
		counts.append(total - _pipeline_totals[index])
		changed = changed or total != _pipeline_totals[index]
		_pipeline_totals[index] = total
	if changed:
		_log("pipelines compiled: %d for drawing, %d specialized in the background, %d for surfaces, %d for meshes, %d for 2D." % [
			counts[0], counts[1], counts[2], counts[3], counts[4]])


func _log(message: String) -> void:
	print(_LOG_PREFIX, message)
