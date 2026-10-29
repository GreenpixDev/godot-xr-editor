@tool
class_name XREBlueprintRing
extends XREBlueprintPetals
## The block palette as a ring (D-093, drawn as D-094 says, its groups as
## D-095 and D-096 say), a value of [constant XREFeatureSettings.BLOCK_PALETTE]:
## around the point the palette opens from, facing the head, a disc with a
## magnifier — Search, the list —, around it a ring of the seven general task
## groups and Object, always the same in the same places, and over it an arc
## of the context object's groups — Move, Look, Sound —, only those it has,
## under its name. Drawn over everything (D-096). Each group is a sector with its name and a stripe on its outer edge in
## the color of the cards it adds. The ray on a group lights it and shows its
## blocks as a column of pills in their cards' colors: beside the ring, on the
## group's side, for a general group; above the arc for the object's, leaning
## toward the head, square to the line of sight to its middle (D-098). The
## trigger on one adds it. A group with no block for the wire is dim and
## shows nothing. Built as it opens and when another group is shown, never per
## frame; picked analytically: the disc and the sectors by distance and angle
## from the middle, the pills by their rectangles.

## The disc's radius, the gap around it and the ring's outer radius, in meters.
const DISC := 0.034
const GAP := 0.004
const OUTER := 0.118
## The gap between two sectors, in meters along the ring, and a sector's edge.
const SECTOR_GAP := 0.004
const EDGE := 0.0016
## How far beside the ring the blocks' spine stands, and the ticks from it to the pills.
const SPINE := 0.03
const TICK := 0.01
## The groups of the ring, clockwise from the top: Object, always here, dim
## without an object (D-096), at the top under the middle of the arc of the
## object's other groups (D-097), then the general ones, as
## [constant XREBlueprintActions.GENERAL_TASKS] names them, and last, between
## Variables and Object, the graph's own functions (docs/blueprint_functions.md).
const ORDER: Array[String] = ["Object", "Arithmetic", "Logic", "Math", "Flow", "Utility", "Events", "Variables", "Functions"]
## The arc of the object's other groups — Move, Look, Sound (D-095, D-096):
## its radii, in meters, and the angle of one group on it.
const BAND_IN := 0.152
const BAND_OUT := 0.205
const BAND_STEP := 0.33
## How far above the arc the column of an object's group starts, and how far it may lean toward the head.
const LIFT := 0.03
const MAX_TILT := 1.2
## The faces of the cards each group adds, in [constant XREBlueprintCanvas.CARD_PALETTE]: its stripe's color; Utility and Object gray.
const GROUP_CARDS: Dictionary[String, int] = {"Events": 0, "Move": 1, "Look": 1, "Flow": 2, "Arithmetic": 3, "Logic": 3, "Math": 3, "Variables": 3, "Sound": 4}
## The light edges of the card faces, by [constant XREBlueprintCanvas.CARD_PALETTE]; the Object group's own gray.
const CARD_EDGES: Array[Color] = [Color("89adff"), Color("7be5b3"), Color("c9a8f2"), Color("a9b4f5"), Color("e5b57b"), Color("e8879b")]
const OBJECT_EDGE := Color("c8cdd8")
## Functions' stripe: the teal of their calls.
const FUNCTIONS_EDGE := Color("6fd3dc")
const FILL := Color("1d2026", 0.94)
const FILL_HOT := Color("3b404b", 0.97)
const DISC_FILL := Color("2b2f38", 0.96)
const LINE := Color(1, 1, 1, 0.18)
const SPINE_COLOR := Color("c8cdd8", 0.7)
## How much of a dim group is seen.
const DIM_ALPHA := 0.45

## The groups: [code]{"title", "items", "outer", "from", "to"}[/code], the
## general ones in [constant ORDER], then the object's on the arc from the
## left; their sectors between the angles [code]from[/code] and [code]to[/code].
var _sectors: Array[Dictionary] = []
## The arc's angle, half of it each side of the top; 0 without the object's groups.
var _span := 0.0
## The group whose blocks are shown, or -1, and how many petals the ring itself has: the disc and the groups.
var _open_sector := -1
var _ring_count := 0
var _column: Node3D
## The fills of the disc and the sectors, and of the pills, by petal; their colors, and their edges'.
var _fills: Array[MeshInstance3D] = []
var _fill_colors: Array[Color] = []
var _edge_colors: Array[Color] = []


