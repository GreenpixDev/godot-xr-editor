@tool
extends Node
## Screenshots of the spatial graph as the headset shows it, for looking at by
## eye: a windowed editor (not headless, no XR) with fake controllers opens the
## graph of the selected object and saves views from the head to
## build/shots/. The plugin runs it with `-- --xre-shot-blueprint-vr`; it keeps
## the editor's saved feature settings, so the shots show what the user sees.
## The graph is the user's own: every edit the clicks make is undone before
## the editor quits, since the graph saves its draft on the way out.

const SIZE := Vector2i(1600, 1200)
const FOLDER := "res://build/shots"

var _document: XREDocument
var _service: XREBlueprints
var _rig: XRERig
var _viewport: SubViewport
var _right: XRControllerTracker
var _left: XRControllerTracker


func _init(document: XREDocument) -> void:
	_document = document


func _ready() -> void:
	_run.call_deferred()


func _frames(count: int = 3) -> void:
	for frame: int in count: await get_tree().process_frame


func _shot(name: String) -> void:
	await _frames(6)
	await RenderingServer.frame_post_draw
	var image := _viewport.get_texture().get_image()
	image.save_png(FOLDER + "/" + name + ".png")
	print("shot_blueprint_vr: ", ProjectSettings.globalize_path(FOLDER + "/" + name + ".png"))


## Points the right hand's ray at [param point] from [param front] of it.
func _aim(point: Vector3, front: Vector3) -> void:
	_right.set_pose(&"aim", Transform3D(Basis.looking_at(-front), point + front * 0.4), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)


## Puts the head at [param from], looking at [param at].
func _look(from: Vector3, at: Vector3) -> void:
	_rig.camera.global_transform = Transform3D(Basis.looking_at(at - from, Vector3.UP), from)


## D-115: the graph from its side and from behind, where Card mirror and Node
## back lay the cards out as a mirror's; the head back where it was.
func _shot_sides(head: Vector3, cards: Array) -> void:
	if cards.is_empty(): return
	var center := Vector3.ZERO
	for card: XREBlueprintCanvas.Card in cards: center += card.node.global_position
	center /= cards.size()
	var away := head - center
	away.y = 0.0
	for step: Array in [["25_side", PI * 0.5], ["25b_behind", PI * 0.8], ["25c_back", PI]]:
		_look(center + away.rotated(Vector3.UP, step[1] as float) + Vector3.UP * (head.y - center.y), center)
		await _frames(4)
		await _shot(step[0] as String)
	# From where the graph reads left to right: square to the sum of its wires'
	# directions, 1 m out from its cards' nearest edge.
	var bases: Dictionary[int, Vector3] = {}
	var middle := Vector3.ZERO
	for card: XREBlueprintCanvas.Card in cards:
		bases[card.id] = card.base
		middle += card.base
	middle /= cards.size()
	var flow := Vector3.ZERO
	for edge: Dictionary in _service.blueprint.graph.edges:
		if not bases.has(edge["from"]) or not bases.has(edge["to"]): continue
		var step: Vector3 = bases[edge["to"]] - bases[edge["from"]]
		step.y = 0.0
		if not step.is_zero_approx(): flow += step.normalized()
	flow = flow.normalized() if not flow.is_zero_approx() else Vector3.RIGHT
	var forward := Vector3(flow.z, 0, -flow.x)
	var nearest := 0.0
	for point: Vector3 in bases.values(): nearest = minf(nearest, (point - middle).dot(forward))
	var canvas := _service.canvas
	var view := middle + forward * (nearest - 1.0)
	view.y = middle.y + 0.12
	_look(canvas.to_global(view), canvas.to_global(middle))
	await _frames(4)
	await _shot("25d_view")
	_look(head, center)
	await _frames(4)


## D-093: the palette's tiles and task chips, the ring at a card's plus, the
## next-block suggestions there and the copy button; the user's settings back.
func _shot_d090(head: Vector3, host: Node3D) -> void:
	var keys: Array[StringName] = [XREFeatureSettings.BLOCK_PALETTE, XREFeatureSettings.PALETTE_GROUPS, XREFeatureSettings.NEXT_SUGGESTIONS, XREFeatureSettings.BLOCK_COPY]
	var saved: Dictionary[StringName, StringName] = {}
	for key: StringName in keys: saved[key] = _document.features.get_value(key)
	var panels := _service.panels
	var card: int = _service.blueprint.graph.nodes[0]["id"] if not _service.blueprint.graph.nodes.is_empty() else -1
	_document.features.set_value(XREFeatureSettings.NEXT_SUGGESTIONS, XREFeatureSettings.OFF)
	for groups: StringName in [XREFeatureSettings.SOURCES, XREFeatureSettings.TASKS]:
		_document.features.set_value(XREFeatureSettings.BLOCK_PALETTE, XREFeatureSettings.TILES)
		_document.features.set_value(XREFeatureSettings.PALETTE_GROUPS, groups)
		if card >= 0: _service.call("_show_block_palette", card)
		else: _service.open_block_menu()
		await _frames(6)
		var window := panels.find_window(XREBlueprintPaletteTab)
		if window != null:
			_look(window.global_position + window.global_basis.z * 0.7, window.global_position)
			await _shot("17b_tiles_%s" % groups)
		_service.close_block_palette()
		await _frames(3)
	_document.features.set_value(XREFeatureSettings.PALETTE_GROUPS, XREFeatureSettings.SOURCES)
	if card >= 0:
		var plus := _service.canvas.plus_position(card)
		_document.features.set_value(XREFeatureSettings.BLOCK_PALETTE, XREFeatureSettings.RING)
		_service.call("_show_block_palette", card)
		await _frames(4)
		var ring := _service.get("_choice") as XREBlueprintRing
		_look(head, plus)
		await _shot("17c_ring")
		if ring != null and ring.is_open():
			ring.open_sector(XREBlueprintRing.ORDER.find("Flow"))
			await _shot("17d_ring_flow")
		_service.call("_close_inputs")
		_document.features.set_value(XREFeatureSettings.BLOCK_PALETTE, XREFeatureSettings.LIST)
		_document.features.set_value(XREFeatureSettings.NEXT_SUGGESTIONS, XREFeatureSettings.ON)
		_service.call("_show_block_palette", card)
		await _frames(4)
		_look(head, plus)
		await _shot("17e_suggestions")
		_service.call("_close_inputs")
		_document.features.set_value(XREFeatureSettings.BLOCK_COPY, XREFeatureSettings.ON)
		await _frames(4)
		_look(head, host.global_position)
		await _shot("17f_copy_button")
		# The copy on its way: a stand-in that looks as the card does (D-114).
		# The trigger held with the ray off the graph, so the copy follows it and nothing else takes it.
		if card >= 0:
			_aim(Vector3(-50, 1.6, -1), Vector3.BACK)
			_right.set_input(&"trigger", 1.0)
			await _frames()
			_service.call("_start_copy", card, _rig.right_hand, _service.canvas.to_global(_service.canvas.get_block_position(card)))
			_service.set("_drag_distance", 0.5)
			await _frames(4)
			var ghost := _service.get("_ghost") as Node3D
			if ghost != null: _look(ghost.global_position + ghost.global_basis.z.normalized() * 0.35, ghost.global_position)
			await _shot("17g_copy_stand_in")
			_service.call("_end_drag", false)
			_right.set_input(&"trigger", 0.0)
			_aim(Vector3(-50, 0, 0), Vector3.BACK)
			await _frames()
	for key: StringName in keys: _document.features.set_value(key, saved[key])
	await _frames(3)


