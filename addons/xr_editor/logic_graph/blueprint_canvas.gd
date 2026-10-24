@tool
class_name XREBlueprintCanvas
extends Node3D
## Spatial cards and typed ports over the same resource used by GraphEdit.
## Cached card/port arrays are picked analytically; wires reuse meshes during dragging.
## Cards are drawn as the feature setting [constant XREFeatureSettings.NODE_DISPLAY]
## says ([method set_display], D-039): flat billboards turned to the head, or
## solid cuboids that keep the graph's orientation. Ports are drawn as
## [constant XREFeatureSettings.PORT_DISPLAY] says ([method set_port_display],
## D-043): flat discs, or shaded spheres standing out of the face. A port under
## a ray grows, as the plus and the trash do, and one wire on it thickens: the
## one a click on the port would detach (D-044, D-045). With several wires on a port,
## the height the ray meets the port at picks one: the higher the hit, the
## higher the wire's other end.
##
## Parameters show on the cards as the parameter settings say
## ([method set_parameter_modes], D-052): literals as tokens — pucks in slots,
## or plugs in the ports — in the rows of their ports or in square sockets for
## settings without a port; the target's member after the Target ("Target ·
## visible") and an event's Source; Play Animation's Finished output for its
## wait; a Variable socket wired to its box on the shelf ([XREBlueprintShelf]).
##
## An operator (D-065: Equal and the Operator blocks) is a small card as in
## Unreal: no title, its inputs and their tokens on the left, its symbol in the
## middle, its result on the right; its trash and plus stand above it.
##
## The cards and boxes a ray is on are in focus (D-072, [method set_focus]):
## lit with their ports, details and wires as [constant XREFeatureSettings.FOCUS]
## says, or come toward the user with them (D-073), the rest darker or
## see-through as [constant XREFeatureSettings.DEFOCUS] says.

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
## How far a sphere port's center stands out of the card's face, in its radii.
const SPHERE_LIFT := 0.35
## How much a port, the plus or the trash grows under a ray, and a port that a wire may end on.
const HOVER_SCALE := 1.6
const COMPATIBLE_SCALE := 1.3
## How much thicker the wire a click would detach is drawn, in meters added
## to its radius: twice the tube's 2.2 mm (D-045).
const LIT_WIRE_GROW := 0.0022
const PLUS_RADIUS := 0.010
const TOUCH_RADIUS := 0.035
## Lift only the contact dot towards the controller; ray picking stays unchanged.
const HIT_DOT_OFFSET := 0.012
## How far a card or a box in focus comes toward the user out of its place
## with Focus on Front (D-073), along its front: past a cuboid's depth and the
## tokens standing out of a face.
const FRONT_LIFT := 0.06
const COLORS: Array[Color] = [Color("eeeeee"), Color("63c6ea"), Color("e8879b"), Color("7be5b3"), Color("7be5b3"), Color("e5b57b"), Color("89adff"), Color("89adff"), Color("b991eb"), Color("f2d878")]
## Dark saturated faces: events, properties/motion, flow, values, audio, animation.
const CARD_PALETTE: Array[Color] = [Color("174479"), Color("155947"), Color("553478"), Color("323e73"), Color("785016"), Color("743351")]
## Faces of the native blocks; a call's face follows its function ([method card_group]).
const CARD_GROUPS: Dictionary[String, int] = {
	"signal": 0,
	"get_property": 1, "set_property": 1,
	"branch": 2,
	"value": 3, "equals": 3, "operator": 3, "get_variable": 3, "set_variable": 3,
}
## Faces of the library's categories.
const CATEGORY_GROUPS: Dictionary[String, int] = {"Motion": 1, "Flow": 2, "Audio": 4, "Animation": 5}
## Kinds of a card's sockets besides its ports (D-052): a token on an input
## port's row, a square socket for a setting without a port, Play Animation's
## Finished output, an event's Source, a Variable, and the member name after
## Target or Source.
const TOKEN := 0
const SQUARE := 1
const FINISHED := 2
const SOURCE := 3
const VARIABLE := 4
const MEMBER := 5
## A puck's depth on the card, a plug's, how far left of the port a plug's
## body is, and how faint a token is under a wire.
const PUCK_DEPTH := 0.008
const PLUG_DEPTH := 0.012
const PLUG_GAP := 0.022
const FADED := 0.35
## How much a token or a member grows under a ray.
const SOCKET_HOVER := 1.15
const MEMBER_COLOR := Color("dcc8fa")
## An operator's card: how much taller than its rows, its symbol's font sizes
## (a sign, a word such as AND) and the room on each side of the symbol.
const OPERATOR_PAD := 0.03
const SYMBOL_SIZE := 44
const WORD_SIZE := 26
const SYMBOL_ROOM := 0.034
const TOKEN_FACE := Color("151a26")
## How much nearer a token's text and swatch sort than its face, in meters.
const TOKEN_SORTING := 0.01
## Pixel size of the cards' labels, for measuring their text.
const LABEL_PIXEL := 0.0007

## A socket of a card that is not one of its block's ports (D-052).
class Socket:
	var kind := TOKEN
	## The parameter the socket shows or sets.
	var key := ""
	## Its port type, for colors; a token's value's.
	var type := 0
	## The input port a token belongs to; -1 for a square, 0 for Finished.
	var port := -1
	var center := Vector3.ZERO
	var size := Vector3.ZERO
	var visual: Node3D
	var text: Label3D
	## A wire comes into the token's port: the token is faint, or not plugged in.
	var wired := false
	var value: Variant
	## The visual's scale when not under a ray.
	var base_scale := Vector3.ONE

class Card:
	var id: int
	var node: Node3D
	var height: float
	var width := CARD_WIDTH
	## An operator's small card (D-065).
	var compact := false
	## The height of the first row's ports; a compact card's output is in its middle.
	var first_row := 0.0
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
	var sockets: Array[Socket] = []
	## The wire of output 0 leaves the Finished socket: its block waits (D-052).
	var waits := false
	var finished := -1
	## It covers an input in use and is see-through (D-066).
	var faded := false
	## Its focus (D-072): a state of [XREBlueprintFocus], the ports (bits of
	## [member ports]) and sockets kept as they are out of focus, and how it is
	## painted now: paint, see-through, those ports and sockets.
	var focus := XREBlueprintFocus.NORMAL
	var keep_ports := 0
	var keep_sockets := 0
	var look := Vector4i(-1, 0, 0, 0)
	## How far it stands out of its place toward the user (D-073), and the
	## offset that adds to its node's position now: the graph keeps the place.
	var lift := 0.0
	var raised := Vector3.ZERO

class Wire:
	var from: Card
	var to: Card
	var from_port: int
	var to_port: int
	## Index of the wire's edge in the graph's edges.
	var edge: int
	## A wire straight from a variable's box (D-061): [member from] is null and
	## this names the variable of the inline Get Variable it stands for.
	var variable := ""
	var mesh: XREGraphWire
	var normal: Material
	var lit: Material
	var faded := false
	## Its focus (D-072) and how it is painted now: paint and see-through, -1 not yet.
	var focus := XREBlueprintFocus.NORMAL
	var look := -1

var _cards: Array[Card] = []
var _wires: Array[Wire] = []
var _selected_material: Material
var _port_mesh: CylinderMesh
var _sphere_mesh: SphereMesh
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
## Where the last ray met the port it hit, -1 at its bottom to 1 at its top, and the edge that picks.
var _hit_height := 0.0
var _hit_edge := -1
## Edges lit under each hand's ray, or -1.
var _edge_right := -1
var _edge_left := -1
var _frame_material: Material
var _hover_right := -1
var _hover_left := -1
var _delete_right := -1
var _delete_left := -1
var _body_materials: Array[ShaderMaterial] = []
var _faces_user := false
var _display := XREFeatureSettings.BILLBOARD
var _port_display := XREFeatureSettings.FLAT
var _plus_shown := true
var _value_mode := XREFeatureSettings.WINDOW
var _target_mode := XREFeatureSettings.WINDOW
var _wait_mode := XREFeatureSettings.FLAG
var _variable_mode := XREFeatureSettings.WINDOW
## The socket the last ray hit: its index in the card's sockets, or -1.
var _hit_socket := -1
var _hit_finished := false
## The box of the shelf the last ray hit, empty for none.
var _hit_box := false
## Sockets under each hand's ray: the card and the socket index, or -1.
var _socket_right := Vector2i(-1, -1)
var _socket_left := Vector2i(-1, -1)
var _shelf: XREBlueprintShelf
## Wires from Variable sockets to their boxes.
var _variable_wires: Array[Dictionary] = []
static var _token_materials: Dictionary[Color, Material] = {}
## Ports under each hand's ray: the card and the index in [member Card.ports], or -1.
var _port_right := Vector2i(-1, -1)
var _port_left := Vector2i(-1, -1)
## Port type a wire being drawn may connect to, or -1, and whether it ends on inputs.
var _compatible_type := -1
var _compatible_input := false
var _head_position := Vector3.ZERO
var _view_transform := Transform3D.IDENTITY
static var _wire_shader: Shader
## Focus on what a ray is on (D-072): the settings [constant XREFeatureSettings.FOCUS]
## and [constant XREFeatureSettings.DEFOCUS], the cards in focus (-1 for none),
## the boxes of variables in focus (empty for none), whether anything is, and
## the frame of a card in focus.
var _focus_mode := XREFeatureSettings.OFF
var _defocus_mode := XREFeatureSettings.OFF
var _focus_cards := Vector3i(-1, -1, -1)
var _focus_box := ""
var _focus_other_box := ""
var _focus_any := false
var _focus_frame: Material


func _init() -> void:
	_selected_material = material(Color.WHITE, true)
	_frame_material = material(Color("65839b"), true)
	_focus_frame = material(XREBlueprintFocus.FRAME, true)
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
	_sphere_mesh = SphereMesh.new()
	_sphere_mesh.radius = PORT_RADIUS
	_sphere_mesh.height = PORT_RADIUS * 2.0
	_sphere_mesh.radial_segments = 24
	_sphere_mesh.rings = 12
	_trash_mesh = _make_trash_mesh()
	_trash_material = material(Color("ffabb4"), true)
	_preview = create_scene_wire(Color("ffda82"))
	_preview.visible = false
	_shelf = XREBlueprintShelf.new(_trash_mesh, _trash_material)
	add_child(_shelf)


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


