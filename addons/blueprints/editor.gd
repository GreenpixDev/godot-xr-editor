@tool
class_name XREBlueprintEditor
extends VBoxContainer
## Desktop view of a Blueprint document. Contains no scene mutation logic.

signal new_requested
signal open_requested
signal save_requested
signal build_requested
signal attach_requested
signal focus_requested
signal graph_scene_requested
## Compact views can supply headset text input without depending on XR classes.
signal text_edit_requested(field: LineEdit)

const PORT_COLORS: Array[Color] = [Color("eeeeee"), Color("63c6ea"), Color("e8879b"), Color("7be5b3"), Color("7be5b3"), Color("e5b57b"), Color("89adff"), Color("89adff"), Color("b991eb"), Color("f2d878")]

var document: XREBlueprintDocument
## Input origin of this view. The compact XR inspector uses vr_panel.
var operation_source: StringName = &"desktop_graph"
var _parameters_only := false
var canvas: GraphEdit
var _details: VBoxContainer
var _source: CodeEdit
var _status: Label
var _filename: Label
var _palette: ItemList
var _search: LineEdit
var _selected_id := -1
var _pending_refresh := false
var _rebuilding := false
var _keep_details := false
var _details_state: Dictionary = {}
var _details_key: Array = []
var _undo_button: Button
var _redo_button: Button
var _host_label: Label
var _picker: ConfirmationDialog
var _tree: Tree
var _pick_id := -1
var _variables_dialog: AcceptDialog
var _target_field: LineEdit
var _target_hint: Label
var _target_matches: ItemList
var _target_id := -1
var _target_dirty := false
var _target_document_path := ""
var _scene_notice: HBoxContainer
var _scene_message: Label
var _scene_button: Button
var _target_button: Button
var _context_was_active := true


## Builds the view once; the document may load different graphs afterwards.
func setup(value: XREBlueprintDocument, parameters_only: bool = false) -> void:
	document = value
	_parameters_only = parameters_only
	auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var toolbar := HBoxContainer.new()
	add_child(toolbar)
	_button(toolbar, "New", new_requested.emit)
	_button(toolbar, "Open…", open_requested.emit)
	_button(toolbar, "Save", save_requested.emit)
	_button(toolbar, "Build .gd", build_requested.emit)
	_button(toolbar, "Attach to selected", attach_requested.emit).tooltip_text = "Save/build and assign to the selected scene node. Existing unrelated scripts are protected."
	_undo_button = _button(toolbar, "Undo", func() -> void: document.perform(document.undo, operation_source))
	_redo_button = _button(toolbar, "Redo", func() -> void: document.perform(document.redo, operation_source))
	_button(toolbar, "Variables…", _show_variables)
	_button(toolbar, "Script host…", func() -> void: _show_picker(-1))
	_filename = Label.new()
	_filename.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_filename.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	toolbar.add_child(_filename)
	_scene_notice = HBoxContainer.new()
	add_child(_scene_notice)
	_scene_message = _label(_scene_notice, "")
	_scene_message.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scene_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_scene_button = _button(_scene_notice, "Open graph scene", graph_scene_requested.emit)
	var body := HSplitContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(body)
	var library := VBoxContainer.new()
	library.custom_minimum_size.x = 175
	body.add_child(library)
	_label(library, "BLOCKS")
	_search = LineEdit.new()
	_search.placeholder_text = "Search blocks…"
	library.add_child(_search)
	_search.text_changed.connect(func(_text: String) -> void: _fill_palette())
	_palette = ItemList.new()
	_palette.size_flags_vertical = Control.SIZE_EXPAND_FILL
	library.add_child(_palette)
	_palette.item_activated.connect(_add_block)
	_button(library, "Add selected block", func() -> void:
		var items := _palette.get_selected_items()
		if not items.is_empty():
			_add_block(items[0]))
	var main := HSplitContainer.new()
	main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(main)
	var tabs := TabContainer.new()
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main.add_child(tabs)
	canvas = GraphEdit.new()
	canvas.name = "Graph"
	canvas.right_disconnects = true
	for type: int in range(2, PORT_COLORS.size()):
		canvas.add_valid_connection_type(type, XREBlueprintGraph.VALUE)
	canvas.add_valid_connection_type(XREBlueprintGraph.INTEGER, XREBlueprintGraph.NUMBER)
	canvas.show_arrange_button = false
	tabs.add_child(canvas)
	canvas.connection_request.connect(_connect_blocks)
	canvas.disconnection_request.connect(_disconnect_blocks)
	canvas.delete_nodes_request.connect(_delete_blocks)
	canvas.node_selected.connect(_select_block)
	canvas.end_node_move.connect(_move_blocks)
	_source = CodeEdit.new()
	_source.name = "Generated GDScript"
	_source.editable = false
	_source.gutters_draw_line_numbers = true
	tabs.add_child(_source)
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size.x = 260
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main.add_child(scroll)
	_details = VBoxContainer.new()
	_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_details)
	var status_bar := HBoxContainer.new()
	add_child(status_bar)
	_status = Label.new()
	_status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_bar.add_child(_status)
	var focus_button := _button(status_bar, "Focus graph", focus_requested.emit)
	focus_button.tooltip_text = "Toggle the editor's distraction-free mode to make more room for the graph."
	_host_label = _label(status_bar, "")
	_picker = ConfirmationDialog.new()
	_picker.title = "Choose scene node"
	_tree = Tree.new()
	_tree.custom_minimum_size = Vector2(480, 400)
	_picker.add_child(_tree)
	_picker.confirmed.connect(_pick_node)
	add_child(_picker)
	_variables_dialog = AcceptDialog.new()
	_variables_dialog.title = "Graph variables"
	add_child(_variables_dialog)
	if parameters_only:
		toolbar.hide()
		library.hide()
		tabs.hide()
		focus_button.hide()
		_host_label.hide()
	document.changed.connect(_schedule_refresh)
	_fill_palette()
	_refresh()


