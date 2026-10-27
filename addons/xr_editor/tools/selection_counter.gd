@tool
class_name XRESelectionCounter
extends Node
## How many things are selected, on a pill over the left controller (D-118),
## with [constant XREFeatureSettings.SELECTION_COUNTER] on: the scene objects,
## or the blocks of the graph while it is open ([XREBlueprints]). While a hand
## holds its grip in empty space, which makes the other hand add to the
## selection (D-115, D-117), the pill shows a plus and turns blue, also before
## anything is selected. With nothing selected and no plus, it hides.
## [br][br]
## The scene's selection is counted when it changes, not every frame; each
## frame only compares a few numbers, and the text is made again only when
## they change (invariant 4). The pill is a child of the left hand, so it
## follows it, and is drawn over the controller.

## Where the pill is in the left hand's space, in meters: above the controller, towards the head.
const OFFSET := Vector3(0.0, 0.07, 0.04)
const IDLE_COLOR := Color(0.92, 0.93, 0.95)
## The plus's color: the light blue of copies (D-116), as adding is a step towards them.
const ADDING_COLOR := Color("a9d4ff")

var _document: XREDocument
var _rig: XRERig
var _manipulator: XREManipulator
var _blueprints: XREBlueprints
var _label: Label3D
## Selected scene objects, counted on [signal XREDocument.selection_changed].
var _objects := 0
## What the pill shows now: a count of blocks or objects, whether the plus is on, whether it is shown.
var _shown_count := -1
var _shown_blocks := false
var _shown_adding := false
var _shown := false


## [param blueprints] may be null: the scene's selection is counted then.
func _init(document: XREDocument, rig: XRERig, manipulator: XREManipulator, blueprints: XREBlueprints = null) -> void:
	_document = document
	_rig = rig
	_manipulator = manipulator
	_blueprints = blueprints
	_label = XRERig.create_vr_label(32, 0.0006)
	_label.name = "SelectionCounter"
	_label.position = OFFSET
	_label.no_depth_test = true
	_label.render_priority = Material.RENDER_PRIORITY_MAX
	_label.outline_size = 10
	_label.outline_modulate = Color(0.08, 0.09, 0.11, 0.9)
	_label.visible = false


func _enter_tree() -> void:
	_rig.left_hand.add_child(_label)
	_document.selection_changed.connect(_count_objects)
	_count_objects()


func _exit_tree() -> void:
	_document.selection_changed.disconnect(_count_objects)
	_label.queue_free()


func _process(_delta: float) -> void:
	var on := _document.features.get_value(XREFeatureSettings.SELECTION_COUNTER) == XREFeatureSettings.ON
	var blocks := _blueprints != null and _blueprints.is_open()
	var count := _blueprints.get_selected_count() if blocks else _objects
	var adding := (_blueprints.is_adding() if blocks else _manipulator.is_adding()) and _modifier_used(blocks)
	var shown := on and (count > 0 or adding)
	if shown == _shown and count == _shown_count and blocks == _shown_blocks and adding == _shown_adding:
		return
	_shown = shown
	_shown_count = count
	_shown_blocks = blocks
	_shown_adding = adding
	_label.visible = shown
	if not shown:
		return
	var noun := ("block" if count == 1 else "blocks") if blocks else ("object" if count == 1 else "objects")
	_label.text = "%s%d %s" % ["+ " if adding else "", count, noun]
	_label.modulate = ADDING_COLOR if adding else IDLE_COLOR


## The pill, to read what it shows.
func get_label() -> Label3D:
	return _label


## Whether the grip held in empty space does anything: it adds to the
## selection with Add to selection on Other grip, and, in the scene, takes
## copies with Copy objects on Other grip or Both (D-116).
func _modifier_used(blocks: bool) -> bool:
	var features := _document.features
	if features.get_value(XREFeatureSettings.SELECT_ADD) == XREFeatureSettings.GRIP:
		return true
	var copy := features.get_value(XREFeatureSettings.OBJECT_COPY)
	return not blocks and (copy == XREFeatureSettings.GRIP or copy == XREFeatureSettings.BOTH)


func _count_objects() -> void:
	_objects = _document.get_selection().size()
