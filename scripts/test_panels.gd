extends SceneTree
## Headless tests of the panels in the headset: XREPanels with the forearm
## panel and windows, driven by fake controller trackers over a fake document,
## the scene, signals and file system tabs, and XREInspectorProxy. The
## inspector itself needs the editor (scripts/test_inspector.gd). Used by
## scripts/check.sh, not shipped with the plugin. Prints "test_panels: FAILED ..."
## for every failed check and a summary line at the end.

const EPSILON := 0.001
## How far in front of a panel the tests hold the hand that points at it, in meters.
const AIM_DISTANCE := 0.3


## A fake document: records what panels do instead of touching an editor.
class FakeDocument extends XREDocument:
	var root: Node
	var selection: Array[Node] = []
	## Folder paths to their entries, as list_folder() gives them.
	var folders: Dictionary[String, PackedStringArray] = {}
	## Scenes open_scene() can open, by path.
	var scenes: Dictionary[String, Node] = {}
	var previews: Array[String] = []
	## The "before" value of every commit_property().
	var commits: Array = []

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

	func commit_transform(node: Node3D, _before: Transform3D, source: Source) -> void:
		_record(&"transform", source, [node])

	func set_property(object: Object, property: StringName, value: Variant, source: Source) -> void:
		object.set(property, value)
		_record(&"set_property", source, [object as Node])

	func preview_property(object: Object, property: StringName, value: Variant) -> void:
		object.set(property, value)
		previews.append("%s=%s" % [property, value])

	func commit_property(object: Object, property: StringName, before: Variant, source: Source) -> void:
		commits.append(before)
		_record(&"set_property", source, [object as Node])
		previews.append("commit %s" % property)

	func add_node(node: Node, parent: Node, source: Source) -> void:
		parent.add_child(node, true)
		node.owner = root
		_record(&"add_node", source, [node])

	func remove_nodes(_nodes: Array[Node], _source: Source) -> void:
		pass

	func save(_source: Source) -> Error:
		return OK

	func open_scene(path: String, source: Source) -> Error:
		if not scenes.has(path):
			return ERR_FILE_NOT_FOUND
		root = scenes[path]
		selection.clear()
		_record(&"open_scene", source, [root])
		scene_changed.emit()
		selection_changed.emit()
		return OK

	func list_folder(path: String) -> PackedStringArray:
		return folders.get(path, PackedStringArray())

	func get_file_type(path: String) -> StringName:
		return &"PackedScene" if path.get_extension() == "tscn" else &"Texture2D"

	func play(_source: Source, _separate_app: bool) -> Error:
		return OK

	func stop_playing(_source: Source) -> void:
		pass

	func is_playing() -> bool:
		return false

	func get_snap() -> XRESnap:
		return XRESnap.new(false, 0.0, 0.0, 0.0)


var _checks := 0
var _failures := 0
var _frame := 0
var _steps: Array[Callable] = []

var _document: FakeDocument
var _operations: Array[String] = []
var _trackers: Array[XRControllerTracker] = []
var _right: XRControllerTracker
var _left: XRControllerTracker
var _rig: XRERig
var _locomotion: XRELocomotion
var _palette: XREPalette
var _panels: XREPanels
var _manipulator: XREManipulator
var _hand_panel: XREHandPanel

var _scene: Node3D
var _other: Node3D
var _box: Node3D
var _lamp: OmniLight3D
var _trigger: Area3D
var _left_aim := Transform3D(Basis.IDENTITY, Vector3(-0.2, -0.3, -0.3))
var _operation_count := 0
var _window_before: Vector3
var _rig_before: Vector3
var _hold_distance := 0.0


