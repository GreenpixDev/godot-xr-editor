extends SceneTree
## Native obstacle routing and smooth attachment regressions without a headset.

var _checks := 0
var _failures := 0


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("test_blueprint_routing: FAILED " + message)


func _avoids(wire: XREGraphWire, bounds: AABB, pose: Transform3D = Transform3D.IDENTITY) -> bool:
	if not wire.is_routed(): return false
	var inverse := pose.affine_inverse()
	for index: int in wire.get_point_count() - 1:
		if bounds.intersects_segment(inverse * wire.get_point(index), inverse * wire.get_point(index + 1)) != null: return false
	return true


func _project(point: Vector3, eye: Transform3D) -> Vector3:
	var local := eye.affine_inverse() * point
	return Vector3(local.x / -local.z, local.y / -local.z, 0)


func _avoids_silhouette(wire: XREGraphWire, card: XREBlueprintCanvas.Card, eye: Transform3D) -> bool:
	if not wire.is_routed(): return false
	var rectangle := AABB(_project(card.node.transform * card.bounds.get_endpoint(0), eye), Vector3.ZERO)
	for corner: int in range(1, 8): rectangle = rectangle.expand(_project(card.node.transform * card.bounds.get_endpoint(corner), eye))
	rectangle.position.z = -1
	rectangle.size.z = 2
	for index: int in wire.get_point_count() - 1:
		if rectangle.intersects_segment(_project(wire.get_point(index), eye), _project(wire.get_point(index + 1), eye)) != null: return false
	return true


func _detour_side(wire: XREGraphWire, card: XREBlueprintCanvas.Card, eye: Transform3D) -> int:
	var rectangle := AABB(_project(card.node.transform * card.bounds.get_endpoint(0), eye), Vector3.ZERO)
	for corner: int in range(1, 8): rectangle = rectangle.expand(_project(card.node.transform * card.bounds.get_endpoint(corner), eye))
	for index: int in wire.get_point_count() - 1:
		for sample: int in 8:
			var point := _project(wire.get_point(index).lerp(wire.get_point(index + 1), sample / 8.0), eye)
			if point.x > rectangle.position.x and point.x < rectangle.end.x:
				if point.y > rectangle.end.y: return 1
				if point.y < rectangle.position.y: return -1
	return 0


