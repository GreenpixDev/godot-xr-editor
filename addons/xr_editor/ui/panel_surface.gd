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
## A window (rig-locked, docs/vr_ui.md, D-040) has corner handles
## ([method add_corner_handles]): brackets just outside its corners, shown
## while a ray is on the window. The router that owns the window moves it by
## them ([method intersect_handle]); they never reach the interface.
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
## Background of a Meta Horizon OS window (D-042): dark neutral gray, no edge.
const META_WINDOW_COLOR := Color(0.12, 0.13, 0.15)
## Corners, in the order of [method get_hit_corner].
enum Corner { TOP_LEFT, TOP_RIGHT, BOTTOM_RIGHT, BOTTOM_LEFT }
## A corner handle's bracket, in meters: its gap from the frame's edge, its
## width and how far each arm runs from the corner along the edges.
const HANDLE_GAP := 0.012
const HANDLE_WIDTH := 0.008
const HANDLE_ARM := 0.045
## Where a ray takes a corner handle, in meters: outside the frame, up to
## [constant HANDLE_OUT] beyond its edges and [constant HANDLE_ALONG] from
## the corner along them. Inside the frame the ray stays the interface's mouse.
const HANDLE_OUT := 0.045
const HANDLE_ALONG := 0.07
## A handle's color, while a ray is on the window and while it is on that handle.
const HANDLE_COLOR := Color(1.0, 1.0, 1.0, 0.45)
const HANDLE_HOT_COLOR := Color(1.0, 1.0, 1.0, 0.95)
const _HOVER_BODY := 1 << 4

## Handle materials shared by every window: idle and hot, over the scene and over the logic veil.
static var _handle_materials: Array[ShaderMaterial] = []

## The frame, filling the panel; panels put their controls in it.
var root: PanelContainer
## Corner radius of the frame in interface pixels; the corner handles bend
## around it. Set before [method add_corner_handles].
var corner_radius := CORNER_RADIUS
## Size of the interface, in its own pixels.
var size_px: Vector2
## Size of the quad, in meters.
var size_m: Vector2

var _viewport: SubViewport
var _quad: MeshInstance3D
var _render_scale := 1.0
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
## Where the last ray met the panel's plane, in meters from its center.
var _hit_local := Vector2.ZERO
var _hit_corner := -1
## Corner handles, in [enum Corner] order; empty on a panel that isn't a window.
var _handles: Array[MeshInstance3D] = []
var _handles_enabled := true
## What rays were on this frame: a bit per corner and [constant _HOVER_BODY];
## [method _process] shows the handles by it and clears it.
var _hover_mask := 0
var _shown_mask := -1
var _overlay := false
var _scene_material: StandardMaterial3D
var _overlay_material: ShaderMaterial


