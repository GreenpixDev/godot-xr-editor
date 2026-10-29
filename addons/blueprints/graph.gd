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
##
## Format 4 adds the graph's own functions ([member functions],
## [XREBlueprintUserFunctions]): each keeps its body's blocks and wires, from
## an Entry to its Returns. A body is edited as a graph of its own
## ([method body]) whose edits go back into this one ([method embed]), so
## that one history covers the file. A call of one is a [code]call[/code]
## whose function's scope is "local".

const FORMAT_VERSION := 4
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
## The built-in compound values Break takes apart and Make puts together (D-139).
const VECTOR4 := 10
const VECTOR2I := 11
const VECTOR3I := 12
const RECT2 := 13
const BOUNDS := 14
const QUATERNION := 15
const BASIS := 16
const TRANSFORM2D := 17
const TRANSFORM3D := 18
const PLANE := 19
## Variant types of the port categories that have one, by category.
const CATEGORY_TYPES: Dictionary[int, int] = {BOOLEAN: TYPE_BOOL, INTEGER: TYPE_INT, NUMBER: TYPE_FLOAT, TEXT: TYPE_STRING, VECTOR2: TYPE_VECTOR2,
		VECTOR3: TYPE_VECTOR3, OBJECT: TYPE_OBJECT, COLOR: TYPE_COLOR, VECTOR4: TYPE_VECTOR4, VECTOR2I: TYPE_VECTOR2I, VECTOR3I: TYPE_VECTOR3I,
		RECT2: TYPE_RECT2, BOUNDS: TYPE_AABB, QUATERNION: TYPE_QUATERNION, BASIS: TYPE_BASIS, TRANSFORM2D: TYPE_TRANSFORM2D,
		TRANSFORM3D: TYPE_TRANSFORM3D, PLANE: TYPE_PLANE}
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
	# Its ports follow its operator ([method ports]); a unary one has no B, a
	# variadic one keeps its count in "operands" and C… as its parameters (D-136).
	"operator": {"title": "Operator", "in": [["A", VALUE, "a"], ["B", VALUE, "b"]], "out": [["Result", VALUE, ""]], "params": {"op": "add", "a": 0.0, "b": 0.0}},
	"get_variable": {"title": "Get Variable", "in": [], "out": [["Value", VALUE, ""]], "params": {"variable": ""}},
	# Its outputs Then 0… follow "outputs" (D-138); each runs after the chain of the one before ends.
	"sequence": {"title": "Sequence", "in": [["In", EXEC, ""]], "out": [], "params": {"outputs": 2}},
	# A case per output, its value in case_0…, then Default (D-138); "on" is int, string or enum.
	"switch": {"title": "Switch", "in": [["In", EXEC, ""], ["Selection", INTEGER, "selection"]], "out": [], "params": {"on": "int", "selection": 0, "cases": 2, "case_0": 0, "case_1": 1}},
	# A value taken apart into its fields and one put together from them (D-139):
	# their ports follow the block's "struct" and "hidden" ([XREBlueprintStructs]).
	"break": {"title": "Break", "in": [["Target", VALUE, ""]], "out": [], "params": {}},
	"make": {"title": "Make", "in": [], "out": [["Result", VALUE, ""]], "params": {}},
	"set_variable": {"title": "Set Variable", "in": [["In", EXEC, ""], ["Value", VALUE, "value"]], "out": [["Then", EXEC, ""]], "params": {"variable": "", "value": false}},
	# A function body's start and ends: their ports are its inputs and outputs ([member function_signature]).
	"entry": {"title": "Entry", "in": [], "out": [], "params": {}},
	"return": {"title": "Return", "in": [], "out": [], "params": {}},
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
## The graph's own functions (format 4, [XREBlueprintUserFunctions]):
## [code]{"name", "pure", "inputs", "outputs", "nodes", "edges", "vr_center"}[/code].
@export var functions: Array[Dictionary] = []
## Of a function's body ([method body]): its signature, the function without
## its blocks and wires, which its Entry and Return take their ports from.
## Empty for a file's graph.
var function_signature: Dictionary = {}
## Of a function's body: the graph it belongs to, whose functions its calls call.
var parent: XREBlueprintGraph
## How deep [method operand_type] follows wires back through operators, against a cycle that validation reports.
var _resolving := 0


