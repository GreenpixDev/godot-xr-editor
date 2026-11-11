#pragma once

#include <godot_cpp/classes/array_mesh.hpp>
#include <godot_cpp/classes/material.hpp>
#include <godot_cpp/classes/mesh.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/templates/hash_map.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/packed_color_array.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>
#include <godot_cpp/variant/packed_vector3_array.hpp>
#include <godot_cpp/variant/string_name.hpp>

namespace xre {

/// Merges a card's parts into one mesh (Graph drawing Merged, D-168): each part's first surface, placed by its
/// transform in the card's space and painted its colour in the vertices, appended to one surface. In C++
/// because a card's ports alone are thousands of vertices and a hover re-merges its card.
class XREMeshMerger : public godot::RefCounted {
	GDCLASS(XREMeshMerger, godot::RefCounted);

public:
	/// Rebuilds [param p_target] from the first [param p_count] of [param p_meshes] (Mesh), each placed by the
	/// Transform3D in [param p_transforms] and coloured [param p_colors]; one surface of [param p_material], or
	/// none when nothing is left. Returns its vertex count.
	int merge(const godot::Ref<godot::ArrayMesh> &p_target, const godot::Array &p_meshes, const godot::Array &p_transforms,
			const godot::PackedColorArray &p_colors, int p_count, const godot::Ref<godot::Material> &p_material);
	/// Forgets the parts' vertex data kept since the last call: after a rebuild of the graph.
	void clear_cache();
	/// A number that changes whenever anything a merge draws from changes under [param p_card] (D-170): which
	/// nodes are shown, their places, meshes, materials (and the materials' colours, priority, depth test),
	/// transparency and sorting; with [param p_labels], also its labels' text, font, colours and sizes. Merged
	/// meshes (meta [code]merged[/code]) are left out. For a check each frame: allocates nothing.
	int64_t card_state(godot::Node *p_card, bool p_labels);

protected:
	static void _bind_methods();

private:
	struct Source {
		godot::PackedVector3Array vertices;
		godot::PackedVector3Array normals;
		godot::PackedInt32Array indices;
	};
	const Source *source_of(const godot::Ref<godot::Mesh> &p_mesh);
	void state_of(godot::Node *p_node, bool p_labels, uint64_t &r_hash);
	godot::StringName merged_name = "merged";
	godot::StringName tint_name = "tint";
	godot::StringName face_tint_name = "face_tint";
	godot::StringName grow_name = "grow";

	godot::HashMap<uint64_t, Source> sources;
	godot::PackedVector3Array vertices;
	godot::PackedVector3Array normals;
	godot::PackedColorArray colors;
	godot::PackedInt32Array indices;
};

} // namespace xre
