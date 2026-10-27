@tool
class_name XRESettingsTab
extends XREPanelTab
## Settings in the headset (D-039, D-116), drawn as the mockup "Новое меню
## Settings" is. Sections are on the left: Global, Editor and Controls
## ([enum XREFeatureSettings.Category]). The Editor's subsections
## ([constant XREFeatureSettings.GROUPS]) are a row over the settings or open
## under Editor on the left, as [constant XREFeatureSettings.SETTINGS_SUBSECTIONS]
## says. The sections fold to their icons, and the window narrows to
## [constant COLLAPSED_SIZE]; the subsections are then a row on top.
## [br][br]
## A setting is a row: its name, a blue dot and ↺ while it isn't at its
## default, and its values: a segmented row of up to four, a switch for On and
## Off, or a button opening a list under the row for [constant LIST_VALUES] and
## more. A setting that doesn't act with the current values
## ([method XREFeatureSettings.is_active]) is dimmed and says what it needs.
## The explanation of the row under the ray is at the bottom of the window, but
## not on a forearm, where there is no room for it. Reset in the header opens a
## menu over the page that puts back the defaults of the subsection, the
## section or every setting: the first click asks, a second within
## [constant CONFIRM_SEC] does it, as the Blueprint trash does (D-085). Every
## switch goes through [XREDocument] as an operation from a panel.
## [br][br]
## The Controls page (D-050) has the layouts of the controller buttons
## ([constant XREFeatureSettings.LAYOUTS]) in a row and a row per action: its
## name on the left, its button with the button's icon ([XREButtonGlyph]) on
## the right. A click on the button waits for a controller button
## ([method wants_button]); the one pressed becomes the action's, in the custom
## layout ([method XREDocument.set_binding]). Another click, or
## [constant CAPTURE_SEC] without a press, cancels the wait.

## How long a binding waits for a button, in seconds.
const CAPTURE_SEC := 5.0
## What a binding button says while it waits.
const PRESS_TEXT := "Press a button…"
## How long a reset waits for its second click, in seconds.
const CONFIRM_SEC := 3.0
## A setting with this many values or more picks one from a list under its row.
const LIST_VALUES := 5
## The window, and with the sections folded to their icons.
const WINDOW_SIZE := Vector2(640.0, 600.0)
const COLLAPSED_SIZE := Vector2(480.0, 600.0)
## Width of the sections on the left from the window's edge: with names, with
## the subsections under Editor, and as icons.
const NAV_WIDTH := 150.0
const TREE_WIDTH := 168.0
const COLLAPSED_WIDTH := 58.0
## Least width of a setting's name: values that don't fit beside it go under it.
const NAME_WIDTH := 130.0
## Below this height the explanation at the bottom is left out, as on a forearm.
const HINT_MIN_HEIGHT := 450.0
const HINT_LINES := 4
const HINT_TITLE := "Point at a setting"
const HINT_TEXT := "Its explanation shows here."
const MENU_WIDTH := 290.0
## Titles and glyphs ([XRETabIcons]) of the sections, by [enum XREFeatureSettings.Category].
const SECTION_TITLES: Array[String] = ["Global", "Editor", "Controls"]
const SECTION_GLYPHS: Array[StringName] = [&"globe", &"editor", &"controller"]
## What a reset puts back: the subsection's settings, the section's, every
## setting, or the controls layout to the runtime's.
const RESET_GROUP := &"group"
const RESET_SECTION := &"section"
const RESET_ALL := &"all"
const RESET_LAYOUT := &"layout"
## Colors of the mockup, a Meta Horizon OS window's (D-042).
const TEXT_COLOR := Color(0.945, 0.953, 0.969)
const MUTED_COLOR := Color(0.663, 0.69, 0.749)
const HINT_COLOR := Color(0.604, 0.631, 0.69)
const CAP_COLOR := Color(0.525, 0.553, 0.616)
const NAV_COLOR := Color(0.761, 0.784, 0.827)
const CURRENT_COLOR := Color(0.231, 0.251, 0.294)
const LINE_COLOR := Color(1.0, 1.0, 1.0, 0.07)
const FOOT_LINE_COLOR := Color(1.0, 1.0, 1.0, 0.08)
const ROW_HOT_COLOR := Color(1.0, 1.0, 1.0, 0.045)
const LINK_COLOR := Color(0.537, 0.678, 1.0)
const NEEDS_COLOR := Color(0.788, 0.643, 0.416)
const BORDER_COLOR := Color(0.227, 0.247, 0.286)
const LIST_COLOR := Color(0.149, 0.165, 0.196)
const LIST_HOVER_COLOR := Color(0.188, 0.208, 0.243)
const OPTION_COLOR := Color(0.875, 0.89, 0.918)
const RADIO_COLOR := Color(0.49, 0.522, 0.584)
const MENU_HOVER_COLOR := Color(0.204, 0.224, 0.267)
const ARMED_COLOR := Color(0.478, 0.149, 0.188)
const ARMED_NOTE_COLOR := Color(1.0, 0.851, 0.863)
const OFF_COLOR := Color(0.365, 0.392, 0.447)
const DIM_ALPHA := 0.42

var _section := XREFeatureSettings.Category.EDITOR
## The Editor's subsection shown, a key of [constant XREFeatureSettings.GROUPS].
var _group: StringName = XREFeatureSettings.GROUPS.keys()[0]
## Whether Editor's subsections are open under it, when they are on the left.
var _open := true
## Whether the sections are folded to their icons, the window narrower.
var _collapsed := false
## The editor's scale, from its theme's font size.
var _ui_scale := 1.0
## The page is built anew at the next refresh: the subsections moved, the sections folded or the scale changed.
var _rebuild := false
var _crumb: Label
var _reset_toggle: Button
var _menu: PanelContainer
var _reset_buttons: Dictionary[StringName, Button] = {}
var _reset_labels: Dictionary[StringName, Label] = {}
var _reset_notes: Dictionary[StringName, Label] = {}
## The reset waiting for its second click, or empty.
var _armed := &""
var _armed_until_usec := 0
## Section buttons by the section's name, and subsection buttons by the subsection's, on the left.
var _nav_buttons: Dictionary[StringName, Button] = {}
var _nav_badges: Dictionary[StringName, PanelContainer] = {}
var _nav_paint: Dictionary[StringName, Array] = {}
var _collapse: Button
## The subsections over the settings, or null.
var _subsections: XRESegmentRow
var _subsection_buttons: Dictionary[StringName, Button] = {}
var _scroll: ScrollContainer
var _content: VBoxContainer
var _foot: PanelContainer
var _hint_title: Label
var _hint: Label
## The row the ray is on, lit.
var _hot := &""
## A row's parts by setting key: the row, its name with the mark and ↺, its
## values, what it needs, its segments, switch or list.
var _rows: Dictionary[StringName, PanelContainer] = {}
var _names: Dictionary[StringName, HBoxContainer] = {}
var _marks: Dictionary[StringName, Control] = {}
var _values: Dictionary[StringName, Control] = {}
var _needs: Dictionary[StringName, Label] = {}
var _segments: Dictionary[StringName, XRESegmentRow] = {}
var _switches: Dictionary[StringName, XRESwitch] = {}
var _pickers: Dictionary[StringName, Button] = {}
var _picker_values: Dictionary[StringName, Label] = {}
var _picker_counts: Dictionary[StringName, Label] = {}
var _lists: Dictionary[StringName, PanelContainer] = {}
var _radios: Dictionary[StringName, Array] = {}
## Value buttons by setting key, in [method XREFeatureSettings.get_values] order: segments or a list's options.
var _buttons: Dictionary[StringName, Array] = {}
## The layouts' row and their buttons, on the Controls page.
var _layouts: XRESegmentRow
var _layout_buttons: Dictionary[StringName, Button] = {}
## Binding buttons by action, on the Controls page.
var _binding_buttons: Dictionary[StringName, Button] = {}
## The icon and the name in each binding button, by action.
var _binding_glyphs: Dictionary[StringName, XREButtonGlyph] = {}
var _binding_labels: Dictionary[StringName, Label] = {}
## The keys besides the buttons, shown while buttons are keys (D-057), or null off the Controls page.
var _keys_label: Label
## The action waiting for a button, or empty.
var _capturing := &""
var _capture_until_usec := 0


