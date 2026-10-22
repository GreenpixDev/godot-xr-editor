@tool
class_name XREBlueprintDocument
extends RefCounted
## Standalone graph document and the only bridge to scene/editor mutations (D-021).

signal changed
## Compatible telemetry boundary for the future XR view of this graph.
signal operation_recorded(operation: StringName, source: StringName, time_usec: int)

const RECOVERY_PATH := "user://blueprints_unsaved.tres"

static var _editor_document: XREBlueprintDocument
static var _editor_clients := 0

## The input view scopes this value with perform(); automatic refreshes do not record operations.
var operation_source: StringName = &"desktop_graph"

var graph := XREBlueprintGraph.new()
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
	changed.emit()
	_record(&"open_graph")
	return true


## True after an edit that has not been saved, including after undoing a saved edit.
func is_dirty() -> bool:
	return graph.snapshot() != _saved_state


## Takes the graph as it is now for saved, its history starting here: a new
## graph opened for a selected object in the headset is written only once it
## is changed (D-063).
func mark_saved() -> void:
	history.clear_history()
	_saved_state = graph.snapshot()


## Saves the source even when it is incomplete. Compilation is a separate operation.
func save_graph(file_path: String) -> bool:
	if not file_path.begins_with("res://") or file_path.get_extension() != "tres":
		return _fail("Save the graph as a .tres file inside the project.")
	var error := ResourceSaver.save(graph, file_path)
	if error != OK:
		return _fail("Could not save graph: %s." % error_string(error))
	path = file_path
	_saved_state = graph.snapshot()
	if Engine.is_editor_hint(): EditorInterface.get_resource_filesystem().update_file(file_path)
	changed.emit()
	_record(&"save_graph")
	return true


## Preserves unnamed work when the editor's Save All / Save and Quit cannot show a file picker.
func save_recovery(recovery_path: String = RECOVERY_PATH) -> bool:
	var error := ResourceSaver.save(graph, recovery_path)
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
	var scene_errors := validate_scene()
	if not scene_errors.is_empty(): return _fail("\n".join(scene_errors))
	var result := XREBlueprintCompiler.compile(graph)
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
## scene becomes its Target and is followed through renames. Returns the new
## block's ID, or -1 if the edit was refused.
func insert_block(block: Dictionary, position: Vector2, wire: Dictionary = {}, target: Node = null, title: String = "Add Block") -> int:
	var state := graph.snapshot()
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


## Disconnects a specific wire.
func disconnect_blocks(from: int, from_port: int, to: int, to_port: int) -> void:
	var state := graph.snapshot()
	(state["edges"] as Array).erase({"from": from, "from_port": from_port, "to": to, "to_port": to_port})
	commit("Disconnect Ports", state)


## Edits a parameter, preserving the previous value for undo.
func set_parameter(id: int, key: String, value: Variant) -> bool:
	var state := graph.snapshot()
	for block: Dictionary in state["nodes"]:
		if block["id"] == id:
			block["params"][key] = value
			if key in ["target", "property", "signal"] or key in _provider_keys(block):
				_reflect(block, get_host(), true)
			if key == "variable" and block["kind"] == "set_variable":
				var variable := graph.find_variable(str(value))
				if not variable.is_empty(): block["params"]["value"] = variable.get("value", XREBlueprintSchema.default_value(XREBlueprintGraph.variable_type(variable)))
	return commit("Set %s" % key.capitalize(), state)


## Records a complete graph change. Used for group dragging too.
func commit(title: String, state: Dictionary) -> bool:
	last_error = ""
	var candidate := XREBlueprintGraph.new()
	candidate.restore(state)
	var errors := candidate.validate()
	if not errors.is_empty():
		return _fail("\n".join(errors))
	if state == graph.snapshot():
		return true
	history.create_action("Blueprints: " + title)
	# Weak references in history preserve chosen identities across scene renames,
	# without a reference cycle between this document and its UndoRedo object.
	history.add_do_method(_restore_bound.bind(weakref(self), state.duplicate(true), _binding_snapshot(state)))
	history.add_undo_method(_restore_bound.bind(weakref(self), graph.snapshot(), _targets.duplicate()))
	history.commit_action()
	_record(StringName(title.to_snake_case()))
	return true


static func _restore_bound(ref: WeakRef, state: Dictionary, bindings: Dictionary) -> void:
	var document := ref.get_ref() as XREBlueprintDocument
	if document == null: return
	document._targets.assign(bindings)
	document._bound_paths.clear()
	for block: Dictionary in state["nodes"]:
		var params: Dictionary = block["params"]
		if params.has("target"): document._bound_paths[block["id"]] = params["target"]
	document.graph.restore(state)
	document.refresh_bindings()


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
func choose_target(id: int, node: Node) -> bool:
	var host := get_host()
	if host == null: return _fail("Choose the script host first.")
	if not scene_nodes().has(node): return _fail("The target is outside the edited scene.")
	var problem := XREBlueprintSchema.target_kind_problem(graph.find_node(id), node)
	if not problem.is_empty(): return _fail(problem)
	if not set_parameter(id, "target", str(host.get_path_to(node))): return false
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
	candidate.restore(state)
	if candidate.validate().is_empty() and state != graph.snapshot():
		graph.restore(state)
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


## Takes the start value out of variable [param name], keeping its type
## (D-054): the box is empty, and the build reports it until a value is back.
func clear_variable_value(name: String) -> bool:
	var state := graph.snapshot()
	for variable: Dictionary in state["variables"]:
		if variable["name"] == name and variable.has("value"):
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
