@tool
class_name XREBlueprints
extends Node3D
## XR lifecycle and input adapter for the independent Blueprint document (D-025).
## Assignments go through XREDocument; spatial UI is never owned by the scene.

signal changed
## Asks for the graph's window of tab class [param type] — the parameters
## ([XREBlueprintParametersTab]) or the block palette ([XREBlueprintPaletteTab])
## — at [param pose], beside a block (D-044). [XREPanels] opens it there and
## calls [method window_closed] when it closes.
signal window_requested(type: GDScript, pose: Transform3D)
## Asks for the window of tab class [param type] to close: [param always], or
## only if it isn't pinned to a hand.
signal window_dismissed(type: GDScript, always: bool)
## Asks the open window of tab class [param type] to pulse where it is (D-046).
signal window_pulse_requested(type: GDScript)

## Neck pivot relative to the eye center, in head coordinates: behind and below
## the eyes. Turning or tilting the head then leaves the measured hand motion alone.
const NECK_FROM_EYES := Vector3(0.0, -0.075, 0.0805)
## For the HOMER gain the body is a vertical segment from shoulders to hips,
## below the neck pivot: a hand low at the lap is still near the body.
const BODY_TOP := 0.175
const BODY_BOTTOM := 0.65
## Farther than this from the head, in meters, the badge over a selected
## object grows with the distance and so keeps its size in view (D-043).
const BADGE_DISTANCE := 1.2
## Gap between a block and its parameters or palette window beside it, in
## meters, and how much nearer the head than the block, and than any card it
## covers, the window is: so that no card covers it or takes its ray.
const PARAMETERS_GAP := 0.04
const PARAMETERS_LIFT := 0.05

class Pointer:
	var hand: XREHand
	var surface: XREPanelSurface
	var drives := false
	var held: Node3D
	var hold := Transform3D.IDENTITY
	var block := -1
	var before := Transform3D.IDENTITY
	var touched := false
	var grab_point := Vector3.ZERO
	var distance := 0.0
	var body_offset := Vector3.ZERO
	var along := Vector3.FORWARD
	var depth_uses_grip := false
	var gain := 1.0
	## A held window: the one whose handles light up, the corner it was taken
	## by (-1 for its interface) and whether the trigger holds it, not the grip.
	var window: XREPanelSurface
	var corner := -1
	var by_trigger := false

class Marker:
	var host: Node
	var anchor: Node3D
	var visual: Node3D
	var path: String

class TargetWire:
	var id: int
	var port: int
	var target: Node
	var anchor: Node3D
	var mesh: XREGraphWire

var blueprint: XREBlueprintDocument
var canvas: XREBlueprintCanvas
var parameters: XREBlueprintEditor
var status := "Select an object, then Create Blueprint or Open Blueprint."
var logic_mode := false
## Optional project folder for graph creation; empty uses the host scene's folder.
var source_folder := ""
var _document: XREDocument
var _rig: XRERig
var _icons: XREIcons
var _root: Node
var _workspace: Node3D
var _floating_ui: Node3D
var _dimmer: MeshInstance3D
var _toolbar: XREPanelSurface
## The block palette's form: a button per block a card's plus adds ([XREBlueprintPaletteTab]).
var block_list: Control
## Keeps the forms off screen while no window shows them.
var _forms_home: SubViewport
## Tab classes of the graph's windows that are open (D-044).
var _open_windows: Array[GDScript] = []
## The block the parameters window was opened beside, or -1, and on which side of it: -1 left, 1 right.
var _parameters_block := -1
var _parameters_side := -1.0
var _badge: XREPanelSurface
var _badge_anchor: Node3D
var _badge_geometry: Array[GeometryInstance3D] = []
var _badge_label: Label
var _badge_open: Button
var _badge_detach: Button
var _title: Label
var _status_label: Label
var _pointers: Array[Pointer] = []
var _markers: Array[Marker] = []
var _target_wires: Array[TargetWire] = []
var _catalog := PackedStringArray()
var _selected := -1
var _pending_id := -1
var _pending_port := -1
var _pending_input := false
var _pending_hand: XREHand
var _target_pick := -1
var _refresh_queued := false
var _rebuild_queued := false
var _picker: XREPicker
var _keyboard: XREVirtualKeyboard
var _keyboard_target: WeakRef
## The rig-locked windows of the graph, which move by their corner handles (docs/vr_ui.md, D-040).
var _windows: Array[XREPanelSurface] = []
var _built_state: Dictionary = {}
var _built_path := ""
var _built_host: WeakRef
var _built_script: Script


func _init(document: XREDocument, rig: XRERig, icons: XREIcons, theme: Theme = null) -> void:
	_document = document
	_rig = rig
	_icons = icons
	blueprint = XREBlueprintDocument.retain_editor_shared()
	_workspace = Node3D.new()
	_workspace.name = "Workspace"
	_workspace.top_level = true
	add_child(_workspace)
	_floating_ui = Node3D.new()
	_floating_ui.name = "FloatingUI"
	add_child(_floating_ui)
	canvas = XREBlueprintCanvas.new()
	canvas.set_display(document.features.get_value(XREFeatureSettings.NODE_DISPLAY))
	canvas.set_port_display(document.features.get_value(XREFeatureSettings.PORT_DISPLAY))
	_workspace.add_child(canvas)
	_toolbar = XREPanelSurface.new(Vector2(840, 150), 0.0009, 1.5, theme)
	_toolbar.position = Vector3(0, 0.42, 0.03)
	_floating_ui.add_child(_toolbar)
	_build_toolbar()
	_forms_home = SubViewport.new()
	_forms_home.name = "FormsHome"
	_forms_home.disable_3d = true
	_forms_home.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_forms_home)
	parameters = XREBlueprintEditor.new()
	parameters.operation_source = &"vr_panel"
	parameters.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if theme != null: parameters.theme = theme
	_forms_home.add_child(parameters)
	parameters.setup(blueprint, true)
	parameters.graph_scene_requested.connect(_open_owner_scene)
	parameters.text_edit_requested.connect(_show_keyboard, CONNECT_DEFERRED)
	_keyboard = XREVirtualKeyboard.new(theme)
	_keyboard.applied.connect(_apply_keyboard)
	_floating_ui.add_child(_keyboard)
	_build_block_list(theme)
	_windows = [_toolbar, _keyboard]
	for window: XREPanelSurface in _windows: window.add_corner_handles()
	_update_window_shape()
	_workspace.hide()
	_floating_ui.hide()
	_badge = XREPanelSurface.new(Vector2(340, 170), 0.00065, 1.5, theme)
	add_child(_badge)
	var column := VBoxContainer.new()
	_badge.root.add_child(column)
	_badge_label = Label.new()
	_badge_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_badge_label)
	_badge_open = _button(column, "Create Blueprint", open_selected)
	_badge_detach = _button(column, "Detach Blueprint", detach_selected)
	_badge.set_shown(false)
	for hand: XREHand in [rig.right_hand, rig.left_hand]:
		var pointer := Pointer.new()
		pointer.hand = hand
		_pointers.append(pointer)
	_picker = XREPicker.new()


