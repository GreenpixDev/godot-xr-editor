@tool
class_name XRECardMerge
extends RefCounted
## Graph drawing Merged (D-168): a card's parts of one look are drawn as one mesh, a child of the card. The
## parts stay where they are — the ray, the tests and the focus read them — but leave the VR layer while merged.
## A part is merged by its material: the plain unshaded overlay ([method XREBlueprintCanvas.material], any
## priority and depth test) or the wires' shaded one ([method XREBlueprintCanvas.wire_material], without
## growth), its colour, the part's transparency and its place going into the vertices. Other parts (textured,
## the grids, labels) draw themselves. [method merge] again whenever a merged part changes: its card alone.

## Meta of a merged part: the layers it had.
const _LAYERS := &"merge_layers"
## Meta of a merged mesh.
const MERGED := &"merged"

static var _merger: XREMeshMerger
static var _plain: Dictionary = {}
static var _shaded: Dictionary = {}
static var _shaded_shader: Shader
static var _shaded_top_shader: Shader

## The card the parts are on.
var card_node: Node3D
var _parts: Array[GeometryInstance3D] = []
## By the look's key: the merged mesh and what is merged into it.
var _meshes: Dictionary = {}
var _lists: Dictionary = {}


func _init(node: Node3D) -> void:
	card_node = node
	if _merger == null: _merger = XREMeshMerger.new()


## The parts to merge, from now on; the ones before draw themselves again.
func set_parts(parts: Array[GeometryInstance3D]) -> void:
	_restore_parts()
	_parts = parts


## Merges the parts as they are now.
func merge() -> void:
	for key: Array in _lists:
		var list: Array = _lists[key]
		(list[0] as Array).clear()
		(list[1] as Array).clear()
		list[2] = PackedColorArray()
		list[3] = PackedFloat32Array()
	for part: GeometryInstance3D in _parts:
		if not is_instance_valid(part): continue
		var key := _key_of(part)
		if key.is_empty() or not _shown(part):
			_unhide(part)
			continue
		if not part.has_meta(_LAYERS):
			part.set_meta(_LAYERS, part.layers)
			part.layers = 0
		if not _lists.has(key): _lists[key] = [[], [], PackedColorArray(), PackedFloat32Array()]
		var list: Array = _lists[key]
		# Packed arrays are values: changed here, then put back.
		var colors: PackedColorArray = list[2]
		var offsets: PackedFloat32Array = list[3]
		var at := _sorted_at(offsets, part.sorting_offset)
		(list[0] as Array).insert(at, (part as MeshInstance3D).mesh)
		(list[1] as Array).insert(at, _place_of(part))
		colors.insert(at, _color_of(part))
		offsets.insert(at, part.sorting_offset)
		list[2] = colors
		list[3] = offsets
	for key: Array in _lists:
		var list: Array = _lists[key]
		var count := (list[0] as Array).size()
		if count == 0:
			if _meshes.has(key): (_meshes[key] as MeshInstance3D).visible = false
			continue
		var mesh: MeshInstance3D = _meshes.get(key)
		if mesh == null:
			mesh = XRERig.create_vr_mesh(ArrayMesh.new(), null)
			mesh.name = "Merged"
			# Its material is the merge's own: focus paints its parts, not it.
			mesh.set_meta(&"painted", true)
			mesh.set_meta(MERGED, true)
			card_node.add_child(mesh)
			_meshes[key] = mesh
		mesh.visible = true
		# Focus and see-through reach it through its card, but its parts' colours already hold them: as it was made.
		mesh.transparency = 0.0
		for meta: StringName in [&"seen", &"unfaded", &"untop", &"unpainted"]:
			if mesh.has_meta(meta): mesh.remove_meta(meta)
		var sorting: PackedFloat32Array = list[3]
		mesh.sorting_offset = sorting[sorting.size() - 1]
		_merger.merge(mesh.mesh as ArrayMesh, list[0], list[1], list[2], count, _material_of(key))


## Gives every part back its own drawing and frees the merged meshes.
func release() -> void:
	_restore_parts()
	for key: Array in _meshes:
		var mesh: MeshInstance3D = _meshes[key]
		if is_instance_valid(mesh): mesh.queue_free()
	_meshes.clear()
	_lists.clear()


## How many merged meshes draw now.
func mesh_count() -> int:
	var count := 0
	for key: Array in _meshes:
		if (_meshes[key] as MeshInstance3D).visible: count += 1
	return count


