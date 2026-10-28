@tool
class_name XREBlueprintActions
extends RefCounted
## Everything the action menu can add (D-051), as Unreal's action database:
## each entry spawns a block that is already set up. Sources are the context
## object's class and script (methods, properties to get and set, signals to
## handle), the Blueprint library and static functions of the project's
## script classes, autoloads, utility functions of @GlobalScope and the native
## blocks with their presets. The database is built when a menu opens, never
## per frame; classes are cached, scripts are reread when their source changes.
##
## An action is a Dictionary: [code]id[/code], [code]title[/code],
## [code]subtitle[/code], [code]kind[/code] (event, call, pure, latent,
## property, native, preset or variable), [code]keywords[/code],
## [code]block[/code] (a block without ID and position for
## [method XREBlueprintDocument.insert_block]), [code]target[/code] (the scene
## node it acts on, or null), [code]inputs[/code] and [code]outputs[/code]
## (port types, for the pin filter) and [code]disabled[/code] (why it can't be
## added, or empty). A new variable's action (D-078) has no block but
## [code]variable[/code], the value it starts with; the view adds the variable.

## Groups of actions a menu chip shows: the context object's, the library's,
## @GlobalScope's, the native blocks, all together.
const CONTEXT := &"context"
const LIBRARY := &"library"
const GLOBAL := &"global"
const NATIVE := &"native"
const ALL := &"all"
## Classes every node has: their members go under Advanced.
const ADVANCED_CLASSES: Array[String] = ["Node", "Object"]
## How many recently added actions the menu offers first, and how many best matches of a search.
const RECENT_COUNT := 5
## The menu's groups by task (D-093, D-095), in the order of their chips: what
## a block is for, not where it comes from in code. The general groups first,
## then the groups of the context object, which only its own blocks fill.
const TASKS: Array[String] = ["Events", "Variables", "Arithmetic", "Logic", "Math", "Flow", "Utility", "Move", "Look", "Sound", "Object"]
const GENERAL_TASKS: Array[String] = ["Events", "Variables", "Arithmetic", "Logic", "Math", "Flow", "Utility"]
const OBJECT_TASKS: Array[String] = ["Move", "Look", "Sound", "Object"]
## Words of a member's name that put it in Move or in Look; the rest of an
## object's members are Object.
const MOVE_WORDS: Array[String] = ["position", "rotat", "scale", "transform", "translate", "basis", "quaternion", "look_at", "velocity", "offset"]
## Members those words name that don't move anything: the translation of text.
const NOT_MOVE_WORDS: Array[String] = ["auto_translate", "translate_messages"]
## Classes whose objects move: only they have the group Move (D-095).
const MOVING_CLASSES: Array[String] = ["Node2D", "Node3D", "Control"]
const LOOK_WORDS: Array[String] = ["visible", "show", "hide", "transparency", "modulate", "color", "text", "material", "albedo", "energy", "texture"]
## The start values of new variables the menu offers (D-078), one of each type.
const NEW_VARIABLES: Array = [false, 0, 0.0, "", Vector2.ZERO, Vector3.ZERO, Color.WHITE]

static var _shared: XREBlueprintActions

## IDs of actions added lately, the newest first.
var recent: Array[String] = []
var _classes: Dictionary[String, Dictionary] = {}
var _scripts: Dictionary[String, Dictionary] = {}


## One database for every menu of the editor.
static func shared() -> XREBlueprintActions:
	if _shared == null:
		_shared = XREBlueprintActions.new()
	return _shared


## Notes that [param action] was added, so that it is offered first next time.
func remember(action: Dictionary) -> void:
	recent.erase(action["id"])
	recent.insert(0, action["id"])
	if recent.size() > 16: recent.resize(16)


## Forgets cached scripts: the next menu rereads them.
func invalidate_scripts() -> void:
	_scripts.clear()