func _enter_tree() -> void:
	print("XR Editor: Blueprints VR D-034 loaded from ", ProjectSettings.globalize_path("res://"))
	_dimmer = create_dimmer()
	_rig.camera.add_child(_dimmer)
	_dimmer.hide()
	_picker.scenario = get_viewport().find_world_3d().scenario
	_root = _document.get_scene_root()
	blueprint.update_active_scene(_root)
	blueprint.changed.connect(_schedule_rebuild)
	blueprint.operation_recorded.connect(_graph_operation)
	_document.selection_changed.connect(_selection_changed)
	_document.scene_changed.connect(_scene_changed)
	_document.files_changed.connect(_schedule_refresh)
	_document.blueprint_bindings_changed.connect(_schedule_refresh)
	_document.operation_recorded.connect(_scene_operation)
	_document.features.changed.connect(_feature_changed)
	_document.prepare_play = prepare_play
	_schedule_refresh()


func _exit_tree() -> void:
	_set_ui_overlay(false)
	if is_instance_valid(_dimmer): _dimmer.queue_free()
	cancel_connection()
	_target_pick = -1
	save_draft()
	blueprint.changed.disconnect(_schedule_rebuild)
	blueprint.operation_recorded.disconnect(_graph_operation)
	_document.selection_changed.disconnect(_selection_changed)
	_document.scene_changed.disconnect(_scene_changed)
	_document.files_changed.disconnect(_schedule_refresh)
	_document.blueprint_bindings_changed.disconnect(_schedule_refresh)
	_document.operation_recorded.disconnect(_scene_operation)
	_document.features.changed.disconnect(_feature_changed)
	if _document.prepare_play == prepare_play: _document.prepare_play = Callable()
	for pointer: Pointer in _pointers:
		pointer.hand.unclaim(self)
		pointer.hand.unclaim_stick(self)
	_picker = null
	XREBlueprintDocument.release_editor_shared()


func _process(delta: float) -> void:
	if is_instance_valid(_badge_anchor) and _badge_anchor.is_inside_tree():
		# As light icons do (XREIcons), the badge keeps its size in view farther than
		# BADGE_DISTANCE away, so that its text stays readable (D-043); nearer, it keeps its size.
		var head := _rig.camera.global_position
		var up := _rig.global_basis.y.normalized()
		var base := _badge_position()
		var size := maxf(base.distance_to(head) / BADGE_DISTANCE, 1.0)
		var point := base + up * (_badge.size_m.y * 0.5 * size)
		_badge.global_transform = Transform3D(XREPanels.facing(point, head, up) * Basis.from_scale(Vector3.ONE * size), point)
	else:
		_badge.set_shown(false)
	for marker: Marker in _markers:
		marker.visual.visible = logic_mode and is_instance_valid(marker.host) and marker.host.is_inside_tree() and is_instance_valid(marker.anchor) and marker.anchor.is_inside_tree()
		if marker.visual.visible: marker.visual.global_position = marker.anchor.global_position + _rig.global_basis.y * 0.22
	if _workspace.visible: canvas.face_user(_rig.camera.global_position)
	for pointer: Pointer in _pointers:
		_update_pointer(pointer, delta)
		_keyboard.poll_trigger(pointer.hand, pointer.surface == _keyboard and _keyboard.is_shown())
	_update_target_wires()
	if _workspace.visible and _rig.right_hand.ax_pressed and _rig.right_hand.is_free_for(self):
		_rig.right_hand.claim(self)
		delete_block()


## Catalog scanning is event-driven, never part of the frame loop.
func refresh_catalog() -> void:
	_catalog.clear()
	_collect_graphs("res://")
	_catalog.sort()
	_refresh_markers()
	_selection_changed()
	changed.emit()


## Cached project sources for the catalog; refreshing is explicit or event-driven.
func graph_paths() -> PackedStringArray:
	return _catalog


## Creates source without changing a scene node; its host is chosen explicitly later.
func create_unassigned() -> bool:
	if _root == null: return false
	_finish_holds()
	if not save_draft(): return false
	blueprint.perform(blueprint.new_graph, &"vr_panel")
	blueprint.set_scene_root(_root)
	var state := blueprint.graph.snapshot()
	state["host_path"] = NodePath("")
	blueprint.perform(blueprint.commit.bind("Clear Host", state), &"vr_panel")
	if not blueprint.perform(blueprint.save_graph.bind(_new_path(_root)), &"vr_panel"): return false
	show_graph()
	_message("New graph. Choose host before Build & Attach.")
	return true


## Finds source metadata or a legacy generated script's adjacent .tres.
static func source_path(node: Node) -> String:
	if not is_instance_valid(node): return ""
	var saved: String = str(node.get_meta(&"_xre_blueprint", ""))
	if not saved.is_empty(): return saved
	var script := node.get_script() as Script
	if script != null and script.resource_path.ends_with(".generated.gd") and script.source_code.begins_with(XREBlueprintCompiler.HEADER):
		return script.resource_path.trim_suffix(".generated.gd") + ".tres"
	return ""


## Resolves the selected object's existing host before offering creation.
func open_selected() -> void:
	var selected := _document.get_selection()
	if selected.size() != 1:
		_message("Select exactly one scene node.")
		return
	var host := related_host(selected[0])
	if host != null: open_graph(source_path(host))
	else: create_for(selected[0])


## Adds a Logic child through the scene document if the chosen node has a script.
func create_for(node: Node) -> bool:
	if _root == null or not is_instance_valid(node) or not (node == _root or _root.is_ancestor_of(node)): return false
	_finish_holds()
	if not save_draft(): return false
	var host := node
	if node.get_script() != null:
		host = Node.new()
		host.name = "Logic"
		_document.add_node(host, node, XREDocument.Source.PANEL)
	blueprint.perform(blueprint.new_graph, &"vr_panel")
	blueprint.set_scene_root(_root)
	if not blueprint.perform(blueprint.set_host_node.bind(host), &"vr_panel"): return false
	var path := _new_path(host)
	if not blueprint.perform(blueprint.save_graph.bind(path), &"vr_panel"):
		_message(blueprint.last_error)
		return false
	if not _document.assign_blueprint(host, path, null, XREDocument.Source.PANEL):
		_message("Could not assign Blueprint to this scene node.")
		return false
	_refresh_markers()
	show_graph()
	_message("Created " + path.get_file() + ". Build & Attach enables its behavior.")
	return true


## Incomplete source edits survive closing and switching; generated code is built separately.
func save_draft() -> bool:
	if is_instance_valid(parameters) and parameters.is_inside_tree(): parameters.flush_parameters()
	if not blueprint.is_dirty(): return true
	if blueprint.path.is_empty(): return blueprint.save_recovery()
	var success: bool = blueprint.perform(blueprint.save_graph.bind(blueprint.path), &"vr_panel")
	if not success: _message(blueprint.last_error)
	return success


## Saves the previous draft and opens this source in the shared document.
func open_graph(path: String) -> bool:
	_finish_holds()
	if blueprint.path != path:
		if not save_draft(): return false
		if not blueprint.perform(blueprint.open_graph.bind(path), &"vr_panel"):
			_message(blueprint.last_error)
			return false
	show_graph()
	_message("Opened " + path.get_file())
	return true


