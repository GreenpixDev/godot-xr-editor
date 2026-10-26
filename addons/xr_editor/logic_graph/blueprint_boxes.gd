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
## anywhere on it.

const BOX_SIZE := Vector3(0.11, 0.045, 0.05)
## Centers of neighbouring boxes in the row of boxes never put anywhere are
## this far apart; the row is this far below the lowest card.
const SPACING := 0.15
const BELOW := 0.1
## Parts of a box the ray may hit.
const BODY := 0
const TRASH := 1
const TOKEN := 2
## An output of a component on the box's right side (D-096).
const COMPONENT := 3
## Components by type, as Break names its outputs; a component's port's
## radius, how far out of the box's side it is, the rows apart.
const COMPONENTS: Dictionary[int, Array] = {TYPE_VECTOR2: ["x", "y"], TYPE_VECTOR3: ["x", "y", "z"], TYPE_COLOR: ["r", "g", "b", "a"]}
const COMPONENT_RADIUS := 0.005
const COMPONENT_OUT := 0.008
const COMPONENT_STEP := 0.0135
## How far left the start value moves on a box with components: clear of their names.
const COMPONENT_ROOM := 0.012
## An archetypes' box (D-097), as the mockup's: a dark rounded card with a rim
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
	var value: Variant
	var used := false
	var trash: Node3D
	var trash_point := Vector3.ZERO
	var token: Node3D
	var token_text: Label3D
	var token_point := Vector3.ZERO
	var token_size := Vector3.ZERO
	## Its components' outputs (D-096), in the box's space, and their discs.
	var components: Array[Vector3] = []
	var component_ports: Array[Node3D] = []
	## Its size, which an archetypes' box takes from its name and value (D-097).
	var size := BOX_SIZE
	## Where an archetypes' box is read and written, in its space (D-097).
	var read_point := Vector3.ZERO
	var write_point := Vector3.ZERO
	## It covers an input in use and is see-through (D-066).
	var faded := false
	## Its focus (D-072), a state of [XREBlueprintFocus], and how it is painted now: -1 not yet.
	var focus := XREBlueprintFocus.NORMAL
	var look := -1

var _boxes: Array[Box] = []
var _hit := -1
var _hit_part := BODY
var _hit_component := -1
var _split := false
var _archetype := false
var _archetype_trash: Material
## The box part under each hand's ray: the box and the part, or -1.
var _hover_right := Vector2i(-1, -1)
var _hover_left := Vector2i(-1, -1)
var _trash_mesh: Mesh
var _trash_material: Material


func _init(trash_mesh: Mesh, trash_material: Material, archetype_trash: Material = null) -> void:
	name = "Boxes"
	_trash_mesh = trash_mesh
	_trash_material = trash_material
	_archetype_trash = archetype_trash


## Rebuilds the boxes of [param graph]'s variables, each at its point of
## [param places] (canvas space, by variable); tokens in the [param style] of
## [constant XREFeatureSettings.VALUE_INPUT], text with Window. [param used]
## names the variables blocks refer to. With [param split] a vector's or a
## colour's box has an output for each component (D-096). With
## [param archetype] the boxes look as archetypes do (D-097).
func rebuild(graph: XREBlueprintGraph, places: Dictionary[String, Vector3], style: StringName, used: Dictionary, split: bool = false, archetype: bool = false) -> void:
	_split = split
	_archetype = archetype
	for box: Box in _boxes:
		remove_child(box.node)
		box.node.queue_free()
	_boxes.clear()
	_hover_right = Vector2i(-1, -1)
	_hover_left = Vector2i(-1, -1)
	for variable: Dictionary in graph.variables:
		var key := str(variable["name"])
		_add_box(key, variable.get("value"), XREBlueprintGraph.variable_type(variable), places.get(key, Vector3.ZERO), style, used.has(key), XREBlueprintTokens.variable_expression(variable))


## Moves the boxes to their points of [param places] (canvas space, by
## variable), when only the graph's placement changed; creates nothing.
func place(places: Dictionary[String, Vector3]) -> void:
	for box: Box in _boxes:
		if places.has(box.name): box.node.position = places[box.name]


