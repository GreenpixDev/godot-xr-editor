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

# The built-in compound values (D-139): vectors blue, whole vectors green, boxes teal, a rotation violet, transforms orange.
const PORT_COLORS: Array[Color] = [Color("eeeeee"), Color("63c6ea"), Color("e8879b"), Color("b4e05a"), Color("7be5b3"), Color("e5b57b"), Color("89adff"), Color("89adff"), Color("b991eb"), Color("f2d878"), Color("89adff"), Color("9fd36a"), Color("9fd36a"), Color("6fc3c8"), Color("6fc3c8"), Color("c38bf0"), Color("f0a35e"), Color("f0a35e"), Color("f0a35e"), Color("6fc3c8")]

var document: XREBlueprintDocument
## Input origin of this view. The compact XR inspector uses vr_panel.
var operation_source: StringName = &"desktop_graph"
var _parameters_only := false
var canvas: GraphEdit
var _details: VBoxContainer
var _source: CodeEdit
var _status: Label
var _filename: Label
## The scene nodes selected in the editor, for the menu's first context: set by the plugin.
var selected_nodes_provider: Callable
## Whether a parameter shows in the details, [code]func(block, key) -> bool[/code]:
## the headset sets some in the graph instead (D-052). Without it, all show.
var parameter_filter: Callable
var _menu: XREBlueprintActionMenu
var _popup: PopupPanel
var _popup_menu: XREBlueprintActionMenu
var _popup_wire: Dictionary = {}
var _popup_position := Vector2.ZERO
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
	library.custom_minimum_size.x = 300
	body.add_child(library)
	_label(library, "ADD BLOCK")
	_menu = XREBlueprintActionMenu.new()
	library.add_child(_menu)
	_menu.action_chosen.connect(_add_action)
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
	canvas.connection_to_empty.connect(_connection_to_empty)
	canvas.connection_from_empty.connect(_connection_from_empty)
	canvas.popup_request.connect(_menu_at)
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
	_popup = PopupPanel.new()
	_popup.size = Vector2i(460, 520)
	add_child(_popup)
	_popup_menu = XREBlueprintActionMenu.new()
	_popup.add_child(_popup_menu)
	_popup_menu.action_chosen.connect(_add_popup_action)
	_popup_menu.pin_cleared.connect(func() -> void: _popup_wire = {})
	if parameters_only:
		toolbar.hide()
		library.hide()
		tabs.hide()
		focus_button.hide()
		_host_label.hide()
	document.changed.connect(_schedule_refresh)
	refresh_menu()
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


## Points the add-block menu at the selected scene node, the selected block's target and the host.
func refresh_menu() -> void:
	if _menu == null or _parameters_only: return
	_menu.set_contexts(menu_contexts(), document.get_host(), document.graph)


## Context objects of the add-block menu (D-051): the scene node selected in
## the editor, the selected block's target and the graph's host, each once.
func menu_contexts() -> Array[Dictionary]:
	var nodes: Array[Node] = []
	if selected_nodes_provider.is_valid():
		var selected: Array = selected_nodes_provider.call()
		if not selected.is_empty() and selected[0] is Node: nodes.append(selected[0])
	if _selected_id >= 0: nodes.append(document.target_node(_selected_id))
	nodes.append(document.get_host())
	var contexts: Array[Dictionary] = []
	var scene := document.scene_nodes()
	var seen: Array[Node] = []
	for node: Node in nodes:
		if node == null or seen.has(node) or not scene.has(node): continue
		seen.append(node)
		contexts.append({"label": str(node.name), "node": node})
	return contexts


func _add_action(action: Dictionary) -> void:
	var offset := Vector2(80, 80) + Vector2(24, 24) * (document.graph.nodes.size() % 7)
	_insert(action, (canvas.scroll_offset + offset) / canvas.zoom, {})


func _add_popup_action(action: Dictionary) -> void:
	_popup.hide()
	_insert(action, _popup_position, _popup_wire)


func _insert(action: Dictionary, position: Vector2, wire: Dictionary) -> void:
	if document.graph.nodes.size() >= XREBlueprintGraph.MAX_NODES:
		show_status("Block limit reached.", true)
		return
	var target := action.get("target") as Node
	var id: int = document.perform(document.insert_block.bind(action["block"], position, wire, target), operation_source)
	if id < 0:
		show_status(document.last_error, true)
		return
	_selected_id = id
	show_status("Added %s." % action["title"])


## The add-block menu where the canvas was right-clicked, without a wire.
func _menu_at(at_position: Vector2) -> void:
	_popup_wire = {}
	_open_popup(at_position, {}, [])


