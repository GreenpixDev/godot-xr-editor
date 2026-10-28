@tool
class_name XREBlueprintSchema
extends RefCounted
## Reflection and supported value types for scene-bound graph ports.

const LITERAL_TYPES: Array[int] = [TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]
## Property types a Tween can interpolate.
const TWEENABLE_TYPES: Array[int] = [TYPE_INT, TYPE_FLOAT, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]


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


## The enumeration, "Class.Enum", of property [param info] of class
## [param cls], empty when it has none (D-138). A script's property says it;
## an engine's says only its hint, its getter's result names it.
static func property_enum(cls: String, info: Dictionary) -> String:
	if int(info.get("type", TYPE_NIL)) != TYPE_INT: return ""
	if int(info.get("usage", 0)) & PROPERTY_USAGE_CLASS_IS_ENUM: return str(info.get("class_name", ""))
	if int(info.get("hint", 0)) != PROPERTY_HINT_ENUM or not ClassDB.class_exists(cls): return ""
	var getter := ClassDB.class_get_property_getter(cls, str(info["name"]))
	if getter.is_empty(): return ""
	for method: Dictionary in ClassDB.class_get_method_list(cls):
		if method["name"] != getter: continue
		var result: Dictionary = method["return"]
		return str(result["class_name"]) if int(result["usage"]) & PROPERTY_USAGE_CLASS_IS_ENUM else ""
	return ""


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


## Whether [param object] is of class [param cls]: an engine class, or a
## script's [code]class_name[/code] in its script's inheritance.
static func is_of_class(object: Object, cls: String) -> bool:
	if ClassDB.class_exists(cls): return object.is_class(cls)
	var script := object.get_script() as Script
	while script != null:
		if str(script.get_global_name()) == cls: return true
		script = script.get_base_script()
	return false


## Classes a call block's Target may be, empty for any node.
static func target_classes(block: Dictionary) -> Array:
	var function: Variant = block.get("function")
	return (function as Dictionary).get("targets", []) if block.get("kind") == "call" and function is Dictionary else []


## Fundamental target requirements, independent of the selected member name.
## The picker can disable these nodes while keeping other nodes available for configuration.
static func target_kind_problem(block: Dictionary, target: Node) -> String:
	var classes := target_classes(block)
	if classes.is_empty(): return ""
	for cls: Variant in classes:
		if is_of_class(target, str(cls)): return ""
	var names := PackedStringArray()
	for cls: Variant in classes: names.append(str(cls))
	if names.size() == 1: return "requires " + names[0]
	return "requires %s or %s" % [", ".join(names.slice(0, names.size() - 1)), names[names.size() - 1]]


## Names a value provider offers for an argument of [param target]: its
## animations, readable properties or signals ([XREBlueprintFunctions]).
static func provided_names(target: Object, provider: String) -> PackedStringArray:
	var names := PackedStringArray()
	if target == null: return names
	match provider:
		"animation":
			if target is AnimationMixer:
				for name: StringName in (target as AnimationMixer).get_animation_list(): names.append(str(name))
		"property":
			for info: Dictionary in properties(target): names.append(str(info["name"]))
		"signal":
			for info: Dictionary in target.get_signal_list(): names.append(str(info["name"]))
	return names


## Shared target suitability rules for the field, suggestions, picker and build.
static func target_problem(block: Dictionary, target: Node) -> String:
	if target == null: return "missing target"
	var kind: String = block["kind"]
	var problem := target_kind_problem(block, target)
	if not problem.is_empty(): return problem
	var params: Dictionary = block["params"]
	if kind in ["get_property", "set_property"]:
		var property: String = params["property"]
		var info := property_info(target, property)
		if info.is_empty(): return "missing property: " + property
		if kind == "set_property" and int(info.get("usage", 0)) & PROPERTY_USAGE_READ_ONLY:
			return "read-only property: " + property
	if kind == "signal" and not target.has_signal(params["signal"]):
		return "missing signal: " + str(params["signal"])
	if kind == "call":
		return _call_problem(block, target)
	return ""


static func _call_problem(block: Dictionary, target: Node) -> String:
	var function: Dictionary = block["function"]
	var params: Dictionary = block["params"]
	if function["scope"] == "method" and not target.has_method(str(function["name"])):
		return "missing method: " + str(function["name"])
	for argument: Dictionary in function["args"]:
		var provider := str(argument.get("provider", ""))
		if provider.is_empty() or not params.has(argument["key"]): continue
		var value := str(params[argument["key"]])
		match provider:
			"animation":
				if not target is AnimationMixer or not (target as AnimationMixer).has_animation(value): return "missing animation: " + value
			"property":
				if property_info(target, value).is_empty(): return "missing property: " + value
			"signal":
				if not target.has_signal(value): return "missing signal: " + value
	var script_path := str(function.get("script", ""))
	var validator := "_validate_" + str(function["name"])
	if function["scope"] == "static" and not script_path.is_empty() and ResourceLoader.exists(script_path):
		var script := load(script_path) as Script
		if script != null and _has_static(script, validator):
			var problem: Variant = script.call(validator, target, params)
			if problem is String and not (problem as String).is_empty(): return problem
	return ""


static func _has_static(script: Script, name: String) -> bool:
	for info: Dictionary in script.get_script_method_list():
		if str(info["name"]) == name and int(info["flags"]) & METHOD_FLAG_STATIC: return true
	return false