func _init(document: XREDocument) -> void:
	super(document)
	name = "Settings"
	add_theme_constant_override(&"separation", 0)
	# Freed with the tab: the connection goes with it.
	_document.features.changed.connect(_on_feature_changed)
	_build_page()


func get_title() -> String:
	return editor_text("Settings")


func get_symbol() -> StringName:
	return &"settings"


func get_window_size() -> Vector2:
	return COLLAPSED_SIZE if _collapsed else WINDOW_SIZE


## Shows section [param category], and of the Editor's subsection [param group] if given.
func select_section(category: XREFeatureSettings.Category, group: StringName = &"") -> void:
	_section = category
	if group in XREFeatureSettings.GROUPS:
		_group = group
	if category == XREFeatureSettings.Category.EDITOR:
		_open = true
	_build_page()


func get_section() -> XREFeatureSettings.Category:
	return _section


## The Editor's subsection shown.
func get_group() -> StringName:
	return _group


## Folds the sections to their icons, the window narrowing to
## [constant COLLAPSED_SIZE], or unfolds them.
func set_collapsed(collapsed: bool) -> void:
	if collapsed == _collapsed:
		return
	_collapsed = collapsed
	window_size_changed.emit()
	_build_page()


func is_collapsed() -> bool:
	return _collapsed


## The button under the sections that folds and unfolds them.
func get_collapse_button() -> Button:
	return _collapse


## The button of section [param section_name] ("global", "editor", "controls"),
## or of a subsection while they are on the left; null if it isn't shown.
func get_nav_button(section_name: StringName) -> Button:
	return _nav_buttons.get(section_name)


## The count on the section's or subsection's button, 0 without one.
func get_nav_count(section_name: StringName) -> int:
	var badge: PanelContainer = _nav_badges.get(section_name)
	return int((badge.get_child(0) as Label).text) if badge != null and badge.visible else 0


## The row of subsections over the settings, or null while they are on the left.
func get_subsection_row() -> XRESegmentRow:
	return _subsections


## The subsection [param group]'s button in the row over the settings, or null.
func get_subsection_button(group: StringName) -> Button:
	return _subsection_buttons.get(group)


## The button that sets [param key] to [param value]: a segment or a list's
## option; null if the setting isn't on the page or is a switch.
func get_button(key: StringName, value: StringName) -> Button:
	if not key in _buttons:
		return null
	var index := XREFeatureSettings.get_values(key).find(value)
	return _buttons[key][index] as Button if index >= 0 else null


## The switch of an On and Off setting, or null.
func get_switch(key: StringName) -> XRESwitch:
	return _switches.get(key)


## The button opening the list of a setting with many values, or null.
func get_picker(key: StringName) -> Button:
	return _pickers.get(key)


## The value the button of a setting with many values says.
func get_picker_text(key: StringName) -> String:
	return _picker_values[key].text if key in _picker_values else ""


## Whether the list of [param key]'s values is open under its row.
func is_list_open(key: StringName) -> bool:
	return key in _lists and _lists[key].visible


## The row of setting [param key], or null.
func get_row(key: StringName) -> Control:
	return _rows.get(key)


## Whether the row of [param key] is dimmed: the setting doesn't act now.
func is_dimmed(key: StringName) -> bool:
	return key in _needs and _needs[key].visible


## Whether the row of [param key] shows it isn't at its default.
func is_marked(key: StringName) -> bool:
	return key in _marks and _marks[key].visible


## What the bottom of the window explains, "Title: explanation", or empty while it is left out.
func get_hint_text() -> String:
	return "%s: %s" % [_hint_title.text, _hint.text] if _foot.visible else ""


## Shows the explanation of setting [param key] at the bottom and lights its
## row, as the ray on the row does.
func show_hint(key: StringName) -> void:
	if not key in XREFeatureSettings.DEFINITIONS:
		return
	var definition: Dictionary = XREFeatureSettings.DEFINITIONS[key]
	_hint_title.text = definition["title"]
	_hint.text = definition["hint"]
	if _hot in _rows:
		_rows[_hot].add_theme_stylebox_override(&"panel", _row_style(_rows[_hot].get_index() > 0, false))
	_hot = key
	if key in _rows:
		_rows[key].add_theme_stylebox_override(&"panel", _row_style(_rows[key].get_index() > 0, true))


## The Reset button in the header, which opens the menu of resets.
func get_reset_toggle() -> Button:
	return _reset_toggle


## The menu's button of reset [param scope] ([constant RESET_GROUP] and the others), or null.
func get_reset_button(scope: StringName) -> Button:
	return _reset_buttons.get(scope)


## What the reset's button says: what it resets, or "Reset …?" while it asks.
func get_reset_text(scope: StringName) -> String:
	return _reset_labels[scope].text if scope in _reset_labels else ""


## The small text at its right: how many settings it changes, or "press again".
func get_reset_note(scope: StringName) -> String:
	return _reset_notes[scope].text if scope in _reset_notes else ""


## The Controls page's row of layouts, or null if that page isn't shown.
func get_layout_row() -> XRESegmentRow:
	return _layouts


## The Controls page's button that picks [param layout], or null if that page isn't shown.
func get_layout_button(layout: StringName) -> Button:
	return _layout_buttons.get(layout)


## The Controls page's button that rebinds [param action], or null if that page isn't shown.
func get_binding_button(action: StringName) -> Button:
	return _binding_buttons.get(action)


## What the binding button of [param action] says: the button's name, or [constant PRESS_TEXT].
func get_binding_text(action: StringName) -> String:
	return _binding_labels[action].text if action in _binding_labels else ""


## The button whose icon the binding button of [param action] shows, or empty while it waits.
func get_binding_glyph(action: StringName) -> StringName:
	if not action in _binding_glyphs or not _binding_glyphs[action].visible:
		return &""
	return _binding_glyphs[action].button


## The action waiting for a button, or an empty name.
func get_capturing() -> StringName:
	return _capturing


## Waits for a button for [param action], or stops waiting if it already does.
func toggle_capture(action: StringName) -> void:
	if _capturing == action:
		_stop_capture()
		return
	_stop_capture()
	_capturing = action
	_capture_until_usec = Time.get_ticks_usec() + int(CAPTURE_SEC * 1000000.0)
	_show_binding(action)


func wants_button() -> bool:
	if _capturing == &"":
		return false
	if Time.get_ticks_usec() >= _capture_until_usec:
		_stop_capture()
		return false
	return true


