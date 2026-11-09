extends Node3D
## Spike: the same panel drawn into the frame and on OpenXR composition layers,
## which the compositor samples once instead of twice. Runs as a game: in the
## editor the engine always swaps a layer for a mesh (D-156).
##
## The columns get their letters at random on every start, so that the eyes
## judge the letters; a trigger (Space on a keyboard) reveals them.
##
## Arguments after --: --reveal, --shot=<path.png> (saves the window and quits).

enum Kind { IN_FRAME, LAYER, LAYER_HOLE_PUNCH }

const KIND_NAMES: Array[String] = ["in frame", "layer", "layer + hole punch"]
## The columns, shuffled on start.
const KINDS: Array[Kind] = [Kind.IN_FRAME, Kind.LAYER, Kind.LAYER_HOLE_PUNCH]
const LETTERS: Array[String] = ["A", "B", "C"]
## Rows of the viewport's size against the panel's: the plugin's windows use 2 (XREPanels.RENDER_SCALE).
const RENDER_SCALES: Array[float] = [2.0, 1.0]
## A panel, in interface pixels, each as large as in the plugin's windows (XREPanels.WINDOW_PIXEL_SIZE).
const LOGICAL_SIZE := Vector2i(360, 290)
const PIXEL_SIZE := 0.0009
const GAP := 0.05
const DISTANCE := 1.0
## Where the view starts before the headset reports the head.
const START_HEAD := Vector3(0.0, 1.6, 0.0)
## The moving cube: in front of the panels, it shows how each column handles depth.
const CUBE_SIZE := 0.05
const CUBE_IN_FRONT := 0.12
const CUBE_SPEED := 0.6
## The panel's window, as in XREPanelSurface.
const WINDOW_COLOR := Color(0.12, 0.13, 0.15)
const CORNER_RADIUS := 12
const TEXT := "Съешь ещё этих мягких булочек The quick brown fox 0123456789"
const FONT_SIZES: Array[int] = [11, 12, 13, 14, 16, 20]
const SHOT_FRAMES := 30
## The in-frame panel's shader, as in XREPanelSurface.
const PANEL_SHADER := """
shader_type spatial;
render_mode unshaded, depth_draw_always, fog_disabled;
uniform sampler2D panel_texture : source_color, filter_linear;
void fragment() {
	vec4 color = texture(panel_texture, UV);
	if (color.a < 0.01) discard;
	ALBEDO = color.rgb;
	ALPHA = color.a;
}
"""


## Thin lines, flat and slanted: what shows stair steps and shimmer first.
class Lines extends Control:
	func _draw() -> void:
		var line_color := Color(0.85, 0.87, 0.9)
		for i in 5:
			var y := float(i * 4) + 0.5
			draw_line(Vector2(0.0, y), Vector2(size.x * 0.3, y), line_color, 1.0)
		for i in 8:
			var x := size.x * 0.34 + float(i) * size.x * 0.08
			draw_line(Vector2(x, size.y), Vector2(x + size.x * 0.07, 0.0), line_color, 1.0)


var _kinds: Array[Kind] = KINDS.duplicate()
var _origin: XROrigin3D
var _camera: XRCamera3D
var _xr: OpenXRInterface
## Moved together when the head is found or the view recentered.
var _placed: Array[Node3D] = []
var _local: Array[Transform3D] = []
## The panels' center and facing.
var _base := Transform3D.IDENTITY
var _letters: Array[Label3D] = []
var _layers: Array[OpenXRCompositionLayerQuad] = []
var _cube: MeshInstance3D
var _head_found := false
var _revealed := false
var _shot_path := ""
var _frames := 0
var _time := 0.0


func _ready() -> void:
	randomize()
	_kinds.shuffle()
	var arguments := OS.get_cmdline_user_args()
	for argument: String in arguments:
		if argument.begins_with("--shot="):
			_shot_path = argument.trim_prefix("--shot=")

	_origin = XROrigin3D.new()
	add_child(_origin)
	_camera = XRCamera3D.new()
	_camera.position = START_HEAD
	_origin.add_child(_camera)
	for tracker: StringName in [&"left_hand", &"right_hand"]:
		var controller := XRController3D.new()
		controller.tracker = tracker
		controller.button_pressed.connect(_on_controller_button)
		_origin.add_child(controller)

	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	# Lighter than the panels: a hole around a rounded corner shows as black.
	environment.background_color = Color(0.3, 0.34, 0.38)
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)

	_build()
	_place(START_HEAD, 0.0)

	var view := get_viewport()
	view.msaa_3d = Viewport.MSAA_4X
	_xr = XRServer.find_interface("OpenXR") as OpenXRInterface
	if _xr != null and _xr.is_initialized():
		view.use_xr = true
		view.vrs_mode = Viewport.VRS_XR
		_xr.session_begun.connect(_on_session_begun)
		_xr.pose_recentered.connect(_place_at_head)
	else:
		_xr = null
		print("comp_layer: no OpenXR; every layer is drawn as a mesh.")
		# vrs/mode, needed in the headset, leaves only the background in a window.
		view.vrs_mode = Viewport.VRS_DISABLED
	if arguments.has("--reveal"):
		_reveal()


