@tool
@abstract
class_name XREDocument
extends RefCounted
## The only way VR tools read and change the edited scene.
##
## Tools, UI and the logic graph depend on this class alone, never on
## EditorInterface or EditorUndoRedoManager. That keeps every change undoable
## from the desktop, gives telemetry a single choke point, and lets the
## fallback runtime editor swap the implementation without touching tools
## (see docs/decisions.md, D-002).
##
## Every operation names its [enum Source] and is reported through
## [signal operation_recorded] (docs/decisions.md, D-009). What the user does
## in the headset is recorded in [member history] as well, to undo and redo
## there (D-087): implementations record their changes of the scene, this
## class the switches of the settings and, if asked to, of the selection.

## Emitted when the set of selected nodes changes, from VR or from the desktop.
signal selection_changed
## Emitted when the edited scene root is replaced (scene opened, closed or switched).
signal scene_changed
## Emitted when files of the project were added, removed or reimported.
signal files_changed
## Assignments/scene history changed; graph widgets refresh outside the frame loop.
signal blueprint_bindings_changed
## Emitted once for every operation made through this document, after it took
## effect. [param operation] names it ([code]&"select"[/code],
## [code]&"transform"[/code], [code]&"set_property"[/code], [code]&"add_node"[/code],
## [code]&"remove_nodes"[/code], [code]&"save"[/code], [code]&"open_scene"[/code],
## [code]&"play"[/code], [code]&"stop"[/code], [code]&"undo"[/code],
## [code]&"redo"[/code]); [param time_usec] is
## [method Time.get_ticks_usec] at that moment. Previews are not operations.
signal operation_recorded(operation: StringName, source: Source, nodes: Array[Node], time_usec: int)

## Where an operation came from. The share of operations made through panels
## is one of the study's measures (docs/plan.md, «Оценка»).
enum Source {
	## A 3D tool in the headset: pointing, grabbing, handles.
	TOOL,
	## A flat panel shown in the headset.
	PANEL,
}

## Optional synchronous validation before launching a game from the headset.
var prepare_play: Callable
## Variants of features under study (D-039), shared by every tool and panel.
## Read them here; switch them with [method set_feature].
var features := XREFeatureSettings.new()
## What was done in the headset, to undo and redo there (D-087).
var history := XREHistory.new()


## Puts back the latest step of [member history] and records one
## [code]&"undo"[/code] operation; the editor's log gets the step's name.
## False, and nothing recorded, if there is nothing to undo or it can't be undone now.
func undo(source: Source) -> bool:
	if not _may_replay():
		return false
	var step := history.undo()
	if step.is_empty():
		return false
	print("XR Editor: undo ", step)
	_record(&"undo", source, [])
	return true


## Makes again the step of [member history] undone last and records one
## [code]&"redo"[/code] operation, as [method undo] does.
func redo(source: Source) -> bool:
	if not _may_replay():
		return false
	var step := history.redo()
	if step.is_empty():
		return false
	print("XR Editor: redo ", step)
	_record(&"redo", source, [])
	return true


## Switches feature setting [param key] to [param value] ([XREFeatureSettings])
## and records one [code]&"set_feature"[/code] operation; the editor's log gets
## the new value, so that each participant's session shows the variant used.
## False, and nothing recorded, if the value is unknown or already set.
func set_feature(key: StringName, value: StringName, source: Source) -> bool:
	var before := features.get_value(key)
	if not _switch_feature(key, value):
		return false
	_record(&"set_feature", source, [])
	history.record(XREHistory.Kind.SETTINGS, "Set %s" % XREFeatureSettings.DEFINITIONS[key]["title"],
			_switch_feature.bind(key, before), _switch_feature.bind(key, value))
	return true


## Picks controls layout [param layout] ([constant XREFeatureSettings.LAYOUTS])
## and records one [code]&"set_layout"[/code] operation. False if it is unknown
## or already in use.
func set_controls_layout(layout: StringName, source: Source) -> bool:
	var before := features.get_controls()
	if not features.set_layout(layout):
		return false
	print("XR Editor: controls layout = %s" % layout)
	_record(&"set_layout", source, [])
	history.record(XREHistory.Kind.SETTINGS, "Controls layout", _switch_controls.bind(before), _switch_controls.bind(features.get_controls()))
	return true


