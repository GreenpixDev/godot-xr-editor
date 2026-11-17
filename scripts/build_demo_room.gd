extends SceneTree
## Builds the Blueprints demo room: demo/blueprint_room.tscn, the graphs of its
## stations (demo/station_*.tres) and their generated scripts (docs/blueprints.md,
## "Demo room"). The graphs go through XREBlueprintDocument, as the editor makes
## them, so the headset opens them like any other.
##
## Run: godot --headless --xr-mode off --path . -s res://scripts/build_demo_room.gd
## Rebuilding overwrites the scene and the graphs: edits made in the editor are lost.

const DIR := "res://demo"
const SCENE_PATH := "res://demo/blueprint_room.tscn"
const ROOM_SCRIPT := "res://demo/blueprint_room.gd"
const TABLE_TOP := 0.775
## Graph columns are spread so neighboring cards don't touch (a card is about 290 px wide).
const COLUMN_SCALE := 1.3
## Where each station's sign, content and button sit, in meters from its origin.
const SIGN_POS := Vector3(0.0, 0.004, 0.33)
const CONTENT_Z := -0.1
const BUTTON_Z := 0.2
const STATION_X: Array[float] = [-1.2, -0.4, 0.4, 1.2]
const LAMP_COLORS: Array[Color] = [Color(1.0, 0.25, 0.2), Color(1.0, 0.65, 0.15), Color(0.95, 0.95, 0.3), Color(0.25, 0.9, 0.4), Color(0.3, 0.55, 1.0)]

var _failed := false


func _init() -> void:
	_build.call_deferred()


func _build() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DIR))
	var scene := _make_scene()
	var packed := PackedScene.new()
	if packed.pack(scene) != OK or ResourceSaver.save(packed, SCENE_PATH) != OK:
		push_error("build_demo_room: could not save the scene.")
		quit(1)
		return
	scene.free()
	# The graphs bind to the scene as it is on disk, the way the editor opens it.
	var loaded := (ResourceLoader.load(SCENE_PATH, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE) as PackedScene).instantiate()
	_switch_graph(loaded, "Station1")
	_door_graph(loaded, "Station2")
	_wave_graph(loaded, "Station3")
	var repacked := PackedScene.new()
	if repacked.pack(loaded) != OK or ResourceSaver.save(repacked, SCENE_PATH) != OK:
		push_error("build_demo_room: could not save the scene with its scripts.")
		_failed = true
	loaded.free()
	print("build_demo_room: ", "FAILED" if _failed else "done")
	quit(1 if _failed else 0)


# --- The scene ---

func _make_scene() -> Node3D:
	var room := Node3D.new()
	room.name = "BlueprintRoom"
	room.set_script(load(ROOM_SCRIPT))
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.03, 0.035, 0.05)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.45, 0.5, 0.65)
	environment.ambient_light_energy = 0.6
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world := WorldEnvironment.new()
	world.environment = environment
	_add(room, room, world, "WorldEnvironment")
	var moon := DirectionalLight3D.new()
	moon.light_energy = 0.25
	moon.light_color = Color(0.7, 0.78, 1.0)
	moon.rotation_degrees = Vector3(-55.0, 25.0, 0.0)
	_add(room, room, moon, "Moon")
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(8.0, 8.0)
	_add_mesh(room, room, floor_mesh, "Floor", Vector3.ZERO, Color(0.16, 0.17, 0.2))
	var table_mesh := BoxMesh.new()
	table_mesh.size = Vector3(3.2, 0.05, 0.8)
	_add_mesh(room, room, table_mesh, "Table", Vector3(0.0, TABLE_TOP - 0.025, -0.8), Color(0.55, 0.55, 0.58))
	var legs := Node3D.new()
	_add(room, room, legs, "Legs")
	for index: int in 4:
		var leg_mesh := BoxMesh.new()
		leg_mesh.size = Vector3(0.05, TABLE_TOP - 0.05, 0.05)
		var x := -1.5 if index % 2 == 0 else 1.5
		var z := -0.5 if index < 2 else -1.1
		_add_mesh(room, legs, leg_mesh, "Leg%d" % index, Vector3(x, (TABLE_TOP - 0.05) / 2.0, z), Color(0.3, 0.3, 0.33))
	var titles: Array[String] = ["1 · ВЫКЛЮЧАТЕЛЬ\nсобытие, переменная, ветвление", "2 · ДВЕРЬ\nждёт конца анимации", "3 · ВОЛНА\nодин цикл, пять ламп", "4 · ВАШ ХОД\nсоберите эту станцию сами"]
	for index: int in 4:
		var station := Node3D.new()
		station.position = Vector3(STATION_X[index], TABLE_TOP, -0.8)
		_add(room, room, station, "Station%d" % (index + 1))
		_add_button(room, station)
		# Lying on the table at its front edge, so the graph hangs over the station and covers nothing.
		_add_label(room, station, "Sign", titles[index], SIGN_POS, 40, 0.0012).rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	_fill_lamp(room, room.get_node("Station1") as Node3D, "ВЫКЛ")
	_fill_door(room, room.get_node("Station2") as Node3D)
	_fill_wave(room, room.get_node("Station3") as Node3D)
	_fill_lamp(room, room.get_node("Station4") as Node3D, "?")
	return room


