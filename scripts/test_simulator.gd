extends SceneTree
## Headless tests of XRESimulator, the VR view without a headset (D-057):
## keyboard and mouse events in, the rig's head and hands out, and the NonVR
## controls layout; and XREDesktopUI, the editor's 2D UI hidden while in the
## headset (D-119). Used by scripts/check.sh, not shipped with the plugin.
## Prints "test_simulator: FAILED ..." for every failed check and a summary line at the end.

var _checks := 0
var _failures := 0
var _frame := 0
var _steps: Array[Callable] = []

var _simulator: XRESimulator
var _rig: XRERig
var _features: XREFeatureSettings
var _right_before := Transform3D.IDENTITY
var _reach_before := Vector3.ZERO
var _rig_before := Vector3.ZERO


func _initialize() -> void:
	_steps = [
		_start,
		_hands_at_rest,
		_antialiasing,
		_look_right,
		_beam_off,
		_beam_on,
		_beam_over_everything,
		_beam_as_before,
		_trigger,
		_grip,
		_switch_while_gripping,
		_held_hand_stays,
		_left_needs_a_fresh_press,
		_both_hands_grip,
		_switch_back_lets_go,
		_keys_are_buttons,
		_keys_released,
		_wheel_tilts_the_active_stick,
		_reach_out,
		_reached,
		_roll,
		_rolled,
		_fly,
		_flew,
		_desktop_ui,
		_finish,
	]


func _process(_delta: float) -> bool:
	if _frame < _steps.size():
		_steps[_frame].call()
	_frame += 1
	return _frame > _steps.size()


