
### 01 closed

Thread 1: frames 841, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.305 | 1.0 |
| process | 0.733 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.304 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.514 |
| engine C++ (main/) | 0.243 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.830 | 4.830 | 2.0 |
| process | main/main.cpp:5061 | 0.218 | 0.733 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.205 | 0.205 | 14.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.109 | 0.109 | 2.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.085 | 0.085 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.044 | 4.995 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.022 | 0.022 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.019 | 0.019 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.016 | 0.041 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.115 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:543 | 0.014 | 0.014 | 0.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.012 | 0.023 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.011 | 0.011 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.071 | 2.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.009 | 0.035 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.029 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3290 | 0.008 | 0.009 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1076 | 0.007 | 0.007 | 12.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.007 | 6.068 | 1.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.007 | 0.007 | 2.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1059 | 0.007 | 0.012 | 12.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.007 | 0.026 | 1.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.007 | 0.013 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1071 | 0.006 | 0.006 | 14.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.092 |
| res://addons/xr_editor/xr/simulator.gd | 0.073 |
| res://addons/xr_editor/tools/manipulator.gd | 0.071 |
| res://addons/xr_editor/core/feature_settings.gd | 0.055 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.039 |
| res://addons/xr_editor/xr/hand.gd | 0.025 |
| res://addons/xr_editor/ui/panels.gd | 0.023 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.021 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.021 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.002 |

### 02 open

Thread 1: frames 835, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.248 | 1.0 |
| process | 1.797 | 1.0 |
| AudioServer::update | 0.011 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.248 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.565 |
| engine C++ (main/) | 0.245 |
| GDScript: other scripts, with engine calls made from them | 0.010 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.260 | 3.260 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.526 | 0.526 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.300 | 0.300 | 2.0 |
| process | main/main.cpp:5061 | 0.221 | 1.797 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.126 | 0.135 | 41.2 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.119 | 0.325 | 18.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4011 | 0.114 | 0.234 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.084 | 0.084 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4070 | 0.069 | 0.069 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3604 | 0.062 | 0.388 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4033 | 0.047 | 0.047 | 12.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.046 | 3.617 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.042 | 0.042 | 1249.5 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.039 | 0.039 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5487 | 0.031 | 0.052 | 4.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.023 | 0.319 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.021 | 0.021 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.019 | 0.088 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.018 | 0.036 | 4.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.017 | 0.862 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.017 | 0.022 | 15.5 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.016 | 0.344 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5514 | 0.016 | 0.024 | 24.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.016 | 24.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.837 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.217 |
| res://addons/xr_editor/xr/simulator.gd | 0.072 |
| res://addons/xr_editor/tools/manipulator.gd | 0.069 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/ui/panels.gd | 0.046 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.040 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.040 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.013 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |

### 03 open_graph100

Thread 1: frames 643, mean Main::iteration 7.90 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.049 | 1.0 |
| process | 3.824 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.011 | 1.0 |
| Physics Step | 0.011 | 0.5 |
| physics_process | 0.004 | 0.5 |
| 2D physics | 0.003 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.048 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 3.558 |
| engine C++ (main/) | 0.301 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.685 | 1.685 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.342 | 1.342 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.802 | 0.802 | 2.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.586 | 0.624 | 201.6 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.436 | 1.329 | 61.8 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4011 | 0.358 | 0.753 | 12.0 |
| process | main/main.cpp:5061 | 0.270 | 3.824 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4070 | 0.265 | 0.265 | 501.6 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3604 | 0.194 | 1.143 | 4.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.158 | 0.158 | 4780.2 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4033 | 0.147 | 0.147 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.106 | 0.106 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5487 | 0.098 | 0.159 | 4.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.079 | 0.079 | 156.5 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.075 | 2.574 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.059 | 0.077 | 59.3 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.051 | 1.387 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5514 | 0.042 | 0.059 | 72.2 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4016 | 0.041 | 0.296 | 489.5 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.029 | 0.029 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.028 | 0.028 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.025 | 0.724 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.020 | 0.039 | 4.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:543 | 0.019 | 0.019 | 0.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.019 | 0.093 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 2.745 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.237 |
| res://addons/xr_editor/tools/manipulator.gd | 0.089 |
| res://addons/xr_editor/xr/simulator.gd | 0.083 |
| res://addons/xr_editor/core/feature_settings.gd | 0.061 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.050 |
| res://addons/xr_editor/ui/panels.gd | 0.050 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.037 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.031 |
| res://addons/xr_editor/xr/hand.gd | 0.030 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/tools/icons.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 04 open_graph250

