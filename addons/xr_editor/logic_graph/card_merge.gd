@tool
class_name XRECardMerge
extends RefCounted
## Graph drawing Merged (D-168): a card's parts of one look are drawn as one mesh, a child of the card. The
## parts stay where they are — the ray, the tests and the focus read them — but leave the VR layer while merged.
## A part is merged by its material: the plain unshaded overlay ([method XREBlueprintCanvas.material], any
## priority and depth test), the wires' shaded one ([method XREBlueprintCanvas.wire_material], without
## growth) or, with Card merged (D-170), the cards' faces (their [code]face_tint[/code] shader, also over
## everything), its colour, the part's transparency and its place going into the vertices. Other parts
## (textured, the grids, labels) draw themselves. [method merge] again whenever a merged part changes: its card alone.

## Meta of a merged part: the layers it had.
const _LAYERS := &"merge_layers"
## Meta of a merged mesh.
const MERGED := &"merged"

static var _merger: XREMeshMerger
static var _text_merger: XRETextMerger
static var _plain: Dictionary = {}
static var _shaded: Dictionary = {}
static var _shaded_shader: Shader
static var _shaded_top_shader: Shader
static var _face: Dictionary = {}
static var _face_shader: Shader
static var _face_top_shader: Shader
## Whether cards' faces are merged too (Card merged, D-170).
static var faces := false

## The card the parts are on.
var card_node: Node3D
## [method card_state] of the card when it was last merged (D-170).
var state := 0
var _parts: Array[GeometryInstance3D] = []
## By the look's key: the merged mesh and what is merged into it.
var _meshes: Dictionary = {}
var _lists: Dictionary = {}
## Graph detail By distance (D-172): the parts the card's level hides; they leave the VR layer and are not merged.
var _hidden: Array[GeometryInstance3D] = []
## Graph text Merged (D-171): the labels to merge, the merged text and what it is made from.
var _labels: Array[Label3D] = []
var _text: MeshInstance3D
var _text_labels: Array = []
var _text_places: Array = []
var _text_seen := PackedFloat32Array()


func _init(node: Node3D) -> void:
	card_node = node
	if _merger == null: _merger = XREMeshMerger.new()


## The parts to merge, from now on; the ones before and not among them draw themselves again.
func set_parts(parts: Array[GeometryInstance3D]) -> void:
	for part: GeometryInstance3D in _parts:
		if is_instance_valid(part) and not parts.has(part): _unhide(part)
	_parts = parts


## The parts the card's level hides (D-172), from now on; the ones before and not among them are shown again
## (and merged again, if they are merged, by the next [method merge]).
func set_hidden(hidden: Array[GeometryInstance3D]) -> void:
	for part: GeometryInstance3D in _hidden:
		if is_instance_valid(part) and not hidden.has(part): _unhide(part)
	_hidden = hidden


## The merger the card merges share, for other meshes made of parts (D-172).
static func merger() -> XREMeshMerger:
	if _merger == null: _merger = XREMeshMerger.new()
	return _merger


## The labels to merge (D-171), from now on; the ones before and not among them draw themselves again.
func set_labels(labels: Array[Label3D]) -> void:
	for label: Label3D in _labels:
		if is_instance_valid(label) and not labels.has(label): _unhide(label)
	_labels = labels


## Whether [param label] is drawn as Label3D draws it flat (D-171): no billboard, no fixed size, unlit, no alpha
## cut, the default filter, no fill, a font of its own; and not one marked [code]live[/code], changed every frame.
static func mergeable(label: Label3D) -> bool:
	return label.billboard == BaseMaterial3D.BILLBOARD_DISABLED and not label.fixed_size and not label.shaded \
			and label.alpha_cut == Label3D.ALPHA_CUT_DISABLED and label.texture_filter == BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS \
			and label.horizontal_alignment != HORIZONTAL_ALIGNMENT_FILL and label.font != null and not label.text.is_empty() and not label.has_meta(&"live")


## A number that changes with anything under [param node] that a merge draws from, labels too with
## [param labels] (D-170): natively, for a check each frame.
static func card_state(node: Node3D, labels: bool) -> int:
	if _merger == null: _merger = XREMeshMerger.new()
	return _merger.card_state(node, labels)


## Merges the parts as they are now.
func merge() -> void:
	for part: GeometryInstance3D in _hidden:
		if is_instance_valid(part): _hide(part)
	for key: Array in _lists:
		var list: Array = _lists[key]
		(list[0] as Array).clear()
		(list[1] as Array).clear()
		list[2] = PackedColorArray()
		list[3] = PackedFloat32Array()
	for part: GeometryInstance3D in _parts:
		if not is_instance_valid(part): continue
		if _hidden.has(part): continue
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
	_merge_text()


