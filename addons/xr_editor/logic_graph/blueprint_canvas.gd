@tool
class_name XREBlueprintCanvas
extends Node3D
## Spatial cards and typed ports over the same resource used by GraphEdit.
## Cached card/port arrays are picked analytically; wires reuse meshes during dragging.
## Cards turn to the head as [constant XREFeatureSettings.NODE_FACING] says — all,
## only the shorthands, or none, which stand in their graph's or part's
## orientation — and are flat or solid as [constant XREFeatureSettings.NODE_VOLUME]
## says ([method set_node_modes], D-115, after D-039's Node display). A card
## that doesn't turn shows from behind its blank back or its face as a
## mirror's ([constant XREFeatureSettings.NODE_BACK]); a card that turns lays
## itself out as a mirror's past 90° from its front with
## [constant XREFeatureSettings.CARD_MIRROR]. The graph, or each of its parts,
## may turn to the head ([constant XREFeatureSettings.GRAPH_TURN],
## [method set_turn_modes]); wires may carry arrowheads ([method set_arrow_modes]). Ports are drawn as
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
##
## [constant XREFeatureSettings.NODE_STYLE] ([method set_style], D-099) says
## what a card shows of its block: as before, or as an archetype — a header in
## its group's color with its icon ([XREBlueprintIcons]), none on a pure
## function, framed in its result's color, and a trash only on the card in focus.
## An archetype's operator is a sign ([XREBlueprintShapes], D-100): a circle, a
## diamond or a pill in its result's color, and so are math functions as
## [constant XREFeatureSettings.NODE_SHRINK] says ([method set_shrink]).
## An archetype's card (D-101) has its execution In and Then on its header's
## edges, its target — Target, Source or Variable — on the row under it, an
## event's policy as a chip in its header; its header says the operation or
## the member, as [constant XREFeatureSettings.NODE_HEADING] or its block's
## [code]vr_heading[/code] says ([method heading_of]); ⇄ by its trash switches it.
## Further, as Node shrink says, a block may be a bead (D-103): a circle in its
## group's colour with the execution's white rim, or a pure function's ring in
## its result's colour, its icon inside, its ports on its arcs.

const PIXEL_SIZE := 0.0009
const CARD_WIDTH := 0.26
const CARD_THICKNESS := 0.001
## Depth of a solid card (Node volume 3D): it reads as a solid from the side,
## and is thinner than a port's 2 cm, so that ports on its edge stand out of
## its faces too (D-115; 3 cm before).
const CUBOID_DEPTH := 0.012
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
## A call of the graph's own function opens its body by a box with an arrow
## going in, in the teal of its header (docs/blueprint_functions.md); a pure
## one's in the color of its frame.
const OPEN_COLOR := Color("6fd3dc")
## An Entry's pure switch on its header: its pill, on in the green of a
## number, off grey, and how large; the hourglass of a call whose body waits.
const PURE_ON := Color("7be5b3")
const PURE_OFF := Color("3a3f49")
const PURE_SIZE := Vector2(0.026, 0.014)
const WAIT_COLOR := Color("f2d878")
const TOUCH_RADIUS := 0.035
## Lift only the contact dot towards the controller; ray picking stays unchanged.
const HIT_DOT_OFFSET := 0.012
## Colors of the port types of [XREBlueprintGraph], as the 2D view has them:
## execution, any value, bool, int (lime, apart from float since D-080), float
## (sea green), text, the vectors, object, color.
# The built-in compound values (D-139): vectors blue, whole vectors green, boxes teal, a rotation violet, transforms orange.
const COLORS: Array[Color] = [Color("eeeeee"), Color("63c6ea"), Color("e8879b"), Color("b4e05a"), Color("7be5b3"), Color("e5b57b"), Color("89adff"), Color("89adff"), Color("b991eb"), Color("f2d878"), Color("89adff"), Color("9fd36a"), Color("9fd36a"), Color("6fc3c8"), Color("6fc3c8"), Color("c38bf0"), Color("f0a35e"), Color("f0a35e"), Color("f0a35e"), Color("6fc3c8")]
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
## How far a Switch case's puck ends left of the card's right edge (D-140):
## just short of its output's port.
const CASE_INSET := 0.02
const PLUG_DEPTH := 0.012
const PLUG_GAP := 0.022
const FADED := 0.35
## How much a token or a member grows under a ray.
const SOCKET_HOVER := 1.15
const MEMBER_COLOR := Color("dcc8fa")
## A member in a header under the ray (D-110): the focus's yellow.
const MEMBER_HOVER := Color("ffd75e")
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
## An archetype's header (D-099): its height; its icon's size on the card,
## the circle's and a pure function's, and in pixels; the trash, coral and
## larger than a classic card's, standing over the card; the font size of
## the ƒ a call without an icon shows, larger on a pure function, as its glyphs are.
const HEAD_HEIGHT := 0.04
const ICON_SIZE := 0.032
const PURE_ICON_SIZE := 0.026
## How much of the circle an image icon (a class's) takes: it has its own margins.
const IMAGE_SHARE := 0.6
const ICON_PIXELS := 64
const TRASH_COLOR := Color("ff6b7a")
const TRASH_SCALE := 1.3
const TRASH_RISE := 0.02
## The grey of the × that removes an input (D-137), how far right of its
## port it stands, inside the node, and how wide its cross and its hit square are.
const PIN_MARK_COLOR := Color("9aa1b1")
const PIN_MARK_SHIFT := 0.018
const PIN_MARK_SIZE := 0.012
const FALLBACK_SIZE := 30
## A sign (D-100): the width of its rim and of a math function's inner rim, how
## far in the inner rim is and how much of it is seen; the font size of a
## function's name, and of a longer one.
const RIM := 0.0022
const INNER_RIM := 0.0012
const INNER_INSET := 0.0055
const INNER_SEEN := 0.4
const SIGN_WORD_SIZE := 30
const SIGN_LONG_SIZE := 24
## An archetype's card (D-101): the gap between its header and its rows; the
## switch of its heading, its size, how far left of the trash it stands.
const HEAD_GAP := 0.006
## An archetype card's corners (D-109), as the mockup's: 1,5 cm, an event's top
## left 2,5 cm — its "hat".
const CORNER := 0.015
const HAT := 0.025
## An event's policy chip in its header (D-106): its height, its icon's size,
## its text's, how dark its face is of the header's colour, its border.
const CHIP_HEIGHT := 0.024
const CHIP_ICON := 0.016
const CHIP_TEXT := 15
const CHIP_SHADE := 0.72
const CHIP_BORDER := Color(1, 1, 1, 0.25)
## Branch's tabs on its right edge (D-106): their height, colours of
## True and False, how much of their colour their opaque face has (D-108: a
## see-through tab looked lit only in focus).
const TAB_HEIGHT := PORT_RADIUS * 2.0
## How far a tab reaches left of the mark's centre (D-111: a tab no wider than its mark and name).
const TAB_LEAD := 0.012
const TAB_COLORS: Array[Color] = [Color("7be5b3"), Color("e8879b")]
const TAB_TINT := 0.28
## A Get Variable's tag (D-106): its height, how much of its type's colour its face has.
const TAG_HEIGHT := 0.035
const TAG_TINT := 0.22
const SWAP_SIZE := 0.024
const SWAP_SHIFT := 0.034
## The values of Node shrink from fewest signs to most, each with the ones before it: the
## setting lists its default first (D-114), not in this order.
const SHRINK_LEVELS: Array[StringName] = [XREFeatureSettings.OPERATORS, XREFeatureSettings.MATH, XREFeatureSettings.SYSTEM, XREFeatureSettings.ICONS]
## A bead (D-103): its radius, and with three ports on a side; its icon's size
## in its radii, an image's; how far under it its name shows under the ray,
## and its font size (D-106: 18 was too small to read; back in D-108).
const BEAD_RADIUS := 0.036
const BEAD_LARGE := 0.042
const BEAD_ICON := 1.15
const BEAD_IMAGE := 0.85
const BEAD_TIP := 0.02
const TIP_SIZE := 26
## How much of a bead the face of Get Time and Random covers, in its radii.
const BEAD_FACE := 1.9
const PURE_FALLBACK_SIZE := 38
## How far past a threshold the head must go before a node or a part changes
## its mind (D-115): mirrored, turned round, its pins on its back, its turn.
const MARGIN := deg_to_rad(5.0)
## A card's wires that run across the view less than this, as a sum of lengths 1, leave its mirror to its part (D-132).
const MIN_FLOW := 0.25
## How fast a graph or a part turns to its new front: the gap left after a second, as a share.
const TURN_RATE := 12.0
## A turn of a held card about the vertical goes in steps of 15° (D-115).
const YAW_STEP := deg_to_rad(15.0)
## Wire arrowheads (D-115): how far apart chevrons are, how fast they run, how
## much of a wire at each end has none, how far before its input the one at the
## end is and how much larger, and the most drawn of each style.
const ARROW_STEP := 0.09
const ARROW_SPEED := 0.12
const ARROW_MARGIN := 0.035
const ARROW_END := 0.025
const ARROW_END_SCALE := 1.5
const ARROW_LIMIT := 1024

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
	## Where it was built: a sign's token goes round with its port from there (Sign ports Rim, D-115).
	var home := Vector3.ZERO

class Card:
	var id: int
	var node: Node3D
	var height: float
	var width := CARD_WIDTH
	## An operator's small card (D-065).
	var compact := false
	## A sign's shape ([enum XREBlueprintShapes.Shape], D-100), its outline and its inputs' places.
	var shape := 0
	var outline: PackedVector2Array
	var shape_inputs: Array[Vector2] = []
	## An archetype's card with its header row (D-101): row 0 is in the header.
	var headed := false
	## The switch of its heading, where it is, null without one.
	var swap: Node3D
	var swap_point: Vector3
	## A bead (D-103): its outputs' places on its right arc, its name under it
	## shown under the ray.
	var bead := false
	var shape_outputs: Array[Vector2] = []
	var tip: Label3D
	## Whether its tokens say their ports' names: a bead of two values or more.
	var named_tokens := false
	## A Get Variable's tag (D-106): a pill of its type's colour with its name.
	var tag := false
	## The height of the first row's ports; a compact card's output is in its middle.
	var first_row := 0.0
	## How far the front face is in front of a billboard's: ports, labels and icons sit on it.
	var face := 0.0
	var bounds: AABB
	var mesh: MeshInstance3D
	var normal: Material
	var frame: MeshInstance3D
	## The frame's material while the card is neither selected nor in focus:
	## a pure function's is its result's type color (D-099).
	var frame_material: Material
	var plus: Node3D
	var plus_point: Vector3
	var plus_faces: Array[Node3D] = []
	var trash: Node3D
	var trash_point: Vector3
	## The copy button (D-093), or null while cards have none.
	var copy: Node3D
	var copy_point: Vector3
	## A function call's button that opens its body, left of the copy in their
	## row, or null; an Entry's pure switch on its header, or null, and whether it is on.
	var open: Node3D
	var open_point: Vector3
	var pure_switch: Node3D
	var pure_point: Vector3
	var pure_on := false
	## A body's Entry or Return: no trash and no copy (docs/blueprint_functions.md);
	## its trash node stays, empty, as the anchor of its other buttons.
	var fixed := false
	## How many ports of the pins' side come before the pins that change: an
	## Entry's Then, a Return's In (docs/blueprint_functions.md).
	var pin_offset := 0
	## A variadic operator's plus that adds an input (D-137), under its trash,
	## or null; the grey × that removes each input, by input port, null for
	## none while it has the fewest.
	var pin_plus: Node3D
	var pin_plus_point: Vector3
	var pin_marks: Array[Node3D] = []
	## Whether those pins are inputs or outputs (D-138), and how far each × is
	## right of its pin (left of an output's name, negative).
	var pin_input := true
	var pin_shifts: Array[float] = []
	var pin_front := 0.0
	## A Break's or a Make's marks are eyes that hide a field, not × (D-139),
	## and its chip of hidden fields under it, where it is and how large; null
	## while none is hidden.
	var pin_eyes := false
	var hidden_chip: Node3D
	var hidden_chip_point: Vector3
	var hidden_chip_size: Vector2
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
	## Its orientation in its graph about the vertical (D-115), its block's
	## [code]vr_rotation.y[/code] in radians; a held card's preview of it, and its block's own.
	var yaw := 0.0
	var block_yaw := 0.0
	## Its place in the graph before its part's turn, and its part's index in the canvas's parts.
	var base := Vector3.ZERO
	var part := 0
	## Laid out as a mirror's (D-115): its node's x scaled by -1, its labels by -1 again, their sides swapped.
	var mirrored := false
	## Not turned to the head and seen from behind: turned round to show its face as a mirror's (Node back Labelled).
	var turned_round := false
	## Its ports on its back face, turned to the head (Pins Both faces).
	var pins_back := false
	## Its labels, which a mirror leaves readable.
	var labels: Array[Label3D] = []
	## The words of a heading of two labels, verb and member, and the sum of its
	## left and right ends, about which a mirror swaps them back to read in order.
	var heading: Array[Label3D] = []
	var heading_ends := 0.0
	## While held and not facing the head: its yaw towards the head, in steps of 15°; INF when not held.
	var held_face := INF
	## A sign's ports on its rim (Sign ports Rim): where each was built, by its index in [member ports].
	var rim_built: Array[Vector3] = []
	## The level way its wires run through it, in the canvas's space (D-132): a
	## sum of one length from each input's far end and one to each output's.
	var flow := Vector3.ZERO

## A part of the graph (D-115): its cards of one orientation wired together,
## or every card while the graph turns as a whole. It turns about its centre.
class Part:
	var cards: Array[Card] = []
	## Its centre in the canvas's space and its front's yaw.
	var pivot := Vector3.ZERO
	var yaw := 0.0
	## Its turn now and the turn it goes to, in radians; whether its cards are mirrored.
	var turn := 0.0
	var target := 0.0
	var mirrored := false
	## Its cards' ids, sorted: a part keeps its turn across rebuilds while it keeps its cards.
	var key := PackedInt32Array()

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
	## The component of its variable's box it comes from (D-105), -1 for the whole value.
	var component := -1
	## Whether it is a Set's wire to its variable's box: it writes it (D-106).
	var writes := false
	## Its colour, its arrowheads' too (D-115).
	var color := Color.WHITE

var _cards: Array[Card] = []
var _wires: Array[Wire] = []
var _selected_material: Material
var _port_mesh: CylinderMesh
var _sphere_mesh: SphereMesh
var _trash_mesh: ArrayMesh
var _trash_material: Material
var _preview: XREGraphWire
var _offset := Vector2.ZERO
## The VR depth at the canvas's origin: a block stands at its depth less this.
## Not 0 only while a function's body stands where it was opened from ([method center_at]).
var _depth := 0.0
## The file's graph's [member _offset], kept while a body is shown: the boxes
## of its variables stay where they were ([method _box_places]).
var _root_offset := Vector2.ZERO
var _structure: Array = []
## The selected blocks (D-122), drawn with a white frame.
var _selected: Array[int] = []
var _hit_id := -1
var _hit_port := -1
var _hit_input := false
var _hit_plus := false
var _hit_delete := false
var _hit_copy := false
## Whether the last ray hit a call's open button or an Entry's pure switch,
## and at what distance: a later, nearer hit takes the ray back.
var _hit_open := false
var _hit_pure := false
var _button_distance := -1.0
var _open_right := -1
var _open_left := -1
var _pure_right := -1
var _pure_left := -1
var _open_mesh: ArrayMesh
var _open_material: Material
## The signature of the function whose body the canvas shows, empty for a file's graph.
var _function: Dictionary = {}
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
## The card whose heading switch (D-101) is under each hand's ray, or -1.
var _swap_right := -1
var _swap_left := -1
## Whether cards have the copy button ([constant XREFeatureSettings.BLOCK_COPY], D-093).
var _copy_shown := false
var _copy_mesh: ArrayMesh
var _copy_material: Material
## The pins of a variadic operator (D-137): what the last ray hit — its plus,
## or the × of an input, by port, -1 for none — and how far, and what is under
## each hand's ray, as [code](card, port)[/code] for a ×.
var _hit_pin_plus := false
var _hit_pin_mark := -1
## Whether the last ray hit a Break's or a Make's chip of hidden fields (D-139).
var _hit_hidden_chip := false
var _eye_mesh: ArrayMesh
var _pin_distance := -1.0
var _pin_plus_right := -1
var _pin_plus_left := -1
var _pin_mark_right := Vector2i(-1, -1)
var _pin_mark_left := Vector2i(-1, -1)
## The pin whose half-row each hand's ray is on — its port, its name, its × or
## eye, a Switch case's puck (D-140) —, (card, pin) or (-1, -1).
var _pin_row_right := Vector2i(-1, -1)
var _pin_row_left := Vector2i(-1, -1)
## The pin whose half-row the last ray hit, of card [member _pin_row_card].
var _hit_pin_row := -1
var _pin_row_card := -1
var _pin_mark_mesh: ArrayMesh
var _pin_mark_material: Material
var _pin_plus_material: Material
var _body_materials: Array[ShaderMaterial] = []
## Archetypes (D-099): the headers by [enum XREBlueprintIcons.Group], the faces
## under a header, of a pure function and of an operator, the frames by port
## type, the trash.
var _style := XREFeatureSettings.CLASSIC
var _head_materials: Array[ShaderMaterial] = []
var _archetype_faces: Array[ShaderMaterial] = []
var _type_frames: Dictionary[int, Material] = {}
var _archetype_trash: Material
## The faces' shader, and the tags' faces by port type (D-106).
var _card_shader: Shader
var _tag_faces: Dictionary[int, ShaderMaterial] = {}
var _class_icon: Callable
var _shrink := XREFeatureSettings.OPERATORS
var _heading := XREFeatureSettings.OPERATION
var _port_shapes := false
var _composite := XREFeatureSettings.WHOLE
var _hit_swap := false
var _faces_user := false
## Node facing, Node volume, Node back, Pins and Card mirror (D-115).
var _facing := XREFeatureSettings.ON
var _solid := false
var _labelled_back := false
var _pins := XREFeatureSettings.FACE
var _card_mirror := false
## Sign ports on the rim (D-115).
var _rim_ports := false
## Graph turn and Graph parts (D-115): the parts, and whether nothing may turn
## now — something is held or drawn.
var _turn_mode := XREFeatureSettings.FIXED
var _by_parts := false
var _parts: Array[Part] = []
var _turn_frozen := false
## Wire arrowheads (D-115): the modes of execution and data wires, open or
## filled, a multimesh of each style, and the time the running ones run by.
var _exec_arrows := XREFeatureSettings.OFF
var _data_arrows := XREFeatureSettings.OFF
var _open_arrows := false
## An execution port's arrowhead on a node's edge (Pins On the edge), made once.
var _edge_arrow: CylinderMesh
var _arrows_filled: MultiMeshInstance3D
var _arrows_open: MultiMeshInstance3D
var _arrow_clock := 0.0
## The arrowheads' poses as drawn, kept here too: a renderer need not give them back.
var _arrow_poses: Array[Transform3D] = []
## Arc lengths along a wire's points, reused for every wire; a sign's ports' angles on its rim.
var _arc := PackedFloat32Array()
var _rim_angles := PackedFloat32Array()
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
## The row of boxes under the file's graph, kept while a body is shown ([method _shelf]).
var _shelf_at := Vector2.ZERO
var _shelf_known := false
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
	_card_shader = shader
	for tint: Color in CARD_PALETTE: _body_materials.append(_face(shader, tint))
	for tint: Color in XREBlueprintIcons.HEADS: _head_materials.append(_face(shader, tint))
	for tint: Color in [XREBlueprintIcons.BODY, XREBlueprintIcons.PURE_BODY, XREBlueprintIcons.OPERATOR_BODY]: _archetype_faces.append(_face(shader, tint))
	_archetype_trash = material(TRASH_COLOR, true)
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
	_open_mesh = _make_open_mesh()
	_open_material = material(OPEN_COLOR, true)
	_pin_mark_mesh = _make_pin_mark_mesh()
	_eye_mesh = _make_eye_mesh()
	_pin_mark_material = material(PIN_MARK_COLOR, true)
	_pin_plus_material = material(Color.WHITE, true)
	_preview = create_scene_wire(Color("ffda82"))
	_preview.visible = false
	_boxes = XREBlueprintBoxes.new(_trash_mesh, _trash_material, material(TRASH_COLOR, true))
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
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 0.0085
	cone.height = 0.018
	cone.radial_segments = 10
	cone.rings = 1
	_arrows_filled = _arrow_layer(cone)
	_arrows_open = _arrow_layer(_open_arrow_mesh())
	_arc.resize(XREGraphWire.SAMPLES)
	_arrow_poses.resize(ARROW_LIMIT)


