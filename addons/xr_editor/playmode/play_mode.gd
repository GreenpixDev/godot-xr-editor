@tool
class_name XREPlayMode
extends Node
## Plays the edited scene from the headset and brings the user back to the
## editor (docs/decisions.md, D-011).
##
## Controls, all on Y of the left controller (not Menu: SteamVR keeps the
## left Menu button for its dashboard):
## [br]- Y in the editor: play the edited scene, as Run Current Scene (F6)
## on the desktop. The game runs in its own process and opens its own OpenXR
## session; the runtime gives it the headset, and the editor's session waits
## in the background (docs/decisions.md, D-004). SteamVR allows one XR
## application at a time, so there the editor releases its session first and
## runs the game as another application (D-012).
## [br]- Y held for a second in the game: the game quits, and the headset
## comes back to the editor, unchanged since the user left it. That part runs
## in the game: the autoload [constant RETURN_AUTOLOAD]. On SteamVR the
## editor asks for a new session as soon as the game's process is gone.
## [br]- Y in the editor while a game runs: stop the game. This is the way
## back from a game that runs without taking the headset.
## [br][br]
## A press counts only after the button was seen up while the editor had the
## headset, so a user who comes back still holding Y doesn't start the game
## again. Short messages show in the headset in front of the user; lives under
## the [XRERig], so they render there only.

## Name of the autoload that brings the user back from the game.
const RETURN_AUTOLOAD := "XREReturnToEditor"
## Its script; it runs in games only, never in the editor.
const RETURN_SCRIPT := "res://addons/xr_editor/playmode/return_to_editor.gd"
## A game that hasn't taken the headset this long after Play runs without it.
const START_TIMEOUT_SEC := 15.0
## How often to ask for the headset back after the runtime refused, and for
## how long, in seconds (SteamVR, D-012).
const REACQUIRE_RETRY_SEC := 0.1
const REACQUIRE_TIMEOUT_SEC := 30.0
## How long a message stays in the headset, in seconds.
const MESSAGE_SEC := 3.0
## How far ahead of the head messages show, in meters.
const MESSAGE_DISTANCE := 0.8
## How far below the eyes messages show, in meters.
const MESSAGE_DROP := 0.15

const _ReturnToEditor := preload("return_to_editor.gd")
const _LOG_PREFIX := "XR Editor: play: "

enum _State {
	## The editor has the headset; no game is starting.
	IDLE,
	## Play was pressed; the game hasn't taken the headset yet.
	STARTING,
	## The game took the headset.
	IN_GAME,
}

var _document: XREDocument
var _session: XRESession
var _rig: XRERig
var _message: Label3D
var _message_until_usec := 0
var _state := _State.IDLE
var _focused := false
## The button was seen up while the editor had the headset.
var _armed := false
var _play_usec := 0
var _game_usec := 0
## The editor released its session for the game and hasn't got it back yet.
var _released_for_game := false
## Inside XREDocument.play(); see [method _process].
var _in_play_call := false
## The last game ran as a separate application (SteamVR), and whether the
## user was told what that does to the editor's session.
var _separate_play := false
var _warned_second_session := false
## When the game's process was seen gone, and when to ask for the headset next.
var _game_gone_usec := 0
var _next_reacquire_usec := 0


func _init(document: XREDocument, session: XRESession, rig: XRERig) -> void:
	_document = document
	_session = session
	_rig = rig
	_message = Label3D.new()
	_message.layers = XRERig.VR_LAYER
	_message.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_message.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	_message.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_message.no_depth_test = true
	_message.font_size = 40
	_message.pixel_size = 0.0005
	_message.outline_size = 10
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.width = 1200.0
	_message.visible = false
	add_child(_message)


func _process(_delta: float) -> void:
	# Saving before Play shows a progress dialog, which runs main loop
	# iterations, and this method with them, inside XREDocument.play(). The game
	# isn't running yet there, and on SteamVR the headset is already released.
	if _in_play_call:
		return
	var now := Time.get_ticks_usec()
	var focused := _session.has_headset_focus()
	if focused != _focused:
		_focused = focused
		_on_focus_changed(now)
	if _released_for_game:
		_take_headset_back(now)
	elif _state == _State.STARTING:
		_check_start(now)
	if _message.visible and now >= _message_until_usec:
		_message.visible = false

	if not focused:
		_armed = false
	elif not _button_held():
		_armed = true
	elif _armed:
		_armed = false
		_on_button_pressed(now)


## The command line of a game run while the VR view is on: [param args] and
## what the game needs to take the headset and give it back. A choice already
## made stays: Run in Regular Mode on the desktop passes [code]--xr-mode off[/code].
## [br]- [code]--xr-mode on[/code]: the editor doesn't pass its own on to
## games, and the project may have OpenXR off;
## [br]- [code]--ignore-error-breaks[/code]: otherwise a script error stops
## the game in the debugger, and the headset shows a frozen frame with no way
## back but the system menu;
## [br]- the flag that keeps [constant RETURN_AUTOLOAD] in the game.
static func game_args(args: PackedStringArray) -> PackedStringArray:
	var result := args.duplicate()
	if not result.has("--xr-mode"):
		result.append("--xr-mode")
		result.append("on")
	if not result.has("--ignore-error-breaks"):
		result.append("--ignore-error-breaks")
	if not result.has(_ReturnToEditor.GAME_FLAG):
		result.append(_ReturnToEditor.GAME_FLAG)
	return result


