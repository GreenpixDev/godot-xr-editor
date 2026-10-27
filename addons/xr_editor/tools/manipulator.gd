@tool
class_name XREManipulator
extends Node
## Points at, selects, moves, turns and scales nodes of the edited scene with
## the controllers.
##
## Controls (docs/decisions.md, D-008):
## [br]- Point: the ray stops at the node the trigger would select.
## Touching wins over pointing, without a hover outline: the ray, lit, only
## reaches the touched node, and hides with the tip inside it (D-049).
## Nodes the head is inside, like a room, are only pointed at. Icons of lights
## ([XREIcons]) are drawn on top, so they are touched and pointed at before
## geometry. Selection draws white edges ([XREOutline]).
## [br]- Trigger: select the pointed node, or clear the selection over empty space.
## With [constant XREFeatureSettings.OBJECT_SHORTCUT] on, the trigger on a
## node already selected asks for its shortcut ([signal shortcut_requested], D-088),
## for every selected node (D-116).
## [br]- With [constant XREFeatureSettings.SELECT_ADD] at
## [constant XREFeatureSettings.GRIP], while the other hand's grip is held in
## empty space (D-115): the trigger adds the pointed node to the selection, or
## takes it out if it is selected, and keeps the selection over empty space;
## the grip adds the pointed node before grabbing.
## [br]- With [constant XREFeatureSettings.SELECT_AREA] at
## [constant XREFeatureSettings.BRUSH] (D-119): while the trigger is held,
## every node the ray crosses joins the stroke, outlined; letting go selects
## the stroke, or adds it to the selection if the trigger went down while the
## other hand added (D-115), as one selection. A click is a stroke of one
## node, or of none, which clears the selection.
## [br]- Grip: grab the pointed node, which also selects it. Grabbing a
## selected node grabs every selected one (D-115): the others keep their place
## relative to it, as if they were one rigid node. A touched node
## follows the hand rigidly. A node grabbed with the ray follows the hand
## with the hand's motion scaled by how much farther from the body the node
## is than the hand (HOMER, Bowman and Hodges 1997): bringing the hand halfway
## to the body brings the node halfway too, and turning the hand turns the
## node about the point the ray hit. Hand motion counts in the rig's space:
## a node held while the user flies ([XRELocomotion]) travels along rigidly.
## [br]- With [constant XREFeatureSettings.OBJECT_COPY] at
## [constant XREFeatureSettings.GRIP] or [constant XREFeatureSettings.BOTH],
## while the other hand's grip is held in empty space (D-116): the grip takes copies of the selected nodes instead,
## drawn as edges, and the originals stay. Letting go copies them there through
## [method XREDocument.duplicate_nodes], one undo step, and selects the copies;
## let go where they were taken, the copies go beside the originals ([method copy_offset]).
## [br]- Grip of the other hand while holding: both hands hold the node,
## each at the point it took (gripping away from the node takes the first
## hand's point). Spreading the hands scales the node and turning the line
## between them turns it, about the middle between the two points. When one
## hand lets go, the other holds on at its own point, so a node can be passed
## from hand to hand.
## [br]- Trigger of a holding hand: inverts snapping, like Ctrl on the desktop.
## [br]- The delete action (X on the left controller, D-087): delete the
## selection, as Delete on the desktop, without asking; A undoes it
## ([XREUndo]). A node being held is put back first, so that undo brings it
## back where the grab found it.
## [br][br]
## A hand another tool has claimed ([method XREHand.claim]), like the right
## hand touching the [XREPalette] or pointing at a panel ([XREPanels]), is left
## alone, its ray included. The manipulator claims the hands that hold a node.
## The panels leave a hand to it, though their panel is under its ray, when
## it touches a node, points at one in front of the panel within reach, or
## joins a hold ([method takes_pointer], D-047).
## [br][br]
## Picking happens in [XREPicker] (native). A grab changes the scene only
## through [XREDocument]: a preview every frame, then one undo step when the
## last hand lets go. Lives under the [XRERig], so its outlines render in the headset.