## A multimesh of up to [constant ARROW_LIMIT] arrowheads of [param mesh] on the
## VR layer, each in its wire's colour (D-115), over the wires as they are drawn.
func _arrow_layer(mesh: Mesh) -> MultiMeshInstance3D:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.mesh = mesh
	multimesh.instance_count = ARROW_LIMIT
	multimesh.visible_instance_count = 0
	var layer := MultiMeshInstance3D.new()
	layer.name = "Arrows"
	layer.multimesh = multimesh
	layer.layers = XRERig.VR_LAYER
	layer.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	layer.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	var face := StandardMaterial3D.new()
	face.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	face.vertex_color_use_as_albedo = true
	# The instances' colours are the wires' own, in sRGB as the wires' tints are.
	face.vertex_color_is_srgb = true
	face.cull_mode = BaseMaterial3D.CULL_DISABLED
	# In the transparent pass like the wires, above the scene dimmer.
	face.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	face.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	face.render_priority = Material.RENDER_PRIORITY_MAX
	layer.material_override = face
	layer.visible = false
	add_child(layer)
	return layer


## An open arrowhead, two strokes meeting at its tip as ">" with no base (D-115):
## the tip on +Y, flat in the XY plane, 1.6 cm long and wide, its strokes 3.2 mm.
static func _open_arrow_mesh() -> ArrayMesh:
	var half := 0.008
	var stroke := 0.0032
	var points := PackedVector3Array()
	for side: float in [-1.0, 1.0]:
		var tip := Vector2(0, half)
		var end := Vector2(side * half, -half)
		var along := (end - tip).normalized()
		var across := Vector2(-along.y, along.x) * stroke * 0.5
		# Run a little past the tip, so that the strokes close the joint.
		var start := tip - along * stroke * 0.5
		var corners: Array[Vector2] = [start + across, start - across, end + across, end - across]
		for index: int in [0, 1, 2, 2, 1, 3]: points.append(Vector3(corners[index].x, corners[index].y, 0))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	var result := ArrayMesh.new()
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return result


static func _face(shader: Shader, tint: Color) -> ShaderMaterial:
	var result := ShaderMaterial.new()
	result.shader = shader
	result.render_priority = Material.RENDER_PRIORITY_MAX - 1
	result.set_shader_parameter(&"face_tint", tint)
	return result


## Switches what cards show of their blocks to [param style], a value of
## [constant XREFeatureSettings.NODE_STYLE] (D-099). Takes effect on the next
## [method rebuild]; false if it is unknown or already the current one.
func set_style(style: StringName) -> bool:
	if style == _style or not style in XREFeatureSettings.get_values(XREFeatureSettings.NODE_STYLE): return false
	_style = style
	return true


## What cards show of their blocks: a value of [constant XREFeatureSettings.NODE_STYLE].
func get_style() -> StringName:
	return _style


## Switches which blocks archetypes draw as signs to [param shrink], a value of
## [constant XREFeatureSettings.NODE_SHRINK] (D-100). Takes effect on the next
## [method rebuild]; false if it is unknown or already the current one.
func set_shrink(shrink: StringName) -> bool:
	if shrink == _shrink or not shrink in XREFeatureSettings.get_values(XREFeatureSettings.NODE_SHRINK): return false
	_shrink = shrink
	return true


## Which blocks archetypes draw as signs: a value of [constant XREFeatureSettings.NODE_SHRINK].
func get_shrink() -> StringName:
	return _shrink


## Switches how a vector's or a colour's variable gives its components to
## [param composite], a value of [constant XREFeatureSettings.COMPOSITE_VALUES]
## (D-105). Takes effect on the next [method rebuild]; false if unchanged or unknown.
func set_composite(composite: StringName) -> bool:
	if composite == _composite or not composite in XREFeatureSettings.get_values(XREFeatureSettings.COMPOSITE_VALUES): return false
	_composite = composite
	return true


## How a vector's or a colour's variable gives its components ([method set_composite]).
func get_composite() -> StringName:
	return _composite


## Whether ports are shaped by their types ([constant XREFeatureSettings.PORT_SHAPES],
## D-104). Takes effect on the next [method rebuild]; true if it changed.
func set_port_shapes(shaped: bool) -> bool:
	if shaped == _port_shapes: return false
	_port_shapes = shaped
	return true


## Whether ports are shaped by their types ([method set_port_shapes]).
func get_port_shapes() -> bool:
	return _port_shapes


## A port's mesh of [param type] in [param color]: shaped by the type with
## Port shapes on (D-104), flat on the face; else a disc, or a sphere if
## [param spherical] — the sphere's centre is then [constant SPHERE_LIFT] radii
## out of the face, which the caller sets.
func _port_visual(type: int, color: Color, spherical: bool) -> MeshInstance3D:
	# An archetype's execution is an arrow whatever Port shapes says (D-106), as the mockup's.
	if _port_shapes or (type == XREBlueprintGraph.EXEC and _style == XREFeatureSettings.ARCHETYPES): return XRERig.create_vr_mesh(XREBlueprintShapes.port_mesh(type, PORT_RADIUS, PORT_DEPTH * 2.0), material(color, true))
	if spherical: return XRERig.create_vr_mesh(_sphere_mesh, wire_material(color))
	var disc := XRERig.create_vr_mesh(_port_mesh, material(color, true))
	disc.rotation.x = PI * 0.5
	return disc


## Switches what archetypes' headers say by default to [param heading], a value of
## [constant XREFeatureSettings.NODE_HEADING] (D-101). Takes effect on the next
## [method rebuild]; false if it is unknown or already the current one.
func set_heading(heading: StringName) -> bool:
	if heading == _heading or not heading in XREFeatureSettings.get_values(XREFeatureSettings.NODE_HEADING): return false
	_heading = heading
	return true


## What archetypes' headers say by default: a value of [constant XREFeatureSettings.NODE_HEADING].
func get_heading() -> StringName:
	return _heading


## What [param block]'s header says (D-101): its own [code]vr_heading[/code],
## else the setting's; the operation for a block without a member and on
## Classic cards.
func heading_of(block: Dictionary) -> StringName:
	if _style != XREFeatureSettings.ARCHETYPES or not can_head(block): return XREFeatureSettings.OPERATION
	var own := str(block.get("vr_heading", ""))
	return StringName(own) if own in [XREFeatureSettings.OPERATION, XREFeatureSettings.MEMBER] else _heading


## Whether [param block] has a member its header may say (D-101, D-106, D-108):
## any event — On Ready too, its member is ready —, a block with a member —
## a property, an animation —, a variable's Set. A call without a member, as
## Rotate X, has only its operation: its object is no member of it.
static func can_head(block: Dictionary) -> bool:
	# Break and Make say their type or class as Get says its property (D-139).
	if block.get("kind") in ["break", "make"]: return not (block.get("struct", {}) as Dictionary).is_empty()
	return block.get("kind") in ["set_variable", "signal"] or not XREBlueprintTokens.member_key(block).is_empty()


## The member [param block]'s header says in Member (D-101): its signal,
## property or animation, its variable, or what to pick.
static func member_of(block: Dictionary) -> String:
	var params: Dictionary = block.get("params", {})
	if block.get("kind") in ["break", "make"]: return XREBlueprintStructs.name_of(block.get("struct", {}))
	if block.get("kind") == "set_variable":
		var variable := str(params.get("variable", ""))
		return variable if not variable.is_empty() else "choose a box"
	var key := XREBlueprintTokens.member_key(block)
	var member := str(params.get(key, ""))
	return member if not member.is_empty() else XREBlueprintTokens.member_placeholder(block)


## The operation [param block]'s header says (D-101): Set for both Sets, On
## Signal for every event — On Ready is one too (D-107) —, else its title.
static func operation_of(block: Dictionary) -> String:
	if block.get("kind") == "signal": return "On Signal"
	if block.get("kind") in ["break", "make"]: return "Break" if block["kind"] == "break" else "Make"
	return "Set" if block.get("kind") in ["set_property", "set_variable"] else XREBlueprintGraph.title(block)


## The verb before the member in a Member header (D-107): On for an event, Set,
## Get, else the operation — "On Ready", "Set Light Energy", "Get Position".
static func verb_of(block: Dictionary) -> String:
	match str(block.get("kind", "")):
		"signal": return "On"
		"set_property", "set_variable": return "Set"
		"get_property", "get_variable": return "Get"
	return operation_of(block)


## Whether the last ray hit the switch of a card's heading (D-101).
func get_hit_swap() -> bool:
	return _hit_swap


## Where archetypes take the editor's icon of an engine class (D-099):
## [param class_icon] takes a class name and gives a [Texture2D] or null.
func set_class_icons(class_icon: Callable) -> void:
	_class_icon = class_icon


## Switches how nodes are drawn (D-115): which turn to the head — a value of
## [constant XREFeatureSettings.NODE_FACING] —, whether they are [param solid],
## whether a node that doesn't turn shows its face from behind
## ([param labelled_back]), where their ports are — a value of
## [constant XREFeatureSettings.PIN_PLACE] —, and whether cards that turn
## mirror themselves past 90° ([param mirror]). Takes effect on the next
## [method rebuild]; false if nothing changed or a value is unknown.
func set_node_modes(facing: StringName, solid: bool, labelled_back: bool, pins: StringName, mirror: bool) -> bool:
	if not facing in XREFeatureSettings.get_values(XREFeatureSettings.NODE_FACING) or not pins in XREFeatureSettings.get_values(XREFeatureSettings.PIN_PLACE): return false
	if [facing, solid, labelled_back, pins, mirror] == [_facing, _solid, _labelled_back, _pins, _card_mirror]: return false
	_facing = facing
	_solid = solid
	_labelled_back = labelled_back
	_pins = pins
	_card_mirror = mirror
	return true


## The node modes, as [method set_node_modes] takes them.
func get_node_modes() -> Array:
	return [_facing, _solid, _labelled_back, _pins, _card_mirror]


## Whether [param card] turns to the head (Node facing, D-115): every card, or only a shorthand's.
func _faces(card: Card) -> bool:
	return _facing == XREFeatureSettings.ON or (_facing == XREFeatureSettings.SHORTHANDS and card.compact)


## Whether card [param id] stands at its own yaw, which a grab turns (D-115):
## it doesn't face the head.
func turns_on_grab(id: int) -> bool:
	var card := _find_card(id)
	return card != null and not _faces(card)


## Switches where signs' ports are to their rims ([param rim], D-115). Takes
## effect on the next [method rebuild]; true if it changed.
func set_rim_ports(rim: bool) -> bool:
	if rim == _rim_ports: return false
	_rim_ports = rim
	return true


## Switches how the graph turns to the head — a value of
## [constant XREFeatureSettings.GRAPH_TURN] — and whether by its parts (D-115).
## Takes effect on the next [method rebuild]; false if nothing changed or the mode is unknown.
func set_turn_modes(turn: StringName, by_parts: bool) -> bool:
	if not turn in XREFeatureSettings.get_values(XREFeatureSettings.GRAPH_TURN) or [turn, by_parts] == [_turn_mode, _by_parts]: return false
	_turn_mode = turn
	_by_parts = by_parts
	for part: Part in _parts: part.target = 0.0
	return true


## The turn modes, as [method set_turn_modes] takes them.
func get_turn_modes() -> Array:
	return [_turn_mode, _by_parts]


## Switches the arrowheads of execution and data wires to values of
## [constant XREFeatureSettings.EXEC_ARROWS], open ones if [param open] (D-115).
## Takes effect at once; false if nothing changed or a mode is unknown.
func set_arrow_modes(execution: StringName, data: StringName, open: bool) -> bool:
	var modes := XREFeatureSettings.get_values(XREFeatureSettings.EXEC_ARROWS)
	if not execution in modes or not data in modes or [execution, data, open] == [_exec_arrows, _data_arrows, _open_arrows]: return false
	_exec_arrows = execution
	_data_arrows = data
	_open_arrows = open
	_lay_arrows()
	return true


## Whether nothing may turn now: something in the graph is held or drawn (D-115).
func set_turn_frozen(frozen: bool) -> void:
	_turn_frozen = frozen


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
	_depth = 0.0
	if graph.vr_placed: _offset = graph.vr_center
	elif not graph.nodes.is_empty():
		var low: Vector2 = graph.nodes[0]["position"]
		var high := low
		for block: Dictionary in graph.nodes:
			var point: Vector2 = block["position"]
			low = low.min(point)
			high = high.max(point)
		_offset = (low + high) * 0.5
	if graph.function_signature.is_empty(): _root_offset = _offset


## Puts [param graph]'s Entry at [param point], in the canvas's space, as deep
## too: a function's body opened from a call stands in the call's place, one
## opened from the Functions window over it (D-144)
## (docs/blueprint_functions.md). Not kept in the graph.
func center_at(graph: XREBlueprintGraph, point: Vector3) -> void:
	center_graph(graph)
	for block: Dictionary in graph.nodes:
		if block["kind"] != "entry": continue
		var at: Vector2 = block["position"]
		_offset = Vector2(at.x - point.x / PIXEL_SIZE, at.y + point.y / PIXEL_SIZE)
		_depth = float(block.get("vr_depth", 0.0)) - point.z
		return


## XY origin to persist together with the workspace pose, avoiding reopen recentering.
func get_graph_center() -> Vector2:
	return _offset


## Where the view stands on its graph: the graph XY and the depth at the
## canvas's origin, to come back to ([method set_view]).
func get_view() -> Vector3:
	return Vector3(_offset.x, _offset.y, _depth)


