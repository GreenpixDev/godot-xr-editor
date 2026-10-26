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
## wait; a Variable socket wired to its variable's box, which stands among the
## cards and moves as they do (D-078, [XREBlueprintBoxes]).
##
## An operator (D-065: Equal and the Operator blocks) is a small card as in
## Unreal: no title, its inputs and their tokens on the left, its symbol in the
## middle, its result on the right; its trash and plus stand above it.
##
## The cards and boxes a ray is on are in focus (D-072, [method set_focus]):
## lit with their ports, details and wires as [constant XREFeatureSettings.FOCUS]
## says, or drawn over everything with them (D-075), the rest darker or
## see-through as [constant XREFeatureSettings.DEFOCUS] says.
##
## A wire to a variable's box or to a scene object may be a link (D-074,
## [XREBlueprintLinks]): a plug in its port with a ring at its far end, the
## variable's name or the object's projection on it as
## [constant XREFeatureSettings.LINK_PREVIEW] says, and the wire hidden — or
## drawn faint from the ring, in focus or always, as
## [constant XREFeatureSettings.LINK_WIRES] says ([method set_link_modes]).
##
## With [constant XREFeatureSettings.WIRE_BENDS] on ([method set_bends_shown],
## D-081) a wire goes smoothly through its bends, drawn as knots, one tube from
## each bend to the next; the ray picks wires and knots too, behind ports and
## the cards' buttons. A drag previews bends here and [method commit_bends]
## keeps them as one edit.

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
## The copy button's color (D-093): a light blue, as neither the plus's white nor the trash's pink.
const COPY_COLOR := Color("a9d4ff")
const TOUCH_RADIUS := 0.035
## Lift only the contact dot towards the controller; ray picking stays unchanged.
const HIT_DOT_OFFSET := 0.012
## Colors of the port types of [XREBlueprintGraph], as the 2D view has them:
## execution, any value, bool, int (lime, apart from float since D-080), float
## (sea green), text, the vectors, object, color.
const COLORS: Array[Color] = [Color("eeeeee"), Color("63c6ea"), Color("e8879b"), Color("b4e05a"), Color("7be5b3"), Color("e5b57b"), Color("89adff"), Color("89adff"), Color("b991eb"), Color("f2d878")]
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
## A link in a port or in a Source or Variable socket (D-074).
const LINK := 6
## The outer radius of a link's ring, in meters, and how much of the wire a
## link hides is seen while it is drawn: faint, it reads as a link's.
const LINK_RING := 0.012
const LINK_SEEN := 0.5
## How near the ray must pass a wire to be on it, in meters, and how much of
## a wire at each end is left to its ports (D-074).
const WIRE_REACH := 0.012
const WIRE_MARGIN := 0.1
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
## The frame of a card that keeps a variable from being deleted, while it flashes (D-079).
const FLASH_FRAME := Color("ff6b7a")
## How much nearer a token's text and swatch sort than its face, in meters.
const TOKEN_SORTING := 0.01
## Pixel size of the cards' labels, for measuring their text.
const LABEL_PIXEL := 0.0007
## Bent wires (D-081): a knot's radius; how near the ray must pass a wire or a
## knot to take it; how far out of a port the wire's direction at the first
## or the last bend is measured from.
const KNOT_RADIUS := 0.005
const WIRE_HIT_RADIUS := 0.01
const KNOT_HIT_RADIUS := 0.012
const BEND_LEAD := 0.05
## Keys of links ([method link_key]) start here, above any edge's index.
const LINK_KEYS := 1 << 20

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
	## A link's (D-074): the block whose field holds it, the socket it is in
	## (-1 a port, [constant SOURCE], [constant VARIABLE]), and where the wire
	## it hides leaves it, in its card's space.
	var flag_block := -1
	var link_kind := -1
	var end := Vector3.ZERO

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
	## The copy button (D-093), or null while cards have none.
	var copy: Node3D
	var copy_point: Vector3
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
	## It keeps a variable from being deleted: its frame flashes (D-079).
	var flash := false

## A wire that bends (D-081): a graph's edge, or a link — a block's wire to
## its object in the scene, or from its Variable socket to the variable's box.
class Wire:
	var from: Card
	var to: Card
	var from_port: int
	var to_port: int
	## Index of the wire's edge in the graph's edges; a link's key ([method link_key]).
	var edge: int
	## A link's block, whose [member stored] keeps its bends; -1 for an edge,
	## whose own [code]vr_bends[/code] do. A Variable link's socket on [member from].
	var owner := -1
	var stored := "vr_bends"
	var socket := -1
	## A wire straight from a variable's box (D-061): [member from] is null and
	## this names the variable of the inline Get Variable it stands for.
	var variable := ""
	## That inline Get Variable's block.
	var getter := -1
	## The link (D-074) in its port, or in a Variable link's socket, which hides the wire; null for none.
	var link: Socket
	var mesh: XREGraphWire
	var normal: Material
	var lit: Material
	var faded := false
	## Its focus (D-072) and how it is painted now: paint and see-through, -1 not yet.
	var focus := XREBlueprintFocus.NORMAL
	var look := -1
	## A Variable link's material while its variable flashes (D-079), or null.
	var flash: Material
	## Where the wire bends (D-081), in the canvas's space, from its output to
	## its input: its edge's bends, or a drag's preview of them. An Array, not
	## a packed one: a drag moves a bend in place every frame without a copy.
	var bends: Array[Vector3] = []
	## The tubes drawn: [member mesh] up to the first bend, then one after each
	## bend shown; and a knot at each. Only [member mesh] while bends are off.
	var pieces: Array[XREGraphWire] = []
	var knots: Array[MeshInstance3D] = []

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
var _hit_copy := false
## Where the last ray met the port it hit, -1 at its bottom to 1 at its top, and the edge that picks.
var _hit_height := 0.0
var _hit_edge := -1
## Edges lit under each hand's ray, or -1.
var _edge_right := -1
var _edge_left := -1
var _frame_material: Material
var _flash_frame: Material
var _hover_right := -1
var _hover_left := -1
var _delete_right := -1
var _delete_left := -1
var _copy_right := -1
var _copy_left := -1
## Whether cards have the copy button ([constant XREFeatureSettings.BLOCK_COPY], D-093).
var _copy_shown := false
var _copy_mesh: ArrayMesh
var _copy_material: Material
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
## Whether the last ray hit a variable's box.
var _hit_box := false
## Sockets under each hand's ray: the card and the socket index, or -1.
var _socket_right := Vector2i(-1, -1)
var _socket_left := Vector2i(-1, -1)
var _boxes: XREBlueprintBoxes
## Links (D-081): wires from Variable sockets to their boxes, rebuilt with the
## cards; wires of blocks to the scene, which [XREBlueprints] adds and removes.
## Not the links of D-074, which may hide them ([member Wire.link]).
var _variable_links: Array[Wire] = []
var _scene_links: Array[Wire] = []
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
## Links (D-074): the settings [constant XREFeatureSettings.LINK_PREVIEW] and
## [constant XREFeatureSettings.LINK_WIRES]; the inputs whose wire from a
## variable's box is a link, [code](card, port) → {"variable", "getter", "type"}[/code];
## the linkable wire the last [method intersect_link_wire] hit, as a ref of [XREBlueprintLinks], and where.
var _link_preview := XREFeatureSettings.OFF
var _link_wires := XREFeatureSettings.OFF
var _linked_inputs: Dictionary[Vector2i, Dictionary] = {}
var _wire_ref: Dictionary = {}
var _wire_point := Vector3.ZERO
static var _ring_mesh: TorusMesh
static var _ring_fill: CylinderMesh
## Wires bend ([constant XREFeatureSettings.WIRE_BENDS], D-081).
var _bends_shown := false
var _knot_mesh: SphereMesh
## What each hand's ray is on: a wire's edge and its knot, -1 for the wire
## itself; -1, -1 for none. A white knot marks where taking the wire adds a bend.
var _bend_right := Vector2i(-1, -1)
var _bend_left := Vector2i(-1, -1)
var _ghost_right: MeshInstance3D
var _ghost_left: MeshInstance3D
## The wire the last ray hit: its edge, its knot (-1 for the tube), the point
## on it, and how many bends come before that point: where a new bend goes.
var _hit_wire := -1
var _hit_bend := -1
var _hit_wire_point := Vector3.ZERO
var _hit_piece := -1


