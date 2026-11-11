#include "graph_wire_picker.h"

#include "graph_wire.h"

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/aabb.hpp>

#include <algorithm>
#include <cmath>
#include <limits>

using namespace godot;

namespace xre {

namespace {

// The arithmetic below is GDScript's in XREBlueprintCanvas: its vectors are single precision, its
// scalars double; a vector's component, a dot product or a length read as a scalar becomes double,
// and a scalar that scales a vector becomes single. The same conversions give the same hits.

// _ray_segment: the ray's parameter and the segment's, packed as GDScript's Vector2 packs them.
void ray_segment(const Vector3 &p_origin, const Vector3 &p_direction, const Vector3 &p_a, const Vector3 &p_b, real_t &r_t, real_t &r_s) {
	const Vector3 along = p_b - p_a;
	const Vector3 offset = p_a - p_origin;
	const double dd = p_direction.dot(p_direction);
	const double du = p_direction.dot(along);
	const double uu = along.dot(along);
	const double dw = p_direction.dot(offset);
	const double uw = along.dot(offset);
	const double denominator = dd * uu - du * du;
	double s = denominator > 1e-12 ? std::clamp((dw * du - uw * dd) / denominator, 0.0, 1.0) : 0.0;
	double t = (dw + s * du) / dd;
	if (t < 0.0) {
		// The segment lies behind the origin: its point nearest the origin.
		t = 0.0;
		s = uu > 1e-12 ? std::clamp(-uw / uu, 0.0, 1.0) : 0.0;
	}
	r_t = real_t(t);
	r_s = real_t(s);
}

// _box_distance.
double box_distance(const Vector3 &p_origin, const Vector3 &p_direction, const AABB &p_bounds, double p_maximum) {
	double near = 0.0;
	double far = p_maximum;
	const Vector3 end = p_bounds.get_end();
	for (int axis = 0; axis < 3; axis++) {
		const double direction = p_direction[axis];
		const double origin = p_origin[axis];
		if (std::abs(direction) < 0.000001) {
			if (origin < double(p_bounds.position[axis]) || origin > double(end[axis])) { return -1.0; }
			continue;
		}
		const double first = (double(p_bounds.position[axis]) - origin) / direction;
		const double second = (double(end[axis]) - origin) / direction;
		near = std::max(near, std::min(first, second));
		far = std::min(far, std::max(first, second));
		if (near > far) { return -1.0; }
	}
	return near;
}

} // namespace

XREGraphWirePicker::XREGraphWirePicker() :
		mesh_name("mesh"), edge_name("edge"), pieces_name("pieces"), bends_name("bends"), knots_name("knots"), lod_name("lod") {
}

void XREGraphWirePicker::_bind_methods() {
	ClassDB::bind_method(D_METHOD("pick", "wires", "variable_links", "scene_links", "origin", "direction", "maximum", "wire_radius", "knot_radius"), &XREGraphWirePicker::pick);
	ClassDB::bind_method(D_METHOD("get_edge"), &XREGraphWirePicker::get_edge);
	ClassDB::bind_method(D_METHOD("get_bend"), &XREGraphWirePicker::get_bend);
	ClassDB::bind_method(D_METHOD("get_piece"), &XREGraphWirePicker::get_piece);
	ClassDB::bind_method(D_METHOD("get_point"), &XREGraphWirePicker::get_point);
}

double XREGraphWirePicker::pick(const Array &p_wires, const Array &p_variable_links, const Array &p_scene_links, const Vector3 &p_origin, const Vector3 &p_direction, double p_maximum, double p_wire_radius, double p_knot_radius) {
	edge = -1;
	bend = -1;
	piece = -1;
	point = Vector3();
	double nearest = tubes(p_wires, p_origin, p_direction, p_maximum, p_wire_radius);
	nearest = tubes(p_variable_links, p_origin, p_direction, nearest, p_wire_radius);
	nearest = tubes(p_scene_links, p_origin, p_direction, nearest, p_wire_radius);
	const double reach = edge >= 0 ? std::min(nearest + p_knot_radius * 2.0, p_maximum) : p_maximum;
	constexpr double none = std::numeric_limits<double>::infinity();
	double knot = knots(p_wires, p_origin, p_direction, reach, none, p_knot_radius);
	knot = knots(p_variable_links, p_origin, p_direction, reach, knot, p_knot_radius);
	knot = knots(p_scene_links, p_origin, p_direction, reach, knot, p_knot_radius);
	if (knot < none) { return knot; }
	return edge >= 0 ? nearest : -1.0;
}

double XREGraphWirePicker::tubes(const Array &p_wires, const Vector3 &p_origin, const Vector3 &p_direction, double p_nearest, double p_radius) {
	const real_t grow = real_t(p_radius);
	const double radius_squared = p_radius * p_radius;
	for (int64_t w = 0; w < p_wires.size(); w++) {
		Object *wire = p_wires[w];
		if (wire == nullptr) { continue; }
		const XREGraphWire *mesh = Object::cast_to<XREGraphWire>(wire->get(mesh_name));
		// A wire past level 1 of detail (D-172) is not picked.
		if (mesh == nullptr || !mesh->is_visible() || int(wire->get(lod_name)) >= 2) { continue; }
		const Array pieces = wire->get(pieces_name);
		for (int64_t index = 0; index < pieces.size(); index++) {
			const XREGraphWire *tube = Object::cast_to<XREGraphWire>(pieces[index]);
			if (tube == nullptr) { continue; }
			if (box_distance(p_origin, p_direction, tube->get_custom_aabb().grow(grow), p_nearest) < 0.0) { continue; }
			const int count = tube->get_point_count();
			if (count < 2) { continue; }
			Vector3 from = tube->get_point(0);
			for (int sample = 1; sample < count; sample++) {
				const Vector3 to = tube->get_point(sample);
				real_t t = 0.0f;
				real_t s = 0.0f;
				ray_segment(p_origin, p_direction, from, to, t, s);
				const Vector3 on_wire = from.lerp(to, s);
				if (double(t) < p_nearest && double((p_origin + p_direction * t).distance_squared_to(on_wire)) <= radius_squared) {
					p_nearest = t;
					edge = int(wire->get(edge_name));
					piece = int(index);
					point = on_wire;
				}
				from = to;
			}
		}
	}
	return p_nearest;
}

double XREGraphWirePicker::knots(const Array &p_wires, const Vector3 &p_origin, const Vector3 &p_direction, double p_reach, double p_nearest, double p_radius) {
	const double length_squared = p_direction.length_squared();
	for (int64_t w = 0; w < p_wires.size(); w++) {
		Object *wire = p_wires[w];
		if (wire == nullptr) { continue; }
		const XREGraphWire *mesh = Object::cast_to<XREGraphWire>(wire->get(mesh_name));
		// A wire past level 1 of detail (D-172) is not picked.
		if (mesh == nullptr || !mesh->is_visible() || int(wire->get(lod_name)) >= 2) { continue; }
		const Array knots = wire->get(knots_name);
		if (knots.is_empty()) { continue; }
		const Array bends = wire->get(bends_name);
		for (int64_t index = 0; index < knots.size(); index++) {
			const Node3D *knot = Object::cast_to<Node3D>(knots[index]);
			if (knot == nullptr || index >= bends.size()) { continue; }
			const Vector3 center = bends[index];
			const double along = std::max(double((center - p_origin).dot(p_direction)) / length_squared, 0.0);
			const double radius = p_radius * double(knot->get_scale().x);
			if (along > p_reach || along >= p_nearest || double((p_origin + p_direction * real_t(along)).distance_squared_to(center)) > radius * radius) { continue; }
			p_nearest = along;
			edge = int(wire->get(edge_name));
			bend = int(index);
			piece = int(index);
			point = center;
		}
	}
	return p_nearest;
}

int XREGraphWirePicker::get_edge() const { return edge; }
int XREGraphWirePicker::get_bend() const { return bend; }
int XREGraphWirePicker::get_piece() const { return piece; }
Vector3 XREGraphWirePicker::get_point() const { return point; }

} // namespace xre