func _initialize() -> void:
	_steps = [
		_build,
		_show_panel,
		_scene_tab_filled,
		_point_at_box,
		_click_box,
		_box_selected,
		_selection_shows,
		_click_signals_tab,
		_signals_listed,
		_click_pop_out,
		_window_opened,
		_window_listed,
		_hover_with_stick,
		_not_turned,
		_tear_off_files,
		_carry_files,
		_files_carried,
		_files_placed,
		_push_files,
		_files_pushed,
		_fly,
		_flown,
		_change_scene,
		_scene_changed,
		_unfold_folder,
		_folder_unfolded,
		_double_click_scene_1,
		_double_click_scene_2,
		_double_click_scene_3,
		_double_click_scene_4,
		_scene_opened,
		_close_signals_window,
		_signals_window_closed,
		_point_past_panels,
		_room_selected,
		_test_proxy,
		_test_inspector_tab,
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
		printerr("test_panels: FAILED ", what)


func _check_vector(actual: Vector3, expected: Vector3, what: String) -> void:
	_check(actual.distance_to(expected) < EPSILON, "%s: %s, expected %s" % [what, actual, expected])


func _build() -> void:
	_scene = _make_scene("Scene")
	_box = _add(_scene, Node3D.new(), "Box")
	_lamp = _add(_scene, OmniLight3D.new(), "Lamp") as OmniLight3D
	_trigger = _add(_scene, Area3D.new(), "Trigger") as Area3D
	# Saved with the scene, and one made at run time, which the Node dock doesn't list.
	_trigger.body_entered.connect(Callable(_lamp, &"set_visible"), CONNECT_PERSIST)
	_trigger.body_exited.connect(Callable(_lamp, &"set_visible"))
	# An instanced scene: its own nodes are not the scene's.
	var prop := Node3D.new()
	var inside := Node3D.new()
	inside.name = "Inside"
	prop.add_child(inside)
	inside.owner = prop
	var packed := PackedScene.new()
	packed.pack(prop)
	prop.free()
	_add(_scene, packed.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE) as Node3D, "Prop")
	# A room around everything: the manipulator selects it wherever a free ray points.
	var room := CSGBox3D.new()
	room.size = Vector3(20.0, 20.0, 20.0)
	room.custom_aabb = AABB(Vector3(-10.0, -10.0, -10.0), Vector3(20.0, 20.0, 20.0))
	_add(_scene, room, "Room")
	root.add_child(_scene)
	_other = _make_scene("Other")
	root.add_child(_other)

	_document = FakeDocument.new()
	_document.root = _scene
	_document.folders = {
		"res://": PackedStringArray(["levels/", "icon.svg", "main.tscn"]),
		"res://levels/": PackedStringArray(["level_1.tscn"]),
	}
	_document.scenes = {"res://main.tscn": _other}
	_document.operation_recorded.connect(
			func(operation: StringName, source: XREDocument.Source, nodes: Array[Node], _time_usec: int) -> void:
				_operations.append("%s %s %s" % [operation, XREDocument.Source.keys()[source], nodes.map(
						func(node: Node) -> String: return String(node.name))]))

	_right = _add_tracker(&"right_hand")
	_left = _add_tracker(&"left_hand")
	_rig = XRERig.new()
	# In the plugin's order.
	_locomotion = XRELocomotion.new(_rig)
	_rig.add_child(_locomotion)
	var icons := XREIcons.new(_document, _rig)
	_rig.add_child(icons)
	_palette = XREPalette.new(_document, _rig)
	_rig.add_child(_palette)
	_panels = XREPanels.new(_document, _rig, _palette, null, 1.0)
	_rig.add_child(_panels)
	_manipulator = XREManipulator.new(_document, _rig, icons)
	_rig.add_child(_manipulator)
	root.add_child(_rig)
	_hand_panel = _panels.get_hand_panel()
	_pose(_left, _left_aim, 0.0, 0.0)
	_pose(_right, Transform3D(Basis.IDENTITY, Vector3(0.2, -0.3, -0.3)), 0.0, 0.0)
	_left.set_input(&"ax_button", true)


func _make_scene(scene_name: String) -> Node3D:
	var scene := Node3D.new()
	scene.name = scene_name
	return scene


func _add(parent: Node3D, node: Node3D, node_name: String) -> Node3D:
	node.name = node_name
	parent.add_child(node)
	node.owner = parent
	return node


func _add_tracker(tracker_name: StringName) -> XRControllerTracker:
	var tracker := XRControllerTracker.new()
	tracker.name = tracker_name
	XRServer.add_tracker(tracker)
	_trackers.append(tracker)
	return tracker


