@tool
class_name XREBlueprintVectorPanel
extends VBoxContainer
## The form of the Vector window (D-061): what is edited, a free area that
## the 3D arrows of [XREBlueprintTokenEditor] hang in front of — as the
## Objects window has its miniatures (D-045) — the components in figures, and
## Zero, Normalize and Done under them. The window moves by its corner
## handles. Each component is a button (D-062): it opens the keypad for that
## one component, the rare exact value; the small 0 beside it zeroes it.
## Done keeps the vector; the × in the header puts it back (D-063).

## Zero or Normalize was pressed.
signal zero_pressed
signal normalize_pressed
## The button of component [param axis] (0 for X) was pressed: type it.
signal component_pressed(axis: int)
## The × in the header was pressed: the vector is put back.
signal close_pressed
## Done was pressed: the vector is kept.
signal done_pressed
## The small 0 beside component [param axis] was pressed.
signal component_zero_pressed(axis: int)

var _title: Label
var _area: Control
var _components: Array[Button] = []
var _zeros: Array[Button] = []
var _done: Button


func _init() -> void:
	name = "VectorPanel"
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override(&"separation", 8)
	var header := HBoxContainer.new()
	add_child(header)
	_title = Label.new()
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.add_theme_color_override(&"font_color", Color("a9b0bf"))
	header.add_child(_title)
	var close := Button.new()
	close.text = "×"
	close.custom_minimum_size = Vector2(48, 44)
	close.focus_mode = Control.FOCUS_NONE
	close.add_theme_font_size_override(&"font_size", 24)
	close.pressed.connect(close_pressed.emit)
	header.add_child(close)
	_area = Control.new()
	_area.name = "Arrows"
	_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_area)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 6)
	add_child(row)
	for axis: int in 3:
		var pair := HBoxContainer.new()
		pair.add_theme_constant_override(&"separation", 2)
		row.add_child(pair)
		var component := Button.new()
		component.custom_minimum_size = Vector2(84, 44)
		component.focus_mode = Control.FOCUS_NONE
		component.clip_text = true
		component.add_theme_font_size_override(&"font_size", 19)
		component.add_theme_color_override(&"font_color", XREBlueprintTokenEditor.AXIS_COLORS[axis].lightened(0.3))
		component.tooltip_text = "Type %s" % ["X", "Y", "Z"][axis]
		component.pressed.connect(component_pressed.emit.bind(axis))
		pair.add_child(component)
		_components.append(component)
		var zero := Button.new()
		zero.text = "0"
		zero.custom_minimum_size = Vector2(28, 44)
		zero.focus_mode = Control.FOCUS_NONE
		zero.add_theme_font_size_override(&"font_size", 16)
		zero.add_theme_color_override(&"font_color", Color("a9b0bf"))
		zero.tooltip_text = "%s to 0" % ["X", "Y", "Z"][axis]
		zero.pressed.connect(component_zero_pressed.emit.bind(axis))
		pair.add_child(zero)
		_zeros.append(zero)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override(&"separation", 10)
	add_child(buttons)
	for entry: Array in [["Zero", zero_pressed], ["Normalize", normalize_pressed], ["Done", done_pressed]]:
		var button := Button.new()
		button.text = entry[0]
		button.custom_minimum_size = Vector2(104, 48)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect((entry[1] as Signal).emit)
		buttons.add_child(button)
		if entry[0] == "Done": _done = button


## Shows what is edited, [param title], and its value [param value], typed as
## [param expression] (components apart by commas) or empty.
func show_vector(title: String, value: Variant, expression: String = "") -> void:
	_title.text = title
	set_vector(value, expression)


## Shows the components of [param value] on their buttons, each as it was
## typed in [param expression] if it was (D-063); a Vector2 has no Z.
func set_vector(value: Variant, expression: String = "") -> void:
	var count := 2 if value is Vector2 else 3
	for axis: int in 3:
		(_components[axis].get_parent() as Control).visible = axis < count
		if axis >= count: continue
		var typed := XREBlueprintTokens.component_expression(expression, axis)
		_components[axis].text = "%s %s" % [["X", "Y", "Z"][axis], XREBlueprintTokens.component_shown(typed) if not typed.is_empty() else XREBlueprintTokens.text(float(value[axis]), "")]


## The components as their buttons say them, apart: "X 1    Y 0.5    Z 0".
func components_text() -> String:
	var parts: PackedStringArray = []
	for component: Button in _components:
		if (component.get_parent() as Control).visible: parts.append(component.text)
	return "    ".join(parts)


## The button of component [param axis], to click in a test.
func get_component_button(axis: int) -> Button:
	return _components[axis]


## The small 0 beside component [param axis], to click in a test.
func get_zero_button(axis: int) -> Button:
	return _zeros[axis]


## Done, to click in a test.
func get_done_button() -> Button:
	return _done


## The centre of the free area, in interface pixels of the window, where the arrows stand.
func area_center() -> Vector2:
	var rect := _area.get_global_rect()
	return rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.62)
