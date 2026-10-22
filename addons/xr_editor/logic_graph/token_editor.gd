@tool
class_name XREBlueprintTokenEditor
extends Node3D
## The input of a token, around the token itself (D-052), as the concept
## draws it: a number turned by the wrist shows a dial of ticks, one per step,
## the current one white, and its value large above; a choice turned so shows
## its values on an arc, the current one white; a color shows a ring of hues
## and a bar of brightness that the ray picks; a vector shows arrows along
## X, Y and Z, each pulled along its axis to change one component. Built when
## an edit starts, moved and lit while it lasts; picked analytically.
##
## It is drawn over everything — scene, cards, windows — with no depth test
## (D-058). The ring and the arrows stand on a dark plate with a × at its
## corner: the grip on the plate moves them, the × or the trigger anywhere
## else closes them, so that what they cover is never out of reach.

const DIAL := &"dial"
const CHOICE := &"choice"
const RING := &"ring"
const ARROWS := &"arrows"
## A line of help over a token under the ray: how it is edited.
const HINT := &"hint"
## The number line (D-062): half its length, how far above the token, how far
## apart one step's ticks are, the ticks and figures it has, how fast past an
## end the value goes on (units a second per meter beyond), how near a whole
## number it stops at it.
const LINE_HALF := 0.12
const LINE_LIFT := 0.05
const LINE_STEP_GAP := 0.012
const LINE_TICKS := 24
const LINE_FIGURES := 4
const LINE_SPEED := 20.0
const LINE_DETENT := 0.04
## How near a value on the arc of a choice the ray picks it.
const CHOICE_PICK := 0.035
## The hue ring: segments, radius and the band the ray picks in; the brightness bar's size.
const SEGMENTS := 24
const RING_RADIUS := 0.085
const RING_BAND := 0.016
const BAR_SIZE := Vector2(0.014, 0.15)
const SHADES := 10
## The arrows are drawn to one scale (D-061): an axis arrow is its component
## long, the white one is the vector, so that they change together. The
## largest component is [constant ARROW_LENGTH] long when the arrows open
## (one unit at most that); an arrow is drawn at least [constant ARROW_STUB]
## long to be taken; past [constant ARROW_MAX] (the white arrow: past
## [constant VECTOR_MAX]) the scale shrinks instead. The ray picks an arrow
## [constant ARROW_PICK] from its axis.
const ARROW_LENGTH := 0.12
const ARROW_STUB := 0.015
const ARROW_MAX := 0.2
const VECTOR_MAX := 0.24
const ARROW_PICK := 0.022
## The white arrow of the whole vector: its index among the arrows.
const VECTOR_AXIS := 3
## Pulled past its longest, an arrow goes on growing its value: this many
## units a second per meter beyond, times the value's size once past 1, and
## faster the longer it is held there, by this much a second (D-060).
const OVER_SPEED := 40.0
const OVER_ACCEL := 1.5
## The scale along a pulled arrow: a tick at every step of a 1-2-5 series,
## at least [constant GRID_GAP] apart, longer every tenth tick and at zero.
const GRID_GAP := 0.012
const GRID_TICKS := 24
## How much a pulled arrow changes its component, per meter of pull: a tenth per 2 cm.
const ARROW_GAIN := 5.0
## A pulled component this near a whole number stops at it, so that 0 and 1 are easy to hit.
const DETENT := 0.15
## Arrows stand this far in front of their token, towards the head, clear of the card.
const ARROW_LIFT := 0.14
const AXIS_COLORS: Array[Color] = [Color("ff6b6b"), Color("7be5b3"), Color("89adff")]
const IDLE := Color("7d8597")
## Sorted as if this much nearer than it is: drawn after everything else that
## is transparent, after a window drawn over everything too (its offset is 100).
const ON_TOP_OFFSET := 150.0
const PLATE_COLOR := Color(0.07, 0.09, 0.12, 0.82)
## The radius of the × at the plate's corner and how far the ray picks it.
const CLOSE_RADIUS := 0.014

