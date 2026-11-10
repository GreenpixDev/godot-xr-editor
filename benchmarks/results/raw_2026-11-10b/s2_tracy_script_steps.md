
### 01 closed

Thread 1: frames 844, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.404 | 1.0 |
| process | 0.630 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.005 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.403 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.455 |
| engine C++ (main/) | 0.198 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 5.019 | 5.019 | 1.0 |
| process | main/main.cpp:5061 | 0.175 | 0.630 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.174 | 0.174 | 14.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.095 | 0.095 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.083 | 0.083 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.015 | 0.037 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.014 | 0.014 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:820 | 0.013 | 0.099 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.013 | 0.013 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.010 | 0.063 | 2.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.010 | 0.018 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.010 | 0.010 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.009 | 0.009 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.009 | 0.031 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.008 | 0.027 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3291 | 0.007 | 0.008 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1101 | 0.007 | 0.007 | 12.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.007 | 6.060 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1096 | 0.007 | 0.007 | 14.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1084 | 0.006 | 0.012 | 12.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.006 | 0.011 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.006 | 0.089 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.006 | 0.023 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.081 |
| res://addons/xr_editor/xr/simulator.gd | 0.064 |
| res://addons/xr_editor/tools/manipulator.gd | 0.060 |
| res://addons/xr_editor/core/feature_settings.gd | 0.052 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.035 |
| res://addons/xr_editor/xr/hand.gd | 0.023 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.017 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.001 |
| res://addons/xr_editor/tools/undo.gd | 0.001 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.001 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.001 |

### 02 open

Thread 1: frames 842, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.279 | 1.0 |
| process | 1.753 | 1.0 |
| AudioServer::update | 0.013 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.278 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.545 |
| engine C++ (main/) | 0.222 |
| GDScript: other scripts, with engine calls made from them | 0.010 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.396 | 3.396 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.475 | 0.475 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.277 | 0.277 | 1.0 |
| process | main/main.cpp:5061 | 0.198 | 1.753 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4531 | 0.129 | 0.138 | 41.2 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4492 | 0.123 | 0.330 | 18.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4023 | 0.117 | 0.242 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.093 | 0.093 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4082 | 0.071 | 0.071 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3616 | 0.063 | 0.398 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4045 | 0.047 | 0.047 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4064 | 0.041 | 0.041 | 78.1 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4503 | 0.040 | 0.040 | 1248.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5550 | 0.031 | 0.051 | 4.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.024 | 0.321 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.019 | 0.037 | 4.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.019 | 0.019 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4164 | 0.019 | 0.083 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.018 | 0.018 | 2.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4520 | 0.017 | 0.022 | 15.5 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:820 | 0.016 | 0.859 | 1.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.017 | 24.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5577 | 0.016 | 0.023 | 24.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4430 | 0.016 | 0.349 | 0.5 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3291 | 0.015 | 0.291 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.845 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.212 |
| res://addons/xr_editor/xr/simulator.gd | 0.067 |
| res://addons/xr_editor/tools/manipulator.gd | 0.063 |
| res://addons/xr_editor/core/feature_settings.gd | 0.056 |
| res://addons/xr_editor/ui/panels.gd | 0.045 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.040 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.039 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.026 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.020 |
| res://addons/xr_editor/xr/session.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.010 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 03 open_graph100

Thread 1: frames 838, mean Main::iteration 6.07 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| process | 3.548 | 1.0 |
| RenderingServer::draw | 2.508 | 1.0 |
| AudioServer::update | 0.011 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 3.324 |
| engine C++ (servers/) | 2.509 |
| engine C++ (main/) | 0.237 |
| GDScript: other scripts, with engine calls made from them | 0.010 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.131 | 1.131 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.714 | 0.714 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4531 | 0.584 | 0.619 | 200.7 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 0.518 | 0.518 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4492 | 0.436 | 1.305 | 61.5 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4023 | 0.332 | 0.707 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4082 | 0.252 | 0.252 | 500.6 |
| process | main/main.cpp:5061 | 0.214 | 3.548 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3616 | 0.178 | 1.069 | 4.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4503 | 0.144 | 0.144 | 4758.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4045 | 0.139 | 0.139 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.108 | 0.108 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5550 | 0.089 | 0.145 | 4.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4064 | 0.075 | 0.075 | 156.2 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4520 | 0.057 | 0.074 | 59.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4430 | 0.048 | 1.360 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5577 | 0.039 | 0.054 | 72.1 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4028 | 0.039 | 0.282 | 488.6 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.025 | 0.025 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.024 | 0.024 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.024 | 0.695 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.018 | 0.035 | 4.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4164 | 0.018 | 0.084 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4513 | 0.017 | 0.463 | 157.7 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:820 | 0.016 | 2.246 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 2.622 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.211 |
| res://addons/xr_editor/tools/manipulator.gd | 0.077 |
| res://addons/xr_editor/xr/simulator.gd | 0.066 |
| res://addons/xr_editor/core/feature_settings.gd | 0.053 |
| res://addons/xr_editor/ui/panels.gd | 0.043 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.043 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.033 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.027 |
| res://addons/xr_editor/xr/hand.gd | 0.026 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.012 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/blueprints/document.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 04 open_graph250

