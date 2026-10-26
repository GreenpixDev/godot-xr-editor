@tool
class_name XREBlueprintPetals
extends Node3D
## A fan of petals: the members of a scene object — properties, signals,
## animations, sound players — that a wire picks (D-052). The fan grows from a
## white dot on the object, on the side that faces the user; a white stem
## joins the dot to the fan's purple spine, and the petals are pills along it.
## Nodes without geometry under the object — an AnimationPlayer, a sound —
## are groups of their own, under a header with their name. A petal that
## doesn't fit the wire is dim. A long list scrolls: the right thumbstick, a
## trigger dragged up or down along it, or its "▲ / ▼ more" petals. It scrolls
## smoothly (D-067): the rows slide by parts of a row, the one leaving at the
## top fading out and the one coming at the bottom fading in. Built when the
## object, the wire or the first row changes, never per frame; between, the
## rows only move. Picked analytically.
## It turns to the head and keeps its size in view farther than
## [constant FULL_SIZE_DISTANCE] away, as the badge does ([method follow]).

## Petal height, the step between petals and how far the fan stands from its dot, in meters.
const PILL_HEIGHT := 0.03
const STEP := 0.044
const OFFSET := 0.16
## Rows shown at once; the rest scrolls.
const PAGE := 10
const PILL_COLOR := Color("1e1630")
const PILL_HOT := Color("5a4384")
const BORDER := Color("b991eb")
const DIM := 0.6
## Up to this distance from the head the fan has its own size; farther it grows, to at most [constant MAX_GROWTH].
const FULL_SIZE_DISTANCE := 0.7
const MAX_GROWTH := 2.5

class Petal:
	var node: Node3D
	var center := Vector3.ZERO
	var size := Vector2.ZERO
	var item: Dictionary
	var enabled := true
	var frame: MeshInstance3D
	## Its row among the items shown (0 the first), or -1 for a "more" petal, which stays put.
	var row := -1
	## How much of it is seen, while it slides in or out (D-067): under half, the ray passes it.
	var seen := 1.0

var _petals: Array[Petal] = []
var _groups: Array[Dictionary] = []
var _anchor := Vector3.ZERO
var _head := Vector3.ZERO
var _up := Vector3.UP
## The first row shown of the whole list, headers counted, and where the list
## is scrolled to, in rows: its whole part is [member _first], the rest how far
## the rows have slid up (D-067).
var _first := 0
var _position := 0.0
## The headers shown, and their rows among the items shown.
var _headers: Array[Label3D] = []
var _header_rows := PackedInt32Array()
## Room for the "▲ more" petal above the items, in rows: 1 for a list that scrolls.
var _lead := 0.0
var _items: Array[Dictionary] = []
var _hit := -1
var _hovered := -1
var _object: Node3D
var _on_top := false
## Where on top it sorts ([method set_on_top]): at the cards' Front focus
## (D-075), or, for the block menu's fan and ring, over it (D-096).
var top_sorting := 100.0
## The widest petal shown: the column the ray is on the fan within.
var _widest := 0.0
var _stem: MeshInstance3D
var _dot: MeshInstance3D
var _spine_middle := Vector3.ZERO


func _init() -> void:
	name = "Petals"
	top_level = true
	visible = false


## Opens the fan at [param anchor] (global) of [param object], facing
## [param head] upright along [param up]. [param groups] are
## [code]{"header", "items"}[/code], an item [code]{"text", "member",
## "node", "kind", "enabled"}[/code]; a header may be empty.
func open(object: Node3D, anchor: Vector3, head: Vector3, up: Vector3, groups: Array[Dictionary]) -> void:
	_object = object
	_anchor = anchor
	_head = head
	_up = up.normalized()
	_groups = groups
	_first = 0
	_position = 0.0
	_items.clear()
	for group: Dictionary in _groups:
		var listed: Array = group["items"]
		if listed.is_empty(): continue
		if not str(group.get("header", "")).is_empty(): _items.append({"header": group["header"]})
		for item: Dictionary in listed: _items.append(item)
	_build()
	follow(_head)


## Turns the fan to [param head] around its object and scales it to keep its
## size in view; its stem follows. Only transforms: cheap enough for every frame.
func follow(head: Vector3) -> void:
	if not is_open(): return
	_head = head
	var toward := _head - _anchor
	toward -= _up * toward.dot(_up)
	if toward.length() < 0.01: toward = Vector3.BACK
	toward = toward.normalized()
	var side := _up.cross(toward).normalized()
	var growth := clampf(_anchor.distance_to(_head) / FULL_SIZE_DISTANCE, 1.0, MAX_GROWTH)
	var center := _anchor + (toward * OFFSET + side * OFFSET + _up * (STEP * (mini(_items.size(), PAGE + 1) - 1) * 0.5)) * growth
	global_transform = Transform3D(face(center, _head, _up) * Basis.from_scale(Vector3.ONE * growth), center)
	var anchor := to_local(_anchor)
	_dot.position = anchor
	var along := _spine_middle - anchor
	_stem.transform = Transform3D(Basis(Quaternion(Vector3.UP, along.normalized())) * Basis.from_scale(Vector3(1.0, maxf(along.length(), 0.001), 1.0)), anchor + along * 0.5)


