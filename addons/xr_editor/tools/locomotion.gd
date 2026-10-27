@tool
class_name XRELocomotion
extends Node
## Moves the user through the edited scene with the thumbsticks
## (docs/decisions.md, D-015).
##
## Controls:
## [br]- Left thumbstick: fly. Forward and back go where the left controller
## points (where the head looks, with [member XRERig.fly_along_gaze]), up and
## down included; left and right go sideways, level. Speed
## grows with the tilt, up to the flying speed.
## [br]- Left thumbstick click: next flying speed of [constant SPEEDS], round
## and round. The speed shows in front of the user for a moment.
## [br]- Right thumbstick, left and right: turn about the head, up to
## [constant MAX_TURN_SPEED]. Up and down leave the horizon unchanged.
## Not while the right hand points at a panel:
## the stick scrolls it then ([method XREHand.claim_stick]).
## [br]- Right thumbstick click: no navigation action.
## [br][br]
## Turning is about the world vertical and leaves the play space level.
## [br][br]
## While the user moves or turns, a vignette darkens the edges of the
## view against motion sickness, the more the faster. Moves the [XRERig], and
## nothing else: the scene is not changed, so nothing is recorded. Lives under
## the rig, before the other tools, so that they see where the rig is this frame.

## Flying speeds with the stick all the way, in meters per second: slow for
## fine positioning, walking pace, and fast to cross a level.
const SPEEDS: Array[float] = [0.5, 1.5, 4.0]
## Index in [constant SPEEDS] of the speed the user starts with.
const DEFAULT_SPEED := 1
## How long the speed shows after a click, in seconds.
const SPEED_LABEL_SEC := 1.0
## Where the speed shows, relative to the head, in meters.
const SPEED_LABEL_OFFSET := Vector3(0.0, -0.15, -0.8)
## Turning speed with the stick all the way, in degrees per second.
const MAX_TURN_SPEED := 90.0
## Stick tilt that counts as none: resting sticks drift a little.
const DEAD_ZONE := 0.15
## Angle from the view's center where the vignette begins to darken, and where
## it is fully dark at full speed, in degrees.
const VIGNETTE_INNER := 30.0
const VIGNETTE_OUTER := 55.0
## How fast the vignette follows the speed, in full fades per second, so that it doesn't flicker.
const VIGNETTE_RATE := 4.0
## Radius of the sphere the vignette is drawn on, around the head, in meters.
const _VIGNETTE_RADIUS := 0.3

const _SHADER := """
shader_type spatial;
render_mode unshaded, cull_front, depth_test_disabled, shadows_disabled;

uniform float strength = 0.0;
uniform float inner = 0.5;
uniform float outer = 1.0;

varying vec3 direction;

void vertex() {
	// The sphere is centered on the head camera: its own space is the view's.
	direction = VERTEX;
}

void fragment() {
	float angle = acos(clamp(dot(normalize(direction), vec3(0.0, 0.0, -1.0)), -1.0, 1.0));
	ALBEDO = vec3(0.0);
	ALPHA = smoothstep(inner, outer, angle) * strength;
}
"""

var _rig: XRERig
var _document: XREDocument
var _vignette: MeshInstance3D
var _vignette_material: ShaderMaterial
var _strength := 0.0
var _speed := DEFAULT_SPEED
var _speed_label: Label3D
var _speed_label_until_usec := 0


## [param document] gives the binding of the speed button; without one it is the default layout's.
func _init(rig: XRERig, document: XREDocument = null) -> void:
	_rig = rig
	_document = document
	var shader := Shader.new()
	shader.code = _SHADER
	_vignette_material = ShaderMaterial.new()
	_vignette_material.shader = shader
	_vignette_material.render_priority = Material.RENDER_PRIORITY_MAX
	_vignette_material.set_shader_parameter(&"inner", deg_to_rad(VIGNETTE_INNER))
	_vignette_material.set_shader_parameter(&"outer", deg_to_rad(VIGNETTE_OUTER))
	var sphere := SphereMesh.new()
	sphere.radius = _VIGNETTE_RADIUS
	sphere.height = _VIGNETTE_RADIUS * 2.0
	_vignette = XRERig.create_vr_mesh(sphere, _vignette_material)
	_vignette.name = "Vignette"
	_vignette.visible = false
	_speed_label = XRERig.create_vr_label(40, 0.0005)
	_speed_label.no_depth_test = true
	_speed_label.outline_size = 10
	_speed_label.position = SPEED_LABEL_OFFSET
	_speed_label.visible = false
	# Both follow the head, and go with the rig.
	rig.camera.add_child(_vignette)
	rig.camera.add_child(_speed_label)