## A wire from output [param from_port] of block [param from_node] let go on
## the empty canvas: the menu lists the blocks that can take it, and wires the
## one chosen (D-051).
func _connection_to_empty(from_node: StringName, from_port: int, release_position: Vector2) -> void:
	var block := document.graph.find_node(int(str(from_node)))
	if block.is_empty(): return
	var spec: Array = document.graph.ports(block, false)[from_port]
	_popup_wire = {"from": block["id"], "from_port": from_port}
	_open_popup(release_position, {"type": spec[1], "output": true, "label": "%s ▸ %s · %s" % [XREBlueprintGraph.title(block), spec[0], _port_name(spec[1])]}, _pin_contexts(block, from_port, spec))


## The same for a wire pulled out of input [param to_port] of block [param to_node].
func _connection_from_empty(to_node: StringName, to_port: int, release_position: Vector2) -> void:
	var block := document.graph.find_node(int(str(to_node)))
	if block.is_empty(): return
	var spec: Array = document.graph.ports(block, true)[to_port]
	_popup_wire = {"to": block["id"], "to_port": to_port}
	_open_popup(release_position, {"type": spec[1], "output": false, "label": "%s ▸ %s · %s" % [XREBlueprintGraph.title(block), spec[0], _port_name(spec[1])]}, [])


## An object output of a signal is a context of its own: its class's members, aimed by the wire.
func _pin_contexts(block: Dictionary, port: int, spec: Array) -> Array[Dictionary]:
	var contexts: Array[Dictionary] = []
	if spec[1] != XREBlueprintGraph.OBJECT or block["kind"] != "signal": return contexts
	var arguments: Array = block.get("arguments", [])
	if port - 1 < 0 or port - 1 >= arguments.size(): return contexts
	var argument: Dictionary = arguments[port - 1]
	var cls := str(argument.get("class_name", ""))
	contexts.append({"label": "%s · %s" % [argument["name"], cls if not cls.is_empty() else "Object"], "class": cls if not cls.is_empty() else "Node"})
	return contexts


func _open_popup(release_position: Vector2, pin: Dictionary, extra_contexts: Array[Dictionary]) -> void:
	_popup_position = (release_position + canvas.scroll_offset) / canvas.zoom
	var contexts := extra_contexts.duplicate()
	contexts.append_array(menu_contexts())
	_popup_menu.open(contexts, document.get_host(), document.graph, pin)
	_popup.popup(Rect2i(Vector2i(canvas.get_screen_position() + release_position), _popup.size))
	_popup_menu.search.grab_focus()


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
		node.name = str(block["id"])
		node.title = "%s · %d" % [XREBlueprintGraph.title(block), block["id"]]
		node.custom_minimum_size.x = 190
		node.position_offset = block["position"]
		canvas.add_child(node)
		var inputs := document.graph.ports(block, true)
		var outputs := document.graph.ports(block, false)
		if XREBlueprintGraph.is_operator(block):
			_fill_operator(node, block, inputs, outputs)
			node.selected = selected.has(block["id"])
			continue
		# A Sequence's outputs and a Switch's cases come and go (D-138): × by one under the mouse, "+ pin" under them.
		var pins := XREBlueprintGraph.variable_pins(block)
		var id: int = block["id"]
		for slot: int in maxi(inputs.size(), outputs.size()):
			var row := HBoxContainer.new()
			row.mouse_filter = Control.MOUSE_FILTER_PASS
			node.add_child(row)
			var left := _label(row, inputs[slot][0] if slot < inputs.size() else "")
			left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if not pins.is_empty() and not pins["input"] and slot < int(pins["count"]) and int(pins["count"]) > XREBlueprintGraph.MIN_PINS:
				var remove := _button(row, "×", _set_call_option.bind(document.remove_pin.bind(id, slot)))
				remove.name = "RemovePin%d" % slot
				remove.flat = true
				remove.tooltip_text = "Remove %s and its wire" % outputs[slot][0]
				remove.modulate.a = 0.0
				row.mouse_entered.connect(func() -> void: remove.modulate.a = 1.0)
				row.mouse_exited.connect(func() -> void: remove.modulate.a = 0.0)
			_label(row, outputs[slot][0] if slot < outputs.size() else "")
			var left_type: int = inputs[slot][1] if slot < inputs.size() else 0
			var right_type: int = outputs[slot][1] if slot < outputs.size() else 0
			row.tooltip_text = "%s → %s" % [_port_name(left_type), _port_name(right_type)]
			node.set_slot(slot, slot < inputs.size(), left_type, PORT_COLORS[left_type], slot < outputs.size(), right_type, PORT_COLORS[right_type])
		if not pins.is_empty() and pins["can_add"]:
			var add := _button(node, "+ pin", _set_call_option.bind(document.add_pin.bind(id)))
			add.name = "AddPin"
			add.flat = true
			add.size_flags_horizontal = Control.SIZE_SHRINK_END
			add.tooltip_text = "Add an output"
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
	refresh_menu()
	_undo_button.disabled = not document.history.has_undo()
	_redo_button.disabled = not document.history.has_redo()
	var result := XREBlueprintCompiler.compile(document.graph)
	_source.text = result["code"]
	if not (result["errors"] as PackedStringArray).is_empty(): show_status("\n".join(result["errors"]), true)
	_rebuilding = false
	if not _keep_details or _details_state != document.graph.snapshot():
		_refresh_details()
	_keep_details = false