## Independent snapshot for undo and dirty-state comparison.
func snapshot() -> Dictionary:
	return {"nodes": nodes.duplicate(true), "edges": edges.duplicate(true), "variables": variables.duplicate(true), "host_path": host_path, "scene_path": scene_path, "format_version": format_version, "vr_placed": vr_placed, "vr_workspace": vr_workspace, "vr_center": vr_center,
			"functions": functions.duplicate(true), "function": function_signature.duplicate(true)}


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
	# The functions' signatures (their plates and calls), not their bodies; a body's own.
	var signatures: Array = functions.map(XREBlueprintUserFunctions.signature_of)
	return [blocks, wires, kept, host_path, scene_path, vr_placed, vr_workspace, vr_center, signatures, function_signature]


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
	functions.assign((state.get("functions", []) as Array).duplicate(true))
	function_signature = (state.get("function", {}) as Dictionary).duplicate(true)
	emit_changed()


## The index of function [param name] among [member functions], -1 if there is none.
func function_index(name: String) -> int:
	for index: int in functions.size():
		if functions[index].get("name") == name: return index
	return -1


## Function [param name] of this graph, or of the graph a body belongs to; empty if there is none.
func find_function(name: String) -> Dictionary:
	var owner := parent if parent != null else self
	var index := owner.function_index(name)
	return owner.functions[index] if index >= 0 else {}


## The state of function [param name]'s body as a graph of its own: its blocks,
## wires and center, this graph's variables, host and placement.
func body_state(name: String) -> Dictionary:
	var index := function_index(name)
	if index < 0: return {}
	var entry: Dictionary = functions[index]
	var state := snapshot()
	state["nodes"] = (entry.get("nodes", []) as Array).duplicate(true)
	state["edges"] = (entry.get("edges", []) as Array).duplicate(true)
	state["vr_center"] = entry.get("vr_center", Vector2.ZERO)
	state["functions"] = []
	state["function"] = XREBlueprintUserFunctions.signature_of(entry)
	return state


## Function [param name]'s body as a graph of its own, which its views edit:
## [method embed] puts its edits back. Null if there is no such function.
func body(name: String) -> XREBlueprintGraph:
	if function_index(name) < 0: return null
	var view := XREBlueprintGraph.new()
	view.parent = self
	view.restore(body_state(name))
	return view


## This graph's state with [param state], an edit of function [param name]'s
## body, put back: its blocks, wires and center into the function, what the
## body shares — variables, host, placement — into the graph.
func embed(name: String, state: Dictionary) -> Dictionary:
	var result := snapshot()
	var index := function_index(name)
	if index < 0: return result
	var entry: Dictionary = (result["functions"] as Array)[index]
	entry["nodes"] = (state["nodes"] as Array).duplicate(true)
	entry["edges"] = (state["edges"] as Array).duplicate(true)
	entry["vr_center"] = state.get("vr_center", Vector2.ZERO)
	result["variables"] = (state.get("variables", result["variables"]) as Array).duplicate(true)
	for key: String in ["host_path", "scene_path", "vr_placed", "vr_workspace"]:
		if state.has(key): result[key] = state[key]
	return result


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
		"break", "make":
			var name := XREBlueprintStructs.name_of(block.get("struct", {}))
			return ("Break" if kind == "break" else "Make") + (" " + name if not name.is_empty() else "")
		"switch":
			match str(params.get("on", "")):
				"string": return "Switch on String"
				"enum": return "Switch on " + str(params.get("enum", "Enum")).get_slice(".", 1)
			return "Switch on Int"
	return str(BLOCKS[kind]["title"]) if BLOCKS.has(kind) else kind


