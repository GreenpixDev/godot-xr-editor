@tool
class_name XREPluginDocument
extends XREDocument
## [XREDocument] backed by the running Godot editor.
##
## Every change goes into the editor's own undo history, so anything done in
## the headset shows up on the desktop immediately and can be undone with Ctrl+Z.

## Where [method separate_executable] keeps its copy: build/ is neither in git nor scanned by the editor.
const SEPARATE_EXECUTABLE_DIR := "res://build/xre_play"

var _plugin: EditorPlugin
## Process of a game run by [method _play_separately], or 0.
var _game_pid := 0


func _init(plugin: EditorPlugin) -> void:
	_plugin = plugin
	EditorInterface.get_selection().selection_changed.connect(selection_changed.emit)
	plugin.scene_changed.connect(_on_scene_changed)


## Disconnects from editor signals. Call from [method EditorPlugin._exit_tree].
func dispose() -> void:
	EditorInterface.get_selection().selection_changed.disconnect(selection_changed.emit)
	_plugin.scene_changed.disconnect(_on_scene_changed)


func get_scene_root() -> Node:
	return EditorInterface.get_edited_scene_root()


func get_selection() -> Array[Node]:
	return EditorInterface.get_selection().get_selected_nodes()


func select(nodes: Array[Node], source: Source) -> void:
	var selection := EditorInterface.get_selection()
	selection.clear()
	for node in nodes:
		selection.add_node(node)
	_record(&"select", source, nodes)


func preview_transform(node: Node3D, xform: Transform3D) -> void:
	node.transform = xform


func commit_transform(node: Node3D, before: Transform3D, source: Source) -> void:
	var undo_redo := _plugin.get_undo_redo()
	undo_redo.create_action("XR: Transform %s" % node.name)
	undo_redo.add_do_property(node, &"transform", node.transform)
	undo_redo.add_undo_property(node, &"transform", before)
	undo_redo.commit_action()
	_record(&"transform", source, [node])


func set_property(object: Object, property: StringName, value: Variant, source: Source) -> void:
	var undo_redo := _plugin.get_undo_redo()
	undo_redo.create_action("XR: Set %s" % property)
	undo_redo.add_do_property(object, property, value)
	undo_redo.add_undo_property(object, property, object.get(property))
	undo_redo.commit_action()
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
	undo_redo.commit_action()
	_record(&"add_node", source, [node])


func remove_node(node: Node, source: Source) -> void:
	var root := get_scene_root()
	if node == root:
		push_error("XR Editor: cannot remove the scene root.")
		return
	var parent := node.get_parent()
	var undo_redo := _plugin.get_undo_redo()
	undo_redo.create_action("XR: Remove %s" % node.name)
	undo_redo.add_do_method(parent, &"remove_child", node)
	undo_redo.add_undo_method(parent, &"add_child", node, true)
	undo_redo.add_undo_method(parent, &"move_child", node, node.get_index())
	for owned in _nodes_owned_by(node, root, false):
		undo_redo.add_undo_method(owned, &"set_owner", root)
	undo_redo.add_undo_reference(node)
	undo_redo.commit_action()
	_record(&"remove_node", source, [node])


func save(source: Source) -> Error:
	var error := EditorInterface.save_scene()
	if error == OK:
		_record(&"save", source, [get_scene_root()])
	return error


func play(source: Source, separate_app: bool) -> Error:
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


## Runs the scene as Play would, but from [method separate_executable]: the
## editor's Play always runs its own executable. The game gets no debugger, and
## its output goes to its own log, [code]user://logs/godot.log[/code].
func _play_separately(scene_path: String) -> Error:
	_stop_separate_game()
	if EditorInterface.is_playing_scene():
		EditorInterface.stop_playing_scene()
	if EditorInterface.get_editor_settings().get_setting("run/auto_save/save_before_running"):
		EditorInterface.save_all_scenes()
	var executable := separate_executable()
	if executable.is_empty():
		return ERR_CANT_CREATE
	# The arguments the plugin gives the editor's Play while the VR view is on.
	var args := XREPlayMode.game_args(PackedStringArray([
			"--path", ProjectSettings.globalize_path("res://"), "--scene", scene_path]))
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
	scene_changed.emit()


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