Thread 1: frames 320, mean Main::iteration 15.84 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 8.171 | 1.0 |
| process | 7.619 | 1.0 |
| physics | 0.024 | 1.0 |
| Physics Step | 0.024 | 1.0 |
| AudioServer::update | 0.018 | 1.0 |
| physics_process | 0.009 | 1.0 |
| 2D physics | 0.006 | 1.0 |
| PhysicsServer3D::sync | 0.003 | 1.0 |
| PhysicsServer2D::sync | 0.002 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.0 |
| main loop iteration prepare | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 1.0 |
| main loop iteration end | 0.000 | 1.0 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 8.182 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 7.311 |
| engine C++ (main/) | 0.367 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.011 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 3.354 | 3.354 | 16.9 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.715 | 2.715 | 2.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 1.838 | 1.838 | 2.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 1.427 | 1.520 | 514.5 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 1.048 | 3.209 | 149.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4011 | 0.822 | 1.477 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4070 | 0.569 | 0.569 | 1221.9 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3604 | 0.556 | 2.469 | 4.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.381 | 0.381 | 11822.4 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4033 | 0.380 | 0.380 | 12.0 |
| process | main/main.cpp:5061 | 0.316 | 7.619 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5487 | 0.264 | 0.413 | 4.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.138 | 0.179 | 146.5 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.124 | 3.337 | 0.5 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.123 | 0.123 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.107 | 4.676 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4016 | 0.096 | 0.655 | 1209.9 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5514 | 0.095 | 0.138 | 168.3 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.053 | 0.053 | 2.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4458 | 0.049 | 1.272 | 439.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5519 | 0.044 | 0.044 | 168.3 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:543 | 0.042 | 0.042 | 0.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.039 | 0.039 | 2.0 |
| set_instance_transform | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4497 | 0.030 | 0.030 | 514.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.029 | 1.418 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 6.298 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.281 |
| res://addons/xr_editor/tools/manipulator.gd | 0.128 |
| res://addons/xr_editor/xr/simulator.gd | 0.100 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.084 |
| res://addons/xr_editor/core/feature_settings.gd | 0.068 |
| res://addons/xr_editor/ui/panels.gd | 0.062 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.043 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.036 |
| res://addons/xr_editor/xr/hand.gd | 0.035 |
| res://addons/xr_editor/tools/icons.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.026 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/tools/locomotion.gd | 0.016 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.010 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 05 open_graph500

