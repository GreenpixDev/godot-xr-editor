extends SceneTree
## Optional GPU regression: graph/outline/contact occlusion in a normal renderer.
## Run without --headless or XR; check.sh only parses it (dummy rendering has no pixels).

## An empty document, for tabs drawn only to be looked at.
class EmptyDocument extends XREDocument:
	func get_scene_root() -> Node: return null
	func get_selection() -> Array[Node]: return []
	func select(_nodes: Array[Node], _source: Source) -> void: pass
	func preview_transform(_node: Node3D, _xform: Transform3D) -> void: pass
	func commit_transform(_node: Node3D, _before: Transform3D, _source: Source) -> void: pass
	func set_property(_object: Object, _property: StringName, _value: Variant, _source: Source) -> void: pass
	func preview_property(_object: Object, _property: StringName, _value: Variant) -> void: pass
	func commit_property(_object: Object, _property: StringName, _before: Variant, _source: Source) -> void: pass
	func add_node(_node: Node, _parent: Node, _source: Source) -> void: pass
	func remove_nodes(_nodes: Array[Node], _source: Source) -> void: pass
	func save(_source: Source) -> Error: return OK
	func open_scene(_path: String, _source: Source) -> Error: return OK
	func list_folder(_path: String) -> PackedStringArray: return PackedStringArray()
	func get_file_type(_path: String) -> StringName: return &""
	func play(_source: Source, _separate_app: bool) -> Error: return OK
	func stop_playing(_source: Source) -> void: pass
	func is_playing() -> bool: return false
	func get_snap() -> XRESnap: return XRESnap.new(false, 0.0, 0.0, 0.0)


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
	canvas.set_display(XREFeatureSettings.CUBOID)
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
	canvas.set_display(XREFeatureSettings.BILLBOARD)
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
	await _test_launcher_look()
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
	var scene_wire := canvas.create_scene_wire(XREBlueprintCanvas.COLORS[XREBlueprintGraph.OBJECT])
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