## Reopening focuses one shared workspace rather than copying its document.
func show_graph() -> void:
	cancel_connection()
	_target_pick = -1
	_selected = -1
	canvas.center_graph(blueprint.graph)
	canvas.rebuild(blueprint.graph)
	var head := _rig.camera.global_position
	var orientation := XREPanels.facing(head - _rig.camera.global_basis.z, head, Vector3.UP)
	var ui_pose := Transform3D(orientation, head - orientation.z - Vector3.UP * 0.12)
	if not blueprint.graph.vr_placed:
		var state := blueprint.graph.snapshot()
		state["vr_placed"] = true
		state["vr_workspace"] = ui_pose
		state["vr_center"] = canvas.get_graph_center()
		blueprint.perform(blueprint.commit.bind("Place VR Graph", state), &"vr_graph")
	_workspace.global_transform = blueprint.graph.vr_workspace
	canvas.face_user(head)
	_floating_ui.global_transform = ui_pose
	_keyboard.close()
	close_block_palette()
	close_parameters()
	_workspace.show()
	_floating_ui.show()
	_dimmer.show()
	_set_ui_overlay(true)
	parameters.select_block(-1)
	_schedule_rebuild()
	changed.emit()


## Closes only the view, leaving source and scene assignments intact.
func close_graph() -> void:
	for pointer: Pointer in _pointers:
		if pointer.held != null: _finish_hold(pointer, true)
	if not save_draft(): return
	for pointer: Pointer in _pointers: _leave(pointer)
	cancel_connection()
	_target_pick = -1
	_keyboard.close()
	close_block_palette()
	close_parameters()
	_workspace.hide()
	_floating_ui.hide()
	_dimmer.hide()
	_set_ui_overlay(false)
	_message("Back to scene. Blueprint draft saved.")


## Whether the spatial workspace is visible.
func is_open() -> bool:
	return _workspace.visible


## Removes script/source assignment together while retaining project files.
func detach_selected() -> bool:
	var selected := _document.get_selection()
	if selected.size() != 1: return false
	var host := related_host(selected[0])
	if host == null: return false
	if not _document.assign_blueprint(host, "", null, XREDocument.Source.PANEL):
		_message("The node has an unrelated script; it was kept.")
		return false
	_refresh_markers()
	_selection_changed()
	_message("Blueprint detached. Its files remain in the catalog.")
	return true


## Prevents play from silently using stale code after an invalid graph edit.
func prepare_play() -> bool:
	if blueprint.path.is_empty() or not blueprint.scene_context_active(): return true
	var host := blueprint.get_host()
	if host == null or source_path(host) != blueprint.path: return true
	if _keyboard.is_shown():
		_message("Apply or close text input before Play.")
		return false
	parameters.flush_parameters()
	if not parameters.validate_active_target(): return false
	if _built_path == blueprint.path and _built_state == blueprint.graph.snapshot() and _built_host != null and _built_host.get_ref() == host and host.get_script() == _built_script:
		var errors := blueprint.validate_scene()
		if errors.is_empty(): return true
		_message("\n".join(errors))
		return false
	return build_and_attach()


## Validates the visible draft, builds GDScript and assigns through the scene document.
func build_and_attach() -> bool:
	if _keyboard.is_shown():
		_message("Apply or close text input before building.")
		return false
	if blueprint.get_host() == null:
		_message(blueprint.scene_context_message() if not blueprint.scene_context_active() else "Choose host before Build & Attach.")
		return false
	if not parameters.validate_active_target():
		_message("Correct the visible Target before building.")
		return false
	if not blueprint.perform(blueprint.build, &"vr_panel"):
		_message(blueprint.last_error)
		return false
	var script := ResourceLoader.load(blueprint.script_path(), "GDScript", ResourceLoader.CACHE_MODE_REPLACE) as Script
	if script == null or not _document.assign_blueprint(blueprint.get_host(), blueprint.path, script, XREDocument.Source.PANEL):
		_message("Choose an empty Blueprint host in its own scene.")
		return false
	_refresh_markers()
	_built_state = blueprint.graph.snapshot()
	_built_path = blueprint.path
	_built_host = weakref(blueprint.get_host())
	_built_script = script
	_message("Built and attached. Y runs the scene.")
	return true


## Adds a palette block beside the selected card through graph undo history.
func add_block(kind: String) -> void:
	var point := Vector2(80, 100)
	var previous := blueprint.graph.find_node(_selected)
	if not previous.is_empty(): point = previous["position"] + Vector2(320, 0)
	else: point += Vector2(320 * blueprint.graph.nodes.size(), 0)
	blueprint.perform(blueprint.add_block.bind(kind, point), &"vr_panel")
	if not blueprint.graph.nodes.is_empty(): select_block(blueprint.graph.nodes.back()["id"])
	# Pinned to a hand, the palette stays for the next block.
	_dismiss_window(XREBlueprintPaletteTab, false)


## Selects a graph block without replacing the editor's scene selection. Its
## parameters window opens beside it (D-043, D-044), or comes there from
## another block, or pulses if it is there already (D-046); with no block, -1,
## it closes, unless it is pinned to a hand. Without [param open_parameters]
## the window is left as it is: the plus opens only the block palette.
func select_block(id: int, open_parameters: bool = true) -> void:
	_selected = id
	canvas.select_block(id)
	parameters.select_block(id)
	if id >= 0:
		if open_parameters: _show_parameters(id)
	else: _dismiss_window(XREBlueprintParametersTab, false)
	changed.emit()


## Closes the parameters window, pinned too, keeping what was typed in it; the block stays selected.
func close_parameters() -> void:
	_dismiss_window(XREBlueprintParametersTab, true)


## Whether the parameters window is open.
func is_parameters_shown() -> bool:
	return XREBlueprintParametersTab in _open_windows


## Closes the block palette, pinned too.
func close_block_palette() -> void:
	_dismiss_window(XREBlueprintPaletteTab, true)


## Whether the block palette is open.
func is_block_palette_shown() -> bool:
	return XREBlueprintPaletteTab in _open_windows


## The graph's window of tab class [param type] was closed, by its × or as the
## graph asked: what was typed in it is kept, and the keyboard typing into it closes.
func window_closed(type: GDScript) -> void:
	_open_windows.erase(type)
	if type != XREBlueprintParametersTab: return
	_parameters_block = -1
	if is_instance_valid(parameters) and parameters.is_inside_tree(): parameters.flush_parameters()
	var field := _keyboard_target.get_ref() as LineEdit if _keyboard_target != null else null
	if field != null and parameters.is_ancestor_of(field): _keyboard.close()


## Puts [param form] back off screen when the window that showed it is freed ([XREBlueprintFormTab]).
func take_back(form: Control) -> void:
	if is_instance_valid(_forms_home) and not _forms_home.is_queued_for_deletion() and form.get_parent() == null:
		_forms_home.add_child(form)


## Where the parameters window of block [param id] goes: beside the card, at
## its height, facing the head; on its left, or on its right if more cards are
## there to cover on the left. Without the card, to the right of the graph's
## toolbar, where the window was before D-044.
func parameters_pose(id: int) -> Transform3D:
	if not canvas.has_block(id):
		var point := _floating_ui.global_transform * Vector3(0.85, -0.05, 0.03)
		return Transform3D(XREPanels.facing(point, _rig.camera.global_position, _rig.global_basis.y), point)
	var card := canvas.global_transform * canvas.get_block_transform(id)
	var size := XREPanels.WINDOW_SIZE * XREPanels.WINDOW_PIXEL_SIZE
	var reach := XREBlueprintCanvas.CARD_WIDTH + PARAMETERS_GAP + size.x
	var inverse := card.affine_inverse()
	var left := 0
	var right := 0
	for block: Dictionary in blueprint.graph.nodes:
		if block["id"] == id or not canvas.has_block(block["id"]): continue
		var other := inverse * (canvas.global_transform * canvas.get_block_transform(block["id"])).origin
		if absf(other.y) > size.y * 0.5 or absf(other.x) > reach: continue
		if other.x < 0.0: left += 1
		else: right += 1
	_parameters_side = -1.0 if left <= right else 1.0
	return _beside(card, _parameters_side)


