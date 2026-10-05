@tool
class_name XREHand
extends XRController3D
## One controller in the VR view: its pointing ray and the state of its trigger
## and grip. The controller itself is drawn by [XREControllerModel].
##
## Follows the tracker's aim pose: the ray starts at the node's origin and
## points down -Z. Trigger and grip are analog. Each counts as held above
## [constant PRESS_THRESHOLD] and as let go below [constant RELEASE_THRESHOLD],
## so a finger resting halfway doesn't flicker between the two.

## Length of the ray when it points at nothing, in meters.
const RAY_LENGTH := 2.0
const PRESS_THRESHOLD := 0.6
const RELEASE_THRESHOLD := 0.4

const _RAY_WIDTH := 0.004
const _DOT_RADIUS := 0.008

## Trigger is held down.
var trigger_held := false
## Trigger went down since the previous [method update_input].
var trigger_pressed := false
## Trigger went up since the previous [method update_input].
var trigger_released := false
## Grip is held down.
var grip_held := false
## Grip went down since the previous [method update_input].
var grip_pressed := false
## Grip went up since the previous [method update_input].
var grip_released := false

var _ray: MeshInstance3D
var _dot: MeshInstance3D
var _ray_material: StandardMaterial3D
var _hit_material: StandardMaterial3D
var _ray_hits := false


func _init(node_name: String, tracker_name: StringName, color: Color) -> void:
	name = node_name
	tracker = tracker_name
	pose = &"aim"
	show_when_tracked = true

	_ray_material = _unshaded(color)
	_hit_material = _unshaded(Color.WHITE)

	# One meter long, stretched to the ray's length with scale.z.
	var ray_mesh := BoxMesh.new()
	ray_mesh.size = Vector3(_RAY_WIDTH, _RAY_WIDTH, 1.0)
	_ray = XRERig.create_vr_mesh(ray_mesh, _ray_material)
	add_child(_ray)

	var dot_mesh := SphereMesh.new()
	dot_mesh.radius = _DOT_RADIUS
	dot_mesh.height = _DOT_RADIUS * 2.0
	_dot = XRERig.create_vr_mesh(dot_mesh, _hit_material)
	_dot.visible = false
	add_child(_dot)

	show_ray(RAY_LENGTH, false)


## Reads trigger and grip. Call once per frame, before reading the fields above.
## Without tracking or focus the runtime reports both as released.
func update_input() -> void:
	var was_held := trigger_held
	trigger_held = get_float(&"trigger") > (RELEASE_THRESHOLD if was_held else PRESS_THRESHOLD)
	trigger_pressed = trigger_held and not was_held
	trigger_released = was_held and not trigger_held

	was_held = grip_held
	grip_held = get_float(&"grip") > (RELEASE_THRESHOLD if was_held else PRESS_THRESHOLD)
	grip_pressed = grip_held and not was_held
	grip_released = was_held and not grip_held


## Shows the ray [param length] meters long. With [param hit], the ray is
## highlighted and ends in a dot.
func show_ray(length: float, hit: bool) -> void:
	# A ray that starts inside a box hits it at 0 m; keep the scale invertible.
	length = maxf(length, _DOT_RADIUS)
	_ray.visible = true
	_ray.scale = Vector3(1.0, 1.0, length)
	_ray.position = Vector3(0.0, 0.0, -length / 2.0)
	if hit != _ray_hits:
		_ray_hits = hit
		_ray.material_override = _hit_material if hit else _ray_material
		_dot.visible = hit
	if hit:
		_dot.position = Vector3(0.0, 0.0, -length)


func hide_ray() -> void:
	if not _ray.visible:
		return
	_ray.visible = false
	_dot.visible = false
	_ray_hits = false
	_ray.material_override = _ray_material


func _unshaded(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	return material
