@tool
class_name XREBlueprintFunctions
extends RefCounted
## Signatures of the functions a Call block runs (D-051): a method of a scene
## node (engine or script), a static function of a script with a
## [code]class_name[/code] (the Blueprint library among them,
## [XREBlueprintLibrary]) or a utility function of @GlobalScope
## ([XREBlueprintGlobals]). A signature is copied into its block, as signal
## arguments are: the compiler and the views read it from the graph, never
## from live reflection.
##
## A signature is a Dictionary:
## [code]scope[/code] ("method", "static" or "global"), [code]class[/code],
## [code]name[/code], [code]title[/code], [code]category[/code],
## [code]description[/code], [code]keywords[/code], [code]args[/code],
## [code]return[/code] (a Variant type, TYPE_NIL for none or Variant) and
## [code]returns[/code] (whether there is a result), [code]return_class[/code],
## [code]pure[/code] (no execution ports), [code]break[/code] (labels of
## the outputs a pure result is split into, D-084), [code]awaits[/code] (a script
## function, possibly a coroutine), [code]vararg[/code] with [code]extra[/code]
## arguments, [code]then[/code] (the execution output's label),
## [code]targets[/code] (classes the Target may be), [code]script[/code] and
## [code]advanced_shown[/code].
##
## An argument is a Dictionary: [code]name[/code], [code]label[/code],
## [code]type[/code], [code]class_name[/code], [code]key[/code] (the block
## parameter with its value, empty for none), [code]default[/code] if it has
## one, and flags: [code]target[/code] (the block's Target), [code]self[/code]
## (the object a method is called on), [code]run[/code] (the event's run),
## [code]literal[/code] (set on the block, no port), [code]advanced[/code],
## [code]fixed[/code] (an unsupported type with a default: always the default),
## [code]positive[/code], [code]non_negative[/code], [code]provider[/code] ("animation", "property" or
## "signal") and [code]type_of[/code] (the key of the property argument whose
## type the port takes). Enumerations name their class in [code]enum[/code].

## Class of the event's run, a library function's optional last argument.
const RUN_CLASS := &"XREBlueprintRun"
## Argument types a port or a value can carry; TYPE_NIL is Variant.
const PORT_TYPES: Array[int] = [TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_STRING_NAME, TYPE_NODE_PATH, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR, TYPE_OBJECT]
## Parameters of a block that no argument may use as its key.
const RESERVED_KEYS: Array[String] = ["target", "policy", "signal", "function"]
## Labels of a vararg function's extra arguments' keys: value, value_2…
const EXTRA_KEY := "value"
## How many extra arguments a vararg function may take.
const MAX_EXTRA := 8

## Engine methods described more closely than reflection does, by "Class.method":
## [code]title[/code], [code]advanced[/code] arguments, value [code]providers[/code]
## by argument, [code]hidden[/code] from the menu.
const OVERRIDES: Dictionary[String, Dictionary] = {
	"AnimationPlayer.play": {"providers": {"name": "animation"}, "advanced": ["custom_blend", "custom_speed", "from_end"], "keywords": "anim clip"},
	"AnimationPlayer.play_backwards": {"providers": {"name": "animation"}, "advanced": ["custom_blend"], "keywords": "anim reverse"},
	"AnimationPlayer.play_with_capture": {"providers": {"name": "animation"}, "advanced": ["duration", "custom_blend", "custom_speed", "from_end", "trans_type", "ease_type"]},
	"AnimationPlayer.queue": {"providers": {"name": "animation"}},
	"AnimationMixer.has_animation": {"providers": {"name": "animation"}},
	"AudioStreamPlayer.play": {"advanced": ["from_position"], "keywords": "sound sfx"},
	"AudioStreamPlayer2D.play": {"advanced": ["from_position"], "keywords": "sound sfx"},
	"AudioStreamPlayer3D.play": {"advanced": ["from_position"], "keywords": "sound sfx"},
	"Node.add_child": {"advanced": ["force_readable_name", "internal"], "keywords": "spawn attach"},
	"Node.queue_free": {"keywords": "destroy delete remove"},
	"Node.is_in_group": {"keywords": "tag"},
	"Node3D.look_at": {"advanced": ["up", "use_model_front"], "keywords": "face turn aim"},
	"Node3D.look_at_from_position": {"advanced": ["up", "use_model_front"]},
	"Node3D.rotate_y": {"keywords": "turn spin"},
	"Node3D.translate": {"keywords": "move"},
	"Object.emit_signal": {"providers": {"signal": "signal"}, "keywords": "send fire"},
	"Object.call": {"hidden": true}, "Object.callv": {"hidden": true}, "Object.call_deferred": {"hidden": true},
	"Object.connect": {"hidden": true}, "Object.disconnect": {"hidden": true}, "Object.free": {"hidden": true},
	"Object.set": {"hidden": true}, "Object.get": {"hidden": true}, "Object.set_script": {"hidden": true},
}