func _fill_lamp(owner_node: Node, station: Node3D, status: String) -> void:
	var stand := CylinderMesh.new()
	stand.top_radius = 0.008
	stand.bottom_radius = 0.008
	stand.height = 0.25
	_add_mesh(owner_node, station, stand, "Stand", Vector3(0.0, 0.125, CONTENT_Z), Color(0.35, 0.35, 0.4))
	var bulb := SphereMesh.new()
	bulb.radius = 0.045
	bulb.height = 0.09
	_add_mesh(owner_node, station, bulb, "Bulb", Vector3(0.0, 0.3, CONTENT_Z), Color(0.9, 0.85, 0.7))
	var lamp := OmniLight3D.new()
	lamp.light_energy = 0.0
	lamp.omni_range = 0.9
	lamp.light_color = Color(1.0, 0.85, 0.55)
	_add(owner_node, station, lamp, "Lamp", Vector3(0.0, 0.38, CONTENT_Z))
	_add_label(owner_node, station, "Status", status, Vector3(0.0, 0.07, BUTTON_Z - 0.1), 48)


func _fill_door(owner_node: Node, station: Node3D) -> void:
	var post := BoxMesh.new()
	post.size = Vector3(0.03, 0.4, 0.03)
	var lintel := BoxMesh.new()
	lintel.size = Vector3(0.43, 0.03, 0.03)
	_add_mesh(owner_node, station, post, "PostLeft", Vector3(-0.2, 0.2, CONTENT_Z), Color(0.35, 0.35, 0.4))
	_add_mesh(owner_node, station, post, "PostRight", Vector3(0.2, 0.2, CONTENT_Z), Color(0.35, 0.35, 0.4))
	_add_mesh(owner_node, station, lintel, "Lintel", Vector3(0.0, 0.415, CONTENT_Z), Color(0.35, 0.35, 0.4))
	var door_mesh := BoxMesh.new()
	door_mesh.size = Vector3(0.37, 0.4, 0.02)
	_add_mesh(owner_node, station, door_mesh, "Door", Vector3(0.0, 0.2, CONTENT_Z - 0.03), Color(0.15, 0.58, 0.77))
	_add_label(owner_node, station, "Status", "ЗАКРЫТО", Vector3(0.0, 0.07, BUTTON_Z - 0.1), 48)
	var closed := Animation.new()
	closed.length = 0.6
	var open := closed.duplicate() as Animation
	_slide(closed, -0.4, 0.0)
	_slide(open, 0.0, -0.4)
	var library := AnimationLibrary.new()
	library.add_animation(&"open", open)
	library.add_animation(&"close", closed)
	var player := AnimationPlayer.new()
	player.add_animation_library(&"", library)
	_add(owner_node, station, player, "AnimationPlayer")


