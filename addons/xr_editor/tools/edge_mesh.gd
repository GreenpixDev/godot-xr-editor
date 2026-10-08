@tool
class_name XREEdgeMesh
extends RefCounted
## The edges of a mesh that an outline draws (docs/decisions.md, D-020): the
## ones that a viewer can see as lines, found once per mesh.
##
## An edge is drawn when the two faces on it meet at a sharp angle (a box's
## edges), and when one face turns towards the viewer and the other away
## (the outline of a ball, from wherever it is looked at). The first is known
## from the mesh alone, the second only from where the viewer is, so the mesh
## made here keeps with each edge the normals of its two faces, and the
## shader of [XREOutline] picks the edges to draw every frame, in the vertex
## stage. Edges between faces in the same plane (the diagonals of a box's
## sides) are never either, and are left out.

## Edges whose faces meet at more than this angle are always drawn, in degrees.
const CREASE_ANGLE := 40.0
## Faces of one mesh beyond this many are not looked at: finding the edges
## takes a moment in GDScript, and the outline of a bigger mesh is a box.
const MAX_TRIANGLES := 10000
## Two normals at least this alike have the same plane in the eye of an edge.
const _COPLANAR := 0.9999

## Both ends of every edge, one after the other.
var points := PackedVector3Array()
## The normal of one face on each edge, once per end.
var first_normals := PackedVector3Array()
## The normal of the other face, once per end; the first one's opposite where the edge
## has only one face, so that it counts as an outline from every side.
var second_normals := PackedVector3Array()


## The edges of [param mesh] a viewer can see, or null if there are none or the
## mesh has more than [constant MAX_TRIANGLES] faces.
static func find(mesh: Mesh) -> XREEdgeMesh:
	# Every triangle of every surface of triangles, three corners each, in the order the mesh draws them.
	var faces := mesh.get_faces()
	if faces.size() > MAX_TRIANGLES * 3:
		return null

	var welded := {}
	var corners := PackedVector3Array()
	var edge_of := {}
	var ends := PackedInt32Array()
	var firsts := PackedVector3Array()
	var seconds := PackedVector3Array()
	var counts := PackedByteArray()

	# Corners at one place are one corner, whatever their normals and texture
	# coordinates: a box has four to a corner.
	var corner_of := PackedInt32Array()
	corner_of.resize(faces.size())
	for i: int in faces.size():
		var at := faces[i]
		var corner: int = welded.get(at, -1)
		if corner < 0:
			corner = corners.size()
			welded[at] = corner
			corners.append(at)
		corner_of[i] = corner

	for i: int in range(0, faces.size() - 2, 3):
		# Godot's faces run clockwise seen from the front.
		var normal := (faces[i + 2] - faces[i]).cross(faces[i + 1] - faces[i])
		if normal.length_squared() < 1.0e-20:
			continue
		normal = normal.normalized()
		for k: int in 3:
			var from := corner_of[i + k]
			var to := corner_of[i + (k + 1) % 3]
			if from == to:
				continue
			var low := mini(from, to)
			var high := maxi(from, to)
			var key := (low << 32) | high
			var edge: int = edge_of.get(key, -1)
			if edge < 0:
				edge_of[key] = ends.size() / 2
				ends.append(low)
				ends.append(high)
				firsts.append(normal)
				seconds.append(-normal)
				counts.append(1)
			elif counts[edge] == 1:
				seconds[edge] = normal
				counts[edge] = 2

	var found := XREEdgeMesh.new()
	for edge: int in counts.size():
		if counts[edge] == 2 and firsts[edge].dot(seconds[edge]) > _COPLANAR:
			continue
		for end: int in 2:
			found.points.append(corners[ends[edge * 2 + end]])
			found.first_normals.append(firsts[edge])
			found.second_normals.append(seconds[edge])
	return found if not found.points.is_empty() else null


## How many edges there are.
func get_edge_count() -> int:
	return points.size() / 2


## The edges as a mesh of lines for the shader of [XREOutline]: the vertex
## is an end of an edge, the normal is one face's, and the second face's
## normal is in the texture coordinates.
func to_mesh() -> ArrayMesh:
	var second_xy := PackedVector2Array()
	var second_z := PackedVector2Array()
	second_xy.resize(second_normals.size())
	second_z.resize(second_normals.size())
	for i: int in second_normals.size():
		second_xy[i] = Vector2(second_normals[i].x, second_normals[i].y)
		second_z[i] = Vector2(second_normals[i].z, 0.0)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	arrays[Mesh.ARRAY_NORMAL] = first_normals
	arrays[Mesh.ARRAY_TEX_UV] = second_xy
	arrays[Mesh.ARRAY_TEX_UV2] = second_z
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	return mesh