## Binds the waiting action to [param button]: in the custom layout, with the other bindings kept.
func take_button(button: StringName) -> void:
	var action := _capturing
	_stop_capture()
	if action != &"":
		_document.set_binding(action, button, XREDocument.Source.PANEL)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		# The editor's theme is scaled; the page's sizes follow its font size.
		var ui_scale := get_theme_default_font_size() / 14.0
		if not is_equal_approx(ui_scale, _ui_scale):
			_ui_scale = ui_scale
			_rebuild = true
			mark_dirty()
	elif what == NOTIFICATION_RESIZED and _foot != null:
		_update_hint()


func _on_feature_changed(key: StringName) -> void:
	if key == XREFeatureSettings.SETTINGS_SUBSECTIONS:
		_rebuild = true
	mark_dirty()


func _refresh() -> void:
	if _rebuild:
		_build_page()
		return
	var features := _document.features
	_crumb.text = "/ " + SECTION_TITLES[_section]
	if _section == XREFeatureSettings.Category.EDITOR:
		_crumb.text += " / " + XREFeatureSettings.GROUPS[_group]
	for key: StringName in _rows:
		_refresh_row(key)
	var tree := _is_tree()
	_set_nav(&"global", _section == XREFeatureSettings.Category.GLOBAL,
			features.count_changed(XREFeatureSettings.get_keys(XREFeatureSettings.Category.GLOBAL)))
	_set_nav(&"editor", _section == XREFeatureSettings.Category.EDITOR and not (tree and _open),
			0 if tree and _open else features.count_changed(XREFeatureSettings.get_keys(XREFeatureSettings.Category.EDITOR)))
	_set_nav(&"controls", _section == XREFeatureSettings.Category.CONTROLS, 1 if features.is_layout_picked() else 0)
	for group: StringName in XREFeatureSettings.GROUPS:
		var count := features.count_changed(XREFeatureSettings.get_keys(XREFeatureSettings.Category.EDITOR, group))
		if group in _nav_buttons:
			_set_nav(group, _section == XREFeatureSettings.Category.EDITOR and group == _group, count)
		if group in _subsection_buttons:
			_subsections.set_count(_subsection_buttons[group], count)
	if _subsections != null:
		_subsections.pick(_subsection_buttons[_group])
	_refresh_reset()
	if _layouts != null:
		_layouts.pick(_layout_buttons.get(features.get_layout()))
	for action: StringName in _binding_buttons:
		_show_binding(action)
	if _keys_label != null:
		_keys_label.visible = features.uses_keyboard()


func _refresh_row(key: StringName) -> void:
	var features := _document.features
	var value := features.get_value(key)
	var active := features.is_active(key)
	_names[key].modulate.a = 1.0 if active else DIM_ALPHA
	_values[key].modulate.a = 1.0 if active else DIM_ALPHA
	_needs[key].visible = not active
	_marks[key].visible = features.is_changed(key)
	var values := XREFeatureSettings.get_values(key)
	var index := values.find(value)
	if key in _segments:
		_segments[key].pick(_buttons[key][index] as Button)
		_segments[key].set_enabled(active)
	elif key in _switches:
		_switches[key].show_on(value == XREFeatureSettings.ON)
		_switches[key].disabled = not active
	elif key in _pickers:
		var labels: Array = XREFeatureSettings.DEFINITIONS[key]["labels"]
		_picker_values[key].text = labels[index]
		_picker_counts[key].text = "%d of %d ▾" % [index + 1, values.size()]
		_pickers[key].disabled = not active
		if not active:
			_lists[key].visible = false
		for option_index: int in _buttons[key].size():
			(_buttons[key][option_index] as Button).set_pressed_no_signal(option_index == index)
			(_radios[key][option_index] as Control).queue_redraw()


## Shows the section's or subsection's button on the left as current or not, with its count.
func _set_nav(section_name: StringName, current: bool, count: int) -> void:
	if not section_name in _nav_buttons:
		return
	_nav_buttons[section_name].set_pressed_no_signal(current)
	for part: CanvasItem in _nav_paint[section_name]:
		part.modulate = Color.WHITE if current else NAV_COLOR
	var badge := _nav_badges[section_name]
	badge.visible = count > 0
	(badge.get_child(0) as Label).text = str(count)


func _refresh_reset() -> void:
	var armed := _armed != &"" and Time.get_ticks_usec() < _armed_until_usec
	for scope: StringName in _reset_buttons:
		var button := _reset_buttons[scope]
		var count := _reset_count(scope)
		var waiting := armed and scope == _armed
		var title := _reset_title(scope)
		_reset_labels[scope].text = "Reset %s?" % title if waiting else title
		var note := _reset_note(scope, count)
		_reset_notes[scope].text = "press again" if waiting else note
		button.disabled = count == 0
		var color := ARMED_COLOR if waiting else Color(1.0, 1.0, 1.0, 0.0)
		button.add_theme_stylebox_override(&"normal", _menu_item_style(color))
		button.add_theme_stylebox_override(&"hover", _menu_item_style(ARMED_COLOR if waiting else MENU_HOVER_COLOR))
		button.add_theme_stylebox_override(&"pressed", _menu_item_style(ARMED_COLOR if waiting else MENU_HOVER_COLOR))
		_reset_labels[scope].add_theme_color_override(&"font_color", OFF_COLOR if count == 0 else (Color.WHITE if waiting else TEXT_COLOR))
		_reset_notes[scope].add_theme_color_override(&"font_color", OFF_COLOR if count == 0 else (ARMED_NOTE_COLOR if waiting else HINT_COLOR))


func _on_hidden() -> void:
	_stop_capture()
	_armed = &""


func _stop_capture() -> void:
	var action := _capturing
	_capturing = &""
	if action in _binding_buttons:
		_show_binding(action)


## Shows the button of [param action], or [constant PRESS_TEXT] while it waits.
func _show_binding(action: StringName) -> void:
	var waiting := action == _capturing
	var bound := _document.features.get_binding(action)
	_binding_glyphs[action].keyboard = _document.features.uses_keyboard()
	_binding_glyphs[action].button = bound
	_binding_glyphs[action].visible = not waiting
	_binding_labels[action].text = PRESS_TEXT if waiting else XREFeatureSettings.button_label(bound)
	_binding_buttons[action].set_pressed_no_signal(waiting)


## Whether the subsections are under Editor on the left: so set, and the sections not folded.
func _is_tree() -> bool:
	return not _collapsed and _document.features.get_value(XREFeatureSettings.SETTINGS_SUBSECTIONS) == XREFeatureSettings.TREE


