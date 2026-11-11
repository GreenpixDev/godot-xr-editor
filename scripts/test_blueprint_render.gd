extends SceneTree
## Optional GPU regression: graph/outline/contact occlusion in a normal renderer.
## Run without --headless or XR; check.sh only parses it (dummy rendering has no pixels).

## An empty document, for tabs drawn only to be looked at.
class EmptyDocument extends XREDocument:
	func get_scene_root() -> Node: return null
	func get_selection() -> Array[Node]: return []
	func select(_nodes: Array[Node], _source: Source) -> void: pass
	func preview_transform(_node: Node3D, _xform: Transform3D) -> void: pass
	func commit_transforms(_nodes: Array[Node3D], _befores: Array[Transform3D], _source: Source) -> void: pass
	func set_property(_object: Object, _property: StringName, _value: Variant, _source: Source) -> void: pass
	func preview_property(_object: Object, _property: StringName, _value: Variant) -> void: pass
	func commit_property(_object: Object, _property: StringName, _before: Variant, _source: Source) -> void: pass
	func add_node(_node: Node, _parent: Node, _source: Source) -> void: pass
	func remove_nodes(_nodes: Array[Node], _source: Source) -> void: pass
	func duplicate_nodes(_nodes: Array[Node], _move: Transform3D, _source: Source) -> Array[Node]: return []
	func _add_pasted(_pasted: Array[Node], _root: Node, _source: Source) -> void: pass
	func save(_source: Source) -> Error: return OK
	func open_scene(_path: String, _source: Source) -> Error: return OK
	func list_folder(_path: String) -> PackedStringArray: return PackedStringArray()
	func get_file_type(_path: String) -> StringName: return &""
	func play(_source: Source, _separate_app: bool) -> Error: return OK
	func stop_playing(_source: Source) -> void: pass
	func is_playing() -> bool: return false
	func get_snap() -> XRESnap: return XRESnap.new(false, 0.0, 0.0, 0.0)


## Pixels of a 1024 × 768 picture Merged may draw otherwise than Per node: wire tips in ports (D-168).
const MERGE_PIXELS := 16

var _checks := 0
var _failures := 0
var _viewport: SubViewport
var _camera: Camera3D


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		printerr("test_blueprint_render: FAILED " + message)


func _capture(name: String) -> Image:
	for frame: int in 5: await process_frame
	await RenderingServer.frame_post_draw
	var result := _viewport.get_texture().get_image()
	result.save_png("res://build/blueprint_render_" + name + ".png")
	return result


func _white_at(image: Image, point: Vector3) -> bool:
	var pixel := Vector2i(_camera.unproject_position(point))
	for y: int in range(pixel.y - 2, pixel.y + 3):
		for x: int in range(pixel.x - 2, pixel.x + 3):
			var color := image.get_pixel(x, y)
			if minf(color.r, minf(color.g, color.b)) > 0.8: return true
	return false


