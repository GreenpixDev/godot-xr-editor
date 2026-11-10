#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/packed_color_array.hpp>
#include <godot_cpp/variant/packed_float32_array.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>
#include <godot_cpp/variant/rid.hpp>
#include <godot_cpp/variant/transform3d.hpp>
#include <godot_cpp/variant/vector3.hpp>

#include <array>

#include "graph_wire.h"

namespace xre {

/// Lays the arrowheads of a logic graph's wires (D-115) along their tubes into a MultiMesh in one call
/// (D-166): what XREBlueprintCanvas._arrows_on and _put_arrow did in GDScript, the same poses and colours.
/// The canvas lists the tubes to lay arrowheads on with how; this writes the MultiMesh's buffer at once and
/// keeps the poses for get_pose. Allocates nothing once the buffer has its size.
class XREGraphArrows : public godot::RefCounted {
	GDCLASS(XREGraphArrows, godot::RefCounted);

public:
	/// How a tube's arrowheads go, in the low bits of a spec: none, every step, every step running, one at the end.
	enum Mode {
		MODE_OFF = 0,
		MODE_CHEVRONS = 1,
		MODE_RUNNING = 2,
		MODE_AT_END = 3,
	};
	/// Spec bits above the mode: along the tube (else against it); the tube is the one the end arrowhead goes on.
	static constexpr int32_t SPEC_MODE = 3;
	static constexpr int32_t SPEC_FORWARD = 4;
	static constexpr int32_t SPEC_END_PIECE = 8;
	/// Floats of one instance in the buffer: a 3x4 transform and a colour.
	static constexpr int STRIDE = 16;

	/// The canvas's spacing: [param p_limit] arrowheads at most, [param p_step] apart running at [param p_speed]
	/// m/s, [param p_margin] off each tube's ends; the end arrowhead [param p_end] before the end, [param p_end_scale] larger.
	void configure(int p_limit, double p_step, double p_speed, double p_margin, double p_end, double p_end_scale);
	/// Lays the arrowheads of the first [param p_count] tubes of [param p_pieces] (XREGraphWire), each by its
	/// [param p_specs], [param p_sizes] and [param p_colors], open ones turned to [param p_head] (canvas space) or
	/// cones, running by [param p_clock] seconds, into MultiMesh [param p_multimesh]. Returns how many.
	int lay(const godot::Array &p_pieces, int p_count, const godot::PackedInt32Array &p_specs, const godot::PackedFloat32Array &p_sizes,
			const godot::PackedColorArray &p_colors, const godot::Vector3 &p_head, double p_clock, bool p_open, const godot::RID &p_multimesh);
	/// Arrowhead [param p_index] of those the last lay put, in the canvas's space, or the identity.
	godot::Transform3D get_pose(int p_index) const;
	/// Its colour, or transparent black.
	godot::Color get_color(int p_index) const;
	int get_count() const;

protected:
	static void _bind_methods();

private:
	int put(const XREGraphWire &p_piece, int p_points, double p_along, bool p_forward, const godot::Vector3 &p_head, const godot::Color &p_color, double p_size, bool p_open, int p_count);

	int limit = 1024;
	double step = 0.09;
	double speed = 0.12;
	double margin = 0.035;
	double end = 0.025;
	double end_scale = 1.5;
	int count = 0;
	godot::PackedFloat32Array buffer;
	std::array<float, XREGraphWire::SAMPLES> arc{};
};

} // namespace xre
