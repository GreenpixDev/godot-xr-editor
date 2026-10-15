@tool
class_name XREFPSWidget
extends XREPanelSurface
## Optional performance screen backed by session main-loop intervals, not compositor FPS.

signal close_requested

var history: XREFPSHistory
var _session: XRESession
var _number: Label
var _state: Label
var _chart: XREFPSChart


func _init(theme: Theme = null, logical_size: Vector2 = Vector2(500, 340), pixel_size: float = 0.0005, render_scale: float = 1.5) -> void:
	super(logical_size, pixel_size, render_scale, theme)
	name = "FPSWidget"
	var layout_scale := logical_size.x / 500.0
	var column := VBoxContainer.new()
	root.add_child(column)
	_number = Label.new()
	_number.add_theme_font_size_override(&"font_size", roundi(22 * layout_scale))
	_number.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_number)
	_state = Label.new()
	_state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_state)
	_chart = XREFPSChart.new()
	_chart.ui_scale = layout_scale
	_chart.custom_minimum_size.y = 120 * layout_scale
	_chart.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_chart)
	var legend := Label.new()
	legend.text = "Blue: mean FPS · Orange: longest interval\nSource: XRESession main loop, not compositor delivery.\nUse --xre-session-frames for CPU/GPU CSV."
	legend.add_theme_font_size_override(&"font_size", roundi(13 * layout_scale))
	legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(legend)
	var close := Button.new()
	close.text = "Close FPS"
	close.pressed.connect(close_requested.emit)
	column.add_child(close)
	set_shown(false)


## Connects a live session once; no tree lookup or history allocation during sampling.
func setup(session: XRESession) -> void:
	if history != null and history.changed.is_connected(_update): history.changed.disconnect(_update)
	_session = session
	history = session.fps_history if session != null else null
	_chart.history = history
	if history != null: history.changed.connect(_update)
	_update()


func _exit_tree() -> void:
	if history != null and history.changed.is_connected(_update): history.changed.disconnect(_update)


func set_shown(shown: bool) -> void:
	var changed := shown != is_shown()
	super(shown)
	if changed and shown and is_instance_valid(_number): _update()


func _update() -> void:
	if not is_shown(): return
	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	if history == null:
		_chart.refresh_rate = 0.0
		_chart.queue_redraw()
		_number.text = "FPS: no live XR session"
		_state.text = "Unavailable"
		return
	_number.text = "Main loop: %.1f FPS · slowest %.1f ms" % [history.latest_fps, history.latest_worst_ms] if history.focused and history.latest_fps > 0 else "Main loop FPS: waiting for FOCUSED"
	var xr := _session.get_xr_interface()
	var refresh := xr.display_refresh_rate if xr != null else 0.0
	_chart.refresh_rate = refresh if refresh > 0.0 and is_finite(refresh) else 0.0
	var display := "%.1f Hz" % refresh if _chart.refresh_rate > 0 else "unknown"
	_state.text = "%s · display %s · t=%.2f s" % [_session.session_state_text(), display, Time.get_ticks_usec() / 1000000.0]
	_chart.queue_redraw()