## Graph drawing (D-168): a graph drawn Merged looks as drawn Per node, pixel for pixel within the vertex
## colours' 8 bits, as it is, with a card in focus over everything and with sphere ports
## (build/blueprint_render_drawing_*.png). Allowed: a few pixels where a wire's tip goes into its port, as the
## wire and the card's ports are now sorted as two see-through objects, not as the wire and each port.
func _test_graph_drawing() -> void:
	var camera_before := _camera.transform
	var size_before := _camera.size
	var graph := XREBlueprintGraph.new()
	graph.nodes = [
		XREBlueprintGraph.make_node(1, "ready", Vector2(-260, -60)),
		XREBlueprintGraph.make_node(2, "branch", Vector2(60, -60)),
		XREBlueprintGraph.make_node(3, "value", Vector2(-260, 140)),
		XREBlueprintGraph.make_node(4, "print", Vector2(160, 160)),
	]
	graph.edges = [{"from": 1, "from_port": 0, "to": 2, "to_port": 0}, {"from": 3, "from_port": 0, "to": 4, "to_port": 1}]
	graph.upgrade()
	var canvas := XREBlueprintCanvas.new()
	_viewport.add_child(canvas)
	canvas.set_arrow_modes(XREFeatureSettings.OFF, XREFeatureSettings.OFF, false)
	canvas.rebuild(graph)
	# Placed after the rebuild, which puts the canvas where its graph says.
	canvas.position = Vector3(-40.0, 0.0, 0.0)
	canvas.face_user(canvas.to_global(Vector3(0.0, 0.0, 1.0)))
	_camera.transform = Transform3D(Basis.IDENTITY, Vector3(-40.0, 0.0, 1.0))
	_camera.size = 0.8
	_camera.current = true
	for look: int in 4:
		var focused := look == 1
		if look == 1:
			canvas.set_focus_modes(XREFeatureSettings.FRONT, XREFeatureSettings.DIM)
			canvas.hover_actions(2, false, false, true)
		if look == 2:
			# Sphere ports, shaded as wires are: the merge's other look.
			canvas.hover_actions(-1, false, false, true)
			canvas.set_port_display(XREFeatureSettings.SPHERE)
			canvas.rebuild(graph)
			canvas.position = Vector3(-40.0, 0.0, 0.0)
			canvas.face_user(canvas.to_global(Vector3(0.0, 0.0, 1.0)))
		if look == 3:
			# Archetypes, the default style, on BlueCube's graph: faces, bands, icons, tokens (D-170).
			canvas.set_port_display(XREFeatureSettings.FLAT)
			canvas.set_style(XREFeatureSettings.ARCHETYPES)
			var cube: XREBlueprintGraph = load("res://benchmarks/blue_cube_blueprint_2.tres")
			canvas.center_graph(cube)
			canvas.rebuild(cube)
			canvas.position = Vector3(-40.0, 0.0, 0.0)
			var head := canvas.to_global(Vector3(0.0, 0.0, 1.5))
			canvas.face_user(head)
			_camera.transform = Transform3D(Basis.looking_at(canvas.global_position - head), head)
			_camera.size = 1.2
		var images: Array[Image] = []
		# Graph drawing, and with the text merged (D-171).
		var modes: Array[StringName] = [XREFeatureSettings.PER_NODE, XREFeatureSettings.MERGED, XREFeatureSettings.CARD_MERGED, &"text", &"card_merged_text"]
		for mode: StringName in modes:
			canvas.set_merge_mode(XREFeatureSettings.PER_NODE if mode == &"text" else XREFeatureSettings.CARD_MERGED if mode == &"card_merged_text" else mode)
			canvas.set_text_merging(mode in [&"text", &"card_merged_text"])
			images.append(await _capture("drawing_%s_%s" % [["plain", "focus", "spheres", "archetypes"][look], mode]))
		canvas.set_text_merging(false)
		var drawn := 0
		for y: int in range(0, images[0].get_height(), 4):
			for x: int in range(0, images[0].get_width(), 4):
				if not images[0].get_pixel(x, y).is_equal_approx(images[0].get_pixel(0, 0)): drawn += 1
		_check(drawn > 200, "the graph is in view: %d sampled pixel(s) not the background" % drawn)
		for index: int in [1, 2, 3, 4]:
			var differ := 0
			var most := 0.0
			var mask := Image.create(images[0].get_width(), images[0].get_height(), false, Image.FORMAT_RGB8)
			for y: int in images[0].get_height():
				for x: int in images[0].get_width():
					var a := images[0].get_pixel(x, y)
					var b := images[index].get_pixel(x, y)
					var delta := maxf(absf(a.r - b.r), maxf(absf(a.g - b.g), absf(a.b - b.b)))
					most = maxf(most, delta)
					if delta > 3.0 / 255.0:
						differ += 1
						mask.set_pixel(x, y, Color.WHITE)
			mask.save_png("res://build/blueprint_render_drawing_%s_%s_diff.png" % [["plain", "focus", "spheres", "archetypes"][look], modes[index]])
			print("test_blueprint_render: %s, %s: %d pixel(s) differ, at most by %.0f/255" % [["as it is", "a card in focus", "sphere ports", "archetypes on BlueCube"][look], modes[index], differ, most * 255.0])
			_check(differ <= MERGE_PIXELS and canvas.merged_count(2) > 0, "%s, %s draws as Per node: %d pixel(s) differ, at most by %.0f/255"
					% [["as it is", "a card in focus", "sphere ports", "archetypes on BlueCube"][look], modes[index], differ, most * 255.0])
	canvas.queue_free()
	_camera.transform = camera_before
	_camera.size = size_before


## Corner handles of a window over the logic veil (D-040), looked at away from everything else.
func _test_window_handles() -> void:
	var camera_before := _camera.position
	var window := XREPanelSurface.new(Vector2(200, 120), 0.001, 1.5, null)
	window.add_corner_handles()
	window.set_overlay(true)
	_viewport.add_child(window)
	window.position = Vector3(5, 5, -0.2)
	_camera.position = Vector3(5, 5, 2)
	var arm := XREPanelSurface.HANDLE_GAP + XREPanelSurface.HANDLE_WIDTH * 0.5
	var lit := window.to_global(Vector3(window.size_m.x * 0.5 + arm, -window.size_m.y * 0.5 + 0.02, 0))
	var unlit := window.to_global(Vector3(-window.size_m.x * 0.5 - arm, window.size_m.y * 0.5 - 0.02, 0))
	var hover := func() -> void: window.hover_handles(XREPanelSurface.Corner.BOTTOM_RIGHT)
	process_frame.connect(hover)
	var shown := await _capture("window_handles")
	process_frame.disconnect(hover)
	_check(_white_at(shown, lit), "the lit corner handle shows over the logic veil")
	var unlit_color := shown.get_pixelv(Vector2i(_camera.unproject_position(unlit)))
	var background := shown.get_pixelv(Vector2i(_camera.unproject_position(window.to_global(Vector3(0.0, window.size_m.y * 0.5 + 0.06, 0)))))
	_check(not _white_at(shown, unlit) and unlit_color.r > background.r + 0.1, "the other handles show, dimmer")
	var hidden := await _capture("window_handles_hidden")
	_check(not _white_at(hidden, lit) and absf(hidden.get_pixelv(Vector2i(_camera.unproject_position(unlit))).r - background.r) < 0.02,
			"the handles hide when no ray is on the window")
	window.queue_free()
	_camera.position = camera_before


