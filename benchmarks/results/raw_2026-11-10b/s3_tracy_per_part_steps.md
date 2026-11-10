
### 01 closed

Thread 1: frames 835, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.195 | 1.0 |
| process | 0.833 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.194 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.586 |
| engine C++ (main/) | 0.274 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.719 | 4.719 | 1.0 |
| process | main/main.cpp:5061 | 0.247 | 0.833 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.216 | 0.216 | 14.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.119 | 0.119 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.098 | 0.098 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.024 | 0.024 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:821 | 0.018 | 0.135 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.018 | 0.047 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.015 | 0.015 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.013 | 0.025 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.013 | 0.013 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.012 | 0.012 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.012 | 0.078 | 2.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.011 | 0.040 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.010 | 0.032 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3292 | 0.010 | 0.011 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1112 | 0.008 | 0.008 | 12.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 6.060 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.008 | 0.011 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.007 | 0.029 | 1.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.007 | 0.014 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.007 | 0.109 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.007 | 0.010 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.109 |
| res://addons/xr_editor/xr/simulator.gd | 0.081 |
| res://addons/xr_editor/tools/manipulator.gd | 0.077 |
| res://addons/xr_editor/core/feature_settings.gd | 0.061 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.048 |
| res://addons/xr_editor/xr/hand.gd | 0.029 |
| res://addons/xr_editor/ui/panels.gd | 0.027 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.024 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/tools/icons.gd | 0.024 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |

### 02 open

Thread 1: frames 839, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.307 | 1.0 |
| process | 1.722 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.305 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.454 |
| engine C++ (main/) | 0.283 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.234 | 3.234 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.591 | 0.591 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.336 | 0.336 | 1.0 |
| process | main/main.cpp:5061 | 0.256 | 1.722 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4012 | 0.124 | 0.254 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.100 | 0.100 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.073 | 0.073 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3605 | 0.067 | 0.421 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4034 | 0.051 | 0.051 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4053 | 0.043 | 0.043 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5539 | 0.035 | 0.057 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4433 | 0.029 | 0.029 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.026 | 0.347 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4446 | 0.023 | 0.048 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4169 | 0.021 | 0.100 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.020 | 0.039 | 4.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:821 | 0.019 | 0.668 | 1.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.017 | 0.018 | 24.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5566 | 0.017 | 0.026 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4509 | 0.017 | 0.022 | 15.5 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4419 | 0.016 | 0.096 | 0.5 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3292 | 0.016 | 0.316 | 2.0 |
| _link_wire_hit | res://addons/xr_editor/logic_graph/blueprints.gd:6975 | 0.015 | 0.080 | 4.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.635 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.245 |
| res://addons/xr_editor/xr/simulator.gd | 0.082 |
| res://addons/xr_editor/tools/manipulator.gd | 0.072 |
| res://addons/xr_editor/core/feature_settings.gd | 0.064 |
| res://addons/xr_editor/ui/panels.gd | 0.052 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.048 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.046 |
| res://addons/xr_editor/xr/hand.gd | 0.031 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.030 |
| res://addons/xr_editor/xr/rig.gd | 0.025 |
| res://addons/xr_editor/tools/icons.gd | 0.024 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 03 open_graph100

Thread 1: frames 840, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.283 | 1.0 |
| process | 2.756 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.007 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.281 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.474 |
| engine C++ (main/) | 0.301 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.397 | 1.397 | 16.9 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 0.883 | 0.883 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.837 | 0.837 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4012 | 0.360 | 0.759 | 12.0 |
| process | main/main.cpp:5061 | 0.273 | 2.756 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.267 | 0.267 | 501.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3605 | 0.203 | 1.155 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4034 | 0.145 | 0.145 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.117 | 0.117 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5539 | 0.099 | 0.161 | 4.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4053 | 0.080 | 0.080 | 156.4 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4446 | 0.075 | 0.160 | 61.6 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4433 | 0.066 | 0.066 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4509 | 0.061 | 0.079 | 59.1 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4419 | 0.043 | 0.277 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5566 | 0.042 | 0.060 | 72.2 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4017 | 0.042 | 0.299 | 489.2 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.029 | 0.029 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.026 | 0.742 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.022 | 0.022 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4169 | 0.020 | 0.099 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.020 | 0.038 | 4.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:821 | 0.019 | 1.244 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5571 | 0.018 | 0.018 | 72.2 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3292 | 0.016 | 0.759 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 1.654 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.247 |
| res://addons/xr_editor/xr/simulator.gd | 0.083 |
| res://addons/xr_editor/tools/manipulator.gd | 0.082 |
| res://addons/xr_editor/core/feature_settings.gd | 0.062 |
| res://addons/xr_editor/ui/panels.gd | 0.051 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.050 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.039 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.030 |
| res://addons/xr_editor/xr/hand.gd | 0.030 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.016 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 04 open_graph250

