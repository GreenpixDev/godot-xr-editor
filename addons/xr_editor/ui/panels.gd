@tool
class_name XREPanels
extends Node3D
## Flat panels in the headset (docs/decisions.md, D-016): one lying on the
## left forearm, with tabs for the edited scene's tree, the inspector, signals
## and the project's files ([XREHandPanel]), and windows the user opens from
## those tabs and places in the scene ([XREPanelWindow]).
##
## Controls:
## [br]- X on the left controller: show or hide the forearm panel, together
## with the palette's tray ([method XREPalette.is_shown]).
## [br]- A controller's ray on a panel is a mouse pointer: the trigger clicks,
## pulling it twice quickly double-clicks, and the right thumbstick, up and
## down, scrolls. The right hand points at the forearm panel and at windows,
## the left hand at windows.
## [br]- The button at the end of the tab bar: open the tab as a window in
## front of the user. A tab has one window at most; if it has one already,
## the window comes to the user.
## [br]- Grip with the ray on the forearm panel: pull the current tab out as a
## window, which follows the hand until the grip lets go.
## [br]- Grip with the ray on a window: move it. It keeps its distance from the
## hand and turns to face the head; the right thumbstick, up and down, pushes
## it away or pulls it closer.
## [br]- × in a window's title bar: close it.
## [br][br]
## Windows live in the rig's space: flying and turning ([XRELocomotion]) take
## them along, and they stay when another scene is opened. What the tabs
## change goes through [XREDocument] as operations from a panel. A hand on a
## panel is claimed ([method XREHand.claim]), so that the trigger doesn't also
## select what is behind the panel; the right thumbstick is claimed too
## ([method XREHand.claim_stick]), so that scrolling doesn't turn the user.
## A panel takes the ray even when scene geometry is in front of it.
## [br][br]
## Lives under the [XRERig], with an identity transform, after the palette
## (it claims the right hand on its tray first) and before the manipulator.

## Tilted wrist panels follow the controller orientation, as before D-028.
const HAND_OFFSET := Transform3D(Basis(Vector3.RIGHT, -PI / 3.0), Vector3(0.0, 0.02, 0.17))
const FPS_OFFSET := HAND_OFFSET
## Size of the forearm panel in interface pixels at editor scale 1, and the
## size of such a pixel in meters: 25 × 17 cm. Wide enough for the titles of
## the four tabs in the Russian editor.
const HAND_PANEL_SIZE := Vector2(500.0, 340.0)
const HAND_PIXEL_SIZE := 0.0005
## The same for windows: 43 × 54 cm, made to be read from farther away.
const WINDOW_SIZE := Vector2(480.0, 600.0)
const WINDOW_PIXEL_SIZE := 0.0009
## How many times finer than its layout a panel is rendered at editor scale 1.
const RENDER_SCALE := 2.0
## How far rays reach panels, in meters.
const POINT_DISTANCE := 5.0
## Where a window opened with the button appears: this far ahead of the head
## and this far below it, in meters.
const WINDOW_DISTANCE := 0.7
const WINDOW_DROP := 0.15
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
	## The right hand: it points at the forearm panel, and its thumbstick
	## scrolls and pushes windows. The left hand carries the forearm panel.
	var reaches_hand_panel := false
	var uses_stick := false
	## The panel the ray is on, or null.
	var surface: XREPanelSurface
	## This pointer moves [member surface]'s mouse ([method XREPanels._may_drive]).
	var drives := false
	## The window the hand holds, or null.
	var window: XREPanelWindow
	## The window's position in the hand's space, fixed when it was taken.
	var hold: Vector3

	func _init(controller: XREHand, right: bool) -> void:
		hand = controller
		reaches_hand_panel = right
		uses_stick = right


var _document: XREDocument
var _rig: XRERig
var _palette: XREPalette
var _theme: Theme
## The editor's display scale: panels are laid out larger and their pixels made smaller by it.
var _scale := 1.0
var _hand_panel: XREHandPanel
var _windows: Array[XREPanelWindow] = []
var _pointers: Array[Pointer] = []
var _blueprints: XREBlueprints
var _fps: XREFPSWidget
var _fps_closed := false
var _menus_shown := false