func _init() -> void:
	_selected_material = material(Color.WHITE, true)
	_frame_material = material(Color("65839b"), true)
	_focus_frame = material(XREBlueprintFocus.FRAME, true)
	_flash_frame = material(FLASH_FRAME, true)
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
	_copy_mesh = _make_copy_mesh()
	_copy_material = material(COPY_COLOR, true)
	_preview = create_scene_wire(Color("ffda82"))
	_preview.visible = false
	_boxes = XREBlueprintBoxes.new(_trash_mesh, _trash_material)
	add_child(_boxes)
	_knot_mesh = SphereMesh.new()
	_knot_mesh.radius = KNOT_RADIUS
	_knot_mesh.height = KNOT_RADIUS * 2.0
	_knot_mesh.radial_segments = 12
	_knot_mesh.rings = 6
	var ghost_material := wire_material(Color.WHITE)
	_ghost_right = XRERig.create_vr_mesh(_knot_mesh, ghost_material)
	_ghost_left = XRERig.create_vr_mesh(_knot_mesh, ghost_material)
	for ghost: MeshInstance3D in [_ghost_right, _ghost_left]:
		ghost.visible = false
		add_child(ghost)


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


## Whether cards have the copy button ([constant XREFeatureSettings.BLOCK_COPY],
## D-093); true if that changed, for a rebuild.
func set_copy_shown(shown: bool) -> bool:
	if shown == _copy_shown: return false
	_copy_shown = shown
	return true


## Whether wires bend ([constant XREFeatureSettings.WIRE_BENDS], D-081): drawn
## through their bends, which the ray takes. Off, wires are drawn as before
## and the graph keeps their bends. True if that changed, for a rebuild.
func set_bends_shown(shown: bool) -> bool:
	if shown == _bends_shown: return false
	_bends_shown = shown
	return true


## Whether wires bend ([method set_bends_shown]).
func get_bends_shown() -> bool:
	return _bends_shown


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
	for wire: Wire in _wires: _free_wire(wire)
	for link: Wire in _variable_links: _free_wire(link)
	_cards.clear()
	_wires.clear()
	_variable_links.clear()
	_bend_right = Vector2i(-1, -1)
	_bend_left = Vector2i(-1, -1)
	_ghost_right.visible = false
	_ghost_left.visible = false
	_hover_right = -1
	_hover_left = -1
	_delete_right = -1
	_delete_left = -1
	_copy_right = -1
	_copy_left = -1
	_port_right = Vector2i(-1, -1)
	_port_left = Vector2i(-1, -1)
	_socket_right = Vector2i(-1, -1)
	_socket_left = Vector2i(-1, -1)
	_edge_right = -1
	_edge_left = -1
	# The ports an inline Get Variable's link is in (D-074): the card that has the port shows it.
	_linked_inputs.clear()
	for edge: Dictionary in graph.edges:
		var source := graph.find_node(edge["from"])
		if not is_inline(source) or not XREBlueprintLinks.is_link(source, XREBlueprintLinks.VARIABLE): continue
		var variable := str((source["params"] as Dictionary).get("variable", ""))
		_linked_inputs[Vector2i(edge["to"], edge["to_port"])] = {"variable": variable, "getter": source["id"],
				"type": XREBlueprintGraph.port_type(XREBlueprintGraph.variable_type(graph.find_variable(variable)))}
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
		if _copy_shown:
			# Over the top edge, at the trash's side: on the card it would cover the title.
			# An operator's trash is over the edge already: the copy goes beside it.
			card.copy_point = Vector3(card.trash_point.x + 0.025, card.trash_point.y, card.trash_point.z) if card.compact \
					else Vector3(card.trash_point.x, card.height * 0.5 + 0.016, card.trash_point.z)
			card.copy = Node3D.new()
			card.copy.position = card.copy_point
			card.node.add_child(card.copy)
			card.copy.add_child(XRERig.create_vr_mesh(_copy_mesh, _copy_material))
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
				wire.getter = source["id"]
				if _linked_inputs.has(Vector2i(wire.to.id, wire.to_port)): wire.link = _link_socket(wire.to, wire.to_port, -1)
				inline.append(wire)
			continue
		_add_wire(wire, COLORS[wire.from.output_types[wire.from_port]], edge)
		_wires.append(wire)
	_build_boxes(graph)
	for wire: Wire in inline:
		if not _boxes.has_box(wire.variable): continue
		# In its variable's color, as a wire from an output is in its source's: the
		# port it goes into may take any value, as an operator's does (D-065).
		var color := COLORS[XREBlueprintGraph.port_type(XREBlueprintGraph.variable_type(graph.find_variable(wire.variable)))]
		_add_wire(wire, color, graph.edges[wire.edge])
		# Drawn at all, the wire a link hides is faint (D-074).
		if wire.link != null: set_wire_seen(wire, &"link", LINK_SEEN)
		_wires.append(wire)
	update_wires()
	select_block(_selected)
	_paint_focus()
	_show_link_wires()


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


## Gives [param wire] its tube in [param color] and the bends that
## [param entry] — its edge, or a link's block — keeps under [member Wire.stored].
func _add_wire(wire: Wire, color: Color, entry: Dictionary) -> void:
	wire.mesh = create_scene_wire(color)
	wire.normal = wire.mesh.material_override
	wire.lit = wire_material(color, LIT_WIRE_GROW)
	wire.pieces.append(wire.mesh)
	wire.bends = _bends_of(entry, wire.stored)
	_fit_pieces(wire)


func _free_wire(wire: Wire) -> void:
	for piece: XREGraphWire in wire.pieces:
		remove_child(piece)
		piece.queue_free()
	for knot: MeshInstance3D in wire.knots:
		remove_child(knot)
		knot.queue_free()


## The key of a link (D-081): of block [param id]'s wire to the scene, or with
## [param variable] of its wire from its Variable socket to the variable's box.
static func link_key(id: int, variable: bool = false) -> int:
	return LINK_KEYS + id * 2 + (1 if variable else 0)


## Adds the wire of block [param id] to its object in the scene (D-081): from
## its Target port, its adapter or its Source, as [XREBlueprints] lays it with
## [method update_scene_wire] and the others. It bends as an edge does, with
## the bends [param block] keeps; [method remove_scene_link] takes it away.
func add_scene_link(block: Dictionary, color: Color) -> Wire:
	var link := Wire.new()
	link.owner = block["id"]
	link.edge = link_key(link.owner)
	link.stored = XREBlueprintGraph.SCENE_BENDS
	_add_wire(link, color, block)
	_scene_links.append(link)
	return link


func remove_scene_link(link: Wire) -> void:
	_free_wire(link)
	_scene_links.erase(link)


## Shows or hides [param wire], every tube and knot of it.
func set_wire_shown(wire: Wire, shown: bool) -> void:
	if wire.mesh.visible == shown: return
	for piece: XREGraphWire in wire.pieces: piece.visible = shown
	for knot: MeshInstance3D in wire.knots: knot.visible = shown


## Draws [param wire] with [param shown]: its normal or its lit material, or another.
func light_wire(wire: Wire, shown: Material) -> void:
	if wire.mesh.material_override == shown: return
	for piece: XREGraphWire in wire.pieces: piece.material_override = shown
	for knot: MeshInstance3D in wire.knots: knot.material_override = shown


## Makes every tube and knot of [param wire] see-through for [param layer], as
## [method XREBlueprintFade.set_seen] does: a link's (D-074), the focus's (D-072).
func set_wire_seen(wire: Wire, layer: StringName, seen: float) -> void:
	for piece: XREGraphWire in wire.pieces: XREBlueprintFade.set_layer(piece, layer, seen)
	for knot: MeshInstance3D in wire.knots: XREBlueprintFade.set_layer(knot, layer, seen)


## Draws every tube and knot of [param wire] over the rest of the graph, or as before (D-075).
func raise_wire(wire: Wire, enabled: bool) -> void:
	for piece: XREGraphWire in wire.pieces: XREBlueprintFocus.raise(piece, enabled)
	for knot: MeshInstance3D in wire.knots: XREBlueprintFocus.raise(knot, enabled)


## Gives [param part], a tube or a knot new on [param wire], the look of its
## first tube: its material, whether it is shown, how see-through it is and
## whether it is drawn over everything (D-072, D-074, D-075).
func _match_look(wire: Wire, part: GeometryInstance3D) -> void:
	part.material_override = wire.mesh.material_override
	part.visible = wire.mesh.visible
	var layers: Dictionary = wire.mesh.get_meta(&"seen") if wire.mesh.has_meta(&"seen") else {}
	for layer: StringName in layers: XREBlueprintFade.set_layer(part, layer, float(layers[layer]))
	XREBlueprintFocus.raise(part, wire.mesh.has_meta(&"untop"))


## The bends of [param entry] — an edge, or a link's block — under [param key]
## in the canvas's space (D-081): stored as a block's place is, graph X and Y with VR depth.
func _bends_of(entry: Dictionary, key: String = "vr_bends") -> Array[Vector3]:
	var bends: Array[Vector3] = []
	var stored: Variant = entry.get(key)
	if stored is PackedVector3Array:
		for point: Vector3 in stored as PackedVector3Array:
			var at := Vector2(point.x, point.y) - _offset
			bends.append(Vector3(at.x * PIXEL_SIZE, -at.y * PIXEL_SIZE, point.z))
	return bends


