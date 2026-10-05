@tool
class_name XREHandoffBenchmark
extends Node
## Measures how long the headset takes to switch from the editor to a game run
## with the editor's own Play and back (docs/plan.md, play mode).
##
## Two modes:
## [br]- yield: the editor keeps its OpenXR session; the game process starts its
## own, and the runtime gives the headset to the app in focus. Works on Meta Link;
## SteamVR asks the editor to quit and kills it 5 s later;
## [br]- release: the editor destroys its session before Play and asks for a new
## one as soon as the game starts quitting ([method XRESession.release_session]).
## On SteamVR the game then never shows in the headset: it runs on the editor's
## executable, SteamVR takes both for one application and drops the game's
## connection when it loads its input bindings;
## [br]- release_copy (experiment): as release, but the plugin runs the game from
## a copy of the Godot executable ([constant GAME_EXECUTABLE]) instead of Play,
## without the editor's debugger and game view, so SteamVR sees another application.
## [br][method run] waits until the headset is on, then [constant ITERATIONS]
## times plays [constant GAME_SCENE], which quits by itself a few seconds after it
## gets the headset, and waits for the editor to get the headset back. Times come
## from the system clock, which both processes share:
## [br]- [code]to_game_s[/code]: Play (in release mode, the release before it) → the game's session FOCUSED;
## [br]- [code]to_editor_s[/code]: the game quits → the editor's session FOCUSED again.
## [br]Results: [code]handoff_<stamp>.csv[/code] and [code]handoff_<stamp>_meta.json[/code]
## in [constant RESULTS_DIR]; a summary goes to the log.
## [br]Start: [code]godot --path . --editor --xr-mode on -- --xre-handoff[/code]
## (or [code]--xre-handoff-release[/code], [code]--xre-handoff-copy[/code];
## the editor quits when done).

## User argument (after [code]--[/code]) that runs the benchmark at startup and quits after it.
const CLI_FLAG := "--xre-handoff"
## The same in release mode.
const CLI_FLAG_RELEASE := "--xre-handoff-release"
## The same in release_copy mode.
const CLI_FLAG_COPY := "--xre-handoff-copy"
## Copy of the editor's executable that runs the game in release_copy mode, made
## on first use (~180 MB; build/ is neither in git nor scanned by the editor).
const GAME_EXECUTABLE := "res://build/xre_play/Godot_v4.7.2-stable_win64_xre_play.exe"
const GAME_SCENE := "res://benchmarks/xr_handoff_game.tscn"
## Written by the game (benchmarks/xr_handoff_game.gd), read by the editor. In .godot/,
## which the editor doesn't scan; user:// would depend on application/config/name.
const GAME_TIMELINE := "res://.godot/xre_handoff_game.json"
const ITERATIONS := 5
const WARMUP_SEC := 5.0
const PAUSE_SEC := 5.0
## A switch slower than this counts as failed (docs/plan.md risk threshold is 5 s).
const TIMEOUT_SEC := 30.0
const POLL_SEC := 0.02
## Pause before asking SteamVR for a new session again after a refusal.
const REACQUIRE_RETRY_SEC := 0.5
const RESULTS_DIR := "res://benchmarks/results"

const _LOG_PREFIX := "XR Editor: "
const _CSV_HEADER := "iteration,to_game_s,editor_unfocused_s,game_ready_s,game_session_begun_s,game_visible_s,game_focused_s,game_quit_s,game_exit_seen_s,to_editor_s,editor_states,editor_released_s,editor_reacquire_s"

## Session whose OpenXR interface is watched; set before [method run].
var session: XRESession
var _running := false
var _release := false
var _copy := false
## Process ID of the game run from [constant GAME_EXECUTABLE].
var _game_pid := 0
var _xr: OpenXRInterface
## Editor session state changes during the current iteration: [time, name] pairs.
var _editor_states: Array[Array] = []


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.has(CLI_FLAG_COPY):
		run.call_deferred(true, true, true)
	elif args.has(CLI_FLAG_RELEASE):
		run.call_deferred(true, true)
	elif args.has(CLI_FLAG):
		run.call_deferred(true)


func _exit_tree() -> void:
	if _running:
		_running = false
		_disconnect_states()
		if EditorInterface.is_playing_scene():
			EditorInterface.stop_playing_scene()
		if _game_pid > 0 and OS.is_process_running(_game_pid):
			OS.kill(_game_pid)
		if session.is_session_released():
			session.reacquire_session()
		_log("handoff benchmark aborted.")


