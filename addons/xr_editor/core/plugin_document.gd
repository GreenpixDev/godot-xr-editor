@tool
class_name XREPluginDocument
extends XREDocument
## [XREDocument] backed by the running Godot editor.
##
## Every change goes into the editor's own undo history, so anything done in
## the headset shows up on the desktop immediately and can be undone with Ctrl+Z.

var _plugin: EditorPlugin


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


func select(nodes: Array[Node]) -> void:
	var selection := EditorInterface.get_selection()
	selection.clear()
	for node in nodes:
		selection.add_node(node)


func preview_transform(node: Node3D, xform: Transform3D) -> void:
	node.transform = xform


func commit_transform(node: Node3D, before: Transform3D) -> void:
	var undo_redo := _plugin.get_undo_redo()
	undo_redo.create_action("XR: Transform %s" % node.name)
	undo_redo.add_do_property(node, &"transform", node.transform)
	undo_redo.add_undo_property(node, &"transform", before)
	undo_redo.commit_action()


func set_property(object: Object, property: StringName, value: Variant) -> void:
	var undo_redo := _plugin.get_undo_redo()
	undo_redo.create_action("XR: Set %s" % property)
	undo_redo.add_do_property(object, property, value)
	undo_redo.add_undo_property(object, property, object.get(property))
	undo_redo.commit_action()


func add_node(node: Node, parent: Node) -> void:
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


func remove_node(node: Node) -> void:
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


func save() -> Error:
	return EditorInterface.save_scene()


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
