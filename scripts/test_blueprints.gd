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
	_test_wire_bends()
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
	await _test_demo_room()
	_test_migration()
	await _test_calls()
	_test_makers_and_time()
	_test_vectors()
	_test_insert_block()
	_test_paste_blocks()
	_test_actions()
	_test_palette_variants()
	_test_operators()
	_test_variadic_operators()
	await _test_sequence_switch()
	_test_break_make()
	await _test_functions()
	await _test_collections()
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


## The bends the VR editor keeps on a connection (D-081): placement, as a
## block's place is; checked, saved, undone, ignored by the compiler and by disconnecting.
func _test_wire_bends() -> void:
	var doc := XREBlueprintDocument.new()
	doc.add_block("print", Vector2(300, 80))
	_check(doc.connect_blocks(1, 0, 2, 0), "a wire to bend")
	var plain := doc.graph.structure_key()
	var code: String = XREBlueprintCompiler.compile(doc.graph)["code"]
	var state := doc.graph.snapshot()
	var bends := PackedVector3Array([Vector3(150, -40, 0.25), Vector3(250, 160, -0.125)])
	(state["edges"] as Array)[0]["vr_bends"] = bends
	_check(doc.commit("Bend Wire", state) and doc.graph.edges[0].get("vr_bends") == bends, "a wire's bends are an edit of the graph")
	_check(doc.graph.structure_key() == plain, "bends are placement: the structure a view draws is the same")
	_check(XREBlueprintCompiler.compile(doc.graph)["code"] == code, "the compiler ignores bends")
	DirAccess.make_dir_recursive_absolute("res://build/blueprint_tests")
	var path := "res://build/blueprint_tests/bends.tres"
	_check(doc.save_graph(path), "a bent graph saves")
	var loaded := XREBlueprintDocument.new()
	_check(loaded.open_graph(path) and loaded.graph.edges[0].get("vr_bends") is PackedVector3Array and loaded.graph.edges[0]["vr_bends"] == bends, "bends load back as they were")
	doc.undo()
	_check(not doc.graph.edges[0].has("vr_bends"), "undo straightens the wire")
	doc.redo()
	var too_many := PackedVector3Array()
	too_many.resize(XREBlueprintGraph.MAX_BENDS + 1)
	var graph := XREBlueprintGraph.new()
	for bad: Variant in [PackedVector3Array([Vector3(NAN, 0, 0)]), [Vector3.ZERO], Vector3.ZERO, too_many]:
		graph.restore(doc.graph.snapshot())
		graph.edges[0]["vr_bends"] = bad
		_check(not graph.validate().is_empty(), "invalid bends are rejected: %s" % [bad])
		for key: String in [XREBlueprintGraph.SCENE_BENDS, XREBlueprintGraph.VARIABLE_BENDS]:
			graph.restore(doc.graph.snapshot())
			graph.nodes[1][key] = bad
			_check(not graph.validate().is_empty(), "and on a block's own wire: %s %s" % [key, bad])
	# A block keeps the bends of its wire to the scene and of its Variable socket's wire.
	state = doc.graph.snapshot()
	(state["nodes"] as Array)[1][XREBlueprintGraph.SCENE_BENDS] = PackedVector3Array([Vector3(10, 20, 0.5)])
	(state["nodes"] as Array)[1][XREBlueprintGraph.VARIABLE_BENDS] = PackedVector3Array([Vector3(-10, 20, 0.5)])
	_check(doc.commit("Bend Wire", state) and doc.graph.structure_key() == plain, "a block's own bends are placement too")
	_check(XREBlueprintCompiler.compile(doc.graph)["code"] == code, "and the compiler ignores them")
	doc.disconnect_blocks(1, 0, 2, 0)
	_check(doc.graph.edges.is_empty(), "disconnecting takes a bent wire off too")


func _test_all_blocks_compile() -> void:
	var graph := XREBlueprintGraph.new()
	graph.variables.append({"name": "flag", "value": false})
	# Break and Make take their type from a wire (D-139), loops and methods their collection (D-141),
	# Entry and Return belong to a function's body: their own tests build them.
	var kinds: Array = XREBlueprintGraph.BLOCKS.keys().filter(func(kind: String) -> bool: return not kind in ["call", "break", "make", "for_each", "for_each_pair", "collection", "entry", "return"])
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
	# D-078: a variable added with the place of its box in the headset's graph, which is placement, not structure.
	_check(doc.add_variable("gain", 1.5, {"vr_position": Vector2(40, 80), "vr_depth": 0.05}) and doc.graph.find_variable("gain")["vr_position"] == Vector2(40, 80), "a variable is added with a view's fields")
	_check(not doc.add_variable("gain", 2.0) and not doc.add_variable("not a name", 2.0), "a taken or invalid name is refused")
	var key := doc.graph.structure_key()
	var moved := doc.graph.snapshot()
	var placed: Dictionary = (moved["variables"] as Array).back()
	placed["vr_position"] = Vector2(90, 10)
	_check(doc.commit("Move Variable", moved) and doc.graph.find_variable("gain")["vr_position"] == Vector2(90, 10) and doc.graph.structure_key() == key, "moving a box changes the graph's placement only")
	var broken := XREBlueprintGraph.new()
	broken.restore(doc.graph.snapshot())
	broken.variables[-1]["vr_position"] = Vector2(NAN, 0)
	_check(not broken.validate().is_empty(), "a box's non-finite place is rejected")
	var reader := XREBlueprintGraph.make_node(0, "get_variable", Vector2.ZERO)
	reader["params"]["variable"] = "speed"
	var print_id := doc.insert_block(XREBlueprintGraph.make_node(0, "print", Vector2.ZERO), Vector2(300, 0))
	var count := doc.history.get_version()
	var read := doc.insert_block(reader, Vector2(0, 0), {"to": print_id, "to_port": doc.graph.input_port(doc.graph.find_node(print_id), "value")}, null, "Add Variable", [{"name": "speed", "value": 2.0}])
	_check(read > 0 and not doc.graph.find_variable("speed").is_empty() and doc.history.get_version() == count + 1, "a new variable and the block that reads it are one edit")
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


## Presses the button of [param station] of the demo room the way a hand does, with the room's poke tip.
func _press_station(room: Node, station: String, done: Callable) -> void:
	room.call(&"poke", room.get_node(station + "/Button"))
	await _wait_until(done, 3000)
	# The tip leaves the button before the next press.
	await create_timer(0.3).timeout


func _test_demo_room() -> void:
	var room := (load("res://demo/blueprint_room.tscn") as PackedScene).instantiate()
	root.add_child(room)
	await process_frame
	var lamp := room.get_node("Station1/Lamp") as OmniLight3D
	var switch_status := room.get_node("Station1/Status") as Label3D
	_check(lamp.light_energy == 0.0 and switch_status.text == "ВЫКЛ", "demo room: the lamp starts dark")
	await _press_station(room, "Station1", func() -> bool: return switch_status.text == "ВКЛ")
	_check(is_equal_approx(lamp.light_energy, 1.0) and switch_status.text == "ВКЛ", "demo room: poking the button lights the lamp: %s %s" % [lamp.light_energy, switch_status.text])
	await _press_station(room, "Station1", func() -> bool: return switch_status.text == "ВЫКЛ")
	_check(lamp.light_energy == 0.0 and switch_status.text == "ВЫКЛ", "demo room: poking it again puts the lamp out: %s %s" % [lamp.light_energy, switch_status.text])

	var door := room.get_node("Station2/Door") as Node3D
	var door_status := room.get_node("Station2/Status") as Label3D
	await _press_station(room, "Station2", func() -> bool: return door_status.text == "ОТКРЫТО")
	_check(is_equal_approx(door.position.x, -0.4) and door_status.text == "ОТКРЫТО", "demo room: the door slides open and the label follows: %s %s" % [door.position.x, door_status.text])
	await _press_station(room, "Station2", func() -> bool: return door_status.text == "ЗАКРЫТО")
	_check(is_equal_approx(door.position.x, 0.0) and door_status.text == "ЗАКРЫТО", "demo room: and closes again: %s %s" % [door.position.x, door_status.text])

	var wave_status := room.get_node("Station3/Status") as Label3D
	var lamps: Array[OmniLight3D] = []
	for index: int in 5:
		lamps.append(room.get_node("Station3/Lamps/L%d" % (index + 1)) as OmniLight3D)
	var peaks: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
	var peak_times: Array[int] = [0, 0, 0, 0, 0]
	room.call(&"poke", room.get_node("Station3/Button"))
	var started := Time.get_ticks_msec()
	while wave_status.text != "ГОТОВО" or Time.get_ticks_msec() - started < 300:
		await process_frame
		for index: int in 5:
			if lamps[index].light_energy > peaks[index]:
				peaks[index] = lamps[index].light_energy
				peak_times[index] = Time.get_ticks_msec()
		if Time.get_ticks_msec() - started > 8000:
			break
	var in_order := true
	for index: int in 4:
		in_order = in_order and peak_times[index] < peak_times[index + 1]
	_check(wave_status.text == "ГОТОВО" and peaks.all(func(peak: float) -> bool: return is_equal_approx(peak, 1.5)) and in_order, "demo room: the wave runs the lamps in turn and ends: %s %s %s" % [wave_status.text, peaks, peak_times])
	_check(lamps.all(func(light: OmniLight3D) -> bool: return light.light_energy == 0.0), "demo room: every lamp is dark after the wave")
	_check(room.get_node("Station4").get_script() == null and room.get_node("Station4/Button") is Area3D, "demo room: the fourth station is left for the guest to build")
	room.queue_free()
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


## Make Vector2, Make Vector3, Make Color and Get Time: pure library blocks.
func _test_makers_and_time() -> void:
	var graph := XREBlueprintGraph.new()
	var blocks: Array[Dictionary] = []
	for name: String in ["make_vector2", "make_vector3", "make_color", "get_time"]:
		var block := XREBlueprintGraph.make_call(graph.nodes.size() + 1, XREBlueprintFunctions.static_function("XREBlueprintLibrary", name), Vector2.ZERO)
		graph.nodes.append(block)
		blocks.append(block)
	_check(blocks.all(func(block: Dictionary) -> bool: return XREBlueprintGraph.is_pure(block)), "makers and Get Time have no execution ports")
	_check(graph.ports(blocks[1], true).size() == 3 and graph.ports(blocks[1], false)[0][1] == XREBlueprintGraph.port_type(TYPE_VECTOR3), "Make Vector3 takes x, y, z and gives a Vector3")
	_check(graph.ports(blocks[2], true).size() == 4 and graph.ports(blocks[2], false)[0][1] == XREBlueprintGraph.port_type(TYPE_COLOR), "Make Color takes r, g, b, a and gives a Color")
	_check(graph.ports(blocks[3], true).is_empty() and graph.ports(blocks[3], false)[0][1] == XREBlueprintGraph.port_type(TYPE_FLOAT), "Get Time takes nothing and gives a number")
	(blocks[0]["params"] as Dictionary).merge({"x": 1.5, "y": -2.0}, true)
	(blocks[1]["params"] as Dictionary).merge({"x": 1.0, "y": 2.0}, true)
	(blocks[2]["params"] as Dictionary).merge({"r": 0.25, "g": 0.5, "b": 0.75, "a": 0.5}, true)
	_block(graph, "value", {"value": 3})
	_wire(graph, 5, 2, 0, 2)
	var instance := Node.new()
	instance.set_script(_script(graph))
	_check(instance.call("_bp_value1") == Vector2(1.5, -2.0), "Make Vector2 builds its vector")
	_check(instance.call("_bp_value2") == Vector3(1.0, 2.0, 3.0), "Make Vector3 builds its vector; an integer wire widens to its float input")
	_check(instance.call("_bp_value3") == Color(0.25, 0.5, 0.75, 0.5), "Make Color builds its color")
	var first: Variant = instance.call("_bp_value4")
	var second: Variant = instance.call("_bp_value4")
	_check(first is float and float(first) > 0.0 and float(second) >= float(first), "Get Time gives seconds that don't go back")
	instance.free()
	var actions := XREBlueprintActions.new()
	var ids := XREBlueprintActions.flatten(actions.sections({"chip": XREBlueprintActions.LIBRARY, "graph": graph})).map(func(action: Dictionary) -> String: return str(action["id"]))
	_check(ids.has("static:XREBlueprintLibrary.get_time") and not ids.has("static:XREBlueprintLibrary.make_vector3"), "the menu's Library offers Get Time; Make Vector3 is Make's now (D-139)")


func _library_call(graph: XREBlueprintGraph, name: String, params: Dictionary = {}) -> int:
	var id := graph.nodes.size() + 1
	var block := XREBlueprintGraph.make_call(id, XREBlueprintFunctions.static_function("XREBlueprintLibrary", name), Vector2(id * 200, 80))
	(block["params"] as Dictionary).merge(params, true)
	graph.nodes.append(block)
	return id


