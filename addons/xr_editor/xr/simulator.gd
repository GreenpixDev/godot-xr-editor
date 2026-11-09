@tool
class_name XRESimulator
extends Node
## The VR view without a headset (docs/decisions.md, D-057): a window of its own
## shows what the head camera of an [XRERig] sees, and the keyboard and mouse
## drive fake controller trackers, so the tools under the rig can't tell them
## from real ones.
##
## One hand is active at a time. Its ray leaves the eye along the gaze, so it
## always points at the middle of the view; the mouse looks around, the left
## button is its trigger and the right one its grip. The eye sits inside that
## ray, so what shows is a beam from the controller to where the ray ends
## ([constant BEAM_KEY] turns it off); what the ray hits is what lies under the
## cross in the middle. The other hand rests low at its side and points down
## and out, off the middle of the view. A hand left while its trigger or grip is held
## stays where it was and keeps holding, so two-handed gestures work: grab
## with one hand, switch, grab with the other. A hand switched to counts a
## mouse button only once it was up since the switch, unless the hand was
## already holding with it. The buttons of both controllers are keys
## ([constant BUTTON_KEYS]); the left stick is WASD, the right one the arrows,
## and the mouse wheel tilts the active hand's stick forward and back. WASD
## flies where the view looks, at the cross, whichever hand is active
## ([member XRERig.fly_along_gaze]).
## [br][br]
## Keys count by their place on the keyboard, not by their letter, so the
## layout of the keyboard (Russian, say) doesn't matter. The mouse is captured
## by a click in the window and let go with Esc or when the window loses focus;
## while it is free, the buttons and the look do nothing. Losing focus lets go of
## every key and button. While the simulator runs, the editor's main loop doesn't sleep
## between frames (low-processor mode off), as with a headset.
## [br][br]
## Without a window ([code]windowed = false[/code], in tests) the rig renders
## into a [SubViewport] and events come through [method handle_input], with the
## mouse taken as captured.

## Emitted when the user closes the window.
signal closed

## Height of the eyes above the rig's origin, in meters.
const HEAD_HEIGHT := 1.6
## Vertical field of view of the window, in degrees.
const FOV := 80.0
const WINDOW_SIZE := Vector2i(1280, 800)
## How far the view turns per pixel of mouse movement, in degrees.
const LOOK_DEGREES_PER_PIXEL := 0.15
## How far the view tilts up or down, in degrees.
const PITCH_LIMIT := 89.0
## Where a controller is held relative to the eyes: the right one; the left one
## mirrored. The model of the active one shows there, low in the corner of the
## view, and touches what is there.
const HAND_OFFSET := Vector3(0.2, -0.32, -0.4)
## How the other hand rests: pointing down and out from the gaze, in degrees,
## so that its ray doesn't cross the middle of the view.
const REST_PITCH := -35.0
const REST_YAW := 12.0
## How far behind the eye the active hand's ray starts, in meters. The camera
## is inside the ray, which shows only its hit dot then.
const RAY_BACK := 0.02
## Where the beam of the active hand leaves its controller, in the grip pose's space: the tip.
const BEAM_START := Vector3(0.0, -0.01, -0.07)
const BEAM_WIDTH := 0.004
## How far the active hand reaches out along the gaze, and how fast, in meters
## and meters per second: [constant REACH_OUT_KEY] and [constant REACH_IN_KEY].
const MAX_REACH := 0.6
const REACH_SPEED := 0.5
## How far a notch of the mouse wheel with Ctrl rolls the active hand's wrist, in degrees.
const ROLL_STEP := 15.0
## How long a notch of the mouse wheel tilts the stick all the way, in seconds.
const WHEEL_TILT_SEC := 0.15
## Keys of the controllers' buttons, by [constant XREFeatureSettings.BUTTONS]
## key, by place on a US keyboard.
const BUTTON_KEYS: Dictionary[StringName, Key] = {
	&"left_menu": KEY_TAB,
	&"left_x": KEY_X,
	&"left_y": KEY_Y,
	&"left_stick": KEY_SHIFT,
	&"right_a": KEY_E,
	&"right_b": KEY_B,
	&"right_stick": KEY_C,
}
const SWITCH_HAND_KEY := KEY_Q
const BEAM_KEY := KEY_V
const REACH_OUT_KEY := KEY_R
const REACH_IN_KEY := KEY_F
const HELP_KEY := KEY_F1
const SHOT_KEY := KEY_F12
## Where [constant SHOT_KEY] saves pictures of the view.
const SHOTS_FOLDER := "res://build/shots"
## The keys that aren't controller buttons, for the help and the controls page.
const HELP := """Mouse: look · LMB: trigger · RMB: grip (active hand)
Q: switch hand · V: beam on / off · R / F: reach out / in · Ctrl+wheel: roll wrist, MMB: straighten
WASD: left stick (fly) · arrows: right stick (turn) · wheel: active stick forward / back
Esc: free the mouse · F1: help · F12: picture of the view"""

