@tool
class_name XREBlueprintPaletteTab
extends XREBlueprintFormTab
## The blocks a card's plus adds, in a window beside the card (D-044): the
## form is [member XREBlueprints.block_list]. Pinned to a hand, it stays open
## after a block is added, so that several are added in a row.


func _init(document: XREDocument) -> void:
	super(document)
	name = "AddBlock"


func get_title() -> String:
	return "Add block"


func get_symbol() -> StringName:
	return &"add_block"


func _form() -> Control:
	return _service.block_list
