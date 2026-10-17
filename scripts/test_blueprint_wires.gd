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
	var scene_wire := canvas.create_scene_wire(XREBlueprintCanvas.COLORS[XREBlueprintGraph.OBJECT])
	canvas.update_scene_wire(scene_wire, 2, 0, Vector3(0.54, -0.35, -0.5))
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
	await process_frame
	await process_frame
	print("test_blueprint_wires: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)
