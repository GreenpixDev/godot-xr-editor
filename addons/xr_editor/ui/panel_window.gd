@tool
class_name XREPanelWindow
extends XREPanelSurface
## One tab of the forearm panel opened as a window in the scene
## (docs/decisions.md, D-016): a title bar with the tab's icon and title and a
## close button, over the tab. [XREPanels] places and moves it, also by its
## corner handles (D-040). It is rig-locked (docs/vr_ui.md): it goes along
## when the user flies or turns with the sticks, not with the head, and it
## stays when another scene is opened.

## Emitted when the close button is clicked.
signal close_requested

## The tab the window shows; it is the window's own, not the forearm panel's.
var tab: XREPanelTab

var _close: Button


func _init(content: XREPanelTab, logical_size: Vector2, pixel_size: float, render_scale: float, theme: Theme) -> void:
	super(logical_size, pixel_size, render_scale, theme)
	tab = content
	var column := VBoxContainer.new()
	root.add_child(column)

	var title_bar := HBoxContainer.new()
	title_bar.name = "TitleBar"
	column.add_child(title_bar)
	var icon := TextureRect.new()
	icon.texture = XREPanelTab.theme_icon(theme, tab.get_icon_name())
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	title_bar.add_child(icon)
	var title := Label.new()
	title.text = tab.get_title()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if theme != null and theme.has_font(&"bold", &"EditorFonts"):
		title.add_theme_font_override(&"font", theme.get_font(&"bold", &"EditorFonts"))
	title_bar.add_child(title)
	_close = Button.new()
	_close.name = "Close"
	_close.flat = true
	_close.icon = XREPanelTab.theme_icon(theme, &"Close")
	if _close.icon == null:
		_close.text = "×"
	_close.tooltip_text = XREPanelTab.editor_text("Close")
	_close.pressed.connect(close_requested.emit)
	title_bar.add_child(_close)

	var page := PanelContainer.new()
	page.name = "Page"
	page.theme_type_variation = &"TabContainer"
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(tab)
	column.add_child(page)
	pointer_released.connect(tab.end_edit)
	add_corner_handles()


func get_close_button() -> Button:
	return _close