## Selects a spatial card in the compact parameter inspector.
func select_block(id: int) -> void:
	_selected_id = id
	if not _parameters_only or _details_key != _current_details_key(): _refresh_details()


## Opens the existing typed variable editor inside the view's viewport.
func show_variables() -> void:
	_show_variables()


## Selects a script host using the same scene tree as the desktop view.
func show_host_picker() -> void:
	_show_picker(-1)


## Commits visible drafts before closing or switching documents, even if incomplete.
func flush_parameters() -> void:
	var focus := get_viewport().gui_get_focus_owner()
	if focus != null and is_ancestor_of(focus): focus.release_focus()
	_commit_target()


## Displays build results and actionable validation errors without opening a modal.
func show_status(message: String, error: bool = false) -> void:
	_status.text = message
	_status.modulate = Color("ffaaaa") if error else Color("b9c9d9")


## Flushes the visible target draft before Save/Build/Attach. Invalid drafts stay
## visible with their diagnostic and cannot accidentally build the previous value.
func validate_active_target() -> bool:
	if not is_instance_valid(_target_field): return true
	if not document.scene_context_active():
		show_status(document.scene_context_message())
		return false
	_commit_target()
	if _target_dirty: return false
	if document.target_is_connected(_target_id): return true
	var problem := document.target_problem(_target_id, _target_field.text)
	if not problem.is_empty():
		show_status(problem, true)
		return false
	return true


func _exit_tree() -> void:
	if document != null and document.changed.is_connected(_schedule_refresh):
		document.changed.disconnect(_schedule_refresh)


func _shortcut_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo or not key.is_command_or_control_pressed():
		return
	# Text fields retain their own editing shortcuts.
	var focus := get_viewport().gui_get_focus_owner()
	if focus is LineEdit or focus is TextEdit:
		if key.keycode != KEY_S:
			return
	match key.keycode:
		KEY_S:
			if focus is LineEdit:
				focus.release_focus()
			save_requested.emit()
		KEY_Z:
			if key.shift_pressed:
				document.redo()
			else:
				document.undo()
		KEY_Y:
			document.redo()
		_:
			return
	get_viewport().set_input_as_handled()


