@tool
class_name XREVirtualKeyboard
extends XREPanelSurface
## A separate tilted keyboard using SteamVR's five-row English key arrangement.
## Hover pulses belong to the pointing hand; clicks use an original generated sound.

signal applied(text: String)
signal hover_feedback(hand: XREHand)
signal key_clicked

const NORMAL: Array[String] = ["1234567890-", "qwertyuiop", "asdfghjkl", "?zxcvbnm,."]
const SHIFT: Array[String] = ["1234567890_", "QWERTYUIOP", "ASDFGHJKL", "\"ZXCVBNM:;"]
const SYMBOLS: Array[String] = ["!@#$%^&*()=", "+£€$\"'~|#\\", "{}%^<>[]\"", "/\\{}()`~/|"]
const TILT := PI / 5.0
## A shallow release is enough for fast typing; scene tools retain their wider hysteresis.
const KEY_RELEASE_THRESHOLD := 0.55
const KEY_HIT_MARGIN := 3.0

var value: LineEdit
var _keys: Array[Button] = []
var _characters: Array[Button] = []
var _plane := 0
var _right_key := -1
var _left_key := -1
var _right_pressed := -1
var _left_pressed := -1
var _right_down := false
var _left_down := false
var _sound: AudioStreamPlayer
var _normal_style: StyleBoxFlat
var _hover_style: StyleBoxFlat
var _pressed_style: StyleBoxFlat


func _init(theme: Theme = null) -> void:
	super(Vector2(900, 440), 0.0008, 1.5, theme)
	name = "VirtualKeyboard"
	_normal_style = _key_style(Color("2d3b4c"))
	_hover_style = _key_style(Color("456e91"))
	_pressed_style = _key_style(Color("234c70"))
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color("171e28")
	frame.border_color = Color("536c85")
	frame.set_border_width_all(2)
	frame.set_corner_radius_all(10)
	frame.set_content_margin_all(12)
	root.add_theme_stylebox_override(&"panel", frame)
	var column := VBoxContainer.new()
	root.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	value = LineEdit.new()
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.custom_minimum_size.y = 52
	header.add_child(value)
	_add_key(header, "×", close, 0.7)
	for row_index: int in NORMAL.size():
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.size_flags_vertical = Control.SIZE_EXPAND_FILL
		column.add_child(row)
		if row_index == 2: _add_key(row, "123 / #+=", _symbols, 1.3)
		if row_index == 3: _add_key(row, "Shift", _shift, 1.0)
		for character: String in NORMAL[row_index]:
			var button := _add_key(row, character, Callable(), 1.0)
			button.pressed.connect(_insert.bind(button))
			_characters.append(button)
		if row_index == 0: _add_key(row, "⌫", value.delete_char_at_caret, 1.5)
		if row_index == 3: _add_key(row, "Shift", _shift, 1.0)
	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(bottom)
	_add_key(bottom, "Space", func() -> void: value.insert_text_at_caret(" "), 9.0)
	_add_key(bottom, "Done", _apply, 3.0)
	value.text_submitted.connect(func(_text: String) -> void: _apply())
	_sound = AudioStreamPlayer.new()
	_sound.stream = _click_sound()
	_sound.volume_db = -6.0
	_sound.max_polyphony = 8
	_sound.mix_target = AudioStreamPlayer.MIX_TARGET_STEREO
	add_child(_sound)
	set_shown(false)


## Opens without changing the edited field until Done is pressed.
func open_text(text: String) -> void:
	value.text = text
	value.caret_column = text.length()
	_plane = 0
	_update_labels()
	set_shown(true)


## Cancels the current draft and clears both hands' hover state.
func close() -> void:
	set_shown(false)
	_right_key = -1
	_left_key = -1
	_right_pressed = -1
	_left_pressed = -1
	for index: int in _keys.size(): _update_key_style(index)


## Called by the owning pointer before dispatching its mouse movement.
func hover_pointer(hand: XREHand, pixel: Vector2) -> void:
	var index := -1
	var nearest := INF
	if is_shown():
		for i: int in _keys.size():
			var bounds := _keys[i].get_global_rect()
			if bounds.has_point(pixel):
				index = i
				break
			if bounds.grow(KEY_HIT_MARGIN).has_point(pixel):
				var score := pixel.distance_squared_to(bounds.get_center())
				if score < nearest:
					index = i
					nearest = score
	var right := hand.tracker == &"right_hand"
	var previous := _right_key if right else _left_key
	if right: _right_key = index
	else: _left_key = index
	if previous != index:
		_update_key_style(previous)
		_update_key_style(index)
	if index >= 0 and index != previous:
		hover_feedback.emit(hand)
		XREEditorHaptics.pulse(1 if right else 0, 0.18, 0.018)