## Vectors (D-084): their components through Break blocks, operators on
## vectors, and the vector math of the library.
func _test_vectors() -> void:
	var graph := XREBlueprintGraph.new()
	var make := _library_call(graph, "make_vector3", {"x": 1.0, "y": 2.0, "z": 3.0})
	var split := _library_call(graph, "break_vector3")
	_wire(graph, make, split)
	var outputs := graph.ports(graph.find_node(split), false)
	_check(XREBlueprintGraph.is_pure(graph.find_node(split)) and outputs.size() == 3 and outputs[0][0] == "X" and outputs[2][0] == "Z"
			and outputs.all(func(port: Array) -> bool: return port[1] == XREBlueprintGraph.NUMBER), "Break Vector3 is pure and gives X, Y, Z as numbers")
	var z_plus := _operator(graph, "add", {"b": 10.0})
	_wire(graph, split, z_plus, 2, 0)
	_check(graph.ports(graph.find_node(z_plus), false)[0][1] == XREBlueprintGraph.NUMBER, "a component adds to a number")
	var other := _library_call(graph, "make_vector3", {"x": 4.0, "y": 5.0, "z": 6.0})
	var sum := _operator(graph, "add")
	_wire(graph, make, sum, 0, 0)
	_wire(graph, other, sum, 0, 1)
	_check(graph.ports(graph.find_node(sum), false)[0][1] == XREBlueprintGraph.VECTOR3, "Add of two Vector3 gives a Vector3")
	var difference := _operator(graph, "subtract")
	_wire(graph, other, difference, 0, 0)
	_wire(graph, make, difference, 0, 1)
	var scaled := _operator(graph, "multiply", {"b": 2.0})
	_wire(graph, make, scaled, 0, 0)
	var dot := _library_call(graph, "vector3_dot")
	_wire(graph, make, dot, 0, 0)
	_wire(graph, other, dot, 0, 1)
	var cross := _library_call(graph, "vector3_cross", {"a": Vector3.RIGHT, "b": Vector3.UP})
	var length := _library_call(graph, "vector3_length", {"vector": Vector3(3, 4, 0)})
	var normal := _library_call(graph, "vector3_normalize", {"vector": Vector3(0, 0, 5)})
	var distance := _library_call(graph, "vector3_distance")
	_wire(graph, make, distance, 0, 0)
	_wire(graph, other, distance, 0, 1)
	var flat := _library_call(graph, "break_vector2", {"vector": Vector2(7, 8)})
	var flat_y := _operator(graph, "negate")
	_wire(graph, flat, flat_y, 1, 0)
	var flat_length := _library_call(graph, "vector2_length", {"vector": Vector2(6, 8)})
	var flat_dot := _library_call(graph, "vector2_dot", {"a": Vector2(1, 2), "b": Vector2(3, 4)})
	var flat_normal := _library_call(graph, "vector2_normalize", {"vector": Vector2(0, -2)})
	var flat_distance := _library_call(graph, "vector2_distance", {"a": Vector2.ZERO, "b": Vector2(3, 4)})
	var tint := _library_call(graph, "break_color", {"color": Color(0.1, 0.2, 0.3, 0.4)})
	var alpha := _operator(graph, "multiply", {"b": 10.0})
	_wire(graph, tint, alpha, 3, 0)
	_check(graph.validate().is_empty(), "a graph of vectors is valid: %s" % graph.validate())
	var instance := Node.new()
	instance.set_script(_script(graph))
	var value := func(id: int) -> Variant: return instance.call("_bp_value%d" % id)
	_check(is_equal_approx(float(value.call(z_plus)), 13.0), "Break Vector3 gives Z: %s" % value.call(z_plus))
	_check(value.call(sum) == Vector3(5, 7, 9) and value.call(difference) == Vector3(3, 3, 3) and value.call(scaled) == Vector3(2, 4, 6), "vectors add, subtract and scale")
	_check(is_equal_approx(float(value.call(dot)), 32.0) and value.call(cross) == Vector3.BACK, "Vector3 Dot and Cross")
	_check(is_equal_approx(float(value.call(length)), 5.0) and value.call(normal) == Vector3.BACK, "Vector3 Length and Normalize")
	_check(is_equal_approx(float(value.call(distance)), sqrt(27.0)), "Vector3 Distance")
	_check(is_equal_approx(float(value.call(flat_y)), -8.0), "Break Vector2 gives Y")
	_check(is_equal_approx(float(value.call(flat_length)), 10.0) and is_equal_approx(float(value.call(flat_dot)), 11.0)
			and value.call(flat_normal) == Vector2.UP and is_equal_approx(float(value.call(flat_distance)), 5.0), "Vector2 Length, Dot, Normalize and Distance")
	_check(is_equal_approx(float(value.call(alpha)), 4.0), "Break Color gives A")
	instance.free()
	var actions := XREBlueprintActions.new()
	var ids := XREBlueprintActions.flatten(actions.sections({"chip": XREBlueprintActions.LIBRARY, "graph": graph})).map(func(action: Dictionary) -> String: return str(action["id"]))
	_check(["vector3_cross", "vector2_distance"].all(func(name: String) -> bool: return ids.has("static:XREBlueprintLibrary." + name)) and not ids.has("static:XREBlueprintLibrary.break_vector3"), "the menu's Library offers vector math; Break Vector3 is Break's now (D-139)")
	var pin := XREBlueprintActions.flatten(actions.sections({"chip": XREBlueprintActions.NATIVE, "graph": graph, "pin": {"type": XREBlueprintGraph.VECTOR3, "output": true}}))
	_check(pin.any(func(action: Dictionary) -> bool: return action["id"] == "struct:break:Vector3") and pin.any(func(action: Dictionary) -> bool: return action["id"] == "struct:break"), "a Vector3 wire let go offers Break Vector3 and Break")


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


## D-122, D-126, D-128: pasted blocks get new IDs, their wires among them and
## the outer ones into them follow, and the variables they use that the graph
## lacks come in the same undo step.
func _test_paste_blocks() -> void:
	var source := XREBlueprintDocument.new()
	source.set_variable("clip_count", 3)
	var setter := source.insert_block(XREBlueprintGraph.make_node(0, "set_variable", Vector2.ZERO), Vector2(300, 100), {"from": 1, "from_port": 0})
	var number := XREBlueprintGraph.make_node(0, "value", Vector2.ZERO)
	(number["params"] as Dictionary)["value"] = 1.0
	var value := source.insert_block(number, Vector2(100, 300))
	var blocks: Array[Dictionary] = [source.graph.find_node(setter)]
	var edges: Array[Dictionary] = []
	var variables: Array[Dictionary] = []
	variables.assign(source.graph.variables)
	var target := XREBlueprintDocument.new()
	var version := target.history.get_version()
	var ids := target.paste_blocks(blocks, edges, Vector2(10, 20), 0.5, "Paste Blocks", [], variables)
	var pasted := target.graph.find_node(ids[0]) if ids.size() == 1 else {}
	_check(not pasted.is_empty() and pasted["position"] == Vector2(310, 120) and is_equal_approx(float(pasted["vr_depth"]), 0.5),
			"a pasted block gets a new ID, moved by the offset and the depth")
	_check(not target.graph.find_variable("clip_count").is_empty() and target.history.get_version() == version + 1,
			"the variable it writes comes along, in the same undo step")
	_check(target.paste_blocks(blocks, edges, Vector2.ZERO, 0.0, "Paste Blocks", [], variables).size() == 1 and target.graph.variables.size() == 1,
			"a variable the graph has already isn't added twice")
	# Set Property's Value takes any value, as Value gives.
	var property := source.insert_block(XREBlueprintGraph.make_node(0, "set_property", Vector2.ZERO), Vector2(500, 100))
	var outer: Array[Dictionary] = [{"from": value, "from_port": 0, "to": property, "to_port": 1}]
	var setters: Array[Dictionary] = [source.graph.find_node(property)]
	var copies := source.paste_blocks(setters, edges, Vector2(0, 200), 0.0, "Duplicate Blocks", outer)
	_check(copies.size() == 1 and source.graph.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == value and edge["to"] == copies[0]),
			"an outer wire into a pasted block comes from the same output")


