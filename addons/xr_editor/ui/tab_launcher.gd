@tool
class_name XRETabLauncher
extends XREPanelSurface
## The tab launcher, drawn as the app library of Meta Horizon OS's Navigator
## (docs/decisions.md, D-041, D-042): no panel behind it, icons with their
## titles under them in offset rows — five, then three, centered (D-045) — and a
## pill-shaped dock at the bottom with the library's glyph, lit as the open
## page, and the time. [XREPanels] shows it in front of the user on its button (D-050), dims
## the scene behind it, and hides it again; a click on a tile asks for that
## tab's window ([signal tab_chosen]). The ray on a tile grows its icon.
## The launcher is concave and fades in and out (D-043 — D-045). After the
## tabs, the Playtest tile plays the edited scene, as the play button does
## ([signal playtest_chosen], D-082).

## Emitted when the tile of the tab of class [param type] is clicked.
signal tab_chosen(type: GDScript)
## Emitted when the Playtest tile is clicked.
signal playtest_chosen

## Layout at editor scale 1, in interface pixels: tiles in the long rows, a
## tile and the icon on it, the space between tiles and rows, the dock's
## height.
const LONG_ROW := 5
const TILE_SIZE := Vector2(120.0, 116.0)
const ICON_SIZE := 72.0
const SPACING := 16.0
const DOCK_HEIGHT := 52.0
const MARGIN := 16.0
## How much the icon under the ray grows.
const HOVER_SCALE := 1.12
const DOCK_COLOR := Color(0.08, 0.09, 0.1, 0.94)
## The Playtest tile's icon ([XRETabIcons]) and title.
const PLAYTEST_SYMBOL := &"playtest"
const PLAYTEST_TITLE := "Playtest"

var _tiles: Dictionary[GDScript, Button] = {}
var _playtest: Button
var _clock: Label
var _clock_usec := -1000000


## A launcher of tabs [param tabs], whose classes are [param types] in the same
## order; the tabs give the tiles their icons and titles and are not kept.
func _init(types: Array[GDScript], tabs: Array[XREPanelTab], logical_size: Vector2, pixel_size: float,
		render_scale: float, theme: Theme) -> void:
	super(logical_size, pixel_size, render_scale, theme)
	var layout_scale := logical_size.x / size_for(types.size()).x
	root.add_theme_stylebox_override(&"panel", StyleBoxEmpty.new())
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override(&"separation", roundi(SPACING * layout_scale))
	root.add_child(column)
	var tiles: Array[Button] = []
	for index: int in types.size():
		var tile := _make_tile(tabs[index].get_symbol(), tabs[index].get_title(), render_scale, layout_scale)
		tile.pressed.connect(tab_chosen.emit.bind(types[index]))
		tiles.append(tile)
		_tiles[types[index]] = tile
	_playtest = _make_tile(PLAYTEST_SYMBOL, PLAYTEST_TITLE, render_scale, layout_scale)
	_playtest.pressed.connect(playtest_chosen.emit)
	tiles.append(_playtest)
	var row: HBoxContainer = null
	var in_row := 0
	for tile: Button in tiles:
		if row == null or row.get_child_count() == in_row:
			row = HBoxContainer.new()
			row.alignment = BoxContainer.ALIGNMENT_CENTER
			row.add_theme_constant_override(&"separation", roundi(SPACING * layout_scale))
			column.add_child(row)
			in_row = LONG_ROW if column.get_child_count() % 2 == 1 else LONG_ROW - 1
		row.add_child(tile)

	var dock_row := CenterContainer.new()
	column.add_child(dock_row)
	var dock := PanelContainer.new()
	dock.name = "Dock"
	dock.add_theme_stylebox_override(&"panel", meta_style(DOCK_COLOR, roundi(DOCK_HEIGHT * 0.5 * layout_scale),
			8.0 * layout_scale))
	dock_row.add_child(dock)
	var items := HBoxContainer.new()
	items.add_theme_constant_override(&"separation", roundi(10 * layout_scale))
	dock.add_child(items)
	var library := TextureRect.new()
	library.name = "Library"
	library.texture = XRETabIcons.glyph(&"library", roundi(20 * layout_scale * render_scale))
	library.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	library.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var lit := PanelContainer.new()
	var circle := (DOCK_HEIGHT - 16.0) * layout_scale
	lit.custom_minimum_size = Vector2(circle, circle)
	lit.add_theme_stylebox_override(&"panel", meta_style(Color(1.0, 1.0, 1.0, 0.22), roundi(circle * 0.5), 8.0 * layout_scale))
	lit.add_child(library)
	items.add_child(lit)
	_clock = Label.new()
	_clock.name = "Clock"
	_clock.add_theme_color_override(&"font_color", Color(1.0, 1.0, 1.0, 0.85))
	_clock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	items.add_child(_clock)
	update_clock()


## Size of a launcher of [param count] tabs and the Playtest tile at editor
## scale 1, in interface pixels.
static func size_for(count: int) -> Vector2:
	var rows := 0
	var left := count + 1
	while left > 0:
		left -= LONG_ROW if rows % 2 == 0 else LONG_ROW - 1
		rows += 1
	return Vector2(TILE_SIZE.x * LONG_ROW + SPACING * (LONG_ROW - 1) + MARGIN * 2.0,
			TILE_SIZE.y * rows + SPACING * rows + DOCK_HEIGHT + MARGIN * 2.0)


## The tile of the tab of class [param type], or null.
func get_tile(type: GDScript) -> Button:
	return _tiles.get(type)


## The Playtest tile, after the tabs' tiles.
func get_playtest_tile() -> Button:
	return _playtest


## The title under the tile of the tab of class [param type].
func get_tile_title(type: GDScript) -> String:
	return (_tiles[type].find_child("Title", true, false) as Label).text


## The icon on the tile of the tab of class [param type].
func get_tile_icon(type: GDScript) -> TextureRect:
	return _tiles[type].find_child("Icon", true, false) as TextureRect


## Shows the time in the dock, as HH:MM; checks the clock once a second at most.
func update_clock() -> void:
	var now := Time.get_ticks_usec()
	if now - _clock_usec < 1000000:
		return
	_clock_usec = now
	_clock.text = Time.get_time_string_from_system().left(5)


func _make_tile(symbol: StringName, title_text: String, render_scale: float, layout_scale: float) -> Button:
	var tile := Button.new()
	tile.name = String(symbol).to_pascal_case()
	tile.custom_minimum_size = TILE_SIZE * layout_scale
	for state: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"focus", &"disabled"]:
		tile.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var stack := VBoxContainer.new()
	stack.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_theme_constant_override(&"separation", roundi(6 * layout_scale))
	tile.add_child(stack)
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.texture = XRETabIcons.tab(symbol, roundi(ICON_SIZE * HOVER_SCALE * layout_scale * render_scale))
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2.ONE * ICON_SIZE * layout_scale
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.pivot_offset = icon.custom_minimum_size * 0.5
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(icon)
	var title := Label.new()
	title.name = "Title"
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.add_theme_color_override(&"font_color", Color.WHITE)
	title.add_theme_color_override(&"font_shadow_color", Color(0.0, 0.0, 0.0, 0.6))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(title)
	tile.mouse_entered.connect(func() -> void: icon.scale = Vector2.ONE * HOVER_SCALE)
	tile.mouse_exited.connect(func() -> void: icon.scale = Vector2.ONE)
	return tile