## Shows the graph from [param view], as [method get_view] gave it.
func set_view(view: Vector3) -> void:
	_offset = Vector2(view.x, view.y)
	_depth = view.z


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
	_open_right = -1
	_open_left = -1
	_pure_right = -1
	_pure_left = -1
	_function = graph.function_signature
	_swap_right = -1
	_swap_left = -1
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
		card.base = position_from_block(block)
		card.block_yaw = yaw_of(block)
		card.yaw = card.block_yaw
		card.node.position = card.base
		add_child(card.node)
		var inputs := graph.ports(block, true)
		var outputs := graph.ports(block, false)
		var layout := _layout(graph, block, inputs, outputs)
		var archetype := _style == XREFeatureSettings.ARCHETYPES
		card.shape = _sign_shape(block, inputs, outputs) if archetype else XREBlueprintShapes.Shape.NONE
		card.compact = XREBlueprintGraph.is_operator(block) or card.shape != XREBlueprintShapes.Shape.NONE
		var chip := ""
		if archetype and not card.compact and _is_bead(block, inputs, layout):
			card.bead = true
			card.compact = true
			card.shape = XREBlueprintShapes.Shape.CIRCLE
			_bead_layout(block, inputs, layout)
			var sides := maxi((layout[0] as Array).size(), (layout[1] as Array).size())
			var radius := BEAD_LARGE if sides >= 3 else BEAD_RADIUS
			card.width = radius * 2.0
			card.height = radius * 2.0
			card.outline = XREBlueprintShapes.circle(radius)
			card.shape_inputs = XREBlueprintShapes.arc((layout[0] as Array).size(), radius, -1.0)
			card.shape_outputs = XREBlueprintShapes.arc((layout[1] as Array).size(), radius, 1.0)
			var values := 0
			for spec: Array in inputs:
				if not int(spec[1]) in [XREBlueprintGraph.EXEC, XREBlueprintGraph.OBJECT]: values += 1
			card.named_tokens = values >= 2
		elif archetype and not card.compact and block["kind"] == "get_variable" and _variable_mode != XREFeatureSettings.BOXES:
			# A Get Variable without boxes is a tag (D-106): its name and its output.
			card.tag = true
			card.compact = true
			card.shape = XREBlueprintShapes.Shape.PILL
			var named := str((block["params"] as Dictionary).get("variable", ""))
			card.width = text_width(named if not named.is_empty() else "variable", 21) + 0.06
			card.height = TAG_HEIGHT
			card.outline = XREBlueprintShapes.stadium(Vector2(card.width, card.height))
		elif archetype and not card.compact:
			card.headed = true
			chip = _head_layout(block, inputs, outputs, layout)
		if card.bead or card.tag: pass
		elif card.shape != XREBlueprintShapes.Shape.NONE:
			var size := XREBlueprintShapes.size_of(card.shape, inputs.size())
			card.width = size.x
			card.height = size.y
			card.outline = XREBlueprintShapes.outline(card.shape, inputs.size())
			card.shape_inputs = XREBlueprintShapes.inputs(card.shape, inputs.size())
		elif card.compact:
			card.height = OPERATOR_PAD + maxi((layout[0] as Array).size(), 1) * ROW_HEIGHT
			card.width = _operator_width(graph, block, inputs)
			card.first_row = ((layout[0] as Array).size() - 1) * ROW_HEIGHT * 0.5
		elif card.headed:
			var rows := maxi((layout[0] as Array).size(), (layout[1] as Array).size()) - 1
			card.height = HEAD_HEIGHT + HEAD_GAP * 2.0 + maxi(rows, 0) * ROW_HEIGHT + (0.02 if rows <= 0 else 0.0)
		else:
			card.height = 0.08 + maxi((layout[0] as Array).size(), (layout[1] as Array).size()) * ROW_HEIGHT
			card.first_row = card.height * 0.5 - 0.064
		var cuboid := _solid
		var body_size := Vector3(card.width, card.height, CUBOID_DEPTH if cuboid else CARD_THICKNESS)
		card.face = (CUBOID_DEPTH - CARD_THICKNESS) * 0.5 if cuboid else 0.0
		card.bounds = AABB(-body_size * 0.5, body_size)
		var group := XREBlueprintIcons.group_of(block, inputs, outputs)
		card.normal = _body_materials[card_group(block)]
		card.frame_material = _frame_material
		if archetype:
			var pure := group == XREBlueprintIcons.Group.PURE
			card.normal = _archetype_faces[2 if card.compact else 1 if pure else 0]
			if card.tag and not outputs.is_empty(): card.normal = _tag_face(int((outputs[0] as Array)[1]))
			# A bead is its group's colour, rimmed white as the execution is (D-103).
			if card.bead and not pure:
				card.normal = _head_materials[group]
				card.frame_material = _type_frame(XREBlueprintGraph.EXEC)
			# A pure function is framed in its result's color, as its wire is.
			if pure and _pure_type(block, outputs) >= 0: card.frame_material = _type_frame(_pure_type(block, outputs))
		# An archetype's card is rounded (D-109), picked by its outline as a sign is.
		if card.headed: card.outline = XREBlueprintShapes.rounded_rect(Vector2(card.width, card.height), _corners(block))
		var body: Mesh
		if card.shape != XREBlueprintShapes.Shape.NONE or card.headed: body = XREBlueprintShapes.body(card.outline, body_size.z)
		elif cuboid:
			var box := BoxMesh.new()
			box.size = body_size
			body = box
		else:
			var panel := QuadMesh.new()
			panel.size = Vector2(card.width, card.height)
			body = panel
		card.mesh = XRERig.create_vr_mesh(body, card.normal)
		card.node.add_child(card.mesh)
		if card.bead: _add_bead(card, block, group, outputs)
		elif card.tag: _add_tag(card, block, outputs)
		elif card.shape != XREBlueprintShapes.Shape.NONE: _add_rims(card, block, outputs)
		elif card.headed: _add_rim(card, group != XREBlueprintIcons.Group.PURE)
		else: _add_frame(card, body_size, cuboid)
		if archetype and not card.compact: _add_head(card, block, group, outputs, ((layout[0] as Array)[0] as Dictionary).has("port"))
		elif not card.compact:
			var title := label("%s · %d" % [graph.title_of(block), card.id], 21)
			title.position = Vector3(0, card.height * 0.5 - 0.022, card.face + CARD_THICKNESS * 0.5 + 0.0005)
			card.node.add_child(title)
			# Clear of the plus at the title's right.
			_add_function_marks(card, block, card.height * 0.5 - 0.022, card.face + CARD_THICKNESS * 0.5, 0.045)
		card.plus_point = Vector3(card.width * 0.5 - 0.023, card.height * 0.5 - 0.022, card.face + CARD_THICKNESS * 0.5 + 0.002)
		# Above an operator's small card: inside, they would cover its ports.
		if card.compact: card.plus_point = Vector3(card.width * 0.5 - 0.012, card.height * 0.5 + 0.016, card.face + CARD_THICKNESS * 0.5 + 0.002)
		# An archetype's icon is where the trash was: the trash stands over the card's right corner, as
		# over an operator; an operator's plus goes to its left.
		var trash_point := Vector3(-card.plus_point.x, card.plus_point.y, card.plus_point.z)
		if archetype:
			trash_point = card.plus_point if card.compact else Vector3(card.plus_point.x, card.height * 0.5 + TRASH_RISE, card.plus_point.z)
			if card.compact: card.plus_point.x = -card.plus_point.x
			# Then is on the header's right edge: the plus goes left of it.
			elif ((layout[1] as Array)[0] as Dictionary).has("port"): card.plus_point.x = card.width * 0.5 - 0.05
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
		card.trash_point = trash_point
		card.trash = Node3D.new()
		card.trash.position = card.trash_point
		card.node.add_child(card.trash)
		card.fixed = block.get("kind") in ["entry", "return"]
		if not card.fixed:
			var trash := XRERig.create_vr_mesh(_trash_mesh, _archetype_trash if archetype else _trash_material)
			card.trash.add_child(trash)
			# An archetype's trash, larger, shows while its card is in focus ([method _look_card]).
			if archetype: trash.scale = Vector3.ONE * TRASH_SCALE
		if archetype: card.trash.visible = false
		if _copy_shown and not card.fixed:
			# Over the top edge, at the trash's side: on the card it would cover the title.
			# An operator's trash is over the edge already: the copy goes beside it.
			card.copy_point = Vector3(card.trash_point.x + 0.025, card.trash_point.y, card.trash_point.z) if card.compact \
					else Vector3(card.trash_point.x, card.height * 0.5 + 0.016, card.trash_point.z)
			# An archetype's trash stands over the edge itself: the copy goes left of it, and of
			# its heading's switch, and shows with them under the ray (D-113).
			if archetype: card.copy_point = card.trash_point - Vector3(SWAP_SHIFT * (2.0 if can_head(block) and not card.bead else 1.0), 0, 0)
			card.copy = Node3D.new()
			card.copy.position = card.copy_point
			card.node.add_child(card.copy)
			card.copy.add_child(XRERig.create_vr_mesh(_copy_mesh, _copy_material))
			if archetype: card.copy.visible = false
		# A call of the graph's own function opens its body by a button left of
		# the copy, in their row and shown with them; without the copy, in its
		# place (docs/blueprint_functions.md).
		if XREBlueprintUserFunctions.is_call(block):
			var slot := Vector3(card.trash_point.x + 0.025, card.trash_point.y, card.trash_point.z) if card.compact 					else Vector3(card.trash_point.x, card.height * 0.5 + 0.016, card.trash_point.z)
			if archetype: slot = card.trash_point - Vector3(SWAP_SHIFT, 0, 0)
			card.open_point = card.copy_point - Vector3(SWAP_SHIFT, 0, 0) if card.copy != null else slot
			card.open = Node3D.new()
			card.open.name = "Open"
			card.open.position = card.open_point
			card.node.add_child(card.open)
			card.open.add_child(XRERig.create_vr_mesh(_open_mesh, _open_material))
			if archetype: card.open.visible = false
		_add_rows(card, graph, block, inputs, outputs, layout)
		_ring_untyped(card, block)
		_add_pin_buttons(card, block, archetype, outputs, graph)
		if not chip.is_empty() and _value_mode != XREFeatureSettings.WINDOW: _add_chip(card, block, chip, group)
		if archetype and can_head(block) and not card.bead: _add_swap(card, block)
		if card.bead or card.tag: pass
		elif card.shape != XREBlueprintShapes.Shape.NONE: _add_sign_symbol(card, block, inputs, outputs)
		elif card.compact: _add_symbol(card, block)
		card.labels.assign(card.node.find_children("", "Label3D", true, false))
		var verb := card.node.get_node_or_null(^"Verb") as Label3D
		var member := card.node.get_node_or_null(^"Member") as Label3D
		if verb != null and member != null:
			card.heading = [verb, member]
			card.heading_ends = verb.position.x - text_width(verb.text, 21) * 0.5 + member.position.x + text_width(member.text, 21) * 0.5
		if card.shape != XREBlueprintShapes.Shape.NONE:
			for port: MeshInstance3D in card.ports: card.rim_built.append(port.position)
			for socket: Socket in card.sockets: socket.home = socket.center
		_orient(card)
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
			if is_inline(source) and source["kind"] != "get_variable":
				# From a box's component through its hidden Break (D-105): no link, the variable of the Break's getter.
				wire.variable = split_variable(graph, source)
				wire.component = edge["from_port"]
				inline.append(wire)
			elif is_inline(source):
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
		# A component is a number (D-105).
		if wire.component >= 0: color = COLORS[XREBlueprintGraph.NUMBER]
		_add_wire(wire, color, graph.edges[wire.edge])
		# Drawn at all, the wire a link hides is faint (D-074).
		if wire.link != null: set_wire_seen(wire, &"link", LINK_SEEN)
		_wires.append(wire)
	_build_parts()
	# New cards show the head what the settings say at once, not when it next moves (D-115).
	_face_cards()
	update_wires()
	select_blocks(_selected)
	_paint_focus()
	_show_link_wires()


## The port type a pure [param block]'s frame and icon take, -1 for none: its
## first output's, a Break's what it takes apart (D-140), as Make's is what it
## gives.
static func _pure_type(block: Dictionary, outputs: Array) -> int:
	if block.get("kind") == "break":
		var struct: Dictionary = block.get("struct", {})
		return XREBlueprintGraph.port_type(int(struct["type"])) if not struct.is_empty() else XREBlueprintGraph.VALUE
	return int((outputs[0] as Array)[1]) if not outputs.is_empty() else -1


## An archetype's header (D-099) on [param card] of [param block], of
## [param group]: a band in the group's color with the icon on its circle,
## then the title; a pure function has no band, its icon in its result's
## color. A call without an icon shows ƒ, circled with execution.
func _add_head(card: Card, block: Dictionary, group: int, outputs: Array, in_port: bool = false) -> void:
	var front := card.face + CARD_THICKNESS * 0.5
	var row := card.height * 0.5 - HEAD_HEIGHT * 0.5
	var pure := group == XREBlueprintIcons.Group.PURE
	var tint := COLORS[_pure_type(block, outputs)] if pure and _pure_type(block, outputs) >= 0 else Color.WHITE
	if not pure:
		# Its top corners as the card's (D-109).
		var corners := _corners(block)
		# Thin and just over the face (D-110): 0.5 mm deep it reached past the
		# labels and icons on it, and the depth test hid them out of focus.
		var band := XREBlueprintShapes.body(XREBlueprintShapes.rounded_rect(Vector2(card.width, HEAD_HEIGHT), Vector4(corners.x, corners.y, 0, 0)), 0.0001)
		var head := XRERig.create_vr_mesh(band, _head_materials[group])
		head.name = "Head"
		head.position = Vector3(0, row, front + 0.0002)
		card.node.add_child(head)
	var icon: Variant = XREBlueprintIcons.icon_of(block, _class_icon)
	var fallback: bool = icon == null and block.get("kind") == "call"
	var size := PURE_ICON_SIZE if pure else ICON_SIZE
	# Clear of In on the header's left edge (D-101).
	var start := -card.width * 0.5 + (0.034 if in_port else 0.012)
	var center := Vector3(start + size * 0.5, row, front)
	# Every icon of a block with execution stands on the header's dark circle: a glyph, an image, ƒ.
	if not pure: _add_icon(card, "Circle", XREBlueprintIcons.circle(ICON_PIXELS), Color.WHITE, size, center + Vector3(0, 0, 0.0005))
	if icon is Texture2D:
		_add_icon(card, "Icon", icon, Color.WHITE, size * IMAGE_SHARE, center + Vector3(0, 0, 0.0007))
	elif icon is StringName:
		var glyph: StringName = icon
		_add_icon(card, "Icon", XREBlueprintIcons.texture(glyph, ICON_PIXELS, not pure), Color.WHITE if glyph in XREBlueprintIcons.COLORED or not pure else tint, size, center + Vector3(0, 0, 0.0007))
	if fallback:
		var sign := label("ƒ", PURE_FALLBACK_SIZE if pure else FALLBACK_SIZE)
		sign.name = "Fallback"
		sign.modulate = tint
		sign.position = center + Vector3(0, 0, 0.0008)
		card.node.add_child(sign)
	var left := start + (size + 0.008 if icon != null or fallback or not pure else 0.0)
	if heading_of(block) == XREFeatureSettings.MEMBER:
		# One line (D-107): the verb, then the member in its colour, as words —
		# "On Ready", "Set Light Energy"; the member's trigger opens its petals.
		var verb := label(verb_of(block), 21)
		verb.name = "Verb"
		verb.position = Vector3(left + text_width(verb.text, 21) * 0.5, row, front + 0.0005)
		card.node.add_child(verb)
		# A Break's or a Make's type or class stays as written: Vector3, not Vector 3.
		var member := member_of(block) if member_of(block).contains(" ") or block.get("kind") in ["break", "make"] else member_of(block).capitalize()
		var after := left + text_width(verb.text + " ", 21)
		var member_label := label(member, 21)
		member_label.name = "Member"
		member_label.modulate = MEMBER_COLOR
		member_label.position = Vector3(after + text_width(member, 21) * 0.5, row, front + 0.0005)
		card.node.add_child(member_label)
		var key := XREBlueprintTokens.member_key(block)
		if not key.is_empty():
			var socket := Socket.new()
			socket.kind = MEMBER
			socket.key = key
			socket.type = XREBlueprintGraph.OBJECT
			socket.center = member_label.position
			socket.size = Vector3(text_width(member, 21) + 0.006, 0.022, 0.004)
			socket.visual = member_label
			socket.base_scale = member_label.scale
			socket.value = member
			card.sockets.append(socket)
		return
	# An Entry says its function's name.
	var text := operation_of(block) if block.get("kind") != "entry" or _function.is_empty() else str(_function.get("name", "Entry"))
	var title := label(text, 21)
	title.name = "Title"
	title.position = Vector3(left + text_width(text, 21) * 0.5, row, front + 0.0005)
	card.node.add_child(title)
	_add_function_marks(card, block, row, front)


## On the header's right, clear of Then — on a classic card's title row,
## [param margin] from its edge —: the hourglass of a call whose body waits,
## the pure switch of a body's Entry, the word pure and its pill
## (docs/blueprint_functions.md).
func _add_function_marks(card: Card, block: Dictionary, row: float, front: float, margin: float = -1.0) -> void:
	var executes := not bool(_function.get("pure", false)) if block.get("kind") == "entry" else not XREBlueprintGraph.is_pure(block)
	var right := card.width * 0.5 - (margin if margin >= 0.0 else 0.034 if executes else 0.012)
	if XREBlueprintUserFunctions.is_call(block) and bool((block["function"] as Dictionary).get("awaits", false)):
		_add_icon(card, "Waits", XREBlueprintIcons.texture(&"waits", ICON_PIXELS, false), WAIT_COLOR, ICON_SIZE * 0.7, Vector3(right - ICON_SIZE * 0.35, row, front + 0.0007))
	if block.get("kind") != "entry" or _function.is_empty(): return
	card.pure_on = bool(_function.get("pure", false))
	card.pure_point = Vector3(right - PURE_SIZE.x * 0.5, row, front + 0.0006)
	card.pure_switch = Node3D.new()
	card.pure_switch.name = "Pure"
	card.pure_switch.position = card.pure_point
	card.node.add_child(card.pure_switch)
	var pill := XRERig.create_vr_mesh(XREBlueprintShapes.body(XREBlueprintShapes.stadium(PURE_SIZE), 0.0006), material(PURE_ON if card.pure_on else PURE_OFF, true))
	pill.name = "Pill"
	card.pure_switch.add_child(pill)
	var knob := XRERig.create_vr_mesh(XREBlueprintShapes.body(XREBlueprintShapes.circle(PURE_SIZE.y * 0.36), 0.0006), material(Color("e9edf5"), true))
	knob.name = "Knob"
	knob.position = Vector3((1.0 if card.pure_on else -1.0) * (PURE_SIZE.x - PURE_SIZE.y) * 0.5, 0, 0.0008)
	card.pure_switch.add_child(knob)
	var word := label("pure", 16)
	word.modulate = Color(1, 1, 1, 0.62)
	word.position = Vector3(-PURE_SIZE.x * 0.5 - 0.004 - text_width("pure", 16) * 0.5, 0, 0.0008)
	card.pure_switch.add_child(word)


## A pin of a body's Entry or Return without a type yet is a grey ring, as the
## mockup's: its port grey with a dark middle (docs/blueprint_functions.md).
func _ring_untyped(card: Card, block: Dictionary) -> void:
	var kind := str(block.get("kind", ""))
	if not kind in ["entry", "return"] or _function.is_empty(): return
	var pins: Array = _function.get("inputs" if kind == "entry" else "outputs", [])
	var offset := 0 if bool(_function.get("pure", false)) else 1
	for index: int in pins.size():
		if XREBlueprintUserFunctions.is_typed(pins[index]): continue
		var port := index + offset + (card.inputs.size() if kind == "entry" else 0)
		if port >= card.ports.size() or card.ports[port] == null: continue
		var mesh := card.ports[port]
		mesh.material_override = material(PIN_MARK_COLOR, true)
		var middle := XRERig.create_vr_mesh(_sphere_mesh, material(XREBlueprintIcons.BODY, true))
		middle.name = "Untyped"
		middle.scale = Vector3.ONE * 0.6
		# Just in front of the port's middle: its grey stays a rim around it.
		middle.position = mesh.position + Vector3(0, 0, PORT_RADIUS * 0.8)
		card.node.add_child(middle)


## The box of an Entry's pure switch, its word and pill, around [member Card.pure_point].
func _pure_box(card: Card) -> AABB:
	var width := PURE_SIZE.x + text_width("pure", 16) + 0.008
	var center := card.pure_point - Vector3((text_width("pure", 16) + 0.004) * 0.5, 0, 0)
	var size := Vector3(width, 0.024, 0.012) * card.pure_switch.scale.x
	return AABB(center - size * 0.5, size)


## Puts an archetype's rows in their places (D-101): its execution In first,
## in the header, or nothing there; its target next, on the row under the
## header; on the right the first execution output in the header (not
## Branch's True), nothing beside the target. An event's policy leaves the
## rows for a chip in the header: its key is returned, empty for none.
func _head_layout(block: Dictionary, inputs: Array, outputs: Array, layout: Array) -> String:
	var left: Array[Dictionary] = layout[0]
	var right: Array[Dictionary] = layout[1]
	var chip := ""
	for entry: Dictionary in left.duplicate():
		if entry.get("square", "") == "policy":
			left.erase(entry)
			chip = "policy"
	var first: Dictionary = {"blank": true}
	var target: Dictionary = {}
	for entry: Dictionary in left:
		if not entry.has("port"):
			if entry.has("source") or entry.has("variable"): target = entry
			continue
		var spec: Array = inputs[int(entry["port"])]
		if first.has("blank") and int(spec[1]) == XREBlueprintGraph.EXEC: first = entry
		elif spec.size() > 2 and spec[2] == "target": target = entry
	left.erase(first)
	left.erase(target)
	if not target.is_empty(): left.push_front(target)
	first["head"] = true
	left.push_front(first)
	var then: Dictionary = {"blank": true}
	# Branch, Sequence and Switch keep every output a row of its own (D-106, D-138).
	if not block.get("kind") in ["branch", "sequence", "switch"]:
		for entry: Dictionary in right:
			if entry.has("port") and int((outputs[int(entry["port"])] as Array)[1]) == XREBlueprintGraph.EXEC:
				then = entry
				break
	right.erase(then)
	if not target.is_empty(): right.push_front({"blank": true})
	then["head"] = true
	right.push_front(then)
	return chip


## An event's policy as a chip in [param card]'s header (D-106): a narrow
## pill darker than the header of [param group], its policy's icon and word,
## left of Then. Its socket is the policy's: the trigger opens the fan of
## parallel, ignore and restart, as the token did (D-062).
func _add_chip(card: Card, block: Dictionary, key: String, group: int) -> void:
	var value := str((block["params"] as Dictionary).get(key, ""))
	var text := label(value, CHIP_TEXT)
	var size := Vector2(0.012 + CHIP_ICON + 0.004 + text_width(value, CHIP_TEXT) + 0.01, CHIP_HEIGHT)
	var center := Vector3(card.width * 0.5 - 0.03 - size.x * 0.5, card.height * 0.5 - HEAD_HEIGHT * 0.5, card.face + CARD_THICKNESS * 0.5 + 0.0008)
	var chip := Node3D.new()
	chip.name = "Chip"
	chip.position = center
	card.node.add_child(chip)
	var outline := XREBlueprintShapes.stadium(size)
	var shade := XREBlueprintIcons.HEADS[group] * CHIP_SHADE
	chip.add_child(XRERig.create_vr_mesh(XREBlueprintShapes.body(outline, 0.001), XREBlueprintBoxes.under_material(Color(shade, 1.0))))
	chip.add_child(XRERig.create_vr_mesh(XREBlueprintShapes.ring(outline, 0.0, 0.0012, 0.0006), XREBlueprintBoxes.under_material(CHIP_BORDER)))
	var icon := {"parallel": &"parallel", "ignore": &"ignore", "restart": &"loop"}.get(value, &"") as StringName
	var left := -size.x * 0.5 + 0.008
	_add_icon_to(chip, XREBlueprintIcons.texture(icon, ICON_PIXELS, true), Color.WHITE, CHIP_ICON, Vector3(left + CHIP_ICON * 0.5, 0, 0.001))
	text.position = Vector3(left + CHIP_ICON + 0.004 + text_width(value, CHIP_TEXT) * 0.5, 0, 0.0012)
	chip.add_child(text)
	var socket := Socket.new()
	socket.kind = SQUARE
	socket.key = key
	socket.type = XREBlueprintTokens.color_type(value, key)
	socket.center = center
	socket.size = Vector3(size.x, size.y, 0.01)
	socket.visual = chip
	socket.text = text
	socket.value = value
	card.sockets.append(socket)


## A square of [param texture] under [param parent], [param size] across at [param point], tinted [param tint].
func _add_icon_to(parent: Node3D, texture: Texture2D, tint: Color, size: float, point: Vector3) -> void:
	if texture == null: return
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * size
	var face := material(tint, true)
	face.albedo_texture = texture
	var visual := XRERig.create_vr_mesh(quad, face)
	visual.position = point
	parent.add_child(visual)


