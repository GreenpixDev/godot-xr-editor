extends SceneTree
## Native Bezier wires without a headset: port attachment, exit directions, smoothness,
## and continuity when the cards turn towards a moving head.

var _checks := 0
var _failures := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("test_blueprint_wires: FAILED " + message)


## Largest turn between consecutive segments, in radians.
func _sharpest_turn(wire: XREGraphWire) -> float:
	var result := 0.0
	for index: int in range(1, wire.get_point_count() - 1):
		var before := wire.get_point(index) - wire.get_point(index - 1)
		var after := wire.get_point(index + 1) - wire.get_point(index)
		if before.length() > 0.0001 and after.length() > 0.0001:
			result = maxf(result, before.angle_to(after))
	return result


func _attached(wire: XREGraphWire, start: Vector3, end: Vector3) -> bool:
	var last := wire.get_point_count() - 1
	return last > 0 and wire.get_point(0).is_equal_approx(start) and wire.get_point(last).is_equal_approx(end)


## The curve leaves the start along its direction and arrives at the end from its direction.
func _exits(wire: XREGraphWire, start_direction: Vector3, end_direction: Vector3) -> bool:
	var last := wire.get_point_count() - 1
	var leaving := (wire.get_point(1) - wire.get_point(0)).normalized()
	var arriving := (wire.get_point(last - 1) - wire.get_point(last)).normalized()
	return leaving.dot(start_direction) > 0.95 and arriving.dot(end_direction) > 0.95


func _max_shift(wire: XREGraphWire, before: PackedVector3Array) -> float:
	var result := 0.0
	for index: int in wire.get_point_count():
		result = maxf(result, wire.get_point(index).distance_to(before[index]))
	return result


func _points(wire: XREGraphWire) -> PackedVector3Array:
	var result := PackedVector3Array()
	for index: int in wire.get_point_count(): result.append(wire.get_point(index))
	return result


## Whether a ray at [param point] of [param canvas], from 0.4 m in front of it, hits the canvas.
func _ray_at(canvas: XREBlueprintCanvas, point: Vector3) -> bool:
	return canvas.intersect_ray(canvas.to_global(point) + Vector3.BACK * 0.4, Vector3.FORWARD, 1.0) >= 0


