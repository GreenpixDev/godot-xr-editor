@tool
class_name XREBlueprintCanvas
extends Node3D
## Spatial cards and typed ports over the same resource used by GraphEdit.
## Cached card/port arrays are picked analytically; wires reuse meshes during dragging.
## Cards are drawn as the feature setting [constant XREFeatureSettings.NODE_DISPLAY]
## says ([method set_display], D-039): flat billboards turned to the head, or
## solid cuboids that keep the graph's orientation.

const PIXEL_SIZE := 0.0009
const CARD_WIDTH := 0.26
const CARD_THICKNESS := 0.001
## Depth of a card drawn as a cuboid: thick enough to read as a solid from the side.
const CUBOID_DEPTH := 0.03
const ROW_HEIGHT := 0.045
const PORT_RADIUS := 0.010
const PORT_DEPTH := 0.001
const PORT_SIZE := Vector3(PORT_RADIUS * 2.0, PORT_RADIUS * 2.0, PORT_DEPTH * 2.0)
const PORT_HIT_MARGIN := 0.006
const PLUS_RADIUS := 0.010
const TOUCH_RADIUS := 0.035
## Lift only the contact dot towards the controller; ray picking stays unchanged.
const HIT_DOT_OFFSET := 0.012
const COLORS: Array[Color] = [Color("eeeeee"), Color("63c6ea"), Color("e8879b"), Color("7be5b3"), Color("7be5b3"), Color("e5b57b"), Color("89adff"), Color("89adff"), Color("b991eb"), Color("f2d878")]
## Dark saturated faces: events, properties/motion, flow, values, audio, animation.
const CARD_PALETTE: Array[Color] = [Color("174479"), Color("155947"), Color("553478"), Color("323e73"), Color("785016"), Color("743351")]
const CARD_GROUPS: Dictionary[String, int] = {
	"ready": 0, "signal": 0,
	"get_property": 1, "set_property": 1, "tween": 1,
	"branch": 2, "delay": 2,
	"value": 3, "boolean": 3, "equals": 3, "get_variable": 3, "set_variable": 3, "print": 3,
	"play_sound": 4, "play_animation": 5,
}

class Card:
	var id: int
	var node: Node3D
	var height: float
	## How far the front face is in front of a billboard's: ports, labels and icons sit on it.
	var face := 0.0
	var bounds: AABB
	var mesh: MeshInstance3D
	var normal: Material
	var frame: MeshInstance3D
	var plus: Node3D
	var plus_point: Vector3
	var plus_faces: Array[Node3D] = []
	var trash: Node3D
	var trash_point: Vector3
	var inputs: Array[Vector3] = []
	var outputs: Array[Vector3] = []
	var input_types: Array[int] = []
	var output_types: Array[int] = []
	var ports: Array[MeshInstance3D] = []

class Wire:
	var from: Card
	var to: Card
	var from_port: int
	var to_port: int
	var mesh: XREGraphWire

var _cards: Array[Card] = []
var _wires: Array[Wire] = []
var _selected_material: Material
var _port_mesh: CylinderMesh
var _trash_mesh: ArrayMesh
var _trash_material: Material
var _preview: XREGraphWire
var _offset := Vector2.ZERO
var _structure: Array = []
var _selected := -1
var _hit_id := -1
var _hit_port := -1
var _hit_input := false
var _hit_plus := false
var _hit_delete := false
var _frame_material: Material
var _hover_right := -1
var _hover_left := -1
var _delete_right := -1
var _delete_left := -1
var _body_materials: Array[ShaderMaterial] = []
var _faces_user := false
var _display := XREFeatureSettings.BILLBOARD
var _head_position := Vector3.ZERO
var _view_transform := Transform3D.IDENTITY
static var _wire_shader: Shader


