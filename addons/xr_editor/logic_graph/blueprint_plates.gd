@tool
class_name XREBlueprintPlates
extends ScrollContainer
## The graph's own functions as plates in the Functions window (D-148,
## docs/blueprint_functions.md): every function of the file, called or not. A
## plate shows ƒ, the function's name, its signature and, in its corner, how
## many calls it has; under the ray its trash too. Last, a dashed plate with +ƒ
## makes a new function. The form of [XREBlueprintFunctionsTab]: see-through,
## drawn over the scene and the cards, moved by its Control Bar as any window.
##
## The trigger on a plate shows its body; the grip takes a call of it out
## ([XREBlueprints] reads [method plate_at]); the trash deletes a function
## without calls. The plate of the body shown is lit.

## Emitted by the trigger on a plate.
signal open_requested(name: String)
## Emitted by the plus plate.
signal create_requested
## Emitted by a plate's trash.
signal delete_requested(name: String)
## Emitted when the number of plates changed: the window's height follows.
signal size_changed

## A plate in interface pixels: the mockup's 180 × 46 points, 20 × 5.5 cm at the
## windows' pixel size; the gap between plates; the window's margin.
const PLATE_SIZE := Vector2(224.0, 62.0)
const GAP := 8.0
const MARGIN := 16.0
## The tallest the window grows; more plates scroll.
const MOST_ROWS := 7
const BADGE_SIZE := 26.0
## The plates' colors: a function's teal, a pure one's green, as their calls.
const TEAL := Color("6fd3dc")
const GREEN := Color("7be5b3")
const FILL := Color("123e45")
const PURE_FILL := Color("161c28")
const DASH := Color("7d8597")

class Plate:
	var name := ""
	var button: Button
	var trash: Button

var _plates: Array[Plate] = []
var _plus: Button
var _column: VBoxContainer
var _rows := -1


func _init() -> void:
	name = "Plates"
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_column = VBoxContainer.new()
	_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_column.add_theme_constant_override(&"separation", int(GAP))
	add_child(_column)


## Builds a plate for each function of [param owner], the file's graph, and the
## plus plate after them; [param opened] is the function whose body is shown,
## empty for none.
func rebuild(owner: XREBlueprintGraph, opened: String) -> void:
	for child: Node in _column.get_children():
		_column.remove_child(child)
		child.queue_free()
	_plates.clear()
	for entry: Dictionary in owner.functions:
		_add_plate(owner, entry, str(entry["name"]) == opened)
	_plus = Button.new()
	_plus.name = "NewFunction"
	_plus.custom_minimum_size = Vector2(PLATE_SIZE.x, PLATE_SIZE.y * 0.8)
	_plus.text = "+ƒ"
	_plus.tooltip_text = "New function"
	_plus.add_theme_font_size_override(&"font_size", 24)
	_plus.add_theme_color_override(&"font_color", Color("c8cdd8"))
	for state: StringName in [&"normal", &"hover", &"pressed", &"focus"]:
		_plus.add_theme_stylebox_override(state, XREPanelSurface.meta_style(Color(1, 1, 1, 0.1 if state == &"hover" else 0.03), 12, 4.0))
	_plus.pressed.connect(func() -> void: create_requested.emit())
	_plus.draw.connect(_draw_dashes)
	_column.add_child(_plus)
	if _rows != _plates.size():
		_rows = _plates.size()
		size_changed.emit()


## The window's size in interface pixels: as tall as its plates, up to [constant MOST_ROWS].
func window_size() -> Vector2:
	var rows := mini(_plates.size(), MOST_ROWS)
	return Vector2(PLATE_SIZE.x + MARGIN * 2.0 + 12.0, rows * (PLATE_SIZE.y + GAP) + PLATE_SIZE.y * 0.8 + MARGIN * 2.0)


func _draw_dashes() -> void:
	var rect := Rect2(Vector2.ONE * 2.0, _plus.size - Vector2.ONE * 4.0)
	var corners := PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])
	for index: int in 4:
		_plus.draw_dashed_line(corners[index], corners[(index + 1) % 4], DASH, 2.0, 8.0)