## The title of [param block] in this graph: an Entry shows its function's name.
func title_of(block: Dictionary) -> String:
	if block.get("kind") == "entry" and not function_signature.is_empty(): return str(function_signature.get("name", "Entry"))
	return title(block)


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
	if kind in ["entry", "return"]: return XREBlueprintUserFunctions.body_ports(function_signature, kind, input)
	var result: Array = (BLOCKS[kind]["in" if input else "out"] as Array).duplicate(true)
	var params: Dictionary = block["params"]
	if kind == "sequence" and not input:
		for index: int in pin_count(block): result.append(["Then %d" % index, EXEC])
	if kind == "switch":
		# Selection is of the cases' type; an output per case, keyed by its value's parameter, then Default (D-138).
		if input: result[1][1] = TEXT if params.get("on") == "string" else INTEGER
		else:
			for index: int in pin_count(block): result.append([case_label(block, index), EXEC, case_key(index)])
			result.append(["Default", EXEC])
	if kind in ["break", "make"]: return _struct_ports(block, input)
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


## An operator's ports (D-065): A and B, or A alone, or from A to H for a
## variadic one (D-136), of the type its operator takes — booleans for logic,
## numbers to order and for min and max, any value else — and its Result, of
## the type its operands give ([method operand_type]).
func _operator_ports(block: Dictionary, input: bool) -> Array:
	var op := str((block["params"] as Dictionary).get("op", ""))
	var count := operand_count(block)
	if input:
		var operand := port_type(XREBlueprintOperators.operand_type(op))
		var inputs: Array = []
		for index: int in count:
			var key: String = XREBlueprintOperators.OPERAND_KEYS[index]
			inputs.append([key.to_upper(), operand, key])
		return inputs
	var types: Array[int] = []
	for index: int in count: types.append(operand_type(block, XREBlueprintOperators.OPERAND_KEYS[index]))
	return [["Result", port_type(XREBlueprintOperators.fold_type(op, types)), ""]]


## How many operands an operator or Equal block has: one for a unary
## operator, its [code]operands[/code] for a variadic one (D-136), else two.
static func operand_count(block: Dictionary) -> int:
	if block.get("kind") == "equals": return 2
	var op := operator_of(block)
	if XREBlueprintOperators.is_unary(op): return 1
	var count: Variant = (block.get("params", {}) as Dictionary).get("operands", XREBlueprintOperators.MIN_OPERANDS)
	if not XREBlueprintOperators.is_variadic(op) or not count is int: return XREBlueprintOperators.MIN_OPERANDS
	return clampi(count, XREBlueprintOperators.MIN_OPERANDS, XREBlueprintOperators.MAX_OPERANDS)


## Fewest and most pins a block whose pins change has (D-136, D-138).
const MIN_PINS := 2
const MAX_PINS := 8


## How many outputs a Sequence has, or cases a Switch (D-138), from two to eight.
static func pin_count(block: Dictionary) -> int:
	var params: Dictionary = block.get("params", {})
	var count: Variant = params.get("outputs" if block.get("kind") == "sequence" else "cases", MIN_PINS)
	return clampi(count, MIN_PINS, MAX_PINS) if count is int else MIN_PINS


## The parameter of a Switch's case [param index]: its value (D-138).
static func case_key(index: int) -> String:
	return "case_%d" % index


## What the output of a Switch's case [param index] says: its value, a text in
## quotes; an enumeration's case keeps its constant's name (D-138).
static func case_label(block: Dictionary, index: int) -> String:
	var params: Dictionary = block.get("params", {})
	var value: Variant = params.get(case_key(index))
	return "\"%s\"" % str(value) if params.get("on") == "string" else str(value)


## The constants of enumeration [param path], "Class.Enum", by name: of an
## engine class or of a script class's enum; empty if there is none.
static func enum_constants(path: String) -> Dictionary:
	var result := {}
	var cls := path.get_slice(".", 0)
	var name := path.get_slice(".", 1)
	if cls.is_empty() or name.is_empty(): return result
	if ClassDB.class_exists(cls):
		if not ClassDB.class_has_enum(cls, name): return result
		for constant: String in ClassDB.class_get_enum_constants(cls, name): result[constant] = ClassDB.class_get_integer_constant(cls, constant)
		return result
	var script := XREBlueprintFunctions.global_script(cls)
	var found: Variant = script.get_script_constant_map().get(name) if script != null else null
	if found is Dictionary: result = (found as Dictionary).duplicate()
	return result


