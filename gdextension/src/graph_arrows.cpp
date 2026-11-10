#include "graph_arrows.h"

#include <godot_cpp/classes/rendering_server.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/core/math.hpp>
#include <godot_cpp/variant/basis.hpp>
#include <godot_cpp/variant/color.hpp>
#include <godot_cpp/variant/quaternion.hpp>

#include <cmath>

using namespace godot;

namespace xre {

void XREGraphArrows::configure(int p_limit, double p_step, double p_speed, double p_margin, double p_end, double p_end_scale) {
	ERR_FAIL_COND(p_limit < 0);
	limit = p_limit;
	step = p_step;
	speed = p_speed;
	margin = p_margin;
	end = p_end;
	end_scale = p_end_scale;
	buffer.resize(int64_t(limit) * STRIDE);
	buffer.fill(0.0f);
	count = 0;
}

int XREGraphArrows::lay(const Array &p_pieces, int p_count, const PackedInt32Array &p_specs, const PackedFloat32Array &p_sizes,
		const PackedColorArray &p_colors, const Vector3 &p_head, double p_clock, bool p_open, const RID &p_multimesh) {
	ERR_FAIL_COND_V(p_count < 0 || p_count > p_pieces.size() || p_count > p_specs.size() || p_count > p_sizes.size() || p_count > p_colors.size(), 0);
	if (buffer.size() != int64_t(limit) * STRIDE) {
		buffer.resize(int64_t(limit) * STRIDE);
	}
	count = 0;
	const double running = std::fmod(p_clock * speed, step);
	for (int i = 0; i < p_count; i++) {
		const XREGraphWire *piece = Object::cast_to<XREGraphWire>(p_pieces[i]);
		if (piece == nullptr) {
			continue;
		}
		const int32_t spec = p_specs[i];
		const int mode = spec & SPEC_MODE;
		if (mode == MODE_OFF) {
			continue;
		}
		const bool forward = (spec & SPEC_FORWARD) != 0;
		const int points = piece->get_point_count();
		if (points < 2 || points > XREGraphWire::SAMPLES) {
			continue;
		}
		arc[0] = 0.0f;
		for (int point = 1; point < points; point++) {
			arc[point] = arc[point - 1] + piece->get_point(point).distance_to(piece->get_point(point - 1));
		}
		const double length = arc[points - 1];
		const double size = p_sizes[i];
		const Color color = p_colors[i];
		// One at the end of the flow: the last tube's end, or the first's start against it.
		if (mode == MODE_AT_END) {
			if ((spec & SPEC_END_PIECE) != 0 && length > end * 2.0 && count < limit) {
				count = put(*piece, points, length - end, forward, p_head, color, size * end_scale, p_open, count);
			}
			continue;
		}
		if (length < margin * 2.0 + 0.02) {
			continue;
		}
		double along = margin + (mode == MODE_RUNNING ? running : step * 0.5);
		while (along < length - margin && count < limit) {
			count = put(*piece, points, along, forward, p_head, color, size, p_open, count);
			along += step;
		}
	}
	if (count > 0 && p_multimesh.is_valid()) {
		RenderingServer::get_singleton()->multimesh_set_buffer(p_multimesh, buffer);
	}
	return count;
}

int XREGraphArrows::put(const XREGraphWire &p_piece, int p_points, double p_along, bool p_forward, const Vector3 &p_head, const Color &p_color, double p_size, bool p_open, int p_count) {
	const double length = arc[p_points - 1];
	const double at = p_forward ? p_along : length - p_along;
	int index = 0;
	while (index < p_points - 2 && arc[index + 1] < at) {
		index++;
	}
	const Vector3 start = p_piece.get_point(index);
	const Vector3 finish = p_piece.get_point(index + 1);
	const double span = double(arc[index + 1]) - double(arc[index]);
	const double weight = span > 0.0 ? Math::clamp((at - double(arc[index])) / span, 0.0, 1.0) : 0.0;
	const Vector3 point = start.lerp(finish, real_t(weight));
	const Vector3 tangent = (finish - start).normalized() * (p_forward ? 1.0f : -1.0f);
	if (tangent.is_zero_approx()) {
		return p_count;
	}
	Basis basis;
	if (p_open) {
		// Flat along the wire, turned about it to the head.
		Vector3 toward = p_head - point;
		toward -= tangent * toward.dot(tangent);
		if (toward.is_zero_approx()) {
			const Vector3 side = tangent.cross(Vector3(0, 1, 0));
			toward = !side.is_zero_approx() ? side : Vector3(0, 0, 1);
		}
		toward = toward.normalized();
		basis = Basis(tangent.cross(toward).normalized(), tangent, toward);
	} else {
		basis = Basis(Quaternion(Vector3(0, 1, 0), tangent));
	}
	basis = basis.scaled(Vector3(1, 1, 1) * real_t(p_size));
	float *data = buffer.ptrw() + int64_t(p_count) * STRIDE;
	for (int row = 0; row < 3; row++) {
		data[row * 4 + 0] = float(basis.rows[row].x);
		data[row * 4 + 1] = float(basis.rows[row].y);
		data[row * 4 + 2] = float(basis.rows[row].z);
		data[row * 4 + 3] = float(point[row]);
	}
	data[12] = p_color.r;
	data[13] = p_color.g;
	data[14] = p_color.b;
	data[15] = p_color.a;
	return p_count + 1;
}

Transform3D XREGraphArrows::get_pose(int p_index) const {
	if (p_index < 0 || p_index >= count) {
		return Transform3D();
	}
	const float *data = buffer.ptr() + int64_t(p_index) * STRIDE;
	Transform3D pose;
	for (int row = 0; row < 3; row++) {
		pose.basis.rows[row] = Vector3(data[row * 4 + 0], data[row * 4 + 1], data[row * 4 + 2]);
		pose.origin[row] = data[row * 4 + 3];
	}
	return pose;
}

Color XREGraphArrows::get_color(int p_index) const {
	if (p_index < 0 || p_index >= count) {
		return Color(0, 0, 0, 0);
	}
	const float *data = buffer.ptr() + int64_t(p_index) * STRIDE;
	return Color(data[12], data[13], data[14], data[15]);
}

int XREGraphArrows::get_count() const {
	return count;
}

void XREGraphArrows::_bind_methods() {
	ClassDB::bind_method(D_METHOD("configure", "limit", "step", "speed", "margin", "end", "end_scale"), &XREGraphArrows::configure);
	ClassDB::bind_method(D_METHOD("lay", "pieces", "count", "specs", "sizes", "colors", "head", "clock", "open", "multimesh"), &XREGraphArrows::lay);
	ClassDB::bind_method(D_METHOD("get_pose", "index"), &XREGraphArrows::get_pose);
	ClassDB::bind_method(D_METHOD("get_color", "index"), &XREGraphArrows::get_color);
	ClassDB::bind_method(D_METHOD("get_count"), &XREGraphArrows::get_count);
	BIND_CONSTANT(SPEC_FORWARD);
	BIND_CONSTANT(SPEC_END_PIECE);
	BIND_CONSTANT(MODE_OFF);
	BIND_CONSTANT(MODE_CHEVRONS);
	BIND_CONSTANT(MODE_RUNNING);
	BIND_CONSTANT(MODE_AT_END);
}

} // namespace xre