## Variadic operators (D-136): types folded from the left, pins added and
## removed with their wires following them by key, validation, the menu, the
## generated code and its values.
func _test_variadic_operators() -> void:
	var invalid := XREBlueprintOperators.INVALID
	_check(XREBlueprintOperators.is_variadic("add") and XREBlueprintOperators.is_variadic("append") and not XREBlueprintOperators.is_variadic("subtract") and not XREBlueprintOperators.is_variadic("not"),
			"add, multiply, AND, OR, min, max and append take more inputs; subtract and NOT don't")
	_check(XREBlueprintOperators.fold_type("add", [TYPE_INT, TYPE_INT, TYPE_FLOAT] as Array[int]) == TYPE_FLOAT and XREBlueprintOperators.fold_type("add", [TYPE_INT, TYPE_INT, TYPE_INT] as Array[int]) == TYPE_INT,
			"int + int + float is a float, three ints an int")
	_check(XREBlueprintOperators.fold_type("min", [TYPE_INT, TYPE_INT] as Array[int]) == TYPE_INT and XREBlueprintOperators.fold_type("max", [TYPE_INT, TYPE_FLOAT, TYPE_INT] as Array[int]) == TYPE_FLOAT
			and XREBlueprintOperators.result_type("min", TYPE_STRING, TYPE_INT) == invalid, "min and max take numbers: ints give an int, with a real a real")
	_check(XREBlueprintOperators.fold_type("append", [TYPE_STRING, TYPE_INT, TYPE_VECTOR3] as Array[int]) == TYPE_STRING and XREBlueprintOperators.fold_type("add", [TYPE_VECTOR3, TYPE_VECTOR3, TYPE_FLOAT] as Array[int]) == invalid,
			"append makes text of anything; a vector and a number don't add at the third input")

	# Pins: added at the end with a literal that changes nothing, removed with their wires.
	var doc := XREBlueprintDocument.new()
	var sum := doc.insert_block(XREBlueprintGraph.make_operator(0, "add", Vector2.ZERO), Vector2(400, 0))
	var one := doc.insert_block(XREBlueprintGraph.make_node(0, "value", Vector2.ZERO), Vector2(0, 0))
	var two := doc.insert_block(XREBlueprintGraph.make_node(0, "value", Vector2.ZERO), Vector2(0, 100))
	var reader := doc.insert_block(XREBlueprintGraph.make_node(0, "set_variable", Vector2.ZERO), Vector2(700, 0))
	_check(doc.add_operand(sum) and doc.add_operand(sum), "two inputs added to Add")
	var block := doc.graph.find_node(sum)
	var inputs := doc.graph.ports(block, true)
	_check(inputs.size() == 4 and inputs[2][0] == "C" and inputs[3][2] == "d" and block["params"]["operands"] == 4 and block["params"]["d"] == 0.0, "Add has A, B, C, D; D starts at 0: %s" % [block["params"]])
	_check(doc.connect_blocks(one, 0, sum, 0) and doc.connect_blocks(two, 0, sum, 2) and doc.connect_blocks(sum, 0, reader, 1), "values wire into A and C, the result out")
	doc.set_parameter(sum, "d", 7.0)
	var history := doc.history.get_history_count()
	_check(doc.remove_operand(sum, "b"), "B is removed")
	block = doc.graph.find_node(sum)
	var into: Dictionary = {}
	for edge: Dictionary in doc.graph.edges:
		if edge["to"] == sum: into[edge["from"]] = edge["to_port"]
	_check(into.get(one) == 0 and into.get(two) == 1 and block["params"]["operands"] == 3 and block["params"]["c"] == 7.0 and not (block["params"] as Dictionary).has("d"),
			"C's wire and D's literal moved up a pin: %s %s" % [into, block["params"]])
	_check(doc.graph.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == sum and edge["to"] == reader), "the result's wire stays")
	_check(doc.remove_operand(sum, "b"), "the wired B, once C, is removed")
	block = doc.graph.find_node(sum)
	_check(not doc.graph.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == two) and not (block["params"] as Dictionary).has("operands") and block["params"]["b"] == 7.0,
			"its wire went with it; two inputs left, the count gone: %s" % [block["params"]])
	_check(not doc.remove_operand(sum, "a") and doc.last_error.contains("at least"), "two inputs stay: %s" % doc.last_error)
	_check(doc.history.get_history_count() == history + 2, "each removal is one edit")
	doc.undo()
	doc.undo()
	block = doc.graph.find_node(sum)
	_check(block["params"]["operands"] == 4 and doc.graph.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == two and edge["to"] == sum and edge["to_port"] == 2), "undo brings back the pins and C's wire")
	for count: int in range(4, XREBlueprintOperators.MAX_OPERANDS): doc.add_operand(sum)
	_check(XREBlueprintGraph.operand_count(doc.graph.find_node(sum)) == 8 and not doc.add_operand(sum), "at most eight inputs")
	_check(not doc.add_operand(doc.insert_block(XREBlueprintGraph.make_operator(0, "subtract", Vector2.ZERO), Vector2(0, 600))), "Subtract takes no more inputs")
	var product := doc.insert_block(XREBlueprintGraph.make_operator(0, "multiply", Vector2.ZERO), Vector2(0, 700))
	var both := doc.insert_block(XREBlueprintGraph.make_operator(0, "and", Vector2.ZERO), Vector2(0, 800))
	var either := doc.insert_block(XREBlueprintGraph.make_operator(0, "or", Vector2.ZERO), Vector2(0, 900))
	var least := doc.insert_block(XREBlueprintGraph.make_operator(0, "min", Vector2.ZERO), Vector2(0, 1000))
	var text := doc.insert_block(XREBlueprintGraph.make_operator(0, "append", Vector2.ZERO), Vector2(0, 1100))
	doc.set_parameter(least, "b", 5.0)
	for id: int in [product, both, either, least, text]: doc.add_operand(id)
	_check(doc.graph.find_node(product)["params"]["c"] == 1.0 and doc.graph.find_node(both)["params"]["c"] == true and doc.graph.find_node(either)["params"]["c"] == false
			and doc.graph.find_node(least)["params"]["c"] == 5.0 and doc.graph.find_node(text)["params"]["c"] == "", "a new input changes nothing: ×1, AND true, OR false, min the last, append empty")
	var vectors := doc.insert_block(XREBlueprintGraph.make_operator(0, "add", Vector2.ZERO), Vector2(0, 1200))
	doc.set_parameter(vectors, "a", Vector3.ONE)
	doc.add_operand(vectors)
	_check(doc.graph.find_node(vectors)["params"]["c"] == Vector3.ZERO, "added to vectors, a zero vector")
	var count := doc.insert_block(XREBlueprintGraph.make_node(0, "value", Vector2.ZERO), Vector2(0, 1300))
	doc.set_parameter(count, "value", 3)
	_check(doc.connect_blocks(count, 0, product, 2) and doc.graph.find_node(product)["params"]["a"] is int and doc.graph.find_node(product)["params"]["b"] is int, "an int wired into C makes A and B ints")
	_check(doc.graph.operand_types(doc.graph.find_node(least), "c", [TYPE_BOOL, TYPE_INT, TYPE_STRING]) == [TYPE_INT], "min's input takes numbers only")
	_check(doc.graph.ports(doc.graph.find_node(least), true)[0][1] == XREBlueprintGraph.NUMBER and doc.graph.ports(doc.graph.find_node(text), false)[0][1] == XREBlueprintGraph.TEXT, "min's inputs are numbers; append gives text")

	# Validation: a count only a variadic operator has, no literal past it.
	var graph := XREBlueprintGraph.new()
	_operator(graph, "subtract", {"operands": 3, "c": 1.0})
	_operator(graph, "add", {"operands": 9})
	_operator(graph, "add", {"d": 1.0})
	var errors := "\n".join(graph.validate())
	_check(errors.contains("#1: invalid number of operands") and errors.contains("#2: invalid number of operands") and errors.contains("#3: d is past its operands"), "counts and literals are checked: %s" % errors)

	# The menu: Min and Max are operators, @GlobalScope's min() and max() are gone from it.
	var found := XREBlueprintActions.flatten(XREBlueprintActions.new().sections({"chip": XREBlueprintActions.ALL, "graph": doc.graph, "query": "max"}))
	var ids: Array[String] = []
	for action: Dictionary in found: ids.append(str(action["id"]))
	_check(ids.has("operator:max") and not ids.has("global:max") and ids.has("global:maxf"), "max is the operator, maxf stays: %s" % [ids])
	found = XREBlueprintActions.flatten(XREBlueprintActions.new().sections({"chip": XREBlueprintActions.ALL, "graph": doc.graph, "query": "concat"}))
	_check(found.size() == 1 and found[0]["id"] == "operator:append" and XREBlueprintActions.task_of(found[0]) == "Arithmetic", "Append is found as concat, in Arithmetic")

	# Generated code folds the inputs from the left.
	graph = XREBlueprintGraph.new()
	var ten := _operator(graph, "add", {"operands": 4, "a": 1, "b": 2, "c": 3, "d": 4})
	var joined := _operator(graph, "append", {"operands": 3, "a": "level ", "b": 5, "c": "!"})
	var smallest := _operator(graph, "min", {"operands": 3, "a": 3, "b": 7, "c": 5})
	var largest := _operator(graph, "max", {"operands": 3, "a": 3, "b": 7.5, "c": 5})
	var all := _operator(graph, "and", {"operands": 3, "a": true, "b": true, "c": false})
	var any := _operator(graph, "or", {"operands": 3, "a": false, "b": false, "c": true})
	var plain := _operator(graph, "add", {"a": 1, "b": 2})
	var source := XREBlueprintCompiler.compile(graph)["code"] as String
	_check(source.contains("\treturn _bp_operate(\"add\", 1, 2, run, %d)\n" % plain), "two inputs compile as before")
	var instance := Node.new()
	instance.set_script(_script(graph))
	_check(instance.call("_bp_value%d" % ten) == 10 and instance.call("_bp_value%d" % joined) == "level 5!", "1 + 2 + 3 + 4 is 10; append makes level 5!")
	_check(instance.call("_bp_value%d" % smallest) == 3 and is_equal_approx(float(instance.call("_bp_value%d" % largest)), 7.5) and instance.call("_bp_value%d" % smallest) is int, "min of ints is the int 3, max 7.5")
	_check(instance.call("_bp_value%d" % all) == false and instance.call("_bp_value%d" % any) == true, "true AND true AND false; false OR false OR true")
	instance.free()
	graph = XREBlueprintGraph.new()
	_operator(graph, "add", {"operands": 3, "a": 1, "b": 2, "c": "x"})
	errors = "\n".join(XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray)
	_check(errors.contains("Add doesn't take int and String"), "the build names the pair that can't go together: %s" % errors)


## Sequence and Switch (D-138): their pins added and removed with wires
## following them, a case's value, validation, the generated code — a
## Sequence's next output waits for the chain before it, Delay included —, the
## three kinds of Switch and a repeated case.
func _test_sequence_switch() -> void:
	# Pins: a Sequence's outputs and a Switch's cases, the wires following them.
	var doc := XREBlueprintDocument.new()
	var sequence := doc.insert_block(XREBlueprintGraph.make_node(0, "sequence", Vector2.ZERO), Vector2(0, 0))
	var first := doc.insert_block(XREBlueprintGraph.make_node(0, "branch", Vector2.ZERO), Vector2(400, 0))
	var second := doc.insert_block(XREBlueprintGraph.make_node(0, "branch", Vector2.ZERO), Vector2(400, 200))
	_check(doc.graph.ports(doc.graph.find_node(sequence), false).size() == 2 and doc.add_pin(sequence), "a Sequence has Then 0 and Then 1, and takes Then 2")
	var outputs := doc.graph.ports(doc.graph.find_node(sequence), false)
	_check(outputs.size() == 3 and outputs[2][0] == "Then 2", "Then 2 is its third output: %s" % [outputs])
	doc.connect_blocks(sequence, 0, first, 0)
	doc.connect_blocks(sequence, 2, second, 0)
	_check(doc.remove_pin(sequence, 1), "Then 1 is removed")
	var from: Dictionary = {}
	for edge: Dictionary in doc.graph.edges:
		if edge["from"] == sequence: from[edge["to"]] = edge["from_port"]
	_check(from.get(first) == 0 and from.get(second) == 1, "Then 2's wire moved up to Then 1: %s" % [from])
	_check(not doc.remove_pin(sequence, 0) and doc.last_error.contains("at least"), "two outputs stay")
	var switch := doc.insert_block(XREBlueprintGraph.make_switch(0, "int", Vector2.ZERO), Vector2(0, 400))
	_check(XREBlueprintGraph.title(doc.graph.find_node(switch)) == "Switch on Int" and doc.add_pin(switch), "Switch on Int takes a case")
	var block := doc.graph.find_node(switch)
	outputs = doc.graph.ports(block, false)
	_check(block["params"]["case_2"] == 2 and outputs.size() == 4 and outputs[2][0] == "2" and outputs[3][0] == "Default", "the new case is 2, before Default: %s" % [outputs])
	doc.connect_blocks(switch, 3, second, 0)
	_check(doc.remove_pin(switch, 0), "case 0 is removed")
	block = doc.graph.find_node(switch)
	_check(block["params"]["case_0"] == 1 and block["params"]["case_1"] == 2 and not (block["params"] as Dictionary).has("case_2")
			and doc.graph.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == switch and edge["from_port"] == 2 and edge["to"] == second), "the cases moved up; Default's wire follows it")
	var words := doc.insert_block(XREBlueprintGraph.make_switch(0, "string", Vector2.ZERO), Vector2(0, 600))
	doc.add_pin(words)
	_check(doc.graph.find_node(words)["params"]["case_2"] == "case_2" and doc.graph.ports(doc.graph.find_node(words), false)[0][0] == "\"case_0\"", "a String case is a new text, its output in quotes")
	var mode := doc.insert_block(XREBlueprintGraph.make_switch(0, "enum", Vector2.ZERO, "Node.ProcessMode"), Vector2(0, 800))
	block = doc.graph.find_node(mode)
	_check(XREBlueprintGraph.title(block) == "Switch on ProcessMode" and block["params"]["case_1"] == "PROCESS_MODE_PAUSABLE", "Switch on an enumeration names its constants")
	for count: int in 3: doc.add_pin(mode)
	_check(XREBlueprintGraph.pin_count(doc.graph.find_node(mode)) == 5 and not XREBlueprintGraph.variable_pins(doc.graph.find_node(mode))["can_add"], "every constant used: no more cases")
	_check(not doc.set_parameter(mode, "case_0", "NO_SUCH_MODE"), "a name the enumeration hasn't is refused")
	# A wire from an enumeration's Get makes an Int Switch one on its constants; Default keeps its wire.
	var process_info: Dictionary = {}
	for entry: Dictionary in ClassDB.class_get_property_list("Node"):
		if entry["name"] == "process_mode": process_info = entry
	var getter: Dictionary = XREBlueprintActions._property_actions(process_info, "Node")[0]["block"]
	_check(getter.get("property_enum") == "Node.ProcessMode", "Get Process Mode knows its enumeration: %s" % [getter.get("property_enum")])
	var read := doc.insert_block(getter, Vector2(-400, 1000))
	var by_number := doc.insert_block(XREBlueprintGraph.make_node(0, "switch", Vector2.ZERO), Vector2(0, 1000))
	doc.add_pin(by_number)
	doc.connect_blocks(by_number, 3, second, 0)
	_check(doc.connect_blocks(read, 0, by_number, 1), "Process Mode is wired into the Int Switch's Selection: %s" % doc.last_error)
	block = doc.graph.find_node(by_number)
	_check(block["params"]["on"] == "enum" and block["params"]["enum"] == "Node.ProcessMode" and block["params"]["case_2"] == "PROCESS_MODE_WHEN_PAUSED", "the Switch is on ProcessMode, its three cases its first constants: %s" % [block["params"]])
	_check(doc.graph.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == by_number and edge["from_port"] == 3 and edge["to"] == second), "Default keeps its wire")
	_check((XREBlueprintCompiler.compile(doc.graph)["errors"] as PackedStringArray).is_empty(), "it builds")
	doc.undo()
	_check(doc.graph.find_node(by_number)["params"]["on"] == "int", "undo takes the wire and the enumeration back")

	# Validation.
	var graph := XREBlueprintGraph.new()
	_block(graph, "sequence", {"outputs": 9})
	_block(graph, "switch", {"on": "float"})
	_block(graph, "switch", {"case_1": "one"})
	_block(graph, "switch", {"case_4": 4})
	var errors := "\n".join(graph.validate())
	_check(errors.contains("#1: invalid number of outputs") and errors.contains("#2: a Switch is on int") and errors.contains("#3: case 1 must be int") and errors.contains("#4: case 4 is past"), "pins are checked: %s" % errors)
	graph = XREBlueprintGraph.new()
	_block(graph, "ready")
	_block(graph, "switch", {"case_1": 0})
	_wire(graph, 1, 2)
	errors = "\n".join(XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray)
	_check(errors.contains("case 0 repeats"), "a repeated case is a build error: %s" % errors)

	# The generated code: Then 1 waits for Then 0's Delay; each Switch takes its case.
	graph = XREBlueprintGraph.new()
	graph.variables.append_array([{"name": "waited", "value": false}, {"name": "seen", "value": false}, {"name": "done", "value": false}, {"name": "hit", "value": ""}])
	var ready := _block(graph, "ready")
	var order := _block(graph, "sequence", {"outputs": 3})
	var delay := graph.nodes.size() + 1
	var wait := XREBlueprintGraph.make_node(delay, "delay", Vector2.ZERO)
	wait["params"]["seconds"] = 0.05
	graph.nodes.append(wait)
	var after := _block(graph, "set_variable", {"variable": "waited", "value": true})
	var reader := _block(graph, "set_variable", {"variable": "seen", "value": false})
	var waited := _block(graph, "get_variable", {"variable": "waited"})
	var cases := _block(graph, "sequence", {"outputs": 3})
	var numbers := graph.nodes.size() + 1
	graph.nodes.append(XREBlueprintGraph.make_switch(numbers, "int", Vector2.ZERO))
	(graph.nodes[numbers - 1]["params"] as Dictionary).merge({"selection": 2, "cases": 3, "case_2": 2}, true)
	var two := _block(graph, "set_variable", {"variable": "hit", "value": "two"})
	var texts := graph.nodes.size() + 1
	graph.nodes.append(XREBlueprintGraph.make_switch(texts, "string", Vector2.ZERO))
	(graph.nodes[texts - 1]["params"] as Dictionary).merge({"selection": "case_1"}, true)
	var run := _block(graph, "set_variable", {"variable": "hit", "value": "two run"})
	var modes := graph.nodes.size() + 1
	graph.nodes.append(XREBlueprintGraph.make_switch(modes, "enum", Vector2.ZERO, "Node.ProcessMode"))
	(graph.nodes[modes - 1]["params"] as Dictionary).merge({"selection": "PROCESS_MODE_PAUSABLE"}, true)
	var always := _block(graph, "set_variable", {"variable": "hit", "value": "two run pausable"})
	var done := _block(graph, "set_variable", {"variable": "done", "value": true})
	_wire(graph, ready, order)
	_wire(graph, order, delay, 0)
	_wire(graph, delay, after)
	_wire(graph, order, reader, 1)
	_wire(graph, waited, reader, 0, 1)
	_wire(graph, order, cases, 2)
	_wire(graph, cases, numbers, 0)
	_wire(graph, numbers, two, 2)
	_wire(graph, cases, texts, 1)
	_wire(graph, texts, run, 1)
	_wire(graph, cases, modes, 2)
	_wire(graph, modes, always, 1)
	_wire(graph, always, done)
	var source := XREBlueprintCompiler.compile(graph)["code"] as String
	_check(source.contains("_bp_sequence(run, %d, [%d, %d, %d])" % [order, delay, reader, cases]) and source.contains("\t\t1:  # PROCESS_MODE_PAUSABLE\n"), "Sequence and Switch compile readably")
	var scene := Node.new()
	scene.set_script(_script(graph))
	root.add_child(scene)
	await _wait_until(func() -> bool: return scene.get("_bp_var_done") == true)
	_check(scene.get("_bp_var_seen") == true, "Then 1 ran after Then 0's Delay ended")
	_check(scene.get("_bp_var_hit") == "two run pausable", "each Switch took its case: %s" % scene.get("_bp_var_hit"))
	_check((scene.get("_bp_runs") as Array).is_empty(), "the run ended with its stack")
	scene.queue_free()
	await process_frame


