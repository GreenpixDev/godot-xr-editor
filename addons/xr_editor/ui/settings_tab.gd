@tool
class_name XRESettingsTab
extends XREPanelTab
## Variants of features under study ([XREFeatureSettings], D-039), switched in
## the headset: one page per [enum XREFeatureSettings.Category], a row of
## buttons per setting, one button per value. A switch goes through
## [method XREDocument.set_feature] as an operation from a panel.

## Page titles, by [enum XREFeatureSettings.Category].
const PAGE_TITLES: Array[String] = ["Features", "Controls"]

var _pages: TabBar
var _content: VBoxContainer
## Value buttons by setting key, in [method XREFeatureSettings.get_values] order.
var _buttons: Dictionary[StringName, Array] = {}


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


func get_icon_name() -> StringName:
	return &"Tools"


## Shows page [param category].
func select_page(category: XREFeatureSettings.Category) -> void:
	_pages.current_tab = category


func get_page_bar() -> TabBar:
	return _pages


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


func _build_page() -> void:
	for child: Node in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	_buttons.clear()
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
