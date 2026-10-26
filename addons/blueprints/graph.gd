@tool
class_name XREBlueprintGraph
extends Resource
## Serializable visual program. The UI and compiler share this format, not UI nodes.
##
## Format 3 (D-051) keeps only the blocks a function call can't express:
## events ([code]signal[/code]), [code]call[/code], [code]branch[/code],
## [code]value[/code], variables, properties, [code]equals[/code] and
## [code]operator[/code] (D-065: arithmetic, comparison and logic,
## [XREBlueprintOperators]). On Ready, Boolean, Print, Delay, Tween, Play
## Sound and Play Animation are presets ([constant PRESETS]): an event, a
## value or a call of a function of the Blueprint library
## ([XREBlueprintLibrary]) or of @GlobalScope. Version 2 graphs migrate in
## memory ([method upgrade]).
##
## A connection may keep the bends the VR editor drew it with (D-081):
## [code]vr_bends[/code], a [PackedVector3Array] from its output to its input,
## each X and Y in graph coordinates as a block's [code]position[/code] and Z
## its VR depth in meters as [code]vr_depth[/code]. A block keeps those of its
## own wires so: [constant SCENE_BENDS], [constant VARIABLE_BENDS]. The
## compiler and GraphEdit ignore them.
##
## A block's [code]vr_heading[/code], "operation" or "member", says what its
## card's header shows in the VR editor's archetypes (D-101), over the
## editor's setting; a variable's [code]vr_collapsed[/code] false opens its box's
## drawer of components there, shut without it (D-108, D-114). The compiler and GraphEdit ignore them too.

const FORMAT_VERSION := 3
const MAX_NODES := 256
## Most bends one wire keeps (D-081).
const MAX_BENDS := 16
## Bends of a block's wire to its object in the scene, from its Target port,
## adapter or Source, and of its Variable socket's wire to the variable's box (D-081).
const SCENE_BENDS := "vr_scene_bends"
const VARIABLE_BENDS := "vr_variable_bends"
const EXEC := 0
const VALUE := 1
const BOOLEAN := 2
const INTEGER := 3
const NUMBER := 4
const TEXT := 5
const VECTOR2 := 6
const VECTOR3 := 7
const OBJECT := 8
const COLOR := 9
## Port entries are [label, type, key]: the key names the parameter an
## unconnected input takes its value from, empty for none. Execution flows and
## values cannot be mixed. A call block's ports come from its function ([XREBlueprintFunctions]).
const BLOCKS := {
	"signal": {"title": "On Signal", "in": [], "out": [["Then", EXEC, ""]], "params": {"target": ".", "signal": "pressed", "policy": "parallel"}},
	"call": {"title": "Call", "in": [], "out": [], "params": {}},
	"branch": {"title": "Branch", "in": [["In", EXEC, ""], ["Condition", BOOLEAN, "condition"]], "out": [["True", EXEC, ""], ["False", EXEC, ""]], "params": {"condition": true}},
	"value": {"title": "Value", "in": [], "out": [["Value", VALUE, ""]], "params": {"value": 1.0}},
	"get_property": {"title": "Get Property", "in": [["Target", OBJECT, "target"]], "out": [["Value", VALUE, ""]], "params": {"target": ".", "property": "visible"}},
	"set_property": {"title": "Set Property", "in": [["In", EXEC, ""], ["Value", VALUE, "value"], ["Target", OBJECT, "target"]], "out": [["Then", EXEC, ""]], "params": {"target": ".", "property": "visible", "value": true}},
	"equals": {"title": "Equal", "in": [["A", VALUE, "a"], ["B", VALUE, "b"]], "out": [["Result", BOOLEAN, ""]], "params": {"a": 1.0, "b": 1.0}},
	# Its ports follow its operator ([method ports]); a unary one has no B.
	"operator": {"title": "Operator", "in": [["A", VALUE, "a"], ["B", VALUE, "b"]], "out": [["Result", VALUE, ""]], "params": {"op": "add", "a": 0.0, "b": 0.0}},
	"get_variable": {"title": "Get Variable", "in": [], "out": [["Value", VALUE, ""]], "params": {"variable": ""}},
	"set_variable": {"title": "Set Variable", "in": [["In", EXEC, ""], ["Value", VALUE, "value"]], "out": [["Then", EXEC, ""]], "params": {"variable": "", "value": false}},
}
## Shortcuts that are a configured block of another kind (D-051): On Ready is
## On Signal of the host's ready, Boolean a Value, the rest call a function
## of the library or of @GlobalScope. They are also the block kinds of format 2.
const PRESETS := {
	"ready": {"title": "On Ready", "kind": "signal", "params": {"target": ".", "signal": "ready", "policy": "parallel"}},
	"boolean": {"title": "Boolean", "kind": "value", "params": {"value": true}},
	"print": {"title": "Print", "kind": "call", "scope": "global", "class": "", "name": "print", "params": {"value": "Hello from Blueprints"}},
	"delay": {"title": "Delay", "kind": "call", "scope": "static", "class": "XREBlueprintLibrary", "name": "delay", "params": {}},
	"tween": {"title": "Tween Property", "kind": "call", "scope": "static", "class": "XREBlueprintLibrary", "name": "tween_property", "params": {}},
	"play_sound": {"title": "Play Sound", "kind": "call", "scope": "static", "class": "XREBlueprintLibrary", "name": "play_sound", "params": {"target": "AudioStreamPlayer"}},
	"play_animation": {"title": "Play Animation", "kind": "call", "scope": "static", "class": "XREBlueprintLibrary", "name": "play_animation", "params": {"target": "AnimationPlayer"}},
}
## Parameter keys of the inputs of format 2 blocks that became calls, by
## port: migration finds the same parameter's port on the call.
const _V2_INPUTS := {"print": ["", "value"], "tween": ["", "value", "target"], "delay": [""], "play_sound": ["", "target"], "play_animation": ["", "target"]}