## Sections of the menu for [param context]: [code]{"title", "actions",
## "advanced", "count"}[/code]. The context has [code]chip[/code] (a group),
## [code]node[/code] (the context object, or null), [code]class[/code] (its
## class when there is no object, as for a pin's), [code]label[/code],
## [code]host[/code] (the script host), [code]graph[/code], [code]pin[/code]
## ([code]{"type", "output"}[/code] of the port a wire comes from, or empty;
## an input's may have [code]value_types[/code], the Variant types a new
## variable may have to go into it, D-079, D-080),
## [code]query[/code] (words that must all match), [code]advanced[/code]
## (whether Advanced is open) and [code]new_variables[/code] (whether the view
## adds new variables, D-078), [code]one_set[/code] (whether the view has one Set for
## a property and a variable, D-102). An Advanced section lists its actions only when
## open or searched. The graph's variables are a section of the native blocks,
## and of the host's chip, whose script they belong to.
func sections(context: Dictionary) -> Array[Dictionary]:
	if not str(context.get("task", "")).is_empty(): return _task_sections(context)
	var chip: StringName = context.get("chip", CONTEXT)
	var result: Array[Dictionary] = []
	var node := context.get("node") as Node
	var cls := str(context.get("class", node.get_class() if node != null else ""))
	# A script class of a pin is shown as the engine class it extends.
	if not cls.is_empty() and not ClassDB.class_exists(cls):
		var script := XREBlueprintFunctions.global_script(cls)
		cls = str(script.get_instance_base_type()) if script != null else "Node"
	var label := str(context.get("label", node.name if node != null else cls))
	var host := context.get("host") as Node
	var graph := context.get("graph") as XREBlueprintGraph
	if graph == null: graph = XREBlueprintGraph.new()
	var dynamic := node == null and not cls.is_empty()
	if chip in [CONTEXT, ALL] and not cls.is_empty():
		var own_from := result.size()
		result.append(_section("Presets", _presets(node, cls, host, graph, dynamic), context))
		var own := _class_actions(cls, true)
		var script := node.get_script() as Script if node != null else null
		var members := own.duplicate()
		if script != null: members.append_array(_script_actions(script, cls))
		result.append(_section("%s · %s" % [label, _class_title(node, cls)], _bind(members, node, dynamic, graph), context))
		var base := str(ClassDB.get_parent_class(cls))
		while not base.is_empty() and not base in ADVANCED_CLASSES:
			result.append(_section(base + " · inherited", _bind(_class_actions(base, true), node, dynamic, graph), context))
			base = str(ClassDB.get_parent_class(base))
		result.append(_section("Signals · " + label, _bind(_signal_actions(node, cls, script), node, dynamic, graph), context))
		if chip == CONTEXT and node != null and node == host: result.append(_section("Variables", _variable_actions(graph, host, context), context))
		result.append(_section("Library", _bind(_library_actions(cls), node, dynamic, graph), context))
		if chip == CONTEXT or context.get("with_advanced", false):
			var advanced: Array[Dictionary] = []
			for name: String in ADVANCED_CLASSES:
				if ClassDB.is_parent_class(cls, name): advanced.append_array(_class_actions(name, true))
			var section := _section("Advanced · Node, Object", _bind(advanced, node, dynamic, graph), context)
			section["advanced"] = true
			section["count"] = (section["actions"] as Array).size()
			if not context.get("advanced", false) and str(context.get("query", "")).strip_edges().is_empty(): section["actions"] = []
			result.append(section)
		# The object's own sections (D-095): what its groups Move, Look, Sound and Object list.
		for index: int in range(own_from, result.size()):
			if result[index]["title"] != "Variables": result[index]["object"] = true
	if chip in [LIBRARY, ALL]:
		var library := _library_actions("")
		if chip == ALL and not cls.is_empty():
			library = library.filter(func(action: Dictionary) -> bool: return not _fits_class(action, cls))
		var groups: Dictionary[String, Array] = {}
		for action: Dictionary in _bind(library, node if chip == LIBRARY else null, false, graph, host):
			var group: String = action.get("category", "Library")
			if not groups.has(group): groups[group] = []
			groups[group].append(action)
		for group: String in groups:
			result.append(_section(group, groups[group], context))
		for autoload: Dictionary in _autoload_actions():
			result.append(_section("Autoload · " + autoload["name"], autoload["actions"], context))
	if chip in [GLOBAL, ALL]:
		var categories: Dictionary[String, Array] = {}
		for action: Dictionary in _global_actions():
			var group: String = action["category"]
			if not categories.has(group): categories[group] = []
			categories[group].append(action)
		for group: String in categories:
			result.append(_section(group, categories[group], context))
	if chip in [NATIVE, ALL]:
		result.append(_section("Native", _native_actions(graph, host, context.get("one_set", false)), context))
		result.append(_section("Break & Make", _bind(_struct_actions(), host, false, graph), context))
		result.append(_section("Variables", _variable_actions(graph, host, context), context))
		for title: String in ["Math", "Comparison", "Logic"]:
			result.append(_section(title, _operator_actions(title, graph, host), context))
	result = result.filter(func(section: Dictionary) -> bool: return not (section["actions"] as Array).is_empty() or section.get("count", 0) > 0)
	if str(context.get("query", "")).strip_edges().is_empty() and not recent.is_empty():
		var found: Array[Dictionary] = []
		for id: String in recent:
			for section: Dictionary in result:
				for action: Dictionary in section["actions"]:
					if action["id"] == id and found.size() < RECENT_COUNT and not found.has(action): found.append(action)
		if not found.is_empty(): result.insert(0, {"title": "Recent", "actions": found, "advanced": false, "count": found.size()})
	var best := _best_matches(result, str(context.get("query", "")))
	if not best.is_empty(): result.insert(0, {"title": "Best matches", "actions": best, "advanced": false, "count": best.size()})
	return result


## The sections of task [code]task[/code] of [param context] (D-093): those of
## all the blocks, with the context object's Advanced, each keeping only the
## blocks of that task ([method task_of]); a group of the object
## ([constant OBJECT_TASKS]) only the object's own sections (D-095).
func _task_sections(context: Dictionary) -> Array[Dictionary]:
	var task := str(context["task"])
	var base := context.duplicate()
	base.erase("task")
	base["chip"] = ALL
	base["with_advanced"] = task == "Object"
	var result: Array[Dictionary] = []
	var cls := _context_class(context)
	for section: Dictionary in sections(base):
		if task in OBJECT_TASKS and not section.get("object", false): continue
		if section.get("advanced", false):
			result.append(section)
			continue
		var kept: Array[Dictionary] = []
		for action: Dictionary in section["actions"]:
			if _task_for(action, cls) == task: kept.append(action)
		if kept.is_empty(): continue
		var copy := section.duplicate()
		copy["actions"] = kept
		copy["count"] = kept.size()
		result.append(copy)
	return result


