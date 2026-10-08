@tool
class_name XREPanelSurface
extends Node3D
## A flat interface shown in the headset: controls laid out in a [SubViewport]
## and drawn onto a quad, with a controller's ray for a mouse
## (docs/decisions.md, D-016). [XREPanels] drives the pointer.
##
## The quad lies in the node's XY plane, centered on its origin, and faces +Z;
## only its front takes the ray. The interface is laid out at
## [member size_px] and rendered at a multiple of it, so that text stays sharp
## in the headset. [member root] is the frame every panel shares: the editor's
## theme, its base color, rounded corners. Popups open inside the panel, never
## on the desktop.
## [br][br]
## The pointer acts as a mouse with one button. A press pins the pointer where
## it went down until the ray moves [constant CLICK_SLOP_PX] away, so that
## hand tremor doesn't turn a click into a drag. Godot leaves double clicks to
## the platform, so the panel marks a press soon after another, at the same
## place, as one.
## [br][br]
## The panel is rendered only while its quad is in view, and not at all while hidden.

## Emitted after the pointer's button went up, once the interface has handled it.
signal pointer_released

## How far the ray must move from where a press went down before the pointer follows it, in pixels.
const CLICK_SLOP_PX := 8.0
## A press within this time of the previous one, and this close to it, is a double click.
const DOUBLE_CLICK_USEC := 400000
const DOUBLE_CLICK_PX := 12.0
## Corner radius of the frame, in interface pixels.
const CORNER_RADIUS := 12

## The frame, filling the panel; panels put their controls in it.
var root: PanelContainer
## Size of the interface, in its own pixels.
var size_px: Vector2
## Size of the quad, in meters.
var size_m: Vector2

var _viewport: SubViewport
var _quad: MeshInstance3D
var _shown := true
## The pointer is on the panel: the viewport was told the mouse entered.
var _inside := false
var _pointer := Vector2.ZERO
var _pressed := false
## The pointer stays where the press went down.
var _pinned := false
var _press_position := Vector2.ZERO
var _last_press_usec := -DOUBLE_CLICK_USEC
var _last_press_position := Vector2.ZERO
var _hit_pixel := Vector2.ZERO


## A panel [param logical_size] interface pixels large, each [param pixel_size]
## meters in the headset and rendered [param render_scale] times as fine.
func _init(logical_size: Vector2, pixel_size: float, render_scale: float, theme: Theme) -> void:
	size_px = logical_size
	size_m = logical_size * pixel_size

	root = PanelContainer.new()
	root.name = "Frame"
	root.theme = theme
	root.add_theme_stylebox_override(&"panel", frame_style(theme))
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_viewport = SubViewport.new()
	_viewport.name = "Viewport"
	_viewport.size = Vector2i((logical_size * render_scale).round())
	_viewport.size_2d_override = Vector2i(logical_size.round())
	_viewport.size_2d_override_stretch = true
	_viewport.transparent_bg = true
	_viewport.disable_3d = true
	_viewport.gui_embed_subwindows = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	_viewport.add_child(root)
	add_child(_viewport)

	var mesh := QuadMesh.new()
	mesh.size = size_m
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
	material.albedo_texture = _viewport.get_texture()
	# The viewport renders in sRGB, and the material would read it as linear.
	material.albedo_texture_force_srgb = true
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	material.disable_fog = true
	_quad = XRERig.create_vr_mesh(mesh, material)
	_quad.name = "Quad"
	add_child(_quad)


## The frame of every panel: the editor's base color, rounded corners and an
## edge in its accent color.
static func frame_style(theme: Theme) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = editor_color(theme, &"base_color", Color(0.13, 0.15, 0.19))
	var edge := editor_color(theme, &"accent_color", Color(0.44, 0.73, 0.98))
	edge.a = 0.6
	style.border_color = edge
	style.set_border_width_all(2)
	style.set_corner_radius_all(CORNER_RADIUS)
	style.set_content_margin_all(8.0)
	style.anti_aliasing = true
	return style


## The editor theme's color [param color_name], or [param fallback] without the editor's theme.
static func editor_color(theme: Theme, color_name: StringName, fallback: Color) -> Color:
	if theme != null and theme.has_color(color_name, &"Editor"):
		return theme.get_color(color_name, &"Editor")
	return fallback


## Whether the panel is in view and takes the ray.
func is_shown() -> bool:
	return _shown


## Shows or hides the panel. A hidden panel isn't rendered, its controls are
## hidden too (tabs stop updating), and a pointer on it leaves.
func set_shown(shown: bool) -> void:
	if shown == _shown:
		return
	_shown = shown
	if not shown:
		pointer_exit()
	visible = shown
	root.visible = shown
	_viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE if shown else SubViewport.UPDATE_DISABLED


