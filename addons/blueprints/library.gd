@tool
class_name XREBlueprintLibrary
extends RefCounted
## Blueprint blocks written in GDScript (D-051). A static function here, or in
## any script with a [code]class_name[/code], is a block of the action menu: a
## Call block runs it, nothing in the compiler is particular to it. Tags in the
## [code]##[/code] comment above a function tell the menu and the block how to
## show it ([XREBlueprintFunctions]):
## [br]- [code]@bp_name[/code], [code]@bp_category[/code], [code]@bp_keywords[/code]: its name, group and search words;
## [br]- [code]@bp_target[/code] [i]arg[/i]: the argument is the block's Target, a scene node with a wire to it;
##   [code]@bp_target_types[/code] lists the classes it may be;
## [br]- [code]@bp_literal[/code] [i]args[/i]: set on the block, without a port;
## [br]- [code]@bp_provider[/code] [i]arg kind[/i]: offer the target's animations, properties or signals for it;
## [br]- [code]@bp_type_of[/code] [i]arg property[/i]: the argument's port takes the type of that property;
## [br]- [code]@bp_advanced[/code] [i]args[/i]: hidden until the block shows its advanced arguments;
## [br]- [code]@bp_positive[/code] [i]args[/i]: numbers that must be greater than zero;
## [br]- [code]@bp_non_negative[/code] [i]args[/i]: numbers that may be zero but not less;
## [br]- [code]@bp_then[/code] [i]label[/i]: the name of the execution output; [code]@bp_pure[/code]: no execution ports.
## [br]A last argument of type [XREBlueprintRun] is the event's run, passed by
## the block. A static [code]_validate_<function>(target, args) -> String[/code]
## beside a function checks a block's settings in the editor; the error it
## returns shows as the block's Target problem, before the game runs.


## Waits [param seconds] of game time, or until the event's run is cancelled;
## 0 waits for the next frame.
## @bp_name Delay
## @bp_category Flow
## @bp_keywords wait timer pause sleep
## @bp_then Finished
## @bp_non_negative seconds
static func delay(seconds: float = 1.0, run: XREBlueprintRun = null) -> void:
	if run == null:
		return
	var tree := run.tree()
	if tree == null:
		return
	var timer := tree.create_timer(seconds)
	while run.alive() and timer.time_left > 0.0:
		await tree.process_frame


## Starts an audio player from [param from_position] seconds and continues at once.
## @bp_name Play Sound
## @bp_category Audio
## @bp_keywords sfx audio sound effect
## @bp_target player
## @bp_target_types AudioStreamPlayer AudioStreamPlayer2D AudioStreamPlayer3D
## @bp_advanced from_position
static func play_sound(player: Node, from_position: float = 0.0, run: XREBlueprintRun = null) -> void:
	if not (player is AudioStreamPlayer or player is AudioStreamPlayer2D or player is AudioStreamPlayer3D):
		if run != null:
			run.fail("Play Sound needs an audio player.")
		return
	player.call(&"play", from_position)


