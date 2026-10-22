@tool
extends Node
## Screenshots of the spatial graph as the headset shows it, for looking at by
## eye: a windowed editor (not headless, no XR) with fake controllers opens the
## graph of the selected object and saves views from the head to
## build/shots/. The plugin runs it with `-- --xre-shot-blueprint-vr`; it keeps
## the editor's saved feature settings, so the shots show what the user sees.
## The graph is the user's own: every edit the clicks make is undone before
## the editor quits, since the graph saves its draft on the way out.

const SIZE := Vector2i(1600, 1200)
const FOLDER := "res://build/shots"

var _document: XREDocument
var _service: XREBlueprints
var _rig: XRERig
var _viewport: SubViewport
var _right: XRControllerTracker
var _left: XRControllerTracker


func _init(document: XREDocument) -> void:
	_document = document


func _ready() -> void:
	_run.call_deferred()


func _frames(count: int = 3) -> void:
	for frame: int in count: await get_tree().process_frame


func _shot(name: String) -> void:
	await _frames(6)
	await RenderingServer.frame_post_draw
	var image := _viewport.get_texture().get_image()
	image.save_png(FOLDER + "/" + name + ".png")
	print("shot_blueprint_vr: ", ProjectSettings.globalize_path(FOLDER + "/" + name + ".png"))


## Points the right hand's ray at [param point] from [param front] of it.
func _aim(point: Vector3, front: Vector3) -> void:
	_right.set_pose(&"aim", Transform3D(Basis.looking_at(-front), point + front * 0.4), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)


## Puts the head at [param from], looking at [param at].
func _look(from: Vector3, at: Vector3) -> void:
	_rig.camera.global_transform = Transform3D(Basis.looking_at(at - from, Vector3.UP), from)


