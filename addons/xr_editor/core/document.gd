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
## [signal operation_recorded] (docs/decisions.md, D-009).

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
## [code]&"play"[/code], [code]&"stop"[/code]); [param time_usec] is
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


## Replaces the current selection. Selection is not recorded in undo history.
@abstract func select(nodes: Array[Node], source: Source) -> void


## Moves a node live while the user drags it. Not recorded in undo history
## and not an operation; finish every drag with [method commit_transform].
@abstract func preview_transform(node: Node3D, xform: Transform3D) -> void


## Records one undo step from [param before] to the node's current local transform.
@abstract func commit_transform(node: Node3D, before: Transform3D, source: Source) -> void


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
## is not a scene ([method is_scene_file]).
@abstract func open_scene(path: String, source: Source) -> Error


## The entries of the project folder [param path] (a [code]res://[/code] path),
## as the desktop's FileSystem dock lists them: subfolders first, each name
## ending with [code]/[/code], then files, both sorted. Folders Godot ignores
## and files that are not resources are left out.
@abstract func list_folder(path: String) -> PackedStringArray


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