func _check(condition: bool, what: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("test_simulator: FAILED ", what)


func _key(key: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	event.pressed = pressed
	_simulator.handle_input(event)


func _mouse(button: MouseButton, pressed: bool, ctrl: bool = false) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	event.ctrl_pressed = ctrl
	_simulator.handle_input(event)


func _move_mouse(relative: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.relative = relative
	_simulator.handle_input(event)


func _head_forward() -> Vector3:
	return -_rig.camera.transform.basis.z


# One step per frame, as in test_play_mode.gd: each step checks what the
# simulator and the rig did in the previous frame, then sends the next input.

func _start() -> void:
	_features = XREFeatureSettings.new()
	_features.runtime_layout = XREFeatureSettings.NON_VR
	_simulator = XRESimulator.new(World3D.new(), false)
	_rig = _simulator.rig
	root.add_child(_simulator)


## Antialiasing (D-134): each value's multisampling; Auto as before, 4× in the
## simulator and on a standalone headset, none on a PC headset.
func _antialiasing() -> void:
	_check(XREFeatureSettings.get_default(XREFeatureSettings.ANTIALIASING) == XREFeatureSettings.AUTO, "Antialiasing is Auto by default")
	var view := _simulator.get_view()
	_check(view.msaa_3d == Viewport.MSAA_4X, "the simulator starts at 4x")
	_check(XRESession.msaa_for(XREFeatureSettings.AUTO, false, true) == Viewport.MSAA_4X
			and XRESession.msaa_for(XREFeatureSettings.AUTO, true, false) == Viewport.MSAA_4X
			and XRESession.msaa_for(XREFeatureSettings.AUTO, false, false) == Viewport.MSAA_DISABLED,
			"Auto: 4x in the simulator and on a standalone headset, off on a PC headset")
	var none := Viewport.SCREEN_SPACE_AA_DISABLED
	var fxaa := Viewport.SCREEN_SPACE_AA_FXAA
	# Each value: MSAA, post-process, TAA and scale, the same in the simulator, on a PC and on a standalone headset.
	var expected: Dictionary[StringName, Array] = {
		XREFeatureSettings.OFF: [Viewport.MSAA_DISABLED, none, false, 1.0],
		XREFeatureSettings.MSAA_2X: [Viewport.MSAA_2X, none, false, 1.0],
		XREFeatureSettings.MSAA_4X: [Viewport.MSAA_4X, none, false, 1.0],
		XREFeatureSettings.MSAA_8X: [Viewport.MSAA_8X, none, false, 1.0],
		XREFeatureSettings.MSAA_4X_SSAA_2X: [Viewport.MSAA_4X, none, false, 2.0],
		XREFeatureSettings.FXAA: [Viewport.MSAA_DISABLED, fxaa, false, 1.0],
		XREFeatureSettings.SSAA_1_5X: [Viewport.MSAA_DISABLED, none, false, 1.5],
		XREFeatureSettings.SSAA_2X: [Viewport.MSAA_DISABLED, none, false, 2.0],
	}
	for value: StringName in expected:
		_check_antialiasing(view, value, false, true, expected[value])
		var probe := SubViewport.new()
		_check_antialiasing(probe, value, false, false, expected[value])
		_check_antialiasing(probe, value, true, false, expected[value])
		probe.free()
	var headset := SubViewport.new()
	# SMAA fails in stereo: only the simulator, which is mono, has it.
	_check_antialiasing(view, XREFeatureSettings.SMAA, false, true, [Viewport.MSAA_DISABLED, Viewport.SCREEN_SPACE_AA_SMAA, false, 1.0])
	_check_antialiasing(headset, XREFeatureSettings.SMAA, false, false, [Viewport.MSAA_DISABLED, fxaa, false, 1.0])
	_check_antialiasing(headset, XREFeatureSettings.SMAA, true, false, [Viewport.MSAA_DISABLED, fxaa, false, 1.0])
	# The engine doesn't jitter a stereo view, and its Mobile renderer has no TAA: only the simulator has it.
	_check_antialiasing(view, XREFeatureSettings.TAA, false, true, [Viewport.MSAA_DISABLED, none, true, 1.0])
	_check_antialiasing(headset, XREFeatureSettings.TAA, false, false, [Viewport.MSAA_4X, none, false, 1.0])
	_check_antialiasing(headset, XREFeatureSettings.TAA, true, false, [Viewport.MSAA_4X, none, false, 1.0])
	headset.free()
	for value: StringName in XREFeatureSettings.DEFINITIONS[XREFeatureSettings.ANTIALIASING]["values"]:
		_check(value == XREFeatureSettings.AUTO or value in [XREFeatureSettings.SMAA, XREFeatureSettings.TAA] or expected.has(value), "%s is tested" % value)
	XRESession.apply_antialiasing(view, XREFeatureSettings.AUTO, false, true)
	_check(view.msaa_3d == Viewport.MSAA_4X and view.screen_space_aa == none and not view.use_taa and is_equal_approx(view.scaling_3d_scale, 1.0),
			"Auto puts back what the other values changed")


func _check_antialiasing(view: Viewport, value: StringName, standalone: bool, simulated: bool, wanted: Array) -> void:
	XRESession.apply_antialiasing(view, value, standalone, simulated)
	_check(view.msaa_3d == wanted[0] and view.screen_space_aa == wanted[1] and view.use_taa == wanted[2] and is_equal_approx(view.scaling_3d_scale, wanted[3]),
			"%s (standalone %s, simulated %s): MSAA %d, screen-space %d, TAA %s, scale %.1f" % [value, standalone, simulated, view.msaa_3d, view.screen_space_aa, view.use_taa, view.scaling_3d_scale])


func _hands_at_rest() -> void:
	var head := _rig.camera.transform
	_check(head.origin.is_equal_approx(Vector3(0.0, XRESimulator.HEAD_HEIGHT, 0.0)), "the eyes are above the rig: %s" % head.origin)
	var aim := _rig.right_hand.transform
	_check((-aim.basis.z).is_equal_approx(_head_forward()), "the active hand points where the eyes look")
	_check(aim.origin.is_equal_approx(head.origin - _head_forward() * XRESimulator.RAY_BACK),
			"the active ray starts at the eye: %s" % aim.origin)
	var left := _rig.left_hand.transform
	_check(left.origin.x < head.origin.x - 0.1 and left.origin.y < head.origin.y - 0.1, "the other hand rests low on its side: %s" % left.origin)
	_check(-left.basis.z.y < -0.2, "the other hand points down, off the middle of the view")
	_check(_rig.has_grip_pose(_rig.right_hand) and _rig.has_grip_pose(_rig.left_hand), "both controllers are tracked")
	_check(_simulator.get_active_hand() == &"right_hand", "the right hand starts active")
	_move_mouse(Vector2(100.0, 0.0))


func _look_right() -> void:
	_check(_head_forward().x > 0.2, "moving the mouse right looks right: %s" % _head_forward())
	_check((-_rig.right_hand.transform.basis.z).is_equal_approx(_head_forward()), "the ray follows the look")
	var beam := _simulator.get_beam()
	_check(beam != null, "the active hand shows a beam")
	if beam != null:
		var start := beam.global_transform * Vector3(0.0, 0.0, 0.5)
		var end := beam.global_transform * Vector3(0.0, 0.0, -0.5)
		_check(start.distance_to(_rig.right_controller.global_transform * XRESimulator.BEAM_START) < 0.001,
				"the beam leaves the tip of the controller")
		_check(end.distance_to(_rig.right_hand.get_ray_end()) < 0.001, "and ends where the ray from the eye ends")
		_check(end.distance_to(_rig.camera.global_position + _head_forward() * (XREHand.RAY_LENGTH - XRESimulator.RAY_BACK)) < 0.001,
				"in the middle of the view")
	_key(XRESimulator.BEAM_KEY, true)
	_key(XRESimulator.BEAM_KEY, false)


func _beam_off() -> void:
	_check(_simulator.get_beam() == null and not _simulator.beam_on, "V turns the beam off")
	_key(XRESimulator.BEAM_KEY, true)
	_key(XRESimulator.BEAM_KEY, false)


func _beam_on() -> void:
	_check(_simulator.get_beam() != null, "V turns it on again")
	_rig.right_hand.set_on_top(true)


## With the ray over everything, the beam is drawn as late as the ray, after a window over everything, as the block palette (D-090).
func _beam_over_everything() -> void:
	var beam := _simulator.get_beam()
	_check(beam != null and beam.sorting_offset == _rig.right_hand.get_ray_sorting() and beam.sorting_offset > XREPanelSurface.OVER_FOCUS_SORTING,
			"the beam is drawn over everything with the ray, after a window drawn over everything")
	_rig.right_hand.set_on_top(false)


func _beam_as_before() -> void:
	var beam := _simulator.get_beam()
	_check(beam != null and beam.sorting_offset == 0.0, "and as before once the ray is")
	_mouse(MOUSE_BUTTON_LEFT, true)


func _trigger() -> void:
	_check(_rig.right_hand.trigger_pressed and _rig.right_hand.trigger_held, "the left mouse button is the trigger")
	_check(not _rig.left_hand.trigger_held, "of the active hand only")
	_mouse(MOUSE_BUTTON_LEFT, false)
	_mouse(MOUSE_BUTTON_RIGHT, true)


func _grip() -> void:
	_check(not _rig.right_hand.trigger_held and _rig.right_hand.grip_held, "the right mouse button is the grip")
	_right_before = _rig.right_hand.transform
	_key(XRESimulator.SWITCH_HAND_KEY, true)
	_key(XRESimulator.SWITCH_HAND_KEY, false)


func _switch_while_gripping() -> void:
	_check(_simulator.get_active_hand() == &"left_hand", "Q switches to the left hand")
	_check(_rig.right_hand.grip_held, "a hand left while gripping keeps gripping")
	_check(not _rig.left_hand.grip_held, "the button held at the switch doesn't grip with the new hand")
	_check((-_rig.left_hand.transform.basis.z).is_equal_approx(_head_forward()), "the left ray now leaves the eye")
	_move_mouse(Vector2(-200.0, 50.0))


func _held_hand_stays() -> void:
	_check(_rig.right_hand.transform.is_equal_approx(_right_before), "the gripping hand stays where it was")
	_check((-_rig.left_hand.transform.basis.z).is_equal_approx(_head_forward()), "the active hand follows the look")
	_mouse(MOUSE_BUTTON_RIGHT, false)


func _left_needs_a_fresh_press() -> void:
	_check(not _rig.left_hand.grip_held and _rig.right_hand.grip_held, "letting the button go doesn't let the other hand go")
	_mouse(MOUSE_BUTTON_RIGHT, true)


func _both_hands_grip() -> void:
	_check(_rig.left_hand.grip_pressed and _rig.right_hand.grip_held, "a fresh press grips with the new hand, both hands hold")
	_mouse(MOUSE_BUTTON_RIGHT, false)
	_key(XRESimulator.SWITCH_HAND_KEY, true)


func _switch_back_lets_go() -> void:
	_check(_simulator.get_active_hand() == &"right_hand", "Q switches back")
	_check(not _rig.right_hand.grip_held and not _rig.left_hand.grip_held, "back on a hand with the button up, it lets go")
	_check((-_rig.right_hand.transform.basis.z).is_equal_approx(_head_forward()), "the right hand follows the look again")
	_key(XRESimulator.SWITCH_HAND_KEY, false)
	_key(XRESimulator.BUTTON_KEYS[&"left_menu"], true)
	_key(XRESimulator.BUTTON_KEYS[&"right_a"], true)
	_key(XRESimulator.BUTTON_KEYS[&"right_b"], true)
	_key(XRESimulator.BUTTON_KEYS[&"left_x"], true)
	_key(KEY_W, true)
	_key(KEY_D, true)


func _keys_are_buttons() -> void:
	_check(_rig.is_action_pressed(_features, XREFeatureSettings.LAUNCHER), "Tab opens the launcher in the NonVR layout")
	_check(_rig.is_action_pressed(_features, XREFeatureSettings.UNDO) and _rig.right_hand.ax_pressed, "E is the right A: undo")
	_check(_rig.is_action_pressed(_features, XREFeatureSettings.REDO), "B is the right B: redo")
	_check(_rig.is_action_pressed(_features, XREFeatureSettings.DELETE) and _rig.left_hand.ax_pressed, "X is the left X: delete")
	_check(not _rig.is_action_held(_features, XREFeatureSettings.PLAY), "Y is up")
	_check(_rig.left_hand.get_vector2(&"primary").is_equal_approx(Vector2(1.0, 1.0)), "W and D tilt the left stick forward and right")
	for key: Key in [XRESimulator.BUTTON_KEYS[&"left_menu"], XRESimulator.BUTTON_KEYS[&"right_a"], XRESimulator.BUTTON_KEYS[&"right_b"],
			XRESimulator.BUTTON_KEYS[&"left_x"], KEY_W, KEY_D]:
		_key(key, false)


func _keys_released() -> void:
	_check(not _rig.is_action_held(_features, XREFeatureSettings.LAUNCHER) and not _rig.right_hand.ax_held, "released keys let the buttons go")
	_check(_rig.left_hand.get_vector2(&"primary").is_zero_approx(), "and the stick")
	_mouse(MOUSE_BUTTON_WHEEL_UP, true)


func _wheel_tilts_the_active_stick() -> void:
	_check(_rig.right_hand.get_vector2(&"primary").y > 0.9, "the wheel tilts the active hand's stick forward")
	_check(_rig.left_hand.get_vector2(&"primary").is_zero_approx(), "not the other one")
	_reach_before = _rig.right_hand.transform.origin
	_key(XRESimulator.REACH_OUT_KEY, true)


func _reach_out() -> void:
	pass


func _reached() -> void:
	var moved := _rig.right_hand.transform.origin - _reach_before
	_check(moved.dot(_head_forward()) > 0.0, "R reaches out along the look: %s" % moved)
	_check((-_rig.right_hand.transform.basis.z).is_equal_approx(_head_forward()), "and the ray still points the same way")
	_key(XRESimulator.REACH_OUT_KEY, false)
	_mouse(MOUSE_BUTTON_WHEEL_UP, true, true)


func _roll() -> void:
	pass


func _rolled() -> void:
	var basis := _rig.right_hand.transform.basis
	_check((-basis.z).is_equal_approx(_head_forward()), "a rolled wrist points the same way")
	_check(absf(basis.x.angle_to(_rig.camera.transform.basis.x) - deg_to_rad(XRESimulator.ROLL_STEP)) < 0.01,
			"Ctrl+wheel rolls the wrist a step")


# The right hand is active, the left one rests pointing down: flying still goes
# where the view looks, up and down included.
func _fly() -> void:
	_rig.add_child(XRELocomotion.new(_rig))
	_rig_before = _rig.global_position
	_move_mouse(Vector2(0.0, -150.0))
	_key(KEY_W, true)


func _flew() -> void:
	var moved := _rig.global_position - _rig_before
	var gaze := -_rig.camera.global_basis.z
	_check(gaze.y > 0.1, "the view looks up: %s" % gaze)
	_check(moved.length() > 0.0 and moved.normalized().angle_to(gaze) < deg_to_rad(1.0),
			"W flies where the view looks, not where the resting left hand points: %s" % moved)
	_key(KEY_W, false)


func _desktop_ui() -> void:
	var control := Control.new()
	var ui := XREDesktopUI.new(control)
	_check(not ui.update(true, false) and control.visible, "off, the UI stays in the headset")
	ui.enabled = true
	_check(ui.update(true, false) and not control.visible and ui.is_hidden(), "on, it hides while in the headset")
	_check(ui.update(false, false) and control.visible, "and shows when the headset doesn't show the editor")
	ui.update(true, false)
	var motion := InputEventMouseMotion.new()
	ui.handle_input(motion)
	_check(not control.visible, "moving the mouse over the window doesn't show it")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_SPACE
	key.pressed = true
	ui.handle_input(key)
	_check(control.visible and not ui.is_hidden(), "a key in the window shows it")
	_check(not ui.update(true, false) and control.visible, "it stays while in the headset")
	_check(ui.update(true, true) and not control.visible, "until a trigger or grip")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	ui.handle_input(click)
	_check(control.visible, "a click shows it too")
	ui.update(true, true)
	ui.restore()
	_check(control.visible and not ui.is_hidden(), "restored, it shows")
	control.free()


func _finish() -> void:
	_check(XREFeatureSettings.NON_VR in XREFeatureSettings.LAYOUTS, "NonVR is a controls layout")
	_check(_features.get_layout() == XREFeatureSettings.NON_VR and _features.uses_keyboard(), "without a headset NonVR is in use, with keys")
	_check(_features.set_layout(XREFeatureSettings.CUSTOM) and _features.uses_keyboard(), "the user's own layout shows keys too, without a headset")
	var headset := XREFeatureSettings.new()
	_check(not headset.uses_keyboard() and headset.set_layout(XREFeatureSettings.NON_VR) and headset.uses_keyboard(),
			"with a headset only the NonVR layout shows keys")
	_check(XRESimulator.key_label(&"left_menu") == "Tab" and XRESimulator.key_label(&"left_stick") == "Shift",
			"the keys have names for the controls page")
	for action: StringName in XREFeatureSettings.ACTIONS:
		_check(XREFeatureSettings.preset_binding(XREFeatureSettings.NON_VR, action) in XRESimulator.BUTTON_KEYS,
				"every action of NonVR has a key: %s" % action)
	_simulator.queue_free()
	print("test_simulator: %d of %d checks failed" % [_failures, _checks])
