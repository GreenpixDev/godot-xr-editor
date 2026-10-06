extends SceneTree
## Headless tests of the VR tools: the native XREPicker, XRESnap, XREIcons, and
## XREManipulator, XREPalette and XRELocomotion driven by fake controller trackers. Used by
## scripts/check.sh, not shipped with the plugin. Prints "test_tools: FAILED ..."
## for every failed check and a summary line at the end.
##
## Headless Godot renders nothing and its mesh storage reports empty bounds,
## so every test mesh sets custom_aabb: that is what the renderer's BVH,
## and thus the picker, sees.

const EPSILON := 0.001

## A fake document: records what tools do instead of touching an editor.
class FakeDocument extends XREDocument:
	var root: Node
	var selection: Array[Node] = []
	var snap := XRESnap.new(false, 0.0, 0.0, 0.0)
	var previews := 0
	## The "before" transform of every commit_transform.
	var commits: Array[Transform3D] = []
	## Nodes add_node put in.
	var added: Array[Node] = []
	## Nodes remove_nodes took out; the test frees them at the end.
	var removed: Array[Node] = []

	func get_scene_root() -> Node:
		return root

	func get_selection() -> Array[Node]:
		return selection.duplicate()

	func select(nodes: Array[Node], source: Source) -> void:
		selection = nodes.duplicate()
		_record(&"select", source, nodes)
		selection_changed.emit()

	func preview_transform(node: Node3D, xform: Transform3D) -> void:
		node.transform = xform
		previews += 1

	func commit_transform(node: Node3D, before: Transform3D, source: Source) -> void:
		commits.append(before)
		_record(&"transform", source, [node])

	func set_property(_object: Object, _property: StringName, _value: Variant, _source: Source) -> void:
		pass

	func add_node(node: Node, parent: Node, source: Source) -> void:
		parent.add_child(node, true)
		node.owner = root
		added.append(node)
		_record(&"add_node", source, [node])

	func remove_nodes(nodes: Array[Node], source: Source) -> void:
		var gone := nodes_to_remove(nodes, root)
		if gone.is_empty():
			return
		for node: Node in gone:
			node.get_parent().remove_child(node)
		removed.append_array(gone)
		# The editor's selection drops nodes that leave the tree.
		var kept: Array[Node] = []
		for node: Node in selection:
			if node.is_inside_tree():
				kept.append(node)
		selection = kept
		_record(&"remove_nodes", source, gone)
		selection_changed.emit()

	func save(_source: Source) -> Error:
		return OK

	func play(_source: Source, _separate_app: bool) -> Error:
		return OK

	func stop_playing(_source: Source) -> void:
		pass

	func is_playing() -> bool:
		return false

	func get_snap() -> XRESnap:
		return snap


var _checks := 0
var _failures := 0
var _frame := 0
var _steps: Array[Callable] = []

var _scene: Node3D
var _picker: XREPicker
var _document: FakeDocument
var _operations: Array[String] = []
var _trackers: Array[XRControllerTracker] = []
var _right: XRControllerTracker
var _left: XRControllerTracker
var _rig: XRERig
var _locomotion: XRELocomotion
var _icons: XREIcons
var _palette: XREPalette
var _manipulator: XREManipulator
## The box the manipulator tests grab, in the scene's first lane.
var _target: MeshInstance3D
var _gain := 1.0
## Where the left hand holds the tray for the palette tests.
var _tray_hand: Vector3
## The node the palette is holding or has put in the scene.
var _taken: Node3D
var _operation_count := 0
var _commit_count := 0
var _rig_before: Vector3
var _target_before: Vector3


func _initialize() -> void:
	_steps = [
		_build,
		_test_picker,
		_test_snap,
		_test_manipulation_math,
		_test_nodes_to_remove,
		_start_manipulator,
		_test_icons,
		_point_at_target,
		_press_trigger,
		_grab_with_ray,
		_move_hand,
		_join_left_hand,
		_spread_hands,
		_let_go,
		_grab_with_snap,
		_invert_snap,
		_grab_and_switch_scene,
		_touch_grab_right,
		_join_left_by_touch,
		_let_go_right,
		_turn_left_hand,
		_check_hand_over,
		_palette_shown,
		_touch_miniature,
		_take_box,
		_carry_box,
		_box_placed,
		_light_taken,
		_light_thrown_away,
		_delete_placed,
		_placed_deleted,
		_grab_far,
		_held_deleted,
		_point_at_spot_icon,
		_spot_selected,
		_grab_for_flight,
		_fly,
		_flown,
		_turned,
		_speed_clicked,
		_finish,
	]


func _process(_delta: float) -> bool:
	if _frame < _steps.size():
		_steps[_frame].call()
	_frame += 1
	return false


