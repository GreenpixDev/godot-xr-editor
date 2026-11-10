
### 01 closed

Thread 1: frames 850, mean Main::iteration 6.07 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.335 | 1.0 |
| process | 0.708 | 1.0 |
| AudioServer::update | 0.016 | 1.0 |
| physics | 0.005 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| ScriptServer::frame | 0.000 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.342 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.504 |
| engine C++ (main/) | 0.232 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.941 | 4.941 | 1.0 |
| process | main/main.cpp:5061 | 0.204 | 0.708 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.186 | 0.186 | 14.7 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.096 | 0.096 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.078 | 0.078 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.026 | 0.026 | 0.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.021 | 0.021 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.017 | 0.017 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.016 | 0.040 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.016 | 0.016 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.014 | 0.108 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.012 | 0.022 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.011 | 0.011 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.011 | 0.011 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.010 | 0.068 | 2.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.009 | 0.033 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.028 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.008 | 0.009 | 2.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 6.076 | 1.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1124 | 0.007 | 0.007 | 12.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.007 | 0.007 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1119 | 0.007 | 0.007 | 14.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1107 | 0.006 | 0.012 | 12.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.006 | 0.012 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.006 | 0.025 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.087 |
| res://addons/xr_editor/xr/simulator.gd | 0.071 |
| res://addons/xr_editor/tools/manipulator.gd | 0.066 |
| res://addons/xr_editor/core/feature_settings.gd | 0.053 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.052 |
| res://addons/xr_editor/xr/hand.gd | 0.024 |
| res://addons/xr_editor/ui/panels.gd | 0.022 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.020 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.013 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.001 |
| res://addons/xr_editor/tools/undo.gd | 0.001 |

### 02 open

Thread 1: frames 857, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.457 | 1.0 |
| process | 1.570 | 1.0 |
| AudioServer::update | 0.015 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.455 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.339 |
| engine C++ (main/) | 0.248 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.559 | 3.559 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.480 | 0.480 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.266 | 0.266 | 1.0 |
| process | main/main.cpp:5061 | 0.221 | 1.570 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.119 | 0.242 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.104 | 0.104 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.070 | 0.070 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.064 | 0.401 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.049 | 0.049 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.041 | 0.041 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.032 | 0.053 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.027 | 0.027 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.026 | 0.333 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.022 | 0.045 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.020 | 0.091 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.019 | 0.037 | 4.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.019 | 0.019 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.018 | 0.018 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.017 | 0.628 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.016 | 0.025 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.016 | 0.021 | 15.5 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.017 | 24.0 |
| AudioServer::update | main/main.cpp:5111 | 0.015 | 0.015 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.015 | 0.294 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.015 | 0.015 | 0.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.598 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.226 |
| res://addons/xr_editor/xr/simulator.gd | 0.073 |
| res://addons/xr_editor/tools/manipulator.gd | 0.066 |
| res://addons/xr_editor/core/feature_settings.gd | 0.057 |
| res://addons/xr_editor/ui/panels.gd | 0.046 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.043 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.040 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.029 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.021 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 03 open_graph100

Thread 1: frames 837, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.456 | 1.0 |
| process | 2.577 | 1.0 |
| AudioServer::update | 0.015 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 3D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.459 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.341 |
| engine C++ (main/) | 0.251 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.655 | 1.655 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.999 | 0.999 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.635 | 0.635 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.357 | 0.753 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.266 | 0.266 | 500.6 |
| process | main/main.cpp:5061 | 0.224 | 2.577 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.193 | 1.139 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.146 | 0.146 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.125 | 0.125 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.097 | 0.159 | 4.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.078 | 0.078 | 156.2 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.070 | 0.149 | 61.6 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.058 | 0.058 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.056 | 0.072 | 59.1 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.043 | 0.299 | 488.6 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.042 | 0.060 | 72.1 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.037 | 0.252 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.026 | 0.734 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.024 | 0.024 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.019 | 0.089 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.019 | 0.019 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.019 | 0.038 | 4.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5625 | 0.018 | 0.018 | 72.1 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.017 | 1.188 | 1.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.015 | 0.016 | 24.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 1.601 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.226 |
| res://addons/xr_editor/xr/simulator.gd | 0.072 |
| res://addons/xr_editor/tools/manipulator.gd | 0.072 |
| res://addons/xr_editor/core/feature_settings.gd | 0.056 |
| res://addons/xr_editor/ui/panels.gd | 0.046 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.044 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.036 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.030 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.021 |
| res://addons/xr_editor/xr/session.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 04 open_graph250

