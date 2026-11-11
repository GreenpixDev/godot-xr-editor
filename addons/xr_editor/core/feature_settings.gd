@tool
class_name XREFeatureSettings
extends RefCounted
## Variants of features under study (docs/decisions.md, D-039). When a feature
## has competing designs to compare on participants, each design is a value of
## one setting here, not a separate branch or a constant in code: the
## researcher switches it in the headset ([XRESettingsTab]) between sessions.
##
## Every setting belongs to a [enum Category], which is a section of the
## settings tab, and in the Editor section to a subsection of [constant GROUPS]
## (D-116). A setting that only acts with certain values of others names them
## in [code]requires[/code] ([method is_active]). Its first value is the default. Values are switched through
## [method XREDocument.set_feature], so that the switch is an operation in the
## study's log; tools read them with [method get_value] and redraw on
## [signal changed]. With a [member path] the values persist across editor
## restarts; without one (tests) they live in memory.
##
## Adding a variant: a new value in an existing setting's [code]values[/code]
## if it competes with the others, otherwise a new entry in [constant DEFINITIONS].

## Emitted after the value of setting [param key] changed. Switching the
## controls layout or rebinding an action emits it with [constant CONTROLS].
signal changed(key: StringName)

## Sections of the settings tab, in its order (D-116).
enum Category {
	## What isn't one tool's: the settings tab itself.
	GLOBAL,
	## How the editor's features look and behave, in the subsections of [constant GROUPS].
	EDITOR,
	## Which controller buttons do what: the layout and its bindings (D-050).
	CONTROLS,
	## How the headset's frame is drawn and what it costs (D-164): antialiasing and the drawing's
	## performance variants. Not in the settings tab until its mockup is approved.
	GRAPHICS,
}

## Subsections of the Editor section, in order, by the names settings give in
## [code]group[/code]: what they change.
const GROUPS: Dictionary[StringName, String] = {
	&"cards": "Cards",
	&"view": "View",
	&"values": "Values",
	&"objects": "Objects",
	&"wires": "Wires",
	&"blocks": "Blocks",
}

## Where the settings tab shows a section's subsections (D-116).
const SETTINGS_SUBSECTIONS := &"settings_subsections"
## A row over the settings, dragged sideways when it doesn't fit, as the controls layouts are.
const ROW := &"row"
## Under the section's name on the left, opened and closed by it.
const TREE := &"tree"

## How the VR view smooths its edges (D-134): multisampling of the headset's
## view and of the simulator's window. Auto, as before: 4× on a standalone
## headset, whose tiled GPU resolves it on chip, and in the simulator; none on
## a PC headset. Off, 2×, 4× or 8× everywhere: more samples cost GPU time.
## D-153 adds the engine's other ways, as [method XRESession.apply_antialiasing]
## sets them: FXAA, SMAA, TAA, supersampling and 16 samples a pixel, as MSAA 4×
## with SSAA 2×, since the engine's and the GPU's MSAA ends at 8×.
const ANTIALIASING := &"antialiasing"
## How the wires' arrowheads are laid out each time they move (D-166): natively, by [XREGraphArrows] in one
## call; or in GDScript, as before. The same poses and colours.
const ARROW_LAYOUT := &"arrow_layout"
## Whether the logic graph's parts of one look share their material and mesh (D-167): Shared, made once
## for each colour and shape; Per part, each its own, as before. They look the same.
const GRAPH_MATERIALS := &"graph_materials"
## How a logic graph card's parts are drawn (D-168): Per node, each by itself, as before; Merged, its ports of
## one look as one mesh, merged again when one changes. Per node first until a headset run shows Merged's gain.
## Card merged (D-170): every flat part of one look — ports, rims, plus, trash, tokens' faces, the face — merged,
## again whenever anything under the card changes.
const GRAPH_DRAWING := &"graph_drawing"
const MERGED := &"merged"
const CARD_MERGED := &"card_merged"
const PER_NODE := &"per_node"
## How the logic graph answers the hands' rays (D-169): Each call, every ask worked out, as before; Per frame,
## the same ray asked again in a frame, with nothing changed, answered as the first time. The same answers.
const RAY_PICKING := &"ray_picking"
const EACH_CALL := &"each_call"
const PER_FRAME := &"per_frame"
## How a ray finds the logic graph's wires it passes near (D-169): in GDScript, as before; or natively, by
## [XREGraphWirePicker] in one call. The same wires.
const WIRE_PICKING := &"wire_picking"
const PER_PART := &"per_part"
const NATIVE := &"native"
const SCRIPT := &"script"
## Whether the editor's own window is drawn while its 2D UI is hidden in VR (D-165): always on a
## standalone headset, on a PC with --hide-ui. Paused stops its viewport, the root, from updating;
## Live draws it as before. A key or a click in the window shows the UI, and draws it, at once.
const EDITOR_WINDOW := &"editor_window"
const PAUSED := &"paused"
const LIVE := &"live"
const MSAA_2X := &"msaa_2x"
const MSAA_4X := &"msaa_4x"
const MSAA_8X := &"msaa_8x"
const MSAA_4X_SSAA_2X := &"msaa_4x_ssaa_2x"
const FXAA := &"fxaa"
const SMAA := &"smaa"
const TAA := &"taa"
const SSAA_1_5X := &"ssaa_1_5x"
const SSAA_2X := &"ssaa_2x"

## Which logic graph nodes turn towards the head ([XREBlueprintCanvas], D-115;
## with [constant NODE_VOLUME] it took the place of Node display, D-039):
## [constant ON] all of them, as Billboard did; only the shorthands — signs,
## beads, tags, operators and the variables' boxes —; [constant OFF] none, as
## Cuboid did: they stand in the orientation of the graph, or of their part.
const NODE_FACING := &"node_facing"
const SHORTHANDS := &"shorthands"
## Whether nodes are flat ([constant FLAT]) or solid, 1.2 cm deep (D-115).
const NODE_VOLUME := &"node_volume"
const SOLID := &"solid"
## What a node that doesn't turn to the head shows from behind (D-115): its
## blank back, or its face laid out as a mirror's — inputs on the right, the
## text readable, icons and execution arrows along the flow.
const NODE_BACK := &"node_back"
const BLANK := &"blank"
const LABELLED := &"labelled"
## Where a node's ports are (D-115): on whichever of its faces is turned to
## the head (the default since D-133); on its face, as before; or on its edge, balls and arrowheads that
## stand out of a node thinner than they are, seen from every side.
const PIN_PLACE := &"pin_place"
const FACE := &"face"
const BOTH_FACES := &"both_faces"
const EDGE := &"edge"
## Whether cards turned to the head lay themselves out as a mirror's (D-115,
## on by default since D-133): inputs on the right, so that their wires leave
## towards their neighbours — a card whose wires run to the head's left
## (D-132), one without wires across the view past 90° from the front of its
## graph or part.
const CARD_MIRROR := &"card_mirror"
## Where the ports of the shorthands' signs are (D-115): each on the rim
## towards the far end of its wire, at most 90° from its side (D-132; the
## default since D-133); or inputs on the left, the result on the right, as before.
const SIGN_PORTS := &"sign_ports"
const SIDES := &"sides"
const RIM := &"rim"
## Whether the graph turns to the head about the vertical (D-115): never; by
## 180° past 95° from its front; to the nearest of its four fronts past 50°;
## or once to the head when a ray first comes onto it. Never while a card, a
## box, a bend or a wire is held.
const GRAPH_TURN := &"graph_turn"
const FIXED := &"fixed"
const FLIP := &"flip"
const STEPS := &"steps"
const AIM := &"aim"
## What turns and mirrors as one (D-115): the whole graph about its centre, or
## each of its parts about its own — cards of one orientation
## ([code]vr_rotation[/code]) wired together.
const GRAPH_PARTS := &"graph_parts"
const PARTS := &"parts"
## Arrowheads on logic graph wires along their flow, from output to input and
## from an object to its Target (D-115), for execution wires and data wires
## apart: chevrons every 9 cm, the same running, or one at the end. Running on
## execution wires and one at the end on data wires by default since D-133.
const EXEC_ARROWS := &"exec_arrows"
const DATA_ARROWS := &"data_arrows"
const CHEVRONS := &"chevrons"
const RUNNING := &"running"
const AT_END := &"at_end"
## How wires' arrowheads are drawn (D-115): open ones, two strokes as ">",
## turned about the wire to the head (the default since D-133), or filled cones.
const ARROW_STYLE := &"arrow_style"
const FILLED := &"filled"
const OPEN := &"open"

