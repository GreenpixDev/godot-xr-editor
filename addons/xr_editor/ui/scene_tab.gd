@tool
class_name XRESceneTab
extends XREPanelTab
## The edited scene's tree, as the desktop's Scene dock shows it: the scene's
## own nodes with their icons, and nodes inside instanced scenes only where
## their children are editable. Clicking a node selects it
## ([method XREDocument.select] from a panel); a selection made anywhere else
## shows here.
##
## The tree is rebuilt when nodes of the scene are added, removed or renamed
## ([signal SceneTree.node_added] and the like), at most once a frame and only
## while the tab is shown. Folded nodes stay folded across rebuilds.

var _tree: Tree
var _message: Label
var _root: Node
## Item of each shown node, by the node's instance ID.
var _items: Dictionary[int, TreeItem] = {}
## Instance IDs of the nodes the user folded.
var _folded: Dictionary[int, bool] = {}
## The tree's selection is being set to match the document's, not by the user.
var _syncing := false
var _selection_queued := false


func _init(document: XREDocument) -> void:
	super(document)
	name = "Scene"
	_tree = Tree.new()
	_tree.name = "Tree"
	_tree.select_mode = Tree.SELECT_MULTI
	_tree.size_flags_vertical = SIZE_EXPAND_FILL
	_tree.multi_selected.connect(_on_multi_selected)
	_tree.item_collapsed.connect(_on_item_collapsed)
	add_child(_tree)
	_message = _make_message(editor_text("This operation can't be done without a scene."))
	add_child(_message)


func get_title() -> String:
	return editor_text("Scene")


func get_icon_name() -> StringName:
	return &"PackedScene"


## The item of [param node], or null if the tree doesn't show it.
func get_item(node: Node) -> TreeItem:
	return _items.get(node.get_instance_id())


func get_tree_control() -> Tree:
	return _tree


func _enter_tree() -> void:
	_root = _document.get_scene_root()
	_document.scene_changed.connect(_on_scene_changed)
	_document.selection_changed.connect(_on_selection_changed)
	get_tree().node_added.connect(_on_node_changed)
	get_tree().node_removed.connect(_on_node_changed)
	get_tree().node_renamed.connect(_on_node_renamed)
	mark_dirty()


func _exit_tree() -> void:
	_document.scene_changed.disconnect(_on_scene_changed)
	_document.selection_changed.disconnect(_on_selection_changed)
	get_tree().node_added.disconnect(_on_node_changed)
	get_tree().node_removed.disconnect(_on_node_changed)
	get_tree().node_renamed.disconnect(_on_node_renamed)


func _refresh() -> void:
	_syncing = true
	_tree.clear()
	_items.clear()
	_root = _document.get_scene_root()
	_tree.visible = _root != null
	_message.visible = _root == null
	if _root != null:
		_add(_root, null)
	_syncing = false
	_sync_selection()


func _add(node: Node, parent: TreeItem) -> void:
	var id := node.get_instance_id()
	var item := _tree.create_item(parent)
	item.set_text(0, node.name)
	item.set_icon(0, _class_icon(StringName(node.get_class()), &"Node"))
	item.set_metadata(0, id)
	_items[id] = item
	for child: Node in node.get_children():
		if child.owner == _root or (child.owner != null and _root.is_editable_instance(child.owner)):
			_add(child, item)
	item.collapsed = _folded.has(id)


func _sync_selection() -> void:
	_syncing = true
	_tree.deselect_all()
	var first: TreeItem = null
	for node: Node in _document.get_selection():
		var item := get_item(node)
		if item != null:
			item.select(0)
			if first == null:
				first = item
	_syncing = false
	if first != null:
		_tree.scroll_to_item(first)


func _on_scene_changed() -> void:
	_root = _document.get_scene_root()
	mark_dirty()


func _on_selection_changed() -> void:
	# A refresh on its way syncs the selection anyway.
	if not is_dirty():
		_sync_selection()


## Called for every node added or removed anywhere in the editor: the cheap test first.
func _on_node_changed(node: Node) -> void:
	if is_instance_valid(_root) and (node == _root or _root.is_ancestor_of(node)):
		mark_dirty()


func _on_node_renamed(node: Node) -> void:
	var item := get_item(node)
	if item != null:
		item.set_text(0, node.name)


func _on_multi_selected(_item: TreeItem, _column: int, _selected: bool) -> void:
	# One click deselects some items and selects another: select once, after it.
	if _syncing or _selection_queued:
		return
	_selection_queued = true
	_select_from_tree.call_deferred()


func _select_from_tree() -> void:
	_selection_queued = false
	var nodes: Array[Node] = []
	var item := _tree.get_next_selected(null)
	while item != null:
		var id: int = item.get_metadata(0)
		var node := instance_from_id(id) as Node
		if node != null:
			nodes.append(node)
		item = _tree.get_next_selected(item)
	if nodes != _document.get_selection():
		_document.select(nodes, XREDocument.Source.PANEL)


func _on_item_collapsed(item: TreeItem) -> void:
	var id: int = item.get_metadata(0)
	if item.collapsed:
		_folded[id] = true
	else:
		_folded.erase(id)
