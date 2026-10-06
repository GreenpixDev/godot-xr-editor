@tool
extends EditorPlugin
## Entry point of the XR Editor plugin.

const _BENCHMARK_MENU := "XR Editor: Measure Frame Time"
const _HANDOFF_MENU := "XR Editor: Measure Play Handoff"
const _HANDOFF_RELEASE_MENU := "XR Editor: Measure Play Handoff (Release Session)"

var document: XREDocument
var _session: XRESession
var _locomotion: XRELocomotion
var _icons: XREIcons
var _palette: XREPalette
var _manipulator: XREManipulator
var _play_mode: XREPlayMode
var _benchmark: XREFrameBenchmark
var _handoff: XREHandoffBenchmark


func _enable_plugin() -> void:
	add_autoload_singleton(XREPlayMode.RETURN_AUTOLOAD, XREPlayMode.RETURN_SCRIPT)


func _disable_plugin() -> void:
	remove_autoload_singleton(XREPlayMode.RETURN_AUTOLOAD)


func _enter_tree() -> void:
	document = XREPluginDocument.new(self)
	_session = XRESession.new()
	_session.name = "XRESession"
	add_child(_session)
	# Tools draw in the headset, so they live under the rig; no rig, no VR view.
	var rig := _session.get_rig()
	if rig != null:
		# First: the tools after it see where the rig is this frame, and what
		# follows a hand doesn't lag a frame behind while the user flies.
		_locomotion = XRELocomotion.new(rig)
		_locomotion.name = "XRELocomotion"
		rig.add_child(_locomotion)
		_icons = XREIcons.new(document, rig)
		_icons.name = "XREIcons"
		rig.add_child(_icons)
		# Before the manipulator: tools run in tree order, and the palette
		# claims the right hand when it touches the tray.
		_palette = XREPalette.new(document, rig)
		_palette.name = "XREPalette"
		rig.add_child(_palette)
		_manipulator = XREManipulator.new(document, rig, _icons)
		_manipulator.name = "XREManipulator"
		rig.add_child(_manipulator)
		_play_mode = XREPlayMode.new(document, _session, rig)
		_play_mode.name = "XREPlayMode"
		rig.add_child(_play_mode)
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
	# All of them have already left the tree with this node: the palette threw
	# away what it held, the manipulator put back what it held, the session
	# restored the editor's settings, the benchmarks stopped and put the editor
	# back. The VR tools go with the rig.
	_locomotion = null
	_icons = null
	_palette = null
	_manipulator = null
	_play_mode = null
	_handoff.queue_free()
	_handoff = null
	_benchmark.queue_free()
	_benchmark = null
	_session.queue_free()
	_session = null
	(document as XREPluginDocument).dispose()
	document = null


## While the VR view is on, every game run, from the headset or from the
## desktop, gets what it needs to take the headset and give it back.
func _run_scene(_scene: String, args: PackedStringArray) -> PackedStringArray:
	if _session == null or _session.get_xr_interface() == null:
		return args
	return XREPlayMode.game_args(args)