var mode := &""
var _ticks: Array[MeshInstance3D] = []
var _figures: Array[Label3D] = []
var _marker: MeshInstance3D
var _line_center := 0.0
var _line_scale := 0.12
var _line_step := 0.1
var _line_shown := 0.0
var _line_value := 0.0
var _line_integer := false
## The least value the line goes to, or NAN (D-063): zero for a Delay.
var _line_minimum := NAN
var _value: Label3D
var _choices: Array[Label3D] = []
var _segments: Array[MeshInstance3D] = []
var _shades: Array[MeshInstance3D] = []
var _arrows: Array[Node3D] = []
var _axes: Array[Vector3] = []
var _lit := -1
var _idle_material: Material
var _hot_material: Material
var _lit_white: StandardMaterial3D
## The plate of the ring or the arrows, its size, and its ×; null without one.
var _plate: MeshInstance3D
var _plate_size := Vector2.ZERO
var _close: Node3D
var _close_disc: MeshInstance3D
var _close_idle: StandardMaterial3D
var _close_hot: StandardMaterial3D
## The value the arrows make, large over their plate, followed while one is pulled (D-059).
var _readout: Label3D
## Each arrow's own material, given back when it is no longer lit.
var _arrow_materials: Array[Material] = []
## The vector the arrows edit, each arrow's shaft, head and number, its length,
## and the grid of the pulled one (D-060).
var _vector: Variant
var _shafts: Array[MeshInstance3D] = []
var _heads: Array[MeshInstance3D] = []
var _numbers: Array[Label3D] = []
var _lengths: Array[float] = []
var _grid: Array[MeshInstance3D] = []
var _grid_axis := -1
## Meters per unit of the arrows' one scale, and what it was when a pull began.
var _scale := ARROW_LENGTH
var _scale_start := ARROW_LENGTH
## A pull: the component, or the white arrow's tip, when it began; how long it
## has been held past the end; the value it reached there.
var _start_length := 0.0
var _over_time := 0.0
var _tip_start := Vector3.ZERO
var _grab := Vector3.ZERO
var _vector_start: Variant
## The window the arrows stand in front of (D-062): X along its right, Y up
## it, Z out of it toward the user, slanted down and left so that it is seen.
var _frame := Basis.IDENTITY
## How far before the token, toward the head, the number line and a choice
## stand, and how far above it, clear of the card (D-062).
const WIDGET_LEAD := 0.06
## The white arrow's reach past its end, in meters at the scale its pull began.
var _reach := 0.0


func _init() -> void:
	name = "TokenEditor"
	top_level = true
	visible = false
	_idle_material = XREBlueprintCanvas.material(IDLE, true)
	_hot_material = XREBlueprintCanvas.material(Color.WHITE, true)
	_lit_white = XREBlueprintCanvas.material(Color("f2d878"), true)
	_lit_white.no_depth_test = true


## Whether an input is shown.
func is_open() -> bool:
	return visible and not mode.is_empty()


## Closes the input.
func close() -> void:
	_clear()
	mode = &""
	visible = false


func _clear() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	_ticks.clear()
	_figures.clear()
	_marker = null
	_choices.clear()
	_segments.clear()
	_shades.clear()
	_arrows.clear()
	_axes.clear()
	_value = null
	_plate = null
	_close = null
	_close_disc = null
	_readout = null
	_arrow_materials.clear()
	_shafts.clear()
	_heads.clear()
	_numbers.clear()
	_lengths.clear()
	_grid.clear()
	_grid_axis = -1
	_plate_size = Vector2.ZERO
	_lit = -1


## Draws every part over everything: no depth test, sorted last (D-058).
func _raise(node: Node) -> void:
	for child: Node in node.get_children():
		if child is GeometryInstance3D: (child as GeometryInstance3D).sorting_offset = ON_TOP_OFFSET
		if child is Label3D: (child as Label3D).no_depth_test = true
		elif child is MeshInstance3D:
			var material := (child as MeshInstance3D).material_override as BaseMaterial3D
			if material != null: material.no_depth_test = true
		_raise(child)
	# The plate under the rest of the widget, the rest still over everything else.
	if node == self and _plate != null: _plate.sorting_offset = ON_TOP_OFFSET - 1.0


## A dark plate of [param size] behind the widget, in the plane of [param basis]
## (global) at the widget's origin, with a × at its top right corner.
func _add_plate(size: Vector2, basis: Basis) -> void:
	var quad := QuadMesh.new()
	quad.size = size
	_plate = XRERig.create_vr_mesh(quad, XREBlueprintCanvas.material(PLATE_COLOR, true))
	add_child(_plate)
	_plate.global_basis = basis.orthonormalized()
	_plate.position = _plate.basis.z * -0.004
	_plate_size = size
	_close = Node3D.new()
	add_child(_close)
	_close.global_basis = basis.orthonormalized()
	_close.position = _close.basis * Vector3(size.x * 0.5 - CLOSE_RADIUS * 1.4, size.y * 0.5 - CLOSE_RADIUS * 1.4, 0.002)
	var disc := CylinderMesh.new()
	disc.top_radius = CLOSE_RADIUS
	disc.bottom_radius = CLOSE_RADIUS
	disc.height = 0.002
	_close_idle = XREBlueprintCanvas.material(Color("39414f"), true)
	_close_hot = XREBlueprintCanvas.material(Color("e8879b"), true)
	_close_idle.no_depth_test = true
	_close_hot.no_depth_test = true
	_close_disc = XRERig.create_vr_mesh(disc, _close_idle)
	_close_disc.rotation.x = PI * 0.5
	_close.add_child(_close_disc)
	var cross := XREBlueprintCanvas.label("×", 30)
	cross.position.z = 0.002
	_close.add_child(cross)