## Branch's True and False tabs on [param card]'s right edge at [param point]
## (D-106): a strip of the tab's colour, faint, and its tick or cross.
## Its left end is round, as the mockup's (D-107), and the mark stands just
## before the output's name [param text].
func _add_tab(card: Card, point: Vector3, index: int, text: String) -> void:
	var color := TAB_COLORS[index]
	var mark := card.width * 0.5 - 0.022 - text_width(text, 18) - 0.011
	# Both tabs as wide as False's needs (D-111): from just before its cross to the edge.
	var width := 0.022 + maxf(text_width("True", 18), text_width("False", 18)) + 0.011 + TAB_LEAD
	var outline := XREBlueprintShapes.rounded_rect(Vector2(width, TAB_HEIGHT), Vector4(TAB_HEIGHT * 0.5, 0, 0, TAB_HEIGHT * 0.5))
	var tab := XRERig.create_vr_mesh(XREBlueprintShapes.body(outline, 0.0005), XREBlueprintBoxes.under_material(XREBlueprintIcons.BODY.lerp(color, TAB_TINT)))
	tab.name = "TabTrue" if index == 0 else "TabFalse"
	tab.position = Vector3(card.width * 0.5 - width * 0.5, point.y, card.face + CARD_THICKNESS * 0.5 + 0.0004)
	card.node.add_child(tab)
	_add_icon_to(card.node, XREBlueprintIcons.texture(&"true" if index == 0 else &"false", ICON_PIXELS, false), color, 0.014, Vector3(mark, point.y, card.face + CARD_THICKNESS * 0.5 + 0.0008))


## The switch of [param card]'s heading (D-101): ⇄ left of its trash, shown
## with it, in the member's colour while the card says its member.
func _add_swap(card: Card, block: Dictionary) -> void:
	card.swap_point = card.trash_point - Vector3(SWAP_SHIFT, 0, 0)
	card.swap = Node3D.new()
	card.swap.position = card.swap_point
	card.node.add_child(card.swap)
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * SWAP_SIZE
	var face := material(MEMBER_COLOR if heading_of(block) == XREFeatureSettings.MEMBER else Color.WHITE, true)
	face.albedo_texture = XREBlueprintIcons.texture(&"swap", ICON_PIXELS, false)
	card.swap.add_child(XRERig.create_vr_mesh(quad, face))
	card.swap.visible = false

## A square of [param texture] on [param card], [param size] across at
## [param point], tinted [param tint]: a part of an archetype's icon (D-099).
func _add_icon(card: Card, part: String, texture: Texture2D, tint: Color, size: float, point: Vector3) -> void:
	if texture == null: return
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * size
	var face := material(tint, true)
	face.albedo_texture = texture
	var visual := XRERig.create_vr_mesh(quad, face)
	visual.name = part
	visual.position = point
	card.node.add_child(visual)


## An archetype's frame in the color of port type [param type], made once (D-099).
func _type_frame(type: int) -> Material:
	if not _type_frames.has(type): _type_frames[type] = material(COLORS[type], true)
	return _type_frames[type]


## Whether [param block] is a bead as an archetype (D-103): Delay, Get Time
## and Random from + System on; from All with icons, every block with an icon
## of its own — not ƒ — and at most three rows a side ([param layout]), not an event.
func _is_bead(block: Dictionary, inputs: Array, layout: Array) -> bool:
	var level := SHRINK_LEVELS.find(_shrink)
	if level < 2: return false
	var function: Dictionary = block.get("function", {})
	var key := "%s.%s" % [function.get("class", ""), function.get("name", "")]
	var system := key in ["XREBlueprintLibrary.delay", "XREBlueprintLibrary.get_time"] or str(function.get("category", "")).ends_with("· random")
	if system: return true
	if level < 3 or block.get("kind") == "signal" or XREBlueprintIcons.icon_of(block, _class_icon) == null: return false
	return (layout[0] as Array).size() <= 3 and (layout[1] as Array).size() <= 3


## Puts a bead's left rows in its arc's order (D-103): its execution In at the
## top, its target next, the rest under them.
func _bead_layout(block: Dictionary, inputs: Array, layout: Array) -> void:
	var left: Array[Dictionary] = layout[0]
	var first: Dictionary = {}
	var target: Dictionary = {}
	for entry: Dictionary in left:
		if entry.has("source") or entry.has("variable"): target = entry
		if not entry.has("port"): continue
		var spec: Array = inputs[int(entry["port"])]
		if first.is_empty() and int(spec[1]) == XREBlueprintGraph.EXEC: first = entry
		elif spec.size() > 2 and spec[2] == "target": target = entry
	for entry: Dictionary in [target, first]:
		if entry.is_empty(): continue
		left.erase(entry)
		left.push_front(entry)


## A tag's face of port type [param type]'s colour, made once (D-106).
func _tag_face(type: int) -> ShaderMaterial:
	if not _tag_faces.has(type): _tag_faces[type] = _face(_card_shader, XREBlueprintIcons.BODY.lerp(COLORS[type], TAG_TINT))
	return _tag_faces[type]


## A Get Variable's tag (D-106): its rim in its type's colour, a dot of its
## type's shape and its name, as the mockup's.
func _add_tag(card: Card, block: Dictionary, outputs: Array) -> void:
	var front := card.bounds.end.z + 0.0004
	card.frame = XRERig.create_vr_mesh(XREBlueprintShapes.ring(card.outline, 0.0, RIM, front), card.frame_material)
	card.frame.set_meta(&"painted", true)
	card.node.add_child(card.frame)
	var type := int((outputs[0] as Array)[1]) if not outputs.is_empty() else XREBlueprintGraph.VALUE
	var dot := XRERig.create_vr_mesh(XREBlueprintShapes.port_mesh(type if _port_shapes else XREBlueprintGraph.NUMBER, PORT_RADIUS, PORT_DEPTH * 2.0), material(COLORS[type], true))
	dot.scale = Vector3.ONE * 0.55
	dot.position = Vector3(-card.width * 0.5 + 0.017, 0, front + 0.0004)
	card.node.add_child(dot)
	var named := str((block["params"] as Dictionary).get("variable", ""))
	var text := label(named if not named.is_empty() else "variable", 21)
	text.name = "Title"
	text.modulate = COLORS[type].lerp(Color.WHITE, 0.5)
	text.position = Vector3(-card.width * 0.5 + 0.03 + text_width(text.text, 21) * 0.5, 0, front + 0.0006)
	card.node.add_child(text)


## A bead's rim, its icon inside — white on a function, its result's colour
## on a pure function — and its name under it for the ray (D-103).
func _add_bead(card: Card, block: Dictionary, group: int, outputs: Array) -> void:
	var front := card.bounds.end.z + 0.0004
	card.frame = XRERig.create_vr_mesh(XREBlueprintShapes.ring(card.outline, 0.0, RIM, front), card.frame_material)
	card.frame.set_meta(&"painted", true)
	card.node.add_child(card.frame)
	var pure := group == XREBlueprintIcons.Group.PURE
	var tint := COLORS[_pure_type(block, outputs)] if pure and _pure_type(block, outputs) >= 0 else Color.WHITE
	var radius := card.width * 0.5
	var icon: Variant = XREBlueprintIcons.icon_of(block, _class_icon)
	var center := Vector3(0, 0, front + 0.0004)
	var function: Dictionary = block.get("function", {})
	var face := &"dial" if str(function.get("name", "")) == "get_time" else &"dice" if str(function.get("category", "")).ends_with("· random") else &""
	if not face.is_empty(): _add_icon(card, "Icon", XREBlueprintIcons.texture(face, ICON_PIXELS * 2, false), Color.WHITE, radius * BEAD_FACE, center)
	elif icon is Texture2D: _add_icon(card, "Icon", icon, Color.WHITE, radius * BEAD_IMAGE, center)
	elif icon is StringName:
		var glyph: StringName = icon
		_add_icon(card, "Icon", XREBlueprintIcons.texture(glyph, ICON_PIXELS, false), Color.WHITE if glyph in XREBlueprintIcons.COLORED else tint, radius * BEAD_ICON, center)
	card.tip = label(operation_of(block), TIP_SIZE)
	card.tip.name = "Tip"
	card.tip.position = Vector3(0, -radius - BEAD_TIP, front + 0.0006)
	card.tip.visible = false
	card.node.add_child(card.tip)



## The shape of [param block]'s sign as an archetype (D-100), or none: an
## operator by its group — arithmetic a circle, from four inputs a column
## (D-136) —, Append a card, a math function by its inputs from
## [constant XREFeatureSettings.NODE_SHRINK] + Math on.
func _sign_shape(block: Dictionary, inputs: Array, outputs: Array) -> XREBlueprintShapes.Shape:
	if XREBlueprintGraph.is_operator(block):
		match XREBlueprintOperators.group_of(XREBlueprintGraph.operator_of(block)):
			XREBlueprintOperators.MATH: return XREBlueprintShapes.Shape.CIRCLE if inputs.size() <= 3 else XREBlueprintShapes.Shape.COLUMN
			XREBlueprintOperators.LOGIC: return XREBlueprintShapes.Shape.PILL
			XREBlueprintOperators.TEXT: return XREBlueprintShapes.Shape.NONE
		return XREBlueprintShapes.Shape.DIAMOND
	# + Math and every level after it (D-100, D-103).
	if SHRINK_LEVELS.find(_shrink) >= 1 and not XREBlueprintShapes.word_of(block, inputs, outputs).is_empty():
		return XREBlueprintShapes.Shape.CIRCLE if inputs.size() <= 2 else XREBlueprintShapes.Shape.OVAL
	return XREBlueprintShapes.Shape.NONE


## The corners of [param block]'s archetype card (D-109): top left, top right,
## bottom right, bottom left; an event's top left larger.
static func _corners(block: Dictionary) -> Vector4:
	return Vector4(HAT if block.get("kind") == "signal" else CORNER, CORNER, CORNER, CORNER)


## A rounded archetype card's frame along its outline (D-109), as the frame a
## selection and the focus paint, over its header; with [param headed] a
## line of it between the header and the body too (D-110).
func _add_rim(card: Card, headed: bool) -> void:
	var front := card.bounds.end.z + 0.0004
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.append_from(XREBlueprintShapes.ring(card.outline, 0.0, 0.0012, front), 0, Transform3D.IDENTITY)
	if headed:
		var line := XREBlueprintShapes.rounded_rect(Vector2(card.width - 0.0024, 0.0012), Vector4.ZERO)
		surface.append_from(XREBlueprintShapes.body(line, 0.0001), 0, Transform3D(Basis.IDENTITY, Vector3(0, card.height * 0.5 - HEAD_HEIGHT, front)))
	card.frame = XRERig.create_vr_mesh(surface.commit(), card.frame_material)
	card.frame.set_meta(&"painted", true)
	card.node.add_child(card.frame)


## A sign's rim in its result's color, as the frame a selection and the focus
## paint, and a math function's second rim inside it, fainter (D-100).
func _add_rims(card: Card, block: Dictionary, outputs: Array) -> void:
	var front := card.bounds.end.z + 0.0004
	card.frame = XRERig.create_vr_mesh(XREBlueprintShapes.ring(card.outline, 0.0, RIM, front), card.frame_material)
	card.frame.set_meta(&"painted", true)
	card.node.add_child(card.frame)
	if XREBlueprintGraph.is_operator(block) or outputs.is_empty(): return
	var color := COLORS[int((outputs[0] as Array)[1])]
	var rim := XRERig.create_vr_mesh(XREBlueprintShapes.ring(card.outline, INNER_INSET, INNER_RIM, front), material(Color(color, INNER_SEEN), true))
	rim.name = "Rim"
	card.node.add_child(rim)


## A sign's symbol or name in the middle, in its result's color (D-100); an
## oval's a little right, clear of its three inputs' tokens.
func _add_sign_symbol(card: Card, block: Dictionary, inputs: Array, outputs: Array) -> void:
	var text := XREBlueprintGraph.symbol(block) if XREBlueprintGraph.is_operator(block) else XREBlueprintShapes.word_of(block, inputs, outputs)
	var size := SYMBOL_SIZE if text.length() == 1 else SIGN_WORD_SIZE if text.length() <= 3 else SIGN_LONG_SIZE
	var symbol := label(text, size)
	symbol.modulate = COLORS[card.output_types[0]] if not card.output_types.is_empty() else Color.WHITE
	symbol.position = Vector3(0.006 if card.shape == XREBlueprintShapes.Shape.OVAL else 0.0, 0, card.bounds.end.z + 0.0008)
	symbol.name = "Symbol"
	card.node.add_child(symbol)


## The variable whose components the hidden Break [param breaker] gives (D-105):
## that of the inline Get Variable wired into it, empty for none.
static func split_variable(graph: XREBlueprintGraph, breaker: Dictionary) -> String:
	for edge: Dictionary in graph.edges:
		if edge["to"] != breaker["id"]: continue
		var getter := graph.find_node(edge["from"])
		if getter.get("kind") == "get_variable": return str((getter["params"] as Dictionary).get("variable", ""))
	return ""


## Whether the drawer of components of [param variable]'s box is shut (D-108):
## shut unless its editor-only vr_collapsed is false (D-114), open while a
## hidden Break wires its components.
static func drawer_shut(graph: XREBlueprintGraph, variable: Dictionary) -> bool:
	if not bool(variable.get("vr_collapsed", true)): return false
	var name := str(variable.get("name", ""))
	for block: Dictionary in graph.nodes:
		if is_split_break(block) and split_variable(graph, block) == name: return false
	return true


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
	wire.color = color
	wire.mesh = create_scene_wire(color)
	wire.normal = wire.mesh.material_override
	# An execution wire is white: thicker alone, it hardly shows under the ray, so it takes the focus's gold (D-132).
	wire.lit = wire_material(XREBlueprintFocus.FRAME if color.s < 0.1 else color, LIT_WIRE_GROW)
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
			bends.append(Vector3(at.x * PIXEL_SIZE, -at.y * PIXEL_SIZE, point.z - _depth))
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
## A Break marked inline is one too with Composite values on Split (D-105): its
## wires come from its variable's box's components.
func is_inline(block: Dictionary) -> bool:
	if block.is_empty() or not bool(block.get("vr_inline", false)) or _variable_mode != XREFeatureSettings.BOXES: return false
	if block.get("kind") == "get_variable": return true
	return is_split_break(block) and _composite == XREFeatureSettings.SPLIT


## Whether [param block] is a Break of a box's components (D-105): a call of
## the library's break_vector2, break_vector3 or break_color marked inline.
static func is_split_break(block: Dictionary) -> bool:
	if block.get("kind") != "call" or not bool(block.get("vr_inline", false)): return false
	var function: Dictionary = block.get("function", {})
	return str(function.get("class", "")) == "XREBlueprintLibrary" and str(function.get("name", "")).begins_with("break_")


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


## A stand-in of card [param id] for its copy on the way to its place (D-114):
## the card's node duplicated at the card's scale, without its buttons and
## name tip, centred at its origin; null for no card.
func stand_in(id: int) -> Node3D:
	var card := _find_card(id)
	if card == null: return null
	var copy := card.node.duplicate() as Node3D
	var buttons: Array[Node3D] = [card.plus, card.trash, card.copy, card.open, card.swap, card.tip, card.pin_plus, card.hidden_chip]
	buttons.append_array(card.pin_marks)
	for button: Node3D in buttons:
		if button != null: (copy.get_child(button.get_index()) as Node3D).visible = false
	copy.transform = Transform3D(Basis.from_scale(card.node.global_basis.get_scale()), Vector3.ZERO)
	return copy


## Graph coordinates of a workspace point: the inverse of [method position_from_block] without depth.
func block_position(point: Vector3) -> Vector2:
	return Vector2(point.x, -point.y) / PIXEL_SIZE + _offset


## The VR depth a block at workspace point [param point] keeps: the depth part of
## the inverse of [method position_from_block].
func block_depth(point: Vector3) -> float:
	return point.z + _depth


## Desktop XY and editor-only depth describe the same card; compilation ignores depth.
func position_from_block(block: Dictionary) -> Vector3:
	var point: Vector2 = block["position"] - _offset
	return Vector3(point.x * PIXEL_SIZE, -point.y * PIXEL_SIZE, float(block.get("vr_depth", 0.0)) - _depth)


## Where the box of each of [param graph]'s variables stands, in the canvas's
## space (D-078): where it was put, as a card's place is kept — graph XY in
## [code]vr_position[/code], depth in [code]vr_depth[/code]. A box never put
## anywhere keeps its place in the shelf's row below the cards (D-052). They are
## the file's graph's: while a body is shown, they stay where they were.
func _box_places(graph: XREBlueprintGraph) -> Dictionary[String, Vector3]:
	var shelf := _shelf(graph)
	var left := shelf.x
	var low := shelf.y
	var row := Vector3(left + XREBlueprintBoxes.BOX_SIZE.x * 0.5, low - XREBlueprintBoxes.BELOW - XREBlueprintBoxes.BOX_SIZE.y * 0.5, 0.0)
	var places: Dictionary[String, Vector3] = {}
	for index: int in graph.variables.size():
		var variable: Dictionary = graph.variables[index]
		var placed: Variant = variable.get("vr_position")
		if placed is Vector2:
			var point: Vector2 = (placed as Vector2) - _box_offset()
			places[str(variable["name"])] = Vector3(point.x * PIXEL_SIZE, -point.y * PIXEL_SIZE, float(variable.get("vr_depth", 0.0)))
		else: places[str(variable["name"])] = row + Vector3.RIGHT * XREBlueprintBoxes.SPACING * index
	return places


## The graph XY at the canvas's origin the boxes of the variables stand by: the
## file's graph's, whichever graph is shown.
func _box_offset() -> Vector2:
	return _offset if _function.is_empty() else _root_offset


## Graph coordinates a box at workspace point [param point] keeps in [code]vr_position[/code].
func box_position(point: Vector3) -> Vector2:
	return Vector2(point.x, -point.y) / PIXEL_SIZE + _box_offset()


## The left edge and the bottom of the cards the row of boxes stands
## under: of the file's graph, kept while a function's body is shown, so that the
## row stays where it was (docs/blueprint_functions.md).
func _shelf(graph: XREBlueprintGraph) -> Vector2:
	if not graph.function_signature.is_empty() and _shelf_known: return _shelf_at
	var left := INF
	var low := INF
	for card: Card in _cards:
		left = minf(left, card.node.position.x - card.width * 0.5)
		low = minf(low, card.node.position.y - card.height * 0.5)
	if is_inf(left):
		left = -0.2
		low = 0.0
	if graph.function_signature.is_empty():
		_shelf_at = Vector2(left, low)
		_shelf_known = true
	return Vector2(left, low)


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
		if _cards[index].id != blocks[index]["id"]: return false
	for index: int in _cards.size():
		var card := _cards[index]
		card.base = position_from_block(blocks[index])
		card.block_yaw = yaw_of(blocks[index])
		card.yaw = card.block_yaw
	# A turned card may join or leave a part (D-115).
	_build_parts()
	_face_cards()
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
	card.held_face = INF
	var state := document.graph.snapshot()
	# Its place in the graph, its part's turn undone; its yaw as its own (D-115).
	var point := _unshown(card, card.node.position)
	for block: Dictionary in state["nodes"]:
		if block["id"] == id:
			block["position"] = Vector2(point.x, -point.y) / PIXEL_SIZE + _offset
			block["vr_depth"] = block_depth(point)
			if is_zero_approx(card.yaw): block.erase("vr_rotation")
			else: block["vr_rotation"] = Vector3(0, card.yaw, 0)
	return document.perform(document.commit.bind("Move Blocks", state), &"vr_graph")


## Commits the places of the cards of [param ids], moved together (D-122), as
## one step of the graph's history, as [method commit_move] one card's.
func commit_moves(document: XREBlueprintDocument, ids: Array[int]) -> bool:
	var state := document.graph.snapshot()
	for block: Dictionary in state["nodes"]:
		var card := _find_card(int(block["id"])) if ids.has(block["id"]) else null
		if card == null: continue
		block["position"] = Vector2(card.node.position.x, -card.node.position.y) / PIXEL_SIZE + _offset
		block["vr_depth"] = block_depth(card.node.position)
		block.erase("vr_rotation")
	return document.perform(document.commit.bind("Move Blocks", state), &"vr_graph")


## Moves the cards of [param ids] from [param starts] by [param shift], in
## the canvas's space, along with a card being held (D-122): live geometry
## only, as [method preview_move], the wires bent once for all of them.
func preview_group(ids: Array[int], starts: Array[Vector3], shift: Vector3) -> void:
	for index: int in ids.size():
		var card := _find_card(ids[index])
		if card == null: continue
		card.node.position = starts[index] + shift
		_orient(card)
	update_wires()


