@tool
class_name XREPanels
extends Node3D
## Flat panels in the headset (docs/decisions.md, D-016, D-041, D-042):
## windows of the tabs — things to add to the scene ([XREObjectsTab], D-045),
## the edited scene's tree, the inspector, signals, the project's files,
## Blueprints, the feature settings ([XRESettingsTab], D-039) and debug tools
## ([XREDebugTab]) — that the user opens from a launcher
## ([XRETabLauncher]), places in the scene ([XREPanelWindow]) or pins to a
## forearm. Both look as Meta Horizon OS's Navigator and windows do.
##
## Controls:
## [br]- X on the left controller: show or hide the launcher in front of the
## user, an icon for each tab, over a dimmed scene. It fades in and out.
## [br]- A controller's ray on a panel is a mouse pointer: the trigger clicks,
## pulling it twice quickly double-clicks, and the right thumbstick, up and
## down, scrolls. Either hand points at the launcher and at windows, but not
## at a window pinned to its own forearm.
## [br]- A tile of the launcher: open that tab's window in front of the user
## and hide the launcher. A tab has one window at most; if it has one
## already, it pulses where it is, or comes to the user from out of view.
## [br]- Grip with the ray on a window or on its control bar, or trigger or
## grip on one of its corner handles (D-040): move it while the button is
## held. It keeps its distance from the hand and turns to face the head; the
## right thumbstick, up and down, pushes it away or pulls it closer.
## [br]- The control bar under a window shows while the ray is on the window.
## × on it: close the window. The pin on it: pin the window, compact, to the
## forearm of the hand that clicked, where the old forearm panel lay; a window
## pinned there before comes back in front of the user. The window glyph on a
## pinned window's bar, or grip on it with the other hand's ray: make it a
## window again, in front of the user or in the hand.
## [br][br]
## Windows are rig-locked (docs/vr_ui.md): flying and turning
## ([XRELocomotion]) take them along, the head doesn't, and they stay when
## another scene is opened. A pinned window is hand-locked and shows while its
## controller is tracked. What the tabs
## change goes through [XREDocument] as operations from a panel. A hand on a
## panel is claimed ([method XREHand.claim]), so that the trigger doesn't also
## select what is behind the panel; the right thumbstick is claimed too
## ([method XREHand.claim_stick]), so that scrolling doesn't turn the user.
## A panel takes the ray even when scene geometry is in front of it, except a
## node within reach that the manipulator takes ([method set_manipulator], D-047).
## [br][br]
## Lives under the [XRERig], with an identity transform, after the palette
## (it claims the right hand on its miniatures first) and before the manipulator.

## Where a window pinned to a hand lies on the forearm, in the controller's
## aim space, tilted as the forearm panel was before D-028.
const HAND_OFFSET := Transform3D(Basis(Vector3.RIGHT, -PI / 3.0), Vector3(0.0, 0.02, 0.17))
## Size of a compact panel on a forearm in interface pixels at editor scale 1,
## and the size of such a pixel in meters: 25 × 17 cm, as the forearm panel
## was.
const COMPACT_SIZE := Vector2(500.0, 340.0)
const COMPACT_PIXEL_SIZE := 0.0005
## The same for windows: 43 × 54 cm, made to be read from farther away.
const WINDOW_SIZE := Vector2(480.0, 600.0)
const WINDOW_PIXEL_SIZE := 0.0009
## Pixel size of the launcher: 47 × 24 cm with eight tiles, about 43° wide.
const LAUNCHER_PIXEL_SIZE := 0.00068
## How dark the scene gets behind the launcher, as Navigator dims it.
const LAUNCHER_DIM := 0.45
## How many times finer than its layout a panel is rendered at editor scale 1.
const RENDER_SCALE := 2.0
## How long the launcher and its dimming take to fade in, and out, in seconds (D-043, D-045).
const LAUNCHER_FADE_TIME := 0.22
## Radius of a concave window's curve, in meters (D-043): about as far as
## windows open. The launcher is always concave, with its own distance for one.
const CONCAVE_RADIUS := 0.8
## How far from the gaze a window open already may be and stay where it is
## when it is opened again, in radians (D-045).
const VIEW_HALF_ANGLE := 0.6
## How far rays reach panels, in meters.
const POINT_DISTANCE := 5.0
## Where a window opened from the launcher appears: this far ahead of the head
## and this far below it, in meters.
const WINDOW_DISTANCE := 0.7
const WINDOW_DROP := 0.15
## Space kept between windows that open side by side, in meters.
const WINDOW_GAP := 0.04
## The same for the launcher: nearer and lower, under the gaze.
const LAUNCHER_DISTANCE := 0.6
const LAUNCHER_DROP := 0.2
## How near and how far a held window may be pushed, in meters from the hand.
const MIN_WINDOW_DISTANCE := 0.15
const MAX_WINDOW_DISTANCE := 4.0
## Thumbstick all the way: wheel notches scrolled per second, and the factor
## a held window's distance changes by per second.
const SCROLL_SPEED := 12.0
const PUSH_SPEED := 2.0
## Stick tilt that counts as none.
const DEAD_ZONE := 0.15


