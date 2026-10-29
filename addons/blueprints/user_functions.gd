@tool
class_name XREBlueprintUserFunctions
extends RefCounted
## A graph's own functions (format 4, docs/blueprint_functions.md). A function
## is a Dictionary in [member XREBlueprintGraph.functions]:
## [code]name[/code], [code]pure[/code], [code]inputs[/code] and
## [code]outputs[/code] (pins: [code]{"key": name, "type": Variant type}[/code],
## or [code]{"key": name, "exec": true}[/code] for execution, which only a
## function that isn't pure has; no type until its first wire gives one), [code]nodes[/code] and
## [code]edges[/code] of its body, from its Entry to its Returns, and
## [code]vr_center[/code].
##
## A call is a [code]call[/code] block whose function's scope is "local"
## ([method call_signature]): its inputs are the function's inputs, its
## outputs the function's outputs. Calls keep a copy of the signature, as
## every call does; [method sync] brings them and the body's Entry and Return
## up to date after an edit, their wires following their pins by key, as a
## Sequence's do (D-136).

## Most functions a graph has and pins a side of one has.
const MAX_FUNCTIONS := 32
const MAX_PINS := 8
## Deepest nesting of function calls in the game.
const MAX_DEPTH := 64
## Names a pin can't take: parameters a block keeps for itself.
const RESERVED: Array[String] = XREBlueprintFunctions.RESERVED_KEYS


## A new function: an empty body with its Entry and Return, joined unless it is pure.
static func make(name: String, pure: bool) -> Dictionary:
	var edges: Array[Dictionary] = []
	if not pure: edges.append({"from": 1, "from_port": 0, "to": 2, "to_port": 0})
	return {"name": name, "pure": pure, "inputs": [], "outputs": [], "nodes": [XREBlueprintGraph.make_node(1, "entry", Vector2(80, 100)),
			XREBlueprintGraph.make_node(2, "return", Vector2(440, 100))], "edges": edges, "vr_center": Vector2(260, 100)}


## The first name of [param prefix] followed by a number that none of [param taken] has.
static func free_name(prefix: String, taken: Array) -> String:
	var index := 1
	while taken.has("%s%d" % [prefix, index]): index += 1
	return "%s%d" % [prefix, index]


## The names of the functions of root state or graph functions [param functions].
static func names(functions: Array) -> Array:
	return functions.map(func(entry: Dictionary) -> String: return str(entry.get("name", "")))


## Function [param entry] without its body: what its calls and its Entry and Return show.
static func signature_of(entry: Dictionary) -> Dictionary:
	var result := entry.duplicate(true)
	result.erase("nodes")
	result.erase("edges")
	result.erase("vr_center")
	return result


## Whether [param pin] has a type yet: a value's or execution.
static func is_typed(pin: Dictionary) -> bool:
	return pin.has("type") or is_exec(pin)


## Whether [param pin] is one of execution: another way in or out of the function.
static func is_exec(pin: Dictionary) -> bool:
	return bool(pin.get("exec", false))


## The Variant type of [param pin]; TYPE_NIL, any value, until it has one.
static func pin_type(pin: Dictionary) -> int:
	return int(pin.get("type", TYPE_NIL))


## The port category of [param pin]: any value until it has a type.
static func pin_category(pin: Dictionary) -> int:
	if is_exec(pin): return XREBlueprintGraph.EXEC
	return XREBlueprintGraph.port_type(pin_type(pin)) if is_typed(pin) else XREBlueprintGraph.VALUE


## Whether [param name] may name a pin or a function.
static func valid_name(name: String) -> bool:
	return name.is_valid_identifier() and not name in RESERVED and not name.begins_with("_bp")


## The ports of an Entry or a Return of a body with [param signature]: the
## Entry's Then and the function's inputs as its outputs, the Return's In and
## the function's outputs as its inputs; a pure function's have no Then or
## In. A Return's input keeps a literal under its output's name.
static func body_ports(signature: Dictionary, kind: String, input: bool) -> Array:
	var result: Array = []
	if (kind == "entry") == input: return result
	if not signature.get("pure", false): result.append(["Then" if kind == "entry" else "In", XREBlueprintGraph.EXEC, ""])
	for pin: Dictionary in signature.get("inputs" if kind == "entry" else "outputs", []) as Array:
		var key := str(pin["key"])
		var literal := kind == "return" and not is_exec(pin) and not pin_type(pin) in XREBlueprintFunctions.WIRED_TYPES
		result.append([key, pin_category(pin), key if literal else ""])
	return result