## Emitted when the trigger of [param hand] goes down on [param node], a
## selected node, with [constant XREFeatureSettings.OBJECT_SHORTCUT] on (D-088):
## [XREObjectShortcut] opens for it, and the rest of the selection (D-116), and claims the hand.
signal shortcut_requested(hand: XREHand, node: Node3D)

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
## How far from the hand a node in front of a panel takes the ray from the
## panel, in meters ([method takes_pointer], D-047): within reach, so that a
## small node put down by a window is grabbed rather than the window.
const PANEL_REACH := 1.0
## Smallest scale factor two hands can apply within one hold.
const MIN_SCALE_FACTOR := 0.01
## Selected nodes beyond this many are not outlined, to bound the work per frame.
const MAX_OUTLINED := 64
## How many frames a stroke let go of stays shown at most, waiting for the editor's selection (D-119).
const BRUSH_SETTLE_FRAMES := 10
const HOVER_COLOR := Color(1.0, 1.0, 1.0)
const SELECTION_COLOR := Color.WHITE
## The edges of copies being carried (D-116): the light blue of the graph's copy button (D-093).
const COPY_COLOR := Color("a9d4ff")
## Copies let go of within this of where they were taken, in meters, go beside
## the originals instead of over them (D-116), as a block's copy does (D-093).
const COPY_CLICK := 0.02
## The gap between the originals and copies put beside them, in meters.
const COPY_GAP := 0.1


## What the manipulator keeps for each controller.
class HandState:
	var hand: XREHand
	var picker: XREPicker
	## Marks [member hover].
	var outline: XREOutline
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
	## The grip went down in empty space and is still held: with
	## [constant XREFeatureSettings.SELECT_ADD] at [constant XREFeatureSettings.GRIP],
	## the other hand adds to the selection (D-115).
	var adding := false

	func _init(controller: XREHand) -> void:
		hand = controller
		picker = XREPicker.new()
		outline = XREOutline.new(XREManipulator.HOVER_COLOR)


var _document: XREDocument
var _rig: XRERig
var _icons: XREIcons
var _hands: Array[HandState] = []
var _root: Node

var _selected: Array[Node3D] = []
## Bounds of each of [member _selected] in its own space.
var _selected_bounds: Array[AABB] = []
## Whether each of [member _selected] is shown by an icon ([XREIcons]): its
## outline follows the icon, which grows with distance, instead of its faces.
var _selected_icons: Array[bool] = []
## The outline of each of [member _selected], and spare ones after them.
var _selection_outlines: Array[XREOutline] = []

## Hands holding [member _grabbed]; empty when nothing is grabbed.
var _holders: Array[HandState] = []
var _grabbed: Node3D
## The nodes the grab moves (D-115): [member _grabbed] and the other selected
## nodes, but none under another of them, which carries it. Filled when the grab begins.
var _movers: Array[Node3D] = []
## Local transform of each of [member _movers] before the grab: the undo
## step's start, and what a cancel restores.
var _mover_befores: Array[Transform3D] = []
## Global transform of each of [member _movers] in the grabbed node's space
## when the grab began: the grabbed node carries them as one rigid group.
var _mover_offsets: Array[Transform3D] = []
## From global space to the parent space of each of [member _movers], fixed for the grab.
var _mover_to_parents: Array[Transform3D] = []
## The grab carries copies of [member _movers], which stay (D-116).
var _copying := false
## Where the copies are: the global move from the originals, which the grab
## changes instead of the nodes.
var _copy_move: Transform3D
## The grabbed node's global transform when the grab began.
var _grab_start_global: Transform3D
## Bounds of each of [member _movers] in its own space, for its copy's outline.
var _mover_bounds: Array[AABB] = []
## The outline of each copy being carried, and spare ones after them.
var _copy_outlines: Array[XREOutline] = []

## The hand sweeping a brush stroke (D-119), or null.
var _brush_hand: HandState
## The stroke replaces the selection when it ends, rather than adding to it.
var _brush_replace := false
## The node the trigger went down on when the stroke adds: the trigger added
## it or took it out already, and the stroke leaves it as it is.
var _brush_start: Node3D
## The nodes the stroke crossed, in that order, with their bounds in their own
## space and whether each is shown by an icon, as [member _selected] has.
var _brushed: Array[Node3D] = []
var _brushed_bounds: Array[AABB] = []
var _brushed_icons: Array[bool] = []
## The outline of each of [member _brushed], and spare ones after them.
var _brush_outlines: Array[XREOutline] = []
## Frames left to show a stroke let go of until the document tells of the
## selection it made: the editor does in a later frame, and without this the
## selection before the stroke would flash back in between. 0 when none waits.
var _brush_settling := 0
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
		add_child(state.outline)
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
	_clear_brush()
	_document.selection_changed.disconnect(_on_selection_changed)
	_document.scene_changed.disconnect(_on_scene_changed)


