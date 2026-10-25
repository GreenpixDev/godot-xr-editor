@tool
class_name XREObjectShortcut
extends Node3D
## The shortcut of the selected object (D-088), with
## [constant XREFeatureSettings.OBJECT_SHORTCUT] on: the trigger held again on
## the selected object ([signal XREManipulator.shortcut_requested]) opens round
## buttons on an arc, as a choice's values are (D-062) — Delete, Rename,
## Blueprint — [constant DISTANCE] along the hand's ray, its center where the
## ray is. The ray picks a button; letting the trigger go does it, or, on none,
## only closes the shortcut. While it is open the rest is darkened, as under an
## input in use (D-061), and it is drawn over everything, so that nothing of
## the scene between it and the head hides it. Both hands are the shortcut's.
## [br][br]
## Delete removes the object through [XREDocument], as X does (D-087). Rename
## opens a keyboard with the object's name: Done renames it, a trigger off the
## keyboard or its × leaves the name as it was. Blueprint opens the object's
## graph or creates one, as the badge's button does (D-085).
## [br][br]
## Lives under the [XRERig], after the [XREManipulator]: a hand let go of in a
## frame has no trigger press left for the manipulator in that frame.

## Emitted by Blueprint, after the shortcut closed: [method XREBlueprints.open_selected] opens or creates the graph.
signal blueprint_requested

## The buttons, left to right on the arc: their names, glyphs ([XRETabIcons]),
## and colors with the ray on them — the badge's red for delete and
## Blueprints' blue for the graph (D-085), the keyboard's for rename.
const DELETE := 0
const RENAME := 1
const BLUEPRINT := 2
const TITLES: Array[String] = ["Delete", "Rename", "Blueprint"]
const GLYPHS: Array[StringName] = [&"trash", &"rename", &"blueprint"]
const LIT_COLORS: Array[Color] = [Color(0.86, 0.2, 0.18), Color("456e91"), Color("1f8fb5")]
const IDLE_COLOR := Color(0.12, 0.13, 0.15, 0.94)
## How far along the ray from the hand the shortcut opens, in meters: nearer
## than most objects, so that it is read at the same size whatever it is for.
const DISTANCE := 0.45
## The arc, as a choice's (D-062): its radius, and a button's, in meters.
const ARC_RADIUS := 0.1
const BUTTON_RADIUS := 0.03
## The ray within this of a button's center, on the shortcut's plane, picks it: half the gap between two.
const PICK_RADIUS := 0.05
## Lit, a button grows this much.
const LIT_SCALE := 1.2
## Drawn after the dimmer and over the scene's widgets, as the graph's inputs are (D-058).
const ON_TOP_OFFSET := 100.0
## Rename's keyboard: this far before the head and below the eyes, as the graph's opens (D-057).
const KEYBOARD_AHEAD := 0.65
const KEYBOARD_DROP := 0.38

## Whether the shortcut may not open now: [method XREBlueprints.is_open], the graph keeps its badge.
var blocked: Callable

var _document: XREDocument
var _rig: XRERig
var _menu: Node3D
var _buttons: Array[Node3D] = []
var _disc_materials: Array[StandardMaterial3D] = []
var _name: Label3D
var _keyboard: XREVirtualKeyboard
var _dimmer: MeshInstance3D
## The hand whose trigger holds the shortcut open, or null.
var _hand: XREHand
## The object the shortcut is for, and the one the keyboard renames.
var _node: Node
var _renamed: Node
var _lit := -1
## Where the ray meets the shortcut's plane, in its space ([method _cast]).
var _plane_point := Vector3.ZERO
## Both hands, and those claimed while the shortcut or its keyboard is open.
var _hands: Array[XREHand] = []
var _claimed: Array[XREHand] = []
var _focused := false


