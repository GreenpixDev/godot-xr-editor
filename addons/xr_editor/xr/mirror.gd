@tool
class_name XREMirror
extends Window
## The headset's view on the desktop (docs/decisions.md, D-118): a window of
## its own shows what the left eye sees, for people around the user.
##
## Nothing is rendered twice. The window's own viewport is detached from its
## screen, and the headset's viewport is attached there instead: Godot 4.7.2
## then copies the left eye of each frame the headset gets into the window
## ([code]OpenXRInterface::post_draw_viewport[/code], the same copy a desktop XR
## game shows in its window). The eye fills the window, cut at the edges if
## their proportions differ. A frame the headset doesn't get (the session not
## visible, released for a game) isn't copied: the window keeps the last one.
## Not on a standalone headset, where the engine doesn't copy.
## [br][br]
## [constant FULLSCREEN_KEY] in the window switches it to the full screen and back.

## Height of the window when it opens, in pixels; its width follows the eye's proportions.
const HEIGHT := 720
const FULLSCREEN_KEY := KEY_F11

var _headset_viewport: RID


## [param headset_viewport] is the viewport the headset renders,
## [param eye_size] the size of one eye's image.
func _init(headset_viewport: SubViewport, eye_size: Vector2) -> void:
	name = "XREMirror"
	title = "XR Editor — headset view"
	# A window inside the editor's own (single window mode) has no screen to attach to.
	force_native = true
	size = Vector2i(roundi(HEIGHT * eye_size.x / eye_size.y), HEIGHT) if eye_size.y > 0.0 else Vector2i(HEIGHT, HEIGHT)
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	wrap_controls = false
	_headset_viewport = headset_viewport.get_viewport_rid()
	window_input.connect(_on_window_input)


func _notification(what: int) -> void:
	match what:
		# The window attaches its own viewport to its screen each time its size
		# changes, right before this notification.
		NOTIFICATION_WM_SIZE_CHANGED:
			_attach()
		NOTIFICATION_EXIT_TREE:
			_detach()


func _attach() -> void:
	var id := get_window_id()
	if id == DisplayServer.INVALID_WINDOW_ID:
		# Hidden: no screen to copy to.
		_detach()
		return
	RenderingServer.viewport_attach_to_screen(get_viewport_rid(), Rect2(), DisplayServer.INVALID_WINDOW_ID)
	RenderingServer.viewport_attach_to_screen(_headset_viewport, Rect2(Vector2.ZERO, size), id)
	# The window is presented in every frame the headset gets: with V-Sync it
	# would hold the main loop to the desktop monitor, not the headset.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED, id)


func _detach() -> void:
	RenderingServer.viewport_attach_to_screen(_headset_viewport, Rect2(), DisplayServer.INVALID_WINDOW_ID)


func _on_window_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo or key.physical_keycode != FULLSCREEN_KEY:
		return
	mode = Window.MODE_WINDOWED if mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN
