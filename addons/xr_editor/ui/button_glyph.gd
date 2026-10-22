@tool
class_name XREButtonGlyph
extends Control
## Icon of a controller button ([constant XREFeatureSettings.BUTTONS]), drawn
## as a game shows a gamepad's: a round face button in its color with its
## letter, a stick with a ring and LS or RS, or the menu button: a dark circle
## with three lines (D-050). Sized to the theme's font. With [member keyboard],
## the key that stands for the button without a headset, as a keycap (D-057).

## Face button colors by letter, as on an Xbox controller.
const COLORS: Dictionary[String, Color] = {
	"A": Color(0.33, 0.69, 0.2),
	"B": Color(0.86, 0.2, 0.18),
	"X": Color(0.16, 0.45, 0.88),
	"Y": Color(0.95, 0.74, 0.1),
}
const _STICK_COLOR := Color(0.24, 0.25, 0.28)
const _RING_COLOR := Color(0.78, 0.79, 0.82)
## The glyph's diameter, in the theme's font sizes.
const _SIZE := 1.6
const _KEYCAP_COLOR := Color(0.86, 0.87, 0.9)
const _KEYCAP_TEXT_COLOR := Color(0.12, 0.13, 0.15)

## The button drawn, a key of [constant XREFeatureSettings.BUTTONS].
var button := &"":
	set(value):
		button = value
		_resize()
## Draws the key of the button ([method XRESimulator.key_label]) instead of the button.
var keyboard := false:
	set(value):
		keyboard = value
		_resize()


func _init(shown: StringName = &"") -> void:
	button = shown
	mouse_filter = MOUSE_FILTER_IGNORE
	size_flags_vertical = SIZE_SHRINK_CENTER


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED or what == NOTIFICATION_ENTER_TREE:
		_resize()


## A keycap is as wide as its key's name.
func _resize() -> void:
	var height := roundf(get_theme_default_font_size() * _SIZE)
	var width := height
	if keyboard:
		var font_size := int(height * 0.5)
		var text := XRESimulator.key_label(button)
		width = maxf(height, get_theme_default_font().get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + height * 0.6)
	custom_minimum_size = Vector2(width, height)
	queue_redraw()


func _draw() -> void:
	if keyboard:
		_draw_keycap()
		return
	var letter := XREFeatureSettings.button_glyph(button)
	if letter.is_empty():
		return
	var center := size / 2.0
	var radius := minf(size.x, size.y) / 2.0 - 1.0
	if letter == "≡":
		draw_circle(center, radius, _STICK_COLOR, true, -1.0, true)
		var half := radius * 0.42
		var width := maxf(1.0, radius * 0.14)
		for row: int in 3:
			var y := center.y + (row - 1) * radius * 0.32
			draw_line(Vector2(center.x - half, y), Vector2(center.x + half, y), _RING_COLOR, width, true)
		return
	var stick := letter.length() > 1
	var text_color := Color.WHITE
	if stick:
		draw_circle(center, radius, _STICK_COLOR, true, -1.0, true)
		draw_arc(center, radius * 0.82, 0.0, TAU, 32, _RING_COLOR, maxf(1.0, radius * 0.1), true)
	else:
		draw_circle(center, radius, COLORS.get(letter, _STICK_COLOR), true, -1.0, true)
		if letter == "Y":
			text_color = Color(0.15, 0.12, 0.05)
	var font := get_theme_default_font()
	var font_size := int(radius * (0.95 if stick else 1.2))
	var text_size := font.get_string_size(letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var baseline := center.y + (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	draw_string(font, Vector2(center.x - text_size.x / 2.0, baseline), letter, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)


func _draw_keycap() -> void:
	var text := XRESimulator.key_label(button)
	if text.is_empty():
		return
	var rect := Rect2(Vector2.ONE, size - Vector2.ONE * 2.0)
	var box := StyleBoxFlat.new()
	box.bg_color = _KEYCAP_COLOR
	box.set_corner_radius_all(int(rect.size.y * 0.2))
	box.border_color = _KEYCAP_COLOR.darkened(0.35)
	box.border_width_bottom = maxi(2, int(rect.size.y * 0.08))
	draw_style_box(box, rect)
	var font := get_theme_default_font()
	var font_size := int(size.y * 0.5)
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var baseline := size.y / 2.0 + (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0 - 1.0
	draw_string(font, Vector2((size.x - text_size.x) / 2.0, baseline), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, _KEYCAP_TEXT_COLOR)
