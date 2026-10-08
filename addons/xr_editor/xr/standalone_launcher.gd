@tool
class_name XREStandaloneLauncher
extends Node
## The plugin in the editor's 2D panel on a standalone headset (docs/decisions.md,
## D-018): Project → Tools → [constant MENU] opens this project's editor in VR,
## another process of the app ([XREStandalone]). The panel stays open behind it.
##
## [code]scripts/quest.py[/code] asks for the same from a PC: it leaves
## [constant OPEN_REQUEST] in the project before it opens the panel, and the
## launcher opens VR as soon as the panel has scanned the project, so the two
## editors don't import the same files at once. The request has one item per
## line, as on Godot's command line: before a [code]--[/code] line, a
## [code]res://[/code] path is the scene to open and anything else an argument
## for the engine (for example [code]--benchmark[/code]); after it, user
## arguments for the plugin in VR (for example [code]--xre-benchmark[/code]).

const MENU := "XR Editor: Open in VR"
## Left by scripts/quest.py; read and deleted at startup.
const OPEN_REQUEST := "res://.godot/xr_editor_open_vr"

const _LOG_PREFIX := "XR Editor: "

var _plugin: EditorPlugin
## A request from scripts/quest.py waits for the scan, with this scene and these arguments.
var _request_pending := false
var _request_scene := ""
var _request_args := PackedStringArray()
var _request_engine_args := PackedStringArray()


func _init(plugin: EditorPlugin) -> void:
	_plugin = plugin


func _enter_tree() -> void:
	_plugin.add_tool_menu_item(MENU, _open_from_menu)
	_request_pending = FileAccess.file_exists(OPEN_REQUEST)
	if _request_pending:
		_take_request()
	set_process(_request_pending)


func _exit_tree() -> void:
	_plugin.remove_tool_menu_item(MENU)


func _process(_delta: float) -> void:
	if EditorInterface.get_resource_filesystem().is_scanning():
		return
	set_process(false)
	_request_pending = false
	_open(_request_args, _request_scene, _request_engine_args)


func _open_from_menu() -> void:
	_open(PackedStringArray(), "", PackedStringArray())


func _open(user_args: PackedStringArray, scene: String, engine_args: PackedStringArray) -> void:
	var error := XREStandalone.open_editor_in_vr(user_args, scene, engine_args)
	if error == OK:
		print(_LOG_PREFIX, "opening the editor in VR%s%s%s." % [
			" on " + scene if not scene.is_empty() else "",
			" with %s" % user_args if not user_args.is_empty() else "",
			", engine arguments %s" % engine_args if not engine_args.is_empty() else ""])
	else:
		push_error("XR Editor: could not open the editor in VR (%s)." % error_string(error))


## Reads the request left by scripts/quest.py and deletes it, so it opens VR once.
func _take_request() -> void:
	var lines := FileAccess.get_file_as_string(OPEN_REQUEST).split("\n", false)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(OPEN_REQUEST))
	var for_plugin := false
	for line: String in lines:
		var item := line.strip_edges()
		if item.is_empty():
			continue
		if for_plugin:
			_request_args.append(item)
		elif item == "--":
			for_plugin = true
		elif item.begins_with("res://"):
			_request_scene = item
		else:
			_request_engine_args.append(item)