## The task group of [param action] (D-093, D-095), one of [constant TASKS]:
## events; variables and values; arithmetic — the operators + − × ÷ % —;
## logic — comparisons, Equal, AND, OR, NOT —; math — the functions of
## @GlobalScope's math and random, vectors —; flow — Branch, Delay, what
## orders the run —; utility — Print, Get Time, the rest of @GlobalScope —;
## moving, the look, sound and animation, and the object's other members.
## An object's member is Move or Look by the words of its name.
static func task_of(action: Dictionary) -> String:
	var id := str(action["id"])
	if action.get("kind", "") == "event": return "Events"
	if action.get("kind", "") == "variable" or id in ["native:value", "preset:boolean"]: return "Variables"
	if id == "native:equals": return "Logic"
	if id.begins_with("operator:"):
		return "Arithmetic" if XREBlueprintOperators.group_of(id.trim_prefix("operator:")) in [XREBlueprintOperators.MATH, XREBlueprintOperators.TEXT] else "Logic"
	if id in ["native:branch", "preset:delay", "native:sequence"] or id.begins_with("native:switch_"): return "Flow"
	if id.begins_with("struct:"): return "Math"
	if id == "preset:print": return "Utility"
	if id == "preset:tween": return "Move"
	if id in ["preset:play_sound", "preset:play_animation"]: return "Sound"
	var category := str(action.get("category", ""))
	if category.begins_with("@GlobalScope · "): return "Math" if category.ends_with(" · math") or category.ends_with(" · random") else "Utility"
	match category:
		"Vector": return "Math"
		"Flow": return "Flow"
		"Time": return "Utility"
		"Motion": return "Move"
		"Color": return "Look"
		"Audio", "Animation": return "Sound"
	var member := id.get_slice(".", id.get_slice_count(".") - 1) if id.contains(".") else ""
	var moving := not NOT_MOVE_WORDS.any(func(word: String) -> bool: return member.contains(word))
	for word: String in MOVE_WORDS:
		if moving and member.contains(word): return "Move"
	for word: String in LOOK_WORDS:
		if member.contains(word): return "Look"
	return "Object"


## Up to [constant RECENT_COUNT] actions of [param sections] whose title
## [param query] begins, or one of its words does: Sin before Asin for "sin".
## The title itself first, then a beginning of it, then of a word; shorter first.
static func _best_matches(sections: Array[Dictionary], query: String) -> Array[Dictionary]:
	var wanted := query.strip_edges().to_lower()
	var best: Array[Dictionary] = []
	if wanted.is_empty(): return best
	var scored: Array[Array] = []
	var seen: Dictionary[String, bool] = {}
	for action: Dictionary in flatten(sections):
		if seen.has(action["id"]) or not str(action["disabled"]).is_empty(): continue
		seen[action["id"]] = true
		var title := str(action["title"]).to_lower()
		var score := 3 if title == wanted else 2 if title.begins_with(wanted) else 1 if (" " + title).contains(" " + wanted) else 0
		if score > 0: scored.append([score, title.length(), scored.size(), action])
	scored.sort_custom(func(first: Array, second: Array) -> bool:
		if first[0] != second[0]: return first[0] > second[0]
		if first[1] != second[1]: return first[1] < second[1]
		return first[2] < second[2])
	for entry: Array in scored.slice(0, RECENT_COUNT): best.append(entry[3])
	return best


## The [param count] blocks most likely to be added next for [param context]
## (D-093), best first, of every group and section: those that fit its pin,
## one of each kind ([method XREBlueprintStats.key_of]), none that can't be
## added ([method rank]).
func suggest(context: Dictionary, count: int, stats: XREBlueprintStats) -> Array[Dictionary]:
	return rank(flatten(sections(_every_block(context, false))), context.get("pin", {}), stats, count)


## The blocks of each task group for [param context] (D-093), by
## [constant TASKS], each ranked ([method rank]) and at most [param count]; a
## group of the object only the context object's own blocks (D-095).
func by_task(context: Dictionary, count: int, stats: XREBlueprintStats) -> Dictionary[String, Array]:
	var groups: Dictionary[String, Array] = {}
	for task: String in TASKS: groups[task] = []
	var cls := _context_class(context)
	for section: Dictionary in sections(_every_block(context, true)):
		var own: bool = section.get("object", false)
		for action: Dictionary in section["actions"]:
			var task := _task_for(action, cls)
			if own or not task in OBJECT_TASKS: groups[task].append(action)
	var pin: Dictionary = context.get("pin", {})
	for task: String in TASKS: groups[task] = rank(groups[task], pin, stats, count)
	return groups


## The groups of [constant OBJECT_TASKS] the context object of [param context]
## has blocks of, whatever the pin (D-095): Move for what moves, Sound for a
## player, none without an object — a graph of networking has no Move.
func object_tasks(context: Dictionary) -> Array[String]:
	var base := _every_block(context, true)
	base.erase("pin")
	base["chip"] = CONTEXT
	var found: Dictionary[String, bool] = {}
	var cls := _context_class(context)
	for section: Dictionary in sections(base):
		if not section.get("object", false): continue
		for action: Dictionary in section["actions"]: found[_task_for(action, cls)] = true
	var tasks: Array[String] = []
	for task: String in OBJECT_TASKS:
		if found.has(task): tasks.append(task)
	return tasks