## What the panels keep for each controller.
class Pointer:
	var hand: XREHand
	## The right hand: it takes a panel's mouse over from the left hand, and its
	## thumbstick scrolls and pushes windows.
	var right := false
	## The panel the ray is on, or null.
	var surface: XREPanelSurface
	## This pointer moves [member surface]'s mouse ([method XREPanels._may_drive]).
	var drives := false
	## The window the hand holds, or null.
	var window: XREPanelWindow
	## The window's position in the hand's space, fixed when it was taken.
	var hold: Vector3
	## The corner handle the window was taken by, or -1 for its interface.
	var corner := -1
	## The trigger holds the window, not the grip.
	var by_trigger := false

	func _init(controller: XREHand, is_right: bool) -> void:
		hand = controller
		right = is_right


var _document: XREDocument
var _rig: XRERig
var _palette: XREPalette
var _theme: Theme
## The editor's display scale: panels are laid out larger and their pixels made smaller by it.
var _scale := 1.0
var _session: XRESession
var _launcher: XRETabLauncher
## Darkens the scene behind the launcher; it follows the head.
var _dimmer: MeshInstance3D
var _windows: Array[XREPanelWindow] = []
var _pointers: Array[Pointer] = []
var _blueprints: XREBlueprints
var _manipulator: XREManipulator
var _menus_shown := false
## How far the launcher has faded in, 0 to 1.
var _fade := 0.0
## The hand whose trigger the panels are handing to a panel right now, or null.
var _clicking: XREHand
## How far the ray went to the surface [method on_top_surface] last found.
var on_top_distance := POINT_DISTANCE


## [param theme] and [param editor_scale] are the editor's; without them
## (null, 1) the panels use Godot's default theme.
func _init(document: XREDocument, rig: XRERig, palette: XREPalette, theme: Theme, editor_scale: float, session: XRESession = null) -> void:
	_document = document
	_rig = rig
	_palette = palette
	_theme = theme
	_scale = editor_scale
	_session = session
	var types := tab_types()
	# Tabs give the tiles their titles and icons; the windows make their own.
	var tabs: Array[XREPanelTab] = []
	for type: GDScript in types:
		tabs.append(type.new(_document) as XREPanelTab)
	_launcher = XRETabLauncher.new(types, tabs, XRETabLauncher.size_for(types.size()) * _scale,
			LAUNCHER_PIXEL_SIZE / _scale, _render_scale(), theme)
	for tab: XREPanelTab in tabs:
		tab.free()
	_launcher.name = "Launcher"
	# Concave whatever the windows are: bent around the user, as it opens this far away.
	_launcher.set_curve_radius(LAUNCHER_DISTANCE)
	_launcher.set_shown(false)
	# Over the dimmer, as Navigator is over the dimmed scene. With the depth test: the ray in front
	# of it stays visible (D-044).
	_launcher.set_overlay(true)
	# Deferred: the click on the tile is still being handled.
	_launcher.tab_chosen.connect(_on_tab_chosen, CONNECT_DEFERRED)
	add_child(_launcher)
	_dimmer = XREBlueprints.create_dimmer(LAUNCHER_DIM)
	_dimmer.name = "LauncherDimmer"
	_dimmer.visible = false
	rig.camera.add_child(_dimmer)
	_pointers.append(Pointer.new(rig.right_hand, true))
	_pointers.append(Pointer.new(rig.left_hand, false))


func _enter_tree() -> void:
	_document.features.changed.connect(_on_feature_changed)


func _exit_tree() -> void:
	_document.features.changed.disconnect(_on_feature_changed)
	_disconnect_blueprints()
	if is_instance_valid(_dimmer): _dimmer.queue_free()
	# The panels have left the tree before this node: only the hands are let go.
	for pointer: Pointer in _pointers:
		pointer.surface = null
		pointer.drives = false
		pointer.window = null
		pointer.hand.unclaim(self)
		pointer.hand.unclaim_stick(self)


func _process(delta: float) -> void:
	if _rig.is_action_pressed(_document.features, XREFeatureSettings.LAUNCHER):
		show_launcher(not _menus_shown)
	_update_fade(delta)
	for window: XREPanelWindow in _windows:
		var hand := _pin_hand(window)
		if hand != null:
			window.set_shown(hand.get_has_tracking_data())
			if window.is_shown():
				window.global_transform = hand.global_transform * HAND_OFFSET
	for pointer: Pointer in _pointers:
		_update_pointer(pointer, delta)
	_poll_button_capture()