func _process(_delta: float) -> void:
	var root: Node = _root if is_instance_valid(_root) else null

	for state: HandState in _hands:
		if state.holding and state.hand.grip_released:
			_let_go(state)
		if not state.hand.grip_held:
			state.adding = false

	for state: HandState in _hands:
		if state.holding:
			state.hand.hide_ray()
			continue
		if not state.hand.is_free_for(self):
			# The tool that claimed the hand draws its ray.
			state.hover = null
			state.adding = false
			if state == _brush_hand:
				_clear_brush()
			continue
		_update_hover(state, root)
		if state == _brush_hand:
			_brush(state)
			if state == _brush_hand:
				continue
		if state.hand.grip_pressed:
			if _holders.is_empty():
				_begin_grab(state)
				state.adding = state.hover == null
			elif _holders.size() == 1:
				_join(state)
		elif state.hand.trigger_pressed and _holders.is_empty():
			if _adds_to_selection(state):
				_toggle(state.hover)
				_begin_brush(state, false)
			elif _opens_shortcut(state.hover):
				shortcut_requested.emit(state.hand, state.hover)
			elif _brushes():
				_begin_brush(state, true)
			else:
				_select(state.hover)

	var delete_hand := _rig.get_action_hand(_document.features, XREFeatureSettings.DELETE)
	if _rig.is_action_pressed(_document.features, XREFeatureSettings.DELETE) and delete_hand.is_free_for(self):
		_delete_selection()

	if not _holders.is_empty():
		_drag()
	_update_outlines()


## Whether the manipulator, after the panels in the tree, should have
## [param hand] although the hand's ray, from [param origin] along
## [param direction], is on a panel [param panel_distance] away (D-047): the
## hand touches a node; or the ray hits a node nearer than the panel and
## within [constant PANEL_REACH]; or the other hand holds a node and this
## hand's grip joins it, to scale and turn it with both hands. [XREPanels]
## then leaves the hand alone.
func takes_pointer(hand: XREHand, origin: Vector3, direction: Vector3, panel_distance: float) -> bool:
	var root: Node = _root if is_instance_valid(_root) else null
	var state := _state_of(hand)
	if root == null or state == null or state.holding:
		return false
	if _holders.size() == 1 and hand.grip_pressed:
		return true
	if _icons.find_at_point(origin, TOUCH_RADIUS) \
			or state.picker.find_at_point(root, origin, TOUCH_RADIUS, _rig.camera.global_position):
		return true
	var end := origin + direction * minf(panel_distance, PANEL_REACH)
	return _icons.cast_segment(origin, end) or state.picker.cast_segment(root, origin, end)


func _state_of(hand: XREHand) -> HandState:
	for state: HandState in _hands:
		if state.hand == hand:
			return state
	return null


## How long the ray of a hand touching a node is (D-049): from the tip
## [param tip] to the node's bounds [param bounds], in its space at
## [param xform], along [param direction] if the ray meets them, otherwise to
## their nearest point; -1 with the tip inside them, where the ray hides.
static func touch_ray_length(tip: Vector3, direction: Vector3, xform: Transform3D, bounds: AABB) -> float:
	var inverse := xform.affine_inverse()
	var local_tip := inverse * tip
	if bounds.has_point(local_tip):
		return -1.0
	var hit: Variant = bounds.intersects_ray(local_tip, inverse.basis * direction)
	var point: Vector3 = hit if hit != null else local_tip.clamp(bounds.position, bounds.end)
	return tip.distance_to(xform * point)


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
	elif node != null:
		# Touched (D-049): a short lit ray to the node, none from inside it.
		var icon := state.hover_icon
		var xform := XREIcons.icon_transform(node.global_transform, _rig.camera.global_position) if icon else node.global_transform
		var length := touch_ray_length(hand.global_position, -hand.global_basis.z.normalized(), xform,
				XREIcons.MESH_BOUNDS if icon else state.hover_bounds)
		if length < 0.0:
			hand.hide_ray()
		else:
			hand.show_ray(length, true)
	else:
		hand.show_ray(XREHand.RAY_LENGTH, false)