## Where the block palette of block [param id] goes: beside the card, on the
## side its parameters window isn't.
func palette_pose(id: int) -> Transform3D:
	var card := canvas.global_transform * canvas.get_block_transform(id)
	var side := -_parameters_side if is_parameters_shown() and _parameters_block == id else 1.0
	return _beside(card, side)


## A window's pose beside a card at [param card], on its [param side] (-1 left,
## 1 right), at its height, facing the head: nearer the head than the card and
## than the cards it covers, by [constant PARAMETERS_LIFT].
func _beside(card: Transform3D, side: float) -> Transform3D:
	var size := XREPanels.WINDOW_SIZE * XREPanels.WINDOW_PIXEL_SIZE
	var head := _rig.camera.global_position
	var up := _rig.global_basis.y.normalized()
	var across := card.basis.x.normalized()
	var point := card.origin + across * side * (XREBlueprintCanvas.CARD_WIDTH * 0.5 + PARAMETERS_GAP + size.x * 0.5)
	var distance := minf(head.distance_to(point), head.distance_to(card.origin))
	var inverse := card.affine_inverse()
	for block: Dictionary in blueprint.graph.nodes:
		if not canvas.has_block(block["id"]): continue
		var other := (canvas.global_transform * canvas.get_block_transform(block["id"])).origin
		var local := inverse * other
		# Cards whose centers are within the window and half a card around it, as seen beside the block.
		var from := XREBlueprintCanvas.CARD_WIDTH * 0.5 + PARAMETERS_GAP
		var along := local.x * side
		if along < from - XREBlueprintCanvas.CARD_WIDTH or along > from + size.x + XREBlueprintCanvas.CARD_WIDTH * 0.5 or absf(local.y) > size.y * 0.5 + 0.15: continue
		distance = minf(distance, head.distance_to(other) - XREBlueprintCanvas.CUBOID_DEPTH)
	point = head + (point - head).normalized() * maxf(distance - PARAMETERS_LIFT, 0.2)
	return Transform3D(XREPanels.facing(point, head, up), point)


## Asks for the graph's window of tab class [param type] at [param pose].
func _request_window(type: GDScript, pose: Transform3D) -> void:
	if not type in _open_windows: _open_windows.append(type)
	window_requested.emit(type, pose)


## Asks for the graph's window of tab class [param type] to close: [param always], or unless pinned.
func _dismiss_window(type: GDScript, always: bool) -> void:
	if not type in _open_windows: return
	# Without the panels (a test of the graph alone) the window just closes.
	if window_dismissed.get_connections().is_empty(): window_closed(type)
	else: window_dismissed.emit(type, always)


## Whether [param hand] holds a card or a window of the graph.
func is_holding(hand: XREHand) -> bool:
	for pointer: Pointer in _pointers:
		if pointer.hand == hand: return pointer.held != null
	return false


## Opens the parameters window beside block [param id] (-1: the selected one,
## or none); open there already, it pulses.
func _show_parameters(id: int = -1) -> void:
	if not _workspace.visible: return
	if id < 0: id = _selected
	if is_parameters_shown() and (id == _parameters_block or id < 0):
		window_pulse_requested.emit(XREBlueprintParametersTab)
		return
	_parameters_block = id
	_request_window(XREBlueprintParametersTab, parameters_pose(id))


## Removes the selected block and incident wires through the graph document.
func delete_block(id: int = -1) -> void:
	var target := id if id >= 0 else _selected
	if target < 0 or blueprint.graph.find_node(target).is_empty(): return
	for pointer: Pointer in _pointers:
		if pointer.block == target: _finish_hold(pointer, false)
	cancel_connection()
	if _target_pick == target: _target_pick = -1
	var was_selected := target == _selected
	blueprint.perform(blueprint.remove_blocks.bind([target] as Array[int]), &"vr_graph")
	if was_selected: select_block(-1)


## Connected ports detach one wire as one undo step; empty ports start a click-click wire.
## [param edge] is the wire on the port to detach, the one lit under the ray
## ([method XREBlueprintCanvas.get_hit_edge]); -1 or another port's takes the port's last wire.
func click_port(id: int, port: int, input: bool, hand: XREHand = null, edge: int = -1) -> bool:
	if not canvas.has_port(id, port, input): return false
	if _pending_id == id and _pending_port == port and _pending_input == input:
		# The same port again takes the wire back (D-043), as the trigger on nothing does.
		cancel_connection()
		_message("Wire cancelled.")
		return true
	if _pending_id < 0:
		# A connected port lets go of its end of the last wire on it, as dragging a connected
		# port does in GraphEdit (D-044): the wire stays on its other end and follows the ray,
		# to go to another port, or away with the trigger on nothing. One undo puts it back.
		var detached := -1
		for index: int in blueprint.graph.edges.size():
			var wire_on: Dictionary = blueprint.graph.edges[index]
			if (input and wire_on["to"] == id and wire_on["to_port"] == port) or (not input and wire_on["from"] == id and wire_on["from_port"] == port):
				detached = index
				if index == edge: break
		if detached >= 0:
			var state := blueprint.graph.snapshot()
			var edges: Array = state["edges"]
			var wire: Dictionary = edges[detached]
			edges.remove_at(detached)
			if not blueprint.perform(blueprint.commit.bind("Disconnect Ports", state), &"vr_graph"): return false
			_pending_id = wire["from"] if input else wire["to"]
			_pending_port = wire["from_port"] if input else wire["to_port"]
			_pending_input = not input
			_pending_hand = hand
			canvas.highlight_ports(canvas.port_type(_pending_id, _pending_port, _pending_input), not _pending_input)
			_message("Wire detached. Trigger on a port reconnects it; on empty space removes it.")
			return true
		_pending_id = id
		_pending_port = port
		_pending_input = input
		_pending_hand = hand
		canvas.highlight_ports(canvas.port_type(id, port, input), not input)
		_message("Press trigger on a compatible port. The same port or empty space cancels the wire.")
		return true
	if input == _pending_input:
		_message("Connect an output to an input.")
		return false
	var from := id if _pending_input else _pending_id
	var from_port := port if _pending_input else _pending_port
	var to := _pending_id if _pending_input else id
	var to_port := _pending_port if _pending_input else port
	var success: bool = blueprint.perform(blueprint.connect_blocks.bind(from, from_port, to, to_port), &"vr_graph")
	if success: cancel_connection()
	else: _message(blueprint.last_error)
	return success


## Discards only the pending connection preview.
func cancel_connection() -> void:
	_pending_id = -1
	_pending_port = -1
	_pending_input = false
	_pending_hand = null
	canvas.hide_connection()


## Arms direct scene picking for the selected block's static Target.
func pick_target() -> void:
	var block := blueprint.graph.find_node(_selected)
	if block.is_empty() or not (block["params"] as Dictionary).has("target"):
		_message("Select a block with a Target first.")
		return
	if not blueprint.scene_context_active():
		_message(blueprint.scene_context_message())
		return
	cancel_connection()
	_target_pick = _selected
	_message("Point at a scene object and press trigger. Invisible targets are in the parameter tree.")


