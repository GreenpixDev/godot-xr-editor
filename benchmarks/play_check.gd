extends Node3D
## Scene for checking play mode in the headset (docs/decisions.md, D-011): move
## the cubes in VR, play with Menu, see them where they were put, hold Menu to
## come back.
##
## The XR player is built when the game starts instead of being saved in the
## scene: XRCamera3D and XRController3D follow the trackers in the editor too
## (scene/3d/xr/xr_nodes.cpp in 4.7.2 doesn't check is_editor_hint()), so a
## saved player would move with the user's head and hands while they edit in
## the headset, and its controllers would catch the ray.

const _CONTROLLER_SIZE := Vector3(0.04, 0.04, 0.12)


func _ready() -> void:
	var xr := XRServer.find_interface("OpenXR") as OpenXRInterface
	if xr == null or not xr.is_initialized():
		print("Play check: OpenXR is not running.")
		return
	# As in Godot's XR setup guide: the runtime paces frames, not the monitor.
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	get_viewport().use_xr = true
	var origin := XROrigin3D.new()
	add_child(origin)
	origin.add_child(XRCamera3D.new())
	for tracker: StringName in [&"left_hand", &"right_hand"]:
		var mesh := BoxMesh.new()
		mesh.size = _CONTROLLER_SIZE
		var body := MeshInstance3D.new()
		body.mesh = mesh
		body.position = Vector3(0.0, 0.0, _CONTROLLER_SIZE.z / 2.0)
		var controller := XRController3D.new()
		controller.tracker = tracker
		controller.pose = &"aim"
		controller.show_when_tracked = true
		controller.add_child(body)
		origin.add_child(controller)
