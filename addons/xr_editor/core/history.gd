@tool
class_name XREHistory
extends RefCounted
## What the user did in the headset, in the order it was done, to undo by the
## undo action and redo by the redo action (A and B, [XREUndo];
## docs/decisions.md, D-087): changes of the edited scene and of logic graphs,
## values typed, feature settings switched, windows, menus and inputs opened.
##
## Each change is recorded once it is made ([method record]) with two
## callables: one puts it back, the other makes it again, and each returns
## whether it changed anything. The changes recorded in one frame — a press of
## a button and what it set off — are one step: [method undo] puts them back
## in reverse order, [method redo] makes them again in order. The scene's and
## the graphs' own histories stay where they are: a change of the scene is put
## back by the editor's Undo ([XREPluginDocument]), a graph's by its history.
## [br][br]
## A change may stop mattering after it was recorded: a menu that was opened
## has closed by itself as its value was typed, a window was closed by its ×.
## Its callable then changes nothing, and it is left out of the step; a step
## left with nothing is dropped, and the button goes on to the step before it
## (or after it, for redo): every press does something the user sees. A change
## made past the headset — the scene edited on the desktop — makes every
## recorded change of that [enum Kind] stale ([method forget]).
## [br][br]
## While a step is put back or made again, and for the rest of that frame,
## nothing is recorded: what the callables set off belongs to the step.

## Emitted when a step was recorded, undone or redone, or changes were forgotten.
signal changed
## Emitted as soon as a step was put back or made again: what watches the
## interface for what opens ([XREBlueprints]) takes what the step opened and closed as it finds it.
signal replayed

## What a change changes.
enum Kind {
	## The edited scene, in the editor's undo history.
	SCENE,
	## A logic graph, in the graph's own history.
	GRAPH,
	## Feature settings, the controls layout and bindings.
	SETTINGS,
	## The headset's interface: windows, the launcher, menus, inputs and wires being drawn.
	VIEW,
	## The selection of scene objects, with [constant XREFeatureSettings.UNDO_SELECTION] on.
	SELECTION,
}

## Steps kept at most; the oldest go first.
const MAX_STEPS := 200


## One change: what puts it back and what makes it again.
class Change:
	var kind: Kind
	var name: String
	var undo: Callable
	var redo: Callable


## The changes recorded in one frame.
class Step:
	var frame := -1
	var changes: Array[Change] = []


var _steps: Array[Step] = []
## How many of [member _steps], from the first, are done; the others can be redone.
var _done := 0
var _replaying := false
## The frame a step was last put back or made again in.
var _replay_frame := -1


## Records a change of [param kind] that has just been made, by the name
## [param change_name] for the log: [param undo] puts it back and [param redo]
## makes it again, each returning true if it changed anything. Changes
## recorded in one frame make one step. The steps undone are dropped: they
## can't be redone after a new change.
func record(kind: Kind, change_name: String, undo: Callable, redo: Callable) -> void:
	if is_replaying():
		return
	var frame := Engine.get_process_frames()
	if _done < _steps.size():
		_steps.resize(_done)
	var step: Step = _steps.back() if not _steps.is_empty() else null
	if step == null or step.frame != frame:
		step = Step.new()
		step.frame = frame
		_steps.append(step)
		if _steps.size() > MAX_STEPS:
			_steps.pop_front()
		_done = _steps.size()
	var change := Change.new()
	change.kind = kind
	change.name = change_name
	change.undo = undo
	change.redo = redo
	step.changes.append(change)
	changed.emit()


## Whether there is a step to undo.
func can_undo() -> bool:
	return _done > 0


## Whether there is a step to redo.
func can_redo() -> bool:
	return _done < _steps.size()


## The name of the step [method undo] would put back, or empty.
func get_undo_name() -> String:
	return _name(_steps[_done - 1]) if can_undo() else ""


## The name of the step [method redo] would make again, or empty.
func get_redo_name() -> String:
	return _name(_steps[_done]) if can_redo() else ""


## How many steps are kept, done and undone.
func get_step_count() -> int:
	return _steps.size()


## Puts back the latest step done. Returns its name, or empty if there was
## nothing to undo: steps that changed nothing are dropped on the way.
func undo() -> String:
	while can_undo():
		_done -= 1
		var step := _steps[_done]
		if _replay(step, true):
			changed.emit()
			return _name(step)
		_steps.remove_at(_done)
	changed.emit()
	return ""


## Makes again the step undone last. Returns its name, or empty if there was
## nothing to redo: steps that changed nothing are dropped on the way.
func redo() -> String:
	while can_redo():
		var step := _steps[_done]
		if _replay(step, false):
			_done += 1
			changed.emit()
			return _name(step)
		_steps.remove_at(_done)
	changed.emit()
	return ""


## Whether a step is being put back or made again, or was in this frame:
## nothing is recorded then, and a history that changes then was changed by it.
func is_replaying() -> bool:
	return _replaying or _replay_frame == Engine.get_process_frames()


## Drops every change of [param kind], and the steps left with nothing: they
## can't be put back any more, as the history they were in has changed past
## the headset — the scene edited or undone on the desktop, another graph opened.
func forget(kind: Kind) -> void:
	var index := 0
	var forgotten := false
	while index < _steps.size():
		var step := _steps[index]
		var kept: Array[Change] = []
		for change: Change in step.changes:
			if change.kind != kind:
				kept.append(change)
		if kept.size() == step.changes.size():
			index += 1
			continue
		forgotten = true
		step.changes = kept
		if not kept.is_empty():
			index += 1
			continue
		_steps.remove_at(index)
		if index < _done:
			_done -= 1
	if forgotten:
		changed.emit()


## Drops every step.
func clear() -> void:
	_steps.clear()
	_done = 0
	changed.emit()


## Puts [param step] back, [param backward], or makes it again, and keeps in
## it only the changes that changed something.
func _replay(step: Step, backward: bool) -> bool:
	_replaying = true
	var kept: Array[Change] = []
	var count := step.changes.size()
	for offset: int in count:
		var change := step.changes[count - 1 - offset] if backward else step.changes[offset]
		var callable := change.undo if backward else change.redo
		if not callable.is_valid():
			continue
		var result: Variant = callable.call()
		if result is bool and result:
			kept.append(change)
	_replaying = false
	_replay_frame = Engine.get_process_frames()
	if backward:
		kept.reverse()
	step.changes = kept
	replayed.emit()
	return not kept.is_empty()


static func _name(step: Step) -> String:
	return step.changes[0].name if not step.changes.is_empty() else ""
