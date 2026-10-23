@tool
class_name XREBlueprintPipette
extends Node3D
## The pipette of the Color window (D-065), held in a hand in place of its
## controller while it is taken: a glass tip, a tube with the color being
## edited in it, a rubber bulb behind. Its tip is where the hand's ray starts,
## pointing down -Z. Drawn over the dimming around an input, as the ray is.
## Built once; [method hold] moves it to a hand.

## How long it is, from the tip to the end of the bulb, in meters.
const LENGTH := 0.142
const GLASS := Color(0.8, 0.9, 1.0)
const RUBBER := Color(0.62, 0.16, 0.18)

var _liquid: ShaderMaterial


func _init() -> void:
	name = "Pipette"
	visible = false
	# CylinderMesh stands along +Y: turned so that its top points down -Z, to the tip.
	_add(_cylinder(0.0011, 0.0042, 0.026), 0.013, XREBlueprintCanvas._token_shaded(GLASS))
	_liquid = (XREBlueprintCanvas._token_shaded(Color.WHITE) as ShaderMaterial).duplicate() as ShaderMaterial
	_add(_cylinder(0.0055, 0.0055, 0.036), 0.044, _liquid)
	_add(_cylinder(0.0055, 0.0055, 0.034), 0.079, XREBlueprintCanvas._token_shaded(GLASS))
	_add(_cylinder(0.0078, 0.0078, 0.004), 0.098, XREBlueprintCanvas._token_shaded(RUBBER.darkened(0.3)))
	var bulb := CapsuleMesh.new()
	bulb.radius = 0.0095
	bulb.height = 0.042
	bulb.radial_segments = 16
	bulb.rings = 6
	_add(bulb, LENGTH - 0.021, XREBlueprintCanvas._token_shaded(RUBBER))


static func _cylinder(top: float, bottom: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top
	mesh.bottom_radius = bottom
	mesh.height = height
	mesh.radial_segments = 16
	mesh.rings = 1
	return mesh


## A part of [param mesh] whose middle is [param along] behind the tip.
func _add(mesh: Mesh, along: float, material: Material) -> void:
	var part := XRERig.create_vr_mesh(mesh, material)
	part.basis = Basis(Vector3.RIGHT, -PI * 0.5)
	part.position = Vector3(0, 0, along)
	# After the dimmer, as the ray over an input is (D-061).
	part.sorting_offset = 200.0
	add_child(part)


## Puts the pipette in [param hand], its tip at the ray's start, with [param color] in it.
func hold(hand: Node3D, color: Color) -> void:
	if get_parent() != hand:
		if get_parent() != null: get_parent().remove_child(self)
		hand.add_child(self)
	transform = Transform3D.IDENTITY
	set_color(color)
	visible = true


## Puts the pipette away: it is hidden in the hand it was in.
func put_back() -> void:
	visible = false


## Shows [param color] in the tube, without its alpha.
func set_color(color: Color) -> void:
	_liquid.set_shader_parameter(&"tint", Color(color, 1.0))


## The color in the tube.
func get_color() -> Color:
	return _liquid.get_shader_parameter(&"tint") as Color
