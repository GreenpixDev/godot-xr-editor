@tool
class_name XREBlueprintDocument
extends RefCounted
## Standalone graph document and the only bridge to scene/editor mutations (D-021).

signal changed
## The graph the views show changed to a function's body, [param name], or back
## to the file's graph, an empty name ([method open_function]).
signal body_opened(name: String)
## Compatible telemetry boundary for the future XR view of this graph.
signal operation_recorded(operation: StringName, source: StringName, time_usec: int)

const RECOVERY_PATH := "user://blueprints_unsaved.tres"

static var _editor_document: XREBlueprintDocument
static var _editor_clients := 0

## The input view scopes this value with perform(); automatic refreshes do not record operations.
var operation_source: StringName = &"desktop_graph"
## Called with every state [method commit] records, before it is checked, to
## add to the same edit: the headset makes each new reference a link with it
## (D-077). Empty for none.
var amend := Callable()

## The graph the views show and edit: the file's, [member root], or one of its
## functions' bodies ([method open_function]), whose edits go into the file's.
var graph := XREBlueprintGraph.new()
## The file's graph, with its functions; one history covers all of it.
var root := graph
## The function whose body [member graph] is, empty for the file's graph.
var opened := ""
var path := ""
var history := UndoRedo.new()
var last_error := ""
var _saved_state: Dictionary = {}
var _root_ref: WeakRef
var _active_root_ref: WeakRef
var _context_assigned := false
var _host_ref: WeakRef
var _host_bound_path := NodePath(".")
var _targets: Dictionary[int, WeakRef] = {}
var _bound_paths: Dictionary[int, String] = {}


## One editor document shared by desktop and XR views; the core has no XR dependency.
static func editor_shared() -> XREBlueprintDocument:
	if _editor_document == null:
		_editor_document = XREBlueprintDocument.new()
	return _editor_document


## Retains the shared document for a plugin/view lifecycle.
static func retain_editor_shared() -> XREBlueprintDocument:
	_editor_clients += 1
	return editor_shared()


## Releases the static root so UndoRedo is disposed before editor shutdown.
static func release_editor_shared() -> void:
	_editor_clients = maxi(_editor_clients - 1, 0)
	if _editor_clients == 0: _editor_document = null


## Executes an input command with its telemetry source and restores the caller's scope.
func perform(action: Callable, source: StringName) -> Variant:
	var previous := operation_source
	operation_source = source
	var result: Variant = action.call()
	operation_source = previous
	return result


func _init() -> void:
	history.max_steps = 100
	graph.changed.connect(changed.emit)
	new_graph()


func _notification(what: int) -> void:
	# UndoRedo inherits Object, not RefCounted.
	if what == NOTIFICATION_PREDELETE and is_instance_valid(history):
		history.free()


## Starts an empty document. The view must resolve unsaved edits before calling.
func new_graph() -> void:
	_show("")
	history.clear_history()
	graph.format_version = XREBlueprintGraph.FORMAT_VERSION
	path = ""
	_host_ref = null
	_targets.clear()
	_bound_paths.clear()
	graph.restore({"nodes": [XREBlueprintGraph.make_node(1, "ready", Vector2(80, 100))], "edges": []})
	_root_ref = null
	_context_assigned = false
	_bind_owner(_active_scene())
	_saved_state = graph.snapshot()
	changed.emit()


## Opens a separate resource instance so discarded edits never alter the loader cache.
func open_graph(file_path: String) -> bool:
	var previous_root := _owning_scene()
	var loaded := ResourceLoader.load(file_path, "", ResourceLoader.CACHE_MODE_IGNORE) as XREBlueprintGraph
	if loaded == null:
		return _fail("This resource is not a Blueprint graph.")
	loaded.upgrade()
	var errors := loaded.validate()
	if not errors.is_empty():
		return _fail("\n".join(errors))
	_show("")
	history.clear_history()
	graph.format_version = loaded.format_version
	path = file_path
	graph.restore(loaded.snapshot())
	_saved_state = graph.snapshot()
	_host_ref = null
	_targets.clear()
	_bound_paths.clear()
	_select_graph_context(previous_root)
	refresh_bindings()
	refresh_structs()
	changed.emit()
	_record(&"open_graph")
	return true


## True after an edit that has not been saved, including after undoing a saved edit.
func is_dirty() -> bool:
	return root.snapshot() != _saved_state


## Takes the graph as it is now for saved, its history starting here: a new
## graph opened for a selected object in the headset is written only once it
## is changed (D-063).
func mark_saved() -> void:
	history.clear_history()
	_saved_state = root.snapshot()


## Saves the source even when it is incomplete. Compilation is a separate operation.
func save_graph(file_path: String) -> bool:
	if not file_path.begins_with("res://") or file_path.get_extension() != "tres":
		return _fail("Save the graph as a .tres file inside the project.")
	var error := ResourceSaver.save(root, file_path)
	if error != OK:
		return _fail("Could not save graph: %s." % error_string(error))
	path = file_path
	_saved_state = root.snapshot()
	if Engine.is_editor_hint(): EditorInterface.get_resource_filesystem().update_file(file_path)
	changed.emit()
	_record(&"save_graph")
	return true


## Preserves unnamed work when the editor's Save All / Save and Quit cannot show a file picker.
func save_recovery(recovery_path: String = RECOVERY_PATH) -> bool:
	var error := ResourceSaver.save(root, recovery_path)
	if error != OK:
		return _fail("Could not save the unnamed graph: %s." % error_string(error))
	return true


## Restores a saved unnamed draft as dirty work, ready for Save As.
func recover(recovery_path: String = RECOVERY_PATH) -> bool:
	if not FileAccess.file_exists(recovery_path):
		return false
	var draft := ResourceLoader.load(recovery_path, "", ResourceLoader.CACHE_MODE_IGNORE) as XREBlueprintGraph
	if draft == null:
		return false
	draft.upgrade()
	if not draft.validate().is_empty(): return false
	_show("")
	history.clear_history()
	path = ""
	_saved_state = {}
	graph.restore(draft.snapshot())
	_select_graph_context(_owning_scene())
	changed.emit()
	return true


## Removes a draft after an explicit save or discard.
func clear_recovery(recovery_path: String = RECOVERY_PATH) -> void:
	if FileAccess.file_exists(recovery_path):
		DirAccess.remove_absolute(recovery_path)


## Generated files always sit beside their source and never replace handwritten scripts.
func script_path() -> String:
	return path.get_basename() + ".generated.gd" if not path.is_empty() else ""


## Saves the graph and compiles its runtime script. Old output survives validation errors.
func build() -> bool:
	last_error = ""
	if path.is_empty():
		return _fail("Save the graph before building it.")
	refresh_bindings()
	refresh_structs()
	var scene_errors := validate_scene()
	if not scene_errors.is_empty(): return _fail("\n".join(scene_errors))
	var result := XREBlueprintCompiler.compile(root)
	var errors: PackedStringArray = result["errors"]
	if not errors.is_empty():
		return _fail("\n".join(errors))
	var output := script_path()
	if FileAccess.file_exists(output) and not FileAccess.get_file_as_string(output).begins_with(XREBlueprintCompiler.HEADER):
		return _fail("Refusing to overwrite a handwritten script: %s." % output)
	# The engine is the final syntax/type checker before touching an existing output.
	var script := GDScript.new()
	script.source_code = result["code"]
	if script.reload() != OK:
		return _fail("Generated script failed to compile. See Output for details.")
	if not save_graph(path):
		return false
	var file := FileAccess.open(output, FileAccess.WRITE)
	if file == null:
		return _fail("Could not write script: %s." % error_string(FileAccess.get_open_error()))
	file.store_string(result["code"])
	var error := file.get_error()
	file.close()
	if error != OK:
		return _fail("Could not finish writing script: %s." % error_string(error))
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().update_file(output)
	_record(&"build_graph")
	return true


## Adds one block of a native kind or a preset ([constant XREBlueprintGraph.PRESETS]) through undo history.
func add_block(kind: String, position: Vector2) -> void:
	var block := XREBlueprintGraph.make_node(0, kind, position)
	if block.is_empty():
		return
	insert_block(block, position)


## The ID a new block gets.
func next_id() -> int:
	var id := 1
	for block: Dictionary in graph.nodes:
		id = maxi(id, block["id"] + 1)
	return id


