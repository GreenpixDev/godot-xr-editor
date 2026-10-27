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
	## The "before" transform of every node commit_transforms committed.
	var commits: Array[Transform3D] = []
	## How many times commit_transforms was called: one undo step each.
	var commit_steps := 0
	## Nodes add_node put in.
	var added: Array[Node] = []
	## Nodes remove_nodes took out; the test frees them at the end.
	var removed: Array[Node] = []
	## How many times duplicate_nodes copied anything: one undo step each.
	var duplicate_steps := 0
	## select() tells of the change only when the test emits it, as the editor does in a later frame.
	var late_selection := false

	func get_scene_root() -> Node:
		return root

	func get_selection() -> Array[Node]:
		return selection.duplicate()

	func select(nodes: Array[Node], source: Source) -> void:
		selection = nodes.duplicate()
		_record(&"select", source, nodes)
		if not late_selection:
			selection_changed.emit()

	func preview_transform(node: Node3D, xform: Transform3D) -> void:
		node.transform = xform
		previews += 1

	func commit_transforms(nodes: Array[Node3D], befores: Array[Transform3D], source: Source) -> void:
		commits.append_array(befores)
		commit_steps += 1
		var recorded: Array[Node] = []
		recorded.assign(nodes)
		_record(&"transform", source, recorded)

	func set_property(object: Object, property: StringName, value: Variant, source: Source) -> void:
		object.set(property, value)
		var nodes: Array[Node] = []
		if object is Node:
			nodes.append(object as Node)
		_record(&"set_property", source, nodes)

	func preview_property(_object: Object, _property: StringName, _value: Variant) -> void:
		pass

	func commit_property(_object: Object, _property: StringName, _before: Variant, _source: Source) -> void:
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

	func duplicate_nodes(nodes: Array[Node], move: Transform3D, source: Source) -> Array[Node]:
		var copies: Array[Node] = []
		for original: Node in nodes_to_remove(nodes, root):
			var owned: Array[Node] = []
			var copy := copy_node(original, root, move, owned)
			original.get_parent().add_child(copy, true)
			original.get_parent().move_child(copy, original.get_index() + 1)
			for node: Node in owned:
				node.owner = root
			copies.append(copy)
		if copies.is_empty():
			return copies
		duplicate_steps += 1
		_record(&"duplicate", source, copies)
		return copies

	func save(_source: Source) -> Error:
		return OK

	func open_scene(_path: String, _source: Source) -> Error:
		return ERR_UNAVAILABLE

	func list_folder(_path: String) -> PackedStringArray:
		return PackedStringArray()

	func get_file_type(_path: String) -> StringName:
		return &""

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
var _shortcut: XREObjectShortcut
var _counter: XRESelectionCounter
var _blueprint_requests := 0
## The box the manipulator tests grab, in the scene's first lane.
var _target: MeshInstance3D
var _gain := 1.0
## The Objects window the palette's miniatures hang in (D-045), and its tab.
var _objects: XREPanelWindow
var _objects_tab: XREObjectsTab
## The node the palette is holding or has put in the scene.
var _taken: Node3D
var _operation_count := 0
var _commit_count := 0
var _rig_before: Vector3
## Global positions of the boxes grabbed together (D-115), by path, before the grab.
var _group_before: Dictionary[String, Vector3] = {}
## How many copies the fake document made before a copy step (D-116), and the copies' parent's children then.
var _duplicate_count := 0
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
		_test_outline,
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
		_sphere_hovered_by_ray,
		_sphere_taken_by_ray,
		_sphere_thrown_away,
		_delete_placed,
		_placed_deleted,
		_grab_far,
		_held_deleted,
		_point_at_spot_icon,
		_spot_selected,
		_shortcut_off,
		_shortcut_stays_shut,
		_select_for_shortcut,
		_release_for_shortcut,
		_hold_for_shortcut,
		_shortcut_opened,
		_rename_lit,
		_rename_typed,
		_renamed,
		_delete_aimed,
		_delete_lit,
		_deleted_by_shortcut,
		_near_selected,
		_open_for_nothing,
		_let_go_on_nothing,
		_closed_on_nothing,
		_blueprint_aimed,
		_blueprint_lit,
		_blueprint_requested,
		_shortcut_blocked,
		_multi_start,
		_hold_grip_with_replace,
		_trigger_with_replace,
		_replaced_with_grip_held,
		_select_first,
		_hold_other_grip,
		_trigger_to_add,
		_added_by_other_grip,
		_trigger_to_take_out,
		_taken_out,
		_trigger_to_add_back,
		_added_back,
		_trigger_in_empty,
		_kept_in_empty,
		_trigger_on_child,
		_child_added,
		_trigger_on_parent,
		_parent_added,
		_group_grabbed,
		_group_moved,
		_group_committed,
		_group_regrabbed,
		_group_cancelled,
		_copy_start,
		_hold_on_group,
		_group_shortcut_opened,
		_duplicate_lit,
		_duplicated_by_shortcut,
		_hold_without_copy,
		_shortcut_without_copy,
		_hold_with_grip_copy,
		_shortcut_with_grip_copy,
		_hold_with_both,
		_shortcut_with_both,
		_copy_grip_start,
		_copy_hold_other_grip,
		_copy_grip_on_twin,
		_copies_carried,
		_copies_let_go,
		_copies_placed,
		_copy_click,
		_copy_click_let_go,
		_copy_clicked,
		_copy_cancelled,
		_counter_start,
		_counter_counts,
		_counter_adding,
		_counter_modifier_unused,
		_counter_hidden,
		_brush_start,
		_brush_first,
		_brush_second,
		_brush_gap,
		_brush_third,
		_brush_done,
		_brush_add_start,
		_brush_add_on,
		_brush_add_more,
		_brush_added,
		_brush_click_empty,
		_brush_cleared,
		_brush_late_press,
		_brush_late_release,
		_brush_late_shown,
		_brush_late_told,
		_box_start,
		_box_drag,
		_box_drawn,
		_box_done,
		_box_add_press,
		_box_add_drag,
		_box_add_release,
		_box_added,
		_box_click,
		_box_clicked,
		_grab_for_flight,
		_fly,
		_flown,
		_turned,
		_speed_clicked,
		_tilted_up,
		_levelled,
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
	# Lanes 30–33: boxes selected and grabbed together (D-115); the cart carries its load.
	_add_box(_scene, "PairA", Vector3(30.0, 0.0, -1.0), 0.2)
	_add_box(_scene, "PairB", Vector3(31.0, 0.0, -1.0), 0.2)
	_add_box(_scene, "PairC", Vector3(32.0, 0.0, -1.0), 0.2)
	_add_box(_add_box(_scene, "Cart", Vector3(33.0, 0.0, -1.0), 0.2), "Load", Vector3(0.0, 0.5, 0.0), 0.2)
	# Lanes 36–37: boxes copied (D-116); the twin's part is copied with it.
	_add_box(_add_box(_scene, "Twin", Vector3(36.0, 0.0, -1.0), 0.2), "Part", Vector3(0.0, 0.5, 0.0), 0.2)
	_add_box(_scene, "Pal", Vector3(37.0, 0.0, -1.0), 0.2)
	# High before the head: boxes a selection box takes (D-120), one beside it,
	# and one hidden behind the middle one, seen from the head at the origin.
	for index: int in 3:
		_add_box(_scene, "High%d" % (index + 1), Vector3(-0.6 + 0.6 * index, 3.0, -3.0), 0.2)
	_add_box(_scene, "High4", Vector3(2.0, 3.0, -3.0), 0.2)
	_add_box(_scene, "Behind2", Vector3(0.0, 4.0, -4.0), 0.2)
	# Lanes 40–43: boxes a brush stroke crosses (D-119).
	for index: int in 4:
		_add_box(_scene, "Brush%d" % (index + 1), Vector3(40.0 + index, 0.0, -1.0), 0.2)

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
	# The manipulator's checks press the trigger on what is selected: no shortcut until its own checks (D-088).
	_document.features.set_value(XREFeatureSettings.OBJECT_SHORTCUT, XREFeatureSettings.OFF)
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
	_palette.set_manipulator(_manipulator)
	# After the manipulator, as in the plugin (D-088).
	_shortcut = XREObjectShortcut.new(_document, _rig)
	_shortcut.blueprint_requested.connect(func() -> void: _blueprint_requests += 1)
	_manipulator.shortcut_requested.connect(_shortcut.open)
	_rig.add_child(_shortcut)
	_counter = XRESelectionCounter.new(_document, _rig, _manipulator)
	_rig.add_child(_counter)
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
	_check(not _icons.cast_segment(Vector3(12.0, 0.0, -2.0), Vector3(12.0, 0.0, -10.0)),
			"an icon behind where the segment starts is not hit")
	_check(_icons.find_at_point(lamp.global_position + Vector3(0.0, radius + 0.02, 0.0), 0.03)
			and _icons.get_hit_node() == lamp, "touch reaches 2 cm past the icon")
	_check(not _icons.find_at_point(lamp.global_position + Vector3(0.0, radius + 0.05, 0.0), 0.03), "touch stops at the radius")

	var added := _add_node(_scene, OmniLight3D.new(), "Added", Vector3(16.0, 0.0, -1.0))
	_check(_icons.cast_segment(Vector3(16.0, 0.0, 1.0), Vector3(16.0, 0.0, -10.0)), "a light added to the scene gets an icon")
	_scene.remove_child(added)
	_check(not _icons.cast_segment(Vector3(16.0, 0.0, 1.0), Vector3(16.0, 0.0, -10.0)), "a removed light loses its icon")
	added.free()


