@tool
class_name XREBlueprintTokenEditor
extends Node3D
## The input of a token, around the token itself (D-052), as the concept
## draws it: a number turned by the wrist shows a dial of ticks, one per step,
## the current one white, and its value large above; a choice turned so shows
## its values on an arc, the current one white; a color in 3D shows a globe of
## colors, turned by a drag and picked by a click (D-064); a vector shows
## arrows along X, Y and Z, each pulled along its axis to change one component.
## Built when an edit starts, moved and lit while it lasts; picked analytically.
##
## It is drawn over everything — scene, cards, windows — with no depth test
## (D-058); what stands nearer the head and covers it is see-through (D-066,
## [method focus_sphere]). The globe and the arrows hang in front of their
## windows, which move and close them ([XREBlueprintColorTab], [XREBlueprintVectorTab]).

const DIAL := &"dial"
const CHOICE := &"choice"
const GLOBE := &"globe"
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
## The globe of colors (D-064): its radius at full saturation, the part of
## that it shrinks to at none, and how far it tilts toward the user at most.
## Its longitude is the hue, its latitude the lightness, black at the bottom
## pole and white at the top, its depth the saturation.
const GLOBE_RADIUS := 0.075
const GLOBE_CORE := 0.45
const GLOBE_TILT := 1.3
## The arrows are drawn to one scale (D-061): an axis arrow is its component
## long, the white one is the vector, so that they change together. The
## largest component is [constant ARROW_LENGTH] long when the arrows open
## (one unit at most that); an arrow is drawn at least [constant ARROW_STUB]
## long to be taken; past [constant ARROW_MAX] (the white arrow: past
## [constant VECTOR_MAX]) the scale shrinks instead. The ray picks an arrow
## [constant ARROW_PICK] from its axis. Small enough that a seated user pulls
## them by the wrist and the forearm, not the whole arm (D-064). A vector
## under 1 is drawn finer, by tenths (D-066): its largest component's decade,
## down to [constant FINEST], is [constant ARROW_LENGTH] long, so that 0.1 and
## 0.01 are pulled as 1 and 0.1 are. An arrow is taken only by its end, the
## last [constant TIP_REACH] of it and its head.
const ARROW_LENGTH := 0.07
const FINEST := 0.1
const TIP_REACH := 0.025
const ARROW_STUB := 0.01
const ARROW_MAX := 0.12
const VECTOR_MAX := 0.14
const ARROW_PICK := 0.02
## The length of an arrow's head.
const HEAD_LENGTH := 0.016
## The white arrow of the whole vector: its index among the arrows. It and
## the vector over it are a little see-through (D-067): the sum is read from
## the axis arrows through it.
const VECTOR_AXIS := 3
const VECTOR_COLOR := Color(1.0, 1.0, 1.0, 0.5)
const VECTOR_TEXT_ALPHA := 0.75
## Pulled past its longest, an arrow goes on growing its value: this many
## units a second per meter beyond, times the value's size once past 1, and
## faster the longer it is held there, by this much a second (D-060).
const OVER_SPEED := 40.0
const OVER_ACCEL := 1.5
## Pulled near its foot an arrow goes toward zero (D-067), as past its end it
## goes on: within [constant NEAR_ZONE] of the foot its component shrinks, by a
## tenth a second at the inner edge and faster the longer it is held, to
## [constant SMALLEST] at least, the scale growing so that the arrow stays
## [constant NEAR_ZONE] long. Within [constant ZERO_ZONE] it is 0. The finest a
## value or a step goes is a millionth (D-071; a hundredth before).
const NEAR_ZONE := 0.016
const ZERO_ZONE := 0.004
const UNDER_SPEED := 2.3
const SMALLEST := 0.000001
## With Axis scale on Stick (D-069) none of that: the stick tilted all the way
## makes the scale this many times finer or coarser a second (natural log: 20
## times, D-070), the value kept. Held past an end the axis slides on at an
## even speed, [constant PAN_SPEED] meters of it a second per meter beyond, as
## it is drawn now: faster only by a coarser scale, never by time (D-070).
const ZOOM_SPEED := 3.0
const PAN_SPEED := 5.0
## The scale along a pulled arrow: a tick at every step of a 1-2-5 series,
## at least [constant GRID_GAP] apart, longer every tenth tick and at zero. A
## pulled component goes by those steps, with no stop at whole numbers: one
## kept 0.1 out of reach (D-066).
const GRID_GAP := 0.007
const GRID_TICKS := 24
const SERIES: Array[float] = [1.0, 2.0, 5.0]
## How much a pulled arrow changes its component, per meter of pull: a tenth per 2 cm.
const ARROW_GAIN := 5.0
## A pulled component this near a whole number stops at it, so that 0 and 1 are easy to hit.
const DETENT := 0.15
const AXIS_COLORS: Array[Color] = [Color("ff6b6b"), Color("7be5b3"), Color("89adff")]
const IDLE := Color("7d8597")
## Sorted as if this much nearer than it is: drawn after everything else that
## is transparent, after a window drawn over everything too (its offset is 100).
const ON_TOP_OFFSET := 150.0