## Finds a direct host, child behavior or ancestor host for a scene selection.
func related_host(node: Node) -> Node:
	if not source_path(node).is_empty(): return node
	for marker: Marker in _markers:
		if is_instance_valid(marker.host) and marker.host.get_parent() == node: return marker.host
	var ancestor := node.get_parent()
	while ancestor != null:
		if not source_path(ancestor).is_empty(): return ancestor
		if ancestor == _root: break
		ancestor = ancestor.get_parent()
	return null


## Shows cached host markers without modifying the edited scene.
func set_logic_mode(enabled: bool) -> void:
	logic_mode = enabled
	changed.emit()


func _build_toolbar() -> void:
	var column := VBoxContainer.new()
	_toolbar.root.add_child(column)
	_title = Label.new()
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_title)
	var row := HBoxContainer.new()
	column.add_child(row)
	_button(row, "Back to scene", close_graph)
	_button(row, "Save draft", save_draft)
	_button(row, "Build & Attach", build_and_attach)
	_button(row, "Undo", func() -> void: blueprint.perform(blueprint.undo, &"vr_panel"))
	_button(row, "Redo", func() -> void: blueprint.perform(blueprint.redo, &"vr_panel"))
	var second := HBoxContainer.new()
	column.add_child(second)
	_button(second, "Pick Target", pick_target)
	_button(second, "Cancel wire / target", func() -> void:
		cancel_connection()
		_target_pick = -1)
	_button(second, "Variables", func() -> void:
		parameters.show_variables()
		_show_parameters())
	_button(second, "Choose host", func() -> void:
		parameters.show_host_picker()
		_show_parameters())
	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_status_label)


func _update_pointer(pointer: Pointer, delta: float) -> void:
	var hand := pointer.hand
	if pointer.held != null:
		canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
		if not hand.get_has_tracking_data(): _finish_hold(pointer, false)
		elif pointer.block >= 0 and pointer.depth_uses_grip and not _rig.has_grip_pose(hand): _finish_hold(pointer, false)
		elif not (hand.trigger_held if pointer.by_trigger else hand.grip_held): _finish_hold(pointer, true)
		else:
			if pointer.block >= 0:
				var physical := _rig.hand_pose(hand, pointer.depth_uses_grip).origin
				if not pointer.touched:
					# Only the hand's motion along the rod, relative to the body, reels the
					# card; moving across the rod (sideways, up, down) keeps its length.
					# The rod direction is averaged over the frame, which makes a swing
					# around the body with the rod pointing outwards exactly length-preserving.
					var offset := _body_offset(physical)
					var along := (_rig.global_basis.inverse() * -hand.global_basis.z).normalized()
					var mean := along + pointer.along
					if mean.is_zero_approx(): mean = along
					pointer.distance = maxf(XREManipulator.TOUCH_RADIUS, pointer.distance + (offset - pointer.body_offset).dot(mean.normalized()) * (pointer.gain - 1.0))
					pointer.body_offset = offset
					pointer.along = along
				var contact := physical if pointer.touched else hand.global_position - hand.global_basis.z.normalized() * pointer.distance
				canvas.preview_grab(pointer.block, contact, pointer.grab_point, _rig.camera.global_position)
				if pointer.touched: hand.hide_ray()
				else: hand.show_ray(pointer.distance, true)
			else:
				var target := hand.global_transform * pointer.hold
				if pointer.held == _keyboard: pointer.held.global_transform = target
				else: pointer.held.global_transform = Transform3D(XREPanels.facing(target.origin, _rig.camera.global_position, Vector3.UP), target.origin)
				if pointer.window != null: pointer.window.hover_handles(pointer.corner)
			return
	if not hand.is_free_for(self) or not hand.get_has_tracking_data():
		canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
		if _pending_hand == hand: cancel_connection()
		_leave(pointer)
		return
	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	var distance := 5.0
	var surface: XREPanelSurface
	var handle: XREPanelSurface
	var canvas_hit := -1.0
	if _workspace.visible and hand.grip_pressed:
		var touched := touch_block(hand)
		if touched >= 0:
			canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
			_start_hold(pointer, canvas, touched, _rig.hand_pose(hand, true).origin, true)
			return
	if pointer.surface != null and pointer.surface.is_pressed():
		surface = pointer.surface
		distance = surface.intersect_ray(origin, direction, INF, false)
	else:
		if _workspace.visible: canvas_hit = canvas.intersect_ray(origin, direction, distance)
		if _badge.is_shown():
			var hit := _badge.intersect_ray(origin, direction, distance)
			if hit >= 0:
				surface = _badge
				distance = hit
		if _workspace.visible:
			for window: XREPanelSurface in _windows:
				var hit := window.intersect_ray(origin, direction, distance)
				if hit >= 0:
					surface = window
					distance = hit
			# Handles lie outside the frames: only one nearer than any window is taken.
			for window: XREPanelSurface in _windows:
				var hit := window.intersect_handle(origin, direction, distance)
				if hit >= 0:
					handle = window
					distance = hit
			if handle != null: surface = null
		if canvas_hit >= 0 and canvas_hit < distance:
			surface = null
			handle = null
	if handle != null:
		canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
		if _pending_hand == hand: _preview_connection(origin + direction * maxf(distance, 0.01))
		_leave(pointer)
		hand.claim(self)
		hand.claim_stick(self)
		hand.show_ray(maxf(distance, 0.01), true)
		handle.hover_handles(handle.get_hit_corner())
		if hand.trigger_pressed or hand.grip_pressed: _hold_window(pointer, handle, handle.get_hit_corner(), not hand.grip_pressed)
		return
	if surface != null:
		canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
		if _pending_hand == hand: _preview_connection(origin + direction * maxf(distance, 0.01))
		if pointer.surface != surface:
			_leave(pointer)
			pointer.surface = surface
		hand.claim(self)
		hand.claim_stick(self)
		hand.show_ray(maxf(distance, 0.01), true)
		surface.hover_handles(-1)
		if surface == _keyboard:
			if distance >= 0: _keyboard.hover_pointer(hand, surface.get_hit_pixel())
			else: _keyboard.leave_pointer(hand)
			if hand.grip_pressed: _hold_window(pointer, _keyboard, -1, false)
			return
		if not pointer.drives:
			pointer.drives = true
			for other: Pointer in _pointers:
				if other != pointer and other.surface == surface and other.drives:
					if surface.is_pressed() or hand == _rig.left_hand: pointer.drives = false
					else: other.drives = false
		if not pointer.drives: return
		if distance >= 0:
			surface.pointer_move(surface.get_hit_pixel())
		if hand.trigger_pressed: surface.pointer_button(true)
		if hand.trigger_released: surface.pointer_button(false)
		if hand.grip_pressed and surface != _badge and not surface.is_pressed(): _hold_window(pointer, surface, -1, false)
		elif hand == _rig.right_hand:
			var tilt := XREPanels._tilt(hand.get_vector2(&"primary").y)
			if tilt != 0: surface.pointer_scroll(tilt * XREPanels.SCROLL_SPEED * delta)
		return
	_leave(pointer)
	if _workspace.visible:
		var hit := canvas_hit
		if _pending_hand == hand: _preview_connection(origin + direction * (hit if hit >= 0 else 0.8), canvas.get_hit_id() if hit >= 0 else -1, canvas.get_hit_port() if hit >= 0 else -1, canvas.get_hit_input())
		if hit >= 0:
			hand.claim(self)
			hand.show_ray(hit, true, XREBlueprintCanvas.HIT_DOT_OFFSET)
			var id := canvas.get_hit_id()
			canvas.hover_actions(id, canvas.get_hit_plus(), canvas.get_hit_delete(), hand == _rig.right_hand, canvas.get_hit_port(), canvas.get_hit_input(), canvas.get_hit_edge() if _pending_id < 0 else -1)
			if hand.grip_pressed: _start_hold(pointer, canvas, id, origin + direction * hit)
			elif hand.trigger_pressed:
				if canvas.get_hit_plus(): _show_block_palette(id)
				elif canvas.get_hit_delete(): delete_block(id)
				elif canvas.get_hit_port() >= 0: click_port(id, canvas.get_hit_port(), canvas.get_hit_input(), hand, canvas.get_hit_edge())
				else: select_block(id)
			if hand == _rig.right_hand and hand.ax_pressed: delete_block()
			return
	canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
	if _pending_scene_target():
		_update_scene_target_pointer(hand, origin, direction)
		return
	if _pending_hand == hand:
		hand.claim(self)
		hand.show_ray(0.8, false)
		# The trigger on nothing takes the wire back (D-043).
		if hand.trigger_pressed:
			cancel_connection()
			_message("Wire cancelled.")
		return
	if _target_pick >= 0:
		if not blueprint.scene_context_active():
			_target_pick = -1
			_message(blueprint.scene_context_message())
			return
		hand.claim(self)
		var hit_node: Node
		var hit_distance := 5.0
		var end := origin + direction * 5.0
		if _icons != null and _icons.cast_segment(origin, end):
			hit_node = _icons.get_hit_node()
			hit_distance = _icons.get_hit_distance()
		elif is_instance_valid(_root) and _picker.cast_segment(_root, origin, end):
			hit_node = _picker.get_hit_node()
			hit_distance = _picker.get_hit_distance()
		hand.show_ray(hit_distance, hit_node != null)
		if hand.trigger_pressed and hit_node != null:
			if blueprint.perform(blueprint.choose_target.bind(_target_pick, hit_node), &"vr_graph"):
				_target_pick = -1
				_message("Target selected.")
			else: _message(blueprint.last_error)
		return
	if logic_mode:
		for marker: Marker in _markers:
			if not marker.visual.visible: continue
			var along := direction.dot(marker.visual.global_position - origin)
			if along > 0 and along < 5.0 and (origin + direction * along).distance_squared_to(marker.visual.global_position) < 0.05 * 0.05:
				hand.claim(self)
				hand.show_ray(along, true)
				if hand.trigger_pressed: open_graph(marker.path)
				return