## Runs the whole measurement. With [param quit_when_done] the editor quits at the end;
## with [param release] the editor gives up its OpenXR session for every game run,
## and with [param copy] also runs the game from [constant GAME_EXECUTABLE] instead of Play.
func run(quit_when_done: bool = false, release: bool = false, copy: bool = false) -> void:
	if _running:
		_log("handoff benchmark is already running.")
		return
	_xr = session.get_xr_interface()
	if _xr == null:
		_log("handoff benchmark needs a running VR session: start the editor with --xr-mode on.")
		return
	_running = true
	_release = release or copy
	_copy = copy
	if _copy and not _make_game_executable():
		_running = false
		return

	_log("handoff benchmark (%s mode): waiting for the headset to be put on." % _mode_name())
	while _running and _xr.get_session_state() != OpenXRInterface.SESSION_STATE_FOCUSED:
		await _wait(1.0)
	if not _running:
		return
	await _wait(WARMUP_SEC)

	var stamp := Time.get_datetime_string_from_system().replace(":", "-")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RESULTS_DIR))
	_save_metadata(RESULTS_DIR.path_join("handoff_%s_meta.json" % stamp))
	var rows := PackedStringArray([_CSV_HEADER])
	var to_game: Array[float] = []
	var to_editor: Array[float] = []
	_connect_states()

	for iteration in range(1, ITERATIONS + 1):
		var row := await _measure_once(iteration)
		if not _running:
			return
		rows.append(row.get("csv", ""))
		if row.has("to_game_s"):
			to_game.append(row["to_game_s"])
		if row.has("to_editor_s"):
			to_editor.append(row["to_editor_s"])
		await _wait(PAUSE_SEC)

	_disconnect_states()
	_running = false
	var csv_path := RESULTS_DIR.path_join("handoff_%s.csv" % stamp)
	var file := FileAccess.open(csv_path, FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(rows) + "\n")
	_log("handoff benchmark done, %s:" % csv_path)
	_log("  editor -> game: %s" % _summary(to_game))
	_log("  game -> editor: %s" % _summary(to_editor))
	if quit_when_done:
		get_tree().quit()


## One Play → game in the headset → game quits → editor in the headset again.
## Returns the CSV row and the two switch times when they happened.
func _measure_once(iteration: int) -> Dictionary:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(GAME_TIMELINE))
	_editor_states.clear()
	var t_play := Time.get_unix_time_from_system()
	var t_released := NAN
	if _release:
		if not session.release_session():
			# Playing anyway would get the editor killed on SteamVR.
			_log("handoff %d/%d: the editor kept its OpenXR session, benchmark stopped." % [iteration, ITERATIONS])
			_running = false
			_disconnect_states()
			return {}
		t_released = Time.get_unix_time_from_system()
		_editor_states.append([t_released, "RELEASED"])
	if _copy:
		_game_pid = OS.create_process(ProjectSettings.globalize_path(GAME_EXECUTABLE),
				["--path", ProjectSettings.globalize_path("res://"), GAME_SCENE])
	else:
		EditorInterface.play_custom_scene(GAME_SCENE)
	_log("handoff %d/%d: playing %s." % [iteration, ITERATIONS, GAME_SCENE])

	while _running and _game_running() and Time.get_unix_time_from_system() - t_play < TIMEOUT_SEC * 2.0:
		if _release:
			# Every frame: on SteamVR the new session must come within ~25 ms of the game's exit.
			await get_tree().process_frame
		else:
			await _wait(POLL_SEC)
	var t_exit_seen := Time.get_unix_time_from_system()
	var t_reacquire := NAN
	if _release and session.is_session_released():
		t_reacquire = Time.get_unix_time_from_system()
		_editor_states.append([t_reacquire, "REACQUIRE"])
		while _running and not session.reacquire_session():
			_editor_states.append([Time.get_unix_time_from_system(), "REFUSED"])
			if Time.get_unix_time_from_system() - t_exit_seen > TIMEOUT_SEC:
				break
			await _wait(REACQUIRE_RETRY_SEC)
	# After the new session: stopping Play takes time, and the game is gone anyway.
	if EditorInterface.is_playing_scene():
		EditorInterface.stop_playing_scene()
	while _running and not _editor_focused(t_reacquire) and Time.get_unix_time_from_system() - t_exit_seen < TIMEOUT_SEC:
		await _wait(POLL_SEC)
	if not _running:
		return {}

	var game: Dictionary = {}
	var timeline := FileAccess.get_file_as_string(GAME_TIMELINE)
	if not timeline.is_empty():
		game = JSON.parse_string(timeline) as Dictionary
	var t_quit: float = game.get("quit", NAN)
	var t_unfocused := _first_state_after("VISIBLE", t_play)
	var t_refocused := _first_state_after("FOCUSED", t_quit if not is_nan(t_quit) else t_exit_seen)

	var result := {}
	if game.has("focused"):
		result["to_game_s"] = float(game["focused"]) - t_play
	if not is_nan(t_quit) and not is_nan(t_refocused):
		result["to_editor_s"] = t_refocused - t_quit
	var states := PackedStringArray()
	for change in _editor_states:
		states.append("%s@%.3f" % [change[1], float(change[0]) - t_play])
	var cells := PackedStringArray([
		str(iteration),
		_seconds(result.get("to_game_s", NAN)),
		_seconds(t_unfocused - t_play),
		_seconds(float(game.get("ready", NAN)) - t_play),
		_seconds(float(game.get("session_begun", NAN)) - t_play),
		_seconds(float(game.get("visible", NAN)) - t_play),
		_seconds(float(game.get("focused", NAN)) - t_play),
		_seconds(t_quit - t_play),
		_seconds(t_exit_seen - t_quit),
		_seconds(result.get("to_editor_s", NAN)),
		" ".join(states),
		_seconds(t_released - t_play),
		_seconds(t_reacquire - t_play),
	])
	result["csv"] = ",".join(cells)
	_log("handoff %d: editor -> game %s s, game -> editor %s s." % [
		iteration, _seconds(result.get("to_game_s", NAN)), _seconds(result.get("to_editor_s", NAN))])
	return result


