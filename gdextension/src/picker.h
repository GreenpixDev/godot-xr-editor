#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/aabb.hpp>
#include <godot_cpp/variant/rid.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/variant/variant.hpp>
#include <godot_cpp/variant/vector3.hpp>

#include <cstdint>

namespace godot {
class GeometryInstance3D;
class Node;
class Node3D;
} // namespace godot

namespace xre {

/// Finds the node of the edited scene that a controller points at or touches.
///
/// The desktop editor picks only nodes that have a gizmo, and drops assets
/// only onto collision shapes (docs/vr_feature_map.md). This picks visible
/// geometry instead. Candidates come from the renderer's own BVH of the
/// scenario (RenderingServer.instances_cull_ray and instances_cull_aabb),
/// which always matches what the headset shows. A MeshInstance3D is then
/// tested against its triangles (the mesh caches its TriangleMesh, and the
/// editor's selection gizmo has usually built it already); any other geometry
/// (CSG, sprites, labels, multimeshes) is tested against its bounding box. Particles are never picked: their box
/// is a visibility volume, not their shape. Lights and other non-geometry
/// nodes are left to handles.
///
/// A hit is resolved to the node the desktop editor would select for it
/// (Node3DEditorViewport::_select_ray and _select_clicked in 4.7.2): a node
/// inside an instanced scene gives way to the instance root unless that
/// instance has editable children, the outermost ancestor with "_edit_group_"
/// metadata stands for everything under it, and a node with "_edit_lock_"
/// metadata can't be picked.
///
/// Called every frame for every controller, so it allocates nothing itself;
/// the engine queries it relies on return newly allocated containers (the
/// candidate list, a Dictionary per triangle test), see docs/decisions.md, D-007.
/// Main thread only (the editor always renders on the main thread).
class XREPicker : public godot::RefCounted {
	GDCLASS(XREPicker, godot::RefCounted);

public:
	XREPicker();

	/// The rendering scenario to search: World3D.scenario of the edited scene's world.
	void set_scenario(const godot::RID &p_scenario);
	godot::RID get_scenario() const;

	/// Render layers of what the scenario holds beside the scene: geometry on
	/// these layers alone is passed over before anything dearer is asked of it.
	/// 0, the default, passes over nothing.
	void set_skipped_layers(uint32_t p_layers);
	uint32_t get_skipped_layers() const;

	/// Finds the closest geometry of p_scene_root's scene that the segment from
	/// p_from to p_to hits. Returns whether there is a hit; the getters describe it.
	bool cast_segment(godot::Node *p_scene_root, const godot::Vector3 &p_from, const godot::Vector3 &p_to);
	/// Finds geometry of p_scene_root's scene whose bounding box is no farther
	/// than p_radius from p_point. Of several, the smallest box wins: a hand in
	/// a cup on a table means the cup. Geometry whose box holds p_viewer (the
	/// head) is skipped: the user is inside it, and a room is not something to
	/// take in hand. Returns whether there is a hit; the hit position is
	/// p_point and the normal is zero.
	bool find_at_point(godot::Node *p_scene_root, const godot::Vector3 &p_point, double p_radius, const godot::Vector3 &p_viewer);

	/// The node to select for the last hit, or null if there was none or it was freed since.
	godot::Node3D *get_hit_node() const;
	godot::Vector3 get_hit_position() const;
	/// Surface normal at the hit, in world space, on the side the ray came
	/// from; zero for find_at_point().
	godot::Vector3 get_hit_normal() const;
	/// From the start of the segment, or from the point, to the hit.
	double get_hit_distance() const;

	/// The node to select for p_node, by the same rules as for a hit on its
	/// geometry: its instance root, outermost group or owned ancestor. Null if
	/// that node is locked or p_node is not in p_scene_root's scene. For icons
	/// and handles of nodes without geometry, like lights.
	godot::Node3D *get_selectable_node(godot::Node *p_node, godot::Node *p_scene_root) const;

	/// Bounding box of the pickable geometry under p_node (p_node included), in
	/// p_node's own space. A node without any is given a 10 cm box around its origin.
	static godot::AABB get_local_bounds(godot::Node3D *p_node);

protected:
	static void _bind_methods();

private:
	godot::RID scenario;
	uint32_t skipped_layers = 0;
	uint64_t hit_node_id = 0;
	godot::Vector3 hit_position;
	godot::Vector3 hit_normal;
	double hit_distance = 0.0;

	// Built once: per-frame code must not allocate.
	godot::StringName edit_group_name;
	godot::StringName edit_lock_name;
	godot::Variant position_key;
	godot::Variant normal_key;

	void clear_hit();
	void set_hit(godot::Node3D *p_node, const godot::Vector3 &p_position, const godot::Vector3 &p_normal, double p_distance);
	bool is_candidate(godot::GeometryInstance3D *p_geometry, godot::Node *p_scene_root) const;
	bool intersect_segment(godot::GeometryInstance3D *p_geometry, const godot::Vector3 &p_from, const godot::Vector3 &p_to, godot::Vector3 &r_position, godot::Vector3 &r_normal) const;
	godot::Node3D *resolve(godot::Node *p_node, godot::Node *p_scene_root) const;
	bool is_locked(const godot::Node *p_node) const;
};

} // namespace xre