## Whether the trigger on [param node] opens its shortcut rather than selects
## it (D-088): the node is selected, alone or with others, for which the
## shortcut acts together (D-116).
func _opens_shortcut(node: Node3D) -> bool:
	if node == null or _document.features.get_value(XREFeatureSettings.OBJECT_SHORTCUT) != XREFeatureSettings.ON:
		return false
	return _document.get_selection().has(node)


## Makes [param node] the only selected node, or clears the selection for null.
func _select(node: Node3D) -> void:
	var nodes: Array[Node] = []
	if node != null:
		nodes.append(node)
	if _document.get_selection() != nodes:
		_document.select(nodes, XREDocument.Source.TOOL)


## Whether the trigger or the grip of [param state]'s hand adds to the
## selection: the other hand's grip is held in empty space, with
## [constant XREFeatureSettings.SELECT_ADD] at [constant XREFeatureSettings.GRIP] (D-115).
func _adds_to_selection(state: HandState) -> bool:
	return _document.features.get_value(XREFeatureSettings.SELECT_ADD) == XREFeatureSettings.GRIP \
			and _other_adding(state)


## Whether the grip of [param state]'s hand takes copies: the other hand's grip
## is held in empty space, with [constant XREFeatureSettings.OBJECT_COPY] at
## [constant XREFeatureSettings.GRIP] or [constant XREFeatureSettings.BOTH] (D-116).
func _copies_on_grab(state: HandState) -> bool:
	return _document.features.get_value(XREFeatureSettings.OBJECT_COPY) in [XREFeatureSettings.GRIP, XREFeatureSettings.BOTH] \
			and _other_adding(state)


## Whether a hand holds its grip down in empty space, which makes the other
## hand add to the selection (D-115): for the selection's counter (D-118).
func is_adding() -> bool:
	for state: HandState in _hands:
		if state.adding:
			return true
	return false


## Whether the hand other than [param state]'s holds its grip down in empty space (D-115).
func _other_adding(state: HandState) -> bool:
	for other: HandState in _hands:
		if other != state and other.adding:
			return true
	return false


## Whether the trigger sweeps a brush stroke (D-119).
func _brushes() -> bool:
	return _document.features.get_value(XREFeatureSettings.SELECT_AREA) == XREFeatureSettings.BRUSH


## Starts a brush stroke of [param state]'s hand, if [method _brushes]: one
## that replaces the selection, from the node under the ray, or one that adds
## to it, the node under the ray left as the trigger made it.
func _begin_brush(state: HandState, replace: bool) -> void:
	if not _brushes():
		return
	_clear_brush()
	_brush_hand = state
	_brush_replace = replace
	_brush_start = null if replace else state.hover
	if replace and state.hover != null:
		_add_brushed(state.hover)


## Adds the node under the ray of the stroke's hand to the stroke; ends the
## stroke when the trigger lets go, or the grip goes down to grab.
func _brush(state: HandState) -> void:
	if not state.hand.trigger_held or state.hand.grip_pressed:
		_end_brush()
		return
	var node := state.hover
	if node == null or node == _brush_start or _brushed.has(node) or (not _brush_replace and _selected.has(node)):
		return
	if _brushed.size() < MAX_OUTLINED:
		_add_brushed(node)


func _add_brushed(node: Node3D) -> void:
	_brushed.append(node)
	_brushed_bounds.append(XREPicker.get_local_bounds(node))
	_brushed_icons.append(_icons.has_icon(node))
	if _brush_outlines.size() < _brushed.size():
		var outline := XREOutline.new(SELECTION_COLOR)
		add_child(outline)
		_brush_outlines.append(outline)


## Selects the stroke, or adds it to the selection, as one selection.
func _end_brush() -> void:
	var nodes: Array[Node] = []
	if not _brush_replace:
		nodes = _document.get_selection()
	for node: Node3D in _brushed:
		if is_instance_valid(node) and node.is_inside_tree() and not nodes.has(node):
			nodes.append(node)
	var changes := _brush_replace or not _brushed.is_empty()
	if not changes or _document.get_selection() == nodes:
		_clear_brush()
		return
	# Shown until the selection changed comes, which clears it.
	_brush_hand = null
	_brush_settling = BRUSH_SETTLE_FRAMES
	_document.select(nodes, XREDocument.Source.TOOL)


## Ends the stroke without selecting anything.
func _clear_brush() -> void:
	_brush_hand = null
	_brush_settling = 0
	_brush_start = null
	_brushed.clear()
	_brushed_bounds.clear()
	_brushed_icons.clear()
	for outline: XREOutline in _brush_outlines:
		outline.clear()