## Live geometry only; a preview never modifies the resource or undo history.
func preview_move(id: int, point: Vector3) -> void:
	var card := _find_card(id)
	if card == null: return
	card.node.position = point
	_orient(card)
	update_wires()


## Previews position and orientation without touching the graph resource; a
## turn of a held card's yaw goes back to its block's (D-115).
func preview_transform(id: int, pose: Transform3D) -> void:
	var card := _find_card(id)
	if card == null: return
	card.yaw = card.block_yaw
	card.held_face = INF
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
		entry["vr_position"] = Vector2(point.x, -point.y) / PIXEL_SIZE + _box_offset()
		entry["vr_depth"] = point.z
	return document.perform(document.commit.bind("Move Variable", state), &"vr_graph")


## Shows the box of [param variable] at [param point] (the canvas's space) without editing the graph (D-078).
func preview_box_move(variable: String, point: Vector3) -> void:
	_boxes.move_box(variable, point)
	update_wires()


## Keeps a captured point of the box of [param variable] on the rod (D-078):
## [param contact] (global) is where [param local_contact], a point of the
## box, goes, in the graph's orientation; the box turns to the head about its center (D-090).
func preview_box_grab(variable: String, contact: Vector3, local_contact: Vector3) -> void:
	preview_box_move(variable, to_local(contact) - local_contact)


## Makes the cards, wires and boxes that cover an input in use, seen from
## [param eye], see-through, and gives the others back their look (D-066):
## the inputs are the first [param count] spheres of [param targets]
## ([XREBlueprintFade]). Only a card that changes is touched.
func fade_covering(eye: Vector3, targets: PackedVector4Array, count: int) -> void:
	var arrows_change := false
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
		arrows_change = true
	if arrows_change: _lay_arrows()
	_boxes.fade_covering(eye, targets, count)


## Whether the card of block [param id] is see-through, covering an input (D-066).
func is_faded(id: int) -> bool:
	var card := _find_card(id)
	return card != null and card.faded


## Turns the nodes that face the head towards it without moving their centers or
## editing the graph, and the variables' boxes with them (D-090); turns the graph
## or its parts as Graph turn says, mirrors cards as Card mirror says, and turns
## round or flips the pins of the cards that don't face the head as Node back and
## Pins say (D-115), [param delta] seconds after the last call (0: at once).
## The head is kept for a switch of the settings.
func face_user(head: Vector3, delta: float = 0.0) -> void:
	_arrow_clock += delta
	var turned := _turn_parts(head, delta)
	if not turned and _faces_user and head.is_equal_approx(_head_position) and global_transform.is_equal_approx(_view_transform):
		if _runs_arrows(): _lay_arrows()
		return
	_faces_user = true
	_head_position = head
	_view_transform = global_transform
	_boxes.face(head, _facing != XREFeatureSettings.OFF)
	_face_cards()
	update_wires()


## Decides what each card shows the last head and turns it so (D-115): its part
## mirrored or not, turned round, its pins on its back, its sign's ports on the rim.
func _face_cards() -> void:
	for part: Part in _parts: _mirror_part(part)
	if _card_mirror and _turn_mode == XREFeatureSettings.FIXED: _sum_flows()
	var local_head := to_local(_head_position)
	for card: Card in _cards:
		if _faces_user: _decide_sides(card, local_head)
		_orient(card)
	if _rim_ports and _faces_user: _lay_rims()


## Nodes that face the head face its last position square on, tilting up or down
## to it too, their rows level (D-061, after D-034 turned them around the vertical
## only); the others stand at their yaw in their part, turned with it, and turned
## round while they show their face from behind (D-115). A mirrored card's x is scaled by -1.
func _orient(card: Card) -> void:
	var mirror := Basis.from_scale(Vector3(-1, 1, 1)) if card.mirrored else Basis.IDENTITY
	if not _faces(card): card.node.basis = Basis(Vector3.UP, card.yaw + _part_turn(card) + (PI if card.turned_round else 0.0)) * mirror
	elif _faces_user: card.node.global_basis = XREBlueprintPetals.face(card.node.global_position, _head_position, Vector3.UP) * mirror


## The turn of [param card]'s part about its centre: 0 while the whole graph turns, which turns the canvas itself (D-115).
func _part_turn(card: Card) -> float:
	return _parts[card.part].turn if _by_parts and card.part < _parts.size() else 0.0


## Where [param point], a place in the graph, is shown for [param card]: turned with its part about the part's centre (D-115).
func _shown(card: Card, point: Vector3) -> Vector3:
	if not _by_parts or card.part >= _parts.size(): return point
	var part := _parts[card.part]
	return part.pivot + Basis(Vector3.UP, part.turn) * (point - part.pivot)


## The place in the graph [param point], shown for [param card], stands for: [method _shown] undone.
func _unshown(card: Card, point: Vector3) -> Vector3:
	if not _by_parts or card.part >= _parts.size(): return point
	var part := _parts[card.part]
	return part.pivot + Basis(Vector3.UP, -part.turn) * (point - part.pivot)


## Puts [param card] where its part's turn shows its place in the graph.
func _place(card: Card) -> void:
	card.node.position = _shown(card, card.base)


## A block's yaw in its graph about the vertical (D-115): its [code]vr_rotation.y[/code], in radians.
static func yaw_of(block: Dictionary) -> float:
	var rotation: Variant = block.get("vr_rotation")
	return wrapf((rotation as Vector3).y, -PI, PI) if rotation is Vector3 else 0.0


## Splits the cards into parts (D-115): all of them while the graph turns as a
## whole, else cards of one yaw wired together, each about the centre of its
## cards. A part with the cards of one before keeps its turn.
func _build_parts() -> void:
	var previous := _parts
	_parts = []
	if not _by_parts:
		var whole := Part.new()
		whole.cards = _cards.duplicate()
		whole.key = PackedInt32Array([-1])
		_parts.append(whole)
	else:
		var lead: Array[int] = []
		var index_of: Dictionary[int, int] = {}
		for index: int in _cards.size():
			lead.append(index)
			index_of[_cards[index].id] = index
		for wire: Wire in _wires:
			if wire.from == null or wire.to == null or not is_zero_approx(angle_difference(wire.from.block_yaw, wire.to.block_yaw)): continue
			lead[_root(lead, index_of[wire.from.id])] = _root(lead, index_of[wire.to.id])
		var by_root: Dictionary[int, Part] = {}
		for index: int in _cards.size():
			var root := _root(lead, index)
			if not by_root.has(root):
				var part := Part.new()
				part.yaw = _cards[index].block_yaw
				by_root[root] = part
				_parts.append(part)
			by_root[root].cards.append(_cards[index])
	for part: Part in _parts:
		if part.cards.is_empty(): continue
		var bounds := AABB(part.cards[0].base, Vector3.ZERO)
		var ids := PackedInt32Array()
		for card: Card in part.cards:
			bounds = bounds.expand(card.base)
			ids.append(card.id)
		ids.sort()
		if _by_parts: part.key = ids
		part.pivot = bounds.get_center()
	for index: int in _parts.size():
		var part := _parts[index]
		for card: Card in part.cards: card.part = index
		for old: Part in previous:
			if old.key != part.key: continue
			part.turn = old.turn
			part.target = old.target
			part.mirrored = old.mirrored
	if not _by_parts: _turn_whole()
	else: transform = Transform3D.IDENTITY
	for card: Card in _cards: _place(card)


static func _root(lead: Array[int], index: int) -> int:
	while lead[index] != index: index = lead[index]
	return index


## Where [param head] (global) is seen from [param part] (D-115): its angle about
## the vertical from the part's front before its turn, -PI to PI.
func _bearing(part: Part, head: Vector3) -> float:
	var offset := to_local(head) - part.pivot
	# The whole graph turns the canvas itself: undo that turn.
	if not _by_parts: offset = Basis(Vector3.UP, part.turn) * offset
	return angle_difference(part.yaw, atan2(offset.x, offset.z))


## Turns the parts towards their targets as Graph turn sets them for [param head]
## (D-115), [param delta] seconds on (0: at once); nothing while something is held.
## True if a part turned.
func _turn_parts(head: Vector3, delta: float) -> bool:
	if _turn_frozen or _parts.is_empty(): return false
	var changed := false
	for part: Part in _parts:
		if _turn_mode != XREFeatureSettings.AIM: part.target = _turn_target(part, _bearing(part, head))
		var gap := angle_difference(part.turn, part.target)
		if is_zero_approx(gap): continue
		part.turn = part.target if delta <= 0.0 or absf(gap) < 0.001 else wrapf(part.turn + gap * minf(1.0, delta * TURN_RATE), -PI, PI)
		changed = true
	if not changed: return false
	if _by_parts:
		for card: Card in _cards: _place(card)
	else: _turn_whole()
	return true


## Turns the canvas with the whole graph's part about the centre of its cards (D-115).
func _turn_whole() -> void:
	var part := _parts[0]
	var turn := Basis(Vector3.UP, part.turn)
	transform = Transform3D(turn, part.pivot - turn * part.pivot)


## The turn [param part] goes to with the head at [param bearing] from its front
## (D-115): none while Fixed; round past 95°, back under 85°, while Flip; the
## nearest of four fronts once the head is past 50° from the current, while Steps.
func _turn_target(part: Part, bearing: float) -> float:
	match _turn_mode:
		XREFeatureSettings.FLIP:
			var limit := PI * 0.5 - MARGIN if absf(part.target) > PI * 0.5 else PI * 0.5 + MARGIN
			return PI if absf(bearing) > limit else 0.0
		XREFeatureSettings.STEPS:
			if absf(angle_difference(part.target, bearing)) <= PI * 0.25 + MARGIN: return part.target
			return wrapf(snappedf(bearing, PI * 0.5), -PI, PI)
	return 0.0


## Turns the part of card [param id] to the last head once (Graph turn On aim,
## D-115), as a ray comes onto it; nothing while something is held.
func aim_at(id: int) -> void:
	var card := _find_card(id)
	if card == null or _turn_mode != XREFeatureSettings.AIM or _turn_frozen or card.part >= _parts.size(): return
	var part := _parts[card.part]
	part.target = _bearing(part, _head_position)


## The turn of the part of card [param id] now, in radians (D-115).
func get_part_turn(id: int) -> float:
	var card := _find_card(id)
	return _parts[card.part].turn if card != null and card.part < _parts.size() else 0.0


## Whether [param part]'s cards that face the head are mirrored (Card mirror, D-115):
## past 95° from the part's front, back under 85°, while the graph doesn't turn.
func _mirror_part(part: Part) -> void:
	if not _card_mirror or _turn_mode != XREFeatureSettings.FIXED:
		part.mirrored = false
		return
	var bearing := absf(_bearing(part, _head_position))
	if bearing > PI * 0.5 + MARGIN: part.mirrored = true
	elif bearing < PI * 0.5 - MARGIN: part.mirrored = false


## Sums each card's [member Card.flow] (D-132): from the far end of each of its
## inputs' wires, from it to the far end of each of its outputs' — a wire's
## nearest bend where it bends, a variable's box for a wire from one.
func _sum_flows() -> void:
	for card: Card in _cards: card.flow = Vector3.ZERO
	for wire: Wire in _wires:
		if wire.to == null: continue
		var bends := wire.knots.size()
		var start: Vector3 = wire.bends[bends - 1] if bends > 0 else wire.from.node.position if wire.from != null else _boxes.box_point(wire.variable)
		wire.to.flow += _level(wire.to.node.position - start)
		if wire.from != null: wire.from.flow += _level((wire.bends[0] if bends > 0 else wire.to.node.position) - wire.from.node.position)


## [param offset] along the floor, of length 1; zero if it is upright.
static func _level(offset: Vector3) -> Vector3:
	offset.y = 0.0
	return offset.normalized() if not offset.is_zero_approx() else Vector3.ZERO


## Whether [param card], turned to [param local_head], lays out as a mirror's
## (Card mirror, D-132): its wires run to the head's left, past 95° from its
## right, until back under 85°; a card whose wires don't run across the view
## goes with its part ([method _mirror_part], D-115).
func _flow_mirrored(card: Card, local_head: Vector3) -> bool:
	if card.part >= _parts.size() or not _card_mirror or _turn_mode != XREFeatureSettings.FIXED: return false
	var right := Vector3.UP.cross(_level(local_head - card.node.position))
	var flow := Vector3(card.flow.x, 0.0, card.flow.z)
	if right.is_zero_approx() or flow.length() < MIN_FLOW: return _parts[card.part].mirrored
	var angle := right.angle_to(flow)
	if angle > PI * 0.5 + MARGIN: return true
	if angle < PI * 0.5 - MARGIN: return false
	return card.mirrored


## What [param card] shows the head at [param local_head] (the canvas's space,
## D-115): a card that faces the head is mirrored as its wires run
## ([method _flow_mirrored], D-132), a sign on the
## rim never; one that doesn't face it is turned round to show its face as a
## mirror's (Node back Labelled), or has its pins on its back (Pins Both faces),
## while the head is past 95° behind it, until it is back under 85°.
func _decide_sides(card: Card, local_head: Vector3) -> void:
	var mirrored := false
	var pins_back := false
	if _faces(card):
		mirrored = _flow_mirrored(card, local_head) and not (_rim_ports and card.shape != XREBlueprintShapes.Shape.NONE)
		card.turned_round = false
	else:
		var front := Basis(Vector3.UP, card.yaw + _part_turn(card)) * Vector3.BACK
		var offset := local_head - card.node.position
		offset.y = 0.0
		var angle := front.angle_to(offset) if not offset.is_zero_approx() else 0.0
		var was := card.turned_round or card.pins_back
		var behind := angle > PI * 0.5 + MARGIN or (was and angle > PI * 0.5 - MARGIN)
		card.turned_round = behind and _labelled_back
		mirrored = card.turned_round
		pins_back = behind and not _labelled_back and _pins == XREFeatureSettings.BOTH_FACES
	if mirrored != card.mirrored: _set_mirrored(card, mirrored)
	if pins_back != card.pins_back: _flip_pins(card)


## Lays [param card] out as a mirror's, or back (D-115): its node mirrors in
## [method _orient]; its labels mirror back to read, their left and right swapped.
func _set_mirrored(card: Card, mirrored: bool) -> void:
	card.mirrored = mirrored
	for text: Label3D in card.labels:
		text.scale.x = -text.scale.x
		if text.horizontal_alignment == HORIZONTAL_ALIGNMENT_LEFT: text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		elif text.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT: text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	# Each word reads by itself; swapped back about the heading's middle, they read in order.
	for word: Label3D in card.heading: word.position.x = card.heading_ends - word.position.x
	for socket: Socket in card.sockets:
		if socket.visual is Label3D: socket.base_scale.x = -socket.base_scale.x
		if not card.heading.is_empty() and socket.visual == card.heading[1]: socket.center = socket.visual.position


## Moves [param card]'s ports to its other face (Pins Both faces, D-115).
func _flip_pins(card: Card) -> void:
	card.pins_back = not card.pins_back
	for port: MeshInstance3D in card.ports: port.position.z = -port.position.z
	for index: int in card.inputs.size():
		var point := card.inputs[index]
		card.inputs[index] = Vector3(point.x, point.y, -point.z)
	for index: int in card.outputs.size():
		var point := card.outputs[index]
		card.outputs[index] = Vector3(point.x, point.y, -point.z)


## Keeps a captured point on the rod. A card that faces the head keeps facing it;
## one that doesn't keeps its orientation, which the hand's [param twist] about
## the vertical since the grab, in radians, turns in steps of 15° (D-115).
func preview_grab(id: int, contact: Vector3, local_contact: Vector3, head: Vector3, twist: float = 0.0) -> void:
	var card := _find_card(id)
	if card == null: return
	if not _faces(card):
		# It turns to the head about the vertical, in steps of 15° with a margin, so
		# that it doesn't flick between two while carried; the twist steps it further.
		var local_head := to_local(head)
		var exact := _yaw_to(local_head, to_local(contact)) - _part_turn(card)
		if is_inf(card.held_face) or absf(angle_difference(card.held_face, exact)) > YAW_STEP * 0.5 + MARGIN * 0.5:
			card.held_face = snappedf(exact, YAW_STEP)
		card.yaw = wrapf(card.held_face + snappedf(twist, YAW_STEP), -PI, PI)
		_decide_sides(card, local_head)
		_orient(card)
		card.node.global_position = contact - card.node.global_basis * local_contact
		update_wires()
		return
	var mirror := Basis.from_scale(Vector3(-1, 1, 1)) if card.mirrored else Basis.IDENTITY
	var across := -local_contact.x if card.mirrored else local_contact.x
	var orientation := XREBlueprintPetals.face(contact, head, Vector3.UP)
	var span := head - contact
	span.y = 0.0
	# Solve yaw around the captured point, rather than rotating around the center
	# afterwards and moving that point away from the controller's straight ray.
	if span.length() > absf(across) + 0.001:
		# Around the vertical, so that the rows stay level on a card tilted to the head.
		orientation = Basis(Vector3.UP, asin(across / span.length())) * orientation
	orientation *= mirror
	card.node.global_transform = Transform3D(orientation, contact - orientation * local_contact)
	update_wires()


## The yaw about the vertical, in the canvas's space, that turns a card at
## [param point] to [param local_head] (D-115).
static func _yaw_to(local_head: Vector3, point: Vector3) -> float:
	var toward := local_head - point
	return atan2(toward.x, toward.z) if not Vector2(toward.x, toward.z).is_zero_approx() else 0.0


## Gives [param block], new at [param point] in the canvas's space, a
## [code]vr_rotation[/code] that turns its card to the last head, in steps of
## 15°, where cards don't all face the head (D-115): as a held card turns.
func turn_to_head(block: Dictionary, point: Vector3) -> void:
	if _facing == XREFeatureSettings.ON or not _faces_user: return
	var yaw := wrapf(snappedf(_yaw_to(to_local(_head_position), point), YAW_STEP), -PI, PI)
	if is_zero_approx(yaw): block.erase("vr_rotation")
	else: block["vr_rotation"] = Vector3(0, yaw, 0)


## Current card pose in workspace coordinates, including a grip preview.
func get_block_transform(id: int) -> Transform3D:
	var card := _find_card(id)
	return card.node.transform if card != null else Transform3D.IDENTITY


## Whether the canvas shows a card for block [param id].
func has_block(id: int) -> bool:
	return _find_card(id) != null


## Width and height of block [param id]'s card, in meters; zero without it.
func get_block_size(id: int) -> Vector2:
	var card := _find_card(id)
	return Vector2(card.width, card.height) if card != null else Vector2.ZERO


## Current preview position of a card in workspace coordinates.
func get_block_position(id: int) -> Vector3:
	var card := _find_card(id)
	return card.node.position if card != null else Vector3.ZERO


## Highlights a card without changing the scene selection; -1 highlights none.
func select_block(id: int) -> void:
	var ids: Array[int] = []
	if id >= 0: ids.append(id)
	select_blocks(ids)


## The blocks whose cards have their middle in [param rect], on the canvas's
## plane in its space (D-125), in the order of the cards.
func blocks_in_rect(rect: Rect2) -> Array[int]:
	var ids: Array[int] = []
	for card: Card in _cards:
		if rect.has_point(Vector2(card.node.position.x, card.node.position.y)): ids.append(card.id)
	return ids


## Highlights the cards of [param ids], several at once (D-122).
func select_blocks(ids: Array[int]) -> void:
	_selected = ids.duplicate()
	for card: Card in _cards: _paint_frame(card)
	# A card selected or let go of out of focus is darkened or not (D-122), and a
	# selection keeps the rest darker with nothing in focus (D-129).
	if _focus_mode != XREFeatureSettings.OFF or _defocus_mode != XREFeatureSettings.OFF: _paint_focus()


