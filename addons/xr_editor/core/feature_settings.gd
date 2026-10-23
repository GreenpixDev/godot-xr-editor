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

## Emitted after the value of setting [param key] changed. Switching the
## controls layout or rebinding an action emits it with [constant CONTROLS].
signal changed(key: StringName)

## Pages of the settings tab.
enum Category {
	## How features look and behave.
	FEATURES,
	## Which controller buttons do what: the layout and its bindings (D-050).
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

## Parameters of logic graph blocks as objects of the graph (D-052): each of the
## four settings takes one kind of parameter out of the parameters window.
## Literal values — durations, conditions, values, an event's policy, wait.
const VALUE_INPUT := &"value_input"
## In the block's parameters window, as before.
const WINDOW := &"window"
## Tokens: pucks lying in slots on the card's rows.
const PUCKS := &"pucks"
## Tokens: plugs in the ports, sticking out to the left of the card.
const PLUGS := &"plugs"
## The target object and its member — a property, a signal, an animation.
## Every value but Window wires the Target to the object in the scene; they
## differ in where the member's name shows (D-057).
const TARGET_INPUT := &"target_input"
## The member's name on the card, after Target or Source; the wire ends at the object.
const ON_NODE := &"node"
## The member's name only on a petal on a stem from the object, where the wire ends.
const SCENE := &"scene"
## An adapter: a plug in the Target (or Source) port, like a token, with the
## member's name on it, and the wire to the object leaves its far end (D-059).
const ADAPTER := &"adapter"
## Whether Play Animation waits for its animation.
const ANIMATION_WAIT := &"animation_wait"
## A wait flag, as before.
const FLAG := &"flag"
## Which output is wired: Then goes on at once, Finished after the animation.
const FINISHED_PORT := &"finished_port"
## The variable of Get and Set Variable.
const VARIABLE_INPUT := &"variable_input"
## A wire to the variable's box on a shelf beside the graph.
const BOXES := &"boxes"
## A window of ready tokens beside the graph, as Objects is for the scene; with tokens only.
const TOKEN_TRAY := &"token_tray"
## A wire from a petal of the selected object let go in the graph adds the block for that member.
const SCENE_CREATE := &"scene_create"
const OFF := &"off"
const ON := &"on"
## The plus on a card, which opens the block menu wired to its execution
## output (D-058). Shown by default; hidden, a block is added only by a wire
## let go in empty space (D-051) or from the Blueprints tab.
const CARD_PLUS := &"card_plus"
const SHOWN := &"shown"
const HIDDEN := &"hidden"
## How a color token is edited (D-064): in the Color window, near the head.
const COLOR_INPUT := &"color_input"
## Godot's color picker: a square, sliders and the hex code.
const PICKER := &"picker"
## A globe of colors to turn and click, its depth the saturation, R, G, B and hex typed.
const GLOBE := &"globe"
## How the scale of a number's line and of a vector's arrows changes (D-069).
const AXIS_SCALE := &"axis_scale"
## By itself: held past an end the value speeds on, held by 0 it goes toward zero (D-060, D-067, D-068).
const AUTO := &"auto"
## By the stick, up finer and down coarser, the value kept; nothing speeds on.
const STICK := &"stick"

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
	VALUE_INPUT: {
		"category": Category.FEATURES,
		"title": "Values",
		"values": [WINDOW, PUCKS, PLUGS],
		"labels": ["Window", "Pucks", "Plugs"],
		"hint": "Window: in the block's parameters. Pucks: tokens in slots on the card. Plugs: tokens plugged into the ports.",
	},
	TARGET_INPUT: {
		"category": Category.FEATURES,
		"title": "Targets",
		"values": [WINDOW, ON_NODE, SCENE, ADAPTER],
		"labels": ["Window", "Node", "Scene", "Adapter"],
		"hint": "Window: in the parameters. Others wire the Target to the object; the member shows on the card (Node), on a petal at the object (Scene) or on a plug in the port the wire leaves (Adapter).",
	},
	ANIMATION_WAIT: {
		"category": Category.FEATURES,
		"title": "Animation wait",
		"values": [FLAG, FINISHED_PORT],
		"labels": ["Flag", "Finished port"],
		"hint": "Flag: a wait setting. Finished port: wire Finished to wait for the animation, Then not to.",
	},
	VARIABLE_INPUT: {
		"category": Category.FEATURES,
		"title": "Variables",
		"values": [WINDOW, BOXES],
		"labels": ["Window", "Boxes"],
		"hint": "Window: chosen in the parameters. Boxes: wire Get and Set Variable to a box on the shelf.",
	},
	TOKEN_TRAY: {
		"category": Category.FEATURES,
		"title": "Token tray",
		"values": [OFF, ON],
		"labels": ["Off", "On"],
		"hint": "On: a Tokens window of ready values opens with the graph. Works with Values on Pucks or Plugs.",
	},
	SCENE_CREATE: {
		"category": Category.FEATURES,
		"title": "Create from scene",
		"values": [OFF, ON],
		"labels": ["Off", "On"],
		"hint": "On: the selected object shows its members; a wire from one let go in the graph adds its block.",
	},
	CARD_PLUS: {
		"category": Category.FEATURES,
		"title": "Plus on cards",
		"values": [SHOWN, HIDDEN],
		"labels": ["Shown", "Hidden"],
		"hint": "Shown: the plus on a card adds the next block. Hidden: add blocks by letting a wire go in empty space.",
	},
	COLOR_INPUT: {
		"category": Category.FEATURES,
		"title": "Color input",
		"values": [PICKER, GLOBE],
		"labels": ["2D", "3D"],
		"hint": "2D: a color picker with the hex code. 3D: a globe of colors to turn and click, R, G, B typed. Both have a pipette.",
	},
	AXIS_SCALE: {
		"category": Category.FEATURES,
		"title": "Axis scale",
		"values": [AUTO, STICK],
		"labels": ["Auto", "Stick"],
		"hint": "For a number's line and a vector's arrows. Auto: past an end the value speeds up, held by 0 it goes toward 0. Stick: the stick up makes the scale finer, down coarser; nothing speeds up.",
	},
}

