extends SceneTree
# Spike D-154: DLAA through the layer in layer/, against the engine's own modes. Mono, or a stereo
# viewport with -- --stereo. Prints each mode's GPU time, the error against a heavily supersampled
# reference (PSNR, higher is better) and saves a picture. See README.md for how to run it.

const STUB := """
#version 450
layout(local_size_x = 1, local_size_y = 1) in;
layout(set = 0, binding = 0) uniform sampler2D color_in;
layout(set = 0, binding = 1) uniform sampler2D depth_in;
layout(set = 0, binding = 2) uniform sampler2D motion_in;
layout(rgba16f, set = 0, binding = 3) uniform image2D output_image;
layout(push_constant) uniform Params { uvec4 data[8]; } params;
void main() {
	imageStore(output_image, ivec2(0), texture(color_in, vec2(0.0)) + texture(depth_in, vec2(0.0)) + texture(motion_in, vec2(0.0)) + vec4(params.data[0]));
}
"""
const COPY := """
#version 450
layout(local_size_x = 16, local_size_y = 16) in;
layout(set = 0, binding = 0) uniform sampler2D source;
layout(rgba16f, set = 0, binding = 1) uniform image2D target;
void main() {
	ivec2 pixel = ivec2(gl_GlobalInvocationID.xy);
	if (any(greaterThanEqual(pixel, imageSize(target)))) return;
	imageStore(target, pixel, texelFetch(source, pixel, 0));
}
"""
const SIZE := Vector2i(1024, 1024)
const STEP_FRAMES := 60