## Shows the box of [param variable] at [param point] (canvas space) without editing the graph, as it is carried (D-078).
func move_box(variable: String, point: Vector3) -> void:
	for box: Box in _boxes:
		if box.name == variable: box.node.position = point


func _add_box(variable: String, value: Variant, type: int, point: Vector3, style: StringName, used: bool, expression: String = "") -> void:
	var box := Box.new()
	box.name = variable
	box.value = value
	box.used = used
	box.type = type
	box.node = Node3D.new()
	box.node.name = "Box_" + variable
	box.node.position = point
	add_child(box.node)
	if _archetype:
		_add_card(box, style, expression)
		_boxes.append(box)
		return
	var shape := BoxMesh.new()
	shape.size = BOX_SIZE
	var color := XREBlueprintCanvas.COLORS[XREBlueprintGraph.port_type(box.type)]
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
	if _split and COMPONENTS.has(type): _add_components(box)
	_boxes.append(box)


## An archetypes' box (D-097): see [constant CARD_HEIGHT].
func _add_card(box: Box, style: StringName, expression: String) -> void:
	var color := XREBlueprintCanvas.COLORS[XREBlueprintGraph.port_type(box.type)]
	var shown := XREBlueprintTokens.shown(box.value, "", expression) if box.value != null else "empty"
	var value_width := XREBlueprintTokens.width(shown) * 0.85
	var short := type_string(box.type).to_lower() if box.type in [TYPE_BOOL, TYPE_INT, TYPE_FLOAT] else type_string(box.type)
	var name_width := XREBlueprintCanvas.text_width(box.name, 18) + XREBlueprintCanvas.text_width(short, 14) + 0.012
	var width := maxf(maxf(name_width + 0.05, value_width + 0.05), 0.12)
	box.size = Vector3(width, CARD_HEIGHT, 0.008)
	var outline := XREBlueprintShapes.rounded_rect(Vector2(width, CARD_HEIGHT), Vector4.ONE * CARD_CORNER)
	var behind := XRERig.create_vr_mesh(XREBlueprintShapes.body(outline, 0.002), under_material(Color(color, BEHIND_SEEN)))
	behind.position = Vector3(BEHIND, BEHIND, -0.004)
	box.node.add_child(behind)
	var behind_rim := XRERig.create_vr_mesh(XREBlueprintShapes.ring(outline, 0.0, 0.0012, 0.0), under_material(Color(color, 0.35)))
	behind_rim.position = behind.position
	box.node.add_child(behind_rim)
	box.node.add_child(XRERig.create_vr_mesh(XREBlueprintShapes.body(outline, box.size.z), under_material(XREBlueprintIcons.BODY)))
	var front := box.size.z * 0.5
	var lid := XREBlueprintShapes.rounded_rect(Vector2(width, LID_HEIGHT), Vector4(CARD_CORNER, CARD_CORNER, 0, 0))
	var lid_mesh := XRERig.create_vr_mesh(XREBlueprintShapes.body(lid, 0.001), under_material(XREBlueprintIcons.BODY.lerp(color, LID_TINT)))
	lid_mesh.position = Vector3(0, CARD_HEIGHT * 0.5 - LID_HEIGHT * 0.5, front + 0.0004)
	box.node.add_child(lid_mesh)
	box.node.add_child(XRERig.create_vr_mesh(XREBlueprintShapes.ring(outline, 0.0, 0.0017, front + 0.0008), XREBlueprintCanvas.material(color, true)))
	var lid_y := CARD_HEIGHT * 0.5 - LID_HEIGHT * 0.5
	var dot := XRERig.create_vr_mesh(XREBlueprintShapes.port_mesh(XREBlueprintGraph.port_type(box.type), XREBlueprintCanvas.PORT_RADIUS, XREBlueprintCanvas.PORT_DEPTH * 2.0), XREBlueprintCanvas.material(color, true))
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
	var value_y := -CARD_HEIGHT * 0.5 + (CARD_HEIGHT - LID_HEIGHT) * 0.5
	box.token_point = Vector3(width * 0.5 - 0.015 - value_width * 0.5, value_y, front + 0.001)
	if box.value == null:
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
	# Read on the right edge, written from the top (D-097).
	box.read_point = Vector3(width * 0.5, 0, front + 0.002)
	box.write_point = Vector3(0, CARD_HEIGHT * 0.5, front)
	var read := XRERig.create_vr_mesh(XREBlueprintShapes.port_mesh(XREBlueprintGraph.port_type(box.type), XREBlueprintCanvas.PORT_RADIUS, XREBlueprintCanvas.PORT_DEPTH * 2.0), XREBlueprintCanvas.material(color, true))
	read.position = box.read_point
	box.node.add_child(read)
	# The trash, as an archetype's: over the right corner, while the ray is on the box.
	box.trash_point = Vector3(width * 0.5 - 0.023, CARD_HEIGHT * 0.5 + XREBlueprintCanvas.TRASH_RISE, front + 0.002)
	box.trash = Node3D.new()
	box.trash.position = box.trash_point
	var trash := XRERig.create_vr_mesh(_trash_mesh, _archetype_trash if _archetype_trash != null else _trash_material)
	trash.scale = Vector3.ONE * XREBlueprintCanvas.TRASH_SCALE
	if box.used: trash.transparency = 1.0 - USED_TRASH
	box.trash.add_child(trash)
	box.trash.visible = false
	box.node.add_child(box.trash)
	if _split and COMPONENTS.has(box.type): _add_drawer(box)