static var _tag_cache: Dictionary[String, Dictionary] = {}


## The signature of function [param name] in [param scope] ("method",
## "static" or "global") of class [param cls]; empty if there is none.
static func find(scope: String, cls: String, name: String) -> Dictionary:
	match scope:
		"method": return method(cls, name)
		"static": return static_function(cls, name)
		"global": return global(name)
	return {}


## [param name] from snake_case to a title: "play_backwards" is "Play Backwards".
static func title_of(name: String) -> String:
	var words := PackedStringArray()
	for word: String in name.trim_prefix("_").split("_", false):
		words.append(word.left(1).to_upper() + word.substr(1))
	return " ".join(words)


## Engine method [param name] of class [param cls] or of its bases; empty if there is none.
static func method(cls: String, name: String) -> Dictionary:
	if not ClassDB.class_exists(cls):
		return {}
	var owner := _declaring_class(cls, name)
	for info: Dictionary in ClassDB.class_get_method_list(owner, true):
		if str(info["name"]) == name:
			return method_of(cls, owner, info)
	return {}


## The signature of engine method [param info], declared in [param owner] and
## called on a [param cls].
static func method_of(cls: String, owner: String, info: Dictionary) -> Dictionary:
	var name := str(info["name"])
	var override: Dictionary = OVERRIDES.get(owner + "." + name, OVERRIDES.get(cls + "." + name, {}))
	var signature := {"scope": "method", "class": cls, "name": name, "title": override.get("title", title_of(name)),
			"category": owner, "description": "", "keywords": override.get("keywords", ""), "targets": [cls], "script": "", "awaits": false}
	var tags := {"advanced": override.get("advanced", []), "providers": override.get("providers", {})}
	signature["pure"] = int(info["flags"]) & METHOD_FLAG_CONST != 0 and int(info["return"]["type"]) != TYPE_NIL
	return _complete(signature, info, tags)


## Method [param name] of [param script], called on a node of class [param cls]
## that has the script; empty if the script has none.
static func script_method(script: Script, cls: String, name: String) -> Dictionary:
	if script == null:
		return {}
	for info: Dictionary in script.get_script_method_list():
		if str(info["name"]) != name or int(info["flags"]) & METHOD_FLAG_STATIC:
			continue
		var tags := script_tags(script, name)
		var global := str(script.get_global_name())
		var signature := {"scope": "method", "class": global if not global.is_empty() else cls, "name": name,
				"title": tags.get("name", title_of(name)), "category": tags.get("category", global if not global.is_empty() else script.resource_path.get_file()),
				"description": tags.get("description", ""), "keywords": tags.get("keywords", ""), "targets": [global if not global.is_empty() else cls],
				"script": script.resource_path, "awaits": tags.has("coroutine"), "pure": tags.has("pure")}
		return _complete(signature, info, tags)
	return {}


## Static function [param name] of the script with class name [param global_name]; empty if there is none.
static func static_function(global_name: String, name: String) -> Dictionary:
	return static_of(global_script(global_name), global_name, name)