## How the ports of logic graph cards are drawn ([XREBlueprintCanvas], D-043).
const PORT_DISPLAY := &"port_display"
## Flat discs on the card's face.
const FLAT := &"flat"
## Round, shaded spheres standing out of the card's face.
const SPHERE := &"sphere"

## What a logic graph card shows of its block ([XREBlueprintCanvas], D-099).
const NODE_STYLE := &"node_style"
## As before: one face in its group's color, the title with the block's id, a trash in the header.
const CLASSIC := &"classic"
## A header in its group's color with an icon (signals, Set, functions, flow),
## none on a pure function, framed in its result's color; the trash only on
## what the ray is on, and the delete button deletes it.
const ARCHETYPES := &"archetypes"

## Which blocks archetypes draw as signs, not cards ([XREBlueprintShapes], D-100):
## each value adds to the one before. Classic cards ignore it.
const NODE_SHRINK := &"node_shrink"
## Only the operators: arithmetic a circle, a comparison a diamond, logic a pill.
const OPERATORS := &"operators"
## The math functions too, as sin, abs, √, min, clamp and lerp: a circle with a
## second rim and the name, an oval for three inputs.
const MATH := &"math"
## Delay too, a bead on the execution's white thread, and Get Time and Random, rings (D-103).
const SYSTEM := &"system"
## Every block with an icon of its own and at most three ports a side, not an
## event: a function a bead in its group's colour, a pure function a ring (D-103).
const ICONS := &"icons"

## What an archetype's header says of a block with a member — a signal, a
## property, an animation, a variable (D-101): the operation, its member
## then on the adapter, or the member itself, the wire to the object or box
## bare. A card may be switched on its own (its block's vr_heading).
const NODE_HEADING := &"node_heading"
## "On Signal", "Set", "Play Animation"; the member on the adapter, the name or the link.
const OPERATION := &"operation"
## "body_entered", "light_energy", "gate_open" over a small "On Signal" or "Set".
const MEMBER := &"member"

## How a vector's or a colour's variable gives its components (D-105): whole,
## a Break taking them apart, or split, an output of each on its box, the
## Break under it hidden as an inline Get Variable is (D-061).
const COMPOSITE_VALUES := &"composite_values"
const WHOLE := &"whole"
const SPLIT := &"split"
## Whether a logic graph port's shape says its type too, its colour as before
## (D-104): execution an arrow, bool a diamond, int a square, float a
## circle, text a pill, a vector a triangle, an object a hexagon, a colour a
## half-filled circle, any value a ring. Int and float, side by side, differ
## by more than their hue (D-080).
const PORT_SHAPES := &"port_shapes"

## Shape of the windows (rig-locked panels, docs/vr_ui.md; D-043). The tab
## launcher is concave either way.
const WINDOW_SHAPE := &"window_shape"
## Bent around the user: the edges come nearer, as the launcher's do.
const CONCAVE := &"concave"

