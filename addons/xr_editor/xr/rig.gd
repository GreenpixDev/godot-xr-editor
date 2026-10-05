@tool
class_name XRERig
extends XROrigin3D
## The user's body in the VR view: head camera and both controllers.
##
## Lives in the editor tree under the plugin, never in the edited scene, and has
## no owner, so it is never saved into a .tscn. Everything it draws is on
## [constant VR_LAYER], which desktop 3D viewport cameras do not render.

## Render layer of everything the VR layer draws. Desktop 3D viewport cameras
## render bits 0–19 (scene layers 1–20) and bits 24–31 (editor gizmos), see
## editor/scene/3d/node_3d_editor_plugin.cpp in 4.7.2; bit 20 is left to the headset.
const VR_LAYER := 1 << 20
## Bits 0–19: render layers 1–20 that scene content can be on.
const SCENE_LAYERS := (1 << 20) - 1
## Length of the pointing ray drawn from each controller, in meters.
const RAY_LENGTH := 2.0

var camera: XRCamera3D
var left_hand: XRController3D
var right_hand: XRController3D


func _init() -> void:
	name = "XRERig"
	set_notify_transform(true)
	camera = XRCamera3D.new()
	camera.name = "Head"
	camera.cull_mask = SCENE_LAYERS | VR_LAYER
	camera.current = true
	add_child(camera)
	left_hand = _create_hand("LeftHand", &"left_hand", Color(0.3, 0.6, 1.0))
	right_hand = _create_hand("RightHand", &"right_hand", Color(1.0, 0.6, 0.2))


func _notification(what: int) -> void:
	# XROrigin3D publishes its transform to XRServer only outside the editor
	# (scene/3d/xr/xr_nodes.cpp checks is_editor_hint()). Both eyes are rendered
	# relative to XRServer.world_origin, so the rig publishes it itself.
	if what == NOTIFICATION_ENTER_TREE or what == NOTIFICATION_TRANSFORM_CHANGED:
		XRServer.world_origin = global_transform


## Builds a controller that follows [param tracker_name]'s aim pose and stays
## hidden until the tracker reports a pose.
func _create_hand(node_name: String, tracker_name: StringName, color: Color) -> XRController3D:
	var hand := XRController3D.new()
	hand.name = node_name
	hand.tracker = tracker_name
	hand.pose = &"aim"
	hand.show_when_tracked = true

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color

	# The aim pose looks down -Z from the controller tip: the body extends back
	# along +Z, the ray forward along -Z.
	hand.add_child(_create_box(Vector3(0.04, 0.04, 0.12), Vector3(0.0, 0.0, 0.06), material))
	hand.add_child(_create_box(Vector3(0.004, 0.004, RAY_LENGTH), Vector3(0.0, 0.0, -RAY_LENGTH / 2.0), material))
	# Spike diagnostics: proves that button input, not just tracking, reaches the editor.
	hand.button_pressed.connect(_on_button_pressed.bind(node_name))
	add_child(hand)
	return hand


func _on_button_pressed(button: String, hand_name: String) -> void:
	print("XR Editor: %s pressed %s." % [hand_name, button])


func _create_box(size: Vector3, offset: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var box := MeshInstance3D.new()
	box.mesh = mesh
	box.material_override = material
	box.position = offset
	box.layers = VR_LAYER
	# Shadows are culled by the light, not the camera: a VR-layer shadow would
	# show up in the desktop viewport.
	box.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	box.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	return box