## Builds the page anew for the section shown and refreshes it.
func _build_page() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()
	for parts: Dictionary in [_reset_buttons, _reset_labels, _reset_notes, _nav_buttons, _nav_badges, _nav_paint,
			_subsection_buttons, _rows, _names, _marks, _values, _needs, _segments, _switches, _pickers, _picker_values,
			_picker_counts, _lists, _radios, _buttons, _layout_buttons, _binding_buttons, _binding_glyphs, _binding_labels]:
		parts.clear()
	_subsections = null
	_layouts = null
	_keys_label = null
	_capturing = &""
	_armed = &""
	_hot = &""
	_rebuild = false
	# The page, and the menu of resets over it.
	var frame := Control.new()
	frame.name = "Frame"
	frame.size_flags_vertical = SIZE_EXPAND_FILL
	add_child(frame)
	var page := VBoxContainer.new()
	page.name = "Page"
	page.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	page.add_theme_constant_override(&"separation", 0)
	frame.add_child(page)
	_build_header(page)
	var body := HBoxContainer.new()
	body.name = "Body"
	body.size_flags_vertical = SIZE_EXPAND_FILL
	body.add_theme_constant_override(&"separation", 0)
	page.add_child(body)
	_build_nav(body)
	var main := VBoxContainer.new()
	main.name = "Main"
	main.size_flags_horizontal = SIZE_EXPAND_FILL
	main.add_theme_constant_override(&"separation", 0)
	body.add_child(main)
	if _section == XREFeatureSettings.Category.EDITOR and not _is_tree():
		_build_subsection_row(main)
	# Not disabled sideways: then the page would be as wide as its widest
	# row, and the rows are fitted to the page's width (_fit_rows).
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	_scroll.add_theme_stylebox_override(&"panel", StyleBoxEmpty.new())
	_scroll.resized.connect(_fit_rows)
	_scroll.get_v_scroll_bar().visibility_changed.connect(_fit_rows)
	main.add_child(_scroll)
	# The rows reach 8 pixels past the page's edge, so that the lit row's
	# color reaches past their text, as in the mockup.
	var margin := _margin(10.0, 0.0, 0.0, 12.0)
	margin.size_flags_horizontal = SIZE_EXPAND_FILL
	_scroll.add_child(margin)
	_content = VBoxContainer.new()
	_content.name = "Content"
	_content.size_flags_horizontal = SIZE_EXPAND_FILL
	_content.add_theme_constant_override(&"separation", 0)
	margin.add_child(_content)
	if _section == XREFeatureSettings.Category.CONTROLS:
		_build_controls_page()
	else:
		var keys := XREFeatureSettings.get_keys(_section, _group if _section == XREFeatureSettings.Category.EDITOR else &"")
		if keys.is_empty():
			var message := _make_message("No settings here yet.")
			message.visible = true
			_content.add_child(message)
		for key: StringName in keys:
			_add_setting(key)
	_build_foot(page)
	_build_menu(frame)
	_update_hint()
	_refresh()


func _build_header(page: VBoxContainer) -> void:
	var margin := _margin(6.0, 2.0, 4.0, 10.0)
	margin.name = "Header"
	page.add_child(margin)
	var header := HBoxContainer.new()
	header.add_theme_constant_override(&"separation", _px(8.0))
	margin.add_child(header)
	var title := _label("Settings", 16.0, TEXT_COLOR, _font(&"bold"))
	header.add_child(title)
	_crumb = _label("", 16.0, MUTED_COLOR)
	_crumb.size_flags_horizontal = SIZE_EXPAND_FILL
	_crumb.clip_text = true
	header.add_child(_crumb)
	_reset_toggle = Button.new()
	_reset_toggle.name = "Reset"
	_reset_toggle.text = "Reset ▾"
	_reset_toggle.toggle_mode = true
	_reset_toggle.focus_mode = FOCUS_NONE
	_reset_toggle.add_theme_font_size_override(&"font_size", _px(13.0))
	var pad := Vector4(12.0, 5.0, 12.0, 5.0)
	_reset_toggle.add_theme_stylebox_override(&"normal", _box(Color(1.0, 1.0, 1.0, 0.0), 999.0, pad, BORDER_COLOR))
	_reset_toggle.add_theme_stylebox_override(&"hover", _box(Color(1.0, 1.0, 1.0, 0.05), 999.0, pad, BORDER_COLOR))
	for state: StringName in [&"pressed", &"hover_pressed"]:
		_reset_toggle.add_theme_stylebox_override(state, _box(XRESegmentRow.PICKED_COLOR, 999.0, pad, XRESegmentRow.PICKED_COLOR))
	_reset_toggle.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())
	for state: StringName in [&"font_color", &"font_hover_color"]:
		_reset_toggle.add_theme_color_override(state, NAV_COLOR)
	for state: StringName in [&"font_pressed_color", &"font_hover_pressed_color"]:
		_reset_toggle.add_theme_color_override(state, XRESegmentRow.PICKED_TEXT_COLOR)
	_reset_toggle.size_flags_vertical = SIZE_SHRINK_CENTER
	_reset_toggle.toggled.connect(func(on: bool) -> void:
		_menu.visible = on
		_armed = &""
		_refresh_reset())
	header.add_child(_reset_toggle)


func _build_nav(body: HBoxContainer) -> void:
	var tree := _is_tree()
	var width := COLLAPSED_WIDTH if _collapsed else (TREE_WIDTH if tree else NAV_WIDTH)
	var rail := PanelContainer.new()
	rail.name = "Sections"
	# The window's own margin of 12 pixels is the rail's padding on the left.
	rail.custom_minimum_size.x = _px(width - 12.0)
	var style := _box(Color(1.0, 1.0, 1.0, 0.0), 0.0, Vector4(0.0, 4.0, 6.0 if _collapsed else 8.0, 12.0))
	style.border_width_right = maxi(1, _px(1.0))
	style.border_color = LINE_COLOR
	rail.add_theme_stylebox_override(&"panel", style)
	body.add_child(rail)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", _px(2.0))
	rail.add_child(column)
	var box := ScrollContainer.new()
	box.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.size_flags_vertical = SIZE_EXPAND_FILL
	box.add_theme_stylebox_override(&"panel", StyleBoxEmpty.new())
	column.add_child(box)
	var nav := VBoxContainer.new()
	nav.size_flags_horizontal = SIZE_EXPAND_FILL
	nav.add_theme_constant_override(&"separation", _px(2.0))
	box.add_child(nav)
	for index: int in SECTION_TITLES.size():
		var category := index as XREFeatureSettings.Category
		var section_name := StringName(SECTION_TITLES[index].to_lower())
		var chevron := -1
		if tree and category == XREFeatureSettings.Category.EDITOR:
			chevron = 1 if _open else 0
		var button := _nav_button(nav, section_name, SECTION_TITLES[index], SECTION_GLYPHS[index], chevron, false)
		button.pressed.connect(_on_section_pressed.bind(category))
		if tree and category == XREFeatureSettings.Category.EDITOR and _open:
			for group: StringName in XREFeatureSettings.GROUPS:
				var sub := _nav_button(nav, group, XREFeatureSettings.GROUPS[group], &"", -1, true)
				sub.pressed.connect(_on_group_pressed.bind(group))
	_collapse = Button.new()
	_collapse.name = "Collapse"
	_collapse.text = "»" if _collapsed else "«  Collapse"
	_collapse.focus_mode = FOCUS_NONE
	_collapse.alignment = HORIZONTAL_ALIGNMENT_CENTER if _collapsed else HORIZONTAL_ALIGNMENT_LEFT
	_collapse.add_theme_font_size_override(&"font_size", _px(13.0))
	var pad := Vector4(0.0 if _collapsed else 10.0, 8.0, 0.0 if _collapsed else 10.0, 8.0)
	_collapse.add_theme_stylebox_override(&"normal", _box(Color(1.0, 1.0, 1.0, 0.0), 12.0, pad))
	for state: StringName in [&"hover", &"pressed", &"hover_pressed"]:
		_collapse.add_theme_stylebox_override(state, _box(XRESegmentRow.HOVER_COLOR, 12.0, pad))
	_collapse.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())
	for state: StringName in [&"font_color", &"font_pressed_color"]:
		_collapse.add_theme_color_override(state, CAP_COLOR)
	_collapse.add_theme_color_override(&"font_hover_color", NAV_COLOR)
	_collapse.pressed.connect(_on_collapse_pressed)
	column.add_child(_collapse)