## D-045: the Objects window shows its miniatures over a see-through frame,
## named under them (build/blueprint_render_objects.png); a wire a click would
## detach is drawn thicker, not in another color.
func _test_objects_and_wire() -> void:
	var camera_before := _camera.transform
	var size_before := _camera.size
	var document := EmptyDocument.new()
	var rig := XRERig.new()
	_viewport.add_child(rig)
	# The rig's own camera isn't the one looking here.
	rig.camera.current = false
	_camera.current = true
	var palette := XREPalette.new(document, rig)
	rig.add_child(palette)
	var tab := XREObjectsTab.new(document)
	var window := XREPanelWindow.new(tab, tab.get_window_size(), XREPanels.WINDOW_PIXEL_SIZE, 2.0, null)
	_viewport.add_child(window)
	window.position = Vector3(40.0, 0.0, 0.0)
	palette.set_host(window, tab)
	_camera.transform = Transform3D(Basis.IDENTITY, Vector3(40.0, 0.0, 1.0))
	_camera.size = 0.5
	var image := await _capture("objects")
	var box_at := palette.get_item_transform(&"CSGBox3D").origin
	var box := image.get_pixelv(Vector2i(_camera.unproject_position(box_at)))
	var cell := image.get_pixelv(Vector2i(_camera.unproject_position(box_at + Vector3(0.035, 0.0, 0.0))))
	var frame := image.get_pixelv(Vector2i(_camera.unproject_position(window.to_global(Vector3(0.0, -window.size_m.y * 0.5 + 0.005, 0.0)))))
	var outside := image.get_pixelv(Vector2i(_camera.unproject_position(window.to_global(Vector3(0.0, -window.size_m.y * 0.5 - 0.03, 0.0)))))
	_check(absf(box.v - cell.v) > 0.03, "a miniature is drawn in front of its cell: %s over %s" % [box, cell])
	_check(frame.v < outside.v and frame.v > XREPanelSurface.META_WINDOW_COLOR.v + 0.05, "over a see-through frame: %s, outside %s" % [frame, outside])
	palette.set_host(null, null)
	window.queue_free()
	rig.queue_free()
	_camera.current = true

	var thin := XREBlueprintCanvas.new()
	_viewport.add_child(thin)
	var wires: Array[XREGraphWire] = []
	for row: int in 2:
		var wire := thin.create_scene_wire(Color.ORANGE)
		var y := 0.05 - row * 0.1
		wire.update_curve(Vector3(39.8, y, 0.0), Vector3.RIGHT, Vector3(40.2, y, 0.0), Vector3.RIGHT)
		wires.append(wire)
	wires[1].material_override = XREBlueprintCanvas.wire_material(Color.ORANGE, XREBlueprintCanvas.LIT_WIRE_GROW)
	_camera.transform = Transform3D(Basis.IDENTITY, Vector3(40.0, 0.0, 1.0))
	_camera.size = 0.2
	image = await _capture("wire_thickness")
	var thickness: Array[int] = []
	for wire: int in 2:
		var center := Vector2i(_camera.unproject_position(Vector3(40.0, 0.05 - wire * 0.1, 0.0)))
		var count := 0
		for y: int in range(center.y - 20, center.y + 21):
			if image.get_pixel(center.x, y).r > 0.3: count += 1
		thickness.append(count)
	_check(thickness[1] >= thickness[0] * 1.6 and thickness[0] > 0, "the lit wire is drawn thicker: %s px, %s px" % [thickness[1], thickness[0]])
	thin.queue_free()
	_camera.transform = camera_before
	_camera.size = size_before


