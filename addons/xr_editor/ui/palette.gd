@tool
class_name XREPalette
extends Node
## Things to add to the edited scene: CSG primitives to block out a level, and
## lights (docs/decisions.md, D-013, D-014). Since D-045 they are in a window
## of their own, Objects ([XREObjectsTab]), opened from the launcher like the
## other tabs: a see-through window with a 3D miniature in front of each of
## its cells, named under it. Before, they were a tray above the left
## controller, shown with the launcher on X.
##
## The CSG miniatures are the very nodes the window gives, with the desktop's
## defaults (a CSGSphere3D has 12 segments and 6 rings), at
## [constant MINIATURE_SCALE]. Light miniatures are the icons lights have in
## the scene ([XREIcons]).
## [br][br]
## Controls:
## [br]- The right hand touching a miniature, or its ray on one: the
## miniature is outlined and its cell lit.
## [br]- Grip then: take that thing out. The new node is where its miniature
## was and as big as it, and follows the hand rigidly, the far one taken by
## the ray too; a light is created at its natural scale, as a light has no
## size. Snapping applies as to a grab, and the trigger of the hand inverts it.
## [br]- Letting go of the grip: the node goes into the scene, under the scene
## root, and is selected. Two hands scale it up from there.
## [br]- A while holding it: throw it away.
## [br][br]
## Until the grip lets go, the new node is not part of the scene: it hangs
## under this node. Putting it in is then one [method XREDocument.add_node],
## so that taking something out is one undo step and one operation, however
## long it was carried.
## [br][br]
## Lives under the [XRERig], before the [XREPanels] and the [XREManipulator]:
## it claims the right hand ([method XREHand.claim]) while the hand is on a
## miniature or holds a new node, and they then leave that hand alone, so
## that a grip on a miniature doesn't move its window.

## The things offered, in the window's order: the class of the node to
## create, also its name in the scene, as the desktop's Add Child Node names
## it; and the name under its cell.
const ITEMS: Array[Array] = [
	[&"CSGBox3D", "Box"],
	[&"CSGCylinder3D", "Cylinder"],
	[&"CSGSphere3D", "Sphere"],
	[&"OmniLight3D", "Omni light"],
	[&"SpotLight3D", "Spot light"],
]
## How close the right controller's tip must come to a miniature's center to
## touch it, and how close the right ray must pass by it, in meters.
const TOUCH_RADIUS := 0.035
const RAY_RADIUS := 0.03
## How far the right ray reaches miniatures, in meters.
const RAY_LENGTH := 5.0
## How far in front of its window's cell a miniature hangs, in meters.
const DEPTH := 0.04
## Scale of the CSG miniatures, and of the nodes taken out: a 1 m box is 3.3 cm.
const MINIATURE_SCALE := 1.0 / 30.0
## Radius of a light's miniature icon, in meters.
const LIGHT_MINIATURE_RADIUS := 0.012
const HOVER_COLOR := Color(1.0, 1.0, 1.0)

const _SHAPE_COLOR := Color(0.8, 0.8, 0.8)
const _LIGHT_COLOR := Color(1.0, 0.85, 0.4)


## One thing offered.
class Item:
	## Class of the node to create; also the node's name in the scene.
	var type: StringName
	## Scale of the node taken out, and of its miniature.
	var scale: float
	var miniature_scale: float
	var miniature: GeometryInstance3D
	## [member miniature]'s bounds in its own space, for the hover outline.
	var bounds: AABB


var _document: XREDocument
var _rig: XRERig
## Has a hand before the palette when the hand touches a node of the scene or
## points at one in front of a miniature ([method set_manipulator]).
var _manipulator: XREManipulator
var _items: Array[Item] = []
## Holds the miniatures; shown while the window is.
var _shelf: Node3D
## The Objects window the miniatures hang in, and its tab, or null.
var _host: XREPanelSurface
var _host_tab: XREObjectsTab
var _hover_box: XREBoundsBox
## The item the right hand is on, or null.
var _hovered: Item

## The node taken out and not yet let go, or null.
var _held: Node3D
## [member _held]'s global transform relative to the right hand, fixed when it was taken.
var _hold: Transform3D
## Global transform of the scene root's space, fixed when the node was taken, and its inverse.
var _parent_global: Transform3D
var _to_parent: Transform3D
var _snap: XRESnap
## Where [member _held] goes in the scene root's space when it is let go.
var _local: Transform3D


