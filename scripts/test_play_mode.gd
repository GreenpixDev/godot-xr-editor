extends SceneTree
## Headless tests of play mode: XREPlayMode driven by fake controller trackers,
## a fake document and a fake session, the game's command line, and the hold
## that returns from the game (the XREReturnToEditor autoload). Used by
## scripts/check.sh, not shipped with the plugin. Prints
## "test_play_mode: FAILED ..." for every failed check and a summary line at the end.

const ReturnToEditor := preload("res://addons/xr_editor/playmode/return_to_editor.gd")
## The edited scene's file. Never written: only whether there is one matters.
const SCENE_PATH := "res://play_mode_test.tscn"
## Where the editor on a standalone headset leaves its state in this test, not in the project.
const RETURN_STATE_PATH := "user://test_play_mode_return.cfg"
## Where the user stands, by the rig, when they play on a standalone headset.
const PLACE_BEFORE_GAME := Transform3D(Basis(Vector3.UP, 1.0), Vector3(2.0, 0.0, -3.0))
const USEC := 1000000


## Plays and stops on paper instead of running a game.
class FakeDocument extends XREDocument:
	var root: Node
	var playing := false
	## How the last game was run.
	var separate := false
	## Called inside play() before the game starts, as the editor's progress
	## dialog runs main loop iterations while it saves.
	var while_saving := Callable()

	func get_scene_root() -> Node:
		return root

	func get_selection() -> Array[Node]:
		return []

	func select(_nodes: Array[Node], _source: Source) -> void:
		pass

	func preview_transform(_node: Node3D, _xform: Transform3D) -> void:
		pass

	func commit_transforms(_nodes: Array[Node3D], _befores: Array[Transform3D], _source: Source) -> void:
		pass

	func set_property(_object: Object, _property: StringName, _value: Variant, _source: Source) -> void:
		pass

	func preview_property(_object: Object, _property: StringName, _value: Variant) -> void:
		pass

	func commit_property(_object: Object, _property: StringName, _before: Variant, _source: Source) -> void:
		pass

	func add_node(_node: Node, _parent: Node, _source: Source) -> void:
		pass

	func remove_nodes(_nodes: Array[Node], _source: Source) -> void:
		pass

	func save(_source: Source) -> Error:
		return OK

	## Scenes opened, in order. The edited scene stays the same.
	var opened: Array[String] = []

	func open_scene(path: String, source: Source) -> Error:
		opened.append(path)
		_record(&"open_scene", source, [])
		return OK

	func list_folder(_path: String) -> PackedStringArray:
		return PackedStringArray()

	func get_file_type(_path: String) -> StringName:
		return &""

	func play(source: Source, separate_app: bool) -> Error:
		if root == null or root.scene_file_path.is_empty():
			return ERR_UNCONFIGURED
		if while_saving.is_valid():
			while_saving.call()
		playing = true
		separate = separate_app
		_record(&"play", source, [root])
		return OK

	func stop_playing(source: Source) -> void:
		playing = false
		_record(&"stop", source, [])

	func is_playing() -> bool:
		return playing

	func get_snap() -> XRESnap:
		return XRESnap.new(false, 0.0, 0.0, 0.0)


## Headset focus, runtime and session releases as the test sets them, without OpenXR.
class FakeSession extends XRESession:
	var focus := true
	var yields := true
	## A standalone headset, where the game replaces the editor's process.
	var replaces := false
	var released := false
	var releases := 0
	var reacquires := 0

	func has_headset_focus() -> bool:
		return focus and not released

	func can_yield_headset() -> bool:
		return yields

	func game_replaces_editor() -> bool:
		return replaces

	func is_session_released() -> bool:
		return released

	func release_session() -> bool:
		released = true
		releases += 1
		return true

	func reacquire_session() -> bool:
		released = false
		reacquires += 1
		return true


var _checks := 0
var _failures := 0
var _frame := 0
var _steps: Array[Callable] = []

var _trackers: Array[XRControllerTracker] = []
var _left: XRControllerTracker
var _right: XRControllerTracker
var _document: FakeDocument
var _session: FakeSession
var _rig: XRERig
var _play_mode: XREPlayMode
var _operations: Array[String] = []


