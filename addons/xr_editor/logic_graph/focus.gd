@tool
class_name XREBlueprintFocus
extends RefCounted
## Focus on what a ray is on in the graph (D-072). With many blocks their
## ports and wires are hard to follow; a card under a ray, or a variable's
## box, is in focus with its ports, details, adapters and wires, and the
## rest is out of it. Two settings: [constant XREFeatureSettings.FOCUS] lights
## what is in focus, [constant XREFeatureSettings.DEFOCUS] makes the rest
## darker or see-through. A port or a detail under the ray grows as before,
## over the focus of its card.
##
## A look is painted on a node and every geometry under it: its material is
## swapped for a lighter or darker copy, made once for each material and kept
## in its meta, and the one it had is kept in the geometry's meta; a label's
## color is darkened. See-through is a layer of [method XREBlueprintFade.set_seen].
## A geometry with the meta [code]painted[/code] has its material set by its
## owner (a card's frame) and only takes the transparency.
##
## With Focus on Front (D-075) what is in focus is painted [constant TOP]: as
## it is, but drawn over everything — its materials' copies skip the depth
## test, its labels too, it goes through the transparent pass (a faint layer
## of [XREBlueprintFade]), so that nothing transparent drawn after it, as a
## panel, covers it, and it is sorted after the rest of the graph, as the
## petals are over the cards (D-062). Without the depth test its own parts are
## sorted by how far toward its front they stand: a socket under the token in
## it, the face under its ports, labels last. The hands' rays are drawn over
## it in turn ([method XREHand.set_on_top]).

## How a card, a wire or a box is in focus: as it is, the focus, the end of
## a wire in focus or a port a wire may end on (as it is), out of focus.
const NORMAL := 0
const FOCUSED := 1
const KEPT := 2
const OUT := 3
## How it is painted: as it is, lighter, darker, as it is over everything (D-075).
const PLAIN := 0
const LIT := 1
const DARK := 2
const TOP := 3
## How much later than the rest of the graph what is painted [constant TOP]
## is drawn; how much later for each meter its part stands toward the front
## of what is painted (a card), so that its parts are drawn back to front
## with no depth test; how much later a label than a geometry where it stands;
## how much of it is seen, just under all of it, for the transparent pass.
const TOP_SORTING := 100.0
const DEPTH_SORTING := 1000.0
const TEXT_SORTING := 0.5
const TOP_SEEN := 0.999
## How far toward white what is in focus goes, how bright what is out of
## focus stays with Dim, and how much of it is seen with Transparent.
const LIGHT := 0.3
const DIM := 0.35
const SEEN := 0.25
## The frame of a card in focus.
const FRAME := Color("ffd75e")


## Paints [param node] and every geometry under it [param paint_as]: [constant LIT],
## [constant DARK], [constant TOP] or back [constant PLAIN].
## [param root] is what its parts are sorted in with [constant TOP]: [param node] if null.
static func paint(node: Node, paint_as: int, root: Node3D = null) -> void:
	if root == null: root = node as Node3D
	var geometry_node := node as GeometryInstance3D
	if geometry_node != null: raise(geometry_node, paint_as == TOP, root)
	var label := node as Label3D
	if label != null:
		if paint_as == DARK and not label.has_meta(&"unpainted"):
			label.set_meta(&"unpainted", [label.modulate, label.outline_modulate])
			label.modulate = _darker(label.modulate)
			label.outline_modulate = _darker(label.outline_modulate)
		elif paint_as != DARK and label.has_meta(&"unpainted"):
			var before: Array = label.get_meta(&"unpainted")
			label.modulate = before[0]
			label.outline_modulate = before[1]
			label.remove_meta(&"unpainted")
	elif node is GeometryInstance3D and not node.has_meta(&"painted"):
		var geometry := node as GeometryInstance3D
		var own: Material = geometry.get_meta(&"unpainted") if geometry.has_meta(&"unpainted") else geometry.material_override
		if paint_as == PLAIN:
			if geometry.has_meta(&"unpainted"):
				geometry.material_override = own
				geometry.remove_meta(&"unpainted")
		elif own != null:
			geometry.set_meta(&"unpainted", own)
			geometry.material_override = variant(own, paint_as)
	for child: Node in node.get_children(): paint(child, paint_as, root)


