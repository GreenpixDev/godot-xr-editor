extends Node3D
## Root of the Blueprints demo room (docs/blueprints.md, "Demo room"): a table
## with four stations, each a button and what it drives. The buttons are
## Area3D; whatever enters one presses it, and the stations' graphs listen to
## its area_entered.
##
## The player is built when the game starts, not saved in the scene, for the
## reason benchmarks/play_check.gd gives. In the headset the hands carry a poke
## tip; without one (a plain window) the mouse pokes the button under it.

const _TIP_RADIUS := 0.012
const _CONTROLLER_SIZE := Vector3(0.04, 0.04, 0.12)
const _AWAY := Vector3(0.0, -10.0, 0.0)
## How long the mouse's tip stays on a button, in seconds.
const _POKE_SEC := 0.25

var _mouse_tip: Area3D
var _camera: Camera3D


func _ready() -> void:
	var xr := XRServer.find_interface("OpenXR") as OpenXRInterface
	if xr != null and xr.is_initialized():
		_build_headset_player()
	else:
		_build_window_player()


## Moves the window player's tip onto [param button] for a moment, as a hand
## pressing it would. Not awaited: the press ends on its own.
func poke(button: Area3D) -> void:
	if _mouse_tip == null or not is_instance_valid(button):
		return
	_mouse_tip.global_position = button.global_position
	get_tree().create_timer(_POKE_SEC).timeout.connect(_release_tip, CONNECT_ONE_SHOT)


func _release_tip() -> void:
	if is_instance_valid(_mouse_tip):
		_mouse_tip.global_position = _AWAY


func _build_headset_player() -> void:
	# As in Godot's XR setup guide: the runtime paces frames, not the monitor.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	get_viewport().use_xr = true
	var origin := XROrigin3D.new()
	add_child(origin)
	origin.add_child(XRCamera3D.new())
	for tracker: StringName in [&"left_hand", &"right_hand"]:
		var mesh := BoxMesh.new()
		mesh.size = _CONTROLLER_SIZE
		var body := MeshInstance3D.new()
		body.mesh = mesh
		body.position = Vector3(0.0, 0.0, _CONTROLLER_SIZE.z / 2.0)
		var controller := XRController3D.new()
		controller.tracker = tracker
		controller.pose = &"aim"
		controller.show_when_tracked = true
		controller.add_child(body)
		var tip := _make_tip()
		tip.position = Vector3(0.0, 0.0, -0.02)
		controller.add_child(tip)
		origin.add_child(controller)


func _build_window_player() -> void:
	_camera = Camera3D.new()
	add_child(_camera)
	_camera.position = Vector3(0.0, 1.55, 0.55)
	_camera.look_at_from_position(_camera.position, Vector3(0.0, 0.8, -0.8))
	_camera.current = true
	_mouse_tip = _make_tip()
	add_child(_mouse_tip)
	_mouse_tip.global_position = _AWAY


func _unhandled_input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if _camera == null or click == null or not click.pressed or click.button_index != MOUSE_BUTTON_LEFT:
		return
	var from := _camera.project_ray_origin(click.position)
	var query := PhysicsRayQueryParameters3D.create(from, from + _camera.project_ray_normal(click.position) * 6.0)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and hit["collider"] is Area3D:
		poke(hit["collider"] as Area3D)


func _make_tip() -> Area3D:
	var shape := SphereShape3D.new()
	shape.radius = _TIP_RADIUS
	var collision := CollisionShape3D.new()
	collision.shape = shape
	var tip := Area3D.new()
	tip.name = "PokeTip"
	tip.add_child(collision)
	return tip
