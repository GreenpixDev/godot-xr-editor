@tool
class_name XREGraphLab
extends Node
## Measures what the open graph costs the headset. Once the headset is on and the
## scene is loaded it runs, [constant STEP_SEC] each and without being touched, the
## [constant STEPS]: the ceiling with the GPU unloaded, each of the canvas's kinds of
## object hidden in turn between steps with all of them shown, and a graph made larger
## in memory. It opens and closes the graph itself, logs each step's name when it
## starts, and the graph's own script time every [constant REPORT_SEC]; read the
## steps' frame rate and App GPU ms (VrApi) around those lines with
## [code]benchmarks/quest_fps_report.py[/code]. Nothing it does reaches a saved graph. A step during which the
## session leaves focus (the headset slept) is logged as cut and run again from its start (D-161).
## Start: [code]py scripts/quest.py --scene res://benchmarks/play_check.tscn -- --xre-graph-lab[/code].

## User argument (after [code]--[/code]) that runs the lab.
const CLI_FLAG := "--xre-graph-lab"
## With [constant CLI_FLAG] on a standalone headset: goes straight to [constant GAME_SCENE] in the game process, as Play does (D-018).
const GAME_FLAG := "--xre-graph-lab-game"
## As [constant GAME_FLAG], straight to Compatibility: for when that renderer's part of the game's run didn't start (D-155).
const COMPAT_FLAG := "--xre-graph-lab-compat"
## The canvas alone, measured outside the editor.
const GAME_SCENE := "res://benchmarks/graph_runtime_lab.tscn"
## User argument that tells [constant GAME_SCENE] it runs on Compatibility, and what its steps' names start with there.
const COMPAT_ARG := "--xre-lab-compat"
const COMPAT_STEP_PREFIX := "compat_"
## Seconds each step lasts.
const STEP_SEC := 20.0
## Seconds the headset must have been on before the first step.
const WARMUP_SEC := 15.0
## Seconds between lines of the graph's own script time. A step lasts a whole number of them, so that a step's
## last report holds only that step's frames.
const REPORT_SEC := 5.0
## Fewest frames a report made at the end of a step has.
const MIN_REPORT_FRAMES := 30
## Longest frame, in seconds, a step may hold: a longer one means the process stood still (the headset slept), and
## the step is void as when the session leaves focus (D-161).
const STALL_SEC := 1.0
## The scene node whose graph the steps open.
const HOST := "BlueCube"
## Steps in order. A step's name holds what it changes from the open graph.
const STEPS: Array[String] = [
	"closed", "open", "open_scale", "open_service_off_scale",
	"open", "open_ports_off", "open", "open_shader_off", "open", "open_plain_off", "open", "open_text_off",
	"open", "open_wires_off", "open", "open_all_off", "open", "open_text_cut", "open", "open_service_off_text_off",
	"open_big2", "open_big4", "open", "closed",
]
## With [constant EDITOR_FLAG] after [code]--[/code]: what the editor and the plugin cost, with the graph open and closed.
const EDITOR_FLAG := "--xre-graph-lab-editor"
const EDITOR_STEPS: Array[String] = [
	"closed", "closed_tree_off", "closed", "open", "open_errors_off", "open", "open_log_off", "open", "open_views_off", "open", "open_editor_off",
	"open", "open_panels_off", "open", "open_manipulator_off", "open", "open_plugin_off",
	"open", "open_tree_off", "open", "open_physics_off", "open", "open_tree_off", "open", "closed",
]
## With [constant CLI_FLAG] after [code]--[/code]: what the GPU's base in the editor is made of (D-155), foveation
## fixed. The editor then opens itself again on Compatibility for [constant BASE_COMPAT_STEPS].
const BASE_FLAG := "--xre-graph-lab-base"
const BASE_STEPS: Array[String] = [
	"closed", "closed_vr_off", "closed_views_off", "closed_root_off", "closed_lean", "closed_scene_off", "closed_empty", "closed",
	"open", "open_dimmer_off", "open_ui_off", "open_all_off", "open_views_off", "open_root_off", "open_lean", "open", "open_big2", "closed",
]
const BASE_COMPAT_STEPS: Array[String] = ["closed", "closed_vr_off", "closed_empty", "open", "open_ui_off", "open_all_off", "open_big2", "open", "closed"]
## With [constant CLI_FLAG] after [code]--[/code]: how the cost grows with the graph's and the scene's size (D-157, step 0.3),
## foveation fixed. [code]graphN[/code] in a step's name is a graph of N blocks, [code]sceneNk[/code] N thousand
## [MeshInstance3D]-like objects on the rendering server around the scene's host; both are built in memory.
const STRESS_FLAG := "--xre-graph-lab-stress"
const STRESS_STEPS: Array[String] = [
	"closed", "open", "open_graph100", "open_graph250", "open_graph500", "open", "closed",
	"closed_scene1k", "closed_scene5k", "closed_scene20k", "closed", "open_scene5k", "open", "closed",
]
## With [constant CLI_FLAG] after [code]--[/code]: logs each viewport's render time and counters at every report, in any steps (D-157, step 1.1).
## The base and stress runs do it on their own. Measuring renders costs the GPU a little: compare these runs with each other.
const VIEWS_FLAG := "--xre-graph-lab-views"
## Distance between the stress scene's objects, and their size, in metres.
const SCENE_SPACING := 0.6
const SCENE_OBJECT := 0.3
## With [constant CLI_FLAG] after [code]--[/code]: no measuring, only the views. Each step moves the user to where the whole
## scene and the open graph are in view, waits, and saves a picture of what a camera at the head sees there to
## [constant SHOT_DIR] (D-157): the check of the framing that comes before a measuring run.
const POSE_FLAG := "--xre-graph-lab-pose"
const POSE_STEPS: Array[String] = [
	"closed", "open", "open_graph100", "open_graph250", "open_graph500", "closed_scene1k", "closed_scene5k", "open_scene5k", "closed",
]
## Seconds a step of [constant POSE_STEPS] lasts.
const POSE_STEP_SEC := 6.0
## Where the pictures go, and their side in pixels.
const SHOT_DIR := "res://benchmarks/shots"
const SHOT_SIZE := 960
## Part of the field of view both eyes share that the framed boxes may use, so that no edge is cut.
const VIEW_FILL := 0.8
## Metres the head stands above the middle of the framed boxes.
const VIEW_LIFT := 0.3
## Distance a step is framed from at least, and the steps it grows by until everything fits, in metres.
const VIEW_MIN_DISTANCE := 1.2
const VIEW_STEP := 0.05
## Longest diagonal of a part of the scene that counts for the framing, in metres: the ground plane doesn't.
const SCENE_PART_MAX := 12.0
## How far behind the scene's host the stress scene's nearest objects stand, and the height of its lowest, in metres.
const SCENE_NEAR := 3.0
const SCENE_BASE := 0.1
## Seconds a step of [constant BASE_STEPS] lasts.
const BASE_STEP_SEC := 10.0
## Foveation of those steps, as [code]graph_runtime_lab[/code] has it: it doesn't follow the load.
const BASE_FOVEATION := 3
## User argument (after [code]--[/code]): one second a step, and no second renderer, for a check without a headset.
const FAST_FLAG := "--xre-lab-fast"
## Scale of the render target in the scaled steps.
const SCALE := 0.7
## User argument (after [code]--[/code]) with a list of steps of one's own, as [code]--xre-graph-lab-steps=closed,open[/code],
## in place of the run's (D-164). With [constant BASE_FLAG] or [constant STRESS_FLAG] the steps last as theirs do.
const STEPS_FLAG := "--xre-graph-lab-steps="
## User argument, repeated for more settings, as [code]--xre-lab-feature=editor_window=live[/code]: a setting's value
## for this run only, neither saved nor in the history (D-164).
const FEATURE_FLAG := "--xre-lab-feature="

