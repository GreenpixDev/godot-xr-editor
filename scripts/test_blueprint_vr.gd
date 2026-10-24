@tool
extends Node
## Real-editor regression of spatial input, source persistence and scene assignment history.

var _document: XREDocument
var _service: XREBlueprints
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
var _saved_display := XREFeatureSettings.BILLBOARD
## The same for the port display and the window shape (D-043).
var _saved_ports := XREFeatureSettings.FLAT
var _saved_shape := XREFeatureSettings.FLAT
## The same for the parameter settings (D-052), which a headset session leaves as it set them.
var _saved_parameters: Dictionary[StringName, StringName] = {}
const PARAMETER_SETTINGS: Array[StringName] = [XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ANIMATION_WAIT,
		XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.TOKEN_TRAY, XREFeatureSettings.SCENE_CREATE, XREFeatureSettings.CARD_PLUS, XREFeatureSettings.WIRE_BENDS]


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


func _run() -> void:
	for frame: int in 600:
		await get_tree().process_frame
		if _document.get_scene_root() != null and not EditorInterface.get_resource_filesystem().is_scanning(): break
	var scene := _document.get_scene_root()
	_check(scene != null, "editor scene is available")
	if scene == null:
		get_tree().quit(1)
		return
	# The editor's saved variant is put back at the end; the checks expect the default billboards.
	_saved_display = _document.features.get_value(XREFeatureSettings.NODE_DISPLAY)
	_document.features.set_value(XREFeatureSettings.NODE_DISPLAY, XREFeatureSettings.BILLBOARD)
	_saved_ports = _document.features.get_value(XREFeatureSettings.PORT_DISPLAY)
	_document.features.set_value(XREFeatureSettings.PORT_DISPLAY, XREFeatureSettings.FLAT)
	_saved_shape = _document.features.get_value(XREFeatureSettings.WINDOW_SHAPE)
	_document.features.set_value(XREFeatureSettings.WINDOW_SHAPE, XREFeatureSettings.FLAT)
	for key: StringName in PARAMETER_SETTINGS:
		_saved_parameters[key] = _document.features.get_value(key)
		_document.features.set_value(key, XREFeatureSettings.get_default(key))
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
	_rig.add_child(XREManipulator.new(_document, _rig, icons))
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
	await _test_window_corners()
	var toolbar := _service.get("_toolbar") as XREPanelSurface
	var toolbar_point := toolbar.pixel_to_global(Vector2(12, 144))
	_aim(toolbar_point)
	_left.set_pose(&"aim", Transform3D(Basis.IDENTITY, toolbar_point + Vector3.BACK * 0.4), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(toolbar.is_pressed(), "one hand owns the panel mouse while pressed")
	_left.set_pose(&"aim", Transform3D(Basis.IDENTITY, Vector3(-5, 0, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_check(toolbar.is_pressed(), "idle second hand leaving does not release the owner's button")
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(not toolbar.is_pressed(), "owner releases its own panel mouse")
	await _test_surface_occlusion(toolbar)
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
	_right.set_input(&"ax_button", true)
	await _frames()
	_right.set_input(&"ax_button", false)
	await _frames()
	_check(_service.blueprint.graph.find_node(branch_id).is_empty(), "A deletes the selected graph block")
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
	await _test_parameters_in_graph()
	await _test_token_input()
	await _test_target_modes()
	await _test_widgets_and_wires()
	await _test_vector_widget()
	await _test_links_and_focus()
	await _test_number_inputs()
	await _test_d063()
	await _test_wire_bends()
	_check(_service.blueprint.operation_source == &"desktop_graph", "VR command source scope is restored")
	_service.parameters.call("_set_parameter", print_id, "value", "VR test")
	await _frames()
	_check(_service.blueprint.graph.find_node(print_id)["params"]["value"] == "VR test", "existing typed parameter UI edits shared model")
	var workspace := _service.get("_workspace") as Node3D
	var pinned_pose := workspace.global_transform
	var pinned_center := _service.canvas.get_graph_center()
	var pinned_cards: Dictionary[int, Vector3] = {}
	for card: XREBlueprintCanvas.Card in _service.canvas.get("_cards") as Array: pinned_cards[card.id] = card.node.global_position
	_service.close_graph()
	_check(not _service.is_open(), "Back to scene closes only spatial view")
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
	_document.features.set_value(XREFeatureSettings.NODE_DISPLAY, _saved_display)
	_document.features.set_value(XREFeatureSettings.PORT_DISPLAY, _saved_ports)
	_document.features.set_value(XREFeatureSettings.WINDOW_SHAPE, _saved_shape)
	for key: StringName in PARAMETER_SETTINGS: _document.features.set_value(key, _saved_parameters[key])
	print("test_blueprint_vr: %d of %d checks failed" % [_failures, _checks])
	get_tree().quit(1 if _failures > 0 else 0)


func _record(operation: StringName, _source: XREDocument.Source, _nodes: Array[Node], _time_usec: int) -> void:
	_operations.append(operation)


## Switching the node display (D-039) redraws the open graph at once, and back.
func _test_node_display() -> void:
	var key := XREFeatureSettings.NODE_DISPLAY
	var count := (_service.canvas.get("_cards") as Array).size()
	_check(_document.set_feature(key, XREFeatureSettings.CUBOID, XREDocument.Source.PANEL), "the node display switches to cuboids")
	_check(_operations.back() == &"set_feature", "the switch enters common telemetry")
	await _frames()
	var cards := _service.canvas.get("_cards") as Array
	_check(_service.canvas.get_display() == XREFeatureSettings.CUBOID and cards.size() == count, "the open graph is redrawn with the same cards")
	_check((cards[0] as XREBlueprintCanvas.Card).mesh.mesh is BoxMesh, "open cards become cuboids")
	_check((cards[0] as XREBlueprintCanvas.Card).node.basis.is_equal_approx(Basis.IDENTITY), "cuboids keep the graph's orientation in the headset")
	_check(_document.set_feature(key, XREFeatureSettings.BILLBOARD, XREDocument.Source.PANEL), "the node display switches back")
	await _frames()
	cards = _service.canvas.get("_cards") as Array
	_check((cards[0] as XREBlueprintCanvas.Card).mesh.mesh is QuadMesh, "open cards are billboards again")


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
## corner moves that window; trigger on the toolbar's moves them all. The
## parameters and the block palette are the panels' windows since D-044.
func _test_window_corners() -> void:
	var floating := _service.get("_floating_ui") as Node3D
	var toolbar := _service.get("_toolbar") as XREPanelSurface
	var panel := _service.get("_keyboard") as XREVirtualKeyboard
	var pointer := (_service.get("_pointers") as Array)[0] as XREBlueprints.Pointer
	var floating_before := floating.global_transform
	var history := _service.blueprint.history.get_version()
	for window: XREPanelSurface in [toolbar, panel]:
		_check(window.has_corner_handles(), "graph window %s has corner handles" % window.name)
	_check(not (_service.get("_badge") as XREPanelSurface).has_corner_handles(), "the object's badge, object-locked, has none")
	panel.open_text("corner")
	var panel_before := panel.transform

	_aim_corner(panel, XREPanelSurface.Corner.BOTTOM_RIGHT, 0, 0)
	await _frames()
	_check(panel.handle_lit(XREPanelSurface.Corner.BOTTOM_RIGHT), "the ray lights the keyboard's corner handle")
	_check(not toolbar.handle_shown(XREPanelSurface.Corner.TOP_LEFT), "another window's handles stay hidden")
	_right.set_input(&"grip", 1.0)
	await _frames()
	_check(pointer.held == panel and pointer.window == panel, "grip on a corner handle takes the keyboard")
	var start := panel.global_position
	var hand := _rig.right_hand.global_transform
	_right.set_pose(&"aim", _rig.global_transform.affine_inverse() * hand.translated(Vector3(0.1, 0.05, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_check(panel.global_position.distance_to(start + Vector3(0.1, 0.05, 0)) < 0.001, "the window follows the hand by its corner")
	_check(panel.global_basis.is_equal_approx(floating_before.basis * panel_before.basis), "and keeps its tilt")
	_check(toolbar.global_transform.is_equal_approx(floating_before * toolbar.transform), "the keyboard moves alone")
	_right.set_input(&"grip", 0.0)
	await _frames()
	_check(pointer.held == null, "letting go of the grip leaves the window")
	panel.transform = panel_before

	_aim_corner(toolbar, XREPanelSurface.Corner.TOP_LEFT, 0, 0)
	await _frames()
	_check(toolbar.handle_lit(XREPanelSurface.Corner.TOP_LEFT), "the ray lights the toolbar's corner handle")
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_check(pointer.held == floating and pointer.window == toolbar, "trigger on the toolbar's corner takes the graph's windows")
	_check(not toolbar.is_pressed(), "without clicking the toolbar")
	hand = _rig.right_hand.global_transform
	_right.set_pose(&"aim", _rig.global_transform.affine_inverse() * hand.translated(Vector3(-0.1, 0, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_check(floating.global_position.distance_to(floating_before.origin + Vector3(-0.1, 0, 0)) < 0.001, "the graph's windows move together by the toolbar's corner")
	_check(panel.transform.is_equal_approx(panel_before), "keeping their places in the group")
	_check(toolbar.handle_lit(XREPanelSurface.Corner.TOP_LEFT), "the handle stays lit while it is held")
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check(pointer.held == null, "letting go of the trigger leaves the windows")
	_check(_service.blueprint.history.get_version() == history, "moving windows is not a graph edit")
	floating.global_transform = floating_before
	_aim(Vector3(5, 4, -2))
	await _frames()
	_check(not toolbar.handle_shown(XREPanelSurface.Corner.TOP_LEFT), "handles hide when the ray leaves")
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

	var toolbar := _service.get("_toolbar") as XREPanelSurface
	_check(_document.set_feature(XREFeatureSettings.WINDOW_SHAPE, XREFeatureSettings.CONCAVE, XREDocument.Source.PANEL), "windows switch to concave")
	_check(toolbar.curve_radius > 0.0 and (_service.get("_keyboard") as XREPanelSurface).curve_radius > 0.0 and not (_service.get("_badge") as XREPanelSurface).curve_radius > 0.0,
			"the graph's windows bend, the object's badge doesn't")
	var pixel := Vector2(60, 40)
	var point := toolbar.pixel_to_global(pixel)
	_check(toolbar.to_local(point).z > 0.05, "a concave window's edge comes towards the user")
	var normal := toolbar.global_basis.z.normalized()
	_check(toolbar.intersect_ray(point + normal * 0.3, -normal, 1.0) >= 0 and toolbar.get_hit_pixel().distance_to(pixel) < 0.5,
			"the ray hits the pixel drawn there: %s" % toolbar.get_hit_pixel())
	_check(_document.set_feature(XREFeatureSettings.WINDOW_SHAPE, XREFeatureSettings.FLAT, XREDocument.Source.PANEL) and toolbar.curve_radius == 0.0,
			"and flat again")


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


func _test_surface_occlusion(toolbar: XREPanelSurface) -> void:
	var before := _service.canvas.get_block_position(1)
	var center := toolbar.pixel_to_global(toolbar.size_px * 0.5) + toolbar.global_basis.z * 0.05
	_service.canvas.preview_move(1, _service.canvas.to_local(center))
	_aim(center)
	await _frames()
	var ray := _rig.right_hand.get("_ray") as MeshInstance3D
	_check(ray.scale.z < 0.43, "front card stops the pointer before a panel behind it: %.3f m" % ray.scale.z)
	await _click(center)
	_check(_service.get("_selected") == 1, "trigger reaches the card instead of the covered panel")
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
	var badge := _service.get("_badge") as XREPanelSurface
	var first := badge.global_position
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


## D-052: parameters as objects of the graph, each setting and its variants.
func _test_parameters_in_graph() -> void:
	var features := _document.features
	var keys: Array[StringName] = [XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ANIMATION_WAIT,
			XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.TOKEN_TRAY, XREFeatureSettings.SCENE_CREATE]
	var saved: Dictionary[StringName, StringName] = {}
	for key: StringName in keys:
		saved[key] = features.get_value(key)
		features.set_value(key, XREFeatureSettings.get_default(key))
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
	_right.set_input(&"ax_button", true)
	await _frames()
	_right.set_input(&"ax_button", false)
	await _frames()
	_check(not graph.find_node(delay).is_empty() and is_equal_approx(float((graph.find_node(delay)["params"] as Dictionary).get("seconds", -1.0)), 1.0), "A on a token gives back the default token and keeps its block")
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
	var shelf := _service.canvas.get_shelf()
	_check(shelf.visible and shelf.has_box("door_open") and shelf.has_box("count"), "the variables are boxes on the shelf")
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
## dial, the ring of hues and the arrows of a vector at the token, scrolled
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
	_check(editor.mode == XREBlueprintTokenEditor.RING, "a click on a color token opens the ring of hues around it")
	var hue_point := editor.global_transform * (Vector3(cos(TAU / 3.0), sin(TAU / 3.0), 0.0) * XREBlueprintTokenEditor.RING_RADIUS)
	await _click_from(hue_point, editor.global_basis.z.normalized())
	var color := graph.find_node(equal)["params"]["a"] as Color
	_check(absf(color.h - 1.0 / 3.0) < 0.05, "the ray picks a hue on the ring: %s" % color)
	await _click(Vector3(5, 4, -2))
	_check(not editor.is_open(), "the trigger elsewhere closes the ring")
	await _click_from(_service.canvas.token_transform(equal, "b").origin, front)
	_check(editor.mode == XREBlueprintTokenEditor.ARROWS, "a click on a vector token opens its arrows")
	var arrow := editor.global_position + editor.axis_direction(0) * float((editor.get("_lengths") as Array)[0]) * 0.6
	_aim_from(arrow, Vector3.BACK)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_aim_from(arrow + editor.axis_direction(0) * 0.1, Vector3.BACK)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	var vector := _edited() as Vector3
	_check(is_equal_approx(vector.x, 3.5) and is_equal_approx(vector.y, 2.0), "pulling X 10 cm at the scale of (1, 2, 3) adds 2.5 to X only: %s" % vector)
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
	var box_token := _service.canvas.get_shelf().token_transform("lit").origin
	_aim_from(box_token, Vector3.BACK)
	await _frames()
	_right.set_input(&"grip", 1.0)
	await _frames()
	_aim(Vector3(5, 4, -2))
	await _frames()
	_right.set_input(&"grip", 0.0)
	await _frames()
	_check(not graph.find_variable("lit").has("value") and XREBlueprintGraph.variable_type(graph.find_variable("lit")) == TYPE_BOOL, "a box's token is taken out, not copied: the box is empty, its type kept")
	_service.blueprint.undo()
	await _frames()
	_service.call("_wire_box_to_port", "pause", equal, 0)
	await _frames()
	var reader: Dictionary = graph.nodes.back()
	_check(reader["kind"] == "get_variable" and reader["params"]["variable"] == "pause" and graph.edges.has({"from": reader["id"], "from_port": 0, "to": equal, "to_port": 0}), "a wire between a box and an input adds the box's Get Variable wired to it")
	await _frames()
	var shelf := _service.canvas.get_shelf()
	shelf.hover(0, XREBlueprintShelf.TRASH, true)
	shelf.hover(-1, -1, false)
	var trash := ((shelf.get("_boxes") as Array)[0] as XREBlueprintShelf.Box).trash
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
	_check(XREFeatureSettings.get_values(XREFeatureSettings.TARGET_INPUT) == [XREFeatureSettings.WINDOW, XREFeatureSettings.ON_NODE, XREFeatureSettings.SCENE, XREFeatureSettings.ADAPTER], "Targets: Window, Node, Scene and Adapter")
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
	_check(XREFeatureSettings.get_values(XREFeatureSettings.CARD_PLUS) == [XREFeatureSettings.SHOWN, XREFeatureSettings.HIDDEN], "Plus on cards: Shown, Hidden")
	_check(not _card(delay).plus_faces.is_empty(), "by default a card has its plus")
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
	var lengths := editor.get("_lengths") as Array
	var axes := editor.get("_axes") as Array
	_check(is_equal_approx(float(lengths[0]), 0.06) and is_equal_approx(float(lengths[1]), 0.06) and is_equal_approx(float(lengths[3]), Vector2(0.06, 0.06).length()), "the arrows are drawn to one scale, the white one their sum")

	# An axis pulled: the white arrow goes with it.
	var on_y := editor.global_position + editor.axis_direction(1) * 0.03
	_aim_from(on_y, face)
	await _frames()
	_check((editor.get("_arrows")[1] as Node3D).scale.x > 1.1, "the arrow under the ray is lit")
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_aim_from(on_y + editor.axis_direction(1) * 0.06, face)
	await _frames()
	_check(is_equal_approx(float(lengths[1]), 0.12) and (axes[3] as Vector3).is_equal_approx((editor.axis_direction(0) * 0.06 + editor.axis_direction(1) * 0.12).normalized()) and is_equal_approx(float(lengths[3]), Vector2(0.06, 0.12).length()), "pulled, Y is longer and the white arrow follows it")
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
	_aim_from(tip + editor.axis_direction(0) * 0.024, face)
	await _frames()
	_check(is_equal_approx(float(lengths[0]), 0.084) and is_equal_approx(float(lengths[1]), 0.12), "moved, the white arrow takes the axis arrows with it")
	_right.set_input(&"trigger", 0.0)
	await _frames(4)
	value = _edited()
	_check(value is Vector3 and (value as Vector3).is_equal_approx(Vector3(0.7, 1.0, 0.0)), "the white arrow moved 2.4 cm adds 0.2 to X: %s" % value)

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
	var from_box := (inline_wires[0] as XREBlueprintCanvas.Wire).mesh.get_point(0) - _service.canvas.get_shelf().box_point("speed") if inline_wires.size() == 1 else Vector3.INF
	var half := XREBlueprintShelf.BOX_SIZE * 0.5 + Vector3.ONE * 0.0005
	var to_port := _service.canvas.port_position(delay, seconds_port, true) - _service.canvas.get_shelf().box_point("speed")
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
		_check(absf(keypad.global_position.distance_to(head) - window.global_position.distance_to(head)) < 0.25 and keypad.global_position.y < window.global_position.y, "below the window, about as far as it")
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


## Presses the delete button (A) with the right ray at the wire's point [param point].
func _delete_at_wire(point: Vector3) -> void:
	_aim_at_wire(point)
	await _frames()
	_right.set_input(&"ax_button", true)
	await _frames()
	_right.set_input(&"ax_button", false)
	await _frames()


## D-064: wires bend while Wire bends is on, as edges in draw.io — trigger or
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
	_check(features.get_value(XREFeatureSettings.WIRE_BENDS) == XREFeatureSettings.OFF and not canvas.get_bends_shown(), "Wire bends is off by default")
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
	_check(target_wire != null and target_wire.link != null and target_wire.mesh == target_wire.link.mesh, "the Target wire to the object is a link of the canvas")
	if target_wire != null:
		var key := target_wire.link.edge
		var on_link := target_wire.link.pieces[0].get_point(XREGraphWire.SAMPLES / 2)
		_aim_at_wire(on_link)
		await _frames()
		_check(canvas.is_edge_lit(key) and canvas.is_ghost_shown(true), "the ray on a Target wire marks a bend: lit %s, ghost %s" % [canvas.is_edge_lit(key), canvas.is_ghost_shown(true)])
		_check(target_wire.mesh.material_override == target_wire.lit_material, "and thickens the wire")
		version = _service.blueprint.history.get_version()
		await _drag_wire(on_link, up * 0.1)
		var kept: Variant = graph.find_node(setter).get(XREBlueprintGraph.SCENE_BENDS)
		_check(_service.blueprint.history.get_version() == version + 1 and kept is PackedVector3Array and (kept as PackedVector3Array).size() == 1, "dragged, it keeps its bend on its block, in one edit")
		target_wire = _target_wire(setter)
		_check(target_wire != null and target_wire.link.knots.size() == 1, "the Target wire bends there")
		_service.blueprint.undo()
		await _frames()
		target_wire = _target_wire(setter)
		_check(not graph.find_node(setter).has(XREBlueprintGraph.SCENE_BENDS) and target_wire != null and target_wire.link.knots.is_empty(), "undo straightens it")

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


## Clicks the right trigger at [param point], from [param front].
func _click_from(point: Vector3, front: Vector3) -> void:
	_aim_from(point, front)
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
