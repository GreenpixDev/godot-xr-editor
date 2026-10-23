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

## How a card, a wire or a box is in focus: as it is, the focus, the end of
## a wire in focus or a port a wire may end on (as it is), out of focus.
const NORMAL := 0
const FOCUSED := 1
const KEPT := 2
const OUT := 3
## How it is painted: as it is, lighter, darker.
const PLAIN := 0
const LIT := 1
const DARK := 2
## How far toward white what is in focus goes, how bright what is out of
## focus stays with Dim, and how much of it is seen with Transparent.
const LIGHT := 0.3
const DIM := 0.35
const SEEN := 0.25
## The frame of a card in focus.
const FRAME := Color("ffd75e")


## Paints [param node] and every geometry under it [param paint_as]: [constant LIT],
## [constant DARK] or back [constant PLAIN].
static func paint(node: Node, paint_as: int) -> void:
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
	for child: Node in node.get_children(): paint(child, paint_as)


## [param material] painted [param paint_as]: itself for [constant PLAIN], else
## a copy, lighter or darker, made once and kept in its meta.
static func variant(material: Material, paint_as: int) -> Material:
	if material == null or paint_as == PLAIN: return material
	var key := &"focus_lit" if paint_as == LIT else &"focus_dark"
	if material.has_meta(key): return material.get_meta(key)
	var copy := material.duplicate() as Material
	for meta: StringName in [&"focus_lit", &"focus_dark"]:
		if copy.has_meta(meta): copy.remove_meta(meta)
	if copy is BaseMaterial3D:
		var standard := copy as BaseMaterial3D
		standard.albedo_color = _changed(standard.albedo_color, paint_as)
	elif copy is ShaderMaterial:
		var shader := copy as ShaderMaterial
		for parameter: StringName in [&"tint", &"face_tint"]:
			var value: Variant = shader.get_shader_parameter(parameter)
			if value is Color: shader.set_shader_parameter(parameter, _changed(value as Color, paint_as))
	material.set_meta(key, copy)
	return copy


static func _changed(color: Color, paint_as: int) -> Color:
	if paint_as == LIT:
		var lighter := color.lerp(Color.WHITE, LIGHT)
		return Color(lighter.r, lighter.g, lighter.b, color.a)
	return _darker(color)


static func _darker(color: Color) -> Color:
	return Color(color.r * DIM, color.g * DIM, color.b * DIM, color.a)
