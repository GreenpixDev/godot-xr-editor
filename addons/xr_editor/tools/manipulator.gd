@tool
class_name XREManipulator
extends Node
## Points at, selects, moves, turns and scales nodes of the edited scene with
## the controllers.
##
## Controls (docs/decisions.md, D-008):
## [br]- Point: the ray stops at the node the trigger would select, and that
## node is outlined. A node the controller tip is inside is outlined instead:
## touching wins over pointing. Nodes the head is inside, like a room, are
## only pointed at. Icons of lights ([XREIcons]) are drawn on top, so they are
## touched and pointed at before geometry.
## [br]- Trigger: select the outlined node, or clear the selection over empty space.
## [br]- Grip: grab the outlined node, which also selects it. A touched node
## follows the hand rigidly. A node grabbed with the ray follows the hand
## with the hand's motion scaled by how much farther from the body the node
## is than the hand (HOMER, Bowman and Hodges 1997): bringing the hand halfway
## to the body brings the node halfway too, and turning the hand turns the
## node about the point the ray hit. Hand motion counts in the rig's space:
## a node held while the user flies ([XRELocomotion]) travels along rigidly.
## [br]- Grip of the other hand while holding: both hands hold the node,
## each at the point it took (gripping away from the node takes the first
## hand's point). Spreading the hands scales the node and turning the line
## between them turns it, about the middle between the two points. When one
## hand lets go, the other holds on at its own point, so a node can be passed
## from hand to hand.
## [br]- Trigger of a holding hand: inverts snapping, like Ctrl on the desktop.
## [br]- A on the right controller: delete the selection, as Delete on the
## desktop, without asking. A node being held is put back first, so that
## undo brings it back where the grab found it.
## [br][br]
## A hand another tool has claimed ([method XREHand.claim]), like the right
## hand touching the [XREPalette], is left alone. The manipulator claims the
## hands that hold a node.
## [br][br]
## Picking happens in [XREPicker] (native). A grab changes the scene only
## through [XREDocument]: a preview every frame, then one undo step when the
## last hand lets go. Lives under the [XRERig], so its outlines render in the headset.

## How far the ray reaches, in meters.
const PICK_DISTANCE := 50.0
## How close the controller tip must come to a node's bounds to touch it, in meters.
const TOUCH_RADIUS := 0.03
## Where the body is assumed to be relative to the head. HOMER scales motion by
## distances from the body, and the rig tracks only the head and hands.
const TORSO_OFFSET := Vector3(0.0, -0.3, 0.0)
## Smallest hand-to-body distance HOMER divides by, in meters.
const MIN_REACH := 0.1
## Smallest span between the hands that two-handed scaling and turning use, in meters.
const MIN_SPAN := 0.05
## Smallest scale factor two hands can apply within one hold.
const MIN_SCALE_FACTOR := 0.01
## Selected nodes beyond this many are not outlined, to bound the work per frame.
const MAX_OUTLINED := 64
const HOVER_COLOR := Color(1.0, 1.0, 1.0)
const SELECTION_COLOR := Color(1.0, 0.5, 0.0)


## What the manipulator keeps for each controller.
class HandState:
	var hand: XREHand
	var picker: XREPicker
	var box: XREBoundsBox
	## The node the hand touches or points at, or null.
	var hover: Node3D
	## [member hover]'s bounds in its own space.
	var hover_bounds: AABB
	## [member hover] is shown by an icon, which the outline follows instead of the bounds.
	var hover_icon := false
	## The hand touches [member hover] rather than points at it.
	var hover_touched := false
	## Where the ray hit [member hover], or the controller tip if touched.
	var hover_point: Vector3
	## From the controller tip to [member hover] along the ray.
	var hover_distance := 0.0
	var holding := false
	## Where the hand holds the grabbed node, in the node's own space: the
	## point stays on the node however the hands move, turn or scale it.
	var grab_point: Vector3
	## HOMER's gain for this hand, fixed when it took hold.
	var gain := 1.0
	## The hand's transform in the rig's space when the current hold began.
	var hold_start: Transform3D

	func _init(controller: XREHand) -> void:
		hand = controller
		picker = XREPicker.new()
		box = XREBoundsBox.new(XREManipulator.HOVER_COLOR)


var _document: XREDocument
var _rig: XRERig
var _icons: XREIcons
var _hands: Array[HandState] = []
var _root: Node

var _selected: Array[Node3D] = []
## Bounds of each of [member _selected] in its own space.
var _selected_bounds: Array[AABB] = []
## Whether each of [member _selected] is shown by an icon ([XREIcons]): its
## outline follows the icon, which grows with distance, instead of its bounds.
var _selected_icons: Array[bool] = []
var _selection_boxes: Array[XREBoundsBox] = []