## The manipulator's outlines of [param color] that mark something now.
func _active_outlines(color: Color) -> Array[XREOutline]:
	var found: Array[XREOutline] = []
	for child: Node in _manipulator.get_children():
		var outline := child as XREOutline
		if outline != null and outline.is_active() and outline.color == color:
			found.append(outline)
	return found


## The edges XREEdgeMesh finds, then what an outline draws of a node and where it falls back to a box.
func _test_outline() -> void:
	var box_edges := XREEdgeMesh.find(BoxMesh.new())
	_check(box_edges != null and box_edges.get_edge_count() == 12, "a box has twelve edges, and its sides' diagonals aren't among them: %s"
			% (box_edges.get_edge_count() if box_edges != null else -1))
	if box_edges != null:
		var square := true
		for i: int in box_edges.points.size():
			square = square and absf(box_edges.first_normals[i].dot(box_edges.second_normals[i])) < 0.001
		_check(square, "the two faces on a box's edge are at right angles")
	var plane_edges := XREEdgeMesh.find(PlaneMesh.new())
	_check(plane_edges != null and plane_edges.get_edge_count() == 4, "a plane has the four edges of its border: %s"
			% (plane_edges.get_edge_count() if plane_edges != null else -1))
	if plane_edges != null:
		_check_vector(plane_edges.second_normals[0], -plane_edges.first_normals[0], "an edge with one face is an outline from every side")
	var ball := SphereMesh.new()
	ball.radial_segments = 12
	ball.rings = 6
	var ball_edges := XREEdgeMesh.find(ball)
	_check(ball_edges != null and ball_edges.get_edge_count() > 12, "a ball's edges are kept, to be drawn where they are its outline")
	var huge := SphereMesh.new()
	huge.radial_segments = 200
	huge.rings = 100
	_check(XREEdgeMesh.find(huge) == null, "a mesh of too many faces has no edges found")
	_check(XREEdgeMesh.find(ArrayMesh.new()) == null, "a mesh with no surfaces has none")

	var outline := XREOutline.new(Color.WHITE)
	root.add_child(outline)
	var bounds := AABB(Vector3(-0.1, -0.1, -0.1), Vector3(0.2, 0.2, 0.2))
	_check(not outline.is_active() and outline.get_part_count() == 0, "an outline starts out marking nothing")

	outline.show_node(_target, bounds)
	_check(outline.get_part_count() == 1 and not outline.is_boxed(), "a mesh has its own edges drawn: %d" % outline.get_part_count())
	outline.show_node(_scene.get_node(^"Group") as Node3D, bounds)
	_check(outline.get_part_count() == 1 and not outline.is_boxed(), "a group has the edges of its children drawn: %d" % outline.get_part_count())
	outline.show_node(_scene.get_node(^"Holder") as Node3D, bounds)
	_check(outline.get_part_count() == 1, "children the scene doesn't own have their edges drawn too: %d" % outline.get_part_count())
	# A CSG shape's mesh can't be read back in headless (the renderer is a stub): it is covered by drawing it in a window.
	outline.show_node(_scene.get_node(^"Csg") as Node3D, bounds)

	var hidden := _scene.get_node(^"Hidden") as Node3D
	outline.show_node(hidden, bounds)
	_check(outline.get_part_count() == 0 and outline.is_boxed(), "a hidden node has no edges to draw")
	hidden.visible = true
	outline.show_node(hidden, bounds)
	_check(outline.get_part_count() == 1 and not outline.is_boxed(), "...and has them when it shows")
	hidden.visible = false

	var empty := _add_node(_scene, Node3D.new(), "Empty", Vector3(30.0, 0.0, 0.0))
	outline.show_node(empty, bounds)
	_check(outline.get_part_count() == 0 and outline.is_boxed(), "a node with no geometry is boxed")
	_check_vector(outline.get_box().global_position, Vector3(30.0, 0.0, 0.0) + bounds.grow(XREBoundsBox.PADDING).position,
			"the box stands where the node's bounds are")

	var nested := CSGBox3D.new()
	nested.name = "Nested"
	_scene.get_node(^"Csg").add_child(nested)
	outline.show_node(nested, bounds)
	_check(outline.get_part_count() == 0 and outline.is_boxed(), "a CSG shape inside another has no mesh of its own, and is boxed")
	nested.free()

	var crowd := _add_node(_scene, Node3D.new(), "Crowd", Vector3(31.0, 0.0, 0.0))
	for i: int in XREOutline.MAX_PARTS:
		crowd.add_child(_box("Crowded%d" % i, 0.1))
	outline.show_node(crowd, bounds)
	_check(outline.get_part_count() == XREOutline.MAX_PARTS and not outline.is_boxed(), "a group at the limit has its edges drawn")
	crowd.add_child(_box("OneMore", 0.1))
	outline.clear()
	outline.show_node(crowd, bounds)
	_check(outline.get_part_count() == 0 and outline.is_boxed(), "a group past the limit is boxed")
	outline.clear()

	outline.show_node(_target, bounds)
	_target.hide()
	outline.show_node(_target, bounds)
	_check(outline.get_part_count() == 0, "a node that hides takes its lines with it")
	_target.show()
	outline.show_node(_target, bounds)
	_check(outline.get_part_count() == 1, "...and gets them back when it shows again")

	outline.show_box(Transform3D.IDENTITY, bounds)
	_check(outline.is_boxed() and outline.get_part_count() == 0, "a box can be asked for")
	outline.clear()
	_check(not outline.is_active() and not outline.is_boxed(), "clearing marks nothing")
	outline.free()
	empty.free()
	crowd.free()


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
	var hovered := _active_outlines(XREManipulator.HOVER_COLOR)
	_check(hovered.is_empty(), "pointing does not outline the scene object")
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 1.0, 0.0)


