@tool
class_name XREUndo
extends Node
## Undo and redo in the headset (docs/decisions.md, D-087): the undo action
## (A on the right controller) puts back the latest step of
## [member XREDocument.history] — a change of the scene or of a graph, a value
## typed, a setting switched, a window, a menu or an input opened — and the
## redo action (B) makes it again.
## [br][br]
## Neither acts while a trigger or a grip is held: what a hand drags or holds
## is not done yet, as the desktop editor doesn't undo while a mouse button is
## down. Lives under the [XRERig] after the tools, so that what they recorded
## in a frame is in the history before the button reads it.

var _document: XREDocument
var _rig: XRERig


func _init(document: XREDocument, rig: XRERig) -> void:
	_document = document
	_rig = rig


func _process(_delta: float) -> void:
	var features := _document.features
	var undo := _rig.is_action_pressed(features, XREFeatureSettings.UNDO)
	var redo := _rig.is_action_pressed(features, XREFeatureSettings.REDO)
	if not (undo or redo) or _hands_busy():
		return
	if undo:
		_document.undo(XREDocument.Source.TOOL)
	else:
		_document.redo(XREDocument.Source.TOOL)


## Whether a hand holds its trigger or grip.
func _hands_busy() -> bool:
	return _rig.left_hand.trigger_held or _rig.left_hand.grip_held or _rig.right_hand.trigger_held or _rig.right_hand.grip_held
