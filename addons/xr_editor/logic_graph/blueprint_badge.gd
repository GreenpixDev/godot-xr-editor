@tool
class_name XREBlueprintBadge
extends XREPanelSurface
## The badge over the selected object (D-082), object-locked (docs/vr_ui.md):
## a pill as a window's control bar is (D-042), hung over the object on a
## dashed leader that ends in a dot on top of it.
##
## In the scene ([method show_scene]) it holds the object's name and the
## Blueprint button: filled when the object has a graph, which it opens, and
## faint with a plus when it has none, which it creates. In the graph
## ([method show_graph]) it holds the graph's name and round buttons: add a
## block, delete the Blueprint, close the graph. Delete asks once more: the
## first click arms it, red, for [constant ARM_USEC]. A message
## ([method show_message]) shows over the pill for [constant MESSAGE_USEC].
## [XREBlueprints] places it each frame ([method place], [method float_at]).

## Emitted by the Blueprint button in the scene.
signal blueprint_pressed
## Emitted by the plus in the graph.
signal add_pressed
## Emitted by the trash's second click.
signal delete_pressed
## Emitted by × in the graph.
signal close_pressed

## The pill, in interface pixels, each [constant PIXEL_SIZE] meters: 23 × 4 cm.
const SIZE := Vector2(360.0, 64.0)
const PIXEL_SIZE := 0.00065
const BUTTON_SIZE := 44.0
const GLYPH_SIZE := 26.0
## The Blueprint button's glyph, beside its text, as tall as a capital letter and a half.
const LABEL_GLYPH_SIZE := 20.0
const ICON_SIZE := 34.0
## The Blueprints' colors (the tab's icon): the Blueprint button's fill, lit and pressed.
const ACCENT := Color("1f8fb5")
const ACCENT_LIT := Color("2ba3cc")
const ACCENT_PRESSED := Color("4fd0e8")
const ARMED := Color(0.86, 0.2, 0.18)
## The leader from the object's top to the pill, in meters at full size: its
## length, thickness, one dash and gap, and the dot on the object.
const GAP := 0.1
const LEADER_RADIUS := 0.0011
const DASH := 0.008
const DOT_RADIUS := 0.0045
const LEADER_COLOR := Color(0.88, 0.9, 0.94, 0.85)
## How long the trash waits for its second click, and a message stays, in microseconds.
const ARM_USEC := 3000000
const MESSAGE_USEC := 4000000

static var _leader_shader: Shader
static var _leader_top_shader: Shader

var _scene_row: HBoxContainer
var _graph_row: HBoxContainer
var _name: Label
var _blueprint: Button
var _title: Label
var _add: Button
var _trash: Button
var _close: Button
var _graph_name := ""
var _armed_usec := -1
var _message: Label3D
var _message_usec := -1
var _leader: MeshInstance3D
var _dot: MeshInstance3D
var _leader_scene: ShaderMaterial
var _leader_top: ShaderMaterial
var _dot_scene: StandardMaterial3D
var _dot_top: StandardMaterial3D
var _filled_styles: Array[StyleBoxFlat] = []
var _faint_styles: Array[StyleBoxFlat] = []
var _trash_styles: Array[StyleBoxFlat] = []
var _armed_styles: Array[StyleBoxFlat] = []


