@tool
class_name XREPluginDocument
extends XREDocument
## [XREDocument] backed by the running Godot editor.
##
## Every change goes into the editor's own undo history, so anything done in
## the headset shows up on the desktop immediately and can be undone with Ctrl+Z.
## It is a change of [member XREDocument.history] too (D-087), which the undo
## in the headset puts back by the editor's own Undo of the Scene menu, as
## Ctrl+Z does: a script can't undo through [EditorUndoRedoManager], and
## undoing the scene's [UndoRedo] itself would leave the manager's own record
## of what to undo next behind. Once the scene's history changes past the
## headset — an edit or Ctrl+Z on the desktop — the headset's changes of the
## scene are forgotten ([method XREHistory.forget]).

## Where [method separate_executable] keeps its copy: build/ is neither in git nor scanned by the editor.
const SEPARATE_EXECUTABLE_DIR := "res://build/xre_play"
## File of the feature settings ([member XREDocument.features]) in the project's .godot/editor/.
const FEATURES_FILE := "xr_editor_features.cfg"
## Ids of Undo and Redo in the editor's Scene menu: EditorNode's EDIT_UNDO and
## EDIT_REDO in 4.7.2, which picking them sends to EditorNode::_menu_option.
const _EDIT_UNDO := 13
const _EDIT_REDO := 14

var _plugin: EditorPlugin
## Process of a game run by [method _play_separately], or 0.
var _game_pid := 0
## The editor's Scene menu, once found ([method _scene_menu]).
var _scene_menu_found: PopupMenu
## This document is changing the editor's undo history: what it hears of it meanwhile is its own.
var _changing := false
## Process frame the edited scene last changed in ([method _scene_switched_this_frame]), or -1.
var _scene_changed_frame := -1


func _init(plugin: EditorPlugin) -> void:
	_plugin = plugin
	# Per project and machine, outside git: the researcher sets the variant on the study's computer.
	features = XREFeatureSettings.new(EditorInterface.get_editor_paths().get_project_settings_dir().path_join(FEATURES_FILE))
	print("XR Editor: features ", features.describe())
	EditorInterface.get_selection().selection_changed.connect(selection_changed.emit)
	EditorInterface.get_resource_filesystem().filesystem_changed.connect(files_changed.emit)
	plugin.scene_changed.connect(_on_scene_changed)
	plugin.get_undo_redo().version_changed.connect(blueprint_bindings_changed.emit)
	plugin.get_undo_redo().history_changed.connect(blueprint_bindings_changed.emit)
	plugin.get_undo_redo().version_changed.connect(_on_editor_history_changed)
	plugin.get_undo_redo().history_changed.connect(_on_editor_history_changed)


## Disconnects from editor signals. Call from [method EditorPlugin._exit_tree].
func dispose() -> void:
	EditorInterface.get_selection().selection_changed.disconnect(selection_changed.emit)
	EditorInterface.get_resource_filesystem().filesystem_changed.disconnect(files_changed.emit)
	_plugin.scene_changed.disconnect(_on_scene_changed)
	_plugin.get_undo_redo().version_changed.disconnect(blueprint_bindings_changed.emit)
	_plugin.get_undo_redo().history_changed.disconnect(blueprint_bindings_changed.emit)
	_plugin.get_undo_redo().version_changed.disconnect(_on_editor_history_changed)
	_plugin.get_undo_redo().history_changed.disconnect(_on_editor_history_changed)


func get_scene_root() -> Node:
	return EditorInterface.get_edited_scene_root()


func get_selection() -> Array[Node]:
	return EditorInterface.get_selection().get_selected_nodes()