class Dlss extends CompositorEffect:
	const MAGIC := 0x5852454449534c44
	var rd: RenderingDevice
	var stub: RID
	var stub_pipeline: RID
	var copy: RID
	var copy_pipeline: RID
	var sampler: RID
	var outputs: Array[RID] = []
	var frame := 0
	var reset := true
	var jitter_sign := Vector2(1.0, 1.0)
	var motion_scale := Vector2(1.0, 1.0)
	var dump_ubo := 0
	var base: Array[Vector2] = []
	var base_frames: Array[int] = []
	var view_count_one := true
	var raw_output := false
	var raw_image: PackedByteArray
	var rig_jitter := Vector2.ZERO
	var motion_jittered := false
	var use_rig_jitter := false
	var logged := 0

	func _init() -> void:
		effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
		needs_motion_vectors = true
		RenderingServer.call_on_render_thread(_setup)

	func _setup() -> void:
		rd = RenderingServer.get_rendering_device()
		stub = _shader(STUB)
		stub_pipeline = rd.compute_pipeline_create(stub)
		copy = _shader(COPY)
		copy_pipeline = rd.compute_pipeline_create(copy)
		var state := RDSamplerState.new()
		sampler = rd.sampler_create(state)

	func _shader(code: String) -> RID:
		var source := RDShaderSource.new()
		source.language = RenderingDevice.SHADER_LANGUAGE_GLSL
		source.source_compute = code
		var spirv := rd.shader_compile_spirv_from_source(source)
		if not spirv.compile_error_compute.is_empty():
			printerr(spirv.compile_error_compute)
		return rd.shader_create_from_spirv(spirv)

	func _output(view: int, size: Vector2i) -> RID:
		while outputs.size() <= view:
			var format := RDTextureFormat.new()
			format.format = RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT
			format.width = size.x
			format.height = size.y
			format.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
			outputs.append(rd.texture_create(format, RDTextureView.new()))
		return outputs[view]

	func _image(rid: RID) -> int:
		return rd.get_driver_resource(RenderingDevice.DRIVER_RESOURCE_VULKAN_IMAGE, rid, 0)

	func _view(rid: RID) -> int:
		return rd.get_driver_resource(RenderingDevice.DRIVER_RESOURCE_VULKAN_IMAGE_VIEW, rid, 0)

	func _format(rid: RID) -> int:
		return rd.get_driver_resource(RenderingDevice.DRIVER_RESOURCE_VULKAN_IMAGE_NATIVE_TEXTURE_FORMAT, rid, 0)

	func _sampled(binding: int, rid: RID) -> RDUniform:
		var uniform := RDUniform.new()
		uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
		uniform.binding = binding
		uniform.add_id(sampler)
		uniform.add_id(rid)
		return uniform

	func _storage(binding: int, rid: RID) -> RDUniform:
		var uniform := RDUniform.new()
		uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		uniform.binding = binding
		uniform.add_id(rid)
		return uniform

	func _render_callback(_type: int, render_data: RenderData) -> void:
		var buffers := render_data.get_render_scene_buffers() as RenderSceneBuffersRD
		var scene := render_data.get_render_scene_data()
		var size := buffers.get_internal_size()
		if dump_ubo > 0:
			dump_ubo -= 1
			var bytes := rd.buffer_get_data(scene.get_uniform_buffer())
			var floats := bytes.to_float32_array()
			var line := "ubo %d floats:" % floats.size()
			for i: int in floats.size():
				if i >= 64 and i < floats.size() and absf(floats[i]) > 1e-7 and absf(floats[i]) < 0.01:
					line += " %d=%.6f" % [i, floats[i]]
			print(line)
		for view: int in buffers.get_view_count():
			var jitter := _jitter(scene.get_view_projection(view)[2], view, size)
			var color := buffers.get_color_layer(view)
			var depth := buffers.get_depth_layer(view)
			var motion := buffers.get_velocity_layer(view)
			var output := _output(view, size)
			var push := PackedByteArray()
			push.resize(128)
			push.encode_u64(0, MAGIC)
			push.encode_u64(8, _image(color))
			push.encode_u64(16, _view(color))
			push.encode_u64(24, _image(depth))
			push.encode_u64(32, _view(depth))
			push.encode_u64(40, _image(motion))
			push.encode_u64(48, _view(motion))
			push.encode_u64(56, _image(output))
			push.encode_u64(64, _view(output))
			push.encode_u32(72, _format(color))
			push.encode_u32(76, _format(depth))
			push.encode_u32(80, _format(motion))
			push.encode_u32(84, _format(output))
			push.encode_u32(88, size.x)
			push.encode_u32(92, size.y)
			push.encode_u32(96, view)
			push.encode_u32(100, view)
			push.encode_float(104, jitter.x * jitter_sign.x)
			push.encode_float(108, jitter.y * jitter_sign.y)
			push.encode_float(112, motion_scale.x * size.x)
			push.encode_float(116, motion_scale.y * size.y)
			push.encode_u32(120, 1 if reset else 0)
			push.encode_u32(124, 1 if motion_jittered else 0)
			var set_stub := UniformSetCacheRD.get_cache(stub, 0, [_sampled(0, color), _sampled(1, depth), _sampled(2, motion), _storage(3, output)])
			var list := rd.compute_list_begin()
			rd.compute_list_bind_compute_pipeline(list, stub_pipeline)
			rd.compute_list_bind_uniform_set(list, set_stub, 0)
			rd.compute_list_set_push_constant(list, push, 128)
			rd.compute_list_dispatch(list, 1, 1, 1)
			rd.compute_list_end()
			var set_copy := UniformSetCacheRD.get_cache(copy, 0, [_sampled(0, output), _storage(1, color)])
			list = rd.compute_list_begin()
			rd.compute_list_bind_compute_pipeline(list, copy_pipeline)
			rd.compute_list_bind_uniform_set(list, set_copy, 0)
			rd.compute_list_dispatch(list, (size.x + 15) / 16, (size.y + 15) / 16, 1)
			rd.compute_list_end()
		reset = false
		frame += 1
		if raw_output:
			raw_output = false
			raw_image = rd.texture_get_data(outputs[0], 0)

	# The engine's jitter is in the projection's third column, over the eye's own off-axis part,
	# which a mean over the frames finds. In pixels.
	func _jitter(column: Vector4, view: int, size: Vector2i) -> Vector2:
		while base.size() <= view:
			base.append(Vector2.ZERO)
			base_frames.append(0)
		var raw := Vector2(column.x, column.y)
		if logged < 6:
			logged += 1
			print("view ", view, " projection column 2: ", column)
		if use_rig_jitter:
			return rig_jitter
		base_frames[view] += 1
		base[view] += (raw - base[view]) / float(base_frames[view])
		var center := Vector2.ZERO if view_count_one else base[view]
		return (raw - center) * Vector2(size) * 0.5


