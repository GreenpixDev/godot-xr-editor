#pragma once

#include <godot_cpp/classes/array_mesh.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>
#include <godot_cpp/variant/vector3.hpp>

#include <array>
#include <cstdint>

namespace xre {

/// A logic graph connection: a cubic Bezier tube from one port to another, as in GraphEdit.
/// The curve depends only on its endpoints and their exit directions, so it never jumps
/// with the head and never disappears. The mesh is allocated once and updated in place.
class XREGraphWire : public godot::MeshInstance3D {
	GDCLASS(XREGraphWire, godot::MeshInstance3D);

public:
	static constexpr int SAMPLES = 40;
	static constexpr int SIDES = 8;
	static constexpr godot::real_t RADIUS = 0.0022f;

	XREGraphWire();
	/// A zero direction leaves that end free: the curve simply arrives at the point.
	/// A back edge (the end behind the start's direction) loops out along [param p_front],
	/// towards the user, instead of folding into a cusp in the cards' plane.
	void update_curve(const godot::Vector3 &p_start, const godot::Vector3 &p_start_direction, const godot::Vector3 &p_end, const godot::Vector3 &p_end_direction, const godot::Vector3 &p_front);
	int get_point_count() const;
	godot::Vector3 get_point(int p_index) const;
	/// Where the ray from [param p_origin] along [param p_direction] (global) first passes
	/// within [param p_radius] meters of the curve, in units of [param p_direction] up to
	/// [param p_maximum], or -1; [param p_margin] of the curve at each end is left out, where
	/// it goes into its ports. Allocates nothing: it may run every frame.
	godot::real_t intersect_ray(const godot::Vector3 &p_origin, const godot::Vector3 &p_direction, godot::real_t p_radius, godot::real_t p_maximum, godot::real_t p_margin);
	/// How far along the curve the last [method intersect_ray] hit it, 0 at its start to 1 at its end, or -1.
	godot::real_t get_hit_fraction() const;

protected:
	static void _bind_methods();

private:
	std::array<godot::Vector3, SAMPLES> points;
	godot::Ref<godot::ArrayMesh> wire_mesh;
	godot::PackedByteArray vertex_bytes;
	uint32_t position_stride = 0;
	uint32_t normal_offset = 0;
	uint32_t normal_stride = 0;
	bool built = false;
	godot::real_t hit_fraction = -1.0f;
	godot::Vector3 last_start;
	godot::Vector3 last_start_direction;
	godot::Vector3 last_end;
	godot::Vector3 last_end_direction;
	godot::Vector3 last_front;
};

} // namespace xre
