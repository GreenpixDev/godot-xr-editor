#include "graph_wire.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/packed_int32_array.hpp>
#include <godot_cpp/variant/packed_vector3_array.hpp>

#include <algorithm>
#include <cmath>
#include <cstring>
#include <limits>

using namespace godot;

namespace xre {

namespace {
constexpr real_t MARGIN = 0.0075f;
constexpr real_t DETOUR = 0.04f;
constexpr real_t ROUND = 0.025f;
constexpr real_t STUB = 0.07f;
constexpr real_t RADIUS = 0.0015f;
constexpr real_t TUBE_MARGIN = RADIUS * 1.414214f;

Vector3 quadratic(const Vector3 &p_a, const Vector3 &p_control, const Vector3 &p_b, real_t p_t) {
	const real_t inverse = 1.0f - p_t;
	return p_a * (inverse * inverse) + p_control * (2.0f * inverse * p_t) + p_b * (p_t * p_t);
}
} // namespace

void XREWireRouter::_bind_methods() {
	ClassDB::bind_method(D_METHOD("clear"), &XREWireRouter::clear);
	ClassDB::bind_method(D_METHOD("set_obstacle", "id", "bounds", "pose"), &XREWireRouter::set_obstacle, DEFVAL(Transform3D()));
	ClassDB::bind_method(D_METHOD("set_view", "head", "up"), &XREWireRouter::set_view);
}

void XREWireRouter::clear() { obstacle_count = 0; revision++; }

void XREWireRouter::set_obstacle(int64_t p_id, const AABB &p_bounds, const Transform3D &p_pose) {
	for (int i = 0; i < obstacle_count; i++) {
		if (obstacles[i].id == p_id) {
			if (obstacles[i].bounds != p_bounds || obstacles[i].pose != p_pose) {
				obstacles[i] = { p_id, p_bounds, p_pose, p_pose.affine_inverse(), p_pose.xform(p_bounds) };
				revision++;
			}
			return;
		}
	}
	ERR_FAIL_COND(obstacle_count == MAX_OBSTACLES);
	obstacles[obstacle_count++] = { p_id, p_bounds, p_pose, p_pose.affine_inverse(), p_pose.xform(p_bounds) };
	revision++;
}

bool XREWireRouter::segment_hits(const Vector3 &p_start, const Vector3 &p_end, const AABB &p_bounds) const {
	const Vector3 delta = p_end - p_start;
	const Vector3 end = p_bounds.get_end();
	double near = 0.0;
	double far = 1.0;
	for (int axis = 0; axis < 3; axis++) {
		if (std::abs(delta[axis]) < 0.0000001) {
			if (p_start[axis] <= p_bounds.position[axis] || p_start[axis] >= end[axis]) { return false; }
			continue;
		}
		const double a = (p_bounds.position[axis] - p_start[axis]) / delta[axis];
		const double b = (end[axis] - p_start[axis]) / delta[axis];
		near = std::max(near, std::min(a, b));
		far = std::min(far, std::max(a, b));
		if (near >= far) { return false; }
	}
	return near < 1.0 && far > 0.0;
}

bool XREWireRouter::hits_obstacle(const Vector3 &p_start, const Vector3 &p_end, const Obstacle &p_obstacle, real_t p_margin) const {
	return segment_hits(p_obstacle.inverse.xform(p_start), p_obstacle.inverse.xform(p_end), p_obstacle.bounds.grow(p_margin));
}

int XREWireRouter::collisions(const Vector3 &p_start, const Vector3 &p_end, int64_t p_source, int64_t p_target, bool p_actual) const {
	int count = 0;
	for (int i = 0; i < obstacle_count; i++) {
		const auto &obstacle = obstacles[i];
		const real_t margin = (p_actual || obstacle.id == p_source || obstacle.id == p_target) ? TUBE_MARGIN : MARGIN;
		if (hits_obstacle(p_start, p_end, obstacle, margin)) { count++; }
	}
	return count;
}

void XREWireRouter::set_view(const Vector3 &p_head, const Vector3 &p_up) {
	if (has_view && head == p_head && view_up == p_up) { return; }
	has_view = true;
	head = p_head;
	view_up = p_up.normalized();
	revision++;
}

void XREWireRouter::prepare_view() {
	if (view_revision == revision) { return; }
	view_revision = revision;
	AABB envelope;
	if (obstacle_count > 0) {
		envelope = obstacles[0].world_bounds;
		for (int i = 1; i < obstacle_count; i++) { envelope = envelope.merge(obstacles[i].world_bounds); }
	}
	Vector3 away = envelope.get_center() - head;
	if (away.length_squared() < 0.000001f) { away = Vector3(0, 0, -1); }
	Vector3 up = view_up;
	if (away.normalized().cross(up).length_squared() < 0.0001f) { up = Vector3(0, 0, 1); }
	view = Transform3D(Basis::looking_at(away, up), head);
	view_inverse = view.affine_inverse();
	real_t nearest = std::numeric_limits<real_t>::infinity();
	for (int i = 0; i < obstacle_count; i++) {
		in_view[i] = true;
		for (int corner = 0; corner < 8; corner++) {
			const Vector3 point = view_inverse.xform(obstacles[i].pose.xform(obstacles[i].bounds.get_endpoint(corner)));
			if (-point.z <= 0.05f) { in_view[i] = false; }
		}
		if (in_view[i]) {
			for (int corner = 0; corner < 8; corner++) {
				nearest = std::min(nearest, -view_inverse.xform(obstacles[i].pose.xform(obstacles[i].bounds.get_endpoint(corner))).z);
			}
		}
	}
	front_depth = std::isfinite(nearest) ? std::max(0.05f, nearest - 0.06f) : 1.0f;
	for (int i = 0; i < obstacle_count; i++) {
		if (!in_view[i]) { continue; }
		AABB rectangle;
		real_t margin = 0;
		for (int corner = 0; corner < 8; corner++) {
			const Vector3 local = view_inverse.xform(obstacles[i].pose.xform(obstacles[i].bounds.get_endpoint(corner)));
			const real_t scale = front_depth / -local.z;
			const Vector3 projected(local.x * scale, local.y * scale, 0);
			if (corner == 0) { rectangle = AABB(projected, Vector3()); }
			else { rectangle.expand_to(projected); }
			// Covers tube thickness and eye parallax relative to the front plane.
			margin = std::max(margin, MARGIN * scale + 0.035f * std::abs(1.0f - scale));
		}
		silhouettes[i] = rectangle.grow(margin);
		silhouettes[i].position.z = -1;
		silhouettes[i].size.z = 2;
	}
}

Vector3 XREWireRouter::project(const Vector3 &p_point) const {
	const Vector3 local = view_inverse.xform(p_point);
	const real_t scale = front_depth / std::max(0.05f, -local.z);
	return Vector3(local.x * scale, local.y * scale, 0);
}

Vector3 XREWireRouter::unproject(const Vector3 &p_point) const {
	return view.xform(Vector3(p_point.x, p_point.y, -front_depth));
}

int XREWireRouter::silhouette_hits(const Vector3 &p_a, const Vector3 &p_b, int64_t p_ignore) const {
	int hits = 0;
	for (int i = 0; i < obstacle_count; i++) {
		if (in_view[i] && obstacles[i].id != p_ignore && segment_hits(p_a, p_b, silhouettes[i])) { hits++; }
	}
	return hits;
}

bool XREWireRouter::route(const Vector3 &p_start, const Vector3 &p_start_normal, const Vector3 &p_end, const Vector3 &p_end_normal, int64_t p_source, int64_t p_target, std::array<Vector3, MAX_POINTS> &r_points, int &r_count, int &r_side) {
	if (has_view) {
		prepare_view();
		if (-view_inverse.xform(p_start).z > 0.05f && -view_inverse.xform(p_end).z > 0.05f) {
			return route_view(p_start, p_start_normal, p_end, p_end_normal, p_source, p_target, r_points, r_count, r_side);
		}
	}
	return route_world(p_start, p_start_normal, p_end, p_end_normal, p_source, p_target, r_points, r_count);
}

bool XREWireRouter::route_view(const Vector3 &p_start, const Vector3 &p_start_normal, const Vector3 &p_end, const Vector3 &p_end_normal, int64_t p_source, int64_t p_target, std::array<Vector3, MAX_POINTS> &r_points, int &r_count, int &r_side) const {
	r_count = 0;
	if (!p_start.is_finite() || !p_end.is_finite()) { return false; }
	const auto stem = [&](const Vector3 &point, const Vector3 &normal) {
		real_t length = std::min(STUB, p_start.distance_to(p_end) * 0.25f);
		for (int i = 0; i < obstacle_count; i++) {
			const real_t margin = (obstacles[i].id == p_source || obstacles[i].id == p_target) ? TUBE_MARGIN : MARGIN;
			if (!hits_obstacle(point, point + normal * length, obstacles[i], margin)) { continue; }
			real_t low = 0;
			real_t high = length;
			for (int search = 0; search < 12; search++) {
				const real_t middle = (low + high) * 0.5f;
				if (hits_obstacle(point, point + normal * middle, obstacles[i], margin)) { high = middle; }
				else { low = middle; }
			}
			length = low * 0.5f;
		}
		return point + normal * length;
	};
	const Vector3 start_lead = stem(p_start, p_start_normal.normalized());
	const Vector3 end_lead = stem(p_end, p_end_normal.normalized());
	const auto escape = [&](Vector3 point, int64_t owner, const Vector3 &terminal) {
		int sign = 0;
		for (int i = 0; i < obstacle_count; i++) {
			if (obstacles[i].id == owner) { sign = obstacles[i].inverse.xform(terminal).x < 0 ? -1 : 1; }
		}
		for (int pass = 0; pass < MAX_KNOTS; pass++) {
			bool blocked = false;
			for (int i = 0; i < obstacle_count; i++) {
				if (!in_view[i] || !silhouettes[i].has_point(point)) { continue; }
				const AABB &area = silhouettes[i];
				const bool right = sign ? sign > 0 : point.x > area.get_center().x;
				point.x = right ? area.get_end().x + DETOUR : area.position.x - DETOUR;
				blocked = true;
			}
			if (!blocked) { break; }
		}
		return point;
	};
	std::array<Vector3, MAX_KNOTS> core;
	core[0] = escape(project(start_lead), p_source, p_start);
	core[1] = escape(project(end_lead), p_target, p_end);
	int core_count = 2;
	AABB envelope;
	bool first_rectangle = true;
	for (int i = 0; i < obstacle_count; i++) {
		if (!in_view[i]) { continue; }
		envelope = first_rectangle ? silhouettes[i] : envelope.merge(silhouettes[i]);
		first_rectangle = false;
	}
	for (int pass = 0; pass < MAX_KNOTS; pass++) {
		int segment = -1;
		int blocking = -1;
		for (int k = 0; k < core_count - 1 && blocking < 0; k++) {
			for (int i = 0; i < obstacle_count; i++) {
				if (in_view[i] && segment_hits(core[k], core[k + 1], silhouettes[i])) { segment = k; blocking = i; break; }
			}
		}
		if (blocking < 0) { break; }
		if (core_count + 8 > MAX_KNOTS) { return false; }
		const Vector3 start = core[segment];
		const Vector3 end = core[segment + 1];
		const AABB &bounds = silhouettes[blocking];
		double best = std::numeric_limits<double>::infinity();
		Vector3 first;
		Vector3 second;
		int chosen_side = 0;
		bool preferred = false;
		for (int axis = 1; axis >= 0 && !preferred; axis--) {
			for (int side = 1; side >= 0 && !preferred; side--) {
				for (int global = 0; global < 2 && !preferred; global++) {
					const AABB &area = global ? envelope : bounds;
					const real_t plane = side ? area.get_end()[axis] + DETOUR : area.position[axis] - DETOUR;
					Vector3 a = start;
					Vector3 b = end;
					a[axis] = plane; b[axis] = plane;
					if (segment_hits(start, a, bounds) || segment_hits(a, b, bounds) || segment_hits(b, end, bounds)) { continue; }
					const int hits = silhouette_hits(start, a) + silhouette_hits(a, b) + silhouette_hits(b, end);
					const int choice = (axis + 1) * (side ? 1 : -1);
					const double score = start.distance_to(a) + a.distance_to(b) + b.distance_to(end) + hits * 1000.0;
					if (score < best || (choice == r_side && hits == 0)) {
						best = score; first = a; second = b; chosen_side = choice;
						preferred = choice == r_side && hits == 0;
					}
				}
			}
		}
		if (!std::isfinite(best)) { return false; }
		if (r_side == 0 || !preferred) { r_side = chosen_side; }
		for (int k = core_count - 1; k > segment; k--) { core[k + 2] = core[k]; }
		core[segment + 1] = first; core[segment + 2] = second;
		core_count += 2;
	}
	for (int k = 0; k < core_count - 1; k++) {
		if (silhouette_hits(core[k], core[k + 1]) > 0) { return false; }
	}
	std::array<Vector3, MAX_KNOTS> knots;
	int count = 0;
	knots[count++] = p_start;
	knots[count++] = start_lead;
	knots[count++] = unproject(project(start_lead));
	for (int k = 0; k < core_count; k++) { knots[count++] = unproject(core[k]); }
	if (p_target >= 0) {
		knots[count++] = unproject(project(end_lead));
	} else {
		const Vector3 portal = view_inverse.xform(unproject(core[core_count - 1]));
		const real_t depth = -view_inverse.xform(end_lead).z;
		knots[count++] = view.xform(Vector3(portal.x * depth / front_depth, portal.y * depth / front_depth, -depth));
	}
	knots[count++] = end_lead;
	knots[count++] = p_end;
	if (smooth(knots, count, p_source, p_target, r_points, r_count, true)) { return true; }
	// A scene target may be behind the graph: keep the front corridor, route only its tail in 3D.
	if (p_target < 0) {
		std::array<Vector3, MAX_POINTS> tail;
		int tail_count = 0;
		if (smooth(knots, count - 3, p_source, p_target, r_points, r_count, true) && route_world(knots[count - 4], Vector3(), p_end, p_end_normal, p_source, p_target, tail, tail_count) && r_count + tail_count - 1 <= MAX_POINTS) {
			for (int k = 1; k < tail_count; k++) { r_points[r_count++] = tail[k]; }
			return true;
		}
	}
	r_count = 0;
	return false;
}

bool XREWireRouter::route_world(const Vector3 &p_start, const Vector3 &p_start_normal, const Vector3 &p_end, const Vector3 &p_end_normal, int64_t p_source, int64_t p_target, std::array<Vector3, MAX_POINTS> &r_points, int &r_count) const {
	r_count = 0;
	if (!p_start.is_finite() || !p_end.is_finite()) { return false; }
	std::array<Vector3, MAX_KNOTS> knots;
	const real_t stub = std::min(STUB, p_start.distance_to(p_end) * 0.25f);
	knots[0] = p_start;
	real_t start_stub = stub;
	real_t end_stub = stub;
	// Terminals can face a nearby neighbour: shorten the stem before it enters any body.
	for (int i = 0; i < obstacle_count; i++) {
		const real_t margin = (obstacles[i].id == p_source || obstacles[i].id == p_target) ? TUBE_MARGIN : MARGIN;
		for (int endpoint = 0; endpoint < 2; endpoint++) {
			const Vector3 point = endpoint ? p_end : p_start;
			const Vector3 normal = (endpoint ? p_end_normal : p_start_normal).normalized();
			real_t &length = endpoint ? end_stub : start_stub;
			if (normal.length_squared() == 0 || !hits_obstacle(point, point + normal * length, obstacles[i], margin)) { continue; }
			real_t low = 0;
			real_t high = length;
			for (int search = 0; search < 12; search++) {
				const real_t middle = (low + high) * 0.5f;
				if (hits_obstacle(point, point + normal * middle, obstacles[i], margin)) { high = middle; }
				else { low = middle; }
			}
			length = low * 0.5f;
		}
	}
	knots[1] = p_start + p_start_normal.normalized() * start_stub;
	knots[2] = p_end + p_end_normal.normalized() * end_stub;
	knots[3] = p_end;
	int count = 4;
	AABB envelope;
	if (obstacle_count > 0) {
		envelope = obstacles[0].world_bounds;
		for (int i = 1; i < obstacle_count; i++) { envelope = envelope.merge(obstacles[i].world_bounds); }
	}
	for (int pass = 0; pass < MAX_KNOTS; pass++) {
		int segment = -1;
		int blocking = -1;
		for (int k = 1; k < count - 2 && blocking < 0; k++) {
			for (int i = 0; i < obstacle_count; i++) {
				const auto &obstacle = obstacles[i];
					const real_t margin = (obstacle.id == p_source || obstacle.id == p_target) ? TUBE_MARGIN : MARGIN;
					if (hits_obstacle(knots[k], knots[k + 1], obstacle, margin)) { segment = k; blocking = i; break; }
			}
		}
		if (blocking < 0) { break; }
		if (count + 2 > MAX_KNOTS) { return false; }
		const Vector3 start = knots[segment];
		const Vector3 end = knots[segment + 1];
		const auto &obstacle = obstacles[blocking];
		const real_t margin = (obstacle.id == p_source || obstacle.id == p_target) ? TUBE_MARGIN : MARGIN;
		const AABB bounds = obstacle.world_bounds.grow(margin);
		double best = std::numeric_limits<double>::infinity();
		Vector3 first;
		Vector3 second;
		for (int axis = 2; axis >= 0; axis--) {
			for (int side = 1; side >= 0; side--) {
				for (int global = 0; global < 2; global++) {
					const AABB area = global ? envelope.grow(MARGIN) : bounds;
					const real_t plane = side ? area.get_end()[axis] + DETOUR : area.position[axis] - DETOUR;
					Vector3 a = start;
					Vector3 b = end;
					a[axis] = plane;
					b[axis] = plane;
					if (hits_obstacle(start, a, obstacle, margin) || hits_obstacle(a, b, obstacle, margin) || hits_obstacle(b, end, obstacle, margin)) { continue; }
					const int hits = collisions(start, a, p_source, p_target) + collisions(a, b, p_source, p_target) + collisions(b, end, p_source, p_target);
					const double score = start.distance_to(a) + a.distance_to(b) + b.distance_to(end) + hits * 1000.0;
					if (score < best) { best = score; first = a; second = b; }
				}
			}
		}
		if (!std::isfinite(best)) { return false; }
		for (int k = count - 1; k > segment; k--) { knots[k + 2] = knots[k]; }
		knots[segment + 1] = first;
		knots[segment + 2] = second;
		count += 2;
	}
	return smooth(knots, count, p_source, p_target, r_points, r_count);
}

bool XREWireRouter::smooth(const std::array<Vector3, MAX_KNOTS> &p_knots, int p_count, int64_t p_source, int64_t p_target, std::array<Vector3, MAX_POINTS> &r_points, int &r_count, bool p_view) const {
	r_count = 0;
	r_points[r_count++] = p_knots[0];
	Vector3 cursor = p_knots[0];
	for (int k = 1; k < p_count; k++) {
		Vector3 entry = p_knots[k];
		Vector3 exit = entry;
		if (k < p_count - 1) {
			const real_t radius = std::min(ROUND, std::min(p_knots[k].distance_to(p_knots[k - 1]), p_knots[k].distance_to(p_knots[k + 1])) * 0.25f);
			entry += (p_knots[k - 1] - p_knots[k]).normalized() * radius;
			exit += (p_knots[k + 1] - p_knots[k]).normalized() * radius;
		}
		Vector3 control = (cursor + entry) * 0.5f;
		if (!p_view && k > 1 && k < p_count - 1 && cursor.distance_to(entry) > 0.08) {
			const Vector3 span = entry - cursor;
			Vector3 bow = Vector3(0, 0, 0.02f);
			if (std::abs(span.normalized().z) > 0.9) { bow = Vector3(0, 0.02f, 0); }
			Vector3 previous = cursor;
			bool safe = true;
			for (int j = 1; j <= 4; j++) {
				const Vector3 next = quadratic(cursor, control + bow, entry, j / 4.0f);
				if (collisions(previous, next, p_source, p_target, true) > 0) { safe = false; break; }
				previous = next;
			}
			if (safe) { control += bow; }
		}
		for (int j = 1; j <= 3; j++) { r_points[r_count++] = quadratic(cursor, control, entry, j / 3.0f); }
		if (k < p_count - 1) {
			for (int j = 1; j <= 4; j++) { r_points[r_count++] = quadratic(entry, p_knots[k], exit, j / 4.0f); }
		}
		cursor = exit;
	}
	for (int i = 0; i < r_count - 1; i++) {
		if (collisions(r_points[i], r_points[i + 1], p_source, p_target, true) > 0) { r_count = 0; return false; }
	}
	return true;
}

XREGraphWire::XREGraphWire() {
	wire_mesh.instantiate();
	PackedVector3Array vertices;
	vertices.resize(XREWireRouter::MAX_POINTS * 4);
	PackedInt32Array indices;
	indices.resize((XREWireRouter::MAX_POINTS - 1) * 24);
	int32_t *data = indices.ptrw();
	int cursor = 0;
	for (int i = 0; i < XREWireRouter::MAX_POINTS - 1; i++) {
		for (int side = 0; side < 4; side++) {
			const int a = i * 4 + side;
			const int b = i * 4 + (side + 1) % 4;
			const int c = a + 4;
			const int d = b + 4;
			data[cursor++] = a; data[cursor++] = b; data[cursor++] = c;
			data[cursor++] = b; data[cursor++] = d; data[cursor++] = c;
		}
	}
	Array arrays;
	arrays.resize(Mesh::ARRAY_MAX);
	arrays[Mesh::ARRAY_VERTEX] = vertices;
	arrays[Mesh::ARRAY_INDEX] = indices;
	wire_mesh->add_surface_from_arrays(Mesh::PRIMITIVE_TRIANGLES, arrays, Array(), Dictionary(), Mesh::ARRAY_FLAG_USE_DYNAMIC_UPDATE);
	vertex_bytes.resize(XREWireRouter::MAX_POINTS * 4 * 3 * sizeof(float));
}

void XREGraphWire::_bind_methods() {
	ClassDB::bind_method(D_METHOD("update_route", "router", "start", "start_normal", "end", "end_normal", "source", "target"), &XREGraphWire::update_route);
	ClassDB::bind_method(D_METHOD("get_point_count"), &XREGraphWire::get_point_count);
	ClassDB::bind_method(D_METHOD("get_point", "index"), &XREGraphWire::get_point);
	ClassDB::bind_method(D_METHOD("is_routed"), &XREGraphWire::is_routed);
}

void XREGraphWire::update_route(const Ref<XREWireRouter> &p_router, const Vector3 &p_start, const Vector3 &p_start_normal, const Vector3 &p_end, const Vector3 &p_end_normal, int64_t p_source, int64_t p_target) {
	if (get_mesh().is_null()) { set_mesh(wire_mesh); }
	if (p_router == last_router && p_router.is_valid() && last_revision == p_router->get_revision() && last_start == p_start && last_start_normal == p_start_normal && last_end == p_end && last_end_normal == p_end_normal && last_source == p_source && last_target == p_target) {
		set_visible(routed);
		return;
	}
	last_router = p_router;
	last_revision = p_router.is_valid() ? p_router->get_revision() : 0;
	last_start = p_start; last_start_normal = p_start_normal;
	last_end = p_end; last_end_normal = p_end_normal;
	last_source = p_source; last_target = p_target;
	routed = p_router.is_valid() && p_router->route(p_start, p_start_normal, p_end, p_end_normal, p_source, p_target, points, point_count, route_side);
	set_visible(routed);
	if (!routed) { return; }
	uint8_t *bytes = vertex_bytes.ptrw();
	AABB bounds(points[0], Vector3());
	Vector3 previous_side;
	for (int i = 0; i < XREWireRouter::MAX_POINTS; i++) {
		const int index = std::min(i, point_count - 1);
		const Vector3 point = points[index];
		Vector3 tangent = points[std::min(point_count - 1, index + 1)] - points[std::max(0, index - 1)];
		if (tangent.length_squared() < 0.00000001) { tangent = Vector3(1, 0, 0); }
		tangent.normalize();
		const Vector3 up = std::abs(tangent.y) > 0.9 ? Vector3(1, 0, 0) : Vector3(0, 1, 0);
		Vector3 side = previous_side - tangent * previous_side.dot(tangent);
		if (side.length_squared() < 0.00000001) { side = tangent.cross(up); }
		side = side.normalized() * RADIUS;
		previous_side = side;
		const Vector3 vertical = side.cross(tangent).normalized() * RADIUS;
		for (int corner = 0; corner < 4; corner++) {
			const Vector3 vertex = i >= point_count ? point : point + side * (corner < 2 ? -1.0f : 1.0f) + vertical * ((corner == 0 || corner == 3) ? -1.0f : 1.0f);
			bounds.expand_to(vertex);
			const float packed[3] = { static_cast<float>(vertex.x), static_cast<float>(vertex.y), static_cast<float>(vertex.z) };
			std::memcpy(bytes + (i * 4 + corner) * 3 * sizeof(float), packed, sizeof(packed));
		}
	}
	set_custom_aabb(bounds.grow(RADIUS));
	wire_mesh->surface_update_vertex_region(0, 0, vertex_bytes);
}

int XREGraphWire::get_point_count() const { return point_count; }
Vector3 XREGraphWire::get_point(int p_index) const { ERR_FAIL_INDEX_V(p_index, point_count, Vector3()); return points[p_index]; }
bool XREGraphWire::is_routed() const { return routed; }

} // namespace xre