## A button of the sections on the left: a chevron, a glyph, the name and a
## count; folded, the glyph alone with the count at its corner.
func _nav_button(nav: VBoxContainer, section_name: StringName, text: String, glyph: StringName, chevron: int, sub: bool) -> Button:
	var button := Button.new()
	button.name = String(section_name)
	button.toggle_mode = true
	button.focus_mode = FOCUS_NONE
	var pad := Vector4(34.0, 6.0, 10.0, 6.0) if sub else (Vector4(0.0, 9.0, 0.0, 9.0) if _collapsed else Vector4(10.0, 8.0, 10.0, 8.0))
	button.add_theme_stylebox_override(&"normal", _box(Color(1.0, 1.0, 1.0, 0.0), 12.0, pad))
	button.add_theme_stylebox_override(&"hover", _box(Color(1.0, 1.0, 1.0, 0.04), 12.0, pad))
	button.add_theme_stylebox_override(&"pressed", _box(CURRENT_COLOR, 12.0, pad))
	button.add_theme_stylebox_override(&"hover_pressed", _box(CURRENT_COLOR, 12.0, pad))
	button.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())
	var content := HBoxContainer.new()
	content.mouse_filter = MOUSE_FILTER_IGNORE
	content.alignment = BoxContainer.ALIGNMENT_CENTER if _collapsed else BoxContainer.ALIGNMENT_BEGIN
	content.add_theme_constant_override(&"separation", _px(9.0))
	content.set_anchors_preset(PRESET_FULL_RECT)
	content.offset_left = _px(pad.x)
	content.offset_top = _px(pad.y)
	content.offset_right = -_px(pad.z)
	content.offset_bottom = -_px(pad.w)
	button.add_child(content)
	var paint: Array[CanvasItem] = []
	if chevron >= 0:
		content.add_child(_chevron(chevron == 1))
	if glyph != &"":
		var icon := TextureRect.new()
		icon.texture = XRETabIcons.glyph(glyph, _px(17.0))
		icon.mouse_filter = MOUSE_FILTER_IGNORE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		content.add_child(icon)
		paint.append(icon)
	var label := _label(text, 13.5 if sub else 14.0, Color.WHITE)
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.visible = not _collapsed
	content.add_child(label)
	paint.append(label)
	var badge := XRESegmentRow.make_badge(_ui_scale)
	badge.visible = false
	if _collapsed:
		# At the icon's corner.
		badge.set_anchors_preset(PRESET_TOP_RIGHT)
		badge.offset_left = -_px(18.0)
		badge.offset_top = _px(2.0)
		badge.offset_right = -_px(2.0)
		button.add_child(badge)
	else:
		content.add_child(badge)
	var height := func() -> void:
		button.custom_minimum_size.y = content.get_combined_minimum_size().y + _px(pad.y + pad.w)
	content.minimum_size_changed.connect(height)
	height.call()
	nav.add_child(button)
	_nav_buttons[section_name] = button
	_nav_badges[section_name] = badge
	_nav_paint[section_name] = paint
	return button


func _build_subsection_row(main: VBoxContainer) -> void:
	var wrap := PanelContainer.new()
	wrap.name = "SubsectionsWrap"
	var style := _box(Color(1.0, 1.0, 1.0, 0.0), 0.0, Vector4(18.0, 0.0, 6.0, 8.0))
	style.border_width_bottom = maxi(1, _px(1.0))
	style.border_color = LINE_COLOR
	wrap.add_theme_stylebox_override(&"panel", style)
	main.add_child(wrap)
	_subsections = XRESegmentRow.new(_ui_scale)
	_subsections.name = "Subsections"
	for group: StringName in XREFeatureSettings.GROUPS:
		var button := _subsections.add_choice(XREFeatureSettings.GROUPS[group])
		button.name = String(group)
		button.pressed.connect(_on_group_pressed.bind(group))
		_subsection_buttons[group] = button
	wrap.add_child(_subsections)
	_subsections.pick(_subsection_buttons[_group])
	_subsections.reveal(_subsection_buttons[_group])


## A setting's row: its name, the mark and ↺, its values, what it needs and, for many values, their list.
func _add_setting(key: StringName) -> void:
	var definition: Dictionary = XREFeatureSettings.DEFINITIONS[key]
	var row := PanelContainer.new()
	row.name = String(key)
	row.add_theme_stylebox_override(&"panel", _row_style(not _rows.is_empty(), false))
	_content.add_child(row)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", _px(7.0))
	row.add_child(column)
	# Values go under the name when they don't fit beside it.
	var line := HFlowContainer.new()
	line.add_theme_constant_override(&"h_separation", _px(12.0))
	line.add_theme_constant_override(&"v_separation", _px(7.0))
	column.add_child(line)
	var name_box := HBoxContainer.new()
	name_box.size_flags_horizontal = SIZE_EXPAND_FILL
	name_box.size_flags_vertical = SIZE_SHRINK_CENTER
	name_box.custom_minimum_size.x = _px(NAME_WIDTH)
	name_box.add_theme_constant_override(&"separation", _px(7.0))
	line.add_child(name_box)
	name_box.add_child(_label(definition["title"], 14.0, TEXT_COLOR))
	var mark := HBoxContainer.new()
	mark.add_theme_constant_override(&"separation", _px(7.0))
	name_box.add_child(mark)
	var dot := Panel.new()
	dot.mouse_filter = MOUSE_FILTER_IGNORE
	dot.custom_minimum_size = Vector2.ONE * _px(7.0)
	dot.size_flags_vertical = SIZE_SHRINK_CENTER
	dot.add_theme_stylebox_override(&"panel", XREPanelSurface.meta_style(XRESegmentRow.BADGE_COLOR, _px(4.0), 0.0))
	mark.add_child(dot)
	var reset := Button.new()
	reset.name = "Reset"
	reset.text = "↺"
	reset.focus_mode = FOCUS_NONE
	reset.size_flags_vertical = SIZE_SHRINK_CENTER
	reset.add_theme_font_size_override(&"font_size", _px(14.0))
	for state: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed", &"focus"]:
		reset.add_theme_stylebox_override(state, _box(Color(1.0, 1.0, 1.0, 0.0), 0.0, Vector4(2.0, 0.0, 2.0, 0.0)))
	for state: StringName in [&"font_color", &"font_hover_color", &"font_pressed_color"]:
		reset.add_theme_color_override(state, LINK_COLOR)
	reset.pressed.connect(func() -> void: _document.reset_features([key], XREDocument.Source.PANEL))
	mark.add_child(reset)
	var values := XREFeatureSettings.get_values(key)
	var labels: Array = definition["labels"]
	var control: Control
	if values.size() == 2 and XREFeatureSettings.ON in values and XREFeatureSettings.OFF in values:
		var toggle := XRESwitch.new(_ui_scale)
		toggle.size_flags_vertical = SIZE_SHRINK_CENTER
		toggle.toggled.connect(func(on: bool) -> void:
			_document.set_feature(key, XREFeatureSettings.ON if on else XREFeatureSettings.OFF, XREDocument.Source.PANEL))
		_switches[key] = toggle
		control = toggle
	elif values.size() >= LIST_VALUES:
		control = _add_picker(key, column)
	else:
		var segments := XRESegmentRow.new(_ui_scale, true, 11.0)
		segments.size_flags_vertical = SIZE_SHRINK_CENTER
		for index: int in values.size():
			var button := segments.add_choice(labels[index])
			button.name = String(values[index])
			button.pressed.connect(_document.set_feature.bind(key, values[index], XREDocument.Source.PANEL))
		_segments[key] = segments
		_buttons[key] = segments.get_choices().duplicate()
		control = segments
	line.add_child(control)
	var needs := _label(_needs_text(key), 12.0, NEEDS_COLOR)
	needs.name = "Needs"
	needs.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	needs.visible = false
	column.add_child(needs)
	column.move_child(needs, 1)
	_rows[key] = row
	_names[key] = name_box
	_marks[key] = mark
	_values[key] = control
	_needs[key] = needs
	_watch(row, key)