Thread 1: frames 182, mean Main::iteration 27.92 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 15.502 | 1.0 |
| process | 12.394 | 1.0 |
| physics | 0.031 | 1.0 |
| Physics Step | 0.031 | 1.7 |
| AudioServer::update | 0.024 | 1.0 |
| physics_process | 0.011 | 1.7 |
| 2D physics | 0.008 | 1.7 |
| PhysicsServer3D::sync | 0.003 | 1.7 |
| PhysicsServer2D::sync | 0.003 | 1.7 |
| NavigationServer3D::physics_process | 0.002 | 1.7 |
| OS::add_frame_delay | 0.002 | 1.0 |
| NavigationServer2D::physics_process | 0.002 | 1.7 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.7 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| main loop iteration prepare | 0.001 | 1.7 |
| xr_server->_process | 0.001 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 1.7 |
| main loop iteration end | 0.000 | 1.7 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 15.555 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 12.040 |
| engine C++ (main/) | 0.407 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.012 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 6.958 | 6.958 | 17.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.620 | 4.620 | 2.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 3.648 | 3.648 | 2.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 1.987 | 4.699 | 293.5 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4011 | 1.701 | 2.975 | 12.1 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 1.417 | 1.508 | 512.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3604 | 1.155 | 4.961 | 4.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4070 | 1.095 | 1.095 | 2433.3 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4033 | 0.768 | 0.768 | 12.1 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.748 | 0.748 | 23478.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5487 | 0.565 | 0.863 | 4.0 |
| process | main/main.cpp:5061 | 0.342 | 12.394 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.273 | 0.352 | 291.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.239 | 4.972 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4016 | 0.190 | 1.274 | 2421.2 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5514 | 0.189 | 0.272 | 329.8 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.145 | 8.411 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.130 | 0.130 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:543 | 0.090 | 0.090 | 0.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5519 | 0.083 | 0.083 | 329.8 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.070 | 0.070 | 2.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2957 | 0.054 | 0.054 | 293.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4458 | 0.049 | 1.274 | 440.2 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.045 | 0.045 | 2.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4428 | 0.032 | 4.616 | 280.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 10.864 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.309 |
| res://addons/xr_editor/tools/manipulator.gd | 0.149 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.142 |
| res://addons/xr_editor/xr/simulator.gd | 0.109 |
| res://addons/xr_editor/core/feature_settings.gd | 0.076 |
| res://addons/xr_editor/ui/panels.gd | 0.070 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.047 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.039 |
| res://addons/xr_editor/xr/hand.gd | 0.037 |
| res://addons/xr_editor/tools/icons.gd | 0.031 |
| res://addons/xr_editor/xr/rig.gd | 0.031 |
| res://addons/xr_editor/xr/session.gd | 0.026 |
| res://addons/xr_editor/tools/locomotion.gd | 0.017 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.011 |
| res://addons/xr_editor/ui/palette.gd | 0.008 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.007 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |

### 06 open

Thread 1: frames 840, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.338 | 1.0 |
| process | 1.700 | 1.0 |
| AudioServer::update | 0.011 | 1.0 |
| physics | 0.007 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.337 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.477 |
| engine C++ (main/) | 0.239 |
| GDScript: other scripts, with engine calls made from them | 0.010 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.339 | 3.339 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.535 | 0.535 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.298 | 0.298 | 2.0 |
| process | main/main.cpp:5061 | 0.215 | 1.700 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.128 | 0.138 | 41.3 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.120 | 0.331 | 18.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4011 | 0.095 | 0.160 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.084 | 0.084 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4070 | 0.064 | 0.064 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3604 | 0.063 | 0.316 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4033 | 0.047 | 0.047 | 12.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.047 | 3.695 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.043 | 0.043 | 1251.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5487 | 0.031 | 0.052 | 4.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.023 | 0.284 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.019 | 0.087 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.018 | 0.036 | 4.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.018 | 0.018 | 2.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.017 | 0.022 | 15.5 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.017 | 0.830 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.016 | 0.350 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5514 | 0.016 | 0.024 | 24.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3290 | 0.015 | 0.245 | 2.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.014 | 0.015 | 24.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.768 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.214 |
| res://addons/xr_editor/xr/simulator.gd | 0.069 |
| res://addons/xr_editor/tools/manipulator.gd | 0.067 |
| res://addons/xr_editor/core/feature_settings.gd | 0.056 |
| res://addons/xr_editor/ui/panels.gd | 0.045 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.041 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.034 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.027 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.021 |
| res://addons/xr_editor/xr/session.gd | 0.013 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/blueprints/document.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 07 closed