## The number line of a number held by the trigger (D-062, after D-052's dial):
## a ruler across the token at [param pose], with a tick every tenth (every
## unit for an [param integer]) and figures at the long ones, and a marker at
## the value, the value large above it. The ray along the line moves the
## marker and the value ([method line_to]); held past an end the value goes
## on, faster and faster, the ruler sliding under the marker. The wrist and
## the stick step it too ([method nudge]). The value goes no lower than
## [param minimum] (NAN: no bound): the line stops there (D-063).
func open_dial(pose: Transform3D, value: Variant, minimum: float = NAN) -> void:
	_clear()
	mode = DIAL
	_line_minimum = minimum
	global_transform = Transform3D(pose.basis, pose.origin + pose.basis.z.normalized() * WIDGET_LEAD)
	_line_integer = value is int
	_line_step = 1.0 if _line_integer else 0.1
	_line_scale = LINE_STEP_GAP / _line_step
	_line_center = float(value)
	_line_shown = 0.0
	_line_value = float(value)
	_over_time = 0.0
	var line := BoxMesh.new()
	line.size = Vector3(LINE_HALF * 2.0, 0.002, 0.002)
	var bar := XRERig.create_vr_mesh(line, _idle_material)
	bar.position = Vector3(0, LINE_LIFT, 0.01)
	add_child(bar)
	var minor := BoxMesh.new()
	minor.size = Vector3(0.0015, 0.008, 0.0015)
	var major := BoxMesh.new()
	major.size = Vector3(0.0025, 0.016, 0.0025)
	for index: int in LINE_TICKS:
		var tick := XRERig.create_vr_mesh(minor, _idle_material)
		tick.set_meta(&"minor", minor)
		tick.set_meta(&"major", major)
		add_child(tick)
		_ticks.append(tick)
	for index: int in LINE_FIGURES:
		var figure := XREBlueprintCanvas.label("", 14)
		figure.modulate = Color("a9b0bf")
		add_child(figure)
		_figures.append(figure)
	var pin := BoxMesh.new()
	pin.size = Vector3(0.004, 0.03, 0.004)
	_marker = XRERig.create_vr_mesh(pin, _hot_material)
	add_child(_marker)
	_value = XREBlueprintCanvas.label("", 30)
	add_child(_value)
	var hint := XREBlueprintCanvas.label("move the ray ← → along the line  ·  past its end it speeds up  ·  or the wrist, the stick  ·  let go to keep", 14)
	hint.modulate = Color("a9b0bf")
	hint.position = Vector3(0, LINE_LIFT - 0.035, 0.01)
	add_child(hint)
	_show_line()
	_raise(self)
	visible = true


## Moves the marker to [param offset] meters along the line from where the
## trigger took the token, [param delta] seconds after the last move; returns
## the value. Past an end the marker stays there and the value goes on, this
## many units a second per meter beyond, times its size once past 1, faster the
## longer it is held there.
func line_to(offset: float, delta: float) -> Variant:
	var over := absf(offset) - LINE_HALF
	if over > 0.0:
		_over_time += delta
		_line_center += signf(offset) * over * LINE_SPEED * maxf(absf(_line_center), 1.0) * (1.0 + _over_time * OVER_ACCEL) * delta
	else: _over_time = 0.0
	_line_shown = clampf(offset, -LINE_HALF, LINE_HALF)
	return _line_settle(over <= 0.0)


## Steps the value by [param steps] of the line, the marker where it is: the wrist's and the stick's steps.
func nudge(steps: int) -> Variant:
	_line_center += steps * _line_step
	return _line_settle(true)


func _line_settle(detent: bool) -> Variant:
	if not is_nan(_line_minimum):
		# The ruler stops with its least value under the marker: held past the end it doesn't run on.
		_line_center = maxf(_line_center, _line_minimum - _line_shown / _line_scale)
	var value := _line_center + _line_shown / _line_scale
	if _line_integer: value = roundf(value)
	else:
		value = snappedf(value, _line_step)
		if detent and absf(value - roundf(value)) <= LINE_DETENT: value = roundf(value)
	if not is_nan(_line_minimum): value = maxf(value, _line_minimum)
	_line_value = value
	_show_line()
	return int(value) if _line_integer else value


## The value the line shows now.
func get_line_value() -> Variant:
	return int(_line_value) if _line_integer else _line_value


