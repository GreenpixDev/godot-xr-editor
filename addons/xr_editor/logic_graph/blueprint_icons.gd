@tool
class_name XREBlueprintIcons
extends RefCounted
## Groups and icons of the logic graph's blocks as archetypes draw them
## ([constant XREFeatureSettings.NODE_STYLE], D-099). A block with execution
## has a header in its group's color: signals red, Set green, flow grey, every
## other function blue, the graph's own functions teal — their calls, the
## Entry and Return of their bodies (docs/blueprint_functions.md). A pure
## function has none: its card is framed in its result's type color.
## [br][br]
## An icon says what a block does, white on its header's dark circle, or larger in its
## result's color on a pure function. The first found of: its function's
## [code]@bp_icon[/code] (a glyph's name or a res:// image), ours for the
## block or the library's function, its script class's [code]@icon[/code],
## the editor's icon of its engine class (an image on the circle too), its category's glyph. A call with
## none shows ƒ: in the circle with execution, alone on a pure function.
## Glyphs are SVG on a grid of 16 points around the center, with a line of
## 1.5, as the editor's icons are; drawn on rebuilds, never per frame.

## Groups of the archetypes, by [method group_of].
enum Group { EVENT, SET, FUNCTION, FLOW, MINE, PURE }
## Header colors of [enum Group]: a deep red for signals, apart from the coral of delete (D-079).
const HEADS: Array[Color] = [Color("7d2630"), Color("155947"), Color("1f4c80"), Color("3d4450"), Color("1a5c66")]
## Faces of a card with a header, a pure function's and an operator's.
const BODY := Color("161b26")
const PURE_BODY := Color("131925")
const OPERATOR_BODY := Color("1a2133")
## How dark the header's circle under an icon is: black this opaque, so that
## the white glyph stands out of a header lit by the focus too (D-072).
const CIRCLE := 0.32
## A glyph's scale on its grid of 128 pixels: on the header's circle, and
## alone on a pure function, larger, as nothing frames it.
const CIRCLED_SCALE := 7.2
const ALONE_SCALE := 8.5
## Glyphs by name: [code]{S}[/code] stands for a stroke, [code]{F}[/code] for a fill.
const GLYPHS: Dictionary[StringName, String] = {
	&"event": '<path d="M1 -6L-4 1H0L-1 6L4 -1H0Z" {F}/>',
	&"ready": '<circle r="5.5" {S}/><path d="M-1.6 -2.8L2.9 0L-1.6 2.8Z" {F}/>',
	&"set": '<path d="M-4 4L-3 1L3 -5L5 -3L-1 3Z" {S}/>',
	&"get": '<path d="M-6.5 0Q0 -6.5 6.5 0Q0 6.5 -6.5 0Z" {S}/><circle r="2" {F}/>',
	&"flow": '<path d="M-5 0H-1L4 -4M-1 0L4 4" {S}/>',
	&"loop": '<path d="M5 1.5A5.2 5.2 0 1 1 3.6 -3.8" {S}/><path d="M5.6 -6.4V-2.6H1.8" {S}/>',
	&"delay": '<path d="M-4 -5H4M-4 5H4M-3 -5C-3 -1 3 1 3 5M3 -5C3 -1 -3 1 -3 5" {S}/>',
	&"tween": '<path d="M-6 4C-1 4 1 -4 6 -4" {S}/><circle cx="-6" cy="4" r="1.4" {F}/><circle cx="6" cy="-4" r="1.4" {F}/>',
	&"audio": '<path d="M1 3V-5L5 -3" {S}/><circle cx="-1" cy="3" r="2.2" {F}/>',
	&"animation": '<path d="M-3 -4.5L4.5 0L-3 4.5Z" {F}/>',
	&"print": '<path d="M-5.5 -3.5L-2.5 -0.5L-5.5 2.5M-0.5 3.5H5" {S}/>',
	&"emit": '<circle cx="-3.5" r="1.6" {F}/><path d="M-0.5 -3A4 4 0 0 1 -0.5 3M2 -5.5A7 7 0 0 1 2 5.5" {S}/>',
	&"spawn": '<rect x="-6" y="-3.5" width="8.5" height="8.5" rx="1.5" {S}/><path d="M4 -6.5V-1.5M1.5 -4H6.5" {S}/>',
	&"free": '<rect x="-5.5" y="-5.5" width="11" height="11" rx="2" {S}/><path d="M-2.5 -2.5L2.5 2.5M2.5 -2.5L-2.5 2.5" {S}/>',
	&"scene": '<rect x="-4.5" y="-6" width="9" height="12" rx="1" {S}/><circle cx="2" cy="0.5" r="1" {F}/>',
	&"make": '<path d="M-6 -5L-1.5 0L-6 5M-6 0H-1.5" {S}/><circle cx="3" r="2.6" {F}/>',
	&"break": '<circle cx="-3" r="2.6" {F}/><path d="M1.5 0L6 -5M1.5 0L6 5M1.5 0H6" {S}/>',
	&"vector": '<path d="M-5 5L5 -5M0 -5H5V0" {S}/>',
	&"color": '<circle cx="-2.8" cy="-2" r="2.6" fill="#ff6b6b"/><circle cx="2.8" cy="-2" r="2.6" fill="#7be5b3"/><circle cy="2.8" r="2.6" fill="#89adff"/>',
	&"time": '<circle r="5" {S}/><path d="M0 -3V0L2.2 1.4" {S}/>',
	&"swap": '<path d="M-5 -2.5H4.5L2 -5M5 2.5H-4.5L-2 5" {S}/>',
	# An event's policy on its chip (D-106): runs side by side, a new one ignored, the old one restarted (the loop).
	&"parallel": '<path d="M-5 -2.5H4M1.5 -5L4 -2.5L1.5 0M-5 2.5H4M1.5 0L4 2.5L1.5 5" {S}/>',
	&"ignore": '<circle r="5" {S}/><path d="M-3.5 3.5L3.5 -3.5" {S}/>',
	# Branch's tabs (D-106): True's tick, False's cross.
	&"true": '<path d="M-4 0L-1 3L4 -3" {S}/>',
	&"false": '<path d="M-3 -3L3 3M3 -3L-3 3" {S}/>',
	# Get Time's and Random's faces on their rings (D-106), in their own colours: a dial
	# with its quarter ticks and hands, a die with five pips.
	&"dial": '<circle r="6.3" fill="none" stroke="#4fd1d9" stroke-opacity=".5" stroke-width=".4"/><path d="M0 -6.1V-5M6.1 0H5M0 6.1V5M-6.1 0H-5" stroke="#4fd1d9" stroke-width=".55"/><path d="M0 -4.2V0L2.8 1.7" stroke="#eaf8f9" stroke-width=".8" fill="none" stroke-linecap="round"/>',
	&"dice": '<rect x="-5.2" y="-5.2" width="10.4" height="10.4" rx="2.2" fill="none" stroke="#cdeff1" stroke-width=".55"/><g fill="#cdeff1"><circle cx="-2.5" cy="-2.5" r=".85"/><circle cx="2.5" cy="-2.5" r=".85"/><circle r=".85"/><circle cx="-2.5" cy="2.5" r=".85"/><circle cx="2.5" cy="2.5" r=".85"/></g>',
	# A box's drawer of components (D-108): open, shut.
	&"drawer_open": '<path d="M-4 -2L0 2L4 -2" {S}/>',
	&"drawer_shut": '<path d="M-2 -4L2 0L-2 4" {S}/>',
	&"random": '<rect x="-5" y="-5" width="10" height="10" rx="2.5" {S}/><circle cx="-2" cy="-2" r="1" {F}/><circle cx="2" cy="2" r="1" {F}/>',
	# A function's body (docs/blueprint_functions.md): Entry's arrow into it, Return's out of it.
	&"entry": '<path d="M-6 0H3M0 -3.5L3.5 0L0 3.5M6 -5.5V5.5" {S}/>',
	&"return": '<path d="M6 0H-3M0 -3.5L-3.5 0L0 3.5M-6 -5.5V5.5" {S}/>',
	# A call's body waits (docs/blueprint_functions.md): an hourglass on its header.
	&"waits": '<path d="M-4 -5.5H4M-4 5.5H4M-3 -5.5C-3 -1 3 1 3 5.5M3 -5.5C3 -1 -3 1 -3 5.5" {S}/>',
	# Collections (D-143): an array's brackets, a dictionary's braces, and what a method does to one.
	&"list": '<path d="M-3 -6H-5.5V6H-3M3 -6H5.5V6H3" {S}/>',
	&"map": '<path d="M-2.5 -6C-5 -6 -4 -1 -6 0C-4 1 -5 6 -2.5 6M2.5 -6C5 -6 4 -1 6 0C4 1 5 6 2.5 6" {S}/>',
	&"add": '<path d="M0 -5V5M-5 0H5" {S}/>',
	&"contains": '<path d="M5 -4.5H0A4.5 4.5 0 0 0 0 4.5H5M-4.5 0H5" {S}/>',
	&"count": '<path d="M-2 -5.5L-3.5 5.5M2.5 -5.5L1 5.5M-5.5 -2H5.5M-5.5 2H5.5" {S}/>',
	&"sort": '<path d="M-5 -4H5M-5 0H2M-5 4H-1" {S}/>',
}
## Glyphs of the methods of Array and Dictionary (D-143), by method.
const METHODS: Dictionary[String, StringName] = {
	"array_get": &"get", "array_size": &"count", "array_is_empty": &"count", "array_contains": &"contains", "array_find": &"contains",
	"array_pick_random": &"random", "array_set": &"set", "array_append": &"add", "array_insert": &"add", "array_add_unique": &"add",
	"array_remove": &"free", "array_remove_at": &"free", "array_clear": &"free", "array_sort": &"sort", "array_shuffle": &"random",
	"dictionary_get": &"get", "dictionary_has": &"contains", "dictionary_keys": &"list", "dictionary_values": &"list", "dictionary_size": &"count",
	"dictionary_set": &"set", "dictionary_remove": &"free", "dictionary_clear": &"free", "dictionary_merge": &"add",
}
## Glyphs drawn in their own colors, never tinted.
const COLORED: Array[StringName] = [&"color", &"dial", &"dice"]
## Our icons of the library's functions and of engine methods, by
## "Class.name", and of @GlobalScope's, by name.
const FUNCTIONS: Dictionary[String, StringName] = {
	"XREBlueprintLibrary.delay": &"delay",
	"XREBlueprintLibrary.tween_property": &"tween",
	"XREBlueprintLibrary.play_sound": &"audio",
	"XREBlueprintLibrary.play_animation": &"animation",
	"XREBlueprintLibrary.make_vector2": &"make",
	"XREBlueprintLibrary.make_vector3": &"make",
	"XREBlueprintLibrary.make_color": &"color",
	"XREBlueprintLibrary.break_vector2": &"break",
	"XREBlueprintLibrary.break_vector3": &"break",
	"XREBlueprintLibrary.break_color": &"break",
	"XREBlueprintLibrary.get_time": &"time",
	"Node.queue_free": &"free",
	"Node.add_child": &"spawn",
	"Object.emit_signal": &"emit",
	"SceneTree.change_scene_to_file": &"scene",
	"SceneTree.change_scene_to_packed": &"scene",
	"print": &"print",
}
## Glyphs of the library's categories and of @GlobalScope's (after "· ").
const CATEGORIES: Dictionary[String, StringName] = {
	"Flow": &"flow", "Motion": &"tween", "Audio": &"audio", "Animation": &"animation",
	"Vector": &"vector", "Color": &"color", "Time": &"time", "random": &"random",
}
## Glyphs of the native blocks; Value, Equal and the operators have none.
const KINDS: Dictionary[String, StringName] = {
	"signal": &"event", "set_property": &"set", "set_variable": &"set",
	"get_property": &"get", "get_variable": &"get", "branch": &"flow",
	"sequence": &"flow", "switch": &"flow", "break": &"break", "make": &"make",
	"entry": &"entry", "return": &"return",
	"make_array": &"list", "make_dictionary": &"map", "for_each": &"loop", "for_each_pair": &"loop",
}


