@tool
class_name XREPanelWindow
extends XREPanelSurface
## A tab opened as a window, drawn as Meta Horizon OS draws an app's window
## (docs/decisions.md, D-016, D-041, D-042): the tab fills a dark frame with
## large rounded corners, without a title bar, and a pill-shaped control bar
## under the window's bottom edge holds the tab's icon and title and the
## window's buttons — pin it to a hand ([signal pin_requested]; the router
## picks the hand by who clicked), or make a pinned one a window again
## ([signal unpin_requested]), and close ([signal close_requested]).
## [method get_pin_button] and [method get_unpin_button] give the first two.
## The control bar shows while a ray is on the window or on the bar, and for
## a moment after, so that the ray can go down to it. [XREPanels] places and
## moves the window, also by its corner handles (D-040) and by the bar.
##
## A window is rig-locked (docs/vr_ui.md): it goes along when the user flies
## or turns with the sticks, not with the head, and it stays when another
## scene is opened. Pinned to a hand, it is hand-locked and compact: laid out
## smaller, with smaller pixels, and without corner handles
## ([method set_pin]).

## Emitted when the close button is clicked.
signal close_requested
## Emitted when the pin button of the control bar is clicked: the window goes
## to a hand, which the click's hand decides ([XREPanels]).
signal pin_requested
## Emitted when a pinned window's control bar asks for it to be a window again.
signal unpin_requested

## Where a window is.
enum Pin {
	## In the scene, where the user put it: rig-locked.
	WINDOW,
	## On a forearm: hand-locked.
	LEFT_HAND,
	RIGHT_HAND,
}

## Corner radius of the window's frame, in interface pixels at editor scale 1.
const WINDOW_RADIUS := 24
## The control bar at editor scale 1, in interface pixels, and the gap between
## it and the window, in meters. The bar is narrower than the space between
## the bottom corner handles' zones, so that the handles stay free.
const BAR_SIZE := Vector2(320.0, 52.0)
const BAR_GAP := 0.012
const BAR_COLOR := Color(0.08, 0.09, 0.1, 0.94)
## How long the control bar stays after the last ray left the window, in microseconds.
const BAR_LINGER_USEC := 600000
## A round button of the control bar and its glyph, in interface pixels at editor scale 1.
const BUTTON_SIZE := 36.0
const GLYPH_SIZE := 24.0
const ICON_SIZE := 26.0

## The tab the window shows; it is the window's own.
var tab: XREPanelTab
## Where the window is, a [enum Pin].
var pin := Pin.WINDOW

var _close: Button
var _bar: XREPanelSurface
var _bar_size: Vector2
var _pin: Button
var _unpin: Button
var _hovered_usec := -BAR_LINGER_USEC


func _init(content: XREPanelTab, logical_size: Vector2, pixel_size: float, render_scale: float, theme: Theme) -> void:
	super(logical_size, pixel_size, render_scale, theme)
	tab = content
	var layout_scale := logical_size.x / XREPanels.WINDOW_SIZE.x
	corner_radius = roundi(WINDOW_RADIUS * layout_scale)
	root.add_theme_stylebox_override(&"panel", meta_style(META_WINDOW_COLOR, corner_radius, 12.0 * layout_scale))
	root.add_child(tab)
	pointer_released.connect(tab.end_edit)
	add_corner_handles()

	_bar_size = BAR_SIZE * layout_scale
	_bar = XREPanelSurface.new(_bar_size, pixel_size, render_scale, theme)
	_bar.name = "ControlBar"
	_bar.root.add_theme_stylebox_override(&"panel", meta_style(BAR_COLOR, roundi(_bar_size.y * 0.5),
			8.0 * layout_scale))
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", roundi(4 * layout_scale))
	_bar.root.add_child(row)
	var icon := TextureRect.new()
	icon.texture = XRETabIcons.tab(tab.get_symbol(), roundi(ICON_SIZE * layout_scale * render_scale))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2.ONE * ICON_SIZE * layout_scale
	row.add_child(icon)
	var title := Label.new()
	title.name = "Title"
	title.text = tab.get_title()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.add_theme_color_override(&"font_color", Color.WHITE)
	if theme != null and theme.has_font(&"bold", &"EditorFonts"):
		title.add_theme_font_override(&"font", theme.get_font(&"bold", &"EditorFonts"))
	row.add_child(title)
	var glyph_px := roundi(GLYPH_SIZE * layout_scale * render_scale)
	_pin = _round_button(row, "Pin to a hand", &"pin", glyph_px, layout_scale)
	_pin.name = "Pin"
	_pin.pressed.connect(pin_requested.emit)
	_unpin = _round_button(row, "Make it a window", &"window", glyph_px, layout_scale)
	_unpin.name = "Unpin"
	_unpin.pressed.connect(unpin_requested.emit)
	_close = _round_button(row, XREPanelTab.editor_text("Close"), &"close", glyph_px, layout_scale)
	_close.name = "Close"
	_close.pressed.connect(close_requested.emit)
	add_child(_bar)
	_bar.set_shown(false)
	_update_bar()


