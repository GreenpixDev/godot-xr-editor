@tool
class_name XREInspectorTab
extends XREPanelTab
## The selected node's properties in the editor's own inspector, as the
## desktop's Inspector dock shows them, with all its property editors. The
## inspector edits an [XREInspectorProxy] in place of the node, so every edit
## goes through [XREDocument]: one undo step and one operation from a panel
## each time the pointer's button goes up, a drag of a number included
## (docs/decisions.md, D-016).
##
## One node at a time: with several selected the tab says so. Resources and
## node paths are read only. [EditorInspector] needs the editor; in a run
## without it the tab says so instead. The inspector is let go while the tab
## is hidden and edits the selection again when the tab is shown.

var _inspector: EditorInspector
## [method EditorInspector.create_default_inspector] wants a filter field; it
## stays hidden, as there is no keyboard in the headset.
var _filter: LineEdit
var _proxy: XREInspectorProxy
var _message: Label


func _init(document: XREDocument) -> void:
	super(document)
	name = "Inspector"
	_message = _make_message("")
	add_child(_message)


func get_title() -> String:
	return editor_text("Inspector")


func get_symbol() -> StringName:
	return &"inspector"


## The inspector, once the tab has been shown with a node selected; null before, or without the editor.
func get_inspector() -> EditorInspector:
	return _inspector


## What the inspector edits, or null.
func get_proxy() -> XREInspectorProxy:
	return _proxy


func end_edit() -> void:
	if _proxy != null:
		_proxy.commit()


func _enter_tree() -> void:
	_document.selection_changed.connect(mark_dirty)
	_document.scene_changed.connect(mark_dirty)
	mark_dirty()


func _exit_tree() -> void:
	_document.selection_changed.disconnect(mark_dirty)
	_document.scene_changed.disconnect(mark_dirty)
	_let_go()


func _on_hidden() -> void:
	_let_go()
	_dirty = true


func _refresh() -> void:
	var nodes := _document.get_selection()
	var node: Node = nodes[0] if nodes.size() == 1 else null
	if node == null or not Engine.is_editor_hint():
		_let_go()
		if nodes.size() > 1:
			_message.text = editor_text("This operation requires a single selected node.")
		elif node != null:
			_message.text = "The inspector works in the editor only."
		else:
			_message.text = ""
		_message.visible = not _message.text.is_empty()
		if _inspector != null:
			_inspector.visible = false
		return
	_message.visible = false
	if _inspector == null:
		_filter = LineEdit.new()
		_filter.visible = false
		add_child(_filter)
		_inspector = EditorInspector.create_default_inspector(_filter)
		_inspector.name = "EditorInspector"
		_inspector.size_flags_vertical = SIZE_EXPAND_FILL
		add_child(_inspector)
	_inspector.visible = true
	if _proxy == null or _proxy.get_target() != node:
		end_edit()
		# The inspector holds a raw pointer to what it edits and touches it in
		# edit(): the old proxy must outlive the switch, or that is a use after
		# free, and a double free of the proxy (D-092).
		var proxy := XREInspectorProxy.new(_document, node)
		_inspector.edit(proxy)
		_proxy = proxy


## Commits what was set and stops editing, so that a hidden inspector doesn't
## refresh its values. The inspector lets go of the proxy before it is freed.
func _let_go() -> void:
	end_edit()
	if _inspector != null:
		_inspector.edit(null)
	_proxy = null
