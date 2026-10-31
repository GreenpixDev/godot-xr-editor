@tool
extends Node3D
## What the graph costs outside the editor (D-152): the canvas alone and the graph of
## BlueCube in a game process, in front of play_check's scene without its scripts and
## with the editor's MSAA. Steps of [constant STEP_SEC], logged as [XREGraphLab]'s, for
## [code]benchmarks/quest_fps_report.py[/code]. Nothing it does reaches a saved graph.
## [code]--xre-lab-fast[/code] after [code]--[/code]: one second a step, for a check without a headset.

const GRAPH := "res://benchmarks/blue_cube_blueprint_2.tres"
const BACKGROUND := "res://benchmarks/play_check.tscn"
const STEP_SEC := 25.0
const WARMUP_SEC := 15.0
const REPORT_SEC := 5.0
const STEPS: Array[String] = ["closed", "open", "open_big2", "open_big4", "open", "closed"]
## Half the angle of view every card stays in, and how far back the workspace may go for it.
const VIEW_ANGLE := deg_to_rad(35.0)
const MAX_DISTANCE := 12.0
const _LOG_PREFIX := "XR Editor: "

var _camera: XRCamera3D
var _workspace: Node3D
var _canvas: XREBlueprintCanvas
var _graph: XREBlueprintGraph
var _step := -1
var _left := WARMUP_SEC
var _step_sec := STEP_SEC
var _report_left := REPORT_SEC
var _script_usec := 0
var _process_time := 0.0
var _frames := 0


func _ready() -> void:
	if Engine.is_editor_hint(): return
	if OS.get_cmdline_user_args().has("--xre-lab-fast"):
		_step_sec = 1.0
		_left = 1.0
	var xr := XRServer.find_interface("OpenXR") as OpenXRInterface
	if xr != null and xr.is_initialized():
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
		print(_LOG_PREFIX, "graph lab: OpenXR on, display %.1f Hz." % xr.display_refresh_rate)
	get_viewport().msaa_3d = Viewport.MSAA_4X
	add_child(_background())
	var origin := XROrigin3D.new()
	add_child(origin)
	_camera = XRCamera3D.new()
	_camera.cull_mask = XRERig.SCENE_LAYERS | XRERig.VR_LAYER
	origin.add_child(_camera)
	_workspace = Node3D.new()
	_workspace.top_level = true
	_workspace.visible = false
	add_child(_workspace)
	_canvas = _make_canvas()
	_workspace.add_child(_canvas)
	_graph = ResourceLoader.load(GRAPH, "", ResourceLoader.CACHE_MODE_IGNORE) as XREBlueprintGraph
	_graph.upgrade()


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or _canvas == null: return
	if _workspace.visible:
		var started := Time.get_ticks_usec()
		_canvas.face_user(_camera.global_position, delta)
		_script_usec += Time.get_ticks_usec() - started
	_process_time += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	_frames += 1
	_report_left -= delta
	if _report_left <= 0.0:
		_report_left = REPORT_SEC
		_report()
	_left -= delta
	if _left > 0.0: return
	_left = _step_sec
	_step += 1
	if _step >= STEPS.size():
		print(_LOG_PREFIX, "graph lab: done.")
		set_process(false)
		if _step_sec < STEP_SEC: get_tree().quit()
		return
	print(_LOG_PREFIX, "graph lab: ", STEPS[_step])
	_apply(STEPS[_step])


func _apply(step: String) -> void:
	_workspace.visible = step != "closed"
	if step == "closed": return
	var head := _camera.global_position
	var orientation := XREPanels.facing(head - _camera.global_basis.z, head, Vector3.UP)
	_workspace.global_transform = Transform3D(orientation, head - orientation.z - Vector3.UP * 0.12)
	var graph := _graph
	if step.contains("big2"): graph = XREGraphLab.enlarged(_graph, 2)
	elif step.contains("big4"): graph = XREGraphLab.enlarged(_graph, 4)
	_canvas.center_graph(graph)
	_canvas.rebuild(graph)
	_fit_in_view(head, orientation)
	var visible_objects := 0
	var stack: Array[Node] = [_canvas]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		if node is GeometryInstance3D and (node as GeometryInstance3D).is_visible_in_tree(): visible_objects += 1
	print(_LOG_PREFIX, "graph lab: %d visible object(s) at %.2f m." % [visible_objects, head.distance_to(_workspace.global_position)])


## Moves the workspace back along the view until every card is within [constant VIEW_ANGLE] of it: none is culled,
## as none is in the editor's run, whose graph stands where it was placed.
func _fit_in_view(head: Vector3, orientation: Basis) -> void:
	var forward := -orientation.z
	var distance := 1.0
	while distance < MAX_DISTANCE:
		_workspace.global_position = head + forward * distance - Vector3.UP * 0.12
		var inside := true
		for item: Variant in _canvas.get("_cards") as Array:
			var card := item as XREBlueprintCanvas.Card
			var seen := (_workspace.to_global(card.base) - head).normalized()
			if seen.dot(forward) < cos(VIEW_ANGLE): inside = false
		if inside: return
		distance += 0.25


func _report() -> void:
	var frames := maxi(_frames, 1)
	print(_LOG_PREFIX, "graph lab: graph scripts %.1f ms per frame, of them facing the head %.1f ms." % [_script_usec / 1000.0 / frames, _script_usec / 1000.0 / frames])
	print(_LOG_PREFIX, "graph lab: frames %d fps, VR view render CPU 0.00 ms, GPU 0.00 ms, process %.2f ms, %d draw calls." % [
		roundi(Engine.get_frames_per_second()), _process_time / frames, roundi(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))])
	_script_usec = 0
	_process_time = 0.0
	_frames = 0


## play_check's scene as the editor shows it: its scripts don't run there.
func _background() -> Node:
	var scene := (load(BACKGROUND) as PackedScene).instantiate()
	var stack: Array[Node] = [scene]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		node.set_script(null)
	return scene


## A canvas with the features of the headset's runs of D-152, as [XREBlueprints] gives them.
func _make_canvas() -> XREBlueprintCanvas:
	var canvas := XREBlueprintCanvas.new()
	canvas.set_node_modes(&"on", false, false, &"both_faces", true)
	canvas.set_rim_ports(true)
	canvas.set_turn_modes(&"fixed", false)
	canvas.set_arrow_modes(&"running", &"at_end", true)
	canvas.set_style(&"archetypes")
	canvas.set_shrink(&"system")
	canvas.set_heading(&"member")
	canvas.set_port_shapes(false)
	canvas.set_collection_modes(&"grid", &"make", false)
	canvas.set_composite(&"split")
	canvas.set_plus_shown(false)
	canvas.set_bends_shown(true)
	canvas.set_copy_shown(true)
	canvas.set_port_display(&"sphere")
	canvas.set_parameter_modes(&"plugs", &"adapter", &"finished_port", &"boxes")
	canvas.set_focus_modes(&"front", &"dim")
	canvas.set_link_modes(&"variables", &"on_focus")
	return canvas