## The task group of [param action] for a context object of class [param cls]
## ([method task_of]): what would be Move is Object for one that doesn't move
## ([constant MOVING_CLASSES]) — a plain Node's Tween Property.
static func _task_for(action: Dictionary, cls: String) -> String:
	var task := task_of(action)
	if task == "Move" and not MOVING_CLASSES.any(func(moving: String) -> bool: return ClassDB.class_exists(cls) and ClassDB.is_parent_class(cls, moving)): return "Object"
	return task


## The engine class of [param context]'s object, or empty.
static func _context_class(context: Dictionary) -> String:
	var node := context.get("node") as Node
	var cls := str(context.get("class", node.get_class() if node != null else ""))
	if not cls.is_empty() and not ClassDB.class_exists(cls):
		var script := XREBlueprintFunctions.global_script(cls)
		cls = str(script.get_instance_base_type()) if script != null else "Node"
	return cls


## [param context] for all the blocks, without a search; Advanced too with [param advanced].
static func _every_block(context: Dictionary, advanced: bool) -> Dictionary:
	var base := context.duplicate()
	base.erase("task")
	base["chip"] = ALL
	base["query"] = ""
	base["with_advanced"] = advanced
	base["advanced"] = advanced
	return base


## The first [param count] of [param actions], best first (D-093): by the
## wires in [param stats] between the block of [param pin] ([code]key[/code],
## [method XREBlueprintStats.key_of]) and each one's kind — from an output into
## it, from it into an input — then how often its kind is in the graphs, raised
## a little if it was added lately, then their order. One of each kind; none
## that can't be added.
func rank(actions: Array, pin: Dictionary, stats: XREBlueprintStats, count: int) -> Array[Dictionary]:
	var from := str(pin.get("key", ""))
	var output: bool = pin.get("output", true)
	var scored: Array[Array] = []
	var seen: Dictionary[String, bool] = {}
	for action: Dictionary in actions:
		if not str(action["disabled"]).is_empty(): continue
		var key := XREBlueprintStats.key_of(action.get("block", {}))
		if key.is_empty(): key = str(action["id"])
		if seen.has(key): continue
		seen[key] = true
		var wires := 0
		if not from.is_empty() and stats != null: wires = stats.pair_count(from, key) if output else stats.pair_count(key, from)
		var lately := recent.find(str(action["id"]))
		var score := wires * 100 + (stats.kind_count(key) if stats != null else 0) + (2 * (8 - lately) if lately >= 0 and lately < 8 else 0)
		scored.append([score, scored.size(), action])
	scored.sort_custom(func(first: Array, second: Array) -> bool: return first[0] > second[0] or (first[0] == second[0] and first[1] < second[1]))
	var ranked: Array[Dictionary] = []
	for entry: Array in scored.slice(0, count): ranked.append(entry[2])
	return ranked


## Every action of [param sections] in order, without section headers.
static func flatten(sections: Array[Dictionary]) -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	for section: Dictionary in sections:
		for action: Dictionary in section["actions"]:
			actions.append(action)
	return actions


## Whether [param action] can take a wire from a port of type [param type]
## that is an output if [param output]: it has a compatible port on the other side.
static func fits_pin(action: Dictionary, type: int, output: bool) -> bool:
	for port: int in action["inputs" if output else "outputs"]:
		if (XREBlueprintGraph.ports_compatible(type, port) if output else XREBlueprintGraph.ports_compatible(port, type)): return true
	return false


## Whether every word of [param query] is in the action's title, subtitle, keywords or category.
static func matches(action: Dictionary, query: String) -> bool:
	var words := query.to_lower().split(" ", false)
	if words.is_empty(): return true
	var haystack := ("%s %s %s %s %s" % [action["title"], action["subtitle"], action.get("keywords", ""), action.get("category", ""), str(action["id"]).replace("_", " ")]).to_lower()
	for word: String in words:
		if not haystack.contains(word): return false
	return true


func _section(title: String, actions: Array, context: Dictionary) -> Dictionary:
	var pin: Dictionary = context.get("pin", {})
	var query := str(context.get("query", ""))
	var kept: Array[Dictionary] = []
	for action: Dictionary in actions:
		if not pin.is_empty() and not fits_pin(action, pin["type"], pin["output"]): continue
		if not matches(action, query): continue
		kept.append(action)
	# Disabled entries stay visible, with their reason, after the ones that can be added.
	kept.sort_custom(func(first: Dictionary, second: Dictionary) -> bool: return str(first["disabled"]).is_empty() and not str(second["disabled"]).is_empty())
	return {"title": title, "actions": kept, "advanced": false, "count": kept.size()}


## The class shown for [param node]: its script's class name, or its engine class.
static func _class_title(node: Node, cls: String) -> String:
	var script := node.get_script() as Script if node != null else null
	if script != null and not str(script.get_global_name()).is_empty(): return str(script.get_global_name())
	return cls


## Copies of [param actions] aimed at [param node]: its Target, or with
## [param dynamic] an empty Target that a wire supplies. Without a node a
## library action aims at [param host] if it may.
func _bind(actions: Array, node: Node, dynamic: bool, graph: XREBlueprintGraph, host: Node = null) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for source: Dictionary in actions:
		var action := source.duplicate()
		var block: Dictionary = (source["block"] as Dictionary).duplicate(true)
		var aim := node if node != null else host
		if XREBlueprintGraph.has_target(block):
			if dynamic: block["params"]["target"] = ""
			elif aim != null and XREBlueprintSchema.target_kind_problem(block, aim).is_empty(): action["target"] = aim
		action["block"] = block
		var ports := _ports(block, graph)
		action["inputs"] = ports[0]
		action["outputs"] = ports[1]
		result.append(action)
	return result


