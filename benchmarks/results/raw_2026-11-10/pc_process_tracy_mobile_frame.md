logs/editor_sim_2026-11-10T19-33-35 (benchmarks/tracy_steps.py)

### 01 closed

Thread 1: frames 832, mean Main::iteration 6.11 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.307 | 1.0 |
| process | 0.776 | 1.0 |
| AudioServer::update | 0.016 | 1.0 |
| physics | 0.007 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| 3D physics | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.305 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.536 |
| engine C++ (main/) | 0.269 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.890 | 4.890 | 1.0 |
| process | main/main.cpp:5061 | 0.240 | 0.776 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.187 | 0.187 | 14.6 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.099 | 0.099 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.086 | 0.086 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.023 | 0.023 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.016 | 0.042 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.016 | 0.016 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.016 | 0.118 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.015 | 0.015 | 0.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.013 | 0.025 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.012 | 0.012 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.011 | 0.011 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.074 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.030 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.009 | 0.036 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.008 | 0.009 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1124 | 0.008 | 0.008 | 12.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 6.117 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.008 | 0.008 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.007 | 0.010 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.007 | 0.027 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1119 | 0.007 | 0.007 | 14.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.007 | 0.013 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.095 |
| res://addons/xr_editor/xr/simulator.gd | 0.078 |
| res://addons/xr_editor/tools/manipulator.gd | 0.072 |
| res://addons/xr_editor/core/feature_settings.gd | 0.056 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.042 |
| res://addons/xr_editor/xr/hand.gd | 0.025 |
| res://addons/xr_editor/ui/panels.gd | 0.024 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.002 |

### 02 open

Thread 1: frames 853, mean Main::iteration 6.05 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.343 | 1.0 |
| process | 1.682 | 1.0 |
| AudioServer::update | 0.017 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
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
| engine C++ (servers/) | 4.342 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.427 |
| engine C++ (main/) | 0.272 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.387 | 3.387 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.516 | 0.516 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.281 | 0.281 | 1.0 |
| process | main/main.cpp:5061 | 0.243 | 1.682 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.126 | 0.257 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.109 | 0.109 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.075 | 0.075 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.069 | 0.426 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.051 | 0.051 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.043 | 0.043 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.034 | 0.057 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.028 | 0.028 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.026 | 0.352 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.023 | 0.047 | 18.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.021 | 0.098 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.020 | 0.040 | 4.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.019 | 0.663 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.018 | 0.027 | 24.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.017 | 0.018 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.017 | 0.022 | 15.5 |
| AudioServer::update | main/main.cpp:5111 | 0.017 | 0.017 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.016 | 0.314 | 2.0 |
| _link_wire_hit | res://addons/xr_editor/logic_graph/blueprints.gd:6979 | 0.015 | 0.080 | 4.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.633 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.240 |
| res://addons/xr_editor/xr/simulator.gd | 0.080 |
| res://addons/xr_editor/tools/manipulator.gd | 0.071 |
| res://addons/xr_editor/core/feature_settings.gd | 0.062 |
| res://addons/xr_editor/ui/panels.gd | 0.050 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.044 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.043 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.031 |
| res://addons/xr_editor/xr/hand.gd | 0.030 |
| res://addons/xr_editor/xr/rig.gd | 0.025 |
| res://addons/xr_editor/tools/icons.gd | 0.024 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 03 open_big2

Thread 1: frames 835, mean Main::iteration 6.09 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.013 | 1.0 |
| process | 2.047 | 1.0 |
| AudioServer::update | 0.019 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
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
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.013 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.808 |
| engine C++ (main/) | 0.259 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.696 | 2.696 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.750 | 0.750 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.398 | 0.398 | 1.0 |
| process | main/main.cpp:5061 | 0.228 | 2.047 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.214 | 0.479 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.159 | 0.159 | 266.3 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.133 | 0.757 | 4.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.122 | 0.122 | 1.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.081 | 0.081 | 156.2 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.081 | 0.081 | 12.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.055 | 0.092 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.039 | 0.039 | 0.5 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.038 | 0.081 | 32.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.030 | 0.039 | 30.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.026 | 0.038 | 40.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.025 | 0.529 | 2.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.022 | 0.163 | 248.3 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.022 | 0.146 | 0.5 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.021 | 0.021 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.020 | 0.093 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.019 | 0.019 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.019 | 0.038 | 4.0 |
| AudioServer::update | main/main.cpp:5111 | 0.019 | 0.019 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.018 | 0.887 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.016 | 0.496 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 1.049 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.233 |
| res://addons/xr_editor/xr/simulator.gd | 0.075 |
| res://addons/xr_editor/tools/manipulator.gd | 0.070 |
| res://addons/xr_editor/core/feature_settings.gd | 0.059 |
| res://addons/xr_editor/ui/panels.gd | 0.047 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.045 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.037 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.030 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/locomotion.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 04 open