Thread 1: frames 851, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.204 | 1.0 |
| process | 0.835 | 1.0 |
| AudioServer::update | 0.010 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.203 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.623 |
| engine C++ (main/) | 0.235 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.731 | 4.731 | 2.0 |
| process | main/main.cpp:5061 | 0.212 | 0.835 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.208 | 0.208 | 14.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.111 | 0.111 | 2.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.082 | 0.082 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:482 | 0.064 | 0.064 | 3.4 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:483 | 0.048 | 0.048 | 3.4 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.042 | 4.895 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.021 | 0.021 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.017 | 0.017 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.015 | 0.116 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.015 | 0.038 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:543 | 0.014 | 0.014 | 0.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.069 | 2.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.011 | 0.021 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.010 | 0.010 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.010 | 0.010 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.008 | 0.026 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:470 | 0.008 | 0.122 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3290 | 0.008 | 0.008 | 2.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.007 | 0.031 | 2.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.007 | 0.007 | 2.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.007 | 0.109 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.007 | 6.067 | 1.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1076 | 0.007 | 0.007 | 12.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.153 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.092 |
| res://addons/xr_editor/tools/manipulator.gd | 0.071 |
| res://addons/xr_editor/xr/simulator.gd | 0.067 |
| res://addons/xr_editor/core/feature_settings.gd | 0.052 |
| res://addons/xr_editor/xr/hand.gd | 0.024 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.021 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.020 |
| res://addons/xr_editor/xr/session.gd | 0.012 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |

### 08 closed_scene1k

Thread 1: frames 842, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.297 | 1.0 |
| process | 0.741 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.007 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.297 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.529 |
| engine C++ (main/) | 0.237 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.444 | 4.444 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.573 | 0.573 | 14.7 |
| process | main/main.cpp:5061 | 0.213 | 0.741 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.113 | 0.113 | 2.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.087 | 0.087 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.043 | 4.612 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.025 | 0.025 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.018 | 0.018 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.120 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.016 | 0.040 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:543 | 0.014 | 0.014 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.012 | 0.022 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.011 | 0.011 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.074 | 2.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.010 | 0.010 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.028 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3290 | 0.008 | 0.009 | 2.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.008 | 0.033 | 2.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.008 | 0.008 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1076 | 0.007 | 0.007 | 12.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.007 | 6.067 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.007 | 0.013 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1059 | 0.007 | 0.012 | 12.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1071 | 0.007 | 0.007 | 14.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.095 |
| res://addons/xr_editor/tools/manipulator.gd | 0.075 |
| res://addons/xr_editor/xr/simulator.gd | 0.071 |
| res://addons/xr_editor/core/feature_settings.gd | 0.054 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.040 |
| res://addons/xr_editor/xr/hand.gd | 0.025 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.023 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/ui/panels.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.021 |
| res://addons/xr_editor/xr/session.gd | 0.013 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |

### 09 closed_scene5k

Thread 1: frames 856, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.253 | 1.0 |
| process | 0.782 | 1.0 |
| AudioServer::update | 0.013 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.003 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.252 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.554 |
| engine C++ (main/) | 0.255 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.293 | 3.293 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.674 | 1.674 | 14.7 |
| process | main/main.cpp:5061 | 0.228 | 0.782 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.113 | 0.113 | 2.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.088 | 0.088 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.043 | 3.460 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.025 | 0.025 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.126 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.016 | 0.042 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:543 | 0.014 | 0.014 | 0.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.013 | 0.013 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.013 | 0.013 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.012 | 0.024 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.011 | 0.011 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.076 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.029 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3290 | 0.008 | 0.009 | 2.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.008 | 0.034 | 2.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.008 | 0.008 | 2.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.007 | 6.067 | 1.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1076 | 0.007 | 0.007 | 12.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.007 | 0.014 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.007 | 0.010 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:470 | 0.007 | 0.010 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.100 |
| res://addons/xr_editor/tools/manipulator.gd | 0.078 |
| res://addons/xr_editor/xr/simulator.gd | 0.075 |
| res://addons/xr_editor/core/feature_settings.gd | 0.056 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.042 |
| res://addons/xr_editor/xr/hand.gd | 0.026 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.025 |
| res://addons/xr_editor/ui/panels.gd | 0.022 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |

### 10 closed_scene20k