## Adds [param block] (a native block or a call, [XREBlueprintActions]) at
## [param position] and, with [param wire], connects it as one undo step:
## [code]{"from": id, "from_port": port}[/code] wires that output to the new
## block's first compatible input, [code]{"to": id, "to_port": port}[/code]
## its first compatible output to that input. A [param target] node of the
## scene becomes its Target and is followed through renames. [param variables]
## are new graph variables added in the same step, for a block that reads one
## (D-078). Returns the new block's ID, or -1 if the edit was refused.
func insert_block(block: Dictionary, position: Vector2, wire: Dictionary = {}, target: Node = null, title: String = "Add Block", variables: Array[Dictionary] = []) -> int:
	var state := graph.snapshot()
	(state["variables"] as Array).append_array(variables)
	var id := next_id()
	var added := block.duplicate(true)
	added["id"] = id
	added["position"] = position
	# A variable block without its variable takes the first one.
	if added["kind"] in ["get_variable", "set_variable"] and str((added["params"] as Dictionary).get("variable", "")).is_empty() and not graph.variables.is_empty():
		added["params"]["variable"] = graph.variables[0]["name"]
		if added["kind"] == "set_variable": added["params"]["value"] = graph.variables[0].get("value", XREBlueprintSchema.default_value(XREBlueprintGraph.variable_type(graph.variables[0])))
	var host := get_host()
	if target != null and host != null and XREBlueprintGraph.has_target(added):
		added["params"]["target"] = str(host.get_path_to(target))
	_reflect(added, host, true)
	(state["nodes"] as Array).append(added)
	if not wire.is_empty():
		var edge := connection_for(state, added, wire)
		if edge.is_empty(): return _fail_id("The new block has no free port for this wire.")
		(state["edges"] as Array).append(edge)
	if not commit(title, state): return -1
	if target != null and target != host and host != null and XREBlueprintGraph.has_target(added):
		_targets[id] = weakref(target)
		_bound_paths[id] = str(host.get_path_to(target))
	return id


## Adds copies of [param blocks] and of the wires [param edges] between them,
## as one undo step [param title] (D-122): each copy gets a new ID, its
## position moved by [param offset] and its [code]vr_depth[/code] by
## [param depth]; a wire with an end outside [param blocks] is left out, and a
## Target keeps its path. Returns the copies' IDs in the order of
## [param blocks], or none if the edit was refused. [param outer] are wires
## into [param blocks] from blocks not copied (D-126): each copy's input gets
## one from the same output. Of [param variables], those the graph has no
## variable of the name of are added in the same step (D-128).
func paste_blocks(blocks: Array[Dictionary], edges: Array[Dictionary], offset: Vector2, depth: float, title: String = "Paste Blocks", outer: Array[Dictionary] = [], variables: Array[Dictionary] = []) -> Array[int]:
	var state := graph.snapshot()
	for variable: Dictionary in variables:
		if graph.find_variable(str(variable["name"])).is_empty(): (state["variables"] as Array).append(variable.duplicate(true))
	var copies: Dictionary[int, int] = {}
	var ids: Array[int] = []
	var id := next_id()
	for block: Dictionary in blocks:
		var added := block.duplicate(true)
		copies[int(block["id"])] = id
		added["id"] = id
		added["position"] = (block["position"] as Vector2) + offset
		added["vr_depth"] = float(block.get("vr_depth", 0.0)) + depth
		(state["nodes"] as Array).append(added)
		ids.append(id)
		id += 1
	for edge: Dictionary in edges:
		if not copies.has(int(edge["from"])) or not copies.has(int(edge["to"])): continue
		var added := edge.duplicate(true)
		added["from"] = copies[int(edge["from"])]
		added["to"] = copies[int(edge["to"])]
		(state["edges"] as Array).append(added)
	for edge: Dictionary in outer:
		if copies.has(int(edge["from"])) or not copies.has(int(edge["to"])): continue
		var added := edge.duplicate(true)
		added["to"] = copies[int(edge["to"])]
		(state["edges"] as Array).append(added)
	if ids.is_empty() or not commit(title, state): return []
	for original: int in copies:
		if _targets.has(original): _targets[copies[original]] = _targets[original]
	return ids


## The wire that joins [param block], a block of [param state], to the port
## [param wire] names ([method insert_block]): the first of its inputs or
## outputs that is free and of a compatible type; empty if none is. An object
## prefers the Target, any type the same type.
func connection_for(state: Dictionary, block: Dictionary, wire: Dictionary) -> Dictionary:
	var candidate := XREBlueprintGraph.new()
	candidate.restore(state)
	var other := candidate.find_node(int(wire.get("from", wire.get("to", -1))))
	if other.is_empty() or candidate.find_node(block["id"]).is_empty():
		return {}
	var output := wire.has("from")
	var port: int = wire.get("from_port", wire.get("to_port", -1))
	var others := candidate.ports(other, not output)
	if port < 0 or port >= others.size(): return {}
	var type: int = others[port][1]
	var mine := candidate.ports(block, output)
	var best := -1
	for index: int in mine.size():
		var spec: Array = mine[index]
		var fits := XREBlueprintGraph.ports_compatible(type, spec[1]) if output else XREBlueprintGraph.ports_compatible(spec[1], type)
		if not fits: continue
		var edge := {"from": other["id"], "from_port": port, "to": block["id"], "to_port": index} if output else {"from": block["id"], "from_port": index, "to": other["id"], "to_port": port}
		if _occupied(candidate, edge, type): continue
		var exact: bool = spec[1] == type and (type != XREBlueprintGraph.OBJECT or not output or index == XREBlueprintGraph.target_port(block))
		if exact: return edge
		if best < 0: best = index
	if best < 0: return {}
	return {"from": other["id"], "from_port": port, "to": block["id"], "to_port": best} if output else {"from": block["id"], "from_port": best, "to": other["id"], "to_port": port}


## Whether [param edge] would take an end that holds one wire only: an execution output or a data input.
static func _occupied(candidate: XREBlueprintGraph, edge: Dictionary, type: int) -> bool:
	for existing: Dictionary in candidate.edges:
		if type == XREBlueprintGraph.EXEC and existing["from"] == edge["from"] and existing["from_port"] == edge["from_port"]: return true
		if type != XREBlueprintGraph.EXEC and existing["to"] == edge["to"] and existing["to_port"] == edge["to_port"]: return true
	return false


## Shows or hides the advanced arguments of call block [param id]; they can't hide while wired.
func set_advanced_shown(id: int, shown: bool) -> bool:
	var block := graph.find_node(id)
	if block.is_empty() or block["kind"] != "call": return false
	var state := graph.snapshot()
	for entry: Dictionary in state["nodes"]:
		if entry["id"] == id: entry["function"]["advanced_shown"] = shown
	if not shown:
		var first := graph.ports(block, true).size() - _advanced_count(block)
		for edge: Dictionary in graph.edges:
			if edge["to"] == id and edge["to_port"] >= first: return _fail("Disconnect the advanced arguments first.")
	return commit("Show Advanced" if shown else "Hide Advanced", state)


## Sets how many extra arguments vararg call block [param id] takes; a wired one can't be removed.
func set_extra_arguments(id: int, count: int) -> bool:
	var block := graph.find_node(id)
	if block.is_empty() or block["kind"] != "call" or not (block["function"] as Dictionary).get("vararg", false): return false
	var current := int((block["function"] as Dictionary).get("extra", 0))
	if count < 0 or count > XREBlueprintFunctions.MAX_EXTRA: return _fail("A call takes at most %d extra arguments." % XREBlueprintFunctions.MAX_EXTRA)
	var state := graph.snapshot()
	for entry: Dictionary in state["nodes"]:
		if entry["id"] != id: continue
		entry["function"]["extra"] = count
		for index: int in range(current, count): entry["params"][XREBlueprintFunctions.extra_key(index)] = ""
		for index: int in range(count, current):
			var port := graph.input_port(block, XREBlueprintFunctions.extra_key(index))
			for edge: Dictionary in graph.edges:
				if edge["to"] == id and edge["to_port"] == port: return _fail("Disconnect the argument first.")
			(entry["params"] as Dictionary).erase(XREBlueprintFunctions.extra_key(index))
	return commit("Set Arguments", state)


## Changes the pins of block [param id] as one edit [param title] (D-136):
## [param change] edits the block's copy in place, then every wire of the
## block follows its pin by key — an input by the parameter it falls back to,
## any other pin by its label — so that its port number may move. A key in
## [param renames] is the pin's new key; an empty one, or a key the block no
## longer has, takes the wire away in the same edit.
func reshape_pins(id: int, change: Callable, renames: Dictionary = {}, title: String = "Change Pins") -> bool:
	var block := graph.find_node(id)
	if block.is_empty(): return _fail("The block is missing.")
	var state := graph.snapshot()
	var changed: Dictionary = {}
	for entry: Dictionary in state["nodes"]:
		if entry["id"] != id: continue
		change.call(entry)
		changed = entry
	var candidate := XREBlueprintGraph.new()
	candidate.restore(state)
	var inputs := [_pin_keys(graph.ports(block, true)), _pin_keys(candidate.ports(changed, true))]
	var outputs := [_pin_keys(graph.ports(block, false)), _pin_keys(candidate.ports(changed, false))]
	var kept: Array = []
	for edge: Dictionary in state["edges"]:
		if edge["to"] == id:
			edge["to_port"] = _follow_pin(int(edge["to_port"]), inputs[0], inputs[1], renames)
			if edge["to_port"] < 0: continue
		if edge["from"] == id:
			edge["from_port"] = _follow_pin(int(edge["from_port"]), outputs[0], outputs[1], renames)
			if edge["from_port"] < 0: continue
		kept.append(edge)
	state["edges"] = kept
	return commit(title, state)