func _preview_connection(point: Vector3, end_id: int = -1, end_port: int = -1, end_input: bool = false) -> void:
	canvas.show_connection(_pending_id, _pending_port, _pending_input, canvas.to_local(point), end_id, end_port, end_input)


func _start_hold(pointer: Pointer, node: Node3D, block: int, point: Vector3 = Vector3.ZERO, touched: bool = false) -> void:
	for other: Pointer in _pointers:
		if other.held != null: return
	cancel_connection()
	_leave(pointer)
	pointer.held = node
	pointer.block = block
	pointer.window = null
	pointer.corner = -1
	pointer.by_trigger = false
	var target := node.global_transform
	if block >= 0:
		select_block(block)
		pointer.before = canvas.get_block_transform(block)
		pointer.touched = touched
		target = canvas.global_transform * pointer.before
		pointer.grab_point = target.affine_inverse() * point
		pointer.distance = pointer.hand.to_local(point).length()
		pointer.depth_uses_grip = _rig.has_grip_pose(pointer.hand)
		var physical := _rig.hand_pose(pointer.hand, pointer.depth_uses_grip).origin
		pointer.body_offset = _body_offset(physical)
		pointer.along = (_rig.global_basis.inverse() * -pointer.hand.global_basis.z).normalized()
		pointer.gain = 1.0 if touched else maxf(_body_reach(point) / maxf(_body_reach(physical), XREManipulator.MIN_REACH), 1.0)
		if touched: pointer.hand.hide_ray()
		else: pointer.hand.show_ray(pointer.distance, true)
	else: pointer.hold = pointer.hand.global_transform.affine_inverse() * target
	pointer.hand.claim(self)


## Takes [param window], by its [param corner] handle or by its interface
## with -1, held by the trigger if [param by_trigger], otherwise by the grip.
## The toolbar leads the graph's windows: taking it moves them all.
func _hold_window(pointer: Pointer, window: XREPanelSurface, corner: int, by_trigger: bool) -> void:
	_start_hold(pointer, _floating_ui if window == _toolbar else window, -1)
	if pointer.held == null: return
	pointer.window = window
	pointer.corner = corner
	pointer.by_trigger = by_trigger


## Distance from [param point] to the body: a vertical shoulder-to-hip segment
## below the neck pivot of [param head]. Sets the HOMER gain of a far grab.
static func body_reach(head: Transform3D, up: Vector3, point: Vector3) -> float:
	var neck := head * NECK_FROM_EYES
	var axis := Geometry3D.get_closest_point_to_segment(point, neck - up * BODY_TOP, neck - up * BODY_BOTTOM)
	return point.distance_to(axis)


func _body_reach(point: Vector3) -> float:
	return body_reach(_rig.camera.global_transform, _rig.global_basis.y.normalized(), point)


## Where [param point] is relative to the neck pivot, in rig space: walking, turning
## the head and flying the rig leave it unchanged.
func _body_offset(point: Vector3) -> Vector3:
	var to_rig := _rig.global_transform.affine_inverse()
	return to_rig * point - to_rig * (_rig.camera.global_transform * NECK_FROM_EYES)


func _finish_hold(pointer: Pointer, commit: bool) -> void:
	if pointer.block >= 0:
		if commit: canvas.commit_move(blueprint, pointer.block)
		else: canvas.preview_transform(pointer.block, pointer.before)
	pointer.held = null
	pointer.block = -1
	pointer.window = null
	pointer.by_trigger = false
	pointer.hand.show_ray(XREHand.RAY_LENGTH, false)
	pointer.hand.unclaim(self)


func _finish_holds() -> void:
	for pointer: Pointer in _pointers:
		if pointer.held != null: _finish_hold(pointer, true)


func _leave(pointer: Pointer) -> void:
	if pointer.surface != null:
		if pointer.surface == _keyboard: _keyboard.leave_pointer(pointer.hand)
		if pointer.drives: pointer.surface.pointer_exit()
		pointer.surface = null
		pointer.drives = false
	if pointer.held == null:
		pointer.hand.unclaim(self)
		pointer.hand.unclaim_stick(self)


## Touch checks the physical controller, then its aim origin for tracker compatibility.
func touch_block(hand: XREHand) -> int:
	if not _workspace.visible: return -1
	var id := canvas.intersect_touch(_rig.hand_pose(hand, true).origin)
	return id if id >= 0 else canvas.intersect_touch(hand.global_position)


