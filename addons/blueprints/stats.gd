@tool
class_name XREBlueprintStats
extends RefCounted
## How often each kind of block, and each wire from one kind to another,
## comes in the project's graphs (D-093): what the block menu offers first,
## as tiles, on a ring or as suggestions at a wire's end. Counted when a menu
## opens, never per frame: a graph file is read again only when it changed.
## Graphs under [constant SKIPPED] are not counted: the addons' own, and the
## study's, whose participants would steer what the next one is offered.
##
## A block's key ([method key_of]) is what makes two blocks the same kind for
## the menu: the operator, the function, the property, the signal — not the
## variable, so that Get of one variable counts for Get of another.

## Folders that are not walked.
const SKIPPED: Array[String] = ["res://addons", "res://study", "res://.godot"]
## How long the files found are trusted before the folders are walked again.
const WALK_INTERVAL_MSEC := 2000

static var _shared: XREBlueprintStats

## Blocks by key, and wires by [method pair_key].
var kinds: Dictionary[String, int] = {}
var pairs: Dictionary[String, int] = {}
## The counts of each graph file: [code]{"time", "kinds", "pairs"}[/code].
var _files: Dictionary[String, Dictionary] = {}
## When the folders were last walked, or -1.
var _walked_at := -1


## One count for every menu of the editor.
static func shared() -> XREBlueprintStats:
	if _shared == null:
		_shared = XREBlueprintStats.new()
	return _shared


## What makes [param block] the same kind as another for the menu: Multiply is
## "operator:multiply", Sin "call:sin", Set Position "set_property:position",
## On Ready "signal:ready", Get Variable of any variable "get_variable".
## Empty for no block.
static func key_of(block: Dictionary) -> String:
	var kind := str(block.get("kind", ""))
	var params: Dictionary = block.get("params", {})
	match kind:
		"":
			return ""
		"call":
			return "call:" + str((block.get("function", {}) as Dictionary).get("name", ""))
		"operator":
			return "operator:" + str(params.get("op", ""))
		"signal":
			return "signal:" + str(params.get("signal", ""))
		"get_property", "set_property":
			return kind + ":" + str(params.get("property", ""))
	return kind


## The key of a wire from a block of key [param from] into one of key [param to].
static func pair_key(from: String, to: String) -> String:
	return from + ">" + to


## How many blocks of key [param key] there are.
func kind_count(key: String) -> int:
	return kinds.get(key, 0)


## How many wires go from a block of key [param from] into one of key [param to].
func pair_count(from: String, to: String) -> int:
	return pairs.get(pair_key(from, to), 0)


## Counts the graphs of the project again, those that changed since, and
## [param current], the graph being edited, as it is now rather than as saved.
func update(current: XREBlueprintGraph = null) -> void:
	# A wire let go and its menu opened again soon after: the files are as they were.
	if _walked_at < 0 or Time.get_ticks_msec() - _walked_at > WALK_INTERVAL_MSEC:
		_walked_at = Time.get_ticks_msec()
		var seen: Dictionary[String, bool] = {}
		_walk("res://", seen)
		for path: String in _files.keys():
			if not seen.has(path): _files.erase(path)
	kinds.clear()
	pairs.clear()
	var skip := current.resource_path if current != null else ""
	for path: String in _files:
		if path != skip: _add(_files[path])
	if current != null: _add(count(current))


## Adds [param graph]'s blocks and wires to the counts, for a count without files.
func add_graph(graph: XREBlueprintGraph) -> void:
	_add(count(graph))


## The blocks and wires of [param graph]: [code]{"kinds", "pairs"}[/code], by key.
static func count(graph: XREBlueprintGraph) -> Dictionary:
	var found: Dictionary[String, int] = {}
	var wires: Dictionary[String, int] = {}
	var keys: Dictionary[int, String] = {}
	for block: Dictionary in graph.nodes:
		var key := key_of(block)
		keys[int(block.get("id", -1))] = key
		if not key.is_empty(): found[key] = found.get(key, 0) + 1
	for edge: Dictionary in graph.edges:
		var from: String = keys.get(int(edge.get("from", -1)), "")
		var to: String = keys.get(int(edge.get("to", -1)), "")
		if from.is_empty() or to.is_empty(): continue
		var key := pair_key(from, to)
		wires[key] = wires.get(key, 0) + 1
	return {"kinds": found, "pairs": wires}


func _add(counted: Dictionary) -> void:
	var found: Dictionary = counted["kinds"]
	for key: String in found: kinds[key] = kinds.get(key, 0) + int(found[key])
	var wires: Dictionary = counted["pairs"]
	for key: String in wires: pairs[key] = pairs.get(key, 0) + int(wires[key])


## Finds the graph files under [param folder], recounting those that changed.
func _walk(folder: String, seen: Dictionary[String, bool]) -> void:
	var dir := DirAccess.open(folder)
	if dir == null: return
	for name: String in dir.get_directories():
		var path := folder.path_join(name)
		if name.begins_with(".") or path in SKIPPED: continue
		_walk(path, seen)
	for name: String in dir.get_files():
		if name.get_extension() != "tres": continue
		var path := folder.path_join(name)
		var time := FileAccess.get_modified_time(path)
		seen[path] = true
		if _files.has(path) and _files[path]["time"] == time: continue
		_files[path] = _read(path, time)


## The counts of the graph file at [param path], empty ones for another resource.
static func _read(path: String, time: int) -> Dictionary:
	var empty := {"time": time, "kinds": {}, "pairs": {}}
	var file := FileAccess.open(path, FileAccess.READ)
	# Only the header says what a .tres holds without loading it.
	if file == null or not file.get_line().contains("script_class=\"XREBlueprintGraph\""): return empty
	file.close()
	var graph := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REUSE) as XREBlueprintGraph
	if graph == null: return empty
	var counted := count(graph)
	counted["time"] = time
	return counted