const _LOG_PREFIX := "XR Editor: "

## One viewport the process renders, and its render time summed over the frames since the last report.
## Only an active view (one that drew or took time at a report) is read every frame: the editor has some
## two thousand viewports, nearly all idle, and reading each of them every frame cost 2-3.5 ms of CPU a
## frame on Quest 2 (D-163).
class _View:
	var rid: RID
	## The viewport's instance: one freed between reports is skipped, not read (its RID errs every frame).
	var id := 0
	var label := ""
	var active := false
	var frames := 0
	var cpu := 0.0
	var gpu := 0.0


var _service: XREBlueprints
var _document: XREDocument
var _step := -1
var _left := WARMUP_SEC
var _started := false
var _stopped: Array[Node] = []
var _cut: Array[Label3D] = []
var _report_left := REPORT_SEC
var _scale := 1.0
var _enlarged := false
var _measuring := false
var _render_cpu := 0.0
var _render_gpu := 0.0
var _process_time := 0.0
var _frames := 0
var _steps: Array[String] = STEPS
var _log_dock: Node
var _log_parent: Node
var _paused: Array[Node] = []
var _paused_physics: Array[Node] = []
var _modes: Dictionary[Node, Node.ProcessMode] = {}
var _updates: Dictionary[SubViewport, SubViewport.UpdateMode] = {}
var _step_sec := STEP_SEC
var _compat := false
var _root_stopped := false
var _rendering_changed := false
var _views_on := false
var _views: Dictionary[int, _View] = {}
## The views read every frame, rebuilt at each report: a loop over all of [member _views] is itself too slow.
var _active_views: Array[_View] = []
var _scene_rids: Array[RID] = []
var _scene_mesh: BoxMesh
var _shots := false
var _shot_taken := false
var _away := false
var _busy_frame := -2
var _xr: OpenXRInterface


func _init(service: XREBlueprints, document: XREDocument) -> void:
	_service = service
	_document = document


func _enter_tree() -> void:
	_xr = _interface()
	if _xr == null: return
	# The states a session passes through when the headset is taken off or sleeps; they may come and go within
	# one frame, before _process sees the state.
	_xr.session_visible.connect(_on_session_left)
	_xr.session_synchronized.connect(_on_session_left)
	_xr.session_stopping.connect(_on_session_left)


func _exit_tree() -> void:
	if _xr == null: return
	_xr.session_visible.disconnect(_on_session_left)
	_xr.session_synchronized.disconnect(_on_session_left)
	_xr.session_stopping.disconnect(_on_session_left)
	_xr = null


func _on_session_left() -> void:
	_leave("the session left focus")


## The headset was taken off or slept: what the step has measured so far is void (D-161).
func _leave(reason: String) -> void:
	if _away: return
	_away = true
	if _started and _step >= 0 and _step < _steps.size():
		print(_LOG_PREFIX, "graph lab: away in %s%s: %s; the step starts again when the headset is back." % [COMPAT_STEP_PREFIX if _compat else "", _steps[_step], reason])


## The headset is back: the warm-up, or the step that was cut, starts again from the beginning with its line.
func _come_back() -> void:
	_away = false
	_discard_measures()
	if not _started:
		_left = WARMUP_SEC
		return
	_left = _step_sec
	_report_left = REPORT_SEC
	_shot_taken = false
	print(_LOG_PREFIX, "graph lab: ", COMPAT_STEP_PREFIX if _compat else "", _steps[_step])


## Forgets the times summed since the last report.
func _discard_measures() -> void:
	_render_cpu = 0.0
	_render_gpu = 0.0
	_process_time = 0.0
	_frames = 0
	for view: _View in _views.values():
		view.cpu = 0.0
		view.gpu = 0.0
		view.frames = 0
	_service.take_process_times()
	var rig := _service.get("_rig") as Node
	var manipulator := rig.find_child("XREManipulator", false, false) as XREManipulator if rig != null else null
	if manipulator != null: manipulator.take_process_time()


