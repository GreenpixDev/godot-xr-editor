extends SceneTree
## Loads every GDScript in the project so that parse and type errors surface
## in a single headless run, and checks that the plugin's native library is
## loaded. Used by scripts/check.sh, not shipped with the plugin.

## A class registered by gdextension/ (see scripts/build_gdextension.sh).
const NATIVE_CLASS := "XREEditorControllers"


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
	if not ClassDB.class_exists(NATIVE_CLASS):
		failed += 1
		printerr("parse_all: FAILED native library not loaded, run scripts/build_gdextension.sh")
	quit(1 if failed > 0 else 0)


## Paths of all .gd files under [param dir_path], skipping hidden folders and
## folders Godot ignores ([code].gdignore[/code]).
func _scripts_under(dir_path: String) -> PackedStringArray:
	var result := PackedStringArray()
	if FileAccess.file_exists(dir_path.path_join(".gdignore")):
		return result
	for file in DirAccess.get_files_at(dir_path):
		if file.get_extension() == "gd":
			result.append(dir_path.path_join(file))
	for dir in DirAccess.get_directories_at(dir_path):
		if not dir.begins_with("."):
			result.append_array(_scripts_under(dir_path.path_join(dir)))
	return result