## Switches how ports are drawn to [param display], a value of
## [constant XREFeatureSettings.PORT_DISPLAY]. Takes effect on the next
## [method rebuild]; false if it is unknown or already the current one.
func set_port_display(display: StringName) -> bool:
	if display == _port_display or not display in XREFeatureSettings.get_values(XREFeatureSettings.PORT_DISPLAY): return false
	_port_display = display
	return true


## Whether cards have their plus ([constant XREFeatureSettings.CARD_PLUS], D-058);
## true if that changed, for a rebuild.
func set_plus_shown(shown: bool) -> bool:
	if shown == _plus_shown: return false
	_plus_shown = shown
	return true


## How ports are drawn: a value of [constant XREFeatureSettings.PORT_DISPLAY].
func get_port_display() -> StringName:
	return _port_display


## Switches how parameters show on the cards (D-052): the values of
## [constant XREFeatureSettings.VALUE_INPUT], [constant XREFeatureSettings.TARGET_INPUT],
## [constant XREFeatureSettings.ANIMATION_WAIT] and
## [constant XREFeatureSettings.VARIABLE_INPUT]. Takes effect on the next
## [method rebuild]; false if nothing changed.
func set_parameter_modes(values: StringName, targets: StringName, wait: StringName, variables: StringName) -> bool:
	if [values, targets, wait, variables] == [_value_mode, _target_mode, _wait_mode, _variable_mode]: return false
	_value_mode = values
	_target_mode = targets
	_wait_mode = wait
	_variable_mode = variables
	return true


## The current parameter settings, as [method set_parameter_modes] takes them.
func get_parameter_modes() -> Array[StringName]:
	return [_value_mode, _target_mode, _wait_mode, _variable_mode]


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
	_port_right = Vector2i(-1, -1)
	_port_left = Vector2i(-1, -1)
	_socket_right = Vector2i(-1, -1)
	_socket_left = Vector2i(-1, -1)
	_edge_right = -1
	_edge_left = -1
	for wire: Dictionary in _variable_wires:
		remove_child(wire["mesh"])
		(wire["mesh"] as Node).queue_free()
	_variable_wires.clear()
	for block: Dictionary in graph.nodes:
		# An inline Get Variable is no card: its wire comes from the variable's box (D-061).
		if is_inline(block): continue
		var card := Card.new()
		card.id = block["id"]
		card.node = Node3D.new()
		card.node.name = "Block%d" % card.id
		card.node.position = position_from_block(block)
		add_child(card.node)
		_orient(card)
		var inputs := graph.ports(block, true)
		var outputs := graph.ports(block, false)
		var layout := _layout(graph, block, inputs, outputs)
		card.compact = XREBlueprintGraph.is_operator(block)
		if card.compact:
			card.height = OPERATOR_PAD + maxi((layout[0] as Array).size(), 1) * ROW_HEIGHT
			card.width = _operator_width(graph, block, inputs)
			card.first_row = ((layout[0] as Array).size() - 1) * ROW_HEIGHT * 0.5
		else:
			card.height = 0.08 + maxi((layout[0] as Array).size(), (layout[1] as Array).size()) * ROW_HEIGHT
			card.first_row = card.height * 0.5 - 0.064
		var cuboid := _display == XREFeatureSettings.CUBOID
		var body_size := Vector3(card.width, card.height, CUBOID_DEPTH if cuboid else CARD_THICKNESS)
		card.face = (CUBOID_DEPTH - CARD_THICKNESS) * 0.5 if cuboid else 0.0
		card.bounds = AABB(-body_size * 0.5, body_size)
		card.normal = _body_materials[card_group(block)]
		var body: PrimitiveMesh
		if cuboid:
			var box := BoxMesh.new()
			box.size = body_size
			body = box
		else:
			var panel := QuadMesh.new()
			panel.size = Vector2(card.width, card.height)
			body = panel
		card.mesh = XRERig.create_vr_mesh(body, card.normal)
		card.node.add_child(card.mesh)
		_add_frame(card, body_size, cuboid)
		if not card.compact:
			var title := label("%s · %d" % [XREBlueprintGraph.title(block), card.id], 21)
			title.position = Vector3(0, card.height * 0.5 - 0.022, card.face + CARD_THICKNESS * 0.5 + 0.0005)
			card.node.add_child(title)
		card.plus_point = Vector3(card.width * 0.5 - 0.023, card.height * 0.5 - 0.022, card.face + CARD_THICKNESS * 0.5 + 0.002)
		# Above an operator's small card: inside, they would cover its ports.
		if card.compact: card.plus_point = Vector3(card.width * 0.5 - 0.012, card.height * 0.5 + 0.016, card.face + CARD_THICKNESS * 0.5 + 0.002)
		card.plus = Node3D.new()
		card.node.add_child(card.plus)
		for point: Vector3 in ([card.plus_point] if _plus_shown else []):
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
		_add_rows(card, graph, block, inputs, outputs, layout)
		if card.compact: _add_symbol(card, block)
		_cards.append(card)
	var inline: Array[Wire] = []
	for edge_index: int in graph.edges.size():
		var edge: Dictionary = graph.edges[edge_index]
		var wire := Wire.new()
		wire.edge = edge_index
		wire.from = _find_card(edge["from"])
		wire.to = _find_card(edge["to"])
		wire.from_port = edge["from_port"]
		wire.to_port = edge["to_port"]
		if wire.to == null: continue
		if wire.from == null:
			var source := graph.find_node(edge["from"])
			if is_inline(source):
				wire.variable = str((source["params"] as Dictionary).get("variable", ""))
				inline.append(wire)
			continue
		var color := COLORS[wire.from.output_types[wire.from_port]]
		wire.mesh = create_scene_wire(color)
		wire.normal = wire.mesh.material_override
		wire.lit = wire_material(color, LIT_WIRE_GROW)
		_wires.append(wire)
	_build_shelf(graph)
	for wire: Wire in inline:
		if not _shelf.has_box(wire.variable): continue
		# In its variable's color, as a wire from an output is in its source's: the
		# port it goes into may take any value, as an operator's does (D-065).
		var color := COLORS[XREBlueprintGraph.port_type(XREBlueprintGraph.variable_type(graph.find_variable(wire.variable)))]
		wire.mesh = create_scene_wire(color)
		wire.normal = wire.mesh.material_override
		wire.lit = wire_material(color, LIT_WIRE_GROW)
		_wires.append(wire)
	update_wires()
	select_block(_selected)
	_paint_focus()


## How wide an operator's card is (D-065): its ports and the widest token on
## them on the left, room for its symbol, its result's port on the right.
func _operator_width(graph: XREBlueprintGraph, block: Dictionary, inputs: Array) -> float:
	var tokens := XREBlueprintTokens.port_keys(graph, block) if _value_mode == XREFeatureSettings.PUCKS else ([] as Array[String])
	var widest := 0.0
	for spec: Array in inputs:
		var key: String = spec[2] if spec.size() > 2 else ""
		var value: Variant = (block["params"] as Dictionary).get(key)
		if key in tokens and value != null: widest = maxf(widest, XREBlueprintTokens.width(XREBlueprintTokens.shown(value, key, XREBlueprintTokens.expression_of(block, key))))
	return _operator_start(widest) + _symbol_width(block) + SYMBOL_ROOM


## Where the room for an operator's symbol begins, from its card's left edge, past tokens [param widest] wide.
static func _operator_start(widest: float) -> float:
	return SYMBOL_ROOM + (widest + 0.012 if widest > 0.0 else 0.0)


static func _symbol_size(block: Dictionary) -> int:
	return SYMBOL_SIZE if XREBlueprintGraph.symbol(block).length() == 1 else WORD_SIZE


static func _symbol_width(block: Dictionary) -> float:
	return maxf(text_width(XREBlueprintGraph.symbol(block), _symbol_size(block)), 0.02)


## The symbol in the middle of an operator's card, between its tokens and its result.
func _add_symbol(card: Card, block: Dictionary) -> void:
	var widest := 0.0
	for socket: Socket in card.sockets:
		if _value_mode == XREFeatureSettings.PUCKS and socket.kind == TOKEN and socket.visual.get_child_count() > 0: widest = maxf(widest, socket.size.x)
	var start := -card.width * 0.5 + _operator_start(widest)
	var symbol := label(XREBlueprintGraph.symbol(block), _symbol_size(block))
	symbol.position = Vector3((start + card.width * 0.5 - SYMBOL_ROOM) * 0.5, 0, card.face + CARD_THICKNESS * 0.5 + 0.0005)
	symbol.name = "Symbol"
	card.node.add_child(symbol)


## Whether [param block] is an inline Get Variable (D-061): a wire from a
## variable's box straight into a port stands for it while variables are boxes.
func is_inline(block: Dictionary) -> bool:
	return not block.is_empty() and block.get("kind") == "get_variable" and bool(block.get("vr_inline", false)) and _variable_mode == XREFeatureSettings.BOXES


## The face of [param block]'s card in [constant CARD_PALETTE]: a native
## block's own; a call's by its library category or by its target's class —
## audio players amber, animation players berry — and @GlobalScope's as values.
static func card_group(block: Dictionary) -> int:
	if block.get("kind") != "call": return CARD_GROUPS.get(block.get("kind"), 3)
	var function: Dictionary = block["function"]
	if function["scope"] == "global": return 3
	if CATEGORY_GROUPS.has(str(function.get("category", ""))): return CATEGORY_GROUPS[str(function["category"])]
	for target: Variant in function.get("targets", []):
		var cls := str(target)
		if not ClassDB.class_exists(cls): continue
		if ClassDB.is_parent_class(cls, "AnimationMixer"): return 5
		if cls.begins_with("AudioStreamPlayer"): return 4
	return 1


## Graph coordinates of a workspace point: the inverse of [method position_from_block] without depth.
func block_position(point: Vector3) -> Vector2:
	return Vector2(point.x, -point.y) / PIXEL_SIZE + _offset


