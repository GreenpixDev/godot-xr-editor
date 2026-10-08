@tool
class_name XRESignalsTab
extends XREPanelTab
## The signals of the selected node and where they go, as the Signals tab of
## the desktop's Node dock lists them: the script's signals first, then each
## class's, from the node's own class up to Object, each sorted by name. Under
## a signal are its connections saved with the scene
## ([constant Object.CONNECT_PERSIST]) as [code]→ target :: method()[/code];
## connections made at run time, the editor's own among them, are left out.
##
## Read only (docs/decisions.md, D-016): in the headset, signals are to be
## connected in the logic graph (docs/plan.md). Refreshed when the selection
## or the scene changes, and when the tab is shown.

var _tree: Tree
var _message: Label


func _init(document: XREDocument) -> void:
	super(document)
	name = "Signals"
	_tree = Tree.new()
	_tree.name = "Tree"
	_tree.hide_root = true
	_tree.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(_tree)
	_message = _make_message(editor_text("This operation requires a single selected node."))
	add_child(_message)


func get_title() -> String:
	return editor_text("Signals")


func get_icon_name() -> StringName:
	return &"Signals"


func get_tree_control() -> Tree:
	return _tree


## [param info], a signal as [method Object.get_signal_list] describes it, as
## the Node dock writes it: [code]body_entered(body: Node3D)[/code].
static func signature(info: Dictionary) -> String:
	var args: Array[String] = []
	var arg_list: Array = info["args"]
	for arg: Dictionary in arg_list:
		var type: int = arg["type"]
		var type_name: String = arg["class_name"]
		if type_name.is_empty():
			type_name = "Variant" if type == TYPE_NIL else type_string(type)
		args.append("%s: %s" % [arg["name"], type_name])
	return "%s(%s)" % [info["name"], ", ".join(args)]


func _enter_tree() -> void:
	_document.selection_changed.connect(mark_dirty)
	_document.scene_changed.connect(mark_dirty)
	mark_dirty()


func _exit_tree() -> void:
	_document.selection_changed.disconnect(mark_dirty)
	_document.scene_changed.disconnect(mark_dirty)


func _refresh() -> void:
	_tree.clear()
	var nodes := _document.get_selection()
	var node: Node = nodes[0] if nodes.size() == 1 else null
	_tree.visible = node != null
	_message.visible = node == null
	if node == null:
		return
	var top := _tree.create_item()
	var script := node.get_script() as Script
	if script != null:
		var script_name := String(script.get_global_name())
		_add_class(top, node, script_name if not script_name.is_empty() else script.resource_path.get_file(),
				&"Script", script.get_script_signal_list())
	var type := StringName(node.get_class())
	while not type.is_empty():
		_add_class(top, node, type, type, ClassDB.class_get_signal_list(type, true))
		type = ClassDB.get_parent_class(type)


func _add_class(top: TreeItem, node: Node, title: String, icon_type: StringName, signals: Array[Dictionary]) -> void:
	if signals.is_empty():
		return
	var category := _tree.create_item(top)
	category.set_text(0, title)
	category.set_icon(0, _class_icon(icon_type, &"Object"))
	category.set_selectable(0, false)
	if has_theme_color(&"prop_category", &"Editor"):
		category.set_custom_bg_color(0, get_theme_color(&"prop_category", &"Editor"))
	var sorted := signals.duplicate()
	sorted.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a["name"]).naturalnocasecmp_to(String(b["name"])) < 0)
	var signal_icon := _icon(&"Signal")
	var slot_icon := _icon(&"Slot")
	for info: Dictionary in sorted:
		var signal_name: String = info["name"]
		var item := _tree.create_item(category)
		item.set_text(0, signature(info))
		item.set_icon(0, signal_icon)
		item.set_metadata(0, signal_name)
		for connection: Dictionary in node.get_signal_connection_list(signal_name):
			var flags: int = connection["flags"]
			if flags & CONNECT_PERSIST == 0:
				continue
			var callable: Callable = connection["callable"]
			var slot := _tree.create_item(item)
			slot.set_text(0, "→ %s :: %s()" % [_target_name(callable.get_object()), callable.get_method()])
			slot.set_icon(0, slot_icon)
			slot.set_selectable(0, false)


## How the Node dock names a connection's target: its path from the scene root.
func _target_name(target: Object) -> String:
	var node := target as Node
	var root := _document.get_scene_root()
	if node != null and root != null and (node == root or root.is_ancestor_of(node)):
		return String(root.get_path_to(node))
	if node != null:
		return String(node.name)
	return str(target)
