@tool
@abstract
class_name XREPanelTab
extends VBoxContainer
## One tab of the panels in the headset ([XREPanels]), shown in a window of
## its own: the edited scene's tree, the inspector, signals, the project's
## files, Blueprints or the feature settings. A tab shows the document and
## changes it only through [XREDocument], as operations from a panel
## ([constant XREDocument.Source.PANEL]).
##
## A tab keeps itself up to date only while it is shown. A change while it is
## hidden marks it dirty ([method mark_dirty]); it refreshes once, at the end
## of the frame, when it is shown again: a window pinned to a hand hides while
## the controller isn't tracked.

## Emitted when [method get_window_size] gives another size: the tab's window,
## unless it is pinned to a forearm, is laid out anew at it.
signal window_size_changed

## Translation domain of the editor's interface: tabs say what the desktop's
## docks say, in the editor's language.
const EDITOR_DOMAIN := &"godot.editor"
## Theme type of the editor's icons.
const ICONS := &"EditorIcons"

var _document: XREDocument
var _dirty := true
var _refresh_queued := false


func _init(document: XREDocument) -> void:
	_document = document
	size_flags_vertical = SIZE_EXPAND_FILL


## Title on the tab's tile in the launcher and on its window, in the editor's language.
@abstract func get_title() -> String


## The tab's icon in [XRETabIcons]: its tile in the launcher and on its window.
@abstract func get_symbol() -> StringName


## Size of the tab's window in interface pixels at editor scale 1.
func get_window_size() -> Vector2:
	return XREPanels.WINDOW_SIZE


## Color of the tab's window frame: a Meta window's, or a see-through one.
func get_frame_color() -> Color:
	return XREPanelSurface.META_WINDOW_COLOR


## Finishes an edit made with the pointer. The panel calls it when the
## pointer's button goes up, and the tab when it is hidden.
func end_edit() -> void:
	pass


## Asks for a refresh: at the end of this frame if the tab is shown,
## otherwise when it is shown next.
func mark_dirty() -> void:
	_dirty = true
	if is_inside_tree() and is_visible_in_tree():
		_queue_refresh()


## Whether a change is waiting for the tab to be shown.
func is_dirty() -> bool:
	return _dirty


## The editor's translation of [param text], or [param text] if it has none.
static func editor_text(text: String) -> String:
	return String(TranslationServer.get_or_add_domain(EDITOR_DOMAIN).translate(text))


## The editor icon [param icon_name] of [param theme], or null.
static func theme_icon(theme: Theme, icon_name: StringName) -> Texture2D:
	if theme != null and theme.has_icon(icon_name, ICONS):
		return theme.get_icon(icon_name, ICONS)
	return null


## Whether the tab's window shows the Control Bar under it when the ray is on
## it: its icon, its pin and its ×. A window of an input has its own × (D-062).
func has_control_bar() -> bool:
	return true


## Whether the tab's window is drawn over everything, as an input of the graph
## is (D-058), but without darkening the rest (D-086): the graph's cards between
## it and the head neither hide it nor take its ray.
func is_drawn_on_top() -> bool:
	return false


## Whether the tab waits for a controller button to be pressed
## ([constant XREFeatureSettings.BUTTONS]). [XREPanels] then gives it the next
## one ([method take_button]), and no tool acts on that press.
func wants_button() -> bool:
	return false


## Takes [param button], pressed while [method wants_button].
func take_button(_button: StringName) -> void:
	pass


## Rebuilds what the tab shows from the document.
@abstract func _refresh() -> void


## Called when the tab is hidden, after [method end_edit].
func _on_hidden() -> void:
	pass


func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		if _dirty and is_visible_in_tree():
			_queue_refresh()
	elif what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree():
			if _dirty:
				_queue_refresh()
		else:
			end_edit()
			_on_hidden()


func _queue_refresh() -> void:
	if _refresh_queued:
		return
	_refresh_queued = true
	_run_refresh.call_deferred()


func _run_refresh() -> void:
	_refresh_queued = false
	if not _dirty or not is_inside_tree() or not is_visible_in_tree():
		return
	_dirty = false
	_refresh()


## The editor icon of class [param type], or of its nearest ancestor class
## that has one, or the icon [param fallback]; null without the editor's theme.
func _class_icon(type: StringName, fallback: StringName) -> Texture2D:
	var current := type
	while not current.is_empty():
		if has_theme_icon(current, ICONS):
			return get_theme_icon(current, ICONS)
		if not ClassDB.class_exists(current):
			break
		current = ClassDB.get_parent_class(current)
	return get_theme_icon(fallback, ICONS) if has_theme_icon(fallback, ICONS) else null


## The editor icon [param icon_name], or null without the editor's theme.
func _icon(icon_name: StringName) -> Texture2D:
	return get_theme_icon(icon_name, ICONS) if has_theme_icon(icon_name, ICONS) else null


## A hidden label in the middle of the tab, for when there is nothing to show.
func _make_message(text: String) -> Label:
	var label := Label.new()
	label.name = "Message"
	label.text = text
	label.size_flags_vertical = SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.visible = false
	return label