## Desktop XY and editor-only depth describe the same card; compilation ignores depth.
func position_from_block(block: Dictionary) -> Vector3:
	var point: Vector2 = block["position"] - _offset
	return Vector3(point.x * PIXEL_SIZE, -point.y * PIXEL_SIZE, float(block.get("vr_depth", 0.0)))


## Moves the existing cards to the graph's placement when only placement changed.
## False means the blocks differ and [method rebuild] is needed.
func sync_placement(graph: XREBlueprintGraph) -> bool:
	if graph.structure_key() != _structure: return false
	var blocks: Array[Dictionary] = []
	for block: Dictionary in graph.nodes:
		if not is_inline(block): blocks.append(block)
	if blocks.size() != _cards.size(): return false
	for index: int in _cards.size():
		var card := _cards[index]
		var block: Dictionary = blocks[index]
		if card.id != block["id"]: return false
		card.node.position = position_from_block(block)
		card.raised = Vector3.ZERO
		_orient(card)
	update_wires()
	return true


## Commits one spatial move to the shared graph history after previewing its geometry.
func commit_move(document: XREBlueprintDocument, id: int) -> bool:
	var card := _find_card(id)
	if card == null: return false
	var state := document.graph.snapshot()
	# The card's place, without its lift in focus (D-073).
	var place := card.node.position - card.raised
	for block: Dictionary in state["nodes"]:
		if block["id"] == id:
			block["position"] = Vector2(place.x, -place.y) / PIXEL_SIZE + _offset
			block["vr_depth"] = place.z
			block.erase("vr_rotation")
	return document.perform(document.commit.bind("Move Blocks", state), &"vr_graph")


## Live geometry only; a preview never modifies the resource or undo history.
## [param point] is where the card is shown, with its lift in focus (D-073), as
## [method get_block_position] gives it.
func preview_move(id: int, point: Vector3) -> void:
	var card := _find_card(id)
	if card == null: return
	card.node.position = point
	_orient(card)
	update_wires()


## Previews position and orientation without touching the graph resource;
## [param pose] is shown, as [method get_block_transform] gives it.
func preview_transform(id: int, pose: Transform3D) -> void:
	var card := _find_card(id)
	if card == null: return
	card.node.transform = pose
	# Shown so, it stands out of its place along its own front (D-073).
	card.raised = pose.basis.z.normalized() * card.lift
	_orient(card)
	update_wires()


## Makes the cards, wires and boxes that cover an input in use, seen from
## [param eye], see-through, and gives the others back their look (D-066):
## the inputs are the first [param count] spheres of [param targets]
## ([XREBlueprintFade]). Only a card that changes is touched.
func fade_covering(eye: Vector3, targets: PackedVector4Array, count: int) -> void:
	for card: Card in _cards:
		var faded := count > 0 and card.node.visible and XREBlueprintFade.covers(eye, targets, count, card.node.global_transform * card.bounds)
		if faded == card.faded: continue
		card.faded = faded
		XREBlueprintFade.set_faded(card.node, faded)
	for wire: Wire in _wires:
		var faded := count > 0 and wire.mesh.visible and XREBlueprintFade.covers(eye, targets, count, wire.mesh.global_transform * wire.mesh.get_aabb())
		if faded == wire.faded: continue
		wire.faded = faded
		XREBlueprintFade.set_faded(wire.mesh, faded)
	_shelf.fade_covering(eye, targets, count)


## Whether the card of block [param id] is see-through, covering an input (D-066).
func is_faded(id: int) -> bool:
	var card := _find_card(id)
	return card != null and card.faded


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


## Billboards face the last head position square on, tilting up or down to it
## too, their rows level (D-061, after D-034 turned them around the vertical
## only); cuboids keep the graph's orientation. Turned from its place, the
## card then stands out of it along its front by its lift (D-073).
func _orient(card: Card) -> void:
	card.node.position -= card.raised
	if _display == XREFeatureSettings.CUBOID: card.node.basis = Basis.IDENTITY
	elif _faces_user: card.node.global_basis = XREBlueprintPetals.face(card.node.global_position, _head_position, Vector3.UP)
	card.raised = card.node.basis.z.normalized() * card.lift
	card.node.position += card.raised


## Keeps a captured point on the rod while its upright panel faces the user.
func preview_grab(id: int, contact: Vector3, local_contact: Vector3, head: Vector3) -> void:
	if _display == XREFeatureSettings.CUBOID:
		# A solid keeps the graph's orientation: only the captured point follows the rod.
		var held := _find_card(id)
		if held == null: return
		held.node.global_transform = Transform3D(global_basis, contact - global_basis * local_contact)
		# Where it is held is where it is shown: its place is its lift behind (D-073).
		held.raised = held.node.basis.z.normalized() * held.lift
		update_wires()
		return
	var orientation := XREBlueprintPetals.face(contact, head, Vector3.UP)
	var span := head - contact
	span.y = 0.0
	# Solve yaw around the captured point, rather than rotating around the center
	# afterwards and moving that point away from the controller's straight ray.
	if span.length() > absf(local_contact.x) + 0.001:
		# Around the vertical, so that the rows stay level on a card tilted to the head.
		orientation = Basis(Vector3.UP, asin(local_contact.x / span.length())) * orientation
	var pose := Transform3D(orientation, contact - orientation * local_contact)
	var card := _find_card(id)
	if card == null: return
	card.node.global_transform = pose
	card.raised = card.node.basis.z.normalized() * card.lift
	update_wires()


## Current card pose in workspace coordinates, including a grip preview and
## its lift in focus (D-073): where it is shown.
func get_block_transform(id: int) -> Transform3D:
	var card := _find_card(id)
	return card.node.transform if card != null else Transform3D.IDENTITY


## Whether the canvas shows a card for block [param id].
func has_block(id: int) -> bool:
	return _find_card(id) != null


## Current preview position of a card in workspace coordinates, with its lift in focus (D-073).
func get_block_position(id: int) -> Vector3:
	var card := _find_card(id)
	return card.node.position if card != null else Vector3.ZERO


## Highlights a card without changing the scene selection.
func select_block(id: int) -> void:
	_selected = id
	for card: Card in _cards: _paint_frame(card)


## A selected card's frame is white, one in focus is [constant XREBlueprintFocus.FRAME]
## with Focus on (D-072), darker out of focus with Defocus on Dim.
func _paint_frame(card: Card) -> void:
	var base := _selected_material if card.id == _selected else _focus_frame if card.look.x == XREBlueprintFocus.LIT else _frame_material
	card.frame.material_override = XREBlueprintFocus.variant(base, XREBlueprintFocus.DARK if card.look.x == XREBlueprintFocus.DARK else XREBlueprintFocus.PLAIN)


## Switches focus (D-072) to [param focus], a value of [constant XREFeatureSettings.FOCUS],
## and [param defocus], one of [constant XREFeatureSettings.DEFOCUS]: the graph
## is painted again. False if nothing changed.
func set_focus_modes(focus: StringName, defocus: StringName) -> bool:
	if focus == _focus_mode and defocus == _defocus_mode: return false
	_focus_mode = focus
	_defocus_mode = defocus
	for card: Card in _cards: card.look = Vector4i(-1, 0, 0, 0)
	for wire: Wire in _wires: wire.look = -1
	for link: Dictionary in _variable_wires: link["look"] = -1
	_shelf.forget_looks()
	_paint_focus()
	return true


## The focus settings, as [method set_focus_modes] takes them.
func get_focus_modes() -> Array[StringName]:
	return [_focus_mode, _defocus_mode]


## Puts the cards of [param cards] (-1 for none) and the boxes of variables
## [param box] and [param other_box] (empty for none) in focus, with their
## ports, details and wires, and the rest of the graph out of it (D-072);
## nothing in focus gives everything back. Only what changes is painted: it
## may be called every frame.
func set_focus(cards: Vector3i, box: String = "", other_box: String = "") -> void:
	if cards == _focus_cards and box == _focus_box and other_box == _focus_other_box: return
	_focus_cards = cards
	_focus_box = box
	_focus_other_box = other_box
	_paint_focus()


## How block [param id] is in focus: [constant XREBlueprintFocus.FOCUSED],
## [constant XREBlueprintFocus.OUT], or [constant XREBlueprintFocus.NORMAL] while nothing is.
func focus_state(id: int) -> int:
	if not _focus_any: return XREBlueprintFocus.NORMAL
	return XREBlueprintFocus.FOCUSED if _in_focus(id) else XREBlueprintFocus.OUT


## How what is in focus [param state] is painted under the settings: lit in
## focus with Focus on, darker out of it with Defocus on Dim.
func focus_paint(state: int) -> int:
	if state == XREBlueprintFocus.FOCUSED and _focus_mode == XREFeatureSettings.ON: return XREBlueprintFocus.LIT
	if state == XREBlueprintFocus.OUT and _defocus_mode == XREFeatureSettings.DIM: return XREBlueprintFocus.DARK
	return XREBlueprintFocus.PLAIN


## How much of what is in focus [param state] is seen: less out of focus with Defocus on Transparent.
func focus_seen(state: int) -> float:
	return XREBlueprintFocus.SEEN if state == XREBlueprintFocus.OUT and _defocus_mode == XREFeatureSettings.TRANSPARENT else 1.0


## How far what is in focus [param state] comes toward the user: [constant FRONT_LIFT]
## in focus with Focus on Front (D-073), else 0.
func focus_lift(state: int) -> float:
	return FRONT_LIFT if state == XREBlueprintFocus.FOCUSED and _focus_mode == XREFeatureSettings.FRONT else 0.0


func _in_focus(id: int) -> bool:
	return id >= 0 and (id == _focus_cards.x or id == _focus_cards.y or id == _focus_cards.z)