@export var format_version: int = FORMAT_VERSION
@export var nodes: Array[Dictionary] = []
@export var edges: Array[Dictionary] = []
@export var variables: Array[Dictionary] = []
## Script host relative to the edited scene root; editor context, not a runtime target.
@export var host_path: NodePath = NodePath(".")
## Owning scene for editor reflection. Generated runtime targets remain relative.
@export var scene_path: String = ""
## Editor-only fixed workspace pose and XY origin, retained across VR reopenings.
@export var vr_placed := false
@export var vr_workspace := Transform3D.IDENTITY
@export var vr_center := Vector2.ZERO
## How deep [method operand_type] follows wires back through operators, against a cycle that validation reports.
var _resolving := 0


## Independent snapshot for undo and dirty-state comparison.
func snapshot() -> Dictionary:
	return {"nodes": nodes.duplicate(true), "edges": edges.duplicate(true), "variables": variables.duplicate(true), "host_path": host_path, "scene_path": scene_path, "format_version": format_version, "vr_placed": vr_placed, "vr_workspace": vr_workspace, "vr_center": vr_center}


## Everything a view draws except placement — of blocks, of variables' boxes
## (D-078) and of wires' bends (D-081): equal keys mean an edit only moved
## blocks or boxes or bent wires.
func structure_key() -> Array:
	var blocks: Array = []
	for block: Dictionary in nodes:
		var shape := block.duplicate(true)
		shape.erase("position")
		shape.erase("vr_depth")
		shape.erase("vr_rotation")
		shape.erase("vr_anchor")
		shape.erase(SCENE_BENDS)
		shape.erase(VARIABLE_BENDS)
		blocks.append(shape)
	var wires: Array = []
	for edge: Dictionary in edges:
		var shape := edge.duplicate()
		shape.erase("vr_bends")
		wires.append(shape)
	# A variable's box placed in the headset's graph (D-078) is placement too.
	var kept: Array = []
	for variable: Dictionary in variables:
		var shape := variable.duplicate(true)
		shape.erase("vr_position")
		shape.erase("vr_depth")
		kept.append(shape)
	return [blocks, wires, kept, host_path, scene_path, vr_placed, vr_workspace, vr_center]


## Applies one complete edit and notifies every view of this resource.
func restore(state: Dictionary) -> void:
	nodes.assign((state["nodes"] as Array).duplicate(true))
	edges.assign((state["edges"] as Array).duplicate(true))
	variables.assign((state.get("variables", []) as Array).duplicate(true))
	host_path = state.get("host_path", NodePath("."))
	scene_path = state.get("scene_path", "")
	format_version = state.get("format_version", FORMAT_VERSION)
	vr_placed = state.get("vr_placed", false)
	vr_workspace = state.get("vr_workspace", Transform3D.IDENTITY)
	vr_center = state.get("vr_center", Vector2.ZERO)
	emit_changed()


## Finds a block by its stable integer ID, independent of its screen position.
func find_node(id: int) -> Dictionary:
	for block: Dictionary in nodes:
		if block.get("id", -1) == id:
			return block
	return {}


## The fixed type of a graph variable: its start value's, or, with that taken
## out (D-054), the type it keeps in "type".
static func variable_type(variable: Dictionary) -> int:
	if variable.has("value"): return typeof(variable["value"])
	return int(variable.get("type", TYPE_NIL))


