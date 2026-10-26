@tool
class_name XREBlueprintShapes
extends RefCounted
## Signs of the archetypes ([constant XREFeatureSettings.NODE_STYLE], D-100):
## operators and math functions drawn as shapes, not cards. A circle for
## arithmetic, a diamond with rounded corners for a comparison, a pill for
## logic by its word; a math function of one or two inputs is a circle with a
## second, inner rim and its name ([constant XREFeatureSettings.NODE_SHRINK]),
## of three an oval. Inputs sit on the left of the outline, the result on the
## right. Outlines run counterclockwise in the card's plane, around its center;
## meshes are built on rebuilds, the ray is tested against the outline.

enum Shape { NONE, CIRCLE, DIAMOND, PILL, OVAL }
## Sizes in meters: a circle's radius, a diamond's half diagonal, a pill's and
## an oval's width and height, a diamond's rounding.
const CIRCLE_RADIUS := 0.036
const DIAMOND_RADIUS := 0.044
const PILL_SIZE := Vector2(0.1, 0.056)
const OVAL_SIZE := Vector2(0.11, 0.08)
const ROUNDING := 0.008
## Points on a full turn of an outline.
const SEGMENTS := 48
## Port types a math sign takes and gives: numbers, vectors, any value.
const NUMERIC: Array[int] = [XREBlueprintGraph.VALUE, XREBlueprintGraph.INTEGER, XREBlueprintGraph.NUMBER, XREBlueprintGraph.VECTOR2, XREBlueprintGraph.VECTOR3]
## Signs of math functions where a sign is more usual than the name, by function
## name: √ only where the font has it ([method word_of]); the absolute value by
## its word, as |x| is small in the headset and looks like a vector's length.
const WORDS: Dictionary[String, String] = {
	"sqrt": "√", "abs": "abs",
	"vector2_length": "|v|", "vector3_length": "|v|",
	"vector2_normalize": "norm", "vector3_normalize": "norm",
	"vector2_dot": "·", "vector3_dot": "·", "vector3_cross": "cross",
	"vector2_distance": "dist", "vector3_distance": "dist",
}
## The longest name a sign shows; longer functions stay cards.
const LONGEST := 5


## Size of [param shape], width and height.
static func size_of(shape: Shape) -> Vector2:
	match shape:
		Shape.CIRCLE: return Vector2.ONE * CIRCLE_RADIUS * 2.0
		Shape.DIAMOND: return Vector2.ONE * DIAMOND_RADIUS * 2.0
		Shape.PILL: return PILL_SIZE
		Shape.OVAL: return OVAL_SIZE
	return Vector2.ZERO


## The outline of [param shape], counterclockwise.
static func outline(shape: Shape) -> PackedVector2Array:
	var points := PackedVector2Array()
	match shape:
		Shape.CIRCLE:
			for index: int in SEGMENTS: points.append(Vector2.from_angle(TAU * index / SEGMENTS) * CIRCLE_RADIUS)
		Shape.DIAMOND:
			var corners: Array[Vector2] = [Vector2(DIAMOND_RADIUS, 0), Vector2(0, DIAMOND_RADIUS), Vector2(-DIAMOND_RADIUS, 0), Vector2(0, -DIAMOND_RADIUS)]
			for index: int in corners.size():
				var corner := corners[index]
				var before := corners[index - 1]
				var after := corners[(index + 1) % corners.size()]
				# A right angle: the arc touches each side ROUNDING from the corner.
				var center := corner + ((before - corner).normalized() + (after - corner).normalized()) * ROUNDING
				var from := (corner + (before - corner).normalized() * ROUNDING - center).angle()
				var to := (corner + (after - corner).normalized() * ROUNDING - center).angle()
				if to < from: to += TAU
				for step: int in 7: points.append(center + Vector2.from_angle(lerpf(from, to, step / 6.0)) * ROUNDING)
		Shape.PILL, Shape.OVAL: points = stadium(size_of(shape))
	return points


## A rectangle [param size] wide and high around its centre, its corners
## rounded by [param radii] — top left, top right, bottom right, bottom left
## — counterclockwise (D-106: a variable's box and its lid).
static func rounded_rect(size: Vector2, radii: Vector4) -> PackedVector2Array:
	var points := PackedVector2Array()
	var half := size * 0.5
	var corners: Array[Vector2] = [Vector2(half.x, -half.y), Vector2(half.x, half.y), Vector2(-half.x, half.y), Vector2(-half.x, -half.y)]
	var rounding: Array[float] = [radii.z, radii.y, radii.x, radii.w]
	for index: int in 4:
		var radius := minf(rounding[index], minf(half.x, half.y))
		var start := -PI * 0.5 + PI * 0.5 * index
		var center := corners[index] - Vector2(signf(corners[index].x), signf(corners[index].y)) * radius
		for step: int in 7: points.append(center + Vector2.from_angle(start + PI * 0.5 * step / 6.0) * radius)
	return points