## Break and Make (D-139): the fields of built-in values, of a script class
## and of an engine class; a wire typing an untyped Break; hiding a field with
## the wires following; the generated code and its values; a value of another
## class, a subclass and a field gone from its class.
func _test_break_make() -> void:
	var vector := XREBlueprintStructs.describe(TYPE_VECTOR3)
	_check((vector["fields"] as Array).map(func(field: Dictionary) -> String: return field["name"]) == ["x", "y", "z"], "Vector3 has x, y, z")
	var color := XREBlueprintStructs.describe(TYPE_COLOR)
	_check(XREBlueprintStructs.default_hidden(color) == ["h", "s", "v"] and (XREBlueprintStructs.describe(TYPE_COLOR, "", true)["fields"] as Array).size() == 4, "Color's h, s, v start hidden; Make has r, g, b, a only")
	var transform := XREBlueprintStructs.describe(TYPE_TRANSFORM3D)
	_check(transform["fields"][0]["type"] == TYPE_BASIS and transform["fields"][1]["name"] == "origin" and XREBlueprintGraph.port_type(TYPE_TRANSFORM3D) == XREBlueprintGraph.TRANSFORM3D, "Transform3D has basis and origin, a port of its own")
	var stats := XREBlueprintStructs.describe(TYPE_OBJECT, "XREDemoStats")
	var names: Array = (stats["fields"] as Array).map(func(field: Dictionary) -> String: return field["name"])
	var hidden := XREBlueprintStructs.default_hidden(stats)
	_check(names.slice(0, 4) == ["hp", "speed", "title", "_cooldown"] and hidden.has("_cooldown") and hidden.has("resource_name") and not hidden.has("hp"), "a script class's variables, its engine base's properties hidden: %s" % [names])
	_check(XREBlueprintStructs.can_make(TYPE_OBJECT, "XREDemoStats") and not XREBlueprintStructs.can_make(TYPE_OBJECT, "Node3D") and not XREBlueprintStructs.describe(TYPE_OBJECT, "Node3D").is_empty(), "Make builds a resource, not a node; Break takes an engine class apart")
	_check((XREBlueprintStructs.describe(TYPE_OBJECT, "XREDemoEliteStats")["fields"] as Array).map(func(field: Dictionary) -> String: return field["name"]).slice(0, 2) == ["shield", "hp"], "a subclass's fields come first, then its base script's")

	# A wire types an untyped Break; hiding a field moves the wires after it.
	var doc := XREBlueprintDocument.new()
	var typed := XREBlueprintGraph.new()
	typed.nodes.append(XREBlueprintGraph.make_node(1, "make", Vector2.ZERO))
	typed.retype(1, XREBlueprintStructs.describe(TYPE_OBJECT, "XREDemoStats", true))
	var maker := doc.insert_block(typed.nodes[0], Vector2(0, 0))
	var split := doc.insert_block(XREBlueprintGraph.make_node(0, "break", Vector2.ZERO), Vector2(300, 0))
	_check(doc.graph.ports(doc.graph.find_node(split), false).is_empty() and doc.connect_blocks(maker, 0, split, 0), "an untyped Break has no fields; the Make's wire goes into its Target")
	var block := doc.graph.find_node(split)
	var outputs := doc.graph.ports(block, false)
	_check(XREBlueprintGraph.title(block) == "Break XREDemoStats" and outputs.map(func(spec: Array) -> String: return spec[0]) == ["hp", "speed", "title"], "the wire typed it: hp, speed, title shown: %s" % [outputs])
	var text := doc.insert_block(XREBlueprintGraph.make_operator(0, "append", Vector2.ZERO), Vector2(600, 0))
	doc.connect_blocks(split, 2, text, 0)
	_check(doc.set_field_hidden(split, "speed", true), "speed is hidden")
	_check(doc.graph.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == split and edge["from_port"] == 1 and edge["to"] == text), "title's wire moved up with it")
	_check(not doc.set_field_hidden(split, "title", true) and doc.last_error.contains("wire"), "a field with a wire stays")
	_check(doc.set_field_hidden(split, "speed", false) and doc.graph.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == split and edge["from_port"] == 2), "shown again, it takes its place back")

	# Generated code: a Make's fields, a Break's, built-in values, another class, a gone field.
	var graph := XREBlueprintGraph.new()
	var make_stats := _block(graph, "make")
	graph.retype(make_stats, XREBlueprintStructs.describe(TYPE_OBJECT, "XREDemoStats", true))
	(graph.find_node(make_stats)["params"] as Dictionary).merge({"hp": 7, "title": "elf"}, true)
	var break_stats := _block(graph, "break")
	_wire(graph, make_stats, break_stats)
	graph.adopt_structs([])
	var plus := _operator(graph, "add", {"b": 3})
	_wire(graph, break_stats, plus, 0, 0)
	var shout := _operator(graph, "append", {"b": "!"})
	_wire(graph, break_stats, shout, 2, 0)
	var make_vector := _block(graph, "make")
	graph.retype(make_vector, XREBlueprintStructs.describe(TYPE_VECTOR3, "", true))
	(graph.find_node(make_vector)["params"] as Dictionary).merge({"x": 1.0, "y": 2.0, "z": 3.0}, true)
	var make_transform := _block(graph, "make")
	graph.retype(make_transform, XREBlueprintStructs.describe(TYPE_TRANSFORM3D, "", true))
	# A hidden basis keeps the default's; origin is then the only input.
	graph.find_node(make_transform)["hidden"] = ["basis"]
	_wire(graph, make_vector, make_transform, 0, 0)
	var break_transform := _block(graph, "break")
	_wire(graph, make_transform, break_transform)
	graph.adopt_structs([])
	var break_color := _block(graph, "break")
	graph.retype(break_color, XREBlueprintStructs.describe(TYPE_COLOR))
	graph.find_node(break_color)["params"]["value"] = Color(1, 0, 0, 1)
	graph.find_node(break_color)["hidden"] = []
	var hue := _operator(graph, "add", {"b": 0.25})
	_wire(graph, break_color, hue, 4, 0)
	_check(graph.validate().is_empty(), "a graph of Break and Make is valid: %s" % graph.validate())
	var source := XREBlueprintCompiler.compile(graph)["code"] as String
	_check(source.contains("var value := XREDemoStats.new()") and source.contains("value.set(&\"hp\", 7)") and source.contains("var value := Transform3D()") and source.contains("_bp_field(_bp_value%d(run), &\"title\"" % break_stats),
			"Make and Break read as code")
	var instance := Node.new()
	instance.set_script(_script(graph))
	var problems: Array[String] = []
	instance.connect(&"blueprint_error", func(_id: int, message: String) -> void: problems.append(message))
	_check(instance.call("_bp_value%d" % plus) == 10 and instance.call("_bp_value%d" % shout) == "elf!", "Break reads Make's hp 7 and title elf")
	_check((instance.call("_bp_value%d" % break_transform) as Transform3D).origin == Vector3(1, 2, 3), "Make Transform3D takes its origin from Make Vector3, Break gives it back")
	_check(is_equal_approx(float(instance.call("_bp_value%d" % hue)), 0.25), "a shown h of red is 0")
	_check(instance.call("_bp_struct", XREDemoEliteStats.new(), TYPE_OBJECT, "XREDemoStats", null, 9) is XREDemoEliteStats, "a subclass's value is taken apart")
	_check(instance.call("_bp_struct", RefCounted.new(), TYPE_OBJECT, "XREDemoStats", null, 9) == null, "another class's is not")
	instance.free()
	# A field gone from its class: dropped without a wire, kept red with one; the build stops.
	var stale := graph.find_node(break_stats)
	(stale["struct"]["fields"] as Array).append({"name": "mana", "type": TYPE_FLOAT, "class_name": ""})
	(stale["struct"]["fields"] as Array).append({"name": "luck", "type": TYPE_FLOAT, "class_name": ""})
	var now: Dictionary = XREBlueprintStructs.reconciled(stale, ["mana"])
	var kept: Array = (now["fields"] as Array).map(func(field: Dictionary) -> String: return field["name"] + ("!" if field.get("missing", false) else ""))
	_check(kept.has("mana!") and not kept.has("luck") and not kept.has("luck!"), "a gone field with a wire stays, missing; without one it goes: %s" % [kept])
	stale["struct"] = now
	var errors := "\n".join(XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray)
	_check(errors.contains("XREDemoStats has no field mana"), "the build names the gone field: %s" % errors)
	graph = XREBlueprintGraph.new()
	_block(graph, "break")
	errors = "\n".join(XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray)
	_check(errors.contains("wire its Target"), "an untyped Break says how to type it")


func _collection(graph: XREBlueprintGraph, method: String, params: Dictionary = {}) -> int:
	var id := graph.nodes.size() + 1
	var block := XREBlueprintGraph.make_collection(id, method, Vector2(id * 200, 80))
	(block["params"] as Dictionary).merge(params, true)
	graph.nodes.append(block)
	return id