## Adds [param node] to the selection, or takes it out if it is selected; null changes nothing.
func _toggle(node: Node3D) -> void:
	if node == null:
		return
	var nodes := _document.get_selection()
	if nodes.has(node):
		nodes.erase(node)
	else:
		nodes.append(node)
	_document.select(nodes, XREDocument.Source.TOOL)


## Whether a grab can move [param node]: in the tree, and neither its own nor
## its global transform flattened.
static func _movable(node: Node3D) -> bool:
	return node != null and node.is_inside_tree() \
			and not is_zero_approx(node.transform.basis.determinant()) \
			and not is_zero_approx(node.global_transform.basis.determinant())


func _begin_grab(state: HandState) -> void:
	var node := state.hover
	if not _movable(node):
		return
	_copying = _copies_on_grab(state)
	if not _document.get_selection().has(node):
		if _adds_to_selection(state):
			_toggle(node)
		else:
			_select(node)
	_grabbed = node
	_parent_global = node.global_transform * node.transform.affine_inverse()
	_to_parent = _parent_global.affine_inverse()
	_snap = _document.get_snap()
	_free_global = node.global_transform
	_grab_start_global = node.global_transform
	_copy_move = Transform3D.IDENTITY
	_scale = 1.0
	_collect_movers()
	_join(state)


## Fills [member _movers]: the grabbed node first, then the selected nodes in
## the selection's order, leaving out those under another of them.
func _collect_movers() -> void:
	var nodes: Array[Node3D] = [_grabbed]
	for node: Node in _document.get_selection():
		var node_3d := node as Node3D
		if node_3d != _grabbed and _movable(node_3d):
			nodes.append(node_3d)
	var to_grabbed := _grabbed.global_transform.affine_inverse()
	for node: Node3D in nodes:
		var carried := false
		for other: Node3D in nodes:
			if other.is_ancestor_of(node):
				carried = true
				break
		if carried:
			continue
		_movers.append(node)
		_mover_befores.append(node.transform)
		_mover_offsets.append(to_grabbed * node.global_transform)
		_mover_to_parents.append((node.global_transform * node.transform.affine_inverse()).affine_inverse())
		if _copying:
			_mover_bounds.append(XREPicker.get_local_bounds(node))
	while _copying and _copy_outlines.size() < _movers.size():
		var outline := XREOutline.new(COPY_COLOR)
		add_child(outline)
		_copy_outlines.append(outline)


func _clear_movers() -> void:
	_movers.clear()
	_mover_befores.clear()
	_mover_offsets.clear()
	_mover_to_parents.clear()
	_mover_bounds.clear()
	_copying = false
	for outline: XREOutline in _copy_outlines:
		outline.clear()


func _join(state: HandState) -> void:
	# The copies are not where the grabbed node is: a second hand holds them at the first one's point.
	if state.hover == _grabbed and (_holders.is_empty() or not _copying):
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
	var grabbed_global := _parent_global * local
	if _copying:
		_copy_move = grabbed_global * _grab_start_global.affine_inverse()
		return
	for i: int in _movers.size():
		if not is_instance_valid(_movers[i]) or not _movers[i].is_inside_tree():
			continue
		if _movers[i] == _grabbed:
			_document.preview_transform(_grabbed, local)
		else:
			_document.preview_transform(_movers[i], _mover_to_parents[i] * grabbed_global * _mover_offsets[i])


## Records the grab as one undo step of the nodes that moved, if any did, or
## of the copies it carried.
func _end_grab() -> void:
	if _copying:
		_place_copies()
		_grabbed = null
		_snap = null
		_clear_movers()
		return
	var moved: Array[Node3D] = []
	var befores: Array[Transform3D] = []
	for i: int in _movers.size():
		if is_instance_valid(_movers[i]) and _movers[i].is_inside_tree() \
				and not _movers[i].transform.is_equal_approx(_mover_befores[i]):
			moved.append(_movers[i])
			befores.append(_mover_befores[i])
	if not moved.is_empty():
		_document.commit_transforms(moved, befores, XREDocument.Source.TOOL)
	_grabbed = null
	_snap = null
	_clear_movers()


## Puts the grabbed nodes back where the grab found them, without an undo step.
func _cancel_grab() -> void:
	for state: HandState in _holders:
		state.holding = false
		state.hand.unclaim(self)
	_holders.clear()
	for i: int in _movers.size():
		if not _copying and is_instance_valid(_movers[i]) and _movers[i].is_inside_tree():
			_document.preview_transform(_movers[i], _mover_befores[i])
	_grabbed = null
	_snap = null
	_clear_movers()


