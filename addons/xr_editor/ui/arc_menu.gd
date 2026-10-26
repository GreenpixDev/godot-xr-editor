@tool
class_name XREArcMenu
extends Node3D
## Round buttons on an arc, as a choice's values are (D-062), picked by a ray
## and drawn over everything: the object's shortcut (D-088) and the wire's
## menu (D-090). Its owner places it facing the head, opens it with the
## buttons it needs, lights the one under a hand's ray with [method pick] each
## frame and does the lit one when its trigger lets go. The center, where the
## ray was when the menu opened, picks nothing. Drawn without a depth test,
## after a dimmer at the highest render priority, so that nothing between it
## and the head hides it.

const IDLE_COLOR := Color(0.12, 0.13, 0.15, 0.94)
## The arc, as a choice's (D-062): its radius, and a button's, in meters.
const ARC_RADIUS := 0.1
const BUTTON_RADIUS := 0.03
## The ray within this of a button's center, on the menu's plane, picks it: half the gap between two.
const PICK_RADIUS := 0.05
## Lit, a button grows this much.
const LIT_SCALE := 1.2
## Drawn after the dimmer and over the scene's widgets, as the graph's inputs are (D-058).
const ON_TOP_OFFSET := 100.0

var _buttons: Array[Node3D] = []
var _disc_materials: Array[StandardMaterial3D] = []
var _lit_colors: Array[Color] = []
## The buttons shown now, by index, left to right.
var _shown: Array[int] = []
var _caption: Label3D
var _lit := -1
## Where the ray meets the menu's plane, in its space ([method _cast]).
var _plane_point := Vector3.ZERO


## Builds a button for each of [param titles], with the glyph of
## [param glyphs] ([XRETabIcons]) and the color of [param lit_colors] under the ray.
func _init(titles: Array[String], glyphs: Array[StringName], lit_colors: Array[Color]) -> void:
	visible = false
	_lit_colors = lit_colors
	var disc := QuadMesh.new()
	disc.size = Vector2.ONE * BUTTON_RADIUS * 2.0
	var glyph := QuadMesh.new()
	glyph.size = Vector2.ONE * BUTTON_RADIUS * 1.15
	var disc_texture := XRETabIcons.glyph(&"disc", 128)
	for index: int in titles.size():
		var button := Node3D.new()
		button.name = titles[index]
		add_child(button)
		var material := _material(disc_texture, IDLE_COLOR)
		var face := XRERig.create_vr_mesh(disc, material)
		face.sorting_offset = ON_TOP_OFFSET
		button.add_child(face)
		var symbol := XRERig.create_vr_mesh(glyph, _material(XRETabIcons.glyph(glyphs[index], 96), Color.WHITE))
		symbol.position.z = 0.001
		symbol.sorting_offset = ON_TOP_OFFSET + 1.0
		button.add_child(symbol)
		var title := _label(titles[index], 20)
		title.position = Vector3(0.0, BUTTON_RADIUS + 0.014, 0.001)
		button.add_child(title)
		_buttons.append(button)
		_disc_materials.append(material)
	# Where the ray was when the trigger went down: on it, no button is picked.
	var dot := XRERig.create_vr_mesh(disc, _material(disc_texture, Color(1.0, 1.0, 1.0, 0.85)))
	dot.scale = Vector3.ONE * 0.2
	dot.sorting_offset = ON_TOP_OFFSET
	add_child(dot)
	_caption = _label("", 18)
	_caption.modulate = Color("dfe4ee")
	_caption.position = Vector3(0.0, -0.028, 0.001)
	add_child(_caption)


## Shows the buttons of [param items] (indices of the titles, all of them if
## empty) on the arc, left to right, with [param caption] under the center; nothing is lit.
func open(caption: String, items: Array[int] = []) -> void:
	_shown.clear()
	if items.is_empty():
		for index: int in _buttons.size(): _shown.append(index)
	else: _shown.append_array(items)
	for button: Node3D in _buttons: button.visible = false
	for slot: int in _shown.size():
		# From upper left to upper right, as a choice's values are laid out (D-062); one alone on top.
		var angle := PI * 0.5 if _shown.size() == 1 else PI * (5.0 / 6.0) - slot * PI * (2.0 / 3.0) / (_shown.size() - 1)
		var button := _buttons[_shown[slot]]
		button.position = Vector3(cos(angle), sin(angle), 0.0) * ARC_RADIUS
		button.visible = true
	_caption.text = caption
	visible = true
	_light(-1)


func close() -> void:
	visible = false
	_light(-1)


func is_open() -> bool:
	return visible


## The buttons shown, indices of the titles, left to right.
func get_shown() -> Array[int]:
	return _shown


## The button the ray is on, an index of the titles, or -1.
func get_lit() -> int:
	return _lit


## The center of button [param index], global.
func get_button_position(index: int) -> Vector3:
	return _buttons[index].global_position


## Lights the shown button nearest to where [param hand]'s ray meets the
## menu's plane, within [constant PICK_RADIUS], and pulses the hand as one
## lights up. Returns how far along the ray the plane is, or -1.
func pick(hand: XREHand) -> float:
	var distance := _cast(hand.global_position, -hand.global_basis.z.normalized())
	var picked := -1
	if distance >= 0.0:
		var nearest := PICK_RADIUS
		for index: int in _shown:
			var gap := Vector2(_plane_point.x - _buttons[index].position.x, _plane_point.y - _buttons[index].position.y).length()
			if gap < nearest:
				nearest = gap
				picked = index
	if picked != _lit and picked >= 0:
		XREEditorHaptics.pulse(1 if hand.tracker == &"right_hand" else 0, 0.18, 0.018)
	_light(picked)
	return distance


func _light(index: int) -> void:
	if index == _lit:
		return
	_lit = index
	for i: int in _buttons.size():
		var lit := i == index
		_disc_materials[i].albedo_color = _lit_colors[i] if lit else IDLE_COLOR
		_buttons[i].scale = Vector3.ONE * (LIT_SCALE if lit else 1.0)


## How far along the ray from [param origin] it meets the menu's plane, or
## -1; [member _plane_point] is then where, in the menu's space. Either side
## counts: the menu faces the head, and a hand held out to the side may be
## behind its plane.
func _cast(origin: Vector3, direction: Vector3) -> float:
	var inverse := global_transform.affine_inverse()
	var local_origin := inverse * origin
	var local_direction := inverse.basis * direction
	if absf(local_direction.z) < 0.000001:
		return -1.0
	var distance := -local_origin.z / local_direction.z
	if distance < 0.0:
		return -1.0
	_plane_point = local_origin + local_direction * distance
	return distance


static func _material(texture: Texture2D, color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = texture
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = true
	material.render_priority = Material.RENDER_PRIORITY_MAX
	return material


static func _label(text: String, font_size: int) -> Label3D:
	var label := XRERig.create_vr_label(font_size, 0.0007)
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.text = text
	label.no_depth_test = true
	label.render_priority = Material.RENDER_PRIORITY_MAX
	label.outline_render_priority = Material.RENDER_PRIORITY_MAX - 1
	label.sorting_offset = ON_TOP_OFFSET + 2.0
	return label
