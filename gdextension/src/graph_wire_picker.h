#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/array.hpp>
#include <godot_cpp/variant/string_name.hpp>
#include <godot_cpp/variant/vector3.hpp>

namespace xre {

class XREGraphWire;

/// Finds the wire or knot a ray passes near among a logic graph's wires (D-169): what
/// XREBlueprintCanvas._intersect_wires, _intersect_tubes, _intersect_knots, _ray_segment and
/// _box_distance did in GDScript, in one call over all of them, with the same arithmetic and the
/// same ties. The canvas passes its lists of wires (its GDScript Wire objects) as they are; this
/// reads each one's mesh, edge, pieces, bends and knots. Allocates nothing: it runs every frame.
class XREGraphWirePicker : public godot::RefCounted {
	GDCLASS(XREGraphWirePicker, godot::RefCounted);

public:
	XREGraphWirePicker();
	/// The nearest tube of the wires of [param p_wires], [param p_variable_links] and [param p_scene_links]
	/// that the ray (the canvas's space) passes within [param p_wire_radius] of, nearer than [param p_maximum],
	/// unless a knot within [param p_knot_radius] times its scale is nearer or close behind: its distance, or -1.
	double pick(const godot::Array &p_wires, const godot::Array &p_variable_links, const godot::Array &p_scene_links,
			const godot::Vector3 &p_origin, const godot::Vector3 &p_direction, double p_maximum, double p_wire_radius, double p_knot_radius);
	/// Of the last pick: the wire's edge (-1 for none), its knot (-1 for a tube), the piece or the knot's index, the point on it.
	int get_edge() const;
	int get_bend() const;
	int get_piece() const;
	godot::Vector3 get_point() const;

protected:
	static void _bind_methods();

private:
	double tubes(const godot::Array &p_wires, const godot::Vector3 &p_origin, const godot::Vector3 &p_direction, double p_nearest, double p_radius);
	double knots(const godot::Array &p_wires, const godot::Vector3 &p_origin, const godot::Vector3 &p_direction, double p_reach, double p_nearest, double p_radius);

	godot::StringName mesh_name;
	godot::StringName edge_name;
	godot::StringName pieces_name;
	godot::StringName bends_name;
	godot::StringName knots_name;
	int edge = -1;
	int bend = -1;
	int piece = -1;
	godot::Vector3 point;
};

} // namespace xre