## The key of each pin of [param ports] ([method reshape_pins]): the parameter
## it falls back to, else its label after "#".
static func _pin_keys(ports: Array) -> Array[String]:
	var keys: Array[String] = []
	for spec: Array in ports:
		var key: String = spec[2] if spec.size() > 2 else ""
		keys.append(key if not key.is_empty() else "#" + str(spec[0]))
	return keys


## Where pin [param port] of keys [param before] is among [param after],
## renamed by [param renames]; -1 when it is gone.
static func _follow_pin(port: int, before: Array[String], after: Array[String], renames: Dictionary) -> int:
	if port < 0 or port >= before.size(): return -1
	var key: String = renames.get(before[port], before[port])
	return after.find(key) if not key.is_empty() else -1


## Adds a pin after the last of block [param id]'s pins that change
## ([method XREBlueprintGraph.variable_pins]): an operator's input, a
## Sequence's output, a Switch's case before Default (D-138). One edit.
func add_pin(id: int) -> bool:
	var block := graph.find_node(id)
	var pins := graph.pins_of(block)
	if pins.is_empty(): return _fail("This block's pins are fixed.")
	if not pins["can_add"]: return _fail("This block takes no more pins.")
	match str(block["kind"]):
		# A body's Entry adds an input of its function, its Return an output.
		"entry", "return": return not add_function_pin(opened, block["kind"] == "entry").is_empty()
		"operator": return add_operand(id)
		"sequence":
			var count := XREBlueprintGraph.pin_count(block)
			var grow := func(entry: Dictionary) -> void: entry["params"]["outputs"] = count + 1
			return reshape_pins(id, grow, {}, "Add Pin")
		"switch":
			var count := XREBlueprintGraph.pin_count(block)
			var value: Variant = XREBlueprintGraph.next_case(block)
			var grow := func(entry: Dictionary) -> void:
				entry["params"]["cases"] = count + 1
				entry["params"][XREBlueprintGraph.case_key(count)] = value
			return reshape_pins(id, grow, {}, "Add Pin")
		"make_array":
			# A copy of the last element's literal, of the elements' type (D-141).
			var count := XREBlueprintGraph.collection_count(block)
			var literal: Variant = _new_item(block, "item_", count)
			var grow := func(entry: Dictionary) -> void:
				entry["params"]["count"] = count + 1
				(entry["params"] as Dictionary).erase(XREBlueprintGraph.MADE_TYPE)
				if literal != null: entry["params"]["item_%d" % count] = literal
			return reshape_pins(id, grow, {}, "Add Element")
		"make_dictionary":
			# A key no pair has, of the keys' type, and the last value's literal.
			var pairs := XREBlueprintGraph.collection_count(block)
			var key: Variant = _new_key(block, pairs)
			var value: Variant = _new_item(block, "value_", pairs)
			var grow := func(entry: Dictionary) -> void:
				entry["params"]["pairs"] = pairs + 1
				(entry["params"] as Dictionary).erase(XREBlueprintGraph.MADE_TYPE)
				if key != null: entry["params"]["key_%d" % pairs] = key
				if value != null: entry["params"]["value_%d" % pairs] = value
			return reshape_pins(id, grow, {}, "Add Element")
	return false


## The literal a new element of Make Array or value of Make Dictionary takes
## (D-141): the last one's, else a value of the type of those wired in; null
## for a type only a wire brings.
func _new_item(block: Dictionary, prefix: String, count: int) -> Variant:
	var params: Dictionary = block["params"]
	if params.has(prefix + str(count - 1)): return params[prefix + str(count - 1)]
	var type := XREBlueprintGraph.variant_type(graph.items_category(block, prefix))
	if type == TYPE_NIL: return 0
	return XREBlueprintSchema.default_value(type) if type in XREBlueprintSchema.LITERAL_TYPES else null


## A key of Make Dictionary's keys' type that no pair has (D-141): key_2 for
## text, the largest number + 1, else the type's default.
func _new_key(block: Dictionary, pairs: int) -> Variant:
	var params: Dictionary = block["params"]
	var used: Array = []
	for index: int in pairs: used.append(params.get("key_%d" % index))
	var type := XREBlueprintGraph.variant_type(graph.items_category(block, "key_"))
	match type:
		TYPE_STRING, TYPE_NIL:
			var index := pairs
			while used.has("key_%d" % index): index += 1
			return "key_%d" % index
		TYPE_INT:
			var largest := -1
			for value: Variant in used:
				if value is int: largest = maxi(largest, value)
			return largest + 1
	return XREBlueprintSchema.default_value(type) if type in XREBlueprintSchema.LITERAL_TYPES else null


## Removes pin [param port] — of its side, as [method XREBlueprintGraph.variable_pins]
## says — of block [param id] with its wire (D-138); the pins after it move
## up with their values and wires. At least two stay.
func remove_pin(id: int, port: int) -> bool:
	var block := graph.find_node(id)
	var pins := graph.pins_of(block)
	if pins.is_empty(): return _fail("This block's pins are fixed.")
	var count: int = pins["count"]
	if port < 0 or port >= count: return _fail("The block has no such pin.")
	var fewest: int = pins.get("min", XREBlueprintGraph.MIN_PINS)
	if count <= fewest: return _fail("A block keeps at least %d pins." % fewest)
	match str(block["kind"]):
		"entry", "return":
			var input: bool = block["kind"] == "entry"
			var key := str((graph.function_signature["inputs" if input else "outputs"] as Array)[port]["key"])
			return remove_function_pin(opened, input, key)
		"make_array", "make_dictionary":
			# An element, or a pair with both its pins (D-141); those after it move up.
			var pair: bool = block["kind"] == "make_dictionary"
			var index := port / 2 if pair else port
			var total := XREBlueprintGraph.collection_count(block)
			var prefixes: Array[String] = ["item_"]
			if pair: prefixes.assign(["key_", "value_"])
			var renames := {}
			for prefix: String in prefixes:
				renames[prefix + str(index)] = ""
				for after: int in range(index + 1, total): renames[prefix + str(after)] = prefix + str(after - 1)
			# The last one gone, the block keeps the type it made: an empty Array[int] stays one (D-144).
			var made: int = graph.ports(block, false)[0][1]
			var shrink := func(entry: Dictionary) -> void:
				var params: Dictionary = entry["params"]
				if total == 1: params[XREBlueprintGraph.MADE_TYPE] = made
				for prefix: String in prefixes:
					for after: int in range(index, total - 1):
						if params.has(prefix + str(after + 1)): params[prefix + str(after)] = params[prefix + str(after + 1)]
						else: params.erase(prefix + str(after))
					params.erase(prefix + str(total - 1))
				params["pairs" if pair else "count"] = total - 1
			return reshape_pins(id, shrink, renames, "Remove Element")
		"operator": return remove_operand(id, XREBlueprintOperators.OPERAND_KEYS[port])
		"sequence":
			var renames := {"#Then %d" % port: ""}
			for after: int in range(port + 1, count): renames["#Then %d" % after] = "#Then %d" % (after - 1)
			var shrink := func(entry: Dictionary) -> void: entry["params"]["outputs"] = count - 1
			return reshape_pins(id, shrink, renames, "Remove Pin")
		"switch":
			var renames := {XREBlueprintGraph.case_key(port): ""}
			for after: int in range(port + 1, count): renames[XREBlueprintGraph.case_key(after)] = XREBlueprintGraph.case_key(after - 1)
			var shrink := func(entry: Dictionary) -> void:
				var params: Dictionary = entry["params"]
				for after: int in range(port, count - 1): params[XREBlueprintGraph.case_key(after)] = params[XREBlueprintGraph.case_key(after + 1)]
				params.erase(XREBlueprintGraph.case_key(count - 1))
				params["cases"] = count - 1
			return reshape_pins(id, shrink, renames, "Remove Pin")
	return false


## Makes the array that loop or method block [param id] works on of the scene
## objects [param nodes], in their order (D-143): their paths from the host
## in place of the wire into its Array, or of its rack's list. One edit.
func wire_selection(id: int, nodes: Array[Node]) -> bool:
	var host := get_host()
	var block := graph.find_node(id)
	if host == null or block.is_empty() or not block.get("kind") in ["for_each", "collection"] or XREBlueprintGraph.on_dictionary(block): return _fail("Only an array's input takes the selected objects.")
	var paths: Array[String] = []
	for node: Node in nodes:
		if is_instance_valid(node) and not paths.has(str(host.get_path_to(node))): paths.append(str(host.get_path_to(node)))
	if paths.is_empty(): return _fail("Select the objects first.")
	var port := graph.input_port(block, "collection")
	var state := graph.snapshot()
	state["edges"] = (state["edges"] as Array).filter(func(edge: Dictionary) -> bool: return not (edge["to"] == id and edge["to_port"] == port))
	for entry: Dictionary in state["nodes"]:
		if entry["id"] != id: continue
		(entry["params"] as Dictionary).erase("collection")
		entry["params"][XREBlueprintGraph.SCENE_TARGETS] = paths
	return commit("Wire Selection", state)


