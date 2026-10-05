@tool
extends EditorPlugin
## Entry point of the XR Editor plugin.

const _BENCHMARK_MENU := "XR Editor: Measure Frame Time"
const _HANDOFF_MENU := "XR Editor: Measure Play Handoff"
const _HANDOFF_RELEASE_MENU := "XR Editor: Measure Play Handoff (Release Session)"

var document: XREDocument
var _session: XRESession
var _manipulator: XREManipulator
var _benchmark: XREFrameBenchmark
var _handoff: XREHandoffBenchmark


func _enter_tree() -> void:
	document = XREPluginDocument.new(self)
	_session = XRESession.new()
	_session.name = "XRESession"
	add_child(_session)
	# Tools draw in the headset, so they live under the rig; no rig, no VR view.
	var rig := _session.get_rig()
	if rig != null:
		_manipulator = XREManipulator.new(document, rig)
		_manipulator.name = "XREManipulator"
		rig.add_child(_manipulator)
	_benchmark = XREFrameBenchmark.new()
	_benchmark.name = "XREFrameBenchmark"
	_benchmark.session = _session
	add_child(_benchmark)
	_handoff = XREHandoffBenchmark.new()
	_handoff.name = "XREHandoffBenchmark"
	_handoff.session = _session
	add_child(_handoff)
	add_tool_menu_item(_BENCHMARK_MENU, _benchmark.run)
	add_tool_menu_item(_HANDOFF_MENU, _handoff.run)
	add_tool_menu_item(_HANDOFF_RELEASE_MENU, _handoff.run.bind(false, true))


func _exit_tree() -> void:
	remove_tool_menu_item(_BENCHMARK_MENU)
	remove_tool_menu_item(_HANDOFF_MENU)
	remove_tool_menu_item(_HANDOFF_RELEASE_MENU)
	# All of them have already left the tree with this node: the manipulator
	# put back what it held, the session restored the editor's settings, the
	# benchmarks stopped and put the editor back. The manipulator goes with the rig.
	_manipulator = null
	_handoff.queue_free()
	_handoff = null
	_benchmark.queue_free()
	_benchmark = null
	_session.queue_free()
	_session = null
	(document as XREPluginDocument).dispose()
	document = null