## Works out what is in focus and paints what changed (D-072). Run on a change
## of focus, of the graph or of the ports a wire may end on, never every frame.
## In focus: the cards and boxes asked for and the wires on them. Out of it:
## the rest, but the far ends of those wires — a port, a socket, a box — and
## the ports a wire being drawn may end on stay as they are. With Focus on
## Front the cards and boxes in focus come forward, the wires on them follow (D-073).
func _paint_focus() -> void:
	var used := _focus_mode != XREFeatureSettings.OFF or _defocus_mode != XREFeatureSettings.OFF
	var any := false
	if used:
		for card: Card in _cards: any = any or _in_focus(card.id)
		any = any or _shelf.has_box(_focus_box) or _shelf.has_box(_focus_other_box)
	_focus_any = any
	for card: Card in _cards:
		card.focus = (XREBlueprintFocus.FOCUSED if _in_focus(card.id) else XREBlueprintFocus.OUT) if any else XREBlueprintFocus.NORMAL
		card.keep_ports = 0
		card.keep_sockets = 0
	var boxes: Dictionary[String, int] = {}
	if any:
		for variable: String in [_focus_box, _focus_other_box]:
			if _shelf.has_box(variable): boxes[variable] = XREBlueprintFocus.FOCUSED
	for wire: Wire in _wires:
		var focused: bool = any and ((wire.from != null and wire.from.focus == XREBlueprintFocus.FOCUSED) or wire.to.focus == XREBlueprintFocus.FOCUSED
				or (wire.from == null and boxes.get(wire.variable, XREBlueprintFocus.NORMAL) == XREBlueprintFocus.FOCUSED))
		wire.focus = XREBlueprintFocus.FOCUSED if focused else XREBlueprintFocus.OUT if any else XREBlueprintFocus.NORMAL
		if not focused: continue
		_keep_port(wire.to, wire.to_port, true)
		if wire.from != null: _keep_port(wire.from, wire.from_port, false)
		elif not boxes.has(wire.variable): boxes[wire.variable] = XREBlueprintFocus.KEPT
	for link: Dictionary in _variable_wires:
		var card: Card = link["card"]
		var variable: String = link["variable"]
		var focused: bool = any and (card.focus == XREBlueprintFocus.FOCUSED or boxes.get(variable, XREBlueprintFocus.NORMAL) == XREBlueprintFocus.FOCUSED)
		link["focus"] = XREBlueprintFocus.FOCUSED if focused else XREBlueprintFocus.OUT if any else XREBlueprintFocus.NORMAL
		if not focused: continue
		if card.focus != XREBlueprintFocus.FOCUSED: card.keep_sockets |= 1 << int(link["socket"])
		if not boxes.has(variable): boxes[variable] = XREBlueprintFocus.KEPT
	if any and _compatible_type >= 0:
		for card: Card in _cards:
			if card.focus != XREBlueprintFocus.OUT: continue
			for index: int in card.ports.size():
				if _compatible(card, index): card.keep_ports |= 1 << index
	for card: Card in _cards: _look_card(card)
	for wire: Wire in _wires: _look_wire(wire)
	for link: Dictionary in _variable_wires: _look_link(link)
	var moved := false
	for index: int in _shelf.box_count():
		var state: int = boxes.get(_shelf.box_name(index), XREBlueprintFocus.OUT if any else XREBlueprintFocus.NORMAL)
		_shelf.paint_box(index, state, focus_paint(state), focus_seen(state))
		moved = _shelf.raise_box(index, focus_lift(state)) or moved
	for card: Card in _cards:
		var lift := focus_lift(card.focus)
		if lift == card.lift: continue
		card.lift = lift
		_orient(card)
		moved = true
	if moved: update_wires()


## Keeps port [param port] of [param card] (an input if [param input]) as it
## is out of focus: the far end of a wire in focus. Play Animation's output 0
## is its Finished socket while it waits.
func _keep_port(card: Card, port: int, input: bool) -> void:
	if card.focus == XREBlueprintFocus.FOCUSED: return
	if not input and port == 0 and card.finished >= 0 and card.waits: card.keep_sockets |= 1 << card.finished
	else: card.keep_ports |= 1 << (port if input else card.inputs.size() + port)


func _look_card(card: Card) -> void:
	var paint := focus_paint(card.focus)
	var seen := focus_seen(card.focus)
	var look := Vector4i(paint, 1 if seen < 1.0 else 0, card.keep_ports, card.keep_sockets)
	if look == card.look: return
	card.look = look
	XREBlueprintFocus.paint(card.node, paint)
	XREBlueprintFade.set_seen(card.node, &"focus", seen)
	for index: int in card.ports.size():
		if (card.keep_ports & (1 << index)) == 0: continue
		XREBlueprintFocus.paint(card.ports[index], XREBlueprintFocus.PLAIN)
		XREBlueprintFade.set_seen(card.ports[index], &"focus", 1.0)
	for index: int in card.sockets.size():
		if (card.keep_sockets & (1 << index)) == 0 or card.sockets[index].visual == null: continue
		XREBlueprintFocus.paint(card.sockets[index].visual, XREBlueprintFocus.PLAIN)
		XREBlueprintFade.set_seen(card.sockets[index].visual, &"focus", 1.0)
	_paint_frame(card)


func _look_wire(wire: Wire) -> void:
	var seen := focus_seen(wire.focus)
	var look := focus_paint(wire.focus) * 2 + (1 if seen < 1.0 else 0)
	if look == wire.look: return
	wire.look = look
	XREBlueprintFade.set_seen(wire.mesh, &"focus", seen)
	_paint_wire(wire)


## The wire's material: thicker if a click would detach it, then lit or darker by its focus (D-072).
func _paint_wire(wire: Wire) -> void:
	var lit := wire.edge == _edge_right or wire.edge == _edge_left
	wire.mesh.material_override = XREBlueprintFocus.variant(wire.lit if lit else wire.normal, focus_paint(wire.focus))


func _look_link(link: Dictionary) -> void:
	var state: int = link["focus"]
	var seen := focus_seen(state)
	var look := focus_paint(state) * 2 + (1 if seen < 1.0 else 0)
	if look == int(link["look"]): return
	link["look"] = look
	XREBlueprintFade.set_seen(link["mesh"] as Node, &"focus", seen)
	_paint_link(link)


## A Variable wire's material: white while its variable flashes, thicker
## under a ray on its socket, then lit or darker by its focus (D-072).
func _paint_link(link: Dictionary) -> void:
	var card: Card = link["card"]
	var base: Material = link["flash"] if link["flash"] != null else link["lit"] if is_socket_hovered(card.id, int(link["socket"])) else link["normal"]
	(link["mesh"] as XREGraphWire).material_override = XREBlueprintFocus.variant(base, focus_paint(int(link["focus"])))


## Each hand contributes hover independently, so one idle ray cannot clear the other.
func hover_plus(id: int, right: bool) -> void:
	if (right and _hover_right == id) or (not right and _hover_left == id): return
	if right: _hover_right = id
	else: _hover_left = id
	for card: Card in _cards:
		for face: Node3D in card.plus_faces:
			face.scale = Vector3.ONE * (HOVER_SCALE if card.id == _hover_right or card.id == _hover_left else 1.0)


## Highlights only type-compatible endpoints while a connection is being made.
func highlight_ports(type: int, want_input: bool) -> void:
	var changed := type != _compatible_type or want_input != _compatible_input
	_compatible_type = type
	_compatible_input = want_input
	_scale_ports()
	# Out of focus, the ports a wire may end on stay as they are (D-072).
	if changed: _paint_focus()


## Grows the ports a wire may end on and, more, the ports under a ray.
func _scale_ports() -> void:
	for card: Card in _cards:
		for index: int in card.ports.size():
			var hovered := Vector2i(card.id, index) == _port_right or Vector2i(card.id, index) == _port_left
			card.ports[index].scale = Vector3.ONE * (HOVER_SCALE if hovered else COMPATIBLE_SCALE if _compatible(card, index) else 1.0)
	update_wires()


## Whether a wire being drawn may end on port [param index] of [param card] (in [member Card.ports]).
func _compatible(card: Card, index: int) -> bool:
	if _compatible_type < 0: return false
	var input := index < card.inputs.size()
	if input != _compatible_input: return false
	var port_type := card.input_types[index] if input else card.output_types[index - card.inputs.size()]
	return XREBlueprintGraph.ports_compatible(_compatible_type, port_type) if _compatible_input else XREBlueprintGraph.ports_compatible(port_type, _compatible_type)


## Whether the port of card [param id] at [param index] in its ports is under a hand's ray.
func is_port_hovered(id: int, port: int, input: bool) -> bool:
	var card := _find_card(id)
	if card == null: return false
	var key := Vector2i(id, port if input else card.inputs.size() + port)
	return key == _port_right or key == _port_left


## Both hands contribute action hover independently, using cached card visuals:
## the plus, the trash or port [param port] of card [param id] (an input if
## [param input]) under the ray of the [param right] hand or the other.
## [param edge] is the wire on that port to light ([method get_hit_edge]), or -1.
## The shelf's box under that ray is let go too, unless [param keep_box].
func hover_actions(id: int, plus: bool, trash: bool, right: bool, port: int = -1, input: bool = false, edge: int = -1, keep_box: bool = false) -> void:
	if not keep_box: _shelf.hover(-1, -1, right)
	hover_plus(id if plus else -1, right)
	_hover_port(id, port, input, right)
	_hover_edge(edge if port >= 0 else -1, right)
	var hovered := id if trash else -1
	if (right and _delete_right == hovered) or (not right and _delete_left == hovered): return
	if right: _delete_right = hovered
	else: _delete_left = hovered
	for card: Card in _cards:
		card.trash.scale = Vector3.ONE * (HOVER_SCALE if card.id == _delete_right or card.id == _delete_left else 1.0)


func _hover_edge(edge: int, right: bool) -> void:
	if edge == (_edge_right if right else _edge_left): return
	if right: _edge_right = edge
	else: _edge_left = edge
	for wire: Wire in _wires: _paint_wire(wire)


## Whether the wire of graph edge [param edge] is lit under a ray.
func is_edge_lit(edge: int) -> bool:
	return edge >= 0 and (edge == _edge_right or edge == _edge_left)