## The merged meshes, for the tests.
func get_meshes() -> Array[MeshInstance3D]:
	var meshes: Array[MeshInstance3D] = []
	for key: Array in _meshes: meshes.append(_meshes[key])
	return meshes


func _restore_parts() -> void:
	for part: GeometryInstance3D in _parts:
		if is_instance_valid(part): _unhide(part)


static func _unhide(part: GeometryInstance3D) -> void:
	if not part.has_meta(_LAYERS): return
	part.layers = part.get_meta(_LAYERS)
	part.remove_meta(_LAYERS)


## Whether [param part] and what holds it up to the card are visible.
func _shown(part: Node3D) -> bool:
	var node: Node = part
	while node != null and node != card_node:
		if node is Node3D and not (node as Node3D).visible: return false
		node = node.get_parent()
	return node == card_node


## Where [param part] is in the card's space.
func _place_of(part: Node3D) -> Transform3D:
	var place := part.transform
	var node := part.get_parent()
	while node != null and node != card_node:
		if node is Node3D: place = (node as Node3D).transform * place
		node = node.get_parent()
	return place


static func _sorted_at(offsets: PackedFloat32Array, offset: float) -> int:
	var at := offsets.size()
	while at > 0 and offsets[at - 1] > offset: at -= 1
	return at


## The look [param part] is merged in, or empty if it draws itself.
static func _key_of(part: GeometryInstance3D) -> Array:
	var mesh := part as MeshInstance3D
	if mesh == null or mesh.mesh == null or mesh.mesh.get_surface_count() != 1 or part is MultiMeshInstance3D: return []
	var material := part.material_override
	if material is StandardMaterial3D:
		var plain := material as StandardMaterial3D
		if plain.albedo_texture != null or plain.vertex_color_use_as_albedo or plain.shading_mode != BaseMaterial3D.SHADING_MODE_UNSHADED \
				or plain.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA:
			return []
		return [&"plain", plain.render_priority, plain.no_depth_test, plain.depth_draw_mode, plain.cull_mode]
	if material is ShaderMaterial:
		var shaded := material as ShaderMaterial
		var shader := XREBlueprintCanvas.wire_shader()
		if shader == null or not is_zero_approx(float(shaded.get_shader_parameter(&"grow"))): return []
		var top: Variant = shader.get_meta(&"focus_top") if shader.has_meta(&"focus_top") else null
		if shaded.shader == shader: return [&"shaded", shaded.render_priority, false]
		if top != null and shaded.shader == top: return [&"shaded", shaded.render_priority, true]
	return []


## [param part]'s colour as its material and transparency draw it.
static func _color_of(part: GeometryInstance3D) -> Color:
	var seen := 1.0 - part.transparency
	if part.material_override is StandardMaterial3D:
		var color := (part.material_override as StandardMaterial3D).albedo_color
		color.a *= seen
		return color
	var tint: Color = (part.material_override as ShaderMaterial).get_shader_parameter(&"tint")
	tint.a = seen
	return tint


## The material a merged mesh of look [param key] is drawn with, made once for each look.
static func _material_of(key: Array) -> Material:
	if key[0] == &"plain":
		if not _plain.has(key):
			var plain := StandardMaterial3D.new()
			plain.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			plain.vertex_color_use_as_albedo = true
			plain.vertex_color_is_srgb = true
			plain.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			plain.render_priority = key[1]
			plain.no_depth_test = key[2]
			plain.depth_draw_mode = key[3]
			plain.cull_mode = key[4]
			_plain[key] = plain
		return _plain[key]
	if not _shaded.has(key):
		var shaded := ShaderMaterial.new()
		shaded.shader = _shaded_shader_of(key[2])
		shaded.render_priority = key[1]
		_shaded[key] = shaded
	return _shaded[key]


## The wires' shader, its tint in the vertices' colour (sRGB, as a source_color uniform is), see-through by its alpha.
static func _shaded_shader_of(top: bool) -> Shader:
	var shader := _shaded_top_shader if top else _shaded_shader
	if shader != null: return shader
	shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, depth_draw_always, shadows_disabled, fog_disabled%s;
vec3 to_linear(vec3 c) { return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c)); }
void fragment() {
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	ALBEDO = to_linear(COLOR.rgb) * mix(0.45, 1.0, sqrt(facing));
	ALPHA = COLOR.a;
}
""" % (", depth_test_disabled" if top else "")
	if top: _shaded_top_shader = shader
	else: _shaded_shader = shader
	return shader