## Port types of [param block] in [param graph]'s context: inputs, then outputs.
static func _ports(block: Dictionary, graph: XREBlueprintGraph) -> Array:
	var probe := block.duplicate(true)
	# No block of a graph has ID 0: no wire of the graph comes into the probe.
	probe["id"] = 0
	probe["position"] = Vector2.ZERO
	var types: Array = [[], []]
	for side: int in 2:
		for spec: Array in graph.ports(probe, side == 0):
			(types[side] as Array).append(spec[1])
	return types


## Methods and properties of engine class [param cls] declared in it, without
## the accessors of its properties, which are Get and Set actions instead.
func _class_actions(cls: String, own: bool) -> Array:
	if _classes.has(cls): return _classes[cls]["actions"]
	var actions: Array[Dictionary] = []
	var accessors: Dictionary[String, bool] = {}
	var properties: Array[Dictionary] = []
	for info: Dictionary in ClassDB.class_get_property_list(cls, own):
		var name := str(info["name"])
		if not int(info["usage"]) & PROPERTY_USAGE_EDITOR: continue
		accessors[str(ClassDB.class_get_property_setter(cls, name))] = true
		accessors[str(ClassDB.class_get_property_getter(cls, name))] = true
		if int(info["type"]) in XREBlueprintSchema.LITERAL_TYPES: properties.append(info)
	for info: Dictionary in ClassDB.class_get_method_list(cls, own):
		var name := str(info["name"])
		if name.begins_with("_") or accessors.has(name): continue
		var override: Dictionary = XREBlueprintFunctions.OVERRIDES.get(cls + "." + name, {})
		if override.get("hidden", false): continue
		var signature := XREBlueprintFunctions.method_of(cls, cls, info) if own else XREBlueprintFunctions.method(cls, name)
		if signature.is_empty(): continue
		actions.append(_call_action("method:%s.%s" % [cls, name], signature, cls))
	for info: Dictionary in properties:
		actions.append_array(_property_actions(info, cls))
	_classes[cls] = {"actions": actions}
	return actions


## Get and Set of property [param info], declared in [param owner].
static func _property_actions(info: Dictionary, owner: String) -> Array[Dictionary]:
	var name := str(info["name"])
	var title := XREBlueprintFunctions.title_of(name)
	var type := int(info["type"])
	var getter := XREBlueprintGraph.make_node(0, "get_property", Vector2.ZERO)
	getter["params"]["property"] = name
	getter["property_type"] = type
	var setter := XREBlueprintGraph.make_node(0, "set_property", Vector2.ZERO)
	setter["params"]["property"] = name
	setter["property_type"] = type
	# An enumeration's Get makes a Switch wired from it one on its constants (D-138).
	var enum_path := XREBlueprintSchema.property_enum(owner, info)
	if not enum_path.is_empty(): getter["property_enum"] = enum_path
	if XREBlueprintGraph.is_literal(XREBlueprintSchema.default_value(type)): setter["params"]["value"] = XREBlueprintSchema.default_value(type)
	var subtitle := "property %s: %s" % [name, type_string(type)]
	return [
		{"id": "get:%s.%s" % [owner, name], "title": "Get " + title, "subtitle": subtitle, "kind": "pure", "keywords": owner, "category": owner, "block": getter, "target": null, "disabled": ""},
		{"id": "set:%s.%s" % [owner, name], "title": "Set " + title, "subtitle": subtitle, "kind": "property", "keywords": owner, "category": owner, "block": setter, "target": null, "disabled": ""},
	]


## An action that adds a call block of [param signature].
static func _call_action(id: String, signature: Dictionary, category: String) -> Dictionary:
	var arguments := PackedStringArray()
	for argument: Dictionary in signature["args"]:
		if argument.get("self", false) or argument.get("run", false): continue
		arguments.append(str(argument["name"]) + (" = …" if argument.has("default") else ""))
	if signature.get("vararg", false): arguments.append("…")
	var kind := "pure" if signature.get("pure", false) else "latent" if signature.get("awaits", false) else "call"
	var result := " → " + XREBlueprintSchema.type_name(int(signature["return"])) if signature.get("returns", false) else ""
	return {"id": id, "title": signature["title"], "subtitle": "%s(%s)%s" % [signature["name"], ", ".join(arguments), result], "kind": kind,
			"keywords": str(signature.get("keywords", "")) + " " + str(signature["name"]), "category": category,
			"block": XREBlueprintGraph.make_call(0, signature, Vector2.ZERO), "target": null, "disabled": XREBlueprintFunctions.problem(signature)}


