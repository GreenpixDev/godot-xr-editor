@tool
class_name XREBlueprintBoxes
extends Node3D
## The graph's variables as boxes among its cards (D-052, D-078), when the
## setting [constant XREFeatureSettings.VARIABLE_INPUT] is Boxes. Each box
## stands where it was put, as a card does ([XREBlueprintCanvas] places them);
## a box never put anywhere stands in a row below the cards, as on the shelf
## of D-052. Above a box are its name and type; on its front a trash and the
## value the variable starts the game with, a token as on the cards. A Get or
## Set Variable card wires its Variable socket to its box. New variables come
## from the block menu. Lives in the canvas's space, built only on document
## changes; picked analytically, as the cards are. The start value is a puck
## even with plugs (D-065): it goes into no port, and the trigger takes it
## anywhere on it. As billboard cards do, a box turns to the head where it
## stands ([method face], D-090), so that its name and value face the user from
## the side too; with cuboid cards it keeps the graph's orientation.

const BOX_SIZE := Vector3(0.11, 0.045, 0.05)
## Centers of neighbouring boxes in the row of boxes never put anywhere are
## this far apart; the row is this far below the lowest card.
const SPACING := 0.15
const BELOW := 0.1
## Parts of a box the ray may hit.
const BODY := 0
const TRASH := 1
const TOKEN := 2
## An output of a component on the box's right side (D-105).
const COMPONENT := 3
## The switch of a box's drawer of components (D-108).
const DRAWER := 4
const DRAWER_SIZE := 0.018
## Components by type, as Break names its outputs; a component's port's
## radius, how far out of the box's side it is, the rows apart.
const COMPONENTS: Dictionary[int, Array] = {TYPE_VECTOR2: ["x", "y"], TYPE_VECTOR3: ["x", "y", "z"], TYPE_COLOR: ["r", "g", "b", "a"]}
const COMPONENT_RADIUS := 0.005
const COMPONENT_OUT := 0.008
const COMPONENT_STEP := 0.0135
## How far left the start value moves on a box with components: clear of their names.
const COMPONENT_ROOM := 0.012
## An archetypes' box (D-106), as the mockup's: a dark rounded card with a rim
## and a lid in its type's colour, its name and type on the lid, its start
## value below, its reading port on its right edge, its writes coming in at
## the top, a faint second card behind it for depth; its components in a
## drawer under it. Its height and corner; the lid's; how far the card behind
## is; how much of the type's colour the lid and the card behind have; the
## colours of the components x, y, z (r, g, b) and a.
const CARD_HEIGHT := 0.057
const CARD_CORNER := 0.015
const LID_HEIGHT := 0.025
const BEHIND := 0.0075
const LID_TINT := 0.3
const BEHIND_SEEN := 0.06
const AXES: Array[Color] = [Color("ff6b6b"), Color("7be5b3"), Color("89adff"), Color("c8cdd8")]
const DRAWER_ROW := 0.022
## How see-through a box is, and a box whose variable is in use behind a dim trash.
const BOX_ALPHA := 0.55
const USED_TRASH := 0.3

class Box:
	## The variable.
	var name := ""
	var node: Node3D
	var type := TYPE_NIL
	## Its port category: a collection's with its elements' (D-143).
	var category := XREBlueprintGraph.VALUE
	var value: Variant
	var used := false
	var trash: Node3D
	var trash_point := Vector3.ZERO
	var token: Node3D
	var token_text: Label3D
	var token_point := Vector3.ZERO
	var token_size := Vector3.ZERO
	## Its components' outputs (D-105), in the box's space, and their discs.
	var components: Array[Vector3] = []
	var component_ports: Array[Node3D] = []
	## Its extent, which an archetypes' box takes from its name and value (D-106).
	var extent := BOX_SIZE
	## Its drawer of components shut on its own (D-108), and its switch.
	var collapsed := false
	var drawer: Node3D
	var drawer_point := Vector3.ZERO
	## Where an archetypes' box is read and written, in its space (D-106).
	var read_point := Vector3.ZERO
	var write_point := Vector3.ZERO
	## It covers an input in use and is see-through (D-066).
	var faded := false
	## Its focus (D-072), a state of [XREBlueprintFocus], and how it is painted now: -1 not yet.
	var focus := XREBlueprintFocus.NORMAL
	var look := -1
	## How much it is grown under a ray, kept as it turns.
	var size := 1.0
	## A collection's elements' pucks (D-144): what names each in a reference
	## ([method item_ref]), where it is and how big, its puck and its text.
	var item_refs: Array[String] = []
	var item_points: Array[Vector3] = []
	var item_sizes: Array[Vector3] = []
	var item_nodes: Array[Node3D] = []
	var item_texts: Array[Label3D] = []
	## The plus after them and the × over the puck under a ray, on its element, or -1.
	var plus: Node3D
	var plus_point := Vector3.ZERO
	var mark: Node3D
	var mark_item := -1

## A collection variable's elements under its lid (D-143, D-144), each a puck
## of its own, as a Make block's pins: so many a row, at most so many, or pairs
## a row each; the gap between pucks and around a pair's arrow, a row; the
## plus after them, which adds one, and the × over the puck under the ray,
## which takes it away.
const ROW_ITEMS := 4
const MAX_ITEMS := 12
const MAX_PAIRS := 6
const ITEM_GAP := XREBlueprintCanvas.PIN_MARK_SIZE + 0.002
const ARROW_GAP := 0.014
const PAIR_ROW := 0.022
const PLUS_SIZE := 0.014
const MARK_SIZE := XREBlueprintCanvas.PIN_MARK_SIZE
## An element's puck, the plus after the elements and the × over a puck (D-144).
const ITEM := 5
const ITEM_PLUS := 6
const ITEM_MARK := 7
## The port of a collection's output (D-143): [method XREBlueprintCanvas.collection_visual] of its category.
var collection_port: Callable
var _boxes: Array[Box] = []
var _hit := -1
var _hit_part := BODY
var _hit_component := -1
var _hit_item := -1
## Grows with every change of what [method intersect_ray] reads, for the canvas's kept rays (D-169).
var pick_version := 0
var _mark_mesh: Mesh
var _split := false
var _archetype := false
## Whether a box's dot and output are shaped by its type (Port shapes, D-104), or circles.
var _shapes := false
var _archetype_trash: Material
## The box part under each hand's ray: the box, the part and its component (D-109), or -1.
var _hover_right := Vector3i(-1, -1, -1)
var _hover_left := Vector3i(-1, -1, -1)
var _trash_mesh: Mesh
var _trash_material: Material
## The head the boxes turn to (D-090), and whether they do: with billboard cards.
var _head := Vector3.ZERO
var _facing := false


