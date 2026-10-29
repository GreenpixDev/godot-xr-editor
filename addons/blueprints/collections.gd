@tool
class_name XREBlueprintCollections
extends RefCounted
## Arrays and dictionaries of the graph (D-141). A port of a collection is a
## category of its own ([constant XREBlueprintGraph.ARRAY] plus its element's,
## [constant XREBlueprintGraph.DICTIONARY] plus its key's and value's): its
## colour is its element's, as in Unreal. An untyped one has elements of any
## value ([constant XREBlueprintGraph.VALUE]). Collections don't nest:
## Godot 4.7 has no Array[Array[int]].
##
## The blocks that work on a collection are a table of the methods of Array and
## Dictionary ([constant METHODS]), not calls: reflection doesn't list the
## methods of built-in types, and the compiler writes [code]items.append(x)[/code]
## instead of a call of the library. A method block's ports follow the
## collection wired into it.

## How many element types a dictionary's category keeps apart: its value is the low part.
const SPAN := 32

## A method of Array or Dictionary as a block (D-141): its title, what it works
## on, whether it is pure, its arguments as [label, role, parameter], its result
## as [label, role] or empty, the GDScript of it with [code]{items}[/code] for
## the collection and [code]{0}[/code]… for the arguments, and search words.
## A role says a port's type: "element", "key" and "value" of the collection,
## "keys" and "values" — arrays of them —, "collection" — of its type —, "int" and "bool".
## An argument whose role is in [code]optional[/code] may stay empty.
const METHODS: Dictionary[String, Dictionary] = {
	"array_get": {"title": "Get", "on": "array", "pure": true, "args": [["Index", "int", "index"]], "result": ["Element", "element"],
			"code": "_bp_at({items}, {0}, run, {id})", "keywords": "item element at index read"},
	"array_size": {"title": "Size", "on": "array", "pure": true, "args": [], "result": ["Size", "int"], "code": "{items}.size()", "keywords": "count length how many"},
	"array_is_empty": {"title": "Is Empty", "on": "array", "pure": true, "args": [], "result": ["Empty", "bool"], "code": "{items}.is_empty()", "keywords": "none no items"},
	"array_contains": {"title": "Contains", "on": "array", "pure": true, "args": [["Value", "element", "value"]], "result": ["Result", "bool"],
			"code": "{items}.has({0})", "keywords": "has includes find in set"},
	"array_find": {"title": "Find", "on": "array", "pure": true, "args": [["Value", "element", "value"]], "result": ["Index", "int"],
			"code": "{items}.find({0})", "keywords": "index of search position"},
	"array_pick_random": {"title": "Pick Random", "on": "array", "pure": true, "args": [], "result": ["Element", "element"],
			"code": "_bp_pick({items}, run, {id})", "keywords": "random any choose"},
	"array_set": {"title": "Set Element", "on": "array", "pure": false, "args": [["Index", "int", "index"], ["Value", "element", "value"]], "result": [],
			"code": "_bp_set_at({items}, {0}, {1}, run, {id})", "keywords": "item element at index write replace"},
	"array_append": {"title": "Append", "on": "array", "pure": false, "args": [["Value", "element", "value"]], "result": [],
			"code": "{items}.append({0})", "keywords": "add push back end item element"},
	"array_insert": {"title": "Insert", "on": "array", "pure": false, "args": [["Index", "int", "index"], ["Value", "element", "value"]], "result": [],
			"code": "_bp_insert({items}, {0}, {1}, run, {id})", "keywords": "add at index item element"},
	"array_add_unique": {"title": "Add Unique", "on": "array", "pure": false, "args": [["Value", "element", "value"]], "result": [],
			"code": "if not {items}.has({0}):\n\t{items}.append({0})", "keywords": "add set no repeat distinct"},
	"array_remove": {"title": "Remove", "on": "array", "pure": false, "args": [["Value", "element", "value"]], "result": [],
			"code": "{items}.erase({0})", "keywords": "erase delete item element set"},
	"array_remove_at": {"title": "Remove At", "on": "array", "pure": false, "args": [["Index", "int", "index"]], "result": [],
			"code": "_bp_remove_at({items}, {0}, run, {id})", "keywords": "erase delete index"},
	"array_clear": {"title": "Clear", "on": "array", "pure": false, "args": [], "result": [], "code": "{items}.clear()", "keywords": "empty erase all"},
	"array_sort": {"title": "Sort", "on": "array", "pure": false, "args": [], "result": [], "code": "{items}.sort()", "keywords": "order ascending"},
	"array_shuffle": {"title": "Shuffle", "on": "array", "pure": false, "args": [], "result": [], "code": "{items}.shuffle()", "keywords": "random order mix"},
	"dictionary_get": {"title": "Get", "on": "dictionary", "pure": true, "args": [["Key", "key", "key"], ["Default", "value", "default"]], "result": ["Value", "value"],
			"optional": ["default"], "code": "{items}.get({0}, {1})", "strict": "_bp_get({items}, {0}, run, {id})", "keywords": "value of key read lookup"},
	"dictionary_has": {"title": "Has", "on": "dictionary", "pure": true, "args": [["Key", "key", "key"]], "result": ["Result", "bool"],
			"code": "{items}.has({0})", "keywords": "contains key in set"},
	"dictionary_keys": {"title": "Keys", "on": "dictionary", "pure": true, "args": [], "result": ["Keys", "keys"], "code": "_bp_keys({items})", "keywords": "all keys list"},
	"dictionary_values": {"title": "Values", "on": "dictionary", "pure": true, "args": [], "result": ["Values", "values"], "code": "_bp_values({items})", "keywords": "all values list"},
	"dictionary_size": {"title": "Size", "on": "dictionary", "pure": true, "args": [], "result": ["Size", "int"], "code": "{items}.size()", "keywords": "count length how many"},
	"dictionary_set": {"title": "Set", "on": "dictionary", "pure": false, "args": [["Key", "key", "key"], ["Value", "value", "value"]], "result": [],
			"code": "{items}[{0}] = {1}", "keywords": "put write value of key"},
	"dictionary_remove": {"title": "Remove", "on": "dictionary", "pure": false, "args": [["Key", "key", "key"]], "result": [],
			"code": "{items}.erase({0})", "keywords": "erase delete key"},
	"dictionary_clear": {"title": "Clear", "on": "dictionary", "pure": false, "args": [], "result": [], "code": "{items}.clear()", "keywords": "empty erase all"},
	"dictionary_merge": {"title": "Merge", "on": "dictionary", "pure": false, "args": [["Other", "collection", "other"]], "result": [],
			"code": "{items}.merge({0}, true)", "keywords": "add all combine update"},
}