## An operator as Unreal draws one (D-065): no title, the literal of each
## input without a wire by its port, the symbol in the middle, the result on
## the right. Its name is its tooltip. A variadic one (D-136) shows × by an
## input under the mouse while it has more than two, and "+ pin" under them.
func _fill_operator(node: GraphNode, block: Dictionary, inputs: Array, outputs: Array) -> void:
	node.title = ""
	node.tooltip_text = "%s · %d" % [XREBlueprintGraph.title(block), block["id"]]
	node.custom_minimum_size.x = 0
	var params: Dictionary = block["params"]
	var id: int = block["id"]
	var variadic := XREBlueprintOperators.is_variadic(XREBlueprintGraph.operator_of(block))
	var wired: Dictionary[int, bool] = {}
	for edge: Dictionary in document.graph.edges:
		if edge["to"] == block["id"]: wired[int(edge["to_port"])] = true
	for slot: int in inputs.size():
		var row := HBoxContainer.new()
		row.add_theme_constant_override(&"separation", 10)
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		node.add_child(row)
		var key: String = inputs[slot][2]
		if variadic and inputs.size() > XREBlueprintOperators.MIN_OPERANDS:
			var remove := _button(row, "×", _set_call_option.bind(document.remove_operand.bind(id, key)))
			remove.name = "Remove" + key.to_upper()
			remove.flat = true
			remove.tooltip_text = "Remove input %s and its wire" % key.to_upper()
			remove.modulate.a = 0.0
			row.mouse_entered.connect(func() -> void: remove.modulate.a = 1.0)
			row.mouse_exited.connect(func() -> void: remove.modulate.a = 0.0)
		var left := _label(row, _short(params[key]) if params.has(key) and not wired.has(slot) else "")
		left.modulate = Color("adbac9")
		left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var middle := _label(row, XREBlueprintGraph.symbol(block) if slot == 0 else "")
		middle.add_theme_font_size_override(&"font_size", 22)
		middle.custom_minimum_size.x = 36
		middle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var left_type: int = inputs[slot][1]
		var right_type: int = outputs[0][1]
		# Wired, an input of any value is in the color of what comes in; its type still takes any wire.
		var shown := XREBlueprintGraph.port_type(document.graph.operand_type(block, key)) if left_type == XREBlueprintGraph.VALUE and wired.has(slot) else left_type
		node.set_slot(slot, true, left_type, PORT_COLORS[shown], slot == 0, right_type, PORT_COLORS[right_type])
	if variadic and inputs.size() < XREBlueprintOperators.MAX_OPERANDS:
		var add := _button(node, "+ pin", _set_call_option.bind(document.add_operand.bind(id)))
		add.name = "AddPin"
		add.flat = true
		add.size_flags_horizontal = Control.SIZE_SHRINK_END
		add.tooltip_text = "Add an input"


## A literal in a few characters, for an operator's input.
static func _short(value: Variant) -> String:
	if value is Color: return "#" + (value as Color).to_html(false)
	if value is String: return "\"%s\"" % (value as String).left(10)
	return str(value).left(18)


func _summary(block: Dictionary) -> String:
	var params: Dictionary = block["params"]
	var lines := PackedStringArray()
	for key: String in params:
		lines.append("%s: %s" % [key, str(params[key]).left(40)])
	return "\n".join(lines) if not lines.is_empty() else "Runs when the node is ready."


func _port_name(type: int) -> String:
	return ["Execution", "Variant", "bool", "int", "float", "String", "Vector2", "Vector3", "Object", "Color", "Vector4", "Vector2i", "Vector3i", "Rect2", "AABB", "Quaternion", "Basis", "Transform2D", "Transform3D", "Plane"][type]