func assign_blueprint(host: Node, path: String, script: Script, source: Source) -> bool:
	var root := get_scene_root()
	if host == null or root == null or not (host == root or root.is_ancestor_of(host)):
		return false
	var previous := host.get_script() as Script
	if previous != null and previous != script:
		if not previous.resource_path.ends_with(".generated.gd") or not previous.source_code.begins_with(XREBlueprintCompiler.HEADER):
			return false
	var had_source := host.has_meta(&"_xre_blueprint")
	var previous_path: Variant = host.get_meta(&"_xre_blueprint", "")
	if previous == script and str(previous_path) == path and (not path.is_empty() or not had_source): return true
	var undo_redo := _plugin.get_undo_redo()
	undo_redo.create_action("XR: Detach Blueprint" if path.is_empty() else "XR: Assign Blueprint", UndoRedo.MERGE_DISABLE, host)
	undo_redo.add_do_method(host, &"set_script", script)
	if path.is_empty(): undo_redo.add_do_method(host, &"remove_meta", &"_xre_blueprint")
	else: undo_redo.add_do_method(host, &"set_meta", &"_xre_blueprint", path)
	undo_redo.add_undo_method(host, &"set_script", previous)
	if had_source: undo_redo.add_undo_method(host, &"set_meta", &"_xre_blueprint", previous_path)
	else: undo_redo.add_undo_method(host, &"remove_meta", &"_xre_blueprint")
	_commit(undo_redo, host)
	_record(&"detach_blueprint" if path.is_empty() else &"assign_blueprint", source, [host])
	return true


func select(nodes: Array[Node], source: Source) -> void:
	var before := get_selection()
	_set_selection(nodes)
	_record(&"select", source, nodes)
	_remember_selection(before)


func preview_transform(node: Node3D, xform: Transform3D) -> void:
	node.transform = xform


func commit_transform(node: Node3D, before: Transform3D, source: Source) -> void:
	var undo_redo := _plugin.get_undo_redo()
	undo_redo.create_action("XR: Transform %s" % node.name)
	undo_redo.add_do_property(node, &"transform", node.transform)
	undo_redo.add_undo_property(node, &"transform", before)
	_commit(undo_redo, node)
	_record(&"transform", source, [node])


func set_property(object: Object, property: StringName, value: Variant, source: Source) -> void:
	var undo_redo := _plugin.get_undo_redo()
	undo_redo.create_action("XR: Set %s" % property)
	undo_redo.add_do_property(object, property, value)
	undo_redo.add_undo_property(object, property, object.get(property))
	_commit(undo_redo, object)
	var nodes: Array[Node] = []
	if object is Node:
		nodes.append(object as Node)
	_record(&"set_property", source, nodes)


func preview_property(object: Object, property: StringName, value: Variant) -> void:
	object.set(property, value)


func commit_property(object: Object, property: StringName, before: Variant, source: Source) -> void:
	var undo_redo := _plugin.get_undo_redo()
	undo_redo.create_action("XR: Set %s" % property)
	undo_redo.add_do_property(object, property, object.get(property))
	undo_redo.add_undo_property(object, property, before)
	_commit(undo_redo, object)
	var nodes: Array[Node] = []
	if object is Node:
		nodes.append(object as Node)
	_record(&"set_property", source, nodes)


func add_node(node: Node, parent: Node, source: Source) -> void:
	var root := get_scene_root()
	var undo_redo := _plugin.get_undo_redo()
	undo_redo.create_action("XR: Add %s" % node.name)
	undo_redo.add_do_method(parent, &"add_child", node, true)
	# Owners must be re-applied on every redo: remove_child() on undo clears them.
	for owned in _nodes_owned_by(node, root, true):
		undo_redo.add_do_method(owned, &"set_owner", root)
	undo_redo.add_do_reference(node)
	undo_redo.add_undo_method(parent, &"remove_child", node)
	_commit(undo_redo, parent)
	_record(&"add_node", source, [node])


func remove_nodes(nodes: Array[Node], source: Source) -> void:
	var root := get_scene_root()
	var removed := nodes_to_remove(nodes, root)
	if removed.is_empty():
		return
	var undo_redo := _plugin.get_undo_redo()
	undo_redo.create_action("XR: Remove %s" % removed[0].name if removed.size() == 1
			else "XR: Remove %d Nodes" % removed.size())
	# Undo runs its calls in the order they were added: in tree order, each
	# node goes back at its old index, as Delete does on the desktop.
	for node: Node in removed:
		var parent := node.get_parent()
		undo_redo.add_do_method(parent, &"remove_child", node)
		undo_redo.add_undo_method(parent, &"add_child", node, true)
		undo_redo.add_undo_method(parent, &"move_child", node, node.get_index())
		for owned: Node in _nodes_owned_by(node, root, false):
			undo_redo.add_undo_method(owned, &"set_owner", root)
		undo_redo.add_undo_reference(node)
	_commit(undo_redo, root)
	_record(&"remove_nodes", source, removed)


