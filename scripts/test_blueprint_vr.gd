@tool
extends Node
## Real-editor regression of spatial input, source persistence and scene assignment history.

var _document: XREDocument
var _service: XREBlueprints
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
	_service = XREBlueprints.new(_document, _rig, icons, EditorInterface.get_editor_theme())
	_service.source_folder = "res://build/blueprint_vr_tests"
	_rig.add_child(_service)
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
	_check(_service.blueprint.graph.edges.is_empty(), "clicking a connected port disconnects its wires")
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
	_right.set_input(&"grip", 0.0)
	await _frames()
	_check(_service.blueprint.history.get_version() == history_version + 1, "grip release commits exactly one graph edit")
	_check(absf(float(_service.blueprint.graph.find_node(print_id).get("vr_depth", 0)) - preview_depth) < 0.001, "previewed ray-constrained depth is persisted")
	_service.blueprint.undo()
	await _frames()
	_check(_service.canvas.get_block_position(print_id).is_equal_approx(before), "undo restores spatial card placement")
	await _test_card_rotation(print_id)
	await _test_depth_pull(print_id)
	await _test_depth_direction(print_id)
	await _test_keyboard()
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
	print("test_blueprint_vr: %d of %d checks failed" % [_failures, _checks])
	get_tree().quit(1 if _failures > 0 else 0)


func _record(operation: StringName, _source: XREDocument.Source, _nodes: Array[Node], _time_usec: int) -> void:
	_operations.append(operation)


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
	_check((_service.get("_block_palette") as XREPanelSurface).is_shown(), "trigger on plus opens a block palette")
	(_service.get("_block_palette") as XREPanelSurface).set_shown(false)
	_rig.camera.position = Vector3(0, 0, -2)
	await _frames()
	_check(card.node.global_basis.z.dot(Vector3.FORWARD) > 0.99, "walking behind the graph turns each flat card towards the head")
	var plus := card.node.to_global(card.plus_point)
	_right.set_pose(&"aim", Transform3D(Basis(Vector3.UP, PI), plus + Vector3.FORWARD * 0.4), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_check((_service.get("_block_palette") as XREPanelSurface).is_shown(), "automatically facing plus opens the palette from the user's new side")
	(_service.get("_block_palette") as XREPanelSurface).set_shown(false)
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
	facing.y = 0.0
	_check((_service.canvas.global_basis * preview.basis.z).dot(facing.normalized()) > 0.999 and (_service.canvas.global_basis * preview.basis.y).is_equal_approx(Vector3.UP), "touch grab stays upright and faces the user despite controller roll")
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
	var torso := _rig.camera.global_position + XREManipulator.TORSO_OFFSET
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
		var expected := XREManipulator.moved_pivot(contact, hand_start, hand_pulled, XREManipulator.homer_gain(torso, hand_start, contact))
		_check(endpoint.is_equal_approx(expected), "straight depth pull matches the scene-object HOMER displacement")
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
		_check(_service.canvas.get_block_transform(id).is_equal_approx(pose), "tracking loss cancels both depth and pose preview")
		_right.set_input(&"grip", 0.0)
	_service.canvas.preview_transform(id, original)
	_check(_service.blueprint.history.get_version() == history, "depth previews never add history before release")
	_aim(Vector3(5, 4, -2))
	await _frames()


func _set_grip_and_aim(grip: Transform3D) -> void:
	_right.set_pose(&"grip", grip, Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_right.set_pose(&"aim", Transform3D(grip.basis, grip * Vector3(0, 0, -0.12)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)


func _test_depth_direction(id: int) -> void:
	var original := _service.canvas.get_block_transform(id)
	var version := _service.blueprint.history.get_version()
	var torso := _rig.camera.global_position + XREManipulator.TORSO_OFFSET
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
	for side: float in [-0.8, 0.8, -0.4, 0.4, 0.0]:
		var turn := Basis(Vector3.UP, side)
		_set_grip_and_aim(Transform3D(turn, torso + turn * offset))
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
	var contact := _service.canvas.to_global(_service.canvas.get_block_transform(id) * pointer.grab_point)
	var pulling := torso + Basis(Vector3.UP, 0.6) * offset * 0.85
	_set_grip_and_aim(Transform3D(Basis.IDENTITY, pulling))
	await _frames()
	_check(pointer.distance < initial, "reducing arm reach during a sideways swing shortens the rod")
	var endpoint := _service.canvas.to_global(_service.canvas.get_block_transform(id) * pointer.grab_point)
	_check(endpoint.z > contact.z, "combined lateral/pull motion brings the card forward rather than sending it away")
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
	_check(is_equal_approx(ray.scale.z, 0.4 - XREBlueprintCanvas.CARD_THICKNESS * 0.5), "front card stops the pointer before a panel behind it")
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
