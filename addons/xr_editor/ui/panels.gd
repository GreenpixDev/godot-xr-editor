@tool
class_name XREPanels
extends Node3D
## Flat panels in the headset (docs/decisions.md, D-016, D-041, D-042):
## windows of the tabs — the edited scene's tree, the inspector, signals, the
## project's files, Blueprints, the feature settings ([XRESettingsTab], D-039)
## and debug tools ([XREDebugTab]) — that the user opens from a launcher
## ([XRETabLauncher]), places in the scene ([XREPanelWindow]) or pins to a
## forearm. Both look as Meta Horizon OS's Navigator and windows do.
##
## Controls:
## [br]- X on the left controller: show or hide the launcher in front of the
## user, an icon for each tab, over a dimmed scene, together with the
## palette's tray ([method XREPalette.is_shown]).
## [br]- A controller's ray on a panel is a mouse pointer: the trigger clicks,
## pulling it twice quickly double-clicks, and the right thumbstick, up and
## down, scrolls. Either hand points at the launcher and at windows, but not
## at a window pinned to its own forearm.
## [br]- A tile of the launcher: open that tab's window in front of the user
## and hide the launcher and the tray. A tab has one window at most; if it has
## one already, the window comes to the user.
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
## A panel takes the ray even when scene geometry is in front of it.
## [br][br]
## Lives under the [XRERig], with an identity transform, after the palette
## (it claims the right hand on its tray first) and before the manipulator.

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
## Pixel size of the launcher: 45 × 28 cm with seven tiles, about 40° wide.
const LAUNCHER_PIXEL_SIZE := 0.0008
## How dark the scene gets behind the launcher, as Navigator dims it.
const LAUNCHER_DIM := 0.45
## How many times finer than its layout a panel is rendered at editor scale 1.
const RENDER_SCALE := 2.0
## How far rays reach panels, in meters.
const POINT_DISTANCE := 5.0
## Where a window opened from the launcher appears: this far ahead of the head
## and this far below it, in meters.
const WINDOW_DISTANCE := 0.7
const WINDOW_DROP := 0.15
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
var _menus_shown := false
## The hand whose trigger the panels are handing to a panel right now, or null.
var _clicking: XREHand


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
	_launcher.set_shown(false)
	# Over the dimmer, as Navigator is over the dimmed scene.
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


func _exit_tree() -> void:
	if is_instance_valid(_blueprints) and _blueprints.changed.is_connected(_update_overlay): _blueprints.changed.disconnect(_update_overlay)
	if is_instance_valid(_dimmer): _dimmer.queue_free()
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
		_menus_shown = shown
		if shown:
			_place_in_front(_launcher, LAUNCHER_DISTANCE, LAUNCHER_DROP)
		_launcher.set_shown(shown)
		_dimmer.visible = shown
	if shown:
		_launcher.update_clock()
	for window: XREPanelWindow in _windows:
		var hand := _pin_hand(window)
		if hand != null:
			window.set_shown(hand.get_has_tracking_data())
			if window.is_shown():
				window.global_transform = hand.global_transform * HAND_OFFSET
	for pointer: Pointer in _pointers:
		_update_pointer(pointer, delta)


func get_launcher() -> XRETabLauncher:
	return _launcher


## Connects the optional graph tab to the spatial editing service.
func set_blueprints(service: XREBlueprints) -> void:
	if is_instance_valid(_blueprints) and _blueprints.changed.is_connected(_update_overlay): _blueprints.changed.disconnect(_update_overlay)
	_blueprints = service
	if service != null: service.changed.connect(_update_overlay)
	for window: XREPanelWindow in _windows:
		if window.tab is XREBlueprintTab: (window.tab as XREBlueprintTab).setup(service)
	_update_overlay()


func _update_overlay() -> void:
	var enabled := _blueprints != null and _blueprints.is_open()
	for window: XREPanelWindow in _windows: window.set_overlay(enabled)


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


## The window pinned to [param hand]'s forearm, or null.
func get_pinned_window(hand: XREHand) -> XREPanelWindow:
	for window: XREPanelWindow in _windows:
		if _pin_hand(window) == hand:
			return window
	return null


