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
	## It covers an input in use and is see-through (D-066).
	var faded := false
	## Its focus (D-072), a state of [XREBlueprintFocus], and how it is painted now: -1 not yet.
	var focus := XREBlueprintFocus.NORMAL
	var look := -1

var _boxes: Array[Box] = []
var _hit := -1
var _hit_part := BODY
## The box part under each hand's ray: the box and the part, or -1.
var _hover_right := Vector2i(-1, -1)
var _hover_left := Vector2i(-1, -1)
var _trash_mesh: Mesh
var _trash_material: Material


func _init(trash_mesh: Mesh, trash_material: Material) -> void:
	name = "Boxes"
	_trash_mesh = trash_mesh
	_trash_material = trash_material


## Rebuilds the boxes of [param graph]'s variables, each at its point of
## [param places] (canvas space, by variable); tokens in the [param style] of
## [constant XREFeatureSettings.VALUE_INPUT], text with Window. [param used]
## names the variables blocks refer to.
func rebuild(graph: XREBlueprintGraph, places: Dictionary[String, Vector3], style: StringName, used: Dictionary) -> void:
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
	if value == null:
		# Its token taken out (D-054): an empty slot that takes one back.
		var slot := BoxMesh.new()
		slot.size = Vector3(XREBlueprintTokens.width("0.0"), XREBlueprintTokens.HEIGHT, 0.002)
		box.token_point = Vector3(0.012, 0, front)
		var mesh := XRERig.create_vr_mesh(slot, XREBlueprintCanvas.material(Color(1, 1, 1, 0.5), true))
		mesh.position = box.token_point
		box.node.add_child(mesh)
		box.token_size = Vector3(slot.size.x, XREBlueprintTokens.HEIGHT, 0.012)
	elif style == XREFeatureSettings.WINDOW:
		box.token_text = XREBlueprintCanvas.label("= " + shown, 16)
		box.token_text.position = Vector3(0.012, 0, front + 0.001)
		box.node.add_child(box.token_text)
		box.token_point = box.token_text.position
		box.token_size = Vector3(XREBlueprintTokens.width(shown) * 0.8, XREBlueprintTokens.HEIGHT, 0.01)
	else:
		var width := XREBlueprintTokens.width(shown) * 0.85
		box.token = XREBlueprintCanvas.make_token(value, "", width, false, false, false, -1, shown)
		box.token.scale = Vector3.ONE * 0.85
		box.token_point = Vector3(0.012, 0, front)
		box.token.position = box.token_point
		box.node.add_child(box.token)
		box.token_text = box.token.get_meta(&"text") as Label3D
		box.token_size = Vector3(width, XREBlueprintTokens.HEIGHT, 0.012)
	_boxes.append(box)


## Makes the boxes that cover an input in use see-through, as the cards (D-066, [method XREBlueprintCanvas.fade_covering]).
func fade_covering(eye: Vector3, targets: PackedVector4Array, count: int) -> void:
	for box: Box in _boxes:
		if box.node == null: continue
		var faded := count > 0 and visible and XREBlueprintFade.covers(eye, targets, count, box.node.global_transform * AABB(-BOX_SIZE * 0.5, BOX_SIZE))
		if faded == box.faded: continue
		box.faded = faded
		XREBlueprintFade.set_faded(box.node, faded)


## Nearest box part on the ray, in the canvas's space; -1 if none. The hit is
## kept for [method get_hit_name] and [method get_hit_part].
func intersect_ray(origin: Vector3, direction: Vector3, maximum: float) -> float:
	_hit = -1
	_hit_part = BODY
	var nearest := maximum
	for index: int in _boxes.size():
		var box := _boxes[index]
		# See-through over an input in use, a box doesn't take the ray (D-067).
		if box.faded: continue
		var local_origin := origin - box.node.position
		var body := XREBlueprintCanvas._box_distance(local_origin, direction, AABB(-BOX_SIZE * 0.5, BOX_SIZE), nearest)
		if body < 0: continue
		nearest = body
		_hit = index
		_hit_part = BODY
		var trash := XREBlueprintCanvas._box_distance(local_origin, direction, AABB(box.trash_point - Vector3(0.012, 0.014, 0.006), Vector3(0.024, 0.028, 0.012)), INF)
		var token := XREBlueprintCanvas._box_distance(local_origin, direction, AABB(box.token_point - box.token_size * 0.5 - Vector3(0.003, 0.003, 0.003), box.token_size + Vector3(0.006, 0.006, 0.006)), INF)
		if trash >= 0 and trash <= nearest + BOX_SIZE.z:
			_hit_part = TRASH
		elif token >= 0 and token <= nearest + BOX_SIZE.z:
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


## The part of the box the last ray hit: [constant BODY], [constant TRASH] or [constant TOKEN].
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
func box_end(variable: String, toward: Vector3) -> Array[Vector3]:
	var center := box_point(variable)
	var along := toward - center
	if along.length() < 0.0001: return [center, Vector3.LEFT]
	along = along.normalized()
	var reach := INF
	for axis: int in 3:
		if absf(along[axis]) > 0.0001: reach = minf(reach, BOX_SIZE[axis] * 0.5 / absf(along[axis]))
	return [center + along * reach, along]


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