## Methods and properties a node's [param script] adds to class [param cls].
func _script_actions(script: Script, cls: String) -> Array[Dictionary]:
	var entry := _script_entry(script)
	if entry.has("members"): return entry["members"]
	var actions: Array[Dictionary] = []
	var global := str(script.get_global_name())
	for info: Dictionary in script.get_script_method_list():
		var name := str(info["name"])
		if name.begins_with("_") or int(info["flags"]) & METHOD_FLAG_STATIC: continue
		var signature := XREBlueprintFunctions.script_method(script, cls, name)
		if signature.is_empty() or signature.get("hidden", false): continue
		actions.append(_call_action("script:%s.%s" % [script.resource_path, name], signature, global if not global.is_empty() else script.resource_path.get_file()))
	for info: Dictionary in script.get_script_property_list():
		if int(info.get("usage", 0)) & PROPERTY_USAGE_EDITOR and int(info["type"]) in XREBlueprintSchema.LITERAL_TYPES:
			actions.append_array(_property_actions(info, global if not global.is_empty() else script.resource_path.get_file()))
	entry["members"] = actions
	return actions


func _script_entry(script: Script) -> Dictionary:
	var key := script.resource_path
	var size := script.source_code.length()
	if not _scripts.has(key) or _scripts[key].get("size", -1) != size: _scripts[key] = {"size": size}
	return _scripts[key]


## "On <signal>" for every signal of [param cls] and of [param script].
func _signal_actions(node: Node, cls: String, script: Script) -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	var infos: Array[Dictionary] = []
	infos.assign(ClassDB.class_get_signal_list(cls))
	if script != null: infos.append_array(script.get_script_signal_list())
	var seen: Dictionary[String, bool] = {}
	for info: Dictionary in infos:
		var name := str(info["name"])
		if seen.has(name): continue
		seen[name] = true
		var block := XREBlueprintGraph.make_node(0, "signal", Vector2.ZERO)
		block["params"]["signal"] = name
		var arguments: Array[Dictionary] = []
		if node != null: arguments = XREBlueprintSchema.signal_arguments(node, name)
		else:
			for argument: Dictionary in info["args"]:
				arguments.append({"name": str(argument["name"]), "type": int(argument["type"]), "class_name": str(argument.get("class_name", ""))})
		block["arguments"] = arguments
		var names := PackedStringArray()
		for argument: Dictionary in arguments: names.append(argument["name"])
		actions.append({"id": "signal:" + name, "title": "On " + XREBlueprintFunctions.title_of(name), "subtitle": "signal %s(%s)" % [name, ", ".join(names)],
				"kind": "event", "keywords": "event signal " + name, "category": cls, "block": block, "target": null, "disabled": ""})
	return actions


## Static functions of the project's script classes: the Blueprint library,
## scripts outside the addons, and functions tagged for Blueprints. With
## [param cls], only the ones whose Target may be a [param cls].
func _library_actions(cls: String) -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	for entry: Dictionary in ProjectSettings.get_global_class_list():
		var path := str(entry["path"])
		var global := str(entry["class"])
		var script_entry: Dictionary = _scripts.get(path, {})
		if not script_entry.has("library"):
			var script := load(path) as Script
			if script == null: continue
			script_entry = _script_entry(script)
			var functions: Array[Dictionary] = []
			var user := not path.begins_with("res://addons/") or global == "XREBlueprintLibrary"
			for info: Dictionary in script.get_script_method_list():
				var name := str(info["name"])
				if name.begins_with("_") or not int(info["flags"]) & METHOD_FLAG_STATIC: continue
				var tags := XREBlueprintFunctions.script_tags(script, name)
				if not user and not _tagged(tags): continue
				var signature := XREBlueprintFunctions.static_of(script, global, name)
				if signature.is_empty() or signature.get("hidden", false): continue
				functions.append(_call_action("static:%s.%s" % [global, name], signature, str(signature["category"])))
			script_entry["library"] = functions
		for action: Dictionary in script_entry["library"]:
			if cls.is_empty() or _fits_class(action, cls): actions.append(action)
	return actions


## Whether tags were written for Blueprints.
static func _tagged(tags: Dictionary) -> bool:
	return tags.has("name") or tags.has("category") or tags.has("target") or tags.has("then") or tags.has("pure") or not (tags.get("break", []) as Array).is_empty()


## Whether [param action]'s Target may be of class [param cls].
static func _fits_class(action: Dictionary, cls: String) -> bool:
	var classes := XREBlueprintSchema.target_classes(action["block"])
	if classes.is_empty() or cls.is_empty(): return false
	for target: Variant in classes:
		if ClassDB.class_exists(str(target)) and ClassDB.class_exists(cls) and ClassDB.is_parent_class(cls, str(target)): return true
	return false


## Methods of the project's autoloads, aimed at /root/<Name>.
func _autoload_actions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for property: Dictionary in ProjectSettings.get_property_list():
		var setting := str(property["name"])
		if not setting.begins_with("autoload/"): continue
		var path := str(ProjectSettings.get_setting(setting)).trim_prefix("*")
		if path.begins_with("res://addons/") or path.get_extension() != "gd": continue
		var script := load(path) as Script
		if script == null: continue
		var name := setting.trim_prefix("autoload/")
		var actions: Array[Dictionary] = []
		for action: Dictionary in _script_actions(script, str(script.get_instance_base_type())):
			var aimed := action.duplicate(true)
			aimed["block"]["params"]["target"] = "/root/" + name
			var ports := _ports(aimed["block"], XREBlueprintGraph.new())
			aimed["inputs"] = ports[0]
			aimed["outputs"] = ports[1]
			actions.append(aimed)
		result.append({"name": name, "actions": actions})
	return result


