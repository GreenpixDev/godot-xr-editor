@tool
class_name XREBlueprintActionMenu
extends VBoxContainer
## The menu that adds a block (D-051), in the desktop view and in the
## headset's Add block window alike: chips that pick what is listed — a
## context object, the library, @GlobalScope, the native blocks or all of
## them — a row under them that picks one of their sections, such as one class
## of the object, or All (D-063), as buttons a dimmer gray than the chips
## (D-064), a search field, the pin a wire comes from,
## and the actions in sections ([XREBlueprintActions]). A click on a row
## chooses it; a row pulled out of the list sideways is dragged, so that the
## view places its block where the pull ends.
##
## Two variants of the headset's palette (D-090): tiles of the blocks most
## likely next over the chips ([method set_tiles]), and chips by task —
## Events, Math, Move and the rest ([constant XREBlueprintActions.TASKS]) —
## instead of by source ([method set_task_groups]). A chosen action carries
## where it was picked, [code]origin[/code]: "tile", "list" or "search".

## A row or a tile was clicked; [param action] has its [code]origin[/code].
signal action_chosen(action: Dictionary)
## A row was pressed and pulled out of the list while held.
signal action_dragged(action: Dictionary)
## The pin filter was cleared: the next block is added without a wire.
signal pin_cleared
## A click on the search field, for a headset's keyboard.
signal text_edit_requested(field: LineEdit)

## Colors of the kinds' icons: events, calls, pure functions, waits, properties, presets, native blocks, variables.
const KIND_COLORS: Dictionary[String, Color] = {
	"event": Color("a83c36"), "call": Color("2f6db5"), "pure": Color("357a4f"), "latent": Color("6e4aa8"),
	"property": Color("9a5f1f"), "preset": Color("8a6d12"), "native": Color("4f5666"), "variable": Color("323e73"),
}
const GROUPS: Array[StringName] = [XREBlueprintActions.LIBRARY, XREBlueprintActions.GLOBAL, XREBlueprintActions.NATIVE, XREBlueprintActions.ALL]
const GROUP_TITLES: Array[String] = ["Library", "Global", "Native", "All"]
## How much darker than a chip a section's button is (D-064): a dimmer gray, a
## level under the chips; the picked one less so.
const SECTION_DIM := 0.3
const SECTION_PICKED_DIM := 0.12
## How many tiles there are, and in how many columns (D-090).
const TILE_COUNT := 12
const TILE_COLUMNS := 4
## How much darker than its kind's color a tile is, and its hovered and pressed look.
const TILE_DIM := 0.3
const TILE_HOVER_DIM := 0.1

var actions := XREBlueprintActions.shared()
## What the tiles are ranked by (D-090).
var stats := XREBlueprintStats.shared()
## Whether the menu offers new variables (D-078): the headset's graph adds them
## as boxes where they are put; the desktop has its Variables dialog for that.
var offers_variables := false
var search: LineEdit
var tree: Tree
## The tiles over the chips (D-090) and the actions they add.
var _tiles: GridContainer
var _tile_actions: Array[Dictionary] = []
var _tiles_shown := false
## Whether the chips are the task groups (D-090) rather than the context objects and sources.
var _tasks := false
## The task groups the chips show (D-092): the general ones, then those the first context object has.
var _task_titles: Array[String] = []
var _chips: HFlowContainer
var _chip_group: ButtonGroup
## The sections of the chosen chip, All first (D-063), and the one picked: empty for All.
var _subs: HFlowContainer
var _sub_group: ButtonGroup
var _sub := ""
var _sub_titles: PackedStringArray = []
var _pin_row: HBoxContainer
var _pin_label: Label
var _contexts: Array[Dictionary] = []
var _chip := 0
var _pin: Dictionary = {}
var _host: Node
var _graph: XREBlueprintGraph
var _advanced := false
var _icons: Dictionary[String, Texture2D] = {}
var _pressed: TreeItem
var _dragged := false
var _large := false
var _context_key: Array = []


