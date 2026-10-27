@tool
class_name XRESegmentRow
extends VBoxContainer
## Choices on a dark track, the one picked white, as Meta Horizon OS draws a
## segmented control (D-116). A row longer than its place scrolls sideways: the
## ray drags it and the right stick's left and right move it
## ([XREPanelSurface], D-117). A fade at an edge says there is more that way,
## and a bar under the row how much of it is in view. A choice may carry a
## count, a blue badge after its name.

const TRACK_COLOR := Color(0.165, 0.18, 0.212)
const PICKED_COLOR := Color(0.914, 0.929, 0.961)
const HOVER_COLOR := Color(1.0, 1.0, 1.0, 0.08)
const TEXT_COLOR := Color(0.761, 0.784, 0.827)
const PICKED_TEXT_COLOR := Color(0.078, 0.09, 0.114)
const BADGE_COLOR := Color(0.357, 0.525, 0.941)
## Sizes in interface pixels at editor scale 1.
const RADIUS := 16.0
const INSET := 3.0
const PADDING := Vector2(12.0, 5.0)
const FONT_SIZE := 13.0
const BADGE_FONT_SIZE := 10.5
const GAP := 6.0
## The fade: its width, and how much of it is the track's color before it clears.
const FADE_WIDTH := 44.0
const FADE_SOLID := 0.3
const BAR_SIZE := Vector2(60.0, 3.0)
const BAR_COLOR := Color(0.227, 0.247, 0.286)
const BAR_THUMB_COLOR := Color(0.663, 0.69, 0.749)
## Pixels hidden past an edge that still count as none, and the room a natural row keeps for rounding.
const OVERFLOW := 1.0
const SLACK := 2.0

var _ui_scale := 1.0
## Whether the row is as wide as its choices, at most [member _fit_width];
## otherwise it fills its place.
var _natural := false
var _fit_width := INF
## Room left and right of a choice's name.
var _pad_x := PADDING.x
var _scroll: ScrollContainer
var _choices: HBoxContainer
var _fades: Control
var _bar: Control
var _group := ButtonGroup.new()
var _buttons: Array[Button] = []
var _labels: Array[Label] = []
var _badges: Array[PanelContainer] = []
var _counts: Array[Label] = []


## A row drawn at [param ui_scale], the editor's. [param natural] rows are as
## wide as their choices, as a setting's values beside its name; the others
## fill their place, as the subsections and the controls layouts do.
## [param pad_x] is the room left and right of a choice's name.
func _init(ui_scale: float = 1.0, natural: bool = false, pad_x: float = PADDING.x) -> void:
	_ui_scale = ui_scale
	_natural = natural
	_pad_x = pad_x
	add_theme_constant_override(&"separation", roundi(GAP * ui_scale))
	var track := PanelContainer.new()
	track.name = "Track"
	track.add_theme_stylebox_override(&"panel", XREPanelSurface.meta_style(TRACK_COLOR, roundi(RADIUS * ui_scale), INSET * ui_scale))
	add_child(track)
	_scroll = ScrollContainer.new()
	_scroll.name = "Scroll"
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	# The theme's frame would take room from the choices that the row's width doesn't count.
	_scroll.add_theme_stylebox_override(&"panel", StyleBoxEmpty.new())
	_scroll.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())
	track.add_child(_scroll)
	_choices = HBoxContainer.new()
	_choices.name = "Choices"
	_choices.add_theme_constant_override(&"separation", roundi(2.0 * ui_scale))
	_choices.minimum_size_changed.connect(_fit)
	_scroll.add_child(_choices)
	# Over the choices, in the track's color: the fades at the edges.
	_fades = Control.new()
	_fades.name = "Fades"
	_fades.mouse_filter = MOUSE_FILTER_IGNORE
	_fades.draw.connect(_draw_fades)
	track.add_child(_fades)
	_bar = Control.new()
	_bar.name = "Bar"
	_bar.mouse_filter = MOUSE_FILTER_IGNORE
	_bar.custom_minimum_size = Vector2(0.0, BAR_SIZE.y * ui_scale)
	_bar.visible = false
	_bar.draw.connect(_draw_bar)
	add_child(_bar)
	var scroll_bar := _scroll.get_h_scroll_bar()
	scroll_bar.value_changed.connect(_update.unbind(1))
	scroll_bar.changed.connect(_update)
	resized.connect(_update)