## The fan as a sphere, its radius in [code]w[/code], for what covers it to
## become see-through (D-066); a zero radius while it is closed.
func focus_sphere() -> Vector4:
	if not is_open() or _petals.is_empty(): return Vector4.ZERO
	var top := _petals[0].center.y + STEP * 0.5
	var bottom := _petals[_petals.size() - 1].center.y - STEP * 0.5
	var middle := global_transform * Vector3(_widest * 0.5, (top + bottom) * 0.5, 0.0)
	var radius := Vector2(_widest, top - bottom).length() * 0.5 * global_basis.get_scale().x
	return Vector4(middle.x, middle.y, middle.z, radius)


## Draws the fan over everything (D-061), while a member is picked in focus.
func set_on_top(enabled: bool) -> void:
	if enabled == _on_top: return
	_on_top = enabled
	_raise(self, enabled)


## Over everything (D-062): a petal's edge and fill come up from under the
## cards' priority to theirs, sorted at [member top_sorting] and before their text.
func _raise(node: Node, enabled: bool) -> void:
	for child: Node in node.get_children():
		if child is Label3D:
			(child as Label3D).no_depth_test = enabled
			(child as Label3D).sorting_offset = top_sorting + 1.0 if enabled else 0.0
		elif child is MeshInstance3D:
			(child as MeshInstance3D).sorting_offset = top_sorting if enabled else 0.0
			var material := (child as MeshInstance3D).material_override as BaseMaterial3D
			if material != null:
				material.no_depth_test = enabled
				if material.has_meta(&"under_text"): material.render_priority = Material.RENDER_PRIORITY_MAX if enabled else Material.RENDER_PRIORITY_MAX - 1
		_raise(child, enabled)


## Closes the fan.
func close() -> void:
	_clear()
	_object = null
	_groups = []
	visible = false


## Whether the fan is open.
func is_open() -> bool:
	return visible and _object != null


## The object the fan is open at, or null.
func get_object() -> Node3D:
	return _object if is_open() else null


## Where the fan grows from on its object, global.
func get_anchor() -> Vector3:
	return _anchor


## How many items the fan shows on all its pages.
func get_item_count() -> int:
	var count := 0
	for group: Dictionary in _groups: count += (group["items"] as Array).size()
	return count


## The items on the page shown, in order: more than half seen.
func get_shown() -> Array[Dictionary]:
	var shown: Array[Dictionary] = []
	for petal: Petal in _petals:
		if petal.seen >= 0.5: shown.append(petal.item)
	return shown


func _clear() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_petals.clear()
	_headers.clear()
	_header_rows.clear()
	_stem = null
	_dot = null
	_hit = -1
	_hovered = -1


func _build() -> void:
	_clear()
	if _object == null:
		visible = false
		return
	var last := maxi(_items.size() - PAGE, 0)
	_position = clampf(_position, 0.0, float(last))
	_first = floori(_position)
	_lead = 1.0 if last > 0 else 0.0
	_widest = 0.0
	var top := -_lead * STEP
	if _position > 0.0:
		_add_petal({"text": "▲ %d more" % ceili(_position), "scroll": -(PAGE - 2), "enabled": true}, -1, 0.0)
		top = 0.0
	# A row more than a page: the one sliding in at the bottom (D-067).
	var rows := mini(PAGE + 1, _items.size() - _first)
	for index: int in rows:
		var item: Dictionary = _items[_first + index]
		if not item.has("header"):
			_add_petal(item, index, 0.0)
			continue
		var header := XREBlueprintCanvas.label(str(item["header"]), 16)
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		header.modulate = Color("a7afc1")
		add_child(header)
		_headers.append(header)
		_header_rows.append(index)
	var bottom := -(_lead + mini(PAGE, _items.size()) - 1) * STEP
	var below := ceili(float(_items.size()) - _position - PAGE)
	if below > 0:
		bottom = -(_lead + PAGE + 0.5) * STEP
		_add_petal({"text": "▼ %d more" % below, "scroll": PAGE - 2, "enabled": true}, -1, bottom)
	if _petals.is_empty():
		visible = false
		return
	_place()
	var spine_top := Vector3(-0.012, top, 0)
	var spine_bottom := Vector3(-0.012, bottom, 0)
	add_child(_stick(spine_top, spine_bottom, BORDER, 0.002))
	_spine_middle = (spine_top + spine_bottom) * 0.5
	# The stem is a rod of unit length that follow() stretches from the dot to the spine.
	_stem = _stick(Vector3.ZERO, Vector3.UP, Color.WHITE, 0.0025)
	add_child(_stem)
	var dot := SphereMesh.new()
	dot.radius = 0.008
	dot.height = 0.016
	_dot = XRERig.create_vr_mesh(dot, XREBlueprintCanvas.material(Color.WHITE, true))
	add_child(_dot)
	visible = true
	if _on_top: _raise(self, true)
	if not _head.is_zero_approx() and is_inside_tree(): follow(_head)