## Adds scene object [param node] at the end of the array of selected objects of block [param id] (D-143).
func add_scene_target(id: int, node: Node) -> bool:
	var block := graph.find_node(id)
	var paths: Array[String] = []
	paths.assign((block.get("params", {}) as Dictionary).get(XREBlueprintGraph.SCENE_TARGETS, []))
	var host := get_host()
	if host == null or not is_instance_valid(node): return _fail("The object is missing.")
	if paths.has(str(host.get_path_to(node))): return _fail("The object is in the array already.")
	paths.append(str(host.get_path_to(node)))
	var state := graph.snapshot()
	for entry: Dictionary in state["nodes"]:
		if entry["id"] == id: entry["params"][XREBlueprintGraph.SCENE_TARGETS] = paths
	return commit("Add Element", state)


## Takes object [param index] out of the array of selected objects of block
## [param id] (D-143); the last one out leaves the input to a wire again.
func remove_scene_target(id: int, index: int) -> bool:
	var block := graph.find_node(id)
	var paths: Array[String] = []
	paths.assign((block.get("params", {}) as Dictionary).get(XREBlueprintGraph.SCENE_TARGETS, []))
	if index < 0 or index >= paths.size(): return _fail("The array has no such object.")
	paths.remove_at(index)
	var state := graph.snapshot()
	for entry: Dictionary in state["nodes"]:
		if entry["id"] != id: continue
		if paths.is_empty(): (entry["params"] as Dictionary).erase(XREBlueprintGraph.SCENE_TARGETS)
		else: entry["params"][XREBlueprintGraph.SCENE_TARGETS] = paths
	return commit("Remove Element", state)


## The scene objects of the array of selected objects of block [param id] (D-143), in order; a missing one is null.
func scene_targets(id: int) -> Array[Node]:
	var nodes: Array[Node] = []
	var host := get_host()
	for path: Variant in (graph.find_node(id).get("params", {}) as Dictionary).get(XREBlueprintGraph.SCENE_TARGETS, []):
		nodes.append(host.get_node_or_null(NodePath(str(path))) if host != null else null)
	return nodes


## Hides or shows field [param name] of Break or Make [param id] (D-139): a
## pin with a wire stays. One edit; its other wires follow their fields.
func set_field_hidden(id: int, name: String, hidden: bool) -> bool:
	var block := graph.find_node(id)
	if not block.get("kind") in ["break", "make"]: return _fail("Only Break and Make hide fields.")
	var ports := graph.ports(block, block["kind"] == "make")
	if hidden:
		for edge: Dictionary in graph.edges:
			var port: int = edge["from_port"] if block["kind"] == "break" else edge["to_port"]
			var mine: bool = edge["from"] == id if block["kind"] == "break" else edge["to"] == id
			if mine and port < ports.size() and str(ports[port][2]) == name: return _fail("A wire holds this pin.")
	var change := func(entry: Dictionary) -> void:
		var names: Array = entry.get("hidden", [])
		if hidden and not names.has(name): names.append(name)
		elif not hidden: names.erase(name)
		entry["hidden"] = names
	return reshape_pins(id, change, {}, "Hide Field" if hidden else "Show Field")


## Brings every Break's and Make's fields to their classes as they are now
## (D-139), on opening a graph and before building it: no undo step, as the
## scene bindings ([method refresh_bindings]). A field gone keeps its pin,
## red, while a wire reads it.
func refresh_structs() -> void:
	var state := graph.snapshot()
	var changed := false
	for block: Dictionary in state["nodes"]:
		if not block.get("kind") in ["break", "make"] or (block.get("struct", {}) as Dictionary).is_empty(): continue
		var wired: Array[String] = []
		var ports := graph.ports(block, block["kind"] == "make")
		for edge: Dictionary in graph.edges:
			if block["kind"] == "break" and edge["from"] == block["id"] and edge["from_port"] < ports.size(): wired.append(str(ports[edge["from_port"]][2]))
			if block["kind"] == "make" and edge["to"] == block["id"] and edge["to_port"] < ports.size(): wired.append(str(ports[edge["to_port"]][2]))
		var now: Variant = XREBlueprintStructs.reconciled(block, wired)
		if now == null or now == block["struct"]: continue
		block["struct"] = now
		changed = true
	if not changed: return
	var candidate := XREBlueprintGraph.new()
	candidate.parent = graph.parent
	candidate.restore(state)
	if candidate.validate().is_empty(): _restore_view(state)


## Adds an operand after the last one of variadic operator block [param id]
## (D-136). Its literal changes nothing — 0 to add, 1 to multiply, true for
## AND, false for OR, an empty text to append, the last literal for min and
## max — in the type of operand A's.
func add_operand(id: int) -> bool:
	var block := graph.find_node(id)
	var op := XREBlueprintGraph.operator_of(block)
	if block.get("kind") != "operator" or not XREBlueprintOperators.is_variadic(op): return _fail("This block takes no more inputs.")
	var count := XREBlueprintGraph.operand_count(block)
	if count >= XREBlueprintOperators.MAX_OPERANDS: return _fail("An operator takes at most %d inputs." % XREBlueprintOperators.MAX_OPERANDS)
	var params: Dictionary = block["params"]
	var key: String = XREBlueprintOperators.OPERAND_KEYS[count]
	var literal: Variant = XREBlueprintOperators.operand_default(op, count)
	var last: String = XREBlueprintOperators.OPERAND_KEYS[count - 1]
	if op in ["min", "max"] and params.has(last): literal = params[last]
	else:
		var adopted: Variant = XREBlueprintGraph.adopted_literal(op, "a", graph.operand_type(block, "a"), literal)
		if adopted != null: literal = adopted
	var change := func(entry: Dictionary) -> void:
		entry["params"]["operands"] = count + 1
		entry["params"][key] = literal
	return reshape_pins(id, change, {}, "Add Pin")


## Removes operand [param key] of variadic operator block [param id] with its
## wire (D-136): the operands after it move up, with their literals and wires.
## At least two stay.
func remove_operand(id: int, key: String) -> bool:
	var block := graph.find_node(id)
	if block.get("kind") != "operator" or not XREBlueprintOperators.is_variadic(XREBlueprintGraph.operator_of(block)): return _fail("This block's inputs are fixed.")
	var count := XREBlueprintGraph.operand_count(block)
	var index := XREBlueprintOperators.OPERAND_KEYS.find(key)
	if index < 0 or index >= count: return _fail("The block has no input %s." % key.to_upper())
	if count <= XREBlueprintOperators.MIN_OPERANDS: return _fail("An operator keeps at least %d inputs." % XREBlueprintOperators.MIN_OPERANDS)
	var keys := XREBlueprintOperators.OPERAND_KEYS
	var renames := {key: ""}
	for after: int in range(index + 1, count): renames[keys[after]] = keys[after - 1]
	var change := func(entry: Dictionary) -> void:
		var params: Dictionary = entry["params"]
		for after: int in range(index, count - 1):
			if params.has(keys[after + 1]): params[keys[after]] = params[keys[after + 1]]
			else: params.erase(keys[after])
		params.erase(keys[count - 1])
		if count - 1 > XREBlueprintOperators.MIN_OPERANDS: params["operands"] = count - 1
		else: params.erase("operands")
	return reshape_pins(id, change, renames, "Remove Pin")


## How many ports a call block's shown advanced arguments add after its other inputs.
static func _advanced_count(block: Dictionary) -> int:
	var count := 0
	var function: Dictionary = block["function"]
	if not function.get("advanced_shown", false): return 0
	for argument: Dictionary in function["args"]:
		if argument.get("advanced", false) and not argument.get("literal", false) and not argument.get("fixed", false) and not argument.get("run", false): count += 1
	return count


## Removes blocks and every incident connection as one operation.
func remove_blocks(ids: Array[int]) -> void:
	var state := graph.snapshot()
	state["nodes"] = (state["nodes"] as Array).filter(func(block: Dictionary) -> bool: return not ids.has(block["id"]))
	state["edges"] = (state["edges"] as Array).filter(func(edge: Dictionary) -> bool: return not ids.has(edge["from"]) and not ids.has(edge["to"]))
	commit("Delete Blocks", state)


## Connects compatible unoccupied ports. Invalid changes leave the graph untouched.
func connect_blocks(from: int, from_port: int, to: int, to_port: int) -> bool:
	var state := graph.snapshot()
	(state["edges"] as Array).append({"from": from, "from_port": from_port, "to": to, "to_port": to_port})
	return commit("Connect Ports", state)


