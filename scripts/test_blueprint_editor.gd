@tool
extends Node
## Runs inside the real editor: graph UI, resource activation and scene assignment history.

var _checks := 0
var _failures := 0


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("test_blueprint_editor: FAILED " + message)


## Called by the standalone plugin only with --xre-test-blueprint-editor.
func run(plugin: EditorPlugin, document: XREBlueprintDocument, view: XREBlueprintEditor) -> void:
	for frame: int in 600:
		await get_tree().process_frame
		var opened := EditorInterface.get_edited_scene_root()
		if opened != null and opened.scene_file_path == "res://benchmarks/blueprint_door.tscn" and not EditorInterface.get_resource_filesystem().is_scanning():
			break
	_check(document.open_graph("res://benchmarks/blueprint_door.tres"), "open example graph")
	await get_tree().process_frame
	await get_tree().process_frame
	_check(_block_count(view) == 8, "view displays all example blocks")
	_check(view.canvas.get_connection_list().size() == document.graph.edges.size(), "view displays execution and data wires")
	EditorInterface.set_main_screen_editor("Blueprints")
	_check(view.visible, "main screen tab activates")
	await _test_scene_switch(document, view)
	await _test_target_input(document, view)
	await _test_operator_pins(document, view)
	view.canvas.node_selected.emit(view.canvas.get_node("6"))
	await get_tree().process_frame
	_check((view.canvas.get_node("6") as GraphNode).get_input_port_count() == 3, "property block has execution, value and target inputs")
	# A literal's type picker: values of different types must not be compared.
	var literal_before := document.graph.snapshot()
	for literal: Variant in [Vector2(1, 2), Vector3(1, 2, 3), Color.RED]:
		view.call("_set_parameter", 6, "value", literal)
		var stored: Variant = (document.graph.find_node(6)["params"] as Dictionary).get("value")
		_check(typeof(stored) == typeof(literal) and stored == literal, "the literal switches to %s: %s" % [type_string(typeof(literal)), stored])
	for step: int in 3:
		document.undo()
	_check(document.graph.snapshot() == literal_before, "undo restores the literal")
	await get_tree().process_frame
	view.call("_set_parameter", 6, "value", "changed")
	document.undo()
	await get_tree().process_frame
	var details := view.get("_details") as VBoxContainer
	var seconds_field: LineEdit
	for index: int in details.get_child_count() - 1:
		var label := details.get_child(index) as Label
		if details.get_child(index) is LineEdit:
			var field := details.get_child(index) as LineEdit
			if field.text == "OPEN": seconds_field = field
	_check(seconds_field != null, "undo refreshes parameter fields after a pending edit")
	var before := document.graph.snapshot()
	view.canvas.delete_nodes_request.emit([&"6"] as Array[StringName])
	await get_tree().process_frame
	_check(_block_count(view) == 7, "Delete request changes model and view")
	document.undo()
	await get_tree().process_frame
	_check(document.graph.snapshot() == before and _block_count(view) == 8, "undo restores view and model")
	var block := view.canvas.get_node("6") as GraphNode
	var old_position := block.position_offset
	block.position_offset += Vector2(50, 30)
	view.canvas.end_node_move.emit()
	await get_tree().process_frame
	_check(document.graph.find_node(6)["position"] == old_position + Vector2(50, 30), "drag commits positions")
	document.undo()
	await get_tree().process_frame
	_check(document.graph.find_node(6)["position"] == old_position, "drag is undoable")
	# Keep the fixture untouched on disk. Only this temporary node receives the script.
	var scene := EditorInterface.get_edited_scene_root()
	_check(scene != null, "editor has the requested fixture scene")
	if scene != null:
		_check((document.graph.find_node(1).get("arguments", []) as Array).size() == 1, "signal signature exposes its boolean argument")
		_check(document.graph.find_node(6).get("property_type") == TYPE_STRING, "scene reflection types the text property")
		view.call("_show_picker", 6)
		var picker := view.get("_tree") as Tree
		_check(picker.get_root() != null, "target picker displays the scene tree")
		(view.get("_picker") as ConfirmationDialog).hide()
		var original := document.graph.snapshot()
		var original_path := document.path
		DirAccess.make_dir_recursive_absolute("res://build")
		_check(document.save_graph("res://build/blueprint_editor_assignment.tres"), "assignment fixture has a separate saved graph")
		var target := Node.new()
		target.name = "BlueprintAssignmentTest"
		scene.add_child(target)
		target.owner = scene
		var selection := EditorInterface.get_selection()
		selection.clear()
		selection.add_node(target)
		var attached := document.attach_to_selected(plugin.get_undo_redo())
		_check(attached, "attach generated script to selected node: " + document.last_error)
		_check(target.get_script() != null, "scene node receives script")
		var manager := plugin.get_undo_redo()
		var history := manager.get_history_undo_redo(manager.get_object_history_id(target))
		history.undo()
		_check(target.get_script() == null, "scene history undoes assignment")
		history.redo()
		_check(target.get_script() != null, "scene history redoes assignment")
		history.undo()
		var handwritten := GDScript.new()
		handwritten.source_code = "extends Node\n"
		handwritten.reload()
		target.set_script(handwritten)
		_check(not document.attach_to_selected(manager), "assignment protects existing unrelated script")
		_check(target.get_script() == handwritten, "existing script remains intact")
		selection.clear()
		scene.remove_child(target)
		target.free()
		document.graph.restore(original)
		document.path = original_path
	# Rendered runs also produce a screenshot for visual QA; headless has no pixels.
	if DisplayServer.get_name() != "headless":
		get_tree().root.size = Vector2i(1600, 1000)
		EditorInterface.set_distraction_free_mode(true)
		plugin.hide_bottom_panel()
		view.canvas.zoom = 0.65
		view.canvas.scroll_offset = Vector2.ZERO
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		DirAccess.make_dir_recursive_absolute("res://build/blueprint_tests")
		get_viewport().get_texture().get_image().save_png("res://build/blueprint_tests/editor.png")
		view.canvas.node_selected.emit(view.canvas.get_node("6"))
		var target_field := view.get("_target_field") as LineEdit
		target_field.text = "NoSuchNode"
		target_field.text_changed.emit(target_field.text)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://build/blueprint_tests/editor_missing_target.png")
		target_field.text = "Status"
		target_field.text_changed.emit(target_field.text)
		EditorInterface.set_distraction_free_mode(false)
	print("test_blueprint_editor: %d of %d checks failed" % [_failures, _checks])
	get_tree().quit(1 if _failures > 0 else 0)