## Arrays and dictionaries (D-141): their categories and which wires they take,
## Make Array's and Make Dictionary's pins and the literals a wire types, the
## build's errors, the menu, the variables, the generated code and a run of For
## Each whose body waits, For Each Pair, a method on a dictionary and an error.
func _test_collections() -> void:
	var ints := XREBlueprintCollections.array_of(XREBlueprintGraph.INTEGER)
	var any_array := XREBlueprintCollections.array_of(XREBlueprintGraph.VALUE)
	var colors := XREBlueprintCollections.dictionary_of(XREBlueprintGraph.TEXT, XREBlueprintGraph.COLOR)
	_check(XREBlueprintGraph.ports_compatible(ints, any_array) and not XREBlueprintGraph.ports_compatible(any_array, ints) and XREBlueprintGraph.ports_compatible(ints, XREBlueprintGraph.VALUE),
			"Array[int] goes into an untyped array and any value, an untyped one not into Array[int]")
	_check(not XREBlueprintGraph.ports_compatible(ints, XREBlueprintCollections.array_of(XREBlueprintGraph.NUMBER)) and not XREBlueprintGraph.ports_compatible(XREBlueprintGraph.INTEGER, ints)
			and not XREBlueprintGraph.ports_compatible(colors, any_array), "no Array[int] into Array[float], no int into Array[int], no dictionary into an array")
	_check(XREBlueprintCollections.hint(colors) == "Dictionary[String, Color]" and XREBlueprintCollections.key_of(colors) == XREBlueprintGraph.TEXT and XREBlueprintCollections.element_of(colors) == XREBlueprintGraph.COLOR,
			"a dictionary's category keeps its key and value")
	_check(XREBlueprintGraph.port_type(TYPE_ARRAY) == any_array and XREBlueprintCollections.category_of([] as Array[int]) == ints, "an engine's Array is an untyped array; Array[int] is typed")
	var parsed: Variant = XREBlueprintCollections.parse("[1, 2, 5]", ints)
	_check(parsed is Array and (parsed as Array).is_typed() and parsed == [1, 2, 5] and XREBlueprintCollections.parse("[1, \"a\"]", ints) == null and XREBlueprintCollections.parse("[[1]]", any_array) == null,
			"a list's text is read as Array[int]; another element or a nested list is refused")
	_check(XREBlueprintCollections.text_of(parsed) == "[1, 2, 5]", "and written back: %s" % XREBlueprintCollections.text_of(parsed))

	# Make Array's pins: a copy of the last literal, a wire typing the others, a pin removed with its wire moving up.
	var doc := XREBlueprintDocument.new()
	var make := doc.insert_block(XREBlueprintGraph.make_node(0, "make_array", Vector2.ZERO), Vector2.ZERO)
	_check(doc.graph.ports(doc.graph.find_node(make), false)[0][1] == ints and doc.add_pin(make), "Make Array of 0, 0 gives Array[int] and takes a third element")
	var block := doc.graph.find_node(make)
	_check(block["params"]["count"] == 3 and block["params"]["item_2"] == 0 and doc.graph.ports(block, true)[2][0] == "[2]", "its third element is [2], 0: %s" % [block["params"]])
	var number := doc.insert_block(XREBlueprintGraph.make_node(0, "value", Vector2.ZERO), Vector2(-300, 0))
	_check(doc.connect_blocks(number, 0, make, 2), "a float is wired into [2]: %s" % doc.last_error)
	block = doc.graph.find_node(make)
	_check(block["params"]["item_0"] is float and doc.graph.ports(block, false)[0][1] == XREBlueprintCollections.array_of(XREBlueprintGraph.NUMBER), "the other literals are floats now, the array Array[float]: %s" % [block["params"]])
	_check(doc.remove_pin(make, 0), "[0] is removed")
	block = doc.graph.find_node(make)
	_check(block["params"]["count"] == 2 and not (block["params"] as Dictionary).has("item_2") and doc.graph.edges.any(func(edge: Dictionary) -> bool: return edge["to"] == make and edge["to_port"] == 1),
			"[2]'s wire moved up to [1]: %s" % [doc.graph.edges])
	doc.remove_pin(make, 0)
	# D-144: the last one goes too; the empty array stays an Array[float], and a new element is a float.
	_check(doc.remove_pin(make, 0), "the last element is removed: %s" % doc.last_error)
	block = doc.graph.find_node(make)
	var float_array := XREBlueprintCollections.array_of(XREBlueprintGraph.NUMBER)
	_check(block["params"]["count"] == 0 and (block["params"] as Dictionary).get(XREBlueprintGraph.MADE_TYPE) == float_array and doc.graph.ports(block, false)[0][1] == float_array
			and doc.graph.ports(block, true).is_empty() and doc.graph.validate().is_empty(), "an empty Make Array keeps its type: %s %s" % [block["params"], doc.graph.validate()])
	_check(XREBlueprintCompiler._make_collection(doc.graph, block).contains("var value: Array[float] = []"), "and gives an empty Array[float]: %s" % XREBlueprintCompiler._make_collection(doc.graph, block))
	_check(not doc.remove_pin(make, 0) and doc.add_pin(make), "nothing more to remove; the plus adds one")
	block = doc.graph.find_node(make)
	_check(block["params"]["item_0"] is float and not (block["params"] as Dictionary).has(XREBlueprintGraph.MADE_TYPE), "of the type kept, which goes: %s" % [block["params"]])
	var table := doc.insert_block(XREBlueprintGraph.make_node(0, "make_dictionary", Vector2.ZERO), Vector2(0, 300))
	doc.add_pin(table)
	block = doc.graph.find_node(table)
	_check(block["params"]["pairs"] == 2 and block["params"]["key_1"] == "key_1" and block["params"]["value_1"] == 0 and doc.graph.ports(block, true).size() == 4
			and XREBlueprintGraph.variable_pins(block)["pair"], "Make Dictionary takes a pair with a new key: %s" % [block["params"]])
	_check(doc.remove_pin(table, 3) and doc.graph.find_node(table)["params"]["pairs"] == 1, "× of a pair's value removes the pair")

	# A collection wired into a method types its element's literal; a String array's Append adds "".
	doc.add_variable("words", [] as Array[String])
	var words := doc.insert_block(XREBlueprintGraph.make_node(0, "get_variable", Vector2.ZERO), Vector2(0, 600))
	doc.set_parameter(words, "variable", "words")
	var append := doc.insert_block(XREBlueprintGraph.make_collection(0, "array_append", Vector2.ZERO), Vector2(300, 600))
	_check(doc.graph.find_node(append)["params"]["value"] == 0 and doc.connect_blocks(words, 0, append, 1), "Words is wired into Append: %s" % doc.last_error)
	_check(doc.graph.find_node(append)["params"]["value"] == "" and doc.graph.ports(doc.graph.find_node(append), true)[2][1] == XREBlueprintGraph.TEXT, "its Value is a String now")
	_check(not doc.connect_blocks(number, 0, append, 2), "a float doesn't go into a String's Value")

	# A collection, an object and Get's Default take no token: the headset fills no socket of them (D-142).
	var graph := XREBlueprintGraph.new()
	var lookup_block := XREBlueprintGraph.make_collection(1, "dictionary_get", Vector2.ZERO)
	var merge_block := XREBlueprintGraph.make_collection(2, "dictionary_merge", Vector2.ZERO)
	graph.nodes = [lookup_block, merge_block]
	_check(graph.socket_keys(lookup_block) == ["key"] and graph.socket_keys(merge_block).is_empty(),
			"Get's sockets are Key alone, Merge's none: %s %s" % [graph.socket_keys(lookup_block), graph.socket_keys(merge_block)])

	# Validation and the build's errors.
	graph = XREBlueprintGraph.new()
	_block(graph, "make_array", {"count": 9})
	_block(graph, "make_array", {"count": 1})
	_collection(graph, "array_append", {"other": 1})
	var errors := "\n".join(graph.validate())
	_check(errors.contains("#1: invalid number of elements") and errors.contains("#2: item_1 is past its elements") and errors.contains("#3: array_append takes no other"), "collection blocks are checked: %s" % errors)
	graph = XREBlueprintGraph.new()
	var ready := _block(graph, "ready")
	var fresh := _block(graph, "make_array")
	var push := _collection(graph, "array_append")
	var loop := _block(graph, "for_each")
	_wire(graph, ready, push)
	_wire(graph, fresh, push, 0, 1)
	_wire(graph, push, loop)
	errors = "\n".join(XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray)
	_check(errors.contains("Block #%d: wire Array." % loop), "a loop without its array is a build error: %s" % errors)
	_wire(graph, fresh, loop, 0, 1)
	errors = "\n".join(XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray)
	_check(errors.contains("Block #%d changes a new array — wire a variable." % push) and not errors.contains("#%d changes" % loop), "Append into a Make Array is, a loop over one isn't: %s" % errors)

	# The menu: Array and Dictionary, and a new variable of a typed array's wire.
	graph = XREBlueprintGraph.new()
	var sections := XREBlueprintActions.shared().sections({"chip": XREBlueprintActions.NATIVE, "graph": graph})
	var titles: Dictionary[String, Array] = {}
	for section: Dictionary in sections: titles[section["title"]] = (section["actions"] as Array).map(func(action: Dictionary) -> String: return action["title"])
	var array_titles: Array = titles.get("Array", [])
	var dictionary_titles: Array = titles.get("Dictionary", [])
	_check(array_titles.has("For Each") and array_titles.has("Append") and dictionary_titles.has("For Each Pair") and dictionary_titles.has("Make Dictionary"),
			"the menu has Array and Dictionary: %s %s" % [array_titles, dictionary_titles])
	_check(XREBlueprintActions.task_of({"id": "native:for_each"}) == "Flow" and XREBlueprintActions.task_of({"id": "collection:array_append"}) == "Array" and XREBlueprintActions.task_of({"id": "collection:dictionary_get"}) == "Dictionary", "For Each is Flow, Append is Array, a dictionary method Dictionary")
	var offered := XREBlueprintActions.flatten(XREBlueprintActions.shared().sections({"chip": XREBlueprintActions.NATIVE, "graph": graph, "new_variables": true, "pin": {"type": ints, "output": false}}))
	_check(offered.any(func(action: Dictionary) -> bool: return action["title"] == "New Array[int] variable" and (action["variable"] as Array).is_typed()) \
			and not offered.any(func(action: Dictionary) -> bool: return action["title"] == "New int variable"), "an Array[int] input offers a new Array[int] variable, not an int one")

	# A run: For Each over doors waits for its body's Delay, then For Each Pair, then Get on the dictionary.
	graph = XREBlueprintGraph.new()
	graph.variables.append_array([{"name": "doors", "value": [1, 2, 3] as Array[int]}, {"name": "seen", "value": [] as Array[int]}, {"name": "indexes", "value": [] as Array[int]},
			{"name": "names", "value": [] as Array[String]}, {"name": "lamps", "value": {"a": 1, "b": 2} as Dictionary[String, int]}, {"name": "picked", "value": 0}, {"name": "done", "value": false}])
	ready = _block(graph, "ready")
	loop = _block(graph, "for_each")
	var doors := _block(graph, "get_variable", {"variable": "doors"})
	push = _collection(graph, "array_append")
	var seen := _block(graph, "get_variable", {"variable": "seen"})
	var delay := graph.nodes.size() + 1
	var wait := XREBlueprintGraph.make_node(delay, "delay", Vector2.ZERO)
	wait["params"]["seconds"] = 0.05
	graph.nodes.append(wait)
	var pair := _block(graph, "for_each_pair")
	var lamps := _block(graph, "get_variable", {"variable": "lamps"})
	var name := _collection(graph, "array_append")
	var names := _block(graph, "get_variable", {"variable": "names"})
	var pick := _block(graph, "set_variable", {"variable": "picked", "value": 0})
	var lookup := _collection(graph, "dictionary_get", {"key": "b"})
	var done := _block(graph, "set_variable", {"variable": "done", "value": true})
	var index := _collection(graph, "array_append")
	var indexes := _block(graph, "get_variable", {"variable": "indexes"})
	_wire(graph, ready, loop)
	_wire(graph, doors, loop, 0, 1)
	_wire(graph, loop, push, 0, 0)
	_wire(graph, seen, push, 0, 1)
	_wire(graph, loop, push, 1, 2)
	_wire(graph, push, delay)
	_wire(graph, delay, index)
	_wire(graph, indexes, index, 0, 1)
	_wire(graph, loop, index, 2, 2)
	_wire(graph, loop, pair, 3, 0)
	_wire(graph, lamps, pair, 0, 1)
	_wire(graph, pair, name, 0, 0)
	_wire(graph, names, name, 0, 1)
	_wire(graph, pair, name, 1, 2)
	_wire(graph, pair, pick, 3, 0)
	_wire(graph, lamps, lookup, 0, 0)
	_wire(graph, lookup, pick, 0, 1)
	_wire(graph, pick, done)
	_check(graph.validate().is_empty(), "the loops' graph is valid: %s" % graph.validate())
	_check(graph.ports(graph.find_node(loop), false)[1][1] == XREBlueprintGraph.INTEGER and graph.ports(graph.find_node(pair), false)[1][1] == XREBlueprintGraph.TEXT
			and graph.ports(graph.find_node(lookup), false)[0][1] == XREBlueprintGraph.INTEGER, "Element is an int, Key a String, Get's Value an int, by the wires")
	var source := XREBlueprintCompiler.compile(graph)["code"] as String
	_check(source.contains("var _bp_var_doors: Array[int] = [1, 2, 3]") and source.contains("\titems.append(a0)\n") and source.contains("return _bp_loop(run, %d, _bp_array(value), %d, %d)" % [loop, push, pair])
			and source.contains("_bp_get(items, a0, run, %d)" % lookup), "collections compile readably")
	var scene := Node.new()
	scene.set_script(_script(graph))
	var problems: Array[String] = []
	scene.connect(&"blueprint_error", func(_id: int, message: String) -> void: problems.append(message))
	root.add_child(scene)
	await process_frame
	_check(scene.get("_bp_var_seen") == [1] and scene.get("_bp_var_indexes") == [], "the body's Delay holds the loop at the first door: %s" % [scene.get("_bp_var_seen")])
	await _wait_until(func() -> bool: return scene.get("_bp_var_done") == true)
	_check(scene.get("_bp_var_seen") == [1, 2, 3] and scene.get("_bp_var_indexes") == [0, 1, 2], "each door in turn, its index read after the Delay: %s %s" % [scene.get("_bp_var_seen"), scene.get("_bp_var_indexes")])
	_check(scene.get("_bp_var_names") == ["a", "b"] and scene.get("_bp_var_picked") == 2, "For Each Pair gave the keys, Get b gave 2")
	_check(problems.is_empty() and (scene.get("_bp_runs") as Array).is_empty(), "no errors, the run ended: %s" % [problems])
	# Get past the end and a key a dictionary hasn't, without Default, are the block's errors.
	_check(scene.call("_bp_at", [1] as Array[int], 3, null, 7) == null and scene.call("_bp_get", {"a": 1}, "z", null, 8) == null and problems.size() == 2 and problems[0].contains("out of"),
			"an index out of range and a missing key are errors: %s" % [problems])
	scene.queue_free()
	await process_frame
	# Make Array of an int and a float gives Array[float]; Make Dictionary a typed one; Size reads either.
	graph = XREBlueprintGraph.new()
	graph.variables.append({"name": "kept", "value": [] as Array[float]})
	var floats := _block(graph, "make_array", {"item_0": 1, "item_1": 2.5})
	var colored := _block(graph, "make_dictionary", {"key_0": "open", "value_0": Color.GREEN})
	var size := _collection(graph, "array_size")
	_wire(graph, floats, size, 0, 0)
	ready = _block(graph, "ready")
	var keep := _block(graph, "set_variable", {"variable": "kept", "value": [] as Array[float]})
	_wire(graph, ready, keep)
	_wire(graph, floats, keep, 0, 1)
	source = XREBlueprintCompiler.compile(graph)["code"] as String
	_check(source.contains("var value: Array[float] = [1.0, 2.5]") and source.contains("var value: Dictionary[String, Color] = {\"open\": Color(0, 1, 0, 1)}") and source.contains("_bp_var_kept.assign(_bp_array(value))"), "Make blocks compile to typed literals")
	var instance := Node.new()
	instance.set_script(_script(graph))
	root.add_child(instance)
	var made: Variant = instance.call("_bp_value%d" % floats)
	var table_made: Variant = instance.call("_bp_value%d" % colored)
	_check(made is Array and (made as Array).get_typed_builtin() == TYPE_FLOAT and made == [1.0, 2.5] and instance.call("_bp_value%d" % size) == 2, "Make Array gives Array[float] [1.0, 2.5] of size 2")
	_check(table_made is Dictionary and (table_made as Dictionary).get_typed_value_builtin() == TYPE_COLOR and (table_made as Dictionary)["open"] == Color.GREEN, "Make Dictionary gives Dictionary[String, Color]")
	_check(instance.get("_bp_var_kept") == [1.0, 2.5], "Set takes Make Array's elements: %s" % [instance.get("_bp_var_kept")])
	instance.queue_free()
	await process_frame
	await _test_collections_d143()