## Gives [param wire] a tube after each bend and a knot at each while bends are
## shown, none while they are off. Only on document changes and when a drag
## adds or takes off a bend, never every frame.
func _fit_pieces(wire: Wire) -> void:
	var count := wire.bends.size() if _bends_shown else 0
	while wire.knots.size() > count:
		var knot := wire.knots.pop_back() as MeshInstance3D
		remove_child(knot)
		knot.queue_free()
		var piece := wire.pieces.pop_back() as XREGraphWire
		remove_child(piece)
		piece.queue_free()
	while wire.knots.size() < count:
		var piece := create_scene_wire(Color.WHITE)
		_match_look(wire, piece)
		wire.pieces.append(piece)
		var knot := XRERig.create_vr_mesh(_knot_mesh, wire.mesh.material_override)
		add_child(knot)
		_match_look(wire, knot)
		wire.knots.append(knot)
	# Knots may stand for other bends now: the rays light theirs again.
	_clear_bend_hover()


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


## Where the box of each of [param graph]'s variables stands, in the canvas's
## space (D-078): where it was put, as a card's place is kept — graph XY in
## [code]vr_position[/code], depth in [code]vr_depth[/code]. A box never put
## anywhere keeps its place in the shelf's row below the cards (D-052).
func _box_places(graph: XREBlueprintGraph) -> Dictionary[String, Vector3]:
	var left := INF
	var low := INF
	for card: Card in _cards:
		left = minf(left, card.node.position.x - card.width * 0.5)
		low = minf(low, card.node.position.y - card.height * 0.5)
	if is_inf(left):
		left = -0.2
		low = 0.0
	var row := Vector3(left + XREBlueprintBoxes.BOX_SIZE.x * 0.5, low - XREBlueprintBoxes.BELOW - XREBlueprintBoxes.BOX_SIZE.y * 0.5, 0.0)
	var places: Dictionary[String, Vector3] = {}
	for index: int in graph.variables.size():
		var variable: Dictionary = graph.variables[index]
		var placed: Variant = variable.get("vr_position")
		if placed is Vector2:
			var point: Vector2 = (placed as Vector2) - _offset
			places[str(variable["name"])] = Vector3(point.x * PIXEL_SIZE, -point.y * PIXEL_SIZE, float(variable.get("vr_depth", 0.0)))
		else: places[str(variable["name"])] = row + Vector3.RIGHT * XREBlueprintBoxes.SPACING * index
	return places


## Moves the existing cards and boxes to the graph's placement, and bends its
## wires as it does (D-081), when only placement changed.
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
		_orient(card)
	if _boxes.visible: _boxes.place(_box_places(graph))
	for wire: Wire in _wires: _reload_bends(graph, wire)
	for link: Wire in _variable_links: _reload_bends(graph, link)
	for link: Wire in _scene_links: _reload_bends(graph, link)
	update_wires()
	return true


## Gives [param wire] the bends [param graph] keeps for it, on its edge or its link's block.
func _reload_bends(graph: XREBlueprintGraph, wire: Wire) -> void:
	var entry: Dictionary = graph.find_node(wire.owner) if wire.owner >= 0 else (graph.edges[wire.edge] if wire.edge < graph.edges.size() else {})
	wire.bends = _bends_of(entry, wire.stored)
	_fit_pieces(wire)


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


## Commits the place of the box of [param variable] (D-078), previewed by
## [method preview_box_move], to the graph's history, as [method commit_move] a card's.
func commit_box_move(document: XREBlueprintDocument, variable: String) -> bool:
	if not _boxes.has_box(variable): return false
	var point := _boxes.box_point(variable)
	var state := document.graph.snapshot()
	for entry: Dictionary in state["variables"]:
		if entry["name"] != variable: continue
		entry["vr_position"] = Vector2(point.x, -point.y) / PIXEL_SIZE + _offset
		entry["vr_depth"] = point.z
	return document.perform(document.commit.bind("Move Variable", state), &"vr_graph")


## Shows the box of [param variable] at [param point] (the canvas's space) without editing the graph (D-078).
func preview_box_move(variable: String, point: Vector3) -> void:
	_boxes.move_box(variable, point)
	update_wires()


## Keeps a captured point of the box of [param variable] on the rod (D-078):
## [param contact] (global) is where [param local_contact], a point of the
## box, goes. A box keeps the graph's orientation, as a cuboid card does.
func preview_box_grab(variable: String, contact: Vector3, local_contact: Vector3) -> void:
	preview_box_move(variable, to_local(contact) - local_contact)


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
		# A bent wire (D-081) covers the input if one of its tubes does.
		var faded := false
		if count > 0 and wire.mesh.visible:
			for piece: XREGraphWire in wire.pieces:
				if XREBlueprintFade.covers(eye, targets, count, piece.global_transform * piece.get_aabb()):
					faded = true
					break
		if faded == wire.faded: continue
		wire.faded = faded
		set_wire_seen(wire, &"cover", XREBlueprintFade.SEEN if faded else 1.0)
	_boxes.fade_covering(eye, targets, count)


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
## only); cuboids keep the graph's orientation.
func _orient(card: Card) -> void:
	if _display == XREFeatureSettings.CUBOID: card.node.basis = Basis.IDENTITY
	elif _faces_user: card.node.global_basis = XREBlueprintPetals.face(card.node.global_position, _head_position, Vector3.UP)


## Keeps a captured point on the rod while its upright panel faces the user.
func preview_grab(id: int, contact: Vector3, local_contact: Vector3, head: Vector3) -> void:
	if _display == XREFeatureSettings.CUBOID:
		# A solid keeps the graph's orientation: only the captured point follows the rod.
		var held := _find_card(id)
		if held == null: return
		held.node.global_transform = Transform3D(global_basis, contact - global_basis * local_contact)
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
	update_wires()


## Current card pose in workspace coordinates, including a grip preview.
func get_block_transform(id: int) -> Transform3D:
	var card := _find_card(id)
	return card.node.transform if card != null else Transform3D.IDENTITY


## Whether the canvas shows a card for block [param id].
func has_block(id: int) -> bool:
	return _find_card(id) != null


## Current preview position of a card in workspace coordinates.
func get_block_position(id: int) -> Vector3:
	var card := _find_card(id)
	return card.node.position if card != null else Vector3.ZERO


## Highlights a card without changing the scene selection.
func select_block(id: int) -> void:
	_selected = id
	for card: Card in _cards: _paint_frame(card)


## A selected card's frame is white, one in focus is [constant XREBlueprintFocus.FRAME]
## with Focus on (D-072), darker out of focus with Defocus on Dim; one that
## keeps a variable from being deleted flashes [constant FLASH_FRAME] (D-079).
func _paint_frame(card: Card) -> void:
	var base := _flash_frame if card.flash else _selected_material if card.id == _selected else _focus_frame if card.look.x == XREBlueprintFocus.LIT else _frame_material
	# A flash isn't darkened out of focus: it is there to be seen.
	var paint := card.look.x if card.look.x == XREBlueprintFocus.TOP or (card.look.x == XREBlueprintFocus.DARK and not card.flash) else XREBlueprintFocus.PLAIN
	card.frame.material_override = XREBlueprintFocus.variant(base, paint)


## Switches focus (D-072) to [param focus], a value of [constant XREFeatureSettings.FOCUS],
## and [param defocus], one of [constant XREFeatureSettings.DEFOCUS]: the graph
## is painted again. False if nothing changed.
func set_focus_modes(focus: StringName, defocus: StringName) -> bool:
	if focus == _focus_mode and defocus == _defocus_mode: return false
	_focus_mode = focus
	_defocus_mode = defocus
	for card: Card in _cards: card.look = Vector4i(-1, 0, 0, 0)
	for wire: Wire in _wires: wire.look = -1
	for link: Wire in _variable_links: link.look = -1
	_boxes.forget_looks()
	_paint_focus()
	return true


## The focus settings, as [method set_focus_modes] takes them.
func get_focus_modes() -> Array[StringName]:
	return [_focus_mode, _defocus_mode]


## Switches links (D-074) to [param preview], a value of [constant XREFeatureSettings.LINK_PREVIEW],
## which takes effect on the next [method rebuild], and [param wires], one of
## [constant XREFeatureSettings.LINK_WIRES], which does at once. True if a rebuild is needed.
func set_link_modes(preview: StringName, wires: StringName) -> bool:
	_link_wires = wires
	_show_link_wires()
	if preview == _link_preview: return false
	_link_preview = preview
	return true


## The link settings, as [method set_link_modes] takes them.
func get_link_modes() -> Array[StringName]:
	return [_link_preview, _link_wires]


## Whether the wire a link on card [param id] hides is drawn now, by
## [constant XREFeatureSettings.LINK_WIRES]: always, never, or while the card —
## or the box of its [param variable], if it has one — is in focus (D-072).
func link_wire_shown(id: int, variable: String = "") -> bool:
	if _link_wires == XREFeatureSettings.ON: return true
	if _link_wires != XREFeatureSettings.ON_FOCUS: return false
	return _in_focus(id) or (not variable.is_empty() and (variable == _focus_box or variable == _focus_other_box))