const _PROFILE := "/interaction_profiles/oculus/touch_controller"
const _HANDS: Array[StringName] = [&"left_hand", &"right_hand"]
const _LOG_PREFIX := "XR Editor: no headset: "

## The user's head and controllers.
var rig: XRERig
## The window showing the view, or null without one.
var window: Window
## The beam from the active controller to the end of its ray shows ([constant BEAM_KEY]).
var beam_on := true

var _viewport: Viewport
var _hud: _Hud
var _beam: _Beam
var _trackers: Dictionary[StringName, XRControllerTracker] = {}
var _active := &"right_hand"
var _yaw := 0.0
var _pitch := 0.0
var _reach := 0.0
var _roll: Dictionary[StringName, float] = {&"left_hand": 0.0, &"right_hand": 0.0}
## The poses each hand had in the last frame, in the rig's space.
var _aim: Dictionary[StringName, Transform3D] = {}
var _grip: Dictionary[StringName, Transform3D] = {}
## A hand left while holding: it stays put and keeps its trigger and grip.
var _frozen: Dictionary[StringName, bool] = {&"left_hand": false, &"right_hand": false}
var _trigger: Dictionary[StringName, bool] = {&"left_hand": false, &"right_hand": false}
var _grip_held: Dictionary[StringName, bool] = {&"left_hand": false, &"right_hand": false}
var _keys: Dictionary[Key, bool] = {}
var _mouse_trigger := false
var _mouse_grip := false
## The mouse button counts for the active hand: it was up since the hand was switched to.
var _trigger_armed := true
var _grip_armed := true
var _wheel := 0.0
var _wheel_until_usec := 0
var _captured := false
var _low_processor_before := false


## [param world] is the world the view shows: the editor's.
func _init(world: World3D, windowed: bool = true) -> void:
	name = "XRESimulator"
	rig = XRERig.new()
	rig.camera.fov = FOV
	rig.fly_along_gaze = true
	_hud = _Hud.new(self)
	if windowed:
		window = Window.new()
		window.name = "XRESimulatorWindow"
		window.title = "XR Editor — no headset"
		window.size = WINDOW_SIZE
		window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
		window.wrap_controls = false
		window.close_requested.connect(closed.emit)
		window.window_input.connect(handle_input)
		window.focus_exited.connect(_let_go)
		_viewport = window
	else:
		var viewport := SubViewport.new()
		viewport.size = WINDOW_SIZE
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		_viewport = viewport
		_captured = true
	_viewport.world_3d = world
	_viewport.msaa_3d = Viewport.MSAA_4X
	_viewport.add_child(rig)
	_beam = _Beam.new(self)
	rig.add_child(_beam)
	_viewport.add_child(_hud)
	add_child(_viewport)
	for hand: StringName in _HANDS:
		var tracker := XRControllerTracker.new()
		tracker.name = hand
		tracker.type = XRServer.TRACKER_CONTROLLER
		tracker.hand = XRPositionalTracker.TRACKER_HAND_LEFT if hand == &"left_hand" else XRPositionalTracker.TRACKER_HAND_RIGHT
		tracker.profile = _PROFILE
		_trackers[hand] = tracker
	_update_poses()


func _enter_tree() -> void:
	for hand: StringName in _HANDS:
		XRServer.add_tracker(_trackers[hand])
	_low_processor_before = OS.low_processor_usage_mode
	OS.low_processor_usage_mode = false
	rig.camera.current = true
	print(_LOG_PREFIX, "VR view in a window, keyboard and mouse for controllers.")


