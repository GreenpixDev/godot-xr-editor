
### 01 closed

Thread 1: frames 839, mean Main::iteration 6.07 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.445 | 1.0 |
| process | 0.605 | 1.0 |
| AudioServer::update | 0.012 | 1.0 |
| physics | 0.005 | 1.0 |
| Physics Step | 0.005 | 0.4 |
| physics_process | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.000 | 0.4 |
| process 2D navigation | 0.000 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.443 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.442 |
| engine C++ (main/) | 0.184 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 5.006 | 5.006 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.258 | 0.258 | 14.8 |
| process | main/main.cpp:5061 | 0.162 | 0.605 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.079 | 0.079 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.067 | 0.067 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.020 | 0.020 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.015 | 0.037 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.013 | 0.013 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.013 | 0.096 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.010 | 0.061 | 2.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.010 | 0.010 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.009 | 0.018 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.009 | 0.009 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.008 | 0.028 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.008 | 0.030 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.007 | 0.008 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1124 | 0.007 | 0.007 | 12.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1119 | 0.007 | 0.007 | 14.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.007 | 6.075 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1107 | 0.006 | 0.012 | 12.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.006 | 0.087 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.006 | 0.006 | 1.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.006 | 0.011 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.077 |
| res://addons/xr_editor/xr/simulator.gd | 0.062 |
| res://addons/xr_editor/tools/manipulator.gd | 0.058 |
| res://addons/xr_editor/core/feature_settings.gd | 0.053 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.035 |
| res://addons/xr_editor/xr/hand.gd | 0.022 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.019 |
| res://addons/xr_editor/tools/icons.gd | 0.018 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.018 |
| res://addons/xr_editor/xr/session.gd | 0.010 |
| res://addons/xr_editor/tools/locomotion.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.003 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.001 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.001 |
| res://addons/xr_editor/tools/undo.gd | 0.001 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.001 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.001 |

### 02 open

Thread 1: frames 837, mean Main::iteration 6.07 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.627 | 1.0 |
| process | 1.425 | 1.0 |
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
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.626 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.242 |
| engine C++ (main/) | 0.195 |
| GDScript: other scripts, with engine calls made from them | 0.010 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.705 | 3.705 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.572 | 0.572 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.221 | 0.221 | 1.0 |
| process | main/main.cpp:5061 | 0.173 | 1.425 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.118 | 0.245 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.089 | 0.089 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.072 | 0.072 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.063 | 0.402 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.049 | 0.049 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.042 | 0.042 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.030 | 0.050 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.024 | 0.024 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.023 | 0.322 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.022 | 0.045 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.018 | 0.079 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.018 | 0.036 | 4.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.017 | 24.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.016 | 0.023 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.016 | 0.021 | 15.5 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.016 | 0.583 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.015 | 0.290 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.014 | 0.014 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.014 | 0.014 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| _link_wire_hit | res://addons/xr_editor/logic_graph/blueprints.gd:6979 | 0.013 | 0.071 | 4.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.581 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.201 |
| res://addons/xr_editor/xr/simulator.gd | 0.064 |
| res://addons/xr_editor/core/feature_settings.gd | 0.055 |
| res://addons/xr_editor/tools/manipulator.gd | 0.053 |
| res://addons/xr_editor/ui/panels.gd | 0.043 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.040 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.037 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.025 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.018 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/blueprints/document.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.006 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.003 |

### 03 open_graph100