## D-143: a loop over its rack's list ending at Break, an array of scene
## objects by their paths, a packed array's port, a wire taking a rack's place,
## a method's own list changed is a build error.
func _test_collections_d143() -> void:
	_check(XREBlueprintGraph.port_type(TYPE_PACKED_INT32_ARRAY) == XREBlueprintCollections.array_of(XREBlueprintGraph.INTEGER) and XREBlueprintGraph.port_type(TYPE_PACKED_STRING_ARRAY) == XREBlueprintCollections.array_of(XREBlueprintGraph.TEXT),
			"an engine's packed arrays are typed arrays")
	_check(XREBlueprintCollections.parse_any("[1, 2.5]", XREBlueprintCollections.array_of(XREBlueprintGraph.VALUE)) == [1.0, 2.5] and XREBlueprintCollections.parse_any("[1, \"a\"]", XREBlueprintCollections.array_of(XREBlueprintGraph.VALUE)) == null,
			"an untyped rack's list takes its elements' type")
	_check(XREBlueprintCollections.appended(null, XREBlueprintCollections.array_of(XREBlueprintGraph.VALUE)) == [0] and XREBlueprintCollections.appended([3] as Array[int], XREBlueprintCollections.array_of(XREBlueprintGraph.INTEGER)) == [3, 3],
			"a rack's plus adds a copy of the last, or 0")
	var graph := XREBlueprintGraph.new()
	graph.variables.append_array([{"name": "seen", "value": [] as Array[int]}, {"name": "done", "value": false}])
	var ready := _block(graph, "ready")
	var loop := _block(graph, "for_each", {"collection": [4, 5, 6] as Array[int]})
	var push := _collection(graph, "array_append")
	var seen := _block(graph, "get_variable", {"variable": "seen"})
	var stop := _block(graph, "branch")
	var five := _block(graph, "equals", {"b": 5})
	var done := _block(graph, "set_variable", {"variable": "done", "value": true})
	var count := _collection(graph, "array_size", {XREBlueprintGraph.SCENE_TARGETS: ["A", "B"] as Array[String]})
	_wire(graph, ready, loop)
	_wire(graph, loop, push, 0, 0)
	_wire(graph, seen, push, 0, 1)
	_wire(graph, loop, push, 1, 2)
	_wire(graph, push, stop)
	_wire(graph, loop, five, 1, 0)
	_wire(graph, five, stop, 0, 1)
	_wire(graph, stop, loop, 0, 2)
	_wire(graph, loop, done, 3, 0)
	_check(graph.validate().is_empty() and graph.ports(graph.find_node(loop), false)[1][1] == XREBlueprintGraph.INTEGER, "a loop over its rack's Array[int] gives ints: %s" % graph.validate())
	var source := XREBlueprintCompiler.compile(graph)["code"] as String
	_check(source.contains("var value: Variant = [4, 5, 6]") and source.contains("_bp_targets([\"A\", \"B\"], run, %d)" % count) and source.contains("%d: block_id = _bp_loop_break(run, %d, %d)" % [XREBlueprintCompiler.BREAK + loop, loop, done]),
			"a rack's list, the objects and Break compile readably")
	var scene := Node.new()
	for name: String in ["A", "B"]:
		var child := Node.new()
		child.name = name
		scene.add_child(child)
	scene.set_script(_script(graph))
	root.add_child(scene)
	await _wait_until(func() -> bool: return scene.get("_bp_var_done") == true)
	_check(scene.get("_bp_var_seen") == [4, 5], "Break at 5 ended the loop and ran Completed: %s" % [scene.get("_bp_var_seen")])
	_check(scene.call("_bp_value%d" % count) == 2, "the array of the scene's A and B has two objects")
	_check((scene.get("_bp_runs") as Array).is_empty(), "the run ended")
	scene.queue_free()
	await process_frame
	# A method's own list, changed, is a new array; a wire takes a rack's place.
	graph = XREBlueprintGraph.new()
	ready = _block(graph, "ready")
	push = _collection(graph, "array_append", {"collection": [1] as Array[int]})
	_wire(graph, ready, push)
	_check("\n".join(XREBlueprintCompiler.compile(graph)["errors"] as PackedStringArray).contains("Block #%d changes a new array" % push), "Append to a rack's list is a build error")
	var doc := XREBlueprintDocument.new()
	doc.add_variable("kept", [] as Array[int])
	var held := doc.insert_block(XREBlueprintGraph.make_collection(0, "array_size", Vector2.ZERO), Vector2.ZERO)
	doc.set_parameter(held, "collection", [7, 8] as Array[int])
	var kept := doc.insert_block(XREBlueprintGraph.make_node(0, "get_variable", Vector2.ZERO), Vector2(-300, 0))
	_check(doc.connect_blocks(kept, 0, held, 0) and not (doc.graph.find_node(held)["params"] as Dictionary).has("collection"), "a wire into Size takes its rack's place")


func _operator(graph: XREBlueprintGraph, op: String, params: Dictionary = {}) -> int:
	var id := graph.nodes.size() + 1
	var block := XREBlueprintGraph.make_operator(id, op, Vector2(id * 200, 80))
	(block["params"] as Dictionary).merge(params, true)
	graph.nodes.append(block)
	return id


