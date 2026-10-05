@tool
class_name XREControllerModel
extends XRController3D
## The model of one physical controller in the VR view, with its trigger, grip,
## thumbstick and buttons moving as the user works them.
##
## Follows the tracker's grip pose: models from the WebXR input profiles
## (github.com/immersive-web/webxr-input-profiles) have their origin there, so
## none needs an offset. The model is picked by the tracker's OpenXR interaction
## profile from [constant MODELS]. Until the runtime reports a profile, and for a
## profile missing from the table, the model is [constant DEFAULT_MODEL].
## [br][br]
## How the parts move comes from the [code]profile.json[/code] next to the model:
## each visual response names a node to place between a min and a max node, and
## the weight is computed as in the reference library
## (@webxr-input-profiles/motion-controllers 1.0.0). Parts follow the
## controller's input signals rather than being updated every frame. A part
## whose input XREEditorControllers doesn't publish (the thumbrest) or whose
## nodes the model lacks stays put.
## [br][br]
## To add a controller, copy its [code]left.glb[/code], [code]right.glb[/code] and
## [code]profile.json[/code] from the WebXR input profiles into a folder under
## [constant MODELS_DIR] and map its interaction profile to that folder in
## [constant MODELS]. The runtime only reports profiles that
## XREEditorControllers suggests bindings for (gdextension/src/editor_controllers.cpp)
## and passes any other controller off as the closest of them, so a new profile
## needs bindings there as well.

## Folder with one subfolder per controller model.
const MODELS_DIR := "res://addons/xr_editor/xr/controller_models/"
## Model subfolder of [constant MODELS_DIR] for each OpenXR interaction profile.
const MODELS: Dictionary[String, String] = {
	"/interaction_profiles/oculus/touch_controller": "oculus_touch_v3",
}
## Model shown before the runtime reports a profile and for profiles missing from [constant MODELS].
const DEFAULT_MODEL := "oculus_touch_v3"

## Tracker input (published by XREEditorControllers) behind the button or
## trigger of each WebXR component id that profile.json files use.
const _BUTTON_INPUTS: Dictionary[String, String] = {
	"xr-standard-trigger": "trigger",
	"xr-standard-squeeze": "grip",
	"xr-standard-thumbstick": "primary_click",
	"x-button": "ax_button",
	"a-button": "ax_button",
	"y-button": "by_button",
	"b-button": "by_button",
	"menu": "menu_button",
}
## Tracker input behind the axes of each WebXR component id.
const _AXES_INPUTS: Dictionary[String, String] = {
	"xr-standard-thumbstick": "primary",
}
## The reference library's thresholds above which a component counts as touched.
const _BUTTON_TOUCH_THRESHOLD := 0.05
const _AXIS_TOUCH_THRESHOLD := 0.1
## Profile XREEditorControllers reports while the hand has no controller.
const _NO_PROFILE := "none"
const _LOG_PREFIX := "XR Editor: "


## A moving part: a node placed between two poses, or shown and hidden, by one
## value of its component.
class _Part:
	var node: Node3D
	var min_transform: Transform3D
	var max_transform: Transform3D
	## Which value of the component drives it: "button", "xAxis", "yAxis" or "state".
	var property: String
	## Component states in which the part follows that value; in others it rests.
	var states: PackedStringArray
	## Shown and hidden instead of moved.
	var visibility: bool


## A control of the controller (trigger, thumbstick, a button) and the parts it moves.
class _Component:
	## 0 to 1.
	var button := 0.0
	## -1 to 1 in the WebXR convention: +Y is the thumbstick pulled back.
	var axes := Vector2.ZERO
	var parts: Array[_Part] = []


## "left" or "right".
var _side: String
var _tracker: XRPositionalTracker
var _model_name := ""
var _model: Node3D
## The components of the shown model by the tracker inputs that drive them.
var _components: Dictionary[String, _Component] = {}