## Parameters of logic graph blocks as objects of the graph (D-052): each of the
## four settings takes one kind of parameter out of the parameters window.
## Literal values — durations, conditions, values, an event's policy, wait.
const VALUE_INPUT := &"value_input"
## In the block's parameters window, as before.
const WINDOW := &"window"
## Tokens: pucks lying in slots on the card's rows.
const PUCKS := &"pucks"
## Tokens: plugs in the ports, sticking out to the left of the card.
const PLUGS := &"plugs"
## The target object and its member — a property, a signal, an animation.
## Every value but Window wires the Target to the object in the scene; they
## differ in where the member's name shows (D-057).
const TARGET_INPUT := &"target_input"
## The member's name on the card, after Target or Source; the wire ends at the object.
const ON_NODE := &"node"
## The member's name only on a petal on a stem from the object, where the wire ends.
const SCENE := &"scene"
## An adapter: a plug in the Target (or Source) port, like a token, with the
## member's name on it, and the wire to the object leaves its far end (D-059).
const ADAPTER := &"adapter"
## Whether Play Animation waits for its animation.
const ANIMATION_WAIT := &"animation_wait"
## A wait flag, as before.
const FLAG := &"flag"
## Which output is wired: Then goes on at once, Finished after the animation.
const FINISHED_PORT := &"finished_port"
## The variable of Get and Set Variable.
const VARIABLE_INPUT := &"variable_input"
## A wire to the variable's box on a shelf beside the graph.
const BOXES := &"boxes"
## A window of ready tokens beside the graph, as Objects is for the scene; with tokens only.
const TOKEN_TRAY := &"token_tray"
## A wire from a petal of the selected object let go in the graph adds the block for that member.
const SCENE_CREATE := &"scene_create"
const OFF := &"off"
const ON := &"on"
## The plus on a card, which opens the block menu wired to its execution
## output (D-058). Hidden by default (D-076): a block is added by a wire let
## go in empty space (D-051) or from the Blueprints tab.
const CARD_PLUS := &"card_plus"
const SHOWN := &"shown"
const HIDDEN := &"hidden"
## How a color token is edited (D-064): in the Color window, near the head.
const COLOR_INPUT := &"color_input"
## Godot's color picker: a square, sliders and the hex code.
const PICKER := &"picker"
## A globe of colors to turn and click, its depth the saturation, R, G, B and hex typed.
const GLOBE := &"globe"
## How the scale of a number's line and of a vector's arrows changes (D-069).
const AXIS_SCALE := &"axis_scale"
## By itself: held past an end the value speeds on, held by 0 it goes toward zero (D-060, D-067, D-068).
const AUTO := &"auto"
## By the stick, up finer and down coarser, the value kept; nothing speeds on.
const STICK := &"stick"
## Whether what a ray is on in the graph lights up (D-072) or is drawn over
## everything in its place (D-075, after D-073 brought it forward): a card with
## its ports, details, adapters and wires, or a variable's box with its wires.
## The hands' rays are drawn over it.
const FOCUS := &"focus"
## Over everything, in its place.
const FRONT := &"front"
## What the rest of the graph becomes while a ray is on a card or a box (D-072).
const DEFOCUS := &"defocus"
## Darker.
const DIM := &"dim"
## See-through.
const TRANSPARENT := &"transparent"
## Links (D-074): a detail in a port that stands for a variable or a scene
## object, its wire to the variable's box or the object hidden. What a link
## shows: "link" only, or the variable's name, or the object's projection.
const LINK_PREVIEW := &"link_preview"
const VARIABLES := &"variables"
const OBJECTS := &"objects"
const ALL := &"all"
## When the wires links hide are drawn: never, while their card, box or link is in focus, always.
const LINK_WIRES := &"link_wires"
const ON_FOCUS := &"on_focus"
## How a wire to a variable or an object becomes a link (D-074), besides a link
## from the Tokens window laid on its port: a button on the wire under the ray,
## a pull of the wire into its port by the grip, a button over its port, or
## by itself as soon as the wire is made, with no buttons, a link never a wire again (D-077),
## or a menu the trigger held on the wire opens: Link, or a bend added or taken off (D-090).
const LINK_CREATE := &"link_create"
const WIRE_BUTTON := &"wire_button"
const PULL := &"pull"
const PORT_BUTTON := &"port_button"
const ALWAYS := &"always"
const WIRE_MENU := &"wire_menu"
## How a wire is drawn from a port, a socket or a variable's box (D-135): the
## trigger held from it and let go where it ends — a port, a box, an object,
## or empty space for the block menu —, or a click on it and another where it
## ends, as before (D-043).
const WIRE_DRAW := &"wire_draw"
const HOLD := &"hold"
const CLICK := &"click"
## Whether a new wire to a variable or an object that has more than one wire
## or link already, and that runs far, becomes a link by itself (D-090).
const AUTO_LINK := &"auto_link"
## Bends of logic graph wires, as waypoints in draw.io (D-081). On (the
## default since D-089), a wire goes through its bends, and trigger or grip on
## it adds and drags them; off, wires are drawn as before and the bends a
## graph has are kept but not shown.
const WIRE_BENDS := &"wire_bends"
## Whether undo in the headset ([XREHistory], D-087) puts back the selection
## of scene objects too, a step of its own each time it changes, as Blender's
## does (the default since D-089); off, it doesn't, as the desktop editor's Ctrl+Z doesn't.
const UNDO_SELECTION := &"undo_selection"
## Whether the trigger held again on the selected object opens its shortcut
## ([XREObjectShortcut], D-088): delete, rename, Blueprint, picked by the ray
## and done as the trigger lets go. On (the default since D-089), it takes
## the place of the scene's badge (D-085); the graph keeps its badge.
const OBJECT_SHORTCUT := &"object_shortcut"
## How the block palette offers blocks (D-093; the ring by default since D-097): a list as before; tiles of the
## blocks most likely next over that list; or a ring of the task groups at the
## point the palette is opened from, its blocks around the group the ray is on,
## the list behind the ring's middle.
const BLOCK_PALETTE := &"block_palette"
const LIST := &"list"
const TILES := &"tiles"
const RING := &"ring"
## What the palette's chips group the blocks by (D-093): where they come from
## — the object, the library, @GlobalScope, the native blocks — as before, or
## what they are for: Events, Variables, Math, Flow, Move, Look, Sound, Object.
## The ring always has the task groups.
const PALETTE_GROUPS := &"palette_groups"
const SOURCES := &"sources"
const TASKS := &"tasks"
## Whether a wire let go in empty space, a card's plus or a box's wire first
## offers the five blocks most likely next on petals at that point, with
## More… for the palette (D-093).
const NEXT_SUGGESTIONS := &"next_suggestions"
## Whether a card has a copy button beside its trash (D-093; on by default since D-097): the trigger on it
## takes a copy of the block along the ray, to let go where it goes, or, let
## go at once, puts it beside the card.
const BLOCK_COPY := &"block_copy"
## How the trigger adds scene objects to the selection (D-120). Other grip
## (the default since D-131): while the
## other hand's grip is held in empty space, the trigger adds the object under
## the ray, or takes it out if it is selected already, and a grip adds it
## before grabbing. Replace, as before D-131: it selects only the object
## under the ray. A grip on a selected object grabs every selected one with
## either value.
const SELECT_ADD := &"select_add"
const REPLACE := &"replace"
const GRIP := &"grip"
## How scene objects are copied in the headset (D-121; Both by default since D-131). Shortcut: Duplicate in
## the object's shortcut puts copies of the selection beside it. Other grip:
## while the other hand's grip is held in empty space, a grip on an object
## takes copies of the selection, drawn as edges, and letting go puts them
## there; the originals stay. Both: either way. Clipboard: Copy in the
## shortcut, and the card's copy button in the graph, put copies on a
## clipboard shown on the left hand, which pastes them where the ray lets go,
## in this scene or another, in this graph or another (D-128). Off: no copy
## in the headset, as before.
const OBJECT_COPY := &"object_copy"
const SHORTCUT := &"shortcut"
const BOTH := &"both"
const CLIPBOARD := &"clipboard"
## Whether a pill over the left controller tells how many scene objects, or
## blocks of the open graph, are selected, with a plus while the other hand's
## grip held in empty space adds to the selection (D-123; on by default since D-131).
const SELECTION_COUNTER := &"selection_counter"
## How the trigger selects several scene objects in one stroke (D-124).
## Brush (the default since D-131): while the trigger is held, everything the
## ray crosses is selected too, and the stroke is one selection when the
## trigger lets go. Off, as before: a trigger selects what is under the ray
## when it goes down. Box: the
## trigger held draws a rectangle before the head, as the mouse does on the
## desktop, and letting go selects what is in it and not hidden (D-125); in
## the graph, a rectangle on the graph's plane from its empty space.
const SELECT_AREA := &"select_area"
const BRUSH := &"brush"
const BOX := &"box"
## Whether a copy of blocks (D-093, D-122) keeps the data wires that come into
## them from blocks not copied, from the same outputs (D-126). Off, as before:
## the inputs those wires fed get default tokens (D-059).
const COPY_OUTER_WIRES := &"copy_outer_wires"
## Whether a scene object copied in the headset (D-121) shares its Blueprint
## with the original — the same graph and script, as Duplicate on the desktop
## — or gets its own: a copy of the graph beside the scene, with the copy as
## its host, and of its generated script (D-127).
const COPY_BLUEPRINT := &"copy_blueprint"
const SHARED := &"shared"
const OWN := &"own"

## How a port of an array or a dictionary shows it is one (D-143): a grid of
## three by three cells in its element's colour — a dictionary's key's and
## value's columns —, or the element's port three times, one behind the other.
const COLLECTION_PORT := &"collection_port"
const GRID := &"grid"
const STACK := &"stack"
## How a list of values is put into a collection's port and a collection
## variable's start value without a keyboard (D-143): a Make Array block with an
## input each, or a rack, a piece in the port holding its pucks.
const COLLECTION_LITERAL := &"collection_literal"
const MAKE := &"make"
const RACK := &"rack"
## Whether a collection's wire has two strands, its element's colour around a
## dark core — a dictionary's key's around its value's —, to tell it from far (D-143).
const COLLECTION_WIRE := &"collection_wire"
## Whether a wire from a port of an array of objects let go on a selected object
## makes the array of the selected objects, in the order they were selected (D-143).
const SCENE_COLLECTION := &"scene_collection"

