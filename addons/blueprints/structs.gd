@tool
class_name XREBlueprintStructs
extends RefCounted
## The fields Break takes a value apart into and Make puts one together from
## (D-135). GDScript has no structs: a value's fields are a built-in type's
## members — from this table, the engine being pinned —, a script class's
## variables or an engine class's properties.
##
## A block keeps them copied, as a call keeps its function's signature
## (D-051): [code]struct[/code] is [code]{"type", "class", "fields"}[/code],
## each field [code]{"name", "type", "class_name"}[/code] and the flags
## [code]derived[/code] (computed, not a constructor's), [code]inherited[/code]
## (an engine base class's) and [code]missing[/code] (gone from its class
## since, while a wire still reads it). Its [code]hidden[/code] keeps the names
## not shown, so a field new in the class shows by itself.

## A built-in type's fields, in its constructor's order: [name, Variant type].
const BUILTIN: Dictionary[int, Array] = {
	TYPE_VECTOR2: [["x", TYPE_FLOAT], ["y", TYPE_FLOAT]],
	TYPE_VECTOR3: [["x", TYPE_FLOAT], ["y", TYPE_FLOAT], ["z", TYPE_FLOAT]],
	TYPE_VECTOR4: [["x", TYPE_FLOAT], ["y", TYPE_FLOAT], ["z", TYPE_FLOAT], ["w", TYPE_FLOAT]],
	TYPE_VECTOR2I: [["x", TYPE_INT], ["y", TYPE_INT]],
	TYPE_VECTOR3I: [["x", TYPE_INT], ["y", TYPE_INT], ["z", TYPE_INT]],
	TYPE_COLOR: [["r", TYPE_FLOAT], ["g", TYPE_FLOAT], ["b", TYPE_FLOAT], ["a", TYPE_FLOAT]],
	TYPE_RECT2: [["position", TYPE_VECTOR2], ["size", TYPE_VECTOR2]],
	TYPE_AABB: [["position", TYPE_VECTOR3], ["size", TYPE_VECTOR3]],
	TYPE_QUATERNION: [["x", TYPE_FLOAT], ["y", TYPE_FLOAT], ["z", TYPE_FLOAT], ["w", TYPE_FLOAT]],
	TYPE_BASIS: [["x", TYPE_VECTOR3], ["y", TYPE_VECTOR3], ["z", TYPE_VECTOR3]],
	TYPE_TRANSFORM2D: [["x", TYPE_VECTOR2], ["y", TYPE_VECTOR2], ["origin", TYPE_VECTOR2]],
	TYPE_TRANSFORM3D: [["basis", TYPE_BASIS], ["origin", TYPE_VECTOR3]],
	TYPE_PLANE: [["normal", TYPE_VECTOR3], ["d", TYPE_FLOAT]],
}
## Members computed from the others: Break reads them, hidden at first; Make has none.
const DERIVED: Dictionary[int, Array] = {
	TYPE_COLOR: [["h", TYPE_FLOAT], ["s", TYPE_FLOAT], ["v", TYPE_FLOAT]],
	TYPE_RECT2: [["end", TYPE_VECTOR2]],
	TYPE_AABB: [["end", TYPE_VECTOR3]],
}