func _init(trash_mesh: Mesh, trash_material: Material, archetype_trash: Material = null) -> void:
	name = "Boxes"
	_trash_mesh = trash_mesh
	_trash_material = trash_material
	_archetype_trash = archetype_trash


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED: pick_version += 1


## Rebuilds the boxes of [param graph]'s variables, each at its point of
## [param places] (canvas space, by variable); tokens in the [param style] of
## [constant XREFeatureSettings.VALUE_INPUT], text with Window. [param used]
## names the variables blocks refer to. With [param split] a vector's or a
## colour's box has an output for each component (D-105). With
## [param archetype] the boxes look as archetypes do (D-106); with [param shapes]
## their dots and outputs have their types' shapes, else they are circles (D-114).
func rebuild(graph: XREBlueprintGraph, places: Dictionary[String, Vector3], style: StringName, used: Dictionary, split: bool = false, archetype: bool = false, shapes: bool = false) -> void:
	pick_version += 1
	_split = split
	_archetype = archetype
	_shapes = shapes
	for box: Box in _boxes:
		remove_child(box.node)
		box.node.queue_free()
	_boxes.clear()
	_hover_right = Vector3i(-1, -1, -1)
	_hover_left = Vector3i(-1, -1, -1)
	for variable: Dictionary in graph.variables:
		var key := str(variable["name"])
		_add_box(key, variable.get("value"), XREBlueprintGraph.variable_type(variable), places.get(key, Vector3.ZERO), style, used.has(key), XREBlueprintTokens.variable_expression(variable), XREBlueprintCanvas.drawer_shut(graph, variable))

## Moves the boxes to their points of [param places] (canvas space, by
## variable), when only the graph's placement changed; creates nothing.
func place(places: Dictionary[String, Vector3]) -> void:
	pick_version += 1
	for box: Box in _boxes:
		if not places.has(box.name): continue
		box.node.position = places[box.name]
		_orient(box)


## Turns the boxes to [param head] (global) where they stand, as billboard cards
## turn ([method XREBlueprintCanvas.face_user]), with [param facing]; without it,
## as with cuboid cards, they keep the graph's orientation.
func face(head: Vector3, facing: bool) -> void:
	pick_version += 1
	_head = head
	_facing = facing
	for box: Box in _boxes: _orient(box)


func _orient(box: Box) -> void:
	if _facing and box.node.is_inside_tree(): box.node.global_basis = XREBlueprintPetals.face(box.node.global_position, _head, Vector3.UP)
	else: box.node.basis = Basis.IDENTITY
	box.node.scale = Vector3.ONE * box.size


## Shows the box of [param variable] at [param point] (canvas space) without editing the graph, as it is carried (D-078).
func move_box(variable: String, point: Vector3) -> void:
	pick_version += 1
	for box: Box in _boxes:
		if box.name != variable: continue
		box.node.position = point
		_orient(box)


func _add_box(variable: String, value: Variant, type: int, point: Vector3, style: StringName, used: bool, expression: String = "", collapsed: bool = false) -> void:
	var box := Box.new()
	box.name = variable
	box.collapsed = collapsed
	box.value = value
	box.used = used
	box.type = type
	box.category = XREBlueprintCollections.category_of(value) if value != null else XREBlueprintGraph.port_type(type)
	box.node = Node3D.new()
	box.node.name = "Box_" + variable
	box.node.position = point
	add_child(box.node)
	_orient(box)
	if _archetype:
		_add_card(box, style, expression)
		_boxes.append(box)
		return
	var shape := BoxMesh.new()
	shape.size = BOX_SIZE
	var color := XREBlueprintCanvas.type_color(box.category)
	color.a = BOX_ALPHA
	box.node.add_child(XRERig.create_vr_mesh(shape, XREBlueprintCanvas.material(color, true)))
	var front := BOX_SIZE.z * 0.5 + 0.001
	var title := XREBlueprintCanvas.label("%s : %s" % [variable, type_string(type)], 16)
	title.position = Vector3(0, BOX_SIZE.y * 0.5 + 0.016, 0)
	box.node.add_child(title)
	box.trash_point = Vector3(-BOX_SIZE.x * 0.5 + 0.014, 0, front)
	box.trash = Node3D.new()
	box.trash.position = box.trash_point
	var trash := XRERig.create_vr_mesh(_trash_mesh, _trash_material)
	if used: trash.transparency = 1.0 - USED_TRASH
	box.trash.add_child(trash)
	box.node.add_child(box.trash)
	var shown := XREBlueprintTokens.shown(value, "", expression) if value != null else "empty"
	var shift := -COMPONENT_ROOM if _split and COMPONENTS.has(type) else 0.0
	if value == null:
		# Its token taken out (D-054): an empty slot that takes one back.
		var slot := BoxMesh.new()
		slot.size = Vector3(XREBlueprintTokens.width("0.0"), XREBlueprintTokens.HEIGHT, 0.002)
		box.token_point = Vector3(0.012 + shift, 0, front)
		var mesh := XRERig.create_vr_mesh(slot, XREBlueprintCanvas.material(Color(1, 1, 1, 0.5), true))
		mesh.position = box.token_point
		box.node.add_child(mesh)
		box.token_size = Vector3(slot.size.x, XREBlueprintTokens.HEIGHT, 0.012)
	elif style == XREFeatureSettings.WINDOW:
		box.token_text = XREBlueprintCanvas.label("= " + shown, 16)
		box.token_text.position = Vector3(0.012 + shift, 0, front + 0.001)
		box.node.add_child(box.token_text)
		box.token_point = box.token_text.position
		box.token_size = Vector3(XREBlueprintTokens.width(shown) * 0.8, XREBlueprintTokens.HEIGHT, 0.01)
	else:
		var width := XREBlueprintTokens.width(shown) * 0.85
		box.token = XREBlueprintCanvas.make_token(value, "", width, false, false, false, -1, shown)
		box.token.scale = Vector3.ONE * 0.85
		box.token_point = Vector3(0.012 + shift, 0, front)
		box.token.position = box.token_point
		box.node.add_child(box.token)
		box.token_text = box.token.get_meta(&"text") as Label3D
		box.token_size = Vector3(width, XREBlueprintTokens.HEIGHT, 0.012)
	if _split and COMPONENTS.has(type):
		_add_drawer_switch(box, Vector3(BOX_SIZE.x * 0.5 - 0.01, BOX_SIZE.y * 0.5 + 0.012, BOX_SIZE.z * 0.5))
		if not box.collapsed: _add_components(box)
	_boxes.append(box)