func _init(document: XREDocument, rig: XRERig, theme: Theme = null) -> void:
	_document = document
	_rig = rig
	_hands = [rig.left_hand, rig.right_hand]
	_menu = Node3D.new()
	_menu.name = "Menu"
	_menu.visible = false
	add_child(_menu)
	var disc := QuadMesh.new()
	disc.size = Vector2.ONE * BUTTON_RADIUS * 2.0
	var glyph := QuadMesh.new()
	glyph.size = Vector2.ONE * BUTTON_RADIUS * 1.15
	var disc_texture := XRETabIcons.glyph(&"disc", 128)
	for index: int in TITLES.size():
		# From upper left to upper right, as a choice of three is laid out (D-062).
		var angle := PI * (5.0 / 6.0) - index * PI * (2.0 / 3.0) / (TITLES.size() - 1)
		var button := Node3D.new()
		button.name = TITLES[index]
		button.position = Vector3(cos(angle), sin(angle), 0.0) * ARC_RADIUS
		_menu.add_child(button)
		var material := _material(disc_texture, IDLE_COLOR)
		var face := XRERig.create_vr_mesh(disc, material)
		face.sorting_offset = ON_TOP_OFFSET
		button.add_child(face)
		var symbol := XRERig.create_vr_mesh(glyph, _material(XRETabIcons.glyph(GLYPHS[index], 96), Color.WHITE))
		symbol.position.z = 0.001
		symbol.sorting_offset = ON_TOP_OFFSET + 1.0
		button.add_child(symbol)
		var title := _label(TITLES[index], 20)
		title.position = Vector3(0.0, BUTTON_RADIUS + 0.014, 0.001)
		button.add_child(title)
		_buttons.append(button)
		_disc_materials.append(material)
	# Where the ray was when the trigger went down: on it, no button is picked.
	var dot := XRERig.create_vr_mesh(disc, _material(disc_texture, Color(1.0, 1.0, 1.0, 0.85)))
	dot.scale = Vector3.ONE * 0.2
	dot.sorting_offset = ON_TOP_OFFSET
	_menu.add_child(dot)
	_name = _label("", 18)
	_name.modulate = Color("dfe4ee")
	_name.position = Vector3(0.0, -0.028, 0.001)
	_menu.add_child(_name)
	_keyboard = XREVirtualKeyboard.new(theme)
	_keyboard.name = "RenameKeyboard"
	_keyboard.set_on_top(true)
	_keyboard.set_top_sorting(XREPanelSurface.OVER_FOCUS_SORTING + 1.0)
	_keyboard.applied.connect(_apply_name)
	add_child(_keyboard)


func _enter_tree() -> void:
	_dimmer = XREBlueprints.create_dimmer(XREBlueprints.FOCUS_DIM, Material.RENDER_PRIORITY_MAX)
	_dimmer.name = "ShortcutDimmer"
	_dimmer.visible = false
	_rig.camera.add_child(_dimmer)


func _exit_tree() -> void:
	_close_menu()
	_keyboard.close()
	_finish()
	_dimmer.queue_free()
	_dimmer = null


## Opens the shortcut for [param node], held by the trigger of [param hand]
## ([signal XREManipulator.shortcut_requested]). False if it is open already,
## or [member blocked] says no.
func open(hand: XREHand, node: Node3D) -> bool:
	if _hand != null or _keyboard.is_shown() or not is_instance_valid(node) or not hand.get_has_tracking_data():
		return false
	if blocked.is_valid() and bool(blocked.call()):
		return false
	_hand = hand
	_node = node
	var head := _rig.camera.global_position
	var center := hand.global_position - hand.global_basis.z.normalized() * DISTANCE
	global_transform = Transform3D(XREPanels.facing(center, head, _rig.global_basis.y), center)
	_name.text = str(node.name)
	_menu.visible = true
	_light(-1)
	_focus(true)
	_claim_hands()
	return true


## Whether the buttons are shown, held open by a trigger.
func is_open() -> bool:
	return _hand != null


## Whether Rename's keyboard is shown.
func is_renaming() -> bool:
	return _keyboard.is_shown()


## Whether the rest is darkened: the shortcut or its keyboard is open.
func is_dimming() -> bool:
	return _dimmer != null and _dimmer.visible


## The button the ray is on ([constant DELETE], [constant RENAME], [constant BLUEPRINT]), or -1.
func get_lit() -> int:
	return _lit


## The center of button [param index], global.
func get_button_position(index: int) -> Vector3:
	return _buttons[index].global_position


func get_keyboard() -> XREVirtualKeyboard:
	return _keyboard


func _process(_delta: float) -> void:
	if _hand != null:
		_update_menu()
	elif _keyboard.is_shown():
		_update_keyboard()
	elif _focused:
		_finish()