## D-140: Switch, Sequence, Break Vector4 and Make Transform3D, each in focus,
## then with the ray on its second output's name, which keeps its × or eye.
func _shot_pins() -> void:
	var switch := XREBlueprintGraph.make_switch(0, "int", Vector2.ZERO)
	# A third case with a long value, as the author's.
	switch["params"]["cases"] = 3
	switch["params"]["case_2"] = 194513308
	var blocks: Array[Dictionary] = [switch, XREBlueprintGraph.make_node(0, "sequence", Vector2.ZERO)]
	for action: Dictionary in XREBlueprintActions.new().call("_struct_actions") as Array:
		if action["id"] in ["struct:break:Vector4", "struct:make:Transform3D"]: blocks.append(action["block"])
	for index: int in blocks.size():
		_service.call("_add_from_menu", {"id": "shot:pins_%d" % index, "title": XREBlueprintGraph.title(blocks[index]), "target": null, "block": blocks[index]})
		await _frames(6)
		var added_id: int = _service.blueprint.graph.nodes.back()["id"]
		var card: XREBlueprintCanvas.Card = null
		for each: XREBlueprintCanvas.Card in _service.canvas.get("_cards") as Array:
			if each.id == added_id: card = each
		if card == null: continue
		var face := card.node.global_transform
		var front := face.basis.z.normalized()
		_look(face.origin + front * 0.3, face.origin)
		_aim(face.origin, front)
		await _shot("30_pins_%d_focus" % index)
		var pins := card.inputs if card.pin_input else card.outputs
		if card.pin_marks.size() > 1 and pins.size() > 1:
			var mark := card.pin_marks[1].position if card.pin_marks[1] != null else pins[1]
			_aim(card.node.to_global((mark + Vector3(pins[1].x, pins[1].y, mark.z)) * 0.5), front)
			await _shot("30_pins_%d_name" % index)
		_aim(Vector3(-50, 0, 0), Vector3.BACK)
		_service.blueprint.undo()
		await _frames(3)


## Mean script time of the next frames, in ms, printed with [param label].
func _time_frames(label: String, count: int = 120) -> void:
	var sum := 0.0
	for frame: int in count:
		await get_tree().process_frame
		sum += Performance.get_monitor(Performance.TIME_PROCESS)
	print("shot_blueprint_vr: %s: process %.2f ms mean over %d frames" % [label, sum / count * 1000.0, count])


## XRE_SHOT_ONLY=stats: what the open graph costs to draw, as the headset's
## renderer sees it (nodes by class, transparent surfaces, draw calls).
func _stats() -> void:
	await _frames(20)
	await _time_frames("graph open")
	var counts: Dictionary[String, int] = {}
	var transparent := 0
	var surfaces := 0
	var stack: Array[Node] = [_service]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		counts[node.get_class()] = counts.get(node.get_class(), 0) + 1
		for child: Node in node.get_children(): stack.push_back(child)
		if node is GeometryInstance3D and (node as GeometryInstance3D).visible:
			surfaces += 1
			var material := (node as GeometryInstance3D).material_override
			if node is MeshInstance3D and material == null: material = (node as MeshInstance3D).get_active_material(0)
			if node is Label3D or (material is BaseMaterial3D and (material as BaseMaterial3D).transparency != BaseMaterial3D.TRANSPARENCY_DISABLED): transparent += 1
	print("shot_blueprint_vr: nodes by class: ", counts)
	print("shot_blueprint_vr: visible geometry instances %d, transparent or text %d" % [surfaces, transparent])
	_service.close_graph()
	await _time_frames("graph closed")
	print("shot_blueprint_vr: draw calls %d, objects %d, primitives %d" % [
		_viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_DRAW_CALLS_IN_FRAME),
		_viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_OBJECTS_IN_FRAME),
		_viewport.get_render_info(Viewport.RENDER_INFO_TYPE_VISIBLE, Viewport.RENDER_INFO_PRIMITIVES_IN_FRAME)])