## Distance from [param origin] along [param direction] (a unit vector) to
## where the ray meets the panel's front, if that is within
## [param max_distance]; otherwise -1. [method get_hit_pixel] then tells the
## pixel. With [param bounded] off, any point of the panel's plane counts:
## a pointer holding the button down follows the ray past the edges.
## The panel must not be scaled, for the distance to be in meters.
func intersect_ray(origin: Vector3, direction: Vector3, max_distance: float, bounded: bool = true) -> float:
	if not _shown or not is_visible_in_tree():
		return -1.0
	var to_local := global_transform.affine_inverse()
	var local_origin := to_local * origin
	var local_direction := to_local.basis * direction
	if local_origin.z <= 0.0 or local_direction.z >= 0.0:
		return -1.0
	var distance := -local_origin.z / local_direction.z
	if distance > max_distance:
		return -1.0
	var hit := local_origin + local_direction * distance
	var pixel := Vector2((hit.x / size_m.x + 0.5) * size_px.x, (0.5 - hit.y / size_m.y) * size_px.y)
	if bounded and (pixel.x < 0.0 or pixel.y < 0.0 or pixel.x > size_px.x or pixel.y > size_px.y):
		return -1.0
	_hit_pixel = pixel
	return distance


## The interface pixel the last hit of [method intersect_ray] fell on.
func get_hit_pixel() -> Vector2:
	return _hit_pixel


## Global position of the interface pixel [param pixel] on the quad.
func pixel_to_global(pixel: Vector2) -> Vector3:
	var local := Vector3((pixel.x / size_px.x - 0.5) * size_m.x, (0.5 - pixel.y / size_px.y) * size_m.y, 0.0)
	return global_transform * local


## Where the pointer is, in interface pixels.
func get_pointer() -> Vector2:
	return _pointer


## Whether the pointer's button is down.
func is_pressed() -> bool:
	return _pressed


## Moves the pointer to [param pixel], entering the panel if it was off it.
func pointer_move(pixel: Vector2) -> void:
	if _pinned:
		if pixel.distance_to(_press_position) < CLICK_SLOP_PX:
			return
		_pinned = false
	var entering := not _inside
	if entering:
		_inside = true
		_viewport.notification(NOTIFICATION_VP_MOUSE_ENTER)
	elif pixel == _pointer:
		return
	var event := InputEventMouseMotion.new()
	event.position = pixel
	event.global_position = pixel
	event.relative = Vector2.ZERO if entering else pixel - _pointer
	event.screen_relative = event.relative
	if _pressed:
		event.button_mask = MOUSE_BUTTON_MASK_LEFT
	_pointer = pixel
	_viewport.push_input(event, true)


## Presses or lets go of the pointer's button where the pointer is.
func pointer_button(pressed: bool) -> void:
	if pressed == _pressed or not _inside:
		return
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = _pointer
	event.global_position = _pointer
	_pressed = pressed
	if pressed:
		event.button_mask = MOUSE_BUTTON_MASK_LEFT
		var now := Time.get_ticks_usec()
		event.double_click = now - _last_press_usec < DOUBLE_CLICK_USEC \
				and _pointer.distance_to(_last_press_position) < DOUBLE_CLICK_PX
		# A double click ends the series: the next press starts a new one.
		_last_press_usec = -DOUBLE_CLICK_USEC if event.double_click else now
		_last_press_position = _pointer
		_press_position = _pointer
		_pinned = true
	_viewport.push_input(event, true)
	if not pressed:
		_pinned = false
		pointer_released.emit()


## Turns the mouse wheel by [param notches] where the pointer is: positive
## scrolls up. A fraction of a notch scrolls a fraction as far.
func pointer_scroll(notches: float) -> void:
	if not _inside or is_zero_approx(notches):
		return
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_WHEEL_UP if notches > 0.0 else MOUSE_BUTTON_WHEEL_DOWN
		event.factor = absf(notches)
		event.pressed = pressed
		event.position = _pointer
		event.global_position = _pointer
		_viewport.push_input(event, true)


## Takes the pointer off the panel, letting go of its button first.
func pointer_exit() -> void:
	if not _inside or not _viewport.is_inside_tree():
		_inside = false
		_pressed = false
		_pinned = false
		return
	if _pressed:
		pointer_button(false)
	_inside = false
	_pinned = false
	_viewport.notification(NOTIFICATION_VP_MOUSE_EXIT)