## A petal of [param item] in row [param row] of the items shown, or, with -1,
## a "more" petal that stays at height [param y].
func _add_petal(item: Dictionary, row: int, y: float) -> void:
	var text := str(item["text"])
	var width := XREBlueprintCanvas.text_width(text, 18) + 0.03
	_widest = maxf(_widest, width)
	var petal := Petal.new()
	petal.item = item
	petal.row = row
	petal.enabled = item.get("enabled", true)
	petal.center = Vector3(width * 0.5, y, 0)
	petal.size = Vector2(width, PILL_HEIGHT)
	petal.node = Node3D.new()
	petal.node.position = petal.center
	add_child(petal.node)
	var pill := make_pill(text, 1.0 if petal.enabled else DIM)
	petal.frame = pill.get_meta(&"frame") as MeshInstance3D
	petal.node.add_child(pill)
	_petals.append(petal)


## Slides the rows to where the list is scrolled (D-067): up by the part of a
## row past [member _first], the first row fading out as it goes, the row
## under the page fading in. Only positions and transparency: no rebuild.
func _place() -> void:
	var slide := _position - _first
	for petal: Petal in _petals:
		if petal.row < 0: continue
		petal.center.y = -(_lead + petal.row - slide) * STEP
		petal.node.position = petal.center
		petal.seen = _row_seen(petal.row, slide)
		_fade(petal.node, petal.seen)
	for index: int in _headers.size():
		var row := _header_rows[index]
		_headers[index].position = Vector3(0, -(_lead + row - slide) * STEP, 0)
		_fade(_headers[index], _row_seen(row, slide))


## How much of row [param row] is seen with the rows slid by [param slide].
static func _row_seen(row: int, slide: float) -> float:
	if row == 0: return 1.0 - slide
	if row >= PAGE: return slide
	return 1.0


static func _fade(node: Node, seen: float) -> void:
	if node is GeometryInstance3D: (node as GeometryInstance3D).transparency = 1.0 - seen
	for child: Node in node.get_children(): _fade(child, seen)


## A basis at [param center] square to the line of sight from [param head],
## tilted toward it too, with its rows level ([param up] across them): seen
## from above, petals one under another don't run into each other.
static func face(center: Vector3, head: Vector3, up: Vector3) -> Basis:
	var z := head - center
	if z.length() < 0.001: return XREPanels.facing(center, head, up)
	z = z.normalized()
	var x := up.cross(z)
	if x.length() < 0.001: return XREPanels.facing(center, head, up)
	x = x.normalized()
	return Basis(x, z.cross(x), z)


## A petal [param text] shows, [param alpha] opaque: a purple-edged pill. Its
## width is its "width" metadata, its edge its "frame". Its edge and fill are
## drawn before its text (a lower render priority): sorted by depth alone, the
## fill could come out over the text and dim it from some angles.
static func make_pill(text: String, alpha: float = 1.0) -> Node3D:
	var pill := Node3D.new()
	var width := XREBlueprintCanvas.text_width(text, 18) + 0.03
	var frame := BoxMesh.new()
	frame.size = Vector3(width, PILL_HEIGHT, 0.002)
	var edge := XRERig.create_vr_mesh(frame, _under_text(XREBlueprintCanvas.material(Color(BORDER, alpha), true)))
	pill.add_child(edge)
	var fill := QuadMesh.new()
	fill.size = Vector2(width - 0.004, PILL_HEIGHT - 0.004)
	var fill_mesh := XRERig.create_vr_mesh(fill, _under_text(XREBlueprintCanvas.material(Color(PILL_COLOR, 0.92 * alpha), true)))
	fill_mesh.position.z = 0.0012
	pill.add_child(fill_mesh)
	var label := XREBlueprintCanvas.label(text, 18)
	label.modulate = Color(Color("f3ecff"), alpha)
	label.position.z = 0.0016
	pill.add_child(label)
	pill.set_meta(&"width", width)
	pill.set_meta(&"frame", edge)
	return pill


static func _under_text(material: StandardMaterial3D) -> StandardMaterial3D:
	material.render_priority = Material.RENDER_PRIORITY_MAX - 1
	material.set_meta(&"under_text", true)
	return material