## Binds [param action] to [param button] and records one [code]&"set_binding"[/code]
## operation. A preset layout in use becomes the custom one with every other
## binding as it was ([method XREFeatureSettings.set_binding]).
func set_binding(action: StringName, button: StringName, source: Source) -> bool:
	var before := features.get_controls()
	if not features.set_binding(action, button):
		return false
	print("XR Editor: binding %s = %s, layout %s" % [action, button, features.get_layout()])
	_record(&"set_binding", source, [])
	history.record(XREHistory.Kind.SETTINGS, "Bind %s" % XREFeatureSettings.ACTION_TITLES[action], _switch_controls.bind(before), _switch_controls.bind(features.get_controls()))
	return true


## Associates graph source and generated script in one scene-history operation.
## Runtime/fake documents may override this; unrelated scripts must be protected.
func assign_blueprint(_host: Node, _path: String, _script: Script, _source: Source) -> bool:
	return false


## Routes graph operations to the same research telemetry as scene tools.
func record_graph_operation(operation: StringName, source: Source) -> void:
	_record(operation, source, [])


## Root of the scene being edited, or null if no scene is open.
@abstract func get_scene_root() -> Node


@abstract func get_selection() -> Array[Node]


## Replaces the current selection. Selection is not recorded in the editor's
## undo history; it is in [member history] with
## [constant XREFeatureSettings.UNDO_SELECTION] on ([method _remember_selection]).
@abstract func select(nodes: Array[Node], source: Source) -> void


## Moves a node live while the user drags it. Not recorded in undo history
## and not an operation; finish every drag with [method commit_transform], or
## [method commit_transforms] for a group.
@abstract func preview_transform(node: Node3D, xform: Transform3D) -> void


## Records one undo step from [param before] to the node's current local transform.
func commit_transform(node: Node3D, before: Transform3D, source: Source) -> void:
	commit_transforms([node], [before], source)


## Records one undo step that moves each of [param nodes] from its
## [param befores] entry to its current local transform, and one
## [code]&"transform"[/code] operation naming them all (D-115): a group
## dragged together is undone together.
@abstract func commit_transforms(nodes: Array[Node3D], befores: Array[Transform3D], source: Source) -> void


@abstract func set_property(object: Object, property: StringName, value: Variant, source: Source) -> void


## Changes a property live while the user drags its value, like
## [method preview_transform]. Not recorded in undo history and not an
## operation; finish every drag with [method commit_property].
@abstract func preview_property(object: Object, property: StringName, value: Variant) -> void


## Records one undo step from [param before] to the property's current value,
## and one [code]&"set_property"[/code] operation.
@abstract func commit_property(object: Object, property: StringName, before: Variant, source: Source) -> void


## Adds [param node], which has no parent yet, under [param parent] with its
## current transform, and makes it part of the saved scene. One undo step.
@abstract func add_node(node: Node, parent: Node, source: Source) -> void


## Removes [param nodes] as one undo step, as Delete does on the desktop. Only
## [method nodes_to_remove] of them go; if none does, nothing is recorded.
@abstract func remove_nodes(nodes: Array[Node], source: Source) -> void


@abstract func save(source: Source) -> Error


## Opens the scene saved at [param path] for editing, or switches to it if it
## is open already, as a double click in the desktop's FileSystem dock does.
## The edited scene changes ([signal scene_changed]); the scene that was
## edited stays open. Returns [constant ERR_FILE_UNRECOGNIZED] for a file that
## is not a scene ([method is_scene_file]), and [constant ERR_BUSY] if the
## edited scene already changed in this frame and can't change again until
## the next ([XREPluginDocument], D-092).
@abstract func open_scene(path: String, source: Source) -> Error


## The entries of the project folder [param path] (a [code]res://[/code] path),
## as the desktop's FileSystem dock lists them: subfolders first, each name
## ending with [code]/[/code], then files, both sorted. Folders Godot ignores
## and files that are not resources are left out.
@abstract func list_folder(path: String) -> PackedStringArray


## The editor's icon of class [param cls], as the desktop's Scene dock shows
## it, for the cards of the logic graph (D-099); null without an editor or icon.
func get_class_icon(_cls: StringName) -> Texture2D:
	return null


## Resource type of the project file at [param path], like
## [code]&"PackedScene"[/code] or [code]&"Texture2D"[/code]; empty if unknown.
@abstract func get_file_type(path: String) -> StringName


