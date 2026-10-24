@tool
extends Node
## Test of the panels' parts that need a running editor: the inspector tab
## with the editor's own EditorInspector, editing a node of the open scene
## through XREInspectorProxy and XREPluginDocument into the editor's undo
## history, and XREPluginDocument opening scenes and listing files, and undo
## and redo in the headset through the editor's own Undo and Redo (D-082). The plugin
## starts it in an editor run with "-- --xre-test-inspector" (scripts/check.sh)
## and it quits the editor when done. Prints "test_inspector: FAILED ..." for
## every failed check and a summary line at the end. Undoes its edits and
## saves nothing.

const SCENE := "res://benchmarks/manipulation_check.tscn"
const OTHER_SCENE := "res://benchmarks/play_check.tscn"
## Editor frames to wait for the scene to open before giving up.
const SCENE_TIMEOUT_FRAMES := 600

var _document: XREDocument
var _checks := 0
var _failures := 0
var _steps: Array[Callable] = []
var _step := 0
var _waited := 0
var _operations: Array[String] = []
var _window: XREPanelWindow
var _tab: XREInspectorTab
var _sun: DirectionalLight3D
var _energy_before := 0.0
## A node the headset adds and deletes, undone and redone (D-082).
var _added: Node3D


func _init(document: XREDocument) -> void:
	name = "XRETestInspector"
	_document = document
	_steps = [_wait_for_scene, _open_window, _inspector_shown, _drag_value, _open_other_scene, _other_scene_opened,
			_undo_value, _add_node, _undo_add, _remove_node, _undo_remove, _edit_on_desktop, _open_for_undo, _undo_open,
			_test_files, _finish]


func _enter_tree() -> void:
	_document.operation_recorded.connect(_on_operation_recorded)


func _exit_tree() -> void:
	_document.operation_recorded.disconnect(_on_operation_recorded)


func _process(_delta: float) -> void:
	if _step < _steps.size():
		_steps[_step].call()


func _next() -> void:
	_step += 1