## D-064: a wire's bends, drawn as knots it goes through smoothly and picked by
## the ray while bends are on; off, the wire is drawn and passed as before.
func _test_bends() -> void:
	var document := XREBlueprintDocument.new()
	var graph := document.graph
	var stored := Vector3(0, -250, 0.05)
	graph.restore({"nodes": [XREBlueprintGraph.make_node(1, "ready", Vector2(-300, 0)), XREBlueprintGraph.make_node(2, "print", Vector2(300, 0)), XREBlueprintGraph.make_node(3, "print", Vector2(0, -250))],
			"edges": [{"from": 1, "from_port": 0, "to": 2, "to_port": 0, "vr_bends": PackedVector3Array([stored])}], "vr_placed": true, "vr_center": Vector2.ZERO})
	var canvas := XREBlueprintCanvas.new()
	root.add_child(canvas)
	canvas.center_graph(graph)
	canvas.rebuild(graph)
	var output := canvas.port_position(1, 0, false)
	var input := canvas.port_position(2, 0, true)
	var plain := canvas.wire_pieces(0)
	_check(not canvas.get_bends_shown() and plain.size() == 1 and canvas.wire_knot(0, 0) == null, "off, a bent wire is one tube without knots")
	_check(_attached(plain[0], output, input), "off, the wire runs from port to port as before")
	var middle := plain[0].get_point(XREGraphWire.SAMPLES / 2)
	_check(not _ray_at(canvas, middle) or canvas.get_hit_wire() < 0, "off, the ray passes through wires")

	_check(canvas.set_bends_shown(true) and not canvas.set_bends_shown(true), "bends switch on once")
	canvas.rebuild(graph)
	var knot_point := Vector3(0, 250 * XREBlueprintCanvas.PIXEL_SIZE, 0.05)
	var pieces := canvas.wire_pieces(0)
	var knot := canvas.wire_knot(0, 0)
	_check(pieces.size() == 2 and knot != null and knot.position.is_equal_approx(knot_point), "on, the wire has a knot at its bend, stored in graph coordinates and depth")
	_check(canvas.wire_bends(0).size() == 1 and canvas.wire_bends(0)[0].is_equal_approx(knot_point), "the canvas has the bend in its own space")
	_check(_attached(pieces[0], output, knot_point) and _attached(pieces[1], knot_point, input), "the wire runs through the knot from port to port")
	var first := pieces[0]
	var last := first.get_point_count() - 1
	_check((first.get_point(1) - first.get_point(0)).normalized().dot(Vector3.RIGHT) > 0.95, "the bent wire still leaves its output rightwards")
	_check((pieces[1].get_point(last - 1) - pieces[1].get_point(last)).normalized().dot(Vector3.LEFT) > 0.95, "and enters its input from the left")
	var arriving := (first.get_point(last) - first.get_point(last - 1)).normalized()
	var leaving := (pieces[1].get_point(1) - pieces[1].get_point(0)).normalized()
	_check(arriving.angle_to(leaving) < deg_to_rad(8.0), "no corner at the knot: %.1f°" % rad_to_deg(arriving.angle_to(leaving)))
	_check(_sharpest_turn(first) < deg_to_rad(25.0) and _sharpest_turn(pieces[1]) < deg_to_rad(25.0), "both tubes bend smoothly")

	# The ray: knot, tube, a tube in front of a card, and ports before wires.
	_check(_ray_at(canvas, knot_point) and canvas.get_hit_wire() == 0 and canvas.get_hit_bend() == 0 and canvas.get_hit_id() == -1, "the ray takes the knot, in front of the card behind it")
	var on_first := first.get_point(XREGraphWire.SAMPLES / 2)
	_check(_ray_at(canvas, on_first) and canvas.get_hit_wire() == 0 and canvas.get_hit_bend() == -1 and canvas.get_hit_piece() == 0 and canvas.get_hit_wire_point().distance_to(on_first) < XREBlueprintCanvas.WIRE_HIT_RADIUS, "the ray takes the tube before the bend")
	var on_second := pieces[1].get_point(XREGraphWire.SAMPLES / 2)
	_check(_ray_at(canvas, on_second) and canvas.get_hit_wire() == 0 and canvas.get_hit_piece() == 1, "and the one after it, where a new bend goes second")
	var over_card := first.get_point(XREGraphWire.SAMPLES - 4)
	_check(_ray_at(canvas, over_card) and canvas.get_hit_wire() == 0, "a wire in front of a card's face takes the ray from it")
	var across := (first.get_point(XREGraphWire.SAMPLES / 2 + 1) - first.get_point(XREGraphWire.SAMPLES / 2 - 1)).cross(Vector3.BACK).normalized()
	_check(not _ray_at(canvas, on_first + across * 0.03) or canvas.get_hit_wire() < 0, "3 cm off the wire the ray misses it")
	_check(_ray_at(canvas, output) and canvas.get_hit_port() == 0 and canvas.get_hit_wire() < 0, "on a port the port keeps the ray, not its wire")

	# Light and hover.
	var stored_wire := (canvas.get("_wires") as Array)[0] as XREBlueprintCanvas.Wire
	canvas.hover_actions(-1, false, false, true, -1, false, 0)
	_check(pieces.all(func(piece: XREGraphWire) -> bool: return piece.material_override == stored_wire.lit) and knot.material_override == stored_wire.lit, "the wire under the ray thickens along every tube and knot")
	canvas.hover_bend(0, 0, Vector3.ZERO, true)
	_check(knot.scale.x > 1.0 and canvas.is_bend_hovered(0, 0) and not canvas.is_ghost_shown(true), "the knot under the ray grows")
	canvas.hover_bend(0, -1, on_first, true)
	_check(is_equal_approx(knot.scale.x, 1.0) and canvas.is_ghost_shown(true) and (canvas.get("_ghost_right") as Node3D).position == on_first, "off the knot, a white knot marks where a bend would go")
	canvas.hover_bend(-1, -1, Vector3.ZERO, true)
	canvas.hover_actions(-1, false, false, true)
	_check(not canvas.is_ghost_shown(true) and pieces[0].material_override == stored_wire.normal, "off the wire, both go")

	# A drag's preview, then one edit.
	var snapshot := graph.snapshot()
	var card := canvas.get_node("Block2")
	_check(canvas.insert_bend(0, 0, on_first) == 0 and canvas.bend_count(0) == 2 and canvas.wire_pieces(0).size() == 3, "a new bend goes before the knot of the tube it is on")
	var moved := on_first + Vector3(0, -0.1, 0.15)
	canvas.preview_bend(0, 0, moved)
	_check(canvas.wire_knot(0, 0).position == moved and _attached(canvas.wire_pieces(0)[0], output, moved), "the bend previews where the hand takes it")
	_check(graph.snapshot() == snapshot, "the preview leaves the graph alone")
	canvas.reset_bends(graph, 0)
	_check(canvas.bend_count(0) == 1 and canvas.wire_pieces(0).size() == 2, "let go unmoved, the wire is as the graph has it")
	canvas.insert_bend(0, 1, on_second)
	canvas.preview_bend(0, 1, moved)
	_check(canvas.commit_bends(document, 0, "Bend Wire"), "the bends commit as one edit")
	var kept: PackedVector3Array = graph.edges[0].get("vr_bends", PackedVector3Array())
	var expected := Vector3(moved.x / XREBlueprintCanvas.PIXEL_SIZE, -moved.y / XREBlueprintCanvas.PIXEL_SIZE, moved.z)
	_check(kept.size() == 2 and kept[0].is_equal_approx(stored) and kept[1].is_equal_approx(expected), "the graph keeps them in graph coordinates and depth: %s" % [kept])
	_check(canvas.sync_placement(graph) and canvas.get_node("Block2") == card, "a bend's edit re-lays the wires without rebuilding the cards")
	document.undo()
	_check(canvas.sync_placement(graph) and canvas.bend_count(0) == 1 and canvas.wire_knot(0, 0).position.is_equal_approx(knot_point), "undo takes the new bend back")
	canvas.remove_bend(0)
	_check(canvas.commit_bends(document, 0, "Straighten Wire") and not graph.edges[0].has("vr_bends"), "all bends off: the edge keeps none")
	document.undo()
	canvas.sync_placement(graph)
	for _index: int in XREBlueprintGraph.MAX_BENDS: canvas.insert_bend(0, 0, on_first)
	_check(canvas.bend_count(0) == XREBlueprintGraph.MAX_BENDS and canvas.insert_bend(0, 0, on_first) == -1, "a wire takes at most %d bends" % XREBlueprintGraph.MAX_BENDS)
	canvas.reset_bends(graph, 0)

	# Moving a card keeps the bend where it is, the wire through it.
	canvas.preview_move(2, canvas.get_block_position(2) + Vector3(0.1, -0.2, 0.05))
	_check(_attached(canvas.wire_pieces(0)[1], knot_point, canvas.port_position(2, 0, true)), "a moved card drags its end of the wire, the bend stays")

	# Links bend too: a block's wire to the scene and its Variable socket's wire to the box.
	var scene_key := XREBlueprintCanvas.link_key(2)
	graph.nodes[1][XREBlueprintGraph.SCENE_BENDS] = PackedVector3Array([Vector3(400, 300, 0.1)])
	var scene_link := canvas.add_scene_link(graph.find_node(2), XREBlueprintCanvas.COLORS[XREBlueprintGraph.OBJECT])
	var object := Vector3(0.5, -0.5, -0.3)
	canvas.update_scene_wire(scene_link, 2, 0, object)
	var scene_knot := Vector3(0.36, -0.27, 0.1)
	var scene_pieces := canvas.wire_pieces(scene_key)
	_check(scene_pieces.size() == 2 and canvas.wire_knot(scene_key, 0).position.is_equal_approx(scene_knot), "a Target wire bends where its block keeps its bend")
	_check(_attached(scene_pieces[0], canvas.port_position(2, 0, true), scene_knot) and _attached(scene_pieces[1], scene_knot, object), "and runs through it from its port to the object")
	var on_scene := scene_pieces[1].get_point(XREGraphWire.SAMPLES / 2)
	_check(_ray_at(canvas, on_scene) and canvas.get_hit_wire() == scene_key and canvas.get_hit_piece() == 1, "the ray takes the Target wire")
	canvas.insert_bend(scene_key, 1, on_scene)
	_check(canvas.commit_bends(document, scene_key, "Bend Wire") and (graph.find_node(2).get(XREBlueprintGraph.SCENE_BENDS, PackedVector3Array()) as PackedVector3Array).size() == 2, "its bends commit on its block")
	canvas.set_link_shown(scene_link, false)
	_check(not scene_pieces[0].visible and not canvas.wire_knot(scene_key, 0).visible and (not _ray_at(canvas, on_scene) or canvas.get_hit_wire() != scene_key), "a hidden link hides every tube and knot and takes no ray")
	canvas.remove_scene_link(scene_link)
	_check(canvas.wire_pieces(scene_key).is_empty(), "a removed link is gone")
	var boxes := XREBlueprintGraph.new()
	boxes.restore({"nodes": [XREBlueprintGraph.make_node(1, "set_variable", Vector2(0, 0))], "edges": [], "variables": [{"name": "speed", "value": 1.0}], "vr_placed": true, "vr_center": Vector2.ZERO})
	boxes.nodes[0]["params"]["variable"] = "speed"
	boxes.nodes[0][XREBlueprintGraph.VARIABLE_BENDS] = PackedVector3Array([Vector3(-250, 150, 0.08)])
	canvas.set_parameter_modes(XREFeatureSettings.WINDOW, XREFeatureSettings.WINDOW, XREFeatureSettings.FLAG, XREFeatureSettings.BOXES)
	canvas.rebuild(boxes)
	var variable_key := XREBlueprintCanvas.link_key(1, true)
	var variable_pieces := canvas.wire_pieces(variable_key)
	_check(variable_pieces.size() == 2 and canvas.wire_knot(variable_key, 0).position.is_equal_approx(Vector3(-0.225, -0.135, 0.08)), "a Variable socket's wire to its box bends where its block keeps its bend")
	_check(_ray_at(canvas, variable_pieces[0].get_point(XREGraphWire.SAMPLES / 2)) and canvas.get_hit_wire() == variable_key, "the ray takes it")
	canvas.set_parameter_modes(XREFeatureSettings.WINDOW, XREFeatureSettings.WINDOW, XREFeatureSettings.FLAG, XREFeatureSettings.WINDOW)

	_check(canvas.set_bends_shown(false), "bends switch off")
	canvas.rebuild(graph)
	_check(canvas.wire_pieces(0).size() == 1 and canvas.wire_knot(0, 0) == null and graph.edges[0].has("vr_bends"), "off again: one tube, the graph's bends kept")
	canvas.queue_free()