var vp: SubViewport
var effect: Dlss
var moving: Node3D
var origin: XROrigin3D
var rig_jitter_on := false
var rig_frame := 0


func _init() -> void:
	_run.call_deferred()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var stereo := args.has("--stereo")
	vp = SubViewport.new()
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.own_world_3d = true
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color.BLACK
	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	effect = Dlss.new()
	effect.enabled = false
	var compositor := Compositor.new()
	compositor.compositor_effects = [effect]
	world_env.compositor = compositor
	vp.add_child(world_env)
	var white := StandardMaterial3D.new()
	white.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var box := BoxMesh.new()
	box.size = Vector3(0.5, 0.5, 0.02)
	box.material = white
	for i: int in 12:
		var inst := MeshInstance3D.new()
		inst.mesh = box
		inst.position = Vector3(-0.9 + (i % 4) * 0.6, -0.5 + (i / 4) * 0.5, -2.0)
		inst.rotation = Vector3(0.0, 0.0, 0.3 + i * 0.13)
		vp.add_child(inst)
	var interface: XRInterface = null
	if stereo:
		interface = XRServer.find_interface("Native mobile")
		interface.initialize()
		XRServer.primary_interface = interface
		vp.use_xr = true
		origin = XROrigin3D.new()
		origin.add_child(XRCamera3D.new())
		vp.add_child(origin)
	else:
		vp.size = SIZE
		vp.add_child(Camera3D.new())
	root.add_child(vp)
	RenderingServer.viewport_set_measure_render_time(vp.get_viewport_rid(), true)
	if args.has("--dump-ubo"):
		effect.enabled = true
		vp.use_taa = true
		effect.dump_ubo = 4
		for i: int in 12:
			await process_frame
		quit()
		return
	effect.view_count_one = not stereo
	var rig_jitter_wanted := args.has("--rig-jitter")
	effect.use_rig_jitter = rig_jitter_wanted
	effect.motion_jittered = rig_jitter_wanted
	process_frame.connect(_jitter_rig)
	effect.jitter_sign = _pair(args, "--j", Vector2(1.0, 1.0))
	effect.motion_scale = _pair(args, "--m", Vector2(1.0, 1.0))
	moving = MeshInstance3D.new()
	(moving as MeshInstance3D).mesh = box
	moving.position = Vector3(0.0, 0.05, -1.5)
	vp.add_child(moving)
	var modes: Array = [["off", 0, false, false], ["msaa4", Viewport.MSAA_4X, false, false], ["taa", 0, true, false], ["dlaa", 0, true, true]]
	if args.has("--only-dlaa"):
		modes = [modes[3]]
	for test: String in ["still", "moving"]:
		moving.rotation.z = 0.7
		rig_jitter_on = false
		vp.msaa_3d = Viewport.MSAA_8X
		vp.use_taa = false
		effect.enabled = false
		vp.scaling_3d_scale = 4.0
		await _settle()
		var still_reference := _picture()
		vp.scaling_3d_scale = 1.0
		for mode: Array in modes:
			vp.msaa_3d = mode[1]
			vp.use_taa = mode[2]
			effect.enabled = mode[3]
			effect.reset = true
			rig_jitter_on = rig_jitter_wanted and mode[3]
			var angle := 0.7
			var speed := _pair(args, "--speed", Vector2(0.01, 0.0)).x
			var sum := 0.0
			for i: int in STEP_FRAMES:
				if test == "moving":
					angle += speed
					moving.rotation.z = angle
				await RenderingServer.frame_post_draw
				sum += RenderingServer.viewport_get_measured_render_time_gpu(vp.get_viewport_rid())
			var picture := _picture()
			var reference := still_reference
			var raw_note := ""
			if test == "moving":
				# The same pose, frozen and heavily supersampled.
				var msaa := vp.msaa_3d
				var taa := vp.use_taa
				var on := effect.enabled
				rig_jitter_on = false
				vp.msaa_3d = Viewport.MSAA_8X
				vp.use_taa = false
				effect.enabled = false
				vp.scaling_3d_scale = 4.0
				await _settle()
				reference = _picture()
				vp.scaling_3d_scale = 1.0
				vp.msaa_3d = msaa
				vp.use_taa = taa
				effect.enabled = on
			elif mode[3]:
				effect.raw_output = true
				await RenderingServer.frame_post_draw
				await RenderingServer.frame_post_draw
				if not effect.raw_image.is_empty():
					var raw := _srgb(effect.raw_image, picture.get_width(), picture.get_height())
					raw_note = " (dlss output before the engine's TAA: %.2f dB)" % _psnr(raw, reference)
			picture.save_png("user://%s_%s.png" % [test, mode[0]])
			print("%-6s %-6s gpu %5.2f ms  psnr %6.2f dB%s" % [test, mode[0], sum / STEP_FRAMES, _psnr(picture, reference), raw_note])
	if interface != null:
		XRServer.primary_interface = null
		interface.uninitialize()
	print("user dir ", OS.get_user_data_dir())
	quit()