## An archetypes' box (D-106): see [constant CARD_HEIGHT].
func _add_card(box: Box, style: StringName, expression: String) -> void:
	var color := XREBlueprintCanvas.type_color(box.category)
	var shown := XREBlueprintTokens.shown(box.value, "", expression) if box.value != null else "empty"
	var value_width := XREBlueprintTokens.width(shown) * 0.85
	var short := type_string(box.type).to_lower() if box.type in [TYPE_BOOL, TYPE_INT, TYPE_FLOAT] else type_string(box.type)
	# A collection (D-143): its type in full, its first elements or pairs under the lid, a pair a row.
	var collection := XREBlueprintCollections.is_collection(box.category)
	var rows := 1
	var layout: Array[Dictionary] = []
	if collection:
		short = XREBlueprintCollections.hint(box.category)
		layout = _item_layout(box)
		value_width = 0.03
		for entry: Dictionary in layout:
			value_width = maxf(value_width, float(entry["x"]) + float(entry["width"]))
			rows = maxi(rows, int(entry["row"]) + 1)
	var height := CARD_HEIGHT + PAIR_ROW * (rows - 1)
	var name_width := XREBlueprintCanvas.text_width(box.name, 18) + XREBlueprintCanvas.text_width(short, 14) + 0.012 + (0.02 if collection else 0.0)
	var width := maxf(maxf(name_width + 0.05, value_width + 0.05), 0.12)
	box.extent = Vector3(width, height, 0.008)
	var outline := XREBlueprintShapes.rounded_rect(Vector2(width, height), Vector4.ONE * CARD_CORNER)
	var behind := XRERig.create_vr_mesh(XREBlueprintShapes.body(outline, 0.002), under_material(Color(color, BEHIND_SEEN)))
	behind.position = Vector3(BEHIND, BEHIND, -0.004)
	box.node.add_child(behind)
	var behind_rim := XRERig.create_vr_mesh(XREBlueprintShapes.ring(outline, 0.0, 0.0012, 0.0), under_material(Color(color, 0.35)))
	behind_rim.position = behind.position
	box.node.add_child(behind_rim)
	box.node.add_child(XRERig.create_vr_mesh(XREBlueprintShapes.body(outline, box.extent.z), under_material(XREBlueprintIcons.BODY)))
	var front := box.extent.z * 0.5
	var lid := XREBlueprintShapes.rounded_rect(Vector2(width, LID_HEIGHT), Vector4(CARD_CORNER, CARD_CORNER, 0, 0))
	var lid_mesh := XRERig.create_vr_mesh(XREBlueprintShapes.body(lid, 0.001), under_material(XREBlueprintIcons.BODY.lerp(color, LID_TINT)))
	lid_mesh.position = Vector3(0, height * 0.5 - LID_HEIGHT * 0.5, front + 0.0004)
	box.node.add_child(lid_mesh)
	# The rim, and a line of it under the lid, as a headed card's (D-110, D-114):
	# in front of the lid, whose face is 0.9 mm out and hid them at 0.8 mm.
	var rim := SurfaceTool.new()
	rim.begin(Mesh.PRIMITIVE_TRIANGLES)
	rim.append_from(XREBlueprintShapes.ring(outline, 0.0, 0.0017, front + 0.0011), 0, Transform3D.IDENTITY)
	var line := XREBlueprintShapes.rounded_rect(Vector2(width - 0.0034, 0.0017), Vector4.ZERO)
	rim.append_from(XREBlueprintShapes.body(line, 0.0001), 0, Transform3D(Basis.IDENTITY, Vector3(0, height * 0.5 - LID_HEIGHT, front + 0.0011)))
	box.node.add_child(XRERig.create_vr_mesh(rim.commit(), XREBlueprintCanvas.material(color, true)))
	var lid_y := height * 0.5 - LID_HEIGHT * 0.5
	var dot := XRERig.create_vr_mesh(XREBlueprintShapes.port_mesh(_port_shape(box), XREBlueprintCanvas.PORT_RADIUS, XREBlueprintCanvas.PORT_DEPTH * 2.0), XREBlueprintCanvas.material(color, true))
	dot.scale = Vector3.ONE * 0.5
	dot.position = Vector3(-width * 0.5 + 0.015, lid_y, front + 0.0012)
	box.node.add_child(dot)
	var title := XREBlueprintCanvas.label(box.name, 18)
	title.modulate = color.lerp(Color.WHITE, 0.5)
	var left := -width * 0.5 + 0.027
	title.position = Vector3(left + XREBlueprintCanvas.text_width(box.name, 18) * 0.5, lid_y, front + 0.0014)
	box.node.add_child(title)
	var kind := XREBlueprintCanvas.label(short, 14)
	kind.modulate = Color(1, 1, 1, 0.55)
	kind.position = Vector3(left + XREBlueprintCanvas.text_width(box.name, 18) + 0.006 + XREBlueprintCanvas.text_width(short, 14) * 0.5, lid_y, front + 0.0014)
	box.node.add_child(kind)
	var value_y := -height * 0.5 + (height - LID_HEIGHT) * 0.5
	box.token_point = Vector3(width * 0.5 - 0.015 - value_width * 0.5, value_y, front + 0.001)
	if collection:
		# Its elements on the left under the lid, each its own puck (D-144); folded, its count types the list (D-143).
		box.token_size = Vector3.ZERO
		_add_items(box, layout, -width * 0.5 + 0.012, value_y + PAIR_ROW * (rows - 1) * 0.5, front + 0.001)
	elif box.value == null:
		var slot := BoxMesh.new()
		slot.size = Vector3(XREBlueprintTokens.width("0.0"), XREBlueprintTokens.HEIGHT, 0.002)
		var mesh := XRERig.create_vr_mesh(slot, XREBlueprintCanvas.material(Color(1, 1, 1, 0.5), true))
		mesh.position = box.token_point
		box.node.add_child(mesh)
		box.token_size = Vector3(slot.size.x, XREBlueprintTokens.HEIGHT, 0.012)
	elif style == XREFeatureSettings.WINDOW:
		box.token_text = XREBlueprintCanvas.label("= " + shown, 16)
		box.token_text.position = box.token_point
		box.node.add_child(box.token_text)
		box.token_size = Vector3(XREBlueprintTokens.width(shown) * 0.8, XREBlueprintTokens.HEIGHT, 0.01)
	else:
		box.token = XREBlueprintCanvas.make_token(box.value, "", value_width / 0.85, false, false, false, -1, shown)
		box.token.scale = Vector3.ONE * 0.85
		box.token.position = box.token_point
		box.node.add_child(box.token)
		box.token_text = box.token.get_meta(&"text") as Label3D
		box.token_size = Vector3(value_width, XREBlueprintTokens.HEIGHT, 0.012)
	# Read on the right edge, written from the top (D-106).
	box.read_point = Vector3(width * 0.5, 0, front + 0.002)
	box.write_point = Vector3(0, height * 0.5, front)
	# A collection's is its grid or stack, as its cards' ports are (D-143).
	var read: MeshInstance3D = collection_port.call(box.category) if collection and collection_port.is_valid() else XRERig.create_vr_mesh(XREBlueprintShapes.port_mesh(_port_shape(box), XREBlueprintCanvas.PORT_RADIUS, XREBlueprintCanvas.PORT_DEPTH * 2.0), XREBlueprintCanvas.material(color, true))
	read.position = box.read_point
	box.node.add_child(read)
	# The trash, as an archetype's: over the right corner, while the ray is on the box.
	box.trash_point = Vector3(width * 0.5 - 0.023, height * 0.5 + XREBlueprintCanvas.TRASH_RISE, front + 0.002)
	box.trash = Node3D.new()
	box.trash.position = box.trash_point
	var trash := XRERig.create_vr_mesh(_trash_mesh, _archetype_trash if _archetype_trash != null else _trash_material)
	trash.scale = Vector3.ONE * XREBlueprintCanvas.TRASH_SCALE
	if box.used: trash.transparency = 1.0 - USED_TRASH
	box.trash.add_child(trash)
	box.trash.visible = false
	box.node.add_child(box.trash)
	if _split and COMPONENTS.has(box.type):
		_add_drawer_switch(box, Vector3(width * 0.5 - 0.016, height * 0.5 - LID_HEIGHT * 0.5, front + 0.0016))
		if not box.collapsed: _add_drawer(box)
	# A collection's chevron folds its elements to their count, as a drawer of components (D-114, D-143).
	elif collection: _add_drawer_switch(box, Vector3(width * 0.5 - 0.016, height * 0.5 - LID_HEIGHT * 0.5, front + 0.0016))