## Plays the edited scene as a game in its own process, as Run Current Scene
## (F6) on the desktop: the open scenes are saved first, and a game already
## running is stopped. Returns [constant ERR_UNCONFIGURED] if the scene has no
## file yet, because the editor would ask for one on the desktop.
## [br][br]
## With [param separate_app], the plugin starts the game itself, not the
## editor's Play, and the game runs without the editor's debugger: as another
## application than the editor, which SteamVR needs (docs/decisions.md, D-012),
## and on a standalone headset in the editor's own process, which it replaces (D-018).
@abstract func play(source: Source, separate_app: bool) -> Error


## Stops the running game, if there is one.
@abstract func stop_playing(source: Source) -> void


## Whether a game run from this editor is running, started from VR or from the desktop.
@abstract func is_playing() -> bool


## Snap steps and whether snapping is on, as the user set them for the 3D view.
## Read when a drag starts.
@abstract func get_snap() -> XRESnap


## Those of [param nodes] that [method remove_nodes] removes, in tree order:
## nodes of the scene under [param root], but not the root itself, nodes
## inside instanced scenes (their owner is the instance), or nodes under
## another of [param nodes], which go with it.
static func nodes_to_remove(nodes: Array[Node], root: Node) -> Array[Node]:
	var result: Array[Node] = []
	if root == null:
		return result
	for node: Node in nodes:
		if node.owner != root or not root.is_ancestor_of(node) or result.has(node):
			continue
		var nested := false
		for other: Node in nodes:
			if other != node and other != root and other.is_ancestor_of(node):
				nested = true
				break
		if not nested:
			result.append(node)
	result.sort_custom(func(a: Node, b: Node) -> bool: return b.is_greater_than(a))
	return result


## Whether [param path] is a scene file the editor opens for editing: a
## [code].tscn[/code] or [code].scn[/code]. Imported scenes like glTF are not:
## the desktop opens their import settings instead.
static func is_scene_file(path: String) -> bool:
	return path.get_extension().to_lower() in ["tscn", "scn"]


## Reports an operation; every implementation calls it once per operation.
func _record(operation: StringName, source: Source, nodes: Array[Node]) -> void:
	operation_recorded.emit(operation, source, nodes, Time.get_ticks_usec())


## Whether a step of [member history] may be put back or made again now. The
## editor refuses to undo while a mouse button is down ([XREPluginDocument]).
func _may_replay() -> bool:
	return true


## Records the change of the selection from [param before] to the one now in
## [member history], when [constant XREFeatureSettings.UNDO_SELECTION] asks
## for it (D-087). Implementations call it from [method select].
func _remember_selection(before: Array[Node]) -> void:
	if features.get_value(XREFeatureSettings.UNDO_SELECTION) != XREFeatureSettings.ON:
		return
	var after := get_selection()
	if after == before:
		return
	history.record(XREHistory.Kind.SELECTION, "Select", _reselect.bind(before), _reselect.bind(after))


## Selects those of [param nodes] still in the scene, for undo and redo of the
## selection: no [code]&"select"[/code] operation, the [code]&"undo"[/code] is one.
func _reselect(nodes: Array[Node]) -> bool:
	var root := get_scene_root()
	var kept: Array[Node] = []
	# A node of a scene closed since is freed.
	for item: Variant in nodes:
		var node := item as Node if is_instance_valid(item) else null
		if node != null and root != null and (node == root or root.is_ancestor_of(node)):
			kept.append(node)
	if kept == get_selection():
		return false
	_set_selection(kept)
	return true


## Selects [param nodes] without an operation. The default goes through
## [method select]; the editor's document selects them itself.
func _set_selection(nodes: Array[Node]) -> void:
	select(nodes, Source.TOOL)


## Sets feature [param key] to [param value], for a switch, its undo and its redo; the editor's log gets the value.
func _switch_feature(key: StringName, value: StringName) -> bool:
	if not features.set_value(key, value):
		return false
	print("XR Editor: feature %s = %s" % [key, value])
	return true


## Puts back the controls [param controls] ([method XREFeatureSettings.get_controls]), for undo and redo.
func _switch_controls(controls: Dictionary) -> bool:
	if not features.set_controls(controls):
		return false
	print("XR Editor: controls layout = %s" % features.get_layout())
	return true