## Keys of the inputs of [param block] whose literal may be taken out, leaving
## an empty socket that the build reports (D-054): the values of its ports.
func socket_keys(block: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for spec: Array in ports(block, true):
		var key: String = spec[2] if spec.size() > 2 else ""
		if not key.is_empty() and key != "target": keys.append(key)
	return keys


## Finds a graph variable. Its default determines its fixed type.
func find_variable(name: String) -> Dictionary:
	for variable: Dictionary in variables:
		if variable.get("name", "") == name:
			return variable
	return {}


## The title a block shows: its function's for a call, On Ready for the
## host's ready, Boolean for a boolean value.
static func title(block: Dictionary) -> String:
	var kind: String = str(block.get("kind", ""))
	var params: Dictionary = block.get("params", {})
	match kind:
		"call":
			var function: Variant = block.get("function")
			return str((function as Dictionary).get("title", "Call")) if function is Dictionary else "Call"
		"signal":
			return "On Ready" if params.get("signal") == "ready" and params.get("target") == "." else "On Signal"
		"value":
			return "Boolean" if params.get("value") is bool else "Value"
		"operator":
			var op := str(params.get("op", ""))
			return str((XREBlueprintOperators.OPERATORS[op] as Dictionary)["title"]) if XREBlueprintOperators.OPERATORS.has(op) else "Operator"
	return str(BLOCKS[kind]["title"]) if BLOCKS.has(kind) else kind


## Migrates older files in memory. Saving is explicit and preserves old wires:
## format 2 blocks that are presets now become their event, value or call, and
## wires keep their ports by parameter.
func upgrade() -> void:
	if format_version > FORMAT_VERSION:
		return
	for block: Dictionary in nodes:
		if BLOCKS.has(block.get("kind")) and block.get("params") is Dictionary and block["kind"] != "call":
			# Settings missing from older files get their defaults; an empty socket stays empty (D-054).
			var sockets := socket_keys(block)
			for key: String in BLOCKS[block["kind"]]["params"]:
				if not (block["params"] as Dictionary).has(key) and not key in sockets and not is_unused(block, key): block["params"][key] = BLOCKS[block["kind"]]["params"][key]
		elif PRESETS.has(block.get("kind")) and block.get("params") is Dictionary:
			(block["params"] as Dictionary).merge(_legacy_params(str(block["kind"])), false)
	# Calls made before property and variable were free argument keys kept them as arg_property and arg_variable.
	for block: Dictionary in nodes:
		var function: Variant = block.get("function")
		if block.get("kind") != "call" or not function is Dictionary or not block.get("params") is Dictionary: continue
		var bounds := _library_bounds(function as Dictionary)
		for argument: Variant in (function as Dictionary).get("args", []):
			if not argument is Dictionary: continue
			var entry := argument as Dictionary
			var name := str(entry.get("name", ""))
			# A library function's bounds as its source has them now: a Delay saved
			# when its seconds had to be positive may be 0 now (D-063).
			if bounds.has(name):
				for flag: String in ["positive", "non_negative"]:
					if name in (bounds[name] as Dictionary)[flag]: entry[flag] = true
					else: entry.erase(flag)
			if name in ["property", "variable"] and entry.get("key") == "arg_" + name:
				entry["key"] = name
				var params: Dictionary = block["params"]
				if params.has("arg_" + name):
					params[name] = params["arg_" + name]
					params.erase("arg_" + name)
	# By content, not by version: format 2 files saved its version as the default,
	# so they don't store it and load as the current format.
	var legacy := nodes.any(func(block: Dictionary) -> bool: return PRESETS.has(block.get("kind")))
	if format_version < 3 or legacy:
		var remaps: Dictionary[int, Array] = {}
		for index: int in nodes.size():
			var old: Dictionary = nodes[index]
			var kind := str(old.get("kind", ""))
			if not PRESETS.has(kind) or not old.get("id") is int or not old.get("params") is Dictionary:
				continue
			var block := make_node(old["id"], kind, old.get("position", Vector2.ZERO))
			if block.is_empty():
				continue
			for key: String in block["params"]:
				if (old["params"] as Dictionary).has(key): block["params"][key] = old["params"][key]
			for key: String in ["vr_depth", "vr_rotation", "property_type", "arguments"]:
				if old.has(key): block[key] = old[key]
			nodes[index] = block
			if _V2_INPUTS.has(kind): remaps[int(old["id"])] = _V2_INPUTS[kind]
		for edge: Dictionary in edges:
			if not edge.get("to") is int or not remaps.has(edge["to"]) or not edge.get("to_port") is int: continue
			var keys: Array = remaps[edge["to"]]
			if edge["to_port"] < 0 or edge["to_port"] >= keys.size(): continue
			edge["to_port"] = input_port(find_node(edge["to"]), keys[edge["to_port"]])
	format_version = FORMAT_VERSION


## The bounds of the numbers of library function [param function] as its
## source tags them now: [code]{argument: {"positive": [...], "non_negative": [...]}}[/code]
## for each argument, empty for a function of no script class.
static func _library_bounds(function: Dictionary) -> Dictionary:
	if function.get("scope") != "static": return {}
	var script := XREBlueprintFunctions.global_script(str(function.get("class", "")))
	if script == null: return {}
	var tags := XREBlueprintFunctions.script_tags(script, str(function.get("name", "")))
	var bounds := {}
	for argument: Variant in function.get("args", []):
		if not argument is Dictionary: continue
		var name := str((argument as Dictionary).get("name", ""))
		bounds[name] = {"positive": tags.get("positive", []), "non_negative": tags.get("non_negative", [])}
	return bounds


## Parameters a format 2 block of preset [param kind] had, for files saved before they existed.
static func _legacy_params(kind: String) -> Dictionary:
	match kind:
		"ready": return {"policy": "parallel"}
		"print": return {"value": "Hello from Blueprints"}
		"tween": return {"target": ".", "property": "position", "value": Vector2(400, 240), "seconds": 1.0}
		"delay": return {"seconds": 1.0}
		"play_sound": return {"target": "AudioStreamPlayer"}
		"play_animation": return {"target": "AnimationPlayer", "animation": "open", "wait": false, "timeout": 30.0}
		"boolean": return {"value": true}
	return {}


## Port arrays include reflected properties, variables and signal arguments.
func ports(block: Dictionary, input: bool) -> Array:
	var kind: String = block["kind"]
	if kind == "call":
		var function: Variant = block.get("function")
		if not function is Dictionary or not (function as Dictionary).get("args") is Array: return []
		return (XREBlueprintFunctions.ports(function, int(block.get("property_type", TYPE_NIL)))[0 if input else 1] as Array).duplicate(true)
	if kind == "operator": return _operator_ports(block, input)
	var result: Array = (BLOCKS[kind]["in" if input else "out"] as Array).duplicate(true)
	var params: Dictionary = block["params"]
	if not input and kind == "signal":
		for argument: Dictionary in block.get("arguments", []):
			result.append([argument["name"], port_type(argument["type"]), ""])
	if not input and kind == "value":
		result[0][1] = port_type(typeof(params["value"]))
	if kind in ["get_property", "set_property"]:
		if (input and kind == "set_property") or (not input and kind == "get_property"):
			result[1 if input else 0][1] = port_type(block.get("property_type", TYPE_NIL))
	if kind in ["get_variable", "set_variable"]:
		var variable := find_variable(params["variable"])
		if not variable.is_empty() and ((input and kind == "set_variable") or (not input and kind == "get_variable")):
			result[1 if input else 0][1] = port_type(variable_type(variable))
	return result


## An operator's ports (D-065): A and B, or A alone, of the type its group
## takes — booleans for logic, numbers to order, any value else — and its
## Result, of the type its operands give ([method operand_type]).
func _operator_ports(block: Dictionary, input: bool) -> Array:
	var op := str((block["params"] as Dictionary).get("op", ""))
	var group := XREBlueprintOperators.group_of(op)
	if input:
		var operand := BOOLEAN if group == XREBlueprintOperators.LOGIC else NUMBER if group == XREBlueprintOperators.ORDER else VALUE
		var inputs: Array = [["A", operand, "a"]]
		if not XREBlueprintOperators.is_unary(op): inputs.append(["B", operand, "b"])
		return inputs
	return [["Result", port_type(XREBlueprintOperators.result_type(op, operand_type(block, "a"), operand_type(block, "b"))), ""]]


## The Variant type of operand [param key] (A or B) of an operator or Equal
## block: of the output its wire comes from, else of its literal; TYPE_NIL
## when it can't be known before the game runs.
func operand_type(block: Dictionary, key: String) -> int:
	var port := 0 if key == "a" else 1
	for edge: Dictionary in edges:
		if edge.get("to") != block.get("id") or edge.get("to_port") != port or not edge.get("from_port") is int: continue
		var source := find_node(int(edge.get("from", -1)))
		if source.is_empty() or _resolving > 64: return TYPE_NIL
		_resolving += 1
		var outputs := ports(source, false)
		_resolving -= 1
		var index: int = edge["from_port"]
		return variant_type(outputs[index][1]) if index >= 0 and index < outputs.size() else TYPE_NIL
	var params: Dictionary = block.get("params", {})
	return typeof(params[key]) if params.has(key) else TYPE_NIL


## Whether operand [param key] of [param block] has a wire into it.
func _operand_wired(block: Dictionary, key: String) -> bool:
	var port := 0 if key == "a" else 1
	for edge: Dictionary in edges:
		if edge.get("to") == block.get("id") and edge.get("to_port") == port: return true
	return false


## Whether [param block] draws as an operator (D-065): an Operator, or Equal, which is one.
static func is_operator(block: Dictionary) -> bool:
	return block.get("kind") in ["operator", "equals"]


## The operator of an operator block: its [code]op[/code], [code]equal[/code] for Equal.
static func operator_of(block: Dictionary) -> String:
	if block.get("kind") == "equals": return "equal"
	return str((block.get("params", {}) as Dictionary).get("op", ""))


## The symbol an operator block shows between its inputs and its result.
static func symbol(block: Dictionary) -> String:
	var op := operator_of(block)
	if op == "equal": return "="
	return str((XREBlueprintOperators.OPERATORS[op] as Dictionary)["symbol"]) if XREBlueprintOperators.OPERATORS.has(op) else "?"


## Whether parameter [param key] of [param block] is unused: B of a unary operator.
static func is_unused(block: Dictionary, key: String) -> bool:
	return block.get("kind") == "operator" and key == "b" and XREBlueprintOperators.is_unary(operator_of(block))


## A new wire into an operand of an arithmetic or equality operator (D-065):
## the other operand's literal takes the wire's type, as Unreal's wildcard pins
## do — a number stays by a vector it multiplies, or divides. [param before]
## are the edges before the edit; true if a literal changed.
func adopt_operands(before: Array) -> bool:
	var changed := false
	for edge: Dictionary in edges:
		if before.has(edge) or not edge.get("to") is int or not edge.get("to_port") in [0, 1]: continue
		var block := find_node(edge["to"])
		if not is_operator(block) or not block.get("params") is Dictionary: continue
		var key := "a" if edge["to_port"] == 0 else "b"
		var other := "b" if key == "a" else "a"
		var params: Dictionary = block["params"]
		if not params.has(other) or is_unused(block, other) or _operand_wired(block, other): continue
		var adopted: Variant = adopted_literal(operator_of(block), key, operand_type(block, key), params[other])
		if adopted == null: continue
		params[other] = adopted
		changed = true
	return changed


## The literal [param literal] of the other operand of operator [param op] as
## it takes the type [param wired] of a wire into operand [param key]
## ([method adopt_operands]), or null when it stays as it is: the operator
## isn't arithmetic or equality, the types match, or a number scales a vector.
static func adopted_literal(op: String, key: String, wired: int, literal: Variant) -> Variant:
	if not (op == "equal" or XREBlueprintOperators.group_of(op) == XREBlueprintOperators.MATH): return null
	if wired in [TYPE_NIL, TYPE_OBJECT] or typeof(literal) == wired: return null
	var scales := op == "multiply" or (op == "divide" and key == "a")
	if scales and wired in XREBlueprintOperators.VECTORS and typeof(literal) in XREBlueprintOperators.NUMBERS: return null
	return convert_literal(literal, wired)


## Which of the Variant types [param types] a wire into operand
## [param key] of operator block [param block] may bring (D-080): those the
## operator works on with its other operand — what is wired into it, or its
## literal as it would take the wire's type ([method adopted_literal]).
## Equal and the equality operators compare anything.
func operand_types(block: Dictionary, key: String, types: Array) -> Array[int]:
	var op := operator_of(block)
	var other := "b" if key == "a" else "a"
	var params: Dictionary = block.get("params", {})
	var result: Array[int] = []
	for candidate: Variant in types:
		var type := int(candidate)
		if op == "equal":
			result.append(type)
			continue
		var second := TYPE_NIL
		if not XREBlueprintOperators.is_unary(op):
			second = operand_type(block, other)
			if not _operand_wired(block, other) and params.has(other):
				var adopted: Variant = adopted_literal(op, key, type, params[other])
				if adopted != null: second = typeof(adopted)
		var works := XREBlueprintOperators.result_type(op, type, second) if key == "a" else XREBlueprintOperators.result_type(op, second, type)
		if works != XREBlueprintOperators.INVALID: result.append(type)
	return result


## [param value] as a literal of Variant type [param type]: a number keeps its
## value, as a whole number or a real, and fills a vector; anything else is the
## type's default. Null for a type no literal has.
static func convert_literal(value: Variant, type: int) -> Variant:
	if typeof(value) in XREBlueprintOperators.NUMBERS:
		match type:
			TYPE_INT: return roundi(float(value))
			TYPE_FLOAT: return float(value)
			TYPE_VECTOR2: return Vector2.ONE * float(value)
			TYPE_VECTOR3: return Vector3.ONE * float(value)
	return XREBlueprintSchema.default_value(type)


## The Variant type of values of port category [param category]; TYPE_NIL for any value.
static func variant_type(category: int) -> int:
	match category:
		BOOLEAN: return TYPE_BOOL
		INTEGER: return TYPE_INT
		NUMBER: return TYPE_FLOAT
		TEXT: return TYPE_STRING
		VECTOR2: return TYPE_VECTOR2
		VECTOR3: return TYPE_VECTOR3
		OBJECT: return TYPE_OBJECT
		COLOR: return TYPE_COLOR
	return TYPE_NIL


## Index of the input of [param block] whose unconnected value is parameter
## [param key], or of its execution input for an empty key; -1 if none.
func input_port(block: Dictionary, key: String) -> int:
	if block.is_empty(): return -1
	var inputs := ports(block, true)
	for index: int in inputs.size():
		var spec: Array = inputs[index]
		if key.is_empty() and spec[1] == EXEC: return index
		if not key.is_empty() and spec.size() > 2 and spec[2] == key: return index
	return -1


## Maps Godot's Variant type to a graph port category.
static func port_type(type: int) -> int:
	return {TYPE_BOOL: BOOLEAN, TYPE_INT: INTEGER, TYPE_FLOAT: NUMBER, TYPE_STRING: TEXT, TYPE_STRING_NAME: TEXT, TYPE_VECTOR2: VECTOR2, TYPE_VECTOR3: VECTOR3, TYPE_OBJECT: OBJECT, TYPE_COLOR: COLOR}.get(type, VALUE)


## Allowed data conversions; execution can only connect to execution.
static func ports_compatible(from: int, to: int) -> bool:
	return from == to or (to == VALUE and from != EXEC) or (from == INTEGER and to == NUMBER)


## Index of the optional runtime Target input; object-valued data inputs are separate.
static func target_port(block: Dictionary) -> int:
	match block.get("kind"):
		"get_property": return 0
		"set_property": return 2
		"call":
			var function: Variant = block.get("function")
			if not function is Dictionary: return -1
			var inputs: Array = XREBlueprintFunctions.ports(function, int(block.get("property_type", TYPE_NIL)))[0]
			for index: int in inputs.size():
				var spec: Array = inputs[index]
				if spec.size() > 2 and spec[2] == "target": return index
	return -1


## Whether a block has a Target: a scene node path, and maybe a port that overrides it.
static func has_target(block: Dictionary) -> bool:
	return (block.get("params", {}) as Dictionary).has("target")


## Whether a block computes data on demand, without execution ports.
static func is_pure(block: Dictionary) -> bool:
	match block.get("kind"):
		"value", "get_property", "equals", "operator", "get_variable": return true
		"call":
			var function: Variant = block.get("function")
			return function is Dictionary and bool((function as Dictionary).get("pure", false))
	return false


## Whether a block starts execution.
static func is_event(block: Dictionary) -> bool:
	return block.get("kind") == "signal"


## Creates a block with isolated default parameters: a native kind or a preset ([constant PRESETS]).
## An empty dictionary if the preset's function can't be found.
static func make_node(id: int, kind: String, position: Vector2) -> Dictionary:
	if BLOCKS.has(kind) and kind != "call":
		return {"id": id, "kind": kind, "position": position, "params": (BLOCKS[kind]["params"] as Dictionary).duplicate(true)}
	if not PRESETS.has(kind):
		return {}
	var preset: Dictionary = PRESETS[kind]
	var block: Dictionary
	if preset["kind"] == "call":
		var signature := XREBlueprintFunctions.find(preset["scope"], preset["class"], preset["name"])
		if signature.is_empty():
			push_error("Blueprints: the function of preset %s is missing." % kind)
			return {}
		signature["title"] = preset["title"]
		block = make_call(id, signature, position)
	else:
		block = {"id": id, "kind": preset["kind"], "position": position, "params": (BLOCKS[preset["kind"]]["params"] as Dictionary).duplicate(true)}
	(block["params"] as Dictionary).merge((preset["params"] as Dictionary).duplicate(true), true)
	return block


## Creates an Operator block of operator [param op] ([XREBlueprintOperators]).
static func make_operator(id: int, op: String, position: Vector2) -> Dictionary:
	return {"id": id, "kind": "operator", "position": position, "params": XREBlueprintOperators.default_params(op)}


## Creates a call block of function [param signature] ([XREBlueprintFunctions]).
static func make_call(id: int, signature: Dictionary, position: Vector2) -> Dictionary:
	return {"id": id, "kind": "call", "position": position, "function": signature.duplicate(true), "params": XREBlueprintFunctions.default_params(signature)}


## Whether a literal can be represented by this version of the editor/compiler.
static func is_literal(value: Variant) -> bool:
	match typeof(value):
		TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return true
		TYPE_FLOAT:
			return is_finite(value)
		TYPE_VECTOR2:
			return (value as Vector2).is_finite()
		TYPE_VECTOR3:
			return (value as Vector3).is_finite()
		TYPE_COLOR:
			var color := value as Color
			return is_finite(color.r) and is_finite(color.g) and is_finite(color.b) and is_finite(color.a)
	return false


## Execution may loop; data dependencies must remain acyclic.
func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if not vr_center.is_finite() or not vr_workspace.origin.is_finite() or not vr_workspace.basis.x.is_finite() or not vr_workspace.basis.y.is_finite() or not vr_workspace.basis.z.is_finite() or absf(vr_workspace.basis.determinant()) < 0.0001:
		errors.append("Invalid VR workspace placement.")
	if format_version != FORMAT_VERSION:
		errors.append("Unsupported graph format: %d." % format_version)
	if nodes.size() > MAX_NODES:
		errors.append("A graph can contain at most %d blocks." % MAX_NODES)
	var ids: Dictionary = {}
	var names: Dictionary = {}
	for variable: Dictionary in variables:
		var name: String = str(variable.get("name", ""))
		var typed := variable.has("value") and is_literal(variable["value"]) or not variable.has("value") and variable.get("type") is int and int(variable["type"]) in XREBlueprintSchema.LITERAL_TYPES
		if not variable.get("name") is String or not name.is_valid_identifier() or names.has(name) or not typed:
			errors.append("Variables need unique identifiers and supported default values.")
		names[name] = true
		if variable.has("vr_position") and (not variable["vr_position"] is Vector2 or not (variable["vr_position"] as Vector2).is_finite()):
			errors.append("Variable %s has an invalid VR position." % name)
		if variable.has("vr_depth") and (not typeof(variable["vr_depth"]) in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(variable["vr_depth"]))):
			errors.append("Variable %s has invalid VR depth." % name)
		if variable.has("vr_collapsed") and not variable["vr_collapsed"] is bool:
			errors.append("Variable %s has an invalid VR drawer." % name)
	for block: Dictionary in nodes:
		var id: Variant = block.get("id")
		var kind: Variant = block.get("kind")
		if not id is int or id < 1 or ids.has(id):
			errors.append("Block IDs must be unique positive integers.")
			continue
		ids[id] = true
		if not kind is String or not BLOCKS.has(kind):
			errors.append("Block #%s has an unknown kind." % id)
			continue
		if not block.get("position") is Vector2 or not block.get("params") is Dictionary:
			errors.append("Block #%s has invalid position or parameters." % id)
			continue
		if block.has("vr_depth") and (not typeof(block["vr_depth"]) in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(block["vr_depth"]))):
			errors.append("Block #%s has invalid VR depth." % id)
		if block.has("vr_rotation") and (not block["vr_rotation"] is Vector3 or not (block["vr_rotation"] as Vector3).is_finite()):
			errors.append("Block #%s has invalid VR rotation." % id)
		if block.has("vr_anchor") and (not block["vr_anchor"] is Vector3 or not (block["vr_anchor"] as Vector3).is_finite()):
			errors.append("Block #%s has invalid VR anchor." % id)
		if block.has("vr_links") and not block["vr_links"] is Array:
			errors.append("Block #%s has invalid VR links." % id)
		if block.has("vr_heading") and not str(block["vr_heading"]) in ["operation", "member"]:
			errors.append("Block #%s has invalid VR heading." % id)
		for key: String in [SCENE_BENDS, VARIABLE_BENDS]:
			if block.has(key) and not _valid_bends(block[key]): errors.append("Block #%s has invalid VR bends." % id)
		var params: Dictionary = block["params"]
		if kind == "call":
			errors.append_array(_validate_call(block))
		var defaults: Dictionary = BLOCKS[kind]["params"]
		var sockets := socket_keys(block) if kind != "call" else ([] as Array[String])
		for key: String in defaults:
			# A port's value may be taken out: the build reports the empty socket (D-054).
			if not params.has(key) and key in sockets or is_unused(block, key): continue
			if not params.has(key) or not is_literal(params[key]):
				errors.append("Block #%s: invalid %s." % [id, key])
				continue
			if key in ["target", "property", "signal"]:
				if not params[key] is String or (key != "target" and str(params[key]).strip_edges().is_empty()):
					errors.append("Block #%s: %s must be nonempty text." % [id, key])
			if key == "condition" and not params[key] is bool:
				errors.append("Block #%s: expected a boolean." % id)
			if key == "policy" and not params[key] in ["parallel", "ignore", "restart"]:
				errors.append("Block #%s: unknown event policy." % id)
			if key == "op" and not XREBlueprintOperators.OPERATORS.has(params[key]):
				errors.append("Block #%s: unknown operator." % id)
			if key == "variable" and not params[key] is String:
				errors.append("Block #%s: variable must be an identifier." % id)
		if block.has("property_type") and (not block["property_type"] is int or block["property_type"] < TYPE_NIL or block["property_type"] >= TYPE_MAX):
			errors.append("Block #%s: invalid property type." % id)
		if not block.get("arguments", []) is Array:
			errors.append("Block #%s: invalid signal arguments." % id)
		else:
			for argument: Variant in block.get("arguments", []):
				if not argument is Dictionary or not (argument as Dictionary).get("name") is String or not (argument as Dictionary).get("type") is int:
					errors.append("Block #%s: invalid signal argument." % id)
				elif int(argument["type"]) < TYPE_NIL or int(argument["type"]) >= TYPE_MAX:
					errors.append("Block #%s: invalid signal argument type." % id)
	if not errors.is_empty():
		return errors
	var occupied: Dictionary = {}
	var degrees: Dictionary = {}
	var outgoing: Dictionary = {}
	for id: int in ids:
		degrees[id] = 0
		outgoing[id] = []
	for edge: Dictionary in edges:
		if not _valid_edge_shape(edge):
			errors.append("A connection has invalid endpoints or ports.")
			continue
		if edge.has("vr_bends") and not _valid_bends(edge["vr_bends"]):
			errors.append("A connection has invalid VR bends.")
		var from_block := find_node(edge["from"])
		var to_block := find_node(edge["to"])
		var outputs := ports(from_block, false)
		var inputs := ports(to_block, true)
		var from_type: int = outputs[edge["from_port"]][1]
		var to_type: int = inputs[edge["to_port"]][1]
		if not ports_compatible(from_type, to_type):
			errors.append("Incompatible ports on #%d and #%d." % [edge["from"], edge["to"]])
		# Execution may merge; values may fan out. The other directions are single.
		var key := ("out:%d:%d" % [edge["from"], edge["from_port"]] if from_type == EXEC
				else "in:%d:%d" % [edge["to"], edge["to_port"]])
		if occupied.has(key):
			errors.append("Port already connected: %s." % key)
		occupied[key] = true
		if from_type != EXEC:
			degrees[edge["to"]] += 1
			(outgoing[edge["from"]] as Array).append(edge["to"])
	var pending: Array[int] = []
	for id: int in degrees:
		if degrees[id] == 0:
			pending.append(id)
	var visited := 0
	while not pending.is_empty():
		var id: int = pending.pop_back()
		visited += 1
		for next: int in outgoing[id]:
			degrees[next] -= 1
			if degrees[next] == 0:
				pending.append(next)
	if visited != ids.size():
		errors.append("Data dependency cycles are not supported. Store changing state in a variable.")
	return errors


