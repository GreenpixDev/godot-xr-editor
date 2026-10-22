@tool
class_name XRESettingsTab
extends XREPanelTab
## Variants of features under study ([XREFeatureSettings], D-039), switched in
## the headset: one page per [enum XREFeatureSettings.Category], a row of
## buttons per setting, one button per value. A switch goes through
## [method XREDocument.set_feature] as an operation from a panel.
## [br][br]
## The Controls page (D-050) picks the layout of the controller buttons
## ([constant XREFeatureSettings.LAYOUTS]) and has a row per action: its name
## on the left, its button with the button's icon ([XREButtonGlyph]) on the
## right. A click on the button waits for a controller button
## ([method wants_button]); the one pressed becomes the action's, in the custom
## layout ([method XREDocument.set_binding]). Another click, or
## [constant CAPTURE_SEC] without a press, cancels the wait.

## How long a binding waits for a button, in seconds.
const CAPTURE_SEC := 5.0
## What a binding button says while it waits.
const PRESS_TEXT := "Press a button…"

## Page titles, by [enum XREFeatureSettings.Category].
const PAGE_TITLES: Array[String] = ["Features", "Controls"]

var _pages: TabBar
var _content: VBoxContainer
## Value buttons by setting key, in [method XREFeatureSettings.get_values] order.
var _buttons: Dictionary[StringName, Array] = {}
## Layout buttons by layout, on the Controls page.
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
	_pages = TabBar.new()
	_pages.name = "Pages"
	for title: String in PAGE_TITLES:
		_pages.add_tab(title)
	_pages.tab_changed.connect(func(_page: int) -> void: _build_page())
	add_child(_pages)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_content = VBoxContainer.new()
	_content.name = "Content"
	_content.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(_content)
	# Freed with the tab: the connection goes with it.
	_document.features.changed.connect(_on_feature_changed)
	_build_page()


func get_title() -> String:
	return editor_text("Settings")


func get_symbol() -> StringName:
	return &"settings"


## Shows page [param category].
func select_page(category: XREFeatureSettings.Category) -> void:
	_pages.current_tab = category


func get_page_bar() -> TabBar:
	return _pages


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


## The button that sets [param key] to [param value], or null if it isn't on the current page.
func get_button(key: StringName, value: StringName) -> Button:
	if not key in _buttons:
		return null
	var index := XREFeatureSettings.get_values(key).find(value)
	return _buttons[key][index] as Button if index >= 0 else null


func _on_feature_changed(_key: StringName) -> void:
	mark_dirty()


func _refresh() -> void:
	for key: StringName in _buttons:
		var current := _document.features.get_value(key)
		var values := XREFeatureSettings.get_values(key)
		for index: int in values.size():
			(_buttons[key][index] as Button).set_pressed_no_signal(values[index] == current)
	var layout := _document.features.get_layout()
	for key: StringName in _layout_buttons:
		_layout_buttons[key].set_pressed_no_signal(key == layout)
	for action: StringName in _binding_buttons:
		_show_binding(action)
	if _keys_label != null:
		_keys_label.visible = _document.features.uses_keyboard()


func _on_hidden() -> void:
	_stop_capture()


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


func _build_page() -> void:
	for child: Node in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	_buttons.clear()
	_layout_buttons.clear()
	_binding_buttons.clear()
	_binding_glyphs.clear()
	_binding_labels.clear()
	_keys_label = null
	_capturing = &""
	if _pages.current_tab == XREFeatureSettings.Category.CONTROLS:
		_build_controls_page()
		mark_dirty()
		return
	var keys := XREFeatureSettings.get_keys(_pages.current_tab as XREFeatureSettings.Category)
	if keys.is_empty():
		var message := _make_message("No settings here yet.")
		message.visible = true
		_content.add_child(message)
	for key: StringName in keys:
		var definition: Dictionary = XREFeatureSettings.DEFINITIONS[key]
		var title := Label.new()
		title.text = definition["title"]
		_content.add_child(title)
		var row := HBoxContainer.new()
		row.name = String(key)
		_content.add_child(row)
		var group := ButtonGroup.new()
		var labels: Array = definition["labels"]
		var buttons: Array[Button] = []
		var values := XREFeatureSettings.get_values(key)
		for index: int in values.size():
			var button := Button.new()
			button.name = String(values[index])
			button.text = labels[index]
			button.toggle_mode = true
			button.button_group = group
			button.size_flags_horizontal = SIZE_EXPAND_FILL
			button.pressed.connect(_document.set_feature.bind(key, values[index], XREDocument.Source.PANEL))
			row.add_child(button)
			buttons.append(button)
		_buttons[key] = buttons
		var hint := Label.new()
		hint.text = definition["hint"]
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint.modulate = Color(1.0, 1.0, 1.0, 0.7)
		_content.add_child(hint)
	mark_dirty()


func _build_controls_page() -> void:
	var title := Label.new()
	title.text = "Controls layout"
	_content.add_child(title)
	var row := HBoxContainer.new()
	row.name = "Layouts"
	_content.add_child(row)
	var group := ButtonGroup.new()
	for index: int in XREFeatureSettings.LAYOUTS.size():
		var layout := XREFeatureSettings.LAYOUTS[index]
		var button := Button.new()
		button.name = String(layout)
		button.text = XREFeatureSettings.LAYOUT_LABELS[index]
		button.toggle_mode = true
		button.button_group = group
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.pressed.connect(_document.set_controls_layout.bind(layout, XREDocument.Source.PANEL))
		row.add_child(button)
		_layout_buttons[layout] = button
	var hint := Label.new()
	hint.text = "Set for the runtime until you pick one. Click a binding, then press the button: it switches to Custom, which keeps every other binding and is then used on every runtime."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.modulate = Color(1.0, 1.0, 1.0, 0.7)
	_content.add_child(hint)
	# The keys that aren't controller buttons don't rebind; they show here.
	_keys_label = Label.new()
	_keys_label.name = "Keys"
	_keys_label.text = XRESimulator.HELP
	_keys_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_keys_label.visible = _document.features.uses_keyboard()
	_content.add_child(_keys_label)
	for action: StringName in XREFeatureSettings.ACTIONS:
		var row_action := HBoxContainer.new()
		row_action.name = String(action)
		_content.add_child(row_action)
		var label := Label.new()
		label.text = XREFeatureSettings.ACTION_TITLES[action]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row_action.add_child(label)
		var button := Button.new()
		button.name = "Binding"
		button.toggle_mode = true
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.size_flags_stretch_ratio = 0.7
		button.pressed.connect(toggle_capture.bind(action))
		row_action.add_child(button)
		# A Button doesn't size to its children: the content sets its minimum size.
		var content := HBoxContainer.new()
		content.mouse_filter = MOUSE_FILTER_IGNORE
		content.set_anchors_and_offsets_preset(PRESET_FULL_RECT, PRESET_MODE_MINSIZE, 6)
		content.alignment = BoxContainer.ALIGNMENT_CENTER
		button.add_child(content)
		var glyph := XREButtonGlyph.new()
		content.add_child(glyph)
		var name_label := Label.new()
		name_label.mouse_filter = MOUSE_FILTER_IGNORE
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		content.add_child(name_label)
		content.minimum_size_changed.connect(func() -> void:
			button.custom_minimum_size = content.get_combined_minimum_size() + Vector2(12.0, 8.0))
		_binding_buttons[action] = button
		_binding_glyphs[action] = glyph
		_binding_labels[action] = name_label
		_show_binding(action)