func _press_trigger() -> void:
	_check(_operations == ["select TOOL [\"Near\"]"], "trigger selects the node under the ray: %s" % [_operations])
	var selected := _active_outlines(XREManipulator.SELECTION_COLOR)
	_check(selected.size() == 1 and selected[0].get_part_count() == 1 and not selected[0].is_boxed(),
			"the selected node has its edges drawn: %d outlines" % selected.size())
	_check(_active_outlines(Color.WHITE).size() == 1, "selection has one white outline")
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
	_check(not _palette.is_shown(), "without their window the miniatures are hidden")
	# The Objects window, as the panels open it from the launcher (D-045); facing +Z.
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 0.0)
	_objects_tab = XREObjectsTab.new(_document)
	_objects = XREPanelWindow.new(_objects_tab, _objects_tab.get_window_size(), XREPanels.WINDOW_PIXEL_SIZE, 1.0, null)
	_rig.add_child(_objects)
	_palette.set_host(_objects, _objects_tab)


# Palette: the right hand takes things out of the Objects window. The window
# is moved so that the box's miniature is at (0, 0, 0.5): the right hand
# touching it also points at the Near box, which the manipulator would grab.

func _palette_shown() -> void:
	_check(_palette.is_shown(), "the miniatures show in their window")
	for index: int in XREPalette.ITEMS.size():
		var type: StringName = XREPalette.ITEMS[index][0]
		var expected := _objects.pixel_to_global(_objects_tab.get_cell_center(index)) + _objects.global_basis.z * XREPalette.DEPTH
		_check(_palette.get_item_transform(type).origin.is_equal_approx(expected) and _objects_tab.get_cell_name(index) == XREPalette.ITEMS[index][1],
				"%s hangs in front of its cell, named under it" % type)
	_check(_objects_tab.get_frame_color().a < 0.5, "the window is see-through")
	_objects.global_position += Vector3(0.0, 0.0, 0.5) - _palette.get_item_transform(&"CSGBox3D").origin
	_set_hand(_right, Vector3(0.0, 0.0, 0.5), 0.0, 0.0)


func _touch_miniature() -> void:
	_check(_palette.get_hovered() == &"CSGBox3D", "the right hand touches the box's miniature: %s" % _palette.get_hovered())
	_check(_objects_tab.get_hovered() == 0, "its cell lights up")
	_check(not (_rig.right_hand.get("_ray") as MeshInstance3D).visible, "with the tip inside the miniature, the ray hides (D-049)")
	_check(not _rig.right_hand.is_free_for(_manipulator), "the palette claims the hand that touches it")
	_operation_count = _operations.size()
	_set_hand(_right, Vector3(0.0, 0.0, 0.5), 0.0, 1.0)


func _take_box() -> void:
	_taken = _palette.get_held()
	_check(_taken is CSGBox3D, "grip takes a box out of its window: %s" % _taken)
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
	_check(_taken is OmniLight3D, "grip takes a light out of its window: %s" % _taken)
	if _taken == null:
		return
	var unsnapped := _palette.get_item_transform(&"OmniLight3D").origin
	_check_vector(_taken.global_position,
			Vector3(snappedf(unsnapped.x, 0.5), snappedf(unsnapped.y, 0.5), snappedf(unsnapped.z, 0.5)),
			"a node taken out snaps to the grid")
	_check_vector(_taken.scale, Vector3.ONE, "a light comes out at its natural scale")
	_left.set_input(&"ax_button", true)


func _light_thrown_away() -> void:
	_check(_palette.get_held() == null and _document.added.size() == 1, "X throws the held light away")
	_check(not is_instance_valid(_taken), "the thrown light is freed")
	_check(_operations.size() == _operation_count, "throwing away records nothing: %s" % [_operations])
	_check(_document.removed.is_empty(), "the X that throws a light away doesn't delete the selection")
	_left.set_input(&"ax_button", false)
	# The ray, from 40 cm in front, on the sphere's miniature (D-045).
	_document.snap = XRESnap.new(false, 0.5, 15.0, 10.0)
	_set_hand(_right, _palette.get_item_transform(&"CSGSphere3D").origin + Vector3(0.0, 0.0, 0.4), 0.0, 0.0)


func _sphere_hovered_by_ray() -> void:
	_check(_palette.get_hovered() == &"CSGSphere3D" and _objects_tab.get_hovered() == 2, "the right ray on a miniature lights it and its cell")
	var ray := _rig.right_hand.get("_ray") as MeshInstance3D
	_check(ray.visible and is_equal_approx(ray.scale.z, 0.4), "the ray ends at the miniature: %f" % ray.scale.z)
	_set_hand(_right, _palette.get_item_transform(&"CSGSphere3D").origin + Vector3(0.0, 0.0, 0.4), 0.0, 1.0)


func _sphere_taken_by_ray() -> void:
	_taken = _palette.get_held()
	_check(_taken is CSGSphere3D, "grip with the ray on it takes the sphere out: %s" % _taken)
	if _taken != null:
		var miniature := _palette.get_item_transform(&"CSGSphere3D")
		_check(_taken.global_transform.is_equal_approx(Transform3D(miniature.basis.orthonormalized() * XREPalette.MINIATURE_SCALE, miniature.origin)),
				"where its miniature is, as big as it: %s" % _taken.global_transform)
	_left.set_input(&"ax_button", true)


func _sphere_thrown_away() -> void:
	_check(_palette.get_held() == null and _document.added.size() == 1, "X throws it away")
	_left.set_input(&"ax_button", false)
	_set_hand(_right, Vector3(1.0, 1.5, 0.0), 0.0, 0.0)


func _delete_placed() -> void:
	_left.set_input(&"ax_button", true)


func _placed_deleted() -> void:
	_check(_document.removed.size() == 1 and _document.removed[0] is CSGBox3D, "X deletes the selection: %s" % [_document.removed])
	_check(_operations.back() == "remove_nodes TOOL [\"CSGBox3D\"]", "deleting is recorded: %s" % [_operations])
	_check(_document.get_selection().is_empty(), "nothing is selected after deleting")
	_left.set_input(&"ax_button", false)
	_commit_count = _document.commits.size()
	_set_hand(_right, Vector3(0.0, 0.0, -2.0), 0.0, 1.0)


func _grab_far() -> void:
	var far := _scene.get_node(^"Far")
	_check(_document.get_selection() == [far], "touch grab of the far box selects it: %s" % [_document.get_selection()])
	_set_hand(_right, Vector3(0.1, 0.0, -2.0), 0.0, 1.0)
	_left.set_input(&"ax_button", true)


func _held_deleted() -> void:
	var far := _document.removed.back() as Node3D
	_check(far != null and far.name == &"Far", "X deletes the node being held: %s" % [_document.removed])
	if far != null:
		_check_vector(far.position, Vector3(0.0, 0.0, -2.0), "a node deleted while held goes back where the grab found it")
	_check(_document.commits.size() == _commit_count, "a node deleted while held records no move")
	_set_hand(_right, Vector3(1.0, 1.5, 0.0), 0.0, 0.0)
	_left.set_input(&"ax_button", false)
	# The window closes, as × on its control bar closes it.
	_palette.set_host(null, null)
	_objects.queue_free()