## A copy of [param graph] with [param factor] copies of its blocks and wires, in a grid
## of two columns around its centre (in [param columns] columns), for the steps on a larger graph. Never saved.
static func enlarged(graph: XREBlueprintGraph, factor: int, columns := 2) -> XREBlueprintGraph:
	var result := XREBlueprintGraph.new()
	result.format_version = graph.format_version
	result.variables = graph.variables
	result.functions = graph.functions
	result.host_path = graph.host_path
	result.scene_path = graph.scene_path
	result.vr_workspace = graph.vr_workspace
	var stride := 0
	var low := Vector2.INF
	var high := -Vector2.INF
	for node: Dictionary in graph.nodes:
		stride = maxi(stride, node.id as int + 1)
		var place: Vector2 = node.position
		low = low.min(place)
		high = high.max(place)
	# With a gap: copies a graph's own size apart meet at its corners.
	var step := (high - low) * 1.25 if not graph.nodes.is_empty() else Vector2.ZERO
	for copy: int in factor:
		var offset := Vector2(copy % columns, copy / columns) * step
		for node: Dictionary in graph.nodes:
			var block := node.duplicate(true)
			block.id = (node.id as int) + copy * stride
			block.position = (node.position as Vector2) + offset
			result.nodes.append(block)
		for edge: Dictionary in graph.edges:
			var wire := edge.duplicate(true)
			wire.from = (edge.from as int) + copy * stride
			wire.to = (edge.to as int) + copy * stride
			result.edges.append(wire)
	return result


## A copy of [param graph] with [param blocks] blocks (the source's, repeated in a square grid, the last copy cut
## short) and the wires between those that are left. Never saved.
static func grown(graph: XREBlueprintGraph, blocks: int) -> XREBlueprintGraph:
	var copies := ceili(float(blocks) / maxi(graph.nodes.size(), 1))
	var result := enlarged(graph, maxi(copies, 1), ceili(sqrt(float(copies))))
	if result.nodes.size() > blocks: result.nodes.resize(blocks)
	var kept: Dictionary[int, bool] = {}
	for node: Dictionary in result.nodes: kept[node.id as int] = true
	var wires: Array[Dictionary] = []
	for edge: Dictionary in result.edges:
		if kept.has(edge.from as int) and kept.has(edge.to as int): wires.append(edge)
	result.edges = wires
	return result


## The number of blocks a step's name asks the graph to have ([code]graphN[/code]), or 0.
static func graph_blocks(step: String) -> int:
	return _number_after(step, "graph", 1)


## The number of objects a step's name asks the scene to have ([code]sceneNk[/code], thousands), or 0.
static func scene_objects(step: String) -> int:
	return _number_after(step, "scene", 1000) if step.contains("k") else 0


static func _number_after(step: String, word: String, unit: int) -> int:
	var at := step.find(word)
	if at < 0: return 0
	var digits := ""
	for index: int in range(at + word.length(), step.length()):
		if step[index] < "0" or step[index] > "9": break
		digits += step[index]
	return digits.to_int() * unit


## The steps [constant STEPS_FLAG] in [param args] lists, or none without it.
static func custom_steps(args: PackedStringArray) -> Array[String]:
	var steps: Array[String] = []
	for arg: String in args:
		if not arg.begins_with(STEPS_FLAG): continue
		steps.clear()
		for step: String in arg.substr(STEPS_FLAG.length()).split(",", false): steps.append(step.strip_edges())
	return steps


## The settings [constant FEATURE_FLAG] in [param args] sets for the run, by key.
static func lab_features(args: PackedStringArray) -> Dictionary[StringName, StringName]:
	var features: Dictionary[StringName, StringName] = {}
	for arg: String in args:
		if not arg.begins_with(FEATURE_FLAG): continue
		var pair := arg.substr(FEATURE_FLAG.length()).split("=")
		if pair.size() == 2: features[StringName(pair[0].strip_edges())] = StringName(pair[1].strip_edges())
	return features


## What is wrong with the steps and settings [param args] give the lab: a step not named in
## [code][a-z_0-9]+[/code], an empty list, an unknown setting or value. Empty when the run may start.
static func flag_errors(args: PackedStringArray) -> Array[String]:
	var errors: Array[String] = []
	var name := RegEx.create_from_string("^[a-z_0-9]+$")
	for arg: String in args:
		if arg.begins_with(STEPS_FLAG) and custom_steps(PackedStringArray([arg])).is_empty(): errors.append("no steps in %s" % arg)
		if arg.begins_with(FEATURE_FLAG) and arg.substr(FEATURE_FLAG.length()).split("=").size() != 2: errors.append("not key=value: %s" % arg)
	for step: String in custom_steps(args):
		if name.search(step) == null: errors.append("a step's name isn't [a-z_0-9]+: '%s'" % step)
	var features := lab_features(args)
	for key: StringName in features:
		if not key in XREFeatureSettings.DEFINITIONS: errors.append("no setting %s" % key)
		elif not features[key] in XREFeatureSettings.get_values(key): errors.append("setting %s has no value %s" % [key, features[key]])
	return errors


## Engine arguments that run a process on Compatibility.
static func compat_engine_args() -> PackedStringArray:
	return PackedStringArray(["--rendering-method", "gl_compatibility", "--rendering-driver", "opengl3"])


## The command line of [constant GAME_SCENE] as a game, on Compatibility if [param compat], one second a step if [param fast].
static func game_args(compat: bool, fast: bool) -> PackedStringArray:
	var args := PackedStringArray(["--path", ProjectSettings.globalize_path("res://"), "--scene", GAME_SCENE])
	if compat: args.append_array(compat_engine_args())
	args = XREPlayMode.game_args(args)
	var user := PackedStringArray()
	if compat: user.append(COMPAT_ARG)
	if fast: user.append("--xre-lab-fast")
	if not user.is_empty():
		args.append("--")
		args.append_array(user)
	return args


