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
	_check(not _canvas.set_node_modes(&"sphere", true, false, XREFeatureSettings.FACE, false), "an unknown node display is refused")
	_check(_canvas.set_node_modes(XREFeatureSettings.OFF, true, false, XREFeatureSettings.FACE, false), "the canvas switches to cuboids")
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
	# The head is 11° to the left of straight ahead from the rod's end: the cuboid turns a step of 15° to it (D-115).
	_check(card.node.to_global(local_contact).is_equal_approx(contact) and card.node.basis.is_equal_approx(Basis(Vector3.UP, deg_to_rad(-15.0))),
			"a grabbed cuboid follows the rod, turned to the head about the vertical")
	_canvas.preview_transform(1, Transform3D(Basis.from_euler(Vector3(0.3, 0.7, -0.2)), Vector3(0.1, -0.1, 0.2)))
	_check(card.node.basis.is_equal_approx(Basis.IDENTITY), "a moved cuboid keeps the graph's orientation")
	_check(_canvas.set_node_modes(XREFeatureSettings.ON, false, false, XREFeatureSettings.FACE, false), "the canvas switches back to billboards")
	_canvas.rebuild(graph)
	card = (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	_check(card.mesh.mesh is QuadMesh and card.face == 0.0, "billboards are flat again")
	_canvas.face_user(Vector3(0, 0, -2))
	_check(card.node.global_basis.z.dot(Vector3.FORWARD) > 0.99, "billboards turn to the head again")


## Node facing, Node volume, Node back, Pins and Card mirror (D-115) on a card of
## [param graph] at the origin with one output, its Then.
func _test_node_variants(graph: XREBlueprintGraph) -> void:
	var behind := Vector3(0, 0, -2)
	var front := Vector3(0, 0, 2)
	# Node volume 3D: thinner than a port, so a port on its edge stands out of its faces.
	_canvas.set_node_modes(XREFeatureSettings.ON, true, false, XREFeatureSettings.FACE, false)
	_canvas.rebuild(graph)
	var card := (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	_check(is_equal_approx(card.bounds.size.z, XREBlueprintCanvas.CUBOID_DEPTH) and XREBlueprintCanvas.CUBOID_DEPTH < XREBlueprintCanvas.PORT_RADIUS * 2.0,
			"a solid card is thinner than its ports")
	_canvas.face_user(Vector3(2, 0, 0))
	_check(card.node.global_basis.z.dot(Vector3.RIGHT) > 0.99, "a solid card that faces the head turns to it")
	# Node back Labelled: from behind, a card that doesn't face the head turns round, mirrored.
	_canvas.set_node_modes(XREFeatureSettings.OFF, false, true, XREFeatureSettings.FACE, false)
	_canvas.rebuild(graph)
	card = (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	_canvas.face_user(front)
	var port := _canvas.port_position(1, 0, false)
	_check(not card.turned_round and not card.mirrored, "seen from the front, its face shows as it is")
	_canvas.face_user(behind)
	var moved := _canvas.port_position(1, 0, false)
	_check(card.turned_round and card.mirrored and card.node.global_basis.determinant() < 0.0, "seen from behind, it turns round, mirrored")
	_check(is_equal_approx(moved.x, port.x) and moved.z < 0.0, "its output stays on the same side, now on the face turned to the head")
	var title := card.labels[0]
	_check(title.scale.x < 0.0 and (card.node.global_basis * Vector3(title.scale.x, 0, 0)).dot(Vector3.LEFT) > 0.0, "its labels mirror back to read from behind")
	_check(_hit(moved, Vector3.BACK) >= 0 and _canvas.get_hit_port() == 0, "the port on the face turned to the head is picked from behind")
	_canvas.face_user(Vector3(2, 0, 0.1))
	_check(card.turned_round, "past 90° but within the margin, it stays turned round")
	_canvas.face_user(front)
	_check(not card.turned_round and not card.mirrored and title.scale.x > 0.0, "back in front, it turns back")
	# Pins Both faces: a blank back carries the ports while the head is behind.
	_canvas.set_node_modes(XREFeatureSettings.OFF, false, false, XREFeatureSettings.BOTH_FACES, false)
	_canvas.rebuild(graph)
	card = (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	_canvas.face_user(behind)
	_check(card.pins_back and not card.turned_round and _canvas.port_position(1, 0, false).z < 0.0, "from behind, the ports are on the back face")
	_canvas.face_user(front)
	_check(not card.pins_back and _canvas.port_position(1, 0, false).z > 0.0, "from the front, on the front face again")
	# Pins On the edge: a ball or an arrowhead on the edge, in the middle of the depth, picked from the side.
	_canvas.set_node_modes(XREFeatureSettings.OFF, true, false, XREFeatureSettings.EDGE, false)
	_canvas.rebuild(graph)
	card = (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	port = _canvas.port_position(1, 0, false)
	_check(is_equal_approx(port.x, card.width * 0.5) and is_zero_approx(port.z), "a port on the edge is on the card's right edge, in its depth's middle")
	_check(_hit(port, Vector3.LEFT) >= 0 and _canvas.get_hit_port() == 0, "it is picked from the side")
	_check(_hit(port + Vector3(0, 0, -0.012), Vector3.BACK) >= 0 and _canvas.get_hit_port() == 0, "and from behind")
	# Card mirror: a card that faces the head lays out as a mirror's past 95° from the graph's front.
	_canvas.set_node_modes(XREFeatureSettings.ON, false, false, XREFeatureSettings.FACE, true)
	_canvas.rebuild(graph)
	card = (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	_canvas.face_user(front)
	_check(not card.mirrored and _canvas.port_direction(1, false).x > 0.99, "in front, its output leaves to the right")
	_canvas.face_user(Vector3.FORWARD.rotated(Vector3.UP, deg_to_rad(-92.0)) * 2.0)
	_check(not card.mirrored, "at 92° it is not mirrored yet")
	_canvas.face_user(behind)
	_check(card.mirrored and _canvas.port_direction(1, false).x > 0.99, "behind, mirrored: its output still leaves towards the graph's right")
	_canvas.face_user(front)
	_check(not card.mirrored, "in front again, it is not")
	_canvas.set_node_modes(XREFeatureSettings.ON, false, false, XREFeatureSettings.FACE, false)
	_canvas.rebuild(graph)


## Card mirror and Graph turn (D-115) on a graph whose cards' centre is far from
## the canvas's origin: both go by that centre; a two-word heading, mirrored,
## still reads verb then member.
func _test_off_centre() -> void:
	var far := XREBlueprintGraph.new()
	var setter := XREBlueprintGraph.make_node(2, "set_property", Vector2(4000, 0))
	(setter["params"] as Dictionary).merge({"target": "Lamp", "property": "light_energy"}, true)
	setter["vr_heading"] = "member"
	far.nodes = [XREBlueprintGraph.make_operator(1, "add", Vector2.ZERO), setter]
	far.upgrade()
	var style := _canvas.get_style()
	_canvas.set_style(XREFeatureSettings.ARCHETYPES)
	_canvas.set_node_modes(XREFeatureSettings.ON, false, false, XREFeatureSettings.FACE, true)
	_canvas.rebuild(far)
	var cards := _canvas.get("_cards") as Array
	var centre := ((cards[0] as XREBlueprintCanvas.Card).base + (cards[1] as XREBlueprintCanvas.Card).base) * 0.5
	var card := cards[1] as XREBlueprintCanvas.Card
	var verb := card.node.get_node("Verb") as Label3D
	var member := card.node.get_node("Member") as Label3D
	_canvas.face_user(centre + Vector3(0, 0, 2))
	_check(not card.mirrored and verb.global_position.x < member.global_position.x, "in front, the heading reads Set, then Light Energy")
	# 93° from the canvas's origin, but straight behind the cards' centre.
	_canvas.face_user(centre + Vector3(0, 0, -0.1))
	_check(card.mirrored, "straight behind the cards' centre, a card mirrors although the canvas's origin sees the head at 93°")
	_check(verb.global_position.x > member.global_position.x and member.scale.x < 0.0, "mirrored, the heading still reads Set, then Light Energy, from behind")
	_canvas.face_user(centre + Vector3(0, 0, 2))
	_check(not card.mirrored and verb.global_position.x < member.global_position.x, "in front again, the heading is as built")
	_canvas.set_turn_modes(XREFeatureSettings.FLIP, false)
	_canvas.face_user(centre + Vector3(0, 0, -2))
	_check(_canvas.basis.z.dot(Vector3.FORWARD) > 0.99 and _canvas.to_global(centre).is_equal_approx(centre), "a flipping graph turns about its cards' centre")
	_canvas.set_turn_modes(XREFeatureSettings.FIXED, false)
	_canvas.set_node_modes(XREFeatureSettings.ON, false, false, XREFeatureSettings.FACE, false)
	_canvas.set_style(style)
	_canvas.face_user(Vector3(0, 0, 2))
	_check(_canvas.transform.is_equal_approx(Transform3D.IDENTITY), "Fixed puts it back")


## Graph turn (D-115) of [param graph], whole: the canvas itself turns about its centre.
func _test_graph_turn(graph: XREBlueprintGraph) -> void:
	_check(_canvas.set_turn_modes(XREFeatureSettings.FLIP, false) and not _canvas.set_turn_modes(&"spin", false), "Graph turn switches to Flip, an unknown mode is refused")
	_canvas.rebuild(graph)
	_canvas.face_user(Vector3(0, 0, 2))
	_check(_canvas.basis.is_equal_approx(Basis.IDENTITY), "in front, a flipping graph stays")
	_canvas.face_user(Vector3(0, 0, -2))
	_check(_canvas.basis.z.dot(Vector3.FORWARD) > 0.99, "behind, it turns round")
	_canvas.face_user(Vector3(2, 0, 0.1))
	_check(_canvas.basis.z.dot(Vector3.FORWARD) > 0.99, "past 85° it stays round")
	_canvas.face_user(Vector3(0, 0, 2))
	_check(_canvas.basis.is_equal_approx(Basis.IDENTITY), "in front again, it turns back")
	_canvas.set_turn_frozen(true)
	_canvas.face_user(Vector3(0, 0, -2))
	_check(_canvas.basis.is_equal_approx(Basis.IDENTITY), "nothing turns while something is held")
	_canvas.set_turn_frozen(false)
	_canvas.set_turn_modes(XREFeatureSettings.STEPS, false)
	_canvas.face_user(Vector3(0, 0, 2).rotated(Vector3.UP, deg_to_rad(60.0)))
	_check(_canvas.basis.z.dot(Vector3.RIGHT) > 0.99, "with Steps, past 50° it turns to the nearest front, 90°")
	_canvas.face_user(Vector3(0, 0, 2).rotated(Vector3.UP, deg_to_rad(50.0)))
	_check(_canvas.basis.z.dot(Vector3.RIGHT) > 0.99, "within 50° of that front it stays")
	_canvas.set_turn_modes(XREFeatureSettings.AIM, false)
	var side := Vector3(0, 0, 2).rotated(Vector3.UP, deg_to_rad(120.0))
	_canvas.face_user(side)
	_check(_canvas.basis.is_equal_approx(Basis.IDENTITY), "On aim, it doesn't turn by itself")
	_canvas.aim_at(1)
	_canvas.face_user(side)
	_check(_canvas.basis.z.dot(side.normalized()) > 0.99, "a ray coming onto it turns it to the head")
	_canvas.set_turn_modes(XREFeatureSettings.FIXED, false)
	_canvas.face_user(Vector3(0, 0, 2))
	_check(_canvas.basis.is_equal_approx(Basis.IDENTITY), "Fixed puts it back")
	_canvas.rebuild(graph)


## Graph parts, a card's yaw, Sign ports and wire arrowheads (D-115) on two
## operators, the second right of and above the first, wired from the first.
func _test_parts_and_wires() -> void:
	var pair := XREBlueprintGraph.new()
	pair.nodes = [XREBlueprintGraph.make_operator(1, "add", Vector2.ZERO), XREBlueprintGraph.make_operator(2, "add", Vector2(300, -200))]
	pair.edges = [{"from": 1, "from_port": 0, "to": 2, "to_port": 0}]
	pair.upgrade()
	# A card that doesn't face the head turns in steps of 15° with the hand's twist, and keeps its yaw.
	_canvas.set_node_modes(XREFeatureSettings.OFF, false, false, XREFeatureSettings.FACE, false)
	_canvas.rebuild(pair)
	var first := (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	_canvas.preview_grab(1, Vector3(0, 0, 0.5), Vector3.ZERO, Vector3(0, 0, 2), 0.3)
	_check(is_equal_approx(first.yaw, deg_to_rad(15.0)) and first.node.basis.z.dot(Vector3.BACK.rotated(Vector3.UP, deg_to_rad(15.0))) > 0.999, "a twist of 0.3 rad turns the card by 15°")
	_canvas.preview_transform(1, Transform3D.IDENTITY)
	_check(is_zero_approx(first.yaw), "a cancelled grab puts its yaw back")
	# Held, it turns to the head in steps of 15°, without flicking between two at a step's edge.
	_canvas.preview_grab(1, Vector3.ZERO, Vector3.ZERO, Vector3(2, 0, 0))
	_check(is_equal_approx(first.yaw, PI * 0.5) and first.node.basis.z.dot(Vector3.RIGHT) > 0.999, "a held card turns to the head beside it")
	_canvas.preview_transform(1, Transform3D.IDENTITY)
	for step: Array in [[5.0, 0.0, "5° off, it stays square"], [12.0, 15.0, "12° off, it steps to 15°"], [9.0, 15.0, "back at 9°, it keeps 15°"], [3.0, 0.0, "at 3°, it steps back"]]:
		_canvas.preview_grab(1, Vector3.ZERO, Vector3.ZERO, Vector3(0, 0, 2).rotated(Vector3.UP, deg_to_rad(step[0] as float)))
		_check(is_equal_approx(first.yaw, deg_to_rad(step[1] as float)), step[2] as String)
	_canvas.preview_transform(1, Transform3D.IDENTITY)
	# A new block comes turned to the head, in steps of 15°; with every card facing the head, as before.
	_canvas.face_user(Vector3(2, 0, 2))
	var block := {}
	_canvas.turn_to_head(block, Vector3.ZERO)
	_check(block.get("vr_rotation") is Vector3 and is_equal_approx((block["vr_rotation"] as Vector3).y, PI * 0.25), "a new block turns to the head")
	_canvas.set_node_modes(XREFeatureSettings.ON, false, false, XREFeatureSettings.FACE, false)
	block = {}
	_canvas.turn_to_head(block, Vector3.ZERO)
	_check(not block.has("vr_rotation"), "with Node facing On it keeps no yaw of its own")
	_canvas.set_node_modes(XREFeatureSettings.OFF, false, false, XREFeatureSettings.FACE, false)
	_canvas.rebuild(pair)
	first = (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	# Graph parts: cards of one yaw wired together turn as a part about its centre.
	pair.nodes[1]["vr_rotation"] = Vector3(0, PI, 0)
	_check(is_equal_approx(absf(XREBlueprintCanvas.yaw_of(pair.nodes[1])), PI), "a block's yaw is its vr_rotation's y")
	_canvas.set_turn_modes(XREFeatureSettings.FLIP, true)
	_canvas.rebuild(pair)
	_canvas.face_user(Vector3(0.1, 0, 3))
	_check(is_zero_approx(_canvas.get_part_turn(1)) and is_equal_approx(absf(_canvas.get_part_turn(2)), PI), "the part facing away flips, the one in front stays")
	_check(_canvas.basis.is_equal_approx(Basis.IDENTITY), "by parts, the canvas itself doesn't turn")
	var second := (_canvas.get("_cards") as Array)[1] as XREBlueprintCanvas.Card
	_check(second.node.position.is_equal_approx(second.base) and second.node.basis.z.dot(Vector3.BACK) > 0.99, "a flipped part of one card turns about its own centre, its face to the head")
	_canvas.set_turn_modes(XREFeatureSettings.FIXED, false)
	pair.nodes[1].erase("vr_rotation")
	# Sign ports on the rim: the first sign's result turns up and right, towards its wire's far end.
	_canvas.set_style(XREFeatureSettings.ARCHETYPES)
	_canvas.set_node_modes(XREFeatureSettings.ON, false, false, XREFeatureSettings.FACE, false)
	_check(_canvas.set_rim_ports(true) and not _canvas.set_rim_ports(true), "Sign ports switch to the rim once")
	_canvas.rebuild(pair)
	_canvas.face_user(Vector3(0, 0, 3))
	first = (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	var result := _canvas.port_position(1, 0, false) - first.node.position
	_check(result.x > 0.0 and result.y > 0.01 and absf(Vector2(result.x, result.y).length() - first.width * 0.5) < 0.001, "the result sits on the rim, towards the second sign: %s" % result)
	_canvas.set_rim_ports(false)
	_canvas.set_style(XREFeatureSettings.CLASSIC)
	_canvas.rebuild(pair)
	_canvas.face_user(Vector3(0, 0, 3))
	# Arrowheads: data chevrons on the data wire, none for execution, one at the end, open ones.
	var filled := _canvas.get("_arrows_filled") as MultiMeshInstance3D
	var open := _canvas.get("_arrows_open") as MultiMeshInstance3D
	_check(not _canvas.set_arrow_modes(&"dots", XREFeatureSettings.OFF, false), "an unknown arrow mode is refused")
	_check(_canvas.set_arrow_modes(XREFeatureSettings.CHEVRONS, XREFeatureSettings.OFF, false) and filled.multimesh.visible_instance_count == 0,
			"execution chevrons draw nothing on a data wire")
	_canvas.set_arrow_modes(XREFeatureSettings.OFF, XREFeatureSettings.CHEVRONS, false)
	var chevrons := filled.multimesh.visible_instance_count
	_check(chevrons >= 2 and filled.visible, "data chevrons lie along the data wire: %d" % chevrons)
	var tip := _canvas.get_arrow_pose(0)
	var wire_way := (_canvas.port_position(2, 0, true) - _canvas.port_position(1, 0, false)).normalized()
	_check(tip.basis.y.normalized().dot(wire_way) > 0.0, "a chevron points from the output towards the input")
	_canvas.set_arrow_modes(XREFeatureSettings.OFF, XREFeatureSettings.AT_END, false)
	_check(filled.multimesh.visible_instance_count == 1, "at the end, one arrowhead")
	_canvas.set_arrow_modes(XREFeatureSettings.OFF, XREFeatureSettings.RUNNING, true)
	var before := _canvas.get_arrow_pose(0).origin
	_canvas.face_user(Vector3(0, 0, 3), 0.25)
	_check(open.visible and not filled.visible and not _canvas.get_arrow_pose(0).origin.is_equal_approx(before), "open arrowheads run along the wire")
	# Out of focus with Defocus on Dim, arrowheads darken as their wire does; see-through with it.
	var modes := _canvas.get_focus_modes()
	_canvas.set_focus_modes(XREFeatureSettings.OFF, XREFeatureSettings.DIM)
	var wire := (_canvas.get("_wires") as Array)[0] as XREBlueprintCanvas.Wire
	wire.focus = XREBlueprintFocus.OUT
	var dimmed: Color = _canvas.call("_arrow_color", wire)
	_check(is_equal_approx(dimmed.r, wire.color.r * XREBlueprintFocus.DIM) and is_equal_approx(dimmed.a, wire.color.a), "out of focus, arrowheads darken as their wire")
	_canvas.set_wire_seen(wire, &"focus", 0.4)
	_check(is_equal_approx((_canvas.call("_arrow_color", wire) as Color).a, wire.color.a * 0.4), "and are as see-through as it")
	_canvas.set_wire_seen(wire, &"focus", 1.0)
	wire.focus = XREBlueprintFocus.NORMAL
	_canvas.set_focus_modes(modes[0], modes[1])
	_canvas.set_arrow_modes(XREFeatureSettings.OFF, XREFeatureSettings.OFF, false)
	_check(not filled.visible and not open.visible, "off, none are drawn")
	_canvas.set_node_modes(XREFeatureSettings.ON, false, false, XREFeatureSettings.FACE, false)


## D-132 on two operators wired from the first to the second: a card turned to
## the head mirrors as its wire runs across the view, with the head square to
## the graph's side, where the graph's front decides nothing; a sign's result
## on the rim stays within 90° of its right and goes towards its wire's bend;
## a plug stays in its port; a white wire under the ray turns gold.
func _test_flow_and_rim() -> void:
	var pair := XREBlueprintGraph.new()
	pair.nodes = [XREBlueprintGraph.make_operator(1, "add", Vector2.ZERO), XREBlueprintGraph.make_operator(2, "add", Vector2.ZERO)]
	pair.nodes[1]["vr_depth"] = -0.6
	pair.edges = [{"from": 1, "from_port": 0, "to": 2, "to_port": 0}]
	pair.upgrade()
	_canvas.set_node_modes(XREFeatureSettings.ON, false, false, XREFeatureSettings.FACE, true)
	_canvas.rebuild(pair)
	var cards := _canvas.get("_cards") as Array
	var first := cards[0] as XREBlueprintCanvas.Card
	var second := cards[1] as XREBlueprintCanvas.Card
	_canvas.face_user(Vector3(2, 0, -0.3))
	_check(not first.mirrored and not second.mirrored, "its wire running to the head's right, a card is not mirrored")
	_canvas.face_user(Vector3(-2, 0, -0.3))
	_check(first.mirrored and second.mirrored, "its wire running to the head's left, it is, though the head is square to the graph's side")
	_check(_canvas.port_direction(1, false).dot(second.node.position - first.node.position) > 0.0, "mirrored, its output leaves towards the next card")
	_canvas.face_user(Vector3(2, 0, -0.3))
	_check(not first.mirrored and not second.mirrored, "back on the other side, it is not")
	# Sign ports on the rim: the second sign to the left of the first.
	pair.nodes[1]["position"] = Vector2(-300, 0)
	pair.nodes[1].erase("vr_depth")
	var modes := _canvas.get_parameter_modes()
	_canvas.set_parameter_modes(XREFeatureSettings.PLUGS, modes[1], modes[2], modes[3])
	_canvas.set_style(XREFeatureSettings.ARCHETYPES)
	_canvas.set_node_modes(XREFeatureSettings.ON, false, false, XREFeatureSettings.FACE, false)
	_canvas.set_rim_ports(true)
	_canvas.rebuild(pair)
	_canvas.face_user(Vector3(0, 0, 3))
	first = (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	var result := _canvas.port_position(1, 0, false) - first.node.position
	_check(result.x > 0.003 and absf(result.y) < 0.001, "a result whose wire runs straight left folds back to its right, not to the edge (D-135): %s" % result)
	var plugs := 0
	for socket: XREBlueprintCanvas.Socket in first.sockets:
		if socket.kind != XREBlueprintCanvas.TOKEN or socket.port < 0: continue
		var port := first.ports[socket.port].position
		_check(Vector2(socket.visual.position.x, socket.visual.position.y).is_equal_approx(Vector2(port.x, port.y)), "a plug's cap stays in its port on the rim")
		_check(socket.center.x < socket.visual.position.x and is_equal_approx(socket.center.y, socket.visual.position.y), "its body level to the port's left")
		plugs += 1
	_check(plugs == 2, "the sign has a plug in each input: %d" % plugs)
	# A wire being drawn may end in a plugged input out of focus: the plug stays as it is with its port (D-135).
	var focus_modes := _canvas.get_focus_modes()
	_canvas.set_focus_modes(XREFeatureSettings.ON, XREFeatureSettings.DIM)
	_canvas.set_focus(Vector3i(2, -1, -1))
	_canvas.highlight_ports(XREBlueprintGraph.NUMBER, true)
	var kept := 0
	for index: int in first.sockets.size():
		var socket := first.sockets[index]
		if socket.kind == XREBlueprintCanvas.TOKEN and socket.port >= 0 and (first.keep_ports & (1 << socket.port)) != 0 and (first.keep_sockets & (1 << index)) != 0: kept += 1
	_check(first.focus == XREBlueprintFocus.OUT and kept == 2, "out of focus, both plugs in ports a number may end on are kept: %d" % kept)
	_canvas.highlight_ports(-1, false)
	_canvas.set_focus(Vector3i(-1, -1, -1))
	_check(first.keep_sockets == 0, "and let go with the wire")
	_canvas.set_focus_modes(focus_modes[0], focus_modes[1])
	# A bend behind the sign, left and below: its result folds back to its right, below (D-135).
	pair.edges[0]["vr_bends"] = PackedVector3Array([Vector3(-200, 100, 0)])
	_canvas.set_bends_shown(true)
	_canvas.rebuild(pair)
	_canvas.face_user(Vector3(0, 0, 3))
	first = (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	result = _canvas.port_position(1, 0, false) - first.node.position
	_check(result.x > 0.003 and result.y < -0.001, "a result whose wire runs back down to the left stays right, a little below: %s" % result)
	# A bend up and to the right of the first sign: its result goes towards the bend.
	pair.edges[0]["vr_bends"] = PackedVector3Array([Vector3(200, -200, 0)])
	_canvas.set_bends_shown(true)
	_canvas.rebuild(pair)
	_canvas.face_user(Vector3(0, 0, 3.1))
	first = (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	result = _canvas.port_position(1, 0, false) - first.node.position
	_check(result.x > 0.003 and result.y > 0.003, "a result goes towards its wire's bend, up and right: %s" % result)
	_canvas.set_bends_shown(false)
	_canvas.set_rim_ports(false)
	_canvas.set_style(XREFeatureSettings.CLASSIC)
	_canvas.set_parameter_modes(modes[0], modes[1], modes[2], modes[3])
	# An execution wire under the ray is gold; a data wire keeps its colour, thicker.
	for color: Color in [XREBlueprintCanvas.COLORS[0], XREBlueprintCanvas.COLORS[1]]:
		var wire := XREBlueprintCanvas.Wire.new()
		_canvas.call("_add_wire", wire, color, {})
		var tint: Color = (wire.lit as ShaderMaterial).get_shader_parameter(&"tint")
		_check(tint.is_equal_approx(XREBlueprintFocus.FRAME if color == XREBlueprintCanvas.COLORS[0] else color), "a wire of %s is %s under the ray" % [color, tint])
		_canvas.call("_free_wire", wire)
	_canvas.rebuild(pair)


## Archetypes (D-099): an event's header in its group's color with its icon,
## the trash in the plus's corner, picked only while the card is in focus; a
## pure function framed in its result's color; a call without an icon shows ƒ.
func _test_archetypes(graph: XREBlueprintGraph) -> void:
	_check(not _canvas.set_style(&"glyphs"), "an unknown node style is refused")
	_check(_canvas.set_style(XREFeatureSettings.ARCHETYPES), "the canvas switches to archetypes")
	_canvas.rebuild(graph)
	_canvas.face_user(Vector3(0, 0, 2))
	var card := (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	var head := card.node.get_node_or_null("Head") as MeshInstance3D
	_check(head != null and ((head.material_override as ShaderMaterial).get_shader_parameter(&"face_tint") as Color).is_equal_approx(XREBlueprintIcons.HEADS[XREBlueprintIcons.Group.EVENT]), "an event has a red header")
	var icon := card.node.get_node_or_null("Icon") as MeshInstance3D
	_check(icon != null and (icon.material_override as BaseMaterial3D).albedo_texture != null and card.node.get_node_or_null("Circle") != null, "with Ready's icon on its circle")
	_check(card.trash_point.x > 0.0 and card.trash_point.y > card.bounds.end.y and not card.trash.visible, "the trash stands over the right corner, hidden out of focus")
	var corner := Vector3(-card.width * 0.5 + 0.003, card.height * 0.5 - 0.003, 0)
	_check(not card.outline.is_empty() and _hit(card.node.position + corner, Vector3.FORWARD) < 0, "the event's card is rounded: its top left corner takes no ray (D-109)")
	_check(_hit(card.node.position + Vector3(0, 0, 0), Vector3.FORWARD) >= 0 and _canvas.get_hit_id() == 1, "its middle does")
	_check(_hit(card.trash_point, Vector3.FORWARD) < 0, "a hidden trash isn't picked")
	_canvas.set_focus(Vector3i(1, -1, -1))
	_check(card.trash.visible and _hit(card.trash_point, Vector3.FORWARD) >= 0 and _canvas.get_hit_delete(), "in focus the trash shows and is picked")
	var air := card.node.position + Vector3(card.trash_point.x, card.bounds.end.y + 0.003, card.trash_point.z)
	_check(_hit(air, Vector3.FORWARD) >= 0 and _canvas.get_hit_id() == 1 and not _canvas.get_hit_delete(), "the air between the card and its trash keeps the card under the ray (D-114)")
	var stand_in := _canvas.stand_in(1)
	_check(stand_in != null and stand_in.get_child_count() == card.node.get_child_count() and not (stand_in.get_child(card.trash.get_index()) as Node3D).visible
			and (stand_in.get_child(card.plus.get_index()) as Node3D).visible == false, "a copy's stand-in is the card without its buttons (D-114)")
	stand_in.free()
	_canvas.set_focus(Vector3i(-1, -1, -1))
	_check(not card.trash.visible, "and hides when the focus goes")
	_check(_hit(air, Vector3.FORWARD) < 0, "and the air is air again")
	var calls := XREBlueprintGraph.new()
	calls.nodes = [XREBlueprintGraph.make_call(1, XREBlueprintFunctions.global("lerpf"), Vector2.ZERO),
			XREBlueprintGraph.make_call(2, XREBlueprintFunctions.method("Node3D", "look_at"), Vector2(0, 300)),
			XREBlueprintGraph.make_node(3, "delay", Vector2(0, 600))]
	calls.upgrade()
	_canvas.rebuild(calls)
	var pure := (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	var sign := pure.node.get_node_or_null("Fallback") as Label3D
	_check(pure.node.get_node_or_null("Head") == null and sign != null and sign.text == "ƒ" and sign.modulate.is_equal_approx(XREBlueprintCanvas.COLORS[XREBlueprintGraph.NUMBER]),
			"a pure function without an icon has no header and a ƒ in its result's color")
	_check((pure.frame_material as BaseMaterial3D).albedo_color.is_equal_approx(XREBlueprintCanvas.COLORS[XREBlueprintGraph.NUMBER]), "and is framed in it")
	var call := (_canvas.get("_cards") as Array)[1] as XREBlueprintCanvas.Card
	_check(call.node.get_node_or_null("Head") != null and call.node.get_node_or_null("Circle") != null and call.node.get_node_or_null("Fallback") != null, "a function without an icon has a blue header and a ƒ on its circle")
	var delay := (_canvas.get("_cards") as Array)[2] as XREBlueprintCanvas.Card
	_check(((delay.node.get_node("Head") as MeshInstance3D).material_override as ShaderMaterial).get_shader_parameter(&"face_tint") == XREBlueprintIcons.HEADS[XREBlueprintIcons.Group.FLOW], "Delay is in the grey of flow")
	_check(XREBlueprintIcons.icon_of(delay_block(calls), Callable()) == &"delay", "with the hourglass")
	_check(_canvas.set_style(XREFeatureSettings.CLASSIC), "the canvas switches back to classic")
	_canvas.rebuild(graph)
	card = (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	_check(card.node.get_node_or_null("Head") == null and card.trash.visible and card.trash_point.x < 0.0, "classic cards have their trash in the left corner again")


## Signs of variadic operators (D-136): Add of three is a circle with its
## inputs on the arc, of five a column, AND of four a taller pill, each input
## on the outline a step apart; Append is a card.
func _test_growing_signs() -> void:
	var graph := XREBlueprintGraph.new()
	var specs := [["add", 3], ["add", 5], ["and", 4], ["append", 3], ["min", 2]]
	for index: int in specs.size():
		var block := XREBlueprintGraph.make_operator(index + 1, str(specs[index][0]), Vector2(0, index * 300))
		for extra: int in range(2, int(specs[index][1])): block["params"][XREBlueprintOperators.OPERAND_KEYS[extra]] = XREBlueprintOperators.operand_default(str(specs[index][0]), extra)
		if int(specs[index][1]) > 2: block["params"]["operands"] = specs[index][1]
		graph.nodes.append(block)
	_check(graph.validate().is_empty(), "the operators validate: %s" % graph.validate())
	_canvas.set_style(XREFeatureSettings.ARCHETYPES)
	_canvas.rebuild(graph)
	_canvas.face_user(Vector3(0, 0, 50))
	var cards := _canvas.get("_cards") as Array
	var shapes: Array[int] = [XREBlueprintShapes.Shape.CIRCLE, XREBlueprintShapes.Shape.COLUMN, XREBlueprintShapes.Shape.PILL, XREBlueprintShapes.Shape.NONE, XREBlueprintShapes.Shape.CIRCLE]
	for index: int in shapes.size():
		_check((cards[index] as XREBlueprintCanvas.Card).shape == shapes[index], "%s of %d is shape %d" % [specs[index][0], specs[index][1], shapes[index]])
	_check((cards[3] as XREBlueprintCanvas.Card).compact, "Append is a compact card")
	var column := cards[1] as XREBlueprintCanvas.Card
	_check(column.height > column.width + XREBlueprintShapes.INPUT_STEP and is_equal_approx(column.width, XREBlueprintShapes.CIRCLE_RADIUS * 2.0), "the column is as wide as the circle and taller")
	for index: int in [0, 1, 2]:
		var card := cards[index] as XREBlueprintCanvas.Card
		var on_outline := true
		var places: Array[float] = []
		for port: int in int(specs[index][1]):
			var at := _canvas.port_position(index + 1, port, true) - card.node.position
			places.append(at.y)
			on_outline = on_outline and _outline_distance(card.outline, Vector2(at.x, at.y)) < 0.001
		_check(on_outline, "the inputs of %s of %d are on its outline" % specs[index])
		var falling := true
		for port: int in range(1, places.size()): falling = falling and places[port] < places[port - 1]
		_check(falling, "its inputs go down from the top: %s" % [places])
		if index > 0: _check(is_equal_approx(places[0] - places[1], XREBlueprintShapes.INPUT_STEP), "a step of %.3f m apart" % XREBlueprintShapes.INPUT_STEP)
	_check(_hit(column.node.position + Vector3(0, column.height * 0.4, 0), Vector3.FORWARD) >= 0 and _canvas.get_hit_id() == 2, "the column takes the ray near its top")
	_check(((cards[4] as XREBlueprintCanvas.Card).node.get_node("Symbol") as Label3D).text == "min", "min is a circle with its word")


## The distance from [param point] to the nearest edge of [param outline].
func _outline_distance(outline: PackedVector2Array, point: Vector2) -> float:
	var nearest := INF
	for index: int in outline.size():
		var closest := Geometry2D.get_closest_point_to_segment(point, outline[index], outline[(index + 1) % outline.size()])
		nearest = minf(nearest, closest.distance_to(point))
	return nearest


## Signs (D-100): an archetype's operator is a circle, a comparison a
## diamond, logic a pill, each in its result's color and picked inside its
## outline; with Node shrink on + Math a math function of one or two inputs is
## a circle with an inner rim and its name, of three an oval whose tokens say
## their names. Classic and Operators keep the cards.
func _test_signs() -> void:
	var signs := XREBlueprintGraph.new()
	signs.nodes = [XREBlueprintGraph.make_operator(1, "add", Vector2.ZERO), XREBlueprintGraph.make_operator(2, "less", Vector2(0, 200)),
			XREBlueprintGraph.make_operator(3, "and", Vector2(0, 400)), XREBlueprintGraph.make_call(4, XREBlueprintFunctions.global("sin"), Vector2(0, 600)),
			XREBlueprintGraph.make_call(5, XREBlueprintFunctions.global("clampf"), Vector2(0, 800)), XREBlueprintGraph.make_call(6, XREBlueprintFunctions.global("absf"), Vector2(0, 1000))]
	signs.upgrade()
	_canvas.set_style(XREFeatureSettings.ARCHETYPES)
	_canvas.rebuild(signs)
	_canvas.face_user(Vector3(0, 0, 50))
	var cards := _canvas.get("_cards") as Array
	var shapes: Array[int] = [XREBlueprintShapes.Shape.CIRCLE, XREBlueprintShapes.Shape.DIAMOND, XREBlueprintShapes.Shape.PILL]
	for index: int in shapes.size():
		_check((cards[index] as XREBlueprintCanvas.Card).shape == shapes[index], "operator %d is its group's sign" % (index + 1))
	var add := cards[0] as XREBlueprintCanvas.Card
	var origin := add.node.position
	_check(_hit(origin, Vector3.FORWARD) >= 0 and _canvas.get_hit_id() == 1, "a circle takes the ray in its middle")
	var corner := origin + Vector3(XREBlueprintShapes.CIRCLE_RADIUS * 0.9, XREBlueprintShapes.CIRCLE_RADIUS * 0.9, 0)
	_check(_hit(corner, Vector3.FORWARD) < 0 or _canvas.get_hit_id() != 1, "but not in the corner of its box, outside the circle")
	_check(_faces_front(add.frame.mesh) and _faces_front(add.mesh.mesh), "the sign's rim and face wind clockwise toward the front, as Godot draws front faces")
	var port := _canvas.port_position(1, 0, true) - origin
	_check(absf(Vector2(port.x, port.y).length() - XREBlueprintShapes.CIRCLE_RADIUS) < 0.0005 and port.y > 0.0, "its first input is on its outline, at the top left")
	_check(((add.node.get_node("Symbol") as Label3D).modulate).is_equal_approx(XREBlueprintCanvas.COLORS[add.output_types[0]]), "its symbol is in its result's color")
	_check((cards[1] as XREBlueprintCanvas.Card).frame_material == _canvas.call("_type_frame", XREBlueprintGraph.BOOLEAN), "a comparison's rim is bool's")
	_check((cards[3] as XREBlueprintCanvas.Card).shape == XREBlueprintShapes.Shape.NONE, "with Operators, sin is a card")
	_check(_canvas.set_shrink(XREFeatureSettings.MATH) and not _canvas.set_shrink(&"glyphs"), "Node shrink switches to + Math")
	var modes := _canvas.get_parameter_modes()
	_canvas.set_parameter_modes(XREFeatureSettings.PLUGS, modes[1], modes[2], modes[3])
	_canvas.rebuild(signs)
	cards = _canvas.get("_cards") as Array
	var sine := cards[3] as XREBlueprintCanvas.Card
	_check(sine.shape == XREBlueprintShapes.Shape.CIRCLE and sine.node.get_node_or_null("Rim") != null and (sine.node.get_node("Symbol") as Label3D).text == "sin", "with + Math, sin is a circle with an inner rim and its name")
	var clamp := cards[4] as XREBlueprintCanvas.Card
	var labels: Array[String] = []
	for child: Node in clamp.node.find_children("*", "Label3D", true, false): labels.append((child as Label3D).text)
	_check(clamp.shape == XREBlueprintShapes.Shape.OVAL and (clamp.node.get_node("Symbol") as Label3D).text == "clamp" and labels.any(func(text: String) -> bool: return text.begins_with("min ")),
			"clampf is an oval, its min token says its name: %s" % [labels])
	_check(((cards[5] as XREBlueprintCanvas.Card).node.get_node("Symbol") as Label3D).text == "abs", "absf is abs, as a word")
	_check(_canvas.set_style(XREFeatureSettings.CLASSIC), "classic again")
	_canvas.rebuild(signs)
	cards = _canvas.get("_cards") as Array
	_check((cards[0] as XREBlueprintCanvas.Card).shape == XREBlueprintShapes.Shape.NONE and (cards[0] as XREBlueprintCanvas.Card).compact and not (cards[3] as XREBlueprintCanvas.Card).compact, "classic keeps the operators' cards and sin's")
	_canvas.set_shrink(XREFeatureSettings.OPERATORS)
	_canvas.set_parameter_modes(modes[0], modes[1], modes[2], modes[3])


## An archetype's card (D-101): In and Then on the header's edges, the target
## on the row under it, an event's policy a puck in the header; in Member the
## header says the member with the operation under it and the target row has
## no adapter; a block's own vr_heading wins over the setting; ⇄ shows and is
## picked with the trash.
func _test_headings() -> void:
	var cards_graph := XREBlueprintGraph.new()
	var event := XREBlueprintGraph.make_node(1, "signal", Vector2.ZERO)
	(event["params"] as Dictionary).merge({"target": "Gate", "signal": "body_entered"}, true)
	var setter := XREBlueprintGraph.make_node(2, "set_property", Vector2(0, 300))
	(setter["params"] as Dictionary).merge({"target": "Lamp", "property": "light_energy"}, true)
	var own := XREBlueprintGraph.make_node(3, "set_property", Vector2(0, 600))
	(own["params"] as Dictionary).merge({"target": "Lamp", "property": "visible"}, true)
	own["vr_heading"] = "member"
	XREBlueprintLinks.set_link(setter, XREBlueprintLinks.TARGET, true)
	var rotate := XREBlueprintGraph.make_call(4, XREBlueprintFunctions.method("Node3D", "rotate_x"), Vector2(0, 900))
	var linked_rotate := XREBlueprintGraph.make_call(5, XREBlueprintFunctions.method("Node3D", "rotate_x"), Vector2(0, 1200))
	XREBlueprintLinks.set_link(linked_rotate, XREBlueprintLinks.TARGET, true)
	cards_graph.nodes = [event, setter, own, rotate, linked_rotate]
	cards_graph.upgrade()
	var modes := _canvas.get_parameter_modes()
	_canvas.set_parameter_modes(XREFeatureSettings.PLUGS, XREFeatureSettings.ADAPTER, modes[2], modes[3])
	_canvas.set_style(XREFeatureSettings.ARCHETYPES)
	_canvas.rebuild(cards_graph)
	_canvas.face_user(Vector3(0, 0, 50))
	var cards := _canvas.get("_cards") as Array
	var signal_card := cards[0] as XREBlueprintCanvas.Card
	var set_card := cards[1] as XREBlueprintCanvas.Card
	var head_y := signal_card.height * 0.5 - XREBlueprintCanvas.HEAD_HEIGHT * 0.5
	_check(signal_card.headed and is_equal_approx(signal_card.outputs[0].y, head_y), "an event's Then is on its header's right edge")
	_check(is_equal_approx(set_card.inputs[0].y, set_card.height * 0.5 - XREBlueprintCanvas.HEAD_HEIGHT * 0.5) and set_card.inputs[0].x < 0.0, "a Set's In is on its header's left edge")
	var target := XREBlueprintGraph.target_port(setter)
	_check(set_card.inputs[target].y > set_card.inputs[1 if target != 1 else 2].y, "its Target is on the row under the header, above Value")
	_check((set_card.node.get_node("Title") as Label3D).text == "Set" and (signal_card.node.get_node("Title") as Label3D).text == "On Signal", "the headers say the operation: Set, On Signal")
	var band := set_card.node.get_node("Head") as MeshInstance3D
	var band_front := band.position.z + band.mesh.get_aabb().end.z
	_check((set_card.node.get_node("Title") as Label3D).position.z > band_front and (set_card.node.get_node("Circle") as Node3D).position.z > band_front and set_card.frame.mesh.get_aabb().end.z > band_front,
			"the title, the icon's circle and the outline stand before the header, seen out of focus too (D-110)")
	var chip: XREBlueprintCanvas.Socket = null
	var adapters := 0
	for socket: XREBlueprintCanvas.Socket in signal_card.sockets:
		if socket.key == "policy": chip = socket
		if socket.kind == XREBlueprintCanvas.MEMBER: adapters += 1
	_check(chip != null and is_equal_approx(chip.center.y, head_y) and chip.center.x > 0.0, "the policy is a chip in the event's header")
	_check(adapters == 1, "in Operation the event's Source has its adapter")
	var kinds: Array[int] = []
	for socket: XREBlueprintCanvas.Socket in (cards[3] as XREBlueprintCanvas.Card).sockets: kinds.append(socket.kind)
	_check(not kinds.has(XREBlueprintCanvas.MEMBER), "Rotate X takes its object itself: no adapter on its Target (D-112)")
	kinds.clear()
	for socket: XREBlueprintCanvas.Socket in (cards[4] as XREBlueprintCanvas.Card).sockets: kinds.append(socket.kind)
	_check(kinds.has(XREBlueprintCanvas.LINK) and not kinds.has(XREBlueprintCanvas.MEMBER), "its link goes into the port, with no adapter")
	var mine := cards[2] as XREBlueprintCanvas.Card
	_check((mine.node.get_node("Member") as Label3D).text == "Visible" and (mine.node.get_node("Verb") as Label3D).text == "Set" and _canvas.heading_of(own) == XREFeatureSettings.MEMBER, "a block's own vr_heading says its member over the setting")
	_check(_canvas.set_heading(XREFeatureSettings.MEMBER) and not _canvas.set_heading(&"both"), "Node heading switches to Member")
	_canvas.rebuild(cards_graph)
	cards = _canvas.get("_cards") as Array
	signal_card = cards[0] as XREBlueprintCanvas.Card
	set_card = cards[1] as XREBlueprintCanvas.Card
	_check((signal_card.node.get_node("Member") as Label3D).text == "Body Entered" and (set_card.node.get_node("Member") as Label3D).text == "Light Energy"
			and (signal_card.node.get_node("Verb") as Label3D).text == "On", "in Member the headers say On Body Entered and Set Light Energy, on one line (D-107)")
	var source_adapters := 0
	for socket: XREBlueprintCanvas.Socket in signal_card.sockets:
		if socket.kind == XREBlueprintCanvas.MEMBER and socket.visual.name != "Member": source_adapters += 1
	_check(source_adapters == 0, "in Member the event's Source has no adapter (D-107)")
	var members: Array[XREBlueprintCanvas.Socket] = []
	for socket: XREBlueprintCanvas.Socket in set_card.sockets:
		if socket.kind == XREBlueprintCanvas.MEMBER: members.append(socket)
	_check(members.size() == 1 and members[0].visual.name == "Member", "the Set's member is the header's, its Target has no adapter")
	var ring: XREBlueprintCanvas.Socket = null
	for socket: XREBlueprintCanvas.Socket in set_card.sockets:
		if socket.kind == XREBlueprintCanvas.LINK: ring = socket
	_check(ring != null and ring.visual.get_node_or_null("Token") == null and ring.visual.has_meta(&"head"), "its link is a ring alone, no plug (D-107)")
	var ring_words: Array[String] = []
	for child: Node in (ring.visual.get_meta(&"head") as Node3D).find_children("*", "Label3D", true, false): ring_words.append((child as Label3D).text)
	_check(ring_words.has("link"), "and says link in it (D-110): %s" % [ring_words])
	var member_socket := -1
	for index: int in set_card.sockets.size():
		if set_card.sockets[index].visual.name == "Member": member_socket = index
	_canvas.hover_socket(2, member_socket, true)
	var member_label := set_card.node.get_node("Member") as Label3D
	_check(member_label.scale.is_equal_approx(Vector3.ONE) and member_label.modulate.is_equal_approx(XREBlueprintCanvas.MEMBER_HOVER), "the member under the ray changes colour, not size (D-110)")
	_canvas.hover_socket(-1, -1, true)
	# Another card's socket under the ray leaves a dark member dark (D-114).
	XREBlueprintFocus.paint(member_label, XREBlueprintFocus.DARK)
	var dark := member_label.modulate
	_canvas.hover_socket(1, 0, true)
	_check(member_label.modulate.is_equal_approx(dark), "a member out of focus stays dark while the ray is on another card")
	_canvas.hover_socket(2, member_socket, true)
	_check(member_label.modulate.v < XREBlueprintCanvas.MEMBER_HOVER.v, "and lights up dark under the ray")
	_canvas.hover_socket(-1, -1, true)
	XREBlueprintFocus.paint(member_label, XREBlueprintFocus.PLAIN)
	_check(member_label.modulate.is_equal_approx(XREBlueprintCanvas.MEMBER_COLOR), "and is its own colour back in focus")
	_check(set_card.swap != null and not set_card.swap.visible, "⇄ waits for the focus")
	_canvas.set_focus(Vector3i(2, -1, -1))
	_check(set_card.swap.visible and _hit(set_card.node.position + set_card.swap_point, Vector3.FORWARD) >= 0 and _canvas.get_hit_swap() and not _canvas.get_hit_delete(), "in focus ⇄ shows by the trash and is picked")
	var between := set_card.node.position + (set_card.swap_point + set_card.trash_point) * 0.5
	_check(_hit(between, Vector3.FORWARD) >= 0 and _canvas.get_hit_id() == 2 and not _canvas.get_hit_swap() and not _canvas.get_hit_delete(), "the air between ⇄ and the trash keeps the card (D-114)")
	_canvas.hover_actions(2, false, false, true, -1, false, -1, false, false, true)
	_check(is_equal_approx(set_card.swap.scale.x, XREBlueprintCanvas.HOVER_SCALE), "⇄ grows under the ray, as the trash does (D-132)")
	_canvas.hover_actions(-1, false, false, true)
	_check(is_equal_approx(set_card.swap.scale.x, 1.0), "and shrinks back off it")
	_canvas.set_focus(Vector3i(-1, -1, -1))
	_check(_canvas.set_style(XREFeatureSettings.CLASSIC), "classic again")
	_canvas.rebuild(cards_graph)
	_check(_canvas.heading_of(own) == XREFeatureSettings.OPERATION and not ((_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card).headed, "classic cards say the operation, as before")
	_canvas.set_heading(XREFeatureSettings.OPERATION)
	_canvas.set_parameter_modes(modes[0], modes[1], modes[2], modes[3])


## Beads (D-103): with + System Delay is a bead in flow's grey rimmed white,
## its ports on its arcs, Get Time and Random rings in their result's colour,
## Random's tokens saying their names; with All with icons a Set and a
## Branch are beads too, Branch's outputs named outside, but not an event, a
## function without an icon (ƒ) or Make Color with four inputs. A bead's name
## shows under the ray.
func _test_beads() -> void:
	var beads := XREBlueprintGraph.new()
	beads.nodes = [XREBlueprintGraph.make_node(1, "delay", Vector2.ZERO),
			XREBlueprintGraph.make_call(2, XREBlueprintFunctions.static_function("XREBlueprintLibrary", "get_time"), Vector2(0, 200)),
			XREBlueprintGraph.make_call(3, XREBlueprintFunctions.global("randi_range"), Vector2(0, 400)),
			XREBlueprintGraph.make_node(4, "set_property", Vector2(0, 600)), XREBlueprintGraph.make_node(5, "branch", Vector2(0, 800)),
			XREBlueprintGraph.make_call(6, XREBlueprintFunctions.static_function("XREBlueprintLibrary", "make_color"), Vector2(0, 1000)),
			XREBlueprintGraph.make_node(7, "signal", Vector2(0, 1200)),
			XREBlueprintGraph.make_call(8, XREBlueprintFunctions.method("Node3D", "look_at"), Vector2(0, 1400)),
			XREBlueprintGraph.make_call(9, XREBlueprintFunctions.global("sin"), Vector2(0, 1600))]
	beads.upgrade()
	var modes := _canvas.get_parameter_modes()
	_canvas.set_parameter_modes(XREFeatureSettings.PLUGS, modes[1], modes[2], modes[3])
	_canvas.set_style(XREFeatureSettings.ARCHETYPES)
	_canvas.set_shrink(XREFeatureSettings.MATH)
	_canvas.rebuild(beads)
	_canvas.face_user(Vector3(0, 0, 50))
	_check(not ((_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card).bead, "with + Math Delay is a card")
	_check(_canvas.set_shrink(XREFeatureSettings.SYSTEM), "Node shrink switches to + System")
	_canvas.rebuild(beads)
	var cards := _canvas.get("_cards") as Array
	var delay := cards[0] as XREBlueprintCanvas.Card
	var face := (delay.mesh.material_override as ShaderMaterial).get_shader_parameter(&"face_tint") as Color
	_check(delay.bead and face.is_equal_approx(XREBlueprintIcons.HEADS[XREBlueprintIcons.Group.FLOW]) and (delay.frame_material as BaseMaterial3D).albedo_color.is_equal_approx(XREBlueprintCanvas.COLORS[XREBlueprintGraph.EXEC]),
			"with + System Delay is a bead in flow's grey rimmed white")
	var port := delay.inputs[0]
	_check(port.x < 0.0 and port.y > 0.0 and absf(Vector2(port.x, port.y).length() - XREBlueprintCanvas.BEAD_RADIUS) < 0.0005, "its In is on its left arc, at the top")
	var time := cards[1] as XREBlueprintCanvas.Card
	_check(time.bead and (time.frame_material as BaseMaterial3D).albedo_color.is_equal_approx(XREBlueprintCanvas.COLORS[XREBlueprintGraph.NUMBER]) and time.node.get_node_or_null("Icon") != null, "Get Time is a ring in float's colour with its dial")
	var random := cards[2] as XREBlueprintCanvas.Card
	var texts: Array[String] = []
	for child: Node in random.node.find_children("*", "Label3D", true, false): texts.append((child as Label3D).text)
	_check(random.bead and texts.any(func(text: String) -> bool: return text.begins_with("from ")), "Random is a ring whose tokens say their names: %s" % [texts])
	_check(not (cards[3] as XREBlueprintCanvas.Card).bead, "Set is a card with + System")
	_check(not delay.tip.visible, "a bead's name waits for the ray")
	_canvas.set_focus(Vector3i(1, -1, -1))
	_check(delay.tip.visible and delay.tip.text == "Delay" and delay.tip.font_size == XREBlueprintCanvas.TIP_SIZE, "under the ray a bead says its name, large (D-108)")
	_canvas.set_focus(Vector3i(-1, -1, -1))
	_check(_canvas.set_shrink(XREFeatureSettings.ICONS), "Node shrink switches to All with icons")
	_canvas.rebuild(beads)
	cards = _canvas.get("_cards") as Array
	var setter := cards[3] as XREBlueprintCanvas.Card
	_check(setter.bead and ((setter.mesh.material_override as ShaderMaterial).get_shader_parameter(&"face_tint") as Color).is_equal_approx(XREBlueprintIcons.HEADS[XREBlueprintIcons.Group.SET]), "with All with icons Set is a green bead")
	var branch := cards[4] as XREBlueprintCanvas.Card
	var named: Array[String] = []
	for child: Node in branch.node.find_children("*", "Label3D", true, false): named.append((child as Label3D).text)
	_check(branch.bead and named.has("True") and named.has("False"), "Branch is a bead, its outputs named outside")
	_check((cards[8] as XREBlueprintCanvas.Card).shape == XREBlueprintShapes.Shape.CIRCLE and not (cards[8] as XREBlueprintCanvas.Card).bead, "sin stays a math sign with All with icons")
	_check(not (cards[5] as XREBlueprintCanvas.Card).bead and not (cards[6] as XREBlueprintCanvas.Card).bead and not (cards[7] as XREBlueprintCanvas.Card).bead,
			"Make Color's four inputs, an event and a function without an icon keep their cards")
	_canvas.set_shrink(XREFeatureSettings.OPERATORS)
	_canvas.set_style(XREFeatureSettings.CLASSIC)
	_canvas.set_parameter_modes(modes[0], modes[1], modes[2], modes[3])


## Port shapes (D-104): with them on a port's mesh is its type's shape, one
## mesh a type, flat and facing the front, its colour as before, picked as a
## port was; off, ports are discs again.
func _test_port_shapes() -> void:
	var shaped := XREBlueprintGraph.new()
	shaped.nodes = [XREBlueprintGraph.make_node(1, "branch", Vector2.ZERO), XREBlueprintGraph.make_node(2, "delay", Vector2(0, 300))]
	shaped.upgrade()
	_check(_canvas.set_port_shapes(true) and not _canvas.set_port_shapes(true), "port shapes switch on once")
	_canvas.rebuild(shaped)
	_canvas.face_user(Vector3(0, 0, 50))
	var branch := (_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	var delay := (_canvas.get("_cards") as Array)[1] as XREBlueprintCanvas.Card
	var condition := branch.ports[1].mesh
	var seconds := delay.ports[1].mesh
	_check(condition is ArrayMesh and seconds is ArrayMesh and condition != seconds, "bool's port and float's are shapes of their own")
	_check(branch.ports[0].mesh == delay.ports[0].mesh, "execution's ports share one arrow")
	_check(_faces_front(condition) and _faces_front(branch.ports[0].mesh), "the shapes face the front")
	_check(((branch.ports[1] as MeshInstance3D).material_override as BaseMaterial3D).albedo_color.is_equal_approx(XREBlueprintCanvas.COLORS[XREBlueprintGraph.BOOLEAN]), "in bool's colour as before")
	var port := _canvas.port_position(1, 1, true)
	_check(_hit(port, Vector3.FORWARD) >= 0 and _canvas.get_hit_port() == 1 and _canvas.get_hit_input(), "a shaped port is picked as a port")
	_check(_canvas.set_port_shapes(false), "port shapes switch off")
	_canvas.rebuild(shaped)
	_check(((_canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card).ports[1].mesh is CylinderMesh, "ports are discs again")


## The mockup's details (D-106): an event's policy a narrow chip with its
## icon; On Ready says its member too; execution ports arrows on the card's
## edges; Branch's True and False tabs; Get Time's dial; a bead's name large;
## a variable's box read on its right edge and written from its top, its
## trash under the ray; a Get Variable without boxes a tag.
func _test_mockup_details() -> void:
	var details := XREBlueprintGraph.new()
	details.nodes = [XREBlueprintGraph.make_node(1, "ready", Vector2.ZERO), XREBlueprintGraph.make_node(2, "branch", Vector2(0, 300)),
			XREBlueprintGraph.make_call(3, XREBlueprintFunctions.static_function("XREBlueprintLibrary", "get_time"), Vector2(0, 600))]
	var getter := XREBlueprintGraph.make_node(4, "get_variable", Vector2(0, 900))
	getter["params"]["variable"] = "speed"
	details.nodes.append(getter)
	details.nodes.append(XREBlueprintGraph.make_operator(5, "multiply", Vector2(0, 1200)))
	details.variables = [{"name": "speed", "value": 1.5}, {"name": "spot", "value": Vector3.ONE, "vr_collapsed": false}, {"name": "aim", "value": Vector3.ONE}]
	details.upgrade()
	var modes := _canvas.get_parameter_modes()
	_canvas.set_parameter_modes(XREFeatureSettings.PLUGS, XREFeatureSettings.ADAPTER, modes[2], XREFeatureSettings.WINDOW)
	_canvas.set_style(XREFeatureSettings.ARCHETYPES)
	_canvas.set_shrink(XREFeatureSettings.SYSTEM)
	_canvas.rebuild(details)
	_canvas.face_user(Vector3(0, 0, 50))
	var cards := _canvas.get("_cards") as Array
	var ready := cards[0] as XREBlueprintCanvas.Card
	var chip := ready.node.get_node_or_null("Chip") as Node3D
	var chip_socket: XREBlueprintCanvas.Socket = null
	for socket: XREBlueprintCanvas.Socket in ready.sockets:
		if socket.key == "policy": chip_socket = socket
	_check(chip != null and chip_socket != null and chip_socket.visual == chip and chip_socket.size.x < 0.09, "the policy is a narrow chip of its own: %s" % [chip_socket.size if chip_socket != null else null])
	_check(XREBlueprintCanvas.can_head(details.nodes[0]) and XREBlueprintCanvas.member_of(details.nodes[0]) == "ready" and XREBlueprintCanvas.verb_of(details.nodes[0]) == "On"
			and XREBlueprintCanvas.operation_of(details.nodes[0]) == "On Signal", "On Ready is an event as any: On Ready in Member, On Signal in Operation")
	_check(is_equal_approx(ready.outputs[0].x, ready.width * 0.5) and ready.ports[ready.inputs.size()].mesh is ArrayMesh, "its Then is an arrow on the card's edge")
	var branch := cards[1] as XREBlueprintCanvas.Card
	var tabs := branch.node.find_children("Tab*", "MeshInstance3D", false, false)
	_check(tabs.size() == 2 and is_equal_approx(branch.outputs[0].x, branch.width * 0.5), "Branch has True and False tabs, its outputs on the edge")
	_check((tabs[0] as MeshInstance3D).mesh is ArrayMesh, "the tabs are round at their left ends (D-107)")
	_check(is_equal_approx(((tabs[0] as MeshInstance3D).material_override as BaseMaterial3D).albedo_color.a, 1.0) and (tabs[0] as MeshInstance3D).mesh.get_aabb().size.y < XREBlueprintCanvas.ROW_HEIGHT * 0.7,
			"and opaque and low (D-108)")
	_check((tabs[0] as MeshInstance3D).mesh.get_aabb().size.x < 0.08 and is_equal_approx((tabs[0] as MeshInstance3D).mesh.get_aabb().size.x, (tabs[1] as MeshInstance3D).mesh.get_aabb().size.x),
			"and as narrow as their marks and names, both alike (D-111)")
	_check(not XREBlueprintCanvas.can_head(XREBlueprintGraph.make_call(9, XREBlueprintFunctions.method("Node3D", "rotate_x"), Vector2.ZERO)), "Rotate X has no member to say, only its operation (D-108)")
	var times := cards[4] as XREBlueprintCanvas.Card
	_check(((times.ports[1] as MeshInstance3D).material_override as BaseMaterial3D).albedo_color.is_equal_approx(XREBlueprintCanvas.COLORS[XREBlueprintGraph.NUMBER]),
			"an operand with a float token has a float's port, not any value's (D-107)")
	var time := cards[2] as XREBlueprintCanvas.Card
	_check(time.bead and (time.node.get_node("Icon") as MeshInstance3D).mesh.get_aabb().size.x > time.width * 0.9, "Get Time's dial fills its ring")
	var tag := cards[3] as XREBlueprintCanvas.Card
	_check(tag.tag and (tag.node.get_node("Title") as Label3D).text == "speed" and is_equal_approx(tag.outputs[0].x, tag.width * 0.5), "a Get Variable without boxes is a tag with its name, its output on its end")
	_canvas.set_parameter_modes(XREFeatureSettings.PLUGS, XREFeatureSettings.ADAPTER, modes[2], XREFeatureSettings.BOXES)
	_canvas.rebuild(details)
	var boxes := _canvas.get_boxes()
	var read := boxes.box_end("speed", Vector3.ZERO)
	var write := boxes.box_end("speed", Vector3.ZERO, true)
	# The box turns to the head as the cards do (D-090): its own right and up.
	var speed_box: XREBlueprintBoxes.Box = null
	for item: XREBlueprintBoxes.Box in boxes.get("_boxes") as Array:
		if item.name == "speed": speed_box = item
	var turn := speed_box.node.basis.orthonormalized()
	var local_read := speed_box.node.transform.affine_inverse() * read[0]
	var local_write := speed_box.node.transform.affine_inverse() * write[0]
	_check(read[1].is_equal_approx(turn * Vector3.RIGHT) and write[1].is_equal_approx(turn * Vector3.UP) and local_read.x > 0.0 and local_write.y > 0.0, "a box is read on its right edge and written from its top")
	_canvas.set_composite(XREFeatureSettings.SPLIT)
	_canvas.rebuild(details)
	boxes = _canvas.get_boxes()
	_check(not boxes.component_point("spot", 0).is_equal_approx(boxes.box_point("spot")) and boxes.component_point("aim", 0).is_equal_approx(boxes.box_point("aim")),
			"with Split a box has its drawer, unless its own is shut (D-108)")
	var aim := boxes.box_point("aim")
	var aim_box: XREBlueprintBoxes.Box = null
	for item: XREBlueprintBoxes.Box in boxes.get("_boxes") as Array:
		if item.name == "aim": aim_box = item
	_check(boxes.intersect_ray(aim + aim_box.drawer_point + Vector3(0, 0, 0.3), Vector3.FORWARD, 1.0) >= 0 and boxes.get_hit_part() == XREBlueprintBoxes.DRAWER, "its drawer's switch takes the ray")
	boxes.hover(boxes.get_hit_index(), XREBlueprintBoxes.DRAWER, true)
	_check(aim_box.drawer.scale.x > 1.5, "and grows under it (D-110)")
	boxes.hover(-1, -1, true)
	var spot_index := -1
	for index: int in boxes.box_count():
		if boxes.box_name(index) == "spot": spot_index = index
	var spot_box := (boxes.get("_boxes") as Array)[spot_index] as XREBlueprintBoxes.Box
	boxes.hover(spot_index, XREBlueprintBoxes.COMPONENT, true, 1)
	_check(spot_box.component_ports[1].scale.x > 1.5 and is_equal_approx(spot_box.component_ports[0].scale.x, 1.0), "the output of y under the ray grows, as a card's port (D-109)")
	boxes.hover(-1, -1, true)
	_check(is_equal_approx(spot_box.component_ports[1].scale.x, 1.0), "and shrinks back")
	_check((spot_box.component_ports[0] as MeshInstance3D).mesh.get_aabb().size.x < XREBlueprintBoxes.COMPONENT_RADIUS * 2.0 + 0.0005, "the outputs are as small as they were drawn, not ports' size (D-114)")
	var triangle := XREBlueprintShapes.port_mesh(XREBlueprintGraph.VECTOR3, XREBlueprintCanvas.PORT_RADIUS, XREBlueprintCanvas.PORT_DEPTH * 2.0)
	var shaped := func(box: XREBlueprintBoxes.Box) -> bool: return box.node.find_children("*", "MeshInstance3D", true, false).any(func(item: Node) -> bool: return (item as MeshInstance3D).mesh == triangle)
	_check(not shaped.call(spot_box), "with Port shapes off a Vector3's box has no triangle (D-114)")
	_canvas.set_port_shapes(true)
	_canvas.rebuild(details)
	boxes = _canvas.get_boxes()
	_check(shaped.call((boxes.get("_boxes") as Array)[spot_index] as XREBlueprintBoxes.Box), "with it on it has")
	_canvas.set_port_shapes(false)
	_canvas.set_composite(XREFeatureSettings.WHOLE)
	_canvas.rebuild(details)
	boxes = _canvas.get_boxes()
	var center := boxes.box_point("speed")
	_check(boxes.intersect_ray(center + Vector3(0, 0, 0.3), Vector3.FORWARD, 1.0) >= 0 and boxes.get_hit_part() != XREBlueprintBoxes.TRASH, "out of focus its trash isn't there")
	_canvas.set_focus(Vector3i(-1, -1, -1), "speed")
	var trash := ((boxes.get("_boxes") as Array)[0] as XREBlueprintBoxes.Box).trash
	_check(trash.visible, "under the ray its trash shows over it")
	_canvas.set_focus(Vector3i(-1, -1, -1))
	_canvas.set_shrink(XREFeatureSettings.OPERATORS)
	_canvas.set_style(XREFeatureSettings.CLASSIC)
	_canvas.set_parameter_modes(modes[0], modes[1], modes[2], modes[3])


## Whether every triangle of [param mesh] that faces +Z winds clockwise seen from there (Godot's front faces).
static func _faces_front(mesh: Mesh) -> bool:
	var arrays := mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
	var count := indices.size() if not indices.is_empty() else vertices.size()
	var faced := 0
	for first: int in range(0, count, 3):
		var corners: Array[int] = [first, first + 1, first + 2]
		if not indices.is_empty(): corners.assign([indices[first], indices[first + 1], indices[first + 2]])
		if normals[corners[0]].z < 0.9: continue
		var a := Vector2(vertices[corners[0]].x, vertices[corners[0]].y)
		var b := Vector2(vertices[corners[1]].x, vertices[corners[1]].y)
		var c := Vector2(vertices[corners[2]].x, vertices[corners[2]].y)
		if (b - a).cross(c - a) > 0.0: return false
		faced += 1
	return faced > 0


static func delay_block(graph: XREBlueprintGraph) -> Dictionary:
	return graph.find_node(3)


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
	# Written in format 2: Print is a preset of the global print since D-051.
	graph.upgrade()
	_canvas.set_node_modes(XREFeatureSettings.ON, false, false, XREFeatureSettings.FACE, false)
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
	graph.upgrade()
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
	_check(card.node.global_basis.z.dot(front.normalized()) > 0.99 and absf(card.node.global_basis.x.y) < 0.001, "grabbed panel faces the head, tilted up or down to it, rows level (D-061)")
	contact = Vector3(head.x + 0.03, 0.1, head.z)
	_canvas.preview_grab(1, contact, local_contact, head)
	_check(card.node.to_global(local_contact).is_equal_approx(contact), "minimum horizontal reach cannot detach an off-center grab from the rod")
	_test_cuboid(graph)
	_test_node_variants(graph)
	_test_graph_turn(graph)
	_test_off_centre()
	_test_parts_and_wires()
	_test_flow_and_rim()
	_test_archetypes(graph)
	_test_signs()
	_test_growing_signs()
	_test_headings()
	_test_beads()
	_test_port_shapes()
	_test_mockup_details()
	_canvas.rebuild(graph)
	_test_port_wires()
	_canvas.queue_free()
	await process_frame
	await process_frame
	print("test_blueprint_picking: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)
