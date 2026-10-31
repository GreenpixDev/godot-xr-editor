@tool
class_name XREGraphLab
extends Node
## Finds what the open graph costs the headset's GPU and which settings buy it
## back. Once the headset is on and the scene is loaded it measures, [constant STEP_SEC]
## each and without being touched: the scene with the graph of [constant HOST] closed,
## then the graph open under each antialiasing and a smaller render target, then closed
## again. It opens and closes the graph itself and logs each step's name when it
## starts; read the steps' App GPU ms (VrApi) around those lines. The antialiasing
## and the render target are put back after the last step.
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
const STEPS: Array[String] = [
	"closed", "open_msaa_default", "open_msaa_2x", "open_msaa_off", "open_msaa_default", "open_scale_0.8", "open_msaa_off_scale_0.8", "closed",
]
## Scale of the render target in the scaled steps.
const SCALE := 0.8

const _LOG_PREFIX := "XR Editor: "

var _service: XREBlueprints
var _document: XREDocument
var _step := -1
var _left := WARMUP_SEC
var _antialiasing: StringName
var _scale := 1.0
var _started := false
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
		_antialiasing = _document.features.get_value(XREFeatureSettings.ANTIALIASING)
		var xr := _interface()
		if xr != null: _scale = xr.render_target_size_multiplier
	_step += 1
	if _step >= STEPS.size():
		_restore()
		print(_LOG_PREFIX, "graph lab: done.")
		queue_free()
		return
	print(_LOG_PREFIX, "graph lab: ", STEPS[_step])
	_apply(STEPS[_step])


func _exit_tree() -> void:
	if _started: _restore()


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
	if step == "closed":
		if _graph_open(): _service.close_graph()
	elif not _graph_open():
		_document.select([_host()], XREDocument.Source.TOOL)
		_service.open_selected()
	var scaled := step.contains("scale")
	var xr := _interface()
	if xr != null: xr.render_target_size_multiplier = _scale * SCALE if scaled else _scale
	var value := XREFeatureSettings.OFF if step.contains("msaa_off") else (XREFeatureSettings.MSAA_2X if step.contains("msaa_2x") else _antialiasing)
	_document.set_feature(XREFeatureSettings.ANTIALIASING, value, XREDocument.Source.TOOL)


func _restore() -> void:
	var xr := _interface()
	if xr != null: xr.render_target_size_multiplier = _scale
	_document.set_feature(XREFeatureSettings.ANTIALIASING, _antialiasing, XREDocument.Source.TOOL)