## The pins of [param block] that are added and removed (D-136, D-138):
## [code]{"input": side, "count": n, "can_add": bool}[/code] — a variadic
## operator's inputs, a Sequence's outputs, a Switch's cases before Default —,
## empty for a block whose pins are fixed. They are the first of their side.
static func variable_pins(block: Dictionary) -> Dictionary:
	match str(block.get("kind", "")):
		"operator":
			if not XREBlueprintOperators.is_variadic(operator_of(block)): return {}
			var count := operand_count(block)
			return {"input": true, "count": count, "can_add": count < XREBlueprintOperators.MAX_OPERANDS}
		"sequence":
			return {"input": false, "count": pin_count(block), "can_add": pin_count(block) < MAX_PINS}
		"switch":
			var count := pin_count(block)
			var free := count < MAX_PINS
			var params: Dictionary = block["params"]
			if free and params.get("on") == "enum":
				var used: Array = []
				for index: int in count: used.append(params.get(case_key(index)))
				free = enum_constants(str(params.get("enum", ""))).keys().any(func(name: Variant) -> bool: return not used.has(name))
			return {"input": false, "count": count, "can_add": free}
	return {}


## The pins of [param block] that are added and removed, as
## [method variable_pins] says, with [code]"offset"[/code], how many ports of
## their side come before them, and [code]"fewest"[/code] it keeps: of a
## body's Entry the function's inputs, of its Return the outputs, after Then
## or In, from none ([XREBlueprintUserFunctions]).
func pins_of(block: Dictionary) -> Dictionary:
	var kind := str(block.get("kind", ""))
	if kind in ["entry", "return"] and not function_signature.is_empty():
		var count := (function_signature.get("inputs" if kind == "entry" else "outputs", []) as Array).size()
		return {"input": kind == "return", "count": count, "can_add": count < XREBlueprintUserFunctions.MAX_PINS, "offset": 0 if function_signature.get("pure", false) else 1, "fewest": 0}
	var pins := variable_pins(block)
	if not pins.is_empty(): pins.merge({"offset": 0, "fewest": MIN_PINS})
	return pins


## The value a new case of Switch [param block] takes (D-138): the largest
## number + 1, a text no case has, the name of the first constant no case
## has; null when an enumeration has none left.
static func next_case(block: Dictionary) -> Variant:
	var params: Dictionary = block["params"]
	var used: Array = []
	for index: int in pin_count(block): used.append(params.get(case_key(index)))
	match str(params.get("on", "")):
		"string":
			var index := used.size()
			while used.has("case_%d" % index): index += 1
			return "case_%d" % index
		"enum":
			for name: String in enum_constants(str(params.get("enum", ""))):
				if not used.has(name): return name
			return null
	var largest := -1
	for value: Variant in used:
		if value is int: largest = maxi(largest, value)
	return largest + 1


## Creates a Switch on [param on] — "int", "string" or "enum" of
## [param enum_path] — with two cases (D-138).
static func make_switch(id: int, on: String, position: Vector2, enum_path: String = "") -> Dictionary:
	var block := make_node(id, "switch", position)
	var params: Dictionary = block["params"]
	params["on"] = on
	if on == "string":
		params["selection"] = ""
		params["case_0"] = "case_0"
		params["case_1"] = "case_1"
	elif on == "enum":
		# An enumeration's cases and selection keep its constants' names; the build makes them numbers.
		params["enum"] = enum_path
		var names := enum_constants(enum_path).keys()
		params["selection"] = str(names[0]) if not names.is_empty() else ""
		params["case_0"] = str(names[0]) if names.size() > 0 else ""
		params["case_1"] = str(names[1]) if names.size() > 1 else ""
	return block


## The enumeration, "Class.Enum", whose constant output [param port] of
## [param block] gives, empty when none (D-138): a property's, a call's
## result, a signal's argument, a Break's field.
func output_enum(block: Dictionary, port: int) -> String:
	var path := ""
	match str(block.get("kind", "")):
		"get_property": path = str(block.get("property_enum", "")) if port == 0 else ""
		"call", "signal", "break": path = output_class(block, port)
	var outputs := ports(block, false)
	if not path.contains(".") or port < 0 or port >= outputs.size() or outputs[port][1] != INTEGER: return ""
	return path if enum_constants(path).size() >= MIN_PINS else ""