## The graph's edges on port [param port] of card [param id] (an input if
## [param input]), the one whose other end is highest first.
func port_edges(id: int, port: int, input: bool) -> Array[int]:
	var found: Array[Wire] = []
	for wire: Wire in _wires:
		if (wire.to.id == id and wire.to_port == port) if input else (wire.from != null and wire.from.id == id and wire.from_port == port):
			found.append(wire)
	found.sort_custom(func(first: Wire, second: Wire) -> bool:
		return _far_end(first, input).y > _far_end(second, input).y)
	var edges: Array[int] = []
	for wire: Wire in found:
		edges.append(wire.edge)
	return edges


## Where [param wire] ends away from the port it is looked at from: its output's end if that port is an input.
func _far_end(wire: Wire, input: bool) -> Vector3:
	if input and wire.from == null: return _shelf.box_point(wire.variable)
	return _port_position(wire.from, wire.from_port, false) if input else _port_position(wire.to, wire.to_port, true)


## The edge on the port the last ray hit that the hit's height picks
## ([method port_edges]: the top of the port picks the first), or -1 for no
## port or no wire on it.
func get_hit_edge() -> int:
	return _hit_edge


func _hover_port(id: int, port: int, input: bool, right: bool) -> void:
	var key := Vector2i(-1, -1)
	if id >= 0 and port >= 0:
		var card := _find_card(id)
		if card != null: key = Vector2i(id, port if input else card.inputs.size() + port)
	if key == (_port_right if right else _port_left): return
	if right: _port_right = key
	else: _port_left = key
	_scale_ports()


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
	_hit_edge = -1
	_hit_height = 0.0
	_hit_socket = -1
	_hit_finished = false
	_hit_box = false
	if not is_visible_in_tree(): return -1.0
	var inverse := global_transform.affine_inverse()
	var local_origin := inverse * origin
	var local_direction := inverse.basis * direction
	var nearest := maximum
	var proximity := INF
	for card: Card in _cards:
		# See-through over an input in use, a card doesn't take the ray from it (D-067).
		if card.faded: continue
		var card_inverse := card.node.transform.affine_inverse()
		var card_origin := card_inverse * local_origin
		var card_direction := card_inverse.basis * local_direction
		# Come forward (D-073), a card takes the ray down to its place too: it
		# doesn't drop back under a ray it moved away from.
		var bounds := card.bounds.merge(AABB(card.bounds.position + Vector3.FORWARD * card.lift, card.bounds.size)) if card.lift > 0.0 else card.bounds
		var body := _box_distance(card_origin, card_direction, bounds, nearest)
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
				_hit_height = (card_origin + card_direction * hit - center).y / ((PORT_RADIUS + PORT_HIT_MARGIN) * card.ports[index].scale.y)
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
				_hit_height = (card_origin + card_direction * hit - center).y / ((PORT_RADIUS + PORT_HIT_MARGIN) * card.ports[card.inputs.size() + index].scale.y)
		for index: int in card.sockets.size():
			var socket := card.sockets[index]
			var hit := -1.0
			if socket.kind in [FINISHED, SOURCE, VARIABLE]:
				hit = _port_distance(card_origin, card_direction, socket.center, socket.visual.scale, nearest)
				if hit < 0: continue
				var score := (card_origin + card_direction * hit - socket.center).length_squared()
				if not (hit < nearest or score < proximity): continue
				proximity = score
			else:
				# While a wire is drawn tokens and names give way to the ports under them.
				if _compatible_type >= 0: continue
				var size := socket.size * (socket.visual.scale.x / socket.base_scale.x) + Vector3.ONE * 0.004
				# A token on the face wins over the face it lies on.
				hit = _box_distance(card_origin, card_direction, AABB(socket.center - size * 0.5, size), nearest + 0.02)
				if hit < 0: continue
			nearest = minf(hit, nearest)
			_hit_id = card.id
			_hit_socket = index
			_hit_port = socket.port if socket.kind == FINISHED else -1
			_hit_input = false
			_hit_finished = socket.kind == FINISHED
			_hit_plus = false
			_hit_delete = false
	if _shelf.visible:
		var shelf := _shelf.intersect_ray(local_origin, local_direction, nearest)
		if shelf >= 0:
			nearest = shelf
			_hit_box = true
			_hit_id = -1
			_hit_port = -1
			_hit_socket = -1
			_hit_plus = false
			_hit_delete = false
			return nearest
	if _hit_port >= 0 and _hit_finished:
		# Finished picks the wire of output 0 only while it leaves Finished.
		var card := _find_card(_hit_id)
		if card != null and card.waits:
			var edges := port_edges(_hit_id, 0, false)
			if not edges.is_empty(): _hit_edge = edges[0]
		return nearest
	if _hit_port >= 0 and _hit_socket < 0 and not _hit_input and _hit_port == 0:
		var card := _find_card(_hit_id)
		if card != null and card.finished >= 0 and card.waits:
			# Then has no wire while the wire leaves Finished.
			return nearest
	if _hit_port >= 0:
		var edges := port_edges(_hit_id, _hit_port, _hit_input)
		if not edges.is_empty():
			# Bands from the port's top down, one per wire.
			var band := floori((1.0 - clampf(_hit_height, -1.0, 1.0)) * 0.5 * edges.size())
			_hit_edge = edges[clampi(band, 0, edges.size() - 1)]
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


func _port_distance(origin: Vector3, direction: Vector3, center: Vector3, scale: Vector3, maximum: float) -> float:
	if _port_display == XREFeatureSettings.SPHERE:
		# The sphere and the same margin as a disc's around it.
		var radius := (PORT_RADIUS + PORT_HIT_MARGIN) * scale.x
		var along := (center - origin).dot(direction) / direction.length_squared()
		var off := (origin + direction * along).distance_squared_to(center)
		if off > radius * radius: return -1.0
		var depth := sqrt((radius * radius - off) / direction.length_squared())
		var near := along - depth if along - depth >= 0.0 else along + depth
		return near if near >= 0.0 and near <= maximum else -1.0
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


## Index of the socket the last ray hit on its card ([constant TOKEN] and the others), or -1.
func get_hit_socket() -> int:
	return _hit_socket


## The color of what the last ray hit, for the pipette (D-065): a color
## token's or a box's color, else the token's, the port's or the box's type
## color, the plus's or the trash's own, the card's face. Null for nothing.
func get_hit_color() -> Variant:
	if _hit_box: return _shelf.get_hit_color()
	var card := _find_card(_hit_id)
	if card == null: return null
	if _hit_socket >= 0 and _hit_socket < card.sockets.size():
		var socket := card.sockets[_hit_socket]
		if socket.value is Color: return socket.value
		return MEMBER_COLOR if socket.kind == MEMBER else COLORS[socket.type]
	if _hit_port >= 0: return COLORS[card.input_types[_hit_port] if _hit_input else card.output_types[_hit_port]]
	if _hit_plus: return Color.WHITE
	if _hit_delete: return (_trash_material as BaseMaterial3D).albedo_color
	return (card.normal as ShaderMaterial).get_shader_parameter(&"face_tint")


## Kind of the socket the last ray hit, or -1.
func get_hit_socket_kind() -> int:
	var card := _find_card(_hit_id)
	return card.sockets[_hit_socket].kind if card != null and _hit_socket >= 0 and _hit_socket < card.sockets.size() else -1


## Parameter of the socket the last ray hit, or empty.
func get_hit_socket_key() -> String:
	var card := _find_card(_hit_id)
	return card.sockets[_hit_socket].key if card != null and _hit_socket >= 0 and _hit_socket < card.sockets.size() else ""


## Whether the last ray hit Play Animation's Finished output; its port is then 0.
func get_hit_finished() -> bool:
	return _hit_finished


## Whether the last ray hit a box of the shelf ([method get_shelf]).
func get_hit_box() -> bool:
	return _hit_box


## The variables' boxes.
func get_shelf() -> XREBlueprintShelf:
	return _shelf


## Whether output 0 of block [param id] leaves Finished: the block waits.
func is_waiting(id: int) -> bool:
	var card := _find_card(id)
	return card != null and card.finished >= 0 and card.waits


## Whether block [param id] shows a Finished output.
func has_finished(id: int) -> bool:
	var card := _find_card(id)
	return card != null and card.finished >= 0


## The keys of the token sockets of block [param id], squares too.
func token_keys(id: int) -> Array[String]:
	var keys: Array[String] = []
	var card := _find_card(id)
	if card == null: return keys
	for socket: Socket in card.sockets:
		if socket.kind in [TOKEN, SQUARE]: keys.append(socket.key)
	return keys


## The value the token of [param key] on block [param id] shows.
func token_value(id: int, key: String) -> Variant:
	var socket := _socket(id, key)
	return socket.value if socket != null else null


## Whether the token of [param key] on block [param id] is under a wire.
func is_token_wired(id: int, key: String) -> bool:
	var socket := _socket(id, key)
	return socket != null and socket.wired


## Shows [param value] on the token of [param key] while it is turned, without editing the graph.
## Hides the token of [param key] on block [param id] while it is carried away (D-058);
## the next rebuild shows the socket as the graph has it.
func hide_token(id: int, key: String, hidden: bool = true) -> void:
	var socket := _socket(id, key)
	if socket != null and socket.visual != null: socket.visual.visible = not hidden


## Shows [param value] on the token of [param key] on block [param id] until
## the next rebuild, as [param shown] says if given (an expression, D-063).
func preview_token(id: int, key: String, value: Variant, shown: String = "") -> void:
	var socket := _socket(id, key)
	if socket != null and socket.text != null: socket.text.text = shown if not shown.is_empty() else XREBlueprintTokens.text(value, key)


## The global transform of the token of [param key] on block [param id].
func token_transform(id: int, key: String) -> Transform3D:
	var card := _find_card(id)
	var socket := _socket(id, key)
	if card == null or socket == null: return global_transform
	return global_transform * card.node.transform * Transform3D(Basis.IDENTITY, socket.center)


## Where socket [param kind] of block [param id] is, in the canvas's space; the card's center if it has none.
func socket_position(id: int, kind: int) -> Vector3:
	var card := _find_card(id)
	if card == null: return Vector3.ZERO
	for socket: Socket in card.sockets:
		if socket.kind == kind: return card.node.transform * socket.center
	return card.node.position