## Disconnects a specific wire, with whatever the VR editor keeps on it (its bends, D-081).
func disconnect_blocks(from: int, from_port: int, to: int, to_port: int) -> void:
	var state := graph.snapshot()
	state["edges"] = (state["edges"] as Array).filter(func(edge: Dictionary) -> bool:
		return not (edge["from"] == from and edge["from_port"] == from_port and edge["to"] == to and edge["to_port"] == to_port))
	commit("Disconnect Ports", state)


## Edits a parameter, preserving the previous value for undo. [param edits]
## sets fields of blocks in the same edit, [code]{id: {field: value}}[/code],
## a null value erasing the field: the headset's links move with a target (D-074).
func set_parameter(id: int, key: String, value: Variant, edits: Dictionary = {}) -> bool:
	var state := graph.snapshot()
	for block: Dictionary in state["nodes"]:
		var fields: Dictionary = edits.get(block["id"], {})
		for field: String in fields:
			if fields[field] == null: block.erase(field)
			else: block[field] = fields[field]
		if block["id"] == id:
			block["params"][key] = value
			if key in ["target", "property", "signal"] or key in _provider_keys(block):
				_reflect(block, get_host(), true)
			if key == "variable" and block["kind"] == "set_variable":
				var variable := graph.find_variable(str(value))
				if not variable.is_empty(): block["params"]["value"] = variable.get("value", XREBlueprintSchema.default_value(XREBlueprintGraph.variable_type(variable)))
	return commit("Set %s" % key.capitalize(), state)


## Records a complete graph change. Used for group dragging too. [param state]
## is of the graph the views show: a function's body goes into the file's
## graph, a first wire of one of its Entry's or Return's pins giving it its type.
func commit(title: String, state: Dictionary) -> bool:
	last_error = ""
	if amend.is_valid(): amend.call(state)
	var candidate := XREBlueprintGraph.new()
	candidate.parent = graph.parent
	candidate.restore(state)
	# A wire into an operator's operand: the other's literal takes its type (D-065).
	var adopted := candidate.adopt_operands(graph.edges)
	# A wire into Break's Target or from Make's Result types the block (D-139).
	if candidate.adopt_structs(graph.edges): adopted = true
	# A wire from an enumeration's constant into a Switch's Selection makes it a Switch on it (D-138).
	if candidate.adopt_enums(graph.edges): adopted = true
	# A wire into a collection block types its literals (D-141).
	if candidate.adopt_collections(graph.edges): adopted = true
	if adopted: state = candidate.snapshot()
	if opened.is_empty():
		if state == graph.snapshot():
			return true
		return _record_state(title, state, _binding_snapshot(state))
	var full := root.embed(opened, state)
	var typed := XREBlueprintUserFunctions.adopt_pins(full, opened, graph.edges)
	XREBlueprintUserFunctions.sync(full, root.snapshot(), typed["renames"], {}, typed["literals"], typed["changed"])
	if full == root.snapshot():
		return true
	return _record_state(title, full, _binding_snapshot(state))


## Records [param state] of the file's graph, its functions too, as one edit
## [param title], after checking it: [param bindings] are the targets of the
## blocks of the graph the views show ([method _binding_snapshot]).
func _record_state(title: String, state: Dictionary, bindings: Dictionary) -> bool:
	var check := XREBlueprintGraph.new()
	check.restore(state)
	var errors := check.validate()
	if not errors.is_empty():
		return _fail("\n".join(errors))
	history.create_action("Blueprints: " + title)
	# Weak references in history preserve chosen identities across scene renames,
	# without a reference cycle between this document and its UndoRedo object.
	history.add_do_method(_restore_bound.bind(weakref(self), state.duplicate(true), bindings, opened))
	history.add_undo_method(_restore_bound.bind(weakref(self), root.snapshot(), _targets.duplicate(), opened))
	history.commit_action()
	_record(StringName(title.to_snake_case()))
	return true


## Puts the file's graph to [param state] and the body the views show with it.
## [param bindings] are of the graph [param view] showed: a view of another
## graph binds its targets anew by their paths.
static func _restore_bound(ref: WeakRef, state: Dictionary, bindings: Dictionary, view: String) -> void:
	var document := ref.get_ref() as XREBlueprintDocument
	if document == null: return
	document.root.restore(state)
	document._sync_view()
	document._targets.clear()
	document._bound_paths.clear()
	if view == document.opened:
		document._targets.assign(bindings)
		for block: Dictionary in document.graph.nodes:
			var params: Dictionary = block["params"]
			if params.has("target"): document._bound_paths[block["id"]] = params["target"]
	document.refresh_bindings()


## The body the views show as the file's graph has it now; the file's graph
## when its function is gone.
func _sync_view() -> void:
	if opened.is_empty(): return
	if root.function_index(opened) < 0:
		_show("")
		return
	graph.restore(root.body_state(opened))


## Shows the graph [param state] of the graph the views show, outside history: a
## refresh of what the scene says ([method refresh_bindings], [method refresh_structs]).
func _restore_view(state: Dictionary) -> void:
	if not opened.is_empty(): root.restore(root.embed(opened, state))
	graph.restore(state)


## The views show function [param name]'s body, or the file's graph for an
## empty name. Not an edit: undo doesn't change what is shown, but an undo of
## an edit of the body shown keeps it shown.
func open_function(name: String) -> bool:
	if name == opened: return true
	if not name.is_empty() and root.function_index(name) < 0: return _fail("There is no function %s." % name)
	_show(name)
	_record(&"enter_function" if not name.is_empty() else &"exit_function")
	return true


func _show(name: String) -> void:
	if name == opened and (name.is_empty() or graph != root): return
	graph.changed.disconnect(changed.emit)
	opened = name
	graph = root if name.is_empty() else root.body(name)
	graph.changed.connect(changed.emit)
	_targets.clear()
	_bound_paths.clear()
	refresh_bindings()
	body_opened.emit(name)
	changed.emit()


## Adds a function to the file's graph, pure or not, named
## [param name] or function_1… (docs/blueprint_functions.md): its body has
## only its Entry and Return, turned [param yaw] radians, the Return left of the Entry with [param leftward]. One edit; returns its name, empty if refused.
func create_function(pure: bool = false, name: String = "", yaw: float = 0.0, leftward: bool = false) -> String:
	var names := XREBlueprintUserFunctions.names(root.functions)
	if name.is_empty(): name = XREBlueprintUserFunctions.free_name("function_", names)
	if not XREBlueprintUserFunctions.valid_name(name) or names.has(name):
		_fail("A function needs a free name that is an identifier.")
		return ""
	var state := root.snapshot()
	var entry := XREBlueprintUserFunctions.make(name, pure)
	# Its Entry and Return face the way the graph's cards do, [param yaw] about the vertical.
	if not is_zero_approx(yaw):
		for block: Dictionary in entry["nodes"] as Array: block["vr_rotation"] = Vector3(0, yaw, 0)
	# Seen from behind or from the side, the graph's right is the viewer's left: the Return stands on the viewer's right.
	if leftward:
		var nodes: Array = entry["nodes"]
		var first: Vector2 = nodes[0]["position"]
		nodes[0]["position"] = nodes[1]["position"]
		nodes[1]["position"] = first
	(state["functions"] as Array).append(entry)
	return name if _commit_functions("Create Function", state) else ""


## Removes function [param name], which nothing calls any more. One edit.
func delete_function(name: String) -> bool:
	var index := root.function_index(name)
	if index < 0: return _fail("There is no function %s." % name)
	var calls := XREBlueprintUserFunctions.count_calls(root, name)
	if calls > 0: return _fail("%s has %d calls: delete them first." % [name, calls])
	var state := root.snapshot()
	(state["functions"] as Array).remove_at(index)
	return _commit_functions("Delete Function", state)


## Renames function [param name] to [param new_name]; its calls follow. One edit.
func rename_function(name: String, new_name: String) -> bool:
	var index := root.function_index(name)
	if index < 0: return _fail("There is no function %s." % name)
	if new_name == name: return true
	if not XREBlueprintUserFunctions.valid_name(new_name) or root.function_index(new_name) >= 0: return _fail("A function needs a free name that is an identifier.")
	var state := root.snapshot()
	state["functions"][index]["name"] = new_name
	var was := opened
	if opened == name: opened = new_name
	if not _commit_functions("Rename Function", state, {}, {name: new_name}):
		opened = was
		return false
	return true


