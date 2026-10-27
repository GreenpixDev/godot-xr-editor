@tool
class_name XRESwitch
extends Button
## An On and Off switch as Meta Horizon OS draws one (D-116): a grey pill,
## blue when on, its white knob then at the right.

## Sizes in interface pixels at editor scale 1.
const SIZE := Vector2(46.0, 27.0)
const KNOB := 21.0
const INSET := 3.0
const OFF_COLOR := Color(0.227, 0.247, 0.286)
const ON_COLOR := Color(0.357, 0.525, 0.941)
const KNOB_COLOR := Color(0.914, 0.929, 0.961)

var _ui_scale := 1.0


func _init(ui_scale: float = 1.0) -> void:
	_ui_scale = ui_scale
	toggle_mode = true
	focus_mode = FOCUS_NONE
	custom_minimum_size = SIZE * ui_scale
	for state: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"disabled", &"focus"]:
		add_theme_stylebox_override(state, StyleBoxEmpty.new())
	toggled.connect(func(_on: bool) -> void: queue_redraw())


## Shows the switch on or off without its signals.
func show_on(on: bool) -> void:
	set_pressed_no_signal(on)
	queue_redraw()


func _draw() -> void:
	var track := Rect2(Vector2(0.0, (size.y - SIZE.y * _ui_scale) * 0.5), SIZE * _ui_scale)
	draw_style_box(XREPanelSurface.meta_style(ON_COLOR if button_pressed else OFF_COLOR, roundi(SIZE.y * 0.5 * _ui_scale), 0.0), track)
	var radius := KNOB * 0.5 * _ui_scale
	var left := track.position.x + INSET * _ui_scale + ((SIZE.x - KNOB - INSET * 2.0) * _ui_scale if button_pressed else 0.0)
	draw_circle(Vector2(left + radius, track.get_center().y), radius, KNOB_COLOR, true, -1.0, true)
