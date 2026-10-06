@tool
class_name XREIcons
extends Node
## Icons in the headset for nodes of the edited scene that have no geometry to
## point at: lights (docs/decisions.md, D-014). A bulb for an omni light, a cone
## open the way the light shines for spot and directional lights, in the
## light's color.
##
## Icons are drawn on top of everything and keep the same apparent size at any
## distance, as icons in the desktop viewport do. What is drawn on top is
## picked first: [XREManipulator] asks [method find_at_point] and
## [method cast_segment] before it picks geometry, so a light inside a lamp
## shade or behind a wall can be selected and grabbed.
## [br][br]
## The list of icons follows the scene through the tree's
## [signal SceneTree.node_added] and [signal SceneTree.node_removed]; nothing
## searches the tree per frame. Lives under the [XRERig], so icons render in the headset only.

## Icon radius per meter between the head and the icon: about 1° of view.
const RADIUS_PER_METER := 0.0175
## Smallest icon radius, in meters, so that a light near the head stays touchable.
const MIN_RADIUS := 0.015
## Bounds of every icon mesh in its own space: one meter in radius.
const MESH_BOUNDS := AABB(Vector3(-1.0, -1.0, -1.0), Vector3(2.0, 2.0, 2.0))

## Unit-radius icon meshes, shared by all icons and the palette's miniatures.
static var _bulb: SphereMesh
static var _cone: ArrayMesh


## One light and its icon.
class Icon:
	var light: Light3D
	var mesh: MeshInstance3D
	var material: StandardMaterial3D


var _document: XREDocument
var _rig: XRERig
var _root: Node
var _icons: Array[Icon] = []
## Only for [method XREPicker.get_selectable_node].
var _picker := XREPicker.new()

var _hit_node: Node3D
var _hit_position: Vector3
var _hit_distance := 0.0


func _init(document: XREDocument, rig: XRERig) -> void:
	_document = document
	_rig = rig


func _enter_tree() -> void:
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)
	_document.scene_changed.connect(_on_scene_changed)
	_on_scene_changed()


func _exit_tree() -> void:
	get_tree().node_added.disconnect(_on_node_added)
	get_tree().node_removed.disconnect(_on_node_removed)
	_document.scene_changed.disconnect(_on_scene_changed)
	_clear()


func _process(_delta: float) -> void:
	var head := _rig.camera.global_position
	for icon: Icon in _icons:
		var light := icon.light
		var shown := light.is_visible_in_tree()
		icon.mesh.visible = shown
		if not shown:
			continue
		icon.mesh.global_transform = icon_transform(light.global_transform, head)
		if icon.material.albedo_color != light.light_color:
			icon.material.albedo_color = light.light_color


## Radius of an icon at [param center] seen from [param head].
static func radius_at(center: Vector3, head: Vector3) -> float:
	return maxf(center.distance_to(head) * RADIUS_PER_METER, MIN_RADIUS)


## Global transform of the icon of a light whose global transform is
## [param light], seen from [param head]: the light's place and turn, scaled
## to the icon's radius. The icon mesh then fills [constant MESH_BOUNDS].
static func icon_transform(light: Transform3D, head: Vector3) -> Transform3D:
	return Transform3D(light.basis.orthonormalized() * radius_at(light.origin, head), light.origin)


## Whether [param node] is shown by an icon. Not for per-frame use: it looks through all icons.
func has_icon(node: Node) -> bool:
	for icon: Icon in _icons:
		if icon.light == node:
			return true
	return false


## The icon mesh for a light of class [param type], one meter in radius: a
## sphere, or a cone open to -Z for lights that shine one way.
static func mesh_for(type: StringName) -> Mesh:
	if type == &"SpotLight3D" or type == &"DirectionalLight3D":
		return _cone_mesh()
	if _bulb == null:
		_bulb = SphereMesh.new()
		_bulb.radius = 1.0
		_bulb.height = 2.0
		_bulb.radial_segments = 16
		_bulb.rings = 8
	return _bulb


