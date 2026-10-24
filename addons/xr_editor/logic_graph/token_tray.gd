@tool
class_name XREBlueprintTokenTray
extends ScrollContainer
## The ready tokens of the Tokens window (D-052, D-055): Recent, Links (D-074), Numbers,
## Yes/No, Colors, Vectors, Modes and Text, four to a row (D-058: bigger). The cells are
## frames; [XREBlueprints] hangs a solid token in front of each, as the
## Objects window has its miniatures (D-045). The trigger or the grip on a
## cell takes a copy of its token; the tray never empties. While a socket is
## under the ray, cells that don't fit it are dim. Scrolls by dragging between
## the cells, as lists do.

## Emitted when the cells were rebuilt: their tokens must be built again.
signal cells_changed

const COLUMNS := 4
const CELL_SIZE := Vector2(116.0, 76.0)
const RECENT_COUNT := 5
const CELL_COLOR := Color(1.0, 1.0, 1.0, 0.07)
const SECTIONS: Array[Array] = [
	# A link that stands for nothing yet (D-074): laid on a port, it takes that port's wire, or asks for a box.
	["Links", [{"link": ""}]],
	["Numbers", [0.5, 1.0, 2.0, 5.0, 0, 1, 10, 100]],
	["Yes / No", [true, false]],
	["Colors", [Color("ffffff"), Color("7be5b3"), Color("e8879b"), Color("f2d878"), Color("89adff"), Color("ffb070"), Color("000000")]],
	["Vectors", [Vector3.ZERO, Vector3.UP, Vector3.ONE, Vector2.ZERO, Vector2.ONE]],
	["Modes", ["parallel", "ignore", "restart"]],
	["Text", ["", "Hello", "OPEN", "CLOSED"]],
]

var _recent: Array = []
var _cells: Array[PanelContainer] = []
var _values: Array = []
var _keys: Array[String] = []
var _fits: Array[bool] = []
var _filter: Callable
var _column: VBoxContainer


func _init() -> void:
	name = "TokenTray"
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_column = VBoxContainer.new()
	_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_column)
	_rebuild()


## Remembers [param value] for the Recent row.
func remember(value: Variant) -> void:
	for index: int in _recent.size():
		if typeof(_recent[index]) == typeof(value) and _recent[index] == value:
			_recent.remove_at(index)
			break
	_recent.insert(0, value)
	if _recent.size() > RECENT_COUNT: _recent.resize(RECENT_COUNT)
	_rebuild()


## Dims the cells for which [param fits] ([code]func(value, key) -> bool[/code]) is false; an invalid callable dims none.
func set_filter(fits: Callable) -> void:
	_filter = fits
	for index: int in _cells.size():
		_fits[index] = not fits.is_valid() or fits.call(_values[index], _keys[index])
		_cells[index].modulate.a = 1.0 if _fits[index] else 0.3


## The value and key of the cell at interface pixel [param pixel] of the window, or empty.
func cell_at(pixel: Vector2) -> Dictionary:
	if not get_global_rect().has_point(pixel): return {}
	for index: int in _cells.size():
		if _cells[index].get_global_rect().has_point(pixel): return {"value": _values[index], "key": _keys[index]}
	return {}


## Values of the cells, in order.
func get_values() -> Array:
	return _values


## The key of cell [param index]'s token: "policy" for a mode.
func get_key(index: int) -> String:
	return _keys[index]


## Where cell [param index] is, in interface pixels of the window, and whether all of it is in view.
func cell_rect(index: int) -> Rect2:
	return _cells[index].get_global_rect()


## Whether cell [param index] is wholly inside the visible part of the tray.
func is_cell_shown(index: int) -> bool:
	return get_global_rect().encloses(_cells[index].get_global_rect())


## Whether cell [param index]'s token fits the socket under the ray.
func cell_fits(index: int) -> bool:
	return _fits[index]


func _rebuild() -> void:
	for child: Node in _column.get_children():
		_column.remove_child(child)
		child.queue_free()
	_cells.clear()
	_values.clear()
	_keys.clear()
	_fits.clear()
	var sections: Array[Array] = []
	if not _recent.is_empty(): sections.append(["Recent", _recent])
	sections.append_array(SECTIONS)
	for section: Array in sections:
		var header := Label.new()
		header.text = str(section[0]).to_upper()
		header.add_theme_color_override(&"font_color", Color("a9b0bf"))
		_column.add_child(header)
		var grid := GridContainer.new()
		grid.columns = COLUMNS
		grid.add_theme_constant_override(&"h_separation", 6)
		grid.add_theme_constant_override(&"v_separation", 6)
		_column.add_child(grid)
		for value: Variant in section[1]:
			var key := "policy" if section[0] == "Modes" else XREBlueprintLinks.KEY if section[0] == "Links" else ""
			var cell := PanelContainer.new()
			cell.custom_minimum_size = CELL_SIZE
			cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cell.add_theme_stylebox_override(&"panel", XREPanelSurface.meta_style(CELL_COLOR, 12, 4.0))
			grid.add_child(cell)
			_cells.append(cell)
			_values.append(value)
			_keys.append(key)
			_fits.append(true)
	if _filter.is_valid(): set_filter(_filter)
	cells_changed.emit()