## The operators (D-065): their types, a wire's type taken by the other
## literal, the menu, the generated code and its values.
## The block palette's variants (D-093): kinds and wires counted, the likely
## next ranked by them, the task groups, the best matches of a search, and the
## menu's tiles and task chips with where an action was picked.
func _test_palette_variants() -> void:
	var sin_block := XREBlueprintGraph.make_call(1, XREBlueprintFunctions.global("sin"), Vector2.ZERO)
	_check(XREBlueprintStats.key_of(sin_block) == "call:sin" and XREBlueprintStats.key_of(XREBlueprintGraph.make_operator(1, "multiply", Vector2.ZERO)) == "operator:multiply"
			and XREBlueprintStats.key_of(XREBlueprintGraph.make_node(1, "ready", Vector2.ZERO)) == "signal:ready" and XREBlueprintStats.key_of({}) == "",
			"a block's kind for the menu is its function, operator or signal")
	var getter := XREBlueprintGraph.make_node(1, "get_variable", Vector2.ZERO)
	getter["params"]["variable"] = "phase"
	_check(XREBlueprintStats.key_of(getter) == "get_variable", "Get Variable of any variable is one kind")
	# Sin into Multiply twice and into Divide once, as in the project's graphs.
	var graph := XREBlueprintGraph.new()
	for pair: Array in [["multiply", 0], ["multiply", 0], ["divide", 0]]:
		var from := graph.nodes.size() + 1
		graph.nodes.append(XREBlueprintGraph.make_call(from, XREBlueprintFunctions.global("sin"), Vector2.ZERO))
		graph.nodes.append(XREBlueprintGraph.make_operator(from + 1, pair[0], Vector2.ZERO))
		_wire(graph, from, from + 1)
	var stats := XREBlueprintStats.new()
	stats.add_graph(graph)
	_check(stats.kind_count("call:sin") == 3 and stats.pair_count("call:sin", "operator:multiply") == 2 and stats.pair_count("call:sin", "operator:divide") == 1, "kinds and wires are counted")
	var project := XREBlueprintStats.new()
	project.update(graph)
	_check(project.kind_count("signal:ready") > 0 and project.pair_count("call:sin", "operator:multiply") > 2, "the project's graph files are counted, with the graph being edited")
	var actions := XREBlueprintActions.new()
	var pin := {"type": XREBlueprintGraph.NUMBER, "output": true, "key": "call:sin"}
	var next := actions.suggest({"graph": graph, "pin": pin}, 5, stats)
	_check(next.size() == 5 and next[0]["id"] == "operator:multiply" and next[1]["id"] == "operator:divide", "a wire from Sin suggests Multiply, then Divide: %s" % [next.map(func(action: Dictionary) -> String: return str(action["id"]))])
	_check(next.all(func(action: Dictionary) -> bool: return XREBlueprintActions.fits_pin(action, XREBlueprintGraph.NUMBER, true)), "suggestions fit the wire")
	var into := actions.suggest({"graph": graph, "pin": {"type": XREBlueprintGraph.NUMBER, "output": false, "key": "operator:multiply"}}, 3, stats)
	_check(not into.is_empty() and into[0]["id"] == "global:sin", "a wire from Multiply's input suggests what goes into it: Sin")
	var keys: Array[String] = []
	for action: Dictionary in actions.suggest({"graph": graph}, 12, stats): keys.append(XREBlueprintStats.key_of(action.get("block", {})))
	var unique: Array[String] = []
	for key: String in keys:
		if not unique.has(key): unique.append(key)
	_check(keys.size() == 12 and unique.size() == 12, "one suggestion of each kind")
	actions.remember({"id": "preset:delay"})
	_check(actions.suggest({"graph": graph, "pin": {"type": XREBlueprintGraph.EXEC, "output": true}}, 3, stats)[0]["id"] == "preset:delay", "without wires counted, what was added lately comes first")
	var cases := {"operator:multiply": "Arithmetic", "operator:modulo": "Arithmetic", "operator:greater": "Logic", "operator:and": "Logic", "native:equals": "Logic",
			"global:sin": "Math", "preset:delay": "Flow", "native:branch": "Flow", "global:print": "Utility", "preset:print": "Utility", "static:XREBlueprintLibrary.get_time": "Utility",
			"set:Node3D.position": "Move", "method:Node3D.rotate_y": "Move", "set:Node3D.visible": "Look", "set:Label3D.text": "Look", "preset:play_sound": "Sound",
			"variable:get:phase": "Variables", "native:value": "Variables", "method:Node.queue_free": "Object", "set:Node3D.rotation_edit_mode": "Move"}
	var wrong: Array[String] = []
	for id: String in cases:
		var kind := "variable" if id.begins_with("variable:") else "pure"
		var category := "@GlobalScope · math" if id == "global:sin" else "@GlobalScope · general" if id == "global:print" else "Time" if id.ends_with("get_time") else ""
		if XREBlueprintActions.task_of({"id": id, "kind": kind, "category": category}) != cases[id]: wrong.append(id)
	_check(wrong.is_empty() and XREBlueprintActions.task_of({"id": "signal:ready", "kind": "event"}) == "Events", "blocks go to their task groups: %s" % [wrong])
	var scene := Node3D.new()
	var cube := MeshInstance3D.new()
	cube.name = "Cube"
	scene.add_child(cube)
	root.add_child(scene)
	var math := XREBlueprintActions.flatten(actions.sections({"task": "Math", "node": cube, "host": scene, "graph": graph}))
	_check(math.any(func(action: Dictionary) -> bool: return action["id"] == "global:sin") and not math.any(func(action: Dictionary) -> bool: return action["id"] == "operator:multiply")
			and math.all(func(action: Dictionary) -> bool: return XREBlueprintActions.task_of(action) == "Math"), "Math has @GlobalScope's math functions, not the operators (D-095)")
	var arithmetic := XREBlueprintActions.flatten(actions.sections({"task": "Arithmetic", "node": cube, "host": scene, "graph": graph})).map(func(action: Dictionary) -> String: return str(action["id"]))
	var logic := XREBlueprintActions.flatten(actions.sections({"task": "Logic", "node": cube, "host": scene, "graph": graph})).map(func(action: Dictionary) -> String: return str(action["id"]))
	_check(arithmetic.has("operator:multiply") and arithmetic.has("operator:divide") and not arithmetic.has("operator:greater"), "Arithmetic has + − × ÷")
	_check(logic.has("operator:greater") and logic.has("operator:and") and logic.has("native:equals") and not logic.has("operator:add"), "Logic has the comparisons, Equal, AND, OR, NOT")
	var utility := XREBlueprintActions.flatten(actions.sections({"task": "Utility", "node": cube, "host": scene, "graph": graph})).map(func(action: Dictionary) -> String: return str(action["title"]))
	_check(utility.has("Print") and utility.has("Get Time") and not XREBlueprintActions.flatten(actions.sections({"task": "Flow", "node": cube, "host": scene, "graph": graph})).any(func(action: Dictionary) -> bool: return action["title"] in ["Print", "Get Time"]),
			"Print and Get Time are Utility, not Flow")
	var move := XREBlueprintActions.flatten(actions.sections({"task": "Move", "node": cube, "host": scene, "graph": graph}))
	_check(move.any(func(action: Dictionary) -> bool: return action["id"] == "set:Node3D.position") and move.any(func(action: Dictionary) -> bool: return action["id"] == "preset:tween"), "Move has the object's position and Tween Property")
	var object := actions.sections({"task": "Object", "node": cube, "host": scene, "graph": graph})
	_check(object.any(func(section: Dictionary) -> bool: return section["advanced"]), "Object keeps Advanced")
	var groups := actions.by_task({"node": cube, "host": scene, "graph": graph}, 8, stats)
	_check(groups.keys() == XREBlueprintActions.TASKS and (groups["Math"] as Array).size() == 8 and not (groups["Move"] as Array).is_empty(), "the ring's groups are the task groups, at most 8 blocks each")
	_check((groups["Sound"] as Array).is_empty(), "a cube has no Sound: the library's Play Sound is a player's, not the cube's (D-095)")
	_check(actions.object_tasks({"node": cube, "host": scene, "graph": graph}) == ["Move", "Look", "Object"], "the cube's groups: Move, Look, Object")
	var peer := Node.new()
	scene.add_child(peer)
	_check(actions.object_tasks({"node": peer, "host": scene, "graph": graph}) == ["Object"] and actions.object_tasks({"graph": graph}).is_empty(),
			"a plain Node, as a graph of networking has, has no Move, Look or Sound; no object, no object's groups")
	var player := AudioStreamPlayer3D.new()
	scene.add_child(player)
	_check(actions.object_tasks({"node": player, "host": scene, "graph": graph}).has("Sound"), "a sound player has Sound")
	var best := actions.sections({"chip": XREBlueprintActions.ALL, "node": cube, "host": scene, "graph": graph, "query": "sin"})
	_check(best[0]["title"] == "Best matches" and best[0]["actions"][0]["id"] == "global:sin", "a search shows its best matches first: Sin for \"sin\", before Asin")
	# The menu: tiles over the chips, chips by task, and where an action was picked.
	var menu := XREBlueprintActionMenu.new()
	menu.actions = XREBlueprintActions.new()
	menu.stats = stats
	root.add_child(menu)
	var contexts: Array[Dictionary] = [{"label": "Cube", "node": cube}]
	menu.open(contexts, scene, graph, pin)
	_check(menu.get_tiles().is_empty() and not (menu.get_node("Tiles") as Control).visible, "the list has no tiles by default")
	var chosen: Array[Dictionary] = []
	menu.action_chosen.connect(func(action: Dictionary) -> void: chosen.append(action))
	menu.set_tiles(true)
	var tiles := menu.get_tiles()
	_check(tiles.size() == XREBlueprintActionMenu.TILE_COUNT and tiles[0]["id"] == "operator:multiply" and (menu.get_node("Tiles") as Control).visible, "tiles show the likely next blocks for the wire")
	((menu.get_node("Tiles") as Node).get_child(0) as Button).pressed.emit()
	_check(chosen.size() == 1 and chosen[0]["id"] == "operator:multiply" and chosen[0]["origin"] == "tile", "a tile adds its block and says it came from a tile")
	menu.choose_chip(menu.get_chip_titles().find("All"))
	menu.search.text = "sin"
	menu.refresh()
	_check(not (menu.get_node("Tiles") as Control).visible, "tiles make way for a search's results")
	var row := menu.tree.get_root().get_first_child().get_first_child()
	row.select(0)
	menu.tree.item_activated.emit()
	_check(chosen.size() == 2 and chosen[1]["origin"] == "search", "a row picked while searching says so")
	menu.search.text = ""
	menu.refresh()
	menu.set_task_groups(true)
	var expected := PackedStringArray(XREBlueprintActions.GENERAL_TASKS)
	expected.append_array(["Move", "Look", "Object", "All"])
	_check(menu.get_chip_titles() == expected, "by task, the chips are the general groups, the cube's and All: %s" % [menu.get_chip_titles()])
	menu.clear_pin()
	menu.choose_chip(menu.get_chip_titles().find("Math"))
	_check(menu.get_listed().any(func(action: Dictionary) -> bool: return action["id"] == "global:sin") and menu.get_listed().all(func(action: Dictionary) -> bool: return XREBlueprintActions.task_of(action) == "Math"), "the Math chip lists Sin")
	menu.choose_chip(menu.get_chip_titles().find("Arithmetic"))
	_check(menu.get_listed().any(func(action: Dictionary) -> bool: return action["id"] == "operator:multiply"), "the Arithmetic chip lists Multiply")
	menu.choose_chip(menu.get_chip_titles().find("Move"))
	_check(menu.get_listed().any(func(action: Dictionary) -> bool: return action["id"] == "set:Node3D.position"), "the Move chip lists the first context object's position")
	menu.set_task_groups(false)
	_check(menu.get_chip_titles()[0] == "Cube", "by source, the context object's chip comes back")
	menu.free()
	scene.free()


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
	# D-080: the types a wire into an operand may bring, by what the operator works on.
	var candidates := [TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR]
	_check(doc.graph.operand_types(doc.graph.find_node(offset), "a", candidates) == [TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_COLOR],
			"a free operand of Add takes anything but a bool: the other literal takes its type")
	_check(doc.graph.operand_types(doc.graph.find_node(sum), "b", candidates) == [TYPE_INT, TYPE_FLOAT], "by a wired integer, Add's B takes an int or a float")
	_check(doc.graph.operand_types(doc.graph.find_node(scale), "b", candidates) == [TYPE_INT, TYPE_FLOAT, TYPE_VECTOR3], "by a wired vector, Multiply's B takes a number or the same vector")
	_check(doc.graph.operand_types(XREBlueprintGraph.make_node(9, "equals", Vector2.ZERO), "a", candidates) == candidates, "Equal compares anything")

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
	_check(not natives.any(func(action: Dictionary) -> bool: return str(action["id"]).begins_with("variable:new:")), "without a view that adds them, no new variables are offered")
	var offered := XREBlueprintActions.flatten(actions.sections({"chip": XREBlueprintActions.NATIVE, "host": scene, "graph": doc.graph, "new_variables": true, "pin": {"type": XREBlueprintGraph.NUMBER, "output": false}}))
	_check(offered.any(func(action: Dictionary) -> bool: return action["id"] == "variable:new:float" and action["variable"] is float)
			and not offered.any(func(action: Dictionary) -> bool: return action["id"] in ["variable:new:String", "variable:new:int"]),
			"a wire from a number input offers a new variable of its type only, not even an int it takes (D-078, D-079)")
	var any_value := XREBlueprintActions.flatten(actions.sections({"chip": XREBlueprintActions.NATIVE, "graph": doc.graph, "new_variables": true, "pin": {"type": XREBlueprintGraph.VALUE, "output": false, "value_types": [TYPE_VECTOR3]}}))
	_check(any_value.filter(func(action: Dictionary) -> bool: return str(action["id"]).begins_with("variable:new:")).map(func(action: Dictionary) -> String: return str(action["id"])) == ["variable:new:Vector3"]
			and not any_value.any(func(action: Dictionary) -> bool: return action["id"] == "variable:get:door_open"),
			"an input of any value offers new and existing variables of the type the view says is in it (D-079)")
	var host_chip := XREBlueprintActions.flatten(actions.sections({"chip": XREBlueprintActions.CONTEXT, "node": scene, "host": scene, "graph": doc.graph, "new_variables": true}))
	_check(host_chip.any(func(action: Dictionary) -> bool: return action["id"] == "variable:new:Vector3") and host_chip.any(func(action: Dictionary) -> bool: return action["id"] == "variable:get:door_open"),
			"the host's chip offers its graph's variables, new ones too")
	var id := doc.insert_block(preset["block"], Vector2(200, 0), {"from": 1, "from_port": 0}, player)
	_check(id > 0 and doc.graph.find_node(id)["params"]["target"] == "Animations" and not doc.target_is_connected(id), "an action's block is added aimed at its object")
	actions.remember(preset)
	_check(actions.sections({"chip": XREBlueprintActions.CONTEXT, "node": player, "host": scene, "graph": doc.graph})[0]["title"] == "Recent", "recently added actions come first")
	scene.free()