func _exit_tree() -> void:
	_let_go()
	for hand: StringName in _HANDS:
		XRServer.remove_tracker(_trackers[hand])
	OS.low_processor_usage_mode = _low_processor_before
	print(_LOG_PREFIX, "closed.")


## Puts the user where [param head] is, looking the same way, level: the
## eyes [constant HEAD_HEIGHT] above the rig.
func look_from(head: Transform3D) -> void:
	var forward := -head.basis.z
	_yaw = atan2(-forward.x, -forward.z)
	_pitch = asin(clampf(forward.y, -1.0, 1.0))
	# Its parent is a viewport: its own transform is the global one.
	rig.transform = Transform3D(Basis.IDENTITY, head.origin - Vector3(0.0, HEAD_HEIGHT, 0.0))
	_update_poses()


## The hand the mouse drives: [code]&"left_hand"[/code] or [code]&"right_hand"[/code].
func get_active_hand() -> StringName:
	return _active


## Makes [param hand] the one the mouse drives, as [constant SWITCH_HAND_KEY] does.
func set_active_hand(hand: StringName) -> void:
	if hand == _active or not hand in _HANDS:
		return
	# By the mouse now, not by the last frame: a button let go just before the switch lets go.
	var left := _active
	_trigger[left] = _mouse_trigger and _trigger_armed
	_grip_held[left] = _mouse_grip and _grip_armed
	_frozen[left] = _trigger[left] or _grip_held[left]
	_active = hand
	_frozen[hand] = false
	_trigger_armed = not _mouse_trigger or _trigger[hand]
	_grip_armed = not _mouse_grip or _grip_held[hand]


## The window or viewport the view renders to, for
## [method XRESession.apply_antialiasing]; MSAA 4× until that is called.
func get_view() -> Viewport:
	return _viewport


## Whether the window has the keyboard: the user works in the VR view.
func has_focus() -> bool:
	return window == null or window.has_focus()


## Saves a picture of the view to [param path] (PNG).
func save_shot(path: String) -> Error:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var error := _viewport.get_texture().get_image().save_png(path)
	print(_LOG_PREFIX, "picture of the view %s (%s)." % [ProjectSettings.globalize_path(path), error_string(error)])
	return error


## Handles one event of the window: keys, mouse buttons and movement.
func handle_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key != null:
		_on_key(key)
		return
	var button := event as InputEventMouseButton
	if button != null:
		_on_mouse_button(button)
		return
	var motion := event as InputEventMouseMotion
	if motion != null and _captured:
		_yaw -= deg_to_rad(motion.relative.x * LOOK_DEGREES_PER_PIXEL)
		_pitch = clampf(_pitch - deg_to_rad(motion.relative.y * LOOK_DEGREES_PER_PIXEL),
				-deg_to_rad(PITCH_LIMIT), deg_to_rad(PITCH_LIMIT))


func _on_key(event: InputEventKey) -> void:
	if event.echo:
		return
	var key := event.physical_keycode
	_keys[key] = event.pressed
	if not event.pressed:
		return
	match key:
		KEY_ESCAPE:
			_set_captured(false)
		SWITCH_HAND_KEY:
			set_active_hand(&"left_hand" if _active == &"right_hand" else &"right_hand")
		BEAM_KEY:
			beam_on = not beam_on
		HELP_KEY:
			_hud.help.visible = not _hud.help.visible
		SHOT_KEY:
			save_shot("%s/simulator_%s.png" % [SHOTS_FOLDER, Time.get_datetime_string_from_system().replace(":", "-")])


func _on_mouse_button(event: InputEventMouseButton) -> void:
	if not _captured:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_set_captured(true)
		return
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			_mouse_trigger = event.pressed
		MOUSE_BUTTON_RIGHT:
			_mouse_grip = event.pressed
		MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_roll[_active] = 0.0
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
			if not event.pressed:
				return
			var up := event.button_index == MOUSE_BUTTON_WHEEL_UP
			if event.ctrl_pressed:
				_roll[_active] += deg_to_rad(ROLL_STEP if up else -ROLL_STEP)
			else:
				_wheel = 1.0 if up else -1.0
				_wheel_until_usec = Time.get_ticks_usec() + int(WHEEL_TILT_SEC * 1000000.0)


