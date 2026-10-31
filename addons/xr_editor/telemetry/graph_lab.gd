@tool
class_name XREGraphLab
extends Node
## Measures what the open graph costs the headset. Once the headset is on and the
## scene is loaded it runs, [constant STEP_SEC] each and without being touched: the
## graph of [constant HOST] closed, open, closed again. It opens and closes the graph
## itself, logs each step's name when it starts, and the graph's own script time
## every [constant REPORT_SEC]; read the steps' frame rate and App GPU ms (VrApi)
## around those lines with [code]benchmarks/quest_fps_report.py[/code].
## Start: [code]py scripts/quest.py --scene res://benchmarks/play_check.tscn -- --xre-graph-lab[/code].

## User argument (after [code]--[/code]) that runs the lab.
const CLI_FLAG := "--xre-graph-lab"
## Seconds each step lasts.
const STEP_SEC := 25.0
## Seconds the headset must have been on before the first step.
const WARMUP_SEC := 15.0
## Seconds between lines of the graph's own script time.
const REPORT_SEC := 5.0
## The scene node whose graph the steps open.
const HOST := "BlueCube"
## Steps in order.
const STEPS: Array[String] = ["closed", "open", "open_service_off", "open_service_off_canvas_off", "open_service_off_canvas_off_ui_off", "closed"]

const _LOG_PREFIX := "XR Editor: "

var _service: XREBlueprints
var _document: XREDocument
var _step := -1
var _left := WARMUP_SEC
var _started := false
var _stopped: Array[Node] = []
var _report_left := REPORT_SEC


func _init(service: XREBlueprints, document: XREDocument) -> void:
	_service = service
	_document = document


func _process(delta: float) -> void:
	if not _ready_to_start(): return
	_report_left -= delta
	if _report_left <= 0.0 and _started:
		_report_left = REPORT_SEC
		var times := _service.take_process_times()
		print(_LOG_PREFIX, "graph lab: graph scripts %.1f ms per frame, of them facing the head %.1f ms." % [times.x, times.y])
	_left -= delta
	if _left > 0.0: return
	_left = STEP_SEC
	if not _started:
		_started = true
	_step += 1
	if _step >= STEPS.size():
		print(_LOG_PREFIX, "graph lab: done.")
		queue_free()
		return
	print(_LOG_PREFIX, "graph lab: ", STEPS[_step])
	_apply(STEPS[_step])


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
	if step.contains("service_off"): _off(_service)
	if step.contains("canvas_off"): _off(_service.canvas)
	if step.contains("ui_off"):
		_off(_service.get("_floating_ui") as Node3D)
		_off(_service.get("_dimmer") as Node3D)
	if step == "closed":
		if _graph_open(): _service.close_graph()
	elif not _graph_open():
		_document.select([_host()], XREDocument.Source.TOOL)
		_service.open_selected()


## Stops [param node] for the current step: its script, or its drawing.
func _off(node: Node) -> void:
	if node == null: return
	if node is Node3D and node != _service:
		(node as Node3D).visible = false
		_stopped.append(node)
	else:
		node.set_process(false)
		_stopped.append(node)


func _restore() -> void:
	for node: Node in _stopped:
		if not is_instance_valid(node): continue
		if node is Node3D and node != _service: (node as Node3D).visible = true
		else: node.set_process(true)
	_stopped.clear()