## A new wire into a Switch's Selection from an enumeration's constant makes
## it a Switch on that enumeration (D-138), as a wire into Break types it:
## its cases take the constants in order, as many as it had while there are;
## the wires of cases gone go, Default keeps its own. [param before] are the
## edges before the edit; true if a block changed.
func adopt_enums(before: Array) -> bool:
	var changed := false
	for edge: Dictionary in edges.duplicate():
		if before.has(edge) or not edge.get("to") is int or not edge.get("from") is int: continue
		var target := find_node(edge["to"])
		if target.get("kind") != "switch" or edge["to_port"] != input_port(target, "selection"): continue
		var path := output_enum(find_node(edge["from"]), int(edge["from_port"]))
		var params: Dictionary = target["params"]
		if path.is_empty() or (params.get("on") == "enum" and str(params.get("enum", "")) == path): continue
		var names := enum_constants(path).keys()
		var old_count := pin_count(target)
		var count := mini(old_count, names.size())
		for index: int in old_count: params.erase(case_key(index))
		params["on"] = "enum"
		params["enum"] = path
		params["cases"] = count
		params["selection"] = str(names[0])
		for index: int in count: params[case_key(index)] = str(names[index])
		var kept: Array[Dictionary] = []
		for wire: Dictionary in edges:
			if wire["from"] == target["id"] and int(wire["from_port"]) >= count:
				if int(wire["from_port"]) < old_count: continue
				wire["from_port"] = count
			kept.append(wire)
		edges = kept
		changed = true
	return changed


## Break's Target and the fields it shows, Make's fields and its Result
## (D-139), each field keyed by its name: Make's input of a literal type falls
## back to its parameter, Break's Target to "value" for a vector or a color.
## Without a struct Break takes any value and gives nothing, Make gives any.
static func _struct_ports(block: Dictionary, input: bool) -> Array:
	var struct: Dictionary = block.get("struct", {})
	var type := port_type(int(struct["type"])) if not struct.is_empty() else VALUE
	var result: Array = []
	if block["kind"] == "break":
		if input: return [["Target", type, "value"]]
		for field: Dictionary in XREBlueprintStructs.shown(block): result.append([str(field["name"]), port_type(int(field["type"])), str(field["name"])])
		return result
	if not input: return [["Result", type, ""]]
	for field: Dictionary in XREBlueprintStructs.shown(block): result.append([str(field["name"]), port_type(int(field["type"])), str(field["name"])])
	return result


## The class of the object output [param port] of [param block] gives, empty
## when unknown: a signal argument's, a call's result's, a Break's field's,
## a Make's (D-139).
func output_class(block: Dictionary, port: int) -> String:
	match str(block.get("kind", "")):
		"signal":
			var arguments: Array = block.get("arguments", [])
			return str((arguments[port - 1] as Dictionary).get("class_name", "")) if port >= 1 and port <= arguments.size() else ""
		"call":
			var outputs := ports(block, false)
			return str((block["function"] as Dictionary).get("return_class", "")) if port >= 0 and port < outputs.size() and outputs[port][0] == "Result" else ""
		"break":
			var fields := XREBlueprintStructs.shown(block)
			return str(fields[port].get("class_name", "")) if port >= 0 and port < fields.size() else ""
		"make":
			return str((block.get("struct", {}) as Dictionary).get("class", ""))
	return ""


## The class an object input [param port] of [param block] wants, empty when
## any: a call argument's (D-139).
func input_class(block: Dictionary, port: int) -> String:
	if block.get("kind") != "call": return ""
	var inputs := ports(block, true)
	if port < 0 or port >= inputs.size() or str(inputs[port][2]).is_empty(): return ""
	for argument: Dictionary in (block["function"] as Dictionary)["args"]:
		if str(argument.get("key", "")) == str(inputs[port][2]): return str(argument.get("class_name", ""))
	return ""


