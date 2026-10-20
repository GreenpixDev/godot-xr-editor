@tool
class_name XREFeatureSettings
extends RefCounted
## Variants of features under study (docs/decisions.md, D-039). When a feature
## has competing designs to compare on participants, each design is a value of
## one setting here, not a separate branch or a constant in code: the
## researcher switches it in the headset ([XRESettingsTab]) between sessions.
##
## Every setting belongs to a [enum Category], which is a page of the settings
## tab. Its first value is the default. Values are switched through
## [method XREDocument.set_feature], so that the switch is an operation in the
## study's log; tools read them with [method get_value] and redraw on
## [signal changed]. With a [member path] the values persist across editor
## restarts; without one (tests) they live in memory.
##
## Adding a variant: a new value in an existing setting's [code]values[/code]
## if it competes with the others, otherwise a new entry in [constant DEFINITIONS].

## Emitted after the value of setting [param key] changed.
signal changed(key: StringName)

## Pages of the settings tab.
enum Category {
	## How features look and behave.
	FEATURES,
	## Which controller inputs do what. None yet.
	CONTROLS,
}

## How logic graph cards are drawn ([XREBlueprintCanvas]).
const NODE_DISPLAY := &"node_display"
## Flat cards that turn towards the head around the vertical (D-033).
const BILLBOARD := &"billboard"
## Solid boxes in the graph's orientation, seen from the side when walked around.
const CUBOID := &"cuboid"

## How the ports of logic graph cards are drawn ([XREBlueprintCanvas], D-043).
const PORT_DISPLAY := &"port_display"
## Flat discs on the card's face.
const FLAT := &"flat"
## Round, shaded spheres standing out of the card's face.
const SPHERE := &"sphere"

## Shape of the windows (rig-locked panels, docs/vr_ui.md; D-043). The tab
## launcher is concave either way.
const WINDOW_SHAPE := &"window_shape"
## Bent around the user: the edges come nearer, as the launcher's do.
const CONCAVE := &"concave"

## Every setting by key: its page, title, values (the first is the default),
## the values' titles and a line of explanation.
const DEFINITIONS: Dictionary[StringName, Dictionary] = {
	NODE_DISPLAY: {
		"category": Category.FEATURES,
		"title": "Node display",
		"values": [BILLBOARD, CUBOID],
		"labels": ["Billboard", "Cuboid"],
		"hint": "Billboard: flat cards facing you. Cuboid: solid boxes fixed in the graph.",
	},
	PORT_DISPLAY: {
		"category": Category.FEATURES,
		"title": "Port display",
		"values": [FLAT, SPHERE],
		"labels": ["Flat", "Sphere"],
		"hint": "Flat: discs on the card. Sphere: round ports standing out of it.",
	},
	WINDOW_SHAPE: {
		"category": Category.FEATURES,
		"title": "Window shape",
		"values": [FLAT, CONCAVE],
		"labels": ["Flat", "Concave"],
		"hint": "Flat: plane windows. Concave: windows bent around you, as the launcher is.",
	},
}

const _SECTION := "features"

## File the values persist in, or empty to keep them in memory.
var path := ""
var _values: Dictionary[StringName, StringName] = {}


## Reads the values saved in [param file], if any. Unknown keys and values
## saved by another version fall back to the defaults.
func _init(file: String = "") -> void:
	path = file
	if path.is_empty() or not FileAccess.file_exists(path):
		return
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return
	for key: StringName in DEFINITIONS:
		var saved: Variant = config.get_value(_SECTION, String(key), "")
		if saved is String and StringName(saved) in get_values(key):
			_values[key] = StringName(saved)


## Keys of the settings on page [param category], in definition order.
static func get_keys(category: Category) -> Array[StringName]:
	var keys: Array[StringName] = []
	for key: StringName in DEFINITIONS:
		if DEFINITIONS[key]["category"] == category:
			keys.append(key)
	return keys


## The values setting [param key] may take; its default first.
static func get_values(key: StringName) -> Array[StringName]:
	var values: Array[StringName] = []
	if key in DEFINITIONS:
		var listed: Array = DEFINITIONS[key]["values"]
		for value: StringName in listed:
			values.append(value)
	return values


## The default value of setting [param key], or an empty name for an unknown key.
static func get_default(key: StringName) -> StringName:
	var values := get_values(key)
	return values[0] if not values.is_empty() else &""


## The current value of setting [param key].
func get_value(key: StringName) -> StringName:
	return _values[key] if key in _values else get_default(key)


## Sets setting [param key] to [param value] and saves it. Returns false, and
## changes nothing, for an unknown key or value or the current value. Tools and
## panels call [method XREDocument.set_feature], which logs the switch.
func set_value(key: StringName, value: StringName) -> bool:
	if not value in get_values(key) or get_value(key) == value:
		return false
	_values[key] = value
	_save()
	changed.emit(key)
	return true


## One line with every setting's current value, for the editor's log.
func describe() -> String:
	var parts := PackedStringArray()
	for key: StringName in DEFINITIONS:
		parts.append("%s=%s" % [key, get_value(key)])
	return ", ".join(parts)


func _save() -> void:
	if path.is_empty():
		return
	var config := ConfigFile.new()
	for key: StringName in _values:
		config.set_value(_SECTION, String(key), String(_values[key]))
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if config.save(path) != OK:
		push_error("XR Editor: can't save feature settings to " + path)
