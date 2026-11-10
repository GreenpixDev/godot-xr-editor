
### 01 closed

Thread 1: frames 841, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.204 | 1.0 |
| process | 0.824 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.203 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.574 |
| engine C++ (main/) | 0.277 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.735 | 4.735 | 1.0 |
| process | main/main.cpp:5061 | 0.250 | 0.824 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.214 | 0.214 | 14.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.118 | 0.118 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.096 | 0.096 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.024 | 0.024 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.019 | 0.048 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:821 | 0.018 | 0.138 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.013 | 0.025 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.012 | 0.012 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.012 | 0.012 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.077 | 2.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.011 | 0.039 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.031 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3292 | 0.008 | 0.009 | 2.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 6.060 | 1.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1112 | 0.008 | 0.008 | 12.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.007 | 0.010 | 1.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.007 | 0.014 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.007 | 0.107 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1095 | 0.007 | 0.014 | 12.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.007 | 0.028 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.109 |
| res://addons/xr_editor/xr/simulator.gd | 0.079 |
| res://addons/xr_editor/tools/manipulator.gd | 0.075 |
| res://addons/xr_editor/core/feature_settings.gd | 0.060 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.045 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/ui/panels.gd | 0.027 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.024 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/tools/icons.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |

### 02 open

Thread 1: frames 840, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.310 | 1.0 |
| process | 1.719 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.309 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.452 |
| engine C++ (main/) | 0.282 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.287 | 3.287 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.557 | 0.557 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.321 | 0.321 | 1.0 |
| process | main/main.cpp:5061 | 0.255 | 1.719 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4012 | 0.125 | 0.258 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.101 | 0.101 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.075 | 0.075 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3605 | 0.069 | 0.426 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4034 | 0.050 | 0.050 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4053 | 0.044 | 0.044 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5539 | 0.035 | 0.058 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4433 | 0.029 | 0.029 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.027 | 0.353 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4446 | 0.024 | 0.048 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4169 | 0.021 | 0.100 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.020 | 0.039 | 4.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:821 | 0.019 | 0.674 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5566 | 0.018 | 0.026 | 24.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.017 | 0.018 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4509 | 0.017 | 0.022 | 15.5 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3292 | 0.016 | 0.316 | 2.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4419 | 0.015 | 0.095 | 0.5 |
| _link_wire_hit | res://addons/xr_editor/logic_graph/blueprints.gd:6975 | 0.015 | 0.081 | 4.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.642 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.244 |
| res://addons/xr_editor/xr/simulator.gd | 0.081 |
| res://addons/xr_editor/tools/manipulator.gd | 0.071 |
| res://addons/xr_editor/core/feature_settings.gd | 0.064 |
| res://addons/xr_editor/ui/panels.gd | 0.051 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.047 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.044 |
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
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 03 open_graph100

Thread 1: frames 837, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.218 | 1.0 |
| process | 2.814 | 1.0 |
| AudioServer::update | 0.015 | 1.0 |
| physics | 0.006 | 1.0 |
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
| xr_server->_process | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.216 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.530 |
| engine C++ (main/) | 0.301 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.245 | 1.245 | 16.8 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.021 | 1.021 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.777 | 0.777 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4012 | 0.374 | 0.778 | 12.0 |
| process | main/main.cpp:5061 | 0.272 | 2.814 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.270 | 0.270 | 500.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3605 | 0.216 | 1.194 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4034 | 0.151 | 0.151 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.127 | 0.127 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5539 | 0.104 | 0.167 | 4.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4053 | 0.080 | 0.080 | 156.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4446 | 0.074 | 0.158 | 61.6 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4433 | 0.066 | 0.066 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4509 | 0.060 | 0.077 | 59.1 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4419 | 0.043 | 0.275 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5566 | 0.043 | 0.062 | 72.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4017 | 0.043 | 0.303 | 488.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.028 | 0.028 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.027 | 0.753 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.022 | 0.022 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.020 | 0.039 | 4.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4169 | 0.020 | 0.098 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:821 | 0.019 | 1.254 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5571 | 0.019 | 0.019 | 72.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3292 | 0.016 | 0.799 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 1.698 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.251 |
| res://addons/xr_editor/xr/simulator.gd | 0.084 |
| res://addons/xr_editor/tools/manipulator.gd | 0.082 |
| res://addons/xr_editor/core/feature_settings.gd | 0.062 |
| res://addons/xr_editor/ui/panels.gd | 0.053 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.049 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.039 |
| res://addons/xr_editor/xr/hand.gd | 0.031 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.031 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/tools/icons.gd | 0.024 |
| res://addons/xr_editor/xr/session.gd | 0.016 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 04 open_graph250

