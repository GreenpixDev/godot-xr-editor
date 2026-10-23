@tool
class_name XREBlueprintColorSampler
extends RefCounted
## The pipette of the Color window (D-064): the color of a scene object where
## the ray meets it, as its material says it — not as the headset shows it,
## dimmed by the graph's veil and by the darkening around an input, shaded by
## lights. Run once per click, never per frame.

## Names a shader's color parameter commonly has, tried in this order.
const SHADER_COLORS: Array[StringName] = [&"albedo", &"albedo_color", &"color", &"base_color", &"modulate", &"tint"]


## The color of [param node] (the node the picker resolved a hit to) at
## [param point], global: of the geometry under it whose box holds the point,
## the smallest of several. Null if none has a color to give.
static func color_at(node: Node, point: Vector3) -> Variant:
	var best: GeometryInstance3D
	var best_size := INF
	for geometry: GeometryInstance3D in _geometries(node, []):
		var box := (geometry.global_transform * geometry.get_aabb()).grow(0.005)
		if not box.has_point(point): continue
		var size := box.size.length()
		if size < best_size:
			best_size = size
			best = geometry
	return _color_of(best, point) if best != null else null


static func _geometries(node: Node, found: Array[GeometryInstance3D]) -> Array[GeometryInstance3D]:
	if node is GeometryInstance3D and (node as GeometryInstance3D).is_visible_in_tree(): found.append(node as GeometryInstance3D)
	for child: Node in node.get_children(): _geometries(child, found)
	return found


static func _color_of(geometry: GeometryInstance3D, point: Vector3) -> Variant:
	var color: Variant = material_color(geometry.material_override)
	if color != null: return color
	if geometry is MeshInstance3D:
		var instance := geometry as MeshInstance3D
		if instance.mesh == null: return null
		return material_color(instance.get_active_material(_surface_at(instance, point)))
	if geometry is CSGShape3D:
		var csg_material: Variant = geometry.get(&"material")
		return material_color(csg_material as Material) if csg_material is Material else null
	if geometry is SpriteBase3D: return (geometry as SpriteBase3D).modulate
	if geometry is Label3D: return (geometry as Label3D).modulate
	return null


## The surface of [param instance]'s mesh at [param point]: of several, the
## one whose vertices' box holds it, the smallest of those.
static func _surface_at(instance: MeshInstance3D, point: Vector3) -> int:
	var mesh := instance.mesh
	if mesh.get_surface_count() < 2: return 0
	var local := instance.global_transform.affine_inverse() * point
	var best := 0
	var best_size := INF
	for surface: int in mesh.get_surface_count():
		var vertices: PackedVector3Array = mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
		if vertices.is_empty(): continue
		var box := AABB(vertices[0], Vector3.ZERO)
		for vertex: Vector3 in vertices: box = box.expand(vertex)
		box = box.grow(0.005)
		if box.has_point(local) and box.size.length() < best_size:
			best_size = box.size.length()
			best = surface
	return best


## The color [param material] gives its surface: a standard material's albedo,
## a shader's color parameter by a common name; null for none.
static func material_color(material: Material) -> Variant:
	if material is BaseMaterial3D: return (material as BaseMaterial3D).albedo_color
	if material is ShaderMaterial:
		for parameter: StringName in SHADER_COLORS:
			var value: Variant = (material as ShaderMaterial).get_shader_parameter(parameter)
			if value is Color: return value
	return null