func _check(condition: bool, what: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("test_tools: FAILED ", what)


func _check_vector(actual: Vector3, expected: Vector3, what: String) -> void:
	_check(actual.distance_to(expected) < EPSILON, "%s: %s, expected %s" % [what, actual, expected])


# Scene: lanes along X, each a ray from z = 1 down -Z testing one rule.

func _build() -> void:
	_scene = Node3D.new()
	_scene.name = "Scene"
	root.add_child(_scene)

	# Lane 0: the nearer of two boxes.
	_target = _add_box(_scene, "Near", Vector3(0.0, 0.0, -1.0), 0.2)
	_add_box(_scene, "Far", Vector3(0.0, 0.0, -2.0), 0.2)
	# Lane 1: a locked node lets the ray through.
	_add_box(_scene, "Locked", Vector3(1.0, 0.0, -1.0), 0.2).set_meta(&"_edit_lock_", true)
	_add_box(_scene, "Behind", Vector3(1.0, 0.0, -2.0), 0.2)
	# Lane 2: a group stands for its children.
	var group := _add_node(_scene, Node3D.new(), "Group", Vector3(2.0, 0.0, -1.0))
	group.set_meta(&"_edit_group_", true)
	_add_box(group, "Grouped", Vector3.ZERO, 0.2)
	# Lane 3: an instanced scene stands for its children.
	var prop := Node3D.new()
	prop.name = "Prop"
	var prop_mesh := _box("PropMesh", 0.2)
	prop.add_child(prop_mesh)
	prop_mesh.owner = prop
	var packed := PackedScene.new()
	packed.pack(prop)
	prop.free()
	var instance := packed.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) as Node3D
	_add_node(_scene, instance, "Instance", Vector3(3.0, 0.0, -1.0))
	# Lane 4: a hidden node can't be picked.
	_add_box(_scene, "Hidden", Vector3(4.0, 0.0, -1.0), 0.2).visible = false
	_add_box(_scene, "Visible", Vector3(4.0, 0.0, -2.0), 0.2)
	# Lane 5: a mesh is hit by its triangles, not its bounding box.
	var ball := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	ball.mesh = sphere
	ball.custom_aabb = sphere.get_aabb()
	_add_node(_scene, ball, "Ball", Vector3(5.0, 0.0, -1.0))
	# Lane 6: geometry outside the edited scene, like the VR layer, is ignored.
	_add_box(root, "Outside", Vector3(6.0, 0.0, -1.0), 0.2)
	# Lane 7: a node the scene doesn't own gives way to its owned parent.
	var holder := _add_node(_scene, Node3D.new(), "Holder", Vector3(7.0, 0.0, -1.0))
	var generated := _box("Generated", 0.2)
	holder.add_child(generated)
	# Lane 8: other geometry is hit by its bounding box.
	var csg := CSGBox3D.new()
	csg.size = Vector3(0.4, 0.4, 0.4)
	csg.custom_aabb = AABB(Vector3(-0.2, -0.2, -0.2), Vector3(0.4, 0.4, 0.4))
	_add_node(_scene, csg, "Csg", Vector3(8.0, 0.0, -1.0))
	# Lane 10: touching picks the smallest box around the point.
	_add_box(_scene, "Big", Vector3(10.0, 0.0, -1.0), 2.0)
	_add_box(_scene, "Small", Vector3(10.0, 0.0, -1.0), 0.2)
	# Lanes 12–15: lights, picked by their icons. A light behind a box, an
	# instanced lamp that stands for its light, a hidden light.
	_add_node(_scene, OmniLight3D.new(), "Lamp", Vector3(12.0, 0.0, -1.0))
	_add_box(_scene, "Shade", Vector3(13.0, 0.0, -1.0), 0.2)
	_add_node(_scene, SpotLight3D.new(), "Spot", Vector3(13.0, 0.0, -2.0))
	var lamp := Node3D.new()
	var bulb := OmniLight3D.new()
	bulb.name = "Bulb"
	lamp.add_child(bulb)
	bulb.owner = lamp
	var lamp_scene := PackedScene.new()
	lamp_scene.pack(lamp)
	lamp.free()
	_add_node(_scene, lamp_scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) as Node3D, "LampProp",
			Vector3(14.0, 0.0, -1.0))
	_add_node(_scene, OmniLight3D.new(), "HiddenLamp", Vector3(15.0, 0.0, -1.0)).visible = false
	# Lanes 20 and 21.5: a 6 m CSG room around (20, 0, 0) with a box inside.
	var room := CSGBox3D.new()
	room.size = Vector3(6.0, 6.0, 6.0)
	room.custom_aabb = AABB(Vector3(-3.0, -3.0, -3.0), Vector3(6.0, 6.0, 6.0))
	_add_node(_scene, room, "Room", Vector3(20.0, 0.0, 0.0))
	_add_box(_scene, "InRoom", Vector3(20.0, 0.0, -1.0), 0.2)

	_picker = XREPicker.new()
	_picker.scenario = root.find_world_3d().scenario


func _box(node_name: String, size: float) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(size, size, size)
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.custom_aabb = mesh.get_aabb()
	return instance


func _add_box(parent: Node, node_name: String, position: Vector3, size: float) -> MeshInstance3D:
	return _add_node(parent, _box(node_name, size), node_name, position) as MeshInstance3D