func _init(node_name: String, tracker_name: StringName, hand: XRPositionalTracker.TrackerHand) -> void:
	name = node_name
	tracker = tracker_name
	pose = &"grip"
	show_when_tracked = true
	_side = "left" if hand == XRPositionalTracker.TRACKER_HAND_LEFT else "right"
	button_pressed.connect(_on_button.bind(1.0))
	button_released.connect(_on_button.bind(0.0))
	input_float_changed.connect(_on_button)
	input_vector2_changed.connect(_on_axes)
	# Loaded with the plugin: a model loaded mid-session stalls a frame in the headset.
	_show_model(DEFAULT_MODEL)


func _enter_tree() -> void:
	XRServer.tracker_added.connect(_on_tracker_added)
	XRServer.tracker_removed.connect(_on_tracker_removed)
	_watch_tracker(XRServer.get_tracker(tracker) as XRPositionalTracker)


func _exit_tree() -> void:
	XRServer.tracker_added.disconnect(_on_tracker_added)
	XRServer.tracker_removed.disconnect(_on_tracker_removed)
	_watch_tracker(null)


## The subfolder of [constant MODELS_DIR] whose model is shown.
func get_model_name() -> String:
	return _model_name


func _on_tracker_added(tracker_name: StringName, _type: int) -> void:
	if tracker_name == tracker:
		_watch_tracker(XRServer.get_tracker(tracker) as XRPositionalTracker)


func _on_tracker_removed(tracker_name: StringName, _type: int) -> void:
	if tracker_name == tracker:
		_watch_tracker(null)


func _watch_tracker(new_tracker: XRPositionalTracker) -> void:
	if _tracker != null:
		_tracker.profile_changed.disconnect(_on_profile_changed)
	_tracker = new_tracker
	if _tracker != null:
		_tracker.profile_changed.connect(_on_profile_changed)
		_on_profile_changed(_tracker.profile)


func _on_profile_changed(profile: String) -> void:
	# Without a controller the node is hidden anyway: keep the model it had.
	if profile.is_empty() or profile == _NO_PROFILE:
		return
	var model_name: String = MODELS.get(profile, DEFAULT_MODEL)
	_show_model(model_name)
	print(_LOG_PREFIX, "%s controller model %s for %s%s." % [
		tracker, _model_name, profile, "" if MODELS.has(profile) else " (no model of its own)"])


func _on_button(input: String, value: float) -> void:
	var component: _Component = _components.get(input)
	if component != null:
		component.button = clampf(value, 0.0, 1.0)
		_move_parts(component)


func _on_axes(input: String, value: Vector2) -> void:
	var component: _Component = _components.get(input)
	if component != null:
		component.axes = _webxr_axes(value)
		_move_parts(component)


## Replaces the shown model with [param model_name]'s, unless it is already shown.
func _show_model(model_name: String) -> void:
	if model_name == _model_name:
		return
	var folder := MODELS_DIR.path_join(model_name)
	var path := folder.path_join(_side + ".glb")
	var scene := load(path) as PackedScene
	if scene == null:
		push_error("XR Editor: no controller model at %s." % path)
		return
	if _model != null:
		_model.queue_free()
	_model = scene.instantiate() as Node3D
	# Same treatment as XRERig.create_vr_mesh(): headset only, no shadow, no GI.
	for node: Node in _model.find_children("*", "GeometryInstance3D", true, false):
		var geometry := node as GeometryInstance3D
		geometry.layers = XRERig.VR_LAYER
		geometry.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		geometry.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	add_child(_model)
	_model_name = model_name
	_find_parts(folder.path_join("profile.json"))


