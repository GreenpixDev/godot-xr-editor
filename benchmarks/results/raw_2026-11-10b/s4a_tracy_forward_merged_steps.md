
### 01 closed

Thread 1: frames 840, mean Main::iteration 6.04 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.216 | 1.0 |
| process | 0.790 | 1.0 |
| AudioServer::update | 0.026 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.215 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.546 |
| engine C++ (main/) | 0.284 |
| engine C++ (platform/) | 0.016 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.723 | 4.723 | 1.0 |
| process | main/main.cpp:5061 | 0.245 | 0.790 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.212 | 0.212 | 14.7 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.122 | 0.122 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.117 | 0.117 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.026 | 0.026 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.024 | 0.024 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.017 | 0.043 | 2.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.016 | 6.059 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.016 | 0.119 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.013 | 0.025 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.012 | 0.012 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.011 | 0.011 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.076 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.031 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.009 | 0.035 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.008 | 0.009 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1124 | 0.008 | 0.008 | 12.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.007 | 0.029 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.007 | 0.010 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1119 | 0.007 | 0.007 | 14.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.007 | 0.014 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1107 | 0.007 | 0.015 | 12.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.095 |
| res://addons/xr_editor/xr/simulator.gd | 0.079 |
| res://addons/xr_editor/tools/manipulator.gd | 0.073 |
| res://addons/xr_editor/core/feature_settings.gd | 0.060 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.041 |
| res://addons/xr_editor/xr/hand.gd | 0.027 |
| res://addons/xr_editor/ui/panels.gd | 0.024 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.002 |

### 02 open

Thread 1: frames 835, mean Main::iteration 6.07 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.401 | 1.0 |
| process | 1.639 | 1.0 |
| AudioServer::update | 0.021 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
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
| engine C++ (servers/) | 4.400 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.379 |
| engine C++ (main/) | 0.282 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.398 | 3.398 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.533 | 0.533 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.305 | 0.305 | 1.0 |
| process | main/main.cpp:5061 | 0.249 | 1.639 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.118 | 0.241 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.117 | 0.117 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.070 | 0.070 | 140.1 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.065 | 0.400 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.047 | 0.047 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.041 | 0.041 | 78.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.034 | 0.056 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.027 | 0.027 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.025 | 0.330 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.022 | 0.045 | 18.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.021 | 0.021 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.021 | 0.021 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.020 | 0.094 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.019 | 0.037 | 4.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.018 | 0.630 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.016 | 0.025 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.016 | 0.021 | 15.5 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.016 | 0.016 | 0.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.017 | 24.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.015 | 0.300 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.601 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.231 |
| res://addons/xr_editor/xr/simulator.gd | 0.078 |
| res://addons/xr_editor/tools/manipulator.gd | 0.071 |
| res://addons/xr_editor/core/feature_settings.gd | 0.060 |
| res://addons/xr_editor/ui/panels.gd | 0.048 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.047 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.041 |
| res://addons/xr_editor/xr/hand.gd | 0.030 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.029 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/tools/icons.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.016 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 03 open_graph100

Thread 1: frames 840, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.629 | 1.0 |
| process | 2.414 | 1.0 |
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
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.631 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.219 |
| engine C++ (main/) | 0.208 |
| GDScript: other scripts, with engine calls made from them | 0.010 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.002 | 2.002 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.879 | 0.879 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.601 | 0.601 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.345 | 0.738 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.264 | 0.264 | 500.6 |
| process | main/main.cpp:5061 | 0.185 | 2.414 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.182 | 1.107 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.141 | 0.141 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.111 | 0.111 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.093 | 0.152 | 4.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.078 | 0.078 | 156.2 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.069 | 0.144 | 61.5 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.056 | 0.056 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.053 | 0.069 | 59.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.041 | 0.296 | 488.6 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.041 | 0.057 | 72.1 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.034 | 0.241 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.023 | 0.710 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.021 | 0.021 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.018 | 0.080 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.018 | 0.036 | 4.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5625 | 0.016 | 0.016 | 72.1 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.016 | 1.131 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.015 | 0.015 | 2.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.015 | 0.016 | 24.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 1.544 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.205 |
| res://addons/xr_editor/xr/simulator.gd | 0.064 |
| res://addons/xr_editor/tools/manipulator.gd | 0.062 |
| res://addons/xr_editor/core/feature_settings.gd | 0.055 |
| res://addons/xr_editor/ui/panels.gd | 0.044 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.039 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.035 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.027 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.011 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/blueprints/document.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.006 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.003 |

### 04 open_graph250

Thread 1: frames 618, mean Main::iteration 8.27 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.143 | 1.0 |
| process | 4.106 | 1.0 |
| AudioServer::update | 0.013 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.008 | 0.5 |
| physics_process | 0.004 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| NavigationServer3D::physics_process | 0.000 | 0.5 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.141 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 3.863 |
| engine C++ (main/) | 0.264 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 2.439 | 2.439 | 16.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 1.496 | 1.496 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.719 | 1.347 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.544 | 0.544 | 1222.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.422 | 2.144 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.327 | 0.327 | 12.0 |
| process | main/main.cpp:5061 | 0.238 | 4.106 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.218 | 0.348 | 4.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.157 | 0.157 | 1.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.156 | 0.339 | 148.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.131 | 0.168 | 146.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.120 | 0.120 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.094 | 0.629 | 1210.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.087 | 0.119 | 168.3 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.082 | 0.557 | 0.5 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.040 | 0.040 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5625 | 0.032 | 0.032 | 168.3 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2974 | 0.025 | 0.025 | 148.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.025 | 1.298 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.023 | 0.023 | 0.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.019 | 0.090 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.018 | 0.036 | 4.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.017 | 2.057 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.015 | 1.363 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 3.103 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.223 |
| res://addons/xr_editor/tools/manipulator.gd | 0.089 |
| res://addons/xr_editor/xr/simulator.gd | 0.071 |
| res://addons/xr_editor/core/feature_settings.gd | 0.055 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.054 |
| res://addons/xr_editor/ui/panels.gd | 0.045 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.035 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.021 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 05 open_graph500