Thread 1: frames 500, mean Main::iteration 10.14 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.461 | 1.0 |
| process | 4.642 | 1.0 |
| AudioServer::update | 0.017 | 1.0 |
| physics | 0.012 | 1.0 |
| Physics Step | 0.011 | 0.6 |
| physics_process | 0.005 | 0.6 |
| PhysicsServer3D::sync | 0.002 | 0.6 |
| PhysicsServer2D::sync | 0.001 | 0.6 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.6 |
| NavigationServer2D::physics_process | 0.001 | 0.6 |
| 2D physics | 0.001 | 0.6 |
| 3D physics | 0.000 | 0.6 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.6 |
| setup | 0.000 | 0.6 |
| main loop iteration end | 0.000 | 0.6 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.463 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 4.327 |
| engine C++ (main/) | 0.339 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.010 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 3.417 | 3.417 | 16.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 1.827 | 1.827 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4012 | 0.779 | 1.416 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.552 | 0.552 | 1220.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3605 | 0.502 | 2.326 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4034 | 0.355 | 0.355 | 12.0 |
| process | main/main.cpp:5061 | 0.303 | 4.642 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5539 | 0.245 | 0.388 | 4.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.163 | 0.163 | 1.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4446 | 0.163 | 0.356 | 148.5 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4433 | 0.139 | 0.139 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4509 | 0.139 | 0.178 | 146.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4017 | 0.094 | 0.637 | 1208.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4419 | 0.093 | 0.604 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5566 | 0.091 | 0.132 | 168.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.050 | 0.050 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5571 | 0.041 | 0.041 | 168.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.028 | 0.028 | 0.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.028 | 0.028 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.028 | 1.351 | 2.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2962 | 0.027 | 0.027 | 148.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.022 | 0.041 | 4.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:821 | 0.020 | 2.200 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4169 | 0.020 | 0.106 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3292 | 0.017 | 1.567 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 3.383 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.275 |
| res://addons/xr_editor/tools/manipulator.gd | 0.113 |
| res://addons/xr_editor/xr/simulator.gd | 0.093 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.070 |
| res://addons/xr_editor/core/feature_settings.gd | 0.064 |
| res://addons/xr_editor/ui/panels.gd | 0.057 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.040 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.033 |
| res://addons/xr_editor/xr/hand.gd | 0.032 |
| res://addons/xr_editor/tools/icons.gd | 0.026 |
| res://addons/xr_editor/xr/rig.gd | 0.025 |
| res://addons/xr_editor/xr/session.gd | 0.020 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 05 open_graph500

Thread 1: frames 258, mean Main::iteration 19.68 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 11.150 | 1.0 |
| process | 8.551 | 1.0 |
| AudioServer::update | 0.023 | 1.0 |
| physics | 0.022 | 1.0 |
| Physics Step | 0.022 | 1.2 |
| physics_process | 0.011 | 1.2 |
| PhysicsServer3D::sync | 0.003 | 1.2 |
| PhysicsServer2D::sync | 0.002 | 1.2 |
| NavigationServer3D::physics_process | 0.001 | 1.2 |
| NavigationServer2D::physics_process | 0.001 | 1.2 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| 2D physics | 0.001 | 1.2 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.2 |
| main loop iteration prepare | 0.001 | 1.2 |
| xr_server->_process | 0.001 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 1.2 |
| main loop iteration end | 0.000 | 1.2 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 11.148 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 8.228 |
| engine C++ (main/) | 0.380 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.011 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 7.163 | 7.163 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 3.710 | 3.710 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4012 | 1.722 | 2.963 | 12.1 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3605 | 1.201 | 5.018 | 4.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 1.064 | 1.064 | 2436.4 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4034 | 0.795 | 0.795 | 12.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5539 | 0.562 | 0.863 | 4.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4446 | 0.334 | 0.719 | 295.8 |
| process | main/main.cpp:5061 | 0.325 | 8.551 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4509 | 0.276 | 0.356 | 293.3 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4433 | 0.212 | 0.212 | 0.5 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.206 | 0.206 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4419 | 0.191 | 1.152 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4017 | 0.187 | 1.241 | 2424.3 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5566 | 0.184 | 0.276 | 329.9 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5571 | 0.091 | 0.091 | 329.9 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.067 | 0.067 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.062 | 0.062 | 0.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2962 | 0.054 | 0.054 | 295.3 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.032 | 0.032 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.031 | 2.702 | 2.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4453 | 0.030 | 0.385 | 293.3 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4430 | 0.029 | 0.720 | 282.2 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4511 | 0.027 | 0.079 | 293.3 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.025 | 0.047 | 4.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 7.105 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.314 |
| res://addons/xr_editor/tools/manipulator.gd | 0.133 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.114 |
| res://addons/xr_editor/xr/simulator.gd | 0.105 |
| res://addons/xr_editor/core/feature_settings.gd | 0.072 |
| res://addons/xr_editor/ui/panels.gd | 0.068 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.047 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.038 |
| res://addons/xr_editor/xr/hand.gd | 0.037 |
| res://addons/xr_editor/tools/icons.gd | 0.030 |
| res://addons/xr_editor/xr/rig.gd | 0.030 |
| res://addons/xr_editor/xr/session.gd | 0.025 |
| res://addons/xr_editor/tools/locomotion.gd | 0.016 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.010 |
| res://addons/xr_editor/ui/palette.gd | 0.008 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.008 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.007 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.007 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.007 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.005 |