## Shows or hides the wires links hide, as [method link_wire_shown] says.
func _show_link_wires() -> void:
	for wire: Wire in _wires:
		if wire.link != null: set_wire_shown(wire, link_wire_shown(wire.to.id, wire.variable))
	for link: Wire in _variable_links:
		if link.link != null: set_wire_shown(link, link.flash != null or link_wire_shown(link.from.id, link.variable))


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
	_show_link_wires()


## How block [param id] is in focus: [constant XREBlueprintFocus.FOCUSED],
## [constant XREBlueprintFocus.OUT], or [constant XREBlueprintFocus.NORMAL] while nothing is.
func focus_state(id: int) -> int:
	if not _focus_any: return XREBlueprintFocus.NORMAL
	return XREBlueprintFocus.FOCUSED if _in_focus(id) else XREBlueprintFocus.OUT


## How what is in focus [param state] is painted under the settings: lit in
## focus with Focus on, darker out of it with Defocus on Dim.
func focus_paint(state: int) -> int:
	if state == XREBlueprintFocus.FOCUSED and _focus_mode == XREFeatureSettings.ON: return XREBlueprintFocus.LIT
	if state == XREBlueprintFocus.FOCUSED and _focus_mode == XREFeatureSettings.FRONT: return XREBlueprintFocus.TOP
	if state == XREBlueprintFocus.OUT and _defocus_mode == XREFeatureSettings.DIM: return XREBlueprintFocus.DARK
	return XREBlueprintFocus.PLAIN


## How much of what is in focus [param state] is seen: less out of focus with Defocus on Transparent.
func focus_seen(state: int) -> float:
	return XREBlueprintFocus.SEEN if state == XREBlueprintFocus.OUT and _defocus_mode == XREFeatureSettings.TRANSPARENT else 1.0


## Whether something is drawn over everything in focus with Focus on Front
## (D-075): then the hands' rays are drawn over it.
func is_front_focused() -> bool:
	return _focus_mode == XREFeatureSettings.FRONT and _focus_any


func _in_focus(id: int) -> bool:
	return id >= 0 and (id == _focus_cards.x or id == _focus_cards.y or id == _focus_cards.z)


## Works out what is in focus and paints what changed (D-072). Run on a change
## of focus, of the graph or of the ports a wire may end on, never every frame.
## In focus: the cards and boxes asked for and the wires on them. Out of it:
## the rest, but the far ends of those wires — a port, a socket, a box — and
## the ports a wire being drawn may end on stay as they are.
func _paint_focus() -> void:
	var used := _focus_mode != XREFeatureSettings.OFF or _defocus_mode != XREFeatureSettings.OFF
	var any := false
	if used:
		for card: Card in _cards: any = any or _in_focus(card.id)
		any = any or _boxes.has_box(_focus_box) or _boxes.has_box(_focus_other_box)
	_focus_any = any
	for card: Card in _cards:
		card.focus = (XREBlueprintFocus.FOCUSED if _in_focus(card.id) else XREBlueprintFocus.OUT) if any else XREBlueprintFocus.NORMAL
		card.keep_ports = 0
		card.keep_sockets = 0
	var boxes: Dictionary[String, int] = {}
	if any:
		for variable: String in [_focus_box, _focus_other_box]:
			if _boxes.has_box(variable): boxes[variable] = XREBlueprintFocus.FOCUSED
	for wire: Wire in _wires:
		var focused: bool = any and ((wire.from != null and wire.from.focus == XREBlueprintFocus.FOCUSED) or wire.to.focus == XREBlueprintFocus.FOCUSED
				or (wire.from == null and boxes.get(wire.variable, XREBlueprintFocus.NORMAL) == XREBlueprintFocus.FOCUSED))
		wire.focus = XREBlueprintFocus.FOCUSED if focused else XREBlueprintFocus.OUT if any else XREBlueprintFocus.NORMAL
		if not focused: continue
		_keep_port(wire.to, wire.to_port, true)
		if wire.from != null: _keep_port(wire.from, wire.from_port, false)
		elif not boxes.has(wire.variable): boxes[wire.variable] = XREBlueprintFocus.KEPT
	for link: Wire in _variable_links:
		var focused: bool = any and (link.from.focus == XREBlueprintFocus.FOCUSED or boxes.get(link.variable, XREBlueprintFocus.NORMAL) == XREBlueprintFocus.FOCUSED)
		link.focus = XREBlueprintFocus.FOCUSED if focused else XREBlueprintFocus.OUT if any else XREBlueprintFocus.NORMAL
		if not focused: continue
		if link.from.focus != XREBlueprintFocus.FOCUSED: link.from.keep_sockets |= 1 << link.socket
		if not boxes.has(link.variable): boxes[link.variable] = XREBlueprintFocus.KEPT
	if any and _compatible_type >= 0:
		for card: Card in _cards:
			if card.focus != XREBlueprintFocus.OUT: continue
			for index: int in card.ports.size():
				if _compatible(card, index): card.keep_ports |= 1 << index
	for card: Card in _cards: _look_card(card)
	for wire: Wire in _wires: _look_wire(wire)
	for link: Wire in _variable_links: _look_link(link)
	for index: int in _boxes.box_count():
		var state: int = boxes.get(_boxes.box_name(index), XREBlueprintFocus.OUT if any else XREBlueprintFocus.NORMAL)
		_boxes.paint_box(index, state, focus_paint(state), focus_seen(state))


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
	set_wire_seen(wire, &"focus", seen)
	_paint_wire(wire)


## The wire's material, on every tube and knot: thicker if a click would detach
## it or the ray is on it (D-081), then lit or darker by its focus (D-072).
func _paint_wire(wire: Wire) -> void:
	light_wire(wire, XREBlueprintFocus.variant(wire.lit if is_edge_lit(wire.edge) else wire.normal, focus_paint(wire.focus)))
	raise_wire(wire, focus_paint(wire.focus) == XREBlueprintFocus.TOP)


func _look_link(link: Wire) -> void:
	var seen := focus_seen(link.focus)
	var look := focus_paint(link.focus) * 2 + (1 if seen < 1.0 else 0)
	if look == link.look: return
	link.look = look
	set_wire_seen(link, &"focus", seen)
	_paint_link(link)


## A Variable wire's material, on every tube and knot: white while its variable
## flashes, thicker under a ray on its socket or on itself (D-081), then lit or
## darker by its focus (D-072).
func _paint_link(link: Wire) -> void:
	var base: Material = link.flash if link.flash != null else link.lit if is_socket_hovered(link.from.id, link.socket) or is_edge_lit(link.edge) else link.normal
	light_wire(link, XREBlueprintFocus.variant(base, focus_paint(link.focus)))
	raise_wire(link, focus_paint(link.focus) == XREBlueprintFocus.TOP)


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
## [param edge] is the wire to light: the one on that port ([method get_hit_edge])
## or the one the ray is on ([method get_hit_wire]), or -1.
## A variable's box under that ray is let go too, unless [param keep_box];
## the copy button grows with [param copy].
func hover_actions(id: int, plus: bool, trash: bool, right: bool, port: int = -1, input: bool = false, edge: int = -1, keep_box: bool = false, copy: bool = false) -> void:
	if not keep_box: _boxes.hover(-1, -1, right)
	hover_plus(id if plus else -1, right)
	_hover_copy(id if copy else -1, right)
	_hover_port(id, port, input, right)
	_hover_edge(edge, right)
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
	# Wires to the scene are lit by [XREBlueprints], which asks [method is_edge_lit].
	_paint_links()


## Paints the Variable links (D-081): lit with their socket or themselves under a ray (D-061), by their focus (D-072).
func _paint_links() -> void:
	for link: Wire in _variable_links: _paint_link(link)


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
	if input and wire.from == null: return _boxes.box_point(wire.variable)
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


func _hover_copy(id: int, right: bool) -> void:
	if id == (_copy_right if right else _copy_left): return
	if right: _copy_right = id
	else: _copy_left = id
	for card: Card in _cards:
		if card.copy != null: card.copy.scale = Vector3.ONE * (HOVER_SCALE if card.id == _copy_right or card.id == _copy_left else 1.0)


