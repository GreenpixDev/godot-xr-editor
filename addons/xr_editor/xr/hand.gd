@tool
class_name XREHand
extends XRController3D
## One controller in the VR view: its pointing ray and the state of its trigger,
## grip and A or X button. The controller itself is drawn by [XREControllerModel].
##
## Follows the tracker's aim pose: the ray starts at the node's origin and
## points down -Z. Trigger and grip are analog. Each counts as held above
## [constant PRESS_THRESHOLD] and as let go below [constant RELEASE_THRESHOLD],
## so a finger resting halfway doesn't flicker between the two.
## [br][br]
## Several tools read the same hand. A tool that hovers over or holds something
## with the hand claims it ([method claim]); the others leave a claimed hand
## alone, so that one press does one thing. The thumbstick is claimed apart
## ([method claim_stick]): a tool may hold an object with the hand while the
## user still flies and turns with its stick.

## Length of the ray when it points at nothing, in meters.
const RAY_LENGTH := 2.0
const PRESS_THRESHOLD := 0.6
const RELEASE_THRESHOLD := 0.4

const _RAY_WIDTH := 0.004
const _DOT_RADIUS := 0.008

## Trigger is held down.
var trigger_held := false
## Trigger went down since the previous [method update_input].
var trigger_pressed := false
## Trigger went up since the previous [method update_input].
var trigger_released := false
## Grip is held down.
var grip_held := false
## Grip went down since the previous [method update_input].
var grip_pressed := false
## Grip went up since the previous [method update_input].
var grip_released := false
## A (right controller) or X (left) is held down.
var ax_held := false
## A or X went down since the previous [method update_input].
var ax_pressed := false
## The thumbstick is pressed in.
var stick_click_held := false
## The thumbstick went in since the previous [method update_input].
var stick_click_pressed := false

## Buttons [method is_input_held] and [method was_input_pressed] answer for.
const _BUTTON_INPUTS: Array[StringName] = [&"ax_button", &"by_button", &"primary_click", &"menu_button"]

## The tool that claimed the hand, or null.
var _claimed_by: Object
## The tool that claimed the thumbstick, or null.
var _stick_claimed_by: Object
## Which of [constant _BUTTON_INPUTS] is down, and which went down this frame.
var _input_held: Dictionary[StringName, bool] = {}
var _input_pressed: Dictionary[StringName, bool] = {}
var _ray: MeshInstance3D
var _dot: MeshInstance3D
var _ray_material: StandardMaterial3D
var _hit_material: StandardMaterial3D
var _ray_hits := false


func _init(node_name: String, tracker_name: StringName, color: Color) -> void:
	name = node_name
	tracker = tracker_name
	pose = &"aim"
	show_when_tracked = true

	_ray_material = _unshaded(color)
	_hit_material = _unshaded(Color.WHITE)

	# One meter long, stretched to the ray's length with scale.z.
	var ray_mesh := BoxMesh.new()
	ray_mesh.size = Vector3(_RAY_WIDTH, _RAY_WIDTH, 1.0)
	_ray = XRERig.create_vr_mesh(ray_mesh, _ray_material)
	add_child(_ray)

	var dot_mesh := SphereMesh.new()
	dot_mesh.radius = _DOT_RADIUS
	dot_mesh.height = _DOT_RADIUS * 2.0
	_dot = XRERig.create_vr_mesh(dot_mesh, _hit_material)
	_dot.visible = false
	add_child(_dot)

	show_ray(RAY_LENGTH, false)