func _init() -> void:
	name = "ActionMenu"
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tiles = GridContainer.new()
	_tiles.name = "Tiles"
	_tiles.columns = TILE_COLUMNS
	_tiles.hide()
	add_child(_tiles)
	_chips = HFlowContainer.new()
	_chips.name = "Chips"
	add_child(_chips)
	_chip_group = ButtonGroup.new()
	_subs = HFlowContainer.new()
	_subs.name = "Sections"
	add_child(_subs)
	_sub_group = ButtonGroup.new()
	search = LineEdit.new()
	search.name = "Search"
	search.placeholder_text = "Search blocks"
	search.clear_button_enabled = true
	search.text_changed.connect(func(_text: String) -> void: refresh())
	search.gui_input.connect(_search_input)
	add_child(search)
	_pin_row = HBoxContainer.new()
	_pin_row.name = "Pin"
	add_child(_pin_row)
	_pin_label = Label.new()
	_pin_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_pin_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_pin_row.add_child(_pin_label)
	var clear := Button.new()
	clear.name = "ClearPin"
	clear.text = "×"
	clear.tooltip_text = "Show every block; the new one is added without a wire."
	clear.pressed.connect(clear_pin)
	_pin_row.add_child(clear)
	_pin_row.hide()
	tree = Tree.new()
	tree.name = "Actions"
	tree.columns = 2
	tree.hide_root = true
	tree.select_mode = Tree.SELECT_ROW
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree.set_column_expand_ratio(0, 3)
	tree.set_column_expand_ratio(1, 2)
	tree.gui_input.connect(_tree_input)
	tree.item_activated.connect(func() -> void: _choose(tree.get_selected()))
	add_child(tree)


## Larger rows and chips, for a headset (D-051): the ray picks a row without a keyboard.
func set_large(large: bool) -> void:
	_large = large
	tree.add_theme_constant_override(&"v_separation", 14 if large else 4)
	tree.add_theme_constant_override(&"icon_max_width", 22 if large else 14)
	_icons.clear()


## Shows the tiles of the blocks most likely next over the chips (D-090): those
## that fit the pin, ranked by [member stats] and what was added lately.
func set_tiles(shown: bool) -> void:
	if shown == _tiles_shown: return
	_tiles_shown = shown
	_update_tiles()
	if _graph != null: refresh()


## Groups the chips by task (D-090) — [constant XREBlueprintActions.TASKS] and
## All — or, as before, by context object and source.
func set_task_groups(tasks: bool) -> void:
	if tasks == _tasks: return
	_tasks = tasks
	_chip = 0
	_sub = ""
	_advanced = false
	_update_task_titles()
	_build_chips()
	if _graph != null: refresh()


## The actions of the tiles, in order; empty while they are hidden.
func get_tiles() -> Array[Dictionary]:
	if not _tiles_shown: return []
	return _tile_actions


## Opens the menu on [param contexts] — [code]{"label", "node", "class"}[/code],
## the first chosen — for a graph [param graph] hosted by [param host]. A
## [param pin] ([code]{"type", "output", "label"}[/code]) lists only blocks
## that can take its wire. The search starts empty.
func open(contexts: Array[Dictionary], host: Node, graph: XREBlueprintGraph, pin: Dictionary = {}) -> void:
	_contexts = contexts
	_host = host
	_graph = graph
	_pin = pin
	_chip = 0
	_sub = ""
	_advanced = false
	_context_key = []
	search.set_block_signals(true)
	search.text = ""
	search.set_block_signals(false)
	_update_task_titles()
	_build_chips()
	_update_tiles()
	refresh()


## Changes the context objects, keeping the chosen group, the pin and the search.
func set_contexts(contexts: Array[Dictionary], host: Node, graph: XREBlueprintGraph) -> void:
	var key: Array = [host, graph, graph.variables.duplicate(true) if graph != null else []]
	for context: Dictionary in contexts: key.append(context.get("node"))
	if key == _context_key: return
	_context_key = key
	var group := _chip - _contexts.size() if _chip >= _contexts.size() else -1
	_contexts = contexts
	_host = host
	_graph = graph
	if not _tasks: _chip = _contexts.size() + group if group >= 0 else 0
	else:
		# The task group chosen stays, as long as the new object has it; All stays All.
		var task := _task_titles[_chip] if _chip < _task_titles.size() else ""
		_update_task_titles()
		_chip = _task_titles.size() if task.is_empty() else maxi(_task_titles.find(task), 0)
	_build_chips()
	_update_tiles()
	refresh()


## The pin a wire comes from, or empty.
func get_pin() -> Dictionary:
	return _pin