## Every setting by key: its section, its subsection in the Editor section
## (a key of [constant GROUPS]), the values of other settings it acts with
## (optional), title, values (the first is the default; the defaults are the
## author's picks after the headset checks, D-076, D-114, D-131, D-133), the values' titles
## and a line of explanation.
const DEFINITIONS: Dictionary[StringName, Dictionary] = {
	NODE_FACING: {
		"category": Category.EDITOR,
		"group": &"cards",
		"title": "Node facing",
		"values": [ON, SHORTHANDS, OFF],
		"labels": ["On", "Shorthands", "Off"],
		"hint": "On: every node turns to you. Shorthands: only signs, beads, tags, operators and boxes do; cards stand in the graph. Off: nothing turns.",
	},
	NODE_VOLUME: {
		"category": Category.EDITOR,
		"group": &"cards",
		"title": "Node volume",
		"values": [FLAT, SOLID],
		"labels": ["2D", "3D"],
		"hint": "2D: flat nodes. 3D: solid nodes 1.2 cm deep, thinner than their ports.",
	},
	NODE_BACK: {
		"category": Category.EDITOR,
		"group": &"cards",
		"requires": {NODE_FACING: [SHORTHANDS, OFF]},
		"title": "Node back",
		"values": [BLANK, LABELLED],
		"labels": ["Blank", "Labelled"],
		"hint": "For nodes that don't turn to you. Blank: their back is plain. Labelled: from behind a card shows its face as a mirror's, inputs on the right, the text readable.",
	},
	PIN_PLACE: {
		"category": Category.EDITOR,
		"group": &"cards",
		"title": "Pins",
		"values": [BOTH_FACES, FACE, EDGE],
		"labels": ["Both faces", "On the face", "On the edge"],
		"hint": "On the face: as before D-133. Both faces: on whichever face is turned to you. On the edge: balls and arrowheads on the node's edge, seen from every side.",
	},
	CARD_MIRROR: {
		"category": Category.EDITOR,
		"group": &"cards",
		"requires": {NODE_FACING: [ON], GRAPH_TURN: [FIXED]},
		"title": "Card mirror",
		"values": [ON, OFF],
		"labels": ["On", "Off"],
		"hint": "With Node facing On and Graph turn Fixed. On: a card whose wires run to your left lays out as a mirror's, inputs on the right, so its wires leave towards its neighbours; a card without wires across your view, past 90° from the graph's front.",
	},
	SIGN_PORTS: {
		"category": Category.EDITOR,
		"group": &"cards",
		"title": "Sign ports",
		"values": [RIM, SIDES],
		"labels": ["Rim", "Sides"],
		"hint": "Rim: each port slides along the rim towards the other end of its wire, or its nearest bend, at most 90° from its side. Sides: a sign's inputs on its left, its result on its right.",
	},
	GRAPH_TURN: {
		"category": Category.EDITOR,
		"group": &"view",
		"title": "Graph turn",
		"values": [FIXED, FLIP, STEPS, AIM],
		"labels": ["Fixed", "Flip 180°", "Steps 90°", "On aim"],
		"hint": "Fixed: the graph stays. Flip: it turns round past 95° from its front. Steps: to the nearest of four fronts past 50°. On aim: to you once, when your ray first comes onto it. Never while something in it is held.",
	},
	GRAPH_PARTS: {
		"category": Category.EDITOR,
		"group": &"view",
		"title": "Graph parts",
		"values": [WHOLE, PARTS],
		"labels": ["Whole", "Parts"],
		"hint": "Whole: the graph turns and mirrors as one, by its front. Parts: cards of one orientation wired together do so by their own; turn a card with the grip while nodes don't face you.",
	},
	PORT_DISPLAY: {
		"category": Category.EDITOR,
		"group": &"cards",
		"title": "Port display",
		"values": [SPHERE, FLAT],
		"labels": ["Sphere", "Flat"],
		"hint": "Flat: discs on the card. Sphere: round ports standing out of it.",
	},
	NODE_STYLE: {
		"category": Category.EDITOR,
		"group": &"cards",
		"title": "Node style",
		"values": [ARCHETYPES, CLASSIC],
		"labels": ["Archetypes", "Classic"],
		"hint": "Classic: cards as before. Archetypes: a header colored by group with an icon, pure functions framed in their result's color; the trash and X delete the card under the ray.",
	},
	NODE_SHRINK: {
		"category": Category.EDITOR,
		"group": &"cards",
		"requires": {NODE_STYLE: [ARCHETYPES]},
		"title": "Node shrink",
		"values": [SYSTEM, OPERATORS, MATH, ICONS],
		"labels": ["+ System", "Operators", "+ Math", "All with icons"],
		"hint": "With Archetypes. Operators: operators are signs. + Math: math functions as sin, abs, clamp too. + System: Delay a bead, Get Time and Random rings. All with icons: every block with its own icon and at most three ports a side; its name shows under the ray.",
	},
	NODE_HEADING: {
		"category": Category.EDITOR,
		"group": &"cards",
		"requires": {NODE_STYLE: [ARCHETYPES]},
		"title": "Node heading",
		"values": [MEMBER, OPERATION],
		"labels": ["Member", "Operation"],
		"hint": "With Archetypes. Operation: the header says what the block does, the member is on the adapter. Member: the header says the signal, property or variable, the wire to it bare. ⇄ by the trash switches one card.",
	},
	COMPOSITE_VALUES: {
		"category": Category.EDITOR,
		"group": &"values",
		"title": "Composite values",
		"values": [SPLIT, WHOLE],
		"labels": ["Split", "Whole"],
		"hint": "Whole: a vector or colour variable's box gives the whole value, a Break takes it apart. Split: its box has an output for each component, x y z or r g b a, wired straight into a port.",
	},
	PORT_SHAPES: {
		"category": Category.EDITOR,
		"group": &"cards",
		"title": "Port shapes",
		"values": [OFF, ON],
		"labels": ["Off", "On"],
		"hint": "On: a port's shape says its type as its colour does: an arrow for execution, a diamond for bool, a square for int, a circle for float, a pill for text, a triangle for vectors.",
	},
	WINDOW_SHAPE: {
		"category": Category.EDITOR,
		"group": &"view",
		"title": "Window shape",
		"values": [FLAT, CONCAVE],
		"labels": ["Flat", "Concave"],
		"hint": "Flat: plane windows. Concave: windows bent around you, as the launcher is.",
	},
	VALUE_INPUT: {
		"category": Category.EDITOR,
		"group": &"values",
		"title": "Values",
		"values": [PLUGS, WINDOW, PUCKS],
		"labels": ["Plugs", "Window", "Pucks"],
		"hint": "Window: in the block's parameters. Pucks: tokens in slots on the card. Plugs: tokens plugged into the ports.",
	},
	TARGET_INPUT: {
		"category": Category.EDITOR,
		"group": &"objects",
		"title": "Targets",
		"values": [ADAPTER, WINDOW, ON_NODE, SCENE],
		"labels": ["Adapter", "Window", "Node", "Scene"],
		"hint": "Window: in the parameters. Others wire the Target to the object; the member shows on the card (Node), on a petal at the object (Scene) or on a plug in the port the wire leaves (Adapter).",
	},
	ANIMATION_WAIT: {
		"category": Category.EDITOR,
		"group": &"values",
		"title": "Animation wait",
		"values": [FINISHED_PORT, FLAG],
		"labels": ["Finished port", "Flag"],
		"hint": "Flag: a wait setting. Finished port: wire Finished to wait for the animation, Then not to.",
	},
	VARIABLE_INPUT: {
		"category": Category.EDITOR,
		"group": &"values",
		"title": "Variables",
		"values": [BOXES, WINDOW],
		"labels": ["Boxes", "Window"],
		"hint": "Window: chosen in the parameters. Boxes: wire Get and Set Variable to a box on the shelf.",
	},
	TOKEN_TRAY: {
		"category": Category.EDITOR,
		"group": &"values",
		"requires": {VALUE_INPUT: [PLUGS, PUCKS]},
		"title": "Token tray",
		"values": [OFF, ON],
		"labels": ["Off", "On"],
		"hint": "On: a Tokens window of ready values opens with the graph. Works with Values on Pucks or Plugs.",
	},
	SCENE_CREATE: {
		"category": Category.EDITOR,
		"group": &"objects",
		"title": "Create from scene",
		"values": [OFF, ON],
		"labels": ["Off", "On"],
		"hint": "On: the selected object shows its members; a wire from one let go in the graph adds its block.",
	},
	CARD_PLUS: {
		"category": Category.EDITOR,
		"group": &"blocks",
		"title": "Plus on cards",
		"values": [HIDDEN, SHOWN],
		"labels": ["Hidden", "Shown"],
		"hint": "Shown: the plus on a card adds the next block. Hidden: add blocks by letting a wire go in empty space.",
	},
	COLOR_INPUT: {
		"category": Category.EDITOR,
		"group": &"values",
		"title": "Color input",
		"values": [GLOBE, PICKER],
		"labels": ["3D", "2D"],
		"hint": "2D: a color picker with the hex code. 3D: a globe of colors to turn and click, R, G, B typed. Both have a pipette.",
	},
	AXIS_SCALE: {
		"category": Category.EDITOR,
		"group": &"values",
		"title": "Axis scale",
		"values": [STICK, AUTO],
		"labels": ["Stick", "Auto"],
		"hint": "For a number's line and a vector's arrows. Auto: past an end the value speeds up, held by 0 it goes toward 0. Stick: the stick up makes the scale finer, down coarser; nothing speeds up.",
	},
	FOCUS: {
		"category": Category.EDITOR,
		"group": &"view",
		"title": "Focus",
		"values": [FRONT, OFF, ON],
		"labels": ["Front", "Off", "On"],
		"hint": "On: the card or variable under the ray lights up with its ports, details and wires; a port or a detail under the ray grows as well. Front: it is drawn over everything with its ports, details, adapters and wires, staying where it is; the rays over it.",
	},
	DEFOCUS: {
		"category": Category.EDITOR,
		"group": &"view",
		"title": "Defocus",
		"values": [DIM, OFF, TRANSPARENT],
		"labels": ["Dim", "Off", "Transparent"],
		"hint": "While the ray is on a card or a variable, the rest of the graph stays as it is (Off), goes darker (Dim) or see-through (Transparent).",
	},
	LINK_PREVIEW: {
		"category": Category.EDITOR,
		"group": &"wires",
		"title": "Link preview",
		"values": [VARIABLES, OFF, OBJECTS, ALL],
		"labels": ["Variables", "Off", "Objects", "All"],
		"hint": "What a link in a port shows: \"link\" only (Off), the variable's name, the object's projection, or both.",
	},
	LINK_WIRES: {
		"category": Category.EDITOR,
		"group": &"wires",
		"title": "Link wires",
		"values": [ON_FOCUS, OFF, ON],
		"labels": ["On focus", "Off", "On"],
		"hint": "The wire a link hides: never drawn (Off), drawn while the ray is on its card, its variable or the link (On focus), always drawn (On).",
	},
	WIRE_DRAW: {
		"category": Category.EDITOR,
		"group": &"wires",
		"title": "Wire draw",
		"values": [HOLD, CLICK],
		"labels": ["Hold", "Click"],
		"hint": "Hold: hold the trigger on a port and let go where the wire ends: on a port it connects, in empty space the block menu opens, on its own port it goes back. Click: click the port, then click where the wire ends.",
	},
	LINK_CREATE: {
		"category": Category.EDITOR,
		"group": &"wires",
		"title": "Link from wire",
		"values": [WIRE_MENU, WIRE_BUTTON, PULL, PORT_BUTTON, ALWAYS],
		"labels": ["Wire menu", "Wire button", "Pull", "Port button", "Always"],
		"hint": "How a wire to a variable or an object becomes a link: a link button where the ray is on the wire, the grip pulling the wire into its port, a link button over its port, by itself as soon as the wire is made (Always: no buttons, and a link never becomes a wire), or a menu the trigger held on the wire opens (Wire menu: Link or Point; on a point, Delete point; let go on one to do it). A link from the Tokens window laid on the port works with each.",
	},
	AUTO_LINK: {
		"category": Category.EDITOR,
		"group": &"wires",
		"requires": {LINK_CREATE: [WIRE_MENU, WIRE_BUTTON, PULL, PORT_BUTTON]},
		"title": "Auto link",
		"values": [ON, OFF],
		"labels": ["On", "Off"],
		"hint": "On: a new wire to a variable or an object that has more than one wire or link already becomes a link by itself if it runs farther than half a meter.",
	},
	WIRE_BENDS: {
		"category": Category.EDITOR,
		"group": &"wires",
		"title": "Wire bends",
		"values": [ON, OFF],
		"labels": ["On", "Off"],
		"hint": "On: trigger or grip on a wire drags a bend out of it, on a knot moves the bend; Delete on a knot removes it.",
	},
	UNDO_SELECTION: {
		"category": Category.EDITOR,
		"group": &"objects",
		"title": "Undo selection",
		"values": [ON, OFF],
		"labels": ["On", "Off"],
		"hint": "On: undo puts back what was selected too, a step of its own each time the selection changes. Off: selecting isn't undone, as on the desktop.",
	},
	OBJECT_SHORTCUT: {
		"category": Category.EDITOR,
		"group": &"objects",
		"title": "Object shortcut",
		"values": [ON, OFF],
		"labels": ["On", "Off"],
		"hint": "On: hold the trigger again on the selected object for Delete, Rename and Blueprint; let go on one to do it, elsewhere to cancel. The Blueprint badge over the object gives way to it; the graph keeps its badge.",
	},
	BLOCK_PALETTE: {
		"category": Category.EDITOR,
		"group": &"blocks",
		"title": "Block palette",
		"values": [RING, LIST, TILES],
		"labels": ["Ring", "List", "Tiles"],
		"hint": "List: chips, search and rows. Tiles: twelve big tiles of the likely next blocks over the list. Ring: the task groups around the point the palette opens from; the ray on a group shows its blocks, the middle opens the list.",
	},
	PALETTE_GROUPS: {
		"category": Category.EDITOR,
		"group": &"blocks",
		"title": "Palette groups",
		"values": [SOURCES, TASKS],
		"labels": ["Sources", "Tasks"],
		"hint": "Sources: chips of the object, Library, Global, Native. Tasks: Events, Variables, Math, Flow, Move, Look, Sound, Object. The ring always has the tasks.",
	},
	NEXT_SUGGESTIONS: {
		"category": Category.EDITOR,
		"group": &"blocks",
		"title": "Next suggestions",
		"values": [OFF, ON],
		"labels": ["Off", "On"],
		"hint": "On: a wire let go in empty space or a card's plus first shows the five likely next blocks on petals there; More… opens the palette.",
	},
	BLOCK_COPY: {
		"category": Category.EDITOR,
		"group": &"blocks",
		"title": "Copy blocks",
		"values": [ON, OFF],
		"labels": ["On", "Off"],
		"hint": "On: a copy button beside a card's trash. Trigger on it and point where the copy goes, or let go at once to put it beside the card.",
	},
	SETTINGS_SUBSECTIONS: {
		"category": Category.GLOBAL,
		"title": "Subsections",
		"values": [ROW, TREE],
		"labels": ["On top", "On the left"],
		"hint": "Where Settings shows a section's subsections. On top: a row over the settings; drag it sideways when it doesn't fit. On the left: under the section's name, which opens and closes them.",
	},
	ANTIALIASING: {
		"category": Category.GRAPHICS,
		"title": "Antialiasing",
		"values": [AUTO, OFF, MSAA_2X, MSAA_4X, MSAA_8X, MSAA_4X_SSAA_2X, FXAA, SMAA, TAA, SSAA_1_5X, SSAA_2X],
		"labels": ["Auto", "Off", "MSAA 2×", "MSAA 4×", "MSAA 8×", "16× (MSAA 4× + SSAA 2×)", "FXAA", "SMAA", "TAA", "SSAA 1.5×", "SSAA 2×"],
		"hint": "Smooths edges in the VR view. Auto: MSAA 4× on a standalone headset and in the window, off on a PC headset. SSAA also smooths text and costs the most. FXAA blurs. SMAA and TAA act only in the window: in a headset, SMAA is FXAA and TAA is MSAA 4×.",
	},
	EDITOR_WINDOW: {
		"category": Category.GRAPHICS,
		"title": "Editor window",
		"values": [PAUSED, LIVE],
		"labels": ["Paused", "Live"],
		"hint": "While the editor's 2D window is hidden in VR, Paused stops drawing it, and the headset gets that time. Live draws it as before. A key or a click in the window shows it again.",
	},
	ARROW_LAYOUT: {
		"category": Category.GRAPHICS,
		"title": "Arrow layout",
		"values": [NATIVE, SCRIPT],
		"labels": ["Native", "Script"],
		"hint": "How the wires' arrowheads are laid out as they run or the head moves. Native: in the plugin's C++ part, in one call. Script: in GDScript, as before; slower on large graphs. They look the same.",
	},
	GRAPH_MATERIALS: {
		"category": Category.GRAPHICS,
		"title": "Graph materials",
		"values": [SHARED, PER_PART],
		"labels": ["Shared", "Per part"],
		"hint": "Shared: parts of the graph that look the same share one material and mesh, so drawing them costs less. Per part: each has its own, as before. They look the same.",
	},
	GRAPH_DRAWING: {
		"category": Category.GRAPHICS,
		"title": "Graph drawing",
		"values": [PER_NODE, MERGED, CARD_MERGED],
		"labels": ["Per node", "Ports merged", "Card merged"],
		"hint": "Per node: each part of a card is drawn on its own, as before. Ports merged: a card's ports are drawn as one mesh, drawn again when one changes. Card merged: all its flat parts, its face too, as one mesh of each look; fewest draw calls. They look the same.",
	},
	RAY_PICKING: {
		"category": Category.GRAPHICS,
		"title": "Ray picking",
		"values": [EACH_CALL, PER_FRAME],
		"labels": ["Each call", "Per frame"],
		"hint": "How the graph finds what a hand's ray is on. Each call: worked out every time it is asked, as before. Per frame: the same ray asked again in a frame, with nothing changed, gets the first answer; less CPU. The same answers.",
	},
	WIRE_PICKING: {
		"category": Category.GRAPHICS,
		"title": "Wire picking",
		"values": [SCRIPT, NATIVE],
		"labels": ["Script", "Native"],
		"hint": "How a ray finds the wires it passes near. Script: in GDScript, as before. Native: in the plugin's C++ part, in one call; less CPU on large graphs. The same wires.",
	},
	EXEC_ARROWS: {
		"category": Category.EDITOR,
		"group": &"wires",
		"title": "Execution arrows",
		"values": [RUNNING, OFF, CHEVRONS, AT_END],
		"labels": ["Running", "Off", "Chevrons", "At the end"],
		"hint": "Arrowheads on execution wires along the flow. Chevrons: every 9 cm. Running: the same, moving. At the end: one before the input.",
	},
	DATA_ARROWS: {
		"category": Category.EDITOR,
		"group": &"wires",
		"title": "Data arrows",
		"values": [AT_END, OFF, CHEVRONS, RUNNING],
		"labels": ["At the end", "Off", "Chevrons", "Running"],
		"hint": "Arrowheads on data wires, from output to input and from an object to its Target. Chevrons: every 9 cm. Running: the same, moving. At the end: one before the input.",
	},
	ARROW_STYLE: {
		"category": Category.EDITOR,
		"group": &"wires",
		"title": "Arrow style",
		"values": [OPEN, FILLED],
		"labels": ["Open", "Filled"],
		"hint": "Filled: cones, seen from every side. Open: two strokes as >, turned about the wire to you.",
	},
	SELECT_ADD: {
		"category": Category.EDITOR,
		"group": &"objects",
		"title": "Add to selection",
		"values": [GRIP, REPLACE],
		"labels": ["Other grip", "Replace"],
		"hint": "Replace: the trigger selects only the object under the ray. Other grip: hold the other hand's grip in empty space, and the trigger adds the object or takes it out. A grip on a selected object grabs all the selected ones.",
	},
	OBJECT_COPY: {
		"category": Category.EDITOR,
		"group": &"objects",
		"title": "Copy objects",
		"values": [BOTH, SHORTCUT, GRIP, CLIPBOARD, OFF],
		"labels": ["Both", "Shortcut", "Other grip", "Clipboard", "Off"],
		"hint": "Shortcut: Duplicate in the object's shortcut puts copies of the selected objects beside them. Other grip: hold the other hand's grip in empty space, and a grip on an object takes copies of the selected ones to let go where they go. Both: either way. Clipboard: Copy in the shortcut, or a card's copy button, puts them on a clipboard over the left hand; its Paste, held, takes them where the ray lets go, in any scene or graph. Off: no copies in the headset.",
	},
	SELECTION_COUNTER: {
		"category": Category.EDITOR,
		"group": &"objects",
		"title": "Selection counter",
		"values": [ON, OFF],
		"labels": ["On", "Off"],
		"hint": "On: a pill over the left controller tells how many objects, or blocks of the open graph, are selected, with a plus while the other hand's grip held in empty space adds to the selection.",
	},
	COPY_BLUEPRINT: {
		"category": Category.EDITOR,
		"group": &"objects",
		"title": "Blueprint of a copy",
		"values": [SHARED, OWN],
		"labels": ["Shared", "Own"],
		"hint": "Shared: a copied object runs the same graph as the original, and editing it changes both. Own: the copy gets a graph and a script of its own, copied from the original's.",
	},
	COPY_OUTER_WIRES: {
		"category": Category.EDITOR,
		"group": &"blocks",
		"title": "Copy outer wires",
		"values": [OFF, ON],
		"labels": ["Off", "On"],
		"hint": "On: a copy of blocks keeps the data wires coming into them from blocks not copied. Off: those inputs get default tokens. Execution wires stay with the originals either way.",
	},
	COLLECTION_PORT: {
		"category": Category.EDITOR,
		"group": &"cards",
		"title": "Collection port",
		"values": [GRID, STACK],
		"labels": ["Grid", "Stack"],
		"hint": "How a port of an array or a dictionary shows it: Grid, three by three cells in its element's colour (a dictionary: its keys' and values' columns); Stack, the element's port three times, one behind the other.",
	},
	COLLECTION_LITERAL: {
		"category": Category.EDITOR,
		"group": &"values",
		"title": "Collection literal",
		"values": [MAKE, RACK],
		"labels": ["Make block", "Rack"],
		"hint": "How a list is typed in: Make block, a Make Array card with an input for each element; Rack, a piece in the collection's port that holds its values, + adds one, the trigger on it types the list.",
	},
	COLLECTION_WIRE: {
		"category": Category.EDITOR,
		"group": &"wires",
		"title": "Collection wire",
		"values": [OFF, ON],
		"labels": ["Off", "On"],
		"hint": "On: a wire of an array or a dictionary has two strands, its element's colour around a dark core (a dictionary: its keys' around its values'), to tell it from a single value's from far.",
	},
	SCENE_COLLECTION: {
		"category": Category.EDITOR,
		"group": &"objects",
		"title": "Array from scene",
		"values": [OFF, ON],
		"labels": ["Off", "On"],
		"hint": "On: a wire from a port of an array of objects let go on a selected object makes the array of the selected objects, numbered in the order they were selected. The ray on a branch and the delete button takes its object out; another wire from the port to an object adds it at the end.",
	},
	SELECT_AREA: {
		"category": Category.EDITOR,
		"group": &"objects",
		"title": "Select area",
		"values": [BRUSH, OFF, BOX],
		"labels": ["Brush", "Off", "Box"],
		"hint": "Brush: hold the trigger and sweep the ray; everything it crosses is selected, as one selection when the trigger lets go. Box: hold the trigger and draw a rectangle; what is in it and not hidden is selected when the trigger lets go; in the graph, draw it from the graph's empty space. With the other hand's grip held in empty space, either adds to the selection.",
	},
}

