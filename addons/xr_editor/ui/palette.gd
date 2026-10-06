@tool
class_name XREPalette
extends Node
## A tray of things to add to the edited scene, held above the left
## controller: CSG primitives to block out a level, and lights
## (docs/decisions.md, D-013, D-014).
##
## The CSG miniatures are the very nodes the tray gives, with the desktop's
## defaults (a CSGSphere3D has 12 segments and 6 rings), at
## [constant MINIATURE_SCALE]. Light miniatures are the icons lights have in
## the scene ([XREIcons]).
## [br][br]
## Controls:
## [br]- X on the left controller: show or hide the tray.
## [br]- Grip of the right hand touching a miniature: take that thing out. The
## new node is where its miniature was and as big as it, and follows the hand
## rigidly; a light is created at its natural scale, as a light has no size.
## Snapping applies as to a grab, and the trigger of the hand inverts it.
## [br]- Letting go of the grip: the node goes into the scene, under the scene
## root, and is selected. Two hands scale it up from there.
## [br]- A while holding it: throw it away.
## [br][br]
## Until the grip lets go, the new node is not part of the scene: it hangs
## under this node. Putting it in is then one [method XREDocument.add_node],
## so that taking something out of the tray is one undo step and one
## operation, however long it was carried.
## [br][br]
## Lives under the [XRERig], before the [XREManipulator]: it claims the right
## hand ([method XREHand.claim]) while the hand touches a miniature or holds a
## new node, and the manipulator then leaves that hand alone.

## Where the tray sits in the left controller's aim space, in meters: above
## the controller, with the first row of miniatures over it.
const TRAY_OFFSET := Vector3(0.0, 0.08, -0.02)
## Distance between neighbouring miniatures, in meters.
const CELL := 0.07
## How close the right controller's tip must come to a miniature's center to
## touch it, in meters: half a cell, so that neighbours don't overlap.
const TOUCH_RADIUS := 0.035
## Scale of the CSG miniatures, and of the nodes taken out: a 1 m box is 3.3 cm.
const MINIATURE_SCALE := 1.0 / 30.0
## Radius of a light's miniature icon, in meters.
const LIGHT_MINIATURE_RADIUS := 0.012
const HOVER_COLOR := Color(1.0, 1.0, 1.0)

const _SHAPE_COLOR := Color(0.8, 0.8, 0.8)
const _LIGHT_COLOR := Color(1.0, 0.85, 0.4)


## One thing the tray offers.
class Item:
	## Class of the node to create; also the node's name in the scene, as the
	## desktop's Add Child Node names it.
	var type: StringName
	## Scale of the node taken out.
	var scale: float
	var miniature: GeometryInstance3D
	## [member miniature]'s bounds in its own space, for the hover outline.
	var bounds: AABB


var _document: XREDocument
var _rig: XRERig
var _items: Array[Item] = []
var _tray: Node3D
var _hover_box: XREBoundsBox
## X turned the tray on; it shows while the left controller is tracked.
var _shown := false
## The item the right hand touches, or null.
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
	_tray = Node3D.new()
	_tray.name = "Tray"
	_tray.visible = false
	add_child(_tray)

	var plate_material := _unshaded(Color(0.1, 0.1, 0.1, 0.6))
	plate_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var plate_mesh := BoxMesh.new()
	plate_mesh.size = Vector3(CELL * 3.0, 0.004, CELL * 2.0)
	var plate := XRERig.create_vr_mesh(plate_mesh, plate_material)
	plate.position = Vector3(0.0, -0.002, -CELL * 0.5)
	_tray.add_child(plate)

	var shape := StandardMaterial3D.new()
	shape.albedo_color = _SHAPE_COLOR
	# Visible in a scene with no light yet.
	shape.emission_enabled = true
	shape.emission = _SHAPE_COLOR * 0.3
	# Half heights of the desktop's defaults: a 1 m box, a cylinder 2 m tall, a sphere 1 m across.
	_add_shape(&"CSGBox3D", "Box", 0.5, shape, Vector3(-CELL, 0.0, 0.0))
	_add_shape(&"CSGCylinder3D", "Cylinder", 1.0, shape, Vector3.ZERO)
	_add_shape(&"CSGSphere3D", "Sphere", 0.5, shape, Vector3(CELL, 0.0, 0.0))
	var light := _unshaded(_LIGHT_COLOR)
	_add_light(&"OmniLight3D", "Omni", light, Vector3(-CELL * 0.5, 0.0, -CELL))
	_add_light(&"SpotLight3D", "Spot", light, Vector3(CELL * 0.5, 0.0, -CELL))

	_hover_box = XREBoundsBox.new(HOVER_COLOR)
	add_child(_hover_box)