## Copies the nodes the grab carried copies of where they are now, or beside
## the originals if they are still about where they were taken, and selects the copies.
func _place_copies() -> void:
	var originals: Array[Node] = []
	for node: Node3D in _movers:
		if is_instance_valid(node) and node.is_inside_tree():
			originals.append(node)
	if originals.is_empty():
		return
	var move := _copy_move
	if move.origin.length() < COPY_CLICK and move.basis.is_equal_approx(Basis.IDENTITY):
		move = copy_offset(originals, _rig.camera.global_basis, _rig.global_basis.y)
	var copies := _document.duplicate_nodes(originals, move, XREDocument.Source.TOOL)
	if not copies.is_empty():
		_document.select(copies, XREDocument.Source.TOOL)


## Where copies of [param nodes] go when they are put beside them (D-116): to
## the right of the head, whose basis is [param head], level with the floor
## under [param up], by the width of the nodes' bounds that way and
## [constant COPY_GAP] more, as a global move.
static func copy_offset(nodes: Array[Node], head: Basis, up: Vector3) -> Transform3D:
	var level := up.normalized()
	var right := head.x - level * head.x.dot(level)
	right = right.normalized() if right.length() > 0.001 else head.x.normalized()
	var bounds := AABB()
	var found := false
	for node: Node in nodes:
		var node_3d := node as Node3D
		if node_3d == null or not node_3d.is_inside_tree():
			continue
		var node_bounds := node_3d.global_transform * XREPicker.get_local_bounds(node_3d)
		bounds = bounds.merge(node_bounds) if found else node_bounds
		found = true
	var width := absf(right.x) * bounds.size.x + absf(right.y) * bounds.size.y + absf(right.z) * bounds.size.z
	return Transform3D(Basis.IDENTITY, right * (width + COPY_GAP))


func _delete_selection() -> void:
	_cancel_grab()
	var nodes := _document.get_selection()
	if not nodes.is_empty():
		_document.remove_nodes(nodes, XREDocument.Source.TOOL)


func _update_outlines() -> void:
	var head := _rig.camera.global_position
	# A stroke that replaces the selection shows only what it crossed.
	if _brush_settling > 0:
		_brush_settling -= 1
		if _brush_settling == 0:
			_clear_brush()
	var replacing := (_brush_hand != null or _brush_settling > 0) and _brush_replace
	for i: int in _selected.size():
		var outline := _selection_outlines[i]
		if not replacing and is_instance_valid(_selected[i]) and _selected[i].is_inside_tree():
			_outline(outline, _selected[i], _selected_bounds[i], _selected_icons[i], head)
		else:
			outline.clear()
	if _copying:
		for i: int in _movers.size():
			if is_instance_valid(_movers[i]) and _movers[i].is_inside_tree():
				_copy_outlines[i].show_node(_movers[i], _mover_bounds[i], _copy_move)
			else:
				_copy_outlines[i].clear()
	for i: int in _brushed.size():
		if is_instance_valid(_brushed[i]) and _brushed[i].is_inside_tree():
			_outline(_brush_outlines[i], _brushed[i], _brushed_bounds[i], _brushed_icons[i], head)
		else:
			_brush_outlines[i].clear()
	for state: HandState in _hands:
		state.outline.clear()


func _outline(outline: XREOutline, node: Node3D, bounds: AABB, icon: bool, head: Vector3) -> void:
	if icon:
		outline.show_box(XREIcons.icon_transform(node.global_transform, head), XREIcons.MESH_BOUNDS)
	else:
		outline.show_node(node, bounds)


func _on_selection_changed() -> void:
	if _brush_settling > 0:
		_clear_brush()
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
	while _selection_outlines.size() < _selected.size():
		var outline := XREOutline.new(SELECTION_COLOR)
		add_child(outline)
		_selection_outlines.append(outline)
	# The nodes may be the same, but what is drawn of them may not: look at them afresh.
	for outline: XREOutline in _selection_outlines:
		outline.clear()


func _on_scene_changed() -> void:
	_cancel_grab()
	_clear_brush()
	_root = _document.get_scene_root()
	for state: HandState in _hands:
		state.hover = null
	_on_selection_changed()
