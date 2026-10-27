extends SceneTree
## Headless tests of undo and redo in the headset (docs/decisions.md, D-087):
## XREHistory's steps, the document's undo of feature settings, bindings and
## the selection, and XREUndo's buttons with fake controller trackers. The
## scene's undo through the editor is tested in scripts/test_inspector.gd, the
## panels' in scripts/test_panels.gd, the graph's in scripts/test_blueprint_vr.gd.
## Used by scripts/check.sh, not shipped with the plugin. Prints
## "test_history: FAILED ..." for every failed check and a summary line at the end.


## A fake document: a selection of nodes and nothing else.
class FakeDocument extends XREDocument:
	var root: Node
	var selection: Array[Node] = []

	func get_scene_root() -> Node:
		return root

	func get_selection() -> Array[Node]:
		return selection.duplicate()

	func select(nodes: Array[Node], source: Source) -> void:
		var before := get_selection()
		selection = nodes.duplicate()
		_record(&"select", source, nodes)
		_remember_selection(before)

	func preview_transform(node: Node3D, xform: Transform3D) -> void:
		node.transform = xform

	func commit_transform(_node: Node3D, _before: Transform3D, _source: Source) -> void:
		pass

	func set_property(_object: Object, _property: StringName, _value: Variant, _source: Source) -> void:
		pass

	func preview_property(_object: Object, _property: StringName, _value: Variant) -> void:
		pass

	func commit_property(_object: Object, _property: StringName, _before: Variant, _source: Source) -> void:
		pass

	func add_node(_node: Node, _parent: Node, _source: Source) -> void:
		pass

	func remove_nodes(_nodes: Array[Node], _source: Source) -> void:
		pass

	func save(_source: Source) -> Error:
		return OK

	func open_scene(_path: String, _source: Source) -> Error:
		return ERR_UNAVAILABLE

	func list_folder(_path: String) -> PackedStringArray:
		return PackedStringArray()

	func get_file_type(_path: String) -> StringName:
		return &""

	func play(_source: Source, _separate_app: bool) -> Error:
		return OK

	func stop_playing(_source: Source) -> void:
		pass

	func is_playing() -> bool:
		return false

	func get_snap() -> XRESnap:
		return XRESnap.new(false, 0.0, 0.0, 0.0)

	func _set_selection(nodes: Array[Node]) -> void:
		selection = nodes.duplicate()


## Something the history changes: a value and what was done to it.
class Thing:
	var value := 0
	var log: Array[String] = []

	## Sets the value, for a change's undo or redo: false if it is that already.
	func put(to: int) -> bool:
		if value == to:
			return false
		value = to
		log.append(str(to))
		return true


var _checks := 0
var _failures := 0
var _frame := 0
var _steps: Array[Callable] = []

var _history: XREHistory
var _first := Thing.new()
var _second := Thing.new()
var _document: FakeDocument
var _operations: Array[String] = []
var _scene: Node3D
var _box: Node3D
var _lamp: Node3D
var _trackers: Array[XRControllerTracker] = []
var _right: XRControllerTracker
var _left: XRControllerTracker
var _rig: XRERig
var _undo: XREUndo


func _initialize() -> void:
	_steps = [
		_record_in_one_frame,
		_record_in_another_frame,
		_undo_steps,
		_redo_steps,
		_change_after_undo,
		_changed_after_undo,
		_drop_stale_steps,
		_replay_records_nothing,
		_record_after_replay,
		_forget_kind,
		_test_settings,
		_test_bindings,
		_test_layouts,
		_test_selection,
		_select_more,
		_undo_selection,
		_build_rig,
		_press_undo,
		_undone_by_button,
		_press_redo,
		_redone_by_button,
		_press_undo_holding,
		_not_undone_while_holding,
		_finish,
	]


func _process(_delta: float) -> bool:
	if _frame < _steps.size():
		_steps[_frame].call()
	_frame += 1
	return false