func _run() -> void:
	var router := XREWireRouter.new()
	var wire := XREGraphWire.new()
	root.add_child(wire)
	var blocker := AABB(Vector3(-0.18, -0.12, -0.013), Vector3(0.36, 0.24, 0.026))
	router.set_obstacle(3, blocker)
	var start := Vector3(-0.6, 0, 0)
	var end := Vector3(0.6, 0, 0)
	wire.update_route(router, start, Vector3.RIGHT, end, Vector3.LEFT, 1, 2)
	_check(wire.is_routed(), "intermediate card receives a bounded detour")
	_check(_avoids(wire, blocker.grow(0.0015)), "every rendered segment avoids the intermediate card")
	_check(wire.get_point(0).is_equal_approx(start) and wire.get_point(wire.get_point_count() - 1).is_equal_approx(end), "curve stays attached to both terminal exits")
	var mesh := wire.mesh
	var count := wire.get_point_count()
	wire.update_route(router, start, Vector3.RIGHT, end, Vector3.LEFT, 1, 2)
	_check(wire.mesh == mesh and wire.get_point_count() == count, "unchanged route retains its existing mesh and sample buffer")
	router.set_obstacle(3, AABB(Vector3(-0.18, -0.12, 0.07), blocker.size))
	wire.update_route(router, start, Vector3.RIGHT, end, Vector3.LEFT, 1, 2)
	_check(_avoids(wire, AABB(Vector3(-0.18, -0.12, 0.07), blocker.size).grow(0.0015)), "moving the intermediate card invalidates and updates its detour")
	router.clear()
	var source := AABB(Vector3(-0.13, -0.1, -0.013), Vector3(0.26, 0.2, 0.026))
	router.set_obstacle(1, source)
	start = Vector3(-0.138, 0, 0)
	end = Vector3(0, 0, -0.5)
	wire.update_route(router, start, Vector3.LEFT, end, Vector3.ZERO, 1, -1)
	_check(_avoids(wire, source.grow(0.0015)), "Target behind the source card never sends a line through its body")
	_check(wire.get_point(1).x < start.x, "visible terminal stem initially leaves through the outer port face")
	router.clear()
	router.set_obstacle(1, source)
	router.set_obstacle(2, AABB(source.position + Vector3(0.288, 0, 0), source.size))
	start = Vector3(0.138, 0, 0)
	end = Vector3(0.15, 0, 0)
	wire.update_route(router, start, Vector3.RIGHT, end, Vector3.LEFT, 1, 2)
	_check(wire.is_routed() and _avoids(wire, source) and _avoids(wire, AABB(source.position + Vector3(0.288, 0, 0), source.size)), "adjacent cards retain a safe short terminal connection")
	var graph := XREBlueprintGraph.new()
	graph.nodes = [XREBlueprintGraph.make_node(1, "ready", Vector2.ZERO), XREBlueprintGraph.make_node(2, "print", Vector2(950, 0)), XREBlueprintGraph.make_node(3, "print", Vector2(475, 0))]
	graph.edges = [{"from": 1, "from_port": 0, "to": 2, "to_port": 0}]
	var canvas := XREBlueprintCanvas.new()
	root.add_child(canvas)
	canvas.rebuild(graph)
	var stored := (canvas.get("_wires") as Array)[0] as XREBlueprintCanvas.Wire
	var cards := canvas.get("_cards") as Array
	var card := cards[2] as XREBlueprintCanvas.Card
	_check(stored.mesh.is_routed() and _avoids(stored.mesh, card.node.transform * card.bounds), "graph wire bypasses the actual middle card")
	canvas.preview_transform(3, Transform3D(Basis.from_euler(Vector3(0.3, 0.6, 0.2)), Vector3(0.4, -0.025, 0.04)))
	_check(stored.mesh.is_routed() and _avoids(stored.mesh, card.node.transform * card.bounds), "rotated moved obstacle updates a cached graph wire")
	_check(stored.mesh.get_point(0).is_equal_approx(canvas.port_position(1, 0, false)), "moving an obstacle preserves attachment to the source port")
	canvas.preview_transform(1, Transform3D(Basis.from_euler(Vector3(0.3, 0.7, 0.4)), Vector3(-0.2, 0, 0)))
	_check(stored.mesh.is_routed(), "a rotated source port keeps its routed connection")
	canvas.preview_transform(2, Transform3D(Basis.from_euler(Vector3(-0.2, -0.65, -0.3)), Vector3(1.0, 0, 0)))
	_check(stored.mesh.is_routed(), "a rotated destination port keeps its routed connection")
	_check(stored.mesh.is_routed() and stored.mesh.get_point(0).is_equal_approx(canvas.port_position(1, 0, false)) and stored.mesh.get_point(stored.mesh.get_point_count() - 1).is_equal_approx(canvas.port_position(2, 0, true)), "rotating both cards preserves both physical terminal exits")
	var source_card := cards[0] as XREBlueprintCanvas.Card
	var target_card := cards[1] as XREBlueprintCanvas.Card
	_check(_avoids(stored.mesh, source_card.bounds.grow(0.0022), source_card.node.transform), "tube clears the rotated source body including its cross section")
	_check(_avoids(stored.mesh, target_card.bounds.grow(0.0022), target_card.node.transform), "tube clears the rotated destination body including its cross section")
	graph.nodes = [XREBlueprintGraph.make_node(1, "ready", Vector2(-600, 0)), XREBlueprintGraph.make_node(2, "print", Vector2(600, 0)), XREBlueprintGraph.make_node(3, "print", Vector2.ZERO)]
	canvas.rebuild(graph)
	stored = (canvas.get("_wires") as Array)[0] as XREBlueprintCanvas.Wire
	cards = canvas.get("_cards") as Array
	card = cards[2] as XREBlueprintCanvas.Card
	var snapshot := graph.snapshot()
	for angle: float in [0.0, 0.35, -0.35, 0.65, -0.65, PI, PI - 0.35, PI + 0.35, PI - 0.65, PI + 0.65]:
		var head := Vector3(sin(angle) * 2.3, 0.2, cos(angle) * 2.3)
		canvas.face_user(head)
		_check(stored.mesh.is_routed(), "view-aware wire stays routed at angle %.2f" % angle)
		var basis := Basis.looking_at(-head, Vector3.UP)
		for offset: float in [-0.035, 0.0, 0.035]:
			_check(_avoids_silhouette(stored.mesh, card, Transform3D(basis, head + basis.x * offset)), "wire bypasses the middle card silhouette for eye offset %.3f and angle %.2f" % [offset, angle])
		_check(_avoids(stored.mesh, card.bounds.grow(0.0022), card.node.transform), "view route also clears the actual rotated middle body")
		_check(stored.mesh.is_routed() and stored.mesh.get_point(0).is_equal_approx(canvas.port_position(1, 0, false)) and stored.mesh.get_point(stored.mesh.get_point_count() - 1).is_equal_approx(canvas.port_position(2, 0, true)), "view change preserves both exact port anchors")
	_check(graph.snapshot() == snapshot, "view routing never modifies graph positions or resources")
	var scene_wire := canvas.create_scene_wire(XREBlueprintCanvas.COLORS[XREBlueprintGraph.OBJECT])
	canvas.face_user(Vector3(0, 0.2, 2.3))
	canvas.update_scene_wire(scene_wire, 2, 0, Vector3(0.54, -0.35, -0.5))
	var target_card_view := cards[1] as XREBlueprintCanvas.Card
	_check(scene_wire.is_routed() and _avoids(scene_wire, target_card_view.bounds.grow(0.0022), target_card_view.node.transform), "view-aware Target behind its own card retains a safe front exit")
	_check(scene_wire.is_routed() and (scene_wire.get_point(1) - scene_wire.get_point(0)).dot(target_card_view.node.basis.z) > 0, "scene Target initially leaves towards the visible front")
	var head := Vector3(0, 0.2, 2.3)
	var eye := Transform3D(Basis.looking_at(-head, Vector3.UP), head)
	var side := _detour_side(stored.mesh, card, eye)
	_check(side != 0, "view route visibly goes around one side of the middle card")
	canvas.preview_move(3, Vector3(0, 0.04, 0))
	_check(stored.mesh.is_routed() and _detour_side(stored.mesh, card, eye) == side, "valid detour side survives a shorter competing route after obstacle movement")
	canvas.preview_move(3, Vector3.ZERO)
	for shift: float in [-0.06, 0.06, -0.03, 0.03, 0.0]:
		var moved_head := head + Vector3(shift, 0, 0)
		canvas.face_user(moved_head)
		_check(stored.mesh.is_routed() and _detour_side(stored.mesh, card, Transform3D(Basis.looking_at(-moved_head, Vector3.UP), moved_head)) == side, "small head movement retains a valid detour side")
	canvas.queue_free()
	wire.queue_free()
	await process_frame
	await process_frame
	print("test_blueprint_routing: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)