## A selected card's frame is white, one in focus is [constant XREBlueprintFocus.FRAME]
## with Focus on (D-072), darker out of focus with Defocus on Dim; one that
## keeps a variable from being deleted flashes [constant FLASH_FRAME] (D-079).
func _paint_frame(card: Card) -> void:
	var base := _flash_frame if card.flash else _selected_material if _selected.has(card.id) else _focus_frame if card.look.x == XREBlueprintFocus.LIT else card.frame_material
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
## [constant XREBlueprintFocus.OUT], or [constant XREBlueprintFocus.NORMAL] while nothing is
## and for a selected card out of focus (D-122).
func focus_state(id: int) -> int:
	if not _focus_any: return XREBlueprintFocus.NORMAL
	return XREBlueprintFocus.FOCUSED if _in_focus(id) else XREBlueprintFocus.NORMAL if _selected.has(id) else XREBlueprintFocus.OUT


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
## the ports a wire being drawn may end on stay as they are, and so do the
## selected cards (D-122). With nothing asked for, selected cards put the rest
## out of focus all the same (D-129).
func _paint_focus() -> void:
	var used := _focus_mode != XREFeatureSettings.OFF or _defocus_mode != XREFeatureSettings.OFF
	var any := false
	if used:
		for card: Card in _cards: any = any or _in_focus(card.id)
		any = any or _boxes.has_box(_focus_box) or _boxes.has_box(_focus_other_box)
		# With the ray in the air, a selected card keeps the rest darker, so that it stands out (D-129).
		for card: Card in _cards:
			if any: break
			any = _selected.has(card.id)
	_focus_any = any
	for card: Card in _cards:
		# A selected card out of focus keeps its look: only the others are put back (D-122).
		card.focus = (XREBlueprintFocus.FOCUSED if _in_focus(card.id) else XREBlueprintFocus.NORMAL if _selected.has(card.id)
				else XREBlueprintFocus.OUT) if any else XREBlueprintFocus.NORMAL
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
			# A token in a port the wire may end on stays as it is with it: a plug's cap is in the port (D-135).
			for index: int in card.sockets.size():
				var socket := card.sockets[index]
				if socket.kind == TOKEN and socket.port >= 0 and socket.port < card.inputs.size() and (card.keep_ports & (1 << socket.port)) != 0:
					card.keep_sockets |= 1 << index
	for card: Card in _cards: _look_card(card)
	for wire: Wire in _wires: _look_wire(wire)
	for link: Wire in _variable_links: _look_link(link)
	_lay_arrows()
	for index: int in _boxes.box_count():
		var state: int = boxes.get(_boxes.box_name(index), XREBlueprintFocus.OUT if any else XREBlueprintFocus.NORMAL)
		_boxes.paint_box(index, state, focus_paint(state), focus_seen(state))
	var focused: Array[String] = [_focus_box, _focus_other_box]
	_boxes.show_trashes(focused)


## Keeps port [param port] of [param card] (an input if [param input]) as it
## is out of focus: the far end of a wire in focus. Play Animation's output 0
## is its Finished socket while it waits.
func _keep_port(card: Card, port: int, input: bool) -> void:
	if card.focus == XREBlueprintFocus.FOCUSED: return
	if not input and port == 0 and card.finished >= 0 and card.waits: card.keep_sockets |= 1 << card.finished
	else: card.keep_ports |= 1 << (port if input else card.inputs.size() + port)


func _look_card(card: Card) -> void:
	# An archetype's trash shows on the card a ray is on, with Focus and Defocus off too (D-099).
	if _style == XREFeatureSettings.ARCHETYPES:
		card.trash.visible = _in_focus(card.id)
		if card.swap != null: card.swap.visible = card.trash.visible
		if card.copy != null: card.copy.visible = card.trash.visible
		if card.open != null: card.open.visible = card.trash.visible
		# A variadic operator's plus shows with its trash, under it (D-137).
		if card.pin_plus != null: card.pin_plus.visible = card.trash.visible
		# A bead's name shows under the ray (D-103, D-108).
		if card.tip != null: card.tip.visible = card.trash.visible

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
	# An input's × shows while the ray is on its port (D-137).
	_show_pins()
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
## the copy button grows with [param copy], the heading's switch with [param swap].
func hover_actions(id: int, plus: bool, trash: bool, right: bool, port: int = -1, input: bool = false, edge: int = -1, keep_box: bool = false, copy: bool = false, swap: bool = false, pin_plus: bool = false, pin_mark: int = -1, pin_row: int = -1, open: bool = false, pure: bool = false) -> void:
	if not keep_box: _boxes.hover(-1, -1, right)
	hover_plus(id if plus else -1, right)
	_hover_copy(id if copy else -1, right)
	_hover_function(id if open else -1, id if pure else -1, right)
	_hover_swap(id if swap else -1, right)
	_hover_pins(id, pin_plus, pin_mark, pin_row, right)
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
	if input and wire.from == null: return _boxes.component_point(wire.variable, wire.component)
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


## Grows a call's open button and an Entry's pure switch under a hand's ray.
func _hover_function(open: int, pure: int, right: bool) -> void:
	if open == (_open_right if right else _open_left) and pure == (_pure_right if right else _pure_left): return
	if right:
		_open_right = open
		_pure_right = pure
	else:
		_open_left = open
		_pure_left = pure
	for card: Card in _cards:
		if card.open != null: card.open.scale = Vector3.ONE * (HOVER_SCALE if card.id == _open_right or card.id == _open_left else 1.0)
		if card.pure_switch != null: card.pure_switch.scale = Vector3.ONE * (1.15 if card.id == _pure_right or card.id == _pure_left else 1.0)


func _hover_swap(id: int, right: bool) -> void:
	if id == (_swap_right if right else _swap_left): return
	if right: _swap_right = id
	else: _swap_left = id
	for card: Card in _cards:
		if card.swap != null: card.swap.scale = Vector3.ONE * (HOVER_SCALE if card.id == _swap_right or card.id == _swap_left else 1.0)


## Two squares, one over the other's corner: the copy button (D-093).
static func _make_copy_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for corner: Vector3 in [Vector3(-0.0025, 0.0025, 0), Vector3(0.0025, -0.0025, 0.0005)]:
		for side: float in [-1.0, 1.0]:
			_append_trash_bar(surface, Vector3(0.012, 0.0018, 0.002), corner + Vector3(0, side * 0.0051, 0))
			_append_trash_bar(surface, Vector3(0.0018, 0.012, 0.002), corner + Vector3(side * 0.0051, 0, 0))
	return surface.commit()


## A box with an arrow going into it: the button that opens a function's body.
static func _make_open_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side: float in [-1.0, 1.0]:
		_append_trash_bar(surface, Vector3(0.0164, 0.0018, 0.002), Vector3(0, -0.0025 + side * 0.0056, 0))
		_append_trash_bar(surface, Vector3(0.0018, 0.0130, 0.002), Vector3(side * 0.0073, -0.0025, 0))
	var tip := Vector3(0.0, 0.0012, 0.0005)
	var tail := Vector3(-0.0066, 0.0108, 0.0005)
	var shaft := BoxMesh.new()
	shaft.size = Vector3(tail.distance_to(tip), 0.0018, 0.002)
	surface.append_from(shaft, 0, Transform3D(Basis(Vector3.BACK, (tip - tail).angle_to(Vector3.RIGHT) * -1.0), (tip + tail) * 0.5))
	_append_trash_bar(surface, Vector3(0.0056, 0.0018, 0.002), tip + Vector3(-0.0019, 0, 0))
	_append_trash_bar(surface, Vector3(0.0018, 0.0056, 0.002), tip + Vector3(0, 0.0019, 0))
	return surface.commit()


## A plain cross of two bars (D-137): the × that removes an input.
static func _make_pin_mark_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for angle: float in [PI * 0.25, -PI * 0.25]:
		var bar := BoxMesh.new()
		bar.size = Vector3(PIN_MARK_SIZE, 0.0022, 0.002)
		surface.append_from(bar, 0, Transform3D(Basis(Vector3.BACK, angle), Vector3.ZERO))
	return surface.commit()


## The pins' buttons of [param block]'s card when its pins change
## ([method XREBlueprintGraph.variable_pins], D-137, D-138): the plus under
## the card's corner on the side of those pins — left for inputs, right for
## outputs, the trash's height mirrored — while it can take another, and a grey
## × by each of them, inside the card, while it has more than the fewest. In
## archetypes the plus shows with the trash, a × while the ray is on its pin
## or on itself ([method _show_pins]); a classic card shows its plus always.
func _add_pin_buttons(card: Card, block: Dictionary, archetype: bool, outputs: Array, graph: XREBlueprintGraph) -> void:
	var pins := graph.pins_of(block)
	if pins.is_empty():
		if block.get("kind") in ["break", "make"]: _add_field_buttons(card, block, graph)
		return
	var count: int = pins["count"]
	card.pin_input = pins["input"]
	card.pin_offset = pins["offset"]
	var inputs := graph.ports(block, true)
	var front := card.face + CARD_THICKNESS * 0.5 + 0.002
	card.pin_front = front
	if pins["can_add"]:
		card.pin_plus_point = Vector3(absf(card.trash_point.x) * (-1.0 if card.pin_input else 1.0), -card.trash_point.y, front)
		card.pin_plus = Node3D.new()
		card.pin_plus.name = "PinPlus"
		card.pin_plus.position = card.pin_plus_point
		card.node.add_child(card.pin_plus)
		for size: Vector3 in [Vector3(0.018, 0.004, 0.002), Vector3(0.004, 0.018, 0.002)]:
			var bar := BoxMesh.new()
			bar.size = size
			card.pin_plus.add_child(XRERig.create_vr_mesh(bar, _pin_plus_material))
		card.pin_plus.visible = not archetype
	card.pin_marks.clear()
	card.pin_shifts.clear()
	for index: int in count:
		var mark: Node3D = null
		# Right of an input's port; left of an output's name, which stands left of its port.
		var shift := PIN_MARK_SHIFT
		var at := index + card.pin_offset
		# Right of a Return's output's name, as a Make's eye is (D-140).
		if card.pin_input and block["kind"] == "return":
			var named := str((inputs[at] as Array)[0]) if at < inputs.size() else ""
			shift = 0.022 + text_width(named, 18) + PIN_MARK_SHIFT * 0.6
		if not card.pin_input:
			var name := str((outputs[at] as Array)[0]) if at < outputs.size() else ""
			shift = -(0.022 + text_width(name, 18) + PIN_MARK_SHIFT * 0.6)
			# Left of a Switch case's puck, which stands for its name (D-140); its port is on the edge.
			if block["kind"] == "switch" and _value_mode != XREFeatureSettings.WINDOW:
				var case := XREBlueprintGraph.case_key(index)
				shift = -(CASE_INSET + XREBlueprintTokens.width(XREBlueprintTokens.shown((block["params"] as Dictionary).get(case), case, "")) + PIN_MARK_SHIFT * 0.6)
		if count > int(pins["fewest"]):
			mark = Node3D.new()
			mark.name = "PinMark%d" % index
			mark.add_child(XRERig.create_vr_mesh(_pin_mark_mesh, _pin_mark_material))
			mark.visible = false
			card.node.add_child(mark)
		card.pin_marks.append(mark)
		card.pin_shifts.append(shift)
	_place_pin_marks(card)


## A Break's or a Make's eye by each field without a wire, which hides it,
## and, while fields are hidden, a chip under the card on the fields' side
## saying how many, which lists them to show again (D-139). The eyes show as
## a × does: while the ray is on the field's pin or on the eye.
func _add_field_buttons(card: Card, block: Dictionary, graph: XREBlueprintGraph) -> void:
	if (block.get("struct", {}) as Dictionary).is_empty(): return
	card.pin_eyes = true
	card.pin_input = block["kind"] == "make"
	var front := card.face + CARD_THICKNESS * 0.5 + 0.002
	card.pin_front = front
	var wired: Dictionary[int, bool] = {}
	for edge: Dictionary in graph.edges:
		if card.pin_input and edge["to"] == card.id: wired[int(edge["to_port"])] = true
		if not card.pin_input and edge["from"] == card.id: wired[int(edge["from_port"])] = true
	var fields := XREBlueprintStructs.shown(block)
	var count := fields.size()
	card.pin_marks.clear()
	card.pin_shifts.clear()
	for index: int in count:
		# Past the field's name, which stands by its port on either side (D-140).
		var width := text_width(str(fields[index]["name"]), 18) + 0.022 + PIN_MARK_SHIFT * 0.6
		var shift := width if card.pin_input else -width
		var mark: Node3D = null
		if not wired.has(index):
			mark = Node3D.new()
			mark.name = "FieldEye%d" % index
			mark.add_child(XRERig.create_vr_mesh(_eye_mesh, _pin_mark_material))
			mark.visible = false
			card.node.add_child(mark)
		card.pin_marks.append(mark)
		card.pin_shifts.append(shift)
	_place_pin_marks(card)
	var hidden: int = (block.get("hidden", []) as Array).size()
	if hidden == 0: return
	var text := label("··· %d hidden" % hidden, 16)
	text.modulate = Color("aab2c3")
	card.hidden_chip_size = Vector2(text_width(text.text, 16) + 0.016, 0.02)
	# Flush with the card's edge on the fields' side, just under it.
	var side := -1.0 if card.pin_input else 1.0
	card.hidden_chip_point = Vector3(side * (card.width * 0.5 - card.hidden_chip_size.x * 0.5), -card.height * 0.5 - 0.016, front)
	card.hidden_chip = Node3D.new()
	card.hidden_chip.name = "HiddenChip"
	card.hidden_chip.position = card.hidden_chip_point
	card.node.add_child(card.hidden_chip)
	var pill := XRERig.create_vr_mesh(XREBlueprintShapes.body(XREBlueprintShapes.stadium(card.hidden_chip_size), 0.001), material(Color("232a3b"), true))
	card.hidden_chip.add_child(pill)
	text.position = Vector3(0, 0, 0.0008)
	card.hidden_chip.add_child(text)


## An open eye: an almond's rim and its pupil (D-139).
static func _make_eye_mesh() -> ArrayMesh:
	var almond := PackedVector2Array()
	for index: int in 24:
		var angle := TAU * index / 24.0
		almond.append(Vector2(cos(angle) * 0.0072, sin(angle) * 0.0042))
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.append_from(XREBlueprintShapes.ring(almond, 0.0, 0.0012, 0.0), 0, Transform3D.IDENTITY)
	surface.append_from(XREBlueprintShapes.body(XREBlueprintShapes.circle(0.0018), 0.001), 0, Transform3D.IDENTITY)
	return surface.commit()


## Whether the last ray hit the chip of a Break's or a Make's hidden fields (D-139).
func get_hit_hidden_chip() -> bool:
	return _hit_hidden_chip


## Puts each × of [param card] by its pin as it stands now (D-137).
func _place_pin_marks(card: Card) -> void:
	var ports := card.inputs if card.pin_input else card.outputs
	for index: int in card.pin_marks.size():
		var mark := card.pin_marks[index]
		var at := index + card.pin_offset
		if mark != null and at < ports.size(): mark.position = Vector3(ports[at].x + card.pin_shifts[index], ports[at].y, card.pin_front)


## Shows the × of each pin under a hand's ray, on the pin or on the ×
## itself, by its pin as it stands now (D-137) — on the pin is anywhere in its
## half of the row, its name too (D-140) —, and grows the plus or the × under a ray.
func _show_pins() -> void:
	for card: Card in _cards:
		if card.pin_plus != null:
			card.pin_plus.scale = Vector3.ONE * (HOVER_SCALE if card.id == _pin_plus_right or card.id == _pin_plus_left else 1.0)
		if card.pin_marks.is_empty(): continue
		var first := (0 if card.pin_input else card.inputs.size()) + card.pin_offset
		for index: int in card.pin_marks.size():
			var mark := card.pin_marks[index]
			if mark == null: continue
			var key := Vector2i(card.id, index)
			var port := Vector2i(card.id, first + index)
			var on_mark := key == _pin_mark_right or key == _pin_mark_left
			mark.visible = on_mark or port == _port_right or port == _port_left or key == _pin_row_right or key == _pin_row_left
			mark.scale = Vector3.ONE * (HOVER_SCALE if on_mark else 1.0)
		_place_pin_marks(card)


func _hover_pins(id: int, plus: bool, mark: int, row: int, right: bool) -> void:
	var plus_id := id if plus else -1
	var mark_key := Vector2i(id, mark) if mark >= 0 else Vector2i(-1, -1)
	var row_key := Vector2i(id, row) if row >= 0 else Vector2i(-1, -1)
	if plus_id == (_pin_plus_right if right else _pin_plus_left) and mark_key == (_pin_mark_right if right else _pin_mark_left) \
			and row_key == (_pin_row_right if right else _pin_row_left): return
	if right:
		_pin_plus_right = plus_id
		_pin_mark_right = mark_key
		_pin_row_right = row_key
	else:
		_pin_plus_left = plus_id
		_pin_mark_left = mark_key
		_pin_row_left = row_key
	_show_pins()


## Whether the last ray hit the plus of a variadic operator (D-137).
func get_hit_pin_plus() -> bool:
	return _hit_pin_plus


## The input whose × the last ray hit (D-137), or -1.
func get_hit_pin_mark() -> int:
	return _hit_pin_mark


## The pin of the card under the last ray whose half-row it hit (D-140): its
## port, its name, its × or eye; -1 elsewhere.
func get_hit_pin_row() -> int:
	return _hit_pin_row if _pin_row_card == _hit_id and _hit_id >= 0 else -1