Thread 1: frames 427, mean Main::iteration 11.95 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| process | 7.055 | 1.0 |
| RenderingServer::draw | 4.890 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.012 | 1.0 |
| Physics Step | 0.012 | 0.7 |
| physics_process | 0.005 | 0.7 |
| PhysicsServer3D::sync | 0.002 | 0.7 |
| PhysicsServer2D::sync | 0.001 | 0.7 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.7 |
| NavigationServer2D::physics_process | 0.001 | 0.7 |
| ScriptServer::frame | 0.001 | 1.0 |
| 2D physics | 0.001 | 0.7 |
| 3D physics | 0.000 | 0.7 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.7 |
| setup | 0.000 | 0.7 |
| main loop iteration end | 0.000 | 0.7 |

| Own time by area | ms/frame |
|---|---|
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 6.765 |
| engine C++ (servers/) | 4.888 |
| engine C++ (main/) | 0.312 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 2.988 | 2.988 | 16.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 1.698 | 1.698 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4531 | 1.413 | 1.497 | 513.2 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4492 | 1.066 | 3.163 | 148.8 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4023 | 0.722 | 1.352 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4082 | 0.547 | 0.547 | 1222.9 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3616 | 0.446 | 2.182 | 4.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4503 | 0.348 | 0.348 | 11805.6 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4045 | 0.335 | 0.335 | 12.0 |
| process | main/main.cpp:5061 | 0.278 | 7.055 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5550 | 0.225 | 0.356 | 4.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.153 | 0.153 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4520 | 0.136 | 0.175 | 146.3 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4430 | 0.112 | 3.293 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4028 | 0.092 | 0.630 | 1210.8 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5577 | 0.086 | 0.121 | 168.4 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.052 | 0.052 | 2.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4513 | 0.046 | 1.251 | 438.1 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.037 | 0.037 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5582 | 0.034 | 0.034 | 168.4 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.032 | 0.032 | 0.0 |
| set_instance_transform | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4552 | 0.030 | 0.030 | 513.2 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2969 | 0.027 | 0.027 | 148.3 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.026 | 1.320 | 2.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4536 | 0.021 | 0.021 | 513.2 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 5.891 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.247 |
| res://addons/xr_editor/tools/manipulator.gd | 0.123 |
| res://addons/xr_editor/xr/simulator.gd | 0.081 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.073 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/ui/panels.gd | 0.050 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.036 |
| res://addons/xr_editor/xr/hand.gd | 0.030 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.030 |
| res://addons/xr_editor/tools/icons.gd | 0.024 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.016 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 05 open_graph500

Thread 1: frames 224, mean Main::iteration 22.61 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| process | 12.001 | 1.0 |
| RenderingServer::draw | 10.641 | 1.0 |
| AudioServer::update | 0.021 | 1.0 |
| physics | 0.020 | 1.0 |
| Physics Step | 0.020 | 1.4 |
| physics_process | 0.010 | 1.4 |
| PhysicsServer3D::sync | 0.003 | 1.4 |
| PhysicsServer2D::sync | 0.002 | 1.4 |
| NavigationServer3D::physics_process | 0.001 | 1.4 |
| NavigationServer2D::physics_process | 0.001 | 1.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| 2D physics | 0.001 | 1.4 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.4 |
| main loop iteration prepare | 0.001 | 1.4 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 1.4 |
| main loop iteration end | 0.000 | 1.4 |

