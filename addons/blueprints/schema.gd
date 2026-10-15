@tool
class_name XREBlueprintSchema
extends RefCounted
## Reflection and supported value types for scene-bound graph ports.

const LITERAL_TYPES: Array[int] = [TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]


## Human-readable type name, also used in diagnostics and port tooltips.
static func type_name(type: int) -> String:
	return "Variant" if type == TYPE_NIL else type_string(type)


## Safe implicit conversions. Narrowing a float to an integer is explicit.
static func accepts(expected: int, actual: int) -> bool:
	return expected == TYPE_NIL or expected == actual or (expected == TYPE_FLOAT and actual == TYPE_INT) or (expected in [TYPE_STRING, TYPE_STRING_NAME] and actual in [TYPE_STRING, TYPE_STRING_NAME])


## Default literal for a supported type.
static func default_value(type: int) -> Variant:
	match type:
		TYPE_BOOL: return false
		TYPE_INT: return 0
		TYPE_FLOAT: return 0.0
		TYPE_STRING, TYPE_STRING_NAME: return ""
		TYPE_VECTOR2: return Vector2.ZERO
		TYPE_VECTOR3: return Vector3.ZERO
		TYPE_COLOR: return Color.WHITE
	return null


## Describes a property without accessing a nonexistent property. Component paths
## such as position:x are supported for vectors and colors.
static func property_info(object: Object, path: String) -> Dictionary:
	var parts := path.split(":")
	var current: Variant = object
	var info: Dictionary = {}
	for index: int in parts.size():
		var name: String = parts[index]
		info = {}
		if current is Object and is_instance_valid(current):
			for entry: Dictionary in (current as Object).get_property_list():
				if str(entry["name"]) == name:
					info = entry.duplicate()
					break
			if info.is_empty():
				return {}
			current = (current as Object).get(name)
		elif current is Vector2 and name in ["x", "y"]:
			current = (current as Vector2)[0 if name == "x" else 1]
			info = {"type": TYPE_FLOAT}
		elif current is Vector3 and name in ["x", "y", "z"]:
			current = (current as Vector3)[["x", "y", "z"].find(name)]
			info = {"type": TYPE_FLOAT}
		elif current is Color and name in ["r", "g", "b", "a"]:
			current = (current as Color)[["r", "g", "b", "a"].find(name)]
			info = {"type": TYPE_FLOAT}
		else:
			return {}
	info["value"] = current
	return info


## Properties that the current block library can edit or read.
static func properties(object: Object) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for info: Dictionary in object.get_property_list():
		if int(info["type"]) in LITERAL_TYPES and int(info["usage"]) & PROPERTY_USAGE_EDITOR and str(info["name"]) != "script":
			result.append(info)
	return result


## Signal argument descriptors copied into a graph, never live Object references.
static func signal_arguments(object: Object, signal_name: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for info: Dictionary in object.get_signal_list():
		if str(info["name"]) == signal_name:
			for argument: Dictionary in info["args"]:
				result.append({"name": str(argument["name"]), "type": int(argument["type"]), "class_name": str(argument.get("class_name", ""))})
	return result


## Fundamental target requirements, independent of the selected member name.
## The picker can disable these nodes while keeping other nodes available for configuration.
static func target_kind_problem(kind: String, target: Node) -> String:
	if kind == "play_animation" and not target is AnimationPlayer:
		return "requires AnimationPlayer"
	if kind == "play_sound" and not (target is AudioStreamPlayer or target is AudioStreamPlayer2D or target is AudioStreamPlayer3D):
		return "requires an audio player"
	return ""


## Shared target suitability rules for the field, suggestions, picker and build.
static func target_problem(block: Dictionary, target: Node) -> String:
	if target == null: return "missing target"
	var kind: String = block["kind"]
	var problem := target_kind_problem(kind, target)
	if not problem.is_empty(): return problem
	var params: Dictionary = block["params"]
	if params.has("property"):
		var property: String = params["property"]
		var info := property_info(target, property)
		if info.is_empty(): return "missing property: " + property
		if kind in ["set_property", "tween"] and int(info.get("usage", 0)) & PROPERTY_USAGE_READ_ONLY:
			return "read-only property: " + property
		if kind == "tween" and not int(info["type"]) in [TYPE_INT, TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]:
			return "property cannot be tweened: " + property
	if kind == "signal" and not target.has_signal(params["signal"]):
		return "missing signal: " + str(params["signal"])
	if kind == "play_animation":
		var player := target as AnimationPlayer
		if not player.has_animation(params["animation"]): return "missing animation: " + str(params["animation"])
		if params["wait"] and player.get_animation(params["animation"]).loop_mode != Animation.LOOP_NONE:
			return "cannot wait for a looping animation"
	return ""