## The signature a call of function [param entry] keeps ([XREBlueprintFunctions]):
## an argument per input of a value, keyed by its name, the names of the inputs
## of execution after In, the outputs as they are; [param awaits] when its body
## waits. A call that isn't pure keeps its result: which way it left too.
static func call_signature(entry: Dictionary, awaits: bool) -> Dictionary:
	var args: Array[Dictionary] = []
	var ways: Array[String] = []
	for pin: Dictionary in entry.get("inputs", []) as Array:
		var key := str(pin["key"])
		if is_exec(pin): ways.append(key)
		else: args.append({"name": key, "label": key, "type": pin_type(pin), "class_name": "", "key": key})
	var name := str(entry.get("name", ""))
	var pure := bool(entry.get("pure", false))
	var outputs := (entry.get("outputs", []) as Array).duplicate(true)
	return {"scope": "local", "class": "", "name": name, "title": name, "category": "Functions", "keywords": "function", "args": args, "exec_inputs": ways,
			"return": TYPE_NIL, "returns": not outputs.is_empty() or not pure, "return_class": "", "pure": pure, "outputs": outputs, "awaits": awaits and not pure,
			"vararg": false, "extra": 0, "then": "Then", "targets": [], "advanced_shown": false}


## Whether call signature [param signature] is that of function [param entry] now.
static func matches(signature: Dictionary, entry: Dictionary) -> bool:
	var expected := call_signature(entry, false)
	for key: String in ["args", "exec_inputs", "outputs", "pure"]:
		if signature.get(key, []) != expected[key]: return false
	return true


## Whether [param block] calls one of the graph's functions, [param name] if given.
static func is_call(block: Dictionary, name: String = "") -> bool:
	if block.get("kind") != "call" or not block.get("function") is Dictionary: return false
	var function: Dictionary = block["function"]
	return function.get("scope") == "local" and (name.is_empty() or function.get("name") == name)


## How many calls of function [param name] root state [param state] has, in its graph and in every body.
static func call_count(state: Dictionary, name: String) -> int:
	var count := 0
	for holder: Dictionary in _holders(state):
		for block: Dictionary in holder["nodes"] as Array:
			if is_call(block, name): count += 1
	return count


## Which functions of root state [param state] wait, by name: a body with a
## call that waits, its own or a library one, as Delay; a pure one never.
static func awaiting(state: Dictionary) -> Dictionary:
	var result := {}
	var functions: Array = state.get("functions", [])
	for entry: Dictionary in functions: result[entry["name"]] = false
	var grew := true
	while grew:
		grew = false
		for entry: Dictionary in functions:
			if result[entry["name"]] or entry.get("pure", false): continue
			for block: Dictionary in entry["nodes"] as Array:
				if block.get("kind") != "call" or not block.get("function") is Dictionary: continue
				var function: Dictionary = block["function"]
				if function.get("pure", false): continue
				if function.get("scope") == "local" and result.get(function.get("name"), false) or function.get("scope") != "local" and function.get("awaits", false):
					result[entry["name"]] = true
					grew = true
					break
	return result