func _init() -> void:
	super()
	name = "Ring"


## Opens the ring at [param anchor] (global), facing [param head] upright along
## [param up], for [param object] ([method XREBlueprintPetals.get_object]).
## [param groups] maps a task group's title to its blocks, petal items
## [code]{"text", "action", …}[/code], the likeliest first; [param middle] is
## the disc's item. [param objects] are the groups of the arc, under [param label], the object's name.
func open_ring(object: Node3D, anchor: Vector3, head: Vector3, up: Vector3, groups: Dictionary, middle: Dictionary, objects: Array[String] = [], label: String = "") -> void:
	_object = object
	_anchor = anchor
	_head = head
	_up = up.normalized()
	_sectors = []
	var half := PI / ORDER.size()
	for index: int in ORDER.size():
		var items: Array = groups.get(ORDER[index], [])
		_sectors.append({"title": ORDER[index], "items": items, "outer": false, "from": sector_angle(index) - half, "to": sector_angle(index) + half})
	# Object is in the ring itself: the arc has the rest.
	var arc := objects.filter(func(title: String) -> bool: return not title in ORDER)
	_span = BAND_STEP * arc.size()
	for index: int in arc.size():
		var items: Array = groups.get(arc[index], [])
		var to := PI * 0.5 + _span * 0.5 - index * BAND_STEP
		_sectors.append({"title": arc[index], "items": items, "outer": true, "from": to - BAND_STEP, "to": to})
	_open_sector = -1
	_clear()
	_column = null
	_fills.clear()
	_fill_colors.clear()
	_edge_colors.clear()
	_add_disc(middle)
	for index: int in _sectors.size(): _add_sector(index)
	_ring_count = _petals.size()
	if _span > 0.0 and not label.is_empty():
		var name_label := XREBlueprintCanvas.label(label, 12)
		name_label.modulate = Color("a7afc1")
		name_label.position = Vector3(0.0, (OUTER + BAND_IN) * 0.5, 0.002)
		add_child(name_label)
	visible = true
	if _on_top: _raise(self, true)
	follow(head)


## Turns the ring to [param head] about its middle and scales it to keep its
## size in view, as the fan does. Only its transform.
func follow(head: Vector3) -> void:
	if not is_open(): return
	_head = head
	var growth := clampf(_anchor.distance_to(_head) / FULL_SIZE_DISTANCE, 1.0, MAX_GROWTH)
	global_transform = Transform3D(face(_anchor, _head, _up) * Basis.from_scale(Vector3.ONE * growth), _anchor)


## The angle of general group [param index]'s middle in the ring's plane, counterclockwise from the right.
static func sector_angle(index: int) -> float:
	return PI * 0.5 - index * TAU / ORDER.size()