## Lists every block again; the next one is added without a wire.
func clear_pin() -> void:
	if _pin.is_empty(): return
	_pin = {}
	_update_tiles()
	refresh()
	pin_cleared.emit()


## Picks chip [param index]: a context object first, then the groups; by
## task, a task group, then All.
func choose_chip(index: int) -> void:
	_chip = clampi(index, 0, (_task_titles.size() + 1 if _tasks else _contexts.size() + GROUPS.size()) - 1)
	_sub = ""
	_advanced = false
	for button: Node in _chips.get_children():
		(button as Button).set_pressed_no_signal(button.get_index() == _chip)
	refresh()


## Picks the section titled [param title] of the chosen chip (D-063), as its
## row under the chips says it; empty for All.
func choose_section(title: String) -> void:
	_sub = title
	refresh()


## The titles of the section row, All first; empty while the chip has one section.
func get_section_titles() -> PackedStringArray:
	return _sub_titles


## The short title of section [param title] in the row under the chips:
## "GreenCube · MeshInstance3D" is MeshInstance3D, "Node3D · inherited" Node3D.
static func short_title(title: String) -> String:
	if title.begins_with("Advanced"): return "Advanced"
	if title.begins_with("Signals · "): return "Signals"
	if title.ends_with(" · inherited"): return title.trim_suffix(" · inherited")
	if title.begins_with("Autoload · "): return title.trim_prefix("Autoload · ")
	return title.get_slice(" · ", title.get_slice_count(" · ") - 1)


## The titles of the chips, context objects first.
func get_chip_titles() -> PackedStringArray:
	var titles := PackedStringArray()
	for button: Node in _chips.get_children(): titles.append((button as Button).text)
	return titles


## The actions listed now, in order.
func get_listed() -> Array[Dictionary]:
	var listed: Array[Dictionary] = []
	var section := tree.get_root().get_first_child() if tree.get_root() != null else null
	while section != null:
		for row: TreeItem in section.get_children():
			if row.get_metadata(0) is Dictionary: listed.append(row.get_metadata(0))
		section = section.get_next()
	return listed


## Rebuilds the list from the chosen chip, the pin and the search.
func refresh() -> void:
	_pin_row.visible = not _pin.is_empty()
	if not _pin.is_empty():
		_pin_label.text = "%s %s" % ["From" if _pin.get("output", true) else "Into", _pin.get("label", "")]
	_tiles.visible = _tiles_shown and not _tile_actions.is_empty() and search.text.strip_edges().is_empty()
	tree.clear()
	var root := tree.create_item()
	var context := {"chip": XREBlueprintActions.CONTEXT, "host": _host, "graph": _graph, "pin": _pin, "query": search.text, "advanced": _advanced, "new_variables": offers_variables}
	if _tasks:
		# A task group lists the first context object's members of that task, as All does all of them.
		context = _first_context(context)
		if _chip < _task_titles.size(): context["task"] = _task_titles[_chip]
	elif _chip < _contexts.size():
		var chosen := _contexts[_chip]
		context["node"] = chosen.get("node")
		context["label"] = chosen.get("label", "")
		if chosen.has("class"): context["class"] = chosen["class"]
	else:
		context = _first_context(context)
		context["chip"] = GROUPS[_chip - _contexts.size()]
	# The row of sections comes from the chip and the pin, not the search, so that typing doesn't move it.
	var all := context.duplicate()
	all["query"] = ""
	all["advanced"] = true
	_sub_titles = PackedStringArray()
	for section: Dictionary in actions.sections(all):
		var short := short_title(str(section["title"]))
		if not section["title"] in ["Recent", "Best matches"] and not _sub_titles.has(short): _sub_titles.append(short)
	if _sub_titles.size() < 2: _sub_titles = PackedStringArray()
	if not _sub.is_empty() and not _sub_titles.has(_sub): _sub = ""
	if not _sub_titles.is_empty(): _sub_titles.insert(0, "All")
	_build_subs()
	if not _sub.is_empty(): context["advanced"] = true
	for section: Dictionary in actions.sections(context):
		if not _sub.is_empty() and short_title(str(section["title"])) != _sub: continue
		var header := tree.create_item(root)
		var count: int = section.get("count", 0)
		if section.get("advanced", false):
			header.set_text(0, ("▾ " if _advanced else "▸ ") + section["title"])
			header.set_text(1, "%d" % count)
			header.set_metadata(0, "advanced")
		else:
			header.set_text(0, str(section["title"]).to_upper())
		header.set_selectable(0, false)
		header.set_selectable(1, false)
		header.set_custom_color(0, Color("9aa3b2"))
		header.set_custom_color(1, Color("9aa3b2"))
		for action: Dictionary in section["actions"]:
			var row := tree.create_item(header)
			row.set_text(0, action["title"])
			row.set_text(1, action["subtitle"] if str(action["disabled"]).is_empty() else action["disabled"])
			row.set_icon(0, _icon(action["kind"]))
			row.set_metadata(0, action)
			row.set_tooltip_text(0, "%s\n%s" % [action["title"], action["subtitle"]])
			row.set_custom_color(1, Color("b3bac6"))
			if not str(action["disabled"]).is_empty():
				row.set_selectable(0, false)
				row.set_selectable(1, false)
				row.set_custom_color(0, Color("777d88"))
				row.set_tooltip_text(0, action["disabled"])
	if root.get_child_count() == 0:
		var empty := tree.create_item(root)
		empty.set_text(0, "Nothing matches." if not search.text.is_empty() else "No blocks here.")
		empty.set_text(1, "Clear the pin or pick All." if not _pin.is_empty() else "Pick All to search everything.")
		empty.set_selectable(0, false)
		empty.set_selectable(1, false)


