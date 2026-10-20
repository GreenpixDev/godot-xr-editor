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

static var _vr_font: FontFile

var camera: XRCamera3D
var left_hand: XREHand
var right_hand: XREHand
var left_controller: XREControllerModel
var right_controller: XREControllerModel
## A panel waits for a button to bind ([method set_capturing]): actions see none.
var _capturing := false
## The capture ended; actions see no button until every one is up.
var _blocked_until_released := false


func _init() -> void:
	name = "XRERig"
	set_notify_transform(true)
	camera = XRCamera3D.new()
	camera.name = "Head"
	camera.cull_mask = SCENE_LAYERS | VR_LAYER
	camera.current = true
	add_child(camera)
	left_hand = XREHand.new("LeftHand", &"left_hand", Color(0.3, 0.6, 1.0))
	add_child(left_hand)
	right_hand = XREHand.new("RightHand", &"right_hand", Color(1.0, 0.6, 0.2))
	add_child(right_hand)
	left_controller = XREControllerModel.new("LeftController", &"left_hand", XRPositionalTracker.TRACKER_HAND_LEFT)
	right_controller = XREControllerModel.new("RightController", &"right_hand", XRPositionalTracker.TRACKER_HAND_RIGHT)
	add_child(left_controller)
	add_child(right_controller)


func _process(_delta: float) -> void:
	# Before the tools under the rig: a node processes before its children.
	left_hand.update_input()
	right_hand.update_input()
	if _blocked_until_released and not _any_button_held():
		_blocked_until_released = false


## Keeps the action buttons from the tools while a panel waits for one to bind
## (D-050). When the wait ends, they stay blocked until every button is up:
## the press that was bound must not also act, in this frame or while held.
func set_capturing(capturing: bool) -> void:
	if _capturing and not capturing:
		_blocked_until_released = true
	_capturing = capturing


## Whether a panel waits for a button, or the button it took is still down.
func is_capturing() -> bool:
	return _capturing or _blocked_until_released


## The hand whose button [param action] ([constant XREFeatureSettings.ACTIONS])
## is bound to in [param features] (D-050); null features mean the default layout.
func get_action_hand(features: XREFeatureSettings, action: StringName) -> XREHand:
	return get_button_hand(XREFeatureSettings.binding_of(features, action))


## Whether the button of [param action] went down this frame.
func is_action_pressed(features: XREFeatureSettings, action: StringName) -> bool:
	if is_capturing():
		return false
	var button := XREFeatureSettings.binding_of(features, action)
	return get_action_hand(features, action).was_input_pressed(XREFeatureSettings.button_input(button))


## Whether the button of [param action] is down.
func is_action_held(features: XREFeatureSettings, action: StringName) -> bool:
	if is_capturing():
		return false
	var button := XREFeatureSettings.binding_of(features, action)
	return get_action_hand(features, action).is_input_held(XREFeatureSettings.button_input(button))


## The hand of [param button], a key of [constant XREFeatureSettings.BUTTONS].
func get_button_hand(button: StringName) -> XREHand:
	return left_hand if XREFeatureSettings.button_hand(button) == &"left_hand" else right_hand


func _any_button_held() -> bool:
	for button: StringName in XREFeatureSettings.BUTTONS:
		if get_button_hand(button).is_input_held(XREFeatureSettings.button_input(button)):
			return true
	return false


## Whether a controller currently provides its physical grip pose.
func has_grip_pose(hand: XREHand) -> bool:
	var model := right_controller if hand == right_hand else left_controller
	return model.get_has_tracking_data()


## Physical grip pose for touch/grab; aim is the fallback for trackers without grip.
func hand_pose(hand: XREHand, physical: bool = false) -> Transform3D:
	var model := right_controller if hand == right_hand else left_controller
	return model.global_transform if physical and model.get_has_tracking_data() else hand.global_transform


func _notification(what: int) -> void:
	# XROrigin3D publishes its transform to XRServer only outside the editor
	# (scene/3d/xr/xr_nodes.cpp checks is_editor_hint()). Both eyes are rendered
	# relative to XRServer.world_origin, so the rig publishes it itself.
	if what == NOTIFICATION_ENTER_TREE or what == NOTIFICATION_TRANSFORM_CHANGED:
		XRServer.world_origin = global_transform


## A mesh only the headset shows: on [constant VR_LAYER], casting no shadow
## (shadows are culled by the light, not the camera, so a VR-layer shadow would
## show up in the desktop viewport) and left out of global illumination.
static func create_vr_mesh(mesh: Mesh, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.layers = VR_LAYER
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	return instance


## Text only the headset shows, as [method create_vr_mesh] does for meshes,
## turned to face the viewer. [param pixel_size] is in meters per pixel of
## [param font_size].
static func create_vr_label(font_size: int, pixel_size: float) -> Label3D:
	var label := Label3D.new()
	label.layers = VR_LAYER
	label.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	label.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font = vr_font()
	label.font_size = font_size
	label.pixel_size = pixel_size
	return label


## The default font as a multichannel signed distance field: 3D text stays sharp
## up close and far away instead of shimmering from a fixed-size glyph atlas.
static func vr_font() -> Font:
	if _vr_font == null:
		var base := ThemeDB.fallback_font as FontFile
		if base == null or base.data.is_empty(): return ThemeDB.fallback_font
		_vr_font = FontFile.new()
		_vr_font.data = base.data
		_vr_font.multichannel_signed_distance_field = true
	return _vr_font