## Makes function [param name] pure or not, which always works: going pure,
## its Entry, its Return and its calls lose Then and In with their wires;
## blocks with execution stay in its body, never run (docs/blueprint_functions.md).
## Going back, an Entry joins its Return when the body has nothing to run. One edit.
func set_function_pure(name: String, pure: bool) -> bool:
	var index := root.function_index(name)
	if index < 0: return _fail("There is no function %s." % name)
	if bool(root.functions[index].get("pure", false)) == pure: return true
	var state := root.snapshot()
	var entry: Dictionary = state["functions"][index]
	entry["pure"] = pure
	# A pure function has no execution: its pins of execution have no type again.
	if pure:
		for side: String in ["inputs", "outputs"]:
			for pin: Dictionary in entry[side] as Array: pin.erase("exec")
	XREBlueprintUserFunctions.sync(state, root.snapshot())
	if not pure:
		var view := XREBlueprintGraph.new()
		view.restore(state)
		var body := view.body(name)
		var start := -1
		var finish := -1
		var runs := false
		for block: Dictionary in body.nodes:
			if block["kind"] == "entry": start = block["id"]
			elif block["kind"] == "return": finish = block["id"] if finish < 0 else finish
			elif not XREBlueprintGraph.is_pure(block): runs = true
		if not runs and start > 0 and finish > 0: (entry["edges"] as Array).append({"from": start, "from_port": 0, "to": finish, "to_port": 0})
	return _commit_functions("Set Function Pure", state, {}, {}, {}, false)


## Adds an input ([param input]) or an output to function [param name]:
## input_1… or output_1…, without a type until its first wire gives one. One
## edit with its calls; returns the pin's name, empty if refused.
func add_function_pin(name: String, input: bool) -> String:
	var index := root.function_index(name)
	if index < 0:
		_fail("There is no function %s." % name)
		return ""
	var side := "inputs" if input else "outputs"
	var pins: Array = root.functions[index][side]
	if pins.size() >= XREBlueprintUserFunctions.MAX_PINS:
		_fail("A function has at most %d %s." % [XREBlueprintUserFunctions.MAX_PINS, side])
		return ""
	var key := XREBlueprintUserFunctions.free_name("input_" if input else "output_", XREBlueprintUserFunctions.names_of(pins))
	var state := root.snapshot()
	(state["functions"][index][side] as Array).append({"key": key})
	return key if _commit_functions("Add Function Input" if input else "Add Function Output", state) else ""


## Removes input ([param input]) or output [param key] of function
## [param name] with its wires, in the body and at every call. One edit.
func remove_function_pin(name: String, input: bool, key: String) -> bool:
	var index := root.function_index(name)
	if index < 0: return _fail("There is no function %s." % name)
	var side := "inputs" if input else "outputs"
	var state := root.snapshot()
	var pins: Array = state["functions"][index][side]
	var at := XREBlueprintUserFunctions.names_of(pins).find(key)
	if at < 0: return _fail("%s has no pin %s." % [name, key])
	pins.remove_at(at)
	return _commit_functions("Remove Function Pin", state, {name: {key: "", "#" + key: ""}})


## Renames pin [param key] of function [param name] to [param new_key]; its
## wires and the calls' values stay. One edit.
func rename_function_pin(name: String, input: bool, key: String, new_key: String) -> bool:
	var index := root.function_index(name)
	if index < 0: return _fail("There is no function %s." % name)
	if new_key == key: return true
	var side := "inputs" if input else "outputs"
	var state := root.snapshot()
	var pins: Array = state["functions"][index][side]
	var names := XREBlueprintUserFunctions.names_of(pins)
	var at := names.find(key)
	if at < 0: return _fail("%s has no pin %s." % [name, key])
	if not XREBlueprintUserFunctions.valid_name(new_key) or names.has(new_key): return _fail("A pin needs a free name that is an identifier.")
	pins[at]["key"] = new_key
	return _commit_functions("Rename Function Pin", state, {name: {key: new_key, "#" + key: "#" + new_key}})


## Moves pin [param key] of function [param name] to place [param place] of
## its side; the wires follow. One edit.
func move_function_pin(name: String, input: bool, key: String, place: int) -> bool:
	var index := root.function_index(name)
	if index < 0: return _fail("There is no function %s." % name)
	var side := "inputs" if input else "outputs"
	var state := root.snapshot()
	var pins: Array = state["functions"][index][side]
	var at := XREBlueprintUserFunctions.names_of(pins).find(key)
	if at < 0: return _fail("%s has no pin %s." % [name, key])
	place = clampi(place, 0, pins.size() - 1)
	if place == at: return true
	var pin: Variant = pins.pop_at(at)
	pins.insert(place, pin)
	return _commit_functions("Move Function Pin", state)


## Adds a call of function [param name] at [param position] of the graph the
## views show, [param depth] deep in VR, wired as [method insert_block] does.
## Returns its ID, -1 if refused.
func add_function_call(name: String, position: Vector2, wire: Dictionary = {}, depth: float = 0.0) -> int:
	var index := root.function_index(name)
	if index < 0: return _fail_id("There is no function %s." % name)
	var awaits: bool = XREBlueprintUserFunctions.awaiting(root.snapshot()).get(name, false)
	var signature := XREBlueprintUserFunctions.call_signature(root.functions[index], awaits)
	var block := XREBlueprintGraph.make_call(0, signature, position)
	if not is_zero_approx(depth): block["vr_depth"] = depth
	return insert_block(block, position, wire, null, "Add Function Call")


## Records [param state], an edit of the file's graph's functions, after
## bringing their calls and bodies up to date ([method XREBlueprintUserFunctions.sync]).
func _commit_functions(title: String, state: Dictionary, renames: Dictionary = {}, renamed: Dictionary = {}, literals: Dictionary = {}, sync: bool = true) -> bool:
	if sync: XREBlueprintUserFunctions.sync(state, root.snapshot(), renames, renamed, literals)
	if state == root.snapshot(): return true
	return _record_state(title, state, _targets.duplicate())


func _binding_snapshot(state: Dictionary) -> Dictionary:
	var result: Dictionary[int, WeakRef] = {}
	var root := _root_ref.get_ref() as Node if _root_ref != null else null
	if root == null: return result
	var host := root.get_node_or_null(state["host_path"])
	if host == null: return result
	for block: Dictionary in state["nodes"]:
		var params: Dictionary = block["params"]
		if not params.has("target"): continue
		# "." is the host itself, whichever node hosts the script, as On Ready's is.
		if str(params["target"]).strip_edges().is_empty() or params["target"] == ".": continue
		var target := host.get_node_or_null(NodePath(params["target"]))
		if target != null and (target == root or root.is_ancestor_of(target)): result[block["id"]] = weakref(target)
	return result


## Undoes a graph edit without consuming unrelated scene history.
func undo() -> void:
	if history.has_undo():
		history.undo()
		_record(&"undo")


## Reapplies an undone graph edit.
func redo() -> void:
	if history.has_redo():
		history.redo()
		_record(&"redo")


## Assigns only to an unscripted node, or one already using this generated script.
## Scene assignment uses the editor's scene history; graph edits have their own history.
func attach_to_selected(undo_redo: EditorUndoRedoManager) -> bool:
	var selected := EditorInterface.get_selection().get_selected_nodes()
	if selected.size() != 1:
		return _fail("Select exactly one scene node to receive this Blueprint.")
	var node: Node = selected[0]
	var previous := node.get_script() as Script
	if previous != null and previous.resource_path != script_path():
		return _fail("The selected node already has a different script. Use an empty child Node for the Blueprint.")
	if not set_host_node(node) or not build():
		return false
	var script := ResourceLoader.load(script_path(), "GDScript", ResourceLoader.CACHE_MODE_REPLACE) as Script
	# Runtime scripts deliberately lack @tool: can_instantiate() is false in
	# the editor even for valid code. build() has already checked reload().
	if script == null:
		return _fail("Could not load the generated script.")
	if previous == script:
		return true
	undo_redo.create_action("Blueprints: Attach Script", UndoRedo.MERGE_DISABLE, node)
	undo_redo.add_do_method(node, &"set_script", script)
	undo_redo.add_undo_method(node, &"set_script", previous)
	undo_redo.commit_action()
	_record(&"attach_script")
	return true


## Explicitly associates a graph with a scene. Tab changes use update_active_scene.
func set_scene_root(root: Node) -> void:
	_active_root_ref = weakref(root) if root != null else null
	_root_ref = null
	_context_assigned = false
	if root == null: graph.scene_path = ""
	_bind_owner(root)
	changed.emit()


## Changes the visible editor scene without retargeting an existing graph.
func update_active_scene(root: Node) -> void:
	var owner := _owning_scene()
	var clean_unassigned := not _context_assigned and owner == null and graph.scene_path.is_empty() and path.is_empty() and not is_dirty()
	_active_root_ref = weakref(root) if root != null else null
	if root != null:
		if owner == root:
			refresh_bindings()
		elif not graph.scene_path.is_empty() and root.scene_file_path == graph.scene_path:
			_bind_owner(root)
		elif not _context_assigned and owner == null and graph.scene_path.is_empty():
			_bind_owner(root)
	if clean_unassigned: _saved_state = graph.snapshot()
	changed.emit()


