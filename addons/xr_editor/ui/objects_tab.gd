@tool
class_name XREObjectsTab
extends XREPanelTab
## Things to add to the scene, in a see-through window (D-045): a cell per
## thing the palette offers ([constant XREPalette.ITEMS]), its name at the
## bottom. The window shows no 3D; [XREPalette] hangs a 3D miniature in front
## of each cell ([method get_cell_center]), which the right hand takes out as
## from the tray before (D-013, D-014). The cell of the miniature under the
## hand lights up.

## Cells at editor scale 1, in interface pixels: across, a cell and the height
## of its name, the gap between cells.
const COLUMNS := 3
const CELL_SIZE := Vector2(120.0, 130.0)
const NAME_HEIGHT := 28.0
const GAP := 8.0
## A cell's background, and while its miniature is under the hand.
const CELL_COLOR := Color(1.0, 1.0, 1.0, 0.06)
const HOVER_COLOR := Color(1.0, 1.0, 1.0, 0.22)

var _cells: Array[PanelContainer] = []
var _idle: StyleBoxFlat
var _lit: StyleBoxFlat
var _hovered := -1


func _init(document: XREDocument) -> void:
	super(document)
	name = "Objects"
	_idle = XREPanelSurface.meta_style(CELL_COLOR, 14, 4.0)
	_lit = XREPanelSurface.meta_style(HOVER_COLOR, 14, 4.0)
	var grid := GridContainer.new()
	grid.columns = COLUMNS
	grid.add_theme_constant_override(&"h_separation", int(GAP))
	grid.add_theme_constant_override(&"v_separation", int(GAP))
	grid.size_flags_horizontal = SIZE_SHRINK_CENTER
	grid.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(grid)
	for item: Array in XREPalette.ITEMS:
		var cell := PanelContainer.new()
		cell.name = String(item[0])
		cell.custom_minimum_size = CELL_SIZE
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_theme_stylebox_override(&"panel", _idle)
		# The miniature hangs over the space; the name is at the bottom.
		var column := VBoxContainer.new()
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(column)
		var space := Control.new()
		space.size_flags_vertical = SIZE_EXPAND_FILL
		space.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(space)
		var label := Label.new()
		label.name = "Name"
		label.text = item[1]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.custom_minimum_size.y = NAME_HEIGHT
		label.add_theme_color_override(&"font_color", Color.WHITE)
		label.add_theme_color_override(&"font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
		column.add_child(label)
		grid.add_child(cell)
		_cells.append(cell)


func get_title() -> String:
	return "Objects"


func get_symbol() -> StringName:
	return &"objects"


func get_window_size() -> Vector2:
	var rows := ceili(float(XREPalette.ITEMS.size()) / COLUMNS)
	return Vector2(CELL_SIZE.x * COLUMNS + GAP * (COLUMNS - 1) + 40.0, CELL_SIZE.y * rows + GAP * (rows - 1) + 40.0)


## See-through: the miniatures hang in it.
func get_frame_color() -> Color:
	var color := XREPanelSurface.META_WINDOW_COLOR
	color.a = 0.3
	return color


## Where the miniature of item [param index] hangs, in interface pixels: in the
## middle of its cell, above its name.
func get_cell_center(index: int) -> Vector2:
	var rect := _cells[index].get_global_rect()
	var name_height := NAME_HEIGHT * rect.size.x / CELL_SIZE.x
	return rect.position + Vector2(rect.size.x * 0.5, (rect.size.y - name_height) * 0.5)


## How wide a cell is, in interface pixels.
func get_cell_width() -> float:
	return _cells[0].get_global_rect().size.x


## The name under the cell of item [param index].
func get_cell_name(index: int) -> String:
	return (_cells[index].find_child("Name", true, false) as Label).text


## Lights the cell of item [param index] up, or none with -1.
func set_hovered(index: int) -> void:
	if index == _hovered:
		return
	_hovered = index
	for cell: int in _cells.size():
		_cells[cell].add_theme_stylebox_override(&"panel", _lit if cell == index else _idle)


## The item whose cell is lit, or -1.
func get_hovered() -> int:
	return _hovered


func _refresh() -> void:
	pass