func _set_captured(captured: bool) -> void:
	_captured = captured or window == null
	if window != null:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _captured else Input.MOUSE_MODE_VISIBLE
	if not _captured:
		_mouse_trigger = false
		_mouse_grip = false


## Lets go of every key and button, and of the mouse.
func _let_go() -> void:
	_keys.clear()
	_wheel_until_usec = 0
	_set_captured(false)


func _process(delta: float) -> void:
	# The editor turns it back on in places (progress dialogs); a frame it sleeps is one the view misses.
	OS.low_processor_usage_mode = false
	if _held(REACH_OUT_KEY) != _held(REACH_IN_KEY):
		_reach = clampf(_reach + (REACH_SPEED if _held(REACH_OUT_KEY) else -REACH_SPEED) * delta, 0.0, MAX_REACH)
	_update_poses()
	_update_inputs()
	_hud.update(self)


func _held(key: Key) -> bool:
	return _keys.get(key, false)


## Head and hands, in the rig's space. Runs before the rig's own processing:
## its parent comes first in the tree.
func _update_poses() -> void:
	var head := Transform3D(Basis.from_euler(Vector3(_pitch, _yaw, 0.0)), Vector3(0.0, HEAD_HEIGHT, 0.0))
	rig.camera.transform = head
	var forward := -head.basis.z
	for hand: StringName in _HANDS:
		if _frozen[hand]:
			continue
		var side := HAND_OFFSET if hand == &"right_hand" else Vector3(-HAND_OFFSET.x, HAND_OFFSET.y, HAND_OFFSET.z)
		var held := head.origin + head.basis * side
		if hand == _active:
			var basis := head.basis * Basis(Vector3.BACK, _roll[hand])
			_aim[hand] = Transform3D(basis, head.origin + forward * (_reach - RAY_BACK))
			_grip[hand] = Transform3D(basis, held + forward * _reach)
		else:
			var out := deg_to_rad(-REST_YAW if hand == &"right_hand" else REST_YAW)
			_aim[hand] = Transform3D(head.basis * Basis.from_euler(Vector3(deg_to_rad(REST_PITCH), out, 0.0)), held)
			_grip[hand] = _aim[hand]
		var tracker := _trackers[hand]
		tracker.set_pose(&"aim", _aim[hand], Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
		tracker.set_pose(&"grip", _grip[hand], Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)


func _update_inputs() -> void:
	if not _mouse_trigger:
		_trigger_armed = true
	if not _mouse_grip:
		_grip_armed = true
	for hand: StringName in _HANDS:
		if hand == _active:
			_trigger[hand] = _mouse_trigger and _trigger_armed
			_grip_held[hand] = _mouse_grip and _grip_armed
		elif not _frozen[hand]:
			_trigger[hand] = false
			_grip_held[hand] = false
		var tracker := _trackers[hand]
		tracker.set_input(&"trigger", 1.0 if _trigger[hand] else 0.0)
		tracker.set_input(&"grip", 1.0 if _grip_held[hand] else 0.0)
	for button: StringName in BUTTON_KEYS:
		_trackers[XREFeatureSettings.button_hand(button)].set_input(
				XREFeatureSettings.button_input(button), _held(BUTTON_KEYS[button]))
	var left := Vector2(_axis(KEY_D, KEY_A), _axis(KEY_W, KEY_S))
	var right := Vector2(_axis(KEY_RIGHT, KEY_LEFT), _axis(KEY_UP, KEY_DOWN))
	if Time.get_ticks_usec() < _wheel_until_usec:
		if _active == &"left_hand":
			left.y = _wheel
		else:
			right.y = _wheel
	_trackers[&"left_hand"].set_input(&"primary", left)
	_trackers[&"right_hand"].set_input(&"primary", right)


func _axis(positive: Key, negative: Key) -> float:
	return (1.0 if _held(positive) else 0.0) - (1.0 if _held(negative) else 0.0)


## The beam of the active hand while it shows, or null.
func get_beam() -> MeshInstance3D:
	return _beam.mesh if _beam.visible else null


## The key of [param button], a key of [constant XREFeatureSettings.BUTTONS]: "Tab".
static func key_label(button: StringName) -> String:
	return OS.get_keycode_string(BUTTON_KEYS[button]) if button in BUTTON_KEYS else ""


## Over the view: a cross in the middle where the active ray points, which hand
## is active, and the keys.
class _Hud extends Control:
	var help: Label
	var _status: Label
	var _free: Label

	func _init(simulator: XRESimulator) -> void:
		name = "Hud"
		mouse_filter = MOUSE_FILTER_IGNORE
		set_anchors_preset(PRESET_FULL_RECT)
		_status = _label(PRESET_TOP_LEFT)
		# At the top, under the status: the controllers are at the bottom.
		help = _label(PRESET_TOP_LEFT)
		help.position.y += 32.0
		help.modulate.a = 0.85
		var buttons := PackedStringArray()
		for button: StringName in XRESimulator.BUTTON_KEYS:
			buttons.append("%s: %s" % [XRESimulator.key_label(button), XREFeatureSettings.button_label(button)])
		help.text = XRESimulator.HELP + "\n" + " · ".join(buttons)
		_free = _label(PRESET_CENTER)
		_free.text = "Click to look around"
		_free.grow_horizontal = GROW_DIRECTION_BOTH
		_free.grow_vertical = GROW_DIRECTION_BOTH
		_free.position.y += 40.0
		update(simulator)

	func update(simulator: XRESimulator) -> void:
		var status := "%s hand · reach %.2f m" % ["Left" if simulator._active == &"left_hand" else "Right", simulator._reach]
		var frozen := simulator._frozen[&"right_hand" if simulator._active == &"left_hand" else &"left_hand"]
		if frozen:
			status += " · the other hand holds"
		if not simulator.beam_on:
			status += " · beam off (V)"
		if _status.text != status:
			_status.text = status
		_free.visible = not simulator._captured

	func _label(preset: LayoutPreset) -> Label:
		var label := Label.new()
		label.mouse_filter = MOUSE_FILTER_IGNORE
		label.add_theme_color_override(&"font_outline_color", Color.BLACK)
		label.add_theme_constant_override(&"outline_size", 6)
		add_child(label)
		label.set_anchors_and_offsets_preset(preset, PRESET_MODE_MINSIZE, 12)
		return label

	func _draw() -> void:
		var center := size / 2.0
		for direction: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
			draw_line(center + direction * 4.0, center + direction * 11.0, Color.BLACK, 4.0, true)
			draw_line(center + direction * 4.0, center + direction * 11.0, Color.WHITE, 2.0, true)

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			queue_redraw()


## The beam of the active hand: from the tip of its controller to where its
## ray, which leaves the eye, ends, in the ray's own material. Processed after
## every tool, once they have set the ray for this frame.
class _Beam extends Node3D:
	var mesh: MeshInstance3D
	var _simulator: XRESimulator

	func _init(simulator: XRESimulator) -> void:
		name = "Beam"
		_simulator = simulator
		process_priority = 1000
		var box := BoxMesh.new()
		box.size = Vector3(XRESimulator.BEAM_WIDTH, XRESimulator.BEAM_WIDTH, 1.0)
		mesh = XRERig.create_vr_mesh(box, null)
		add_child(mesh)

	func _process(_delta: float) -> void:
		var rig := _simulator.rig
		var right := _simulator.get_active_hand() == &"right_hand"
		var hand := rig.right_hand if right else rig.left_hand
		var start := (rig.right_controller if right else rig.left_controller).global_transform * XRESimulator.BEAM_START
		var end := hand.get_ray_end()
		var direction := end - start
		visible = _simulator.beam_on and hand.is_ray_shown() and direction.length() > 0.001
		if not visible:
			return
		var up := Vector3.UP if absf(direction.normalized().y) < 0.99 else Vector3.BACK
		global_transform = Transform3D(Basis.looking_at(direction, up), start + direction / 2.0)
		mesh.scale = Vector3(1.0, 1.0, direction.length())
		var material := hand.get_ray_material()
		if mesh.material_override != material:
			mesh.material_override = material
		# Drawn over everything as the ray is, after what is drawn over everything too, as the block palette (D-090).
		mesh.sorting_offset = hand.get_ray_sorting()