## Reflection and target editing are available only in the graph's owning scene.
func scene_context_active() -> bool:
	var root := _owning_scene()
	return root != null and root == _active_scene()


## Neutral notice for another active scene, or for a closed graph scene.
func scene_context_message() -> String:
	if scene_context_active(): return ""
	if not graph.scene_path.is_empty(): return "Graph belongs to " + graph.scene_path.get_file()
	var owner := _owning_scene()
	if owner != null: return "Graph belongs to " + str(owner.name) + " (unsaved scene)"
	if _context_assigned: return "Graph scene is unavailable (unsaved scene)."
	return "Open a scene to configure this graph."


## Opens/activates the saved owner scene through the document bridge.
func open_graph_scene() -> bool:
	if graph.scene_path.is_empty() or not FileAccess.file_exists(graph.scene_path):
		return _fail("The graph scene is unavailable.")
	EditorInterface.open_scene_from_path(graph.scene_path)
	_record(&"open_graph_scene")
	return true


func _owning_scene() -> Node:
	return _root_ref.get_ref() as Node if _root_ref != null else null


func _active_scene() -> Node:
	return _active_root_ref.get_ref() as Node if _active_root_ref != null else null


func _bind_owner(root: Node) -> void:
	if root == null: return
	_context_assigned = true
	_root_ref = weakref(root)
	graph.scene_path = root.scene_file_path
	_host_ref = null
	_targets.clear()
	_bound_paths.clear()
	refresh_bindings()


func _select_graph_context(previous_root: Node) -> void:
	_root_ref = null
	_context_assigned = false
	var active := _active_scene()
	if graph.scene_path.is_empty():
		# Legacy resources have no owner metadata. Prefer an actual script user,
		# then the companion scene; otherwise the scene chosen on first open.
		for candidate: Node in [previous_root, active]:
			if candidate == null or path.is_empty(): continue
			for node: Node in _nodes_under(candidate):
				var script := node.get_script() as Script
				if script != null and script.resource_path == script_path():
					_bind_owner(candidate)
					return
		var companion := path.get_basename() + ".tscn" if not path.is_empty() else ""
		if not companion.is_empty() and FileAccess.file_exists(companion):
			graph.scene_path = companion
		else:
			_bind_owner(active)
			return
	for candidate: Node in [previous_root, active]:
		if candidate != null and candidate.scene_file_path == graph.scene_path:
			_bind_owner(candidate)
			return
	_context_assigned = not graph.scene_path.is_empty()


## Scene nodes available to the host/target picker, in tree order.
func scene_nodes() -> Array[Node]:
	if not scene_context_active(): return []
	return _nodes_under(_owning_scene())


func _nodes_under(root: Node) -> Array[Node]:
	var result: Array[Node] = []
	if root == null: return result
	var pending: Array[Node] = [root]
	while not pending.is_empty():
		var node: Node = pending.pop_back()
		result.append(node)
		var children := node.get_children()
		children.reverse()
		for child: Node in children: pending.append(child)
	return result


## Resolves the script host, preserving its identity through renames in this session.
func get_host() -> Node:
	if not scene_context_active(): return null
	if graph.host_path.is_empty(): return null
	var root := _root_ref.get_ref() as Node if _root_ref != null else null
	if root == null: return null
	var host := _host_ref.get_ref() as Node if _host_ref != null else null
	if host == null or _host_bound_path != graph.host_path:
		host = root.get_node_or_null(graph.host_path)
		_host_ref = weakref(host) if host != null else null
		_host_bound_path = graph.host_path
	return host


## Chooses the script host and rewrites known targets relative to it as one edit.
func set_host_node(node: Node) -> bool:
	if not scene_context_active(): return _fail(scene_context_message())
	var root := _root_ref.get_ref() as Node if _root_ref != null else null
	if root == null or not (node == root or root.is_ancestor_of(node)):
		return _fail("Choose a host in the edited scene.")
	refresh_bindings()
	var state := graph.snapshot()
	state["host_path"] = root.get_path_to(node)
	for block: Dictionary in state["nodes"]:
		var ref: WeakRef = _targets.get(block["id"])
		var target := ref.get_ref() as Node if ref != null else null
		if target != null: block["params"]["target"] = str(node.get_path_to(target))
	if not commit("Set Script Host", state): return false
	_host_ref = weakref(node)
	_host_bound_path = graph.host_path
	return true


## Points block [param id] at scene node [param node] and sets its member
## [param key] — a property, signal or animation — to [param member], as one
## edit called [param title] (D-052): the wire from the Target to a petal of
## the member. An empty key leaves the members as they are. [param anchor],
## in [param node]'s space, is where the wire ends on it, for the headset.
func set_target_member(id: int, node: Node, key: String, member: String, anchor: Variant = null, title: String = "Wire Member") -> bool:
	var host := get_host()
	if host == null: return _fail("Choose the script host first.")
	if not scene_nodes().has(node): return _fail("The target is outside the edited scene.")
	var block := graph.find_node(id)
	if block.is_empty() or not XREBlueprintGraph.has_target(block): return _fail("This block has no target.")
	var problem := XREBlueprintSchema.target_kind_problem(block, node)
	if not problem.is_empty(): return _fail(problem)
	var state := graph.snapshot()
	for entry: Dictionary in state["nodes"]:
		if entry["id"] != id: continue
		entry["params"]["target"] = str(host.get_path_to(node))
		if not key.is_empty(): entry["params"][key] = member
		if anchor is Vector3: entry["vr_anchor"] = anchor
		else: entry.erase("vr_anchor")
		_reflect(entry, host, true)
	if not commit(title, state): return false
	if node != host:
		_targets[id] = weakref(node)
		_bound_paths[id] = str(host.get_path_to(node))
	return true


## Selects a target from the scene tree. No edited scene node is mutated.
## [param edits] sets fields of blocks in the same edit ([method set_parameter]).
func choose_target(id: int, node: Node, edits: Dictionary = {}) -> bool:
	var host := get_host()
	if host == null: return _fail("Choose the script host first.")
	if not scene_nodes().has(node): return _fail("The target is outside the edited scene.")
	var problem := XREBlueprintSchema.target_kind_problem(graph.find_node(id), node)
	if not problem.is_empty(): return _fail(problem)
	if not set_parameter(id, "target", str(host.get_path_to(node)), edits): return false
	if node != host:
		_targets[id] = weakref(node)
		_bound_paths[id] = str(host.get_path_to(node))
	return true


## Refreshes paths and cached types after scene edits or before compilation.
func refresh_bindings() -> void:
	if not scene_context_active(): return
	var host := get_host()
	if host == null: return
	var root := _root_ref.get_ref() as Node
	var state := graph.snapshot()
	state["scene_path"] = root.scene_file_path
	state["host_path"] = root.get_path_to(host)
	for block: Dictionary in state["nodes"]:
		var params: Dictionary = block["params"]
		if not params.has("target"): continue
		if str(params["target"]).strip_edges().is_empty(): continue
		if params["target"] == ".":
			_targets.erase(block["id"])
			_bound_paths.erase(block["id"])
			_reflect(block, host)
			continue
		var ref: WeakRef = _targets.get(block["id"])
		var target := ref.get_ref() as Node if ref != null else null
		if target != null and _bound_paths.get(block["id"]) == params["target"] and (target == root or root.is_ancestor_of(target)):
			params["target"] = str(host.get_path_to(target))
		else:
			target = host.get_node_or_null(NodePath(params["target"]))
		if target != null and (target == root or root.is_ancestor_of(target)):
			_targets[block["id"]] = weakref(target)
			_bound_paths[block["id"]] = params["target"]
		_reflect(block, host)
	var candidate := XREBlueprintGraph.new()
	candidate.parent = graph.parent
	candidate.restore(state)
	if candidate.validate().is_empty() and state != graph.snapshot():
		_restore_view(state)
		_record(&"refresh_scene_bindings")


## Reports missing targets/properties/signals before writing generated code.
func validate_scene() -> PackedStringArray:
	var errors := PackedStringArray()
	if _root_ref == null and graph.scene_path.is_empty(): return errors
	if not scene_context_active():
		errors.append(scene_context_message())
		return errors
	var host := get_host()
	if host == null:
		errors.append("Script host is missing from the edited scene.")
		return errors
	for block: Dictionary in graph.nodes:
		var params: Dictionary = block["params"]
		if not params.has("target"): continue
		if target_is_connected(block["id"]): continue
		var problem := target_problem(block["id"], params["target"])
		if not problem.is_empty(): errors.append("Block #%d: %s." % [block["id"], problem])
	return errors


## Available properties of the block's exemplar target.
func target_node(id: int) -> Node:
	var block := graph.find_node(id)
	return resolve_target((block["params"] as Dictionary).get("target", ".")) if not block.is_empty() else null