func _process(delta: float) -> void:
	# The lab's own long frames (a step that builds a large graph, a picture) are not a stall.
	if delta > STALL_SEC and Engine.get_process_frames() > _busy_frame + 1: _leave("the process stood still %.1f s" % delta)
	if not _ready_to_start():
		if _host() != null: _leave("the session isn't focused")
		return
	if _away:
		_come_back()
		return
	var user_args := OS.get_cmdline_user_args()
	if user_args.has(GAME_FLAG) or user_args.has(COMPAT_FLAG):
		print(_LOG_PREFIX, "graph lab: leaving for the game process.")
		set_process(false)
		OS.create_instance(game_args(user_args.has(COMPAT_FLAG), false))
		return
	_measure()
	_report_left -= delta
	if _report_left <= 0.0 and _started:
		_report()
	_left -= delta
	if _shots and _started and not _shot_taken and _left <= _step_sec * 0.5:
		_shot_taken = true
		_snap(_steps[_step])
		_busy_frame = Engine.get_process_frames()
	if _left > 0.0: return
	_left = _step_sec
	# What the last frames of the step did, if the timer hasn't just said it: a report is then the step's own tail.
	if _started and _frames >= MIN_REPORT_FRAMES: _report()
	_report_left = REPORT_SEC
	if not _started:
		_started = true
		var xr := _interface()
		if xr != null: _scale = xr.render_target_size_multiplier
		if OS.get_cmdline_user_args().has(EDITOR_FLAG):
			_steps = EDITOR_STEPS
			_log_inventory()
		if OS.get_cmdline_user_args().has(BASE_FLAG): _start_base()
		if OS.get_cmdline_user_args().has(STRESS_FLAG): _start_stress()
		if OS.get_cmdline_user_args().has(VIEWS_FLAG): _views_on = true
		if OS.get_cmdline_user_args().has(POSE_FLAG): _start_pose()
		var args := OS.get_cmdline_user_args()
		var errors := flag_errors(args)
		if not errors.is_empty():
			push_error(_LOG_PREFIX + "graph lab: not started: " + "; ".join(errors))
			_restore()
			queue_free()
			return
		var custom := custom_steps(args)
		if not custom.is_empty(): _steps = custom
		var features := lab_features(args)
		for key: StringName in features:
			_document.set_feature_for_run(key, features[key], XREDocument.Source.TOOL)
			print(_LOG_PREFIX, "graph lab: feature %s=%s" % [key, features[key]])
	_step += 1
	_shot_taken = false
	if _step >= _steps.size():
		_restore()
		if _steps == BASE_STEPS and not OS.get_cmdline_user_args().has(FAST_FLAG):
			print(_LOG_PREFIX, "graph lab: leaving for Compatibility.")
			set_process(false)
			XREStandalone.open_editor_in_vr(PackedStringArray([CLI_FLAG, BASE_FLAG, COMPAT_ARG]), _document.get_scene_root().scene_file_path, compat_engine_args())
			return
		print(_LOG_PREFIX, "graph lab: done.")
		if OS.get_cmdline_user_args().has(FAST_FLAG): get_tree().quit()
		queue_free()
		return
	print(_LOG_PREFIX, "graph lab: ", COMPAT_STEP_PREFIX if _compat else "", _steps[_step])
	_apply(_steps[_step])
	_busy_frame = Engine.get_process_frames()


## Sets up the steps of what the GPU's base is made of.
func _start_base() -> void:
	var args := OS.get_cmdline_user_args()
	_compat = args.has(COMPAT_ARG)
	_steps = BASE_COMPAT_STEPS if _compat else BASE_STEPS
	_step_sec = 1.0 if args.has(FAST_FLAG) else BASE_STEP_SEC
	_left = _step_sec
	_views_on = true
	_fix_foveation()


## Sets up the steps of how the cost grows with the graph's and the scene's size.
func _start_stress() -> void:
	_steps = STRESS_STEPS
	_step_sec = 1.0 if OS.get_cmdline_user_args().has(FAST_FLAG) else BASE_STEP_SEC
	_left = _step_sec
	_views_on = true
	_fix_foveation()


## Sets up the steps of the framing check.
func _start_pose() -> void:
	_steps = POSE_STEPS
	_step_sec = 1.0 if OS.get_cmdline_user_args().has(FAST_FLAG) else POSE_STEP_SEC
	_left = _step_sec
	_shots = true
	print(_LOG_PREFIX, "graph lab: framing with tangents ", _view_tangents())


## Logs the renderer, and has foveation stay at one level whatever the load.
func _fix_foveation() -> void:
	print(_LOG_PREFIX, "graph lab: renderer ", RenderingServer.get_current_rendering_method(), " on ", RenderingServer.get_current_rendering_driver_name())
	var xr := _interface()
	if xr == null: return
	xr.foveation_dynamic = false
	xr.foveation_level = BASE_FOVEATION
	print(_LOG_PREFIX, "graph lab: foveation %s, render target %s." % ["supported" if xr.is_foveation_supported() else "not supported", xr.get_render_target_size()])


## Adds this frame's render times of the VR view; the first call has the server measure them.
func _measure() -> void:
	var rig := _service.get("_rig") as Node
	if rig == null or not rig.is_inside_tree(): return
	var rid := rig.get_viewport().get_viewport_rid()
	if not _measuring:
		_measuring = true
		RenderingServer.viewport_set_measure_render_time(rid, true)
	_render_cpu += RenderingServer.viewport_get_measured_render_time_cpu(rid)
	_render_gpu += RenderingServer.viewport_get_measured_render_time_gpu(rid)
	if _views_on:
		if _views.is_empty(): _refresh_views()
		for view: _View in _active_views:
			if not is_instance_id_valid(view.id): continue
			view.cpu += RenderingServer.viewport_get_measured_render_time_cpu(view.rid)
			view.gpu += RenderingServer.viewport_get_measured_render_time_gpu(view.rid)
			view.frames += 1
	_process_time += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	_frames += 1


## Logs the graph's script time and the frames since the last report.
func _report() -> void:
	_report_left = REPORT_SEC
	var times := _service.take_process_times()
	var manipulator := (_service.get("_rig") as Node).find_child("XREManipulator", false, false) as XREManipulator
	# D-158: the panels' routing and the manipulator are outside the graph scripts, and the routing holds a frame's first facing while a hand is free.
	print(_LOG_PREFIX, "graph lab: graph scripts %.2f ms per frame, of them facing the head %.2f ms; ray routing %.2f ms; manipulator %.2f ms." % [times.x, times.y, times.z, manipulator.take_process_time() if manipulator != null else 0.0])
	_report_frames()