## The labels shown as one mesh of glyphs (D-171), sorted as the frontmost of them; the others draw themselves.
func _merge_text() -> void:
	_text_labels.clear()
	_text_places.clear()
	_text_seen.clear()
	var sorting := -INF
	for label: Label3D in _labels:
		if not is_instance_valid(label) or _hidden.has(label): continue
		if not _shown(label) or not mergeable(label):
			_unhide(label)
			continue
		if not label.has_meta(_LAYERS):
			label.set_meta(_LAYERS, label.layers)
			label.layers = 0
		_text_labels.append(label)
		_text_places.append(_place_of(label))
		_text_seen.append(1.0 - label.transparency)
		sorting = maxf(sorting, label.sorting_offset)
	if _text_labels.is_empty():
		if _text != null: _text.visible = false
		return
	if _text == null:
		_text = XRERig.create_vr_mesh(ArrayMesh.new(), null)
		_text.name = "MergedText"
		_text.set_meta(&"painted", true)
		_text.set_meta(MERGED, true)
		card_node.add_child(_text)
	if _text_merger == null: _text_merger = XRETextMerger.new()
	_text.visible = true
	_text.transparency = 0.0
	for meta: StringName in [&"seen", &"unfaded", &"untop", &"unpainted"]:
		if _text.has_meta(meta): _text.remove_meta(meta)
	_text.sorting_offset = sorting
	_text_merger.merge(_text.mesh as ArrayMesh, _text_labels, _text_places, _text_seen, _text_labels.size())


## The merged text's mesh, for the tests; null when there is none.
func get_text_mesh() -> MeshInstance3D:
	return _text if _text != null and _text.visible else null


## Gives every part back its own drawing and frees the merged meshes.
func release() -> void:
	_restore_parts()
	for part: GeometryInstance3D in _hidden:
		if is_instance_valid(part): _unhide(part)
	_hidden.clear()
	for label: Label3D in _labels:
		if is_instance_valid(label): _unhide(label)
	_labels.clear()
	if is_instance_valid(_text): _text.queue_free()
	_text = null
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
	if _text != null and _text.visible: count += 1
	return count


## The merged meshes, for the tests.
func get_meshes() -> Array[MeshInstance3D]:
	var meshes: Array[MeshInstance3D] = []
	for key: Array in _meshes: meshes.append(_meshes[key])
	return meshes


func _restore_parts() -> void:
	for part: GeometryInstance3D in _parts:
		if is_instance_valid(part): _unhide(part)


static func _hide(part: GeometryInstance3D) -> void:
	if part.has_meta(_LAYERS): return
	part.set_meta(_LAYERS, part.layers)
	part.layers = 0


static func _unhide(part: GeometryInstance3D) -> void:
	if part == null: return
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
		var top: Variant = shader.get_meta(&"focus_top") if shader != null and shader.has_meta(&"focus_top") else null
		if shader != null and (shaded.shader == shader or (top != null and shaded.shader == top)):
			var grow: Variant = shaded.get_shader_parameter(&"grow")
			if grow != null and not is_zero_approx(float(grow)): return []
			return [&"shaded", shaded.render_priority, shaded.shader != shader]
		# A card's face (D-170), as it is or over everything (Front).
		if faces and shaded.shader != null and shaded.get_shader_parameter(&"face_tint") is Color and shaded.shader.code.contains("uniform vec4 face_tint"):
			return [&"face", shaded.render_priority, shaded.shader.code.contains("depth_test_disabled")]
	return []


## [param part]'s colour as its material and transparency draw it.
static func _color_of(part: GeometryInstance3D) -> Color:
	var seen := 1.0 - part.transparency
	if part.material_override is StandardMaterial3D:
		var color := (part.material_override as StandardMaterial3D).albedo_color
		color.a *= seen
		return color
	var shaded := part.material_override as ShaderMaterial
	var face: Variant = shaded.get_shader_parameter(&"face_tint")
	var tint: Color = face if face is Color else shaded.get_shader_parameter(&"tint")
	tint.a = seen
	return tint


## The material a merged mesh of look [param key] is drawn with, made once for each look.
## The material of look [param key] ([method _key_of]), for other merged meshes (D-172).
static func material_of(key: Array) -> Material:
	return _material_of(key)


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
	if key[0] == &"face":
		if not _face.has(key):
			var face := ShaderMaterial.new()
			face.shader = _face_shader_of(key[2])
			face.render_priority = key[1]
			_face[key] = face
		return _face[key]
	if not _shaded.has(key):
		var shaded := ShaderMaterial.new()
		shaded.shader = _shaded_shader_of(key[2])
		shaded.render_priority = key[1]
		_shaded[key] = shaded
	return _shaded[key]


## The cards' face shader (D-170), its tint in the vertices' colour (sRGB, as a source_color uniform is),
## see-through by its alpha; the front face full, the sides and back darker, as the canvas's.
static func _face_shader_of(top: bool) -> Shader:
	var shader := _face_top_shader if top else _face_shader
	if shader != null: return shader
	shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, depth_draw_always, shadows_disabled%s;
varying float front;
vec3 to_linear(vec3 c) { return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c)); }
void vertex() { front = step(0.5, NORMAL.z); }
void fragment() { ALBEDO = to_linear(COLOR.rgb) * mix(0.55, 1.0, front); ALPHA = COLOR.a; }
""" % (", depth_test_disabled" if top else "")
	if top: _face_top_shader = shader
	else: _face_shader = shader
	return shader


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
