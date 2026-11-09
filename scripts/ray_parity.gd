extends RefCounted
## Checks [method XREBlueprintCanvas.intersect_ray] says the same with its cards' reach (D-158) as with none,
## over a grid of rays around every card: for the graph tests, as each of them leaves the canvas.

## All that [method XREBlueprintCanvas.intersect_ray] notes of a ray.
const FIELDS: Array[String] = ["_hit_id", "_hit_port", "_hit_input", "_hit_plus", "_hit_delete", "_hit_swap", "_hit_copy", "_hit_open", "_hit_pure",
	"_button_distance", "_hit_pin_plus", "_hit_pin_mark", "_hit_hidden_chip", "_hit_rack", "_hit_rack_plus", "_rack_card", "_hit_pin_row", "_pin_row_card",
	"_pin_distance", "_hit_edge", "_hit_height", "_hit_socket", "_hit_finished", "_hit_box", "_hit_wire", "_hit_bend", "_hit_piece", "_hit_wire_point"]
## Rays each way across a card's reach.
const GRID := 11


## The distance and all [constant FIELDS] for a ray.
static func outcome(canvas: XREBlueprintCanvas, origin: Vector3, direction: Vector3, maximum: float) -> Array:
	var result: Array = [canvas.intersect_ray(origin, direction, maximum)]
	for field: String in FIELDS: result.append(canvas.get(field))
	return result


## The first ray that says otherwise as a text, or empty: as the canvas stands, then with every button of every card
## shown and at the largest scale a hover gives it. Also that repeating a ray says the same.
static func first_difference(canvas: XREBlueprintCanvas) -> String:
	var as_it_stands := _compare(canvas)
	if not as_it_stands.is_empty(): return as_it_stands
	var parts: Array[Node3D] = []
	var scales: Array[Vector3] = []
	var shown: Array[bool] = []
	for card: XREBlueprintCanvas.Card in canvas.get("_cards") as Array:
		for part: Node3D in _buttons_of(card):
			parts.append(part)
			scales.append(part.scale)
			shown.append(part.visible)
			part.visible = true
			part.scale = Vector3.ONE * XREBlueprintCanvas.HOVER_SCALE
		for socket: XREBlueprintCanvas.Socket in card.sockets:
			parts.append(socket.visual)
			scales.append(socket.visual.scale)
			shown.append(socket.visual.visible)
			socket.visual.scale = socket.base_scale * XREBlueprintCanvas.HOVER_SCALE
	var hovered := _compare(canvas)
	for index: int in parts.size():
		parts[index].scale = scales[index]
		parts[index].visible = shown[index]
	return hovered


static func _buttons_of(card: XREBlueprintCanvas.Card) -> Array[Node3D]:
	var parts: Array[Node3D] = [card.trash]
	parts.append_array(card.plus_faces)
	parts.append_array(card.ports)
	for part: Node3D in [card.swap, card.copy, card.open, card.pure_switch, card.pin_plus, card.hidden_chip]:
		if part != null: parts.append(part)
	for mark: Node3D in card.pin_marks:
		if mark != null: parts.append(mark)
	return parts


static func _compare(canvas: XREBlueprintCanvas) -> String:
	var cards := canvas.get("_cards") as Array
	var origins := PackedVector3Array()
	var directions := PackedVector3Array()
	var culled: Array[Array] = []
	for card: XREBlueprintCanvas.Card in cards:
		# Asks the card its reach.
		canvas.intersect_ray(card.node.global_position + Vector3.BACK, Vector3.FORWARD, 5.0)
		var spread := card.reach.grow(0.03)
		var to_global := canvas.global_transform * card.node.transform
		for column: int in GRID:
			for row: int in GRID:
				var point := spread.position + Vector3(spread.size.x * column / (GRID - 1.0), spread.size.y * row / (GRID - 1.0), spread.size.z * 0.5)
				var target := to_global * point
				var front := to_global.basis.z.normalized()
				for from: Vector3 in [front, -front, (front + to_global.basis.x.normalized() * 0.6).normalized(), (front - to_global.basis.y.normalized() * 0.6).normalized()]:
					origins.append(target + from * 0.8)
					directions.append(-from)
					culled.append(outcome(canvas, target + from * 0.8, -from, 5.0))
	for index: int in origins.size():
		if outcome(canvas, origins[index], directions[index], 5.0) != culled[index]:
			return "a repeated ray said otherwise from %s along %s" % [origins[index], directions[index]]
	for card: XREBlueprintCanvas.Card in cards:
		card.reach = AABB(-Vector3.ONE * 1000.0, Vector3.ONE * 2000.0)
		card.reach_known = true
	var difference := ""
	for index: int in origins.size():
		var whole := outcome(canvas, origins[index], directions[index], 5.0)
		if whole != culled[index]:
			difference = "from %s along %s the reach says %s, without it %s" % [origins[index], directions[index], culled[index], whole]
			break
	for card: XREBlueprintCanvas.Card in cards: card.reach_known = false
	return difference