## Logs the frames since the last report, for a runtime without VrApi's counters.
func _report_frames() -> void:
	var frames := maxi(_frames, 1)
	print(_LOG_PREFIX, "graph lab: frames %d fps, VR view render CPU %.2f ms, GPU %.2f ms, process %.2f ms, %d draw calls." % [
		roundi(Engine.get_frames_per_second()), _render_cpu / frames, _render_gpu / frames, _process_time / frames,
		roundi(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))])
	if _views_on:
		_report_views()
		_refresh_views()
	_render_cpu = 0.0
	_render_gpu = 0.0
	_process_time = 0.0
	_frames = 0


## Logs, for every viewport that rendered, its render time per frame since the last report and what its last frame
## drew: the VR view, the editor's window and views, the plugin's panels (D-157, step 1.1). Compatibility on
## Android writes no GPU time (utilities.cpp), so its GPU column stays zero. A view that drew for the first time is
## made active here and logged from the next report on, over the frames it was read in.
func _report_views() -> void:
	for view: _View in _views.values():
		if not is_instance_id_valid(view.id): continue
		var rid := view.rid
		var visible_info := RenderingServer.VIEWPORT_RENDER_INFO_TYPE_VISIBLE
		var calls := RenderingServer.viewport_get_render_info(rid, visible_info, RenderingServer.VIEWPORT_RENDER_INFO_DRAW_CALLS_IN_FRAME)
		var objects := RenderingServer.viewport_get_render_info(rid, visible_info, RenderingServer.VIEWPORT_RENDER_INFO_OBJECTS_IN_FRAME)
		var primitives := RenderingServer.viewport_get_render_info(rid, visible_info, RenderingServer.VIEWPORT_RENDER_INFO_PRIMITIVES_IN_FRAME)
		var shadow := RenderingServer.viewport_get_render_info(rid, RenderingServer.VIEWPORT_RENDER_INFO_TYPE_SHADOW, RenderingServer.VIEWPORT_RENDER_INFO_DRAW_CALLS_IN_FRAME)
		var canvas := RenderingServer.viewport_get_render_info(rid, RenderingServer.VIEWPORT_RENDER_INFO_TYPE_CANVAS, RenderingServer.VIEWPORT_RENDER_INFO_DRAW_CALLS_IN_FRAME)
		if not view.active:
			view.active = calls > 0 or canvas > 0 or shadow > 0 \
					or RenderingServer.viewport_get_measured_render_time_cpu(rid) > 0.0 \
					or RenderingServer.viewport_get_measured_render_time_gpu(rid) > 0.0
		elif view.cpu > 0.0 or view.gpu > 0.0 or calls > 0 or canvas > 0:
			var read := maxi(view.frames, 1)
			print(_LOG_PREFIX, "graph lab: view %s: render CPU %.2f ms, GPU %.2f ms, visible %d call(s) %d object(s) %d primitive(s), shadow %d call(s), canvas %d call(s)." % [
				view.label, view.cpu / read, view.gpu / read, calls, objects, primitives, shadow, canvas])
		view.cpu = 0.0
		view.gpu = 0.0
		view.frames = 0


## Has the server measure every viewport that now exists, and forgets those that are gone.
func _refresh_views() -> void:
	var live: Array[Viewport] = [get_tree().root]
	for node: Node in get_tree().root.find_children("*", "Viewport", true, false):
		live.append(node as Viewport)
	var kept: Dictionary[int, bool] = {}
	for viewport: Viewport in live:
		var id := viewport.get_instance_id()
		kept[id] = true
		if _views.has(id): continue
		var view := _View.new()
		view.rid = viewport.get_viewport_rid()
		view.id = id
		var named := viewport.name as String if viewport == get_tree().root else "%s/%s" % [viewport.get_parent().name, viewport.name]
		view.label = named.replace(" ", "_")
		_views[id] = view
		RenderingServer.viewport_set_measure_render_time(view.rid, true)
	for id: int in _views.keys():
		if not kept.has(id): _views.erase(id)
	_active_views.clear()
	for view: _View in _views.values():
		if view.active: _active_views.append(view)


## The scene is loaded and, with a headset, the session has focus.
func _ready_to_start() -> bool:
	if _host() == null: return false
	var xr := _interface()
	return xr == null or xr.get_session_state() == OpenXRInterface.SESSION_STATE_FOCUSED


func _interface() -> OpenXRInterface:
	return XRServer.primary_interface as OpenXRInterface


func _graph_open() -> bool:
	var workspace := _service.get("_workspace") as Node3D
	return workspace != null and workspace.visible


func _host() -> Node3D:
	var root := _service.get("_root") as Node
	return root.find_child(HOST, true, false) as Node3D if root != null else null


func _apply(step: String) -> void:
	_restore()
	_add_scene_objects(scene_objects(step))
	if step.begins_with("closed"):
		if _graph_open(): _service.close_graph()
		_frame_view()
		_editor_off(step)
		return
	if not _graph_open():
		_document.select([_host()], XREDocument.Source.TOOL)
		_service.open_selected()
	var blocks := graph_blocks(step)
	if blocks > 0:
		var sized := grown(_service.blueprint.graph, blocks)
		print(_LOG_PREFIX, "graph lab: graph of %d block(s), %d wire(s)." % [sized.nodes.size(), sized.edges.size()])
		_show(sized, true)
	elif step.contains("big2"): _show(enlarged(_service.blueprint.graph, 2), true)
	elif step.contains("big4"): _show(enlarged(_service.blueprint.graph, 4), true)
	elif _enlarged: _show(_service.blueprint.graph, false)
	_frame_view()
	if step.contains("service_off"):
		_service.set_process(false)
		_stopped.append(_service)
	if step.contains("scale"):
		var xr := _interface()
		if xr != null: xr.render_target_size_multiplier = _scale * SCALE
	if step.contains("_off"): _hide_kind(step)
	if step.contains("text_cut"): _cut_text()
	_editor_off(step)