func save(source: Source) -> Error:
	var error := EditorInterface.save_scene()
	if error == OK:
		_record(&"save", source, [get_scene_root()])
	return error


func open_scene(path: String, source: Source) -> Error:
	if not is_scene_file(path):
		return ERR_FILE_UNRECOGNIZED
	if not ResourceLoader.exists(path):
		return ERR_FILE_NOT_FOUND
	var previous := get_scene_root()
	var before := previous.scene_file_path if previous != null else ""
	if before != path and _scene_switched_this_frame():
		return ERR_BUSY
	if not _switch_scene(path) and (previous == null or before != path):
		return FAILED
	_record(&"open_scene", source, [get_scene_root()])
	# Undo goes back to the scene edited before, if it has a file to switch to.
	if not before.is_empty() and before != path:
		history.record(XREHistory.Kind.VIEW, "Open %s" % path.get_file(), _switch_scene.bind(before), _switch_scene.bind(path))
	return OK


## Lists what the editor's file system knows: the same folders and files the
## FileSystem dock shows, without a scan of the disk.
func list_folder(path: String) -> PackedStringArray:
	var folder := EditorInterface.get_resource_filesystem().get_filesystem_path(path)
	var result := PackedStringArray()
	if folder == null:
		return result
	var names: Array[String] = []
	for i: int in folder.get_subdir_count():
		names.append(folder.get_subdir(i).get_name() + "/")
	names.sort_custom(_natural_order)
	result.append_array(names)
	names.clear()
	for i: int in folder.get_file_count():
		names.append(folder.get_file(i))
	names.sort_custom(_natural_order)
	result.append_array(names)
	return result


func get_class_icon(cls: StringName) -> Texture2D:
	var theme := EditorInterface.get_editor_theme()
	return theme.get_icon(cls, &"EditorIcons") if theme != null and theme.has_icon(cls, &"EditorIcons") else null


func get_file_type(path: String) -> StringName:
	return StringName(EditorInterface.get_resource_filesystem().get_file_type(path))


func play(source: Source, separate_app: bool) -> Error:
	if prepare_play.is_valid() and not bool(prepare_play.call()):
		return ERR_INVALID_DATA
	var root := get_scene_root()
	# Without a file, the editor opens a save dialog on the desktop instead of playing.
	if root == null or root.scene_file_path.is_empty():
		return ERR_UNCONFIGURED
	if separate_app:
		var error := _play_separately(root.scene_file_path)
		if error != OK:
			return error
	else:
		EditorInterface.play_current_scene()
		# The editor starts the game process before it returns, or doesn't start it at all.
		if not EditorInterface.is_playing_scene():
			return FAILED
	_record(&"play", source, [root])
	return OK


func stop_playing(source: Source) -> void:
	if _separate_game_running():
		OS.kill(_game_pid)
		_game_pid = 0
	elif EditorInterface.is_playing_scene():
		EditorInterface.stop_playing_scene()
	else:
		return
	_record(&"stop", source, [])


func is_playing() -> bool:
	return _separate_game_running() or EditorInterface.is_playing_scene()


## A copy of the editor's executable to run games from as another application:
## SteamVR takes processes of one executable for one application
## ([XREHandoffBenchmark]). Made on first use (~180 MB) and again whenever the
## editor's executable is newer. Returns its path, or an empty string if it
## can't be made.
static func separate_executable() -> String:
	var source := OS.get_executable_path()
	var extension := source.get_extension()
	var target := ProjectSettings.globalize_path(SEPARATE_EXECUTABLE_DIR).path_join(
			source.get_file().get_basename() + "_xre_play" + ("." + extension if not extension.is_empty() else ""))
	if FileAccess.file_exists(target) and FileAccess.get_modified_time(target) >= FileAccess.get_modified_time(source):
		return target
	print("XR Editor: copying the Godot executable to %s to run games as a separate application." % target)
	DirAccess.make_dir_recursive_absolute(target.get_base_dir())
	var error := DirAccess.copy_absolute(source, target)
	if error != OK:
		push_error("XR Editor: could not copy the Godot executable to %s (%s)." % [target, error_string(error)])
		return ""
	return target