## The group of [param block], whose ports are [param inputs] and [param
## outputs] ([method XREBlueprintGraph.ports]): with no execution port it is pure.
static func group_of(block: Dictionary, inputs: Array, outputs: Array) -> Group:
	var kind := str(block.get("kind", ""))
	if kind == "signal": return Group.EVENT
	if kind in ["set_property", "set_variable"]: return Group.SET
	# A body's ends keep their header when the function is pure: its switch is there.
	if kind in ["entry", "return"]: return Group.MINE
	var executes := false
	for spec: Array in inputs + outputs:
		if int(spec[1]) == XREBlueprintGraph.EXEC: executes = true
	if not executes: return Group.PURE
	if kind in ["branch", "sequence", "switch", "for_each", "for_each_pair"] or (kind == "call" and _category(block) == "Flow"): return Group.FLOW
	if XREBlueprintUserFunctions.is_call(block): return Group.MINE
	return Group.FUNCTION


## The icon of [param block]'s card, as the class says: a glyph's name
## ([constant GLYPHS]), a texture, or null for none — a call then shows ƒ.
## [param class_icon] gives the editor's icon of an engine class, or null.
static func icon_of(block: Dictionary, class_icon: Callable) -> Variant:
	var kind := str(block.get("kind", ""))
	if kind == "signal":
		return &"ready" if str((block.get("params", {}) as Dictionary).get("signal", "")) == "ready" else &"event"
	if kind == "collection": return METHODS.get(str((block.get("params", {}) as Dictionary).get("method", "")))
	if kind != "call": return KINDS.get(kind)
	var function: Dictionary = block.get("function", {})
	var tagged := str(function.get("icon", ""))
	if GLYPHS.has(StringName(tagged)): return StringName(tagged)
	if tagged.begins_with("res://") and ResourceLoader.exists(tagged): return load(tagged) as Texture2D
	var cls := str(function.get("class", ""))
	var name := str(function.get("name", ""))
	var key := name if function.get("scope") == "global" else "%s.%s" % [cls, name]
	if FUNCTIONS.has(key): return FUNCTIONS[key]
	for entry: Dictionary in ProjectSettings.get_global_class_list():
		if str(entry["class"]) != cls: continue
		var path := str(entry.get("icon", ""))
		if not path.is_empty() and ResourceLoader.exists(path): return load(path) as Texture2D
	if function.get("scope") == "method" and ClassDB.class_exists(cls) and class_icon.is_valid():
		var found: Variant = class_icon.call(StringName(cls))
		if found is Texture2D: return found
	return CATEGORIES.get(_category(block))