var mode := &""
## How the scale of the line and of the arrows changes, a value of
## [constant XREFeatureSettings.AXIS_SCALE] (D-069): set before they open.
var scale_mode := XREFeatureSettings.AUTO
## The arrow being pulled, or -1; how far, and where the hand is, at the last pull: a zoom keeps the value under them.
var _pull_axis := -1
var _last_pulled := 0.0
var _last_point := Vector3.ZERO
## Where each arrow begins, on Stick (D-071): 0, or a value its axis was moved
## on to, as a number line slides, when it would be longer than it can be.
## Written by the arrow's foot ("from 1.5"). Always 0 on Auto.
var _bases := Vector3.ZERO
var _base_labels: Array[Label3D] = []
## The scale shown (D-071): "step 0.01" by the line's right end or under the arrows.
var _step_label: Label3D
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
## Where the line begins, in meters right of the token (D-064): -[constant LINE_HALF],
## or nearer when its least value would fall inside, so that the line starts there.
var _line_left := -LINE_HALF
## How long the marker has been held near the 0 tick (D-068).
var _under_time := 0.0
var _value: Label3D
var _choices: Array[Label3D] = []
var _arrows: Array[Node3D] = []
var _axes: Array[Vector3] = []
var _lit := -1
var _idle_material: Material
var _hot_material: Material
var _lit_white: StandardMaterial3D
## The globe (D-064): its turn, the sphere scaled to its saturation, the
## mark of its color, which turns with it, and the ring under the ray.
var _pivot: Node3D
var _globe: MeshInstance3D
var _globe_material: ShaderMaterial
var _mark: MeshInstance3D
var _hover: MeshInstance3D
var _globe_yaw := 0.0
var _globe_pitch := 0.0
## The color it shows: hue, saturation and lightness, the hue kept through grays; and its alpha.
var _hsl := Vector3(0.0, 1.0, 0.5)
var _alpha := 1.0
static var _globe_shader: Shader
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
	_arrows.clear()
	_axes.clear()
	_value = null
	_pivot = null
	_globe = null
	_mark = null
	_hover = null
	_arrow_materials.clear()
	_shafts.clear()
	_heads.clear()
	_numbers.clear()
	_lengths.clear()
	_grid.clear()
	_grid_axis = -1
	_lit = -1
	_base_labels.clear()
	_step_label = null


## Draws every part over everything: no depth test, sorted last (D-058).
func _raise(node: Node) -> void:
	for child: Node in node.get_children():
		if child is GeometryInstance3D: (child as GeometryInstance3D).sorting_offset = ON_TOP_OFFSET
		if child is Label3D: (child as Label3D).no_depth_test = true
		elif child is MeshInstance3D:
			var material := (child as MeshInstance3D).material_override as BaseMaterial3D
			if material != null: material.no_depth_test = true
		_raise(child)
	# The mark of the color over the globe it lies on.
	if node == self and _mark != null:
		_mark.sorting_offset = ON_TOP_OFFSET + 1.0
		_hover.sorting_offset = ON_TOP_OFFSET + 1.0


## The number line of a number held by the trigger (D-062, after D-052's dial):
## a ruler across the token at [param pose], with a tick every tenth (every
## unit for an [param integer]) and figures at the long ones, and a marker at
## the value, the value large above it. The ray along the line moves the
## marker and the value ([method line_to]); held past an end the value goes
## on, faster and faster, the ruler sliding under the marker. The wrist and
## the stick step it too ([method nudge]). The value goes no lower than
## [param minimum] (NAN: no bound): the line stops there (D-063) and begins
## there, as long as the line is, when it would reach below (D-064). Held
## near the 0 tick a fraction goes toward zero, as an arrow near its foot
## does (D-068, [constant NEAR_ZONE]): the ruler grows finer about its 0.
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
	_under_time = 0.0
	_line_left = -LINE_HALF
	if not is_nan(minimum): _line_left = clampf((minimum - _line_center) * _line_scale, -LINE_HALF, 0.0)
	var line := BoxMesh.new()
	line.size = Vector3(LINE_HALF * 2.0, 0.002, 0.002)
	var bar := XRERig.create_vr_mesh(line, _idle_material)
	bar.position = Vector3(_line_left + LINE_HALF, LINE_LIFT, 0.01)
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
	var help := "move the ray ← → along the line  ·  past its end it speeds up, held by 0 it goes to 0  ·  or the wrist, the stick  ·  let go to keep"
	if scale_mode == XREFeatureSettings.STICK: help = "move the ray ← → along the line, past its end it slides on  ·  stick ↑ finer, ↓ coarser  ·  wrist or stick ← → a step  ·  let go to keep"
	var hint := XREBlueprintCanvas.label(help, 14)
	hint.modulate = Color("a9b0bf")
	hint.position = Vector3(_line_left + LINE_HALF, LINE_LIFT - 0.035, 0.01)
	add_child(hint)
	_step_label = _make_step_label()
	_step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_step_label.position = Vector3(_line_left + LINE_HALF * 2.0 + 0.02, LINE_LIFT, 0.01)
	_show_line()
	_raise(self)
	visible = true


