@tool
class_name XRETransitionScreen
extends Node3D
## Covers the headset's view with black and a line of text while the headset
## goes from the editor to a game and back (docs/decisions.md, D-019).
##
## While an application is busy or closing, the headset keeps showing the last
## frame it drew, turned with the head: a frozen scene that goes black at the
## edges. Covered first, that frame is a still loading screen instead. On a
## standalone headset the editor takes about 3 s to close before the game
## starts; elsewhere the game takes its time to show up.
## [br][br]
## Goes under the head camera and follows it. Draws over the scene and over
## everything else on its layers, except the locomotion vignette, which is
## black too. [method cover] fades the view out, [method is_covered] says when
## the headset has been sent the covered view, and [method reveal] fades back
## in. Runs in the editor and in games: no editor API.

const _SPHERE_RADIUS := 0.5
## How far ahead of the eyes the text is, in meters, and how big: 48 px of
## 0.6 mm, a line about 1.4° high.
const _TEXT_DISTANCE := 1.2
const _FONT_SIZE := 48
const _PIXEL_SIZE := 0.0006
const _TEXT_COLOR := Color(0.85, 0.85, 0.85)
## Over everything but the vignette (the maximum); the text over the sphere.
const _SPHERE_PRIORITY := Material.RENDER_PRIORITY_MAX - 1
const _TEXT_PRIORITY := Material.RENDER_PRIORITY_MAX

## How long a fade takes, in seconds. At zero the view is covered and revealed at once.
var fade_sec := 0.25
## Frames drawn fully covered before [method is_covered] is true: the headset
## shows the last frame it got, and the latest one may still be on its way.
var frames_to_cover := 2

var _sphere_material: StandardMaterial3D
var _label: Label3D
## How covered the view is, from 0 to 1, and where it is going.
var _alpha := 0.0
var _target := 0.0
## Frames drawn since the view was fully covered.
var _covered_frames := 0


## [param layers]: render layers the head camera shows, and where the screen
## draws: the VR layer in the editor ([constant XRERig.VR_LAYER]).
func _init(layers: int) -> void:
	name = "XRETransitionScreen"
	# A game may be paused when it leaves for the editor.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	_sphere_material = StandardMaterial3D.new()
	_sphere_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_sphere_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_sphere_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_sphere_material.no_depth_test = true
	_sphere_material.render_priority = _SPHERE_PRIORITY
	var mesh := SphereMesh.new()
	mesh.radius = _SPHERE_RADIUS
	mesh.height = _SPHERE_RADIUS * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	var sphere := MeshInstance3D.new()
	sphere.name = "Sphere"
	sphere.mesh = mesh
	sphere.material_override = _sphere_material
	_set_up_geometry(sphere, layers)
	add_child(sphere)

	_label = Label3D.new()
	_label.name = "Text"
	_label.position = Vector3(0.0, 0.0, -_TEXT_DISTANCE)
	_label.font_size = _FONT_SIZE
	_label.pixel_size = _PIXEL_SIZE
	_label.outline_size = 0
	_label.no_depth_test = true
	_label.render_priority = _TEXT_PRIORITY
	_set_up_geometry(_label, layers)
	add_child(_label)
	_apply()


func _process(delta: float) -> void:
	if not visible:
		return
	if _target > 0.0 and _alpha >= 1.0:
		# The previous frame was drawn fully covered.
		_covered_frames += 1
	if not is_equal_approx(_alpha, _target):
		_alpha = move_toward(_alpha, _target, delta / fade_sec) if fade_sec > 0.0 else _target
		_apply()
	if _target <= 0.0 and _alpha <= 0.0:
		visible = false


## Fades the view out to [param text] on black, or covers it at once if
## [param at_once]. Already covered, it only changes the text.
func cover(text: String, at_once := false) -> void:
	_label.text = text
	if _target <= 0.0:
		_target = 1.0
		_covered_frames = 0
	if at_once or fade_sec <= 0.0:
		_alpha = 1.0
	visible = true
	_apply()


## Fades the view back in.
func reveal() -> void:
	_target = 0.0
	_covered_frames = 0
	if fade_sec <= 0.0:
		_alpha = 0.0
		visible = false
	_apply()


## Whether the view is covered or on its way to be.
func is_covering() -> bool:
	return _target > 0.0


## Whether the view has been fully covered for [member frames_to_cover] frames:
## what the headset shows if the application stops drawing now.
func is_covered() -> bool:
	return _target > 0.0 and _alpha >= 1.0 and _covered_frames >= frames_to_cover


## The text on the screen.
func get_text() -> String:
	return _label.text


func _apply() -> void:
	_sphere_material.albedo_color = Color(0.0, 0.0, 0.0, _alpha)
	_label.modulate = Color(_TEXT_COLOR, _alpha)


static func _set_up_geometry(geometry: GeometryInstance3D, layers: int) -> void:
	geometry.layers = layers
	geometry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	geometry.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