## Moves the rig, and with it the user, to where the whole scene and the open graph are in view: looking at the middle of
## their boxes from the side the graph faces, upright, from as near as everything's corners fit in the field of view both
## eyes share. The graph and the scene stay where they are, and so does the way the user's head is turned in the rig:
## the rig turns to make the camera look right.
func _frame_view() -> void:
	var rig := _service.get("_rig") as XRERig
	var workspace := _service.get("_workspace") as Node3D
	if rig == null or rig.camera == null or workspace == null: return
	var scene_box := _box_of(_document.get_scene_root(), SCENE_PART_MAX)
	var graph_box := _box_of(_service.canvas, INF) if _graph_open() else AABB()
	var box := scene_box
	if graph_box.size != Vector3.ZERO: box = graph_box if scene_box.size == Vector3.ZERO else scene_box.merge(graph_box)
	if box.size == Vector3.ZERO: return
	var back := _view_back()
	var centre := box.get_center()
	var tangents := _view_tangents()
	var distance := VIEW_MIN_DISTANCE
	var standing := centre + back * distance + Vector3.UP * VIEW_LIFT
	var gaze := Basis.looking_at(centre - standing, Vector3.UP)
	for _try: int in 600:
		standing = centre + back * distance + Vector3.UP * VIEW_LIFT
		gaze = Basis.looking_at(centre - standing, Vector3.UP)
		if _fits(box, standing, gaze, tangents): break
		distance += VIEW_STEP
	var inside := rig.global_transform.affine_inverse() * rig.camera.global_transform
	var turned := (gaze * inside.basis.inverse()).orthonormalized()
	rig.global_transform = Transform3D(turned, standing - turned * inside.origin)
	_service.canvas.face_user(rig.camera.global_position)
	print(_LOG_PREFIX, "graph lab: view of scene %s and graph %s from %.2f m, tangents %.2f x %.2f." % [scene_box, graph_box, distance, tangents.x, tangents.y])


## Whether all corners of [param box] are in the view of a camera at [param at] turned by [param gaze].
func _fits(box: AABB, at: Vector3, gaze: Basis, tangents: Vector2) -> bool:
	var back := gaze.inverse()
	for corner: int in 8:
		var point := back * (box.get_endpoint(corner) - at)
		var depth := -point.z
		if depth < 0.05 or absf(point.x) > tangents.x * depth or absf(point.y) > tangents.y * depth: return false
	return true


## The box, in the world, of the visible geometry under [param root] whose parts are not longer than [param limit] across.
func _box_of(root: Node, limit: float) -> AABB:
	var box := AABB()
	var found := false
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		var item := node as GeometryInstance3D
		if item == null or not item.is_visible_in_tree(): continue
		var part := item.global_transform * item.get_aabb()
		if part.size.length() > limit: continue
		box = box.merge(part) if found else part
		found = true
	return box


## The tangents of the half angles, horizontal and vertical, of the field of view both eyes share, taken by
## [constant VIEW_FILL]; 40 degrees where there are no eyes (a window).
func _view_tangents() -> Vector2:
	var xr := XRServer.primary_interface
	var low := Vector2(0.84, 0.84)
	if xr != null and xr.get_view_count() > 0:
		low = Vector2.INF
		for view: int in xr.get_view_count():
			var projection := xr.get_projection_for_view(view, 1.0, 0.1, 100.0)
			var focal := Vector2(absf(projection.x.x), absf(projection.y.y))
			if focal.x < 0.0001 or focal.y < 0.0001: continue
			var shift := Vector2(projection.z.x, projection.z.y)
			low = low.min(Vector2(minf(absf(shift.x + 1.0), absf(shift.x - 1.0)) / focal.x, minf(absf(shift.y + 1.0), absf(shift.y - 1.0)) / focal.y))
		if not is_finite(low.x) or not is_finite(low.y): low = Vector2(0.84, 0.84)
	return low * VIEW_FILL


## Saves a picture of what a camera at the head sees, as wide as the framing counts on, to [constant SHOT_DIR].
func _snap(label: String) -> void:
	var rig := _service.get("_rig") as XRERig
	if rig == null or rig.camera == null: return
	var view := SubViewport.new()
	view.size = Vector2i(SHOT_SIZE, SHOT_SIZE)
	view.world_3d = rig.get_viewport().world_3d
	view.render_target_update_mode = SubViewport.UPDATE_ONCE
	var camera := Camera3D.new()
	camera.cull_mask = rig.camera.cull_mask
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	camera.fov = rad_to_deg(2.0 * atan(_view_tangents().x / VIEW_FILL))
	view.add_child(camera)
	add_child(view)
	camera.global_transform = rig.camera.global_transform
	camera.current = true
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var folder := ProjectSettings.globalize_path(SHOT_DIR)
	DirAccess.make_dir_recursive_absolute(folder)
	# The editor would import the pictures, and give two copies of one (a pulled one) the same uid.
	if not FileAccess.file_exists(folder + "/.gdignore"): FileAccess.open(folder + "/.gdignore", FileAccess.WRITE)
	var path := "%s/lab_%s.png" % [folder, label]
	var saved := view.get_texture().get_image().save_png(path)
	print(_LOG_PREFIX, "graph lab: picture %s %s." % [path, "saved" if saved == OK else "not saved (%d)" % saved])
	view.queue_free()


func _show(graph: XREBlueprintGraph, enlarged_graph: bool) -> void:
	_enlarged = enlarged_graph
	var began := Time.get_ticks_usec()
	_service.canvas.center_graph(graph)
	_service.canvas.rebuild(graph)
	print(_LOG_PREFIX, "graph lab: rebuilt %d block(s) in %.1f ms." % [graph.nodes.size(), (Time.get_ticks_usec() - began) / 1000.0])


## Hides the canvas's visible objects of the kind [param step] names, and logs how many.
func _hide_kind(step: String) -> void:
	var count := 0
	var stack: Array[Node] = [_service.canvas]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		if node is GeometryInstance3D and (node as GeometryInstance3D).visible and step.contains(kind_of(node as GeometryInstance3D, _service.canvas)):
			(node as Node3D).visible = false
			_stopped.append(node)
			count += 1
		elif node is GeometryInstance3D and (node as GeometryInstance3D).visible and step.contains("all_off"):
			(node as Node3D).visible = false
			_stopped.append(node)
			count += 1
	print(_LOG_PREFIX, "graph lab: hid %d object(s)." % count)