## Key [signal changed] carries when the controls layout or a binding changed.
const CONTROLS := &"controls"

## Layouts of the controls (D-050): the bindings of every action. One is picked
## for the runtime the editor runs on until the user picks another; rebinding
## an action in a preset copies the preset into [constant CUSTOM] first.
const HORIZON_LINK := &"horizon_link"
const STEAMVR := &"steamvr"
const HORIZON_OS := &"horizon_os"
## The VR view without a headset (D-057): the controllers' buttons are keys
## ([constant XRESimulator.BUTTON_KEYS]), and the controls page shows the keys.
const NON_VR := &"non_vr"
## The user's own bindings. Once chosen it is used on every runtime.
const CUSTOM := &"custom"
const LAYOUTS: Array[StringName] = [HORIZON_LINK, STEAMVR, HORIZON_OS, NON_VR, CUSTOM]
const LAYOUT_LABELS: Array[String] = ["Horizon Link", "SteamVR", "Horizon OS", "NonVR", "Custom"]

## Actions with a button of their own, in the order of the controls page.
const DELETE := &"delete"
const LAUNCHER := &"launcher"
const PLAY := &"play"
const SPEED := &"speed"
const ACTIONS: Array[StringName] = [LAUNCHER, PLAY, DELETE, SPEED]
const ACTION_TITLES: Dictionary[StringName, String] = {
	LAUNCHER: "Open the launcher",
	PLAY: "Play / stop (hold in game: back)",
	DELETE: "Delete the selection",
	SPEED: "Change flying speed",
}

