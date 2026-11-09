@tool
extends Node
## Real-editor regression of spatial input, source persistence and scene assignment history.

var _document: XREDocument
var _service: XREBlueprints
const RayParity := preload("res://scripts/ray_parity.gd")
## The panels, which open the graph's parameters window (D-044).
var _panels: XREPanels
var _rig: XRERig
var _right: XRControllerTracker
var _left: XRControllerTracker
var _checks := 0
var _failures := 0
var _operations: Array[StringName] = []
var _host: Node3D
var _viewport: SubViewport
var _hover_pulses := 0
var _keyboard_clicks := 0
## The editor's node display before the test, put back at the end.
var _saved_display := XREFeatureSettings.ON
## The same for the port display and the window shape (D-043).
var _saved_ports := XREFeatureSettings.FLAT
var _saved_shape := XREFeatureSettings.FLAT
## The same for the parameter settings (D-052), which a headset session leaves as it set them.
var _saved_parameters: Dictionary[StringName, StringName] = {}
## The editor's settings file, kept aside while the checks run.
var _saved_path := ""
const PARAMETER_SETTINGS: Array[StringName] = [XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ANIMATION_WAIT,
		XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.TOKEN_TRAY, XREFeatureSettings.SCENE_CREATE, XREFeatureSettings.CARD_PLUS, XREFeatureSettings.COLOR_INPUT, XREFeatureSettings.AXIS_SCALE,
		XREFeatureSettings.FOCUS, XREFeatureSettings.DEFOCUS, XREFeatureSettings.LINK_PREVIEW, XREFeatureSettings.LINK_WIRES, XREFeatureSettings.LINK_CREATE, XREFeatureSettings.WIRE_BENDS,
		XREFeatureSettings.OBJECT_SHORTCUT, XREFeatureSettings.AUTO_LINK, XREFeatureSettings.BLOCK_PALETTE, XREFeatureSettings.PALETTE_GROUPS, XREFeatureSettings.NEXT_SUGGESTIONS, XREFeatureSettings.BLOCK_COPY,
		XREFeatureSettings.NODE_STYLE, XREFeatureSettings.NODE_SHRINK, XREFeatureSettings.NODE_HEADING, XREFeatureSettings.PORT_SHAPES, XREFeatureSettings.COMPOSITE_VALUES,
		XREFeatureSettings.NODE_VOLUME, XREFeatureSettings.NODE_BACK, XREFeatureSettings.PIN_PLACE, XREFeatureSettings.CARD_MIRROR, XREFeatureSettings.SIGN_PORTS,
		XREFeatureSettings.GRAPH_TURN, XREFeatureSettings.GRAPH_PARTS, XREFeatureSettings.EXEC_ARROWS, XREFeatureSettings.DATA_ARROWS, XREFeatureSettings.ARROW_STYLE,
		XREFeatureSettings.SELECT_ADD, XREFeatureSettings.OBJECT_COPY, XREFeatureSettings.SELECTION_COUNTER, XREFeatureSettings.SELECT_AREA,
		XREFeatureSettings.WIRE_DRAW, XREFeatureSettings.COLLECTION_PORT, XREFeatureSettings.COLLECTION_LITERAL, XREFeatureSettings.COLLECTION_WIRE, XREFeatureSettings.SCENE_COLLECTION]
## The values the checks start from: the defaults before D-076, D-089, D-097, D-114, D-131 and D-133 made the
## author's picks the defaults. Each check switches to the variant it covers.
const BASELINE: Dictionary[StringName, StringName] = {
	XREFeatureSettings.VALUE_INPUT: XREFeatureSettings.WINDOW, XREFeatureSettings.TARGET_INPUT: XREFeatureSettings.WINDOW,
	XREFeatureSettings.ANIMATION_WAIT: XREFeatureSettings.FLAG, XREFeatureSettings.VARIABLE_INPUT: XREFeatureSettings.WINDOW,
	XREFeatureSettings.TOKEN_TRAY: XREFeatureSettings.OFF, XREFeatureSettings.SCENE_CREATE: XREFeatureSettings.OFF,
	XREFeatureSettings.CARD_PLUS: XREFeatureSettings.SHOWN, XREFeatureSettings.COLOR_INPUT: XREFeatureSettings.PICKER,
	XREFeatureSettings.AXIS_SCALE: XREFeatureSettings.AUTO, XREFeatureSettings.FOCUS: XREFeatureSettings.OFF,
	XREFeatureSettings.DEFOCUS: XREFeatureSettings.OFF, XREFeatureSettings.LINK_PREVIEW: XREFeatureSettings.OFF,
	XREFeatureSettings.LINK_WIRES: XREFeatureSettings.OFF, XREFeatureSettings.LINK_CREATE: XREFeatureSettings.WIRE_BUTTON,
	XREFeatureSettings.WIRE_BENDS: XREFeatureSettings.OFF, XREFeatureSettings.OBJECT_SHORTCUT: XREFeatureSettings.OFF,
	XREFeatureSettings.AUTO_LINK: XREFeatureSettings.OFF,
	XREFeatureSettings.BLOCK_PALETTE: XREFeatureSettings.LIST, XREFeatureSettings.PALETTE_GROUPS: XREFeatureSettings.SOURCES,
	XREFeatureSettings.NEXT_SUGGESTIONS: XREFeatureSettings.OFF, XREFeatureSettings.BLOCK_COPY: XREFeatureSettings.OFF,
	# The redesign of the cards (D-099 to D-105) starts from Classic, as the checks before it expect.
	XREFeatureSettings.NODE_STYLE: XREFeatureSettings.CLASSIC, XREFeatureSettings.NODE_SHRINK: XREFeatureSettings.OPERATORS,
	XREFeatureSettings.NODE_HEADING: XREFeatureSettings.OPERATION, XREFeatureSettings.PORT_SHAPES: XREFeatureSettings.OFF,
	XREFeatureSettings.COMPOSITE_VALUES: XREFeatureSettings.WHOLE,
	# The graph from any angle (D-115): its first values, whatever the author picked.
	XREFeatureSettings.NODE_VOLUME: XREFeatureSettings.FLAT, XREFeatureSettings.NODE_BACK: XREFeatureSettings.BLANK,
	XREFeatureSettings.PIN_PLACE: XREFeatureSettings.FACE, XREFeatureSettings.CARD_MIRROR: XREFeatureSettings.OFF,
	XREFeatureSettings.SIGN_PORTS: XREFeatureSettings.SIDES, XREFeatureSettings.GRAPH_TURN: XREFeatureSettings.FIXED,
	XREFeatureSettings.GRAPH_PARTS: XREFeatureSettings.WHOLE, XREFeatureSettings.EXEC_ARROWS: XREFeatureSettings.OFF,
	XREFeatureSettings.DATA_ARROWS: XREFeatureSettings.OFF, XREFeatureSettings.ARROW_STYLE: XREFeatureSettings.FILLED,
	# Selecting and copying several (D-120 to D-125) start from one at a time, as before D-131.
	XREFeatureSettings.SELECT_ADD: XREFeatureSettings.REPLACE, XREFeatureSettings.OBJECT_COPY: XREFeatureSettings.SHORTCUT,
	XREFeatureSettings.SELECTION_COUNTER: XREFeatureSettings.OFF, XREFeatureSettings.SELECT_AREA: XREFeatureSettings.OFF,
	# A wire is drawn by clicks, as the checks before D-135 expect.
	XREFeatureSettings.WIRE_DRAW: XREFeatureSettings.CLICK,
	# Collections (D-143): their first values.
	XREFeatureSettings.COLLECTION_PORT: XREFeatureSettings.GRID, XREFeatureSettings.COLLECTION_LITERAL: XREFeatureSettings.MAKE,
	XREFeatureSettings.COLLECTION_WIRE: XREFeatureSettings.OFF, XREFeatureSettings.SCENE_COLLECTION: XREFeatureSettings.OFF,
}


func _init(document: XREDocument) -> void:
	_document = document


func _ready() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("test_blueprint_vr: FAILED " + message)


func _frames(count: int = 3) -> void:
	for frame: int in count: await get_tree().process_frame


func _aim(point: Vector3) -> void:
	_right.set_pose(&"aim", Transform3D(Basis.IDENTITY, point + Vector3(0, 0, 0.4)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)


func _click(point: Vector3) -> void:
	_aim(point)
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()


## A ray's pose, in the rig, at [param pixel] of [param surface], from 0.3 m in front of it.
func _pose_at(surface: XREPanelSurface, pixel: Vector2) -> Transform3D:
	var target := surface.pixel_to_global(pixel)
	var origin := target + surface.global_basis.z.normalized() * 0.3
	return _rig.global_transform.affine_inverse() * Transform3D(Basis.looking_at(target - origin), origin)


## A trigger click by the right ray on [param pixel] of [param surface].
func _click_at(surface: XREPanelSurface, pixel: Vector2) -> void:
	_right.set_pose(&"aim", _pose_at(surface, pixel), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()


## The center of [param control] in its panel's interface pixels.
static func _pixel_of(control: Control) -> Vector2:
	return control.get_global_rect().get_center()


func _run() -> void:
	for frame: int in 600:
		await get_tree().process_frame
		if _document.get_scene_root() != null and not EditorInterface.get_resource_filesystem().is_scanning(): break
	var scene := _document.get_scene_root()
	_check(scene != null, "editor scene is available")
	if scene == null:
		get_tree().quit(1)
		return
	# The checks switch settings in memory only: the editor's saved file is never
	# written, so a run that stops halfway leaves the author's settings as they are.
	_saved_path = _document.features.path
	_document.features.path = ""
	# The editor's variant is put back at the end; the checks expect the default billboards.
	_saved_display = _document.features.get_value(XREFeatureSettings.NODE_FACING)
	_document.features.set_value(XREFeatureSettings.NODE_FACING, XREFeatureSettings.ON)
	_saved_ports = _document.features.get_value(XREFeatureSettings.PORT_DISPLAY)
	_document.features.set_value(XREFeatureSettings.PORT_DISPLAY, XREFeatureSettings.FLAT)
	_saved_shape = _document.features.get_value(XREFeatureSettings.WINDOW_SHAPE)
	_document.features.set_value(XREFeatureSettings.WINDOW_SHAPE, XREFeatureSettings.FLAT)
	for key: StringName in PARAMETER_SETTINGS:
		_saved_parameters[key] = _document.features.get_value(key)
		_document.features.set_value(key, BASELINE[key])
	DirAccess.make_dir_recursive_absolute("res://build/blueprint_vr_tests")
	_right = XRControllerTracker.new()
	_right.name = &"right_hand"
	_right.type = XRServer.TRACKER_CONTROLLER
	_left = XRControllerTracker.new()
	_left.name = &"left_hand"
	_left.type = XRServer.TRACKER_CONTROLLER
	XRServer.add_tracker(_right)
	XRServer.add_tracker(_left)
	_left.set_pose(&"aim", Transform3D(Basis.IDENTITY, Vector3(-5, 0, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_rig = XRERig.new()
	_viewport = SubViewport.new()
	_viewport.world_3d = (scene as Node3D).get_world_3d()
	_viewport.add_child(_rig)
	add_child(_viewport)
	_rig.camera.position = Vector3(0, 1.4, 0)
	var icons := XREIcons.new(_document, _rig)
	_rig.add_child(icons)
	# In the plugin's order: the palette and the panels before the graph.
	var palette := XREPalette.new(_document, _rig)
	_rig.add_child(palette)
	_panels = XREPanels.new(_document, _rig, palette, EditorInterface.get_editor_theme(), 1.0)
	_rig.add_child(_panels)
	_service = XREBlueprints.new(_document, _rig, icons, EditorInterface.get_editor_theme())
	_service.source_folder = "res://build/blueprint_vr_tests"
	_rig.add_child(_service)
	_panels.set_blueprints(_service)
	var manipulator := XREManipulator.new(_document, _rig, icons)
	manipulator.graph_open = _service.is_open
	_rig.add_child(manipulator)
	_document.operation_recorded.connect(_record)
	_host = Node3D.new()
	_host.name = "BlueprintVRFixture"
	_document.add_node(_host, scene, XREDocument.Source.PANEL)
	_document.select([_host], XREDocument.Source.TOOL)
	await _frames()
	_check((_service.get("_picker") as XREPicker).scenario == _viewport.world_3d.scenario, "target picker uses the edited scene's shared scenario")
	await _test_badge()
	_check(_service.create_for(_host), "create Blueprint from a scene object")
	await _frames()
	var path := _service.blueprint.path
	_check(FileAccess.file_exists(path), "source is persisted beside configured scene folder")
	_check(_host.get_meta(&"_xre_blueprint", "") == path, "host identifies its graph before compilation")
	_check(_host.get_script() == null, "draft does not execute in the editor")
	_check(_service.related_host(_host) == _host, "scene open resolves the explicit host")
	_check(_service.is_open(), "creation opens spatial workspace")
	await _test_workspace()
	await _test_node_display()
	await _test_node_style()
	await _test_composite_values()
	await _test_window_corners()
	var badge := _service.get("_badge") as XREBlueprintBadge
	await _test_badge_graph(badge, path)
	# The badge's title, off its buttons (D-085).
	var title_pose := _pose_at(badge, Vector2(110, badge.size_px.y * 0.5))
	_right.set_pose(&"aim", title_pose, Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_left.set_pose(&"aim", title_pose, Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(badge.is_pressed(), "one hand owns the panel mouse while pressed")
	_left.set_pose(&"aim", Transform3D(Basis.IDENTITY, Vector3(-5, 0, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_check(badge.is_pressed(), "idle second hand leaving does not release the owner's button")
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(not badge.is_pressed(), "owner releases its own panel mouse")
	_check(_service.is_open(), "a click on the badge's title closes nothing")
	await _test_surface_occlusion(badge)
	for child: Node in EditorInterface.get_editor_main_screen().get_children():
		if child is XREBlueprintEditor: _check((child as XREBlueprintEditor).document == _service.blueprint, "desktop and VR share one document")
	_service.add_block("print")
	await _frames()
	var print_id: int = _service.blueprint.graph.nodes.back()["id"]
	_check(_service.blueprint.graph.nodes.size() == 2, "spatial palette changes shared graph")
	var source := _service.canvas.to_global(_service.canvas.port_position(1, 0, false))
	var target := _service.canvas.to_global(_service.canvas.port_position(print_id, 0, true))
	_check(_service.canvas.intersect_ray(source + Vector3.BACK * 0.4, Vector3.FORWARD, 1) >= 0, "analytic ray reaches a spatial port")
	_check(_service.canvas.get_hit_id() == 1 and _service.canvas.get_hit_port() == 0 and not _service.canvas.get_hit_input(), "ray identifies endpoint and direction")
	await _click(source)
	_check(_service.get("_pending_hand") == _rig.right_hand, "starting trigger owns the wire preview")
	_aim(target)
	_left.set_pose(&"aim", Transform3D(Basis.IDENTITY, source + Vector3.BACK * 0.4), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	var preview := _service.canvas.get("_preview") as XREGraphWire
	_check(preview.get_point(preview.get_point_count() - 1).is_equal_approx(_service.canvas.port_position(print_id, 0, true)), "idle left ray cannot overwrite the right wire endpoint")
	await _click(target)
	_check(_service.get("_pending_hand") == null and not preview.visible, "successful connection clears owner and preview")
	_left.set_pose(&"aim", Transform3D(Basis.IDENTITY, Vector3(-5, 0, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_check(_service.blueprint.graph.edges.size() == 1, "two trigger presses create a typed wire")
	var wire := (_service.canvas.get("_wires") as Array)[0] as XREBlueprintCanvas.Wire
	_check(wire.mesh.get_point(0).is_equal_approx(_service.canvas.port_position(1, 0, false)), "curved wire starts at the output terminal")
	_check(wire.mesh.get_point(wire.mesh.get_point_count() - 1).is_equal_approx(_service.canvas.port_position(print_id, 0, true)), "curved wire ends at the input terminal")
	_check(&"connect_ports" in _operations, "spatial connection enters common telemetry")
	_service.blueprint.undo()
	await _frames()
	_check(_service.blueprint.graph.edges.is_empty(), "graph undo removes connection")
	_service.blueprint.redo()
	await _frames()
	_check(_service.blueprint.graph.edges.size() == 1, "graph redo restores spatial connection")
	await _click(_service.canvas.to_global(_service.canvas.port_position(print_id, 0, true)))
	_check(_service.blueprint.graph.edges.is_empty(), "clicking a connected port detaches the wire from it")
	_check(_service.get("_pending_id") == print_id and _service.get("_pending_port") == 0 and _service.get("_pending_input")
			and _service.get("_pending_hand") == _rig.right_hand and preview.visible,
			"the wire stays on the clicked port and its other end follows the ray (D-058)")
	_service.cancel_connection()
	_service.blueprint.undo()
	await _frames()
	var before := _service.canvas.get_block_position(print_id)
	var history_version := _service.blueprint.history.get_version()
	var body := _service.canvas.to_global(before + Vector3(0, 0.025, 0))
	_aim(body)
	_right.set_input(&"grip", 1.0)
	await _frames()
	_aim(body + Vector3(0.08, 0.03, 0.06))
	await _frames()
	var preview_depth := _service.canvas.get_block_position(print_id).z
	_check(_service.blueprint.history.get_version() == history_version, "grip preview does not create history entries")
	var card_node := _service.canvas.get_node_or_null("Block%d" % print_id)
	var details := (_service.parameters.get("_details") as Node).get_child(0)
	_right.set_input(&"grip", 0.0)
	await _frames()
	_check(card_node != null and _service.canvas.get_node_or_null("Block%d" % print_id) == card_node, "releasing a moved card keeps the canvas instead of rebuilding it")
	_check(is_instance_valid(details) and details.get_parent() == _service.parameters.get("_details"), "releasing a moved card keeps the parameter form")
	_check(_service.blueprint.history.get_version() == history_version + 1, "grip release commits exactly one graph edit")
	_check(absf(float(_service.blueprint.graph.find_node(print_id).get("vr_depth", 0)) - preview_depth) < 0.001, "previewed ray-constrained depth is persisted")
	_service.blueprint.undo()
	await _frames()
	_check(_service.canvas.get_block_position(print_id).is_equal_approx(before), "undo restores spatial card placement")
	_check(_service.canvas.get_node_or_null("Block%d" % print_id) == card_node, "undoing a move only repositions the existing card")
	await _test_card_rotation(print_id)
	await _test_depth_pull(print_id)
	await _test_depth_direction(print_id)
	await _test_depth_lap(print_id)
	await _test_keyboard()
	await _test_windows_and_ports(print_id)
	_service.add_block("branch")
	await _frames()
	var branch_id: int = _service.blueprint.graph.nodes.back()["id"]
	_check(_service.click_port(print_id, 0, false), "start execution wire")
	_check(not _service.click_port(branch_id, 1, true), "execution cannot connect to a bool input")
	_service.cancel_connection()
	_check(_service.get("_pending_port") == -1 and _service.get("_pending_hand") == null and not preview.visible, "explicit cancellation clears all connection state")
	_check(_service.blueprint.graph.edges.size() == 1, "rejected wire leaves program unchanged")
	_check(_service.click_port(print_id, 0, false) and _service.click_port(branch_id, 0, true), "VR ports create the forward branch connection")
	await _frames()
	_check(_service.click_port(branch_id, 0, false) and _service.click_port(print_id, 0, true), "VR ports accept a back edge into an already connected execution input")
	await _frames()
	_check(_service.blueprint.graph.edges.size() == 3 and _service.blueprint.graph.validate().is_empty(), "spatial cycle shares the valid desktop document")
	var loop_wire := (_service.canvas.get("_wires") as Array)[2] as XREBlueprintCanvas.Wire
	_check(loop_wire.mesh.visible and loop_wire.mesh.get_point(0).is_equal_approx(_service.canvas.port_position(branch_id, 0, false)), "back edge remains visibly attached to round ports")
	_service.blueprint.undo()
	await _frames()
	_check(_service.blueprint.graph.edges.size() == 2, "one undo removes only the spatial back edge")
	_service.blueprint.redo()
	await _frames()
	_check(_service.blueprint.graph.edges.size() == 3, "redo restores the spatial execution loop")
	var delete_before := _service.blueprint.graph.snapshot()
	var delete_version := _service.blueprint.history.get_version()
	for card: XREBlueprintCanvas.Card in _service.canvas.get("_cards") as Array:
		if card.id == branch_id:
			await _click(card.node.to_global(card.trash_point))
			break
	_check(_service.blueprint.graph.find_node(branch_id).is_empty() and _service.blueprint.graph.edges.size() == 1, "trash trigger removes its node and both incident execution wires")
	_check(_service.blueprint.history.get_version() == delete_version + 1, "trash deletion is one graph history edit")
	_service.blueprint.undo()
	await _frames()
	_check(_service.blueprint.graph.snapshot() == delete_before, "trash undo restores the node, parameters and back edge")
	_service.blueprint.redo()
	await _frames()
	_check(_service.blueprint.graph.find_node(branch_id).is_empty(), "trash deletion can be redone")
	_service.blueprint.undo()
	await _frames()
	_service.select_block(branch_id)
	_aim(Vector3(5, 4, -2))
	_left.set_input(&"ax_button", true)
	await _frames()
	_left.set_input(&"ax_button", false)
	await _frames()
	_check(_service.blueprint.graph.find_node(branch_id).is_empty(), "X deletes the selected graph block")
	_check(_rig.right_hand.is_free_for(self), "released graph input returns hand ownership")
	_check(is_instance_valid(_host) and _host.is_inside_tree(), "graph deletion preserves the scene host")
	_service.select_block(print_id)
	_check(_service.build_and_attach(), "build and assign generated runtime script")
	_check(_host.get_script() != null, "scene host receives compiled script")
	var valid_script := _host.get_script() as Script
	_service.add_block("set_property")
	await _frames()
	var invalid_id: int = _service.blueprint.graph.nodes.back()["id"]
	_service.parameters.call("_set_parameter", invalid_id, "target", "MissingObject")
	await _frames()
	_check(not _service.prepare_play(), "invalid visible Target blocks play preparation")
	_check(_host.get_script() == valid_script, "failed build keeps the last compiled artifact intact")
	_service.delete_block()
	await _frames()
	await _test_target()
	await _test_left_wire(print_id)
	await _test_block_menu()
	await _test_d093()
	await _test_d117()
	await _test_d119()
	await _test_d120()
	await _test_d121()
	await _test_d122()
	await _test_d123()
	await _test_d125()
	await _test_d135()
	await _test_d137()
	await _test_functions()
	await _test_d142()
	await _test_d143()
	await _test_parameters_in_graph()
	await _test_token_input()
	await _test_target_modes()
	await _test_widgets_and_wires()
	await _test_vector_widget()
	await _test_links_and_focus()
	await _test_number_inputs()
	await _test_d063()
	await _test_d064()
	await _test_d065()
	await _test_d066()
	await _test_d068()
	await _test_d069()
	await _test_d072()
	await _test_d074()
	await _test_d078()
	await _test_wire_bends()
	await _test_d090()
	await _test_history(print_id)
	_check(_service.blueprint.operation_source == &"desktop_graph", "VR command source scope is restored")
	_service.parameters.call("_set_parameter", print_id, "value", "VR test")
	await _frames()
	_check(_service.blueprint.graph.find_node(print_id)["params"]["value"] == "VR test", "existing typed parameter UI edits shared model")
	var workspace := _service.get("_workspace") as Node3D
	var pinned_pose := workspace.global_transform
	var pinned_center := _service.canvas.get_graph_center()
	var pinned_cards: Dictionary[int, Vector3] = {}
	for card: XREBlueprintCanvas.Card in _service.canvas.get("_cards") as Array: pinned_cards[card.id] = card.node.global_position
	# A pipette taken in the Color window goes back with the graph (D-065).
	_service.call("_open_color", print_id, "value", "", Color.RED)
	_service.color_panel.get_pipette_button().toggled.emit(true)
	var pipette_taken := not _rig.right_controller.is_model_shown()
	_service.close_graph()
	_check(not _service.is_open(), "Back to scene closes only spatial view")
	await _frames(2)
	_check(pipette_taken and _rig.right_controller.is_model_shown() and _service.get("_pipette_hand") == null and _panels.find_window(XREBlueprintColorTab) == null, "a pipette in the hand goes back with the graph, the Color window closed")
	_check(_host.get_script() != null and FileAccess.file_exists(path), "closing retains behavior and source")
	var saved := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as XREBlueprintGraph
	_check(saved.find_node(print_id)["params"]["value"] == "VR test", "closing persists the draft")
	_check(saved.vr_placed and saved.vr_workspace.is_equal_approx(pinned_pose) and saved.vr_center.is_equal_approx(pinned_center), "saved graph retains its workspace pose and stable XY center")
	var rig_before_reopen := _rig.transform
	_rig.transform = Transform3D(Basis(Vector3.UP, 0.7), Vector3(2.2, 0.4, -1.5))
	_check(_service.open_graph(path), "catalog can reopen the same graph")
	await _frames()
	_check(workspace.global_transform.is_equal_approx(pinned_pose), "reopening from another scene point does not reposition the graph")
	for card: XREBlueprintCanvas.Card in _service.canvas.get("_cards") as Array:
		_check(card.node.global_position.is_equal_approx(pinned_cards[card.id]), "changed graph bounds and opening viewpoint cannot shift a saved card center")
	_check((_service.get("_floating_ui") as Node3D).global_position.distance_to(_rig.camera.global_position) < 1.5, "reopened graph leaves its UI near the current user")
	_rig.transform = rig_before_reopen
	await _frames()
	_service.refresh_catalog()
	_check(XREBlueprints.source_path(_host) == path, "source lookup survives closing and reopening")
	var plugin := (_document as XREPluginDocument).get("_plugin") as EditorPlugin
	var manager := plugin.get_undo_redo()
	var history := manager.get_history_undo_redo(manager.get_object_history_id(_host))
	_check(_service.detach_selected(), "detach through scene document")
	_check(_host.get_script() == null and not _host.has_meta(&"_xre_blueprint"), "detach removes assignment and source link")
	_check(FileAccess.file_exists(path), "detach retains graph file")
	history.undo()
	_check(_host.get_script() != null and XREBlueprints.source_path(_host) == path, "scene undo restores script and source link together")
	history.redo()
	_check(_host.get_script() == null, "scene redo removes behavior")
	var handwritten := GDScript.new()
	handwritten.source_code = "extends Node3D\n"
	handwritten.reload()
	ResourceSaver.save(handwritten, "res://build/blueprint_vr_tests/protected.gd")
	handwritten = ResourceLoader.load("res://build/blueprint_vr_tests/protected.gd", "GDScript", ResourceLoader.CACHE_MODE_REPLACE) as GDScript
	_host.set_script(handwritten)
	_check(not _document.assign_blueprint(_host, path, null, XREDocument.Source.PANEL), "unrelated script is protected")
	_check(_host.get_script() == handwritten, "unrelated script remains intact")
	_check(_service.create_unassigned(), "catalog creates a graph without scene assignment")
	await _frames()
	_check(_service.blueprint.get_host() == null, "unassigned graph has no implicit root host")
	_check(not _service.build_and_attach(), "unassigned graph requires explicit host choice")
	var snapshot := _service.blueprint.graph.snapshot()
	_document.open_scene("res://benchmarks/blueprint_door.tscn", XREDocument.Source.PANEL)
	await _frames(12)
	_check(_service.blueprint.graph.snapshot() == snapshot, "scene switch does not retarget a spatial graph")
	_check(not _service.blueprint.scene_context_active(), "another scene suspends target reflection")
	_check(_service.get("_target_pick") == -1 and _service.get("_pending_hand") == null, "scene switch clears pending target and connection ownership")
	_document.open_scene("res://benchmarks/play_check.tscn", XREDocument.Source.PANEL)
	await _frames(12)
	_check(_service.blueprint.scene_context_active(), "return restores the graph's scene context")
	var graph := XREBlueprintGraph.new()
	graph.restore(_service.blueprint.graph.snapshot())
	graph.nodes[0]["vr_depth"] = NAN
	_check(not graph.validate().is_empty(), "non-finite spatial metadata is rejected")
	graph.nodes[0]["vr_depth"] = 0.0
	graph.nodes[0]["vr_rotation"] = Vector3(NAN, 0, 0)
	_check(not graph.validate().is_empty(), "non-finite card orientation is rejected")
	_document.select([], XREDocument.Source.TOOL)
	EditorInterface.inspect_object(null)
	_service.close_graph()
	_service.queue_free()
	await _frames()
	_check(not _document.prepare_play.is_valid(), "plugin teardown releases play guard")
	_document.operation_recorded.disconnect(_record)
	XRServer.remove_tracker(_right)
	XRServer.remove_tracker(_left)
	_rig.queue_free()
	_viewport.queue_free()
	await _frames()
	_document.features.set_value(XREFeatureSettings.NODE_FACING, _saved_display)
	_document.features.set_value(XREFeatureSettings.PORT_DISPLAY, _saved_ports)
	_document.features.set_value(XREFeatureSettings.WINDOW_SHAPE, _saved_shape)
	for key: StringName in PARAMETER_SETTINGS: _document.features.set_value(key, _saved_parameters[key])
	_document.features.path = _saved_path
	print("test_blueprint_vr: %d of %d checks failed" % [_failures, _checks])
	get_tree().quit(1 if _failures > 0 else 0)


func _record(operation: StringName, _source: XREDocument.Source, _nodes: Array[Node], _time_usec: int) -> void:
	_operations.append(operation)


## D-087: what is done in the graph is a step of the headset's history — an
## edit, a menu or an input opened, the graph closed — that undo puts back and
## redo makes again. An input that closed by itself leaves only its value to undo.
func _test_history(print_id: int) -> void:
	var history := _document.history
	var graph := _service.blueprint.graph
	var keyboard := _service.get("_keyboard") as XREVirtualKeyboard
	_service.call("_close_inputs")
	_service.close_block_palette()
	_service.close_parameters()
	await _frames()
	history.clear()
	var before: Variant = graph.find_node(print_id)["params"]["value"]
	_service.blueprint.perform(_service.blueprint.set_parameter.bind(print_id, "value", "Undo me"), &"vr_graph")
	_check(history.get_undo_name() == "Set Value", "an edit of the graph in the headset is a step: %s" % history.get_undo_name())
	await _frames()
	_operations.clear()
	_check(_document.undo(XREDocument.Source.TOOL) and graph.find_node(print_id)["params"]["value"] == before, "undo puts the edit back through the graph's history")
	_check(_document.redo(XREDocument.Source.TOOL) and graph.find_node(print_id)["params"]["value"] == "Undo me", "redo makes it again")
	_check(_operations == [&"undo", &"redo"], "each is one operation, none of the graph's own: %s" % [_operations])
	_service.undo()
	_check(graph.find_node(print_id)["params"]["value"] == before and _operations.back() == &"undo", "the Blueprints tab's Undo is the headset's undo")
	_document.redo(XREDocument.Source.TOOL)
	await _frames()
	# On the desktop, the graph's history goes on past the headset's.
	_service.blueprint.perform(_service.blueprint.set_parameter.bind(print_id, "value", "Desktop"), &"desktop_graph")
	_check(not history.can_undo(), "an edit on the desktop leaves the headset nothing of the graph to undo")
	_service.blueprint.undo()
	_service.blueprint.undo()
	await _frames()
	_check(graph.find_node(print_id)["params"]["value"] == before, "the desktop's undo puts it all back")
	# A menu opened is a step: undo closes it, redo opens it again.
	history.clear()
	_service.open_block_menu()
	await _frames()
	_check(_service.is_block_palette_shown() and history.get_undo_name() == "Block menu", "the block menu opened is a step: %s" % history.get_undo_name())
	_check(_document.undo(XREDocument.Source.TOOL) and not _service.is_block_palette_shown() and _panels.find_window(XREBlueprintPaletteTab) == null, "undo closes it")
	_check(_document.redo(XREDocument.Source.TOOL) and _service.is_block_palette_shown() and _panels.find_window(XREBlueprintPaletteTab) != null, "redo opens it again")
	await _frames()
	_check(history.get_step_count() == 1, "what undo and redo opened and closed is no step of its own: %d" % history.get_step_count())
	_service.close_block_palette()
	await _frames()
	_check(not _document.undo(XREDocument.Source.TOOL) and not _service.is_block_palette_shown(), "closed meanwhile, the menu is no step left to undo")
	# Nothing is recorded in the frame of an undo.
	await _frames()
	# A token's keyboard: undo closes it, its draft not kept; a value typed
	# closes it, and undo puts back the value, the keyboard staying closed.
	history.clear()
	_service.call("_open_token_keyboard", print_id, "value", "", before)
	await _frames()
	_check(keyboard.is_shown() and history.get_undo_name() == "Keyboard", "a token's keyboard opened is a step: %s" % history.get_undo_name())
	keyboard.value.text = "typed"
	_check(_document.undo(XREDocument.Source.TOOL) and not keyboard.is_shown() and graph.find_node(print_id)["params"]["value"] == before,
			"undo closes the keyboard, its draft not typed")
	_check(_document.redo(XREDocument.Source.TOOL) and keyboard.is_shown(), "redo opens it again")
	await _frames()
	keyboard.value.text = "typed"
	keyboard.call("_apply")
	await _frames()
	_check(not keyboard.is_shown() and graph.find_node(print_id)["params"]["value"] == "typed", "the value typed is kept, the keyboard closed")
	_check(_document.undo(XREDocument.Source.TOOL) and graph.find_node(print_id)["params"]["value"] == before and not keyboard.is_shown(),
			"undo puts back the value; the keyboard stays closed")
	_check(not _document.undo(XREDocument.Source.TOOL), "the keyboard closed by itself is no step left")
	_check(_document.redo(XREDocument.Source.TOOL) and graph.find_node(print_id)["params"]["value"] == "typed", "redo types the value again")
	await _frames()
	_service.blueprint.perform(_service.blueprint.set_parameter.bind(print_id, "value", before), &"vr_graph")
	# Back to scene is a step: undo opens the graph again.
	history.clear()
	await _frames()
	_service.close_graph()
	await _frames()
	_check(not _service.is_open() and history.get_undo_name() == "Back to scene", "Back to scene is a step: %s" % history.get_undo_name())
	_check(_document.undo(XREDocument.Source.TOOL) and _service.is_open(), "undo opens the graph again")
	_check(_document.redo(XREDocument.Source.TOOL) and not _service.is_open(), "redo goes back to the scene")
	_check(_document.undo(XREDocument.Source.TOOL) and _service.is_open(), "and undo opens it once more")
	await _frames()
	history.clear()


## Switching Node volume and Node facing (D-115, after D-039's Node display)
## redraws the open graph at once, and back.
func _test_node_display() -> void:
	var count := (_service.canvas.get("_cards") as Array).size()
	_check(_document.set_feature(XREFeatureSettings.NODE_VOLUME, XREFeatureSettings.SOLID, XREDocument.Source.PANEL), "Node volume switches to 3D")
	_check(_operations.back() == &"set_feature", "the switch enters common telemetry")
	_check(_document.set_feature(XREFeatureSettings.NODE_FACING, XREFeatureSettings.OFF, XREDocument.Source.PANEL), "Node facing switches off")
	await _frames()
	var cards := _service.canvas.get("_cards") as Array
	_check(_service.canvas.get_node_modes().slice(0, 2) == [XREFeatureSettings.OFF, true] and cards.size() == count, "the open graph is redrawn with the same cards")
	_check((cards[0] as XREBlueprintCanvas.Card).mesh.mesh is BoxMesh, "open cards become solid")
	_check((cards[0] as XREBlueprintCanvas.Card).node.basis.is_equal_approx(Basis.IDENTITY), "cards that don't face the head keep the graph's orientation in the headset")
	_check(_document.set_feature(XREFeatureSettings.NODE_FACING, XREFeatureSettings.ON, XREDocument.Source.PANEL)
			and _document.set_feature(XREFeatureSettings.NODE_VOLUME, XREFeatureSettings.FLAT, XREDocument.Source.PANEL), "Node facing and Node volume switch back")
	await _frames()
	cards = _service.canvas.get("_cards") as Array
	_check((cards[0] as XREBlueprintCanvas.Card).mesh.mesh is QuadMesh, "open cards are flat and turn to the head again")
	await _test_pointer_once()
	await _test_view_variants()


## The panels ask takes_pointer for each hand before the service's frame (D-158): one facing of the cards for one head
## in a frame, what it asks of them timed, and rays around a graph as it stands say the same with and without the reach.
func _test_pointer_once() -> void:
	var canvas := _service.canvas
	var hand := _rig.right_hand
	await _frames(2)
	_service.take_process_times()
	var head := _rig.camera.global_position
	var origin := head + Vector3(5, 5, 5)
	_service.takes_pointer(hand, origin, Vector3.UP, 5.0)
	# Not facing the head now, the canvas would again if asked: no second call in the frame asks.
	canvas.set("_faces_user", false)
	_service.takes_pointer(hand, origin, Vector3.UP, 5.0)
	_check(not canvas.get("_faces_user"), "the other hand's call in the frame doesn't face the cards again")
	var camera_was := _rig.camera.global_position
	_rig.camera.global_position = camera_was + Vector3(0, 0.3, 0)
	_service.takes_pointer(hand, origin, Vector3.UP, 5.0)
	_check(canvas.get("_faces_user"), "a head moved within the frame does")
	_rig.camera.global_position = camera_was
	var times := _service.take_process_times()
	_check(times.z > 0.0, "the panels' calls are timed: %s" % times)
	_check(_service.take_process_times() == Vector3.ZERO, "and said once")
	await _frames(3)
	times = _service.take_process_times()
	_check(times.x > 0.0, "the service's frame is timed: %s" % times)
	var difference: String = RayParity.first_difference(canvas)
	_check(difference.is_empty(), "the reach changes a ray on the open graph: %s" % difference)


## Graph turn and wire arrows in the headset (D-115): seen from behind a
## flipping graph turns round, but not while a wire is drawn; On aim, a ray
## coming onto it turns it to the head; arrows switch without a rebuild.
func _test_view_variants() -> void:
	var canvas := _service.canvas
	var workspace := canvas.get_parent() as Node3D
	var saved := workspace.global_transform
	var id := ((canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card).id
	# Seen from behind: the graph's front turned away from the head.
	workspace.global_basis = Basis(Vector3.UP, PI) * saved.basis
	_service.set("_pending_id", id)
	_check(_service.call("_holds_graph"), "a wire being drawn holds the graph still")
	_service.set("_pending_id", -1)
	_check(_document.set_feature(XREFeatureSettings.GRAPH_TURN, XREFeatureSettings.FLIP, XREDocument.Source.PANEL), "Graph turn switches to Flip")
	await _frames(40)
	_check(is_equal_approx(absf(canvas.get_part_turn(id)), PI), "seen from behind, it turns round: %f" % canvas.get_part_turn(id))
	_check(_document.set_feature(XREFeatureSettings.GRAPH_TURN, XREFeatureSettings.AIM, XREDocument.Source.PANEL), "Graph turn switches to On aim")
	workspace.global_basis = Basis(Vector3.UP, PI * 0.6) * saved.basis
	# The switch rebuilt the cards.
	var card := (canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	_aim(card.node.global_position + Vector3(4, 4, 0))
	await _frames(40)
	_check(is_zero_approx(canvas.get_part_turn(id)), "On aim, it stays while no ray is on it")
	_aim(card.node.global_position)
	# The turn eases in; editor frames are short.
	var head := Vector3.ZERO
	for frame: int in 400:
		await get_tree().process_frame
		head = Basis(Vector3.UP, canvas.get_part_turn(card.id)) * canvas.to_local(_rig.camera.global_position)
		if absf(angle_difference(canvas.get_part_turn(card.id), atan2(head.x, head.z))) < 0.005: break
	_check(absf(angle_difference(canvas.get_part_turn(card.id), atan2(head.x, head.z))) < 0.01 and absf(canvas.get_part_turn(card.id)) > 1.0,
			"a ray coming onto it turns it to the head: %f, the head at %f" % [canvas.get_part_turn(card.id), atan2(head.x, head.z)])
	_aim(card.node.global_position + Vector3(4, 4, 0))
	_check(_document.set_feature(XREFeatureSettings.GRAPH_TURN, XREFeatureSettings.FIXED, XREDocument.Source.PANEL), "Graph turn back to Fixed")
	workspace.global_transform = saved
	await _frames(40)
	_check(canvas.basis.is_equal_approx(Basis.IDENTITY), "Fixed puts the graph back")
	card = (canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	_check(_document.set_feature(XREFeatureSettings.DATA_ARROWS, XREFeatureSettings.CHEVRONS, XREDocument.Source.PANEL)
			and _document.set_feature(XREFeatureSettings.EXEC_ARROWS, XREFeatureSettings.RUNNING, XREDocument.Source.PANEL), "arrows switch on")
	await _frames()
	# This graph has no wires: the picking test lays arrows on them; here the modes reach the canvas.
	_check(canvas.get("_exec_arrows") == XREFeatureSettings.RUNNING and canvas.get("_data_arrows") == XREFeatureSettings.CHEVRONS
			and (canvas.get("_cards") as Array)[0] == card, "the canvas takes the arrows' modes, with no rebuild")
	_check(_document.set_feature(XREFeatureSettings.DATA_ARROWS, XREFeatureSettings.OFF, XREDocument.Source.PANEL)
			and _document.set_feature(XREFeatureSettings.EXEC_ARROWS, XREFeatureSettings.OFF, XREDocument.Source.PANEL), "arrows switch off")
	await _frames()
	_check(not (canvas.get("_arrows_filled") as MultiMeshInstance3D).visible, "and none are drawn")
	# A card that doesn't face the head turns on the stick while gripped: right clockwise, seen from above.
	_check(_document.set_feature(XREFeatureSettings.NODE_FACING, XREFeatureSettings.OFF, XREDocument.Source.PANEL), "Node facing switches off")
	await _frames()
	card = (canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	var version := _service.blueprint.history.get_version()
	var rig_basis := _rig.global_basis
	_aim(card.node.global_position)
	_right.set_input(&"grip", 1.0)
	await _frames()
	# Taken, it turns to the head: the stick and the wrist turn it from there.
	var to_head := canvas.to_local(_rig.camera.global_position) - card.node.position
	var faced := card.yaw
	_check(absf(angle_difference(faced, atan2(to_head.x, to_head.z))) <= deg_to_rad(10.0), "a taken card turns to the head: %f, the head at %f" % [faced, atan2(to_head.x, to_head.z)])
	_right.set_input(&"primary", Vector2(1, 0))
	# Frames come as fast as they can here: wait for a step of the stick's turn.
	for frame: int in 600:
		await get_tree().process_frame
		if angle_difference(faced, card.yaw) < -0.1: break
	_right.set_input(&"primary", Vector2.ZERO)
	_check(angle_difference(faced, card.yaw) < -0.1 and _rig.global_basis.is_equal_approx(rig_basis), "the stick turns the held card clockwise, not the rig: %f from %f" % [card.yaw, faced])
	_right.set_input(&"grip", 0.0)
	await _frames()
	var turned: Variant = _service.blueprint.graph.find_node(card.id).get("vr_rotation")
	_check(turned is Vector3 and absf(angle_difference(faced, (turned as Vector3).y)) > 0.1 and _service.blueprint.history.get_version() == version + 1, "letting go saves the turn as one edit")
	_service.blueprint.undo()
	await _frames()
	_check(not _service.blueprint.graph.find_node(card.id).has("vr_rotation"), "undo takes the turn back")
	# The wrist rolled clockwise as the user sees it (the window's Ctrl+wheel down) turns it clockwise too.
	card = (canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	var at := card.node.global_position
	_aim(at)
	_right.set_input(&"grip", 1.0)
	await _frames()
	faced = card.yaw
	_right.set_pose(&"aim", Transform3D(Basis(Vector3.BACK, deg_to_rad(-15.0)), at + Vector3(0, 0, 0.4)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_check(is_equal_approx(angle_difference(faced, card.yaw), deg_to_rad(-15.0)), "a roll of 15° turns the held card a step: %f from %f" % [rad_to_deg(card.yaw), rad_to_deg(faced)])
	_right.set_input(&"grip", 0.0)
	await _frames()
	_service.blueprint.undo()
	await _frames()
	_check(_document.set_feature(XREFeatureSettings.NODE_FACING, XREFeatureSettings.ON, XREDocument.Source.PANEL), "Node facing back on")
	await _frames()


## Archetypes (D-099): a header in the group's color with its icon — signals,
## Set, flow —, none on a pure function, framed in its result's color, and no
## id in the title; the trash shows only in focus, and X deletes the card under
## the ray, not the selected one. Back to Classic, the cards are as before.
func _test_node_style() -> void:
	var key := XREFeatureSettings.NODE_STYLE
	var graph := _service.blueprint.graph
	var count := graph.nodes.size()
	var event: int = graph.nodes[0]["id"]
	var added: Array[int] = []
	for kind: String in ["set_property", "branch", "delay", "get_property"]:
		_service.add_block(kind)
		await _frames()
		added.append(int(graph.nodes.back()["id"]))
	var had_in := graph.edges.any(func(edge: Dictionary) -> bool: return edge["to"] == added[0] and edge["to_port"] == 0)
	_check(_document.set_feature(key, XREFeatureSettings.ARCHETYPES, XREDocument.Source.PANEL), "the node style switches to archetypes")
	await _frames()
	_check(_service.canvas.get_style() == XREFeatureSettings.ARCHETYPES and (_service.canvas.get("_cards") as Array).size() == count + 4, "the open graph is redrawn with the same cards")
	var groups: Array[int] = [XREBlueprintIcons.Group.EVENT, XREBlueprintIcons.Group.SET, XREBlueprintIcons.Group.FLOW, XREBlueprintIcons.Group.FLOW]
	var ids: Array[int] = [event, added[0], added[1], added[2]]
	for index: int in ids.size():
		var head := _card(ids[index]).node.get_node_or_null("Head") as MeshInstance3D
		var shown: Material = head.get_meta(&"unpainted", head.material_override) if head != null else null
		_check(shown is ShaderMaterial and ((shown as ShaderMaterial).get_shader_parameter(&"face_tint") as Color).is_equal_approx(XREBlueprintIcons.HEADS[groups[index]]),
				"%s has a header in its group's color" % XREBlueprintGraph.title(graph.find_node(ids[index])))
		_check(_card(ids[index]).node.get_node_or_null("Icon") != null, "and an icon on it")
	var pure := _card(added[3])
	_check(pure.node.get_node_or_null("Head") == null and pure.node.get_node_or_null("Icon") != null, "Get Property, pure, has no header, only its icon")
	_check((pure.frame_material as BaseMaterial3D).albedo_color.is_equal_approx(XREBlueprintCanvas.COLORS[pure.output_types[0]]), "and is framed in its result's color")
	var titled := false
	for child: Node in _card(event).node.get_children():
		if child is Label3D and (child as Label3D).text.contains(" · "): titled = true
	_check(not titled, "an archetype's title has no id")
	_aim(Vector3(5, 4, -2))
	await _frames()
	_check(not _card(added[1]).trash.visible, "out of focus, an archetype has no trash")
	_service.select_block(added[0])
	await _frames()
	_aim(_card(added[1]).node.to_global(Vector3(0, -0.02, _card(added[1]).face)))
	await _frames()
	_check(_card(added[1]).trash.visible, "the card under the ray shows its trash")
	_left.set_input(&"ax_button", true)
	await _frames()
	_left.set_input(&"ax_button", false)
	await _frames()
	_check(graph.find_node(added[1]).is_empty() and not graph.find_node(added[0]).is_empty(), "X deletes the card under the ray, not the selected one")
	_service.blueprint.undo()
	await _frames()
	_check(not graph.find_node(added[1]).is_empty(), "undo puts it back")
	# A click on the policy chip takes the next policy (D-107), one edit.
	var policy := str(graph.find_node(event)["params"]["policy"])
	_service.call("_next_policy", event)
	await _frames()
	_check(str(graph.find_node(event)["params"]["policy"]) != policy, "a click on the chip takes the next policy")
	_service.blueprint.undo()
	await _frames()
	# ⇄ switches one card's heading (D-101): one edit, undone by A.
	_service.switch_heading(added[0])
	await _frames()
	_check(str(graph.find_node(added[0]).get("vr_heading", "")) == "member" and _card(added[0]).node.get_node_or_null("Member") != null, "⇄ makes the Set's header say its member")
	_service.blueprint.undo()
	await _frames()
	_check(not graph.find_node(added[0]).has("vr_heading") and _card(added[0]).node.get_node_or_null("Title") != null, "undo puts the operation back")
	# One Set (D-102): the menu lists Set; a box's wire into its Target makes it a
	# Set Variable, a scene object for its Variable a Set Property again, each one edit.
	_check(_service.block_menu.one_set, "with archetypes the block menu has one Set")
	_check(_service.blueprint.add_variable("speed", 1.5, {"vr_position": Vector2(-400, 0)}), "a variable for the Set")
	await _frames()
	_service.call("_set_writes_variable", added[0], "speed")
	await _frames()
	var written := graph.find_node(added[0])
	_check(written["kind"] == "set_variable" and str(written["params"]["variable"]) == "speed" and not (written["params"] as Dictionary).has("target"), "a box's wire into the Set's Target makes it write the variable")
	_check(graph.edges.any(func(edge: Dictionary) -> bool: return edge["to"] == added[0] and edge["to_port"] == 0) == had_in, "its In stays wired as it was")
	_service.call("_set_writes_property", added[0], _host)
	await _frames()
	written = graph.find_node(added[0])
	_check(written["kind"] == "set_property" and not (written["params"] as Dictionary).has("variable") and str(written["params"]["target"]) == ".", "the Variable wired to a scene object makes it write a property of it")
	_service.blueprint.undo()
	_service.blueprint.undo()
	_service.blueprint.undo()
	await _frames()
	_check(graph.find_node(added[0])["kind"] == "set_property" and graph.find_variable("speed").is_empty(), "undo takes back each edit")
	# Port shapes (D-104) redraw the open graph too.
	_check(_document.set_feature(XREFeatureSettings.PORT_SHAPES, XREFeatureSettings.ON, XREDocument.Source.PANEL) and _service.canvas.get_port_shapes(), "port shapes switch on")
	await _frames()
	_check(_card(added[1]).ports[1].mesh is ArrayMesh, "Branch's Condition is a shaped port")
	_check(_document.set_feature(XREFeatureSettings.PORT_SHAPES, XREFeatureSettings.OFF, XREDocument.Source.PANEL), "and off")
	await _frames()
	# Node shrink (D-100) redraws the open graph too.
	_check(_document.set_feature(XREFeatureSettings.NODE_SHRINK, XREFeatureSettings.MATH, XREDocument.Source.PANEL), "node shrink switches to + Math")
	await _frames()
	_check(_service.canvas.get_shrink() == XREFeatureSettings.MATH and (_service.canvas.get("_cards") as Array).size() == count + 4, "the open graph is redrawn with + Math")
	_check(_document.set_feature(XREFeatureSettings.NODE_SHRINK, XREFeatureSettings.ICONS, XREDocument.Source.PANEL), "node shrink switches to All with icons")
	await _frames()
	_check(_card(added[2]).bead and _card(added[0]).bead and not _card(event).bead, "Delay and Set are beads, the event a card (D-103)")
	_check(_document.set_feature(XREFeatureSettings.NODE_SHRINK, XREFeatureSettings.OPERATORS, XREDocument.Source.PANEL), "and back to Operators")
	await _frames()
	_aim(Vector3(5, 4, -2))
	_check(_document.set_feature(key, XREFeatureSettings.CLASSIC, XREDocument.Source.PANEL), "the node style switches back")
	await _frames()
	_check(not _service.block_menu.one_set, "and Classic lists Set Property and the variables' Sets again")
	_check(_card(event).node.get_node_or_null("Head") == null and _card(added[1]).trash.visible, "cards are classic again, with the trash in the header")
	for index: int in added.size(): _service.blueprint.undo()
	await _frames()
	_check(graph.nodes.size() == count, "the blocks added for the check are gone")
	_service.select_block(-1)


## Composite values on Split (D-105): a Vector3's box has an output for each
## component, which the ray picks; wired into a port, a Break fed by a Get
## Variable goes under it, both hidden, its wire a number's from the
## component; on Whole the Break is a card; deleting the reader takes the
## hidden two with it; each is one edit.
func _test_composite_values() -> void:
	var features := _document.features
	var variables := features.get_value(XREFeatureSettings.VARIABLE_INPUT)
	_document.set_feature(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.BOXES, XREDocument.Source.PANEL)
	_check(_document.set_feature(XREFeatureSettings.COMPOSITE_VALUES, XREFeatureSettings.SPLIT, XREDocument.Source.PANEL), "composite values switch to Split")
	var graph := _service.blueprint.graph
	var count := graph.nodes.size()
	_service.add_block("delay")
	await _frames()
	var delay: int = graph.nodes.back()["id"]
	_check(_service.blueprint.add_variable("spot", Vector3(1, 2, 3), {"vr_position": Vector2(-400, 300)}), "a Vector3 variable")
	await _frames()
	var boxes := _service.canvas.get_boxes()
	_check(boxes.component_point("spot", 2).is_equal_approx(boxes.box_point("spot")), "a new box's drawer starts shut (D-114)")
	_service.call("_switch_drawer", "spot")
	await _frames()
	boxes = _service.canvas.get_boxes()
	_check(graph.find_variable("spot").get("vr_collapsed", true) == false, "its switch opens it, one edit")
	var z := boxes.component_point("spot", 2)
	_check(not z.is_equal_approx(boxes.box_point("spot")) and z.x > boxes.box_point("spot").x, "its box has its components' outputs on its right")
	_check(boxes.intersect_ray(z + Vector3(0, 0, 0.3), Vector3.FORWARD, 1.0) >= 0 and boxes.get_hit_part() == XREBlueprintBoxes.COMPONENT and boxes.get_hit_component() == 2, "the ray picks the z output")
	# The drawer shuts on its own (D-108), one edit, and opens again.
	_service.call("_switch_drawer", "spot")
	await _frames()
	_check(not graph.find_variable("spot").has("vr_collapsed") and _service.canvas.get_boxes().component_point("spot", 2).is_equal_approx(_service.canvas.get_boxes().box_point("spot")), "its drawer shuts without the setting")
	_service.call("_switch_drawer", "spot")
	await _frames()
	_check(graph.find_variable("spot").get("vr_collapsed", true) == false, "and opens again")
	boxes = _service.canvas.get_boxes()
	var cards := (_service.canvas.get("_cards") as Array).size()
	_service.call("_wire_component_to_port", "spot", 1, delay, 1)
	await _frames()
	var breaker := -1
	for edge: Dictionary in graph.edges:
		if edge["to"] == delay and edge["to_port"] == 1: breaker = edge["from"]
	var block := graph.find_node(breaker)
	_check(XREBlueprintCanvas.is_split_break(block) and str((block["function"] as Dictionary)["name"]) == "break_vector3", "the y output wired into Seconds is a hidden Break of spot")
	_check((_service.canvas.get("_cards") as Array).size() == cards, "with no card for it or its Get Variable")
	_service.call("_switch_drawer", "spot")
	await _frames()
	_check(graph.find_variable("spot").get("vr_collapsed", true) == false, "a drawer whose components are wired stays open")
	var wired: XREBlueprintCanvas.Wire = null
	for wire: XREBlueprintCanvas.Wire in _service.canvas.get("_wires") as Array:
		if wire.from == null and wire.to != null and wire.to.id == delay and wire.to_port == 1: wired = wire
	_check(wired != null and wired.component == 1 and wired.variable == "spot", "its wire comes from the box's y output")
	_check(_document.set_feature(XREFeatureSettings.COMPOSITE_VALUES, XREFeatureSettings.WHOLE, XREDocument.Source.PANEL), "composite values switch to Whole")
	await _frames()
	_check(_card(breaker) != null, "on Whole the Break is a card")
	_check(_document.set_feature(XREFeatureSettings.COMPOSITE_VALUES, XREFeatureSettings.SPLIT, XREDocument.Source.PANEL), "and Split again")
	await _frames()
	_service.delete_block(delay)
	await _frames()
	_check(graph.find_node(breaker).is_empty() and not graph.nodes.any(func(entry: Dictionary) -> bool: return entry["kind"] == "get_variable" and entry.get("vr_inline", false) and str(entry["params"]["variable"]) == "spot"),
			"deleting Delay takes the hidden Break and its Get Variable with it")
	for step: int in 7: _service.blueprint.undo()
	await _frames()
	_check(graph.nodes.size() == count and graph.find_variable("spot").is_empty(), "undo takes back each edit")
	_document.set_feature(XREFeatureSettings.COMPOSITE_VALUES, XREFeatureSettings.WHOLE, XREDocument.Source.PANEL)
	_document.set_feature(XREFeatureSettings.VARIABLE_INPUT, variables, XREDocument.Source.PANEL)
	await _frames()


## Points the right ray, with [param trigger] and [param grip], at a point
## just outside [param corner] of [param window], from in front of it.
func _aim_corner(window: XREPanelSurface, corner: int, trigger: float, grip: float) -> void:
	var sign := Vector2(-1 if corner == XREPanelSurface.Corner.TOP_LEFT or corner == XREPanelSurface.Corner.BOTTOM_LEFT else 1,
			1 if corner == XREPanelSurface.Corner.TOP_LEFT or corner == XREPanelSurface.Corner.TOP_RIGHT else -1)
	var local := Vector3(sign.x * (window.size_m.x * 0.5 + 0.02), sign.y * (window.size_m.y * 0.5 + 0.02), 0)
	var target := window.global_transform * local
	var origin := target + window.global_basis.z.normalized() * 0.4
	_right.set_pose(&"aim", Transform3D(Basis.looking_at(target - origin), origin), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_right.set_input(&"trigger", trigger)
	_right.set_input(&"grip", grip)


## Corner handles of the graph's windows (D-040): grip on the keyboard's
## corner moves that window. The parameters and the block palette are the
## panels' windows since D-044; the toolbar, which moved them all, is gone
## since D-085.
func _test_window_corners() -> void:
	var floating := _service.get("_floating_ui") as Node3D
	var panel := _service.get("_keyboard") as XREVirtualKeyboard
	var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
	var floating_before := floating.global_transform
	var history := _service.blueprint.history.get_version()
	_check(panel.has_corner_handles(), "the keyboard has corner handles")
	_check((_service.get("_windows") as Array).size() == 1, "the keyboard is the graph's only window of its own")
	_check(not (_service.get("_badge") as XREPanelSurface).has_corner_handles(), "the object's badge, object-locked, has none")
	panel.open_text("corner")
	var panel_before := panel.transform

	_aim_corner(panel, XREPanelSurface.Corner.BOTTOM_RIGHT, 0, 0)
	await _frames()
	_check(panel.handle_lit(XREPanelSurface.Corner.BOTTOM_RIGHT), "the ray lights the keyboard's corner handle")
	_right.set_input(&"grip", 1.0)
	await _frames()
	_check(pointer.held == panel and pointer.window == panel, "grip on a corner handle takes the keyboard")
	var start := panel.global_position
	var hand := _rig.right_hand.global_transform
	_right.set_pose(&"aim", _rig.global_transform.affine_inverse() * hand.translated(Vector3(0.1, 0.05, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_check(panel.global_position.distance_to(start + Vector3(0.1, 0.05, 0)) < 0.001, "the window follows the hand by its corner")
	_check(panel.global_basis.is_equal_approx(floating_before.basis * panel_before.basis), "and keeps its tilt")
	_check(floating.global_transform.is_equal_approx(floating_before), "the keyboard moves alone")
	_right.set_input(&"grip", 0.0)
	await _frames()
	_check(pointer.held == null, "letting go of the grip leaves the window")
	_check(_service.blueprint.history.get_version() == history, "moving windows is not a graph edit")
	panel.transform = panel_before
	_aim(Vector3(5, 4, -2))
	await _frames()
	_check(not panel.handle_shown(XREPanelSurface.Corner.BOTTOM_RIGHT), "handles hide when the ray leaves")
	panel.close()


func _test_workspace() -> void:
	var workspace := _service.get("_workspace") as Node3D
	_check(workspace.global_basis.y.is_equal_approx(Vector3.UP), "workspace opens vertically")
	var before := workspace.global_transform
	var floating := _service.get("_floating_ui") as Node3D
	var ui_local := floating.transform
	_check((_service.get("_dimmer") as MeshInstance3D).visible, "opening logic enables the scene dimmer")
	var rig_before := _rig.transform
	_rig.transform = Transform3D(Basis(Vector3.UP, 0.3), Vector3(0.4, 0.2, -0.5))
	await _frames()
	_check(workspace.global_transform.is_equal_approx(before), "flying and yaw leave the workspace at its opening position")
	_check(floating.transform.is_equal_approx(ui_local), "Blueprint and parameter panels follow the rig independently of the graph")
	_rig.transform = rig_before
	var head_before := _rig.camera.position
	_rig.camera.position += Vector3(0.2, 0, -0.1)
	await _frames()
	_check(workspace.global_transform.is_equal_approx(before), "physical walking leaves the graph fixed in the scene")
	_check(floating.transform.is_equal_approx(ui_local), "physical head translation does not move floating windows")
	_check(workspace.global_basis.is_equal_approx(before.basis), "looking/walking do not turn the graph")
	_rig.camera.position = head_before
	var head_rotation := _rig.camera.rotation
	_rig.camera.rotation = Vector3(0.15, 0.3, 0)
	await _frames()
	_check(floating.transform.is_equal_approx(ui_local), "head rotation does not steer floating windows")
	_rig.camera.rotation = head_rotation
	await _frames()
	var card := (_service.canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	await _click(card.node.to_global(card.plus_point))
	_check(_service.is_block_palette_shown(), "trigger on plus opens a block palette")
	_service.close_block_palette()
	_rig.camera.position = Vector3(0, 0, -2)
	await _frames()
	_check(card.node.global_basis.z.dot((_rig.camera.global_position - card.node.global_position).normalized()) > 0.99 and absf(card.node.global_basis.x.y) < 0.001, "walking behind the graph turns each flat card towards the head, tilted to it (D-061)")
	var plus := card.node.to_global(card.plus_point)
	_right.set_pose(&"aim", Transform3D(Basis(Vector3.UP, PI), plus + Vector3.FORWARD * 0.4), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(_service.is_block_palette_shown(), "automatically facing plus opens the palette from the user's new side")
	_service.close_block_palette()
	_rig.camera.position = head_before
	await _frames()
	_aim(Vector3(5, 4, -2))
	_service.select_block(-1)


func _test_card_rotation(id: int) -> void:
	var before := _service.canvas.get_block_transform(id)
	var point := _service.canvas.to_global(before.origin)
	_right.set_pose(&"aim", Transform3D(Basis.IDENTITY, point + Vector3.BACK * 0.15), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_right.set_pose(&"grip", Transform3D(Basis.IDENTITY, point), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_right.set_input(&"grip", 1.0)
	await _frames()
	var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
	_check(pointer.block == id and pointer.touched, "direct touch grabs the card at the physical controller")
	_check(not (_rig.right_hand.get("_ray") as MeshInstance3D).visible, "physical touch hides the aim ray")
	var version := _service.blueprint.history.get_version()
	var rotation := Basis.from_euler(Vector3(0.25, 0.4, 0.1))
	var moved := point + Vector3(0.04, 0.02, 0)
	_right.set_pose(&"grip", Transform3D(rotation, moved), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_right.set_pose(&"aim", Transform3D(rotation, moved + rotation * Vector3.BACK * 0.15), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	var preview := _service.canvas.get_block_transform(id)
	var facing := _rig.camera.global_position - _service.canvas.to_global(preview.origin)
	_check((_service.canvas.global_basis * preview.basis.z).dot(facing.normalized()) > 0.99 and absf((_service.canvas.global_basis * preview.basis.x).y) < 0.001, "touch grab faces the user, rows level, despite controller roll")
	_check(_service.blueprint.history.get_version() == version, "rotation preview leaves history untouched")
	_right.set_input(&"grip", 0.0)
	await _frames()
	_check(_service.blueprint.history.get_version() == version + 1, "release stores move and rotation as one edit")
	_check(not _service.blueprint.graph.find_node(id).has("vr_rotation"), "view-dependent facing is not saved as graph metadata")
	_service.blueprint.undo()
	await _frames()
	_check(_service.canvas.get_block_transform(id).is_equal_approx(before), "undo restores position and orientation together")
	_service.blueprint.redo()
	await _frames()
	_check(_service.canvas.get_block_transform(id).is_equal_approx(preview), "redo restores the rotated card")
	_service.blueprint.undo()
	await _frames()
	_right.invalidate_pose(&"grip")
	await _frames()
	await _test_card_ray(id)
	_aim(Vector3(5, 4, -2))
	await _frames()


func _test_card_ray(id: int) -> void:
	var before := _service.canvas.get_block_transform(id)
	var point := _service.canvas.to_global(before.origin + Vector3(0, 0.025, 0))
	_aim(point)
	_right.set_input(&"grip", 1.0)
	await _frames()
	var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
	_check(pointer.block == id and not pointer.touched, "ray grip remains a distant grab")
	var turn := Basis.from_euler(Vector3(0.2, 0.6, -0.1))
	_right.set_pose(&"aim", Transform3D(turn, point + Vector3(0.06, 0.02, 0.4)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	var ray := _rig.right_hand.get("_ray") as MeshInstance3D
	var endpoint := _service.canvas.to_global(_service.canvas.get_block_transform(id) * pointer.grab_point)
	_check(ray.basis.orthonormalized().is_equal_approx(Basis.IDENTITY), "grabbing never steers the ray away from the controller aim axis")
	_check(_rig.right_hand.to_local(endpoint).is_equal_approx(Vector3(0, 0, -pointer.distance)), "held card contact stays on the aim axis while depth changes")
	_check(ray.to_global(Vector3(0, 0, -0.5)).is_equal_approx(endpoint), "rotated grab ray ends at the actual card contact")
	_check((_rig.right_hand.get("_dot") as MeshInstance3D).global_position.is_equal_approx(endpoint), "grab dot follows the card's local contact")
	_right.invalidate_pose(&"aim")
	await _frames()
	_check(_service.canvas.get_block_transform(id).is_equal_approx(before), "tracking loss restores the whole distant grab preview")
	_right.set_input(&"grip", 0.0)


func _test_depth_pull(id: int) -> void:
	var original := _service.canvas.get_block_transform(id)
	var history := _service.blueprint.history.get_version()
	var torso := _body_point()
	var hand_start := torso + Vector3.FORWARD * 0.4
	var near_motion := 0.0
	for depth: float in [1.0, 3.0]:
		var pose := Transform3D(Basis.IDENTITY, _service.canvas.to_local(torso + Vector3.FORWARD * depth))
		_service.canvas.preview_transform(id, pose)
		_right.set_pose(&"aim", Transform3D(Basis.IDENTITY, hand_start), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
		_right.set_input(&"grip", 0.0)
		await _frames()
		_right.set_input(&"grip", 1.0)
		await _frames()
		var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
		_check(pointer.block == id and not pointer.touched, "depth fixture is grabbed by the ray")
		var contact := _service.canvas.to_global(_service.canvas.get_block_transform(id) * pointer.grab_point)
		var initial_distance := pointer.distance
		var hand_pulled := torso + Vector3.FORWARD * 0.32
		_right.set_pose(&"aim", Transform3D(Basis.IDENTITY, hand_pulled), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
		await _frames()
		var endpoint := _service.canvas.to_global(_service.canvas.get_block_transform(id) * pointer.grab_point)
		var gain := _body_reach(contact) / _body_reach(hand_start)
		var expected := XREManipulator.moved_pivot(contact, hand_start, hand_pulled, gain)
		_check(endpoint.is_equal_approx(expected), "straight depth pull scales hand travel by the body-reach HOMER gain")
		_check(pointer.distance < initial_distance, "moving the hand toward the body shortens the ray grab")
		var motion := contact.distance_to(endpoint)
		if depth < 2.0: near_motion = motion
		else: _check(motion > near_motion * 2.0, "farther card needs less hand travel for the same pull")
		var hand_pushed := torso + Vector3.FORWARD * 0.48
		_right.set_pose(&"aim", Transform3D(Basis.IDENTITY, hand_pushed), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
		await _frames()
		_check(pointer.distance > initial_distance, "moving the hand away from the body increases grab depth")
		endpoint = _service.canvas.to_global(_service.canvas.get_block_transform(id) * pointer.grab_point)
		_check(_rig.right_hand.to_local(endpoint).is_equal_approx(Vector3(0, 0, -pointer.distance)), "push keeps the card contact exactly on the straight ray")
		_right.invalidate_pose(&"aim")
		await _frames()
		_check(_service.canvas.get_block_transform(id).origin.is_equal_approx(pose.origin), "tracking loss cancels both depth and pose preview")
		_right.set_input(&"grip", 0.0)
	_service.canvas.preview_transform(id, original)
	_check(_service.blueprint.history.get_version() == history, "depth previews never add history before release")
	_aim(Vector3(5, 4, -2))
	await _frames()


## A point on the assumed body axis at shoulder-to-hip height, as the grab measures it.
func _body_point() -> Vector3:
	return _rig.camera.global_transform * XREBlueprints.NECK_FROM_EYES - _rig.global_basis.y.normalized() * 0.225


func _body_reach(point: Vector3) -> float:
	return XREBlueprints.body_reach(_rig.camera.global_transform, _rig.global_basis.y.normalized(), point)


func _set_grip_and_aim(grip: Transform3D) -> void:
	_right.set_pose(&"grip", grip, Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_right.set_pose(&"aim", Transform3D(grip.basis, grip * Vector3(0, 0, -0.12)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)


## A single torso point at neck height made a pull toward the lap read as a push.
func _test_depth_lap(id: int) -> void:
	var original := _service.canvas.get_block_transform(id)
	var version := _service.blueprint.history.get_version()
	var body := _body_point()
	var start := body + Vector3(0.15, -0.2, -0.35)
	var pulled := start + Vector3(0, -0.2, 0.15)
	var torso_point := _rig.camera.global_position + XREManipulator.TORSO_OFFSET
	_check(pulled.distance_to(torso_point) > start.distance_to(torso_point), "lap fixture moves away from a single torso point")
	_service.canvas.preview_transform(id, Transform3D(Basis.IDENTITY, _service.canvas.to_local(start + Vector3(0, 0, -0.12) + Vector3.FORWARD * 2.0)))
	_set_grip_and_aim(Transform3D(Basis.IDENTITY, start))
	_right.set_input(&"grip", 0.0)
	await _frames()
	_right.set_input(&"grip", 1.0)
	await _frames()
	var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
	_check(pointer.block == id and not pointer.touched, "lap regression grabs a distant card by the ray")
	var initial := pointer.distance
	_set_grip_and_aim(Transform3D(Basis.IDENTITY, pulled))
	await _frames()
	_check(pointer.distance < initial, "pulling the hand back and down toward the lap shortens the rod")
	_right.invalidate_pose(&"grip")
	await _frames()
	_check(pointer.held == null and _service.blueprint.history.get_version() == version, "cancelled lap hold adds no history")
	_service.canvas.preview_transform(id, original)
	_right.set_input(&"grip", 0.0)
	_aim(Vector3(5, 4, -2))
	await _frames()


func _test_depth_direction(id: int) -> void:
	var original := _service.canvas.get_block_transform(id)
	var version := _service.blueprint.history.get_version()
	var torso := _body_point()
	var grip_start := torso + Vector3(0.28, 0, -0.4)
	var aim_start := grip_start + Vector3(0, 0, -0.12)
	_service.canvas.preview_transform(id, Transform3D(Basis.IDENTITY, _service.canvas.to_local(aim_start + Vector3.FORWARD * 2.0)))
	_set_grip_and_aim(Transform3D(Basis.IDENTITY, grip_start))
	_right.set_input(&"grip", 0.0)
	await _frames()
	_right.set_input(&"grip", 1.0)
	await _frames()
	var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
	_check(pointer.block == id and not pointer.touched, "direction regression grabs a distant card with separate grip/aim poses")
	var initial := pointer.distance
	for yaw: float in [-0.8, 0.8, -0.4, 0.4, 0.0]:
		_set_grip_and_aim(Transform3D(Basis(Vector3.UP, yaw), grip_start))
		await _frames()
		_check(is_equal_approx(pointer.distance, initial), "wrist yaw with fixed physical grip never changes grab depth")
	var offset := grip_start - torso
	var outwards := Basis.looking_at(Vector3(offset.x, 0, offset.z))
	_set_grip_and_aim(Transform3D(outwards, grip_start))
	await _frames()
	_check(is_equal_approx(pointer.distance, initial), "pointing the rod outwards from the body is a wrist turn only")
	for side: float in [-0.8, 0.8, -0.4, 0.4, 0.0]:
		var turn := Basis(Vector3.UP, side)
		_set_grip_and_aim(Transform3D(turn * outwards, torso + turn * offset))
		await _frames()
		_check(is_equal_approx(pointer.distance, initial), "arm swing at constant body distance keeps the rod length")
		var contact_on_arc := _service.canvas.to_global(_service.canvas.get_block_transform(id) * pointer.grab_point)
		_check(_rig.right_hand.to_local(contact_on_arc).is_equal_approx(Vector3(0, 0, -initial)), "rotating a fixed-length rod keeps the card attached to its tip")
	var head_before := _rig.camera.position
	var shift := Vector3(0.12, 0.05, -0.08)
	_rig.camera.position += shift
	_set_grip_and_aim(Transform3D(Basis.IDENTITY, grip_start + _rig.global_basis * shift))
	await _frames()
	_check(is_equal_approx(pointer.distance, initial), "walking with the hand and body together preserves rod length")
	_rig.camera.position = head_before
	_set_grip_and_aim(Transform3D(Basis.IDENTITY, grip_start))
	await _frames()
	var head_turn := _rig.camera.transform
	var neck := head_turn * XREBlueprints.NECK_FROM_EYES
	for look: Vector3 in [Vector3(-0.6, 0, 0), Vector3(0.3, 0.7, 0), Vector3(-0.3, -0.8, 0)]:
		var turned := Basis.from_euler(look)
		_rig.camera.transform = Transform3D(turned, neck - turned * XREBlueprints.NECK_FROM_EYES)
		await _frames()
		_check(is_equal_approx(pointer.distance, initial), "turning the head about the neck with a still hand keeps rod length")
	_rig.camera.transform = head_turn
	await _frames()
	var contact := _service.canvas.to_global(_service.canvas.get_block_transform(id) * pointer.grab_point)
	var sideways := grip_start + Vector3(0.3, 0.1, 0)
	_check(_body_reach(sideways) > _body_reach(grip_start), "sideways fixture moves the hand away from the body axis")
	_set_grip_and_aim(Transform3D(Basis.IDENTITY, sideways))
	await _frames()
	_check(is_equal_approx(pointer.distance, initial), "moving the hand across the rod keeps its length")
	var endpoint := _service.canvas.to_global(_service.canvas.get_block_transform(id) * pointer.grab_point)
	_check(is_equal_approx(endpoint.z, contact.z), "a sideways move carries the card sideways, never away")
	_set_grip_and_aim(Transform3D(Basis.IDENTITY, sideways + Vector3(0, 0, 0.08)))
	await _frames()
	_check(pointer.distance < initial, "pulling back along the rod after a sideways move shortens it")
	_set_grip_and_aim(Transform3D(Basis.IDENTITY, grip_start))
	await _frames()
	_check(is_equal_approx(pointer.distance, initial), "returning the hand restores the rod length")
	var pushed := grip_start + Vector3(0, 0, -0.4)
	_set_grip_and_aim(Transform3D(Basis.IDENTITY, pushed))
	await _frames()
	var far := pointer.distance
	_check(far > initial, "strong deliberate push increases depth")
	for yaw: float in [0.8, -0.8, 0.8, 0.0]:
		_set_grip_and_aim(Transform3D(Basis(Vector3.UP, yaw), pushed))
		await _frames()
		_check(is_equal_approx(pointer.distance, far), "yaw after a strong push cannot add more distance")
	await _frames(20)
	_check(is_equal_approx(pointer.distance, far), "stationary hold cannot accumulate depth frame by frame")
	_set_grip_and_aim(Transform3D(Basis.IDENTITY, pushed + Vector3(0, 0, 0.08)))
	await _frames()
	_check(pointer.distance < far, "pull after a strong push reverses depth immediately")
	_right.set_input(&"grip", 0.0)
	await _frames()
	_check(_service.blueprint.history.get_version() == version + 1, "entire pushed/rotated gesture remains one undo edit")
	_right.set_input(&"grip", 1.0)
	await _frames()
	_check(pointer.block == id, "pushed card can be grabbed again without a distance jump")
	var reacquired := pointer.distance
	var fresh_grip := pushed + Vector3(0, 0, 0.08)
	for yaw: float in [-0.8, 0.8, 0.0]:
		_set_grip_and_aim(Transform3D(Basis(Vector3.UP, yaw), fresh_grip))
		await _frames()
		_check(is_equal_approx(pointer.distance, reacquired), "new hold of a distant card stays stable during both wrist turns")
	_set_grip_and_aim(Transform3D(Basis.IDENTITY, fresh_grip + Vector3(0, 0, 0.08)))
	await _frames()
	_check(pointer.distance < reacquired, "fresh far hold still pulls toward the hand")
	_right.set_input(&"grip", 0.0)
	await _frames()
	_check(_service.blueprint.history.get_version() == version + 2, "second hold remains a separate single undo edit")
	_service.blueprint.undo()
	await _frames()
	_service.blueprint.undo()
	await _frames()
	_check(_service.canvas.get_block_transform(id).is_equal_approx(original), "undo restores placement before the full distant gesture")
	_set_grip_and_aim(Transform3D(Basis.IDENTITY, _service.canvas.to_global(original.origin + Vector3(0, 0.025, 0)) + Vector3.BACK * 0.52))
	_right.set_input(&"grip", 1.0)
	await _frames()
	_check(pointer.depth_uses_grip, "hold latches its physical motion source")
	_right.invalidate_pose(&"grip")
	await _frames()
	_check(pointer.held == null and _service.canvas.get_block_transform(id).is_equal_approx(original), "grip pose loss cancels rather than switching to a displaced aim origin")
	_right.invalidate_pose(&"grip")
	_right.set_input(&"grip", 0.0)
	_aim(Vector3(5, 4, -2))
	await _frames()


## Points the right ray at interface pixel [param pixel] of [param surface], from in front of it, without clicking.
func _hover_on(surface: XREPanelSurface, pixel: Vector2) -> void:
	var target := surface.pixel_to_global(pixel)
	var origin := target + surface.global_basis.z.normalized() * 0.4
	_right.set_pose(&"aim", Transform3D(Basis.looking_at(target - origin), origin), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()


## Clicks the right trigger on interface pixel [param pixel] of [param surface], from in front of it.
func _click_on(surface: XREPanelSurface, pixel: Vector2) -> void:
	var target := surface.pixel_to_global(pixel)
	var origin := target + surface.global_basis.z.normalized() * 0.4
	_right.set_pose(&"aim", Transform3D(Basis.looking_at(target - origin), origin), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()


func _card(id: int) -> XREBlueprintCanvas.Card:
	for card: XREBlueprintCanvas.Card in _service.canvas.get("_cards") as Array:
		if card.id == id: return card
	return null


## The box of variable [param variable] as built now, or null.
func _box(variable: String) -> XREBlueprintBoxes.Box:
	for box: XREBlueprintBoxes.Box in (_service.canvas.get("_boxes") as XREBlueprintBoxes).get("_boxes") as Array:
		if box.name == variable: return box
	return null


## D-043, D-044: the parameters window opens beside the selected block as a
## window of the panels, which closes and pins to a hand by its control bar;
## the block palette closes by ×; a wire is taken back by its own port or by
## the trigger on nothing; a port under the ray grows; sphere ports; concave windows.
func _test_windows_and_ports(id: int) -> void:
	_service.select_block(-1)
	await _frames()
	_check(not _service.is_parameters_shown() and _panels.find_window(XREBlueprintParametersTab) == null,
			"without a selected block there is no parameters window")
	_service.select_block(id)
	var window := _panels.find_window(XREBlueprintParametersTab)
	_check(_service.is_parameters_shown() and window != null, "selecting a block opens its parameters window")
	if window == null: return
	_check(window.tab.is_ancestor_of(_service.parameters) and _service.parameters.is_visible_in_tree(), "the window shows the parameters form")
	_check(window.get_bar() != null and window.has_corner_handles(), "a window as the tabs' are: control bar and corner handles")
	var card_pose := _card(id).node.global_transform
	var beside := card_pose.affine_inverse() * window.global_position
	# Pulled towards the head from beside the card, it drifts a little towards the head's height.
	_check(absf(beside.y) < 0.1 and absf(beside.x) > XREBlueprintCanvas.CARD_WIDTH * 0.5 and absf(beside.x) < XREBlueprintCanvas.CARD_WIDTH + window.size_m.x,
			"beside the selected block: %s" % beside)
	_check(_rig.camera.global_position.distance_to(window.global_position) < _rig.camera.global_position.distance_to(card_pose.origin),
			"nearer the head than the block")
	var first: int = _service.blueprint.graph.nodes[0]["id"]
	_service.select_block(first)
	_check(_panels.find_window(XREBlueprintParametersTab) == window
			and (_card(first).node.global_transform.affine_inverse() * window.global_position).length() < 0.5,
			"selecting another block brings the window beside it")
	_service.select_block(id)
	# The ray on the window shows its control bar; × on it closes the window.
	var bar := window.get_bar()
	await _hover_on(window, window.size_px * 0.5)
	await _click_on(bar, window.get_close_button().get_global_rect().get_center())
	await _frames()
	_check(not _service.is_parameters_shown() and _panels.find_window(XREBlueprintParametersTab) == null and _service.get("_selected") == id,
			"× on the control bar closes the parameters window and the block stays selected")
	_check(is_instance_valid(_service.parameters) and _service.parameters.get_parent() == _service.get("_forms_home"),
			"the form outlives its window")
	_service.select_block(-1)
	_service.select_block(id)
	window = _panels.find_window(XREBlueprintParametersTab)
	_check(window != null and window.tab.is_ancestor_of(_service.parameters), "selecting the block again opens the window again")
	await _hover_on(window, window.size_px * 0.5)
	await _click_on(window.get_bar(), window.get_pin_button().get_global_rect().get_center())
	await _frames()
	_check(window.pin == XREPanelWindow.Pin.RIGHT_HAND and _panels.get_pinned_window(_rig.right_hand) == window,
			"the pin on its control bar pins the parameters window to the hand that clicked")
	var pinned := window.global_transform
	_service.select_block(first)
	_check(window.global_transform.is_equal_approx(pinned) and window.is_pinned(), "a pinned parameters window stays on the hand when another block is selected")
	_service.close_parameters()
	_check(_panels.find_window(XREBlueprintParametersTab) == null and _panels.get_pinned_window(_rig.right_hand) == null, "the graph closes it, pinned too")
	await _frames()
	_service.select_block(id)
	_service.close_parameters()
	await _frames()
	# The plus's palette: a window of the panels too, beside the card, on the other side than the parameters.
	_service.call("_show_block_palette", id)
	var palette := _panels.find_window(XREBlueprintPaletteTab)
	_check(_service.is_block_palette_shown() and palette != null and palette.tab.is_ancestor_of(_service.block_menu), "the plus opens the block palette window")
	_check(not _service.is_parameters_shown() and _panels.find_window(XREBlueprintParametersTab) == null and _service.get("_selected") == id,
			"and not the parameters, though it selects the block (D-046)")
	_service.select_block(id)
	var parameters := _panels.find_window(XREBlueprintParametersTab)
	_check(parameters != null, "selecting the block opens its parameters")
	if palette == null or parameters == null: return
	# The block selected again: its parameters pulse where they are (D-046).
	parameters.stop_pulse()
	var parameters_at := parameters.global_transform
	_service.select_block(id)
	_check(parameters.is_pulsing() and parameters.global_transform.orthonormalized().is_equal_approx(parameters_at),
			"selecting the block again pulses its parameters where they are")
	parameters.stop_pulse()
	_service.call("_show_block_palette", id)
	_check(palette.is_pulsing(), "the plus again pulses the open palette")
	var card_inverse := _card(id).node.global_transform.affine_inverse()
	_check(signf((card_inverse * palette.global_position).x) == -signf((card_inverse * parameters.global_position).x),
			"beside the card, on the other side than its parameters")
	var blocks_before := _service.blueprint.graph.nodes.size()
	await _hover_on(palette, palette.size_px * 0.5)
	await _click_on(palette.get_bar(), palette.get_close_button().get_global_rect().get_center())
	await _frames()
	_check(not _service.is_block_palette_shown() and _panels.find_window(XREBlueprintPaletteTab) == null
			and _service.block_menu.get_parent() == _service.get("_forms_home") and _service.blueprint.graph.nodes.size() == blocks_before,
			"× on its control bar closes the block palette")
	_service.call("_show_block_palette", id)
	palette = _panels.find_window(XREBlueprintPaletteTab)
	_panels.pin_window(palette, XREPanelWindow.Pin.LEFT_HAND)
	var nodes_before := _service.blueprint.graph.nodes.size()
	_service.add_block("print")
	_check(_service.blueprint.graph.nodes.size() == nodes_before + 1 and _service.is_block_palette_shown() and palette.is_pinned(),
			"pinned to a hand, the palette stays after a block is added")
	_service.blueprint.undo()
	await _frames()
	_service.call("_show_block_palette", id)
	_check(palette.is_pinned() and _panels.get_pinned_window(_rig.left_hand) == palette, "the plus leaves a pinned palette on the hand")
	_service.close_block_palette()
	_service.close_parameters()
	await _frames()
	_check(_panels.find_window(XREBlueprintPaletteTab) == null, "the graph closes the pinned palette")
	# A port with two wires detaches only the one picked, from this port; its other end keeps it (D-044).
	var history := _service.blueprint.history.get_version()
	_service.add_block("value")
	var value_id: int = _service.blueprint.graph.nodes.back()["id"]
	_service.add_block("print")
	var second_id: int = _service.blueprint.graph.nodes.back()["id"]
	_service.blueprint.perform(_service.blueprint.connect_blocks.bind(value_id, 0, id, 1), &"vr_graph")
	_service.blueprint.perform(_service.blueprint.connect_blocks.bind(value_id, 0, second_id, 1), &"vr_graph")
	await _frames()
	var chosen := -1
	for index: int in _service.blueprint.graph.edges.size():
		var edge: Dictionary = _service.blueprint.graph.edges[index]
		if edge["from"] == value_id and edge["to"] == second_id: chosen = index
	var edges_before := _service.blueprint.graph.edges.size()
	_check(_service.click_port(value_id, 0, false, _rig.right_hand, chosen), "a click on a port with two wires")
	var kept := false
	var gone := true
	for edge: Dictionary in _service.blueprint.graph.edges:
		if edge["from"] == value_id and edge["to"] == id: kept = true
		if edge["from"] == value_id and edge["to"] == second_id: gone = false
	_check(_service.blueprint.graph.edges.size() == edges_before - 1 and kept and gone, "detaches only the picked wire")
	_check(_service.get("_pending_id") == value_id and _service.get("_pending_port") == 0 and not _service.get("_pending_input"),
			"which stays on the clicked port, its other end on the ray")
	_service.cancel_connection()
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()
	_service.select_block(id)
	_service.close_parameters()
	await _frames()

	var preview := _service.canvas.get("_preview") as XREGraphWire
	var port := _service.canvas.to_global(_service.canvas.port_position(id, 0, false))
	var front := _card(id).node.global_basis.z.normalized()
	var aim_port := func() -> void:
		_right.set_pose(&"aim", Transform3D(Basis.looking_at(-front), port + front * 0.4), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	aim_port.call()
	await _frames()
	_check(_service.canvas.is_port_hovered(id, 0, false), "the port under the ray grows, as the plus does")
	_check(is_equal_approx(_card(id).ports[_card(id).inputs.size()].scale.x, XREBlueprintCanvas.HOVER_SCALE), "by the plus's hover scale")
	for click: int in 2:
		aim_port.call()
		_right.set_input(&"trigger", 1.0)
		await _frames()
		_right.set_input(&"trigger", 0.0)
		await _frames()
		if click == 0: _check(_service.get("_pending_id") == id and preview.visible, "trigger on a port draws a wire")
	_check(int(_service.get("_pending_id")) == -1 and not preview.visible, "the same port again takes the wire back")
	aim_port.call()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(_service.get("_pending_hand") == _rig.right_hand, "a wire again, by the right hand")
	var selection := _document.get_selection()
	var blocks := _service.blueprint.graph.nodes.size()
	await _click(Vector3(5, 4, -2))
	_check(_document.get_selection() == selection, "the trigger on nothing selects nothing in the scene")
	# Let go in empty space, the wire opens the block menu for its pin (D-051); its × takes the wire back.
	var menu := _panels.find_window(XREBlueprintPaletteTab)
	_check(menu != null and _service.block_menu.get_pin().get("type") == XREBlueprintGraph.EXEC and _service.block_menu.get_pin().get("output") == true,
			"the trigger on nothing opens the block menu for the wire's port")
	_check(not _service.block_menu.get_listed().is_empty() and _service.block_menu.get_listed().all(func(action: Dictionary) -> bool: return XREBlueprintActions.fits_pin(action, XREBlueprintGraph.EXEC, true)),
			"the menu lists only blocks that can follow the port")
	if menu != null:
		await _hover_on(menu, menu.size_px * 0.5)
		await _click_on(menu.get_bar(), menu.get_close_button().get_global_rect().get_center())
	_check(int(_service.get("_pending_id")) == -1 and not preview.visible and _service.blueprint.graph.nodes.size() == blocks, "× of the menu takes the wire back")
	_check(not _service.canvas.is_port_hovered(id, 0, false), "a port the ray left is back to its size")

	_check(_document.set_feature(XREFeatureSettings.PORT_DISPLAY, XREFeatureSettings.SPHERE, XREDocument.Source.PANEL), "ports switch to spheres")
	await _frames()
	var card := _card(id)
	_check(card.ports[0].mesh is SphereMesh, "open cards' ports are spheres")
	port = _service.canvas.to_global(_service.canvas.port_position(id, 0, false))
	_check(_service.canvas.intersect_ray(port + front * 0.4, -front, 1.0) >= 0 and _service.canvas.get_hit_port() == 0 and not _service.canvas.get_hit_input(),
			"a sphere port takes the ray")
	var side := (front * 0.5 + _card(id).node.global_basis.x.normalized() * 0.866).normalized()
	_check(_service.canvas.intersect_ray(port + side * 0.3, -side, 1.0) >= 0 and _service.canvas.get_hit_port() == 0,
			"from aside too, as a sphere")
	_check(_document.set_feature(XREFeatureSettings.PORT_DISPLAY, XREFeatureSettings.FLAT, XREDocument.Source.PANEL), "ports switch back")
	await _frames()
	_check(_card(id).ports[0].mesh is CylinderMesh, "flat ports again")

	var keyboard := _service.get("_keyboard") as XREVirtualKeyboard
	keyboard.open_text("shape")
	_check(_document.set_feature(XREFeatureSettings.WINDOW_SHAPE, XREFeatureSettings.CONCAVE, XREDocument.Source.PANEL), "windows switch to concave")
	_check(keyboard.curve_radius > 0.0 and not (_service.get("_badge") as XREPanelSurface).curve_radius > 0.0,
			"the graph's windows bend, the object's badge doesn't")
	var pixel := Vector2(60, 40)
	var point := keyboard.pixel_to_global(pixel)
	_check(keyboard.to_local(point).z > 0.05, "a concave window's edge comes towards the user")
	var normal := keyboard.global_basis.z.normalized()
	_check(keyboard.intersect_ray(point + normal * 0.3, -normal, 1.0) >= 0 and keyboard.get_hit_pixel().distance_to(pixel) < 0.5,
			"the ray hits the pixel drawn there: %s" % keyboard.get_hit_pixel())
	_check(_document.set_feature(XREFeatureSettings.WINDOW_SHAPE, XREFeatureSettings.FLAT, XREDocument.Source.PANEL) and keyboard.curve_radius == 0.0,
			"and flat again")
	keyboard.close()


func _test_keyboard() -> void:
	var field := LineEdit.new()
	field.text = "door"
	add_child(field)
	_service.call("_show_keyboard", field)
	await _frames()
	var keyboard := _service.get("_keyboard") as XREVirtualKeyboard
	_check(keyboard.is_shown() and keyboard.get_parent() is Node3D, "text opens a separate spatial keyboard")
	_check(keyboard.global_basis.y.y < 0.95 and keyboard.global_basis.z.y > 0, "keyboard is tilted towards the user")
	keyboard.hover_feedback.connect(func(_hand: XREHand) -> void: _hover_pulses += 1)
	keyboard.key_clicked.connect(func() -> void: _keyboard_clicks += 1)
	var characters := keyboard.get("_characters") as Array
	var key := characters[11] as Button
	var pixel := key.get_global_rect().get_center()
	keyboard.hover_pointer(_rig.right_hand, pixel)
	keyboard.hover_pointer(_rig.right_hand, pixel)
	_check(_hover_pulses == 1, "stationary key hover requests only one vibration pulse")
	keyboard.leave_pointer(_rig.right_hand)
	keyboard.hover_pointer(_rig.left_hand, pixel)
	_check(_hover_pulses == 2, "other hand receives its own hover feedback")
	_check(not XREEditorHaptics.pulse(1, 0.18, 0.018), "headless feedback safely reports an absent XR session")
	keyboard.leave_pointer(_rig.left_hand)
	await _click(keyboard.pixel_to_global(pixel))
	_check(keyboard.value.text == "doorq" and field.text == "door", "ray key edits only the keyboard draft")
	_check(_keyboard_clicks == 1, "key press requests one click sound")
	var left_key := characters[12] as Button
	var left_point := keyboard.pixel_to_global(left_key.get_global_rect().get_center())
	_left.set_pose(&"aim", Transform3D(Basis.IDENTITY, left_point + Vector3.BACK * 0.4), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_check(keyboard.key_is_hovered(13) and keyboard.key_is_hovered(14), "both rays highlight different keyboard keys independently")
	_left.set_input(&"trigger", 1.0)
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(keyboard.value.text == "doorqqw" and _keyboard_clicks == 3, "both triggers accept one key immediately on press")
	_left.set_input(&"trigger", 0.0)
	await _frames()
	_check(keyboard.value.text == "doorqqw", "release adds no second key when the left hand finishes first")
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(keyboard.value.text == "doorqqw" and _keyboard_clicks == 3, "holding and release do not repeat a key")
	_left.set_input(&"trigger", 1.0)
	await _frames()
	_left.set_pose(&"aim", Transform3D(Basis.IDENTITY, Vector3(-5, 0, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_left.set_input(&"trigger", 0.0)
	await _frames()
	_check(keyboard.value.text == "doorqqww" and _keyboard_clicks == 4, "moving away after press preserves the already accepted key")
	var clicks_before := _keyboard_clicks
	var text_before := keyboard.value.text
	for tap: int in 16:
		_right.set_input(&"trigger", 1.0)
		await _frames(1)
		_right.set_input(&"trigger", 0.5)
		await _frames(1)
	_check(keyboard.value.text == text_before + "q".repeat(16) and _keyboard_clicks == clicks_before + 16, "fast shallow trigger releases preserve every key and sound")
	_right.set_input(&"trigger", 0.0)
	await _frames()
	var accepted := keyboard.value.text
	keyboard.call("_symbols")
	_check((characters[30] as Button).text == "/", "symbol plane includes path separators")
	keyboard.call("_shift")
	_check((characters[10] as Button).text == "_", "shift plane includes underscore")
	keyboard.call("_apply")
	_check(field.text == accepted and not keyboard.is_shown(), "Done applies all fast input and closes the keyboard")
	_service.call("_show_keyboard", field)
	await _frames()
	keyboard.value.text = "cancelled"
	keyboard.close()
	_check(field.text == accepted, "closing the keyboard discards the draft")
	field.queue_free()
	_aim(Vector3(5, 4, -2))
	await _frames()


## A card in front of a panel takes the ray; a panel drawn over everything,
## as the graph's badge is (D-085), takes it over the card.
func _test_surface_occlusion(badge: XREBlueprintBadge) -> void:
	var before := _service.canvas.get_block_position(1)
	var pixel := Vector2(110, badge.size_px.y * 0.5)
	var normal := badge.global_basis.z.normalized()
	_service.canvas.preview_move(1, _service.canvas.to_local(badge.pixel_to_global(pixel) + normal * 0.05))
	var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
	_right.set_pose(&"aim", _pose_at(badge, pixel), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_check(pointer.surface == badge, "the badge drawn over everything takes the ray over a card in front of it")
	badge.set_on_top(false)
	await _frames()
	var ray := _rig.right_hand.get("_ray") as MeshInstance3D
	_check(ray.scale.z < 0.28 and pointer.surface == null, "front card stops the pointer before a panel behind it: %.3f m" % ray.scale.z)
	await _click_at(badge, pixel)
	_check(_service.get("_selected") == 1, "trigger reaches the card instead of the covered panel")
	badge.set_on_top(true)
	_service.canvas.preview_move(1, before)
	_service.select_block(-1)
	_aim(Vector3(5, 4, -2))
	await _frames()


func _test_badge() -> void:
	var geometry := MeshInstance3D.new()
	geometry.name = "Geometry"
	geometry.mesh = BoxMesh.new()
	geometry.custom_aabb = AABB(Vector3(-0.5, -0.5, -0.5), Vector3.ONE)
	geometry.position = Vector3(0.7, 0.2, 0)
	_document.add_node(geometry, _host, XREDocument.Source.PANEL)
	await _frames()
	var badge := _service.get("_badge") as XREBlueprintBadge
	var first := badge.global_position
	# In the scene: the object's name and the Blueprint button, faint with a plus before it has a graph (D-085).
	_check(badge.is_shown() and not badge.is_graph() and not badge.is_on_top(), "the scene's badge shows over the selected object")
	_check(badge.get_blueprint_button().is_visible_in_tree() and badge.get_blueprint_button().text == "Blueprint"
			and badge.get_blueprint_button().tooltip_text == "Create Blueprint", "its one button is Blueprint, which creates one here")
	_check(not badge.get_close_button().is_visible_in_tree() and not badge.get_trash_button().is_visible_in_tree(), "the graph's buttons wait for the graph")
	_check_leader(badge, geometry.global_transform * geometry.custom_aabb)
	# With the object's shortcut on, its Blueprint takes the scene badge's place (D-088).
	_document.features.set_value(XREFeatureSettings.OBJECT_SHORTCUT, XREFeatureSettings.ON)
	await _frames()
	_check(not badge.is_shown(), "with the object's shortcut on, the scene has no badge")
	_document.features.set_value(XREFeatureSettings.OBJECT_SHORTCUT, XREFeatureSettings.OFF)
	await _frames()
	_check(badge.is_shown() and not badge.is_graph(), "with the shortcut off, the badge is back")
	var before := _host.transform
	_document.preview_transform(_host, Transform3D(Basis.from_euler(Vector3(0.1, 0.3, 0.4)).scaled(Vector3(4, 7, 2)), before.origin))
	await _frames()
	var bounds := geometry.global_transform * geometry.custom_aabb
	_check(badge.global_position.y - badge.size_m.y * 0.5 > bounds.end.y, "badge stays wholly above rotated scaled child geometry during preview")
	_check(badge.global_position.y > first.y, "badge follows increasing object size without reselecting")
	geometry.custom_aabb = AABB(Vector3(-0.5, -1, -0.5), Vector3(1, 2, 1))
	await _frames()
	bounds = geometry.global_transform * geometry.custom_aabb
	_check(badge.global_position.y - badge.size_m.y * 0.5 > bounds.end.y, "badge follows changed geometry bounds without a tree scan")
	_document.preview_transform(_host, before)
	geometry.custom_aabb = AABB(Vector3(-0.5, -0.5, -0.5), Vector3.ONE)
	await _frames()
	_check(badge.global_position.is_equal_approx(first), "restoring transform restores badge placement")
	if DisplayServer.get_name() != "headless":
		var csg := CSGBox3D.new()
		csg.name = "CSGBounds"
		csg.position = Vector3(2, 0, 0)
		_document.add_node(csg, _host, XREDocument.Source.PANEL)
		await _frames(8)
		csg.size = Vector3(3, 12, 3)
		await _frames(8)
		var csg_bounds := csg.global_transform * csg.get_aabb()
		_check(csg_bounds.size.y > 11, "rendered CSG fixture exposes its updated geometric bounds")
		_check(badge.global_position.y - badge.size_m.y * 0.5 > csg_bounds.end.y, "badge follows resized CSG geometry")
		_document.remove_nodes([csg], XREDocument.Source.PANEL)
		await _frames()


## The dashed leader (D-085) runs from the top of [param bounds], where its dot is, up to the pill's bottom edge.
func _check_leader(badge: XREBlueprintBadge, bounds: AABB) -> void:
	var top := Vector3(bounds.get_center().x, bounds.end.y, bounds.get_center().z)
	var leader := badge.get_leader()
	var grown := badge.global_basis.y.length()
	var bottom := badge.global_position - badge.global_basis.y * badge.size_m.y * 0.5
	_check(leader.visible and badge.get_dot().visible and badge.get_dot().global_position.distance_to(top) < 0.001, "the leader's dot sits on top of the object")
	_check((leader.global_transform * Vector3(0, -0.5, 0)).distance_to(top) < 0.001 and (leader.global_transform * Vector3(0, 0.5, 0)).distance_to(bottom) < 0.001,
			"the leader runs from the object up to the pill")
	_check(is_equal_approx(top.distance_to(bottom), XREBlueprintBadge.GAP * grown), "the leader is %.2f m long at full size" % XREBlueprintBadge.GAP)
	var dashes := float((leader.material_override as ShaderMaterial).get_shader_parameter(&"dashes"))
	_check(is_equal_approx(dashes, XREBlueprintBadge.GAP / (XREBlueprintBadge.DASH * 2.0)), "it is dashed: %.1f dashes" % dashes)


## The graph's badge (D-085): over the graph's object, drawn over everything,
## with the graph's name, + (the block palette), the trash (twice: detach and
## close) and × (close). The graph is open for [member _host] on [param path].
func _test_badge_graph(badge: XREBlueprintBadge, path: String) -> void:
	var geometry := _host.get_node("Geometry") as MeshInstance3D
	_check(badge.is_shown() and badge.is_graph() and badge.is_on_top(), "in the graph the badge shows the graph's buttons over everything")
	_check(not badge.get_blueprint_button().is_visible_in_tree() and badge.get_add_button().is_visible_in_tree()
			and badge.get_trash_button().is_visible_in_tree() and badge.get_close_button().is_visible_in_tree(), "+, the trash and × instead of Blueprint")
	_check((badge.get_leader().material_override as ShaderMaterial).render_priority == Material.RENDER_PRIORITY_MAX, "the leader is drawn over the dimmed scene too")
	_check_leader(badge, geometry.global_transform * geometry.custom_aabb)
	_document.features.set_value(XREFeatureSettings.OBJECT_SHORTCUT, XREFeatureSettings.ON)
	await _frames()
	_check(badge.is_shown() and badge.is_graph(), "with the object's shortcut on, the graph keeps its badge (D-088)")
	_document.features.set_value(XREFeatureSettings.OBJECT_SHORTCUT, XREFeatureSettings.OFF)
	await _frames()
	await _click_at(badge, _pixel_of(badge.get_add_button()))
	_check(_service.is_block_palette_shown() and _service.is_open(), "+ opens the block palette")
	_service.close_block_palette()
	await _frames()
	# The trash asks once more: the first click only arms it.
	var trash := _pixel_of(badge.get_trash_button())
	await _click_at(badge, trash)
	_check(badge.is_armed() and _service.is_open() and XREBlueprints.source_path(_host) == path, "the first click on the trash only arms it")
	badge.show_scene("", false)
	badge.show_graph(str(_host.name))
	_check(not badge.is_armed(), "leaving the graph's view disarms it")
	await _click_at(badge, trash)
	await _click_at(badge, trash)
	_check(not _service.is_open() and _host.get_script() == null and not _host.has_meta(&"_xre_blueprint") and FileAccess.file_exists(path),
			"the second click detaches the Blueprint and closes the graph; its file stays")
	_check(badge.is_shown() and not badge.is_graph() and badge.get_blueprint_button().tooltip_text == "Create Blueprint" and not badge.is_on_top(),
			"the badge is the scene's again, for an object without a Blueprint")
	_check(badge.get_message().begins_with("Blueprint deleted"), "and says so over the pill: %s" % badge.get_message())
	var plugin := (_document as XREPluginDocument).get("_plugin") as EditorPlugin
	var manager := plugin.get_undo_redo()
	manager.get_history_undo_redo(manager.get_object_history_id(_host)).undo()
	await _frames()
	_check(XREBlueprints.source_path(_host) == path, "scene undo gives the object its Blueprint back")
	# The history's own undo, unlike Ctrl+Z through the manager, tells the plugin nothing.
	_service.refresh_catalog()
	_check(badge.get_blueprint_button().tooltip_text == "Open Blueprint", "and the badge's button opens it")
	await _click_at(badge, _pixel_of(badge.get_blueprint_button()))
	_check(_service.is_open() and _service.blueprint.path == path and badge.is_graph(), "Blueprint opens the object's graph")
	await _click_at(badge, _pixel_of(badge.get_close_button()))
	_check(not _service.is_open() and XREBlueprints.source_path(_host) == path, "× closes the graph and keeps the Blueprint")
	_check(_service.open_graph(path), "the graph opens again")
	await _frames()
	_aim(Vector3(5, 4, -2))
	await _frames()


func _test_target() -> void:
	_service.add_block("set_property")
	await _frames()
	var id: int = _service.blueprint.graph.nodes.back()["id"]
	await _test_scene_wires(id)
	_service.pick_target()
	_check(_service.get("_target_pick") == id, "Pick Target arms the selected block")
	# The dummy headless renderer has no BVH candidates. A regular editor run
	# exercises the real triangle picker and trigger routing against scene geometry.
	if DisplayServer.get_name() != "headless":
		var geometry := _host.get_node("Geometry") as MeshInstance3D
		geometry.position = Vector3(3, 2, -2)
		await _frames()
		await _click(geometry.global_position + Vector3.BACK * 0.5)
		_check(_service.blueprint.graph.find_node(id)["params"]["target"] == "Geometry", "Pick Target selects real mesh geometry relative to its host")
		_check(_service.get("_target_pick") == -1 and _service.status == "Target selected.", "successful target trigger confirms and disarms picking")
		geometry.position = Vector3(0.7, 0.2, 0)
	_service.delete_block()
	await _frames()
	_check(_service.get("_target_pick") == -1, "removing the armed block cancels target picking")


func _test_scene_wires(id: int) -> void:
	var wires := _service.get("_target_wires") as Array
	_check(wires.size() == 1, "static Target creates one scene connection")
	var wire := wires[0] as XREBlueprints.TargetWire
	_check(wire.id == id and wire.target == _host, "default Target points to the actual graph host")
	var geometry := _host.get_node("Geometry") as MeshInstance3D
	var version := _service.blueprint.history.get_version()
	_check(_service.connect_scene_target(id, geometry), "scene wire chooses an existing geometry target")
	await _frames()
	_check(_service.blueprint.history.get_version() == version + 1 and _service.blueprint.graph.find_node(id)["params"]["target"] == "Geometry", "scene connection stores a relative target in one undo step")
	wire = (_service.get("_target_wires") as Array)[0] as XREBlueprints.TargetWire
	_check(wire.mesh.to_global(wire.mesh.get_point(wire.mesh.get_point_count() - 1)).is_equal_approx(geometry.global_position), "scene curve ends on the cached target anchor")
	var before := geometry.transform
	_document.preview_transform(geometry, Transform3D(before.basis, before.origin + Vector3(0.1, 0.2, 0.3)))
	await _frames()
	_check(wire.mesh.to_global(wire.mesh.get_point(wire.mesh.get_point_count() - 1)).is_equal_approx(geometry.global_position), "scene curve follows a moving target without tree lookup")
	_document.preview_transform(geometry, before)
	_service.blueprint.undo()
	await _frames()
	_check(_service.blueprint.graph.find_node(id)["params"]["target"] == ".", "undo restores the previous static target")
	_service.blueprint.redo()
	await _frames()
	_check((_service.get("_target_wires") as Array)[0].target == geometry, "redo restores the target's visual connection")
	var outsider := Node3D.new()
	var state := _service.blueprint.graph.snapshot()
	_check(not _service.connect_scene_target(id, outsider) and _service.blueprint.graph.snapshot() == state, "outside-scene endpoint cannot mutate the graph")
	outsider.free()
	var light := OmniLight3D.new()
	light.name = "WireFixtureLight"
	light.position = Vector3(2.5, 1, -2.5)
	_document.add_node(light, _host, XREDocument.Source.PANEL)
	await _frames()
	var port := XREBlueprintGraph.target_port(_service.blueprint.graph.find_node(id))
	await _click(_service.canvas.to_global(_service.canvas.port_position(id, port, true)))
	_check(_service.get("_pending_id") == id and _service.get("_pending_hand") == _rig.right_hand, "trigger on Target starts a port-to-scene wire")
	await _click(light.global_position)
	_check(_service.blueprint.graph.find_node(id)["params"]["target"] == "WireFixtureLight" and _service.get("_pending_id") == -1, "trigger on a scene icon completes Target binding and clears preview")
	if DisplayServer.get_name() != "headless":
		var pose := geometry.transform
		_document.preview_transform(geometry, Transform3D(pose.basis, Vector3(3, 2, -2)))
		await _frames(8)
		await _click(_service.canvas.to_global(_service.canvas.port_position(id, port, true)))
		await _click(geometry.global_position + Vector3.BACK * 0.5)
		_check(_service.blueprint.graph.find_node(id)["params"]["target"] == "Geometry" and _service.get("_pending_id") == -1, "Target port also connects to real scene triangles with GPU picking")
		_document.preview_transform(geometry, pose)
		await _frames()
	_service.connect_scene_target(id, _host)
	_document.remove_nodes([light], XREDocument.Source.PANEL)
	await _frames()
	_service.add_block("get_property")
	await _frames()
	var source: int = _service.blueprint.graph.nodes.back()["id"]
	_service.blueprint.perform(_service.blueprint.set_parameter.bind(source, "property", "owner"), &"vr_graph")
	await _frames()
	_check(_service.blueprint.perform(_service.blueprint.connect_blocks.bind(source, 0, id, port), &"vr_graph"), "dynamic object output can still supply the Target port")
	await _frames()
	var hidden := true
	for entry: XREBlueprints.TargetWire in _service.get("_target_wires") as Array:
		if entry.id == id: hidden = false
	_check(hidden, "dynamic Target suppresses the obsolete literal scene wire")
	state = _service.blueprint.graph.snapshot()
	_check(not _service.connect_scene_target(id, _host) and _service.blueprint.graph.snapshot() == state, "scene binding never silently overrides a dynamic Target")
	_service.blueprint.perform(_service.blueprint.remove_blocks.bind([source] as Array[int]), &"vr_graph")
	await _frames()
	_service.select_block(id)


func _test_left_wire(id: int) -> void:
	var source := _service.canvas.to_global(_service.canvas.port_position(id, 0, false))
	_aim(Vector3(5, 4, -2))
	_left.set_pose(&"aim", Transform3D(Basis.IDENTITY, source + Vector3.BACK * 0.4), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_left.set_input(&"trigger", 1.0)
	await _frames()
	_left.set_input(&"trigger", 0.0)
	await _frames()
	_check(_service.get("_pending_hand") == _rig.left_hand, "left trigger can own a wire too")
	_left.invalidate_pose(&"aim")
	await _frames()
	_check(_service.get("_pending_hand") == null and _service.get("_pending_id") == -1, "owner tracking loss cancels the wire")
	_left.set_pose(&"aim", Transform3D(Basis.IDENTITY, Vector3(-5, 0, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	var point := _service.canvas.to_global(_service.canvas.get_block_position(id) + Vector3(0, 0.025, 0))
	_aim(point)
	await _frames()
	var ray := _rig.right_hand.get("_ray") as MeshInstance3D
	var dot := _rig.right_hand.get("_dot") as MeshInstance3D
	_check(dot.visible and -dot.position.z < ray.scale.z, "card contact dot is lifted in front of the hit plane")
	_check(not (dot.material_override as StandardMaterial3D).no_depth_test, "contact dot keeps depth testing")
	var label := XREBlueprintCanvas.label("Test", 22)
	_check(not XREBlueprintCanvas.material(Color.WHITE).no_depth_test and not label.no_depth_test, "graph materials and text respect depth")
	label.free()


## D-051: the plus's menu lists what may follow the card and wires the block
## it adds; pinned to a hand, the next block follows the new one; a wire let
## go in empty space opens the menu for its port; a row pulled out is placed.
func _test_block_menu() -> void:
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph
	_service.add_block("print")
	await _frames()
	var source: int = graph.nodes.back()["id"]
	_service.call("_show_block_palette", source)
	await _frames()
	var menu := _service.block_menu
	var window := _panels.find_window(XREBlueprintPaletteTab)
	_check(window != null and window.tab.is_ancestor_of(menu), "the plus opens the block menu in its window")
	if window != null: await _test_palette_on_top(window, source)
	_check(menu.get_pin().get("type") == XREBlueprintGraph.EXEC and menu.get_pin().get("output") == true, "the menu is filtered by the card's execution output")
	_check(menu.get_chip_titles().has(str(_host.name)) and menu.get_chip_titles().has("Library") and menu.get_chip_titles().has("All"), "chips name the host and the groups")
	menu.choose_chip(menu.get_chip_titles().find("Library"))
	var delay: Array[Dictionary] = menu.get_listed().filter(func(action: Dictionary) -> bool: return action["title"] == "Delay")
	_check(not delay.is_empty(), "the library lists Delay")
	if delay.is_empty(): return
	if window != null: _panels.pin_window(window, XREPanelWindow.Pin.LEFT_HAND)
	menu.action_chosen.emit(delay[0])
	await _frames()
	var delay_id: int = graph.nodes.back()["id"]
	_check(graph.find_node(delay_id)["kind"] == "call" and graph.edges.has({"from": source, "from_port": 0, "to": delay_id, "to_port": 0}), "the block is added wired from the card")
	_check(_service.is_block_palette_shown() and str(menu.get_pin().get("label", "")).begins_with("Delay"), "pinned to a hand, the menu follows the new block")
	menu.choose_chip(menu.get_chip_titles().find("Global"))
	menu.search.text = "print"
	menu.search.text_changed.emit("print")
	var prints: Array[Dictionary] = menu.get_listed().filter(func(action: Dictionary) -> bool: return action["id"] == "global:print")
	_check(not prints.is_empty(), "the search finds a global function")
	if not prints.is_empty():
		menu.action_chosen.emit(prints[0])
		await _frames()
		_check(graph.edges.has({"from": delay_id, "from_port": 0, "to": graph.nodes.back()["id"], "to_port": 0}), "a chain is added in a row: the next block follows Delay's Finished")
	_service.close_block_palette()
	await _frames()
	var blocks := graph.nodes.size()
	_check(_service.click_port(graph.nodes.back()["id"], 0, false), "a wire from the last block")
	_service.call("_open_menu_for_wire", Vector3(0.6, -0.4, 0.05))
	await _frames()
	_check(_service.is_block_palette_shown() and menu.get_pin().get("output") == true, "a wire let go in empty space opens the menu for its port")
	await _test_palette_over_focus(graph.nodes.back()["id"])
	menu.choose_chip(menu.get_chip_titles().find("Native"))
	var branch: Array[Dictionary] = menu.get_listed().filter(func(action: Dictionary) -> bool: return action["id"] == "native:branch")
	if not branch.is_empty():
		menu.action_chosen.emit(branch[0])
		await _frames()
	var branch_id: int = graph.nodes.back()["id"]
	_check(graph.nodes.size() == blocks + 1 and graph.find_node(branch_id)["kind"] == "branch" and int(_service.get("_pending_id")) == -1, "the block is added where the wire was let go, and the wire is done")
	_check(absf(float(graph.find_node(branch_id).get("vr_depth", 0.0)) - 0.05) < 0.001, "at that point's depth")
	_service.close_block_palette()
	_service.call("_drag_from_menu", branch[0] if not branch.is_empty() else {})
	await _frames()
	_check(graph.nodes.size() == blocks + 2 and _service.get("_ghost") == null, "a row pulled out of the menu is placed where its trigger is let go")
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-093: adding blocks without the keyboard. Each setting's variants: the
## next-block suggestions at a wire let go and at a plus, More… and a click
## away; the palette's tiles, task chips and ring; the copy button. Where a
## block was picked is the name of its operation in the log.
func _test_d093() -> void:
	var features := _document.features
	for key: StringName in [XREFeatureSettings.BLOCK_PALETTE, XREFeatureSettings.PALETTE_GROUPS, XREFeatureSettings.NEXT_SUGGESTIONS, XREFeatureSettings.BLOCK_COPY]:
		_check(features.get_value(key) == BASELINE[key], "%s starts at the list as it was" % key)
	_check(XREFeatureSettings.get_default(XREFeatureSettings.BLOCK_PALETTE) == XREFeatureSettings.RING and XREFeatureSettings.get_default(XREFeatureSettings.PALETTE_GROUPS) == XREFeatureSettings.SOURCES
			and XREFeatureSettings.get_default(XREFeatureSettings.NEXT_SUGGESTIONS) == XREFeatureSettings.OFF and XREFeatureSettings.get_default(XREFeatureSettings.BLOCK_COPY) == XREFeatureSettings.ON,
			"the defaults are the author's picks (D-097): the ring, chips by source, no suggestions, the copy button")
	_check(XREFeatureSettings.get_default(XREFeatureSettings.NODE_STYLE) == XREFeatureSettings.ARCHETYPES and XREFeatureSettings.get_default(XREFeatureSettings.NODE_SHRINK) == XREFeatureSettings.SYSTEM
			and XREFeatureSettings.get_default(XREFeatureSettings.NODE_HEADING) == XREFeatureSettings.MEMBER and XREFeatureSettings.get_default(XREFeatureSettings.COMPOSITE_VALUES) == XREFeatureSettings.SPLIT
			and XREFeatureSettings.get_default(XREFeatureSettings.LINK_CREATE) == XREFeatureSettings.WIRE_MENU and XREFeatureSettings.get_default(XREFeatureSettings.AUTO_LINK) == XREFeatureSettings.ON,
			"the defaults are the author's picks (D-114): archetypes, + System, Member, Split, the wire menu, auto link")
	_check(XREFeatureSettings.get_default(XREFeatureSettings.PIN_PLACE) == XREFeatureSettings.BOTH_FACES and XREFeatureSettings.get_default(XREFeatureSettings.CARD_MIRROR) == XREFeatureSettings.ON
			and XREFeatureSettings.get_default(XREFeatureSettings.SIGN_PORTS) == XREFeatureSettings.RIM and XREFeatureSettings.get_default(XREFeatureSettings.EXEC_ARROWS) == XREFeatureSettings.RUNNING
			and XREFeatureSettings.get_default(XREFeatureSettings.DATA_ARROWS) == XREFeatureSettings.AT_END and XREFeatureSettings.get_default(XREFeatureSettings.ARROW_STYLE) == XREFeatureSettings.OPEN,
			"the defaults are the author's picks (D-133): both faces, card mirror, the rim, running and end arrows, open ones")
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph
	var menu := _service.block_menu
	var hand := _rig.right_hand
	_service.add_block("print")
	await _frames()
	var source: int = graph.nodes.back()["id"]
	# Suggestions at a wire let go in empty space.
	_check(_document.set_feature(XREFeatureSettings.NEXT_SUGGESTIONS, XREFeatureSettings.ON, XREDocument.Source.PANEL) and _operations.back() == &"set_feature", "suggestions switch on, logged")
	_check(_service.click_port(source, 0, false), "a wire from Print's Then")
	_service.call("_open_menu_for_wire", Vector3(0.6, -0.4, 0.05))
	await _frames()
	var choice := _service.get("_choice") as XREBlueprintPetals
	var shown := choice.get_shown()
	_check(choice.is_open() and not (choice is XREBlueprintRing) and not _service.is_block_palette_shown(), "a wire let go opens the suggestions, not the palette")
	_check(shown.size() == XREBlueprints.SUGGESTIONS + 1 and (shown.back() as Dictionary).get("more", false) and shown[0].has("action"), "five blocks and More…: %s" % [shown.map(func(item: Dictionary) -> String: return str(item["text"]))])
	_check(shown.slice(0, XREBlueprints.SUGGESTIONS).all(func(item: Dictionary) -> bool: return XREBlueprintActions.fits_pin(item["action"], XREBlueprintGraph.EXEC, true)), "each fits the wire")
	var blocks := graph.nodes.size()
	_service.call("_choose_petal", choice, shown[0], hand)
	await _frames()
	var added: int = graph.nodes.back()["id"]
	_check(graph.nodes.size() == blocks + 1 and graph.edges.has({"from": source, "from_port": 0, "to": added, "to_port": 0}) and int(_service.get("_pending_id")) == -1 and not choice.is_open(),
			"a suggestion is added wired where the wire was let go, and the petals go")
	_check(&"add_suggested_block" in _operations, "the log says it came from a suggestion")
	_check(_service.click_port(source, 0, false) or _service.click_port(added, 0, false), "another wire")
	_service.call("_open_menu_for_wire", Vector3(0.7, -0.4, 0.05))
	await _frames()
	shown = choice.get_shown()
	_service.call("_choose_petal", choice, shown.back(), hand)
	await _frames()
	_check(_service.is_block_palette_shown() and not choice.is_open() and int(_service.get("_pending_id")) >= 0, "More… opens the palette for the same wire")
	_service.close_block_palette()
	_service.cancel_connection()
	await _frames()
	_check(_service.click_port(added, 0, false), "a wire again")
	_service.call("_open_menu_for_wire", Vector3(0.7, -0.4, 0.05))
	await _frames()
	_service.call("_close_inputs")
	await _frames()
	_check(not choice.is_open() and int(_service.get("_pending_id")) == -1 and not bool(_service.get("_menu_at_point")), "a click away takes the suggestions and their wire away")
	_service.call("_show_block_palette", added)
	await _frames()
	_check(choice.is_open() and not _service.is_block_palette_shown() and choice.get_shown()[0].has("action"), "the plus offers suggestions too")
	_check(_document.set_feature(XREFeatureSettings.NEXT_SUGGESTIONS, XREFeatureSettings.OFF, XREDocument.Source.PANEL) and not choice.is_open(), "switched off, suggestions open close")
	# Tiles over the list.
	_check(_document.set_feature(XREFeatureSettings.BLOCK_PALETTE, XREFeatureSettings.TILES, XREDocument.Source.PANEL), "the palette switches to tiles")
	_service.call("_show_block_palette", added)
	await _frames()
	var tiles := menu.get_tiles()
	_check(_service.is_block_palette_shown() and tiles.size() == XREBlueprintActionMenu.TILE_COUNT and (menu.get_node("Tiles") as Control).visible, "the palette has its tiles")
	_check(tiles.all(func(action: Dictionary) -> bool: return XREBlueprintActions.fits_pin(action, XREBlueprintGraph.EXEC, true)), "tiles fit the plus's wire")
	blocks = graph.nodes.size()
	((menu.get_node("Tiles") as Node).get_child(0) as Button).pressed.emit()
	await _frames()
	_check(graph.nodes.size() == blocks + 1 and &"add_block_from_tile" in _operations, "a tile adds its block, logged as from a tile")
	_service.close_block_palette()
	# Chips by task.
	_check(_document.set_feature(XREFeatureSettings.PALETTE_GROUPS, XREFeatureSettings.TASKS, XREDocument.Source.PANEL), "the chips switch to tasks")
	_check(menu.get_chip_titles()[0] == "Events" and menu.get_chip_titles().has("Move") and menu.get_chip_titles()[-1] == "All", "the chips are the task groups")
	_document.set_feature(XREFeatureSettings.PALETTE_GROUPS, XREFeatureSettings.SOURCES, XREDocument.Source.PANEL)
	_check(menu.get_chip_titles().has("Library"), "and back to the sources")
	# The ring.
	_check(_document.set_feature(XREFeatureSettings.BLOCK_PALETTE, XREFeatureSettings.RING, XREDocument.Source.PANEL) and menu.get_tiles().is_empty(), "the palette switches to the ring, without tiles")
	_service.add_block("print")
	await _frames()
	var free: int = graph.nodes.back()["id"]
	_service.call("_show_block_palette", free)
	await _frames()
	choice = _service.get("_choice") as XREBlueprintPetals
	var ring := choice as XREBlueprintRing
	_check(ring != null and ring.is_open() and not _service.is_block_palette_shown(), "the plus opens the ring, not the window")
	if ring == null: return
	shown = ring.get_shown()
	var arc: Array = shown.filter(func(item: Dictionary) -> bool: return item.has("sector") and int(item["sector"]) >= XREBlueprintRing.ORDER.size()).map(func(item: Dictionary) -> String: return str(item["text"]))
	_check(shown[0].get("list", false) and shown.slice(1, 1 + XREBlueprintRing.ORDER.size()).map(func(item: Dictionary) -> String: return str(item["text"])) == XREBlueprintRing.ORDER,
			"the ring has its middle, the seven general groups and Object (D-096)")
	_check(arc.has("Move") and not arc.has("Object") and not arc.has("Sound"), "over it, the object's other groups it has: %s" % [arc])
	_check(XREBlueprintRing.ORDER[0] == "Object" and is_equal_approx(XREBlueprintRing.sector_angle(0), PI * 0.5), "Object is at the top, under the middle of the arc (D-097)")
	var object_group := XREBlueprintRing.ORDER.size() + arc.find("Move")
	var arc_angle := PI * 0.5 + XREBlueprintRing.BAND_STEP * (arc.size() * 0.5 - arc.find("Move") - 0.5)
	var arc_at := ring.global_transform * (Vector3(cos(arc_angle), sin(arc_angle), 0.0) * (XREBlueprintRing.BAND_IN + XREBlueprintRing.BAND_OUT) * 0.5)
	var arc_front := ring.global_basis.z.normalized()
	_check(ring.intersect_ray(arc_at + arc_front * 0.4, -arc_front, 1.0) >= 0 and ring.get_hit().get("sector", -1) == object_group, "the ray picks a group of the arc")
	ring.hover_hit()
	_check(ring.get_open_sector() == "Move" and ring.get_shown().size() > shown.size(), "and shows its blocks over the arc")
	var column := ring.get_node("Column") as Node3D
	var pills: Array[Vector3] = []
	for item: Dictionary in ring.get_shown().slice(1 + XREBlueprintRing.ORDER.size() + arc.size()): pills.append(ring.item_position(item))
	var middle := (pills[0] + pills[-1]) * 0.5 if not pills.is_empty() else Vector3.ZERO
	var head := _rig.camera.global_position
	_check(column != null and not pills.is_empty() and absf(column.global_basis.y.normalized().dot((middle - head).normalized())) < 0.05 and column.basis.y.z > 0.0,
			"the column over the arc leans toward the head, square to the line of sight to its middle (D-098): dot %.3f, lean %.3f" % [column.global_basis.y.normalized().dot((middle - head).normalized()) if column != null else NAN, column.basis.y.z if column != null else NAN])
	if not pills.is_empty():
		_check(ring.intersect_ray(head, (pills[-1] - head).normalized(), 5.0) >= 0 and ring.get_hit().has("action"), "the ray picks a block of the leaning column")
	var sortings: Array[float] = []
	var labels_free := true
	var parts: Array[Node] = [ring]
	while not parts.is_empty():
		var part: Node = parts.pop_back()
		parts.append_array(part.get_children())
		if part is MeshInstance3D: sortings.append((part as MeshInstance3D).sorting_offset)
		if part is Label3D and not (part as Label3D).no_depth_test: labels_free = false
	_check(not sortings.is_empty() and sortings.min() >= XREBlueprints.CHOICE_SORTING and XREBlueprints.CHOICE_SORTING > XREBlueprintFocus.TOP_SORTING and labels_free,
			"the ring is drawn over everything, over the cards in Front focus too (D-096)")
	_check(shown.filter(func(item: Dictionary) -> bool: return item.has("sector") and not item["enabled"]).map(func(item: Dictionary) -> String: return str(item["text"])).has("Events"),
			"a group with no block for the wire, Events after an execution output, is dim")
	var flow := XREBlueprintRing.ORDER.find("Flow")
	var angle := XREBlueprintRing.sector_angle(flow)
	var at := ring.global_transform * (Vector3(cos(angle), sin(angle), 0.0) * (XREBlueprintRing.DISC + XREBlueprintRing.OUTER) * 0.5)
	var front := ring.global_basis.z.normalized()
	_check(ring.intersect_ray(at + front * 0.4, -front, 1.0) >= 0 and ring.get_hit().get("sector", -1) == flow, "the ray picks a group")
	ring.hover_hit()
	_check(ring.get_open_sector() == "Flow" and ring.get_shown().size() > shown.size(), "the ray on a group shows its blocks")
	var delay: Array[Dictionary] = ring.get_shown().filter(func(item: Dictionary) -> bool: return item.has("action") and item["action"]["title"] == "Delay")
	_check(not delay.is_empty(), "Flow has Delay")
	blocks = graph.nodes.size()
	if not delay.is_empty():
		_service.call("_choose_petal", ring, delay[0], hand)
		await _frames()
		_check(graph.nodes.size() == blocks + 1 and graph.edges.has({"from": free, "from_port": 0, "to": graph.nodes.back()["id"], "to_port": 0}) and not ring.is_open(), "a block of the ring is added wired from the card")
		_check(&"add_block_from_ring" in _operations, "logged as from the ring")
	_service.call("_show_block_palette", added)
	await _frames()
	_service.call("_choose_petal", ring, ring.get_shown()[0], hand)
	await _frames()
	_check(_service.is_block_palette_shown() and not ring.is_open(), "the ring's middle opens the list with its search")
	_service.close_block_palette()
	# D-094: More… opens the ring where it was clicked, the ring's Search… the window; the wire waits meanwhile.
	_document.set_feature(XREFeatureSettings.NEXT_SUGGESTIONS, XREFeatureSettings.ON, XREDocument.Source.PANEL)
	_service.add_block("print")
	await _frames()
	var spare: int = graph.nodes.back()["id"]
	_check(_service.click_port(spare, 0, false), "a wire for the ring")
	var let_go := Vector3(0.5, -0.3, 0.05)
	_service.call("_open_menu_for_wire", let_go)
	await _frames()
	var fan := _service.get("_choice") as XREBlueprintPetals
	var preview := _service.canvas.get("_preview") as XREGraphWire
	_service.call("_preview_connection", _service.canvas.to_global(Vector3(-0.4, 0.3, 0.2)))
	_check(preview.get_point(preview.get_point_count() - 1).distance_to(let_go) < 0.005, "with the suggestions open the wire ends where it was let go, wherever the ray is")
	var more: Dictionary = fan.get_shown().back()
	var more_at := fan.item_position(more)
	_service.call("_choose_petal", fan, more, hand)
	await _frames()
	ring = _service.get("_choice") as XREBlueprintRing
	_check(ring != null and ring.is_open() and ring.global_position.distance_to(more_at) < 0.001, "More… opens the ring where it was clicked")
	_service.call("_preview_connection", _service.canvas.to_global(Vector3(-0.4, 0.3, 0.2)))
	_check(preview.visible and preview.get_point(preview.get_point_count() - 1).distance_to(let_go) < 0.005, "and the wire still waits there")
	if ring != null:
		_service.call("_choose_petal", ring, ring.get_shown()[0], hand)
		await _frames()
	var list := _panels.find_window(XREBlueprintPaletteTab)
	_check(list != null and list.global_position.distance_to(more_at) < XREBlueprints.PARAMETERS_LIFT + 0.002, "the ring's Search… opens the window there")
	_service.call("_preview_connection", _service.canvas.to_global(Vector3(-0.4, 0.3, 0.2)))
	_check(preview.get_point(preview.get_point_count() - 1).distance_to(let_go) < 0.005 and int(_service.get("_pending_id")) == spare, "the wire waits on the window too")
	_service.call("_cancel_dropped_wire")
	await _frames()
	_check(not _service.is_block_palette_shown() and int(_service.get("_pending_id")) == -1 and not preview.visible, "a click elsewhere takes the window and the wire away")
	_document.set_feature(XREFeatureSettings.BLOCK_PALETTE, XREFeatureSettings.LIST, XREDocument.Source.PANEL)
	_check(_service.click_port(spare, 0, false), "a wire for the list")
	_service.call("_open_menu_for_wire", let_go)
	await _frames()
	more = fan.get_shown().back()
	more_at = fan.item_position(more)
	_service.call("_choose_petal", fan, more, hand)
	await _frames()
	list = _panels.find_window(XREBlueprintPaletteTab)
	_check(list != null and list.global_position.distance_to(more_at) < XREBlueprints.PARAMETERS_LIFT + 0.002, "with the list, More… opens the window where it was clicked")
	_service.call("_cancel_dropped_wire")
	_document.set_feature(XREFeatureSettings.NEXT_SUGGESTIONS, XREFeatureSettings.OFF, XREDocument.Source.PANEL)
	await _frames()
	_document.set_feature(XREFeatureSettings.BLOCK_PALETTE, XREFeatureSettings.LIST, XREDocument.Source.PANEL)
	# The copy button.
	_check(_document.set_feature(XREFeatureSettings.BLOCK_COPY, XREFeatureSettings.ON, XREDocument.Source.PANEL), "the copy button switches on")
	await _frames()
	var card := _card(source)
	_check(card != null and card.copy != null, "cards have the copy button")
	if card == null or card.copy == null: return
	var button := card.node.global_transform * card.copy_point
	var facing := card.node.global_basis.z.normalized()
	_service.canvas.intersect_ray(button + facing * 0.4, -facing, 1.0)
	_check(_service.canvas.get_hit_copy() and _service.canvas.get_hit_id() == source and not _service.canvas.get_hit_delete(), "the ray hits the copy button")
	blocks = graph.nodes.size()
	var edges := graph.edges.size()
	var version := _service.blueprint.history.get_version()
	# The trigger let go at once: the drag ends as it starts.
	_service.call("_start_copy", source, hand, button)
	await _frames()
	var copy: Dictionary = graph.nodes.back()
	var original := graph.find_node(source)
	_check(graph.nodes.size() == blocks + 1 and graph.edges.size() == edges and copy["kind"] == original["kind"] and copy["params"] == original["params"], "a click copies the block, without its wires")
	_check((copy["position"] as Vector2).x == (original["position"] as Vector2).x and (copy["position"] as Vector2).y > (original["position"] as Vector2).y, "beside it, below")
	_check(_service.blueprint.history.get_version() == version + 1 and &"duplicate_block" in _operations, "one undo step, Duplicate Block in the log")
	# Held, the copy follows the ray until the trigger lets go.
	_aim(Vector3(5, 4, -2))
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_service.call("_start_copy", source, hand, button)
	_aim(Vector3(4.6, 4.2, -2))
	await _frames()
	var ghost := _service.get("_ghost") as Node3D
	_check(ghost != null and graph.nodes.size() == blocks + 1, "the copy's stand-in follows the ray while the trigger is held")
	var dropped := _service.canvas.to_local(ghost.global_position) if ghost != null else Vector3.ZERO
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(graph.nodes.size() == blocks + 2 and absf(float((graph.nodes.back() as Dictionary).get("vr_depth", 0.0)) - dropped.z) < 0.001, "pulled away, the copy goes where it is let go")
	_document.set_feature(XREFeatureSettings.BLOCK_COPY, XREFeatureSettings.OFF, XREDocument.Source.PANEL)
	await _frames()
	_check(_card(source) != null and _card(source).copy == null, "switched off, the button goes")
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## Where the ray takes a card by its title, as a grab does.
func _card_point(id: int) -> Vector3:
	return _service.canvas.to_global(_service.canvas.get_block_transform(id).origin + Vector3(0, 0.025, 0))


## D-122: with Add to selection on Other grip, the left grip held in empty
## space makes the right trigger add a card to the selection or take it out;
## the right grip on a selected card moves them all, the copy button copies
## them with the wires between them, X deletes them: one undo step each.
func _test_d117() -> void:
	var graph := _service.blueprint.graph
	var history := _service.blueprint.history.get_version()
	var hand := _rig.right_hand
	_check(XREFeatureSettings.get_default(XREFeatureSettings.SELECT_ADD) == XREFeatureSettings.GRIP, "blocks are added with the other grip by default (D-131)")
	var ids: Array[int] = []
	for index: int in 3:
		_service.add_block("print")
		await _frames()
		ids.append(int((graph.nodes.back() as Dictionary)["id"]))
	var start := _service.canvas.get_block_position(ids[0]) + Vector3(0, 0.6, 0.1)
	for index: int in 3:
		_service.canvas.preview_move(ids[index], start + Vector3(0.45 * index, 0, 0))
	_check(_service.canvas.commit_moves(_service.blueprint, ids), "three Print blocks are set apart in one step")
	_check(_service.blueprint.perform(_service.blueprint.connect_blocks.bind(ids[0], 0, ids[1], 0), &"vr_graph"), "a wire joins the first two")
	await _frames()
	_document.set_feature(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.GRIP, XREDocument.Source.PANEL)
	_service.select_block(ids[0])
	_left.set_pose(&"aim", Transform3D(Basis.IDENTITY, Vector3(-5, 0, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_left.set_input(&"grip", 1.0)
	await _frames()
	await _click(_card_point(ids[1]))
	_check(_service.get_selected_blocks() == [ids[0], ids[1]], "the left grip held in empty space, the trigger adds a card: %s" % [_service.get_selected_blocks()])
	_check(not _service.is_parameters_shown(), "with two cards selected, the parameters window is closed")
	await _click(_card_point(ids[2]))
	await _click(_card_point(ids[2]))
	_check(_service.get_selected_blocks() == [ids[0], ids[1]], "the trigger on a selected card takes it out: %s" % [_service.get_selected_blocks()])
	# With Defocus on Dim, the ray on one card darkens the others, but not a selected one.
	var canvas := _service.canvas
	var modes := canvas.get_focus_modes()
	canvas.set_focus_modes(XREFeatureSettings.ON, XREFeatureSettings.DIM)
	canvas.set_focus(Vector3i(ids[1], -1, -1))
	_check(canvas.focus_state(ids[1]) == XREBlueprintFocus.FOCUSED and canvas.focus_state(ids[0]) == XREBlueprintFocus.NORMAL
			and canvas.focus_state(ids[2]) == XREBlueprintFocus.OUT, "out of focus, a selected card keeps its look, the others are darker")
	canvas.select_block(ids[2])
	_check(canvas.focus_state(ids[2]) == XREBlueprintFocus.NORMAL and canvas.focus_state(ids[0]) == XREBlueprintFocus.OUT,
			"selecting a card out of focus lights it up again, and the one let go of goes dark")
	canvas.select_blocks(_service.get_selected_blocks())
	canvas.set_focus(Vector3i(-1, -1, -1))
	_check(canvas.focus_state(ids[0]) == XREBlueprintFocus.NORMAL and canvas.focus_state(ids[2]) == XREBlueprintFocus.OUT,
			"with the ray in the air, a selection keeps the rest darker (D-129)")
	canvas.select_block(-1)
	_check(canvas.focus_state(ids[2]) == XREBlueprintFocus.NORMAL, "with nothing selected, nothing is darker")
	canvas.select_blocks(_service.get_selected_blocks())
	canvas.set_focus_modes(modes[0], modes[1])
	await _click(_card_point(ids[2]))
	_check(_service.get_selected_blocks() == [ids[0], ids[1], ids[2]], "and adds it back: %s" % [_service.get_selected_blocks()])
	# D-123: in the open graph the counter tells the blocks, with the plus while the left grip adds.
	_document.features.set_value(XREFeatureSettings.SELECTION_COUNTER, XREFeatureSettings.ON)
	var counter := XRESelectionCounter.new(_document, _rig, null, _service)
	add_child(counter)
	await _frames()
	_check(counter.get_label().visible and counter.get_label().text == "+ 3 blocks", "the counter tells the selected blocks, with the plus: %s" % counter.get_label().text)
	_left.set_input(&"grip", 0.0)
	await _frames()
	_check(counter.get_label().text == "3 blocks", "the left grip let go, no plus: %s" % counter.get_label().text)
	counter.queue_free()
	_document.features.set_value(XREFeatureSettings.SELECTION_COUNTER, XREFeatureSettings.OFF)
	# The right grip on the second card moves all three.
	var starts: Array[Vector3] = []
	for id: int in ids: starts.append(_service.canvas.get_block_position(id))
	var places: Array[Vector2] = []
	for id: int in ids: places.append(graph.find_node(id)["position"])
	var version := _service.blueprint.history.get_version()
	var grab := _card_point(ids[1])
	_aim(grab)
	_right.set_input(&"grip", 1.0)
	await _frames()
	var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
	_check(pointer.block == ids[1] and pointer.group == [ids[0], ids[2]], "the grip on a selected card carries the others: %s" % [pointer.group])
	_aim(grab + Vector3(0.1, 0.05, 0))
	await _frames()
	var shift := _service.canvas.get_block_position(ids[1]) - starts[1]
	_check(shift.length() > 0.01, "the held card follows the hand: %s" % shift)
	for index: int in [0, 2]:
		_check((_service.canvas.get_block_position(ids[index]) - starts[index]).is_equal_approx(shift), "card %d moves with it" % index)
	_check(_service.blueprint.history.get_version() == version, "nothing is recorded while they are held")
	_right.set_input(&"grip", 0.0)
	await _frames()
	_check(_service.blueprint.history.get_version() == version + 1, "letting go moves them in one undo step")
	for index: int in 3:
		_check(graph.find_node(ids[index])["position"] != places[index], "block %d has its new place in the graph" % index)
	_check(_service.get_selected_blocks() == [ids[0], ids[1], ids[2]], "and stays selected")
	# The copy button of a selected card copies all three and the wire between two of them.
	_document.set_feature(XREFeatureSettings.BLOCK_COPY, XREFeatureSettings.ON, XREDocument.Source.PANEL)
	await _frames()
	var card := _card(ids[0])
	_check(card != null and card.copy != null, "cards have the copy button")
	if card == null or card.copy == null: return
	var blocks := graph.nodes.size()
	var edges := graph.edges.size()
	version = _service.blueprint.history.get_version()
	_aim(Vector3(5, 4, -2))
	await _frames()
	_service.call("_start_copy", ids[0], hand, card.node.global_transform * card.copy_point)
	await _frames()
	var copies := _service.get_selected_blocks()
	_check(graph.nodes.size() == blocks + 3 and graph.edges.size() == edges + 1, "a click copies the three blocks and the wire between two of them")
	_check(_service.blueprint.history.get_version() == version + 1 and &"duplicate_blocks" in _operations, "one undo step, Duplicate Blocks in the log")
	_check(copies.size() == 3 and not ids.any(func(id: int) -> bool: return copies.has(id)), "the copies are selected, not the originals: %s" % [copies])
	if copies.size() == 3:
		var below := (graph.find_node(copies[0])["position"] as Vector2) - (graph.find_node(ids[0])["position"] as Vector2)
		_check(is_zero_approx(below.x) and below.y > 0.0, "let go at once, the copies go below the originals: %s" % below)
		var wired := graph.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == copies[0] and edge["to"] == copies[1])
		_check(wired, "the copied wire joins the copies")
	# X deletes the three copies.
	version = _service.blueprint.history.get_version()
	_left.set_input(&"ax_button", true)
	await _frames()
	_left.set_input(&"ax_button", false)
	await _frames()
	_check(graph.nodes.size() == blocks and _service.blueprint.history.get_version() == version + 1, "X deletes every selected block in one undo step")
	_check(_service.get_selected_blocks().is_empty(), "and nothing is selected")
	# Replace: the trigger replaces the selection, though the left grip is held.
	_document.set_feature(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.REPLACE, XREDocument.Source.PANEL)
	_document.set_feature(XREFeatureSettings.BLOCK_COPY, XREFeatureSettings.OFF, XREDocument.Source.PANEL)
	_service.select_block(ids[0])
	_left.set_input(&"grip", 1.0)
	await _frames()
	await _click(_card_point(ids[1]))
	_check(_service.get_selected_blocks() == [ids[1]], "with Replace, the trigger selects one card: %s" % [_service.get_selected_blocks()])
	_left.set_input(&"grip", 0.0)
	_service.select_block(-1)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-124: with Select area on Brush, the trigger held and swept over the cards
## selects every card the ray crossed when it lets go; the cards of the stroke
## keep their look out of focus, as selected ones (D-122); with the left grip
## held in empty space, a stroke adds.
func _test_d119() -> void:
	var graph := _service.blueprint.graph
	var canvas := _service.canvas
	var features := _document.features
	var history := _service.blueprint.history.get_version()
	var ids: Array[int] = []
	for index: int in 3:
		_service.add_block("print")
		await _frames()
		ids.append(int((graph.nodes.back() as Dictionary)["id"]))
	var start := canvas.get_block_position(ids[0]) + Vector3(0, 0.6, 0.1)
	for index: int in 3:
		canvas.preview_move(ids[index], start + Vector3(0.45 * index, 0, 0))
	canvas.commit_moves(_service.blueprint, ids)
	features.set_value(XREFeatureSettings.SELECT_AREA, XREFeatureSettings.BRUSH)
	features.set_value(XREFeatureSettings.FOCUS, XREFeatureSettings.ON)
	features.set_value(XREFeatureSettings.DEFOCUS, XREFeatureSettings.DIM)
	_service.select_block(-1)
	_aim(_card_point(ids[0]))
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(_service.get_selected_blocks().is_empty(), "while the trigger is held, nothing is selected yet")
	_aim(_card_point(ids[1]))
	await _frames()
	_check(canvas.focus_state(ids[1]) == XREBlueprintFocus.FOCUSED and canvas.focus_state(ids[0]) == XREBlueprintFocus.NORMAL
			and canvas.focus_state(ids[2]) == XREBlueprintFocus.OUT,
			"a card the stroke crossed keeps its look out of focus; one it hasn't is darker")
	_aim(_card_point(ids[2]))
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(_service.get_selected_blocks() == ids, "letting go selects every card the ray crossed: %s" % [_service.get_selected_blocks()])
	_check(not _service.is_parameters_shown(), "several, without the parameters window")
	await _click(_card_point(ids[1]))
	_check(_service.get_selected_blocks() == [ids[1]], "a click is a stroke of one card: %s" % [_service.get_selected_blocks()])
	# D-132: a click again on the one card selected lets it go; on another, selects that one.
	await _click(_card_point(ids[1]))
	_check(_service.get_selected_blocks().is_empty(), "a click on the one card selected lets it go: %s" % [_service.get_selected_blocks()])
	await _click(_card_point(ids[1]))
	_check(_service.get_selected_blocks() == [ids[1]], "a click selects it again")
	features.set_value(XREFeatureSettings.SELECT_AREA, XREFeatureSettings.OFF)
	await _click(_card_point(ids[1]))
	_check(_service.get_selected_blocks().is_empty(), "without a brush too: %s" % [_service.get_selected_blocks()])
	await _click(_card_point(ids[1]))
	_check(_service.get_selected_blocks() == [ids[1]], "and again it selects it")
	features.set_value(XREFeatureSettings.SELECT_AREA, XREFeatureSettings.BRUSH)
	# The left grip held in empty space: the stroke adds, from the card the trigger added.
	features.set_value(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.GRIP)
	_service.select_block(ids[0])
	_left.set_pose(&"aim", Transform3D(Basis.IDENTITY, Vector3(-5, 0, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_left.set_input(&"grip", 1.0)
	_aim(_card_point(ids[1]))
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(_service.get_selected_blocks() == [ids[0], ids[1]], "the trigger adds the card at once: %s" % [_service.get_selected_blocks()])
	_aim(_card_point(ids[2]))
	await _frames()
	_aim(_card_point(ids[1]))
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(_service.get_selected_blocks() == ids, "the stroke adds what it crossed and leaves the first card in: %s" % [_service.get_selected_blocks()])
	_left.set_input(&"grip", 0.0)
	features.set_value(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.REPLACE)
	features.set_value(XREFeatureSettings.SELECT_AREA, XREFeatureSettings.OFF)
	features.set_value(XREFeatureSettings.FOCUS, BASELINE[XREFeatureSettings.FOCUS])
	features.set_value(XREFeatureSettings.DEFOCUS, BASELINE[XREFeatureSettings.DEFOCUS])
	_service.select_block(-1)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-125: with Select area on Box, the trigger in the graph's empty space
## draws a rectangle on its plane; letting go selects the cards whose middle
## is in it; a click there lets go of the selected blocks.
func _test_d120() -> void:
	var graph := _service.blueprint.graph
	var canvas := _service.canvas
	var features := _document.features
	var history := _service.blueprint.history.get_version()
	var ids: Array[int] = []
	for index: int in 3:
		_service.add_block("print")
		await _frames()
		ids.append(int((graph.nodes.back() as Dictionary)["id"]))
	var start := canvas.get_block_position(ids[0]) + Vector3(0, 0.6, 0.1)
	for index: int in 3:
		canvas.preview_move(ids[index], start + Vector3(0.45 * index, 0, 0))
	canvas.commit_moves(_service.blueprint, ids)
	features.set_value(XREFeatureSettings.SELECT_AREA, XREFeatureSettings.BOX)
	_service.select_block(-1)
	var normal := canvas.global_basis.z.normalized()
	var first := canvas.get_block_position(ids[0])
	var second := canvas.get_block_position(ids[1])
	var corner := canvas.to_global(Vector3(first.x - 0.35, first.y - 0.25, 0.0))
	_aim_from(corner, normal)
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
	_check(pointer.boxing and _rig.right_hand.get_claimant() == _service, "the trigger in the graph's empty space starts a box, the hand the graph's")
	_aim_from(canvas.to_global(Vector3(second.x + 0.05, second.y + 0.25, 0.0)), normal)
	await _frames()
	_check((_service.get_node(^"SelectionBox") as XREBoundsBox).visible and _service.get_selected_blocks().is_empty(),
			"while the trigger is held, the box is drawn and nothing is selected yet")
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(_service.get_selected_blocks() == [ids[0], ids[1]], "letting go selects the cards whose middle is in the box: %s" % [_service.get_selected_blocks()])
	_check(not (_service.get_node(^"SelectionBox") as XREBoundsBox).visible, "and the box goes")
	_aim_from(corner, normal)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(_service.get_selected_blocks().is_empty(), "a click in the graph's empty space lets go of them: %s" % [_service.get_selected_blocks()])
	features.set_value(XREFeatureSettings.SELECT_AREA, XREFeatureSettings.OFF)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-126: with Copy outer wires on, a block's copy keeps the data wire into it
## from a block not copied, from the same output; an execution wire stays with
## the original. Off, the copy has no wires, as before.
func _test_d121() -> void:
	var graph := _service.blueprint.graph
	var features := _document.features
	var history := _service.blueprint.history.get_version()
	var hand := _rig.right_hand
	_check(XREFeatureSettings.get_default(XREFeatureSettings.COPY_OUTER_WIRES) == XREFeatureSettings.OFF, "outer wires aren't copied by default")
	var made: Array[int] = []
	for kind: String in ["value", "delay", "print"]:
		_service.add_block(kind)
		await _frames()
		made.append(int((graph.nodes.back() as Dictionary)["id"]))
	var feeder := made[0]
	var waiter := made[1]
	var printer := made[2]
	_check(_service.blueprint.connect_blocks(feeder, 0, waiter, graph.input_port(graph.find_node(waiter), "seconds")), "a value feeds the delay's seconds")
	_check(_service.blueprint.connect_blocks(printer, 0, waiter, 0), "and Print's Then runs it")
	features.set_value(XREFeatureSettings.BLOCK_COPY, XREFeatureSettings.ON)
	features.set_value(XREFeatureSettings.COPY_OUTER_WIRES, XREFeatureSettings.ON)
	await _frames()
	var card := _card(waiter)
	_check(card != null and card.copy != null, "the delay has the copy button")
	if card == null or card.copy == null: return
	var edges := graph.edges.size()
	var before := graph.nodes.map(func(block: Dictionary) -> int: return int(block["id"]))
	_aim(Vector3(5, 4, -2))
	await _frames()
	_service.call("_start_copy", waiter, hand, card.node.global_transform * card.copy_point)
	await _frames()
	var added := graph.nodes.filter(func(block: Dictionary) -> bool: return not before.has(int(block["id"])))
	var copy := int((added[0] as Dictionary)["id"]) if added.size() == 1 else -1
	_check(copy >= 0 and graph.find_node(copy)["function"] == graph.find_node(waiter)["function"], "the delay is copied, alone: %s" % [added])
	_check(graph.edges.size() == edges + 1 and graph.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == feeder and edge["to"] == copy),
			"its copy keeps the value's wire, from the same output; not Print's execution wire")
	_check(&"duplicate_block" in _operations, "one block: Duplicate Block in the log")
	features.set_value(XREFeatureSettings.COPY_OUTER_WIRES, XREFeatureSettings.OFF)
	await _frames()
	edges = graph.edges.size()
	card = _card(waiter)
	if card == null or card.copy == null: return
	_service.call("_start_copy", waiter, hand, card.node.global_transform * card.copy_point)
	await _frames()
	_check(graph.edges.size() == edges, "off, a copy has no wires, as before")
	features.set_value(XREFeatureSettings.BLOCK_COPY, BASELINE[XREFeatureSettings.BLOCK_COPY])
	_service.select_block(-1)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-127: a copied object shares its Blueprint by default; with Blueprint of a
## copy on Own, it gets a graph of its own beside the scene, with the copy as
## its host, and its own generated script; the original keeps its own.
func _test_d122() -> void:
	_check(XREFeatureSettings.get_default(XREFeatureSettings.COPY_BLUEPRINT) == XREFeatureSettings.SHARED, "a copy shares its Blueprint by default")
	var source := XREBlueprints.source_path(_host)
	var script := _host.get_script() as Script
	_check(not source.is_empty() and script != null, "the fixture has a built Blueprint")
	if source.is_empty() or script == null: return
	var nodes: Array[Node] = [_host]
	var away := Transform3D(Basis.IDENTITY, Vector3(0, 0, 3))
	var shared := _document.duplicate_nodes(nodes, away, XREDocument.Source.TOOL)
	_check(shared.size() == 1 and XREBlueprints.source_path(shared[0]) == source and shared[0].get_script() == script,
			"Shared: the copy runs the same graph and script")
	await _frames()
	_document.undo(XREDocument.Source.TOOL)
	await _frames()
	_document.features.set_value(XREFeatureSettings.COPY_BLUEPRINT, XREFeatureSettings.OWN)
	var own := _document.duplicate_nodes(nodes, away, XREDocument.Source.TOOL)
	var copy: Node = own[0] if own.size() == 1 else null
	var path := XREBlueprints.source_path(copy) if copy != null else ""
	_check(not path.is_empty() and path != source and FileAccess.file_exists(path), "Own: the copy has a graph of its own beside the scene: %s" % path)
	var graph := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as XREBlueprintGraph if not path.is_empty() else null
	_check(graph != null and graph.host_path == _document.get_scene_root().get_path_to(copy), "whose host is the copy")
	var own_script := copy.get_script() as Script if copy != null else null
	_check(own_script != null and own_script != script and own_script.resource_path == path.get_basename() + ".generated.gd",
			"and a generated script of its own")
	_check(XREBlueprints.source_path(_host) == source and _host.get_script() == script, "the original keeps its own")
	await _frames()
	_document.undo(XREDocument.Source.TOOL)
	await _frames()
	_check(copy == null or copy.get_parent() == null, "undo takes the copy out")
	_document.features.set_value(XREFeatureSettings.COPY_BLUEPRINT, XREFeatureSettings.SHARED)
	for file: String in [path, path.get_basename() + ".generated.gd", path.get_basename() + ".generated.gd.uid"]:
		if file.is_empty() or not FileAccess.file_exists(file): continue
		DirAccess.remove_absolute(ProjectSettings.globalize_path(file))
		# The editor's file system forgets it too, or the graph catalog still lists the removed graph.
		EditorInterface.get_resource_filesystem().update_file(file)


## D-128: with Copy objects on Clipboard, a card's copy button puts the block
## on the graph's clipboard, the graph unchanged; Paste puts it where the ray
## meets the graph's plane, one undo step, selected.
func _test_d123() -> void:
	var graph := _service.blueprint.graph
	var canvas := _service.canvas
	var features := _document.features
	var history := _service.blueprint.history.get_version()
	_service.add_block("print")
	await _frames()
	var source := int((graph.nodes.back() as Dictionary)["id"])
	features.set_value(XREFeatureSettings.BLOCK_COPY, XREFeatureSettings.ON)
	features.set_value(XREFeatureSettings.OBJECT_COPY, XREFeatureSettings.CLIPBOARD)
	await _frames()
	var card := _card(source)
	if card == null or card.copy == null:
		_check(false, "the card has the copy button")
		return
	var blocks := graph.nodes.size()
	_service.call("_start_copy", source, _rig.right_hand, card.node.global_transform * card.copy_point)
	await _frames()
	_check(graph.nodes.size() == blocks and _service.get_clipboard_count() == 1 and &"copy_blocks" in _operations,
			"the copy button puts the block on the clipboard, the graph as it was")
	var normal := canvas.global_basis.z.normalized()
	var at := canvas.to_global(canvas.get_block_position(source) + Vector3(0.0, -0.4, 0.0))
	var version := _service.blueprint.history.get_version()
	_check(_service.paste_clipboard(at + normal * 0.4, -normal), "Paste where the ray meets the graph's plane")
	await _frames()
	var pasted := _service.get_selected_blocks()
	_check(graph.nodes.size() == blocks + 1 and pasted.size() == 1 and pasted[0] != source and _service.blueprint.history.get_version() == version + 1
			and &"paste_blocks" in _operations, "puts a copy there, one undo step, selected: %s" % [pasted])
	if pasted.size() == 1:
		_check(canvas.get_block_position(pasted[0]).distance_to(canvas.to_local(at)) < 0.01, "where the ray met the plane")
	_service.clear_clipboard()
	_check(_service.get_clipboard_count() == 0, "× empties it")
	features.set_value(XREFeatureSettings.OBJECT_COPY, XREFeatureSettings.SHORTCUT)
	features.set_value(XREFeatureSettings.BLOCK_COPY, BASELINE[XREFeatureSettings.BLOCK_COPY])
	_service.select_block(-1)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-130: a click in the graph's empty space lets go of the selected blocks;
## with the other hand adding, it keeps them.
## D-137: pins of a variadic operator in the headset. The ray on Add shows
## the plus under its trash; trigger on it adds input C. The ray on an input
## shows its ×; trigger on the × removes the input. Each is one edit, A undoes it.
func _test_d137() -> void:
	var graph := _service.blueprint.graph
	var canvas := _service.canvas
	var id := _service.blueprint.insert_block(XREBlueprintGraph.make_operator(0, "add", Vector2.ZERO), Vector2(-900, 900))
	await _frames()
	var card := _card(id)
	_check(card != null and card.pin_plus != null and card.pin_marks.size() == 2 and card.pin_marks[0] == null, "Add of two inputs has a plus and no ×")
	if card == null or card.pin_plus == null: return
	_check(is_equal_approx(card.pin_plus_point.x, -absf(card.trash_point.x)) and card.pin_plus_point.y < -card.height * 0.5, "the plus is under the node's left corner, on the inputs' side (D-138)")
	var front := card.node.global_basis.z.normalized()
	_aim_from(card.node.global_position, front)
	await _frames()
	_check(card.pin_plus.visible, "the ray on the node shows the plus with the trash")
	_aim_from(card.node.to_global(card.pin_plus_point), front)
	await _frames()
	# Both hands cast every frame: the plus growing says the right hand's ray is on it.
	_check(card.pin_plus.visible and card.pin_plus.scale.x > 1.0, "the ray takes the plus: it grows")
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(XREBlueprintGraph.operand_count(graph.find_node(id)) == 3, "trigger on the plus adds input C")
	card = _card(id)
	_check(card != null and card.pin_marks.size() == 3 and card.pin_marks[1] != null and not card.pin_marks[1].visible, "three inputs: each has a ×, hidden")
	if card == null or card.pin_marks.size() < 3 or card.pin_marks[1] == null: return
	front = card.node.global_basis.z.normalized()
	_aim_from(canvas.to_global(canvas.port_position(id, 1, true)), front)
	await _frames()
	_check(card.pin_marks[1].visible and not card.pin_marks[0].visible, "the ray on input B shows its × only")
	_aim_from(card.node.to_global(card.pin_marks[1].position), front)
	await _frames()
	_check(card.pin_marks[1].visible and card.pin_marks[1].scale.x > 1.0, "the ray takes the ×, which stays and grows")
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(XREBlueprintGraph.operand_count(graph.find_node(id)) == 2, "trigger on the × removes input B")
	_service.blueprint.undo()
	await _frames()
	_check(XREBlueprintGraph.operand_count(graph.find_node(id)) == 3, "A brings it back")
	_service.blueprint.undo()
	_service.blueprint.undo()
	await _frames()
	_check(graph.find_node(id).is_empty(), "two more undos take the operator out")
	# D-138: a Sequence's plus is under its right corner, on the outputs' side; × stands left of an output's name.
	var sequence := _service.blueprint.insert_block(XREBlueprintGraph.make_node(0, "sequence", Vector2.ZERO), Vector2(-900, 900))
	await _frames()
	card = _card(sequence)
	_check(card != null and card.pin_plus != null and card.pin_plus_point.x > 0.0 and not card.pin_input, "a Sequence's plus is under its right corner")
	if card == null or card.pin_plus == null: return
	front = card.node.global_basis.z.normalized()
	_aim_from(card.node.global_position, front)
	await _frames()
	_aim_from(card.node.to_global(card.pin_plus_point), front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(XREBlueprintGraph.pin_count(graph.find_node(sequence)) == 3, "trigger on it adds Then 2")
	card = _card(sequence)
	if card == null or card.pin_marks.size() < 3 or card.pin_marks[1] == null: return
	front = card.node.global_basis.z.normalized()
	_aim_from(canvas.to_global(canvas.port_position(sequence, 1, false)), front)
	await _frames()
	_check(card.pin_marks[1].visible and card.pin_marks[1].position.x < card.outputs[1].x - 0.03, "the ray on Then 1 shows its ×, left of its name")
	# D-140: on the way from the port to the ×, over the name, the × stays.
	var on_name := (card.pin_marks[1].position + Vector3(card.outputs[1].x, card.outputs[1].y, card.pin_marks[1].position.z)) * 0.5
	_aim_from(card.node.to_global(on_name), front)
	await _frames()
	_check(card.pin_marks[1].visible and not card.pin_marks[0].visible, "the ray on Then 1's name keeps its ×")
	_aim_from(card.node.to_global(card.pin_marks[1].position), front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(XREBlueprintGraph.pin_count(graph.find_node(sequence)) == 2, "trigger on the × removes Then 1")
	for step: int in 3: _service.blueprint.undo()
	await _frames()
	_check(graph.find_node(sequence).is_empty(), "undos take the Sequence out")
	# D-140: a Switch has In and Selection only; its cases are pucks where its outputs' names are, with plugs too.
	var saved_values: Variant = _document.features.get_value(XREFeatureSettings.VALUE_INPUT)
	for mode: StringName in [XREFeatureSettings.PUCKS, XREFeatureSettings.PLUGS]:
		_document.features.set_value(XREFeatureSettings.VALUE_INPUT, mode)
		var switch := _service.blueprint.insert_block(XREBlueprintGraph.make_switch(0, "int", Vector2.ZERO), Vector2(-900, 900))
		await _frames()
		card = _card(switch)
		var cases: Array[XREBlueprintCanvas.Socket] = []
		for socket: XREBlueprintCanvas.Socket in card.sockets if card != null else []:
			if socket.key.begins_with("case_"): cases.append(socket)
		_check(card != null and card.inputs.size() == 2 and cases.size() == 2, "%s: a Switch has two inputs, In and Selection, and two case pucks" % mode)
		_check(cases.all(func(socket: XREBlueprintCanvas.Socket) -> bool: return socket.center.x > 0.0 and absf(socket.center.y - card.outputs[cases.find(socket)].y) < 0.002),
				"%s: each case's puck is in its output's row, right of the middle" % mode)
		_check(card != null and card.pin_marks.size() == 2 and card.pin_shifts[0] < -0.03, "%s: a case's × would stand left of its puck" % mode)
		_service.blueprint.undo()
		await _frames()
	_document.features.set_value(XREFeatureSettings.VALUE_INPUT, saved_values)
	await _frames()
	# D-139: Break says "Break Vector3" as Get says its member; an eye by a field hides it, a chip lists the hidden.
	var split_action: Dictionary = {}
	for action: Dictionary in XREBlueprintActions.new().call("_struct_actions") as Array:
		if action["id"] == "struct:break:Vector3": split_action = action
	var split_block: Dictionary = (split_action.get("block", {}) as Dictionary).duplicate(true)
	# Its header in Member, as ⇄ sets it on archetype cards.
	split_block["vr_heading"] = "member"
	var saved_style: Variant = _document.features.get_value(XREFeatureSettings.NODE_STYLE)
	_document.features.set_value(XREFeatureSettings.NODE_STYLE, XREFeatureSettings.ARCHETYPES)
	var split := _service.blueprint.insert_block(split_block, Vector2(-900, 900)) if not split_action.is_empty() else -1
	await _frames()
	card = _card(split)
	_check(card != null and card.pin_eyes and card.pin_marks.size() == 3 and card.hidden_chip == null, "Break Vector3 has an eye by x, y and z and no chip")
	if card == null or card.pin_marks.size() < 3:
		_document.features.set_value(XREFeatureSettings.NODE_STYLE, saved_style)
		return
	var member := card.node.get_node_or_null(^"Member") as Label3D
	_check(member != null and member.text == "Vector3" and (card.node.get_node(^"Verb") as Label3D).text == "Break", "its header says Break Vector3")
	# D-140: its Target takes only a wire; its frame and icon are in Vector3's color, not its x's.
	_check(not card.sockets.any(func(socket: XREBlueprintCanvas.Socket) -> bool: return socket.kind in [XREBlueprintCanvas.TOKEN, XREBlueprintCanvas.SQUARE]), "Break's Target has no token")
	_check(XREBlueprintCanvas._pure_type(graph.find_node(split), graph.ports(graph.find_node(split), false)) == XREBlueprintGraph.VECTOR3, "Break is in the color of what it takes apart")
	front = card.node.global_basis.z.normalized()
	_aim_from(canvas.to_global(canvas.port_position(split, 1, false)), front)
	await _frames()
	_check(card.pin_marks[1].visible and not card.pin_marks[0].visible, "the ray on y shows its eye")
	_aim_from(card.node.to_global((card.pin_marks[1].position + Vector3(card.outputs[1].x, card.outputs[1].y, card.pin_marks[1].position.z)) * 0.5), front)
	await _frames()
	_check(card.pin_marks[1].visible, "the ray on y's name keeps its eye")
	_aim_from(card.node.to_global(card.pin_marks[1].position), front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check((graph.find_node(split)["hidden"] as Array).has("y"), "trigger on the eye hides y")
	card = _card(split)
	_check(card != null and card.hidden_chip != null and card.pin_marks.size() == 2, "a chip says one is hidden; x and z keep their eyes")
	var chip_difference: String = RayParity.first_difference(_service.canvas)
	_check(chip_difference.is_empty(), "the reach changes a ray on a chip and its eyes: %s" % chip_difference)
	if card == null or card.hidden_chip == null:
		_document.features.set_value(XREFeatureSettings.NODE_STYLE, saved_style)
		return
	_aim_from(card.node.to_global(card.hidden_chip_point), card.node.global_basis.z.normalized())
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check((_service.get("_choice") as XREBlueprintPetals).is_open(), "trigger on the chip lists the hidden on petals")
	_service.call("_choose_petal", _service.get("_choice"), {"text": "y", "show_field": [split, "y"], "enabled": true}, _rig.right_hand)
	await _frames()
	_check(not (graph.find_node(split)["hidden"] as Array).has("y"), "its petal shows y again")
	for step: int in 3: _service.blueprint.undo()
	_document.features.set_value(XREFeatureSettings.NODE_STYLE, saved_style)
	await _frames()
	_aim_from(Vector3(0, -50, 0), Vector3.BACK)
	await _frames()


func _test_d125() -> void:
	var graph := _service.blueprint.graph
	var canvas := _service.canvas
	var history := _service.blueprint.history.get_version()
	_service.add_block("print")
	await _frames()
	var id := int((graph.nodes.back() as Dictionary)["id"])
	canvas.preview_move(id, canvas.get_block_position(id) + Vector3(0, 0.6, 0.1))
	canvas.commit_move(_service.blueprint, id)
	await _frames()
	var normal := canvas.global_basis.z.normalized()
	var place := canvas.get_block_position(id)
	var empty := canvas.to_global(Vector3(place.x, place.y + 0.35, 0.0))
	_service.select_block(id)
	_aim_from(empty, normal)
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(_service.get_selected_blocks().is_empty(), "a click in the graph's empty space lets go of the selected block")
	_document.features.set_value(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.GRIP)
	_service.select_block(id)
	_left.set_pose(&"aim", Transform3D(Basis.IDENTITY, Vector3(-5, 0, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_left.set_input(&"grip", 1.0)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(_service.get_selected_blocks() == [id], "with the other hand adding, it keeps it: %s" % [_service.get_selected_blocks()])
	_left.set_input(&"grip", 0.0)
	_document.features.set_value(XREFeatureSettings.SELECT_ADD, XREFeatureSettings.REPLACE)
	_service.select_block(-1)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-086: the block palette is drawn over everything, as an input is, but
## without the focus veil; a card between it and the hand takes neither the
## sight of it nor its ray.
func _test_palette_on_top(window: XREPanelWindow, card: int) -> void:
	_check(window.is_on_top() and window.get_bar().is_on_top(), "the block palette is drawn over everything, its control bar too")
	_check(not _service.is_focused() and not (_service.get("_focus_dimmer") as MeshInstance3D).visible, "without the focus veil of an input")
	var pixel := window.size_px * 0.5
	var before := _service.canvas.get_block_position(card)
	_service.canvas.preview_move(card, _service.canvas.to_local(window.pixel_to_global(pixel) + window.global_basis.z.normalized() * 0.05))
	var pose := _pose_at(window, pixel)
	_check(_service.canvas.intersect_ray(_rig.global_transform * pose.origin, -(_rig.global_basis * pose.basis.z).normalized(), 1.0) >= 0, "a card stands between the hand and the palette")
	_right.set_pose(&"aim", pose, Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	var ray := _rig.right_hand.get("_ray") as MeshInstance3D
	_check(_rig.right_hand.get_claimant() == _panels and ray.scale.z > 0.28, "the ray goes through the card to the palette: %.3f m" % ray.scale.z)
	_service.canvas.preview_move(card, before)
	_aim(Vector3(5, 4, -2))
	await _frames()


## D-086: with Focus on Front the card a wire is drawn from is drawn over
## everything (D-075); the block palette the wire opened is drawn over it.
func _test_palette_over_focus(card: int) -> void:
	_document.features.set_value(XREFeatureSettings.FOCUS, XREFeatureSettings.FRONT)
	await _frames()
	var window := _panels.find_window(XREBlueprintPaletteTab)
	var highest := -INF
	var parts: Array[Node] = [_service.canvas.get_node("Block%d" % card)]
	while not parts.is_empty():
		var part: Node = parts.pop_back()
		parts.append_array(part.get_children())
		if part is GeometryInstance3D and (part as GeometryInstance3D).visible: highest = maxf(highest, (part as GeometryInstance3D).sorting_offset)
	_check(highest >= XREBlueprintFocus.TOP_SORTING, "the wire's card is in Front focus, over everything: %.1f" % highest)
	_check(window != null and (window.get("_quad") as MeshInstance3D).sorting_offset > highest and (window.get_bar().get("_quad") as MeshInstance3D).sorting_offset > highest,
			"the palette and its bar are drawn after it")
	# XREHand draws its ray over everything 200 later.
	_check((window.get("_quad") as MeshInstance3D).sorting_offset < 200.0, "and before the hands' rays")
	_document.features.set_value(XREFeatureSettings.FOCUS, XREFeatureSettings.OFF)
	await _frames()


## D-135: with Wire draw on Hold the trigger held on a port draws the wire;
## let go on another port it connects, on its own port a wire taken off it
## goes back, in empty space the block menu opens for it. Click keeps clicks.
func _test_d135() -> void:
	var graph := _service.blueprint.graph
	var canvas := _service.canvas
	var features := _document.features
	var history := _service.blueprint.history.get_version()
	_check(XREFeatureSettings.get_default(XREFeatureSettings.WIRE_DRAW) == XREFeatureSettings.HOLD, "a wire is drawn by holding the trigger by default")
	var ids: Array[int] = []
	for index: int in 2:
		_service.add_block("print")
		await _frames()
		ids.append(int((graph.nodes.back() as Dictionary)["id"]))
	var start := canvas.get_block_position(ids[0]) + Vector3(0, 0.6, 0.1)
	for index: int in 2:
		canvas.preview_move(ids[index], start + Vector3(0.45 * index, 0, 0))
	canvas.commit_moves(_service.blueprint, ids)
	await _frames()
	features.set_value(XREFeatureSettings.WIRE_DRAW, XREFeatureSettings.HOLD)
	var normal := canvas.global_basis.z.normalized()
	var out := canvas.to_global(canvas.port_position(ids[0], 0, false))
	var into := canvas.to_global(canvas.port_position(ids[1], 0, true))
	var empty := canvas.to_global(canvas.get_block_position(ids[0]) + Vector3(0, 0.35, 0))
	var edges := graph.edges.size()
	_aim_from(out, normal)
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(int(_service.get("_pending_id")) == ids[0], "the trigger held on an output draws a wire")
	_aim_from(into, normal)
	await _frames()
	_check(int(_service.get("_pending_id")) == ids[0] and graph.edges.size() == edges, "held, it follows the ray over an input")
	_right.set_input(&"trigger", 0.0)
	await _frames()
	var last: Dictionary = graph.edges.back() if not graph.edges.is_empty() else {}
	_check(graph.edges.size() == edges + 1 and last.get("from") == ids[0] and last.get("to") == ids[1] and int(_service.get("_pending_id")) == -1,
			"let go on the input, it connects there")
	graph.edges[graph.edges.size() - 1]["vr_bends"] = PackedVector3Array([Vector3(10, 20, 0.3)])
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(graph.edges.size() == edges and int(_service.get("_pending_id")) == ids[1], "held on a wired input, its wire comes off it")
	_right.set_input(&"trigger", 0.0)
	await _frames()
	last = graph.edges.back() if not graph.edges.is_empty() else {}
	_check(graph.edges.size() == edges + 1 and last.get("to") == ids[1] and last.get("vr_bends") == PackedVector3Array([Vector3(10, 20, 0.3)]) and int(_service.get("_pending_id")) == -1,
			"let go on the same port, it goes back with its bend")
	var free := canvas.to_global(canvas.port_position(ids[1], 0, false))
	edges = graph.edges.size()
	_aim_from(free, normal)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_aim_from(empty, normal)
	await _frames()
	_check(_panels.find_window(XREBlueprintPaletteTab) == null, "held in empty space, no menu yet")
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(_panels.find_window(XREBlueprintPaletteTab) != null and int(_service.get("_pending_id")) == ids[1], "let go in empty space, the block menu opens for the wire, which waits on it")
	_service.call("_cancel_dropped_wire")
	await _frames()
	_check(int(_service.get("_pending_id")) == -1, "the menu let go takes the wire with it")
	_aim_from(free, normal)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_aim_from(out, normal)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(int(_service.get("_pending_id")) == -1 and graph.edges.size() == edges, "let go on an output for an output, the wire goes, nothing connects")
	features.set_value(XREFeatureSettings.WIRE_DRAW, XREFeatureSettings.CLICK)
	_aim_from(out, normal)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(int(_service.get("_pending_id")) == ids[0], "with Click, a click on a port draws a wire that stays")
	_service.cancel_connection()
	features.set_value(XREFeatureSettings.WIRE_DRAW, BASELINE[XREFeatureSettings.WIRE_DRAW])
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	_aim(Vector3(-50, 0, 0))
	await _frames()


## D-143: collections in the headset, each variant — Collection port Grid and
## Stack, Collection wire, Collection literal Rack and its plus, Array from
## scene with its numbered branches —, a collection variable's box and the
## keyboard staying over a wire's menu.
func _test_d143() -> void:
	var graph := _service.blueprint.graph
	var canvas := _service.canvas
	var features := _document.features
	var history := _service.blueprint.history.get_version()
	for pair: Array in [[XREFeatureSettings.COLLECTION_PORT, XREFeatureSettings.GRID], [XREFeatureSettings.COLLECTION_LITERAL, XREFeatureSettings.MAKE],
			[XREFeatureSettings.COLLECTION_WIRE, XREFeatureSettings.OFF], [XREFeatureSettings.SCENE_COLLECTION, XREFeatureSettings.OFF]]:
		_check(XREFeatureSettings.get_default(pair[0] as StringName) == pair[1], "%s is %s by default" % pair)
	# As the mockup draws them: archetypes, variables in boxes; the settings as they were come back at the end.
	var touched: Array[StringName] = [XREFeatureSettings.COLLECTION_PORT, XREFeatureSettings.COLLECTION_LITERAL, XREFeatureSettings.COLLECTION_WIRE, XREFeatureSettings.SCENE_COLLECTION, XREFeatureSettings.NODE_STYLE, XREFeatureSettings.VARIABLE_INPUT]
	var was: Array[StringName] = []
	for key: StringName in touched: was.append(features.get_value(key))
	features.set_value(XREFeatureSettings.NODE_STYLE, XREFeatureSettings.ARCHETYPES)
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.BOXES)
	_service.blueprint.add_variable("scores", [1, 2, 5] as Array[int])
	_service.call("_add_from_menu", {"id": "test:loop", "title": "For Each", "target": null, "block": XREBlueprintGraph.make_node(0, "for_each", Vector2.ZERO)})
	await _frames()
	var loop := int((graph.nodes.back() as Dictionary)["id"])
	var getter := XREBlueprintGraph.make_node(0, "get_variable", Vector2.ZERO)
	getter["params"]["variable"] = "scores"
	var scores := _service.blueprint.insert_block(getter, Vector2.ZERO)
	_service.blueprint.connect_blocks(scores, 0, loop, 1)
	await _frames()
	var port := _card(loop).ports[1] as MeshInstance3D
	_check(port.mesh is ArrayMesh and port.get_child_count() == 0, "Grid: the Array port is one grid of cells")
	features.set_value(XREFeatureSettings.COLLECTION_PORT, XREFeatureSettings.STACK)
	features.set_value(XREFeatureSettings.COLLECTION_WIRE, XREFeatureSettings.ON)
	await _frames()
	port = _card(loop).ports[1] as MeshInstance3D
	_check(port.get_child_count() == 2, "Stack: the Array port is three ports, one behind another")
	var strands := false
	for wire: XREBlueprintCanvas.Wire in canvas.get("_wires") as Array:
		if wire.to != null and wire.to.id == loop and wire.normal is ShaderMaterial and (wire.normal as ShaderMaterial).get_shader_parameter(&"core") != null: strands = true
	_check(strands, "Collection wire: the array's wire has two strands")
	# Rack: a Pick Random without a wire holds its list beside its port; its plus adds one.
	features.set_value(XREFeatureSettings.COLLECTION_LITERAL, XREFeatureSettings.RACK)
	_service.call("_add_from_menu", {"id": "test:pick", "title": "Pick Random", "target": null, "block": XREBlueprintGraph.make_collection(0, "array_pick_random", Vector2.ZERO)})
	await _frames()
	var pick := int((graph.nodes.back() as Dictionary)["id"])
	# Apart from the loop, so that nothing covers its rack.
	canvas.preview_move(pick, canvas.get_block_position(loop) + Vector3(0.7, 0.4, 0.2))
	canvas.commit_moves(_service.blueprint, [pick] as Array[int])
	await _frames()
	_check(_card(pick).rack_rect.has_volume(), "Rack: an unwired Array has a rack")
	var card := _card(pick)
	await _click_from(card.node.to_global(card.rack_plus_point), card.node.global_basis.z.normalized())
	_check((graph.find_node(pick)["params"] as Dictionary).get("collection") == [0] and _service.blueprint.last_error.is_empty(), "the rack's plus adds an element: %s" % [(graph.find_node(pick)["params"] as Dictionary).get("collection")])
	# The plus rebuilt the cards.
	card = _card(pick)
	await _click_from(card.node.to_global(card.rack_rect.get_center()), card.node.global_basis.z.normalized())
	_check((_service.get("_keyboard") as XREPanelSurface).is_visible_in_tree(), "the trigger on the rack types its list on the keyboard")
	_service.call("_collection_typed", "[3, 4]")
	_check((graph.find_node(pick)["params"] as Dictionary).get("collection") == [3, 4], "the list typed is the rack's")
	_service.call("_close_inputs")
	# A collection variable's box: its type in full, its elements, folded to a count.
	var boxes := canvas.get("_boxes") as XREBlueprintBoxes
	var box: XREBlueprintBoxes.Box = null
	for each: XREBlueprintBoxes.Box in boxes.get("_boxes") as Array:
		if each.name == "scores": box = each
	_check(box != null and box.category == XREBlueprintCollections.array_of(XREBlueprintGraph.INTEGER) and not box.collapsed, "the box of scores is an Array[int], open")
	# D-144: its start value as a Make block's pins — a puck an element, a plus, a × over the puck under the ray.
	_check(Array(box.item_refs) == ["0", "1", "2"] and box.plus != null and box.mark != null, "each element is a puck of its own, a plus after them: %s" % [box.item_refs])
	var front := box.node.global_basis.z.normalized()
	await _click_from(box.node.global_transform * box.plus_point, front)
	_check(graph.find_variable("scores")["value"] == [1, 2, 5, 5] and graph.find_variable("scores")["value"] is Array[int], "the plus adds a copy of the last: %s" % [graph.find_variable("scores")["value"]])
	box = _box("scores")
	await _click_from(box.node.global_transform * box.item_points[1], front)
	_check(not (_service.get("_token_edit") as Dictionary).is_empty() and str((_service.get("_token_edit") as Dictionary)["box"]) == "scores#1", "a click on a puck types that element: %s" % [_service.get("_token_edit")])
	_service.call("_token_text_submitted", "7")
	_check(graph.find_variable("scores")["value"] == [1, 7, 5, 5], "only that element changes: %s" % [graph.find_variable("scores")["value"]])
	_service.call("_close_inputs")
	box = _box("scores")
	_aim_from(box.node.global_transform * box.item_points[0], front)
	await _frames()
	# The typed value rebuilt the boxes meanwhile.
	box = _box("scores")
	_check(box.mark.visible and box.mark_item == 0, "the × shows over the puck under the ray")
	await _click_from(box.node.global_transform * box.mark.position, front)
	_check(graph.find_variable("scores")["value"] == [7, 5, 5], "the × takes that element away: %s" % [graph.find_variable("scores")["value"]])
	_check(XREBlueprintBoxes.with_item({"open": 1, "closed": 2}, "1k", "open", XREBlueprintCollections.dictionary_of(XREBlueprintGraph.TEXT, XREBlueprintGraph.INTEGER)) == null
			and (XREBlueprintBoxes.with_item({"open": 1, "closed": 2}, "0k", "shut", XREBlueprintCollections.dictionary_of(XREBlueprintGraph.TEXT, XREBlueprintGraph.INTEGER)) as Dictionary).keys() == ["shut", "closed"],
			"a key is renamed in its place, and not to another pair's")
	_service.call("_switch_drawer", "scores")
	await _frames()
	_check(graph.find_variable("scores").get("vr_collapsed") == true, "its chevron folds it")
	# Array from scene: a wire from the Array let go on the selected objects.
	features.set_value(XREFeatureSettings.SCENE_COLLECTION, XREFeatureSettings.ON)
	_service.call("_add_from_menu", {"id": "test:objects", "title": "For Each", "target": null, "block": XREBlueprintGraph.make_node(0, "for_each", Vector2.ZERO)})
	await _frames()
	var objects := int((graph.nodes.back() as Dictionary)["id"])
	var scene := _document.get_scene_root()
	var nodes: Array[Node] = []
	for child: Node in scene.get_children():
		if child is MeshInstance3D and nodes.size() < 2: nodes.append(child)
	_document.select(nodes, XREDocument.Source.TOOL)
	await _frames()
	_service.set("_pending_id", objects)
	_service.set("_pending_port", 1)
	_service.set("_pending_input", true)
	_check(bool(_service.call("_pending_scene_target")), "an Array port's wire goes to the scene with Array from scene on")
	_check(_service.connect_scene_target(objects, nodes[1]), "let go on a selected object: %s" % _service.blueprint.last_error)
	var paths: Array = (graph.find_node(objects)["params"] as Dictionary).get(XREBlueprintGraph.SCENE_TARGETS, [])
	_check(paths.size() == 2, "the array holds the two selected objects, in their order: %s" % [paths])
	await _frames()
	var branches := 0
	for wire: Variant in _service.get("_target_wires") as Array:
		if int((wire as Object).get("id")) == objects and int((wire as Object).get("element")) >= 0: branches += 1
	_check(branches == 2, "a numbered branch to each")
	_check(_service.blueprint.remove_scene_target(objects, 0) and (graph.find_node(objects)["params"][XREBlueprintGraph.SCENE_TARGETS] as Array).size() == 1, "a branch's object goes out of the array")
	_document.select([], XREDocument.Source.TOOL)
	for index: int in touched.size():
		features.set_value(touched[index], was[index])
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	_aim(Vector3(-50, 0, 0))
	await _frames()


## D-142: a collection's block without its collection wired leaves the
## headset's edits alone — the trash, a wire held off a port —, which fill the
## sockets they empty: its collection takes no token.
func _test_d142() -> void:
	var graph := _service.blueprint.graph
	var history := _service.blueprint.history.get_version()
	_service.call("_add_from_menu", {"id": "test:keys", "title": "Keys", "target": null, "block": XREBlueprintGraph.make_collection(0, "dictionary_keys", Vector2.ZERO)})
	await _frames()
	var keys := int((graph.nodes.back() as Dictionary)["id"])
	_service.add_block("print")
	await _frames()
	var printer := int((graph.nodes.back() as Dictionary)["id"])
	_check(graph.find_node(keys).get("kind") == "collection" and not (graph.find_node(keys)["params"] as Dictionary).has("collection"), "Keys stands unwired, its collection empty")
	_service.delete_block(printer)
	await _frames()
	_check(graph.find_node(printer).is_empty() and _service.blueprint.last_error.is_empty(), "the trash still deletes a block: %s" % _service.blueprint.last_error)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-052: parameters as objects of the graph, each setting and its variants.
func _test_parameters_in_graph() -> void:
	var features := _document.features
	var keys: Array[StringName] = [XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ANIMATION_WAIT,
			XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.TOKEN_TRAY, XREFeatureSettings.SCENE_CREATE]
	var saved: Dictionary[StringName, StringName] = {}
	for key: StringName in keys:
		saved[key] = features.get_value(key)
		features.set_value(key, BASELINE[key])
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph
	_service.add_block("delay")
	await _frames()
	var delay: int = graph.nodes.back()["id"]
	_check(_service.canvas.token_keys(delay).is_empty() and _service.parameters_needed(delay), "by default values are in the window")
	_check(_document.set_feature(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PUCKS, XREDocument.Source.PANEL), "values switch to pucks")
	await _frames()
	_check(_service.canvas.token_keys(delay).has("seconds") and not _service.parameters_needed(delay), "a Delay's seconds is a puck and its window has nothing left")
	var token := _service.canvas.token_transform(delay, "seconds").origin
	var front := _card(delay).node.global_basis.z.normalized()
	var aim := func(angle: float) -> void:
		_right.set_pose(&"aim", Transform3D(Basis.looking_at(-front) * Basis(Vector3.BACK, angle), token + front * 0.4), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	aim.call(0.0)
	await _frames()
	_service.canvas.intersect_ray(token + front * 0.4, -front, 1.0)
	_check(_service.canvas.get_hit_socket_kind() == XREBlueprintCanvas.TOKEN and _service.canvas.get_hit_socket_key() == "seconds", "the ray hits the puck")
	_right.set_input(&"trigger", 1.0)
	await _frames()
	for angle: float in [-0.3, -0.6]:
		await get_tree().create_timer(0.25).timeout
		aim.call(angle)
		await _frames()
	_check(is_equal_approx(float(graph.find_node(delay)["params"]["seconds"]), 1.0), "a turn previews without editing the graph")
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(is_equal_approx(float(graph.find_node(delay)["params"]["seconds"]), 1.2), "two steps of the wrist add two tenths: %s" % graph.find_node(delay)["params"]["seconds"])
	_check(&"turn_token" in _operations, "a turn is a logged edit")
	aim.call(0.0)
	await _frames()
	_right.set_input(&"grip", 1.0)
	await _frames()
	_aim(Vector3(5, 4, -2))
	await _frames()
	_right.set_input(&"grip", 0.0)
	await _frames()
	_check(is_equal_approx(float((graph.find_node(delay)["params"] as Dictionary).get("seconds", -1.0)), 1.0), "a puck dropped in the air leaves its port the default token (D-059)")
	_check(not " ".join(XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray).contains("Seconds is empty"), "so the build has nothing to report")
	_service.blueprint.undo()
	await _frames()
	_check(is_equal_approx(float(graph.find_node(delay)["params"]["seconds"]), 1.2), "undo puts the token back")
	aim.call(0.0)
	await _frames()
	_left.set_input(&"ax_button", true)
	await _frames()
	_left.set_input(&"ax_button", false)
	await _frames()
	_check(not graph.find_node(delay).is_empty() and is_equal_approx(float((graph.find_node(delay)["params"] as Dictionary).get("seconds", -1.0)), 1.0), "X with the right ray on a token gives back the default token and keeps its block")
	_service.blueprint.undo()
	await _frames()
	_check(_document.set_feature(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PLUGS, XREDocument.Source.PANEL), "values switch to plugs")
	await _frames()
	var plug := _card(delay).node.to_local(_service.canvas.token_transform(delay, "seconds").origin)
	_check(plug.x < -XREBlueprintCanvas.CARD_WIDTH * 0.5, "a plug sticks out to the left of its card")
	_check(_document.set_feature(XREFeatureSettings.TOKEN_TRAY, XREFeatureSettings.ON, XREDocument.Source.PANEL), "the token tray switches on")
	await _frames()
	_check(_panels.find_window(XREBlueprintTokensTab) != null, "the Tokens window opens with tokens")
	var cells := _service.token_tray.get_values()
	_check(cells.has(true) and cells.has("restart"), "the tray has yes/no and modes")
	_document.set_feature(XREFeatureSettings.TOKEN_TRAY, XREFeatureSettings.OFF, XREDocument.Source.PANEL)
	await _frames()
	_check(_panels.find_window(XREBlueprintTokensTab) == null, "and closes with it off")

	_check(_document.set_feature(XREFeatureSettings.ANIMATION_WAIT, XREFeatureSettings.FINISHED_PORT, XREDocument.Source.PANEL), "wait switches to the Finished port")
	_service.add_block("play_animation")
	_service.add_block("print")
	await _frames()
	var play: int = graph.nodes[graph.nodes.size() - 2]["id"]
	var after: int = graph.nodes.back()["id"]
	_check(_service.canvas.has_finished(play) and not "wait" in _service.canvas.token_keys(play), "Play Animation shows Finished instead of a wait token")
	_check(_service.click_port(play, 0, false, null, -1, 1) and _service.click_port(after, 0, true), "a wire from Finished")
	await _frames()
	_check(graph.find_node(play)["params"]["wait"] == true and _service.canvas.is_waiting(play), "wired from Finished it waits")
	_check(_service.click_port(play, 0, false, null, -1, 0), "Then takes the wire")
	await _frames()
	_check(graph.find_node(play)["params"]["wait"] == false and graph.edges.has({"from": play, "from_port": 0, "to": after, "to_port": 0}), "wired from Then it goes on at once, the wire kept")
	_check(&"wire_finished" in _operations, "the switch is logged")

	var player := AnimationPlayer.new()
	player.name = "Doors"
	var library := AnimationLibrary.new()
	library.add_animation("open", Animation.new())
	library.add_animation("close", Animation.new())
	player.add_animation_library("", library)
	_document.add_node(player, _host, XREDocument.Source.PANEL)
	_check(_document.set_feature(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.SCENE, XREDocument.Source.PANEL), "targets switch to the scene")
	await _frames()
	var petals := _service.get("_petals") as XREBlueprintPetals
	_service.call("_open_petals", play, _host, _host.global_position)
	var close: Array[Dictionary] = petals.get_shown().filter(func(item: Dictionary) -> bool: return item.get("member") == "close")
	_check(petals.is_open() and not close.is_empty(), "the object's petals list its hidden AnimationPlayer's animations")
	if not close.is_empty():
		_service.call("_choose_petal", petals, close[0], _rig.right_hand)
		await _frames()
		_check(graph.find_node(play)["params"]["target"] == "Doors" and graph.find_node(play)["params"]["animation"] == "close", "one petal sets the target and the animation")
		_check(&"wire_member" in _operations and not petals.is_open(), "as one logged edit; the fan closes")
	_check(not _service.parameters_needed(play) or _service.shows_in_window(graph.find_node(play), "timeout"), "the window keeps only what is left in it")
	_service.add_block("signal")
	await _frames()
	var event: int = graph.nodes.back()["id"]
	_check(_service.canvas.socket_position(event, XREBlueprintCanvas.SOURCE) != _card(event).node.position, "an event has a Source socket on the scene")
	_service.call("_open_petals", event, _host, _host.global_position)
	var visibility: Array[Dictionary] = petals.get_shown().filter(func(item: Dictionary) -> bool: return item.get("member") == "visibility_changed")
	if visibility.is_empty() and petals.get_item_count() > 0:
		for page: int in 20:
			petals.scroll(XREBlueprintPetals.PAGE)
			visibility = petals.get_shown().filter(func(item: Dictionary) -> bool: return item.get("member") == "visibility_changed")
			if not visibility.is_empty(): break
	_check(not visibility.is_empty(), "the object's signals are petals, a page at a time")
	if not visibility.is_empty():
		_service.call("_choose_petal", petals, visibility[0], _rig.right_hand)
		await _frames()
		_check(graph.find_node(event)["params"]["signal"] == "visibility_changed", "a signal petal sets the event's signal")

	_check(_document.set_feature(XREFeatureSettings.SCENE_CREATE, XREFeatureSettings.ON, XREDocument.Source.PANEL), "create from scene switches on")
	_document.select([_host], XREDocument.Source.TOOL)
	await _frames()
	_check(petals.is_open() and petals.get_object() == _host, "the selected object shows its petals")
	var clips: Array[Dictionary] = []
	for page: int in 20:
		clips = petals.get_shown().filter(func(item: Dictionary) -> bool: return item.get("kind") == "animation")
		if not clips.is_empty(): break
		petals.scroll(XREBlueprintPetals.PAGE)
	_check(not clips.is_empty(), "with its animations")
	if not clips.is_empty():
		var blocks := graph.nodes.size()
		_service.call("_choose_petal", petals, clips[0], _rig.right_hand)
		_service.set("_choice_point", Vector3(0.4, -0.6, 0.0))
		_service.call("_create_member_block", "play_animation")
		await _frames()
		_check(graph.nodes.size() == blocks + 1 and graph.nodes.back()["params"]["target"] == "Doors" and &"create_from_scene" in _operations, "a petal's wire let go in the graph adds its block")
	_document.set_feature(XREFeatureSettings.SCENE_CREATE, XREFeatureSettings.OFF, XREDocument.Source.PANEL)

	_service.blueprint.set_variable("door_open", false)
	_service.blueprint.set_variable("count", 0)
	_check(_document.set_feature(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.BOXES, XREDocument.Source.PANEL), "variables switch to boxes")
	_service.add_block("get_variable")
	await _frames()
	var getter: int = graph.nodes.back()["id"]
	var shelf := _service.canvas.get_boxes()
	_check(shelf.visible and shelf.has_box("door_open") and shelf.has_box("count"), "the variables are boxes in the graph")
	_check(not _service.shows_in_window(graph.find_node(getter), "variable"), "a Get Variable's variable leaves the window")
	_service.call("_remove_box", "door_open")
	_check(not graph.find_variable("door_open").is_empty(), "a box in use can't be deleted")
	_service.call("_wire_variable", getter, "count")
	await _frames()
	_check(graph.find_node(getter)["params"]["variable"] == "count" and &"wire_variable" in _operations, "a wire to a box sets the variable")
	_service.call("_remove_box", "door_open")
	_check(graph.find_variable("door_open").is_empty(), "a free box can be deleted")

	for key: StringName in keys: features.set_value(key, saved[key])
	_document.remove_nodes([player], XREDocument.Source.PANEL)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## Aims the right ray at [param point] from [param front], 0.4 m in front of it.
func _aim_from(point: Vector3, front: Vector3) -> void:
	_right.set_pose(&"aim", Transform3D(Basis.looking_at(-front), point + front * 0.4), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)


## D-052 after the first headset check: tokens dragged by the trigger, the
## dial, the Color window (D-064) and the arrows of a vector, scrolled
## petals, a member's petal on its stem, a box's trash lit per hand.
func _test_token_input() -> void:
	var features := _document.features
	var saved_values := features.get_value(XREFeatureSettings.VALUE_INPUT)
	var saved_targets := features.get_value(XREFeatureSettings.TARGET_INPUT)
	var saved_variables := features.get_value(XREFeatureSettings.VARIABLE_INPUT)
	features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PUCKS)
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph
	var editor := _service.get("_token_editor") as XREBlueprintTokenEditor
	_service.add_block("delay")
	await _frames()
	var delay: int = graph.nodes.back()["id"]
	var front := _card(delay).node.global_basis.z.normalized()
	var token := _service.canvas.token_transform(delay, "seconds").origin
	_aim_from(token, front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(editor.mode == XREBlueprintTokenEditor.DIAL, "a number held by the trigger shows its dial at the token")
	_aim_from(token + _card(delay).node.global_basis.x.normalized() * 0.036, front)
	await _frames()
	var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
	_check(pointer.carried == null and editor.mode == XREBlueprintTokenEditor.DIAL, "the ray moved with the trigger held doesn't take the token (D-061)")
	var stepped_from := _service.blueprint.history.get_version()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(is_equal_approx(float(graph.find_node(delay)["params"]["seconds"]), 1.3), "the ray along its number line sets it, a tenth per 1.2 cm (D-062): %s" % graph.find_node(delay)["params"]["seconds"])
	if _service.blueprint.history.get_version() > stepped_from: _service.blueprint.undo()
	await _frames()
	_aim_from(token, front)
	await _frames()
	_check(editor.mode == XREBlueprintTokenEditor.HINT, "a token under the ray says how it is edited")
	_aim(Vector3(5, 4, -2))
	await _frames()

	features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PLUGS)
	_service.blueprint.set_variable("pause", 2.0)
	_service.add_block("get_variable")
	await _frames()
	var pause: int = graph.nodes.back()["id"]
	_service.blueprint.set_parameter(pause, "variable", "pause")
	await _frames()
	front = _card(delay).node.global_basis.z.normalized()
	await _click_from(_service.canvas.to_global(_service.canvas.port_position(pause, 0, false)), _card(pause).node.global_basis.z.normalized())
	var seconds_port := graph.input_port(graph.find_node(delay), "seconds")
	await _click_from(_service.canvas.to_global(_service.canvas.port_position(delay, seconds_port, true)), front)
	_check(graph.edges.has({"from": pause, "from_port": 0, "to": delay, "to_port": seconds_port}), "a variable's wire goes into a port that holds a plug: %s" % [graph.edges])
	features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PUCKS)
	await _frames()
	_service.add_block("equals")
	await _frames()
	var equal: int = graph.nodes.back()["id"]
	var state := graph.snapshot()
	for block: Dictionary in state["nodes"]:
		if block["id"] == equal:
			block["params"]["a"] = Color.BLUE
			block["params"]["b"] = Vector3(1, 2, 3)
	_service.blueprint.commit("Test Values", state)
	await _frames()
	front = _card(equal).node.global_basis.z.normalized()
	await _click_from(_service.canvas.token_transform(equal, "a").origin, front)
	await _frames(3)
	_check(_panels.find_window(XREBlueprintColorTab) != null and _service.color_panel.get_picker().is_visible_in_tree() and editor.mode != XREBlueprintTokenEditor.GLOBE, "a click on a color token opens the Color window with the 2D picker (D-064)")
	_service.color_panel.get_picker().color_changed.emit(Color.GREEN)
	await _frames()
	var color := _edited() as Color
	_check(color.is_equal_approx(Color.GREEN) and graph.find_node(equal)["params"]["a"] == Color.BLUE, "the picker shows its color on the token; the graph keeps it until Done")
	_service.color_panel.get_done_button().pressed.emit()
	await _frames(3)
	_check((graph.find_node(equal)["params"]["a"] as Color).is_equal_approx(Color.GREEN) and _panels.find_window(XREBlueprintColorTab) == null, "Done keeps the color and closes the window")
	await _click_from(_service.canvas.token_transform(equal, "b").origin, front)
	_check(editor.mode == XREBlueprintTokenEditor.ARROWS, "a click on a vector token opens its arrows")
	var arrow := editor.global_position + editor.axis_direction(0) * float((editor.get("_lengths") as Array)[0]) * 0.6
	var pull := editor.get_arrow_scale() * 2.5
	_aim_from(arrow, Vector3.BACK)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_aim_from(arrow + editor.axis_direction(0) * pull, Vector3.BACK)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	var vector := _edited() as Vector3
	_check(is_equal_approx(vector.x, 3.5) and is_equal_approx(vector.y, 2.0), "pulling X 2.5 units long at the scale of (1, 2, 3) adds 2.5 to X only: %s" % vector)
	_check(editor.global_position.distance_to(_service.canvas.token_transform(equal, "b").origin) > 0.1, "the arrows stand in front of the card, not in it")
	_check(is_equal_approx(XREBlueprintTokenEditor.pulled(0.08, 0.0), 0.0) and is_equal_approx(XREBlueprintTokenEditor.pulled(0.9, 0.02), 1.0), "a pulled axis stops at whole numbers")
	await _click_from(editor.global_position + editor.axis_direction(1) * float((editor.get("_lengths") as Array)[1]) * 0.6, Vector3.BACK)
	vector = _edited() as Vector3
	_check(is_zero_approx(vector.y) and is_equal_approx(vector.x, 3.5), "a click on an arrow sets its axis to 0: %s" % vector)
	await _click(Vector3(5, 4, -2))

	features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.SCENE)
	_service.add_block("signal")
	await _frames()
	var event: int = graph.nodes.back()["id"]
	var petals := _service.get("_petals") as XREBlueprintPetals
	_service.call("_open_petals", event, _host, _host.global_position)
	var first: Dictionary = petals.get_shown()[0]
	_check(petals.get_item_count() > XREBlueprintPetals.PAGE and petals.scroll(2) and petals.get_shown()[0] != first, "a long list of petals scrolls")
	_check(str(petals.get_shown()[0].get("text", "")).begins_with("▲"), "with a petal that scrolls back up")
	_service.cancel_connection()
	petals.close()
	_service.add_block("set_property")
	await _frames()
	var setter: int = graph.nodes.back()["id"]
	_service.blueprint.choose_target(setter, _host)
	await _frames(4)
	var lit: Array = (_service.get("_target_wires") as Array).filter(func(wire: XREBlueprints.TargetWire) -> bool: return wire.id == setter)
	_check(not lit.is_empty() and (lit[0] as XREBlueprints.TargetWire).label != null, "the member has a petal of its own on a stem")
	if not lit.is_empty():
		var wire := lit[0] as XREBlueprints.TargetWire
		var end := wire.mesh.get_point(wire.mesh.get_point_count() - 1)
		_check(_service.canvas.to_global(end).distance_to(wire.label.global_position) < float(wire.width) * 0.5 * wire.label.global_basis.get_scale().x + 0.01, "the Target wire ends at the member's petal")
		var head := _rig.camera.global_position
		var growth := wire.label.global_basis.get_scale().x
		var base := (wire.anchor.global_transform * XREPicker.get_local_bounds(wire.anchor)).get_center()
		_check(growth >= 1.0 and is_equal_approx(growth, clampf(base.distance_to(head) / XREBlueprintPetals.FULL_SIZE_DISTANCE, 1.0, XREBlueprintPetals.MAX_GROWTH)), "far away the member's petal grows to keep its size in view")
		var toward := head - base
		toward.y = 0.0
		toward = toward.normalized() if not toward.is_zero_approx() else Vector3.BACK
		_check((wire.label.global_position - base).dot(toward.cross(Vector3.UP)) > 0.0, "it hangs to the left of its object, away from the fan")
		_check(wire.label.global_position.distance_to(wire.dot.global_position) > 0.05, "which hangs on its stem from the object")
	_service.add_block("set_property")
	await _frames()
	var second: int = graph.nodes.back()["id"]
	_service.blueprint.choose_target(second, _host)
	await _frames(4)
	var stacked: Array = (_service.get("_target_wires") as Array).filter(func(wire: XREBlueprints.TargetWire) -> bool: return wire.id in [setter, second])
	_check(stacked.size() == 2 and (stacked[0] as XREBlueprints.TargetWire).label.global_position.distance_to((stacked[1] as XREBlueprints.TargetWire).label.global_position) > XREBlueprintPetals.PILL_HEIGHT, "petals of two wires to one object don't overlap")
	_service.call("_open_petals", setter, _host, _host.global_position)
	await _frames()
	_check(petals.is_open() and (stacked[0] as XREBlueprints.TargetWire).label.visible, "the member's petal stays in view while its object's fan is open")
	var fan_head := _rig.camera.global_position
	_check(petals.global_basis.z.normalized().dot((fan_head - petals.global_position).normalized()) > 0.999, "the fan faces the head square on")
	_rig.camera.position += Vector3(0.6, 0.3, 0.0)
	await _frames()
	_check(petals.global_basis.z.normalized().dot((_rig.camera.global_position - petals.global_position).normalized()) > 0.999, "and turns as the head moves")
	_rig.camera.position -= Vector3(0.6, 0.3, 0.0)
	petals.close()
	var label := XRERig.create_vr_label(18, 0.001)
	_check(label.auto_translate_mode == Node.AUTO_TRANSLATE_MODE_DISABLED, "3D labels aren't translated into the editor's language")
	label.free()
	features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ON_NODE)
	await _frames(4)
	var member: Array = (_card(setter).sockets).filter(func(socket: XREBlueprintCanvas.Socket) -> bool: return socket.kind == XREBlueprintCanvas.MEMBER)
	_check(not member.is_empty() and (member[0] as XREBlueprintCanvas.Socket).visual.has_meta(&"width"), "the member's name on the card is a petal of its own")

	features.set_value(XREFeatureSettings.TOKEN_TRAY, XREFeatureSettings.ON)
	await _frames(4)
	var tray := _panels.find_window(XREBlueprintTokensTab)
	var tray_tokens := _service.get("_tray_tokens") as Array
	_check(tray != null and tray_tokens.size() == _service.token_tray.get_values().size(), "the tray's cells hold solid tokens")
	if tray != null:
		var cell := _service.token_tray.cell_rect(0).get_center()
		await _hover_on(tray, cell)
		_right.set_input(&"trigger", 1.0)
		await _frames()
		_check(pointer.carried != null and pointer.carried_trigger, "the trigger on a cell of the tray takes its token")
		_aim(Vector3(5, 4, -2))
		await _frames()
		_right.set_input(&"trigger", 0.0)
		await _frames()
		_check(pointer.carried == null, "and lets it go with the trigger")
	features.set_value(XREFeatureSettings.TOKEN_TRAY, XREFeatureSettings.OFF)
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.BOXES)
	_service.blueprint.set_variable("lit", false)
	await _frames()
	# The start value never leaves its box (D-079, after D-054 let the grip take it out): the grip carries the box.
	var box_token := _service.canvas.get_boxes().token_transform("lit").origin
	_aim_from(box_token, Vector3.BACK)
	await _frames()
	_right.set_input(&"grip", 1.0)
	await _frames()
	_check(pointer.carried == null, "the grip on a box's token takes no token")
	_aim_from(box_token + Vector3(0.05, 0.0, 0.0), Vector3.BACK)
	await _frames()
	_right.set_input(&"grip", 0.0)
	await _frames()
	_check(graph.find_variable("lit").get("value") == false and graph.find_variable("lit").get("vr_position") is Vector2, "it carries the box, its start value kept")
	_service.blueprint.undo()
	await _frames()
	_service.call("_wire_box_to_port", "pause", equal, 0)
	await _frames()
	var reader: Dictionary = graph.nodes.back()
	_check(reader["kind"] == "get_variable" and reader["params"]["variable"] == "pause" and graph.edges.has({"from": reader["id"], "from_port": 0, "to": equal, "to_port": 0}), "a wire between a box and an input adds the box's Get Variable wired to it")
	await _frames()
	var shelf := _service.canvas.get_boxes()
	shelf.hover(0, XREBlueprintBoxes.TRASH, true)
	shelf.hover(-1, -1, false)
	var trash := ((shelf.get("_boxes") as Array)[0] as XREBlueprintBoxes.Box).trash
	_check(is_equal_approx(trash.scale.x, XREBlueprintCanvas.HOVER_SCALE), "a box's trash grows under a ray, and the other hand's idle ray leaves it so")
	shelf.hover(-1, -1, true)

	# Clicks on nothing let the scene's selection go.
	_document.select([_host], XREDocument.Source.TOOL)
	features.set_value(XREFeatureSettings.VALUE_INPUT, saved_values)
	features.set_value(XREFeatureSettings.TARGET_INPUT, saved_targets)
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, saved_variables)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## The pill of the member socket on card [param id], or null.
func _member_pill(id: int) -> Node3D:
	for socket: XREBlueprintCanvas.Socket in _card(id).sockets:
		if socket.kind == XREBlueprintCanvas.MEMBER: return socket.visual
	return null


## The Target wire of block [param id] to the scene, or null.
func _target_wire(id: int) -> XREBlueprints.TargetWire:
	for wire: XREBlueprints.TargetWire in _service.get("_target_wires") as Array:
		if wire.id == id: return wire
	return null


## D-057 after the third headset check: where Targets show the member — on
## the card (Node), on a petal at the object (Scene), both (All); an unset
## member says what to pick, and wiring the Target to an object asks for it;
## a petal on its stem takes the trigger; numbers type on a keypad that opens
## in front of the card.
func _test_target_modes() -> void:
	var features := _document.features
	var saved_values := features.get_value(XREFeatureSettings.VALUE_INPUT)
	var saved_targets := features.get_value(XREFeatureSettings.TARGET_INPUT)
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph
	_check(XREFeatureSettings.get_values(XREFeatureSettings.TARGET_INPUT) == [XREFeatureSettings.ADAPTER, XREFeatureSettings.WINDOW, XREFeatureSettings.ON_NODE, XREFeatureSettings.SCENE], "Targets: Adapter by default (D-076), Window, Node and Scene")
	_service.add_block("set_property")
	await _frames()
	var setter: int = graph.nodes.back()["id"]
	_service.blueprint.choose_target(setter, _host)
	_service.add_block("signal")
	await _frames()
	var event: int = graph.nodes.back()["id"]
	var expected := {
		XREFeatureSettings.WINDOW: [false, false],
		XREFeatureSettings.ON_NODE: [true, false],
		XREFeatureSettings.SCENE: [false, true],
		XREFeatureSettings.ADAPTER: [true, false],
	}
	for mode: StringName in expected:
		features.set_value(XREFeatureSettings.TARGET_INPUT, mode)
		await _frames(4)
		var on_card := _member_pill(setter) != null
		var wire := _target_wire(setter)
		var on_stem := wire != null and wire.label != null
		_check([on_card, on_stem] == expected[mode], "Targets %s: member on the card %s, on a stem %s" % [mode, on_card, on_stem])
		var sources := (_card(event).sockets).filter(func(socket: XREBlueprintCanvas.Socket) -> bool: return socket.kind == XREBlueprintCanvas.SOURCE)
		_check((sources.size() == 1) == (mode != XREFeatureSettings.WINDOW) and (_member_pill(event) != null) == (mode in [XREFeatureSettings.ON_NODE, XREFeatureSettings.ADAPTER]), "Targets %s: the event's Source and its signal's name" % mode)
		if mode == XREFeatureSettings.ADAPTER:
			var adapter := _member_pill(setter)
			var start: Variant = _service.canvas.adapter_end(setter)
			_check(adapter != null and adapter.has_meta(&"adapter_end") and start is Vector3 and wire != null and wire.mesh.get_point(0).is_equal_approx(start as Vector3), "Adapter: a plug in the Target port, and the wire to the object leaves its far end")
			var adapter_text := (adapter.get_meta(&"text") as Label3D).text if adapter != null else ""
			_check(adapter_text == "visible ▸", "the adapter names the member: %s" % adapter_text)
			var pin := adapter.get_meta(&"pin") as MeshInstance3D if adapter != null and adapter.has_meta(&"pin") else null
			_check(pin != null and _service.canvas.to_global(start as Vector3).distance_to(pin.global_position) < 0.001, "the wire goes into a pin at the adapter's far end")
			# Focus Front (D-075): the wire to the object keeps its shape, drawn over everything.
			var before_points := PackedVector3Array()
			for index: int in wire.mesh.get_point_count(): before_points.append(wire.mesh.get_point(index))
			features.set_value(XREFeatureSettings.FOCUS, XREFeatureSettings.FRONT)
			_aim_from(_card(setter).node.global_position + _card(setter).node.global_basis.y.normalized() * 0.02, _card(setter).node.global_basis.z.normalized())
			await _frames(3)
			var kept := wire.mesh.get_point_count() == before_points.size()
			for index: int in before_points.size(): kept = kept and wire.mesh.get_point(index).is_equal_approx(before_points[index])
			_check(_service.canvas.focus_state(setter) == XREBlueprintFocus.FOCUSED and kept and wire.mesh.has_meta(&"untop") and adapter.find_children("*", "Label3D", true, false).all(func(part: Node) -> bool: return (part as Label3D).no_depth_test),
					"with Front its wire to the object keeps its shape and is drawn over everything, the adapter too")
			_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
			features.set_value(XREFeatureSettings.FOCUS, XREFeatureSettings.OFF)
			await _frames(3)
	features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ON_NODE)
	await _frames(4)
	var pill := _member_pill(setter)
	var pill_text := (pill.get_child(2) as Label3D).text if pill != null else ""
	_check(pill_text == "visible ▸", "the member on the card shows it is a choice: %s" % pill_text)
	features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.SCENE)
	await _frames(4)
	var wire := _target_wire(setter)
	_check(wire != null and wire.label != null and (wire.label.get_child(2) as Label3D).text == "visible ▸", "and so does its petal on the stem")
	_check(XREBlueprintTokens.member_placeholder(graph.find_node(setter)) == "pick a property ▸" and XREBlueprintTokens.member_placeholder(graph.find_node(event)) == "pick a signal ▸", "an unset member says what to pick")
	var petals := _service.get("_petals") as XREBlueprintPetals
	if wire != null and wire.label != null:
		var front := wire.label.global_basis.z.normalized()
		var at := wire.label.global_position
		var met := _service.stem_at(at + front * 0.4, -front, 5.0)
		_check(met == wire, "the ray meets the petal on its stem: %s, visible %s" % [met.id if met != null else -1, wire.label.visible])
		_check(_service.stem_at(at + front * 0.4 + wire.label.global_basis.x * 3.0, -front, 5.0) == null, "and only there")
		var editor := _service.get("_token_editor") as XREBlueprintTokenEditor
		_aim_from(at, front)
		await _frames()
		_check(editor.mode == XREBlueprintTokenEditor.HINT, "the petal on the stem says what the trigger does")
		await _click_from(at, front)
		_check(petals.is_open() and _service.get("_petal_block") == setter, "the trigger on it opens the object's petals for its block")
		_service.cancel_connection()
		petals.close()
		_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
		await _frames()
	_service.connect_scene_target(setter, _host)
	await _frames()
	_check(petals.is_open() and _service.get("_petal_block") == setter and petals.get_object() == _host, "wiring the Target to an object opens its petals to pick the property")
	_service.cancel_connection()
	petals.close()

	# A number types on a keypad, in front of the card rather than in it.
	features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PUCKS)
	_service.add_block("delay")
	await _frames()
	var delay: int = graph.nodes.back()["id"]
	var keyboard := _service.get("_keyboard") as XREVirtualKeyboard
	_service.call("_open_token_keyboard", delay, "seconds", "", 1.0)
	await _frames()
	_check(keyboard.is_shown() and keyboard.is_keypad(), "a number opens the keypad")
	var token := _service.canvas.token_transform(delay, "seconds").origin
	var card := _card(delay).node
	var normal := card.global_basis.z.normalized()
	var top := keyboard.global_transform * Vector3(0, keyboard.size_m.y * 0.5, 0)
	var bottom := keyboard.global_transform * Vector3(0, -keyboard.size_m.y * 0.5, 0)
	_check((top - token).dot(normal) > 0.05 and (bottom - token).dot(normal) > 0.05, "the tilted keyboard stays in front of the card: %.2f, %.2f m" % [(top - token).dot(normal), (bottom - token).dot(normal)])
	var seven: Button = null
	for key: Button in keyboard.get("_keys") as Array:
		if key.text == "7" and key.is_visible_in_tree(): seven = key
	_check(seven != null, "the keypad has big digits")
	if seven != null:
		keyboard.value.text = ""
		keyboard.hover_pointer(_rig.right_hand, seven.get_global_rect().get_center())
		keyboard.press_pointer(_rig.right_hand)
		keyboard.release_pointer(_rig.right_hand)
		_check(keyboard.value.text == "7", "a digit types itself")
	keyboard.close()
	_service.call("_open_token_keyboard", delay, "seconds", "", Vector3.ONE)
	_check(keyboard.is_keypad() and not (keyboard.get("_comma") as Button).disabled, "a vector's keypad has the comma")
	_service.call("_open_token_keyboard", delay, "seconds", "", "door")
	_check(keyboard.is_shown() and not keyboard.is_keypad(), "text keeps the letters")
	keyboard.close()

	features.set_value(XREFeatureSettings.VALUE_INPUT, saved_values)
	features.set_value(XREFeatureSettings.TARGET_INPUT, saved_targets)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-058 after the fourth headset check: widgets over everything, moved by the
## grip and closed by their ×; windows before a wire being drawn; a second click
## in empty space takes back the wire and its menu; a token carried leaves its
## socket at once and leaves nothing drawn there; bigger tray tokens; cards
## without the plus; stems in the wire's colour.
func _test_widgets_and_wires() -> void:
	var features := _document.features
	var saved_values := features.get_value(XREFeatureSettings.VALUE_INPUT)
	var saved_targets := features.get_value(XREFeatureSettings.TARGET_INPUT)
	var saved_tray := features.get_value(XREFeatureSettings.TOKEN_TRAY)
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph
	var editor := _service.get("_token_editor") as XREBlueprintTokenEditor
	features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PUCKS)
	features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.SCENE)
	_service.add_block("set_property")
	await _frames()
	var setter: int = graph.nodes.back()["id"]
	_service.blueprint.choose_target(setter, _host)
	await _frames(4)
	var wire := _target_wire(setter)
	_check(wire != null and wire.stem != null and wire.stem.material_override is ShaderMaterial and wire.dot.material_override == wire.stem.material_override, "the petal's stem is the wire's own tube")

	var pointer := (_service.get("_pointers") as Array).filter(func(item: XREBlueprints.Pointer) -> bool: return item.hand == _rig.right_hand)[0] as XREBlueprints.Pointer
	_check((_service.get("_keyboard") as XREVirtualKeyboard).is_on_top(), "the keyboard is drawn over everything too")

	# A wire being drawn gives way to windows: a click on one lets the wire go.
	var debug := _panels.open_window(XREDebugTab)
	await _frames()
	var center := debug.pixel_to_global(debug.size_px * 0.5)
	var face := debug.global_basis.z.normalized()
	_service.click_port(setter, 0, true, _rig.right_hand)
	_check(_service.get("_pending_hand") == _rig.right_hand, "a wire from a port")
	_aim_from(center, face)
	await _frames(4)
	_check(_rig.right_hand.get_claimant() is XREPanels and _service.get("_pending_hand") == _rig.right_hand, "over a window the window has the ray and the wire waits")
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(_service.get("_pending_id") == -1, "a click on the window lets the wire go")
	_panels.call("_close_window", debug)
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await _frames()

	# Let go in empty space a wire opens the block menu; a second click there takes both back.
	_service.click_port(setter, 0, false, _rig.right_hand)
	var empty := _card(setter).node.global_position + Vector3(0.6, 0.4, 0.3)
	await _click_from(empty, Vector3.BACK)
	_check(_service.is_block_palette_shown() and _service.get("_pending_id") == setter, "the wire let go in empty space opens its menu")
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await _frames(4)
	await _click_from(empty + Vector3(-0.1, 0.1, 0.0), Vector3.BACK)
	_check(not _service.is_block_palette_shown() and _service.get("_pending_id") == -1, "a second click in empty space closes the menu and takes the wire back")

	# A token carried leaves its socket at once; an empty socket draws nothing.
	_service.add_block("delay")
	await _frames()
	var delay: int = graph.nodes.back()["id"]
	var token := _service.canvas.token_transform(delay, "seconds").origin
	var card_front := _card(delay).node.global_basis.z.normalized()
	var socket := (_card(delay).sockets.filter(func(item: XREBlueprintCanvas.Socket) -> bool: return item.key == "seconds"))[0] as XREBlueprintCanvas.Socket
	_aim_from(token, card_front)
	await _frames()
	_right.set_input(&"grip", 1.0)
	await _frames()
	_check(pointer.carried != null and not socket.visual.visible, "the grip takes the token itself: its socket is empty at once")
	_aim_from(token + _card(delay).node.global_basis.x * 0.5 + Vector3.UP * 0.4, card_front)
	await _frames()
	_right.set_input(&"grip", 0.0)
	await _frames(4)
	socket = (_card(delay).sockets.filter(func(item: XREBlueprintCanvas.Socket) -> bool: return item.key == "seconds"))[0] as XREBlueprintCanvas.Socket
	_check(is_equal_approx(float((graph.find_node(delay)["params"] as Dictionary).get("seconds", -1.0)), 1.0) and socket.visual.visible, "let go in the air, its port gets the default token back (D-059)")

	# Tray tokens fill their cells.
	features.set_value(XREFeatureSettings.TOKEN_TRAY, XREFeatureSettings.ON)
	await _frames(4)
	var tray := _panels.find_window(XREBlueprintTokensTab)
	var tray_tokens := _service.get("_tray_tokens") as Array
	if tray != null and not tray_tokens.is_empty():
		var cell := _service.token_tray.cell_rect(0).size.x * tray.size_m.x / tray.size_px.x
		var first := tray_tokens[0] as Node3D
		var extent := float(first.get_meta(&"extent")) * first.global_basis.get_scale().x
		_check(extent > cell * 0.6, "a tray token fills most of its cell: %.3f of %.3f m" % [extent, cell])
	else: _check(false, "the tray is open with tokens")
	features.set_value(XREFeatureSettings.TOKEN_TRAY, saved_tray)

	# Cards without the plus.
	_check(XREFeatureSettings.get_values(XREFeatureSettings.CARD_PLUS) == [XREFeatureSettings.HIDDEN, XREFeatureSettings.SHOWN], "Plus on cards: Hidden by default (D-076), Shown")
	_check(not _card(delay).plus_faces.is_empty(), "shown, a card has its plus")
	_document.set_feature(XREFeatureSettings.CARD_PLUS, XREFeatureSettings.HIDDEN, XREDocument.Source.PANEL)
	await _frames(4)
	var hidden := _card(delay)
	var plus := _service.canvas.to_global(hidden.node.transform * hidden.plus_point)
	_service.canvas.intersect_ray(plus + card_front * 0.4, -card_front, 1.0)
	_check(hidden.plus_faces.is_empty() and not _service.canvas.get_hit_plus(), "hidden, the card has no plus to hit")
	_document.set_feature(XREFeatureSettings.CARD_PLUS, XREFeatureSettings.SHOWN, XREDocument.Source.PANEL)
	await _frames(4)
	_check(not _card(delay).plus_faces.is_empty(), "shown again")

	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	features.set_value(XREFeatureSettings.VALUE_INPUT, saved_values)
	features.set_value(XREFeatureSettings.TARGET_INPUT, saved_targets)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-061: a vector token edited as in the headset — its Vector window and the
## arrows in front of it, at one scale: an axis pulled moves the white arrow
## with it, the white arrow moves every axis; past the end the value speeds on
## and the scale shrinks along a grid; Zero and Normalize; the grip on the
## arrows carries the window, its × closes them; all else is dimmed meanwhile.
func _test_vector_widget() -> void:
	var features := _document.features
	var saved_values := features.get_value(XREFeatureSettings.VALUE_INPUT)
	features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PUCKS)
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph
	var editor := _service.get("_token_editor") as XREBlueprintTokenEditor
	_service.add_block("set_property")
	await _frames()
	var setter: int = graph.nodes.back()["id"]
	_service.blueprint.choose_target(setter, _host)
	_service.call("_set_token", setter, "property", "position", "Set Token")
	_service.call("_set_token", setter, "value", Vector3(0.5, 0.5, 0.0), "Set Token")
	await _frames(4)
	var token := _service.canvas.token_transform(setter, "value").origin
	var front := _card(setter).node.global_basis.z.normalized()
	await _click_from(token, front)
	await _frames(3)
	var window := _panels.find_window(XREBlueprintVectorTab)
	_check(editor.mode == XREBlueprintTokenEditor.ARROWS and window != null, "a click on a vector token opens its Vector window with the arrows")
	if window == null or editor.mode != XREBlueprintTokenEditor.ARROWS:
		features.set_value(XREFeatureSettings.VALUE_INPUT, saved_values)
		while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
		return
	var face := window.global_basis.z.normalized()
	_check((editor.global_position - window.global_position).dot(face) > 0.0 and (editor.global_position - window.global_position).length() < 0.3, "the arrows stand in front of the window")
	_check(_service.is_focused() and (_service.get("_focus_dimmer") as Node3D).visible and window.is_on_top(), "all else is dimmed, the window drawn over it")
	_check(_service.vector_panel.components_text() == "X 0.5    Y 0.5    Z 0", "the window shows the components: %s" % _service.vector_panel.components_text())
	var head := _rig.camera.global_position
	_check(window.global_position.distance_to(head) <= XREBlueprints.NEAR_DISTANCE + 0.01 and window.global_position.y < head.y - 0.05, "the Vector window opens within a seated reach, below the eyes (D-064): %.2f m" % window.global_position.distance_to(head))
	_check(window.size_m.x < 0.36 and window.size_m.y < 0.4, "and is small: %s" % window.size_m)
	_check(window.global_basis.z.normalized().dot((head - window.global_position).normalized()) > 0.999, "tilted to face the head")
	var lengths := editor.get("_lengths") as Array
	var axes := editor.get("_axes") as Array
	# Meters per unit: the largest component is under 1, so a unit is ARROW_LENGTH long.
	var unit := XREBlueprintTokenEditor.ARROW_LENGTH
	_check(is_equal_approx(float(lengths[0]), 0.5 * unit) and is_equal_approx(float(lengths[1]), 0.5 * unit) and is_equal_approx(float(lengths[3]), Vector2(0.5, 0.5).length() * unit), "the arrows are drawn to one scale, the white one their sum")

	# An axis pulled: the white arrow goes with it.
	var on_y := editor.global_position + editor.axis_direction(1) * 0.25 * unit
	_aim_from(on_y, face)
	await _frames()
	_check((editor.get("_arrows")[1] as Node3D).scale.x > 1.1, "the arrow under the ray is lit")
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_aim_from(on_y + editor.axis_direction(1) * 0.5 * unit, face)
	await _frames()
	_check(is_equal_approx(float(lengths[1]), unit) and (axes[3] as Vector3).is_equal_approx((editor.axis_direction(0) * 0.5 + editor.axis_direction(1)).normalized()) and is_equal_approx(float(lengths[3]), Vector2(0.5, 1.0).length() * unit), "pulled, Y is longer and the white arrow follows it")
	_right.set_input(&"trigger", 0.0)
	await _frames(4)
	var value: Variant = _edited()
	_check(value is Vector3 and (value as Vector3).is_equal_approx(Vector3(0.5, 1.0, 0.0)), "let go, the token has it: %s" % value)
	_check(_service.vector_panel.components_text() == "X 0.5    Y 1    Z 0", "and so does the window")

	# The white arrow moves every component.
	var tip := editor.global_position + (axes[3] as Vector3) * float(lengths[3]) * 0.95
	_aim_from(tip, face)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_aim_from(tip + editor.axis_direction(0) * 0.2 * unit, face)
	await _frames()
	_check(is_equal_approx(float(lengths[0]), 0.7 * unit) and is_equal_approx(float(lengths[1]), unit), "moved, the white arrow takes the axis arrows with it")
	_right.set_input(&"trigger", 0.0)
	await _frames(4)
	value = _edited()
	_check(value is Vector3 and (value as Vector3).is_equal_approx(Vector3(0.7, 1.0, 0.0)), "the white arrow moved 0.2 units along X adds 0.2 to X: %s" % value)

	# Past its end the white arrow speeds on, the scale shrinking along a grid.
	tip = editor.global_position + (axes[3] as Vector3) * float(lengths[3]) * 0.95
	var scale_before := editor.get_arrow_scale()
	_aim_from(tip, face)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_aim_from(tip + (axes[3] as Vector3) * 0.3, face)
	var grid_shown := false
	for frame: int in 40:
		await get_tree().process_frame
		for tick: MeshInstance3D in editor.get("_grid") as Array: grid_shown = grid_shown or tick.visible
	var sped := editor.get_vector() as Vector3
	_check(sped.length() > XREBlueprintTokenEditor.VECTOR_MAX / scale_before + 0.1 and editor.get_arrow_scale() < scale_before and absf(float(lengths[3]) - XREBlueprintTokenEditor.VECTOR_MAX) < 0.02, "held past its end the vector grows on and the scale shrinks: %s" % sped)
	_check(grid_shown, "over a sliding scale")
	_right.set_input(&"trigger", 0.0)
	await _frames(4)
	value = _edited()
	_check(value is Vector3 and (value as Vector3).length() >= sped.length() - 0.01 and (value as Vector3).normalized().dot(Vector3(0.7, 1.0, 0.0).normalized()) > 0.99, "let go, the token has it, in the same direction: %s" % value)

	# An axis past its end does so too; the other arrows shrink with the scale.
	var y_before := float(lengths[1])
	var on_x := editor.global_position + editor.axis_direction(0) * float(lengths[0]) * 0.5
	_aim_from(on_x, face)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_aim_from(on_x + editor.axis_direction(0) * 0.35, face)
	for frame: int in 30: await get_tree().process_frame
	_check(absf(float(lengths[0]) - XREBlueprintTokenEditor.ARROW_MAX) < 0.02 and float(lengths[1]) < y_before, "X held past its end stays at its longest; Y shrinks with the scale")
	_right.set_input(&"trigger", 0.0)
	await _frames(4)

	# Zero and Normalize.
	_service.call("_vector_action", true)
	await _frames()
	value = _edited()
	_check(value is Vector3 and absf((value as Vector3).length() - 1.0) < 0.002, "Normalize makes it one long: %s" % value)
	_service.call("_vector_action", false)
	await _frames()
	value = _edited()
	_check(value is Vector3 and (value as Vector3).is_zero_approx(), "Zero makes it nothing")
	_check(graph.find_node(setter)["params"]["value"] == Vector3(0.5, 0.5, 0.0), "and the graph keeps the vector until Done (D-063)")
	_service.vector_panel.get_zero_button(0).pressed.emit()
	_service.call("_vector_action", true)
	_service.vector_panel.get_zero_button(1).pressed.emit()
	await _frames()
	_check(_edited() == Vector3.ZERO, "the small 0 by Y zeroes Y alone")
	_service.call("_preview_value_edit", Vector3(0.6, 0.8, 0.0), "")
	_service.vector_panel.get_zero_button(1).pressed.emit()
	await _frames()
	_check(_edited() == Vector3(0.6, 0.0, 0.0), "the small 0 by Y zeroes Y alone: %s" % _edited())
	_service.call("_preview_value_edit", Vector3(0.6, 0.8, 0.0), "")

	# The grip on the arrows carries the window, and they go with it.
	on_y = editor.global_position + editor.axis_direction(1) * 0.008
	_aim_from(on_y, face)
	await _frames()
	_right.set_input(&"grip", 1.0)
	await _frames()
	var window_before := window.global_position
	_aim_from(on_y + Vector3(0.0, 0.1, 0.0), face)
	await _frames(3)
	_check(window.global_position.distance_to(window_before + Vector3(0.0, 0.1, 0.0)) < 0.02 and (editor.global_position - window.global_position).length() < 0.3, "the grip on the arrows carries the window, the arrows with it")
	_right.set_input(&"grip", 0.0)
	await _frames()

	_check(not window.tab.has_control_bar(), "the Vector window has no Control Bar: its own × is in its header")
	# A click away from the window and the arrows closes them (D-062).
	await _click(Vector3(5, 4, -2))
	await _frames(3)
	_check(editor.mode != XREBlueprintTokenEditor.ARROWS and _panels.find_window(XREBlueprintVectorTab) == null, "a click away closes the arrows and their window")
	_document.select([_host], XREDocument.Source.TOOL)
	await _click_from(token, front)
	await _frames(3)
	window = _panels.find_window(XREBlueprintVectorTab)
	_check(editor.mode == XREBlueprintTokenEditor.ARROWS and window != null, "opened again")
	_check(graph.find_node(setter)["params"]["value"] == Vector3(0.5, 0.5, 0.0), "a click away kept nothing")
	_service.call("_preview_value_edit", Vector3(2.0, 0.0, 1.0), "")
	_service.vector_panel.close_pressed.emit()
	await _frames(3)
	_check(editor.mode != XREBlueprintTokenEditor.ARROWS and _panels.find_window(XREBlueprintVectorTab) == null, "the × in its header closes them")
	_check(graph.find_node(setter)["params"]["value"] == Vector3(0.5, 0.5, 0.0), "and puts the vector back")
	await _click_from(token, front)
	await _frames(3)
	var before_done := _service.blueprint.history.get_version()
	_service.call("_preview_value_edit", Vector3(2.0, 0.0, 1.0), "")
	_service.vector_panel.get_done_button().pressed.emit()
	await _frames(3)
	_check(graph.find_node(setter)["params"]["value"] == Vector3(2.0, 0.0, 1.0) and _service.blueprint.history.get_version() == before_done + 1, "Done keeps the vector, as one edit")
	_check(editor.mode != XREBlueprintTokenEditor.ARROWS and _panels.find_window(XREBlueprintVectorTab) == null, "and closes the window")
	await _click_from(token, front)
	await _frames(3)
	window = _panels.find_window(XREBlueprintVectorTab)
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await _frames()
	# The window's × closes the arrows; the dimming goes.
	_panels.call("_close_window", window)
	await _frames(3)
	_check(not editor.is_open() and (_service.get("_value_edit") as Dictionary).is_empty() and not _service.is_focused() and not (_service.get("_focus_dimmer") as Node3D).visible, "the window's × closes the arrows and the dimming goes")

	features.set_value(XREFeatureSettings.VALUE_INPUT, saved_values)
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-061: a variable wired straight into a port (an inline Get Variable with
## no card), the wires to a variable and to a scene object lit under the ray,
## and the member of an adapter picked with all else dimmed.
func _test_links_and_focus() -> void:
	var features := _document.features
	var saved := {}
	for key: StringName in [XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.TARGET_INPUT]: saved[key] = features.get_value(key)
	features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PLUGS)
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.BOXES)
	features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ADAPTER)
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph
	_service.blueprint.set_variable("speed", 3.0)
	_service.add_block("delay")
	await _frames(3)
	var delay: int = graph.nodes.back()["id"]
	var seconds_port := graph.input_port(graph.find_node(delay), "seconds")
	_service.call("_wire_box_to_port", "speed", delay, seconds_port)
	await _frames(3)
	var reader: Dictionary = graph.nodes.back()
	_check(reader["kind"] == "get_variable" and bool(reader.get("vr_inline", false)) and not _service.canvas.has_block(reader["id"]), "a box wired into a port is an inline Get Variable, with no card")
	var inline_wires := (_service.canvas.get("_wires") as Array).filter(func(wire: XREBlueprintCanvas.Wire) -> bool: return wire.variable == "speed")
	var from_box := (inline_wires[0] as XREBlueprintCanvas.Wire).mesh.get_point(0) - _service.canvas.get_boxes().box_point("speed") if inline_wires.size() == 1 else Vector3.INF
	var half := XREBlueprintBoxes.BOX_SIZE * 0.5 + Vector3.ONE * 0.0005
	var to_port := _service.canvas.port_position(delay, seconds_port, true) - _service.canvas.get_boxes().box_point("speed")
	_check(absf(from_box.x) <= half.x and absf(from_box.y) <= half.y and absf(from_box.z) <= half.z and from_box.normalized().dot(to_port.normalized()) > 0.999, "its wire comes straight from the box, aimed at its centre (D-063): %s" % from_box)
	_check((XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray).is_empty(), "and it builds")
	# Under the ray on the port its wire thickens.
	var port := _service.canvas.to_global(_service.canvas.port_position(delay, seconds_port, true))
	var front := _card(delay).node.global_basis.z.normalized()
	_aim_from(port, front)
	await _frames()
	_check(_service.canvas.is_edge_lit((inline_wires[0] as XREBlueprintCanvas.Wire).edge), "the ray on the port lights the variable's wire")
	# Detached, the inline block goes with its wire.
	_check(_service.click_port(delay, seconds_port, true, _rig.right_hand), "a click on the port")
	_service.cancel_connection()
	await _frames(3)
	_check(graph.find_node(reader["id"]).is_empty() and (graph.find_node(delay)["params"] as Dictionary).has("seconds"), "detached, the inline Get Variable goes and the port gets its default token")
	# A visible Get Variable shows no name by its socket: its wire goes to the box.
	_service.add_block("get_variable")
	await _frames()
	var getter: int = graph.nodes.back()["id"]
	_service.blueprint.set_parameter(getter, "variable", "speed")
	await _frames(3)
	var names := (_card(getter).sockets).filter(func(socket: XREBlueprintCanvas.Socket) -> bool: return socket.kind == XREBlueprintCanvas.MEMBER)
	_check(names.is_empty(), "a Get Variable card has no variable name by its socket")
	var variable_socket := -1
	for index: int in _card(getter).sockets.size():
		if _card(getter).sockets[index].kind == XREBlueprintCanvas.VARIABLE: variable_socket = index
	_service.canvas.hover_socket(getter, variable_socket, true)
	var link := (_service.canvas.get("_variable_links") as Array).filter(func(item: XREBlueprintCanvas.Wire) -> bool: return item.from == _card(getter))
	_check(not link.is_empty() and (link[0] as XREBlueprintCanvas.Wire).mesh.material_override == (link[0] as XREBlueprintCanvas.Wire).lit, "the ray on the Variable socket lights its wire to the box")
	_service.canvas.hover_socket(-1, -1, true)

	# The adapter: the ray on it lights its wire; its trigger picks a member with all else dimmed.
	_service.delete_block(getter)
	_service.delete_block(delay)
	await _frames()
	_service.add_block("set_property")
	await _frames()
	var setter: int = graph.nodes.back()["id"]
	_service.blueprint.choose_target(setter, _host)
	# Away from the other cards, so that nothing stands before its adapter.
	_service.canvas.preview_move(setter, Vector3(1.6, 0.9, 0.3))
	_service.canvas.commit_move(_service.blueprint, setter)
	await _frames(4)
	var adapter := (_card(setter).sockets).filter(func(socket: XREBlueprintCanvas.Socket) -> bool: return socket.kind == XREBlueprintCanvas.MEMBER)
	_check(not adapter.is_empty(), "the Target has its adapter")
	if not adapter.is_empty():
		var at := _service.canvas.to_global(_card(setter).node.transform * (adapter[0] as XREBlueprintCanvas.Socket).center)
		front = _card(setter).node.global_basis.z.normalized()
		_aim_from(at, front)
		await _frames()
		var wire := _target_wire(setter)
		var hit := _service.canvas.intersect_ray(at + front * 0.4, -front, 1.0)
		_check(wire != null and wire.mesh.material_override == wire.lit_material, "the ray on the adapter lights its wire to the object: hit %.3f kind %d id %d, wire %s" % [hit, _service.canvas.get_hit_socket_kind(), _service.canvas.get_hit_id(), wire != null])
		await _click_from(at, front)
		var petals := _service.get("_petals") as XREBlueprintPetals
		_check(petals.is_open() and _service.get("_petal_block") == setter, "the trigger on the adapter opens the object's petals")
		_check(_service.get("_pending_id") == -1 and _service.get("_link_hand") == null, "and draws no wire: the adapter only picks the member (D-062)")
		_check(_service.is_focused() and (_service.get("_focus_dimmer") as Node3D).visible and petals.get("_on_top"), "all else is dimmed, the petals over it")
		var fills := petals.find_children("*", "MeshInstance3D", true, false).filter(func(mesh: Node) -> bool: return (mesh as MeshInstance3D).material_override is BaseMaterial3D and ((mesh as MeshInstance3D).material_override as BaseMaterial3D).has_meta(&"under_text"))
		_check(not fills.is_empty() and fills.all(func(mesh: Node) -> bool: return ((mesh as MeshInstance3D).material_override as BaseMaterial3D).render_priority == Material.RENDER_PRIORITY_MAX), "the petals' fills too are drawn over the cards (D-062)")
		var shown := petals.get("_petals") as Array
		if shown.size() >= 2:
			var between := petals.to_global(((shown[0] as XREBlueprintPetals.Petal).center + (shown[1] as XREBlueprintPetals.Petal).center) * 0.5)
			var fan_front := petals.global_basis.z.normalized()
			_check(petals.intersect_ray(between + fan_front * 0.4, -fan_front, 5.0) >= 0, "the ray between two petals is still on the fan")
		await _frames()
		await _click(Vector3(5, 4, -2))
		_check(not petals.is_open() and not _service.is_focused(), "a click away from the petals closes them (D-062)")
		# The click on nothing let the scene's selection go: the tests after this one need it.
		_document.select([_host], XREDocument.Source.TOOL)
		_service.cancel_connection()
		await _frames()
		_check(not (_service.get("_focus_dimmer") as Node3D).visible, "closed, the dimming goes")
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	for key: StringName in saved: features.set_value(key, saved[key])
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-062: a number's line under the trigger, past its end speeding on; a
## choice picked by the ray on its value; π, e and fractions typed; one
## component of a vector typed in its window; the window see-through.
func _test_number_inputs() -> void:
	var features := _document.features
	var saved_values := features.get_value(XREFeatureSettings.VALUE_INPUT)
	features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PUCKS)
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph
	var editor := _service.get("_token_editor") as XREBlueprintTokenEditor

	# Typed constants and fractions.
	var typed := {"3π": 3.0 * PI, "π/2": PI / 2.0, "1/2π": PI / 2.0, "2e": 2.0 * exp(1.0), "-π": -PI, "2(1+π)": 2.0 * (1.0 + PI), "0.25": 0.25, "1/4": 0.25}
	for text: String in typed:
		var number: Variant = XREBlueprintTokens.parse_number(text)
		_check(number != null and is_equal_approx(float(number), float(typed[text])), "the keypad reads %s as %s: %s" % [text, typed[text], number])
	_check(XREBlueprintTokens.parse_number("door") == null and XREBlueprintTokens.parse_number("OS.kill(1)") == null, "and nothing but numbers")
	var keypad := _service.get("_keyboard") as XREVirtualKeyboard
	keypad.open_number("", 1)
	var labels: Array[String] = []
	for key: Button in keypad.get("_keys") as Array:
		if key.is_visible_in_tree(): labels.append(key.text)
	_check("π" in labels and "e" in labels and "/" in labels and "×" in labels, "the keypad has π, e, / and ×")
	keypad.close()

	# The number line: the ray along it, past its end speeding on.
	_service.add_block("delay")
	await _frames()
	var delay: int = graph.nodes.back()["id"]
	var token := _service.canvas.token_transform(delay, "seconds").origin
	var front := _card(delay).node.global_basis.z.normalized()
	var right := _card(delay).node.global_basis.x.normalized()
	_aim_from(token, front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	var ticks := (editor.get("_ticks") as Array).filter(func(tick: MeshInstance3D) -> bool: return tick.visible)
	_check(editor.mode == XREBlueprintTokenEditor.DIAL and ticks.size() >= 15, "a number held by the trigger shows its line of ticks: %d" % ticks.size())
	_aim_from(token + right * 0.3, front)
	for frame: int in 30: await get_tree().process_frame
	var sped: Variant = editor.get_line_value()
	_check(float(sped) > 1.0 + XREBlueprintTokenEditor.LINE_HALF / XREBlueprintTokenEditor.LINE_STEP_GAP * 0.1 + 0.2, "held past the line's end the number speeds on: %s" % sped)
	_right.set_input(&"trigger", 0.0)
	await _frames(3)
	_check(float(graph.find_node(delay)["params"]["seconds"]) >= float(sped) - 0.001, "let go, the token has it")

	# A choice: the ray on a value picks it.
	_service.add_block("signal")
	await _frames()
	var event: int = graph.nodes.back()["id"]
	var policy := _service.canvas.token_transform(event, "policy").origin
	front = _card(event).node.global_basis.z.normalized()
	_aim_from(policy, front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	var choices := editor.get("_choices") as Array
	_check(editor.mode == XREBlueprintTokenEditor.CHOICE and choices.size() == XREBlueprintTokens.POLICIES.size(), "a choice held by the trigger shows its values")
	if choices.size() == XREBlueprintTokens.POLICIES.size():
		var restart := (choices[2] as Label3D).global_position
		_aim_from(restart, editor.global_basis.z.normalized())
		await _frames()
		_right.set_input(&"trigger", 0.0)
		await _frames(3)
		_check(graph.find_node(event)["params"]["policy"] == XREBlueprintTokens.POLICIES[2], "the ray on a value picks it: %s" % graph.find_node(event)["params"]["policy"])
	_right.set_input(&"trigger", 0.0)
	await _frames()

	# One component of a vector, typed.
	_service.add_block("set_property")
	await _frames()
	var setter: int = graph.nodes.back()["id"]
	_service.blueprint.choose_target(setter, _host)
	_service.call("_set_token", setter, "property", "position", "Set Token")
	_service.call("_set_token", setter, "value", Vector3(1.0, 2.0, 3.0), "Set Token")
	await _frames(3)
	_service.call("_open_vector", setter, "value", "", Vector3(1.0, 2.0, 3.0))
	await _frames(3)
	var window := _panels.find_window(XREBlueprintVectorTab)
	_check(window != null and window.tab.get_frame_color().a < 0.9, "the Vector window is see-through")
	_service.vector_panel.get_component_button(1).pressed.emit()
	await _frames()
	_check(keypad.is_shown() and keypad.is_keypad(), "its Y button opens the keypad for Y")
	_service.call("_token_text_submitted", "π/2")
	await _frames(3)
	var value: Variant = _edited()
	_check(value is Vector3 and is_equal_approx((value as Vector3).y, PI / 2.0) and is_equal_approx((value as Vector3).x, 1.0) and is_equal_approx((value as Vector3).z, 3.0), "π/2 typed sets Y alone: %s" % value)
	_check(editor.mode == XREBlueprintTokenEditor.ARROWS, "the arrows stay open")
	_check(_service.vector_panel.components_text() == "X 1    Y π/2    Z 3", "the window shows Y as typed: %s" % _service.vector_panel.components_text())
	_service.vector_panel.get_done_button().pressed.emit()
	await _frames(3)
	var kept_block := graph.find_node(setter)
	_check(XREBlueprintTokens.expression_of(kept_block, "value") == "1, π/2, 3" and is_equal_approx((kept_block["params"]["value"] as Vector3).y, PI / 2.0), "Done keeps it with Y's expression: %s" % XREBlueprintTokens.expression_of(kept_block, "value"))
	var vector_label := (_service.canvas.call("_socket", setter, "value") as XREBlueprintCanvas.Socket).text
	_check(vector_label != null and vector_label.text == "(1, π/2, 3)", "the token shows it: %s" % (vector_label.text if vector_label != null else "none"))
	keypad.close()
	window = _panels.find_window(XREBlueprintVectorTab)
	if window != null: _panels.call("_close_window", window)
	await _frames()

	features.set_value(XREFeatureSettings.VALUE_INPUT, saved_values)
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## The value the Vector window shows now, not yet kept (D-063).
func _edited() -> Variant:
	return (_service.get("_value_edit") as Dictionary).get("value")


## D-063: expressions kept as typed, √ ^ + ( ) on a keypad with no letters,
## a click and a hold told apart on a number, zero for a Delay, the keyboard
## of one axis clear of the head, a click away from a fan selecting nothing,
## a box's wire opening the block menu, the menu's row of sections, and the
## graph of an object selected in the headset.
func _test_d063() -> void:
	var features := _document.features
	var saved := {}
	for key: StringName in [XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.TARGET_INPUT]: saved[key] = features.get_value(key)
	features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PUCKS)
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph
	var editor := _service.get("_token_editor") as XREBlueprintTokenEditor
	var keypad := _service.get("_keyboard") as XREVirtualKeyboard

	# Expressions.
	var typed := {"√2": sqrt(2.0), "2^3": 8.0, "2√(1+π)": 2.0 * sqrt(1.0 + PI), "(1+2": 3.0, "3+4×2": 11.0, "π^2/2": PI * PI / 2.0, "√π": sqrt(PI), "−2^2": -4.0}
	for text: String in typed:
		var number: Variant = XREBlueprintTokens.parse_number(text)
		_check(number != null and is_equal_approx(float(number), float(typed[text])), "the keypad reads %s as %s: %s" % [text, typed[text], number])
	_check(XREBlueprintTokens.parse_number("√") == null and XREBlueprintTokens.parse_number("2)") == null and XREBlueprintTokens.parse_number("sqrt(2)") == null, "and no broken or spelled-out ones")
	_check(XREBlueprintTokens.is_expression("π/2") and not XREBlueprintTokens.is_expression("1.5") and XREBlueprintTokens.is_expression("1, π, 0") and not XREBlueprintTokens.is_expression("1, 2"), "an expression is more than plain numbers")
	keypad.open_number("", 1)
	var labels: Array[String] = []
	for key: Button in keypad.get("_keys") as Array:
		if key.is_visible_in_tree(): labels.append(key.text)
	_check(not "ABC" in labels and not "q" in labels and not "Space" in labels, "the keypad has no way to the letters")
	for wanted: String in ["√", "^", "+", "−", "(", ")", "π", "e", "×", "/"]: _check(wanted in labels, "the keypad has %s" % wanted)
	keypad.close()

	# A Delay typed as π/2 keeps it; the token shows it, the keyboard reopens on it.
	_service.add_block("delay")
	await _frames()
	var delay: int = graph.nodes.back()["id"]
	_service.call("_open_token_keyboard", delay, "seconds", "", 1.0)
	_service.call("_token_text_submitted", "π/2")
	await _frames(3)
	var block := graph.find_node(delay)
	_check(is_equal_approx(float(block["params"]["seconds"]), PI / 2.0) and XREBlueprintTokens.expression_of(block, "seconds") == "π/2", "a number typed as π/2 keeps the expression")
	var label := (_service.canvas.call("_socket", delay, "seconds") as XREBlueprintCanvas.Socket).text
	_check(label != null and label.text == "π/2 s", "its token shows π/2 s: %s" % (label.text if label != null else "none"))
	_check((XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray).is_empty(), "and it builds")
	_service.call("_open_token_keyboard", delay, "seconds", "", PI / 2.0)
	_check(keypad.is_shown() and keypad.value.text == "π/2", "the keypad reopens on the expression: %s" % keypad.value.text)
	keypad.close()
	_service.set("_token_edit", {})

	# Held without a change the number shows its line; let go, no keyboard. A click types.
	var token := _service.canvas.token_transform(delay, "seconds").origin
	var front := _card(delay).node.global_basis.z.normalized()
	var right := _card(delay).node.global_basis.x.normalized()
	_aim_from(token, front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await get_tree().create_timer(float(XREBlueprints.CLICK_USEC) / 1000000.0 + 0.1).timeout
	_right.set_input(&"trigger", 0.0)
	await _frames(3)
	_check(not keypad.is_shown(), "held, then let go unchanged, a number opens no keyboard")
	await _click_from(token, front)
	await _frames()
	_check(keypad.is_shown() and keypad.is_keypad(), "a click on it opens the keypad")
	keypad.close()
	_service.set("_token_edit", {})
	await _frames()

	# A Delay of 0: the line stops at zero, and the graph takes it.
	_aim_from(token, front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_aim_from(token - right * 0.4, front)
	for frame: int in 30: await get_tree().process_frame
	_check(is_zero_approx(float(editor.get_line_value())), "past its left end a Delay's line stops at 0: %s" % editor.get_line_value())
	_right.set_input(&"trigger", 0.0)
	await _frames(3)
	block = graph.find_node(delay)
	_check(is_zero_approx(float(block["params"]["seconds"])) and XREBlueprintTokens.expression_of(block, "seconds").is_empty(), "a Delay of 0 s is kept, the expression dropped")
	_check(graph.validate().is_empty(), "and the graph allows it: %s" % [graph.validate()])
	var saved_delay := graph.find_node(delay).duplicate(true)
	for argument: Dictionary in saved_delay["function"]["args"]: if argument.get("key") == "seconds": argument["positive"] = true
	var old := XREBlueprintGraph.new()
	old.nodes.assign([saved_delay])
	old.upgrade()
	_check(not XREBlueprintTokens.positive(old.nodes[0], "seconds") and is_zero_approx(XREBlueprintTokens.minimum(old.nodes[0], "seconds", 1.0)), "a Delay saved when it had to be positive may be 0 when loaded")

	# The keyboard of one axis stands clear of the head.
	_service.add_block("set_property")
	await _frames()
	var setter: int = graph.nodes.back()["id"]
	_service.blueprint.choose_target(setter, _host)
	_service.call("_set_token", setter, "property", "position", "Set Token")
	_service.call("_set_token", setter, "value", Vector3(1.0, 2.0, 3.0), "Set Token")
	await _frames(3)
	_service.call("_open_vector", setter, "value", "", Vector3(1.0, 2.0, 3.0))
	await _frames(3)
	var window := _panels.find_window(XREBlueprintVectorTab)
	_service.vector_panel.get_component_button(0).pressed.emit()
	await _frames()
	var head := _rig.camera.global_position
	_check(keypad.is_shown() and keypad.global_position.distance_to(head) >= XREBlueprints.KEYBOARD_NEAREST - 0.001, "the keypad of an axis is clear of the head: %.2f m" % keypad.global_position.distance_to(head))
	if window != null:
		_check(absf(keypad.global_position.distance_to(head) - window.global_position.distance_to(head)) < 0.06 and keypad.global_position.y < window.global_position.y, "low on the window, about as far as it (D-067): %.2f m, the window %.2f m" % [keypad.global_position.distance_to(head), window.global_position.distance_to(head)])
	keypad.close()
	_service.set("_token_edit", {})
	_service.call("_end_vector", false)
	await _frames(3)

	# A click away from a fan over a scene object closes the fan and selects nothing.
	features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ADAPTER)
	await _frames(3)
	var petals := _service.get("_petals") as XREBlueprintPetals
	_service.call("_open_member_petals", setter, _rig.right_hand)
	await _frames(3)
	_check(petals.is_open(), "the trigger on the adapter opens its fan")
	var other := MeshInstance3D.new()
	other.name = "ClickAwayTarget"
	var box_mesh := BoxMesh.new()
	other.mesh = box_mesh
	other.custom_aabb = AABB(Vector3(-0.5, -0.5, -0.5), Vector3.ONE)
	other.position = Vector3(0, 1.4, 3.0)
	_document.add_node(other, _document.get_scene_root(), XREDocument.Source.PANEL)
	await _frames(3)
	_document.select([_host], XREDocument.Source.TOOL)
	await _frames(3)
	var selection := _document.get_selection()
	await _click_from(other.global_position, Vector3.FORWARD)
	await _frames(3)
	_check(not petals.is_open() and _document.get_selection() == selection, "a click away closes the fan and selects no scene object: %s" % [_document.get_selection()])
	features.set_value(XREFeatureSettings.TARGET_INPUT, saved[XREFeatureSettings.TARGET_INPUT])
	await _frames(3)

	# A box's wire let go in empty space opens the block menu for its value.
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.BOXES)
	_service.blueprint.set_variable("gain", 2.0)
	await _frames(3)
	_service.set("_link_kind", XREBlueprintCanvas.VARIABLE)
	_service.set("_link_box", "gain")
	_service.set("_link_hand", _rig.right_hand)
	await _click(Vector3(0.0, 1.4, -0.9) + Vector3(0.6, 0.6, 0.0))
	await _frames(3)
	_check(_service.is_block_palette_shown() and _service.block_menu.get_pin().get("type") == XREBlueprintGraph.NUMBER and _service.get("_link_box") == "gain", "a box's wire let go in empty space opens the block menu for a float")
	var before_count := graph.nodes.size()
	_service.block_menu.choose_chip(Array(_service.block_menu.get_chip_titles()).find("Library"))
	var delay_action := {}
	for action: Dictionary in _service.block_menu.get_listed():
		if action["title"] == "Delay": delay_action = action
	_check(not delay_action.is_empty(), "Delay is among the blocks that take a float")
	if not delay_action.is_empty():
		_service.block_menu.action_chosen.emit(delay_action)
		await _frames(3)
		var added: Dictionary = graph.nodes[before_count]
		var reader: Dictionary = graph.nodes.back()
		_check(added["kind"] == "call" and reader["kind"] == "get_variable" and reader["params"]["variable"] == "gain" and graph.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == reader["id"] and edge["to"] == added["id"]), "the block chosen gets the box wired into its float input")
	_service.close_block_palette()
	_service.cancel_connection()
	await _frames()

	# The menu's row of sections, under the chips, above the search.
	_service.open_block_menu()
	await _frames(3)
	var menu := _service.block_menu
	var sections := menu.get_section_titles()
	_check(sections.size() > 2 and sections[0] == "All" and "Node3D" in sections, "the menu has a row of sections, All first: %s" % [sections])
	_check(menu.get_node("Sections").get_index() < menu.search.get_index() and menu.get_node("Chips").get_index() < menu.get_node("Sections").get_index(), "under the chips, above the search")
	var everything := menu.get_listed().size()
	menu.choose_section("Node3D")
	var only := menu.get_listed()
	_check(only.size() > 0 and only.size() < everything, "a section lists only its blocks: %d of %d" % [only.size(), everything])
	menu.choose_section("")
	_check(menu.get_listed().size() == everything, "All lists them all again")
	_service.close_block_palette()
	await _frames()

	features.set_value(XREFeatureSettings.VALUE_INPUT, saved[XREFeatureSettings.VALUE_INPUT])
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, saved[XREFeatureSettings.VARIABLE_INPUT])
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()

	# Selecting an object in the headset opens its graph: a new one, saved with its first change.
	var path := _service.blueprint.path
	_document.select([other], XREDocument.Source.TOOL)
	await _frames(3)
	_check(_service.is_open() and _service.blueprint.get_host() == other and _service.blueprint.path.is_empty() and not _service.blueprint.is_dirty(), "selecting an object with no Blueprint opens a new graph for it, unsaved")
	_document.select([_host], XREDocument.Source.TOOL)
	await _frames(3)
	_check(_service.blueprint.path == path and _service.blueprint.get_host() == _host, "selecting the host again opens its graph")
	_check(other.get_meta(&"_xre_blueprint", "") == "", "the untouched new graph left nothing behind")
	_document.select([other], XREDocument.Source.TOOL)
	await _frames(3)
	_service.add_block("print")
	await _frames(3)
	var made: String = str(other.get_meta(&"_xre_blueprint", ""))
	_check(not made.is_empty() and FileAccess.file_exists(made) and _service.blueprint.path == made, "its first change saves it beside the scene and assigns it: %s" % made)
	_document.select([_host], XREDocument.Source.TOOL)
	await _frames(3)
	_check(_service.blueprint.path == path, "and the host's graph opens again")
	_document.remove_nodes([other], XREDocument.Source.PANEL)
	await _frames(3)


## Points the right ray at [param point], a point of the canvas, from the head's side, 0.4 m away.
func _aim_at_wire(point: Vector3) -> Vector3:
	var at := _service.canvas.to_global(point)
	var front := (_rig.camera.global_position - at).normalized()
	_aim_from(at, front)
	return front


## The point of graph edge [param edge]'s wire halfway along its tube number [param piece], in the canvas's space.
func _wire_middle(edge: int, piece: int = 0) -> Vector3:
	var pieces := _service.canvas.wire_pieces(edge)
	return pieces[piece].get_point(XREGraphWire.SAMPLES / 2) if piece < pieces.size() else Vector3.ZERO


## Presses the right [param button] — trigger or grip — at the wire's point
## [param point], drags it by [param offset] across the ray, and lets go.
func _drag_wire(point: Vector3, offset: Vector3, button: StringName = &"trigger") -> void:
	var front := _aim_at_wire(point)
	await _frames()
	_right.set_input(button, 1.0)
	await _frames()
	var at := _service.canvas.to_global(point)
	for step: int in range(1, 6):
		_aim_from(at + offset * (step / 5.0), front)
		await _frames(1)
	await _frames()
	_right.set_input(button, 0.0)
	await _frames()


## Presses the delete button (X) with the right ray at the wire's point [param point].
func _delete_at_wire(point: Vector3) -> void:
	_aim_at_wire(point)
	await _frames()
	_left.set_input(&"ax_button", true)
	await _frames()
	_left.set_input(&"ax_button", false)
	await _frames()


## D-081: wires bend while Wire bends is on, as edges in draw.io — trigger or
## grip on a wire drags a bend out of it, on a knot moves the bend, the delete
## button takes bends off, never the selected block; off, the ray passes
## through wires as before.
func _test_wire_bends() -> void:
	var features := _document.features
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph
	var canvas := _service.canvas
	_service.add_block("print")
	await _frames()
	var from: int = graph.nodes.back()["id"]
	_service.add_block("print")
	await _frames()
	var to: int = graph.nodes.back()["id"]
	# Below the other cards and nearer the head, so that nothing is in front of the wire.
	canvas.preview_move(from, Vector3(-0.25, -0.7, 0.25))
	canvas.commit_move(_service.blueprint, from)
	canvas.preview_move(to, Vector3(0.25, -0.62, 0.25))
	canvas.commit_move(_service.blueprint, to)
	await _frames()
	_check(_service.click_port(from, 0, false) and _service.click_port(to, 0, true), "a wire to bend")
	await _frames()
	_service.close_parameters()
	_service.close_block_palette()
	_service.select_block(from, false)
	await _frames()
	var edge := graph.edges.size() - 1
	_check(graph.edges[edge]["from"] == from and graph.edges[edge]["to"] == to, "the wire is the last edge")

	# Off, as before: the wire takes no ray.
	_check(XREFeatureSettings.get_default(XREFeatureSettings.WIRE_BENDS) == XREFeatureSettings.ON, "Wire bends is on by default (D-089)")
	_check(features.get_value(XREFeatureSettings.WIRE_BENDS) == XREFeatureSettings.OFF and not canvas.get_bends_shown(), "Wire bends is off at the start of the checks")
	_aim_at_wire(_wire_middle(edge))
	await _frames()
	_check(not canvas.is_ghost_shown(true) and not canvas.is_edge_lit(edge), "off, the ray on a wire neither lights it nor marks a bend")

	_check(_document.set_feature(XREFeatureSettings.WIRE_BENDS, XREFeatureSettings.ON, XREDocument.Source.PANEL) and _operations.back() == &"set_feature", "Wire bends switches on, in the log")
	await _frames()
	_check(canvas.get_bends_shown(), "the open graph bends its wires")
	var middle := _wire_middle(edge)
	_aim_at_wire(middle)
	await _frames()
	_check(canvas.is_ghost_shown(true) and canvas.is_edge_lit(edge), "on, the ray on a wire thickens it and marks where a bend would go")

	# Trigger: a new bend dragged out of the wire, kept as one edit.
	var front := _aim_at_wire(middle)
	var up := (Vector3.UP - front * front.dot(Vector3.UP)).normalized()
	var at := canvas.to_global(middle)
	var version := _service.blueprint.history.get_version()
	_operations.clear()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(_service.is_holding(_rig.right_hand), "a bend in hand holds the hand, as a card does")
	for step: int in range(1, 6):
		_aim_from(at + up * (0.12 * step / 5.0), front)
		await _frames(1)
	await _frames()
	_check(_service.blueprint.history.get_version() == version, "dragging previews without history")
	_check(canvas.bend_count(edge) == 1 and canvas.wire_knot(edge, 0) != null and canvas.wire_knot(edge, 0).global_position.distance_to(at + up * 0.12) < 0.02, "the new bend follows the ray's end")
	_right.set_input(&"trigger", 0.0)
	await _frames()
	var bends: PackedVector3Array = graph.edges[edge].get("vr_bends", PackedVector3Array())
	_check(_service.blueprint.history.get_version() == version + 1 and bends.size() == 1 and &"bend_wire" in _operations, "let go, the bend is one edit in the log: %s" % [_operations])
	var knot := canvas.to_global(canvas.wire_bends(edge)[0])
	_check(knot.distance_to(at + up * 0.12) < 0.02, "it stays where it was let go")
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await _frames()
	_check(_rig.right_hand.is_free_for(self) and not _service.is_holding(_rig.right_hand), "the hand is let go with it")

	# A click without a drag adds nothing.
	version = _service.blueprint.history.get_version()
	_aim_at_wire(_wire_middle(edge, 1))
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(_service.blueprint.history.get_version() == version and canvas.bend_count(edge) == 1, "a click on a wire adds no bend")

	# Grip on the knot moves it; undo puts it back.
	var knot_point := canvas.wire_bends(edge)[0]
	_aim_at_wire(knot_point)
	await _frames()
	_check(canvas.is_bend_hovered(edge, 0) and not canvas.is_ghost_shown(true), "the knot under the ray grows, no new bend is marked")
	var down := -up * 0.08
	await _drag_wire(knot_point, down, &"grip")
	_check(canvas.bend_count(edge) == 1 and _service.blueprint.history.get_version() == version + 1, "grip on the knot moves the bend, one edit")
	_check(canvas.to_global(canvas.wire_bends(edge)[0]).distance_to(knot + down) < 0.02, "to where the grip let it go")
	_service.blueprint.undo()
	await _frames()
	_check(canvas.to_global(canvas.wire_bends(edge)[0]).distance_to(knot) < 0.001, "undo puts the bend back")
	_service.blueprint.redo()
	await _frames()
	_check(canvas.to_global(canvas.wire_bends(edge)[0]).distance_to(knot + down) < 0.02, "redo moves it again")
	var pieces := canvas.wire_pieces(edge)
	_check(pieces.size() == 2 and pieces[0].get_point(0).is_equal_approx(canvas.port_position(from, 0, false)) and pieces[1].get_point(XREGraphWire.SAMPLES - 1).is_equal_approx(canvas.port_position(to, 0, true)), "the bent wire still runs from port to port")

	# The delete button: a knot, then all bends; never the selected block.
	var blocks := graph.nodes.size()
	await _drag_wire(_wire_middle(edge, 1), up * 0.1)
	_check(canvas.bend_count(edge) == 2, "a second bend")
	_operations.clear()
	await _delete_at_wire(canvas.wire_bends(edge)[1])
	_check(canvas.bend_count(edge) == 1 and (graph.edges[edge]["vr_bends"] as PackedVector3Array).size() == 1 and &"remove_bend" in _operations, "the delete button on a knot takes that bend off")
	await _drag_wire(_wire_middle(edge, 1), up * 0.1)
	await _delete_at_wire(_wire_middle(edge, 0))
	_check(canvas.bend_count(edge) == 0 and not graph.edges[edge].has("vr_bends") and &"straighten_wire" in _operations, "on the wire it takes all its bends off")
	await _delete_at_wire(_wire_middle(edge, 0))
	_check(graph.nodes.size() == blocks and not graph.find_node(from).is_empty(), "on a straight wire it deletes nothing, not the selected block")

	# While a wire is drawn, wires take no ray.
	await _drag_wire(_wire_middle(edge), up * 0.1)
	_check(_service.click_port(to, 0, false, _rig.right_hand), "a new wire is drawn")
	_aim_at_wire(_wire_middle(edge, 1))
	await _frames()
	_check(not canvas.is_ghost_shown(true) and not canvas.is_edge_lit(edge), "a wire being drawn passes over other wires")
	_service.cancel_connection()
	await _frames()

	# A block's wire to its object in the scene bends too, its bends kept on the block.
	_service.add_block("set_property")
	await _frames()
	var setter: int = graph.nodes.back()["id"]
	canvas.preview_move(setter, Vector3(0.0, -0.45, 0.3))
	canvas.commit_move(_service.blueprint, setter)
	_service.blueprint.choose_target(setter, _host)
	_service.close_parameters()
	_service.close_block_palette()
	await _frames(4)
	var target_wire := _target_wire(setter)
	_check(target_wire != null and target_wire.canvas_wire != null and target_wire.mesh == target_wire.canvas_wire.mesh, "the Target wire to the object is a link of the canvas")
	if target_wire != null:
		var key := target_wire.canvas_wire.edge
		var on_link := target_wire.canvas_wire.pieces[0].get_point(XREGraphWire.SAMPLES / 2)
		_aim_at_wire(on_link)
		await _frames()
		_check(canvas.is_edge_lit(key) and canvas.is_ghost_shown(true), "the ray on a Target wire marks a bend: lit %s, ghost %s" % [canvas.is_edge_lit(key), canvas.is_ghost_shown(true)])
		_check(target_wire.mesh.material_override == target_wire.lit_material, "and thickens the wire")
		# A wire that may become a link (D-074) bends too: Link from wire on Wire button puts its button above it, off the ray.
		var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
		var lifted := pointer.button.global_position - canvas.to_global(on_link) if pointer.button != null else Vector3.ZERO
		_check(pointer.button != null and pointer.button.visible and pointer.button_make and lifted.dot(Vector3.UP) > XREBlueprintPetals.PILL_HEIGHT * 0.5,
				"with Wire button the link button stands above the wire, off the ray")
		version = _service.blueprint.history.get_version()
		await _drag_wire(on_link, up * 0.1)
		var kept: Variant = graph.find_node(setter).get(XREBlueprintGraph.SCENE_BENDS)
		_check(_service.blueprint.history.get_version() == version + 1 and kept is PackedVector3Array and (kept as PackedVector3Array).size() == 1, "dragged, it keeps its bend on its block, in one edit")
		_check(not XREBlueprintLinks.is_link(graph.find_node(setter), XREBlueprintLinks.TARGET), "the trigger on the wire bends it and makes no link")
		target_wire = _target_wire(setter)
		_check(target_wire != null and target_wire.canvas_wire.knots.size() == 1, "the Target wire bends there")
		_service.blueprint.undo()
		await _frames()
		target_wire = _target_wire(setter)
		_check(not graph.find_node(setter).has(XREBlueprintGraph.SCENE_BENDS) and target_wire != null and target_wire.canvas_wire.knots.is_empty(), "undo straightens it")
		# Pull: the grip pulls the wire into its port (D-074), the trigger still bends it.
		features.set_value(XREFeatureSettings.LINK_CREATE, XREFeatureSettings.PULL)
		await _frames()
		_aim_at_wire(on_link)
		await _frames()
		_right.set_input(&"grip", 1.0)
		await _frames()
		target_wire = _target_wire(setter)
		_check(not pointer.pull.is_empty() and pointer.bend_edge < 0 and target_wire != null and not target_wire.mesh.visible, "with Pull the grip on the wire pulls it into its port, no bend")
		_right.set_input(&"grip", 0.0)
		await _frames(2)
		_check(pointer.pull.is_empty() and not XREBlueprintLinks.is_link(graph.find_node(setter), XREBlueprintLinks.TARGET), "let go where it was taken, it stays a wire")
		version = _service.blueprint.history.get_version()
		await _drag_wire(on_link, up * 0.1)
		_check(_service.blueprint.history.get_version() == version + 1 and graph.find_node(setter).has(XREBlueprintGraph.SCENE_BENDS), "with Pull the trigger still bends it")
		_service.blueprint.undo()
		await _frames()
		features.set_value(XREFeatureSettings.LINK_CREATE, XREFeatureSettings.WIRE_BUTTON)
		await _frames()

	# Off again: drawn as before, the bends kept.
	_check(_document.set_feature(XREFeatureSettings.WIRE_BENDS, XREFeatureSettings.OFF, XREDocument.Source.PANEL), "Wire bends switches off")
	await _frames()
	_check(canvas.wire_pieces(edge).size() == 1 and canvas.wire_knot(edge, 0) == null and graph.edges[edge].has("vr_bends"), "off, one tube again, the graph keeps the bend")
	_aim_at_wire(_wire_middle(edge))
	await _frames()
	_check(not canvas.is_ghost_shown(true) and not canvas.is_edge_lit(edge), "and the ray passes through the wire")
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await _frames()
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-090: the rays over the block palette with no card in focus; a block from
## the menu with no card to go beside where the menu was, one beside a card as
## deep as it; the variables' boxes turned to the head; Link from wire on Wire
## menu — the trigger held on a wire opens Link, Point or Delete point, done as
## it lets go —; and Auto link.
func _test_d090() -> void:
	var features := _document.features
	var graph := _service.blueprint.graph
	var canvas := _service.canvas
	var history := _service.blueprint.history.get_version()
	_check(XREFeatureSettings.get_values(XREFeatureSettings.AUTO_LINK) == [XREFeatureSettings.ON, XREFeatureSettings.OFF], "Auto link is a setting, on by default (D-114)")

	# The rays over the block palette, drawn over everything (D-086), though no card is in focus.
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	_service.select_block(-1)
	await _frames()
	_service.open_block_menu()
	await _frames(3)
	var window := _panels.find_window(XREBlueprintPaletteTab)
	_check(window != null and window.is_on_top() and not canvas.is_front_focused() and bool(_service.get("_rays_on_top")), "the rays are drawn over the block palette with no card in focus")
	# Its block, with no card to go beside, goes where the menu was, not far along the graph.
	var menu_at := window.global_position if window != null else Vector3.ZERO
	var count := graph.nodes.size()
	_service.add_block("print")
	await _frames(2)
	var added: int = graph.nodes.back()["id"]
	var gap := canvas.to_global(canvas.get_block_position(added)).distance_to(menu_at)
	_check(graph.nodes.size() == count + 1 and gap < 0.5, "a block added with no card goes where the menu was: %.2f m from it" % gap)
	_check(not _service.is_block_palette_shown() and not bool(_service.get("_rays_on_top")), "the palette closed, the rays are drawn as before")
	canvas.preview_move(added, canvas.get_block_position(added) + Vector3(0, 0, 0.3))
	canvas.commit_move(_service.blueprint, added)
	await _frames()
	_service.select_block(added, false)
	_service.add_block("print")
	await _frames(2)
	var beside: int = graph.nodes.back()["id"]
	_check(is_equal_approx(float(graph.find_node(beside).get("vr_depth", 0.0)), float(graph.find_node(added)["vr_depth"])), "a block added beside the selected card is as deep as it")

	# The variables' boxes turn to the head, as billboard cards do; with cuboid cards they don't.
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.BOXES)
	_service.blueprint.set_variable("menu_gain", 2.0)
	await _frames(3)
	var right := -INF
	for card: XREBlueprintCanvas.Card in canvas.get("_cards") as Array: right = maxf(right, card.node.position.x + card.width * 0.5)
	var box_at := Vector3(right + 0.4, -1.1, 0.2)
	canvas.preview_box_move("menu_gain", box_at)
	canvas.commit_box_move(_service.blueprint, "menu_gain")
	await _frames(3)
	var boxes := canvas.get_boxes()
	var box := boxes.get_node_or_null("Box_menu_gain") as Node3D
	var toward := (_rig.camera.global_position - box.global_position).normalized() if box != null else Vector3.ZERO
	_check(box != null and box.global_basis.z.normalized().dot(toward) > 0.999 and absf(box.global_basis.x.normalized().dot(Vector3.UP)) < 0.001, "a variable's box turns to the head, its rows level")
	var box_origin := (box.global_position if box != null else Vector3.ZERO) + toward * 0.4
	_check(canvas.intersect_ray(box_origin, -toward, 1.0) >= 0.0 and canvas.get_hit_box() and boxes.get_hit_name() == "menu_gain", "the ray from the head takes the turned box")
	features.set_value(XREFeatureSettings.NODE_FACING, XREFeatureSettings.OFF)
	await _frames(3)
	box = boxes.get_node_or_null("Box_menu_gain") as Node3D
	_check(box != null and box.basis.orthonormalized().is_equal_approx(Basis.IDENTITY), "with cuboid cards it keeps the graph's orientation")
	features.set_value(XREFeatureSettings.NODE_FACING, XREFeatureSettings.ON)
	await _frames(3)

	# Wire menu: the trigger on a wire from a box opens Link and Point; let go on Link, a link.
	features.set_value(XREFeatureSettings.WIRE_BENDS, XREFeatureSettings.ON)
	features.set_value(XREFeatureSettings.LINK_CREATE, XREFeatureSettings.WIRE_MENU)
	_service.add_block("delay")
	await _frames()
	var delay: int = graph.nodes.back()["id"]
	_service.add_block("delay")
	await _frames()
	var other: int = graph.nodes.back()["id"]
	for item: Array in [[delay, box_at + Vector3(0.45, 0.35, 0.0)], [other, box_at + Vector3(1.0, 0.35, 0.0)]]:
		canvas.preview_move(int(item[0]), item[1])
		canvas.commit_move(_service.blueprint, int(item[0]))
		await _frames()
	var seconds := graph.input_port(graph.find_node(delay), "seconds")
	_service.call("_wire_box_to_port", "menu_gain", delay, seconds)
	_service.close_parameters()
	_service.close_block_palette()
	await _frames(3)
	var getter := canvas.inline_getter(delay, seconds)
	var ref := XREBlueprintLinks.ref(getter, XREBlueprintLinks.VARIABLE, delay, seconds)
	var mesh := canvas.ref_wire(ref)
	var menu := _service.get("_wire_menu") as XREArcMenu
	_check(getter >= 0 and mesh != null and mesh.visible, "a wire from the box into Seconds")
	var middle := mesh.get_point(XREGraphWire.SAMPLES / 2) if mesh != null else Vector3.ZERO
	_aim_at_wire(middle)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(_service.is_wire_menu_open() and _service.is_focused() and menu.get_shown() == [XREBlueprints.WIRE_LINK, XREBlueprints.WIRE_POINT], "the trigger on it opens its menu, Link and Point, the rest dark")
	_check(_service.get_wire_menu_lit() == -1, "the ray where it was picks nothing")
	_aim_from(_service.get_wire_menu_button(XREBlueprints.WIRE_LINK), menu.global_basis.z.normalized())
	await _frames()
	_check(_service.get_wire_menu_lit() == XREBlueprints.WIRE_LINK, "the ray on Link lights it")
	_operations.clear()
	_right.set_input(&"trigger", 0.0)
	await _frames(2)
	_check(not _service.is_wire_menu_open() and XREBlueprintLinks.is_link(graph.find_node(getter), XREBlueprintLinks.VARIABLE) and &"make_link" in _operations, "let go on Link, the wire is a link, a logged edit")
	# The trigger on the link makes it its wire again, with no wire button.
	var link := _link_socket(delay)
	var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
	var link_front := _card(delay).node.global_basis.z.normalized()
	var link_point := _card(delay).node.global_transform * link.center if link != null else Vector3.ZERO
	_aim_from(link_point, link_front)
	await _frames()
	_check(link != null and (pointer.button == null or not pointer.button.visible), "with Wire menu the ray on a link puts up no wire button")
	_operations.clear()
	await _click_from(link_point, link_front)
	await _frames(2)
	_check(not XREBlueprintLinks.is_link(graph.find_node(getter), XREBlueprintLinks.VARIABLE) and &"unlink" in _operations, "the trigger on the link makes it its wire again")
	if XREBlueprintLinks.is_link(graph.find_node(getter), XREBlueprintLinks.VARIABLE): _service.call("_set_link", ref, false)
	await _frames(2)

	# Point on the box's wire: a bend where the ray was, one edit.
	var box_edge := -1
	for index: int in graph.edges.size():
		if graph.edges[index]["from"] == getter and graph.edges[index]["to"] == delay: box_edge = index
	mesh = canvas.ref_wire(ref)
	middle = mesh.get_point(XREGraphWire.SAMPLES / 2) if mesh != null else Vector3.ZERO
	_aim_at_wire(middle)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(_service.is_wire_menu_open() and menu.get_shown() == [XREBlueprints.WIRE_LINK, XREBlueprints.WIRE_POINT], "the menu again, Link and Point")
	_aim_from(_service.get_wire_menu_button(XREBlueprints.WIRE_POINT), menu.global_basis.z.normalized())
	await _frames()
	var version := _service.blueprint.history.get_version()
	_operations.clear()
	_right.set_input(&"trigger", 0.0)
	await _frames(2)
	_check(box_edge >= 0 and canvas.bend_count(box_edge) == 1 and _service.blueprint.history.get_version() == version + 1 and &"add_bend" in _operations, "let go on Point, a bend, one edit in the log: %s" % [_operations])
	_check(box_edge >= 0 and canvas.bend_count(box_edge) == 1 and canvas.wire_bends(box_edge)[0].distance_to(middle) < 0.02, "where the ray was on the wire")
	# On its knot: Link and Delete point.
	_aim_at_wire(canvas.wire_bends(box_edge)[0] if box_edge >= 0 and canvas.bend_count(box_edge) > 0 else Vector3.ZERO)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(_service.is_wire_menu_open() and menu.get_shown() == [XREBlueprints.WIRE_LINK, XREBlueprints.WIRE_UNBEND], "on its knot the menu has Link and Delete point: open %s, %s, hit bend %d" % [_service.is_wire_menu_open(), menu.get_shown(), canvas.get_hit_bend()])
	_aim_from(_service.get_wire_menu_button(XREBlueprints.WIRE_UNBEND), menu.global_basis.z.normalized())
	await _frames()
	_operations.clear()
	_right.set_input(&"trigger", 0.0)
	await _frames(2)
	_check(canvas.bend_count(box_edge) == 0 and &"remove_bend" in _operations, "let go on Delete point, the bend is gone")
	# Let go where it opened: nothing.
	version = _service.blueprint.history.get_version()
	mesh = canvas.ref_wire(ref)
	middle = mesh.get_point(XREGraphWire.SAMPLES / 2) if mesh != null else Vector3.ZERO
	_aim_at_wire(middle)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames(2)
	_check(not _service.is_wire_menu_open() and _service.blueprint.history.get_version() == version and canvas.bend_count(box_edge) == 0, "let go on no button, the menu only closes")
	# The other hand's trigger closes it.
	_aim_at_wire(middle)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_left.set_input(&"trigger", 1.0)
	await _frames(2)
	_check(not _service.is_wire_menu_open() and _service.blueprint.history.get_version() == version, "the other hand's trigger closes the menu, nothing done")
	_left.set_input(&"trigger", 0.0)
	_right.set_input(&"trigger", 0.0)
	await _frames(2)
	# The grip still drags a bend out of it.
	var front := _aim_at_wire(middle)
	var up := (Vector3.UP - front * front.dot(Vector3.UP)).normalized()
	await _drag_wire(middle, up * 0.1, &"grip")
	_check(canvas.bend_count(box_edge) == 1 and _service.blueprint.history.get_version() == version + 1, "the grip on a wire still drags a bend out of it")
	_service.blueprint.undo()
	await _frames(2)

	# An execution wire has only a bend to give: no menu, the trigger drags it out as without the menu.
	_check(_service.click_port(delay, 0, false) and _service.click_port(other, 0, true), "an execution wire")
	_service.close_parameters()
	_service.close_block_palette()
	await _frames(2)
	var edge := graph.edges.size() - 1
	middle = _wire_middle(edge)
	front = _aim_at_wire(middle)
	await _frames()
	version = _service.blueprint.history.get_version()
	_operations.clear()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(not _service.is_wire_menu_open() and _service.is_holding(_rig.right_hand), "on an execution wire no menu: the trigger takes a bend")
	var at := canvas.to_global(middle)
	for step: int in range(1, 6):
		_aim_from(at + up * (0.1 * step / 5.0), front)
		await _frames(1)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames(2)
	_check(canvas.bend_count(edge) == 1 and _service.blueprint.history.get_version() == version + 1 and &"bend_wire" in _operations, "let go, the bend is one edit: %s" % [_operations])
	# With Wire bends off a wire from a box has only Link to give: the trigger makes it at once.
	features.set_value(XREFeatureSettings.WIRE_BENDS, XREFeatureSettings.OFF)
	await _frames(2)
	mesh = canvas.ref_wire(ref)
	var on_wire := canvas.to_global(mesh.get_point(XREGraphWire.SAMPLES / 2)) if mesh != null else Vector3.ZERO
	_operations.clear()
	await _click_from(on_wire, (_rig.camera.global_position - on_wire).normalized())
	await _frames(2)
	_check(not _service.is_wire_menu_open() and XREBlueprintLinks.is_link(graph.find_node(getter), XREBlueprintLinks.VARIABLE) and &"make_link" in _operations, "with Wire bends off the trigger on a wire from a box makes the link at once, no menu")
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await _frames()

	# Auto link: a new wire to a variable with more than one already, running far, is a link.
	features.set_value(XREFeatureSettings.LINK_CREATE, XREFeatureSettings.WIRE_BUTTON)
	features.set_value(XREFeatureSettings.AUTO_LINK, XREFeatureSettings.ON)
	_service.blueprint.set_variable("auto_gain", 1.0)
	await _frames(2)
	var auto_at := box_at + Vector3(0.0, -0.5, 0.0)
	canvas.preview_box_move("auto_gain", auto_at)
	canvas.commit_box_move(_service.blueprint, "auto_gain")
	await _frames(2)
	var delays: Array[int] = []
	for place: Vector3 in [Vector3(1.0, 0.0, 0.0), Vector3(1.0, -0.25, 0.0), Vector3(1.0, -0.5, 0.0), Vector3(0.3, 0.05, 0.0), Vector3(1.0, -0.75, 0.0)]:
		_service.add_block("delay")
		await _frames()
		var id: int = graph.nodes.back()["id"]
		canvas.preview_move(id, auto_at + place)
		canvas.commit_move(_service.blueprint, id)
		delays.append(id)
	await _frames()
	var linked: Array[bool] = []
	for index: int in delays.size():
		if index == delays.size() - 1: features.set_value(XREFeatureSettings.AUTO_LINK, XREFeatureSettings.OFF)
		var port := graph.input_port(graph.find_node(delays[index]), "seconds")
		_service.call("_wire_box_to_port", "auto_gain", delays[index], port)
		await _frames(2)
		var reader := canvas.inline_getter(delays[index], port)
		linked.append(reader >= 0 and XREBlueprintLinks.is_link(graph.find_node(reader), XREBlueprintLinks.VARIABLE))
	_check(linked == [false, false, true, false, false], "with Auto link only the third far wire becomes a link; a near one and one with it off stay wires: %s" % [linked])
	# For an object too: blocks the block menu adds for it, with their Target, as an edit of its window.
	features.set_value(XREFeatureSettings.AUTO_LINK, XREFeatureSettings.ON)
	features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ON_NODE)
	var cube: Node3D
	for found: Node in _document.get_scene_root().find_children("*", "CSGShape3D", true, false):
		if (found as CSGShape3D).is_root_shape() and found != _host:
			cube = found as Node3D
			break
	_check(cube != null, "a cube of the scene to target")
	if cube != null:
		var cube_path := str(_service.blueprint.get_host().get_path_to(cube))
		var existing := graph.nodes.filter(func(block: Dictionary) -> bool: return (block["params"] as Dictionary).get("target") == cube_path).size()
		var cube_at := canvas.to_local(cube.global_position)
		var expected: Array[bool] = []
		var targeted: Array[bool] = []
		for index: int in 4:
			var near := index == 3
			var spot := cube_at + (Vector3(0.2, 0.0, 0.0) if near else Vector3(1.0, -0.25 * index, 0.0))
			var block := XREBlueprintGraph.make_node(0, "set_property", Vector2.ZERO)
			block["vr_depth"] = spot.z
			var id: int = _service.blueprint.perform(_service.blueprint.insert_block.bind(block, canvas.block_position(spot), {}, cube), &"vr_panel")
			await _frames(2)
			expected.append(not near and existing + index > XREBlueprints.AUTO_LINK_REFERENCES)
			targeted.append(id >= 0 and XREBlueprintLinks.is_link(graph.find_node(id), XREBlueprintLinks.TARGET))
		_check(targeted == expected, "with Auto link a far block added for an object with more than one wire to it already is a link: %s, expected %s" % [targeted, expected])
	features.set_value(XREFeatureSettings.AUTO_LINK, XREFeatureSettings.OFF)
	features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.WINDOW)
	_service.close_parameters()
	_service.close_block_palette()
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.WINDOW)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames(3)


## Clicks the right trigger at [param point], from [param front].
func _click_from(point: Vector3, front: Vector3) -> void:
	_aim_from(point, front)
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()


## D-064: the number line of a non-negative number from its least value, the
## Vector window near the head, the menu's sections as dimmer buttons, and the
## Color window: the globe of colors in 3D, R, G, B and hex typed, the
## pipette, and the 2D picker's hex code typed on the keyboard.
func _test_d064() -> void:
	var features := _document.features
	var saved_values := features.get_value(XREFeatureSettings.VALUE_INPUT)
	features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PUCKS)
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph
	var editor := _service.get("_token_editor") as XREBlueprintTokenEditor
	var keypad := _service.get("_keyboard") as XREVirtualKeyboard

	# A line that may not go below zero begins there, as long as ever.
	editor.open_dial(Transform3D.IDENTITY, 0.0, 0.0)
	_check(is_zero_approx(float(editor.get("_line_left"))), "a Delay of 0 s: its number line begins at the token")
	var below := false
	for tick: MeshInstance3D in editor.get("_ticks") as Array: below = below or (tick.visible and tick.position.x < -0.0001)
	_check(not below, "no tick below zero")
	_check(is_zero_approx(float(editor.line_to(-0.05, 0.016))), "the ray left of it stays at 0")
	_check(is_equal_approx(float(editor.line_to(0.2, 0.016)), 1.7), "20 cm right is 1.7 s, still on the line: %s" % editor.get_line_value())
	editor.open_dial(Transform3D.IDENTITY, 0.5, 0.0)
	_check(is_equal_approx(float(editor.get("_line_left")), -0.06), "at 0.5 s it begins 6 cm left, at 0")
	editor.open_dial(Transform3D.IDENTITY, 0.0)
	_check(is_equal_approx(float(editor.get("_line_left")), -XREBlueprintTokenEditor.LINE_HALF), "a number with no bound is centred on its token as before")
	editor.close()

	# The menu's sections: buttons, a dimmer gray than the chips.
	_service.open_block_menu()
	await _frames(3)
	var menu := _service.block_menu
	var subs := menu.get_node("Sections").get_children()
	var chip := menu.get_node("Chips").get_child(0) as Button
	var section: Button = null
	if subs.size() > 1: section = subs[subs.size() - 1] as Button
	var chip_style := chip.get_theme_stylebox(&"normal") as StyleBoxFlat
	var section_style: StyleBoxFlat = null
	if section != null: section_style = section.get_theme_stylebox(&"normal") as StyleBoxFlat
	_check(section != null and not section.flat and section_style != null and chip_style != null and section_style.bg_color.get_luminance() < chip_style.bg_color.get_luminance(), "the menu's sections are buttons, a dimmer gray than the chips")
	_service.close_block_palette()
	await _frames()

	# In 3D a color opens the globe in front of the Color window, near the head.
	features.set_value(XREFeatureSettings.COLOR_INPUT, XREFeatureSettings.GLOBE)
	_service.add_block("equals")
	await _frames()
	var equal: int = graph.nodes.back()["id"]
	_service.call("_set_token", equal, "a", Color.BLUE, "Set Token")
	await _frames(4)
	var token := _service.canvas.token_transform(equal, "a").origin
	var front := _card(equal).node.global_basis.z.normalized()
	await _click_from(token, front)
	await _frames(3)
	var window := _panels.find_window(XREBlueprintColorTab)
	_check(window != null and editor.mode == XREBlueprintTokenEditor.GLOBE and not _service.color_panel.get_picker().is_visible_in_tree(), "in 3D a color token opens the Color window with the globe of colors")
	if window == null or editor.mode != XREBlueprintTokenEditor.GLOBE:
		_service.call("_close_inputs")
		features.set_value(XREFeatureSettings.VALUE_INPUT, saved_values)
		while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
		return
	var head := _rig.camera.global_position
	_check(window.global_position.distance_to(head) <= XREBlueprints.NEAR_DISTANCE + 0.01 and window.global_position.y < head.y - 0.05, "near the head, below the eyes: %.2f m" % window.global_position.distance_to(head))
	var face := window.global_basis.z.normalized()
	_check((editor.global_position - window.global_position).dot(face) > 0.0 and (editor.global_position - window.global_position).length() < 0.25, "the globe hangs in front of the window")
	_check(_service.is_focused() and window.is_on_top() and (_service.get("_focus_dimmer") as Node3D).visible, "all else is dimmed, the window drawn over it")

	var opened := editor.get_globe_turn()
	_check(absf(wrapf(opened.x + TAU * 2.0 / 3.0, -PI, PI)) < 0.01 and absf(opened.y) < 0.01, "it opens turned so that blue faces the user: %s" % opened)
	var toward := (head - editor.global_position).normalized()
	_check(editor.global_basis.z.normalized().dot(toward) > 0.999, "the globe faces the head, the window below the eyes upright")
	# A drag across the globe turns it; the color stays.
	var center := editor.global_position
	var globe_front := editor.global_basis.z.normalized()
	_aim_from(center, globe_front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_aim_from(center + editor.global_basis.x.normalized() * 0.03, globe_front)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames(3)
	var turn := editor.get_globe_turn()
	_check(absf(wrapf(turn.x - opened.x, -PI, PI) - 0.03 / editor.globe_radius()) < 0.05 and absf(turn.y - opened.y) < 0.05 and (_edited() as Color).is_equal_approx(Color.BLUE), "a drag across the globe turns it, the color kept: %s" % turn)

	# A click on it picks the color there: in its middle, unturned, red at half lightness.
	editor.turn_globe(0.0, 0.0)
	await _click_from(editor.global_position, globe_front)
	await _frames()
	var picked := _edited() as Color
	_check(_near(picked, Color.RED), "a click on the globe's middle picks red: %s" % picked)
	_check((editor.get("_mark") as Node3D).visible and graph.find_node(equal)["params"]["a"] == Color.BLUE, "its mark shows it; the graph keeps the color until Done")
	_service.color_panel.get_saturation_slider().value = 0.5
	await _frames()
	picked = _edited() as Color
	_check(_near(picked, Color(0.75, 0.25, 0.25)) and editor.globe_radius() < XREBlueprintTokenEditor.GLOBE_RADIUS, "the saturation slider grays it and shrinks the globe: %s" % picked)

	# R, G, B and the hex code typed.
	_service.color_panel.get_channel_button(1).pressed.emit()
	await _frames()
	_check(keypad.is_shown(), "G opens the keypad")
	_service.call("_token_text_submitted", "128")
	await _frames()
	picked = _edited() as Color
	_check(picked.g8 == 128 and absi(picked.r8 - 191) <= 1 and absi(picked.b8 - 64) <= 1, "typed, G is 128, R and B kept: %s" % picked)
	_check(_service.color_panel.get_channel_button(1).text == "G 128", "and its button says it")
	_service.color_panel.get_hex_button().pressed.emit()
	await _frames()
	_service.call("_token_text_submitted", "#00ff00")
	await _frames()
	_check((_edited() as Color).is_equal_approx(Color.GREEN) and _service.color_panel.get_hex_button().text == "#00ff00", "the hex code typed is the color")
	keypad.close()

	# The pipette takes an object's own color, as dimmed as the scene may look.
	var swatch := MeshInstance3D.new()
	swatch.name = "PipetteFixture"
	var box := BoxMesh.new()
	box.size = Vector3(0.4, 0.4, 0.4)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.6, 0.9)
	box.material = material
	swatch.mesh = box
	_document.add_node(swatch, _document.get_scene_root(), XREDocument.Source.PANEL)
	swatch.global_position = Vector3(2.5, 1.0, -2.5)
	await _frames(3)
	var selection := _document.get_selection()
	var pipette := _service.get("_pipette") as XREBlueprintPipette
	var pipette_button := _service.color_panel.get_pipette_button()
	_check(pipette_button.text == "Pipette" and not pipette.visible, "the pipette waits on its button (D-065)")
	pipette_button.toggled.emit(true)
	await _frames()
	_check(_service.get("_pipette_hand") == _rig.right_hand and pipette.visible and pipette.get_parent() == _rig.right_hand and not _rig.right_controller.is_model_shown(), "taken, the pipette is in the hand instead of its controller")
	_check(pipette_button.button_pressed and pipette_button.text == "Put back" and pipette.get_color().is_equal_approx(Color.GREEN), "its button says Put back; the color is in its tube")
	var surface := swatch.global_position + Vector3(0.0, 0.0, 0.2)
	_check(XREBlueprintColorSampler.color_at(swatch, surface) == Color(0.2, 0.6, 0.9), "the pipette reads the material color of the object where the ray meets it")
	await _click(surface)
	await _frames(3)
	# The dummy headless renderer has no BVH candidates: the ray meets nothing there.
	if DisplayServer.get_name() != "headless":
		picked = _edited() as Color
		_check(picked.is_equal_approx(Color(0.2, 0.6, 0.9)), "the pipette takes the object's material color: %s" % picked)
	else:
		_service.call("_preview_color", Color(0.2, 0.6, 0.9))
	_check(_service.get("_pipette_hand") == _rig.right_hand and _panels.find_window(XREBlueprintColorTab) != null and _document.get_selection() == selection, "the pipette stays in the hand after a click; the window stays and nothing is selected")
	_check(pipette.get_color().is_equal_approx(Color(0.2, 0.6, 0.9)), "the tube shows the color taken")

	# The graph's colors: a card's face, a color token's color.
	var card := _card(equal)
	await _click_from(card.node.global_position, card.node.global_basis.z.normalized())
	_check((_edited() as Color).is_equal_approx(XREBlueprintCanvas.CARD_PALETTE[3]), "a click on a card takes its face's color: %s" % _edited())
	await _click_from(_service.canvas.token_transform(equal, "a").origin, card.node.global_basis.z.normalized())
	_check((_edited() as Color).is_equal_approx(Color.BLUE), "a click on a color token takes its color: %s" % _edited())
	# Windows: any but the Color window. Their pixels are read only with a GPU.
	var other := _panels.open_window(XRESettingsTab)
	other.global_transform = Transform3D(Basis.IDENTITY, _rig.camera.global_position + Vector3(0.6, 0, -1.2))
	var color_window := _panels.find_window(XREBlueprintColorTab)
	var aim := _rig.camera.global_position
	_service.call("_pipette_hit", aim, (other.global_position - aim).normalized())
	_check(int(_service.get("_pipette_on")) == XREBlueprints.PIPETTE_WINDOW and _service.get("_pipette_window") == other, "the pipette's ray takes a window")
	_service.call("_pipette_hit", aim, (color_window.global_position - aim).normalized())
	_check(int(_service.get("_pipette_on")) != XREBlueprints.PIPETTE_WINDOW, "but not the Color window")
	var pixel: Variant = other.color_at_pixel(other.size_px * 0.5)
	_check(pixel is Color if DisplayServer.get_name() != "headless" else pixel == null, "a window's pixel is read back from its viewport: %s" % [pixel])
	_panels.call("_close_window", other)
	_service.call("_preview_color", Color(0.2, 0.6, 0.9))
	# Off the token: under the ray it would show its hint.
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)

	# Put back: the controller comes back.
	pipette_button.toggled.emit(false)
	await _frames()
	_check(_service.get("_pipette_hand") == null and not pipette.visible and _rig.right_controller.is_model_shown() and pipette_button.text == "Pipette", "put back, the controller is in the hand again")
	pipette_button.toggled.emit(true)
	await _frames()
	_check(XREBlueprintColorSampler.material_color(null) == null, "no material, no color")
	_service.color_panel.get_done_button().pressed.emit()
	await _frames(3)
	_check((graph.find_node(equal)["params"]["a"] as Color).is_equal_approx(Color(0.2, 0.6, 0.9)) and not editor.is_open() and _panels.find_window(XREBlueprintColorTab) == null, "Done keeps it; the globe and the window close")
	_check(_service.get("_pipette_hand") == null and _rig.right_controller.is_model_shown(), "and the pipette is put back")

	# The × puts it back.
	await _click_from(token, front)
	await _frames(3)
	_service.call("_preview_color", Color.YELLOW)
	_service.color_panel.close_pressed.emit()
	await _frames(3)
	_check((graph.find_node(equal)["params"]["a"] as Color).is_equal_approx(Color(0.2, 0.6, 0.9)) and _panels.find_window(XREBlueprintColorTab) == null and not _service.is_focused(), "the × puts the color back and closes the window")

	# In 2D a click on the picker's hex code types it on the keyboard.
	features.set_value(XREFeatureSettings.COLOR_INPUT, XREFeatureSettings.PICKER)
	await _click_from(token, front)
	await _frames(3)
	_check(_panels.find_window(XREBlueprintColorTab) != null and _service.color_panel.get_picker().is_visible_in_tree() and editor.mode != XREBlueprintTokenEditor.GLOBE, "in 2D the window shows the picker")
	var hex: LineEdit = null
	for field: LineEdit in _line_edits(_service.color_panel.get_picker(), []):
		if not field.get_parent() is SpinBox and Color.html_is_valid(field.text.strip_edges().trim_prefix("#")): hex = field
	_check(hex != null, "the picker has its hex code")
	if hex != null:
		var press := InputEventMouseButton.new()
		press.button_index = MOUSE_BUTTON_LEFT
		press.pressed = true
		hex.gui_input.emit(press)
		await _frames(2)
		_check(keypad.is_shown(), "a click on it opens the keyboard")
		_service.call("_apply_keyboard", "ff0000")
		await _frames()
		_check(_edited() is Color and (_edited() as Color).is_equal_approx(Color.RED), "typed there, it is the color: %s" % [_edited()])
	_service.call("_close_inputs")
	await _frames()
	_check(not keypad.is_shown() and (graph.find_node(equal)["params"]["a"] as Color).is_equal_approx(Color(0.2, 0.6, 0.9)), "closed, the keyboard goes and the color is as it was")

	_document.remove_nodes([swatch], XREDocument.Source.PANEL)
	features.set_value(XREFeatureSettings.VALUE_INPUT, saved_values)
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-065: operators drawn as in Unreal, a variable's start value a puck that
## takes the trigger all over, the 3D Color window see-through. The pipette in
## the hand is checked in [method _test_d064].
func _test_d065() -> void:
	var features := _document.features
	var saved_values := features.get_value(XREFeatureSettings.VALUE_INPUT)
	var saved_variables := features.get_value(XREFeatureSettings.VARIABLE_INPUT)
	var saved_colors := features.get_value(XREFeatureSettings.COLOR_INPUT)
	features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PUCKS)
	await _frames()
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph

	# An operator: a small card, no title, its symbol between its inputs and its result.
	_service.add_block("operator")
	await _frames(3)
	var add: int = graph.nodes.back()["id"]
	var card := _card(add)
	var symbol := card.node.get_node_or_null("Symbol") as Label3D if card != null else null
	_check(card != null and card.compact and card.width < XREBlueprintCanvas.CARD_WIDTH and card.height < 0.13 and symbol != null and symbol.text == "+", "Add is a small card with + on it")
	if card == null or symbol == null:
		while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
		return
	var titled := false
	for child: Node in card.node.get_children():
		if child is Label3D and (child as Label3D).text.begins_with("Add"): titled = true
	_check(not titled, "with no title")
	_check(card.inputs[0].x < symbol.position.x and symbol.position.x < card.outputs[0].x and is_zero_approx(card.outputs[0].y) and card.inputs[0].y > 0.0 and card.inputs[1].y < 0.0, "A above B on the left, the symbol between, the result in the middle on the right")
	var token := card.node.to_local(_service.canvas.token_transform(add, "a").origin)
	_check(token.x > card.inputs[0].x and token.x < symbol.position.x and absf(token.y - card.inputs[0].y) < 0.001, "A's token right by its port, before the symbol")
	_check(card.trash_point.y > card.height * 0.5, "its trash stands above it")
	# A wire's type: B's literal takes it, and so does the result.
	_service.add_block("value")
	await _frames(3)
	var count: int = graph.nodes.back()["id"]
	_service.blueprint.set_parameter(count, "value", 4)
	_service.blueprint.connect_blocks(count, 0, add, 0)
	await _frames(3)
	_check(graph.find_node(add)["params"]["b"] is int and _service.canvas.port_type(add, 0, false) == XREBlueprintGraph.INTEGER, "an integer wired into A: B and the result are integers")
	var negation := _service.blueprint.insert_block(XREBlueprintGraph.make_operator(0, "not", Vector2.ZERO), graph.find_node(add)["position"] + Vector2(0, 260))
	await _frames(3)
	var unary := _card(negation)
	var word := unary.node.get_node_or_null("Symbol") as Label3D if unary != null else null
	_check(unary != null and unary.inputs.size() == 1 and is_zero_approx(unary.inputs[0].y) and word != null and word.text == "NOT" and unary.height < card.height, "NOT: one input level with its result, a shorter card")
	_service.add_block("equals")
	await _frames(3)
	var equal := _card(graph.nodes.back()["id"])
	_check(equal != null and equal.compact and (equal.node.get_node("Symbol") as Label3D).text == "=", "Equal is an operator too: =")

	# A variable's start value is a puck even with plugs, and takes the trigger all over.
	features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PLUGS)
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.BOXES)
	_service.blueprint.set_variable("speed", 2.0)
	await _frames(3)
	var shelf := _service.canvas.get_boxes()
	var start: XREBlueprintBoxes.Box = null
	for box: XREBlueprintBoxes.Box in shelf.get("_boxes") as Array:
		if box.name == "speed": start = box
	_check(start != null and start.token != null, "the box of speed has its start value")
	if start != null and start.token != null:
		var body := start.token.get_child(0) as MeshInstance3D
		var bounds := body.get_aabb()
		_check(absf(bounds.position.x + bounds.end.x) < 0.002, "a puck, not a plug: nothing sticks out to its left")
		var front := _service.canvas.global_basis.z.normalized()
		var center := shelf.token_transform("speed").origin
		var across := _service.canvas.global_basis.x.normalized() * start.token_size.x * 0.4
		for point: Vector3 in [center, center - across, center + across]:
			_service.canvas.intersect_ray(point + front * 0.4, -front, 5.0)
			_check(_service.canvas.get_hit_box() and shelf.get_hit_part() == XREBlueprintBoxes.TOKEN, "the ray takes it at %s" % (point - center))
	# A float's box wired into Add's B: the wire and B in a float's color, A in an integer's, as what comes in.
	_service.call("_wire_box_to_port", "speed", add, 1)
	await _frames(3)
	var numbers := XREBlueprintCanvas.COLORS[XREBlueprintGraph.NUMBER]
	var wires := (_service.canvas.get("_wires") as Array).filter(func(wire: XREBlueprintCanvas.Wire) -> bool: return wire.variable == "speed" and wire.to.id == add)
	_check(wires.size() == 1 and _tint((wires[0] as XREBlueprintCanvas.Wire).normal) == numbers, "the wire from a float's box is a float's color, not any value's: %s" % [_tint((wires[0] as XREBlueprintCanvas.Wire).normal) if wires.size() == 1 else null])
	card = _card(add)
	_check(_tint(card.ports[1].material_override) == numbers and _tint(card.ports[0].material_override) == XREBlueprintCanvas.COLORS[XREBlueprintGraph.INTEGER], "wired, B is a float's color and A an integer's")
	_check(card.input_types[1] == XREBlueprintGraph.VALUE, "but B still takes any wire")

	# In 3D the Color window is see-through, as the Vector window; in 2D it is not.
	for mode: StringName in [XREFeatureSettings.GLOBE, XREFeatureSettings.PICKER]:
		features.set_value(XREFeatureSettings.COLOR_INPUT, mode)
		await _frames()
		_service.call("_open_color", equal.id, "a", "", Color.BLUE)
		await _frames(3)
		var window := _panels.find_window(XREBlueprintColorTab)
		var alpha := window.tab.get_frame_color().a if window != null else -1.0
		_check(alpha < 1.0 and alpha > 0.0 if mode == XREFeatureSettings.GLOBE else is_equal_approx(alpha, 1.0), "%s: the frame's alpha is %.2f" % [mode, alpha])
		_service.call("_close_inputs")
		await _frames(3)

	features.set_value(XREFeatureSettings.VALUE_INPUT, saved_values)
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, saved_variables)
	features.set_value(XREFeatureSettings.COLOR_INPUT, saved_colors)
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-066: the graph's windows stay in the world; what covers an input is
## see-through, and the petals take the ray over it; a token takes a wire's
## place; the keypad small, beside its window, facing the hand; arrows taken
## by their ends, the ray ending there, fine values under 1, the vector over its arrow.
func _test_d066() -> void:
	var features := _document.features
	var saved := {}
	for key: StringName in [XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.AXIS_SCALE]: saved[key] = features.get_value(key)
	features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PUCKS)
	# The arrows speed on and go toward zero by themselves (D-069: Auto), whatever the user chose.
	features.set_value(XREFeatureSettings.AXIS_SCALE, XREFeatureSettings.AUTO)
	await _frames()
	var history := _service.blueprint.history.get_version()
	var graph := _service.blueprint.graph
	var editor := _service.get("_token_editor") as XREBlueprintTokenEditor
	var keypad := _service.get("_keyboard") as XREVirtualKeyboard

	# The block menu stays where it opened when the sticks fly or turn the user.
	_service.open_block_menu()
	await _frames(3)
	var menu := _panels.find_window(XREBlueprintPaletteTab)
	var rig_before := _rig.global_transform
	var menu_before := menu.global_position if menu != null else Vector3.ZERO
	_rig.global_position += Vector3(0.6, 0.0, -0.4)
	_rig.global_transform = XRELocomotion.turned(_rig.global_transform, _rig.camera.global_position, 0.5)
	await _frames()
	_check(menu != null and menu.top_level and menu.global_position.distance_to(menu_before) < 0.001, "the block menu stays in the world as the rig moves")
	_rig.global_transform = rig_before
	_service.close_block_palette()
	await _frames(3)

	# A token dropped on a port a wire comes into takes the wire's place.
	_service.add_block("delay")
	await _frames()
	var delay: int = graph.nodes.back()["id"]
	_service.add_block("value")
	await _frames()
	var source: int = graph.nodes.back()["id"]
	_service.blueprint.set_parameter(source, "value", 5.0)
	var port := graph.input_port(graph.find_node(delay), "seconds")
	_service.blueprint.connect_blocks(source, 0, delay, port)
	await _frames(3)
	var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
	pointer.carried = Node3D.new()
	pointer.carried_value = 2.0
	pointer.carried_key = "seconds"
	pointer.carried_block = -1
	pointer.carried_copy = true
	_service.call("_drop_carried", pointer, {"block": delay, "key": "seconds"})
	await _frames(3)
	var into := graph.edges.filter(func(edge: Dictionary) -> bool: return edge["to"] == delay and edge["to_port"] == port)
	_check(into.is_empty() and is_equal_approx(float(graph.find_node(delay)["params"]["seconds"]), 2.0) and not graph.find_node(source).is_empty(), "a token on a wired port takes the wire's place; the wire goes, its block stays")
	_service.blueprint.undo()
	await _frames(3)
	_check(graph.edges.any(func(edge: Dictionary) -> bool: return edge["to"] == delay and edge["to_port"] == port), "one undo brings the wire back")

	# A wire let go in empty space opens the block menu; ended on a port instead, it closes it (D-067).
	_service.add_block("value")
	await _frames()
	var feeder: int = graph.nodes.back()["id"]
	_service.add_block("delay")
	await _frames()
	var waiter: int = graph.nodes.back()["id"]
	_service.click_port(feeder, 0, false, _rig.right_hand)
	_service.call("_open_menu_for_wire", Vector3(0.0, 0.0, 0.1))
	await _frames(3)
	_check(_service.is_block_palette_shown(), "the wire's block menu is open")
	_check(_service.click_port(waiter, graph.input_port(graph.find_node(waiter), "seconds"), true, _rig.right_hand), "the wire ends on a port")
	await _frames(3)
	_check(not _service.is_block_palette_shown() and _panels.find_window(XREBlueprintPaletteTab) == null, "and its menu closes")

	# The Vector window of (1, 2, 3); a card and a scene object between it and the head.
	_service.add_block("set_property")
	await _frames()
	var setter: int = graph.nodes.back()["id"]
	_service.blueprint.choose_target(setter, _host)
	_service.call("_set_token", setter, "property", "position", "Set Token")
	_service.call("_set_token", setter, "value", Vector3(1.0, 2.0, 3.0), "Set Token")
	await _frames(3)
	var head := _rig.camera.global_position
	var near_pose := _service.call("_near_pose", _service.canvas.token_transform(setter, "value").origin) as Transform3D
	var between := head.lerp(near_pose.origin, 0.6)
	var blocker := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = Vector3.ONE * 0.05
	blocker.mesh = cube
	_host.add_child(blocker)
	blocker.global_position = between
	_service.canvas.preview_move(delay, _service.canvas.to_local(between))
	_service.canvas.commit_move(_service.blueprint, delay)
	await _frames(3)
	_service.call("_open_vector", setter, "value", "", Vector3(1.0, 2.0, 3.0))
	await _frames(4)
	var window := _panels.find_window(XREBlueprintVectorTab)
	_check(window != null and window.top_level, "the Vector window stands in the world too")
	_check(_service.canvas.is_faded(delay) and not _service.canvas.is_faded(setter), "the card between the head and the arrows is see-through; the token's own, behind, is not")
	_check(_service.get_fade().is_faded(blocker) and is_zero_approx(blocker.transparency), "so is the scene object there, its node untouched")
	var faded_part := false
	for child: Node in _card(delay).node.find_children("*", "GeometryInstance3D", true, false): faded_part = faded_part or (child as GeometryInstance3D).transparency > 0.5
	_check(faded_part, "its parts are drawn faint")
	_service.canvas.intersect_ray(head, (between - head).normalized(), 5.0)
	_check(_service.canvas.get_hit_id() != delay, "and the ray passes it, on to the input (D-067)")

	# The vector is written over the white arrow; the arrows are taken by their ends only.
	var numbers := editor.get("_numbers") as Array
	_check((numbers[XREBlueprintTokenEditor.VECTOR_AXIS] as Label3D).text == "(1, 2, 3)", "the white arrow has the vector over it: %s" % (numbers[XREBlueprintTokenEditor.VECTOR_AXIS] as Label3D).text)
	var white := (editor.get("_shafts") as Array)[XREBlueprintTokenEditor.VECTOR_AXIS] as MeshInstance3D
	_check(_tint(white.material_override).a < 0.9 and (numbers[XREBlueprintTokenEditor.VECTOR_AXIS] as Label3D).modulate.a < 0.9 and _tint(((editor.get("_shafts") as Array)[0] as MeshInstance3D).material_override).a > 0.99, "the white arrow and its vector are a little see-through, the axis arrows not (D-067)")
	var face := window.global_basis.z.normalized() if window != null else Vector3.BACK
	_service.call("_preview_value_edit", Vector3(0.0, 3.0, 0.0), "")
	await _frames()
	var lengths := editor.get("_lengths") as Array
	var middle := editor.global_position + editor.axis_direction(1) * float(lengths[1]) * 0.3
	var tip := editor.tip_position(1)
	_check(editor.pick(middle + face * 0.4, -face).is_empty(), "the middle of an arrow doesn't take it")
	_check(int(editor.pick(tip + face * 0.4, -face).get("axis", -1)) == 1, "its end does")
	# Pulled, the ray ends on the arrow's end.
	var y_tip := editor.tip_position(1)
	_aim_from(y_tip, face)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_aim_from(y_tip - editor.axis_direction(1) * 0.02, face)
	await _frames()
	var hand_end := _rig.right_hand.get_ray_end()
	var pulled_tip := editor.tip_position(1)
	_check(hand_end.distance_to(pulled_tip) < 0.015, "the ray ends on the pulled arrow's end: %.3f m off" % hand_end.distance_to(pulled_tip))
	_right.set_input(&"trigger", 0.0)
	await _frames(3)

	# Under 1, finer: 0.1 is reached by a pull from 1, then 0.01.
	# Ten long, then one: the arrows are drawn anew by units.
	_service.call("_preview_value_edit", Vector3(10.0, 0.0, 0.0), "")
	_service.call("_preview_value_edit", Vector3(1.0, 0.0, 0.0), "")
	await _frames()
	_check(is_equal_approx(editor.get_arrow_scale(), XREBlueprintTokenEditor.ARROW_LENGTH) and is_equal_approx(editor.get_step(), 0.1), "by units a step is 0.1")
	# Held near its foot X goes toward zero (D-067), smaller the longer it is held, the scale growing.
	editor.begin_pull(0)
	var near := -XREBlueprintTokenEditor.ARROW_LENGTH + (XREBlueprintTokenEditor.ZERO_ZONE + XREBlueprintTokenEditor.NEAR_ZONE) * 0.5
	var value: Variant = editor.pull_to(0, near, 0.0)
	var entered := float(value[0])
	_check(entered > 0.1 and entered < 0.3, "pulled near its foot, X is still the value there: %s" % value)
	var seen: Array[float] = []
	for step: int in 30:
		value = editor.pull_to(0, near, 0.1)
		seen.append(float(value[0]))
	_check(seen[5] < entered and seen.min() >= XREBlueprintTokenEditor.SMALLEST - 0.0001 and seen.any(func(shown: float) -> bool: return shown <= 0.1001 and shown > 0.0101) and seen.back() > 0.0 and seen.back() < 0.001, "held there it goes 0.1, 0.01 and on, finer than 0.01 (D-071), not to 0: %s" % [seen])
	var arrow := float((editor.get("_lengths") as Array)[0])
	_check(editor.get_arrow_scale() > XREBlueprintTokenEditor.ARROW_LENGTH * 5.0 and absf(arrow - XREBlueprintTokenEditor.NEAR_ZONE) < 0.003, "the scale grew, the arrow stays at the zone's edge: %.3f m" % arrow)
	value = editor.pull_to(0, -XREBlueprintTokenEditor.ARROW_LENGTH + XREBlueprintTokenEditor.ZERO_ZONE * 0.5, 0.1)
	_check(float(value[0]) == 0.0, "at the foot it is 0")
	value = editor.pull_to(0, -XREBlueprintTokenEditor.ARROW_LENGTH + 0.03, 0.1)
	_check(float(value[0]) > 0.0 and float(value[0]) < 0.1, "out of the zone again, by the finer scale: %s" % value)
	editor.end_pull()
	_check(editor.get_step() <= 0.0101, "let go, the arrows stay as fine, a step of 0.01: %.3f" % editor.get_step())

	# The keypad of a component: small, beside the window on the hand's side, facing the hand.
	_service.vector_panel.get_component_button(0).pressed.emit()
	await _frames()
	_check(keypad.is_shown() and keypad.is_keypad() and keypad.size_m.x < 0.4 and keypad.size_m.y < 0.3, "the keypad is small: %s" % keypad.size_m)
	if window != null:
		var eye := _rig.camera.global_position
		var top := keypad.global_transform * Vector3(0.0, keypad.size_m.y * 0.5, 0.0)
		var window_top := window.pixel_to_global(Vector2(window.size_px.x * 0.5, 0.0))
		_check(keypad.global_position.y < window.global_position.y and top.y < window_top.y and top.y > keypad.global_position.y, "it stands low on the window, its top within it (D-067)")
		_check(keypad.global_basis.z.normalized().dot((eye - keypad.global_position).normalized()) > 0.999, "square to the line of sight from the eyes")
		var down := rad_to_deg(asin(clampf((eye - keypad.global_position).normalized().y, -1.0, 1.0)))
		_check(down < 50.0, "and not far below them: %.0f°" % down)
	var key: Button = null
	for button: Button in keypad.get("_keys") as Array:
		if button.text == "7" and button.is_visible_in_tree(): key = button
	_check(key != null and key.size.x < 80 and key.size.y < 70, "its keys about as big as the letters': %s" % (key.size if key != null else Vector2.ZERO))
	keypad.close()
	keypad.open_text("")
	_check(is_equal_approx(keypad.size_m.x, XREVirtualKeyboard.LETTERS_SIZE.x * XREVirtualKeyboard.PIXEL_SIZE), "the letters have their own size back")
	keypad.close()
	_service.set("_token_edit", {})
	_service.call("_end_vector", false)
	await _frames(3)
	_check(not _service.canvas.is_faded(delay) and not _service.get_fade().is_faded(blocker), "closed, nothing is see-through")
	var still_faded := false
	for child: Node in _card(delay).node.find_children("*", "GeometryInstance3D", true, false): still_faded = still_faded or (child as GeometryInstance3D).transparency > 0.5
	_check(not still_faded, "and the card's parts have their look back")

	# Petals picked in focus take the ray over a card in front of them.
	features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ADAPTER)
	await _frames(3)
	_service.call("_open_member_petals", setter, _rig.right_hand)
	await _frames(3)
	var petals := _service.get("_petals") as XREBlueprintPetals
	var shown := petals.get("_petals") as Array
	_check(petals.is_open() and _service.is_focused() and not shown.is_empty(), "the member's petals open in focus")
	if petals.is_open() and not shown.is_empty():
		var petal := petals.to_global((shown[0] as XREBlueprintPetals.Petal).center)
		var toward := (_rig.camera.global_position - petal).normalized()
		_service.canvas.preview_move(delay, _service.canvas.to_local(petal + toward * 0.2))
		_service.canvas.commit_move(_service.blueprint, delay)
		await _frames(3)
		_aim_from(petal, toward)
		await _frames(3)
		_check(petals.get("_hovered") == 0, "the ray lights the petal through the card before it")
		_check(_service.canvas.is_faded(delay), "and the card is see-through")
		# The list scrolls smoothly (D-067): by half a row the first row is half seen, and so is the next one under the page.
		if petals.get_item_count() > XREBlueprintPetals.PAGE + 1:
			var before := (shown[0] as XREBlueprintPetals.Petal).center.y
			_check(petals.scroll_by(0.5) and is_equal_approx(petals.get_scroll(), 0.5), "the fan scrolls by half a row")
			shown = petals.get("_petals") as Array
			var rows := shown.filter(func(item: XREBlueprintPetals.Petal) -> bool: return item.row >= 0)
			var first := rows[0] as XREBlueprintPetals.Petal
			var under := rows.back() as XREBlueprintPetals.Petal
			_check(is_equal_approx(first.seen, 0.5) and is_equal_approx(under.seen, 0.5) and first.center.y > before - XREBlueprintPetals.STEP * 1.0, "the first row half gone, the one under the page half come: %.2f, %.2f" % [first.seen, under.seen])
			petals.scroll_by(0.7)
			_check(petals.get("_first") == 1 and is_equal_approx(petals.get_scroll(), 1.2), "past a row, the next is first")
	_service.call("_close_inputs")
	await _frames(3)
	blocker.queue_free()
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	for item: StringName in saved: features.set_value(item, saved[item])
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames()


## D-068: a number's line held near its 0 tick goes toward zero, as an arrow near its foot.
func _test_d068() -> void:
	var editor := _service.get("_token_editor") as XREBlueprintTokenEditor
	editor.scale_mode = XREFeatureSettings.AUTO
	var unit := XREBlueprintTokenEditor.LINE_STEP_GAP / 0.1
	editor.open_dial(Transform3D.IDENTITY, 0.5)
	var zero := -0.5 * unit
	var held := zero + (XREBlueprintTokenEditor.ZERO_ZONE + XREBlueprintTokenEditor.NEAR_ZONE) * 0.5
	var first := float(editor.line_to(held, 0.0))
	_check(first > 0.05 and first < 0.2, "near the 0 tick, the value is the line's there: %s" % first)
	var seen: Array[float] = []
	for step: int in 30: seen.append(float(editor.line_to(held, 0.1)))
	_check(seen[5] < first and seen.min() >= XREBlueprintTokenEditor.SMALLEST - 0.0001 and seen.any(func(shown: float) -> bool: return shown < 0.0999 and shown > 0.0101) and seen.back() > 0.0 and seen.back() < 0.001, "held there it goes toward zero, finer than 0.01 (D-071), not to 0: %s" % [seen])
	var scale := float(editor.get("_line_scale"))
	_check(absf(-float(editor.get("_line_center")) * scale - zero) < 0.0005 and scale > unit * 5.0, "the ruler grew finer about its 0, which stayed put: %.2f m a unit" % scale)
	var before_nudge := float(editor.get_line_value())
	var nudged := float(editor.nudge(1))
	_check(float(editor.get("_line_step")) <= 0.0201 and nudged > before_nudge and nudged < 0.1, "its step is fine, for the wrist and the stick too: %s → %s" % [before_nudge, nudged])
	# The stick moved the ruler: its 0 tick is where it is now.
	zero = -float(editor.get("_line_center")) * float(editor.get("_line_scale"))
	_check(float(editor.line_to(zero + XREBlueprintTokenEditor.ZERO_ZONE * 0.5, 0.1)) == 0.0, "at the 0 tick it is 0")
	_check(float(editor.line_to(zero + 0.03, 0.1)) > 0.0 and float(editor.get_line_value()) < 0.1, "away from it again, by the finer ruler: %s" % editor.get_line_value())
	# A Delay's line begins at 0: held by its start it goes to zero too.
	editor.open_dial(Transform3D.IDENTITY, 0.5, 0.0)
	for step: int in 30: editor.line_to(float(editor.get("_line_left")) + 0.01, 0.1)
	_check(float(editor.get_line_value()) > 0.0 and float(editor.get_line_value()) < 0.001, "a Delay held by its start goes toward 0 s: %s" % editor.get_line_value())
	# A whole number has no fractions to go to.
	editor.open_dial(Transform3D.IDENTITY, 1)
	var integer_zero := -XREBlueprintTokenEditor.LINE_STEP_GAP
	for step: int in 10: editor.line_to(integer_zero + 0.01, 0.1)
	_check(editor.get_line_value() is int and is_equal_approx(float(editor.get("_line_scale")), XREBlueprintTokenEditor.LINE_STEP_GAP), "a whole number's line stays by units: %s" % editor.get_line_value())
	editor.close()


## D-069: Axis scale — Auto speeds on and goes toward zero; Stick scales by the stick, the value kept, and nothing speeds.
func _test_d069() -> void:
	# D-071: figures as fine as they are, the step written.
	_check(XREBlueprintTokens.text(0.000025, "") == "0.000025" and XREBlueprintTokens.text(1.503, "") == "1.503" and XREBlueprintTokens.text(0.5, "") == "0.5" and XREBlueprintTokens.text(2.0, "") == "2" and XREBlueprintTokens.text(-0.0, "") == "0", "numbers are written as fine as they are: %s, %s" % [XREBlueprintTokens.text(0.000025, ""), XREBlueprintTokens.text(1.503, "")])
	_check(XREFeatureSettings.get_values(XREFeatureSettings.AXIS_SCALE) == [XREFeatureSettings.STICK, XREFeatureSettings.AUTO] and XREFeatureSettings.get_default(XREFeatureSettings.AXIS_SCALE) == XREFeatureSettings.STICK, "Axis scale: Stick, the default (D-076), or Auto")
	var editor := _service.get("_token_editor") as XREBlueprintTokenEditor
	editor.scale_mode = XREFeatureSettings.STICK
	# The number line: past its end it slides on evenly (D-070), the stick scales it about the marker.
	editor.open_dial(Transform3D.IDENTITY, 0.5)
	var slid: Array[float] = []
	for step: int in 11: slid.append(float(editor.line_to(XREBlueprintTokenEditor.LINE_HALF + 0.05, 0.1)))
	_check(slid[10] > slid[0] + 1.0 and absf((slid[10] - slid[5]) - (slid[5] - slid[0])) < 0.25, "on Stick, past its end the line slides on evenly, not faster and faster: %s" % [slid])
	var kept := float(editor.get_line_value())
	var coarse_step := float(editor.get("_line_step"))
	_check(editor.get_shown_step() == "step 0.1", "the line writes its step: %s" % editor.get_shown_step())
	editor.zoom(1.0, 1.0)
	_check(editor.get_shown_step() == "step " + XREBlueprintTokens.plain(float(editor.get("_line_step"))) and editor.get_shown_step() != "step 0.1", "finer, a finer step: %s" % editor.get_shown_step())
	_check(is_equal_approx(float(editor.get_line_value()), kept) and float(editor.get("_line_step")) < coarse_step, "the stick up makes it finer, the value kept: step %s" % editor.get("_line_step"))
	var finer := float(editor.line_to(XREBlueprintTokenEditor.LINE_HALF - 0.05, 0.1))
	_check(finer < kept and finer > kept - 0.2, "5 cm back is now a little less: %s" % finer)
	editor.zoom(-1.0, 3.0)
	_check(float(editor.get("_line_step")) > coarse_step, "down, coarser: step %s" % editor.get("_line_step"))
	editor.zoom(1.0, 10.0)
	_check(float(editor.get("_line_step")) < 0.00001, "up and up, finer than 0.01 (D-071): step %s" % editor.get("_line_step"))
	editor.open_dial(Transform3D.IDENTITY, 0.5)
	editor.zoom(-1.0, 1.0)
	var coarse_slid := 0.0
	for step: int in 11: coarse_slid = float(editor.line_to(XREBlueprintTokenEditor.LINE_HALF + 0.05, 0.1))
	_check(coarse_slid - 0.5 > (slid[10] - slid[0]) * 10.0, "coarser, it slides on faster: %s" % coarse_slid)
	editor.open_dial(Transform3D.IDENTITY, 0.5)
	var zero := -0.5 * XREBlueprintTokenEditor.LINE_STEP_GAP / 0.1
	var scale := float(editor.get("_line_scale"))
	for step: int in 20: editor.line_to(zero + 0.01, 0.1)
	_check(is_equal_approx(float(editor.get("_line_scale")), scale), "held by 0, the line doesn't go toward zero on Stick")
	# The arrows: no speeding past the end nor toward zero; the stick scales them.
	editor.open_arrows(Transform3D.IDENTITY, 3, Vector3(1.0, 0.0, 0.0))
	editor.begin_pull(0)
	var near := -XREBlueprintTokenEditor.ARROW_LENGTH + 0.007
	var values: Array[float] = []
	for step: int in 5: values.append(float(editor.pull_to(0, near, 0.1)[0]))
	_check(values.max() == values.min() and is_equal_approx(values[0], 0.1), "near its foot it stays, 0.1: %s" % [values])
	var scale_before := editor.get_arrow_scale()
	editor.zoom(1.0, 1.0)
	_check(editor.get_arrow_scale() > scale_before * 4.0 and is_equal_approx(float(editor.pull_to(0, near, 0.1)[0]), 0.1), "the stick up makes it finer, the value kept")
	var refined := float(editor.pull_to(0, near - 0.02, 0.1)[0])
	_check(refined > 0.0 and refined < 0.1, "then the ray sets less than 0.1: %s" % refined)
	# Past its longest the axis slides on (D-070): by an even share of the value, not faster and faster.
	values.clear()
	for step: int in 11: values.append(float(editor.pull_to(0, 0.3, 0.1)[0]))
	var lengths := editor.get("_lengths") as Array
	var early := values[5] - values[0]
	var late := values[10] - values[5]
	_check(early > 0.0 and absf(late / early - 1.0) < 0.15 and absf(float(lengths[0]) - XREBlueprintTokenEditor.ARROW_MAX) < 0.003 and editor.get_bases().x > 0.0, "past its longest its axis slides on evenly, the arrow at its longest, beginning further on (D-071): %s" % [values])
	var base_label := (editor.get("_base_labels") as Array)[0] as Label3D
	_check(base_label.visible and base_label.text.begins_with("from "), "its foot says where it begins: %s" % base_label.text)
	# Finer and finer, past where the arrow would fit (D-071): it begins further on instead.
	var held := float(editor.get_vector()[0])
	var fine_before := editor.get_arrow_scale()
	editor.zoom(1.0, 10.0)
	_check(editor.get_arrow_scale() > fine_before * 1000.0 and is_equal_approx(float(editor.get_vector()[0]), held) and float(lengths[0]) <= XREBlueprintTokenEditor.ARROW_MAX + 0.001 and float(lengths[3]) <= XREBlueprintTokenEditor.VECTOR_MAX + 0.001, "the stick goes on making it finer, the value kept, the arrows within their reach: %.1f m a unit" % editor.get_arrow_scale())
	_check(editor.get_step() < 0.00001 and editor.get_shown_step() == "step " + XREBlueprintTokens.plain(editor.get_step()), "to a step finer than 0.01, written under the arrows: %s" % editor.get_shown_step())
	var nudged := float(editor.pull_to(0, 0.3 - 0.01, 0.1)[0])
	_check(nudged < held and nudged > held - 0.001, "and 1 cm of the ray is now a little: %s → %s" % [held, nudged])
	editor.zoom(-1.0, 10.0)
	_check(editor.get_bases().x == 0.0 and not base_label.visible, "coarse again, the arrow begins at 0")
	var left := editor.get_arrow_scale()
	editor.end_pull()
	_check(is_equal_approx(editor.get_arrow_scale(), left), "let go, the scale stays as the stick left it")
	editor.close()
	editor.scale_mode = XREFeatureSettings.AUTO


## D-072: what the ray is on is in focus — a card with its ports, details and
## wires lit, the rest darker or see-through, the far ends of its wires as they
## are; a port under the ray grows over its card's focus; a variable's box the same.
func _test_d072() -> void:
	var features := _document.features
	var graph := _service.blueprint.graph
	var canvas := _service.canvas
	var history := _service.blueprint.history.get_version()
	var saved_variables := features.get_value(XREFeatureSettings.VARIABLE_INPUT)
	_check(XREFeatureSettings.get_values(XREFeatureSettings.FOCUS) == [XREFeatureSettings.FRONT, XREFeatureSettings.OFF, XREFeatureSettings.ON]
			and XREFeatureSettings.get_values(XREFeatureSettings.DEFOCUS) == [XREFeatureSettings.DIM, XREFeatureSettings.OFF, XREFeatureSettings.TRANSPARENT],
			"Focus is Front (D-073), the default (D-076), Off or On; Defocus is Dim, the default, Off or Transparent")

	# Three cards to the right of all the others: a value wired into a delay, and a delay alone below.
	var right := -INF
	for card: XREBlueprintCanvas.Card in canvas.get("_cards") as Array: right = maxf(right, card.node.position.x + card.width * 0.5)
	_service.add_block("value")
	await _frames()
	var feeder: int = graph.nodes.back()["id"]
	_service.add_block("delay")
	await _frames()
	var waiter: int = graph.nodes.back()["id"]
	_service.add_block("delay")
	await _frames()
	var other: int = graph.nodes.back()["id"]
	var places: Dictionary[int, Vector3] = {feeder: Vector3(right + 0.3, 0.0, 0.0), waiter: Vector3(right + 0.7, 0.0, 0.0), other: Vector3(right + 0.7, -0.35, 0.0)}
	for id: int in places:
		canvas.preview_move(id, places[id])
		canvas.commit_move(_service.blueprint, id)
		await _frames()
	var seconds := graph.input_port(graph.find_node(waiter), "seconds")
	_service.blueprint.connect_blocks(feeder, 0, waiter, seconds)
	await _frames(3)
	var wire: XREBlueprintCanvas.Wire
	for item: XREBlueprintCanvas.Wire in canvas.get("_wires") as Array:
		if item.from != null and item.from.id == feeder and item.to.id == waiter: wire = item
	var feeder_out := _card(feeder).ports[_card(feeder).inputs.size()]

	# No card selected: a selected one would keep its look out of focus (D-122).
	_service.select_block(-1)
	# Off: the ray on a card changes nothing.
	_aim_from(canvas.to_global(canvas.get_block_position(waiter) + Vector3(0.0, 0.02, 0.0)), _card(waiter).node.global_basis.z.normalized())
	await _frames()
	_check(canvas.focus_state(waiter) == XREBlueprintFocus.NORMAL and _card(other).mesh.material_override == _card(other).normal, "with both off nothing is in focus")

	# Focus On, Defocus Dim: the card under the ray lit, its wire lit, the rest darker.
	features.set_value(XREFeatureSettings.FOCUS, XREFeatureSettings.ON)
	features.set_value(XREFeatureSettings.DEFOCUS, XREFeatureSettings.DIM)
	await _frames()
	var body := _card(waiter).node.global_position + _card(waiter).node.global_basis.y.normalized() * 0.02
	_aim_from(body, _card(waiter).node.global_basis.z.normalized())
	await _frames()
	_check(canvas.focus_state(waiter) == XREBlueprintFocus.FOCUSED and canvas.focus_state(other) == XREBlueprintFocus.OUT and canvas.focus_state(feeder) == XREBlueprintFocus.OUT, "the card under the ray is in focus, the others out of it")
	var face := _face(_card(waiter).normal)
	_check(_face(_card(waiter).mesh.material_override).r > face.r + 0.05, "the card in focus is lighter")
	_check(_tint(_card(waiter).frame.material_override).is_equal_approx(XREBlueprintFocus.FRAME), "and its frame is the focus's")
	_check(_face(_card(other).mesh.material_override).r < _face(_card(other).normal).r * 0.5, "a card out of focus is darker")
	var dark_label := false
	for child: Node in _card(other).node.get_children():
		if child is Label3D: dark_label = dark_label or (child as Label3D).modulate.r < 0.5
	_check(dark_label, "its text too")
	_check(wire != null and wire.focus == XREBlueprintFocus.FOCUSED and _tint(wire.mesh.material_override).r >= _tint(wire.normal).r and wire.mesh.material_override != wire.normal, "the card's wire is in focus, lit")
	_check(_face(_card(feeder).mesh.material_override).r < _face(_card(feeder).normal).r * 0.5 and not feeder_out.has_meta(&"unpainted"), "the far end of that wire stays as it is on its darker card")

	# A port under the ray grows over its card's focus.
	_aim_from(canvas.to_global(canvas.port_position(waiter, seconds, true)), _card(waiter).node.global_basis.z.normalized())
	await _frames()
	_check(canvas.focus_state(waiter) == XREBlueprintFocus.FOCUSED and canvas.is_port_hovered(waiter, seconds, true) and is_equal_approx(_card(waiter).ports[seconds].scale.x, XREBlueprintCanvas.HOVER_SCALE), "a port under the ray grows, its card still in focus")

	# An input in use keeps the focus it opened with, the rays on the input, not the graph.
	var keyboard := _service.get("_keyboard") as XREVirtualKeyboard
	keyboard.set_shown(true)
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await get_tree().create_timer(XREBlueprints.FOCUS_HOLD * 2.0).timeout
	await _frames(2)
	_check(_service.is_focused() and canvas.focus_state(waiter) == XREBlueprintFocus.FOCUSED and _face(_card(other).mesh.material_override).r < _face(_card(other).normal).r * 0.5,
			"while an input is in use the focus stays, the rest still darker")
	keyboard.set_shown(false)

	# Off the graph: a moment later, everything as it was.
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await _frames(1)
	_check(canvas.focus_state(waiter) == XREBlueprintFocus.FOCUSED, "gone off the graph, the ray keeps its focus a moment")
	await get_tree().create_timer(XREBlueprints.FOCUS_HOLD * 2.0).timeout
	await _frames(2)
	_check(canvas.focus_state(waiter) == XREBlueprintFocus.NORMAL and _card(other).mesh.material_override == _card(other).normal and _card(waiter).mesh.material_override == _card(waiter).normal
			and wire.mesh.material_override == wire.normal and not _tint(_card(waiter).frame.material_override).is_equal_approx(XREBlueprintFocus.FRAME), "then everything is as it was")

	# Defocus Transparent: the rest see-through, the far end of the wire not; Focus Off: the card not lit.
	features.set_value(XREFeatureSettings.FOCUS, XREFeatureSettings.OFF)
	features.set_value(XREFeatureSettings.DEFOCUS, XREFeatureSettings.TRANSPARENT)
	_aim_from(body, _card(waiter).node.global_basis.z.normalized())
	await _frames()
	_check(is_equal_approx(_card(other).mesh.transparency, 1.0 - XREBlueprintFocus.SEEN) and _card(other).mesh.material_override == _card(other).normal, "with Transparent a card out of focus is see-through, not darker")
	_check(is_equal_approx(_card(feeder).mesh.transparency, 1.0 - XREBlueprintFocus.SEEN) and feeder_out.transparency == 0.0, "the far end of the wire is not")
	_check(_card(waiter).mesh.transparency == 0.0 and _card(waiter).mesh.material_override == _card(waiter).normal, "with Focus off the card under the ray is as it is")
	# See-through layers don't undo each other (D-066 and D-072).
	XREBlueprintFade.set_faded(_card(other).node, true)
	_check(is_equal_approx(_card(other).mesh.transparency, 1.0 - XREBlueprintFade.SEEN), "covering an input it is fainter still")
	features.set_value(XREFeatureSettings.DEFOCUS, XREFeatureSettings.OFF)
	await _frames()
	_check(is_equal_approx(_card(other).mesh.transparency, 1.0 - XREBlueprintFade.SEEN), "out of focus no more, it still covers the input")
	XREBlueprintFade.set_faded(_card(other).node, false)
	_check(_card(other).mesh.transparency == 0.0, "and then it is as it was")

	# Focus Front (D-073): the card under the ray comes toward the user with its ports and wires, not lit.
	var port_place := canvas.port_position(waiter, seconds, true)
	var wire_points := PackedVector3Array()
	for index: int in wire.mesh.get_point_count(): wire_points.append(wire.mesh.get_point(index))
	var ray := _rig.right_hand.get("_ray") as GeometryInstance3D
	features.set_value(XREFeatureSettings.FOCUS, XREFeatureSettings.FRONT)
	await _frames()
	var card := _card(waiter)
	var same := wire.mesh.get_point_count() == wire_points.size()
	for index: int in wire_points.size(): same = same and wire.mesh.get_point(index).is_equal_approx(wire_points[index])
	_check(canvas.focus_state(waiter) == XREBlueprintFocus.FOCUSED and canvas.get_block_position(waiter).is_equal_approx(places[waiter])
			and canvas.port_position(waiter, seconds, true).is_equal_approx(port_place) and same, "with Front the card under the ray stays where it is, its ports and its wire keep their shape")
	var labels := card.node.find_children("*", "Label3D", true, false)
	_check(card.mesh.material_override == XREBlueprintFocus.variant(card.normal, XREBlueprintFocus.TOP) and card.mesh.material_override != card.normal
			and not labels.is_empty() and (labels[0] as Label3D).no_depth_test and wire.mesh.has_meta(&"untop") and wire.mesh.material_override != wire.normal,
			"and is drawn over everything: its materials skip the depth test, its labels and its wire too")
	# Without the depth test its parts are drawn back to front: by how far toward its front each stands.
	var parts := card.node.find_children("*", "GeometryInstance3D", true, false)
	var inverse := card.node.global_transform.affine_inverse()
	var ordered := true
	var highest := 0.0
	for part: Node in parts:
		var geometry := part as GeometryInstance3D
		highest = maxf(highest, geometry.sorting_offset)
		var front := (inverse * geometry.global_transform * geometry.get_aabb().get_center()).z
		for part_behind: Node in parts:
			var second := part_behind as GeometryInstance3D
			var other_front := (inverse * second.global_transform * second.get_aabb().get_center()).z
			if front > other_front + 0.0005 and geometry.sorting_offset <= second.sorting_offset: ordered = false
	_check(ordered and card.ports[seconds].sorting_offset > card.mesh.sorting_offset and (labels[0] as Label3D).sorting_offset > card.mesh.sorting_offset
			and parts.all(func(part: Node) -> bool: return part.has_meta(&"untop")) and card.mesh.transparency > 0.0 and not _card(feeder).mesh.has_meta(&"untop"),
			"its parts are drawn back to front — the face, then its ports, its labels — in the transparent pass, so that a panel doesn't cover it; the card at the far end of its wire as it is")
	_check(ray != null and ray.sorting_offset > highest, "the rays are drawn over it")
	features.set_value(XREFeatureSettings.FOCUS, XREFeatureSettings.OFF)
	await _frames()
	_check(card.mesh.material_override == card.normal and not card.mesh.has_meta(&"untop") and is_zero_approx(card.mesh.sorting_offset) and is_zero_approx(card.mesh.transparency) and not (labels[0] as Label3D).has_meta(&"untop")
			and not wire.mesh.has_meta(&"untop") and is_zero_approx(ray.sorting_offset), "Focus off, it and the rays are drawn as before")

	# A variable's box: in focus with its wire; the Variable socket at its far end stays as it is.
	# With Front it stays in its place, drawn over everything, and so does its wire to its card (D-075).
	features.set_value(XREFeatureSettings.FOCUS, XREFeatureSettings.FRONT)
	features.set_value(XREFeatureSettings.DEFOCUS, XREFeatureSettings.DIM)
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.BOXES)
	_service.blueprint.set_variable("focus_count", 0)
	_service.add_block("get_variable")
	await _frames()
	var getter: int = graph.nodes.back()["id"]
	canvas.preview_move(getter, Vector3(right + 0.3, -0.35, 0.0))
	canvas.commit_move(_service.blueprint, getter)
	await _frames()
	_service.call("_wire_variable", getter, "focus_count")
	# Not selected, the getter goes dark out of focus (D-122).
	_service.select_block(-1)
	await _frames(3)
	var shelf := canvas.get_boxes()
	var links := (canvas.get("_variable_links") as Array).filter(func(link: XREBlueprintCanvas.Wire) -> bool: return link.variable == "focus_count")
	var box_place := shelf.box_point("focus_count")
	var link_mesh: XREGraphWire = (links[0] as XREBlueprintCanvas.Wire).mesh if links.size() == 1 else null
	var link_ends := PackedVector3Array([link_mesh.get_point(0), link_mesh.get_point(link_mesh.get_point_count() - 1)] if link_mesh != null else [Vector3.ZERO, Vector3.ZERO])
	_aim_from(shelf.to_global(shelf.box_point("focus_count")) + Vector3.UP * 0.015, Vector3.BACK)
	await _frames()
	_check(shelf.box_focus("focus_count") == XREBlueprintFocus.FOCUSED and canvas.focus_state(getter) == XREBlueprintFocus.OUT, "the box under the ray is in focus, its card out of it")
	_check(shelf.box_point("focus_count").is_equal_approx(box_place) and _card(getter).node.position.is_equal_approx(Vector3(right + 0.3, -0.35, 0.0))
			and link_mesh != null and link_mesh.get_point(0).is_equal_approx(link_ends[0]) and link_mesh.get_point(link_mesh.get_point_count() - 1).is_equal_approx(link_ends[1])
			and link_mesh.has_meta(&"untop") and shelf.find_children("*", "MeshInstance3D", true, false).any(func(mesh: Node) -> bool: return mesh.has_meta(&"untop")),
			"with Front the box stays in its place, drawn over everything with its wire; its card and the wire's ends where they were")
	var socket := -1
	for index: int in _card(getter).sockets.size():
		if _card(getter).sockets[index].kind == XREBlueprintCanvas.VARIABLE: socket = index
	_check(links.size() == 1 and (links[0] as XREBlueprintCanvas.Wire).focus == XREBlueprintFocus.FOCUSED and socket >= 0 and not _card(getter).sockets[socket].visual.has_meta(&"unpainted")
			and _face(_card(getter).mesh.material_override).r < _face(_card(getter).normal).r * 0.5, "its wire is in focus; the Variable socket it goes into stays as it is on its darker card")
	_aim_from(_card(getter).node.global_position + _card(getter).node.global_basis.y.normalized() * 0.02, _card(getter).node.global_basis.z.normalized())
	await _frames()
	_check(canvas.focus_state(getter) == XREBlueprintFocus.FOCUSED and shelf.box_focus("focus_count") == XREBlueprintFocus.KEPT, "the ray on its card: the box at the far end of the wire stays as it is")
	_check(shelf.box_point("focus_count").is_equal_approx(box_place) and _card(getter).node.position.is_equal_approx(Vector3(right + 0.3, -0.35, 0.0)),
			"the box and the card in their places")

	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	features.set_value(XREFeatureSettings.FOCUS, XREFeatureSettings.OFF)
	features.set_value(XREFeatureSettings.DEFOCUS, XREFeatureSettings.OFF)
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, saved_variables)
	await get_tree().create_timer(XREBlueprints.FOCUS_HOLD * 2.0).timeout
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames(3)


## D-074: links. A wire from a variable's box or to a scene object becomes a
## link in its port — by the button on the wire, by pulling the wire into its
## port, by the button over the port, or by a link from the tray laid on it —
## its wire hidden or drawn as Link wires says, its name or projection as Link
## preview says; a link moves, and let go in the air it is a wire again.
func _test_d074() -> void:
	var features := _document.features
	var graph := _service.blueprint.graph
	var canvas := _service.canvas
	var history := _service.blueprint.history.get_version()
	var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
	_check(XREFeatureSettings.get_values(XREFeatureSettings.LINK_PREVIEW) == [XREFeatureSettings.VARIABLES, XREFeatureSettings.OFF, XREFeatureSettings.OBJECTS, XREFeatureSettings.ALL]
			and XREFeatureSettings.get_values(XREFeatureSettings.LINK_WIRES) == [XREFeatureSettings.ON_FOCUS, XREFeatureSettings.OFF, XREFeatureSettings.ON]
			and XREFeatureSettings.get_values(XREFeatureSettings.LINK_CREATE) == [XREFeatureSettings.WIRE_MENU, XREFeatureSettings.WIRE_BUTTON, XREFeatureSettings.PULL, XREFeatureSettings.PORT_BUTTON, XREFeatureSettings.ALWAYS],
			"Link preview, Link wires and Link from wire are settings with the values asked for, the first by default")
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.BOXES)
	_service.blueprint.set_variable("link_gain", 2.0)
	var right := -INF
	for card: XREBlueprintCanvas.Card in canvas.get("_cards") as Array: right = maxf(right, card.node.position.x + card.width * 0.5)
	_service.add_block("delay")
	await _frames()
	var delay: int = graph.nodes.back()["id"]
	_service.add_block("delay")
	await _frames()
	var other: int = graph.nodes.back()["id"]
	for item: Array in [[delay, Vector3(right + 0.6, 0.1, 0.0)], [other, Vector3(right + 0.6, -0.3, 0.0)]]:
		canvas.preview_move(int(item[0]), item[1])
		canvas.commit_move(_service.blueprint, int(item[0]))
		await _frames()
	var seconds := graph.input_port(graph.find_node(delay), "seconds")
	_service.call("_wire_box_to_port", "link_gain", delay, seconds)
	await _frames(3)
	var getter := canvas.inline_getter(delay, seconds)
	var ref := XREBlueprintLinks.ref(getter, XREBlueprintLinks.VARIABLE, delay, seconds)
	var front := canvas.global_basis.z.normalized()
	_check(getter >= 0 and canvas.ref_wire(ref) != null and canvas.ref_wire(ref).visible and not XREBlueprintLinks.is_link(graph.find_node(getter), XREBlueprintLinks.VARIABLE), "a wire from the box into Seconds, not a link")
	# Always (D-077): a new wire to a box is a link at once, in the same edit; undo takes both back.
	features.set_value(XREFeatureSettings.LINK_CREATE, XREFeatureSettings.ALWAYS)
	var always_version := _service.blueprint.history.get_version()
	_service.call("_wire_box_to_port", "link_gain", other, seconds)
	await _frames(3)
	var linked := canvas.inline_getter(other, seconds)
	_check(linked >= 0 and XREBlueprintLinks.is_link(graph.find_node(linked), XREBlueprintLinks.VARIABLE) and _service.blueprint.history.get_version() == always_version + 1
			and XREBlueprintLinks.is_link(graph.find_node(getter), XREBlueprintLinks.VARIABLE) == false, "with Always a new wire is a link at once, as one edit; the wire made before stays a wire")
	_service.blueprint.undo()
	await _frames(3)
	_check(canvas.inline_getter(other, seconds) < 0, "undo takes the wire and its link back together")
	var plain := canvas.ref_wire(ref)
	_aim_from(canvas.to_global(plain.get_point(plain.get_point_count() / 2)), front)
	await _frames()
	_check(pointer.button == null or not pointer.button.visible, "with Always the ray on a wire made before puts up no link button")
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await _frames()
	features.set_value(XREFeatureSettings.LINK_CREATE, XREFeatureSettings.WIRE_BUTTON)

	# Wire button: the ray on the wire puts a link button there; the trigger on it makes the link.
	var mesh := canvas.ref_wire(ref)
	var middle := canvas.to_global(mesh.get_point(mesh.get_point_count() / 2))
	_aim_from(middle, front)
	await _frames()
	_check(pointer.button != null and pointer.button.visible and pointer.button_make and pointer.button_ref.get("block") == getter, "the ray on the wire puts up a link button")
	await _click_from(pointer.button.global_position, front)
	await _frames(2)
	_check(XREBlueprintLinks.is_link(graph.find_node(getter), XREBlueprintLinks.VARIABLE) and &"make_link" in _operations, "its trigger makes the wire a link, as a logged edit")
	var link := _link_socket(delay)
	_check(link != null and link.text != null and link.text.text == "link" and link.port == seconds, "the link is in Seconds and says link with Link preview Off")
	_check(not canvas.ref_wire(ref).visible, "its wire is hidden with Link wires Off")
	_check(_service.blueprint.build(), "the graph with a link still builds")

	# Link preview Variables: the variable's name; Link wires On: the wire drawn, faint, from the link's ring.
	features.set_value(XREFeatureSettings.LINK_PREVIEW, XREFeatureSettings.VARIABLES)
	features.set_value(XREFeatureSettings.LINK_WIRES, XREFeatureSettings.ON)
	await _frames(3)
	link = _link_socket(delay)
	mesh = canvas.ref_wire(ref)
	_check(link != null and link.text.text == "link_gain", "with Link preview Variables it says the variable's name")
	_check(mesh.visible and is_equal_approx(mesh.transparency, 1.0 - XREBlueprintCanvas.LINK_SEEN), "with Link wires On its wire is drawn, faint")
	var ring := _card(delay).node.transform * link.end
	_check(mesh.get_point(mesh.get_point_count() - 1).distance_to(ring) < 0.002, "from the link's ring")
	features.set_value(XREFeatureSettings.LINK_WIRES, XREFeatureSettings.ON_FOCUS)
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await get_tree().create_timer(XREBlueprints.FOCUS_HOLD * 2.0).timeout
	await _frames(2)
	_check(not canvas.ref_wire(ref).visible, "On focus: hidden while the ray is elsewhere")
	_aim_from(_card(delay).node.global_position + _card(delay).node.global_basis.y.normalized() * 0.02, _card(delay).node.global_basis.z.normalized())
	await _frames(2)
	_check(canvas.ref_wire(ref).visible, "drawn while the ray is on its card")

	# By the link, a button takes it back to its wire.
	var link_point := _card(delay).node.global_transform * link.center
	_aim_from(link_point, _card(delay).node.global_basis.z.normalized())
	await _frames()
	_check(pointer.button != null and pointer.button.visible and not pointer.button_make, "the ray on a link puts up a wire button")
	await _click_from(pointer.button.global_position, _card(delay).node.global_basis.z.normalized())
	await _frames(2)
	_check(not XREBlueprintLinks.is_link(graph.find_node(getter), XREBlueprintLinks.VARIABLE) and _link_socket(delay) == null and &"unlink" in _operations, "its trigger makes the link a wire again")
	features.set_value(XREFeatureSettings.LINK_WIRES, XREFeatureSettings.OFF)

	# Pull: the grip on the wire, the hand to its port, let go: a link; let go where it was taken: still a wire.
	features.set_value(XREFeatureSettings.LINK_CREATE, XREFeatureSettings.PULL)
	await _frames()
	mesh = canvas.ref_wire(ref)
	middle = canvas.to_global(mesh.get_point(mesh.get_point_count() / 2))
	_aim_from(middle, front)
	await _frames()
	_check(pointer.button == null or not pointer.button.visible, "with Pull no button on the wire")
	_right.set_input(&"grip", 1.0)
	await _frames()
	_check(not pointer.pull.is_empty() and not mesh.visible, "the grip takes the wire, which follows the hand")
	_right.set_input(&"grip", 0.0)
	await _frames(2)
	_check(not XREBlueprintLinks.is_link(graph.find_node(getter), XREBlueprintLinks.VARIABLE) and pointer.pull.is_empty() and canvas.ref_wire(ref).visible, "let go where it was taken, it stays a wire")
	_aim_from(middle, front)
	await _frames()
	_right.set_input(&"grip", 1.0)
	await _frames()
	_aim_from(canvas.to_global(canvas.port_position(delay, seconds, true)), front)
	await _frames()
	_right.set_input(&"grip", 0.0)
	await _frames(2)
	_check(XREBlueprintLinks.is_link(graph.find_node(getter), XREBlueprintLinks.VARIABLE), "pulled into its port and let go, it is a link")
	_service.call("_set_link", ref, false)
	await _frames(2)

	# Port button: the ray on the port puts the button over it.
	features.set_value(XREFeatureSettings.LINK_CREATE, XREFeatureSettings.PORT_BUTTON)
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await _frames()
	mesh = canvas.ref_wire(ref)
	_aim_from(canvas.to_global(canvas.port_position(delay, seconds, true)), _card(delay).node.global_basis.z.normalized())
	await _frames()
	var over := pointer.button.global_position - canvas.to_global(canvas.port_position(delay, seconds, true)) if pointer.button != null else Vector3.ZERO
	_check(pointer.button != null and pointer.button.visible and pointer.button_make and over.dot(_card(delay).node.global_basis.y.normalized()) > 0.01, "with Port button the ray on the port puts up a link button over it")
	await _click_from(pointer.button.global_position, _card(delay).node.global_basis.z.normalized())
	await _frames(2)
	_check(XREBlueprintLinks.is_link(graph.find_node(getter), XREBlueprintLinks.VARIABLE), "its trigger makes the link")
	_check(float(_service.call("_link_wire_hit", middle + front * 0.4, -front, 1.0)) < 0.0, "a link's hidden wire is not on the ray")

	# Let go in the air, a link carried away from its port is a wire again.
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await _frames()
	_right.set_input(&"grip", 1.0)
	await _frames()
	_service.call("_carry_link", pointer, XREBlueprintLinks.of_variable("link_gain"), XREBlueprintLinks.ref(getter, XREBlueprintLinks.VARIABLE, delay, seconds))
	await _frames()
	_check(pointer.carried != null and not _link_socket(delay).visual.visible, "the grip carries the link itself: its port shows none")
	_right.set_input(&"grip", 0.0)
	await _frames(2)
	_check(pointer.carried == null and not XREBlueprintLinks.is_link(graph.find_node(getter), XREBlueprintLinks.VARIABLE) and canvas.inline_getter(delay, seconds) == getter, "let go in the air it is the wire again")

	# A link from the tray: on a wired port it takes the wire; on a free one it waits for a box.
	_check(_service.token_tray.get_values().any(func(value: Variant) -> bool: return XREBlueprintLinks.is_link_value(value)), "the tray has a link")
	_service.call("_dock_blank_link", {"block": delay, "port": seconds, "kind": -1}, _rig.right_hand)
	await _frames(2)
	_check(XREBlueprintLinks.is_link(graph.find_node(getter), XREBlueprintLinks.VARIABLE), "laid on a port wired from a box, it makes that wire a link")
	var other_seconds := graph.input_port(graph.find_node(other), "seconds")
	_service.call("_dock_blank_link", {"block": other, "port": other_seconds, "kind": -1}, _rig.right_hand)
	_check(_service.get("_pending_id") == other and _service.get("_pending_link") == true, "laid on a free port, a wire from it waits for a box")
	_service.call("_wire_box_to_port", "link_gain", other, other_seconds)
	await _frames(2)
	var other_getter := canvas.inline_getter(other, other_seconds)
	_check(other_getter >= 0 and XREBlueprintLinks.is_link(graph.find_node(other_getter), XREBlueprintLinks.VARIABLE), "the box it ends on is read through a link")

	# Moved to another port, a link leaves its own port the default token.
	_service.call("_set_link", XREBlueprintLinks.ref(other_getter, XREBlueprintLinks.VARIABLE, other, other_seconds), false)
	await _frames(2)
	_service.call("_dock_link", XREBlueprintLinks.of_variable("link_gain"), {"block": other, "port": other_seconds, "kind": -1}, XREBlueprintLinks.ref(getter, XREBlueprintLinks.VARIABLE, delay, seconds))
	await _frames(2)
	_check(canvas.inline_getter(delay, seconds) < 0 and graph.find_node(getter).is_empty() and (graph.find_node(delay)["params"] as Dictionary).has("seconds"), "moved away, the link takes its Get Variable along; its port gets its default")
	var moved := canvas.inline_getter(other, other_seconds)
	_check(moved >= 0 and XREBlueprintLinks.is_link(graph.find_node(moved), XREBlueprintLinks.VARIABLE) and graph.find_node(other_getter).is_empty(), "the port it goes into reads the variable through it")

	# An object's link: the Target wire hidden, the object's projection in the ring.
	features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ON_NODE)
	features.set_value(XREFeatureSettings.LINK_PREVIEW, XREFeatureSettings.ALL)
	var cube: Node3D
	for found: Node in _document.get_scene_root().find_children("*", "CSGShape3D", true, false):
		if (found as CSGShape3D).is_root_shape() and found != _host:
			cube = found as Node3D
			break
	_service.add_block("set_property")
	await _frames()
	var setter: int = graph.nodes.back()["id"]
	canvas.preview_move(setter, Vector3(right + 0.6, -0.7, 0.0))
	canvas.commit_move(_service.blueprint, setter)
	if cube != null: _service.blueprint.choose_target(setter, cube)
	await _frames(3)
	var target_port := XREBlueprintGraph.target_port(graph.find_node(setter))
	var target_wire := _service.call("_target_wire_of", setter) as XREBlueprints.TargetWire
	_check(cube != null and target_wire != null and target_wire.mesh.visible and not target_wire.link, "Set Property wired to a cube of the scene")
	_aim_from(canvas.to_global(canvas.port_position(setter, target_port, true)), _card(setter).node.global_basis.z.normalized())
	await _frames()
	_check(pointer.button != null and pointer.button.visible and pointer.button_make and pointer.button_ref.get("key") == XREBlueprintLinks.TARGET, "the ray on its Target puts up a link button")
	await _click_from(pointer.button.global_position, _card(setter).node.global_basis.z.normalized())
	await _frames(3)
	target_wire = _service.call("_target_wire_of", setter) as XREBlueprints.TargetWire
	var target_link := _link_socket(setter)
	_check(XREBlueprintLinks.is_link(graph.find_node(setter), XREBlueprintLinks.TARGET) and target_wire != null and target_wire.link and not target_wire.mesh.visible, "its trigger makes the Target a link, its wire hidden")
	var projection := (target_link.visual.get_meta(&"head") as Node3D).get_meta(&"inside") as Node3D if target_link != null else null
	_check(cube != null and target_link != null and target_link.text.text == cube.name and projection != null and projection.get_child_count() == 1 and projection.get_child(0).get_child_count() > 0,
			"with Link preview All it says the object's name and has its projection in its ring")
	_check(_service.blueprint.validate_scene().is_empty() and _service.blueprint.build(), "a Target link builds")
	features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ADAPTER)
	await _frames(3)
	target_link = _link_socket(setter)
	_check(target_link != null and target_link.visual.has_meta(&"inside") and canvas.link_end(setter, XREBlueprintLinks.TARGET) is Vector3, "with Targets on Adapter the link's ring is at the adapter's end")

	features.set_value(XREFeatureSettings.LINK_PREVIEW, XREFeatureSettings.OFF)
	features.set_value(XREFeatureSettings.LINK_CREATE, XREFeatureSettings.WIRE_BUTTON)
	features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.WINDOW)
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.WINDOW)
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await _frames()
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames(3)


## D-078: the variables' boxes stand among the cards, where they were put: the
## grip carries a box as it does a card, one edit on letting go. New variables
## come from the block menu, their box where it was opened, read by the input
## whose wire opened it in the same edit.
func _test_d078() -> void:
	var features := _document.features
	var graph := _service.blueprint.graph
	var canvas := _service.canvas
	var boxes := canvas.get_boxes()
	var menu := _service.block_menu
	var keyboard := _service.get("_keyboard") as XREVirtualKeyboard
	var history := _service.blueprint.history.get_version()
	features.set_value(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.BOXES)
	_service.blueprint.set_variable("place_gain", 1.0)
	await _frames()
	var row := boxes.box_point("place_gain")
	var node := boxes.get_node_or_null("Box_place_gain")
	_check(boxes.has_box("place_gain") and not graph.find_variable("place_gain").has("vr_position"), "a variable never put anywhere has its box in the row below the cards")

	# The grip on the box's body carries it on the ray; letting go is one edit, and it stays there.
	var start := boxes.to_global(row) + Vector3.UP * 0.019
	var version := _service.blueprint.history.get_version()
	_aim_from(start, Vector3.BACK)
	await _frames()
	_right.set_input(&"grip", 1.0)
	await _frames()
	_aim_from(start + Vector3(0.1, 0.05, 0.0), Vector3.BACK)
	await _frames()
	_check(boxes.box_point("place_gain").distance_to(row + Vector3(0.1, 0.05, 0.0)) < 0.002 and _service.blueprint.history.get_version() == version, "the grip carries the box along the ray, the graph not edited yet")
	_right.set_input(&"grip", 0.0)
	await _frames()
	var placed: Dictionary = graph.find_variable("place_gain")
	_check(_service.blueprint.history.get_version() == version + 1 and placed.get("vr_position") is Vector2 and &"move_variable" in _operations, "letting go is one edit, Move Variable, that keeps the box's place")
	_check(boxes.box_point("place_gain").distance_to(row + Vector3(0.1, 0.05, 0.0)) < 0.002 and boxes.get_node_or_null("Box_place_gain") == node, "the box stays where it was let go, the same box")
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	var lowest := -1
	var bottom := INF
	for card: XREBlueprintCanvas.Card in canvas.get("_cards") as Array:
		if card.node.position.y < bottom:
			bottom = card.node.position.y
			lowest = card.id
	var moved_box := boxes.box_point("place_gain")
	if lowest >= 0:
		canvas.preview_move(lowest, canvas.get_block_position(lowest) + Vector3.DOWN * 0.4)
		canvas.commit_move(_service.blueprint, lowest)
		await _frames()
	_check(lowest >= 0 and boxes.box_point("place_gain").is_equal_approx(moved_box), "a box that was put somewhere doesn't follow the cards")
	if lowest >= 0: _service.blueprint.undo()
	_service.blueprint.undo()
	await _frames()
	_check(boxes.box_point("place_gain").is_equal_approx(row) and not graph.find_variable("place_gain").has("vr_position") and boxes.get_node_or_null("Box_place_gain") == node,
			"undo puts the box back in the row, moving the same box")

	# A new variable from the menu: the keyboard asks its name; with none typed it is named by its type.
	_service.open_block_menu()
	await _frames()
	menu.choose_chip(menu.get_chip_titles().find("Native"))
	var floats: Array[Dictionary] = menu.get_listed().filter(func(action: Dictionary) -> bool: return action["id"] == "variable:new:float")
	_check(not floats.is_empty() and menu.get_listed().any(func(action: Dictionary) -> bool: return action["id"] == "variable:new:Color"), "the menu's native blocks offer a new variable of each type")
	menu.choose_chip(menu.get_chip_titles().find(str(_host.name)))
	_check(menu.get_listed().any(func(action: Dictionary) -> bool: return action["id"] == "variable:new:float"), "so does the host's chip")
	var place: Vector3 = _service.call("_menu_place", null)
	var expected := canvas.position_from_block({"position": Vector2(place.x, place.y), "vr_depth": place.z})
	var variables := graph.variables.size()
	if not floats.is_empty(): menu.action_chosen.emit(floats[0])
	await _frames()
	_check(keyboard.is_shown() and graph.variables.size() == variables, "choosing it asks for the name, nothing added yet")
	_service.call("_token_text_submitted", "")
	await _frames()
	var added: Dictionary = graph.find_variable("new_float")
	_check(added.get("value") is float and added.get("vr_position") is Vector2 and &"add_variable" in _operations, "Done with no name adds new_float, as one edit")
	_check(boxes.has_box("new_float") and boxes.box_point("new_float").distance_to(expected) < 0.001, "its box is where the menu was opened, beside its card")
	_check(_service.call("_free_variable_name", 0.0) == "new_float_2", "the next one of the type gets the next free name")
	if not floats.is_empty(): _service.call("_ask_new_variable", floats[0], null)
	_service.call("_token_text_submitted", "place_gain")
	await _frames()
	_check(graph.variables.size() == variables + 1, "a taken name adds nothing")
	keyboard.close()

	# From the wire of a number input let go in empty space: the new variable and its reader are one edit.
	_service.add_block("delay")
	await _frames()
	var delay: int = graph.nodes.back()["id"]
	var seconds := graph.input_port(graph.find_node(delay), "seconds")
	_check(_service.click_port(delay, seconds, true), "a wire from Delay's Seconds")
	var point := canvas.get_block_position(delay) + Vector3(-0.35, 0.05, 0.04)
	_service.call("_open_menu_for_wire", point)
	await _frames()
	menu.choose_chip(menu.get_chip_titles().find("Native"))
	var listed := menu.get_listed()
	var wired: Array[Dictionary] = listed.filter(func(action: Dictionary) -> bool: return action["id"] == "variable:new:float")
	_check(not wired.is_empty() and not listed.any(func(action: Dictionary) -> bool: return str(action["id"]).begins_with("variable:new:") and action["id"] != "variable:new:float"),
			"the input's pin lists a new variable of its own type only, not even an int it could take (D-079)")
	version = _service.blueprint.history.get_version()
	if not wired.is_empty(): menu.action_chosen.emit(wired[0])
	await _frames()
	_check(int(_service.get("_pending_id")) == -1 and keyboard.is_shown(), "the wire is done with, the keyboard asks the name")
	_service.call("_token_text_submitted", "speed_limit")
	await _frames()
	var readers := graph.edges.filter(func(edge: Dictionary) -> bool:
		var params: Dictionary = graph.find_node(edge["from"]).get("params", {})
		return edge["to"] == delay and edge["to_port"] == seconds and params.get("variable") == "speed_limit")
	_check(not graph.find_variable("speed_limit").is_empty() and readers.size() == 1 and _service.blueprint.history.get_version() == version + 1, "the new variable is read by Seconds, both in one edit")
	_check(boxes.box_point("speed_limit").distance_to(point) < 0.001, "its box is where the wire was let go")
	_service.blueprint.undo()
	await _frames()
	_check(graph.find_variable("speed_limit").is_empty() and not graph.edges.any(func(edge: Dictionary) -> bool: return edge["to"] == delay and edge["to_port"] == seconds), "one undo takes both back")
	keyboard.close()
	_service.close_block_palette()

	# D-079: an operator's operand takes any value, but a new variable for it is of the type in it.
	_service.add_block("operator")
	await _frames()
	var add: int = graph.nodes.back()["id"]
	_check(_service.click_port(add, 0, true), "a wire from Add's A, a float in it")
	_service.call("_open_menu_for_wire", canvas.get_block_position(add) + Vector3(-0.3, 0.0, 0.04))
	await _frames()
	menu.choose_chip(menu.get_chip_titles().find("Native"))
	var operand := menu.get_listed().map(func(action: Dictionary) -> String: return str(action["id"]))
	_check(operand.has("variable:new:float") and operand.has("variable:new:int") and operand.has("variable:new:Vector3") and not operand.has("variable:new:bool"),
			"Add's A lists new variables of the types Add works on, an int as well as a float (D-080), not a bool it couldn't add")
	_service.cancel_connection()
	_service.close_block_palette()
	await _frames()

	# D-080: an int has its own color. Add takes either and gives an int for two ints, a float else, its ports showing which.
	var int_color := XREBlueprintCanvas.COLORS[XREBlueprintGraph.INTEGER]
	var float_color := XREBlueprintCanvas.COLORS[XREBlueprintGraph.NUMBER]
	_check(int_color != float_color, "an int's color is not a float's")
	_service.blueprint.set_variable("steps", 2)
	_service.blueprint.set_variable("rate", 0.5)
	await _frames()
	_service.call("_wire_box_to_port", "steps", add, 0)
	await _frames(3)
	var added_card := _card(add)
	_check(added_card != null and _tint(added_card.ports[0].material_override) == int_color and _tint(added_card.ports[2].material_override) == int_color and graph.find_node(add)["params"]["b"] is int,
			"an int into A: A and the result are an int's color, B's token an int")
	var int_wires := (canvas.get("_wires") as Array).filter(func(wire: XREBlueprintCanvas.Wire) -> bool: return wire.variable == "steps" and wire.to.id == add)
	_check(int_wires.size() == 1 and _tint((int_wires[0] as XREBlueprintCanvas.Wire).normal) == int_color, "the wire from the int's box is an int's color")
	_check(_service.click_port(add, 1, true), "a wire from Add's B, an int A wired")
	_service.call("_open_menu_for_wire", canvas.get_block_position(add) + Vector3(-0.3, -0.1, 0.04))
	await _frames()
	menu.choose_chip(menu.get_chip_titles().find("Native"))
	var second := menu.get_listed().map(func(action: Dictionary) -> String: return str(action["id"]))
	_check(second.has("variable:new:int") and second.has("variable:new:float") and not second.has("variable:new:Vector3") and not second.has("variable:new:String") and second.has("variable:get:rate"),
			"by an int, B lists an int or a float, new or there, but not a vector")
	_service.cancel_connection()
	_service.close_block_palette()
	_service.call("_wire_box_to_port", "rate", add, 1)
	await _frames(3)
	added_card = _card(add)
	_check(added_card != null and _tint(added_card.ports[0].material_override) == int_color and _tint(added_card.ports[1].material_override) == float_color and _tint(added_card.ports[2].material_override) == float_color,
			"an int into A and a float into B: A an int's color, B and the result a float's")

	# D-079: deleting a box takes its wires and links into ports with it; the ports get their default tokens back.
	_service.blueprint.set_variable("drop_gain", 4.0)
	await _frames()
	_service.call("_wire_box_to_port", "drop_gain", delay, seconds)
	await _frames()
	version = _service.blueprint.history.get_version()
	_service.call("_remove_box", "drop_gain")
	await _frames()
	var params: Dictionary = graph.find_node(delay)["params"]
	_check(graph.find_variable("drop_gain").is_empty() and not graph.edges.any(func(edge: Dictionary) -> bool: return edge["to"] == delay and edge["to_port"] == seconds)
			and not graph.nodes.any(func(block: Dictionary) -> bool: return (block["params"] as Dictionary).get("variable") == "drop_gain")
			and params.get("seconds") is float and _service.blueprint.history.get_version() == version + 1 and &"remove_variable" in _operations,
			"a box wired into Seconds is deleted with its wire and the Get Variable it stands for, Seconds a token again, as one edit")
	_service.blueprint.undo()
	await _frames()
	_check(not graph.find_variable("drop_gain").is_empty() and graph.edges.any(func(edge: Dictionary) -> bool: return edge["to"] == delay and edge["to_port"] == seconds), "one undo brings the box and its wire back")
	# A card that uses the variable keeps it: the card's frame and its wire to the box flash, the wire drawn even as a link.
	_service.add_block("set_variable")
	await _frames()
	var setter: int = graph.nodes.back()["id"]
	_service.call("_wire_variable", setter, "drop_gain")
	await _frames()
	_service.call("_remove_box", "drop_gain")
	await _frames()
	var flashing := _card(setter)
	_check(not graph.find_variable("drop_gain").is_empty() and flashing != null and flashing.flash and str(_service.status).contains("Set Variable #%d" % setter),
			"a box a Set Variable card uses stays; the message names the card, and it flashes")
	_check(flashing != null and _tint(flashing.frame.material_override) == XREBlueprintCanvas.FLASH_FRAME, "in the flash's color")
	await get_tree().create_timer(XREBlueprints.FLASH_TIME + 0.2).timeout
	_check(_card(setter) != null and not _card(setter).flash, "the flash goes after a while")

	features.set_value(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.WINDOW)
	_aim_from(Vector3(-5, 0, 0), Vector3.BACK)
	await _frames()
	while _service.blueprint.history.get_version() > history: _service.blueprint.undo()
	await _frames(3)


## The link socket of the card of block [param id], or null.
func _link_socket(id: int) -> XREBlueprintCanvas.Socket:
	var card := _card(id)
	if card == null: return null
	for socket: XREBlueprintCanvas.Socket in card.sockets:
		if socket.kind == XREBlueprintCanvas.LINK: return socket
	return null


## The face of a card's body material.
static func _face(material: Material) -> Color:
	return (material as ShaderMaterial).get_shader_parameter(&"face_tint") if material is ShaderMaterial else Color.BLACK


## The color [param material] draws in: a standard material's albedo, a shader's tint.
static func _tint(material: Material) -> Color:
	if material is BaseMaterial3D: return (material as BaseMaterial3D).albedo_color
	return (material as ShaderMaterial).get_shader_parameter(&"tint") if material is ShaderMaterial else Color.BLACK


## A color near [param expected], within a step of 255.
static func _near(color: Color, expected: Color) -> bool:
	return absf(color.r - expected.r) < 0.004 and absf(color.g - expected.g) < 0.004 and absf(color.b - expected.b) < 0.004 and is_equal_approx(color.a, expected.a)


## Every line edit under [param node], internal ones too, into [param found].
func _line_edits(node: Node, found: Array[LineEdit]) -> Array[LineEdit]:
	for child: Node in node.get_children(true):
		if child is LineEdit: found.append(child as LineEdit)
		_line_edits(child, found)
	return found



## The graph's own functions in the headset (docs/blueprint_functions.md), by
## the right hand's ray and trigger: a call's open button left of its copy
## shows the body in the graph's place, the badge's ‹ back; the Entry's plus,
## right, adds an input, the Return's, left, an output; the Entry's pure
## switch makes the function pure; a plate in the Functions window shows the
## body too, the plus plate makes a function, the grip takes a call out
## (D-148); the badge over the Entry goes back where it was entered from; the
## ring has Functions.
func _test_functions() -> void:
	var start := _service.blueprint.history.get_version()
	await _functions_in_headset()
	# Whatever step stopped it, the graph is shown and the edits are undone for the tests after it.
	_service.open_function("")
	while _service.blueprint.history.get_version() > start and _service.blueprint.history.has_undo(): _service.blueprint.undo()
	await _frames()
	_check(_service.blueprint.root.functions.is_empty() and _service.blueprint.opened.is_empty(), "undo takes the function and its call out")


func _functions_in_headset() -> void:
	var blueprint := _service.blueprint
	var canvas := _service.canvas
	var name := blueprint.create_function()
	# Deep in VR, as cards moved by hand are: the body is shown as deep.
	var call := blueprint.add_function_call(name, Vector2(-900, 900), {}, 0.6)
	await _frames()
	var card := _card(call)
	_check(card != null and card.open != null and (card.copy == null or is_equal_approx(card.open_point.x, card.copy_point.x - XREBlueprintCanvas.SWAP_SHIFT) and is_equal_approx(card.open_point.y, card.copy_point.y))
			and card.open_point.y > card.height * 0.4, "a call of the graph's function has its open button over it, left of its copy in their row")
	if card == null or card.open == null: return
	var front := card.node.global_basis.z.normalized()
	_aim_from(card.node.global_position, front)
	await _frames()
	_check(card.open.visible and card.trash.visible and (card.copy == null or card.copy.visible), "the ray on the call shows the open button with the trash and the copy")
	_aim_from(card.node.to_global(card.open_point), front)
	await _frames()
	_check(card.open.scale.x > 1.0, "the ray takes the open button: it grows")
	var call_point := canvas.position_from_block(blueprint.graph.find_node(call))
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(blueprint.opened == name and _card(call) == null and _card(1) != null and _card(2) != null, "trigger shows the body: its Entry and Return in the graph's place")
	var entry_point := canvas.position_from_block(blueprint.graph.find_node(1))
	_check(entry_point.distance_to(call_point) < 0.001, "the body's Entry stands where its call was, as deep: %s, %s" % [entry_point, call_point])
	var up := _rig.global_basis.y.normalized()
	var entry_world := canvas.to_global(canvas.get_block_transform(1).origin)
	var entry_height := canvas.get_block_size(1).y
	var window := _panels.find_window(XREBlueprintFunctionsTab)
	_check(window != null and window.is_on_top(), "the Functions window is open, drawn over the scene and the cards")
	if window == null: return
	var under := canvas.to_global(canvas.get_block_transform(1).origin - Vector3.UP * entry_height * 0.5) - up * (XREBlueprints.FUNCTIONS_GAP + window.size_m.y * 0.5)
	_check(window.global_position.distance_to(under) < 0.01, "the window comes under the body's Entry: %s, %s" % [window.global_position, under])
	var badge: XREBlueprintBadge = _service.get("_badge")
	var title: Label = badge.get("_title")
	_check(badge.get_back_button().visible and title.text == "ƒ " + name, "the badge has ‹ back and the function's name while the body is shown: %s" % title.text)
	_check(badge.global_position.y > entry_world.y + entry_height * 0.5 and Vector2(badge.global_position.x - entry_world.x, badge.global_position.z - entry_world.z).length() < 0.2,
			"the badge stands over the Entry, not over the object: %s, %s" % [badge.global_position, entry_world])
	var entry := _card(1)
	var ending := _card(2)
	_check(entry != null and entry.pure_switch != null and entry.pin_plus != null and entry.pin_plus_point.x > 0.0, "the Entry has its pure switch and its plus under its right corner")
	_check(ending != null and ending.pin_plus != null and ending.pin_plus_point.x < 0.0, "the Return's plus is under its left corner, on its inputs' side")
	if entry == null or entry.pin_plus == null: return
	front = entry.node.global_basis.z.normalized()
	_aim_from(entry.node.global_position, front)
	await _frames()
	_aim_from(entry.node.to_global(entry.pin_plus_point), front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check((blueprint.root.find_function(name)["inputs"] as Array).size() == 1, "trigger on the Entry's plus adds an input")
	entry = _card(1)
	if entry == null or entry.pure_switch == null: return
	_aim_from(entry.node.to_global(entry.pure_point), front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(bool(blueprint.root.find_function(name)["pure"]) and _card(1) != null and _card(1).pure_on, "trigger on the pure switch makes the function pure")
	# A function's body entered from this one's call: back comes here, as it was shown.
	var inner := blueprint.create_function()
	var shown_view := canvas.get_view()
	var inner_call := blueprint.add_function_call(inner, Vector2(300, 300))
	await _frames()
	_service.open_function(inner, canvas.position_from_block(blueprint.graph.find_node(inner_call)), true)
	await _frames()
	_check(blueprint.opened == inner, "a call's open button in a body shows the other body")
	await _click_on(badge, _pixel_of(badge.get_back_button()))
	_check(blueprint.opened == name and canvas.get_view().is_equal_approx(shown_view), "‹ comes back to the body it was entered from, as it was shown")
	await _click_on(badge, _pixel_of(badge.get_back_button()))
	_check(blueprint.opened.is_empty() and _card(call) != null and not badge.get_back_button().visible, "‹ again: the graph")
	blueprint.undo()
	blueprint.undo()
	await _frames()
	_check(blueprint.root.find_function(inner).is_empty(), "undo takes the inner function out")
	var plates := _service.plates
	_check(plates.plate_count() == 1, "the function has a plate in the Functions window")
	var spot := window.global_position
	await _click_on(window, _pixel_of(plates.get_plate(name)))
	_check(blueprint.opened == name, "trigger on the plate shows the body")
	var over := canvas.to_local(window.global_position + window.global_basis.y.normalized() * (window.size_m.y * 0.5 + XREBlueprints.FUNCTIONS_LIFT))
	var shown := canvas.position_from_block(blueprint.graph.find_node(1))
	_check(shown.distance_to(over) < 0.001 and window.global_position.is_equal_approx(spot), "its Entry stands over the window, which stays: %s, %s" % [shown, over])
	# Another function from the plus plate, then back to the first: the Entry stays where it was.
	var top := window.global_position + window.global_basis.y.normalized() * window.size_m.y * 0.5
	await _click_on(window, _pixel_of(plates.get_plus()))
	await _frames()
	var second := blueprint.opened
	_check(blueprint.root.functions.size() == 2 and second != name and canvas.position_from_block(blueprint.graph.find_node(1)).distance_to(shown) < 0.001,
			"the plus plate makes a function whose Entry stands where the first's did")
	var grown_top := window.global_position + window.global_basis.y.normalized() * window.size_m.y * 0.5
	_check(grown_top.distance_to(top) < 0.001 and plates.plate_count() == 2, "the window grows by a plate downward, its top where it was: %s, %s" % [grown_top, top])
	await _click_on(window, _pixel_of(plates.get_plate(name)))
	_check(blueprint.opened == name and canvas.position_from_block(blueprint.graph.find_node(1)).distance_to(shown) < 0.001, "the first's plate: its Entry where it was")
	# The grip on a plate takes a call out into the body shown.
	var calls := XREBlueprintUserFunctions.count_calls(blueprint.root, second)
	spot = window.global_position
	_right.set_pose(&"aim", _pose_at(window, _pixel_of(plates.get_plate(second))), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_right.set_input(&"grip", 1.0)
	await _frames()
	_right.set_input(&"grip", 0.0)
	await _frames()
	_check(XREBlueprintUserFunctions.count_calls(blueprint.root, second) == calls + 1 and window.global_position.is_equal_approx(spot), "the grip on a plate takes a call out, the window stays")
	# The badge's trash in a body deletes the function, not the Blueprint (D-149).
	var path := blueprint.path
	_service.call("_create_from_plates")
	await _frames()
	var third := blueprint.opened
	await _click_on(badge, _pixel_of(badge.get_trash_button()))
	_check(blueprint.root.find_function(third).size() > 0 and title.text == "Delete function?", "the first click on the body's trash arms it: %s" % title.text)
	await _click_on(badge, _pixel_of(badge.get_trash_button()))
	_check(blueprint.root.find_function(third).is_empty() and blueprint.root.functions.size() == 2 and blueprint.opened.is_empty() and _service.is_open() and blueprint.path == path,
			"the second deletes the function only: the graph is shown, the Blueprint stays")
	_service.call("_open_from_plates", name)
	await _frames()
	await _click_on(badge, _pixel_of(badge.get_trash_button()))
	await _click_on(badge, _pixel_of(badge.get_trash_button()))
	_check(not blueprint.root.find_function(name).is_empty() and blueprint.opened.is_empty() and _service.is_open() and blueprint.path == path,
			"a function with calls stays: back in the graph, where its calls flash")
	var items: Array[Dictionary] = _service.call("_function_items")
	_check(items.size() == 4 and str(items[0]["text"]) == "ƒ " + name and items[3]["text"] == "+ Function", "the ring's Functions: a call of each, + Pure function, + Function")
	_service.call("_create_from_menu", false, canvas.to_global(Vector3(0.3, 0.0, 0.0)))
	await _frames()
	_check(blueprint.root.functions.size() == 3 and not blueprint.opened.is_empty() and XREBlueprintUserFunctions.count_calls(blueprint.root, blueprint.opened) == 1,
			"+ Function from the ring adds its call where the ring was and shows its body")