# Halton (2, 3) sub-pixel offsets by turning the rig: the engine has no stereo jitter.
func _jitter_rig() -> void:
	if origin == null:
		return
	if not rig_jitter_on:
		origin.rotation = Vector3.ZERO
		return
	rig_frame += 1
	var pixel := Vector2(_halton(rig_frame % 16 + 1, 2) - 0.5, _halton(rig_frame % 16 + 1, 3) - 0.5)
	var eye := Vector2(vp.size)
	var focal: float = XRServer.primary_interface.get_projection_for_view(0, eye.x / eye.y, 0.05, 100.0)[0].x
	origin.rotation = Vector3(pixel.y * effect.jitter_sign.y, pixel.x * effect.jitter_sign.x, 0.0) * 2.0 / (eye.x * focal)
	effect.rig_jitter = pixel


func _halton(index: int, base: int) -> float:
	var f := 1.0
	var r := 0.0
	var i := index
	while i > 0:
		f /= base
		r += f * (i % base)
		i /= base
	return r


func _pair(args: PackedStringArray, prefix: String, fallback: Vector2) -> Vector2:
	for arg: String in args:
		if arg.begins_with(prefix + "="):
			var parts := arg.get_slice("=", 1).split(",")
			return Vector2(parts[0].to_float(), parts[1].to_float())
	return fallback


# The DLSS output, half floats in linear, as the picture the tonemapper would make of it.
func _srgb(data: PackedByteArray, width: int, height: int) -> Image:
	var image := Image.create_from_data(width, height, false, Image.FORMAT_RGBAH, data)
	image.convert(Image.FORMAT_RGBF)
	var floats := image.get_data().to_float32_array()
	var bytes := PackedByteArray()
	bytes.resize(floats.size())
	for i: int in floats.size():
		var c := clampf(floats[i], 0.0, 1.0)
		c = 12.92 * c if c < 0.0031308 else 1.055 * pow(c, 1.0 / 2.4) - 0.055
		bytes[i] = int(c * 255.0 + 0.5)
	return Image.create_from_data(width, height, false, Image.FORMAT_RGB8, bytes)


func _settle() -> void:
	for i: int in STEP_FRAMES:
		await process_frame


func _picture() -> Image:
	var image: Image
	if vp.use_xr:
		image = RenderingServer.texture_2d_layer_get(vp.get_texture().get_rid(), 0)
	else:
		image = vp.get_texture().get_image()
	image.convert(Image.FORMAT_RGB8)
	return image


func _psnr(a: Image, b: Image) -> float:
	var x := a.get_data()
	var y := b.get_data()
	var sum := 0.0
	for i: int in x.size():
		var d := float(x[i]) - float(y[i])
		sum += d * d
	var mse := sum / x.size()
	return 99.0 if mse < 1e-9 else 10.0 * log(255.0 * 255.0 / mse) / log(10.0)