func _initialize() -> void:
	_steps = [
		_start,
		_settle,
		_press_right_hand,
		_press_to_play,
		_release_before_game,
		_game_takes_headset,
		_game_quits_while_held,
		_release_after_return,
		_press_while_gripping,
		_release_grip,
		_press_unsaved,
		_release_unsaved,
		_press_invalid_blueprint,
		_invalid_blueprint_keeps_headset,
		_press_on_steamvr,
		_steamvr_game_runs,
		_steamvr_game_quits_while_held,
		_steamvr_editor_back,
		_press_to_play_again,
		_release_game_without_headset,
		_press_to_stop,
		_stopped,
		_press_on_standalone,
		_standalone_game_starts,
		_standalone_editor_back,
		_press_before_invalid_fade,
		_invalidate_during_fade,
		_wait_invalid_fade,
		_invalid_fade_keeps_headset,
		_press_with_frames_to_cover,
		_covering_before_game,
		_still_covering,
		_game_starts_once_covered,
		_playtest,
		_playtest_wait_1,
		_playtest_wait_2,
		_playtest_wait_3,
		_playtest_started,
		_finish,
	]


func _process(_delta: float) -> bool:
	if _frame < _steps.size():
		_steps[_frame].call()
	_frame += 1
	return false


func _check(condition: bool, what: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("test_play_mode: FAILED ", what)


# One step per frame, as in test_tools.gd: each step checks what XREPlayMode
# did in the previous frame, then sets the next input.

func _start() -> void:
	_left = _add_tracker(&"left_hand")
	_right = _add_tracker(&"right_hand")
	var scene := Node3D.new()
	scene.scene_file_path = SCENE_PATH
	root.add_child(scene)
	_document = FakeDocument.new()
	_document.root = scene
	_document.operation_recorded.connect(
			func(operation: StringName, source: XREDocument.Source, _nodes: Array[Node], _time_usec: int) -> void:
				_operations.append("%s %s" % [operation, XREDocument.Source.keys()[source]]))
	_session = FakeSession.new()
	_rig = XRERig.new()
	_play_mode = XREPlayMode.new(_document, _session, _rig)
	_play_mode.return_state_path = RETURN_STATE_PATH
	# The view is covered at once, so that the game starts in the frame of the press.
	_play_mode.transition.fade_sec = 0.0
	_play_mode.transition.frames_to_cover = 0
	_rig.add_child(_play_mode)
	root.add_child(_rig)
	_document.while_saving = _play_mode._process.bind(0.0)


## A frame with Y up and the headset on, in case XREPlayMode first runs only now: that arms it.
func _settle() -> void:
	pass


func _press_right_hand() -> void:
	_check(_operations.is_empty(), "nothing happens before a press: %s" % [_operations])
	_right.set_input(ReturnToEditor.BUTTON, true)


func _press_to_play() -> void:
	_check(_operations.is_empty(), "B on the right hand doesn't play: %s" % [_operations])
	_right.set_input(ReturnToEditor.BUTTON, false)
	_y(true)


func _release_before_game() -> void:
	_check(_operations == ["play TOOL"], "Y plays the scene: %s" % [_operations])
	_check(_play_mode.transition.is_covering() and _play_mode.transition.get_text().begins_with("Starting"),
			"a loading screen says the game is starting: %s" % _play_mode.transition.get_text())
	_check(_play_mode.is_playing_from_vr(), "saving before Play doesn't take the game for quit")
	_y(false)


func _game_takes_headset() -> void:
	_session.focus = false
	# The user holds Y in the game to come back.
	_y(true)


func _game_quits_while_held() -> void:
	_check(_play_mode.get_message().is_empty(), "no message when the game takes the headset")
	_check(_play_mode.is_playing_from_vr(), "the game has the headset")
	_check(_play_mode.transition.is_covering(), "the editor's view stays covered behind the game")
	# The game quit, and the user still holds Y.
	_document.playing = false
	_session.focus = true


func _release_after_return() -> void:
	_check(_operations.size() == 1, "Y held while coming back doesn't play again: %s" % [_operations])
	_check(not _play_mode.is_playing_from_vr(), "back in the editor")
	_check(not _play_mode.transition.is_covering(), "the editor's view shows again")
	_y(false)


func _press_while_gripping() -> void:
	_set_grip(_right, 1.0)
	_y(true)


func _release_grip() -> void:
	_check(_operations.size() == 1, "no play while a grip is held: %s" % [_operations])
	_check(_play_mode.get_message().contains("grip"), "the headset asks to let go: %s" % _play_mode.get_message())
	_check(not _play_mode.transition.is_covering(), "a refused play leaves the view alone")
	_set_grip(_right, 0.0)
	_y(false)
	_document.root.scene_file_path = ""


func _press_unsaved() -> void:
	_y(true)


func _release_unsaved() -> void:
	_check(_operations.size() == 1, "no play of a scene without a file: %s" % [_operations])
	_check(_play_mode.get_message().begins_with("Save"), "the headset asks to save: %s" % _play_mode.get_message())
	_check(_session.releases == 0, "a refused play keeps the headset")
	_document.root.scene_file_path = SCENE_PATH
	_session.yields = false
	_y(false)


# SteamVR: the editor gives its session up for the game and asks for a new one
# once the game's process is gone (D-012).


func _press_invalid_blueprint() -> void:
	_document.prepare_play = func() -> bool: return false
	_y(true)


func _invalid_blueprint_keeps_headset() -> void:
	_check(_operations.size() == 1, "invalid graph does not start a game")
	_check(_session.releases == 0, "invalid graph keeps SteamVR's first session")
	_check(not _play_mode.transition.is_covering(), "invalid graph leaves the editor visible")
	_check(_play_mode.get_message().begins_with("Blueprint"), "headset explains graph validation refusal")
	_document.prepare_play = Callable()
	_y(false)

func _press_on_steamvr() -> void:
	_y(true)


func _steamvr_game_runs() -> void:
	_check(_session.releases == 1 and _session.released, "the editor releases the headset where it can't yield it")
	_check(_operations.size() == 2 and _document.separate, "and plays as a separate application: %s" % [_operations])
	_check(_session.reacquires == 0 and _play_mode.is_playing_from_vr(),
			"saving before the game starts doesn't take the headset back")
	# The user lets go and later holds Y in the game.
	_y(false)


func _steamvr_game_quits_while_held() -> void:
	_check(_session.reacquires == 0, "the headset stays with a running game")
	_y(true)
	_document.playing = false


func _steamvr_editor_back() -> void:
	_check(_session.reacquires == 1 and not _session.released, "the editor asks for the headset once the game is gone")
	_check(_operations.size() == 2, "Y held across the return doesn't play again: %s" % [_operations])
	_check(not _play_mode.get_message().begins_with("The game quit"), "the return isn't taken for a failed start: %s" % _play_mode.get_message())
	_session.yields = true
	_y(false)


func _press_to_play_again() -> void:
	_check(_play_mode.get_message().begins_with("SteamVR"), "back from a separate game, the headset warns about SteamVR: %s" % _play_mode.get_message())
	_check(not _play_mode.transition.is_covering(), "and shows the editor's view again")
	_y(true)


func _release_game_without_headset() -> void:
	_check(_operations == ["play TOOL", "play TOOL", "play TOOL"] and _document.playing and not _document.separate,
			"Y plays again: %s" % [_operations])
	# The editor keeps the headset: the game runs without it.
	_y(false)


func _press_to_stop() -> void:
	_y(true)


func _stopped() -> void:
	_check(_operations.size() == 4 and _operations[3] == "stop TOOL" and not _document.playing,
			"Y stops a game that runs without the headset: %s" % [_operations])
	_check(_play_mode.get_message() == "Game stopped.", "the headset says so: %s" % _play_mode.get_message())
	_check(not _play_mode.transition.is_covering(), "and shows the editor's view again")
	_session.replaces = true
	_rig.transform = PLACE_BEFORE_GAME
	_y(false)


# Standalone headset: the editor's Play replaces the editor's process with the
# game, and the editor opened after it puts the user back (D-018).

func _press_on_standalone() -> void:
	_y(true)


func _standalone_game_starts() -> void:
	_check(_operations.size() == 5 and _operations[4] == "play TOOL" and _document.separate,
			"Y plays without the editor's Play and its debugger on a standalone headset: %s" % [_operations])
	_check(_session.releases == 1, "the session isn't released for a game that replaces the editor")
	_check(_play_mode.transition.get_text().contains("Hold Left Y"),
			"the loading screen says how to come back: %s" % _play_mode.transition.get_text())
	# The game ends; the editor it opens finds what this one left, and opens another scene first.
	_document.playing = false
	_y(false)
	_document.root.scene_file_path = "res://another_scene.tscn"
	_rig.transform = Transform3D.IDENTITY
	_play_mode.restore_after_game(XREStandalone.take_return_state(RETURN_STATE_PATH))
	_check(_play_mode.transition.is_covering() and _play_mode.transition.get_text().begins_with("Opening"),
			"the editor opened after the game starts covered: %s" % _play_mode.transition.get_text())


func _standalone_editor_back() -> void:
	var rig := _rig.transform
	_check(rig.is_equal_approx(PLACE_BEFORE_GAME), "the user is back where they stood: %s" % rig)
	_check(not FileAccess.file_exists(RETURN_STATE_PATH), "what the editor left is read once")
	_check(_document.opened == [SCENE_PATH] and _operations[-1] == "open_scene TOOL",
			"the scene that was edited opens again: %s, %s" % [_document.opened, _operations])
	_check(not _play_mode.transition.is_covering(), "and the view shows once it is open")
	_session.replaces = false
	_play_mode.transition.frames_to_cover = 2


# The game starts only once the headset has been sent the covered view.


func _press_before_invalid_fade() -> void:
	_session.yields = false
	_document.prepare_play = func() -> bool: return true
	_y(true)


func _invalidate_during_fade() -> void:
	_document.prepare_play = func() -> bool: return false
	_y(false)


func _wait_invalid_fade() -> void:
	pass


func _invalid_fade_keeps_headset() -> void:
	_check(_operations.size() == 6, "graph changed during fade does not start a game")
	_check(_session.releases == 1, "graph changed during fade does not release SteamVR again")
	_check(not _play_mode.transition.is_covering(), "refused fade returns to editor view")
	_document.prepare_play = Callable()
	_session.yields = true
	_y(false)

func _press_with_frames_to_cover() -> void:
	_y(true)


func _covering_before_game() -> void:
	_check(_operations.size() == 6 and _play_mode.transition.is_covering() and _play_mode.is_playing_from_vr(),
			"Y covers the view first: %s" % [_operations])
	_y(false)


func _still_covering() -> void:
	_check(_operations.size() == 6, "the game waits for covered frames: %s" % [_operations])


func _game_starts_once_covered() -> void:
	_check(_operations.size() == 7 and _operations[6] == "play TOOL",
			"and starts after %d of them: %s" % [_play_mode.transition.frames_to_cover, _operations])


# The launcher's Playtest tile does what Y does, as an operation from a panel (D-082).

func _playtest() -> void:
	_document.playing = false
	_play_mode.request_play(XREDocument.Source.PANEL)
	_check(_operations.size() == 7 and _play_mode.transition.is_covering() and _play_mode.is_playing_from_vr(),
			"Playtest covers the view first, as Y does: %s" % [_operations])


func _playtest_wait_1() -> void:
	pass


func _playtest_wait_2() -> void:
	pass


func _playtest_wait_3() -> void:
	pass


func _playtest_started() -> void:
	_check(_operations.size() == 8 and _operations[7] == "play PANEL" and _document.playing,
			"then plays the scene, from a panel: %s" % [_operations])
	_play_mode.request_play(XREDocument.Source.PANEL)
	_check(_operations.size() == 9 and _operations[8] == "stop PANEL" and not _document.playing,
			"Playtest while the game runs stops it: %s" % [_operations])


func _finish() -> void:
	_test_game_args()
	_test_standalone()
	_test_transition_screen()
	_test_return_hold()
	for tracker in _trackers:
		XRServer.remove_tracker(tracker)
	# Play mode still runs this frame and would ask the session for focus.
	_play_mode.get_parent().free()
	_session.free()
	print("test_play_mode: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)


func _test_game_args() -> void:
	var args := XREPlayMode.game_args(PackedStringArray(["--some-arg"]))
	_check(args == PackedStringArray(["--some-arg", "--xr-mode", "on", "--ignore-error-breaks", ReturnToEditor.GAME_FLAG]),
			"a game run from the VR view takes the headset and doesn't stop on errors: %s" % args)
	_check(XREPlayMode.game_args(args) == args, "the arguments are added once: %s" % XREPlayMode.game_args(args))
	var regular := XREPlayMode.game_args(PackedStringArray(["--xr-mode", "off"]))
	_check(regular.count("--xr-mode") == 1 and regular[1] == "off", "Run in Regular Mode stays regular: %s" % regular)
	var features := XREFeatureSettings.new()
	var with_button := XREPlayMode.game_args(PackedStringArray(), features)
	_check(with_button.has(ReturnToEditor.BUTTON_FLAG + "left_hand:by_button"), "the game learns the button that returns: %s" % with_button)
	features.set_binding(XREFeatureSettings.PLAY, &"right_b")
	var rebound := XREPlayMode.game_args(with_button, features)
	_check(rebound.has(ReturnToEditor.BUTTON_FLAG + "right_hand:by_button") and rebound.size() == with_button.size(),
			"a rebinding replaces it: %s" % rebound)


func _test_standalone() -> void:
	var editor := XREStandalone.editor_args(PackedStringArray(["--xre-benchmark"]))
	_check(editor.slice(0, 2) == PackedStringArray(["--xr-mode", "on"]) and editor[2].ends_with("project.godot")
			and not editor.has("--editor") and editor.slice(3) == PackedStringArray(["--", "--xre-benchmark"]),
			"the editor opens in VR by its project.godot, never --editor: %s" % editor)
	_check(XREStandalone.editor_args(PackedStringArray()).size() == 3, "no user arguments, no --")
	var on_scene := XREStandalone.editor_args(PackedStringArray(["--xre-benchmark"]), SCENE_PATH)
	_check(on_scene[3] == SCENE_PATH and on_scene[4] == "--", "the scene to open comes before the plugin's arguments: %s" % on_scene)
	var measured := XREStandalone.editor_args(PackedStringArray(), "", PackedStringArray(["--benchmark"]))
	_check(measured.slice(0, 3) == PackedStringArray(["--xr-mode", "on", "--benchmark"]) and measured[3].ends_with("project.godot")
			and measured.size() == 4, "the engine's arguments come before the project: %s" % measured)
	var none := XREStandalone.take_return_state(RETURN_STATE_PATH)
	_check(not none.has_rig and none.scene_path.is_empty(), "nothing left, nothing restored")


## The loading screen with its own fade, frame by frame with a made-up delta.
func _test_transition_screen() -> void:
	var screen := XRETransitionScreen.new(XRERig.VR_LAYER)
	_check(not screen.visible and not screen.is_covering(), "the loading screen starts hidden")
	screen.cover("Starting")
	_check(screen.visible and screen.is_covering() and not screen.is_covered(), "covering starts a fade")
	screen._process(screen.fade_sec / 2.0)
	screen._process(screen.fade_sec / 2.0)
	for frame: int in screen.frames_to_cover:
		_check(not screen.is_covered(), "covered only after %d frames drawn so, not %d" % [screen.frames_to_cover, frame])
		screen._process(0.01)
	_check(screen.is_covered(), "covered after the fade and %d frames" % screen.frames_to_cover)
	screen.cover("Other text")
	_check(screen.is_covered() and screen.get_text() == "Other text", "covering again only changes the text")
	screen.reveal()
	_check(screen.visible and not screen.is_covering(), "revealing fades back in")
	screen._process(screen.fade_sec)
	_check(not screen.visible, "and hides the screen at the end")
	screen.free()


## The game side, frame by frame with a made-up clock.
func _test_return_hold() -> void:
	var game := ReturnToEditor.new()
	_check(game.advance(false, true, 0) < 0.0, "a hold doesn't count before the game has the headset")
	_check(game.advance(true, true, 0) < 0.0, "Y still down from the editor doesn't count")
	_check(game.advance(true, false, 0) < 0.0, "letting go counts nothing")
	_check(is_zero_approx(game.advance(true, true, USEC)), "a new press starts the hold")
	var half := USEC + int(ReturnToEditor.HOLD_SEC * USEC / 2.0)
	_check(is_equal_approx(game.advance(true, true, half), 0.5), "the hold fills up with time")
	_check(game.advance(true, false, half) < 0.0, "letting go cancels the hold")
	_check(is_zero_approx(game.advance(true, true, 3 * USEC)), "the next press starts over")
	_check(game.advance(false, true, 3 * USEC + 1) < 0.0, "losing the headset cancels the hold")
	_check(game.advance(true, true, 4 * USEC) < 0.0, "and it must be pressed again after")
	_check(game.advance(true, false, 4 * USEC) < 0.0, "letting go arms it")
	game.advance(true, true, 5 * USEC)
	_check(game.advance(true, true, 5 * USEC + int(ReturnToEditor.HOLD_SEC * USEC)) >= 1.0, "a full hold returns to the editor")
	game.free()


func _add_tracker(tracker_name: StringName) -> XRControllerTracker:
	var tracker := XRControllerTracker.new()
	tracker.name = tracker_name
	XRServer.add_tracker(tracker)
	_trackers.append(tracker)
	return tracker


func _y(down: bool) -> void:
	_left.set_input(ReturnToEditor.BUTTON, down)


func _set_grip(tracker: XRControllerTracker, value: float) -> void:
	tracker.set_input(&"grip", value)