Thread 1: frames 577, mean Main::iteration 8.80 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 7.714 | 1.0 |
| process | 1.044 | 1.0 |
| AudioServer::update | 0.022 | 1.0 |
| physics | 0.014 | 1.0 |
| Physics Step | 0.014 | 0.5 |
| physics_process | 0.005 | 0.5 |
| 2D physics | 0.004 | 0.5 |
| PhysicsServer3D::sync | 0.002 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 7.715 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.730 |
| engine C++ (main/) | 0.358 |
| engine C++ (platform/) | 0.011 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 5.998 | 5.998 | 14.7 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.297 | 1.297 | 2.0 |
| process | main/main.cpp:5061 | 0.313 | 1.044 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.155 | 0.155 | 2.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.126 | 0.126 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.084 | 1.549 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.037 | 0.037 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.033 | 0.033 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.022 | 0.022 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.021 | 0.158 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.020 | 0.020 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:543 | 0.020 | 0.020 | 0.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.019 | 0.051 | 2.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.018 | 0.036 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.015 | 0.015 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.013 | 0.108 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.011 | 0.037 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.011 | 8.810 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.010 | 0.014 | 1.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1076 | 0.010 | 0.010 | 12.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3290 | 0.009 | 0.011 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:470 | 0.009 | 0.014 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.009 | 0.041 | 2.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.009 | 0.009 | 2.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.009 | 0.037 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.124 |
| res://addons/xr_editor/tools/manipulator.gd | 0.112 |
| res://addons/xr_editor/xr/simulator.gd | 0.101 |
| res://addons/xr_editor/core/feature_settings.gd | 0.065 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.060 |
| res://addons/xr_editor/xr/hand.gd | 0.032 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.031 |
| res://addons/xr_editor/ui/panels.gd | 0.028 |
| res://addons/xr_editor/tools/icons.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.027 |
| res://addons/xr_editor/xr/session.gd | 0.023 |
| res://addons/xr_editor/tools/locomotion.gd | 0.016 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.015 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/tools/clipboard.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/xr/standalone.gd | 0.003 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |

### 11 closed

Thread 1: frames 855, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.271 | 1.0 |
| process | 0.765 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.008 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.270 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.546 |
| engine C++ (main/) | 0.245 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.762 | 4.762 | 2.0 |
| process | main/main.cpp:5061 | 0.219 | 0.765 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.218 | 0.218 | 14.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.117 | 0.117 | 2.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.097 | 0.097 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.044 | 4.934 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.023 | 0.023 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.017 | 0.124 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.016 | 0.041 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:543 | 0.014 | 0.014 | 0.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.012 | 0.023 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.011 | 0.011 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.074 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.029 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.008 | 0.033 | 2.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.008 | 0.008 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3290 | 0.008 | 0.009 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1076 | 0.008 | 0.008 | 12.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.007 | 6.067 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.007 | 0.014 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:470 | 0.007 | 0.010 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1071 | 0.007 | 0.007 | 14.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1059 | 0.007 | 0.013 | 12.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.098 |
| res://addons/xr_editor/tools/manipulator.gd | 0.076 |
| res://addons/xr_editor/xr/simulator.gd | 0.074 |
| res://addons/xr_editor/core/feature_settings.gd | 0.056 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.042 |
| res://addons/xr_editor/xr/hand.gd | 0.026 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.025 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/ui/panels.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.021 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.002 |

### 12 open_scene5k

