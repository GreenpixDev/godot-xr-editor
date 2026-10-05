extends Node3D
## Game side of the play-mode handoff measurement (XREHandoffBenchmark): a plain
## XR game that takes the headset, stays [constant PLAY_SEC] and quits, writing the
## system-clock time of every step to [constant TIMELINE] for the editor to read.
## The system clock is shared by both processes; engine ticks are not.

const PLAY_SEC := 5.0
## Quits anyway if the headset never comes to this game.
const GIVE_UP_SEC := 30.0
## The editor and a game run from it share user://.
const TIMELINE := "user://xre_handoff_game.json"

var _xr: OpenXRInterface
var _events := {}


func _ready() -> void:
	_mark("ready")
	_xr = XRServer.find_interface("OpenXR") as OpenXRInterface
	if _xr == null or not _xr.is_initialized():
		_mark("no_openxr")
		_quit()
		return
	_xr.session_begun.connect(_mark.bind("session_begun"))
	_xr.session_visible.connect(_mark.bind("visible"))
	_xr.session_focussed.connect(_on_focused)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	get_viewport().use_xr = true
	get_tree().create_timer(GIVE_UP_SEC).timeout.connect(_quit)


func _on_focused() -> void:
	if _events.has("focused"):
		return
	_mark("focused")
	get_tree().create_timer(PLAY_SEC).timeout.connect(_quit)


## Keeps the first time of each event.
func _mark(event: String) -> void:
	if not _events.has(event):
		_events[event] = Time.get_unix_time_from_system()


func _quit() -> void:
	if _events.has("quit"):
		return
	_mark("quit")
	var file := FileAccess.open(TIMELINE, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_events))
	get_tree().quit()
