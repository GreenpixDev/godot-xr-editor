
### 01 closed

Thread 1: frames 842, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.378 | 1.0 |
| process | 0.654 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.007 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| process 2D navigation | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.377 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.471 |
| engine C++ (main/) | 0.206 |
| engine C++ (platform/) | 0.006 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.982 | 4.982 | 1.0 |
| process | main/main.cpp:5061 | 0.183 | 0.654 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.178 | 0.178 | 14.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.098 | 0.098 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.085 | 0.085 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.022 | 0.022 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.016 | 0.016 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.015 | 0.039 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.015 | 0.106 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.070 | 2.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.010 | 0.019 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.010 | 0.010 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.010 | 0.010 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.008 | 0.027 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.008 | 0.031 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3290 | 0.007 | 0.008 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1089 | 0.007 | 0.007 | 12.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1072 | 0.006 | 0.012 | 12.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1084 | 0.006 | 0.006 | 14.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.006 | 0.098 | 1.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.006 | 0.011 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.006 | 6.060 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.006 | 0.008 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.084 |
| res://addons/xr_editor/tools/manipulator.gd | 0.067 |
| res://addons/xr_editor/xr/simulator.gd | 0.064 |
| res://addons/xr_editor/core/feature_settings.gd | 0.053 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.039 |
| res://addons/xr_editor/xr/hand.gd | 0.023 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.020 |
| res://addons/xr_editor/tools/icons.gd | 0.020 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.001 |
| res://addons/xr_editor/tools/undo.gd | 0.001 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.001 |

### 02 open

Thread 1: frames 839, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.291 | 1.0 |
| process | 1.742 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.007 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| process 2D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.290 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.533 |
| engine C++ (main/) | 0.223 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.006 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.397 | 3.397 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.486 | 0.486 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.282 | 0.282 | 1.0 |
| process | main/main.cpp:5061 | 0.199 | 1.742 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.126 | 0.135 | 41.2 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.126 | 0.331 | 18.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4011 | 0.116 | 0.238 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.089 | 0.089 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4070 | 0.069 | 0.069 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3604 | 0.064 | 0.393 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4033 | 0.046 | 0.046 | 12.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.041 | 0.041 | 1249.5 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.040 | 0.040 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5487 | 0.030 | 0.051 | 4.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.023 | 0.319 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.019 | 0.019 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.019 | 0.085 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.018 | 0.018 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.018 | 0.036 | 4.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.016 | 0.021 | 15.5 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.858 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.016 | 0.349 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5514 | 0.016 | 0.024 | 24.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.016 | 24.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.843 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.210 |
| res://addons/xr_editor/xr/simulator.gd | 0.065 |
| res://addons/xr_editor/tools/manipulator.gd | 0.065 |
| res://addons/xr_editor/core/feature_settings.gd | 0.055 |
| res://addons/xr_editor/ui/panels.gd | 0.043 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.040 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.039 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.025 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.020 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.003 |

### 03 open_graph100

Thread 1: frames 835, mean Main::iteration 6.11 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| process | 3.640 | 1.0 |
| RenderingServer::draw | 2.446 | 1.0 |
| AudioServer::update | 0.011 | 1.0 |
| physics | 0.007 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.003 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 3.398 |
| engine C++ (servers/) | 2.447 |
| engine C++ (main/) | 0.258 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.260 | 1.260 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.750 | 0.750 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.580 | 0.617 | 201.1 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.454 | 1.329 | 61.6 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4011 | 0.336 | 0.710 | 12.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 0.284 | 0.284 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4070 | 0.252 | 0.252 | 500.6 |
| process | main/main.cpp:5061 | 0.233 | 3.640 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3604 | 0.182 | 1.075 | 4.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.151 | 0.151 | 4763.7 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4033 | 0.137 | 0.137 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.114 | 0.114 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5487 | 0.092 | 0.149 | 4.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.074 | 0.074 | 156.2 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.058 | 0.074 | 59.1 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.049 | 1.385 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4016 | 0.040 | 0.283 | 488.6 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5514 | 0.040 | 0.056 | 72.1 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.027 | 0.027 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.026 | 0.026 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.024 | 0.702 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.019 | 0.089 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.018 | 0.036 | 4.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4458 | 0.018 | 0.461 | 158.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.017 | 2.289 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 2.663 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.221 |
| res://addons/xr_editor/tools/manipulator.gd | 0.083 |
| res://addons/xr_editor/xr/simulator.gd | 0.070 |
| res://addons/xr_editor/core/feature_settings.gd | 0.056 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.046 |
| res://addons/xr_editor/ui/panels.gd | 0.044 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.035 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.026 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.021 |
| res://addons/xr_editor/xr/session.gd | 0.012 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 04 open

Thread 1: frames 843, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.290 | 1.0 |
| process | 1.742 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.007 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| process 2D navigation | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.288 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.533 |
| engine C++ (main/) | 0.224 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.383 | 3.383 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.495 | 0.495 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.283 | 0.283 | 1.0 |
| process | main/main.cpp:5061 | 0.200 | 1.742 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.127 | 0.334 | 18.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.127 | 0.136 | 41.2 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4011 | 0.115 | 0.236 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.089 | 0.089 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4070 | 0.069 | 0.069 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3604 | 0.062 | 0.388 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4033 | 0.046 | 0.046 | 12.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.041 | 0.041 | 1249.5 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.040 | 0.040 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5487 | 0.031 | 0.051 | 4.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.023 | 0.319 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.019 | 0.085 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.018 | 0.036 | 4.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.017 | 0.022 | 15.5 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.016 | 0.352 | 0.5 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.862 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5514 | 0.016 | 0.023 | 24.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.015 | 0.016 | 24.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.841 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.210 |
| res://addons/xr_editor/tools/manipulator.gd | 0.066 |
| res://addons/xr_editor/xr/simulator.gd | 0.066 |
| res://addons/xr_editor/core/feature_settings.gd | 0.055 |
| res://addons/xr_editor/ui/panels.gd | 0.043 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.041 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.039 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.025 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.020 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 05 closed

Thread 1: frames 842, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.354 | 1.0 |
| process | 0.678 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.007 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| process 2D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.353 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.493 |
| engine C++ (main/) | 0.209 |
| engine C++ (platform/) | 0.006 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.943 | 4.943 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.188 | 0.188 | 14.7 |
| process | main/main.cpp:5061 | 0.185 | 0.678 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.103 | 0.103 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.084 | 0.084 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.021 | 0.021 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.016 | 0.016 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.016 | 0.039 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.015 | 0.114 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.066 | 2.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.010 | 0.010 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.010 | 0.010 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.010 | 0.019 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.008 | 0.027 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.008 | 0.010 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.007 | 0.030 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1089 | 0.007 | 0.007 | 12.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3290 | 0.007 | 0.008 | 2.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.007 | 0.012 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.006 | 0.012 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1084 | 0.006 | 0.006 | 14.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.006 | 6.060 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.006 | 0.102 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.091 |
| res://addons/xr_editor/tools/manipulator.gd | 0.067 |
| res://addons/xr_editor/xr/simulator.gd | 0.064 |
| res://addons/xr_editor/core/feature_settings.gd | 0.053 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.041 |
| res://addons/xr_editor/xr/hand.gd | 0.023 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.022 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.020 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.001 |
| res://addons/xr_editor/tools/undo.gd | 0.001 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.001 |