func _add_node(parent: Node, node: Node3D, node_name: String, position: Vector3) -> Node3D:
	node.name = node_name
	node.position = position
	parent.add_child(node)
	if parent == _scene or parent.owner == _scene:
		node.owner = _scene
	return node


func _cast_lane(x: float, y: float = 0.0) -> String:
	if not _picker.cast_segment(_scene, Vector3(x, y, 1.0), Vector3(x, y, -10.0)):
		return ""
	return String(_picker.get_hit_node().name)


func _test_picker() -> void:
	_check(_cast_lane(0.0) == "Near", "nearest box wins, got %s" % _cast_lane(0.0))
	_check(absf(_picker.get_hit_distance() - 1.9) < EPSILON, "distance to the near face: %f" % _picker.get_hit_distance())
	_check_vector(_picker.get_hit_normal(), Vector3(0.0, 0.0, 1.0), "normal of the near face")
	_check(_cast_lane(1.0) == "Behind", "locked node is skipped, got %s" % _cast_lane(1.0))
	_check(_cast_lane(2.0) == "Group", "group stands for its child, got %s" % _cast_lane(2.0))
	_check(_cast_lane(3.0) == "Instance", "instance root stands for its child, got %s" % _cast_lane(3.0))
	_scene.set_editable_instance(_scene.get_node(^"Instance"), true)
	_check(_cast_lane(3.0) == "PropMesh", "editable instance exposes its child, got %s" % _cast_lane(3.0))
	_check(_cast_lane(4.0) == "Visible", "hidden node is skipped, got %s" % _cast_lane(4.0))
	_check(_cast_lane(5.0) == "Ball", "sphere is hit through its center, got %s" % _cast_lane(5.0))
	_check(absf(_picker.get_hit_distance() - 1.5) < 0.02, "distance to the sphere: %f" % _picker.get_hit_distance())
	_check(_cast_lane(5.45, 0.45) == "", "ray through the sphere's box corner misses, got %s" % _cast_lane(5.45, 0.45))
	_check(_cast_lane(6.0) == "", "geometry outside the scene is ignored, got %s" % _cast_lane(6.0))
	_check(_cast_lane(7.0) == "Holder", "unowned node gives way to its parent, got %s" % _cast_lane(7.0))
	_check(_cast_lane(8.0) == "Csg", "CSG is hit by its box, got %s" % _cast_lane(8.0))
	_check(absf(_picker.get_hit_distance() - 1.8) < EPSILON, "distance to the CSG box: %f" % _picker.get_hit_distance())
	_check(_cast_lane(-2.0) == "", "empty lane hits nothing, got %s" % _cast_lane(-2.0))
	_check(_cast_lane(20.0) == "InRoom", "a ray from inside a box reaches what is in it, got %s" % _cast_lane(20.0))
	_check(_cast_lane(21.5) == "Room", "a ray from inside a box hits its wall, got %s" % _cast_lane(21.5))
	_check(absf(_picker.get_hit_distance() - 4.0) < EPSILON, "distance to the wall: %f" % _picker.get_hit_distance())
	_check_vector(_picker.get_hit_normal(), Vector3(0.0, 0.0, 1.0), "the normal of the wall faces the ray")

	var head := Vector3(0.0, 0.0, 1.0)
	_check(_picker.find_at_point(_scene, Vector3(10.0, 0.0, -1.0), 0.03, head)
			and _picker.get_hit_node().name == &"Small", "touch picks the smallest box")
	_check(_picker.find_at_point(_scene, Vector3(0.0, 0.12, -1.0), 0.03, head)
			and _picker.get_hit_node() == _target, "touch reaches 2 cm past the bounds")
	_check(absf(_picker.get_hit_distance() - 0.02) < EPSILON, "touch distance: %f" % _picker.get_hit_distance())
	_check(not _picker.find_at_point(_scene, Vector3(0.0, 0.2, -1.0), 0.03, head), "touch stops at the radius")
	_check(not _picker.find_at_point(_scene, Vector3(21.0, 0.0, 0.0), 0.03, Vector3(20.0, 1.0, 0.0)),
			"a box around the head cannot be touched")
	_check(_picker.find_at_point(_scene, Vector3(22.0, 0.0, 0.0), 0.03, head)
			and _picker.get_hit_node().name == &"Room", "the same box from outside can")

	var bounds := XREPicker.get_local_bounds(_scene.get_node(^"Group") as Node3D)
	_check(bounds.is_equal_approx(AABB(Vector3(-0.1, -0.1, -0.1), Vector3(0.2, 0.2, 0.2))), "group bounds: %s" % bounds)
	bounds = XREPicker.get_local_bounds(_scene.get_node(^"Holder") as Node3D)
	_check(bounds.size.is_equal_approx(Vector3(0.2, 0.2, 0.2)), "bounds include unowned children: %s" % bounds)


