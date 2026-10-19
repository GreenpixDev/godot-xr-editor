@tool
class_name XREFileSystemTab
extends XREPanelTab
## The project's folders and files, as the desktop's FileSystem dock lists
## them, with the icons of their types. A folder's entries are read when it is
## unfolded, so that a large project costs nothing until it is browsed.
## Unfolded folders and the selected file stay across refreshes.
##
## A double click on a scene, or Open under the tree, opens it for editing
## ([method XREDocument.open_scene] from a panel), at the end of the frame:
## the editor may run main loop iterations while it loads. The panels stay as
## they are and show the scene now edited. Refreshed when the project's files
## change ([signal XREDocument.files_changed]) and when the tab is shown.

const ROOT := "res://"

var _tree: Tree
var _open: Button
## Folders the user unfolded, as paths ending with a slash.
var _unfolded: Dictionary[String, bool] = {ROOT: true}
## The tree is being filled: folding it is not the user's doing.
var _building := false


func _init(document: XREDocument) -> void:
	super(document)
	name = "FileSystem"
	_tree = Tree.new()
	_tree.name = "Tree"
	_tree.size_flags_vertical = SIZE_EXPAND_FILL
	_tree.item_collapsed.connect(_on_item_collapsed)
	_tree.item_selected.connect(_update_open)
	_tree.item_activated.connect(_on_item_activated)
	add_child(_tree)
	_open = Button.new()
	_open.name = "Open"
	_open.text = editor_text("Open")
	_open.disabled = true
	_open.size_flags_horizontal = SIZE_SHRINK_END
	_open.pressed.connect(_open_selected)
	add_child(_open)


func get_title() -> String:
	return editor_text("FileSystem")


func get_symbol() -> StringName:
	return &"files"


func get_tree_control() -> Tree:
	return _tree


func get_open_button() -> Button:
	return _open


## The item of the file or folder at [param path] (folders end with a slash),
## or null if no unfolded folder shows it.
func get_item(path: String) -> TreeItem:
	return _find(_tree.get_root(), path)


func _enter_tree() -> void:
	_document.files_changed.connect(mark_dirty)
	_open.icon = _icon(&"Load")
	mark_dirty()


func _exit_tree() -> void:
	_document.files_changed.disconnect(mark_dirty)


func _refresh() -> void:
	var selected := _selected_path()
	_building = true
	_tree.clear()
	var root := _tree.create_item()
	root.set_text(0, ROOT)
	root.set_icon(0, _icon(&"Folder"))
	root.set_metadata(0, ROOT)
	_fill(root, ROOT)
	_building = false
	var item := get_item(selected) if not selected.is_empty() else null
	if item != null:
		item.select(0)
	_update_open()


## Adds the entries of the folder at [param path] under [param folder_item].
func _fill(folder_item: TreeItem, path: String) -> void:
	for entry: String in _document.list_folder(path):
		var item := _tree.create_item(folder_item)
		if entry.ends_with("/"):
			var folder := path + entry
			item.set_text(0, entry.trim_suffix("/"))
			item.set_icon(0, _icon(&"Folder"))
			item.set_metadata(0, folder)
			if _unfolded.has(folder):
				_fill(item, folder)
			else:
				# Gives the folder its arrow; replaced by the entries when unfolded.
				_tree.create_item(item).set_metadata(0, "")
				item.collapsed = true
		else:
			var file := path + entry
			item.set_text(0, entry)
			item.set_icon(0, _class_icon(_document.get_file_type(file), &"File"))
			item.set_metadata(0, file)


func _find(item: TreeItem, path: String) -> TreeItem:
	if item == null:
		return null
	var item_path: String = item.get_metadata(0)
	if item_path == path:
		return item
	if not item_path.ends_with("/") or not path.begins_with(item_path):
		return null
	for child: TreeItem in item.get_children():
		var found := _find(child, path)
		if found != null:
			return found
	return null


func _selected_path() -> String:
	var item := _tree.get_selected()
	if item == null:
		return ""
	var path: String = item.get_metadata(0)
	return path


func _on_item_collapsed(item: TreeItem) -> void:
	if _building:
		return
	var path: String = item.get_metadata(0)
	if not path.ends_with("/"):
		return
	if item.collapsed:
		_unfolded.erase(path)
	else:
		_unfolded[path] = true
		# Not while the tree handles the click that unfolded the folder.
		_unfold.call_deferred(item, path)


func _unfold(item: TreeItem, path: String) -> void:
	if not is_instance_valid(item) or item.collapsed:
		return
	var first := item.get_first_child()
	if first == null or not String(first.get_metadata(0)).is_empty():
		return
	first.free()
	_building = true
	_fill(item, path)
	_building = false


func _on_item_activated() -> void:
	var item := _tree.get_selected()
	if item == null:
		return
	var path: String = item.get_metadata(0)
	if path.ends_with("/"):
		item.collapsed = not item.collapsed
	else:
		_open_scene(path)


func _update_open() -> void:
	_open.disabled = not XREDocument.is_scene_file(_selected_path())


func _open_selected() -> void:
	_open_scene(_selected_path())


func _open_scene(path: String) -> void:
	if XREDocument.is_scene_file(path):
		_document.open_scene.call_deferred(path, XREDocument.Source.PANEL)