## The category of an array of [param element]'s, of any value for VALUE.
static func array_of(element: int) -> int:
	return XREBlueprintGraph.ARRAY + element


## The category of a dictionary of [param key]'s to [param value]'s.
static func dictionary_of(key: int, value: int) -> int:
	return XREBlueprintGraph.DICTIONARY + key * SPAN + value


static func is_array(category: int) -> bool:
	return category >= XREBlueprintGraph.ARRAY and category < XREBlueprintGraph.ARRAY + SPAN


static func is_dictionary(category: int) -> bool:
	return category >= XREBlueprintGraph.DICTIONARY and category < XREBlueprintGraph.DICTIONARY + SPAN * SPAN


static func is_collection(category: int) -> bool:
	return is_array(category) or is_dictionary(category)


## The category of an array's elements or of a dictionary's values; the category itself for anything else.
static func element_of(category: int) -> int:
	if is_array(category): return category - XREBlueprintGraph.ARRAY
	if is_dictionary(category): return (category - XREBlueprintGraph.DICTIONARY) % SPAN
	return category


## The category of a dictionary's keys, VALUE for anything else.
static func key_of(category: int) -> int:
	return (category - XREBlueprintGraph.DICTIONARY) / SPAN if is_dictionary(category) else XREBlueprintGraph.VALUE


## Whether [param category] is untyped: an array of any value, a dictionary of any keys and values.
static func is_untyped(category: int) -> bool:
	return category in [array_of(XREBlueprintGraph.VALUE), dictionary_of(XREBlueprintGraph.VALUE, XREBlueprintGraph.VALUE)]


## The port category of [param value]: a typed collection's with its element's.
static func category_of(value: Variant) -> int:
	if value is Array:
		var array := value as Array
		return array_of(_element_category(array.get_typed_builtin()))
	if value is Dictionary:
		var dictionary := value as Dictionary
		return dictionary_of(_element_category(dictionary.get_typed_key_builtin()), _element_category(dictionary.get_typed_value_builtin()))
	return XREBlueprintGraph.port_type(typeof(value))