Thread 1: frames 531, mean Main::iteration 9.75 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| process | 4.917 | 1.0 |
| RenderingServer::draw | 4.816 | 1.0 |
| AudioServer::update | 0.018 | 1.0 |
| physics | 0.011 | 1.0 |
| Physics Step | 0.011 | 0.6 |
| physics_process | 0.005 | 0.6 |
| PhysicsServer3D::sync | 0.002 | 0.6 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.6 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.6 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 0.6 |
| 2D physics | 0.001 | 0.6 |
| 3D physics | 0.000 | 0.6 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.6 |
| setup | 0.000 | 0.6 |
| main loop iteration end | 0.000 | 0.6 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.819 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 4.594 |
| engine C++ (main/) | 0.351 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.010 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 2.956 | 2.956 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 1.634 | 1.634 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4012 | 0.840 | 1.496 | 12.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3605 | 0.575 | 2.515 | 4.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.567 | 0.567 | 1222.9 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4034 | 0.388 | 0.388 | 12.0 |
| process | main/main.cpp:5061 | 0.313 | 4.917 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5539 | 0.263 | 0.411 | 4.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.170 | 0.170 | 1.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4446 | 0.169 | 0.362 | 148.8 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4509 | 0.139 | 0.178 | 146.3 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4433 | 0.138 | 0.138 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4017 | 0.100 | 0.656 | 1210.8 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4419 | 0.098 | 0.615 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5566 | 0.094 | 0.137 | 168.4 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.051 | 0.051 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5571 | 0.042 | 0.042 | 168.4 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.030 | 1.460 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.029 | 0.029 | 2.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2962 | 0.027 | 0.027 | 148.3 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.026 | 0.026 | 0.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.024 | 0.044 | 4.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:821 | 0.022 | 2.330 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4169 | 0.021 | 0.108 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.018 | 0.018 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 3.610 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.291 |
| res://addons/xr_editor/tools/manipulator.gd | 0.116 |
| res://addons/xr_editor/xr/simulator.gd | 0.094 |
| res://addons/xr_editor/core/feature_settings.gd | 0.069 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.068 |
| res://addons/xr_editor/ui/panels.gd | 0.061 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.042 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.035 |
| res://addons/xr_editor/xr/hand.gd | 0.035 |
| res://addons/xr_editor/tools/icons.gd | 0.027 |
| res://addons/xr_editor/xr/rig.gd | 0.026 |
| res://addons/xr_editor/xr/session.gd | 0.020 |
| res://addons/xr_editor/tools/locomotion.gd | 0.015 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 05 open_graph500

Thread 1: frames 298, mean Main::iteration 17.12 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 8.912 | 1.0 |
| process | 8.179 | 1.0 |
| AudioServer::update | 0.022 | 1.0 |
| physics | 0.021 | 1.0 |
| Physics Step | 0.021 | 1.0 |
| physics_process | 0.010 | 1.0 |
| PhysicsServer3D::sync | 0.003 | 1.0 |
| PhysicsServer2D::sync | 0.002 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| 2D physics | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.0 |
| main loop iteration prepare | 0.001 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 1.0 |
| main loop iteration end | 0.000 | 1.0 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 8.910 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 7.844 |
| engine C++ (main/) | 0.376 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.012 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 5.582 | 5.582 | 16.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 3.050 | 3.050 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4012 | 1.634 | 2.882 | 12.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3605 | 1.100 | 4.759 | 4.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 1.066 | 1.066 | 2428.1 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4034 | 0.719 | 0.719 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5539 | 0.542 | 0.829 | 4.0 |
| process | main/main.cpp:5061 | 0.322 | 8.179 | 1.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4446 | 0.321 | 0.698 | 293.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4509 | 0.272 | 0.348 | 291.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.212 | 0.212 | 1.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4433 | 0.211 | 0.211 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4017 | 0.193 | 1.248 | 2416.1 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5566 | 0.182 | 0.261 | 329.1 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4419 | 0.180 | 1.121 | 0.5 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5571 | 0.079 | 0.079 | 329.1 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.064 | 0.064 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.053 | 0.053 | 0.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2962 | 0.051 | 0.051 | 293.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.031 | 0.031 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.030 | 2.556 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4430 | 0.029 | 0.701 | 280.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4453 | 0.029 | 0.377 | 291.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4511 | 0.026 | 0.077 | 291.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5546 | 0.024 | 0.219 | 240.8 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 6.779 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.296 |
| res://addons/xr_editor/tools/manipulator.gd | 0.128 |
| res://addons/xr_editor/xr/simulator.gd | 0.102 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.101 |
| res://addons/xr_editor/core/feature_settings.gd | 0.071 |
| res://addons/xr_editor/ui/panels.gd | 0.065 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.043 |
| res://addons/xr_editor/xr/hand.gd | 0.036 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.036 |
| res://addons/xr_editor/tools/icons.gd | 0.030 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/xr/session.gd | 0.025 |
| res://addons/xr_editor/tools/locomotion.gd | 0.016 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.010 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 06 open