## The ruler under the marker: a tick at every step of the value around the
## line's middle, long ones every ten steps with their figures.
func _show_line() -> void:
	var first := ceilf((_line_center - LINE_HALF / _line_scale) / _line_step)
	var figure := 0
	for index: int in _ticks.size():
		var tick := _ticks[index]
		var at := (first + index) * _line_step
		var x := (at - _line_center) * _line_scale
		tick.visible = absf(x) <= LINE_HALF + 0.0001
		if not tick.visible: continue
		var whole := absi(roundi(first + index)) % 10 == 0
		tick.mesh = tick.get_meta(&"major") if whole else tick.get_meta(&"minor")
		tick.position = Vector3(x, LINE_LIFT + (0.004 if whole else 0.0), 0.01)
		if whole and figure < _figures.size():
			_figures[figure].text = XREBlueprintTokens.text(roundi(at) if _line_integer else snappedf(at, _line_step), "")
			_figures[figure].position = Vector3(x, LINE_LIFT - 0.018, 0.01)
			_figures[figure].visible = true
			figure += 1
	for index: int in range(figure, _figures.size()): _figures[index].visible = false
	_marker.position = Vector3(_line_shown, LINE_LIFT, 0.012)
	_value.text = XREBlueprintTokens.text(int(_line_value) if _line_integer else _line_value, "")
	_value.position = Vector3(_line_shown, LINE_LIFT + 0.04, 0.012)


## A line of help [param text] over the token at [param pose], for a token under the ray.
func show_hint(pose: Transform3D, text: String) -> void:
	if mode == HINT and _value != null and _value.text == text and global_position.is_equal_approx(pose.origin): return
	_clear()
	mode = HINT
	global_transform = pose
	_value = XREBlueprintCanvas.label(text, 15)
	_value.modulate = Color("dfe4ee")
	_value.position = Vector3(0, 0.026, 0.012)
	add_child(_value)
	_raise(self)
	visible = true


## The values of a choice on an arc above the token at [param pose], [param current] white.
func open_choice(pose: Transform3D, choices: Array[String], current: String) -> void:
	_clear()
	mode = CHOICE
	global_transform = Transform3D(pose.basis, pose.origin + pose.basis.z.normalized() * WIDGET_LEAD)
	for index: int in choices.size():
		var angle := PI * (5.0 / 6.0) - index * PI * (2.0 / 3.0) / maxf(choices.size() - 1, 1)
		var text := XREBlueprintCanvas.label(choices[index], 20)
		text.position = Vector3(cos(angle) * 0.08, sin(angle) * 0.07 + 0.01, 0.01)
		add_child(text)
		_choices.append(text)
	var knob := CylinderMesh.new()
	knob.top_radius = 0.02
	knob.bottom_radius = 0.02
	knob.height = 0.01
	var mesh := XRERig.create_vr_mesh(knob, XREBlueprintCanvas.material(XREBlueprintCanvas.TOKEN_FACE, true))
	mesh.rotation.x = PI * 0.5
	mesh.position = Vector3(0, 0.035, 0.008)
	add_child(mesh)
	set_choice(current, choices)
	_raise(self)
	visible = true


## Lights [param current] among [param choices].
func set_choice(current: String, choices: Array[String]) -> void:
	for index: int in _choices.size():
		var chosen := index < choices.size() and choices[index] == current
		_choices[index].modulate = Color.WHITE if chosen else IDLE
		_choices[index].scale = Vector3.ONE * (1.25 if chosen else 1.0)


## The choice the ray from [param origin] along [param direction] is on, or -1:
## the nearest within [constant CHOICE_PICK] of a value on the arc (D-062).
func choice_at(origin: Vector3, direction: Vector3) -> int:
	if mode != CHOICE: return -1
	var at := _on_plane(global_transform, origin, direction)
	if at.is_empty(): return -1
	var point: Vector3 = at["point"]
	var best := -1
	var nearest := CHOICE_PICK
	for index: int in _choices.size():
		var gap := Vector2(point.x - _choices[index].position.x, point.y - _choices[index].position.y).length()
		if gap < nearest:
			nearest = gap
			best = index
	return best


## The ring of hues around the token at [param pose] and the bar of brightness beside it.
func open_ring(pose: Transform3D, color: Color) -> void:
	_clear()
	mode = RING
	global_transform = pose
	for index: int in SEGMENTS:
		var angle := TAU * index / SEGMENTS
		var segment := BoxMesh.new()
		segment.size = Vector3(TAU * RING_RADIUS / SEGMENTS + 0.001, RING_BAND, 0.003)
		var mesh := XRERig.create_vr_mesh(segment, XREBlueprintCanvas.material(Color.from_hsv(float(index) / SEGMENTS, 0.75, 0.95), true))
		mesh.position = Vector3(cos(angle), sin(angle), 0) * RING_RADIUS
		mesh.rotation.z = angle + PI * 0.5
		add_child(mesh)
		_segments.append(mesh)
	for index: int in SHADES:
		var shade := QuadMesh.new()
		shade.size = Vector2(BAR_SIZE.x, BAR_SIZE.y / SHADES)
		var value := 1.0 - float(index) / (SHADES - 1)
		var mesh := XRERig.create_vr_mesh(shade, XREBlueprintCanvas.material(Color.from_hsv(color.h, color.s, value), true))
		mesh.position = Vector3(RING_RADIUS + 0.04, BAR_SIZE.y * 0.5 - (index + 0.5) * BAR_SIZE.y / SHADES, 0)
		add_child(mesh)
		_shades.append(mesh)
	var plate := Vector2(RING_RADIUS * 2.0 + 0.1, RING_RADIUS * 2.0 + 0.07)
	_add_plate(plate, pose.basis)
	_plate.position += _plate.basis.x * 0.02
	_close.position += _close.basis.x * 0.02
	_raise(self)
	visible = true


