@tool
class_name XREBlueprintTab
extends XREPanelTab
## Project graph catalog and block palette on the forearm or in a floating window.

var _service: XREBlueprints
var _status: Label
var _graphs: ItemList
var _blocks: OptionButton
var _markers: CheckBox


func _init(document: XREDocument) -> void:
	super(document)
	name = "Blueprints"
	_button(self, "New unassigned graph", func() -> void:
		if _service != null: _service.create_unassigned())
	var actions := HBoxContainer.new()
	add_child(actions)
	_button(actions, "Open / Create", func() -> void:
		if _service != null: _service.open_selected())
	_button(actions, "Detach", func() -> void:
		if _service != null: _service.detach_selected())
	_button(actions, "Refresh", func() -> void:
		if _service != null: _service.refresh_catalog())
	_markers = CheckBox.new()
	_markers.text = "Logic mode: show Blueprint markers"
	_markers.toggled.connect(func(enabled: bool) -> void:
		if _service != null: _service.set_logic_mode(enabled))
	add_child(_markers)
	_graphs = ItemList.new()
	_graphs.size_flags_vertical = SIZE_EXPAND_FILL
	_graphs.item_activated.connect(_open_item)
	add_child(_graphs)
	_button(self, "Open selected graph", func() -> void:
		var selected := _graphs.get_selected_items()
		if not selected.is_empty(): _open_item(selected[0]))
	var palette := HBoxContainer.new()
	add_child(palette)
	_blocks = OptionButton.new()
	_blocks.size_flags_horizontal = SIZE_EXPAND_FILL
	for kind: String in XREBlueprintGraph.BLOCKS:
		_blocks.add_item(XREBlueprintGraph.BLOCKS[kind]["title"])
		_blocks.set_item_metadata(_blocks.item_count - 1, kind)
	palette.add_child(_blocks)
	_button(palette, "Add block", func() -> void:
		if _service != null:
			if not _service.is_open(): _service.show_graph()
			_service.add_block(_blocks.get_item_metadata(_blocks.selected)))
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_status)


## Panel construction is independent of tool order; the plugin injects its service once.
func setup(service: XREBlueprints) -> void:
	if _service != null and _service.changed.is_connected(mark_dirty): _service.changed.disconnect(mark_dirty)
	_service = service
	if _service != null: _service.changed.connect(mark_dirty)
	mark_dirty()


func _exit_tree() -> void:
	if _service != null and _service.changed.is_connected(mark_dirty): _service.changed.disconnect(mark_dirty)


func get_title() -> String:
	return "Blueprints"


func get_icon_name() -> StringName:
	return &"VisualShader"


func _refresh() -> void:
	if _service == null:
		_status.text = "Blueprint tools are available in the XR view."
		return
	_graphs.clear()
	for path: String in _service.graph_paths():
		var index := _graphs.add_item(path.trim_prefix("res://"))
		_graphs.set_item_metadata(index, path)
	_markers.set_pressed_no_signal(_service.logic_mode)
	_status.text = _service.status


func _open_item(index: int) -> void:
	if _service != null: _service.open_graph(_graphs.get_item_metadata(index))


func _button(parent: Node, text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.pressed.connect(action)
	parent.add_child(button)