## How [param box]'s elements lie under its lid (D-143, D-144), from its left
## and its first row: entries of [code]kind[/code] "item" (a puck, its
## [code]value[/code] and its [code]ref[/code], [method item_ref]), "arrow"
## between a pair's key and value, "plus" after the last, which adds one,
## "more" past the last shown, or "count" folded or empty; each with its
## [code]x[/code], [code]row[/code] and [code]width[/code]. An array's pucks
## go [constant ROW_ITEMS] a row, a dictionary's pairs a row each.
func _item_layout(box: Box) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var count := (box.value as Array).size() if box.value is Array else (box.value as Dictionary).size() if box.value is Dictionary else 0
	if box.collapsed or box.value == null or count == 0:
		var text := _count_text(box)
		result.append({"kind": "count", "x": 0.0, "row": 0, "width": XREBlueprintCanvas.text_width(text, 16)})
		# An empty one takes its first element by its plus.
		if not box.collapsed and box.value != null: result.append({"kind": "plus", "x": XREBlueprintCanvas.text_width(text, 16) + ITEM_GAP * 0.5, "row": 0, "width": PLUS_SIZE})
		return result
	var x := 0.0
	var row := 0
	if box.value is Dictionary:
		var pairs := box.value as Dictionary
		var keys := pairs.keys()
		for index: int in mini(keys.size(), MAX_PAIRS):
			row = index
			x = _lay_item(result, keys[index], "%dk" % index, 0.0, row)
			result.append({"kind": "arrow", "x": x, "row": row, "width": ARROW_GAP})
			x = _lay_item(result, pairs[keys[index]], "%dv" % index, x + ARROW_GAP, row)
		result.append({"kind": "more" if keys.size() > MAX_PAIRS else "plus", "x": x + ITEM_GAP, "row": row, "width": XREBlueprintTokens.width("…") if keys.size() > MAX_PAIRS else PLUS_SIZE})
		return result
	var items := box.value as Array
	for index: int in mini(items.size(), MAX_ITEMS):
		if index > 0 and index % ROW_ITEMS == 0:
			row += 1
			x = 0.0
		x = _lay_item(result, items[index], str(index), x, row) + ITEM_GAP
	if items.size() > MAX_ITEMS:
		result.append({"kind": "more", "x": x, "row": row, "width": XREBlueprintTokens.width("…")})
		return result
	if items.size() % ROW_ITEMS == 0:
		row += 1
		x = 0.0
	result.append({"kind": "plus", "x": x, "row": row, "width": PLUS_SIZE})
	return result


## A puck of [param value] for [method _item_layout] at [param x] of [param row]; where it ends.
static func _lay_item(layout: Array[Dictionary], value: Variant, ref: String, x: float, row: int) -> float:
	var width := XREBlueprintTokens.width(XREBlueprintTokens.text(value, "")) * 0.85
	layout.append({"kind": "item", "value": value, "ref": ref, "x": x, "row": row, "width": width})
	return x + width


## "3 items", "1 item", "2 pairs": a folded collection, or an empty one.
static func _count_text(box: Box) -> String:
	var count := (box.value as Array).size() if box.value is Array else (box.value as Dictionary).size() if box.value is Dictionary else 0
	var noun := "pair" if box.value is Dictionary else "item"
	return "%d %s%s" % [count, noun, "" if count == 1 else "s"]


