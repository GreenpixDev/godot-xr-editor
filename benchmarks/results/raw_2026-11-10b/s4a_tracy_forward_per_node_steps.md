
### 01 closed

Thread 1: frames 840, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.377 | 1.0 |
| process | 0.653 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.007 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 2D navigation | 0.000 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.376 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.462 |
| engine C++ (main/) | 0.217 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.977 | 4.977 | 1.0 |
| process | main/main.cpp:5061 | 0.190 | 0.653 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.179 | 0.179 | 14.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.098 | 0.098 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.088 | 0.088 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.021 | 0.021 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.015 | 0.015 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.015 | 0.037 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.013 | 0.101 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.010 | 0.021 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.010 | 0.010 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.010 | 0.064 | 2.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.010 | 0.010 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.008 | 0.028 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.008 | 0.030 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.007 | 0.008 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1124 | 0.007 | 0.007 | 12.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.007 | 6.061 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1119 | 0.006 | 0.006 | 14.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1107 | 0.006 | 0.012 | 12.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.006 | 0.011 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.006 | 0.024 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.006 | 0.090 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.081 |
| res://addons/xr_editor/xr/simulator.gd | 0.067 |
| res://addons/xr_editor/tools/manipulator.gd | 0.062 |
| res://addons/xr_editor/core/feature_settings.gd | 0.051 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.037 |
| res://addons/xr_editor/xr/hand.gd | 0.023 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.020 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.018 |
| res://addons/xr_editor/xr/session.gd | 0.012 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.001 |
| res://addons/xr_editor/xr/standalone.gd | 0.001 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.001 |
| res://addons/xr_editor/tools/undo.gd | 0.001 |

### 02 open

Thread 1: frames 838, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.534 | 1.0 |
| process | 1.505 | 1.0 |
| AudioServer::update | 0.015 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.008 | 0.4 |
| physics_process | 0.003 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.532 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.284 |
| engine C++ (main/) | 0.239 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.655 | 3.655 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.467 | 0.467 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.276 | 0.276 | 1.0 |
| process | main/main.cpp:5061 | 0.211 | 1.505 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.116 | 0.239 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.095 | 0.095 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.070 | 0.070 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.062 | 0.393 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.047 | 0.047 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.040 | 0.040 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.031 | 0.052 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.025 | 0.025 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.023 | 0.319 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.021 | 0.044 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.019 | 0.085 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.018 | 0.036 | 4.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.017 | 0.017 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.016 | 0.594 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.016 | 0.016 | 2.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.016 | 0.024 | 24.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.016 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.016 | 0.020 | 15.5 |
| AudioServer::update | main/main.cpp:5111 | 0.015 | 0.015 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.015 | 0.289 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.578 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.211 |
| res://addons/xr_editor/xr/simulator.gd | 0.072 |
| res://addons/xr_editor/tools/manipulator.gd | 0.060 |
| res://addons/xr_editor/core/feature_settings.gd | 0.057 |
| res://addons/xr_editor/ui/panels.gd | 0.045 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.040 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.040 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.027 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.020 |
| res://addons/xr_editor/xr/session.gd | 0.013 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 03 open_graph100

Thread 1: frames 837, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.582 | 1.0 |
| process | 2.459 | 1.0 |
| AudioServer::update | 0.013 | 1.0 |
| physics | 0.007 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| process 2D navigation | 0.000 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.581 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.254 |
| engine C++ (main/) | 0.220 |
| GDScript: other scripts, with engine calls made from them | 0.010 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.911 | 1.911 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.925 | 0.925 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.588 | 0.588 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.352 | 0.750 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.267 | 0.267 | 500.6 |
| process | main/main.cpp:5061 | 0.195 | 2.459 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.187 | 1.126 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.142 | 0.142 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.119 | 0.119 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.095 | 0.155 | 4.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.079 | 0.079 | 156.2 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.068 | 0.144 | 61.6 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.055 | 0.055 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.054 | 0.070 | 59.1 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.042 | 0.300 | 488.6 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.042 | 0.058 | 72.1 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.034 | 0.240 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.023 | 0.713 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.020 | 0.020 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.019 | 0.037 | 4.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.018 | 0.081 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5625 | 0.016 | 0.016 | 72.1 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.016 | 1.137 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.016 | 0.016 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.015 | 0.729 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 1.565 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.209 |
| res://addons/xr_editor/xr/simulator.gd | 0.069 |
| res://addons/xr_editor/tools/manipulator.gd | 0.062 |
| res://addons/xr_editor/core/feature_settings.gd | 0.056 |
| res://addons/xr_editor/ui/panels.gd | 0.044 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.040 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.036 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.029 |
| res://addons/xr_editor/xr/hand.gd | 0.026 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.012 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/blueprints/document.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.003 |