Thread 1: frames 822, mean Main::iteration 6.17 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.623 | 1.0 |
| process | 2.526 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.623 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.304 |
| engine C++ (main/) | 0.236 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.792 | 1.792 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.072 | 1.072 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.599 | 0.599 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.353 | 0.748 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.265 | 0.265 | 500.6 |
| process | main/main.cpp:5061 | 0.211 | 2.526 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.189 | 1.130 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.146 | 0.146 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.115 | 0.115 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.098 | 0.157 | 4.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.078 | 0.078 | 156.2 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.070 | 0.150 | 61.6 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.059 | 0.059 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.057 | 0.073 | 59.1 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.042 | 0.297 | 488.6 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.042 | 0.058 | 72.1 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.037 | 0.253 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.024 | 0.723 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.023 | 0.023 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.019 | 0.037 | 4.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.018 | 0.085 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.018 | 0.018 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.017 | 1.170 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5625 | 0.017 | 0.017 | 72.1 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.015 | 0.731 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 1.589 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.216 |
| res://addons/xr_editor/xr/simulator.gd | 0.070 |
| res://addons/xr_editor/tools/manipulator.gd | 0.068 |
| res://addons/xr_editor/core/feature_settings.gd | 0.057 |
| res://addons/xr_editor/ui/panels.gd | 0.045 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.042 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.036 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.029 |
| res://addons/xr_editor/xr/hand.gd | 0.026 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.020 |
| res://addons/xr_editor/xr/session.gd | 0.012 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 04 open_graph250

Thread 1: frames 605, mean Main::iteration 8.42 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| process | 4.282 | 1.0 |
| RenderingServer::draw | 4.123 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.008 | 0.5 |
| physics_process | 0.004 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| NavigationServer3D::physics_process | 0.000 | 0.5 |
| 2D physics | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.122 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 4.010 |
| engine C++ (main/) | 0.289 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 2.508 | 2.508 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 1.398 | 1.398 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.729 | 1.356 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.542 | 0.542 | 1222.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.464 | 2.220 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.351 | 0.351 | 12.0 |
| process | main/main.cpp:5061 | 0.261 | 4.282 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.226 | 0.360 | 4.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.164 | 0.164 | 1.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.159 | 0.345 | 148.7 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.134 | 0.172 | 146.2 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.124 | 0.124 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.094 | 0.627 | 1210.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.089 | 0.574 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.087 | 0.123 | 168.3 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.040 | 0.040 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5625 | 0.036 | 0.036 | 168.3 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2974 | 0.026 | 0.026 | 148.2 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.025 | 1.334 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.022 | 0.022 | 0.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.020 | 0.038 | 4.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.019 | 0.093 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.019 | 2.123 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.015 | 1.424 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 3.211 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.237 |
| res://addons/xr_editor/tools/manipulator.gd | 0.091 |
| res://addons/xr_editor/xr/simulator.gd | 0.076 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.057 |
| res://addons/xr_editor/core/feature_settings.gd | 0.057 |
| res://addons/xr_editor/ui/panels.gd | 0.049 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.036 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.030 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 05 open_graph500

Thread 1: frames 305, mean Main::iteration 16.68 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 8.740 | 1.0 |
| process | 7.919 | 1.0 |
| AudioServer::update | 0.022 | 1.0 |
| physics | 0.019 | 1.0 |
| Physics Step | 0.018 | 1.0 |
| physics_process | 0.009 | 1.0 |
| PhysicsServer3D::sync | 0.003 | 1.0 |
| PhysicsServer2D::sync | 0.002 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| 2D physics | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 1.0 |
| main loop iteration end | 0.000 | 1.0 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 8.739 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 7.599 |
| engine C++ (main/) | 0.357 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.010 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 5.553 | 5.553 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 2.885 | 2.885 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 1.571 | 2.819 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 1.069 | 1.069 | 2427.9 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 1.024 | 4.632 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.731 | 0.731 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.517 | 0.795 | 4.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.319 | 0.696 | 294.5 |
| process | main/main.cpp:5061 | 0.307 | 7.919 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.272 | 0.347 | 292.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.215 | 0.215 | 1.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.194 | 0.194 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.190 | 1.249 | 2415.9 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.180 | 0.252 | 329.1 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.177 | 1.098 | 0.5 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5625 | 0.072 | 0.072 | 329.1 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.062 | 0.062 | 2.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2974 | 0.051 | 0.051 | 294.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.051 | 0.051 | 0.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4471 | 0.030 | 0.377 | 292.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.029 | 2.546 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.029 | 0.029 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.028 | 0.699 | 280.9 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4561 | 0.026 | 0.076 | 292.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5600 | 0.024 | 0.212 | 240.8 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 6.591 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.282 |
| res://addons/xr_editor/tools/manipulator.gd | 0.123 |
| res://addons/xr_editor/xr/simulator.gd | 0.097 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.096 |
| res://addons/xr_editor/core/feature_settings.gd | 0.067 |
| res://addons/xr_editor/ui/panels.gd | 0.060 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.042 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.035 |
| res://addons/xr_editor/xr/hand.gd | 0.032 |
| res://addons/xr_editor/tools/icons.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.026 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/tools/locomotion.gd | 0.015 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 06 open

