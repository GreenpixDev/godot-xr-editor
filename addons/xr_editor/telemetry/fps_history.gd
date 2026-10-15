@tool
class_name XREFPSHistory
extends RefCounted
## Bounded main-loop timing history. This is not a headset compositor counter.

signal changed

const CAPACITY := 240
const WINDOW_SEC := 60.0
const UPDATE_SEC := 0.25
var fps := PackedFloat64Array()
var worst_fps := PackedFloat64Array()
var timestamps := PackedFloat64Array()
var count := 0
var cursor := 0
var focused := false
var latest_fps := 0.0
var latest_worst_ms := 0.0
var _frames := 0
var _elapsed := 0.0
var _worst := 0.0


func _init() -> void:
	fps.resize(CAPACITY)
	worst_fps.resize(CAPACITY)
	timestamps.resize(CAPACITY)


## Feeds actual monotonic intervals from XRESession, never smoothed/clamped delta.
## Each bucket stores mean FPS and the reciprocal of its longest interval.
func record_interval(seconds: float, timestamp: float, has_focus: bool) -> void:
	if not has_focus:
		if focused:
			_store(timestamp, NAN, NAN)
			latest_fps = 0.0
			latest_worst_ms = 0.0
			focused = false
			_frames = 0
			_elapsed = 0.0
			_worst = 0.0
			changed.emit()
		return
	focused = true
	if seconds <= 0.0: return
	_frames += 1
	_elapsed += seconds
	_worst = maxf(_worst, seconds)
	if _elapsed < UPDATE_SEC: return
	latest_fps = _frames / _elapsed
	latest_worst_ms = _worst * 1000.0
	_store(timestamp, latest_fps, 1.0 / _worst)
	_frames = 0
	_elapsed = 0.0
	_worst = 0.0
	changed.emit()


## Chronological ring index, without allocating a copy of the history.
func index_at(chronological: int) -> int:
	return (cursor - count + chronological + CAPACITY) % CAPACITY


func _store(timestamp: float, mean: float, worst: float) -> void:
	fps[cursor] = mean
	worst_fps[cursor] = worst
	timestamps[cursor] = timestamp
	cursor = (cursor + 1) % CAPACITY
	count = mini(count + 1, CAPACITY)