## Puts [param box]'s elements under its lid as [param layout] lays them
## ([method _item_layout]) from [param left], the first row at [param top]:
## pucks shown as they are, not taken; the × over them hidden till a ray is on one.
func _add_items(box: Box, layout: Array[Dictionary], left: float, top: float, z: float) -> void:
	for entry: Dictionary in layout:
		var width := float(entry["width"])
		var point := Vector3(left + float(entry["x"]) + width * 0.5, top - int(entry["row"]) * PAIR_ROW, z)
		match str(entry["kind"]):
			"item":
				var value: Variant = entry["value"]
				var text := XREBlueprintTokens.text(value, "")
				var token := XREBlueprintCanvas.make_token(value, "", width / 0.85, false, false, false, -1, text)
				token.scale = Vector3.ONE * 0.85
				token.position = point
				box.node.add_child(token)
				box.item_refs.append(str(entry["ref"]))
				box.item_points.append(point)
				box.item_sizes.append(Vector3(width, XREBlueprintTokens.HEIGHT * 0.85, 0.012))
				box.item_nodes.append(token)
				box.item_texts.append(token.get_meta(&"text") as Label3D)
			"arrow":
				var arrow := XREBlueprintCanvas.label("→", 16)
				arrow.position = point
				box.node.add_child(arrow)
			"plus":
				box.plus_point = point
				box.plus = Node3D.new()
				box.plus.name = "ItemPlus"
				box.plus.position = point
				for size: Vector3 in [Vector3(PLUS_SIZE * 0.8, 0.0025, 0.0015), Vector3(0.0025, PLUS_SIZE * 0.8, 0.0015)]:
					var bar := BoxMesh.new()
					bar.size = size
					box.plus.add_child(XRERig.create_vr_mesh(bar, XREBlueprintCanvas.material(Color(0.78, 0.8, 0.85), true)))
				box.node.add_child(box.plus)
			_:
				# Folded, empty or past the last shown: the trigger on it types the list (D-143).
				box.token_text = XREBlueprintCanvas.label(_count_text(box) if entry["kind"] == "count" else "…", 16)
				box.token_text.modulate = Color(1, 1, 1, 0.7)
				box.token_text.position = point
				box.node.add_child(box.token_text)
				box.token_point = point
				box.token_size = Vector3(width, XREBlueprintTokens.HEIGHT, 0.012)
	if box.item_refs.is_empty(): return
	# The same × as a Make block's pin's (D-137).
	box.mark = Node3D.new()
	box.mark.name = "ItemMark"
	if _mark_mesh == null: _mark_mesh = XREBlueprintCanvas._make_pin_mark_mesh()
	box.mark.add_child(XRERig.create_vr_mesh(_mark_mesh, XREBlueprintCanvas.material(XREBlueprintCanvas.PIN_MARK_COLOR, true)))
	box.mark.visible = false
	box.node.add_child(box.mark)


## Where the × of element [param item]'s puck stands: in the gap right of it,
## as a pin's right of its name — of a pair, right of its value, as it takes the pair.
static func _mark_point(box: Box, item: int) -> Vector3:
	if box.item_refs[item].ends_with("k") and item + 1 < box.item_points.size(): item += 1
	return box.item_points[item] + Vector3(box.item_sizes[item].x * 0.5 + ITEM_GAP * 0.5, 0, 0.003)


## The reference to the element [param suffix] of [param variable]'s start
## value (D-144), which [method box_value], [method preview_value] and
## [method token_transform] take as a box's name: an array's index, a
## dictionary's pair's index with "k" for its key or "v" for its value.
static func item_ref(variable: String, suffix: String) -> String:
	return "%s#%s" % [variable, suffix]


## The element of collection [param value] that [param suffix] names ([method item_ref]); null for none.
static func item_value(value: Variant, suffix: String) -> Variant:
	var index := suffix.trim_suffix("k").trim_suffix("v").to_int()
	if value is Array: return (value as Array)[index] if index >= 0 and index < (value as Array).size() else null
	if not value is Dictionary: return null
	var keys := (value as Dictionary).keys()
	if index < 0 or index >= keys.size(): return null
	return keys[index] if suffix.ends_with("k") else (value as Dictionary)[keys[index]]


## [param value], a collection of [param category], with the element
## [param suffix] names set to [param item], in its place; null if it can't
## take it: of another type, or a key another pair has.
static func with_item(value: Variant, suffix: String, item: Variant, category: int) -> Variant:
	var index := suffix.trim_suffix("k").trim_suffix("v").to_int()
	var result: Variant = null
	if value is Array:
		var items: Array = []
		items.assign(value as Array)
		if index < 0 or index >= items.size(): return null
		items[index] = item
		result = items
	elif value is Dictionary:
		var source := value as Dictionary
		var keys := source.keys()
		if index < 0 or index >= keys.size(): return null
		var key_side := suffix.ends_with("k")
		if key_side and item != keys[index] and source.has(item): return null
		var pairs := {}
		for at: int in keys.size():
			if at != index: pairs[keys[at]] = source[keys[at]]
			elif key_side: pairs[item] = source[keys[at]]
			else: pairs[keys[at]] = item
		result = pairs
	else: return null
	return result if XREBlueprintCollections.is_untyped(category) else XREBlueprintCollections.typed(result, category)


## [param value], a collection of [param category], without the element
## [param suffix] names — a dictionary's whole pair —; null for none.
static func without_item(value: Variant, suffix: String, category: int) -> Variant:
	var index := suffix.trim_suffix("k").trim_suffix("v").to_int()
	var result: Variant = null
	if value is Array:
		var items: Array = []
		items.assign(value as Array)
		if index < 0 or index >= items.size(): return null
		items.remove_at(index)
		result = items
	elif value is Dictionary:
		var source := value as Dictionary
		var keys := source.keys()
		if index < 0 or index >= keys.size(): return null
		var pairs := {}
		for at: int in keys.size():
			if at != index: pairs[keys[at]] = source[keys[at]]
		result = pairs
	else: return null
	if XREBlueprintCollections.is_untyped(category): return result
	return XREBlueprintCollections.typed(result, category) if not (result is Array and (result as Array).is_empty() or result is Dictionary and (result as Dictionary).is_empty()) else XREBlueprintCollections.empty(category)


## The type whose port shape [param box]'s dot and output take: its own with
## Port shapes on, a float's circle with it off, as the cards' ports are (D-114).
func _port_shape(box: Box) -> int:
	return XREBlueprintGraph.port_type(box.type) if _shapes else XREBlueprintGraph.NUMBER


## The switch of [param box]'s drawer of components at [param point] (D-108):
## ▾ while open, ▸ while shut; the trigger on it opens or shuts it.
func _add_drawer_switch(box: Box, point: Vector3) -> void:
	box.drawer_point = point
	box.drawer = Node3D.new()
	box.drawer.position = point
	var quad := QuadMesh.new()
	quad.size = Vector2.ONE * DRAWER_SIZE
	var face := XREBlueprintCanvas.material(Color.WHITE, true)
	face.albedo_texture = XREBlueprintIcons.texture(&"drawer_shut" if box.collapsed else &"drawer_open", 64, false)
	box.drawer.add_child(XRERig.create_vr_mesh(quad, face))
	box.node.add_child(box.drawer)


