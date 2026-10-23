extends SceneTree
## Headless model, compiler, generated-runtime and document tests for the standalone addon.

var _checks := 0
var _failures := 0

class Emitter extends Node:
	signal text_event(value: String)
	signal body_event(body: Node2D)
	signal move_event(value: Vector2)

class Target extends Node:
	var writes: Array[String] = []
	var message: String = "":
		set(value):
			message = value
			writes.append(value)

class NumericStatus extends Node:
	var text: int = 42

class Counter extends Node:
	var total := 0

	func add(amount: int) -> int:
		total += amount
		return total

	func slow_add(amount: int) -> int:
		await get_tree().process_frame
		total += amount
		return total

class LoopTarget extends Node:
	var count := 0
	var continue_loop := true
	var pulse := false:
		set(value):
			pulse = value
			count += 1
			continue_loop = count < 1500


func _init() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("test_blueprints: FAILED " + message)


func _wait_until(predicate: Callable, timeout_msec: int = 2000) -> void:
	var deadline := Time.get_ticks_msec() + timeout_msec
	while not predicate.call() and Time.get_ticks_msec() < deadline:
		await process_frame


func _block(graph: XREBlueprintGraph, kind: String, params: Dictionary = {}) -> int:
	var id := graph.nodes.size() + 1
	var block := XREBlueprintGraph.make_node(id, kind, Vector2(id * 200, 80))
	(block["params"] as Dictionary).merge(params, true)
	graph.nodes.append(block)
	return id


func _wire(graph: XREBlueprintGraph, from: int, to: int, from_port: int = 0, to_port: int = 0) -> void:
	graph.edges.append({"from": from, "from_port": from_port, "to": to, "to_port": to_port})


func _script(graph: XREBlueprintGraph) -> GDScript:
	var result := XREBlueprintCompiler.compile(graph)
	_check((result["errors"] as PackedStringArray).is_empty(), "valid graph compiles: %s" % result["errors"])
	var script := GDScript.new()
	script.source_code = result["code"]
	_check(script.reload() == OK, "generated GDScript parses")
	return script