## Finds the icon nearest along the segment from [param from] to [param to].
## Returns whether there is one; the getters describe it.
func cast_segment(from: Vector3, to: Vector3) -> bool:
	_clear_hit()
	var length := from.distance_to(to)
	if is_zero_approx(length):
		return false
	var direction := (to - from) / length
	var head := _rig.camera.global_position
	for icon: Icon in _icons:
		if not icon.light.is_visible_in_tree():
			continue
		var center := icon.light.global_position
		var radius := radius_at(center, head)
		var along := (center - from).dot(direction)
		var off_squared := from.distance_squared_to(center) - along * along
		if off_squared > radius * radius:
			continue
		# From inside the icon, the hit is where the segment starts.
		var distance := maxf(along - sqrt(radius * radius - off_squared), 0.0)
		if distance > length or (_hit_node != null and distance >= _hit_distance):
			continue
		var node := _picker.get_selectable_node(icon.light, _root)
		if node != null:
			_hit_node = node
			_hit_position = center
			_hit_distance = distance
	return _hit_node != null


## Finds the icon nearest to [param point] among those no farther than
## [param radius] from it. Returns whether there is one.
func find_at_point(point: Vector3, radius: float) -> bool:
	_clear_hit()
	var head := _rig.camera.global_position
	for icon: Icon in _icons:
		if not icon.light.is_visible_in_tree():
			continue
		var center := icon.light.global_position
		var distance := maxf(point.distance_to(center) - radius_at(center, head), 0.0)
		if distance > radius or (_hit_node != null and distance >= _hit_distance):
			continue
		var node := _picker.get_selectable_node(icon.light, _root)
		if node != null:
			_hit_node = node
			_hit_position = point
			_hit_distance = distance
	return _hit_node != null


## The node to select for the last hit, or null.
func get_hit_node() -> Node3D:
	return _hit_node


## The light's position for [method cast_segment], the point for [method find_at_point].
func get_hit_position() -> Vector3:
	return _hit_position


## From the start of the segment to the icon's surface, or from the point to it.
func get_hit_distance() -> float:
	return _hit_distance


func _clear_hit() -> void:
	_hit_node = null
	_hit_position = Vector3.ZERO
	_hit_distance = 0.0


func _on_scene_changed() -> void:
	_clear()
	_root = _document.get_scene_root()
	if _root == null:
		return
	if _root is Light3D:
		_add(_root as Light3D)
	for node: Node in _root.find_children("*", "Light3D", true, false):
		_add(node as Light3D)


func _on_node_added(node: Node) -> void:
	# Called for every node the editor adds anywhere: the cheap test first.
	if node is Light3D and is_instance_valid(_root) and _root.is_ancestor_of(node):
		_add(node as Light3D)


func _on_node_removed(node: Node) -> void:
	if not node is Light3D:
		return
	for i: int in _icons.size():
		if _icons[i].light == node:
			_icons[i].mesh.queue_free()
			_icons.remove_at(i)
			return


func _add(light: Light3D) -> void:
	for icon: Icon in _icons:
		if icon.light == light:
			return
	var icon := Icon.new()
	icon.light = light
	icon.material = StandardMaterial3D.new()
	icon.material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	icon.material.no_depth_test = true
	icon.material.albedo_color = light.light_color
	icon.mesh = XRERig.create_vr_mesh(mesh_for(light.get_class()), icon.material)
	icon.mesh.top_level = true
	icon.mesh.visible = false
	add_child(icon.mesh)
	_icons.append(icon)


func _clear() -> void:
	for icon: Icon in _icons:
		icon.mesh.queue_free()
	_icons.clear()
	_root = null


## A cone one meter in radius and two long, centered on the origin, its apex
## to +Z and its open side to -Z.
static func _cone_mesh() -> ArrayMesh:
	if _cone != null:
		return _cone
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.0
	cylinder.bottom_radius = 1.0
	cylinder.height = 2.0
	cylinder.radial_segments = 16
	cylinder.rings = 1
	var arrays := cylinder.get_mesh_arrays()
	# +90° about X: the apex (+Y) goes to +Z, the base (-Y) to -Z.
	var turn := Basis(Vector3.RIGHT, PI * 0.5)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	for i: int in vertices.size():
		vertices[i] = turn * vertices[i]
		normals[i] = turn * normals[i]
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TANGENT] = null
	_cone = ArrayMesh.new()
	_cone.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return _cone