## Moves the marker to [param offset] meters along the line from where the
## trigger took the token, [param delta] seconds after the last move; returns
## the value. Past an end the marker stays there and the value goes on, this
## many units a second per meter beyond, times its size once past 1, faster the
## longer it is held there. Held within [constant NEAR_ZONE] of the 0 tick, a
## fraction goes toward zero (D-068): the ruler grows finer about its 0, the
## 0 tick staying where it is, so that the value under the marker shrinks, to
## [constant SMALLEST] at least; within [constant ZERO_ZONE] it is 0.
func line_to(offset: float, delta: float) -> Variant:
	var right := _line_left + LINE_HALF * 2.0
	var over := maxf(offset - right, _line_left - offset)
	var auto := scale_mode != XREFeatureSettings.STICK
	if over > 0.0 and not auto:
		# On Stick the ruler slides on evenly under the marker (D-070): a line, not a segment.
		_line_center += signf(offset - _line_left - LINE_HALF) * over * PAN_SPEED / _line_scale * delta
	elif over > 0.0:
		_over_time += delta
		_line_center += signf(offset - _line_left - LINE_HALF) * over * LINE_SPEED * maxf(absf(_line_center), 1.0) * (1.0 + _over_time * OVER_ACCEL) * delta
	else: _over_time = 0.0
	var zero := -_line_center * _line_scale
	var from_zero := offset - zero
	if auto and over <= 0.0 and not _line_integer and zero >= _line_left - 0.0001 and zero <= right + 0.0001 and absf(from_zero) < NEAR_ZONE and absf(from_zero) > ZERO_ZONE:
		_under_time += delta
		var depth := (NEAR_ZONE - absf(from_zero)) / (NEAR_ZONE - ZERO_ZONE)
		var finer := _line_scale * exp(UNDER_SPEED * depth * (1.0 + _under_time * OVER_ACCEL) * delta)
		_line_scale = maxf(_line_scale, minf(finer, absf(from_zero) / SMALLEST))
		_line_center = -zero / _line_scale
		_line_step = _fine_step()
	else: _under_time = 0.0
	_line_shown = clampf(offset, _line_left, right)
	return _line_settle(over <= 0.0)


## The line's step at its scale (D-068): the smallest of 0.000001… 0.01, 0.02,
## 0.05, 0.1… whose ticks are at least [constant LINE_STEP_GAP] apart (D-071).
func _fine_step() -> float:
	for exponent: int in range(-6, 12):
		for factor: float in SERIES:
			var step := factor * pow(10.0, exponent)
			if step * _line_scale >= LINE_STEP_GAP - 0.000001: return step
	return pow(10.0, 12)


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
		# Going toward zero by the 0 tick (D-068) it is shown to the hundredth, never
		# 0, though its ticks are coarser: snapped to them, 0.04 would be 0.
		if _under_time > 0.0: value = signf(value) * maxf(snappedf(absf(value), SMALLEST), SMALLEST)
		else: value = snappedf(value, _line_step)
		# Not on a finer ruler (D-068): 0.01 to 0.04 would stop at 0.
		if detent and _under_time <= 0.0 and _line_step >= 0.1 and absf(value - roundf(value)) <= LINE_DETENT: value = roundf(value)
	if not is_nan(_line_minimum): value = maxf(value, _line_minimum)
	_line_value = value
	_show_line()
	return int(value) if _line_integer else value


## The value the line shows now.
func get_line_value() -> Variant:
	return int(_line_value) if _line_integer else _line_value


## The ruler under the marker: a tick at every step of the value along the
## line, long ones every ten steps with their figures; none below its least value.
func _show_line() -> void:
	var first := ceilf((_line_center + _line_left / _line_scale) / _line_step - 0.0001)
	var figure := 0
	for index: int in _ticks.size():
		var tick := _ticks[index]
		var at := (first + index) * _line_step
		var x := (at - _line_center) * _line_scale
		tick.visible = x >= _line_left - 0.0001 and x <= _line_left + LINE_HALF * 2.0 + 0.0001 and (is_nan(_line_minimum) or at >= _line_minimum - _line_step * 0.01)
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
	if _step_label != null: _step_label.text = "step " + XREBlueprintTokens.plain(_line_step)
	_value.text = XREBlueprintTokens.text(int(_line_value) if _line_integer else _line_value, "")
	_value.position = Vector3(_line_shown, LINE_LIFT + 0.04, 0.012)


## The scale of the line or of the arrows in words (D-071): "step 0.01", what one tick is.
func _make_step_label() -> Label3D:
	var label := XREBlueprintCanvas.label("", 14)
	label.modulate = Color("c8cedb")
	add_child(label)
	return label


## The step the line or the arrows show now (D-071).
func get_shown_step() -> String:
	return _step_label.text if _step_label != null else ""


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


