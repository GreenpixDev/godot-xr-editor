@tool
class_name XREBlueprintColorPanel
extends VBoxContainer
## The form of the Color window of a color token (D-064), opened near the
## head. In 2D ([constant XREFeatureSettings.PICKER]) it is Godot's color
## picker, its square, sliders and hex code; a click on a figure or on the hex
## code opens the keyboard. In 3D ([constant XREFeatureSettings.GLOBE]) it is
## a free area that the globe of colors of [XREBlueprintTokenEditor] hangs in
## front of, the saturation as a slider, and R, G, B and the hex code as
## buttons that type them. Both end in the color before and now, the pipette
## and Done. Done keeps the color; the × in the header puts it back, as the
## Vector window does (D-063).

## The × in the header was pressed: the color is put back.
signal close_pressed
## Done was pressed: the color is kept.
signal done_pressed
## The 2D picker made [param color].
signal color_picked(color: Color)
## The 3D saturation slider moved to [param value], 0 to 1.
signal saturation_changed(value: float)
## The 3D button of channel [param channel] (0 for R) was pressed: type it, 0 to 255.
signal channel_pressed(channel: int)
## The 3D hex button was pressed: type the code.
signal hex_pressed
## The pipette was turned on or off.
signal pipette_toggled(on: bool)
## A figure or the hex code of the 2D picker was clicked: [param numeric] for a figure.
signal text_edit_requested(field: LineEdit, numeric: bool)

const CHANNELS: Array[String] = ["R", "G", "B"]
const CHANNEL_COLORS: Array[Color] = [Color("ff8a8a"), Color("8be8b8"), Color("9db9ff")]

var _mode := XREFeatureSettings.PICKER
var _title: Label
var _picker: ColorPicker
var _area: Control
var _saturation_row: HBoxContainer
var _saturation: HSlider
var _channel_row: HBoxContainer
var _channels: Array[Button] = []
var _hex: Button
var _before: ColorRect
var _now: ColorRect
var _pipette: Button
var _done: Button


func _init() -> void:
	name = "ColorPanel"
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override(&"separation", 8)
	var header := HBoxContainer.new()
	add_child(header)
	_title = Label.new()
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.clip_text = true
	_title.add_theme_color_override(&"font_color", Color("a9b0bf"))
	header.add_child(_title)
	var close := Button.new()
	close.text = "×"
	close.custom_minimum_size = Vector2(48, 44)
	close.focus_mode = Control.FOCUS_NONE
	close.add_theme_font_size_override(&"font_size", 24)
	close.pressed.connect(close_pressed.emit)
	header.add_child(close)
	_picker = ColorPicker.new()
	_picker.name = "Picker"
	_picker.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_picker.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# The pipette of the window samples the scene; the picker's own samples the screen, which a headset has not.
	_picker.sampler_visible = false
	_picker.presets_visible = false
	_picker.can_add_swatches = false
	_picker.color_changed.connect(color_picked.emit)
	add_child(_picker)
	_hook_fields(_picker)
	_area = Control.new()
	_area.name = "Globe"
	_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_area)
	_saturation_row = HBoxContainer.new()
	_saturation_row.add_theme_constant_override(&"separation", 10)
	add_child(_saturation_row)
	var label := Label.new()
	label.text = "Saturation"
	_saturation_row.add_child(label)
	_saturation = HSlider.new()
	_saturation.min_value = 0.0
	_saturation.max_value = 1.0
	_saturation.step = 0.01
	_saturation.custom_minimum_size = Vector2(0, 40)
	_saturation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_saturation.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_saturation.focus_mode = Control.FOCUS_NONE
	_saturation.value_changed.connect(saturation_changed.emit)
	_saturation_row.add_child(_saturation)
	_channel_row = HBoxContainer.new()
	_channel_row.add_theme_constant_override(&"separation", 6)
	add_child(_channel_row)
	for channel: int in 3:
		var button := Button.new()
		button.custom_minimum_size = Vector2(76, 44)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override(&"font_size", 19)
		button.add_theme_color_override(&"font_color", CHANNEL_COLORS[channel])
		button.tooltip_text = "Type %s, 0 to 255" % CHANNELS[channel]
		button.pressed.connect(channel_pressed.emit.bind(channel))
		_channel_row.add_child(button)
		_channels.append(button)
	_hex = Button.new()
	_hex.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hex.custom_minimum_size = Vector2(0, 44)
	_hex.focus_mode = Control.FOCUS_NONE
	_hex.add_theme_font_size_override(&"font_size", 19)
	_hex.tooltip_text = "Type the hex code"
	_hex.pressed.connect(hex_pressed.emit)
	_channel_row.add_child(_hex)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override(&"separation", 10)
	add_child(buttons)
	var swatch := HBoxContainer.new()
	swatch.add_theme_constant_override(&"separation", 0)
	swatch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(swatch)
	_before = ColorRect.new()
	_before.tooltip_text = "Before"
	_now = ColorRect.new()
	_now.tooltip_text = "Now"
	for rect: ColorRect in [_before, _now]:
		rect.custom_minimum_size = Vector2(0, 48)
		rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		swatch.add_child(rect)
	_pipette = Button.new()
	_pipette.toggle_mode = true
	_pipette.custom_minimum_size = Vector2(116, 48)
	_pipette.focus_mode = Control.FOCUS_NONE
	_pipette.tooltip_text = "Take the pipette in your hand: click an object, a card or a window for its own color, not darkened"
	_pipette.toggled.connect(pipette_toggled.emit)
	buttons.add_child(_pipette)
	_done = Button.new()
	_done.text = "Done"
	_done.custom_minimum_size = Vector2(96, 48)
	_done.focus_mode = Control.FOCUS_NONE
	_done.pressed.connect(done_pressed.emit)
	buttons.add_child(_done)
	set_mode(_mode)
	set_pipette(false)