## Shows the blocks of group [param index] beside the ring and lights the
## group; nothing for a group already shown or an empty one.
func open_sector(index: int) -> void:
	if index == _open_sector or index < 0 or index >= _sectors.size() or (_sectors[index]["items"] as Array).is_empty(): return
	var before := _open_sector
	_open_sector = index
	# The column of the group shown before goes, with its pills.
	_petals.resize(_ring_count)
	_fills.resize(_ring_count)
	_fill_colors.resize(_ring_count)
	_edge_colors.resize(_ring_count)
	if _hovered >= _ring_count: _hovered = -1
	if is_instance_valid(_column):
		remove_child(_column)
		_column.queue_free()
	if before >= 0: _paint(before + 1)
	_paint(index + 1)
	_column = Node3D.new()
	_column.name = "Column"
	add_child(_column)
	var items: Array = _sectors[index]["items"]
	var angle := (float(_sectors[index]["from"]) + float(_sectors[index]["to"])) * 0.5
	if _sectors[index]["outer"]:
		# Over the arc, the likeliest lowest: the ray goes up to it over nothing
		# else. Upright it would rise far over the eyes: it leans toward the head (D-098).
		var base := Vector3(cos(angle), sin(angle), 0.0) * BAND_OUT
		var middle := LIFT + PILL_HEIGHT * 0.5 + (items.size() - 1) * STEP * 0.5
		_column.transform = Transform3D(Basis(Vector3.RIGHT, column_tilt(base, middle)), base)
		_column.add_child(_stick(Vector3.ZERO, Vector3(0.0, LIFT, 0.0), Color.WHITE, 0.0012))
		for row: int in items.size():
			var item: Dictionary = items[row]
			_add_block(item, Vector3(0.0, LIFT + PILL_HEIGHT * 0.5 + row * STEP, 0.0), XREBlueprintCanvas.text_width(str(item["text"]), 18) + 0.03)
		if _on_top: _raise(_column, true)
		return
	var tip := Vector3(cos(angle), sin(angle), 0.0) * OUTER
	var side := 1.0 if cos(angle) >= -0.01 else -1.0
	var spine := side * (OUTER + SPINE)
	var top := tip.y + (items.size() - 1) * STEP * 0.5
	var bottom := top - (items.size() - 1) * STEP
	_column.add_child(_stick(tip, Vector3(spine, tip.y, 0.0), Color.WHITE, 0.0012))
	_column.add_child(_stick(Vector3(spine, top, 0.0), Vector3(spine, bottom, 0.0), SPINE_COLOR, 0.0012))
	for row: int in items.size():
		var item: Dictionary = items[row]
		var y := top - row * STEP
		var width := XREBlueprintCanvas.text_width(str(item["text"]), 18) + 0.03
		_column.add_child(_stick(Vector3(spine, y, 0.0), Vector3(spine + side * TICK, y, 0.0), SPINE_COLOR, 0.001))
		_add_block(item, Vector3(spine + side * (TICK + width * 0.5), y, 0.0), width)
	if _on_top: _raise(_column, true)


## How far a column standing at [param base] in the ring's plane, its middle
## [param middle] up along it, leans toward the head about the ring's
## horizontal (D-098): the line of sight to its middle is square to it. With
## the lean a, along (0, cos a, sin a), that is (base − eye)·(0, cos a, sin a)
## + middle = 0. 0 for a middle under the eyes.
func column_tilt(base: Vector3, middle: float) -> float:
	var eye := global_transform.affine_inverse() * _head
	var up := base.y - eye.y
	var toward := base.z - eye.z
	var reach := Vector2(up, toward).length()
	if eye.z <= 0.01 or reach <= middle: return 0.0
	# up · cos a + toward · sin a = reach · cos(a − phase) = −middle.
	var phase := atan2(toward, up)
	var turn := acos(-middle / reach)
	var best := 0.0
	for lean: float in [phase + turn, phase - turn, phase + turn - TAU, phase - turn + TAU]:
		if lean >= 0.0 and lean <= MAX_TILT and (best == 0.0 or lean < best): best = lean
	return best


## Where the petal of [param item] is, global: a block's in its column, which may lean.
func item_position(item: Dictionary) -> Vector3:
	for index: int in _petals.size():
		if _petals[index].item == item: return global_transform * (_column_transform(index) * _petals[index].center)
	return global_position


## The group whose blocks are shown, by title, or empty.
func get_open_sector() -> String:
	return str(_sectors[_open_sector]["title"]) if _open_sector >= 0 else ""


## The items of the petals: the disc, the groups, then the blocks shown.
func get_shown() -> Array[Dictionary]:
	var shown: Array[Dictionary] = []
	for petal: Petal in _petals: shown.append(petal.item)
	return shown


func get_item_count() -> int:
	return _petals.size()


