@tool
class_name XREBlueprintParametersTab
extends XREBlueprintFormTab
## The parameters of the selected logic graph block, in a window beside it
## (D-044): the form is [member XREBlueprints.parameters].


func _init(document: XREDocument) -> void:
	super(document)
	name = "Parameters"


func get_title() -> String:
	return "Parameters"


func get_symbol() -> StringName:
	return &"parameters"


func _form() -> Control:
	return _service.parameters