func _select_block(node: Node) -> void:
	if _rebuilding:
		return
	_selected_id = int(str(node.name))
	_refresh_details()
	refresh_menu()


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
	_label(_details, XREBlueprintGraph.title(block))
	var params: Dictionary = block["params"]
	if block["kind"] == "call":
		_call_details(block)
	for key: String in (params if block["kind"] != "call" else {}):
		# The counts of pins change by the pins (D-136, D-138); what a Switch is on is its kind.
		if key in ["operands", "outputs", "cases", "on", "enum"] or not _shows(block, key) or XREBlueprintGraph.is_unused(block, key): continue
		_label(_details, key.capitalize())
		if block["kind"] == "switch" and params.get("on") == "enum" and (key == "selection" or key.begins_with("case_")):
			# An enumeration's case and selection are its constants' names (D-138).
			var names: Array[String] = []
			names.assign(XREBlueprintGraph.enum_constants(str(params.get("enum", ""))).keys())
			_options(block["id"], key, names, str(params[key]))
		elif key == "op":
			# Another operator of the same group and as many operands (D-065); past two, a variadic one (D-136).
			var op := str(params[key])
			var many := XREBlueprintGraph.operand_count(block) > XREBlueprintOperators.MIN_OPERANDS
			var same: Array[String] = []
			for other: String in XREBlueprintOperators.OPERATORS:
				if XREBlueprintOperators.group_of(other) == XREBlueprintOperators.group_of(op) and XREBlueprintOperators.is_unary(other) == XREBlueprintOperators.is_unary(op) \
						and (not many or XREBlueprintOperators.is_variadic(other)): same.append(other)
			_options(block["id"], key, same, op)
		elif key == "target":
			_target_editor(block)
		elif key == "policy":
			_options(block["id"], key, ["parallel", "ignore", "restart"], params[key])
		elif key == "variable":
			var names: Array[String] = []
			for variable: Dictionary in document.graph.variables: names.append(variable["name"])
			_options(block["id"], key, names, params[key])
		elif key in ["property", "signal", "animation"] and document.target_node(block["id"]) != null:
			_scene_options(block, key)
		elif (key == "value" or key in XREBlueprintOperators.OPERAND_KEYS) and block["kind"] != "boolean" and not block["kind"] == "set_variable":
			_literal_editor(block["id"], key, params[key])
		else:
			_parameter_editor(block["id"], key, params[key])
	# Values taken out in the headset leave their sockets empty (D-054).
	if block["kind"] != "call":
		var defaults: Dictionary = (XREBlueprintGraph.BLOCKS[block["kind"]]["params"] as Dictionary).duplicate()
		# Every input of an operator, C… too (D-136).
		if block["kind"] == "operator":
			for index: int in XREBlueprintGraph.operand_count(block):
				defaults[XREBlueprintOperators.OPERAND_KEYS[index]] = XREBlueprintOperators.operand_default(XREBlueprintGraph.operator_of(block), index)
		for key: String in defaults:
			if params.has(key) or not _shows(block, key) or XREBlueprintGraph.is_unused(block, key): continue
			_label(_details, key.capitalize())
			_empty_editor(block["id"], key, defaults[key])
	if block["kind"] in ["break", "make"]: _field_toggles(block)
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


## A Break's or a Make's fields, each shown while ticked (D-139): one with a
## wire can't be hidden. Without a type, how to give it one.
func _field_toggles(block: Dictionary) -> void:
	var struct: Dictionary = block.get("struct", {})
	if struct.is_empty():
		var hint := _label(_details, "Wire its Target to give it a type." if block["kind"] == "break" else "Wire its Result into an input to give it a type.")
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		return
	_label(_details, "Fields")
	var hidden: Array = block.get("hidden", [])
	for field: Dictionary in struct["fields"]:
		var name := str(field["name"])
		var check := CheckBox.new()
		check.name = "Field_" + name
		check.text = "%s  %s%s" % [name, XREBlueprintSchema.type_name(int(field["type"])), "  · missing" if field.get("missing", false) else ""]
		check.button_pressed = not hidden.has(name)
		_details.add_child(check)
		check.toggled.connect(func(shown: bool) -> void: _set_call_option(document.set_field_hidden.bind(block["id"], name, not shown)))


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