## Two squares, one over the other's corner: the copy button (D-093).
static func _make_copy_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for corner: Vector3 in [Vector3(-0.0025, 0.0025, 0), Vector3(0.0025, -0.0025, 0.0005)]:
		for side: float in [-1.0, 1.0]:
			_append_trash_bar(surface, Vector3(0.012, 0.0018, 0.002), corner + Vector3(0, side * 0.0051, 0))
			_append_trash_bar(surface, Vector3(0.0018, 0.012, 0.002), corner + Vector3(side * 0.0051, 0, 0))
	return surface.commit()


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
	_hit_copy = false
	_hit_edge = -1
	_hit_height = 0.0
	_hit_socket = -1
	_hit_finished = false
	_hit_box = false
	_hit_wire = -1
	_hit_bend = -1
	_hit_piece = -1
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
		var body := _box_distance(card_origin, card_direction, card.bounds, nearest)
		if body >= 0:
			nearest = body
			proximity = INF
			_hit_id = card.id
			_hit_port = -1
			_hit_input = false
			_hit_plus = false
			_hit_delete = false
			_hit_copy = false
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
				_hit_copy = false
		var trash_size := Vector3.ONE * PLUS_RADIUS * card.trash.scale.x * 2.0
		var trash_hit := _box_distance(card_origin, card_direction, AABB(card.trash_point - trash_size * 0.5, trash_size), nearest)
		if trash_hit >= 0:
			nearest = trash_hit
			_hit_id = card.id
			_hit_port = -1
			_hit_plus = false
			_hit_delete = true
			_hit_copy = false
		if card.copy != null:
			var copy_size := Vector3.ONE * PLUS_RADIUS * card.copy.scale.x * 2.0
			var copy_hit := _box_distance(card_origin, card_direction, AABB(card.copy_point - copy_size * 0.5, copy_size), nearest)
			if copy_hit >= 0:
				nearest = copy_hit
				_hit_id = card.id
				_hit_port = -1
				_hit_plus = false
				_hit_delete = false
				_hit_copy = true
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
				_hit_copy = false
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
				_hit_copy = false
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
			_hit_copy = false
	# A wire in front of a card's face takes the ray from it; ports, sockets and
	# the cards' buttons keep it. Not while a wire is drawn: it ends on ports.
	var drawing := _preview.visible or _compatible_type >= 0
	if _bends_shown and not drawing and _hit_port < 0 and _hit_socket < 0 and not _hit_plus and not _hit_delete and not _hit_copy:
		var wire_hit := _intersect_wires(local_origin, local_direction, nearest)
		if wire_hit >= 0:
			nearest = wire_hit
			_hit_id = -1
	if _boxes.visible:
		var box := _boxes.intersect_ray(local_origin, local_direction, nearest)
		if box >= 0:
			nearest = box
			_hit_box = true
			_hit_id = -1
			_hit_port = -1
			_hit_socket = -1
			_hit_plus = false
			_hit_delete = false
			_hit_copy = false
			_hit_wire = -1
			_hit_bend = -1
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
	return nearest if _hit_id >= 0 or _hit_wire >= 0 else -1.0


## The nearest wire or knot the ray passes within [constant WIRE_HIT_RADIUS] or
## [constant KNOT_HIT_RADIUS] of, nearer than [param maximum], in the canvas's
## space (D-081); -1 for none. Each tube's bounds sort out the wires far from
## the ray first. A knot on the wire the ray is on wins over its tube.
func _intersect_wires(origin: Vector3, direction: Vector3, maximum: float) -> float:
	var nearest := _intersect_tubes(_wires, origin, direction, maximum)
	nearest = _intersect_tubes(_variable_links, origin, direction, nearest)
	nearest = _intersect_tubes(_scene_links, origin, direction, nearest)
	var reach := minf(nearest + KNOT_HIT_RADIUS * 2.0, maximum) if _hit_wire >= 0 else maximum
	var knot_hit := _intersect_knots(_wires, origin, direction, reach, INF)
	knot_hit = _intersect_knots(_variable_links, origin, direction, reach, knot_hit)
	knot_hit = _intersect_knots(_scene_links, origin, direction, reach, knot_hit)
	if knot_hit < INF: return knot_hit
	return nearest if _hit_wire >= 0 else -1.0


## The nearest tube of [param wires] the ray passes near, nearer than
## [param nearest], which is returned if none is: it notes what it hits.
func _intersect_tubes(wires: Array[Wire], origin: Vector3, direction: Vector3, nearest: float) -> float:
	for wire: Wire in wires:
		if not wire.mesh.visible: continue
		for index: int in wire.pieces.size():
			var piece := wire.pieces[index]
			if _box_distance(origin, direction, piece.custom_aabb.grow(WIRE_HIT_RADIUS), nearest) < 0: continue
			var from := piece.get_point(0)
			for sample: int in range(1, piece.get_point_count()):
				var to := piece.get_point(sample)
				var closest := _ray_segment(origin, direction, from, to)
				var on_wire := from.lerp(to, closest.y)
				if closest.x < nearest and (origin + direction * closest.x).distance_squared_to(on_wire) <= WIRE_HIT_RADIUS * WIRE_HIT_RADIUS:
					nearest = closest.x
					_hit_wire = wire.edge
					_hit_piece = index
					_hit_wire_point = on_wire
				from = to
	return nearest


## The nearest knot of [param wires] the ray passes near, no farther than
## [param reach] and nearer than [param nearest], which is returned if none is.
func _intersect_knots(wires: Array[Wire], origin: Vector3, direction: Vector3, reach: float, nearest: float) -> float:
	for wire: Wire in wires:
		if not wire.mesh.visible: continue
		for index: int in wire.knots.size():
			var center := wire.bends[index]
			var along := maxf((center - origin).dot(direction) / direction.length_squared(), 0.0)
			var radius := KNOT_HIT_RADIUS * wire.knots[index].scale.x
			if along > reach or along >= nearest or (origin + direction * along).distance_squared_to(center) > radius * radius: continue
			nearest = along
			_hit_wire = wire.edge
			_hit_bend = index
			_hit_piece = index
			_hit_wire_point = center
	return nearest


## Where the ray from [param origin] along [param direction] passes nearest to
## the segment from [param a] to [param b]: the ray's parameter, not behind its
## origin, and the segment's, 0 at [param a] to 1 at [param b].
static func _ray_segment(origin: Vector3, direction: Vector3, a: Vector3, b: Vector3) -> Vector2:
	var along := b - a
	var offset := a - origin
	var dd := direction.dot(direction)
	var du := direction.dot(along)
	var uu := along.dot(along)
	var dw := direction.dot(offset)
	var uw := along.dot(offset)
	var denominator := dd * uu - du * du
	var s := clampf((dw * du - uw * dd) / denominator, 0.0, 1.0) if denominator > 1e-12 else 0.0
	var t := (dw + s * du) / dd
	if t < 0.0:
		# The segment lies behind the origin: its point nearest the origin.
		t = 0.0
		s = clampf(-uw / uu, 0.0, 1.0) if uu > 1e-12 else 0.0
	return Vector2(t, s)


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
	if _hit_box: return _boxes.get_hit_color()
	var card := _find_card(_hit_id)
	if card == null: return null
	if _hit_socket >= 0 and _hit_socket < card.sockets.size():
		var socket := card.sockets[_hit_socket]
		if socket.value is Color: return socket.value
		return MEMBER_COLOR if socket.kind == MEMBER else COLORS[socket.type]
	if _hit_port >= 0: return COLORS[card.input_types[_hit_port] if _hit_input else card.output_types[_hit_port]]
	if _hit_plus: return Color.WHITE
	if _hit_delete: return (_trash_material as BaseMaterial3D).albedo_color
	if _hit_copy: return COPY_COLOR
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


## Whether the last ray hit a variable's box ([method get_boxes]).
func get_hit_box() -> bool:
	return _hit_box


## The variables' boxes.
func get_boxes() -> XREBlueprintBoxes:
	return _boxes


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
	_paint_links()


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


## Where the plus of card [param id] is, global, shown or not: where the
## block menu's suggestions or ring open from it (D-093).
func plus_position(id: int) -> Vector3:
	var card := _find_card(id)
	if card == null: return global_position
	return card.node.global_transform * card.plus_point


## Whether the last ray hit the card's copy button (D-093).
func get_hit_copy() -> bool:
	return _hit_copy


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
	for wire: Wire in _wires: _update_wire(wire)
	for link: Wire in _variable_links: _update_variable_link(link)


## Lays the wire of [param link]'s Variable socket to its variable's box.
func _update_variable_link(link: Wire) -> void:
	# A link's wire leaves its ring, not the socket (D-074).
	var at := link.from.node.transform * (link.link.end if link.link != null else link.from.sockets[link.socket].center)
	var end := _boxes.box_end(link.variable, at)
	_lay(link, at, Vector3.LEFT, end[0], end[1], _front(link.from))


## Lays [param wire] from its output, or its variable's box, to its input.
func _update_wire(wire: Wire) -> void:
	if wire.owner >= 0:
		# A link: the Variable one lays itself; [XREBlueprints] lays those to the scene.
		if wire.socket >= 0: _update_variable_link(wire)
		return
	var end := _port_position(wire.to, wire.to_port, true)
	var end_direction := _port_direction(wire.to, true)
	var start: Vector3
	var start_direction: Vector3
	var front: Vector3
	if wire.from == null:
		# A link's wire goes into its ring, not the port (D-074).
		if wire.link != null: end = wire.to.node.transform * wire.link.end
		var box := _boxes.box_end(wire.variable, end)
		start = box[0]
		start_direction = box[1]
		front = _front(wire.to)
	else:
		start = _port_position(wire.from, wire.from_port, false)
		start_direction = _port_direction(wire.from, false)
		front = (_front(wire.from) + _front(wire.to)).normalized()
	_lay(wire, start, start_direction, end, end_direction, front)