## A new wire types a Break or a Make (D-139), as a wire into Set's Target
## picks its kind (D-102): into Break's Target, by what comes — its type, its
## class —; from Make's Result, by the input it goes into, when Make can build
## that. A block of the same type stays. Its wires keep their fields by name;
## a field the new type hasn't takes its wire away. [param before] are the
## edges before the edit; true if a block changed.
func adopt_structs(before: Array) -> bool:
	var retypes: Dictionary = {}
	for edge: Dictionary in edges:
		if before.has(edge) or not edge.get("to") is int or not edge.get("from") is int: continue
		var target := find_node(edge["to"])
		var source := find_node(edge["from"])
		if target.get("kind") == "break" and edge["to_port"] == 0 and not source.is_empty():
			var outputs := ports(source, false)
			if edge["from_port"] < 0 or edge["from_port"] >= outputs.size(): continue
			var struct := XREBlueprintStructs.describe(variant_type(outputs[edge["from_port"]][1]), output_class(source, edge["from_port"]))
			if not struct.is_empty() and not _same_struct(target, struct): retypes[target["id"]] = struct
		if source.get("kind") == "make" and edge["from_port"] == 0 and not target.is_empty():
			var inputs := ports(target, true)
			if edge["to_port"] < 0 or edge["to_port"] >= inputs.size(): continue
			var type := variant_type(inputs[edge["to_port"]][1])
			var cls := input_class(target, edge["to_port"])
			if XREBlueprintStructs.can_make(type, cls):
				var made := XREBlueprintStructs.describe(type, cls, true)
				if not _same_struct(source, made): retypes[source["id"]] = made
	for id: int in retypes: retype(id, retypes[id])
	return not retypes.is_empty()


static func _same_struct(block: Dictionary, struct: Dictionary) -> bool:
	var own: Dictionary = block.get("struct", {})
	return not own.is_empty() and own["type"] == struct["type"] and str(own.get("class", "")) == str(struct.get("class", ""))


## Gives Break or Make [param id] [param struct] (D-139): its fields hidden at
## first, a Make's literals for its fields — kept where a field of the name had
## one —, and its wires moved to their fields by name, those without one gone.
func retype(id: int, struct: Dictionary) -> void:
	var block := find_node(id)
	if block.is_empty(): return
	var before_in := _struct_keys(ports(block, true))
	var before_out := _struct_keys(ports(block, false))
	block["struct"] = struct
	block["hidden"] = XREBlueprintStructs.default_hidden(struct)
	if block["kind"] == "make":
		var old: Dictionary = block["params"]
		var params := {}
		for field: Dictionary in struct["fields"]:
			var name := str(field["name"])
			if int(field["type"]) in XREBlueprintSchema.LITERAL_TYPES:
				params[name] = old[name] if old.has(name) and typeof(old[name]) == int(field["type"]) else XREBlueprintSchema.default_value(int(field["type"]))
		block["params"] = params
	elif int(struct["type"]) in XREBlueprintSchema.LITERAL_TYPES:
		(block["params"] as Dictionary)["value"] = XREBlueprintSchema.default_value(int(struct["type"]))
	else:
		(block["params"] as Dictionary).erase("value")
	var after_in := _struct_keys(ports(block, true))
	var after_out := _struct_keys(ports(block, false))
	var kept: Array[Dictionary] = []
	for edge: Dictionary in edges:
		if edge["to"] == id:
			var index := after_in.find(before_in[edge["to_port"]]) if edge["to_port"] < before_in.size() else -1
			if index < 0: continue
			edge["to_port"] = index
		if edge["from"] == id:
			var index := after_out.find(before_out[edge["from_port"]]) if edge["from_port"] < before_out.size() else -1
			if index < 0: continue
			edge["from_port"] = index
		kept.append(edge)
	edges.assign(kept)


static func _struct_keys(specs: Array) -> Array[String]:
	var keys: Array[String] = []
	for spec: Array in specs: keys.append(str(spec[2]) if spec.size() > 2 and not str(spec[2]).is_empty() else "#" + str(spec[0]))
	return keys


