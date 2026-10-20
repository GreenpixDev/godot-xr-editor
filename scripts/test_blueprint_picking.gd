extends SceneTree
## Analytic picking regressions against visible card geometry, including oblique edges.

var _checks := 0
var _failures := 0
var _canvas: XREBlueprintCanvas


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("test_blueprint_picking: FAILED " + message)


func _hit(point: Vector3, direction: Vector3, distance: float = 0.5) -> float:
	var world_point := _canvas.to_global(point)
	var world_direction := (_canvas.global_basis * direction).normalized()
	return _canvas.intersect_ray(world_point - world_direction * distance, world_direction, distance + 0.1)


## The cuboid node display (D-039): a solid box in the graph's orientation, picked by its volume.
func _test_cuboid(graph: XREBlueprintGraph) -> void:
	_check(not _canvas.set_display(&"sphere"), "an unknown node display is refused")
	_check(_canvas.set_display(XREFeatureSettings.CUBOID), "the canvas switches to cuboids")
	_canvas.rebuild(graph)
	var card := (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	var half := card.bounds.size * 0.5
	_check(card.mesh.mesh is BoxMesh and is_equal_approx(card.bounds.size.z, XREBlueprintCanvas.CUBOID_DEPTH), "a cuboid card is a solid box")
	_check(card.node.basis.is_equal_approx(Basis.IDENTITY), "a rebuilt cuboid keeps the graph's orientation although the head was seen")
	_canvas.face_user(Vector3(1.5, 0.3, 0.5))
	_check(card.node.basis.is_equal_approx(Basis.IDENTITY), "a cuboid doesn't turn to the head")
	var port := _canvas.port_position(1, 0, false)
	_check(port.z > half.z, "ports sit on the cuboid's front face")
	_check(is_equal_approx(_hit(port, Vector3.FORWARD), 0.5) and _canvas.get_hit_port() == 0, "the port on the front face is pickable")
	_check(_hit(card.plus_point, Vector3.FORWARD) >= 0 and _canvas.get_hit_plus(), "plus is pickable on the front face")
	_check(_hit(card.trash_point, Vector3.FORWARD) >= 0 and _canvas.get_hit_delete(), "trash is pickable on the front face")
	_check(is_equal_approx(_hit(Vector3(half.x, 0, 0), Vector3.LEFT), 0.5) and _canvas.get_hit_id() == 1, "the cuboid's side is pickable")
	_check(is_equal_approx(_hit(Vector3(0, 0, -half.z), Vector3.BACK), 0.5), "the cuboid's back stops the ray")
	_check(_canvas.intersect_touch(_canvas.to_global(Vector3(0, 0, -half.z - 0.02))) == 1, "grip behind the cuboid touches it")
	var contact := Vector3(0.3, 0.1, -1)
	var local_contact := Vector3(0.1, 0.03, half.z)
	_canvas.preview_grab(1, contact, local_contact, Vector3(0.1, 0.8, 0))
	_check(card.node.to_global(local_contact).is_equal_approx(contact) and card.node.basis.is_equal_approx(Basis.IDENTITY),
			"a grabbed cuboid follows the rod without turning")
	_canvas.preview_transform(1, Transform3D(Basis.from_euler(Vector3(0.3, 0.7, -0.2)), Vector3(0.1, -0.1, 0.2)))
	_check(card.node.basis.is_equal_approx(Basis.IDENTITY), "a moved cuboid keeps the graph's orientation")
	_check(_canvas.set_display(XREFeatureSettings.BILLBOARD), "the canvas switches back to billboards")
	_canvas.rebuild(graph)
	card = (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	_check(card.mesh.mesh is QuadMesh and card.face == 0.0, "billboards are flat again")
	_canvas.face_user(Vector3(0, 0, -2))
	_check(card.node.global_basis.z.dot(Vector3.FORWARD) > 0.99, "billboards turn to the head again")


## D-044, D-045: a port under the ray thickens one of its wires, which the height of
## the hit on the port picks, the top of the port the wire going highest.
func _test_port_wires() -> void:
	var graph := XREBlueprintGraph.new()
	graph.nodes = [
		{"id": 1, "kind": "value", "position": Vector2(0, 0), "params": {"value": 1.0}},
		{"id": 2, "kind": "print", "position": Vector2(400, -300), "params": {}},
		{"id": 3, "kind": "print", "position": Vector2(400, 300), "params": {}},
	]
	graph.edges = [
		{"from": 1, "from_port": 0, "to": 3, "to_port": 1},
		{"from": 1, "from_port": 0, "to": 2, "to_port": 1},
	]
	_canvas.set_display(XREFeatureSettings.BILLBOARD)
	_canvas.center_graph(graph)
	_canvas.rebuild(graph)
	_canvas.face_user(_canvas.to_global(Vector3(0, 0, 2)))
	_check(_canvas.port_edges(1, 0, false) == ([1, 0] as Array[int]), "a port's wires, the one going highest first: %s" % [_canvas.port_edges(1, 0, false)])
	var card := (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	var port := card.node.position + card.outputs[0]
	var reach := XREBlueprintCanvas.PORT_RADIUS * 0.9
	_check(_hit(port + Vector3.UP * reach, Vector3.FORWARD) >= 0 and _canvas.get_hit_port() == 0 and _canvas.get_hit_edge() == 1,
			"the port's top picks the wire going up")
	_check(_hit(port + Vector3.DOWN * reach, Vector3.FORWARD) >= 0 and _canvas.get_hit_edge() == 0, "its bottom the wire going down")
	_canvas.hover_actions(1, false, false, true, 0, false, _canvas.get_hit_edge())
	_check(_canvas.is_edge_lit(0) and not _canvas.is_edge_lit(1), "the picked wire lights up")
	var wires := _canvas.get("_wires") as Array
	var lit := wires[0] as XREBlueprintCanvas.Wire
	_check(lit.mesh.material_override == lit.lit and (wires[1] as XREBlueprintCanvas.Wire).mesh.material_override != (wires[1] as XREBlueprintCanvas.Wire).lit,
			"drawn lit, the other one not")
	var lit_material := lit.lit as ShaderMaterial
	var normal_material := lit.normal as ShaderMaterial
	_check(is_equal_approx(float(lit_material.get_shader_parameter(&"grow")), XREBlueprintCanvas.LIT_WIRE_GROW)
			and lit_material.get_shader_parameter(&"tint") == normal_material.get_shader_parameter(&"tint"),
			"lit means thicker, in the same color (D-045)")
	_canvas.hover_actions(-1, false, false, true)
	_check(not _canvas.is_edge_lit(0) and lit.mesh.material_override == lit.normal, "the ray leaving the port puts the wire out")
	_check(_hit(card.node.position + card.outputs[0], Vector3.FORWARD) >= 0 and _canvas.get_hit_edge() >= 0, "a port with one wire or more always picks one")


func _run() -> void:
	var graph := XREBlueprintGraph.new()
	graph.nodes = [{"id": 1, "kind": "ready", "position": Vector2.ZERO, "params": {"policy": "parallel"}}]
	_canvas = XREBlueprintCanvas.new()
	root.add_child(_canvas)
	_canvas.rebuild(graph)
	var card := (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	var half := card.bounds.size * 0.5
	_check(card.mesh.mesh is QuadMesh, "card is a flat panel mesh")
	_check(card.ports[0].mesh is CylinderMesh, "port returns to a round contact")
	for sx: float in [-1.0, 1.0]:
		for sy: float in [-1.0, 1.0]:
			var corner := Vector3(sx * (half.x - 0.00001), sy * (half.y - 0.00001), half.z)
			_check(is_equal_approx(_hit(corner, Vector3.FORWARD), 0.5), "front ray reaches the visible corner")
			_check(is_equal_approx(_hit(corner, Vector3(-sx, -sy, -1).normalized()), 0.5), "oblique ray reaches the visible corner without a hole")
			_check(_canvas.get_hit_id() == 1 and _canvas.get_hit_port() == -1, "corner belongs to the card body")
			_check(_hit(Vector3(sx * (half.x + 0.001), sy * (half.y - 0.001), half.z), Vector3.FORWARD) < 0, "ray just outside the corner misses")
	_check(is_equal_approx(_hit(Vector3(half.x, half.y - 0.005, 0), Vector3.LEFT), 0.5), "visible side face is pickable")
	_check(is_equal_approx(_hit(Vector3(0, 0, -half.z), Vector3.BACK), 0.5), "visible back face stops the ray")
	var port := _canvas.port_position(1, 0, false)
	_check(is_equal_approx(_hit(port, Vector3.FORWARD), 0.5), "front ray reaches the circular contact surface")
	_check(_canvas.get_hit_port() == 0 and not _canvas.get_hit_input(), "circle identifies the output port")
	_check(absf(port.x) + XREBlueprintCanvas.PORT_RADIUS <= half.x and port.z > half.z, "round pad sits on the panel face")
	_check(_canvas._port_distance(port + Vector3(0.014, 0.014, 0.4), Vector3.FORWARD, card.outputs[0], Vector3.ONE, 1.0) < 0, "empty square corners around a circle are not port hits")
	var pose := Transform3D(Basis.from_euler(Vector3(0.3, 0.7, -0.2)), Vector3(0.1, -0.1, 0.2))
	_canvas.preview_transform(1, pose)
	var corner := Vector3(-half.x + 0.00001, half.y - 0.00001, half.z)
	_check(is_equal_approx(_hit(pose * corner, pose.basis * Vector3(1, -1, -1).normalized()), 0.5), "rotated card picks its own corner")
	_check(_canvas.port_position(1, 0, false).is_equal_approx(pose * (card.outputs[0] + Vector3.BACK * XREBlueprintCanvas.PORT_DEPTH)), "contact surface follows panel orientation")
	_check(_canvas.intersect_touch(_canvas.to_global(pose * Vector3.ZERO)) == 1, "direct grip can touch a rotated card")
	_canvas.preview_transform(1, Transform3D.IDENTITY)
	_check(_hit(card.plus_point, Vector3.FORWARD) >= 0 and _canvas.get_hit_plus(), "plus button is analytically pickable")
	_canvas.hover_plus(1, true)
	_canvas.hover_plus(-1, false)
	_check(card.plus_faces[0].scale.x > 1.5, "plus hover enlarges its face without moving its anchor")
	_canvas.hover_plus(-1, true)
	_check(card.plus_faces[0].scale.is_equal_approx(Vector3.ONE), "plus returns to its original size on exit")
	_check(_hit(card.trash_point, Vector3.FORWARD) >= 0 and _canvas.get_hit_delete() and not _canvas.get_hit_plus() and _canvas.get_hit_port() == -1, "trash icon is a distinct action in the opposite corner")
	_canvas.hover_actions(1, false, true, true)
	_canvas.hover_actions(-1, false, false, false)
	_check(card.trash.scale.x > 1.5, "idle other hand cannot clear trash hover")
	_canvas.hover_actions(-1, false, false, true)
	_check(card.trash.scale.is_equal_approx(Vector3.ONE), "trash hover resets on exit")
	var snapshot := graph.snapshot()
	_canvas.face_user(Vector3(0, 0, -2))
	_check(card.node.global_basis.z.dot(Vector3.FORWARD) > 0.99 and card.node.global_basis.y.is_equal_approx(Vector3.UP), "walking behind a panel turns its readable face towards the user")
	_check(card.node.position.is_zero_approx() and graph.snapshot() == snapshot, "facing changes neither the card center nor the graph resource")
	_check(_hit(card.node.transform * card.plus_point, Vector3.BACK) >= 0 and _canvas.get_hit_plus(), "same front plus remains pickable from the user's new side")
	_check(_hit(card.node.transform * card.trash_point, Vector3.BACK) >= 0 and _canvas.get_hit_delete(), "trash remains pickable after the panel faces the user from behind")
	_canvas.face_user(Vector3(0, 0, 2))
	_canvas.position = Vector3(0.4, 1.2, -1)
	_canvas.basis = Basis.from_euler(Vector3(0.2, 0.8, -0.1)).scaled(Vector3(1.5, 0.7, 1.2))
	_check(is_equal_approx(_hit(Vector3(half.x - 0.00001, half.y - 0.00001, half.z), Vector3(-1, -1, -1).normalized(), 0.7), 0.7), "rotated scaled workspace preserves world-space hit distance at its corner")
	_canvas.basis = Basis.IDENTITY
	_canvas.position = Vector3.ZERO
	_canvas.preview_move(1, Vector3(0.1, 0.2, -0.15))
	_check(is_equal_approx(_hit(card.node.transform * Vector3(-half.x + 0.00001, half.y - 0.00001, half.z), card.node.basis * Vector3(1, -1, -1).normalized()), 0.5), "moved card's corner follows its facing preview geometry")
	var contact := Vector3(0.3, 0.1, -1)
	var local_contact := Vector3(0.1, 0.03, half.z)
	var head := Vector3(0.1, 0.8, 0)
	_canvas.face_user(head)
	_canvas.preview_grab(1, contact, local_contact, head)
	_check(card.node.to_global(local_contact).is_equal_approx(contact), "off-center grab stays attached to the rod after automatic facing")
	var front := head - card.node.global_position
	front.y = 0.0
	_check(card.node.global_basis.z.dot(front.normalized()) > 0.999, "grabbed panel continues facing the head without tilt")
	contact = Vector3(head.x + 0.03, 0.1, head.z)
	_canvas.preview_grab(1, contact, local_contact, head)
	_check(card.node.to_global(local_contact).is_equal_approx(contact), "minimum horizontal reach cannot detach an off-center grab from the rod")
	_test_cuboid(graph)
	_test_port_wires()
	_canvas.queue_free()
	await process_frame
	await process_frame
	print("test_blueprint_picking: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)