## Static function [param name] of [param script], whose class name is [param global_name].
static func static_of(script: Script, global_name: String, name: String) -> Dictionary:
	if script == null:
		return {}
	for info: Dictionary in script.get_script_method_list():
		if str(info["name"]) != name or not int(info["flags"]) & METHOD_FLAG_STATIC:
			continue
		var tags := script_tags(script, name)
		var signature := {"scope": "static", "class": global_name, "name": name, "title": tags.get("name", title_of(name)),
				"category": tags.get("category", global_name), "description": tags.get("description", ""), "keywords": tags.get("keywords", ""),
				"targets": tags.get("target_types", []), "script": script.resource_path, "awaits": tags.has("coroutine"), "pure": tags.has("pure")}
		return _complete(signature, info, tags)
	return {}


## Utility function [param name] of @GlobalScope; empty if there is none.
static func global(name: String) -> Dictionary:
	if not XREBlueprintGlobals.FUNCTIONS.has(name):
		return {}
	var entry: Dictionary = XREBlueprintGlobals.FUNCTIONS[name]
	var arguments: Array[Dictionary] = []
	for pair: Array in entry["args"]:
		arguments.append({"name": pair[0], "type": pair[1], "class_name": "", "usage": PROPERTY_USAGE_NIL_IS_VARIANT if int(pair[1]) == TYPE_NIL else 0})
	var info := {"name": name, "args": arguments, "default_args": [], "flags": METHOD_FLAG_VARARG if entry["vararg"] else METHOD_FLAG_NORMAL,
			"return": {"type": entry["return"], "class_name": "", "usage": PROPERTY_USAGE_NIL_IS_VARIANT if entry["returns"] else 0}}
	var signature := {"scope": "global", "class": "", "name": name, "title": title_of(name), "category": "@GlobalScope · " + str(entry["category"]),
			"description": "", "keywords": str(entry["category"]), "targets": [], "script": "", "awaits": false, "pure": bool(entry["returns"])}
	return _complete(signature, info, {})


## The script that declares global class [param global_name], or null.
static func global_script(global_name: String) -> Script:
	for entry: Dictionary in ProjectSettings.get_global_class_list():
		if str(entry["class"]) == global_name:
			return load(str(entry["path"])) as Script
	return null


## Tags in the [code]##[/code] comment above function [param name] of
## [param script] ([XREBlueprintLibrary]): [code]name[/code],
## [code]category[/code], [code]keywords[/code], [code]description[/code],
## [code]target[/code], [code]target_types[/code], [code]literal[/code],
## [code]advanced[/code], [code]positive[/code], [code]non_negative[/code], [code]providers[/code],
## [code]type_of[/code], [code]then[/code], [code]pure[/code], [code]hide[/code],
## [code]break[/code], and [code]coroutine[/code] if its body awaits.
static func script_tags(script: Script, name: String) -> Dictionary:
	var key := script.resource_path + ":" + name
	var source := script.source_code
	if _tag_cache.has(key) and _tag_cache[key].get("_source_size", -1) == source.length():
		return _tag_cache[key]
	var tags := {"_source_size": source.length(), "literal": [], "advanced": [], "positive": [], "non_negative": [], "target_types": [], "break": [], "providers": {}, "type_of": {}}
	var lines := source.split("\n")
	for index: int in lines.size():
		var line := lines[index].strip_edges()
		var header := line.trim_prefix("static ").strip_edges()
		if not header.begins_with("func " + name + "(") and not header.begins_with("func " + name + " ("):
			continue
		var comment := PackedStringArray()
		var above := index - 1
		while above >= 0 and lines[above].strip_edges().begins_with("##"):
			comment.insert(0, lines[above].strip_edges().trim_prefix("##").strip_edges())
			above -= 1
		var description := PackedStringArray()
		for text: String in comment:
			if not text.begins_with("@bp_"):
				description.append(text)
				continue
			var words := text.split(" ", false)
			var tag := words[0].trim_prefix("@bp_")
			var rest := words.slice(1)
			match tag:
				"name", "category", "then", "keywords":
					tags[tag] = " ".join(rest)
				"target":
					if not rest.is_empty():
						tags["target"] = rest[0]
				"literal", "advanced", "positive", "non_negative", "target_types", "break":
					(tags[tag] as Array).append_array(Array(rest))
				"provider":
					if rest.size() >= 2:
						(tags["providers"] as Dictionary)[rest[0]] = rest[1]
				"type_of":
					if rest.size() >= 2:
						(tags["type_of"] as Dictionary)[rest[0]] = rest[1]
				"pure", "hide":
					tags[tag] = true
		tags["description"] = " ".join(description).strip_edges()
		# A coroutine is awaited by its block; awaiting another function would be redundant.
		var body := index + 1
		while body < lines.size() and (lines[body].strip_edges().is_empty() or lines[body].begins_with("	") or lines[body].begins_with(" ")):
			if lines[body].split("#")[0].contains("await "): tags["coroutine"] = true
			body += 1
		break
	_tag_cache[key] = tags
	return tags


