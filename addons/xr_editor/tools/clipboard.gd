@tool
class_name XREClipboard
extends Node
## The clipboard on the left hand (D-123), with
## [constant XREFeatureSettings.OBJECT_COPY] at [constant XREFeatureSettings.CLIPBOARD]:
## a pill under the selection's counter tells what it holds — the scene
## objects Copy put there ([method XREDocument.copy_nodes]), or, while the graph
## is open, the blocks its copy button did ([XREBlueprints]) — with two
## buttons the right hand's ray picks: Paste and ×.
## [br][br]
## The trigger held on Paste takes the clipboard along the ray as boxes of its
## nodes, the first one where the ray meets the scene, or
## [constant DROP_DISTANCE] along it; letting go pastes them there, one undo
## step, and selects them. Over the open graph, a box on its plane shows where
## the blocks go, and letting go pastes them there. × empties the clipboard.
## The clipboard is the document's and the graph's, so it outlives a switch of
## scene or graph. Lives under the [XRERig] before the tools that take the
## right hand, so that a button under its ray is the clipboard's.

## Where the pill is in the left hand's space, in meters: under the counter ([XRESelectionCounter]).
const OFFSET := Vector3(0.0, 0.035, 0.04)
## How far the buttons are left and right of the pill's middle, in meters.
const BUTTON_SPACING := 0.065
## The ray within this of a button's middle picks it, in meters.
const BUTTON_RADIUS := 0.018
## Where a paste goes along the ray when it meets nothing, in meters.
const DROP_DISTANCE := 1.5
const PASTE := 0
const CLEAR := 1
const IDLE_COLOR := Color(0.92, 0.93, 0.95)
const LIT_COLOR := XREManipulator.COPY_COLOR
## Boxes drawn for a paste at most.
const MAX_SHOWN := 64

var _document: XREDocument
var _rig: XRERig
var _blueprints: XREBlueprints
var _icons: XREIcons
var _picker := XREPicker.new()
var _label: Label3D
var _buttons: Array[Label3D] = []
## The button under the right hand's ray, or -1; how far along the ray it is.
var _lit := -1
var _lit_distance := 0.0
## The trigger held on Paste carries the clipboard ([method _carry]).
var _carrying := false
var _phantoms: Array[XREBoundsBox] = []
var _shown_count := -1
var _shown_blocks := false


func _init(document: XREDocument, rig: XRERig) -> void:
	_document = document
	_rig = rig
	_label = _make_label("ClipboardPill", OFFSET)
	for index: int in 2:
		var side := -1.0 if index == PASTE else 1.0
		var button := _make_label("Paste" if index == PASTE else "ClipboardClear", OFFSET + Vector3(side * BUTTON_SPACING, 0.0, 0.0))
		button.text = "Paste" if index == PASTE else "×"
		_buttons.append(button)


## The tools it reads: the graph, for its clipboard of blocks, and the icons, for where a paste lands. Either may be null.
func set_sources(blueprints: XREBlueprints, icons: XREIcons) -> void:
	_blueprints = blueprints
	_icons = icons


func _make_label(node_name: String, position: Vector3) -> Label3D:
	var label := XRERig.create_vr_label(28, 0.0006)
	label.name = node_name
	label.position = position
	label.no_depth_test = true
	label.render_priority = Material.RENDER_PRIORITY_MAX
	label.outline_size = 10
	label.outline_modulate = Color(0.08, 0.09, 0.11, 0.9)
	label.modulate = IDLE_COLOR
	label.visible = false
	return label


func _enter_tree() -> void:
	_picker.scenario = get_viewport().find_world_3d().scenario
	_rig.left_hand.add_child(_label)
	for button: Label3D in _buttons:
		_rig.left_hand.add_child(button)


func _exit_tree() -> void:
	_drop(false)
	_label.queue_free()
	for button: Label3D in _buttons:
		button.queue_free()


func _process(_delta: float) -> void:
	var blocks := _blueprints != null and _blueprints.is_open()
	var count := _blueprints.get_clipboard_count() if blocks else _document.get_clipboard_count()
	var shown := _document.features.get_value(XREFeatureSettings.OBJECT_COPY) == XREFeatureSettings.CLIPBOARD and count > 0
	var hand := _rig.right_hand
	if _carrying:
		if not shown or not hand.get_has_tracking_data():
			_drop(false)
		elif not hand.trigger_held:
			_drop(true)
		else:
			_carry(blocks)
		return
	if count != _shown_count or blocks != _shown_blocks:
		_shown_count = count
		_shown_blocks = blocks
		var noun := ("block" if count == 1 else "blocks") if blocks else ("object" if count == 1 else "objects")
		_label.text = "%d %s" % [count, noun]
	_label.visible = shown
	for button: Label3D in _buttons:
		button.visible = shown
	var lit := _pick(hand) if shown and hand.is_free_for(self) and hand.get_has_tracking_data() \
			and _rig.left_hand.get_has_tracking_data() else -1
	if lit != _lit:
		_lit = lit
		for index: int in _buttons.size():
			_buttons[index].modulate = LIT_COLOR if index == lit else IDLE_COLOR
	if lit < 0:
		if hand.get_claimant() == self:
			hand.unclaim(self)
		return
	hand.claim(self)
	hand.show_ray(_lit_distance, true)
	if not hand.trigger_pressed:
		return
	if lit == PASTE:
		_carrying = true
		_carry(blocks)
	elif blocks:
		_blueprints.clear_clipboard()
	else:
		_document.clear_clipboard()