## The name, as a step holds it, of the kind of object [param node] of [param canvas] is.
static func kind_of(node: GeometryInstance3D, canvas: XREBlueprintCanvas) -> String:
	if node is Label3D: return "text_off"
	if node is XREGraphWire: return "wires_off"
	if not (node is MeshInstance3D): return "other_off"
	var mesh := (node as MeshInstance3D).mesh
	var sphere := canvas.get("_sphere_mesh") as Mesh
	var knot := canvas.get("_knot_mesh") as Mesh
	if mesh != null and mesh == sphere: return "ports_off"
	if mesh != null and mesh == knot: return "wires_off"
	var shaded := node.material_override is ShaderMaterial or (mesh != null and mesh.get_surface_count() > 0 and mesh.surface_get_material(0) is ShaderMaterial)
	return "shader_off" if shaded else "plain_off"


## Cuts the canvas's text out of the transparent pass, as alpha scissor does, and logs how many labels.
func _cut_text() -> void:
	var stack: Array[Node] = [_service.canvas]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		if node is Label3D:
			(node as Label3D).alpha_cut = Label3D.ALPHA_CUT_DISCARD
			_cut.append(node as Label3D)
	print(_LOG_PREFIX, "graph lab: cut %d label(s)." % _cut.size())


## Adds [param count] objects to the scene's world on the rendering server only: separate instances of one box, as a
## scene of that many meshes would be, in a cube of a lattice behind the scene's host as the views see it ([method _view_back]),
## [constant SCENE_NEAR] metres beyond it and standing on the ground, so that all of them are in the view of the head that
## [method _frame_view] puts in front of the host. No node, nothing saved.
func _add_scene_objects(count: int) -> void:
	if count <= 0: return
	var host := _host()
	if host == null: return
	if _scene_mesh == null:
		_scene_mesh = BoxMesh.new()
		_scene_mesh.size = Vector3.ONE * SCENE_OBJECT
		_scene_mesh.material = StandardMaterial3D.new()
	var scenario := host.get_world_3d().scenario
	var side := ceili(pow(float(count), 1.0 / 3.0))
	var back := _view_back()
	var right := Vector3.UP.cross(back)
	var origin := Vector3(host.global_position.x, SCENE_BASE, host.global_position.z)
	for index: int in count:
		var cell := Vector3(index % side, index / side % side, index / (side * side))
		var place := origin + right * ((cell.x - side * 0.5) * SCENE_SPACING) + Vector3.UP * (cell.y * SCENE_SPACING) - back * (SCENE_NEAR + cell.z * SCENE_SPACING)
		var rid := RenderingServer.instance_create2(_scene_mesh.get_rid(), scenario)
		RenderingServer.instance_set_transform(rid, Transform3D(Basis.IDENTITY, place))
		_scene_rids.append(rid)
	print(_LOG_PREFIX, "graph lab: scene of %d object(s) added." % _scene_rids.size())


## The horizontal direction from the scene to the head's side: the way the graph's front faces.
func _view_back() -> Vector3:
	var workspace := _service.get("_workspace") as Node3D
	if workspace == null: return Vector3.BACK
	var back := Vector3(workspace.global_basis.z.x, 0.0, workspace.global_basis.z.z)
	return back.normalized() if back.length_squared() > 0.0001 else Vector3.BACK


func _restore() -> void:
	for rid: RID in _scene_rids:
		RenderingServer.free_rid(rid)
	_scene_rids.clear()
	for label: Label3D in _cut:
		if is_instance_valid(label): label.alpha_cut = Label3D.ALPHA_CUT_DISABLED
	_cut.clear()
	for node: Node in _stopped:
		if not is_instance_valid(node): continue
		if node is Node3D and node != _service: (node as Node3D).visible = true
		else: node.set_process(true)
	_stopped.clear()
	var xr := _interface()
	if xr != null and _started: xr.render_target_size_multiplier = _scale
	Engine.print_error_messages = true
	if _log_dock != null:
		_log_parent.add_child(_log_dock)
		_log_dock = null
	PhysicsServer3D.set_active(true)
	PhysicsServer2D.set_active(true)
	for node: Node in _paused:
		if is_instance_valid(node): node.set_process(true)
	_paused.clear()
	for node: Node in _paused_physics:
		if is_instance_valid(node): node.set_physics_process(true)
	_paused_physics.clear()
	for node: Node in _modes:
		if is_instance_valid(node): node.process_mode = _modes[node]
	_modes.clear()
	for viewport: SubViewport in _updates:
		if is_instance_valid(viewport): viewport.render_target_update_mode = _updates[viewport]
	_updates.clear()
	if _root_stopped:
		_root_stopped = false
		RenderingServer.viewport_set_update_mode(get_tree().root.get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_WHEN_VISIBLE)
	if _rendering_changed:
		_rendering_changed = false
		_set_scene_rendering(false, false, false)


## Applies what [param step] turns off of the editor and the plugin, and logs how much.
func _editor_off(step: String) -> void:
	if step.contains("errors_off") or step.contains("log_off"): Engine.print_error_messages = false
	if step.contains("log_off"): _take_out_log()
	if step.contains("physics_off"):
		PhysicsServer3D.set_active(false)
		PhysicsServer2D.set_active(false)
	if step.contains("panels_off"): _pause_tool("XREPanels")
	if step.contains("manipulator_off"): _pause_tool("XREManipulator")
	if step.contains("views_off"): _stop_viewports()
	if step.contains("root_off"):
		_root_stopped = true
		RenderingServer.viewport_set_update_mode(get_tree().root.get_viewport_rid(), RenderingServer.VIEWPORT_UPDATE_DISABLED)
	if step.contains("vr_off") or step.contains("empty"): _hide_vr(false)
	if step.contains("ui_off"): _hide_vr(true)
	if step.contains("dimmer_off"): _hide_node(_service.get("_dimmer") as Node3D)
	var empty := step.contains("empty")
	if empty or step.contains("lean") or step.contains("scene_off"):
		_rendering_changed = true
		_set_scene_rendering(empty or step.contains("lean"), empty or step.contains("scene_off"), empty)
	if step.contains("editor_off") or step.contains("tree_off"): _stop_editor()
	if step.contains("plugin_off") or step.contains("tree_off"): _stop_plugin(step.contains("tree_off"))
	print(_LOG_PREFIX, "graph lab: stopped %d viewport(s), %d branch(es), %d script(s), %d physics script(s)." % [_updates.size(), _modes.size(), _paused.size(), _paused_physics.size()])