## Utility functions of @GlobalScope by category.
func _global_actions() -> Array[Dictionary]:
	if _classes.has("@GlobalScope"): return _classes["@GlobalScope"]["actions"]
	var actions: Array[Dictionary] = []
	for name: String in XREBlueprintGlobals.FUNCTIONS:
		# The Min and Max operators take their place (D-136); old blocks still build.
		if name in ["min", "max"]: continue
		var signature := XREBlueprintFunctions.global(name)
		var action := _call_action("global:" + name, signature, signature["category"])
		var ports := _ports(action["block"], XREBlueprintGraph.new())
		action["inputs"] = ports[0]
		action["outputs"] = ports[1]
		actions.append(action)
	_classes["@GlobalScope"] = {"actions": actions}
	return actions


## Shortcuts for the context object: Play Sound for an audio player, Play
## Animation for an AnimationPlayer, Tween Property for anything that moves,
## On Ready for the host.
func _presets(node: Node, cls: String, host: Node, graph: XREBlueprintGraph, dynamic: bool) -> Array[Dictionary]:
	var names: Array[String] = []
	if ClassDB.is_parent_class(cls, "AudioStreamPlayer") or ClassDB.is_parent_class(cls, "AudioStreamPlayer2D") or ClassDB.is_parent_class(cls, "AudioStreamPlayer3D"): names.append("play_sound")
	if ClassDB.is_parent_class(cls, "AnimationPlayer"): names.append("play_animation")
	if ClassDB.is_parent_class(cls, "Node2D") or ClassDB.is_parent_class(cls, "Node3D") or ClassDB.is_parent_class(cls, "Control"): names.append("tween")
	if node != null and node == host: names.append("ready")
	var actions: Array[Dictionary] = []
	for name: String in names:
		var action := _preset_action(name)
		if not action.is_empty(): actions.append(action)
	return _bind(actions, node, dynamic, graph)


## The action of preset [param name] ([constant XREBlueprintGraph.PRESETS]).
static func _preset_action(name: String) -> Dictionary:
	var block := XREBlueprintGraph.make_node(0, name, Vector2.ZERO)
	if block.is_empty(): return {}
	var preset: Dictionary = XREBlueprintGraph.PRESETS[name]
	var subtitle := "preset of On Signal(ready)" if name == "ready" else "preset of Value" if name == "boolean" \
			else "preset of %s.%s()" % [preset["class"] if not str(preset["class"]).is_empty() else "@GlobalScope", preset["name"]]
	return {"id": "preset:" + name, "title": preset["title"], "subtitle": subtitle, "kind": "event" if name == "ready" else "preset",
			"keywords": "preset " + name, "category": "Presets", "block": block, "target": null, "disabled": ""}


## The operators of menu section [param title] (D-065): Math, Comparison —
## Equal first — or Logic.
func _operator_actions(title: String, graph: XREBlueprintGraph, host: Node) -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	if title == "Comparison":
		actions.append({"id": "native:equals", "title": "Equal", "subtitle": "operator =", "kind": "pure", "keywords": "compare == same",
				"category": title, "block": XREBlueprintGraph.make_node(0, "equals", Vector2.ZERO), "target": null, "disabled": ""})
	for op: String in XREBlueprintOperators.OPERATORS:
		var info: Dictionary = XREBlueprintOperators.OPERATORS[op]
		if XREBlueprintOperators.SECTIONS[info["group"]] != title: continue
		actions.append({"id": "operator:" + op, "title": info["title"], "subtitle": "operator " + str(info["symbol"]), "kind": "pure", "keywords": "operator " + str(info["keywords"]),
				"category": title, "block": XREBlueprintGraph.make_operator(0, op, Vector2.ZERO), "target": null, "disabled": ""})
	return _bind(actions, host, false, graph)


## Break and Make (D-139): untyped, which a wire types — into Break's Target,
## from Make's Result —, then of each built-in compound value and of each
## script class of the project with fields; Make only of what it can build.
func _struct_actions() -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	for kind: String in ["break", "make"]:
		actions.append({"id": "struct:" + kind, "title": kind.capitalize(), "subtitle": "native · by its wire's type", "kind": "pure",
				"keywords": "break split fields components struct" if kind == "break" else "make build construct fields struct",
				"category": "Break & Make", "block": XREBlueprintGraph.make_node(0, kind, Vector2.ZERO), "target": null, "disabled": ""})
	var types: Array = []
	for type: int in XREBlueprintStructs.BUILTIN: types.append([type, ""])
	for entry: Dictionary in ProjectSettings.get_global_class_list():
		if not str(entry.get("path", "")).begins_with("res://addons/"): types.append([TYPE_OBJECT, str(entry["class"])])
	for pair: Array in types:
		var name := type_string(int(pair[0])) if int(pair[0]) != TYPE_OBJECT else str(pair[1])
		for kind: String in ["break", "make"]:
			var struct := XREBlueprintStructs.describe(int(pair[0]), str(pair[1]), kind == "make")
			if struct.is_empty() or (struct["fields"] as Array).is_empty() or (kind == "make" and not XREBlueprintStructs.can_make(int(pair[0]), str(pair[1]))): continue
			var block := XREBlueprintGraph.make_node(0, kind, Vector2.ZERO)
			block["struct"] = struct
			block["hidden"] = XREBlueprintStructs.default_hidden(struct)
			if kind == "make":
				for field: Dictionary in struct["fields"]:
					if int(field["type"]) in XREBlueprintSchema.LITERAL_TYPES: block["params"][field["name"]] = XREBlueprintSchema.default_value(int(field["type"]))
			elif int(pair[0]) in XREBlueprintSchema.LITERAL_TYPES:
				block["params"]["value"] = XREBlueprintSchema.default_value(int(pair[0]))
			actions.append({"id": "struct:%s:%s" % [kind, name], "title": "%s %s" % [kind.capitalize(), name], "subtitle": "native · " + ("fields of " if kind == "break" else "from fields ") + name,
					"kind": "pure", "keywords": "%s %s fields components" % [kind, name.to_lower()], "category": "Break & Make", "block": block, "target": null, "disabled": ""})
	return actions