## An archetypes' box's components (D-096, D-097): a drawer under it, each
## component's name in its axis's colour and its output on the right edge.
func _add_drawer(box: Box) -> void:
	var names: Array = COMPONENTS[box.type]
	var color := XREBlueprintCanvas.COLORS[XREBlueprintGraph.port_type(box.type)]
	var height := names.size() * DRAWER_ROW + 0.012
	var outline := XREBlueprintShapes.rounded_rect(Vector2(box.size.x - 0.01, height), Vector4(0, 0, 0.012, 0.012))
	var top := -CARD_HEIGHT * 0.5 + 0.007
	var drawer := XRERig.create_vr_mesh(XREBlueprintShapes.body(outline, 0.004), under_material(XREBlueprintIcons.PURE_BODY))
	drawer.position = Vector3(0.005, top - height * 0.5, -0.001)
	box.node.add_child(drawer)
	var rim := XRERig.create_vr_mesh(XREBlueprintShapes.ring(outline, 0.0, 0.0012, 0.0021), XREBlueprintCanvas.material(Color(color, 0.5), true))
	rim.position = drawer.position
	box.node.add_child(rim)
	var front := box.size.z * 0.5
	for index: int in names.size():
		var point := Vector3(box.size.x * 0.5, top - 0.007 - DRAWER_ROW * (index + 0.5), front)
		var port := XRERig.create_vr_mesh(XREBlueprintShapes.port_mesh(XREBlueprintGraph.NUMBER, COMPONENT_RADIUS, 0.002), XREBlueprintCanvas.material(XREBlueprintCanvas.COLORS[XREBlueprintGraph.NUMBER], true))
		port.position = point
		box.node.add_child(port)
		var text := XREBlueprintCanvas.label(str(names[index]), 16)
		text.modulate = AXES[mini(index, AXES.size() - 1)]
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		text.position = point + Vector3(-0.012, 0, 0.001)
		box.node.add_child(text)
		box.components.append(point)
		box.component_ports.append(port)
	box.size.y += height
	# The box's centre stays its card's: its picking box grows down by the drawer.


## An archetypes' box's face in [param color] (D-097): drawn before the labels
## and tokens on it, as a card's face is, so that sorting never puts it over them.
static func under_material(color: Color) -> StandardMaterial3D:
	var result := XREBlueprintCanvas.material(color, true)
	result.render_priority = Material.RENDER_PRIORITY_MAX - 1
	return result