func _test_snap() -> void:
	var snap := XRESnap.new(true, 0.5, 15.0, 10.0)
	var turned := Transform3D(Basis.from_euler(Vector3(0.0, deg_to_rad(37.0), deg_to_rad(-5.0))).scaled_local(Vector3(2.0, 1.0, 1.0)),
			Vector3(0.74, 0.1, -1.26))
	var snapped := snap.snap_transform(turned)
	_check_vector(snapped.origin, Vector3(0.5, 0.0, -1.5), "origin on the grid")
	_check_vector(snapped.basis.get_rotation_quaternion().get_euler(), Vector3(0.0, deg_to_rad(30.0), 0.0), "angles on 15°")
	_check_vector(snapped.basis.get_scale(), Vector3(2.0, 1.0, 1.0), "scale kept")
	_check(is_equal_approx(snap.snap_scale_factor(1.23), 1.2), "scale factor on 10 %")
	_check(is_equal_approx(snap.snap_scale_factor(0.01), 0.1), "scale factor at least one step")
	var off := XRESnap.new(true, 0.0, 0.0, 0.0)
	_check(off.snap_transform(turned).is_equal_approx(turned), "zero steps change nothing")


func _test_manipulation_math() -> void:
	var start := Transform3D(Basis.from_euler(Vector3(0.3, 0.2, 0.1)), Vector3(0.1, 1.0, -0.4))
	var hand_start := Transform3D(Basis.from_euler(Vector3(-0.2, 0.5, 0.0)), Vector3(0.0, 1.0, -0.3))
	var hand_now := Transform3D(Basis.from_euler(Vector3(0.4, -0.3, 0.2)), Vector3(0.2, 1.1, -0.5))
	var rigid := hand_now * hand_start.affine_inverse() * start
	var held := XREManipulator.one_hand_transform(start, hand_start.origin, hand_start, hand_now, 1.0)
	_check(held.is_equal_approx(rigid), "touch grab is rigid: %s vs %s" % [held, rigid])

	var moved_hand := Transform3D(hand_start.basis, hand_start.origin + Vector3(0.1, 0.0, 0.0))
	var far := XREManipulator.one_hand_transform(start, Vector3(0.0, 1.0, -3.0), hand_start, moved_hand, 5.0)
	_check_vector(far.origin, start.origin + Vector3(0.5, 0.0, 0.0), "ray grab scales motion by the gain")
	_check(is_equal_approx(XREManipulator.homer_gain(Vector3.ZERO, Vector3(0.0, 0.0, -0.5), Vector3(0.0, 0.0, -5.0)), 10.0),
			"HOMER gain is the distance ratio")
	_check(is_equal_approx(XREManipulator.homer_gain(Vector3.ZERO, Vector3(0.0, 0.0, -0.5), Vector3(0.0, 0.0, -0.2)), 1.0),
			"HOMER gain is at least 1")

	var a := Vector3(-0.2, 1.0, -0.3)
	var b := Vector3(0.2, 1.0, -0.3)
	var pivot := Vector3(0.0, 1.0, -1.0)
	var node := Transform3D(Basis.IDENTITY, Vector3(0.0, 1.0, -1.5))
	_check(is_equal_approx(XREManipulator.two_hand_scale(a, b, a - Vector3(0.2, 0.0, 0.0), b + Vector3(0.2, 0.0, 0.0)), 2.0),
			"spreading the hands twice as wide scales by 2")
	var turned := XREManipulator.two_hand_transform(node, pivot, a, b, Vector3(0.0, 1.0, -0.5), Vector3(0.0, 1.0, -0.1),
			1.0, 1.0)
	# The line between the hands turned from +X to +Z, -90° about Y, and its
	# midpoint stayed put: the node, 0.5 m in front of the pivot, ends up 0.5 m to its right.
	_check_vector(turned.origin, Vector3(0.5, 1.0, -1.0), "two hands turn the node about the pivot")
	var scaled := XREManipulator.two_hand_transform(node, pivot, a, b, a, b, 1.0, 2.0)
	_check_vector(scaled.origin, Vector3(0.0, 1.0, -2.0), "two hands scale about the pivot")
	_check_vector(scaled.basis.get_scale(), Vector3(2.0, 2.0, 2.0), "two hands scale uniformly")

	var rig := Transform3D(Basis.IDENTITY, Vector3(1.0, 0.0, 0.0))
	var head := Vector3(1.0, 1.6, 0.5)
	var right_turn := XRELocomotion.turned(rig, head, -PI / 2.0)
	_check_vector(right_turn * (rig.affine_inverse() * head), head, "turning keeps the head in place")
	_check_vector(-right_turn.basis.z, Vector3(1.0, 0.0, 0.0), "a negative angle turns to the right")


func _test_nodes_to_remove() -> void:
	var group := _scene.get_node(^"Group")
	var nodes: Array[Node] = [_scene, _scene.get_node(^"Far"), group.get_node(^"Grouped"), group,
			_scene.get_node(^"Instance/PropMesh"), _target, _scene.get_node(^"Far")]
	var names := XREDocument.nodes_to_remove(nodes, _scene).map(func(node: Node) -> String: return String(node.name))
	_check(names == ["Near", "Far", "Group"],
			"removing skips the root, nodes inside instances, nested and repeated nodes, in tree order: %s" % [names])
	_check(XREDocument.nodes_to_remove(nodes, null).is_empty(), "without a scene nothing is removed")