## Grows the socket under a hand's ray: index [param socket] on block [param id], -1 for none.
func hover_socket(id: int, socket: int, right: bool) -> void:
	var key := Vector2i(id, socket)
	if key == (_socket_right if right else _socket_left): return
	if right: _socket_right = key
	else: _socket_left = key
	for card: Card in _cards:
		for index: int in card.sockets.size():
			var hovered := Vector2i(card.id, index) == _socket_right or Vector2i(card.id, index) == _socket_left
			var item := card.sockets[index]
			if item.kind in [FINISHED, SOURCE, VARIABLE]: item.visual.scale = item.base_scale * (HOVER_SCALE if hovered else 1.0)
			else: item.visual.scale = item.base_scale * (SOCKET_HOVER if hovered else 1.0)
	# The wire of a Variable socket under a ray thickens, as a port's does (D-061).
	for link: Dictionary in _variable_wires: _paint_link(link)


## Whether socket [param socket] of block [param id] is under a hand's ray.
func is_socket_hovered(id: int, socket: int) -> bool:
	return Vector2i(id, socket) == _socket_right or Vector2i(id, socket) == _socket_left


func _socket(id: int, key: String) -> Socket:
	var card := _find_card(id)
	if card == null: return null
	for socket: Socket in card.sockets:
		if socket.kind in [TOKEN, SQUARE] and socket.key == key: return socket
	return null


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


## A wire leaves a disc from its face and a sphere from its center; Play
## Animation's output 0 leaves Finished while it waits (D-052).
func _port_position(card: Card, port: int, input: bool, finished: int = -1) -> Vector3:
	if not input and port == 0 and card.finished >= 0 and (card.waits if finished < 0 else finished == 1):
		return card.node.transform * (card.sockets[card.finished].center + Vector3.BACK * PORT_DEPTH)
	var visual := card.ports[port if input else card.inputs.size() + port]
	var center := card.inputs[port] if input else card.outputs[port]
	if _port_display == XREFeatureSettings.SPHERE: return card.node.transform * center
	return card.node.transform * (center + Vector3.BACK * PORT_DEPTH * visual.scale.z)


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


## A connection preview uses the same pooled geometry as permanent wires. A
## wire from Play Animation's output 0 leaves Finished with [param finished] 1,
## Then with 0, and where its wire is with -1.
func show_connection(id: int, port: int, input: bool, end: Vector3, end_id: int = -1, end_port: int = -1, end_input: bool = false, finished: int = -1) -> void:
	# Over a port the preview snaps to it; elsewhere its end follows the ray freely.
	var direction := Vector3.ZERO
	if end_id >= 0 and end_port >= 0:
		end = port_position(end_id, end_port, end_input)
		direction = port_direction(end_id, end_input)
	var card := _find_card(id)
	if card == null: return
	_preview.update_curve(_port_position(card, port, input, finished), port_direction(id, input), end, direction, _front(card))
	_preview.visible = true


## A preview from socket [param kind] of card [param id] — Source or Variable — to [param end], in the canvas's space.
func show_socket_link(id: int, kind: int, end: Vector3) -> void:
	var card := _find_card(id)
	if card == null: return
	for socket: Socket in card.sockets:
		if socket.kind == kind:
			_preview.update_curve(card.node.transform * socket.center, Vector3.LEFT, end, Vector3.ZERO, _front(card))
			_preview.visible = true
			return


## Clears preview geometry and compatibility emphasis.
func hide_connection() -> void:
	_preview.visible = false
	highlight_ports(-1, false)


## Updates existing mesh transforms after a card preview; creates no geometry.
func update_wires() -> void:
	for wire: Wire in _wires:
		if wire.from == null:
			var port := _port_position(wire.to, wire.to_port, true)
			var end := _shelf.box_end(wire.variable, port)
			wire.mesh.update_curve(end[0], end[1], port, _port_direction(wire.to, true), _front(wire.to))
			continue
		wire.mesh.update_curve(_port_position(wire.from, wire.from_port, false), _port_direction(wire.from, false), _port_position(wire.to, wire.to_port, true), _port_direction(wire.to, true), (_front(wire.from) + _front(wire.to)).normalized())
	for link: Dictionary in _variable_wires:
		var card: Card = link["card"]
		var socket: Socket = card.sockets[link["socket"]]
		var at := card.node.transform * socket.center
		var end := _shelf.box_end(link["variable"], at)
		(link["mesh"] as XREGraphWire).update_curve(at, Vector3.LEFT, end[0], end[1], _front(card))


## Creates one reusable native tube; permanent, preview and scene wires share it.
func create_scene_wire(color: Color) -> XREGraphWire:
	var wire := XREGraphWire.new()
	wire.layers = XRERig.VR_LAYER
	wire.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	wire.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	# Room for a thickened wire beyond the tube's own bounds.
	wire.extra_cull_margin = LIT_WIRE_GROW
	wire.material_override = wire_material(color)
	add_child(wire)
	return wire


## A preview from [param from] to [param to], in the canvas's space: a wire from a petal or a box.
func show_link(from: Vector3, to: Vector3) -> void:
	_preview.update_curve(from, Vector3.ZERO, to, Vector3.ZERO, Vector3.BACK)
	_preview.visible = true


## A static wire from socket [param kind] of block [param id] — an event's Source — towards the scene object.
func update_socket_wire(wire: XREGraphWire, id: int, kind: int, end: Vector3) -> void:
	wire.update_curve(socket_position(id, kind), Vector3.LEFT, end, Vector3.ZERO, _front(_find_card(id)))


## Lights the Variable wires to the box of [param variable] — a variable in use that can't be deleted — or puts them back.
func flash_variable(variable: String, lit: bool) -> void:
	for link: Dictionary in _variable_wires:
		if link["variable"] != variable: continue
		link["flash"] = wire_material(Color.WHITE, LIT_WIRE_GROW * 2.0) if lit else null
		_paint_link(link)


## A static Target wire: from its input port, leaving left, free towards the scene object.
func update_scene_wire(wire: XREGraphWire, id: int, port: int, end: Vector3) -> void:
	wire.update_curve(port_position(id, port, true), port_direction(id, true), end, Vector3.ZERO, _front(_find_card(id)))


## [param shown] is the type whose color it has, if not its own: an operator's
## input of any value wired is in the color of what comes in (D-065).
func _add_port(card: Card, spec: Array, index: int, input: bool, row: int = -1, shown: int = -1) -> Label3D:
	var point := _row_point(card, row if row >= 0 else index, input)
	var color := COLORS[shown if shown >= 0 else spec[1]]
	var mesh: MeshInstance3D
	if _port_display == XREFeatureSettings.SPHERE:
		# Shaded by the view angle, as wires are, so that it reads as round.
		point.z = card.face + CARD_THICKNESS * 0.5 + PORT_RADIUS * SPHERE_LIFT
		mesh = XRERig.create_vr_mesh(_sphere_mesh, wire_material(color))
	else:
		mesh = XRERig.create_vr_mesh(_port_mesh, material(color, true))
		mesh.rotation.x = PI * 0.5
	mesh.position = point
	card.node.add_child(mesh)
	card.ports.append(mesh)
	if input:
		card.inputs.append(point)
		card.input_types.append(spec[1])
	else:
		card.outputs.append(point)
		card.output_types.append(spec[1])
	# An operator's ports have no names (D-065): its symbol says what they are.
	var text := label(spec[0] if not card.compact else "", 18)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if input else HORIZONTAL_ALIGNMENT_RIGHT
	text.position = point + Vector3(0.022 if input else -0.022, 0, 0)
	card.node.add_child(text)
	return text


## Where the port of row [param row] is on the left ([param input]) or the right edge of [param card].
## An operator's result is in the middle of its card's height.
func _row_point(card: Card, row: int, input: bool) -> Vector3:
	var top := 0.0 if card.compact and not input else card.first_row
	return Vector3((-card.width * 0.5 + 0.014) if input else (card.width * 0.5 - 0.014), top - row * ROW_HEIGHT, card.face + 0.003)


## The rows of [param block]'s card (D-052): on the left its inputs, then square
## sockets for settings without ports, an event's Source and a Variable; on the
## right its outputs, with Finished after Play Animation's Then.
func _layout(graph: XREBlueprintGraph, block: Dictionary, inputs: Array, outputs: Array) -> Array:
	var left: Array[Dictionary] = []
	var right: Array[Dictionary] = []
	var finished := _wait_mode == XREFeatureSettings.FINISHED_PORT and XREBlueprintTokens.has_finished(block)
	for index: int in inputs.size(): left.append({"port": index})
	if _value_mode != XREFeatureSettings.WINDOW:
		for key: String in XREBlueprintTokens.square_keys(block, finished): left.append({"square": key})
	if XREBlueprintTokens.targets_in_scene(_target_mode) and block["kind"] == "signal": left.append({"source": true})
	if _variable_mode == XREFeatureSettings.BOXES and block["kind"] in ["get_variable", "set_variable"]: left.append({"variable": true})
	for index: int in outputs.size():
		right.append({"port": index})
		if index == 0 and finished: right.append({"finished": true})
	return [left, right]


