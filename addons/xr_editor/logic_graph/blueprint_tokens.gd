@tool
class_name XREBlueprintTokens
extends RefCounted
## Values of a block's parameters as objects of the graph in the headset
## (D-052): a token — a puck in a slot on the card, or a plug in the port — for
## a literal, a member of the target object for a name, a box for a variable.
## Which parameter is set where follows the feature settings
## ([constant XREFeatureSettings.VALUE_INPUT] and the others); this class says
## what each parameter of a block is. Nothing here touches the graph.

## What a token holds, for its icon and its way of input.
const NUMBER := &"number"
const TOGGLE := &"toggle"
const TEXT := &"text"
const COLOR := &"color"
const VECTOR := &"vector"
const CHOICE := &"choice"
## A turn of the wrist this many radians steps a number or a choice once (D-052).
const TURN_STEP := PI / 12.0
## Turning faster than this many radians a second steps ten times as far.
const FAST_TURN := 4.0
## How far the ray moves off a token, at its distance, before the trigger drags it instead of turning it.
const DRAG_DISTANCE := 0.03
## The choices of an event's policy, in the order a turn steps through them.
const POLICIES: Array[String] = ["parallel", "ignore", "restart"]
## A token's height, and its width for its text, in meters.
const HEIGHT := 0.024
const CHARACTER_WIDTH := 0.0082
const MIN_WIDTH := 0.036
## Common properties first among the members a target offers (D-052).
const COMMON_PROPERTIES: Array[String] = ["visible", "position", "rotation", "scale", "modulate", "text", "light_color", "light_energy",
		"color", "albedo_color", "playing", "volume_db", "disabled", "button_pressed", "value"]