Thread 1: frames 839, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.718 | 1.0 |
| process | 1.323 | 1.0 |
| AudioServer::update | 0.013 | 1.0 |
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
| xr_server->_process | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.716 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.147 |
| engine C++ (main/) | 0.189 |
| GDScript: other scripts, with engine calls made from them | 0.010 |
| engine C++ (platform/) | 0.006 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.915 | 3.915 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.458 | 0.458 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.218 | 0.218 | 1.0 |
| process | main/main.cpp:5061 | 0.167 | 1.323 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.096 | 0.168 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.086 | 0.086 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.070 | 0.070 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.062 | 0.323 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.048 | 0.048 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.031 | 0.050 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.026 | 0.026 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.023 | 0.285 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.022 | 0.044 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.018 | 0.080 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.018 | 0.036 | 4.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.016 | 0.023 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.016 | 0.020 | 15.5 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.015 | 0.547 | 1.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.015 | 0.015 | 24.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.014 | 0.014 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.014 | 0.244 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.013 | 0.013 | 2.0 |
| _link_wire_hit | res://addons/xr_editor/logic_graph/blueprints.gd:6979 | 0.013 | 0.071 | 4.0 |
| AudioServer::update | main/main.cpp:5111 | 0.013 | 0.013 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.502 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.199 |
| res://addons/xr_editor/xr/simulator.gd | 0.062 |
| res://addons/xr_editor/core/feature_settings.gd | 0.054 |
| res://addons/xr_editor/tools/manipulator.gd | 0.053 |
| res://addons/xr_editor/ui/panels.gd | 0.042 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.037 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.034 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.027 |
| res://addons/xr_editor/xr/hand.gd | 0.024 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.018 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/blueprints/document.gd | 0.010 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.006 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.002 |

### 07 closed

Thread 1: frames 837, mean Main::iteration 6.08 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.469 | 1.0 |
| process | 0.595 | 1.0 |
| AudioServer::update | 0.011 | 1.0 |
| physics | 0.004 | 1.0 |
| Physics Step | 0.004 | 0.4 |
| physics_process | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 2D navigation | 0.000 | 1.0 |
| PhysicsServer2D::sync | 0.000 | 0.4 |
| process 3D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.468 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.452 |
| engine C++ (main/) | 0.162 |
| engine C++ (platform/) | 0.006 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 5.001 | 5.001 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.290 | 0.290 | 14.8 |
| process | main/main.cpp:5061 | 0.142 | 0.595 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.077 | 0.077 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.068 | 0.068 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.015 | 0.036 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.014 | 0.101 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.013 | 0.013 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.011 | 0.011 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.010 | 0.060 | 2.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.009 | 0.009 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.009 | 0.009 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.009 | 0.016 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.008 | 0.026 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.007 | 0.029 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.007 | 0.008 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1124 | 0.007 | 0.007 | 12.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1119 | 0.007 | 0.007 | 14.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.007 | 0.011 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1107 | 0.006 | 0.012 | 12.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.006 | 0.008 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.006 | 6.088 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.006 | 0.006 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.081 |
| res://addons/xr_editor/tools/manipulator.gd | 0.060 |
| res://addons/xr_editor/xr/simulator.gd | 0.059 |
| res://addons/xr_editor/core/feature_settings.gd | 0.052 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.037 |
| res://addons/xr_editor/xr/hand.gd | 0.022 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.019 |
| res://addons/xr_editor/tools/icons.gd | 0.018 |
| res://addons/xr_editor/ui/panels.gd | 0.018 |
| res://addons/xr_editor/xr/session.gd | 0.010 |
| res://addons/xr_editor/tools/locomotion.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/tools/outline.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.003 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.001 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.001 |
| res://addons/xr_editor/tools/undo.gd | 0.001 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.001 |