## Hands holding [member _grabbed]; empty when nothing is grabbed.
var _holders: Array[HandState] = []
var _grabbed: Node3D
## Local transform before the grab: the undo step's start, and what a cancel restores.
var _before: Transform3D
## Global transform of the grabbed node's parent space, fixed for the grab, and its inverse.
var _parent_global: Transform3D
var _to_parent: Transform3D
var _snap: XRESnap
## Global transform the hands put the node at. Snapping applies on top of it,
## so the node moves on smoothly when snapping is turned off mid-drag.
var _free_global: Transform3D
## Scale factor since the grab began.
var _scale := 1.0
## [member _free_global] and [member _scale] when the current hold began, and
## the hold's pivot: the holding hand's grab point, or the middle between
## both. A hold begins with the grab and again whenever a hand joins or lets
## go, so that the node doesn't jump. The transform and the pivot are in the
## rig's space, as hand motion is: a node held while the rig flies travels
## with it, and HOMER's gain scales only what the hands do.
var _hold_start_free: Transform3D
var _hold_start_pivot: Vector3
var _hold_start_scale := 1.0


func _init(document: XREDocument, rig: XRERig, icons: XREIcons) -> void:
	_document = document
	_rig = rig
	_icons = icons
	for hand: XREHand in [rig.left_hand, rig.right_hand]:
		var state := HandState.new(hand)
		add_child(state.box)
		_hands.append(state)


func _enter_tree() -> void:
	var scenario := get_viewport().find_world_3d().scenario
	for state: HandState in _hands:
		state.picker.scenario = scenario
	_document.selection_changed.connect(_on_selection_changed)
	_document.scene_changed.connect(_on_scene_changed)
	_root = _document.get_scene_root()
	_on_selection_changed()


func _exit_tree() -> void:
	_cancel_grab()
	_document.selection_changed.disconnect(_on_selection_changed)
	_document.scene_changed.disconnect(_on_scene_changed)


func _process(_delta: float) -> void:
	var root: Node = _root if is_instance_valid(_root) else null

	for state: HandState in _hands:
		if state.holding and state.hand.grip_released:
			_let_go(state)

	for state: HandState in _hands:
		if state.holding:
			state.hand.hide_ray()
			continue
		if not state.hand.is_free_for(self):
			state.hover = null
			state.hand.show_ray(XREHand.RAY_LENGTH, false)
			continue
		_update_hover(state, root)
		if state.hand.grip_pressed:
			if _holders.is_empty():
				_begin_grab(state)
			elif _holders.size() == 1:
				_join(state)
		elif state.hand.trigger_pressed and _holders.is_empty():
			_select(state.hover)

	var right := _rig.right_hand
	if right.ax_pressed and right.is_free_for(self):
		_delete_selection()

	if not _holders.is_empty():
		_drag()
	_update_outlines()


## HOMER's scale from hand motion to node motion: how many times farther from
## the body [param target] is than [param hand], never below 1.
static func homer_gain(torso: Vector3, hand: Vector3, target: Vector3) -> float:
	return maxf(torso.distance_to(target) / maxf(torso.distance_to(hand), MIN_REACH), 1.0)


## Where [param pivot] goes when the hand moves from [param hand_start] to
## [param hand_now], with the motion scaled by [param gain].
static func moved_pivot(pivot: Vector3, hand_start: Vector3, hand_now: Vector3, gain: float) -> Vector3:
	return pivot + (hand_now - hand_start) * gain


## Where one hand puts a node that was at [param start] when the hand was at
## [param hand_start]: turned with the hand about [param pivot], and moved with
## it, the motion scaled by [param gain]. With a gain of 1 and the pivot at the
## hand, the node is rigidly attached to the hand.
static func one_hand_transform(start: Transform3D, pivot: Vector3, hand_start: Transform3D,
		hand_now: Transform3D, gain: float) -> Transform3D:
	var turn := hand_now.basis.orthonormalized() * hand_start.basis.orthonormalized().inverse()
	return _turned_about(start, pivot, moved_pivot(pivot, hand_start.origin, hand_now.origin, gain), turn)


## How much two hands scale a node: the span between them now over the span
## when the hold began.
static func two_hand_scale(a_start: Vector3, b_start: Vector3, a_now: Vector3, b_now: Vector3) -> float:
	return a_now.distance_to(b_now) / maxf(a_start.distance_to(b_start), MIN_SPAN)