## Buttons an action can take: the controller's hand, its input in the
## tracker's name, the button's name and the letters of its icon
## ([XREButtonGlyph]; "≡" is drawn as a menu button). Trigger and grip select
## and grab everywhere and are not rebindable. The right Menu is the system's;
## the left one reaches applications on Meta's runtimes, while SteamVR keeps it
## for its dashboard.
const BUTTONS: Dictionary[StringName, Dictionary] = {
	&"left_menu": {"hand": &"left_hand", "input": &"menu_button", "label": "Left Menu", "glyph": "≡"},
	&"left_x": {"hand": &"left_hand", "input": &"ax_button", "label": "Left X", "glyph": "X"},
	&"left_y": {"hand": &"left_hand", "input": &"by_button", "label": "Left Y", "glyph": "Y"},
	&"left_stick": {"hand": &"left_hand", "input": &"primary_click", "label": "Left stick click", "glyph": "LS"},
	&"right_a": {"hand": &"right_hand", "input": &"ax_button", "label": "Right A", "glyph": "A"},
	&"right_b": {"hand": &"right_hand", "input": &"by_button", "label": "Right B", "glyph": "B"},
	&"right_stick": {"hand": &"right_hand", "input": &"primary_click", "label": "Right stick click", "glyph": "RS"},
}

## Bindings of the presets, by layout. On Meta's runtimes the launcher is on
## the left Menu button, as Meta's own apps open their menus; SteamVR keeps
## that button for its dashboard, so there the launcher stays on X. Without a
## headset the keys are Tab, Y, E and Shift.
const _PRESETS: Dictionary[StringName, Dictionary] = {
	HORIZON_LINK: {LAUNCHER: &"left_menu", PLAY: &"left_y", DELETE: &"right_a", SPEED: &"left_stick"},
	STEAMVR: {LAUNCHER: &"left_x", PLAY: &"left_y", DELETE: &"right_a", SPEED: &"left_stick"},
	HORIZON_OS: {LAUNCHER: &"left_menu", PLAY: &"left_y", DELETE: &"right_a", SPEED: &"left_stick"},
	NON_VR: {LAUNCHER: &"left_menu", PLAY: &"left_y", DELETE: &"right_a", SPEED: &"left_stick"},
}

const _SECTION := "features"
const _CONTROLS_SECTION := "controls"

## File the values persist in, or empty to keep them in memory.
var path := ""
var _values: Dictionary[StringName, StringName] = {}
## The layout the runtime asks for, while the user hasn't picked one.
var runtime_layout := HORIZON_LINK
## The layout the user picked, or empty while the runtime's is used.
var _layout := &""
## The user's bindings, by action; complete once [constant CUSTOM] was chosen or made.
var _custom: Dictionary[StringName, StringName] = {}


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
	for action: StringName in ACTIONS:
		var button: Variant = config.get_value(_CONTROLS_SECTION, String(action), "")
		if button is String and StringName(button) in BUTTONS:
			_custom[action] = StringName(button)
	if _custom.size() != ACTIONS.size():
		_custom.clear()
	var layout: Variant = config.get_value(_CONTROLS_SECTION, "layout", "")
	if layout is String and StringName(layout) in LAYOUTS and (layout != CUSTOM or not _custom.is_empty()):
		_layout = StringName(layout)


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


## The layout a runtime gets until the user picks one: the standalone headset's
## own, SteamVR's, otherwise Meta Link's. [param runtime_name] is
## [code]XRRuntimeName[/code] of the OpenXR system info.
static func layout_for_runtime(runtime_name: String, standalone: bool) -> StringName:
	if standalone:
		return HORIZON_OS
	return STEAMVR if runtime_name.begins_with("SteamVR") else HORIZON_LINK


## The layout in use: the user's pick, or the runtime's.
func get_layout() -> StringName:
	return _layout if _layout != &"" else runtime_layout


