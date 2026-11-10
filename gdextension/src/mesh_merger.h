#pragma once

#include <godot_cpp/classes/array_mesh.hpp>
#include <godot_cpp/classes/material.hpp>
#include <godot_cpp/classes/mesh.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/templates/hash_map.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/packed_color_array.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>
#include <godot_cpp/variant/packed_vector3_array.hpp>

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

protected:
	static void _bind_methods();

private:
	struct Source {
		godot::PackedVector3Array vertices;
		godot::PackedVector3Array normals;
		godot::PackedInt32Array indices;
	};
	const Source *source_of(const godot::Ref<godot::Mesh> &p_mesh);

	godot::HashMap<uint64_t, Source> sources;
	godot::PackedVector3Array vertices;
	godot::PackedVector3Array normals;
	godot::PackedColorArray colors;
	godot::PackedInt32Array indices;
};

} // namespace xre
