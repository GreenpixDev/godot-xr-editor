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

## Emitted when the set of selected nodes changes, from VR or from the desktop.
signal selection_changed
## Emitted when the edited scene root is replaced (scene opened, closed or switched).
signal scene_changed


## Root of the scene being edited, or null if no scene is open.
@abstract func get_scene_root() -> Node


@abstract func get_selection() -> Array[Node]


## Replaces the current selection. Selection is not recorded in undo history.
@abstract func select(nodes: Array[Node]) -> void


## Moves a node live while the user drags it. Not recorded in undo history;
## finish every drag with [method commit_transform].
@abstract func preview_transform(node: Node3D, xform: Transform3D) -> void


## Records one undo step from [param before] to the node's current local transform.
@abstract func commit_transform(node: Node3D, before: Transform3D) -> void


@abstract func set_property(object: Object, property: StringName, value: Variant) -> void


## Adds [param node] under [param parent] and makes it part of the saved scene.
@abstract func add_node(node: Node, parent: Node) -> void


@abstract func remove_node(node: Node) -> void


@abstract func save() -> Error
