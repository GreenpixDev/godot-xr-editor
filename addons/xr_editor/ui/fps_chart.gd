@tool
class_name XREFPSChart
extends Control
## Plots cached history in real seconds. Gaps mark loss of headset focus/play.

var history: XREFPSHistory
var refresh_rate := 0.0
## Layout scale keeps plot labels legible at the editor's scaled UI size.
var ui_scale := 1.0


func _draw() -> void:
	if history == null or history.count == 0: return
	var bounds := Rect2(Vector2(32, 10) * ui_scale, size - Vector2(40, 32) * ui_scale)
	var scale := maxf(refresh_rate * 1.25, 120.0)
	for tick: int in 4:
		var y := bounds.end.y - bounds.size.y * tick / 3.0
		draw_line(Vector2(bounds.position.x, y), Vector2(bounds.end.x, y), Color("435260"))
		draw_string(ThemeDB.fallback_font, Vector2(0, y), "%d" % roundi(scale * tick / 3.0), HORIZONTAL_ALIGNMENT_LEFT, -1, roundi(12 * ui_scale))
	if refresh_rate > 0.0 and is_finite(refresh_rate):
		var target_y := bounds.end.y - bounds.size.y * refresh_rate / scale
		draw_line(Vector2(bounds.position.x, target_y), Vector2(bounds.end.x, target_y), Color("678c67"), ui_scale)
	var end := history.timestamps[history.index_at(history.count - 1)]
	var previous := Vector2.ZERO
	var connected := false
	for sample: int in history.count:
		var index := history.index_at(sample)
		var age := end - history.timestamps[index]
		if age > XREFPSHistory.WINDOW_SEC: continue
		if is_nan(history.fps[index]):
			connected = false
			continue
		var x := bounds.end.x - bounds.size.x * age / XREFPSHistory.WINDOW_SEC
		var point := Vector2(x, bounds.end.y - bounds.size.y * clampf(history.fps[index] / scale, 0, 1))
		if connected: draw_line(previous, point, Color("72d8ef"), 2 * ui_scale)
		var low := Vector2(x, bounds.end.y - bounds.size.y * clampf(history.worst_fps[index] / scale, 0, 1))
		draw_line(point, low, Color("ffb36b"), 2 * ui_scale)
		previous = point
		connected = true
	draw_string(ThemeDB.fallback_font, Vector2(bounds.position.x, size.y - 3 * ui_scale), "−60 s", HORIZONTAL_ALIGNMENT_LEFT, -1, roundi(12 * ui_scale))
	draw_string(ThemeDB.fallback_font, Vector2(bounds.end.x - 38 * ui_scale, size.y - 3 * ui_scale), "now", HORIZONTAL_ALIGNMENT_LEFT, -1, roundi(12 * ui_scale))