func _init(theme: Theme) -> void:
	super(SIZE, PIXEL_SIZE, 1.5, theme)
	name = "Badge"
	root.add_theme_stylebox_override(&"panel", meta_style(XREPanelWindow.BAR_COLOR, roundi(SIZE.y * 0.5), 10.0))
	var bold: Font = theme.get_font(&"bold", &"EditorFonts") if theme != null and theme.has_font(&"bold", &"EditorFonts") else null
	var rows := Control.new()
	root.add_child(rows)

	_scene_row = _row(rows)
	_name = _label(_scene_row, bold)
	var radius := roundi(BUTTON_SIZE * 0.5)
	_filled_styles = [_pill_style(ACCENT), _pill_style(ACCENT_LIT), _pill_style(ACCENT_PRESSED)]
	_faint_styles = [_pill_style(Color(1, 1, 1, 0.12)), _pill_style(Color(1, 1, 1, 0.22)), _pill_style(Color(1, 1, 1, 0.32))]
	_blueprint = Button.new()
	_blueprint.name = "Blueprint"
	_blueprint.text = "Blueprint"
	# As tall as the round buttons of the graph's badge and centered in the pill: its glyph,
	# drawn at its own size, made it taller than the pill had room for.
	_blueprint.custom_minimum_size = Vector2(0, BUTTON_SIZE)
	_blueprint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_blueprint.add_theme_constant_override(&"icon_max_width", roundi(LABEL_GLYPH_SIZE))
	_blueprint.add_theme_constant_override(&"h_separation", 8)
	_blueprint.add_theme_color_override(&"font_color", Color.WHITE)
	_blueprint.add_theme_color_override(&"font_hover_color", Color.WHITE)
	_blueprint.add_theme_color_override(&"font_pressed_color", Color.WHITE)
	if bold != null: _blueprint.add_theme_font_override(&"font", bold)
	_blueprint.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())
	_blueprint.pressed.connect(blueprint_pressed.emit)
	_scene_row.add_child(_blueprint)

	_graph_row = _row(rows)
	var icon := TextureRect.new()
	icon.texture = XRETabIcons.tab(&"blueprints", roundi(ICON_SIZE * 1.5))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2.ONE * ICON_SIZE
	_graph_row.add_child(icon)
	_title = _label(_graph_row, bold)
	var glyph_px := roundi(GLYPH_SIZE * 1.5)
	_add = _round_button(_graph_row, "Add block", &"plus", glyph_px)
	_add.pressed.connect(func() -> void:
		_disarm()
		add_pressed.emit())
	_trash = _round_button(_graph_row, "Delete Blueprint", &"trash", glyph_px)
	_trash_styles = _styles_of(_trash)
	_armed_styles = [meta_style(ARMED, radius, (BUTTON_SIZE - GLYPH_SIZE) * 0.5), meta_style(ARMED.lightened(0.15), radius, (BUTTON_SIZE - GLYPH_SIZE) * 0.5),
			meta_style(ARMED.lightened(0.3), radius, (BUTTON_SIZE - GLYPH_SIZE) * 0.5)]
	_trash.pressed.connect(_trash_pressed)
	# Close stands apart from the graph's own buttons, last, as on a window's control bar.
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(6, 0)
	_graph_row.add_child(gap)
	var line := ColorRect.new()
	line.color = Color(1, 1, 1, 0.18)
	line.custom_minimum_size = Vector2(2, 26)
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_graph_row.add_child(line)
	_close = _round_button(_graph_row, "Close Blueprint", &"close", glyph_px)
	_close.pressed.connect(func() -> void:
		_disarm()
		close_pressed.emit())

	_message = XRERig.create_vr_label(26, 0.00042)
	_message.name = "Message"
	_message.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.width = size_m.x * 1.4 / 0.00042
	_message.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_message.outline_size = 8
	_message.outline_modulate = Color(0.05, 0.06, 0.07, 0.9)
	_message.position = Vector3(0, size_m.y * 0.5 + 0.008, 0.001)
	_message.visible = false
	add_child(_message)

	_leader_scene = _leader_material(false)
	_leader_top = _leader_material(true)
	var tube := CylinderMesh.new()
	tube.top_radius = LEADER_RADIUS
	tube.bottom_radius = LEADER_RADIUS
	tube.height = 1.0
	tube.radial_segments = 6
	tube.rings = 1
	tube.cap_top = false
	tube.cap_bottom = false
	_leader = XRERig.create_vr_mesh(tube, _leader_scene)
	_leader.name = "Leader"
	_leader.top_level = true
	add_child(_leader)
	_dot_scene = _dot_material(false)
	_dot_top = _dot_material(true)
	var sphere := SphereMesh.new()
	sphere.radius = DOT_RADIUS
	sphere.height = DOT_RADIUS * 2.0
	sphere.radial_segments = 12
	sphere.rings = 6
	_dot = XRERig.create_vr_mesh(sphere, _dot_scene)
	_dot.name = "Dot"
	_dot.top_level = true
	add_child(_dot)
	show_scene("", false)


