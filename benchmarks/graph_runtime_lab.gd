@tool
extends Node3D
## What the graph and the renderer cost outside the editor (D-152, D-155): the canvas alone
## and the graph of BlueCube in a game process, in front of play_check's scene without its
## scripts and with the editor's MSAA. Steps of [constant STEP_SEC], logged as [XREGraphLab]'s,
## for [code]benchmarks/quest_lab_steps.py[/code]: [constant STEPS] on the renderer the project
## has, then the process starts itself again on Compatibility for [constant COMPAT_STEPS].
## A step's name holds what it changes from the open graph. Foveation stays at the same level
## through every step but one, so that it doesn't follow the load as its dynamic mode does.
## Nothing it does reaches a saved graph or scene.
## [code]--xre-lab-fast[/code] after [code]--[/code]: one second a step, for a check without a headset.

const GRAPH := "res://benchmarks/blue_cube_blueprint_2.tres"
const BACKGROUND := "res://benchmarks/play_check.tscn"
const STEP_SEC := 10.0
const WARMUP_SEC := 15.0
const REPORT_SEC := 4.0
const STEPS: Array[String] = [
	"open", "open_fov0", "open_gpu_boost", "open_sky_off", "open_shadow_off", "open_tonemap_off", "open",
	"open_scene_off", "open_lean", "open_scale", "open_near", "open_opaque", "open_shared", "open",
	"open_port_shapes", "open_values_window", "open_targets_window", "open_cheap", "open",
	"open_big2", "empty", "empty_msaa_off", "closed",
]
const COMPAT_STEPS: Array[String] = ["open", "open_near", "open_lean", "open_big2", "empty", "closed"]
## Half the angle of view every card stays in, and how far back the workspace may go for it.
const VIEW_ANGLE := deg_to_rad(35.0)
const MAX_DISTANCE := 12.0
## How far the graph stands in the near step: about where the editor's does.
const NEAR_DISTANCE := 1.5
## Scale of the render target in the scaled step.
const SCALE := 0.7
const _LOG_PREFIX := "XR Editor: "

var _camera: XRCamera3D
var _workspace: Node3D
var _canvas: XREBlueprintCanvas
var _graph: XREBlueprintGraph
var _xr: OpenXRInterface
var _environment: Environment
var _sun: DirectionalLight3D
var _scenery: Array[GeometryInstance3D] = []
var _materials: Dictionary[GeometryInstance3D, Material] = {}
var _steps: Array[String] = STEPS
var _compat := false
var _fast := false
var _built := ""
var _step := -1
var _left := WARMUP_SEC
var _step_sec := STEP_SEC
var _report_left := REPORT_SEC
var _script_usec := 0
var _process_time := 0.0
var _frames := 0


func _ready() -> void:
	if Engine.is_editor_hint(): return
	var args := OS.get_cmdline_user_args()
	_fast = args.has("--xre-lab-fast")
	_compat = args.has(XREGraphLab.COMPAT_ARG)
	if _compat: _steps = COMPAT_STEPS
	if _fast:
		_step_sec = 1.0
		_left = 1.0
	var xr := XRServer.find_interface("OpenXR") as OpenXRInterface
	if xr != null and xr.is_initialized():
		_xr = xr
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		get_viewport().use_xr = true
		_xr.foveation_dynamic = false
		print(_LOG_PREFIX, "graph lab: OpenXR on, display %.1f Hz, foveation %s, render target %s." % [_xr.display_refresh_rate, "supported" if _xr.is_foveation_supported() else "not supported", _xr.get_render_target_size()])
	print(_LOG_PREFIX, "graph lab: renderer ", RenderingServer.get_current_rendering_method(), " on ", RenderingServer.get_current_rendering_driver_name())
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
	_canvas = XREBlueprintCanvas.new()
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
	if _step >= _steps.size():
		_finish()
		return
	print(_LOG_PREFIX, "graph lab: ", XREGraphLab.COMPAT_STEP_PREFIX if _compat else "", _steps[_step])
	_apply(_steps[_step])


## After the project's renderer the process starts itself again on Compatibility; after that the run is over.
func _finish() -> void:
	set_process(false)
	if _compat:
		print(_LOG_PREFIX, "graph lab: done.")
	else:
		print(_LOG_PREFIX, "graph lab: leaving for Compatibility.")
		OS.create_instance(XREGraphLab.game_args(true, _fast))
	if _fast: get_tree().quit()