## Earlier panel routing yields to nearby touch and to a closer keyboard surface.
func takes_pointer(hand: XREHand, origin: Vector3, direction: Vector3, distance: float) -> bool:
	if _workspace.visible: canvas.face_user(_rig.camera.global_position)
	if hand.grip_pressed and touch_block(hand) >= 0: return true
	if _workspace.visible:
		var card_hit := canvas.intersect_ray(origin, direction, distance)
		if card_hit >= 0 and card_hit < distance: return true
	if not _workspace.visible: return false
	# The graph's windows and their handles, nearer than the panel the ray is on.
	for window: XREPanelSurface in _windows:
		if window.intersect_ray(origin, direction, distance) >= 0 or window.intersect_handle(origin, direction, distance) >= 0: return true
	return false


func _selection_changed() -> void:
	var nodes := _document.get_selection()
	_badge_anchor = null
	_badge_geometry.clear()
	_badge.set_shown(false)
	if nodes.size() == 1 and is_instance_valid(nodes[0]):
		_badge_anchor = _anchor(nodes[0])
		if _badge_anchor != null: _collect_badge_geometry(_badge_anchor)
		var host := related_host(nodes[0])
		_badge_label.text = str(nodes[0].name) + (" · Blueprint" if host != null else " · Logic")
		_badge_open.text = "Open Blueprint" if host != null else "Create Blueprint"
		_badge_detach.visible = host != null
		_badge.set_shown(_badge_anchor != null)
	changed.emit()


## Selection/structural events cache geometry; the frame loop never walks the tree.
func _collect_badge_geometry(node: Node) -> void:
	var geometry := node as GeometryInstance3D
	if geometry != null and not (geometry is GPUParticles3D or geometry is CPUParticles3D):
		_badge_geometry.append(geometry)
	for child: Node in node.get_children(): _collect_badge_geometry(child)


func _badge_position() -> Vector3:
	var up := _rig.global_basis.y.normalized()
	var bounds := AABB()
	var found := false
	for geometry: GeometryInstance3D in _badge_geometry:
		if not is_instance_valid(geometry) or not geometry.is_inside_tree() or not geometry.is_visible_in_tree(): continue
		var local := geometry.custom_aabb
		if not local.has_surface(): local = geometry.get_aabb()
		var part := geometry.global_transform * local
		bounds = bounds.merge(part) if found else part
		found = true
	if not found: return _badge_anchor.global_position + up * 0.3
	# Support of the world AABB along rig-up keeps the whole panel outside it,
	# including rotated/nonuniform scales, offset children and changing CSG bounds.
	var radius := bounds.size.dot(up.abs()) * 0.5
	return bounds.get_center() + up * (radius + 0.1)


func _scene_changed() -> void:
	for pointer: Pointer in _pointers:
		if pointer.held != null: _finish_hold(pointer, false)
	cancel_connection()
	_target_pick = -1
	_root = _document.get_scene_root()
	_picker.scenario = get_viewport().find_world_3d().scenario
	blueprint.update_active_scene(_root)
	_refresh_markers()
	_selection_changed()
	_schedule_rebuild()


func _scene_operation(operation: StringName, _source: XREDocument.Source, _nodes: Array[Node], _time_usec: int) -> void:
	if operation in [&"assign_blueprint", &"detach_blueprint", &"remove_nodes", &"add_node"]: _schedule_refresh()


## A switch of the node display (D-039) redraws the open cards at once; a held card is put down first.
## So does a switch of the port display; a switch of the window shape bends or flattens the graph's windows.
func _feature_changed(key: StringName) -> void:
	if key == XREFeatureSettings.WINDOW_SHAPE:
		_update_window_shape()
		return
	var value := _document.features.get_value(key)
	var switched := false
	if key == XREFeatureSettings.NODE_DISPLAY: switched = canvas.set_display(value)
	elif key == XREFeatureSettings.PORT_DISPLAY: switched = canvas.set_port_display(value)
	if not switched: return
	_finish_holds()
	cancel_connection()
	canvas.rebuild(blueprint.graph)
	_schedule_rebuild()


func _graph_operation(operation: StringName, source: StringName, _time_usec: int) -> void:
	if source == &"vr_graph" or source == &"vr_panel": _document.record_graph_operation(operation, XREDocument.Source.TOOL if source == &"vr_graph" else XREDocument.Source.PANEL)


func _schedule_refresh() -> void:
	if _refresh_queued: return
	_refresh_queued = true
	_run_refresh.call_deferred()


func _run_refresh() -> void:
	_refresh_queued = false
	if is_inside_tree(): refresh_catalog()


func _schedule_rebuild() -> void:
	if _rebuild_queued: return
	_rebuild_queued = true
	_rebuild.call_deferred()


func _rebuild() -> void:
	_rebuild_queued = false
	if not is_inside_tree(): return
	for pointer: Pointer in _pointers:
		if pointer.held != null: _finish_hold(pointer, false)
	# A move or its undo keeps every card: rebuilding them all hitches on the headset.
	if not canvas.sync_placement(blueprint.graph): canvas.rebuild(blueprint.graph)
	_rebuild_target_wires()
	if _target_pick >= 0 and blueprint.graph.find_node(_target_pick).is_empty(): _target_pick = -1
	if _pending_id >= 0:
		if not canvas.has_port(_pending_id, _pending_port, _pending_input): cancel_connection()
		else: canvas.highlight_ports(canvas.port_type(_pending_id, _pending_port, _pending_input), not _pending_input)
	_title.text = (blueprint.path.get_file() if not blueprint.path.is_empty() else "Untitled") + " · Host: " + str(blueprint.graph.host_path)
	_status_label.text = status if blueprint.scene_context_active() else blueprint.scene_context_message()
	changed.emit()


func _refresh_markers() -> void:
	for marker: Marker in _markers:
		remove_child(marker.visual)
		marker.visual.queue_free()
	_markers.clear()
	if not is_instance_valid(_root): return
	var pending: Array[Node] = [_root]
	while not pending.is_empty():
		var node: Node = pending.pop_back()
		for child: Node in node.get_children(): pending.append(child)
		var path := source_path(node)
		if path.is_empty(): continue
		var anchor := _anchor(node)
		if anchor == null: continue
		var marker := Marker.new()
		marker.host = node
		marker.anchor = anchor
		marker.path = path
		marker.visual = Node3D.new()
		add_child(marker.visual)
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.045, 0.045, 0.015)
		marker.visual.add_child(XRERig.create_vr_mesh(mesh, XREBlueprintCanvas.material(Color("5999bb"))))
		var title := XRERig.create_vr_label(24, 0.00065)
		title.text = path.get_file().trim_suffix(".tres")
		title.position.y = 0.05
		marker.visual.add_child(title)
		_markers.append(marker)


func _anchor(node: Node) -> Node3D:
	var current := node
	while current != null:
		if current is Node3D: return current as Node3D
		if current == _root: break
		current = current.get_parent()
	return null


func _collect_graphs(folder: String) -> void:
	for entry: String in _document.list_folder(folder):
		var path := folder.path_join(entry)
		if entry.ends_with("/"): _collect_graphs(path.trim_suffix("/"))
		elif entry.get_extension() == "tres" and ResourceLoader.load(path) is XREBlueprintGraph: _catalog.append(path)