## The globe of colors (D-064) at [param pose], facing as it does, showing
## [param color]: hue round it, lightness up it, black at the bottom pole and
## white at the top, its saturation in its size and in the colors on it. A
## mark lies where the color is. A drag turns it ([method turn_globe]), a
## click picks a color on it ([method globe_at]).
func open_globe(pose: Transform3D, color: Color) -> void:
	_clear()
	mode = GLOBE
	global_transform = Transform3D(pose.basis.orthonormalized(), pose.origin)
	_pivot = Node3D.new()
	add_child(_pivot)
	var sphere := SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	sphere.radial_segments = 48
	sphere.rings = 24
	_globe_material = _make_globe_material()
	_globe = XRERig.create_vr_mesh(sphere, _globe_material)
	_pivot.add_child(_globe)
	var ring := TorusMesh.new()
	ring.inner_radius = 0.0045
	ring.outer_radius = 0.0075
	_mark = XRERig.create_vr_mesh(ring, _hot_material)
	_pivot.add_child(_mark)
	_hover = XRERig.create_vr_mesh(ring, _lit_white)
	_hover.visible = false
	add_child(_hover)
	_globe_yaw = 0.0
	_globe_pitch = 0.0
	_hsl = Vector3(0.0, 1.0, 0.5)
	set_globe_color(color)
	face_globe_color()
	_raise(self)
	visible = true


static func _make_globe_material() -> ShaderMaterial:
	if _globe_shader == null:
		_globe_shader = Shader.new()
		# The colors are sRGB, as a Color is; the renderer works in linear, so they are
		# decoded here. ALPHA keeps the globe in the transparent pass, after the dimmer;
		# without a depth test it is drawn over everything, and being convex, culled
		# back faces keep it whole.
		_globe_shader.code = """
shader_type spatial;
render_mode unshaded, depth_test_disabled, cull_back, fog_disabled;
uniform float saturation = 1.0;
varying vec3 direction;
void vertex() { direction = VERTEX; }
vec3 hsl(float h, float s, float l) {
	vec3 k = clamp(abs(mod(h * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
	return l + s * (k - 0.5) * (1.0 - abs(2.0 * l - 1.0));
}
void fragment() {
	vec3 d = normalize(direction);
	vec3 c = hsl(fract(atan(d.x, d.z) / TAU), saturation, 0.5 + asin(clamp(d.y, -1.0, 1.0)) / PI);
	ALBEDO = mix(pow((c + 0.055) / 1.055, vec3(2.4)), c / 12.92, vec3(lessThan(c, vec3(0.04045))));
	ALPHA = 1.0;
}
"""
	var material := ShaderMaterial.new()
	material.shader = _globe_shader
	material.render_priority = Material.RENDER_PRIORITY_MAX
	return material


## Shows [param color] on the globe: its saturation and its mark. A gray keeps
## the hue it had, black and white the saturation too, so that the globe
## doesn't turn gray with them.
func set_globe_color(color: Color) -> void:
	var picked := to_hsl(color)
	if picked.y > 0.0005 and picked.z > 0.0005 and picked.z < 0.9995: _hsl.x = picked.x
	if picked.z > 0.0005 and picked.z < 0.9995: _hsl.y = picked.y
	_hsl.z = picked.z
	_alpha = color.a
	_show_globe()


## Sets the globe's saturation to [param saturation]; returns the color it makes.
func set_globe_saturation(saturation: float) -> Color:
	_hsl.y = clampf(saturation, 0.0, 1.0)
	_show_globe()
	return get_globe_color()


## The color the globe shows.
func get_globe_color() -> Color:
	return hsl(_hsl.x, _hsl.y, _hsl.z, _alpha)


## The color of [param hue] and [param lightness] at the globe's saturation.
func globe_color(hue: float, lightness: float) -> Color:
	return hsl(hue, _hsl.y, lightness, _alpha)


## The globe's saturation.
func get_globe_saturation() -> float:
	return _hsl.y


## The globe's radius now, smaller the less saturated it is.
func globe_radius() -> float:
	return GLOBE_RADIUS * (GLOBE_CORE + (1.0 - GLOBE_CORE) * _hsl.y)


## Turns the globe to [param yaw] about its own axis and [param pitch] toward
## the user, as a globe on its stand is turned; the tilt stops short of the poles.
func turn_globe(yaw: float, pitch: float) -> void:
	_globe_yaw = wrapf(yaw, -PI, PI)
	_globe_pitch = clampf(pitch, -GLOBE_TILT, GLOBE_TILT)
	_show_globe()


## Turns the globe so that its color faces the user, as far as its tilt goes.
func face_globe_color() -> void:
	turn_globe(-_hsl.x * TAU, (clampf(_hsl.z, 0.0, 1.0) - 0.5) * PI)


## The globe's turn: yaw and pitch.
func get_globe_turn() -> Vector2:
	return Vector2(_globe_yaw, _globe_pitch)


## The direction from the globe's center, unturned, of [param hue] and [param lightness].
static func globe_direction(hue: float, lightness: float) -> Vector3:
	var latitude := (clampf(lightness, 0.0, 1.0) - 0.5) * PI
	return Vector3(cos(latitude) * sin(hue * TAU), sin(latitude), cos(latitude) * cos(hue * TAU))


func _show_globe() -> void:
	if _globe == null: return
	var radius := globe_radius()
	_pivot.basis = Basis(Vector3.RIGHT, _globe_pitch) * Basis(Vector3.UP, _globe_yaw)
	_globe.scale = Vector3.ONE * radius
	_globe_material.set_shader_parameter(&"saturation", _hsl.y)
	var direction := globe_direction(_hsl.x, _hsl.z)
	_mark.basis = _along(direction)
	_mark.position = direction * (radius + 0.002)
	# Only on the side toward the user: drawn over everything, it would show through.
	_mark.visible = (_pivot.basis * direction).z > 0.15