func _process(delta: float) -> void:
	_time += delta
	if _xr != null and not _head_found and _camera.position != Vector3.ZERO and _camera.position != START_HEAD:
		_head_found = true
		_place_at_head()
	var width := (float(LOGICAL_SIZE.x) * PIXEL_SIZE + GAP) * 1.5
	_cube.global_transform = _base * Transform3D(Basis.IDENTITY,
			Vector3(sin(_time * CUBE_SPEED) * width, 0.0, CUBE_IN_FRONT))
	if not _shot_path.is_empty():
		_frames += 1
		if _frames == SHOT_FRAMES:
			var error := get_viewport().get_texture().get_image().save_png(_shot_path)
			print("comp_layer: shot %s, error %d." % [_shot_path, error])
			get_tree().quit()


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key != null and key.pressed and key.keycode == KEY_SPACE:
		_reveal()


func _build() -> void:
	var size_m := Vector2(LOGICAL_SIZE) * PIXEL_SIZE
	for column in _kinds.size():
		var x := (float(column) - 1.0) * (size_m.x + GAP)
		for row in RENDER_SCALES.size():
			var y := (0.5 - float(row)) * (size_m.y + GAP)
			var panel := _make_panel(_kinds[column], RENDER_SCALES[row], size_m)
			_origin.add_child(panel)
			_add_placed(panel, Vector3(x, y, 0.0))
		var letter := _make_label(LETTERS[column], 48)
		_letters.append(letter)
		_add_placed(letter, Vector3(x, size_m.y + GAP * 1.5, 0.0))
	for row in RENDER_SCALES.size():
		var label := _make_label("%d×" % int(RENDER_SCALES[row]), 32)
		_add_placed(label, Vector3(-1.5 * size_m.x - GAP * 2.5, (0.5 - float(row)) * (size_m.y + GAP), 0.0))

	var box := BoxMesh.new()
	box.size = Vector3.ONE * CUBE_SIZE
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.95, 0.55, 0.15)
	box.material = material
	_cube = MeshInstance3D.new()
	_cube.mesh = box
	_origin.add_child(_cube)


func _add_placed(node: Node3D, local_position: Vector3) -> void:
	_placed.append(node)
	_local.append(Transform3D(Basis.IDENTITY, local_position))


func _make_label(text: String, font_size: int) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font_size = font_size
	label.pixel_size = 0.001
	_origin.add_child(label)
	return label


func _make_panel(kind: Kind, render_scale: float, size_m: Vector2) -> Node3D:
	var viewport := _make_viewport(render_scale)
	if kind == Kind.IN_FRAME:
		var quad := QuadMesh.new()
		quad.size = size_m
		var shader := Shader.new()
		shader.code = PANEL_SHADER
		var material := ShaderMaterial.new()
		material.shader = shader
		material.set_shader_parameter(&"panel_texture", viewport.get_texture())
		var mesh := MeshInstance3D.new()
		mesh.mesh = quad
		mesh.material_override = material
		return mesh
	var layer := OpenXRCompositionLayerQuad.new()
	layer.quad_size = size_m
	layer.layer_viewport = viewport
	layer.alpha_blend = true
	if kind == Kind.LAYER_HOLE_PUNCH:
		layer.enable_hole_punch = true
		layer.sort_order = -1
	_layers.append(layer)
	return layer


func _make_viewport(render_scale: float) -> SubViewport:
	var style := StyleBoxFlat.new()
	style.bg_color = WINDOW_COLOR
	style.set_corner_radius_all(CORNER_RADIUS)
	style.set_content_margin_all(8.0)
	var frame := PanelContainer.new()
	frame.add_theme_stylebox_override(&"panel", style)
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var rows := VBoxContainer.new()
	frame.add_child(rows)
	for font_size: int in FONT_SIZES:
		var label := Label.new()
		label.text = "%d %s" % [font_size, TEXT]
		label.add_theme_font_size_override(&"font_size", font_size)
		label.clip_text = true
		rows.add_child(label)
	var lines := Lines.new()
	lines.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows.add_child(lines)

	var viewport := SubViewport.new()
	viewport.size = Vector2i((Vector2(LOGICAL_SIZE) * render_scale).round())
	viewport.size_2d_override = LOGICAL_SIZE
	viewport.size_2d_override_stretch = true
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.add_child(frame)
	add_child(viewport)
	return viewport


func _on_session_begun() -> void:
	print("comp_layer: session begun, render target %s, quad layers by the runtime: %s." % [
			_xr.get_render_target_size(), _layers[0].is_natively_supported()])


func _on_controller_button(button: String) -> void:
	if button == "trigger_click":
		_reveal()


## Puts the panels straight ahead of the head, level.
func _place_at_head() -> void:
	var forward := -_camera.global_basis.z
	_place(_camera.global_position, atan2(-forward.x, -forward.z))


func _place(head: Vector3, yaw: float) -> void:
	var facing := Basis(Vector3.UP, yaw)
	_base = Transform3D(facing, head + facing * Vector3(0.0, 0.0, -DISTANCE))
	for i in _placed.size():
		_placed[i].global_transform = _base * _local[i]


func _reveal() -> void:
	if _revealed:
		return
	_revealed = true
	var native := _xr != null and _layers[0].is_natively_supported()
	for column in _letters.size():
		var kind := _kinds[column]
		var note := "" if kind == Kind.IN_FRAME or native else " (drawn as a mesh!)"
		_letters[column].text = "%s: %s%s" % [LETTERS[column], KIND_NAMES[kind], note]
		_letters[column].font_size = 24
		print("comp_layer: %s" % _letters[column].text)