## Node display (D-039), saved before Node facing and Node volume took its
## place (D-115): Cuboid is Node facing Off with Node volume 3D.
const _OLD_NODE_DISPLAY := "node_display"

## Key [signal changed] carries when the controls layout or a binding changed.
const CONTROLS := &"controls"

## Layouts of the controls (D-050): the bindings of every action. One is picked
## for the runtime the editor runs on until the user picks another; rebinding
## an action in a preset copies the preset into [constant CUSTOM] first.
const HORIZON_LINK := &"horizon_link"
const STEAMVR := &"steamvr"
const HORIZON_OS := &"horizon_os"
## The VR view without a headset (D-057): the controllers' buttons are keys
## ([constant XRESimulator.BUTTON_KEYS]), and the controls page shows the keys.
const NON_VR := &"non_vr"
## The user's own bindings. Once chosen it is used on every runtime.
const CUSTOM := &"custom"
const LAYOUTS: Array[StringName] = [HORIZON_LINK, STEAMVR, HORIZON_OS, NON_VR, CUSTOM]
const LAYOUT_LABELS: Array[String] = ["Horizon Link", "SteamVR", "Horizon OS", "NonVR", "Custom"]

## Actions with a button of their own, in the order of the controls page.
const DELETE := &"delete"
const LAUNCHER := &"launcher"
const PLAY := &"play"
const SPEED := &"speed"
## Undo and redo in the headset ([XREUndo], D-087).
const UNDO := &"undo"
const REDO := &"redo"
const ACTIONS: Array[StringName] = [LAUNCHER, PLAY, UNDO, REDO, DELETE, SPEED]
const ACTION_TITLES: Dictionary[StringName, String] = {
	LAUNCHER: "Open the launcher",
	PLAY: "Play / stop (hold in game: back)",
	UNDO: "Undo",
	REDO: "Redo",
	DELETE: "Delete the selection",
	SPEED: "Change flying speed",
}