## The Variant type of operand [param key] (A, B, C…) of an operator or Equal
## block: of the output its wire comes from, else of its literal; TYPE_NIL
## when it can't be known before the game runs.
func operand_type(block: Dictionary, key: String) -> int:
	var port := XREBlueprintOperators.OPERAND_KEYS.find(key)
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
	var port := XREBlueprintOperators.OPERAND_KEYS.find(key)
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


## Whether parameter [param key] of [param block] is unused: B of a unary
## operator, an operand past a variadic one's count (D-136).
static func is_unused(block: Dictionary, key: String) -> bool:
	if block.get("kind") == "switch" and key.begins_with("case_") and key.trim_prefix("case_").is_valid_int():
		return int(key.trim_prefix("case_")) >= pin_count(block)
	if block.get("kind") != "operator": return false
	var index := XREBlueprintOperators.OPERAND_KEYS.find(key)
	return index >= 0 and index >= operand_count(block)


## A new wire into an operand of an arithmetic or equality operator (D-065):
## the other operands' literals take the wire's type, as Unreal's wildcard pins
## do — a number stays by a vector it multiplies, or divides. [param before]
## are the edges before the edit; true if a literal changed.
func adopt_operands(before: Array) -> bool:
	var changed := false
	for edge: Dictionary in edges:
		if before.has(edge) or not edge.get("to") is int or not edge.get("to_port") is int: continue
		var block := find_node(edge["to"])
		if not is_operator(block) or not block.get("params") is Dictionary: continue
		var port: int = edge["to_port"]
		if port < 0 or port >= operand_count(block): continue
		var key: String = XREBlueprintOperators.OPERAND_KEYS[port]
		var params: Dictionary = block["params"]
		for index: int in operand_count(block):
			var other: String = XREBlueprintOperators.OPERAND_KEYS[index]
			if other == key or not params.has(other) or _operand_wired(block, other): continue
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
	var params: Dictionary = block.get("params", {})
	var result: Array[int] = []
	for candidate: Variant in types:
		var type := int(candidate)
		if op == "equal":
			result.append(type)
			continue
		# The operands as they would be with this wire, folded in order (D-136).
		var operands: Array[int] = []
		for index: int in operand_count(block):
			var other: String = XREBlueprintOperators.OPERAND_KEYS[index]
			if other == key:
				operands.append(type)
				continue
			var second := operand_type(block, other)
			if not _operand_wired(block, other) and params.has(other):
				var adopted: Variant = adopted_literal(op, key, type, params[other])
				if adopted != null: second = typeof(adopted)
			operands.append(second)
		if XREBlueprintOperators.fold_type(op, operands) != XREBlueprintOperators.INVALID: result.append(type)
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
	return CATEGORY_TYPES.get(category, TYPE_NIL)


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
	if type == TYPE_STRING_NAME: return TEXT
	for category: int in CATEGORY_TYPES:
		if CATEGORY_TYPES[category] == type: return category
	return VALUE


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
		"value", "get_property", "equals", "operator", "get_variable", "break", "make": return true
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
	if function_signature.is_empty(): errors.append_array(XREBlueprintUserFunctions.validate(self))
	else: errors.append_array(XREBlueprintUserFunctions.validate_body(self))
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
		# An Entry and a Return belong to a function's body; an event doesn't.
		if kind in ["entry", "return"] and function_signature.is_empty() or kind == "signal" and not function_signature.is_empty():
			errors.append("Block #%s: %s can't be here." % [id, title(block)])
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
		if kind == "return":
			for key: String in params:
				if not is_literal(params[key]): errors.append("Block #%s: invalid %s." % [id, key])
		if kind == "operator": errors.append_array(_validate_operands(block))
		if kind in ["sequence", "switch"]: errors.append_array(_validate_pins(block))
		if kind in ["break", "make"]: errors.append_array(_validate_struct(block))
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