func _add_plate(owner: XREBlueprintGraph, entry: Dictionary, lit: bool) -> void:
	var pure := bool(entry.get("pure", false))
	var color := GREEN if pure else TEAL
	var plate := Plate.new()
	plate.name = str(entry["name"])
	plate.button = Button.new()
	plate.button.name = "Plate_" + plate.name
	plate.button.custom_minimum_size = PLATE_SIZE
	plate.button.tooltip_text = "Open " + plate.name
	for state: StringName in [&"normal", &"hover", &"pressed", &"focus"]:
		var style := XREPanelSurface.meta_style((PURE_FILL if pure else FILL).lightened(0.12 if state == &"hover" else 0.0), 12, 6.0)
		style.set_border_width_all(3 if lit else 2)
		style.border_color = Color.WHITE if lit else color
		plate.button.add_theme_stylebox_override(state, style)
	plate.button.pressed.connect(func() -> void: open_requested.emit(plate.name))
	_column.add_child(plate.button)
	var sign := _label("ƒ", 26, color)
	sign.position = Vector2(12, 10)
	plate.button.add_child(sign)
	var title := _label(plate.name, 20, Color.WHITE)
	title.position = Vector2(38, 6)
	plate.button.add_child(title)
	var shape := _label(signature_text(entry), 15, Color(1, 1, 1, 0.62))
	shape.position = Vector2(38, 32)
	plate.button.add_child(shape)
	# How many calls it has, in its corner: none dim.
	var calls := XREBlueprintUserFunctions.count_calls(owner, plate.name)
	var count := _label(str(calls), 15, Color(1, 1, 1, 1.0 if calls > 0 else 0.6))
	count.name = "Count"
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	count.size = Vector2.ONE * BADGE_SIZE
	count.position = Vector2(PLATE_SIZE.x - BADGE_SIZE - 6.0, 6.0)
	var badge := XREPanelSurface.meta_style(Color("1d2026") if calls > 0 else Color("2a2e36"), int(BADGE_SIZE * 0.5), 0.0)
	badge.set_border_width_all(2)
	badge.border_color = color if calls > 0 else Color(1, 1, 1, 0.25)
	count.add_theme_stylebox_override(&"normal", badge)
	plate.button.add_child(count)
	plate.trash = Button.new()
	plate.trash.name = "Trash"
	plate.trash.icon = XRETabIcons.glyph(&"trash", 22)
	plate.trash.tooltip_text = "Delete " + plate.name
	plate.trash.flat = true
	plate.trash.size = Vector2(30, 30)
	plate.trash.position = Vector2(PLATE_SIZE.x - 36.0, PLATE_SIZE.y - 32.0)
	plate.trash.visible = false
	plate.trash.pressed.connect(func() -> void: delete_requested.emit(plate.name))
	plate.button.add_child(plate.trash)
	# The trash shows under the ray, as a card's does.
	plate.button.mouse_entered.connect(func() -> void: plate.trash.visible = true)
	# The trash is the plate's child: the ray on it is off the plate for the plate, but not for the trash.
	plate.button.mouse_exited.connect(func() -> void: plate.trash.visible = plate.button.get_global_rect().has_point(plate.button.get_global_mouse_position()))
	plate.trash.mouse_exited.connect(func() -> void: plate.trash.visible = plate.button.get_global_rect().has_point(plate.button.get_global_mouse_position()))
	_plates.append(plate)


static func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override(&"font_size", size)
	label.add_theme_color_override(&"font_color", color)
	return label


## What a plate says under the name: its inputs, an arrow and its outputs.
static func signature_text(entry: Dictionary) -> String:
	var inputs := ", ".join(PackedStringArray(XREBlueprintUserFunctions.names_of(entry.get("inputs", []))))
	var outputs := ", ".join(PackedStringArray(XREBlueprintUserFunctions.names_of(entry.get("outputs", []))))
	return "(%s)%s" % [inputs, " → " + outputs if not outputs.is_empty() else ""]


## The function of the plate at interface pixel [param pixel] of the window,
## not on its trash; empty for the plus plate or none.
func plate_at(pixel: Vector2) -> String:
	if not get_global_rect().has_point(pixel): return ""
	for plate: Plate in _plates:
		if plate.button.get_global_rect().has_point(pixel) and not (plate.trash.visible and plate.trash.get_global_rect().has_point(pixel)): return plate.name
	return ""


## Function [param name]'s plate, or null; the plus plate.
func get_plate(name: String) -> Button:
	for plate: Plate in _plates:
		if plate.name == name: return plate.button
	return null


func get_plus() -> Button:
	return _plus


## Function [param name]'s plate's trash, or null.
func get_trash(name: String) -> Button:
	for plate: Plate in _plates:
		if plate.name == name: return plate.trash
	return null


func plate_count() -> int:
	return _plates.size()
