@tool
class_name XREPanelSurface
extends Node3D
## A flat interface shown in the headset: controls laid out in a [SubViewport]
## and drawn onto a quad, with a controller's ray for a mouse
## (docs/decisions.md, D-016). [XREPanels] drives the pointer.
##
## The quad lies in the node's XY plane, centered on its origin, and faces +Z;
## only its front takes the ray. A concave panel ([method set_curve_radius],
## D-043) bends it around a vertical axis in front of it, its edges towards
## the user; the interface keeps its size along the curve. The interface is laid out at
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
## Lists scroll by dragging, as on a phone or in Meta Horizon OS (D-045): a
## press on a list that can scroll — a [ScrollContainer], [Tree], [ItemList]
## or [RichTextLabel], or a control in one — waits. Let go within
## [constant CLICK_SLOP_PX], it is a click; moved further up or down, the
## list follows the ray, with no click, and, let go while moving, glides on
## and slows down. Moved further sideways, a row that scrolls sideways — a
## [ScrollContainer] with horizontal scrolling, as [XRESegmentRow] — follows
## the ray the same way (D-117); without one it is the press it was, and the
## drag goes on as a mouse drag (a slider's).
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
## How much later than the rest a panel drawn over everything is drawn ([method set_on_top]):
## by default as the petals over the cards (D-062); one the graph's cards must not cover,
## after its Front focus (D-075: 100 and up to some 60 more for a card's front parts) and the
## value widgets (150), but before the hands' rays (200) (D-086).
const TOP_SORTING := 100.0
const OVER_FOCUS_SORTING := 190.0

## A pulse ([method pulse]): how long it takes, in seconds, and how much the
## panel grows at its height.
const PULSE_TIME := 0.25
const PULSE_GROWTH := 0.06
## A list let go while dragged glides on: its speed falls by this factor
## per second, and it stops below [constant MIN_GLIDE_SPEED], in interface pixels per second.
const GLIDE_FRICTION := 5.0
const MIN_GLIDE_SPEED := 40.0
## How finely a concave panel is bent: segments of its curve per radian.
const CURVE_SEGMENTS_PER_RADIAN := 24.0

## Handle materials shared by every window: idle and hot, over the scene and over the logic veil.
static var _handle_materials: Array[ShaderMaterial] = []
static var _panel_shader: Shader
static var _top_shader: Shader

## The frame, filling the panel; panels put their controls in it.
var root: PanelContainer
## Corner radius of the frame in interface pixels; the corner handles bend
## around it. Set before [method add_corner_handles].
var corner_radius := CORNER_RADIUS
## Size of the interface, in its own pixels.
var size_px: Vector2
## Size of the quad, in meters; along its curve for a concave panel.
var size_m: Vector2
## Radius of a concave panel's curve in meters, or 0 for a flat one ([method set_curve_radius]).
var curve_radius := 0.0

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
var _on_top := false
var _top_sorting := TOP_SORTING
## Seconds into the pulse, or -1 without one.
var _pulse := -1.0
## Drag scrolling: the list and the sideways row a press waits on, the bar
## being dragged and whether sideways, the one gliding, the content's speed in
## pixels per second, and the last drag.
var _waiting_bar: ScrollBar
var _waiting_row: ScrollBar
var _drag_bar: ScrollBar
var _drag_sideways := false
var _glide_bar: ScrollBar
var _scroll_speed := 0.0
var _drag_from := 0.0
var _drag_usec := 0
var _scene_material: ShaderMaterial
var _overlay_material: ShaderMaterial
var _top_material: ShaderMaterial


## A panel [param logical_size] interface pixels large, each [param pixel_size]
## meters in the headset and rendered [param render_scale] times as fine.
func _init(logical_size: Vector2, pixel_size: float, render_scale: float, theme: Theme) -> void:
	size_px = logical_size
	size_m = logical_size * pixel_size
	_render_scale = render_scale

	root = PanelContainer.new()
	root.name = "Frame"
	root.theme = theme
	root.add_theme_stylebox_override(&"panel", meta_style(META_WINDOW_COLOR, CORNER_RADIUS, 8.0))
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

	# One shader over the scene and over the logic veil, so that a panel's colors don't change
	# when the veil comes (D-043): a StandardMaterial3D with albedo_texture_force_srgb decoded
	# the viewport's sRGB twice and drew the panel almost black.
	_scene_material = _make_panel_material(0)
	_overlay_material = _make_panel_material(Material.RENDER_PRIORITY_MAX)
	_quad = XRERig.create_vr_mesh(_make_mesh(), _scene_material)
	_quad.name = "Quad"
	add_child(_quad)