## Reads trigger, grip, A or X and the thumbstick's click. [XRERig] calls it
## once per frame, before the tools under it read the fields above. Without
## tracking or focus the runtime reports every button as released.
func update_input() -> void:
	var was_held := trigger_held
	trigger_held = get_float(&"trigger") > (RELEASE_THRESHOLD if was_held else PRESS_THRESHOLD)
	trigger_pressed = trigger_held and not was_held
	trigger_released = was_held and not trigger_held

	was_held = grip_held
	grip_held = get_float(&"grip") > (RELEASE_THRESHOLD if was_held else PRESS_THRESHOLD)
	grip_pressed = grip_held and not was_held
	grip_released = was_held and not grip_held

	for input: StringName in _BUTTON_INPUTS:
		was_held = _input_held.get(input, false)
		var held := is_button_pressed(input)
		_input_held[input] = held
		_input_pressed[input] = held and not was_held

	ax_held = _input_held[&"ax_button"]
	ax_pressed = _input_pressed[&"ax_button"]
	stick_click_held = _input_held[&"primary_click"]
	stick_click_pressed = _input_pressed[&"primary_click"]


## Whether button [param input] of the tracker ([code]ax_button[/code],
## [code]by_button[/code], [code]primary_click[/code] or [code]menu_button[/code]) is down.
func is_input_held(input: StringName) -> bool:
	return _input_held.get(input, false)


## Whether button [param input] went down since the previous [method update_input].
func was_input_pressed(input: StringName) -> bool:
	return _input_pressed.get(input, false)


## Whether [param tool] may act on this hand: no other tool has claimed it.
func is_free_for(tool: Object) -> bool:
	return _claimed_by == null or _claimed_by == tool


## Claims the hand for [param tool] until it calls [method unclaim]. Tools run
## in tree order, so the one that claims on hover must run before the others.
func claim(tool: Object) -> void:
	_claimed_by = tool


## The tool that has claimed the hand, or null.
func get_claimant() -> Object:
	return _claimed_by


## Lets go of the hand, if [param tool] has claimed it.
func unclaim(tool: Object) -> void:
	if _claimed_by == tool:
		_claimed_by = null


## Whether [param tool] may read the thumbstick: no other tool has claimed it.
func is_stick_free_for(tool: Object) -> bool:
	return _stick_claimed_by == null or _stick_claimed_by == tool


## Claims the thumbstick for [param tool] until it calls [method unclaim_stick].
## Tools that read sticks every frame see a claim made in the previous frame.
func claim_stick(tool: Object) -> void:
	_stick_claimed_by = tool


## Lets go of the thumbstick, if [param tool] has claimed it.
func unclaim_stick(tool: Object) -> void:
	if _stick_claimed_by == tool:
		_stick_claimed_by = null


## Shows the ray [param length] meters long. With [param hit], the ray is
## highlighted and ends in a dot. [param dot_offset] lifts the dot towards the
## controller for surface UI, without changing the ray's hit distance or depth test.
func show_ray(length: float, hit: bool, dot_offset: float = 0.0) -> void:
	# A ray that starts inside a box hits it at 0 m; keep the scale invertible.
	length = maxf(length, _DOT_RADIUS)
	_ray.visible = true
	_ray.basis = Basis.IDENTITY
	_ray.scale = Vector3(1.0, 1.0, length)
	_ray.position = Vector3(0.0, 0.0, -length / 2.0)
	if hit != _ray_hits:
		_ray_hits = hit
		_ray.material_override = _hit_material if hit else _ray_material
		_dot.visible = hit
	if hit:
		_dot.position = Vector3(0.0, 0.0, -maxf(length - dot_offset, _DOT_RADIUS))


## Keeps pointer visuals above the scene-only logic dimmer.
func set_overlay(enabled: bool) -> void:
	for material: StandardMaterial3D in [_ray_material, _hit_material]:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if enabled else BaseMaterial3D.TRANSPARENCY_DISABLED
		material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS if enabled else BaseMaterial3D.DEPTH_DRAW_OPAQUE_ONLY
		material.render_priority = Material.RENDER_PRIORITY_MAX if enabled else 0


func hide_ray() -> void:
	if not _ray.visible:
		return
	_ray.visible = false
	_dot.visible = false
	_ray_hits = false
	_ray.material_override = _ray_material


func _unshaded(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	return material