func _slide(animation: Animation, from_x: float, to_x: float) -> void:
	var track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, NodePath("Door:position:x"))
	animation.track_insert_key(track, 0.0, from_x)
	animation.track_insert_key(track, animation.length, to_x)


func _fill_wave(owner_node: Node, station: Node3D) -> void:
	_add_label(owner_node, station, "Status", "ГОТОВО", Vector3(0.0, 0.07, BUTTON_Z - 0.1), 48)
	var lamps := Node3D.new()
	_add(owner_node, station, lamps, "Lamps")
	for index: int in LAMP_COLORS.size():
		var x := (index - 2) * 0.16
		var lamp := OmniLight3D.new()
		lamp.light_energy = 0.0
		lamp.omni_range = 0.6
		lamp.light_color = LAMP_COLORS[index]
		_add(owner_node, lamps, lamp, "L%d" % (index + 1), Vector3(x, 0.32, CONTENT_Z))
		var bulb := SphereMesh.new()
		bulb.radius = 0.035
		bulb.height = 0.07
		_add_mesh(owner_node, lamps, bulb, "B%d" % (index + 1), Vector3(x, 0.25, CONTENT_Z), LAMP_COLORS[index].darkened(0.35))


func _add_button(owner_node: Node, station: Node3D) -> void:
	var base := CylinderMesh.new()
	base.top_radius = 0.055
	base.bottom_radius = 0.055
	base.height = 0.02
	_add_mesh(owner_node, station, base, "ButtonBase", Vector3(0.0, 0.01, BUTTON_Z), Color(0.25, 0.25, 0.3))
	var area := Area3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.04
	var collision := CollisionShape3D.new()
	collision.shape = shape
	_add(owner_node, station, area, "Button", Vector3(0.0, 0.045, BUTTON_Z))
	_add(owner_node, area, collision, "Shape")
	var cap := CylinderMesh.new()
	cap.top_radius = 0.035
	cap.bottom_radius = 0.035
	cap.height = 0.03
	_add_mesh(owner_node, area, cap, "Cap", Vector3.ZERO, Color(0.9, 0.15, 0.15))


func _add_label(owner_node: Node, parent: Node, node_name: String, text: String, position: Vector3, size: int, pixel_size: float = 0.0015) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font_size = size
	label.pixel_size = pixel_size
	label.outline_size = 6
	label.modulate = Color(0.85, 0.92, 1.0)
	_add(owner_node, parent, label, node_name, position)
	return label