## A frame in the editor's base color, with rounded corners and an edge in
## its accent color. Panels have the frame of a Meta Horizon OS window instead
## (D-042, D-043), so that the graph's windows look as the tabs' do.
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
	_quad.mesh = _make_mesh()
	if not _handles.is_empty():
		_place_handles()


## Bends the panel around a vertical axis [param radius] meters in front of
## it, so that its edges come towards the user (D-043); 0 makes it flat. Its
## size along the curve, its pixels and its handles stay.
func set_curve_radius(radius: float) -> void:
	radius = maxf(radius, 0.0)
	if is_equal_approx(radius, curve_radius):
		return
	curve_radius = radius
	_quad.mesh = _make_mesh()
	if not _handles.is_empty():
		_place_handles()


## How opaque the panel is drawn, 0 to 1: the launcher fades in by it. It
## doesn't change what takes the ray.
func set_opacity(opacity: float) -> void:
	for material: ShaderMaterial in [_scene_material, _overlay_material]:
		material.set_shader_parameter(&"opacity", clampf(opacity, 0.0, 1.0))


## Where a point [param local] of the flat panel, in meters from its center,
## lies on the panel as it is drawn: bent onto the curve of a concave one.
func bend(local: Vector3) -> Vector3:
	if curve_radius <= 0.0:
		return local
	var angle := local.x / curve_radius
	var depth := curve_radius - local.z
	return Vector3(depth * sin(angle), local.y, curve_radius - depth * cos(angle))


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
## The panel may be scaled uniformly: the distance is along the ray, in meters.
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


## The color the panel draws at interface pixel [param pixel], read back from
## its viewport (D-065): as drawn, before any dimming over it. Slow — it waits
## for the GPU — so only for a click. Null where nothing is drawn, or without
## a picture of the panel, as in a headless run.
func color_at_pixel(pixel: Vector2) -> Variant:
	# The dummy renderer of a headless run keeps no pictures.
	if DisplayServer.get_name() == "headless": return null
	var texture := _viewport.get_texture()
	var image := texture.get_image() if texture != null else null
	if image == null or image.is_empty(): return null
	var at := Vector2i((pixel * Vector2(image.get_size()) / size_px).floor()).clamp(Vector2i.ZERO, image.get_size() - Vector2i.ONE)
	var color := image.get_pixelv(at)
	if color.a <= 0.01: return null
	# Drawn over a clear viewport, a see-through color is kept multiplied by its alpha.
	return Color(minf(color.r / color.a, 1.0), minf(color.g / color.a, 1.0), minf(color.b / color.a, 1.0))


## Gives the panel corner handles: it becomes a window, which a ray moves by
## its corners (D-040). Called once, before the panel is used.
func add_corner_handles() -> void:
	if not _handles.is_empty():
		return
	for corner: int in 4:
		# The mesh comes with the frame's size and curve (_place_handles).
		var handle := XRERig.create_vr_mesh(null, _handle_material(false))
		handle.name = "Handle%s" % (Corner.keys()[corner] as String).to_pascal_case()
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


## Pulses the panel once (D-045): it grows and shrinks back, and shows its
## corner handles meanwhile, so that the user sees where it is, as it appears
## or when it is asked for again while open.
func pulse() -> void:
	_pulse = 0.0
	_update_processing()


## Ends the pulse at once, back to the panel's size: a window taken in hand stops pulsing.
func stop_pulse() -> void:
	if _pulse < 0.0:
		return
	_pulse = -1.0
	scale = Vector3.ONE
	_update_processing()


## Whether the panel is pulsing.
func is_pulsing() -> bool:
	return _pulse >= 0.0


## Whether a list of the panel is being dragged or glides on.
func is_scrolling() -> bool:
	return _drag_bar != null or _glide_bar != null


func _ready() -> void:
	_update_processing()


## Only windows look at the rays each frame; other panels while they pulse or a list glides.
func _update_processing() -> void:
	set_process(not _handles.is_empty() or _pulse >= 0.0 or _glide_bar != null)