## Gives a tab waiting for a controller button ([method XREPanelTab.wants_button])
## the first one pressed, and keeps the buttons from the tools meanwhile (D-050).
## After the pointers: a click that starts the wait blocks the tools from the next frame.
func _poll_button_capture() -> void:
	var waiting: XREPanelTab = null
	for window: XREPanelWindow in _windows:
		if window.tab.wants_button():
			waiting = window.tab
			break
	_rig.set_capturing(waiting != null)
	if waiting == null:
		return
	for button: StringName in XREFeatureSettings.BUTTONS:
		if _rig.get_button_hand(button).was_input_pressed(XREFeatureSettings.button_input(button)):
			waiting.take_button(button)
			_rig.set_capturing(false)
			return


func get_launcher() -> XRETabLauncher:
	return _launcher


## Shows the launcher in front of the user, over a dimmed scene, or hides it
## (D-041, D-042): the launcher action toggles it (left Menu, X on SteamVR, D-050). It fades in and out (D-043, D-045); it takes
## the ray only while shown, not while it fades out.
func show_launcher(shown: bool) -> void:
	if shown == _menus_shown:
		return
	_menus_shown = shown
	if shown:
		# Where the user looks now, unless it is still fading out where it was.
		if not _launcher.is_shown():
			_place_in_front(_launcher, LAUNCHER_DISTANCE, LAUNCHER_DROP)
		_launcher.set_shown(true)
		_dimmer.visible = true
		_launcher.update_clock()


## Whether the launcher is shown, or fading in; not while it fades out.
func is_launcher_shown() -> bool:
	return _menus_shown


## Lets [param manipulator], after the panels in the tree, have a hand whose
## ray is on a panel when it grabs a node there ([method XREManipulator.takes_pointer]).
func set_manipulator(manipulator: XREManipulator) -> void:
	_manipulator = manipulator


## Fades the launcher and its dimming towards shown or hidden; hides them once faded out.
func _update_fade(delta: float) -> void:
	if not _launcher.is_shown():
		return
	if _menus_shown:
		_launcher.update_clock()
	var target := 1.0 if _menus_shown else 0.0
	if _fade != target:
		_fade = move_toward(_fade, target, delta / LAUNCHER_FADE_TIME)
		var eased := ease(_fade, -2.0)
		_launcher.set_opacity(eased)
		(_dimmer.material_override as ShaderMaterial).set_shader_parameter(&"alpha", LAUNCHER_DIM * eased)
	if not _menus_shown and _fade <= 0.0:
		_launcher.set_shown(false)
		_dimmer.visible = false


## Connects the optional graph tab to the spatial editing service.
## The graph's parameters and block palette ([XREBlueprintFormTab], D-044)
## are windows of the panels, opened and closed when the service asks.
func set_blueprints(service: XREBlueprints) -> void:
	_disconnect_blueprints()
	_blueprints = service
	if service != null:
		service.panels = self
		service.changed.connect(_update_overlay)
		service.window_requested.connect(_on_graph_window_requested)
		service.window_dismissed.connect(_on_graph_window_dismissed)
		service.window_pulse_requested.connect(_on_graph_window_pulse)
	for window: XREPanelWindow in _windows:
		if window.tab is XREBlueprintTab: (window.tab as XREBlueprintTab).setup(service)
	_update_overlay()


func _disconnect_blueprints() -> void:
	if not is_instance_valid(_blueprints): return
	if _blueprints.panels == self: _blueprints.panels = null
	if _blueprints.changed.is_connected(_update_overlay): _blueprints.changed.disconnect(_update_overlay)
	if _blueprints.window_requested.is_connected(_on_graph_window_requested): _blueprints.window_requested.disconnect(_on_graph_window_requested)
	if _blueprints.window_dismissed.is_connected(_on_graph_window_dismissed): _blueprints.window_dismissed.disconnect(_on_graph_window_dismissed)
	if _blueprints.window_pulse_requested.is_connected(_on_graph_window_pulse): _blueprints.window_pulse_requested.disconnect(_on_graph_window_pulse)


## The graph asks for its window of tab class [param type] at [param pose],
## beside a block: it opens or comes there, unless it is pinned to a hand.
func _on_graph_window_requested(type: GDScript, pose: Transform3D) -> void:
	var window := _window_for(type)
	if not window.is_pinned():
		_release(window)
		window.global_transform = pose
	window.pulse()


## The graph asks its open window of tab class [param type] to pulse where it is.
func _on_graph_window_pulse(type: GDScript) -> void:
	var window := find_window(type)
	if window != null: window.pulse()