## Where two hands put a node that was at [param start]: turned as the line
## from hand a to hand b turned and scaled by [param factor], both about
## [param pivot], and moved with the midpoint of the hands, the motion scaled
## by [param gain].
static func two_hand_transform(start: Transform3D, pivot: Vector3, a_start: Vector3, b_start: Vector3,
		a_now: Vector3, b_now: Vector3, gain: float, factor: float) -> Transform3D:
	var span_start := b_start - a_start
	var span_now := b_now - a_now
	var turn := Basis.IDENTITY
	if span_start.length() >= MIN_SPAN and span_now.length() >= MIN_SPAN:
		turn = Basis(Quaternion(span_start.normalized(), span_now.normalized()))
	var moved := moved_pivot(pivot, (a_start + b_start) * 0.5, (a_now + b_now) * 0.5, gain)
	return _turned_about(start, pivot, moved, turn * factor)


## [param start] turned and scaled by [param basis] about [param pivot], then
## moved so that the pivot lands on [param moved].
static func _turned_about(start: Transform3D, pivot: Vector3, moved: Vector3, basis: Basis) -> Transform3D:
	return Transform3D(basis, moved) * Transform3D(Basis.IDENTITY, -pivot) * start


func _update_hover(state: HandState, root: Node) -> void:
	var hand := state.hand
	var node: Node3D = null
	if root != null and hand.get_has_tracking_data():
		var aim := hand.global_transform
		var end := aim.origin - aim.basis.z.normalized() * PICK_DISTANCE
		if _icons.find_at_point(aim.origin, TOUCH_RADIUS):
			node = _icons.get_hit_node()
			state.hover_touched = true
			state.hover_point = aim.origin
		elif state.picker.find_at_point(root, aim.origin, TOUCH_RADIUS, _rig.camera.global_position):
			node = state.picker.get_hit_node()
			state.hover_touched = true
			state.hover_point = aim.origin
		elif _icons.cast_segment(aim.origin, end):
			node = _icons.get_hit_node()
			state.hover_touched = false
			state.hover_point = _icons.get_hit_position()
			state.hover_distance = _icons.get_hit_distance()
		elif state.picker.cast_segment(root, aim.origin, end):
			node = state.picker.get_hit_node()
			state.hover_touched = false
			state.hover_point = state.picker.get_hit_position()
			state.hover_distance = state.picker.get_hit_distance()
	if node != state.hover:
		state.hover = node
		if node != null:
			state.hover_bounds = XREPicker.get_local_bounds(node)
			state.hover_icon = _icons.has_icon(node)
	if node != null and not state.hover_touched:
		hand.show_ray(state.hover_distance, true)
	else:
		hand.show_ray(XREHand.RAY_LENGTH, false)


## Makes [param node] the only selected node, or clears the selection for null.
func _select(node: Node3D) -> void:
	var nodes: Array[Node] = []
	if node != null:
		nodes.append(node)
	if _document.get_selection() != nodes:
		_document.select(nodes, XREDocument.Source.TOOL)


func _begin_grab(state: HandState) -> void:
	var node := state.hover
	if node == null or not node.is_inside_tree() \
			or is_zero_approx(node.transform.basis.determinant()) \
			or is_zero_approx(node.global_transform.basis.determinant()):
		return
	_select(node)
	_grabbed = node
	_before = node.transform
	_parent_global = node.global_transform * node.transform.affine_inverse()
	_to_parent = _parent_global.affine_inverse()
	_snap = _document.get_snap()
	_free_global = node.global_transform
	_scale = 1.0
	_join(state)


func _join(state: HandState) -> void:
	if state.hover == _grabbed:
		# Measured on the node as shown, which snapping may have moved off the
		# free transform: the same point of the node either way.
		state.grab_point = _grabbed.global_transform.affine_inverse() * state.hover_point
		state.gain = 1.0 if state.hover_touched else homer_gain(
				_rig.camera.global_position + TORSO_OFFSET, state.hand.global_position, state.hover_point)
	else:
		state.grab_point = _holders[0].grab_point
		state.gain = _holders[0].gain
	state.holding = true
	state.hand.claim(self)
	state.hand.hide_ray()
	_holders.append(state)
	_start_hold()


func _let_go(state: HandState) -> void:
	state.holding = false
	state.hand.unclaim(self)
	_holders.erase(state)
	if _holders.is_empty():
		_end_grab()
	else:
		_start_hold()