# Manipulator and palette driven by fake trackers, one step per frame: each
# step checks what they did in the previous frame, then sets the next input.

func _start_manipulator() -> void:
	_right = _add_tracker(&"right_hand")
	_left = _add_tracker(&"left_hand")
	_document = FakeDocument.new()
	_document.root = _scene
	_document.operation_recorded.connect(
			func(operation: StringName, source: XREDocument.Source, nodes: Array[Node], _time_usec: int) -> void:
				_operations.append("%s %s %s" % [operation, XREDocument.Source.keys()[source], nodes.map(
						func(node: Node) -> String: return String(node.name))]))
	_rig = XRERig.new()
	# In the plugin's order: locomotion moves the rig first, and the palette
	# claims the right hand before the manipulator runs.
	_locomotion = XRELocomotion.new(_rig)
	_rig.add_child(_locomotion)
	_icons = XREIcons.new(_document, _rig)
	_rig.add_child(_icons)
	_palette = XREPalette.new(_document, _rig)
	_rig.add_child(_palette)
	_manipulator = XREManipulator.new(_document, _rig, _icons)
	_rig.add_child(_manipulator)
	root.add_child(_rig)
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 0.0, 0.0)


## Icons are cast at directly; the head is at the origin, as the head tracker is absent.
func _test_icons() -> void:
	var lamp := _scene.get_node(^"Lamp") as Node3D
	var radius := XREIcons.radius_at(lamp.global_position, Vector3.ZERO)
	_check(_icons.cast_segment(Vector3(12.0, 0.0, 1.0), Vector3(12.0, 0.0, -10.0)) and _icons.get_hit_node() == lamp,
			"the ray picks a light by its icon")
	_check(absf(_icons.get_hit_distance() - (2.0 - radius)) < EPSILON, "distance to the icon: %f" % _icons.get_hit_distance())
	_check_vector(_icons.get_hit_position(), lamp.global_position, "a pointed icon is held at its light")
	_check(_icons.cast_segment(Vector3(13.0, 0.0, 1.0), Vector3(13.0, 0.0, -10.0))
			and _icons.get_hit_node().name == &"Spot", "an icon behind geometry is still picked")
	_check(_icons.cast_segment(Vector3(14.0, 0.0, 1.0), Vector3(14.0, 0.0, -10.0))
			and _icons.get_hit_node().name == &"LampProp", "a light in an instance stands for the instance root")
	_check(not _icons.cast_segment(Vector3(15.0, 0.0, 1.0), Vector3(15.0, 0.0, -10.0)), "a hidden light has no icon to pick")
	_check(not _icons.cast_segment(Vector3(12.0, 0.0, 1.0), Vector3(12.0, 0.0, 0.0)), "the segment ends before the icon")
	_check(_icons.find_at_point(lamp.global_position + Vector3(0.0, radius + 0.02, 0.0), 0.03)
			and _icons.get_hit_node() == lamp, "touch reaches 2 cm past the icon")
	_check(not _icons.find_at_point(lamp.global_position + Vector3(0.0, radius + 0.05, 0.0), 0.03), "touch stops at the radius")

	var added := _add_node(_scene, OmniLight3D.new(), "Added", Vector3(16.0, 0.0, -1.0))
	_check(_icons.cast_segment(Vector3(16.0, 0.0, 1.0), Vector3(16.0, 0.0, -10.0)), "a light added to the scene gets an icon")
	_scene.remove_child(added)
	_check(not _icons.cast_segment(Vector3(16.0, 0.0, 1.0), Vector3(16.0, 0.0, -10.0)), "a removed light loses its icon")
	added.free()


func _add_tracker(tracker_name: StringName) -> XRControllerTracker:
	var tracker := XRControllerTracker.new()
	tracker.name = tracker_name
	XRServer.add_tracker(tracker)
	_trackers.append(tracker)
	return tracker


## Puts [param tracker] at [param position], aiming down -Z unless turned by [param basis].
func _set_hand(tracker: XRControllerTracker, position: Vector3, trigger: float, grip: float,
		basis: Basis = Basis.IDENTITY) -> void:
	tracker.set_pose(&"aim", Transform3D(basis, position), Vector3.ZERO, Vector3.ZERO,
			XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	tracker.set_input(&"trigger", trigger)
	tracker.set_input(&"grip", grip)


func _point_at_target() -> void:
	_check(_operations.is_empty(), "pointing alone records nothing: %s" % [_operations])
	_check(_rig.right_hand.global_position.is_equal_approx(Vector3(0.0, 0.0, 0.3)), "fake tracker moves the hand")
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 1.0, 0.0)


func _press_trigger() -> void:
	_check(_operations == ["select TOOL [\"Near\"]"], "trigger selects the node under the ray: %s" % [_operations])
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 0.0, 1.0)