## Plays [param animation] of an AnimationPlayer. With [param wait] the chain
## continues only after it finishes: an interruption, the player leaving the
## scene or [param timeout] seconds of real time stop the chain with an error.
## A looping animation can't be waited for.
## @bp_name Play Animation
## @bp_category Animation
## @bp_keywords anim clip open close
## @bp_target player
## @bp_literal animation wait
## @bp_provider animation animation
## @bp_positive timeout
static func play_animation(player: AnimationPlayer, animation: StringName = &"open", wait: bool = false, timeout: float = 30.0, run: XREBlueprintRun = null) -> void:
	if player == null or not player.has_animation(animation):
		_fail(run, "AnimationPlayer or animation missing: " + animation)
		return
	if wait and player.get_animation(animation).loop_mode != Animation.LOOP_NONE:
		_fail(run, "Cannot wait for a looping animation: " + animation)
		return
	var identity := player.get_instance_id()
	if not wait or run == null:
		XREBlueprintRun.animation_owners.erase(identity)
		player.play(animation)
		return
	var finished: Array[bool] = [false]
	var completed := func(name: StringName) -> void:
		if name == animation:
			finished[0] = true
	player.animation_finished.connect(completed)
	# By slot: a freed player can't be looked up in a typed array.
	var slot := run.players.size()
	run.players.append(player)
	XREBlueprintRun.animation_owners[identity] = run
	player.play(animation)
	var tree := run.tree()
	var deadline := Time.get_ticks_msec() + int(timeout * 1000.0)
	while run.alive() and not finished[0]:
		if not is_instance_valid(player) or not player.is_inside_tree():
			run.fail("Animation target left the scene.")
			break
		if XREBlueprintRun.animation_owners.get(identity) != run or not player.is_playing() or player.current_animation != animation:
			run.fail("Animation interrupted: " + animation)
			break
		if Time.get_ticks_msec() >= deadline:
			run.fail("Animation wait timed out: " + animation)
			break
		await tree.process_frame
	if is_instance_valid(player) and player.animation_finished.is_connected(completed):
		player.animation_finished.disconnect(completed)
	if slot < run.players.size():
		run.players.remove_at(slot)
	if XREBlueprintRun.animation_owners.get(identity) == run:
		XREBlueprintRun.animation_owners.erase(identity)


## Changes [param property] of [param target] smoothly to [param value] over
## [param seconds], then continues. Cancelling the run kills the Tween; what
## has changed stays.
## @bp_name Tween Property
## @bp_category Motion
## @bp_keywords move animate interpolate slide fade
## @bp_target target
## @bp_literal property
## @bp_provider property property
## @bp_type_of value property
## @bp_then Finished
## @bp_non_negative seconds
static func tween_property(target: Node, property: String = "position", value: Variant = Vector2(400, 240), seconds: float = 1.0, run: XREBlueprintRun = null) -> void:
	if run == null or target == null:
		_fail(run, "Tween target is missing.")
		return
	var info := XREBlueprintSchema.property_info(target, property)
	if info.is_empty():
		run.fail("Missing property: " + property)
		return
	if int(info.get("usage", 0)) & PROPERTY_USAGE_READ_ONLY:
		run.fail("Property is read-only: " + property)
		return
	if not int(info["type"]) in XREBlueprintSchema.TWEENABLE_TYPES:
		run.fail("This property cannot be tweened: " + property)
		return
	if not XREBlueprintSchema.accepts(int(info["type"]), typeof(value)):
		run.fail("Expected %s, got %s." % [type_string(int(info["type"])), type_string(typeof(value))])
		return
	var tween := target.create_tween()
	run.tweens.append(tween)
	tween.tween_property(target, NodePath(property), value, seconds)
	var tree := run.tree()
	# A killed Tween never emits finished. Poll its lifetime and the run token.
	while run.alive() and tween.is_valid():
		if not is_instance_valid(target) or not target.is_inside_tree():
			run.fail("Tween target left the scene.")
			break
		await tree.process_frame
	run.tweens.erase(tween)
	if tween.is_valid():
		tween.kill()


static func _validate_play_animation(target: Node, args: Dictionary) -> String:
	var player := target as AnimationPlayer
	var animation := StringName(str(args.get("animation", "")))
	if player == null or not player.has_animation(animation):
		return ""
	if args.get("wait", false) and player.get_animation(animation).loop_mode != Animation.LOOP_NONE:
		return "cannot wait for a looping animation"
	return ""


static func _validate_tween_property(target: Node, args: Dictionary) -> String:
	var property := str(args.get("property", ""))
	var info := XREBlueprintSchema.property_info(target, property)
	if info.is_empty():
		return ""
	if int(info.get("usage", 0)) & PROPERTY_USAGE_READ_ONLY:
		return "read-only property: " + property
	if not int(info["type"]) in XREBlueprintSchema.TWEENABLE_TYPES:
		return "property cannot be tweened: " + property
	return ""


static func _fail(run: XREBlueprintRun, message: String) -> void:
	if run != null:
		run.fail(message)
	else:
		push_error("Blueprints: " + message)
