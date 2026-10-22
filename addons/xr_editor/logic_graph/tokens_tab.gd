@tool
class_name XREBlueprintTokensTab
extends XREBlueprintFormTab
## The Tokens window of ready values (D-052), as the Objects window is for the
## scene (D-045): see-through, with a cell per token; a grip on a cell takes a
## copy. The form is [member XREBlueprints.token_tray]. It opens with the graph
## when the setting [constant XREFeatureSettings.TOKEN_TRAY] is on.


func _init(document: XREDocument) -> void:
	super(document)
	name = "Tokens"


func get_title() -> String:
	return "Tokens"


func get_symbol() -> StringName:
	return &"tokens"


## See-through, as Objects is.
func get_frame_color() -> Color:
	var color := XREPanelSurface.META_WINDOW_COLOR
	color.a = 0.62
	return color


func _form() -> Control:
	return _service.token_tray