func _grab_with_ray() -> void:
	_check(_operations.size() == 1, "grabbing a selected node doesn't select it again: %s" % [_operations])
	_check(_document.previews == 1, "grab previews every frame: %d" % _document.previews)
	_check_vector(_target.position, Vector3(0.0, 0.0, -1.0), "grab alone doesn't move the node")
	var torso := Vector3.ZERO + XREManipulator.TORSO_OFFSET # The head tracker is absent: head at the origin.
	_gain = XREManipulator.homer_gain(torso, Vector3(0.0, 0.0, 0.3), Vector3(0.0, 0.0, -0.9))
	_set_hand(_right, Vector3(0.1, 0.0, 0.3), 0.0, 1.0)


func _move_hand() -> void:
	_check(_gain > 2.0, "far grab amplifies motion: gain %f" % _gain)
	_check_vector(_target.position, Vector3(0.1 * _gain, 0.0, -1.0), "ray grab moves the node by the gain")
	_set_hand(_left, Vector3(-0.2, 0.0, 0.3), 0.0, 1.0)


func _join_left_hand() -> void:
	_check_vector(_target.position, Vector3(0.1 * _gain, 0.0, -1.0), "joining hand doesn't move the node")
	_set_hand(_left, Vector3(-0.5, 0.0, 0.3), 0.0, 1.0)


func _spread_hands() -> void:
	# Span 0.3 → 0.6: scale 2 about the grabbed point (0.1 * gain, 0, -0.9);
	# the midpoint moved by -0.15 along X, times the gain.
	_check_vector(_target.scale, Vector3(2.0, 2.0, 2.0), "spreading the hands scales the node")
	_check_vector(_target.position, Vector3(-0.05 * _gain, 0.0, -1.1), "two-handed scale keeps the grabbed point")
	_check(_document.commits.is_empty(), "nothing is committed while holding")
	_set_hand(_right, Vector3(0.1, 0.0, 0.3), 0.0, 0.0)
	_set_hand(_left, Vector3(-0.5, 0.0, 0.3), 0.0, 0.0)


func _let_go() -> void:
	_check(_document.commits.size() == 1 and _document.commits[0].is_equal_approx(Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, -1.0))),
			"letting go records one undo step from the start: %s" % [_document.commits])
	_check(_operations.size() == 2 and _operations[1] == "transform TOOL [\"Near\"]", "transform is recorded: %s" % [_operations])
	_document.snap = XRESnap.new(true, 0.5, 15.0, 10.0)
	_target.transform = Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, -1.0))
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 0.0, 1.0)


func _grab_with_snap() -> void:
	_set_hand(_right, Vector3(0.13, 0.0, 0.3), 0.0, 1.0)


func _invert_snap() -> void:
	_check_vector(_target.position, Vector3(snappedf(0.13 * _gain, 0.5), 0.0, -1.0), "snapping puts the node on the grid")
	_set_hand(_right, Vector3(0.13, 0.0, 0.3), 1.0, 1.0)


func _grab_and_switch_scene() -> void:
	_check_vector(_target.position, Vector3(0.13 * _gain, 0.0, -1.0), "trigger of the holding hand turns snapping off")
	var commits := _document.commits.size()
	_document.scene_changed.emit()
	_check_vector(_target.position, Vector3(0.0, 0.0, -1.0), "switching scenes puts the node back")
	_check(_document.commits.size() == commits, "a cancelled grab records nothing")
	_set_hand(_right, Vector3(0.13, 0.0, 0.3), 0.0, 0.0)


# Passing the node from hand to hand: the hand that keeps it must hold it at
# its own point, not where the first hand took it.

func _touch_grab_right() -> void:
	_check(_document.commits.size() == 1, "releasing after a cancel records nothing: %s" % [_document.commits])
	_document.snap = XRESnap.new(false, 0.5, 15.0, 10.0)
	_set_hand(_right, Vector3(0.05, 0.0, -1.0), 0.0, 1.0)


func _join_left_by_touch() -> void:
	_set_hand(_left, Vector3(-0.05, 0.0, -1.0), 0.0, 1.0)


func _let_go_right() -> void:
	_set_hand(_right, Vector3(0.05, 0.0, -1.0), 0.0, 0.0)


func _turn_left_hand() -> void:
	_check_vector(_target.position, Vector3(0.0, 0.0, -1.0), "passing the node between hands doesn't move it")
	_set_hand(_left, Vector3(-0.05, 0.0, -1.0), 0.0, 1.0, Basis(Vector3.UP, PI / 2.0))


func _check_hand_over() -> void:
	var left_start := Transform3D(Basis.IDENTITY, Vector3(-0.05, 0.0, -1.0))
	var left_now := Transform3D(Basis(Vector3.UP, PI / 2.0), left_start.origin)
	var rigid := left_now * left_start.affine_inverse() * Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, -1.0))
	_check(_target.transform.is_equal_approx(rigid),
			"the hand that took the node over turns it about itself: %s, expected %s" % [_target.transform, rigid])
	_check(not _palette.is_shown(), "the tray starts hidden")
	# The left hand lets go and shows the tray with X.
	_tray_hand = Vector3(0.0, 0.5, 0.5)
	_set_hand(_left, _tray_hand, 0.0, 0.0)
	_left.set_input(&"ax_button", true)