## Whether buttons are keys of the keyboard: the NonVR layout is in use, or
## the VR view runs without a headset (its runtime layout), whatever the user picked.
func uses_keyboard() -> bool:
	return get_layout() == NON_VR or runtime_layout == NON_VR


## The button action [param action] has in the current layout, a key of [constant BUTTONS].
func get_binding(action: StringName) -> StringName:
	var layout := get_layout()
	if layout == CUSTOM and action in _custom:
		return _custom[action]
	return preset_binding(runtime_layout if layout == CUSTOM else layout, action)


## The button of [param action] in preset [param layout], or empty for an unknown one.
static func preset_binding(layout: StringName, action: StringName) -> StringName:
	var preset: Dictionary = _PRESETS.get(layout, {})
	return preset.get(action, &"")


## The button of [param action] in [param features], or in the default
## layout when there are none (tools run without a document in tests).
static func binding_of(features: XREFeatureSettings, action: StringName) -> StringName:
	return features.get_binding(action) if features != null else preset_binding(HORIZON_LINK, action)


## Tracker name of [param button]'s hand, [code]&"left_hand"[/code] or [code]&"right_hand"[/code].
static func button_hand(button: StringName) -> StringName:
	return BUTTONS[button]["hand"] if button in BUTTONS else &""


## The tracker's input of [param button].
static func button_input(button: StringName) -> StringName:
	return BUTTONS[button]["input"] if button in BUTTONS else &""


## The name of [param button] for the user: "Left Y".
static func button_label(button: StringName) -> String:
	return BUTTONS[button]["label"] if button in BUTTONS else ""


## The letters on [param button]'s icon: "A", or "LS" for a stick.
static func button_glyph(button: StringName) -> String:
	return BUTTONS[button]["glyph"] if button in BUTTONS else ""


## Picks [param layout]. Custom starts as a copy of the bindings in use if the
## user has none. False, and nothing changed, for an unknown layout or the
## layout already in use.
func set_layout(layout: StringName) -> bool:
	if not layout in LAYOUTS or layout == get_layout():
		return false
	if layout == CUSTOM and _custom.is_empty():
		_custom = _current_bindings()
	_layout = layout
	_save()
	changed.emit(CONTROLS)
	return true


## Binds [param action] to [param button]. A preset in use is first copied
## into the custom layout, with every other binding as it was, and the custom
## layout is picked. A button another action had goes to the button [param action]
## gave up, so that no two actions share one. False for an unknown action or
## button, or the binding already set.
func set_binding(action: StringName, button: StringName) -> bool:
	if not action in ACTIONS or not button in BUTTONS or get_binding(action) == button:
		return false
	var bindings := _current_bindings()
	var previous := bindings[action]
	for other: StringName in ACTIONS:
		if other != action and bindings[other] == button:
			bindings[other] = previous
	bindings[action] = button
	_custom = bindings
	_layout = CUSTOM
	_save()
	changed.emit(CONTROLS)
	return true


## One line with every setting's current value, for the editor's log.
func describe() -> String:
	var parts := PackedStringArray()
	for key: StringName in DEFINITIONS:
		parts.append("%s=%s" % [key, get_value(key)])
	parts.append("layout=%s" % get_layout())
	return ", ".join(parts)


func _current_bindings() -> Dictionary[StringName, StringName]:
	var bindings: Dictionary[StringName, StringName] = {}
	for action: StringName in ACTIONS:
		bindings[action] = get_binding(action)
	return bindings


func _save() -> void:
	if path.is_empty():
		return
	var config := ConfigFile.new()
	for key: StringName in _values:
		config.set_value(_SECTION, String(key), String(_values[key]))
	if _layout != &"":
		config.set_value(_CONTROLS_SECTION, "layout", String(_layout))
	for action: StringName in _custom:
		config.set_value(_CONTROLS_SECTION, String(action), String(_custom[action]))
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	if config.save(path) != OK:
		push_error("XR Editor: can't save feature settings to " + path)