### 04 open_graph250

Thread 1: frames 707, mean Main::iteration 7.21 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| process | 3.870 | 1.0 |
| RenderingServer::draw | 3.315 | 1.0 |
| AudioServer::update | 0.010 | 1.0 |
| physics | 0.007 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.000 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 3.669 |
| engine C++ (servers/) | 3.314 |
| engine C++ (main/) | 0.216 |
| GDScript: other scripts, with engine calls made from them | 0.010 |
| engine C++ (platform/) | 0.006 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.936 | 1.936 | 16.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 1.214 | 1.214 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.682 | 1.311 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.544 | 0.544 | 1221.7 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.401 | 2.075 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.319 | 0.319 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.201 | 0.325 | 4.0 |
| process | main/main.cpp:5061 | 0.194 | 3.870 | 1.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.158 | 0.340 | 148.7 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.129 | 0.167 | 146.2 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.127 | 0.127 | 1.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.118 | 0.118 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.094 | 0.629 | 1209.7 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.085 | 0.114 | 168.2 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.081 | 0.555 | 0.5 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.031 | 0.031 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5625 | 0.029 | 0.029 | 168.2 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2974 | 0.026 | 0.026 | 148.2 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.023 | 1.277 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.019 | 0.019 | 0.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.018 | 0.035 | 4.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.018 | 0.081 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.016 | 2.012 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.015 | 0.015 | 2.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4471 | 0.015 | 0.182 | 146.2 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 3.000 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.201 |
| res://addons/xr_editor/tools/manipulator.gd | 0.072 |
| res://addons/xr_editor/xr/simulator.gd | 0.062 |
| res://addons/xr_editor/core/feature_settings.gd | 0.051 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.045 |
| res://addons/xr_editor/ui/panels.gd | 0.040 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.033 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.027 |
| res://addons/xr_editor/xr/hand.gd | 0.025 |
| res://addons/xr_editor/xr/rig.gd | 0.020 |
| res://addons/xr_editor/tools/icons.gd | 0.018 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/blueprints/document.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 05 open_graph500

Thread 1: frames 309, mean Main::iteration 16.41 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 8.686 | 1.0 |
| process | 7.699 | 1.0 |
| physics | 0.021 | 1.0 |
| Physics Step | 0.021 | 1.0 |
| AudioServer::update | 0.019 | 1.0 |
| physics_process | 0.008 | 1.0 |
| 2D physics | 0.005 | 1.0 |
| PhysicsServer3D::sync | 0.003 | 1.0 |
| PhysicsServer2D::sync | 0.002 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.0 |
| main loop iteration prepare | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| setup | 0.000 | 1.0 |
| main loop iteration end | 0.000 | 1.0 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 8.686 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 7.394 |
| engine C++ (main/) | 0.341 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 5.333 | 5.333 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 2.933 | 2.933 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 1.519 | 2.760 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 1.064 | 1.064 | 2427.8 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.996 | 4.521 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.709 | 0.709 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.484 | 0.754 | 4.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.318 | 0.695 | 294.4 |
| process | main/main.cpp:5061 | 0.293 | 7.699 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.273 | 0.348 | 291.9 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.209 | 0.209 | 1.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.197 | 0.197 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.188 | 1.242 | 2415.8 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.174 | 1.097 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.173 | 0.244 | 329.1 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 0.157 | 0.157 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5625 | 0.070 | 0.070 | 329.1 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.056 | 0.056 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.053 | 0.053 | 0.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2974 | 0.051 | 0.051 | 293.9 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4471 | 0.029 | 0.378 | 291.9 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.029 | 0.698 | 280.9 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.027 | 2.522 | 2.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4561 | 0.026 | 0.076 | 291.9 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.025 | 0.025 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 6.434 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.270 |
| res://addons/xr_editor/tools/manipulator.gd | 0.112 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.098 |
| res://addons/xr_editor/xr/simulator.gd | 0.091 |
| res://addons/xr_editor/core/feature_settings.gd | 0.063 |
| res://addons/xr_editor/ui/panels.gd | 0.056 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.041 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.034 |
| res://addons/xr_editor/xr/hand.gd | 0.033 |
| res://addons/xr_editor/tools/icons.gd | 0.025 |
| res://addons/xr_editor/xr/rig.gd | 0.025 |
| res://addons/xr_editor/xr/session.gd | 0.020 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 06 open