## Builds the rows of [param layout] ([method _layout]) on [param card].
func _add_rows(card: Card, graph: XREBlueprintGraph, block: Dictionary, inputs: Array, outputs: Array, layout: Array) -> void:
	var left: Array[Dictionary] = layout[0]
	var right: Array[Dictionary] = layout[1]
	var params: Dictionary = block["params"]
	var wired: Dictionary[int, bool] = {}
	for edge: Dictionary in graph.edges:
		if edge["to"] == card.id: wired[int(edge["to_port"])] = true
	var tokens := XREBlueprintTokens.port_keys(graph, block) if _value_mode != XREFeatureSettings.WINDOW else ([] as Array[String])
	var member_key := XREBlueprintTokens.member_key(block) if XREBlueprintTokens.member_on_card(_target_mode) else ""
	for row: int in left.size():
		var entry := left[row]
		# An operator's token goes right by its port, before the symbol.
		var occupied := row < right.size() or card.compact
		if entry.has("port"):
			var index: int = entry["port"]
			var spec: Array = inputs[index]
			# Wired, an operator's input of any value takes the color of what comes in, as an Unreal wildcard pin.
			var shown := XREBlueprintGraph.port_type(graph.operand_type(block, spec[2])) if card.compact and spec[1] == XREBlueprintGraph.VALUE and wired.has(index) else -1
			var text := _add_port(card, spec, index, true, row, shown)
			var key: String = spec[2] if spec.size() > 2 else ""
			if key == "target" and XREBlueprintTokens.adapter(_target_mode) and block["kind"] != "signal":
				if not wired.has(index): _add_adapter(card, block, _row_point(card, row, true))
			elif key == "target" and not member_key.is_empty() and block["kind"] != "signal":
				_add_member(card, text, member_key, str(params.get(member_key, "")), block)
			elif key in tokens:
				_add_token(card, key, params.get(key), index, row, text, occupied, wired.has(index), false, XREBlueprintTokens.expression_of(block, key))
		elif entry.has("square"):
			var key: String = entry["square"]
			var point := _row_point(card, row, true)
			var square := BoxMesh.new()
			square.size = Vector3(0.0136, 0.0136, 0.0012)
			var socket_visual := XRERig.create_vr_mesh(square, material(Color(1, 1, 1, 0.55), true))
			socket_visual.position = point
			card.node.add_child(socket_visual)
			var text := label(XREBlueprintFunctions.title_of(key), 18)
			text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			text.position = point + Vector3(0.022, 0, 0)
			card.node.add_child(text)
			_add_token(card, key, params.get(key), -1, row, text, occupied, false, true, XREBlueprintTokens.expression_of(block, key))
		elif entry.has("source"):
			var text := _add_virtual(card, SOURCE, "signal", "Source", XREBlueprintGraph.OBJECT, row, true)
			if XREBlueprintTokens.member_on_card(_target_mode): _add_member(card, text, "signal", str(params.get("signal", "")), block)
			elif XREBlueprintTokens.adapter(_target_mode): _add_adapter(card, block, _row_point(card, row, true))
		elif entry.has("variable"):
			var variable := graph.find_variable(str(params.get("variable", "")))
			var type := XREBlueprintGraph.port_type(XREBlueprintGraph.variable_type(variable)) if not variable.is_empty() else XREBlueprintGraph.VALUE
			var text := _add_virtual(card, VARIABLE, "variable", "Variable", type, row, true)
			# No name by the socket (D-061): the wire goes to the variable's box, which has it.
			if variable.is_empty(): _add_member(card, text, "", "choose a box", block)
	for row: int in right.size():
		var entry := right[row]
		if entry.has("port"):
			_add_port(card, outputs[entry["port"]], entry["port"], false, row)
		else:
			_add_virtual(card, FINISHED, "wait", "Finished", XREBlueprintGraph.EXEC, row, false)
			card.finished = card.sockets.size() - 1
			card.waits = bool(params.get("wait", false))


## A port-like socket that is not one of the block's ports: Finished, Source or Variable.
func _add_virtual(card: Card, kind: int, key: String, title: String, type: int, row: int, input: bool) -> Label3D:
	var point := _row_point(card, row, input)
	var mesh := XRERig.create_vr_mesh(_port_mesh, material(COLORS[type], true))
	mesh.rotation.x = PI * 0.5
	mesh.position = point
	card.node.add_child(mesh)
	var socket := Socket.new()
	socket.kind = kind
	socket.key = key
	socket.type = type
	socket.port = 0 if kind == FINISHED else -1
	socket.center = point
	socket.size = Vector3(PORT_RADIUS * 2.0, PORT_RADIUS * 2.0, PORT_DEPTH * 2.0)
	socket.visual = mesh
	card.sockets.append(socket)
	var text := label(title, 18)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if input else HORIZONTAL_ALIGNMENT_RIGHT
	text.position = point + Vector3(0.022 if input else -0.022, 0, 0)
	card.node.add_child(text)
	return text


## The name of the target's member after [param after], as a small petal of
## its own with a gap before it, so that it doesn't run into the label
## (D-055); a socket whose trigger opens the member's petals (D-052).
func _add_member(card: Card, after: Label3D, key: String, member: String, block: Dictionary) -> void:
	# The ▸ says that the name is a choice: the trigger on it opens the object's petals (D-057).
	var shown := (member + " ▸" if not key.is_empty() else member) if not member.is_empty() else XREBlueprintTokens.member_placeholder(block)
	var pill := XREBlueprintPetals.make_pill(shown, 1.0 if not member.is_empty() else 0.6)
	var scale := 0.72
	var width := float(pill.get_meta(&"width")) * scale
	var start := after.position.x + text_width(after.text, 18) + 0.012
	width = minf(width, card.width * 0.5 - 0.012 - start)
	pill.scale = Vector3(minf(scale, width / float(pill.get_meta(&"width"))), scale, scale)
	pill.position = Vector3(start + width * 0.5, after.position.y, card.face + 0.002)
	card.node.add_child(pill)
	var socket := Socket.new()
	socket.kind = MEMBER
	socket.key = key
	socket.type = XREBlueprintGraph.OBJECT
	socket.center = pill.position
	socket.size = Vector3(maxf(width, 0.02) + 0.006, XREBlueprintPetals.PILL_HEIGHT * scale + 0.006, 0.008)
	socket.visual = pill
	socket.base_scale = pill.scale
	socket.value = member
	card.sockets.append(socket)


## The adapter of [param block]'s target (D-059): a plug in the port at
## [param point], in the colour of objects, with the member's name on it; the
## wire to the object leaves its far end ([method adapter_end]). It is a member
## socket: the trigger on it opens the object's petals, as the name does.
func _add_adapter(card: Card, block: Dictionary, point: Vector3) -> void:
	var shown := XREBlueprintTokens.adapter_text(block)
	var width := XREBlueprintTokens.width(shown)
	var plug := make_token(null, "", width, true, false, false, XREBlueprintGraph.OBJECT, shown)
	plug.position = Vector3(point.x, point.y, card.face)
	card.node.add_child(plug)
	var key := XREBlueprintTokens.member_key(block)
	var socket := Socket.new()
	socket.kind = MEMBER
	socket.key = key if not key.is_empty() else "target"
	socket.type = XREBlueprintGraph.OBJECT
	socket.center = Vector3(point.x - PLUG_GAP - width * 0.5, point.y, card.face + PLUG_DEPTH * 0.5)
	socket.size = Vector3(width + 0.006, 0.026 + 0.006, PLUG_DEPTH + 0.004)
	socket.visual = plug
	socket.base_scale = plug.scale
	socket.value = shown
	# A pin at the far end, as a port has (D-060): a neck and a port of the
	# object's colour, where the wire to the object goes in.
	var depth := PLUG_DEPTH * 0.5
	var edge := -PLUG_GAP - width
	var pin_x := edge - PLUG_GAP - PORT_RADIUS
	var neck := CylinderMesh.new()
	neck.top_radius = 0.0045
	neck.bottom_radius = 0.0045
	neck.height = PLUG_GAP + PORT_RADIUS
	neck.radial_segments = 12
	var neck_mesh := XRERig.create_vr_mesh(neck, _token_shaded(COLORS[XREBlueprintGraph.OBJECT]))
	neck_mesh.rotation.z = PI * 0.5
	neck_mesh.position = Vector3((edge + pin_x) * 0.5, 0, depth)
	plug.add_child(neck_mesh)
	var pin: MeshInstance3D
	if _port_display == XREFeatureSettings.SPHERE:
		pin = XRERig.create_vr_mesh(_sphere_mesh, wire_material(COLORS[XREBlueprintGraph.OBJECT]))
	else:
		pin = XRERig.create_vr_mesh(_port_mesh, material(COLORS[XREBlueprintGraph.OBJECT], true))
		pin.rotation.x = PI * 0.5
	pin.position = Vector3(pin_x, 0, depth)
	plug.add_child(pin)
	plug.set_meta(&"pin", pin)
	socket.center.x -= (PLUG_GAP + PORT_RADIUS * 2.0) * 0.5
	socket.size.x += PLUG_GAP + PORT_RADIUS * 2.0
	plug.set_meta(&"adapter_end", Vector3(point.x + pin_x, point.y, card.face + depth))
	card.sockets.append(socket)


## Where the wire to the object leaves the adapter of block [param id], in the canvas's space; null without one.
func adapter_end(id: int) -> Variant:
	var card := _find_card(id)
	if card == null: return null
	for socket: Socket in card.sockets:
		if socket.kind == MEMBER and socket.visual != null and socket.visual.has_meta(&"adapter_end"):
			return card.node.transform * (socket.visual.get_meta(&"adapter_end") as Vector3)
	return null


## A static wire from the adapter of block [param id], leaving left, free towards the scene object.
func update_adapter_wire(wire: XREGraphWire, id: int, start: Vector3, end: Vector3) -> void:
	wire.update_curve(start, Vector3.LEFT, end, Vector3.ZERO, _front(_find_card(id)))


## A token of [param value] for parameter [param key]: a puck in a slot at the
## right of its row, or after its label if the row has an output; a plug in
## the port, or in the square socket with [param square]. Under a wire a puck
## is faint and a plug is out.
func _add_token(card: Card, key: String, value: Variant, port: int, row: int, after: Label3D, occupied: bool, wired: bool, square: bool, expression: String = "") -> void:
	var plug := _value_mode == XREFeatureSettings.PLUGS
	if plug and wired: return
	var empty := value == null
	# A value typed as an expression shows it as typed (D-063).
	var shown := XREBlueprintTokens.shown(value, key, expression) if not empty else "0.00"
	var width := XREBlueprintTokens.width(shown)
	var point := _row_point(card, row, true)
	var center: Vector3
	if plug:
		center = Vector3(point.x - PLUG_GAP - width * 0.5, point.y, card.face + PLUG_DEPTH * 0.5)
	elif occupied:
		center = Vector3(after.position.x + text_width(after.text, 18) + 0.008 + width * 0.5, point.y, card.face + PUCK_DEPTH * 0.5 + 0.001)
	else:
		center = Vector3(card.width * 0.5 - 0.016 - width * 0.5, point.y, card.face + PUCK_DEPTH * 0.5 + 0.001)
	var token: Node3D
	if empty:
		# Its token taken out (D-054): nothing is drawn (D-058), but the socket
		# still takes a token back where it was.
		token = Node3D.new()
		token.position = center
	else:
		token = make_token(value, key, width, plug, square, wired, -1, shown)
		token.position = center if not plug else Vector3(point.x, point.y, card.face)
	card.node.add_child(token)
	var socket := Socket.new()
	socket.kind = SQUARE if square else TOKEN
	socket.key = key
	socket.type = XREBlueprintTokens.color_type(value, key)
	socket.port = port
	socket.center = center
	socket.size = Vector3(width, XREBlueprintTokens.HEIGHT + 0.004, PLUG_DEPTH if plug else PUCK_DEPTH + 0.004)
	socket.visual = token
	socket.text = token.get_meta(&"text") as Label3D if token.has_meta(&"text") else null
	socket.wired = wired
	socket.value = value
	card.sockets.append(socket)