## Puts [param tracker] at [param xform], in global space.
func _pose(tracker: XRControllerTracker, xform: Transform3D, trigger: float, grip: float) -> void:
	tracker.set_pose(&"aim", _rig.global_transform.affine_inverse() * xform if _rig != null else xform,
			Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	tracker.set_input(&"trigger", trigger)
	tracker.set_input(&"grip", grip)


## Points the right hand at [param pixel] of [param surface] from [constant AIM_DISTANCE] in front of it.
func _aim(surface: XREPanelSurface, pixel: Vector2, trigger: float, grip: float = 0.0) -> void:
	var target := surface.pixel_to_global(pixel)
	var origin := target + surface.global_basis.z.normalized() * AIM_DISTANCE
	_pose(_right, Transform3D(Basis.looking_at(target - origin), origin), trigger, grip)


## Center of [param control] in its panel's pixels.
func _center(control: Control) -> Vector2:
	return control.get_global_rect().get_center()


## Center of [param item] of [param tree] in its panel's pixels.
func _item_center(tree: Tree, item: TreeItem) -> Vector2:
	var rect := tree.get_item_area_rect(item)
	return tree.get_global_transform() * (rect.position + rect.size * 0.5)


func _scene_tab() -> XRESceneTab:
	return _hand_panel.get_tabs()[0] as XRESceneTab


func _texts(tree: Tree) -> Array[String]:
	var texts: Array[String] = []
	var item := tree.get_root()
	while item != null:
		texts.append(item.get_text(0))
		item = item.get_next_in_tree()
	return texts


# Forearm panel and the scene tab.

func _show_panel() -> void:
	_check(_palette.is_shown() and _hand_panel.is_shown(), "X shows the tray and the forearm panel")
	_check(_hand_panel.global_transform.is_equal_approx(_left_aim * XREPanels.HAND_OFFSET),
			"the panel lies on the forearm: %s" % _hand_panel.global_transform)
	_left.set_input(&"ax_button", false)


func _scene_tab_filled() -> void:
	var texts := _texts(_scene_tab().get_tree_control())
	_check(texts == ["Scene", "Box", "Lamp", "Trigger", "Prop", "Room"],
			"the scene tab shows the scene's own nodes: %s" % [texts])
	_check(_scene_tab().is_visible_in_tree() and not (_hand_panel.get_tabs()[2] as XREPanelTab).is_visible_in_tree(),
			"the scene tab is shown first, the others are hidden")
	_aim(_hand_panel, _item_center(_scene_tab().get_tree_control(), _scene_tab().get_item(_box)), 0.0)


func _point_at_box() -> void:
	_check(not _rig.right_hand.is_free_for(_manipulator), "a hand on a panel is claimed")
	_check(not _rig.right_hand.is_stick_free_for(_locomotion), "and its thumbstick too")
	_operation_count = _operations.size()
	_aim(_hand_panel, _item_center(_scene_tab().get_tree_control(), _scene_tab().get_item(_box)), 1.0)


func _click_box() -> void:
	_aim(_hand_panel, _item_center(_scene_tab().get_tree_control(), _scene_tab().get_item(_box)), 0.0)


func _box_selected() -> void:
	_check(_operations.slice(_operation_count) == ["select PANEL [\"Box\"]"],
			"a click in the scene tab selects the node, from a panel, and nothing behind the panel: %s"
			% [_operations.slice(_operation_count)])
	_document.select([_trigger], XREDocument.Source.TOOL)


func _selection_shows() -> void:
	var tree := _scene_tab().get_tree_control()
	var selected := tree.get_next_selected(null)
	_check(selected == _scene_tab().get_item(_trigger) and tree.get_next_selected(selected) == null,
			"a selection made elsewhere shows in the scene tab")
	_aim(_hand_panel, _tab_center(2), 1.0)


func _tab_center(index: int) -> Vector2:
	var bar := _hand_panel.get_tab_bar()
	return bar.get_global_transform() * bar.get_tab_rect(index).get_center()


# Signals tab and windows.

func _click_signals_tab() -> void:
	_aim(_hand_panel, _tab_center(2), 0.0)


func _signals_listed() -> void:
	var tab := _hand_panel.get_current_tab() as XRESignalsTab
	_check(tab != null, "a click on a tab shows it")
	if tab == null:
		return
	var texts := _texts(tab.get_tree_control())
	var entered := texts.find("body_entered(body: Node3D)")
	var exited := texts.find("body_exited(body: Node3D)")
	_check(texts.has("Area3D") and texts.has("Node") and texts.find("Area3D") < texts.find("Node"),
			"signals are listed by class, the node's own first: %s" % [texts])
	_check(entered >= 0 and texts[entered + 1] == "→ Lamp :: set_visible()",
			"a connection saved with the scene shows under its signal: %s" % [texts])
	_check(exited >= 0 and not texts[exited + 1].begins_with("→"), "a connection made at run time doesn't show")
	_aim(_hand_panel, _center(_hand_panel.get_pop_out_button()), 1.0)


func _click_pop_out() -> void:
	_aim(_hand_panel, _center(_hand_panel.get_pop_out_button()), 0.0)


func _window_opened() -> void:
	var window := _panels.find_window(XRESignalsTab)
	_check(_panels.get_windows().size() == 1 and window != null, "the button opens the tab as a window")
	if window == null:
		return
	# The head tracker is absent: the head is at the rig's origin, looking down -Z.
	_check_vector(window.global_position, Vector3(0.0, -XREPanels.WINDOW_DROP, -XREPanels.WINDOW_DISTANCE),
			"the window opens in front of the user")
	_check(window.global_basis.z.dot(-window.global_position.normalized()) > 0.999, "and faces the head")
	_check(window.tab is XRESignalsTab and window.tab != _hand_panel.get_current_tab(), "with its own tab")


func _window_listed() -> void:
	var window := _panels.find_window(XRESignalsTab)
	if window == null:
		return
	var texts := _texts((window.tab as XRESignalsTab).get_tree_control())
	_check(texts.has("→ Lamp :: set_visible()"), "the window's tab shows the selection too: %s" % [texts])
	_aim(window, window.size_px * 0.5, 0.0)
	_right.set_input(&"primary", Vector2(1.0, 0.0))


func _hover_with_stick() -> void:
	_rig_before = -_rig.global_basis.z
	_right.set_input(&"primary", Vector2(1.0, 0.0))


func _not_turned() -> void:
	_check((-_rig.global_basis.z).is_equal_approx(_rig_before) and _rig_before.is_equal_approx(Vector3.FORWARD),
			"the right stick doesn't turn the user while the ray is on a panel")
	_right.set_input(&"primary", Vector2.ZERO)
	_hand_panel.select_tab(3)
	_aim(_hand_panel, _hand_panel.size_px * 0.5, 0.0, 1.0)


func _tear_off_files() -> void:
	var window := _panels.find_window(XREFileSystemTab)
	_check(window != null and _panels.get_held_window(_rig.right_hand) == window,
			"grip on the forearm panel pulls its tab out as a window, in hand")
	if window == null:
		return
	_check_vector(window.global_position, _hand_panel.pixel_to_global(_hand_panel.size_px * 0.5),
			"the window comes out where the ray hit the panel")
	_window_before = window.global_position
	var hand := _rig.right_hand.global_transform
	_pose(_right, hand.translated(Vector3(0.2, 0.0, 0.0)), 0.0, 1.0)


func _carry_files() -> void:
	pass


func _files_carried() -> void:
	var window := _panels.find_window(XREFileSystemTab)
	if window == null:
		return
	_check_vector(window.global_position, _window_before + Vector3(0.2, 0.0, 0.0), "the window follows the hand")
	var to_head := (_rig.camera.global_position - window.global_position).normalized()
	_check(window.global_basis.z.dot(to_head) > 0.999, "and turns to face the head")
	_window_before = window.global_position
	_pose(_right, _rig.right_hand.global_transform, 0.0, 0.0)


func _files_placed() -> void:
	var window := _panels.find_window(XREFileSystemTab)
	_check(_panels.get_held_window(_rig.right_hand) == null and window != null
			and window.global_position.is_equal_approx(_window_before), "letting go leaves the window where it is")
	if window == null:
		return
	_aim(window, window.size_px * 0.5, 0.0, 1.0)


func _push_files() -> void:
	_hold_distance = _rig.right_hand.global_position.distance_to(_panels.find_window(XREFileSystemTab).global_position)
	_right.set_input(&"primary", Vector2(0.0, 1.0))


func _files_pushed() -> void:
	var window := _panels.find_window(XREFileSystemTab)
	var distance := _rig.right_hand.global_position.distance_to(window.global_position)
	_check(distance > _hold_distance, "the right stick pushes a held window away: %f to %f" % [_hold_distance, distance])
	_right.set_input(&"primary", Vector2.ZERO)
	_pose(_right, _rig.right_hand.global_transform, 0.0, 0.0)


# Windows go with the user and stay with another scene.

func _fly() -> void:
	_rig_before = _rig.global_position
	_window_before = _panels.find_window(XRESignalsTab).global_position
	_left.set_input(&"primary", Vector2(0.0, 1.0))


func _flown() -> void:
	var flown := _rig.global_position - _rig_before
	_check(flown.length() > 0.0, "the left stick flies while a window is open")
	_check_vector(_panels.find_window(XRESignalsTab).global_position - _window_before, flown,
			"windows travel with the user")
	_left.set_input(&"primary", Vector2.ZERO)


func _change_scene() -> void:
	_document.root = _other
	_document.selection.clear()
	_document.scene_changed.emit()
	_document.selection_changed.emit()
	_hand_panel.select_tab(0)


func _scene_changed() -> void:
	_check(_panels.get_windows().size() == 2, "windows stay when the scene changes")
	var texts := _texts(_scene_tab().get_tree_control())
	_check(texts == ["Other"], "the scene tab shows the scene now edited: %s" % [texts])


# File system tab: folders unfold on demand, and a double click opens a scene.

func _files_tab() -> XREFileSystemTab:
	return _panels.find_window(XREFileSystemTab).tab as XREFileSystemTab


func _unfold_folder() -> void:
	var tab := _files_tab()
	var texts := _texts(tab.get_tree_control())
	_check(texts == ["res://", "levels", "", "icon.svg", "main.tscn"],
			"the file system tab lists the project's root, a folder's entries unread: %s" % [texts])
	tab.get_item("res://levels/").collapsed = false


func _folder_unfolded() -> void:
	var texts := _texts(_files_tab().get_tree_control())
	_check(texts == ["res://", "levels", "level_1.tscn", "icon.svg", "main.tscn"],
			"unfolding a folder reads its entries: %s" % [texts])
	_operation_count = _operations.size()
	_document.scenes["res://main.tscn"] = _scene


func _aim_main(trigger: float) -> void:
	var window := _panels.find_window(XREFileSystemTab)
	var tab := _files_tab()
	_aim(window, _item_center(tab.get_tree_control(), tab.get_item("res://main.tscn")), trigger)


func _double_click_scene_1() -> void:
	_aim_main(1.0)


func _double_click_scene_2() -> void:
	_check(_files_tab().get_tree_control().get_selected() == _files_tab().get_item("res://main.tscn"),
			"a click selects a file")
	_check(not _files_tab().get_open_button().disabled, "Open is on for a scene")
	_check(_operations.size() == _operation_count, "a single click opens nothing")
	_aim_main(0.0)


func _double_click_scene_3() -> void:
	_aim_main(1.0)


func _double_click_scene_4() -> void:
	_aim_main(0.0)


func _scene_opened() -> void:
	_check(_operations.slice(_operation_count) == ["open_scene PANEL [\"Scene\"]"],
			"a double click on a scene opens it, from a panel: %s" % [_operations.slice(_operation_count)])
	_check(_panels.get_windows().size() == 2, "windows stay when a scene is opened from them")
	var window := _panels.find_window(XRESignalsTab)
	_aim(window, _center(window.get_close_button()), 1.0)


func _close_signals_window() -> void:
	var window := _panels.find_window(XRESignalsTab)
	_aim(window, _center(window.get_close_button()), 0.0)


func _signals_window_closed() -> void:
	_check(_panels.find_window(XRESignalsTab) == null and _panels.get_windows().size() == 1,
			"× closes the window")
	_operation_count = _operations.size()
	# Away from every panel, at the room's wall.
	_pose(_right, Transform3D(Basis.IDENTITY, _rig.global_position + Vector3(0.3, 0.0, 0.0)).rotated_local(
			Vector3.UP, -PI / 2.0), 1.0, 0.0)


func _point_past_panels() -> void:
	_pose(_right, _rig.right_hand.global_transform, 0.0, 0.0)


func _room_selected() -> void:
	_check(_rig.right_hand.is_free_for(_manipulator) and _rig.right_hand.is_stick_free_for(_locomotion),
			"a hand off the panels is let go")
	_check(_operations.slice(_operation_count) == ["select TOOL [\"Room\"]"],
			"the trigger off the panels selects in the scene, as before: %s" % [_operations.slice(_operation_count)])


# The inspector's proxy.

func _test_proxy() -> void:
	var node := Node3D.new()
	var listed := XREInspectorProxy.for_inspector(node.get_property_list())
	var names: Array[String] = []
	for property: Dictionary in listed:
		names.append(property["name"])
	_check(names.find("Node3D") >= 0 and names.find("Node3D") < names.find("Node"),
			"the proxy lists a class's properties before its parent's: %s" % [names])
	_check(names.find("position") < names.find("Node") and names.find("process_mode") > names.find("Node"),
			"each with its own class")
	_check(not names.has("script"), "the script is left out")
	var visibility_parent: Dictionary = listed[names.find("visibility_parent")]
	var path_usage: int = visibility_parent["usage"]
	_check(path_usage & PROPERTY_USAGE_READ_ONLY != 0, "node paths are read only")
	var position_usage: int = listed[names.find("position")]["usage"]
	_check(position_usage & PROPERTY_USAGE_READ_ONLY == 0, "values are not")

	_scene.add_child(node)
	node.name = "Edited"
	node.position = Vector3(1.0, 0.0, 0.0)
	var proxy := XREInspectorProxy.new(_document, node)
	_check(proxy.get(&"position") == Vector3(1.0, 0.0, 0.0), "the proxy reads the node")
	_check(proxy.property_can_revert(&"position") and proxy.property_get_revert(&"position") == Vector3.ZERO,
			"and reverts to the class's default")
	_operation_count = _operations.size()
	_document.previews.clear()
	_document.commits.clear()
	proxy.set(&"position", Vector3(2.0, 0.0, 0.0))
	proxy.set(&"position", Vector3(3.0, 0.0, 0.0))
	_check(node.position == Vector3(3.0, 0.0, 0.0) and _operations.size() == _operation_count,
			"setting a value through the proxy previews it, without an operation")
	proxy.set(&"visible", false)
	proxy.commit()
	proxy.commit()
	_check(_document.previews == ["position=(2.0, 0.0, 0.0)", "position=(3.0, 0.0, 0.0)", "commit position",
			"visible=false", "commit visible"], "a drag is one commit; another property commits the first: %s"
			% [_document.previews])
	_check(_document.commits == [Vector3(1.0, 0.0, 0.0), true], "undo goes back to the value before the drag: %s"
			% [_document.commits])
	_check(_operations.slice(_operation_count) == ["set_property PANEL [\"Edited\"]", "set_property PANEL [\"Edited\"]"],
			"each commit is one operation from a panel: %s" % [_operations.slice(_operation_count)])
	proxy.set(&"visible", true)
	proxy.set(&"visible", false)
	proxy.commit()
	_check(_document.commits.size() == 2, "a value set back where it was commits nothing")
	proxy.set(&"no_such_property", 1)
	_check(proxy.get(&"no_such_property") == null, "the proxy has the node's properties only")
	node.free()


func _test_inspector_tab() -> void:
	var tab := _hand_panel.get_tabs()[1] as XREInspectorTab
	_document.select([_lamp], XREDocument.Source.TOOL)
	_hand_panel.select_tab(1)
	_check(tab.get_title() == XREPanelTab.editor_text("Inspector") and tab.get_inspector() == null,
			"without the editor the inspector tab has no inspector")


func _finish() -> void:
	for tracker in _trackers:
		XRServer.remove_tracker(tracker)
	print("test_panels: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)
