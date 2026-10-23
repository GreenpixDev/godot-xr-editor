@tool
class_name XREBlueprintVectorTab
extends XREBlueprintFormTab
## The Vector window of a vector token (D-061): a window like the others, with
## its corner handles, its Control Bar and its ×, and the 3D arrows of the
## vector in front of it. The form is [member XREBlueprints.vector_panel].


func _init(document: XREDocument) -> void:
	super(document)
	name = "Vector"


func get_title() -> String:
	return "Vector"


func get_symbol() -> StringName:
	return &"parameters"


## Square enough for arrows up to [constant XREBlueprintTokenEditor.ARROW_MAX]
## each way, and no larger (D-064): near the head it stays within a seated reach.
func get_window_size() -> Vector2:
	return Vector2(380, 420)


## No Control Bar (D-062): the window has its own ×, and a click away closes it.
func has_control_bar() -> bool:
	return false


## See-through, as Objects is (D-062): the arrows that reach behind it stay in sight.
func get_frame_color() -> Color:
	var color := XREPanelSurface.META_WINDOW_COLOR
	color.a = 0.5
	return color


func _form() -> Control:
	return _service.vector_panel