func _button(parent: Node, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	parent.add_child(button)
	button.pressed.connect(action)
	return button


func _label(parent: Node, text: String) -> Label:
	var label := Label.new()
	label.text = text
	parent.add_child(label)
	return label


func _fill_palette() -> void:
	_palette.clear()
	for kind: String in XREBlueprintGraph.BLOCKS:
		var title: String = XREBlueprintGraph.BLOCKS[kind]["title"]
		if not _search.text.is_empty() and not title.to_lower().contains(_search.text.to_lower()):
			continue
		var index := _palette.add_item(title)
		_palette.set_item_metadata(index, kind)
	if _palette.item_count > 0:
		_palette.select(0)


func _add_block(index: int) -> void:
	var offset := Vector2(80, 80) + Vector2(24, 24) * (document.graph.nodes.size() % 7)
	document.add_block(_palette.get_item_metadata(index), (canvas.scroll_offset + offset) / canvas.zoom)
	if document.graph.nodes.size() >= XREBlueprintGraph.MAX_NODES:
		show_status("Block limit reached.", true)


func _schedule_refresh() -> void:
	if not _pending_refresh:
		_pending_refresh = true
		_refresh.call_deferred()


func _refresh() -> void:
	if not is_inside_tree():
		return
	_pending_refresh = false
	if _parameters_only:
		_scene_notice.visible = not document.scene_context_active()
		_scene_message.text = document.scene_context_message()
		_scene_button.disabled = document.graph.scene_path.is_empty()
		if _details_key != _current_details_key(): _refresh_details()
		return
	_rebuilding = true
	var selected: Array[int] = []
	for child: Node in canvas.get_children():
		if child is GraphNode:
			var block := child as GraphNode
			if block.selected:
				selected.append(int(str(block.name)))
			canvas.remove_child(child)
			child.queue_free()
	canvas.clear_connections()
	for block: Dictionary in document.graph.nodes:
		var node := GraphNode.new()
		var kind: String = block["kind"]
		var spec: Dictionary = XREBlueprintGraph.BLOCKS[kind]
		node.name = str(block["id"])
		node.title = "%s · %d" % [spec["title"], block["id"]]
		node.custom_minimum_size.x = 190
		node.position_offset = block["position"]
		canvas.add_child(node)
		var inputs := document.graph.ports(block, true)
		var outputs := document.graph.ports(block, false)
		for slot: int in maxi(inputs.size(), outputs.size()):
			var row := HBoxContainer.new()
			node.add_child(row)
			var left := _label(row, inputs[slot][0] if slot < inputs.size() else "")
			left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_label(row, outputs[slot][0] if slot < outputs.size() else "")
			var left_type: int = inputs[slot][1] if slot < inputs.size() else 0
			var right_type: int = outputs[slot][1] if slot < outputs.size() else 0
			row.tooltip_text = "%s → %s" % [_port_name(left_type), _port_name(right_type)]
			node.set_slot(slot, slot < inputs.size(), left_type, PORT_COLORS[left_type], slot < outputs.size(), right_type, PORT_COLORS[right_type])
		var summary := _label(node, _summary(block))
		summary.modulate = Color("adbac9")
		summary.custom_minimum_size.x = 160
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		node.selected = selected.has(block["id"])
	for edge: Dictionary in document.graph.edges:
		canvas.connect_node(str(edge["from"]), edge["from_port"], str(edge["to"]), edge["to_port"])
	_filename.text = (document.path.get_file() if not document.path.is_empty() else "Untitled") + (" *" if document.is_dirty() else "")
	_host_label.text = "Host: " + str(document.graph.host_path)
	var context_active := document.scene_context_active()
	_scene_notice.visible = not context_active
	_scene_message.text = document.scene_context_message()
	_scene_message.tooltip_text = document.graph.scene_path
	_scene_button.disabled = document.graph.scene_path.is_empty() or not FileAccess.file_exists(document.graph.scene_path)
	if context_active != _context_was_active:
		show_status("Graph scene active." if context_active else document.scene_context_message())
	_context_was_active = context_active
	_undo_button.disabled = not document.history.has_undo()
	_redo_button.disabled = not document.history.has_redo()
	var result := XREBlueprintCompiler.compile(document.graph)
	_source.text = result["code"]
	if not (result["errors"] as PackedStringArray).is_empty(): show_status("\n".join(result["errors"]), true)
	_rebuilding = false
	if not _keep_details or _details_state != document.graph.snapshot():
		_refresh_details()
	_keep_details = false


func _summary(block: Dictionary) -> String:
	var params: Dictionary = block["params"]
	var lines := PackedStringArray()
	for key: String in params:
		lines.append("%s: %s" % [key, str(params[key]).left(40)])
	return "\n".join(lines) if not lines.is_empty() else "Runs when the node is ready."


func _port_name(type: int) -> String:
	return ["Execution", "Variant", "bool", "int", "float", "String", "Vector2", "Vector3", "Object", "Color"][type]


func _select_block(node: Node) -> void:
	if _rebuilding:
		return
	_selected_id = int(str(node.name))
	_refresh_details()


## What the compact details show; a block move leaves it unchanged, so the form is kept.
func _current_details_key() -> Array:
	var target := document.target_node(_selected_id) if _selected_id >= 0 else null
	return [document.graph.structure_key(), document.path, _selected_id, document.scene_context_active(), target.get_instance_id() if target != null else 0]


func _refresh_details() -> void:
	_details_key = _current_details_key()
	var preserve_draft := is_instance_valid(_target_field) and _target_dirty and _target_id == _selected_id and _target_document_path == document.path
	var draft := _target_field.text if preserve_draft else ""
	_rebuilding = true
	_target_field = null
	_target_hint = null
	_target_matches = null
	_target_id = -1
	for child: Node in _details.get_children():
		_details.remove_child(child)
		child.queue_free()
	var block := document.graph.find_node(_selected_id)
	if block.is_empty():
		_label(_details, "Select a block")
		var hint := _label(_details, "Double-click a block in the list to add it.\n\nWhite wires: execution\nBlue wires: values\nPink wires: booleans\n\nDrag ports to connect.\nDrag an input wire to disconnect.\nDelete removes selected blocks.")
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_rebuilding = false
		return
	_label(_details, XREBlueprintGraph.BLOCKS[block["kind"]]["title"])
	var params: Dictionary = block["params"]
	for key: String in params:
		_label(_details, key.capitalize())
		if key == "target":
			_target_editor(block)
		elif key == "policy":
			_options(block["id"], key, ["parallel", "ignore", "restart"], params[key])
		elif key == "variable":
			var names: Array[String] = []
			for variable: Dictionary in document.graph.variables: names.append(variable["name"])
			_options(block["id"], key, names, params[key])
		elif key in ["property", "signal", "animation"] and document.target_node(block["id"]) != null:
			_scene_options(block, key)
		elif key in ["value", "a", "b"] and block["kind"] != "boolean" and not block["kind"] == "set_variable":
			_literal_editor(block["id"], key, params[key])
		else:
			_parameter_editor(block["id"], key, params[key])
	if block.has("property_type"):
		_label(_details, "Property type: " + XREBlueprintSchema.type_name(block["property_type"]))
	if block["kind"] == "signal":
		for argument: Dictionary in block.get("arguments", []): _label(_details, "%s: %s" % [argument["name"], XREBlueprintSchema.type_name(argument["type"])] )
	if params.has("target"):
		var hint := _label(_details, "Target is relative to the node with the generated script. Use . for itself, Child for a child, ../Sibling for a sibling.")
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if params.has("seconds"):
		var hint := _label(_details, "Delay and Tween wait before continuing. Event policy controls repeated runs.")
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_button(_details, "Delete block", func() -> void: document.perform(document.remove_blocks.bind([block["id"]] as Array[int]), operation_source))
	_rebuilding = false
	if preserve_draft and is_instance_valid(_target_field):
		_target_field.text = draft
		_target_changed(draft)
	if _parameters_only:
		_bind_text_inputs(_details)


func _bind_text_inputs(parent: Node) -> void:
	for control: Node in parent.find_children("*", "LineEdit", true, false):
		var field := control as LineEdit
		field.gui_input.connect(_text_input.bind(field))


func _text_input(event: InputEvent, field: LineEdit) -> void:
	var mouse := event as InputEventMouseButton
	if field.editable and mouse != null and mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
		text_edit_requested.emit(field)


func _target_editor(block: Dictionary) -> void:
	_target_id = block["id"]
	_target_dirty = false
	_target_document_path = document.path
	_target_field = LineEdit.new()
	_target_field.name = "TargetPath"
	_target_field.text = block["params"]["target"]
	_target_field.placeholder_text = "Choose a scene node…"
	_details.add_child(_target_field)
	_target_hint = _label(_details, "")
	_target_hint.name = "TargetDiagnostic"
	_target_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_target_matches = ItemList.new()
	_target_matches.name = "TargetSuggestions"
	_target_matches.custom_minimum_size.y = 100
	_target_matches.focus_mode = Control.FOCUS_NONE
	_target_matches.hide()
	_details.add_child(_target_matches)
	_target_button = _button(_details, "Choose from scene…", func() -> void: _show_picker(block["id"]))
	_target_field.text_changed.connect(_target_changed)
	_target_field.focus_entered.connect(func() -> void: _update_target_feedback(true))
	_target_field.focus_exited.connect(_commit_target)
	_target_field.text_submitted.connect(_submit_target)
	_target_field.gui_input.connect(_target_key)
	_target_matches.item_selected.connect(_accept_target_suggestion)
	_update_target_feedback(false)


func _target_changed(_text: String) -> void:
	_target_dirty = true
	_update_target_feedback(_target_field.has_focus())


func _update_target_feedback(show_suggestions: bool) -> void:
	if not is_instance_valid(_target_field): return
	var active := document.scene_context_active()
	var dynamic := document.target_is_connected(_target_id)
	var problem := "" if not active or dynamic else document.target_problem(_target_id, _target_field.text)
	_target_hint.text = document.scene_context_message() if not active else ("Target comes from its connected port. This path is an optional schema sample." if dynamic else problem)
	_target_field.editable = active
	_target_button.disabled = not active
	_target_hint.modulate = Color("ffaaaa") if not problem.is_empty() else Color("b9c9d9")
	_target_field.tooltip_text = _target_hint.text
	_target_matches.clear()
	for node_path: String in document.target_suggestions(_target_id, _target_field.text):
		var index := _target_matches.add_item(node_path)
		_target_matches.set_item_metadata(index, node_path)
		var node := document.resolve_target(node_path)
		if node != null: _target_matches.set_item_tooltip(index, node.get_class())
	_target_matches.visible = active and show_suggestions and _target_matches.item_count > 0
	if problem.is_empty():
		_target_field.remove_theme_color_override("font_color")
		_target_field.remove_theme_stylebox_override("normal")
		_target_field.remove_theme_stylebox_override("focus")
	else:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("451f26")
		style.border_color = Color("ef7070")
		style.set_border_width_all(2)
		style.set_corner_radius_all(4)
		style.content_margin_left = 8
		style.content_margin_right = 8
		_target_field.add_theme_color_override("font_color", Color("ffaaaa"))
		_target_field.add_theme_stylebox_override("normal", style)
		_target_field.add_theme_stylebox_override("focus", style)


func _commit_target() -> void:
	if _rebuilding or not is_instance_valid(_target_field): return
	if not document.scene_context_active(): return
	_target_matches.hide()
	if not _target_dirty: return
	_keep_details = false
	if document.perform(document.set_parameter.bind(_target_id, "target", _target_field.text), operation_source):
		_target_dirty = false
	else:
		_target_hint.text = document.last_error
		_target_field.tooltip_text = document.last_error
		show_status(document.last_error, true)


func _accept_target_suggestion(index: int) -> void:
	if not is_instance_valid(_target_field): return
	var node_path: String = _target_matches.get_item_metadata(index)
	_target_field.text = node_path
	_target_field.caret_column = node_path.length()
	_target_changed(node_path)
	_commit_target()


func _submit_target(_text: String) -> void:
	var selected := _target_matches.get_selected_items()
	if _target_matches.visible and not selected.is_empty():
		_accept_target_suggestion(selected[0])
	else:
		_commit_target()


func _target_key(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or not _target_matches.visible: return
	var selected := _target_matches.get_selected_items()
	var index := selected[0] if not selected.is_empty() else -1
	match key.keycode:
		KEY_DOWN, KEY_UP:
			index = clampi(index + (1 if key.keycode == KEY_DOWN else -1), 0, _target_matches.item_count - 1)
			_target_matches.select(index)
			_target_matches.ensure_current_is_visible()
		KEY_ENTER, KEY_KP_ENTER, KEY_TAB:
			if index < 0:
				if key.keycode != KEY_TAB or document.target_problem(_target_id, _target_field.text).is_empty(): return
				index = 0
			_accept_target_suggestion(index)
		KEY_ESCAPE:
			_target_matches.hide()
		_:
			return
	_target_field.accept_event()


func _set_parameter(id: int, key: String, value: Variant) -> void:
	if _rebuilding:
		return
	if id == -1:
		if not document.perform(document.set_variable.bind(key, value), operation_source): show_status(document.last_error, true)
		return
	var block := document.graph.find_node(id)
	if block.is_empty():
		return
	var params: Dictionary = block["params"]
	var same_type := typeof(params.get(key)) == typeof(value)
	if key in ["target", "property", "signal", "variable", "wait"]: same_type = false
	# Variants of different types can't be compared: a literal switched from Vector2 to Vector3 would stop here.
	var value_changed: bool = typeof(params.get(key)) != typeof(value) or params.get(key) != value
	if document.perform(document.set_parameter.bind(id, key, value), operation_source):
		# Keep focus when committing one field by clicking or tabbing to another.
		if value_changed:
			_keep_details = same_type
			_details_state = document.graph.snapshot()
	if not document.last_error.is_empty():
		show_status(document.last_error, true)


func _literal_editor(id: int, key: String, value: Variant) -> void:
	var types: Array[int] = [TYPE_STRING, TYPE_INT, TYPE_FLOAT, TYPE_BOOL, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]
	var defaults: Array = ["", 0, 0.0, false, Vector2.ZERO, Vector3.ZERO, Color.WHITE]
	var picker := OptionButton.new()
	for title: String in ["Text", "Integer", "Number", "Boolean", "Vector2", "Vector3", "Color"]:
		picker.add_item(title)
	var index := types.find(typeof(value))
	picker.select(index if index >= 0 else 1)
	_details.add_child(picker)
	picker.item_selected.connect(func(selected: int) -> void: _set_parameter(id, key, defaults[selected]))
	_parameter_editor(id, key, value)


func _parameter_editor(id: int, key: String, value: Variant, parent: VBoxContainer = null) -> void:
	var container := parent if parent != null else _details
	match typeof(value):
		TYPE_BOOL:
			var check := CheckBox.new()
			check.text = "True"
			check.button_pressed = value
			container.add_child(check)
			check.toggled.connect(func(enabled: bool) -> void: _set_parameter(id, key, enabled))
		TYPE_INT, TYPE_FLOAT:
			var field := LineEdit.new()
			field.text = str(value)
			container.add_child(field)
			var apply := func() -> void:
				if value is int and field.text.is_valid_int():
					_set_parameter(id, key, field.text.to_int())
				elif not value is int and field.text.is_valid_float():
					_set_parameter(id, key, field.text.to_float())
				else:
					show_status("Enter a number for %s." % key, true)
			field.text_submitted.connect(func(_text: String) -> void: apply.call())
			field.focus_exited.connect(apply)
		TYPE_VECTOR2, TYPE_VECTOR3:
			var row := HBoxContainer.new()
			container.add_child(row)
			var fields: Array[LineEdit] = []
			for axis: int in (2 if value is Vector2 else 3):
				var field := LineEdit.new()
				field.custom_minimum_size.x = 65
				field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				field.text = str(value[axis])
				field.placeholder_text = ["X", "Y", "Z"][axis]
				row.add_child(field)
				fields.append(field)
			var apply := func() -> void:
				for field: LineEdit in fields:
					if not field.text.is_valid_float():
						show_status("Enter numeric vector components.", true)
						return
				var result: Variant = Vector2(fields[0].text.to_float(), fields[1].text.to_float())
				if fields.size() == 3:
					result = Vector3(fields[0].text.to_float(), fields[1].text.to_float(), fields[2].text.to_float())
				_set_parameter(id, key, result)
			for field: LineEdit in fields:
				field.text_submitted.connect(func(_text: String) -> void: apply.call())
				field.focus_exited.connect(apply)
		TYPE_COLOR:
			var color := ColorPickerButton.new()
			color.color = value
			container.add_child(color)
			color.color_changed.connect(func(chosen: Color) -> void: _set_parameter(id, key, chosen))
		_:
			var field := LineEdit.new()
			field.text = str(value)
			field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			container.add_child(field)
			var apply := func() -> void: _set_parameter(id, key, field.text)
			field.text_submitted.connect(func(_text: String) -> void: apply.call())
			field.focus_exited.connect(apply)


func _options(id: int, key: String, options: Array[String], current: String) -> void:
	var picker := OptionButton.new()
	var values := options.duplicate()
	if not values.has(current): values.insert(0, current)
	for value: String in values: picker.add_item(value if not value.is_empty() else "Choose…")
	picker.select(values.find(current))
	_details.add_child(picker)
	picker.item_selected.connect(func(index: int) -> void: _set_parameter(id, key, values[index]))
	# A text field also supports component paths and script-defined properties.
	if key in ["property", "signal", "animation"]: _parameter_editor(id, key, current)


func _scene_options(block: Dictionary, key: String) -> void:
	var target := document.target_node(block["id"])
	var names: Array[String] = []
	match key:
		"property":
			for info: Dictionary in XREBlueprintSchema.properties(target): names.append(str(info["name"]))
		"signal":
			for info: Dictionary in target.get_signal_list(): names.append(str(info["name"]))
		"animation":
			if target is AnimationPlayer:
				for name: String in (target as AnimationPlayer).get_animation_list(): names.append(name)
	_options(block["id"], key, names, block["params"][key])


func _show_picker(id: int) -> void:
	if not document.scene_context_active():
		show_status(document.scene_context_message())
		return
	_pick_id = id
	_tree.clear()
	var items: Dictionary[Node, TreeItem] = {}
	var nodes := document.scene_nodes()
	if nodes.is_empty():
		show_status("Open a scene before choosing a target or script host.", true)
		return
	for node: Node in nodes:
		var parent: TreeItem = items.get(node.get_parent())
		var item := _tree.create_item(parent)
		item.set_text(0, "%s (%s)" % [node.name, node.get_class()])
		item.set_metadata(0, weakref(node))
		if id >= 0:
			var kind: String = document.graph.find_node(id)["kind"]
			var kind_problem := XREBlueprintSchema.target_kind_problem(kind, node)
			var problem := XREBlueprintSchema.target_problem(document.graph.find_node(id), node)
			if not kind_problem.is_empty():
				item.set_selectable(0, false)
				item.set_custom_color(0, Color("888888"))
			elif not problem.is_empty(): item.set_custom_color(0, Color("e5b57b"))
			item.set_tooltip_text(0, problem)
		items[node] = item
	_picker.popup_centered()


func _pick_node() -> void:
	var item := _tree.get_selected()
	if item == null: return
	var ref := item.get_metadata(0) as WeakRef
	var node := ref.get_ref() as Node
	if node == null: return
	var action := document.set_host_node.bind(node) if _pick_id < 0 else document.choose_target.bind(_pick_id, node)
	var success: bool = document.perform(action, operation_source)
	if not success: show_status(document.last_error, true)


func _show_variables() -> void:
	for child: Node in _variables_dialog.get_children():
		if child is ScrollContainer: child.free()
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(460, 420)
	_variables_dialog.add_child(scroll)
	var fields := VBoxContainer.new()
	fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(fields)
	var error := _label(fields, "")
	error.modulate = Color("ffaaaa")
	for variable: Dictionary in document.graph.variables:
		_label(fields, "%s: %s" % [variable["name"], type_string(typeof(variable["value"]))])
		_parameter_editor(-1, variable["name"], variable["value"], fields)
		_button(fields, "Remove " + variable["name"], func() -> void:
			if document.perform(document.remove_variable.bind(variable["name"]), operation_source): _show_variables.call_deferred()
			else: error.text = document.last_error)
	_label(fields, "New variable")
	var name := LineEdit.new()
	name.placeholder_text = "has_key"
	fields.add_child(name)
	var type := OptionButton.new()
	for value: int in XREBlueprintSchema.LITERAL_TYPES: type.add_item(type_string(value))
	fields.add_child(type)
	_button(fields, "Add variable", func() -> void:
		if not document.graph.find_variable(name.text).is_empty(): error.text = "A variable with this name already exists."
		elif document.perform(document.set_variable.bind(name.text, XREBlueprintSchema.default_value(XREBlueprintSchema.LITERAL_TYPES[type.selected])), operation_source): _show_variables.call_deferred()
		else: error.text = document.last_error)
	if _parameters_only: _bind_text_inputs(fields)
	_variables_dialog.popup_centered()


func _connect_blocks(from: StringName, from_port: int, to: StringName, to_port: int) -> void:
	if not document.connect_blocks(int(str(from)), from_port, int(str(to)), to_port):
		show_status(document.last_error, true)
	else:
		show_status("Connected.")


func _disconnect_blocks(from: StringName, from_port: int, to: StringName, to_port: int) -> void:
	document.disconnect_blocks(int(str(from)), from_port, int(str(to)), to_port)


func _delete_blocks(names: Array[StringName]) -> void:
	var ids: Array[int] = []
	for item: StringName in names:
		ids.append(int(str(item)))
	document.remove_blocks(ids)


func _move_blocks() -> void:
	var state := document.graph.snapshot()
	for child: Node in canvas.get_children():
		if child is GraphNode:
			for block: Dictionary in state["nodes"]:
				if block["id"] == int(str(child.name)):
					block["position"] = (child as GraphNode).position_offset
	document.commit("Move Blocks", state)