## The arrows of a vector token [param value] (D-060, D-061), at
## [param pose]'s origin, facing it: X, Y and, for a Vector3, Z, each its
## component long in one scale and its number at its tip, and a white arrow of
## the whole vector, the three arrows added up. They hang in front of the
## Vector window ([XREBlueprintVectorTab]), which moves and closes them. Pulled
## by its end an axis arrow grows or shrinks, or flips through zero; held past
## its longest the value goes on, faster and faster, the scale shrinking along
## the sliding ticks. The white arrow's tip goes with the hand, every component
## with it, and speeds on so too.
func open_arrows(pose: Transform3D, axes: int, value: Variant = Vector3.ZERO) -> void:
	_clear()
	mode = ARROWS
	global_transform = Transform3D(Basis.IDENTITY, pose.origin)
	_vector = value
	var facing := pose.basis.orthonormalized()
	_frame = facing
	_readout = XREBlueprintCanvas.label(XREBlueprintTokens.text(value, ""), 30)
	add_child(_readout)
	_readout.global_basis = facing
	_readout.position = facing * Vector3(0.0, ARROW_MAX + 0.05, 0.002)
	for axis: int in 3: _add_arrow(AXIS_COLORS[axis], axis_direction(axis))
	_arrows[2].visible = axes == 3
	_add_arrow(Color.WHITE, Vector3.UP)
	var unit := XREBlueprintCanvas.material(Color(1, 1, 1, 0.75), true)
	var minor := BoxMesh.new()
	minor.size = Vector3(0.012, 0.0015, 0.0015)
	var major := BoxMesh.new()
	major.size = Vector3(0.026, 0.0025, 0.0025)
	for index: int in GRID_TICKS:
		var tick := XRERig.create_vr_mesh(minor, unit)
		tick.set_meta(&"minor", minor)
		tick.set_meta(&"major", major)
		tick.visible = false
		add_child(tick)
		_grid.append(tick)
	_fit()
	_show()
	_raise(self)
	visible = true


## Moves the arrows to [param origin], their axes those of a window facing as
## [param facing]: the Vector window carries them, and turns them with it.
func place(origin: Vector3, facing: Basis) -> void:
	global_position = origin
	if not facing.is_equal_approx(_frame):
		_frame = facing
		_show()
	if _readout != null:
		_readout.global_basis = facing
		_readout.global_position = origin + facing * Vector3(0.0, ARROW_MAX + 0.05, 0.002)


## One arrow along [param direction] in [param color]: a shaft of unit length
## scaled to the arrow's, a head at its tip and its number beyond.
func _add_arrow(color: Color, direction: Vector3) -> void:
	var arrow := Node3D.new()
	var shaft := CylinderMesh.new()
	shaft.top_radius = 0.0025
	shaft.bottom_radius = 0.0025
	shaft.height = 1.0
	var head := CylinderMesh.new()
	head.top_radius = 0.0
	head.bottom_radius = 0.009
	head.height = 0.022
	var material := XREBlueprintCanvas.material(color, true)
	_arrow_materials.append(material)
	var shaft_mesh := XRERig.create_vr_mesh(shaft, material)
	arrow.add_child(shaft_mesh)
	var head_mesh := XRERig.create_vr_mesh(head, material)
	arrow.add_child(head_mesh)
	var number := XREBlueprintCanvas.label("", 18)
	number.modulate = color
	number.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arrow.add_child(number)
	arrow.basis = _along(direction)
	add_child(arrow)
	_arrows.append(arrow)
	_axes.append(direction)
	_shafts.append(shaft_mesh)
	_heads.append(head_mesh)
	_numbers.append(number)
	_lengths.append(ARROW_LENGTH)


static func _along(direction: Vector3) -> Basis:
	var unit := direction.normalized()
	if unit.is_equal_approx(Vector3.UP): return Basis.IDENTITY
	if unit.is_equal_approx(Vector3.DOWN): return Basis(Vector3.RIGHT, PI)
	return Basis(Quaternion(Vector3.UP, unit))


## Points arrow [param index] along [param direction], [param length] long (drawn at least a stub).
func _set_arrow(index: int, direction: Vector3, length: float) -> void:
	var shown := maxf(length, ARROW_STUB)
	_axes[index] = direction.normalized() if direction.length() > 0.000001 else Vector3.UP
	_arrows[index].basis = _along(_axes[index])
	_lengths[index] = shown
	_shafts[index].scale = Vector3(1.0, shown, 1.0)
	_shafts[index].position = Vector3(0, shown * 0.5, 0)
	_heads[index].position = Vector3(0, shown + 0.011, 0)
	_numbers[index].position = Vector3(0, shown + 0.04, 0)