func _point_at_spot_icon() -> void:
	_check(not _palette.is_shown(), "closing the window hides the miniatures")
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
	for outline: XREOutline in _active_outlines(XREManipulator.SELECTION_COLOR):
		if outline.is_boxed():
			var box := outline.get_box()
			outlined = true
			_check(absf(box.global_basis.x.length() - expected) < EPSILON,
					"a light's outline grows with its icon: %f, expected %f" % [box.global_basis.x.length(), expected])
			_check_vector(box.global_basis.get_scale(), Vector3.ONE * expected, "a light's outline is a cube")
	_check(outlined, "the selected light is outlined")
	_set_hand(_right, Vector3(13.0, 0.0, 1.0), 0.0, 0.0)


# The object's shortcut (D-088): the trigger held again on the selected node
# opens Delete, Rename and Blueprint; the ray picks one, letting go does it.

## Aims the right hand from [param origin] at [param target], the trigger at [param trigger].
func _aim_right(origin: Vector3, target: Vector3, trigger: float) -> void:
	_set_hand(_right, origin, trigger, 0.0, Basis.looking_at(target - origin))


func _check_shortcut_closed(what: String) -> void:
	_check(not _shortcut.is_open() and not _shortcut.is_renaming() and not _shortcut.is_dimming(), "%s: the shortcut is closed, nothing dark" % what)
	_check(_rig.right_hand.get_claimant() == null and _rig.left_hand.get_claimant() == null, "%s: the hands are free again" % what)


func _shortcut_off() -> void:
	_check(XREFeatureSettings.get_default(XREFeatureSettings.OBJECT_SHORTCUT) == XREFeatureSettings.ON, "the object's shortcut is on by default (D-089)")
	_operation_count = _operations.size()
	_set_hand(_right, Vector3(13.0, 0.0, 1.0), 1.0, 0.0)


func _shortcut_stays_shut() -> void:
	_check(not _shortcut.is_open() and _operations.size() == _operation_count, "with the shortcut off, the trigger on the selected node does nothing")
	_set_hand(_right, Vector3(13.0, 0.0, 1.0), 0.0, 0.0)
	_document.features.set_value(XREFeatureSettings.OBJECT_SHORTCUT, XREFeatureSettings.ON)


func _select_for_shortcut() -> void:
	_set_hand(_right, Vector3(1.0, 0.0, 1.0), 1.0, 0.0)


func _release_for_shortcut() -> void:
	_check(_document.get_selection() == [_scene.get_node(^"Behind")], "with the shortcut on, the trigger still selects another node: %s" % [_document.get_selection()])
	_check(not _shortcut.is_open(), "selecting opens no shortcut")
	_set_hand(_right, Vector3(1.0, 0.0, 1.0), 0.0, 0.0)


func _hold_for_shortcut() -> void:
	_operation_count = _operations.size()
	_set_hand(_right, Vector3(1.0, 0.0, 1.0), 1.0, 0.0)


func _shortcut_opened() -> void:
	_check(_shortcut.is_open() and _shortcut.is_dimming(), "the trigger again on the selected node opens its shortcut, the rest dark")
	_check(_operations.size() == _operation_count, "opening the shortcut changes nothing: %s" % [_operations.slice(_operation_count)])
	_check(_rig.right_hand.get_claimant() == _shortcut and _rig.left_hand.get_claimant() == _shortcut, "both hands are the shortcut's")
	_check_vector(_shortcut.global_position, Vector3(1.0, 0.0, 1.0 - XREObjectShortcut.DISTANCE), "it opens along the ray")
	_check(_shortcut.get_lit() == -1, "the ray where the trigger went down picks nothing")
	_check(_shortcut.get_shown() == [XREObjectShortcut.DELETE, XREObjectShortcut.DUPLICATE, XREObjectShortcut.RENAME,
			XREObjectShortcut.BLUEPRINT], "for one object, Delete, Duplicate, Rename, Blueprint: %s" % [_shortcut.get_shown()])
	_aim_right(Vector3(1.0, 0.0, 1.0), _shortcut.get_button_position(XREObjectShortcut.RENAME), 1.0)


func _rename_lit() -> void:
	_check(_shortcut.get_lit() == XREObjectShortcut.RENAME, "the ray on Rename lights it: %d" % _shortcut.get_lit())
	_aim_right(Vector3(1.0, 0.0, 1.0), _shortcut.get_button_position(XREObjectShortcut.RENAME), 0.0)


func _rename_typed() -> void:
	var keyboard := _shortcut.get_keyboard()
	_check(not _shortcut.is_open() and _shortcut.is_renaming() and _shortcut.is_dimming(), "Rename let go on opens the keyboard, the rest still dark")
	_check(keyboard.value.text == "Behind", "the keyboard starts from the name: %s" % keyboard.value.text)
	_check(_operations.size() == _operation_count, "opening the keyboard changes nothing")
	keyboard.value.text = "Crate"
	keyboard.value.text_submitted.emit(keyboard.value.text)
	var node := _document.get_selection()[0]
	_check(node.name == &"Crate", "Done renames the object: %s" % node.name)
	_check(_operations.slice(_operation_count) == ["set_property TOOL [\"Crate\"]"], "renaming is recorded: %s" % [_operations.slice(_operation_count)])
	_set_hand(_right, Vector3(1.0, 0.0, 1.0), 0.0, 0.0)


func _renamed() -> void:
	_check_shortcut_closed("after renaming")
	_set_hand(_right, Vector3(1.0, 0.0, 1.0), 1.0, 0.0)


func _delete_aimed() -> void:
	_check(_shortcut.is_open(), "the shortcut opens again on the renamed node")
	_aim_right(Vector3(1.0, 0.0, 1.0), _shortcut.get_button_position(XREObjectShortcut.DELETE), 1.0)


func _delete_lit() -> void:
	_check(_shortcut.get_lit() == XREObjectShortcut.DELETE, "the ray on Delete lights it: %d" % _shortcut.get_lit())
	_aim_right(Vector3(1.0, 0.0, 1.0), _shortcut.get_button_position(XREObjectShortcut.DELETE), 0.0)


func _deleted_by_shortcut() -> void:
	var gone := _document.removed.back() as Node
	_check(gone != null and gone.name == &"Crate", "Delete let go on removes the object: %s" % [_document.removed])
	_check(_operations.back() == "remove_nodes TOOL [\"Crate\"]", "deleting is recorded: %s" % [_operations])
	_check_shortcut_closed("after deleting")
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 1.0, 0.0)


func _near_selected() -> void:
	_check(_document.get_selection() == [_target], "the trigger selects the near box: %s" % [_document.get_selection()])
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 0.0, 0.0)


func _open_for_nothing() -> void:
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 1.0, 0.0)


func _let_go_on_nothing() -> void:
	_check(_shortcut.is_open(), "the shortcut opens on the near box")
	_operation_count = _operations.size()
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 0.0, 0.0)


func _closed_on_nothing() -> void:
	_check_shortcut_closed("let go on no button")
	_check(_operations.size() == _operation_count and _document.get_selection() == [_target], "let go on no button, nothing is done")
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 1.0, 0.0)


func _blueprint_aimed() -> void:
	_check(_shortcut.is_open(), "the shortcut opens once more")
	_aim_right(Vector3(0.0, 0.0, 0.3), _shortcut.get_button_position(XREObjectShortcut.BLUEPRINT), 1.0)