## The graph asks for its window of tab class [param type] to close: [param always], or unless it is pinned.
func _on_graph_window_dismissed(type: GDScript, always: bool) -> void:
	var window := find_window(type)
	if window == null:
		if is_instance_valid(_blueprints): _blueprints.window_closed(type)
	elif always or not window.is_pinned():
		_close_window(window)


func _update_overlay() -> void:
	var enabled := _blueprints != null and _blueprints.is_open()
	for window: XREPanelWindow in _windows: window.set_overlay(enabled)


## The hand whose click a window's control is handling now, or null between clicks.
func get_clicking_hand() -> XREHand:
	return _clicking


## The open windows, in the order they were opened, pinned ones too.
func get_windows() -> Array[XREPanelWindow]:
	return _windows


## The window of the tab of class [param type], or null.
func find_window(type: Script) -> XREPanelWindow:
	for window: XREPanelWindow in _windows:
		if window.tab.get_script() == type:
			return window
	return null


## The window held by [param hand], or null.
func get_held_window(hand: XREHand) -> XREPanelWindow:
	for pointer: Pointer in _pointers:
		if pointer.hand == hand:
			return pointer.window
	return null


## Whether the panels let a tool before them take [param hand] although they
## claimed it: they do while the hand only points at a panel, and not while it
## carries a window or holds a panel's button down. The palette takes it so
## for a miniature in front of the Objects window (D-046).
func yields_hand(hand: XREHand) -> bool:
	for pointer: Pointer in _pointers:
		if pointer.hand == hand:
			return pointer.window == null and not (pointer.drives and pointer.surface != null and pointer.surface.is_pressed())
	return true


## The window pinned to [param hand]'s forearm, or null.
func get_pinned_window(hand: XREHand) -> XREPanelWindow:
	for window: XREPanelWindow in _windows:
		if _pin_hand(window) == hand:
			return window
	return null


## Opens the window of the tab of class [param type] in front of the user.
## Windows in front of the user make room for it ([method _place_and_make_room]).
## A window open already stays where it is — in view, or on a hand — and
## pulses, so that the user sees where it is (D-045); one out of view comes
## in front of the user. Every window opened pulses.
func open_window(type: Script) -> XREPanelWindow:
	var open := find_window(type) != null
	var window := _window_for(type)
	if not open or (not window.is_pinned() and not _in_view(window)):
		_place_and_make_room(window)
	window.pulse()
	return window


## Whether the user sees [param window]: it is within
## [constant VIEW_HALF_ANGLE] of the gaze.
func _in_view(window: XREPanelWindow) -> bool:
	var head := _rig.camera.global_transform
	var to_window := window.global_position - head.origin
	return not to_window.is_zero_approx() and to_window.normalized().dot(-head.basis.z.normalized()) > cos(VIEW_HALF_ANGLE)


## Puts [param window] at [param where], an [enum XREPanelWindow.Pin]: pinned,
## compact, to a forearm, where a window pinned before makes way and comes in
## front of the user; or back in front of the user as a window.
func pin_window(window: XREPanelWindow, where: int) -> void:
	if where == window.pin or not _windows.has(window):
		return
	if where != XREPanelWindow.Pin.WINDOW:
		for other: XREPanelWindow in _windows:
			if other != window and other.pin == where:
				_set_pin(other, XREPanelWindow.Pin.WINDOW)
				_place_and_make_room(other)
				other.pulse()
	_set_pin(window, where)
	if where == XREPanelWindow.Pin.WINDOW:
		_place_and_make_room(window)
	else:
		window.global_transform = _pin_hand(window).global_transform * HAND_OFFSET


## The tabs' classes, in the launcher's order.
static func tab_types() -> Array[GDScript]:
	return [XREObjectsTab, XRESceneTab, XREInspectorTab, XRESignalsTab, XREFileSystemTab, XREBlueprintTab, XRESettingsTab, XREDebugTab]


## The basis of a window at [param position] that faces [param head], upright
## along [param up]: its front (+Z) toward the head.
static func facing(position: Vector3, head: Vector3, up: Vector3) -> Basis:
	var away := position - head
	up = up.normalized()
	away -= up * away.dot(up)
	if away.is_zero_approx():
		away = Vector3.FORWARD
	if away.normalized().cross(up.normalized()).length() < 0.01:
		# Straight above or below the head: any upright will do.
		return Basis.looking_at(away, up.cross(Vector3.RIGHT) if absf(up.x) < 0.9 else up.cross(Vector3.FORWARD))
	return Basis.looking_at(away, up)


func _render_scale() -> float:
	return maxf(RENDER_SCALE / _scale, 1.0)