## Buttons an action can take: the controller's hand, its input in the
## tracker's name, the button's name and the letters of its icon
## ([XREButtonGlyph]; "≡" is drawn as a menu button). Trigger and grip select
## and grab everywhere and are not rebindable. The right Menu is the system's;
## the left one reaches applications on Meta's runtimes, while SteamVR keeps it
## for its dashboard.
const BUTTONS: Dictionary[StringName, Dictionary] = {
	&"left_menu": {"hand": &"left_hand", "input": &"menu_button", "label": "Left Menu", "glyph": "≡"},
	&"left_x": {"hand": &"left_hand", "input": &"ax_button", "label": "Left X", "glyph": "X"},
	&"left_y": {"hand": &"left_hand", "input": &"by_button", "label": "Left Y", "glyph": "Y"},
	&"left_stick": {"hand": &"left_hand", "input": &"primary_click", "label": "Left stick click", "glyph": "LS"},
	&"right_a": {"hand": &"right_hand", "input": &"ax_button", "label": "Right A", "glyph": "A"},
	&"right_b": {"hand": &"right_hand", "input": &"by_button", "label": "Right B", "glyph": "B"},
	&"right_stick": {"hand": &"right_hand", "input": &"primary_click", "label": "Right stick click", "glyph": "RS"},
}