func _check(condition: bool, what: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("test_inspector: FAILED ", what)


func _on_operation_recorded(operation: StringName, source: XREDocument.Source, nodes: Array[Node], _time_usec: int) -> void:
	_operations.append("%s %s %s" % [operation, XREDocument.Source.keys()[source],
			nodes.map(func(node: Node) -> String: return String(node.name))])


func _wait_for_scene() -> void:
	var root := _document.get_scene_root()
	if root != null and root.scene_file_path == SCENE:
		_next()
		return
	_waited += 1
	if _waited > SCENE_TIMEOUT_FRAMES:
		_check(false, "the editor didn't open %s; pass it on the command line" % SCENE)
		_step = _steps.size() - 1


func _open_window() -> void:
	_sun = _document.get_scene_root().get_node(^"Sun") as DirectionalLight3D
	_energy_before = _sun.light_energy
	_tab = XREInspectorTab.new(_document)
	_window = XREPanelWindow.new(_tab, XREPanels.WINDOW_SIZE, XREPanels.WINDOW_PIXEL_SIZE, 1.0,
			EditorInterface.get_editor_theme())
	add_child(_window)
	_document.select([_sun], XREDocument.Source.PANEL)
	_next()


## The inspector's editor of [param property], or null.
func _property_editor(property: StringName) -> EditorProperty:
	for node: Node in _tab.get_inspector().find_children("*", "EditorProperty", true, false):
		var editor := node as EditorProperty
		if editor.get_edited_property() == property:
			return editor
	return null


func _inspector_shown() -> void:
	var inspector := _tab.get_inspector()
	_check(inspector != null and inspector.get_edited_object() == _tab.get_proxy() and _tab.get_proxy() != null
			and _tab.get_proxy().get_target() == _sun, "the inspector tab edits the selected node through a proxy")
	if inspector == null:
		_step = _steps.size() - 1
		return
	var energy := _property_editor(&"light_energy")
	_check(energy != null and not energy.read_only, "the node's properties have their editors")
	_check(_property_editor(&"script") == null, "the script is left out")
	# Its text is the editor's, translated or not.
	var add_metadata := ["Add Metadata", XREPanelTab.editor_text("Add Metadata")]
	var buttons := inspector.find_children("*", "Button", true, false).filter(
			func(button: Node) -> bool: return (button as Button).text in add_metadata)
	_check(buttons.is_empty(), "so is the button that adds metadata")
	var parent := _property_editor(&"visibility_parent")
	_check(parent != null and parent.read_only, "node paths are read only")
	if energy == null:
		_step = _steps.size() - 1
		return
	_operations.clear()
	energy.emit_changed(&"light_energy", 2.5)
	_check(is_equal_approx(_sun.light_energy, 2.5) and _operations.is_empty(),
			"an edit in the inspector previews the value, without an operation")
	_window.pointer_released.emit()
	_check(_operations == ["set_property PANEL [\"Sun\"]"],
			"letting go of the pointer makes it one operation from a panel: %s" % [_operations])
	var history := _history()
	_check(history.get_current_action_name() == "XR: Set light_energy",
			"and one step in the editor's undo history: %s" % history.get_current_action_name())
	history.undo()
	_check(is_equal_approx(_sun.light_energy, _energy_before), "undo puts the value back: %f" % _sun.light_energy)
	_next()


func _drag_value() -> void:
	var energy := _property_editor(&"light_energy")
	_operations.clear()
	energy.emit_changed(&"light_energy", 3.0)
	energy.emit_changed(&"light_energy", 4.0)
	_window.pointer_released.emit()
	_check(_operations.size() == 1 and is_equal_approx(_sun.light_energy, 4.0),
			"a drag through several values is one operation: %s" % [_operations])
	_history().undo()
	_check(is_equal_approx(_sun.light_energy, _energy_before), "and one undo step: %f" % _sun.light_energy)
	_operations.clear()
	_check(_document.open_scene(OTHER_SCENE, XREDocument.Source.PANEL) == OK, "a scene opens")
	_next()


func _open_other_scene() -> void:
	var root := _document.get_scene_root()
	_check(root != null and root.scene_file_path == OTHER_SCENE, "the opened scene is edited")
	_check(_operations == ["open_scene PANEL [\"PlayCheck\"]"], "opening is an operation from a panel: %s" % [_operations])
	_check(_window.is_inside_tree(), "the window stays")
	# A real project can restore a persisted selection in the newly opened tab.
	var selection := _document.get_selection()
	var shown: Object = _tab.get_proxy().get_target() if _tab.get_proxy() != null else null
	_check(shown == (selection[0] if selection.size() == 1 else null),
			"the inspector follows the opened scene's restored selection")
	_check(_document.open_scene(SCENE, XREDocument.Source.PANEL) == OK, "an open scene is switched to")
	_check(_document.open_scene("res://benchmarks/play_check.gd", XREDocument.Source.PANEL) == ERR_FILE_UNRECOGNIZED,
			"a script is not opened as a scene")
	_next()


func _other_scene_opened() -> void:
	_check(_document.get_scene_root().scene_file_path == SCENE, "switching back edits the first scene again")
	# The editor keeps each scene's selection.
	var selection := _document.get_selection()
	var shown: Object = _tab.get_proxy().get_target() if _tab.get_proxy() != null else null
	_check(shown == (selection[0] if selection.size() == 1 else null),
			"the inspector follows the selection of the scene switched to: %s, %s" % [shown, selection])
	_next()


## D-082: a value set in the inspector is put back by the headset's undo,
## through the editor's own Undo, and made again by its redo.
func _undo_value() -> void:
	_document.history.clear()
	var energy := _property_editor(&"light_energy")
	energy.emit_changed(&"light_energy", 2.5)
	_window.pointer_released.emit()
	_check(_document.history.get_undo_name() == "Set light_energy", "the edit is a step of the headset's history: %s" % _document.history.get_undo_name())
	_operations.clear()
	_check(_document.undo(XREDocument.Source.TOOL) and is_equal_approx(_sun.light_energy, _energy_before),
			"undo in the headset puts the value back: %f" % _sun.light_energy)
	_check(_operations == ["undo TOOL []"], "undo is one operation: %s" % [_operations])
	_check(_history().has_redo() and _history().get_action_name(_history().get_current_action() + 1) == "XR: Set light_energy",
			"through the editor's history, which can redo it")
	_check(_document.redo(XREDocument.Source.TOOL) and is_equal_approx(_sun.light_energy, 2.5), "redo sets it again: %f" % _sun.light_energy)
	_check(_history().get_current_action_name() == "XR: Set light_energy", "the editor's history has it done again")
	_check(_document.undo(XREDocument.Source.TOOL) and is_equal_approx(_sun.light_energy, _energy_before), "undo once more")
	_next()


func _add_node() -> void:
	_added = Node3D.new()
	_added.name = "XREUndoCheck"
	_document.add_node(_added, _document.get_scene_root(), XREDocument.Source.TOOL)
	_check(_added.get_parent() == _document.get_scene_root() and _document.history.get_undo_name() == "Add XREUndoCheck",
			"a node added is a step: %s" % _document.history.get_undo_name())
	_next()


func _undo_add() -> void:
	_check(_document.undo(XREDocument.Source.TOOL) and _added.get_parent() == null, "undo takes the added node out")
	_check(_document.redo(XREDocument.Source.TOOL) and _added.get_parent() == _document.get_scene_root() and _added.owner == _document.get_scene_root(),
			"redo puts it back in the scene, owned by it")
	_next()


func _remove_node() -> void:
	_document.remove_nodes([_added], XREDocument.Source.TOOL)
	_check(_added.get_parent() == null and _document.history.get_undo_name() == "Remove XREUndoCheck", "deleting is a step")
	_next()


func _undo_remove() -> void:
	_check(_document.undo(XREDocument.Source.TOOL) and _added.get_parent() == _document.get_scene_root(), "undo brings the deleted node back")
	_check(_document.undo(XREDocument.Source.TOOL) and _added.get_parent() == null, "and the undo before takes the added one out")
	_check(_document.history.get_undo_name().is_empty(), "nothing is left to undo: %s" % _document.history.get_undo_name())
	_next()


## An edit on the desktop leaves the headset's changes of the scene behind:
## the editor's Undo would undo that edit first.
func _edit_on_desktop() -> void:
	_document.history.clear()
	var energy := _property_editor(&"light_energy")
	energy.emit_changed(&"light_energy", 2.5)
	_window.pointer_released.emit()
	_check(_document.history.can_undo(), "the headset's edit is to undo")
	var manager := EditorInterface.get_editor_undo_redo()
	manager.create_action("Desktop edit")
	manager.add_do_property(_sun, &"light_energy", _energy_before)
	manager.add_undo_property(_sun, &"light_energy", 2.5)
	manager.commit_action()
	_check(not _document.history.can_undo() and not _document.undo(XREDocument.Source.TOOL),
			"after an edit on the desktop the headset has nothing of the scene to undo")
	_check(is_equal_approx(_sun.light_energy, _energy_before), "the desktop's edit stays")
	_next()


func _open_for_undo() -> void:
	_check(_document.open_scene(OTHER_SCENE, XREDocument.Source.PANEL) == OK, "a scene opens again")
	_next()


func _undo_open() -> void:
	_check(_document.undo(XREDocument.Source.TOOL) and _document.get_scene_root().scene_file_path == SCENE,
			"undo goes back to the scene edited before")
	_check(_document.redo(XREDocument.Source.TOOL) and _document.get_scene_root().scene_file_path == OTHER_SCENE,
			"redo opens the other one again")
	_check(_document.undo(XREDocument.Source.TOOL) and _document.get_scene_root().scene_file_path == SCENE, "and back")
	_next()


func _test_files() -> void:
	var entries := _document.list_folder("res://benchmarks/")
	_check(entries.has("manipulation_check.tscn") and entries.has("play_check.gd"),
			"the project's files are listed: %s" % [entries])
	_check(not entries.has("results/"), "folders Godot ignores are not")
	_check(_document.list_folder("res://").has("benchmarks/"), "folders end with a slash")
	_check(_document.get_file_type(SCENE) == &"PackedScene", "files have their types: %s" % _document.get_file_type(SCENE))
	_next()


func _finish() -> void:
	if _window != null:
		_window.queue_free()
	print("test_inspector: %d of %d checks failed" % [_failures, _checks])
	_next()
	get_tree().quit(1 if _failures > 0 else 0)


func _history() -> UndoRedo:
	var manager := EditorInterface.get_editor_undo_redo()
	return manager.get_history_undo_redo(manager.get_object_history_id(_sun))