## Gives [param label] the colour [param color] as [method paint] left it:
## darker while it is painted [constant DARK] (D-114).
static func recolor(label: Label3D, color: Color) -> void:
	if not label.has_meta(&"unpainted"):
		label.modulate = color
		return
	var before: Array = label.get_meta(&"unpainted")
	before[0] = color
	label.modulate = _darker(color)


## Draws [param geometry] over the rest of the graph, or as before (D-075):
## in the transparent pass, sorted [constant TOP_SORTING] later and more the
## farther toward the front of [param root] it stands, a label after a
## geometry and with no depth test; what it had is kept in its meta.
static func raise(geometry: GeometryInstance3D, enabled: bool, root: Node3D = null) -> void:
	if enabled == geometry.has_meta(&"untop"): return
	var label := geometry as Label3D
	XREBlueprintFade.set_layer(geometry, &"top", TOP_SEEN if enabled else 1.0)
	if enabled:
		geometry.set_meta(&"untop", Vector2(geometry.sorting_offset, 1.0 if label != null and label.no_depth_test else 0.0))
		var front := 0.0
		if root != null and root != geometry and root.is_inside_tree() and geometry.is_inside_tree():
			front = (root.global_transform.affine_inverse() * geometry.global_transform * geometry.get_aabb().get_center()).z
		geometry.sorting_offset += TOP_SORTING + front * DEPTH_SORTING + (TEXT_SORTING if label != null else 0.0)
		if label != null: label.no_depth_test = true
		return
	var before: Vector2 = geometry.get_meta(&"untop")
	geometry.sorting_offset = before.x
	if label != null: label.no_depth_test = before.y > 0.5
	geometry.remove_meta(&"untop")


## [param material] painted [param paint_as]: itself for [constant PLAIN], else
## a copy, lighter, darker or skipping the depth test, made once and kept in its meta.
static func variant(material: Material, paint_as: int) -> Material:
	if material == null or paint_as == PLAIN: return material
	var key := &"focus_lit" if paint_as == LIT else &"focus_dark" if paint_as == DARK else &"focus_top"
	if material.has_meta(key): return material.get_meta(key)
	var copy := material.duplicate() as Material
	for meta: StringName in [&"focus_lit", &"focus_dark", &"focus_top"]:
		if copy.has_meta(meta): copy.remove_meta(meta)
	if copy is BaseMaterial3D:
		var standard := copy as BaseMaterial3D
		if paint_as == TOP:
			standard.no_depth_test = true
			standard.render_priority = Material.RENDER_PRIORITY_MAX
		else: standard.albedo_color = _changed(standard.albedo_color, paint_as)
	elif copy is ShaderMaterial:
		var shader := copy as ShaderMaterial
		if paint_as == TOP:
			shader.shader = _top_shader(shader.shader)
			shader.render_priority = Material.RENDER_PRIORITY_MAX
		else:
			for parameter: StringName in [&"tint", &"face_tint"]:
				var value: Variant = shader.get_shader_parameter(parameter)
				if value is Color: shader.set_shader_parameter(parameter, _changed(value as Color, paint_as))
	material.set_meta(key, copy)
	return copy


## [param shader] skipping the depth test: a copy made once and kept in its meta.
static func _top_shader(shader: Shader) -> Shader:
	if shader == null or shader.code.contains("depth_test_disabled"): return shader
	if shader.has_meta(&"focus_top"): return shader.get_meta(&"focus_top")
	var copy := Shader.new()
	copy.code = shader.code.replace("render_mode ", "render_mode depth_test_disabled, ")
	shader.set_meta(&"focus_top", copy)
	return copy


static func _changed(color: Color, paint_as: int) -> Color:
	if paint_as == LIT:
		var lighter := color.lerp(Color.WHITE, LIGHT)
		return Color(lighter.r, lighter.g, lighter.b, color.a)
	return _darker(color)


static func _darker(color: Color) -> Color:
	return Color(color.r * DIM, color.g * DIM, color.b * DIM, color.a)
