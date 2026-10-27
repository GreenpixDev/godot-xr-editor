@tool
class_name XREBlueprints
extends Node3D
## XR lifecycle and input adapter for the independent Blueprint document (D-025).
## Assignments go through XREDocument; spatial UI is never owned by the scene.

signal changed
## Asks for the graph's window of tab class [param type] — the parameters
## ([XREBlueprintParametersTab]) or the block palette ([XREBlueprintPaletteTab])
## — at [param pose], beside a block (D-044). [XREPanels] opens it there and
## calls [method window_closed] when it closes.
signal window_requested(type: GDScript, pose: Transform3D)
## Asks for the window of tab class [param type] to close: [param always], or
## only if it isn't pinned to a hand.
signal window_dismissed(type: GDScript, always: bool)
## Asks the open window of tab class [param type] to pulse where it is (D-046).
signal window_pulse_requested(type: GDScript)

## Neck pivot relative to the eye center, in head coordinates: behind and below
## the eyes. Turning or tilting the head then leaves the measured hand motion alone.
const NECK_FROM_EYES := Vector3(0.0, -0.075, 0.0805)
## For the HOMER gain the body is a vertical segment from shoulders to hips,
## below the neck pivot: a hand low at the lap is still near the body.
const BODY_TOP := 0.175
const BODY_BOTTOM := 0.65
## Farther than this from the head, in meters, the badge over a selected
## object grows with the distance and so keeps its size in view (D-043).
const BADGE_DISTANCE := 1.2
## Where the badge of a graph without an object stands in the graph's window
## group: over the graph, where its toolbar was before D-085.
const BADGE_FLOATING := Vector3(0.0, 0.42, 0.03)
## How far below a token and in front of it, toward the head, its keyboard opens, in meters (D-057).
## How far along a number's line the ray must go before the line follows it (D-062): a click stays a click.
const LINE_START := 0.008
const KEYBOARD_DROP := 0.2
const KEYBOARD_LEAD := 0.26
## The Vector and Color windows open toward their token from the head, this
## far from it, between these angles below the eyes, in radians (12° and
## 35°), and face the head as a tablet held in the hands does (D-064): within
## the reach of a seated user's hands, seen square on.
const NEAR_DISTANCE := 0.5
const NEAR_DOWN_LEAST := 0.21
const NEAR_DOWN_MOST := 0.61
## How dark all but the input in use goes (D-061).
const FOCUS_DIM := 0.87
## A trigger let go sooner than this, the value unchanged, is a click on a
## number or a choice (D-063): it types or steps; held longer it only shows its line.
const CLICK_USEC := 350000
## The keyboard is never nearer the head than this, in meters (D-063).
const KEYBOARD_NEAREST := 0.45
## How far the ray may move across the globe of colors, in meters, and the
## press still be a click that picks a color, not a turn (D-064).
const GLOBE_CLICK := 0.008
## What the pipette's ray is on (D-065): nothing, a window, the graph, an object of the scene.
const PIPETTE_NOTHING := 0
const PIPETTE_WINDOW := 1
const PIPETTE_GRAPH := 2
const PIPETTE_SCENE := 3
## How far below the Vector or Color window's bottom edge the keypad of one
## value stands, in meters: its tilted top clear of the window's buttons (D-063).
const KEYBOARD_BELOW_WINDOW := 0.25
## The keypad of a figure of the Vector or the Color window (D-067): its top
## edge this far down the window (a part of its height), the buttons under the
## figures covered, and this much nearer the head than the window.
const KEYPAD_TOP := 0.6
const KEYPAD_LEAD := 0.03
## Petals scrolled by the right stick tilted all the way, in rows a second (D-067: smoothly).
const FAN_SPEED := 8.0
## How many blocks the next-block suggestions offer, and a group of the ring (D-093).
const SUGGESTIONS := 5
const RING_BLOCKS := 8
## A copy let go nearer than this to where its stand-in started, in meters, goes beside its block (D-093).
const COPY_CLICK := 0.03
## Where the fan of choices and the ring sort, always over everything (D-096):
## over the cards in Front focus (100), under the windows over the focus veil
## (190) and the hands' rays (200).
const CHOICE_SORTING := 150.0
## The undo step, and the operation in the log, of a block added from the
## menu, by where it was picked (D-093); from a row without a search, Add Block.
const ADD_TITLES: Dictionary[String, String] = {"tile": "Add Block From Tile", "search": "Add Block From Search", "ring": "Add Block From Ring", "suggestion": "Add Suggested Block"}
## What the trigger on a member's name does, shown over it under the ray (D-057).
const MEMBER_HINT := "click: pick on the object's petals"
## Gap between a block and its parameters or palette window beside it, in
## meters, and how much nearer the head than the block, and than any card it
## covers, the window is: so that no card covers it or takes its ray.
const PARAMETERS_GAP := 0.04
const PARAMETERS_LIFT := 0.05
## A block the menu adds with no card to go beside stands this far behind the
## menu's window, in meters, from the head (D-090); cards nearer each other in
## depth than [constant MENU_DEPTH_GAP] make way for it, others don't.
const MENU_BEHIND := 0.08
const MENU_DEPTH_GAP := 0.15
## A ray gone off the graph keeps what it was on in focus this long, in
## seconds (D-072): passing between two cards, the graph doesn't flash.
const FOCUS_HOLD := 0.15
## A link button (D-074) stays this long, in seconds, after the ray left what
## put it up, for the ray to reach it; it stands this far above a port or a
## link, and this much nearer the head than a wire, in meters.
const BUTTON_HOLD := 0.5
const BUTTON_RISE := 0.028
const BUTTON_LEAD := 0.012
## A wire pulled at least this part of the way into its port becomes a link (D-074).
const PULL_DONE := 0.5
## How many parts of an object, and nodes under it, its projection on a link takes at most.
const PROJECTION_PARTS := 24
const PROJECTION_NODES := 200
## The buttons of the wire's menu (D-090), with Link from wire on Wire menu:
## make the wire a link, add a point — a bend — where the ray is on it, or
## take off the point the ray is on; with the colors they light up in.
const WIRE_LINK := 0
const WIRE_POINT := 1
const WIRE_UNBEND := 2
const WIRE_MENU_TITLES: Array[String] = ["Link", "Point", "Delete point"]
const WIRE_MENU_GLYPHS: Array[StringName] = [&"link", &"bend", &"trash"]
const WIRE_MENU_COLORS: Array[Color] = [Color("1f8fb5"), Color("3f9e6a"), Color(0.86, 0.2, 0.18)]
## Auto link (D-090): a new wire to a variable or an object with more wires and
## links than this already, longer than this in meters, becomes a link.
const AUTO_LINK_REFERENCES := 1
const AUTO_LINK_DISTANCE := 0.5
## What the ray on a link says (D-074).
const LINK_HINT := "click: another one  ·  grip: move, let go in the air: a wire"
## What the ray on a link says with Link from wire on Wire menu (D-090).
const LINK_MENU_HINT := "click: a wire again  ·  grip: move"
## How long the cards that keep a variable from being deleted flash, in seconds (D-079).
const FLASH_TIME := 1.5
## What of the graph is open for the user, bits of [method _open_inputs]: each
## one opened is a change of the headset's history, which undo closes (D-087).
const _OPEN_GRAPH := 1
const _OPEN_PARAMETERS := 2
const _OPEN_MENU := 4
const _OPEN_TOKENS := 8
const _OPEN_VECTOR := 16
const _OPEN_COLOR := 32
const _OPEN_KEYBOARD := 64
const _OPEN_PETALS := 128
const _OPEN_CHOICE := 256
const _OPEN_WIRE := 512
const _OPEN_TARGET := 1024
const _OPEN_NAMES: Dictionary[int, String] = {
	_OPEN_GRAPH: "Open graph", _OPEN_PARAMETERS: "Parameters", _OPEN_MENU: "Block menu", _OPEN_TOKENS: "Tokens",
	_OPEN_VECTOR: "Vector", _OPEN_COLOR: "Color", _OPEN_KEYBOARD: "Keyboard", _OPEN_PETALS: "Members",
	_OPEN_CHOICE: "Choice", _OPEN_WIRE: "Wire", _OPEN_TARGET: "Pick target",
}

class Pointer:
	var hand: XREHand
	## The grip went down in empty space and is still held: with
	## [constant XREFeatureSettings.SELECT_ADD] at [constant XREFeatureSettings.GRIP],
	## the other hand adds blocks to the selection (D-117), as it adds scene objects (D-115).
	var adding := false
	## The other selected blocks the held card carries (D-117), and where each was when the hold began.
	var group: Array[int] = []
	var group_starts: Array[Vector3] = []
	## A brush stroke over the cards (D-119): whether one is swept, whether it
	## replaces the selection, the block it began on when it adds (the trigger
	## added it or took it out already), and the blocks it crossed.
	var brushing := false
	var brush_replace := false
	var brush_start := -1
	var brushed: Array[int] = []
	## A selection box on the graph's plane (D-120): whether one is drawn,
	## whether it replaces the selection, and its corners in the canvas's space.
	var boxing := false
	var box_replace := false
	var box_from := Vector2.ZERO
	var box_to := Vector2.ZERO
	var surface: XREPanelSurface
	var drives := false
	var held: Node3D
	var hold := Transform3D.IDENTITY
	var block := -1
	## The variable whose box is held (D-078), carried as a card is; empty for none.
	var box := ""
	var before := Transform3D.IDENTITY
	var touched := false
	var grab_point := Vector3.ZERO
	var distance := 0.0
	var body_offset := Vector3.ZERO
	var along := Vector3.FORWARD
	var depth_uses_grip := false
	var gain := 1.0
	## A held window: the one whose handles light up, the corner it was taken
	## by (-1 for its interface) and whether the trigger holds it, not the grip.
	var window: XREPanelSurface
	var corner := -1
	var by_trigger := false
	## Where the held window was when it was taken: undo puts it back there (D-087).
	var window_before := Transform3D.IDENTITY
	## A token turned by the wrist while the trigger is held (D-052): its block
	## (or the variable of its box), parameter, value now and at the start, the
	## hand's basis at the start, and the turn so far.
	var token_block := -1
	var token_box := ""
	var token_key := ""
	var token_value: Variant
	var token_start: Variant
	var token_basis := Basis.IDENTITY
	var token_angle := 0.0
	var token_last := 0.0
	var token_steps := 0
	## How far the wrist turned lately, decaying over a tenth of a second, and when it was last looked at.
	var token_recent := 0.0
	var token_usec := 0
	## Where the ray met the token at the press, and how far: moving the ray off it drags the token.
	var token_point := Vector3.ZERO
	var token_distance := 0.0
	## Thumbstick steps not yet made while the trigger holds a number, and whether the value changed at all.
	var token_stick := 0.0
	var token_moved := false
	## Steps the ray has made up the token's plane since the trigger took it (D-061).
	var token_ray := 0
	## The ray has left the point it took a number at: the number line follows it (D-062).
	var token_line := false
	## When the trigger took the token: a short press is a click (D-063).
	var token_press_usec := 0
	## The trigger closed an input by a click away (D-063): until it is let go
	## the click goes nowhere else, nor selects a scene object.
	var swallow := false
	## A carried token is held by the trigger, not the grip: it was dragged off its socket.
	var carried_trigger := false
	## An arrow of a vector token pulled while the trigger is held: its axis, the pull's start and the value then.
	var arrow_axis := -1
	var arrow_start := 0.0
	var arrow_value: Variant
	var arrow_block := -1
	var arrow_key := ""
	var arrow_box := ""
	## How far the arrow was pulled at most: a click without a pull sets its component to 0.
	var arrow_reach := 0.0
	## The white arrow (D-060): how far along the ray it was taken, and the point taken.
	var arrow_distance := 0.0
	var arrow_grab := Vector3.ZERO
	## The trigger on the globe of colors (D-064): where on its plane it took
	## it, its turn then, the hue and lightness there, and whether it turned since.
	var globe_drag := false
	var globe_start := Vector2.ZERO
	var globe_turn := Vector2.ZERO
	var globe_pick := Vector2.ZERO
	var globe_moved := false
	## A trigger pressed on petals: the fan, the item under it, the height it
	## was pressed at, the rows scrolled since and whether it dragged (D-052).
	var fan: XREBlueprintPetals
	var fan_item: Dictionary = {}
	var fan_height := 0.0
	var fan_rows := 0.0
	var fan_dragged := false
	## This hand's ray lit a petal of the fan last frame.
	var fan_hover := false
	## A token the grip carries: its mesh, value and parameter, the socket it
	## came from (none from the tray), and whether it is a copy.
	var carried: Node3D
	var carried_value: Variant
	var carried_key := ""
	var carried_block := -1
	var carried_copy := false
	## What this hand's ray put in focus this frame (D-072): a card, -1 for none,
	## and a variable's box, empty for none.
	var focus := -1
	var focus_box := ""
	## Links (D-074). The link button this hand's ray put up — on a wire, over a
	## port or by a link —, the ref of [XREBlueprintLinks] it acts on, whether
	## it makes a link or takes one back to its wire, where it stands (global)
	## and how long it stays without the ray.
	var button: Node3D
	var button_ref: Dictionary = {}
	var button_make := true
	var button_point := Vector3.ZERO
	var button_hold := 0.0
	## A wire the grip pulls into its port: its ref, where on the ray it was
	## taken and how far, and its mesh, hidden meanwhile.
	var pull: Dictionary = {}
	var pull_start := Vector3.ZERO
	var pull_distance := 0.0
	var pull_wire: XREGraphWire
	## Where a carried link came from, as a ref; empty from the tray.
	var carried_ref: Dictionary = {}
	## A wire's bend dragged (D-081): the wire's graph edge, -1 for none, and the
	## bend; whether the drag added it; whether the trigger holds it, not the
	## grip; where it was taken and its offset from the rod's end, which is the
	## card's rod ([member distance] and on); whether it has left that point by
	## [constant LINE_START] yet.
	var bend_edge := -1
	var bend_index := -1
	var bend_new := false
	var bend_trigger := false
	var bend_start := Vector3.ZERO
	var bend_offset := Vector3.ZERO
	var bend_moved := false
	## The frame this hand's ray was last on a wire: after it, the knot it lit is let go.
	var wire_frame := -1
	## The wire under this hand's ray that may become a link, as a ref, with Link
	## from wire on Wire menu (D-090): empty for none. Its menu offers Link.
	var wire_ref: Dictionary = {}

class Marker:
	var host: Node
	var anchor: Node3D
	var visual: Node3D
	var path: String

class TargetWire:
	var id: int
	var port: int
	var target: Node
	var anchor: Node3D
	## The canvas's wire drawn ([method XREBlueprintCanvas.add_scene_link]),
	## which bends (D-081), and its tube from the card, up to its first bend.
	var canvas_wire: XREBlueprintCanvas.Wire
	var mesh: XREGraphWire
	## Where the wire's stem grows from on its target, in the target's space,
	## and the petal of its member there, on a stem from that point, where the
	## wire ends (D-052): [member offset] from the point, global.
	var point := Vector3.ZERO
	var label: Node3D
	var stem: MeshInstance3D
	var dot: MeshInstance3D
	var offset := Vector3.ZERO
	var width := 0.0
	## The target's local bounds: the petals of one object stand in one column beside them.
	var bounds := AABB()
	## The wire leaves an event's Source socket, not a port.
	var source := false
	## A ray is on its petal this frame: it grows.
	var hot := false
	## A ray is on its Target port, its adapter or its Source this frame: it thickens (D-061).
	var lit := false
	var normal: Material
	var lit_material: Material
	## How it, its petal and its stem are painted for the focus (D-072): -1 not yet.
	var look := -1
	## Its block's target is a link (D-074): the wire is hidden, or drawn faint, from the link's ring.
	var link := false

var blueprint: XREBlueprintDocument
var canvas: XREBlueprintCanvas
## The form of the Vector window (D-061).
var vector_panel: XREBlueprintVectorPanel
## The form of the Color window (D-064).
var color_panel: XREBlueprintColorPanel
## The panels the graph's windows open in ([method XREPanels.set_blueprints]); null for the graph alone, as in a test.
var panels: XREPanels
var parameters: XREBlueprintEditor
var status := "Select an object, then Create Blueprint or Open Blueprint."
var logic_mode := false
## Optional project folder for graph creation; empty uses the host scene's folder.
var source_folder := ""
var _document: XREDocument
var _rig: XRERig
var _icons: XREIcons
var _root: Node
var _workspace: Node3D
var _floating_ui: Node3D
var _dimmer: MeshInstance3D
## Darkens all but the input in use (D-061): a value's widget, the keyboard,
## the petals of a member being picked. Drawn over cards and windows, under
## what is drawn over everything.
var _focus_dimmer: MeshInstance3D
var _focused := false
## The block menu's form ([XREBlueprintPaletteTab]): the action menu of the
## desktop view, with larger rows (D-051). A card's plus, a wire let go in
## empty space and Add block of the Blueprints tab open it.
var block_menu: XREBlueprintActionMenu
## Where the menu adds its block: beside this card, wired to this port
## ([method XREBlueprintDocument.insert_block]), or at a point of the
## workspace where a wire was let go; and in which direction it was added.
var _menu_card := -1
var _menu_wire: Dictionary = {}
var _menu_point := Vector3.ZERO
var _menu_at_point := false
## A row pulled out of the menu (D-051): the hand that pulls it, its distance and its block's stand-in.
var _drag_action: Dictionary = {}
var _drag_hand: XREHand
var _drag_distance := 0.6
var _ghost: Node3D
## The ready tokens of the Tokens window ([XREBlueprintTokensTab], D-052).
var token_tray: XREBlueprintTokenTray
## The members of a scene object a wire picks, and the white outline of that object (D-052).
var _petals: XREBlueprintPetals
var _petal_outline: XREOutline
## The block whose member the petals pick, -1 for the selected object's
## petals of Create from scene; whether they are at its Target port, for a
## target that comes by wire.
var _petal_block := -1
var _petal_dynamic := false
## A small fan of choices at a point: Get, Set or Tween for a property, or
## the blocks likely next (D-093); or the ring of the block palette. Either
## of [member _fan_choice] and [member _ring], the one in use.
var _choice: XREBlueprintPetals
var _choice_point := Vector3.ZERO
var _fan_choice: XREBlueprintPetals
var _ring: XREBlueprintRing
## Whether the choice open stands for the block menu (D-093) — the next-block
## suggestions or the ring —, the point it opened at (global) and what opens
## the menu's window where it belongs.
var _choice_menu := false
var _choice_anchor := Vector3.ZERO
var _choice_window := Callable()
## The block a copy is taken of (D-093), and where the copy's stand-in started.
var _copy_source := -1
var _copy_start := Vector3.ZERO
## Where the suggestions or the ring stood whose block is being added (D-093): it goes there without a card; else null.
var _offered_at: Variant = null
## A wire from a petal of the selected object (Create from scene) and the hand that draws it.
var _member_link: Dictionary = {}
var _member_hand: XREHand
## A Source or Variable socket being wired, by the hand that started it; a box starts one too.
var _link_kind := -1
var _link_block := -1
var _link_box := ""
## The component of [member _link_box] a wire is drawn from (D-105), -1 for the whole value.
var _link_component := -1
var _link_hand: XREHand
## Play Animation's output 0 a wire is drawn from: 1 Finished, 0 Then, -1 another port.
var _pending_finished := -1
## The wire drawn from an input ends on a variable's box as a link (D-074):
## it was a link, or a link from the tray was laid on that input.
var _pending_link := false
## The linkable wire the last [method _link_wire_hit] met, as a ref, and where (global).
var _wire_ref: Dictionary = {}
var _wire_point := Vector3.ZERO
## The wire's menu (D-090): the hand whose trigger holds it open, or null, and
## what it is for — [code]{"edge", "bend", "piece", "point", "ref"}[/code]: the
## canvas's wire (-1 for one it doesn't bend), the knot the ray was on (-1 for
## none), the piece and the point (the canvas's space) where it was on the
## wire, and the ref of [XREBlueprintLinks] for its link, empty if it may not become one.
var _wire_menu: XREArcMenu
var _wire_menu_hand: XREHand
var _wire_menu_for: Dictionary = {}
## Meshes baked from CSG objects for the projections on links, by the object's instance id; forgotten on a scene edit.
var _projection_meshes: Dictionary[int, Mesh] = {}
## The token typed on the keyboard, or a new variable's name ([member _token_field]).
var _token_field: LineEdit
var _token_edit: Dictionary = {}
## The input around a token, as in the concept: a dial, a choice, a globe of colors (D-064), arrows (D-052).
var _token_editor: XREBlueprintTokenEditor
## What covers an input in use becomes see-through (D-066): the scene's objects
## through it, the graph's through the canvas; the inputs as spheres, reused.
var _fade := XREBlueprintFade.new()
var _focus_targets := PackedVector4Array()
## Whether the hands' rays are drawn over everything now.
var _rays_on_top := false
## How long what the rays were on stays in focus after they left it (D-072).
var _focus_hold := 0.0
## The token the Vector or the Color window edits: [code]{"block", "key", "box", "value", "start"}[/code],
## and [code]"color"[/code] for a color.
var _value_edit: Dictionary = {}
## The hand that holds the Color window's pipette, or null (D-065): its clicks take colors.
var _pipette_hand: XREHand
## The pipette's model, in that hand instead of its controller.
var _pipette: XREBlueprintPipette
## What the pipette's ray met this frame ([method _pipette_hit]): one of the
## PIPETTE_ constants, how far, and where — a window and its pixel, or a scene object and the point on it.
var _pipette_on := PIPETTE_NOTHING
var _pipette_distance := 0.0
var _pipette_window: XREPanelSurface
var _pipette_pixel := Vector2.ZERO
var _pipette_node: Node
var _pipette_point := Vector3.ZERO
## The delete button acted on a token or a box this frame: the selected block stays.
var _delete_consumed := false
## What each hand's ray picks on the value widget this frame, lit together in [method _process].
var _editor_right: Dictionary = {}
var _editor_left: Dictionary = {}
## The frame a token under a ray last showed its hint in.
var _hint_frame := -1
## The socket the tray's dimming fits: the card and the socket index, or -1.
var _tray_socket := Vector2i(-1, -1)
## Solid tokens hung in front of the tray's cells (D-055), rebuilt when its cells change.
var _tray_tokens: Array[Node3D] = []
var _tray_dirty := true
## Keeps the forms off screen while no window shows them.
var _forms_home: SubViewport
## Tab classes of the graph's windows that are open (D-044).
var _open_windows: Array[GDScript] = []
## The block the parameters window was opened beside, or -1, and on which side of it: -1 left, 1 right.
var _parameters_block := -1
var _parameters_side := -1.0
## The badge over the selected object, or over the graph's (D-085).
var _badge: XREBlueprintBadge
var _badge_anchor: Node3D
var _badge_geometry: Array[GeometryInstance3D] = []
var _pointers: Array[Pointer] = []
var _markers: Array[Marker] = []
var _target_wires: Array[TargetWire] = []
var _catalog := PackedStringArray()
## The block selected last, -1 for none; the parameters window is for it.
var _selected := -1
## Every selected block (D-117): several with Add to selection, the last one [member _selected].
var _selected_blocks: Array[int] = []
## The selection box drawn on the graph's plane (D-120).
var _box_lines: XREBoundsBox
var _pending_id := -1
var _pending_port := -1
var _pending_input := false
var _pending_hand: XREHand
var _target_pick := -1
var _refresh_queued := false
var _rebuild_queued := false
var _picker: XREPicker
var _keyboard: XREVirtualKeyboard
var _keyboard_target: WeakRef
## The rig-locked windows of the graph, which move by their corner handles (docs/vr_ui.md, D-040).
var _windows: Array[XREPanelSurface] = []
## The object a new graph was opened for by selecting it, not yet saved (D-063).
var _unsaved_host: WeakRef
## The graph's history version the headset's history knows of (D-087).
var _graph_version := 0
## What of the graph was open for the user last frame, as bits of _OPEN_*, and
## the graph's file then ([method _watch_inputs]).
var _seen_open := 0
var _seen_path := ""
var _built_state: Dictionary = {}
var _built_path := ""
var _built_host: WeakRef
var _built_script: Script


func _init(document: XREDocument, rig: XRERig, icons: XREIcons, theme: Theme = null) -> void:
	_document = document
	_rig = rig
	_icons = icons
	blueprint = XREBlueprintDocument.retain_editor_shared()
	_box_lines = XREBoundsBox.new(Color.WHITE)
	_box_lines.name = "SelectionBox"
	add_child(_box_lines)
	_workspace = Node3D.new()
	_workspace.name = "Workspace"
	_workspace.top_level = true
	add_child(_workspace)
	_floating_ui = Node3D.new()
	_floating_ui.name = "FloatingUI"
	add_child(_floating_ui)
	canvas = XREBlueprintCanvas.new()
	canvas.set_display(document.features.get_value(XREFeatureSettings.NODE_DISPLAY))
	canvas.set_style(document.features.get_value(XREFeatureSettings.NODE_STYLE))
	canvas.set_shrink(document.features.get_value(XREFeatureSettings.NODE_SHRINK))
	canvas.set_heading(document.features.get_value(XREFeatureSettings.NODE_HEADING))
	canvas.set_port_shapes(document.features.get_value(XREFeatureSettings.PORT_SHAPES) == XREFeatureSettings.ON)
	canvas.set_composite(document.features.get_value(XREFeatureSettings.COMPOSITE_VALUES))
	canvas.set_class_icons(document.get_class_icon)
	canvas.set_plus_shown(document.features.get_value(XREFeatureSettings.CARD_PLUS) == XREFeatureSettings.SHOWN)
	canvas.set_bends_shown(document.features.get_value(XREFeatureSettings.WIRE_BENDS) == XREFeatureSettings.ON)
	canvas.set_copy_shown(document.features.get_value(XREFeatureSettings.BLOCK_COPY) == XREFeatureSettings.ON)
	canvas.set_port_display(document.features.get_value(XREFeatureSettings.PORT_DISPLAY))
	canvas.set_parameter_modes(document.features.get_value(XREFeatureSettings.VALUE_INPUT), document.features.get_value(XREFeatureSettings.TARGET_INPUT),
			document.features.get_value(XREFeatureSettings.ANIMATION_WAIT), document.features.get_value(XREFeatureSettings.VARIABLE_INPUT))
	canvas.set_focus_modes(document.features.get_value(XREFeatureSettings.FOCUS), document.features.get_value(XREFeatureSettings.DEFOCUS))
	canvas.set_link_modes(document.features.get_value(XREFeatureSettings.LINK_PREVIEW), document.features.get_value(XREFeatureSettings.LINK_WIRES))
	_workspace.add_child(canvas)
	_petals = XREBlueprintPetals.new()
	add_child(_petals)
	_fan_choice = XREBlueprintPetals.new()
	_fan_choice.name = "Choice"
	add_child(_fan_choice)
	_ring = XREBlueprintRing.new()
	add_child(_ring)
	for fan: XREBlueprintPetals in [_fan_choice, _ring]:
		fan.top_sorting = CHOICE_SORTING
		fan.set_on_top(true)
	_choice = _fan_choice
	_wire_menu = XREArcMenu.new(WIRE_MENU_TITLES, WIRE_MENU_GLYPHS, WIRE_MENU_COLORS)
	_wire_menu.name = "WireMenu"
	add_child(_wire_menu)
	_petal_outline = XREOutline.new(Color.WHITE)
	add_child(_petal_outline)
	_forms_home = SubViewport.new()
	_forms_home.name = "FormsHome"
	_forms_home.disable_3d = true
	_forms_home.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_forms_home)
	parameters = XREBlueprintEditor.new()
	parameters.operation_source = &"vr_panel"
	parameters.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if theme != null: parameters.theme = theme
	# Only what the parameter settings leave in the window shows there (D-052).
	parameters.parameter_filter = shows_in_window
	_forms_home.add_child(parameters)
	parameters.setup(blueprint, true)
	parameters.graph_scene_requested.connect(_open_owner_scene)
	parameters.text_edit_requested.connect(_show_keyboard, CONNECT_DEFERRED)
	_keyboard = XREVirtualKeyboard.new(theme)
	# Over everything, so that it never sinks into a card (D-058); grip moves it, × closes it.
	_keyboard.set_on_top(true)
	# Over the block palette (D-086) too, whose search it types.
	_keyboard.set_top_sorting(XREPanelSurface.OVER_FOCUS_SORTING + 1.0)
	_keyboard.applied.connect(_apply_keyboard)
	_floating_ui.add_child(_keyboard)
	_build_block_menu(theme)
	_update_palette_mode()
	vector_panel = XREBlueprintVectorPanel.new()
	if theme != null: vector_panel.theme = theme
	vector_panel.zero_pressed.connect(_vector_action.bind(false))
	vector_panel.normalize_pressed.connect(_vector_action.bind(true))
	vector_panel.component_pressed.connect(_type_component)
	vector_panel.component_zero_pressed.connect(_zero_component)
	vector_panel.done_pressed.connect(_end_vector.bind(true))
	vector_panel.close_pressed.connect(_close_inputs)
	_forms_home.add_child(vector_panel)
	color_panel = XREBlueprintColorPanel.new()
	if theme != null: color_panel.theme = theme
	color_panel.color_picked.connect(_preview_color)
	color_panel.saturation_changed.connect(_saturate)
	color_panel.channel_pressed.connect(_type_channel)
	color_panel.hex_pressed.connect(_type_hex)
	color_panel.pipette_toggled.connect(_set_pipette)
	color_panel.text_edit_requested.connect(_type_in_picker, CONNECT_DEFERRED)
	color_panel.done_pressed.connect(_end_color.bind(true))
	color_panel.close_pressed.connect(_close_inputs)
	_forms_home.add_child(color_panel)
	_pipette = XREBlueprintPipette.new()
	add_child(_pipette)
	token_tray = XREBlueprintTokenTray.new()
	if theme != null: token_tray.theme = theme
	token_tray.cells_changed.connect(func() -> void: _tray_dirty = true)
	_forms_home.add_child(token_tray)
	_token_field = LineEdit.new()
	_token_field.name = "TokenText"
	_token_field.text_submitted.connect(_token_text_submitted)
	_forms_home.add_child(_token_field)
	_token_editor = XREBlueprintTokenEditor.new()
	add_child(_token_editor)
	_focus_targets.resize(XREBlueprintFade.MOST)
	_windows = [_keyboard]
	for window: XREPanelSurface in _windows: window.add_corner_handles()
	_update_window_shape()
	_workspace.hide()
	_floating_ui.hide()
	_badge = XREBlueprintBadge.new(theme)
	_badge.blueprint_pressed.connect(open_selected)
	_badge.add_pressed.connect(open_block_menu)
	_badge.delete_pressed.connect(delete_blueprint)
	_badge.close_pressed.connect(close_graph)
	add_child(_badge)
	_badge.set_shown(false)
	for hand: XREHand in [rig.right_hand, rig.left_hand]:
		var pointer := Pointer.new()
		pointer.hand = hand
		_pointers.append(pointer)
	_picker = XREPicker.new()


func _enter_tree() -> void:
	print("XR Editor: Blueprints VR D-052 loaded from ", ProjectSettings.globalize_path("res://"))
	_dimmer = create_dimmer()
	_rig.camera.add_child(_dimmer)
	_dimmer.hide()
	_focus_dimmer = create_dimmer(FOCUS_DIM, Material.RENDER_PRIORITY_MAX)
	_focus_dimmer.name = "FocusDimmer"
	_rig.camera.add_child(_focus_dimmer)
	_focus_dimmer.hide()
	_picker.scenario = get_viewport().find_world_3d().scenario
	_root = _document.get_scene_root()
	blueprint.update_active_scene(_root)
	blueprint.changed.connect(_schedule_rebuild)
	blueprint.operation_recorded.connect(_graph_operation)
	blueprint.history.version_changed.connect(_graph_history_changed)
	_graph_version = blueprint.history.get_version()
	_see_inputs()
	_document.history.replayed.connect(_see_inputs)
	_document.selection_changed.connect(_selection_changed)
	_document.scene_changed.connect(_scene_changed)
	_document.files_changed.connect(_schedule_refresh)
	_document.blueprint_bindings_changed.connect(_schedule_refresh)
	_document.operation_recorded.connect(_scene_operation)
	_document.features.changed.connect(_feature_changed)
	_document.prepare_play = prepare_play
	_document.prepare_copy = prepare_copy
	blueprint.amend = _link_new_references
	_schedule_refresh()


func _exit_tree() -> void:
	# The controller the pipette was held instead of comes back.
	if _pipette_hand != null: _controller(_pipette_hand).set_model_shown(true)
	_set_ui_overlay(false)
	_fade.release()
	if _rays_on_top:
		_rays_on_top = false
		for hand: XREHand in [_rig.left_hand, _rig.right_hand]: hand.set_on_top(false)
	if is_instance_valid(_dimmer): _dimmer.queue_free()
	if is_instance_valid(_focus_dimmer): _focus_dimmer.queue_free()
	cancel_connection()
	_target_pick = -1
	save_draft()
	if blueprint.amend == _link_new_references: blueprint.amend = Callable()
	blueprint.changed.disconnect(_schedule_rebuild)
	blueprint.operation_recorded.disconnect(_graph_operation)
	blueprint.history.version_changed.disconnect(_graph_history_changed)
	_document.history.replayed.disconnect(_see_inputs)
	_document.selection_changed.disconnect(_selection_changed)
	_document.scene_changed.disconnect(_scene_changed)
	_document.files_changed.disconnect(_schedule_refresh)
	_document.blueprint_bindings_changed.disconnect(_schedule_refresh)
	_document.operation_recorded.disconnect(_scene_operation)
	_document.features.changed.disconnect(_feature_changed)
	if _document.prepare_play == prepare_play: _document.prepare_play = Callable()
	if _document.prepare_copy == prepare_copy: _document.prepare_copy = Callable()
	for pointer: Pointer in _pointers:
		pointer.hand.unclaim(self)
		pointer.hand.unclaim_stick(self)
	_picker = null
	XREBlueprintDocument.release_editor_shared()


func _process(delta: float) -> void:
	var head := _rig.camera.global_position
	var up := _rig.global_basis.y.normalized()
	if is_instance_valid(_badge_anchor) and _badge_anchor.is_inside_tree():
		# As light icons do (XREIcons), the badge keeps its size in view farther than
		# BADGE_DISTANCE away, so that its text stays readable (D-043); nearer, it keeps its size.
		var top := _badge_top()
		_badge.place(top, head, up, maxf(top.distance_to(head) / BADGE_DISTANCE, 1.0))
	elif _workspace.visible:
		# A graph without an object in the scene: its badge stands over the graph (D-085).
		var point := _floating_ui.global_transform * BADGE_FLOATING
		_badge.float_at(Transform3D(XREPanels.facing(point, head, up), point))
	else:
		_badge.set_shown(false)
	for marker: Marker in _markers:
		marker.visual.visible = logic_mode and is_instance_valid(marker.host) and marker.host.is_inside_tree() and is_instance_valid(marker.anchor) and marker.anchor.is_inside_tree()
		if marker.visual.visible: marker.visual.global_position = marker.anchor.global_position + _rig.global_basis.y * 0.22
	if _workspace.visible: canvas.face_user(_rig.camera.global_position)
	_delete_consumed = false
	_close_on_click_away()
	for wire: TargetWire in _target_wires:
		wire.hot = false
		wire.lit = false
	for pointer: Pointer in _pointers:
		pointer.focus = -1
		pointer.focus_box = ""
		_update_pointer(pointer, delta)
		_keyboard.poll_trigger(pointer.hand, pointer.surface == _keyboard and _keyboard.is_shown())
		# A ray off the wires this frame lets go of the knot it lit (D-081).
		if pointer.wire_frame != Engine.get_process_frames(): canvas.hover_bend(-1, -1, Vector3.ZERO, pointer.hand == _rig.right_hand)
	_update_buttons(delta)
	if _token_editor.is_interactive(): _token_editor.light(_editor_right if not _editor_right.is_empty() else _editor_left)
	_place_window_widgets()
	_update_focus()
	_update_fade()
	_update_graph_focus(delta)
	# The rays over an input in use (D-061), over what Front draws over everything (D-075) and over
	# the block palette, drawn over everything too (D-086): with no card in focus, as from the badge's
	# plus, it hid the ray on it (D-090) — opened by the graph, or from the launcher's Add block.
	var rays_on_top := _focused or canvas.is_front_focused() or is_block_palette_shown() or (is_instance_valid(panels) and panels.has_window_on_top())
	if rays_on_top != _rays_on_top:
		_rays_on_top = rays_on_top
		for hand: XREHand in [_rig.left_hand, _rig.right_hand]: hand.set_on_top(rays_on_top)
	_editor_right = {}
	_editor_left = {}
	_update_target_wires()
	_update_drag()
	_update_tray_tokens()
	if _token_editor.mode == XREBlueprintTokenEditor.HINT and _hint_frame != Engine.get_process_frames(): _token_editor.close()
	_petals.follow(_rig.camera.global_position)
	var marked := _petals.get_object()
	if marked != null and marked.is_inside_tree(): _petal_outline.show_node(marked, XREPicker.get_local_bounds(marked))
	elif _petal_outline.is_active(): _petal_outline.clear()
	var delete_hand := _rig.get_action_hand(_document.features, XREFeatureSettings.DELETE)
	if _workspace.visible and not _delete_consumed and _rig.is_action_pressed(_document.features, XREFeatureSettings.DELETE) and delete_hand.is_free_for(self):
		# With the graph open, the button deletes in the graph, never the scene's selection.
		_consume_delete()
		delete_hand.claim(self)
		delete_block()
	_watch_inputs()


## What of the graph is open for the user now, as bits of _OPEN_*: the graph,
## its windows, an input in use, a wire being drawn, a target being picked.
func _open_inputs() -> int:
	var open := 0
	if _workspace.visible: open |= _OPEN_GRAPH
	if XREBlueprintParametersTab in _open_windows: open |= _OPEN_PARAMETERS
	if XREBlueprintPaletteTab in _open_windows: open |= _OPEN_MENU
	if XREBlueprintTokensTab in _open_windows: open |= _OPEN_TOKENS
	if _token_editor.mode == XREBlueprintTokenEditor.ARROWS and not _value_edit.is_empty(): open |= _OPEN_VECTOR
	if _editing_color(): open |= _OPEN_COLOR
	if _keyboard.is_shown(): open |= _OPEN_KEYBOARD
	if _petals.is_open() and (_petal_block >= 0 or _petal_dynamic): open |= _OPEN_PETALS
	if _choice.is_open(): open |= _OPEN_CHOICE
	if _pending_id >= 0 or _link_kind >= 0 or not _member_link.is_empty(): open |= _OPEN_WIRE
	if _target_pick >= 0: open |= _OPEN_TARGET
	return open


## Watches what of the graph the user opens (D-087), however it opened — a
## click, a wire let go in empty space, a token typed into —: each is a change
## of the headset's history, which undo closes without keeping what was being
## edited, as its × does, and redo opens again where it can. What closes by
## itself, as the keyboard does when its value is typed, leaves nothing to
## undo but the value. The graph closed by Back to scene is a change too,
## which undo opens again. What a step put back or made again opened or closed
## is that step's: the watch takes it as it finds it ([method _see_inputs]).
func _watch_inputs() -> void:
	var open := _open_inputs()
	var history := _document.history
	var opened := open & ~_seen_open
	var closed := (_seen_open & _OPEN_GRAPH) != 0 and (open & _OPEN_GRAPH) == 0
	var switched := (open & _seen_open & _OPEN_GRAPH) != 0 and blueprint.path != _seen_path
	var before := _seen_path
	_seen_open = open
	_seen_path = blueprint.path
	if opened == 0 and not closed and not switched: return
	if closed: history.record(XREHistory.Kind.VIEW, "Back to scene", _show_graph_view.bind(before), _hide_graph_view)
	elif switched: history.record(XREHistory.Kind.VIEW, "Open graph", _show_graph_view.bind(before), _show_graph_view.bind(blueprint.path))
	for bit: int in _OPEN_NAMES:
		if (opened & bit) == 0: continue
		if bit == _OPEN_GRAPH: history.record(XREHistory.Kind.VIEW, _OPEN_NAMES[bit], _hide_graph_view, _show_graph_view.bind(blueprint.path))
		else: history.record(XREHistory.Kind.VIEW, _OPEN_NAMES[bit], _close_input.bind(bit), _reopen_input(bit))


## Takes what of the graph is open now as seen: at the start, and as soon as a step of the headset's history was put back or made again.
func _see_inputs() -> void:
	_seen_open = _open_inputs()
	_seen_path = blueprint.path


## Closes the graph's input [param bit] if it is open, for undo: what it was editing stays as it was.
func _close_input(bit: int) -> bool:
	if (_open_inputs() & bit) == 0: return false
	match bit:
		_OPEN_PARAMETERS: close_parameters()
		_OPEN_MENU: close_block_palette()
		_OPEN_TOKENS: _dismiss_window(XREBlueprintTokensTab, true)
		_OPEN_VECTOR: _end_vector(false)
		_OPEN_COLOR: _end_color(false)
		_OPEN_KEYBOARD:
			_keyboard.close()
			_token_edit = {}
		_OPEN_PETALS:
			cancel_connection()
			_petals.close()
		_OPEN_CHOICE:
			_choice.close()
			if _choice_menu: _end_block_offer()
		_OPEN_WIRE:
			# The menu of a wire let go is that wire's (D-051).
			if _menu_at_point and is_block_palette_shown(): close_block_palette()
			cancel_connection()
		_OPEN_TARGET: _target_pick = -1
	return true


## What opens the graph's input [param bit] again for redo, as it is open now; an empty
## callable for an input that can't be opened again so: a wire, petals, a choice.
func _reopen_input(bit: int) -> Callable:
	match bit:
		_OPEN_PARAMETERS: return _reopen_parameters.bind(_parameters_block)
		_OPEN_MENU: return Callable() if _menu_at_point else _reopen_menu.bind(_menu_card, not _menu_wire.is_empty())
		_OPEN_TOKENS: return _reopen_tokens
		_OPEN_VECTOR, _OPEN_COLOR: return _reopen_value.bind(_value_edit.duplicate())
		# A token's own keyboard; the keypad of a figure of the Vector or Color window goes with the window.
		_OPEN_KEYBOARD: return _reopen_keyboard.bind(_token_edit.duplicate()) if _token_edit.size() == 4 and _token_edit.has("block") else Callable()
		_OPEN_TARGET: return _reopen_target.bind(_target_pick)
	return Callable()


func _reopen_parameters(block: int) -> bool:
	if not _workspace.visible or is_parameters_shown() or not canvas.has_block(block): return false
	select_block(block)
	return is_parameters_shown()


func _reopen_menu(card: int, wired: bool) -> bool:
	if not _workspace.visible or is_block_palette_shown(): return false
	# The palette itself, not the suggestions before it (D-093).
	if wired and canvas.has_block(card): _show_block_palette(card, false)
	else: open_block_menu()
	return is_block_palette_shown() or (_choice_menu and _choice.is_open())


func _reopen_tokens() -> bool:
	if not _workspace.visible or XREBlueprintTokensTab in _open_windows: return false
	_request_window(XREBlueprintTokensTab, _tray_pose())
	return true


## Opens the Vector or Color window again for the token [param edit] was editing, at its value then.
func _reopen_value(edit: Dictionary) -> bool:
	if not _workspace.visible or not _value_edit.is_empty() or not _token_exists(edit): return false
	if edit.has("color"): _open_color(edit["block"], edit["key"], edit["box"], edit["start"])
	else: _open_vector(edit["block"], edit["key"], edit["box"], edit["start"])
	return true


func _reopen_keyboard(edit: Dictionary) -> bool:
	if not _workspace.visible or _keyboard.is_shown() or not _token_exists(edit): return false
	_open_token_keyboard(edit["block"], edit["key"], edit["box"], edit["value"])
	return _keyboard.is_shown()


func _reopen_target(block: int) -> bool:
	if _target_pick >= 0 or blueprint.graph.find_node(block).is_empty(): return false
	_target_pick = block
	return true


## Whether the block or the variable's box of the token [param edit] names is in the graph.
func _token_exists(edit: Dictionary) -> bool:
	var box := str(edit.get("box", ""))
	if not box.is_empty(): return not blueprint.graph.find_variable(box).is_empty()
	return not blueprint.graph.find_node(int(edit.get("block", -1))).is_empty()


## Shows the graph saved at [param path] (empty: the untitled one open now), for undo and redo.
func _show_graph_view(path: String) -> bool:
	if _workspace.visible and blueprint.path == path: return false
	if path.is_empty() or path == blueprint.path:
		if _workspace.visible or path != blueprint.path: return false
		show_graph()
		return true
	return open_graph(path)


## Back to the scene from the graph, for undo and redo.
func _hide_graph_view() -> bool:
	if not _workspace.visible: return false
	close_graph()
	return not _workspace.visible


## Puts one of the graph's own windows — the toolbar and those it leads, the
## keyboard — back where [param xform] says, for undo and redo of its move.
func _place_window(node: Node3D, xform: Transform3D) -> bool:
	if not is_instance_valid(node) or not node.is_visible_in_tree() or node.global_transform.is_equal_approx(xform): return false
	node.global_transform = xform
	return true


## Whether the delete button went down this frame and nothing took it yet:
## it acts on what a ray is on — a token, a link, a knot, a box —, the right
## hand's first, whichever hand the button is on (X on the left, D-087).
func _deletes_now() -> bool:
	return not _delete_consumed and _rig.is_action_pressed(_document.features, XREFeatureSettings.DELETE)


## Takes this frame's press of the delete button: the selected block stays, and
## the manipulator, after the graph, doesn't delete the scene's selection with it.
func _consume_delete() -> void:
	_delete_consumed = true
	_rig.consume_action(XREFeatureSettings.DELETE)


## Catalog scanning is event-driven, never part of the frame loop.
func refresh_catalog() -> void:
	_catalog.clear()
	_collect_graphs("res://")
	_catalog.sort()
	_refresh_markers()
	_selection_changed()
	changed.emit()


## Cached project sources for the catalog; refreshing is explicit or event-driven.
func graph_paths() -> PackedStringArray:
	return _catalog


## Creates source without changing a scene node; its host is chosen explicitly later.
func create_unassigned() -> bool:
	if _root == null: return false
	_unsaved_host = null
	_finish_holds()
	if not save_draft(): return false
	blueprint.perform(blueprint.new_graph, &"vr_panel")
	blueprint.set_scene_root(_root)
	var state := blueprint.graph.snapshot()
	state["host_path"] = NodePath("")
	blueprint.perform(blueprint.commit.bind("Clear Host", state), &"vr_panel")
	if not blueprint.perform(blueprint.save_graph.bind(_new_path(_root)), &"vr_panel"): return false
	show_graph()
	_message("New graph. Choose host before Build & Attach.")
	return true


## Gives [param copy], which [method XREDocument.duplicate_nodes] just put in
## the scene as a copy of [param original], its own Blueprints, with
## [constant XREFeatureSettings.COPY_BLUEPRINT] at [constant XREFeatureSettings.OWN]
## (D-122): each host in it gets a copy of its graph beside the scene
## ([method _new_path]), with the copy as its host, and of its generated
## script, which it takes with its values kept. The files stay if the copy is
## undone, as a graph made for an object does. At Shared, the default, a copy
## keeps its original's graph and script, as on the desktop.
func prepare_copy(copy: Node, original: Node) -> void:
	if _document.features.get_value(XREFeatureSettings.COPY_BLUEPRINT) != XREFeatureSettings.OWN or _root == null: return
	var hosts: Array[Node] = [copy]
	hosts.append_array(copy.find_children("*", "", true, false))
	var made := false
	for host: Node in hosts:
		var source := str(host.get_meta(&"_xre_blueprint", ""))
		if source.is_empty() or not ResourceLoader.exists(source): continue
		var graph := ResourceLoader.load(source, "", ResourceLoader.CACHE_MODE_IGNORE) as XREBlueprintGraph
		if graph == null: continue
		var path := _new_path(host)
		graph.host_path = _root.get_path_to(host)
		if ResourceSaver.save(graph, path) != OK:
			_message("Could not save a graph for the copy: %s." % path)
			continue
		var own_script: Script = null
		var generated := source.get_basename() + ".generated.gd"
		var script := host.get_script() as Script
		if script != null and script.resource_path == generated:
			var output := path.get_basename() + ".generated.gd"
			var file := FileAccess.open(output, FileAccess.WRITE)
			if file != null:
				file.store_string(FileAccess.get_file_as_string(generated))
				file.close()
				own_script = ResourceLoader.load(output, "GDScript", ResourceLoader.CACHE_MODE_REPLACE) as Script
		if Engine.is_editor_hint():
			EditorInterface.get_resource_filesystem().update_file(path)
			if own_script != null: EditorInterface.get_resource_filesystem().update_file(own_script.resource_path)
		host.set_meta(&"_xre_blueprint", path)
		if own_script != null: _take_script(host, own_script)
		made = true
	if made:
		_refresh_markers()
		_message("The copy of %s has a Blueprint of its own." % original.name)


## Gives [param host] [param script] in place of its own, the values of its
## script variables kept: a copy's script is the same code (D-122).
static func _take_script(host: Node, script: Script) -> void:
	var values: Dictionary[StringName, Variant] = {}
	for property: Dictionary in host.get_property_list():
		if int(property["usage"]) & PROPERTY_USAGE_SCRIPT_VARIABLE: values[StringName(property["name"])] = host.get(property["name"])
	host.set_script(script)
	for name: StringName in values: host.set(name, values[name])


## Finds source metadata or a legacy generated script's adjacent .tres.
static func source_path(node: Node) -> String:
	if not is_instance_valid(node): return ""
	var saved: String = str(node.get_meta(&"_xre_blueprint", ""))
	if not saved.is_empty(): return saved
	var script := node.get_script() as Script
	if script != null and script.resource_path.ends_with(".generated.gd") and script.source_code.begins_with(XREBlueprintCompiler.HEADER):
		return script.resource_path.trim_suffix(".generated.gd") + ".tres"
	return ""


## Resolves the selected object's existing host before offering creation.
func open_selected() -> void:
	var selected := _document.get_selection()
	if selected.size() != 1:
		_message("Select exactly one scene node.")
		return
	var host := related_host(selected[0])
	if host != null: open_graph(source_path(host))
	else: create_for(selected[0])


## Adds a Logic child through the scene document if the chosen node has a script.
func create_for(node: Node) -> bool:
	if _root == null or not is_instance_valid(node) or not (node == _root or _root.is_ancestor_of(node)): return false
	_finish_holds()
	if not save_draft(): return false
	_unsaved_host = null
	var host := node
	if node.get_script() != null:
		host = Node.new()
		host.name = "Logic"
		_document.add_node(host, node, XREDocument.Source.PANEL)
	blueprint.perform(blueprint.new_graph, &"vr_panel")
	blueprint.set_scene_root(_root)
	if not blueprint.perform(blueprint.set_host_node.bind(host), &"vr_panel"): return false
	var path := _new_path(host)
	if not blueprint.perform(blueprint.save_graph.bind(path), &"vr_panel"):
		_message(blueprint.last_error)
		return false
	if not _document.assign_blueprint(host, path, null, XREDocument.Source.PANEL):
		_message("Could not assign Blueprint to this scene node.")
		return false
	_refresh_markers()
	show_graph()
	_message("Created " + path.get_file() + ". Build & Attach enables its behavior.")
	return true


## Incomplete source edits survive closing and switching; generated code is built separately.
func save_draft() -> bool:
	if is_instance_valid(parameters) and parameters.is_inside_tree(): parameters.flush_parameters()
	if not blueprint.is_dirty(): return true
	if blueprint.path.is_empty(): return blueprint.save_recovery()
	var success: bool = blueprint.perform(blueprint.save_graph.bind(blueprint.path), &"vr_panel")
	if not success: _message(blueprint.last_error)
	return success


## Saves the previous draft and opens this source in the shared document.
func open_graph(path: String) -> bool:
	_finish_holds()
	if blueprint.path != path:
		if not save_draft(): return false
		_unsaved_host = null
		if not blueprint.perform(blueprint.open_graph.bind(path), &"vr_panel"):
			_message(blueprint.last_error)
			return false
	show_graph()
	_message("Opened " + path.get_file())
	return true


## In the graph, selecting a scene object by pointing at it opens its graph (D-063): the one of
## its host, or a new one for it, written to disk only once it is changed
## ([method _save_new_graph]). An object with a script of its own keeps the
## graph that is open: its Blueprint needs a Logic child, which Create Blueprint adds.
func _follow_selection() -> void:
	if not _workspace.visible or _root == null: return
	var nodes := _document.get_selection()
	if nodes.size() != 1 or not is_instance_valid(nodes[0]): return
	var node := nodes[0]
	if not (node == _root or _root.is_ancestor_of(node)): return
	var host := related_host(node)
	if host != null:
		if host != blueprint.get_host() or source_path(host) != blueprint.path: open_graph(source_path(host))
		return
	if node == blueprint.get_host(): return
	if node.get_script() != null:
		_message("%s has a script of its own: Create Blueprint adds a Logic child for its graph." % node.name)
		return
	_finish_holds()
	if not save_draft(): return
	blueprint.perform(blueprint.new_graph, &"vr_panel")
	blueprint.set_scene_root(_root)
	if not blueprint.perform(blueprint.set_host_node.bind(node), &"vr_panel"):
		_message(blueprint.last_error)
		return
	show_graph()
	blueprint.mark_saved()
	_unsaved_host = weakref(node)
	_message("%s has no Blueprint yet: this one is saved with its first change." % node.name)


## The first change of a new graph opened for a selected object (D-063):
## the graph is saved beside the scene and assigned to the object.
func _save_new_graph() -> void:
	var host := _unsaved_host.get_ref() as Node if _unsaved_host != null else null
	if host == null or not blueprint.path.is_empty() or not blueprint.is_dirty(): return
	_unsaved_host = null
	if host != blueprint.get_host() or not host.is_inside_tree(): return
	var path := _new_path(host)
	if not blueprint.perform(blueprint.save_graph.bind(path), &"vr_panel"):
		_message(blueprint.last_error)
		return
	if not _document.assign_blueprint(host, path, null, XREDocument.Source.PANEL):
		_message("Could not assign Blueprint to this scene node.")
		return
	_refresh_markers()
	_message("Saved " + path.get_file() + ". Build & Attach enables its behavior.")


## Reopening focuses one shared workspace rather than copying its document.
func show_graph() -> void:
	cancel_connection()
	_target_pick = -1
	_selected = -1
	_selected_blocks.clear()
	canvas.center_graph(blueprint.graph)
	canvas.rebuild(blueprint.graph)
	var head := _rig.camera.global_position
	var orientation := XREPanels.facing(head - _rig.camera.global_basis.z, head, Vector3.UP)
	var ui_pose := Transform3D(orientation, head - orientation.z - Vector3.UP * 0.12)
	if not blueprint.graph.vr_placed:
		var state := blueprint.graph.snapshot()
		state["vr_placed"] = true
		state["vr_workspace"] = ui_pose
		state["vr_center"] = canvas.get_graph_center()
		blueprint.perform(blueprint.commit.bind("Place VR Graph", state), &"vr_graph")
	_workspace.global_transform = blueprint.graph.vr_workspace
	canvas.face_user(head)
	_floating_ui.global_transform = ui_pose
	_keyboard.close()
	close_block_palette()
	close_parameters()
	_workspace.show()
	_floating_ui.show()
	_dimmer.show()
	_set_ui_overlay(true)
	parameters.select_block(-1)
	_update_tray()
	_update_selection_fan()
	_update_badge()
	_schedule_rebuild()
	changed.emit()


## Closes only the view, leaving source and scene assignments intact.
func close_graph() -> void:
	for pointer: Pointer in _pointers:
		if pointer.held != null: _finish_hold(pointer, true)
	_cancel_bends()
	if not save_draft(): return
	for pointer: Pointer in _pointers: _leave(pointer)
	cancel_connection()
	_target_pick = -1
	# The Vector and Color windows put their values back; a pipette goes back for its controller (D-065).
	_close_inputs()
	_keyboard.close()
	close_block_palette()
	close_parameters()
	_dismiss_window(XREBlueprintTokensTab, true)
	_token_editor.close()
	_petals.close()
	_choice.close()
	_workspace.hide()
	_floating_ui.hide()
	_dimmer.hide()
	_set_ui_overlay(false)
	_update_badge()
	_message("Back to scene. Blueprint draft saved.")


## Whether the spatial workspace is visible.
func is_open() -> bool:
	return _workspace.visible


## Removes script/source assignment together while retaining project files.
func detach_selected() -> bool:
	var selected := _document.get_selection()
	if selected.size() != 1: return false
	var host := related_host(selected[0])
	if host == null: return false
	if not _document.assign_blueprint(host, "", null, XREDocument.Source.PANEL):
		_message("The node has an unrelated script; it was kept.")
		return false
	_refresh_markers()
	_selection_changed()
	_message("Blueprint detached. Its files remain in the catalog.")
	return true


## The badge's trash (D-085): the open graph's object loses its Blueprint — its
## script and source link, as one scene undo step, as Detach does — and the
## graph closes. The graph's file stays in the catalog.
func delete_blueprint() -> bool:
	if not _workspace.visible: return false
	var host := blueprint.get_host()
	var assigned := host != null and not blueprint.path.is_empty() and source_path(host) == blueprint.path
	if assigned and not _document.assign_blueprint(host, "", null, XREDocument.Source.PANEL):
		_message("The node has an unrelated script; it was kept.")
		return false
	# A new graph not yet saved (D-063) is just left.
	_unsaved_host = null
	close_graph()
	if _workspace.visible: return false
	_refresh_markers()
	_selection_changed()
	_message("Blueprint deleted. Its file remains in the catalog." if assigned else "Blueprint closed: no object had it.")
	return true


## Undo and redo from the Blueprints tab (D-085): the headset's history, as A
## and B, the graph's edits and what was opened, in turn (D-087).
func undo() -> void:
	_document.undo(XREDocument.Source.PANEL)


func redo() -> void:
	_document.redo(XREDocument.Source.PANEL)


## Drops the wire being drawn and the Target being picked.
func cancel_pick() -> void:
	cancel_connection()
	_target_pick = -1


## Opens the graph's variables in the Parameters window.
func show_variables() -> void:
	parameters.show_variables()
	_show_parameters()


## Opens the host picker in the Parameters window.
func show_host_picker() -> void:
	parameters.show_host_picker()
	_show_parameters()


## Opens or closes the Tokens window.
func toggle_tokens() -> void:
	if XREBlueprintTokensTab in _open_windows: _dismiss_window(XREBlueprintTokensTab, true)
	else: _request_window(XREBlueprintTokensTab, _tray_pose())


## Prevents play from silently using stale code after an invalid graph edit.
func prepare_play() -> bool:
	if blueprint.path.is_empty() or not blueprint.scene_context_active(): return true
	var host := blueprint.get_host()
	if host == null or source_path(host) != blueprint.path: return true
	if _keyboard.is_shown():
		_message("Apply or close text input before Play.")
		return false
	parameters.flush_parameters()
	if not parameters.validate_active_target(): return false
	if _built_path == blueprint.path and _built_state == blueprint.graph.snapshot() and _built_host != null and _built_host.get_ref() == host and host.get_script() == _built_script:
		var errors := blueprint.validate_scene()
		if errors.is_empty(): return true
		_message("\n".join(errors))
		return false
	return build_and_attach()


## Validates the visible draft, builds GDScript and assigns through the scene document.
func build_and_attach() -> bool:
	if _keyboard.is_shown():
		_message("Apply or close text input before building.")
		return false
	if blueprint.get_host() == null:
		_message(blueprint.scene_context_message() if not blueprint.scene_context_active() else "Choose host before Build & Attach.")
		return false
	if not parameters.validate_active_target():
		_message("Correct the visible Target before building.")
		return false
	if not blueprint.perform(blueprint.build, &"vr_panel"):
		_message(blueprint.last_error)
		return false
	var script := ResourceLoader.load(blueprint.script_path(), "GDScript", ResourceLoader.CACHE_MODE_REPLACE) as Script
	if script == null or not _document.assign_blueprint(blueprint.get_host(), blueprint.path, script, XREDocument.Source.PANEL):
		_message("Choose an empty Blueprint host in its own scene.")
		return false
	_refresh_markers()
	_built_state = blueprint.graph.snapshot()
	_built_path = blueprint.path
	_built_host = weakref(blueprint.get_host())
	_built_script = script
	_message("Built and attached. Y runs the scene.")
	return true


## Adds a block of a native kind or a preset beside the selected card through graph undo history.
func add_block(kind: String) -> void:
	var block := XREBlueprintGraph.make_node(0, kind, Vector2.ZERO)
	if block.is_empty(): return
	_menu_card = _selected
	_menu_wire = {}
	_menu_at_point = false
	_add_from_menu({"id": "kind:" + kind, "title": XREBlueprintGraph.title(block), "block": block, "target": null})


## Opens the block menu from the Blueprints tab or the launcher (D-051): no
## pin, the selected object first, the block beside the selected card.
func open_block_menu() -> void:
	if not _workspace.visible: show_graph()
	cancel_connection()
	_menu_card = _selected
	_menu_wire = {}
	_menu_at_point = false
	block_menu.open(_menu_contexts(-1), blueprint.get_host(), blueprint.graph)
	var head := _rig.camera.global_position
	var point := _ahead_point()
	_offer_blocks(point, _request_window.bind(XREBlueprintPaletteTab, Transform3D(XREPanels.facing(point, head, _rig.global_basis.y), point)), false)


## In front of the head, level, as far as a window opens and a little below the eyes: global.
func _ahead_point() -> Vector3:
	var forward := -_rig.camera.global_basis.z
	forward.y = 0.0
	return _rig.camera.global_position + (forward.normalized() if not forward.is_zero_approx() else Vector3.FORWARD) * XREPanels.WINDOW_DISTANCE - Vector3.UP * XREPanels.WINDOW_DROP


## Adds [param action]'s block where the menu was opened, wired to its pin, as
## one undo step. Pinned to a hand, the menu stays: the next block follows
## from the new one's execution output, so that a chain is added in a row.
func _add_from_menu(action: Dictionary, point: Variant = null) -> void:
	if action.has("variable"):
		_ask_new_variable(action, point)
		return
	var place := _menu_place(point)
	var position := Vector2(place.x, place.y)
	var block: Dictionary = (action["block"] as Dictionary).duplicate(true)
	block["vr_depth"] = place.z
	# From a box (D-063) the block comes unwired; the box is wired into its first fitting input then.
	var box := str(_menu_wire.get("box", ""))
	# Where the block was picked is in the operation's name (D-093): the log tells the palette's variants apart.
	var title: String = ADD_TITLES.get(str(action.get("origin", "")), "Add Block")
	var id: int = blueprint.perform(blueprint.insert_block.bind(block, position, _menu_wire if box.is_empty() else {}, action.get("target") as Node, title), &"vr_panel")
	if id < 0:
		_message(blueprint.last_error)
		return
	if _menu_at_point: cancel_connection()
	if not box.is_empty():
		_menu_wire = {}
		var port := _box_input(id, box)
		if port >= 0: _wire_box_to_port(box, id, port)
	select_block(id, false)
	_message("Added %s." % action["title"])
	# Pinned to a hand, the menu stays for the next block.
	_dismiss_window(XREBlueprintPaletteTab, false)
	if is_block_palette_shown():
		_menu_card = id
		_menu_at_point = false
		var pin := _exec_pin(id)
		_menu_wire = {"from": id, "from_port": pin["port"]} if not pin.is_empty() else {}
		block_menu.open(_menu_contexts(id), blueprint.get_host(), blueprint.graph, pin)


## Where a block the menu adds goes: graph X and Y with its VR depth. At
## [param point] (workspace), at the point a wire was let go, beside the
## menu's card and as deep — to the right of an output, to the left of an
## input —, or, with no card, as from the badge's plus, where the menu is
## (D-090): its block stands in the menu's place once it closes. Below the
## cards there, as deep as the block within [constant MENU_DEPTH_GAP].
func _menu_place(point: Variant) -> Vector3:
	if point is Vector3: return _graph_place(point)
	if _menu_at_point: return _graph_place(_menu_point)
	var source := blueprint.graph.find_node(_menu_card)
	var start: Vector3
	# From the ring or the suggestions, closed by now, with no card: where they were (D-093).
	if source.is_empty() and _offered_at is Vector3: start = _graph_place(canvas.to_local(_offered_at as Vector3))
	# Added with no menu, as by [method add_block]: at the end of the row of blocks, as before.
	elif source.is_empty() and _menu_window() == null: start = Vector3(80.0 + 320.0 * blueprint.graph.nodes.size(), 100.0, 0.0)
	elif source.is_empty(): start = _graph_place(_menu_free_point())
	else:
		var beside: Vector2 = source["position"] + Vector2(-320 if _menu_wire.has("to") else 320, 0)
		start = Vector3(beside.x, beside.y, float(source.get("vr_depth", 0.0)))
	return _free_place(start)


## [param start] — graph X and Y with a VR depth —, or the first place from it
## no card is on: down a column of free places, then the next column on.
func _free_place(start: Vector3) -> Vector3:
	var place := start
	for attempt: int in 24:
		place = start + Vector3(320.0 * floorf(attempt / 6.0), 160.0 * (attempt % 6), 0.0)
		var free := true
		for block: Dictionary in blueprint.graph.nodes:
			var offset: Vector2 = block["position"] - Vector2(place.x, place.y)
			if absf(offset.x) < 260 and absf(offset.y) < 140 and absf(float(block.get("vr_depth", 0.0)) - place.z) < MENU_DEPTH_GAP: free = false
		if free: break
	return place


## Graph X and Y of workspace point [param point], with its depth.
func _graph_place(point: Vector3) -> Vector3:
	var at := canvas.block_position(point)
	return Vector3(at.x, at.y, point.z)


## Where a block the menu adds with no card to go beside stands, in the
## workspace: a little behind the menu's window, or, pinned to a hand, before
## the head where the window opens.
func _menu_free_point() -> Vector3:
	var head := _rig.camera.global_position
	var window := _menu_window() as XREPanelWindow
	var at := _ahead_point()
	if window != null and not window.is_pinned(): at = window.global_position
	return canvas.to_local(at + (at - head).normalized() * MENU_BEHIND)


## The context objects of the menu (D-051): the selected scene object, the
## target of card [param id], then the host; a pin's object class first.
func _menu_contexts(id: int, pin_context: Dictionary = {}) -> Array[Dictionary]:
	var contexts: Array[Dictionary] = []
	if not pin_context.is_empty(): contexts.append(pin_context)
	var nodes: Array[Node] = []
	var selection := _document.get_selection()
	if selection.size() == 1: nodes.append(selection[0])
	if id >= 0: nodes.append(blueprint.target_node(id))
	nodes.append(blueprint.get_host())
	var scene := blueprint.scene_nodes()
	var seen: Array[Node] = []
	for node: Node in nodes:
		if node == null or seen.has(node) or not scene.has(node): continue
		seen.append(node)
		contexts.append({"label": str(node.name), "node": node})
	return contexts


## The pin of the first execution output of block [param id], or empty.
func _exec_pin(id: int) -> Dictionary:
	var block := blueprint.graph.find_node(id)
	if block.is_empty(): return {}
	var outputs := blueprint.graph.ports(block, false)
	for index: int in outputs.size():
		if outputs[index][1] == XREBlueprintGraph.EXEC:
			return {"type": XREBlueprintGraph.EXEC, "output": true, "port": index, "label": "%s ▸ %s · exec" % [XREBlueprintGraph.title(block), outputs[index][0]], "key": XREBlueprintStats.key_of(block)}
	return {}


## The menu for a wire let go in empty space at [param point] (workspace): it
## lists the blocks that can take the wire and joins the one chosen to it.
func _open_menu_for_wire(point: Vector3) -> void:
	var block := blueprint.graph.find_node(_pending_id)
	if block.is_empty(): return
	var spec: Array = blueprint.graph.ports(block, _pending_input)[_pending_port]
	var pin := {"type": spec[1], "output": not _pending_input, "port": _pending_port, "label": "%s ▸ %s · %s" % [XREBlueprintGraph.title(block), spec[0], _type_name(spec[1])],
			"key": XREBlueprintStats.key_of(block)}
	var types: Variant = _input_value_types(block, _pending_port) if _pending_input else null
	if types is Array: pin["value_types"] = types
	var pin_context := {}
	if spec[1] == XREBlueprintGraph.OBJECT and block["kind"] == "signal" and not _pending_input:
		var arguments: Array = block.get("arguments", [])
		if _pending_port - 1 >= 0 and _pending_port - 1 < arguments.size():
			var argument: Dictionary = arguments[_pending_port - 1]
			var cls := str(argument.get("class_name", ""))
			pin_context = {"label": "%s · %s" % [argument["name"], cls if not cls.is_empty() else "Object"], "class": cls if not cls.is_empty() else "Node"}
	_menu_card = _pending_id
	_menu_wire = {"to": _pending_id, "to_port": _pending_port} if _pending_input else {"from": _pending_id, "from_port": _pending_port}
	_menu_point = point
	_menu_at_point = true
	block_menu.open(_menu_contexts(_pending_id, pin_context), blueprint.get_host(), blueprint.graph, pin)
	_offer_blocks(canvas.to_global(point), _request_menu_at.bind(point), true)


## The Variant types a new variable may have to go into input [param port]
## of [param block], or null where any value fits, as Print's: the port's own
## (D-079); for an operator's operand, every type of a new variable the
## operator works on with its other operand (D-080) — Add takes an int as
## well as a float, and gives an int for two ints.
func _input_value_types(block: Dictionary, port: int) -> Variant:
	var spec: Array = blueprint.graph.ports(block, true)[port]
	var key: String = spec[2] if spec.size() > 2 else ""
	if XREBlueprintGraph.is_operator(block) and key in ["a", "b"]:
		return blueprint.graph.operand_types(block, key, XREBlueprintActions.NEW_VARIABLES.map(func(value: Variant) -> int: return typeof(value)))
	var own := XREBlueprintGraph.variant_type(spec[1])
	return [own] if own != TYPE_NIL else null


## The menu for a wire from the box of a variable let go in empty space at
## [param point] (D-063): the blocks that take the variable's value; the one
## chosen gets the box wired into its first input of that type.
func _open_menu_for_box(point: Vector3) -> void:
	var variable := blueprint.graph.find_variable(_link_box)
	if variable.is_empty(): return
	var type := XREBlueprintGraph.port_type(XREBlueprintGraph.variable_type(variable))
	_menu_card = -1
	_menu_wire = {"box": _link_box}
	_menu_point = point
	_menu_at_point = true
	block_menu.open(_menu_contexts(-1), blueprint.get_host(), blueprint.graph, {"type": type, "output": true, "label": "%s · %s" % [_link_box, _type_name(type)], "key": "get_variable"})
	_offer_blocks(canvas.to_global(point), _request_menu_at.bind(point), true)


## The data input of block [param id] that the box of [param box] fits first, or -1.
func _box_input(id: int, box: String) -> int:
	var block := blueprint.graph.find_node(id)
	var variable := blueprint.graph.find_variable(box)
	if block.is_empty() or variable.is_empty(): return -1
	var type := XREBlueprintGraph.port_type(XREBlueprintGraph.variable_type(variable))
	var inputs := blueprint.graph.ports(block, true)
	for exact: bool in [true, false]:
		for index: int in inputs.size():
			var port_type: int = inputs[index][1]
			if port_type == XREBlueprintGraph.EXEC: continue
			if port_type == type or (not exact and (port_type == XREBlueprintGraph.VALUE or type == XREBlueprintGraph.VALUE)): return index
	return -1


## Opens the block menu's window beside workspace point [param point], toward the head.
func _request_menu_at(point: Vector3) -> void:
	var world := canvas.global_transform * point
	var head := _rig.camera.global_position
	var away := (world - head).normalized()
	var at := world + XREPanels.facing(world, head, _rig.global_basis.y).x * (XREPanels.WINDOW_SIZE.x * XREPanels.WINDOW_PIXEL_SIZE * 0.5 + 0.05) - away * PARAMETERS_LIFT
	_request_window(XREBlueprintPaletteTab, Transform3D(XREPanels.facing(at, head, _rig.global_basis.y), at))


static func _type_name(type: int) -> String:
	return ["exec", "Variant", "bool", "int", "float", "String", "Vector2", "Vector3", "Object", "Color"][type]


## The window that shows the block menu, or null while it is closed.
func _menu_window() -> XREPanelSurface:
	if not is_block_palette_shown() or not block_menu.is_inside_tree(): return null
	return block_menu.get_viewport().get_parent() as XREPanelSurface


## A row pulled out of the menu: its block follows the ray of the hand that pulls it ([method _update_drag]).
func _drag_from_menu(action: Dictionary) -> void:
	var hand := _rig.right_hand if _rig.right_hand.trigger_held or not _rig.left_hand.trigger_held else _rig.left_hand
	var window := block_menu.get_viewport().get_parent() as Node3D if block_menu.is_inside_tree() else null
	_start_drag(action, hand, clampf(hand.global_position.distance_to(window.global_position) if window != null else 0.6, 0.3, 2.0))


## [param action]'s block follows the ray of [param hand], [param distance] along it, as a stand-in, until the trigger lets go.
## The stand-in is [param card], a card's look, or a plate with the block's title without one.
func _start_drag(action: Dictionary, hand: XREHand, distance: float, card: Node3D = null) -> void:
	_drag_action = action
	_drag_hand = hand
	_drag_distance = distance
	if is_instance_valid(_ghost): _ghost.queue_free()
	_ghost = Node3D.new()
	_ghost.name = "DraggedBlock"
	if card != null:
		_ghost.add_child(card)
	else:
		var quad := QuadMesh.new()
		quad.size = Vector2(XREBlueprintCanvas.CARD_WIDTH, 0.08)
		var face := XREBlueprintCanvas.material(Color(0.2, 0.25, 0.4, 0.7), true)
		_ghost.add_child(XRERig.create_vr_mesh(quad, face))
		var title := XREBlueprintCanvas.label(action["title"], 21)
		title.position.z = 0.001
		_ghost.add_child(title)
	_workspace.add_child(_ghost)
	_update_drag()


## Moves the pulled row's stand-in along its hand's ray; letting the trigger go adds the block there.
func _update_drag() -> void:
	if _drag_action.is_empty(): return
	if not is_instance_valid(_drag_hand) or not _drag_hand.get_has_tracking_data() or not _workspace.visible:
		_end_drag(false)
		return
	var point := _drag_hand.global_position - _drag_hand.global_basis.z.normalized() * _drag_distance
	_ghost.global_transform = Transform3D(XREPanels.facing(point, _rig.camera.global_position, Vector3.UP), point)
	if not _drag_hand.trigger_held: _end_drag(true)


func _end_drag(place: bool) -> void:
	var action := _drag_action
	if action.is_empty(): return
	_drag_action = {}
	var point := canvas.to_local(_ghost.global_position) if is_instance_valid(_ghost) else Vector3.ZERO
	var moved := _ghost.global_position.distance_to(_copy_start) if is_instance_valid(_ghost) else 0.0
	if is_instance_valid(_ghost): _ghost.queue_free()
	_ghost = null
	if place and action.get("origin", "") == "copy" and action.has("blocks"): _place_group_copy(action, point, moved < COPY_CLICK)
	elif place and action.get("origin", "") == "copy": _place_copy(action, point, moved < COPY_CLICK)
	elif place: _add_from_menu(action, point)


## The trigger on the copy button of card [param id] (D-093), the ray on it
## at [param point]: a copy of the block, without its wires, follows the ray of
## [param hand] until the trigger lets go ([method _place_copy]).
func _start_copy(id: int, hand: XREHand, point: Vector3) -> void:
	var block := blueprint.graph.find_node(id)
	if block.is_empty(): return
	if _selected_blocks.size() > 1 and _selected_blocks.has(id):
		_start_group_copy(id, hand, point, _selected_blocks)
		return
	# With its outer wires, one block goes the way of a group: wires are what it copies (D-121).
	if _document.features.get_value(XREFeatureSettings.COPY_OUTER_WIRES) == XREFeatureSettings.ON:
		_start_group_copy(id, hand, point, [id])
		return
	var copy := block.duplicate(true)
	copy.erase("id")
	copy.erase("position")
	_copy_source = id
	var distance := clampf(hand.global_position.distance_to(point), 0.3, 2.0)
	# Where the stand-in starts, as the drag puts it, before a trigger already let go ends it.
	_copy_start = hand.global_position - hand.global_basis.z.normalized() * distance
	# The stand-in looks as the card does (D-114).
	_start_drag({"id": "copy", "title": XREBlueprintGraph.title(block), "block": copy, "target": blueprint.target_node(id), "origin": "copy"}, hand, distance, canvas.stand_in(id))


## The trigger on the copy button of card [param id], one of [param chosen]
## (D-117): copies of them all and of the wires between them follow the ray
## of [param hand], the card's at the ray, until the trigger lets go
## ([method _place_group_copy]). An inline block (D-061) that feeds one of
## them is copied with it: it is drawn as part of the card. With
## [constant XREFeatureSettings.COPY_OUTER_WIRES] on, so are the data wires
## into them from blocks not copied (D-121); an execution output holds one
## wire, so those stay with the originals.
func _start_group_copy(id: int, hand: XREHand, point: Vector3, chosen: Array[int]) -> void:
	var graph := blueprint.graph
	var ids: Dictionary[int, bool] = {}
	for selected: int in chosen:
		if not graph.find_node(selected).is_empty(): ids[selected] = true
	var grown := true
	while grown:
		grown = false
		for edge: Dictionary in graph.edges:
			var from := int(edge["from"])
			if ids.has(int(edge["to"])) and not ids.has(from) and canvas.is_inline(graph.find_node(from)):
				ids[from] = true
				grown = true
	var blocks: Array[Dictionary] = []
	for block: Dictionary in graph.nodes:
		if ids.has(int(block["id"])): blocks.append(block.duplicate(true))
	var edges: Array[Dictionary] = []
	var outer: Array[Dictionary] = []
	var outer_wires := _document.features.get_value(XREFeatureSettings.COPY_OUTER_WIRES) == XREFeatureSettings.ON
	for edge: Dictionary in graph.edges:
		var inside := ids.has(int(edge["from"]))
		if inside and ids.has(int(edge["to"])): edges.append(edge.duplicate(true))
		elif outer_wires and not inside and ids.has(int(edge["to"])):
			var outputs := graph.ports(graph.find_node(int(edge["from"])), false)
			var port := int(edge["from_port"])
			if port < outputs.size() and (outputs[port] as Array)[1] != XREBlueprintGraph.EXEC: outer.append(edge.duplicate(true))
	_copy_source = id
	var distance := clampf(hand.global_position.distance_to(point), 0.3, 2.0)
	_copy_start = hand.global_position - hand.global_basis.z.normalized() * distance
	# The stand-ins keep the cards' places around the card at the ray.
	var stand_ins := Node3D.new()
	var center := canvas.get_block_position(id)
	var scale := canvas.global_basis.get_scale()
	for selected: int in chosen:
		var stand_in := canvas.stand_in(selected)
		if stand_in == null: continue
		stand_in.position += (canvas.get_block_position(selected) - center) * scale
		stand_ins.add_child(stand_in)
	var title := XREBlueprintGraph.title(graph.find_node(id)) if chosen.size() == 1 else "%d blocks" % chosen.size()
	_start_drag({"id": "copy", "title": title, "blocks": blocks, "edges": edges, "outer": outer, "single": chosen.size() == 1, "origin": "copy"}, hand, distance, stand_ins)


## Adds the copies of [param action]'s blocks and wires (D-117), the source
## card's at workspace point [param point], the others where they are around
## it; with [param beside], let go where they started, below the selection by
## its height: one undo step, Duplicate Blocks in the log. The copies are selected.
func _place_group_copy(action: Dictionary, point: Vector3, beside: bool) -> void:
	var source := blueprint.graph.find_node(_copy_source)
	if source.is_empty(): return
	var blocks: Array[Dictionary] = []
	blocks.assign(action["blocks"])
	var edges: Array[Dictionary] = []
	edges.assign(action["edges"])
	var offset := canvas.block_position(point) - (source["position"] as Vector2)
	var depth := point.z - float(source.get("vr_depth", 0.0))
	if beside:
		var top := INF
		var bottom := -INF
		for block: Dictionary in blocks:
			top = minf(top, (block["position"] as Vector2).y)
			bottom = maxf(bottom, (block["position"] as Vector2).y)
		offset = Vector2(0.0, bottom - top + 160.0)
		depth = 0.0
	var outer: Array[Dictionary] = []
	outer.assign(action.get("outer", []))
	var title := "Duplicate Block" if action.get("single", false) else "Duplicate Blocks"
	var ids: Array[int] = blueprint.perform(blueprint.paste_blocks.bind(blocks, edges, offset, depth, title, outer), &"vr_graph")
	if ids.is_empty():
		_message(blueprint.last_error)
		return
	var selected: Array[int] = []
	for index: int in blocks.size():
		if not canvas.is_inline(blocks[index]): selected.append(ids[index])
	select_block(-1)
	for id: int in selected: toggle_block(id)
	_message("Copied %s." % action["title"])


## Adds the copy of [param action] (D-093) at workspace point [param point], or
## with [param beside], let go where it started, below its block where no card
## is: one undo step, Duplicate Block in the log.
func _place_copy(action: Dictionary, point: Vector3, beside: bool) -> void:
	var block: Dictionary = (action["block"] as Dictionary).duplicate(true)
	var source := blueprint.graph.find_node(_copy_source)
	var position := canvas.block_position(point)
	block["vr_depth"] = point.z
	if beside and not source.is_empty():
		var below: Vector2 = source["position"] + Vector2(0, 160)
		var place := _free_place(Vector3(below.x, below.y, float(source.get("vr_depth", 0.0))))
		position = Vector2(place.x, place.y)
		block["vr_depth"] = place.z
	var id: int = blueprint.perform(blueprint.insert_block.bind(block, position, {}, action.get("target") as Node, "Duplicate Block"), &"vr_graph")
	if id < 0:
		_message(blueprint.last_error)
		return
	select_block(id, false)
	_message("Copied %s." % action["title"])


## Selects a graph block without replacing the editor's scene selection. Its
## parameters window opens beside it (D-043, D-044), or comes there from
## another block, or pulses if it is there already (D-046); with no block, -1,
## it closes, unless it is pinned to a hand. Without [param open_parameters]
## the window is left as it is: the plus opens only the block palette.
func select_block(id: int, open_parameters: bool = true) -> void:
	_selected = id
	_selected_blocks.clear()
	if id >= 0: _selected_blocks.append(id)
	canvas.select_block(id)
	parameters.select_block(id)
	if id >= 0:
		if open_parameters and parameters_needed(id): _show_parameters(id)
		elif open_parameters: _dismiss_window(XREBlueprintParametersTab, false)
	else: _dismiss_window(XREBlueprintParametersTab, false)
	changed.emit()


## Adds block [param id] to the selected blocks, or takes it out if it is
## selected (D-117). The parameters window is for one block: with several, it closes.
func toggle_block(id: int) -> void:
	var ids: Array[int] = _selected_blocks.duplicate()
	if ids.has(id): ids.erase(id)
	else: ids.append(id)
	if ids.size() <= 1:
		select_block(ids[0] if ids.size() == 1 else -1, false)
		return
	_selected_blocks = ids
	_selected = ids.back()
	canvas.select_blocks(ids)
	parameters.select_block(-1)
	_dismiss_window(XREBlueprintParametersTab, false)
	changed.emit()


## Selects the blocks of [param ids], the last of them last (D-117): one
## with its parameters window, as [method select_block] does; several with it closed.
func select_blocks(ids: Array[int]) -> void:
	if ids.size() <= 1:
		select_block(ids[0] if ids.size() == 1 else -1)
		return
	_selected_blocks = ids.duplicate()
	_selected = ids.back()
	canvas.select_blocks(ids)
	parameters.select_block(-1)
	_dismiss_window(XREBlueprintParametersTab, false)
	changed.emit()


## Whether the trigger sweeps a brush stroke over the cards (D-119), as it does over the scene.
func _brushes() -> bool:
	return _document.features.get_value(XREFeatureSettings.SELECT_AREA) == XREFeatureSettings.BRUSH


## Starts a brush stroke of [param pointer] on card [param id], if
## [method _brushes]: one that replaces the selection, from that card, or one
## that adds to it, the card left as the trigger made it.
func _begin_block_brush(pointer: Pointer, id: int, replace: bool) -> void:
	if not _brushes(): return
	pointer.brushing = true
	pointer.brush_replace = replace
	pointer.brush_start = -1 if replace else id
	pointer.brushed.clear()
	if replace: pointer.brushed.append(id)
	_show_brush(pointer)


## Adds card [param id], under the ray of the stroke's hand, to the stroke.
func _brush_block(pointer: Pointer, id: int) -> void:
	if id < 0 or id == pointer.brush_start or pointer.brushed.has(id): return
	if not pointer.brush_replace and _selected_blocks.has(id): return
	pointer.brushed.append(id)
	_show_brush(pointer)


## Frames the stroke's cards as selected ones, without selecting them yet:
## out of focus they keep their look, as selected cards do (D-117). A stroke
## that replaces the selection shows only what it crossed.
func _show_brush(pointer: Pointer) -> void:
	var ids: Array[int] = []
	if not pointer.brush_replace: ids.append_array(_selected_blocks)
	ids.append_array(pointer.brushed)
	canvas.select_blocks(ids)


## Selects the stroke of [param pointer], or adds it to the selection, as one selection.
func _end_block_brush(pointer: Pointer) -> void:
	var ids: Array[int] = []
	if not pointer.brush_replace: ids.append_array(_selected_blocks)
	for id: int in pointer.brushed:
		if not ids.has(id) and not blueprint.graph.find_node(id).is_empty(): ids.append(id)
	var changes := pointer.brush_replace or not pointer.brushed.is_empty()
	pointer.brushing = false
	pointer.brushed.clear()
	if changes: select_blocks(ids)
	else: canvas.select_blocks(_selected_blocks)


## Starts a selection box of [param pointer] on the graph's plane where its
## ray, from [param origin] along [param direction], meets it, with
## [constant XREFeatureSettings.SELECT_AREA] at [constant XREFeatureSettings.BOX]
## (D-120): one that replaces the selection, or adds to it while the other
## hand adds (D-117). The hand is the graph's until the trigger lets go.
func _begin_block_box(pointer: Pointer, origin: Vector3, direction: Vector3) -> bool:
	if _document.features.get_value(XREFeatureSettings.SELECT_AREA) != XREFeatureSettings.BOX: return false
	var point: Variant = _on_canvas_plane(origin, direction)
	if point == null: return false
	pointer.boxing = true
	pointer.box_replace = not _adds_blocks(pointer)
	pointer.box_from = point
	pointer.box_to = point
	pointer.hand.claim(self)
	_drag_block_box(pointer)
	return true


## Where the ray from [param origin] along [param direction] meets the graph's
## plane, in the canvas's space, or null if it doesn't, ahead.
func _on_canvas_plane(origin: Vector3, direction: Vector3) -> Variant:
	var plane := canvas.global_transform
	var normal := plane.basis.z.normalized()
	var facing := direction.dot(normal)
	if is_zero_approx(facing): return null
	var along := (plane.origin - origin).dot(normal) / facing
	if along <= 0.0: return null
	var local := plane.affine_inverse() * (origin + direction * along)
	return Vector2(local.x, local.y)


## Draws the box of [param pointer] to where the ray meets the graph's plane
## now; ends it when the trigger lets go, or cancels it when the hand is lost.
## False once it ended: the hand goes on as without it.
func _drag_block_box(pointer: Pointer) -> bool:
	var hand := pointer.hand
	if not hand.get_has_tracking_data() or not hand.is_free_for(self):
		_clear_block_box(pointer)
		return false
	if not hand.trigger_held or hand.grip_pressed:
		_end_block_box(pointer)
		return false
	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	var point: Variant = _on_canvas_plane(origin, direction)
	if point != null: pointer.box_to = point
	var rect := Rect2(pointer.box_from, Vector2.ZERO).expand(pointer.box_to)
	_box_lines.show_bounds(canvas.global_transform, AABB(Vector3(rect.position.x, rect.position.y, 0.0), Vector3(rect.size.x, rect.size.y, 0.0)))
	var end := canvas.to_global(Vector3(pointer.box_to.x, pointer.box_to.y, 0.0))
	hand.show_ray(origin.distance_to(end), true)
	return true


## Selects the cards in the box of [param pointer], or adds them, as one
## selection; a click in the graph's empty space lets go of the selected blocks.
func _end_block_box(pointer: Pointer) -> void:
	var rect := Rect2(pointer.box_from, Vector2.ZERO).expand(pointer.box_to)
	var replace := pointer.box_replace
	_clear_block_box(pointer)
	if rect.size.x < XREManipulator.BOX_CLICK and rect.size.y < XREManipulator.BOX_CLICK:
		if replace: select_block(-1)
		return
	var ids: Array[int] = []
	if not replace: ids.append_array(_selected_blocks)
	for id: int in canvas.blocks_in_rect(rect):
		if not ids.has(id): ids.append(id)
	select_blocks(ids)


func _clear_block_box(pointer: Pointer) -> void:
	pointer.boxing = false
	_box_lines.visible = false
	if pointer.hand.get_claimant() == self: pointer.hand.unclaim(self)


## Ends the stroke of [param pointer] without selecting anything.
func _cancel_block_brush(pointer: Pointer) -> void:
	pointer.brushing = false
	pointer.brushed.clear()
	canvas.select_blocks(_selected_blocks)


## The selected blocks, the last selected last (D-117).
func get_selected_blocks() -> Array[int]:
	return _selected_blocks.duplicate()


## How many blocks are selected, without a copy of them: for the selection's counter (D-118).
func get_selected_count() -> int:
	return _selected_blocks.size()


## Whether a hand holds its grip down in the graph's empty space, which makes
## the other hand add blocks to the selection (D-117).
func is_adding() -> bool:
	for pointer: Pointer in _pointers:
		if pointer.adding: return true
	return false


## Whether the trigger or the grip of [param pointer]'s hand adds blocks to
## the selection: the other hand's grip is held in empty space, with
## [constant XREFeatureSettings.SELECT_ADD] at [constant XREFeatureSettings.GRIP] (D-117).
func _adds_blocks(pointer: Pointer) -> bool:
	if _document.features.get_value(XREFeatureSettings.SELECT_ADD) != XREFeatureSettings.GRIP: return false
	for other: Pointer in _pointers:
		if other != pointer and other.adding: return true
	return false


## Closes the parameters window, pinned too, keeping what was typed in it; the block stays selected.
func close_parameters() -> void:
	_dismiss_window(XREBlueprintParametersTab, true)


## Whether the parameters window is open.
func is_parameters_shown() -> bool:
	return XREBlueprintParametersTab in _open_windows


## Closes the block palette, pinned too.
func close_block_palette() -> void:
	_dismiss_window(XREBlueprintPaletteTab, true)


## Whether the block palette is open.
func is_block_palette_shown() -> bool:
	return XREBlueprintPaletteTab in _open_windows


## The graph's window of tab class [param type] was closed, by its × or as the
## graph asked: what was typed in it is kept, and the keyboard typing into it closes.
func window_closed(type: GDScript) -> void:
	_open_windows.erase(type)
	if type == XREBlueprintVectorTab:
		# Closed but by Done, the vector is as it was (D-063): the arrows go with it.
		_end_vector(false)
		return
	if type == XREBlueprintColorTab:
		# So is the color (D-064): the globe goes with it.
		_end_color(false)
		return
	if type == XREBlueprintPaletteTab:
		# The menu of a wire let go closed without a block: the wire is taken back.
		if _menu_at_point and (_pending_id >= 0 or not _link_box.is_empty()): cancel_connection()
		_menu_wire = {}
		_menu_at_point = false
	if type != XREBlueprintParametersTab: return
	_parameters_block = -1
	if is_instance_valid(parameters) and parameters.is_inside_tree(): parameters.flush_parameters()
	var field := _keyboard_target.get_ref() as LineEdit if _keyboard_target != null else null
	if field != null and parameters.is_ancestor_of(field): _keyboard.close()


## Puts [param form] back off screen when the window that showed it is freed ([XREBlueprintFormTab]).
func take_back(form: Control) -> void:
	if is_instance_valid(_forms_home) and not _forms_home.is_queued_for_deletion() and form.get_parent() == null:
		_forms_home.add_child(form)


## Where the parameters window of block [param id] goes: beside the card, at
## its height, facing the head; on its left, or on its right if more cards are
## there to cover on the left. Without the card, to the right of where the
## graph's toolbar was (D-085), where the window was before D-044.
func parameters_pose(id: int) -> Transform3D:
	if not canvas.has_block(id):
		var point := _floating_ui.global_transform * Vector3(0.85, -0.05, 0.03)
		return Transform3D(XREPanels.facing(point, _rig.camera.global_position, _rig.global_basis.y), point)
	var card := canvas.global_transform * canvas.get_block_transform(id)
	var size := XREPanels.WINDOW_SIZE * XREPanels.WINDOW_PIXEL_SIZE
	var reach := XREBlueprintCanvas.CARD_WIDTH + PARAMETERS_GAP + size.x
	var inverse := card.affine_inverse()
	var left := 0
	var right := 0
	for block: Dictionary in blueprint.graph.nodes:
		if block["id"] == id or not canvas.has_block(block["id"]): continue
		var other := inverse * (canvas.global_transform * canvas.get_block_transform(block["id"])).origin
		if absf(other.y) > size.y * 0.5 or absf(other.x) > reach: continue
		if other.x < 0.0: left += 1
		else: right += 1
	_parameters_side = -1.0 if left <= right else 1.0
	return _beside(card, _parameters_side)


## Where the block palette of block [param id] goes: beside the card, on the
## side its parameters window isn't.
func palette_pose(id: int) -> Transform3D:
	var card := canvas.global_transform * canvas.get_block_transform(id)
	var side := -_parameters_side if is_parameters_shown() and _parameters_block == id else 1.0
	return _beside(card, side)


## A window's pose beside a card at [param card], on its [param side] (-1 left,
## 1 right), at its height, facing the head: nearer the head than the card and
## than the cards it covers, by [constant PARAMETERS_LIFT].
func _beside(card: Transform3D, side: float) -> Transform3D:
	var size := XREPanels.WINDOW_SIZE * XREPanels.WINDOW_PIXEL_SIZE
	var head := _rig.camera.global_position
	var up := _rig.global_basis.y.normalized()
	var across := card.basis.x.normalized()
	var point := card.origin + across * side * (XREBlueprintCanvas.CARD_WIDTH * 0.5 + PARAMETERS_GAP + size.x * 0.5)
	var distance := minf(head.distance_to(point), head.distance_to(card.origin))
	var inverse := card.affine_inverse()
	for block: Dictionary in blueprint.graph.nodes:
		if not canvas.has_block(block["id"]): continue
		var other := (canvas.global_transform * canvas.get_block_transform(block["id"])).origin
		var local := inverse * other
		# Cards whose centers are within the window and half a card around it, as seen beside the block.
		var from := XREBlueprintCanvas.CARD_WIDTH * 0.5 + PARAMETERS_GAP
		var along := local.x * side
		if along < from - XREBlueprintCanvas.CARD_WIDTH or along > from + size.x + XREBlueprintCanvas.CARD_WIDTH * 0.5 or absf(local.y) > size.y * 0.5 + 0.15: continue
		distance = minf(distance, head.distance_to(other) - XREBlueprintCanvas.CUBOID_DEPTH)
	point = head + (point - head).normalized() * maxf(distance - PARAMETERS_LIFT, 0.2)
	return Transform3D(XREPanels.facing(point, head, up), point)


## Asks for the graph's window of tab class [param type] at [param pose].
func _request_window(type: GDScript, pose: Transform3D) -> void:
	if not type in _open_windows: _open_windows.append(type)
	window_requested.emit(type, pose)


## Asks for the graph's window of tab class [param type] to close: [param always], or unless pinned.
func _dismiss_window(type: GDScript, always: bool) -> void:
	if not type in _open_windows: return
	# Without the panels (a test of the graph alone) the window just closes.
	if window_dismissed.get_connections().is_empty(): window_closed(type)
	else: window_dismissed.emit(type, always)


## Whether [param hand] holds a card or a window of the graph, or drags a wire's bend (D-081).
func is_holding(hand: XREHand) -> bool:
	for pointer: Pointer in _pointers:
		if pointer.hand == hand: return pointer.held != null or pointer.bend_edge >= 0
	return false


## Opens the parameters window beside block [param id] (-1: the selected one,
## or none); open there already, it pulses.
func _show_parameters(id: int = -1) -> void:
	if not _workspace.visible: return
	if id < 0: id = _selected
	if is_parameters_shown() and (id == _parameters_block or id < 0):
		window_pulse_requested.emit(XREBlueprintParametersTab)
		return
	_parameters_block = id
	_request_window(XREBlueprintParametersTab, parameters_pose(id))


## Whether input [param port] of block [param id] is the one Target of an
## archetypes' Set (D-102): a Set Property's Target, which a box's wire turns
## into a Set Variable of the box.
func _sets_target(id: int, port: int) -> bool:
	var block := blueprint.graph.find_node(id)
	return canvas.get_style() == XREFeatureSettings.ARCHETYPES and block.get("kind") == "set_property" and port == XREBlueprintGraph.target_port(block)


## Whether the Variable wire being drawn is an archetypes' Set Variable's
## (D-102): let go on a scene object, it turns the Set into a Set Property of it.
func _variable_set_link() -> bool:
	if _link_kind != XREBlueprintCanvas.VARIABLE or _link_block < 0 or canvas.get_style() != XREFeatureSettings.ARCHETYPES: return false
	return blueprint.graph.find_node(_link_block).get("kind") == "set_variable"


## The one Set of archetypes (D-102): Set [param id], writing a property,
## writes [param variable] instead, under the hood a Set Variable. Its
## execution wires stay; a wire into its Value stays if it fits the variable,
## else the Value gets the variable's value; its Target and its wires to the
## scene go. One edit.
func _set_writes_variable(id: int, variable: String) -> void:
	var found := blueprint.graph.find_variable(variable)
	if found.is_empty() or blueprint.graph.find_node(id).is_empty(): return
	var type := XREBlueprintGraph.port_type(XREBlueprintGraph.variable_type(found))
	var state := blueprint.graph.snapshot()
	for entry: Dictionary in state["nodes"]:
		if entry["id"] != id: continue
		entry["kind"] = "set_variable"
		entry["params"] = {"variable": variable, "value": found.get("value", XREBlueprintSchema.default_value(XREBlueprintGraph.variable_type(found)))}
		for key: String in ["vr_anchor", "vr_links", XREBlueprintGraph.SCENE_BENDS]: entry.erase(key)
	_keep_set_wires(state, id, type)
	if blueprint.perform(blueprint.commit.bind("Set Variable", state), &"vr_graph"):
		cancel_connection()
		_message("Set writes %s." % variable)
	else: _message(blueprint.last_error)


## The other way (D-102): Set [param id], writing a variable, writes a
## property of [param node], under the hood a Set Property, its member to
## pick from the petals that open. Execution and Value wires stay. One edit.
func _set_writes_property(id: int, node: Node) -> void:
	var host := blueprint.get_host()
	if host == null or not blueprint.scene_nodes().has(node):
		_message("The target is outside the edited scene.")
		return
	var state := blueprint.graph.snapshot()
	var defaults: Dictionary = XREBlueprintGraph.BLOCKS["set_property"]["params"]
	for entry: Dictionary in state["nodes"]:
		if entry["id"] != id: continue
		entry["kind"] = "set_property"
		entry["params"] = {"target": str(host.get_path_to(node)), "property": defaults["property"], "value": defaults["value"]}
		for key: String in ["vr_links", XREBlueprintGraph.VARIABLE_BENDS]: entry.erase(key)
	_keep_set_wires(state, id, XREBlueprintGraph.VALUE)
	if not blueprint.perform(blueprint.commit.bind("Set Property", state), &"vr_graph"):
		_message(blueprint.last_error)
		return
	cancel_connection()
	var object := node as Node3D
	if object != null: _open_petals(id, object, object.global_position)
	_message("Set writes a property of %s: pick it." % node.name)


## Keeps of [param state]'s wires into Set [param id] its execution and a
## Value wire whose source fits [param type]; a dropped Value keeps its token.
func _keep_set_wires(state: Dictionary, id: int, type: int) -> void:
	state["edges"] = (state["edges"] as Array).filter(func(edge: Dictionary) -> bool: return _keeps_set_wire(edge, id, type))
	_drop_orphan_inlines(state)


func _keeps_set_wire(edge: Dictionary, id: int, type: int) -> bool:
	if edge["to"] != id or int(edge["to_port"]) == 0: return true
	if int(edge["to_port"]) != 1: return false
	var source := blueprint.graph.find_node(edge["from"])
	var outputs := blueprint.graph.ports(source, false)
	return int(edge["from_port"]) < outputs.size() and XREBlueprintGraph.ports_compatible(int((outputs[int(edge["from_port"])] as Array)[1]), type)


## The policy chip of an archetype's event (D-107): a click takes the next
## policy — parallel, ignore, restart, parallel —, one edit, no widget.
func _next_policy(id: int) -> void:
	var block := blueprint.graph.find_node(id)
	if block.is_empty(): return
	var policies: Array[String] = ["parallel", "ignore", "restart"]
	var next := policies[(policies.find(str((block["params"] as Dictionary).get("policy", "parallel"))) + 1) % policies.size()]
	if not blueprint.perform(blueprint.set_parameter.bind(id, "policy", next), &"vr_graph"): _message(blueprint.last_error)


## Switches what the header of block [param id]'s archetype says (D-101):
## the member if it said the operation, and back. Kept in the block's
## vr_heading, one edit of the graph, which A undoes.
func switch_heading(id: int) -> void:
	var block := blueprint.graph.find_node(id)
	if block.is_empty() or not XREBlueprintCanvas.can_head(block): return
	var heading := XREFeatureSettings.OPERATION if canvas.heading_of(block) == XREFeatureSettings.MEMBER else XREFeatureSettings.MEMBER
	var state := blueprint.graph.snapshot()
	for entry: Dictionary in state["nodes"]:
		if entry["id"] == id: entry["vr_heading"] = str(heading)
	blueprint.perform(blueprint.commit.bind("Switch Heading", state), &"vr_graph")


## Removes the selected block and incident wires through the graph document.
## A block of several selected takes them all along, as one undo step (D-117).
func delete_block(id: int = -1) -> void:
	var target := id if id >= 0 else _selected
	if target < 0 or blueprint.graph.find_node(target).is_empty(): return
	var targets: Array[int] = [target]
	if _selected_blocks.size() > 1 and _selected_blocks.has(target): targets = _selected_blocks.duplicate()
	for pointer: Pointer in _pointers:
		if targets.has(pointer.block) or pointer.group.any(func(held: int) -> bool: return targets.has(held)): _finish_hold(pointer, false)
	cancel_connection()
	if targets.has(_target_pick): _target_pick = -1
	var was_selected := targets.has(_selected)
	# As the document's remove_blocks, but the ports its wires fed get default tokens (D-059).
	var state := blueprint.graph.snapshot()
	state["nodes"] = (state["nodes"] as Array).filter(func(block: Dictionary) -> bool: return not targets.has(block["id"]))
	state["edges"] = (state["edges"] as Array).filter(func(edge: Dictionary) -> bool: return not targets.has(edge["from"]) and not targets.has(edge["to"]))
	_drop_orphan_inlines(state)
	_fill_sockets(state)
	blueprint.perform(blueprint.commit.bind("Delete Blocks", state), &"vr_graph")
	if was_selected: select_block(-1)


## Removes from [param state] the inline Get Variable blocks (D-061) whose
## wire is gone: without it there is nothing of them to see or to take.
## A hidden Break of a box's components goes the same way (D-105), and then its Get Variable;
## with Composite values on Whole that Break is a card, and stays.
func _drop_orphan_inlines(state: Dictionary) -> void:
	while true:
		var feeding: Dictionary[int, bool] = {}
		for edge: Dictionary in state["edges"]: feeding[int(edge["from"])] = true
		var orphans: Dictionary[int, bool] = {}
		for block: Dictionary in state["nodes"]:
			if canvas.is_inline(block) and not feeding.has(int(block["id"])): orphans[int(block["id"])] = true
		if orphans.is_empty(): return
		state["nodes"] = (state["nodes"] as Array).filter(func(block: Dictionary) -> bool: return not orphans.has(int(block["id"])))
		state["edges"] = (state["edges"] as Array).filter(func(edge: Dictionary) -> bool: return not orphans.has(int(edge["to"])) and not orphans.has(int(edge["from"])))


## Gives every port of the blocks in [param state] that has neither a token
## nor a wire its default token (D-059): no edit in the headset leaves a port
## empty, so the graph builds and the token can be set again.
func _fill_sockets(state: Dictionary) -> void:
	for entry: Dictionary in state["nodes"]:
		var params: Dictionary = entry["params"]
		for key: String in blueprint.graph.socket_keys(entry):
			if params.has(key): continue
			var port := blueprint.graph.input_port(entry, key)
			var wired := false
			for edge: Dictionary in state["edges"]:
				if edge["to"] == entry["id"] and edge["to_port"] == port: wired = true
			if not wired: params[key] = _socket_default(entry, key)


## The default token of port [param key] of [param block], of the type it expects.
func _socket_default(block: Dictionary, key: String) -> Variant:
	var type := XREBlueprintTokens.expected_type(blueprint.graph, block, key)
	var fallback: Variant = XREBlueprintTokens.default_value(block, key)
	if type != TYPE_NIL and typeof(fallback) != type and not (type == TYPE_FLOAT and typeof(fallback) == TYPE_INT): return XREBlueprintSchema.default_value(type)
	return fallback


## Connected ports detach one wire as one undo step; empty ports start a click-click wire.
## [param edge] is the wire on the port to detach, the one lit under the ray
## ([method XREBlueprintCanvas.get_hit_edge]); -1 or another port's takes the port's last wire.
## On Play Animation's output 0 with a Finished socket (D-052), [param finished]
## is 1 for Finished and 0 for Then: the free one of the two takes the wire as
## one edit of its wait.
func click_port(id: int, port: int, input: bool, hand: XREHand = null, edge: int = -1, finished: int = -1) -> bool:
	if not canvas.has_port(id, port, input): return false
	if not input and port == 0 and finished >= 0 and canvas.has_finished(id) and _pending_id < 0:
		var wired := false
		for wire: Dictionary in blueprint.graph.edges:
			if wire["from"] == id and wire["from_port"] == 0: wired = true
		if wired and canvas.is_waiting(id) != (finished == 1):
			_message("Waits for the animation." if finished == 1 else "Goes on at once.")
			return _set_token(id, "wait", finished == 1, "Wire Finished")
		if not wired: _pending_finished = finished
	if _pending_id == id and _pending_port == port and _pending_input == input:
		# The same port again takes the wire back (D-043), as the trigger on nothing does.
		cancel_connection()
		_message("Wire cancelled.")
		return true
	if _pending_id < 0:
		# A connected port keeps its end of the wire picked on it and lets go of the
		# other end, which follows the ray (D-058, after D-044 had it the other way
		# round): to go to another port, or away with the trigger on nothing. One
		# undo puts it back.
		var detached := -1
		for index: int in blueprint.graph.edges.size():
			var wire_on: Dictionary = blueprint.graph.edges[index]
			if (input and wire_on["to"] == id and wire_on["to_port"] == port) or (not input and wire_on["from"] == id and wire_on["from_port"] == port):
				detached = index
				if index == edge: break
		if detached >= 0:
			var state := blueprint.graph.snapshot()
			var edges: Array = state["edges"]
			var wire: Dictionary = edges[detached]
			var source := blueprint.graph.find_node(wire["from"])
			edges.remove_at(detached)
			_drop_orphan_inlines(state)
			_fill_sockets(state)
			if not blueprint.perform(blueprint.commit.bind("Disconnect Ports", state), &"vr_graph"): return false
			_pending_id = id
			_pending_port = port
			_pending_input = input
			_pending_hand = hand
			# A link to a variable taken off its port goes to the next box as a link (D-074).
			_pending_link = input and canvas.is_inline(source) and XREBlueprintLinks.is_link(source, XREBlueprintLinks.VARIABLE)
			canvas.highlight_ports(canvas.port_type(_pending_id, _pending_port, _pending_input), not _pending_input)
			_message("Wire detached. Trigger on a port reconnects it; on empty space removes it.")
			return true
		_pending_id = id
		_pending_port = port
		_pending_input = input
		_pending_hand = hand
		_pending_link = false
		canvas.highlight_ports(canvas.port_type(id, port, input), not input)
		_message("Press trigger on a compatible port. The same port or empty space cancels the wire.")
		return true
	if input == _pending_input:
		_message("Connect an output to an input.")
		return false
	var from := id if _pending_input else _pending_id
	var from_port := port if _pending_input else _pending_port
	var to := _pending_id if _pending_input else id
	var to_port := _pending_port if _pending_input else port
	var wait := (finished if _pending_input else _pending_finished) if from_port == 0 and canvas.has_finished(from) else -1
	var success: bool
	if wait >= 0:
		# Wired from Finished it waits, from Then it doesn't: the wire and the wait are one edit.
		var state := blueprint.graph.snapshot()
		(state["edges"] as Array).append({"from": from, "from_port": from_port, "to": to, "to_port": to_port})
		for block: Dictionary in state["nodes"]:
			if block["id"] == from: block["params"]["wait"] = wait == 1
		success = blueprint.perform(blueprint.commit.bind("Connect Ports", state), &"vr_graph")
	else:
		success = blueprint.perform(blueprint.connect_blocks.bind(from, from_port, to, to_port), &"vr_graph")
	if success:
		cancel_connection()
		_close_wire_menu()
	else: _message(blueprint.last_error)
	return success


## The block menu of a wire let go in empty space (D-051) closes once the
## wire ends on a port or a box instead (D-067): the menu was for that wire.
## Pinned to a hand, it stays.
func _close_wire_menu() -> void:
	if not _menu_at_point: return
	_menu_at_point = false
	_menu_wire = {}
	_dismiss_window(XREBlueprintPaletteTab, false)


## Whether [param hand] draws a wire: from a port, a Source, a box or a petal.
func has_wire(hand: XREHand) -> bool:
	return hand != null and (_pending_hand == hand or _link_hand == hand or _member_hand == hand)


## Discards only the pending connection preview.
func cancel_connection() -> void:
	_pending_id = -1
	_pending_port = -1
	_pending_input = false
	_pending_hand = null
	_pending_finished = -1
	_pending_link = false
	_link_kind = -1
	_link_block = -1
	_link_box = ""
	_link_component = -1
	_link_hand = null
	_member_link = {}
	_member_hand = null
	_choice.close()
	if _petal_block >= 0 or _petal_dynamic: _petals.close()
	_petal_block = -1
	_petal_dynamic = false
	canvas.hide_connection()
	if is_inside_tree(): _update_selection_fan()


## Arms direct scene picking for the selected block's static Target.
func pick_target() -> void:
	var block := blueprint.graph.find_node(_selected)
	if block.is_empty() or not (block["params"] as Dictionary).has("target"):
		_message("Select a block with a Target first.")
		return
	if not blueprint.scene_context_active():
		_message(blueprint.scene_context_message())
		return
	cancel_connection()
	_target_pick = _selected
	_message("Point at a scene object and press trigger. Invisible targets are in the parameter tree.")


## Finds a direct host, child behavior or ancestor host for a scene selection.
func related_host(node: Node) -> Node:
	if not source_path(node).is_empty(): return node
	for marker: Marker in _markers:
		if is_instance_valid(marker.host) and marker.host.get_parent() == node: return marker.host
	var ancestor := node.get_parent()
	while ancestor != null:
		if not source_path(ancestor).is_empty(): return ancestor
		if ancestor == _root: break
		ancestor = ancestor.get_parent()
	return null


## Shows cached host markers without modifying the edited scene.
func set_logic_mode(enabled: bool) -> void:
	logic_mode = enabled
	changed.emit()


func _update_pointer(pointer: Pointer, delta: float) -> void:
	var hand := pointer.hand
	if not hand.grip_held or not hand.is_free_for(self): pointer.adding = false
	if pointer.brushing:
		if not hand.get_has_tracking_data() or not hand.is_free_for(self): _cancel_block_brush(pointer)
		elif not hand.trigger_held or hand.grip_pressed: _end_block_brush(pointer)
	if pointer.boxing and _drag_block_box(pointer): return
	if pointer.swallow and not (hand.trigger_held and hand.get_has_tracking_data()):
		pointer.swallow = false
		if hand.get_claimant() == self: hand.unclaim(self)
	if pointer.bend_edge >= 0:
		_update_bend(pointer)
		return
	if pointer.carried != null:
		_update_carried(pointer)
		return
	if not pointer.pull.is_empty():
		_update_pull(pointer)
		return
	if pointer.arrow_axis >= 0:
		_update_arrow(pointer, delta)
		return
	if pointer.globe_drag:
		_update_globe(pointer)
		return
	if pointer.fan != null:
		_update_fan_press(pointer)
		return
	if not pointer.token_key.is_empty() or not pointer.token_box.is_empty():
		_update_turn(pointer, delta)
		return
	if pointer.held != null:
		canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
		# A card or a box carried stays in focus (D-072).
		if pointer.held == canvas:
			pointer.focus = pointer.block
			pointer.focus_box = pointer.box
		var on_rod := pointer.block >= 0 or not pointer.box.is_empty()
		if not hand.get_has_tracking_data(): _finish_hold(pointer, false)
		elif on_rod and pointer.depth_uses_grip and not _rig.has_grip_pose(hand): _finish_hold(pointer, false)
		elif not (hand.trigger_held if pointer.by_trigger else hand.grip_held): _finish_hold(pointer, true)
		else:
			if on_rod:
				if not pointer.touched: _reel(pointer)
				var contact := _rig.hand_pose(hand, pointer.depth_uses_grip).origin if pointer.touched else hand.global_position - hand.global_basis.z.normalized() * pointer.distance
				if pointer.box.is_empty(): canvas.preview_grab(pointer.block, contact, pointer.grab_point, _rig.camera.global_position)
				if pointer.box.is_empty() and not pointer.group.is_empty():
					canvas.preview_group(pointer.group, pointer.group_starts, canvas.get_block_position(pointer.block) - pointer.before.origin)
				elif not pointer.box.is_empty(): canvas.preview_box_grab(pointer.box, contact, pointer.grab_point)
				if pointer.touched: hand.hide_ray()
				else: hand.show_ray(pointer.distance, true)
			else:
				var target := hand.global_transform * pointer.hold
				if pointer.held == _keyboard: pointer.held.global_transform = target
				else: pointer.held.global_transform = Transform3D(XREPanels.facing(target.origin, _rig.camera.global_position, Vector3.UP), target.origin)
				if pointer.window != null: pointer.window.hover_handles(pointer.corner)
			return
	if _wire_menu.is_open():
		# The wire's menu has both hands while it is open (D-090), as the object's shortcut does.
		if hand == _wire_menu_hand: _update_wire_menu(pointer)
		else:
			_leave(pointer)
			hand.claim(self)
			hand.show_ray(XREHand.RAY_LENGTH, false)
		return
	if not hand.is_free_for(self) or not hand.get_has_tracking_data():
		canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
		canvas.hover_socket(-1, -1, hand == _rig.right_hand)
		var box_waits := _link_hand == hand and not _link_box.is_empty()
		var menu_waits := (_pending_hand == hand or box_waits) and _dropped_menu_open() and hand.get_has_tracking_data()
		var window := _menu_window()
		if menu_waits and hand.trigger_pressed and (window == null or window.intersect_ray(hand.global_position, -hand.global_basis.z.normalized(), INF) < 0):
			# A click on another window lets the wire go with its menu (D-094).
			_cancel_dropped_wire()
		elif menu_waits:
			# On the menu of a wire let go, the wire waits at the point it was let go (D-051).
			if box_waits: canvas.show_link(_link_origin(), _menu_point)
			else: _preview_connection(canvas.to_global(_menu_point))
		elif has_wire(hand) and hand.get_has_tracking_data() and hand.get_claimant() is XREPanels:
			# A window has the ray (D-058): the wire waits; a click on the window or its × lets it go.
			if hand.trigger_pressed:
				cancel_connection()
				_message("Wire cancelled.")
		elif has_wire(hand): cancel_connection()
		_leave(pointer)
		return
	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	var distance := 5.0
	var surface: XREPanelSurface
	var handle: XREPanelSurface
	var canvas_hit := -1.0
	if _workspace.visible and hand.grip_pressed:
		var touched := touch_block(hand)
		if touched >= 0:
			canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
			_start_hold(pointer, canvas, touched, _rig.hand_pose(hand, true).origin, true)
			return
	# The widget of a value is over everything: it takes the ray first (D-058).
	if _workspace.visible and _point_at_editor(pointer, origin, direction): return
	if _workspace.visible and hand == _pipette_hand:
		var color_window := _color_window()
		if color_window != null and (color_window.intersect_ray(origin, direction, XREPanels.POINT_DISTANCE) >= 0 or color_window.intersect_handle(origin, direction, XREPanels.POINT_DISTANCE) >= 0):
			# The window's own buttons — Put back, Done — are the panels' from the next frame.
			_leave(pointer)
			hand.unclaim(self)
			return
		_point_pipette(pointer, origin, direction)
		return
	# Petals picked in focus are the input in use (D-066): over the cards and the
	# windows, which covered them and took the ray, they take it first.
	var fan_first := _workspace.visible and is_focused() and (_choice.is_open() or (_petals.is_open() and (_petal_block >= 0 or _petal_dynamic)))
	if fan_first and _point_at_petals(pointer, origin, direction, 5.0, delta): return
	# A window of the panels drawn over everything, as the block palette (D-086), is the
	# panels' from the next frame, however near the cards in front of it; the keyboard, over it, stays.
	if _workspace.visible and is_instance_valid(panels) and not (pointer.surface != null and pointer.surface.is_pressed()) \
			and not (_keyboard.is_shown() and _keyboard.intersect_ray(origin, direction, INF) >= 0) and panels.on_top_surface(hand, origin, direction) != null:
		canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
		_leave(pointer)
		hand.unclaim(self)
		hand.unclaim_stick(self)
		return
	if pointer.surface != null and pointer.surface.is_pressed():
		surface = pointer.surface
		distance = surface.intersect_ray(origin, direction, INF, false)
	else:
		if _workspace.visible: canvas_hit = canvas.intersect_ray(origin, direction, distance)
		if _badge.is_shown():
			var hit := _badge.intersect_ray(origin, direction, distance)
			if hit >= 0:
				surface = _badge
				distance = hit
		if _workspace.visible:
			for window: XREPanelSurface in _windows:
				var hit := window.intersect_ray(origin, direction, distance)
				if hit >= 0:
					surface = window
					distance = hit
			# Handles lie outside the frames: only one nearer than any window is taken.
			for window: XREPanelSurface in _windows:
				var hit := window.intersect_handle(origin, direction, distance)
				if hit >= 0:
					handle = window
					distance = hit
			if handle != null: surface = null
		if canvas_hit >= 0 and canvas_hit < distance and not (surface != null and surface.is_on_top()):
			surface = null
			handle = null
	if _workspace.visible and (hand.grip_pressed or hand.trigger_pressed) and _take_from_tray(pointer, origin, direction): return
	if handle != null:
		canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
		if _pending_hand == hand: _preview_connection(origin + direction * maxf(distance, 0.01))
		_leave(pointer)
		hand.claim(self)
		hand.claim_stick(self)
		hand.show_ray(maxf(distance, 0.01), true)
		handle.hover_handles(handle.get_hit_corner())
		if hand.trigger_pressed or hand.grip_pressed: _hold_window(pointer, handle, handle.get_hit_corner(), not hand.grip_pressed)
		return
	if surface != null:
		canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
		# A click on one of the graph's windows lets a wire go, as on the panels' (D-058).
		if hand.trigger_pressed and has_wire(hand) and surface != _menu_window():
			if _dropped_menu_open(): _cancel_dropped_wire()
			else: cancel_connection()
		if _pending_hand == hand: _preview_connection(origin + direction * maxf(distance, 0.01))
		if pointer.surface != surface:
			_leave(pointer)
			pointer.surface = surface
		hand.claim(self)
		hand.claim_stick(self)
		hand.show_ray(maxf(distance, 0.01), true)
		surface.hover_handles(-1)
		if surface == _keyboard:
			if distance >= 0: _keyboard.hover_pointer(hand, surface.get_hit_pixel())
			else: _keyboard.leave_pointer(hand)
			if hand.grip_pressed: _hold_window(pointer, _keyboard, -1, false)
			return
		if not pointer.drives:
			pointer.drives = true
			for other: Pointer in _pointers:
				if other != pointer and other.surface == surface and other.drives:
					if surface.is_pressed() or hand == _rig.left_hand: pointer.drives = false
					else: other.drives = false
		if not pointer.drives: return
		if distance >= 0:
			surface.pointer_move(surface.get_hit_pixel())
		if hand.trigger_pressed: surface.pointer_button(true)
		if hand.trigger_released: surface.pointer_button(false)
		if hand.grip_pressed and surface != _badge and not surface.is_pressed(): _hold_window(pointer, surface, -1, false)
		elif hand == _rig.right_hand:
			var tilt := XREPanels._tilt(hand.get_vector2(&"primary").y)
			if tilt != 0: surface.pointer_scroll(tilt * XREPanels.SCROLL_SPEED * delta)
		return
	_leave(pointer)
	# A link button stands in front of what put it up (D-074): it takes the ray first.
	if _workspace.visible and _point_at_button(pointer, origin, direction, canvas_hit): return
	if _workspace.visible and not fan_first and _point_at_petals(pointer, origin, direction, canvas_hit if canvas_hit >= 0 else 5.0, delta): return
	if _workspace.visible and _point_at_stem(pointer, origin, direction, canvas_hit if canvas_hit >= 0 else 5.0): return
	if _workspace.visible and _point_at_link_wire(pointer, origin, direction, canvas_hit if canvas_hit >= 0 else 5.0, canvas_hit >= 0 and canvas.get_hit_wire() >= 0): return
	if _workspace.visible:
		var hit := canvas_hit
		if _pending_hand == hand: _preview_connection(origin + direction * (hit if hit >= 0 else 0.8), canvas.get_hit_id() if hit >= 0 else -1, canvas.get_hit_port() if hit >= 0 else -1, canvas.get_hit_input())
		# With the menu of a wire let go open, a click on a card, a port, a box or a
		# wire lets the wire go with the menu, and does nothing else (D-094).
		if hit >= 0 and hand.trigger_pressed and has_wire(hand) and _dropped_menu_open():
			hand.claim(self)
			hand.show_ray(hit, true)
			_cancel_dropped_wire()
			return
		if hit >= 0 and canvas.get_hit_box():
			_point_at_box(pointer, origin, direction, hit)
			return
		if hit >= 0 and canvas.get_hit_wire() >= 0:
			_point_at_wire(pointer, hit)
			return
		if hit >= 0:
			_point_at_card(pointer, origin, direction, hit)
			return
	canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
	canvas.hover_socket(-1, -1, hand == _rig.right_hand)
	if _pending_scene_target() or (_link_kind == XREBlueprintCanvas.SOURCE and _link_hand == hand) or (_link_hand == hand and _variable_set_link()):
		_update_scene_target_pointer(hand, origin, direction)
		return
	if not _member_link.is_empty() and _member_hand == hand:
		_update_member_link(hand, origin, direction)
		return
	if _link_kind == XREBlueprintCanvas.VARIABLE and _link_hand == hand:
		var box_menu := _menu_window() if not _link_box.is_empty() else null
		if box_menu != null and box_menu.intersect_ray(origin, direction, distance) >= 0:
			# As a port's wire (D-051): the menu's window takes the ray from the next frame.
			canvas.show_link(_link_origin(), _menu_point)
			_leave(pointer)
			hand.unclaim(self)
			return
		hand.claim(self)
		hand.show_ray(0.8, false)
		_show_box_link(canvas.to_local(origin + direction * 0.8))
		if hand.trigger_pressed:
			# From a box, a click in empty space opens the block menu for its value
			# (D-063), as a port's wire does; a second click there takes the wire back.
			if not _link_box.is_empty() and not _dropped_menu_open():
				_open_menu_for_box(canvas.to_local(origin + direction * 0.8))
				return
			if _dropped_menu_open(): _cancel_dropped_wire()
			else: cancel_connection()
			_message("Variable wire cancelled.")
		return
	if _pending_hand == hand:
		var menu := _menu_window()
		if menu != null and menu.intersect_ray(origin, direction, distance) >= 0:
			# The menu of a wire let go is the panels' window: they take the ray from the next frame.
			_preview_connection(canvas.to_global(_menu_point))
			_leave(pointer)
			hand.unclaim(self)
			return
		hand.claim(self)
		hand.show_ray(0.8, false)
		# Let go in empty space, the wire opens the block menu for its pin (D-051);
		# its own port or × of the menu takes it back, and so does a second click
		# in empty space while that menu is open (D-058).
		if hand.trigger_pressed:
			if _dropped_menu_open(): _cancel_dropped_wire()
			else: _open_menu_for_wire(canvas.to_local(origin + direction * 0.8))
		return
	if _target_pick >= 0:
		if not blueprint.scene_context_active():
			_target_pick = -1
			_message(blueprint.scene_context_message())
			return
		hand.claim(self)
		var hit_node: Node
		var hit_distance := 5.0
		var end := origin + direction * 5.0
		if _icons != null and _icons.cast_segment(origin, end):
			hit_node = _icons.get_hit_node()
			hit_distance = _icons.get_hit_distance()
		elif is_instance_valid(_root) and _picker.cast_segment(_root, origin, end):
			hit_node = _picker.get_hit_node()
			hit_distance = _picker.get_hit_distance()
		hand.show_ray(hit_distance, hit_node != null)
		if hand.trigger_pressed and hit_node != null:
			if blueprint.perform(blueprint.choose_target.bind(_target_pick, hit_node), &"vr_graph"):
				_target_pick = -1
				_message("Target selected.")
			else: _message(blueprint.last_error)
		return
	if logic_mode:
		for marker: Marker in _markers:
			if not marker.visual.visible: continue
			var along := direction.dot(marker.visual.global_position - origin)
			if along > 0 and along < 5.0 and (origin + direction * along).distance_squared_to(marker.visual.global_position) < 0.05 * 0.05:
				hand.claim(self)
				hand.show_ray(along, true)
				if hand.trigger_pressed: open_graph(marker.path)
				return
	# The trigger in empty space draws a selection box on the graph's plane (D-120).
	if hand.trigger_pressed and _workspace.visible and _begin_block_box(pointer, origin, direction): return
	# The grip in empty space: the other hand's trigger adds blocks (D-117).
	if hand.grip_pressed and hand.is_free_for(self): pointer.adding = true
	# A click away that closed an input goes on to the graph, but selects no
	# scene object (D-063): the hand stays the graph's until it is let go.
	if pointer.swallow and hand.is_free_for(self):
		hand.claim(self)
		hand.show_ray(0.8, false)


func _preview_connection(point: Vector3, end_id: int = -1, end_port: int = -1, end_input: bool = false) -> void:
	# While the menu of a wire let go is open, the wire ends where it was let go, wherever the ray is (D-094).
	if _dropped_menu_open():
		canvas.show_connection(_pending_id, _pending_port, _pending_input, _menu_point, -1, -1, false, _pending_finished)
		return
	canvas.show_connection(_pending_id, _pending_port, _pending_input, canvas.to_local(point), end_id, end_port, end_input, _pending_finished)


## Takes [param node] in [param pointer]'s hand: the canvas with card
## [param block] or the box of variable [param box] (D-078) on a rod to
## [param point], or by touch; a window with -1 and no box.
func _start_hold(pointer: Pointer, node: Node3D, block: int, point: Vector3 = Vector3.ZERO, touched: bool = false, box: String = "") -> void:
	for other: Pointer in _pointers:
		if other.held != null: return
	cancel_connection()
	_leave(pointer)
	pointer.held = node
	pointer.block = block
	pointer.box = box
	pointer.window = null
	pointer.corner = -1
	pointer.by_trigger = false
	var target := node.global_transform
	if block >= 0 or not box.is_empty():
		if block >= 0: _hold_group(pointer, block)
		pointer.before = canvas.get_block_transform(block) if box.is_empty() else Transform3D(Basis.IDENTITY, canvas.get_boxes().box_point(box))
		pointer.touched = touched
		target = canvas.global_transform * pointer.before
		pointer.grab_point = target.affine_inverse() * point
		pointer.distance = pointer.hand.to_local(point).length()
		pointer.depth_uses_grip = _rig.has_grip_pose(pointer.hand)
		var physical := _rig.hand_pose(pointer.hand, pointer.depth_uses_grip).origin
		pointer.body_offset = _body_offset(physical)
		pointer.along = (_rig.global_basis.inverse() * -pointer.hand.global_basis.z).normalized()
		pointer.gain = 1.0 if touched else maxf(_body_reach(point) / maxf(_body_reach(physical), XREManipulator.MIN_REACH), 1.0)
		if touched: pointer.hand.hide_ray()
		else: pointer.hand.show_ray(pointer.distance, true)
	else: pointer.hold = pointer.hand.global_transform.affine_inverse() * target
	pointer.hand.claim(self)


## Takes [param window], by its [param corner] handle or by its interface
## with -1, held by the trigger if [param by_trigger], otherwise by the grip.
func _hold_window(pointer: Pointer, window: XREPanelSurface, corner: int, by_trigger: bool) -> void:
	_start_hold(pointer, window, -1)
	if pointer.held == null: return
	pointer.window = window
	pointer.corner = corner
	pointer.by_trigger = by_trigger
	pointer.window_before = pointer.held.global_transform


## Selects block [param block], taken by [param pointer]'s hand, and the other
## selected blocks it carries (D-117): a selected block keeps the selection,
## one the other hand's grip adds joins it, any other replaces it.
func _hold_group(pointer: Pointer, block: int) -> void:
	if not _selected_blocks.has(block):
		if _adds_blocks(pointer): toggle_block(block)
		else: select_block(block)
	pointer.group.clear()
	pointer.group_starts.clear()
	for id: int in _selected_blocks:
		if id == block or not canvas.has_block(id): continue
		pointer.group.append(id)
		pointer.group_starts.append(canvas.get_block_position(id))


## Distance from [param point] to the body: a vertical shoulder-to-hip segment
## below the neck pivot of [param head]. Sets the HOMER gain of a far grab.
static func body_reach(head: Transform3D, up: Vector3, point: Vector3) -> float:
	var neck := head * NECK_FROM_EYES
	var axis := Geometry3D.get_closest_point_to_segment(point, neck - up * BODY_TOP, neck - up * BODY_BOTTOM)
	return point.distance_to(axis)


func _body_reach(point: Vector3) -> float:
	return body_reach(_rig.camera.global_transform, _rig.global_basis.y.normalized(), point)


## Where [param point] is relative to the neck pivot, in rig space: walking, turning
## the head and flying the rig leave it unchanged.
func _body_offset(point: Vector3) -> Vector3:
	var to_rig := _rig.global_transform.affine_inverse()
	return to_rig * point - to_rig * (_rig.camera.global_transform * NECK_FROM_EYES)


## Reels the rod of [param pointer] — a far card's or box's (D-036, D-037, D-078), a bend's
## (D-081): only the hand's motion along the rod, relative to the body,
## changes its length; moving across the rod (sideways, up, down) keeps it.
## The rod direction is averaged over the frame, which makes a swing around
## the body with the rod pointing outwards exactly length-preserving.
func _reel(pointer: Pointer) -> void:
	var offset := _body_offset(_rig.hand_pose(pointer.hand, pointer.depth_uses_grip).origin)
	var along := (_rig.global_basis.inverse() * -pointer.hand.global_basis.z).normalized()
	var mean := along + pointer.along
	if mean.is_zero_approx(): mean = along
	pointer.distance = maxf(XREManipulator.TOUCH_RADIUS, pointer.distance + (offset - pointer.body_offset).dot(mean.normalized()) * (pointer.gain - 1.0))
	pointer.body_offset = offset
	pointer.along = along


func _finish_hold(pointer: Pointer, commit: bool) -> void:
	if pointer.block >= 0 and not pointer.group.is_empty():
		if commit:
			var moved: Array[int] = [pointer.block]
			moved.append_array(pointer.group)
			canvas.commit_moves(blueprint, moved)
		else:
			canvas.preview_transform(pointer.block, pointer.before)
			canvas.preview_group(pointer.group, pointer.group_starts, Vector3.ZERO)
	elif pointer.block >= 0:
		if commit: canvas.commit_move(blueprint, pointer.block)
		else: canvas.preview_transform(pointer.block, pointer.before)
	elif not pointer.box.is_empty():
		if commit: canvas.commit_box_move(blueprint, pointer.box)
		else: canvas.preview_box_move(pointer.box, pointer.before.origin)
	elif pointer.held != null and pointer.window != null and not pointer.held.global_transform.is_equal_approx(pointer.window_before):
		_document.history.record(XREHistory.Kind.VIEW, "Move window", _place_window.bind(pointer.held, pointer.window_before),
				_place_window.bind(pointer.held, pointer.held.global_transform))
	pointer.held = null
	pointer.block = -1
	pointer.group.clear()
	pointer.group_starts.clear()
	pointer.box = ""
	pointer.window = null
	pointer.by_trigger = false
	pointer.hand.show_ray(XREHand.RAY_LENGTH, false)
	pointer.hand.unclaim(self)


func _finish_holds() -> void:
	for pointer: Pointer in _pointers:
		if pointer.held != null: _finish_hold(pointer, true)


func _leave(pointer: Pointer) -> void:
	if pointer.surface != null:
		if pointer.surface == _keyboard: _keyboard.leave_pointer(pointer.hand)
		if pointer.drives: pointer.surface.pointer_exit()
		pointer.surface = null
		pointer.drives = false
	if pointer.held == null:
		pointer.hand.unclaim(self)
		pointer.hand.unclaim_stick(self)


## Touch checks the physical controller, then its aim origin for tracker compatibility.
func touch_block(hand: XREHand) -> int:
	if not _workspace.visible: return -1
	var id := canvas.intersect_touch(_rig.hand_pose(hand, true).origin)
	return id if id >= 0 else canvas.intersect_touch(hand.global_position)


## Earlier panel routing yields to nearby touch and to a closer keyboard surface.
## On a panel drawn over everything ([param on_top], D-086), only what is drawn
## over everything too, a touch and what the hand already does take the ray.
func takes_pointer(hand: XREHand, origin: Vector3, direction: Vector3, distance: float, on_top: bool = false) -> bool:
	if _workspace.visible: canvas.face_user(_rig.camera.global_position)
	# What is drawn over everything takes the ray however far it is (D-058).
	if _workspace.visible and _token_editor.is_interactive() and not _token_editor.pick(origin, direction).is_empty(): return true
	if _keyboard.is_shown() and _keyboard.intersect_ray(origin, direction, INF) >= 0: return true
	if hand.grip_pressed and touch_block(hand) >= 0: return true
	for pointer: Pointer in _pointers:
		if pointer.hand == hand and (pointer.carried != null or not pointer.pull.is_empty() or not pointer.token_key.is_empty() or not pointer.token_box.is_empty()): return true
	if on_top: return false
	for pointer: Pointer in _pointers:
		# A link button, or a wire that may become a link, nearer than the panel (D-074).
		if pointer.hand == hand and _workspace.visible and pointer.button != null and pointer.button.visible and _pill_distance(pointer.button, origin, direction) >= 0.0: return true
	if _workspace.visible and not _document.features.get_value(XREFeatureSettings.LINK_CREATE) in [XREFeatureSettings.PORT_BUTTON, XREFeatureSettings.ALWAYS] and _link_wire_hit(origin, direction, distance) >= 0.0: return true
	if _workspace.visible and (hand.grip_pressed or hand.trigger_pressed) and not _tray_cell(origin, direction).is_empty(): return true
	if _workspace.visible and ((_petals.is_open() and _petals.intersect_ray(origin, direction, distance) >= 0) or (_choice.is_open() and _choice.intersect_ray(origin, direction, distance) >= 0)): return true
	if _workspace.visible:
		var card_hit := canvas.intersect_ray(origin, direction, distance)
		if card_hit >= 0 and card_hit < distance: return true
	if not _workspace.visible: return false
	# The graph's windows and their handles, nearer than the panel the ray is on.
	for window: XREPanelSurface in _windows:
		if window.intersect_ray(origin, direction, distance) >= 0 or window.intersect_handle(origin, direction, distance) >= 0: return true
	return false


func _selection_changed() -> void:
	_update_selection_fan()
	var nodes := _document.get_selection()
	if nodes.size() == 1 and is_instance_valid(nodes[0]) and is_block_palette_shown() and _workspace.visible:
		block_menu.set_contexts(_menu_contexts(_menu_card), blueprint.get_host(), blueprint.graph)
	_update_badge()
	changed.emit()


## The badge (D-085): in the scene, over the one selected object, with its
## Blueprint button; in the graph, over the graph's object, with the graph's
## buttons, drawn over everything — or over the graph, if no object has it.
## With the object's shortcut on, the scene has no badge: the shortcut's
## Blueprint takes its place (D-088).
func _update_badge() -> void:
	var nodes := _document.get_selection()
	var selected: Node = nodes[0] if nodes.size() == 1 and is_instance_valid(nodes[0]) else null
	var graph := _workspace.visible
	var object: Node = blueprint.get_host() if graph else selected
	if not graph and _document.features.get_value(XREFeatureSettings.OBJECT_SHORTCUT) == XREFeatureSettings.ON: object = null
	_badge_anchor = _anchor(object) if is_instance_valid(object) and object.is_inside_tree() else null
	_badge_geometry.clear()
	if _badge_anchor != null: _collect_badge_geometry(_badge_anchor)
	if graph:
		var title := str(object.name) if is_instance_valid(object) else blueprint.path.get_file().get_basename()
		_badge.show_graph(title if not title.is_empty() else "Untitled")
	elif selected != null:
		_badge.show_scene(str(selected.name), related_host(selected) != null)
	_badge.set_on_top(graph)
	_badge.set_shown(graph or _badge_anchor != null)


## Selection/structural events cache geometry; the frame loop never walks the tree.
func _collect_badge_geometry(node: Node) -> void:
	var geometry := node as GeometryInstance3D
	if geometry != null and not (geometry is GPUParticles3D or geometry is CPUParticles3D):
		_badge_geometry.append(geometry)
	for child: Node in node.get_children(): _collect_badge_geometry(child)


## The top of the badge's object, where its leader starts.
func _badge_top() -> Vector3:
	var up := _rig.global_basis.y.normalized()
	var bounds := AABB()
	var found := false
	for geometry: GeometryInstance3D in _badge_geometry:
		if not is_instance_valid(geometry) or not geometry.is_inside_tree() or not geometry.is_visible_in_tree(): continue
		var local := geometry.custom_aabb
		if not local.has_surface(): local = geometry.get_aabb()
		var part := geometry.global_transform * local
		bounds = bounds.merge(part) if found else part
		found = true
	if not found: return _badge_anchor.global_position + up * 0.2
	# Support of the world AABB along rig-up keeps the whole panel outside it,
	# including rotated/nonuniform scales, offset children and changing CSG bounds.
	var radius := bounds.size.dot(up.abs()) * 0.5
	return bounds.get_center() + up * radius


func _scene_changed() -> void:
	for pointer: Pointer in _pointers:
		if pointer.held != null: _finish_hold(pointer, false)
	cancel_connection()
	_target_pick = -1
	_projection_meshes.clear()
	_root = _document.get_scene_root()
	_picker.scenario = get_viewport().find_world_3d().scenario
	blueprint.update_active_scene(_root)
	_refresh_markers()
	_selection_changed()
	_schedule_rebuild()


func _scene_operation(operation: StringName, source: XREDocument.Source, _nodes: Array[Node], _time_usec: int) -> void:
	if operation in [&"assign_blueprint", &"detach_blueprint", &"remove_nodes", &"add_node"]: _schedule_refresh()
	# An object may have changed its shape: its projection on a link is baked again (D-074).
	_projection_meshes.clear()
	# An object selected by pointing at it in the headset, not one added or picked on the desktop (D-063).
	if operation == &"select" and source == XREDocument.Source.TOOL: _follow_selection.call_deferred()


## A switch of the node display (D-039) redraws the open cards at once; a held card is put down first.
## So does a switch of the port display; a switch of the window shape bends or flattens the graph's windows.
func _feature_changed(key: StringName) -> void:
	if key == XREFeatureSettings.OBJECT_SHORTCUT:
		_update_badge()
		return
	if key in [XREFeatureSettings.BLOCK_PALETTE, XREFeatureSettings.PALETTE_GROUPS, XREFeatureSettings.NEXT_SUGGESTIONS]:
		_update_palette_mode()
		return
	if key == XREFeatureSettings.WINDOW_SHAPE:
		_update_window_shape()
		return
	if key == XREFeatureSettings.TOKEN_TRAY:
		_update_tray()
		return
	if key == XREFeatureSettings.SCENE_CREATE:
		_update_selection_fan()
		return
	if key == XREFeatureSettings.COLOR_INPUT:
		# The next color opens in the other mode; one open now is put back.
		if _editing_color(): _end_color(false)
		return
	if key in [XREFeatureSettings.FOCUS, XREFeatureSettings.DEFOCUS]:
		canvas.set_focus_modes(_document.features.get_value(XREFeatureSettings.FOCUS), _document.features.get_value(XREFeatureSettings.DEFOCUS))
		return
	if key in [XREFeatureSettings.LINK_PREVIEW, XREFeatureSettings.LINK_WIRES]:
		# The wires show or hide at once; another preview draws the links again (D-074).
		if not canvas.set_link_modes(_document.features.get_value(XREFeatureSettings.LINK_PREVIEW), _document.features.get_value(XREFeatureSettings.LINK_WIRES)): return
		_finish_holds()
		for pointer: Pointer in _pointers: _drop_tokens(pointer)
		canvas.rebuild(blueprint.graph)
		_schedule_rebuild()
		return
	if key == XREFeatureSettings.LINK_CREATE:
		for pointer: Pointer in _pointers:
			_hide_button(pointer)
			if not pointer.pull.is_empty(): _end_pull(pointer, false)
		_cancel_wire_menu()
		return
	if key in [XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ANIMATION_WAIT, XREFeatureSettings.VARIABLE_INPUT]:
		var features := _document.features
		if not canvas.set_parameter_modes(features.get_value(XREFeatureSettings.VALUE_INPUT), features.get_value(XREFeatureSettings.TARGET_INPUT),
				features.get_value(XREFeatureSettings.ANIMATION_WAIT), features.get_value(XREFeatureSettings.VARIABLE_INPUT)): return
		_finish_holds()
		_cancel_bends()
		for pointer: Pointer in _pointers: _drop_tokens(pointer)
		cancel_connection()
		_petals.close()
		canvas.rebuild(blueprint.graph)
		parameters.select_block(_selected)
		_update_tray()
		_schedule_rebuild()
		return
	var value := _document.features.get_value(key)
	var switched := false
	if key == XREFeatureSettings.NODE_DISPLAY: switched = canvas.set_display(value)
	elif key == XREFeatureSettings.NODE_STYLE:
		switched = canvas.set_style(value)
		# One Set in archetypes (D-102): the menu lists Set for both.
		block_menu.one_set = value == XREFeatureSettings.ARCHETYPES
	elif key == XREFeatureSettings.NODE_SHRINK: switched = canvas.set_shrink(value)
	elif key == XREFeatureSettings.NODE_HEADING: switched = canvas.set_heading(value)
	elif key == XREFeatureSettings.PORT_SHAPES: switched = canvas.set_port_shapes(value == XREFeatureSettings.ON)
	elif key == XREFeatureSettings.COMPOSITE_VALUES: switched = canvas.set_composite(value)
	elif key == XREFeatureSettings.PORT_DISPLAY: switched = canvas.set_port_display(value)
	elif key == XREFeatureSettings.CARD_PLUS: switched = canvas.set_plus_shown(value == XREFeatureSettings.SHOWN)
	elif key == XREFeatureSettings.WIRE_BENDS: switched = canvas.set_bends_shown(value == XREFeatureSettings.ON)
	elif key == XREFeatureSettings.BLOCK_COPY: switched = canvas.set_copy_shown(value == XREFeatureSettings.ON)
	if not switched: return
	_finish_holds()
	_cancel_bends()
	cancel_connection()
	canvas.rebuild(blueprint.graph)
	_schedule_rebuild()


func _graph_operation(operation: StringName, source: StringName, _time_usec: int) -> void:
	if source == &"vr_graph" or source == &"vr_panel":
		_document.record_graph_operation(operation, XREDocument.Source.TOOL if source == &"vr_graph" else XREDocument.Source.PANEL)
		_remember_graph_edit(operation)
	if _unsaved_host != null and blueprint.path.is_empty(): _save_new_graph.call_deferred()


## An edit of the graph made in the headset — its history went one action on —
## is a change of the headset's history (D-087): undo puts it back through the
## graph's history, as long as that is where the edit left it. Undo or redo of
## the graph's own from a window leaves the headset's changes of the graph behind.
func _remember_graph_edit(operation: StringName) -> void:
	var actions := blueprint.history
	if operation == &"undo" or operation == &"redo":
		if not _document.history.is_replaying(): _document.history.forget(XREHistory.Kind.GRAPH)
	elif actions.get_version() != _graph_version and actions.has_undo() and not actions.has_redo():
		var action := actions.get_current_action_name()
		_document.history.record(XREHistory.Kind.GRAPH, action.trim_prefix("Blueprints: "),
				_undo_graph_edit.bind(actions.get_version(), action), _redo_graph_edit.bind(actions.get_version(), action))
	_graph_version = actions.get_version()


## The graph's history changed. Past the headset — on the desktop, or emptied
## as another graph opened — the headset's changes of the graph can't be put back in turn.
func _graph_history_changed() -> void:
	var actions := blueprint.history
	var from_headset := blueprint.operation_source == &"vr_graph" or blueprint.operation_source == &"vr_panel"
	if _document.history.is_replaying(): _graph_version = actions.get_version()
	elif (not actions.has_undo() and not actions.has_redo()) or not from_headset:
		_document.history.forget(XREHistory.Kind.GRAPH)
		_graph_version = actions.get_version()


## Puts back the graph's edit [param action], made when its history came to [param version]: false if it moved since.
func _undo_graph_edit(version: int, action: String) -> bool:
	var actions := blueprint.history
	if actions.get_version() != version or actions.get_current_action_name() != action: return false
	actions.undo()
	_graph_version = actions.get_version()
	return true


## Makes the graph's edit [param action] again, if it is the graph's next to redo.
func _redo_graph_edit(version: int, action: String) -> bool:
	var actions := blueprint.history
	if actions.get_version() != version - 1 or not actions.has_redo() or actions.get_action_name(actions.get_current_action() + 1) != action: return false
	actions.redo()
	_graph_version = actions.get_version()
	return true


func _schedule_refresh() -> void:
	if _refresh_queued: return
	_refresh_queued = true
	_run_refresh.call_deferred()


func _run_refresh() -> void:
	_refresh_queued = false
	if is_inside_tree(): refresh_catalog()


func _schedule_rebuild() -> void:
	if _rebuild_queued: return
	_rebuild_queued = true
	_rebuild.call_deferred()


func _rebuild() -> void:
	_rebuild_queued = false
	if not is_inside_tree(): return
	for pointer: Pointer in _pointers:
		if pointer.held != null: _finish_hold(pointer, false)
	_cancel_bends()
	# A move or its undo keeps every card: rebuilding them all hitches on the headset.
	if not canvas.sync_placement(blueprint.graph): canvas.rebuild(blueprint.graph)
	_rebuild_target_wires()
	if _target_pick >= 0 and blueprint.graph.find_node(_target_pick).is_empty(): _target_pick = -1
	if _pending_id >= 0:
		if not canvas.has_port(_pending_id, _pending_port, _pending_input): cancel_connection()
		else: canvas.highlight_ports(canvas.port_type(_pending_id, _pending_port, _pending_input), not _pending_input)
	# A rebuild shows the token as the graph has it: the vector being edited is shown again (D-063).
	if _token_editor.mode == XREBlueprintTokenEditor.ARROWS and not _value_edit.is_empty(): _preview_value_edit(_value_edit["value"], str(_value_edit["expression"]))
	# The host may have changed: the badge goes over the new one.
	_update_badge()
	if not blueprint.scene_context_active(): _badge.show_message(blueprint.scene_context_message())
	changed.emit()


func _refresh_markers() -> void:
	for marker: Marker in _markers:
		remove_child(marker.visual)
		marker.visual.queue_free()
	_markers.clear()
	if not is_instance_valid(_root): return
	var pending: Array[Node] = [_root]
	while not pending.is_empty():
		var node: Node = pending.pop_back()
		for child: Node in node.get_children(): pending.append(child)
		var path := source_path(node)
		if path.is_empty(): continue
		var anchor := _anchor(node)
		if anchor == null: continue
		var marker := Marker.new()
		marker.host = node
		marker.anchor = anchor
		marker.path = path
		marker.visual = Node3D.new()
		add_child(marker.visual)
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.045, 0.045, 0.015)
		marker.visual.add_child(XRERig.create_vr_mesh(mesh, XREBlueprintCanvas.material(Color("5999bb"))))
		var title := XRERig.create_vr_label(24, 0.00065)
		title.text = path.get_file().trim_suffix(".tres")
		title.position.y = 0.05
		marker.visual.add_child(title)
		_markers.append(marker)


func _anchor(node: Node) -> Node3D:
	var current := node
	while current != null:
		if current is Node3D: return current as Node3D
		if current == _root: break
		current = current.get_parent()
	return null


func _collect_graphs(folder: String) -> void:
	for entry: String in _document.list_folder(folder):
		var path := folder.path_join(entry)
		if entry.ends_with("/"): _collect_graphs(path.trim_suffix("/"))
		elif entry.get_extension() == "tres" and ResourceLoader.load(path) is XREBlueprintGraph: _catalog.append(path)


func _new_path(host: Node) -> String:
	var folder := _root.scene_file_path.get_base_dir() if not _root.scene_file_path.is_empty() else "res://"
	if not source_folder.is_empty(): folder = source_folder
	var base := str(host.name).validate_filename().to_snake_case() + "_blueprint"
	var path := folder.path_join(base + ".tres")
	var index := 2
	while FileAccess.file_exists(path) or FileAccess.file_exists(path.get_basename() + ".generated.gd"):
		path = folder.path_join(base + "_%d.tres" % index)
		index += 1
	return path


func _open_owner_scene() -> void:
	if not blueprint.graph.scene_path.is_empty(): _document.open_scene(blueprint.graph.scene_path, XREDocument.Source.PANEL)


func _message(text: String) -> void:
	status = text
	if is_instance_valid(_badge): _badge.show_message(text)
	changed.emit()


func _build_block_menu(theme: Theme) -> void:
	block_menu = XREBlueprintActionMenu.new()
	block_menu.set_large(true)
	block_menu.offers_variables = true
	block_menu.one_set = canvas.get_style() == XREFeatureSettings.ARCHETYPES
	if theme != null: block_menu.theme = theme
	block_menu.action_chosen.connect(_add_from_menu)
	block_menu.action_dragged.connect(_drag_from_menu)
	block_menu.pin_cleared.connect(func() -> void: _menu_wire = {})
	block_menu.text_edit_requested.connect(_show_keyboard, CONNECT_DEFERRED)
	_forms_home.add_child(block_menu)


## Bends the graph's windows as the setting [constant XREFeatureSettings.WINDOW_SHAPE] says (D-043).
func _update_window_shape() -> void:
	var concave := _document.features.get_value(XREFeatureSettings.WINDOW_SHAPE) == XREFeatureSettings.CONCAVE
	for window: XREPanelSurface in _windows: window.set_curve_radius(XREPanels.CONCAVE_RADIUS if concave else 0.0)


## Opens the block menu beside card [param id], whose plus was clicked, and
## selects the card without opening its parameters (D-046); open ones stay,
## and the menu goes on their other side. The menu lists what can follow the
## card's first execution output and wires the block it adds to it (D-051).
func _show_block_palette(id: int, suggest: bool = true) -> void:
	cancel_connection()
	select_block(id, false)
	_menu_card = id
	_menu_at_point = false
	var pin := _exec_pin(id)
	_menu_wire = {"from": id, "from_port": pin["port"]} if not pin.is_empty() else {}
	block_menu.open(_menu_contexts(id), blueprint.get_host(), blueprint.graph, pin)
	_offer_blocks(canvas.plus_position(id), _request_window.bind(XREBlueprintPaletteTab, palette_pose(id)), suggest)


## Offers the blocks of the menu just opened (D-093): with [param suggest]
## and Next suggestions on, the likeliest next on petals at [param at]
## (global), with More… for the palette; else the palette itself
## ([method _show_palette]). [param window] opens its window where it belongs.
func _offer_blocks(at: Vector3, window: Callable, suggest: bool) -> void:
	_choice_anchor = at
	_choice_window = window
	if suggest and _document.features.get_value(XREFeatureSettings.NEXT_SUGGESTIONS) == XREFeatureSettings.ON:
		var stats := XREBlueprintStats.shared()
		stats.update(blueprint.graph)
		var items: Array[Dictionary] = []
		for action: Dictionary in block_menu.actions.suggest(block_menu.menu_context(), SUGGESTIONS, stats):
			items.append({"text": action["title"], "action": action, "origin": "suggestion", "enabled": true})
		if not items.is_empty():
			items.append({"text": "More…", "more": true, "enabled": true})
			_use_choice(_fan_choice)
			_fan_choice.open(canvas, at, _rig.camera.global_position, _rig.global_basis.y, [{"header": "", "items": items}])
			_choice_menu = true
			return
	_show_palette()


## The block palette of the menu open (D-093), as Block palette says: its
## window, or the ring of the task groups where the menu was opened from.
func _show_palette() -> void:
	if _document.features.get_value(XREFeatureSettings.BLOCK_PALETTE) != XREFeatureSettings.RING:
		_choice_menu = false
		_choice_window.call()
		return
	var stats := XREBlueprintStats.shared()
	stats.update(blueprint.graph)
	var groups := {}
	var tasks := block_menu.actions.by_task(block_menu.menu_context(), RING_BLOCKS, stats)
	for task: String in tasks:
		var items: Array[Dictionary] = []
		for action: Dictionary in tasks[task]: items.append({"text": action["title"], "action": action, "origin": "ring", "enabled": true})
		groups[task] = items
	_use_choice(_ring)
	# The object's groups on the arc are those it has whatever the wire (D-095): the ring keeps its shape for the object.
	var context := block_menu.menu_context()
	_ring.open_ring(canvas, _choice_anchor, _rig.camera.global_position, _rig.global_basis.y, groups, {"text": "Search…", "list": true, "enabled": true},
			block_menu.actions.object_tasks(context), str(context.get("label", "")))
	_choice_menu = true


## Makes [param fan] the choice at a point in use, closing the other (D-093); it is not the block menu's until that says so.
func _use_choice(fan: XREBlueprintPetals) -> void:
	if fan != _choice:
		_choice.close()
		_choice = fan
	_choice_menu = false


## A petal of the block menu's suggestions or ring picked (D-093): a group of
## the ring shows its blocks, More… the palette, the ring's middle the list;
## a block is added as the menu adds it.
func _choose_offered(item: Dictionary) -> void:
	if item.has("sector"):
		_ring.open_sector(int(item["sector"]))
		return
	# Where More… or Search… was clicked: the ring or the window opens there (D-094).
	var at := _choice.item_position(item)
	_choice.close()
	if item.has("more") and _document.features.get_value(XREFeatureSettings.BLOCK_PALETTE) == XREFeatureSettings.RING:
		_choice_anchor = at
		_show_palette()
		return
	_choice_menu = false
	if item.has("more") or item.has("list"):
		_show_window_at(at)
		return
	var action: Dictionary = (item["action"] as Dictionary).duplicate()
	action["origin"] = item["origin"]
	block_menu.actions.remember(action)
	_offered_at = at
	_add_from_menu(action)
	_offered_at = null


## Opens the block palette's window centered at [param at] (global), where
## More… or Search… was clicked (D-094), a little nearer the head: the ray is on it.
func _show_window_at(at: Vector3) -> void:
	var head := _rig.camera.global_position
	var point := at + (head - at).normalized() * PARAMETERS_LIFT
	_request_window(XREBlueprintPaletteTab, Transform3D(XREPanels.facing(point, head, _rig.global_basis.y), point))


## Whether the block menu of a wire let go is open — its window, the
## suggestions or the ring (D-094): the wire's end waits where it was let go.
func _dropped_menu_open() -> bool:
	return _menu_at_point and (is_block_palette_shown() or (_choice_menu and _choice.is_open()))


## A click off the open menu of a wire let go (D-094): the menu and the wire go.
func _cancel_dropped_wire() -> void:
	if is_block_palette_shown(): close_block_palette()
	if _choice_menu and _choice.is_open(): _choice.close()
	_choice_menu = false
	_menu_at_point = false
	_menu_wire = {}
	cancel_connection()
	_message("Wire cancelled.")


## The wire from a variable's box to workspace point [param point], or, while its menu is open, to where it was let go (D-094).
func _show_box_link(point: Vector3) -> void:
	canvas.show_link(_link_origin(), _menu_point if _dropped_menu_open() else point)


## The block menu's suggestions or ring closed without a block (D-093): the
## wire let go in empty space they were for goes too, as the menu's × takes it.
func _end_block_offer() -> void:
	_choice_menu = false
	if not _menu_at_point: return
	_menu_at_point = false
	_menu_wire = {}
	cancel_connection()
	_message("Wire cancelled.")


## The block palette as Block palette and Palette groups say (D-093): tiles
## over the list, chips by task. Suggestions or a ring open for the menu
## close: the next ones open as the settings say now.
func _update_palette_mode() -> void:
	var features := _document.features
	block_menu.set_tiles(features.get_value(XREFeatureSettings.BLOCK_PALETTE) == XREFeatureSettings.TILES)
	block_menu.set_task_groups(features.get_value(XREFeatureSettings.PALETTE_GROUPS) == XREFeatureSettings.TASKS)
	if _choice_menu and _choice.is_open():
		_choice.close()
		_end_block_offer()


## The keyboard for [param field]: in front of the user, or with [param at]
## below that point and in front of it, as at a token being typed into (D-052).
## With [param components] above 0 it is a keypad for a number or a vector of
## that many components (D-057). [param lead] is how far toward the head it
## comes from [param at], [param drop] how far below it; it is never nearer
## the head than [constant KEYBOARD_NEAREST] (D-063). [param at] may be a
## [Transform3D] too, or a [Callable] that makes one once the board has its
## size: the keyboard's pose itself ([method _keypad_below]).
func _show_keyboard(field: LineEdit, at: Variant = null, components: int = 0, lead: float = KEYBOARD_LEAD, drop: float = KEYBOARD_DROP) -> void:
	if not is_instance_valid(field) or not _workspace.visible: return
	_keyboard_target = weakref(field)
	# Opened first: the keypad is smaller than the letters (D-066), and the pose may take its size.
	if components > 0: _keyboard.open_number(field.text, components)
	else: _keyboard.open_text(field.text)
	if at is Callable: at = (at as Callable).call()
	if at is Transform3D:
		_keyboard.global_transform = at
		return
	var head := _rig.camera.global_position
	var upright := XREPanels.facing(head - _rig.camera.global_basis.z, head, Vector3.UP)
	var point := head - upright.z * 0.65 - Vector3.UP * 0.38
	if at is Vector3:
		# Below the token and well in front of the graph, toward the head, so that
		# the tilted board, whose top leans back, stays clear of the cards (D-057).
		upright = XREPanels.facing(at as Vector3, head, Vector3.UP)
		point = (at as Vector3) - Vector3.UP * drop + upright.z * lead
	var reach := point - head
	if reach.length() < KEYBOARD_NEAREST: point = head + reach.normalized() * KEYBOARD_NEAREST
	_keyboard.global_transform = Transform3D(upright * Basis(Vector3.RIGHT, -XREVirtualKeyboard.TILT), point)


func _apply_keyboard(text: String) -> void:
	var field := _keyboard_target.get_ref() as LineEdit if _keyboard_target != null else null
	if not is_instance_valid(field): return
	field.text = text
	field.text_changed.emit(field.text)
	field.text_submitted.emit(field.text)
	_keyboard_target = null


## XR-only scene veil, [param alpha] opaque. Its far depth separates world
## geometry from logic overlays. The launcher of the panels dims the scene
## with one too ([XREPanels]).
static func create_dimmer(alpha: float = 0.68, priority: int = Material.RENDER_PRIORITY_MAX - 2) -> MeshInstance3D:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_always, cull_disabled, fog_disabled;
void vertex() { POSITION = vec4(VERTEX.xy, 0.0, 1.0); }
uniform float alpha = 0.68;
void fragment() {
	ALBEDO = vec3(0.0);
	ALPHA = alpha;
	// Godot 4.7 uses reverse-Z, including Compatibility: far depth is zero.
	DEPTH = 0.0;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.render_priority = priority
	material.set_shader_parameter(&"alpha", alpha)
	var quad := QuadMesh.new()
	quad.size = Vector2(2, 2)
	var mesh := XRERig.create_vr_mesh(quad, material)
	mesh.name = "LogicSceneDimmer"
	mesh.position.z = -0.1
	mesh.extra_cull_margin = 10.0
	return mesh


func _set_ui_overlay(enabled: bool) -> void:
	for surface: XREPanelSurface in [_keyboard, _badge]: surface.set_overlay(enabled)
	_rig.left_hand.set_overlay(enabled)
	_rig.right_hand.set_overlay(enabled)


func _rebuild_target_wires() -> void:
	for wire: TargetWire in _target_wires:
		canvas.remove_scene_link(wire.canvas_wire)
		if wire.label != null:
			wire.label.queue_free()
			wire.stem.queue_free()
			wire.dot.queue_free()
	_target_wires.clear()
	if not blueprint.scene_context_active(): return
	var mode := _document.features.get_value(XREFeatureSettings.TARGET_INPUT)
	var scene_mode := XREBlueprintTokens.targets_in_scene(mode)
	for block: Dictionary in blueprint.graph.nodes:
		var id: int = block["id"]
		var port := XREBlueprintGraph.target_port(block)
		var source: bool = scene_mode and block["kind"] == "signal"
		if (port < 0 and not source) or blueprint.target_is_connected(id): continue
		var target := blueprint.target_node(id)
		if not is_instance_valid(target): continue
		var anchor := _anchor(target)
		if anchor == null: continue
		var wire := TargetWire.new()
		wire.id = id
		wire.port = port
		wire.target = target
		wire.anchor = anchor
		wire.source = source
		# The wire ends where its member was picked on the object (D-052), else at the object's origin.
		if block.get("vr_anchor") is Vector3 and anchor == target: wire.point = block["vr_anchor"]
		wire.canvas_wire = canvas.add_scene_link(block, XREBlueprintCanvas.COLORS[XREBlueprintGraph.OBJECT])
		wire.mesh = wire.canvas_wire.mesh
		wire.normal = wire.canvas_wire.normal
		wire.lit_material = wire.canvas_wire.lit
		# A link hides the wire, faint while drawn; its member is on the link, not on a petal (D-074).
		wire.link = scene_mode and XREBlueprintLinks.is_link(block, XREBlueprintLinks.TARGET)
		if wire.link: canvas.set_wire_seen(wire.canvas_wire, &"link", XREBlueprintCanvas.LINK_SEEN)
		var member_key := XREBlueprintTokens.member_key(block)
		if XREBlueprintTokens.member_on_stem(mode) and not member_key.is_empty() and not wire.link:
			# The member's petal, on a stem from the object, on the user's side of it;
			# unset, it says what to pick, and the trigger on it opens the object's petals (D-057).
			var member := str((block["params"] as Dictionary).get(member_key, ""))
			wire.label = XREBlueprintPetals.make_pill(member + " ▸" if not member.is_empty() else XREBlueprintTokens.member_placeholder(block), 1.0 if not member.is_empty() else 0.7)
			wire.width = float(wire.label.get_meta(&"width"))
			wire.label.top_level = true
			add_child(wire.label)
			var stick := CylinderMesh.new()
			# The stem is the wire's own tube from the object to its petal (D-058): same
			# colour and thickness, so the petal reads as joined to the object.
			stick.top_radius = 0.0022
			stick.bottom_radius = 0.0022
			stick.height = 1.0
			stick.radial_segments = 8
			var tube := XREBlueprintCanvas.wire_material(XREBlueprintCanvas.COLORS[XREBlueprintGraph.OBJECT])
			wire.stem = XRERig.create_vr_mesh(stick, tube)
			wire.stem.top_level = true
			add_child(wire.stem)
			var sphere := SphereMesh.new()
			sphere.radius = 0.007
			sphere.height = 0.014
			wire.dot = XRERig.create_vr_mesh(sphere, tube)
			wire.dot.top_level = true
			add_child(wire.dot)
			# Petals of several wires to one object stand one above the other, not in one place.
			var below := 0
			for other: TargetWire in _target_wires:
				if other.anchor == anchor and other.label != null: below += 1
			wire.offset = Vector3(0.0, 0.03 + below * (XREBlueprintPetals.PILL_HEIGHT + 0.014), 0.0)
			wire.bounds = XREPicker.get_local_bounds(anchor)
		_target_wires.append(wire)
	_update_target_wires()
	_fill_link_heads()


func _update_target_wires() -> void:
	for wire: TargetWire in _target_wires:
		var shown := _workspace.visible and blueprint.scene_context_active() and is_instance_valid(wire.target) and wire.target.is_inside_tree() and is_instance_valid(wire.anchor) and wire.anchor.is_inside_tree()
		# A link's wire only as Link wires says (D-074); a wire pulled into its port is the pull's preview meanwhile.
		if shown and wire.link: shown = canvas.link_wire_shown(wire.id)
		if shown and _is_pulled(wire.mesh): shown = false
		canvas.set_wire_shown(wire.canvas_wire, shown)
		if wire.label != null:
			wire.label.visible = wire.mesh.visible
			wire.stem.visible = wire.mesh.visible
			wire.dot.visible = wire.mesh.visible
		if not wire.mesh.visible: continue
		# Lit or darker with its card's focus, see-through out of it, its petal and stem too (D-072);
		# thicker on its port (D-061) and under a ray on the wire itself (D-081), every tube and knot of it.
		var state := canvas.focus_state(wire.id)
		var paint := canvas.focus_paint(state)
		canvas.light_wire(wire.canvas_wire, XREBlueprintFocus.variant(wire.lit_material if wire.lit or wire.hot or canvas.is_edge_lit(wire.canvas_wire.edge) else wire.normal, paint))
		canvas.raise_wire(wire.canvas_wire, paint == XREBlueprintFocus.TOP)
		var seen := canvas.focus_seen(state)
		var look := paint * 2 + (1 if seen < 1.0 else 0)
		if look != wire.look:
			wire.look = look
			canvas.set_wire_seen(wire.canvas_wire, &"focus", seen)
			if wire.label != null:
				for part: Node3D in [wire.label, wire.stem, wire.dot]:
					XREBlueprintFocus.paint(part, paint)
					XREBlueprintFade.set_seen(part, &"focus", seen)
		var end := wire.anchor.global_transform * wire.point
		if wire.label != null:
			# The wire ends at the member's petal; the petal hangs on its stem from the
			# point on the object, in a column above its front left corner as seen from
			# the head, one petal over another, so that the fan (to the right,
			# XREBlueprintPetals) never covers them. Farther than the fan's full-size
			# distance they keep their size in view, as the fan does.
			var head := _rig.camera.global_position
			var box := wire.anchor.global_transform * wire.bounds
			var base := box.get_center()
			var toward := head - base
			toward.y = 0.0
			toward = toward.normalized() if not toward.is_zero_approx() else Vector3.BACK
			var growth := clampf(base.distance_to(head) / XREBlueprintPetals.FULL_SIZE_DISTANCE, 1.0, XREBlueprintPetals.MAX_GROWTH)
			var shown_size := growth * (1.1 if wire.hot else 1.0)
			var left := toward.cross(Vector3.UP).normalized()
			var reach := maxf(box.size.x, box.size.z) * 0.5
			var pill := base + toward * reach + left * (reach + (0.02 + wire.width * 0.5) * growth) + Vector3.UP * (box.size.y * 0.5 + wire.offset.y * growth)
			var facing := XREBlueprintPetals.face(pill, head, Vector3.UP)
			wire.label.global_transform = Transform3D(facing * Basis.from_scale(Vector3.ONE * shown_size), pill)
			wire.dot.global_position = end
			var along := pill - end
			wire.stem.global_transform = Transform3D(Basis(Quaternion(Vector3.UP, along.normalized())) * Basis.from_scale(Vector3(1.0, maxf(along.length(), 0.001), 1.0)), end + along * 0.5)
			end = pill - facing.x * wire.width * 0.5 * growth
		# With an adapter in the port (D-059) the wire leaves the adapter's far end, a link's from its ring (D-074).
		var adapter_end: Variant = canvas.link_end(wire.id, XREBlueprintLinks.TARGET) if wire.link else canvas.adapter_end(wire.id)
		if adapter_end is Vector3: canvas.update_adapter_wire(wire.canvas_wire, wire.id, adapter_end as Vector3, canvas.to_local(end))
		elif wire.source: canvas.update_socket_wire(wire.canvas_wire, wire.id, XREBlueprintCanvas.SOURCE, canvas.to_local(end))
		else: canvas.update_scene_wire(wire.canvas_wire, wire.id, wire.port, canvas.to_local(end))


## The block a wire to the scene is drawn from: its Target port, or an event's Source.
func _scene_link_block() -> int:
	if _link_kind == XREBlueprintCanvas.SOURCE or _variable_set_link(): return _link_block
	return _pending_id


func _pending_scene_target() -> bool:
	if _pending_id < 0 or not _pending_input: return false
	var block := blueprint.graph.find_node(_pending_id)
	return not block.is_empty() and XREBlueprintGraph.target_port(block) == _pending_port


## A scene endpoint uses the existing target validation, relative path, history and telemetry.
func connect_scene_target(id: int, target: Node) -> bool:
	var block := blueprint.graph.find_node(id)
	if block.is_empty() or XREBlueprintGraph.target_port(block) < 0:
		_message("Choose a block with a Target port.")
		return false
	if not blueprint.scene_context_active():
		_message(blueprint.scene_context_message())
		return false
	if blueprint.target_is_connected(id):
		_message("Disconnect the dynamic Target before choosing a scene object.")
		return false
	var success: bool = blueprint.perform(blueprint.choose_target.bind(id, target), &"vr_graph")
	if success:
		cancel_connection()
		_message("Target connected to scene object.")
		_ask_member(id, target)
	else: _message(blueprint.last_error)
	return success


## After the Target is wired to [param target], a block that uses a member
## of it (a property, a signal, an animation) keeps the object's petals open
## and says to pick one (D-057): a Set Property comes with "visible", which is
## rarely the property wanted.
func _ask_member(id: int, target: Node) -> void:
	var block := blueprint.graph.find_node(id)
	if block.is_empty() or not target is Node3D or _member_role(block).is_empty(): return
	if XREBlueprintTokens.member_key(block).is_empty(): return
	var object := target as Node3D
	_open_petals(id, object, object.global_transform * (block["vr_anchor"] as Vector3 if block.get("vr_anchor") is Vector3 else Vector3.ZERO))
	_message("Now %s: point at a petal by %s and press trigger." % [XREBlueprintTokens.member_placeholder(block).trim_suffix(" ▸"), object.name])


func _update_scene_target_pointer(hand: XREHand, origin: Vector3, direction: Vector3) -> void:
	if not blueprint.scene_context_active():
		cancel_connection()
		_message(blueprint.scene_context_message())
		return
	hand.claim(self)
	var id := _scene_link_block()
	var target: Node
	var distance := 5.0
	var end := origin + direction * distance
	if _icons != null and _icons.cast_segment(origin, end):
		target = _icons.get_hit_node()
		distance = _icons.get_hit_distance()
	elif is_instance_valid(_root) and _picker.cast_segment(_root, origin, end):
		target = _picker.get_hit_node()
		distance = _picker.get_hit_distance()
	var point := origin + direction * distance
	hand.show_ray(distance, target != null)
	if _pending_hand == hand: _preview_connection(point)
	elif _link_kind == XREBlueprintCanvas.SOURCE or _variable_set_link(): canvas.show_socket_link(id, _link_kind, canvas.to_local(point))
	# With Targets on Scene the object under the ray shows the members this block can use (D-052).
	var block := blueprint.graph.find_node(id)
	if target is Node3D and XREBlueprintTokens.targets_in_scene(_document.features.get_value(XREFeatureSettings.TARGET_INPUT)) and not _member_role(block).is_empty():
		if _petals.get_object() != target or _petal_block != id or _petal_dynamic:
			_open_petals(id, target as Node3D, point)
			_message("%s: point at a petal and press trigger to wire the member; the stick or a drag scrolls." % target.name)
	if hand.trigger_pressed and target != null:
		if _variable_set_link(): _set_writes_property(id, target)
		elif _link_kind == XREBlueprintCanvas.SOURCE:
			if blueprint.perform(blueprint.set_target_member.bind(id, target, "", "", null, "Wire Member"), &"vr_graph"):
				cancel_connection()
				_message("Source connected to scene object.")
			else: _message(blueprint.last_error)
		else: connect_scene_target(id, target)
	elif hand.trigger_pressed and (_pending_hand == hand or _link_hand == hand):
		cancel_connection()
		_message("Wire cancelled.")


# --- Parameters as objects of the graph (D-052) ---------------------------------------------


## Whether parameter [param key] of [param block] is set in its parameters
## window: what the parameter settings don't take into the graph (D-052).
func shows_in_window(block: Dictionary, key: String) -> bool:
	var features := _document.features
	var values := features.get_value(XREFeatureSettings.VALUE_INPUT) == XREFeatureSettings.WINDOW
	var targets := features.get_value(XREFeatureSettings.TARGET_INPUT) == XREFeatureSettings.WINDOW
	if key == "target" or (key == XREBlueprintTokens.member_key(block) and not key.is_empty()): return targets
	if key == "variable": return features.get_value(XREFeatureSettings.VARIABLE_INPUT) == XREFeatureSettings.WINDOW
	if key == "wait" and XREBlueprintTokens.has_finished(block) and features.get_value(XREFeatureSettings.ANIMATION_WAIT) == XREFeatureSettings.FINISHED_PORT: return false
	return values


## Whether block [param id] has anything left for its parameters window.
func parameters_needed(id: int) -> bool:
	var block := blueprint.graph.find_node(id)
	if block.is_empty(): return false
	for key: String in block["params"]:
		if shows_in_window(block, key): return true
	return false


## Opens or closes the Tokens window as the settings say: with tokens and Token tray on.
func _update_tray() -> void:
	var wanted := _workspace.visible and _document.features.get_value(XREFeatureSettings.TOKEN_TRAY) == XREFeatureSettings.ON \
			and _document.features.get_value(XREFeatureSettings.VALUE_INPUT) != XREFeatureSettings.WINDOW
	if wanted and not XREBlueprintTokensTab in _open_windows: _request_window(XREBlueprintTokensTab, _tray_pose())
	elif not wanted and XREBlueprintTokensTab in _open_windows: _dismiss_window(XREBlueprintTokensTab, true)


## Where the Tokens window opens: left of where the graph's toolbar was (D-085), facing the head.
func _tray_pose() -> Transform3D:
	var point := _floating_ui.global_transform * Vector3(-0.75, -0.15, 0.05)
	return Transform3D(XREPanels.facing(point, _rig.camera.global_position, _rig.global_basis.y), point)


## The window that shows the token tray, or null while it is closed.
func _tray_window() -> XREPanelSurface:
	if not XREBlueprintTokensTab in _open_windows or not token_tray.is_inside_tree(): return null
	return token_tray.get_viewport().get_parent() as XREPanelSurface


## The tray's cell on the ray, [code]{"value", "key"}[/code], or empty.
func _tray_cell(origin: Vector3, direction: Vector3) -> Dictionary:
	var window := _tray_window()
	if window == null or window.intersect_ray(origin, direction, XREPanels.POINT_DISTANCE) < 0: return {}
	return token_tray.cell_at(window.get_hit_pixel())


## The trigger or the grip on a cell of the tray takes a copy of its token,
## held by that button until it is let go over a socket (D-055).
func _take_from_tray(pointer: Pointer, origin: Vector3, direction: Vector3) -> bool:
	var cell := _tray_cell(origin, direction)
	if cell.is_empty(): return false
	_leave(pointer)
	var by_trigger := pointer.hand.trigger_pressed and not pointer.hand.grip_pressed
	if XREBlueprintLinks.is_link_value(cell["value"]): _carry_link(pointer, cell["value"], {}, by_trigger)
	else: _carry(pointer, cell["value"], cell["key"], -1, true, by_trigger)
	return true


## Hangs a solid token in front of each cell of the tray while its window is
## open, as the Objects window has its miniatures (D-045, D-055): in the style
## of the value setting, dim where it doesn't fit the socket under the ray,
## hidden where the tray is scrolled away.
func _update_tray_tokens() -> void:
	var window := _tray_window()
	if window == null or not window.is_shown():
		if not _tray_tokens.is_empty():
			for token: Node3D in _tray_tokens: token.queue_free()
			_tray_tokens.clear()
			_tray_dirty = true
		return
	var values := token_tray.get_values()
	var plug := _value_mode() == XREFeatureSettings.PLUGS
	if _tray_dirty or _tray_tokens.size() != values.size() or (not _tray_tokens.is_empty() and _tray_tokens[0].get_meta(&"plug", false) != plug):
		for token: Node3D in _tray_tokens: token.queue_free()
		_tray_tokens.clear()
		for index: int in values.size():
			var key := token_tray.get_key(index)
			var token: Node3D
			if key == XREBlueprintLinks.KEY:
				# A link that stands for nothing yet, white (D-074); laid on a port it takes that port's wire, or asks for a box.
				token = XREBlueprintCanvas.make_link("link", XREBlueprintTokens.width("link"), XREBlueprintGraph.EXEC)
				token.set_meta(&"shift", float(token.get_meta(&"extent")) * 0.5)
			else:
				var width := XREBlueprintTokens.width(XREBlueprintTokens.text(values[index], key))
				token = XREBlueprintCanvas.make_token(values[index], key, width, plug, false, false)
				token.set_meta(&"shift", (XREBlueprintCanvas.PLUG_GAP + width) * 0.5 if plug else 0.0)
				token.set_meta(&"extent", XREBlueprintCanvas.PLUG_GAP + width + XREBlueprintCanvas.PORT_RADIUS if plug else width)
			token.top_level = true
			token.set_meta(&"plug", plug)
			add_child(token)
			_tray_tokens.append(token)
		_tray_dirty = false
	var basis := window.global_basis.orthonormalized()
	# Each token as large as its cell lets it (D-058): most of its width, half its height.
	var cell := token_tray.cell_rect(0).size * window.size_m.x / float(window.size_px.x) if not _tray_tokens.is_empty() else Vector2.ZERO
	for index: int in _tray_tokens.size():
		var token := _tray_tokens[index]
		token.visible = token_tray.is_cell_shown(index)
		if not token.visible: continue
		var scale := minf(cell.x * 0.85 / maxf(float(token.get_meta(&"extent")), 0.001), cell.y * 0.6 / XREBlueprintTokens.HEIGHT)
		var point := window.pixel_to_global(token_tray.cell_rect(index).get_center()) + basis.z * 0.01 + basis.x * float(token.get_meta(&"shift")) * scale
		token.global_transform = Transform3D(basis * Basis.from_scale(Vector3.ONE * scale), point)
		var fits := token_tray.cell_fits(index)
		if token.get_meta(&"fits", true) != fits:
			token.set_meta(&"fits", fits)
			# A token that doesn't fit fades but keeps its dark front (D-063): faded
			# whole, its front let its light sides through and hid its value.
			for child: Node in token.get_children():
				if child is Label3D: (child as Label3D).modulate.a = 1.0 if fits else 0.4
				elif child is GeometryInstance3D and not child.has_meta(&"face"): (child as GeometryInstance3D).transparency = 0.0 if fits else 0.7


## The ray on a card: its tokens, sockets, ports, plus and trash.
func _point_at_card(pointer: Pointer, origin: Vector3, direction: Vector3, hit: float) -> void:
	var hand := pointer.hand
	hand.claim(self)
	hand.show_ray(hit, true, XREBlueprintCanvas.HIT_DOT_OFFSET)
	var id := canvas.get_hit_id()
	var socket := canvas.get_hit_socket()
	var kind := canvas.get_hit_socket_kind()
	var key := canvas.get_hit_socket_key()
	var right := hand == _rig.right_hand
	# The card is in focus wherever on it the ray is; a port or a detail grows over that (D-072).
	pointer.focus = id
	if pointer.brushing: _brush_block(pointer, id)
	canvas.hover_actions(id, canvas.get_hit_plus(), canvas.get_hit_delete(), right, canvas.get_hit_port(), canvas.get_hit_input(), canvas.get_hit_edge() if _pending_id < 0 else -1, false, canvas.get_hit_copy())
	canvas.hover_socket(id, socket, right)
	var link := canvas.get_hit_link() if kind == XREBlueprintCanvas.LINK else {}
	_update_link_button(pointer, id, kind, link, origin + direction * hit)
	# The wire to the scene object thickens under the ray on its Target port,
	# its adapter or name, or the event's Source (D-061).
	var on_target: bool = kind in [XREBlueprintCanvas.MEMBER, XREBlueprintCanvas.SOURCE] or (not link.is_empty() and link["key"] == XREBlueprintLinks.TARGET)
	if not on_target and canvas.get_hit_port() >= 0 and canvas.get_hit_input():
		on_target = canvas.get_hit_port() == XREBlueprintGraph.target_port(blueprint.graph.find_node(id))
	if on_target:
		for wire: TargetWire in _target_wires:
			if wire.id == id: wire.lit = true
	var token := kind in [XREBlueprintCanvas.TOKEN, XREBlueprintCanvas.SQUARE]
	if token and canvas.token_value(id, key) != null and _token_editor.mode in [&"", XREBlueprintTokenEditor.HINT]:
		_token_editor.show_hint(_token_pose(id, key, ""), XREBlueprintTokens.hint(XREBlueprintTokens.kind_of(canvas.token_value(id, key), key)) + "  ·  grip: move")
		_hint_frame = Engine.get_process_frames()
	elif kind == XREBlueprintCanvas.MEMBER and not key.is_empty() and _token_editor.mode in [&"", XREBlueprintTokenEditor.HINT]:
		var at := canvas.to_global(canvas.socket_position(id, XREBlueprintCanvas.MEMBER))
		_token_editor.show_hint(Transform3D(XREPanels.facing(at, _rig.camera.global_position, _rig.global_basis.y), at), MEMBER_HINT)
		_hint_frame = Engine.get_process_frames()
	elif not link.is_empty() and _token_editor.mode in [&"", XREBlueprintTokenEditor.HINT]:
		var at := origin + direction * hit
		_token_editor.show_hint(Transform3D(XREPanels.facing(at, _rig.camera.global_position, _rig.global_basis.y), at), LINK_MENU_HINT if _wire_menu_on() else LINK_HINT)
		_hint_frame = Engine.get_process_frames()
	_filter_tray(id, socket, key if token else "")
	if not _member_link.is_empty() and _member_hand == hand:
		canvas.show_link(canvas.to_local(_member_link["anchor_global"]), canvas.to_local(origin + direction * hit))
		if hand.trigger_pressed: _connect_member_link(id)
		return
	if hand.grip_pressed:
		if token and _value_mode() != XREFeatureSettings.WINDOW:
			_carry(pointer, canvas.token_value(id, key), key, id, false)
		elif not link.is_empty(): _carry_link(pointer, _link_value(link, canvas.get_hit_link_value()), link)
		else: _start_hold(pointer, canvas, id, origin + direction * hit)
	elif hand.trigger_pressed:
		if canvas.get_hit_plus(): _show_block_palette(id)
		elif canvas.get_hit_delete(): delete_block(id)
		elif canvas.get_hit_copy(): _start_copy(id, hand, origin + direction * hit)
		elif canvas.get_hit_swap(): switch_heading(id)
		elif token and key == "policy" and canvas.get_style() == XREFeatureSettings.ARCHETYPES: _next_policy(id)
		elif token: _start_turn(pointer, id, key, "", origin + direction * hit)
		# With Wire menu the trigger on a link makes it its wire again, with no button (D-090).
		elif not link.is_empty() and _wire_menu_on(): _set_link(link, false)
		elif not link.is_empty(): _retarget_link(link, hand)
		elif kind == XREBlueprintCanvas.SOURCE: _start_link(id, XREBlueprintCanvas.SOURCE, hand)
		elif kind == XREBlueprintCanvas.VARIABLE:
			if _link_kind == XREBlueprintCanvas.VARIABLE and not _link_box.is_empty(): _wire_variable(id, _link_box)
			else: _start_link(id, XREBlueprintCanvas.VARIABLE, hand)
		elif kind == XREBlueprintCanvas.MEMBER: _open_member_petals(id, hand)
		elif canvas.get_hit_port() >= 0 and canvas.get_hit_input() and _link_kind == XREBlueprintCanvas.VARIABLE and not _link_box.is_empty() and _link_component >= 0:
			_wire_component_to_port(_link_box, _link_component, id, canvas.get_hit_port())
		elif canvas.get_hit_port() >= 0 and canvas.get_hit_input() and _link_kind == XREBlueprintCanvas.VARIABLE and not _link_box.is_empty() and _sets_target(id, canvas.get_hit_port()):
			_set_writes_variable(id, _link_box)
		elif canvas.get_hit_port() >= 0 and canvas.get_hit_input() and _link_kind == XREBlueprintCanvas.VARIABLE and not _link_box.is_empty():
			_wire_box_to_port(_link_box, id, canvas.get_hit_port())
		elif canvas.get_hit_port() >= 0:
			var finished := (1 if canvas.get_hit_finished() else 0) if canvas.get_hit_port() == 0 and not canvas.get_hit_input() and canvas.has_finished(id) else -1
			click_port(id, canvas.get_hit_port(), canvas.get_hit_input(), hand, canvas.get_hit_edge(), finished)
		elif _adds_blocks(pointer):
			toggle_block(id)
			_begin_block_brush(pointer, id, false)
		elif _brushes(): _begin_block_brush(pointer, id, true)
		else: select_block(id)
	if _deletes_now():
		_consume_delete()
		if token: _reset_token(id, key)
		# A link is a wire again (D-074): nothing of the reference is lost; with Always it stays a link (D-077).
		elif not link.is_empty():
			if not _links_only(): _set_link(link, false)
		# An archetype goes itself, as a box does (D-099); before, the selected block did.
		else: delete_block(id if canvas.get_style() == XREFeatureSettings.ARCHETYPES else -1)


## The ray on a wire while wires bend (D-081), as on an edge in draw.io: the
## wire thickens, and its knot under the ray grows, or a white knot marks
## where a bend would go. Trigger or grip takes that knot, or a new bend
## there, and drags it; the delete button takes the knot off, or all the
## wire's bends, and never the selected block.
func _point_at_wire(pointer: Pointer, hit: float) -> void:
	var hand := pointer.hand
	var right := hand == _rig.right_hand
	var edge := canvas.get_hit_wire()
	var bend := canvas.get_hit_bend()
	hand.claim(self)
	hand.show_ray(hit, true)
	canvas.hover_actions(-1, false, false, right, -1, false, edge)
	canvas.hover_socket(-1, -1, right)
	canvas.hover_bend(edge, bend, canvas.get_hit_wire_point(), right)
	pointer.wire_frame = Engine.get_process_frames()
	# With Link from wire on Wire menu the trigger opens the wire's menu (D-090); the grip still drags.
	if hand.trigger_pressed and _wire_menu_on() and _open_wire_menu(pointer, edge, bend, pointer.wire_ref):
		canvas.hover_bend(-1, -1, Vector3.ZERO, right)
	elif hand.trigger_pressed or hand.grip_pressed:
		_start_bend(pointer, edge, bend, hit, not hand.grip_pressed)
	elif _deletes_now():
		_consume_delete()
		_unbend(edge, bend)


## Takes bend [param bend] of the wire of graph edge [param edge] in
## [param pointer]'s hand, or adds one where its ray is on the wire with -1, on
## a rod as a far card's ([method _reel]); held by the trigger if
## [param by_trigger], otherwise by the grip. One hand drags a wire at a time.
func _start_bend(pointer: Pointer, edge: int, bend: int, hit: float, by_trigger: bool) -> void:
	for other: Pointer in _pointers:
		if other != pointer and other.bend_edge == edge: return
	var hand := pointer.hand
	var on_ray := hand.global_position - hand.global_basis.z.normalized() * hit
	var index := bend if bend >= 0 else canvas.insert_bend(edge, canvas.get_hit_piece(), canvas.get_hit_wire_point())
	if index < 0:
		_message("A wire takes at most %d bends." % XREBlueprintGraph.MAX_BENDS)
		return
	pointer.bend_edge = edge
	pointer.bend_index = index
	pointer.bend_new = bend < 0
	pointer.bend_trigger = by_trigger
	pointer.bend_start = canvas.to_global(canvas.get_hit_wire_point())
	pointer.bend_offset = pointer.bend_start - on_ray
	pointer.bend_moved = false
	pointer.distance = hit
	pointer.depth_uses_grip = _rig.has_grip_pose(hand)
	var physical := _rig.hand_pose(hand, pointer.depth_uses_grip).origin
	pointer.body_offset = _body_offset(physical)
	pointer.along = (_rig.global_basis.inverse() * -hand.global_basis.z).normalized()
	pointer.gain = maxf(_body_reach(on_ray) / maxf(_body_reach(physical), XREManipulator.MIN_REACH), 1.0)
	hand.claim(self)


## Drags the bend [param pointer] holds on its rod; let go, keeps it as one
## edit, Bend Wire, if it left the point it was taken at; a lost hand puts it back.
func _update_bend(pointer: Pointer) -> void:
	var hand := pointer.hand
	if not hand.get_has_tracking_data() or (pointer.depth_uses_grip and not _rig.has_grip_pose(hand)):
		_end_bend(pointer, false)
		return
	if not (hand.trigger_held if pointer.bend_trigger else hand.grip_held):
		_end_bend(pointer, true)
		return
	if _deletes_now():
		# The delete button takes off the knot in hand, as any knot, not the selected block.
		_consume_delete()
		var edge := pointer.bend_edge
		var index := pointer.bend_index
		var kept := not pointer.bend_new
		_end_bend(pointer, false)
		if kept: _unbend(edge, index)
		return
	_reel(pointer)
	var point := hand.global_position - hand.global_basis.z.normalized() * pointer.distance + pointer.bend_offset
	# A click is no drag: a bend not moved is not kept.
	if not pointer.bend_moved and point.distance_to(pointer.bend_start) > LINE_START: pointer.bend_moved = true
	if pointer.bend_moved: canvas.preview_bend(pointer.bend_edge, pointer.bend_index, canvas.to_local(point))
	hand.show_ray(pointer.distance, true)
	var right := hand == _rig.right_hand
	canvas.hover_actions(-1, false, false, right, -1, false, pointer.bend_edge)
	canvas.hover_bend(pointer.bend_edge, pointer.bend_index, Vector3.ZERO, right)
	pointer.wire_frame = Engine.get_process_frames()


## Lets go of the bend [param pointer] drags: kept in the graph if it moved
## and [param commit], otherwise the wire is drawn as the graph has it.
func _end_bend(pointer: Pointer, commit: bool) -> void:
	var edge := pointer.bend_edge
	pointer.bend_edge = -1
	pointer.bend_index = -1
	pointer.hand.show_ray(XREHand.RAY_LENGTH, false)
	pointer.hand.unclaim(self)
	if commit and pointer.bend_moved and canvas.commit_bends(blueprint, edge, "Bend Wire"): return
	canvas.reset_bends(blueprint.graph, edge)


## Puts back the bends being dragged, and closes the wire's menu (D-090): the graph or the canvas changes under them.
func _cancel_bends() -> void:
	for pointer: Pointer in _pointers:
		if pointer.bend_edge >= 0: _end_bend(pointer, false)
	_cancel_wire_menu()


## Takes bend [param bend] off the wire of graph edge [param edge], or all its
## bends with -1, as one edit: Remove Bend or Straighten Wire.
func _unbend(edge: int, bend: int) -> void:
	if canvas.bend_count(edge) == 0:
		_message("Drag the wire with trigger or grip to bend it.")
		return
	for pointer: Pointer in _pointers:
		if pointer.bend_edge == edge: return
	canvas.remove_bend(edge, bend)
	if not canvas.commit_bends(blueprint, edge, "Remove Bend" if bend >= 0 else "Straighten Wire"): canvas.reset_bends(blueprint.graph, edge)


## Adds a bend to the wire of graph edge [param edge] at [param point] (the
## canvas's space) on its piece [param piece], as one edit, Add Bend (D-090):
## the wire stays as it was, with a knot there that grip or trigger then drags.
func _add_bend(edge: int, piece: int, point: Vector3) -> void:
	for pointer: Pointer in _pointers:
		if pointer.bend_edge == edge: return
	if canvas.insert_bend(edge, piece, point) < 0:
		_message("A wire takes at most %d bends." % XREBlueprintGraph.MAX_BENDS)
		return
	if not canvas.commit_bends(blueprint, edge, "Add Bend"): canvas.reset_bends(blueprint.graph, edge)


# --- The wire's menu (D-090) ------------------------------------------------------------------


## Whether Link from wire is on Wire menu: the trigger on a wire opens its menu.
func _wire_menu_on() -> bool:
	return _document.features.get_value(XREFeatureSettings.LINK_CREATE) == XREFeatureSettings.WIRE_MENU


## Opens the wire's menu for [param pointer]'s hand, whose trigger went down
## on the canvas's wire [param edge] (-1 for a wire it doesn't bend), on its
## knot [param bend] or between knots with -1, the wire's link being
## [param ref] (empty if it may not become one): Link if it may, Point
## between knots, Delete point on one. Along the ray, as the object's shortcut
## (D-088), its center where the ray is. With one of them only there is no
## menu: Link is done at once (true); a bend or a knot is the trigger's to
## drag, as without the menu (false).
func _open_wire_menu(pointer: Pointer, edge: int, bend: int, ref: Dictionary) -> bool:
	if _wire_menu.is_open(): return false
	var items: Array[int] = []
	if not ref.is_empty(): items.append(WIRE_LINK)
	if edge >= 0: items.append(WIRE_UNBEND if bend >= 0 else WIRE_POINT)
	# One thing to do is done with no menu (D-090): a bend the trigger drags out of the wire or a
	# knot it drags, as without the menu (false); a link at once.
	if items.size() < 2:
		if items == [WIRE_LINK]: _set_link(ref, true)
		return items == [WIRE_LINK]
	var hand := pointer.hand
	var head := _rig.camera.global_position
	var center := hand.global_position - hand.global_basis.z.normalized() * XREObjectShortcut.DISTANCE
	_wire_menu.global_transform = Transform3D(XREPanels.facing(center, head, _rig.global_basis.y), center)
	_wire_menu_hand = hand
	_wire_menu_for = {"edge": edge, "bend": bend, "piece": canvas.get_hit_piece(), "point": canvas.get_hit_wire_point(), "ref": ref.duplicate()}
	_wire_menu.open("Point" if bend >= 0 else "Wire", items)
	_hide_button(pointer)
	hand.claim(self)
	return true


## Lights the button under the ray of the menu's hand; its trigger let go does
## it, or, on none, only closes the menu. A lost hand closes it.
func _update_wire_menu(pointer: Pointer) -> void:
	var hand := pointer.hand
	if not hand.get_has_tracking_data():
		_cancel_wire_menu()
		return
	hand.claim(self)
	var distance := _wire_menu.pick(hand)
	var picked := _wire_menu.get_lit()
	hand.show_ray(distance if distance >= 0.0 else XREHand.RAY_LENGTH, picked >= 0)
	pointer.focus = int((_wire_menu_for["ref"] as Dictionary).get("card", -1))
	if hand.trigger_held: return
	var target := _wire_menu_for
	_cancel_wire_menu()
	match picked:
		WIRE_LINK: _set_link(target["ref"], true)
		WIRE_POINT: _add_bend(int(target["edge"]), int(target["piece"]), target["point"])
		WIRE_UNBEND: _unbend(int(target["edge"]), int(target["bend"]))


## Closes the wire's menu without doing anything, and lets go of its hand.
func _cancel_wire_menu() -> void:
	if not _wire_menu.is_open(): return
	if _wire_menu_hand != null: _wire_menu_hand.unclaim(self)
	_wire_menu_hand = null
	_wire_menu_for = {}
	_wire_menu.close()


## Whether the wire's menu is open (D-090).
func is_wire_menu_open() -> bool:
	return _wire_menu.is_open()


## The button the ray is on in the wire's menu, one of WIRE_LINK, WIRE_POINT and WIRE_UNBEND, or -1.
func get_wire_menu_lit() -> int:
	return _wire_menu.get_lit()


## The center of button [param index] of the wire's menu, global.
func get_wire_menu_button(index: int) -> Vector3:
	return _wire_menu.get_button_position(index)


## Dims the tray's tokens that don't fit the socket under a ray, once it changes; empty [param key] for none.
func _filter_tray(id: int, socket: int, key: String) -> void:
	var hovered := Vector2i(id, socket) if not key.is_empty() else Vector2i(-1, -1)
	if hovered == _tray_socket: return
	_tray_socket = hovered
	if key.is_empty():
		token_tray.set_filter(Callable())
		return
	var block := blueprint.graph.find_node(id)
	token_tray.set_filter(func(value: Variant, token_key: String) -> bool:
		return XREBlueprintTokens.accepts(blueprint.graph, block, key, value) and (token_key == "policy") == (key == "policy"))


func _value_mode() -> StringName:
	return _document.features.get_value(XREFeatureSettings.VALUE_INPUT)


## Sets parameter [param key] of block [param id] to [param value] as one
## edit called [param title] for the log ("Turn Token", "Dock Token"…).
## Sets the token of [param key] on block [param id] to [param value] as one
## edit; [param expression] is the text it was typed as, kept to show (D-063),
## and any other way of setting it drops the one it had.
func _set_token(id: int, key: String, value: Variant, title: String, expression: String = "") -> bool:
	var state := blueprint.graph.snapshot()
	var found := false
	for block: Dictionary in state["nodes"]:
		if block["id"] == id and (block["params"] as Dictionary).has(key):
			block["params"][key] = value
			var kept: Dictionary = (block.get("expressions", {}) as Dictionary).duplicate()
			if expression.is_empty(): kept.erase(key)
			else: kept[key] = expression
			if kept.is_empty(): block.erase("expressions")
			else: block["expressions"] = kept
			found = true
	if not found: return false
	var success: bool = blueprint.perform(blueprint.commit.bind(title, state), &"vr_graph")
	if success and key != "wait": token_tray.remember(value)
	elif not success: _message(blueprint.last_error)
	return success


## A token taken out by the delete button: a port's socket is left empty (D-054), the build
## reports it until a token or a wire is back; a square socket gets its default.
func _reset_token(id: int, key: String) -> void:
	var block := blueprint.graph.find_node(id)
	if block.is_empty() or not (block["params"] as Dictionary).has(key): return
	# A port always has a token or a wire (D-059): A gives back the default token.
	if _set_token(id, key, _socket_default(block, key), "Reset Token"): _message("Back to the default value.")


## The trigger on a token, met by the ray at [param point]: a turn of the
## wrist edits a number or a choice while it is held, around a dial at the
## token; moving the ray off the token drags it, as the grip does.
func _start_turn(pointer: Pointer, id: int, key: String, box: String, point: Vector3) -> void:
	var value: Variant = canvas.token_value(id, key) if box.is_empty() else canvas.get_boxes().box_value(box)
	if value == null: return
	_token_editor.close()
	pointer.token_point = point
	pointer.token_distance = pointer.hand.global_position.distance_to(point)
	var pose := _token_pose(id, key, box)
	_token_editor.scale_mode = _document.features.get_value(XREFeatureSettings.AXIS_SCALE)
	match XREBlueprintTokens.kind_of(value, key):
		XREBlueprintTokens.NUMBER: _token_editor.open_dial(pose, value, XREBlueprintTokens.minimum(blueprint.graph.find_node(id), key, value))
		XREBlueprintTokens.CHOICE: _token_editor.open_choice(pose, XREBlueprintTokens.POLICIES, str(value))
	pointer.token_block = id
	pointer.token_key = key
	pointer.token_box = box
	pointer.token_value = value
	pointer.token_start = value
	pointer.token_basis = pointer.hand.global_basis
	pointer.token_angle = 0.0
	pointer.token_last = 0.0
	pointer.token_steps = 0
	pointer.token_recent = 0.0
	pointer.token_usec = Time.get_ticks_usec()
	pointer.token_stick = 0.0
	pointer.token_ray = 0
	pointer.token_line = false
	pointer.token_moved = false
	pointer.token_press_usec = Time.get_ticks_usec()
	pointer.hand.claim(self)
	pointer.hand.claim_stick(self)


## Turns the token by the wrist's roll since the press (D-052): a step every
## [constant XREBlueprintTokens.TURN_STEP], ten times as far when turned fast.
## Letting go commits a turn as one edit; a click without a turn toggles, steps
## a choice or opens the token's input.
func _update_turn(pointer: Pointer, delta: float) -> void:
	var hand := pointer.hand
	if not hand.get_has_tracking_data():
		_end_turn(pointer, false)
		return
	var key := pointer.token_key
	var kind := XREBlueprintTokens.kind_of(pointer.token_value, key)
	# The trigger never moves the token (D-061): the grip does. Held on a number
	# it shows the number line (D-062): the ray along it sets the value, past
	# its ends faster and faster; held on a choice, the ray on a value picks it.
	# The wrist and the stick step both.
	if kind in [XREBlueprintTokens.NUMBER, XREBlueprintTokens.CHOICE]:
		var roll := (pointer.token_basis.inverse() * hand.global_basis).get_euler().z
		var change := wrapf(roll - pointer.token_last, -PI, PI)
		pointer.token_last = roll
		pointer.token_angle += change
		# Fast is by real time over a tenth of a second, not by one frame's jump.
		var now := Time.get_ticks_usec()
		pointer.token_recent = pointer.token_recent * exp(-float(now - pointer.token_usec) / 100000.0) + absf(change)
		pointer.token_usec = now
		var steps := int(-pointer.token_angle / XREBlueprintTokens.TURN_STEP)
		# The thumbstick steps too, about six a second at full tilt: for those who don't turn the wrist.
		pointer.token_stick += XREPanels._tilt(hand.get_vector2(&"primary").x) * 6.0 * delta
		var pushed := int(pointer.token_stick)
		pointer.token_stick -= pushed
		if pushed != 0:
			pointer.token_angle -= pushed * XREBlueprintTokens.TURN_STEP
			steps += pushed
		var value: Variant = pointer.token_value
		if kind == XREBlueprintTokens.NUMBER:
			# Axis scale on Stick (D-069): the stick up and down makes the line finer or coarser.
			if _token_editor.scale_mode == XREFeatureSettings.STICK: _token_editor.zoom(XREPanels._tilt(hand.get_vector2(&"primary").y), delta)
			if steps != pointer.token_steps:
				value = _token_editor.nudge(steps - pointer.token_steps)
				pointer.token_steps = steps
			var across := _ray_across(pointer, hand)
			if not is_nan(across) and absf(across) > LINE_START: pointer.token_line = true
			if pointer.token_line and not is_nan(across): value = _token_editor.line_to(across, delta)
		else:
			var picked := _token_editor.choice_at(hand.global_position, -hand.global_basis.z.normalized())
			if picked >= 0: value = XREBlueprintTokens.POLICIES[picked]
			if steps != pointer.token_steps:
				value = XREBlueprintTokens.turned(value, key, steps - pointer.token_steps, false)
				pointer.token_steps = steps
		# Zero is as far as a non-negative number goes, a step above it a positive one (D-063).
		var least := XREBlueprintTokens.minimum(blueprint.graph.find_node(pointer.token_block), key, value)
		if not is_nan(least) and (value is float or value is int) and float(value) < least: value = int(least) if value is int else least
		if typeof(value) != typeof(pointer.token_value) or value != pointer.token_value:
			pointer.token_moved = true
			pointer.token_value = value
			if pointer.token_box.is_empty(): canvas.preview_token(pointer.token_block, key, value)
			else: canvas.get_boxes().preview_value(pointer.token_box, value)
			if kind == XREBlueprintTokens.CHOICE: _token_editor.set_choice(str(value), XREBlueprintTokens.POLICIES)
			_message("%s: %s" % [key.capitalize() if not key.is_empty() else pointer.token_box, XREBlueprintTokens.text(value, key)])
	if not hand.trigger_held: _end_turn(pointer, true)


## How far to the right, as seen from the head, the ray of [param hand] meets
## the plane of the token turned by [param pointer], from the point it was
## taken at, in meters; NAN off it: the number line's offset (D-062).
func _ray_across(pointer: Pointer, hand: XREHand) -> float:
	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	var head := _rig.camera.global_position
	var facing := XREPanels.facing(pointer.token_point, head, _rig.global_basis.y)
	var normal := facing.z.normalized()
	var toward := direction.dot(normal)
	if absf(toward) < 0.0001: return NAN
	var along := (pointer.token_point - origin).dot(normal) / toward
	if along < 0.0: return NAN
	return (origin + direction * along - pointer.token_point).dot(facing.x.normalized())


func _end_turn(pointer: Pointer, commit: bool) -> void:
	var id := pointer.token_block
	var key := pointer.token_key
	var box := pointer.token_box
	var value: Variant = pointer.token_value
	var start: Variant = pointer.token_start
	var turned := pointer.token_moved
	# Held, a number or a choice only shows its line or its values (D-063): a click types or steps.
	var clicked := Time.get_ticks_usec() - pointer.token_press_usec <= CLICK_USEC and not pointer.token_line
	pointer.token_key = ""
	pointer.token_box = ""
	pointer.token_block = -1
	pointer.hand.unclaim(self)
	pointer.hand.unclaim_stick(self)
	if _token_editor.mode in [XREBlueprintTokenEditor.DIAL, XREBlueprintTokenEditor.CHOICE]: _token_editor.close()
	if not commit:
		if box.is_empty(): canvas.preview_token(id, key, start)
		else: canvas.get_boxes().preview_value(box, start)
		return
	if turned:
		if typeof(value) == typeof(start) and value == start: return
		if box.is_empty(): _set_token(id, key, value, "Turn Token")
		else: _set_box(box, value, "Turn Token")
		return
	if not clicked and XREBlueprintTokens.kind_of(value, key) in [XREBlueprintTokens.NUMBER, XREBlueprintTokens.CHOICE]: return
	match XREBlueprintTokens.kind_of(value, key):
		XREBlueprintTokens.TOGGLE:
			if box.is_empty(): _set_token(id, key, not value, "Turn Token")
			else: _set_box(box, not value, "Turn Token")
		XREBlueprintTokens.CHOICE:
			_set_token(id, key, XREBlueprintTokens.turned(value, key, 1, false), "Turn Token")
		XREBlueprintTokens.COLOR:
			_open_color(id, key, box, value)
		XREBlueprintTokens.VECTOR:
			_open_vector(id, key, box, value)
			_message("Pull an arrow's end; stick ↑ finer, ↓ coarser. The white arrow moves all. Grip moves them; × closes." if _document.features.get_value(XREFeatureSettings.AXIS_SCALE) == XREFeatureSettings.STICK else "Pull an arrow's end; past its end it speeds up, held by its foot it goes to 0. The white arrow moves all. Grip moves them; × closes.")
		_:
			_open_token_keyboard(id, key, box, value)


## Sets the start value of variable [param name] from its box, keeping its
## type; [param expression] as for a token ([method _set_token]).
func _set_box(box: String, value: Variant, _title: String, expression: String = "") -> bool:
	var variable := blueprint.graph.find_variable(box)
	var type := XREBlueprintGraph.variable_type(variable)
	if variable.is_empty() or not XREBlueprintSchema.accepts(type, typeof(value)): return false
	if type == TYPE_FLOAT: value = float(value)
	var state := blueprint.graph.snapshot()
	for entry: Dictionary in state["variables"]:
		if entry["name"] != box: continue
		entry["value"] = value
		entry.erase("type")
		if expression.is_empty(): entry.erase("expression")
		else: entry["expression"] = expression
	var success: bool = blueprint.perform(blueprint.commit.bind("Set Variable Default", state), &"vr_graph")
	if not success: _message(blueprint.last_error)
	return success


## The keyboard for an exact value of a token (D-052).
func _open_token_keyboard(id: int, key: String, box: String, value: Variant) -> void:
	_token_edit = {"block": id, "key": key, "box": box, "value": value}
	_token_field.text = str(value) if not value is Color else (value as Color).to_html(false)
	if value is Vector2: _token_field.text = "%s, %s" % [(value as Vector2).x, (value as Vector2).y]
	if value is Vector3: _token_field.text = "%s, %s, %s" % [(value as Vector3).x, (value as Vector3).y, (value as Vector3).z]
	# Typed as an expression, it is edited as that (D-063).
	var expression := _expression_of(id, key, box)
	if not expression.is_empty(): _token_field.text = expression
	var components := 0
	match typeof(value):
		TYPE_INT, TYPE_FLOAT: components = 1
		TYPE_VECTOR2: components = 2
		TYPE_VECTOR3: components = 3
	_show_keyboard(_token_field, _token_pose(id, key, box).origin, components)


## Text typed for a token, or the name of a new variable.
func _token_text_submitted(text: String) -> void:
	var edit := _token_edit
	_token_edit = {}
	if edit.get("new_variable", false):
		_add_new_variable(edit, text.strip_edges())
		return
	if edit.is_empty(): return
	if edit.has("channel") or edit.has("hex"):
		_typed_color(edit, text)
		return
	if edit.has("axis"):
		# One component typed in the Vector window (D-062): the others stay, and
		# so does what each was typed as (D-063). Done keeps it all.
		var number: Variant = XREBlueprintTokens.parse_number(text)
		if number == null:
			_message("Not a number: " + text)
			return
		if _value_edit.is_empty(): return
		var axis := int(edit["axis"])
		var changed: Variant = _value_edit["value"]
		changed[axis] = float(number)
		_preview_value_edit(changed, _component_expression(axis, text.strip_edges()))
		return
	var parsed: Variant = _parse(text, edit["value"])
	if parsed == null:
		_message("Not a value of this type: " + text)
		return
	var like: Variant = edit["value"]
	var expression := text.strip_edges() if (like is float or like is Vector2 or like is Vector3) and XREBlueprintTokens.is_expression(text) else ""
	if str(edit["box"]).is_empty(): _set_token(edit["block"], edit["key"], parsed, "Type Token", expression)
	else: _set_box(edit["box"], parsed, "Type Token", expression)


## The expression the token of [param key] on block [param id], or the box of
## [param box], was typed as and still gives, or empty (D-063).
func _expression_of(id: int, key: String, box: String) -> String:
	if not box.is_empty(): return XREBlueprintTokens.variable_expression(blueprint.graph.find_variable(box))
	return XREBlueprintTokens.expression_of(blueprint.graph.find_node(id), key)


## [param text] as a value of [param like]'s type, or null.
static func _parse(text: String, like: Variant) -> Variant:
	var clean := text.strip_edges()
	match typeof(like):
		TYPE_BOOL:
			if clean.to_lower() in ["true", "1", "yes", "on"]: return true
			if clean.to_lower() in ["false", "0", "no", "off"]: return false
			return null
		TYPE_INT:
			if clean.is_valid_int(): return clean.to_int()
			var number: Variant = XREBlueprintTokens.parse_number(clean)
			return roundi(float(number)) if number != null else null
		TYPE_FLOAT: return XREBlueprintTokens.parse_number(clean)
		TYPE_COLOR: return Color.html(clean) if Color.html_is_valid(clean) else null
		TYPE_VECTOR2, TYPE_VECTOR3:
			var parts := clean.trim_prefix("(").trim_suffix(")").split(",", false)
			var count := 2 if like is Vector2 else 3
			if parts.size() != count: return null
			var numbers: Array[float] = []
			for part: String in parts:
				var number: Variant = XREBlueprintTokens.parse_number(part)
				if number == null: return null
				numbers.append(float(number))
			if count == 2: return Vector2(numbers[0], numbers[1])
			return Vector3(numbers[0], numbers[1], numbers[2])
	return clean


## Where a token is, facing the head: on block [param id]'s card, or on the box of [param box].
func _token_pose(id: int, key: String, box: String) -> Transform3D:
	var at := canvas.token_transform(id, key).origin if box.is_empty() else canvas.get_boxes().token_transform(box).origin
	return Transform3D(XREPanels.facing(at, _rig.camera.global_position, _rig.global_basis.y), at)


## The ray on the globe of colors or on the arrows of a vector (D-061,
## D-064): they light up; the trigger turns the globe or picks a color on it,
## or pulls an arrow. The trigger elsewhere closes them and goes on to what it
## is on, but not the hand that holds the pipette: it takes a color there (D-065).
func _point_at_editor(pointer: Pointer, origin: Vector3, direction: Vector3) -> bool:
	if not _token_editor.mode in [XREBlueprintTokenEditor.GLOBE, XREBlueprintTokenEditor.ARROWS] or _value_edit.is_empty(): return false
	var hand := pointer.hand
	var picked := _token_editor.pick(origin, direction)
	# Lit once a frame for both hands ([method _process]): the other hand's ray
	# off the widget must not put out what this one lights (D-059).
	if pointer.hand == _rig.right_hand: _editor_right = picked
	else: _editor_left = picked
	if picked.is_empty():
		# The keyboard typing one of the vector's components takes the click: the arrows stay (D-062).
		if _keyboard.is_shown() and _keyboard.intersect_ray(origin, direction, XREPanels.POINT_DISTANCE) >= 0: return false
		if hand.trigger_pressed and hand != _pipette_hand:
			if _token_editor.mode == XREBlueprintTokenEditor.ARROWS:
				_token_editor.close()
				_value_edit = {}
				_dismiss_window(XREBlueprintVectorTab, true)
			else: _end_color(false)
		return false
	_leave(pointer)
	hand.claim(self)
	hand.show_ray(float(picked["distance"]), true)
	canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
	canvas.hover_socket(-1, -1, hand == _rig.right_hand)
	# They move with their window: the grip on them takes the window (D-061).
	if hand.grip_pressed:
		var window := _vector_window() if _token_editor.mode == XREBlueprintTokenEditor.ARROWS else _color_window()
		if window != null: _hold_window(pointer, window, -1, false)
		return true
	if not hand.trigger_pressed: return true
	if picked.has("globe"):
		pointer.globe_drag = true
		pointer.globe_moved = false
		pointer.globe_pick = picked["globe"]
		pointer.globe_start = _token_editor.globe_plane_point(origin, direction)
		pointer.globe_turn = _token_editor.get_globe_turn()
		return true
	var value: Variant = _value_edit["value"]
	if picked.has("axis"):
		pointer.arrow_axis = picked["axis"]
		pointer.arrow_value = value
		pointer.arrow_block = _value_edit["block"]
		pointer.arrow_key = _value_edit["key"]
		pointer.arrow_box = _value_edit["box"]
		pointer.arrow_reach = 0.0
		# The stick is the pull's while it lasts: it scales the arrows, not turns the user (D-069).
		hand.claim_stick(self)
		if pointer.arrow_axis == XREBlueprintTokenEditor.VECTOR_AXIS:
			# The white arrow's tip goes with the hand, at the distance the ray met it.
			pointer.arrow_distance = float(picked["distance"])
			pointer.arrow_grab = origin + direction * pointer.arrow_distance
			_token_editor.begin_pull(XREBlueprintTokenEditor.VECTOR_AXIS, pointer.arrow_grab)
		else:
			pointer.arrow_start = _token_editor.axis_offset(pointer.arrow_axis, origin, direction)
			_token_editor.begin_pull(pointer.arrow_axis)
	return true


## The trigger held on the globe (D-064): the ray moved across it turns it, as
## a ball rolled by its surface — about its axis left and right, toward the
## user up and down. Let go without a turn, it is a click: the color where the
## ray took the globe.
func _update_globe(pointer: Pointer) -> void:
	var hand := pointer.hand
	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	var at := _token_editor.globe_plane_point(origin, direction)
	if not is_nan(at.x) and not is_nan(pointer.globe_start.x):
		var moved := at - pointer.globe_start
		if moved.length() > GLOBE_CLICK: pointer.globe_moved = true
		if pointer.globe_moved:
			var radius := _token_editor.globe_radius()
			_token_editor.turn_globe(pointer.globe_turn.x + moved.x / radius, pointer.globe_turn.y - moved.y / radius)
	# On the globe's face toward the hand, not at its center (D-066).
	hand.show_ray(maxf(origin.distance_to(_token_editor.global_position) - _token_editor.globe_radius(), 0.01), true)
	if hand.trigger_held and hand.get_has_tracking_data(): return
	pointer.globe_drag = false
	hand.unclaim(self)
	if pointer.globe_moved or not hand.get_has_tracking_data() or _value_edit.is_empty(): return
	_preview_color(_token_editor.globe_color(pointer.globe_pick.x, pointer.globe_pick.y))
	_message("Picked %s. Done keeps it." % _color_text(_value_edit["value"] as Color))


## Pulls an arrow of a vector token by its end (D-060): the arrow grows or
## shrinks with the ray along its axis and its component follows; held past its
## longest or shortest the component goes on, faster and faster. The white
## arrow's tip goes with the hand and changes every component. A click on an
## axis arrow without a pull sets its component to 0. Let go: one edit.
func _update_arrow(pointer: Pointer, delta: float) -> void:
	var hand := pointer.hand
	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	var value: Variant
	# Axis scale on Stick (D-069): the stick up and down makes the arrows' scale finer or coarser.
	if _token_editor.scale_mode == XREFeatureSettings.STICK: _token_editor.zoom(XREPanels._tilt(hand.get_vector2(&"primary").y), delta)
	if pointer.arrow_axis == XREBlueprintTokenEditor.VECTOR_AXIS:
		var point := origin + direction * pointer.arrow_distance
		pointer.arrow_reach = maxf(pointer.arrow_reach, point.distance_to(pointer.arrow_grab))
		value = _token_editor.move_to(point, delta)
	else:
		var pulled := _token_editor.axis_offset(pointer.arrow_axis, origin, direction) - pointer.arrow_start
		pointer.arrow_reach = maxf(pointer.arrow_reach, absf(pulled))
		value = _token_editor.pull_to(pointer.arrow_axis, pulled, delta)
	# The ray ends on the end of the arrow it pulls (D-066), not at the arrows' foot or past them.
	hand.show_ray(maxf((_token_editor.tip_position(pointer.arrow_axis) - origin).dot(direction), 0.01), true)
	if pointer.arrow_box.is_empty(): canvas.preview_token(pointer.arrow_block, pointer.arrow_key, value)
	else: canvas.get_boxes().preview_value(pointer.arrow_box, value)
	_message("%s: %s" % [key_name(pointer.arrow_axis), XREBlueprintTokens.text(value, pointer.arrow_key)])
	vector_panel.set_vector(value)
	if hand.trigger_held and hand.get_has_tracking_data(): return
	var axis := pointer.arrow_axis
	pointer.arrow_axis = -1
	hand.unclaim(self)
	hand.unclaim_stick(self)
	if axis != XREBlueprintTokenEditor.VECTOR_AXIS and pointer.arrow_reach <= 0.005: value = _token_editor.zero(axis)
	# Kept only by Done (D-063): until then the token just shows it.
	if not hand.get_has_tracking_data() or value == pointer.arrow_value:
		_preview_value_edit(pointer.arrow_value, str(_value_edit.get("expression", "")))
		return
	_preview_value_edit(value, "")


## What arrow [param axis] of a vector edits, for the status line.
static func key_name(axis: int) -> String:
	return "Vector" if axis == XREBlueprintTokenEditor.VECTOR_AXIS else ["X", "Y", "Z"][clampi(axis, 0, 2)]


## Opens the Vector window (D-061) for the vector token of [param key] on
## block [param id], or of the box of [param box]: in front of the token,
## toward the head, with the arrows of [param value] in front of the window.
func _open_vector(id: int, key: String, box: String, value: Variant) -> void:
	var expression := _expression_of(id, key, box)
	_value_edit = {"block": id, "key": key, "box": box, "value": value, "expression": expression, "start": value, "start_expression": expression}
	var pose := _near_pose(_token_pose(id, key, box).origin)
	var block := blueprint.graph.find_node(id)
	vector_panel.show_vector("%s · %s" % [box if not box.is_empty() else XREBlueprintGraph.title(block), key.capitalize() if box.is_empty() else "start value"], value, expression)
	_request_window(XREBlueprintVectorTab, pose)
	_token_editor.scale_mode = _document.features.get_value(XREFeatureSettings.AXIS_SCALE)
	_token_editor.open_arrows(pose, 2 if value is Vector2 else 3, value)
	_place_window_widgets()


## Where the Vector or the Color window opens for a token at [param at]
## (D-064): [constant NEAR_DISTANCE] from the head toward it, at least
## [constant NEAR_DOWN_LEAST] and at most [constant NEAR_DOWN_MOST] below the
## eyes, tilted to face the head.
func _near_pose(at: Vector3) -> Transform3D:
	var head := _rig.camera.global_position
	var up := _rig.global_basis.y.normalized()
	var toward := at - head
	var flat := toward - up * toward.dot(up)
	if flat.length() < 0.001:
		flat = -_rig.camera.global_basis.z
		flat -= up * flat.dot(up)
	var down := clampf(atan2(-toward.dot(up), flat.length()), NEAR_DOWN_LEAST, NEAR_DOWN_MOST)
	var point := head + (flat.normalized() * cos(down) - up * sin(down)) * NEAR_DISTANCE
	return Transform3D(Basis.looking_at(point - head, up), point)


## The Vector window, or null while it is closed.
func _vector_window() -> XREPanelSurface:
	if not XREBlueprintVectorTab in _open_windows or not vector_panel.is_inside_tree(): return null
	return vector_panel.get_viewport().get_parent() as XREPanelSurface


## Keeps the arrows in front of the Vector window, the globe in front of the
## Color window, wherever it is moved, pinned or carried; without the window they close.
func _place_window_widgets() -> void:
	if not _token_editor.mode in [XREBlueprintTokenEditor.ARROWS, XREBlueprintTokenEditor.GLOBE]: return
	var arrows := _token_editor.mode == XREBlueprintTokenEditor.ARROWS
	var window := _vector_window() if arrows else _color_window()
	if window == null:
		if not (XREBlueprintVectorTab if arrows else XREBlueprintColorTab) in _open_windows:
			_token_editor.close()
			_value_edit = {}
		return
	var facing := window.global_basis.orthonormalized()
	var center := window.pixel_to_global((vector_panel if arrows else color_panel).area_center())
	if arrows:
		_token_editor.place(center + facing.z * 0.03, facing)
		return
	# The window stands upright, below the eyes; the globe faces the head itself,
	# so that its front, where its color is turned to, is the middle of what is seen.
	var at := center + facing.z * _token_editor.globe_radius() * 0.5
	var toward := _rig.camera.global_position - at
	_token_editor.place(at, Basis.looking_at(-toward, _rig.global_basis.y) if toward.length() > 0.001 else facing)


## A trigger pressed with the ray off the input in use closes that input
## (D-062): the Vector window and its arrows, the Color window, the keyboard, the
## petals of an adapter's member. The click then goes on to what it is on.
func _close_on_click_away() -> void:
	# Focused since the last frame: the click that opened an input doesn't close it.
	if not _focused or not is_focused(): return
	for hand: XREHand in [_rig.left_hand, _rig.right_hand]:
		# The pipette's clicks take colors anywhere (D-065).
		if not hand.trigger_pressed or not hand.get_has_tracking_data() or hand == _pipette_hand: continue
		var origin := hand.global_position
		var direction := -hand.global_basis.z.normalized()
		if _on_input(origin, direction): continue
		_close_inputs()
		for pointer: Pointer in _pointers:
			if pointer.hand == hand: pointer.swallow = true
		return


## Whether the ray from [param origin] along [param direction] is on the input in use.
func _on_input(origin: Vector3, direction: Vector3) -> bool:
	if _keyboard.is_shown() and (_keyboard.intersect_ray(origin, direction, XREPanels.POINT_DISTANCE) >= 0 or _keyboard.intersect_handle(origin, direction, XREPanels.POINT_DISTANCE) >= 0): return true
	if _token_editor.is_interactive() and not _token_editor.pick(origin, direction).is_empty(): return true
	for window: XREPanelSurface in [_vector_window(), _color_window()]:
		if window != null and (window.intersect_ray(origin, direction, XREPanels.POINT_DISTANCE) >= 0 or window.intersect_handle(origin, direction, XREPanels.POINT_DISTANCE) >= 0): return true
	if _petals.is_open() and _petals.intersect_ray(origin, direction, XREPanels.POINT_DISTANCE) >= 0: return true
	if _choice.is_open() and _choice.intersect_ray(origin, direction, XREPanels.POINT_DISTANCE) >= 0: return true
	# The dial and the choice of a token live only while the trigger holds them.
	return _token_editor.mode in [XREBlueprintTokenEditor.DIAL, XREBlueprintTokenEditor.CHOICE]


## Closes the inputs in use: the arrows and their window, the Color window
## and its globe, the keyboard (its draft lost), a member's petals with no
## wire waiting on them.
func _close_inputs() -> void:
	if _editing_color(): _end_color(false)
	elif _token_editor.mode == XREBlueprintTokenEditor.ARROWS: _end_vector(false)
	elif _token_editor.is_interactive():
		_token_editor.close()
		_value_edit = {}
	if _keyboard.is_shown():
		_keyboard.close()
		_token_edit = {}
	if _petals.is_open() and _petal_block >= 0 and _pending_id < 0 and _link_hand == null:
		cancel_connection()
		_petals.close()
	elif _choice.is_open() and _member_link.is_empty():
		_choice.close()
		# The block menu's suggestions or ring go with the wire they were for (D-093).
		if _choice_menu: _end_block_offer()
	_cancel_wire_menu()


## Whether an input has the user's attention (D-061): a value's widget, the
## keyboard, or the petals of a member being picked, or a choice, or the wire's menu (D-090).
func is_focused() -> bool:
	if not _workspace.visible: return false
	if _token_editor.mode in [XREBlueprintTokenEditor.DIAL, XREBlueprintTokenEditor.CHOICE, XREBlueprintTokenEditor.GLOBE, XREBlueprintTokenEditor.ARROWS]: return true
	if _editing_color(): return true
	if _keyboard.is_shown() or _choice.is_open() or _wire_menu.is_open(): return true
	return _petals.is_open() and (_petal_block >= 0 or _petal_dynamic)


## Darkens all but the input in use, and draws that input and the rays over the darkness.
func _update_focus() -> void:
	var focus := is_focused()
	var vector_window := _vector_window()
	if vector_window != null and vector_window.is_on_top() != focus: vector_window.set_on_top(focus)
	var color_window := _color_window()
	if color_window != null and color_window.is_on_top() != focus: color_window.set_on_top(focus)
	if focus == _focused: return
	_focused = focus
	# The scene's objects that may cover the input are gathered once, as it opens (D-066).
	if focus: _fade.gather(_root)
	else:
		_fade.release()
		canvas.fade_covering(_rig.camera.global_position, _focus_targets, 0)
	_focus_dimmer.visible = focus
	_petals.set_on_top(focus and (_petal_block >= 0 or _petal_dynamic))


## Makes what covers the input in use see-through (D-066), every frame while
## one is in focus: the scene's objects, cards, wires and boxes nearer the head
## than the input and in front of it. Only what changes is touched.
func _update_fade() -> void:
	if not _focused: return
	var count := _add_target(0, _token_editor.focus_sphere())
	if _petal_block >= 0 or _petal_dynamic: count = _add_target(count, _petals.focus_sphere())
	count = _add_target(count, _choice.focus_sphere())
	count = _add_window(count, _keyboard)
	count = _add_window(count, _vector_window())
	count = _add_window(count, _color_window())
	var eye := _rig.camera.global_position
	canvas.fade_covering(eye, _focus_targets, count)
	_fade.update(eye, _focus_targets, count)


## Puts in focus what the rays are on (D-072): a card, a member's petal of a
## card on its object, a variable's box; a card held and the card or box a
## wire is drawn from stay in focus too. Gone off the graph, a ray keeps its
## focus for [constant FOCUS_HOLD]. While an input is in use (D-061) the focus
## stays as it was when it opened: the rays are on the input, not the graph,
## and the rest of the graph stays darker or see-through under its dimmer.
## The canvas paints only what changes.
func _update_graph_focus(delta: float) -> void:
	if is_focused():
		_focus_hold = FOCUS_HOLD
		return
	var cards := Vector3i(-1, -1, -1)
	var box := ""
	var other_box := ""
	var pointed := false
	if _workspace.visible:
		cards.x = _pointers[0].focus
		cards.y = _pointers[1].focus
		box = _pointers[0].focus_box
		other_box = _pointers[1].focus_box
		pointed = cards.x >= 0 or cards.y >= 0 or not box.is_empty() or not other_box.is_empty()
		cards.z = _pending_id if _pending_id >= 0 else _link_block if _link_kind >= 0 else -1
		if other_box.is_empty() and _link_kind >= 0: other_box = _link_box
	if pointed: _focus_hold = FOCUS_HOLD
	elif _focus_hold > 0.0 and _workspace.visible:
		_focus_hold -= delta
		return
	canvas.set_focus(cards, box, other_box)


func _add_window(count: int, surface: XREPanelSurface) -> int:
	if surface == null or not surface.is_shown() or not surface.is_on_top(): return count
	var center := surface.global_position
	return _add_target(count, Vector4(center.x, center.y, center.z, surface.size_m.length() * 0.5))


func _add_target(count: int, sphere: Vector4) -> int:
	if sphere.w <= 0.0 or count >= _focus_targets.size(): return count
	_focus_targets[count] = sphere
	return count + 1


## The scene's fading of what covers an input (D-066), for the tests.
func get_fade() -> XREBlueprintFade:
	return _fade


## The keypad for one component [param axis] of the vector in the Vector
## window (D-062), below the window: the rare exact value of one axis.
func _type_component(axis: int) -> void:
	if _value_edit.is_empty() or _token_editor.mode != XREBlueprintTokenEditor.ARROWS: return
	var value: Variant = _value_edit["value"]
	_token_edit = {"block": _value_edit["block"], "key": _value_edit["key"], "box": _value_edit["box"], "value": value, "axis": axis}
	var typed := XREBlueprintTokens.component_expression(str(_value_edit.get("expression", "")), axis)
	_token_field.text = typed if not typed.is_empty() else XREBlueprintTokens.text(float(value[axis]), "")
	_show_keyboard(_token_field, _keypad_at(_vector_window()), 1)
	_message("Type %s; π, e, √, ^ and brackets work: 3π, π/2, √2." % ["X", "Y", "Z"][axis])


## Where the keypad for a figure of [param window] goes ([method _keypad_below]); null without the window.
func _keypad_at(window: XREPanelSurface) -> Variant:
	return _keypad_below.bind(window) if window != null else null


## The keypad of a figure of [param window] (D-067, after D-066 put it beside):
## low on the window, over the buttons under the figures, its top edge
## [constant KEYPAD_TOP] down it, just nearer the head than the window, and
## square to the line of sight, neither tilted back nor turned to a hand. Below
## the window (D-063) the head bent far down; beside it the keys were aslant to the eyes.
func _keypad_below(window: XREPanelSurface) -> Transform3D:
	var head := _rig.camera.global_position
	var up := _rig.global_basis.y.normalized()
	var distance := maxf(head.distance_to(window.global_position) - KEYPAD_LEAD, KEYBOARD_NEAREST)
	var top := window.pixel_to_global(Vector2(window.size_px.x * 0.5, window.size_px.y * KEYPAD_TOP))
	top = head + (top - head).normalized() * distance
	var center := top - _square(top, head, up).y * _keyboard.size_m.y * 0.5
	center = head + (center - head).normalized() * distance
	return Transform3D(_square(center, head, up), center)


## A basis at [param point] whose front (+Z) looks straight at [param head], upright along [param up].
static func _square(point: Vector3, head: Vector3, up: Vector3) -> Basis:
	var away := point - head
	if away.length() < 0.001 or absf(away.normalized().dot(up)) > 0.99: return XREPanels.facing(point, head, up)
	return Basis.looking_at(away, up)


## The small 0 by component [param axis] in the Vector window (D-063): that component is 0.
func _zero_component(axis: int) -> void:
	if _value_edit.is_empty() or _token_editor.mode != XREBlueprintTokenEditor.ARROWS: return
	var changed: Variant = _value_edit["value"]
	changed[axis] = 0.0
	_preview_value_edit(changed, _component_expression(axis, "0"))
	_message("%s is 0." % ["X", "Y", "Z"][axis])


## The vector's expression with component [param axis] typed as [param text]
## and the others as they were typed or are; empty when all are plain numbers.
func _component_expression(axis: int, text: String) -> String:
	var value: Variant = _value_edit["value"]
	var before := str(_value_edit.get("expression", ""))
	var parts: PackedStringArray = []
	for index: int in (2 if value is Vector2 else 3):
		var kept := XREBlueprintTokens.component_expression(before, index)
		parts.append(kept if not kept.is_empty() else XREBlueprintTokens.plain(float(value[index])))
	parts[axis] = text
	var joined := ", ".join(parts)
	return joined if XREBlueprintTokens.is_expression(joined) else ""


## Shows [param value] (typed as [param expression], or empty) on the token
## the Vector window edits, on its arrows and in its figures, without keeping
## it: Done keeps it ([method _end_vector], D-063).
func _preview_value_edit(value: Variant, expression: String) -> void:
	if _value_edit.is_empty(): return
	_value_edit["value"] = value
	_value_edit["expression"] = expression
	var shown := XREBlueprintTokens.shown(value, str(_value_edit["key"]), expression)
	if str(_value_edit["box"]).is_empty(): canvas.preview_token(_value_edit["block"], _value_edit["key"], value, shown)
	else: canvas.get_boxes().preview_value(_value_edit["box"], value, shown)
	_token_editor.set_vector(value)
	vector_panel.set_vector(value, expression)


## Ends the Vector window's edit (D-063): Done keeps the vector as one edit,
## the ×, a click away or the window closing put it back as it was.
func _end_vector(commit: bool) -> void:
	if _value_edit.is_empty() or _token_editor.mode != XREBlueprintTokenEditor.ARROWS:
		if _token_editor.mode == XREBlueprintTokenEditor.ARROWS: _token_editor.close()
		_dismiss_window(XREBlueprintVectorTab, true)
		return
	var edit := _value_edit
	_value_edit = {}
	_token_editor.close()
	if _keyboard.is_shown() and _token_edit.has("axis"):
		_keyboard.close()
		_token_edit = {}
	var value: Variant = edit["value"]
	var expression := str(edit["expression"])
	var changed: bool = value != edit["start"] or expression != str(edit["start_expression"])
	if commit and changed:
		if str(edit["box"]).is_empty(): _set_token(edit["block"], edit["key"], value, "Set Vector", expression)
		else: _set_box(edit["box"], value, "Set Vector", expression)
		_message("Kept %s." % XREBlueprintTokens.shown(value, str(edit["key"]), expression))
	else:
		var start: Variant = edit["start"]
		var shown := XREBlueprintTokens.shown(start, str(edit["key"]), str(edit["start_expression"]))
		if str(edit["box"]).is_empty(): canvas.preview_token(edit["block"], edit["key"], start, shown)
		else: canvas.get_boxes().preview_value(edit["box"], start, shown)
		if changed: _message("The vector is as it was.")
	_dismiss_window(XREBlueprintVectorTab, true)


## Zero or Normalize under the arrows: the whole vector at once, one edit.
func _vector_action(normalize: bool) -> void:
	if _value_edit.is_empty() or _token_editor.mode != XREBlueprintTokenEditor.ARROWS: return
	var value: Variant = _value_edit["value"]
	var changed: Variant = value * 0.0
	if normalize:
		var length := (value as Vector2).length() if value is Vector2 else (value as Vector3).length()
		if length < 0.000001:
			_message("A zero vector has no direction.")
			return
		changed = value / length
		changed = Vector2(snappedf((changed as Vector2).x, 0.001), snappedf((changed as Vector2).y, 0.001)) if changed is Vector2 else Vector3(snappedf((changed as Vector3).x, 0.001), snappedf((changed as Vector3).y, 0.001), snappedf((changed as Vector3).z, 0.001))
	_preview_value_edit(changed, "")
	_message("Normalized." if normalize else "Zero.")


## Opens the Color window (D-064) for the color token of [param key] on block
## [param id], or of the box of [param box]: near the head, toward the token;
## the 2D picker or, in 3D, the globe of colors in front of the window, as
## the Color input setting says.
func _open_color(id: int, key: String, box: String, value: Color) -> void:
	_value_edit = {"block": id, "key": key, "box": box, "value": value, "start": value, "color": true}
	_set_pipette(false)
	var pose := _near_pose(_token_pose(id, key, box).origin)
	var mode := _document.features.get_value(XREFeatureSettings.COLOR_INPUT)
	var block := blueprint.graph.find_node(id)
	var title := "%s · %s" % [box if not box.is_empty() else XREBlueprintGraph.title(block), key.capitalize() if box.is_empty() else "start value"]
	_token_editor.close()
	if mode == XREFeatureSettings.GLOBE: _token_editor.open_globe(pose, value)
	color_panel.show_color(title, value, mode, _token_editor.get_globe_saturation() if mode == XREFeatureSettings.GLOBE else -1.0)
	_request_window(XREBlueprintColorTab, pose)
	_place_window_widgets()
	if mode == XREFeatureSettings.GLOBE: _message("Drag the globe to turn it, click a color on it. Saturation under it. Done keeps it; × puts it back.")
	else: _message("Pick a color; click the hex code or a figure to type it. Done keeps it; × puts it back.")


## The Color window, or null while it is closed.
func _color_window() -> XREPanelSurface:
	if not XREBlueprintColorTab in _open_windows or not color_panel.is_inside_tree(): return null
	return color_panel.get_viewport().get_parent() as XREPanelSurface


## Whether the Color window edits a token now.
func _editing_color() -> bool:
	return bool(_value_edit.get("color", false))


## Shows [param color] on the token the Color window edits, on its globe and
## in the window, without keeping it: Done keeps it ([method _end_color]). A
## color that came from elsewhere than the globe, [param turn], turns it to face the user.
func _preview_color(color: Color, turn: bool = false) -> void:
	if not _editing_color(): return
	_value_edit["value"] = color
	if str(_value_edit["box"]).is_empty(): canvas.preview_token(_value_edit["block"], _value_edit["key"], color)
	else: canvas.get_boxes().preview_value(_value_edit["box"], color)
	if _token_editor.mode == XREBlueprintTokenEditor.GLOBE:
		_token_editor.set_globe_color(color)
		if turn: _token_editor.face_globe_color()
	if _pipette_hand != null: _pipette.set_color(color)
	color_panel.set_color(color, _token_editor.get_globe_saturation() if _token_editor.mode == XREBlueprintTokenEditor.GLOBE else -1.0)


## The saturation slider under the globe moved to [param saturation].
func _saturate(saturation: float) -> void:
	if not _editing_color() or _token_editor.mode != XREBlueprintTokenEditor.GLOBE: return
	_preview_color(_token_editor.set_globe_saturation(saturation))


## Ends the Color window's edit (D-064), as the Vector window's (D-063): Done
## keeps the color as one edit; the ×, a click away or the window closing put
## it back as it was.
func _end_color(commit: bool) -> void:
	_set_pipette(false)
	if not _editing_color():
		if _token_editor.mode == XREBlueprintTokenEditor.GLOBE: _token_editor.close()
		_dismiss_window(XREBlueprintColorTab, true)
		return
	var edit := _value_edit
	_value_edit = {}
	if _token_editor.mode == XREBlueprintTokenEditor.GLOBE: _token_editor.close()
	var field := _keyboard_target.get_ref() as LineEdit if _keyboard_target != null else null
	if _keyboard.is_shown() and (_token_edit.has("channel") or _token_edit.has("hex") or (field != null and color_panel.is_ancestor_of(field))):
		_keyboard.close()
		_token_edit = {}
	var value := edit["value"] as Color
	var start := edit["start"] as Color
	var changed := not value.is_equal_approx(start)
	if commit and changed:
		if str(edit["box"]).is_empty(): _set_token(edit["block"], edit["key"], value, "Set Color")
		else: _set_box(edit["box"], value, "Set Color")
		_message("Kept %s." % _color_text(value))
	else:
		if str(edit["box"]).is_empty(): canvas.preview_token(edit["block"], edit["key"], start)
		else: canvas.get_boxes().preview_value(edit["box"], start)
		if changed: _message("The color is as it was.")
	_dismiss_window(XREBlueprintColorTab, true)


## The keypad for channel [param channel] (0 for R) of the color, 0 to 255, low on the Color window (D-067).
func _type_channel(channel: int) -> void:
	if not _editing_color(): return
	var color := _value_edit["value"] as Color
	_token_edit = {"channel": channel}
	_token_field.text = str([color.r8, color.g8, color.b8][channel])
	_show_keyboard(_token_field, _keypad_at(_color_window()), 1)
	_message("Type %s, 0 to 255." % XREBlueprintColorPanel.CHANNELS[channel])


## The keyboard for the color's hex code, below the Color window.
func _type_hex() -> void:
	if not _editing_color(): return
	_token_edit = {"hex": true}
	_token_field.text = (_value_edit["value"] as Color).to_html(false)
	_show_keyboard(_token_field, _below_window(_color_window()), 0, 0.0, KEYBOARD_BELOW_WINDOW)
	_message("Type the hex code: ff8800, or f80.")


## A figure or the hex code of the 2D picker clicked: the keypad low on the
## window (D-066), or the keyboard, wider, below it.
func _type_in_picker(field: LineEdit, numeric: bool) -> void:
	if not _editing_color(): return
	if numeric: _show_keyboard(field, _keypad_at(_color_window()), 1)
	else: _show_keyboard(field, _below_window(_color_window()), 0, 0.0, KEYBOARD_BELOW_WINDOW)


## A channel or the hex code typed for the color the Color window edits: [param edit] says which.
func _typed_color(edit: Dictionary, text: String) -> void:
	if not _editing_color(): return
	var color := _value_edit["value"] as Color
	if edit.has("hex"):
		var code := text.strip_edges().trim_prefix("#")
		if not Color.html_is_valid(code):
			_message("Not a hex code: " + text)
			return
		var typed := Color.html(code)
		# Without alpha digits the code keeps the color's alpha.
		if code.length() in [3, 6]: typed.a = color.a
		_preview_color(typed, true)
		return
	var number: Variant = XREBlueprintTokens.parse_number(text)
	if number == null:
		_message("Not a number: " + text)
		return
	color[int(edit["channel"])] = clampf(roundf(float(number)), 0.0, 255.0) / 255.0
	_preview_color(color, true)


## The middle of the bottom edge of [param window], or null without it.
func _below_window(window: XREPanelSurface) -> Variant:
	return window.pixel_to_global(Vector2(window.size_px.x * 0.5, window.size_px.y)) if window != null else null


## Takes the pipette or puts it back (D-065): the hand that clicked Pipette
## holds it instead of its controller, and its clicks off the Color window take
## colors — of the scene's objects, of the graph's cards, tokens, ports and
## boxes, of the windows — until Put back, or until the color's edit ends.
func _set_pipette(on: bool) -> void:
	var hand: XREHand = null
	if on and _editing_color():
		hand = panels.get_clicking_hand() if is_instance_valid(panels) else null
		if hand == null: hand = _rig.right_hand
	if _pipette_hand != null and _pipette_hand != hand: _controller(_pipette_hand).set_model_shown(true)
	var taken := hand != null and hand != _pipette_hand
	_pipette_hand = hand
	if hand != null:
		_controller(hand).set_model_shown(false)
		_pipette.hold(hand, _value_edit["value"] as Color)
	else:
		_pipette.put_back()
	color_panel.set_pipette(hand != null)
	if taken: _message("The pipette is in your hand: click any color but this window's. Put back drops it.")


## The model of [param hand]'s controller.
func _controller(hand: XREHand) -> XREControllerModel:
	return _rig.right_controller if hand == _rig.right_hand else _rig.left_controller


## The ray of the hand that holds the pipette, off the Color window (D-065):
## lit on what it meets first, whose color a click takes. The pipette stays in
## the hand; a click selects nothing and closes nothing.
func _point_pipette(pointer: Pointer, origin: Vector3, direction: Vector3) -> void:
	var hand := pointer.hand
	_leave(pointer)
	hand.claim(self)
	_pipette_hit(origin, direction)
	hand.show_ray(_pipette_distance, _pipette_on != PIPETTE_NOTHING)
	if not hand.trigger_pressed: return
	pointer.swallow = true
	var sampled: Variant = null
	match _pipette_on:
		PIPETTE_WINDOW: sampled = _pipette_window.color_at_pixel(_pipette_pixel)
		PIPETTE_GRAPH: sampled = canvas.get_hit_color()
		PIPETTE_SCENE: sampled = XREBlueprintColorSampler.color_at(_pipette_node, _pipette_point)
	if sampled == null:
		_message("No color there." if _pipette_on != PIPETTE_NOTHING else "Point at something: an object, a card, a token, a window.")
		return
	var color := sampled as Color
	color.a = (_value_edit["value"] as Color).a
	_preview_color(color, true)
	_message("Took %s. Done keeps it." % _color_text(color))


## Finds what the pipette's ray meets first within 5 m (D-065): a window but
## the Color window, the graph — its cards, tokens, ports and boxes — or an
## object of the scene; the [code]_pipette_[/code] fields say what and where.
## Lit by the graph's ray test, nothing is allocated: it runs every frame the pipette is held.
func _pipette_hit(origin: Vector3, direction: Vector3) -> void:
	_pipette_on = PIPETTE_NOTHING
	_pipette_distance = 5.0
	if is_instance_valid(_root) and _picker.cast_segment(_root, origin, origin + direction * _pipette_distance):
		_pipette_on = PIPETTE_SCENE
		_pipette_distance = _picker.get_hit_distance()
		_pipette_node = _picker.get_hit_node()
		_pipette_point = _picker.get_hit_position()
	var on_graph := canvas.intersect_ray(origin, direction, _pipette_distance)
	if on_graph >= 0:
		_pipette_on = PIPETTE_GRAPH
		_pipette_distance = on_graph
	var color_window := _color_window()
	for window: XREPanelSurface in _windows: _pipette_window_hit(window, color_window, origin, direction)
	if is_instance_valid(panels):
		for window: XREPanelSurface in panels.get_windows(): _pipette_window_hit(window, color_window, origin, direction)


func _pipette_window_hit(window: XREPanelSurface, color_window: XREPanelSurface, origin: Vector3, direction: Vector3) -> void:
	if window == color_window: return
	var hit := window.intersect_ray(origin, direction, _pipette_distance)
	if hit < 0: return
	_pipette_on = PIPETTE_WINDOW
	_pipette_distance = hit
	_pipette_window = window
	_pipette_pixel = window.get_hit_pixel()


## [param color] for the status line: its hex code and R, G, B.
static func _color_text(color: Color) -> String:
	return "#%s (%d, %d, %d)" % [color.to_html(false), color.r8, color.g8, color.b8]


## The grip carries a copy of a token: from a socket of block [param id] (it
## moves; a second grip makes it a copy), or from the tray with [param copy].
## A box's start value is never carried (D-079).
## [param by_trigger]: the trigger holds it, dragged off its socket, not the grip.
func _carry(pointer: Pointer, value: Variant, key: String, id: int, copy: bool, by_trigger: bool = false) -> void:
	if value == null: return
	var shown := XREBlueprintTokens.text(value, key)
	pointer.carried = XREBlueprintCanvas.make_token(value, key, XREBlueprintTokens.width(shown), _value_mode() == XREFeatureSettings.PLUGS, false, false)
	pointer.carried.top_level = true
	add_child(pointer.carried)
	pointer.carried_value = value
	pointer.carried_key = key
	pointer.carried_block = id
	pointer.carried_copy = copy
	pointer.carried_trigger = by_trigger
	pointer.hand.claim(self)
	# The token itself is in the hand, not a copy of it: it leaves its socket
	# at once (D-058). Let go anywhere but in another socket, the graph puts it back.
	if id >= 0 and not copy: canvas.hide_token(id, key)
	_update_carried(pointer)


## Moves a carried token with its hand's ray; over a socket that takes it the
## socket grows. A grip of the other hand makes it a copy. Letting go puts it
## in that socket — and takes it from where it came from unless a copy — or,
## in the air, drops it: a token from a socket leaves its default there.
func _update_carried(pointer: Pointer) -> void:
	var hand := pointer.hand
	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	var distance := 0.35
	var hit := canvas.intersect_ray(origin, direction, 5.0) if _workspace.visible else -1.0
	var target := _link_dock(hit) if pointer.carried_key == XREBlueprintLinks.KEY else _dock_target(hit)
	if hit >= 0: distance = maxf(hit - 0.01, 0.05)
	canvas.hover_socket(target.get("block", -1), canvas.get_hit_socket() if target.has("block") else -1, hand == _rig.right_hand)
	var point := origin + direction * distance
	pointer.carried.global_transform = Transform3D(XREPanels.facing(point, _rig.camera.global_position, Vector3.UP), point)
	hand.show_ray(distance, not target.is_empty())
	for other: Pointer in _pointers:
		if other != pointer and other.hand.grip_pressed and not pointer.carried_copy:
			pointer.carried_copy = true
			_message("A copy: the token stays where it was.")
	if hand.get_has_tracking_data() and (hand.trigger_held if pointer.carried_trigger else hand.grip_held): return
	_drop_carried(pointer, target if hand.get_has_tracking_data() else {})


## The socket a token dropped now would go to — [code]{"block", "key"}[/code]
## or [code]{"box"}[/code] — from the last ray [param hit], or empty.
func _dock_target(hit: float) -> Dictionary:
	if hit < 0: return {}
	if canvas.get_hit_box():
		var boxes := canvas.get_boxes()
		if boxes.get_hit_part() in [XREBlueprintBoxes.TOKEN, XREBlueprintBoxes.BODY] and not boxes.get_hit_name().is_empty(): return {"box": boxes.get_hit_name()}
		return {}
	var id := canvas.get_hit_id()
	if canvas.get_hit_socket_kind() in [XREBlueprintCanvas.TOKEN, XREBlueprintCanvas.SQUARE]: return {"block": id, "key": canvas.get_hit_socket_key()}
	if canvas.get_hit_port() >= 0 and canvas.get_hit_input():
		var block := blueprint.graph.find_node(id)
		var spec: Array = blueprint.graph.ports(block, true)[canvas.get_hit_port()]
		if spec.size() > 2 and not str(spec[2]).is_empty() and spec[2] != "target": return {"block": id, "key": spec[2]}
	return {}


func _drop_carried(pointer: Pointer, target: Dictionary) -> void:
	if pointer.carried_key == XREBlueprintLinks.KEY:
		_drop_link(pointer, target)
		return
	var value: Variant = pointer.carried_value
	var source_block := pointer.carried_block
	var source_key := pointer.carried_key
	var copy := pointer.carried_copy
	pointer.carried.queue_free()
	pointer.carried = null
	_show_carried_source(source_block, source_key, copy)
	pointer.carried_block = -1
	pointer.hand.unclaim(self)
	pointer.hand.show_ray(XREHand.RAY_LENGTH, false)
	var from_socket := source_block >= 0 and not copy
	if target.has("block") and target["block"] == source_block and target["key"] == source_key:
		_schedule_rebuild()
		return
	var state := blueprint.graph.snapshot()
	if target.has("block"):
		var block := blueprint.graph.find_node(target["block"])
		if block.is_empty() or not XREBlueprintTokens.accepts(blueprint.graph, block, target["key"], value):
			_message("This token doesn't fit there.")
			_schedule_rebuild()
			return
		for entry: Dictionary in state["nodes"]:
			if entry["id"] == target["block"]: entry["params"][target["key"]] = value
		# On a port a wire comes into, the token takes the wire's place (D-066): the wire goes.
		var port := blueprint.graph.input_port(block, target["key"])
		if port >= 0:
			var edges: Array = state["edges"]
			var before := edges.size()
			state["edges"] = edges.filter(func(edge: Dictionary) -> bool: return not (edge["to"] == target["block"] and edge["to_port"] == port))
			if (state["edges"] as Array).size() != before: _drop_orphan_inlines(state)
	elif target.has("box"):
		var variable := blueprint.graph.find_variable(target["box"])
		if variable.is_empty() or not XREBlueprintSchema.accepts(XREBlueprintGraph.variable_type(variable), typeof(value)):
			_message("This token doesn't fit there.")
			_schedule_rebuild()
			return
		for entry: Dictionary in state["variables"]:
			if entry["name"] == target["box"]:
				entry["value"] = float(value) if XREBlueprintGraph.variable_type(variable) == TYPE_FLOAT else value
				entry.erase("type")
	elif not from_socket:
		# A copy or a token from the tray, let go in the air, just goes.
		_schedule_rebuild()
		return
	# Taken out of its socket, the token leaves a port a default token unless a
	# wire brings its value (D-059, after D-054 left it empty); a square socket
	# gets its default back.
	if from_socket:
		for entry: Dictionary in state["nodes"]:
			if entry["id"] != source_block: continue
			if source_key in blueprint.graph.socket_keys(entry): (entry["params"] as Dictionary).erase(source_key)
			else: entry["params"][source_key] = XREBlueprintTokens.default_value(entry, source_key)
		_fill_sockets(state)
	var title := "Dock Token" if target.has("block") or target.has("box") else "Reset Token"
	if blueprint.perform(blueprint.commit.bind(title, state), &"vr_graph"):
		if title == "Dock Token": token_tray.remember(value)
		_message("Token in %s." % str(target.get("key", target.get("box", ""))).capitalize() if title == "Dock Token" else "Back to the default token.")
	else: _message(blueprint.last_error)
	_schedule_rebuild()


## Lets go of what [param pointer] turns or carries, without an edit.
func _drop_tokens(pointer: Pointer) -> void:
	if pointer.arrow_axis >= 0: pointer.hand.unclaim_stick(self)
	pointer.arrow_axis = -1
	_token_editor.close()
	if not pointer.token_key.is_empty() or not pointer.token_box.is_empty(): _end_turn(pointer, false)
	if pointer.carried != null:
		pointer.carried.queue_free()
		pointer.carried = null
		_show_carried_source(pointer.carried_block, pointer.carried_key, pointer.carried_copy)
		if not pointer.carried_ref.is_empty(): canvas.hide_link(pointer.carried_ref, false)
		pointer.carried_ref = {}
		pointer.hand.unclaim(self)
		_schedule_rebuild()
	if not pointer.pull.is_empty(): _end_pull(pointer, false)


## Shows again the token that a carry hid in its socket (D-058): a drop that
## edits the graph rebuilds it anyway; one that doesn't (back in its own
## socket, a default equal to it) must not leave it hidden.
func _show_carried_source(block: int, key: String, copy: bool) -> void:
	if copy: return
	if block >= 0: canvas.hide_token(block, key, false)


## The ray on the variables' boxes (D-052): the trash deletes the variable,
## the token sets its start value, the box takes a Variable wire; the grip
## anywhere on it carries it, as a card (D-078). The start value never leaves
## its box (D-079): it changes by its input, or by a token laid on it.
func _point_at_box(pointer: Pointer, origin: Vector3, direction: Vector3, hit: float) -> void:
	var hand := pointer.hand
	var boxes := canvas.get_boxes()
	hand.claim(self)
	hand.show_ray(hit, true)
	canvas.hover_actions(-1, false, false, hand == _rig.right_hand, -1, false, -1, true)
	boxes.hover(boxes.get_hit_index(), boxes.get_hit_part(), hand == _rig.right_hand, boxes.get_hit_component())
	var variable := boxes.get_hit_name()
	var part := boxes.get_hit_part()
	pointer.focus_box = variable
	if _link_kind == XREBlueprintCanvas.VARIABLE and _link_hand == hand: _show_box_link(canvas.to_local(origin + direction * hit))
	if _deletes_now() and not variable.is_empty():
		_consume_delete()
		_remove_box(variable)
		return
	if hand.grip_pressed:
		_start_hold(pointer, canvas, -1, origin + direction * hit, false, variable)
		return
	if not hand.trigger_pressed: return
	match part:
		XREBlueprintBoxes.TRASH: _remove_box(variable)
		XREBlueprintBoxes.TOKEN:
			if _value_mode() == XREFeatureSettings.WINDOW:
				parameters.show_variables()
				_show_parameters()
			else: _start_turn(pointer, -1, "", variable, origin + direction * hit)
		XREBlueprintBoxes.DRAWER: _switch_drawer(variable)
		XREBlueprintBoxes.COMPONENT:
			# A component's output (D-105): into the port a wire waits at, or a wire of its own to a port.
			if _pending_id >= 0 and _pending_input: _wire_component_to_port(variable, boxes.get_hit_component(), _pending_id, _pending_port)
			else:
				cancel_connection()
				_link_kind = XREBlueprintCanvas.VARIABLE
				_link_box = variable
				_link_component = boxes.get_hit_component()
				_link_hand = hand
				_message("Press trigger on the input that reads it.")
		_:
			if _pending_id >= 0 and _pending_input and _sets_target(_pending_id, _pending_port): _set_writes_variable(_pending_id, variable)
			elif _pending_id >= 0 and _pending_input: _wire_box_to_port(variable, _pending_id, _pending_port)
			elif _link_kind == XREBlueprintCanvas.VARIABLE and _link_block >= 0: _wire_variable(_link_block, variable)
			else:
				cancel_connection()
				_link_kind = XREBlueprintCanvas.VARIABLE
				_link_box = variable
				_link_hand = hand
				_message("Press trigger on the Variable of a Get or Set Variable.")


## A Variable wire from block [param id]'s socket to the box of [param variable], as one edit.
func _wire_variable(id: int, variable: String) -> void:
	var block := blueprint.graph.find_node(id)
	if block.is_empty() or blueprint.graph.find_variable(variable).is_empty(): return
	var state := blueprint.graph.snapshot()
	for entry: Dictionary in state["nodes"]:
		if entry["id"] != id: continue
		entry["params"]["variable"] = variable
		var found := blueprint.graph.find_variable(variable)
		if entry["kind"] == "set_variable": entry["params"]["value"] = found.get("value", XREBlueprintSchema.default_value(XREBlueprintGraph.variable_type(found)))
	if blueprint.perform(blueprint.commit.bind("Wire Variable", state), &"vr_graph"):
		cancel_connection()
		_close_wire_menu()
		_message("%s uses %s." % [XREBlueprintGraph.title(block), variable])
	else: _message(blueprint.last_error)


## A wire between a box and a data input of block [param id] (D-055): a Get
## Variable of the box goes in left of the card, wired to that input, as one
## edit. With [param added], the new variable the box is for, that edit adds it too (D-078).
func _wire_box_to_port(variable: String, id: int, port: int, added: Dictionary = {}) -> void:
	var target := blueprint.graph.find_node(id)
	if target.is_empty() or (added.is_empty() and blueprint.graph.find_variable(variable).is_empty()): return
	var getter := XREBlueprintGraph.make_node(0, "get_variable", Vector2.ZERO)
	getter["params"]["variable"] = variable
	# Inline (D-061): no card, the wire comes straight from the box; the 2D editor shows the node.
	getter["vr_inline"] = true
	# From a link, or from a link of the tray laid on the port, it stays a link (D-074).
	if _pending_link and _pending_id == id and _pending_port == port: XREBlueprintLinks.set_link(getter, XREBlueprintLinks.VARIABLE, true)
	getter["vr_depth"] = float(target.get("vr_depth", 0.0))
	var position: Vector2 = target["position"] + Vector2(-300, 40 + 50 * port)
	var variables: Array[Dictionary] = []
	if not added.is_empty(): variables.append(added)
	var inserted: int = blueprint.perform(blueprint.insert_block.bind(getter, position, {"to": id, "to_port": port}, null, "Wire Variable" if added.is_empty() else "Add Variable", variables), &"vr_graph")
	cancel_connection()
	if inserted < 0: _message(blueprint.last_error)
	else:
		_close_wire_menu()
		_message("%s reads %s." % [XREBlueprintGraph.title(target), variable])


## Opens or shuts the drawer of components of [param variable]'s box (D-108),
## whatever Composite values says for the others: one edit of the graph's
## editor-only vr_collapsed, false while open (drawers start shut, D-114). A
## drawer whose components are wired stays open.
func _switch_drawer(variable: String) -> void:
	var found := blueprint.graph.find_variable(variable)
	if found.is_empty(): return
	var shutting := not XREBlueprintCanvas.drawer_shut(blueprint.graph, found)
	if shutting:
		for block: Dictionary in blueprint.graph.nodes:
			if XREBlueprintCanvas.is_split_break(block) and XREBlueprintCanvas.split_variable(blueprint.graph, block) == variable:
				_message("%s's components are wired: unwire them to shut its drawer." % variable)
				return
	var state := blueprint.graph.snapshot()
	for entry: Dictionary in state["variables"]:
		if entry["name"] != variable: continue
		if shutting: entry.erase("vr_collapsed")
		else: entry["vr_collapsed"] = false
	if not blueprint.perform(blueprint.commit.bind("Shut Drawer" if shutting else "Open Drawer", state), &"vr_graph"): _message(blueprint.last_error)


## A wire from component [param component] of [param variable]'s box into
## input [param port] of block [param id] (D-105): a Break of the variable,
## fed by an inline Get Variable, both hidden, its component's output wired
## to the port in place of what fed it; one edit. The 2D editor shows them.
func _wire_component_to_port(variable: String, component: int, id: int, port: int) -> void:
	var found := blueprint.graph.find_variable(variable)
	var target := blueprint.graph.find_node(id)
	var names: Array = XREBlueprintBoxes.COMPONENTS.get(XREBlueprintGraph.variable_type(found), [])
	if found.is_empty() or target.is_empty() or component < 0 or component >= names.size(): return
	var spec: Array = blueprint.graph.ports(target, true)[port]
	if not XREBlueprintGraph.ports_compatible(XREBlueprintGraph.NUMBER, int(spec[1])):
		_message("%s takes no number." % spec[0])
		cancel_connection()
		return
	var name := {TYPE_VECTOR2: "break_vector2", TYPE_VECTOR3: "break_vector3", TYPE_COLOR: "break_color"}[XREBlueprintGraph.variable_type(found)] as String
	var state := blueprint.graph.snapshot()
	var next := 1
	for entry: Dictionary in state["nodes"]: next = maxi(next, int(entry["id"]) + 1)
	var depth := float(target.get("vr_depth", 0.0))
	var getter := XREBlueprintGraph.make_node(next, "get_variable", target["position"] + Vector2(-600, 40 + 50 * port))
	getter["params"]["variable"] = variable
	getter["vr_inline"] = true
	getter["vr_depth"] = depth
	var breaker := XREBlueprintGraph.make_call(next + 1, XREBlueprintFunctions.static_function("XREBlueprintLibrary", name), target["position"] + Vector2(-300, 40 + 50 * port))
	breaker["vr_inline"] = true
	breaker["vr_depth"] = depth
	(state["nodes"] as Array).append_array([getter, breaker])
	# An input takes one wire: what fed it goes, and an inline reader with it.
	state["edges"] = (state["edges"] as Array).filter(func(edge: Dictionary) -> bool: return not (edge["to"] == id and edge["to_port"] == port))
	(state["edges"] as Array).append_array([{"from": next, "from_port": 0, "to": next + 1, "to_port": 0}, {"from": next + 1, "from_port": component, "to": id, "to_port": port}])
	_drop_orphan_inlines(state)
	if blueprint.perform(blueprint.commit.bind("Wire Component", state), &"vr_graph"):
		cancel_connection()
		_close_wire_menu()
		_message("%s reads %s.%s." % [XREBlueprintGraph.title(target), variable, names[component]])
	else: _message(blueprint.last_error)


## Deletes the variable of a box with its wires and links into ports (D-079):
## the inline Get Variables they stand for (D-061) go too, and the ports they
## fed get their default tokens, as one edit. A card that uses the variable —
## a Get or Set Variable — keeps it: the message names the card, and the card
## flashes with its wire to the box, drawn even where a link hides it.
func _remove_box(variable: String) -> void:
	var users := PackedStringArray()
	var readers: Dictionary[int, bool] = {}
	for block: Dictionary in blueprint.graph.nodes:
		if str((block["params"] as Dictionary).get("variable", "")) != variable: continue
		if canvas.is_inline(block): readers[int(block["id"])] = true
		else: users.append("%s #%d" % [XREBlueprintGraph.title(block), block["id"]])
	if not users.is_empty():
		_message("%s is used by %s: delete that, or wire it to another box, first." % [variable, ", ".join(users)])
		canvas.flash_variable(variable, true)
		get_tree().create_timer(FLASH_TIME).timeout.connect(func() -> void: if is_instance_valid(canvas): canvas.flash_variable(variable, false))
		return
	var state := blueprint.graph.snapshot()
	state["nodes"] = (state["nodes"] as Array).filter(func(block: Dictionary) -> bool: return not readers.has(int(block["id"])))
	state["edges"] = (state["edges"] as Array).filter(func(edge: Dictionary) -> bool: return not readers.has(int(edge["from"])))
	state["variables"] = (state["variables"] as Array).filter(func(entry: Dictionary) -> bool: return entry["name"] != variable)
	_fill_sockets(state)
	if blueprint.perform(blueprint.commit.bind("Remove Variable", state), &"vr_graph"): _message("Variable %s removed." % variable)
	else: _message(blueprint.last_error)


## A new variable of [param action] from the block menu (D-078), of its type:
## the keyboard asks its name. Its box goes where the menu was opened — the
## point a wire was let go, or beside the menu's card — or at [param point],
## where its row was pulled to. From a wire of a data input, that input reads it.
func _ask_new_variable(action: Dictionary, point: Variant) -> void:
	var place := _menu_place(null)
	var at := canvas.position_from_block({"position": Vector2(place.x, place.y), "vr_depth": place.z})
	if point is Vector3: at = point
	elif _menu_at_point: at = _menu_point
	var value: Variant = action["variable"]
	_token_edit = {"new_variable": true, "value": value, "at": at, "wire": _menu_wire.duplicate() if _menu_wire.has("to") else {}}
	if _menu_at_point: cancel_connection()
	# Pinned to a hand, the menu stays, without the wire.
	_dismiss_window(XREBlueprintPaletteTab, false)
	if is_block_palette_shown():
		_menu_at_point = false
		block_menu.clear_pin()
	_token_field.text = ""
	_show_keyboard(_token_field, canvas.to_global(at))
	_message("Type the name of the new %s variable, or Done for %s." % [type_string(typeof(value)), _free_variable_name(value)])


## Adds the variable [method _ask_new_variable] asked for, named [param text]
## or, with nothing typed, by its type ([method _free_variable_name]), its box
## at the point asked, as one edit; one read by an input is wired there in it too.
func _add_new_variable(edit: Dictionary, text: String) -> void:
	var value: Variant = edit["value"]
	var variable := text if not text.is_empty() else _free_variable_name(value)
	if not variable.is_valid_identifier() or not blueprint.graph.find_variable(variable).is_empty():
		_message("A variable needs a new name of letters, digits and _.")
		return
	var at: Vector3 = edit["at"]
	var place := {"vr_position": canvas.block_position(at), "vr_depth": at.z}
	var wire: Dictionary = edit["wire"]
	if not wire.is_empty():
		var added := {"name": variable, "value": value}
		added.merge(place)
		_wire_box_to_port(variable, int(wire["to"]), int(wire["to_port"]), added)
	elif blueprint.perform(blueprint.add_variable.bind(variable, value, place), &"vr_graph"): _message("Variable %s: %s." % [variable, type_string(typeof(value))])
	else: _message(blueprint.last_error)


## The first name no variable of the graph has, for a new one of [param value]'s type: new_float, new_float_2…
func _free_variable_name(value: Variant) -> String:
	var base := "new_" + type_string(typeof(value)).to_lower()
	var candidate := base
	var index := 2
	while not blueprint.graph.find_variable(candidate).is_empty():
		candidate = "%s_%d" % [base, index]
		index += 1
	return candidate


## The point a Source or Variable wire starts from, in the canvas's space.
func _link_origin() -> Vector3:
	if _link_block >= 0: return canvas.socket_position(_link_block, _link_kind)
	if not _link_box.is_empty(): return canvas.get_boxes().component_point(_link_box, _link_component)
	return Vector3.ZERO


## The trigger on an event's Source or a Variable: a wire from it, to a scene object or a box.
func _start_link(id: int, kind: int, hand: XREHand) -> void:
	cancel_connection()
	_link_kind = kind
	_link_block = id
	_link_hand = hand
	_message("Point at a scene object and press trigger." if kind == XREBlueprintCanvas.SOURCE else "Press trigger on a variable's box.")


## What a member wire of [param block] picks on an object: "property",
## "signal", "animation", "audio" for a sound player, or empty for none.
func _member_role(block: Dictionary) -> String:
	if block.is_empty(): return ""
	var kind := XREBlueprintTokens.member_kind(block)
	if not kind.is_empty(): return kind
	for cls: Variant in XREBlueprintSchema.target_classes(block):
		if str(cls).begins_with("AudioStreamPlayer"): return "audio"
	return ""


## Opens the petals of [param object] for block [param id], grown from [param point] on it.
func _open_petals(id: int, object: Node3D, point: Vector3) -> void:
	var block := blueprint.graph.find_node(id)
	_petal_block = id
	_petal_dynamic = false
	_petals.open(object, point, _rig.camera.global_position, _rig.global_basis.y, _member_groups(object, _member_role(block), block))


## The trigger on the member's name after Target or Source: its petals, at the
## target object, or at the port for a target that comes by wire (D-052).
func _open_member_petals(id: int, hand: XREHand) -> void:
	var block := blueprint.graph.find_node(id)
	if block.is_empty(): return
	if block["kind"] != "signal" and blueprint.target_is_connected(id):
		var cls := _wired_class(id)
		var items: Array[Dictionary] = []
		if ClassDB.class_exists(cls):
			for info: Dictionary in ClassDB.class_get_property_list(cls):
				if int(info["usage"]) & PROPERTY_USAGE_EDITOR and int(info["type"]) in XREBlueprintSchema.LITERAL_TYPES:
					items.append({"text": str(info["name"]), "member": str(info["name"]), "node": null, "kind": "property", "enabled": true})
		cancel_connection()
		_petal_block = id
		_petal_dynamic = true
		var at := canvas.to_global(canvas.port_position(id, XREBlueprintGraph.target_port(block), true))
		_petals.open(canvas, at, _rig.camera.global_position, _rig.global_basis.y, [{"header": cls, "items": items}])
		_message("Choose the member of the %s the wire brings." % cls)
		return
	# The adapter only picks the member (D-062): no wire comes off it to another
	# object; the name on the card (Node) also lets the ray pick another object.
	var adapter := XREBlueprintTokens.adapter(_document.features.get_value(XREFeatureSettings.TARGET_INPUT))
	if adapter: cancel_connection()
	elif block["kind"] == "signal": _start_link(id, XREBlueprintCanvas.SOURCE, hand)
	else:
		cancel_connection()
		_pending_id = id
		_pending_port = XREBlueprintGraph.target_port(block)
		_pending_input = true
		_pending_hand = hand
	var target := blueprint.target_node(id) as Node3D
	if target == null: target = _anchor(blueprint.target_node(id)) if blueprint.target_node(id) != null else null
	if target != null: _open_petals(id, target, target.global_transform * (block["vr_anchor"] as Vector3 if block.get("vr_anchor") is Vector3 else Vector3.ZERO))
	_message("Pick a member." if adapter else "Pick a member, or point at another object.")


## The class of the object a wire brings to block [param id]'s Target: a signal argument's class.
func _wired_class(id: int) -> String:
	var block := blueprint.graph.find_node(id)
	var port := XREBlueprintGraph.target_port(block)
	for edge: Dictionary in blueprint.graph.edges:
		if edge["to"] != id or edge["to_port"] != port: continue
		var source := blueprint.graph.find_node(edge["from"])
		if source["kind"] == "signal" and edge["from_port"] >= 1:
			var arguments: Array = source.get("arguments", [])
			if edge["from_port"] - 1 < arguments.size():
				var cls := str((arguments[edge["from_port"] - 1] as Dictionary).get("class_name", ""))
				if not cls.is_empty(): return cls
	return "Node"


## Members of [param object] for a wire of [param role], grouped: the
## object's own, then the sound and animation players without geometry under
## it, each in a group of its own (D-052).
func _member_groups(object: Node, role: String, block: Dictionary) -> Array[Dictionary]:
	var groups: Array[Dictionary] = []
	var players := _hidden_children(object, "AnimationPlayer")
	var sounds := _hidden_children(object, "AudioStreamPlayer")
	if role in ["signal", "all"]:
		groups.append({"header": "Signals · " + object.name if role == "all" else "", "items": _signal_items(object)})
		if role == "signal":
			for child: Node in players + sounds: groups.append({"header": "%s · %s" % [child.name, child.get_class()], "items": _signal_items(child)})
	if role in ["animation", "all"]:
		for player: Node in players:
			var items: Array[Dictionary] = []
			for clip: String in (player as AnimationMixer).get_animation_list():
				items.append({"text": clip, "member": clip, "node": player, "kind": "animation", "enabled": true})
			groups.append({"header": "%s · AnimationPlayer" % player.name, "items": items})
	if role in ["audio", "all"]:
		var items: Array[Dictionary] = []
		for sound: Node in sounds: items.append({"text": "▶ " + str(sound.name), "member": "", "node": sound, "kind": "audio", "enabled": true})
		groups.append({"header": "Sounds" if role == "all" else "", "items": items})
	if role in ["property", "all"]:
		var items: Array[Dictionary] = []
		var names: Array[String] = []
		if not block.is_empty(): names = XREBlueprintTokens.properties_for(block, object)
		else:
			for info: Dictionary in XREBlueprintSchema.properties(object): names.append(str(info["name"]))
		var wired_type := _wired_value_type(block)
		for property: String in names:
			var info := XREBlueprintSchema.property_info(object, property)
			var fits := wired_type == TYPE_NIL or XREBlueprintSchema.accepts(int(info.get("type", TYPE_NIL)), wired_type)
			items.append({"text": property, "member": property, "node": object, "kind": "property", "enabled": fits})
		items.sort_custom(func(first: Dictionary, second: Dictionary) -> bool: return first["enabled"] and not second["enabled"])
		groups.append({"header": "Properties" if role == "all" else "", "items": items})
	return groups


## The type of the wire into a block's value input, TYPE_NIL for none or for a Variant.
func _wired_value_type(block: Dictionary) -> int:
	if block.is_empty(): return TYPE_NIL
	var port := blueprint.graph.input_port(block, "value")
	for edge: Dictionary in blueprint.graph.edges:
		if edge["to"] == block["id"] and edge["to_port"] == port:
			var source := blueprint.graph.find_node(edge["from"])
			var type: int = blueprint.graph.ports(source, false)[edge["from_port"]][1]
			return [TYPE_NIL, TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_VECTOR2, TYPE_VECTOR3, TYPE_OBJECT, TYPE_COLOR][type]
	return TYPE_NIL


## The signals of [param node], the ones a graph handles most first.
static func _signal_items(node: Node) -> Array[Dictionary]:
	var common: Array[String] = ["body_entered", "body_exited", "area_entered", "area_exited", "pressed", "toggled", "timeout", "animation_finished", "finished", "ready"]
	var items: Array[Dictionary] = []
	for info: Dictionary in node.get_signal_list():
		items.append({"text": str(info["name"]), "member": str(info["name"]), "node": node, "kind": "signal", "enabled": true})
	items.sort_custom(func(first: Dictionary, second: Dictionary) -> bool:
		var a := common.find(first["member"])
		var b := common.find(second["member"])
		if a >= 0 and b >= 0: return a < b
		if a >= 0 or b >= 0: return a >= 0
		return str(first["member"]) < str(second["member"]))
	return items


## Nodes of class [param cls] (AnimationPlayer, or AudioStreamPlayer and its 2D and 3D kinds)
## at [param object] or up to two levels under it: nodes the user doesn't see.
static func _hidden_children(object: Node, cls: String) -> Array[Node]:
	var found: Array[Node] = []
	var pending: Array[Node] = [object]
	var depth: Dictionary[Node, int] = {object: 0}
	while not pending.is_empty():
		var node: Node = pending.pop_front()
		if node.is_class(cls) or (cls == "AudioStreamPlayer" and (node is AudioStreamPlayer2D or node is AudioStreamPlayer3D)): found.append(node)
		if depth[node] >= 2: continue
		for child: Node in node.get_children():
			depth[child] = depth[node] + 1
			pending.append(child)
	return found


## The ray on the petals of a member or on a choice: they light up, the trigger picks.
## The ray on the petals of a member or on a choice: they light up, the wire
## being drawn ends on the petal under the ray, the right thumbstick scrolls a
## long list; the trigger picks, or, dragged up or down, scrolls ([method _update_fan_press]).
func _point_at_petals(pointer: Pointer, origin: Vector3, direction: Vector3, limit: float, delta: float) -> bool:
	if not _petals.is_open() and not _choice.is_open(): return false
	var fan := _choice if _choice.is_open() and _choice.intersect_ray(origin, direction, limit) >= 0 else _petals
	var hit := fan.intersect_ray(origin, direction, limit)
	# Only the hand that lit a petal puts it out: the other hand's ray off the fan leaves it (D-059).
	if hit >= 0 or pointer.fan_hover: fan.hover_hit()
	pointer.fan_hover = hit >= 0
	if hit < 0:
		# Picking a member in focus (D-062), the right stick scrolls the list wherever the ray is.
		if is_focused() and fan == _petals and pointer.hand == _rig.right_hand:
			var off_tilt := XREPanels._tilt(pointer.hand.get_vector2(&"primary").y)
			if off_tilt != 0.0:
				pointer.hand.claim_stick(self)
				# Smoothly, by parts of a row (D-067).
				fan.scroll_by(-off_tilt * FAN_SPEED * delta)
		return false
	var hand := pointer.hand
	var point := origin + direction * hit
	hand.claim(self)
	hand.claim_stick(self)
	hand.show_ray(hit, true)
	canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
	if _pending_hand == hand: _preview_connection(point)
	elif _link_kind == XREBlueprintCanvas.SOURCE and _link_hand == hand: canvas.show_socket_link(_link_block, XREBlueprintCanvas.SOURCE, canvas.to_local(point))
	elif not _member_link.is_empty() and _member_hand == hand: canvas.show_link(canvas.to_local(_member_link["anchor_global"]), canvas.to_local(point))
	var tilt := XREPanels._tilt(hand.get_vector2(&"primary").y)
	if tilt != 0.0:
		fan.scroll_by(-tilt * FAN_SPEED * delta)
	if hand.trigger_pressed:
		pointer.fan = fan
		pointer.fan_item = fan.get_hit()
		pointer.fan_height = fan.plane_height(origin, direction)
		pointer.fan_rows = 0.0
		pointer.fan_dragged = false
	return true


## The ray on a member's petal on its stem (D-057): it grows and says what the
## trigger does, which opens the object's petals to pick another member — as the
## member's name on the card does. Picked analytically, nearer than [param limit].
func _point_at_stem(pointer: Pointer, origin: Vector3, direction: Vector3, limit: float) -> bool:
	var hit := stem_at(origin, direction, limit)
	if hit == null: return false
	var hand := pointer.hand
	hit.hot = true
	# The member's petal on the object stands for its card: that card is in focus (D-072).
	pointer.focus = hit.id
	hand.claim(self)
	hand.show_ray(origin.distance_to(hit.label.global_position), true)
	canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
	canvas.hover_socket(-1, -1, hand == _rig.right_hand)
	if _token_editor.mode in [&"", XREBlueprintTokenEditor.HINT]:
		var pose := hit.label.global_transform.orthonormalized()
		_token_editor.show_hint(Transform3D(pose.basis, pose.origin + pose.basis.y * XREBlueprintPetals.PILL_HEIGHT * 0.5 * hit.label.global_basis.get_scale().y), MEMBER_HINT)
		_hint_frame = Engine.get_process_frames()
	if hand.trigger_pressed: _open_member_petals(hit.id, hand)
	return true


## The Target wire whose member's petal the ray from [param origin] along
## [param direction] meets nearer than [param limit], or null.
func stem_at(origin: Vector3, direction: Vector3, limit: float) -> TargetWire:
	var found: TargetWire = null
	var nearest := limit
	for wire: TargetWire in _target_wires:
		if wire.label == null or not wire.label.visible: continue
		var inverse := wire.label.global_transform.affine_inverse()
		var local_origin := inverse * origin
		var local_direction := inverse.basis * direction
		if absf(local_direction.z) < 0.000001: continue
		var along := -local_origin.z / local_direction.z
		if along < 0.0: continue
		var point := local_origin + local_direction * along
		if absf(point.x) > wire.width * 0.5 + 0.004 or absf(point.y) > XREBlueprintPetals.PILL_HEIGHT * 0.5 + 0.004: continue
		var distance := origin.distance_to(wire.label.global_transform * point)
		if distance < nearest:
			nearest = distance
			found = wire
	return found


## A trigger held on petals: dragged up or down it scrolls the list, the rows
## following the ray smoothly once it has moved half a row (D-067); let go
## without a drag it picks the petal it was pressed on.
func _update_fan_press(pointer: Pointer) -> void:
	var hand := pointer.hand
	var fan := pointer.fan
	var origin := hand.global_position
	var direction := -hand.global_basis.z.normalized()
	var height := fan.plane_height(origin, direction)
	if not is_nan(height) and not is_nan(pointer.fan_height):
		if not pointer.fan_dragged and absf(height - pointer.fan_height) > XREBlueprintPetals.STEP * 0.5:
			# From here the rows go with the ray, with no jump of the half row it took.
			pointer.fan_dragged = true
			pointer.fan_height = height
			pointer.fan_rows = 0.0
		if pointer.fan_dragged:
			var rows := (height - pointer.fan_height) / XREBlueprintPetals.STEP
			fan.scroll_by(rows - pointer.fan_rows)
			pointer.fan_rows = rows
	var hit := fan.intersect_ray(origin, direction, 5.0)
	fan.hover_hit()
	hand.show_ray(hit if hit >= 0 else 0.6, hit >= 0)
	if hand.trigger_held and hand.get_has_tracking_data(): return
	pointer.fan = null
	if not pointer.fan_dragged and hand.get_has_tracking_data() and fan.is_open(): _choose_petal(fan, pointer.fan_item, hand)


func _choose_petal(fan: XREBlueprintPetals, item: Dictionary, hand: XREHand) -> void:
	if item.is_empty() or not item.get("enabled", true): return
	if item.has("scroll"):
		fan.scroll(int(item["scroll"]))
		return
	if fan == _choice and _choice_menu:
		_choose_offered(item)
		return
	if fan == _choice:
		_choice.close()
		_create_member_block(str(item["choice"]))
		return
	if _petal_block >= 0:
		var id := _petal_block
		var block := blueprint.graph.find_node(id)
		var key := XREBlueprintTokens.member_key(block)
		var success: bool
		if _petal_dynamic: success = _set_token(id, key, item["member"], "Wire Member")
		else:
			var node: Node = item["node"]
			var anchor: Variant = null
			if node is Node3D and node == _petals.get_object(): anchor = (node as Node3D).global_transform.affine_inverse() * _petals.get_anchor()
			success = blueprint.perform(blueprint.set_target_member.bind(id, node, key if not str(item["member"]).is_empty() else "", item["member"], anchor, "Wire Member"), &"vr_graph")
		if success:
			cancel_connection()
			_petals.close()
			_message("%s · %s" % [XREBlueprintGraph.title(block), item["member"] if not str(item["member"]).is_empty() else item["text"]])
		else: _message(blueprint.last_error)
		return
	# The selected object's petals: a wire from the member, to a card or into the graph (Create from scene).
	var node := item["node"] as Node
	var anchor_global := _petals.get_anchor()
	_member_link = item.duplicate()
	_member_link["anchor_global"] = anchor_global
	_member_link["anchor"] = (node as Node3D).global_transform.affine_inverse() * anchor_global if node is Node3D and node == _petals.get_object() else null
	_member_hand = hand
	_message("Point into the graph and press trigger to add the block, or at a card's Target.")


## Opens the selected object's petals for Create from scene (D-052), or closes them.
func _update_selection_fan() -> void:
	if _petal_block >= 0 or _petal_dynamic or not _member_link.is_empty(): return
	var selection := _document.get_selection()
	var object := selection[0] as Node3D if selection.size() == 1 else null
	if not _workspace.visible or object == null or _document.features.get_value(XREFeatureSettings.SCENE_CREATE) != XREFeatureSettings.ON or not blueprint.scene_context_active():
		_petals.close()
		return
	var bounds := object.global_transform * XREPicker.get_local_bounds(object)
	var head := _rig.camera.global_position
	var toward := head - bounds.get_center()
	toward.y = 0.0
	var anchor := bounds.get_center() + (toward.normalized() * minf(bounds.size.x, bounds.size.z) * 0.5 if not toward.is_zero_approx() else Vector3.ZERO)
	_petals.open(object, anchor, head, _rig.global_basis.y, _member_groups(object, "all", {}))


## The wire from a petal over empty space: the trigger adds its block there, a
## property first asks Get, Set or Tween.
func _update_member_link(hand: XREHand, origin: Vector3, direction: Vector3) -> void:
	hand.claim(self)
	hand.show_ray(0.8, false)
	var point := origin + direction * 0.8
	canvas.show_link(canvas.to_local(_member_link["anchor_global"]), canvas.to_local(point))
	if not hand.trigger_pressed: return
	_choice_point = canvas.to_local(point)
	if _member_link["kind"] == "property":
		var items: Array[Dictionary] = []
		for choice: Array in [["Get", "get_property"], ["Set", "set_property"], ["Tween", "tween"]]:
			items.append({"text": choice[0] + " " + str(_member_link["member"]), "choice": choice[1], "enabled": true})
		_use_choice(_fan_choice)
		_choice.open(canvas, point, _rig.camera.global_position, _rig.global_basis.y, [{"header": "", "items": items}])
		return
	_create_member_block(str({"signal": "signal", "animation": "play_animation", "audio": "play_sound"}[_member_link["kind"]]))


## Adds the block of kind or preset [param kind] for the member of the wire
## from a petal, at the point it was let go, aimed at its object: one edit.
func _create_member_block(kind: String) -> void:
	var item := _member_link
	if item.is_empty(): return
	var block := XREBlueprintGraph.make_node(0, kind, Vector2.ZERO)
	if block.is_empty(): return
	var key := XREBlueprintTokens.member_key(block)
	if not key.is_empty() and not str(item["member"]).is_empty(): block["params"][key] = item["member"]
	if item.get("anchor") is Vector3: block["vr_anchor"] = item["anchor"]
	block["vr_depth"] = _choice_point.z
	var id: int = blueprint.perform(blueprint.insert_block.bind(block, canvas.block_position(_choice_point), {}, item["node"] as Node, "Create From Scene"), &"vr_graph")
	cancel_connection()
	if id < 0:
		_message(blueprint.last_error)
		return
	select_block(id, false)
	_message("Added %s for %s." % [XREBlueprintGraph.title(blueprint.graph.find_node(id)), item["text"]])


## The wire from a petal let go on card [param id]: the card takes its object and member.
func _connect_member_link(id: int) -> void:
	var item := _member_link
	var block := blueprint.graph.find_node(id)
	var role := _member_role(block)
	var fits := role == str(item["kind"]) or (role == "" and XREBlueprintGraph.has_target(block))
	if not fits:
		_message("This card can't use a %s." % item["kind"])
		return
	var key := XREBlueprintTokens.member_key(block)
	if blueprint.perform(blueprint.set_target_member.bind(id, item["node"], key if not str(item["member"]).is_empty() else "", item["member"], item.get("anchor"), "Wire Member"), &"vr_graph"):
		cancel_connection()
		_message("%s · %s" % [XREBlueprintGraph.title(block), item["text"]])
	else: _message(blueprint.last_error)



# --- Links (D-074) ----------------------------------------------------------------------------


## With Link from wire on Always (D-077), makes every reference an edit from the
## headset gives a block — a variable or a scene object it had not — a link in
## the same edit, [param state] (of [method XREBlueprintDocument.commit]): so a
## new wire to a box or an object is a link at once, and undo takes both back.
## A reference that stays as it was keeps its look, so a link made a wire again stays a wire.
## With Auto link on (D-090), only a reference [method _links_far] says so of
## becomes a link: to a variable or an object with wires or links to it
## already, far from its card. Edits from the headset are the graph's and
## its windows' (D-090): a block the block menu adds for an object, with its
## Target, or a target picked in Parameters, gets its link as a wire does.
func _link_new_references(state: Dictionary) -> void:
	if not blueprint.operation_source in [&"vr_graph", &"vr_panel"]: return
	var always := _links_only()
	if not always and _document.features.get_value(XREFeatureSettings.AUTO_LINK) != XREFeatureSettings.ON: return
	for entry: Dictionary in state["nodes"]:
		var params: Dictionary = entry["params"]
		var before: Dictionary = blueprint.graph.find_node(int(entry["id"])).get("params", {})
		if entry["kind"] in ["get_variable", "set_variable"] and not str(params.get("variable", "")).is_empty() and params.get("variable") != before.get("variable"):
			if always or _links_far(entry, XREBlueprintLinks.VARIABLE, state): XREBlueprintLinks.set_link(entry, XREBlueprintLinks.VARIABLE, true)
		if XREBlueprintGraph.has_target(entry) and not str(params.get("target", "")).is_empty() and params.get("target") != before.get("target"):
			if always or _links_far(entry, XREBlueprintLinks.TARGET, state): XREBlueprintLinks.set_link(entry, XREBlueprintLinks.TARGET, true)


## Whether the new reference of [param key] of block [param entry] — its
## variable or its target — in [param state] should be a link by Auto link
## (D-090): other blocks refer to it more than [constant AUTO_LINK_REFERENCES]
## times already, by wires or links, and its wire would run farther than
## [constant AUTO_LINK_DISTANCE] — from the card, or the card an inline Get
## Variable feeds, to the variable's box or to the object.
func _links_far(entry: Dictionary, key: String, state: Dictionary) -> bool:
	var params: Dictionary = entry["params"]
	var field := "variable" if key == XREBlueprintLinks.VARIABLE else "target"
	var references := 0
	for block: Dictionary in blueprint.graph.nodes:
		if block["id"] == entry["id"] or (block.get("params", {}) as Dictionary).get(field) != params[field]: continue
		if key == XREBlueprintLinks.VARIABLE and not block["kind"] in ["get_variable", "set_variable"]: continue
		references += 1
	if references <= AUTO_LINK_REFERENCES: return false
	var end: Vector3
	if key == XREBlueprintLinks.VARIABLE:
		if not canvas.get_boxes().has_box(str(params[field])): return false
		end = canvas.get_boxes().box_point(str(params[field]))
	else:
		if not XREBlueprintTokens.targets_in_scene(_document.features.get_value(XREFeatureSettings.TARGET_INPUT)): return false
		var target := blueprint.resolve_target(str(params[field])) as Node3D
		if target == null or not target.is_inside_tree(): return false
		end = canvas.to_local(target.global_position)
	var card := entry
	if canvas.is_inline(entry):
		# An inline Get Variable shows on the card it feeds (D-061).
		for edge: Dictionary in state["edges"]:
			if edge["from"] != entry["id"]: continue
			for block: Dictionary in state["nodes"]:
				if block["id"] == edge["to"]: card = block
	return canvas.position_from_block(card).distance_to(end) > AUTO_LINK_DISTANCE


## Whether Link from wire is on Always (D-077): links are made by themselves
## and never become wires again, so no link or wire buttons.
func _links_only() -> bool:
	return _document.features.get_value(XREFeatureSettings.LINK_CREATE) == XREFeatureSettings.ALWAYS


## Makes the reference [param ref] (of [XREBlueprintLinks]) a link, its wire
## hidden, or with [param on] false a wire again, as one edit.
func _set_link(ref: Dictionary, on: bool) -> bool:
	var state := blueprint.graph.snapshot()
	var found := false
	for entry: Dictionary in state["nodes"]:
		if entry["id"] != int(ref["block"]): continue
		XREBlueprintLinks.set_link(entry, str(ref["key"]), on)
		found = true
	if not found: return false
	for pointer: Pointer in _pointers: _hide_button(pointer)
	if not blueprint.perform(blueprint.commit.bind("Make Link" if on else "Unlink", state), &"vr_graph"):
		_message(blueprint.last_error)
		return false
	_message("A link now: its wire is hidden; Settings → Link wires shows it." if on else "The link is a wire again.")
	return true


## The link button of [param pointer]'s ray on card [param id] (D-074): by a
## link [param link] under the ray, one that takes it back to its wire; with
## Link from wire on Port button, over a port or socket whose wire may become
## a link, one that makes it. [param point] is where the ray is on the card.
func _update_link_button(pointer: Pointer, id: int, kind: int, link: Dictionary, point: Vector3) -> void:
	var create := _document.features.get_value(XREFeatureSettings.LINK_CREATE)
	# With Always there are no buttons: every new wire is a link, and a link stays one (D-077).
	if has_wire(pointer.hand) or create == XREFeatureSettings.ALWAYS: return
	if not link.is_empty():
		# With Wire menu the trigger on the link itself takes it back to its wire (D-090).
		if not create in [XREFeatureSettings.PULL, XREFeatureSettings.WIRE_MENU]: _show_button(pointer, link, false, _button_above(id, point))
		return
	if create != XREFeatureSettings.PORT_BUTTON: return
	var ref := _linkable_at(id, kind)
	if ref.is_empty(): return
	_show_button(pointer, ref, true, _button_above(id, canvas.to_global(canvas.ref_point(ref))))


## Over [param point] on card [param id], toward the head: where a link button stands.
func _button_above(id: int, point: Vector3) -> Vector3:
	var up := (canvas.global_basis * canvas.get_block_transform(id).basis.y).normalized()
	return point + up * BUTTON_RISE + (_rig.camera.global_position - point).normalized() * BUTTON_LEAD


## The reference on card [param id] under the last ray whose wire may become a
## link (D-074): a port fed from a variable's box, a Target, a Source or a
## Variable wired to its object or box, and not a link yet; empty for none.
func _linkable_at(id: int, kind: int) -> Dictionary:
	var block := blueprint.graph.find_node(id)
	if block.is_empty(): return {}
	var port := canvas.get_hit_port()
	var target_port := XREBlueprintGraph.target_port(block)
	var ref: Dictionary = {}
	if kind == XREBlueprintCanvas.SOURCE or (kind == XREBlueprintCanvas.MEMBER and block["kind"] == "signal"):
		ref = XREBlueprintLinks.ref(id, XREBlueprintLinks.TARGET, id, -1, XREBlueprintCanvas.SOURCE)
	elif kind == XREBlueprintCanvas.MEMBER or (kind < 0 and port >= 0 and canvas.get_hit_input() and port == target_port):
		ref = XREBlueprintLinks.ref(id, XREBlueprintLinks.TARGET, id, target_port, -1)
	elif kind == XREBlueprintCanvas.VARIABLE:
		ref = XREBlueprintLinks.ref(id, XREBlueprintLinks.VARIABLE, id, -1, XREBlueprintCanvas.VARIABLE)
		if canvas.ref_wire(ref) == null: return {}
	elif kind < 0 and port >= 0 and canvas.get_hit_input():
		var getter := canvas.inline_getter(id, port)
		if getter < 0: return {}
		ref = XREBlueprintLinks.ref(getter, XREBlueprintLinks.VARIABLE, id, port, -1)
	if ref.is_empty(): return {}
	if ref["key"] == XREBlueprintLinks.TARGET:
		var wire := _target_wire_of(id)
		if wire == null or wire.link: return {}
	elif XREBlueprintLinks.is_link(blueprint.graph.find_node(int(ref["block"])), XREBlueprintLinks.VARIABLE): return {}
	return ref


## The wire to the scene object of block [param id], or null.
func _target_wire_of(id: int) -> TargetWire:
	for wire: TargetWire in _target_wires:
		if wire.id == id: return wire
	return null


## Puts up [param pointer]'s link button at [param point] (global) for
## [param ref]: "link" to make it a link with [param make], else "wire".
func _show_button(pointer: Pointer, ref: Dictionary, make: bool, point: Vector3) -> void:
	var text := "link" if make else "wire"
	if pointer.button == null or str(pointer.button.get_meta(&"text", "")) != text:
		if pointer.button != null: pointer.button.queue_free()
		pointer.button = XREBlueprintPetals.make_pill(text)
		pointer.button.name = "LinkButton"
		pointer.button.set_meta(&"text", text)
		pointer.button.top_level = true
		add_child(pointer.button)
	pointer.button_ref = ref
	pointer.button_make = make
	pointer.button_point = point
	pointer.button_hold = BUTTON_HOLD
	pointer.button.visible = true


func _hide_button(pointer: Pointer) -> void:
	pointer.button_ref = {}
	pointer.button_hold = 0.0
	if pointer.button != null: pointer.button.visible = false


## Turns the link buttons to the head where they stand; one the rays left
## [constant BUTTON_HOLD] ago goes. Every frame, without allocating.
func _update_buttons(delta: float) -> void:
	var head := _rig.camera.global_position
	for pointer: Pointer in _pointers:
		if pointer.button == null or not pointer.button.visible: continue
		pointer.button_hold -= delta
		if pointer.button_hold <= 0.0 or not _workspace.visible:
			_hide_button(pointer)
			continue
		var grown := 1.15 if pointer.button.get_meta(&"hot", false) else 1.0
		pointer.button.global_transform = Transform3D(XREBlueprintPetals.face(pointer.button_point, head, Vector3.UP) * Basis.from_scale(Vector3.ONE * grown), pointer.button_point)
		pointer.button.set_meta(&"hot", false)


## Where the ray from [param origin] along [param direction] meets the link
## button [param pill], in units of [param direction], or -1.
func _pill_distance(pill: Node3D, origin: Vector3, direction: Vector3) -> float:
	var inverse := pill.global_transform.affine_inverse()
	var local_origin := inverse * origin
	var local_direction := inverse.basis * direction
	if absf(local_direction.z) < 0.000001: return -1.0
	var along := -local_origin.z / local_direction.z
	if along < 0.0: return -1.0
	var at := local_origin + local_direction * along
	var margin := 0.006
	if absf(at.x) > float(pill.get_meta(&"width")) * 0.5 + margin or absf(at.y) > XREBlueprintPetals.PILL_HEIGHT * 0.5 + margin: return -1.0
	return along


## The ray on [param pointer]'s link button: it grows and stays; the trigger
## makes its link or takes it back to its wire. False if the ray is not on it,
## or [param canvas_hit] — a card's — is nearer.
func _point_at_button(pointer: Pointer, origin: Vector3, direction: Vector3, canvas_hit: float) -> bool:
	if pointer.button == null or not pointer.button.visible or pointer.button_ref.is_empty() or has_wire(pointer.hand): return false
	var hit := _pill_distance(pointer.button, origin, direction)
	if hit < 0.0 or (canvas_hit >= 0.0 and hit > canvas_hit + 0.03): return false
	var hand := pointer.hand
	hand.claim(self)
	hand.show_ray(hit, true)
	canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
	canvas.hover_socket(-1, -1, hand == _rig.right_hand)
	pointer.focus = int(pointer.button_ref["card"])
	pointer.button_hold = BUTTON_HOLD
	pointer.button.set_meta(&"hot", true)
	if hand.trigger_pressed: _set_link(pointer.button_ref, pointer.button_make)
	return true


## The nearest drawn wire that may become a link — from a variable's box, or
## to a scene object — on the ray within [param limit], not a link yet: its
## distance, or -1; [member _wire_ref] and [member _wire_point] say which and where.
func _link_wire_hit(origin: Vector3, direction: Vector3, limit: float) -> float:
	_wire_ref = {}
	var nearest := canvas.intersect_link_wire(origin, direction, limit)
	if nearest >= 0.0:
		_wire_ref = canvas.get_wire_ref()
		_wire_point = canvas.get_wire_point()
	for wire: TargetWire in _target_wires:
		if wire.link or not wire.mesh.visible: continue
		var hit := canvas.intersect_wire(wire.canvas_wire, origin, direction, nearest if nearest >= 0.0 else limit)
		if hit < 0.0: continue
		nearest = hit
		_wire_ref = XREBlueprintLinks.ref(wire.id, XREBlueprintLinks.TARGET, wire.id, -1 if wire.source else wire.port, XREBlueprintCanvas.SOURCE if wire.source else -1)
		_wire_point = origin + direction * hit
	return nearest


## The ray on a wire that may become a link, nearer than [param limit] (D-074):
## with Link from wire on Wire button a link button stands where the ray is on
## it; on Pull the grip takes the wire to pull it into its port. False with
## Port button, or with no such wire on the ray.
## [param bent]: the canvas's ray is on a wire while wires bend (D-081). The
## wire is then the bends' as well: looked for a little past that hit, it puts
## up its link button above the wire, as over a port, and false lets the bends
## have the ray — trigger and grip drag a bend —, but on Pull the grip still
## pulls it into its port.
func _point_at_link_wire(pointer: Pointer, origin: Vector3, direction: Vector3, limit: float, bent: bool = false) -> bool:
	var create := _document.features.get_value(XREFeatureSettings.LINK_CREATE)
	var hand := pointer.hand
	pointer.wire_ref = {}
	if create in [XREFeatureSettings.PORT_BUTTON, XREFeatureSettings.ALWAYS] or has_wire(hand) or _target_pick >= 0: return false
	var hit := _link_wire_hit(origin, direction, limit + XREBlueprintCanvas.WIRE_REACH * 2.0 if bent else limit)
	if hit < 0.0: return false
	if create == XREFeatureSettings.WIRE_MENU: pointer.wire_ref = _wire_ref
	if bent:
		pointer.focus = int(_wire_ref["card"])
		# With Wire menu the trigger on the bends' wire opens its menu, Link in it ([method _point_at_wire]).
		if create == XREFeatureSettings.WIRE_BUTTON:
			# On the wire the button would take the ray from it, and the trigger would make a link, not
			# a bend: it stands up across the ray, so that a ray from above doesn't foreshorten the rise.
			var up := Vector3.UP - direction * direction.dot(Vector3.UP)
			up = up.normalized() if not up.is_zero_approx() else canvas.global_basis.y.normalized()
			_show_button(pointer, _wire_ref, true, _wire_point + up * BUTTON_RISE - direction * BUTTON_LEAD)
		elif create == XREFeatureSettings.PULL and hand.grip_pressed:
			hand.show_ray(hit, true)
			_start_pull(pointer, _wire_ref, hit)
			return true
		return false
	hand.claim(self)
	hand.show_ray(hit, true)
	canvas.hover_actions(-1, false, false, hand == _rig.right_hand)
	canvas.hover_socket(-1, -1, hand == _rig.right_hand)
	pointer.focus = int(_wire_ref["card"])
	if create == XREFeatureSettings.WIRE_BUTTON: _show_button(pointer, _wire_ref, true, _wire_point + (_rig.camera.global_position - _wire_point).normalized() * BUTTON_LEAD)
	elif create == XREFeatureSettings.WIRE_MENU:
		# A wire the canvas doesn't bend, with Wire bends off: its menu has Link alone.
		if hand.trigger_pressed: _open_wire_menu(pointer, -1, -1, _wire_ref)
	elif hand.grip_pressed: _start_pull(pointer, _wire_ref, hit)
	return true


## The grip takes the wire of [param ref] at [param distance] along the ray, to pull it into its port.
func _start_pull(pointer: Pointer, ref: Dictionary, distance: float) -> void:
	var hand := pointer.hand
	pointer.pull = ref
	pointer.pull_distance = distance
	pointer.pull_start = hand.global_position - hand.global_basis.z.normalized() * distance
	pointer.pull_wire = _ref_mesh(ref)
	if pointer.pull_wire != null: _show_ref_wire(ref, false)
	hand.claim(self)
	_message("Pull the wire into its port and let go: it becomes a link.")


## The mesh the wire of [param ref] is drawn as, or null: up to its first bend (D-081).
func _ref_mesh(ref: Dictionary) -> XREGraphWire:
	if ref["key"] == XREBlueprintLinks.VARIABLE: return canvas.ref_wire(ref)
	var wire := _target_wire_of(int(ref["card"]))
	return wire.mesh if wire != null else null


## Shows or hides the wire of [param ref], every tube and knot of it (D-081).
func _show_ref_wire(ref: Dictionary, shown: bool) -> void:
	if ref["key"] == XREBlueprintLinks.VARIABLE:
		canvas.show_ref_wire(ref, shown)
		return
	var wire := _target_wire_of(int(ref["card"]))
	if wire != null: canvas.set_wire_shown(wire.canvas_wire, shown)


## Whether a hand pulls [param mesh] into its port now.
func _is_pulled(mesh: XREGraphWire) -> bool:
	for pointer: Pointer in _pointers:
		if pointer.pull_wire == mesh and not pointer.pull.is_empty(): return true
	return false


## Where the wire of [param ref] goes into its card, in the canvas's space: its
## port, its Source or Variable socket, an adapter's far end.
func _ref_start(ref: Dictionary) -> Vector3:
	if ref["key"] == XREBlueprintLinks.TARGET:
		var end: Variant = canvas.adapter_end(int(ref["card"]))
		if end is Vector3: return end
	return canvas.ref_point(ref)


## The wire follows the grip from its port; let go most of the way to the
## port ([constant PULL_DONE]), it becomes a link, else it is as it was.
func _update_pull(pointer: Pointer) -> void:
	var hand := pointer.hand
	var point := hand.global_position - hand.global_basis.z.normalized() * pointer.pull_distance
	var port := canvas.to_global(_ref_start(pointer.pull))
	var progress := 1.0 - point.distance_to(port) / maxf(pointer.pull_start.distance_to(port), 0.01)
	canvas.show_link(canvas.to_local(port), canvas.to_local(point))
	hand.show_ray(pointer.pull_distance, true)
	pointer.focus = int(pointer.pull["card"])
	if hand.get_has_tracking_data() and hand.grip_held: return
	_end_pull(pointer, hand.get_has_tracking_data() and progress >= PULL_DONE)


func _end_pull(pointer: Pointer, commit: bool) -> void:
	var ref := pointer.pull
	pointer.pull = {}
	if pointer.pull_wire != null and ref["key"] == XREBlueprintLinks.VARIABLE: _show_ref_wire(ref, true)
	pointer.pull_wire = null
	canvas.hide_connection()
	pointer.hand.unclaim(self)
	pointer.hand.show_ray(XREHand.RAY_LENGTH, false)
	if commit: _set_link(ref, true)
	else: _message("The wire stays a wire: pull it all the way into its port.")


## The trigger on a link (D-074): a wire from its port or socket, as from a
## wired one, to another box or object; what it ends on is a link too.
func _retarget_link(ref: Dictionary, hand: XREHand) -> void:
	var card := int(ref["card"])
	var kind := int(ref["kind"])
	if kind == XREBlueprintCanvas.VARIABLE or kind == XREBlueprintCanvas.SOURCE:
		_start_link(card, kind, hand)
		return
	var port := int(ref["port"])
	var edges := canvas.port_edges(card, port, true)
	click_port(card, port, true, hand, edges[0] if not edges.is_empty() else -1)


## What a link [param ref] carried away holds: its variable, or the target path
## [param value] — as [method XREBlueprintCanvas.get_hit_link_value] says.
static func _link_value(ref: Dictionary, value: String) -> Dictionary:
	return XREBlueprintLinks.of_variable(value) if ref["key"] == XREBlueprintLinks.VARIABLE else XREBlueprintLinks.of_target(value)


## The grip, or the trigger with [param by_trigger], carries the link
## [param value]: from the tray with no [param source], else the link of
## [param source] itself, which leaves its port at once (D-058), or a copy by a
## grip of the other hand. Let go in a port it goes there; in the air a link
## from a port is a wire again.
func _carry_link(pointer: Pointer, value: Dictionary, source: Dictionary, by_trigger: bool = false) -> void:
	var what := str(value["link"])
	var text := "link"
	var type := XREBlueprintGraph.EXEC
	if what == XREBlueprintLinks.VARIABLE:
		text = str(value["name"])
		type = XREBlueprintGraph.port_type(XREBlueprintGraph.variable_type(blueprint.graph.find_variable(text)))
	elif what == XREBlueprintLinks.TARGET:
		var path := str(value["path"])
		text = "self" if path in [".", ""] else path.get_file()
		type = XREBlueprintGraph.OBJECT
	pointer.carried = XREBlueprintCanvas.make_link(text, XREBlueprintTokens.width(text), type)
	pointer.carried.top_level = true
	add_child(pointer.carried)
	pointer.carried_value = value
	pointer.carried_key = XREBlueprintLinks.KEY
	pointer.carried_block = -1
	pointer.carried_copy = source.is_empty()
	pointer.carried_trigger = by_trigger
	pointer.carried_ref = source
	pointer.hand.claim(self)
	if not source.is_empty(): canvas.hide_link(source, true)
	_update_carried(pointer)


## Where a link dropped now would go, from the last ray [param hit] (D-074):
## [code]{"block", "port", "kind"}[/code] — an input port, a Source or a
## Variable socket, a link's place — or empty.
func _link_dock(hit: float) -> Dictionary:
	if hit < 0.0 or canvas.get_hit_box(): return {}
	var id := canvas.get_hit_id()
	var block := blueprint.graph.find_node(id)
	if block.is_empty(): return {}
	var kind := canvas.get_hit_socket_kind()
	match kind:
		XREBlueprintCanvas.LINK:
			var ring := canvas.get_hit_link()
			return {"block": id, "port": ring["port"], "kind": ring["kind"]}
		XREBlueprintCanvas.SOURCE, XREBlueprintCanvas.VARIABLE:
			return {"block": id, "port": -1, "kind": kind}
		XREBlueprintCanvas.MEMBER:
			if block["kind"] == "signal": return {"block": id, "port": -1, "kind": XREBlueprintCanvas.SOURCE}
			return {"block": id, "port": XREBlueprintGraph.target_port(block), "kind": -1}
		XREBlueprintCanvas.TOKEN:
			if canvas.get_hit_socket_port() >= 0: return {"block": id, "port": canvas.get_hit_socket_port(), "kind": -1}
	if canvas.get_hit_port() >= 0 and canvas.get_hit_input(): return {"block": id, "port": canvas.get_hit_port(), "kind": -1}
	return {}


## Lets go of [param pointer]'s carried link over [param slot] ([method _link_dock]).
func _drop_link(pointer: Pointer, slot: Dictionary) -> void:
	var value: Dictionary = pointer.carried_value
	var source := pointer.carried_ref
	var copy := pointer.carried_copy
	var hand := pointer.hand
	pointer.carried.queue_free()
	pointer.carried = null
	pointer.carried_ref = {}
	hand.unclaim(self)
	hand.show_ray(XREHand.RAY_LENGTH, false)
	if not source.is_empty(): canvas.hide_link(source, false)
	if slot.is_empty():
		# Let go in the air, a link taken from its port is its wire again; a copy or the tray's just goes.
		# With Always a link never becomes a wire: it goes back to its port (D-077).
		if not source.is_empty() and not copy and not _links_only(): _set_link(source, false)
		return
	if not source.is_empty() and int(slot["block"]) == int(source["card"]) and int(slot["port"]) == int(source["port"]) and int(slot["kind"]) == int(source["kind"]): return
	if str(value["link"]).is_empty(): _dock_blank_link(slot, hand)
	else: _dock_link(value, slot, {} if copy else source)


## A link from the tray laid on [param slot] (D-074): the wire there to a
## variable's box or a scene object becomes a link; on a free input, a wire
## from it waits for a box, whose link it then is.
func _dock_blank_link(slot: Dictionary, hand: XREHand) -> void:
	var id := int(slot["block"])
	var port := int(slot["port"])
	var kind := int(slot["kind"])
	var block := blueprint.graph.find_node(id)
	if kind == XREBlueprintCanvas.SOURCE or (kind < 0 and port >= 0 and port == XREBlueprintGraph.target_port(block)):
		if not XREBlueprintTokens.targets_in_scene(_document.features.get_value(XREFeatureSettings.TARGET_INPUT)):
			_message("Links to objects need Targets on Node, Scene or Adapter.")
			return
		if kind < 0 and blueprint.target_is_connected(id):
			_message("A wire from a block brings this Target: links stand for objects of the scene.")
			return
		_set_link(XREBlueprintLinks.ref(id, XREBlueprintLinks.TARGET, id, port, kind), true)
		return
	if _document.features.get_value(XREFeatureSettings.VARIABLE_INPUT) != XREFeatureSettings.BOXES:
		_message("Links to variables need Variables on Boxes.")
		return
	if kind == XREBlueprintCanvas.VARIABLE:
		_set_link(XREBlueprintLinks.ref(id, XREBlueprintLinks.VARIABLE, id, -1, kind), true)
		if str((block["params"] as Dictionary).get("variable", "")).is_empty(): _start_link(id, kind, hand)
		return
	var getter := canvas.inline_getter(id, port)
	if getter >= 0:
		_set_link(XREBlueprintLinks.ref(getter, XREBlueprintLinks.VARIABLE, id, port, -1), true)
		return
	for edge: Dictionary in blueprint.graph.edges:
		if edge["to"] == id and edge["to_port"] == port:
			_message("A wire from a block comes in here: links stand for variables and objects.")
			return
	cancel_connection()
	_pending_id = id
	_pending_port = port
	_pending_input = true
	_pending_hand = hand
	_pending_link = true
	canvas.highlight_ports(canvas.port_type(id, port, true), false)
	_message("Press trigger on a variable's box: its link goes in this port.")


## A link of a variable or an object [param value] let go on [param slot]
## (D-074): the slot reads that variable or targets that object through a link,
## as one edit; moved from [param source] (empty for a copy), it leaves there
## what a token leaves — a port's default, a socket's wire.
func _dock_link(value: Dictionary, slot: Dictionary, source: Dictionary) -> void:
	var id := int(slot["block"])
	var port := int(slot["port"])
	var kind := int(slot["kind"])
	var block := blueprint.graph.find_node(id)
	var target_slot := kind == XREBlueprintCanvas.SOURCE or (kind < 0 and port >= 0 and port == XREBlueprintGraph.target_port(block))
	if value["link"] == XREBlueprintLinks.TARGET:
		if not target_slot:
			_message("An object's link goes into a Target or a Source.")
			return
		var node := blueprint.resolve_target(str(value["path"]))
		if node == null:
			_message("The link's object is not in this scene.")
			return
		if kind < 0 and blueprint.target_is_connected(id):
			_message("A wire from a block brings this Target: links stand for objects of the scene.")
			return
		var edits := {id: {XREBlueprintLinks.FIELD: XREBlueprintLinks.field_with(block, XREBlueprintLinks.TARGET, true)}}
		if not source.is_empty() and int(source["block"]) != id:
			edits[int(source["block"])] = {XREBlueprintLinks.FIELD: XREBlueprintLinks.field_with(blueprint.graph.find_node(int(source["block"])), str(source["key"]), false)}
		if blueprint.perform(blueprint.choose_target.bind(id, node, edits), &"vr_graph"): _message("A link to %s." % node.name)
		else: _message(blueprint.last_error)
		return
	var variable_name := str(value["name"])
	var variable := blueprint.graph.find_variable(variable_name)
	if variable.is_empty() or _document.features.get_value(XREFeatureSettings.VARIABLE_INPUT) != XREFeatureSettings.BOXES:
		_message("Links to variables need Variables on Boxes.")
		return
	var state := blueprint.graph.snapshot()
	if kind == XREBlueprintCanvas.VARIABLE:
		for entry: Dictionary in state["nodes"]:
			if entry["id"] != id: continue
			entry["params"]["variable"] = variable_name
			if entry["kind"] == "set_variable": entry["params"]["value"] = variable.get("value", XREBlueprintSchema.default_value(XREBlueprintGraph.variable_type(variable)))
			XREBlueprintLinks.set_link(entry, XREBlueprintLinks.VARIABLE, true)
	elif kind < 0 and port >= 0 and not target_slot:
		if not XREBlueprintGraph.ports_compatible(XREBlueprintGraph.port_type(XREBlueprintGraph.variable_type(variable)), canvas.port_type(id, port, true)):
			_message("%s doesn't fit there." % variable_name)
			return
		# As a token takes a wire's place (D-066): what came into the port goes.
		state["edges"] = (state["edges"] as Array).filter(func(edge: Dictionary) -> bool: return not (edge["to"] == id and edge["to_port"] == port))
		var getter := XREBlueprintGraph.make_node(blueprint.next_id(), "get_variable", (block["position"] as Vector2) + Vector2(-300, 40 + 50 * port))
		getter["params"]["variable"] = variable_name
		getter["vr_inline"] = true
		getter["vr_depth"] = float(block.get("vr_depth", 0.0))
		XREBlueprintLinks.set_link(getter, XREBlueprintLinks.VARIABLE, true)
		(state["nodes"] as Array).append(getter)
		(state["edges"] as Array).append({"from": getter["id"], "from_port": 0, "to": id, "to_port": port})
	else:
		_message("A variable's link goes into a port of its type or a Variable.")
		return
	if not source.is_empty():
		if source["key"] == XREBlueprintLinks.VARIABLE and int(source["kind"]) < 0:
			# Its Get Variable goes with it; the port it fed gets its default token (D-059).
			var getter_id := int(source["block"])
			state["edges"] = (state["edges"] as Array).filter(func(edge: Dictionary) -> bool: return edge["from"] != getter_id)
		else:
			for entry: Dictionary in state["nodes"]:
				if entry["id"] == int(source["block"]): XREBlueprintLinks.set_link(entry, str(source["key"]), false)
	_drop_orphan_inlines(state)
	_fill_sockets(state)
	if blueprint.perform(blueprint.commit.bind("Move Link" if not source.is_empty() else "Dock Link", state), &"vr_graph"): _message("A link to %s." % variable_name)
	else: _message(blueprint.last_error)


## Puts the projections of their objects in the rings of the target links that
## wait for one (D-074): once for each ring, as the canvas is built.
func _fill_link_heads() -> void:
	for item: Array in canvas.target_heads():
		var inside: Node3D = item[1]
		if inside.get_child_count() > 0: continue
		var target := blueprint.target_node(int(item[0]))
		if target is Node3D: _project(target as Node3D, inside)


## A projection of [param target] in [param inside]: the meshes of its own
## geometry and of its children's, CSG baked, a light's icon, in their colours
## and shaded as wires are, fitted to a link's ring. Built from nodes and
## meshes the scene has; nothing of the scene changes (invariant 1).
func _project(target: Node3D, inside: Node3D) -> void:
	var inverse := target.global_transform.affine_inverse()
	var holder := Node3D.new()
	holder.name = "Projection"
	var bounds := AABB()
	var found := false
	var pending: Array[Node] = [target]
	var visited := 0
	while not pending.is_empty() and holder.get_child_count() < PROJECTION_PARTS and visited < PROJECTION_NODES:
		var node: Node = pending.pop_back()
		visited += 1
		pending.append_array(node.get_children())
		var spatial := node as Node3D
		if spatial == null or not spatial.visible: continue
		var mesh: Mesh
		var color := Color.WHITE
		var local := inverse * spatial.global_transform
		if node is CSGShape3D:
			var shape := node as CSGShape3D
			if not shape.is_root_shape(): continue
			var key := shape.get_instance_id()
			if not _projection_meshes.has(key): _projection_meshes[key] = shape.bake_static_mesh()
			mesh = _projection_meshes[key]
			var paint: Material = shape.material_override
			# A box's, a sphere's… material: each primitive has its own property, not their base class.
			if paint == null and shape is CSGPrimitive3D: paint = shape.get(&"material") as Material
			color = _albedo(paint, color)
		elif node is MeshInstance3D:
			var instance := node as MeshInstance3D
			mesh = instance.mesh
			if mesh != null and mesh.get_surface_count() > 0: color = _albedo(instance.get_active_material(0), color)
		elif node is Light3D:
			mesh = XREIcons.mesh_for(StringName(node.get_class()))
			color = (node as Light3D).light_color
			local = local * Transform3D(Basis.from_scale(Vector3.ONE * 0.1), Vector3.ZERO)
		if mesh == null: continue
		var part := XRERig.create_vr_mesh(mesh, XREBlueprintCanvas.wire_material(color))
		part.transform = local
		holder.add_child(part)
		var box := local * mesh.get_aabb()
		bounds = bounds.merge(box) if found else box
		found = true
	var largest := maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	if not found or largest < 0.0001:
		holder.free()
		return
	var fit := XREBlueprintCanvas.LINK_RING * 1.3 / largest
	holder.transform = Transform3D(Basis.from_scale(Vector3.ONE * fit), -bounds.get_center() * fit)
	inside.add_child(holder)


## The colour [param material] paints in, or [param fallback] for one without an albedo.
static func _albedo(material: Material, fallback: Color) -> Color:
	var standard := material as BaseMaterial3D
	return Color(standard.albedo_color, 1.0) if standard != null else fallback