func _blueprint_lit() -> void:
	_check(_shortcut.get_lit() == XREObjectShortcut.BLUEPRINT, "the ray on Blueprint lights it: %d" % _shortcut.get_lit())
	_aim_right(Vector3(0.0, 0.0, 0.3), _shortcut.get_button_position(XREObjectShortcut.BLUEPRINT), 0.0)


func _blueprint_requested() -> void:
	_check(_blueprint_requests == 1, "Blueprint let go on asks for the object's graph: %d" % _blueprint_requests)
	_check(_target.is_inside_tree() and _document.get_selection() == [_target], "Blueprint keeps the object and its selection")
	_check_shortcut_closed("after Blueprint")
	# An open graph keeps its badge instead (D-085).
	_shortcut.blocked = func() -> bool: return true
	_operation_count = _operations.size()
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 1.0, 0.0)


func _shortcut_blocked() -> void:
	_check(not _shortcut.is_open() and _operations.size() == _operation_count, "while the graph is open the trigger on the selected node opens nothing")
	_shortcut.blocked = Callable()
	_document.features.set_value(XREFeatureSettings.OBJECT_SHORTCUT, XREFeatureSettings.OFF)
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 0.0, 0.0)


# Adding to the selection (D-115): with Other grip, the left grip held in
# empty space makes the right trigger add a box or take it out, and the right
# grip add one before grabbing. A grip on a selected box grabs the selection.

func _selection_names() -> Array:
	return _document.get_selection().map(func(node: Node) -> String: return String(node.name))


## Remembers where the boxes of lanes 30–33 are.
func _remember_group() -> void:
	for path: String in ["PairA", "PairB", "PairC", "Cart", "Cart/Load"]:
		_group_before[path] = (_scene.get_node(path) as Node3D).global_position


func _multi_start() -> void:
	_check(XREFeatureSettings.get_default(XREFeatureSettings.SELECT_ADD) == XREFeatureSettings.REPLACE,
			"the trigger replaces the selection by default")
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 0.0)
	_set_hand(_right, Vector3(30.0, 0.0, 1.0), 1.0, 0.0)


func _hold_grip_with_replace() -> void:
	_check(_selection_names() == ["PairA"], "the trigger selects the first box: %s" % [_selection_names()])
	_operation_count = _operations.size()
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 1.0)
	_set_hand(_right, Vector3(31.0, 0.0, 1.0), 0.0, 0.0)


func _trigger_with_replace() -> void:
	_check(_operations.size() == _operation_count, "a grip in empty space does nothing: %s" % [_operations.slice(_operation_count)])
	_set_hand(_right, Vector3(31.0, 0.0, 1.0), 1.0, 0.0)


func _replaced_with_grip_held() -> void:
	_check(_selection_names() == ["PairB"], "with Replace, the trigger replaces though the other grip is held: %s" % [_selection_names()])
	_document.features.set_value(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.GRIP)
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 0.0)
	_set_hand(_right, Vector3(30.0, 0.0, 1.0), 0.0, 0.0)


func _select_first() -> void:
	_set_hand(_right, Vector3(30.0, 0.0, 1.0), 1.0, 0.0)


func _hold_other_grip() -> void:
	_check(_selection_names() == ["PairA"], "with Other grip, the trigger alone still replaces: %s" % [_selection_names()])
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 1.0)
	_set_hand(_right, Vector3(31.0, 0.0, 1.0), 0.0, 0.0)


func _trigger_to_add() -> void:
	_set_hand(_right, Vector3(31.0, 0.0, 1.0), 1.0, 0.0)


func _added_by_other_grip() -> void:
	_check(_selection_names() == ["PairA", "PairB"], "the other grip held, the trigger adds the box: %s" % [_selection_names()])
	_check(_operations.back() == "select TOOL [\"PairA\", \"PairB\"]", "adding is one select of both: %s" % _operations.back())
	_check(_active_outlines(XREManipulator.SELECTION_COLOR).size() == 2, "both boxes are outlined")
	_set_hand(_right, Vector3(30.0, 0.0, 1.0), 0.0, 0.0)


func _trigger_to_take_out() -> void:
	_set_hand(_right, Vector3(30.0, 0.0, 1.0), 1.0, 0.0)


func _taken_out() -> void:
	_check(_selection_names() == ["PairB"], "the trigger on a selected box takes it out: %s" % [_selection_names()])
	_set_hand(_right, Vector3(30.0, 0.0, 1.0), 0.0, 0.0)


func _trigger_to_add_back() -> void:
	_set_hand(_right, Vector3(30.0, 0.0, 1.0), 1.0, 0.0)


func _added_back() -> void:
	_check(_selection_names() == ["PairB", "PairA"], "the trigger adds it back: %s" % [_selection_names()])
	_operation_count = _operations.size()
	_set_hand(_right, Vector3(35.0, 0.0, 1.0), 0.0, 0.0)


func _trigger_in_empty() -> void:
	_set_hand(_right, Vector3(35.0, 0.0, 1.0), 1.0, 0.0)


func _kept_in_empty() -> void:
	_check(_selection_names() == ["PairB", "PairA"] and _operations.size() == _operation_count,
			"the other grip held, the trigger in empty space keeps the selection: %s" % [_selection_names()])
	_set_hand(_right, Vector3(33.0, 0.5, 1.0), 0.0, 0.0)


func _trigger_on_child() -> void:
	_set_hand(_right, Vector3(33.0, 0.5, 1.0), 1.0, 0.0)


func _child_added() -> void:
	_check(_selection_names() == ["PairB", "PairA", "Load"], "the trigger adds the cart's load: %s" % [_selection_names()])
	_set_hand(_right, Vector3(33.0, 0.0, 1.0), 0.0, 0.0)


func _trigger_on_parent() -> void:
	_set_hand(_right, Vector3(33.0, 0.0, 1.0), 1.0, 0.0)


func _parent_added() -> void:
	_check(_selection_names() == ["PairB", "PairA", "Load", "Cart"], "and the cart: %s" % [_selection_names()])
	_remember_group()
	_commit_count = _document.commit_steps
	_set_hand(_right, Vector3(32.0, 0.0, 1.0), 0.0, 1.0)


func _group_grabbed() -> void:
	_check(_selection_names() == ["PairB", "PairA", "Load", "Cart", "PairC"],
			"the other grip held, the grip adds the box it grabs: %s" % [_selection_names()])
	_check(_rig.right_hand.get_claimant() == _manipulator, "the grabbing hand is the manipulator's")
	# The left grip lets go: the right hand holds on.
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 0.0)
	_set_hand(_right, Vector3(32.1, 0.0, 1.0), 0.0, 1.0)


func _group_moved() -> void:
	var moved := (_scene.get_node(^"PairC") as Node3D).global_position - _group_before["PairC"]
	_check(moved.x > 0.05, "the grabbed box follows the hand: %s" % moved)
	for path: String in ["PairA", "PairB", "Cart", "Cart/Load"]:
		_check_vector((_scene.get_node(path) as Node3D).global_position - _group_before[path], moved,
				"%s moves with the grabbed box" % path)
	_check(_document.commit_steps == _commit_count, "nothing is committed while holding the group")
	_set_hand(_right, Vector3(32.1, 0.0, 1.0), 0.0, 0.0)