## The pin of [param card] whose half of the row [param at] is in, on the face,
## -1 when none (D-140): from the card's middle to its port and a little past
## it — past its × or eye too, which an output's has left of its name.
func _pin_row(card: Card, at: Vector3) -> int:
	if absf(at.z - card.pin_front) > CARD_THICKNESS + 0.02: return -1
	var ports := card.inputs if card.pin_input else card.outputs
	for index: int in mini(card.pin_marks.size(), ports.size() - card.pin_offset):
		var mark := card.pin_marks[index]
		var port := ports[index + card.pin_offset]
		if mark == null or absf(at.y - port.y) > ROW_HEIGHT * 0.5: continue
		var reach := PIN_MARK_SIZE
		if card.pin_input and at.x >= port.x - reach and at.x <= maxf(0.0, mark.position.x + reach): return index
		if not card.pin_input and at.x <= port.x + reach and at.x >= minf(0.0, mark.position.x - reach): return index
	return -1


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
	_hit_swap = false
	_hit_copy = false
	_hit_open = false
	_hit_pure = false
	_button_distance = -1.0
	_hit_pin_plus = false
	_hit_pin_mark = -1
	_hit_hidden_chip = false
	_hit_pin_row = -1
	_pin_row_card = -1
	_pin_distance = -1.0
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
		# A sign takes the ray inside its outline, not its whole box (D-100).
		if body >= 0 and not card.outline.is_empty():
			var at := card_origin + card_direction * body
			if not XREBlueprintShapes.contains(card.outline, Vector2(at.x, at.y)): body = -1.0
		if body >= 0:
			nearest = body
			proximity = INF
			_hit_id = card.id
			_hit_port = -1
			_hit_input = false
			_hit_plus = false
			_hit_delete = false
			_hit_swap = false
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
				_hit_swap = false
				_hit_copy = false
		var trash_size := Vector3.ONE * PLUS_RADIUS * card.trash.scale.x * (TRASH_SCALE if _style == XREFeatureSettings.ARCHETYPES else 1.0) * 2.0
		var trash_hit := _box_distance(card_origin, card_direction, AABB(card.trash_point - trash_size * 0.5, trash_size), nearest) if card.trash.visible and not card.fixed else -1.0
		if trash_hit >= 0:
			nearest = trash_hit
			_hit_id = card.id
			_hit_port = -1
			_hit_plus = false
			_hit_delete = true
			_hit_swap = false
			_hit_copy = false
		if card.swap != null and card.swap.visible:
			var swap_size := Vector3.ONE * SWAP_SIZE
			var swap_hit := _box_distance(card_origin, card_direction, AABB(card.swap_point - swap_size * 0.5, swap_size), nearest)
			if swap_hit >= 0:
				nearest = swap_hit
				_hit_id = card.id
				_hit_port = -1
				_hit_plus = false
				_hit_delete = false
				_hit_swap = true
				_hit_copy = false
		# An archetype's copy shows with its trash (D-113); a classic card's always.
		if card.copy != null and card.copy.visible:
			var copy_size := Vector3.ONE * PLUS_RADIUS * card.copy.scale.x * 2.0
			var copy_hit := _box_distance(card_origin, card_direction, AABB(card.copy_point - copy_size * 0.5, copy_size), nearest)
			if copy_hit >= 0:
				nearest = copy_hit
				_hit_id = card.id
				_hit_port = -1
				_hit_plus = false
				_hit_delete = false
				_hit_swap = false
				_hit_copy = true
		# A function call's open button, in the row of its copy, and an Entry's
		# pure switch (docs/blueprint_functions.md); a later, nearer hit takes the ray back.
		if card.open != null and card.open.visible:
			var open_size := Vector3.ONE * PLUS_RADIUS * card.open.scale.x * 2.0
			var open_hit := _box_distance(card_origin, card_direction, AABB(card.open_point - open_size * 0.5, open_size), nearest)
			if open_hit >= 0:
				nearest = open_hit
				_button_distance = open_hit
				_hit_id = card.id
				_hit_port = -1
				_hit_plus = false
				_hit_delete = false
				_hit_swap = false
				_hit_copy = false
				_hit_open = true
		if card.pure_switch != null:
			var pure_hit := _box_distance(card_origin, card_direction, _pure_box(card), nearest)
			if pure_hit >= 0:
				nearest = pure_hit
				_button_distance = pure_hit
				_hit_id = card.id
				_hit_port = -1
				_hit_plus = false
				_hit_delete = false
				_hit_swap = false
				_hit_copy = false
				_hit_open = false
				_hit_pure = true
		# A variadic operator's plus under it and the × by an input (D-137); a later,
		# nearer hit of anything else takes the ray back ([method _settle_pins]).
		if card.pin_plus != null and card.pin_plus.visible:
			var pin_size := Vector3.ONE * PLUS_RADIUS * card.pin_plus.scale.x * 2.0
			var pin_hit := _box_distance(card_origin, card_direction, AABB(card.pin_plus_point - pin_size * 0.5, pin_size), nearest)
			if pin_hit >= 0:
				nearest = pin_hit
				_pin_distance = pin_hit
				_hit_id = card.id
				_hit_port = -1
				_hit_plus = false
				_hit_delete = false
				_hit_swap = false
				_hit_copy = false
				_hit_pin_plus = true
				_hit_pin_mark = -1
		if card.hidden_chip != null and card.hidden_chip.visible:
			var chip_size := Vector3(card.hidden_chip_size.x, card.hidden_chip_size.y, 0.006)
			var chip_hit := _box_distance(card_origin, card_direction, AABB(card.hidden_chip_point - chip_size * 0.5, chip_size), nearest)
			if chip_hit >= 0:
				nearest = chip_hit
				_pin_distance = chip_hit
				_hit_id = card.id
				_hit_port = -1
				_hit_plus = false
				_hit_delete = false
				_hit_swap = false
				_hit_copy = false
				_hit_pin_plus = false
				_hit_pin_mark = -1
				_hit_hidden_chip = true
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
				_hit_swap = false
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
				_hit_swap = false
				_hit_copy = false
				_hit_height = (card_origin + card_direction * hit - center).y / ((PORT_RADIUS + PORT_HIT_MARGIN) * card.ports[card.inputs.size() + index].scale.y)
		# An input's × (D-137) lies on the face beside its port, which bulges over the face:
		# as a token on the face, it wins over the port and the face.
		for index: int in card.pin_marks.size():
			var mark := card.pin_marks[index]
			if mark == null or not mark.visible: continue
			var mark_size := Vector3.ONE * PIN_MARK_SIZE * mark.scale.x
			var mark_hit := _box_distance(card_origin, card_direction, AABB(mark.position - mark_size * 0.5, mark_size), nearest + 0.02)
			if mark_hit < 0: continue
			nearest = minf(mark_hit, nearest)
			_pin_distance = nearest
			_hit_id = card.id
			_hit_port = -1
			_hit_input = false
			_hit_plus = false
			_hit_delete = false
			_hit_swap = false
			_hit_copy = false
			_hit_pin_plus = false
			_hit_pin_mark = index
			_hit_hidden_chip = false
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
			_hit_swap = false
			_hit_copy = false
		# The ray anywhere in a pin's half-row shows its × or eye (D-140): on its
		# name too, on the way from the port to the ×.
		if _hit_id == card.id and not card.pin_marks.is_empty():
			var row := _pin_row(card, card_origin + card_direction * nearest)
			if row >= 0:
				_hit_pin_row = row
				_pin_row_card = card.id
		# The air between an archetype's buttons and between them and its card keeps
		# the card under the ray, so its buttons don't hide on the way to one (D-114).
		if _hit_id != card.id and _style == XREFeatureSettings.ARCHETYPES and card.trash.visible:
			var reach := AABB(card.trash_point - trash_size * 0.5, trash_size)
			if card.swap != null: reach = reach.merge(AABB(card.swap_point - Vector3.ONE * SWAP_SIZE * 0.5, Vector3.ONE * SWAP_SIZE))
			if card.copy != null:
				var copy_size := Vector3.ONE * PLUS_RADIUS * card.copy.scale.x * 2.0
				reach = reach.merge(AABB(card.copy_point - copy_size * 0.5, copy_size))
			if card.open != null:
				var open_size := Vector3.ONE * PLUS_RADIUS * card.open.scale.x * 2.0
				reach = reach.merge(AABB(card.open_point - open_size * 0.5, open_size))
			# Down into the card: a sign's outline leaves air under its corner.
			var floor_y := card.bounds.get_center().y if not card.outline.is_empty() else card.bounds.end.y
			reach = reach.expand(Vector3(reach.position.x, floor_y, reach.position.z))
			var gap := _box_distance(card_origin, card_direction, reach, nearest)
			# The air down to a variadic operator's plus under it too (D-137).
			if gap < 0 and card.pin_plus != null and card.pin_plus.visible:
				var pin_size := Vector3.ONE * PLUS_RADIUS * card.pin_plus.scale.x * 2.0
				var below := AABB(card.pin_plus_point - pin_size * 0.5, pin_size)
				below = below.expand(Vector3(below.position.x, card.bounds.get_center().y if not card.outline.is_empty() else card.bounds.position.y, below.position.z))
				gap = _box_distance(card_origin, card_direction, below, nearest)
			if gap >= 0:
				nearest = gap
				_hit_id = card.id
				_hit_port = -1
				_hit_input = false
				_hit_socket = -1
				_hit_finished = false
				_hit_plus = false
				_hit_delete = false
				_hit_swap = false
				_hit_copy = false
				_hit_pin_plus = false
				_hit_pin_mark = -1
	# A wire in front of a card's face takes the ray from it; ports, sockets and
	# the cards' buttons keep it. Not while a wire is drawn: it ends on ports.
	var drawing := _preview.visible or _compatible_type >= 0
	# A pin's button keeps the ray only if nothing nearer took it after (D-137).
	if (_hit_pin_plus or _hit_pin_mark >= 0 or _hit_hidden_chip) and (not is_equal_approx(_pin_distance, nearest) or _hit_port >= 0 or _hit_socket >= 0):
		_hit_pin_plus = false
		_hit_pin_mark = -1
		_hit_hidden_chip = false
	if (_hit_open or _hit_pure) and (not is_equal_approx(_button_distance, nearest) or _hit_port >= 0 or _hit_socket >= 0):
		_hit_open = false
		_hit_pure = false
	var on_pin := _hit_pin_plus or _hit_pin_mark >= 0 or _hit_hidden_chip or _hit_open or _hit_pure
	if _bends_shown and not drawing and _hit_port < 0 and _hit_socket < 0 and not _hit_plus and not _hit_delete and not _hit_copy and not on_pin:
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
			_hit_swap = false
			_hit_copy = false
			_hit_open = false
			_hit_pure = false
			_hit_pin_plus = false
			_hit_pin_mark = -1
			_hit_hidden_chip = false
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
	# A port on the edge is round too, seen from every side (D-115).
	if _port_display == XREFeatureSettings.SPHERE or _pins == XREFeatureSettings.EDGE:
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
			# The member in a header doesn't grow over its verb: it changes colour (D-110),
			# staying dark on a card out of focus (D-114).
			elif item.visual.name == "Member" and item.visual is Label3D: XREBlueprintFocus.recolor(item.visual as Label3D, MEMBER_HOVER if hovered else MEMBER_COLOR)
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


## Whether the last ray hit a function call's open button (docs/blueprint_functions.md).
func get_hit_open() -> bool:
	return _hit_open


## Whether the last ray hit an Entry's pure switch (docs/blueprint_functions.md).
func get_hit_pure() -> bool:
	return _hit_pure


## Cached endpoint position in workspace coordinates.
func port_position(id: int, port: int, input: bool) -> Vector3:
	var card := _find_card(id)
	if card == null: return Vector3.ZERO
	return _port_position(card, port, input)


## A wire leaves a disc from its face — the back one with its pins there — and
## a sphere or a port on the edge from its center; Play Animation's output 0
## leaves Finished while it waits (D-052, D-115).
func _port_position(card: Card, port: int, input: bool, finished: int = -1) -> Vector3:
	if not input and port == 0 and card.finished >= 0 and (card.waits if finished < 0 else finished == 1):
		return card.node.transform * (card.sockets[card.finished].center + Vector3.BACK * PORT_DEPTH)
	var visual := card.ports[port if input else card.inputs.size() + port]
	var center := card.inputs[port] if input else card.outputs[port]
	if _port_display == XREFeatureSettings.SPHERE or _pins == XREFeatureSettings.EDGE: return card.node.transform * center
	return card.node.transform * (center + (Vector3.FORWARD if card.pins_back else Vector3.BACK) * PORT_DEPTH * visual.scale.z)


## Wires leave outputs rightwards and enter inputs from the left, as in GraphEdit: the card's
## own sides (D-090), so that a card turned towards the head — seen from the side or from behind
## the graph — sends its wires out of the side its ports are on, not along the graph's horizontal.
func port_direction(id: int, input: bool) -> Vector3:
	var card := _find_card(id)
	return _port_direction(card, input) if card != null else Vector3.ZERO


static func _port_direction(card: Card, input: bool) -> Vector3:
	return -_side(card) if input else _side(card)


## The card's right, along its rows: the graph's with cuboids, turned with a billboard.
static func _side(card: Card) -> Vector3:
	return card.node.basis.x.normalized() if card != null else Vector3.RIGHT


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
			_preview.update_curve(card.node.transform * socket.center, -_side(card), end, Vector3.ZERO, _front(card))
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
	_lay_arrows()


## Whether arrowheads run along their wires, and so are laid every frame (D-115).
func _runs_arrows() -> bool:
	return _exec_arrows == XREFeatureSettings.RUNNING or _data_arrows == XREFeatureSettings.RUNNING


## Puts the wires' arrowheads along them as Execution arrows and Data arrows say
## (D-115): along the flow — from an output to its input, from a box to the
## input it feeds and from a Set to the box it writes, from an object to its
## Target —, filled cones or open ones turned about their wire to the head. Allocates nothing.
func _lay_arrows() -> void:
	var layer := _arrows_open if _open_arrows else _arrows_filled
	var other := _arrows_filled if _open_arrows else _arrows_open
	other.multimesh.visible_instance_count = 0
	other.visible = false
	var count := 0
	if _exec_arrows != XREFeatureSettings.OFF or _data_arrows != XREFeatureSettings.OFF:
		var head := to_local(_head_position) if is_inside_tree() else _head_position
		for wire: Wire in _wires:
			var execution := wire.from != null and wire.from.output_types[wire.from_port] == XREBlueprintGraph.EXEC
			count = _arrows_on(layer.multimesh, wire, execution, true, head, count)
		for link: Wire in _variable_links: count = _arrows_on(layer.multimesh, link, false, link.writes, head, count)
		for link: Wire in _scene_links: count = _arrows_on(layer.multimesh, link, false, false, head, count)
	layer.multimesh.visible_instance_count = count
	layer.visible = count > 0


## Lays [param wire]'s arrowheads into [param arrows] from instance [param count]
## on, along its tubes [param forward] or against them; the count after them.
func _arrows_on(arrows: MultiMesh, wire: Wire, execution: bool, forward: bool, head: Vector3, count: int) -> int:
	var mode := _exec_arrows if execution else _data_arrows
	if mode == XREFeatureSettings.OFF or not wire.mesh.visible: return count
	var size := 1.0 if execution else 0.8
	var color := _arrow_color(wire)
	var last := wire.pieces.size() - 1
	for index: int in wire.pieces.size():
		var piece := wire.pieces[index]
		var points := piece.get_point_count()
		if points < 2 or points > _arc.size(): continue
		_arc[0] = 0.0
		for point: int in range(1, points): _arc[point] = _arc[point - 1] + piece.get_point(point).distance_to(piece.get_point(point - 1))
		var length := _arc[points - 1]
		# One at the end of the flow: the last tube's end, or the first's start against it.
		if mode == XREFeatureSettings.AT_END:
			if index == (last if forward else 0) and length > ARROW_END * 2.0 and count < ARROW_LIMIT:
				count = _put_arrow(arrows, piece, points, length - ARROW_END, forward, head, color, size * ARROW_END_SCALE, count)
			continue
		if length < ARROW_MARGIN * 2.0 + 0.02: continue
		var along := ARROW_MARGIN + (fmod(_arrow_clock * ARROW_SPEED, ARROW_STEP) if mode == XREFeatureSettings.RUNNING else ARROW_STEP * 0.5)
		while along < length - ARROW_MARGIN and count < ARROW_LIMIT:
			count = _put_arrow(arrows, piece, points, along, forward, head, color, size, count)
			along += ARROW_STEP
	return count


## The colour of [param wire]'s arrowheads (D-115): its own, lit or darker by
## its focus as its tubes are, and as see-through as they are.
func _arrow_color(wire: Wire) -> Color:
	var color := wire.color
	match focus_paint(wire.focus):
		XREBlueprintFocus.LIT: color = color.lerp(Color.WHITE, XREBlueprintFocus.LIGHT)
		XREBlueprintFocus.DARK: color = Color(color.r * XREBlueprintFocus.DIM, color.g * XREBlueprintFocus.DIM, color.b * XREBlueprintFocus.DIM)
	color.a = wire.color.a * (1.0 - wire.mesh.transparency)
	return color


## One arrowhead [param along] meters down [param piece] in the flow's
## direction, into instance [param count] of [param arrows]; the next instance.
func _put_arrow(arrows: MultiMesh, piece: XREGraphWire, points: int, along: float, forward: bool, head: Vector3, color: Color, size: float, count: int) -> int:
	var length := _arc[points - 1]
	var at := along if forward else length - along
	var index := 0
	while index < points - 2 and _arc[index + 1] < at: index += 1
	var start := piece.get_point(index)
	var end := piece.get_point(index + 1)
	var span := _arc[index + 1] - _arc[index]
	var point := start.lerp(end, clampf((at - _arc[index]) / span, 0.0, 1.0) if span > 0.0 else 0.0)
	var tangent := (end - start).normalized() * (1.0 if forward else -1.0)
	if tangent.is_zero_approx(): return count
	var basis: Basis
	if _open_arrows:
		# Flat along the wire, turned about it to the head.
		var toward := head - point
		toward -= tangent * toward.dot(tangent)
		if toward.is_zero_approx(): toward = tangent.cross(Vector3.UP) if not tangent.cross(Vector3.UP).is_zero_approx() else Vector3.BACK
		toward = toward.normalized()
		basis = Basis(tangent.cross(toward).normalized(), tangent, toward)
	else: basis = Basis(Quaternion(Vector3.UP, tangent))
	var pose := Transform3D(basis.scaled(Vector3.ONE * size), point)
	arrows.set_instance_transform(count, pose)
	arrows.set_instance_color(count, color)
	_arrow_poses[count] = pose
	return count + 1


## Where arrowhead [param index] of those drawn now is, in the canvas's space (D-115).
func get_arrow_pose(index: int) -> Transform3D:
	return _arrow_poses[index] if index >= 0 and index < _arrow_poses.size() else Transform3D()


## Puts each port of a sign on its rim towards the far ends of its wires, as the
## head sees them (Sign ports Rim, D-115): towards a wire's nearest bend if it
## bends, an input without a wire across from the result, no two nearer than
## 50°, none more than 90° from where it was built (D-132), a wire that runs
## off behind folding back towards that side (D-135); a token goes round with its port.
func _lay_rims() -> void:
	for card: Card in _cards:
		if card.shape == XREBlueprintShapes.Shape.NONE or card.rim_built.size() != card.ports.size(): continue
		var inverse := card.node.transform.affine_inverse()
		var count := card.ports.size()
		if _rim_angles.size() < count: _rim_angles.resize(count)
		var output := 0.0
		var has_output := false
		for index: int in count:
			var input := index < card.inputs.size()
			var pull := Vector2.ZERO
			for wire: Wire in _wires:
				var far := Vector3.INF
				var bends := wire.knots.size()
				if input and wire.to == card and wire.to_port == index:
					far = wire.bends[bends - 1] if bends > 0 else wire.from.node.position if wire.from != null else _boxes.box_point(wire.variable)
				elif not input and wire.from == card and wire.from_port == index - card.inputs.size() and wire.to != null:
					far = wire.bends[0] if bends > 0 else wire.to.node.position
				if far == Vector3.INF: continue
				var local := inverse * far
				var flat := Vector2(local.x, local.y)
				if not flat.is_zero_approx(): pull += flat.normalized()
			_rim_angles[index] = pull.angle() if not pull.is_zero_approx() else INF
			if _rim_angles[index] != INF: _fold_rim(card, index)
			if not input and not has_output and _rim_angles[index] != INF:
				output = _rim_angles[index]
				has_output = true
		for index: int in count:
			if _rim_angles[index] != INF: continue
			var built := card.rim_built[index]
			# A port without a wire stays where it was built, an input across from the result.
			_rim_angles[index] = output + PI if index < card.inputs.size() and has_output else atan2(built.y, built.x)
		for index: int in count: _fold_rim(card, index)
		for _sweep: int in 24:
			for first: int in count:
				for second: int in range(first + 1, count):
					var gap := angle_difference(_rim_angles[first], _rim_angles[second])
					var need := deg_to_rad(50.0) - absf(gap)
					if need <= 0.0: continue
					var push := need * 0.5 * (1.0 if gap >= 0.0 else -1.0)
					_rim_angles[first] -= push
					_rim_angles[second] += push
					_hold_rim(card, first)
					_hold_rim(card, second)
		for index: int in count:
			var spot := _rim_point(card, _rim_angles[index])
			var port := card.ports[index]
			port.position = Vector3(spot.x, spot.y, port.position.z)
			if index < card.inputs.size(): card.inputs[index] = port.position
			else: card.outputs[index - card.inputs.size()] = port.position
		for socket: Socket in card.sockets:
			if socket.kind != TOKEN or socket.port < 0 or socket.port >= card.inputs.size(): continue
			var built := card.rim_built[socket.port]
			var turn := angle_difference(atan2(built.y, built.x), _rim_angles[socket.port])
			var offset := Vector2(socket.home.x - built.x, socket.home.y - built.y).rotated(turn)
			# A plug's cap is its visual's origin: it stays in the port, its body level to its left to read (D-132).
			if _value_mode == XREFeatureSettings.PLUGS: offset = Vector2(socket.center.x - socket.visual.position.x, socket.center.y - socket.visual.position.y)
			var port_at := card.ports[socket.port].position
			var center := Vector3(port_at.x + offset.x, port_at.y + offset.y, socket.home.z)
			socket.visual.position += center - socket.center
			socket.center = center


## Keeps port [param index] of [param card] on the rim within 90° of where it
## was built (D-132): an input stays on its side, the result on its own.
func _hold_rim(card: Card, index: int) -> void:
	var built := card.rim_built[index]
	var home := atan2(built.y, built.x)
	_rim_angles[index] = home + clampf(angle_difference(home, _rim_angles[index]), -PI * 0.5, PI * 0.5)