func _process(delta: float) -> void:
	if _glide_bar != null:
		var gliding := is_instance_valid(_glide_bar)
		if gliding:
			var before := _glide_bar.value
			_glide_bar.value += _scroll_speed * delta
			_scroll_speed *= exp(-GLIDE_FRICTION * delta)
			# Slowed down, or at an end of the list.
			gliding = absf(_scroll_speed) >= MIN_GLIDE_SPEED and not is_equal_approx(_glide_bar.value, before)
		if not gliding:
			_glide_bar = null
			_update_processing()
	if _pulse >= 0.0:
		_pulse += delta
		var progress := _pulse / PULSE_TIME
		if progress >= 1.0:
			_pulse = -1.0
			scale = Vector3.ONE
			_update_processing()
		else:
			# After whoever places the panel this frame: its router runs before it in the tree.
			scale = Vector3.ONE * (1.0 + PULSE_GROWTH * sin(PI * progress))
			_hover_mask |= _HOVER_BODY
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


## Puts the corner handles at the frame's corners, bent around its rounded
## corners and, on a concave panel, onto its curve.
func _place_handles() -> void:
	var outline := _bracket_outline(corner_radius * size_m.x / size_px.x)
	var angles: Array[float] = [PI / 2.0, 0.0, -PI / 2.0, PI]
	for corner: int in _handles.size():
		var place := Transform2D(angles[corner], Vector2(_corner_sign(corner).x * size_m.x * 0.5, _corner_sign(corner).y * size_m.y * 0.5))
		var vertices := PackedVector3Array()
		for point: Vector2 in outline:
			var flat := place * point
			vertices.append(bend(Vector3(flat.x, flat.y, 0.0)))
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		var mesh := ArrayMesh.new()
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
		_handles[corner].mesh = mesh


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
## [constant HANDLE_GAP] outside the frame, as a triangle strip's points. The
## other corners turn it.
static func _bracket_outline(radius: float) -> PackedVector2Array:
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
	var strip := PackedVector2Array()
	for index: int in points.size():
		strip.append(points[index])
		strip.append(points[index] + normals[index] * HANDLE_WIDTH)
	return strip


## The quad as it is drawn: flat, or bent onto the curve of a concave panel.
func _make_mesh() -> Mesh:
	var quad := QuadMesh.new()
	quad.size = size_m
	if curve_radius <= 0.0:
		return quad
	quad.subdivide_width = maxi(ceili(size_m.x / curve_radius * CURVE_SEGMENTS_PER_RADIAN), 1)
	var arrays := quad.get_mesh_arrays()
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	for index: int in vertices.size():
		var angle := vertices[index].x / curve_radius
		vertices[index] = bend(vertices[index])
		normals[index] = Vector3(-sin(angle), 0.0, cos(angle))
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TANGENT] = null
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


## The panel's material at [param priority]: the scene's (0) or the logic veil's
## (maximum); [param on_top] draws it with no depth test.
func _make_panel_material(priority: int, on_top: bool = false) -> ShaderMaterial:
	if on_top:
		if _top_shader == null:
			_top_shader = Shader.new()
			_top_shader.code = """
shader_type spatial;
render_mode unshaded, depth_draw_always, depth_test_disabled, fog_disabled;
uniform sampler2D panel_texture : source_color, filter_linear;
uniform float opacity = 1.0;
void fragment() {
	vec4 color = texture(panel_texture, UV);
	if (color.a * opacity < 0.01) discard;
	ALBEDO = color.rgb;
	ALPHA = color.a * opacity;
}
"""
		var top := ShaderMaterial.new()
		top.shader = _top_shader
		top.render_priority = priority
		top.set_shader_parameter(&"panel_texture", _viewport.get_texture())
		return top
	if _panel_shader == null:
		_panel_shader = Shader.new()
		_panel_shader.code = """
shader_type spatial;
render_mode unshaded, depth_draw_always, fog_disabled;
uniform sampler2D panel_texture : source_color, filter_linear;
uniform float opacity = 1.0;
void fragment() {
	vec4 color = texture(panel_texture, UV);
	if (color.a * opacity < 0.01) discard;
	ALBEDO = color.rgb;
	ALPHA = color.a * opacity;
}
"""
	var material := ShaderMaterial.new()
	material.shader = _panel_shader
	material.render_priority = priority
	material.set_shader_parameter(&"panel_texture", _viewport.get_texture())
	return material


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
	if curve_radius > 0.0:
		return _cast_curve(local_origin, local_direction, max_distance)
	if local_origin.z <= 0.0 or local_direction.z >= 0.0:
		return -1.0
	var distance := -local_origin.z / local_direction.z
	if distance > max_distance:
		return -1.0
	var hit := local_origin + local_direction * distance
	_hit_local = Vector2(hit.x, hit.y)
	return distance


