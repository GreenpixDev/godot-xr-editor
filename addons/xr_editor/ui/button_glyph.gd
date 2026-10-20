@tool
class_name XREButtonGlyph
extends Control
## Icon of a controller button ([constant XREFeatureSettings.BUTTONS]), drawn
## as a game shows a gamepad's: a round face button in its color with its
## letter, a stick with a ring and LS or RS, or the menu button: a dark circle
## with three lines (D-050). Sized to the theme's font.

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

## The button drawn, a key of [constant XREFeatureSettings.BUTTONS].
var button := &"":
	set(value):
		button = value
		queue_redraw()


func _init(shown: StringName = &"") -> void:
	button = shown
	mouse_filter = MOUSE_FILTER_IGNORE
	size_flags_vertical = SIZE_SHRINK_CENTER


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED or what == NOTIFICATION_ENTER_TREE:
		custom_minimum_size = Vector2.ONE * roundf(get_theme_default_font_size() * _SIZE)


func _draw() -> void:
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