func _run() -> void:
	var wire := XREGraphWire.new()
	root.add_child(wire)
	var start := Vector3(-0.6, 0, 0)
	var end := Vector3(0.6, 0.1, 0)
	wire.update_curve(start, Vector3.RIGHT, end, Vector3.LEFT)
	_check(wire.mesh != null and wire.get_point_count() > 8, "a wire builds its mesh on the first update")
	_check(_attached(wire, start, end), "curve starts and ends exactly at the ports")
	_check(_exits(wire, Vector3.RIGHT, Vector3.LEFT), "curve leaves the output rightwards and enters the input from the left")
	_check(_sharpest_turn(wire) < deg_to_rad(15.0), "forward link bends smoothly")
	var mesh := wire.mesh
	wire.update_curve(start, Vector3.RIGHT, end, Vector3.LEFT)
	_check(wire.mesh == mesh, "unchanged endpoints keep the existing mesh")
	# A back edge, output to the right of its input: the GraphEdit S-loop, still smooth.
	for back_end: Vector3 in [Vector3(-0.3, -0.2, 0), Vector3(-0.13, 0, 0), Vector3(-0.5, 0, 0)]:
		wire.update_curve(Vector3(0.13, 0, 0), Vector3.RIGHT, back_end, Vector3.LEFT, Vector3.BACK)
		_check(_sharpest_turn(wire) < deg_to_rad(25.0), "back edge to %s loops without corners" % back_end)
		var front := 0.0
		for index: int in wire.get_point_count(): front = maxf(front, wire.get_point(index).z)
		_check(front > 0.04, "back edge to %s loops out towards the user, not through the cards" % back_end)
	# A free end follows the controller ray without an imposed arrival direction.
	wire.update_curve(Vector3.ZERO, Vector3.LEFT, Vector3(0.2, 0.3, -0.4), Vector3.ZERO)
	_check(_attached(wire, Vector3.ZERO, Vector3(0.2, 0.3, -0.4)), "free end reaches the pointed position")
	_check(_sharpest_turn(wire) < deg_to_rad(25.0), "free end curve is smooth")

	var graph := XREBlueprintGraph.new()
	graph.nodes = [XREBlueprintGraph.make_node(1, "ready", Vector2(-600, 0)), XREBlueprintGraph.make_node(2, "print", Vector2(600, 0)), XREBlueprintGraph.make_node(3, "print", Vector2.ZERO)]
	graph.edges = [{"from": 1, "from_port": 0, "to": 2, "to_port": 0}]
	var canvas := XREBlueprintCanvas.new()
	root.add_child(canvas)
	canvas.rebuild(graph)
	var stored := (canvas.get("_wires") as Array)[0] as XREBlueprintCanvas.Wire
	var cards := canvas.get("_cards") as Array
	var source := cards[0] as XREBlueprintCanvas.Card
	var target := cards[1] as XREBlueprintCanvas.Card
	_check(stored.mesh.visible and _attached(stored.mesh, canvas.port_position(1, 0, false), canvas.port_position(2, 0, true)), "graph wire is drawn between its two ports")
	_check(_exits(stored.mesh, source.node.basis.x, -target.node.basis.x), "graph wire leaves the source card's side and enters the target card's side")
	var snapshot := graph.snapshot()
	var head := Vector3(0, 0.2, 2.3)
	canvas.face_user(head)
	for step: int in 40:
		var before := _points(stored.mesh)
		head += Vector3(0.01, 0.002, -0.005)
		canvas.face_user(head)
		_check(stored.mesh.visible and _max_shift(stored.mesh, before) < 0.01, "a 1 cm head move shifts the wire by less than 1 cm (step %d)" % step)
	_check(_attached(stored.mesh, canvas.port_position(1, 0, false), canvas.port_position(2, 0, true)), "turned cards keep the wire on both ports")
	# Turned cards move their ports back, but the handles must not tip the wire further behind.
	var deepest := INF
	for index: int in stored.mesh.get_point_count(): deepest = minf(deepest, stored.mesh.get_point(index).z)
	var ports := minf(canvas.port_position(1, 0, false).z, canvas.port_position(2, 0, true).z)
	_check(deepest > ports - 0.005, "turned cards do not tip the wire behind its own ports (%.3f m vs %.3f m)" % [deepest, ports])
	_check(graph.snapshot() == snapshot, "turning the cards never modifies the graph")
	canvas.preview_transform(1, Transform3D(Basis.from_euler(Vector3(0.3, 0.7, 0.4)), Vector3(-0.2, 0, 0.1)))
	_check(_attached(stored.mesh, canvas.port_position(1, 0, false), canvas.port_position(2, 0, true)), "moving a card drags its wire end along")
	var scene_link := canvas.add_scene_link(graph.find_node(2), XREBlueprintCanvas.COLORS[XREBlueprintGraph.OBJECT])
	canvas.update_scene_wire(scene_link, 2, 0, Vector3(0.54, -0.35, -0.5))
	var scene_wire := scene_link.mesh
	_check(_attached(scene_wire, canvas.port_position(2, 0, true), Vector3(0.54, -0.35, -0.5)), "Target wire runs from its port to the scene object")
	_check((scene_wire.get_point(1) - scene_wire.get_point(0)).normalized().dot(-target.node.basis.x) > 0.95, "Target wire leaves its input port leftwards")
	var preview := canvas.get("_preview") as XREGraphWire
	canvas.show_connection(1, 0, false, Vector3(0.1, 0.2, 0.3))
	_check(preview.visible and _attached(preview, canvas.port_position(1, 0, false), Vector3(0.1, 0.2, 0.3)), "connection preview follows the free end")
	canvas.show_connection(1, 0, false, Vector3.ZERO, 3, 0, true)
	_check(_attached(preview, canvas.port_position(1, 0, false), canvas.port_position(3, 0, true)), "preview snaps to a hovered port")
	canvas.hide_connection()
	_check(not preview.visible, "hiding the connection hides the preview")
	canvas.queue_free()
	wire.queue_free()
	_test_bends()
	await process_frame
	await process_frame
	print("test_blueprint_wires: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)