## [param theme] and [param editor_scale] are the editor's; without them
## (null, 1) the panels use Godot's default theme.
func _init(document: XREDocument, rig: XRERig, palette: XREPalette, theme: Theme, editor_scale: float, session: XRESession = null) -> void:
	_document = document
	_rig = rig
	_palette = palette
	_theme = theme
	_scale = editor_scale
	var tabs: Array[XREPanelTab] = []
	for type: GDScript in tab_types():
		tabs.append(_create_tab(type))
	_hand_panel = XREHandPanel.new(tabs, HAND_PANEL_SIZE * _scale, HAND_PIXEL_SIZE / _scale, _render_scale(), theme)
	_hand_panel.name = "HandPanel"
	_hand_panel.set_shown(false)
	_hand_panel.pop_out_requested.connect(_on_pop_out_requested)
	add_child(_hand_panel)
	_fps = XREFPSWidget.new(theme, HAND_PANEL_SIZE * _scale, HAND_PIXEL_SIZE / _scale, _render_scale())
	_fps.name = "HandFPS"
	_fps.setup(session)
	_fps.close_requested.connect(func() -> void: _fps_closed = true)
	add_child(_fps)
	_pointers.append(Pointer.new(rig.right_hand, true))
	_pointers.append(Pointer.new(rig.left_hand, false))


func _exit_tree() -> void:
	if is_instance_valid(_blueprints) and _blueprints.changed.is_connected(_update_overlay): _blueprints.changed.disconnect(_update_overlay)
	# The panels have left the tree before this node: only the hands are let go.
	for pointer: Pointer in _pointers:
		pointer.surface = null
		pointer.drives = false
		pointer.window = null
		pointer.hand.unclaim(self)
		pointer.hand.unclaim_stick(self)


func _process(delta: float) -> void:
	var shown := _palette.is_shown()
	if shown != _menus_shown:
		_fps_closed = false
		_menus_shown = shown
	_hand_panel.set_shown(shown)
	_fps.set_shown(shown and not _fps_closed and _rig.right_hand.get_has_tracking_data())
	if shown:
		_hand_panel.global_transform = _rig.left_hand.global_transform * HAND_OFFSET
		_fps.global_transform = _rig.right_hand.global_transform * FPS_OFFSET
	for pointer: Pointer in _pointers:
		_update_pointer(pointer, delta)


func get_hand_panel() -> XREHandPanel:
	return _hand_panel


## Connects the optional graph tab to the spatial editing service.
func set_blueprints(service: XREBlueprints) -> void:
	if is_instance_valid(_blueprints) and _blueprints.changed.is_connected(_update_overlay): _blueprints.changed.disconnect(_update_overlay)
	_blueprints = service
	if service != null: service.changed.connect(_update_overlay)
	for tab: XREPanelTab in _hand_panel.get_tabs():
		if tab is XREBlueprintTab: (tab as XREBlueprintTab).setup(service)
	_update_overlay()


func _update_overlay() -> void:
	var enabled := _blueprints != null and _blueprints.is_open()
	_hand_panel.set_overlay(enabled)
	_fps.set_overlay(enabled)
	for window: XREPanelWindow in _windows: window.set_overlay(enabled)


## The open windows, in the order they were opened.
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


## Opens the window of the tab of class [param type] in front of the user,
## or brings it there if it is open.
func open_window(type: Script) -> XREPanelWindow:
	var window := _window_for(type)
	var head := _rig.camera.global_transform
	var up := _rig.global_basis.y.normalized()
	var forward := -head.basis.z
	forward -= up * forward.dot(up)
	if forward.length() < 0.01:
		forward = -_rig.global_basis.z
	var position := head.origin + forward.normalized() * WINDOW_DISTANCE - up * WINDOW_DROP
	window.global_transform = Transform3D(facing(position, head.origin, up), position)
	return window


## The tabs' classes, in the forearm panel's order.
static func tab_types() -> Array[GDScript]:
	return [XRESceneTab, XREInspectorTab, XRESignalsTab, XREFileSystemTab, XREBlueprintTab]


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


func _create_tab(type: GDScript) -> XREPanelTab:
	var tab := type.new(_document) as XREPanelTab
	if tab is XREBlueprintTab: (tab as XREBlueprintTab).setup(_blueprints)
	return tab


## The window of the tab of class [param type], opened where it last was, or
## made, unplaced, if there is none.
func _window_for(type: Script) -> XREPanelWindow:
	var window := find_window(type)
	if window != null:
		return window
	window = XREPanelWindow.new(_create_tab(type as GDScript), WINDOW_SIZE * _scale, WINDOW_PIXEL_SIZE / _scale,
			_render_scale(), _theme)
	window.name = "%sWindow" % window.tab.name
	# Deferred: the click on the close button is still being handled.
	window.close_requested.connect(_close_window.bind(window), CONNECT_DEFERRED)
	add_child(window)
	_windows.append(window)
	window.set_overlay(_blueprints != null and _blueprints.is_open())
	return window