## An archetypes' box's components (D-105, D-106): a drawer under it, each
## component's name in its axis's colour and its output on the right edge.
func _add_drawer(box: Box) -> void:
	var names: Array = COMPONENTS[box.type]
	var color := XREBlueprintCanvas.type_color(box.category)
	var height := names.size() * DRAWER_ROW + 0.012
	var outline := XREBlueprintShapes.rounded_rect(Vector2(box.extent.x - 0.01, height), Vector4(0, 0, 0.012, 0.012))
	var top := -CARD_HEIGHT * 0.5 + 0.007
	var drawer := XRERig.create_vr_mesh(XREBlueprintShapes.body(outline, 0.004), under_material(XREBlueprintIcons.PURE_BODY))
	drawer.position = Vector3(0.005, top - height * 0.5, -0.001)
	box.node.add_child(drawer)
	var rim := XRERig.create_vr_mesh(XREBlueprintShapes.ring(outline, 0.0, 0.0012, 0.0021), XREBlueprintCanvas.material(Color(color, 0.5), true))
	rim.position = drawer.position
	box.node.add_child(rim)
	var front := box.extent.z * 0.5
	for index: int in names.size():
		var point := Vector3(box.extent.x * 0.5, top - 0.007 - DRAWER_ROW * (index + 0.5), front)
		var port := XRERig.create_vr_mesh(XREBlueprintShapes.port_mesh(XREBlueprintGraph.NUMBER, COMPONENT_RADIUS, 0.002), XREBlueprintCanvas.material(XREBlueprintCanvas.type_color(XREBlueprintGraph.NUMBER), true))
		port.position = point
		box.node.add_child(port)
		var text := XREBlueprintCanvas.label(str(names[index]), 16)
		text.modulate = AXES[mini(index, AXES.size() - 1)]
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		text.position = point + Vector3(-0.012, 0, 0.001)
		box.node.add_child(text)
		box.components.append(point)
		box.component_ports.append(port)
	box.extent.y += height
	# The box's centre stays its card's: its picking box grows down by the drawer.


## An archetypes' box's face in [param color] (D-106): drawn before the labels
## and tokens on it, as a card's face is, so that sorting never puts it over them.
static func under_material(color: Color) -> StandardMaterial3D:
	return XREBlueprintCanvas._shared_material([&"under", color], func() -> Material:
		var result := XREBlueprintCanvas.material(color, true)
		result.render_priority = Material.RENDER_PRIORITY_MAX - 1
		return result) as StandardMaterial3D


## Shows each box's trash while a ray is on it (D-106), as archetypes' cards do:
## [param focused] names the boxes in focus.
func show_trashes(focused: Array[String]) -> void:
	if not _archetype: return
	pick_version += 1
	for box: Box in _boxes:
		if box.trash != null: box.trash.visible = focused.has(box.name)


## The outputs of [param box]'s components on its right side, top first, in
## float's colour, each named (D-105).
func _add_components(box: Box) -> void:
	var names: Array = COMPONENTS[box.type]
	var disc := CylinderMesh.new()
	disc.top_radius = COMPONENT_RADIUS
	disc.bottom_radius = COMPONENT_RADIUS
	disc.height = 0.002
	disc.radial_segments = 16
	var color := XREBlueprintCanvas.type_color(XREBlueprintGraph.NUMBER)
	for index: int in names.size():
		var point := Vector3(BOX_SIZE.x * 0.5 + COMPONENT_OUT, (names.size() - 1) * COMPONENT_STEP * 0.5 - index * COMPONENT_STEP, BOX_SIZE.z * 0.5)
		var port := XRERig.create_vr_mesh(disc, XREBlueprintCanvas.material(color, true))
		port.rotation.x = PI * 0.5
		port.position = point
		box.node.add_child(port)
		var text := XREBlueprintCanvas.label(str(names[index]), 12)
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		text.position = point + Vector3(-COMPONENT_RADIUS - 0.004, 0, 0.001)
		box.node.add_child(text)
		box.components.append(point)
		box.component_ports.append(port)


## Makes the boxes that cover an input in use see-through, as the cards (D-066, [method XREBlueprintCanvas.fade_covering]).
func fade_covering(eye: Vector3, targets: PackedVector4Array, count: int) -> void:
	for box: Box in _boxes:
		if box.node == null: continue
		var faded := count > 0 and visible and XREBlueprintFade.covers(eye, targets, count, box.node.global_transform * _bounds(box))
		if faded == box.faded: continue
		box.faded = faded
		pick_version += 1
		XREBlueprintFade.set_faded(box.node, faded)


## What the last [method intersect_ray] hit: the box, its part, component and element; for the canvas's kept rays (D-169).
func get_hit_state() -> Vector4i:
	return Vector4i(_hit, _hit_part, _hit_component, _hit_item)


## Puts back what [method get_hit_state] gave.
func set_hit_state(state: Vector4i) -> void:
	_hit = state.x
	_hit_part = state.y
	_hit_component = state.z
	_hit_item = state.w


