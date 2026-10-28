@tool
class_name XREBlueprintRun
extends RefCounted
## One invocation of a Blueprint event in a generated script (D-051): its
## arguments, the results of the blocks it has run and its cancellation. A
## library function whose last parameter is of this type gets the run of the
## block that calls it; the block shows no port for it. Through the run the
## function learns that the event was cancelled ([method alive]) and reports
## an error with the block's ID ([method fail]).

## AnimationPlayer instance ID to the run that waits for its animation: a newer
## play of the same player takes it over, and cancelling the owner stops it.
static var animation_owners: Dictionary[int, XREBlueprintRun] = {}

## ID of the event block that started the run.
var event_id := 0
## The event's arguments, in the order of its signal.
var args: Array = []
## False once cancelled: a restart, the host leaving the tree or an error.
var active := true
## ID of the block running now; errors are reported for it.
var block := -1
## The node running the generated script.
var host: Node
## Results of the blocks that have run, by block ID: impure calls keep them for later reads.
var values: Dictionary[int, Variant] = {}
## Tweens and waited AnimationPlayers that cancelling stops.
var tweens: Array[Tween] = []
var players: Array[AnimationPlayer] = []
## The Sequences whose later outputs wait for the chain running now to end
## (D-134), innermost last: each frame is [code][sequence ID, next output, targets][/code].
var stack: Array[Array] = []
## The step the run is at, and the value each Break and Make gave in it, by
## block ID: [code][step, value][/code] (D-135).
var step := 0
var snapshots: Dictionary[int, Array] = {}


## Whether block [param id] gave its value in this step already.
func has_snapshot(id: int) -> bool:
	return snapshots.has(id) and int(snapshots[id][0]) == step


## Keeps [param value] as block [param id]'s for this step.
func keep(id: int, value: Variant) -> void:
	snapshots[id] = [step, value]


## Whether the run may continue: not cancelled, and its host is in the tree.
func alive() -> bool:
	return active and is_instance_valid(host) and host.is_inside_tree()


## The host's scene tree, or null once it left it.
func tree() -> SceneTree:
	return host.get_tree() if is_instance_valid(host) and host.is_inside_tree() else null


## Stops the run with [param message] reported for the running block. The
## generated script emits [code]blueprint_error[/code] or prints the error.
func fail(message: String) -> void:
	if is_instance_valid(host) and host.has_method(&"_bp_error"):
		host.call(&"_bp_error", self, block, message)
	else:
		cancel()
		push_error("Blueprints block #%d: %s" % [block, message])


## Cancels the run: kills its Tweens and stops the animations it waits for.
func cancel() -> void:
	active = false
	for tween: Tween in tweens:
		if tween.is_valid():
			tween.kill()
	for player: AnimationPlayer in players:
		if is_instance_valid(player) and animation_owners.get(player.get_instance_id()) == self:
			player.stop()
			animation_owners.erase(player.get_instance_id())