Thread 1: frames 842, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.369 | 1.0 |
| process | 1.657 | 1.0 |
| AudioServer::update | 0.015 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
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
| engine C++ (servers/) | 4.368 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.388 |
| engine C++ (main/) | 0.284 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.330 | 3.330 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.575 | 0.575 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.317 | 0.317 | 1.0 |
| process | main/main.cpp:5061 | 0.257 | 1.657 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4012 | 0.108 | 0.188 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.102 | 0.102 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.077 | 0.077 | 140.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3605 | 0.071 | 0.360 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4034 | 0.052 | 0.052 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5539 | 0.035 | 0.059 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4433 | 0.032 | 0.032 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.026 | 0.313 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4446 | 0.024 | 0.049 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4169 | 0.021 | 0.100 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.020 | 0.040 | 4.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.020 | 0.020 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.019 | 0.019 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:821 | 0.019 | 0.639 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5566 | 0.018 | 0.027 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4509 | 0.018 | 0.023 | 15.5 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3292 | 0.016 | 0.290 | 2.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.017 | 24.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4419 | 0.015 | 0.099 | 0.5 |
| _link_wire_hit | res://addons/xr_editor/logic_graph/blueprints.gd:6975 | 0.015 | 0.082 | 4.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.015 | 0.015 | 0.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.580 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.245 |
| res://addons/xr_editor/xr/simulator.gd | 0.081 |
| res://addons/xr_editor/tools/manipulator.gd | 0.071 |
| res://addons/xr_editor/core/feature_settings.gd | 0.063 |
| res://addons/xr_editor/ui/panels.gd | 0.051 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.049 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.039 |
| res://addons/xr_editor/xr/hand.gd | 0.031 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.031 |
| res://addons/xr_editor/xr/rig.gd | 0.025 |
| res://addons/xr_editor/tools/icons.gd | 0.024 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 07 closed

Thread 1: frames 842, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.167 | 1.0 |
| process | 0.861 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
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
| engine C++ (servers/) | 5.166 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.615 |
| engine C++ (main/) | 0.272 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.676 | 4.676 | 1.0 |
| process | main/main.cpp:5061 | 0.246 | 0.861 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.227 | 0.227 | 14.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.126 | 0.126 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.097 | 0.097 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.024 | 0.024 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:821 | 0.021 | 0.153 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2794 | 0.020 | 0.051 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.013 | 0.024 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.012 | 0.012 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.012 | 0.012 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.077 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.010 | 0.014 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.010 | 0.031 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.010 | 0.038 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4169 | 0.009 | 0.017 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3292 | 0.009 | 0.010 | 2.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 6.060 | 1.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1112 | 0.008 | 0.008 | 12.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1095 | 0.008 | 0.014 | 12.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.007 | 0.010 | 1.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.007 | 0.015 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.121 |
| res://addons/xr_editor/xr/simulator.gd | 0.080 |
| res://addons/xr_editor/tools/manipulator.gd | 0.079 |
| res://addons/xr_editor/core/feature_settings.gd | 0.061 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.049 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.029 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/ui/panels.gd | 0.026 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/tools/icons.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.002 |