## Nearest box part on the ray, in the canvas's space; -1 if none. The hit is
## kept for [method get_hit_name] and [method get_hit_part].
func intersect_ray(origin: Vector3, direction: Vector3, maximum: float) -> float:
	_hit = -1
	_hit_part = BODY
	_hit_component = -1
	_hit_item = -1
	var nearest := maximum
	for index: int in _boxes.size():
		var box := _boxes[index]
		# See-through over an input in use, a box doesn't take the ray (D-067).
		if box.faded: continue
		# In the box's own space, as it turns to the head; the ray's parameter is the same in both.
		var inverse := box.node.transform.affine_inverse()
		var local_origin := inverse * origin
		var local_direction := inverse.basis * direction
		# A component's output stands out of the box's side: it takes the ray first (D-105).
		for component: int in box.components.size():
			var size := Vector3.ONE * COMPONENT_RADIUS * 2.0 + Vector3(0.002, 0.0, 0.006)
			var at := XREBlueprintCanvas._box_distance(local_origin, local_direction, AABB(box.components[component] - size * 0.5, size), nearest)
			if at < 0: continue
			nearest = at
			_hit = index
			_hit_part = COMPONENT
			_hit_component = component
		if _hit == index and _hit_part == COMPONENT: continue
		# The drawer's switch takes the ray before the box under it (D-108).
		if box.drawer != null:
			var switch := XREBlueprintCanvas._box_distance(local_origin, local_direction, AABB(box.drawer_point - Vector3(0.012, 0.012, 0.006), Vector3(0.024, 0.024, 0.012)), nearest)
			if switch >= 0:
				nearest = switch
				_hit = index
				_hit_part = DRAWER
				continue
		# An archetypes' trash stands over the box, shown under the ray (D-106).
		if _archetype and box.trash.visible:
			var trash_box := AABB(box.trash_point - Vector3(0.012, 0.014, 0.006), Vector3(0.024, 0.028, 0.012))
			var over := XREBlueprintCanvas._box_distance(local_origin, local_direction, trash_box, nearest)
			if over >= 0:
				nearest = over
				_hit = index
				_hit_part = TRASH
				continue
			# The air between the trash and the box keeps the box under the ray, so
			# the trash doesn't hide on the way to it (D-114).
			var gap := XREBlueprintCanvas._box_distance(local_origin, local_direction, trash_box.expand(Vector3(trash_box.position.x, _bounds(box).end.y, trash_box.position.z)), nearest)
			if gap >= 0:
				nearest = gap
				_hit = index
				_hit_part = BODY
				continue
		var body := XREBlueprintCanvas._box_distance(local_origin, local_direction, _bounds(box), nearest)
		if body < 0: continue
		nearest = body
		_hit = index
		_hit_part = BODY
		var trash := XREBlueprintCanvas._box_distance(local_origin, local_direction, AABB(box.trash_point - Vector3(0.012, 0.014, 0.006), Vector3(0.024, 0.028, 0.012)), INF)
		var token := XREBlueprintCanvas._box_distance(local_origin, local_direction, AABB(box.token_point - box.token_size * 0.5 - Vector3(0.003, 0.003, 0.003), box.token_size + Vector3(0.006, 0.006, 0.006)), INF) if box.token_size != Vector3.ZERO else -1.0
		if trash >= 0 and trash <= nearest + box.extent.z and not _archetype:
			_hit_part = TRASH
		elif _hit_items(box, local_origin, local_direction, nearest + box.extent.z): pass
		elif token >= 0 and token <= nearest + box.extent.z:
			_hit_part = TOKEN
	if _hit < 0 or not _hit_part in [ITEM, ITEM_MARK]: _hit_item = -1
	return nearest if _hit >= 0 else -1.0


## Whether the ray in [param box]'s space hits, no farther than [param reach],
## the × over a puck, the plus or an element's puck (D-144), in that order: kept as the hit part.
func _hit_items(box: Box, origin: Vector3, direction: Vector3, reach: float) -> bool:
	if box.mark != null and box.mark.visible and box.mark_item >= 0:
		var at := XREBlueprintCanvas._box_distance(origin, direction, AABB(box.mark.position - Vector3(0.007, 0.007, 0.006), Vector3(0.014, 0.014, 0.012)), INF)
		if at >= 0 and at <= reach:
			_hit_part = ITEM_MARK
			_hit_item = box.mark_item
			return true
	if box.plus != null:
		var at := XREBlueprintCanvas._box_distance(origin, direction, AABB(box.plus_point - Vector3(0.009, 0.009, 0.006), Vector3(0.018, 0.018, 0.012)), INF)
		if at >= 0 and at <= reach:
			_hit_part = ITEM_PLUS
			return true
	for item: int in box.item_points.size():
		var size := box.item_sizes[item] + Vector3(0.003, 0.003, 0.0)
		var at := XREBlueprintCanvas._box_distance(origin, direction, AABB(box.item_points[item] - size * 0.5, size), INF)
		if at < 0 or at > reach: continue
		_hit_part = ITEM
		_hit_item = item
		return true
	return false


## The reference to the element whose puck or × the last ray hit ([method item_ref]); empty for none.
func get_hit_item() -> String:
	if _hit < 0 or _hit_item < 0 or not _hit_part in [ITEM, ITEM_MARK]: return ""
	var box := _boxes[_hit]
	return item_ref(box.name, box.item_refs[_hit_item]) if _hit_item < box.item_refs.size() else ""


## The component's output or the element's puck or × the last ray hit, for [method hover]; -1 for none.
func get_hit_slot() -> int:
	if _hit_part == COMPONENT: return _hit_component
	return _hit_item if _hit_part in [ITEM, ITEM_MARK] else -1


## The color of the box part the last ray hit, for the pipette (D-065): its
## start value if it is a color and the ray is on it, else the box's own; null for none.
func get_hit_color() -> Variant:
	if _hit < 0: return null
	var box := _boxes[_hit]
	if _hit_part == TOKEN and box.value is Color: return box.value
	return XREBlueprintCanvas.type_color(box.category)


## The variable of the box the last ray hit, empty for none.
func get_hit_name() -> String:
	return _boxes[_hit].name if _hit >= 0 else ""


## Whether the last ray hit a box.
func has_hit() -> bool:
	return _hit >= 0


## Which component's output the last ray hit (D-105), -1 for none.
func get_hit_component() -> int:
	return _hit_component if _hit_part == COMPONENT else -1


## Where the output of component [param component] of [param variable]'s box
## is, in the canvas's space (D-105); the box's centre without one.
func component_point(variable: String, component: int) -> Vector3:
	for box: Box in _boxes:
		if box.name == variable and component >= 0 and component < box.components.size(): return box.node.transform * box.components[component]
	return box_point(variable)


## The part of the box the last ray hit: [constant BODY], [constant TRASH], [constant TOKEN] or [constant COMPONENT].
func get_hit_part() -> int:
	return _hit_part