## Puts [param surface] [param distance] meters ahead of the head, level, and
## [param drop] meters below it, facing the head.
func _place_in_front(surface: XREPanelSurface, distance: float, drop: float) -> void:
	var head := _rig.camera.global_transform
	var up := _rig.global_basis.y.normalized()
	var forward := -head.basis.z
	forward -= up * forward.dot(up)
	if forward.length() < 0.01:
		forward = -_rig.global_basis.z
	var position := head.origin + forward.normalized() * distance - up * drop
	surface.global_transform = Transform3D(facing(position, head.origin, up), position)


## Puts [param window] in front of the user ([method _place_in_front]) and
## moves aside the windows it would cover (D-044), so that a window always
## opens where the user looks. A covered window turns around the head, at its
## distance and height, until it is just beside the windows nearer the new
## one: towards the side it is already on, or, if it is straight behind the
## new window, towards the side with more free room. A window moved so moves
## on the ones it then covers. Windows pinned to a hand don't count.
func _place_and_make_room(window: XREPanelWindow) -> void:
	_place_in_front(window, WINDOW_DISTANCE, WINDOW_DROP)
	var head := _rig.camera.global_position
	var up := _rig.global_basis.y.normalized()
	var center := _view_angles(window, head, up)
	var others: Array[XREPanelWindow] = []
	for other: XREPanelWindow in _windows:
		if other != window and not other.is_pinned() and other.is_shown():
			others.append(other)
	# Nearest the new window first: they make room for it, the farther ones for them.
	others.sort_custom(func(first: XREPanelWindow, second: XREPanelWindow) -> bool:
		return absf(angle_difference(center.x, _view_angles(first, head, up).x)) < absf(angle_difference(center.x, _view_angles(second, head, up).x)))
	var free_side := _freer_side(center, others, head, up)
	var placed: Array[XREPanelWindow] = [window]
	for other: XREPanelWindow in others:
		var there := _view_angles(other, head, up)
		var offset := angle_difference(center.x, there.x)
		var side := signf(offset) if absf(offset) > there.z * 0.5 else free_side
		for attempt: int in placed.size():
			var blocker := _first_covered(other, placed, head, up)
			if blocker == null:
				break
			var block := _view_angles(blocker, head, up)
			_turn_to(other, block.x + side * (block.z + _view_angles(other, head, up).z + 0.001), head, up)
		placed.append(other)


## The side, +1 left or -1 right, around the head where [param others] take
## less room beside a window seen at [param center] ([method _view_angles]):
## right if they take as much on both.
func _freer_side(center: Vector4, others: Array[XREPanelWindow], head: Vector3, up: Vector3) -> float:
	var left := 0.0
	var right := 0.0
	for other: XREPanelWindow in others:
		var there := _view_angles(other, head, up)
		var offset := angle_difference(center.x, there.x)
		if offset > 0.0: left += there.z
		elif offset < 0.0: right += there.z
	return 1.0 if left < right else -1.0


## The first of [param windows] that [param window] covers, or null.
func _first_covered(window: XREPanelWindow, windows: Array[XREPanelWindow], head: Vector3, up: Vector3) -> XREPanelWindow:
	var place := _view_angles(window, head, up)
	for other: XREPanelWindow in windows:
		if other != window and _cover(place, _view_angles(other, head, up)):
			return other
	return null


## Turns [param window] around the head so that it is seen at angle [param yaw]
## ([method _view_angles]), at the same distance and height, facing the head.
func _turn_to(window: XREPanelWindow, yaw: float, head: Vector3, up: Vector3) -> void:
	var turn := angle_difference(_view_angles(window, head, up).x, yaw)
	var position := head + Basis(up, turn) * (window.global_position - head)
	window.global_transform = Transform3D(facing(position, head, up), position)


## Whether windows seen as [param first] and [param second] ([method _view_angles]) cover each other.
static func _cover(first: Vector4, second: Vector4) -> bool:
	return absf(angle_difference(first.x, second.x)) < first.z + second.z and absf(first.y - second.y) < first.w + second.w


## Whether [param window] covers another window as the user sees them, not
## counting windows pinned to a hand: their angles around the head, across
## and up, overlap.
func overlaps_window(window: XREPanelWindow) -> bool:
	var head := _rig.camera.global_position
	var up := _rig.global_basis.y.normalized()
	var place := _view_angles(window, head, up)
	for other: XREPanelWindow in _windows:
		if other == window or other.is_pinned() or not other.is_shown():
			continue
		if _cover(place, _view_angles(other, head, up)):
			return true
	return false


## Where [param window] is seen from [param head]: its direction's angle
## around [param up] and its elevation, and its half width and half height,
## all in radians, with the gap between windows.
func _view_angles(window: XREPanelWindow, head: Vector3, up: Vector3) -> Vector4:
	var offset := window.global_position - head
	var rise := offset.dot(up)
	var level := offset - up * rise
	var distance := maxf(offset.length(), 0.01)
	var reference := _rig.global_basis.z
	var yaw := (-reference).signed_angle_to(level, up) if not level.is_zero_approx() else 0.0
	return Vector4(yaw, atan2(rise, level.length()),
			atan((window.size_m.x + WINDOW_GAP) * 0.5 / distance), atan((window.size_m.y + WINDOW_GAP) * 0.5 / distance))


