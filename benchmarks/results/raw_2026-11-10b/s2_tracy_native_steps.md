
### 01 closed

Thread 1: frames 843, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.391 | 1.0 |
| process | 0.640 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.005 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.000 | 0.4 |
| process 3D navigation | 0.000 | 1.0 |
| process 2D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.390 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.464 |
| engine C++ (main/) | 0.199 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.980 | 4.980 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.199 | 0.199 | 14.8 |
| process | main/main.cpp:5061 | 0.177 | 0.640 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.096 | 0.096 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.082 | 0.082 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.020 | 0.020 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.015 | 0.038 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.014 | 0.014 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:820 | 0.014 | 0.102 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.065 | 2.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.010 | 0.019 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.010 | 0.010 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.009 | 0.009 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.009 | 0.032 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.028 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3291 | 0.008 | 0.008 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1101 | 0.007 | 0.007 | 12.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1096 | 0.007 | 0.007 | 14.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.007 | 6.058 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1084 | 0.007 | 0.013 | 12.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.006 | 0.093 | 1.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.006 | 0.011 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.006 | 0.024 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.081 |
| res://addons/xr_editor/xr/simulator.gd | 0.064 |
| res://addons/xr_editor/tools/manipulator.gd | 0.062 |
| res://addons/xr_editor/core/feature_settings.gd | 0.054 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.037 |
| res://addons/xr_editor/xr/hand.gd | 0.024 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/ui/panels.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.001 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.001 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.001 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.001 |

### 02 open

Thread 1: frames 842, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.581 | 1.0 |
| process | 1.454 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.005 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.000 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.581 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.253 |
| engine C++ (main/) | 0.213 |
| GDScript: other scripts, with engine calls made from them | 0.010 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.700 | 3.700 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.478 | 0.478 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.277 | 0.277 | 1.0 |
| process | main/main.cpp:5061 | 0.190 | 1.454 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4023 | 0.118 | 0.243 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.090 | 0.090 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4082 | 0.071 | 0.071 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3616 | 0.062 | 0.398 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4045 | 0.048 | 0.048 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4064 | 0.041 | 0.041 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5550 | 0.031 | 0.051 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4444 | 0.025 | 0.025 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.023 | 0.322 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4457 | 0.022 | 0.044 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4164 | 0.018 | 0.081 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.018 | 0.036 | 4.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:820 | 0.016 | 0.589 | 1.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.017 | 24.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5577 | 0.016 | 0.023 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4520 | 0.016 | 0.021 | 15.5 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.015 | 0.015 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3291 | 0.015 | 0.287 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.015 | 0.015 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4430 | 0.013 | 0.085 | 0.5 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.580 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.204 |
| res://addons/xr_editor/xr/simulator.gd | 0.065 |
| res://addons/xr_editor/tools/manipulator.gd | 0.056 |
| res://addons/xr_editor/core/feature_settings.gd | 0.055 |
| res://addons/xr_editor/ui/panels.gd | 0.043 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.039 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.038 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.026 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/blueprints/document.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.002 |

### 03 open_graph100

Thread 1: frames 841, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.560 | 1.0 |
| process | 2.485 | 1.0 |
| AudioServer::update | 0.013 | 1.0 |
| physics | 0.005 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.000 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.558 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.277 |
| engine C++ (main/) | 0.224 |
| GDScript: other scripts, with engine calls made from them | 0.010 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.638 | 1.638 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.083 | 1.083 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.685 | 0.685 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4023 | 0.350 | 0.746 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4082 | 0.265 | 0.265 | 500.4 |
| process | main/main.cpp:5061 | 0.200 | 2.485 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3616 | 0.186 | 1.124 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4045 | 0.145 | 0.145 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.112 | 0.112 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5550 | 0.094 | 0.154 | 4.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4064 | 0.078 | 0.078 | 156.1 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4457 | 0.069 | 0.146 | 61.6 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4444 | 0.061 | 0.061 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4520 | 0.055 | 0.071 | 59.1 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4028 | 0.042 | 0.297 | 488.4 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5577 | 0.041 | 0.058 | 72.1 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4430 | 0.035 | 0.249 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.024 | 0.720 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.023 | 0.023 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.019 | 0.037 | 4.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4164 | 0.019 | 0.083 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5582 | 0.017 | 0.017 | 72.1 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.016 | 0.016 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:820 | 0.016 | 1.158 | 1.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.015 | 0.016 | 24.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 1.575 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.212 |
| res://addons/xr_editor/tools/manipulator.gd | 0.067 |
| res://addons/xr_editor/xr/simulator.gd | 0.067 |
| res://addons/xr_editor/core/feature_settings.gd | 0.056 |
| res://addons/xr_editor/ui/panels.gd | 0.045 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.042 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.036 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.027 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.020 |
| res://addons/xr_editor/xr/session.gd | 0.012 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/blueprints/document.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.003 |

