@tool
class_name XREOutline
extends Node
## Marks a node of the edited scene in the headset by drawing its own edges
## (docs/decisions.md, D-020), only in the headset, respecting occlusion (D-026).
##
## A box around the node's bounds made objects look bigger when selected, and
## wrong for anything but a box. This draws lines along the edges of the
## node's meshes themselves: the sharp ones (a box's twelve) and, from wherever
## the user looks, the outline of the rest (a ball's). Same shape, same size.
## Each mesh of the node (a group's whole subtree) gets a "ghost", a rendering
## instance that shows the edges of the original's mesh ([XREEdgeMesh]) and
## follows its transform. Nothing is added to the edited scene. The mesh of
## the original is looked at every frame, so CSG shapes, which make a new one
## at every change, and meshes swapped from a panel are followed.
##
## Where a node has no edges to draw, a box around its bounds stands in
## ([XREBoundsBox]): a node with no geometry, a light's icon, a mesh of more
## than [constant XREEdgeMesh.MAX_TRIANGLES] faces, a group of more than
## [constant MAX_PARTS] meshes.

## Meshes of one node that get their edges drawn. A group of more than this is
## boxed instead, which bounds the work of following them every frame.
const MAX_PARTS := 32
## Edge meshes kept, by mesh: finding them takes a moment.
const MAX_CACHED := 64
## Draws after what is drawn at the same distance, as the box does.
const _RENDER_PRIORITY := 64

const _SHADER := """
shader_type spatial;
render_mode unshaded, depth_draw_never, shadows_disabled;

uniform vec4 line_color : source_color = vec4(1.0);
// Edges whose faces' normals are less alike than this are always drawn.
uniform float crease = 0.766;

void vertex() {
	// The normals of the two faces on the edge: see XREEdgeMesh.to_mesh().
	vec3 first = NORMAL;
	vec3 second = vec3(UV, UV2.x);
	vec3 eye = (inverse(MODEL_MATRIX) * INV_VIEW_MATRIX[3]).xyz;
	vec3 to_edge = VERTEX - eye;
	// One face turned towards the eye and the other away: the outline.
	bool outline = dot(first, to_edge) * dot(second, to_edge) < 0.0;
	bool sharp = dot(first, second) < crease;
	if (outline || sharp) {
		vec4 view = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
		// Half a millimeter towards the eye avoids fighting the source surface.
		// Bias in view space works with both projection/depth conventions.
		view.xyz -= normalize(view.xyz) * 0.0005;
		POSITION = PROJECTION_MATRIX * view;
	} else {
		// Outside the view: the line isn't drawn.
		POSITION = vec4(2.0, 2.0, 2.0, 1.0);
	}
}

void fragment() {
	ALBEDO = line_color.rgb;
	// Draw after opaque geometry, testing its depth without overwriting it.
	ALPHA = 1.0;
}
"""

static var _shader: Shader
## Edge meshes by the [RID] of the mesh they are of: [the mesh, its edges or null].
static var _edges_of: Dictionary = {}

## The color of the lines.
var color: Color


## One mesh of the node being marked, and its ghost.
class Part:
	var source: GeometryInstance3D
	var ghost: RID
	## The mesh [member ghost] was given the edges of: [method VisualInstance3D.get_base] of [member source].
	var base: RID
	## Whether that mesh has edges to draw.
	var has_edges := false
	## The transform the ghost has been given.
	var xform: Transform3D
	var shown := false


var _material: ShaderMaterial
var _box: XREBoundsBox
var _scenario: RID
## The node being marked with its edges, or 0.
var _node_id := 0
var _active := false
var _sources: Array[GeometryInstance3D] = []
## Ghosts made so far, the first [member _count] of them for [member _sources]. They are
## kept for the next node: rendering instances are cheap to hold and not to make.
var _parts: Array[Part] = []
var _count := 0
var _shown := 0


func _init(outline_color: Color) -> void:
	color = outline_color
	if _shader == null:
		_shader = Shader.new()
		_shader.code = _SHADER
	_material = ShaderMaterial.new()
	_material.shader = _shader
	_material.render_priority = _RENDER_PRIORITY
	_material.set_shader_parameter(&"line_color", outline_color)
	_material.set_shader_parameter(&"crease", cos(deg_to_rad(XREEdgeMesh.CREASE_ANGLE)))
	_box = XREBoundsBox.new(outline_color)
	add_child(_box)


func _enter_tree() -> void:
	_scenario = get_viewport().find_world_3d().scenario


func _exit_tree() -> void:
	clear()
	for part: Part in _parts:
		RenderingServer.free_rid(part.ghost)
	_parts.clear()
	_count = 0


## Marks [param node] by drawing its edges; call it every frame it stays marked.
## [param bounds], in the node's own space, is for the box that stands in where
## it has no edges to draw.
func show_node(node: Node3D, bounds: AABB) -> void:
	_active = true
	if node.get_instance_id() != _node_id:
		_retarget(node)
	_shown = _update_parts()
	if _shown == 0:
		_box.show_bounds(node.global_transform, bounds)
	else:
		_box.visible = false