## Distance to the disc, the group or the block the ray hits, or -1; the item is [method get_hit].
func intersect_ray(origin: Vector3, direction: Vector3, maximum: float) -> float:
	_hit = -1
	if not is_open(): return -1.0
	var inverse := global_transform.affine_inverse()
	var local_origin := inverse * origin
	var local_direction := inverse.basis * direction
	if absf(local_direction.z) < 0.000001: return -1.0
	var distance := -local_origin.z / local_direction.z
	if distance >= 0.0 and distance <= maximum:
		var point := local_origin + local_direction * distance
		var world := origin.distance_to(global_transform * point)
		var radius := Vector2(point.x, point.y).length()
		if radius <= DISC + GAP * 0.5:
			_hit = 0
			return world
		if radius <= OUTER + 0.004:
			# Clockwise from the top, as the groups go; a group's middle is at its angle.
			var turn := fposmod(PI * 0.5 - atan2(point.y, point.x) + PI / ORDER.size(), TAU)
			_hit = 1 + mini(floori(turn / (TAU / ORDER.size())), ORDER.size() - 1)
			return world
		var along := PI * 0.5 + _span * 0.5 - atan2(point.y, point.x)
		if _span > 0.0 and radius >= BAND_IN - 0.004 and radius <= BAND_OUT + 0.004 and along >= 0.0 and along <= _span:
			# The arc's groups from the left.
			_hit = 1 + ORDER.size() + mini(floori(along / BAND_STEP), _sectors.size() - ORDER.size() - 1)
			return world
	if _petals.size() <= _ring_count: return -1.0
	# The blocks in the plane of their column, which leans over the arc (D-098).
	var column := _column_transform(_ring_count).affine_inverse()
	var column_origin := column * local_origin
	var column_direction := column.basis * local_direction
	if absf(column_direction.z) < 0.000001: return -1.0
	var along_column := -column_origin.z / column_direction.z
	if along_column < 0.0 or along_column > maximum: return -1.0
	var spot := column_origin + column_direction * along_column
	for index: int in range(_ring_count, _petals.size()):
		var offset := spot - _petals[index].center
		if absf(offset.x) <= _petals[index].size.x * 0.5 + 0.004 and absf(offset.y) <= _petals[index].size.y * 0.5 + 0.004:
			_hit = index
			return origin.distance_to(global_transform * (_column_transform(index) * spot))
	return -1.0


## The transform, in the ring, of the plane petal [param index] lies in: its column's for a block, else none.
func _column_transform(index: int) -> Transform3D:
	return _column.transform if index >= _ring_count and is_instance_valid(_column) else Transform3D.IDENTITY


## Lights what the last ray hit; on a group, shows its blocks.
func hover_hit() -> void:
	if _hit >= 1 and _hit < _ring_count: open_sector(_hit - 1)
	if _hit == _hovered: return
	var before := _hovered
	_hovered = _hit
	if before >= 0 and before < _petals.size(): _paint(before)
	if _hovered >= 0: _paint(_hovered)


## The ring doesn't scroll, and a trigger dragged on it doesn't either.
func scroll_by(_rows: float) -> bool:
	return false


func plane_height(_origin: Vector3, _direction: Vector3) -> float:
	return NAN


## The ring and its column as a sphere, for what covers it to become see-through (D-066).
func focus_sphere() -> Vector4:
	if not is_open(): return Vector4.ZERO
	var reach := BAND_OUT if _span > 0.0 else OUTER
	var bounds := AABB(Vector3(-reach, -reach, 0.0), Vector3(reach, reach, 0.0) * 2.0)
	for index: int in range(_ring_count, _petals.size()):
		var petal := _petals[index]
		var column := _column_transform(index)
		bounds = bounds.expand(column * (petal.center + Vector3(petal.size.x, petal.size.y, 0.0) * 0.5))
		bounds = bounds.expand(column * (petal.center - Vector3(petal.size.x, petal.size.y, 0.0) * 0.5))
	var middle := global_transform * bounds.get_center()
	var radius := bounds.size.length() * 0.5 * global_basis.get_scale().x
	return Vector4(middle.x, middle.y, middle.z, radius)


func close() -> void:
	super()
	_sectors = []
	_span = 0.0
	_open_sector = -1
	_ring_count = 0
	_column = null
	_fills.clear()
	_fill_colors.clear()
	_edge_colors.clear()