## Opens the window of the tab of class [param type] in front of the user,
## or brings it there if it is open, off a hand if it is pinned.
func open_window(type: Script) -> XREPanelWindow:
	var window := _window_for(type)
	if window.is_pinned():
		_set_pin(window, XREPanelWindow.Pin.WINDOW)
	_place_in_front(window, WINDOW_DISTANCE, WINDOW_DROP)
	return window


## Puts [param window] at [param where], an [enum XREPanelWindow.Pin]: pinned,
## compact, to a forearm, where a window pinned before makes way and comes in
## front of the user; or back in front of the user as a window.
func pin_window(window: XREPanelWindow, where: int) -> void:
	if where == window.pin or not _windows.has(window):
		return
	if where != XREPanelWindow.Pin.WINDOW:
		for other: XREPanelWindow in _windows:
			if other != window and other.pin == where:
				open_window(other.tab.get_script() as Script)
	_set_pin(window, where)
	if where == XREPanelWindow.Pin.WINDOW:
		_place_in_front(window, WINDOW_DISTANCE, WINDOW_DROP)
	else:
		window.global_transform = _pin_hand(window).global_transform * HAND_OFFSET


## The tabs' classes, in the launcher's order.
static func tab_types() -> Array[GDScript]:
	return [XRESceneTab, XREInspectorTab, XRESignalsTab, XREFileSystemTab, XREBlueprintTab, XRESettingsTab, XREDebugTab]


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


## The window of the tab of class [param type], opened where it last was, or
## made, unplaced, if there is none.
func _window_for(type: Script) -> XREPanelWindow:
	var window := find_window(type)
	if window != null:
		return window
	var tab := (type as GDScript).new(_document) as XREPanelTab
	if tab is XREBlueprintTab: (tab as XREBlueprintTab).setup(_blueprints)
	if tab is XREDebugTab: (tab as XREDebugTab).setup(_session)
	window = XREPanelWindow.new(tab, WINDOW_SIZE * _scale, WINDOW_PIXEL_SIZE / _scale, _render_scale(), _theme)
	window.name = "%sWindow" % window.tab.name
	# Deferred: the click on the button is still being handled.
	window.close_requested.connect(_close_window.bind(window), CONNECT_DEFERRED)
	# Not deferred: the hand that clicked is known only while the click is handled.
	window.pin_requested.connect(_on_pin_requested.bind(window))
	window.unpin_requested.connect(pin_window.bind(window, XREPanelWindow.Pin.WINDOW), CONNECT_DEFERRED)
	add_child(window)
	_windows.append(window)
	window.set_overlay(_blueprints != null and _blueprints.is_open())
	return window


func _close_window(window: XREPanelWindow) -> void:
	_release(window)
	_windows.erase(window)
	window.queue_free()


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
		window.set_pin(where, WINDOW_SIZE * _scale, WINDOW_PIXEL_SIZE / _scale)
		window.set_shown(true)
	else:
		window.set_pin(where, COMPACT_SIZE * _scale, COMPACT_PIXEL_SIZE / _scale)


## The hand [param window] is pinned to, or null.
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
	_palette.close()


func _update_pointer(pointer: Pointer, delta: float) -> void:
	var hand := pointer.hand
	if pointer.window != null:
		if (hand.trigger_held if pointer.by_trigger else hand.grip_held) and hand.get_has_tracking_data():
			_carry(pointer, delta)
			return
		pointer.window = null
	if not hand.is_free_for(self) or not hand.get_has_tracking_data():
		_leave(pointer)
		return

	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	var surface: XREPanelSurface = null
	var handle: XREPanelWindow = null
	var distance := POINT_DISTANCE
	if pointer.drives and pointer.surface.is_pressed():
		# A held button keeps the pointer on its panel, as a mouse drag keeps its control.
		surface = pointer.surface
		distance = surface.intersect_ray(origin, direction, INF, false)
	else:
		var hit := _launcher.intersect_ray(origin, direction, distance)
		if hit >= 0.0:
			surface = _launcher
			distance = hit
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
		if _blueprints != null and _blueprints.takes_pointer(hand, origin, direction, distance):
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