## Adds a choice named [param text] at the end of the row and returns its
## button: connect its [signal BaseButton.pressed].
func add_choice(text: String) -> Button:
	var button := Button.new()
	button.toggle_mode = true
	button.button_group = _group
	button.focus_mode = FOCUS_NONE
	for state: StringName in [&"normal", &"disabled"]:
		button.add_theme_stylebox_override(state, _style(Color(1.0, 1.0, 1.0, 0.0)))
	button.add_theme_stylebox_override(&"hover", _style(HOVER_COLOR))
	button.add_theme_stylebox_override(&"pressed", _style(PICKED_COLOR))
	button.add_theme_stylebox_override(&"hover_pressed", _style(PICKED_COLOR))
	button.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())
	# A Button doesn't size to its children: the content sets its minimum size.
	var content := HBoxContainer.new()
	content.mouse_filter = MOUSE_FILTER_IGNORE
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override(&"separation", roundi(6.0 * _ui_scale))
	content.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	button.add_child(content)
	var label := Label.new()
	label.text = text
	label.mouse_filter = MOUSE_FILTER_IGNORE
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override(&"font_size", roundi(FONT_SIZE * _ui_scale))
	content.add_child(label)
	var badge := make_badge(_ui_scale)
	badge.visible = false
	content.add_child(badge)
	var padding := Vector2(_pad_x, PADDING.y) * _ui_scale * 2.0
	content.minimum_size_changed.connect(func() -> void:
		button.custom_minimum_size = content.get_combined_minimum_size() + padding)
	button.custom_minimum_size = content.get_combined_minimum_size() + padding
	button.toggled.connect(func(_on: bool) -> void: _paint())
	_choices.add_child(button)
	_buttons.append(button)
	_labels.append(label)
	_badges.append(badge)
	_counts.append(badge.get_child(0) as Label)
	_paint()
	return button


## The choices' buttons, in order.
func get_choices() -> Array[Button]:
	return _buttons


## Shows [param button] picked and the others not, without their signals.
func pick(button: Button) -> void:
	for choice: Button in _buttons:
		choice.set_pressed_no_signal(choice == button)
	_paint()


## The badge of [param button] says [param count]; none for 0.
func set_count(button: Button, count: int) -> void:
	var index := _buttons.find(button)
	if index < 0:
		return
	_badges[index].visible = count > 0
	_counts[index].text = str(count)


## Greys the row out and lets no choice be clicked, or brings it back.
func set_enabled(enabled: bool) -> void:
	for choice: Button in _buttons:
		choice.disabled = not enabled


## Caps a natural row's width at [param width]: past it, the row scrolls.
func set_fit_width(width: float) -> void:
	if _natural and not is_equal_approx(width, _fit_width):
		_fit_width = width
		_fit()


## Scrolls the row so that [param button] is in view, once it is laid out:
## the next frame, and again the one after, as a window resized with it lays out a frame later.
func reveal(button: Button) -> void:
	if is_inside_tree():
		get_tree().process_frame.connect(_scroll_to.bind(button, 2), CONNECT_ONE_SHOT)


func get_scroll() -> ScrollContainer:
	return _scroll


## Whether choices are hidden past the left edge, and past the right edge.
func has_more_left() -> bool:
	return _scroll.get_h_scroll_bar().value > OVERFLOW


func has_more_right() -> bool:
	var bar := _scroll.get_h_scroll_bar()
	return bar.value < bar.max_value - bar.page - OVERFLOW