func _apply(step: String) -> void:
	_put_materials_back()
	_set_rendering(step)
	_workspace.visible = step.begins_with("open")
	if not _workspace.visible: return
	var head := _camera.global_position
	var orientation := XREPanels.facing(head - _camera.global_basis.z, head, Vector3.UP)
	_workspace.global_transform = Transform3D(orientation, head - orientation.z - Vector3.UP * 0.12)
	var build := step if step.contains("big2") or step.contains("port_shapes") or step.contains("window") or step.contains("cheap") else "open"
	if build != _built:
		_built = build
		_set_features(build)
		var graph := XREGraphLab.enlarged(_graph, 2) if build.contains("big2") else _graph
		_canvas.center_graph(graph)
		_canvas.rebuild(graph)
	if step.contains("near"): _workspace.global_position = head - orientation.z * NEAR_DISTANCE - Vector3.UP * 0.12
	else: _fit_in_view(head, orientation)
	if step.contains("opaque"): _make_opaque(false)
	elif step.contains("shared"): _make_opaque(true)
	var visible_objects := 0
	for node: Node in _canvas_nodes():
		if node is GeometryInstance3D and (node as GeometryInstance3D).is_visible_in_tree(): visible_objects += 1
	print(_LOG_PREFIX, "graph lab: %d visible object(s) at %.2f m." % [visible_objects, head.distance_to(_workspace.global_position)])


## What of the renderer and of the scene behind the graph [param step] turns off.
func _set_rendering(step: String) -> void:
	var empty := step.begins_with("empty")
	var lean := empty or step.contains("lean")
	_environment.background_mode = Environment.BG_COLOR if lean or step.contains("sky_off") else Environment.BG_SKY
	_environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR if lean or step.contains("tonemap_off") else Environment.TONE_MAPPER_FILMIC
	_sun.shadow_enabled = not (lean or step.contains("shadow_off"))
	_sun.visible = not empty
	for instance: GeometryInstance3D in _scenery: instance.visible = not (empty or step.contains("scene_off"))
	get_viewport().msaa_3d = Viewport.MSAA_DISABLED if step.contains("msaa_off") else Viewport.MSAA_4X
	if _xr == null: return
	_xr.foveation_level = 0 if step.contains("fov0") else 3
	_xr.set_gpu_level(OpenXRInterface.PERF_SETTINGS_LEVEL_BOOST if step.contains("gpu_boost") else OpenXRInterface.PERF_SETTINGS_LEVEL_SUSTAINED_HIGH)
	_xr.render_target_size_multiplier = SCALE if step.contains("scale") else 1.0


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


## Takes the canvas's meshes out of the transparent pass, with a material each as they
## have now or, if [param shared], one for all. What it looks like doesn't matter here.
func _make_opaque(shared: bool) -> void:
	var one := _opaque_material()
	for node: Node in _canvas_nodes():
		if node is GeometryInstance3D and not (node is Label3D):
			var instance := node as GeometryInstance3D
			_materials[instance] = instance.material_override
			instance.material_override = one if shared else _opaque_material()
	print(_LOG_PREFIX, "graph lab: %d object(s) made opaque." % _materials.size())


func _opaque_material() -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	result.albedo_color = Color(0.3, 0.3, 0.35)
	return result


func _put_materials_back() -> void:
	for instance: GeometryInstance3D in _materials:
		if is_instance_valid(instance): instance.material_override = _materials[instance]
	_materials.clear()


func _canvas_nodes() -> Array[Node]:
	var nodes: Array[Node] = []
	var stack: Array[Node] = [_canvas]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		stack.append_array(node.get_children())
		nodes.append(node)
	return nodes


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
		if node is WorldEnvironment: _environment = (node as WorldEnvironment).environment
		elif node is DirectionalLight3D: _sun = node as DirectionalLight3D
		elif node is GeometryInstance3D: _scenery.append(node as GeometryInstance3D)
	return scene


## The features of the headset's runs of D-152, as [XREBlueprints] gives them, but for what [param build] names.
func _set_features(build: String) -> void:
	var cheap := build.contains("cheap")
	_canvas.set_node_modes(&"on", false, false, &"both_faces", true)
	_canvas.set_rim_ports(true)
	_canvas.set_turn_modes(&"fixed", false)
	_canvas.set_arrow_modes(&"at_end" if cheap else &"running", &"at_end", true)
	_canvas.set_style(&"archetypes")
	_canvas.set_shrink(&"icons" if cheap else &"system")
	_canvas.set_heading(&"member")
	_canvas.set_port_shapes(build.contains("port_shapes"))
	_canvas.set_collection_modes(&"grid", &"make", false)
	_canvas.set_composite(&"split")
	_canvas.set_plus_shown(false)
	_canvas.set_bends_shown(true)
	_canvas.set_copy_shown(true)
	_canvas.set_port_display(&"sphere")
	_canvas.set_parameter_modes(&"window" if cheap or build.contains("values_window") else &"plugs", &"window" if cheap or build.contains("targets_window") else &"adapter", &"finished_port", &"boxes")
	_canvas.set_focus_modes(&"front", &"dim")
	_canvas.set_link_modes(&"variables", &"on_focus")