## [method _cast] onto a concave panel: where the ray leaves the cylinder the
## curve lies on, on the cylinder's half nearer the panel, is the curve's
## front. [member _hit_local] is unrolled: along the curve, and up.
func _cast_curve(origin: Vector3, direction: Vector3, max_distance: float) -> float:
	var axis_z := origin.z - curve_radius
	var a := direction.x * direction.x + direction.z * direction.z
	if a < 0.000001:
		return -1.0
	var b := 2.0 * (origin.x * direction.x + axis_z * direction.z)
	var c := origin.x * origin.x + axis_z * axis_z - curve_radius * curve_radius
	var discriminant := b * b - 4.0 * a * c
	if discriminant < 0.0:
		return -1.0
	var distance := (-b + sqrt(discriminant)) / (2.0 * a)
	if distance < 0.0 or distance > max_distance:
		return -1.0
	var hit := origin + direction * distance
	if hit.z >= curve_radius:
		return -1.0
	_hit_local = Vector2(atan2(hit.x, curve_radius - hit.z) * curve_radius, hit.y)
	return distance


## Logic overlays draw after the scene veil and honor depth between panels and cards.
func set_overlay(enabled: bool) -> void:
	if enabled == _overlay: return
	_overlay = enabled
	if not _handles.is_empty(): _update_handles()
	_quad.material_override = _top_material if _on_top else (_overlay_material if enabled else _scene_material)


## Draws the panel over everything — the scene, cards, other windows — with no
## depth test and sorted last (D-058): for a keyboard that must not sink into
## the graph. Its ray hit wins over nearer cards too ([method is_on_top]).
func set_on_top(enabled: bool) -> void:
	_on_top = enabled
	if enabled and _top_material == null: _top_material = _make_panel_material(Material.RENDER_PRIORITY_MAX, true)
	_quad.sorting_offset = _top_sorting if enabled else 0.0
	_quad.material_override = _top_material if enabled else (_overlay_material if _overlay else _scene_material)


## How much later than the rest the panel is drawn while over everything:
## [constant TOP_SORTING] or [constant OVER_FOCUS_SORTING].
func set_top_sorting(sorting: float) -> void:
	_top_sorting = sorting
	if _on_top: _quad.sorting_offset = sorting


## Whether the panel is drawn over everything ([method set_on_top]).
func is_on_top() -> bool:
	return _on_top


## Global position of the interface pixel [param pixel] on the quad.
func pixel_to_global(pixel: Vector2) -> Vector3:
	var local := Vector3((pixel.x / size_px.x - 0.5) * size_m.x, (0.5 - pixel.y / size_px.y) * size_m.y, 0.0)
	return global_transform * bend(local)


## Where the pointer is, in interface pixels.
func get_pointer() -> Vector2:
	return _pointer


## Whether the pointer's button is down.
func is_pressed() -> bool:
	return _pressed


## Moves the pointer to [param pixel], entering the panel if it was off it.
func pointer_move(pixel: Vector2) -> void:
	if _waiting_bar != null or _waiting_row != null:
		var moved := pixel - _press_position
		if moved.length() < CLICK_SLOP_PX:
			return
		_pinned = false
		var sideways := absf(moved.x) > absf(moved.y)
		var bar := _waiting_row if sideways else _waiting_bar
		_waiting_bar = null
		_waiting_row = null
		if bar != null and is_instance_valid(bar):
			# Up or down a list, or along a row: it follows, and no click is made.
			_drag_bar = bar
			_drag_sideways = sideways
			_drag_from = _press_position.x if sideways else _press_position.y
			_drag_usec = Time.get_ticks_usec()
			_scroll_speed = 0.0
		else:
			# Nothing to scroll that way: the press it was, then a mouse drag.
			_send_button(true)
	if _drag_bar != null:
		_drag(pixel)
		return
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


## Presses or lets go of the pointer's button where the pointer is. A press
## on a list that can scroll waits to see whether it is a click or a drag.
func pointer_button(pressed: bool) -> void:
	if pressed == _pressed or not _inside:
		return
	_pressed = pressed
	if pressed:
		_glide_bar = null
		_press_position = _pointer
		_pinned = true
		var bars := _scroll_bars_at_pointer()
		_waiting_bar = bars[0]
		_waiting_row = bars[1]
		if _waiting_bar == null and _waiting_row == null:
			_send_button(true)
		return
	_pinned = false
	if _waiting_bar != null or _waiting_row != null:
		# Let go where it was pressed: a click.
		_waiting_bar = null
		_waiting_row = null
		_send_button(true)
		_send_button(false)
	elif _drag_bar != null:
		# A drag let go while moving glides on.
		if absf(_scroll_speed) >= MIN_GLIDE_SPEED and Time.get_ticks_usec() - _drag_usec < 100000:
			_glide_bar = _drag_bar
		_drag_bar = null
		_update_processing()
	else:
		_send_button(false)
	pointer_released.emit()