# Palette: the right hand takes things out of the tray in the left hand. The
# tray is moved so that the box's miniature is at (0, 0, 0.5): the right
# hand touching it also points at the Near box, which the manipulator would grab.

func _palette_shown() -> void:
	_check(_palette.is_shown(), "X shows the tray")
	_left.set_input(&"ax_button", false)
	_tray_hand += Vector3(0.0, 0.0, 0.5) - _palette.get_item_transform(&"CSGBox3D").origin
	_set_hand(_left, _tray_hand, 0.0, 0.0)
	_set_hand(_right, Vector3(0.0, 0.0, 0.5), 0.0, 0.0)


func _touch_miniature() -> void:
	_check(_palette.get_hovered() == &"CSGBox3D", "the right hand touches the box's miniature: %s" % _palette.get_hovered())
	_check(not _rig.right_hand.is_free_for(_manipulator), "the palette claims the hand that touches it")
	_operation_count = _operations.size()
	_set_hand(_right, Vector3(0.0, 0.0, 0.5), 0.0, 1.0)


func _take_box() -> void:
	_taken = _palette.get_held()
	_check(_taken is CSGBox3D, "grip takes a box out of the tray: %s" % _taken)
	_check(_operations.size() == _operation_count, "the manipulator doesn't grab what the ray points at: %s" % [_operations])
	if _taken == null:
		return
	_check(not _scene.is_ancestor_of(_taken) and _document.added.is_empty(), "the box isn't in the scene while held")
	var miniature := Transform3D(Basis.IDENTITY * XREPalette.MINIATURE_SCALE, Vector3(0.0, 0.0, 0.5))
	_check(_taken.global_transform.is_equal_approx(miniature)
			and _palette.get_item_transform(&"CSGBox3D").is_equal_approx(miniature),
			"the box comes out where its miniature is, as big as it: %s" % _taken.global_transform)
	_set_hand(_right, Vector3(0.2, 0.1, 0.5), 0.0, 1.0)


func _carry_box() -> void:
	if _taken == null:
		return
	_check_vector(_taken.global_position, Vector3(0.2, 0.1, 0.5), "the box follows the hand")
	_set_hand(_right, Vector3(0.2, 0.1, 0.5), 0.0, 0.0)


func _box_placed() -> void:
	if _taken == null:
		return
	_check(_palette.get_held() == null, "letting go puts the box down")
	_check(_document.added == [_taken] and _taken.get_parent() == _scene and _taken.owner == _scene,
			"the box goes into the scene, under its root: %s" % [_document.added])
	_check_vector(_taken.position, Vector3(0.2, 0.1, 0.5), "the box stays where it was let go")
	_check_vector(_taken.scale, Vector3.ONE * XREPalette.MINIATURE_SCALE, "the box stays as big as its miniature")
	_check(_operations.slice(_operation_count) == ["add_node TOOL [\"CSGBox3D\"]", "select TOOL [\"CSGBox3D\"]"],
			"adding is one operation, and the box is selected: %s" % [_operations.slice(_operation_count)])
	# A light, with snapping on, taken by touching and gripping in one frame.
	_document.snap = XRESnap.new(true, 0.5, 15.0, 10.0)
	_operation_count = _operations.size()
	_set_hand(_right, _palette.get_item_transform(&"OmniLight3D").origin, 0.0, 1.0)


func _light_taken() -> void:
	_taken = _palette.get_held()
	_check(_taken is OmniLight3D, "grip takes a light out of the tray: %s" % _taken)
	if _taken == null:
		return
	var unsnapped := _palette.get_item_transform(&"OmniLight3D").origin
	_check_vector(_taken.global_position,
			Vector3(snappedf(unsnapped.x, 0.5), snappedf(unsnapped.y, 0.5), snappedf(unsnapped.z, 0.5)),
			"a node taken out snaps to the grid")
	_check_vector(_taken.scale, Vector3.ONE, "a light comes out at its natural scale")
	_right.set_input(&"ax_button", true)


func _light_thrown_away() -> void:
	_check(_palette.get_held() == null and _document.added.size() == 1, "A throws the held light away")
	_check(not is_instance_valid(_taken), "the thrown light is freed")
	_check(_operations.size() == _operation_count, "throwing away records nothing: %s" % [_operations])
	_check(_document.removed.is_empty(), "the A that throws a light away doesn't delete the selection")
	_right.set_input(&"ax_button", false)
	_set_hand(_right, Vector3(1.0, 1.5, 0.0), 0.0, 0.0)


func _delete_placed() -> void:
	_right.set_input(&"ax_button", true)


func _placed_deleted() -> void:
	_check(_document.removed.size() == 1 and _document.removed[0] is CSGBox3D, "A deletes the selection: %s" % [_document.removed])
	_check(_operations.back() == "remove_nodes TOOL [\"CSGBox3D\"]", "deleting is recorded: %s" % [_operations])
	_check(_document.get_selection().is_empty(), "nothing is selected after deleting")
	_right.set_input(&"ax_button", false)
	_commit_count = _document.commits.size()
	_set_hand(_right, Vector3(0.0, 0.0, -2.0), 0.0, 1.0)