## The graph's own functions (docs/blueprint_functions.md): one created and
## its body shown as the graph, an input and an output typed and named by
## their first wire with the calls following, pure and back with undo, a pin
## renamed and removed, the file saved and opened; the generated code: a
## function waiting for its Delay, a pure one, a call too deep, a pure one
## reading itself and a pin without a type.
func _test_functions() -> void:
	var doc := XREBlueprintDocument.new()
	doc.add_variable("opened", false)
	doc.add_variable("result", false)
	doc.add_variable("speed", 0.0)
	var name := doc.create_function()
	_check(name == "function_1" and doc.root.functions.size() == 1 and doc.rename_function(name, "open_door"), "a new function is function_1; it is renamed")
	var input := doc.add_function_pin("open_door", true)
	var output := doc.add_function_pin("open_door", false)
	_check(input == "input_1" and output == "output_1", "new pins are input_1 and output_1")
	# A call made while the input has no type yet: its literal follows the first wire.
	var call := doc.add_function_call("open_door", Vector2(300, 100), {"from": 1, "from_port": 0})
	var block := doc.graph.find_node(call)
	_check(call > 0 and doc.graph.ports(block, true).size() == 2 and doc.graph.ports(block, false).size() == 2, "the call has In, input_1, Then and output_1: %s" % doc.last_error)
	var reader := doc.insert_block(XREBlueprintGraph.make_node(0, "set_variable", Vector2.ZERO), Vector2(600, 100), {"from": call, "from_port": 0})
	doc.set_parameter(reader, "variable", "result")

	_check(doc.open_function("open_door") and doc.opened == "open_door" and doc.graph != doc.root, "the body is the graph the views show")
	var entry := doc.graph.find_node(1)
	_check(doc.graph.title_of(entry) == "open_door" and doc.graph.ports(entry, false).size() == 2 and doc.graph.ports(doc.graph.find_node(2), true).size() == 2, "Entry is named after the function: Then and input_1; Return: In and output_1")
	var delay := doc.insert_block(XREBlueprintGraph.make_node(0, "delay", Vector2.ZERO), Vector2(200, 100))
	doc.set_parameter(delay, "seconds", 0.05)
	var opener := doc.insert_block(XREBlueprintGraph.make_node(0, "set_variable", Vector2.ZERO), Vector2(400, 100))
	doc.set_parameter(opener, "variable", "opened")
	doc.set_parameter(opener, "value", true)
	var getter := doc.insert_block(XREBlueprintGraph.make_node(0, "get_variable", Vector2.ZERO), Vector2(400, 300))
	doc.set_parameter(getter, "variable", "opened")
	doc.disconnect_blocks(1, 0, 2, 0)
	doc.connect_blocks(1, 0, delay, 0)
	doc.connect_blocks(delay, 0, opener, 0)
	doc.connect_blocks(opener, 0, 2, 0)
	_check(doc.connect_blocks(1, 1, delay, 1), "Entry's input_1 goes into Delay's Seconds: %s" % doc.last_error)
	_check(doc.root.functions[0]["inputs"][0] == {"key": "seconds", "type": TYPE_FLOAT}, "the first wire typed and named the input: %s" % [doc.root.functions[0]["inputs"]])
	_check(doc.connect_blocks(getter, 0, 2, 1), "Get opened goes into Return's output_1: %s" % doc.last_error)
	_check(doc.root.functions[0]["outputs"][0] == {"key": "value", "type": TYPE_BOOL}, "and the output: %s" % [doc.root.functions[0]["outputs"]])
	block = doc.root.find_node(call)
	_check(block["function"]["args"][0]["key"] == "seconds" and is_equal_approx(float(block["params"]["seconds"]), 0.05) and block["function"]["awaits"], "the call's input is seconds with Delay's 0.05; it waits: %s" % [block["params"]])
	var wires := doc.graph.edges.size()
	doc.open_function("")
	doc.undo()
	_check(doc.opened == "" and not (doc.root.find_node(call)["function"]["outputs"][0] as Dictionary).has("type"), "an undo while the file's graph shows undoes the body's edit and its calls")
	doc.redo()
	_check(doc.connect_blocks(call, 1, reader, 1), "the call's output, a bool now, goes into Set result: %s" % doc.last_error)
	doc.open_function("open_door")
	_check(doc.graph.edges.size() == wires, "redo puts it back in the body")

	# Pure and back: the execution wires go, the blocks stay; undo brings them back.
	_check(doc.set_function_pure("open_door", true), "the function becomes pure")
	_check(doc.graph.find_node(delay).size() > 0 and not doc.graph.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == 1 and edge["to"] == delay and edge["to_port"] == 0), "Entry lost Then and its wire; Delay stayed")
	block = doc.root.find_node(call)
	_check(doc.root.ports(block, true).size() == 1 and not doc.root.edges.any(func(edge: Dictionary) -> bool: return edge["to"] == call and edge["from"] == 1), "the call lost In and its wire")
	_check(doc.root.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == call and edge["from_port"] == 0 and edge["to"] == reader and edge["to_port"] == 1), "its output's wire followed it to port 0")
	doc.undo()
	_check(not doc.root.functions[0]["pure"] and doc.root.edges.any(func(edge: Dictionary) -> bool: return edge["to"] == call and edge["from"] == 1), "undo makes it impure with its wires")

	# A pin renamed keeps its wires and values; one removed takes them away.
	_check(doc.rename_function_pin("open_door", true, "seconds", "wait") and is_equal_approx(float(doc.root.find_node(call)["params"]["wait"]), 0.05), "renamed, the call's value follows")
	_check(doc.graph.edges.any(func(edge: Dictionary) -> bool: return edge["from"] == 1 and edge["from_port"] == 1 and edge["to"] == delay), "and the body's wire")
	_check(not doc.delete_function("open_door") and doc.last_error.contains("1 calls"), "a function with calls isn't deleted")

	# A pure function: half of its input.
	doc.open_function("")
	var half := doc.create_function(true, "door_speed")
	doc.add_function_pin(half, true)
	doc.add_function_pin(half, false)
	doc.open_function(half)
	_check(doc.graph.edges.is_empty() and doc.graph.ports(doc.graph.find_node(1), false).size() == 1, "a pure body: Entry has no Then, nothing is wired")
	var divide := doc.insert_block(XREBlueprintGraph.make_operator(0, "divide", Vector2.ZERO), Vector2(200, 100))
	doc.set_parameter(divide, "b", 2.0)
	_check(doc.connect_blocks(1, 0, divide, 0) and doc.connect_blocks(divide, 0, 2, 0), "input into A, Result into Return: %s" % doc.last_error)
	var signature: Dictionary = doc.root.functions[1]
	_check(signature["inputs"][0] == {"key": "a", "type": TYPE_FLOAT} and signature["outputs"][0] == {"key": "result", "type": TYPE_FLOAT}, "typed by A's number, named after the ports: %s" % [signature])
	doc.open_function("")
	var speed := doc.insert_block(XREBlueprintGraph.make_node(0, "set_variable", Vector2.ZERO), Vector2(900, 100), {"from": reader, "from_port": 0})
	doc.set_parameter(speed, "variable", "speed")
	var read := doc.add_function_call(half, Vector2(700, 300))
	doc.set_parameter(read, "a", 3.0)
	_check(doc.connect_blocks(read, 0, speed, 1) and doc.root.ports(doc.root.find_node(read), true).size() == 1, "a pure call: its input, its output, no execution: %s" % doc.last_error)

	# Saved and opened again.
	var path := "user://test_functions.tres"
	_check(ResourceSaver.save(doc.root, path) == OK, "the graph is saved")
	var loaded := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as XREBlueprintGraph
	_check(loaded != null and loaded.functions.size() == 2 and loaded.functions[0]["inputs"][0]["key"] == "wait" and loaded.validate().is_empty(), "a saved graph keeps its functions: %s" % [loaded.validate() if loaded != null else PackedStringArray()])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	# The generated code: the caller waits for the function's Delay; the pure one halves.
	var source := XREBlueprintCompiler.compile(doc.root)
	_check((source["errors"] as PackedStringArray).is_empty(), "functions build: %s" % [source["errors"]])
	var code: String = source["code"]
	_check(code.contains("func _bp_fn_open_door(parent: XREBlueprintRun, entered: int, a0: Variant) -> Array:") and code.contains("await _bp_fn_open_door(run, entered, a0)") and code.contains("func _bp_f0_execute("), "a function compiles to _bp_fn_ and its body's steps")
	var scene := Node.new()
	scene.set_script(_script(doc.root))
	root.add_child(scene)
	await _wait_until(func() -> bool: return scene.get("_bp_var_result") == true)
	_check(scene.get("_bp_var_opened") == true and scene.get("_bp_var_result") == true and is_equal_approx(float(scene.get("_bp_var_speed")), 1.5), "the call waited for its body, got its output; the pure one gave 1.5: %s %s" % [scene.get("_bp_var_result"), scene.get("_bp_var_speed")])
	_check((scene.get("_bp_runs") as Array).is_empty(), "the run ended")
	scene.queue_free()
	await process_frame

	# A loop in a body (D-141 in D-145): For Each runs its body per element, Break at 5 runs Completed, then Return.
	doc = XREBlueprintDocument.new()
	doc.add_variable("last", 0)
	doc.add_variable("done", false)
	var walk := doc.create_function(false, "walk")
	doc.open_function(walk)
	var each := doc.insert_block(XREBlueprintGraph.make_node(0, "for_each", Vector2.ZERO), Vector2(200, 100))
	doc.set_parameter(each, "collection", [4, 5, 6] as Array[int])
	var keep := doc.insert_block(XREBlueprintGraph.make_node(0, "set_variable", Vector2.ZERO), Vector2(400, 100))
	doc.set_parameter(keep, "variable", "last")
	var stop := doc.insert_block(XREBlueprintGraph.make_node(0, "branch", Vector2.ZERO), Vector2(600, 100))
	var five := doc.insert_block(XREBlueprintGraph.make_node(0, "equals", Vector2.ZERO), Vector2(400, 300))
	doc.set_parameter(five, "b", 5)
	doc.disconnect_blocks(1, 0, 2, 0)
	var wired := doc.connect_blocks(1, 0, each, 0) and doc.connect_blocks(each, 0, keep, 0) and doc.connect_blocks(each, 1, keep, 1) and doc.connect_blocks(keep, 0, stop, 0) 			and doc.connect_blocks(each, 1, five, 0) and doc.connect_blocks(five, 0, stop, 1) and doc.connect_blocks(stop, 0, each, 2) and doc.connect_blocks(each, 3, 2, 0)
	_check(wired, "a body with For Each and its Break: %s" % doc.last_error)
	doc.open_function("")
	var walked := doc.add_function_call(walk, Vector2(300, 100), {"from": 1, "from_port": 0})
	var finished := doc.insert_block(XREBlueprintGraph.make_node(0, "set_variable", Vector2.ZERO), Vector2(600, 100), {"from": walked, "from_port": 0})
	doc.set_parameter(finished, "variable", "done")
	doc.set_parameter(finished, "value", true)
	source = XREBlueprintCompiler.compile(doc.root)
	_check((source["errors"] as PackedStringArray).is_empty() and (source["code"] as String).contains("_bp_loop_break(run, %d" % each), "a loop in a body builds, Break in the body's steps: %s" % [source["errors"]])
	scene = Node.new()
	scene.set_script(_script(doc.root))
	root.add_child(scene)
	await _wait_until(func() -> bool: return scene.get("_bp_var_done") == true)
	_check(scene.get("_bp_var_last") == 5 and scene.get("_bp_var_done") == true, "the body's loop broke at 5 and the call went on: %s %s" % [scene.get("_bp_var_last"), scene.get("_bp_var_done")])
	scene.queue_free()
	await process_frame

	# Too deep: a function that calls itself forever is an error of the event, not a crash.
	doc = XREBlueprintDocument.new()
	var forever := doc.create_function(false, "forever")
	doc.open_function(forever)
	doc.disconnect_blocks(1, 0, 2, 0)
	_check(doc.add_function_call(forever, Vector2(200, 100), {"from": 1, "from_port": 0}) > 0, "a function calls itself: %s" % doc.last_error)
	doc.open_function("")
	doc.add_function_call(forever, Vector2(300, 100), {"from": 1, "from_port": 0})
	scene = Node.new()
	scene.set_script(_script(doc.root))
	var errors: Array[String] = []
	scene.connect("blueprint_error", func(_id: int, message: String) -> void: errors.append(message))
	root.add_child(scene)
	await _wait_until(func() -> bool: return not errors.is_empty())
	_check(errors.size() == 1 and errors[0].contains("deeper than 64"), "calls nest at most 64 deep: %s" % [errors])
	scene.queue_free()
	await process_frame

	# A pure function reading itself, and a pin without a type, don't build.
	doc = XREBlueprintDocument.new()
	var loop := doc.create_function(true, "loop")
	doc.add_function_pin(loop, false)
	doc.open_function(loop)
	var again := doc.add_function_call(loop, Vector2(200, 100))
	_check(doc.connect_blocks(again, 0, 2, 0), "a pure function's output reads its own call: %s" % doc.last_error)
	doc.open_function("")
	doc.add_function_pin(doc.create_function(), true)
	var problems := "\n".join(XREBlueprintCompiler.compile(doc.root)["errors"] as PackedStringArray)
	_check(problems.contains("Pure function loop reads itself") and problems.contains("function_1: input_1 has no type"), "both are build errors: %s" % problems)
	_check(doc.delete_function("function_1") and doc.root.function_index("function_1") < 0, "a function without calls is deleted")

	# Ways in and out: a pin wired to an input of execution is another In, one
	# from an output of execution another Then; the call goes on from the way the Return left.
	doc = XREBlueprintDocument.new()
	for flag: String in ["a", "b", "c"]: doc.add_variable(flag, false)
	doc.add_variable("log", "")
	var route := doc.create_function(false, "route")
	doc.add_function_pin(route, true)
	doc.add_function_pin(route, false)
	doc.open_function(route)
	var note := doc.insert_block(XREBlueprintGraph.make_node(0, "set_variable", Vector2.ZERO), Vector2(250, 300))
	doc.set_parameter(note, "variable", "log")
	doc.set_parameter(note, "value", "second")
	_check(doc.connect_blocks(1, 1, note, 0) and doc.connect_blocks(note, 0, 2, 1), "input_1 goes into Set's In, Set's Then into output_1: %s" % doc.last_error)
	var pins: Dictionary = doc.root.functions[0]
	_check(pins["inputs"][0] == {"key": "in", "exec": true} and pins["outputs"][0] == {"key": "then", "exec": true}, "both are of execution now: %s %s" % [pins["inputs"], pins["outputs"]])
	doc.open_function("")
	var order := doc.insert_block(XREBlueprintGraph.make_node(0, "sequence", Vector2.ZERO), Vector2(200, 100), {"from": 1, "from_port": 0})
	var first_call := doc.add_function_call(route, Vector2(400, 0), {"from": order, "from_port": 0})
	var second_call := doc.add_function_call(route, Vector2(400, 300))
	var ports := doc.root.ports(doc.root.find_node(second_call), true)
	_check(ports.size() == 2 and ports[1][1] == XREBlueprintGraph.EXEC and doc.root.ports(doc.root.find_node(second_call), false)[1][0] == "then", "the call has In and in, Then and then")
	doc.connect_blocks(order, 1, second_call, 1)
	var setters: Array[int] = []
	for flag: String in ["a", "b", "c"]:
		var setter := doc.insert_block(XREBlueprintGraph.make_node(0, "set_variable", Vector2.ZERO), Vector2(700, setters.size() * 200))
		doc.set_parameter(setter, "variable", flag)
		doc.set_parameter(setter, "value", true)
		setters.append(setter)
	doc.connect_blocks(first_call, 0, setters[0], 0)
	doc.connect_blocks(second_call, 1, setters[1], 0)
	doc.connect_blocks(second_call, 0, setters[2], 0)
	scene = Node.new()
	scene.set_script(_script(doc.root))
	root.add_child(scene)
	await _wait_until(func() -> bool: return scene.get("_bp_var_b") == true)
	_check(scene.get("_bp_var_a") == true and scene.get("_bp_var_b") == true and scene.get("_bp_var_c") == false and scene.get("_bp_var_log") == "second",
			"In went Then, in went through Set to then: %s %s %s %s" % [scene.get("_bp_var_a"), scene.get("_bp_var_b"), scene.get("_bp_var_c"), scene.get("_bp_var_log")])
	scene.queue_free()
	await process_frame
	_check(doc.set_function_pure(route, true) and not XREBlueprintUserFunctions.is_typed(doc.root.functions[0]["inputs"][0]), "made pure, its pins of execution have no type again")