func _group_committed() -> void:
	_check(_document.commit_steps == _commit_count + 1,
			"letting go records one undo step for the group: %d" % (_document.commit_steps - _commit_count))
	_check(_operations.back() == "transform TOOL [\"PairC\", \"PairB\", \"PairA\", \"Cart\"]",
			"the grabbed box first, not the load, which the cart carries: %s" % _operations.back())
	var befores: Array[Transform3D] = _document.commits.slice(-4)
	_check(befores.size() == 4 and befores[0].origin.is_equal_approx(Vector3(32.0, 0.0, -1.0))
			and befores[3].origin.is_equal_approx(Vector3(33.0, 0.0, -1.0)),
			"each node's undo starts where the grab found it: %s" % [befores])
	_check((_scene.get_node(^"Cart/Load") as Node3D).position.is_equal_approx(Vector3(0.0, 0.5, 0.0)),
			"the load keeps its place on the cart")
	_remember_group()
	_set_hand(_right, Vector3(_group_before["PairA"].x, 0.0, 1.0), 0.0, 1.0)


func _group_regrabbed() -> void:
	_check(_selection_names() == ["PairB", "PairA", "Load", "Cart", "PairC"],
			"a grip on a selected box keeps the selection: %s" % [_selection_names()])
	_set_hand(_right, Vector3(_group_before["PairA"].x + 0.1, 0.0, 1.0), 0.0, 1.0)


func _group_cancelled() -> void:
	_check(not (_scene.get_node(^"PairC") as Node3D).global_position.is_equal_approx(_group_before["PairC"]),
			"grabbing another selected box moves the group too")
	_document.scene_changed.emit()
	for path: String in ["PairA", "PairB", "PairC", "Cart", "Cart/Load"]:
		_check_vector((_scene.get_node(path) as Node3D).global_position, _group_before[path],
				"switching scenes puts %s back" % path)
	_check(_document.commit_steps == _commit_count + 1, "a cancelled group grab records nothing")
	_document.features.set_value(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.REPLACE)
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 0.0, 0.0)


# Copying (D-116): Duplicate in the shortcut of two selected boxes puts their
# copies beside them; with Other grip, the left grip held in empty space makes
# the right grip carry copies, which letting go puts in the scene.

func _node3d(path: String) -> Node3D:
	return _scene.get_node(path) as Node3D


## Checks that the selection is the copies named [param names], one more
## undo step of duplicate_nodes, moved by [param move] from [param originals].
func _check_copies(names: Array[String], originals: Array[String], move: Vector3, what: String) -> void:
	_check(_document.duplicate_steps == _duplicate_count + 1,
			"%s: one undo step copies them: %d" % [what, _document.duplicate_steps - _duplicate_count])
	_check(_selection_names() == names, "%s: the copies are selected: %s" % [what, _selection_names()])
	for i: int in names.size():
		var copy := _node3d(names[i])
		var original := _node3d(originals[i])
		_check(copy != null and copy.owner == _scene, "%s: %s is in the saved scene" % [what, names[i]])
		if copy == null:
			continue
		_check(copy.get_index() == original.get_index() + 1, "%s: %s comes right after its original" % [what, names[i]])
		_check_vector(copy.global_position - original.global_position, move, "%s: %s is moved from %s" % [what, names[i], originals[i]])


## Selects the boxes of lanes 36–37, as the desktop's Scene dock would.
func _select_twin_and_pal() -> void:
	var nodes: Array[Node] = [_node3d("Twin"), _node3d("Pal")]
	_document.select(nodes, XREDocument.Source.PANEL)


func _copy_start() -> void:
	_check(XREFeatureSettings.get_default(XREFeatureSettings.OBJECT_COPY) == XREFeatureSettings.SHORTCUT,
			"Duplicate in the shortcut copies by default")
	var twin: Array[Node] = [_node3d("Twin")]
	var offset := XREManipulator.copy_offset(twin, Basis.IDENTITY, Vector3.UP)
	var bounds := _node3d("Twin").global_transform * XREPicker.get_local_bounds(_node3d("Twin"))
	_check_vector(offset.origin, Vector3(bounds.size.x + XREManipulator.COPY_GAP, 0.0, 0.0),
			"a copy put beside goes right by the width of the node and its child, and a gap")
	_check(offset.basis.is_equal_approx(Basis.IDENTITY), "a copy put beside isn't turned")
	_document.features.set_value(XREFeatureSettings.OBJECT_SHORTCUT, XREFeatureSettings.ON)
	_select_twin_and_pal()
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 0.0)
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 0.0, 0.0)


func _hold_on_group() -> void:
	_operation_count = _operations.size()
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 1.0, 0.0)


func _group_shortcut_opened() -> void:
	_check(_shortcut.is_open(), "the trigger on one of two selected boxes opens the shortcut")
	_check(_shortcut.get_shown() == [XREObjectShortcut.DELETE, XREObjectShortcut.DUPLICATE],
			"for two objects, it has Delete and Duplicate: %s" % [_shortcut.get_shown()])
	_check(_selection_names() == ["Twin", "Pal"], "opening it keeps the selection: %s" % [_selection_names()])
	_aim_right(Vector3(36.0, 0.0, 1.0), _shortcut.get_button_position(XREObjectShortcut.DUPLICATE), 1.0)


func _duplicate_lit() -> void:
	_check(_shortcut.get_lit() == XREObjectShortcut.DUPLICATE, "the ray on Duplicate lights it: %d" % _shortcut.get_lit())
	_duplicate_count = _document.duplicate_steps
	_aim_right(Vector3(36.0, 0.0, 1.0), _shortcut.get_button_position(XREObjectShortcut.DUPLICATE), 0.0)


func _duplicated_by_shortcut() -> void:
	var originals: Array[Node] = [_node3d("Twin"), _node3d("Pal")]
	var move := XREManipulator.copy_offset(originals, _rig.camera.global_basis, _rig.global_basis.y).origin
	_check(move.length() > 1.0, "the copies go beside both boxes, not over one: %s" % move)
	_check_copies(["Twin2", "Pal2"], ["Twin", "Pal"], move, "Duplicate")
	_check(_operations.slice(_operation_count) == ["duplicate TOOL [\"Twin2\", \"Pal2\"]", "select TOOL [\"Twin2\", \"Pal2\"]"],
			"one duplicate of both, then the copies selected: %s" % [_operations.slice(_operation_count)])
	var part := _scene.get_node_or_null(^"Twin2/Part")
	_check(part != null and part.owner == _scene, "the twin's part is copied into the saved scene")
	_check_vector(_node3d("Twin").global_position, Vector3(36.0, 0.0, -1.0), "the original stays")
	_check_shortcut_closed("after Duplicate")
	_document.features.set_value(XREFeatureSettings.OBJECT_COPY, XREFeatureSettings.OFF)
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 0.0, 0.0)


func _hold_without_copy() -> void:
	_select_twin_and_pal()
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 1.0, 0.0)


func _shortcut_without_copy() -> void:
	_check(_shortcut.is_open() and _shortcut.get_shown() == [XREObjectShortcut.DELETE],
			"with Copy objects off, the shortcut of two objects has only Delete: %s" % [_shortcut.get_shown()])
	# Let go where it opened: on no button.
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 0.0, 0.0)


func _hold_with_grip_copy() -> void:
	_check_shortcut_closed("let go on no button")
	_document.features.set_value(XREFeatureSettings.OBJECT_COPY, XREFeatureSettings.GRIP)
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 1.0, 0.0)


func _shortcut_with_grip_copy() -> void:
	_check(_shortcut.is_open() and _shortcut.get_shown() == [XREObjectShortcut.DELETE],
			"with Other grip, the shortcut has no Duplicate: %s" % [_shortcut.get_shown()])
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 0.0, 0.0)


func _hold_with_both() -> void:
	_check_shortcut_closed("let go on no button")
	_document.features.set_value(XREFeatureSettings.OBJECT_COPY, XREFeatureSettings.BOTH)
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 1.0, 0.0)