## The disc in the middle, with its magnifier and "Search", for [param item].
func _add_disc(item: Dictionary) -> void:
	var node := Node3D.new()
	node.name = "Search"
	add_child(node)
	var edge := _wedge_mesh(0.0, DISC, 0.0, TAU, LINE)
	node.add_child(edge)
	var fill := _wedge_mesh(0.0, DISC - EDGE, 0.0, TAU, DISC_FILL)
	fill.position.z = 0.0012
	node.add_child(fill)
	var lens := TorusMesh.new()
	lens.inner_radius = 0.0048
	lens.outer_radius = 0.0064
	lens.rings = 24
	var glass := XRERig.create_vr_mesh(lens, _under_text(XREBlueprintCanvas.material(Color("c8cdd8"), true)))
	glass.transform = Transform3D(Basis(Vector3.RIGHT, PI * 0.5), Vector3(-0.002, 0.007, 0.0018))
	node.add_child(glass)
	var bar := BoxMesh.new()
	bar.size = Vector3(0.007, 0.0016, 0.0016)
	var handle := XRERig.create_vr_mesh(bar, _under_text(XREBlueprintCanvas.material(Color("c8cdd8"), true)))
	handle.transform = Transform3D(Basis(Vector3.BACK, -PI * 0.25), Vector3(0.0045, 0.0015, 0.0018))
	node.add_child(handle)
	var title := XREBlueprintCanvas.label("Search", 14)
	title.modulate = Color("c8cdd8")
	title.position = Vector3(0.0, -0.013, 0.002)
	node.add_child(title)
	_append(item, node, Vector3.ZERO, Vector2(DISC, DISC) * 2.0, edge, fill, LINE, DISC_FILL)


## The sector of group [param index]: its name and a stripe in its cards' color on its outer edge.
func _add_sector(index: int) -> void:
	var title := str(_sectors[index]["title"])
	var enabled := not (_sectors[index]["items"] as Array).is_empty()
	var alpha := 1.0 if enabled else DIM_ALPHA
	var outer_arc: bool = _sectors[index]["outer"]
	var inner := BAND_IN if outer_arc else DISC + GAP
	var outer := BAND_OUT if outer_arc else OUTER
	var middle := (float(_sectors[index]["from"]) + float(_sectors[index]["to"])) * 0.5
	# The gap between sectors is as wide at the inner edge as at the outer.
	var from := float(_sectors[index]["from"]) + SECTOR_GAP * 0.5 / inner
	var to := float(_sectors[index]["to"]) - SECTOR_GAP * 0.5 / inner
	var node := Node3D.new()
	node.name = "Group" + title
	add_child(node)
	var edge := _wedge_mesh(inner, outer, from, to, Color(LINE, LINE.a * alpha))
	node.add_child(edge)
	var inset := EDGE / ((inner + outer) * 0.5)
	var fill := _wedge_mesh(inner + EDGE, outer - EDGE, from + inset, to - inset, Color(FILL, FILL.a * alpha))
	fill.position.z = 0.0012
	node.add_child(fill)
	var color: Color = CARD_EDGES[GROUP_CARDS[title]] if GROUP_CARDS.has(title) else FUNCTIONS_EDGE if title == "Functions" else OBJECT_EDGE
	var stripe := _wedge_mesh(outer - EDGE - 0.004, outer - EDGE, from + inset, to - inset, Color(color, 0.9 * alpha))
	stripe.position.z = 0.0016
	node.add_child(stripe)
	# A long name, as Variables, smaller rather than over the next group.
	var arc := (inner + outer) * 0.5 * (to - from)
	var label := XREBlueprintCanvas.label(title, 16 if XREBlueprintCanvas.text_width(title, 16) <= arc * 0.9 else 13)
	label.modulate = Color(Color("f3ecff"), 1.0 if enabled else 0.4)
	var at := Vector3(cos(middle), sin(middle), 0.0) * ((inner + outer) * 0.5 - 0.002)
	label.position = at + Vector3(0.0, 0.0, 0.002)
	node.add_child(label)
	_append({"text": title, "sector": index, "enabled": enabled}, node, at, Vector2.ZERO, edge, fill, Color(LINE, LINE.a * alpha), Color(FILL, FILL.a * alpha))