## The window of the tab of class [param type], opened where it last was, or
## made, unplaced, if there is none.
func _window_for(type: Script) -> XREPanelWindow:
	var window := find_window(type)
	if window != null:
		return window
	var tab := (type as GDScript).new(_document) as XREPanelTab
	if tab is XREBlueprintTab: (tab as XREBlueprintTab).setup(_blueprints)
	if tab is XREBlueprintFormTab: (tab as XREBlueprintFormTab).setup(_blueprints)
	if tab is XREDebugTab: (tab as XREDebugTab).setup(_session)
	window = XREPanelWindow.new(tab, tab.get_window_size() * _scale, WINDOW_PIXEL_SIZE / _scale, _render_scale(), _theme)
	window.name = "%sWindow" % window.tab.name
	# Deferred: the click on the button is still being handled.
	window.close_requested.connect(_close_window.bind(window), CONNECT_DEFERRED)
	# Not deferred: the hand that clicked is known only while the click is handled.
	window.pin_requested.connect(_on_pin_requested.bind(window))
	window.unpin_requested.connect(pin_window.bind(window, XREPanelWindow.Pin.WINDOW), CONNECT_DEFERRED)
	# The graph's windows stand by its cards, in the world: flying or turning by
	# the sticks leaves them there (D-066), as the cards; the tabs' go with the user.
	if tab is XREBlueprintFormTab: window.top_level = true
	add_child(window)
	_windows.append(window)
	window.set_overlay(_blueprints != null and _blueprints.is_open())
	if tab.is_drawn_on_top():
		# Over the graph's Front focus too: a card in focus, as the one a wire is drawn from, must not cover it.
		window.set_top_sorting(XREPanelSurface.OVER_FOCUS_SORTING)
		window.set_on_top(true)
	window.set_curve_radius(_window_curve(window))
	if tab is XREObjectsTab: _palette.set_host(window, tab as XREObjectsTab)
	return window


## Radius of [param window]'s curve as the setting
## [constant XREFeatureSettings.WINDOW_SHAPE] says, 0 for flat: a window
## pinned to a hand is a panel on the forearm, and always flat.
func _window_curve(window: XREPanelWindow) -> float:
	if window.is_pinned() or _document.features.get_value(XREFeatureSettings.WINDOW_SHAPE) != XREFeatureSettings.CONCAVE:
		return 0.0
	return CONCAVE_RADIUS


func _on_feature_changed(key: StringName) -> void:
	if key != XREFeatureSettings.WINDOW_SHAPE:
		return
	for window: XREPanelWindow in _windows:
		window.set_curve_radius(_window_curve(window))


func _close_window(window: XREPanelWindow) -> void:
	if not _windows.has(window): return
	_release(window)
	_windows.erase(window)
	window.queue_free()
	if window.tab is XREBlueprintFormTab and is_instance_valid(_blueprints): _blueprints.window_closed(window.tab.get_script() as GDScript)
	if window.tab is XREObjectsTab: _palette.set_host(null, null)


## Takes the pointers off [param window] and its bar, and out of the hand that holds it.
func _release(window: XREPanelWindow) -> void:
	for pointer: Pointer in _pointers:
		if pointer.surface == window or pointer.surface == window.get_bar():
			pointer.surface.pointer_exit()
			pointer.surface = null
			pointer.drives = false
		if pointer.window == window:
			pointer.window = null


## Lays [param window] out for [param where], an [enum XREPanelWindow.Pin]:
## compact on a forearm, full as a window. Where it goes is the caller's.
func _set_pin(window: XREPanelWindow, where: int) -> void:
	_release(window)
	if where == XREPanelWindow.Pin.WINDOW:
		window.set_pin(where, window.tab.get_window_size() * _scale, WINDOW_PIXEL_SIZE / _scale)
		window.set_shown(true)
	else:
		window.set_pin(where, COMPACT_SIZE * _scale, COMPACT_PIXEL_SIZE / _scale)
	window.set_curve_radius(_window_curve(window))


## The hand [param window] is pinned to, or null.
## The nearest window drawn over everything (D-086) or its control bar that
## [param hand]'s ray from [param origin] along [param direction] meets, or
## null; [member on_top_distance] is then how far.
func on_top_surface(hand: XREHand, origin: Vector3, direction: Vector3) -> XREPanelSurface:
	var surface: XREPanelSurface = null
	on_top_distance = POINT_DISTANCE
	for window: XREPanelWindow in _windows:
		# A hand doesn't point at what is pinned to its own forearm.
		if not window.is_on_top() or _pin_hand(window) == hand:
			continue
		var hit := window.intersect_ray(origin, direction, on_top_distance)
		if hit >= 0.0:
			surface = window
			on_top_distance = hit
		hit = window.get_bar().intersect_ray(origin, direction, on_top_distance)
		if hit >= 0.0:
			surface = window.get_bar()
			on_top_distance = hit
	return surface