Thread 1: frames 610, mean Main::iteration 8.34 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| process | 4.271 | 1.0 |
| RenderingServer::draw | 4.052 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.008 | 0.5 |
| physics_process | 0.004 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| NavigationServer3D::physics_process | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.053 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 3.999 |
| engine C++ (main/) | 0.289 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 2.346 | 2.346 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 1.501 | 1.501 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.740 | 1.371 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.545 | 0.545 | 1222.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.460 | 2.218 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.338 | 0.338 | 12.0 |
| process | main/main.cpp:5061 | 0.261 | 4.271 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.222 | 0.355 | 4.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.161 | 0.344 | 148.5 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.155 | 0.155 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.130 | 0.168 | 146.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.120 | 0.120 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.096 | 0.632 | 1210.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.089 | 0.568 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.087 | 0.122 | 168.3 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.040 | 0.040 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5625 | 0.034 | 0.034 | 168.3 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.026 | 1.335 | 2.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2974 | 0.025 | 0.025 | 148.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.022 | 0.022 | 0.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.021 | 0.021 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.019 | 0.038 | 4.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.019 | 0.094 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.018 | 2.119 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.015 | 1.418 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 3.199 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.239 |
| res://addons/xr_editor/tools/manipulator.gd | 0.092 |
| res://addons/xr_editor/xr/simulator.gd | 0.077 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.057 |
| res://addons/xr_editor/core/feature_settings.gd | 0.055 |
| res://addons/xr_editor/ui/panels.gd | 0.048 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.036 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.030 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 05 open_graph500

Thread 1: frames 296, mean Main::iteration 17.16 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 9.025 | 1.0 |
| process | 8.109 | 1.0 |
| AudioServer::update | 0.025 | 1.0 |
| physics | 0.021 | 1.0 |
| Physics Step | 0.021 | 1.0 |
| physics_process | 0.010 | 1.0 |
| PhysicsServer3D::sync | 0.003 | 1.0 |
| PhysicsServer2D::sync | 0.002 | 1.0 |
| NavigationServer3D::physics_process | 0.002 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| 2D physics | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.0 |
| main loop iteration prepare | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 1.0 |
| main loop iteration end | 0.000 | 1.0 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 9.022 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 7.793 |
| engine C++ (main/) | 0.381 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.011 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 5.575 | 5.575 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 3.135 | 3.135 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 1.619 | 2.886 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 1.082 | 1.082 | 2426.1 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 1.058 | 4.736 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.734 | 0.734 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.532 | 0.823 | 4.0 |
| process | main/main.cpp:5061 | 0.325 | 8.109 | 1.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.325 | 0.700 | 295.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.270 | 0.346 | 293.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.240 | 0.240 | 1.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.199 | 0.199 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.197 | 1.268 | 2414.1 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.186 | 0.264 | 328.8 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.179 | 1.108 | 0.5 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5625 | 0.079 | 0.079 | 328.8 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.062 | 0.062 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.058 | 0.058 | 0.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2974 | 0.051 | 0.051 | 295.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.031 | 2.575 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.030 | 0.030 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.029 | 0.702 | 281.9 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4471 | 0.028 | 0.375 | 293.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4561 | 0.026 | 0.076 | 293.0 |
| AudioServer::update | main/main.cpp:5111 | 0.025 | 0.025 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 6.738 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.293 |
| res://addons/xr_editor/tools/manipulator.gd | 0.125 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.105 |
| res://addons/xr_editor/xr/simulator.gd | 0.103 |
| res://addons/xr_editor/core/feature_settings.gd | 0.068 |
| res://addons/xr_editor/ui/panels.gd | 0.064 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.043 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.037 |
| res://addons/xr_editor/xr/hand.gd | 0.034 |
| res://addons/xr_editor/tools/icons.gd | 0.029 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/xr/session.gd | 0.024 |
| res://addons/xr_editor/tools/locomotion.gd | 0.016 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.010 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.007 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 06 open