static func _element_category(type: int) -> int:
	return XREBlueprintGraph.VALUE if type == TYPE_NIL else XREBlueprintGraph.port_type(type)


## How GDScript names the type of [param category]: [code]Array[int][/code],
## [code]Dictionary[String, Color][/code], [code]float[/code]; an untyped part is Variant.
static func hint(category: int) -> String:
	if is_array(category):
		var element := element_of(category)
		return "Array" if element == XREBlueprintGraph.VALUE else "Array[%s]" % hint(element)
	if is_dictionary(category):
		if is_untyped(category): return "Dictionary"
		return "Dictionary[%s, %s]" % [hint(key_of(category)), hint(element_of(category))]
	if category == XREBlueprintGraph.EXEC: return "Execution"
	return XREBlueprintSchema.type_name(XREBlueprintGraph.variant_type(category))


## An empty collection of [param category], typed as it is.
static func empty(category: int) -> Variant:
	return typed([] if is_array(category) else {}, category)


## [param value], an array or a dictionary, as one of [param category] — the
## same one when its type is that already —, or null when an element can't be
## of it: a nested collection, a value of another type.
static func typed(value: Variant, category: int) -> Variant:
	if is_array(category) and value is Array:
		var type := XREBlueprintGraph.variant_type(element_of(category))
		for item: Variant in value as Array:
			if not _fits(item, element_of(category)): return null
		if category_of(value) == category: return value
		var converted: Array = []
		for item: Variant in value as Array: converted.append(float(item) if type == TYPE_FLOAT and item is int else item)
		return Array(converted, type, &"Object" if type == TYPE_OBJECT else &"", null)
	if is_dictionary(category) and value is Dictionary:
		var source := value as Dictionary
		for key: Variant in source:
			if not _fits(key, key_of(category)) or not _fits(source[key], element_of(category)): return null
		if category_of(value) == category: return value
		var key_type := XREBlueprintGraph.variant_type(key_of(category))
		var value_type := XREBlueprintGraph.variant_type(element_of(category))
		var converted := {}
		for key: Variant in source:
			converted[float(key) if key_type == TYPE_FLOAT and key is int else key] = float(source[key]) if value_type == TYPE_FLOAT and source[key] is int else source[key]
		return Dictionary(converted, key_type, &"Object" if key_type == TYPE_OBJECT else &"", null, value_type, &"Object" if value_type == TYPE_OBJECT else &"", null)
	return null


## Whether [param item] may be an element of category [param element]: of its
## type, an integer for a number, anything but a collection for any value.
static func _fits(item: Variant, element: int) -> bool:
	if item is Array or item is Dictionary: return false
	if element == XREBlueprintGraph.VALUE: return true
	return XREBlueprintGraph.ports_compatible(XREBlueprintGraph.port_type(typeof(item)), element)


## A collection's start value as a variable keeps it (D-141): typed, its
## elements literals — no objects, which only a wire brings.
static func is_value(value: Variant) -> bool:
	if not (value is Array or value is Dictionary): return false
	var category := category_of(value)
	if element_of(category) == XREBlueprintGraph.VALUE: return false
	if is_dictionary(category) and key_of(category) == XREBlueprintGraph.VALUE: return false
	var items: Array = []
	if value is Array: items = value as Array
	else: items = (value as Dictionary).keys() + (value as Dictionary).values()
	for item: Variant in items:
		if not XREBlueprintGraph.is_literal(item): return false
	return true


## Text the 2D editor shows a collection in and reads back ([method parse]): [1, 2, 5].
static func text_of(value: Variant) -> String:
	var text := var_to_str(value)
	# A typed one is written Array[int]([1, 2]): the list alone.
	var open := text.find("(")
	if open > 0 and text.ends_with(")"): text = text.substr(open + 1, text.length() - open - 2)
	return text.replace("\n", " ")


## [param text] — [code][1, 2][/code], [code]{"open": 1}[/code] — as a
## collection of [param category]; null when it isn't one.
static func parse(text: String, category: int) -> Variant:
	var parsed: Variant = str_to_var(text.strip_edges())
	if not (parsed is Array or parsed is Dictionary): return null
	var value: Variant = typed(parsed, category)
	return value if value != null and is_value(value) else null