## Bindings of the presets, by layout. A undoes and B redoes, X deletes
## (D-087). On Meta's runtimes the launcher is on the left Menu button, as
## Meta's own apps open their menus; SteamVR keeps that button for its
## dashboard, and X deletes, so there the launcher is on the right stick's
## click. Without a headset the keys are Tab, Y, E, B, X and Shift.
const _PRESETS: Dictionary[StringName, Dictionary] = {
	HORIZON_LINK: {LAUNCHER: &"left_menu", PLAY: &"left_y", UNDO: &"right_a", REDO: &"right_b", DELETE: &"left_x", SPEED: &"left_stick"},
	STEAMVR: {LAUNCHER: &"right_stick", PLAY: &"left_y", UNDO: &"right_a", REDO: &"right_b", DELETE: &"left_x", SPEED: &"left_stick"},
	HORIZON_OS: {LAUNCHER: &"left_menu", PLAY: &"left_y", UNDO: &"right_a", REDO: &"right_b", DELETE: &"left_x", SPEED: &"left_stick"},
	NON_VR: {LAUNCHER: &"left_menu", PLAY: &"left_y", UNDO: &"right_a", REDO: &"right_b", DELETE: &"left_x", SPEED: &"left_stick"},
}

const _SECTION := "features"
const _CONTROLS_SECTION := "controls"

## File the values persist in, or empty to keep them in memory.
var path := ""
var _values: Dictionary[StringName, StringName] = {}
## The layout the runtime asks for, while the user hasn't picked one.
var runtime_layout := HORIZON_LINK
## The layout the user picked, or empty while the runtime's is used.
var _layout := &""
## The user's bindings, by action; complete once [constant CUSTOM] was chosen or made.
var _custom: Dictionary[StringName, StringName] = {}


## Reads the values saved in [param file], if any. Unknown keys and values
## saved by another version fall back to the defaults.
func _init(file: String = "") -> void:
	path = file
	if path.is_empty() or not FileAccess.file_exists(path):
		return
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return
	for key: StringName in DEFINITIONS:
		var saved: Variant = config.get_value(_SECTION, String(key), "")
		if saved is String and StringName(saved) in get_values(key):
			_values[key] = StringName(saved)
	if config.get_value(_SECTION, _OLD_NODE_DISPLAY, "") == "cuboid":
		if not NODE_FACING in _values: _values[NODE_FACING] = OFF
		if not NODE_VOLUME in _values: _values[NODE_VOLUME] = SOLID
	for action: StringName in ACTIONS:
		var button: Variant = config.get_value(_CONTROLS_SECTION, String(action), "")
		if button is String and StringName(button) in BUTTONS:
			_custom[action] = StringName(button)
	if _custom.size() != ACTIONS.size():
		_custom.clear()
	var layout: Variant = config.get_value(_CONTROLS_SECTION, "layout", "")
	if layout is String and StringName(layout) in LAYOUTS and (layout != CUSTOM or not _custom.is_empty()):
		_layout = StringName(layout)


## Keys of the settings in section [param category], in definition order; only
## those of subsection [param group] if one is given.
static func get_keys(category: Category, group: StringName = &"") -> Array[StringName]:
	var keys: Array[StringName] = []
	for key: StringName in DEFINITIONS:
		if DEFINITIONS[key]["category"] == category and (group == &"" or get_group(key) == group):
			keys.append(key)
	return keys