## Scrolls the dragged list so that its content follows the pointer, up or
## down, or along a row sideways, and keeps its speed.
func _drag(pixel: Vector2) -> void:
	_pointer = pixel
	if not is_instance_valid(_drag_bar):
		_drag_bar = null
		return
	var now := Time.get_ticks_usec()
	var along := pixel.x if _drag_sideways else pixel.y
	var moved := along - _drag_from
	var seconds := float(now - _drag_usec) / 1000000.0
	if is_zero_approx(moved):
		if seconds > 0.05:
			_scroll_speed = 0.0
		return
	_drag_bar.value -= moved
	if seconds > 0.0:
		_scroll_speed = lerpf(_scroll_speed, -moved / seconds, 0.6)
	_drag_from = along
	_drag_usec = now


## The vertical scroll bar of the innermost list under the pointer that can
## scroll, and the horizontal one of the innermost row that can scroll
## sideways, each null if there is none; both null on a scroll bar itself.
## A row's bar may be hidden: it scrolls all the same. Found by the controls'
## rectangles, not by the viewport's hover, which a quick press right after
## the ray moved can find a frame old (D-046).
func _scroll_bars_at_pointer() -> Array[ScrollBar]:
	var found: ScrollBar = null
	var row: ScrollBar = null
	var pending: Array[Control] = [root]
	while not pending.is_empty():
		var control: Control = pending.pop_back()
		if not control.is_visible_in_tree() or not control.get_global_rect().has_point(_pointer):
			continue
		var bar := _vertical_bar(control)
		if bar != null and bar.is_visible_in_tree():
			if bar.get_global_rect().has_point(_pointer):
				return [null, null]
			if bar.max_value - bar.page > 0.5:
				found = bar
		if control is ScrollContainer and (control as ScrollContainer).horizontal_scroll_mode != ScrollContainer.SCROLL_MODE_DISABLED:
			var sideways := (control as ScrollContainer).get_h_scroll_bar()
			if sideways.is_visible_in_tree() and sideways.get_global_rect().has_point(_pointer):
				return [null, null]
			if sideways.max_value - sideways.page > 0.5:
				row = sideways
		for child: Node in control.get_children():
			if child is Control and not (child as Control).top_level:
				pending.append(child as Control)
	return [found, row]


## The vertical scroll bar of [param control] if it is a list, or null.
static func _vertical_bar(control: Control) -> ScrollBar:
	if control is ScrollContainer:
		return (control as ScrollContainer).get_v_scroll_bar()
	if control is ItemList:
		return (control as ItemList).get_v_scroll_bar()
	if control is RichTextLabel:
		return (control as RichTextLabel).get_v_scroll_bar()
	if control is Tree:
		for child: Node in control.get_children(true):
			if child is VScrollBar:
				return child as VScrollBar
	return null


## Sends the pointer's button to the interface where the pointer is.
func _send_button(pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = _pointer
	event.global_position = _pointer
	if pressed:
		event.button_mask = MOUSE_BUTTON_MASK_LEFT
		var now := Time.get_ticks_usec()
		event.double_click = now - _last_press_usec < DOUBLE_CLICK_USEC \
				and _pointer.distance_to(_last_press_position) < DOUBLE_CLICK_PX
		# A double click ends the series: the next press starts a new one.
		_last_press_usec = -DOUBLE_CLICK_USEC if event.double_click else now
		_last_press_position = _pointer
	_viewport.push_input(event, true)


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


## Turns the mouse wheel sideways by [param notches] where the pointer is:
## positive scrolls a row to the right (D-117).
func pointer_scroll_sideways(notches: float) -> void:
	if not _inside or is_zero_approx(notches):
		return
	for pressed: bool in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_WHEEL_RIGHT if notches > 0.0 else MOUSE_BUTTON_WHEEL_LEFT
		event.factor = absf(notches)
		event.pressed = pressed
		event.position = _pointer
		event.global_position = _pointer
		_viewport.push_input(event, true)


## Takes the pointer off the panel, letting go of its button first.
func pointer_exit() -> void:
	# A press waiting on a list, or a drag, ends without a click.
	_waiting_bar = null
	_waiting_row = null
	_drag_bar = null
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