## The settings of a call: its Target, each argument with a value, extra values and advanced arguments.
func _call_details(block: Dictionary) -> void:
	var function: Dictionary = block["function"]
	var params: Dictionary = block["params"]
	var id: int = block["id"]
	var signature := _label(_details, "%s%s" % [str(function["class"]) + "." if not str(function["class"]).is_empty() else "", function["name"]])
	signature.modulate = Color("adbac9")
	if not str(function.get("description", "")).is_empty():
		var description := _label(_details, function["description"])
		description.modulate = Color("adbac9")
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var has_advanced := false
	for argument: Dictionary in function["args"]:
		if argument.get("advanced", false): has_advanced = true
		if not _shows(block, str(argument.get("key", ""))) and not str(argument.get("key", "")).is_empty(): continue
		if argument.get("target", false):
			_label(_details, "Target")
			_target_editor(block)
			continue
		if not XREBlueprintFunctions.has_literal(argument):
			if int(argument["type"]) == TYPE_OBJECT and not argument.get("run", false) and not argument.get("fixed", false):
				var wire := _label(_details, "%s: connect an object" % argument["label"])
				wire.modulate = Color("adbac9")
			continue
		if argument.get("advanced", false) and not function.get("advanced_shown", false): continue
		var key: String = argument["key"]
		_label(_details, argument["label"])
		if not params.has(key):
			_empty_editor(id, key, XREBlueprintFunctions.initial_value(argument))
			continue
		var provider := str(argument.get("provider", ""))
		var target := document.target_node(id)
		if not provider.is_empty() and target != null:
			var names: Array[String] = []
			names.assign(XREBlueprintSchema.provided_names(target, provider))
			_options(id, key, names, str(params[key]))
			_parameter_editor(id, key, params[key])
		elif not str(argument.get("enum", "")).is_empty() and str(argument["enum"]).contains("."):
			_enum_options(id, key, str(argument["enum"]), int(params[key]))
		elif int(argument["type"]) == TYPE_NIL:
			_literal_editor(id, key, params[key])
		else:
			_parameter_editor(id, key, params[key])
	for index: int in int(function.get("extra", 0)):
		var key := XREBlueprintFunctions.extra_key(index)
		if not _shows(block, key): continue
		_label(_details, XREBlueprintFunctions.title_of(key))
		if params.has(key): _literal_editor(id, key, params[key])
		else: _empty_editor(id, key, "")
	if function.get("vararg", false):
		var row := HBoxContainer.new()
		_details.add_child(row)
		_button(row, "+ value", func() -> void: _set_call_option(document.set_extra_arguments.bind(id, int(function.get("extra", 0)) + 1)))
		_button(row, "− value", func() -> void: _set_call_option(document.set_extra_arguments.bind(id, int(function.get("extra", 0)) - 1)))
	if has_advanced:
		var advanced := CheckBox.new()
		advanced.text = "Show advanced arguments"
		advanced.button_pressed = function.get("advanced_shown", false)
		_details.add_child(advanced)
		advanced.toggled.connect(func(shown: bool) -> void: _set_call_option(document.set_advanced_shown.bind(id, shown)))


## An empty socket's note, and a button that puts [param value] in it.
func _empty_editor(id: int, key: String, value: Variant) -> void:
	var row := HBoxContainer.new()
	_details.add_child(row)
	var note := _label(row, "empty — wire it or set a value")
	note.modulate = Color("e5b57b")
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button(row, "Set", func() -> void: _set_parameter(id, key, value))


func _shows(block: Dictionary, key: String) -> bool:
	return not parameter_filter.is_valid() or parameter_filter.call(block, key)


func _set_call_option(action: Callable) -> void:
	if _rebuilding: return
	if not document.perform(action, operation_source): show_status(document.last_error, true)


## A choice among the constants of enumeration [param enum_path], "Class.Enum".
func _enum_options(id: int, key: String, enum_path: String, current: int) -> void:
	var parts := enum_path.split(".")
	var picker := OptionButton.new()
	var values: Array[int] = []
	for constant: String in ClassDB.class_get_enum_constants(parts[0], parts[1]):
		values.append(ClassDB.class_get_integer_constant(parts[0], constant))
		picker.add_item(constant.capitalize())
	if not values.has(current):
		values.append(current)
		picker.add_item(str(current))
	picker.select(values.find(current))
	_details.add_child(picker)
	picker.item_selected.connect(func(index: int) -> void: _set_parameter(id, key, values[index]))


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
			var kind_problem := XREBlueprintSchema.target_kind_problem(document.graph.find_node(id), node)
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
		var type := XREBlueprintGraph.variable_type(variable)
		_label(fields, "%s: %s" % [variable["name"], type_string(type)])
		if variable.has("value"): _parameter_editor(-1, variable["name"], variable["value"], fields)
		else: _button(fields, "Set a start value", func() -> void:
			if document.perform(document.set_variable.bind(variable["name"], XREBlueprintSchema.default_value(type)), operation_source): _show_variables.call_deferred())
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