func _process(delta: float) -> void:
	if _rig.is_action_pressed(_document.features if _document != null else null, XREFeatureSettings.SPEED):
		_speed = (_speed + 1) % SPEEDS.size()
		_speed_label.text = "Flying speed %.1f m/s" % SPEEDS[_speed]
		_speed_label.visible = true
		_speed_label_until_usec = Time.get_ticks_usec() + int(SPEED_LABEL_SEC * 1000000.0)
	elif _speed_label.visible and Time.get_ticks_usec() >= _speed_label_until_usec:
		_speed_label.visible = false

	# A stick another tool claimed, like the right one over a panel ([XREPanels]), moves nothing.
	var move := Vector2.ZERO
	if _rig.left_hand.is_stick_free_for(self):
		move = _tilt(_rig.left_hand.get_vector2(&"primary"))
	# Each axis has its own dead zone, so that a push straight up doesn't turn.
	var turn := Vector2.ZERO
	var right := _rig.right_hand
	if right.is_stick_free_for(self):
		var stick := right.get_vector2(&"primary")
		turn.x = _axis_tilt(stick.x)

	if not move.is_zero_approx():
		var aim := _rig.camera.global_basis if _rig.fly_along_gaze else _rig.left_hand.global_basis
		var forward := -aim.z.normalized()
		var side := Vector3(aim.x.x, 0.0, aim.x.z)
		side = side.normalized() if not side.is_zero_approx() else Vector3.ZERO
		_rig.global_position += (forward * move.y + side * move.x) * SPEEDS[_speed] * delta
	var pivot := _rig.camera.global_position
	if not is_zero_approx(turn.x):
		_rig.global_transform = turned(_rig.global_transform, pivot, -deg_to_rad(turn.x * MAX_TURN_SPEED * delta))
	_update_vignette(maxf(move.length(), absf(turn.x)), delta)


## [param rig] turned by [param angle] radians about the vertical line through
## [param pivot]; positive turns to the left, seen from above.
static func turned(rig: Transform3D, pivot: Vector3, angle: float) -> Transform3D:
	return Transform3D(Basis(Vector3.UP, angle), pivot) * Transform3D(Basis.IDENTITY, -pivot) * rig


## How far a stick at [param stick] is tilted past the dead zone, 0 to 1 along each axis' direction.
static func _tilt(stick: Vector2) -> Vector2:
	var length := stick.length()
	if length <= DEAD_ZONE:
		return Vector2.ZERO
	return stick / length * minf((length - DEAD_ZONE) / (1.0 - DEAD_ZONE), 1.0)


## How far one stick axis, [param value], is tilted past the dead zone, -1 to 1.
static func _axis_tilt(value: float) -> float:
	return _tilt(Vector2(value, 0.0)).x


## How dark the edges of the view are, 0 to 1.
func get_vignette_strength() -> float:
	return _strength


## Flying speed with the stick all the way, in meters per second.
func get_speed() -> float:
	return SPEEDS[_speed]


## The speed shown in front of the user, or an empty string if none is.
func get_speed_label() -> String:
	return _speed_label.text if _speed_label.visible else ""


func _update_vignette(target: float, delta: float) -> void:
	var strength := move_toward(_strength, target, VIGNETTE_RATE * delta)
	if strength == _strength:
		return
	_strength = strength
	_vignette.visible = strength > 0.0
	_vignette_material.set_shader_parameter(&"strength", strength)
