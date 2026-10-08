@tool
class_name XREInspectorProxy
extends RefCounted
## What the inspector in the headset ([XREInspectorTab]) edits in place of a
## node, so that its edits go through [XREDocument] (docs/decisions.md, D-016).
##
## The editor's own [EditorInspector] writes into the object it edits and
## records an undo step itself, past the document. This object has the node's
## properties and tells the inspector to leave undo alone
## ([code]_dont_undo_redo[/code], as the editor's MultiNodeEdit does). A value
## the inspector sets is previewed on the node ([method XREDocument.preview_property]);
## [method commit] makes everything set to one property since the last commit one undo step and one
## operation. The panel commits when the pointer's button goes up, so that
## dragging a number is one operation, as dragging a node is.
## [br][br]
## What the inspector can't edit in the headset is read only: resources and
## other objects (their own inspectors would write past the document), and
## node paths (the editor resolves them against the desktop's inspector). The
## node's script and the buttons to add metadata are left out.

var _document: XREDocument
var _target: Object
var _properties: Array[Dictionary] = []
var _names: Dictionary[StringName, bool] = {}
## The property being edited since the last commit, or empty.
var _editing := &""
## Its value before the edit.
var _before: Variant


func _init(document: XREDocument, target: Object) -> void:
	_document = document
	_target = target
	_target.property_list_changed.connect(_on_target_property_list_changed)
	_update_properties()


## The object edited through this proxy.
func get_target() -> Object:
	return _target


## Whether a value was set since the last [method commit].
func is_editing() -> bool:
	return not _editing.is_empty()


## Records what was set since the last commit as one undo step and one
## operation from a panel, unless the value came back to where it was.
func commit() -> void:
	if _editing.is_empty():
		return
	var property := _editing
	var before: Variant = _before
	_editing = &""
	_before = null
	if not is_instance_valid(_target):
		return
	var value: Variant = _target.get(property)
	if typeof(value) != typeof(before) or value != before:
		_document.commit_property(_target, property, before, XREDocument.Source.PANEL)


## [param properties] of an object, as [method Object.get_property_list] gives
## them, the way the inspector in the headset shows them:
## [br]- in the inspector's order: each class's properties, from its category
## to the next, come before its parent class's, the script's first;
## [br]- without the script property;
## [br]- objects and node paths read only;
## [br]- metadata last.
static func for_inspector(properties: Array[Dictionary]) -> Array[Dictionary]:
	var head: Array[Dictionary] = []
	var blocks: Array[Array] = []
	var metadata: Array[Dictionary] = []
	for property: Dictionary in properties:
		var property_name: String = property["name"]
		if property_name == "script":
			continue
		var copy := property.duplicate()
		var type: int = property["type"]
		var usage: int = property["usage"]
		if type == TYPE_OBJECT or type == TYPE_NODE_PATH:
			copy["usage"] = usage | PROPERTY_USAGE_READ_ONLY
		if property_name.begins_with("metadata/"):
			metadata.append(copy)
		elif usage & PROPERTY_USAGE_CATEGORY:
			blocks.append([copy])
		elif blocks.is_empty():
			head.append(copy)
		else:
			var block: Array = blocks[blocks.size() - 1]
			block.append(copy)
	var result := head
	for i: int in range(blocks.size() - 1, -1, -1):
		for property: Dictionary in blocks[i]:
			result.append(property)
	result.append_array(metadata)
	return result


func _get_property_list() -> Array[Dictionary]:
	return _properties


func _get(property: StringName) -> Variant:
	if _names.has(property) and is_instance_valid(_target):
		return _target.get(property)
	return null


func _set(property: StringName, value: Variant) -> bool:
	if not _names.has(property):
		return false
	if not is_instance_valid(_target):
		return true
	if _editing != property:
		commit()
		_editing = property
		_before = _target.get(property)
	_document.preview_property(_target, property, value)
	return true


func _property_can_revert(property: StringName) -> bool:
	if not _names.has(property) or not is_instance_valid(_target):
		return false
	return _target.property_can_revert(property) or _default_value(property) != null


func _property_get_revert(property: StringName) -> Variant:
	if not is_instance_valid(_target):
		return null
	if _target.property_can_revert(property):
		return _target.property_get_revert(property)
	return _default_value(property)


## Called by the inspector by name: edits go to the document, not to undo history.
func _dont_undo_redo() -> bool:
	return true


## Called by the inspector by name: this proxy's own script is not the node's.
func _hide_script_from_inspector() -> bool:
	return true


## Called by the inspector by name: adding metadata needs a keyboard.
func _hide_metadata_from_inspector() -> bool:
	return true


## The value [param property] has in a new node of the target's class or
## script, or null if it has none; the inspector's revert arrow goes back to it.
func _default_value(property: StringName) -> Variant:
	var script := _target.get_script() as Script
	if script != null:
		var script_default: Variant = script.get_property_default_value(property)
		if script_default != null:
			return script_default
	return ClassDB.class_get_property_default_value(_target.get_class(), property)


func _update_properties() -> void:
	_properties = for_inspector(_target.get_property_list())
	_names.clear()
	for property: Dictionary in _properties:
		var usage: int = property["usage"]
		if usage & (PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SUBGROUP) == 0:
			_names[StringName(property["name"])] = true


func _on_target_property_list_changed() -> void:
	_update_properties()
	notify_property_list_changed()