| Own time by area | ms/frame |
|---|---|
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 11.739 |
| engine C++ (servers/) | 10.639 |
| engine C++ (main/) | 0.360 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.010 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 6.848 | 6.848 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 3.534 | 3.534 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4492 | 2.090 | 4.771 | 296.1 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4023 | 1.611 | 2.839 | 12.1 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4531 | 1.436 | 1.522 | 516.6 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3616 | 1.096 | 4.748 | 4.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4082 | 1.056 | 1.056 | 2437.4 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4045 | 0.754 | 0.754 | 12.1 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4503 | 0.705 | 0.705 | 23687.6 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5550 | 0.525 | 0.804 | 4.0 |
| process | main/main.cpp:5061 | 0.309 | 12.001 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4520 | 0.276 | 0.354 | 293.6 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4430 | 0.239 | 5.043 | 0.5 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.195 | 0.195 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4028 | 0.184 | 1.229 | 2425.3 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5577 | 0.178 | 0.253 | 330.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5582 | 0.075 | 0.075 | 330.2 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.070 | 0.070 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.070 | 0.070 | 0.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2969 | 0.053 | 0.053 | 295.6 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4513 | 0.046 | 1.284 | 444.1 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.041 | 0.041 | 2.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.032 | 4.687 | 282.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.031 | 2.665 | 2.0 |
| set_instance_transform | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4552 | 0.031 | 0.031 | 516.6 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 10.663 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.295 |
| res://addons/xr_editor/tools/manipulator.gd | 0.146 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.122 |
| res://addons/xr_editor/xr/simulator.gd | 0.096 |
| res://addons/xr_editor/core/feature_settings.gd | 0.065 |
| res://addons/xr_editor/ui/panels.gd | 0.062 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.043 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.037 |
| res://addons/xr_editor/xr/hand.gd | 0.035 |
| res://addons/xr_editor/tools/icons.gd | 0.029 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.005 |

### 06 open

Thread 1: frames 843, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.381 | 1.0 |
| process | 1.654 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.005 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.386 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.448 |
| engine C++ (main/) | 0.219 |
| GDScript: other scripts, with engine calls made from them | 0.010 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.480 | 3.480 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.491 | 0.491 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.285 | 0.285 | 1.0 |
| process | main/main.cpp:5061 | 0.196 | 1.654 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4531 | 0.130 | 0.139 | 41.3 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4492 | 0.121 | 0.329 | 18.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4023 | 0.094 | 0.160 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.090 | 0.090 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4082 | 0.064 | 0.064 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3616 | 0.064 | 0.316 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4045 | 0.047 | 0.047 | 12.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4503 | 0.039 | 0.039 | 1249.5 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5550 | 0.030 | 0.050 | 4.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.024 | 0.281 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.019 | 0.019 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4164 | 0.019 | 0.084 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.018 | 0.037 | 4.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.017 | 0.017 | 2.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4520 | 0.016 | 0.022 | 15.5 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:820 | 0.016 | 0.818 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4430 | 0.016 | 0.348 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5577 | 0.016 | 0.023 | 24.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.015 | 0.015 | 0.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3291 | 0.015 | 0.243 | 2.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.014 | 0.015 | 24.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.760 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.210 |
| res://addons/xr_editor/xr/simulator.gd | 0.065 |
| res://addons/xr_editor/tools/manipulator.gd | 0.064 |
| res://addons/xr_editor/core/feature_settings.gd | 0.055 |
| res://addons/xr_editor/ui/panels.gd | 0.044 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.042 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.034 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.026 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.020 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/blueprints/document.gd | 0.010 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 07 closed

Thread 1: frames 838, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.349 | 1.0 |
| process | 0.683 | 1.0 |
| AudioServer::update | 0.013 | 1.0 |
| physics | 0.005 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.348 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.496 |
| engine C++ (main/) | 0.210 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.938 | 4.938 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.189 | 0.189 | 14.7 |
| process | main/main.cpp:5061 | 0.187 | 0.683 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.103 | 0.103 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.083 | 0.083 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.016 | 0.039 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.016 | 0.016 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:820 | 0.015 | 0.114 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.013 | 0.013 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.011 | 0.019 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.010 | 0.064 | 2.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.010 | 0.010 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.010 | 0.010 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.027 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.008 | 0.031 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.008 | 0.010 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3291 | 0.008 | 0.008 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1101 | 0.007 | 0.007 | 12.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.007 | 6.059 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4164 | 0.007 | 0.012 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1096 | 0.006 | 0.006 | 14.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1084 | 0.006 | 0.012 | 12.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.006 | 0.011 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.092 |
| res://addons/xr_editor/tools/manipulator.gd | 0.065 |
| res://addons/xr_editor/xr/simulator.gd | 0.065 |
| res://addons/xr_editor/core/feature_settings.gd | 0.052 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.041 |
| res://addons/xr_editor/xr/hand.gd | 0.024 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.020 |
| res://addons/xr_editor/xr/session.gd | 0.012 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.001 |
| res://addons/xr_editor/tools/undo.gd | 0.001 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.001 |