## Where the ray from [param origin] along [param direction] meets the globe:
## [code]{"globe": Vector2(hue, lightness), "local", "distance"}[/code], or empty.
func globe_at(origin: Vector3, direction: Vector3) -> Dictionary:
	if mode != GLOBE: return {}
	var inverse := global_transform.affine_inverse()
	var start := inverse * origin
	var along := (inverse.basis * direction).normalized()
	var radius := globe_radius()
	var middle := -start.dot(along)
	var gap := start.length_squared() - middle * middle
	if gap > radius * radius: return {}
	var distance := middle - sqrt(radius * radius - gap)
	if distance < 0.0: return {}
	var point := start + along * distance
	var unturned := _pivot.basis.inverse() * point.normalized()
	var hue := fposmod(atan2(unturned.x, unturned.z) / TAU, 1.0)
	var lightness := 0.5 + asin(clampf(unturned.y, -1.0, 1.0)) / PI
	return {"globe": Vector2(hue, lightness), "local": point, "distance": distance}


## Where the ray from [param origin] along [param direction] meets the plane
## through the globe's center facing the user, in meters right and up of the
## center; NAN off it. A drag turns the globe by it.
func globe_plane_point(origin: Vector3, direction: Vector3) -> Vector2:
	var at := _on_plane(global_transform, origin, direction)
	if at.is_empty(): return Vector2(NAN, NAN)
	var point: Vector3 = at["point"]
	return Vector2(point.x, point.y)


## The color with [param hue], [param saturation] and [param lightness] (HSL), and [param alpha].
static func hsl(hue: float, saturation: float, lightness: float, alpha: float = 1.0) -> Color:
	var chroma := (1.0 - absf(2.0 * lightness - 1.0)) * saturation
	var channels := Vector3.ZERO
	var offsets := Vector3(0.0, 4.0, 2.0)
	for index: int in 3:
		var k := clampf(absf(fposmod(hue * 6.0 + offsets[index], 6.0) - 3.0) - 1.0, 0.0, 1.0)
		channels[index] = lightness + chroma * (k - 0.5)
	return Color(channels.x, channels.y, channels.z, alpha)


## Hue, saturation and lightness (HSL) of [param color].
static func to_hsl(color: Color) -> Vector3:
	var high := maxf(color.r, maxf(color.g, color.b))
	var low := minf(color.r, minf(color.g, color.b))
	var lightness := (high + low) * 0.5
	var spread := high - low
	if spread < 0.000001: return Vector3(0.0, 0.0, lightness)
	return Vector3(color.h, spread / (1.0 - absf(2.0 * lightness - 1.0)), lightness)


## The arrows of a vector token [param value] (D-060, D-061), at
## [param pose]'s origin, facing it: X, Y and, for a Vector3, Z, each its
## component long in one scale and its number at its tip, and a white arrow of
## the whole vector, the three arrows added up, the vector at its tip (D-066:
## no longer over the plate, D-059). They hang in front of the
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
	_bases = Vector3.ZERO
	var facing := pose.basis.orthonormalized()
	_frame = facing
	_step_label = _make_step_label()
	_step_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	for axis: int in 3: _add_arrow(AXIS_COLORS[axis], axis_direction(axis))
	_arrows[2].visible = axes == 3
	_add_arrow(VECTOR_COLOR, Vector3.UP)
	_numbers[VECTOR_AXIS].modulate.a = VECTOR_TEXT_ALPHA
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


## Moves the arrows or the globe to [param origin], their axes those of a
## window facing as [param facing]: the Vector or the Color window carries
## them, and turns them with it.
func place(origin: Vector3, facing: Basis) -> void:
	if mode == GLOBE:
		global_transform = Transform3D(facing, origin)
		return
	global_position = origin
	if not facing.is_equal_approx(_frame):
		_frame = facing
		_show()


## One arrow along [param direction] in [param color]: a shaft of unit length
## scaled to the arrow's, a head at its tip and its number beyond.
func _add_arrow(color: Color, direction: Vector3) -> void:
	var arrow := Node3D.new()
	var shaft := CylinderMesh.new()
	shaft.top_radius = 0.002
	shaft.bottom_radius = 0.002
	shaft.height = 1.0
	var head := CylinderMesh.new()
	head.top_radius = 0.0
	head.bottom_radius = 0.007
	head.height = HEAD_LENGTH
	var material := XREBlueprintCanvas.material(color, true)
	_arrow_materials.append(material)
	var shaft_mesh := XRERig.create_vr_mesh(shaft, material)
	arrow.add_child(shaft_mesh)
	var head_mesh := XRERig.create_vr_mesh(head, material)
	arrow.add_child(head_mesh)
	var number := XREBlueprintCanvas.label("", 16)
	number.modulate = color
	number.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arrow.add_child(number)
	# Behind the foot: the value the arrow begins at, when not 0 (D-071).
	var base := XREBlueprintCanvas.label("", 13)
	base.modulate = Color(color, 0.8)
	base.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	base.position = Vector3(0, -0.014, 0)
	base.visible = false
	arrow.add_child(base)
	_base_labels.append(base)
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
	_heads[index].position = Vector3(0, shown + HEAD_LENGTH * 0.5, 0)
	_numbers[index].position = Vector3(0, shown + HEAD_LENGTH + 0.014, 0)