func _pin_hand(window: XREPanelWindow) -> XREHand:
	match window.pin:
		XREPanelWindow.Pin.LEFT_HAND: return _rig.left_hand
		XREPanelWindow.Pin.RIGHT_HAND: return _rig.right_hand
	return null


## The window [param surface] is, or whose bar it is; null for another panel.
func _window_of(surface: XREPanelSurface) -> XREPanelWindow:
	var window := surface as XREPanelWindow
	if window != null:
		return window
	for other: XREPanelWindow in _windows:
		if other.get_bar() == surface:
			return other
	return null


## The pin of [param window]'s control bar was clicked: the window goes to
## the hand that clicked, after the click.
func _on_pin_requested(window: XREPanelWindow) -> void:
	if _clicking == null:
		return
	var where := XREPanelWindow.Pin.RIGHT_HAND if _clicking == _rig.right_hand else XREPanelWindow.Pin.LEFT_HAND
	pin_window.call_deferred(window, where)


func _on_tab_chosen(type: GDScript) -> void:
	open_window(type)
	# As an app launcher closes when an app starts; X brings it back.
	show_launcher(false)


func _update_pointer(pointer: Pointer, delta: float) -> void:
	var hand := pointer.hand
	if pointer.window != null:
		if (hand.trigger_held if pointer.by_trigger else hand.grip_held) and hand.get_has_tracking_data():
			_carry(pointer, delta)
			return
		pointer.window = null
	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	# The launcher is over everything (D-043): the ray on it is the launcher's even when the
	# graph has the hand, say for a wire being drawn, unless the graph holds something with it.
	var on_launcher := _launcher.intersect_ray(origin, direction, POINT_DISTANCE) if _menus_shown else -1.0
	var graph_lets_go := _blueprints != null and hand.is_free_for(_blueprints) and not _blueprints.is_holding(hand)
	# A wire being drawn in the graph gives way to windows (D-058): the ray on a window is
	# the window's, and a click there lets the wire go, as a click on its own port does.
	var graph_wire := graph_lets_go and _blueprints.has_wire(hand)
	if not hand.get_has_tracking_data() or not (hand.is_free_for(self) or (on_launcher >= 0.0 and graph_lets_go) or graph_wire):
		_leave(pointer)
		return

	var surface: XREPanelSurface = null
	var handle: XREPanelWindow = null
	var distance := POINT_DISTANCE
	if pointer.drives and pointer.surface.is_pressed():
		# A held button keeps the pointer on its panel, as a mouse drag keeps its control.
		surface = pointer.surface
		distance = surface.intersect_ray(origin, direction, INF, false)
	elif on_launcher >= 0.0:
		surface = _launcher
		distance = on_launcher
	else:
		var hit := -1.0
		# A window drawn over everything (D-086) takes the ray before the nearer cards and
		# windows it is drawn over; only what is drawn over everything too may still take it.
		surface = on_top_surface(hand, origin, direction)
		if surface != null:
			distance = on_top_distance
			if _blueprints != null and _blueprints.takes_pointer(hand, origin, direction, distance, true):
				_leave(pointer)
				return
		else:
			for window: XREPanelWindow in _windows:
				# A hand doesn't point at what is pinned to its own forearm.
				if _pin_hand(window) == hand:
					continue
				hit = window.intersect_ray(origin, direction, distance)
				if hit >= 0.0:
					surface = window
					distance = hit
				hit = window.get_bar().intersect_ray(origin, direction, distance)
				if hit >= 0.0:
					surface = window.get_bar()
					distance = hit
			# A handle lies outside its window's frame: only one nearer than any panel is taken.
			for window: XREPanelWindow in _windows:
				hit = window.intersect_handle(origin, direction, distance)
				if hit >= 0.0:
					handle = window
					distance = hit
			if graph_wire and surface == null and handle == null:
				_leave(pointer)
				return
			if _blueprints != null and _blueprints.takes_pointer(hand, origin, direction, distance):
				_leave(pointer)
				return
			# A node touched, or pointed at in front of the panel within reach, or a hold joined (D-047).
			if (surface != null or handle != null) and _manipulator != null \
					and _manipulator.takes_pointer(hand, origin, direction, distance):
				_leave(pointer)
				return
	if handle != null:
		_point_at_handle(pointer, handle, origin + direction * distance, distance)
		return
	if surface == null:
		_leave(pointer)
		return
	if surface != pointer.surface:
		_leave(pointer)
		pointer.surface = surface
	if not pointer.drives:
		pointer.drives = _may_drive(pointer, surface)
	hand.claim(self)
	if pointer.right:
		hand.claim_stick(self)
	if distance >= 0.0:
		hand.show_ray(distance, true)
	var window := _window_of(surface)
	if window != null:
		window.hover_handles(-1)
	if not pointer.drives:
		return
	if distance >= 0.0:
		surface.pointer_move(surface.get_hit_pixel())
	_clicking = hand
	if hand.trigger_pressed:
		surface.pointer_button(true)
	elif hand.trigger_released:
		surface.pointer_button(false)
	_clicking = null
	if hand.grip_pressed and window != null and not surface.is_pressed() and distance >= 0.0:
		_take(pointer, window, origin + direction * distance)
	elif pointer.right:
		var tilt := _tilt(hand.get_vector2(&"primary").y)
		if tilt != 0.0:
			surface.pointer_scroll(tilt * SCROLL_SPEED * delta)