Thread 1: frames 305, mean Main::iteration 16.64 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 8.603 | 1.0 |
| process | 8.044 | 1.0 |
| AudioServer::update | 0.022 | 1.0 |
| physics | 0.018 | 1.0 |
| Physics Step | 0.018 | 1.0 |
| physics_process | 0.009 | 1.0 |
| PhysicsServer3D::sync | 0.003 | 1.0 |
| PhysicsServer2D::sync | 0.002 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| 2D physics | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.0 |
| main loop iteration prepare | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| setup | 0.000 | 1.0 |
| main loop iteration end | 0.000 | 1.0 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 8.615 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 7.734 |
| engine C++ (main/) | 0.363 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.010 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 5.189 | 5.189 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 3.131 | 3.131 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 1.640 | 2.896 | 12.1 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 1.077 | 1.077 | 2433.6 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 1.039 | 4.728 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.736 | 0.736 | 12.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.517 | 0.802 | 4.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.331 | 0.713 | 294.5 |
| process | main/main.cpp:5061 | 0.314 | 8.044 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.274 | 0.352 | 292.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.222 | 0.222 | 1.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.211 | 0.211 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.193 | 1.259 | 2421.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.183 | 0.258 | 329.6 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.176 | 1.130 | 0.5 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5625 | 0.075 | 0.075 | 329.6 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.062 | 0.062 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.053 | 0.053 | 0.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2974 | 0.053 | 0.053 | 294.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.030 | 2.597 | 2.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4471 | 0.030 | 0.382 | 292.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.029 | 0.715 | 280.9 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.028 | 0.028 | 2.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4561 | 0.026 | 0.078 | 292.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5600 | 0.025 | 0.218 | 241.2 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 6.728 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.282 |
| res://addons/xr_editor/tools/manipulator.gd | 0.122 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.098 |
| res://addons/xr_editor/xr/simulator.gd | 0.096 |
| res://addons/xr_editor/core/feature_settings.gd | 0.066 |
| res://addons/xr_editor/ui/panels.gd | 0.059 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.042 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.035 |
| res://addons/xr_editor/xr/hand.gd | 0.035 |
| res://addons/xr_editor/tools/icons.gd | 0.027 |
| res://addons/xr_editor/xr/rig.gd | 0.026 |
| res://addons/xr_editor/xr/session.gd | 0.022 |
| res://addons/xr_editor/tools/locomotion.gd | 0.015 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.004 |

### 06 open

Thread 1: frames 839, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.511 | 1.0 |
| process | 1.516 | 1.0 |
| AudioServer::update | 0.016 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.510 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.278 |
| engine C++ (main/) | 0.255 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.524 | 3.524 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.537 | 0.537 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.298 | 0.298 | 1.0 |
| process | main/main.cpp:5061 | 0.227 | 1.516 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.108 | 0.108 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.100 | 0.174 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.072 | 0.072 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.066 | 0.335 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.048 | 0.048 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.033 | 0.055 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.029 | 0.029 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.025 | 0.294 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.022 | 0.046 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.020 | 0.090 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.019 | 0.038 | 4.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.018 | 0.018 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.018 | 0.018 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.017 | 0.588 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.016 | 0.025 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.016 | 0.021 | 15.5 |
| AudioServer::update | main/main.cpp:5111 | 0.016 | 0.016 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.015 | 0.267 | 2.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.015 | 0.016 | 24.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.015 | 0.015 | 0.0 |
| _link_wire_hit | res://addons/xr_editor/logic_graph/blueprints.gd:6979 | 0.014 | 0.077 | 4.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.534 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.225 |
| res://addons/xr_editor/xr/simulator.gd | 0.075 |
| res://addons/xr_editor/tools/manipulator.gd | 0.065 |
| res://addons/xr_editor/core/feature_settings.gd | 0.059 |
| res://addons/xr_editor/ui/panels.gd | 0.047 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.044 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.036 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.030 |
| res://addons/xr_editor/xr/hand.gd | 0.029 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 07 closed

Thread 1: frames 840, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.390 | 1.0 |
| process | 0.643 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
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
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.389 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.473 |
| engine C++ (main/) | 0.194 |
| engine C++ (platform/) | 0.006 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.989 | 4.989 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.179 | 0.179 | 14.7 |
| process | main/main.cpp:5061 | 0.170 | 0.643 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.100 | 0.100 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.087 | 0.087 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.015 | 0.015 | 0.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.015 | 0.037 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.015 | 0.015 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.015 | 0.106 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.010 | 0.018 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.010 | 0.010 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.010 | 0.063 | 2.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.009 | 0.009 | 1.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.008 | 0.026 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.007 | 0.009 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.007 | 0.029 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.007 | 0.008 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1124 | 0.007 | 0.007 | 12.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.006 | 6.061 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.006 | 0.012 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1119 | 0.006 | 0.006 | 14.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1107 | 0.006 | 0.011 | 12.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.006 | 0.097 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.084 |
| res://addons/xr_editor/tools/manipulator.gd | 0.062 |
| res://addons/xr_editor/xr/simulator.gd | 0.062 |
| res://addons/xr_editor/core/feature_settings.gd | 0.051 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.040 |
| res://addons/xr_editor/xr/hand.gd | 0.023 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.020 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/ui/panels.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.012 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/palette.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.001 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.001 |
| res://addons/xr_editor/tools/undo.gd | 0.001 |