### 04 open_graph250

Thread 1: frames 564, mean Main::iteration 9.01 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.781 | 1.0 |
| process | 4.219 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.009 | 1.0 |
| Physics Step | 0.009 | 0.5 |
| physics_process | 0.004 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| 2D physics | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.780 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 3.955 |
| engine C++ (main/) | 0.287 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 2.880 | 2.880 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 1.713 | 1.713 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4023 | 0.719 | 1.346 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4082 | 0.542 | 0.542 | 1223.8 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3616 | 0.454 | 2.178 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4045 | 0.330 | 0.330 | 12.0 |
| process | main/main.cpp:5061 | 0.259 | 4.219 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5550 | 0.215 | 0.344 | 4.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4457 | 0.156 | 0.339 | 149.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.141 | 0.141 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4520 | 0.131 | 0.168 | 146.5 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4444 | 0.129 | 0.129 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4028 | 0.095 | 0.627 | 1211.7 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4430 | 0.087 | 0.571 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5577 | 0.084 | 0.118 | 168.5 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.041 | 0.041 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5582 | 0.034 | 0.034 | 168.5 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2969 | 0.026 | 0.026 | 148.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.025 | 1.320 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.024 | 0.024 | 0.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.021 | 0.021 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.020 | 0.038 | 4.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4164 | 0.019 | 0.094 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:820 | 0.018 | 2.108 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3291 | 0.014 | 1.377 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 3.150 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.235 |
| res://addons/xr_editor/tools/manipulator.gd | 0.093 |
| res://addons/xr_editor/xr/simulator.gd | 0.076 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.060 |
| res://addons/xr_editor/core/feature_settings.gd | 0.056 |
| res://addons/xr_editor/ui/panels.gd | 0.049 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.036 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.030 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 05 open_graph500

Thread 1: frames 281, mean Main::iteration 18.14 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 10.224 | 1.0 |
| process | 7.897 | 1.0 |
| AudioServer::update | 0.020 | 1.0 |
| physics | 0.019 | 1.0 |
| Physics Step | 0.019 | 1.1 |
| physics_process | 0.009 | 1.1 |
| PhysicsServer3D::sync | 0.003 | 1.1 |
| PhysicsServer2D::sync | 0.002 | 1.1 |
| NavigationServer3D::physics_process | 0.001 | 1.1 |
| NavigationServer2D::physics_process | 0.001 | 1.1 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| 2D physics | 0.001 | 1.1 |
| ScriptServer::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.1 |
| main loop iteration prepare | 0.001 | 1.1 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 1.1 |
| main loop iteration end | 0.000 | 1.1 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 10.223 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 7.587 |
| engine C++ (main/) | 0.344 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.010 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 6.463 | 6.463 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 3.506 | 3.506 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4023 | 1.597 | 2.822 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4082 | 1.056 | 1.056 | 2428.6 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3616 | 1.045 | 4.644 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4045 | 0.721 | 0.721 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5550 | 0.511 | 0.784 | 4.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4457 | 0.316 | 0.685 | 294.5 |
| process | main/main.cpp:5061 | 0.297 | 7.897 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4520 | 0.266 | 0.341 | 292.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4444 | 0.209 | 0.209 | 0.5 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.195 | 0.195 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4028 | 0.181 | 1.225 | 2416.6 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5577 | 0.174 | 0.247 | 329.2 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4430 | 0.173 | 1.097 | 0.5 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5582 | 0.073 | 0.073 | 329.2 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.060 | 0.060 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.057 | 0.057 | 0.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2969 | 0.050 | 0.050 | 294.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.029 | 0.369 | 292.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.028 | 2.568 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4441 | 0.028 | 0.687 | 281.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.028 | 0.028 | 2.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4522 | 0.025 | 0.075 | 292.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5557 | 0.025 | 0.209 | 240.9 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 6.591 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.277 |
| res://addons/xr_editor/tools/manipulator.gd | 0.121 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.103 |
| res://addons/xr_editor/xr/simulator.gd | 0.093 |
| res://addons/xr_editor/core/feature_settings.gd | 0.063 |
| res://addons/xr_editor/ui/panels.gd | 0.060 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.041 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.035 |
| res://addons/xr_editor/xr/hand.gd | 0.033 |
| res://addons/xr_editor/tools/icons.gd | 0.027 |
| res://addons/xr_editor/xr/rig.gd | 0.026 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/tools/locomotion.gd | 0.015 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 06 open

