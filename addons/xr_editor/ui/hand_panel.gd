@tool
class_name XREHandPanel
extends XREPanelSurface
## The panel on the left forearm: a tab bar over the edited scene's tree, the
## inspector, signals and the project's files (docs/decisions.md, D-016).
## [XREPanels] lays it on the forearm and shows it with the palette's tray.
##
## The button at the end of the tab bar opens the current tab as a window in
## the scene ([signal pop_out_requested]). Tabs behind the current one are
## hidden and don't update.

## Emitted when the user asks for [param tab] as a window.
signal pop_out_requested(tab: XREPanelTab)

var _tabs: Array[XREPanelTab] = []
var _bar: TabBar
var _pop_out: Button


func _init(tabs: Array[XREPanelTab], logical_size: Vector2, pixel_size: float, render_scale: float,
		theme: Theme) -> void:
	super(logical_size, pixel_size, render_scale, theme)
	var column := VBoxContainer.new()
	root.add_child(column)

	var header := HBoxContainer.new()
	column.add_child(header)
	_bar = TabBar.new()
	_bar.name = "Tabs"
	_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bar.clip_tabs = true
	header.add_child(_bar)
	_pop_out = Button.new()
	_pop_out.name = "PopOut"
	_pop_out.flat = true
	_pop_out.icon = XREPanelTab.theme_icon(theme, &"MakeFloating")
	if _pop_out.icon == null:
		_pop_out.text = "⧉"
	_pop_out.tooltip_text = XREPanelTab.editor_text("Make Floating")
	_pop_out.pressed.connect(func() -> void: pop_out_requested.emit(get_current_tab()))
	header.add_child(_pop_out)

	var page := PanelContainer.new()
	page.name = "Page"
	page.theme_type_variation = &"TabContainer"
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(page)
	for tab: XREPanelTab in tabs:
		_tabs.append(tab)
		page.add_child(tab)
		_bar.add_tab(tab.get_title(), XREPanelTab.theme_icon(theme, tab.get_icon_name()))
	_bar.tab_changed.connect(_on_tab_changed)
	_on_tab_changed(_bar.current_tab)
	pointer_released.connect(func() -> void: get_current_tab().end_edit())


func get_tabs() -> Array[XREPanelTab]:
	return _tabs


func get_current_tab() -> XREPanelTab:
	return _tabs[_bar.current_tab]


func select_tab(index: int) -> void:
	_bar.current_tab = index


func get_tab_bar() -> TabBar:
	return _bar


func get_pop_out_button() -> Button:
	return _pop_out


func _on_tab_changed(index: int) -> void:
	for i: int in _tabs.size():
		_tabs[i].visible = i == index