## The button of a setting with many values, saying its value and "2 of 5 ▾",
## and the list of the values it opens at the end of [param column].
func _add_picker(key: StringName, column: VBoxContainer) -> Button:
	var picker := Button.new()
	picker.name = "Picker"
	picker.focus_mode = FOCUS_NONE
	picker.size_flags_vertical = SIZE_SHRINK_CENTER
	var pad := Vector4(14.0, 6.0, 14.0, 6.0)
	for state: StringName in [&"normal", &"disabled"]:
		picker.add_theme_stylebox_override(state, _box(XRESegmentRow.TRACK_COLOR, 999.0, pad))
	for state: StringName in [&"hover", &"pressed", &"hover_pressed"]:
		picker.add_theme_stylebox_override(state, _box(XRESegmentRow.TRACK_COLOR.lightened(0.06), 999.0, pad))
	picker.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())
	var content := HBoxContainer.new()
	content.mouse_filter = MOUSE_FILTER_IGNORE
	content.add_theme_constant_override(&"separation", _px(10.0))
	content.set_anchors_preset(PRESET_FULL_RECT)
	content.offset_left = _px(pad.x)
	content.offset_top = _px(pad.y)
	content.offset_right = -_px(pad.z)
	content.offset_bottom = -_px(pad.w)
	picker.add_child(content)
	var value := _label("", 13.5, TEXT_COLOR)
	content.add_child(value)
	var count := _label("", 12.0, CAP_COLOR)
	content.add_child(count)
	var size_up := func() -> void:
		picker.custom_minimum_size = content.get_combined_minimum_size() + Vector2(_px(pad.x + pad.z), _px(pad.y + pad.w))
	content.minimum_size_changed.connect(size_up)
	size_up.call()
	picker.pressed.connect(func() -> void: _lists[key].visible = not _lists[key].visible)
	_pickers[key] = picker
	_picker_values[key] = value
	_picker_counts[key] = count
	var list := PanelContainer.new()
	list.name = "List"
	list.visible = false
	list.add_theme_stylebox_override(&"panel", _box(LIST_COLOR, 12.0, Vector4(5.0, 5.0, 5.0, 5.0)))
	var options_box := VBoxContainer.new()
	options_box.add_theme_constant_override(&"separation", _px(2.0))
	list.add_child(options_box)
	var group := ButtonGroup.new()
	var options: Array[Button] = []
	var radios: Array[Control] = []
	var values := XREFeatureSettings.get_values(key)
	var labels: Array = XREFeatureSettings.DEFINITIONS[key]["labels"]
	var option_pad := Vector4(10.0, 7.0, 10.0, 7.0)
	for index: int in values.size():
		var option := Button.new()
		option.name = String(values[index])
		option.toggle_mode = true
		option.button_group = group
		option.focus_mode = FOCUS_NONE
		for state: StringName in [&"normal", &"pressed"]:
			option.add_theme_stylebox_override(state, _box(Color(1.0, 1.0, 1.0, 0.0), 8.0, option_pad))
		for state: StringName in [&"hover", &"hover_pressed"]:
			option.add_theme_stylebox_override(state, _box(LIST_HOVER_COLOR, 8.0, option_pad))
		option.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())
		var row := HBoxContainer.new()
		row.mouse_filter = MOUSE_FILTER_IGNORE
		row.add_theme_constant_override(&"separation", _px(10.0))
		row.set_anchors_preset(PRESET_FULL_RECT)
		row.offset_left = _px(option_pad.x)
		row.offset_right = -_px(option_pad.z)
		option.add_child(row)
		var radio := _radio(option)
		row.add_child(radio)
		row.add_child(_label(labels[index], 13.5, OPTION_COLOR))
		_fit_height(option, row, option_pad.y + option_pad.w)
		option.pressed.connect(_on_option_pressed.bind(key, values[index]))
		options_box.add_child(option)
		options.append(option)
		radios.append(radio)
	_lists[key] = list
	_buttons[key] = options
	_radios[key] = radios
	column.add_child(list)
	return picker


## The round mark of a list's option: a ring, thick and white when picked.
func _radio(option: Button) -> Control:
	var radio := Control.new()
	radio.mouse_filter = MOUSE_FILTER_IGNORE
	radio.custom_minimum_size = Vector2.ONE * _px(12.0)
	radio.size_flags_vertical = SIZE_SHRINK_CENTER
	radio.draw.connect(func() -> void:
		var center := radio.size * 0.5
		var radius := radio.size.x * 0.5
		if option.button_pressed:
			radio.draw_arc(center, radius - 2.0 * _ui_scale, 0.0, TAU, 32, XRESegmentRow.PICKED_COLOR, 4.0 * _ui_scale, true)
		else:
			radio.draw_arc(center, radius - 0.75 * _ui_scale, 0.0, TAU, 32, RADIO_COLOR, 1.5 * _ui_scale, true))
	option.toggled.connect(func(_on: bool) -> void: radio.queue_redraw())
	return radio


## "Needs Node style: Archetypes": what setting [param key] requires; "not
## Always" when all but one value do.
static func _needs_text(key: StringName) -> String:
	var parts := PackedStringArray()
	var requires: Dictionary = XREFeatureSettings.DEFINITIONS[key].get("requires", {})
	for other: StringName in requires:
		var definition: Dictionary = XREFeatureSettings.DEFINITIONS[other]
		var labels: Array = definition["labels"]
		var allowed: Array = requires[other]
		var values := XREFeatureSettings.get_values(other)
		var all_but_one := allowed.size() > 1 and allowed.size() == values.size() - 1
		var names := PackedStringArray()
		for index: int in values.size():
			if (values[index] in allowed) != all_but_one:
				names.append(labels[index])
		parts.append("%s: %s%s" % [definition["title"], "not " if all_but_one else "", " or ".join(names)])
	return "Needs " + ", ".join(parts)


## Shows [param key]'s explanation while the ray is on its row or any of its controls.
func _watch(control: Control, key: StringName) -> void:
	if control.mouse_filter != MOUSE_FILTER_IGNORE:
		control.mouse_entered.connect(show_hint.bind(key))
	for child: Node in control.get_children():
		if child is Control:
			_watch(child as Control, key)