## The scale at which the largest component is [constant ARROW_LENGTH] long, one unit at most that.
func _fit() -> void:
	var largest := 0.0
	for axis: int in _axis_count(): largest = maxf(largest, absf(float(_vector[axis])))
	_scale = ARROW_LENGTH / maxf(largest, 1.0)


## Every arrow as the vector and the scale are: each axis arrow its component
## long, pointing the way its sign says, the white one the vector, numbers at
## their tips, the readout above.
func _show() -> void:
	var sum := Vector3.ZERO
	for axis: int in _axis_count():
		var component := float(_vector[axis])
		var direction := axis_direction(axis) * (-1.0 if component < 0.0 else 1.0)
		_set_arrow(axis, direction, absf(component) * _scale)
		_numbers[axis].text = "%s %s" % [["X", "Y", "Z"][axis], XREBlueprintTokens.text(component, "")]
		sum += axis_direction(axis) * component * _scale
	_set_arrow(VECTOR_AXIS, sum if sum.length() > 0.000001 else Vector3(1, 1, 1 if _axis_count() == 3 else 0), sum.length())
	_numbers[VECTOR_AXIS].text = ""
	if _readout != null: _readout.text = XREBlueprintTokens.text(_vector, "")


func _axis_count() -> int:
	return 2 if _vector is Vector2 else 3


static func _as_vector3(value: Variant) -> Vector3:
	if value is Vector2: return Vector3((value as Vector2).x, (value as Vector2).y, 0.0)
	return value as Vector3 if value is Vector3 else Vector3.ZERO


func _from_vector3(value: Vector3) -> Variant:
	return Vector2(value.x, value.y) if _vector is Vector2 else value


## The vector the arrows edit now.
func get_vector() -> Variant:
	return _vector


## Meters per unit the arrows are drawn at.
func get_arrow_scale() -> float:
	return _scale


## Shows [param value] as the vector the arrows edit, refitting the scale if
## the arrows would be too long or too short to read.
func set_vector(value: Variant) -> void:
	_vector = value
	if mode != ARROWS: return
	var longest := 0.0
	for axis: int in _axis_count(): longest = maxf(longest, absf(float(_vector[axis])) * _scale)
	if longest > ARROW_MAX or longest < ARROW_LENGTH * 0.25: _fit()
	_show()
	_hide_grid()


## The direction of axis [param axis] of the arrows (0 for X): the window's
## right, its up, and out of it toward the user, slanted (D-062).
func axis_direction(axis: int) -> Vector3:
	match axis:
		0: return _frame.x.normalized()
		1: return _frame.y.normalized()
	return (_frame.z.normalized() * 0.8 - _frame.x.normalized() * 0.45 - _frame.y.normalized() * 0.35).normalized()


func _axes_basis() -> Basis:
	return Basis(axis_direction(0), axis_direction(1), axis_direction(2))


## Starts a pull of axis arrow [param axis] (or the white arrow, [constant VECTOR_AXIS], taken at [param grab]).
func begin_pull(axis: int, grab: Vector3 = Vector3.ZERO) -> void:
	_scale_start = _scale
	_over_time = 0.0
	if axis == VECTOR_AXIS:
		_grab = grab
		_tip_start = _axes_basis() * (_as_vector3(_vector) * _scale)
		_vector_start = _vector
		_reach = 0.0
	elif axis >= 0 and axis < _axis_count():
		_start_length = float(_vector[axis]) * _scale


## Pulls axis arrow [param axis] by [param pulled] meters along its axis,
## [param delta] seconds after the last pull; returns the vector it makes.
## Within its longest the component follows the arrow, stopping at whole
## numbers, through zero to the other side; held past its longest the
## component grows on, faster the longer it is held, and the scale shrinks so
## that the arrow stays at its longest and the others shrink with it.
func pull_to(axis: int, pulled: float, delta: float) -> Variant:
	if axis < 0 or axis >= _axis_count(): return _vector
	var length := _start_length + pulled
	var component: float
	if absf(length) > ARROW_MAX:
		_over_time += delta
		var reached := maxf(absf(float(_vector[axis])), ARROW_MAX / _scale_start)
		var over := absf(length) - ARROW_MAX
		reached += over * OVER_SPEED * maxf(reached, 1.0) * (1.0 + _over_time * OVER_ACCEL) * delta
		component = signf(length) * reached
		_scale = minf(_scale_start, ARROW_MAX / absf(component))
		component = snappedf(component, _step() * 0.5)
	else:
		_over_time = 0.0
		component = snappedf(length / _scale, 0.1 if _scale > 0.05 else _step())
		if absf(component - roundf(component)) <= DETENT: component = roundf(component)
	var value: Variant = _vector
	value[axis] = component
	_vector = value
	_show()
	_update_grid(axis_direction(axis) * (-1.0 if component < 0.0 else 1.0), ARROW_MAX)
	return _vector