func _start_hold() -> void:
	var pivot := _holders[0].grab_point
	if _holders.size() == 2:
		pivot = (pivot + _holders[1].grab_point) * 0.5
	# The hands are children of the rig: their own transforms are in its space.
	_hold_start_free = _rig.global_transform.affine_inverse() * _free_global
	_hold_start_pivot = _hold_start_free * pivot
	_hold_start_scale = _scale
	for state: HandState in _holders:
		state.hold_start = state.hand.transform


func _drag() -> void:
	if not is_instance_valid(_grabbed) or not _grabbed.is_inside_tree():
		_cancel_grab()
		return
	var snapping := _snap.enabled
	for state: HandState in _holders:
		if state.hand.trigger_held:
			snapping = not _snap.enabled

	var moved: Transform3D
	if _holders.size() == 1:
		var state := _holders[0]
		moved = one_hand_transform(_hold_start_free, _hold_start_pivot, state.hold_start, state.hand.transform, state.gain)
	else:
		var a_start := _holders[0].hold_start.origin
		var b_start := _holders[1].hold_start.origin
		var a_now := _holders[0].hand.position
		var b_now := _holders[1].hand.position
		var factor := maxf(two_hand_scale(a_start, b_start, a_now, b_now), MIN_SCALE_FACTOR)
		if snapping:
			factor = _snap.snap_scale_factor(_hold_start_scale * factor) / _hold_start_scale
		_scale = _hold_start_scale * factor
		moved = two_hand_transform(_hold_start_free, _hold_start_pivot, a_start, b_start, a_now, b_now,
				(_holders[0].gain + _holders[1].gain) * 0.5, factor)
	_free_global = _rig.global_transform * moved

	var local := _to_parent * _free_global
	if snapping:
		local = _snap.snap_transform(local)
	_document.preview_transform(_grabbed, local)


## Records the grab as one undo step, unless the node didn't move.
func _end_grab() -> void:
	var valid := is_instance_valid(_grabbed) and _grabbed.is_inside_tree()
	if valid and not _grabbed.transform.is_equal_approx(_before):
		_document.commit_transform(_grabbed, _before, XREDocument.Source.TOOL)
	_grabbed = null
	_snap = null


## Puts the grabbed node back where the grab found it, without an undo step.
func _cancel_grab() -> void:
	for state: HandState in _holders:
		state.holding = false
		state.hand.unclaim(self)
	_holders.clear()
	if is_instance_valid(_grabbed) and _grabbed.is_inside_tree():
		_document.preview_transform(_grabbed, _before)
	_grabbed = null
	_snap = null


func _delete_selection() -> void:
	_cancel_grab()
	var nodes := _document.get_selection()
	if not nodes.is_empty():
		_document.remove_nodes(nodes, XREDocument.Source.TOOL)


func _update_outlines() -> void:
	var head := _rig.camera.global_position
	for i: int in _selected.size():
		var box := _selection_boxes[i]
		if is_instance_valid(_selected[i]) and _selected[i].is_inside_tree():
			_outline(box, _selected[i], _selected_bounds[i], _selected_icons[i], head)
		else:
			box.visible = false
	for state: HandState in _hands:
		# A hovered node deleted this frame has left the tree.
		if not state.holding and is_instance_valid(state.hover) and state.hover.is_inside_tree() \
				and not _selected.has(state.hover):
			_outline(state.box, state.hover, state.hover_bounds, state.hover_icon, head)
		else:
			state.box.visible = false


func _outline(box: XREBoundsBox, node: Node3D, bounds: AABB, icon: bool, head: Vector3) -> void:
	if icon:
		box.show_bounds(XREIcons.icon_transform(node.global_transform, head), XREIcons.MESH_BOUNDS)
	else:
		box.show_bounds(node.global_transform, bounds)


func _on_selection_changed() -> void:
	_selected.clear()
	_selected_bounds.clear()
	_selected_icons.clear()
	for node: Node in _document.get_selection():
		var node_3d := node as Node3D
		if node_3d == null or _selected.size() == MAX_OUTLINED:
			continue
		_selected.append(node_3d)
		_selected_bounds.append(XREPicker.get_local_bounds(node_3d))
		_selected_icons.append(_icons.has_icon(node_3d))
	while _selection_boxes.size() < _selected.size():
		var box := XREBoundsBox.new(SELECTION_COLOR)
		add_child(box)
		_selection_boxes.append(box)
	for i: int in range(_selected.size(), _selection_boxes.size()):
		_selection_boxes[i].visible = false


func _on_scene_changed() -> void:
	_cancel_grab()
	_root = _document.get_scene_root()
	for state: HandState in _hands:
		state.hover = null
	_on_selection_changed()
