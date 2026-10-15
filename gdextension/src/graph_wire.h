#pragma once

#include <godot_cpp/classes/array_mesh.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/aabb.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>
#include <godot_cpp/variant/transform3d.hpp>
#include <godot_cpp/variant/vector3.hpp>

#include <array>
#include <cstdint>

namespace xre {

/// Cached card obstacles in canvas coordinates; no scene queries or frame allocations.
class XREWireRouter : public godot::RefCounted {
	GDCLASS(XREWireRouter, godot::RefCounted);

public:
	static constexpr int MAX_OBSTACLES = 256;
	static constexpr int MAX_KNOTS = 18;
	static constexpr int MAX_POINTS = 128;
	void clear();
	void set_obstacle(int64_t p_id, const godot::AABB &p_bounds, const godot::Transform3D &p_pose);
	/// Uses a front routing plane and conservative stereo silhouettes for the current observer.
	void set_view(const godot::Vector3 &p_head, const godot::Vector3 &p_up);
	uint64_t get_revision() const { return revision; }
	/// Routes and smooths into the caller's fixed buffer. False means no safe bounded route.
	bool route(const godot::Vector3 &p_start, const godot::Vector3 &p_start_normal, const godot::Vector3 &p_end, const godot::Vector3 &p_end_normal, int64_t p_source, int64_t p_target, std::array<godot::Vector3, MAX_POINTS> &r_points, int &r_count, int &r_side);

protected:
	static void _bind_methods();

private:
	struct Obstacle {
		int64_t id = -1;
		godot::AABB bounds;
		godot::Transform3D pose;
		godot::Transform3D inverse;
		godot::AABB world_bounds;
	};
	std::array<Obstacle, MAX_OBSTACLES> obstacles;
	int obstacle_count = 0;
	uint64_t revision = 0;
	bool has_view = false;
	godot::Vector3 head;
	godot::Vector3 view_up;
	godot::Transform3D view;
	godot::Transform3D view_inverse;
	std::array<godot::AABB, MAX_OBSTACLES> silhouettes;
	std::array<bool, MAX_OBSTACLES> in_view{};
	uint64_t view_revision = UINT64_MAX;
	godot::real_t front_depth = 1.0f;
	void prepare_view();
	godot::Vector3 project(const godot::Vector3 &p_point) const;
	godot::Vector3 unproject(const godot::Vector3 &p_point) const;
	int silhouette_hits(const godot::Vector3 &p_a, const godot::Vector3 &p_b, int64_t p_ignore = -1) const;
	bool route_view(const godot::Vector3 &p_start, const godot::Vector3 &p_start_normal, const godot::Vector3 &p_end, const godot::Vector3 &p_end_normal, int64_t p_source, int64_t p_target, std::array<godot::Vector3, MAX_POINTS> &r_points, int &r_count, int &r_side) const;
	bool route_world(const godot::Vector3 &p_start, const godot::Vector3 &p_start_normal, const godot::Vector3 &p_end, const godot::Vector3 &p_end_normal, int64_t p_source, int64_t p_target, std::array<godot::Vector3, MAX_POINTS> &r_points, int &r_count) const;
	bool smooth(const std::array<godot::Vector3, MAX_KNOTS> &p_knots, int p_count, int64_t p_source, int64_t p_target, std::array<godot::Vector3, MAX_POINTS> &r_points, int &r_count, bool p_view = false) const;
	bool segment_hits(const godot::Vector3 &p_start, const godot::Vector3 &p_end, const godot::AABB &p_bounds) const;
	bool hits_obstacle(const godot::Vector3 &p_start, const godot::Vector3 &p_end, const Obstacle &p_obstacle, godot::real_t p_margin) const;
	int collisions(const godot::Vector3 &p_start, const godot::Vector3 &p_end, int64_t p_source, int64_t p_target, bool p_actual = false) const;
};

/// A smooth square-section tube. Buffers/mesh are allocated once, then updated in place.
class XREGraphWire : public godot::MeshInstance3D {
	GDCLASS(XREGraphWire, godot::MeshInstance3D);

public:
	XREGraphWire();
	void update_route(const godot::Ref<XREWireRouter> &p_router, const godot::Vector3 &p_start, const godot::Vector3 &p_start_normal, const godot::Vector3 &p_end, const godot::Vector3 &p_end_normal, int64_t p_source, int64_t p_target);
	int get_point_count() const;
	godot::Vector3 get_point(int p_index) const;
	bool is_routed() const;

protected:
	static void _bind_methods();

private:
	std::array<godot::Vector3, XREWireRouter::MAX_POINTS> points;
	int point_count = 0;
	bool routed = false;
	godot::Ref<godot::ArrayMesh> wire_mesh;
	godot::PackedByteArray vertex_bytes;
	godot::Ref<XREWireRouter> last_router;
	uint64_t last_revision = 0;
	godot::Vector3 last_start;
	godot::Vector3 last_start_normal;
	godot::Vector3 last_end;
	godot::Vector3 last_end_normal;
	int64_t last_source = -1;
	int64_t last_target = -1;
	int route_side = 0;
};

} // namespace xre