func _close_window(window: XREPanelWindow) -> void:
	for pointer: Pointer in _pointers:
		if pointer.surface == window:
			pointer.surface = null
			pointer.drives = false
		if pointer.window == window:
			pointer.window = null
	_windows.erase(window)
	window.queue_free()


func _on_pop_out_requested(tab: XREPanelTab) -> void:
	open_window(tab.get_script() as Script)


func _update_pointer(pointer: Pointer, delta: float) -> void:
	var hand := pointer.hand
	if pointer.window != null:
		if hand.grip_held and hand.get_has_tracking_data():
			_carry(pointer, delta)
			return
		pointer.window = null
	if not hand.is_free_for(self) or not hand.get_has_tracking_data():
		_leave(pointer)
		return

	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	var surface: XREPanelSurface = null
	var distance := POINT_DISTANCE
	if pointer.drives and pointer.surface.is_pressed():
		# A held button keeps the pointer on its panel, as a mouse drag keeps its control.
		surface = pointer.surface
		distance = surface.intersect_ray(origin, direction, INF, false)
	else:
		if pointer.reaches_hand_panel:
			var hit := _hand_panel.intersect_ray(origin, direction, distance)
			if hit >= 0.0:
				surface = _hand_panel
				distance = hit
		else:
			var hit := _fps.intersect_ray(origin, direction, distance)
			if hit >= 0.0:
				surface = _fps
				distance = hit
		for window: XREPanelWindow in _windows:
			var hit := window.intersect_ray(origin, direction, distance)
			if hit >= 0.0:
				surface = window
				distance = hit
		if _blueprints != null and _blueprints.takes_pointer(hand, origin, direction, distance):
			_leave(pointer)
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
	if pointer.uses_stick:
		hand.claim_stick(self)
	if distance >= 0.0:
		hand.show_ray(distance, true)
	if not pointer.drives:
		return
	if distance >= 0.0:
		surface.pointer_move(surface.get_hit_pixel())
	if hand.trigger_pressed:
		surface.pointer_button(true)
	elif hand.trigger_released:
		surface.pointer_button(false)
	if hand.grip_pressed and surface != _fps and not surface.is_pressed() and distance >= 0.0:
		_take(pointer, surface, origin + direction * distance)
	elif pointer.uses_stick:
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
		if surface.is_pressed() or not pointer.reaches_hand_panel:
			return false
		other.drives = false
	return true


## Grip on [param surface] at [param point]: a window is taken as it is; the
## forearm panel gives its current tab's window, which comes to the point.
func _take(pointer: Pointer, surface: XREPanelSurface, point: Vector3) -> void:
	var window := surface as XREPanelWindow
	if window == null:
		window = _window_for(_hand_panel.get_current_tab().get_script() as Script)
		window.global_transform = Transform3D(
				facing(point, _rig.camera.global_position, _rig.global_basis.y), point)
	for other: Pointer in _pointers:
		if other != pointer and other.window == window:
			other.window = null
	_leave(pointer)
	pointer.window = window
	pointer.hold = pointer.hand.global_transform.affine_inverse() * window.global_position
	pointer.hand.claim(self)
	if pointer.uses_stick:
		pointer.hand.claim_stick(self)


## Moves the window [param pointer]'s hand holds.
func _carry(pointer: Pointer, delta: float) -> void:
	var hand := pointer.hand
	if pointer.uses_stick:
		var tilt := _tilt(hand.get_vector2(&"primary").y)
		var length := pointer.hold.length()
		if tilt != 0.0 and length > 0.0:
			var target := clampf(length * exp(tilt * log(PUSH_SPEED) * delta), MIN_WINDOW_DISTANCE, MAX_WINDOW_DISTANCE)
			pointer.hold *= target / length
	var position := hand.global_transform * pointer.hold
	pointer.window.global_transform = Transform3D(
			facing(position, _rig.camera.global_position, _rig.global_basis.y), position)
	hand.show_ray(maxf(-pointer.hold.z, 0.0), true)


## How far [param value], a stick axis, is tilted past the dead zone, -1 to 1.
static func _tilt(value: float) -> float:
	if absf(value) <= DEAD_ZONE:
		return 0.0
	return signf(value) * minf((absf(value) - DEAD_ZONE) / (1.0 - DEAD_ZONE), 1.0)