## What the menu lists all the blocks for now (D-090): the first context
## object, the host, the graph, the pin — for [method XREBlueprintActions.suggest].
func menu_context() -> Dictionary:
	return _first_context({"host": _host, "graph": _graph, "pin": _pin, "new_variables": offers_variables})


## [param context] of all the blocks, on the first context object.
func _first_context(context: Dictionary) -> Dictionary:
	var result := context.duplicate()
	result["chip"] = XREBlueprintActions.ALL
	var first := _contexts[0] if not _contexts.is_empty() else {}
	result["node"] = first.get("node")
	if first.has("class"): result["class"] = first["class"]
	result["label"] = first.get("label", "")
	return result


## Ranks the tiles anew (D-090) for the pin and the context objects; nothing while they are hidden.
func _update_tiles() -> void:
	for child: Node in _tiles.get_children():
		_tiles.remove_child(child)
		child.queue_free()
	_tile_actions = []
	# Not before the menu first opens on a graph.
	if not _tiles_shown or _graph == null: return
	stats.update(_graph)
	_tile_actions = actions.suggest(menu_context(), TILE_COUNT, stats)
	for action: Dictionary in _tile_actions:
		var tile := Button.new()
		tile.text = action["title"]
		tile.tooltip_text = "%s\n%s" % [action["title"], action["subtitle"]]
		tile.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		tile.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tile.custom_minimum_size = Vector2(0, 64 if _large else 30)
		var color: Color = KIND_COLORS.get(action["kind"], KIND_COLORS["native"])
		for state: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"focus"]:
			var style := StyleBoxFlat.new()
			style.bg_color = color.darkened(TILE_HOVER_DIM if state in [&"hover", &"pressed", &"hover_pressed"] else TILE_DIM)
			style.border_color = Color(1, 1, 1, 0.9 if state in [&"hover", &"pressed", &"hover_pressed"] else 0.22)
			style.set_border_width_all(2 if _large else 1)
			style.set_corner_radius_all(10 if _large else 5)
			style.set_content_margin_all(6)
			if state == &"focus": style.draw_center = false
			tile.add_theme_stylebox_override(state, style)
		tile.pressed.connect(_choose_action.bind(action, "tile"))
		_tiles.add_child(tile)


func _build_subs() -> void:
	for child: Node in _subs.get_children():
		_subs.remove_child(child)
		child.queue_free()
	_subs.visible = not _sub_titles.is_empty()
	for title: String in _sub_titles:
		var chip := Button.new()
		chip.text = title
		chip.toggle_mode = true
		chip.button_group = _sub_group
		chip.button_pressed = title == (_sub if not _sub.is_empty() else "All")
		_dim(chip)
		# Class names and section titles as the actions have them, not translated by the editor.
		chip.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		chip.pressed.connect(choose_section.bind("" if title == "All" else title), CONNECT_DEFERRED)
		_subs.add_child(chip)