## Grows the part under the [param right] hand's ray, or the other's, as a
## card's trash grows; -1 for none; a component's output by [param component],
## as a card's port grows (D-109), or an element's puck, which shows the × over
## it ([method get_hit_slot], D-144). Each hand keeps its own, so that an idle
## ray can't take the other's away.
func hover(index: int, part: int, right: bool, component: int = -1) -> void:
	var key := Vector3i(index, part, component if part in [COMPONENT, ITEM, ITEM_MARK] else -1) if index >= 0 else Vector3i(-1, -1, -1)
	if key == (_hover_right if right else _hover_left): return
	pick_version += 1
	if right: _hover_right = key
	else: _hover_left = key
	for box: int in _boxes.size():
		var item := _boxes[box]
		var right_part := _hover_right.y if _hover_right.x == box else -1
		var left_part := _hover_left.y if _hover_left.x == box else -1
		if item.trash != null: item.trash.scale = Vector3.ONE * (XREBlueprintCanvas.HOVER_SCALE if TRASH in [right_part, left_part] else 1.0)
		if item.token != null: item.token.scale = Vector3.ONE * (0.85 * XREBlueprintCanvas.SOCKET_HOVER if TOKEN in [right_part, left_part] else 0.85)
		# The drawer's switch grows under the ray, as the trash does (D-110).
		if item.drawer != null: item.drawer.scale = Vector3.ONE * (XREBlueprintCanvas.HOVER_SCALE if DRAWER in [right_part, left_part] else 1.0)
		item.size = 1.06 if BODY in [right_part, left_part] else 1.0
		item.node.scale = Vector3.ONE * item.size
		for output: int in item.component_ports.size():
			var lit := (_hover_right.x == box and _hover_right.y == COMPONENT and _hover_right.z == output) or (_hover_left.x == box and _hover_left.y == COMPONENT and _hover_left.z == output)
			item.component_ports[output].scale = Vector3.ONE * (XREBlueprintCanvas.HOVER_SCALE if lit else 1.0)
		# An element's puck grows under a ray and shows the × over it, which stays while the ray is on the × (D-144).
		var on := _hover_right.z if _hover_right.x == box and _hover_right.y in [ITEM, ITEM_MARK] else _hover_left.z if _hover_left.x == box and _hover_left.y in [ITEM, ITEM_MARK] else -1
		for element: int in item.item_nodes.size():
			item.item_nodes[element].scale = Vector3.ONE * (0.85 * XREBlueprintCanvas.SOCKET_HOVER if element == on and ITEM in [right_part, left_part] else 0.85)
		if item.plus != null: item.plus.scale = Vector3.ONE * (XREBlueprintCanvas.HOVER_SCALE if ITEM_PLUS in [right_part, left_part] else 1.0)
		if item.mark != null:
			item.mark_item = on if on >= 0 and on < item.item_points.size() else -1
			item.mark.visible = item.mark_item >= 0
			if item.mark.visible: item.mark.position = _mark_point(item, item.mark_item)
			item.mark.scale = Vector3.ONE * (XREBlueprintCanvas.HOVER_SCALE if ITEM_MARK in [right_part, left_part] else 1.0)


## How many boxes there are.
func box_count() -> int:
	return _boxes.size()


## The variable of box [param index].
func box_name(index: int) -> String:
	return _boxes[index].name


## Puts box [param index] in focus [param state] (D-072), painted
## [param paint_as] ([XREBlueprintFocus]) with [param seen] of it seen. Only a change is painted.
func paint_box(index: int, state: int, paint_as: int, seen: float) -> void:
	var box := _boxes[index]
	box.focus = state
	var look := paint_as * 2 + (1 if seen < 1.0 else 0)
	if look == box.look: return
	box.look = look
	XREBlueprintFocus.paint(box.node, paint_as)
	XREBlueprintFade.set_seen(box.node, &"focus", seen)


## How the box of [param variable] is in focus, a state of [XREBlueprintFocus].
func box_focus(variable: String) -> int:
	for box: Box in _boxes:
		if box.name == variable: return box.focus
	return XREBlueprintFocus.NORMAL


## Forgets how the boxes are painted: the next [method paint_box] paints them again.
func forget_looks() -> void:
	for box: Box in _boxes: box.look = -1


## Index of the box the last ray hit, for [method hover]; -1 for none.
func get_hit_index() -> int:
	return _hit


## The centre of the box of [param variable], in the canvas's space; the origin if it has none.
func box_point(variable: String) -> Vector3:
	for box: Box in _boxes:
		if box.name == variable and not variable.is_empty(): return box.node.position
	return Vector3.ZERO


## Where a wire from the box of [param variable] to [param toward] (the
## canvas's space) leaves it, and its direction there (D-063): aimed at the
## box's centre, out of the side that faces that point, so that it comes in
## from any side, not only the left; the box as it is turned. An archetypes'
## box (D-106) is read from its right edge and written from its top, [param writes].
func box_end(variable: String, toward: Vector3, writes: bool = false) -> Array[Vector3]:
	for box: Box in _boxes:
		if box.name != variable or variable.is_empty(): continue
		var center := box.node.position
		var turn := box.node.basis.orthonormalized()
		if _archetype:
			var end: Array[Vector3] = [box.node.transform * box.read_point, turn * Vector3.RIGHT]
			if writes: end = [box.node.transform * box.write_point, turn * Vector3.UP]
			return end
		var along := toward - center
		if along.length() < 0.0001: return [center, Vector3.LEFT]
		along = along.normalized()
		var inside := turn.inverse() * along
		var reach := INF
		for axis: int in 3:
			if absf(inside[axis]) > 0.0001: reach = minf(reach, BOX_SIZE[axis] * 0.5 / absf(inside[axis]))
		return [center + along * reach, along]
	return [Vector3.ZERO, Vector3.LEFT]


## The box [param box]'s picking bounds in its space: its card, and its drawer under it (D-106).
static func _bounds(box: Box) -> AABB:
	if box.extent == BOX_SIZE or box.components.is_empty(): return AABB(-box.extent * 0.5, box.extent)
	var top := CARD_HEIGHT * 0.5
	return AABB(Vector3(-box.extent.x * 0.5, top - box.extent.y, -box.extent.z * 0.5), box.extent)


## Whether a box shows [param variable].
func has_box(variable: String) -> bool:
	for box: Box in _boxes:
		if box.name == variable and not variable.is_empty(): return true
	return false


## The value the box of [param variable] shows, or an element of it by its reference ([method item_ref]).
func box_value(variable: String) -> Variant:
	var name := variable.get_slice("#", 0)
	for box: Box in _boxes:
		if box.name != name: continue
		return box.value if not variable.contains("#") else item_value(box.value, variable.get_slice("#", 1))
	return null


## Shows [param value] on the box of [param variable], or on an element's puck
## by its reference, while it is turned, without editing the graph; as
## [param shown] says if given (D-063).
func preview_value(variable: String, value: Variant, shown: String = "") -> void:
	var name := variable.get_slice("#", 0)
	for box: Box in _boxes:
		if box.name != name: continue
		var text := shown if not shown.is_empty() else XREBlueprintTokens.text(value, "")
		if variable.contains("#"):
			var item := box.item_refs.find(variable.get_slice("#", 1))
			if item >= 0 and box.item_texts[item] != null: box.item_texts[item].text = text
		elif box.token_text != null: box.token_text.text = ("= " if box.token == null else "") + text


## The global transform of the token of [param variable]'s box, or of an
## element's puck by its reference, for a hand that takes it or a widget over it.
func token_transform(variable: String) -> Transform3D:
	var name := variable.get_slice("#", 0)
	for box: Box in _boxes:
		if box.name != name: continue
		var point := box.token_point
		if variable.contains("#"):
			var item := box.item_refs.find(variable.get_slice("#", 1))
			if item >= 0: point = box.item_points[item]
		return box.node.global_transform * Transform3D(Basis.IDENTITY, point)
	return global_transform
