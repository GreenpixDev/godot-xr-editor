@tool
class_name XREBlueprintFade
extends RefCounted
## What covers an input in use becomes see-through (D-066). An input — the
## number line, the choice, the globe, the arrows, the petals, the keyboard
## and the Vector and Color windows — is drawn over everything (D-058), so a
## card or a scene object nearer the head that covered it showed behind it,
## against what the two eyes see. Such an object is faded instead, and comes
## back when it no longer covers the input or the input closes.
##
## An input is a sphere: its center, its radius in [code]w[/code]. An object
## covers it when its box, grown by part of that radius, meets the line from
## the eye to just before the input: what stands behind the input, as the
## card of the token being edited, is left as it is.
##
## The graph's cards, wires and boxes are faded through their instances'
## transparency, the old one kept in a meta ([method set_faded]). A scene
## object's node is left as it is (invariant 1): only its render instance is
## faded, through the [RenderingServer], until [method restore].

## How much of a faded object is still seen.
const SEEN := 0.2
## How far the eye or an input moves before the scene's objects are tested again, in meters.
const MOVE := 0.01
## How many inputs are tested at most.
const MOST := 6

## The scene's geometry that may cover an input, gathered when an input opens.
var _nodes: Array[GeometryInstance3D] = []
## 1 for each of [member _nodes] faded now.
var _faded := PackedByteArray()
## The eye and the inputs the scene was last tested for.
var _eye := Vector3.INF
var _targets := PackedVector4Array()
var _count := 0


func _init() -> void:
	_targets.resize(MOST)


## Whether [param box] (global) covers one of the first [param count] of
## [param targets] seen from [param eye].
static func covers(eye: Vector3, targets: PackedVector4Array, count: int, box: AABB) -> bool:
	for index: int in mini(count, targets.size()):
		var target := targets[index]
		if target.w <= 0.0: continue
		var center := Vector3(target.x, target.y, target.z)
		var reach := eye.distance_to(center)
		var margin := target.w * 0.6
		if reach <= margin: continue
		var near := eye + (center - eye) * ((reach - margin) / reach)
		if box.grow(margin).intersects_segment(eye, near) != null: return true
	return false


## Fades [param node] and every geometry under it, or gives them back the
## transparency they had: the graph's own nodes, never the scene's.
static func set_faded(node: Node, faded: bool) -> void:
	var geometry := node as GeometryInstance3D
	if geometry != null:
		if faded and not geometry.has_meta(&"unfaded"):
			geometry.set_meta(&"unfaded", geometry.transparency)
			geometry.transparency = maxf(geometry.transparency, 1.0 - SEEN)
		elif not faded and geometry.has_meta(&"unfaded"):
			geometry.transparency = float(geometry.get_meta(&"unfaded"))
			geometry.remove_meta(&"unfaded")
	for child: Node in node.get_children(): set_faded(child, faded)


## Takes the visible geometry under [param root] as what may cover an input:
## once, when an input opens, not every frame.
func gather(root: Node) -> void:
	release()
	if is_instance_valid(root): _collect(root)
	_faded.resize(_nodes.size())
	_faded.fill(0)


func _collect(node: Node) -> void:
	var geometry := node as GeometryInstance3D
	if geometry != null and geometry.is_visible_in_tree() and geometry.transparency < 1.0 - SEEN: _nodes.append(geometry)
	for child: Node in node.get_children(): _collect(child)


## Fades the scene's objects that cover the first [param count] of
## [param targets] seen from [param eye], and gives the others back: tested
## again only once the eye or an input has moved.
func update(eye: Vector3, targets: PackedVector4Array, count: int) -> void:
	if _nodes.is_empty() or not _moved(eye, targets, count): return
	_eye = eye
	_count = mini(count, MOST)
	for index: int in _count: _targets[index] = targets[index]
	for index: int in _nodes.size():
		if not is_instance_valid(_nodes[index]): continue
		var node := _nodes[index]
		var faded := node.is_visible_in_tree() and covers(eye, targets, count, node.global_transform * node.get_aabb())
		if faded == (_faded[index] == 1): continue
		_faded[index] = 1 if faded else 0
		RenderingServer.instance_geometry_set_transparency(node.get_instance(), 1.0 - SEEN if faded else node.transparency)


func _moved(eye: Vector3, targets: PackedVector4Array, count: int) -> bool:
	if mini(count, MOST) != _count or eye.distance_to(_eye) > MOVE: return true
	for index: int in _count:
		var before := _targets[index]
		var now := targets[index]
		if Vector3(now.x, now.y, now.z).distance_to(Vector3(before.x, before.y, before.z)) > MOVE or absf(now.w - before.w) > MOVE: return true
	return false


## Whether scene object [param node] is faded now.
func is_faded(node: GeometryInstance3D) -> bool:
	var index := _nodes.find(node)
	return index >= 0 and _faded[index] == 1


## Gives every faded scene object back the transparency of its node.
func restore() -> void:
	for index: int in _nodes.size():
		if _faded[index] == 1 and is_instance_valid(_nodes[index]):
			RenderingServer.instance_geometry_set_transparency(_nodes[index].get_instance(), _nodes[index].transparency)
		_faded[index] = 0
	_eye = Vector3.INF
	_count = 0


## Gives the scene back and forgets it: the input closed.
func release() -> void:
	restore()
	_nodes.clear()
	_faded.clear()