Thread 1: frames 854, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.305 | 1.0 |
| process | 1.728 | 1.0 |
| AudioServer::update | 0.016 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.304 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.457 |
| engine C++ (main/) | 0.287 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.283 | 3.283 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.564 | 0.564 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.295 | 0.295 | 1.0 |
| process | main/main.cpp:5061 | 0.258 | 1.728 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.125 | 0.256 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.111 | 0.111 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.075 | 0.075 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.068 | 0.425 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.051 | 0.051 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.043 | 0.043 | 78.1 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.036 | 0.059 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.030 | 0.030 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.026 | 0.350 | 2.0 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.023 | 0.047 | 18.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.022 | 0.022 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.021 | 0.101 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.020 | 0.020 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.020 | 0.039 | 4.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.019 | 0.673 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.018 | 0.027 | 24.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.017 | 0.022 | 15.5 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.016 | 0.316 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.016 | 0.016 | 1.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.017 | 24.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.016 | 0.096 | 0.5 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.641 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.246 |
| res://addons/xr_editor/xr/simulator.gd | 0.084 |
| res://addons/xr_editor/tools/manipulator.gd | 0.076 |
| res://addons/xr_editor/core/feature_settings.gd | 0.064 |
| res://addons/xr_editor/ui/panels.gd | 0.050 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.047 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.038 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.031 |
| res://addons/xr_editor/xr/hand.gd | 0.030 |
| res://addons/xr_editor/xr/rig.gd | 0.025 |
| res://addons/xr_editor/tools/icons.gd | 0.025 |
| res://addons/xr_editor/xr/session.gd | 0.016 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 05 open_big2

Thread 1: frames 853, mean Main::iteration 6.07 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.835 | 1.0 |
| process | 2.209 | 1.0 |
| AudioServer::update | 0.015 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.835 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.941 |
| engine C++ (main/) | 0.283 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.377 | 2.377 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.808 | 0.808 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.467 | 0.467 | 1.0 |
| process | main/main.cpp:5061 | 0.255 | 2.209 | 1.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4030 | 0.226 | 0.501 | 12.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4089 | 0.166 | 0.166 | 266.3 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3623 | 0.145 | 0.800 | 4.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.133 | 0.133 | 1.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.087 | 0.087 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4071 | 0.085 | 0.085 | 156.2 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5593 | 0.061 | 0.100 | 4.0 |
| lay | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4451 | 0.042 | 0.042 | 0.5 |
| _list_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4464 | 0.041 | 0.087 | 32.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4559 | 0.032 | 0.042 | 30.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5620 | 0.027 | 0.041 | 40.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.027 | 0.557 | 2.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.024 | 0.157 | 0.5 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.023 | 0.023 | 2.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4035 | 0.023 | 0.169 | 248.3 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.022 | 0.103 | 1.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.022 | 0.022 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.020 | 0.947 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:667 | 0.020 | 0.040 | 4.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.017 | 24.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.016 | 0.533 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 1.118 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.254 |
| res://addons/xr_editor/xr/simulator.gd | 0.081 |
| res://addons/xr_editor/tools/manipulator.gd | 0.077 |
| res://addons/xr_editor/core/feature_settings.gd | 0.063 |
| res://addons/xr_editor/ui/panels.gd | 0.051 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.048 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.040 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.031 |
| res://addons/xr_editor/xr/hand.gd | 0.030 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/tools/icons.gd | 0.024 |
| res://addons/xr_editor/xr/session.gd | 0.015 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.004 |

### 06 closed

Thread 1: frames 839, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.240 | 1.0 |
| process | 0.796 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.006 | 1.0 |
| Physics Step | 0.006 | 0.4 |
| physics_process | 0.003 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| 2D physics | 0.000 | 0.4 |
| xr_server->_process | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.239 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.566 |
| engine C++ (main/) | 0.257 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.804 | 4.804 | 1.0 |
| process | main/main.cpp:5061 | 0.230 | 0.796 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.202 | 0.202 | 14.8 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.097 | 0.097 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.092 | 0.092 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.024 | 0.024 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.020 | 0.020 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:822 | 0.017 | 0.128 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2795 | 0.017 | 0.042 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.012 | 0.025 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.012 | 0.012 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.011 | 0.011 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.011 | 0.075 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.009 | 0.031 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.009 | 0.012 | 1.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1124 | 0.009 | 0.009 | 12.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.008 | 0.035 | 2.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3293 | 0.008 | 0.009 | 2.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.008 | 0.008 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 6.068 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.007 | 0.010 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4173 | 0.007 | 0.015 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1119 | 0.007 | 0.007 | 14.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.102 |
| res://addons/xr_editor/xr/simulator.gd | 0.077 |
| res://addons/xr_editor/tools/manipulator.gd | 0.077 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.046 |
| res://addons/xr_editor/xr/hand.gd | 0.026 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.025 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/ui/panels.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.014 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
