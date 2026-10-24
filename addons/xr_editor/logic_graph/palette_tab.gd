@tool
class_name XREBlueprintPaletteTab
extends XREBlueprintFormTab
## The block menu, in a window beside the card whose plus opened it, at a
## wire let go in empty space, or in front of the user (D-044, D-051): the
## form is [member XREBlueprints.block_menu], the action menu of the desktop
## view. Pinned to a hand, it stays open after a block is added, and the next
## block follows the new one, so that a chain is added in a row.


func _init(document: XREDocument) -> void:
	super(document)
	name = "AddBlock"


func get_title() -> String:
	return "Add block"


func get_symbol() -> StringName:
	return &"add_block"


## Over the cards it opens among (D-083), without the focus veil of an input.
func is_drawn_on_top() -> bool:
	return true


func _form() -> Control:
	return _service.block_menu