func get_close_button() -> Button:
	return _close


## The control bar under the window, a panel of its own that the pointer router drives.
func get_bar() -> XREPanelSurface:
	return _bar


## The control bar's button that pins the window to a hand; shown on a window.
func get_pin_button() -> Button:
	return _pin


## The control bar's button that makes a pinned window a window again; shown on a pinned one.
func get_unpin_button() -> Button:
	return _unpin


## Whether the window is pinned to a hand.
func is_pinned() -> bool:
	return pin != Pin.WINDOW


## Puts the window at [param where], a [enum Pin], laid out [param logical_size]
## interface pixels large, each [param pixel_size] meters: the router passes a
## compact size for a hand. Corner handles are only a window's.
func set_pin(where: int, logical_size: Vector2, pixel_size: float) -> void:
	pin = where as Pin
	pointer_exit()
	_bar.pointer_exit()
	resize(logical_size, pixel_size)
	_bar.resize(_bar_size, pixel_size)
	set_handles_enabled(where == Pin.WINDOW)
	_update_bar()


## Tells the window that a ray is on it or on its control bar this frame
## ([method XREPanelSurface.hover_handles]): the bar shows.
func hover_handles(corner: int) -> void:
	_hovered_usec = Time.get_ticks_usec()
	super(corner)


func set_overlay(enabled: bool) -> void:
	super(enabled)
	_bar.set_overlay(enabled)


func _process(delta: float) -> void:
	super(delta)
	_bar.set_shown(Time.get_ticks_usec() - _hovered_usec < BAR_LINGER_USEC or _bar.is_pressed())


## A round icon button of the control bar, lit while the ray is on it.
func _round_button(row: HBoxContainer, tooltip: String, glyph_name: StringName, glyph_px: int,
		layout_scale: float) -> Button:
	var button := Button.new()
	button.tooltip_text = tooltip
	button.icon = XRETabIcons.glyph(glyph_name, glyph_px)
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.custom_minimum_size = Vector2.ONE * BUTTON_SIZE * layout_scale
	var radius := roundi(BUTTON_SIZE * layout_scale * 0.5)
	var margin := (BUTTON_SIZE - GLYPH_SIZE) * 0.5 * layout_scale
	button.add_theme_stylebox_override(&"normal", meta_style(Color(1.0, 1.0, 1.0, 0.0), radius, margin))
	button.add_theme_stylebox_override(&"hover", meta_style(Color(1.0, 1.0, 1.0, 0.16), radius, margin))
	button.add_theme_stylebox_override(&"pressed", meta_style(Color(1.0, 1.0, 1.0, 0.28), radius, margin))
	button.add_theme_stylebox_override(&"hover_pressed", meta_style(Color(1.0, 1.0, 1.0, 0.28), radius, margin))
	button.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())
	row.add_child(button)
	return button


## Shows pin on a window and unpin on a pinned one, and puts the bar under it.
func _update_bar() -> void:
	_pin.visible = pin == Pin.WINDOW
	_unpin.visible = pin != Pin.WINDOW
	_bar.position = Vector3(0.0, -(size_m.y + _bar.size_m.y) * 0.5 - BAR_GAP, 0.0)