## The function of a call block and its parameters: one per argument with a value.
func _validate_call(block: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	var id: int = block["id"]
	var function: Variant = block.get("function")
	if not function is Dictionary or not (function as Dictionary).get("args") is Array or not (function as Dictionary).get("name") is String \
			or str((function as Dictionary)["name"]).is_empty() or not (function as Dictionary).get("scope") in ["method", "static", "global"]:
		errors.append("Block #%d has an invalid function." % id)
		return errors
	var signature := function as Dictionary
	if not XREBlueprintFunctions.problem(signature).is_empty():
		errors.append("Block #%d: %s." % [id, XREBlueprintFunctions.problem(signature)])
	var params: Dictionary = block["params"]
	for argument: Variant in signature["args"]:
		if not argument is Dictionary or not (argument as Dictionary).get("name") is String or not (argument as Dictionary).get("type") is int \
				or not (argument as Dictionary).get("key", "") is String or int(argument["type"]) < TYPE_NIL or int(argument["type"]) >= TYPE_MAX:
			errors.append("Block #%d has an invalid function argument." % id)
			return errors
		var entry := argument as Dictionary
		if entry.get("target", false):
			if not params.get("target") is String:
				errors.append("Block #%d: target must be text." % id)
			continue
		if not XREBlueprintFunctions.has_literal(entry):
			continue
		var key: String = entry["key"]
		if not params.has(key) and not entry.get("literal", false) and not entry.get("advanced", false): continue
		if not params.has(key) or not is_literal(params[key]):
			errors.append("Block #%d: invalid %s." % [id, key])
			continue
		if not str(entry.get("provider", "")).is_empty() and not params[key] is String:
			errors.append("Block #%d: %s must be text." % [id, key])
		if entry.get("positive", false) and (not typeof(params[key]) in [TYPE_INT, TYPE_FLOAT] or float(params[key]) <= 0.0):
			errors.append("Block #%d: %s must be positive." % [id, key])
		if entry.get("non_negative", false) and (not typeof(params[key]) in [TYPE_INT, TYPE_FLOAT] or float(params[key]) < 0.0):
			errors.append("Block #%d: %s must not be negative." % [id, key])
	var extra: Variant = signature.get("extra", 0)
	if not extra is int or int(extra) < 0 or int(extra) > XREBlueprintFunctions.MAX_EXTRA or (int(extra) > 0 and not signature.get("vararg", false)):
		errors.append("Block #%d: invalid number of extra arguments." % id)
	else:
		for index: int in int(extra):
			if params.has(XREBlueprintFunctions.extra_key(index)) and not is_literal(params.get(XREBlueprintFunctions.extra_key(index))):
				errors.append("Block #%d: invalid %s." % [id, XREBlueprintFunctions.extra_key(index)])
	return errors


## Bends of a connection (D-081): finite points, at most [constant MAX_BENDS].
static func _valid_bends(bends: Variant) -> bool:
	if not bends is PackedVector3Array or (bends as PackedVector3Array).size() > MAX_BENDS: return false
	for point: Vector3 in bends as PackedVector3Array:
		if not point.is_finite(): return false
	return true


func _valid_edge_shape(edge: Dictionary) -> bool:
	for key: String in ["from", "from_port", "to", "to_port"]:
		if not edge.get(key) is int:
			return false
	var from_block := find_node(edge["from"])
	var to_block := find_node(edge["to"])
	if from_block.is_empty() or to_block.is_empty():
		return false
	var outputs := ports(from_block, false)
	var inputs := ports(to_block, true)
	return edge["from_port"] >= 0 and edge["from_port"] < outputs.size() and edge["to_port"] >= 0 and edge["to_port"] < inputs.size()