## Shows each box's trash while a ray is on it (D-097), as archetypes' cards do:
## [param focused] names the boxes in focus.
func show_trashes(focused: Array[String]) -> void:
	if not _archetype: return
	for box: Box in _boxes:
		if box.trash != null: box.trash.visible = focused.has(box.name)


## The outputs of [param box]'s components on its right side, top first, in
## float's colour, each named (D-096).
func _add_components(box: Box) -> void:
	var names: Array = COMPONENTS[box.type]
	var disc := CylinderMesh.new()
	disc.top_radius = COMPONENT_RADIUS
	disc.bottom_radius = COMPONENT_RADIUS
	disc.height = 0.002
	disc.radial_segments = 16
	var color := XREBlueprintCanvas.COLORS[XREBlueprintGraph.NUMBER]
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
		XREBlueprintFade.set_faded(box.node, faded)


## Nearest box part on the ray, in the canvas's space; -1 if none. The hit is
## kept for [method get_hit_name] and [method get_hit_part].
func intersect_ray(origin: Vector3, direction: Vector3, maximum: float) -> float:
	_hit = -1
	_hit_part = BODY
	_hit_component = -1
	var nearest := maximum
	for index: int in _boxes.size():
		var box := _boxes[index]
		# See-through over an input in use, a box doesn't take the ray (D-067).
		if box.faded: continue
		var local_origin := origin - box.node.position
		# A component's output stands out of the box's side: it takes the ray first (D-096).
		for component: int in box.components.size():
			var size := Vector3.ONE * COMPONENT_RADIUS * 2.0 + Vector3(0.002, 0.0, 0.006)
			var at := XREBlueprintCanvas._box_distance(local_origin, direction, AABB(box.components[component] - size * 0.5, size), nearest)
			if at < 0: continue
			nearest = at
			_hit = index
			_hit_part = COMPONENT
			_hit_component = component
		if _hit == index and _hit_part == COMPONENT: continue
		# An archetypes' trash stands over the box, shown under the ray (D-097).
		if _archetype and box.trash.visible:
			var over := XREBlueprintCanvas._box_distance(local_origin, direction, AABB(box.trash_point - Vector3(0.012, 0.014, 0.006), Vector3(0.024, 0.028, 0.012)), nearest)
			if over >= 0:
				nearest = over
				_hit = index
				_hit_part = TRASH
				continue
		var body := XREBlueprintCanvas._box_distance(local_origin, direction, _bounds(box), nearest)
		if body < 0: continue
		nearest = body
		_hit = index
		_hit_part = BODY
		var trash := XREBlueprintCanvas._box_distance(local_origin, direction, AABB(box.trash_point - Vector3(0.012, 0.014, 0.006), Vector3(0.024, 0.028, 0.012)), INF)
		var token := XREBlueprintCanvas._box_distance(local_origin, direction, AABB(box.token_point - box.token_size * 0.5 - Vector3(0.003, 0.003, 0.003), box.token_size + Vector3(0.006, 0.006, 0.006)), INF)
		if trash >= 0 and trash <= nearest + box.size.z and not _archetype:
			_hit_part = TRASH
		elif token >= 0 and token <= nearest + box.size.z:
			_hit_part = TOKEN
	return nearest if _hit >= 0 else -1.0


## The color of the box part the last ray hit, for the pipette (D-065): its
## start value if it is a color and the ray is on it, else the box's own; null for none.
func get_hit_color() -> Variant:
	if _hit < 0: return null
	var box := _boxes[_hit]
	if _hit_part == TOKEN and box.value is Color: return box.value
	return XREBlueprintCanvas.COLORS[XREBlueprintGraph.port_type(box.type)]


## The variable of the box the last ray hit, empty for none.
func get_hit_name() -> String:
	return _boxes[_hit].name if _hit >= 0 else ""


## Whether the last ray hit a box.
func has_hit() -> bool:
	return _hit >= 0