## Lays [param wire] from [param start], leaving along [param start_direction],
## to [param end], arriving from [param end_direction] (zero: free), as
## [method XREGraphWire.update_curve] does. Bent (D-081), a tube runs to each
## bend and on to the next, with no loop: at a bend the wire runs from the
## point before it towards the point after it, the first and the last measured
## [constant BEND_LEAD] out of their ends, so it goes through the knot without a corner.
func _lay(wire: Wire, start: Vector3, start_direction: Vector3, end: Vector3, end_direction: Vector3, front: Vector3) -> void:
	var count := wire.knots.size()
	if count == 0:
		wire.mesh.update_curve(start, start_direction, end, end_direction, front)
		return
	var from := start
	var from_direction := start_direction
	for index: int in count:
		var point := wire.bends[index]
		var before: Vector3 = start + start_direction * BEND_LEAD if index == 0 else wire.bends[index - 1]
		var after: Vector3 = end + end_direction * BEND_LEAD if index == count - 1 else wire.bends[index + 1]
		var tangent := (after - before).normalized()
		wire.pieces[index].update_curve(from, from_direction, point, -tangent, Vector3.ZERO)
		wire.knots[index].position = point
		from = point
		from_direction = tangent
	wire.pieces[count].update_curve(from, from_direction, end, end_direction, Vector3.ZERO)


## The wire the last ray hit (D-081): its graph edge or a link's key ([method link_key]), or -1.
func get_hit_wire() -> int:
	return _hit_wire


## The knot the last ray hit on [method get_hit_wire]: its bend, or -1 for the tube.
func get_hit_bend() -> int:
	return _hit_bend


## Where the last ray met [method get_hit_wire], in the canvas's space: its knot's center or the point on its tube.
func get_hit_wire_point() -> Vector3:
	return _hit_wire_point


## How many bends of [method get_hit_wire] come before [method get_hit_wire_point]: where a bend added there goes.
func get_hit_piece() -> int:
	return _hit_piece


## How many bends the wire of graph edge [param edge] is drawn with now.
func bend_count(edge: int) -> int:
	var wire := _find_wire(edge)
	return wire.bends.size() if wire != null else 0


## Where the wire of graph edge [param edge] bends now, in the canvas's space: a copy.
func wire_bends(edge: int) -> Array[Vector3]:
	var bends: Array[Vector3] = []
	var wire := _find_wire(edge)
	if wire != null: bends.assign(wire.bends)
	return bends


## The tubes the wire of graph edge [param edge] is drawn with, from its output.
func wire_pieces(edge: int) -> Array[XREGraphWire]:
	var pieces: Array[XREGraphWire] = []
	var wire := _find_wire(edge)
	if wire != null: pieces.assign(wire.pieces)
	return pieces


## The knot of bend [param bend] of the wire of graph edge [param edge], or null.
func wire_knot(edge: int, bend: int) -> MeshInstance3D:
	var wire := _find_wire(edge)
	return wire.knots[bend] if wire != null and bend >= 0 and bend < wire.knots.size() else null


## Adds a bend at [param point] to the wire of graph edge [param edge], as its
## bend number [param index], until [method commit_bends] or [method reset_bends]:
## the graph is unchanged. Returns the new bend's index; -1 while bends are off
## or the wire has [constant XREBlueprintGraph.MAX_BENDS].
func insert_bend(edge: int, index: int, point: Vector3) -> int:
	var wire := _find_wire(edge)
	if wire == null or not _bends_shown or wire.bends.size() >= XREBlueprintGraph.MAX_BENDS: return -1
	index = clampi(index, 0, wire.bends.size())
	wire.bends.insert(index, point)
	_fit_pieces(wire)
	_update_wire(wire)
	return index


## Moves bend [param index] of the wire of graph edge [param edge] to [param point]:
## a drag's preview, every frame, which allocates nothing.
func preview_bend(edge: int, index: int, point: Vector3) -> void:
	var wire := _find_wire(edge)
	if wire == null or index < 0 or index >= wire.bends.size(): return
	wire.bends[index] = point
	_update_wire(wire)


## Takes bend [param index] off the wire of graph edge [param edge], or all its
## bends with -1, until [method commit_bends] or [method reset_bends].
func remove_bend(edge: int, index: int = -1) -> void:
	var wire := _find_wire(edge)
	if wire == null or index >= wire.bends.size(): return
	if index < 0: wire.bends.clear()
	else: wire.bends.remove_at(index)
	_fit_pieces(wire)
	_update_wire(wire)


## Draws the wire of graph edge [param edge] with the bends [param graph] has: ends a preview.
func reset_bends(graph: XREBlueprintGraph, edge: int) -> void:
	var wire := _find_wire(edge)
	if wire == null: return
	_reload_bends(graph, wire)
	_update_wire(wire)


## Keeps the bends the wire of graph edge [param edge], or link of that key,
## is drawn with in the graph — on the edge or the link's block — as one edit
## called [param title]; false if the document refused it.
func commit_bends(document: XREBlueprintDocument, edge: int, title: String) -> bool:
	var wire := _find_wire(edge)
	if wire == null: return false
	var state := document.graph.snapshot()
	var entry: Dictionary = {}
	if wire.owner < 0:
		var edges: Array = state["edges"]
		if edge < edges.size(): entry = edges[edge]
	else:
		for block: Dictionary in state["nodes"]:
			if block["id"] == wire.owner: entry = block
	if entry.is_empty(): return false
	if wire.bends.is_empty():
		entry.erase(wire.stored)
	else:
		var stored := PackedVector3Array()
		for point: Vector3 in wire.bends:
			var at := Vector2(point.x, -point.y) / PIXEL_SIZE + _offset
			stored.append(Vector3(at.x, at.y, point.z))
		entry[wire.stored] = stored
	return document.perform(document.commit.bind(title, state), &"vr_graph")


## Shows what the ray of the [param right] hand, or the other's, is on
## (D-081): bend [param bend] of the wire of graph edge [param edge] grows its
## knot; with bend -1 a white knot marks [param point], where taking the wire
## adds a bend; edge -1 for neither.
func hover_bend(edge: int, bend: int, point: Vector3, right: bool) -> void:
	var ghost := _ghost_right if right else _ghost_left
	ghost.visible = edge >= 0 and bend < 0
	if ghost.visible: ghost.position = point
	var key := Vector2i(edge, bend)
	var before := _bend_right if right else _bend_left
	if key == before: return
	if right: _bend_right = key
	else: _bend_left = key
	_scale_knot(before)
	_scale_knot(key)


## Whether knot [param bend] of the wire of graph edge [param edge] is under a hand's ray.
func is_bend_hovered(edge: int, bend: int) -> bool:
	return bend >= 0 and (Vector2i(edge, bend) == _bend_right or Vector2i(edge, bend) == _bend_left)


## Whether the white knot of where a bend would go shows under the [param right] hand's ray, or the other's.
func is_ghost_shown(right: bool) -> bool:
	return (_ghost_right if right else _ghost_left).visible


func _scale_knot(key: Vector2i) -> void:
	var knot := wire_knot(key.x, key.y)
	if knot != null: knot.scale = Vector3.ONE * (HOVER_SCALE if is_bend_hovered(key.x, key.y) else 1.0)


## Lets go of the knots the rays lit: they may stand for other bends now.
func _clear_bend_hover() -> void:
	var right := _bend_right
	var left := _bend_left
	_bend_right = Vector2i(-1, -1)
	_bend_left = Vector2i(-1, -1)
	_scale_knot(right)
	_scale_knot(left)


## The wire of graph edge [param edge], or the link of that key.
func _find_wire(edge: int) -> Wire:
	var found := _find_in(_wires, edge)
	if found == null: found = _find_in(_variable_links, edge)
	if found == null: found = _find_in(_scene_links, edge)
	return found


static func _find_in(wires: Array[Wire], edge: int) -> Wire:
	for wire: Wire in wires:
		if wire.edge == edge: return wire
	return null


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
func update_socket_wire(link: Wire, id: int, kind: int, end: Vector3) -> void:
	_lay(link, socket_position(id, kind), Vector3.LEFT, end, Vector3.ZERO, _front(_find_card(id)))


## Lights the cards whose Variable socket is wired to the box of
## [param variable] — a variable in use that can't be deleted — their frames
## and their wires, drawn even where a link hides them (D-079); or puts them back.
func flash_variable(variable: String, lit: bool) -> void:
	for link: Wire in _variable_links:
		if link.variable != variable: continue
		link.flash = wire_material(Color.WHITE, LIT_WIRE_GROW * 2.0) if lit else null
		_paint_link(link)
		link.from.flash = lit
		_paint_frame(link.from)
	_show_link_wires()