func _new_path(host: Node) -> String:
	var folder := _root.scene_file_path.get_base_dir() if not _root.scene_file_path.is_empty() else "res://"
	if not source_folder.is_empty(): folder = source_folder
	var base := str(host.name).validate_filename().to_snake_case() + "_blueprint"
	var path := folder.path_join(base + ".tres")
	var index := 2
	while FileAccess.file_exists(path) or FileAccess.file_exists(path.get_basename() + ".generated.gd"):
		path = folder.path_join(base + "_%d.tres" % index)
		index += 1
	return path


func _open_owner_scene() -> void:
	if not blueprint.graph.scene_path.is_empty(): _document.open_scene(blueprint.graph.scene_path, XREDocument.Source.PANEL)


func _message(text: String) -> void:
	status = text
	if is_instance_valid(_status_label): _status_label.text = text
	changed.emit()


func _button(parent: Node, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	parent.add_child(button)
	return button


func _build_block_list(theme: Theme) -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "BlockList"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	if theme != null: scroll.theme = theme
	var blocks := VBoxContainer.new()
	blocks.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(blocks)
	for kind: String in XREBlueprintGraph.BLOCKS:
		_button(blocks, XREBlueprintGraph.BLOCKS[kind]["title"], add_block.bind(kind))
	block_list = scroll
	_forms_home.add_child(block_list)


## Bends the graph's windows as the setting [constant XREFeatureSettings.WINDOW_SHAPE] says (D-043).
func _update_window_shape() -> void:
	var concave := _document.features.get_value(XREFeatureSettings.WINDOW_SHAPE) == XREFeatureSettings.CONCAVE
	for window: XREPanelSurface in _windows: window.set_curve_radius(XREPanels.CONCAVE_RADIUS if concave else 0.0)


## Opens the block palette beside card [param id], whose plus was clicked,
## and selects the card without opening its parameters (D-046); open ones
## stay, and the palette goes on their other side.
func _show_block_palette(id: int) -> void:
	cancel_connection()
	select_block(id, false)
	_request_window(XREBlueprintPaletteTab, palette_pose(id))


func _show_keyboard(field: LineEdit) -> void:
	if not is_instance_valid(field) or not _workspace.visible: return
	_keyboard_target = weakref(field)
	var head := _rig.camera.global_position
	var upright := XREPanels.facing(head - _rig.camera.global_basis.z, head, Vector3.UP)
	var point := head - upright.z * 0.65 - Vector3.UP * 0.38
	_keyboard.global_transform = Transform3D(upright * Basis(Vector3.RIGHT, -XREVirtualKeyboard.TILT), point)
	_keyboard.open_text(field.text)


func _apply_keyboard(text: String) -> void:
	var field := _keyboard_target.get_ref() as LineEdit if _keyboard_target != null else null
	if not is_instance_valid(field): return
	field.text = text
	field.text_changed.emit(field.text)
	field.text_submitted.emit(field.text)
	_keyboard_target = null


## XR-only scene veil, [param alpha] opaque. Its far depth separates world
## geometry from logic overlays. The launcher of the panels dims the scene
## with one too ([XREPanels]).
static func create_dimmer(alpha: float = 0.68) -> MeshInstance3D:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_always, cull_disabled, fog_disabled;
void vertex() { POSITION = vec4(VERTEX.xy, 0.0, 1.0); }
uniform float alpha = 0.68;
void fragment() {
	ALBEDO = vec3(0.0);
	ALPHA = alpha;
	// Godot 4.7 uses reverse-Z, including Compatibility: far depth is zero.
	DEPTH = 0.0;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.render_priority = Material.RENDER_PRIORITY_MAX - 2
	material.set_shader_parameter(&"alpha", alpha)
	var quad := QuadMesh.new()
	quad.size = Vector2(2, 2)
	var mesh := XRERig.create_vr_mesh(quad, material)
	mesh.name = "LogicSceneDimmer"
	mesh.position.z = -0.1
	mesh.extra_cull_margin = 10.0
	return mesh


func _set_ui_overlay(enabled: bool) -> void:
	for surface: XREPanelSurface in [_toolbar, _keyboard, _badge]: surface.set_overlay(enabled)
	_rig.left_hand.set_overlay(enabled)
	_rig.right_hand.set_overlay(enabled)


func _rebuild_target_wires() -> void:
	for wire: TargetWire in _target_wires:
		canvas.remove_child(wire.mesh)
		wire.mesh.queue_free()
	_target_wires.clear()
	if not blueprint.scene_context_active(): return
	for block: Dictionary in blueprint.graph.nodes:
		var id: int = block["id"]
		var port := XREBlueprintGraph.target_port(block)
		if port < 0 or blueprint.target_is_connected(id): continue
		var target := blueprint.target_node(id)
		if not is_instance_valid(target): continue
		var anchor := _anchor(target)
		if anchor == null: continue
		var wire := TargetWire.new()
		wire.id = id
		wire.port = port
		wire.target = target
		wire.anchor = anchor
		wire.mesh = canvas.create_scene_wire(XREBlueprintCanvas.COLORS[XREBlueprintGraph.OBJECT])
		_target_wires.append(wire)
	_update_target_wires()


func _update_target_wires() -> void:
	for wire: TargetWire in _target_wires:
		wire.mesh.visible = _workspace.visible and blueprint.scene_context_active() and is_instance_valid(wire.target) and wire.target.is_inside_tree() and is_instance_valid(wire.anchor) and wire.anchor.is_inside_tree()
		if wire.mesh.visible:
			canvas.update_scene_wire(wire.mesh, wire.id, wire.port, canvas.to_local(wire.anchor.global_position))


func _pending_scene_target() -> bool:
	if _pending_id < 0 or not _pending_input: return false
	var block := blueprint.graph.find_node(_pending_id)
	return not block.is_empty() and XREBlueprintGraph.target_port(block) == _pending_port


## A scene endpoint uses the existing target validation, relative path, history and telemetry.
func connect_scene_target(id: int, target: Node) -> bool:
	var block := blueprint.graph.find_node(id)
	if block.is_empty() or XREBlueprintGraph.target_port(block) < 0:
		_message("Choose a block with a Target port.")
		return false
	if not blueprint.scene_context_active():
		_message(blueprint.scene_context_message())
		return false
	if blueprint.target_is_connected(id):
		_message("Disconnect the dynamic Target before choosing a scene object.")
		return false
	var success: bool = blueprint.perform(blueprint.choose_target.bind(id, target), &"vr_graph")
	if success:
		cancel_connection()
		_message("Target connected to scene object.")
	else: _message(blueprint.last_error)
	return success


func _update_scene_target_pointer(hand: XREHand, origin: Vector3, direction: Vector3) -> void:
	if not blueprint.scene_context_active():
		cancel_connection()
		_message(blueprint.scene_context_message())
		return
	hand.claim(self)
	var target: Node
	var distance := 5.0
	var end := origin + direction * distance
	if _icons != null and _icons.cast_segment(origin, end):
		target = _icons.get_hit_node()
		distance = _icons.get_hit_distance()
	elif is_instance_valid(_root) and _picker.cast_segment(_root, origin, end):
		target = _picker.get_hit_node()
		distance = _picker.get_hit_distance()
	hand.show_ray(distance, target != null)
	if _pending_hand == hand: _preview_connection(origin + direction * distance)
	if hand.trigger_pressed and target != null: connect_scene_target(_pending_id, target)
	elif hand.trigger_pressed and _pending_hand == hand:
		cancel_connection()
		_message("Wire cancelled.")