func _init(document: XREDocument, rig: XRERig) -> void:
	_document = document
	_rig = rig

	# Children of a plain Node: their transforms are global.
	_shelf = Node3D.new()
	_shelf.name = "Shelf"
	_shelf.visible = false
	add_child(_shelf)

	var shape := StandardMaterial3D.new()
	shape.albedo_color = _SHAPE_COLOR
	# Visible in a scene with no light yet, and over a see-through window (D-045).
	shape.emission_enabled = true
	shape.emission = _SHAPE_COLOR * 0.6
	var light := _unshaded(_LIGHT_COLOR)
	for entry: Array in ITEMS:
		var type: StringName = entry[0]
		if ClassDB.is_parent_class(type, &"CSGShape3D"):
			_add_shape(type, entry[1], shape)
		else:
			_add_light(type, entry[1], light)

	_hover_box = XREBoundsBox.new(HOVER_COLOR)
	add_child(_hover_box)


func _enter_tree() -> void:
	_document.scene_changed.connect(_discard)


func _exit_tree() -> void:
	_discard()
	_rig.right_hand.unclaim(self)
	_document.scene_changed.disconnect(_discard)


## Lets [param manipulator], after the palette in the tree, have the right
## hand when it touches a node of the scene, or its ray hits one before a
## miniature (D-048): a node put down by the Objects window is grabbed, not
## the miniature behind it.
func set_manipulator(manipulator: XREManipulator) -> void:
	_manipulator = manipulator


## Hangs the miniatures in [param window], in front of the cells of its tab
## [param tab]; null for both takes them away, as when the window closes.
func set_host(window: XREPanelSurface, tab: XREObjectsTab) -> void:
	_host = window
	_host_tab = tab


func _process(_delta: float) -> void:
	var right := _rig.right_hand
	var shown := _place_miniatures()

	var hovered := _hovered
	_hovered = null
	var hit_distance := -1.0
	# The hand stays claimed for the frame that lets go of the node: the A that
	# throws it away must not also delete the selection.
	var was_holding := _held != null
	if _held != null:
		if _rig.is_action_pressed(_document.features, XREFeatureSettings.DELETE):
			_discard()
		elif not right.grip_held:
			_place()
		else:
			_follow()
	elif shown and _may_take(right) and right.get_has_tracking_data():
		var origin := right.global_position
		var direction := -right.global_basis.z.normalized()
		_hovered = _item_at(origin)
		if _hovered == null:
			_hovered = _item_on_ray(origin, direction)
			if _hovered != null:
				hit_distance = (_hovered.miniature.global_position - origin).dot(direction)
		# A node of the scene touched, or in front of the miniature on the ray, is the manipulator's (D-048).
		if _hovered != null and is_instance_valid(_manipulator) \
				and _manipulator.takes_pointer(right, origin, direction, maxf(hit_distance, 0.0)):
			_hovered = null
			hit_distance = -1.0
		if _hovered != null and right.grip_pressed:
			_take(_hovered)
			_hovered = null

	if was_holding or _held != null or _hovered != null:
		right.claim(self)
		if hit_distance >= 0.0:
			right.show_ray(hit_distance, true)
		elif _hovered != null:
			# Touched, as a node of the scene is (D-049): a short lit ray to it, none from inside it.
			var length := XREManipulator.touch_ray_length(right.global_position, -right.global_basis.z.normalized(),
					_hovered.miniature.global_transform, _hovered.bounds)
			if length < 0.0:
				right.hide_ray()
			else:
				right.show_ray(length, true)
		else:
			right.show_ray(XREHand.RAY_LENGTH, false)
	else:
		right.unclaim(self)
	if _hovered != null:
		_hover_box.show_bounds(_hovered.miniature.global_transform, _hovered.bounds)
	else:
		_hover_box.visible = false
	if _hovered != hovered and is_instance_valid(_host_tab):
		_host_tab.set_hovered(_items.find(_hovered))


## Whether the palette may look for a miniature under [param hand]: no tool
## has it, or the panels, whose ray is on the Objects window behind the
## miniatures, let it go (D-046) — otherwise a grip there takes the window.
func _may_take(hand: XREHand) -> bool:
	# While the other hand holds a node, this hand's grip joins it to scale it (D-047).
	var other := _rig.left_hand if hand == _rig.right_hand else _rig.right_hand
	if other.get_claimant() is XREManipulator:
		return false
	if hand.is_free_for(self):
		return true
	var panels := hand.get_claimant() as XREPanels
	return panels != null and panels.yields_hand(hand)


## Whether the miniatures are in view: their window is open and shown.
func is_shown() -> bool:
	return _shelf.visible


## Global transform of the miniature of [param type], or the identity if
## there is none. Valid while the miniatures are shown.
func get_item_transform(type: StringName) -> Transform3D:
	for item: Item in _items:
		if item.type == type:
			return item.miniature.global_transform
	return Transform3D.IDENTITY


## Type of the item the right hand is on, or an empty name.
func get_hovered() -> StringName:
	return _hovered.type if _hovered != null else &""


## The node taken out and not yet put in the scene, or null.
func get_held() -> Node3D:
	return _held


