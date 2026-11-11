#include "mesh_merger.h"

#include <godot_cpp/classes/base_material3d.hpp>
#include <godot_cpp/classes/font.hpp>
#include <godot_cpp/classes/geometry_instance3d.hpp>
#include <godot_cpp/classes/label3d.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/shader.hpp>
#include <godot_cpp/classes/shader_material.hpp>
#include <godot_cpp/classes/texture2d.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/variant/basis.hpp>
#include <godot_cpp/variant/transform3d.hpp>

#include <cstring>

using namespace godot;

namespace xre {

namespace {

// FNV-1a over the value's bytes, so that order counts.
void mix(uint64_t &r_hash, uint64_t p_value) {
	for (int i = 0; i < 8; i++) {
		r_hash ^= (p_value >> (i * 8)) & 0xffu;
		r_hash *= 1099511628211ull;
	}
}

void mix_real(uint64_t &r_hash, real_t p_value) {
	uint32_t bits = 0;
	const float value = float(p_value);
	std::memcpy(&bits, &value, sizeof(bits));
	mix(r_hash, uint64_t(bits));
}

void mix_color(uint64_t &r_hash, const Color &p_color) {
	mix_real(r_hash, real_t(p_color.r));
	mix_real(r_hash, real_t(p_color.g));
	mix_real(r_hash, real_t(p_color.b));
	mix_real(r_hash, real_t(p_color.a));
}

void mix_transform(uint64_t &r_hash, const Transform3D &p_transform) {
	for (int row = 0; row < 3; row++) {
		for (int column = 0; column < 3; column++) { mix_real(r_hash, p_transform.basis[row][column]); }
		mix_real(r_hash, p_transform.origin[row]);
	}
}

void mix_variant(uint64_t &r_hash, const Variant &p_value) {
	if (p_value.get_type() == Variant::COLOR) {
		mix_color(r_hash, Color(p_value));
	} else if (p_value.get_type() == Variant::FLOAT || p_value.get_type() == Variant::INT) {
		mix_real(r_hash, real_t(double(p_value)));
	} else {
		mix(r_hash, uint64_t(p_value.get_type()));
	}
}

uint64_t id_of(const Object *p_object) {
	return p_object != nullptr ? uint64_t(p_object->get_instance_id()) : 0;
}

} // namespace

const XREMeshMerger::Source *XREMeshMerger::source_of(const Ref<Mesh> &p_mesh) {
	const uint64_t id = p_mesh->get_instance_id();
	if (const Source *known = sources.getptr(id)) {
		return known;
	}
	if (p_mesh->get_surface_count() < 1) {
		return nullptr;
	}
	const Array arrays = p_mesh->surface_get_arrays(0);
	if (arrays.size() != Mesh::ARRAY_MAX) {
		return nullptr;
	}
	Source source;
	source.vertices = arrays[Mesh::ARRAY_VERTEX];
	if (arrays[Mesh::ARRAY_NORMAL].get_type() == Variant::PACKED_VECTOR3_ARRAY) {
		source.normals = arrays[Mesh::ARRAY_NORMAL];
	}
	if (arrays[Mesh::ARRAY_INDEX].get_type() == Variant::PACKED_INT32_ARRAY) {
		source.indices = arrays[Mesh::ARRAY_INDEX];
	}
	if (source.indices.is_empty()) {
		source.indices.resize(source.vertices.size());
		for (int64_t i = 0; i < source.vertices.size(); i++) {
			source.indices[i] = int32_t(i);
		}
	}
	return &sources.insert(id, source)->value;
}

int XREMeshMerger::merge(const Ref<ArrayMesh> &p_target, const Array &p_meshes, const Array &p_transforms,
		const PackedColorArray &p_colors, int p_count, const Ref<Material> &p_material) {
	ERR_FAIL_COND_V(p_target.is_null(), 0);
	ERR_FAIL_COND_V(p_count < 0 || p_count > p_meshes.size() || p_count > p_transforms.size() || p_count > p_colors.size(), 0);
	int64_t vertex_count = 0;
	int64_t index_count = 0;
	for (int i = 0; i < p_count; i++) {
		const Ref<Mesh> mesh = p_meshes[i];
		const Source *source = mesh.is_valid() ? source_of(mesh) : nullptr;
		if (source != nullptr) {
			vertex_count += source->vertices.size();
			index_count += source->indices.size();
		}
	}
	p_target->clear_surfaces();
	if (vertex_count == 0) {
		return 0;
	}
	vertices.resize(vertex_count);
	normals.resize(vertex_count);
	colors.resize(vertex_count);
	indices.resize(index_count);
	Vector3 *vertex = vertices.ptrw();
	Vector3 *normal = normals.ptrw();
	Color *color = colors.ptrw();
	int32_t *index = indices.ptrw();
	int32_t base = 0;
	for (int i = 0; i < p_count; i++) {
		const Ref<Mesh> mesh = p_meshes[i];
		const Source *source = mesh.is_valid() ? source_of(mesh) : nullptr;
		if (source == nullptr) {
			continue;
		}
		const Transform3D place = p_transforms[i];
		// Normals by the inverse transpose, so that a part scaled unevenly still shades as before.
		const Basis turn = place.basis.inverse().transposed();
		const Color tint = p_colors[i];
		const Vector3 *from = source->vertices.ptr();
		const Vector3 *from_normal = source->normals.ptr();
		const bool has_normals = source->normals.size() == source->vertices.size();
		for (int64_t v = 0; v < source->vertices.size(); v++) {
			*vertex++ = place.xform(from[v]);
			*normal++ = has_normals ? turn.xform(from_normal[v]).normalized() : Vector3(0, 0, 1);
			*color++ = tint;
		}
		const int32_t *from_index = source->indices.ptr();
		for (int64_t n = 0; n < source->indices.size(); n++) {
			*index++ = from_index[n] + base;
		}
		base += int32_t(source->vertices.size());
	}
	Array arrays;
	arrays.resize(Mesh::ARRAY_MAX);
	arrays[Mesh::ARRAY_VERTEX] = vertices;
	arrays[Mesh::ARRAY_NORMAL] = normals;
	arrays[Mesh::ARRAY_COLOR] = colors;
	arrays[Mesh::ARRAY_INDEX] = indices;
	p_target->add_surface_from_arrays(Mesh::PRIMITIVE_TRIANGLES, arrays);
	if (p_material.is_valid()) {
		p_target->surface_set_material(0, p_material);
	}
	return int(vertex_count);
}

void XREMeshMerger::clear_cache() {
	sources.clear();
}

int64_t XREMeshMerger::card_state(Node *p_card, bool p_labels) {
	uint64_t hash = 14695981039346656037ull;
	if (p_card == nullptr) { return 0; }
	const int count = p_card->get_child_count();
	for (int i = 0; i < count; i++) { state_of(p_card->get_child(i), p_labels, hash); }
	return int64_t(hash);
}

void XREMeshMerger::state_of(Node *p_node, bool p_labels, uint64_t &r_hash) {
	Node3D *spatial = Object::cast_to<Node3D>(p_node);
	if (spatial == nullptr || p_node->has_meta(merged_name)) { return; }
	mix(r_hash, id_of(p_node));
	if (!spatial->is_visible()) {
		mix(r_hash, uint64_t(1));
		return;
	}
	mix_transform(r_hash, spatial->get_transform());
	if (GeometryInstance3D *geometry = Object::cast_to<GeometryInstance3D>(p_node)) {
		mix_real(r_hash, geometry->get_transparency());
		mix_real(r_hash, geometry->get_sorting_offset());
		const Ref<Material> material = geometry->get_material_override();
		mix(r_hash, id_of(material.ptr()));
		if (const BaseMaterial3D *standard = Object::cast_to<BaseMaterial3D>(material.ptr())) {
			mix_color(r_hash, standard->get_albedo());
			mix(r_hash, uint64_t(int64_t(standard->get_render_priority())));
			mix(r_hash, uint64_t(standard->get_flag(BaseMaterial3D::FLAG_DISABLE_DEPTH_TEST)));
			mix(r_hash, uint64_t(standard->get_transparency()));
			mix(r_hash, id_of(standard->get_texture(BaseMaterial3D::TEXTURE_ALBEDO).ptr()));
		} else if (const ShaderMaterial *shaded = Object::cast_to<ShaderMaterial>(material.ptr())) {
			mix(r_hash, uint64_t(int64_t(shaded->get_render_priority())));
			mix(r_hash, id_of(shaded->get_shader().ptr()));
			mix_variant(r_hash, shaded->get_shader_parameter(tint_name));
			mix_variant(r_hash, shaded->get_shader_parameter(face_tint_name));
			mix_variant(r_hash, shaded->get_shader_parameter(grow_name));
		}
		if (const MeshInstance3D *mesh = Object::cast_to<MeshInstance3D>(p_node)) { mix(r_hash, id_of(mesh->get_mesh().ptr())); }
		const Label3D *label = Object::cast_to<Label3D>(p_node);
		if (p_labels && label != nullptr) {
			mix(r_hash, uint64_t(label->get_text().hash()));
			mix_color(r_hash, label->get_modulate());
			mix_color(r_hash, label->get_outline_modulate());
			mix(r_hash, uint64_t(int64_t(label->get_font_size())));
			mix(r_hash, uint64_t(int64_t(label->get_outline_size())));
			mix_real(r_hash, label->get_pixel_size());
			mix(r_hash, uint64_t(label->get_draw_flag(Label3D::FLAG_DISABLE_DEPTH_TEST)));
			mix(r_hash, uint64_t(label->get_draw_flag(Label3D::FLAG_DOUBLE_SIDED)));
			mix(r_hash, uint64_t(label->get_billboard_mode()));
			mix(r_hash, uint64_t(int64_t(label->get_render_priority())));
			mix(r_hash, uint64_t(int64_t(label->get_outline_render_priority())));
			mix(r_hash, uint64_t(label->get_horizontal_alignment()));
			mix(r_hash, uint64_t(label->get_vertical_alignment()));
			mix_real(r_hash, label->get_width());
			mix(r_hash, uint64_t(label->get_autowrap_mode()));
			mix_real(r_hash, label->get_line_spacing());
			mix_real(r_hash, label->get_offset().x);
			mix_real(r_hash, label->get_offset().y);
			mix(r_hash, id_of(label->get_font().ptr()));
			mix(r_hash, uint64_t(label->get_alpha_cut_mode()));
		}
	}
	const int count = p_node->get_child_count();
	for (int i = 0; i < count; i++) { state_of(p_node->get_child(i), p_labels, r_hash); }
	mix(r_hash, uint64_t(2));
}

void XREMeshMerger::_bind_methods() {
	ClassDB::bind_method(D_METHOD("merge", "target", "meshes", "transforms", "colors", "count", "material"), &XREMeshMerger::merge);
	ClassDB::bind_method(D_METHOD("clear_cache"), &XREMeshMerger::clear_cache);
	ClassDB::bind_method(D_METHOD("card_state", "card", "labels"), &XREMeshMerger::card_state);
}

} // namespace xre