## The scene's badge for the object [param object_name]: its Blueprint button
## opens the object's graph if [param has_blueprint], else creates one.
func show_scene(object_name: String, has_blueprint: bool) -> void:
	_disarm()
	_scene_row.visible = true
	_graph_row.visible = false
	_name.text = object_name
	_blueprint.icon = XRETabIcons.glyph(&"blueprint" if has_blueprint else &"plus", roundi(GLYPH_SIZE * 1.5))
	_blueprint.tooltip_text = "Open Blueprint" if has_blueprint else "Create Blueprint"
	_set_styles(_blueprint, _filled_styles if has_blueprint else _faint_styles)


## The graph's badge, named [param graph_name]: add a block, delete, close.
func show_graph(graph_name: String) -> void:
	_scene_row.visible = false
	_graph_row.visible = true
	_graph_name = graph_name
	if _armed_usec < 0: _title.text = graph_name


## Whether the badge shows the graph's buttons.
func is_graph() -> bool:
	return _graph_row.visible


## Whether the trash waits for its second click.
func is_armed() -> bool:
	return _armed_usec >= 0


## Shows [param text] over the pill for a moment.
func show_message(text: String) -> void:
	_message.text = text
	_message.visible = not text.is_empty()
	_message_usec = Time.get_ticks_usec()


## The message shown over the pill, or an empty string.
func get_message() -> String:
	return _message.text if _message.visible else ""


## The button of the scene's badge: Blueprint.
func get_blueprint_button() -> Button:
	return _blueprint


## The graph's badge's buttons: add a block, delete, close.
func get_add_button() -> Button:
	return _add


func get_trash_button() -> Button:
	return _trash


func get_close_button() -> Button:
	return _close


## The leader to the object and the dot on it: [XREBlueprints]'s tests look at them.
func get_leader() -> MeshInstance3D:
	return _leader


func get_dot() -> MeshInstance3D:
	return _dot


## Hangs the pill over [param top], the top of the object, facing [param head]:
## the leader's [constant GAP] up, all [param grown] times as large (far away,
## the badge keeps its size in view). Called each frame; allocates nothing.
func place(top: Vector3, head: Vector3, up: Vector3, grown: float) -> void:
	var bottom := top + up * (GAP * grown)
	var point := bottom + up * (size_m.y * 0.5 * grown)
	global_transform = Transform3D(XREPanels.facing(point, head, up) * Basis.from_scale(Vector3.ONE * grown), point)
	var along := bottom - top
	var length := maxf(along.length(), 0.001)
	_leader.global_transform = Transform3D(Basis(Quaternion(Vector3.UP, along / length)) * Basis.from_scale(Vector3(grown, length, grown)), top + along * 0.5)
	_dot.global_transform = Transform3D(Basis.from_scale(Vector3.ONE * grown), top)
	(_leader.material_override as ShaderMaterial).set_shader_parameter(&"dashes", length / (DASH * 2.0 * grown))
	_leader.visible = true
	_dot.visible = true
	_expire()


## Puts the pill at [param pose], without a leader: a graph with no object.
func float_at(pose: Transform3D) -> void:
	global_transform = pose
	_leader.visible = false
	_dot.visible = false
	_expire()


## In the graph the badge is drawn over everything, the leader too, so that
## neither the graph's cards nor the dimmed scene hide its ×; its ray hit then
## wins over nearer cards ([method XREPanelSurface.set_on_top]).
func set_on_top(enabled: bool) -> void:
	super(enabled)
	_leader.material_override = _leader_top if enabled else _leader_scene
	_dot.material_override = _dot_top if enabled else _dot_scene
	_message.no_depth_test = enabled
	_message.render_priority = Material.RENDER_PRIORITY_MAX if enabled else 0


func set_shown(shown: bool) -> void:
	if not shown: _disarm()
	super(shown)


func _trash_pressed() -> void:
	if _armed_usec >= 0:
		_disarm()
		delete_pressed.emit()
		return
	_armed_usec = Time.get_ticks_usec()
	_title.text = "Delete Blueprint?"
	_title.add_theme_color_override(&"font_color", ARMED.lightened(0.35))
	_set_styles(_trash, _armed_styles)