## Resets hover on exit so returning to the same key produces one new pulse.
func leave_pointer(hand: XREHand) -> void:
	var right := hand.tracker == &"right_hand"
	var previous := _right_key if right else _left_key
	var pressed := _right_pressed if right else _left_pressed
	if right:
		_right_key = -1
		_right_pressed = -1
	else:
		_left_key = -1
		_left_pressed = -1
	_update_key_style(previous)
	_update_key_style(pressed)


## Each trigger owns its key independently; no shared viewport mouse is needed.
func press_pointer(hand: XREHand) -> void:
	if not is_shown(): return
	var right := hand.tracker == &"right_hand"
	if (right and _right_pressed >= 0) or (not right and _left_pressed >= 0): return
	var index := _right_key if right else _left_key
	if right: _right_pressed = index
	else: _left_pressed = index
	_update_key_style(index)
	if index >= 0: _keys[index].pressed.emit()


## Release ends the visual press; the key has already been accepted on trigger-down.
func release_pointer(hand: XREHand) -> void:
	var right := hand.tracker == &"right_hand"
	var index := _right_pressed if right else _left_pressed
	if right: _right_pressed = -1
	else: _left_pressed = -1
	_update_key_style(index)


## Polls analog trigger once per frame, including when the ray is outside the keyboard.
func poll_trigger(hand: XREHand, accepts_input: bool) -> void:
	var right := hand.tracker == &"right_hand"
	var before := _right_down if right else _left_down
	var down := hand.get_float(&"trigger") > (KEY_RELEASE_THRESHOLD if before else XREHand.PRESS_THRESHOLD)
	if right: _right_down = down
	else: _left_down = down
	if down and not before and accepts_input and is_shown(): press_pointer(hand)
	elif not down and before: release_pointer(hand)


## Whether either ray is visibly highlighting this key.
func key_is_hovered(index: int) -> bool:
	return index >= 0 and (index == _right_key or index == _left_key)


func _update_key_style(index: int) -> void:
	if index < 0: return
	var style := _pressed_style if index == _right_pressed or index == _left_pressed else (_hover_style if key_is_hovered(index) else _normal_style)
	_keys[index].add_theme_stylebox_override(&"normal", style)


func _add_key(parent: Node, text: String, action: Callable, width: float) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(58 * width, 54)
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override(&"normal", _normal_style)
	button.add_theme_stylebox_override(&"hover", _hover_style)
	button.add_theme_stylebox_override(&"pressed", _pressed_style)
	button.add_theme_color_override(&"font_color", Color.WHITE)
	button.add_theme_color_override(&"font_hover_color", Color.WHITE)
	button.add_theme_color_override(&"font_pressed_color", Color.WHITE)
	button.add_theme_font_size_override(&"font_size", 22 if width >= 1.0 else 20)
	button.pressed.connect(_play_click)
	if action.is_valid(): button.pressed.connect(action)
	parent.add_child(button)
	_keys.append(button)
	return button


static func _key_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("71869b")
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.set_content_margin_all(4)
	return style


func _insert(button: Button) -> void:
	value.insert_text_at_caret(button.text)


func _shift() -> void:
	_plane = 0 if _plane == 1 else 1
	_update_labels()


func _symbols() -> void:
	_plane = 0 if _plane == 2 else 2
	_update_labels()


func _update_labels() -> void:
	var rows := NORMAL if _plane == 0 else (SHIFT if _plane == 1 else SYMBOLS)
	var index := 0
	for row: String in rows:
		for character: String in row:
			_characters[index].text = character
			index += 1


func _apply() -> void:
	applied.emit(value.text)
	close()


func _play_click() -> void:
	key_clicked.emit()
	_sound.play()


static func _click_sound() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	var samples := PackedByteArray()
	samples.resize(1320 * 2)
	for i: int in 1320:
		var time := float(i) / 22050.0
		var envelope := exp(-time * 90.0) * minf(time * 2000.0, 1.0)
		var sample := int(sin(time * TAU * 1100.0) * envelope * 18000.0)
		samples.encode_s16(i * 2, sample)
	stream.data = samples
	return stream