## The graph's own functions (docs/blueprint_functions.md): a call under the
## ray with its open button, the Functions window (D-148), then the body —
## Entry and Return, under the ray with their plus, the badge over the Entry,
## the window under it — and the pure Entry.
func _shot_functions() -> void:
	var blueprint := _service.blueprint
	var name := blueprint.create_function(false, "open_door")
	blueprint.add_function_pin(name, true)
	blueprint.add_function_pin(name, false)
	# Deep in VR, as a card moved by hand is.
	var call := blueprint.add_function_call(name, Vector2(-600, 700), {}, 0.4)
	await _frames(6)
	var card := _card_of(call)
	if card == null: return
	var face := card.node.global_transform
	var front := face.basis.z.normalized()
	_look(face.origin + front * 0.35, face.origin)
	_aim(face.origin, front)
	await _shot("40_fn_call_focus")
	var window := _service.panels.find_window(XREBlueprintFunctionsTab)
	if window == null: return
	var toward := window.global_basis.z.normalized()
	_look(window.global_position + toward * 0.45, window.global_position)
	await _shot("41_fn_plates")
	_aim(Vector3(-50, 0, 0), Vector3.BACK)
	# The same head before and after: the body's Entry takes the call's place, as deep.
	var canvas := _service.canvas
	var place := canvas.position_from_block(blueprint.graph.find_node(call))
	var head := canvas.to_global(place + Vector3(0.15, 0.05, 0.8))
	var seen := canvas.to_global(place + Vector3(0.15, 0.0, 0.0))
	_look(head, seen)
	await _shot("46_fn_open_before")
	_service.open_function(name, place, true)
	await _frames(10)
	_look(head, seen)
	await _shot("47_fn_open_after")
	# Farther back: the badge over the Entry, the window under it.
	_look(canvas.to_global(place + Vector3(0.1, -0.1, 1.1)), canvas.to_global(place + Vector3(0.1, -0.12, 0.0)))
	await _shot("51_fn_badge_window")
	var entry := _card_of(1)
	var ending := _card_of(2)
	if entry == null or ending == null: return
	var middle := (entry.node.global_position + ending.node.global_position) * 0.5
	_look(middle + front * 0.6, middle)
	await _shot("42_fn_body")
	_aim(entry.node.global_position, front)
	_look(entry.node.global_position + front * 0.35, entry.node.global_position)
	await _shot("43_fn_entry_focus")
	_aim(ending.node.global_position, front)
	_look(ending.node.global_position + front * 0.35, ending.node.global_position)
	await _shot("44_fn_return_focus")
	_service.set_function_pure(true)
	await _frames(10)
	entry = _card_of(1)
	if entry != null:
		_aim(entry.node.global_position, front)
		_look(entry.node.global_position + front * 0.35, entry.node.global_position)
		await _shot("45_fn_entry_pure")
	_aim(Vector3(-50, 0, 0), Vector3.BACK)
	# From the window: whichever function, a new one too, its Entry stands in one place over it.
	toward = window.global_basis.z.normalized()
	head = window.global_position + toward * 0.75 + Vector3.UP * 0.12
	seen = window.global_position + Vector3.UP * 0.12
	_service.open_function("")
	await _frames(6)
	_service.call("_open_from_plates", name)
	await _frames(10)
	_look(head, seen)
	await _shot("48_fn_row_first")
	_service.call("_create_from_plates")
	await _frames(10)
	_look(head, seen)
	await _shot("49_fn_row_new")
	_service.call("_open_from_plates", name)
	await _frames(10)
	_look(head, seen)
	await _shot("50_fn_row_back")
	_service.open_function("")
	await _frames(6)


## Trigger down and up on the right hand.
func _click() -> void:
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()


func _card_of(id: int) -> XREBlueprintCanvas.Card:
	for each: XREBlueprintCanvas.Card in _service.canvas.get("_cards") as Array:
		if each.id == id: return each
	return null


## A probe with the saved settings: new blocks from the menu as they appear,
## the trash under the ray, and the trigger held on a wired input.
func _shot_probe(head: Vector3, host: Node3D) -> void:
	var blocks: Array[Dictionary] = [XREBlueprintGraph.make_node(0, "print", Vector2.ZERO), XREBlueprintGraph.make_node(0, "make_array", Vector2.ZERO)]
	var added: Array[int] = []
	for index: int in blocks.size():
		_service.call("_add_from_menu", {"id": "shot:probe_%d" % index, "title": XREBlueprintGraph.title(blocks[index]), "target": null, "block": blocks[index]})
		await _frames(6)
		added.append(int(_service.blueprint.graph.nodes.back()["id"]))
	# An array variable and a dictionary one, as the menu's New Array[int] variable adds them (D-141).
	var at := _service.canvas.get_block_position(added[0]) + Vector3(0, -0.3, 0)
	_service.call("_add_new_variable", {"value": [1, 2, 3] as Array[int], "at": at, "wire": {}}, "doors")
	_service.call("_add_new_variable", {"value": {"open": Color.GREEN} as Dictionary[String, Color], "at": at + Vector3(0.4, 0, 0), "wire": {}}, "lamps")
	await _frames(6)
	print("shot_blueprint_vr: variables %s, last error '%s'" % [_service.blueprint.graph.variables.map(func(variable: Dictionary) -> String: return str(variable["name"])), _service.blueprint.last_error])
	_look(_service.canvas.to_global(at) + _service.canvas.global_basis.z * 0.6, _service.canvas.to_global(at))
	await _shot("40_probe_variables")
	_look(head, host.global_position)
	await _shot("40_probe_overview")
	for id: int in added:
		var card := _card_of(id)
		var face := card.node.global_transform
		var front := face.basis.z.normalized()
		print("shot_blueprint_vr: card %d basis x %s z %s, mirrored %s, canvas z %s" % [id, face.basis.x, face.basis.z, card.node.scale, _service.canvas.global_basis.z])
		_look(face.origin + front * 0.35, face.origin)
		_aim(face.origin, front)
		await _shot("40_probe_card_%d" % id)
		var trash := card.node.to_global(card.trash_point)
		_aim(trash, front)
		await _frames()
		print("shot_blueprint_vr: trash of %d visible %s at %s" % [id, card.trash.visible if card.trash != null else null, trash])
		var distance := _service.canvas.intersect_ray(trash + front * 0.4, -front, 2.0)
		print("shot_blueprint_vr: canvas ray %s: id %d delete %s port %d socket %d pin_row %d wire %d trash scale %s" % [distance, _service.canvas.get_hit_id(), _service.canvas.get_hit_delete(),
				_service.canvas.get_hit_port(), _service.canvas.get_hit_socket(), _service.canvas.get_hit_pin_row(), _service.canvas.get_hit_wire(), card.trash.scale])
		await _shot("40_probe_trash_%d" % id)
		await _click()
		print("shot_blueprint_vr: after the trash click block %d is %s, last error '%s'" % [id, "gone" if _service.blueprint.graph.find_node(id).is_empty() else "still there", _service.blueprint.last_error])
		if not _service.blueprint.graph.find_node(id).is_empty():
			_service.delete_block(id)
			print("shot_blueprint_vr: delete_block(%d) directly: %s, last error '%s'" % [id, "gone" if _service.blueprint.graph.find_node(id).is_empty() else "still there", _service.blueprint.last_error])
		await _frames(6)
	# The trigger held on an input with a wire.
	var graph := _service.blueprint.graph
	for edge: Dictionary in graph.edges:
		var card := _card_of(int(edge["to"]))
		if card == null: continue
		var port := _service.canvas.to_global(_service.canvas.port_position(int(edge["to"]), int(edge["to_port"]), true))
		var front := card.node.global_basis.z.normalized()
		_look(port + front * 0.4, port)
		_aim(port, front)
		await _frames()
		await _shot("40_probe_port")
		var edges := graph.edges.size()
		_right.set_input(&"trigger", 1.0)
		await _frames(4)
		print("shot_blueprint_vr: held on wired input %s of %d: pending %d, edges %d -> %d" % [edge["to_port"], edge["to"], int(_service.get("_pending_id")), edges, graph.edges.size()])
		await _shot("40_probe_port_held")
		_right.set_input(&"trigger", 0.0)
		await _frames(4)
		print("shot_blueprint_vr: let go: pending %d, edges %d" % [int(_service.get("_pending_id")), graph.edges.size()])
		break