func _add_mesh(owner_node: Node, parent: Node, mesh: Mesh, node_name: String, position: Vector3, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	_add(owner_node, parent, instance, node_name, position)


func _add(owner_node: Node, parent: Node, node: Node, node_name: String, position: Vector3 = Vector3.ZERO) -> void:
	node.name = node_name
	if node is Node3D and position != Vector3.ZERO:
		(node as Node3D).position = position
	parent.add_child(node)
	node.owner = owner_node


# --- The graphs ---

## Station 1: the button toggles a variable, a Branch lights the lamp or darkens it.
func _switch_graph(scene: Node, station_name: String) -> void:
	var station := scene.get_node(station_name)
	var doc := _document(scene, station, "res://demo/station_switch.tres")
	doc.add_variable("lit", false)
	var button := station.get_node("Button")
	var lamp := station.get_node("Lamp")
	var status := station.get_node("Status")
	doc.set_target_member(1, button, "signal", "area_entered")
	doc.set_parameter(1, "policy", "restart")
	var read := _block(doc, "get_variable", Vector2(40, 400), {"variable": "lit"})
	var flip := _operator(doc, "not", Vector2(340, 400))
	var write := _block(doc, "set_variable", Vector2(640, 120), {"variable": "lit"})
	var now := _block(doc, "get_variable", Vector2(640, 400), {"variable": "lit"})
	var branch := _block(doc, "branch", Vector2(940, 120))
	var light_on := _tween(doc, lamp, "light_energy", 1.0, 0.3, Vector2(1240, 40))
	var text_on := _text(doc, status, "ВКЛ", Vector2(1540, 40))
	var light_off := _tween(doc, lamp, "light_energy", 0.0, 0.3, Vector2(1240, 400))
	var text_off := _text(doc, status, "ВЫКЛ", Vector2(1540, 400))
	_wire(doc, 1, "Then", write, "In")
	_wire(doc, read, "Value", flip, "A")
	_wire(doc, flip, "Result", write, "Value")
	_wire(doc, now, "Value", branch, "Condition")
	_wire(doc, write, "Then", branch, "In")
	_wire(doc, branch, "True", light_on, "In")
	_wire(doc, light_on, "Finished", text_on, "In")
	_wire(doc, branch, "False", light_off, "In")
	_wire(doc, light_off, "Finished", text_off, "In")
	_finish(doc, station)


## Station 2: the same toggle drives an animation the graph waits for.
func _door_graph(scene: Node, station_name: String) -> void:
	var station := scene.get_node(station_name)
	var doc := _document(scene, station, "res://demo/station_door.tres")
	doc.add_variable("requested_open", false)
	var button := station.get_node("Button")
	var player := station.get_node("AnimationPlayer")
	var status := station.get_node("Status")
	doc.set_target_member(1, button, "signal", "area_entered")
	doc.set_parameter(1, "policy", "restart")
	var read := _block(doc, "get_variable", Vector2(40, 400), {"variable": "requested_open"})
	var flip := _operator(doc, "not", Vector2(340, 400))
	var write := _block(doc, "set_variable", Vector2(640, 120), {"variable": "requested_open"})
	var now := _block(doc, "get_variable", Vector2(640, 400), {"variable": "requested_open"})
	var branch := _block(doc, "branch", Vector2(940, 120))
	var open := _animation(doc, player, "open", Vector2(1240, 40))
	var text_open := _text(doc, status, "ОТКРЫТО", Vector2(1540, 40))
	var close := _animation(doc, player, "close", Vector2(1240, 400))
	var text_closed := _text(doc, status, "ЗАКРЫТО", Vector2(1540, 400))
	_wire(doc, 1, "Then", write, "In")
	_wire(doc, read, "Value", flip, "A")
	_wire(doc, flip, "Result", write, "Value")
	_wire(doc, now, "Value", branch, "Condition")
	_wire(doc, write, "Then", branch, "In")
	_wire(doc, branch, "True", open, "In")
	_wire(doc, open, "Then", text_open, "In")
	_wire(doc, branch, "False", close, "In")
	_wire(doc, close, "Then", text_closed, "In")
	_finish(doc, station)


## Station 3: a loop over five lamps, each brightening and fading before the next.
func _wave_graph(scene: Node, station_name: String) -> void:
	var station := scene.get_node(station_name)
	var doc := _document(scene, station, "res://demo/station_wave.tres")
	var button := station.get_node("Button")
	var status := station.get_node("Status")
	var lamps := station.get_node("Lamps")
	doc.set_target_member(1, button, "signal", "area_entered")
	doc.set_parameter(1, "policy", "ignore")
	var running := _text(doc, status, "ВОЛНА…", Vector2(340, 120))
	var each := _block(doc, "for_each", Vector2(640, 120))
	var targets: Array[Node] = []
	for index: int in LAMP_COLORS.size():
		targets.append(lamps.get_node("L%d" % (index + 1)))
	_check(doc.wire_selection(each, targets), doc, "wire the lamps")
	var up := _tween(doc, targets[0], "light_energy", 1.5, 0.12, Vector2(940, 20))
	var down := _tween(doc, targets[0], "light_energy", 0.0, 0.3, Vector2(1400, 20))
	var ready := _text(doc, status, "ГОТОВО", Vector2(940, 400))
	_wire(doc, 1, "Then", running, "In")
	_wire(doc, running, "Then", each, "In")
	_wire(doc, each, "Loop Body", up, "In")
	_wire(doc, each, "Element", up, "Target")
	_wire(doc, up, "Finished", down, "In")
	_wire(doc, each, "Element", down, "Target")
	_wire(doc, each, "Completed", ready, "In")
	_finish(doc, station)


func _document(scene: Node, host: Node, file: String) -> XREBlueprintDocument:
	var doc := XREBlueprintDocument.new()
	doc.set_scene_root(scene)
	_check(doc.set_host_node(host), doc, "set the host")
	doc.path = file
	return doc


func _finish(doc: XREBlueprintDocument, host: Node) -> void:
	_check(doc.build(), doc, "build " + doc.path)
	if _failed:
		return
	var script := ResourceLoader.load(doc.script_path(), "GDScript", ResourceLoader.CACHE_MODE_REPLACE) as Script
	host.set_script(script)
	host.set_meta("_xre_blueprint", doc.path)


func _block(doc: XREBlueprintDocument, kind: String, position: Vector2, params: Dictionary = {}) -> int:
	position.x *= COLUMN_SCALE
	var id := doc.insert_block(XREBlueprintGraph.make_node(0, kind, position), position)
	_check(id > 0, doc, "add " + kind)
	for key: String in params:
		_check(doc.set_parameter(id, key, params[key]), doc, "set %s of %s" % [key, kind])
	return id


func _operator(doc: XREBlueprintDocument, op: String, position: Vector2) -> int:
	position.x *= COLUMN_SCALE
	var id := doc.insert_block(XREBlueprintGraph.make_operator(0, op, position), position)
	_check(id > 0, doc, "add operator " + op)
	return id


func _tween(doc: XREBlueprintDocument, target: Node, property: String, value: float, seconds: float, position: Vector2) -> int:
	var id := _block(doc, "tween", position)
	_check(doc.set_target_member(id, target, "property", property), doc, "tween target " + property)
	_check(doc.set_parameter(id, "value", value), doc, "tween value")
	_check(doc.set_parameter(id, "seconds", seconds), doc, "tween seconds")
	return id


func _text(doc: XREBlueprintDocument, target: Node, text: String, position: Vector2) -> int:
	var id := _block(doc, "set_property", position)
	_check(doc.set_target_member(id, target, "property", "text"), doc, "text target")
	_check(doc.set_parameter(id, "value", text), doc, "text value")
	return id


func _animation(doc: XREBlueprintDocument, player: Node, animation: String, position: Vector2) -> int:
	var id := _block(doc, "play_animation", position)
	_check(doc.set_target_member(id, player, "animation", animation), doc, "animation target")
	_check(doc.set_parameter(id, "wait", true), doc, "animation wait")
	return id


## Connects the output [param from_label] of [param from] to the input [param to_label] of [param to].
func _wire(doc: XREBlueprintDocument, from: int, from_label: String, to: int, to_label: String) -> void:
	var out_port := _port(doc, from, from_label, false)
	var in_port := _port(doc, to, to_label, true)
	_check(out_port >= 0 and in_port >= 0, doc, "ports %d.%s -> %d.%s" % [from, from_label, to, to_label])
	if out_port >= 0 and in_port >= 0:
		_check(doc.connect_blocks(from, out_port, to, in_port), doc, "wire %d.%s -> %d.%s" % [from, from_label, to, to_label])


func _port(doc: XREBlueprintDocument, id: int, label: String, input: bool) -> int:
	var ports := doc.graph.ports(doc.graph.find_node(id), input)
	for index: int in ports.size():
		var spec: Array = ports[index]
		if str(spec[0]).to_lower() == label.to_lower() or str(spec[2]).to_lower() == label.to_lower():
			return index
	return -1


func _check(condition: bool, doc: XREBlueprintDocument, what: String) -> bool:
	if not condition:
		_failed = true
		printerr("build_demo_room: FAILED %s: %s" % [what, doc.last_error])
	return condition