## Which component's output the last ray hit (D-096), -1 for none.
func get_hit_component() -> int:
	return _hit_component if _hit_part == COMPONENT else -1


## Where the output of component [param component] of [param variable]'s box
## is, in the canvas's space (D-096); the box's centre without one.
func component_point(variable: String, component: int) -> Vector3:
	for box: Box in _boxes:
		if box.name == variable and component >= 0 and component < box.components.size(): return box.node.position + box.components[component]
	return box_point(variable)


## The part of the box the last ray hit: [constant BODY], [constant TRASH], [constant TOKEN] or [constant COMPONENT].
func get_hit_part() -> int:
	return _hit_part


## Grows the part under the [param right] hand's ray, or the other's, as a
## card's trash grows; -1 for none. Each hand keeps its own, so that an idle
## ray can't take the other's away.
func hover(index: int, part: int, right: bool) -> void:
	var key := Vector2i(index, part) if index >= 0 else Vector2i(-1, -1)
	if key == (_hover_right if right else _hover_left): return
	if right: _hover_right = key
	else: _hover_left = key
	for box: int in _boxes.size():
		var item := _boxes[box]
		var right_part := _hover_right.y if _hover_right.x == box else -1
		var left_part := _hover_left.y if _hover_left.x == box else -1
		if item.trash != null: item.trash.scale = Vector3.ONE * (XREBlueprintCanvas.HOVER_SCALE if TRASH in [right_part, left_part] else 1.0)
		if item.token != null: item.token.scale = Vector3.ONE * (0.85 * XREBlueprintCanvas.SOCKET_HOVER if TOKEN in [right_part, left_part] else 0.85)
		item.node.scale = Vector3.ONE * (1.06 if BODY in [right_part, left_part] else 1.0)


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
## from any side, not only the left.
## An archetypes' box (D-097) is read from its right edge and written from its
## top, [param writes].
func box_end(variable: String, toward: Vector3, writes: bool = false) -> Array[Vector3]:
	if _archetype:
		for box: Box in _boxes:
			if box.name != variable: continue
			var end: Array[Vector3] = [box.node.position + box.read_point, Vector3.RIGHT]
			if writes: end = [box.node.position + box.write_point, Vector3.UP]
			return end
	var center := box_point(variable)
	var along := toward - center
	if along.length() < 0.0001: return [center, Vector3.LEFT]
	along = along.normalized()
	var reach := INF
	for axis: int in 3:
		if absf(along[axis]) > 0.0001: reach = minf(reach, BOX_SIZE[axis] * 0.5 / absf(along[axis]))
	return [center + along * reach, along]


## The box [param box]'s picking bounds in its space: its card, and its drawer under it (D-097).
static func _bounds(box: Box) -> AABB:
	if box.size == BOX_SIZE or box.components.is_empty(): return AABB(-box.size * 0.5, box.size)
	var top := CARD_HEIGHT * 0.5
	return AABB(Vector3(-box.size.x * 0.5, top - box.size.y, -box.size.z * 0.5), box.size)


## Whether a box shows [param variable].
func has_box(variable: String) -> bool:
	for box: Box in _boxes:
		if box.name == variable and not variable.is_empty(): return true
	return false


## The value the box of [param variable] shows.
func box_value(variable: String) -> Variant:
	for box: Box in _boxes:
		if box.name == variable: return box.value
	return null


## Shows [param value] on the box of [param variable] while it is turned,
## without editing the graph; as [param shown] says if given (D-063).
func preview_value(variable: String, value: Variant, shown: String = "") -> void:
	for box: Box in _boxes:
		if box.name == variable and box.token_text != null:
			box.token_text.text = ("= " if box.token == null else "") + (shown if not shown.is_empty() else XREBlueprintTokens.text(value, ""))


## The global transform of the token of [param variable]'s box, for a hand that takes it.
func token_transform(variable: String) -> Transform3D:
	for box: Box in _boxes:
		if box.name == variable: return box.node.global_transform * Transform3D(Basis.IDENTITY, box.token_point)
	return global_transform
