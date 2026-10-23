@tool
class_name XREBlueprintColorTab
extends XREBlueprintFormTab
## The Color window of a color token (D-064): a window like the others, with
## its corner handles and its ×, opened near the head. In 3D the globe of
## colors hangs in front of it. The form is [member XREBlueprints.color_panel].


func _init(document: XREDocument) -> void:
	super(document)
	name = "Color"


func get_title() -> String:
	return "Color"


func get_symbol() -> StringName:
	return &"parameters"


## As the form's mode asks: tall for the picker, smaller around the globe.
func get_window_size() -> Vector2:
	return _service.color_panel.window_size() if _service != null else Vector2(400, 660)


## No Control Bar, as the Vector window (D-062): its own ×, and a click away closes it.
func has_control_bar() -> bool:
	return false


## See-through around the globe, as the Vector window is around its arrows
## (D-065); opaque around the 2D picker, whose colors the cards behind would muddle.
func get_frame_color() -> Color:
	var color := XREPanelSurface.META_WINDOW_COLOR
	if _service != null and _service.color_panel.get_mode() == XREFeatureSettings.GLOBE: color.a = 0.5
	return color


func _form() -> Control:
	return _service.color_panel