## Takes the pointer off its panel and lets go of the hand.
func _leave(pointer: Pointer) -> void:
	if pointer.surface != null:
		if pointer.drives:
			pointer.surface.pointer_exit()
		pointer.surface = null
		pointer.drives = false
	if pointer.window == null:
		pointer.hand.unclaim(self)
		pointer.hand.unclaim_stick(self)


## Whether [param pointer] may move [param surface]'s mouse. A panel has one
## mouse: if the other hand moves it, the right hand takes it over unless the
## button is down, so that a left ray resting on a window doesn't lock the
## right hand out; the left hand waits for its turn.
func _may_drive(pointer: Pointer, surface: XREPanelSurface) -> bool:
	for other: Pointer in _pointers:
		if other == pointer or other.surface != surface or not other.drives:
			continue
		if surface.is_pressed() or not pointer.right:
			return false
		other.drives = false
	return true


## The ray on [param window]'s corner handle, [param distance] away at
## [param point]: it lights up, and the trigger or the grip takes the window.
func _point_at_handle(pointer: Pointer, window: XREPanelWindow, point: Vector3, distance: float) -> void:
	_leave(pointer)
	var hand := pointer.hand
	hand.claim(self)
	if pointer.right:
		hand.claim_stick(self)
	hand.show_ray(distance, true)
	var corner := window.get_hit_corner()
	window.hover_handles(corner)
	if hand.trigger_pressed or hand.grip_pressed:
		_take(pointer, window, point, corner, not hand.grip_pressed)


## Grip on [param window] or on its bar at [param point]: the window is taken
## as it is; one pinned to a hand comes off it as a window, centered where the
## ray hit it. A window taken by its [param corner] handle is held by the
## trigger if [param by_trigger], otherwise by the grip.
func _take(pointer: Pointer, window: XREPanelWindow, point: Vector3, corner: int = -1, by_trigger: bool = false) -> void:
	if window.is_pinned():
		_set_pin(window, XREPanelWindow.Pin.WINDOW)
		window.global_transform = Transform3D(
				facing(point, _rig.camera.global_position, _rig.global_basis.y), point)
	for other: Pointer in _pointers:
		if other != pointer and other.window == window:
			other.window = null
	_leave(pointer)
	window.stop_pulse()
	pointer.window = window
	pointer.corner = corner
	pointer.by_trigger = by_trigger
	pointer.hold = pointer.hand.global_transform.affine_inverse() * window.global_position
	pointer.hand.claim(self)
	if pointer.right:
		pointer.hand.claim_stick(self)


## Moves the window [param pointer]'s hand holds.
func _carry(pointer: Pointer, delta: float) -> void:
	var hand := pointer.hand
	if pointer.right:
		var tilt := _tilt(hand.get_vector2(&"primary").y)
		var length := pointer.hold.length()
		if tilt != 0.0 and length > 0.0:
			var target := clampf(length * exp(tilt * log(PUSH_SPEED) * delta), MIN_WINDOW_DISTANCE, MAX_WINDOW_DISTANCE)
			pointer.hold *= target / length
	var position := hand.global_transform * pointer.hold
	pointer.window.global_transform = Transform3D(
			facing(position, _rig.camera.global_position, _rig.global_basis.y), position)
	pointer.window.hover_handles(pointer.corner)
	hand.show_ray(maxf(-pointer.hold.z, 0.0), true)


## How far [param value], a stick axis, is tilted past the dead zone, -1 to 1.
static func _tilt(value: float) -> float:
	if absf(value) <= DEAD_ZONE:
		return 0.0
	return signf(value) * minf((absf(value) - DEAD_ZONE) / (1.0 - DEAD_ZONE), 1.0)