## A pill [param size] wide and high, its ends round, counterclockwise.
static func stadium(size: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	var radius := size.y * 0.5
	var reach := maxf(size.x * 0.5 - radius, 0.0)
	for step: int in SEGMENTS / 2 + 1: points.append(Vector2(reach, 0) + Vector2.from_angle(-PI * 0.5 + PI * step / (SEGMENTS / 2)) * radius)
	for step: int in SEGMENTS / 2 + 1: points.append(Vector2(-reach, 0) + Vector2.from_angle(PI * 0.5 + PI * step / (SEGMENTS / 2)) * radius)
	return points


## Where the [param count] inputs of [param shape] are, top first.
static func inputs(shape: Shape, count: int) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var size := size_of(shape)
	match shape:
		Shape.CIRCLE:
			if count == 1: result.append(Vector2(-CIRCLE_RADIUS, 0))
			# 35° above and below the left: as far apart as two ports need, on the circle.
			else: result.assign([Vector2.from_angle(PI - deg_to_rad(35.0)) * CIRCLE_RADIUS, Vector2.from_angle(PI + deg_to_rad(35.0)) * CIRCLE_RADIUS])
		Shape.DIAMOND:
			if count == 1: result.append(Vector2(-DIAMOND_RADIUS, 0))
			else: result.assign([Vector2(-0.5, 0.5) * DIAMOND_RADIUS, Vector2(-0.5, -0.5) * DIAMOND_RADIUS])
		Shape.PILL:
			if count == 1: result.append(Vector2(-size.x * 0.5, 0))
			else: result.assign([Vector2(-size.x * 0.5 + 0.004, size.y * 0.28), Vector2(-size.x * 0.5 + 0.004, -size.y * 0.28)])
		Shape.OVAL:
			result.assign([Vector2(-size.x * 0.5 + 0.009, size.y * 0.3), Vector2(-size.x * 0.5, 0), Vector2(-size.x * 0.5 + 0.009, -size.y * 0.3)])
	return result


## Where the result of [param shape] is: the middle of its right side.
static func output(shape: Shape) -> Vector2:
	return Vector2(size_of(shape).x * 0.5, 0)


## Shared meshes of the ports' shapes by type (D-104).
static var _ports: Dictionary[int, ArrayMesh] = {}


## A flat port of [param type]'s shape, [param radius] across its middle and
## [param depth] deep, facing +Z (D-104): execution an arrow, bool a diamond,
## int a square, float a circle, text a pill, vectors a triangle, an object a
## hexagon, a colour a ring half filled, any value a ring. Made once a type.
static func port_mesh(type: int, radius: float, depth: float) -> ArrayMesh:
	if _ports.has(type): return _ports[type]
	var r := radius
	var points := PackedVector2Array()
	var hollow := false
	match type:
		XREBlueprintGraph.EXEC: points = PackedVector2Array([Vector2(-0.85 * r, -r), Vector2(0.15 * r, -r), Vector2(1.1 * r, 0), Vector2(0.15 * r, r), Vector2(-0.85 * r, r)])
		XREBlueprintGraph.BOOLEAN: points = PackedVector2Array([Vector2(1.15 * r, 0), Vector2(0, 1.15 * r), Vector2(-1.15 * r, 0), Vector2(0, -1.15 * r)])
		XREBlueprintGraph.INTEGER: points = PackedVector2Array([Vector2(0.85 * r, -0.85 * r), Vector2(0.85 * r, 0.85 * r), Vector2(-0.85 * r, 0.85 * r), Vector2(-0.85 * r, -0.85 * r)])
		XREBlueprintGraph.TEXT:
			for step: int in 13: points.append(Vector2(0.6 * r, 0) + Vector2.from_angle(-PI * 0.5 + PI * step / 12.0) * 0.7 * r)
			for step: int in 13: points.append(Vector2(-0.6 * r, 0) + Vector2.from_angle(PI * 0.5 + PI * step / 12.0) * 0.7 * r)
		XREBlueprintGraph.VECTOR2, XREBlueprintGraph.VECTOR3: points = PackedVector2Array([Vector2(0, 1.1 * r), Vector2(-1.05 * r, -0.8 * r), Vector2(1.05 * r, -0.8 * r)])
		XREBlueprintGraph.OBJECT:
			for step: int in 6: points.append(Vector2.from_angle(TAU * step / 6.0) * 1.05 * r)
		XREBlueprintGraph.VALUE, XREBlueprintGraph.COLOR:
			points = circle(r)
			hollow = true
		_: points = circle(r)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	if hollow:
		surface.append_from(ring(points, 0.0, r * 0.3, depth * 0.5), 0, Transform3D.IDENTITY)
		# A colour's ring is half filled: its left half, as a colour swatch's two tones.
		if type == XREBlueprintGraph.COLOR:
			var half := PackedVector2Array()
			for step: int in 13: half.append(Vector2.from_angle(PI * 0.5 + PI * step / 12.0) * r * 0.75)
			surface.append_from(body(half, depth), 0, Transform3D.IDENTITY)
	else: surface.append_from(body(points, depth), 0, Transform3D.IDENTITY)
	_ports[type] = surface.commit()
	return _ports[type]


## A circle of [param radius], counterclockwise: a bead's outline (D-103).
static func circle(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index: int in SEGMENTS: points.append(Vector2.from_angle(TAU * index / SEGMENTS) * radius)
	return points


## Where [param count] ports are on the left ([param side] -1) or the right
## (1) arc of a bead of [param radius], top first: from 50° above the middle
## to 50° below it, one in the middle (D-103).
static func arc(count: int, radius: float, side: float) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for index: int in count:
		var angle := 0.0 if count == 1 else deg_to_rad(50.0 - 100.0 * index / (count - 1))
		result.append(Vector2(side * cos(angle), sin(angle)) * radius)
	return result


## Whether [param point], in the card's plane, is inside [param points] ([method outline]).
static func contains(points: PackedVector2Array, point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point, points)


## A solid of [param points] [param depth] deep around z = 0: its front faces +Z.
static func body(points: PackedVector2Array, depth: float) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var triangles := Geometry2D.triangulate_polygon(points)
	for side: float in [1.0, -1.0]:
		for first: int in range(0, triangles.size(), 3):
			var a := points[triangles[first]]
			var b := points[triangles[first + 1]]
			var c := points[triangles[first + 2]]
			# Godot's front faces wind clockwise as seen from where they face: the front's seen from +Z, the back's from -Z.
			if ((b - a).cross(c - a) > 0.0) == (side > 0.0):
				var swap := b
				b = c
				c = swap
			for corner: Vector2 in [a, b, c]:
				surface.set_normal(Vector3(0, 0, side))
				surface.add_vertex(Vector3(corner.x, corner.y, side * depth * 0.5))
	for index: int in points.size():
		var a := points[index]
		var b := points[(index + 1) % points.size()]
		var normal := Vector3(b.y - a.y, a.x - b.x, 0).normalized()
		for corner: Vector3 in [Vector3(a.x, a.y, depth * 0.5), Vector3(b.x, b.y, -depth * 0.5), Vector3(a.x, a.y, -depth * 0.5),
				Vector3(a.x, a.y, depth * 0.5), Vector3(b.x, b.y, depth * 0.5), Vector3(b.x, b.y, -depth * 0.5)]:
			surface.set_normal(normal)
			surface.add_vertex(corner)
	return surface.commit()


## A flat band along [param points] at depth [param z], from [param inset]
## inside the outline to [param width] further in: a sign's rim.
static func ring(points: PackedVector2Array, inset: float, width: float, z: float) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for index: int in points.size():
		var before := points[index - 1]
		var after := points[(index + 1) % points.size()]
		var normal := Vector2(after.y - before.y, before.x - after.x).normalized()
		outer.append(points[index] - normal * inset)
		inner.append(points[index] - normal * (inset + width))
	for index: int in points.size():
		var next := (index + 1) % points.size()
		for point: Vector2 in [outer[index], inner[index], inner[next], outer[index], inner[next], outer[next]]:
			surface.set_normal(Vector3.BACK)
			surface.add_vertex(Vector3(point.x, point.y, z))
	return surface.commit()


## What a math function's sign shows (D-100): its usual sign or its name,
## empty if [param block] isn't one — a pure function of @GlobalScope's math
## or of the library's vectors with one to three numbers or vectors in and one
## out, without an icon of its own, its name at most [constant LONGEST] long.
static func word_of(block: Dictionary, inputs: Array, outputs: Array) -> String:
	if block.get("kind") != "call" or outputs.size() != 1 or inputs.is_empty() or inputs.size() > 3: return ""
	for spec: Array in inputs + outputs:
		if not int(spec[1]) in NUMERIC: return ""
	var function: Dictionary = block.get("function", {})
	var name := str(function.get("name", ""))
	var category := str(function.get("category", ""))
	var library: bool = function.get("scope") == "static" and str(function.get("class", "")) == "XREBlueprintLibrary" and category == "Vector"
	if not library and not (function.get("scope") == "global" and category.ends_with("· math")): return ""
	if XREBlueprintIcons.FUNCTIONS.has("XREBlueprintLibrary." + name): return ""
	# absf, floori: the word of abs, floor.
	if not WORDS.has(name) and (name.ends_with("f") or name.ends_with("i")) and XREBlueprintGlobals.FUNCTIONS.has(name.left(-1)): name = name.left(-1)
	var word: String = WORDS.get(name, name)
	if word == "√" and not XRERig.vr_font().has_char(0x221A): word = "sqrt"
	return word if word.length() <= LONGEST else ""