## The scale at which the largest component is [constant ARROW_LENGTH] long,
## one unit at most that; under 1, its decade is (D-066): 0.1 for 0.05 or 0.1,
## down to [constant FINEST]. A zero vector is drawn by units.
func _fit() -> void:
	_bases = Vector3.ZERO
	var largest := 0.0
	for axis: int in _axis_count(): largest = maxf(largest, absf(float(_vector[axis])))
	var unit := 1.0
	if largest > 0.0 and largest < 1.0: unit = maxf(pow(10.0, ceilf(log(largest) / log(10.0) - 0.000001)), FINEST)
	_scale = ARROW_LENGTH / maxf(largest, unit)


## Every arrow as the vector and the scale are: each axis arrow its component
## long — from where it begins, on Stick (D-071) — pointing the way its sign
## says, the white one their sum, numbers at their tips, the step under them.
func _show() -> void:
	var sum := Vector3.ZERO
	for axis: int in _axis_count():
		var component := float(_vector[axis])
		var drawn := component - _bases[axis]
		var direction := axis_direction(axis) * (-1.0 if drawn < 0.0 else 1.0)
		_set_arrow(axis, direction, absf(drawn) * _scale)
		_numbers[axis].text = "%s %s" % [["X", "Y", "Z"][axis], XREBlueprintTokens.text(component, "")]
		_base_labels[axis].visible = _bases[axis] != 0.0
		if _bases[axis] != 0.0: _base_labels[axis].text = "from " + XREBlueprintTokens.text(_bases[axis], "")
		sum += axis_direction(axis) * drawn * _scale
	if _step_label != null:
		_step_label.text = "step " + XREBlueprintTokens.plain(get_step())
		_step_label.position = _frame * Vector3(-0.035, -0.03, 0.0)
	_set_arrow(VECTOR_AXIS, sum if sum.length() > 0.000001 else Vector3(1, 1, 1 if _axis_count() == 3 else 0), sum.length())
	# Every component over the white arrow, as each axis's over its own (D-066).
	_numbers[VECTOR_AXIS].text = XREBlueprintTokens.text(_vector, "")


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
	var same: bool = mode == ARROWS and typeof(value) == typeof(_vector) and value == _vector
	_vector = value
	if mode != ARROWS: return
	# Shown again as it is, a pull let go: on Stick the scale and where the arrows
	# begin stay as the stick and the pull left them (D-071).
	if same and scale_mode == XREFeatureSettings.STICK:
		_show()
		_hide_grid()
		return
	_bases = Vector3.ZERO
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
	_pull_axis = axis
	_last_pulled = 0.0
	_last_point = grab
	if axis == VECTOR_AXIS:
		_grab = grab
		_tip_start = _axes_basis() * ((_as_vector3(_vector) - _bases) * _scale)
		_vector_start = _vector
		_reach = 0.0
	elif axis >= 0 and axis < _axis_count():
		_start_length = (float(_vector[axis]) - _bases[axis]) * _scale