## A variadic operator's pins in GraphEdit (D-136): "+ pin" under its inputs
## adds one, × by an input removes it; the graph is left as it was.
func _test_operator_pins(document: XREBlueprintDocument, view: XREBlueprintEditor) -> void:
	var before := document.graph.snapshot()
	var id := document.insert_block(XREBlueprintGraph.make_operator(0, "add", Vector2.ZERO), Vector2(0, 900))
	await get_tree().process_frame
	await get_tree().process_frame
	var node := view.canvas.get_node_or_null(str(id)) as GraphNode
	var add := node.find_child("AddPin", true, false) as Button if node != null else null
	_check(add != null and node.find_child("RemoveA", true, false) == null, "Add of two inputs shows + pin and no ×")
	if add == null: return
	add.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	node = view.canvas.get_node(str(id)) as GraphNode
	_check(node.get_input_port_count() == 3 and XREBlueprintGraph.operand_count(document.graph.find_node(id)) == 3, "+ pin adds input C")
	var remove := node.find_child("RemoveB", true, false) as Button
	_check(remove != null and is_zero_approx(remove.modulate.a), "× by B waits for the mouse")
	if remove != null: remove.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	_check(XREBlueprintGraph.operand_count(document.graph.find_node(id)) == 2, "× removes input B")
	for step: int in 3: document.undo()
	await get_tree().process_frame
	_check(document.graph.snapshot() == before, "three undos leave the graph as it was")


func _block_count(view: XREBlueprintEditor) -> int:
	var count := 0
	for child: Node in view.canvas.get_children():
		if child is GraphNode:
			count += 1
	return count