## A thin rod from [param from] to [param to], local.
static func _stick(from: Vector3, to: Vector3, color: Color, radius: float) -> MeshInstance3D:
	var rod := CylinderMesh.new()
	rod.top_radius = radius
	rod.bottom_radius = radius
	rod.height = maxf(from.distance_to(to), 0.001)
	rod.radial_segments = 8
	var mesh := XRERig.create_vr_mesh(rod, XREBlueprintCanvas.material(color, true))
	var along := (to - from).normalized() if not from.is_equal_approx(to) else Vector3.UP
	var axis := Vector3.UP.cross(along)
	var basis := Basis(axis.normalized(), Vector3.UP.angle_to(along)) if axis.length() > 0.0001 else Basis.IDENTITY
	mesh.transform = Transform3D(basis, (from + to) * 0.5)
	return mesh


## Distance to the petal the ray hits, or -1; the item is [method get_hit].
func intersect_ray(origin: Vector3, direction: Vector3, maximum: float) -> float:
	_hit = -1
	if not is_open(): return -1.0
	var inverse := global_transform.affine_inverse()
	var local_origin := inverse * origin
	var local_direction := inverse.basis * direction
	if absf(local_direction.z) < 0.000001: return -1.0
	var distance := -local_origin.z / local_direction.z
	if distance < 0.0 or distance > maximum: return -1.0
	var point := local_origin + local_direction * distance
	var world := origin.distance_to(global_transform * point)
	for index: int in _petals.size():
		var petal := _petals[index]
		if petal.seen < 0.5: continue
		var offset := point - petal.center
		if absf(offset.x) <= petal.size.x * 0.5 + 0.004 and absf(offset.y) <= petal.size.y * 0.5 + 0.004:
			_hit = index
			return world
	# Between petals the ray is still on the fan (D-062): the nearest row takes
	# it, so that the list scrolls and lights wherever the ray is on its column.
	if _petals.is_empty() or point.x < -0.03 or point.x > _widest + 0.01: return -1.0
	var top := _petals[0].center.y + STEP * 0.5
	var bottom := _petals[_petals.size() - 1].center.y - STEP * 0.5
	if point.y > top or point.y < bottom: return -1.0
	var nearest := INF
	for index: int in _petals.size():
		if _petals[index].seen < 0.5: continue
		var gap := absf(point.y - _petals[index].center.y)
		if gap < nearest:
			nearest = gap
			_hit = index
	return world


## Where the petal of [param item] is, global; the fan's own place without one.
func item_position(item: Dictionary) -> Vector3:
	for petal: Petal in _petals:
		if petal.item == item: return global_transform * petal.center
	return global_position


## The item of the petal the last ray hit, or empty.
func get_hit() -> Dictionary:
	return _petals[_hit].item if _hit >= 0 else {}


## Lights the petal the last ray hit, or none.
func hover_hit() -> void:
	if _hit == _hovered: return
	_hovered = _hit
	for index: int in _petals.size():
		var petal := _petals[index]
		var alpha := 1.0 if petal.enabled else DIM
		var edge := _under_text(XREBlueprintCanvas.material(Color(Color.WHITE if index == _hovered else BORDER, alpha), true))
		# Over everything as the rest of the fan in focus (D-063): a new edge came out under the cards.
		if _on_top:
			edge.no_depth_test = true
			edge.render_priority = Material.RENDER_PRIORITY_MAX
		petal.frame.material_override = edge
		petal.node.scale = Vector3.ONE * (1.08 if index == _hovered else 1.0)


## Scrolls the list by [param rows] rows, down for positive; false at its end.
func scroll(rows: int) -> bool:
	return scroll_by(rows)


## Scrolls the list smoothly by [param rows], parts of a row too, down for
## positive; false at its end (D-067). The rows slide; the fan is built anew
## only when another row comes first, or a "more" petal comes or goes.
func scroll_by(rows: float) -> bool:
	var last := float(maxi(_items.size() - PAGE, 0))
	var position := clampf(_position + rows, 0.0, last)
	if is_equal_approx(position, _position): return false
	var rebuild := floori(position) != _first or (position > 0.0) != (_position > 0.0) or (position < last) != (_position < last)
	_position = position
	if rebuild: _build()
	else: _place()
	return true


## Where the list is scrolled to, in rows (D-067).
func get_scroll() -> float:
	return _position


## Where the ray meets the fan's plane, up along it in meters; NAN off it.
func plane_height(origin: Vector3, direction: Vector3) -> float:
	if not is_open(): return NAN
	var inverse := global_transform.affine_inverse()
	var local_origin := inverse * origin
	var local_direction := inverse.basis * direction
	if absf(local_direction.z) < 0.000001: return NAN
	var distance := -local_origin.z / local_direction.z
	return (local_origin + local_direction * distance).y if distance >= 0.0 else NAN