Thread 1: frames 842, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.461 | 1.0 |
| process | 1.559 | 1.0 |
| AudioServer::update | 0.020 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.008 | 0.4 |
| physics_process | 0.003 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.459 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.301 |
| engine C++ (main/) | 0.281 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.444 | 3.444 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.556 | 0.556 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.302 | 0.302 | 1.0 |
| process | main/main.cpp:5061 | 0.247 | 1.559 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.114 | 0.114 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.099 | 0.172 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.071 | 0.071 | 140.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.066 | 0.333 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.048 | 0.048 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.033 | 0.055 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.029 | 0.029 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.024 | 0.298 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.022 | 0.045 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.020 | 0.095 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.020 | 0.020 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.019 | 0.037 | 4.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.019 | 0.019 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.018 | 0.018 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.018 | 0.602 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.016 | 0.025 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.016 | 0.021 | 15.5 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.015 | 0.016 | 24.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.015 | 0.263 | 2.0 |
| _link_wire_hit | res://addons/xr_editor/logic_graph/blueprints.gd:6979 | 0.015 | 0.077 | 4.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.535 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.232 |
| res://addons/xr_editor/xr/simulator.gd | 0.079 |
| res://addons/xr_editor/tools/manipulator.gd | 0.068 |
| res://addons/xr_editor/core/feature_settings.gd | 0.060 |
| res://addons/xr_editor/ui/panels.gd | 0.047 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.046 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.036 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.029 |
| res://addons/xr_editor/xr/hand.gd | 0.029 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 07 closed

Thread 1: frames 839, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.193 | 1.0 |
| process | 0.829 | 1.0 |
| AudioServer::update | 0.018 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.008 | 0.4 |
| physics_process | 0.003 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.198 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.585 |
| engine C++ (main/) | 0.276 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.697 | 4.697 | 1.0 |
| process | main/main.cpp:5061 | 0.244 | 0.829 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.225 | 0.225 | 14.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.122 | 0.122 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.109 | 0.109 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.023 | 0.023 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.021 | 0.021 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.018 | 0.018 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.017 | 0.132 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.017 | 0.044 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.015 | 0.015 | 0.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.013 | 0.026 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.012 | 0.012 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.012 | 0.012 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.076 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.010 | 0.013 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.010 | 0.032 | 1.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1124 | 0.009 | 0.009 | 12.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.008 | 0.034 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.008 | 0.009 | 2.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 6.061 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.008 | 0.029 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.007 | 0.015 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.007 | 0.010 | 1.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.007 | 0.007 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.104 |
| res://addons/xr_editor/xr/simulator.gd | 0.081 |
| res://addons/xr_editor/tools/manipulator.gd | 0.078 |
| res://addons/xr_editor/core/feature_settings.gd | 0.059 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.048 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.026 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/tools/icons.gd | 0.023 |
| res://addons/xr_editor/ui/panels.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.016 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