func _build_foot(page: VBoxContainer) -> void:
	_foot = PanelContainer.new()
	_foot.name = "Hint"
	var style := _box(Color(1.0, 1.0, 1.0, 0.0), 0.0, Vector4(6.0, 10.0, 6.0, 2.0))
	style.border_width_top = maxi(1, _px(1.0))
	style.border_color = FOOT_LINE_COLOR
	_foot.add_theme_stylebox_override(&"panel", style)
	# The mockup's 92 pixels, less the window's own margin at the bottom.
	_foot.custom_minimum_size.y = _px(80.0)
	page.add_child(_foot)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", _px(2.0))
	_foot.add_child(column)
	_hint_title = _label(HINT_TITLE, 13.0, TEXT_COLOR, _font(&"bold"))
	column.add_child(_hint_title)
	_hint = _label(HINT_TEXT, 12.5, MUTED_COLOR)
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.max_lines_visible = HINT_LINES
	column.add_child(_hint)


## The menu of resets, over the page under the Reset button.
func _build_menu(frame: Control) -> void:
	_menu = PanelContainer.new()
	_menu.name = "ResetMenu"
	_menu.visible = false
	var style := _box(XRESegmentRow.TRACK_COLOR, 14.0, Vector4(6.0, 6.0, 6.0, 6.0), BORDER_COLOR)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	style.shadow_size = _px(12.0)
	style.shadow_offset = Vector2(0.0, _px(6.0))
	_menu.add_theme_stylebox_override(&"panel", style)
	_menu.set_anchors_preset(PRESET_TOP_RIGHT)
	_menu.offset_left = -_px(MENU_WIDTH + 2.0)
	_menu.offset_right = -_px(2.0)
	_menu.offset_top = _px(38.0)
	_menu.offset_bottom = _px(38.0)
	frame.add_child(_menu)
	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", _px(2.0))
	_menu.add_child(column)
	var head := _margin(10.0, 6.0, 10.0, 4.0)
	head.add_child(_cap("Reset to defaults", 10.5))
	column.add_child(head)
	for scope: StringName in _reset_scopes():
		var item := Button.new()
		item.name = String(scope)
		item.focus_mode = FOCUS_NONE
		item.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())
		item.add_theme_stylebox_override(&"disabled", _menu_item_style(Color(1.0, 1.0, 1.0, 0.0)))
		item.pressed.connect(_on_reset_pressed.bind(scope))
		var row := HBoxContainer.new()
		row.mouse_filter = MOUSE_FILTER_IGNORE
		row.add_theme_constant_override(&"separation", _px(10.0))
		row.set_anchors_preset(PRESET_FULL_RECT)
		row.offset_left = _px(10.0)
		row.offset_right = -_px(10.0)
		item.add_child(row)
		var label := _label("", 13.5, TEXT_COLOR)
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		row.add_child(label)
		var note := _label("", 12.0, HINT_COLOR)
		row.add_child(note)
		_fit_height(item, row, 16.0)
		column.add_child(item)
		_reset_buttons[scope] = item
		_reset_labels[scope] = label
		_reset_notes[scope] = note


func _build_controls_page() -> void:
	_content.add_child(_cap_line("Controls layout", 4.0))
	var wrap := _margin(8.0, 0.0, 8.0, 0.0)
	_content.add_child(wrap)
	_layouts = XRESegmentRow.new(_ui_scale)
	_layouts.name = "Layouts"
	for index: int in XREFeatureSettings.LAYOUTS.size():
		var layout := XREFeatureSettings.LAYOUTS[index]
		var button := _layouts.add_choice(XREFeatureSettings.LAYOUT_LABELS[index])
		button.name = String(layout)
		button.pressed.connect(_document.set_controls_layout.bind(layout, XREDocument.Source.PANEL))
		_layout_buttons[layout] = button
	wrap.add_child(_layouts)
	_layouts.reveal(_layout_buttons.get(_document.features.get_layout()))
	var hint_wrap := _margin(8.0, 8.0, 8.0, 4.0)
	_content.add_child(hint_wrap)
	var notes := VBoxContainer.new()
	hint_wrap.add_child(notes)
	var hint := _label("Set for the runtime until you pick one. Click a binding, then press the button: it switches to Custom, which keeps every other binding and is then used on every runtime.",
			12.5, HINT_COLOR)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notes.add_child(hint)
	# The keys that aren't controller buttons don't rebind; they show here.
	_keys_label = _label(XRESimulator.HELP, 12.5, HINT_COLOR)
	_keys_label.name = "Keys"
	_keys_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_keys_label.visible = _document.features.uses_keyboard()
	notes.add_child(_keys_label)
	_content.add_child(_cap_line("Buttons", 14.0))
	var first := true
	for action: StringName in XREFeatureSettings.ACTIONS:
		var row := PanelContainer.new()
		row.add_theme_stylebox_override(&"panel", _row_style(not first, false))
		first = false
		_content.add_child(row)
		var row_action := HBoxContainer.new()
		row_action.name = String(action)
		row_action.add_theme_constant_override(&"separation", _px(12.0))
		row.add_child(row_action)
		var label := _label(XREFeatureSettings.ACTION_TITLES[action], 14.0, TEXT_COLOR)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row_action.add_child(label)
		var button := Button.new()
		button.name = "Binding"
		button.toggle_mode = true
		button.focus_mode = FOCUS_NONE
		button.size_flags_horizontal = SIZE_SHRINK_END
		button.size_flags_vertical = SIZE_SHRINK_CENTER
		var pad := Vector4(5.0, 4.0, 12.0, 4.0)
		button.add_theme_stylebox_override(&"normal", _box(XRESegmentRow.TRACK_COLOR, 999.0, pad))
		button.add_theme_stylebox_override(&"hover", _box(XRESegmentRow.TRACK_COLOR.lightened(0.06), 999.0, pad))
		for state: StringName in [&"pressed", &"hover_pressed"]:
			button.add_theme_stylebox_override(state, _box(CURRENT_COLOR, 999.0, pad))
		button.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())
		button.pressed.connect(toggle_capture.bind(action))
		row_action.add_child(button)
		# A Button doesn't size to its children: the content sets its minimum size.
		var content := HBoxContainer.new()
		content.mouse_filter = MOUSE_FILTER_IGNORE
		content.add_theme_constant_override(&"separation", _px(7.0))
		content.set_anchors_preset(PRESET_FULL_RECT)
		content.offset_left = _px(pad.x)
		content.offset_right = -_px(pad.z)
		content.alignment = BoxContainer.ALIGNMENT_CENTER
		button.add_child(content)
		var glyph := XREButtonGlyph.new()
		content.add_child(glyph)
		var name_label := _label("", 13.0, TEXT_COLOR)
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		content.add_child(name_label)
		var size_up := func() -> void:
			button.custom_minimum_size = content.get_combined_minimum_size() + Vector2(_px(pad.x + pad.z), _px(pad.y + pad.w))
		content.minimum_size_changed.connect(size_up)
		size_up.call()
		_binding_buttons[action] = button
		_binding_glyphs[action] = glyph
		_binding_labels[action] = name_label


## A Button doesn't size to its children: [param content] sets its height,
## with [param padding] pixels above and below.
func _fit_height(button: Button, content: Control, padding: float) -> void:
	var size_up := func() -> void:
		button.custom_minimum_size.y = content.get_combined_minimum_size().y + _px(padding)
	content.minimum_size_changed.connect(size_up)
	size_up.call()


