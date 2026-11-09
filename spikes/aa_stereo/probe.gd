extends SceneTree
# Each antialiasing mode on a stereo (multiview) viewport as a headset's: which take effect, in
# both eyes, and what they cost on this GPU. Soft = pixels between black and white on a slanted edge.

const MODES := [
	["off", 0, 0, false, 1.0, 0],
	["msaa2", 1, 0, false, 1.0, 0],
	["msaa4", 2, 0, false, 1.0, 0],
	["msaa8", 3, 0, false, 1.0, 0],
	["fxaa", 0, 1, false, 1.0, 0],
	["smaa", 0, 2, false, 1.0, 0],
	["taa", 0, 0, true, 1.0, 0],
	["ssaa1.5", 0, 0, false, 1.5, 0],
	["ssaa2", 0, 0, false, 2.0, 0],
	["msaa4+ssaa2", 2, 0, false, 2.0, 0],
	["fsr2native", 0, 0, false, 1.0, 2],
]

var vp: SubViewport
var stereo := true
var load_node: Node3D


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	stereo = not OS.get_cmdline_user_args().has("--mono")
	root.size = Vector2i(1872, 960)
	vp = SubViewport.new()
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.world_3d = World3D.new()
	vp.own_world_3d = true
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color.BLACK
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	vp.add_child(world_env)
	var white := StandardMaterial3D.new()
	white.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	white.albedo_color = Color.WHITE
	var box := BoxMesh.new()
	box.size = Vector3(0.5, 0.5, 0.02)
	box.material = white
	for i: int in 12:
		var inst := MeshInstance3D.new()
		inst.mesh = box
		inst.position = Vector3(-0.9 + (i % 4) * 0.6, -0.5 + (i / 4) * 0.5, -2.0)
		inst.rotation = Vector3(0.0, 0.0, 0.3 + i * 0.13)
		vp.add_child(inst)
	load_node = Node3D.new()
	vp.add_child(load_node)
	var light := DirectionalLight3D.new()
	light.shadow_enabled = true
	light.rotation = Vector3(-0.8, 0.5, 0.0)
	load_node.add_child(light)
	var sphere := SphereMesh.new()
	sphere.radius = 0.12
	sphere.height = 0.24
	for i: int in 900:
		var ball := MeshInstance3D.new()
		ball.mesh = sphere
		ball.position = Vector3((i % 30) * 0.3 - 4.5, (i / 30) * 0.3 - 4.5, -5.0)
		load_node.add_child(ball)
	var interface: XRInterface = null
	if stereo:
		interface = XRServer.find_interface("Native mobile")
		print("mobile interface: ", interface)
		if interface == null or not interface.initialize():
			print("no stereo interface")
			quit(1)
			return
		XRServer.primary_interface = interface
		vp.use_xr = true
		print("target ", interface.get_render_target_size(), " views ", interface.get_view_count())
		var origin := XROrigin3D.new()
		var cam := XRCamera3D.new()
		origin.add_child(cam)
		vp.add_child(origin)
	else:
		vp.size = Vector2i(1872, 1920)
		var cam := Camera3D.new()
		vp.add_child(cam)
	root.add_child(vp)
	RenderingServer.viewport_set_measure_render_time(vp.get_viewport_rid(), true)
	print("method ", RenderingServer.get_current_rendering_method(), " stereo ", stereo)
	for m: Array in MODES:
		vp.msaa_3d = m[1]
		vp.screen_space_aa = m[2]
		vp.use_taa = m[3]
		vp.scaling_3d_scale = m[4]
		vp.scaling_3d_mode = m[5]
		load_node.visible = true
		for i: int in 40:
			await process_frame
		var sum := 0.0
		for i: int in 40:
			await process_frame
			sum += RenderingServer.viewport_get_measured_render_time_gpu(vp.get_viewport_rid())
		load_node.visible = false
		for i: int in 40:
			await process_frame
		print("%-12s gpu %6.2f ms  soft %s" % [m[0], sum / 40.0, _soft()])
	print("try msaa 16x: index 4")
	vp.msaa_3d = 4 as Viewport.MSAA
	await process_frame
	print("msaa_3d now ", vp.msaa_3d)
	vp.msaa_3d = Viewport.MSAA_DISABLED
	await process_frame
	await process_frame
	if interface != null:
		XRServer.primary_interface = null
		interface.uninitialize()
	quit()


func _soft() -> String:
	var rid := vp.get_texture().get_rid()
	var out := ""
	if stereo:
		for layer: int in 2:
			out += "%d " % _count(RenderingServer.texture_2d_layer_get(rid, layer))
	else:
		out = str(_count(vp.get_texture().get_image()))
	return out


func _count(image: Image) -> int:
	if image == null or image.is_empty():
		return -1
	image.convert(Image.FORMAT_RGB8)
	var data := image.get_data()
	var n := 0
	for i: int in range(0, data.size(), 3):
		if data[i] > 25 and data[i] < 230:
			n += 1
	return n