## Every line edit inside [param node], the picker's own included: a click on
## one asks for the keyboard, a numeric one for the keypad.
func _hook_fields(node: Node) -> void:
	for child: Node in node.get_children(true):
		if child is LineEdit:
			var field := child as LineEdit
			field.gui_input.connect(_field_input.bind(field, field.get_parent() is SpinBox))
		_hook_fields(child)


func _field_input(event: InputEvent, field: LineEdit, numeric: bool) -> void:
	var mouse := event as InputEventMouseButton
	if mouse != null and mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
		text_edit_requested.emit(field, numeric)


## Shows the picker in 2D ([constant XREFeatureSettings.PICKER]), or the area,
## the slider and the buttons of the globe in 3D.
func set_mode(mode: StringName) -> void:
	_mode = mode
	var globe := mode == XREFeatureSettings.GLOBE
	_picker.visible = not globe
	_area.visible = globe
	_saturation_row.visible = globe
	_channel_row.visible = globe


## The mode shown: [constant XREFeatureSettings.PICKER] or [constant XREFeatureSettings.GLOBE].
func get_mode() -> StringName:
	return _mode


## The size of the window for the mode shown, in interface pixels: around
## the globe, or as large as the picker needs, with room for the frame's
## margins and the picker's own rows, which grow past its minimum.
func window_size() -> Vector2:
	if _mode == XREFeatureSettings.GLOBE: return Vector2(380, 470)
	var needed := get_combined_minimum_size() + Vector2(40, 100)
	return Vector2(maxf(400, needed.x), maxf(700, needed.y))


## Shows what is edited, [param title], in [param mode], [param color] both before and now.
func show_color(title: String, color: Color, mode: StringName, saturation: float = -1.0) -> void:
	_title.text = title
	set_mode(mode)
	_before.color = color
	set_color(color, saturation)
	set_pipette(false)


## Shows [param color] as the color now: on the picker, the swatch and the
## buttons; the slider at [param saturation] unless it is negative.
func set_color(color: Color, saturation: float = -1.0) -> void:
	if not _picker.color.is_equal_approx(color): _picker.color = color
	_now.color = color
	var values := [color.r8, color.g8, color.b8]
	for channel: int in 3: _channels[channel].text = "%s %d" % [CHANNELS[channel], values[channel]]
	_hex.text = "#" + color.to_html(false)
	if saturation >= 0.0: _saturation.set_value_no_signal(saturation)


## Shows the pipette taken or put back on its button, without its signal:
## Pipette takes it, Put back drops it (D-065).
func set_pipette(on: bool) -> void:
	_pipette.set_pressed_no_signal(on)
	_pipette.text = "Put back" if on else "Pipette"


## The centre of the free area, in interface pixels of the window, where the globe stands.
func area_center() -> Vector2:
	return _area.get_global_rect().get_center()


## The parts, to use in a test.
func get_picker() -> ColorPicker:
	return _picker


func get_done_button() -> Button:
	return _done


func get_pipette_button() -> Button:
	return _pipette


func get_channel_button(channel: int) -> Button:
	return _channels[channel]


func get_hex_button() -> Button:
	return _hex


func get_saturation_slider() -> HSlider:
	return _saturation


## The color now and before, as the swatch shows them.
func get_shown() -> Color:
	return _now.color


func get_before() -> Color:
	return _before.color