## Brings root state [param state] up to date after an edit of its functions,
## [param before] the state before it: every call's signature and the ports
## of each body's Entry and Return. Wires follow their pins by key, renamed
## by [param renames] — [code]{function: {old key: new key}}[/code], an
## input's key its name, an output's "#" and its name, an empty new key
## taking the wire away —; a function renamed in [param renamed]
## [code]{old: new}[/code] keeps its calls. A literal follows its input;
## [param literals] [code]{function: {input: value}}[/code] gives a typed
## input's the value of the port its first wire came from. With [param drop],
## wires whose ports no longer go together are taken away.
static func sync(state: Dictionary, before: Dictionary, renames: Dictionary = {}, renamed: Dictionary = {}, literals: Dictionary = {}, drop: bool = true) -> void:
	var definitions := {}
	for entry: Dictionary in state["functions"] as Array: definitions[entry["name"]] = entry
	var old_definitions := {}
	for entry: Dictionary in before.get("functions", []) as Array: old_definitions[renamed.get(entry["name"], entry["name"])] = entry
	var awaits := awaiting(state)
	for holder: Dictionary in _holders(state):
		var keys := {}
		for block: Dictionary in holder["nodes"] as Array:
			if not is_call(block): continue
			var old: Dictionary = block["function"]
			var name: String = renamed.get(old["name"], old["name"])
			if not definitions.has(name): continue
			var signature := call_signature(definitions[name], awaits.get(name, false))
			if signature == old: continue
			var moves: Dictionary = renames.get(name, {})
			var before_ports := XREBlueprintFunctions.ports(old, TYPE_NIL)
			var after_ports := XREBlueprintFunctions.ports(signature, TYPE_NIL)
			keys[block["id"]] = [_pin_keys(before_ports[0]), _pin_keys(after_ports[0]), moves, _pin_keys(before_ports[1]), _pin_keys(after_ports[1])]
			block["function"] = signature
			block["params"] = _follow_literals(block["params"], signature["args"], moves, literals.get(name, {}))
		_follow_wires(holder, keys)
	for entry: Dictionary in state["functions"] as Array:
		var name: String = entry["name"]
		if not old_definitions.has(name): continue
		var old := signature_of(old_definitions[name])
		var now := signature_of(entry)
		if old == now: continue
		var moves: Dictionary = renames.get(name, {})
		var keys := {}
		for block: Dictionary in entry["nodes"] as Array:
			var kind := str(block.get("kind", ""))
			if not kind in ["entry", "return"]: continue
			keys[block["id"]] = [_pin_keys(body_ports(old, kind, true)), _pin_keys(body_ports(now, kind, true)), moves,
					_pin_keys(body_ports(old, kind, false)), _pin_keys(body_ports(now, kind, false))]
			if kind == "return": block["params"] = _return_literals(block["params"], now, moves)
		_follow_wires(entry, keys)
	if drop: _drop_mismatched(state)


## The first wire of a pin of function [param name]'s Entry or Return in root
## state [param state] — one no wire in [param before], the body's wires
## before the edit, had — gives it the type of the port at its other end,
## when it has none or one that port doesn't take, and the name of that
## port's label while it keeps the one it was added with. Returns what
## [method sync] needs: [code]{"renames": {name: moves}, "literals": {name:
## {input: the value the port had}}, "changed": whether a pin changed}[/code].
static func adopt_pins(state: Dictionary, name: String, before: Array) -> Dictionary:
	var result := {"renames": {}, "literals": {}, "changed": false}
	var index := -1
	for at: int in (state["functions"] as Array).size():
		if state["functions"][at]["name"] == name: index = at
	if index < 0: return result
	var entry: Dictionary = state["functions"][index]
	var root := XREBlueprintGraph.new()
	root.restore(state)
	var view := root.body(name)
	var offset := 0 if entry.get("pure", false) else 1
	var moves := {}
	var given := {}
	for edge: Dictionary in entry["edges"] as Array:
		if before.has(edge): continue
		var source := view.find_node(edge["from"])
		var target := view.find_node(edge["to"])
		if source.is_empty() or target.is_empty(): continue
		if source["kind"] == "entry":
			var pin := int(edge["from_port"]) - offset
			var spec: Array = view.ports(target, true)[edge["to_port"]] if edge["to_port"] < view.ports(target, true).size() else []
			if pin < 0 or pin >= (entry["inputs"] as Array).size() or spec.is_empty() or _wired_before(view, before, true, edge["from_port"]): continue
			# Execution only for a function that isn't pure: a pure one has none.
			if spec[1] == XREBlueprintGraph.EXEC and entry.get("pure", false): continue
			var input: Dictionary = entry["inputs"][pin]
			var key: String = spec[2] if spec.size() > 2 else ""
			# A port that takes any value is of the type of the value it had.
			var category: int = spec[1]
			if category == XREBlueprintGraph.VALUE and (target["params"] as Dictionary).has(key) and XREBlueprintGraph.is_literal(target["params"][key]): category = XREBlueprintGraph.port_type(typeof(target["params"][key]))
			if not _retype(input, category, true): continue
			result["changed"] = true
			_rename(input, str(spec[0]), entry["inputs"], "input_", moves)
			if not key.is_empty() and (target["params"] as Dictionary).has(key): given[input["key"]] = target["params"][key]
		if target["kind"] == "return":
			var pin := int(edge["to_port"]) - offset
			var spec: Array = view.ports(source, false)[edge["from_port"]] if edge["from_port"] < view.ports(source, false).size() else []
			if pin < 0 or pin >= (entry["outputs"] as Array).size() or spec.is_empty() or _wired_before(view, before, false, edge["to_port"]): continue
			if spec[1] == XREBlueprintGraph.EXEC and entry.get("pure", false): continue
			var output: Dictionary = entry["outputs"][pin]
			if not _retype(output, spec[1], false): continue
			result["changed"] = true
			_rename(output, str(spec[0]), entry["outputs"], "output_", moves)
	if result["changed"]:
		result["renames"] = {name: moves}
		result["literals"] = {name: given}
	return result


