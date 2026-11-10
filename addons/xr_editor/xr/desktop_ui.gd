@tool
class_name XREDesktopUI
extends RefCounted
## Hides the editor's 2D UI on the desktop while the user is in VR: in the
## headset or, without one, in the simulator's window (docs/decisions.md,
## D-119). Hidden, it isn't drawn, and the 3D editor viewports under it stop
## rendering: the desktop costs the frame less (the ui_hidden variant of
## [XREFrameBenchmark]).
##
## With [member minimize] the editor's window is minimized as well, and none
## of it is drawn. Restoring it from the taskbar, or a key or a mouse button
## pressed in it, shows the UI again, for the people at the desk; it stays
## until the user in VR presses a trigger or a grip. Whoever drives
## [method update] shows it while the user isn't in VR: the session ended,
## released for a game, the headset taken off, the simulator's window closed.

## Hide the UI while the user is in VR.
var enabled := false
## Minimize the editor's window while the UI is hidden. Needs a real window: off in tests.
var minimize := false
## Stop rendering the editor's window while the UI is hidden (Editor window Paused, D-165):
## its viewport, the root, isn't updated; the VR view, the simulator's window and the mirror,
## viewports of their own, still are. Set at once, also while hidden.
var pause_window := true:
	set(value):
		pause_window = value
		_apply_pause()

var _control: Control
var _hidden := false
var _shown_by_user := false
## What [member minimize] puts back when the UI shows.
var _mode_before := DisplayServer.WINDOW_MODE_WINDOWED
var _sleep_before := 0
## Whether this stopped the root viewport's updates.
var _window_paused := false


## [param control] is what hides: the editor's base control.
func _init(control: Control) -> void:
	_control = control


## Called every frame. [param in_headset]: the headset shows the editor now;
## [param controller_pressed]: a trigger or a grip went down since the last call.
## Returns whether the UI was hidden or shown by this call.
func update(in_headset: bool, controller_pressed: bool) -> bool:
	if controller_pressed:
		_shown_by_user = false
	if _hidden and minimize and DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_MINIMIZED:
		# Restored from the taskbar.
		_shown_by_user = true
	var changed := _set_hidden(enabled and in_headset and not _shown_by_user)
	if _hidden and minimize:
		# Godot 4.7.2 sleeps this long after every frame while the main window
		# is minimized, low-processor mode or not (OS::add_frame_delay); the
		# editor sets it again whenever its window gains or loses the focus.
		OS.low_processor_usage_mode_sleep_usec = 0
	return changed


## An event of the editor's window: a key or a mouse button shows the UI.
func handle_input(event: InputEvent) -> void:
	if not _hidden or not event.is_pressed() or not (event is InputEventKey or event is InputEventMouseButton):
		return
	_shown_by_user = true
	_set_hidden(false)


## Whether the UI is hidden now.
func is_hidden() -> bool:
	return _hidden


## Whether the editor's window isn't rendered now ([member pause_window]).
func is_window_paused() -> bool:
	return _window_paused


## Stops the editor's window's rendering again if it should be stopped: after someone else (the
## graph lab's root_off steps) turned it back on.
func reapply_pause() -> void:
	if not _window_paused: return
	_window_paused = false
	_apply_pause()


## Shows the UI, as it was before.
func restore() -> void:
	_shown_by_user = false
	_set_hidden(false)


func _set_hidden(hidden: bool) -> bool:
	if hidden == _hidden:
		return false
	_hidden = hidden
	_control.visible = not hidden
	_apply_pause()
	if not minimize:
		return true
	if hidden:
		_mode_before = DisplayServer.window_get_mode()
		_sleep_before = OS.low_processor_usage_mode_sleep_usec
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	else:
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MINIMIZED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED
					if _mode_before == DisplayServer.WINDOW_MODE_MINIMIZED else _mode_before)
		OS.low_processor_usage_mode_sleep_usec = _sleep_before
	return true


## Stops or restarts the root viewport's updates as [member pause_window] and the UI's state say.
## [method RenderingServer.viewport_set_active] would stop the VR view with it (D-017).
func _apply_pause() -> void:
	var paused := _hidden and pause_window
	if paused == _window_paused or _control == null or not _control.is_inside_tree():
		return
	_window_paused = paused
	RenderingServer.viewport_set_update_mode(_control.get_viewport().get_viewport_rid(),
			RenderingServer.VIEWPORT_UPDATE_DISABLED if paused else RenderingServer.VIEWPORT_UPDATE_WHEN_VISIBLE)