## Resolves only targets within the edited scene. An empty path is not the host.
func resolve_target(target_path: String) -> Node:
	var host := get_host()
	if host == null or target_path.strip_edges().is_empty(): return null
	var target := host.get_node_or_null(NodePath(target_path))
	var root := _root_ref.get_ref() as Node if _root_ref != null else null
	return target if target != null and (target == root or root.is_ancestor_of(target)) else null


## True when a runtime object supplies this block's target instead of its literal path.
func target_is_connected(id: int) -> bool:
	var block := graph.find_node(id)
	if block.is_empty(): return false
	var port := graph.target_port(block)
	for edge: Dictionary in graph.edges:
		if edge["to"] == id and edge["to_port"] == port: return true
	return false


## Live validation of a literal target. Missing nodes use the exact UI message.
func target_problem(id: int, target_path: String) -> String:
	var block := graph.find_node(id)
	if block.is_empty(): return "missing target"
	if not scene_context_active(): return scene_context_message()
	if target_path.begins_with("/root/"): return _autoload_problem(block, target_path)
	var target := resolve_target(target_path)
	var problem := XREBlueprintSchema.target_problem(block, target)
	if not problem.is_empty(): return problem
	if block["kind"] == "signal" and (block["params"] as Dictionary).get("signal") == "ready" and target != get_host() and get_host().is_ancestor_of(target):
		return "a child is ready before its host: give the child its own graph"
	var candidate: Dictionary = block.duplicate(true)
	candidate["params"]["target"] = target_path
	_reflect(candidate, get_host(), true)
	var inputs := graph.ports(candidate, true)
	var outputs := graph.ports(candidate, false)
	for edge: Dictionary in graph.edges:
		if edge["to"] == id:
			var source := graph.ports(graph.find_node(edge["from"]), false)
			if edge["to_port"] >= inputs.size() or not graph.ports_compatible(source[edge["from_port"]][1], inputs[edge["to_port"]][1]): return "target is incompatible with connected ports"
		if edge["from"] == id:
			var destination := graph.ports(graph.find_node(edge["to"]), true)
			if edge["from_port"] >= outputs.size() or not graph.ports_compatible(outputs[edge["from_port"]][1], destination[edge["to_port"]][1]): return "target is incompatible with connected ports"
	return ""


## Suitable scene paths matching a prefix or a partial name, with the best match first.
func target_suggestions(id: int, query: String, limit: int = 8) -> PackedStringArray:
	var result := PackedStringArray()
	var host := get_host()
	var block := graph.find_node(id)
	if host == null or block.is_empty(): return result
	var prefix := query.to_lower()
	var partial := PackedStringArray()
	for node: Node in scene_nodes():
		var node_path := str(host.get_path_to(node))
		if not prefix.is_empty() and not node_path.to_lower().contains(prefix): continue
		if not target_problem(id, node_path).is_empty(): continue
		if prefix.is_empty() or node_path.to_lower().begins_with(prefix): result.append(node_path)
		elif node_path.to_lower().contains(prefix): partial.append(node_path)
	result.sort()
	partial.sort()
	result.append_array(partial)
	return result.slice(0, limit)


## Adds or edits a fixed-type variable default through graph history.
func set_variable(name: String, value: Variant) -> bool:
	var state := graph.snapshot()
	var found := false
	for variable: Dictionary in state["variables"]:
		if variable["name"] == name:
			variable["value"] = value
			variable.erase("type")
			found = true
	if not found: (state["variables"] as Array).append({"name": name, "value": value})
	return commit("Set Variable Default", state)


## Adds variable [param name] starting at [param value] through graph history,
## with the editor-only [param fields] of a view beside them, such as where the
## headset's graph shows its box (D-078). A taken or invalid name is refused.
func add_variable(name: String, value: Variant, fields: Dictionary = {}) -> bool:
	if not name.is_valid_identifier() or not graph.find_variable(name).is_empty(): return _fail("A variable needs a new name of letters, digits and _.")
	var state := graph.snapshot()
	var variable := {"name": name, "value": value}
	variable.merge(fields)
	(state["variables"] as Array).append(variable)
	return commit("Add Variable", state)


## Takes the start value out of variable [param name], keeping its type
## (D-054): the box is empty, and the build reports it until a value is back.
## A collection keeps its elements' type in its value: it is emptied instead (D-141).
func clear_variable_value(name: String) -> bool:
	var state := graph.snapshot()
	for variable: Dictionary in state["variables"]:
		if variable["name"] == name and variable.has("value"):
			var category := XREBlueprintCollections.category_of(variable["value"])
			if XREBlueprintCollections.is_collection(category):
				variable["value"] = XREBlueprintCollections.empty(category)
				continue
			variable["type"] = typeof(variable["value"])
			variable.erase("value")
	return commit("Take Token Out", state)


## Takes the literal of parameter [param key] out of block [param id]: its
## socket is empty, and the build reports it until a token or a wire is back (D-054).
func clear_parameter(id: int, key: String) -> bool:
	var state := graph.snapshot()
	for block: Dictionary in state["nodes"]:
		if block["id"] == id: (block["params"] as Dictionary).erase(key)
	return commit("Take Token Out", state)


## Removes an unused variable; references must be removed first.
func remove_variable(name: String) -> bool:
	for block: Dictionary in graph.nodes:
		if (block["params"] as Dictionary).get("variable", "") == name: return _fail("Variable is used by block #%d." % block["id"])
	var state := graph.snapshot()
	state["variables"] = (state["variables"] as Array).filter(func(variable: Dictionary) -> bool: return variable["name"] != name)
	return commit("Remove Variable", state)


func _reflect(block: Dictionary, host: Node, adjust_default: bool = false) -> void:
	var params: Dictionary = block["params"]
	if host == null or not params.has("target") or str(params["target"]).strip_edges().is_empty(): return
	var target := host.get_node_or_null(NodePath(params["target"]))
	var root := _root_ref.get_ref() as Node if _root_ref != null else null
	if target == null or root == null or not (target == root or root.is_ancestor_of(target)): return
	if block["kind"] == "signal" and target.has_signal(params["signal"]): block["arguments"] = XREBlueprintSchema.signal_arguments(target, params["signal"])
	var property_key := "property" if block["kind"] in ["get_property", "set_property"] else _property_key(block)
	if property_key.is_empty() or not params.has(property_key): return
	var info := XREBlueprintSchema.property_info(target, params[property_key])
	if info.is_empty(): return
	block["property_type"] = int(info["type"])
	var enum_path := XREBlueprintSchema.property_enum(target.get_class(), info) if not str(params[property_key]).contains(":") else ""
	if not enum_path.is_empty(): block["property_enum"] = enum_path
	else: block.erase("property_enum")
	var value_key := "value" if block["kind"] in ["get_property", "set_property"] else _typed_key(block, property_key)
	if adjust_default and params.has(value_key) and not XREBlueprintSchema.accepts(info["type"], typeof(params[value_key])) and XREBlueprintGraph.is_literal(info["value"]): params[value_key] = info["value"]


## Keys of a call's arguments whose names come from its target ([XREBlueprintFunctions]).
static func _provider_keys(block: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	if block.get("kind") != "call": return keys
	for argument: Dictionary in (block["function"] as Dictionary)["args"]:
		if not str(argument.get("provider", "")).is_empty(): keys.append(str(argument["key"]))
	return keys


## The key of a call's property argument, empty for none.
static func _property_key(block: Dictionary) -> String:
	if block.get("kind") != "call": return ""
	for argument: Dictionary in (block["function"] as Dictionary)["args"]:
		if argument.get("provider", "") == "property": return str(argument["key"])
	return ""


## The key of the argument whose port takes the type of property argument [param property_key].
static func _typed_key(block: Dictionary, property_key: String) -> String:
	for argument: Dictionary in (block["function"] as Dictionary)["args"]:
		if argument.get("type_of", "") == property_key: return str(argument["key"])
	return ""


## Target of an autoload, [code]/root/Name[/code]: the autoload exists and, for a method, has it.
func _autoload_problem(block: Dictionary, target_path: String) -> String:
	var autoload := target_path.trim_prefix("/root/")
	if not ProjectSettings.has_setting("autoload/" + autoload): return "missing target"
	if block["kind"] != "call" or block["function"]["scope"] != "method": return ""
	var script := load(str(ProjectSettings.get_setting("autoload/" + autoload)).trim_prefix("*")) as Script
	var method := str(block["function"]["name"])
	if script != null:
		for info: Dictionary in script.get_script_method_list():
			if str(info["name"]) == method: return ""
	var base := str(block["function"]["class"])
	if ClassDB.class_exists(base) and ClassDB.class_has_method(base, method): return ""
	return "missing method: " + method


func _fail(message: String) -> bool:
	last_error = message
	return false


func _fail_id(message: String) -> int:
	last_error = message
	return -1


func _record(operation: StringName) -> void:
	operation_recorded.emit(operation, operation_source, Time.get_ticks_usec())
