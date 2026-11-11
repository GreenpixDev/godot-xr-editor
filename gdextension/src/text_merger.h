#pragma once

#include <godot_cpp/classes/array_mesh.hpp>
#include <godot_cpp/classes/label3d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/standard_material3d.hpp>
#include <godot_cpp/templates/hash_map.hpp>
#include <godot_cpp/templates/local_vector.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/packed_color_array.hpp>
#include <godot_cpp/variant/packed_float32_array.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>
#include <godot_cpp/variant/packed_vector2_array.hpp>
#include <godot_cpp/variant/packed_vector3_array.hpp>
#include <godot_cpp/variant/rid.hpp>
#include <godot_cpp/variant/transform3d.hpp>

#include <cstdint>

namespace xre {

/// Graph text Merged (D-171): a card's labels as one mesh. Lays each Label3D's text out as Label3D::_shape and
/// _generate_glyph_surfaces do in Godot 4.7.2 (TextServer shaped text, its line breaks, its glyphs' offsets, sizes
/// and UV rectangles in the font's atlas, the outline first), places the glyphs' quads by the label's transform in
/// the card's space, its colour (times how much of it is seen) in the vertices, and appends them to one surface for
/// each atlas page, priority, outline and depth test: a material as Label3D's own, made once and shared. Only the
/// labels Label3D draws flat and unlit (no billboard, no fixed size, alpha cut off) are meant for it.
class XRETextMerger : public godot::RefCounted {
	GDCLASS(XRETextMerger, godot::RefCounted);

public:
	~XRETextMerger();
	/// Rebuilds [param p_target] from the first [param p_count] labels of [param p_labels], each placed by the
	/// Transform3D in [param p_places] and seen [param p_seen] (1 for all of it). Returns the number of surfaces.
	int merge(const godot::Ref<godot::ArrayMesh> &p_target, const godot::Array &p_labels, const godot::Array &p_places,
			const godot::PackedFloat32Array &p_seen, int p_count);
	/// The render priority of surface [param p_surface] of the last merge, for its sorting.
	int get_surface_priority(int p_surface) const;
	/// Forgets the materials made: their atlas pages may be gone.
	void clear_cache();

protected:
	static void _bind_methods();

private:
	struct Key {
		uint64_t texture = 0;
		int32_t priority = 0;
		int32_t outline = 0;
		bool no_depth = false;
		bool double_sided = true;
		bool operator==(const Key &p_other) const {
			return texture == p_other.texture && priority == p_other.priority && outline == p_other.outline && no_depth == p_other.no_depth && double_sided == p_other.double_sided;
		}
	};
	struct KeyHasher {
		static uint32_t hash(const Key &p_key);
	};
	struct Surface {
		Key key;
		godot::RID texture;
		godot::Vector2 texture_size;
		int64_t pixel_range = 0;
		godot::PackedVector3Array vertices;
		godot::PackedVector3Array normals;
		godot::PackedColorArray colors;
		godot::PackedVector2Array uvs;
		godot::PackedInt32Array indices;
		int quads = 0;
	};

	void lay(const godot::Label3D *p_label, const godot::Transform3D &p_place, double p_seen);
	void glyph(const godot::Dictionary &p_glyph, godot::Vector2 &r_offset, const godot::Color &p_color, int p_priority, int p_outline,
			const godot::Label3D *p_label, const godot::Transform3D &p_place);
	godot::Ref<godot::StandardMaterial3D> material_of(const Surface &p_surface);

	godot::LocalVector<Surface> surfaces;
	godot::HashMap<Key, int, KeyHasher> surface_of;
	godot::HashMap<Key, godot::Ref<godot::StandardMaterial3D>, KeyHasher> materials;
	godot::LocalVector<int> priorities;
	godot::RID shaped;
};

} // namespace xre