func _connect_states() -> void:
	_xr.session_focussed.connect(_on_editor_state.bind("FOCUSED"))
	_xr.session_visible.connect(_on_editor_state.bind("VISIBLE"))
	_xr.session_synchronized.connect(_on_editor_state.bind("SYNCHRONIZED"))
	_xr.session_stopping.connect(_on_editor_state.bind("STOPPING"))
	_xr.session_begun.connect(_on_editor_state.bind("BEGUN"))


func _disconnect_states() -> void:
	for state_signal: Signal in [_xr.session_focussed, _xr.session_visible, _xr.session_synchronized, _xr.session_stopping, _xr.session_begun]:
		if state_signal.is_connected(_on_editor_state):
			state_signal.disconnect(_on_editor_state)


func _on_editor_state(state_name: String) -> void:
	_editor_states.append([Time.get_unix_time_from_system(), state_name])


## Whether the editor has the headset again. A new session (after
## [param since_reacquire]) is followed by its state signals: until its first
## state change the interface still reports the destroyed session's state.
func _editor_focused(since_reacquire: float) -> bool:
	if is_nan(since_reacquire):
		return _xr.get_session_state() == OpenXRInterface.SESSION_STATE_FOCUSED
	return not is_nan(_first_state_after("FOCUSED", since_reacquire))


func _mode_name() -> String:
	if _copy:
		return "release_copy"
	return "release" if _release else "yield"


## Copies the editor's executable to [constant GAME_EXECUTABLE] unless it's there.
func _make_game_executable() -> bool:
	var target := ProjectSettings.globalize_path(GAME_EXECUTABLE)
	if FileAccess.file_exists(target):
		return true
	DirAccess.make_dir_recursive_absolute(target.get_base_dir())
	var err := DirAccess.copy_absolute(OS.get_executable_path(), target)
	if err != OK:
		_log("handoff benchmark: could not copy the Godot executable to %s (%s)." % [target, error_string(err)])
		return false
	_log("handoff benchmark: copied the Godot executable to %s." % target)
	return true


## Whether the game of the current iteration still runs, as far as the handoff
## is concerned. In release modes the game counts as gone once it writes its
## timeline, when it starts quitting: it leaves SteamVR ~30 ms later, but its
## process, run with Play, lives ~90 ms longer, and the editor's Play status
## comes later still. Without the timeline, the end of the process or of Play
## means the game crashed or was stopped.
func _game_running() -> bool:
	if not _release:
		return EditorInterface.is_playing_scene()
	var alive := OS.is_process_running(_game_pid) if _copy else EditorInterface.is_playing_scene()
	return alive and not FileAccess.file_exists(GAME_TIMELINE)


## Time of the first editor state change to [param state_name] at or after [param since], or NAN.
func _first_state_after(state_name: String, since: float) -> float:
	for change in _editor_states:
		if change[1] == state_name and float(change[0]) >= since:
			return float(change[0])
	return NAN


func _seconds(value: float) -> String:
	return "" if is_nan(value) else "%.3f" % value


func _summary(values: Array[float]) -> String:
	if values.is_empty():
		return "no successful switch out of %d" % ITERATIONS
	var sorted_values := values.duplicate()
	sorted_values.sort()
	return "%d of %d, median %.2f s, max %.2f s" % [
		values.size(), ITERATIONS, sorted_values[sorted_values.size() >> 1], sorted_values[-1]]


func _save_metadata(path: String) -> void:
	var settings := EditorInterface.get_editor_settings()
	var system := _xr.get_system_info()
	var meta := {
		"godot": Engine.get_version_info().get("string", ""),
		"openxr_runtime": "%s %s" % [system.get("XRRuntimeName", ""), system.get("XRRuntimeVersion", "")],
		"openxr_system": system.get("OpenXRSystemName", ""),
		"display_refresh_rate_hz": _xr.display_refresh_rate,
		"mode": _mode_name(),
		"game_scene": GAME_SCENE,
		# How the editor shows a running game: -1 separate window, 0 per project
		# (game_view metadata below), 1 embedded, 2 floating embedded.
		"game_embed_mode": settings.get_setting("run/window_placement/game_embed_mode"),
		"embed_on_play": settings.get_project_metadata("game_view", "embed_on_play", true),
		"make_floating_on_play": settings.get_project_metadata("game_view", "make_floating_on_play", true),
		"iterations": ITERATIONS,
		"timeout_sec": TIMEOUT_SEC,
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(meta, "\t") + "\n")


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout


func _log(message: String) -> void:
	print(_LOG_PREFIX, message)