## The keyboard typing the block menu's search: the menu opened by a card's
## plus, then by a wire let go in empty space; a click on a key each time.
func _shot_keyboard() -> void:
	var graph := _service.blueprint.graph
	var keyboard := _service.get("_keyboard") as XREPanelSurface
	for from_wire: bool in [false, true]:
		var id: int = graph.nodes[0]["id"]
		if from_wire:
			var edge: Dictionary = graph.edges[0]
			var card := _card_of(int(edge["from"]))
			var front := card.node.global_basis.z.normalized()
			var port := _service.canvas.to_global(_service.canvas.port_position(int(edge["from"]), int(edge["from_port"]), false))
			_aim(port, front)
			await _frames()
			_right.set_input(&"trigger", 1.0)
			await _frames(4)
			_aim(port + front * 0.25 + Vector3.UP * 0.3, front)
			await _frames(4)
			_right.set_input(&"trigger", 0.0)
			await _frames(6)
		else:
			_service.call("_show_block_palette", id)
			await _frames(6)
		# Search… on the ring opens the window where it was (D-094).
		if not _service.is_block_palette_shown():
			_service.call("_choose_offered", {"list": true})
			await _frames(6)
		var window := _service.call("_menu_window") as XREPanelSurface
		print("shot_blueprint_vr: keyboard, from a wire %s: menu shown %s, pending %d" % [from_wire, _service.is_block_palette_shown(), int(_service.get("_pending_id"))])
		if window == null: continue
		var head := window.global_position + window.global_basis.z.normalized() * 0.7
		_look(head, window.global_position)
		_service.block_menu.text_edit_requested.emit(_service.block_menu.search)
		await _frames(6)
		print("shot_blueprint_vr: keyboard shown %s, menu shown %s" % [keyboard.is_visible_in_tree(), _service.is_block_palette_shown()])
		await _shot("41_keyboard_%s_open" % from_wire)
		var key := keyboard.pixel_to_global(keyboard.size_px * Vector2(0.3, 0.5))
		var origin := key + keyboard.global_basis.z.normalized() * 0.3
		_right.set_pose(&"aim", _rig.global_transform.affine_inverse() * Transform3D(Basis.looking_at(key - origin), origin), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
		await _click()
		await _frames(4)
		print("shot_blueprint_vr: after a key: keyboard shown %s, menu shown %s, pending %d" % [keyboard.is_visible_in_tree(), _service.is_block_palette_shown(), int(_service.get("_pending_id"))])
		await _shot("41_keyboard_%s_typed" % from_wire)
		_service.call("_close_inputs")
		_service.close_block_palette()
		_service.cancel_connection()
		_aim(Vector3(-50, 0, 0), Vector3.BACK)
		await _frames(6)


## Collections (D-143) with the mockup's views: a For Each over an array
## variable and Make blocks with grid ports, a dictionary variable, a rack, an
## array of the three cubes; then Stack, Rack and Collection wire. Settings
## change in memory only; the graph's edits are undone by the caller.
func _shot_collections(head: Vector3, host: Node3D) -> void:
	var features := _document.features
	var saved_path := features.path
	features.path = ""
	var keys: Array[StringName] = [XREFeatureSettings.COLLECTION_PORT, XREFeatureSettings.COLLECTION_LITERAL, XREFeatureSettings.COLLECTION_WIRE, XREFeatureSettings.SCENE_COLLECTION]
	var before: Array[StringName] = []
	for key: StringName in keys: before.append(features.get_value(key))
	var doc := _service.blueprint
	var at := _service.canvas.get_block_position(int(doc.graph.nodes[0]["id"])) + Vector3(0.0, 0.5, 0.15)
	_service.call("_add_new_variable", {"value": [1, 2, 5] as Array[int], "at": at, "wire": {}}, "scores")
	_service.call("_add_new_variable", {"value": {"open": Color.GREEN, "closed": Color.RED} as Dictionary[String, Color], "at": at + Vector3(0.45, 0, 0), "wire": {}}, "lamps")
	var ids: Array[int] = []
	for block: Dictionary in [XREBlueprintGraph.make_node(0, "for_each", Vector2.ZERO), XREBlueprintGraph.make_node(0, "make_array", Vector2.ZERO),
			XREBlueprintGraph.make_node(0, "make_dictionary", Vector2.ZERO), XREBlueprintGraph.make_collection(0, "array_pick_random", Vector2.ZERO),
			XREBlueprintGraph.make_collection(0, "dictionary_get", Vector2.ZERO), XREBlueprintGraph.make_node(0, "for_each", Vector2.ZERO)]:
		_service.call("_add_from_menu", {"id": "shot:collections", "title": XREBlueprintGraph.title(block), "target": null, "block": block})
		await _frames(4)
		ids.append(int(doc.graph.nodes.back()["id"]))
	for index: int in ids.size(): _service.canvas.preview_move(ids[index], at + Vector3(0.32 * (index % 3), -0.3 - 0.3 * (index / 3), 0))
	_service.canvas.commit_moves(doc, ids)
	var getter := XREBlueprintGraph.make_node(0, "get_variable", Vector2.ZERO)
	getter["params"]["variable"] = "scores"
	var scores := doc.insert_block(getter, Vector2.ZERO)
	doc.connect_blocks(scores, 0, ids[0], 1)
	getter["params"]["variable"] = "lamps"
	var lamps := doc.insert_block(getter, Vector2.ZERO)
	doc.connect_blocks(lamps, 0, ids[4], 0)
	doc.set_parameter(ids[3], "collection", [1, 2, 5] as Array[int])
	var cubes: Array[Node] = []
	for name: String in ["RedCube", "GreenCube", "BlueCube"]: cubes.append(_document.get_scene_root().get_node(name))
	doc.wire_selection(ids[5], cubes)
	await _frames(8)
	var middle := _service.canvas.to_global(at + Vector3(0.32, -0.45, 0))
	var front := _service.canvas.global_basis.z.normalized()
	for variant: Array in [["50_collections_grid", XREFeatureSettings.GRID, XREFeatureSettings.MAKE, XREFeatureSettings.OFF],
			["51_collections_stack_rack_wire", XREFeatureSettings.STACK, XREFeatureSettings.RACK, XREFeatureSettings.ON]]:
		features.set_value(XREFeatureSettings.COLLECTION_PORT, variant[1])
		features.set_value(XREFeatureSettings.COLLECTION_LITERAL, variant[2])
		features.set_value(XREFeatureSettings.COLLECTION_WIRE, variant[3])
		await _frames(8)
		_look(middle + front * 1.1, middle)
		await _shot(variant[0])
		for index: int in [0, 1, 3, 4]:
			var card := _card_of(ids[index])
			if card == null: continue
			var face := card.node.global_transform
			_look(face.origin + face.basis.z.normalized() * 0.4 - face.basis.x.normalized() * 0.05, face.origin)
			await _shot("%s_card_%d" % [variant[0], index])
	# D-144: the ray on Make Array's [1], its × right of its name; on a puck of scores, the × over it.
	features.set_value(XREFeatureSettings.COLLECTION_PORT, XREFeatureSettings.GRID)
	await _frames(8)
	var make_card := _card_of(ids[1])
	if make_card != null:
		var pin := make_card.node.to_global(make_card.inputs[1])
		var normal := make_card.node.global_basis.z.normalized()
		_aim(pin, normal)
		_look(pin + normal * 0.35 + make_card.node.global_basis.x.normalized() * 0.05, pin)
		await _frames(4)
		await _shot("52_make_pin_mark")
	for box: XREBlueprintBoxes.Box in _service.canvas.get_boxes().get("_boxes") as Array:
		if box.name != "scores" or box.item_points.is_empty(): continue
		# The head first: the box turns to it (D-090), then the ray at its puck as it stands.
		var puck := box.node.global_transform * box.item_points[0]
		_look(puck + box.node.global_basis.z.normalized() * 0.3 + box.node.global_basis.x.normalized() * 0.04, puck)
		await _frames(4)
		_aim(box.node.global_transform * box.item_points[0], box.node.global_basis.z.normalized())
		await _frames(4)
		await _shot("53_box_item_mark")
	# The rack's plus under the ray, then a click (Rack is on from the last variant).
	features.set_value(XREFeatureSettings.COLLECTION_PORT, XREFeatureSettings.STACK)
	var rack_card := _card_of(ids[3])
	if rack_card != null:
		var plus := rack_card.node.to_global(rack_card.rack_plus_point)
		var normal := rack_card.node.global_basis.z.normalized()
		_aim(plus, normal)
		await _frames(3)
		print("shot_blueprint_vr: rack %s, ray on the plus: id %d plus %s rack %s" % [rack_card.rack_rect, _service.canvas.get_hit_id(), _service.canvas.get_hit_rack_plus(), _service.canvas.get_hit_rack()])
		await _click()
		print("shot_blueprint_vr: after the plus: %s, error '%s'" % [(doc.graph.find_node(ids[3])["params"] as Dictionary).get("collection"), doc.last_error])
		_aim(Vector3(-50, 0, 0), Vector3.BACK)
	features.set_value(XREFeatureSettings.SCENE_COLLECTION, XREFeatureSettings.ON)
	_look(head, host.global_position)
	await _frames(6)
	await _shot("52_collections_scene_array")
	for index: int in keys.size(): features.set_value(keys[index], before[index])
	features.path = saved_path


func _run() -> void:
	for frame: int in 600:
		await get_tree().process_frame
		if _document.get_scene_root() != null and not EditorInterface.get_resource_filesystem().is_scanning(): break
	var scene := _document.get_scene_root() as Node3D
	if scene == null:
		printerr("shot_blueprint_vr: no scene")
		get_tree().quit(1)
		return
	DirAccess.make_dir_recursive_absolute(FOLDER)
	for key: StringName in XREFeatureSettings.DEFINITIONS:
		print("shot_blueprint_vr: setting %s = %s" % [key, _document.features.get_value(key)])
	_right = XRControllerTracker.new()
	_right.name = &"right_hand"
	_right.type = XRServer.TRACKER_CONTROLLER
	_left = XRControllerTracker.new()
	_left.name = &"left_hand"
	_left.type = XRServer.TRACKER_CONTROLLER
	XRServer.add_tracker(_right)
	XRServer.add_tracker(_left)
	for tracker: XRControllerTracker in [_left, _right]:
		tracker.set_pose(&"aim", Transform3D(Basis.IDENTITY, Vector3(-50, 0, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	_rig = XRERig.new()
	_viewport = SubViewport.new()
	_viewport.size = SIZE
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport.world_3d = scene.get_world_3d()
	_viewport.msaa_3d = Viewport.MSAA_4X
	_viewport.add_child(_rig)
	add_child(_viewport)
	_rig.camera.current = true
	_rig.camera.fov = 90.0
	var icons := XREIcons.new(_document, _rig)
	_rig.add_child(icons)
	var palette := XREPalette.new(_document, _rig)
	_rig.add_child(palette)
	var panels := XREPanels.new(_document, _rig, palette, EditorInterface.get_editor_theme(), 1.0)
	_rig.add_child(panels)
	_service = XREBlueprints.new(_document, _rig, icons, EditorInterface.get_editor_theme())
	_rig.add_child(_service)
	panels.set_blueprints(_service)
	# XRE_SHOT_HOST names another object of the scene whose graph to shoot.
	var host_name := OS.get_environment("XRE_SHOT_HOST") if OS.has_environment("XRE_SHOT_HOST") else "GreenCube"
	var host := scene.get_node_or_null(NodePath(host_name)) as Node3D
	if host == null:
		printerr("shot_blueprint_vr: no " + host_name)
		get_tree().quit(1)
		return
	# Standing about where the user stood: a step back from the table, eyes at 1.6 m.
	var head := Vector3(host.global_position.x - 0.1, 1.6, host.global_position.z + 1.1)
	_look(head, host.global_position)
	_document.select([host], XREDocument.Source.TOOL)
	await _frames()
	_service.open_selected()
	await _frames(10)
	var start := _service.blueprint.history.get_version()
	# XRE_SHOT_ONLY=pins shoots only the cards whose pins change (D-140).
	# XRE_SHOT_ONLY=functions shoots only the graph's own functions (docs/blueprint_functions.md).
	if OS.get_environment("XRE_SHOT_ONLY") in ["pins", "probe", "keyboard", "collections", "functions", "stats"]:
		match OS.get_environment("XRE_SHOT_ONLY"):
			"pins": await _shot_pins()
			"probe": await _shot_probe(head, host)
			"keyboard": await _shot_keyboard()
			"collections": await _shot_collections(head, host)
			"functions": await _shot_functions()
			"stats": await _stats()
		while _service.blueprint.history.get_version() > start: _service.blueprint.undo()
		await _frames()
		print("shot_blueprint_vr: done, graph back to version %d" % _service.blueprint.history.get_version())
		get_tree().quit(0)
		return
	_look(head, host.global_position)
	await _shot("01_overview")
	var cards := _service.canvas.get("_cards") as Array
	await _shot_sides(head, cards)
	for card: XREBlueprintCanvas.Card in cards:
		var face := card.node.global_transform
		_look(face.origin + face.basis.z.normalized() * 0.35, face.origin)
		await _shot("02_card_%d" % card.id)
	# Each card again under the ray: in focus, with its trash as Node style shows it (D-099).
	for card: XREBlueprintCanvas.Card in cards:
		var face := card.node.global_transform
		_aim(face.origin, face.basis.z.normalized())
		_look(face.origin + face.basis.z.normalized() * 0.35, face.origin)
		await _shot("02b_card_%d_focus" % card.id)
	_aim(Vector3(-50, 0, 0), Vector3.BACK)
	# The ray from a hand below and to the right onto a card in focus: it must stay over the card, its ports and tokens.
	var target_card := cards[1] as XREBlueprintCanvas.Card
	var card_pose := target_card.node.global_transform
	var eye := card_pose.origin + card_pose.basis.z.normalized() * 0.6
	_look(eye, card_pose.origin)
	var hand_point := eye + Vector3(0.15, -0.3, -0.05)
	_right.set_pose(&"aim", Transform3D(Basis.looking_at(card_pose.origin - hand_point), hand_point), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
	await _shot("24_ray_on_card")
	_aim(Vector3(-50, 0, 0), Vector3.BACK)
	_look(head, host.global_position)
	await _shot("03_objects")
	_look(head.lerp(host.global_position, 0.6), host.global_position)
	await _shot("04_objects_close")
	_service.call("_open_petals", 1, host, host.global_position)
	_look(head, host.global_position)
	await _shot("05_petals")
	_look(head.lerp(host.global_position, 0.5), host.global_position + Vector3(0.1, 0.1, 0))
	await _shot("06_petals_close")
	(_service.get("_petals") as XREBlueprintPetals).close()
	_document.select([], XREDocument.Source.TOOL)
	await _frames()
	_look(head, host.global_position)
	await _shot("07_member_petals")
	_look(head + Vector3(0.5, 0, 0), host.global_position)
	await _shot("08_member_petals_side")
	# A click on Rotate X's connected In port, then the ray off to the side.
	var front := (cards[1] as XREBlueprintCanvas.Card).node.global_basis.z.normalized()
	var port := _service.canvas.to_global(_service.canvas.port_position(2, 0, true))
	_aim(port, front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames()
	_right.set_input(&"trigger", 0.0)
	await _frames()
	_aim(port + Vector3(0.0, -0.25, 0.1), front)
	_look(port + front * 0.6 + Vector3(0, 0.1, 0), port)
	await _shot("09_port_click")
	_service.cancel_connection()
	await _frames()
	# A click on the Angle token: the keyboard.
	var token := _service.canvas.token_transform(2, "angle").origin
	_aim(token, front)
	await _frames()
	_right.set_input(&"trigger", 1.0)
	await _frames(2)
	_right.set_input(&"trigger", 0.0)
	await _frames(6)
	_aim(Vector3(-50, 0, 0), front)
	_look(token + front * 0.6 + Vector3(0, 0.1, 0), token)
	await _shot("10_keyboard")
	_look(head, token)
	await _shot("11_keyboard_far")
	(_service.get("_keyboard") as XREVirtualKeyboard).close()
	# The Vector window of a vector token, the rest dimmed (D-061).
	var editor := _service.get("_token_editor") as XREBlueprintTokenEditor
	var vector_block := -1
	for block: Dictionary in _service.blueprint.graph.nodes:
		if (block["params"] as Dictionary).get("value") is Vector3: vector_block = block["id"]
	if vector_block < 0:
		# A graph without one gets a Set position, undone with the rest before the editor quits.
		_service.add_block("set_property")
		await _frames(3)
		vector_block = _service.blueprint.graph.nodes.back()["id"]
		_service.blueprint.choose_target(vector_block, host)
		_service.call("_set_token", vector_block, "property", "position", "Set Token")
		_service.call("_set_token", vector_block, "value", Vector3(1, 0.5, 0), "Set Token")
		await _frames(3)
	if vector_block >= 0:
		_look(head, host.global_position)
		await _frames()
		_service.call("_open_vector", vector_block, "value", "", Vector3(1, 0.5, 0))
		await _frames(4)
		var vector_window := panels.find_window(XREBlueprintVectorTab)
		if vector_window != null:
			var at := vector_window.global_position
			_look(at + vector_window.global_basis.z * 0.75 + Vector3(0.1, 0.1, 0), at)
			await _shot("12_vector_window")
			editor.begin_pull(1)
			editor.pull_to(1, 0.1, 0.0)
			await _shot("12b_vector_pulled")
			_look(head, at)
			await _shot("12c_vector_dimmed")
			# The keypad of one axis, low on the window, square to the eyes (D-067).
			_service.vector_panel.get_component_button(1).pressed.emit()
			await _frames(4)
			_look(head, (_service.get("_keyboard") as Node3D).global_position.lerp(at, 0.5))
			await _shot("12d_vector_axis_keypad")
			(_service.get("_keyboard") as XREVirtualKeyboard).close()
			_service.set("_token_edit", {})
			panels.call("_close_window", vector_window)
			await _frames(3)
	# The number line of a number held by the trigger (D-062).
	var number_pose := Transform3D(XREPanels.facing(token, head, Vector3.UP), token)
	editor.open_dial(number_pose, 1.5)
	editor.line_to(0.05, 0.0)
	_look(token + front * 0.5 + Vector3(0, 0.05, 0), token)
	await _shot("16_number_line")
	# A Delay's line begins at zero (D-064).
	editor.open_dial(number_pose, 0.0, 0.0)
	editor.line_to(0.05, 0.0)
	await _shot("16b_number_line_zero")
	editor.close()
	# The block menu: the chips, the row of sections, the search (D-063).
	_service.open_block_menu()
	await _frames(6)
	var menu_window := panels.find_window(XREBlueprintPaletteTab)
	if menu_window != null:
		_look(menu_window.global_position + menu_window.global_basis.z * 0.7, menu_window.global_position)
		await _shot("17_block_menu")
	_service.close_block_palette()
	await _frames(3)
	await _shot_d090(head, host)
	# The Color window (D-064): the 2D picker, then the globe of colors; the user's setting back.
	var colors := _document.features.get_value(XREFeatureSettings.COLOR_INPUT)
	_look(head, host.global_position)
	_service.add_block("equals")
	await _frames(4)
	var equal: int = _service.blueprint.graph.nodes.back()["id"]
	_service.call("_set_token", equal, "a", Color("3399e6"), "Set Token")
	await _frames(4)
	for mode: StringName in [XREFeatureSettings.PICKER, XREFeatureSettings.GLOBE]:
		_document.features.set_value(XREFeatureSettings.COLOR_INPUT, mode)
		_look(head, host.global_position)
		await _frames()
		_service.call("_open_color", equal, "a", "", Color("3399e6"))
		await _frames(6)
		var color_window := panels.find_window(XREBlueprintColorTab)
		if color_window == null: continue
		var at := color_window.global_position
		_look(head, at)
		await _shot("18_color_%s" % mode)
		if mode == XREFeatureSettings.GLOBE:
			editor.turn_globe(0.9, 0.35)
			_look(at + color_window.global_basis.z * 0.45 + Vector3(0.05, 0.05, 0), at)
			await _shot("18b_color_globe_turned")
			# The pipette in the right hand instead of its controller (D-065), aimed at the cards.
			_look(head, at)
			var hand_at := head + (at - head) * 0.75 + _rig.camera.global_basis.x * 0.14
			var aim_basis := Basis.looking_at(host.global_position - hand_at, Vector3.UP)
			_right.set_pose(&"aim", Transform3D(aim_basis, hand_at), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
			_right.set_pose(&"grip", Transform3D(aim_basis, hand_at + aim_basis.z * 0.05), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
			_service.color_panel.get_pipette_button().toggled.emit(true)
			await _frames(4)
			_look(head, hand_at)
			await _shot("18c_pipette")
			print("shot_blueprint_vr: Color window pixel ", color_window.color_at_pixel(Vector2(20, color_window.size_px.y * 0.5)), " right controller shown ", _rig.right_controller.is_model_shown())
			_service.color_panel.get_pipette_button().toggled.emit(false)
			_right.set_pose(&"aim", Transform3D(Basis.IDENTITY, Vector3(-50, 0, 0)), Vector3.ZERO, Vector3.ZERO, XRPose.XR_TRACKING_CONFIDENCE_HIGH)
		panels.call("_close_window", color_window)
		await _frames(3)
	_document.features.set_value(XREFeatureSettings.COLOR_INPUT, colors)
	# Operators as Unreal draws them (D-065), beside Equal: an integer into Add, a vector scaled, a comparison, logic.
	var values := _document.features.get_value(XREFeatureSettings.VALUE_INPUT)
	_document.features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PUCKS)
	var graph := _service.blueprint.graph
	var corner: Vector2 = graph.find_node(equal)["position"]
	var count := _service.blueprint.insert_block(XREBlueprintGraph.make_node(0, "value", Vector2.ZERO), corner + Vector2(-320, 170))
	_service.blueprint.set_parameter(count, "value", 4)
	var sum := _service.blueprint.insert_block(XREBlueprintGraph.make_operator(0, "add", Vector2.ZERO), corner + Vector2(0, 170))
	_service.blueprint.connect_blocks(count, 0, sum, 0)
	var scaled := _service.blueprint.insert_block(XREBlueprintGraph.make_operator(0, "multiply", Vector2.ZERO), corner + Vector2(0, 330))
	_service.blueprint.set_parameter(scaled, "a", Vector3(1, 2, 3))
	_service.blueprint.set_parameter(scaled, "b", 2.0)
	_service.blueprint.insert_block(XREBlueprintGraph.make_operator(0, "less_equal", Vector2.ZERO), corner + Vector2(260, 170))
	_service.blueprint.insert_block(XREBlueprintGraph.make_operator(0, "and", Vector2.ZERO), corner + Vector2(260, 330))
	_service.blueprint.insert_block(XREBlueprintGraph.make_operator(0, "not", Vector2.ZERO), corner + Vector2(500, 330))
	await _frames(6)
	var middle := _service.canvas.to_global(_service.canvas.get_block_position(sum))
	_look(middle + _service.canvas.global_basis.z * 0.55 + Vector3(0.12, 0.05, 0), middle + Vector3(0.12, -0.05, 0))
	await _shot("19_operators")
	# A variable's start value is a puck, with plugs too.
	var variables := _document.features.get_value(XREFeatureSettings.VARIABLE_INPUT)
	_document.features.set_value(XREFeatureSettings.VALUE_INPUT, XREFeatureSettings.PLUGS)
	_document.features.set_value(XREFeatureSettings.VARIABLE_INPUT, XREFeatureSettings.BOXES)
	await _frames(6)
	if not graph.variables.is_empty():
		var box := _service.canvas.to_global(_service.canvas.get_boxes().box_point(str(graph.variables[0]["name"])))
		_look(box + _service.canvas.global_basis.z * 0.35 + Vector3(0.05, 0.08, 0), box)
		await _shot("20_variable_box")
		# Close enough to see its rim over the lid (D-114).
		_look(box + _service.canvas.global_basis.z * 0.12, box)
		await _shot("20b_variable_box_close")
	_document.features.set_value(XREFeatureSettings.VALUE_INPUT, values)
	_document.features.set_value(XREFeatureSettings.VARIABLE_INPUT, variables)
	await _frames(3)
	var tray := panels.find_window(XREBlueprintTokensTab)
	if tray != null:
		_look(tray.global_position + tray.global_basis.z * 0.6, tray.global_position)
		await _shot("13_tray")
	# Targets as adapters, then the user's setting back.
	var targets := _document.features.get_value(XREFeatureSettings.TARGET_INPUT)
	_document.features.set_value(XREFeatureSettings.TARGET_INPUT, XREFeatureSettings.ADAPTER)
	await _frames(6)
	_look(head, host.global_position)
	await _shot("14_adapters")
	for card: XREBlueprintCanvas.Card in _service.canvas.get("_cards") as Array:
		var frame := card.node.global_transform
		_look(frame.origin + frame.basis.z.normalized() * 0.4 - frame.basis.x.normalized() * 0.1, frame.origin)
		await _shot("15_adapter_card_%d" % card.id)
	_document.features.set_value(XREFeatureSettings.TARGET_INPUT, targets)
	print("shot_blueprint_vr: dimmer shown ", (_service.get("_dimmer") as Node3D).is_visible_in_tree())
	_service.cancel_connection()
	_service.close_block_palette()
	# Branch, Get Time and Random under the ray, as Node style and Node shrink show them (D-106).
	var extras: Array[Dictionary] = [XREBlueprintGraph.make_node(0, "branch", Vector2.ZERO),
			XREBlueprintGraph.make_call(0, XREBlueprintFunctions.static_function("XREBlueprintLibrary", "get_time"), Vector2.ZERO),
			XREBlueprintGraph.make_call(0, XREBlueprintFunctions.global("randi_range"), Vector2.ZERO)]
	for index: int in extras.size():
		_service.call("_add_from_menu", {"id": "shot:extra_%d" % index, "title": XREBlueprintGraph.title(extras[index]), "target": null, "block": extras[index]})
		await _frames(6)
		var added_id: int = _service.blueprint.graph.nodes.back()["id"]
		var extra: XREBlueprintCanvas.Card = null
		for card: XREBlueprintCanvas.Card in _service.canvas.get("_cards") as Array:
			if card.id == added_id: extra = card
		if extra == null: continue
		var spot := extra.node.global_transform
		_aim(spot.origin, spot.basis.z.normalized())
		_look(spot.origin + spot.basis.z.normalized() * 0.5, spot.origin)
		await _shot("23_extra_%d_focus" % index)
		_aim(Vector3(-50, 0, 0), Vector3.BACK)
		# Each where the one before stood: taken back before the next.
		_service.blueprint.undo()
		await _frames(3)
	# An engine method's card, Rotate X, under the ray: its class's icon on the header's circle (D-099).
	_service.call("_add_from_menu", {"id": "shot:rotate_x", "title": "Rotate X", "target": null,
			"block": XREBlueprintGraph.make_call(0, XREBlueprintFunctions.method("Node3D", "rotate_x"), Vector2.ZERO)})
	await _frames(6)
	var added := _service.canvas.get("_cards") as Array
	var rotate := added.back() as XREBlueprintCanvas.Card
	var at := rotate.node.global_transform
	_aim(at.origin, at.basis.z.normalized())
	_look(at.origin + at.basis.z.normalized() * 0.35, at.origin)
	await _shot("22_engine_method_focus")
	_aim(Vector3(-50, 0, 0), Vector3.BACK)
	while _service.blueprint.history.get_version() > start: _service.blueprint.undo()
	await _frames()
	print("shot_blueprint_vr: done, graph back to version %d" % _service.blueprint.history.get_version())
	get_tree().quit(0)