Thread 1: frames 774, mean Main::iteration 6.57 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.664 | 1.0 |
| process | 1.880 | 1.0 |
| AudioServer::update | 0.013 | 1.0 |
| physics | 0.009 | 1.0 |
| Physics Step | 0.008 | 0.4 |
| physics_process | 0.003 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.666 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.622 |
| engine C++ (main/) | 0.275 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.145 | 2.145 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.987 | 1.987 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.329 | 0.329 | 2.0 |
| process | main/main.cpp:5061 | 0.247 | 1.880 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.126 | 0.135 | 41.2 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.121 | 0.328 | 18.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4011 | 0.117 | 0.241 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.101 | 0.101 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4070 | 0.070 | 0.070 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3604 | 0.065 | 0.400 | 4.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.065 | 2.550 | 1.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4033 | 0.048 | 0.048 | 12.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.042 | 0.042 | 1251.2 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.041 | 0.041 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5487 | 0.032 | 0.053 | 4.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.028 | 0.028 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.024 | 0.326 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.022 | 0.022 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.020 | 0.090 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.019 | 0.038 | 4.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.017 | 0.877 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.017 | 0.348 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.017 | 0.022 | 15.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5514 | 0.016 | 0.025 | 24.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.017 | 24.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.855 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.224 |
| res://addons/xr_editor/tools/manipulator.gd | 0.081 |
| res://addons/xr_editor/xr/simulator.gd | 0.078 |
| res://addons/xr_editor/core/feature_settings.gd | 0.059 |
| res://addons/xr_editor/ui/panels.gd | 0.048 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.043 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.041 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.030 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 13 open

Thread 1: frames 852, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.225 | 1.0 |
| process | 1.815 | 1.0 |
| AudioServer::update | 0.011 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
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
| engine C++ (servers/) | 4.229 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.586 |
| engine C++ (main/) | 0.243 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.202 | 3.202 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.543 | 0.543 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.306 | 0.306 | 2.0 |
| process | main/main.cpp:5061 | 0.219 | 1.815 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.127 | 0.136 | 41.2 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.121 | 0.330 | 18.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4011 | 0.119 | 0.244 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.096 | 0.096 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4070 | 0.072 | 0.072 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3604 | 0.064 | 0.402 | 4.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.049 | 3.569 | 1.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4033 | 0.048 | 0.048 | 12.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.043 | 0.043 | 1250.9 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.041 | 0.041 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5487 | 0.032 | 0.053 | 4.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.024 | 0.328 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.022 | 0.022 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.021 | 0.021 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.020 | 0.088 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.019 | 0.037 | 4.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.017 | 0.022 | 15.5 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.017 | 0.874 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.016 | 0.349 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5514 | 0.016 | 0.024 | 24.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.017 | 24.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.855 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.217 |
| res://addons/xr_editor/xr/simulator.gd | 0.072 |
| res://addons/xr_editor/tools/manipulator.gd | 0.071 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/ui/panels.gd | 0.046 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.041 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.041 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.029 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.021 |
| res://addons/xr_editor/xr/session.gd | 0.013 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 14 closed

Thread 1: frames 837, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.152 | 1.0 |
| process | 0.889 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.008 | 0.4 |
| physics_process | 0.003 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.151 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.670 |
| engine C++ (main/) | 0.246 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.646 | 4.646 | 2.0 |
| process | main/main.cpp:5061 | 0.220 | 0.889 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.218 | 0.218 | 14.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.116 | 0.116 | 2.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.094 | 0.094 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:482 | 0.070 | 0.070 | 3.4 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:483 | 0.047 | 0.047 | 3.4 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.044 | 4.818 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.023 | 0.023 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.019 | 0.019 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.017 | 0.124 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.016 | 0.041 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:543 | 0.015 | 0.015 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.012 | 0.023 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.012 | 0.076 | 2.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.011 | 0.011 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.029 | 1.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.008 | 0.008 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:470 | 0.008 | 0.127 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3290 | 0.008 | 0.009 | 2.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.008 | 0.034 | 2.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 6.068 | 1.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1076 | 0.008 | 0.008 | 12.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.007 | 0.118 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.160 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.099 |
| res://addons/xr_editor/tools/manipulator.gd | 0.078 |
| res://addons/xr_editor/xr/simulator.gd | 0.074 |
| res://addons/xr_editor/core/feature_settings.gd | 0.057 |
| res://addons/xr_editor/xr/hand.gd | 0.026 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.025 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.023 |
| res://addons/xr_editor/ui/panels.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
