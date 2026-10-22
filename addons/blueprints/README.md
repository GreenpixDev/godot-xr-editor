# Blueprints 2D — Godot 4.7

A standalone, early visual scripting editor. No XR plugin, native extension or headset is required.

Copy this folder to `addons/blueprints` in a Godot 4.7.x project, keeping the `.gd.uid` files. Enable **Blueprints 2D** in **Project → Project Settings → Plugins**. Open the **Blueprints** main-screen tab.

Add blocks from the **Add block** menu on the left, by right-clicking the canvas, or by letting a wire go on empty canvas: the menu then lists only blocks that fit and wires the one chosen. Edit parameters on the right. White wires carry execution, blue wires carry values, and pink wires carry booleans. **Save** writes a `.tres` graph and builds a neighboring `.generated.gd` script. Select a scene node without a script, choose **Attach to selected**, save the scene, and run it. Use **Focus graph** for more canvas space.

Use **Script host…** to choose the node holding the script, and **Choose from scene…** for targets. Properties, signals and animations offer lists from the selected node. Typed ports reject incompatible connections; integers may widen to floats. Bound targets follow renames and reparenting while this graph is open. Targets still serialize as relative paths, so changes made with the graph closed require checking its bindings.

Version 0.2.1 adds live target completion and validation. Missing nodes show a red field and the exact message `missing target`. Suggestions include suitable scene nodes; choose with the mouse, Down/Enter or Tab. The scene picker disables wrong target types. Existing nodes missing the selected property/signal/animation show a specific explanation. Invalid target drafts block Save/Build/Attach. A connected Target input makes the path an optional schema sample.

Version 0.2.2 keeps the graph's owner scene in `scene_path`. Switching scene tabs preserves all targets and cached types. Another active scene shows neutral **Graph belongs to …** guidance and an **Open graph scene** button; target editing and reflection resume in the owner scene. Closing its tab does not retarget the graph to another scene. This metadata affects editor context only, not generated runtime code. Older graphs infer their owner from a script user or neighboring same-name scene, falling back to the scene selected on first open.

On Signal exposes its arguments as data ports. Each invocation owns its arguments across waits. Object arguments can feed Target inputs to address the actual event body. **Variables…**, Get Variable and Set Variable provide typed state per script instance.

Events support `parallel`, `ignore` and `restart`. Restart cancels old continuations and their active Tweens / waited animations; it does not undo changes already made. Play Animation optionally waits for named completion, diagnoses interruption and deleted targets, rejects looping waits, and has a real-time timeout. Runtime errors include a block ID and can be handled with the generated `blueprint_error` signal.

The graph is the source. Generated scripts contain ordinary GDScript; since 0.4.0 they need the scripts of this folder at runtime (XREBlueprintRun, XREBlueprintLibrary, XREBlueprintSchema). Version 0.4.0 keeps few native blocks and adds **Call**: any method of a scene node, static function of a class_name script, autoload method or @GlobalScope function. On Ready, Boolean, Print, Delay, Tween, Play Sound and Play Animation are presets; a static function in your own class_name script appears in the menu, shaped by `## @bp_*` tags. Format-2 graphs migrate in memory. Do not hand-edit them: building replaces them. Unrelated scripts on scene nodes are protected.

Version 0.3.1 optionally stores the VR workspace placement and layout origin. XR Editor pins them on first VR opening through the graph document; subsequent openings retain the same scene location. Desktop layout and generated logic ignore this editor-only metadata. Standalone 2D usage still needs no XR/native extension.

Version 0.3 supports execution back edges as well as events, properties, variables, comparisons, branches, delays, tweens, sound, and animation. An iterative runner yields after 64 steps, so even a synchronous loop cannot grow the call stack or prevent subsequent frames. Conditions and values are evaluated again on every visit. Delay, Tween and waited Animation work inside loops; event policies and scene-exit cancellation still apply. Data dependency cycles remain invalid: use graph variables for changing state. User functions, collections/structs, spawn/destroy, and visual debugging are not implemented. Version-one graphs upgrade in memory and are written in version-two format on explicit save.

Graph Undo/Redo is separate from the scene history used to assign a script. Save named graphs with Ctrl+S in this tab. The editor confirms before discarding edits when opening or creating another graph.

Save All / Save and Quit preserves unnamed work as `user://blueprints_unsaved.tres`; the plugin restores it on next startup so you can choose a project path with Save.

Licensed under MIT; see LICENSE.