## A blue pill with a number in it, as the counts of changed settings are drawn.
static func make_badge(ui_scale: float) -> PanelContainer:
	var badge := PanelContainer.new()
	badge.mouse_filter = MOUSE_FILTER_IGNORE
	var style := XREPanelSurface.meta_style(BADGE_COLOR, roundi(8.0 * ui_scale), 0.0)
	style.content_margin_left = 5.0 * ui_scale
	style.content_margin_right = 5.0 * ui_scale
	badge.add_theme_stylebox_override(&"panel", style)
	badge.size_flags_vertical = SIZE_SHRINK_CENTER
	var count := Label.new()
	count.mouse_filter = MOUSE_FILTER_IGNORE
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count.add_theme_color_override(&"font_color", Color.WHITE)
	count.add_theme_font_size_override(&"font_size", roundi(BADGE_FONT_SIZE * ui_scale))
	badge.add_child(count)
	return badge


func _style(color: Color) -> StyleBoxFlat:
	var style := XREPanelSurface.meta_style(color, roundi(RADIUS * _ui_scale), 0.0)
	style.content_margin_left = _pad_x * _ui_scale
	style.content_margin_right = _pad_x * _ui_scale
	style.content_margin_top = PADDING.y * _ui_scale
	style.content_margin_bottom = PADDING.y * _ui_scale
	return style


## Names dark on the picked choice, light on the others.
func _paint() -> void:
	for index: int in _buttons.size():
		_labels[index].add_theme_color_override(&"font_color", PICKED_TEXT_COLOR if _buttons[index].button_pressed else TEXT_COLOR)


## A natural row is as wide as its choices with a pixel or two to spare: at
## a fractional scale the boxes round their choices up to whole pixels.
func _fit() -> void:
	if _natural:
		custom_minimum_size.x = minf(ceilf(_choices.get_combined_minimum_size().x + INSET * _ui_scale * 2.0) + SLACK, _fit_width)


func _scroll_to(button: Button, times: int) -> void:
	if not is_instance_valid(button) or not button.is_inside_tree():
		return
	_scroll.ensure_control_visible(button)
	if times > 1:
		get_tree().process_frame.connect(_scroll_to.bind(button, times - 1), CONNECT_ONE_SHOT)


func _update() -> void:
	var bar := _scroll.get_h_scroll_bar()
	_bar.visible = bar.max_value - bar.page > OVERFLOW
	_fades.queue_redraw()
	_bar.queue_redraw()


## At an edge with more past it: the track's color, then clearing.
func _draw_fades() -> void:
	var width := minf(FADE_WIDTH * _ui_scale, _fades.size.x * 0.5)
	var solid := width * FADE_SOLID
	var height := _fades.size.y
	var clear := Color(TRACK_COLOR, 0.0)
	if has_more_left():
		_fades.draw_rect(Rect2(0.0, 0.0, solid, height), TRACK_COLOR)
		_fades.draw_polygon(PackedVector2Array([Vector2(solid, 0.0), Vector2(width, 0.0), Vector2(width, height), Vector2(solid, height)]),
				PackedColorArray([TRACK_COLOR, clear, clear, TRACK_COLOR]))
	if has_more_right():
		var right := _fades.size.x
		_fades.draw_rect(Rect2(right - solid, 0.0, solid, height), TRACK_COLOR)
		_fades.draw_polygon(PackedVector2Array([Vector2(right - width, 0.0), Vector2(right - solid, 0.0), Vector2(right - solid, height), Vector2(right - width, height)]),
				PackedColorArray([clear, TRACK_COLOR, TRACK_COLOR, clear]))


func _draw_bar() -> void:
	var bar := _scroll.get_h_scroll_bar()
	if bar.max_value <= 0.0:
		return
	var width := BAR_SIZE.x * _ui_scale
	var left := (_bar.size.x - width) * 0.5
	var radius := roundi(_bar.size.y * 0.5)
	_bar.draw_style_box(XREPanelSurface.meta_style(BAR_COLOR, radius, 0.0), Rect2(left, 0.0, width, _bar.size.y))
	_bar.draw_style_box(XREPanelSurface.meta_style(BAR_THUMB_COLOR, radius, 0.0),
			Rect2(left + width * bar.value / bar.max_value, 0.0, width * bar.page / bar.max_value, _bar.size.y))