## A token's mesh, [param width] wide (D-052): a solid piece with rounded
## ends, its sides in its type's color shaded by the view angle, its front
## dark with its value. A puck is centered on its origin; with [param plug] a
## plug's cap is at its origin, in the port, and its body to the left (a
## square cap with [param square]). Under a wire it is [param faded]. Its
## label is its "text" metadata. The body and the front are one mesh each,
## shared by tokens of the same size.
static func make_token(value: Variant, key: String, width: float, plug: bool, square: bool, faded: bool, type: int = -1, shown: String = "") -> Node3D:
	var token := Node3D.new()
	token.name = "Token"
	var border := COLORS[type if type >= 0 else XREBlueprintTokens.color_type(value, key)]
	var alpha := FADED if faded else 1.0
	var height := 0.026 if plug else XREBlueprintTokens.HEIGHT
	var depth := PLUG_DEPTH if plug else PUCK_DEPTH
	var shapes := _token_meshes(width, height, depth, plug, square)
	var body := XRERig.create_vr_mesh(shapes[0], _token_shaded(Color(border, alpha)))
	token.add_child(body)
	var face := XRERig.create_vr_mesh(shapes[1], _token_material(Color(TOKEN_FACE, alpha)))
	face.set_meta(&"face", true)
	token.add_child(face)
	var left := -PLUG_GAP - width * 0.5 if plug else 0.0
	var front := depth * 0.5 + 0.0009 + (depth * 0.5 if plug else 0.0)
	var text := label(shown if not shown.is_empty() else XREBlueprintTokens.text(value, key), 16)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.position = Vector3(left, 0, front + 0.0003)
	text.modulate = Color(1, 1, 1, alpha)
	# Sorted after the face it lies on: from some angles the face's center came nearer and covered it.
	text.sorting_offset = TOKEN_SORTING
	token.add_child(text)
	if value is Color:
		var swatch := QuadMesh.new()
		swatch.size = Vector2(0.012, 0.012)
		var chip := XRERig.create_vr_mesh(swatch, _token_material(value as Color))
		chip.position = Vector3(left - width * 0.5 + height * 0.5 + 0.004, 0, front + 0.0002)
		chip.sorting_offset = TOKEN_SORTING
		token.add_child(chip)
		text.position.x = left + 0.006
	token.set_meta(&"text", text)
	return token


static var _token_shapes: Dictionary[String, Array] = {}


## The body and the front of a token of this size, built once for each size.
static func _token_meshes(width: float, height: float, depth: float, plug: bool, square: bool) -> Array:
	var key := "%d:%d:%d:%s:%s" % [roundi(width * 1000.0), roundi(height * 1000.0), roundi(depth * 1000.0), plug, square]
	if _token_shapes.has(key): return _token_shapes[key]
	var left := -PLUG_GAP - width * 0.5 if plug else 0.0
	var center_z := depth * 0.5 if plug else 0.0
	var body := SurfaceTool.new()
	body.begin(Mesh.PRIMITIVE_TRIANGLES)
	_append_pill(body, Vector3(left, 0, center_z), width, height, depth)
	if plug:
		var neck := CylinderMesh.new()
		neck.top_radius = 0.0045
		neck.bottom_radius = 0.0045
		neck.height = PLUG_GAP
		neck.radial_segments = 12
		body.append_from(neck, 0, Transform3D(Basis(Vector3.BACK, PI * 0.5), Vector3(-PLUG_GAP * 0.5, 0, 0.003)))
		if square:
			var box := BoxMesh.new()
			box.size = Vector3(0.017, 0.017, 0.006)
			body.append_from(box, 0, Transform3D(Basis.IDENTITY, Vector3(0, 0, 0.003)))
		else:
			var disc := CylinderMesh.new()
			disc.top_radius = PORT_RADIUS * 1.05
			disc.bottom_radius = PORT_RADIUS * 1.05
			disc.height = 0.006
			disc.radial_segments = 24
			body.append_from(disc, 0, Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3(0, 0, 0.003)))
	body.generate_normals()
	var face := SurfaceTool.new()
	face.begin(Mesh.PRIMITIVE_TRIANGLES)
	_append_pill(face, Vector3(left, 0, center_z + depth * 0.5 + 0.0004), width - 0.004, height - 0.005, 0.0008)
	var shapes := [body.commit(), face.commit()]
	_token_shapes[key] = shapes
	return shapes


## A pill [param width] by [param height], [param depth] thick, centered at [param center]: a box with round ends.
static func _append_pill(surface: SurfaceTool, center: Vector3, width: float, height: float, depth: float) -> void:
	var middle := BoxMesh.new()
	middle.size = Vector3(maxf(width - height, 0.001), height, depth)
	surface.append_from(middle, 0, Transform3D(Basis.IDENTITY, center))
	for side: float in [-1.0, 1.0]:
		var end := CylinderMesh.new()
		end.top_radius = height * 0.5
		end.bottom_radius = height * 0.5
		end.height = depth
		end.radial_segments = 16
		surface.append_from(end, 0, Transform3D(Basis(Vector3.RIGHT, PI * 0.5), center + Vector3(side * (width - height) * 0.5, 0, 0)))


static func _token_material(color: Color) -> Material:
	if not _token_materials.has(color): _token_materials[color] = material(color, true)
	return _token_materials[color]


static var _token_shader: Shader
static var _shaded_materials: Dictionary[Color, Material] = {}


## Unlit as the cards, but shaded by the view angle, as wires are, so that a token reads as a solid.
static func _token_shaded(color: Color) -> Material:
	if _shaded_materials.has(color): return _shaded_materials[color]
	if _token_shader == null:
		_token_shader = Shader.new()
		_token_shader.code = """
shader_type spatial;
render_mode unshaded, depth_draw_always, shadows_disabled, fog_disabled;
uniform vec4 tint : source_color = vec4(1.0);
void fragment() {
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	ALBEDO = tint.rgb * mix(0.5, 1.0, sqrt(facing));
	ALPHA = tint.a;
}
"""
	var result := ShaderMaterial.new()
	result.shader = _token_shader
	result.render_priority = Material.RENDER_PRIORITY_MAX
	result.set_shader_parameter(&"tint", color)
	_shaded_materials[color] = result
	return result


## Width of [param text] on a card's label of [param font_size], in meters.
static func text_width(text: String, font_size: int) -> float:
	return XRERig.vr_font().get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x * LABEL_PIXEL


## Builds the variables' boxes below the cards and the wires of the Variable sockets to them (D-052).
func _build_shelf(graph: XREBlueprintGraph) -> void:
	_shelf.visible = _variable_mode == XREFeatureSettings.BOXES
	if not _shelf.visible:
		_shelf.rebuild(XREBlueprintGraph.new(), Vector3.ZERO, _value_mode, {})
		_shelf.visible = false
		return
	var left := INF
	var low := INF
	for card: Card in _cards:
		left = minf(left, card.node.position.x - card.width * 0.5)
		low = minf(low, card.node.position.y - card.height * 0.5)
	if is_inf(left):
		left = -0.2
		low = 0.0
	var used: Dictionary[String, bool] = {}
	for block: Dictionary in graph.nodes:
		if block["kind"] in ["get_variable", "set_variable"]: used[str(block["params"]["variable"])] = true
	_shelf.rebuild(graph, Vector3(left + XREBlueprintShelf.BOX_SIZE.x * 0.5, low - XREBlueprintShelf.BELOW - XREBlueprintShelf.BOX_SIZE.y * 0.5, 0.0), _value_mode, used)
	for card: Card in _cards:
		var block := graph.find_node(card.id)
		for index: int in card.sockets.size():
			if card.sockets[index].kind != VARIABLE: continue
			var variable := str((block["params"] as Dictionary).get("variable", ""))
			if not _shelf.has_box(variable): continue
			var type := card.sockets[index].type
			var mesh := create_scene_wire(COLORS[type])
			_variable_wires.append({"card": card, "socket": index, "variable": variable, "mesh": mesh, "normal": mesh.material_override, "lit": wire_material(COLORS[type], LIT_WIRE_GROW),
					"flash": null, "focus": XREBlueprintFocus.NORMAL, "look": -1})


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
		# Its material is the selection's and the focus's ([method _paint_frame]).
		card.frame.set_meta(&"painted", true)
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
	card.frame.set_meta(&"painted", true)
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
## [param grow] thickens the tube by that many meters around, along its normals.
static func wire_material(color: Color, grow: float = 0.0) -> ShaderMaterial:
	if _wire_shader == null:
		_wire_shader = Shader.new()
		_wire_shader.code = """
shader_type spatial;
render_mode unshaded, depth_draw_always, shadows_disabled, fog_disabled;
uniform vec4 tint : source_color = vec4(1.0);
uniform float grow = 0.0;
void vertex() { VERTEX += NORMAL * grow; }
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
	result.set_shader_parameter(&"grow", grow)
	return result


## Fixed-orientation text on the VR layer, independent of scene lighting.
static func label(text: String, font_size: int) -> Label3D:
	var result := XRERig.create_vr_label(font_size, 0.0007)
	result.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	result.render_priority = Material.RENDER_PRIORITY_MAX
	result.text = text
	return result