func _run() -> void:
	for frame: int in 600:
		await get_tree().process_frame
		if _document.get_scene_root() != null and not EditorInterface.get_resource_filesystem().is_scanning(): break
	var scene := _document.get_scene_root() as Node3D
	if scene == null:
		printerr("shot_blueprint_vr: no scene")
		get_tree().quit(1)
		return
	DirAccess.make_dir_recursive_absolute(FOLDER)
	for key: StringName in XREFeatureSettings.DEFINITIONS:
		print("shot_blueprint_vr: setting %s = %s" % [key, _document.features.get_value(key)])
	_right = XRControllerTracker.new()
	_right.name = &"right_hand"
	_right.type = XRServer.TRACKER_CONTROLLER
	_left = XRControllerTracker.new()
	_left.name = &"left_hand"
	_left.type = XRServer.TRACKER_CONTROLLER
	XRServer.add_tracker(_right)
	XRServer.add_tracker(_left)
	for tracker: XRControllerTracker in [_left, _right]:
		tracker.set_pose(&"aim", Transform3D(Basis.IDENTITY, Vector3(-50, 0, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_rig = XRERig.new()
	_viewport = SubViewport.new()
	_viewport.size = SIZE
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.world_3d = scene.get_world_3d()
	_viewport.msaa_3d = Viewport.MSAA_4X
	_viewport.add_child(_rig)
	add_child(_viewport)
	_rig.camera.current = true
	_rig.camera.fov = 90.0
	var icons := XREIcons.new(_document, _rig)
	_rig.add_child(icons)
	var palette := XREPalette.new(_document, _rig)
	_rig.add_child(palette)
	var panels := XREPanels.new(_document, _rig, palette, EditorInterface.get_editor_theme(), 1.0)
	_rig.add_child(panels)
	_service = XREBlueprints.new(_document, _rig, icons, EditorInterface.get_editor_theme())
	_rig.add_child(_service)
	panels.set_blueprints(_service)
	var host := scene.get_node_or_null(^"GreenCube") as Node3D
	if host == null:
		printerr("shot_blueprint_vr: no GreenCube")
		get_tree().quit(1)
		return
	# Standing about where the user stood: a step back from the table, eyes at 1.6 m.
	var head := Vector3(host.global_position.x - 0.1, 1.6, host.global_position.z + 1.1)
	_look(head, host.global_position)
	_document.select([host], XREDocument.Source.TOOL)
	await _frames()
	_service.open_selected()
	await _frames(10)
	var start := _service.blueprint.history.get_version()
	_look(head, host.global_position)
	await _shot("01_overview")
	var cards := _service.canvas.get("_cards") as Array
	for card: XREBlueprintCanvas.Card in cards:
		var face := card.node.global_transform
		_look(face.origin + face.basis.z.normalized() * 0.35, face.origin)
		await _shot("02_card_%d" % card.id)
	_look(head, host.global_position)
	await _shot("03_objects")
	_look(head.lerp(host.global_position, 0.6), host.global_position)
	await _shot("04_objects_close")
	_service.call("_open_petals", 1, host, host.global_position)
	_look(head, host.global_position)
	await _shot("05_petals")
	_look(head.lerp(host.global_position, 0.5), host.global_position + Vector3(0.1, 0.1, 0))
	await _shot("06_petals_close")
	(_service.get("_petals") as XREBlueprintPetals).close()
	_document.select([], XREDocument.Source.TOOL)
	await _frames()
	_look(head, host.global_position)
	await _shot("07_member_petals")
	_look(head + Vector3(0.5, 0, 0), host.global_position)
	await _shot("08_member_petals_side")
	# A click on Rotate X's connected In port, then the ray off to the side.
	var front := (cards[1] as XREBlueprintCanvas.Card).node.global_basis.z.normalized()
	var port := _service.canvas.to_global(_service.canvas.port_position(2, 0, true))
	_aim(port, front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_aim(port + Vector3(0.0, -0.25, 0.1), front)
	_look(port + front * 0.6 + Vector3(0, 0.1, 0), port)
	await _shot("09_port_click")
	_service.cancel_connection()
	await _frames()
	# A click on the Angle token: the keyboard.
	var token := _service.canvas.token_transform(2, "angle").origin
	_aim(token, front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames(2)
	_right.set_input(&"trigger", 0.0)
	await _frames(6)
	_aim(Vector3(-50, 0, 0), front)
	_look(token + front * 0.6 + Vector3(0, 0.1, 0), token)
	await _shot("10_keyboard")
	_look(head, token)
	await _shot("11_keyboard_far")
	(_service.get("_keyboard") as XREVirtualKeyboard).close()
	# The Vector window of a vector token, the rest dimmed (D-061).
	var editor := _service.get("_token_editor") as XREBlueprintTokenEditor
	var vector_block := -1
	for block: Dictionary in _service.blueprint.graph.nodes:
		if (block["params"] as Dictionary).get("value") is Vector3: vector_block = block["id"]
	if vector_block >= 0:
		_look(head, host.global_position)
		await _frames()
		_service.call("_open_vector", vector_block, "value", "", Vector3(1, 0.5, 0))
		await _frames(4)
		var vector_window := panels.find_window(XREBlueprintVectorTab)
		if vector_window != null:
			var at := vector_window.global_position
			_look(at + vector_window.global_basis.z * 0.75 + Vector3(0.1, 0.1, 0), at)
			await _shot("12_vector_window")
			editor.begin_pull(1)
			editor.pull_to(1, 0.1, 0.0)
			await _shot("12b_vector_pulled")
			_look(head, at)
			await _shot("12c_vector_dimmed")
			# The keypad of one axis, below the window (D-063).
			_service.vector_panel.get_component_button(1).pressed.emit()
			await _frames(4)
			_look(head, (_service.get("_keyboard") as Node3D).global_position.lerp(at, 0.5))
			await _shot("12d_vector_axis_keypad")
			(_service.get("_keyboard") as XREVirtualKeyboard).close()
			_service.set("_token_edit", {})
			panels.call("_close_window", vector_window)
			await _frames(3)
	# The number line of a number held by the trigger (D-062).
	var number_pose := Transform3D(XREPanels.facing(token, head, Vector3.UP), token)
	editor.open_dial(number_pose, 1.5)
	editor.line_to(0.05, 0.0)
	_look(token + front * 0.5 + Vector3(0, 0.05, 0), token)
	await _shot("16_number_line")
	editor.close()
	# The block menu: the chips, the row of sections, the search (D-063).
	_service.open_block_menu()
	await _frames(6)
	var menu_window := panels.find_window(XREBlueprintPaletteTab)
	if menu_window != null:
		_look(menu_window.global_position + menu_window.global_basis.z * 0.7, menu_window.global_position)
		await _shot("17_block_menu")
	_service.close_block_palette()
	await _frames(3)
	var tray := panels.find_window(XREBlueprintTokensTab)
	if tray != null:
		_look(tray.global_position + tray.global_basis.z * 0.6, tray.global_position)
		await _shot("13_tray")
	# Targets as adapters, then the user's setting back.
	var targets := _document.features.get_value(XREFeatureSettings.TARGET_INPUT)
	_document.features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ADAPTER)
	await _frames(6)
	_look(head, host.global_position)
	await _shot("14_adapters")
	for card: XREBlueprintCanvas.Card in _service.canvas.get("_cards") as Array:
		var frame := card.node.global_transform
		_look(frame.origin + frame.basis.z.normalized() * 0.4 - frame.basis.x.normalized() * 0.1, frame.origin)
		await _shot("15_adapter_card_%d" % card.id)
	_document.features.set_value(XREFeatureSettings.TARGET_INPUT, targets)
	print("shot_blueprint_vr: dimmer shown ", (_service.get("_dimmer") as Node3D).is_visible_in_tree())
	_service.cancel_connection()
	_service.close_block_palette()
	while _service.blueprint.history.get_version() > start: _service.blueprint.undo()
	await _frames()
	print("shot_blueprint_vr: done, graph back to version %d" % _service.blueprint.history.get_version())
	get_tree().quit(0)