## Turns port [param index] of [param card] towards its wires within 90° of
## where it was built (D-135): a wire that runs off behind, past 90°, turns it
## back towards its side, as far as it is past, rather than to the edge, so a
## result whose wire runs back left stays on the right.
func _fold_rim(card: Card, index: int) -> void:
	var built := card.rim_built[index]
	var home := atan2(built.y, built.x)
	var gap := angle_difference(home, _rim_angles[index])
	if absf(gap) > PI * 0.5: gap = signf(gap) * PI - gap
	_rim_angles[index] = home + gap


## The point of [param card]'s outline at [param angle] from its centre: on a
## circle at its radius, else the outline's point nearest that angle (D-115).
func _rim_point(card: Card, angle: float) -> Vector2:
	if card.shape == XREBlueprintShapes.Shape.CIRCLE: return Vector2.from_angle(angle) * card.width * 0.5
	var best := Vector2.ZERO
	var nearest := INF
	for point: Vector2 in card.outline:
		var gap := absf(angle_difference(point.angle(), angle))
		if gap < nearest:
			nearest = gap
			best = point
	return best


## Lays the wire of [param link]'s Variable socket to its variable's box.
func _update_variable_link(link: Wire) -> void:
	# A link's wire leaves its ring, not the socket (D-074).
	var at := link.from.node.transform * (link.link.end if link.link != null else link.from.sockets[link.socket].center)
	var end := _boxes.box_end(link.variable, at, link.writes)
	_lay(link, at, -_side(link.from), end[0], end[1], _front(link.from))


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
		# Out of its component's output on the box's right side (D-105).
		if wire.component >= 0:
			start = _boxes.component_point(wire.variable, wire.component)
			start_direction = Vector3.RIGHT
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
			stored.append(Vector3(at.x, at.y, block_depth(point)))
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
	var card := _find_card(id)
	_lay(link, socket_position(id, kind), -_side(card), end, Vector3.ZERO, _front(card))


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


## Lights the frames of cards [param ids] — the calls that keep a function
## from being deleted (docs/blueprint_functions.md) — or puts them back.
func flash_cards(ids: Array[int], lit: bool = true) -> void:
	for card: Card in _cards:
		if not ids.has(card.id): continue
		card.flash = lit
		_paint_frame(card)


## A static Target wire ([method add_scene_link]): from its input port, leaving left, free towards the scene object.
func update_scene_wire(link: Wire, id: int, port: int, end: Vector3) -> void:
	_lay(link, port_position(id, port, true), port_direction(id, true), end, Vector3.ZERO, _front(_find_card(id)))


## [param shown] is the type whose color it has, if not its own: an operator's
## input of any value wired is in the color of what comes in (D-065).
func _add_port(card: Card, spec: Array, index: int, input: bool, row: int = -1, shown: int = -1) -> Label3D:
	var point := _row_point(card, row if row >= 0 else index, input)
	var color := COLORS[shown if shown >= 0 else spec[1]]
	var type: int = shown if shown >= 0 else spec[1]
	var spherical := _port_display == XREFeatureSettings.SPHERE and not _port_shapes and not (type == XREBlueprintGraph.EXEC and _style == XREFeatureSettings.ARCHETYPES)
	# An archetype card's execution ports stand on its edges, half out (D-106).
	if type == XREBlueprintGraph.EXEC and card.headed: point.x = card.width * (-0.5 if input else 0.5)
	var label_point := point
	var edge := _pins == XREFeatureSettings.EDGE
	# On the edge, in the middle of the node's depth (D-115); its name stays on the face.
	if edge: point = Vector3(point.x if card.shape != XREBlueprintShapes.Shape.NONE else card.width * (-0.5 if input else 0.5), point.y, 0.0)
	# Shaded by the view angle, as wires are, so that it reads as round.
	elif spherical: point.z = card.face + CARD_THICKNESS * 0.5 + PORT_RADIUS * SPHERE_LIFT
	var mesh := _edge_visual(type, color) if edge else _port_visual(type, color, spherical)
	mesh.position = point
	card.node.add_child(mesh)
	# By the port's index, not its row: an archetype's rows are in another order (D-101).
	card.ports[index if input else card.inputs.size() + index] = mesh
	if input:
		card.inputs[index] = point
		card.input_types[index] = spec[1]
	else:
		card.outputs[index] = point
		card.output_types[index] = spec[1]
	# An operator's ports have no names (D-065): its symbol says what they are.
	var text := label(spec[0] if not card.compact else "", 18)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if input else HORIZONTAL_ALIGNMENT_RIGHT
	text.position = label_point + Vector3(0.022 if input else -0.022, 0, 0)
	card.node.add_child(text)
	return text


## A port on a node's edge (Pins On the edge, D-115): an arrowhead along the flow
## for execution, else a ball, shaded by the view angle as wires are.
func _edge_visual(type: int, color: Color) -> MeshInstance3D:
	if type != XREBlueprintGraph.EXEC: return XRERig.create_vr_mesh(_sphere_mesh, wire_material(color))
	if _edge_arrow == null:
		_edge_arrow = CylinderMesh.new()
		_edge_arrow.top_radius = 0.0
		_edge_arrow.bottom_radius = PORT_RADIUS * 0.95
		_edge_arrow.height = PORT_RADIUS * 2.4
		_edge_arrow.radial_segments = 16
		_edge_arrow.rings = 1
	var arrow := XRERig.create_vr_mesh(_edge_arrow, wire_material(color))
	# Its tip along the card's rows, the way execution flows.
	arrow.rotation.z = -PI * 0.5
	return arrow


## Where the port of row [param row] is on the left ([param input]) or the right edge of [param card].
## An operator's result is in the middle of its card's height.
func _row_point(card: Card, row: int, input: bool) -> Vector3:
	# An archetype's row 0 is its header, the rest under it (D-101).
	if card.headed:
		var y := card.height * 0.5 - HEAD_HEIGHT * 0.5 if row == 0 else card.height * 0.5 - HEAD_HEIGHT - HEAD_GAP - ROW_HEIGHT * 0.5 - (row - 1) * ROW_HEIGHT
		return Vector3((-card.width * 0.5 + 0.014) if input else (card.width * 0.5 - 0.014), y, card.face + 0.003)
	# A tag's output is on its right end (D-106).
	if card.tag: return Vector3(card.width * 0.5 if not input else -card.width * 0.5, -row * ROW_HEIGHT, card.face + 0.003)
	# A bead's ports are on its arcs (D-103).
	if card.bead:
		var places := card.shape_inputs if input else card.shape_outputs
		var spot := places[row] if row < places.size() else Vector2(card.width * (-0.5 if input else 0.5), -row * ROW_HEIGHT)
		return Vector3(spot.x, spot.y, card.face + 0.003)
	# A sign's ports are on its outline (D-100).
	if card.shape != XREBlueprintShapes.Shape.NONE:
		var place := Vector2(card.width * 0.5, 0) if not input else card.shape_inputs[row] if row < card.shape_inputs.size() else Vector2(-card.width * 0.5, -row * ROW_HEIGHT)
		return Vector3(place.x, place.y, card.face + 0.003)
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


## Whether [param block]'s target has a member to pick — a property, a signal,
## an animation — which an adapter is for (D-112).
static func _has_member(block: Dictionary) -> bool:
	return not XREBlueprintTokens.member_key(block).is_empty()


## Builds the rows of [param layout] ([method _layout]) on [param card].
func _add_rows(card: Card, graph: XREBlueprintGraph, block: Dictionary, inputs: Array, outputs: Array, layout: Array) -> void:
	card.inputs.resize(inputs.size())
	card.input_types.resize(inputs.size())
	card.outputs.resize(outputs.size())
	card.output_types.resize(outputs.size())
	card.ports.resize(inputs.size() + outputs.size())
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
			var bare := heading_of(block) == XREFeatureSettings.MEMBER
			# Wired, an operator's input of any value takes the color of what comes in, as an Unreal wildcard pin.
			# Its token's type too, not wired (D-107): a 1.0 makes a float's port, not any value's.
			var operand := graph.operand_type(block, spec[2]) if card.compact and spec[1] == XREBlueprintGraph.VALUE and spec.size() > 2 else TYPE_NIL
			var shown := XREBlueprintGraph.port_type(operand) if operand != TYPE_NIL else -1
			var text := _add_port(card, spec, index, true, row, shown)
			# In on an archetype's header has no name: it is the header's edge (D-101).
			if entry.has("head"): text.text = ""
			var key: String = spec[2] if spec.size() > 2 else ""
			var linked: Dictionary = _linked_inputs.get(Vector2i(card.id, index), {})
			var target_link: bool = key == "target" and block["kind"] != "signal" and XREBlueprintTokens.targets_in_scene(_target_mode) \
					and XREBlueprintLinks.is_link(block, XREBlueprintLinks.TARGET) and not wired.has(index)
			if not linked.is_empty():
				# The wire from the variable's box is a link in the port (D-074).
				var variable := str(linked["variable"])
				_add_link(card, _row_point(card, row, true), XREBlueprintLinks.VARIABLE, linked["type"], variable if XREBlueprintLinks.shows_name(_link_preview) else "link",
						int(linked["getter"]), index, -1, variable)
			# With the member in the header the target row has only the wire, or a link's bare ring (D-101).
			elif target_link and bare:
				_add_target_link(card, block, _row_point(card, row, true), index, -1, true)
			# An adapter picks a member of its object (D-059); a call that takes the object
			# itself, as Rotate X, has none: its wire or link goes straight into the port (D-112).
			elif target_link and XREBlueprintTokens.adapter(_target_mode) and _has_member(block):
				_add_adapter(card, block, _row_point(card, row, true), true, index)
			elif target_link:
				_add_target_link(card, block, _row_point(card, row, true), index, -1)
				if not member_key.is_empty(): _add_member(card, text, member_key, str(params.get(member_key, "")), block)
			elif key == "target" and bare: pass
			elif key == "target" and XREBlueprintTokens.adapter(_target_mode) and block["kind"] != "signal":
				if not wired.has(index) and _has_member(block): _add_adapter(card, block, _row_point(card, row, true))
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
			var text := label(XREBlueprintFunctions.title_of(key) if not card.bead else "", 18)
			text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			text.position = point + Vector3(0.022, 0, 0)
			card.node.add_child(text)
			_add_token(card, key, params.get(key), -1, row, text, occupied, false, true, XREBlueprintTokens.expression_of(block, key))
		elif entry.has("source"):
			var text := _add_virtual(card, SOURCE, "signal", "Source", XREBlueprintGraph.OBJECT, row, true)
			var linked := XREBlueprintLinks.is_link(block, XREBlueprintLinks.TARGET)
			if heading_of(block) == XREFeatureSettings.MEMBER:
				if linked: _add_target_link(card, block, _row_point(card, row, true), -1, SOURCE, true)
			elif linked and XREBlueprintTokens.adapter(_target_mode): _add_adapter(card, block, _row_point(card, row, true), true, -1)
			elif linked: _add_target_link(card, block, _row_point(card, row, true), -1, SOURCE)
			# With the member in the header the Source has only its wire (D-101, D-107).
			if heading_of(block) == XREFeatureSettings.MEMBER: pass
			elif XREBlueprintTokens.member_on_card(_target_mode): _add_member(card, text, "signal", str(params.get("signal", "")), block)
			elif XREBlueprintTokens.adapter(_target_mode) and not linked: _add_adapter(card, block, _row_point(card, row, true))
		elif entry.has("variable"):
			var variable := graph.find_variable(str(params.get("variable", "")))
			var type := XREBlueprintGraph.port_type(XREBlueprintGraph.variable_type(variable)) if not variable.is_empty() else XREBlueprintGraph.VALUE
			var text := _add_virtual(card, VARIABLE, "variable", "Variable", type, row, true)
			# No name by the socket (D-061): the wire goes to the variable's box, which has it.
			if variable.is_empty(): _add_member(card, text, "", "choose a box", block)
			elif XREBlueprintLinks.is_link(block, XREBlueprintLinks.VARIABLE):
				var variable_name := str(variable["name"])
				var named := variable_name if XREBlueprintLinks.shows_name(_link_preview) else "link"
				_add_link(card, _row_point(card, row, true), XREBlueprintLinks.VARIABLE, type, "" if heading_of(block) == XREFeatureSettings.MEMBER else named,
						card.id, -1, VARIABLE, variable_name)
	for row: int in right.size():
		var entry := right[row]
		if entry.has("port"):
			var text := _add_port(card, outputs[entry["port"]], entry["port"], false, row)
			if entry.has("head"): text.text = ""
			# A Switch's case is its value's puck where its output's name is (D-140).
			if block["kind"] == "switch" and _value_mode != XREFeatureSettings.WINDOW and int(entry["port"]) < XREBlueprintGraph.pin_count(block):
				text.text = ""
				var case := XREBlueprintGraph.case_key(int(entry["port"]))
				_add_case_token(card, case, params.get(case), row)
			if card.headed and block["kind"] == "branch": _add_tab(card, card.outputs[int(entry["port"])], int(entry["port"]), str((outputs[int(entry["port"])] as Array)[0]))
			# A bead's outputs have small names outside it when it has more than one (D-103).
			if card.bead and right.size() > 1: _name_outside(text, str((outputs[entry["port"]] as Array)[0]))
		elif entry.has("finished"):
			var finished := _add_virtual(card, FINISHED, "wait", "Finished", XREBlueprintGraph.EXEC, row, false)
			if card.bead: _name_outside(finished, "Finished")
			card.finished = card.sockets.size() - 1
			card.waits = bool(params.get("wait", false))


## The value of a Switch's case [param key] as a puck in the row of its
## output, where the output's name would be, right by its port (D-140): the
## case is an output, so its value is never a plug or an input's socket.
func _add_case_token(card: Card, key: String, value: Variant, row: int) -> void:
	var shown := XREBlueprintTokens.shown(value, key, "")
	var width := XREBlueprintTokens.width(shown)
	var point := _row_point(card, row, false)
	var center := Vector3(card.width * 0.5 - CASE_INSET - width * 0.5, point.y, card.face + PUCK_DEPTH * 0.5 + 0.001)
	var token := make_token(value, key, width, false, false, false, -1, shown)
	token.position = center
	card.node.add_child(token)
	var socket := Socket.new()
	socket.kind = SQUARE
	socket.key = key
	socket.type = XREBlueprintTokens.color_type(value, key)
	socket.port = -1
	socket.center = center
	socket.size = Vector3(width, XREBlueprintTokens.HEIGHT + 0.004, PUCK_DEPTH + 0.004)
	socket.visual = token
	socket.text = token.get_meta(&"text") as Label3D if token.has_meta(&"text") else null
	socket.value = value
	card.sockets.append(socket)


## Puts a bead's output name [param text] small, outside it over its port (D-103).
func _name_outside(label_node: Label3D, text: String) -> void:
	label_node.text = text
	label_node.font_size = 13
	label_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label_node.position += Vector3(0.022 + 0.012, 0.012, 0)


## A port-like socket that is not one of the block's ports: Finished, Source or Variable.
func _add_virtual(card: Card, kind: int, key: String, title: String, type: int, row: int, input: bool) -> Label3D:
	var point := _row_point(card, row, input)
	if type == XREBlueprintGraph.EXEC and card.headed: point.x = card.width * (-0.5 if input else 0.5)
	var mesh := _port_visual(type, COLORS[type], false)
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
	# A bead has no room for a socket's name inside (D-103).
	var text := label(title if not card.bead else "", 18)
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
	var pin := _port_visual(XREBlueprintGraph.OBJECT, COLORS[XREBlueprintGraph.OBJECT], _port_display == XREFeatureSettings.SPHERE)
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
	var card := _find_card(id)
	_lay(link, start, -_side(card), end, Vector3.ZERO, _front(card))


## The link of [param block]'s target (D-074) in its input [param port] or its
## Source socket ([param kind]): its object's name or "link" on it, and a ring
## for the object's projection, which [XREBlueprints] puts in ([method target_heads]);
## [param bare] without a name, as the member is in the header (D-101).
func _add_target_link(card: Card, block: Dictionary, point: Vector3, port: int, kind: int, bare: bool = false) -> void:
	_add_link(card, point, XREBlueprintLinks.TARGET, XREBlueprintGraph.OBJECT, "" if bare else XREBlueprintLinks.target_text(block, _link_preview, _target_mode),
			card.id, port, kind, str((block["params"] as Dictionary).get("target", ".")), XREBlueprintLinks.shows_projection(_link_preview))


## A link (D-074) at [param point], the port of input [param port] or the
## socket of [param kind]: a plug saying [param text] in the colour of
## [param type], with a ring at its far end, where the wire it hides leaves.
## Its socket names the reference of [param key] held by block
## [param flag_block], [param value] — a variable's name or a target path.
## With [param projection] its ring waits for the object's projection.
func _add_link(card: Card, point: Vector3, key: String, type: int, text: String, flag_block: int, port: int, kind: int, value: String, projection: bool = false) -> void:
	var width := XREBlueprintTokens.width(text)
	# A bare ring says link where no projection comes in it (D-110).
	var link := make_link(text, width, type, "link" if text.is_empty() and not projection else "")
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
	socket.text = link.get_meta(&"text") as Label3D if link.has_meta(&"text") else null
	socket.value = value
	socket.end = link.position + (link.get_meta(&"end") as Vector3)
	card.sockets.append(socket)


## A link's mesh (D-074): a plug as a token's ([method make_token]), saying
## [param text], [param width] wide, in the colour of [param type], and its
## ring past the far end. Its ring's node is its "head" metadata, where the wire
## it hides leaves its "end", how far it reaches its "extent", its label its "text".
static func make_link(text: String, width: float, type: int, ring_text: String = "") -> Node3D:
	# A bare link (D-101) is its ring alone by the port, no plug (D-107).
	var bare := text.is_empty()
	var link := make_token(null, "", width, true, false, false, type, text) if not bare else Node3D.new()
	link.name = "Link"
	if bare: width = 0.0
	var head := _make_link_head(type, ring_text)
	head.position = Vector3((-PLUG_GAP - width - LINK_RING + 0.002) if not bare else -PORT_RADIUS - LINK_RING, 0, PLUG_DEPTH * 0.5)
	link.add_child(head)
	link.set_meta(&"head", head)
	link.set_meta(&"end", head.position + Vector3.LEFT * LINK_RING)
	link.set_meta(&"extent", (PLUG_GAP + width + LINK_RING * 2.0) if not bare else PORT_RADIUS + LINK_RING * 2.0)
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
	# The ends of a bent wire's tubes are its knots, not ports: they keep no margin (D-090).
	var margin := WIRE_MARGIN if wire.pieces.size() == 1 else 0.0
	for piece: XREGraphWire in wire.pieces:
		var hit := piece.intersect_ray(origin, direction, WIRE_REACH, maximum, margin)
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
	# An oval's ports have no names: its second and third tokens say theirs, "min 0" (D-100); so do a bead's of two values or more (D-103).
	if (card.shape == XREBlueprintShapes.Shape.OVAL and row > 0) or card.named_tokens: shown = "%s %s" % [key, shown]
	var width := XREBlueprintTokens.width(shown)
	var point := _row_point(card, row, true)
	var center: Vector3
	if plug:
		center = Vector3(point.x - PLUG_GAP - width * 0.5, point.y, card.face + PLUG_DEPTH * 0.5)
	elif card.shape != XREBlueprintShapes.Shape.NONE:
		# A sign has no room inside: a puck lies left of its port (D-100).
		center = Vector3(point.x - 0.016 - width * 0.5, point.y, card.face + PUCK_DEPTH * 0.5 + 0.001)
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
	# Turned as the cards are, with the display they are rebuilt for (D-090).
	_boxes.face(_head_position, _faces_user and _facing != XREFeatureSettings.OFF)
	_boxes.rebuild(graph, _box_places(graph), _value_mode, used, _composite == XREFeatureSettings.SPLIT, _style == XREFeatureSettings.ARCHETYPES, _port_shapes)
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
			# A Set writes its box: an archetypes' box takes it at its top (D-106).
			link.writes = block["kind"] == "set_variable"
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