Thread 1: frames 842, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.679 | 1.0 |
| process | 1.357 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.005 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.000 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.679 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.160 |
| engine C++ (main/) | 0.208 |
| GDScript: other scripts, with engine calls made from them | 0.010 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.814 | 3.814 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.473 | 0.473 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.271 | 0.271 | 1.0 |
| process | main/main.cpp:5061 | 0.187 | 1.357 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4023 | 0.095 | 0.167 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.085 | 0.085 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4082 | 0.070 | 0.070 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3616 | 0.062 | 0.320 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4045 | 0.046 | 0.046 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5550 | 0.030 | 0.049 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4444 | 0.028 | 0.028 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.023 | 0.283 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4457 | 0.022 | 0.044 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4164 | 0.019 | 0.081 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.018 | 0.036 | 4.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:820 | 0.016 | 0.552 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5577 | 0.016 | 0.023 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4520 | 0.016 | 0.020 | 15.5 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.015 | 0.015 | 2.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.015 | 0.015 | 24.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3291 | 0.014 | 0.242 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.014 | 0.014 | 2.0 |
| _link_wire_hit | res://addons/xr_editor/logic_graph/blueprints.gd:6970 | 0.013 | 0.069 | 4.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4430 | 0.013 | 0.087 | 0.5 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.502 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.203 |
| res://addons/xr_editor/xr/simulator.gd | 0.063 |
| res://addons/xr_editor/tools/manipulator.gd | 0.055 |
| res://addons/xr_editor/core/feature_settings.gd | 0.054 |
| res://addons/xr_editor/ui/panels.gd | 0.043 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.040 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.034 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.025 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/blueprints/document.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.002 |

### 07 closed

Thread 1: frames 842, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.379 | 1.0 |
| process | 0.657 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.005 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.000 | 0.4 |
| process 3D navigation | 0.000 | 1.0 |
| process 2D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.378 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.486 |
| engine C++ (main/) | 0.193 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.970 | 4.970 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.193 | 0.193 | 14.8 |
| process | main/main.cpp:5061 | 0.171 | 0.657 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.100 | 0.100 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.081 | 0.081 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.020 | 0.020 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2793 | 0.015 | 0.037 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:820 | 0.015 | 0.109 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.015 | 0.015 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.065 | 2.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.010 | 0.010 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.010 | 0.019 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.009 | 0.009 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.028 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.008 | 0.031 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3291 | 0.007 | 0.008 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.007 | 0.010 | 1.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1101 | 0.007 | 0.007 | 12.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1096 | 0.007 | 0.007 | 14.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.007 | 6.063 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1084 | 0.007 | 0.013 | 12.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4164 | 0.007 | 0.012 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.006 | 0.101 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.087 |
| res://addons/xr_editor/tools/manipulator.gd | 0.064 |
| res://addons/xr_editor/xr/simulator.gd | 0.064 |
| res://addons/xr_editor/core/feature_settings.gd | 0.054 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.040 |
| res://addons/xr_editor/xr/hand.gd | 0.024 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/ui/panels.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.001 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.001 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.001 |
