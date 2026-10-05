extends SceneTree
## Headless tests of XREControllerModel driven by a fake controller tracker:
## which model it shows for which interaction profile, how its meshes are set
## up, how its parts follow the inputs, and that it lets go of the tracker. Used by scripts/check.sh, not shipped
## with the plugin. Prints "test_controller_model: FAILED ..." for every failed
## check and a summary line at the end.

const TOUCH_PROFILE := "/interaction_profiles/oculus/touch_controller"

var _checks := 0
var _failures := 0


func _initialize() -> void:
	await process_frame # The root window enters the tree after _initialize().
	var left := XREControllerModel.new("LeftController", &"left_hand", XRPositionalTracker.TRACKER_HAND_LEFT)
	var right := XREControllerModel.new("RightController", &"right_hand", XRPositionalTracker.TRACKER_HAND_RIGHT)
	_test_setup(left, right)
	root.add_child(left)
	root.add_child(right)
	_test_bounds(left)
	_test_parts(left)
	_test_profiles(left)
	left.free()
	right.free()
	print("test_controller_model: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)


func _check(condition: bool, what: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		print("test_controller_model: FAILED ", what)


## The model is there before any tracker: loaded with the plugin, not mid-session.
func _test_setup(left: XREControllerModel, right: XREControllerModel) -> void:
	_check(left.get_model_name() == XREControllerModel.DEFAULT_MODEL, "default model before a profile")
	_check(left.pose == &"grip" and left.show_when_tracked, "grip pose, hidden while untracked")
	_check(left.get_child_count() == 1 and right.get_child_count() == 1, "one model per hand")
	_check(left.get_child(0).scene_file_path.ends_with("/left.glb"), "left hand gets left.glb")
	_check(right.get_child(0).scene_file_path.ends_with("/right.glb"), "right hand gets right.glb")
	var geometries := left.find_children("*", "GeometryInstance3D", true, false)
	_check(not geometries.is_empty(), "model has meshes")
	for node: Node in geometries:
		var geometry := node as GeometryInstance3D
		_check(geometry.layers == XRERig.VR_LAYER, "%s only on the VR layer" % geometry.name)
		_check(geometry.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "%s casts no shadow" % geometry.name)
		_check(geometry.gi_mode == GeometryInstance3D.GI_MODE_DISABLED, "%s is out of GI" % geometry.name)


## Guards the import: a controller in meters, around the grip pose.
func _test_bounds(model: XREControllerModel) -> void:
	var bounds := AABB()
	for node: Node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		var box := model.global_transform.affine_inverse() * mesh.global_transform * mesh.get_aabb()
		bounds = box if bounds.size == Vector3.ZERO else bounds.merge(box)
	var size := bounds.size
	_check(size.x > 0.05 and size.y > 0.05 and size.z > 0.05 and size.x < 0.3 and size.y < 0.3 and size.z < 0.3,
			"controller is 5–30 cm on each axis, is %s" % size)
	_check(bounds.get_center().length() < 0.05, "grip pose within 5 cm of the model's center, is %s" % bounds.get_center())


## Parts follow the tracker's inputs with the weights of the WebXR reference library.
func _test_parts(model: XREControllerModel) -> void:
	_check(_part_at(model, "xr_standard_trigger_pressed", 0.0), "trigger rests before any input")
	_check(_part_at(model, "xr_standard_thumbstick_xaxis_pressed", 0.5), "thumbstick rests centered")

	var tracker := XRControllerTracker.new()
	tracker.name = &"left_hand"
	tracker.hand = XRPositionalTracker.TRACKER_HAND_LEFT
	XRServer.add_tracker(tracker)
	tracker.set_input(&"trigger", 1.0)
	_check(_part_at(model, "xr_standard_trigger_pressed", 1.0), "trigger pulled all the way")
	tracker.set_input(&"trigger", 0.5)
	_check(_part_at(model, "xr_standard_trigger_pressed", 0.5), "trigger pulled halfway")
	tracker.set_input(&"trigger", 0.0)
	_check(_part_at(model, "xr_standard_trigger_pressed", 0.0), "trigger let go")
	tracker.set_input(&"grip", 0.7)
	_check(_part_at(model, "xr_standard_squeeze_pressed", 0.7), "grip follows its value")
	tracker.set_input(&"ax_button", true)
	_check(_part_at(model, "x_button_pressed", 1.0), "X pressed")
	tracker.set_input(&"ax_button", false)
	_check(_part_at(model, "x_button_pressed", 0.0), "X released")
	tracker.set_input(&"by_button", true)
	_check(_part_at(model, "y_button_pressed", 1.0), "Y pressed")
	tracker.set_input(&"primary_click", true)
	_check(_part_at(model, "xr_standard_thumbstick_pressed", 1.0), "thumbstick clicked")

	tracker.set_input(&"primary", Vector2(1.0, 0.0))
	_check(_part_at(model, "xr_standard_thumbstick_xaxis_pressed", 1.0), "thumbstick right tilts to x max")
	_check(_part_at(model, "xr_standard_thumbstick_yaxis_pressed", 0.5), "thumbstick right keeps y centered")
	tracker.set_input(&"primary", Vector2(0.0, 1.0))
	_check(_part_at(model, "xr_standard_thumbstick_yaxis_pressed", 0.0), "thumbstick forward tilts to y min (WebXR -Y)")
	tracker.set_input(&"primary", Vector2(1.0, 1.0))
	var diagonal := 0.5 + 0.5 * sqrt(0.5)
	_check(_part_at(model, "xr_standard_thumbstick_xaxis_pressed", diagonal), "diagonal x clipped to the circle")
	_check(_part_at(model, "xr_standard_thumbstick_yaxis_pressed", 1.0 - diagonal), "diagonal y clipped to the circle")

	tracker.set_input(&"menu_button", true) # The model has no menu button: nothing moves, nothing fails.
	XRServer.remove_tracker(tracker)


## Whether the part's value node sits at [param weight] between its min and max nodes.
func _part_at(model: Node, part: String, weight: float) -> bool:
	var value := model.find_child(part + "_value", true, false) as Node3D
	var min_node := model.find_child(part + "_min", true, false) as Node3D
	var max_node := model.find_child(part + "_max", true, false) as Node3D
	if value == null or min_node == null or max_node == null:
		return false
	return value.transform.is_equal_approx(min_node.transform.interpolate_with(max_node.transform, weight))


func _test_profiles(model: XREControllerModel) -> void:
	var on_profile_changed := Callable(model, &"_on_profile_changed")
	# A tracker that already has a profile when the model starts watching it.
	var tracker := XRControllerTracker.new()
	tracker.name = &"left_hand"
	tracker.hand = XRPositionalTracker.TRACKER_HAND_LEFT
	tracker.profile = TOUCH_PROFILE
	XRServer.add_tracker(tracker)
	_check(tracker.profile_changed.is_connected(on_profile_changed), "watches the tracker once it is added")
	_check(model.get_model_name() == XREControllerModel.MODELS[TOUCH_PROFILE], "Touch profile gets its model")

	tracker.profile = "/interaction_profiles/unknown/controller"
	_check(model.get_model_name() == XREControllerModel.DEFAULT_MODEL, "unknown profile gets the default model")
	tracker.profile = "none"
	_check(model.get_model_name() == XREControllerModel.DEFAULT_MODEL, "no controller keeps the model")
	_check(model.get_child_count() == 1, "still one model")

	XRServer.remove_tracker(tracker)
	_check(not tracker.profile_changed.is_connected(on_profile_changed), "lets go of a removed tracker")
	XRServer.add_tracker(tracker)
	_check(tracker.profile_changed.is_connected(on_profile_changed), "watches a tracker added again")

	model.get_parent().remove_child(model)
	_check(not tracker.profile_changed.is_connected(on_profile_changed), "lets go of the tracker on leaving the tree")
	_check(not XRServer.tracker_added.is_connected(Callable(model, &"_on_tracker_added")), "disconnects from XRServer")
	XRServer.remove_tracker(tracker)
