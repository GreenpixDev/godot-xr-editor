logs/editor_sim_2026-11-10T19-30-23 (benchmarks/tracy_steps.py)

### 01 closed

Thread 1: frames 839, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.250 | 1.0 |
| process | 0.775 | 1.0 |
| AudioServer::update | 0.017 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.249 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.540 |
| engine C++ (main/) | 0.265 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.792 | 4.792 | 1.0 |
| process | main/main.cpp:5061 | 0.236 | 0.775 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.206 | 0.206 | 14.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.112 | 0.112 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.098 | 0.098 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.023 | 0.023 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.017 | 0.017 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.017 | 0.042 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.015 | 0.118 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.015 | 0.015 | 0.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.013 | 0.025 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.012 | 0.012 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.012 | 0.012 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.075 | 2.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.009 | 0.036 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.031 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.008 | 0.009 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1124 | 0.008 | 0.008 | 12.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 6.059 | 1.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.007 | 0.014 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.007 | 0.029 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1119 | 0.007 | 0.007 | 14.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.007 | 0.010 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1107 | 0.007 | 0.013 | 12.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.095 |
| res://addons/xr_editor/xr/simulator.gd | 0.078 |
| res://addons/xr_editor/tools/manipulator.gd | 0.073 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.042 |
| res://addons/xr_editor/xr/hand.gd | 0.027 |
| res://addons/xr_editor/ui/panels.gd | 0.024 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.021 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.002 |

### 02 open

Thread 1: frames 853, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.373 | 1.0 |
| process | 1.652 | 1.0 |
| AudioServer::update | 0.019 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
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
| engine C++ (servers/) | 4.372 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.394 |
| engine C++ (main/) | 0.278 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.389 | 3.389 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.523 | 0.523 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.300 | 0.300 | 1.0 |
| process | main/main.cpp:5061 | 0.246 | 1.652 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.122 | 0.248 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.116 | 0.116 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.073 | 0.073 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.067 | 0.412 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.049 | 0.049 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.042 | 0.042 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.034 | 0.056 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.029 | 0.029 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.025 | 0.337 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.022 | 0.045 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.020 | 0.095 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.020 | 0.038 | 4.0 |
| AudioServer::update | main/main.cpp:5111 | 0.019 | 0.019 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.018 | 0.018 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.018 | 0.642 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.017 | 0.026 | 24.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.017 | 0.017 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.016 | 0.021 | 15.5 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.016 | 0.308 | 2.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.015 | 0.092 | 0.5 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.615 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.233 |
| res://addons/xr_editor/xr/simulator.gd | 0.079 |
| res://addons/xr_editor/tools/manipulator.gd | 0.070 |
| res://addons/xr_editor/core/feature_settings.gd | 0.061 |
| res://addons/xr_editor/ui/panels.gd | 0.049 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.043 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.042 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.030 |
| res://addons/xr_editor/xr/hand.gd | 0.030 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/tools/icons.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.012 |
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

### 03 open_big2

Thread 1: frames 856, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.895 | 1.0 |
| process | 2.138 | 1.0 |
| AudioServer::update | 0.015 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
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
| engine C++ (servers/) | 3.893 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.869 |
| engine C++ (main/) | 0.286 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.498 | 2.498 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.775 | 0.775 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.454 | 0.454 | 1.0 |
| process | main/main.cpp:5061 | 0.258 | 2.138 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.215 | 0.474 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.155 | 0.155 | 266.5 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.138 | 0.757 | 4.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.119 | 0.119 | 1.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.082 | 0.082 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.080 | 0.080 | 156.3 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.056 | 0.093 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.040 | 0.040 | 0.5 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.039 | 0.082 | 32.6 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.030 | 0.040 | 30.1 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.026 | 0.039 | 40.1 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.025 | 0.520 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.024 | 0.024 | 2.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.023 | 0.150 | 0.5 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.022 | 0.022 | 2.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.021 | 0.159 | 248.4 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.021 | 0.099 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.019 | 0.038 | 4.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.019 | 0.895 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.016 | 0.509 | 2.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.016 | 24.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 1.059 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.243 |
| res://addons/xr_editor/xr/simulator.gd | 0.082 |
| res://addons/xr_editor/tools/manipulator.gd | 0.078 |
| res://addons/xr_editor/core/feature_settings.gd | 0.062 |
| res://addons/xr_editor/ui/panels.gd | 0.050 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.047 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.038 |
| res://addons/xr_editor/xr/hand.gd | 0.031 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.030 |
| res://addons/xr_editor/tools/icons.gd | 0.025 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 04 open