## [param text] as a collection of [param category], or of the type its
## elements share when [param category] is untyped (D-143): [1, 2.5] is
## Array[float]; null when it isn't a list, or its elements differ.
static func parse_any(text: String, category: int) -> Variant:
	if not is_untyped(category): return parse(text, category)
	var parsed: Variant = str_to_var(text.strip_edges())
	if parsed is Array:
		var element := _common(parsed as Array)
		return parse(text, array_of(element)) if element >= 0 else null
	if parsed is Dictionary:
		var key := _common((parsed as Dictionary).keys())
		var value := _common((parsed as Dictionary).values())
		return parse(text, dictionary_of(key, value)) if key >= 0 and value >= 0 else null
	return null


## The category [param items] share: an integer beside a number is a number;
## -1 when they differ or there are none, an int for none.
static func _common(items: Array) -> int:
	if items.is_empty(): return XREBlueprintGraph.INTEGER
	var found := -1
	for item: Variant in items:
		var category := XREBlueprintGraph.port_type(typeof(item))
		if found < 0 or found == category: found = category
		elif [found, category].has(XREBlueprintGraph.INTEGER) and [found, category].has(XREBlueprintGraph.NUMBER): found = XREBlueprintGraph.NUMBER
		else: return -1
	return found


## [param value], a collection of [param category] or null for none yet, with
## one more element (D-143): a copy of the last, else its type's default — an
## int for any —; a dictionary's new key one no pair has.
static func appended(value: Variant, category: int) -> Variant:
	if is_untyped(category): category = array_of(XREBlueprintGraph.INTEGER) if is_array(category) else dictionary_of(XREBlueprintGraph.TEXT, XREBlueprintGraph.INTEGER)
	var result: Variant = empty(category)
	if value is Array: result = (value as Array).duplicate()
	elif value is Dictionary: result = (value as Dictionary).duplicate()
	var element_type := XREBlueprintGraph.variant_type(element_of(category))
	var fresh: Variant = XREBlueprintSchema.default_value(element_type) if element_type in XREBlueprintSchema.LITERAL_TYPES else 0
	if result is Array:
		var items := result as Array
		items.append(items.back() if not items.is_empty() else fresh)
		return items
	var pairs := result as Dictionary
	var key_type := XREBlueprintGraph.variant_type(key_of(category))
	var key: Variant = "key_%d" % pairs.size()
	if key_type == TYPE_INT: key = pairs.size()
	while pairs.has(key): key = (int(key) + 1) if key is int else "%s_" % key
	pairs[key] = pairs.values().back() if not pairs.is_empty() else fresh
	return pairs


## The categories a collection's elements, keys and values may have: those a literal has, and an object.
static func element_categories() -> Array[int]:
	var result: Array[int] = []
	for type: int in XREBlueprintSchema.LITERAL_TYPES: result.append(XREBlueprintGraph.port_type(type))
	result.append(XREBlueprintGraph.OBJECT)
	return result


## The port category of role [param role] ([constant METHODS]) of a block on a collection of [param category].
static func role_category(role: String, category: int) -> int:
	match role:
		"element", "value": return element_of(category)
		"key": return key_of(category)
		"keys": return array_of(key_of(category))
		"values": return array_of(element_of(category))
		"collection": return category
		"int": return XREBlueprintGraph.INTEGER
		"bool": return XREBlueprintGraph.BOOLEAN
	return XREBlueprintGraph.VALUE


## The literal a new argument of role [param role] starts with on a collection
## of [param category]; null for one only a wire brings (an object, a collection).
static func initial_value(role: String, category: int) -> Variant:
	var type := XREBlueprintGraph.variant_type(role_category(role, category))
	if role in ["keys", "values", "collection"] or type == TYPE_OBJECT: return null
	if type == TYPE_NIL: return 0 if role != "key" else ""
	return XREBlueprintSchema.default_value(type)


## The parameters a new block of method [param method] starts with: its method and its arguments' literals.
static func default_params(method: String) -> Dictionary:
	var info: Dictionary = METHODS[method]
	var params := {"method": method}
	var untyped := array_of(XREBlueprintGraph.VALUE) if info["on"] == "array" else dictionary_of(XREBlueprintGraph.VALUE, XREBlueprintGraph.VALUE)
	for argument: Array in info["args"]:
		var key := str(argument[2])
		var value: Variant = initial_value(str(argument[1]), untyped)
		if key.is_empty() or value == null or key in info.get("optional", []): continue
		params[key] = value
	return params