func _grab_far() -> void:
	var far := _scene.get_node(^"Far")
	_check(_document.get_selection() == [far], "touch grab of the far box selects it: %s" % [_document.get_selection()])
	_set_hand(_right, Vector3(0.1, 0.0, -2.0), 0.0, 1.0)
	_right.set_input(&"ax_button", true)


func _held_deleted() -> void:
	var far := _document.removed.back() as Node3D
	_check(far != null and far.name == &"Far", "A deletes the node being held: %s" % [_document.removed])
	if far != null:
		_check_vector(far.position, Vector3(0.0, 0.0, -2.0), "a node deleted while held goes back where the grab found it")
	_check(_document.commits.size() == _commit_count, "a node deleted while held records no move")
	_set_hand(_right, Vector3(1.0, 1.5, 0.0), 0.0, 0.0)
	_right.set_input(&"ax_button", false)
	_left.set_input(&"ax_button", true)


func _point_at_spot_icon() -> void:
	_check(not _palette.is_shown(), "X hides the tray")
	_left.set_input(&"ax_button", false)
	_operation_count = _operations.size()
	_set_hand(_right, Vector3(13.0, 0.0, 1.0), 1.0, 0.0)


func _spot_selected() -> void:
	_check(_operations.slice(_operation_count) == ["select TOOL [\"Spot\"]"],
			"the trigger selects a light behind a box by its icon: %s" % [_operations.slice(_operation_count)])
	# The outline is the icon's box, as big as the icon is from here, not a fixed one.
	var spot := _scene.get_node(^"Spot") as Node3D
	var expected := XREIcons.MESH_BOUNDS.grow(XREBoundsBox.PADDING).size.x \
			* XREIcons.radius_at(spot.global_position, _rig.camera.global_position)
	var outlined := false
	for child: Node in _manipulator.get_children():
		var box := child as XREBoundsBox
		if box != null and box.visible and (box.material_override as StandardMaterial3D).albedo_color == XREManipulator.SELECTION_COLOR:
			outlined = true
			_check(absf(box.global_basis.x.length() - expected) < EPSILON,
					"a light's outline grows with its icon: %f, expected %f" % [box.global_basis.x.length(), expected])
			_check_vector(box.global_basis.get_scale(), Vector3.ONE * expected, "a light's outline is a cube")
	_check(outlined, "the selected light is outlined")
	_set_hand(_right, Vector3(13.0, 0.0, 1.0), 0.0, 0.0)


# Locomotion: flying with a node grabbed by the ray, which HOMER would
# otherwise move by the gain times the distance flown.

func _grab_for_flight() -> void:
	_check(_locomotion.get_vignette_strength() == 0.0, "no vignette while standing still")
	# Off: a grid would round the small distance flown in a frame away.
	_document.snap = XRESnap.new(false, 0.5, 15.0, 10.0)
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 0.0, 1.0)


func _fly() -> void:
	_check(_document.get_selection() == [_target], "the ray grabs the near box: %s" % [_document.get_selection()])
	_rig_before = _rig.global_position
	_target_before = _target.global_position
	# The left hand holds still, aiming down -Z.
	_left.set_input(&"primary", Vector2(0.0, 1.0))


func _flown() -> void:
	var flown := _rig.global_position - _rig_before
	_check(flown.z < 0.0 and is_zero_approx(flown.x) and is_zero_approx(flown.y),
			"the left stick flies where the left hand points: %s" % flown)
	_check_vector(_target.global_position - _target_before, flown, "a held node travels with the rig, by what it flew")
	_check(_locomotion.get_vignette_strength() > 0.0, "flying darkens the edges of the view")
	_left.set_input(&"primary", Vector2.ZERO)
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 0.0, 0.0)
	_right.set_input(&"primary", Vector2(1.0, 0.0))


func _turned() -> void:
	var forward := -_rig.global_basis.z
	_check(forward.x > 0.0 and is_zero_approx(forward.y), "the right stick turns to the right: %s" % forward)
	_right.set_input(&"primary", Vector2.ZERO)
	_check(_locomotion.get_speed() == 1.5 and _locomotion.get_speed_label().is_empty(),
			"flying starts at walking pace, with no label")
	_left.set_input(&"primary_click", true)


func _speed_clicked() -> void:
	_check(_locomotion.get_speed() == 4.0, "the left stick's click picks the next speed: %f" % _locomotion.get_speed())
	_check(_locomotion.get_speed_label() == "Flying speed 4.0 m/s", "the new speed shows: %s" % _locomotion.get_speed_label())
	_left.set_input(&"primary_click", false)


func _finish() -> void:
	for node: Node in _document.removed:
		node.free()
	for tracker in _trackers:
		XRServer.remove_tracker(tracker)
	print("test_tools: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)
