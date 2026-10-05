@tool
extends EditorPlugin
## Entry point of the XR Editor plugin.

var document: XREDocument


func _enter_tree() -> void:
	document = XREPluginDocument.new(self)


func _exit_tree() -> void:
	(document as XREPluginDocument).dispose()
	document = null