## Runs the scene as Play would, but without it: from [method separate_executable],
## because the editor's Play always runs its own executable, or on a standalone
## headset in this very process (D-018). The game gets no debugger, and its
## output goes to its own log, [code]user://logs/godot.log[/code].
func _play_separately(scene_path: String) -> Error:
	_stop_separate_game()
	if EditorInterface.is_playing_scene():
		EditorInterface.stop_playing_scene()
	if EditorInterface.get_editor_settings().get_setting("run/auto_save/save_before_running"):
		EditorInterface.save_all_scenes()
	# The arguments the plugin gives the editor's Play while the VR view is on.
	var args := XREPlayMode.game_args(PackedStringArray([
			"--path", ProjectSettings.globalize_path("res://"), "--scene", scene_path]), features)
	if XREStandalone.is_standalone():
		# From the XR activity, the new instance replaces this process.
		return OK if OS.create_instance(args) >= 0 else ERR_CANT_FORK
	var executable := separate_executable()
	if executable.is_empty():
		return ERR_CANT_CREATE
	var pid := OS.create_process(executable, args)
	if pid <= 0:
		return ERR_CANT_FORK
	_game_pid = pid
	return OK


## Stops a game run by [method _play_separately] without recording an operation.
func _stop_separate_game() -> void:
	if _separate_game_running():
		OS.kill(_game_pid)
	_game_pid = 0


func _separate_game_running() -> bool:
	if _game_pid != 0 and not OS.is_process_running(_game_pid):
		_game_pid = 0
	return _game_pid != 0


## The desktop editor's snap settings (Transform → Configure Snap), so both
## views snap to the same steps.
func get_snap() -> XRESnap:
	return XRESnap.new(EditorInterface.is_node_3d_snap_enabled(), EditorInterface.get_node_3d_translate_snap(),
			EditorInterface.get_node_3d_rotate_snap(), EditorInterface.get_node_3d_scale_snap())


func _on_scene_changed(_scene_root: Node) -> void:
	_scene_changed_frame = Engine.get_process_frames()
	scene_changed.emit()


## Whether the edited scene changed in this frame, on the desktop or here.
## Godot 4.7.2 can't switch scenes again until the frame's deferred calls
## have run: a switch has the Scene dock scroll to each selected node's
## TreeItem later, and the next switch frees those items first, a use after
## free that crashes the editor (D-092). So one switch a frame.
func _scene_switched_this_frame() -> bool:
	return _scene_changed_frame == Engine.get_process_frames()


## Commits the action [param undo_redo] is building and records it in
## [member XREDocument.history], by the history of [param object]: what puts
## it back is the editor's own Undo, what makes it again its Redo (D-087).
func _commit(undo_redo: EditorUndoRedoManager, object: Object) -> void:
	_changing = true
	undo_redo.commit_action()
	_changing = false
	var id := undo_redo.get_object_history_id(object)
	var actions := undo_redo.get_history_undo_redo(id)
	var action := actions.get_current_action_name()
	history.record(XREHistory.Kind.SCENE, action.trim_prefix("XR: "), _editor_undo.bind(id, actions.get_version(), action),
			_editor_redo.bind(id, actions.get_version(), action))


## Undoes [param action], made when the editor's history [param id] came to
## [param version], by the Scene menu's Undo. False, and nothing done, if that
## history has moved since or isn't the edited scene's: the editor's Undo
## would undo something else.
func _editor_undo(id: int, version: int, action: String) -> bool:
	var actions := _plugin.get_undo_redo().get_history_undo_redo(id)
	if actions.get_version() != version or actions.get_current_action_name() != action or not _edits_history(id):
		return false
	_pick_scene_menu(_EDIT_UNDO)
	return actions.get_version() != version


