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
## Emitted once for every operation made through this document, after it took
## effect. [param operation] names it ([code]&"select"[/code],
## [code]&"transform"[/code], [code]&"set_property"[/code], [code]&"add_node"[/code],
## [code]&"remove_node"[/code], [code]&"save"[/code]); [param time_usec] is
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


## Adds [param node] under [param parent] and makes it part of the saved scene.
@abstract func add_node(node: Node, parent: Node, source: Source) -> void


@abstract func remove_node(node: Node, source: Source) -> void


@abstract func save(source: Source) -> Error


## Snap steps and whether snapping is on, as the user set them for the 3D view.
## Read when a drag starts.
@abstract func get_snap() -> XRESnap


## Reports an operation; every implementation calls it once per operation.
func _record(operation: StringName, source: Source, nodes: Array[Node]) -> void:
	operation_recorded.emit(operation, source, nodes, Time.get_ticks_usec())