## A static Target wire ([method add_scene_link]): from its input port, leaving left, free towards the scene object.
func update_scene_wire(link: Wire, id: int, port: int, end: Vector3) -> void:
	_lay(link, port_position(id, port, true), port_direction(id, true), end, Vector3.ZERO, _front(_find_card(id)))


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
			var linked: Dictionary = _linked_inputs.get(Vector2i(card.id, index), {})
			var target_link: bool = key == "target" and block["kind"] != "signal" and XREBlueprintTokens.targets_in_scene(_target_mode) \
					and XREBlueprintLinks.is_link(block, XREBlueprintLinks.TARGET) and not wired.has(index)
			if not linked.is_empty():
				# The wire from the variable's box is a link in the port (D-074).
				var variable := str(linked["variable"])
				_add_link(card, _row_point(card, row, true), XREBlueprintLinks.VARIABLE, linked["type"], variable if XREBlueprintLinks.shows_name(_link_preview) else "link",
						int(linked["getter"]), index, -1, variable)
			elif target_link and XREBlueprintTokens.adapter(_target_mode):
				_add_adapter(card, block, _row_point(card, row, true), true, index)
			elif target_link:
				_add_target_link(card, block, _row_point(card, row, true), index, -1)
				if not member_key.is_empty(): _add_member(card, text, member_key, str(params.get(member_key, "")), block)
			elif key == "target" and XREBlueprintTokens.adapter(_target_mode) and block["kind"] != "signal":
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
			var linked := XREBlueprintLinks.is_link(block, XREBlueprintLinks.TARGET)
			if linked and XREBlueprintTokens.adapter(_target_mode): _add_adapter(card, block, _row_point(card, row, true), true, -1)
			elif linked: _add_target_link(card, block, _row_point(card, row, true), -1, SOURCE)
			if XREBlueprintTokens.member_on_card(_target_mode): _add_member(card, text, "signal", str(params.get("signal", "")), block)
			elif XREBlueprintTokens.adapter(_target_mode) and not linked: _add_adapter(card, block, _row_point(card, row, true))
		elif entry.has("variable"):
			var variable := graph.find_variable(str(params.get("variable", "")))
			var type := XREBlueprintGraph.port_type(XREBlueprintGraph.variable_type(variable)) if not variable.is_empty() else XREBlueprintGraph.VALUE
			var text := _add_virtual(card, VARIABLE, "variable", "Variable", type, row, true)
			# No name by the socket (D-061): the wire goes to the variable's box, which has it.
			if variable.is_empty(): _add_member(card, text, "", "choose a box", block)
			elif XREBlueprintLinks.is_link(block, XREBlueprintLinks.VARIABLE):
				var variable_name := str(variable["name"])
				_add_link(card, _row_point(card, row, true), XREBlueprintLinks.VARIABLE, type, variable_name if XREBlueprintLinks.shows_name(_link_preview) else "link",
						card.id, -1, VARIABLE, variable_name)
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
## With [param link] its pin is a link's ring (D-074), a link socket of input
## [param port] (-1 for an event's Source), and the wire to the object is hidden.
func _add_adapter(card: Card, block: Dictionary, point: Vector3, link: bool = false, port: int = -1) -> void:
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
	if link:
		# A link's ring past the adapter's end instead of its pin (D-074): the object's
		# projection in it, or "link"; the wire it hides leaves its far side.
		var head := _make_link_head(XREBlueprintGraph.OBJECT, "" if XREBlueprintLinks.shows_projection(_link_preview) else "link")
		head.position = Vector3(edge - LINK_RING + 0.002, 0, depth)
		plug.add_child(head)
		if XREBlueprintLinks.shows_projection(_link_preview): head.set_meta(&"projection", true)
		card.sockets.append(socket)
		var ring := Socket.new()
		ring.kind = LINK
		ring.key = XREBlueprintLinks.TARGET
		ring.type = XREBlueprintGraph.OBJECT
		ring.port = port
		ring.link_kind = SOURCE if block["kind"] == "signal" else -1
		ring.flag_block = card.id
		ring.center = Vector3(point.x + head.position.x, point.y, card.face + depth)
		ring.size = Vector3(LINK_RING * 2.0 + 0.006, LINK_RING * 2.0 + 0.006, PLUG_DEPTH + 0.004)
		ring.visual = head
		ring.base_scale = head.scale
		ring.value = str((block["params"] as Dictionary).get("target", "."))
		ring.end = Vector3(point.x + head.position.x - LINK_RING, point.y, card.face + depth)
		plug.set_meta(&"adapter_end", ring.end)
		card.sockets.append(ring)
		return
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
func update_adapter_wire(link: Wire, id: int, start: Vector3, end: Vector3) -> void:
	_lay(link, start, Vector3.LEFT, end, Vector3.ZERO, _front(_find_card(id)))


## The link of [param block]'s target (D-074) in its input [param port] or its
## Source socket ([param kind]): its object's name or "link" on it, and a ring
## for the object's projection, which [XREBlueprints] puts in ([method target_heads]).
func _add_target_link(card: Card, block: Dictionary, point: Vector3, port: int, kind: int) -> void:
	_add_link(card, point, XREBlueprintLinks.TARGET, XREBlueprintGraph.OBJECT, XREBlueprintLinks.target_text(block, _link_preview, _target_mode),
			card.id, port, kind, str((block["params"] as Dictionary).get("target", ".")), XREBlueprintLinks.shows_projection(_link_preview))


## A link (D-074) at [param point], the port of input [param port] or the
## socket of [param kind]: a plug saying [param text] in the colour of
## [param type], with a ring at its far end, where the wire it hides leaves.
## Its socket names the reference of [param key] held by block
## [param flag_block], [param value] — a variable's name or a target path.
## With [param projection] its ring waits for the object's projection.
func _add_link(card: Card, point: Vector3, key: String, type: int, text: String, flag_block: int, port: int, kind: int, value: String, projection: bool = false) -> void:
	var width := XREBlueprintTokens.width(text)
	var link := make_link(text, width, type)
	link.position = Vector3(point.x, point.y, card.face)
	card.node.add_child(link)
	if projection: (link.get_meta(&"head") as Node3D).set_meta(&"projection", true)
	var socket := Socket.new()
	socket.kind = LINK
	socket.key = key
	socket.type = type
	socket.port = port
	socket.link_kind = kind
	socket.flag_block = flag_block
	# The pill and the ring; the plug's cap is left to the port it is in.
	var extent := width + LINK_RING * 2.0
	socket.center = Vector3(point.x - PLUG_GAP - extent * 0.5, point.y, card.face + PLUG_DEPTH * 0.5)
	socket.size = Vector3(extent + 0.006, 0.026 + 0.006, PLUG_DEPTH + 0.004)
	socket.visual = link
	socket.base_scale = link.scale
	socket.text = link.get_meta(&"text") as Label3D
	socket.value = value
	socket.end = link.position + (link.get_meta(&"end") as Vector3)
	card.sockets.append(socket)


## A link's mesh (D-074): a plug as a token's ([method make_token]), saying
## [param text], [param width] wide, in the colour of [param type], and its
## ring past the far end. Its ring's node is its "head" metadata, where the wire
## it hides leaves its "end", how far it reaches its "extent", its label its "text".
static func make_link(text: String, width: float, type: int) -> Node3D:
	var link := make_token(null, "", width, true, false, false, type, text)
	link.name = "Link"
	var head := _make_link_head(type)
	head.position = Vector3(-PLUG_GAP - width - LINK_RING + 0.002, 0, PLUG_DEPTH * 0.5)
	link.add_child(head)
	link.set_meta(&"head", head)
	link.set_meta(&"end", head.position + Vector3.LEFT * LINK_RING)
	link.set_meta(&"extent", PLUG_GAP + width + LINK_RING * 2.0)
	return link


## A link's ring in the colour of [param type], facing +Z on a dark disc, and
## [param text] in it if any. Its "inside" metadata is the node a projection goes in.
static func _make_link_head(type: int, text: String = "") -> Node3D:
	if _ring_mesh == null:
		_ring_mesh = TorusMesh.new()
		_ring_mesh.inner_radius = LINK_RING * 0.72
		_ring_mesh.outer_radius = LINK_RING
		_ring_mesh.rings = 24
		_ring_mesh.ring_segments = 8
		_ring_fill = CylinderMesh.new()
		_ring_fill.top_radius = LINK_RING * 0.8
		_ring_fill.bottom_radius = LINK_RING * 0.8
		_ring_fill.height = 0.001
		_ring_fill.radial_segments = 20
	var head := Node3D.new()
	head.name = "LinkHead"
	var ring := XRERig.create_vr_mesh(_ring_mesh, _token_shaded(COLORS[type]))
	ring.rotation.x = PI * 0.5
	head.add_child(ring)
	var fill := XRERig.create_vr_mesh(_ring_fill, _token_material(TOKEN_FACE))
	fill.rotation.x = PI * 0.5
	fill.position.z = -0.001
	head.add_child(fill)
	var inside := Node3D.new()
	inside.name = "Inside"
	inside.position.z = LINK_RING * 0.5
	head.add_child(inside)
	head.set_meta(&"inside", inside)
	if not text.is_empty():
		var word := label(text, 13)
		word.position.z = 0.0012
		word.sorting_offset = TOKEN_SORTING
		head.add_child(word)
	return head