## Lights the button under the ray; the trigger let go does it.
func _update_menu() -> void:
	if not is_instance_valid(_node) or not _node.is_inside_tree() or not _hand.get_has_tracking_data():
		_close_menu()
		_finish()
		return
	_claim_hands()
	var distance := _cast(_hand.global_position, -_hand.global_basis.z.normalized())
	var picked := -1
	if distance >= 0.0:
		var nearest := PICK_RADIUS
		for index: int in _buttons.size():
			var gap := Vector2(_plane_point.x - _buttons[index].position.x, _plane_point.y - _buttons[index].position.y).length()
			if gap < nearest:
				nearest = gap
				picked = index
	if picked != _lit and picked >= 0:
		XREEditorHaptics.pulse(1 if _hand.tracker == &"right_hand" else 0, 0.18, 0.018)
	_light(picked)
	_hand.show_ray(distance if distance >= 0.0 else XREHand.RAY_LENGTH, picked >= 0)
	for hand: XREHand in _claimed:
		if hand != _hand: hand.show_ray(XREHand.RAY_LENGTH, false)
	if _hand.trigger_held:
		return
	var node := _node
	_close_menu()
	# The hands go back before what the button does: Blueprint opens the graph, which draws them its own way.
	_finish()
	match picked:
		DELETE:
			_document.remove_nodes([node], XREDocument.Source.TOOL)
		RENAME:
			_open_keyboard(node)
		BLUEPRINT:
			blueprint_requested.emit()


## Both rays type on Rename's keyboard, as on the graph's (D-057); a trigger
## off it closes it, the name as it was (D-062).
func _update_keyboard() -> void:
	_claim_hands()
	for hand: XREHand in _claimed:
		if not hand.get_has_tracking_data():
			_keyboard.leave_pointer(hand)
			continue
		var origin := hand.global_position
		var direction := -hand.global_basis.z.normalized()
		var distance := _keyboard.intersect_ray(origin, direction, XREPanels.POINT_DISTANCE)
		if distance >= 0.0:
			_keyboard.hover_pointer(hand, _keyboard.get_hit_pixel())
			hand.show_ray(distance, true)
		else:
			_keyboard.leave_pointer(hand)
			hand.show_ray(XREHand.RAY_LENGTH, false)
		_keyboard.poll_trigger(hand, distance >= 0.0)
		if hand.trigger_pressed and distance < 0.0:
			_keyboard.close()
		if not _keyboard.is_shown():
			_renamed = null
			return


func _open_keyboard(node: Node) -> void:
	_renamed = node
	_keyboard.open_text(str(node.name))
	var head := _rig.camera.global_position
	var up := _rig.global_basis.y.normalized()
	var upright := XREPanels.facing(head - _rig.camera.global_basis.z, head, up)
	var point := head - upright.z * KEYBOARD_AHEAD - up * KEYBOARD_DROP
	_keyboard.global_transform = Transform3D(upright * Basis(Vector3.RIGHT, -XREVirtualKeyboard.TILT), point)
	_focus(true)
	_claim_hands()


## Done on the keyboard: the object takes the name, as a valid node name; an empty or the same one changes nothing.
func _apply_name(text: String) -> void:
	var node := _renamed
	_renamed = null
	var new_name := text.strip_edges().validate_node_name()
	if not is_instance_valid(node) or not node.is_inside_tree() or new_name.is_empty() or new_name == str(node.name):
		return
	_document.set_property(node, &"name", new_name, XREDocument.Source.TOOL)


## Hides the buttons and lets go of the trigger's hand; the hands stay claimed until [method _finish].
func _close_menu() -> void:
	_hand = null
	_node = null
	_menu.visible = false
	_light(-1)


## Gives the hands back and takes the darkness away.
func _finish() -> void:
	for hand: XREHand in _claimed:
		hand.unclaim(self)
	_claimed.clear()
	_focus(false)


## Claims each hand no other tool has: nothing else acts while the shortcut is open.
func _claim_hands() -> void:
	for hand: XREHand in _hands:
		if not hand in _claimed and hand.is_free_for(self):
			hand.claim(self)
			_claimed.append(hand)


## Darkens the rest and draws the rays over it (D-061), or takes that back.
func _focus(enabled: bool) -> void:
	if enabled == _focused:
		return
	_focused = enabled
	if _dimmer != null:
		_dimmer.visible = enabled
	for hand: XREHand in _hands:
		hand.set_overlay(enabled)
		hand.set_on_top(enabled)


func _light(index: int) -> void:
	if index == _lit:
		return
	_lit = index
	for i: int in _buttons.size():
		var lit := i == index
		_disc_materials[i].albedo_color = LIT_COLORS[i] if lit else IDLE_COLOR
		_buttons[i].scale = Vector3.ONE * (LIT_SCALE if lit else 1.0)


## How far along the ray from [param origin] it meets the shortcut's plane, or
## -1; [member _plane_point] is then where, in the shortcut's space. Either
## side counts: the shortcut faces the head, and a hand held out to the side
## may be behind its plane.
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