## Moves the white arrow's tip with the hand, now at [param point],
## [param delta] seconds after the last move: every component follows its
## axis. Past [constant VECTOR_MAX] the vector grows on along its direction,
## faster the longer it is held, the scale shrinking.
func move_to(point: Vector3, delta: float) -> Variant:
	var tip := _tip_start + (point - _grab)
	var to_components := _axes_basis().inverse()
	if _vector is Vector2:
		# In the window's plane: what the hand does along Z doesn't count.
		var flat := to_components * tip
		tip = _axes_basis() * Vector3(flat.x, flat.y, 0.0)
	var value: Vector3
	if tip.length() > VECTOR_MAX:
		# The tip stays at the end; how far it reaches grows on, at the scale the pull began.
		_over_time += delta
		_reach = maxf(_reach, VECTOR_MAX)
		var over := tip.length() - VECTOR_MAX
		_reach += over * OVER_SPEED * _scale_start * maxf(_reach / _scale_start, 1.0) * (1.0 + _over_time * OVER_ACCEL) * delta
		value = to_components * (tip.normalized() * _reach) / _scale_start
		_scale = _scale_start * VECTOR_MAX / _reach
	else:
		_over_time = 0.0
		_reach = 0.0
		value = to_components * tip / _scale
	var grain := 0.1 if _scale > 0.05 else _step() * 0.5
	_vector = _from_vector3(Vector3(snappedf(value.x, grain), snappedf(value.y, grain), snappedf(value.z, grain)))
	_show()
	_update_grid(_axes[VECTOR_AXIS], VECTOR_MAX)
	return _vector


## The step of the scale: the smallest of 0.1, 0.2, 0.5, 1, 2, 5… units at least [constant GRID_GAP] apart.
func _step() -> float:
	var step := 0.1
	var series := [1.0, 2.0, 5.0]
	var index := 0
	while step * _scale < GRID_GAP:
		index += 1
		step = pow(10.0, floorf(index / 3.0) - 1.0) * float(series[index % 3])
	return step


## The ticks of the scale along [param direction] from the foot of the
## arrows to [param reach]: one per step, longer every ten steps; they slide
## and close up as the scale shrinks.
func _update_grid(direction: Vector3, reach: float) -> void:
	var step := _step()
	var across := _along(direction).x
	for index: int in _grid.size():
		var tick := _grid[index]
		var along := (index + 1) * step * _scale
		tick.visible = along <= reach + 0.001
		if not tick.visible: continue
		tick.mesh = tick.get_meta(&"major") if (index + 1) % 10 == 0 else tick.get_meta(&"minor")
		tick.position = direction * along
		tick.basis = Basis(across, direction, across.cross(direction))


func _hide_grid() -> void:
	for tick: MeshInstance3D in _grid: tick.visible = false


## Sets component [param axis] to 0, as a click on its arrow without a pull does.
func zero(axis: int) -> Variant:
	if axis < 0 or axis >= _axis_count(): return _vector
	var value: Variant = _vector
	value[axis] = 0.0
	_vector = value
	_show()
	return _vector


## Ends a pull: the arrows show the vector at a scale that reads, the ticks go.
func end_pull() -> void:
	if mode == ARROWS: set_vector(_vector)


## What the ray picks: [code]{"hue"}[/code] on the ring, [code]{"value"}[/code]
## on the bar, [code]{"axis"}[/code] on an arrow, [code]{"close"}[/code] on the
## ×, [code]{"plate"}[/code] elsewhere on the plate, or empty; with the distance to it.
func pick(origin: Vector3, direction: Vector3) -> Dictionary:
	if not is_open(): return {}
	var picked := _pick_part(origin, direction)
	if not picked.is_empty(): return picked
	if _close != null:
		var at := _on_plane(_close.global_transform, origin, direction)
		if not at.is_empty() and Vector2((at["point"] as Vector3).x, (at["point"] as Vector3).y).length() <= CLOSE_RADIUS * 1.3:
			return {"close": true, "distance": at["distance"]}
	if _plate != null and mode != ARROWS:
		var at := _on_plane(_plate.global_transform, origin, direction)
		if not at.is_empty() and absf((at["point"] as Vector3).x) <= _plate_size.x * 0.5 and absf((at["point"] as Vector3).y) <= _plate_size.y * 0.5:
			return {"plate": true, "distance": at["distance"]}
	return {}