## The struct of a value of Variant type [param type] — of class [param cls]
## for an object — as Break ([param make] false) or Make sees it; empty when
## it has no fields: a number, a text, an unknown class.
static func describe(type: int, cls: String = "", make: bool = false) -> Dictionary:
	var fields: Array[Dictionary] = []
	if BUILTIN.has(type):
		for pair: Array in BUILTIN[type]: fields.append({"name": pair[0], "type": pair[1], "class_name": ""})
		if not make:
			for pair: Array in DERIVED.get(type, []): fields.append({"name": pair[0], "type": pair[1], "class_name": "", "derived": true})
		return {"type": type, "class": "", "fields": fields}
	if type != TYPE_OBJECT or cls.is_empty(): return {}
	var script := XREBlueprintFunctions.global_script(cls)
	var engine := cls
	if script != null:
		# A script's variables, its base scripts' too; then its engine class's properties, inherited.
		var seen: Array[String] = []
		for info: Dictionary in script.get_script_property_list():
			var name := str(info["name"])
			if not int(info.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE or seen.has(name): continue
			seen.append(name)
			fields.append({"name": name, "type": int(info["type"]), "class_name": str(info.get("class_name", ""))})
		engine = str(script.get_instance_base_type())
	elif not ClassDB.class_exists(cls): return {}
	if not make or script == null:
		var own: Array[String] = []
		if script == null:
			for info: Dictionary in ClassDB.class_get_property_list(cls, true):
				if not _shown(info): continue
				own.append(str(info["name"]))
				fields.append({"name": str(info["name"]), "type": int(info["type"]), "class_name": str(info.get("class_name", ""))})
		for info: Dictionary in ClassDB.class_get_property_list(engine):
			var name := str(info["name"])
			if not _shown(info) or own.has(name): continue
			fields.append({"name": name, "type": int(info["type"]), "class_name": str(info.get("class_name", "")), "inherited": true})
	return {"type": TYPE_OBJECT, "class": cls, "fields": fields}


## Whether an engine property is a field: shown in the inspector, not the script.
static func _shown(info: Dictionary) -> bool:
	return int(info.get("usage", 0)) & PROPERTY_USAGE_EDITOR != 0 and str(info["name"]) != "script" \
			and not int(info.get("usage", 0)) & (PROPERTY_USAGE_GROUP | PROPERTY_USAGE_SUBGROUP | PROPERTY_USAGE_CATEGORY)


## Whether Make can build a value of type [param type], of class
## [param cls]: a built-in compound value, or a script class that is no node
## and whose [code]_init()[/code] wants no argument.
static func can_make(type: int, cls: String = "") -> bool:
	if BUILTIN.has(type): return true
	if type != TYPE_OBJECT: return false
	var script := XREBlueprintFunctions.global_script(cls)
	if script == null or ClassDB.is_parent_class(script.get_instance_base_type(), "Node"): return false
	for info: Dictionary in script.get_script_method_list():
		if str(info["name"]) == "_init": return (info["args"] as Array).size() <= (info["default_args"] as Array).size()
	return true


## The names hidden at first (D-135): what starts with "_", computed members,
## an engine base class's properties, and fields of types no port carries.
static func default_hidden(struct: Dictionary) -> Array[String]:
	var hidden: Array[String] = []
	for field: Dictionary in struct.get("fields", []):
		var name := str(field["name"])
		if name.begins_with("_") or field.get("derived", false) or field.get("inherited", false) or not int(field["type"]) in XREBlueprintFunctions.PORT_TYPES:
			hidden.append(name)
	return hidden


## The fields [param block] shows, in order: those not hidden.
static func shown(block: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var hidden: Array = block.get("hidden", [])
	for field: Variant in (block.get("struct", {}) as Dictionary).get("fields", []):
		if field is Dictionary and not hidden.has(str((field as Dictionary)["name"])): result.append(field)
	return result


## The name [param struct] goes by: its class, or its type's name.
static func name_of(struct: Dictionary) -> String:
	if struct.is_empty(): return ""
	return str(struct["class"]) if int(struct["type"]) == TYPE_OBJECT else type_string(int(struct["type"]))


## [param block]'s struct as its class has it now (D-135): fields gone from it
## are dropped, or kept [code]missing[/code] while [param wired] names them;
## a type changed is taken; new fields are added at the end. The block's own
## order stays, so its wires keep their fields. Null when its class is gone.
static func reconciled(block: Dictionary, wired: Array[String]) -> Variant:
	var struct: Dictionary = block.get("struct", {})
	if struct.is_empty(): return struct
	var live := describe(int(struct["type"]), str(struct.get("class", "")), block.get("kind") == "make")
	if live.is_empty(): return null
	var now: Dictionary = {}
	for field: Dictionary in live["fields"]: now[field["name"]] = field
	var fields: Array[Dictionary] = []
	for field: Dictionary in struct["fields"]:
		var name := str(field["name"])
		if now.has(name):
			fields.append((now[name] as Dictionary).duplicate())
			now.erase(name)
		elif wired.has(name):
			var kept := field.duplicate()
			kept["missing"] = true
			fields.append(kept)
	for field: Dictionary in live["fields"]:
		if now.has(field["name"]): fields.append((field as Dictionary).duplicate())
	var result := struct.duplicate()
	result["fields"] = fields
	return result
