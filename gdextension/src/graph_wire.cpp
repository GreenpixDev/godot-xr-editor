#include "graph_wire.h"

#include <godot_cpp/classes/rendering_server.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/core/math_defs.hpp>
#include <godot_cpp/variant/aabb.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>
#include <godot_cpp/variant/packed_vector3_array.hpp>

#include <algorithm>
#include <cmath>
#include <cstring>

using namespace godot;

namespace xre {

namespace {
constexpr int VERTICES = XREGraphWire::SAMPLES * XREGraphWire::SIDES;
// Handle length relative to the span, as GraphEdit's curvature; bounded so short links
// still bend out of their ports and long ones do not balloon.
constexpr real_t HANDLE = 0.5f;
constexpr real_t HANDLE_MIN = 0.03f;
constexpr real_t HANDLE_MAX = 0.3f;
// How far a back edge loops towards the user, per meter it runs backwards.
constexpr real_t LOOP = 0.4f;
constexpr real_t LOOP_MAX = 0.2f;

Vector3 bezier(const Vector3 &p_a, const Vector3 &p_b, const Vector3 &p_c, const Vector3 &p_d, real_t p_t) {
	const real_t u = 1.0f - p_t;
	return p_a * (u * u * u) + p_b * (3.0f * u * u * p_t) + p_c * (3.0f * u * p_t * p_t) + p_d * (p_t * p_t * p_t);
}

Vector3 bezier_tangent(const Vector3 &p_a, const Vector3 &p_b, const Vector3 &p_c, const Vector3 &p_d, real_t p_t) {
	const real_t u = 1.0f - p_t;
	return (p_b - p_a) * (3.0f * u * u) + (p_c - p_b) * (6.0f * u * p_t) + (p_d - p_c) * (3.0f * p_t * p_t);
}
} // namespace

XREGraphWire::XREGraphWire() {
	wire_mesh.instantiate();
	PackedVector3Array vertices;
	vertices.resize(VERTICES);
	PackedVector3Array normals;
	normals.resize(VERTICES);
	normals.fill(Vector3(0, 0, 1));
	PackedInt32Array indices;
	indices.resize((SAMPLES - 1) * SIDES * 6);
	int32_t *data = indices.ptrw();
	int cursor = 0;
	for (int i = 0; i < SAMPLES - 1; i++) {
		for (int side = 0; side < SIDES; side++) {
			const int a = i * SIDES + side;
			const int b = i * SIDES + (side + 1) % SIDES;
			const int c = a + SIDES;
			const int d = b + SIDES;
			data[cursor++] = a; data[cursor++] = c; data[cursor++] = b;
			data[cursor++] = b; data[cursor++] = c; data[cursor++] = d;
		}
	}
	Array arrays;
	arrays.resize(Mesh::ARRAY_MAX);
	arrays[Mesh::ARRAY_VERTEX] = vertices;
	arrays[Mesh::ARRAY_NORMAL] = normals;
	arrays[Mesh::ARRAY_INDEX] = indices;
	wire_mesh->add_surface_from_arrays(Mesh::PRIMITIVE_TRIANGLES, arrays, Array(), Dictionary(), Mesh::ARRAY_FLAG_USE_DYNAMIC_UPDATE);
	// Positions and octahedral normals share the vertex buffer; ask the server for its layout.
	const BitField<RenderingServer::ArrayFormat> format = static_cast<int64_t>(wire_mesh->surface_get_format(0));
	RenderingServer *server = RenderingServer::get_singleton();
	position_stride = server->mesh_surface_get_format_vertex_stride(format, VERTICES);
	normal_offset = server->mesh_surface_get_format_offset(format, VERTICES, RenderingServer::ARRAY_NORMAL);
	normal_stride = server->mesh_surface_get_format_normal_tangent_stride(format, VERTICES);
	vertex_bytes.resize(std::max(position_stride * VERTICES, normal_offset + normal_stride * VERTICES));
	vertex_bytes.fill(0);
	points.fill(Vector3());
}

void XREGraphWire::_bind_methods() {
	ClassDB::bind_method(D_METHOD("update_curve", "start", "start_direction", "end", "end_direction", "front"), &XREGraphWire::update_curve, DEFVAL(Vector3()));
	ClassDB::bind_method(D_METHOD("get_point_count"), &XREGraphWire::get_point_count);
	ClassDB::bind_method(D_METHOD("get_point", "index"), &XREGraphWire::get_point);
	BIND_CONSTANT(SAMPLES);
	BIND_CONSTANT(SIDES);
}

void XREGraphWire::update_curve(const Vector3 &p_start, const Vector3 &p_start_direction, const Vector3 &p_end, const Vector3 &p_end_direction, const Vector3 &p_front) {
	if (get_mesh().is_null()) { set_mesh(wire_mesh); }
	if (built && last_start == p_start && last_start_direction == p_start_direction && last_end == p_end && last_end_direction == p_end_direction && last_front == p_front) { return; }
	ERR_FAIL_COND(!p_start.is_finite() || !p_end.is_finite());
	built = true;
	last_start = p_start;
	last_start_direction = p_start_direction;
	last_end = p_end;
	last_end_direction = p_end_direction;
	last_front = p_front;

	const real_t handle = std::clamp(p_start.distance_to(p_end) * HANDLE, HANDLE_MIN, HANDLE_MAX);
	const Vector3 start_direction = p_start_direction.normalized();
	const real_t backwards = std::max(real_t(0), (p_start - p_end).dot(start_direction));
	const Vector3 loop = p_front.normalized() * std::min(backwards * LOOP, LOOP_MAX);
	const Vector3 a = p_start;
	const Vector3 b = p_start + start_direction * handle + loop;
	const Vector3 c = p_end + p_end_direction.normalized() * handle + loop;
	const Vector3 d = p_end;

	uint8_t *bytes = vertex_bytes.ptrw();
	AABB bounds(a, Vector3());
	Vector3 side;
	for (int i = 0; i < SAMPLES; i++) {
		const real_t t = real_t(i) / real_t(SAMPLES - 1);
		const Vector3 point = bezier(a, b, c, d, t);
		points[i] = point;
		Vector3 tangent = bezier_tangent(a, b, c, d, t);
		if (tangent.length_squared() < 1e-12f) { tangent = d - a; }
		if (tangent.length_squared() < 1e-12f) { tangent = Vector3(1, 0, 0); }
		tangent.normalize();
		// Parallel transport keeps the rings from twisting along the curve.
		side -= tangent * side.dot(tangent);
		if (side.length_squared() < 1e-8f) {
			side = tangent.cross(std::abs(tangent.y) > 0.9f ? Vector3(1, 0, 0) : Vector3(0, 1, 0));
		}
		side.normalize();
		const Vector3 up = tangent.cross(side);
		for (int k = 0; k < SIDES; k++) {
			const real_t angle = real_t(Math::TAU) * real_t(k) / real_t(SIDES);
			const Vector3 normal = side * std::cos(angle) + up * std::sin(angle);
			const Vector3 vertex = point + normal * RADIUS;
			bounds.expand_to(vertex);
			const int index = i * SIDES + k;
			const float position[3] = { float(vertex.x), float(vertex.y), float(vertex.z) };
			std::memcpy(bytes + index * position_stride, position, sizeof(position));
			const Vector2 encoded = normal.octahedron_encode();
			const uint16_t packed[2] = {
				uint16_t(std::clamp(encoded.x * 65535.0f, 0.0f, 65535.0f)),
				uint16_t(std::clamp(encoded.y * 65535.0f, 0.0f, 65535.0f)),
			};
			std::memcpy(bytes + normal_offset + index * normal_stride, packed, sizeof(packed));
		}
	}
	set_custom_aabb(bounds.grow(RADIUS));
	wire_mesh->surface_update_vertex_region(0, 0, vertex_bytes);
}

int XREGraphWire::get_point_count() const { return built ? SAMPLES : 0; }
Vector3 XREGraphWire::get_point(int p_index) const { ERR_FAIL_INDEX_V(p_index, get_point_count(), Vector3()); return points[p_index]; }

} // namespace xre