## Gives section button [param button] the chips' look, darker (D-064).
func _dim(button: Button) -> void:
	for state: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"disabled"]:
		var style := get_theme_stylebox(state, &"Button") as StyleBoxFlat
		if style == null: continue
		var dim := style.duplicate() as StyleBoxFlat
		dim.bg_color = dim.bg_color.darkened(SECTION_PICKED_DIM if state in [&"pressed", &"hover_pressed"] else SECTION_DIM)
		dim.border_color = dim.border_color.darkened(SECTION_DIM)
		button.add_theme_stylebox_override(state, dim)
	for color: StringName in [&"font_color", &"font_hover_color"]:
		button.add_theme_color_override(color, get_theme_color(color, &"Button").darkened(0.15))


func _notification(what: int) -> void:
	# The sections' look comes from the chips' theme, which may come later than they do.
	if what == NOTIFICATION_THEME_CHANGED and _subs != null:
		for child: Node in _subs.get_children(): _dim(child as Button)


## The task groups of the chips (D-092): the general ones, then those the first context object has.
func _update_task_titles() -> void:
	_task_titles = XREBlueprintActions.GENERAL_TASKS.duplicate()
	if _tasks: _task_titles.append_array(actions.object_tasks(menu_context()))


func _build_chips() -> void:
	for child: Node in _chips.get_children():
		_chips.remove_child(child)
		child.queue_free()
	var titles: Array[String] = []
	if _tasks:
		titles.append_array(_task_titles)
		titles.append("All")
	else:
		for context: Dictionary in _contexts: titles.append(str(context.get("label", "")))
		titles.append_array(GROUP_TITLES)
	for index: int in titles.size():
		var chip := Button.new()
		chip.text = titles[index]
		chip.toggle_mode = true
		chip.button_group = _chip_group
		chip.button_pressed = index == _chip
		chip.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		chip.pressed.connect(choose_chip.bind(index))
		_chips.add_child(chip)


func _choose(row: TreeItem) -> void:
	if row == null: return
	var action: Variant = row.get_metadata(0)
	if action is Dictionary and str((action as Dictionary)["disabled"]).is_empty():
		_choose_action(action, "list" if search.text.strip_edges().is_empty() else "search")
	elif action is String and action == "advanced":
		_advanced = not _advanced
		refresh()


## Chooses [param action], picked from [param origin] ("tile", "list" or "search").
func _choose_action(action: Dictionary, origin: String) -> void:
	actions.remember(action)
	var chosen := action.duplicate()
	chosen["origin"] = origin
	action_chosen.emit(chosen)


func _tree_input(event: InputEvent) -> void:
	var button := event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT:
		if button.pressed:
			_pressed = tree.get_item_at_position(button.position)
			_dragged = false
		elif _pressed != null:
			var released := tree.get_item_at_position(button.position)
			if not _dragged and released == _pressed:
				_choose(released)
			_pressed = null
		return
	var motion := event as InputEventMouseMotion
	if motion != null and _pressed != null and not _dragged and motion.button_mask & MOUSE_BUTTON_MASK_LEFT and not Rect2(Vector2.ZERO, tree.size).has_point(motion.position):
		var action: Variant = _pressed.get_metadata(0)
		if action is Dictionary and str((action as Dictionary)["disabled"]).is_empty():
			_dragged = true
			actions.remember(action)
			var dragged := (action as Dictionary).duplicate()
			dragged["origin"] = "list" if search.text.strip_edges().is_empty() else "search"
			action_dragged.emit(dragged)


func _search_input(event: InputEvent) -> void:
	var mouse := event as InputEventMouseButton
	if mouse != null and mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed:
		text_edit_requested.emit(search)


## A filled circle in the color of kind [param kind].
func _icon(kind: String) -> Texture2D:
	if _icons.has(kind): return _icons[kind]
	var size := 22 if _large else 14
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var color: Color = KIND_COLORS.get(kind, Color("4f5666"))
	var center := Vector2(size, size) * 0.5
	for y: int in size:
		for x: int in size:
			var inside := (Vector2(x, y) + Vector2(0.5, 0.5)).distance_to(center) <= size * 0.5 - 0.5
			image.set_pixel(x, y, color if inside else Color(0, 0, 0, 0))
	var texture := ImageTexture.create_from_image(image)
	_icons[kind] = texture
	return texture