## The operands of an operator block past A and B (D-136): a count only a
## variadic operator has, from two to eight, and a literal for each operand
## that keeps one, none past the count.
static func _validate_operands(block: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	var params: Dictionary = block["params"]
	var op := str(params.get("op", ""))
	if params.has("operands"):
		var count: Variant = params["operands"]
		if not XREBlueprintOperators.is_variadic(op) or not count is int or int(count) < XREBlueprintOperators.MIN_OPERANDS or int(count) > XREBlueprintOperators.MAX_OPERANDS:
			errors.append("Block #%s: invalid number of operands." % block["id"])
			return errors
	var count := operand_count(block)
	for index: int in range(XREBlueprintOperators.MIN_OPERANDS, XREBlueprintOperators.OPERAND_KEYS.size()):
		var key: String = XREBlueprintOperators.OPERAND_KEYS[index]
		if not params.has(key): continue
		if index >= count: errors.append("Block #%s: %s is past its operands." % [block["id"], key])
		elif not is_literal(params[key]): errors.append("Block #%s: invalid %s." % [block["id"], key])
	return errors


## A Break's or a Make's struct (D-139): a type, a class, fields with names and
## types, the names it hides; its literals.
static func _validate_struct(block: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	var struct: Variant = block.get("struct", {})
	if not struct is Dictionary or not block.get("hidden", []) is Array:
		errors.append("Block #%s has an invalid struct." % block["id"])
		return errors
	var shape := struct as Dictionary
	if shape.is_empty(): return errors
	if not shape.get("type") is int or not shape.get("class", "") is String or not shape.get("fields") is Array:
		errors.append("Block #%s has an invalid struct." % block["id"])
		return errors
	for field: Variant in shape["fields"]:
		if not field is Dictionary or not (field as Dictionary).get("name") is String or not (field as Dictionary).get("type") is int:
			errors.append("Block #%s has an invalid field." % block["id"])
			return errors
	var params: Dictionary = block["params"]
	for key: String in params:
		if not is_literal(params[key]): errors.append("Block #%s: invalid %s." % [block["id"], key])
	return errors


## A Sequence's count of outputs and a Switch's of cases, from two to eight,
## and a Switch's kind and its cases' values of its type, none past the count (D-138).
static func _validate_pins(block: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	var params: Dictionary = block["params"]
	var key := "outputs" if block["kind"] == "sequence" else "cases"
	if not params.get(key) is int or int(params[key]) < MIN_PINS or int(params[key]) > MAX_PINS:
		errors.append("Block #%s: invalid number of %s." % [block["id"], key])
		return errors
	if block["kind"] == "sequence": return errors
	var on := str(params.get("on", ""))
	if not on in ["int", "string", "enum"]:
		errors.append("Block #%s: a Switch is on int, string or enum." % block["id"])
		return errors
	var constants := enum_constants(str(params.get("enum", ""))) if on == "enum" else {}
	if on == "enum" and constants.is_empty():
		errors.append("Block #%s: unknown enumeration %s." % [block["id"], params.get("enum", "")])
	var type := TYPE_INT if on == "int" else TYPE_STRING
	for index: int in MAX_PINS:
		var value: Variant = params.get(case_key(index))
		if index < int(params[key]) and typeof(value) != type: errors.append("Block #%s: case %d must be %s." % [block["id"], index, type_string(type)])
		elif index < int(params[key]) and on == "enum" and not constants.is_empty() and not constants.has(value): errors.append("Block #%s: %s is no constant of %s." % [block["id"], value, params["enum"]])
		elif index >= int(params[key]) and params.has(case_key(index)): errors.append("Block #%s: case %d is past its cases." % [block["id"], index])
	return errors


## The function of a call block and its parameters: one per argument with a value.
func _validate_call(block: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	var id: int = block["id"]
	var function: Variant = block.get("function")
	if not function is Dictionary or not (function as Dictionary).get("args") is Array or not (function as Dictionary).get("name") is String \
			or str((function as Dictionary)["name"]).is_empty() or not (function as Dictionary).get("scope") in ["method", "static", "global", "local"]:
		errors.append("Block #%d has an invalid function." % id)
		return errors
	var signature := function as Dictionary
	if signature["scope"] == "local":
		var own := find_function(str(signature["name"]))
		if own.is_empty():
			errors.append("Block #%d: there is no function %s." % [id, signature["name"]])
			return errors
		if not XREBlueprintUserFunctions.matches(signature, own):
			errors.append("Block #%d: the call of %s is out of date." % [id, signature["name"]])
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