func _shortcut_with_both() -> void:
	_check(_shortcut.is_open() and _shortcut.get_shown() == [XREObjectShortcut.DELETE, XREObjectShortcut.DUPLICATE],
			"with Both, the shortcut has Duplicate: %s" % [_shortcut.get_shown()])
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 0.0, 0.0)


# With Both, the other grip takes copies too; the Other grip value does the same.
func _copy_grip_start() -> void:
	_check_shortcut_closed("let go on no button")
	_document.features.set_value(XREFeatureSettings.OBJECT_SHORTCUT, XREFeatureSettings.OFF)
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 1.0)


func _copy_hold_other_grip() -> void:
	_select_twin_and_pal()
	_remember_copied()
	_duplicate_count = _document.duplicate_steps
	_commit_count = _document.commit_steps
	_operation_count = _operations.size()
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 0.0, 1.0)


## Remembers where the boxes of lanes 36–37 are.
func _remember_copied() -> void:
	for path: String in ["Twin", "Pal"]:
		_group_before[path] = _node3d(path).global_position


func _copy_grip_on_twin() -> void:
	_check(_rig.right_hand.get_claimant() == _manipulator, "the other grip held, the grip on a selected box holds its copies")
	_check(_active_outlines(XREManipulator.COPY_COLOR).size() == 2, "the copies of both boxes are drawn as edges: %d"
			% _active_outlines(XREManipulator.COPY_COLOR).size())
	_set_hand(_right, Vector3(36.1, 0.0, 1.0), 0.0, 1.0)


func _copies_carried() -> void:
	for path: String in ["Twin", "Pal"]:
		_check_vector(_node3d(path).global_position, _group_before[path], "carrying copies, %s stays" % path)
	_check(_operations.size() == _operation_count, "nothing is recorded while copies are carried: %s" % [_operations.slice(_operation_count)])
	# The left grip lets go: the right hand holds on to the copies.
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 0.0)
	_set_hand(_right, Vector3(36.1, 0.0, 1.0), 0.0, 1.0)


func _copies_let_go() -> void:
	_check(_active_outlines(XREManipulator.COPY_COLOR).size() == 2, "the copies stay in hand when the other grip lets go")
	_set_hand(_right, Vector3(36.1, 0.0, 1.0), 0.0, 0.0)


func _copies_placed() -> void:
	var twin := _node3d("Twin3")
	var move := twin.global_position - _group_before["Twin"] if twin != null else Vector3.ZERO
	_check(move.x > 0.05, "letting go puts the copies where the hand took them: %s" % move)
	_check_copies(["Twin3", "Pal3"], ["Twin", "Pal"], move, "Other grip")
	_check(_document.commit_steps == _commit_count, "the originals aren't moved: no transform step")
	_check(_active_outlines(XREManipulator.COPY_COLOR).is_empty(), "no copy is drawn once they are put down")
	# Grip again on the twin, now not selected, the left grip held: a click, with Other grip.
	_document.features.set_value(XREFeatureSettings.OBJECT_COPY, XREFeatureSettings.GRIP)
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 1.0)
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 0.0, 0.0)


func _copy_click() -> void:
	_duplicate_count = _document.duplicate_steps
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 0.0, 1.0)


func _copy_click_let_go() -> void:
	_check(_selection_names() == ["Twin"], "the grip on a box not selected selects it before taking its copy: %s" % [_selection_names()])
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 0.0, 0.0)


func _copy_clicked() -> void:
	var originals: Array[Node] = [_node3d("Twin")]
	var move := XREManipulator.copy_offset(originals, _rig.camera.global_basis, _rig.global_basis.y).origin
	_check_copies(["Twin4"], ["Twin"], move, "a grip let go at once")
	_duplicate_count = _document.duplicate_steps
	_set_hand(_right, Vector3(36.0, 0.0, 1.0), 0.0, 1.0)


func _copy_cancelled() -> void:
	_check(_active_outlines(XREManipulator.COPY_COLOR).size() == 1, "the grip takes a copy of the twin again")
	_document.scene_changed.emit()
	_check(_document.duplicate_steps == _duplicate_count, "switching scenes copies nothing")
	_check(_active_outlines(XREManipulator.COPY_COLOR).is_empty(), "and draws no copy")
	_document.features.set_value(XREFeatureSettings.OBJECT_COPY, XREFeatureSettings.SHORTCUT)
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 0.0)
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 0.0, 0.0)


# The selection's counter (D-118): a pill over the left controller with how
# many objects are selected, a plus while the left grip held in empty space adds.

func _counter_start() -> void:
	_check(XREFeatureSettings.get_default(XREFeatureSettings.SELECTION_COUNTER) == XREFeatureSettings.OFF, "the counter is off by default")
	_check(not _counter.get_label().visible, "off, there is no pill")
	_check(_counter.get_label().get_parent() == _rig.left_hand, "the pill goes with the left hand")
	_select_twin_and_pal()
	_document.features.set_value(XREFeatureSettings.SELECTION_COUNTER, XREFeatureSettings.ON)


func _counter_counts() -> void:
	var label := _counter.get_label()
	_check(label.visible and label.text == "2 objects", "on, the pill tells how many objects are selected: %s" % label.text)
	_check(label.modulate == XRESelectionCounter.IDLE_COLOR, "in its plain color")
	_document.features.set_value(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.GRIP)
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 1.0)


func _counter_adding() -> void:
	var label := _counter.get_label()
	_check(label.text == "+ 2 objects" and label.modulate == XRESelectionCounter.ADDING_COLOR,
			"the left grip held in empty space, the pill shows the plus in blue: %s" % label.text)
	_document.features.set_value(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.REPLACE)


func _counter_modifier_unused() -> void:
	_check(_counter.get_label().text == "2 objects", "with Replace and copies by the shortcut, the grip adds nothing: no plus")
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 0.0)
	_document.select([], XREDocument.Source.PANEL)


func _counter_hidden() -> void:
	_check(not _counter.get_label().visible, "with nothing selected the pill hides")
	_document.features.set_value(XREFeatureSettings.SELECTION_COUNTER, XREFeatureSettings.OFF)


# A brush stroke (D-119): the trigger held, the ray swept across lanes 40–42
# selects the three boxes as one selection; with the left grip held, a stroke adds.

func _brush_start() -> void:
	_check(XREFeatureSettings.get_default(XREFeatureSettings.SELECT_AREA) == XREFeatureSettings.OFF, "the brush is off by default")
	_document.features.set_value(XREFeatureSettings.SELECT_AREA, XREFeatureSettings.BRUSH)
	_document.select([], XREDocument.Source.PANEL)
	_operation_count = _operations.size()
	_set_hand(_right, Vector3(40.0, 0.0, 1.0), 1.0, 0.0)


func _brush_first() -> void:
	_check(_document.get_selection().is_empty() and _operations.size() == _operation_count,
			"while the trigger is held, nothing is selected yet: %s" % [_operations.slice(_operation_count)])
	_check(_active_outlines(XREManipulator.SELECTION_COLOR).size() == 1, "the box the stroke began on is outlined")
	_set_hand(_right, Vector3(41.0, 0.0, 1.0), 1.0, 0.0)


func _brush_second() -> void:
	_set_hand(_right, Vector3(41.5, 0.0, 1.0), 1.0, 0.0)


func _brush_gap() -> void:
	_check(_active_outlines(XREManipulator.SELECTION_COLOR).size() == 2, "the ray between boxes adds nothing")
	_set_hand(_right, Vector3(42.0, 0.0, 1.0), 1.0, 0.0)