## The Output dock leaves the tree: EditorLog's handler then adds nothing to its RichTextLabel for the error of
## every frame (D-004), which [member Engine.print_error_messages] doesn't stop (editor_log.cpp, _add_log_line).
func _take_out_log() -> void:
	var found := EditorInterface.get_base_control().find_children("*", "EditorLog", true, false)
	if found.is_empty(): return
	_log_dock = found[0]
	_log_parent = _log_dock.get_parent()
	_log_parent.remove_child(_log_dock)


## Hides what the VR layer draws, or, if [param keep_graph], all of it but the graph and what dims the scene behind it.
func _hide_vr(keep_graph: bool) -> void:
	var dimmer := _service.get("_dimmer") as Node
	var count := 0
	var stack: Array[Node] = [_service.get("_rig") as Node]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if keep_graph and (node == _service.canvas or node == dimmer): continue
		stack.append_array(node.get_children())
		if node is GeometryInstance3D and (node as GeometryInstance3D).visible:
			_hide_node(node as Node3D)
			count += 1
	print(_LOG_PREFIX, "graph lab: hid %d object(s) of the VR layer." % count)


func _hide_node(node: Node3D) -> void:
	if node == null or not node.visible: return
	node.visible = false
	_stopped.append(node)


## Turns off, or back on, the costs of the edited scene: sky and tonemapper if [param lean], its meshes if
## [param meshes], its lights if [param lights]. On the rendering server only: the scene's nodes and resources stay as they are.
func _set_scene_rendering(lean: bool, meshes: bool, lights: bool) -> void:
	var stack: Array[Node] = [_document.get_scene_root()]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		if node is WorldEnvironment and (node as WorldEnvironment).environment != null:
			var environment := (node as WorldEnvironment).environment
			RenderingServer.environment_set_background(environment.get_rid(), RenderingServer.ENV_BG_COLOR if lean else environment.background_mode as RenderingServer.EnvironmentBG)
			RenderingServer.environment_set_tonemap(environment.get_rid(), RenderingServer.ENV_TONE_MAPPER_LINEAR if lean else environment.tonemap_mode as RenderingServer.EnvironmentToneMapper, environment.tonemap_exposure, environment.tonemap_white)
		elif node is Light3D:
			var light := node as Light3D
			RenderingServer.instance_set_visible(light.get_instance(), light.is_visible_in_tree() and not lights)
		elif node is GeometryInstance3D:
			var instance := node as GeometryInstance3D
			RenderingServer.instance_set_visible(instance.get_instance(), instance.is_visible_in_tree() and not meshes)


## Every viewport but the VR view stops updating: the editor's 3D and 2D views and the plugin's panels.
func _stop_viewports() -> void:
	for node: Node in get_tree().root.find_children("*", "SubViewport", true, false):
		var viewport := node as SubViewport
		if viewport == _service.get_viewport() or viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED: continue
		_updates[viewport] = viewport.render_target_update_mode
		viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED


## The editor's nodes stop processing: every branch under its root but the one to the VR plugin.
func _stop_editor() -> void:
	var editor := EditorInterface.get_base_control().get_parent()
	for child: Node in editor.get_children():
		if child.is_ancestor_of(_service) or child.process_mode == Node.PROCESS_MODE_DISABLED: continue
		_modes[child] = child.process_mode
		child.process_mode = Node.PROCESS_MODE_DISABLED
	_pause(editor)


## The plugin's scripts stop, but for the native frame loop and controllers, which keep the session
## alive, and this lab; the graph's service too if [param service].
func _stop_plugin(service: bool) -> void:
	var editor := EditorInterface.get_base_control().get_parent()
	var stack: Array[Node] = []
	for child: Node in editor.get_children():
		if child.is_ancestor_of(_service): stack.append(child)
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		if node == self or node.get_class().begins_with("XRE"): continue
		if node == _service and not service: continue
		_pause(node)


## One of the rig's tools, by name, stops: its ray tests run outside the graph's own script time (D-152).
func _pause_tool(tool_name: String) -> void:
	var tool_node := (_service.get("_rig") as Node).find_child(tool_name, false, false)
	if tool_node != null: _pause(tool_node)


func _pause(node: Node) -> void:
	if node.is_processing():
		node.set_process(false)
		_paused.append(node)
	if node.is_physics_processing():
		node.set_physics_process(false)
		_paused_physics.append(node)


## Logs what runs in this process: nodes and viewports, for reading the steps by.
func _log_inventory() -> void:
	var editor := EditorInterface.get_base_control().get_parent()
	for child: Node in editor.get_children():
		var nodes := 0
		var processing := 0
		var stack: Array[Node] = [child]
		while not stack.is_empty():
			var node: Node = stack.pop_back()
			stack.append_array(node.get_children())
			nodes += 1
			if node.is_processing() or node.is_physics_processing() or node.is_processing_internal() or node.is_physics_processing_internal(): processing += 1
		if nodes > 20 or processing > 0: print(_LOG_PREFIX, "graph lab: branch %s (%s): %d node(s), %d processing." % [child.name, child.get_class(), nodes, processing])
	for node: Node in get_tree().root.find_children("*", "SubViewport", true, false):
		var viewport := node as SubViewport
		print(_LOG_PREFIX, "graph lab: viewport %s size %s update %d under %s." % [viewport.name, viewport.size, viewport.render_target_update_mode, viewport.get_parent().name])
	print(_LOG_PREFIX, "graph lab: %d node(s) in all, %d object(s)." % [Performance.get_monitor(Performance.OBJECT_NODE_COUNT), Performance.get_monitor(Performance.OBJECT_COUNT)])