## The subsection of setting [param key], a key of [constant GROUPS], or empty.
static func get_group(key: StringName) -> StringName:
	if not key in DEFINITIONS:
		return &""
	var group: StringName = DEFINITIONS[key].get("group", &"")
	return group


## Whether setting [param key] acts with the current values: those its
## [code]requires[/code] names have one of the values listed, and act themselves.
## Node shrink only shapes archetypes, for one.
func is_active(key: StringName) -> bool:
	if not key in DEFINITIONS:
		return false
	var requires: Dictionary = DEFINITIONS[key].get("requires", {})
	for other: StringName in requires:
		var allowed: Array = requires[other]
		if not get_value(other) in allowed or not is_active(other):
			return false
	return true


## Whether setting [param key] has a value other than its default.
func is_changed(key: StringName) -> bool:
	return key in _values and _values[key] != get_default(key)


## How many of settings [param keys] aren't at their defaults.
func count_changed(keys: Array[StringName]) -> int:
	var count := 0
	for key: StringName in keys:
		if is_changed(key):
			count += 1
	return count


## The values setting [param key] may take; its default first.
static func get_values(key: StringName) -> Array[StringName]:
	var values: Array[StringName] = []
	if key in DEFINITIONS:
		var listed: Array = DEFINITIONS[key]["values"]
		for value: StringName in listed:
			values.append(value)
	return values


## The default value of setting [param key], or an empty name for an unknown key.
static func get_default(key: StringName) -> StringName:
	var values := get_values(key)
	return values[0] if not values.is_empty() else &""


## The current value of setting [param key].
func get_value(key: StringName) -> StringName:
	return _values[key] if key in _values else get_default(key)


## Sets setting [param key] to [param value] and saves it, unless [param persist] is false
## (a value for one run, D-164). Returns false, and changes nothing, for an unknown key or
## value or the current value. Tools and panels call [method XREDocument.set_feature], which logs the switch.
func set_value(key: StringName, value: StringName, persist := true) -> bool:
	if not value in get_values(key) or get_value(key) == value:
		return false
	_values[key] = value
	if persist: _save()
	changed.emit(key)
	return true


## The layout a runtime gets until the user picks one: the standalone headset's
## own, SteamVR's, otherwise Meta Link's. [param runtime_name] is
## [code]XRRuntimeName[/code] of the OpenXR system info.
static func layout_for_runtime(runtime_name: String, standalone: bool) -> StringName:
	if standalone:
		return HORIZON_OS
	return STEAMVR if runtime_name.begins_with("SteamVR") else HORIZON_LINK


## The layout in use: the user's pick, or the runtime's.
func get_layout() -> StringName:
	return _layout if _layout != &"" else runtime_layout


## Whether the user picked a layout; otherwise the runtime's is in use.
func is_layout_picked() -> bool:
	return _layout != &""


## Whether buttons are keys of the keyboard: the NonVR layout is in use, or
## the VR view runs without a headset (its runtime layout), whatever the user picked.
func uses_keyboard() -> bool:
	return get_layout() == NON_VR or runtime_layout == NON_VR


## The button action [param action] has in the current layout, a key of [constant BUTTONS].
func get_binding(action: StringName) -> StringName:
	var layout := get_layout()
	if layout == CUSTOM and action in _custom:
		return _custom[action]
	return preset_binding(runtime_layout if layout == CUSTOM else layout, action)


## The button of [param action] in preset [param layout], or empty for an unknown one.
static func preset_binding(layout: StringName, action: StringName) -> StringName:
	var preset: Dictionary = _PRESETS.get(layout, {})
	return preset.get(action, &"")


## The button of [param action] in [param features], or in the default
## layout when there are none (tools run without a document in tests).
static func binding_of(features: XREFeatureSettings, action: StringName) -> StringName:
	return features.get_binding(action) if features != null else preset_binding(HORIZON_LINK, action)


## Tracker name of [param button]'s hand, [code]&"left_hand"[/code] or [code]&"right_hand"[/code].
static func button_hand(button: StringName) -> StringName:
	return BUTTONS[button]["hand"] if button in BUTTONS else &""


## The tracker's input of [param button].
static func button_input(button: StringName) -> StringName:
	return BUTTONS[button]["input"] if button in BUTTONS else &""


## The name of [param button] for the user: "Left Y".
static func button_label(button: StringName) -> String:
	return BUTTONS[button]["label"] if button in BUTTONS else ""


## The letters on [param button]'s icon: "A", or "LS" for a stick.
static func button_glyph(button: StringName) -> String:
	return BUTTONS[button]["glyph"] if button in BUTTONS else ""


## Picks [param layout]. Custom starts as a copy of the bindings in use if the
## user has none. False, and nothing changed, for an unknown layout or the
## layout already in use.
func set_layout(layout: StringName) -> bool:
	if not layout in LAYOUTS or layout == get_layout():
		return false
	if layout == CUSTOM and _custom.is_empty():
		_custom = _current_bindings()
	_layout = layout
	_save()
	changed.emit(CONTROLS)
	return true


## Binds [param action] to [param button]. A preset in use is first copied
## into the custom layout, with every other binding as it was, and the custom
## layout is picked. A button another action had goes to the button [param action]
## gave up, so that no two actions share one. False for an unknown action or
## button, or the binding already set.
func set_binding(action: StringName, button: StringName) -> bool:
	if not action in ACTIONS or not button in BUTTONS or get_binding(action) == button:
		return false
	var bindings := _current_bindings()
	var previous := bindings[action]
	for other: StringName in ACTIONS:
		if other != action and bindings[other] == button:
			bindings[other] = previous
	bindings[action] = button
	_custom = bindings
	_layout = CUSTOM
	_save()
	changed.emit(CONTROLS)
	return true


## The layout the user picked and their bindings, for [method set_controls]
## to put back: undo of a pick or a rebinding (D-087).
func get_controls() -> Dictionary:
	return {"layout": _layout, "custom": _custom.duplicate()}


## Puts back the controls [method get_controls] gave and saves them. False,
## and nothing changed, if they are the ones in use.
func set_controls(controls: Dictionary) -> bool:
	var custom: Dictionary[StringName, StringName] = {}
	custom.assign(controls.get("custom", {}))
	var layout: StringName = controls.get("layout", &"")
	if layout == _layout and custom == _custom:
		return false
	_layout = layout
	_custom = custom
	_save()
	changed.emit(CONTROLS)
	return true


## One line with every setting's current value, for the editor's log.
func describe() -> String:
	var parts := PackedStringArray()
	for key: StringName in DEFINITIONS:
		parts.append("%s=%s" % [key, get_value(key)])
	parts.append("layout=%s" % get_layout())
	return ", ".join(parts)


func _current_bindings() -> Dictionary[StringName, StringName]:
	var bindings: Dictionary[StringName, StringName] = {}
	for action: StringName in ACTIONS:
		bindings[action] = get_binding(action)
	return bindings


func _save() -> void:
	if path.is_empty():
		return
	var config := ConfigFile.new()
	for key: StringName in _values:
		config.set_value(_SECTION, String(key), String(_values[key]))
	if _layout != &"":
		config.set_value(_CONTROLS_SECTION, "layout", String(_layout))
	for action: StringName in _custom:
		config.set_value(_CONTROLS_SECTION, String(action), String(_custom[action]))
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if config.save(path) != OK:
		push_error("XR Editor: can't save feature settings to " + path)