### 06 open

Thread 1: frames 839, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.382 | 1.0 |
| process | 1.652 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.380 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.382 |
| engine C++ (main/) | 0.286 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.284 | 3.284 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.619 | 0.619 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.332 | 0.332 | 1.0 |
| process | main/main.cpp:5061 | 0.259 | 1.652 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4012 | 0.106 | 0.183 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.100 | 0.100 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.075 | 0.075 | 140.3 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3605 | 0.071 | 0.353 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4034 | 0.050 | 0.050 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5539 | 0.035 | 0.058 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4433 | 0.032 | 0.032 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.026 | 0.307 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4446 | 0.024 | 0.048 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4169 | 0.021 | 0.100 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.020 | 0.039 | 4.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.019 | 0.019 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:821 | 0.019 | 0.631 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5566 | 0.017 | 0.026 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4509 | 0.017 | 0.023 | 15.5 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3292 | 0.017 | 0.285 | 2.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.017 | 24.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4419 | 0.016 | 0.099 | 0.5 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.015 | 0.015 | 0.0 |
| _link_wire_hit | res://addons/xr_editor/logic_graph/blueprints.gd:6975 | 0.015 | 0.081 | 4.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.570 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.245 |
| res://addons/xr_editor/xr/simulator.gd | 0.082 |
| res://addons/xr_editor/tools/manipulator.gd | 0.071 |
| res://addons/xr_editor/core/feature_settings.gd | 0.063 |
| res://addons/xr_editor/ui/panels.gd | 0.051 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.051 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.039 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.030 |
| res://addons/xr_editor/xr/hand.gd | 0.030 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/tools/icons.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 07 closed

Thread 1: frames 839, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.206 | 1.0 |
| process | 0.823 | 1.0 |
| AudioServer::update | 0.013 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| RenderingServer::sync | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.205 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.595 |
| engine C++ (main/) | 0.253 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.731 | 4.731 | 1.0 |
| process | main/main.cpp:5061 | 0.228 | 0.823 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.218 | 0.218 | 14.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.121 | 0.121 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.095 | 0.095 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.024 | 0.024 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:821 | 0.020 | 0.146 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.018 | 0.048 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.018 | 0.018 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.015 | 0.015 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.013 | 0.013 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.012 | 0.023 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.012 | 0.012 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.011 | 0.011 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.074 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.010 | 0.013 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3292 | 0.010 | 0.011 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.030 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.009 | 0.038 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4169 | 0.008 | 0.016 | 1.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1112 | 0.008 | 0.008 | 12.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 6.060 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.007 | 0.010 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1095 | 0.007 | 0.014 | 12.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.007 | 0.014 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.116 |
| res://addons/xr_editor/tools/manipulator.gd | 0.077 |
| res://addons/xr_editor/xr/simulator.gd | 0.076 |
| res://addons/xr_editor/core/feature_settings.gd | 0.061 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.050 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.027 |
| res://addons/xr_editor/ui/panels.gd | 0.025 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/tools/icons.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
