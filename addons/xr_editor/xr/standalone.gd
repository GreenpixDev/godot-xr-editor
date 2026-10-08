@tool
@abstract
class_name XREStandalone
extends RefCounted
## What differs on a standalone headset (Horizon OS), where the Godot editor is
## an Android app (docs/decisions.md, D-017, D-018). Used by the editor and by
## the games it runs, so nothing here touches the editor's API.
##
## The app's own window is a 2D panel. XR runs only in the activity the app
## keeps for XR games, and a launch with [code]--editor[/code] never goes there.
## A path ending in [code]project.godot[/code] also starts the editor and isn't
## on that list: [method open_editor_in_vr] opens this project's editor in the
## XR activity. Called from that activity (a game, or the editor itself), it
## replaces the calling process; called from the panel, it starts one.
## [br][br]
## Play mode builds on that: a game started from the editor in VR replaces the
## editor's process, and the game opens the editor again when the user holds Y.
## The editor leaves the scene and where the user stood in
## [constant RETURN_STATE_FILE] for the editor that opens after the game.

## Where the editor in VR leaves its state for after the game: the project's
## .godot folder, which neither git nor the editor's file system scan sees.
const RETURN_STATE_FILE := "res://.godot/xr_editor_play_return.cfg"


## What the editor finds after a game: the scene and where the user stood.
class ReturnState:
	## The scene to edit, or an empty string.
	var scene_path := ""
	var has_rig := false
	var rig_transform := Transform3D.IDENTITY


## Whether this Godot runs on a standalone headset: the Android editor there
## reports [code]xr_editor[/code], and so do the games it runs. Exported games don't.
static func is_standalone() -> bool:
	return OS.has_feature("xr_editor")


## Command line that opens this project's editor in the XR activity, on
## [param scene] if it isn't empty, with [param user_args] for the plugin
## after [code]--[/code] and [param engine_args] for the engine before the
## project (for example [code]--benchmark[/code]).
static func editor_args(user_args: PackedStringArray, scene: String = "",
		engine_args := PackedStringArray()) -> PackedStringArray:
	var args := PackedStringArray(["--xr-mode", "on"])
	args.append_array(engine_args)
	args.append(ProjectSettings.globalize_path("res://project.godot"))
	if not scene.is_empty():
		args.append(scene)
	if not user_args.is_empty():
		args.append("--")
		args.append_array(user_args)
	return args


## Opens this project's editor in VR (see the class description). From the XR
## activity, this process ends shortly after the call returns.
static func open_editor_in_vr(user_args: PackedStringArray, scene: String = "",
		engine_args := PackedStringArray()) -> Error:
	return OK if OS.create_instance(editor_args(user_args, scene, engine_args)) >= 0 else FAILED


## Leaves [param scene_path] and the rig's transform for the editor that opens after the game.
static func save_return_state(scene_path: String, rig: Transform3D, path: String = RETURN_STATE_FILE) -> Error:
	var file := ConfigFile.new()
	file.set_value("return", "scene", scene_path)
	file.set_value("return", "rig", rig)
	return file.save(path)


## What [method save_return_state] left, once: the file is deleted. Empty if there is none.
static func take_return_state(path: String = RETURN_STATE_FILE) -> ReturnState:
	var state := ReturnState.new()
	if not FileAccess.file_exists(path):
		return state
	var file := ConfigFile.new()
	var error := file.load(path)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	if error != OK:
		return state
	var scene: Variant = file.get_value("return", "scene", "")
	var rig: Variant = file.get_value("return", "rig", null)
	if scene is String:
		state.scene_path = scene as String
	if rig is Transform3D:
		state.has_rig = true
		state.rig_transform = rig as Transform3D
	return state
