@tool
class_name XREBoundsBox
extends MeshInstance3D
## A wireframe box around a node's bounds, drawn only in the headset,
## respecting scene and interface occlusion, like the edge outline (D-026).

## Gap between the bounds and the box, in the node's units: keeps the lines
## off the surfaces of box-shaped objects.
const PADDING := 0.005

## The 12 edges of the unit cube, shared by all boxes.
static var _cube: ArrayMesh


func _init(color: Color) -> void:
	top_level = true
	visible = false
	mesh = _unit_cube()
	layers = XRERig.VR_LAYER
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material_override = material


## Shows the box around [param bounds], given in the space of [param xform].
func show_bounds(xform: Transform3D, bounds: AABB) -> void:
	var padded := bounds.grow(PADDING)
	global_transform = xform * Transform3D(Basis.from_scale(padded.size), padded.position)
	visible = true


static func _unit_cube() -> ArrayMesh:
	if _cube != null:
		return _cube
	var lines := PackedVector3Array()
	for axis: int in 3:
		var u := Vector3.ZERO
		var v := Vector3.ZERO
		u[(axis + 1) % 3] = 1.0
		v[(axis + 2) % 3] = 1.0
		var along := Vector3.ZERO
		along[axis] = 1.0
		for corner: Vector3 in [Vector3.ZERO, u, v, u + v]:
			lines.append(corner)
			lines.append(corner + along)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = lines
	_cube = ArrayMesh.new()
	_cube.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	return _cube