## The button under [param hand]'s ray, within [constant BUTTON_RADIUS] of its
## middle, the nearest along the ray of two; -1 for none.
func _pick(hand: XREHand) -> int:
	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	var best := -1
	for index: int in _buttons.size():
		var along := ray_reach(origin, direction, _buttons[index].global_position, BUTTON_RADIUS)
		if along >= 0.0 and (best < 0 or along < _lit_distance):
			best = index
			_lit_distance = along
	return best


## How far along the ray from [param origin] along [param direction] it passes
## within [param radius] of [param point], or -1 if it doesn't, ahead: for a
## button on the hand, which the other hand's ray picks.
static func ray_reach(origin: Vector3, direction: Vector3, point: Vector3, radius: float) -> float:
	var along := (point - origin).dot(direction)
	if along <= 0.0 or (origin + direction * along).distance_to(point) > radius:
		return -1.0
	return along


## Where the clipboard's first object goes along the right hand's ray: where
## the ray meets the scene, or [constant DROP_DISTANCE] along it.
func _drop_point() -> Vector3:
	var hand := _rig.right_hand
	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	var end := origin + direction * XREManipulator.PICK_DISTANCE
	var root := _document.get_scene_root()
	if _icons != null and _icons.cast_segment(origin, end):
		return _icons.get_hit_position()
	if root != null and _picker.cast_segment(root, origin, end):
		return _picker.get_hit_position()
	return origin + direction * DROP_DISTANCE


## Shows where the clipboard goes as the ray moves: boxes of the objects, or a
## box on the graph's plane for the blocks.
func _carry(blocks: bool) -> void:
	var hand := _rig.right_hand
	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	if blocks:
		var point: Variant = _blueprints.plane_point(origin, direction)
		_show_phantoms(0)
		if point != null:
			var at: Vector3 = point
			_phantom(0).show_bounds(Transform3D(_blueprints.canvas.global_basis, at), AABB(Vector3(-0.15, -0.04, 0.0), Vector3(0.3, 0.08, 0.0)))
			hand.show_ray(origin.distance_to(at), true)
		else:
			hand.show_ray(XREHand.RAY_LENGTH, false)
		return
	var globals := _document.get_clipboard_globals()
	var bounds := _document.get_clipboard_bounds()
	var point := _drop_point()
	var move := Transform3D(Basis.IDENTITY, point - globals[0].origin)
	var count := mini(globals.size(), MAX_SHOWN)
	_show_phantoms(count)
	for index: int in count:
		_phantom(index).show_bounds(move * globals[index], bounds[index])
	hand.show_ray(origin.distance_to(point), true)


## Lets go of the clipboard: pasted where the ray is if [param paste], the copies selected.
func _drop(paste: bool) -> void:
	if not _carrying:
		return
	_carrying = false
	_show_phantoms(0)
	var hand := _rig.right_hand
	if hand.get_claimant() == self:
		hand.unclaim(self)
	if not paste:
		return
	if _blueprints != null and _blueprints.is_open():
		_blueprints.paste_clipboard(hand.global_position, -hand.global_basis.z.normalized())
		return
	var globals := _document.get_clipboard_globals()
	if globals.is_empty():
		return
	var pasted := _document.paste_nodes(Transform3D(Basis.IDENTITY, _drop_point() - globals[0].origin), XREDocument.Source.TOOL)
	if not pasted.is_empty():
		_document.select(pasted, XREDocument.Source.TOOL)


## Box [param index] of a paste, made the first time it is needed.
func _phantom(index: int) -> XREBoundsBox:
	while _phantoms.size() <= index:
		var box := XREBoundsBox.new(LIT_COLOR)
		add_child(box)
		_phantoms.append(box)
	_phantoms[index].visible = true
	return _phantoms[index]


## Hides the boxes from [param count] on.
func _show_phantoms(count: int) -> void:
	for index: int in range(count, _phantoms.size()):
		_phantoms[index].visible = false


## The pill and its buttons, to read what they show and where they are.
func get_label() -> Label3D:
	return _label


func get_button(index: int) -> Label3D:
	return _buttons[index]


## Whether Paste is held and the clipboard follows the ray.
func is_carrying() -> bool:
	return _carrying