## A pill of block [param item] at [param center], [param width] wide, in its card's colors.
func _add_block(item: Dictionary, center: Vector3, width: float) -> void:
	var action: Dictionary = item.get("action", {})
	var group := XREBlueprintCanvas.card_group(action.get("block", {}))
	var node := Node3D.new()
	node.position = center
	_column.add_child(node)
	var frame := BoxMesh.new()
	frame.size = Vector3(width, PILL_HEIGHT, 0.002)
	var edge := XRERig.create_vr_mesh(frame, _under_text(XREBlueprintCanvas.material(CARD_EDGES[group], true)))
	node.add_child(edge)
	var quad := QuadMesh.new()
	quad.size = Vector2(width - 0.004, PILL_HEIGHT - 0.004)
	var fill_color := Color(XREBlueprintCanvas.CARD_PALETTE[group], 0.96)
	var fill := XRERig.create_vr_mesh(quad, _under_text(XREBlueprintCanvas.material(fill_color, true)))
	fill.position.z = 0.0012
	node.add_child(fill)
	var label := XREBlueprintCanvas.label(str(item["text"]), 18)
	label.modulate = Color("f3ecff")
	label.position.z = 0.0016
	node.add_child(label)
	_append(item, node, center, Vector2(width, PILL_HEIGHT), edge, fill, CARD_EDGES[group], fill_color)


func _append(item: Dictionary, node: Node3D, center: Vector3, size: Vector2, edge: MeshInstance3D, fill: MeshInstance3D, edge_color: Color, fill_color: Color) -> void:
	var petal := Petal.new()
	petal.item = item
	petal.enabled = item.get("enabled", true)
	petal.center = center
	petal.size = size
	petal.node = node
	petal.frame = edge
	_petals.append(petal)
	_fills.append(fill)
	_edge_colors.append(edge_color)
	_fill_colors.append(fill_color)


## Paints petal [param index] as it is now: the one under the ray and the
## group whose blocks are shown with a white edge and a lighter fill; a pill under the ray grows.
func _paint(index: int) -> void:
	if index < 0 or index >= _petals.size(): return
	var petal := _petals[index]
	var group := index >= 1 and index < _ring_count
	var lit := petal.enabled and (index == _hovered or (group and index - 1 == _open_sector))
	petal.frame.material_override = _surface(Color.WHITE if lit else _edge_colors[index])
	if index == 0 or group: _fills[index].material_override = _surface(FILL_HOT if lit and group else Color("3b404b") if lit else _fill_colors[index])
	else: petal.node.scale = Vector3.ONE * (1.08 if lit else 1.0)


## A surface of [param color] under the text, over everything while the ring is (D-062).
func _surface(color: Color) -> StandardMaterial3D:
	var surface := _under_text(XREBlueprintCanvas.material(color, true))
	# Seen from either side: the ring turns to the head, but its meshes are built flat.
	surface.cull_mode = BaseMaterial3D.CULL_DISABLED
	if _on_top:
		surface.no_depth_test = true
		surface.render_priority = Material.RENDER_PRIORITY_MAX
	return surface


## A flat sector of a ring between radii [param inner] and [param outer],
## angles [param from] to [param to], of [param color]; a disc from 0.
func _wedge_mesh(inner: float, outer: float, from: float, to: float, color: Color) -> MeshInstance3D:
	var steps := maxi(ceili((to - from) / 0.08), 2)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_normal(Vector3.BACK)
	for step: int in steps:
		var a := lerpf(from, to, float(step) / steps)
		var b := lerpf(from, to, float(step + 1) / steps)
		var a_in := Vector3(cos(a), sin(a), 0.0) * inner
		var b_in := Vector3(cos(b), sin(b), 0.0) * inner
		var a_out := Vector3(cos(a), sin(a), 0.0) * outer
		var b_out := Vector3(cos(b), sin(b), 0.0) * outer
		# Counterclockwise as seen from the head, in front of the plane.
		for corner: Vector3 in [a_in, a_out, b_out, a_in, b_out, b_in]: surface.add_vertex(corner)
	return XRERig.create_vr_mesh(surface.commit(), _surface(color))