## The category of a call's function; @GlobalScope's without its prefix.
static func _category(block: Dictionary) -> String:
	var category := str((block.get("function", {}) as Dictionary).get("category", ""))
	return category.get_slice("· ", 1) if category.begins_with("@GlobalScope") else category


## The header's dark circle, [param size] pixels across: every icon of a
## block with execution stands on it, a glyph or an image (D-099).
static func circle(size: int) -> Texture2D:
	return XRETabIcons.from_svg("bp:circle", '<circle cx="64" cy="64" r="62" fill="#000" fill-opacity="%s"/>' % CIRCLE, size)


## Glyph [param glyph] white, [param size] pixels across: sized for the
## header's circle if [param circled], else larger. Null for an unknown glyph.
static func texture(glyph: StringName, size: int, circled: bool) -> Texture2D:
	if not GLYPHS.has(glyph): return null
	var stroke := 'stroke="#fff" stroke-width="1.5" fill="none" stroke-linecap="round" stroke-linejoin="round"'
	var body := GLYPHS[glyph].replace("{S}", stroke).replace("{F}", 'fill="#fff"')
	var scale := CIRCLED_SCALE if circled else ALONE_SCALE
	return XRETabIcons.from_svg("bp:%s:%s" % [glyph, scale], '<g transform="translate(64 64) scale(%s)">%s</g>' % [scale, body], size)
