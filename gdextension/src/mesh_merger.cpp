#include "mesh_merger.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/variant/basis.hpp>
#include <godot_cpp/variant/transform3d.hpp>

using namespace godot;

namespace xre {

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

void XREMeshMerger::_bind_methods() {
	ClassDB::bind_method(D_METHOD("merge", "target", "meshes", "transforms", "colors", "count", "material"), &XREMeshMerger::merge);
	ClassDB::bind_method(D_METHOD("clear_cache"), &XREMeshMerger::clear_cache);
}

} // namespace xre
