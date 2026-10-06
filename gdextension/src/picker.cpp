#include "picker.h"

#include <godot_cpp/classes/cpu_particles3d.hpp>
#include <godot_cpp/classes/geometry_instance3d.hpp>
#include <godot_cpp/classes/gpu_particles3d.hpp>
#include <godot_cpp/classes/mesh.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/rendering_server.hpp>
#include <godot_cpp/classes/triangle_mesh.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/core/math.hpp>
#include <godot_cpp/core/object.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/packed_int64_array.hpp>
#include <godot_cpp/variant/transform3d.hpp>

#include <limits>

using namespace godot;

namespace xre {

namespace {

constexpr real_t EMPTY_NODE_HALF_SIZE = real_t(0.05);

/// Geometry whose bounding box stands for its shape: everything but particles,
/// whose box is a visibility volume.
bool is_pickable_geometry(const GeometryInstance3D *p_geometry) {
	return Object::cast_to<GPUParticles3D>(p_geometry) == nullptr && Object::cast_to<CPUParticles3D>(p_geometry) == nullptr;
}

/// A node scaled to zero has no inverse; it can't be hit anyway.
bool is_invertible(const Transform3D &p_transform) {
	return !Math::is_zero_approx(p_transform.basis.determinant());
}

void merge_bounds(Node *p_node, const Transform3D &p_to_local, AABB &r_bounds, bool &r_found) {
	const Node3D *node_3d = Object::cast_to<Node3D>(p_node);
	if (node_3d != nullptr && !node_3d->is_visible()) {
		return;
	}
	GeometryInstance3D *geometry = Object::cast_to<GeometryInstance3D>(p_node);
	if (geometry != nullptr && is_pickable_geometry(geometry)) {
		const AABB bounds = (p_to_local * geometry->get_global_transform()).xform(geometry->get_aabb());
		if (r_found) {
			r_bounds.merge_with(bounds);
		} else {
			r_bounds = bounds;
			r_found = true;
		}
	}
	const int32_t count = p_node->get_child_count();
	for (int32_t i = 0; i < count; i++) {
		merge_bounds(p_node->get_child(i), p_to_local, r_bounds, r_found);
	}
}

} // namespace

XREPicker::XREPicker() {
	edit_group_name = StringName("_edit_group_");
	edit_lock_name = StringName("_edit_lock_");
	// String keys, not StringName: that's how TriangleMesh fills its result.
	position_key = String("position");
	normal_key = String("normal");
}

void XREPicker::set_scenario(const RID &p_scenario) {
	scenario = p_scenario;
}

RID XREPicker::get_scenario() const {
	return scenario;
}

bool XREPicker::cast_segment(Node *p_scene_root, const Vector3 &p_from, const Vector3 &p_to) {
	clear_hit();
	ERR_FAIL_COND_V_MSG(!scenario.is_valid(), false, "XREPicker: set the scenario first.");
	if (p_scene_root == nullptr) {
		return false;
	}

	const PackedInt64Array ids = RenderingServer::get_singleton()->instances_cull_ray(p_from, p_to, scenario);
	double closest = std::numeric_limits<double>::infinity();
	for (int64_t i = 0; i < ids.size(); i++) {
		GeometryInstance3D *geometry = Object::cast_to<GeometryInstance3D>(ObjectDB::get_instance(uint64_t(ids[i])));
		if (!is_candidate(geometry, p_scene_root)) {
			continue;
		}
		Vector3 position;
		Vector3 normal;
		if (!intersect_segment(geometry, p_from, p_to, position, normal)) {
			continue;
		}
		const double distance = p_from.distance_to(position);
		if (distance >= closest) {
			continue;
		}
		Node3D *node = resolve(geometry, p_scene_root);
		if (node == nullptr) {
			continue;
		}
		closest = distance;
		set_hit(node, position, normal, distance);
	}
	return hit_node_id != 0;
}

bool XREPicker::find_at_point(Node *p_scene_root, const Vector3 &p_point, double p_radius, const Vector3 &p_viewer) {
	clear_hit();
	ERR_FAIL_COND_V_MSG(!scenario.is_valid(), false, "XREPicker: set the scenario first.");
	if (p_scene_root == nullptr) {
		return false;
	}

	const real_t radius = real_t(p_radius);
	const Vector3 reach(radius, radius, radius);
	const PackedInt64Array ids = RenderingServer::get_singleton()->instances_cull_aabb(AABB(p_point - reach, reach * real_t(2)), scenario);
	double smallest = std::numeric_limits<double>::infinity();
	for (int64_t i = 0; i < ids.size(); i++) {
		GeometryInstance3D *geometry = Object::cast_to<GeometryInstance3D>(ObjectDB::get_instance(uint64_t(ids[i])));
		if (!is_candidate(geometry, p_scene_root)) {
			continue;
		}
		const Transform3D xform = geometry->get_global_transform();
		if (!is_invertible(xform)) {
			continue;
		}
		const AABB bounds = geometry->get_aabb();
		const Transform3D to_local = xform.affine_inverse();
		if (bounds.has_point(to_local.xform(p_viewer))) {
			continue;
		}
		// Distance to the box in world space, exact for any rotation and scale.
		const Vector3 local_point = to_local.xform(p_point);
		const double distance = bounds.has_point(local_point)
				? 0.0
				: double(p_point.distance_to(xform.xform(local_point.clamp(bounds.position, bounds.get_end()))));
		if (distance > p_radius) {
			continue;
		}
		// Grown by the reach, so that a flat box (a floor plane) isn't the smallest of all.
		const Vector3 size = (xform.basis.get_scale().abs() * bounds.size) + reach * real_t(2);
		const double volume = double(size.x) * double(size.y) * double(size.z);
		if (volume >= smallest) {
			continue;
		}
		Node3D *node = resolve(geometry, p_scene_root);
		if (node == nullptr) {
			continue;
		}
		smallest = volume;
		set_hit(node, p_point, Vector3(), distance);
	}
	return hit_node_id != 0;
}

Node3D *XREPicker::get_hit_node() const {
	return hit_node_id == 0 ? nullptr : Object::cast_to<Node3D>(ObjectDB::get_instance(hit_node_id));
}

Vector3 XREPicker::get_hit_position() const {
	return hit_position;
}

Vector3 XREPicker::get_hit_normal() const {
	return hit_normal;
}

double XREPicker::get_hit_distance() const {
	return hit_distance;
}

Node3D *XREPicker::get_selectable_node(Node *p_node, Node *p_scene_root) const {
	ERR_FAIL_NULL_V(p_node, nullptr);
	ERR_FAIL_NULL_V(p_scene_root, nullptr);
	if (p_node != p_scene_root && !p_scene_root->is_ancestor_of(p_node)) {
		return nullptr;
	}
	return resolve(p_node, p_scene_root);
}

AABB XREPicker::get_local_bounds(Node3D *p_node) {
	const AABB empty_node_bounds(Vector3(-EMPTY_NODE_HALF_SIZE, -EMPTY_NODE_HALF_SIZE, -EMPTY_NODE_HALF_SIZE),
			Vector3(EMPTY_NODE_HALF_SIZE, EMPTY_NODE_HALF_SIZE, EMPTY_NODE_HALF_SIZE) * real_t(2));
	ERR_FAIL_NULL_V(p_node, empty_node_bounds);
	const Transform3D xform = p_node->get_global_transform();
	if (!is_invertible(xform)) {
		return empty_node_bounds;
	}
	AABB bounds;
	bool found = false;
	merge_bounds(p_node, xform.affine_inverse(), bounds, found);
	return found ? bounds : empty_node_bounds;
}

void XREPicker::clear_hit() {
	hit_node_id = 0;
	hit_position = Vector3();
	hit_normal = Vector3();
	hit_distance = 0.0;
}

void XREPicker::set_hit(Node3D *p_node, const Vector3 &p_position, const Vector3 &p_normal, double p_distance) {
	hit_node_id = p_node->get_instance_id();
	hit_position = p_position;
	hit_normal = p_normal;
	hit_distance = p_distance;
}

bool XREPicker::is_candidate(GeometryInstance3D *p_geometry, Node *p_scene_root) const {
	// The scenario also holds the VR layer, editor gizmos and the preview sun:
	// only nodes of the edited scene count.
	return p_geometry != nullptr && is_pickable_geometry(p_geometry) &&
			(p_geometry == p_scene_root || p_scene_root->is_ancestor_of(p_geometry)) &&
			p_geometry->is_visible_in_tree() && !is_locked(p_geometry);
}

bool XREPicker::intersect_segment(GeometryInstance3D *p_geometry, const Vector3 &p_from, const Vector3 &p_to, Vector3 &r_position, Vector3 &r_normal) const {
	const Transform3D xform = p_geometry->get_global_transform();
	if (!is_invertible(xform)) {
		return false;
	}
	const Transform3D to_local = xform.affine_inverse();
	const Vector3 local_from = to_local.xform(p_from);
	const Vector3 local_to = to_local.xform(p_to);
	Vector3 local_position;
	Vector3 local_normal;

	const MeshInstance3D *mesh_instance = Object::cast_to<MeshInstance3D>(p_geometry);
	if (mesh_instance != nullptr) {
		const Ref<Mesh> mesh = mesh_instance->get_mesh();
		if (mesh.is_null()) {
			return false;
		}
		// Built on first use and cached by the mesh until it changes.
		const Ref<TriangleMesh> triangles = mesh->generate_triangle_mesh();
		if (triangles.is_null()) {
			return false;
		}
		const Dictionary hit = triangles->intersect_segment(local_from, local_to);
		if (hit.is_empty()) {
			return false;
		}
		local_position = hit[position_key];
		local_normal = hit[normal_key];
	} else {
		// From inside a box (a room built of CSG), the ray hits the wall it
		// leaves through, as it does with a closed mesh.
		const AABB bounds = p_geometry->get_aabb();
		if (bounds.has_point(local_from)) {
			if (bounds.has_point(local_to) || !bounds.intersects_segment(local_to, local_from, &local_position, &local_normal)) {
				return false;
			}
		} else if (!bounds.intersects_segment(local_from, local_to, &local_position, &local_normal)) {
			return false;
		}
	}

	r_position = xform.xform(local_position);
	r_normal = xform.basis.inverse().transposed().xform(local_normal).normalized();
	// Triangle normals follow the winding; the side the ray came from is what counts.
	if (r_normal.dot(p_to - p_from) > 0) {
		r_normal = -r_normal;
	}
	return true;
}

Node3D *XREPicker::resolve(Node *p_node, Node *p_scene_root) const {
	Node *node = p_node;

	// Node::get_deepest_editable_node(), which isn't exposed: the outermost
	// instance root on the way up whose children aren't editable.
	if (node != p_scene_root) {
		const Node *iterated = node;
		while (iterated->get_owner() != nullptr && iterated->get_owner() != p_scene_root) {
			if (!p_scene_root->is_editable_instance(iterated->get_owner())) {
				node = iterated->get_owner();
			}
			iterated = iterated->get_owner();
		}
	}

	// Only nodes the edited scene owns can be selected: one added by a tool
	// script without an owner gives way to its parent.
	const Node *scene_parent = p_scene_root->get_parent();
	while (node != nullptr && node != scene_parent) {
		Node *owner = node->get_owner();
		if (node == p_scene_root || owner == p_scene_root || (owner != nullptr && p_scene_root->is_editable_instance(owner))) {
			break;
		}
		node = node->get_parent();
	}

	// The outermost group stands for everything in it.
	Node3D *selected = Object::cast_to<Node3D>(node);
	for (Node *ancestor = node; ancestor != nullptr && ancestor != scene_parent; ancestor = ancestor->get_parent()) {
		Node3D *group = Object::cast_to<Node3D>(ancestor);
		if (group != nullptr && ancestor->has_meta(edit_group_name)) {
			selected = group;
		}
	}

	if (selected == nullptr || is_locked(selected)) {
		return nullptr;
	}
	return selected;
}

bool XREPicker::is_locked(const Node *p_node) const {
	return bool(p_node->get_meta(edit_lock_name, false));
}

void XREPicker::_bind_methods() {
	ClassDB::bind_method(D_METHOD("set_scenario", "scenario"), &XREPicker::set_scenario);
	ClassDB::bind_method(D_METHOD("get_scenario"), &XREPicker::get_scenario);
	ADD_PROPERTY(PropertyInfo(Variant::RID, "scenario"), "set_scenario", "get_scenario");

	ClassDB::bind_method(D_METHOD("cast_segment", "scene_root", "from", "to"), &XREPicker::cast_segment);
	ClassDB::bind_method(D_METHOD("find_at_point", "scene_root", "point", "radius", "viewer"), &XREPicker::find_at_point);
	ClassDB::bind_method(D_METHOD("get_hit_node"), &XREPicker::get_hit_node);
	ClassDB::bind_method(D_METHOD("get_hit_position"), &XREPicker::get_hit_position);
	ClassDB::bind_method(D_METHOD("get_hit_normal"), &XREPicker::get_hit_normal);
	ClassDB::bind_method(D_METHOD("get_hit_distance"), &XREPicker::get_hit_distance);
	ClassDB::bind_method(D_METHOD("get_selectable_node", "node", "scene_root"), &XREPicker::get_selectable_node);
	ClassDB::bind_static_method("XREPicker", D_METHOD("get_local_bounds", "node"), &XREPicker::get_local_bounds);
}

} // namespace xre