## The rings of target links waiting for their object's projection (D-074):
## [code][block id, node to put it in][/code] for each; a ring filled once has children.
func target_heads() -> Array[Array]:
	var heads: Array[Array] = []
	for card: Card in _cards:
		for socket: Socket in card.sockets:
			if socket.kind != LINK or socket.key != XREBlueprintLinks.TARGET: continue
			var head := socket.visual if socket.visual.has_meta(&"inside") else socket.visual.get_meta(&"head") as Node3D
			if head.has_meta(&"projection"): heads.append([card.id, head.get_meta(&"inside")])
	return heads


## Where the wire that the link of [param key] on block [param id] hides
## leaves it, in the canvas's space; null without one.
func link_end(id: int, key: String) -> Variant:
	var card := _find_card(id)
	if card == null: return null
	for socket: Socket in card.sockets:
		if socket.kind == LINK and socket.key == key: return card.node.transform * socket.end
	return null


## The link socket of [param card] in input [param port] or in the socket of [param kind], or null.
func _link_socket(card: Card, port: int, kind: int) -> Socket:
	for socket: Socket in card.sockets:
		if socket.kind == LINK and socket.port == port and socket.link_kind == kind: return socket
	return null


## Hides the link of [param ref] while it is carried away (D-058, D-074), or shows it again.
func hide_link(ref: Dictionary, hidden: bool) -> void:
	var card := _find_card(int(ref["card"]))
	var socket := _link_socket(card, int(ref["port"]), int(ref["kind"])) if card != null else null
	if socket != null: socket.visual.visible = not hidden


## The inline Get Variable (D-061) whose wire comes into input [param port] of block [param id], or -1.
func inline_getter(id: int, port: int) -> int:
	for wire: Wire in _wires:
		if wire.from == null and wire.to.id == id and wire.to_port == port: return wire.getter
	return -1


## The link the last ray hit, as a ref of [XREBlueprintLinks], or empty.
func get_hit_link() -> Dictionary:
	var card := _find_card(_hit_id)
	if card == null or _hit_socket < 0 or _hit_socket >= card.sockets.size() or card.sockets[_hit_socket].kind != LINK: return {}
	var socket := card.sockets[_hit_socket]
	return XREBlueprintLinks.ref(socket.flag_block, socket.key, card.id, socket.port, socket.link_kind)


## What the link the last ray hit stands for: a variable's name or a target path; empty for none.
func get_hit_link_value() -> String:
	var card := _find_card(_hit_id)
	if card == null or _hit_socket < 0 or _hit_socket >= card.sockets.size() or card.sockets[_hit_socket].kind != LINK: return ""
	return str(card.sockets[_hit_socket].value)


## The input port of the socket the last ray hit — a token's or a link's — or -1.
func get_hit_socket_port() -> int:
	var card := _find_card(_hit_id)
	return card.sockets[_hit_socket].port if card != null and _hit_socket >= 0 and _hit_socket < card.sockets.size() else -1


## Where the reference [param ref] goes into its card, in the canvas's space:
## its input port or its Source or Variable socket (D-074).
func ref_point(ref: Dictionary) -> Vector3:
	var card := _find_card(int(ref["card"]))
	if card == null: return Vector3.ZERO
	if int(ref["kind"]) in [SOURCE, VARIABLE]: return socket_position(card.id, int(ref["kind"]))
	return _port_position(card, int(ref["port"]), true) if int(ref["port"]) >= 0 else card.node.position


## The wire the variable reference [param ref] is drawn as — from a box to a
## port or to a Variable socket — or null (D-074); a target's is [XREBlueprints]'s.
## Its tube up to its first bend (D-081), [method show_ref_wire] shows all of it.
func ref_wire(ref: Dictionary) -> XREGraphWire:
	var wire := _ref_wire(ref)
	return wire.mesh if wire != null else null


## Shows or hides every tube and knot of the wire of the variable reference [param ref] (D-074, D-081).
func show_ref_wire(ref: Dictionary, shown: bool) -> void:
	var wire := _ref_wire(ref)
	if wire != null: set_wire_shown(wire, shown)


func _ref_wire(ref: Dictionary) -> Wire:
	if ref["key"] != XREBlueprintLinks.VARIABLE: return null
	if int(ref["kind"]) == VARIABLE:
		for link: Wire in _variable_links:
			if link.from.id == int(ref["card"]): return link
		return null
	for wire: Wire in _wires:
		if wire.getter == int(ref["block"]): return wire
	return null


## The nearest drawn wire from a variable's box — to a port or to a Variable
## socket — that is not a link yet, on the ray from [param origin] along
## [param direction] (global) within [param maximum] (D-074): its distance, or
## -1. [method get_wire_ref] and [method get_wire_point] say which and where.
## Target wires are [XREBlueprints]'s. The wires test the ray natively
## ([method XREGraphWire.intersect_ray]): it may run every frame.
func intersect_link_wire(origin: Vector3, direction: Vector3, maximum: float) -> float:
	_wire_ref = {}
	if not is_visible_in_tree(): return -1.0
	var nearest := maximum
	var found := false
	for wire: Wire in _wires:
		if wire.variable.is_empty() or wire.link != null or not wire.mesh.visible: continue
		var hit := intersect_wire(wire, origin, direction, nearest)
		if hit < 0.0: continue
		nearest = hit
		found = true
		_wire_ref = XREBlueprintLinks.ref(wire.getter, XREBlueprintLinks.VARIABLE, wire.to.id, wire.to_port, -1)
	for link: Wire in _variable_links:
		if link.link != null or not link.mesh.visible: continue
		var hit := intersect_wire(link, origin, direction, nearest)
		if hit < 0.0: continue
		nearest = hit
		found = true
		_wire_ref = XREBlueprintLinks.ref(link.from.id, XREBlueprintLinks.VARIABLE, link.from.id, -1, VARIABLE)
	if not found: return -1.0
	_wire_point = origin + direction * nearest
	return nearest


## Where the ray from [param origin] along [param direction] (global) meets
## [param wire] nearer than [param maximum], as [method intersect_link_wire]
## takes it (D-074): natively, on each of its tubes (D-081); -1 for nowhere.
func intersect_wire(wire: Wire, origin: Vector3, direction: Vector3, maximum: float) -> float:
	var found := -1.0
	for piece: XREGraphWire in wire.pieces:
		var hit := piece.intersect_ray(origin, direction, WIRE_REACH, maximum, WIRE_MARGIN)
		if hit < 0.0: continue
		maximum = hit
		found = hit
	return found


## The ref of the wire the last [method intersect_link_wire] hit, or empty.
func get_wire_ref() -> Dictionary:
	return _wire_ref


## Where the last [method intersect_link_wire] met its wire, global.
func get_wire_point() -> Vector3:
	return _wire_point


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


## Builds the variables' boxes at their places (D-078) and the wires of the Variable sockets to them (D-052).
func _build_boxes(graph: XREBlueprintGraph) -> void:
	_boxes.visible = _variable_mode == XREFeatureSettings.BOXES
	if not _boxes.visible:
		_boxes.rebuild(XREBlueprintGraph.new(), {}, _value_mode, {})
		_boxes.visible = false
		return
	var used: Dictionary[String, bool] = {}
	for block: Dictionary in graph.nodes:
		if block["kind"] in ["get_variable", "set_variable"]: used[str(block["params"]["variable"])] = true
	_boxes.rebuild(graph, _box_places(graph), _value_mode, used)
	for card: Card in _cards:
		var block := graph.find_node(card.id)
		for index: int in card.sockets.size():
			if card.sockets[index].kind != VARIABLE: continue
			var variable := str((block["params"] as Dictionary).get("variable", ""))
			if not _boxes.has_box(variable): continue
			var link := Wire.new()
			link.from = card
			link.socket = index
			link.variable = variable
			link.owner = card.id
			link.edge = link_key(card.id, true)
			link.stored = XREBlueprintGraph.VARIABLE_BENDS
			# A link in the socket hides its wire, faint while drawn (D-074).
			link.link = _link_socket(card, -1, VARIABLE)
			_add_wire(link, COLORS[card.sockets[index].type], block)
			if link.link != null: set_wire_seen(link, &"link", LINK_SEEN)
			_variable_links.append(link)


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