func _check(condition: bool, what: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("test_history: FAILED ", what)


## Records a change of [param thing] to [param to] that has just been made.
func _change(thing: Thing, to: int, kind: XREHistory.Kind = XREHistory.Kind.VIEW) -> void:
	var from := thing.value
	thing.put(to)
	_history.record(kind, "%d to %d" % [from, to], thing.put.bind(from), thing.put.bind(to))


func _record_in_one_frame() -> void:
	_history = XREHistory.new()
	_check(not _history.can_undo() and not _history.can_redo() and _history.undo().is_empty(), "a new history has nothing to undo or redo")
	_change(_first, 1)
	_change(_second, 1)
	_check(_history.get_step_count() == 1 and _history.get_undo_name() == "0 to 1", "changes recorded in one frame are one step")


func _record_in_another_frame() -> void:
	_change(_first, 2)
	_check(_history.get_step_count() == 2 and _history.get_undo_name() == "1 to 2", "a change in another frame is another step")


func _undo_steps() -> void:
	_check(_history.undo() == "1 to 2" and _first.value == 1 and _second.value == 1, "undo puts back the latest step")
	_first.log.clear()
	_second.log.clear()
	_check(_history.undo() == "0 to 1" and _first.value == 0 and _second.value == 0, "and then the one before, all of it")
	_check(not _history.can_undo() and _history.can_redo() and _history.get_redo_name() == "0 to 1", "the undone steps can be redone")


func _redo_steps() -> void:
	_first.log.clear()
	_second.log.clear()
	_check(_history.redo() == "0 to 1" and _first.value == 1 and _second.value == 1, "redo makes the first step again")
	_check(_history.redo() == "1 to 2" and _first.value == 2, "and the next")
	_check(not _history.can_redo() and _history.redo().is_empty(), "nothing more to redo")


func _change_after_undo() -> void:
	_history.undo()


func _changed_after_undo() -> void:
	_change(_second, 5)
	_check(not _history.can_redo() and _history.get_step_count() == 2, "a change after undo drops the steps that could be redone")
	_history.undo()
	_history.undo()
	_check(_first.value == 0 and _second.value == 0, "back to the start")
	_history.clear()
	_check(_history.get_step_count() == 0, "clear drops every step")


## A step whose change was made undone meanwhile, as a menu closed by its own ×,
## is dropped, and undo goes on to the step before.
func _drop_stale_steps() -> void:
	_change(_first, 1)


func _replay_records_nothing() -> void:
	_change(_second, 1)
	_second.put(0)
	_operations.clear()
	_check(_history.undo() == "0 to 1" and _first.value == 0, "a step that changes nothing is skipped, its undo goes on to the one before")
	_check(_history.get_step_count() == 1 and _history.get_redo_name() == "0 to 1", "and the stale step is gone")
	# What the undo set off in its frame is the undo's.
	_change(_second, 7)
	_check(_history.get_step_count() == 1 and _history.can_redo(), "nothing is recorded in the frame of an undo")
	_second.put(0)


func _record_after_replay() -> void:
	_check(not _history.is_replaying(), "in the next frame the history records again")
	_check(_history.redo() == "0 to 1" and _first.value == 1, "redo")
	_history.clear()
	_history.record(XREHistory.Kind.VIEW, "gone", Callable(), Callable())
	_check(_history.undo().is_empty() and _history.get_step_count() == 0, "a step without callables is dropped")


func _forget_kind() -> void:
	_history.clear()
	_first.value = 0
	_second.value = 0
	_change(_first, 1, XREHistory.Kind.SCENE)
	_change(_second, 1, XREHistory.Kind.VIEW)
	_history.forget(XREHistory.Kind.SCENE)
	_check(_history.get_step_count() == 1 and _history.undo() == "0 to 1" and _first.value == 1 and _second.value == 0,
			"forgetting a kind drops its changes and keeps the others")
	_history.redo()
	_history.forget(XREHistory.Kind.VIEW)
	_check(_history.get_step_count() == 0 and not _history.can_undo(), "a step left with nothing is dropped")


## Feature settings, layouts and bindings are undone as they were switched.
func _test_settings() -> void:
	_document = FakeDocument.new()
	_document.operation_recorded.connect(
			func(operation: StringName, source: XREDocument.Source, _nodes: Array[Node], _time_usec: int) -> void:
				_operations.append("%s %s" % [operation, XREDocument.Source.keys()[source]]))
	var features := _document.features
	_check(_document.set_feature(XREFeatureSettings.NODE_FACING, XREFeatureSettings.OFF, XREDocument.Source.PANEL)
			and _document.history.get_undo_name() == "Set Node facing", "a switch of a feature is a step: %s" % _document.history.get_undo_name())
	_operations.clear()
	_check(_document.undo(XREDocument.Source.TOOL) and features.get_value(XREFeatureSettings.NODE_FACING) == XREFeatureSettings.ON,
			"undo switches it back")
	_check(_operations == ["undo TOOL"], "as one undo operation: %s" % [_operations])
	_check(_document.redo(XREDocument.Source.PANEL) and features.get_value(XREFeatureSettings.NODE_FACING) == XREFeatureSettings.OFF
			and _operations == ["undo TOOL", "redo PANEL"], "redo switches it again: %s" % [_operations])


## A frame after the undo: nothing is recorded in the frame of one.
func _test_bindings() -> void:
	var features := _document.features
	_document.history.clear()
	_check(_document.set_binding(XREFeatureSettings.DELETE, &"right_stick", XREDocument.Source.PANEL)
			and features.get_layout() == XREFeatureSettings.CUSTOM, "a rebinding picks the custom layout")
	_check(_document.undo(XREDocument.Source.TOOL) and features.get_layout() == XREFeatureSettings.HORIZON_LINK
			and features.get_binding(XREFeatureSettings.DELETE) == &"left_x", "undo puts back the layout and the binding")
	_check(_document.redo(XREDocument.Source.TOOL) and features.get_binding(XREFeatureSettings.DELETE) == &"right_stick", "redo binds it again")


func _test_layouts() -> void:
	var features := _document.features
	_check(_document.set_controls_layout(XREFeatureSettings.STEAMVR, XREDocument.Source.PANEL)
			and _document.undo(XREDocument.Source.TOOL) and features.get_layout() == XREFeatureSettings.CUSTOM
			and features.get_binding(XREFeatureSettings.DELETE) == &"right_stick", "undo of a layout picked goes back to the custom one")
	_document.history.clear()
	_operations.clear()
	_check(not _document.undo(XREDocument.Source.TOOL) and not _document.redo(XREDocument.Source.TOOL) and _operations.is_empty(),
			"with nothing to undo or redo, nothing is recorded")


## The selection is undone only with Undo selection on.
func _test_selection() -> void:
	_scene = Node3D.new()
	_scene.name = "Scene"
	root.add_child(_scene)
	_box = Node3D.new()
	_box.name = "Box"
	_scene.add_child(_box)
	_lamp = Node3D.new()
	_lamp.name = "Lamp"
	_scene.add_child(_lamp)
	_document.root = _scene
	_check(XREFeatureSettings.get_default(XREFeatureSettings.UNDO_SELECTION) == XREFeatureSettings.ON, "Undo selection is on by default (D-089)")
	_document.features.set_value(XREFeatureSettings.UNDO_SELECTION, XREFeatureSettings.OFF)
	_document.history.clear()
	_document.select([_box], XREDocument.Source.TOOL)
	_check(not _document.history.can_undo(), "with Undo selection off, selecting is no step, as on the desktop")
	_document.features.set_value(XREFeatureSettings.UNDO_SELECTION, XREFeatureSettings.ON)
	_document.select([_lamp], XREDocument.Source.TOOL)
	_check(_document.history.get_undo_name() == "Select", "on, it is a step")


func _select_more() -> void:
	_document.select([_lamp, _box], XREDocument.Source.TOOL)
	_document.select([_lamp, _box], XREDocument.Source.TOOL)
	_check(_document.history.get_step_count() == 2, "selecting what is selected already is no change")


func _undo_selection() -> void:
	_operations.clear()
	_check(_document.undo(XREDocument.Source.TOOL) and _document.get_selection() == [_lamp], "undo puts back the selection before")
	_check(_document.undo(XREDocument.Source.TOOL) and _document.get_selection() == [_box], "and the one before that")
	_check(_operations == ["undo TOOL", "undo TOOL"], "with no select operations: %s" % [_operations])
	_check(_document.redo(XREDocument.Source.TOOL) and _document.get_selection() == [_lamp], "redo selects again")
	_lamp.free()
	_check(_document.redo(XREDocument.Source.TOOL) and _document.get_selection() == [_box], "a node gone is left out")
	_document.features.set_value(XREFeatureSettings.UNDO_SELECTION, XREFeatureSettings.OFF)
	_document.history.clear()


func _build_rig() -> void:
	_right = _add_tracker(&"right_hand")
	_left = _add_tracker(&"left_hand")
	_document.features = XREFeatureSettings.new()
	# The buttons' checks count steps of their own: selecting is none of them.
	_document.features.set_value(XREFeatureSettings.UNDO_SELECTION, XREFeatureSettings.OFF)
	_rig = XRERig.new()
	_undo = XREUndo.new(_document, _rig)
	_rig.add_child(_undo)
	root.add_child(_rig)
	_first.value = 0
	_document.history.record(XREHistory.Kind.VIEW, "Thing", _first.put.bind(0), _first.put.bind(1))
	_first.put(1)


func _add_tracker(tracker_name: StringName) -> XRControllerTracker:
	var tracker := XRControllerTracker.new()
	tracker.name = tracker_name
	tracker.set_pose(&"aim", Transform3D.IDENTITY, Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	XRServer.add_tracker(tracker)
	_trackers.append(tracker)
	return tracker


func _press_undo() -> void:
	_operations.clear()
	_right.set_input(&"ax_button", true)


func _undone_by_button() -> void:
	_check(_first.value == 0 and _operations == ["undo TOOL"], "A on the right controller undoes: %s" % [_operations])
	_right.set_input(&"ax_button", false)


func _press_redo() -> void:
	_right.set_input(&"by_button", true)


func _redone_by_button() -> void:
	_check(_first.value == 1 and _operations == ["undo TOOL", "redo TOOL"], "B redoes: %s" % [_operations])
	_right.set_input(&"by_button", false)


func _press_undo_holding() -> void:
	_left.set_input(&"grip", 1.0)
	_right.set_input(&"ax_button", true)


func _not_undone_while_holding() -> void:
	_check(_first.value == 1 and _operations.size() == 2, "nothing is undone while a hand holds its grip")
	_right.set_input(&"ax_button", false)
	_left.set_input(&"grip", 0.0)


func _finish() -> void:
	for tracker in _trackers:
		XRServer.remove_tracker(tracker)
	print("test_history: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)