## Puts each miniature in front of its window's cell, turned as the window is;
## shows them while the window is shown. Returns whether they are.
func _place_miniatures() -> bool:
	var shown := is_instance_valid(_host) and is_instance_valid(_host_tab) and _host.is_shown() and _host.is_visible_in_tree()
	_shelf.visible = shown
	if not shown:
		return false
	var basis := _host.global_basis.orthonormalized()
	var front := basis.z * DEPTH
	for index: int in _items.size():
		var item := _items[index]
		var center := _host.pixel_to_global(_host_tab.get_cell_center(index))
		item.miniature.global_transform = Transform3D(basis * Basis.from_scale(Vector3.ONE * item.miniature_scale), center + front)
	return true


## Adds a CSG node of [param type] with its default size, centered on its cell.
func _add_shape(type: StringName, label_text: String, material: Material) -> void:
	var shape := ClassDB.instantiate(type) as CSGShape3D
	shape.material_override = material
	shape.layers = XRERig.VR_LAYER
	shape.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	shape.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	# A cylinder 2 m tall, a box and a sphere 1 m across.
	var half_height := 1.0 if type == &"CSGCylinder3D" else 0.5
	_add_item(type, label_text, shape, AABB(Vector3(-0.5, -half_height, -0.5), Vector3(1.0, half_height * 2.0, 1.0)),
			MINIATURE_SCALE, MINIATURE_SCALE)


func _add_light(type: StringName, label_text: String, material: Material) -> void:
	var icon := XRERig.create_vr_mesh(XREIcons.mesh_for(type), material)
	_add_item(type, label_text, icon, AABB(-Vector3.ONE, Vector3.ONE * 2.0), 1.0, LIGHT_MINIATURE_RADIUS)


func _add_item(type: StringName, label_text: String, miniature: GeometryInstance3D, bounds: AABB, scale: float,
		miniature_scale: float) -> void:
	var item := Item.new()
	item.type = type
	item.scale = scale
	item.miniature_scale = miniature_scale
	item.miniature = miniature
	item.bounds = bounds
	miniature.name = label_text.to_pascal_case()
	_shelf.add_child(miniature)
	_items.append(item)


## The item whose miniature [param tip] touches, the nearest if several do, or null.
func _item_at(tip: Vector3) -> Item:
	var nearest: Item = null
	var nearest_distance := TOUCH_RADIUS
	for item: Item in _items:
		var distance := tip.distance_to(item.miniature.global_position)
		if distance < nearest_distance:
			nearest = item
			nearest_distance = distance
	return nearest


## The item whose miniature the ray from [param origin] along [param direction]
## passes nearest, within [constant RAY_RADIUS] and the ray's reach, or null.
func _item_on_ray(origin: Vector3, direction: Vector3) -> Item:
	var nearest: Item = null
	var nearest_along := RAY_LENGTH
	for item: Item in _items:
		var offset := item.miniature.global_position - origin
		var along := offset.dot(direction)
		if along <= 0.0 or along >= nearest_along:
			continue
		if (offset - direction * along).length_squared() <= RAY_RADIUS * RAY_RADIUS:
			nearest = item
			nearest_along = along
	return nearest


func _take(item: Item) -> void:
	var root := _document.get_scene_root()
	if root == null:
		return
	# Where the miniature is, turned with the window; a light at its natural scale.
	var turned := item.miniature.global_basis.orthonormalized()
	var start := Transform3D(turned * item.scale, item.miniature.global_position)
	_held = ClassDB.instantiate(item.type) as Node3D
	_held.name = item.type
	_hold = _rig.right_hand.global_transform.affine_inverse() * start
	var root_3d := root as Node3D
	_parent_global = root_3d.global_transform if root_3d != null else Transform3D.IDENTITY
	_to_parent = _parent_global.affine_inverse()
	_snap = _document.get_snap()
	add_child(_held)
	_follow()


func _follow() -> void:
	var hand := _rig.right_hand
	var local := _to_parent * hand.global_transform * _hold
	if _snap.enabled != hand.trigger_held:
		local = _snap.snap_transform(local)
	_local = local
	_held.global_transform = _parent_global * local


## Puts the held node into the scene where it is shown, and selects it.
func _place() -> void:
	var node := _held
	_held = null
	_snap = null
	remove_child(node)
	var root := _document.get_scene_root()
	if root == null:
		node.free()
		return
	node.transform = _local
	_document.add_node(node, root, XREDocument.Source.TOOL)
	_document.select([node], XREDocument.Source.TOOL)


## Throws the held node away, if there is one; nothing is recorded.
func _discard() -> void:
	if _held == null:
		return
	_held.queue_free()
	_held = null
	_snap = null


func _unshaded(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	return material
