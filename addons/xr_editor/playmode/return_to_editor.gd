extends Node3D
## Game side of play mode (docs/decisions.md, D-011): holding Y on the left
## controller for [constant HOLD_SEC] quits the game, and the editor, whose OpenXR session
## waited in the background, gets the headset back.
##
## The plugin registers this script as an autoload ([constant XREPlayMode.RETURN_AUTOLOAD]),
## so it runs in every game of the project. It stays only in a game the
## editor ran while its VR view was on ([constant GAME_FLAG] on the command
## line) and only with OpenXR running; anywhere else, exported games included,
## it frees itself at start. Not a tool script: it never runs in the editor.
## [br][br]
## The game itself still gets the button, so a short press can open its own
## menu. A hold longer than [constant SHOW_AFTER_SEC] shows a bar in front of
## the user that fills up until the game quits. The button is read from the
## game's own action map; Godot's default one names it [constant BUTTON] and
## binds it to Y on the left Touch and Pico 4 controllers.

## Command-line argument the editor adds to the games it runs while its VR view is on.
const GAME_FLAG := "--xre-play"
## Input of the left controller's tracker that returns to the editor when held.
## Not Menu: SteamVR keeps the left Menu button for its dashboard.
const BUTTON := &"by_button"
## Tracker of the controller that has the button.
const HAND := &"left_hand"
## How long the button must be held, in seconds.
const HOLD_SEC := 1.0
## A hold shorter than this shows nothing: a tap is meant for the game.
const SHOW_AFTER_SEC := 0.2
## Where the bar is, in the head's space.
const _OFFSET := Transform3D(Basis.IDENTITY, Vector3(0.0, -0.1, -0.6))
const _BAR_SIZE := Vector3(0.2, 0.012, 0.002)
## Render layers 1–20, so that the game's camera shows the bar whatever its cull mask.
const _ALL_LAYERS := (1 << 20) - 1
const _LOG_PREFIX := "XR Editor: "

var _xr: OpenXRInterface
## The button was seen up while the game had the headset; see [method advance].
var _armed := false
## [method Time.get_ticks_usec] when the current hold began, or -1.
var _hold_start_usec := -1
var _fill: MeshInstance3D
## In a game the VR editor ran; see the class description.
var _active := false


func _ready() -> void:
	_xr = XRServer.find_interface("OpenXR") as OpenXRInterface
	if not OS.get_cmdline_args().has(GAME_FLAG) or _xr == null or not _xr.is_initialized():
		queue_free()
		return
	_active = true
	# Quitting from the runtime's own menu: SteamVR kills an application that
	# doesn't quit within 5 s, and the editor would wait for the headset that long.
	_xr.instance_exiting.connect(get_tree().quit)
	# The hold must work in a paused game too; it is timed by the clock, not by delta.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_add_bar(Color(0.0, 0.0, 0.0, 0.6), 0)
	_fill = _add_bar(Color(1.0, 0.6, 0.2), 1)
	var label := Label3D.new()
	label.text = "Back to the editor"
	label.position = Vector3(0.0, 0.03, 0.0)
	label.font_size = 32
	label.pixel_size = 0.0004
	label.outline_size = 8
	label.no_depth_test = true
	label.render_priority = 2
	label.outline_render_priority = 1
	label.layers = _ALL_LAYERS
	label.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(label)


func _process(_delta: float) -> void:
	var now := Time.get_ticks_usec()
	var focused := _xr.get_session_state() == OpenXRInterface.SESSION_STATE_FOCUSED
	var progress := advance(focused, _button_held(), now)
	if progress >= 1.0:
		_quit("returning to the editor.")
	elif progress * HOLD_SEC >= SHOW_AFTER_SEC:
		_show_progress(progress)
	else:
		visible = false


## Advances the hold by one frame and returns how far it got, from 0 to 1, or
## a negative value while no hold counts. A hold counts only if the button
## went down while the game had the headset: it may still be down from the
## press in the editor that started the game.
func advance(focused: bool, held: bool, now_usec: int) -> float:
	if not focused or not held:
		_armed = focused
		_hold_start_usec = -1
		return -1.0
	if not _armed:
		return -1.0
	if _hold_start_usec < 0:
		_hold_start_usec = now_usec
	return minf((now_usec - _hold_start_usec) / (HOLD_SEC * 1000000.0), 1.0)


func _quit(reason: String) -> void:
	print(_LOG_PREFIX, reason)
	set_process(false)
	get_tree().quit()


func _button_held() -> bool:
	var tracker := XRServer.get_tracker(HAND) as XRPositionalTracker
	if tracker == null:
		return false
	var value: Variant = tracker.get_input(BUTTON)
	return value is bool and value


## Puts the bar in front of the head, filled to [param progress].
func _show_progress(progress: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		visible = false
		return
	global_transform = camera.global_transform * _OFFSET
	_fill.scale.x = maxf(progress, 0.001)
	_fill.position.x = -_BAR_SIZE.x * (1.0 - progress) / 2.0
	visible = true


## A bar drawn over the game's geometry, [param priority] deciding which of two bars is on top.
func _add_bar(color: Color, priority: int) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = _BAR_SIZE
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = true
	material.render_priority = priority
	var bar := MeshInstance3D.new()
	bar.mesh = mesh
	bar.material_override = material
	bar.layers = _ALL_LAYERS
	bar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(bar)
	return bar
