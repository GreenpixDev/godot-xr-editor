@tool
extends EditorPlugin
## Entry point of the XR Editor plugin.

const _BENCHMARK_MENU := "XR Editor: Measure Frame Time"
const _HANDOFF_MENU := "XR Editor: Measure Play Handoff"
const _HANDOFF_RELEASE_MENU := "XR Editor: Measure Play Handoff (Release Session)"
## User argument (after [code]--[/code]) that runs [constant _TEST_INSPECTOR]
## in this editor: the inspector in the headset needs a running editor to be
## tested (scripts/check.sh). Not shipped with the plugin; without it the flag does nothing.
const _TEST_INSPECTOR_FLAG := "--xre-test-inspector"
const _TEST_INSPECTOR := "res://scripts/test_inspector.gd"

var document: XREDocument
var _session: XRESession
var _locomotion: XRELocomotion
var _icons: XREIcons
var _palette: XREPalette
var _panels: XREPanels
var _blueprints: XREBlueprints
var _manipulator: XREManipulator
var _play_mode: XREPlayMode
var _launcher: XREStandaloneLauncher
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
	var xr := _session.get_xr_interface()
	if xr != null:
		var runtime := XREFeatureSettings.layout_for_runtime(
				xr.get_system_info().get("XRRuntimeName", ""), XREStandalone.is_standalone())
		document.features.runtime_layout = runtime
		print("XR Editor: controls layout ", document.features.get_layout(), " (runtime layout ", runtime, ")")
	# Tools draw in the headset, so they live under the rig; no rig, no VR view.
	var rig := _session.get_rig()
	if rig != null:
		# First: the tools after it see where the rig is this frame, and what
		# follows a hand doesn't lag a frame behind while the user flies.
		_locomotion = XRELocomotion.new(rig, document)
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
		# After the palette, which claims the right hand on its tray, and before
		# the manipulator, which leaves alone a hand on a panel.
		_panels = XREPanels.new(document, rig, _palette, EditorInterface.get_editor_theme(),
				EditorInterface.get_editor_scale(), _session)
		_panels.name = "XREPanels"
		rig.add_child(_panels)
		_blueprints = XREBlueprints.new(document, rig, _icons, EditorInterface.get_editor_theme())
		_blueprints.name = "XREBlueprints"
		rig.add_child(_blueprints)
		_panels.set_blueprints(_blueprints)
		_manipulator = XREManipulator.new(document, rig, _icons)
		_manipulator.name = "XREManipulator"
		rig.add_child(_manipulator)
		_panels.set_manipulator(_manipulator)
		_palette.set_manipulator(_manipulator)
		_play_mode = XREPlayMode.new(document, _session, rig)
		_play_mode.name = "XREPlayMode"
		rig.add_child(_play_mode)
	elif XREStandalone.is_standalone():
		# The editor's 2D panel on a standalone headset: VR is another editor process (D-018).
		_launcher = XREStandaloneLauncher.new(self)
		_launcher.name = "XREStandaloneLauncher"
		add_child(_launcher)
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
	if _TEST_INSPECTOR_FLAG in OS.get_cmdline_user_args() and ResourceLoader.exists(_TEST_INSPECTOR):
		add_child((load(_TEST_INSPECTOR) as GDScript).new(document) as Node)
	if "--xre-test-blueprint-vr" in OS.get_cmdline_user_args() and ResourceLoader.exists("res://scripts/test_blueprint_vr.gd"):
		add_child((load("res://scripts/test_blueprint_vr.gd") as GDScript).new(document) as Node)


func _exit_tree() -> void:
	remove_tool_menu_item(_BENCHMARK_MENU)
	remove_tool_menu_item(_HANDOFF_MENU)
	remove_tool_menu_item(_HANDOFF_RELEASE_MENU)
	# All of them have already left the tree with this node: the palette threw
	# away what it held, the panels committed what their inspectors edited, the
	# manipulator put back what it held, the session restored the editor's
	# settings, the benchmarks stopped and put the editor back. The VR tools go
	# with the rig.
	_locomotion = null
	_icons = null
	_palette = null
	_panels = null
	_blueprints = null
	_manipulator = null
	_play_mode = null
	if _launcher != null:
		_launcher.queue_free()
		_launcher = null
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
	return XREPlayMode.game_args(args, document.features)


func _build() -> bool:
	return _blueprints == null or _blueprints.prepare_play()