## Whether [param before], a body's wires, had one from its Entry's output
## [param port], or into input [param port] of any of its Returns.
static func _wired_before(view: XREBlueprintGraph, before: Array, entry: bool, port: int) -> bool:
	for edge: Dictionary in before:
		var block := view.find_node(edge["to"] if not entry else edge["from"])
		if entry and block.get("kind") == "entry" and edge["from_port"] == port: return true
		if not entry and block.get("kind") == "return" and edge["to_port"] == port: return true
	return false


## Gives [param pin] the type of port category [param category] at the other
## end of its wire, an Entry's ([param from_entry]) going into it, a Return's
## coming from it: when it has no type, or one the wire can't carry.
static func _retype(pin: Dictionary, category: int, from_entry: bool) -> bool:
	if is_typed(pin):
		var own := pin_category(pin)
		if XREBlueprintGraph.ports_compatible(own, category) if from_entry else XREBlueprintGraph.ports_compatible(category, own): return false
	# A wire of execution makes it a way in or out of the function.
	if category == XREBlueprintGraph.EXEC:
		pin.erase("type")
		pin["exec"] = true
		return true
	pin.erase("exec")
	pin["type"] = XREBlueprintGraph.variant_type(category)
	return true


## Names [param pin] after [param label], the port its first wire came from or
## went to, while it keeps the name [param prefix] gave it and the new one is
## free among [param pins]; [param moves] gets the rename.
static func _rename(pin: Dictionary, label: String, pins: Array, prefix: String, moves: Dictionary) -> void:
	var old := str(pin["key"])
	var number := old.trim_prefix(prefix)
	if not old.begins_with(prefix) or not number.is_valid_int(): return
	var key := label.to_snake_case()
	if not valid_name(key) or names_of(pins).has(key): return
	pin["key"] = key
	moves[old] = key
	moves["#" + old] = "#" + key


## The keys of [param pins].
static func names_of(pins: Array) -> Array:
	return pins.map(func(pin: Dictionary) -> String: return str(pin.get("key", "")))


## How many calls of function [param name] [param graph], a file's graph, has, in it and in its functions' bodies.
static func count_calls(graph: XREBlueprintGraph, name: String) -> int:
	var count := 0
	for block: Dictionary in graph.nodes:
		if is_call(block, name): count += 1
	for entry: Dictionary in graph.functions:
		for block: Dictionary in entry["nodes"] as Array:
			if is_call(block, name): count += 1
	return count


## Root state [param state]'s graph and each function's body: what holds blocks and wires.
static func _holders(state: Dictionary) -> Array[Dictionary]:
	var holders: Array[Dictionary] = [state]
	for entry: Dictionary in state.get("functions", []) as Array: holders.append(entry)
	return holders


## Each port's key ([method XREBlueprintDocument.reshape_pins]): its parameter, else "#" and its label.
static func _pin_keys(ports: Array) -> Array[String]:
	var keys: Array[String] = []
	for spec: Array in ports:
		var key: String = spec[2] if spec.size() > 2 else ""
		keys.append(key if not key.is_empty() else "#" + str(spec[0]))
	return keys


