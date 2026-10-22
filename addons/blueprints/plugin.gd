@tool
extends EditorPlugin
## Independent main-screen visual scripting addon; no XR or native dependencies.

var _document: XREBlueprintDocument
var _view: XREBlueprintEditor
var _files: EditorFileDialog
var _discard: ConfirmationDialog
var _pending: Callable
var _after_save := ""
var _scene_refresh_pending := false


func _enter_tree() -> void:
	_document = XREBlueprintDocument.retain_editor_shared()
	_view = XREBlueprintEditor.new()
	_view.selected_nodes_provider = func() -> Array: return EditorInterface.get_selection().get_selected_nodes()
	EditorInterface.get_editor_main_screen().add_child(_view)
	_view.setup(_document)
	EditorInterface.get_selection().selection_changed.connect(_view.refresh_menu)
	EditorInterface.get_resource_filesystem().filesystem_changed.connect(_scripts_changed)
	_document.update_active_scene(EditorInterface.get_edited_scene_root())
	scene_changed.connect(_scene_changed)
	get_tree().tree_changed.connect(_schedule_scene_refresh)
	_view.hide()
	_view.new_requested.connect(_new_requested)
	_view.open_requested.connect(_open_requested)
	_view.save_requested.connect(_save_requested)
	_view.build_requested.connect(_build_requested)
	_view.attach_requested.connect(_attach_requested)
	_view.focus_requested.connect(_focus_requested)
	_view.graph_scene_requested.connect(_open_graph_scene)
	_files = EditorFileDialog.new()
	_files.access = EditorFileDialog.ACCESS_RESOURCES
	_files.filters = PackedStringArray(["*.tres ; Blueprint graph"])
	_files.file_selected.connect(_file_selected)
	_view.add_child(_files)
	_discard = ConfirmationDialog.new()
	_discard.dialog_text = "Discard unsaved changes to the current Blueprint? Save it first to keep your work."
	_discard.ok_button_text = "Discard changes"
	_discard.confirmed.connect(func() -> void:
		_document.clear_recovery()
		_pending.call())
	_view.add_child(_discard)
	_view.show_status("Add a block from the menu, or let a wire go on empty canvas. Save → Build .gd → select a scene node → Attach to selected.")
	if _document.recover():
		_view.show_status("Recovered an unnamed Blueprint. Use Save to choose its project file.")
	if OS.get_cmdline_user_args().has("--xre-test-blueprint-editor"):
		_run_editor_test.call_deferred()


func _exit_tree() -> void:
	if is_instance_valid(_view) and EditorInterface.get_selection().selection_changed.is_connected(_view.refresh_menu):
		EditorInterface.get_selection().selection_changed.disconnect(_view.refresh_menu)
	if EditorInterface.get_resource_filesystem().filesystem_changed.is_connected(_scripts_changed):
		EditorInterface.get_resource_filesystem().filesystem_changed.disconnect(_scripts_changed)
	if scene_changed.is_connected(_scene_changed): scene_changed.disconnect(_scene_changed)
	if get_tree().tree_changed.is_connected(_schedule_scene_refresh): get_tree().tree_changed.disconnect(_schedule_scene_refresh)
	if is_instance_valid(_view):
		_view.free()
	XREBlueprintDocument.release_editor_shared()
	_document = null


func _scene_changed(root: Node) -> void:
	_document.update_active_scene(root)


## Edited scripts may have new methods, static functions or tags for the add-block menu.
func _scripts_changed() -> void:
	XREBlueprintActions.shared().invalidate_scripts()
	if is_instance_valid(_view): _view.refresh_menu()


func _open_graph_scene() -> void:
	if _document.open_graph_scene():
		EditorInterface.set_main_screen_editor("Blueprints")
	else:
		_view.show_status(_document.last_error, true)


func _schedule_scene_refresh() -> void:
	if not _scene_refresh_pending:
		_scene_refresh_pending = true
		_refresh_scene.call_deferred()


func _refresh_scene() -> void:
	_scene_refresh_pending = false
	if _document != null: _document.refresh_bindings()


func _has_main_screen() -> bool:
	return true


func _get_plugin_name() -> String:
	return "Blueprints"


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("VisualShader", "EditorIcons")


func _make_visible(visible: bool) -> void:
	if is_instance_valid(_view):
		_view.visible = visible
		if visible:
			hide_bottom_panel()


func _handles(object: Object) -> bool:
	return object is XREBlueprintGraph


func _edit(object: Object) -> void:
	var graph := object as XREBlueprintGraph
	if graph == null or graph.resource_path.is_empty() or graph.resource_path == _document.path:
		return
	_confirm_discard(_load_path.bind(graph.resource_path))


func _get_unsaved_status(for_scene: String) -> String:
	if for_scene.is_empty() and _document != null and _document.is_dirty():
		return "Blueprints: " + (_document.path if not _document.path.is_empty() else "untitled graph (use Save in Blueprints)")
	return ""


func _save_external_data() -> void:
	if _document == null or not _document.is_dirty():
		return
	if _document.path.is_empty():
		_show_result(_document.save_recovery(), "Unnamed Blueprint saved for recovery. Use Save to choose its project file.")
	else:
		_show_result(_document.build(), "Blueprint saved and built.")


func _confirm_discard(action: Callable) -> void:
	if _document.is_dirty():
		_pending = action
		_discard.popup_centered()
	else:
		action.call()


func _new_requested() -> void:
	_confirm_discard(_document.new_graph)


func _open_requested() -> void:
	_confirm_discard(_show_open)


func _show_open() -> void:
	_files.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	_files.title = "Open Blueprint"
	_files.popup_centered_ratio(0.65)


func _save_requested() -> void:
	_save_then("save")


func _build_requested() -> void:
	_save_then("build")


func _attach_requested() -> void:
	_save_then("attach")


func _focus_requested() -> void:
	EditorInterface.set_distraction_free_mode(not EditorInterface.is_distraction_free_mode_enabled())
	hide_bottom_panel()


func _save_then(action: String) -> void:
	if not _view.validate_active_target(): return
	if _document.path.is_empty():
		_after_save = action
		_files.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
		_files.title = "Save Blueprint"
		_files.current_file = "blueprint.tres"
		_files.popup_centered_ratio(0.65)
	else:
		_finish_save(action)


func _finish_save(action: String) -> void:
	if not _view.validate_active_target(): return
	match action:
		"attach":
			_show_result(_document.attach_to_selected(get_undo_redo()), "Blueprint attached. Save the scene, then run it (F6).")
		"build":
			_show_result(_document.build(), "Built " + _document.script_path())
		_:
			_show_result(_document.build(), "Saved and built " + _document.script_path())


func _file_selected(path: String) -> void:
	if _files.file_mode == EditorFileDialog.FILE_MODE_OPEN_FILE:
		_load_path(path)
	elif _document.save_graph(path):
		_finish_save(_after_save)
	else:
		_show_result(false, "")


func _load_path(path: String) -> void:
	_show_result(_document.open_graph(path), "Opened " + path)


func _show_result(success: bool, message: String) -> void:
	_view.show_status(message if success else _document.last_error, not success)
	if success and not _document.path.is_empty() and not _document.is_dirty():
		_document.clear_recovery()


func _run_editor_test() -> void:
	# Host-project test harness is optional and is not a dependency of the addon.
	var test_path := "res://scripts/test_blueprint_editor.gd"
	if FileAccess.file_exists(test_path):
		var script := load(test_path) as GDScript
		var test := script.new() as Node
		add_child(test)
		test.call("run", self, _document, _view)
