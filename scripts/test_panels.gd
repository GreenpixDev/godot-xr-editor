extends SceneTree
## Headless tests of the panels in the headset: XREPanels with the tab
## launcher, windows and windows pinned to a hand, driven by fake controller trackers over a fake document,
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
## A small node in front of a window (D-047).
var _small: CSGBox3D
## A panel with a long list, for drag scrolling (D-045), and where its list was.
var _scroll_panel: XREPanelSurface
var _scroll_list: ItemList
var _scroll_value := 0.0
var _panels: XREPanels
var _manipulator: XREManipulator
var _launcher: XRETabLauncher

var _scene: Node3D
var _other: Node3D
var _box: Node3D
var _lamp: OmniLight3D
var _trigger: Area3D
var _left_aim := Transform3D(Basis.IDENTITY, Vector3(-0.2, -0.3, -0.3))
var _operation_count := 0
var _window_before: Vector3
## Where the windows were before a history check (D-087), and where the FileSystem window was.
var _layout_before: Dictionary = {}
var _files_transform := Transform3D.IDENTITY
var _rig_before: Vector3
var _hold_distance := 0.0
## Clicks on the launcher's Playtest tile, and the windows open before them.
var _playtests := 0
var _window_count := 0


func _initialize() -> void:
	_steps = [
		_build,
		_show_launcher,
		_click_scene_tile,
		_scene_window_opened,
		_show_bar,
		_click_pin_left,
		_scene_pinned,
		_scene_on_forearm,
		_point_at_box,
		_click_box,
		_box_selected,
		_selection_shows,
		_launcher_again,
		_click_signals_tile,
		_signals_listed,
		_aim_at_corner,
		_corner_lit,
		_corner_taken,
		_corner_carried,
		_corner_brought_back,
		_corner_let_go,
		_handles_on_window,
		_handles_hidden,
		_window_listed,
		_hover_with_stick,
		_not_turned,
		_tear_off_scene,
		_carry_scene,
		_scene_carried,
		_scene_placed,
		_push_scene,
		_scene_pushed,
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
		_press_close,
		_close_signals_window,
		_signals_window_closed,
		_point_past_panels,
		_room_selected,
		_test_corner_zones,
		_test_feature_store,
		_open_settings,
		_hover_cuboid,
		_press_cuboid,
		_release_cuboid,
		_cuboid_set,
		_controls_page,
		_controls_page_captured,
		_controls_page_released,
		_test_proxy,
		_test_inspector_tab,
		_test_fps,
		_debug_tab_filled,
		_press_pin_left,
		_release_pin_left,
		_debug_pinned,
		_test_make_room,
		_test_objects_window,
		_objects_ray_on_window,
		_objects_box_taken,
		_objects_closed,
		_test_small_node_by_window,
		_small_node_pointed,
		_small_node_grabbed,
		_small_node_joined,
		_small_node_touched,
		_small_node_near,
		_test_node_before_miniature,
		_node_before_miniature_grabbed,
		_node_by_miniature_let_go,
		_node_by_miniature_hovered,
		_node_by_miniature_touched,
		_node_by_miniature_done,
		_test_drag_scroll,
		_drag_list,
		_list_glided,
		_launcher_for_playtest,
		_aim_at_playtest,
		_click_playtest,
		_playtest_requested,
		_test_window_history,
		_launcher_in_history,
		_open_from_launcher,
		_undo_open_window,
		_close_by_x,
		_closed_by_x,
		_pin_files,
		_undo_pin,
		_take_files,
		_carry_files,
		_files_carried,
		_files_moved,
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
	_panels.set_manipulator(_manipulator)
	_palette.set_manipulator(_manipulator)
	root.add_child(_rig)
	_launcher = _panels.get_launcher()
	_pose(_left, _left_aim, 0.0, 0.0)
	_pose(_right, Transform3D(Basis.IDENTITY, Vector3(0.2, -0.3, -0.3)), 0.0, 0.0)
	_left.set_input(&"menu_button", true)


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
	_aim_with(_right, surface, pixel, trigger, grip)


## The same with the left hand.
func _aim_left(surface: XREPanelSurface, pixel: Vector2, trigger: float) -> void:
	_aim_with(_left, surface, pixel, trigger, 0.0)


func _aim_with(tracker: XRControllerTracker, surface: XREPanelSurface, pixel: Vector2, trigger: float, grip: float) -> void:
	var target := surface.pixel_to_global(pixel)
	var origin := target + surface.global_basis.z.normalized() * AIM_DISTANCE
	_pose(tracker, Transform3D(Basis.looking_at(target - origin), origin), trigger, grip)


## Center of [param control] in its panel's pixels.
func _center(control: Control) -> Vector2:
	return control.get_global_rect().get_center()


## Center of [param item] of [param tree] in its panel's pixels.
func _item_center(tree: Tree, item: TreeItem) -> Vector2:
	var rect := tree.get_item_area_rect(item)
	return tree.get_global_transform() * (rect.position + rect.size * 0.5)


func _scene_window() -> XREPanelWindow:
	return _panels.find_window(XRESceneTab)


func _scene_tab() -> XRESceneTab:
	return _scene_window().tab as XRESceneTab


## Center of the launcher's tile of the tab of class [param type], in its pixels.
func _tile_center(type: GDScript) -> Vector2:
	return _center(_launcher.get_tile(type))


## Center of [param window]'s pin button, in the bar's pixels.
func _pin_center(window: XREPanelWindow) -> Vector2:
	return _center(window.get_pin_button())


func _texts(tree: Tree) -> Array[String]:
	var texts: Array[String] = []
	var item := tree.get_root()
	while item != null:
		texts.append(item.get_text(0))
		item = item.get_next_in_tree()
	return texts


# The launcher, the scene window, pinning it to a hand (D-041).

func _show_launcher() -> void:
	_check(_launcher.is_shown() and _panels.is_launcher_shown() and not _palette.is_shown(), "X shows the launcher, and no tray (D-045)")
	_check(_launcher.get_tile(XREObjectsTab) != null and _launcher.get_tile(XREObjectsTab).get_index() == 0, "the objects come first in the launcher")
	# The head tracker is absent: the head is at the rig's origin, looking down -Z.
	_check_vector(_launcher.global_position, Vector3(0.0, -XREPanels.LAUNCHER_DROP, -XREPanels.LAUNCHER_DISTANCE),
			"the launcher opens in front of the user, below the gaze")
	_check(_launcher.global_basis.z.is_equal_approx(Vector3.BACK) and _launcher.global_basis.y.is_equal_approx(Vector3.UP),
			"facing the head, upright")
	for type: GDScript in XREPanels.tab_types():
		var tile := _launcher.get_tile(type)
		var tab := type.new(_document) as XREPanelTab
		_check(tile != null and _launcher.get_tile_icon(type).texture != null and _launcher.get_tile_title(type) == tab.get_title(),
				"the launcher has an icon titled %s" % tab.get_title())
		tab.free()
	var playtest := _launcher.get_playtest_tile()
	_check(playtest != null and (playtest.find_child("Icon", true, false) as TextureRect).texture != null
			and (playtest.find_child("Title", true, false) as Label).text == XRETabLauncher.PLAYTEST_TITLE,
			"the launcher has a Playtest icon (D-082)")
	_check(playtest != null and playtest.get_parent() == _launcher.get_tile(XREDebugTab).get_parent()
			and playtest.get_index() == playtest.get_parent().get_child_count() - 1, "Playtest comes after the tabs")
	var debug := _launcher.get_tile(XREDebugTab)
	var scene := _launcher.get_tile(XRESceneTab)
	_check(debug.get_global_rect().position.y > scene.get_global_rect().end.y
			and absf(debug.get_parent_control().get_global_rect().get_center().x - _launcher.size_px.x * 0.5) < 1.0
			and debug.get_parent().get_child_count() < XRETabLauncher.LONG_ROW,
			"the second row is shorter and centered, offset from the first, as in Navigator")
	_check((_panels.get("_dimmer") as MeshInstance3D).visible, "the scene is dimmed behind the launcher")
	# D-043: concave whatever the windows are, fading in; no tooltip repeats a title (D-044).
	_check(is_equal_approx(_launcher.curve_radius, XREPanels.LAUNCHER_DISTANCE), "the launcher is concave, bent around the head")
	_check(_launcher.to_local(_launcher.pixel_to_global(Vector2.ZERO)).z > 0.03, "its edges come towards the user")
	_check(_launcher.get_tile(XRESceneTab).tooltip_text.is_empty(), "a tile has no tooltip: its title is under it")
	var fade := float(_panels.get("_fade"))
	_check(fade > 0.0, "the launcher fades in: %s" % fade)
	var dim := float(((_panels.get("_dimmer") as MeshInstance3D).material_override as ShaderMaterial).get_shader_parameter(&"alpha"))
	_check(dim > 0.0 and dim <= XREPanels.LAUNCHER_DIM, "and the dimming with it: %s" % dim)
	_check(_panels.get_windows().is_empty(), "no window is open before a tile is chosen")
	_left.set_input(&"menu_button", false)
	_aim(_launcher, _tile_center(XRESceneTab), 1.0)


func _click_scene_tile() -> void:
	_aim(_launcher, _tile_center(XRESceneTab), 0.0)


func _scene_window_opened() -> void:
	var window := _scene_window()
	_check(_panels.get_windows().size() == 1 and window != null, "a click on a tile opens that tab's window")
	if window == null:
		return
	_check(window.is_pulsing(), "a window opened pulses once (D-045)")
	window.stop_pulse()
	_check(window.scale.is_equal_approx(Vector3.ONE) and not window.is_pulsing(), "and is back to its size after")
	_check_vector(window.global_position, Vector3(0.0, -XREPanels.WINDOW_DROP, -XREPanels.WINDOW_DISTANCE),
			"the window opens in front of the user")
	_check(window.global_basis.z.is_equal_approx(Vector3.BACK) and window.global_basis.y.is_equal_approx(Vector3.UP),
			"window faces the head horizontally without tilting")
	_check(not window.is_pinned() and window.has_corner_handles() and window.size_px == XREPanels.WINDOW_SIZE,
			"a window has full size and corner handles")
	var texts := _texts(_scene_tab().get_tree_control())
	_check(texts == ["Scene", "Box", "Lamp", "Trigger", "Prop", "Room"],
			"the scene tab shows the scene's own nodes: %s" % [texts])
	var bar := window.get_bar()
	var bottom := window.pixel_to_global(Vector2(window.size_px.x * 0.5, window.size_px.y))
	_check_vector(bar.global_position, bottom - window.global_basis.y * (bar.size_m.y * 0.5 + XREPanelWindow.BAR_GAP),
			"the bar lies just under the window")
	_check(bar.size_m.x * 0.5 < window.size_m.x * 0.5 - XREPanelSurface.HANDLE_ALONG,
			"between the bottom corner handles")
	_check(window.get_pin_button().visible and not window.get_unpin_button().visible, "a window's bar offers one pin")
	_check(not bar.is_shown(), "the control bar hides until a ray is on the window")
	_aim(window, window.size_px * 0.5, 0.0)


func _show_bar() -> void:
	var window := _scene_window()
	_check(window.get_bar().is_shown(), "a ray on the window shows its control bar")
	# The left hand clicks the pin: the window goes to the left forearm, and the right hand works in it.
	_aim_left(window.get_bar(), _pin_center(window), 1.0)


func _click_pin_left() -> void:
	_check(not _panels.is_launcher_shown(), "choosing a tab hides the launcher")
	_check(_launcher.is_shown(), "it fades out, still drawn (D-045)")
	_panels.call("_update_fade", 1.0)
	_check(not _launcher.is_shown() and not (_panels.get("_dimmer") as MeshInstance3D).visible, "and once faded out, it hides with its dimming")
	_aim_left(_scene_window().get_bar(), _pin_center(_scene_window()), 0.0)


func _scene_pinned() -> void:
	var window := _scene_window()
	_check(window.pin == XREPanelWindow.Pin.LEFT_HAND and _panels.get_pinned_window(_rig.left_hand) == window,
			"the pin clicked with the left hand pins the window to the left forearm")
	_check(window.size_px == XREPanels.COMPACT_SIZE
			and window.size_m.is_equal_approx(XREPanels.COMPACT_SIZE * XREPanels.COMPACT_PIXEL_SIZE),
			"compact, as the forearm panel was: %s" % [window.size_m])
	_check(not window.has_corner_handles(), "without corner handles")
	_check(window.get_unpin_button().visible and not window.get_pin_button().visible, "its bar offers to make it a window again")
	_check(_panels.get_held_window(_rig.left_hand) == null, "the click doesn't take the window")
	_pose(_left, _left_aim, 0.0, 0.0)


func _scene_on_forearm() -> void:
	var window := _scene_window()
	_check(window.global_transform.is_equal_approx(_left_aim * XREPanels.HAND_OFFSET), "on the forearm, tilted")
	_aim(window, _item_center(_scene_tab().get_tree_control(), _scene_tab().get_item(_box)), 0.0)


func _point_at_box() -> void:
	_check(not _rig.right_hand.is_free_for(_manipulator), "a hand on a panel is claimed")
	_check(not _rig.right_hand.is_stick_free_for(_locomotion), "and its thumbstick too")
	_operation_count = _operations.size()
	_aim(_scene_window(), _item_center(_scene_tab().get_tree_control(), _scene_tab().get_item(_box)), 1.0)


func _click_box() -> void:
	_aim(_scene_window(), _item_center(_scene_tab().get_tree_control(), _scene_tab().get_item(_box)), 0.0)


func _box_selected() -> void:
	_check(_operations.slice(_operation_count) == ["select PANEL [\"Box\"]"],
			"a click in the scene tab on the left forearm selects the node, from a panel, and nothing behind the panel: %s"
			% [_operations.slice(_operation_count)])
	_document.select([_trigger], XREDocument.Source.TOOL)


func _selection_shows() -> void:
	var tree := _scene_tab().get_tree_control()
	var selected := tree.get_next_selected(null)
	_check(selected == _scene_tab().get_item(_trigger) and tree.get_next_selected(selected) == null,
			"a selection made elsewhere shows in the scene tab")
	_left.set_input(&"menu_button", true)


# Signals tab and windows.

func _launcher_again() -> void:
	_check(_launcher.is_shown(), "Menu shows the launcher again")
	_check(_scene_window().is_shown() and _scene_window().is_pinned(), "the pinned window stays on the forearm")
	_left.set_input(&"menu_button", false)
	_aim(_launcher, _tile_center(XRESignalsTab), 1.0)


func _click_signals_tile() -> void:
	_aim(_launcher, _tile_center(XRESignalsTab), 0.0)


func _signals_listed() -> void:
	var window := _panels.find_window(XRESignalsTab)
	_check(_panels.get_windows().size() == 2 and window != null, "the signals tile opens its window")
	if window == null:
		return
	# Where the user looks; a window there makes room (D-044).
	_check_vector(window.global_position, Vector3(0.0, -XREPanels.WINDOW_DROP, -XREPanels.WINDOW_DISTANCE),
			"in front of the user")
	_check(not _panels.overlaps_window(window), "and covers no other window")
	window.stop_pulse()
	var tab := window.tab as XRESignalsTab
	var texts := _texts(tab.get_tree_control())
	var entered := texts.find("body_entered(body: Node3D)")
	var exited := texts.find("body_exited(body: Node3D)")
	_check(texts.has("Area3D") and texts.has("Node") and texts.find("Area3D") < texts.find("Node"),
			"signals are listed by class, the node's own first: %s" % [texts])
	_check(entered >= 0 and texts[entered + 1] == "→ Lamp :: set_visible()",
			"a connection saved with the scene shows under its signal: %s" % [texts])
	_check(exited >= 0 and not texts[exited + 1].begins_with("→"), "a connection made at run time doesn't show")


# Corner handles (D-040): trigger or grip on one moves the window.

## Where the right ray points at the Signals window's bottom right handle, from in front of it.
func _corner_point(window: XREPanelWindow) -> Vector3:
	var outward := (window.global_basis.x - window.global_basis.y).normalized() * 0.02
	return window.pixel_to_global(window.size_px) + outward


func _aim_at_point(target: Vector3, normal: Vector3, trigger: float, grip: float = 0.0) -> void:
	var origin := target + normal.normalized() * AIM_DISTANCE
	_pose(_right, Transform3D(Basis.looking_at(target - origin), origin), trigger, grip)


func _aim_at_corner() -> void:
	var window := _panels.find_window(XRESignalsTab)
	if window == null:
		return
	_check(window.has_corner_handles(), "a window has corner handles")
	# The left ray rests on the window from where it is; it points up, away from every panel, meanwhile.
	_pose(_left, Transform3D(Basis(Vector3.RIGHT, PI / 2.0), _left_aim.origin), 0.0, 0.0)
	_aim_at_point(_corner_point(window), window.global_basis.z, 0.0)


func _corner_lit() -> void:
	var window := _panels.find_window(XRESignalsTab)
	if window == null:
		return
	_check(window.handle_lit(XREPanelSurface.Corner.BOTTOM_RIGHT), "the ray on a corner lights its handle")
	_check(window.handle_shown(XREPanelSurface.Corner.TOP_LEFT) and not window.handle_lit(XREPanelSurface.Corner.TOP_LEFT),
			"the other handles show, unlit")
	_check(not _rig.right_hand.is_free_for(_manipulator), "a hand on a handle is the panels'")
	_window_before = window.global_position
	_operation_count = _operations.size()
	_aim_at_point(_corner_point(window), window.global_basis.z, 1.0)


func _corner_taken() -> void:
	var window := _panels.find_window(XRESignalsTab)
	if window == null:
		return
	_check(_panels.get_held_window(_rig.right_hand) == window, "the trigger on a corner handle takes the window")
	_check(not window.is_pressed(), "and doesn't click the interface")
	_check(_operations.size() == _operation_count, "nor selects what is behind it: %s" % [_operations.slice(_operation_count)])
	_pose(_right, _rig.right_hand.global_transform.translated(Vector3(0.1, 0.05, 0.0)), 1.0, 0.0)


func _corner_carried() -> void:
	var window := _panels.find_window(XRESignalsTab)
	if window == null:
		return
	_check_vector(window.global_position, _window_before + Vector3(0.1, 0.05, 0.0), "the window follows the hand while the trigger is held")
	_check(window.handle_lit(XREPanelSurface.Corner.BOTTOM_RIGHT), "the handle it was taken by stays lit")
	_check(window.global_basis.y.is_equal_approx(Vector3.UP), "the carried window stays upright")
	_pose(_right, _rig.right_hand.global_transform.translated(Vector3(-0.1, -0.05, 0.0)), 1.0, 0.0)


func _corner_brought_back() -> void:
	var window := _panels.find_window(XRESignalsTab)
	if window == null:
		return
	_check_vector(window.global_position, _window_before, "and comes back with it")
	_pose(_right, _rig.right_hand.global_transform, 0.0, 0.0)


func _corner_let_go() -> void:
	var window := _panels.find_window(XRESignalsTab)
	if window == null:
		return
	_check(_panels.get_held_window(_rig.right_hand) == null, "letting go of the trigger leaves the window")
	_check_vector(window.global_position, _window_before, "where it is")
	_aim(window, window.size_px * 0.5, 0.0)


func _handles_on_window() -> void:
	var window := _panels.find_window(XRESignalsTab)
	if window == null:
		return
	_check(window.handle_shown(XREPanelSurface.Corner.BOTTOM_RIGHT) and not window.handle_lit(XREPanelSurface.Corner.BOTTOM_RIGHT),
			"a ray on the interface shows the handles, none lit")
	# Up, away from every panel.
	_pose(_right, Transform3D(Basis(Vector3.RIGHT, PI / 2.0), Vector3(0.2, -0.3, -0.3)), 0.0, 0.0)


func _handles_hidden() -> void:
	var window := _panels.find_window(XRESignalsTab)
	if window == null:
		return
	_check(not window.handle_shown(XREPanelSurface.Corner.BOTTOM_RIGHT), "the handles hide when the ray leaves")
	_pose(_left, _left_aim, 0.0, 0.0)
	# Back on the window, for the thumbstick checks after.
	_aim(window, window.size_px * 0.5, 0.0)


func _test_corner_zones() -> void:
	var size := Vector2(0.4, 0.3)
	var zones := {
		Vector2(0.0, 0.0): -1,
		Vector2(0.19, 0.14): -1,
		Vector2(0.21, 0.16): XREPanelSurface.Corner.TOP_RIGHT,
		Vector2(-0.21, 0.13): XREPanelSurface.Corner.TOP_LEFT,
		Vector2(0.18, -0.16): XREPanelSurface.Corner.BOTTOM_RIGHT,
		Vector2(-0.22, -0.17): XREPanelSurface.Corner.BOTTOM_LEFT,
		# Beyond an edge, but away from the corners or too far out.
		Vector2(0.0, 0.16): -1,
		Vector2(0.21, 0.0): -1,
		Vector2(0.3, 0.2): -1,
	}
	for point: Vector2 in zones:
		_check(XREPanelSurface.corner_at(point, size) == zones[point],
				"corner handle at %s: %d, expected %d" % [point, XREPanelSurface.corner_at(point, size), zones[point]])


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
	# Grip on the window pinned to the left forearm.
	_window_before = _scene_window().pixel_to_global(_scene_window().size_px * 0.5)
	_aim(_scene_window(), _scene_window().size_px * 0.5, 0.0, 1.0)


func _tear_off_scene() -> void:
	var window := _scene_window()
	_check(_panels.get_held_window(_rig.right_hand) == window,
			"grip on a window pinned to the other hand pulls it off, in hand")
	_check(not window.is_pinned() and _panels.get_pinned_window(_rig.left_hand) == null
			and window.size_px == XREPanels.WINDOW_SIZE and window.has_corner_handles(), "as a full window again")
	_check_vector(window.global_position, _window_before, "centered where the ray hit it")
	_window_before = window.global_position
	var hand := _rig.right_hand.global_transform
	_pose(_right, hand.translated(Vector3(0.2, 0.0, 0.0)), 0.0, 1.0)


func _carry_scene() -> void:
	pass


func _scene_carried() -> void:
	var window := _scene_window()
	_check_vector(window.global_position, _window_before + Vector3(0.2, 0.0, 0.0), "the window follows the hand")
	var to_head := _rig.camera.global_position - window.global_position
	to_head.y = 0
	to_head = to_head.normalized()
	_check(window.global_basis.z.dot(to_head) > 0.999, "and turns to face the head")
	_check(window.global_basis.y.is_equal_approx(Vector3.UP), "carried window stays vertical")
	_window_before = window.global_position
	_pose(_right, _rig.right_hand.global_transform, 0.0, 0.0)


func _scene_placed() -> void:
	var window := _scene_window()
	_check(_panels.get_held_window(_rig.right_hand) == null
			and window.global_position.is_equal_approx(_window_before), "letting go leaves the window where it is")
	_aim(window, window.size_px * 0.5, 0.0, 1.0)


func _push_scene() -> void:
	_hold_distance = _rig.right_hand.global_position.distance_to(_scene_window().global_position)
	_right.set_input(&"primary", Vector2(0.0, 1.0))


func _scene_pushed() -> void:
	var window := _scene_window()
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


func _scene_changed() -> void:
	_check(_panels.get_windows().size() == 2, "windows stay when the scene changes")
	var texts := _texts(_scene_tab().get_tree_control())
	_check(texts == ["Other"], "the scene tab shows the scene now edited: %s" % [texts])
	# In front of the user, where the signals window was: that one moves aside (D-044).
	var files := _panels.open_window(XREFileSystemTab)
	_check(not _panels.overlaps_window(files) and files.global_position.distance_to(_panels.find_window(XRESignalsTab).global_position) > 0.3,
			"a window opened in front of another moves it aside")


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
	_check(_panels.get_windows().size() == 3, "windows stay when a scene is opened from them")
	var window := _panels.find_window(XRESignalsTab)
	_aim(window, window.size_px * 0.5, 0.0)


func _press_close() -> void:
	var window := _panels.find_window(XRESignalsTab)
	_aim(window.get_bar(), _center(window.get_close_button()), 1.0)


func _close_signals_window() -> void:
	var window := _panels.find_window(XRESignalsTab)
	_aim(window.get_bar(), _center(window.get_close_button()), 0.0)


func _signals_window_closed() -> void:
	_check(_panels.find_window(XRESignalsTab) == null and _panels.get_windows().size() == 2,
			"× on the control bar closes the window")
	_operation_count = _operations.size()
	# Away from every panel, at the room's wall, on the left: windows opened beside others are on the right.
	_pose(_right, Transform3D(Basis.IDENTITY, _rig.global_position + Vector3(-0.3, 0.0, 0.0)).rotated_local(
			Vector3.UP, PI / 2.0), 1.0, 0.0)


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


# Feature settings (D-039).

func _test_feature_store() -> void:
	var path := "user://test_feature_settings.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var store := XREFeatureSettings.new(path)
	var key := XREFeatureSettings.NODE_FACING
	_check(store.get_value(key) == XREFeatureSettings.ON, "the first value of a setting is its default")
	_check(not store.set_value(key, &"sphere") and not store.set_value(&"no_such_setting", XREFeatureSettings.OFF),
			"unknown values and settings are refused")
	_check(not store.set_value(key, XREFeatureSettings.ON), "setting the current value changes nothing")
	var keys: Array[StringName] = []
	store.changed.connect(func(changed: StringName) -> void: keys.append(changed))
	_check(store.set_value(key, XREFeatureSettings.OFF) and keys == [key], "a new value is set and announced")
	_check(XREFeatureSettings.new(path).get_value(key) == XREFeatureSettings.OFF, "the value persists in the file")
	var config := ConfigFile.new()
	config.set_value("features", String(key), "sphere")
	config.save(path)
	_check(XREFeatureSettings.new(path).get_value(key) == XREFeatureSettings.ON, "a saved value no longer known falls back to the default")
	# Node display's Cuboid, saved before Node facing and Node volume took its place (D-115), is both of theirs.
	config = ConfigFile.new()
	config.set_value("features", "node_display", "cuboid")
	config.save(path)
	var migrated := XREFeatureSettings.new(path)
	_check(migrated.get_value(XREFeatureSettings.NODE_FACING) == XREFeatureSettings.OFF and migrated.get_value(XREFeatureSettings.NODE_VOLUME) == XREFeatureSettings.SOLID,
			"a saved Cuboid becomes Node facing Off and Node volume 3D")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_check(XREFeatureSettings.get_keys(XREFeatureSettings.Category.CONTROLS).is_empty(), "the controls page has no variant settings")
	_test_controls_store(path)


## The controls layouts and bindings (D-050).
func _test_controls_store(path: String) -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var store := XREFeatureSettings.new(path)
	var delete := XREFeatureSettings.DELETE
	_check(store.get_layout() == XREFeatureSettings.HORIZON_LINK, "the layout starts as the runtime's, Link here")
	_check(XREFeatureSettings.layout_for_runtime("SteamVR/OpenXR", false) == XREFeatureSettings.STEAMVR
			and XREFeatureSettings.layout_for_runtime("Oculus", false) == XREFeatureSettings.HORIZON_LINK
			and XREFeatureSettings.layout_for_runtime("Oculus", true) == XREFeatureSettings.HORIZON_OS,
			"the runtime picks the layout")
	store.runtime_layout = XREFeatureSettings.STEAMVR
	_check(store.get_layout() == XREFeatureSettings.STEAMVR, "the runtime's layout is in use until one is picked")
	_check(store.get_binding(delete) == &"left_x" and store.get_binding(XREFeatureSettings.PLAY) == &"left_y"
			and store.get_binding(XREFeatureSettings.LAUNCHER) == &"right_stick" and store.get_binding(XREFeatureSettings.SPEED) == &"left_stick",
			"SteamVR's dashboard has the left Menu, and X deletes: the launcher is on the right stick (D-087)")
	_check(store.get_binding(XREFeatureSettings.UNDO) == &"right_a" and store.get_binding(XREFeatureSettings.REDO) == &"right_b"
			and XREFeatureSettings.preset_binding(XREFeatureSettings.HORIZON_LINK, XREFeatureSettings.UNDO) == &"right_a"
			and XREFeatureSettings.preset_binding(XREFeatureSettings.HORIZON_OS, XREFeatureSettings.REDO) == &"right_b"
			and XREFeatureSettings.preset_binding(XREFeatureSettings.NON_VR, XREFeatureSettings.DELETE) == &"left_x",
			"every preset undoes by A, redoes by B and deletes by X")
	_check(XREFeatureSettings.preset_binding(XREFeatureSettings.HORIZON_LINK, XREFeatureSettings.LAUNCHER) == &"left_menu"
			and XREFeatureSettings.preset_binding(XREFeatureSettings.HORIZON_OS, XREFeatureSettings.LAUNCHER) == &"left_menu",
			"Meta's runtimes open the launcher with the left Menu")
	var events: Array[StringName] = []
	store.changed.connect(func(key: StringName) -> void: events.append(key))
	_check(not store.set_binding(delete, &"left_x") and not store.set_binding(delete, &"no_such_button")
			and not store.set_binding(&"no_such_action", &"right_b") and not store.set_layout(&"no_such_layout"),
			"unknown names and the binding in use are refused")
	_check(store.set_binding(delete, &"right_b") and events == [XREFeatureSettings.CONTROLS], "a new binding is set and announced")
	_check(store.get_layout() == XREFeatureSettings.CUSTOM, "rebinding in a preset switches to the custom layout")
	_check(store.get_binding(delete) == &"right_b" and store.get_binding(XREFeatureSettings.PLAY) == &"left_y"
			and store.get_binding(XREFeatureSettings.LAUNCHER) == &"right_stick" and store.get_binding(XREFeatureSettings.SPEED) == &"left_stick"
			and store.get_binding(XREFeatureSettings.UNDO) == &"right_a" and store.get_binding(XREFeatureSettings.REDO) == &"left_x",
			"the other bindings carry over to the custom layout, redo to the button delete gave up")
	_check(store.set_binding(XREFeatureSettings.PLAY, &"right_b") and store.get_binding(XREFeatureSettings.PLAY) == &"right_b"
			and store.get_binding(delete) == &"left_y", "a button another action had goes to the one given up")
	_check(store.set_layout(XREFeatureSettings.HORIZON_OS) and store.get_binding(delete) == &"left_x"
			and store.get_binding(XREFeatureSettings.PLAY) == &"left_y" and store.get_binding(XREFeatureSettings.LAUNCHER) == &"left_menu",
			"a preset has its own bindings")
	_check(store.set_layout(XREFeatureSettings.CUSTOM) and store.get_binding(delete) == &"left_y"
			and store.get_binding(XREFeatureSettings.PLAY) == &"right_b", "the custom bindings are kept")
	var reloaded := XREFeatureSettings.new(path)
	reloaded.runtime_layout = XREFeatureSettings.HORIZON_OS
	_check(reloaded.get_layout() == XREFeatureSettings.CUSTOM and reloaded.get_binding(delete) == &"left_y",
			"the custom layout persists and is used on every runtime")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var fresh := XREFeatureSettings.new(path)
	fresh.runtime_layout = XREFeatureSettings.HORIZON_OS
	_check(fresh.get_layout() == XREFeatureSettings.HORIZON_OS and fresh.set_layout(XREFeatureSettings.CUSTOM)
			and fresh.get_binding(delete) == &"left_x", "custom starts as a copy of the layout in use")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_check(XREFeatureSettings.button_hand(&"right_b") == &"right_hand" and XREFeatureSettings.button_input(&"left_stick") == &"primary_click"
			and XREFeatureSettings.button_label(&"left_y") == "Left Y", "a button knows its hand, input and name")


func _settings_window() -> XREPanelWindow:
	return _panels.find_window(XRESettingsTab)


func _settings_tab() -> XRESettingsTab:
	return _settings_window().tab as XRESettingsTab


## The settings window, pinned to the right forearm; the left hand clicks it.
func _open_settings() -> void:
	# The other windows would take the rays.
	for window: XREPanelWindow in _panels.get_windows():
		window.global_position += Vector3(0.0, 10.0, 0.0)
	var window := _panels.open_window(XRESettingsTab)
	_panels.pin_window(window, XREPanelWindow.Pin.RIGHT_HAND)
	_check(_panels.get_pinned_window(_rig.right_hand) == window and window.size_px == XREPanels.COMPACT_SIZE,
			"a window pins, compact, to the right forearm too")
	_check(window.global_transform.is_equal_approx(_rig.right_hand.global_transform * XREPanels.HAND_OFFSET),
			"where the FPS chart lies")
	_check(_settings_tab().get_title() == XREPanelTab.editor_text("Settings"), "the settings tab has the editor's title")


func _hover_cuboid() -> void:
	_aim_left(_settings_window(), _center(_settings_tab().get_button(XREFeatureSettings.NODE_FACING, XREFeatureSettings.OFF)), 0.0)


func _press_cuboid() -> void:
	var billboard := _settings_tab().get_button(XREFeatureSettings.NODE_FACING, XREFeatureSettings.ON)
	_check(billboard != null and billboard.button_pressed, "the features page shows the node display at its current value")
	_check(not _rig.left_hand.is_free_for(_manipulator), "the left hand points at the window on the right forearm")
	_operation_count = _operations.size()
	_aim_left(_settings_window(), _center(_settings_tab().get_button(XREFeatureSettings.NODE_FACING, XREFeatureSettings.OFF)), 1.0)


func _release_cuboid() -> void:
	_aim_left(_settings_window(), _center(_settings_tab().get_button(XREFeatureSettings.NODE_FACING, XREFeatureSettings.OFF)), 0.0)


func _cuboid_set() -> void:
	_check(_document.features.get_value(XREFeatureSettings.NODE_FACING) == XREFeatureSettings.OFF,
			"a click on Cuboid switches the node display")
	_check(_operations.slice(_operation_count) == ["set_feature PANEL []"],
			"the switch is one operation from a panel: %s" % [_operations.slice(_operation_count)])
	var billboard := _settings_tab().get_button(XREFeatureSettings.NODE_FACING, XREFeatureSettings.ON)
	_check(not billboard.button_pressed and _settings_tab().get_button(XREFeatureSettings.NODE_FACING, XREFeatureSettings.OFF).button_pressed,
			"only the current value's button is down")
	_document.set_feature(XREFeatureSettings.NODE_FACING, XREFeatureSettings.ON, XREDocument.Source.TOOL)
	# D-043: concave windows; one on a forearm stays flat, and the launcher stays concave when they are flat again.
	_check(_settings_tab().get_button(XREFeatureSettings.WINDOW_SHAPE, XREFeatureSettings.CONCAVE) != null
			and _settings_tab().get_button(XREFeatureSettings.PORT_DISPLAY, XREFeatureSettings.SPHERE) != null,
			"the features page has the window shape and the port display")
	_document.set_feature(XREFeatureSettings.WINDOW_SHAPE, XREFeatureSettings.CONCAVE, XREDocument.Source.TOOL)
	var bent := 0
	for window: XREPanelWindow in _panels.get_windows():
		if window.is_pinned(): _check(window.curve_radius == 0.0, "a window on a forearm stays flat")
		elif window.curve_radius > 0.0 and window.get_bar().curve_radius == window.curve_radius: bent += 1
	_check(bent > 0 and bent == _panels.get_windows().size() - 1, "concave windows bend, with their control bars: %d" % bent)
	_document.set_feature(XREFeatureSettings.WINDOW_SHAPE, XREFeatureSettings.FLAT, XREDocument.Source.TOOL)
	for window: XREPanelWindow in _panels.get_windows():
		_check(window.curve_radius == 0.0, "flat windows again")
	_check(_launcher.curve_radius > 0.0, "the launcher stays concave")
	_settings_tab().select_page(XREFeatureSettings.Category.CONTROLS)
	_pose(_left, _left_aim, 0.0, 0.0)


func _controls_page() -> void:
	var tab := _settings_tab()
	_check(tab.get_button(XREFeatureSettings.NODE_FACING, XREFeatureSettings.ON) == null,
			"the controls page doesn't show feature settings")
	var features := _document.features
	_check(tab.get_layout_button(XREFeatureSettings.HORIZON_LINK) != null and tab.get_layout_button(XREFeatureSettings.CUSTOM) != null,
			"the controls page has the layouts")
	_check(tab.get_layout_button(features.get_layout()).button_pressed, "the layout in use is down")
	var delete := XREFeatureSettings.DELETE
	var row := tab.get_binding_button(delete).get_parent()
	_check(row.get_child(0) is Label and (row.get_child(0) as Label).text == XREFeatureSettings.ACTION_TITLES[delete]
			and row.get_child(1) == tab.get_binding_button(delete), "an action's name is on the left, its binding on the right")
	_check(tab.get_binding_glyph(delete) == &"left_x" and tab.get_binding_text(delete) == "Left X",
			"the binding shows the button's icon and name")
	_operation_count = _operations.size()
	tab.get_binding_button(delete).pressed.emit()
	_check(tab.get_capturing() == delete and tab.get_binding_text(delete) == XRESettingsTab.PRESS_TEXT
			and tab.get_binding_glyph(delete) == &"", "a click on the binding waits for a button")
	_check(_operations.size() == _operation_count and features.get_binding(delete) == &"left_x", "waiting changes nothing yet")
	_right.set_input(&"by_button", true)


func _controls_page_captured() -> void:
	var tab := _settings_tab()
	var features := _document.features
	var delete := XREFeatureSettings.DELETE
	_check(features.get_layout() == XREFeatureSettings.CUSTOM and features.get_binding(delete) == &"right_b",
			"the button pressed becomes the action's, in the custom layout")
	_check(features.get_binding(XREFeatureSettings.LAUNCHER) == &"left_menu" and features.get_binding(XREFeatureSettings.PLAY) == &"left_y",
			"the other bindings carry over")
	_check(_operations.slice(_operation_count) == ["set_binding PANEL []"], "the rebinding is one operation: %s" % [_operations.slice(_operation_count)])
	_check(tab.get_capturing() == &"" and _rig.is_capturing() and not _rig.is_action_pressed(features, delete),
			"the press that was bound doesn't act while it is held")
	_right.set_input(&"by_button", false)


func _controls_page_released() -> void:
	var tab := _settings_tab()
	var features := _document.features
	var delete := XREFeatureSettings.DELETE
	_check(not _rig.is_capturing(), "the buttons act again once released")
	_check(tab.get_binding_glyph(delete) == &"right_b" and tab.get_binding_text(delete) == "Right B"
			and tab.get_layout_button(XREFeatureSettings.CUSTOM).button_pressed, "the page follows the rebinding")
	tab.get_binding_button(XREFeatureSettings.SPEED).pressed.emit()
	tab.get_binding_button(XREFeatureSettings.SPEED).pressed.emit()
	_check(tab.get_capturing() == &"" and tab.get_binding_text(XREFeatureSettings.SPEED) == "Left stick click",
			"a second click stops waiting")
	tab.get_layout_button(XREFeatureSettings.STEAMVR).pressed.emit()
	_check(features.get_binding(delete) == &"left_x" and _operations.back() == "set_layout PANEL []", "a click on a preset picks it, as one operation")
	features.set_layout(XREFeatureSettings.HORIZON_LINK)
	_settings_tab().select_page(XREFeatureSettings.Category.FEATURES)


func _test_inspector_tab() -> void:
	var window := _panels.open_window(XREInspectorTab)
	var tab := window.tab as XREInspectorTab
	_document.select([_lamp], XREDocument.Source.TOOL)
	_check(tab.get_title() == XREPanelTab.editor_text("Inspector") and tab.get_inspector() == null,
			"without the editor the inspector tab has no inspector")
	_panels.pin_window(window, XREPanelWindow.Pin.RIGHT_HAND)
	var settings := _settings_window()
	_check(_panels.get_pinned_window(_rig.right_hand) == window, "another window pins to the right forearm")
	_check(not settings.is_pinned() and settings.size_px == XREPanels.WINDOW_SIZE and settings.has_corner_handles(),
			"and the one pinned there before becomes a window again")
	_check_vector(settings.global_position, _rig.global_transform * Vector3(0.0, -XREPanels.WINDOW_DROP, -XREPanels.WINDOW_DISTANCE),
			"in front of the user")
	_check(not _panels.overlaps_window(settings), "and covers no other window (D-044)")
	_panels.pin_window(window, XREPanelWindow.Pin.WINDOW)
	_check(not window.is_pinned() and _panels.get_pinned_window(_rig.right_hand) == null, "Window on the bar unpins it")
	_panels.pin_window(window, XREPanelWindow.Pin.LEFT_HAND)
	window.stop_pulse()
	_panels.open_window(XREInspectorTab)
	_check(window.is_pinned() and window.is_pulsing(), "the launcher leaves a pinned window on the hand and pulses it (D-045)")
	_panels.pin_window(window, XREPanelWindow.Pin.WINDOW)
	window.stop_pulse()
	var place := window.global_transform
	_panels.open_window(XREInspectorTab)
	_check(window.global_transform.orthonormalized().is_equal_approx(place) and window.is_pulsing(), "an open window in view stays where it is and pulses")
	window.global_position = _rig.camera.global_position - _rig.camera.global_basis.z * -2.0
	_panels.open_window(XREInspectorTab)
	_check(_rig.camera.global_basis.z.dot(window.global_position - _rig.camera.global_position) < 0.0, "one out of view comes in front of the user")


func _test_fps() -> void:
	var history := XREFPSHistory.new()
	for frame: int in 25: history.record_interval(0.01, (frame + 1) * 0.01, true)
	_check(is_equal_approx(history.latest_fps, 100), "FPS history derives from monotonic intervals")
	history.record_interval(0.6, 0.85, true)
	_check(is_equal_approx(history.latest_worst_ms, 600), "chart preserves a long single frame interval")
	history.record_interval(0, 0.9, false)
	_check(not history.focused and is_nan(history.fps[history.index_at(history.count - 1)]), "focus loss creates a gap in the history")
	for sample: int in 600: history.record_interval(0.25, 1 + sample * 0.25, true)
	_check(history.count == XREFPSHistory.CAPACITY and history.fps.size() == XREFPSHistory.CAPACITY, "FPS history uses a bounded ring")
	_check(history.timestamps[history.index_at(0)] < history.timestamps[history.index_at(history.count - 1)], "FPS ring keeps chronological order")
	# The other windows would take the left ray.
	for other: XREPanelWindow in _panels.get_windows():
		if not other.is_pinned():
			other.global_position += Vector3(0.0, 10.0, 0.0)
	var window := _panels.open_window(XREDebugTab)
	_check(window.tab is XREDebugTab and window.tab.get_title() == "Debug", "the frame rate is a Debug tab now")


func _debug_tab_filled() -> void:
	var tab := _panels.find_window(XREDebugTab).tab as XREDebugTab
	_check(tab.get_number_label().text.contains("no live XR session"), "missing session does not fabricate a measurement")
	var session := XRESession.new()
	tab.setup(session)
	session.fps_history.record_interval(0.4, 1, true)
	_check(tab.get_chart().history == session.fps_history, "the tab charts the session's history")
	tab.setup(null)
	session.free()
	_check(_panels.get_launcher().get_tile(XREDebugTab) != null, "the launcher has a Debug icon")
	var window := _panels.find_window(XREDebugTab)
	_aim_left(window, window.size_px * 0.5, 0.0)


## The pin clicked with the left hand: the window goes to the left forearm.
func _press_pin_left() -> void:
	var window := _panels.find_window(XREDebugTab)
	_check(window.get_bar().is_shown(), "the left ray on a window shows its control bar too")
	_aim_left(window.get_bar(), _pin_center(window), 1.0)


func _release_pin_left() -> void:
	var window := _panels.find_window(XREDebugTab)
	_aim_left(window.get_bar(), _pin_center(window), 0.0)


func _debug_pinned() -> void:
	var window := _panels.find_window(XREDebugTab)
	_check(window.pin == XREPanelWindow.Pin.LEFT_HAND and _panels.get_pinned_window(_rig.left_hand) == window,
			"the pin clicked with the left hand pins the window to the left forearm")
	_pose(_left, _left_aim, 0.0, 0.0)


## D-044: a window opens in front of the user; the windows it would cover
## turn aside around the head, to the side with more room, and push on the
## ones they then cover.
func _test_make_room() -> void:
	for window: XREPanelWindow in _panels.get_windows().duplicate():
		_panels.call("_close_window", window)
	var to_head := _rig.camera.global_transform.affine_inverse()
	var front := Vector3(0.0, -XREPanels.WINDOW_DROP, -XREPanels.WINDOW_DISTANCE)
	var scene := _panels.open_window(XRESceneTab)
	var signals := _panels.open_window(XRESignalsTab)
	_check((to_head * signals.global_position).is_equal_approx(front), "the second window opens in front of the user")
	var scene_at := to_head * scene.global_position
	_check(scene_at.x > 0.3 and is_equal_approx(scene_at.y, front.y) and is_equal_approx(Vector2(scene_at.x, scene_at.z).length(), XREPanels.WINDOW_DISTANCE),
			"the first one moves aside, at its distance and height; to the right, with as much room on both sides: %s" % scene_at)
	var to_user := _rig.camera.global_position - scene.global_position
	to_user.y = 0.0
	_check(scene.global_basis.z.normalized().is_equal_approx(to_user.normalized()), "facing the head")
	var files := _panels.open_window(XREFileSystemTab)
	_check((to_head * files.global_position).is_equal_approx(front), "the third window opens in front of the user too")
	_check((to_head * signals.global_position).x < -0.3 and (to_head * scene.global_position).is_equal_approx(scene_at),
			"the window it covers goes left, where there is more room; the one on the right stays")
	var settings := _panels.open_window(XRESettingsTab)
	# Angles to the right of the gaze, around the head.
	var files_angle := atan2((to_head * files.global_position).x, -(to_head * files.global_position).z)
	var scene_angle := atan2((to_head * scene.global_position).x, -(to_head * scene.global_position).z)
	_check(files_angle > 0.3 and scene_angle > files_angle + 0.3,
			"pushed right, a window moves on the one it then covers: %s, %s" % [files_angle, scene_angle])
	for window: XREPanelWindow in [scene, signals, files, settings]:
		_check(not _panels.overlaps_window(window), "%s covers no window" % window.name)


## D-045: the launcher's Objects tile opens the palette's window; closing it hides the miniatures.
func _test_objects_window() -> void:
	var window := _panels.open_window(XREObjectsTab)
	_check(window.tab is XREObjectsTab and window.size_px == (window.tab as XREObjectsTab).get_window_size(),
			"the objects window has its own size")
	_check(_palette.get("_host") == window, "its miniatures hang in it")
	window.stop_pulse()
	# The right ray on the window, beside the miniatures: the panels have the hand.
	_aim(window, window.size_px - Vector2(30.0, 30.0), 0.0)


## D-046: the ray on the window, then on a miniature in front of it: grip takes the thing out, not the window.
func _objects_ray_on_window() -> void:
	_check(_rig.right_hand.get_claimant() == _panels, "the ray on the Objects window is the panels'")
	var box := _palette.get_item_transform(&"CSGBox3D").origin
	var window := _panels.find_window(XREObjectsTab)
	var origin := box + window.global_basis.z.normalized() * 0.3
	_pose(_right, Transform3D(Basis.looking_at(box - origin), origin), 0.0, 1.0)


func _objects_box_taken() -> void:
	_check(_palette.get_held() is CSGBox3D and _panels.get_held_window(_rig.right_hand) == null,
			"grip on a miniature in front of its window takes the thing out, not the window")
	_left.set_input(&"ax_button", true)


func _objects_closed() -> void:
	_check(_palette.get_held() == null, "X throws it away")
	_left.set_input(&"ax_button", false)
	_pose(_right, _rig.right_hand.global_transform, 0.0, 0.0)
	_panels.call("_close_window", _panels.find_window(XREObjectsTab))
	_check(_palette.get("_host") == null, "closing the window takes the miniatures away")


## D-047: a small node put down in front of a window — as one taken out of
## the Objects window is — is grabbed, touched and scaled with both hands
## although the rays go on into the window.
func _test_small_node_by_window() -> void:
	var window := _panels.open_window(XRESettingsTab)
	window.stop_pulse()
	var front := window.global_basis.z.normalized()
	_small = CSGBox3D.new()
	_small.name = "Small"
	_small.size = Vector3.ONE / 30.0
	# Headless bounds are empty: the picker sees custom ones (see test_tools.gd).
	_small.custom_aabb = AABB(-_small.size * 0.5, _small.size)
	var scene := _manipulator.get("_root") as Node
	scene.add_child(_small)
	# Part of the edited scene, as the document puts a node there: the picker selects it, not the root.
	_small.owner = scene
	_small.global_position = window.global_position + front * 0.05
	_pose(_right, Transform3D(Basis.looking_at(-front), _small.global_position + front * 0.3), 0.0, 0.0)
	_pose(_left, _left_aim, 0.0, 0.0)


func _small_node_pointed() -> void:
	_check(_rig.right_hand.get_claimant() != _panels and _manipulator.get("_hands")[1].hover == _small,
			"a small node in front of a window takes the ray from the window")
	var front := _panels.find_window(XRESettingsTab).global_basis.z.normalized()
	_pose(_right, Transform3D(Basis.looking_at(-front), _small.global_position + front * 0.3), 0.0, 1.0)


func _small_node_grabbed() -> void:
	_check(_document.get_selection() == [_small] and (_manipulator.get("_holders") as Array).size() == 1
			and _panels.get_held_window(_rig.right_hand) == null, "grip on it grabs the node, not the window")
	# The left ray on the window beside the node: its grip joins the hold.
	var window := _panels.find_window(XRESettingsTab)
	_aim_with(_left, window, window.size_px * 0.2, 0.0, 1.0)


func _small_node_joined() -> void:
	_check((_manipulator.get("_holders") as Array).size() == 2 and _panels.get_held_window(_rig.left_hand) == null,
			"the other hand's grip with its ray on the window joins the hold, to scale with both hands")
	var front := _panels.find_window(XRESettingsTab).global_basis.z.normalized()
	_pose(_left, _left_aim, 0.0, 0.0)
	# The right tip at the node, its ray going on into the window.
	_pose(_right, Transform3D(Basis.looking_at(-front), _small.global_position + front * 0.01), 0.0, 0.0)


func _small_node_touched() -> void:
	_check(_rig.right_hand.get_claimant() != _panels, "a hand touching a small node in front of a window is the manipulator's")
	var ray := _rig.right_hand.get("_ray") as MeshInstance3D
	_check(not ray.visible, "with the tip inside the node, the ray hides (D-049)")
	# The tip 2.5 cm in front of the node's face: still touching it.
	var front := _panels.find_window(XRESettingsTab).global_basis.z.normalized()
	_pose(_right, Transform3D(Basis.looking_at(-front), _small.global_position + front * (_small.size.z * 0.5 + 0.025)), 0.0, 0.0)


func _small_node_near() -> void:
	var ray := _rig.right_hand.get("_ray") as MeshInstance3D
	_check(ray.visible and bool(_rig.right_hand.get("_ray_hits")) and absf(ray.scale.z - 0.025) < 0.001,
			"touching it from 2.5 cm, the ray is lit and reaches only its face: %s" % ray.scale.z)
	_document.select([], XREDocument.Source.TOOL)
	_small.get_parent().remove_child(_small)
	_small.free()
	_panels.call("_close_window", _panels.find_window(XRESettingsTab))
	_pose(_right, Transform3D(Basis.IDENTITY, _rig.global_position + Vector3(0.0, -1.0, 0.0)), 0.0, 0.0)


## D-048: a node put down in front of a miniature of the Objects window, the
## right hand close to it and its ray going on through it into the miniature:
## grip grabs the node, not the miniature; touching it too.
func _test_node_before_miniature() -> void:
	var window := _panels.open_window(XREObjectsTab)
	window.stop_pulse()
	var front := window.global_basis.z.normalized()
	var miniature := _palette.get_item_transform(&"CSGSphere3D").origin
	_small = CSGBox3D.new()
	_small.name = "BeforeMiniature"
	_small.size = Vector3.ONE / 30.0
	_small.custom_aabb = AABB(-_small.size * 0.5, _small.size)
	var scene := _manipulator.get("_root") as Node
	scene.add_child(_small)
	_small.owner = scene
	_small.global_position = miniature + front * 0.04
	# 6 cm from the node, not touching it; the ray goes on into the sphere's miniature.
	_pose(_right, Transform3D(Basis.looking_at(-front), _small.global_position + front * 0.06), 0.0, 1.0)


func _node_before_miniature_grabbed() -> void:
	_check(_palette.get_held() == null and _document.get_selection() == [_small] and (_manipulator.get("_holders") as Array).size() == 1,
			"grip with the ray through a node into a miniature grabs the node, not the miniature")
	var front := _panels.find_window(XREObjectsTab).global_basis.z.normalized()
	_pose(_right, Transform3D(Basis.looking_at(-front), _small.global_position + front * 0.06), 0.0, 0.0)


func _node_by_miniature_let_go() -> void:
	_check((_manipulator.get("_holders") as Array).is_empty() and _palette.get_held() == null, "letting go puts the node down")
	# The tip at the node, 4 cm from the miniature: within the miniature's touch too.
	var front := _panels.find_window(XREObjectsTab).global_basis.z.normalized()
	_pose(_right, Transform3D(Basis.looking_at(-front), _small.global_position), 0.0, 0.0)


func _node_by_miniature_hovered() -> void:
	_check(_palette.get_hovered() == &"", "a hand touching a node by a miniature doesn't light the miniature")
	var front := _panels.find_window(XREObjectsTab).global_basis.z.normalized()
	_pose(_right, Transform3D(Basis.looking_at(-front), _small.global_position), 0.0, 1.0)


func _node_by_miniature_touched() -> void:
	_check(_palette.get_held() == null and (_manipulator.get("_holders") as Array).size() == 1,
			"grip touching a node by a miniature grabs the node")
	_pose(_right, Transform3D(Basis.IDENTITY, _rig.global_position + Vector3(0.0, -1.0, 0.0)), 0.0, 0.0)


func _node_by_miniature_done() -> void:
	_document.select([], XREDocument.Source.TOOL)
	_small.get_parent().remove_child(_small)
	_small.free()
	_panels.call("_close_window", _panels.find_window(XREObjectsTab))


## D-045: a list scrolls by dragging it up or down; a click on it is still a
## click. A panel with a long list, laid out by the next frame.
func _test_drag_scroll() -> void:
	_scroll_panel = XREPanelSurface.new(Vector2(300, 200), 0.001, 1.0, null)
	_scroll_list = ItemList.new()
	_scroll_list.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for index: int in 60:
		_scroll_list.add_item("Item %d" % index)
	_scroll_panel.root.add_child(_scroll_list)
	root.add_child(_scroll_panel)


func _drag_list() -> void:
	var surface := _scroll_panel
	var list := _scroll_list
	var bar := list.get_v_scroll_bar()
	_check(bar.max_value > bar.page, "the list can scroll")
	surface.pointer_move(Vector2(150, 150))
	surface.pointer_button(true)
	_check(list.get_selected_items().is_empty(), "a press on a list waits")
	surface.pointer_move(Vector2(151, 148))
	_check(not surface.is_scrolling(), "a move within the slop is still a click")
	surface.pointer_move(Vector2(152, 60))
	surface.pointer_move(Vector2(152, 30))
	_check(surface.is_scrolling() and is_equal_approx(bar.value, 120.0), "dragged up, the list follows the pointer: %s" % bar.value)
	surface.pointer_button(false)
	_check(list.get_selected_items().is_empty(), "a drag selects nothing")
	_check(surface.is_scrolling(), "let go while moving, it glides on")
	_scroll_value = bar.value


func _list_glided() -> void:
	var surface := _scroll_panel
	var list := _scroll_list
	var bar := list.get_v_scroll_bar()
	_check(bar.value > _scroll_value, "the glide scrolls further: %s" % bar.value)
	surface.pointer_move(Vector2(150, 100))
	surface.pointer_button(true)
	_check(not surface.is_scrolling(), "a press stops the glide")
	var top := bar.value
	surface.pointer_button(false)
	_check(list.get_selected_items().size() == 1 and is_equal_approx(bar.value, top), "a press let go in place clicks the item under it")
	surface.pointer_move(Vector2(40, 40))
	surface.pointer_button(true)
	surface.pointer_move(Vector2(120, 44))
	surface.pointer_button(false)
	_check(not surface.is_scrolling() and is_equal_approx(bar.value, top), "a drag sideways doesn't scroll: it is a press and a mouse drag")
	surface.queue_free()


# The launcher's Playtest tile (D-082).

func _launcher_for_playtest() -> void:
	_panels.playtest_requested.connect(func() -> void: _playtests += 1)
	_window_count = _panels.get_windows().size()
	_left.set_input(&"menu_button", true)


func _aim_at_playtest() -> void:
	_check(_launcher.is_shown(), "Menu shows the launcher for Playtest")
	_left.set_input(&"menu_button", false)
	_aim(_launcher, _center(_launcher.get_playtest_tile()), 1.0)


func _click_playtest() -> void:
	_aim(_launcher, _center(_launcher.get_playtest_tile()), 0.0)


func _playtest_requested() -> void:
	_check(_playtests == 1, "a click on Playtest asks to play once: %d" % _playtests)
	_check(not _panels.is_launcher_shown(), "and hides the launcher")
	_check(_panels.get_windows().size() == _window_count, "Playtest opens no window")


# D-087: the launcher shown and windows opened, closed by ×, pinned and moved are undone and redone.

func _files_window() -> XREPanelWindow:
	return _panels.find_window(XREFileSystemTab)


## Every window's transform and pin, as the panels keep them for undo.
func _layout() -> Dictionary:
	return _panels.call("_layout")


## Whether every window of [param before] but [param skip]'s is where it was.
func _same_layout(before: Dictionary, skip: Script = null) -> bool:
	var now := _layout()
	for type: Variant in before:
		if type == skip:
			continue
		if not now.has(type):
			return false
		var was: Dictionary = before[type]
		var is_now: Dictionary = now[type]
		if was["pin"] != is_now["pin"] or (was["pin"] == XREPanelWindow.Pin.WINDOW and not (was["transform"] as Transform3D).is_equal_approx(is_now["transform"])):
			return false
	return true


func _test_window_history() -> void:
	_pose(_right, Transform3D(Basis.IDENTITY, Vector3(0.2, -0.3, -0.3)), 0.0, 0.0)
	_pose(_left, _left_aim, 0.0, 0.0)
	if _files_window() != null:
		_panels.call("_close_window", _files_window())
	_document.history.clear()
	_left.set_input(&"menu_button", true)


func _launcher_in_history() -> void:
	_left.set_input(&"menu_button", false)
	_check(_panels.is_launcher_shown() and _document.history.get_undo_name() == "Launcher",
			"the launcher shown is a step: %s" % _document.history.get_undo_name())
	_check(_document.undo(XREDocument.Source.TOOL) and not _panels.is_launcher_shown(), "undo hides it")
	_check(_document.redo(XREDocument.Source.TOOL) and _panels.is_launcher_shown(), "redo shows it again")


func _open_from_launcher() -> void:
	_layout_before = _layout()
	_panels.call("_on_tab_chosen", XREFileSystemTab)
	var window := _files_window()
	_check(window != null and not _panels.is_launcher_shown(), "a tab chosen opens its window and hides the launcher")
	_check(_document.history.get_undo_name() == "Open %s" % window.tab.get_title(), "opening is a step: %s" % _document.history.get_undo_name())
	_files_transform = window.transform


func _undo_open_window() -> void:
	_check(_document.undo(XREDocument.Source.TOOL) and _files_window() == null, "undo closes the window opened")
	_check(_same_layout(_layout_before), "and puts back the windows that made room for it")
	_check(not _document.undo(XREDocument.Source.TOOL) and not _panels.is_launcher_shown(),
			"the launcher, hidden by the tile, isn't shown again: its step is dropped, and there is nothing left")
	_check(_document.redo(XREDocument.Source.TOOL) and _files_window() != null and _files_window().transform.is_equal_approx(_files_transform),
			"redo opens the window again where it was")


func _close_by_x() -> void:
	_files_window().close_requested.emit()


func _closed_by_x() -> void:
	_check(_files_window() == null and _document.history.get_undo_name().begins_with("Close "),
			"× closes the window as a step: %s" % _document.history.get_undo_name())
	_check(_document.undo(XREDocument.Source.TOOL) and _files_window() != null and _files_window().transform.is_equal_approx(_files_transform)
			and not _files_window().is_pinned(), "undo opens it again where it was")


func _pin_files() -> void:
	_layout_before = _layout()
	_panels.call("_pin_by_user", _files_window(), XREPanelWindow.Pin.RIGHT_HAND)
	_check(_files_window().pin == XREPanelWindow.Pin.RIGHT_HAND and _document.history.get_undo_name().begins_with("Pin "),
			"pinning is a step: %s" % _document.history.get_undo_name())


func _undo_pin() -> void:
	_check(_document.undo(XREDocument.Source.TOOL) and not _files_window().is_pinned() and _files_window().transform.is_equal_approx(_files_transform),
			"undo makes it a window again where it was")
	_check(_same_layout(_layout_before), "and the window pinned there before goes back to the forearm")


func _take_files() -> void:
	var window := _files_window()
	window.stop_pulse()
	_aim(window, window.size_px * 0.5, 0.0, 1.0)


func _carry_files() -> void:
	_check(_panels.get_held_window(_rig.right_hand) == _files_window(), "grip on the window takes it")
	_pose(_right, _rig.right_hand.global_transform.translated(Vector3(0.3, 0.1, 0.0)), 0.0, 1.0)


func _files_carried() -> void:
	_pose(_right, _rig.right_hand.global_transform, 0.0, 0.0)


func _files_moved() -> void:
	_check(not _files_window().transform.is_equal_approx(_files_transform) and _document.history.get_undo_name().begins_with("Move "),
			"a window moved is a step: %s" % _document.history.get_undo_name())
	_check(_document.undo(XREDocument.Source.TOOL) and _files_window().transform.is_equal_approx(_files_transform), "undo puts it back")
	_panels.call("_close_window", _files_window())


func _finish() -> void:
	for tracker in _trackers:
		XRServer.remove_tracker(tracker)
	print("test_panels: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)