Thread 1: frames 855, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.369 | 1.0 |
| process | 1.658 | 1.0 |
| AudioServer::update | 0.015 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.368 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.392 |
| engine C++ (main/) | 0.283 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.334 | 3.334 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.561 | 0.561 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.317 | 0.317 | 1.0 |
| process | main/main.cpp:5061 | 0.255 | 1.658 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.120 | 0.243 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.110 | 0.110 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.071 | 0.071 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.065 | 0.403 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.048 | 0.048 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.041 | 0.041 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.033 | 0.055 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.029 | 0.029 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.024 | 0.326 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.022 | 0.045 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.020 | 0.095 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.019 | 0.037 | 4.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.018 | 0.632 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.017 | 0.025 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.016 | 0.021 | 15.5 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.016 | 0.304 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.015 | 0.015 | 1.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.015 | 0.016 | 24.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.014 | 0.091 | 0.5 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.606 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.233 |
| res://addons/xr_editor/xr/simulator.gd | 0.082 |
| res://addons/xr_editor/tools/manipulator.gd | 0.071 |
| res://addons/xr_editor/core/feature_settings.gd | 0.062 |
| res://addons/xr_editor/ui/panels.gd | 0.049 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.046 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.037 |
| res://addons/xr_editor/xr/hand.gd | 0.030 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.029 |
| res://addons/xr_editor/xr/rig.gd | 0.025 |
| res://addons/xr_editor/tools/icons.gd | 0.024 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 05 open_big2

Thread 1: frames 842, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.864 | 1.0 |
| process | 2.162 | 1.0 |
| AudioServer::update | 0.016 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.864 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.891 |
| engine C++ (main/) | 0.287 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.409 | 2.409 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.807 | 0.807 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.474 | 0.474 | 1.0 |
| process | main/main.cpp:5061 | 0.259 | 2.162 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.220 | 0.482 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.158 | 0.158 | 266.3 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.137 | 0.767 | 4.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.128 | 0.128 | 1.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.084 | 0.084 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.080 | 0.080 | 156.2 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.058 | 0.095 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.042 | 0.042 | 0.5 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.039 | 0.082 | 32.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.030 | 0.039 | 30.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.026 | 0.039 | 40.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.026 | 0.529 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.025 | 0.025 | 2.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.024 | 0.152 | 0.5 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.022 | 0.162 | 248.3 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.021 | 0.021 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.021 | 0.099 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.020 | 0.039 | 4.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.019 | 0.907 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.016 | 0.515 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.016 | 0.016 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 1.073 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.246 |
| res://addons/xr_editor/xr/simulator.gd | 0.082 |
| res://addons/xr_editor/tools/manipulator.gd | 0.079 |
| res://addons/xr_editor/core/feature_settings.gd | 0.063 |
| res://addons/xr_editor/ui/panels.gd | 0.050 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.048 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.038 |
| res://addons/xr_editor/xr/hand.gd | 0.031 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.031 |
| res://addons/xr_editor/tools/icons.gd | 0.025 |
| res://addons/xr_editor/xr/rig.gd | 0.025 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 06 closed

Thread 1: frames 842, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.244 | 1.0 |
| process | 0.785 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 2D navigation | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.242 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.555 |
| engine C++ (main/) | 0.256 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.794 | 4.794 | 1.0 |
| process | main/main.cpp:5061 | 0.230 | 0.785 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.207 | 0.207 | 14.6 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.114 | 0.114 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.089 | 0.089 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.023 | 0.023 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.018 | 0.018 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.017 | 0.125 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.016 | 0.040 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.012 | 0.024 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.012 | 0.012 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.011 | 0.011 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.010 | 0.072 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.030 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.009 | 0.012 | 1.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1124 | 0.008 | 0.008 | 12.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.008 | 0.033 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.008 | 0.009 | 2.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 6.060 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.008 | 0.015 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.007 | 0.028 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.007 | 0.010 | 1.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.007 | 0.013 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.099 |
| res://addons/xr_editor/xr/simulator.gd | 0.076 |
| res://addons/xr_editor/tools/manipulator.gd | 0.073 |
| res://addons/xr_editor/core/feature_settings.gd | 0.057 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.045 |
| res://addons/xr_editor/xr/hand.gd | 0.027 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.024 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/ui/panels.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