## Completes [param signature] with arguments, result and ports from method info [param info] and [param tags].
static func _complete(signature: Dictionary, info: Dictionary, tags: Dictionary) -> Dictionary:
	var arguments: Array[Dictionary] = []
	if signature["scope"] == "method":
		arguments.append({"name": "target", "label": "Target", "type": TYPE_OBJECT, "class_name": signature["class"], "key": "target", "target": true, "self": true})
	var listed: Array = info["args"]
	var defaults: Array = info["default_args"]
	var extra := 0
	if int(info["flags"]) & METHOD_FLAG_VARARG:
		# print(arg1, ...) and max(arg1, arg2, ...) declare their first values: they are all extra values.
		var untyped := listed.all(func(source: Dictionary) -> bool: return int(source["type"]) == TYPE_NIL)
		if untyped and not listed.is_empty():
			extra = listed.size()
			listed = []
			defaults = []
	var first_default := listed.size() - defaults.size()
	var used: Array[String] = []
	for index: int in listed.size():
		var source: Dictionary = listed[index]
		var name := str(source["name"])
		var type := int(source["type"])
		var argument := {"name": name, "label": title_of(name), "type": type, "class_name": str(source.get("class_name", "")), "key": ""}
		if int(source.get("usage", 0)) & PROPERTY_USAGE_CLASS_IS_ENUM and type == TYPE_INT:
			argument["enum"] = argument["class_name"]
			argument["class_name"] = ""
		if index >= first_default:
			argument["default"] = defaults[index - first_default]
		if type == TYPE_OBJECT and argument["class_name"] == RUN_CLASS:
			argument["run"] = true
			arguments.append(argument)
			continue
		if name == tags.get("target", ""):
			argument["target"] = true
			argument["label"] = "Target"
			argument["key"] = "target"
			if (signature["targets"] as Array).is_empty() and not str(argument["class_name"]).is_empty():
				signature["targets"] = [argument["class_name"]]
		elif not type in PORT_TYPES:
			if not argument.has("default"):
				signature["unsupported"] = "argument %s: %s is not supported" % [name, type_string(type)]
			argument["fixed"] = true
			arguments.append(argument)
			continue
		else:
			var key := name if not name in RESERVED_KEYS and not used.has(name) else "arg_" + name
			argument["key"] = key
		used.append(str(argument["key"]))
		if name in tags.get("literal", []) or (tags.get("providers", {}) as Dictionary).has(name):
			argument["literal"] = true
		if name in tags.get("advanced", []): argument["advanced"] = true
		if name in tags.get("positive", []): argument["positive"] = true
		if name in tags.get("non_negative", []): argument["non_negative"] = true
		var providers: Dictionary = tags.get("providers", {})
		if providers.has(name): argument["provider"] = providers[name]
		var type_of: Dictionary = tags.get("type_of", {})
		if type_of.has(name): argument["type_of"] = type_of[name]
		arguments.append(argument)
	signature["args"] = arguments
	var result: Dictionary = info["return"]
	signature["return"] = int(result["type"])
	signature["returns"] = int(result["type"]) != TYPE_NIL or int(result.get("usage", 0)) & PROPERTY_USAGE_NIL_IS_VARIANT != 0
	signature["return_class"] = str(result.get("class_name", ""))
	signature["vararg"] = int(info["flags"]) & METHOD_FLAG_VARARG != 0
	signature["extra"] = extra
	signature["then"] = tags.get("then", "Then")
	signature["advanced_shown"] = false
	# A broken result is read component by component: the function is pure.
	var broken: Array = tags.get("break", [])
	if not broken.is_empty() and signature["returns"]:
		signature["break"] = broken.duplicate()
		signature["pure"] = true
	if not signature["returns"]: signature["pure"] = false
	if tags.get("hide", false): signature["hidden"] = true
	return signature