## Redoes [param action] by the Scene menu's Redo, as [method _editor_undo]
## undoes it. False, and nothing done, if it isn't the next to redo.
func _editor_redo(id: int, version: int, action: String) -> bool:
	var manager := _plugin.get_undo_redo()
	var actions := manager.get_history_undo_redo(id)
	if actions.get_version() != version - 1 or not actions.has_redo() or not _edits_history(id) \
			or actions.get_action_name(actions.get_current_action() + 1) != action:
		return false
	# The editor redoes the global history first if it can.
	if manager.get_history_undo_redo(EditorUndoRedoManager.GLOBAL_HISTORY).has_redo():
		return false
	_pick_scene_menu(_EDIT_REDO)
	return actions.get_version() == version


## Whether [param id] is the edited scene's history, which the Scene menu's Undo and Redo work on.
func _edits_history(id: int) -> bool:
	var root := get_scene_root()
	return root != null and _plugin.get_undo_redo().get_object_history_id(root) == id


## Picks item [param id] of the editor's Scene menu, as a click on it does.
func _pick_scene_menu(id: int) -> void:
	var menu := _scene_menu()
	if menu == null:
		push_error("XR Editor: the editor's Scene menu with Undo and Redo is not found.")
		return
	_changing = true
	menu.id_pressed.emit(id)
	_changing = false


## The editor's Scene menu: the menu of its main menu bar with Undo and Redo.
func _scene_menu() -> PopupMenu:
	if is_instance_valid(_scene_menu_found):
		return _scene_menu_found
	for bar: Node in EditorInterface.get_base_control().find_children("*", "MenuBar", true, false):
		for child: Node in bar.get_children():
			var menu := child as PopupMenu
			if menu != null and menu.get_item_index(_EDIT_UNDO) >= 0 and menu.get_item_index(_EDIT_REDO) >= 0:
				_scene_menu_found = menu
				return menu
	return null


## The editor's undo history changed. Past this document — an edit, Ctrl+Z or
## a scene closed on the desktop — the headset's changes of the scene can no
## longer be put back by the editor's Undo in turn: they are forgotten.
func _on_editor_history_changed() -> void:
	if not _changing and not history.is_replaying():
		history.forget(XREHistory.Kind.SCENE)


## The editor doesn't undo while a mouse button is down; nor does the headset
## then. Nor in a frame the edited scene changed in: the step may switch
## scenes again ([method _scene_switched_this_frame]). It waits in the
## history meanwhile; a step makes at most one switch, as it holds one frame's changes.
func _may_replay() -> bool:
	return Input.get_mouse_button_mask() & (MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT | MOUSE_BUTTON_MASK_MIDDLE) == 0 \
			and not _scene_switched_this_frame()


func _set_selection(nodes: Array[Node]) -> void:
	var selection := EditorInterface.get_selection()
	selection.clear()
	for node: Node in nodes:
		selection.add_node(node)


## Edits the scene saved at [param path], opening it or switching to its tab,
## for [method open_scene], its undo and its redo. False if it is edited
## already, can't be opened or the edited scene changed in this frame.
func _switch_scene(path: String) -> bool:
	var root := get_scene_root()
	if path.is_empty() or (root != null and root.scene_file_path == path) or not ResourceLoader.exists(path) \
			or _scene_switched_this_frame():
		return false
	_changing = true
	EditorInterface.open_scene_from_path(path)
	_changing = false
	root = get_scene_root()
	return root != null and root.scene_file_path == path


## Names in the order the FileSystem dock sorts them: case aside, numbers by value.
static func _natural_order(a: String, b: String) -> bool:
	return a.naturalnocasecmp_to(b) < 0


## [param node] and its descendants whose owner is [param root]; with
## [param include_unowned], also those with no owner yet (freshly built subtrees).
## Nodes inside instanced scenes are skipped: their owner is the instance root.
func _nodes_owned_by(node: Node, root: Node, include_unowned: bool) -> Array[Node]:
	var result: Array[Node] = []
	if node.owner == root or (include_unowned and node.owner == null):
		result.append(node)
	for child in node.get_children():
		result.append_array(_nodes_owned_by(child, root, include_unowned))
	return result