## Reads the moving parts of the shown model from its profile.json. A model
## without one is static.
func _find_parts(profile_path: String) -> void:
	_components.clear()
	if not FileAccess.file_exists(profile_path):
		return
	var profile: Variant = JSON.parse_string(FileAccess.get_file_as_string(profile_path))
	var descriptions := _dictionary(_dictionary(_dictionary(profile, "layouts"), _side), "components")
	for component_id: String in descriptions:
		var button_input: String = _BUTTON_INPUTS.get(component_id, "")
		var axes_input: String = _AXES_INPUTS.get(component_id, "")
		if button_input.is_empty() and axes_input.is_empty():
			continue
		var component := _Component.new()
		var responses := _dictionary(_dictionary(descriptions, component_id), "visualResponses")
		for response_id: String in responses:
			var part := _find_part(_dictionary(responses, response_id))
			if part != null:
				component.parts.append(part)
		if component.parts.is_empty():
			continue
		if not button_input.is_empty():
			_components[button_input] = component
			component.button = _read_button(button_input)
		if not axes_input.is_empty():
			_components[axes_input] = component
			var axes: Variant = get_input(axes_input)
			if axes is Vector2:
				component.axes = _webxr_axes(axes as Vector2)
		_move_parts(component)


## The part a visual response describes, or null if the model lacks its nodes:
## the Touch v3 profile lists a menu button that the model doesn't have.
func _find_part(response: Dictionary) -> _Part:
	var part := _Part.new()
	part.property = str(response.get("componentProperty", ""))
	var states: Variant = response.get("states")
	if states is Array:
		part.states = PackedStringArray(states as Array)
	part.visibility = str(response.get("valueNodeProperty", "")) == "visibility"
	part.node = _model.find_child(str(response.get("valueNodeName", "")), true, false) as Node3D
	if part.node == null:
		return null
	if not part.visibility:
		var min_node := _model.find_child(str(response.get("minNodeName", "")), true, false) as Node3D
		var max_node := _model.find_child(str(response.get("maxNodeName", "")), true, false) as Node3D
		if min_node == null or max_node == null:
			return null
		part.min_transform = min_node.transform
		part.max_transform = max_node.transform
	return part


## Places the parts of [param component] as the reference library's
## Component.updateFromGamepad() and VisualResponse.updateFromComponent() do.
func _move_parts(component: _Component) -> void:
	var state := "default"
	if component.button >= 1.0:
		state = "pressed"
	elif component.button > _BUTTON_TOUCH_THRESHOLD \
			or absf(component.axes.x) > _AXIS_TOUCH_THRESHOLD or absf(component.axes.y) > _AXIS_TOUCH_THRESHOLD:
		state = "touched"
	# The stick's square range clipped to a circle and mapped to 0..1.
	var axes := component.axes.normalized() if component.axes.length_squared() > 1.0 else component.axes
	axes = axes * 0.5 + Vector2(0.5, 0.5)
	for part: _Part in component.parts:
		var active := part.states.has(state)
		var value := 1.0 if active else 0.0
		match part.property:
			"button":
				value = component.button if active else 0.0
			"xAxis":
				value = axes.x if active else 0.5
			"yAxis":
				value = axes.y if active else 0.5
		if part.visibility:
			part.node.visible = value > 0.0
		else:
			part.node.transform = part.min_transform.interpolate_with(part.max_transform, value)


## The current value of a button or trigger input, 0 to 1.
func _read_button(input: String) -> float:
	var value: Variant = get_input(input)
	if value is bool:
		return 1.0 if (value as bool) else 0.0
	if value is float:
		return clampf(value as float, 0.0, 1.0)
	return 0.0


## Godot's thumbstick axes have +Y pushed forward; WebXR's have +Y pulled back.
static func _webxr_axes(value: Vector2) -> Vector2:
	return Vector2(clampf(value.x, -1.0, 1.0), clampf(-value.y, -1.0, 1.0))


## [param data][lb][param key][rb] if both are dictionaries, otherwise an empty one:
## profile.json is read without a schema.
static func _dictionary(data: Variant, key: String) -> Dictionary:
	if data is Dictionary:
		var value: Variant = (data as Dictionary).get(key)
		if value is Dictionary:
			return value
	return {}