func _disarm() -> void:
	if _armed_usec < 0: return
	_armed_usec = -1
	_title.text = _graph_name
	_title.add_theme_color_override(&"font_color", Color.WHITE)
	_set_styles(_trash, _trash_styles)


## Lets go of the trash and of the message once their time is up.
func _expire() -> void:
	var now := Time.get_ticks_usec()
	if _armed_usec >= 0 and now - _armed_usec > ARM_USEC: _disarm()
	if _message.visible and now - _message_usec > MESSAGE_USEC: _message.visible = false


func _row(parent: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override(&"separation", 4)
	row.alignment = BoxContainer.ALIGNMENT_END
	parent.add_child(row)
	return row


func _label(row: HBoxContainer, bold: Font) -> Label:
	var label := Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override(&"font_color", Color.WHITE)
	if bold != null: label.add_theme_font_override(&"font", bold)
	# Off the pill's rounded end.
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override(&"margin_left", 10)
	margin.add_child(label)
	row.add_child(margin)
	return label


## A round icon button, as a window's control bar has (XREPanelWindow), lit while the ray is on it.
func _round_button(row: HBoxContainer, tooltip: String, glyph_name: StringName, glyph_px: int) -> Button:
	var button := Button.new()
	button.name = tooltip.replace(" ", "")
	button.tooltip_text = tooltip
	button.icon = XRETabIcons.glyph(glyph_name, glyph_px)
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.custom_minimum_size = Vector2.ONE * BUTTON_SIZE
	var radius := roundi(BUTTON_SIZE * 0.5)
	var margin := (BUTTON_SIZE - GLYPH_SIZE) * 0.5
	_set_styles(button, [meta_style(Color(1, 1, 1, 0.0), radius, margin), meta_style(Color(1, 1, 1, 0.16), radius, margin), meta_style(Color(1, 1, 1, 0.28), radius, margin)])
	button.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())
	row.add_child(button)
	return button


## The Blueprint button's frame: a pill as tall as the button, padded only at its ends,
## a little more after the text than before the glyph, as the eye measures a round end.
static func _pill_style(color: Color) -> StyleBoxFlat:
	var style := meta_style(color, roundi(BUTTON_SIZE * 0.5), 0.0)
	style.content_margin_left = 14.0
	style.content_margin_right = 18.0
	return style


## [param styles]: normal, hover, pressed.
static func _set_styles(button: Button, styles: Array[StyleBoxFlat]) -> void:
	button.add_theme_stylebox_override(&"normal", styles[0])
	button.add_theme_stylebox_override(&"hover", styles[1])
	button.add_theme_stylebox_override(&"pressed", styles[2])
	button.add_theme_stylebox_override(&"hover_pressed", styles[2])


static func _styles_of(button: Button) -> Array[StyleBoxFlat]:
	return [button.get_theme_stylebox(&"normal") as StyleBoxFlat, button.get_theme_stylebox(&"hover") as StyleBoxFlat, button.get_theme_stylebox(&"pressed") as StyleBoxFlat]


## Dashes counted from the object's end, so that they stand still as the leader grows.
## On top, as the graph draws it: over the dimmed scene, with no depth test.
static func _leader_material(on_top: bool) -> ShaderMaterial:
	if (_leader_top_shader if on_top else _leader_shader) == null:
		var shader := Shader.new()
		shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, fog_disabled%s;
uniform vec4 tint : source_color = vec4(1.0);
uniform float dashes = 4.0;
varying float along;
void vertex() { along = VERTEX.y + 0.5; }
void fragment() {
	if (fract(along * dashes) > 0.5) discard;
	ALBEDO = tint.rgb;
	ALPHA = tint.a;
}
""" % (", depth_test_disabled" if on_top else "")
		if on_top: _leader_top_shader = shader
		else: _leader_shader = shader
	var material := ShaderMaterial.new()
	material.shader = _leader_top_shader if on_top else _leader_shader
	material.render_priority = Material.RENDER_PRIORITY_MAX if on_top else 0
	material.set_shader_parameter(&"tint", LEADER_COLOR)
	return material


static func _dot_material(on_top: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = LEADER_COLOR
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = on_top
	material.render_priority = Material.RENDER_PRIORITY_MAX if on_top else 0
	return material
