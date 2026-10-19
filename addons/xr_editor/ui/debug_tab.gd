@tool
class_name XREDebugTab
extends XREPanelTab
## Debug tools in the headset (docs/decisions.md, D-042). For now the frame
## rate of the editor's main loop while the headset is on: the latest rate and
## slowest interval, the session's state and the display's rate, and a chart
## of the history ([XREFPSChart]). The numbers are the session's
## ([member XRESession.fps_history]), not the compositor's delivery; frame
## times for the study come from the benchmarks, not from here.
##
## Was the FPS chart on the right wrist; it is a tab now, so it is opened,
## placed and pinned as any other.

## Updates of the history while the tab is shown redraw it at most this often, in microseconds.
const REFRESH_USEC := 250000

var history: XREFPSHistory
var _session: XRESession
var _number: Label
var _state: Label
var _chart: XREFPSChart
var _refreshed_usec := -REFRESH_USEC


func _init(document: XREDocument) -> void:
	super(document)
	name = "Debug"
	_number = Label.new()
	_number.name = "Number"
	_number.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_number)
	_state = Label.new()
	_state.name = "State"
	_state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_state)
	_chart = XREFPSChart.new()
	_chart.name = "Chart"
	_chart.custom_minimum_size.y = 120.0
	_chart.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(_chart)
	var legend := Label.new()
	legend.name = "Legend"
	legend.text = "Blue: mean FPS · Orange: longest interval\nSource: XRESession main loop, not compositor delivery.\nUse --xre-session-frames for CPU/GPU CSV."
	legend.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(legend)


func get_title() -> String:
	return "Debug"


func get_symbol() -> StringName:
	return &"debug"


## Follows [param session]'s frame history, or none without a session.
func setup(session: XRESession) -> void:
	if history != null and history.changed.is_connected(_on_history_changed): history.changed.disconnect(_on_history_changed)
	_session = session
	history = session.fps_history if session != null else null
	_chart.history = history
	if history != null and is_inside_tree(): history.changed.connect(_on_history_changed)
	mark_dirty()


func get_number_label() -> Label:
	return _number


func get_chart() -> XREFPSChart:
	return _chart


func _enter_tree() -> void:
	if history != null and not history.changed.is_connected(_on_history_changed): history.changed.connect(_on_history_changed)
	mark_dirty()


func _exit_tree() -> void:
	if history != null and history.changed.is_connected(_on_history_changed): history.changed.disconnect(_on_history_changed)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		# The editor's theme is scaled; the chart's labels and the big number follow its font size.
		var font_size := get_theme_default_font_size()
		_chart.ui_scale = font_size / 14.0
		_number.add_theme_font_size_override(&"font_size", roundi(font_size * 1.5))


func _on_history_changed() -> void:
	var now := Time.get_ticks_usec()
	if now - _refreshed_usec < REFRESH_USEC:
		return
	_refreshed_usec = now
	mark_dirty()


func _refresh() -> void:
	if history == null:
		_chart.refresh_rate = 0.0
		_chart.queue_redraw()
		_number.text = "FPS: no live XR session"
		_state.text = "Unavailable"
		return
	_number.text = "Main loop: %.1f FPS · slowest %.1f ms" % [history.latest_fps, history.latest_worst_ms] \
			if history.focused and history.latest_fps > 0 else "Main loop FPS: waiting for FOCUSED"
	var xr := _session.get_xr_interface()
	var refresh := xr.display_refresh_rate if xr != null else 0.0
	_chart.refresh_rate = refresh if refresh > 0.0 and is_finite(refresh) else 0.0
	var display := "%.1f Hz" % refresh if _chart.refresh_rate > 0 else "unknown"
	_state.text = "%s · display %s · t=%.2f s" % [_session.session_state_text(), display, Time.get_ticks_usec() / 1000000.0]
	_chart.queue_redraw()