## Where the ray meets the plane of [param frame]: the local point and the distance, or empty.
static func _on_plane(frame: Transform3D, origin: Vector3, direction: Vector3) -> Dictionary:
	var inverse := frame.affine_inverse()
	var local_origin := inverse * origin
	var local_direction := inverse.basis * direction
	if absf(local_direction.z) < 0.000001: return {}
	var distance := -local_origin.z / local_direction.z
	if distance < 0.0: return {}
	return {"point": local_origin + local_direction * distance, "distance": distance}


## Whether the widget has a plate to be held by and closed from: the ring.
func has_plate() -> bool:
	return _plate != null


## Whether the widget takes the ray: the ring or the arrows (D-058, D-061).
func is_interactive() -> bool:
	return mode in [RING, ARROWS]


func _pick_part(origin: Vector3, direction: Vector3) -> Dictionary:
	match mode:
		RING:
			var inverse := global_transform.affine_inverse()
			var local_origin := inverse * origin
			var local_direction := inverse.basis * direction
			if absf(local_direction.z) < 0.000001: return {}
			var distance := -local_origin.z / local_direction.z
			if distance < 0.0: return {}
			var point := local_origin + local_direction * distance
			var radius := Vector2(point.x, point.y).length()
			if absf(radius - RING_RADIUS) <= RING_BAND:
				return {"hue": fposmod(atan2(point.y, point.x), TAU) / TAU, "distance": distance}
			var bar := Vector2(point.x - (RING_RADIUS + 0.04), point.y)
			if absf(bar.x) <= BAR_SIZE.x and absf(bar.y) <= BAR_SIZE.y * 0.5:
				return {"value": clampf(0.5 + bar.y / BAR_SIZE.y, 0.0, 1.0), "distance": distance}
		ARROWS:
			var best := -1
			var best_distance := INF
			var best_gap := INF
			for axis: int in _axes.size():
				if not _arrows[axis].visible: continue
				var closest := Geometry3D.get_closest_points_between_segments(origin, origin + direction * 5.0, global_position, global_position + _axes[axis] * (_lengths[axis] + 0.022))
				# Along an axis the white arrow lies on that axis's arrow: the axis's wins there.
				var gap := closest[0].distance_to(closest[1]) + (0.008 if axis == VECTOR_AXIS else 0.0)
				if gap <= ARROW_PICK and gap < best_gap:
					best_gap = gap
					best = axis
					best_distance = origin.distance_to(closest[0])
			if best >= 0: return {"axis": best, "distance": best_distance}
	return {}


## Shows [param text], the value the arrows make, over their plate.
func set_readout(text: String) -> void:
	if _readout != null: _readout.text = text


## [param value] pulled by [param meters] along its arrow: a tenth per 2 cm, stopping at whole numbers.
static func pulled(value: float, meters: float) -> float:
	var result := snappedf(value + meters * ARROW_GAIN, 0.1)
	if absf(result - roundf(result)) <= DETENT: result = roundf(result)
	return result


## How far along [param axis] of the scene the ray from [param origin] is nearest, in meters from the arrows' foot.
func axis_offset(axis: int, origin: Vector3, direction: Vector3) -> float:
	if axis < 0 or axis > 2: return 0.0
	var line := axis_direction(axis)
	var closest := Geometry3D.get_closest_points_between_segments(global_position - line * 5.0, global_position + line * 5.0, origin, origin + direction * 5.0)
	return (closest[0] - global_position).dot(line)


## Lights what [param picked] ([method pick]) names: a ring segment, a shade or an arrow.
func light(picked: Dictionary) -> void:
	var lit := -1
	if picked.has("hue"): lit = int(floorf(float(picked["hue"]) * SEGMENTS)) % SEGMENTS
	elif picked.has("value"): lit = 100 + clampi(int((1.0 - float(picked["value"])) * SHADES), 0, SHADES - 1)
	elif picked.has("axis"): lit = 200 + int(picked["axis"])
	elif picked.has("close"): lit = 300
	if lit == _lit: return
	_lit = lit
	for index: int in _segments.size(): _segments[index].scale = Vector3.ONE * (1.6 if index == lit else 1.0)
	for index: int in _shades.size(): _shades[index].scale = Vector3.ONE * (1.4 if 100 + index == lit else 1.0)
	# The arrow under the ray grows and turns white; the × grows and turns red (D-059).
	# Lit, an axis arrow turns white and thickens; the white one turns yellow.
	for index: int in _arrows.size():
		var hot := 200 + index == lit
		_arrows[index].scale = Vector3(1.6, 1.0, 1.6) if hot else Vector3.ONE
		_heads[index].scale = Vector3.ONE * (1.3 if hot else 1.0)
		var shown := _arrow_materials[index]
		if hot: shown = _lit_white if index == VECTOR_AXIS else _hot_material
		_shafts[index].material_override = shown
		_heads[index].material_override = shown
	if _close != null:
		_close.scale = Vector3.ONE * (1.4 if lit == 300 else 1.0)
		_close_disc.material_override = _close_hot if lit == 300 else _close_idle