## Pulls axis arrow [param axis] by [param pulled] meters along its axis,
## [param delta] seconds after the last pull; returns the vector it makes.
## Within its longest the component follows the arrow by the scale's steps
## ([method get_step]), through zero to the other side; held past its longest the
## component grows on, faster the longer it is held, and the scale shrinks so
## that the arrow stays at its longest and the others shrink with it. Held
## near its foot the component goes toward zero the same way, the scale
## growing; at the foot it is 0 (D-067).
func pull_to(axis: int, pulled: float, delta: float) -> Variant:
	if axis < 0 or axis >= _axis_count(): return _vector
	_last_pulled = pulled
	var length := _start_length + pulled
	var component: float
	var now := float(_vector[axis])
	var stick := scale_mode == XREFeatureSettings.STICK
	if stick:
		# The stick scales (D-069): no going toward zero by itself. Past the arrow's
		# longest its axis slides on evenly (D-070), as a number line, the arrow
		# staying there and beginning further on, the scale kept (D-071).
		if absf(length) > ARROW_MAX: _bases[axis] += signf(length) * (absf(length) - ARROW_MAX) * PAN_SPEED / _scale * delta
		component = snappedf(_bases[axis] + clampf(length, -ARROW_MAX, ARROW_MAX) / _scale, get_step())
	elif absf(length) > ARROW_MAX:
		_over_time += delta
		var reached := maxf(absf(now), ARROW_MAX / _scale)
		var over := absf(length) - ARROW_MAX
		reached += over * OVER_SPEED * maxf(reached, 1.0) * (1.0 + _over_time * OVER_ACCEL) * delta
		component = signf(length) * reached
		_scale = minf(_scale, ARROW_MAX / absf(component))
		component = snappedf(component, get_step() * 0.5)
	elif absf(length) < ZERO_ZONE:
		_over_time = 0.0
		component = 0.0
	elif absf(length) < NEAR_ZONE:
		# From the value at the zone's edge, or what it came down to on this side.
		_over_time += delta
		var edge := NEAR_ZONE / _scale
		var reached := minf(absf(now), edge) if now != 0.0 and signf(now) == signf(length) else edge
		var depth := (NEAR_ZONE - absf(length)) / (NEAR_ZONE - ZERO_ZONE)
		reached = maxf(reached * exp(-UNDER_SPEED * depth * (1.0 + _over_time * OVER_ACCEL) * delta), SMALLEST)
		_scale = maxf(_scale, NEAR_ZONE / reached)
		component = signf(length) * maxf(snappedf(reached, get_step()), SMALLEST)
	else:
		_over_time = 0.0
		component = snappedf(length / _scale, get_step())
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
	_last_point = point
	var value: Vector3
	if scale_mode == XREFeatureSettings.STICK:
		# Past the end the axes slide on along the white arrow, the scale kept (D-071).
		_reach = 0.0
		if tip.length() > VECTOR_MAX:
			_bases += to_components * (tip.normalized() * (tip.length() - VECTOR_MAX) * PAN_SPEED * delta) / _scale
			tip = tip.limit_length(VECTOR_MAX)
		value = _bases + to_components * tip / _scale
	elif tip.length() > VECTOR_MAX:
		# The tip stays at the end; how far it reaches grows on, at the scale the pull
		# began: on Stick evenly, as the axis is drawn now (D-070).
		_over_time += delta
		_reach = maxf(_reach, VECTOR_MAX)
		var over := tip.length() - VECTOR_MAX
		if scale_mode == XREFeatureSettings.STICK: _reach += over * PAN_SPEED * _scale_start / _scale * delta
		else: _reach += over * OVER_SPEED * _scale_start * maxf(_reach / _scale_start, 1.0) * (1.0 + _over_time * OVER_ACCEL) * delta
		value = to_components * (tip.normalized() * _reach) / _scale_start
		_scale = _scale_start * VECTOR_MAX / _reach
	else:
		_over_time = 0.0
		_reach = 0.0
		value = to_components * tip / _scale
	var grain := get_step() if _reach == 0.0 else get_step() * 0.5
	_vector = _from_vector3(Vector3(snappedf(value.x, grain), snappedf(value.y, grain), snappedf(value.z, grain)))
	_show()
	_update_grid(_axes[VECTOR_AXIS], VECTOR_MAX)
	return _vector


## Makes the scale of the line or of the arrows finer (positive [param tilt],
## the stick up) or coarser for [param delta] seconds (D-069, Axis scale on
## Stick): the value stays. The line scales about its marker; a pulled arrow
## gets longer or shorter and goes on from there with the ray, its value kept;
## the ticks follow. An arrow that would grow longer than it can be begins
## further on its axis instead (D-071, [method _rebase]), so that the scale
## goes on getting finer. No finer than a step of [constant SMALLEST]; a whole
## number's line no finer than a step of 1.
func zoom(tilt: float, delta: float) -> void:
	if is_zero_approx(tilt): return
	var factor := exp(tilt * ZOOM_SPEED * delta)
	if mode == DIAL:
		var value := _line_center + _line_shown / _line_scale
		_line_scale = clampf(_line_scale * factor, LINE_STEP_GAP / 1000000.0, LINE_STEP_GAP / (1.0 if _line_integer else SMALLEST))
		_line_center = value - _line_shown / _line_scale
		_line_step = maxf(_fine_step(), 1.0) if _line_integer else _fine_step()
		_show_line()
		return
	if mode != ARROWS: return
	var before := _scale
	_scale = clampf(_scale * factor, ARROW_LENGTH / 1000000.0, GRID_GAP / SMALLEST)
	if scale_mode == XREFeatureSettings.STICK: _rebase(before)
	if _pull_axis == VECTOR_AXIS: _tip_start = _axes_basis() * ((_as_vector3(_vector) - _bases) * _scale) - (_last_point - _grab)
	elif _pull_axis >= 0 and _pull_axis < _axis_count(): _start_length = (float(_vector[_pull_axis]) - _bases[_pull_axis]) * _scale - _last_pulled
	_show()
	if _pull_axis >= 0: _update_grid(_axes[_pull_axis], VECTOR_MAX if _pull_axis == VECTOR_AXIS else ARROW_MAX)


## Where each arrow begins after the scale went from [param before] to now
## (D-071): from 0 when the whole arrow fits; at its longest, further on its
## axis, when it no longer would; else as long as it was drawn.
func _rebase(before: float) -> void:
	for axis: int in _axis_count():
		var component := float(_vector[axis])
		if absf(component) * _scale <= ARROW_MAX: _bases[axis] = 0.0
		elif _bases[axis] == 0.0: _bases[axis] = component - signf(component) * ARROW_MAX / _scale
		else: _bases[axis] = component - (component - _bases[axis]) * before / _scale


## Where each arrow begins (D-071): 0 but on Stick, its axis moved on.
func get_bases() -> Vector3:
	return _bases