## Branch, Value, properties and events; with [param one_set] Set Property is
## Set, which writes a variable too, by the wire of its Target (D-102).
func _native_actions(graph: XREBlueprintGraph, host: Node, one_set: bool = false) -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	var natives := [["branch", "Branch", "if condition", "native"], ["value", "Value", "literal constant", "native"],
			["get_property", "Get Property", "read", "pure"], ["set_property", "Set" if one_set else "Set Property", "write property variable" if one_set else "write", "property"],
			["signal", "On Signal", "event", "event"]]
	for entry: Array in natives:
		actions.append({"id": "native:" + entry[0], "title": entry[1], "subtitle": "native · " + entry[2], "kind": entry[3], "keywords": entry[2],
				"category": "Native", "block": XREBlueprintGraph.make_node(0, entry[0], Vector2.ZERO), "target": null, "disabled": ""})
	# What orders a run (D-138): outputs one after another, one output by a value.
	actions.append({"id": "native:sequence", "title": "Sequence", "subtitle": "native · then, then", "kind": "native", "keywords": "sequence order then steps do",
			"category": "Native", "block": XREBlueprintGraph.make_node(0, "sequence", Vector2.ZERO), "target": null, "disabled": ""})
	for on: String in ["int", "string"]:
		actions.append({"id": "native:switch_" + on, "title": "Switch on " + ("Int" if on == "int" else "String"), "subtitle": "native · case by value", "kind": "native",
				"keywords": "switch case select match " + on, "category": "Native", "block": XREBlueprintGraph.make_switch(0, on, Vector2.ZERO), "target": null, "disabled": ""})
	for name: String in ["ready", "boolean", "print", "delay"]:
		var preset := _preset_action(name)
		if not preset.is_empty(): actions.append(preset)
	return _bind(actions, host, false, graph)


## Get and Set of each of the graph's variables; first, if the view adds them
## ([code]new_variables[/code] of [param context]), a new variable of each
## type (D-078). Its only output is its value. From a wire of an input only
## the types the view names in the pin's [code]value_types[/code] are offered
## — an operator's operand takes those it works on (D-080) — else the input's
## own type (D-079): the view wires the new variable there, and another type,
## even one the input could convert, isn't what it holds. An input of any
## value with its types named lists only the variables of those types too.
func _variable_actions(graph: XREBlueprintGraph, host: Node, context: Dictionary) -> Array[Dictionary]:
	var pin: Dictionary = context.get("pin", {})
	# The types a new variable may have, or null for any.
	var wanted: Variant = null
	if not pin.is_empty() and not pin.get("output", true):
		var own := XREBlueprintGraph.variant_type(int(pin["type"]))
		if pin.has("value_types"): wanted = pin["value_types"]
		elif own != TYPE_NIL: wanted = [own]
	var picky := wanted is Array and int(pin["type"]) == XREBlueprintGraph.VALUE
	var actions: Array[Dictionary] = []
	for variable: Dictionary in graph.variables:
		if picky and not XREBlueprintGraph.variable_type(variable) in (wanted as Array): continue
		var type := type_string(XREBlueprintGraph.variable_type(variable))
		var getter := XREBlueprintGraph.make_node(0, "get_variable", Vector2.ZERO)
		getter["params"]["variable"] = variable["name"]
		var setter := XREBlueprintGraph.make_node(0, "set_variable", Vector2.ZERO)
		setter["params"]["variable"] = variable["name"]
		setter["params"]["value"] = variable.get("value", XREBlueprintSchema.default_value(XREBlueprintGraph.variable_type(variable)))
		actions.append({"id": "variable:get:" + variable["name"], "title": "Get " + variable["name"], "subtitle": "variable: " + type, "kind": "variable",
				"keywords": "variable get", "category": "Variables", "block": getter, "target": null, "disabled": ""})
		# One Set (D-102): it writes the variable whose box its Target is wired to.
		if not context.get("one_set", false):
			actions.append({"id": "variable:set:" + variable["name"], "title": "Set " + variable["name"], "subtitle": "variable: " + type, "kind": "variable",
					"keywords": "variable set", "category": "Variables", "block": setter, "target": null, "disabled": ""})
	var result: Array[Dictionary] = []
	for value: Variant in (NEW_VARIABLES if context.get("new_variables", false) else []):
		if wanted is Array and not typeof(value) in (wanted as Array): continue
		var type := type_string(typeof(value))
		result.append({"id": "variable:new:" + type, "title": "New %s variable" % type, "subtitle": "variable: " + type, "kind": "variable",
				"keywords": "variable new add create", "category": "Variables", "block": {}, "variable": value, "target": null,
				"inputs": [], "outputs": [XREBlueprintGraph.port_type(typeof(value))], "disabled": ""})
	result.append_array(_bind(actions, host, false, graph))
	return result
