@tool
class_name XREBlueprintFunctionsTab
extends XREBlueprintFormTab
## The Functions window (D-144): the plates of the graph's own functions
## ([member XREBlueprints.plates]). See-through as Tokens is, drawn over the
## scene and the cards so that neither hides it, moved by its Control Bar. It
## opens with the graph; a body opened from a call brings it under the body's
## Entry, and a body opened from it puts its Entry over it.


func _init(document: XREDocument) -> void:
	super(document)
	name = "Functions"


func get_title() -> String:
	return "Functions"


func get_symbol() -> StringName:
	return &"functions"


## As tall as its plates.
func get_window_size() -> Vector2:
	return _service.plates.window_size() if _service != null else Vector2(270, 200)


## See-through, as Tokens is.
func get_frame_color() -> Color:
	var color := XREPanelSurface.META_WINDOW_COLOR
	color.a = 0.62
	return color


## Over the scene's objects and the cards: neither hides it.
func is_drawn_on_top() -> bool:
	return true


func setup(service: XREBlueprints) -> void:
	super(service)
	if _service != null and not _service.plates.size_changed.is_connected(_resize): _service.plates.size_changed.connect(_resize)


## A plate more or less: the window grows or shrinks downward, its top where it
## was, so that a body's Entry over it stays clear of it (D-144).
func _resize() -> void:
	var window := get_viewport().get_parent() as XREPanelWindow if is_inside_tree() else null
	if window == null or window.pin != XREPanelWindow.Pin.WINDOW:
		window_size_changed.emit()
		return
	var top := window.global_position + window.global_basis.y.normalized() * window.size_m.y * 0.5
	window_size_changed.emit()
	# After the panels' deferred resize, queued by the signal before this.
	_keep_top.call_deferred(window, top)


func _keep_top(window: XREPanelWindow, top: Vector3) -> void:
	if is_instance_valid(window): window.global_position = top - window.global_basis.y.normalized() * window.size_m.y * 0.5


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and is_instance_valid(_service) and _service.plates.size_changed.is_connected(_resize):
		_service.plates.size_changed.disconnect(_resize)


func _form() -> Control:
	return _service.plates
