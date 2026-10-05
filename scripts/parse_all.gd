extends SceneTree
## Loads every GDScript in the project so that parse and type errors surface
## in a single headless run. Used by scripts/check.sh, not shipped with the plugin.


func _init() -> void:
	var failed := 0
	var scripts := _scripts_under("res://")
	for path in scripts:
		# load() returns a script object even on a parse error; only
		# can_instantiate() tells broken scripts apart (true for @abstract too).
		var script := load(path) as Script
		if script == null or not script.can_instantiate():
			failed += 1
			printerr("parse_all: FAILED ", path)
	print("parse_all: %d of %d script(s) failed to load" % [failed, scripts.size()])
	quit(1 if failed > 0 else 0)


func _scripts_under(dir_path: String) -> PackedStringArray:
	var result := PackedStringArray()
	for file in DirAccess.get_files_at(dir_path):
		if file.get_extension() == "gd":
			result.append(dir_path.path_join(file))
	for dir in DirAccess.get_directories_at(dir_path):
		if not dir.begins_with("."):
			result.append_array(_scripts_under(dir_path.path_join(dir)))
	return result