## Whether a game started from the headset is starting or has the headset.
func is_playing_from_vr() -> bool:
	return _state != _State.IDLE


## The message shown in the headset, or an empty string if none is.
func get_message() -> String:
	return _message.text if _message.visible else ""


func _on_button_pressed(now: int) -> void:
	if _document.is_playing():
		_document.stop_playing(XREDocument.Source.TOOL)
		_state = _State.IDLE
		_show("Game stopped.")
		return
	var refusal := _refusal()
	if not refusal.is_empty():
		_show(refusal)
		return
	var separate := not _session.can_yield_headset()
	_separate_play = separate
	# Before the game starts: SteamVR would ask the editor to quit once the game has a session.
	if separate and not _session.release_session():
		_show("Could not give the headset to the game.")
		return
	_state = _State.STARTING
	_play_usec = now
	_in_play_call = true
	var error := _document.play(XREDocument.Source.TOOL, separate)
	_in_play_call = false
	if separate:
		# Comes back in _take_headset_back(), right away if the game didn't start.
		_released_for_game = true
		_game_gone_usec = 0
		_next_reacquire_usec = 0
	if error != OK:
		_state = _State.IDLE
		_show("Could not start the game (%s)." % error_string(error))
		return
	_show("Starting the game…")


## Why the game can't start now, or an empty string if it can.
func _refusal() -> String:
	var root := _document.get_scene_root()
	# Checked before the headset is released for the game; the editor's Play would ask for a file on the desktop.
	if root == null or root.scene_file_path.is_empty():
		return "Save the scene to a file on the desktop first."
	# The editor saves the scene before it plays: a node being dragged would be saved mid-drag.
	for hand: XREHand in [_rig.left_hand, _rig.right_hand]:
		if hand.get_float(&"grip") > XREHand.RELEASE_THRESHOLD:
			return "Let go of the grip first."
	return ""


func _on_focus_changed(now: int) -> void:
	if not _focused and _state == _State.STARTING:
		_state = _State.IN_GAME
		_game_usec = now
		_message.visible = false
		if _released_for_game:
			# The editor let go itself; when the game took the headset isn't seen from here.
			_log("the editor released the headset for the game.")
		else:
			_log("the game took the headset %.2f s after Play." % ((now - _play_usec) / 1000000.0))
	elif _focused and _state == _State.IN_GAME:
		_state = _State.IDLE
		_log("back in the editor after %.1f s in the game." % ((now - _game_usec) / 1000000.0))
		if _separate_play and not _warned_second_session:
			# SteamVR sets up only a process's first session as a focused application (D-012).
			_warned_second_session = true
			_show("SteamVR: after a game the view may judder once you select something. Restart the editor if it does.")


## SteamVR (D-012): once the game's process is gone, asks for a new session,
## again every [constant REACQUIRE_RETRY_SEC] while the runtime refuses.
func _take_headset_back(now: int) -> void:
	if now < _next_reacquire_usec:
		return
	if _game_gone_usec == 0 and _document.is_playing():
		return
	if _game_gone_usec == 0:
		_game_gone_usec = now
	if _session.reacquire_session():
		_released_for_game = false
	elif now - _game_gone_usec > REACQUIRE_TIMEOUT_SEC * 1000000.0:
		_released_for_game = false
		push_warning("XR Editor: the OpenXR runtime didn't give the headset back; restart the editor to return to VR.")
	else:
		_next_reacquire_usec = now + int(REACQUIRE_RETRY_SEC * 1000000.0)


func _check_start(now: int) -> void:
	if not _document.is_playing():
		_state = _State.IDLE
		_show("The game quit before it took the headset.")
	elif now - _play_usec > START_TIMEOUT_SEC * 1000000.0:
		_state = _State.IDLE
		_show("The game runs without the headset. Y stops it.")


func _button_held() -> bool:
	return _rig.left_hand.is_button_pressed(_ReturnToEditor.BUTTON)


## Shows [param text] in front of the user for [constant MESSAGE_SEC] and logs it.
func _show(text: String) -> void:
	_log(text)
	var head := _rig.camera.global_transform
	var ahead := Vector3(-head.basis.z.x, 0.0, -head.basis.z.z)
	ahead = ahead.normalized() if not ahead.is_zero_approx() else Vector3.FORWARD
	_message.global_position = head.origin + ahead * MESSAGE_DISTANCE + Vector3.DOWN * MESSAGE_DROP
	_message.text = text
	_message.visible = true
	_message_until_usec = Time.get_ticks_usec() + int(MESSAGE_SEC * 1000000.0)


func _log(message: String) -> void:
	print(_LOG_PREFIX, message)
