extends Node3D
## Control experiment for the spike: the same Godot build and headset running a
## plain XR game (the setup from Godot's docs), without the editor. If this one
## also loses the OpenXR session, the cause is the setup, not the editor process.
##
## Run: godot --path . --log-file logs/xr_game.log res://benchmarks/xr_game_check.tscn

const STATUS_INTERVAL := 5.0

var _xr: OpenXRInterface


func _ready() -> void:
	_xr = XRServer.find_interface("OpenXR") as OpenXRInterface
	if _xr == null or not _xr.is_initialized():
		_log("OpenXR is not initialized.")
		return
	var info := _xr.get_system_info()
	_log("OpenXR runtime %s %s, system %s, session state %d." % [
		info.get("XRRuntimeName", "?"), info.get("XRRuntimeVersion", "?"), info.get("OpenXRSystemName", "?"),
		_xr.get_session_state()])

	_xr.session_begun.connect(_log.bind("session begun"))
	_xr.session_synchronized.connect(_log.bind("session synchronized"))
	_xr.session_visible.connect(_log.bind("session visible"))
	_xr.session_focussed.connect(_log.bind("session focused"))
	_xr.session_stopping.connect(_log.bind("session stopping"))
	_xr.session_loss_pending.connect(_log.bind("session loss pending"))
	_xr.instance_exiting.connect(_log.bind("instance exiting"))
	_xr.refresh_rate_changed.connect(_on_refresh_rate_changed)

	# As in Godot's XR setup guide: the runtime paces frames, not the monitor.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	get_viewport().use_xr = true

	var timer := Timer.new()
	timer.wait_time = STATUS_INTERVAL
	timer.timeout.connect(_log_status)
	add_child(timer)
	timer.start()


func _on_refresh_rate_changed(refresh_rate: float) -> void:
	_log("display refresh rate changed to %.1f Hz" % refresh_rate)


func _log_status() -> void:
	_log("%d fps, session state %d, display %.1f Hz, controller trackers %s" % [
		roundi(Engine.get_frames_per_second()), _xr.get_session_state(), _xr.display_refresh_rate,
		XRServer.get_trackers(XRServer.TRACKER_CONTROLLER).keys()])


func _log(message: String) -> void:
	print("[%.3f s] XR game check: %s." % [Time.get_ticks_msec() / 1000.0, message])