## The class among [param cls] and its bases that declares method [param name].
static func _declaring_class(cls: String, name: String) -> String:
	var current := cls
	while not current.is_empty():
		var parent := str(ClassDB.get_parent_class(current))
		if parent.is_empty() or not ClassDB.class_has_method(parent, name):
			return current
		current = parent
	return cls


## Keys and labels of the extra arguments of a vararg function: value, value_2…
static func extra_key(index: int) -> String:
	return EXTRA_KEY if index == 0 else "%s_%d" % [EXTRA_KEY, index + 1]


## The literal an argument starts with: its default, or a value of its type.
static func initial_value(argument: Dictionary) -> Variant:
	if argument.has("default") and XREBlueprintGraph.is_literal(_as_literal(argument["default"])):
		return _as_literal(argument["default"])
	match int(argument["type"]):
		TYPE_NIL: return 0.0
		TYPE_STRING_NAME, TYPE_NODE_PATH: return ""
	return XREBlueprintSchema.default_value(int(argument["type"]))


## A StringName or NodePath default as the text a block keeps.
static func _as_literal(value: Variant) -> Variant:
	if value is StringName or value is NodePath:
		return str(value)
	return value


## Whether [param argument] keeps a literal on its block: a value a port
## falls back to, or a setting without a port.
static func has_literal(argument: Dictionary) -> bool:
	if argument.get("run", false) or argument.get("fixed", false) or argument.get("target", false):
		return false
	return int(argument["type"]) != TYPE_OBJECT and not str(argument.get("key", "")).is_empty()


## Parameters a new block of [param signature] starts with.
static func default_params(signature: Dictionary) -> Dictionary:
	var params := {}
	for argument: Dictionary in signature["args"]:
		if argument.get("target", false):
			params["target"] = "."
		elif has_literal(argument):
			params[argument["key"]] = initial_value(argument)
	for index: int in int(signature.get("extra", 0)):
		params[extra_key(index)] = ""
	return params


## Why [param signature] can't be a block, or empty if it can.
static func problem(signature: Dictionary) -> String:
	return str(signature.get("unsupported", ""))


## The input and output ports of a call block with [param signature], as
## [code][[label, type, key]...][/code]: the property argument a type follows
## has [param property_type]. Advanced arguments come last, so that showing
## them adds ports at the end without moving wires.
static func ports(signature: Dictionary, property_type: int) -> Array:
	var inputs: Array = []
	var outputs: Array = []
	if not signature.get("pure", false):
		inputs.append(["In", XREBlueprintGraph.EXEC, ""])
		outputs.append([str(signature.get("then", "Then")), XREBlueprintGraph.EXEC, ""])
	var advanced: Array = []
	for argument: Dictionary in signature["args"]:
		if argument.get("run", false) or argument.get("fixed", false) or argument.get("literal", false):
			continue
		var type := int(argument["type"])
		if not str(argument.get("type_of", "")).is_empty() and property_type != TYPE_NIL:
			type = property_type
		var port := [str(argument["label"]), XREBlueprintGraph.port_type(TYPE_STRING if type in [TYPE_STRING_NAME, TYPE_NODE_PATH] else type),
				str(argument["key"]) if has_literal(argument) or argument.get("target", false) else ""]
		if argument.get("advanced", false):
			if signature.get("advanced_shown", false): advanced.append(port)
		else:
			inputs.append(port)
	for index: int in int(signature.get("extra", 0)):
		inputs.append([title_of(extra_key(index)), XREBlueprintGraph.VALUE, extra_key(index)])
	inputs.append_array(advanced)
	var broken: Array = signature.get("break", [])
	for label: Variant in broken:
		outputs.append([str(label), XREBlueprintGraph.NUMBER])
	if signature.get("returns", false) and broken.is_empty():
		outputs.append(["Result", XREBlueprintGraph.port_type(int(signature["return"]))])
	return [inputs, outputs]