func _init() -> void:
	_selected_material = material(Color.WHITE, true)
	_frame_material = material(Color("65839b"), true)
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, depth_draw_always, shadows_disabled;
uniform vec4 face_tint : source_color = vec4(0.09, 0.27, 0.47, 1.0);
varying float front;
// Only the front (+Z) face has the full tint: a cuboid's sides and back read as its depth.
void vertex() { front = step(0.5, NORMAL.z); }
void fragment() { ALBEDO = face_tint.rgb * mix(0.55, 1.0, front); ALPHA = 1.0; }
"""
	for tint: Color in CARD_PALETTE:
		var body := ShaderMaterial.new()
		body.shader = shader
		body.render_priority = Material.RENDER_PRIORITY_MAX - 1
		body.set_shader_parameter(&"face_tint", tint)
		_body_materials.append(body)
	_port_mesh = CylinderMesh.new()
	_port_mesh.top_radius = PORT_RADIUS
	_port_mesh.bottom_radius = PORT_RADIUS
	_port_mesh.height = PORT_DEPTH * 2.0
	_port_mesh.radial_segments = 24
	_trash_mesh = _make_trash_mesh()
	_trash_material = material(Color("ffabb4"), true)
	_preview = create_scene_wire(Color("ffda82"))
	_preview.visible = false


## Switches how cards are drawn to [param display], a value of
## [constant XREFeatureSettings.NODE_DISPLAY]. Takes effect on the next
## [method rebuild]; false if it is unknown or already the current one.
func set_display(display: StringName) -> bool:
	if display == _display or not display in XREFeatureSettings.get_values(XREFeatureSettings.NODE_DISPLAY): return false
	_display = display
	return true


## How cards are drawn: a value of [constant XREFeatureSettings.NODE_DISPLAY].
func get_display() -> StringName:
	return _display


## Initializes the view's center once on open, keeping it fixed during edits.
func center_graph(graph: XREBlueprintGraph) -> void:
	_offset = Vector2.ZERO
	if graph.vr_placed:
		_offset = graph.vr_center
		return
	if graph.nodes.is_empty(): return
	var low: Vector2 = graph.nodes[0]["position"]
	var high := low
	for block: Dictionary in graph.nodes:
		var point: Vector2 = block["position"]
		low = low.min(point)
		high = high.max(point)
	_offset = (low + high) * 0.5


## XY origin to persist together with the workspace pose, avoiding reopen recentering.
func get_graph_center() -> Vector2:
	return _offset


## Rebuilds only after document changes; never called by the frame loop.
func rebuild(graph: XREBlueprintGraph) -> void:
	_structure = graph.structure_key()
	for card: Card in _cards:
		remove_child(card.node)
		card.node.queue_free()
	for wire: Wire in _wires:
		remove_child(wire.mesh)
		wire.mesh.queue_free()
	_cards.clear()
	_wires.clear()
	_hover_right = -1
	_hover_left = -1
	_delete_right = -1
	_delete_left = -1
	for block: Dictionary in graph.nodes:
		var card := Card.new()
		card.id = block["id"]
		card.node = Node3D.new()
		card.node.name = "Block%d" % card.id
		card.node.position = position_from_block(block)
		add_child(card.node)
		_orient(card)
		var inputs := graph.ports(block, true)
		var outputs := graph.ports(block, false)
		card.height = 0.08 + maxi(inputs.size(), outputs.size()) * ROW_HEIGHT
		var cuboid := _display == XREFeatureSettings.CUBOID
		var body_size := Vector3(CARD_WIDTH, card.height, CUBOID_DEPTH if cuboid else CARD_THICKNESS)
		card.face = (CUBOID_DEPTH - CARD_THICKNESS) * 0.5 if cuboid else 0.0
		card.bounds = AABB(-body_size * 0.5, body_size)
		card.normal = _body_materials[CARD_GROUPS.get(block["kind"], 3)]
		var body: PrimitiveMesh
		if cuboid:
			var box := BoxMesh.new()
			box.size = body_size
			body = box
		else:
			var panel := QuadMesh.new()
			panel.size = Vector2(CARD_WIDTH, card.height)
			body = panel
		card.mesh = XRERig.create_vr_mesh(body, card.normal)
		card.node.add_child(card.mesh)
		_add_frame(card, body_size, cuboid)
		var title := label("%s · %d" % [XREBlueprintGraph.BLOCKS[block["kind"]]["title"], card.id], 21)
		title.position = Vector3(0, card.height * 0.5 - 0.022, card.face + CARD_THICKNESS * 0.5 + 0.0005)
		card.node.add_child(title)
		card.plus_point = Vector3(CARD_WIDTH * 0.5 - 0.023, card.height * 0.5 - 0.022, card.face + CARD_THICKNESS * 0.5 + 0.002)
		card.plus = Node3D.new()
		card.node.add_child(card.plus)
		for point: Vector3 in [card.plus_point]:
			var face := Node3D.new()
			face.position = point
			card.plus.add_child(face)
			card.plus_faces.append(face)
			for size: Vector3 in [Vector3(0.018, 0.004, 0.002), Vector3(0.004, 0.018, 0.002)]:
				var bar := BoxMesh.new()
				bar.size = size
				var visual := XRERig.create_vr_mesh(bar, material(Color.WHITE, true))
				face.add_child(visual)
		card.trash_point = Vector3(-card.plus_point.x, card.plus_point.y, card.plus_point.z)
		card.trash = Node3D.new()
		card.trash.position = card.trash_point
		card.node.add_child(card.trash)
		card.trash.add_child(XRERig.create_vr_mesh(_trash_mesh, _trash_material))
		for index: int in inputs.size():
			_add_port(card, inputs[index], index, true)
		for index: int in outputs.size():
			_add_port(card, outputs[index], index, false)
		_cards.append(card)
	for edge: Dictionary in graph.edges:
		var wire := Wire.new()
		wire.from = _find_card(edge["from"])
		wire.to = _find_card(edge["to"])
		wire.from_port = edge["from_port"]
		wire.to_port = edge["to_port"]
		if wire.from == null or wire.to == null: continue
		wire.mesh = create_scene_wire(COLORS[wire.from.output_types[wire.from_port]])
		_wires.append(wire)
	update_wires()
	select_block(_selected)


## Desktop XY and editor-only depth describe the same card; compilation ignores depth.
func position_from_block(block: Dictionary) -> Vector3:
	var point: Vector2 = block["position"] - _offset
	return Vector3(point.x * PIXEL_SIZE, -point.y * PIXEL_SIZE, float(block.get("vr_depth", 0.0)))


## Moves the existing cards to the graph's placement when only placement changed.
## False means the blocks differ and [method rebuild] is needed.
func sync_placement(graph: XREBlueprintGraph) -> bool:
	if graph.nodes.size() != _cards.size() or graph.structure_key() != _structure: return false
	for index: int in _cards.size():
		var card := _cards[index]
		var block: Dictionary = graph.nodes[index]
		if card.id != block["id"]: return false
		card.node.position = position_from_block(block)
		_orient(card)
	update_wires()
	return true


## Commits one spatial move to the shared graph history after previewing its geometry.
func commit_move(document: XREBlueprintDocument, id: int) -> bool:
	var card := _find_card(id)
	if card == null: return false
	var state := document.graph.snapshot()
	for block: Dictionary in state["nodes"]:
		if block["id"] == id:
			block["position"] = Vector2(card.node.position.x, -card.node.position.y) / PIXEL_SIZE + _offset
			block["vr_depth"] = card.node.position.z
			block.erase("vr_rotation")
	return document.perform(document.commit.bind("Move Blocks", state), &"vr_graph")


## Live geometry only; a preview never modifies the resource or undo history.
func preview_move(id: int, point: Vector3) -> void:
	var card := _find_card(id)
	if card == null: return
	card.node.position = point
	_orient(card)
	update_wires()


## Previews position and orientation without touching the graph resource.
func preview_transform(id: int, pose: Transform3D) -> void:
	var card := _find_card(id)
	if card == null: return
	card.node.transform = pose
	_orient(card)
	update_wires()


## Turns flat cards towards the head without moving their centers or editing the graph.
## Cuboids stay as they are; the head is kept for a switch back to billboards.
func face_user(head: Vector3) -> void:
	if _faces_user and head.is_equal_approx(_head_position) and global_transform.is_equal_approx(_view_transform): return
	_faces_user = true
	_head_position = head
	_view_transform = global_transform
	if _display == XREFeatureSettings.CUBOID: return
	for card: Card in _cards:
		_orient(card)
	update_wires()


## Billboards face the last head position around the vertical; cuboids keep the graph's orientation.
func _orient(card: Card) -> void:
	if _display == XREFeatureSettings.CUBOID: card.node.basis = Basis.IDENTITY
	elif _faces_user: card.node.global_basis = XREPanels.facing(card.node.global_position, _head_position, Vector3.UP)


## Keeps a captured point on the rod while its upright panel faces the user.
func preview_grab(id: int, contact: Vector3, local_contact: Vector3, head: Vector3) -> void:
	if _display == XREFeatureSettings.CUBOID:
		# A solid keeps the graph's orientation: only the captured point follows the rod.
		var held := _find_card(id)
		if held == null: return
		held.node.global_transform = Transform3D(global_basis, contact - global_basis * local_contact)
		update_wires()
		return
	var orientation := XREPanels.facing(contact, head, Vector3.UP)
	var span := head - contact
	span.y = 0.0
	# Solve yaw around the captured point, rather than rotating around the center
	# afterwards and moving that point away from the controller's straight ray.
	if span.length() > absf(local_contact.x) + 0.001:
		orientation *= Basis(Vector3.UP, asin(local_contact.x / span.length()))
	var pose := Transform3D(orientation, contact - orientation * local_contact)
	var card := _find_card(id)
	if card == null: return
	card.node.global_transform = pose
	update_wires()


## Current card pose in workspace coordinates, including a grip preview.
func get_block_transform(id: int) -> Transform3D:
	var card := _find_card(id)
	return card.node.transform if card != null else Transform3D.IDENTITY


## Current preview position of a card in workspace coordinates.
func get_block_position(id: int) -> Vector3:
	var card := _find_card(id)
	return card.node.position if card != null else Vector3.ZERO


## Highlights a card without changing the scene selection.
func select_block(id: int) -> void:
	_selected = id
	for card: Card in _cards:
		card.frame.material_override = _selected_material if card.id == id else _frame_material


## Each hand contributes hover independently, so one idle ray cannot clear the other.
func hover_plus(id: int, right: bool) -> void:
	if (right and _hover_right == id) or (not right and _hover_left == id): return
	if right: _hover_right = id
	else: _hover_left = id
	for card: Card in _cards:
		for face: Node3D in card.plus_faces:
			face.scale = Vector3.ONE * (1.6 if card.id == _hover_right or card.id == _hover_left else 1.0)


## Highlights only type-compatible endpoints while a connection is being made.
func highlight_ports(type: int, want_input: bool) -> void:
	for card: Card in _cards:
		for index: int in card.ports.size():
			var input := index < card.inputs.size()
			var port_index := index if input else index - card.inputs.size()
			var port_type := card.input_types[port_index] if input else card.output_types[port_index]
			var compatible := type < 0 or (input == want_input and (XREBlueprintGraph.ports_compatible(type, port_type) if want_input else XREBlueprintGraph.ports_compatible(port_type, type)))
			card.ports[index].scale = Vector3.ONE * (1.3 if type >= 0 and compatible else 1.0)
	update_wires()


## Both hands contribute action hover independently, using cached card visuals.
func hover_actions(id: int, plus: bool, trash: bool, right: bool) -> void:
	hover_plus(id if plus else -1, right)
	var hovered := id if trash else -1
	if (right and _delete_right == hovered) or (not right and _delete_left == hovered): return
	if right: _delete_right = hovered
	else: _delete_left = hovered
	for card: Card in _cards:
		card.trash.scale = Vector3.ONE * (1.6 if card.id == _delete_right or card.id == _delete_left else 1.0)


static func _make_trash_mesh() -> ArrayMesh:
	# One shared mesh/material, one draw per icon instead of seven separate bars.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	_append_trash_bar(surface, Vector3(0.016, 0.002, 0.002), Vector3(0, 0.006, 0))
	_append_trash_bar(surface, Vector3(0.006, 0.002, 0.002), Vector3(0, 0.009, 0))
	_append_trash_bar(surface, Vector3(0.014, 0.002, 0.002), Vector3(0, -0.01, 0))
	for side: float in [-1.0, 1.0]:
		_append_trash_bar(surface, Vector3(0.002, 0.014, 0.002), Vector3(side * 0.006, -0.003, 0))
		_append_trash_bar(surface, Vector3(0.0015, 0.009, 0.002), Vector3(side * 0.002, -0.003, 0))
	return surface.commit()


static func _append_trash_bar(surface: SurfaceTool, dimensions: Vector3, point: Vector3) -> void:
	var shape := BoxMesh.new()
	shape.size = dimensions
	surface.append_from(shape, 0, Transform3D(Basis.IDENTITY, point))


## Nearest oriented body, action icon or surface port; distance is in world meters.
## Both port faces retain an enlarged click area around their contact pad.
func intersect_ray(origin: Vector3, direction: Vector3, maximum: float) -> float:
	_hit_id = -1
	_hit_port = -1
	_hit_input = false
	_hit_plus = false
	_hit_delete = false
	if not is_visible_in_tree(): return -1.0
	var inverse := global_transform.affine_inverse()
	var local_origin := inverse * origin
	var local_direction := inverse.basis * direction
	var nearest := maximum
	var proximity := INF
	for card: Card in _cards:
		var card_inverse := card.node.transform.affine_inverse()
		var card_origin := card_inverse * local_origin
		var card_direction := card_inverse.basis * local_direction
		var body := _box_distance(card_origin, card_direction, card.bounds, nearest)
		if body >= 0:
			nearest = body
			proximity = INF
			_hit_id = card.id
			_hit_port = -1
			_hit_input = false
			_hit_plus = false
			_hit_delete = false
		for face: Node3D in card.plus_faces:
			var plus_point := card.plus_point
			var plus_size := Vector3.ONE * PLUS_RADIUS * face.scale.x * 2.0
			var plus_hit := _box_distance(card_origin, card_direction, AABB(plus_point - plus_size * 0.5, plus_size), nearest)
			if plus_hit >= 0:
				nearest = plus_hit
				_hit_id = card.id
				_hit_port = -1
				_hit_plus = true
				_hit_delete = false
		var trash_size := Vector3.ONE * PLUS_RADIUS * card.trash.scale.x * 2.0
		var trash_hit := _box_distance(card_origin, card_direction, AABB(card.trash_point - trash_size * 0.5, trash_size), nearest)
		if trash_hit >= 0:
			nearest = trash_hit
			_hit_id = card.id
			_hit_port = -1
			_hit_plus = false
			_hit_delete = true
		for index: int in card.inputs.size():
			var center := card.inputs[index]
			var hit := _port_distance(card_origin, card_direction, center, card.ports[index].scale, nearest)
			if hit < 0: continue
			var score := (card_origin + card_direction * hit - center).length_squared()
			if hit < nearest or score < proximity:
				nearest = hit
				proximity = score
				_hit_id = card.id
				_hit_port = index
				_hit_input = true
				_hit_plus = false
				_hit_delete = false
		for index: int in card.outputs.size():
			var center := card.outputs[index]
			var hit := _port_distance(card_origin, card_direction, center, card.ports[card.inputs.size() + index].scale, nearest)
			if hit < 0: continue
			var score := (card_origin + card_direction * hit - center).length_squared()
			if hit < nearest or score < proximity:
				nearest = hit
				proximity = score
				_hit_id = card.id
				_hit_port = index
				_hit_input = false
				_hit_plus = false
				_hit_delete = false
	return nearest if _hit_id >= 0 else -1.0


static func _box_distance(origin: Vector3, direction: Vector3, bounds: AABB, maximum: float) -> float:
	var near := 0.0
	var far := maximum
	var end := bounds.end
	for axis: int in 3:
		if absf(direction[axis]) < 0.000001:
			if origin[axis] < bounds.position[axis] or origin[axis] > end[axis]: return -1.0
			continue
		var first := (bounds.position[axis] - origin[axis]) / direction[axis]
		var second := (end[axis] - origin[axis]) / direction[axis]
		near = maxf(near, minf(first, second))
		far = minf(far, maxf(first, second))
		if near > far: return -1.0
	return near


static func _port_distance(origin: Vector3, direction: Vector3, center: Vector3, scale: Vector3, maximum: float) -> float:
	if absf(direction.z) < 0.000001: return -1.0
	var z := PORT_DEPTH * scale.z * (1 if direction.z < 0 else -1)
	var distance := (center.z + z - origin.z) / direction.z
	if distance < 0 or distance > maximum: return -1.0
	var point := origin + direction * distance - center
	return distance if Vector2(point.x / scale.x, point.y / scale.y).length() <= PORT_RADIUS + PORT_HIT_MARGIN else -1.0


## Grip near a card uses its oriented body, independently of its front-facing ray.
func intersect_touch(point: Vector3) -> int:
	if not is_visible_in_tree(): return -1
	var nearest := INF
	var id := -1
	for card: Card in _cards:
		var local := card.node.to_local(point)
		var closest := local.clamp(card.bounds.position, card.bounds.end)
		var distance := card.node.to_global(closest).distance_squared_to(point)
		if distance <= TOUCH_RADIUS * TOUCH_RADIUS and distance < nearest:
			nearest = distance
			id = card.id
	return id


## Block ID from the last successful ray intersection.
func get_hit_id() -> int:
	return _hit_id


## Port index from the last intersection, or -1 for the card body.
func get_hit_port() -> int:
	return _hit_port


## Whether the last intersected port was an input.
func get_hit_input() -> bool:
	return _hit_input


## Whether the last ray hit the card's add-block button.
func get_hit_plus() -> bool:
	return _hit_plus


## Whether the last ray hit the card's delete action.
func get_hit_delete() -> bool:
	return _hit_delete


## Cached endpoint position in workspace coordinates.
func port_position(id: int, port: int, input: bool) -> Vector3:
	var card := _find_card(id)
	if card == null: return Vector3.ZERO
	return _port_position(card, port, input)


static func _port_position(card: Card, port: int, input: bool) -> Vector3:
	var visual := card.ports[port if input else card.inputs.size() + port]
	return card.node.transform * ((card.inputs[port] if input else card.outputs[port]) + Vector3.BACK * PORT_DEPTH * visual.scale.z)


## Wires leave outputs rightwards and enter inputs from the left, as in GraphEdit. The graph's
## horizontal, not the card's: a card turned towards the head would tip its wires behind others.
func port_direction(id: int, input: bool) -> Vector3:
	var card := _find_card(id)
	return _port_direction(card, input) if card != null else Vector3.ZERO


static func _port_direction(_card: Card, input: bool) -> Vector3:
	return Vector3.LEFT if input else Vector3.RIGHT


## The side of the card its ports face; back edges loop out this way.
static func _front(card: Card) -> Vector3:
	return card.node.basis.z.normalized() if card != null else Vector3.ZERO


## Reflected type of an existing endpoint.
func port_type(id: int, port: int, input: bool) -> int:
	var card := _find_card(id)
	if card == null: return -1
	return card.input_types[port] if input else card.output_types[port]


## Whether a cached endpoint still exists after reflection or undo.
func has_port(id: int, port: int, input: bool) -> bool:
	var card := _find_card(id)
	return card != null and port >= 0 and port < (card.inputs.size() if input else card.outputs.size())


## A connection preview uses the same pooled geometry as permanent wires.
func show_connection(id: int, port: int, input: bool, end: Vector3, end_id: int = -1, end_port: int = -1, end_input: bool = false) -> void:
	# Over a port the preview snaps to it; elsewhere its end follows the ray freely.
	var direction := Vector3.ZERO
	if end_id >= 0 and end_port >= 0:
		end = port_position(end_id, end_port, end_input)
		direction = port_direction(end_id, end_input)
	_preview.update_curve(port_position(id, port, input), port_direction(id, input), end, direction, _front(_find_card(id)))
	_preview.visible = true


## Clears preview geometry and compatibility emphasis.
func hide_connection() -> void:
	_preview.visible = false
	highlight_ports(-1, false)


## Updates existing mesh transforms after a card preview; creates no geometry.
func update_wires() -> void:
	for wire: Wire in _wires:
		wire.mesh.update_curve(_port_position(wire.from, wire.from_port, false), _port_direction(wire.from, false), _port_position(wire.to, wire.to_port, true), _port_direction(wire.to, true), (_front(wire.from) + _front(wire.to)).normalized())


## Creates one reusable native tube; permanent, preview and scene wires share it.
func create_scene_wire(color: Color) -> XREGraphWire:
	var wire := XREGraphWire.new()
	wire.layers = XRERig.VR_LAYER
	wire.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	wire.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	wire.material_override = wire_material(color)
	add_child(wire)
	return wire


## A static Target wire: from its input port, leaving left, free towards the scene object.
func update_scene_wire(wire: XREGraphWire, id: int, port: int, end: Vector3) -> void:
	wire.update_curve(port_position(id, port, true), port_direction(id, true), end, Vector3.ZERO, _front(_find_card(id)))


func _add_port(card: Card, spec: Array, index: int, input: bool) -> void:
	var point := Vector3((-CARD_WIDTH * 0.5 + 0.014) if input else (CARD_WIDTH * 0.5 - 0.014), card.height * 0.5 - 0.064 - index * ROW_HEIGHT, card.face + 0.003)
	var mesh := XRERig.create_vr_mesh(_port_mesh, material(COLORS[spec[1]], true))
	mesh.position = point
	mesh.rotation.x = PI * 0.5
	card.node.add_child(mesh)
	card.ports.append(mesh)
	if input:
		card.inputs.append(point)
		card.input_types.append(spec[1])
	else:
		card.outputs.append(point)
		card.output_types.append(spec[1])
	var text := label(spec[0], 18)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if input else HORIZONTAL_ALIGNMENT_RIGHT
	text.position = point + Vector3(0.022 if input else -0.022, 0, 0)
	card.node.add_child(text)


func _add_frame(card: Card, size: Vector3, cuboid: bool) -> void:
	# Four coplanar border strips, or a cuboid's twelve edges, share one draw call, built only on document changes.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	if cuboid:
		for axis: int in 3:
			for first: float in [-1.0, 1.0]:
				for second: float in [-1.0, 1.0]:
					var edge := BoxMesh.new()
					var dimensions := Vector3.ONE * 0.0015
					dimensions[axis] = size[axis] + 0.0015
					edge.size = dimensions
					var corner := Vector3.ZERO
					corner[(axis + 1) % 3] = size[(axis + 1) % 3] * first * 0.5
					corner[(axis + 2) % 3] = size[(axis + 2) % 3] * second * 0.5
					surface.append_from(edge, 0, Transform3D(Basis.IDENTITY, corner))
		card.frame = XRERig.create_vr_mesh(surface.commit(), _frame_material)
		card.node.add_child(card.frame)
		return
	for axis: int in 2:
		for side: float in [-1.0, 1.0]:
			var shape := BoxMesh.new()
			var dimensions := Vector3.ONE * 0.001
			dimensions[axis] = size[axis]
			shape.size = dimensions
			var point := Vector3(0, 0, 0.001)
			point[1 - axis] = size[1 - axis] * side * 0.5
			surface.append_from(shape, 0, Transform3D(Basis.IDENTITY, point))
	card.frame = XRERig.create_vr_mesh(surface.commit(), _frame_material)
	card.node.add_child(card.frame)


func _find_card(id: int) -> Card:
	for card: Card in _cards:
		if card.id == id: return card
	return null


## Shared unlit materials keep graph geometry readable independently of scene lighting.
static func material(color: Color, overlay: bool = false) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	result.albedo_color = color
	if overlay:
		result.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		result.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
		result.render_priority = Material.RENDER_PRIORITY_MAX
	return result


## Unlit like the cards, but shaded by the view angle so the tube reads as round. ALPHA keeps
## it in the transparent pass above the scene dimmer, with the overlays' render priority.
static func wire_material(color: Color) -> ShaderMaterial:
	if _wire_shader == null:
		_wire_shader = Shader.new()
		_wire_shader.code = """
shader_type spatial;
render_mode unshaded, depth_draw_always, shadows_disabled, fog_disabled;
uniform vec4 tint : source_color = vec4(1.0);
void fragment() {
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	ALBEDO = tint.rgb * mix(0.45, 1.0, sqrt(facing));
	ALPHA = 1.0;
}
"""
	var result := ShaderMaterial.new()
	result.shader = _wire_shader
	result.render_priority = Material.RENDER_PRIORITY_MAX
	result.set_shader_parameter(&"tint", color)
	return result


## Fixed-orientation text on the VR layer, independent of scene lighting.
static func label(text: String, font_size: int) -> Label3D:
	var result := XRERig.create_vr_label(font_size, 0.0007)
	result.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	result.render_priority = Material.RENDER_PRIORITY_MAX
	result.text = text
	return result