func _test_scene_switch(document: XREBlueprintDocument, view: XREBlueprintEditor) -> void:
	view.canvas.node_selected.emit(view.canvas.get_node("6"))
	var before := document.graph.snapshot()
	var was_dirty := document.is_dirty()
	var owner := EditorInterface.get_edited_scene_root()
	DirAccess.make_dir_recursive_absolute("res://build/blueprint_tests")
	var other := Node3D.new()
	other.name = "OtherScene"
	var same_name := MeshInstance3D.new()
	same_name.name = "Status"
	other.add_child(same_name)
	same_name.owner = other
	var packed := PackedScene.new()
	packed.pack(other)
	var other_path := "res://build/blueprint_tests/context_other_%d.tscn" % Time.get_ticks_usec()
	_check(ResourceSaver.save(packed, other_path) == OK, "second scene fixture saves")
	other.free()
	EditorInterface.open_scene_from_path(other_path)
	await _wait_scene(other_path)
	await get_tree().process_frame
	var field := view.get("_target_field") as LineEdit
	var hint := view.get("_target_hint") as Label
	_check(not document.scene_context_active(), "real scene tab switch preserves owner")
	_check(not field.has_theme_stylebox_override("normal") and hint.text == "Graph belongs to blueprint_door.tscn", "other scene shows neutral guidance instead of a red Target")
	_check(not field.editable and (view.get("_target_button") as Button).disabled, "other scene cannot edit or pick graph targets")
	_check(document.graph.snapshot() == before and document.is_dirty() == was_dirty, "real tab switch does not rewrite graph or its dirty state")
	_check(not view.validate_active_target(), "building asks for the graph scene without rebinding it")
	if DisplayServer.get_name() != "headless":
		get_tree().root.size = Vector2i(1600, 1000)
		EditorInterface.set_main_screen_editor("Blueprints")
		EditorInterface.set_distraction_free_mode(true)
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://build/blueprint_tests/editor_other_scene.png")
		EditorInterface.set_distraction_free_mode(false)
	_check(document.open_graph_scene(), "Open graph scene activates the saved owner")
	await _wait_scene("res://benchmarks/blueprint_door.tscn")
	await get_tree().process_frame
	field = view.get("_target_field") as LineEdit
	_check(document.scene_context_active() and document.resolve_target("Status") == owner.get_node("Status"), "returning to real owner restores its target identity")
	_check(field.editable and not field.has_theme_stylebox_override("normal"), "returning restores normal target editing")
	_check(document.graph.snapshot() == before, "returning from another tab preserves graph schema")
	EditorInterface.set_main_screen_editor("Blueprints")


func _wait_scene(path: String) -> void:
	for frame: int in 600:
		await get_tree().process_frame
		var scene := EditorInterface.get_edited_scene_root()
		if scene != null and scene.scene_file_path == path: return
	_check(false, "scene did not open: " + path)


func _test_target_input(document: XREBlueprintDocument, view: XREBlueprintEditor) -> void:
	view.canvas.node_selected.emit(view.canvas.get_node("6"))
	var field := view.get("_target_field") as LineEdit
	field.grab_focus()
	field.text = "NoSuchNode"
	field.text_changed.emit(field.text)
	var hint := view.get("_target_hint") as Label
	_check(hint.text == "missing target" and field.tooltip_text == "missing target", "manual missing target shows the exact inline message and tooltip")
	_check(field.has_theme_stylebox_override("normal"), "missing target field has its red background/border")
	_check(not view.validate_active_target(), "invalid target draft blocks Save/Build")
	await get_tree().process_frame
	field = view.get("_target_field") as LineEdit
	field.grab_focus()
	field.text = "Stat"
	field.text_changed.emit(field.text)
	var suggestions := view.get("_target_matches") as ItemList
	_check(suggestions.visible and suggestions.item_count == 1 and suggestions.get_item_text(0) == "Status", "manual prefix offers the suitable scene node")
	var key := InputEventKey.new()
	key.keycode = KEY_DOWN
	key.pressed = true
	view.get_viewport().push_input(key)
	key = InputEventKey.new()
	key.keycode = KEY_ENTER
	key.pressed = true
	view.get_viewport().push_input(key)
	await get_tree().process_frame
	field = view.get("_target_field") as LineEdit
	_check(field.text == "Status" and document.graph.find_node(6)["params"]["target"] == "Status", "Down and Enter complete the path and apply it")
	_check(not field.has_theme_stylebox_override("normal") and field.tooltip_text.is_empty(), "valid target clears the red style and missing message")
	view.canvas.node_selected.emit(view.canvas.get_node("5"))
	field = view.get("_target_field") as LineEdit
	field.text = "Door"
	field.text_changed.emit(field.text)
	_check((view.get("_target_hint") as Label).text == "requires AnimationPlayer", "wrong target type is explained immediately")
	view.call("_show_picker", 5)
	var tree := view.get("_tree") as Tree
	var pending: Array[TreeItem] = [tree.get_root()]
	var wrong_type_disabled := false
	while not pending.is_empty():
		var item: TreeItem = pending.pop_back()
		if item.get_text(0).begins_with("Door "): wrong_type_disabled = not item.is_selectable(0)
		var child := item.get_first_child()
		while child != null:
			pending.append(child)
			child = child.get_next()
	_check(wrong_type_disabled, "scene picker disables incompatible target types")
	(view.get("_picker") as ConfirmationDialog).hide()
	field = view.get("_target_field") as LineEdit
	field.text = "AnimationPlayer"
	field.text_changed.emit(field.text)
	_check(view.validate_active_target(), "correct target can be applied again")
	await get_tree().process_frame
	view.canvas.node_selected.emit(view.canvas.get_node("6"))