## A panel [param logical_size] interface pixels large, each [param pixel_size]
## meters in the headset and rendered [param render_scale] times as fine.
func _init(logical_size: Vector2, pixel_size: float, render_scale: float, theme: Theme) -> void:
	size_px = logical_size
	size_m = logical_size * pixel_size
	_render_scale = render_scale

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
	_scene_material = material
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, depth_draw_always, fog_disabled;
uniform sampler2D panel_texture : source_color, filter_linear;
void fragment() {
	vec4 color = texture(panel_texture, UV);
	if (color.a < 0.01) discard;
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
"""
	_overlay_material = ShaderMaterial.new()
	_overlay_material.shader = shader
	_overlay_material.render_priority = Material.RENDER_PRIORITY_MAX
	_overlay_material.set_shader_parameter(&"panel_texture", _viewport.get_texture())
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


## A frame as Meta Horizon OS draws a window or a pill (D-042): [param color],
## no edge, corners rounded by [param radius] interface pixels, contents
## [param margin] pixels in.
static func meta_style(color: Color, radius: int, margin: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.set_content_margin_all(margin)
	style.anti_aliasing = true
	return style


## The editor theme's color [param color_name], or [param fallback] without the editor's theme.
static func editor_color(theme: Theme, color_name: StringName, fallback: Color) -> Color:
	if theme != null and theme.has_color(color_name, &"Editor"):
		return theme.get_color(color_name, &"Editor")
	return fallback


## Lays the panel out anew at [param logical_size] interface pixels, each
## [param pixel_size] meters in the headset, rendered as finely as before; its
## corner handles go to the new corners. A window pinned to a hand is
## compacted this way ([XREPanelWindow]).
func resize(logical_size: Vector2, pixel_size: float) -> void:
	size_px = logical_size
	size_m = logical_size * pixel_size
	_viewport.size = Vector2i((logical_size * _render_scale).round())
	_viewport.size_2d_override = Vector2i(logical_size.round())
	(_quad.mesh as QuadMesh).size = size_m
	if not _handles.is_empty():
		_place_handles()


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
	var distance := _cast(origin, direction, max_distance)
	if distance < 0.0:
		return -1.0
	var pixel := Vector2((_hit_local.x / size_m.x + 0.5) * size_px.x, (0.5 - _hit_local.y / size_m.y) * size_px.y)
	if bounded and (pixel.x < 0.0 or pixel.y < 0.0 or pixel.x > size_px.x or pixel.y > size_px.y):
		return -1.0
	_hit_pixel = pixel
	return distance


## The interface pixel the last hit of [method intersect_ray] fell on.
func get_hit_pixel() -> Vector2:
	return _hit_pixel


## Gives the panel corner handles: it becomes a window, which a ray moves by
## its corners (D-040). Called once, before the panel is used.
func add_corner_handles() -> void:
	if not _handles.is_empty():
		return
	var angles: Array[float] = [PI / 2.0, 0.0, -PI / 2.0, PI]
	for corner: int in 4:
		# The mesh comes with the frame's size (_place_handles).
		var handle := XRERig.create_vr_mesh(null, _handle_material(false))
		handle.name = "Handle%s" % (Corner.keys()[corner] as String).to_pascal_case()
		handle.rotation.z = angles[corner]
		handle.visible = false
		add_child(handle)
		_handles.append(handle)
	_place_handles()
	set_process(true)


## Whether the panel is a window, with corner handles it can be moved by now.
func has_corner_handles() -> bool:
	return not _handles.is_empty() and _handles_enabled


## Turns the corner handles off, or back on: a window pinned to a hand isn't
## moved by its corners, and they neither show nor take the ray.
func set_handles_enabled(enabled: bool) -> void:
	if enabled == _handles_enabled:
		return
	_handles_enabled = enabled
	_hover_mask = 0
	_shown_mask = 0
	_update_handles()


## Distance from [param origin] along [param direction] (a unit vector) to
## where the ray meets one of the window's corner handles, if that is within
## [param max_distance]; otherwise -1, and always -1 without handles.
## [method get_hit_corner] then tells which corner.
func intersect_handle(origin: Vector3, direction: Vector3, max_distance: float) -> float:
	if not has_corner_handles():
		return -1.0
	var distance := _cast(origin, direction, max_distance)
	if distance < 0.0:
		return -1.0
	var corner := corner_at(_hit_local, size_m)
	if corner < 0:
		return -1.0
	_hit_corner = corner
	return distance


## The corner the last hit of [method intersect_handle] fell on, an [enum Corner].
func get_hit_corner() -> int:
	return _hit_corner


## The corner handle a point of a window's plane takes, [param point] in
## meters from the center of a frame [param size] large; -1 inside the frame
## or away from its corners.
static func corner_at(point: Vector2, size: Vector2) -> int:
	var out := Vector2(absf(point.x) - size.x * 0.5, absf(point.y) - size.y * 0.5)
	if out.x <= 0.0 and out.y <= 0.0:
		return -1
	if out.x > HANDLE_OUT or out.y > HANDLE_OUT or out.x < -HANDLE_ALONG or out.y < -HANDLE_ALONG:
		return -1
	if point.y >= 0.0:
		return Corner.TOP_LEFT if point.x < 0.0 else Corner.TOP_RIGHT
	return Corner.BOTTOM_LEFT if point.x < 0.0 else Corner.BOTTOM_RIGHT


## Tells the window that a ray is on it this frame: on its corner
## [param corner], or on the interface with -1. The handles show while some
## ray is, and the one under a ray lights up. A router calls it every frame,
## and while it moves the window too.
func hover_handles(corner: int) -> void:
	if not has_corner_handles():
		return
	_hover_mask |= (1 << corner) if corner >= 0 else _HOVER_BODY


## Whether the corner handles are shown, and whether [param corner]'s is lit.
func handle_shown(corner: int) -> bool:
	return not _handles.is_empty() and _handles[corner].visible


func handle_lit(corner: int) -> bool:
	return handle_shown(corner) and _handles[corner].material_override == _handle_material(true)


func _ready() -> void:
	# Only windows look at the rays each frame.
	set_process(not _handles.is_empty())


func _process(_delta: float) -> void:
	# The routers run before their panels in the tree: they have told this frame's hover.
	if _hover_mask != _shown_mask:
		_shown_mask = _hover_mask
		_update_handles()
	_hover_mask = 0


func _update_handles() -> void:
	var shown := _shown_mask > 0
	for corner: int in _handles.size():
		var handle := _handles[corner]
		handle.visible = shown
		handle.material_override = _handle_material(shown and _shown_mask & (1 << corner) != 0)


## Puts the corner handles at the frame's corners, bent around its rounded corners.
func _place_handles() -> void:
	var mesh := _bracket_mesh(corner_radius * size_m.x / size_px.x)
	for corner: int in _handles.size():
		_handles[corner].mesh = mesh
		_handles[corner].position = Vector3(_corner_sign(corner).x * size_m.x * 0.5, _corner_sign(corner).y * size_m.y * 0.5, 0.0)


func _handle_material(hot: bool) -> ShaderMaterial:
	if _handle_materials.is_empty():
		var shader := Shader.new()
		shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always, fog_disabled;
uniform vec4 color : source_color;
void fragment() {
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
"""
		for overlay: bool in [false, true]:
			for lit: bool in [false, true]:
				var material := ShaderMaterial.new()
				material.shader = shader
				material.set_shader_parameter(&"color", HANDLE_HOT_COLOR if lit else HANDLE_COLOR)
				# Over the logic veil, as the panel's own overlay material (set_overlay).
				material.render_priority = Material.RENDER_PRIORITY_MAX if overlay else 0
				_handle_materials.append(material)
	return _handle_materials[(2 if _overlay else 0) + (1 if hot else 0)]


## The top right corner's bracket, around the corner at the origin of a frame
## whose corners are rounded by [param radius] meters: an arm along the top
## edge, an arc around the rounded corner, an arm down the right edge, all
## [constant HANDLE_GAP] outside the frame. The other corners turn it.
static func _bracket_mesh(radius: float) -> ArrayMesh:
	var center := Vector2(-radius, -radius)
	var inner := radius + HANDLE_GAP
	var arm := maxf(HANDLE_ARM - radius, 0.01)
	# Along the bracket, the band's inner edge and its outward normal (Y up, unlike Vector2.UP).
	var points: Array[Vector2] = [Vector2(center.x - arm, center.y + inner)]
	var normals: Array[Vector2] = [Vector2(0.0, 1.0)]
	const STEPS := 8
	for step: int in STEPS + 1:
		var angle := PI / 2.0 * (1.0 - float(step) / STEPS)
		var normal := Vector2(cos(angle), sin(angle))
		points.append(center + normal * inner)
		normals.append(normal)
	points.append(Vector2(center.x + inner, center.y - arm))
	normals.append(Vector2(1.0, 0.0))
	var vertices := PackedVector3Array()
	for index: int in points.size():
		var outer := points[index] + normals[index] * HANDLE_WIDTH
		vertices.append(Vector3(points[index].x, points[index].y, 0.0))
		vertices.append(Vector3(outer.x, outer.y, 0.0))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	return mesh


## Signs of [param corner]'s coordinates from the panel's center.
static func _corner_sign(corner: int) -> Vector2:
	match corner:
		Corner.TOP_LEFT: return Vector2(-1.0, 1.0)
		Corner.TOP_RIGHT: return Vector2(1.0, 1.0)
		Corner.BOTTOM_RIGHT: return Vector2(1.0, -1.0)
	return Vector2(-1.0, -1.0)


## Distance along the ray to the panel's plane, from its front, within
## [param max_distance], with the hit kept in [member _hit_local]; otherwise -1.
func _cast(origin: Vector3, direction: Vector3, max_distance: float) -> float:
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
	_hit_local = Vector2(hit.x, hit.y)
	return distance


## Logic overlays draw after the scene veil and honor depth between panels and cards.
func set_overlay(enabled: bool) -> void:
	if enabled == _overlay: return
	_overlay = enabled
	if not _handles.is_empty(): _update_handles()
	_quad.material_override = _overlay_material if enabled else _scene_material


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
