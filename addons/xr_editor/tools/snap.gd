@tool
class_name XRESnap
extends RefCounted
## Snap steps for moving, rotating and scaling, and the math that applies them.
##
## The desktop editor snaps how far a node moved; this snaps where it ends up.
## Position and rotation go to an absolute grid in the parent's space, so the
## saved values are whole steps whatever the node started from
## (docs/decisions.md, D-008). Scale is snapped as a factor of the scale the
## node had when the drag began, so non-uniform scales keep their proportions.

## Whether snapping is on before the user inverts it.
var enabled: bool
## Grid step in the parent's units (meters under an unscaled parent); 0 is off.
var translate_step: float
## Step of each Euler angle, in degrees; 0 is off.
var rotate_step: float
## Step of the scale factor, in percent; 0 is off.
var scale_step: float


func _init(snap_enabled: bool, translate: float, rotate_degrees: float, scale_percent: float) -> void:
	enabled = snap_enabled
	translate_step = translate
	rotate_step = rotate_degrees
	scale_step = scale_percent


## [param xform] (a local transform) with its origin on the grid and each of
## its Euler angles (in [constant EULER_ORDER_YXZ], the order the inspector
## shows) on a whole step. Scale is kept.
func snap_transform(xform: Transform3D) -> Transform3D:
	var origin := xform.origin.snappedf(translate_step) if translate_step > 0.0 else xform.origin
	if rotate_step <= 0.0:
		return Transform3D(xform.basis, origin)
	var scale := xform.basis.get_scale()
	var rotation := xform.basis.get_rotation_quaternion().get_euler().snappedf(deg_to_rad(rotate_step))
	return Transform3D(Basis.from_euler(rotation) * Basis.from_scale(scale), origin)


## [param factor] rounded to a whole number of scale steps, never below one step.
func snap_scale_factor(factor: float) -> float:
	if scale_step <= 0.0:
		return factor
	var step := scale_step / 100.0
	return maxf(snappedf(factor, step), step)