## Marks a box of [param bounds], in the space of [param xform], and nothing else:
## for what has no edges, like the icon of a light.
func show_box(xform: Transform3D, bounds: AABB) -> void:
	_release_edges()
	_active = true
	_box.show_bounds(xform, bounds)


## Marks nothing, and forgets the node: the next one is looked at afresh.
func clear() -> void:
	if not _active:
		return
	_active = false
	_release_edges()
	_box.visible = false


## Whether anything is marked.
func is_active() -> bool:
	return _active


## How many meshes of the node have their edges drawn.
func get_part_count() -> int:
	return _shown


## Whether a box marks the node, and not its edges.
func is_boxed() -> bool:
	return _box.visible


## The box that stands in for edges, to read its transform.
func get_box() -> XREBoundsBox:
	return _box


func _release_edges() -> void:
	for i: int in _count:
		_hide(_parts[i])
	_node_id = 0
	_count = 0
	_shown = 0
	_sources.clear()


func _retarget(node: Node3D) -> void:
	_release_edges()
	_node_id = node.get_instance_id()
	_collect(node)
	if _sources.size() > MAX_PARTS:
		_sources.clear()
	while _parts.size() < _sources.size():
		_parts.append(_make_part())
	_count = _sources.size()
	for i: int in _count:
		var part := _parts[i]
		part.source = _sources[i]
		# A part used for another node has the edges of that node's mesh.
		part.base = RID()
		part.has_edges = false


## Gathers into [member _sources] the geometry of [param node] and everything
## under it, hidden or not: whether it shows is decided every frame, so that a
## node shown or hidden from a panel is followed.
func _collect(node: Node) -> void:
	var geometry := node as GeometryInstance3D
	if geometry != null and _has_mesh(geometry):
		_sources.append(geometry)
		if _sources.size() > MAX_PARTS:
			return
	for child: Node in node.get_children():
		_collect(child)
		if _sources.size() > MAX_PARTS:
			return


## Whether [param geometry] is drawn from a mesh whose edges can be found: a
## [MeshInstance3D], or a CSG shape that isn't inside another, which has the
## mesh of the whole.
static func _has_mesh(geometry: GeometryInstance3D) -> bool:
	if geometry is MeshInstance3D:
		return true
	var csg := geometry as CSGShape3D
	return csg != null and csg.is_root_shape()


static func _mesh_of(source: GeometryInstance3D) -> Mesh:
	var instance := source as MeshInstance3D
	if instance != null:
		return instance.mesh
	var csg := source as CSGShape3D
	if csg != null:
		var meshes := csg.get_meshes()
		if meshes.size() == 2:
			return meshes[1] as Mesh
	return null


## The edges of the mesh [param source] is drawn from, as lines, or null if
## it has none to draw. Found once for each mesh.
static func _lines_of(source: GeometryInstance3D) -> ArrayMesh:
	var mesh := _mesh_of(source)
	if mesh == null:
		return null
	var key := mesh.get_rid()
	if _edges_of.has(key):
		return (_edges_of[key] as Array)[1] as ArrayMesh
	if _edges_of.size() >= MAX_CACHED:
		_edges_of.clear()
	var edges := XREEdgeMesh.find(mesh)
	var lines: ArrayMesh = edges.to_mesh() if edges != null else null
	# The mesh is kept with its edges: as long as it is, no other has its RID.
	_edges_of[key] = [mesh, lines]
	return lines


func _make_part() -> Part:
	var part := Part.new()
	part.ghost = RenderingServer.instance_create()
	RenderingServer.instance_set_scenario(part.ghost, _scenario)
	RenderingServer.instance_set_layer_mask(part.ghost, XRERig.VR_LAYER)
	# Shadows are culled by the light, not the camera: a shadow cast from the VR
	# layer would show in the desktop viewport.
	RenderingServer.instance_geometry_set_cast_shadows_setting(part.ghost, RenderingServer.SHADOW_CASTING_SETTING_OFF)
	RenderingServer.instance_geometry_set_material_override(part.ghost, _material.get_rid())
	RenderingServer.instance_set_visible(part.ghost, false)
	return part


## Brings the ghosts up to date with their originals, and returns how many show.
func _update_parts() -> int:
	var shown := 0
	for i: int in _count:
		var part := _parts[i]
		var source := part.source
		var base := RID()
		if is_instance_valid(source) and source.is_visible_in_tree():
			base = source.get_base()
		# A CSG shape has no mesh until the frame after it is made or changed.
		if not base.is_valid():
			_hide(part)
			continue
		if base != part.base:
			part.base = base
			var lines := _lines_of(source)
			part.has_edges = lines != null
			if part.has_edges:
				RenderingServer.instance_set_base(part.ghost, lines.get_rid())
		if not part.has_edges:
			_hide(part)
			continue
		var xform := source.global_transform
		if not part.shown or xform != part.xform:
			part.xform = xform
			RenderingServer.instance_set_transform(part.ghost, xform)
		if not part.shown:
			part.shown = true
			RenderingServer.instance_set_visible(part.ghost, true)
		shown += 1
	return shown


func _hide(part: Part) -> void:
	if part.shown:
		part.shown = false
		RenderingServer.instance_set_visible(part.ghost, false)
