@tool
extends EditorPlugin
## Entry point of the XR Editor plugin.

const _BENCHMARK_MENU := "XR Editor: Measure Frame Time"
const _HANDOFF_MENU := "XR Editor: Measure Play Handoff"
const _HANDOFF_RELEASE_MENU := "XR Editor: Measure Play Handoff (Release Session)"
const _SIMULATOR_MENU := "XR Editor: VR View Without Headset"
## User argument that opens the VR view without a headset at startup (D-057).
const _SIMULATOR_FLAG := "--xre-simulator"
## User argument that opens it, saves a picture of the view once the editor has
## settled to [constant _SIMULATOR_SHOT] and closes the editor.
const _SIMULATOR_SHOT_FLAG := "--xre-simulator-shot"
const _SIMULATOR_SHOT := "res://build/shots/simulator.png"
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
var _shortcut: XREObjectShortcut
var _counter: XRESelectionCounter
var _clipboard: XREClipboard
var _play_mode: XREPlayMode
var _undo: XREUndo
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
		if _session.get_rig() != null:
			_add_tools(_session.get_rig())
	else:
		# No headset: the VR view can still open in a window (D-057).
		add_tool_menu_item(_SIMULATOR_MENU, _toggle_simulator)
		var user_args := OS.get_cmdline_user_args()
		if _SIMULATOR_FLAG in user_args or _SIMULATOR_SHOT_FLAG in user_args:
			_start_simulator()
		if _SIMULATOR_SHOT_FLAG in user_args and _session.is_simulating():
			_shoot_simulator.call_deferred()
	_session.simulator_closed.connect(_stop_simulator)
	if xr == null and XREStandalone.is_standalone():
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
	if "--xre-shot-blueprint-vr" in OS.get_cmdline_user_args() and ResourceLoader.exists("res://scripts/shot_blueprint_vr.gd"):
		add_child((load("res://scripts/shot_blueprint_vr.gd") as GDScript).new(document) as Node)


## The VR tools, under [param rig]: they draw in the headset.
func _add_tools(rig: XRERig) -> void:
	# First: the tools after it see where the rig is this frame, and what
	# follows a hand doesn't lag a frame behind while the user flies.
	_locomotion = XRELocomotion.new(rig, document)
	_locomotion.name = "XRELocomotion"
	rig.add_child(_locomotion)
	_icons = XREIcons.new(document, rig)
	_icons.name = "XREIcons"
	rig.add_child(_icons)
	# First of the tools that take the right hand: the pills on the left hand
	# have buttons its ray picks (D-123, D-128). What they show comes from
	# the manipulator and the graph, made later.
	_counter = XRESelectionCounter.new(document, rig)
	_counter.name = "XRESelectionCounter"
	rig.add_child(_counter)
	_clipboard = XREClipboard.new(document, rig)
	_clipboard.name = "XREClipboard"
	rig.add_child(_clipboard)
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
	# After the manipulator: a hand it gives back has no trigger press left for it (D-088).
	_shortcut = XREObjectShortcut.new(document, rig, EditorInterface.get_editor_theme())
	_shortcut.name = "XREObjectShortcut"
	_shortcut.blocked = _blueprints.is_open
	_manipulator.graph_open = _blueprints.is_open
	_shortcut.blueprint_requested.connect(_blueprints.open_selected)
	_manipulator.shortcut_requested.connect(_shortcut.open)
	rig.add_child(_shortcut)
	_counter.set_sources(_manipulator, _blueprints)
	_clipboard.set_sources(_blueprints, _icons)
	_play_mode = XREPlayMode.new(document, _session, rig)
	_play_mode.name = "XREPlayMode"
	rig.add_child(_play_mode)
	_panels.playtest_requested.connect(_play_mode.request_play.bind(XREDocument.Source.PANEL))
	# Last: what the tools record in a frame is in the history before A or B reads it.
	_undo = XREUndo.new(document, rig)
	_undo.name = "XREUndo"
	rig.add_child(_undo)


func _exit_tree() -> void:
	remove_tool_menu_item(_BENCHMARK_MENU)
	remove_tool_menu_item(_HANDOFF_MENU)
	remove_tool_menu_item(_HANDOFF_RELEASE_MENU)
	if _session.get_xr_interface() == null:
		remove_tool_menu_item(_SIMULATOR_MENU)
	_session.simulator_closed.disconnect(_stop_simulator)
	# All of them have already left the tree with this node: the palette threw
	# away what it held, the panels committed what their inspectors edited, the
	# manipulator put back what it held, the session restored the editor's
	# settings, the benchmarks stopped and put the editor back. The VR tools go
	# with the rig.
	_forget_tools()
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


## The tools have left, or are leaving, the tree with the rig.
func _forget_tools() -> void:
	_locomotion = null
	_icons = null
	_palette = null
	_panels = null
	_blueprints = null
	_manipulator = null
	_shortcut = null
	_counter = null
	_clipboard = null
	_play_mode = null
	_undo = null
	# What the history would put back in the panels and the graph went with them.
	if document != null:
		document.history.forget(XREHistory.Kind.VIEW)
		document.history.forget(XREHistory.Kind.GRAPH)


## Opens the VR view without a headset, or closes it (D-057).
func _toggle_simulator() -> void:
	if _session.is_simulating():
		_stop_simulator()
	else:
		_start_simulator()


func _start_simulator() -> void:
	if not _session.start_simulator():
		return
	# Its keys show on the controls page; the user's own pick still wins.
	document.features.runtime_layout = XREFeatureSettings.NON_VR
	_add_tools(_session.get_rig())


func _stop_simulator() -> void:
	if not _session.is_simulating():
		return
	_session.stop_simulator()
	_forget_tools()
	document.features.runtime_layout = XREFeatureSettings.layout_for_runtime("", XREStandalone.is_standalone())


func _shoot_simulator() -> void:
	for frame: int in 240:
		await get_tree().process_frame
	_session.get_simulator().save_shot(_SIMULATOR_SHOT)
	get_tree().quit()


## While the VR view is on, every game run, from the headset or from the
## desktop, gets what it needs to take the headset and give it back.
func _run_scene(_scene: String, args: PackedStringArray) -> PackedStringArray:
	if _session != null and _session.is_simulating() and not args.has("--xr-mode"):
		# No headset: the game runs on the desktop instead of looking for one.
		var flat := args.duplicate()
		flat.append_array(["--xr-mode", "off"])
		return flat
	if _session == null or _session.get_xr_interface() == null:
		return args
	return XREPlayMode.game_args(args, document.features)


func _build() -> bool:
	return _blueprints == null or _blueprints.prepare_play()