## Where pin [param port] of keys [param before] is among [param after], renamed by [param moves]; -1 when gone.
static func _follow(port: int, before: Array[String], after: Array[String], moves: Dictionary) -> int:
	if port < 0 or port >= before.size(): return -1
	var key: String = moves.get(before[port], before[port])
	if key.is_empty(): return -1
	# A pin that became one of execution, or one of a value, is keyed by its label now, or by its name.
	var found := after.find(key)
	return found if found >= 0 else after.find(key.trim_prefix("#") if key.begins_with("#") else "#" + key)


## The wires of [param holder] after the blocks of [param keys] changed their
## pins: [code]{id: [inputs before, inputs after, moves, outputs before, outputs after]}[/code].
static func _follow_wires(holder: Dictionary, keys: Dictionary) -> void:
	if keys.is_empty(): return
	var kept: Array[Dictionary] = []
	for edge: Dictionary in holder["edges"] as Array:
		if keys.has(edge["to"]):
			var change: Array = keys[edge["to"]]
			var inputs_before: Array[String] = change[0]
			var inputs_after: Array[String] = change[1]
			edge["to_port"] = _follow(int(edge["to_port"]), inputs_before, inputs_after, change[2])
			if edge["to_port"] < 0: continue
		if keys.has(edge["from"]):
			var change: Array = keys[edge["from"]]
			var outputs_before: Array[String] = change[3]
			var outputs_after: Array[String] = change[4]
			edge["from_port"] = _follow(int(edge["from_port"]), outputs_before, outputs_after, change[2])
			if edge["from_port"] < 0: continue
		kept.append(edge)
	holder["edges"] = kept


## A call's literals after its inputs changed: each kept, renamed, value of
## an input its first wire typed from [param given], else the input's start value.
static func _follow_literals(params: Dictionary, args: Array, moves: Dictionary, given: Dictionary) -> Dictionary:
	var result := {}
	var back := {}
	for key: String in moves: back[moves[key]] = key
	for argument: Dictionary in args:
		if not XREBlueprintFunctions.has_literal(argument): continue
		var key := str(argument["key"])
		var old: String = back.get(key, key)
		if given.has(key) and XREBlueprintGraph.is_literal(given[key]): result[key] = given[key]
		elif params.has(old) and XREBlueprintSchema.accepts(int(argument["type"]), typeof(params[old])): result[key] = params[old]
		else: result[key] = XREBlueprintFunctions.initial_value(argument)
	return result


## A Return's literals after its function's outputs changed: kept by key when
## of their type, else the type's default; none for an output without a type.
static func _return_literals(params: Dictionary, signature: Dictionary, moves: Dictionary) -> Dictionary:
	var result := {}
	var back := {}
	for key: String in moves: back[moves[key]] = key
	for pin: Dictionary in signature.get("outputs", []) as Array:
		if not is_typed(pin) or is_exec(pin) or pin_type(pin) in XREBlueprintFunctions.WIRED_TYPES: continue
		var key := str(pin["key"])
		var old: String = back.get(key, key)
		if params.has(old) and XREBlueprintSchema.accepts(pin_type(pin), typeof(params[old])): result[key] = params[old]
		elif XREBlueprintSchema.default_value(pin_type(pin)) != null: result[key] = XREBlueprintSchema.default_value(pin_type(pin))
	return result


## Takes away every wire of [param state] whose ports no longer exist or go together.
static func _drop_mismatched(state: Dictionary) -> void:
	var root := XREBlueprintGraph.new()
	root.restore(state)
	_drop_in(root, state)
	for entry: Dictionary in state["functions"] as Array: _drop_in(root.body(str(entry["name"])), entry)


static func _drop_in(graph: XREBlueprintGraph, holder: Dictionary) -> void:
	var kept: Array[Dictionary] = []
	for edge: Dictionary in holder["edges"] as Array:
		var source := graph.find_node(edge["from"])
		var target := graph.find_node(edge["to"])
		if source.is_empty() or target.is_empty(): continue
		var outputs := graph.ports(source, false)
		var inputs := graph.ports(target, true)
		var from: int = edge["from_port"]
		var to: int = edge["to_port"]
		if from < 0 or from >= outputs.size() or to < 0 or to >= inputs.size(): continue
		if not XREBlueprintGraph.ports_compatible(outputs[from][1], inputs[to][1]): continue
		kept.append(edge)
	holder["edges"] = kept


