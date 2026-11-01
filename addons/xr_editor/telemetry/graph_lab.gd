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
## [code]benchmarks/quest_fps_report.py[/code]. Nothing it does reaches a saved graph.
## Start: [code]py scripts/quest.py --scene res://benchmarks/play_check.tscn -- --xre-graph-lab[/code].

## User argument (after [code]--[/code]) that runs the lab.
const CLI_FLAG := "--xre-graph-lab"
## With [constant CLI_FLAG] on a standalone headset: goes straight to [constant GAME_SCENE] in the game process, as Play does (D-018).
const GAME_FLAG := "--xre-graph-lab-game"
## The canvas alone, measured outside the editor.
const GAME_SCENE := "res://benchmarks/graph_runtime_lab.tscn"
## Seconds each step lasts.
const STEP_SEC := 20.0
## Seconds the headset must have been on before the first step.
const WARMUP_SEC := 15.0
## Seconds between lines of the graph's own script time.
const REPORT_SEC := 5.0
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
	"closed", "closed_tree_off", "closed", "open", "open_errors_off", "open", "open_log_off", "open", "open_viewports_off", "open", "open_editor_off",
	"open", "open_panels_off", "open", "open_manipulator_off", "open", "open_plugin_off",
	"open", "open_tree_off", "open", "open_physics_off", "open", "open_tree_off", "open", "closed",
]
## Scale of the render target in the scaled steps.
const SCALE := 0.7

const _LOG_PREFIX := "XR Editor: "

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


func _init(service: XREBlueprints, document: XREDocument) -> void:
	_service = service
	_document = document


## A copy of [param graph] with [param factor] copies of its blocks and wires, in a grid
## of two columns around its centre, for the steps on a larger graph. Never saved.
static func enlarged(graph: XREBlueprintGraph, factor: int) -> XREBlueprintGraph:
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
		var offset := Vector2(copy % 2, copy / 2) * step
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


func _process(delta: float) -> void:
	if not _ready_to_start(): return
	if OS.get_cmdline_user_args().has(GAME_FLAG):
		print(_LOG_PREFIX, "graph lab: leaving for the game process.")
		set_process(false)
		OS.create_instance(XREPlayMode.game_args(PackedStringArray(["--path", ProjectSettings.globalize_path("res://"), "--scene", GAME_SCENE])))
		return
	_measure()
	_report_left -= delta
	if _report_left <= 0.0 and _started:
		_report_left = REPORT_SEC
		var times := _service.take_process_times()
		var manipulator := (_service.get("_rig") as Node).find_child("XREManipulator", false, false) as XREManipulator
		# D-153: the panels' routing and the manipulator are outside the graph scripts, and the routing holds a frame's first facing while a hand is free.
		print(_LOG_PREFIX, "graph lab: graph scripts %.2f ms per frame, of them facing the head %.2f ms; ray routing %.2f ms; manipulator %.2f ms." % [times.x, times.y, times.z, manipulator.take_process_time() if manipulator != null else 0.0])
		_report_frames()
	_left -= delta
	if _left > 0.0: return
	_left = STEP_SEC
	if not _started:
		_started = true
		var xr := _interface()
		if xr != null: _scale = xr.render_target_size_multiplier
		if OS.get_cmdline_user_args().has(EDITOR_FLAG):
			_steps = EDITOR_STEPS
			_log_inventory()
	_step += 1
	if _step >= _steps.size():
		_restore()
		print(_LOG_PREFIX, "graph lab: done.")
		queue_free()
		return
	print(_LOG_PREFIX, "graph lab: ", _steps[_step])
	_apply(_steps[_step])


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
	_process_time += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	_frames += 1


## Logs the frames since the last report, for a runtime without VrApi's counters.
func _report_frames() -> void:
	var frames := maxi(_frames, 1)
	print(_LOG_PREFIX, "graph lab: frames %d fps, VR view render CPU %.2f ms, GPU %.2f ms, process %.2f ms, %d draw calls." % [
		roundi(Engine.get_frames_per_second()), _render_cpu / frames, _render_gpu / frames, _process_time / frames,
		roundi(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))])
	_render_cpu = 0.0
	_render_gpu = 0.0
	_process_time = 0.0
	_frames = 0


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
	if step.begins_with("closed"):
		if _graph_open(): _service.close_graph()
		_editor_off(step)
		return
	if not _graph_open():
		_document.select([_host()], XREDocument.Source.TOOL)
		_service.open_selected()
	if step.contains("big2"): _show(enlarged(_service.blueprint.graph, 2), true)
	elif step.contains("big4"): _show(enlarged(_service.blueprint.graph, 4), true)
	elif _enlarged: _show(_service.blueprint.graph, false)
	if step.contains("service_off"):
		_service.set_process(false)
		_stopped.append(_service)
	if step.contains("scale"):
		var xr := _interface()
		if xr != null: xr.render_target_size_multiplier = _scale * SCALE
	if step.contains("_off"): _hide_kind(step)
	if step.contains("text_cut"): _cut_text()
	_editor_off(step)


func _show(graph: XREBlueprintGraph, enlarged_graph: bool) -> void:
	_enlarged = enlarged_graph
	_service.canvas.center_graph(graph)
	_service.canvas.rebuild(graph)


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


func _restore() -> void:
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


## Applies what [param step] turns off of the editor and the plugin, and logs how much.
func _editor_off(step: String) -> void:
	if step.contains("errors_off") or step.contains("log_off"): Engine.print_error_messages = false
	if step.contains("log_off"): _take_out_log()
	if step.contains("physics_off"):
		PhysicsServer3D.set_active(false)
		PhysicsServer2D.set_active(false)
	if step.contains("panels_off"): _pause_tool("XREPanels")
	if step.contains("manipulator_off"): _pause_tool("XREManipulator")
	if step.contains("viewports_off"): _stop_viewports()
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


## The editor's own viewports stop updating: its 3D and 2D views and any others under its interface.
func _stop_viewports() -> void:
	for node: Node in EditorInterface.get_base_control().find_children("*", "SubViewport", true, false):
		var viewport := node as SubViewport
		if viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED: continue
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