func _brush_third() -> void:
	_check(_active_outlines(XREManipulator.SELECTION_COLOR).size() == 3, "every box the ray crossed is outlined")
	_set_hand(_right, Vector3(42.0, 0.0, 1.0), 0.0, 0.0)


func _brush_done() -> void:
	_check(_selection_names() == ["Brush1", "Brush2", "Brush3"], "letting go selects the stroke: %s" % [_selection_names()])
	_check(_operations.slice(_operation_count) == ["select TOOL [\"Brush1\", \"Brush2\", \"Brush3\"]"],
			"as one selection: %s" % [_operations.slice(_operation_count)])
	_document.features.set_value(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.GRIP)
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 1.0)
	_set_hand(_right, Vector3(40.0, 0.0, 1.0), 0.0, 0.0)


func _brush_add_start() -> void:
	_set_hand(_right, Vector3(40.0, 0.0, 1.0), 1.0, 0.0)


func _brush_add_on() -> void:
	_check(_selection_names() == ["Brush2", "Brush3"], "the left grip held, the trigger takes the selected box out at once: %s" % [_selection_names()])
	_set_hand(_right, Vector3(43.0, 0.0, 1.0), 1.0, 0.0)


func _brush_add_more() -> void:
	_set_hand(_right, Vector3(43.0, 0.0, 1.0), 0.0, 0.0)


func _brush_added() -> void:
	_check(_selection_names() == ["Brush2", "Brush3", "Brush4"],
			"the stroke adds what it crossed, and leaves the box it began on out: %s" % [_selection_names()])
	_document.features.set_value(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.REPLACE)
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 0.0)
	_set_hand(_right, Vector3(45.0, 0.0, 1.0), 1.0, 0.0)


func _brush_click_empty() -> void:
	_set_hand(_right, Vector3(45.0, 0.0, 1.0), 0.0, 0.0)


func _brush_cleared() -> void:
	_check(_document.get_selection().is_empty(), "a click in empty space is a stroke of nothing: it clears the selection")
	# The editor tells of a new selection in a later frame: the stroke stays shown until then.
	var nodes: Array[Node] = [_scene.get_node(^"Brush1"), _scene.get_node(^"Brush2")]
	_document.select(nodes, XREDocument.Source.PANEL)
	_document.late_selection = true
	_set_hand(_right, Vector3(43.0, 0.0, 1.0), 0.0, 0.0)


func _brush_late_press() -> void:
	_set_hand(_right, Vector3(43.0, 0.0, 1.0), 1.0, 0.0)


func _brush_late_release() -> void:
	_set_hand(_right, Vector3(43.0, 0.0, 1.0), 0.0, 0.0)


func _brush_late_shown() -> void:
	_check(_selection_names() == ["Brush4"], "the click selects the box: %s" % [_selection_names()])
	_check(_active_outlines(XREManipulator.SELECTION_COLOR).size() == 1,
			"before the editor tells of it, the click's box alone is outlined, not the selection before it: %d"
			% _active_outlines(XREManipulator.SELECTION_COLOR).size())
	_document.late_selection = false
	_document.selection_changed.emit()


func _brush_late_told() -> void:
	_check(_active_outlines(XREManipulator.SELECTION_COLOR).size() == 1, "told, the selection's outline takes over")
	_document.features.set_value(XREFeatureSettings.SELECT_AREA, XREFeatureSettings.OFF)
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 0.0, 0.0)


# A selection box (D-120): drawn a meter before the head, from (-0.4, 0.8) to
# (0.4, 1.2) on its plane, it takes the three high boxes, not the one beside
# them nor the one hidden behind the middle one.

func _box_start() -> void:
	_document.features.set_value(XREFeatureSettings.SELECT_AREA, XREFeatureSettings.BOX)
	_document.select([], XREDocument.Source.PANEL)
	_operation_count = _operations.size()
	_set_hand(_right, Vector3(-0.4, 0.8, 1.0), 1.0, 0.0)


func _box_drag() -> void:
	_set_hand(_right, Vector3(0.4, 1.2, 1.0), 1.0, 0.0)


func _box_drawn() -> void:
	var lines := _manipulator.get_node(^"SelectionBox") as XREBoundsBox
	_check(lines.visible, "while the trigger is held, the box is drawn")
	_check(_document.get_selection().is_empty() and _operations.size() == _operation_count, "and nothing is selected yet")
	_check(absf(lines.global_position.z + XREManipulator.BOX_DISTANCE) < 0.01, "a meter before the head: %s" % lines.global_position)
	_set_hand(_right, Vector3(0.4, 1.2, 1.0), 0.0, 0.0)


func _box_done() -> void:
	_check(_selection_names() == ["High1", "High2", "High3"], "letting go selects what is in the box and not hidden: %s" % [_selection_names()])
	_check(_operations.slice(_operation_count).size() == 1, "as one selection: %s" % [_operations.slice(_operation_count)])
	_check(not (_manipulator.get_node(^"SelectionBox") as XREBoundsBox).visible, "and the box goes")
	var nodes: Array[Node] = [_scene.get_node(^"High4")]
	_document.select(nodes, XREDocument.Source.PANEL)
	_document.features.set_value(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.GRIP)
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 1.0)
	_set_hand(_right, Vector3(-0.3, 0.9, 1.0), 0.0, 0.0)


func _box_add_press() -> void:
	_set_hand(_right, Vector3(-0.3, 0.9, 1.0), 1.0, 0.0)


func _box_add_drag() -> void:
	_set_hand(_right, Vector3(-0.1, 1.1, 1.0), 1.0, 0.0)


func _box_add_release() -> void:
	_set_hand(_right, Vector3(-0.1, 1.1, 1.0), 0.0, 0.0)


func _box_added() -> void:
	_check(_selection_names() == ["High4", "High1"], "the left grip held, the box adds: %s" % [_selection_names()])
	_document.features.set_value(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.REPLACE)
	_set_hand(_left, Vector3(-5.0, 0.0, 0.0), 0.0, 0.0)
	_set_hand(_right, Vector3(0.6, 3.0, 1.0), 1.0, 0.0)


func _box_click() -> void:
	_set_hand(_right, Vector3(0.6, 3.0, 1.0), 0.0, 0.0)


func _box_clicked() -> void:
	_check(_selection_names() == ["High3"], "a click selects what is under the ray, as before: %s" % [_selection_names()])
	_document.features.set_value(XREFeatureSettings.SELECT_AREA, XREFeatureSettings.OFF)
	_set_hand(_right, Vector3(0.0, 0.0, 0.3), 0.0, 0.0)


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
	_right.set_input(&"primary", Vector2(0.0, 1.0))


func _tilted_up() -> void:
	var forward := -_rig.global_basis.z
	_check(is_zero_approx(forward.y), "vertical right stick input keeps the horizon level: %s" % forward)
	_check(is_zero_approx(_rig.global_basis.x.y), "vertical input does not roll the rig")
	_right.set_input(&"primary", Vector2.ZERO)
	_right.set_input(&"primary_click", true)


func _levelled() -> void:
	_check(_rig.global_basis.y.is_equal_approx(Vector3.UP), "right stick click leaves the rig upright")
	_check(is_zero_approx(_rig.global_basis.x.y), "levelling doesn't roll the rig: %s" % _rig.global_basis.x)
	_right.set_input(&"primary_click", false)


func _finish() -> void:
	for node: Node in _document.removed:
		node.free()
	for tracker in _trackers:
		XRServer.remove_tracker(tracker)
	print("test_tools: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)