func _enter_tree() -> void:
	_document.scene_changed.connect(_discard)


func _exit_tree() -> void:
	_discard()
	_rig.right_hand.unclaim(self)
	_document.scene_changed.disconnect(_discard)


func _process(_delta: float) -> void:
	var left := _rig.left_hand
	var right := _rig.right_hand
	if left.ax_pressed:
		_shown = not _shown
	var tray_shown := _shown and left.get_has_tracking_data()
	_tray.visible = tray_shown
	if tray_shown:
		_tray.global_transform = left.global_transform * Transform3D(Basis.IDENTITY, TRAY_OFFSET)

	_hovered = null
	# The hand stays claimed for the frame that lets go of the node: the A that
	# throws it away must not also delete the selection.
	var was_holding := _held != null
	if _held != null:
		if right.ax_pressed:
			_discard()
		elif not right.grip_held:
			_place()
		else:
			_follow()
	elif tray_shown and right.is_free_for(self) and right.get_has_tracking_data():
		_hovered = _item_at(right.global_position)
		if _hovered != null and right.grip_pressed:
			_take(_hovered)
			_hovered = null

	if was_holding or _held != null or _hovered != null:
		right.claim(self)
	else:
		right.unclaim(self)
	if _hovered != null:
		_hover_box.show_bounds(_hovered.miniature.global_transform, _hovered.bounds)
	else:
		_hover_box.visible = false


## Whether the tray is in view.
func is_shown() -> bool:
	return _tray.visible


## Global transform of the miniature of [param type], or the identity if the
## tray has none. Valid while the tray is shown.
func get_item_transform(type: StringName) -> Transform3D:
	for item: Item in _items:
		if item.type == type:
			return item.miniature.global_transform
	return Transform3D.IDENTITY


## Type of the item the right hand touches, or an empty name.
func get_hovered() -> StringName:
	return _hovered.type if _hovered != null else &""


## The node taken out of the tray and not yet put in the scene, or null.
func get_held() -> Node3D:
	return _held


## Adds a CSG node of [param type] with its default size, [param half_height]
## meters from its center to its bottom, standing at [param position].
func _add_shape(type: StringName, label_text: String, half_height: float, material: Material, position: Vector3) -> void:
	var shape := ClassDB.instantiate(type) as CSGShape3D
	shape.material_override = material
	shape.layers = XRERig.VR_LAYER
	shape.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	shape.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	shape.scale = Vector3.ONE * MINIATURE_SCALE
	shape.position = position + Vector3(0.0, half_height * MINIATURE_SCALE, 0.0)
	_add_item(type, label_text, shape, AABB(Vector3(-0.5, -half_height, -0.5), Vector3(1.0, half_height * 2.0, 1.0)),
			MINIATURE_SCALE, position)


func _add_light(type: StringName, label_text: String, material: Material, position: Vector3) -> void:
	var icon := XRERig.create_vr_mesh(XREIcons.mesh_for(type), material)
	icon.scale = Vector3.ONE * LIGHT_MINIATURE_RADIUS
	icon.position = position + Vector3(0.0, LIGHT_MINIATURE_RADIUS * 1.5, 0.0)
	_add_item(type, label_text, icon, AABB(-Vector3.ONE, Vector3.ONE * 2.0), 1.0, position)


func _add_item(type: StringName, label_text: String, miniature: GeometryInstance3D, bounds: AABB, scale: float,
		position: Vector3) -> void:
	var item := Item.new()
	item.type = type
	item.scale = scale
	item.miniature = miniature
	item.bounds = bounds
	miniature.name = label_text
	_tray.add_child(miniature)

	var label := XRERig.create_vr_label(24, 0.0003)
	label.text = label_text
	label.outline_size = 6
	# On the plate, on the user's side of the miniature.
	label.position = position + Vector3(0.0, 0.006, CELL * 0.4)
	_tray.add_child(label)

	_items.append(item)


## The item whose miniature [param tip] touches, the nearest if several do, or null.
func _item_at(tip: Vector3) -> Item:
	var local := _tray.global_transform.affine_inverse() * tip
	var nearest: Item = null
	var nearest_distance := TOUCH_RADIUS
	for item: Item in _items:
		var distance := local.distance_to(item.miniature.position)
		if distance < nearest_distance:
			nearest = item
			nearest_distance = distance
	return nearest


func _take(item: Item) -> void:
	var root := _document.get_scene_root()
	if root == null:
		return
	# Where the miniature is, turned with the tray; for a light, without the icon's scale.
	var start := Transform3D(_tray.global_basis.orthonormalized() * item.scale, item.miniature.global_position)
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