## Keys of [param block]'s parameters that are literals on its input ports
## ([method XREBlueprintGraph.ports]): the values a token sets while no wire
## comes in. Not the Target, which is a path.
## An empty socket's key is listed too: its token was taken out (D-054).
static func port_keys(graph: XREBlueprintGraph, block: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	var params: Dictionary = block["params"]
	for key: String in graph.socket_keys(block):
		if params.has(key) and not XREBlueprintGraph.is_literal(params[key]): continue
		keys.append(key)
	return keys


## Keys of [param block]'s settings without a port, in square sockets: an
## event's policy and a call's literal arguments that aren't names of the
## target's members. [param finished] leaves out Play Animation's wait, which
## its Finished output sets.
static func square_keys(block: Dictionary, finished: bool) -> Array[String]:
	var keys: Array[String] = []
	if block["kind"] == "signal":
		keys.append("policy")
	elif block["kind"] == "call":
		var function: Dictionary = block["function"]
		for argument: Dictionary in function["args"]:
			if not argument.get("literal", false) or not str(argument.get("provider", "")).is_empty() or not XREBlueprintFunctions.has_literal(argument): continue
			if argument.get("advanced", false) and not function.get("advanced_shown", false): continue
			if finished and str(argument["key"]) == "wait" and has_finished(block): continue
			keys.append(str(argument["key"]))
	return keys


## The key of the parameter that names a member of [param block]'s target: a
## property, a signal or an animation; empty for none.
static func member_key(block: Dictionary) -> String:
	match block["kind"]:
		"get_property", "set_property": return "property"
		"signal": return "signal"
		"call":
			for argument: Dictionary in (block["function"] as Dictionary)["args"]:
				if not str(argument.get("provider", "")).is_empty(): return str(argument["key"])
	return ""


## Whether Targets [param mode] wires the Target to the scene object (any but Window, D-057).
static func targets_in_scene(mode: StringName) -> bool:
	return mode != XREFeatureSettings.WINDOW


## Whether Targets [param mode] shows the member's name on the card.
static func member_on_card(mode: StringName) -> bool:
	return mode == XREFeatureSettings.ON_NODE


## Whether Targets [param mode] shows the member on a petal on a stem from the object.
static func member_on_stem(mode: StringName) -> bool:
	return mode == XREFeatureSettings.SCENE


## Whether Targets [param mode] plugs an adapter into the Target port (D-059).
static func adapter(mode: StringName) -> bool:
	return mode == XREFeatureSettings.ADAPTER


## What the adapter of [param block] says: its member, else its target's name ("self" for the host).
static func adapter_text(block: Dictionary) -> String:
	var params: Dictionary = block["params"]
	var key := member_key(block)
	var member := str(params.get(key, "")) if not key.is_empty() else ""
	if not key.is_empty(): return member + " ▸" if not member.is_empty() else member_placeholder(block)
	var target := str(params.get("target", "."))
	return ("self" if target in [".", ""] else target.get_file()) + " ▸"


## What an unset member says: "pick a property ▸", "pick a signal ▸"…, for [param block].
static func member_placeholder(block: Dictionary) -> String:
	var kind := member_kind(block)
	return "pick a %s ▸" % str({"audio": "sound"}.get(kind, kind if not kind.is_empty() else "member"))


## What a member key names: "property", "signal" or "animation".
static func member_kind(block: Dictionary) -> String:
	match block["kind"]:
		"get_property", "set_property": return "property"
		"signal": return "signal"
		"call":
			for argument: Dictionary in (block["function"] as Dictionary)["args"]:
				if not str(argument.get("provider", "")).is_empty(): return str(argument["provider"])
	return ""


## Whether [param block] is a call whose wait a Finished output can show
## instead of a flag: a function with a literal wait and one execution output.
static func has_finished(block: Dictionary) -> bool:
	if block.get("kind") != "call": return false
	var function: Dictionary = block["function"]
	if function.get("pure", false): return false
	for argument: Dictionary in function["args"]:
		if str(argument.get("key", "")) == "wait" and argument.get("literal", false) and int(argument["type"]) == TYPE_BOOL: return true
	return false


## The value a socket of [param key] takes back when its token is removed: the block's default.
static func default_value(block: Dictionary, key: String) -> Variant:
	if block["kind"] == "call":
		var function: Dictionary = block["function"]
		for argument: Dictionary in function["args"]:
			if str(argument.get("key", "")) == key: return XREBlueprintFunctions.initial_value(argument)
		return ""
	if block["kind"] == "operator": return XREBlueprintOperators.default_params(XREBlueprintGraph.operator_of(block)).get(key, 0.0)
	var defaults: Dictionary = XREBlueprintGraph.BLOCKS[block["kind"]]["params"]
	return defaults.get(key, "")


## The Variant type a socket of [param key] expects, TYPE_NIL for any value.
static func expected_type(graph: XREBlueprintGraph, block: Dictionary, key: String) -> int:
	if key == "policy": return TYPE_STRING
	match block["kind"]:
		"branch": return TYPE_BOOL
		"operator":
			# Logic takes booleans, order numbers, the others any value (D-065).
			match XREBlueprintOperators.group_of(XREBlueprintGraph.operator_of(block)):
				XREBlueprintOperators.LOGIC: return TYPE_BOOL
				XREBlueprintOperators.ORDER: return TYPE_FLOAT
		"set_property": return int(block.get("property_type", TYPE_NIL))
		"set_variable":
			var variable := graph.find_variable(str((block["params"] as Dictionary).get("variable", "")))
			return XREBlueprintGraph.variable_type(variable) if not variable.is_empty() else TYPE_NIL
		"call":
			for argument: Dictionary in (block["function"] as Dictionary)["args"]:
				if str(argument.get("key", "")) != key: continue
				if not str(argument.get("type_of", "")).is_empty() and block.has("property_type"): return int(block["property_type"])
				var type := int(argument["type"])
				return TYPE_STRING if type in [TYPE_STRING_NAME, TYPE_NODE_PATH] else type
	return TYPE_NIL


## Whether [param value] may go into the socket of [param key]: a value its type accepts, a policy for a policy.
static func accepts(graph: XREBlueprintGraph, block: Dictionary, key: String, value: Variant) -> bool:
	if not XREBlueprintGraph.is_literal(value): return false
	if key == "policy": return value is String and value in POLICIES
	if block["kind"] == "signal": return false
	return XREBlueprintSchema.accepts(expected_type(graph, block, key), typeof(value))


## How a token of [param value] in a socket of [param key] is edited.
static func kind_of(value: Variant, key: String) -> StringName:
	if key == "policy": return CHOICE
	match typeof(value):
		TYPE_BOOL: return TOGGLE
		TYPE_INT, TYPE_FLOAT: return NUMBER
		TYPE_COLOR: return COLOR
		TYPE_VECTOR2, TYPE_VECTOR3: return VECTOR
	return TEXT


## A line of help on how a token of [param kind] is edited, shown over it under the ray (D-055).
static func hint(kind: StringName) -> String:
	match kind:
		NUMBER: return "hold trigger: number line, move the ray ← →  ·  click: type"
		CHOICE: return "hold trigger: point at a value  ·  click: next"
		TOGGLE: return "click: switch"
		COLOR: return "click: Color window"
		VECTOR: return "click: axis arrows"
	return "click: keyboard"


## A number typed on the keypad (D-062, D-063): digits, a sign, a point, π
## (pi), e, × (*), /, + and −, ^ for a power, √ for a root and brackets; a
## number before π, e, √ or a bracket multiplies it, so that 3π, π/2, 1/2π,
## 2e, −π, 2^3, √2 and 2√(1+π) read as they are written. A bracket left open
## closes at the end. Null for anything else.
static func parse_number(text: String) -> Variant:
	var clean := text.strip_edges().to_lower().replace(" ", "")
	if clean.is_empty(): return null
	# Godot reads "2e" as 2: e here is the constant, not an exponent.
	if clean.is_valid_float() and not "e" in clean: return clean.to_float()
	clean = clean.replace("π", "pi").replace("×", "*").replace("−", "-").replace("·", "*").replace("^", "**")
	for character: String in clean:
		if not character in "0123456789.+-*/()pie√": return null
	var open := clean.count("(") - clean.count(")")
	if open < 0: return null
	clean += ")".repeat(open)
	# √ takes the number, π or e after it, or a bracket: √2, √π, √(1+π).
	clean = RegEx.create_from_string("√(\\d+\\.?\\d*|pi|e)").sub(clean, "√($1)", true)
	if clean.replace("√(", "").contains("√"): return null
	clean = clean.replace("√(", "q(")
	var pattern := RegEx.create_from_string("(\\d|\\)|pi|e)(?=(pi|e|\\(|q))|(pi|e|\\))(?=\\d)")
	var spaced := clean
	# A number, π, e or a closing bracket followed by π, e, √ or a bracket multiplies.
	var guard := 0
	while guard < 32:
		var found := pattern.search(spaced)
		if found == null: break
		var cut := found.get_end()
		spaced = spaced.substr(0, cut) + "*" + spaced.substr(cut)
		guard += 1
	# Whole numbers as reals, so that 1/2 is a half and not 0.
	spaced = RegEx.create_from_string("(?<![\\d.])(\\d+)(?![\\d.])").sub(spaced, "$1.0", true)
	spaced = spaced.replace("pi", "PI").replace("e", "(%s)" % str(exp(1.0))).replace("q(", "sqrt(")
	var expression := Expression.new()
	if expression.parse(spaced) != OK: return null
	var result: Variant = expression.execute([], null, false)
	if expression.has_execute_failed() or not (result is float or result is int) or not is_finite(float(result)): return null
	return float(result)


## Whether [param text] typed for a number or a vector is more than plain
## numbers (D-063): an expression such as π/2, kept to be shown as typed.
static func is_expression(text: String) -> bool:
	for part: String in text.split(",", false):
		var clean := part.strip_edges()
		if not (clean.is_valid_float() and not "e" in clean.to_lower()): return true
	return false


## Whether [param text] — an expression, components apart by commas for a
## vector — still gives [param value].
static func expression_gives(text: String, value: Variant) -> bool:
	var parts := text.split(",", false)
	match typeof(value):
		TYPE_INT, TYPE_FLOAT:
			var number: Variant = parse_number(text)
			return parts.size() == 1 and number != null and is_equal_approx(float(number), float(value))
		TYPE_VECTOR2, TYPE_VECTOR3:
			var count := 2 if value is Vector2 else 3
			if parts.size() != count: return false
			for axis: int in count:
				var number: Variant = parse_number(parts[axis])
				if number == null or not is_equal_approx(float(number), float(value[axis])): return false
			return true
	return false


## The expression kept for the value of [param key] on [param block] (D-063)
## while it still gives that value, or empty: a value set any other way drops it.
static func expression_of(block: Dictionary, key: String) -> String:
	var kept: Variant = block.get("expressions")
	if not kept is Dictionary or not (kept as Dictionary).has(key): return ""
	var text := str((kept as Dictionary)[key])
	return text if expression_gives(text, (block.get("params", {}) as Dictionary).get(key)) else ""


## The expression kept for the start value of [param variable], as [method expression_of].
static func variable_expression(variable: Dictionary) -> String:
	var text := str(variable.get("expression", ""))
	return text if not text.is_empty() and expression_gives(text, variable.get("value")) else ""


## Component [param axis] of a vector's expression [param text], or empty.
static func component_expression(text: String, axis: int) -> String:
	var parts := text.split(",", false)
	return parts[axis].strip_edges() if axis < parts.size() else ""


## A component of an expression as a token shows it: an expression as typed,
## a plain number as [method text] writes it (1, not 1.0).
static func component_shown(part: String) -> String:
	var clean := part.strip_edges()
	return _number(clean.to_float()) if clean.is_valid_float() and not "e" in clean.to_lower() else clean


## [param value] written for an expression: exact enough to give it back, without trailing zeros.
static func plain(value: float) -> String:
	var written := String.num(value, 6)
	return written.trim_suffix(".0") if written.ends_with(".0") else written


## What a token of [param value] for [param key] shows: its [param expression]
## as typed when there is one (D-063), its unit after it; else [method text].
static func shown(value: Variant, key: String, expression: String) -> String:
	if expression.is_empty(): return text(value, key)
	if value is Vector2 or value is Vector3:
		var parts: PackedStringArray = []
		for part: String in expression.split(",", false): parts.append(component_shown(part))
		return "(%s)" % ", ".join(parts)
	return expression.strip_edges() + (" s" if key in ["seconds", "timeout"] else "")


## The text on a token: a number with its unit for a duration, a quoted text, a color's hex.
static func text(value: Variant, key: String) -> String:
	match typeof(value):
		TYPE_BOOL: return "true" if value else "false"
		TYPE_INT: return str(value)
		TYPE_FLOAT:
			var number := _number(value)
			return number + " s" if key in ["seconds", "timeout"] else number
		TYPE_STRING:
			if key == "policy": return str(value)
			var shown := str(value)
			return "\"%s\"" % (shown if shown.length() <= 12 else shown.left(11) + "…")
		TYPE_VECTOR2:
			var vector := value as Vector2
			return "(%s, %s)" % [_number(vector.x), _number(vector.y)]
		TYPE_VECTOR3:
			var vector := value as Vector3
			return "(%s, %s, %s)" % [_number(vector.x), _number(vector.y), _number(vector.z)]
		TYPE_COLOR: return "#" + (value as Color).to_html(false)
	return str(value)


## A number with at most two decimals, without trailing zeros.
static func _number(value: float) -> String:
	# As many decimals as six figures need, at most six (D-071): 1.503, 0.000025, 0.33333.
	var decimals := 2
	if absf(value) > 0.0: decimals = clampi(5 - floori(log(absf(value)) / log(10.0)), 0, 6)
	var shown := String.num(value, decimals)
	shown = shown.rstrip("0").rstrip(".") if shown.contains(".") else shown
	return shown if shown != "-0" else "0"


## How wide a token showing [param shown] is, in meters.
static func width(shown: String) -> float:
	return MIN_WIDTH + shown.length() * CHARACTER_WIDTH


## The port color category of a token's value, for its border.
static func color_type(value: Variant, key: String) -> int:
	if key == "policy": return XREBlueprintGraph.VALUE
	return XREBlueprintGraph.port_type(typeof(value))


## How far one step of a turn changes [param value]: a unit of its last shown
## decimal, so that 1.5 steps by 0.1 and 30 by 1; ten times that with [param fast].
static func step(value: Variant, fast: bool) -> float:
	var unit := 1.0
	if value is float:
		var shown := _number(value)
		var decimals := shown.length() - shown.find(".") - 1 if shown.contains(".") else 0
		unit = pow(10.0, -maxi(decimals, 1)) if decimals > 0 or absf(value) < 10.0 else 1.0
	return unit * (10.0 if fast else 1.0)


## [param value] turned [param steps] steps: a number by its step, a policy to
## the next choice, a toggle flipped by an odd count. Others don't turn.
static func turned(value: Variant, key: String, steps: int, fast: bool) -> Variant:
	if steps == 0: return value
	if key == "policy":
		var index := POLICIES.find(str(value))
		return POLICIES[posmod(index + steps, POLICIES.size())]
	match typeof(value):
		TYPE_INT: return int(value) + steps * (10 if fast else 1)
		TYPE_FLOAT: return snappedf(float(value) + steps * step(value, fast), step(value, false))
		TYPE_BOOL: return not value if steps % 2 != 0 else value
	return value


## Whether a socket of [param key] with value [param value] keeps a value
## that a positive duration must have: turning stops above zero.
static func positive(block: Dictionary, key: String) -> bool:
	return _argument_flag(block, key, "positive")


## The least value a number [param value] of [param key] on [param block] may
## be turned to (D-063): its smallest step above zero for a positive one, zero
## for a non-negative one (a Delay of 0 s waits a frame), NAN for any value.
static func minimum(block: Dictionary, key: String, value: Variant) -> float:
	if _argument_flag(block, key, "positive"): return 1.0 if value is int else 0.1
	if _argument_flag(block, key, "non_negative"): return 0.0
	return NAN


static func _argument_flag(block: Dictionary, key: String, flag: String) -> bool:
	if block.is_empty() or block["kind"] != "call": return false
	for argument: Dictionary in (block["function"] as Dictionary)["args"]:
		if str(argument.get("key", "")) == key: return argument.get(flag, false)
	return false


## Properties of [param target] a member wire of [param block] may pick: for
## Set Property and Tween writable ones (Tween: of a type it interpolates), for
## Get Property readable ones; common ones first.
static func properties_for(block: Dictionary, target: Object) -> Array[String]:
	var names: Array[String] = []
	var tween: bool = block["kind"] == "call" and (block["function"] as Dictionary).get("name") == "tween_property"
	for info: Dictionary in XREBlueprintSchema.properties(target):
		if block["kind"] == "set_property" or tween:
			if int(info["usage"]) & PROPERTY_USAGE_READ_ONLY: continue
		if tween and not int(info["type"]) in XREBlueprintSchema.TWEENABLE_TYPES: continue
		names.append(str(info["name"]))
	names.sort_custom(func(first: String, second: String) -> bool:
		var a := COMMON_PROPERTIES.find(first)
		var b := COMMON_PROPERTIES.find(second)
		if a >= 0 and b >= 0: return a < b
		if a >= 0 or b >= 0: return a >= 0
		return first < second)
	return names