## The step of the scale: the smallest of 0.000001, 0.000002… 0.1… units at
## least [constant GRID_GAP] apart — 0.1 by units, 0.01 by tenths (D-066, D-071).
func get_step() -> float:
	for exponent: int in range(-6, 12):
		for factor: float in SERIES:
			var step := factor * pow(10.0, exponent)
			if step * _scale >= GRID_GAP - 0.000001: return step
	return pow(10.0, 12)


## The ticks of the scale along [param direction] from the foot of the
## arrows to [param reach]: one per step, longer every ten steps; they slide
## and close up as the scale shrinks.
func _update_grid(direction: Vector3, reach: float) -> void:
	var step := get_step()
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
	_pull_axis = -1
	if mode != ARROWS: return
	# The scale the stick chose stays (D-069).
	if scale_mode == XREFeatureSettings.STICK:
		_show()
		_hide_grid()
	else: set_vector(_vector)


## What the ray picks: [code]{"globe"}[/code] on the globe ([method globe_at]),
## [code]{"axis"}[/code] on an arrow, or empty; with the distance to it.
func pick(origin: Vector3, direction: Vector3) -> Dictionary:
	if not is_open(): return {}
	return _pick_part(origin, direction)


## Where the ray meets the plane of [param frame]: the local point and the distance, or empty.
static func _on_plane(frame: Transform3D, origin: Vector3, direction: Vector3) -> Dictionary:
	var inverse := frame.affine_inverse()
	var local_origin := inverse * origin
	var local_direction := inverse.basis * direction
	if absf(local_direction.z) < 0.000001: return {}
	var distance := -local_origin.z / local_direction.z
	if distance < 0.0: return {}
	return {"point": local_origin + local_direction * distance, "distance": distance}


## Whether the widget takes the ray: the globe or the arrows (D-061, D-064).
func is_interactive() -> bool:
	return mode in [GLOBE, ARROWS]


func _pick_part(origin: Vector3, direction: Vector3) -> Dictionary:
	match mode:
		GLOBE: return globe_at(origin, direction)
		ARROWS:
			var best := -1
			var best_distance := INF
			var best_gap := INF
			for axis: int in _axes.size():
				if not _arrows[axis].visible: continue
				# Only the end of an arrow takes it, its head and a little before (D-066).
				var from := global_position + _axes[axis] * maxf(_lengths[axis] - TIP_REACH, 0.0)
				var closest := Geometry3D.get_closest_points_between_segments(origin, origin + direction * 5.0, from, global_position + _axes[axis] * (_lengths[axis] + HEAD_LENGTH))
				# Along an axis the white arrow lies on that axis's arrow: the axis's wins there.
				var gap := closest[0].distance_to(closest[1]) + (0.008 if axis == VECTOR_AXIS else 0.0)
				if gap <= ARROW_PICK and gap < best_gap:
					best_gap = gap
					best = axis
					best_distance = origin.distance_to(closest[0])
			if best >= 0: return {"axis": best, "distance": best_distance}
	return {}


## Where the head of arrow [param axis] is, global (D-066): the ray that pulls it ends there.
func tip_position(axis: int) -> Vector3:
	if axis < 0 or axis >= _axes.size(): return global_position
	return global_position + _axes[axis] * (_lengths[axis] + HEAD_LENGTH * 0.5)


## The input as a sphere, its center and its radius in [code]w[/code], for
## what covers it to become see-through (D-066); a zero radius while there is
## none that takes the eye: closed, or a line of help.
func focus_sphere() -> Vector4:
	var center := global_position
	var radius := 0.0
	match mode:
		DIAL:
			center = global_transform * Vector3(_line_left + LINE_HALF, LINE_LIFT + 0.01, 0.01)
			radius = LINE_HALF + 0.02
		CHOICE:
			center = global_transform * Vector3(0.0, 0.04, 0.01)
			radius = 0.1
		GLOBE: radius = globe_radius() + 0.01
		ARROWS:
			# The arrows reach out of the window and toward the user; their numbers beyond.
			center = global_position + _frame.z.normalized() * ARROW_MAX * 0.3
			radius = ARROW_MAX + 0.03
	return Vector4(center.x, center.y, center.z, radius if visible else 0.0)


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


## Lights what [param picked] ([method pick]) names: an arrow, or the point
## of the globe under the ray, ringed.
func light(picked: Dictionary) -> void:
	if _hover != null:
		_hover.visible = picked.has("local")
		if _hover.visible:
			var point: Vector3 = picked["local"]
			_hover.basis = _along(point)
			_hover.position = point * (1.0 + 0.004 / maxf(point.length(), 0.001))
	var lit := -1
	if picked.has("axis"): lit = 200 + int(picked["axis"])
	if lit == _lit: return
	_lit = lit
	# Lit, an axis arrow turns white and thickens; the white one turns yellow (D-059).
	for index: int in _arrows.size():
		var hot := 200 + index == lit
		_arrows[index].scale = Vector3(1.6, 1.0, 1.6) if hot else Vector3.ONE
		_heads[index].scale = Vector3.ONE * (1.3 if hot else 1.0)
		var shown := _arrow_materials[index]
		if hot: shown = _lit_white if index == VECTOR_AXIS else _hot_material
		_shafts[index].material_override = shown
		_heads[index].material_override = shown