## The chevron of a section with subsections on the left: › closed, pointing down open.
func _chevron(open: bool) -> Control:
	var mark := Control.new()
	mark.mouse_filter = MOUSE_FILTER_IGNORE
	mark.custom_minimum_size = Vector2(_px(10.0), _px(10.0))
	mark.size_flags_vertical = SIZE_SHRINK_CENTER
	mark.draw.connect(func() -> void:
		var center := mark.size * 0.5
		var half := 2.5 * _ui_scale
		var points := PackedVector2Array([center + Vector2(-half, -half * 2.0), center + Vector2(half, 0.0), center + Vector2(-half, half * 2.0)]) 				if not open else PackedVector2Array([center + Vector2(-half * 2.0, -half), center + Vector2(0.0, half), center + Vector2(half * 2.0, -half)])
		mark.draw_polyline(points, CAP_COLOR, 1.5 * _ui_scale, true))
	return mark


## Interface pixels at the editor's scale.
func _px(value: float) -> int:
	return roundi(value * _ui_scale)


## A label of [param font_size] pixels in [param color], in [param font] or the theme's.
func _label(text: String, font_size: float, color: Color, font: Font = null) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override(&"font_size", _px(font_size))
	label.add_theme_color_override(&"font_color", color)
	if font != null:
		label.add_theme_font_override(&"font", font)
	return label


## A caption as the mockup's: small grey capitals, a little apart, in the editor's code font.
func _cap(text: String, font_size: float) -> Label:
	var font := FontVariation.new()
	font.base_font = _font(&"source")
	font.spacing_glyph = _px(1.0)
	return _label(text.to_upper(), font_size, CAP_COLOR, font)


## A caption over a part of the page, [param top] pixels under what is above it.
func _cap_line(text: String, top: float) -> MarginContainer:
	var margin := _margin(8.0, top, 8.0, 6.0)
	margin.add_child(_cap(text, 11.0))
	return margin


## The editor's font [param font_name] ("bold", "source"), or the theme's own without the editor.
func _font(font_name: StringName) -> Font:
	return get_theme_font(font_name, &"EditorFonts") if has_theme_font(font_name, &"EditorFonts") else get_theme_default_font()


func _margin(left: float, top: float, right: float, bottom: float) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override(&"margin_left", _px(left))
	margin.add_theme_constant_override(&"margin_top", _px(top))
	margin.add_theme_constant_override(&"margin_right", _px(right))
	margin.add_theme_constant_override(&"margin_bottom", _px(bottom))
	return margin


## A box of [param color], corners of [param radius] and the room
## [param padding] (left, top, right, bottom) in pixels, with an edge of [param edge] if it shows.
func _box(color: Color, radius: float, padding: Vector4, edge: Color = Color(0.0, 0.0, 0.0, 0.0)) -> StyleBoxFlat:
	var style := XREPanelSurface.meta_style(color, mini(_px(radius), 999), 0.0)
	style.content_margin_left = _px(padding.x)
	style.content_margin_top = _px(padding.y)
	style.content_margin_right = _px(padding.z)
	style.content_margin_bottom = _px(padding.w)
	if edge.a > 0.0:
		style.set_border_width_all(maxi(1, _px(1.0)))
		style.border_color = edge
	return style


## A setting's or an action's row: a line over it unless it is the first, lit while the ray is on it.
func _row_style(line: bool, hot: bool) -> StyleBoxFlat:
	var style := _box(ROW_HOT_COLOR if hot else Color(1.0, 1.0, 1.0, 0.0), 10.0, Vector4(8.0, 9.0, 8.0, 9.0))
	if line:
		style.border_width_top = maxi(1, _px(1.0))
		style.border_color = LINE_COLOR
	return style


func _menu_item_style(color: Color) -> StyleBoxFlat:
	return _box(color, 9.0, Vector4(10.0, 8.0, 10.0, 8.0))


## Values in a row beside a name are at most as wide as the page; past it they scroll.
func _fit_rows() -> void:
	var bar := _scroll.get_v_scroll_bar()
	# The page's margins and a row's own room on each side.
	var width := _scroll.size.x - (bar.size.x if bar.visible else 0.0) - _px(10.0 + 16.0)
	if width <= 0.0:
		return
	for key: StringName in _segments:
		_segments[key].set_fit_width(width)


## The explanation is shown on the setting pages of a window tall enough for it.
func _update_hint() -> void:
	_foot.visible = _section != XREFeatureSettings.Category.CONTROLS and size.y >= HINT_MIN_HEIGHT * _ui_scale


func _on_section_pressed(category: XREFeatureSettings.Category) -> void:
	if category == XREFeatureSettings.Category.EDITOR and _is_tree():
		_open = not _open if _section == category else true
	_section = category
	_request_build()


func _on_group_pressed(group: StringName) -> void:
	_section = XREFeatureSettings.Category.EDITOR
	_group = group
	_request_build()


func _on_option_pressed(key: StringName, value: StringName) -> void:
	_lists[key].visible = false
	_document.set_feature(key, value, XREDocument.Source.PANEL)


func _on_collapse_pressed() -> void:
	_collapsed = not _collapsed
	window_size_changed.emit()
	_request_build()


## Builds the page anew once the click that asked for it is over.
func _request_build() -> void:
	_rebuild = true
	mark_dirty()


func _reset_scopes() -> Array[StringName]:
	match _section:
		XREFeatureSettings.Category.CONTROLS:
			return [RESET_LAYOUT]
		XREFeatureSettings.Category.GLOBAL:
			return [RESET_SECTION, RESET_ALL]
	return [RESET_GROUP, RESET_SECTION, RESET_ALL]


## The settings reset [param scope] puts back.
func _reset_keys(scope: StringName) -> Array[StringName]:
	match scope:
		RESET_GROUP:
			return XREFeatureSettings.get_keys(XREFeatureSettings.Category.EDITOR, _group)
		RESET_SECTION:
			return XREFeatureSettings.get_keys(_section)
		RESET_ALL:
			var keys: Array[StringName] = []
			keys.assign(XREFeatureSettings.DEFINITIONS.keys())
			return keys
	return []


func _reset_title(scope: StringName) -> String:
	match scope:
		RESET_GROUP:
			return XREFeatureSettings.GROUPS[_group]
		RESET_SECTION:
			return SECTION_TITLES[_section]
		RESET_ALL:
			return "All settings"
	return "Layout"


## What the menu says at the right of a reset: how many settings it changes.
func _reset_note(scope: StringName, count: int) -> String:
	if scope == RESET_LAYOUT:
		return "back to %s" % XREFeatureSettings.LAYOUT_LABELS[XREFeatureSettings.LAYOUTS.find(_document.features.runtime_layout)] \
				if count > 0 else "already the runtime's"
	var note := "%d changed" % count if count > 0 else "nothing changed"
	return note + " · not Controls" if scope == RESET_ALL else note


func _reset_count(scope: StringName) -> int:
	if scope == RESET_LAYOUT:
		return 1 if _document.features.is_layout_picked() else 0
	return _document.features.count_changed(_reset_keys(scope))


## The first click on a reset asks; a second within [constant CONFIRM_SEC] puts the defaults back.
func _on_reset_pressed(scope: StringName) -> void:
	var now := Time.get_ticks_usec()
	if _armed != scope or now >= _armed_until_usec:
		_armed = scope
		_armed_until_usec = now + int(CONFIRM_SEC * 1000000.0)
		if is_inside_tree():
			get_tree().create_timer(CONFIRM_SEC).timeout.connect(_refresh_reset)
		_refresh_reset()
		return
	_armed = &""
	_reset_toggle.button_pressed = false
	if scope == RESET_LAYOUT:
		_document.reset_controls_layout(XREDocument.Source.PANEL)
	else:
		_document.reset_features(_reset_keys(scope), XREDocument.Source.PANEL)