## What is wrong with the functions of [param graph], a file's graph: their
## names, pins and bodies, each body checked as a graph.
static func validate(graph: XREBlueprintGraph) -> PackedStringArray:
	var errors := PackedStringArray()
	if graph.functions.size() > MAX_FUNCTIONS: errors.append("A graph can have at most %d functions." % MAX_FUNCTIONS)
	var seen := {}
	for entry: Dictionary in graph.functions:
		var name := str(entry.get("name", ""))
		if not entry.get("name") is String or not valid_name(name) or seen.has(name):
			errors.append("Functions need unique names that are identifiers: %s." % name)
			continue
		seen[name] = true
		if not entry.get("pure") is bool or not entry.get("inputs") is Array or not entry.get("outputs") is Array or not entry.get("nodes") is Array or not entry.get("edges") is Array:
			errors.append("Function %s is invalid." % name)
			continue
		var pins := PackedStringArray()
		for side: String in ["inputs", "outputs"]: pins.append_array(_validate_pins(name, side, entry[side]))
		if entry["pure"] and pins.is_empty() and ((entry["inputs"] as Array) + (entry["outputs"] as Array)).any(XREBlueprintUserFunctions.is_exec):
			pins.append("Function %s is pure: it has no pins of execution." % name)
		errors.append_array(pins)
		if not pins.is_empty(): continue
		var view := graph.body(name)
		for error: String in view.validate(): errors.append("Function %s: %s" % [name, error])
	return errors


## The pins of one side of function [param name]: unique names, types.
static func _validate_pins(name: String, side: String, pins: Array) -> PackedStringArray:
	var errors := PackedStringArray()
	if pins.size() > MAX_PINS: errors.append("Function %s has more than %d %s." % [name, MAX_PINS, side])
	var keys := {}
	for pin: Variant in pins:
		if not pin is Dictionary or not (pin as Dictionary).get("key") is String:
			errors.append("Function %s has an invalid pin." % name)
			continue
		var key := str((pin as Dictionary)["key"])
		if not valid_name(key) or keys.has(key): errors.append("Function %s: %s need unique names that are identifiers: %s." % [name, side, key])
		keys[key] = true
		var type: Variant = (pin as Dictionary).get("type", TYPE_NIL)
		if not type is int or int(type) < TYPE_NIL or int(type) >= TYPE_MAX or (pin as Dictionary).has("exec") and not (pin as Dictionary)["exec"] is bool:
			errors.append("Function %s: %s has an invalid type." % [name, key])
	return errors


## What is wrong with body [param graph] as a whole: one Entry, and one
## Return for a pure function.
static func validate_body(graph: XREBlueprintGraph) -> PackedStringArray:
	var errors := PackedStringArray()
	var entries := 0
	var returns := 0
	for block: Dictionary in graph.nodes:
		if block.get("kind") == "entry": entries += 1
		if block.get("kind") == "return": returns += 1
	if entries != 1: errors.append("A function's body has one Entry.")
	if graph.function_signature.get("pure", false) and returns != 1: errors.append("A pure function has one Return.")
	return errors


## What keeps the functions of [param graph] from building: a pin without a
## type, a pure function that reads itself — through other pure functions
## too —, which would never end.
static func validate_program(graph: XREBlueprintGraph) -> PackedStringArray:
	var errors := PackedStringArray()
	var reads := {}
	for entry: Dictionary in graph.functions:
		for side: String in ["inputs", "outputs"]:
			for pin: Dictionary in entry[side] as Array:
				if not is_typed(pin): errors.append("Function %s: %s has no type: wire it to give it one." % [entry["name"], pin["key"]])
		if not entry.get("pure", false): continue
		var called: Array = []
		for block: Dictionary in entry["nodes"] as Array:
			if is_call(block) and (block["function"] as Dictionary).get("pure", false): called.append((block["function"] as Dictionary)["name"])
		reads[entry["name"]] = called
	for name: String in reads:
		var pending: Array = (reads[name] as Array).duplicate()
		var seen := {}
		while not pending.is_empty():
			var next: String = pending.pop_back()
			if next == name:
				errors.append("Pure function %s reads itself: it would never end." % name)
				break
			if seen.has(next): continue
			seen[next] = true
			pending.append_array(reads.get(next, []))
	return errors