Thread 1: frames 839, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.633 | 1.0 |
| process | 1.398 | 1.0 |
| AudioServer::update | 0.013 | 1.0 |
| physics | 0.005 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.632 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.184 |
| engine C++ (main/) | 0.228 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.789 | 3.789 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.460 | 0.460 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.248 | 0.248 | 1.0 |
| process | main/main.cpp:5061 | 0.204 | 1.398 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.094 | 0.163 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.093 | 0.093 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.068 | 0.068 | 140.1 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.061 | 0.314 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.046 | 0.046 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.030 | 0.050 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.029 | 0.029 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.024 | 0.281 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.021 | 0.043 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.019 | 0.085 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.018 | 0.035 | 4.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.016 | 0.560 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.016 | 0.016 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.016 | 0.016 | 2.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.016 | 0.023 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.015 | 0.020 | 15.5 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.015 | 0.015 | 0.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.014 | 0.015 | 24.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.014 | 0.242 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.013 | 0.013 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.013 | 0.088 | 0.5 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.502 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.209 |
| res://addons/xr_editor/xr/simulator.gd | 0.067 |
| res://addons/xr_editor/tools/manipulator.gd | 0.059 |
| res://addons/xr_editor/core/feature_settings.gd | 0.054 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.042 |
| res://addons/xr_editor/ui/panels.gd | 0.042 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.033 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.027 |
| res://addons/xr_editor/xr/hand.gd | 0.026 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 07 closed

Thread 1: frames 842, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.436 | 1.0 |
| process | 0.607 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.004 | 1.0 |
| Physics Step | 0.004 | 0.4 |
| physics_process | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.000 | 0.4 |
| process 2D navigation | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.434 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.451 |
| engine C++ (main/) | 0.179 |
| engine C++ (platform/) | 0.006 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 5.068 | 5.068 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.184 | 0.184 | 14.7 |
| process | main/main.cpp:5061 | 0.157 | 0.607 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.079 | 0.079 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.069 | 0.069 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.015 | 0.036 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.014 | 0.014 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.014 | 0.103 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.010 | 0.060 | 2.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.009 | 0.017 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.009 | 0.009 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.009 | 0.009 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.008 | 0.025 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.007 | 0.028 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.007 | 0.008 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.007 | 0.009 | 1.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1124 | 0.006 | 0.006 | 12.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.006 | 0.011 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1119 | 0.006 | 0.006 | 14.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.006 | 6.062 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1107 | 0.006 | 0.011 | 12.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.006 | 0.006 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.082 |
| res://addons/xr_editor/tools/manipulator.gd | 0.060 |
| res://addons/xr_editor/xr/simulator.gd | 0.059 |
| res://addons/xr_editor/core/feature_settings.gd | 0.049 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.038 |
| res://addons/xr_editor/xr/hand.gd | 0.022 |
| res://addons/xr_editor/xr/rig.gd | 0.020 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.019 |
| res://addons/xr_editor/ui/panels.gd | 0.018 |
| res://addons/xr_editor/tools/icons.gd | 0.018 |
| res://addons/xr_editor/xr/session.gd | 0.010 |
| res://addons/xr_editor/tools/locomotion.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/tools/outline.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/palette.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.003 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.001 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.001 |
| res://addons/xr_editor/tools/undo.gd | 0.001 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.001 |