func _run() -> void:
	_test_validation()
	_test_document()
	_test_all_blocks_compile()
	await _test_execution()
	await _test_signal_and_tween()
	_test_types_and_scope()
	_test_scene_bindings()
	_test_target_feedback()
	_test_graph_scene_context()
	await _test_variables_and_object_argument()
	await _test_event_policies()
	await _test_execution_loops()
	await _test_restart_tween_and_errors()
	await _test_animation_wait()
	await _test_demo()
	_test_migration()
	await _test_calls()
	_test_insert_block()
	_test_actions()
	_test_operators()
	print("test_blueprints: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)


func _test_validation() -> void:
	var graph := XREBlueprintGraph.new()
	_block(graph, "ready")
	_block(graph, "branch")
	_block(graph, "boolean")
	_wire(graph, 1, 2)
	_wire(graph, 3, 2, 0, 1)
	_check(graph.validate().is_empty(), "execution and boolean wires are valid")
	var saved := graph.snapshot()
	_wire(graph, 2, 2)
	_check(graph.validate().is_empty(), "execution self-loop is valid")
	graph.restore(saved)
	_wire(graph, 1, 2)
	_check(not graph.validate().is_empty(), "duplicate execution output rejected")
	graph.restore(saved)
	graph.edges[1]["to_port"] = 0
	_check(not graph.validate().is_empty(), "boolean cannot enter execution port")
	graph.restore(saved)
	graph.edges[1]["from"] = 1000
	_check(not graph.validate().is_empty(), "dangling connection rejected")
	graph.restore(saved)
	graph.edges[0]["from_port"] = -1
	_check(not graph.validate().is_empty(), "negative port rejected")
	graph.restore(saved)
	graph.nodes[0]["id"] = 2
	_check(not graph.validate().is_empty(), "duplicate IDs rejected")
	graph.restore(saved)
	graph.nodes[0]["kind"] = "unknown"
	_check(not graph.validate().is_empty(), "unknown blocks rejected without crashing")
	graph.restore(saved)
	graph.nodes[1]["params"] = {}
	_check(graph.validate().is_empty(), "a port's value may be taken out (D-054)")
	_check((XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray).is_empty(), "a wire into the empty socket gives it its value")
	graph.edges.resize(1)
	_check((XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray).has("Block #2: Condition is empty: put a token in or wire it."), "without one the build reports the empty socket")
	graph.restore(saved)
	graph.nodes[1]["params"] = {"condition": 1.0}
	_check(not graph.validate().is_empty(), "a value of the wrong type is still rejected")
	graph.restore(saved)
	graph.format_version += 1
	_check(not graph.validate().is_empty(), "future format rejected")
	graph = XREBlueprintGraph.new()
	_block(graph, "equals")
	_block(graph, "equals")
	_wire(graph, 1, 2)
	_wire(graph, 2, 1)
	_check(not graph.validate().is_empty(), "data dependency cycle rejected")
	graph = XREBlueprintGraph.new()
	_block(graph, "delay", {"seconds": -1.0})
	_check(not graph.validate().is_empty(), "negative duration rejected")
	graph.nodes[0]["params"]["seconds"] = "1"
	_check(not graph.validate().is_empty(), "text duration rejected")
	_check(not XREBlueprintGraph.is_literal(INF), "infinite literal rejected")
	_check(not XREBlueprintGraph.is_literal(null), "null literal rejected")
	graph = XREBlueprintGraph.new()
	_block(graph, "value")
	_block(graph, "value")
	_block(graph, "print")
	_wire(graph, 1, 3, 0, 1)
	_wire(graph, 2, 3, 0, 1)
	_check(not graph.validate().is_empty(), "two data sources on one input rejected")
	var result := XREBlueprintCompiler.compile(graph)
	_check(result["code"] == "", "invalid graph produces no executable output")


func _test_document() -> void:
	var doc := XREBlueprintDocument.new()
	_check(not doc.is_dirty(), "new document is clean")
	doc.add_block("print", Vector2(200, 80))
	_check(doc.graph.nodes.size() == 2 and doc.is_dirty(), "adding block creates an edit")
	_check(doc.connect_blocks(1, 0, 2, 0), "document accepts valid connection")
	var before := doc.graph.snapshot()
	_check(doc.connect_blocks(2, 0, 2, 0), "document accepts an execution cycle")
	doc.undo()
	_check(doc.graph.snapshot() == before, "undo removes the back edge without changing the forward edge")
	doc.redo()
	_check(doc.graph.edges.size() == 2, "redo restores the execution cycle")
	doc.undo()
	_check(not doc.connect_blocks(1, 0, 2, 0), "document still rejects an occupied execution output")
	_check(doc.graph.snapshot() == before, "rejected operation is atomic")
	doc.remove_blocks([2])
	_check(doc.graph.nodes.size() == 1 and doc.graph.edges.is_empty(), "delete also removes incident wires")
	doc.undo()
	_check(doc.graph.snapshot() == before, "undo restores block and wire together")
	doc.redo()
	_check(doc.graph.nodes.size() == 1, "redo deletes again")
	doc.undo()
	DirAccess.make_dir_recursive_absolute("res://build/blueprint_tests")
	var path := "res://build/blueprint_tests/roundtrip.tres"
	_check(doc.save_graph(path), "resource saves")
	_check(not doc.is_dirty(), "saved state is clean")
	doc.set_parameter(2, "value", "changed")
	_check(doc.is_dirty(), "parameter change marks dirty")
	doc.undo()
	_check(not doc.is_dirty(), "undo to saved state clears dirty")
	var loaded := XREBlueprintDocument.new()
	_check(loaded.open_graph(path), "resource reopens")
	_check(loaded.graph.snapshot() == doc.graph.snapshot(), "round trip preserves graph and positions")
	_check(loaded.build(), "document builds a runtime script")
	var output := loaded.script_path()
	var generated := FileAccess.get_file_as_string(output)
	_check(generated.begins_with(XREBlueprintCompiler.HEADER), "output has ownership marker")
	var file := FileAccess.open(output, FileAccess.WRITE)
	file.store_string("extends Node\n# Handwritten script\n")
	file.close()
	_check(not loaded.build(), "build protects handwritten output")
	_check(FileAccess.get_file_as_string(output).contains("Handwritten"), "protected script is unchanged")
	DirAccess.remove_absolute(output)
	_check(loaded.build(), "rebuild succeeds after protected file is removed")
	loaded.set_parameter(2, "value", "unsaved")
	_check(loaded.open_graph(path), "reopen discards changes")
	_check(loaded.graph.snapshot() == doc.graph.snapshot(), "resource loader cache does not keep discarded edits")
	var recovery := "res://build/blueprint_tests/recovery.tres"
	loaded.set_parameter(2, "value", "recover me")
	_check(loaded.save_recovery(recovery), "unnamed work can be saved for recovery")
	var restored := XREBlueprintDocument.new()
	_check(restored.recover(recovery), "draft restores")
	_check(restored.path.is_empty() and restored.is_dirty(), "recovered graph still requires Save As")
	_check(restored.graph.find_node(2)["params"]["value"] == "recover me", "recovery preserves edits")
	restored.clear_recovery(recovery)
	_check(not FileAccess.file_exists(recovery), "explicit discard removes recovery file")


func _test_all_blocks_compile() -> void:
	var graph := XREBlueprintGraph.new()
	graph.variables.append({"name": "flag", "value": false})
	var kinds: Array = XREBlueprintGraph.BLOCKS.keys().filter(func(kind: String) -> bool: return kind != "call")
	kinds.append_array(XREBlueprintGraph.PRESETS.keys())
	for kind: String in kinds:
		_block(graph, kind, {"variable": "flag"} if kind in ["get_variable", "set_variable"] else {})
	var first := XREBlueprintCompiler.compile(graph)
	var second := XREBlueprintCompiler.compile(graph)
	_check(first["code"] == second["code"], "code generation is deterministic")
	_script(graph)
	for literal: Variant in ["quote\"\nline\\path", true, 2.5, Vector2(2, 3), Vector3(4, 5, 6)]:
		graph = XREBlueprintGraph.new()
		_block(graph, "value", {"value": literal})
		var script := _script(graph)
		var instance := Node.new()
		instance.set_script(script)
		_check(instance.call("_bp_value1") == literal, "literal round trip: %s" % literal)
		instance.free()


func _test_execution() -> void:
	var graph := XREBlueprintGraph.new()
	_block(graph, "ready")
	_block(graph, "branch")
	_block(graph, "equals", {"a": true, "b": true})
	_block(graph, "get_property", {"target": "Switch", "property": "button_pressed"})
	_block(graph, "set_property", {"target": "Status", "property": "text", "value": "open"})
	_block(graph, "set_property", {"target": "Status", "property": "text", "value": "closed"})
	_wire(graph, 1, 2)
	_wire(graph, 4, 3)
	_wire(graph, 3, 2, 0, 1)
	_wire(graph, 2, 5)
	_wire(graph, 2, 6, 1)
	var scene := Node.new()
	scene.set_script(_script(graph))
	var button := CheckButton.new()
	button.name = "Switch"
	button.button_pressed = true
	scene.add_child(button)
	var label := Label.new()
	label.name = "Status"
	scene.add_child(label)
	root.add_child(scene)
	_check(label.text == "open", "Ready executes true branch against scene nodes")
	button.button_pressed = false
	scene.call("_bp_event1")
	_check(label.text == "closed", "data reads are live and false branch executes")
	scene.queue_free()
	await process_frame


func _test_types_and_scope() -> void:
	var graph := XREBlueprintGraph.new()
	_block(graph, "value", {"value": "wrong"})
	_block(graph, "set_property", {"property": "position", "value": Vector2.ZERO})
	graph.nodes[1]["property_type"] = TYPE_VECTOR2
	_wire(graph, 1, 2, 0, 1)
	_check(not graph.validate().is_empty(), "text cannot connect to a Vector2 property")
	graph.nodes[0]["params"]["value"] = Vector2.ONE
	_check(graph.validate().is_empty(), "Vector2 connects to Vector2")
	graph.edges.clear()
	graph.nodes[1]["params"]["value"] = "wrong"
	_check(not (XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray).is_empty(), "invalid property literal is diagnosed during compilation")
	_check(XREBlueprintGraph.ports_compatible(graph.INTEGER, graph.NUMBER), "integer widens to float")
	_check(not XREBlueprintGraph.ports_compatible(graph.NUMBER, graph.INTEGER), "float cannot narrow to integer implicitly")
	graph = XREBlueprintGraph.new()
	_block(graph, "signal")
	graph.nodes[0]["arguments"] = [{"name": "value", "type": TYPE_BOOL}]
	_block(graph, "ready")
	_block(graph, "branch")
	_wire(graph, 1, 3)
	_wire(graph, 1, 3, 1, 1)
	_check((XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray).is_empty(), "argument is available in its own event")
	_wire(graph, 2, 3)
	_check(not (XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray).is_empty(), "argument cannot leak into another event's chain")
	graph = XREBlueprintGraph.new()
	graph.format_version = 1
	graph.nodes.append({"id": 1, "kind": "signal", "position": Vector2.ZERO, "params": {"target": ".", "signal": "ready"}})
	graph.upgrade()
	_check(graph.format_version == XREBlueprintGraph.FORMAT_VERSION and graph.nodes[0]["params"]["policy"] == "parallel", "v1 migration preserves parallel behavior")
	_check(graph.validate().is_empty(), "migrated graph is valid")


func _test_scene_bindings() -> void:
	var scene := Node.new()
	var door := Node2D.new()
	door.name = "Door"
	scene.add_child(door)
	root.add_child(scene)
	var doc := XREBlueprintDocument.new()
	doc.set_scene_root(scene)
	doc.add_block("tween", Vector2.ZERO)
	_check(doc.choose_target(2, door), "target can be selected from scene nodes")
	_check(doc.graph.find_node(2)["property_type"] == TYPE_VECTOR2, "property schema comes from selected target")
	_check(doc.graph.find_node(2)["params"]["value"] is Vector2 and doc.graph.ports(doc.graph.find_node(2), true)[2][1] == XREBlueprintGraph.VECTOR2, "the tweened value takes the property's type")
	var solid := Node3D.new()
	solid.name = "Solid"
	scene.add_child(solid)
	doc.set_parameter(2, "property", "rotation")
	doc.choose_target(2, solid)
	_check(doc.graph.find_node(2)["params"]["value"] is Vector3 and doc.graph.find_node(2)["property_type"] == TYPE_VECTOR3, "another target's property changes the value's type")
	doc.choose_target(2, door)
	doc.set_parameter(2, "property", "position")
	solid.free()
	_check(doc.scene_nodes().has(door), "scene picker includes child")
	door.name = "RenamedDoor"
	doc.refresh_bindings()
	_check(doc.graph.find_node(2)["params"]["target"] == "RenamedDoor", "rename follows bound node identity")
	doc.set_parameter(2, "seconds", 2.0)
	door.name = "RenamedAgain"
	doc.refresh_bindings()
	doc.undo()
	_check(doc.graph.find_node(2)["params"]["target"] == "RenamedAgain", "undo keeps target identity after a later scene rename")
	var group := Node.new()
	group.name = "Group"
	scene.add_child(group)
	door.reparent(group)
	doc.refresh_bindings()
	_check(doc.graph.find_node(2)["params"]["target"] == "Group/RenamedAgain", "reparent follows bound node identity")
	_check(doc.set_host_node(group), "host can be selected from the tree")
	_check(doc.graph.find_node(2)["params"]["target"] == "RenamedAgain", "target stays correct when host changes")
	doc.undo()
	_check(doc.get_host() == scene, "host selection is undoable")
	_check(doc.set_variable("has_key", false), "variable can be added")
	_check(doc.clear_variable_value("has_key") and XREBlueprintGraph.variable_type(doc.graph.find_variable("has_key")) == TYPE_BOOL, "a variable's start value can be taken out, keeping its type")
	_check((XREBlueprintCompiler.compile(doc.graph)["errors"] as PackedStringArray).has("Variable has_key has no start value: put a token in its box."), "the build reports an empty box")
	_check(doc.set_variable("has_key", true) and doc.graph.find_variable("has_key")["value"] == true, "a value goes back into the box")
	doc.add_block("get_variable", Vector2.ZERO)
	_check(not doc.remove_variable("has_key"), "referenced variable cannot be deleted silently")
	door.free()
	_check(not doc.validate_scene().is_empty(), "deleted target is diagnosed before build")
	scene.free()


func _test_target_feedback() -> void:
	var scene := Node.new()
	var label := Label.new()
	label.name = "Status"
	scene.add_child(label)
	var player := AnimationPlayer.new()
	player.name = "Animations"
	var library := AnimationLibrary.new()
	var clip := Animation.new()
	library.add_animation("open", clip)
	player.add_animation_library("", library)
	scene.add_child(player)
	var audio := AudioStreamPlayer.new()
	audio.name = "Audio"
	scene.add_child(audio)
	var body := Node2D.new()
	body.name = "Body"
	scene.add_child(body)
	root.add_child(scene)
	var doc := XREBlueprintDocument.new()
	doc.set_scene_root(scene)
	doc.add_block("play_animation", Vector2.ZERO)
	_check(doc.target_problem(2, "NoSuchNode") == "missing target", "missing target uses the exact requested message")
	_check(doc.target_problem(2, "") == "missing target", "empty target never resolves to the script host")
	_check(doc.target_problem(2, "Body") == "requires AnimationPlayer", "animation rejects an existing node of the wrong type")
	_check(doc.target_problem(2, "Animations").is_empty(), "animation accepts a player with the selected clip")
	_check(doc.target_suggestions(2, "ani") == PackedStringArray(["Animations"]), "completion finds a suitable partial path without case sensitivity")
	_check(not doc.choose_target(2, body), "tree selection refuses a fundamentally unsuitable target")
	_check(doc.choose_target(2, player), "tree accepts an AnimationPlayer")
	doc.add_block("play_sound", Vector2.ZERO)
	_check(doc.target_problem(3, "Body") == "requires AudioStreamPlayer, AudioStreamPlayer2D or AudioStreamPlayer3D", "sound rejects unrelated nodes")
	_check(doc.target_suggestions(3, "") == PackedStringArray(["Audio"]), "sound completion includes only audio players")
	doc.add_block("set_property", Vector2.ZERO)
	doc.set_parameter(4, "property", "text")
	_check(doc.target_problem(4, "Body") == "missing property: text", "property action explains missing members")
	_check(doc.target_problem(4, "Status").is_empty(), "property action accepts a suitable label")
	doc.add_block("tween", Vector2.ZERO)
	doc.set_parameter(5, "property", "visible")
	_check(doc.target_problem(5, "Body").begins_with("property cannot be tweened"), "tween rejects a boolean property")
	doc.add_block("signal", Vector2.ZERO)
	_check(doc.target_problem(6, "Status").begins_with("missing signal"), "signal target must expose the selected signal")
	var outside := Node.new()
	root.add_child(outside)
	_check(doc.target_problem(2, str(outside.get_path())) == "missing target", "targets cannot address editor/runtime nodes outside the scene")
	outside.free()
	doc.set_parameter(2, "target", "")
	doc.refresh_bindings()
	_check(doc.graph.find_node(2)["params"]["target"] == "", "binding refresh never silently replaces an empty draft with the host")
	_check((XREBlueprintCompiler.compile(doc.graph)["errors"] as PackedStringArray).has("Block #2: missing target."), "compiler blocks an empty literal even without scene validation")
	_check(doc.validate_scene().has("Block #2: missing target."), "build and field share the missing-target message")
	doc.add_block("signal", Vector2.ZERO)
	doc.graph.find_node(7)["arguments"] = [{"name": "object", "type": TYPE_OBJECT}]
	doc.add_block("set_property", Vector2.ZERO)
	doc.graph.find_node(8)["property_type"] = TYPE_OBJECT
	doc.set_parameter(8, "target", "")
	_check(doc.connect_blocks(7, 1, 8, 1), "object data can feed a property value input")
	_check(not doc.target_is_connected(8), "an object property value never replaces the literal target")
	_check((XREBlueprintCompiler.compile(doc.graph)["errors"] as PackedStringArray).has("Block #8: missing target."), "object value connection cannot bypass missing target validation")
	doc.disconnect_blocks(7, 1, 8, 1)
	_check(doc.connect_blocks(7, 1, 8, 2) and doc.target_is_connected(8), "only the Target input supplies a dynamic target")
	_check(not (XREBlueprintCompiler.compile(doc.graph)["errors"] as PackedStringArray).has("Block #8: missing target."), "connected Target permits an empty optional sample path")
	scene.free()


func _test_graph_scene_context() -> void:
	var owner := Node.new()
	owner.scene_file_path = "res://build/blueprint_tests/owner.tscn"
	var original := Label.new()
	original.name = "Status"
	owner.add_child(original)
	root.add_child(owner)
	var other := Node.new()
	other.scene_file_path = "res://build/blueprint_tests/other.tscn"
	var unrelated := NumericStatus.new()
	unrelated.name = "Status"
	other.add_child(unrelated)
	root.add_child(other)
	var doc := XREBlueprintDocument.new()
	doc.set_scene_root(owner)
	doc.add_block("set_property", Vector2.ZERO)
	doc.set_parameter(2, "property", "text")
	_check(doc.choose_target(2, original), "graph target is bound in its owner scene")
	var saved_path := "res://build/blueprint_tests/scene_context.tres"
	_check(doc.save_graph(saved_path), "graph owner metadata can be saved")
	var before := doc.graph.snapshot()
	doc.update_active_scene(other)
	doc.refresh_bindings()
	_check(not doc.scene_context_active(), "another active scene does not become the graph owner")
	_check(doc.graph.snapshot() == before and not doc.is_dirty(), "tab switch cannot alter targets, types or saved graph state")
	_check(doc.graph.find_node(2)["property_type"] == TYPE_STRING, "same-named numeric property in another scene cannot replace the cached type")
	_check(doc.target_problem(2, "Status") == "Graph belongs to owner.tscn", "inactive scene has neutral owner guidance")
	_check(doc.scene_nodes().is_empty() and doc.target_suggestions(2, "Stat").is_empty(), "inactive scene cannot offer unrelated nodes as targets")
	_check(not doc.choose_target(2, unrelated), "picking a node from another scene is rejected")
	doc.update_active_scene(owner)
	_check(doc.scene_context_active() and doc.resolve_target("Status") == original, "returning restores the actual original target")
	_check(doc.graph.snapshot() == before, "returning to owner preserves the graph exactly")
	var reopened := XREBlueprintDocument.new()
	reopened.update_active_scene(other)
	_check(reopened.open_graph(saved_path), "graph reopens while another scene is active")
	_check(not reopened.scene_context_active() and reopened.graph.snapshot() == before, "saved owner prevents reopening against the wrong scene")
	reopened.update_active_scene(owner)
	_check(reopened.resolve_target("Status") == original, "saved owner resumes when its scene becomes active")
	owner.free()
	doc.update_active_scene(other)
	_check(doc.scene_context_message() == "Graph belongs to owner.tscn", "closing owner keeps its identity instead of adopting the remaining scene")
	var replacement := Node.new()
	replacement.scene_file_path = "res://build/blueprint_tests/owner.tscn"
	var replacement_status := Label.new()
	replacement_status.name = "Status"
	replacement.add_child(replacement_status)
	root.add_child(replacement)
	doc.update_active_scene(replacement)
	_check(doc.resolve_target("Status") == replacement_status, "reopening owner binds its new node instances")
	replacement_status.free()
	_check(doc.target_problem(2, "Status") == "missing target", "a genuinely deleted target still reports missing target in its own scene")
	replacement.free()
	var unsaved := Node.new()
	root.add_child(unsaved)
	var unsaved_doc := XREBlueprintDocument.new()
	unsaved_doc.set_scene_root(unsaved)
	unsaved_doc.add_block("print", Vector2.ZERO)
	var unsaved_before := unsaved_doc.graph.snapshot()
	unsaved.free()
	unsaved_doc.update_active_scene(other)
	_check(not unsaved_doc.scene_context_active() and unsaved_doc.graph.snapshot() == unsaved_before, "closing an unsaved owner also cannot adopt another scene")
	other.free()


func _test_variables_and_object_argument() -> void:
	var graph := XREBlueprintGraph.new()
	graph.variables.append({"name": "has_key", "value": false})
	_block(graph, "signal", {"target": "Emitter", "signal": "body_event"})
	graph.nodes[0]["arguments"] = [{"name": "body", "type": TYPE_OBJECT, "class_name": "Node2D"}]
	_block(graph, "set_variable", {"variable": "has_key", "value": true})
	_block(graph, "branch")
	_block(graph, "get_variable", {"variable": "has_key"})
	_block(graph, "set_property", {"property": "position", "value": Vector2(10, 20)})
	graph.nodes[4]["property_type"] = TYPE_VECTOR2
	_wire(graph, 1, 2)
	_wire(graph, 2, 3)
	_wire(graph, 4, 3, 0, 1)
	_wire(graph, 3, 5)
	_wire(graph, 1, 5, 1, 2)
	var script := _script(graph)
	var scene := Node.new()
	scene.set_script(script)
	var emitter := Emitter.new()
	emitter.name = "Emitter"
	scene.add_child(emitter)
	var body := Node2D.new()
	scene.add_child(body)
	root.add_child(scene)
	emitter.body_event.emit(body)
	_check(body.position == Vector2(10, 20), "object signal argument selects the actual event body")
	_check(scene.get("_bp_var_has_key") == true, "variable stores state across actions")
	var other := Node.new()
	other.set_script(script)
	_check(other.get("_bp_var_has_key") == false, "variables belong to individual graph instances")
	other.free()
	scene.queue_free()
	await process_frame


func _test_event_policies() -> void:
	for policy: String in ["parallel", "ignore", "restart"]:
		var graph := XREBlueprintGraph.new()
		_block(graph, "signal", {"target": "Emitter", "signal": "text_event", "policy": policy})
		graph.nodes[0]["arguments"] = [{"name": "value", "type": TYPE_STRING}]
		_block(graph, "delay", {"seconds": 0.02})
		_block(graph, "set_property", {"target": "Target", "property": "message", "value": ""})
		graph.nodes[2]["property_type"] = TYPE_STRING
		_wire(graph, 1, 2)
		_wire(graph, 2, 3)
		_wire(graph, 1, 3, 1, 1)
		var scene := Node.new()
		scene.set_script(_script(graph))
		var emitter := Emitter.new()
		emitter.name = "Emitter"
		scene.add_child(emitter)
		var target := Target.new()
		target.name = "Target"
		scene.add_child(target)
		root.add_child(scene)
		emitter.text_event.emit("A")
		emitter.text_event.emit("B")
		await create_timer(0.1).timeout
		if policy == "parallel": _check(target.writes.size() == 2 and target.writes.has("A") and target.writes.has("B"), "parallel invocations preserve separate arguments after Delay")
		elif policy == "ignore": _check(target.writes == ["A"], "ignore policy keeps the first invocation")
		else: _check(target.writes == ["B"], "restart cancels old continuation")
		_check((scene.get("_bp_runs") as Array).is_empty(), "event invocations are released")
		scene.queue_free()
		await process_frame


func _test_execution_loops() -> void:
	var graph := XREBlueprintGraph.new()
	graph.variables.append({"name": "finished", "value": false})
	_block(graph, "ready")
	_block(graph, "branch")
	_block(graph, "set_property", {"target": "Target", "property": "pulse", "value": true})
	graph.nodes[2]["property_type"] = TYPE_BOOL
	_block(graph, "set_variable", {"variable": "finished", "value": true})
	_block(graph, "get_property", {"target": "Target", "property": "continue_loop"})
	graph.nodes[4]["property_type"] = TYPE_BOOL
	_wire(graph, 1, 2)
	_wire(graph, 2, 3)
	_wire(graph, 3, 2)
	_wire(graph, 2, 4, 1)
	_wire(graph, 5, 2, 0, 1)
	var scene := Node.new()
	scene.set_script(_script(graph))
	var target := LoopTarget.new()
	target.name = "Target"
	scene.add_child(target)
	root.add_child(scene)
	_check(target.count > 0 and target.count < 1500, "synchronous loop yields before consuming its whole iteration count")
	var first_count := target.count
	await process_frame
	await process_frame
	_check(target.count > first_count, "other frames continue while a synchronous back edge executes")
	await _wait_until(func() -> bool: return scene.get("_bp_var_finished") == true)
	_check(target.count == 1500 and scene.get("_bp_var_finished") == true, "long loop re-evaluates condition and exits through False without recursive stack growth")
	_check((scene.get("_bp_runs") as Array).is_empty(), "completed loop releases its event invocation")
	scene.queue_free()
	await process_frame
	for policy: String in ["ignore", "restart"]:
		graph = XREBlueprintGraph.new()
		_block(graph, "signal", {"target": "Emitter", "signal": "text_event", "policy": policy})
		_block(graph, "branch")
		_wire(graph, 1, 2)
		_wire(graph, 2, 2)
		scene = Node.new()
		scene.set_script(_script(graph))
		var emitter := Emitter.new()
		emitter.name = "Emitter"
		scene.add_child(emitter)
		root.add_child(scene)
		emitter.text_event.emit("A")
		emitter.text_event.emit("B")
		await process_frame
		await process_frame
		_check((scene.get("_bp_runs") as Array).size() == 1, "endless synchronous loop respects " + policy + " event policy")
		root.remove_child(scene)
		await process_frame
		_check((scene.get("_bp_runs") as Array).is_empty(), "leaving the scene cancels an endless loop")
		scene.free()
	graph = XREBlueprintGraph.new()
	_block(graph, "ready")
	_block(graph, "delay", {"seconds": 0.005})
	_block(graph, "set_property", {"target": "Target", "property": "pulse", "value": true})
	_wire(graph, 1, 2)
	_wire(graph, 2, 3)
	_wire(graph, 3, 2)
	scene = Node.new()
	scene.set_script(_script(graph))
	target = LoopTarget.new()
	target.name = "Target"
	scene.add_child(target)
	root.add_child(scene)
	await create_timer(0.04).timeout
	_check(target.count >= 2, "Delay inside a back edge resumes on successive iterations")
	scene.queue_free()
	await process_frame


func _test_animation_wait() -> void:
	var graph := XREBlueprintGraph.new()
	_block(graph, "signal", {"target": "Emitter", "signal": "text_event", "policy": "restart"})
	_block(graph, "play_animation", {"target": "Player", "animation": "open", "wait": true, "timeout": 0.12})
	_block(graph, "set_property", {"target": "Target", "property": "message", "value": "finished"})
	_wire(graph, 1, 2)
	_wire(graph, 2, 3)
	var scene := Node.new()
	scene.set_script(_script(graph))
	var errors: Array[String] = []
	scene.connect("blueprint_error", func(id: int, message: String) -> void: errors.append("%d:%s" % [id, message]))
	var emitter := Emitter.new()
	emitter.name = "Emitter"
	scene.add_child(emitter)
	var player := AnimationPlayer.new()
	player.name = "Player"
	var animation := Animation.new()
	animation.length = 0.06
	var library := AnimationLibrary.new()
	library.add_animation("open", animation)
	player.add_animation_library("", library)
	scene.add_child(player)
	var target := Target.new()
	target.name = "Target"
	scene.add_child(target)
	root.add_child(scene)
	emitter.text_event.emit("A")
	_check(target.message == "", "Play Animation wait delays its continuation")
	await create_timer(0.15).timeout
	_check(target.message == "finished" and errors.is_empty(), "named animation completion resumes the chain")
	target.writes.clear()
	player.speed_scale = 0.0
	emitter.text_event.emit("A")
	await create_timer(0.2).timeout
	_check(target.writes.is_empty() and errors.size() == 1 and errors[0].contains("timed out"), "animation wait has a bounded timeout")
	player.speed_scale = 1.0
	errors.clear()
	emitter.text_event.emit("A")
	await process_frame
	player.stop()
	await create_timer(0.05).timeout
	_check(target.writes.is_empty() and errors.size() == 1 and errors[0].begins_with("2:"), "interruption reports block ID and cancels continuation")
	errors.clear()
	animation.loop_mode = Animation.LOOP_LINEAR
	emitter.text_event.emit("A")
	_check(errors.size() == 1 and errors[0].contains("looping"), "looping animation wait fails immediately")
	animation.loop_mode = Animation.LOOP_NONE
	errors.clear()
	emitter.text_event.emit("A")
	await process_frame
	player.queue_free()
	await create_timer(0.05).timeout
	_check(target.writes.is_empty() and errors.size() == 1, "deleted animation target stops continuation safely")
	scene.queue_free()
	await process_frame


func _test_restart_tween_and_errors() -> void:
	var graph := XREBlueprintGraph.new()
	_block(graph, "signal", {"target": "Emitter", "signal": "move_event", "policy": "restart"})
	graph.nodes[0]["arguments"] = [{"name": "value", "type": TYPE_VECTOR2}]
	_block(graph, "tween", {"target": "Door", "property": "position", "seconds": 0.08})
	graph.nodes[1]["property_type"] = TYPE_VECTOR2
	_block(graph, "set_property", {"target": "Target", "property": "message", "value": "finished"})
	_wire(graph, 1, 2)
	_wire(graph, 1, 2, 1, graph.input_port(graph.nodes[1], "value"))
	_wire(graph, 2, 3)
	var scene := Node.new()
	scene.set_script(_script(graph))
	var errors: Array[String] = []
	scene.connect("blueprint_error", func(_id: int, message: String) -> void: errors.append(message))
	var emitter := Emitter.new()
	emitter.name = "Emitter"
	scene.add_child(emitter)
	var door := Node2D.new()
	door.name = "Door"
	scene.add_child(door)
	var target := Target.new()
	target.name = "Target"
	scene.add_child(target)
	root.add_child(scene)
	emitter.move_event.emit(Vector2(100, 0))
	await process_frame
	emitter.move_event.emit(Vector2(-100, 0))
	await create_timer(0.2).timeout
	_check(door.position.is_equal_approx(Vector2(-100, 0)), "restart kills old Tween and completes the new destination")
	_check(target.writes == ["finished"] and errors.is_empty(), "cancelled Tween never executes its old continuation")
	target.writes.clear()
	emitter.move_event.emit(Vector2(100, 0))
	await process_frame
	door.queue_free()
	await create_timer(0.1).timeout
	_check(target.writes.is_empty() and not errors.is_empty(), "deleted Tween target cancels its continuation")
	scene.queue_free()
	await process_frame


func _test_demo() -> void:
	var packed := load("res://benchmarks/blueprint_door.tscn") as PackedScene
	var scene := packed.instantiate()
	root.add_child(scene)
	var button := scene.get_node("Switch") as CheckButton
	var status := scene.get_node("Status") as Label
	var door := scene.get_node("Door") as Control
	button.button_pressed = true
	_check(status.text == "CLOSED", "demo keeps its status until opening finishes")
	await create_timer(0.75).timeout
	_check(status.text == "OPEN" and door.position.is_equal_approx(Vector2(660, 220)), "demo graph opens the door after the animation")
	button.button_pressed = false
	await process_frame
	button.button_pressed = true
	await create_timer(0.75).timeout
	_check(status.text == "OPEN", "demo rapid toggle cannot resume an obsolete close chain")
	button.button_pressed = false
	await create_timer(0.75).timeout
	_check(status.text == "CLOSED" and door.position.is_equal_approx(Vector2(480, 220)), "demo graph closes the door")
	scene.queue_free()
	await process_frame
	var graph := XREBlueprintGraph.new()
	var errors: Array[String] = []
	_block(graph, "ready")
	_block(graph, "set_property", {"target": ".", "property": "missing", "value": 1.0})
	_wire(graph, 1, 2)
	scene = Node.new()
	scene.set_script(_script(graph))
	errors.clear()
	scene.connect("blueprint_error", func(id: int, message: String) -> void: errors.append("%d:%s" % [id, message]))
	root.add_child(scene)
	_check(errors.size() == 1 and errors[0].begins_with("2:Missing property"), "missing property produces a block-specific error without unsafe access")
	scene.queue_free()
	await process_frame


func _test_signal_and_tween() -> void:
	var graph := XREBlueprintGraph.new()
	_block(graph, "signal", {"target": "Switch", "signal": "toggled"})
	_block(graph, "delay", {"seconds": 0.01})
	_block(graph, "tween", {"target": "Door", "property": "position", "value": Vector2(90, 20), "seconds": 0.02})
	_block(graph, "set_property", {"target": "Status", "property": "text", "value": "finished"})
	_wire(graph, 1, 2)
	_wire(graph, 2, 3)
	_wire(graph, 3, 4)
	var scene := Node.new()
	scene.set_script(_script(graph))
	var button := CheckButton.new()
	button.name = "Switch"
	scene.add_child(button)
	var door := Node2D.new()
	door.name = "Door"
	scene.add_child(door)
	var label := Label.new()
	label.name = "Status"
	scene.add_child(label)
	root.add_child(scene)
	button.button_pressed = true
	_check(label.text == "", "Delay yields before continuing")
	await _wait_until(func() -> bool: return label.text == "finished")
	_check(door.position.is_equal_approx(Vector2(90, 20)), "signal with arguments runs tween to completion")
	_check(label.text == "finished", "continuation waits for tween")
	scene.queue_free()
	await process_frame


func _test_migration() -> void:
	var graph := XREBlueprintGraph.new()
	graph.format_version = 2
	graph.nodes.append({"id": 1, "kind": "ready", "position": Vector2.ZERO, "params": {"policy": "restart"}})
	graph.nodes.append({"id": 2, "kind": "tween", "position": Vector2(200, 0), "params": {"target": "Door", "property": "position", "value": Vector2.ONE, "seconds": 0.5}, "property_type": TYPE_VECTOR2})
	graph.nodes.append({"id": 3, "kind": "value", "position": Vector2(0, 200), "params": {"value": Vector2(3, 4)}})
	graph.nodes.append({"id": 4, "kind": "print", "position": Vector2(400, 0), "params": {"value": "done"}})
	graph.nodes.append({"id": 5, "kind": "boolean", "position": Vector2(0, 300), "params": {"value": false}})
	graph.nodes.append({"id": 6, "kind": "play_animation", "position": Vector2(600, 0), "params": {"target": "Player", "animation": "close", "wait": true, "timeout": 2.0}})
	_wire(graph, 1, 2)
	_wire(graph, 3, 2, 0, 1)
	_wire(graph, 2, 4)
	_wire(graph, 4, 6)
	graph.upgrade()
	_check(graph.format_version == XREBlueprintGraph.FORMAT_VERSION, "format 2 upgrades to the current format")
	var ready := graph.find_node(1)
	_check(ready["kind"] == "signal" and ready["params"]["signal"] == "ready" and ready["params"]["target"] == "." and ready["params"]["policy"] == "restart", "On Ready becomes On Signal of the host's ready, keeping its policy")
	_check(XREBlueprintGraph.title(ready) == "On Ready", "the migrated event is still titled On Ready")
	var tween := graph.find_node(2)
	_check(tween["kind"] == "call" and tween["function"]["name"] == "tween_property" and tween["params"]["seconds"] == 0.5 and tween["property_type"] == TYPE_VECTOR2, "Tween becomes a library call with its parameters")
	_check((tween["params"] as Dictionary).get("property") == "position", "Tween keeps its property")
	_check(graph.edges[1]["to_port"] == graph.input_port(tween, "value"), "a wire into Tween's Value moves to the call's value port")
	_check(graph.find_node(4)["function"]["name"] == "print" and graph.find_node(4)["params"]["value"] == "done", "Print becomes the global print")
	_check(graph.find_node(5)["kind"] == "value" and graph.find_node(5)["params"]["value"] == false, "Boolean becomes a Value")
	_check(graph.find_node(6)["params"]["animation"] == "close" and graph.find_node(6)["params"]["wait"] == true, "Play Animation keeps its animation and wait")
	_check(graph.validate().is_empty(), "the migrated graph is valid")
	_check((XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray).is_empty(), "the migrated graph compiles")


func _test_calls() -> void:
	var counter := Counter.new()
	var graph := XREBlueprintGraph.new()
	graph.variables.append({"name": "total", "value": 0})
	graph.variables.append({"name": "clamped", "value": 0.0})
	graph.variables.append({"name": "grouped", "value": false})
	_block(graph, "ready")
	var add := XREBlueprintGraph.make_call(2, XREBlueprintFunctions.script_method(counter.get_script(), "Node", "add"), Vector2.ZERO)
	add["params"]["target"] = "Counter"
	add["params"]["amount"] = 5
	graph.nodes.append(add)
	_block(graph, "set_variable", {"variable": "total", "value": 0})
	var clamp := XREBlueprintGraph.make_call(4, XREBlueprintFunctions.global("clampf"), Vector2.ZERO)
	clamp["params"]["value"] = 15.0
	clamp["params"]["min"] = 0.0
	clamp["params"]["max"] = 10.0
	graph.nodes.append(clamp)
	_block(graph, "set_variable", {"variable": "clamped", "value": 0.0})
	var group := XREBlueprintGraph.make_call(6, XREBlueprintFunctions.method("Node", "add_to_group"), Vector2.ZERO)
	group["params"]["target"] = "Counter"
	group["params"]["group"] = "enemies"
	graph.nodes.append(group)
	var check := XREBlueprintGraph.make_call(7, XREBlueprintFunctions.method("Node", "is_in_group"), Vector2.ZERO)
	check["params"]["target"] = "Counter"
	check["params"]["group"] = "enemies"
	graph.nodes.append(check)
	_block(graph, "branch")
	_block(graph, "set_variable", {"variable": "grouped", "value": true})
	_check(not XREBlueprintGraph.is_pure(add) and XREBlueprintGraph.is_pure(clamp) and XREBlueprintGraph.is_pure(check), "script methods have execution ports, const and math functions are pure")
	_check(graph.ports(add, false).size() == 2 and graph.ports(add, false)[1][0] == "Result", "a method with a result has Then and Result")
	_wire(graph, 1, 2)
	_wire(graph, 2, 3)
	_wire(graph, 2, 3, 1, 1)
	_wire(graph, 3, 5)
	_wire(graph, 4, 5, 0, 1)
	_wire(graph, 5, 6)
	_wire(graph, 6, 8)
	_wire(graph, 7, 8, 0, 1)
	_wire(graph, 8, 9)
	var scene := Node.new()
	scene.set_script(_script(graph))
	counter.name = "Counter"
	scene.add_child(counter)
	root.add_child(scene)
	_check(counter.total == 5 and scene.get("_bp_var_total") == 5, "a script method runs on its target and its result is read after it ran")
	_check(is_equal_approx(scene.get("_bp_var_clamped"), 10.0), "a pure global function computes its value on demand")
	_check(counter.is_in_group("enemies") and scene.get("_bp_var_grouped") == true, "an engine method runs and a pure method feeds a branch")
	scene.queue_free()
	await process_frame
	graph = XREBlueprintGraph.new()
	graph.variables.append({"name": "total", "value": 0})
	_block(graph, "ready")
	counter = Counter.new()
	var slow := XREBlueprintGraph.make_call(2, XREBlueprintFunctions.script_method(counter.get_script(), "Node", "slow_add"), Vector2.ZERO)
	# An inner class has no source to scan for await: the test marks the coroutine itself.
	slow["function"]["awaits"] = true
	slow["params"]["target"] = "Counter"
	slow["params"]["amount"] = 3
	graph.nodes.append(slow)
	_block(graph, "set_variable", {"variable": "total", "value": 0})
	_wire(graph, 1, 2)
	_wire(graph, 2, 3)
	_wire(graph, 2, 3, 1, 1)
	scene = Node.new()
	scene.set_script(_script(graph))
	counter.name = "Counter"
	scene.add_child(counter)
	root.add_child(scene)
	_check(scene.get("_bp_var_total") == 0, "a coroutine call is awaited before its continuation")
	await _wait_until(func() -> bool: return scene.get("_bp_var_total") == 3)
	_check(scene.get("_bp_var_total") == 3, "the awaited coroutine's result reaches the next block")
	scene.queue_free()
	await process_frame
	var print_block := XREBlueprintGraph.make_node(1, "print", Vector2.ZERO)
	_check(print_block["function"]["extra"] == 1 and (print_block["function"]["args"] as Array).is_empty(), "print's values are its extra arguments")
	var doc := XREBlueprintDocument.new()
	doc.insert_block(print_block, Vector2.ZERO)
	_check(doc.set_extra_arguments(2, 3) and doc.graph.ports(doc.graph.find_node(2), true).size() == 4, "a vararg call takes more values")
	_check(str(XREBlueprintCompiler.compile(doc.graph)["code"]).contains("print(a0, a1, a2)"), "extra values are passed in order")
	_check(doc.set_extra_arguments(2, 1), "extra values can be removed while unwired")
	var play := XREBlueprintGraph.make_call(3, XREBlueprintFunctions.method("AnimationPlayer", "play"), Vector2.ZERO)
	_check(play["function"]["args"][1]["literal"] == true and play["function"]["args"][1]["provider"] == "animation", "the animation name of play() is offered by its target")
	doc.insert_block(play, Vector2.ZERO)
	var before := doc.graph.ports(doc.graph.find_node(3), true).size()
	_check(doc.set_advanced_shown(3, true) and doc.graph.ports(doc.graph.find_node(3), true).size() == before + 3, "advanced arguments add their ports at the end")
	_check(doc.set_advanced_shown(3, false) and doc.graph.ports(doc.graph.find_node(3), true).size() == before, "advanced arguments hide again")
	var unsupported := XREBlueprintFunctions.global("bytes_to_var")
	_check(not XREBlueprintFunctions.problem(unsupported).is_empty(), "a function with an unsupported argument explains why it can't be added")


func _test_insert_block() -> void:
	var doc := XREBlueprintDocument.new()
	var print_block := XREBlueprintGraph.make_node(0, "print", Vector2.ZERO)
	var id := doc.insert_block(print_block, Vector2(300, 100), {"from": 1, "from_port": 0})
	_check(id == 2 and doc.graph.edges == [{"from": 1, "from_port": 0, "to": 2, "to_port": 0}], "a block added from an execution output is wired to its In")
	var value := doc.insert_block(XREBlueprintGraph.make_node(0, "value", Vector2.ZERO), Vector2(100, 300), {"to": 2, "to_port": 1})
	_check(doc.graph.edges.has({"from": value, "from_port": 0, "to": 2, "to_port": 1}), "a block added from a data input gives it its output")
	doc.undo()
	_check(doc.graph.nodes.size() == 2 and doc.graph.edges.size() == 1, "the block and its wire are one undo step")
	_check(doc.insert_block(XREBlueprintGraph.make_node(0, "print", Vector2.ZERO), Vector2.ZERO, {"from": 1, "from_port": 0}) == -1 and not doc.last_error.is_empty(), "an occupied execution output refuses another wire")


func _operator(graph: XREBlueprintGraph, op: String, params: Dictionary = {}) -> int:
	var id := graph.nodes.size() + 1
	var block := XREBlueprintGraph.make_operator(id, op, Vector2(id * 200, 80))
	(block["params"] as Dictionary).merge(params, true)
	graph.nodes.append(block)
	return id


## The operators (D-065): their types, a wire's type taken by the other
## literal, the menu, the generated code and its values.
func _test_operators() -> void:
	var invalid := XREBlueprintOperators.INVALID
	_check(XREBlueprintOperators.result_type("add", TYPE_INT, TYPE_INT) == TYPE_INT and XREBlueprintOperators.result_type("add", TYPE_INT, TYPE_FLOAT) == TYPE_FLOAT, "integers add to an integer, with a real to a real")
	_check(XREBlueprintOperators.result_type("multiply", TYPE_VECTOR3, TYPE_FLOAT) == TYPE_VECTOR3 and XREBlueprintOperators.result_type("multiply", TYPE_FLOAT, TYPE_COLOR) == TYPE_COLOR and XREBlueprintOperators.result_type("subtract", TYPE_VECTOR2, TYPE_VECTOR2) == TYPE_VECTOR2, "vectors and colors scale by numbers and add to their own kind")
	_check(XREBlueprintOperators.result_type("add", TYPE_VECTOR3, TYPE_FLOAT) == invalid and XREBlueprintOperators.result_type("divide", TYPE_FLOAT, TYPE_VECTOR2) == invalid and XREBlueprintOperators.result_type("modulo", TYPE_VECTOR3, TYPE_VECTOR3) == invalid, "a vector and a number don't add; a number isn't divided by a vector")
	_check(XREBlueprintOperators.result_type("add", TYPE_STRING, TYPE_STRING) == TYPE_STRING and XREBlueprintOperators.result_type("subtract", TYPE_STRING, TYPE_STRING) == invalid, "texts join with +, nothing else")
	_check(XREBlueprintOperators.result_type("less", TYPE_INT, TYPE_FLOAT) == TYPE_BOOL and XREBlueprintOperators.result_type("less", TYPE_STRING, TYPE_INT) == invalid and XREBlueprintOperators.result_type("and", TYPE_BOOL, TYPE_BOOL) == TYPE_BOOL, "order compares numbers, logic takes booleans")
	_check(XREBlueprintOperators.result_type("add", TYPE_NIL, TYPE_INT) == TYPE_NIL, "a value unknown before the game gives an unknown result")

	var graph := XREBlueprintGraph.new()
	var add := _operator(graph, "add")
	var negation := _operator(graph, "not")
	var less := _operator(graph, "less")
	var inputs := graph.ports(graph.find_node(add), true)
	_check(inputs.size() == 2 and inputs[0][1] == graph.VALUE and graph.ports(graph.find_node(add), false)[0][1] == graph.NUMBER, "Add takes any values; 0.0 + 0.0 gives a number")
	_check(graph.ports(graph.find_node(negation), true).size() == 1 and graph.ports(graph.find_node(negation), true)[0][1] == graph.BOOLEAN and not (graph.find_node(negation)["params"] as Dictionary).has("b"), "NOT has one boolean input and no B")
	_check(graph.ports(graph.find_node(less), true)[0][1] == graph.NUMBER and graph.ports(graph.find_node(less), false)[0][1] == graph.BOOLEAN, "Less compares numbers to a boolean")
	_check(graph.validate().is_empty(), "operators validate: %s" % graph.validate())
	_check(XREBlueprintGraph.title(graph.find_node(add)) == "Add" and XREBlueprintGraph.symbol(graph.find_node(add)) == "+" and XREBlueprintGraph.symbol(XREBlueprintGraph.make_node(9, "equals", Vector2.ZERO)) == "=", "an operator is titled by its name and shows its symbol; Equal shows =")
	graph.upgrade()
	_check(not (graph.find_node(negation)["params"] as Dictionary).has("b"), "an upgrade gives NOT no B")

	# A wire's type is taken by the other operand's literal, as Unreal's wildcard pins.
	var doc := XREBlueprintDocument.new()
	var sum := doc.insert_block(XREBlueprintGraph.make_operator(0, "add", Vector2.ZERO), Vector2(400, 0))
	var count := doc.insert_block(XREBlueprintGraph.make_node(0, "value", Vector2.ZERO), Vector2(0, 0))
	doc.set_parameter(count, "value", 3)
	doc.set_parameter(sum, "b", 1.0)
	_check(doc.connect_blocks(count, 0, sum, 0), "an integer wires into Add")
	_check(doc.graph.find_node(sum)["params"]["b"] is int and int(doc.graph.find_node(sum)["params"]["b"]) == 1 and doc.graph.ports(doc.graph.find_node(sum), false)[0][1] == XREBlueprintGraph.INTEGER, "B becomes the integer 1: the sum is an integer")
	var scale := doc.insert_block(XREBlueprintGraph.make_operator(0, "multiply", Vector2.ZERO), Vector2(400, 200))
	var direction := doc.insert_block(XREBlueprintGraph.make_node(0, "value", Vector2.ZERO), Vector2(0, 200))
	doc.set_parameter(direction, "value", Vector3(1, 2, 3))
	doc.connect_blocks(direction, 0, scale, 0)
	_check(doc.graph.find_node(scale)["params"]["b"] is float and doc.graph.ports(doc.graph.find_node(scale), false)[0][1] == XREBlueprintGraph.VECTOR3, "a number stays by the vector it multiplies")
	var offset := doc.insert_block(XREBlueprintGraph.make_operator(0, "add", Vector2.ZERO), Vector2(400, 400))
	doc.connect_blocks(direction, 0, offset, 1)
	_check(doc.graph.find_node(offset)["params"]["a"] == Vector3.ZERO and doc.graph.ports(doc.graph.find_node(offset), false)[0][1] == XREBlueprintGraph.VECTOR3, "a vector added: A becomes a zero vector")
	doc.undo()
	_check(doc.graph.find_node(offset)["params"]["a"] is float, "undo puts the literal back with the wire")

	# Menu: Math, Comparison with Equal first, Logic.
	var sections := XREBlueprintActions.new().sections({"chip": XREBlueprintActions.NATIVE, "graph": doc.graph})
	var titles: Array[String] = []
	for section: Dictionary in sections: titles.append(section["title"])
	var comparison: Array = sections[titles.find("Comparison")]["actions"] if titles.has("Comparison") else []
	_check(titles.has("Math") and titles.has("Logic") and not comparison.is_empty() and comparison[0]["id"] == "native:equals", "the native blocks have Math, Comparison with Equal first, and Logic: %s" % [titles])
	var found := XREBlueprintActions.flatten(XREBlueprintActions.new().sections({"chip": XREBlueprintActions.ALL, "graph": doc.graph, "query": "remainder"}))
	_check(found.size() == 1 and found[0]["id"] == "operator:modulo", "an operator is found by its search words")

	# Generated code computes them; a value that doesn't fit is an error, not a crash.
	graph = XREBlueprintGraph.new()
	var seven := _block(graph, "value", {"value": 7})
	var remainder := _operator(graph, "modulo", {"b": 3})
	_wire(graph, seven, remainder)
	var quotient := _operator(graph, "divide", {"a": 7.5, "b": 2.5})
	var scaled := _operator(graph, "multiply", {"a": Vector3(1, 2, 3), "b": 2.0})
	var ordered := _operator(graph, "greater_equal", {"a": 2, "b": 2.5})
	var both := _operator(graph, "and", {"a": true, "b": true})
	var inverse := _operator(graph, "not", {"a": true})
	var differs := _operator(graph, "not_equal", {"a": 1, "b": 1.0})
	var joined := _operator(graph, "add", {"a": "door ", "b": "open"})
	var negative := _operator(graph, "negate", {"a": Vector2(1, -2)})
	var real := _operator(graph, "modulo", {"a": 7.5, "b": 2.0})
	var any := _block(graph, "get_variable", {"variable": "anything"})
	graph.variables.append({"name": "anything", "value": 0})
	var risky := _operator(graph, "divide", {"a": 1})
	_wire(graph, any, risky, 0, 1)
	var instance := Node.new()
	instance.set_script(_script(graph))
	var problems: Array[String] = []
	instance.connect(&"blueprint_error", func(_id: int, message: String) -> void: problems.append(message))
	_check(instance.call("_bp_value%d" % remainder) == 1, "7 % 3 is 1")
	_check(is_equal_approx(float(instance.call("_bp_value%d" % quotient)), 3.0) and instance.call("_bp_value%d" % scaled) == Vector3(2, 4, 6), "7.5 ÷ 2.5 is 3; (1, 2, 3) × 2 is (2, 4, 6)")
	_check(instance.call("_bp_value%d" % ordered) == false and instance.call("_bp_value%d" % both) == true and instance.call("_bp_value%d" % inverse) == false, "2 ≥ 2.5 is false; true AND true; NOT true")
	_check(instance.call("_bp_value%d" % differs) == false and instance.call("_bp_value%d" % joined) == "door open", "1 ≠ 1.0 is false: both are numbers; texts join")
	_check(instance.call("_bp_value%d" % negative) == Vector2(-1, 2) and is_equal_approx(float(instance.call("_bp_value%d" % real)), 1.5), "negation; a real remainder")
	_check(instance.call("_bp_value%d" % risky) == null and problems.has("Division by zero."), "an integer division by a zero that came is reported: %s" % [problems])
	instance.free()
	graph = XREBlueprintGraph.new()
	_operator(graph, "divide", {"a": 1, "b": 0})
	_operator(graph, "add", {"a": Vector3.ONE, "b": "text"})
	var errors := "\n".join(XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray)
	_check(errors.contains("division by zero") and errors.contains("Add doesn't take Vector3 and String"), "the build reports a division by a literal 0 and operands an operator can't take: %s" % errors)


func _test_actions() -> void:
	var scene := Node3D.new()
	var player := AnimationPlayer.new()
	player.name = "Animations"
	scene.add_child(player)
	root.add_child(scene)
	var doc := XREBlueprintDocument.new()
	doc.set_scene_root(scene)
	doc.set_variable("door_open", false)
	var actions := XREBlueprintActions.new()
	var context := {"chip": XREBlueprintActions.CONTEXT, "node": player, "host": scene, "graph": doc.graph}
	var sections := actions.sections(context)
	var titles: Array[String] = []
	for section: Dictionary in sections: titles.append(section["title"])
	_check(titles.has("Presets") and titles.has("Animations · AnimationPlayer") and titles.has("Signals · Animations"), "an object's menu has presets, its own members and its signals: %s" % [titles])
	var all := XREBlueprintActions.flatten(sections)
	var ids: Array[String] = []
	for action: Dictionary in all: ids.append(action["id"])
	_check(ids.has("preset:play_animation") and ids.has("method:AnimationPlayer.play") and ids.has("signal:animation_finished"), "presets, methods and signals are offered")
	_check(not ids.has("method:AnimationPlayer.set_speed_scale") and ids.has("set:AnimationPlayer.speed_scale"), "property accessors are Get and Set actions, not methods")
	var preset: Dictionary = all[ids.find("preset:play_animation")]
	_check(preset["target"] == player, "a preset for the context object aims at it")
	var advanced: Dictionary = sections.filter(func(section: Dictionary) -> bool: return section["advanced"])[0]
	_check(advanced["count"] > 0 and (advanced["actions"] as Array).is_empty(), "Node and Object members wait under Advanced")
	context["query"] = "queue free"
	_check(XREBlueprintActions.flatten(actions.sections(context)).any(func(action: Dictionary) -> bool: return action["id"] == "method:Node.queue_free"), "searching includes Advanced")
	context["query"] = "anim fin"
	_check(XREBlueprintActions.flatten(actions.sections(context)).any(func(action: Dictionary) -> bool: return action["id"] == "signal:animation_finished"), "every word of a search must match")
	context["query"] = ""
	context["pin"] = {"type": XREBlueprintGraph.EXEC, "output": true}
	var after_exec := XREBlueprintActions.flatten(actions.sections(context))
	_check(not after_exec.is_empty() and after_exec.all(func(action: Dictionary) -> bool: return action["kind"] != "event" and action["kind"] != "pure"), "an execution output offers no events and no pure blocks")
	context["pin"] = {"type": XREBlueprintGraph.BOOLEAN, "output": false}
	_check(XREBlueprintActions.flatten(actions.sections(context)).all(func(action: Dictionary) -> bool: return XREBlueprintActions.fits_pin(action, XREBlueprintGraph.BOOLEAN, false)), "a boolean input offers blocks with a boolean output")
	var library := XREBlueprintActions.flatten(actions.sections({"chip": XREBlueprintActions.LIBRARY, "host": scene, "graph": doc.graph}))
	var names: Array[String] = []
	for action: Dictionary in library: names.append(action["title"])
	_check(names.has("Delay") and names.has("Tween Property") and names.has("Play Sound") and names.has("Play Animation"), "the library offers its functions by their tagged names")
	_check(not names.has("Property Info"), "static helpers of the addons are not offered without tags")
	var globals := XREBlueprintActions.flatten(actions.sections({"chip": XREBlueprintActions.GLOBAL, "graph": doc.graph, "query": "clamp"}))
	_check(globals.any(func(action: Dictionary) -> bool: return action["id"] == "global:clampf"), "global functions are searchable")
	var natives := XREBlueprintActions.flatten(actions.sections({"chip": XREBlueprintActions.NATIVE, "host": scene, "graph": doc.graph}))
	_check(natives.any(func(action: Dictionary) -> bool: return action["id"] == "native:branch") and natives.any(func(action: Dictionary) -> bool: return action["id"] == "variable:set:door_open"), "native blocks include each variable's Get and Set")
	var id := doc.insert_block(preset["block"], Vector2(200, 0), {"from": 1, "from_port": 0}, player)
	_check(id > 0 and doc.graph.find_node(id)["params"]["target"] == "Animations" and not doc.target_is_connected(id), "an action's block is added aimed at its object")
	actions.remember(preset)
	_check(actions.sections({"chip": XREBlueprintActions.CONTEXT, "node": player, "host": scene, "graph": doc.graph})[0]["title"] == "Recent", "recently added actions come first")
	scene.free()