## D-043: a window has the same color over the scene and over the logic veil,
## that of a Meta window; a concave window and sphere ports, saved for a look:
## build/blueprint_render_concave.png.
func _test_window_color() -> void:
	var camera_before := _camera.transform
	var size_before := _camera.size
	var plain := XREPanelSurface.new(Vector2(200, 300), 0.001, 1.5, null)
	var veiled := XREPanelSurface.new(Vector2(200, 300), 0.001, 1.5, null)
	veiled.set_overlay(true)
	for surface: XREPanelSurface in [plain, veiled]: _viewport.add_child(surface)
	plain.position = Vector3(29.85, 0.0, 0.0)
	veiled.position = Vector3(30.15, 0.0, 0.0)
	_camera.transform = Transform3D(Basis.IDENTITY, Vector3(30.0, 0.0, 1.0))
	_camera.size = 0.8
	var image := await _capture("window_color")
	var plain_color := image.get_pixelv(Vector2i(_camera.unproject_position(plain.global_position)))
	var veiled_color := image.get_pixelv(Vector2i(_camera.unproject_position(veiled.global_position)))
	var meta := XREPanelSurface.META_WINDOW_COLOR
	_check(absf(plain_color.v - veiled_color.v) < 0.02 and absf(plain_color.r - veiled_color.r) < 0.02,
			"a window's color doesn't change over the logic veil: %s, %s" % [plain_color, veiled_color])
	_check(absf(plain_color.v - meta.v) < 0.03, "and it is a Meta window's: %s, %s" % [plain_color, meta])
	plain.queue_free()
	veiled.queue_free()
	var concave := XREPanelSurface.new(Vector2(480, 300), 0.0009, 1.5, null)
	concave.set_curve_radius(0.8)
	_viewport.add_child(concave)
	concave.position = Vector3(30.0, 0.15, 0.0)
	var graph := XREBlueprintGraph.new()
	graph.nodes = [{"id": 1, "kind": "print", "position": Vector2.ZERO, "params": {}}]
	graph.upgrade()
	var canvas := XREBlueprintCanvas.new()
	canvas.set_port_display(XREFeatureSettings.SPHERE)
	_viewport.add_child(canvas)
	canvas.position = Vector3(30.0, -0.25, 0.0)
	canvas.rebuild(graph)
	_camera.transform = Transform3D(Basis.IDENTITY, Vector3(30.35, 0.0, 1.0)).looking_at(Vector3(30.0, 0.0, 0.0))
	image = await _capture("concave")
	var edge := concave.pixel_to_global(Vector2(10, 150))
	_check(image.get_pixelv(Vector2i(_camera.unproject_position(edge))).v > 0.05, "the concave window's bent edge is drawn")
	var card := (canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	var port := canvas.to_global(card.outputs[0])
	var lit := image.get_pixelv(Vector2i(_camera.unproject_position(port)))
	var expected := XREBlueprintCanvas.COLORS[card.output_types[0]]
	_check(absf(lit.r - expected.r) < 0.15 and absf(lit.g - expected.g) < 0.15 and absf(lit.b - expected.b) < 0.15,
			"a sphere port is drawn in its type's color: %s, %s" % [lit, expected])
	concave.queue_free()
	canvas.queue_free()
	_camera.transform = camera_before
	_camera.size = size_before


## The launcher and a window with its control bar as Meta Horizon OS draws them (D-042),
## saved for a look: build/blueprint_render_launcher.png.
func _test_launcher_look() -> void:
	var camera_before := _camera.transform
	var size_before := _camera.size
	var document := EmptyDocument.new()
	var types := XREPanels.tab_types()
	var tabs: Array[XREPanelTab] = []
	for type: GDScript in types:
		tabs.append(type.new(document) as XREPanelTab)
	var launcher := XRETabLauncher.new(types, tabs, XRETabLauncher.size_for(types.size()), XREPanels.LAUNCHER_PIXEL_SIZE, 2.0, null)
	for tab: XREPanelTab in tabs:
		tab.free()
	launcher.set_overlay(true)
	_viewport.add_child(launcher)
	launcher.position = Vector3(20.0, 0.25, 0.0)
	var window := XREPanelWindow.new(XRESceneTab.new(document), XREPanels.WINDOW_SIZE, XREPanels.WINDOW_PIXEL_SIZE, 2.0, null)
	_viewport.add_child(window)
	window.position = Vector3(20.0, -0.12, -0.5)
	var dimmer := XREBlueprints.create_dimmer(XREPanels.LAUNCHER_DIM)
	_camera.add_child(dimmer)
	_camera.transform = Transform3D(Basis.IDENTITY, Vector3(20.0, 0.0, 1.0))
	_camera.size = 1.0
	var hover := func() -> void: window.hover_handles(-1)
	process_frame.connect(hover)
	var image := await _capture("launcher")
	process_frame.disconnect(hover)
	var dimmed := image.get_pixelv(Vector2i(_camera.unproject_position(window.to_global(Vector3(0.0, 0.1, 0.0)))))
	_check(dimmed.v < XREPanelSurface.META_WINDOW_COLOR.v, "the launcher dims what is behind it")
	_check(window.get_bar().is_shown(), "a hovered window shows its control bar")
	# D-044: a ray pointing at the launcher is drawn over it, not covered by it.
	launcher.set_curve_radius(XREPanels.LAUNCHER_DISTANCE)
	var hand := XREHand.new("LauncherHand", &"right_hand", Color.ORANGE)
	hand.show_when_tracked = false
	_viewport.add_child(hand)
	var target := launcher.global_position
	hand.global_transform = Transform3D(Basis.IDENTITY, target + Vector3(-0.2, 0.05, 0.25)).looking_at(target)
	var length := hand.global_position.distance_to(target)
	hand.show_ray(length, true)
	var pointed := await _capture("launcher_ray")
	var ray_pixel := Vector2i(_camera.unproject_position(hand.to_global(Vector3(0.0, 0.0, -length * 0.6))))
	var ray := pointed.get_pixelv(ray_pixel)
	var under := image.get_pixelv(ray_pixel)
	_check(ray.v > under.v + 0.25, "a ray in front of the launcher is drawn over it: %s over %s" % [ray, under])
	hand.queue_free()
	dimmer.queue_free()
	launcher.queue_free()
	window.queue_free()
	_camera.transform = camera_before
	_camera.size = size_before


func _run() -> void:
	DirAccess.make_dir_recursive_absolute("res://build")
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(512, 512)
	_viewport.own_world_3d = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_viewport)
	_camera = Camera3D.new()
	_camera.position.z = 2
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.size = 0.5
	_camera.cull_mask = XRERig.SCENE_LAYERS | XRERig.VR_LAYER
	_viewport.add_child(_camera)
	_camera.current = true
	var shape := BoxMesh.new()
	shape.size = Vector3(0.42, 0.06, 0.3)
	var cube := XRERig.create_vr_mesh(shape, XREBlueprintCanvas.material(Color("aa2020")))
	cube.position.z = -0.5
	_viewport.add_child(cube)
	var outline := XREOutline.new(Color.WHITE)
	_viewport.add_child(outline)
	outline.show_node(cube, shape.get_aabb())
	var before := await _capture("edges")
	var edge := Vector3(0.04, -0.03, -0.35)
	_check(_white_at(before, edge), "visible cube retains its own sharp edge outline")
	_check(not outline.is_boxed() and outline.get_part_count() == 1, "rendered outline uses mesh edges, not a bounding box")
	var graph := XREBlueprintGraph.new()
	graph.nodes = [{"id": 1, "kind": "ready", "position": Vector2.ZERO, "params": {}}]
	graph.upgrade()
	var canvas := XREBlueprintCanvas.new()
	_viewport.add_child(canvas)
	canvas.rebuild(graph)
	var covered := await _capture("card")
	_check(not _white_at(covered, edge), "card occludes the selected scene edge behind it")
	_check(_white_at(covered, Vector3(0.21, 0, -0.35)), "uncovered scene edges remain visible")
	var window := XREPanelSurface.new(Vector2(200, 80), 0.001, 1.5, null)
	var window_style := XREPanelSurface.frame_style(null)
	window_style.bg_color = Color.GREEN
	window.root.add_theme_stylebox_override(&"panel", window_style)
	_viewport.add_child(window)
	window.set_overlay(true)
	window.position.z = -0.2
	var behind_window := await _capture("window_behind_node")
	var body_probe := Vector2i(_camera.unproject_position(Vector3(0, -0.02, 0)))
	_check(behind_window.get_pixelv(body_probe).is_equal_approx(covered.get_pixelv(body_probe)), "overlay window behind the card cannot cover its body")
	window.position.z = 0.15
	var front_window := await _capture("window_in_front")
	_check(front_window.get_pixelv(body_probe).g > 0.8, "window in front of the card retains physical occlusion")
	window.hide()
	var hand := XREHand.new("RenderHand", &"right_hand", Color.ORANGE)
	hand.show_when_tracked = false
	hand.position = Vector3(0.04, -0.03, 0.4)
	_viewport.add_child(hand)
	var hit := canvas.intersect_ray(hand.global_position, Vector3.FORWARD, 1)
	_check(hit > 0, "analytic ray intersects the rendered card body")
	hand.show_ray(hit, true, XREBlueprintCanvas.HIT_DOT_OFFSET)
	var dot := hand.get("_dot") as MeshInstance3D
	# Isolate the contact marker: the ray's nearer portion is legitimately
	# visible in front of the blocker and would hide an occluded-dot regression.
	(hand.get("_ray") as MeshInstance3D).hide()
	var contact := await _capture("contact")
	_check(_white_at(contact, dot.global_position), "contact dot is visible on the card surface")
	var blocker_shape := BoxMesh.new()
	blocker_shape.size = Vector3(0.05, 0.05, 0.01)
	var blocker := XRERig.create_vr_mesh(blocker_shape, XREBlueprintCanvas.material(Color("208020")))
	blocker.position = Vector3(0.04, -0.03, 0.1)
	_viewport.add_child(blocker)
	var blocked := await _capture("blocked")
	_check(not _white_at(blocked, dot.global_position), "contact dot remains occluded by geometry in front of it")
	blocker.hide()
	hand.hide()
	cube.hide()
	outline.clear()
	_camera.position = Vector3(0.32, 0.14, 0.65)
	_camera.look_at(Vector3.ZERO)
	canvas.face_user(_camera.global_position)
	var angled := await _capture("flat_angle")
	var first_card := (canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	_check(first_card.mesh.mesh is QuadMesh and first_card.node.global_basis.y.is_equal_approx(Vector3.UP), "flat panel remains upright when viewed from an angle")
	_check(_white_at(angled, first_card.node.to_global(Vector3(-0.015, 0.04, 0.001))), "angled panel retains its visible title")
	_check(_white_at(angled, first_card.node.to_global(first_card.outputs[0] + Vector3.LEFT * 0.03)), "angled panel retains its visible port name")
	_camera.position = Vector3(0, 0, -2)
	_camera.rotation = Vector3(0, PI, 0)
	canvas.face_user(_camera.global_position)
	var rear := await _capture("flat_behind")
	_check(_white_at(rear, first_card.node.to_global(Vector3(-0.015, 0.04, 0.001))), "front title stays visible after the user walks behind")
	_check(_white_at(rear, first_card.node.to_global(first_card.plus_point)), "same plus stays visible after automatic facing")
	# The cuboid node display (D-039): seen from the side its depth shows, darker than the front.
	canvas.set_node_modes(XREFeatureSettings.OFF, true, false, XREFeatureSettings.FACE, false)
	canvas.rebuild(graph)
	_camera.position = Vector3(0.6, 0.1, 0.5)
	_camera.rotation = Vector3.ZERO
	_camera.look_at(Vector3.ZERO)
	canvas.face_user(_camera.global_position)
	var solid := await _capture("cuboid_angle")
	var box := (canvas.get("_cards") as Array)[0] as XREBlueprintCanvas.Card
	var half := box.bounds.size * 0.5
	var front_color := solid.get_pixelv(Vector2i(_camera.unproject_position(box.node.to_global(Vector3(-0.06, -half.y + 0.015, half.z)))))
	var side_color := solid.get_pixelv(Vector2i(_camera.unproject_position(box.node.to_global(Vector3(half.x, -half.y + 0.015, 0.0)))))
	_check(box.node.basis.is_equal_approx(Basis.IDENTITY), "a cuboid seen from the side doesn't turn to the camera")
	_check(side_color.get_luminance() > 0.01 and side_color.get_luminance() < front_color.get_luminance() * 0.8,
			"the cuboid's side is drawn, darker than its front: %s, %s" % [side_color, front_color])
	_check(_white_at(solid, box.node.to_global(Vector3(-0.015, 0.04, box.face + 0.001))), "the cuboid's title on its front face is visible from the side")
	canvas.set_node_modes(XREFeatureSettings.ON, false, false, XREFeatureSettings.FACE, false)
	canvas.rebuild(graph)
	_camera.position = Vector3(0, 0, 2)
	_camera.rotation = Vector3.ZERO
	canvas.face_user(_camera.global_position)
	_camera.size = 1.2
	_viewport.size = Vector2i(1024, 768)
	canvas.position = Vector3(-0.25, 0.27, 0)
	var keyboard := XREVirtualKeyboard.new()
	_viewport.add_child(keyboard)
	keyboard.position = Vector3(0, -0.18, 0.1)
	keyboard.rotation.x = -XREVirtualKeyboard.TILT
	keyboard.open_text("door_target/path")
	await _capture("keyboard")
	var keys := keyboard.get("_keys") as Array
	for key: Button in keys:
		var rect := key.get_global_rect()
		_check(rect.position.x >= 0 and rect.end.x <= keyboard.size_px.x and rect.position.y >= 0 and rect.end.y <= keyboard.size_px.y, "keyboard key fits inside its visible surface")
	var characters := keyboard.get("_characters") as Array
	var right_key := characters[11] as Button
	var left_key := characters[12] as Button
	var idle_key := characters[13] as Button
	var left_hand := XREHand.new("LeftRenderHand", &"left_hand", Color.BLUE)
	_viewport.add_child(left_hand)
	left_hand.hide()
	keyboard.hover_pointer(hand, right_key.get_global_rect().get_center())
	keyboard.hover_pointer(left_hand, left_key.get_global_rect().get_center())
	var hovered := await _capture("keyboard_two_hands")
	var right_pixel := Vector2i(_camera.unproject_position(keyboard.pixel_to_global(right_key.get_global_rect().position + Vector2(12, 12))))
	var left_pixel := Vector2i(_camera.unproject_position(keyboard.pixel_to_global(left_key.get_global_rect().position + Vector2(12, 12))))
	var idle_pixel := Vector2i(_camera.unproject_position(keyboard.pixel_to_global(idle_key.get_global_rect().position + Vector2(12, 12))))
	_check(hovered.get_pixelv(right_pixel).b > hovered.get_pixelv(idle_pixel).b + 0.01, "right hand hover visibly highlights its key")
	_check(hovered.get_pixelv(left_pixel).b > hovered.get_pixelv(idle_pixel).b + 0.01, "left hand hover also visibly highlights its own key")
	keyboard.close()
	canvas.hide()
	# The Debug tab (D-042) in a window pinned to a hand: compact.
	var debug := XREDebugTab.new(null)
	var fps := XREPanelWindow.new(debug, XREPanels.WINDOW_SIZE, XREPanels.WINDOW_PIXEL_SIZE, 1.5, null)
	_viewport.add_child(fps)
	fps.set_pin(XREPanelWindow.Pin.LEFT_HAND, XREPanels.COMPACT_SIZE, XREPanels.COMPACT_PIXEL_SIZE)
	fps.rotation.x = -PI / 3.0
	var session := XRESession.new()
	debug.setup(session)
	var timestamp := 0.0
	for frame: int in 5400:
		var interval := 0.055 if frame % 350 == 0 else 1.0 / 90.0
		timestamp += interval
		session.fps_history.record_interval(interval, timestamp, true)
	await _capture("wrist_fps")
	debug.get_number_label().text = "Synthetic render fixture · FPS history"
	for child: Node in debug.get_children():
		var control := child as Control
		if control != null:
			_check(Rect2(Vector2.ZERO, fps.size_px).encloses(control.get_global_rect()), "FPS text, plot and legend fit the compact window on a hand")
	_check(debug.get_chart().history.count > 0, "the Debug tab charts a populated bounded history")
	debug.setup(null)
	session.free()
	fps.queue_free()
	await _test_graph_drawing()
	await _test_launcher_look()
	await _test_window_color()
	await _test_objects_and_wire()
	canvas.show()
	keyboard.set_overlay(true)
	keyboard.open_text("Scene dimmed, overlay unchanged")
	var patch_shape := BoxMesh.new()
	patch_shape.size = Vector3(0.22, 0.22, 0.04)
	var patch := XRERig.create_vr_mesh(patch_shape, XREBlueprintCanvas.material(Color("46c47a")))
	patch.position = Vector3(0.4, 0.24, -0.3)
	_viewport.add_child(patch)
	var glass_material := XREBlueprintCanvas.material(Color(0.2, 0.5, 0.9, 0.7))
	glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var glass := XRERig.create_vr_mesh(patch_shape, glass_material)
	glass.position = Vector3(0.4, -0.05, -0.3)
	_viewport.add_child(glass)
	var veil := XREBlueprints.create_dimmer()
	_camera.add_child(veil)
	veil.hide()
	var plain := await _capture("logic_plain")
	veil.show()
	var dimmed := await _capture("logic_dimmed")
	var patch_pixel := Vector2i(_camera.unproject_position(patch.global_position))
	var glass_pixel := Vector2i(_camera.unproject_position(glass.global_position))
	var body_pixel := Vector2i(_camera.unproject_position(canvas.to_global(Vector3(0, -0.03, XREBlueprintCanvas.CARD_THICKNESS * 0.5))))
	var key_pixel := Vector2i(_camera.unproject_position(keyboard.pixel_to_global(right_key.get_global_rect().position + Vector2(12, 12))))
	_check(dimmed.get_pixelv(patch_pixel).g < plain.get_pixelv(patch_pixel).g * 0.8, "logic veil dims opaque scene geometry")
	_check(dimmed.get_pixelv(glass_pixel).b < plain.get_pixelv(glass_pixel).b * 0.8, "logic veil also dims transparent scene geometry")
	_check(absf(dimmed.get_pixelv(body_pixel).b - plain.get_pixelv(body_pixel).b) < 0.02, "logic veil leaves the card's front unchanged")
	_check(absf(dimmed.get_pixelv(key_pixel).b - plain.get_pixelv(key_pixel).b) < 0.02, "logic veil leaves floating keyboard UI unchanged")
	_camera.cull_mask = XRERig.SCENE_LAYERS
	patch.layers = 1
	glass.layers = 1
	var desktop := await _capture("logic_desktop")
	_check(desktop.get_pixelv(patch_pixel).g > dimmed.get_pixelv(patch_pixel).g * 1.2, "desktop scene camera excludes the VR dimmer")
	_camera.cull_mask = XRERig.SCENE_LAYERS | XRERig.VR_LAYER
	await _test_window_handles()
	veil.hide()
	patch.hide()
	glass.hide()
	keyboard.close()
	var palette_graph := XREBlueprintGraph.new()
	var kinds: Array[String] = ["ready", "set_property", "branch", "value", "play_sound", "play_animation"]
	for index: int in kinds.size():
		var x := -0.42 + (index % 3) * 0.42
		var y := 0.18 - (index / 3) * 0.32
		palette_graph.nodes.append(XREBlueprintGraph.make_node(index + 1, kinds[index], Vector2(x, -y) / XREBlueprintCanvas.PIXEL_SIZE))
	canvas.position = Vector3.ZERO
	canvas.rebuild(palette_graph)
	_camera.size = 1.0
	var palette := await _capture("palette")
	for card: XREBlueprintCanvas.Card in canvas.get("_cards") as Array:
		var pixel := Vector2i(_camera.unproject_position(card.node.to_global(Vector3(0, -0.035, XREBlueprintCanvas.CARD_THICKNESS * 0.5))))
		var color := palette.get_pixelv(pixel)
		_check(maxf(color.r, maxf(color.g, color.b)) - minf(color.r, minf(color.g, color.b)) > 0.1, "block faces retain a saturated category color")
		_check((color.r + color.g + color.b) / 3.0 < 0.45, "block faces avoid the previous pale surface")
		_check(_white_at(palette, card.node.to_global(Vector3(-0.015, card.height * 0.5 - 0.022, 0.001))), "every category retains its title on its facing panel")
	var route_graph := XREBlueprintGraph.new()
	route_graph.nodes = [XREBlueprintGraph.make_node(1, "ready", Vector2(-600, 0)), XREBlueprintGraph.make_node(2, "print", Vector2(600, 0)), XREBlueprintGraph.make_node(3, "print", Vector2.ZERO)]
	route_graph.edges = [{"from": 1, "from_port": 0, "to": 2, "to_port": 0}]
	canvas.rebuild(route_graph)
	_camera.size = 1.3
	var curved := await _capture("curved_wires")
	var graph_wire := (canvas.get("_wires") as Array)[0] as XREBlueprintCanvas.Wire
	var visible_wire := 0
	for sample: int in range(2, graph_wire.mesh.get_point_count() - 2):
		var point := graph_wire.mesh.get_point(sample)
		if absf(point.x) > XREBlueprintCanvas.CARD_WIDTH * 0.5 + 0.02 and absf(point.x) < 0.54 - XREBlueprintCanvas.CARD_WIDTH * 0.5 - 0.02:
			visible_wire += 1 if _white_at(curved, canvas.to_global(point)) else 0
	_check(visible_wire >= 4, "GPU draws the Bezier tube between the cards")
	# The server's vertex layout must match the native packing: positions on the rings,
	# normals pointing radially out of the centerline.
	var arrays := graph_wire.mesh.mesh.surface_get_arrays(0)
	var vertices := arrays[Mesh.ARRAY_VERTEX] as PackedVector3Array
	var normals := arrays[Mesh.ARRAY_NORMAL] as PackedVector3Array
	var layout_ok := vertices.size() == XREGraphWire.SAMPLES * XREGraphWire.SIDES and normals.size() == vertices.size()
	var radius := (vertices[0] - graph_wire.mesh.get_point(0)).length() if layout_ok else 0.0
	layout_ok = layout_ok and radius > 0.001 and radius < 0.005
	if layout_ok:
		for ring: int in [0, XREGraphWire.SAMPLES / 2, XREGraphWire.SAMPLES - 1]:
			for side: int in XREGraphWire.SIDES:
				var index := ring * XREGraphWire.SIDES + side
				var radial := vertices[index] - graph_wire.mesh.get_point(ring)
				layout_ok = layout_ok and absf(radial.length() - radius) < 0.0003 and normals[index].dot(radial.normalized()) > 0.99
	_check(layout_ok, "tube vertices and octahedral normals match the server's vertex layout")
	var scene_wire := canvas.add_scene_link(route_graph.find_node(2), XREBlueprintCanvas.COLORS[XREBlueprintGraph.OBJECT])
	canvas.update_scene_wire(scene_wire, 2, 0, Vector3(0.54, -0.35, -0.5))
	_camera.position = Vector3(0.35, 0.18, 2)
	_camera.look_at(Vector3.ZERO)
	await _capture("target_behind")
	_camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	_viewport.size = Vector2i(2048, 1536)
	for angle: float in [0.0, 0.65, -0.65]:
		var head := Vector3(sin(angle) * 2.3, 0.2, cos(angle) * 2.3)
		_camera.position = head
		_camera.look_at(Vector3.ZERO)
		canvas.face_user(head)
		canvas.update_scene_wire(scene_wire, 2, 0, Vector3(0.54, -0.35, -0.5))
		var eye_image := await _capture("wire_view_%.2f" % angle)
		var ends := 0
		for sample: int in [2, 3, graph_wire.mesh.get_point_count() - 4, graph_wire.mesh.get_point_count() - 3]:
			ends += 1 if _white_at(eye_image, canvas.to_global(graph_wire.mesh.get_point(sample))) else 0
		_check(ends >= 3, "perspective view shows the wire leaving and entering its ports at %.2f" % angle)
	_viewport.queue_free()
	for frame: int in 3: await process_frame
	print("test_blueprint_render: %d of %d checks failed" % [_failures, _checks])
	quit(1 if _failures > 0 else 0)
