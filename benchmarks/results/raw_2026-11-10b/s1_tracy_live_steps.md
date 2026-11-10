
### 01 closed

Thread 1: frames 840, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.387 | 1.0 |
| process | 0.654 | 1.0 |
| AudioServer::update | 0.011 | 1.0 |
| physics | 0.007 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| process 2D navigation | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.386 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.469 |
| engine C++ (main/) | 0.207 |
| engine C++ (platform/) | 0.006 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.950 | 4.950 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.185 | 0.185 | 14.7 |
| process | main/main.cpp:5061 | 0.185 | 0.654 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.102 | 0.102 | 2.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.080 | 0.080 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.042 | 5.104 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.020 | 0.020 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.015 | 0.015 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.015 | 0.038 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.014 | 0.105 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.011 | 0.011 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.010 | 0.010 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.010 | 0.020 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.010 | 0.064 | 2.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.009 | 0.033 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.008 | 0.026 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3290 | 0.008 | 0.009 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1089 | 0.007 | 0.007 | 12.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1072 | 0.006 | 0.012 | 12.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.006 | 6.068 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1084 | 0.006 | 0.006 | 14.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.006 | 0.006 | 2.0 |
| _process | res://addons/xr_editor/xr/simulator.gd:474 | 0.006 | 0.011 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.006 | 0.090 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.085 |
| res://addons/xr_editor/xr/simulator.gd | 0.065 |
| res://addons/xr_editor/tools/manipulator.gd | 0.062 |
| res://addons/xr_editor/core/feature_settings.gd | 0.052 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.037 |
| res://addons/xr_editor/xr/hand.gd | 0.023 |
| res://addons/xr_editor/ui/panels.gd | 0.022 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.012 |
| res://addons/xr_editor/tools/locomotion.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.002 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.001 |
| res://addons/xr_editor/xr/standalone.gd | 0.001 |
| res://addons/xr_editor/tools/undo.gd | 0.001 |

### 02 open

Thread 1: frames 840, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.222 | 1.0 |
| process | 1.818 | 1.0 |
| AudioServer::update | 0.011 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.008 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.4 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| 3D physics | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.221 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.588 |
| engine C++ (main/) | 0.243 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.241 | 3.241 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.520 | 0.520 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.296 | 0.296 | 2.0 |
| process | main/main.cpp:5061 | 0.218 | 1.818 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.129 | 0.138 | 41.2 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.123 | 0.331 | 18.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4011 | 0.118 | 0.241 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.085 | 0.085 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4070 | 0.071 | 0.071 | 140.2 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3604 | 0.063 | 0.395 | 4.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.047 | 3.594 | 1.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4033 | 0.047 | 0.047 | 12.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.041 | 0.041 | 78.1 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.039 | 0.039 | 1248.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5487 | 0.032 | 0.053 | 4.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.024 | 0.325 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.021 | 0.021 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.019 | 0.091 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.019 | 0.019 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.018 | 0.035 | 4.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.017 | 0.350 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.017 | 0.022 | 15.5 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.877 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5514 | 0.016 | 0.024 | 24.0 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.017 | 24.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.852 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.221 |
| res://addons/xr_editor/xr/simulator.gd | 0.073 |
| res://addons/xr_editor/tools/manipulator.gd | 0.068 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/ui/panels.gd | 0.046 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.041 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.040 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.027 |
| res://addons/xr_editor/xr/rig.gd | 0.023 |
| res://addons/xr_editor/tools/icons.gd | 0.021 |
| res://addons/xr_editor/xr/session.gd | 0.013 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/tools/outline.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 03 open_graph100

Thread 1: frames 639, mean Main::iteration 7.97 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.058 | 1.0 |
| process | 3.881 | 1.0 |
| AudioServer::update | 0.014 | 1.0 |
| physics | 0.011 | 1.0 |
| Physics Step | 0.011 | 0.5 |
| physics_process | 0.004 | 0.5 |
| 2D physics | 0.003 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| prepare | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| 3D physics | 0.001 | 0.5 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.001 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.057 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 3.597 |
| engine C++ (main/) | 0.306 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.707 | 1.707 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.328 | 1.328 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.801 | 0.801 | 2.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.588 | 0.624 | 200.4 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.447 | 1.328 | 61.4 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4011 | 0.365 | 0.763 | 12.0 |
| process | main/main.cpp:5061 | 0.274 | 3.881 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4070 | 0.267 | 0.267 | 500.4 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3604 | 0.199 | 1.158 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4033 | 0.146 | 0.146 | 12.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.145 | 0.145 | 4750.6 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.109 | 0.109 | 1.0 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5487 | 0.099 | 0.162 | 4.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.079 | 0.079 | 156.1 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.076 | 2.595 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.060 | 0.078 | 58.9 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.051 | 1.387 | 0.5 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5514 | 0.043 | 0.061 | 72.1 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4016 | 0.041 | 0.299 | 488.4 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.031 | 0.031 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.028 | 0.028 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.026 | 0.734 | 2.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.021 | 0.039 | 4.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.020 | 0.020 | 0.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.020 | 0.097 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 2.765 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.243 |
| res://addons/xr_editor/tools/manipulator.gd | 0.090 |
| res://addons/xr_editor/xr/simulator.gd | 0.084 |
| res://addons/xr_editor/core/feature_settings.gd | 0.061 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.054 |
| res://addons/xr_editor/ui/panels.gd | 0.052 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.038 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.031 |
| res://addons/xr_editor/xr/hand.gd | 0.031 |
| res://addons/xr_editor/xr/rig.gd | 0.024 |
| res://addons/xr_editor/tools/icons.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.016 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.011 |
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

### 04 open

Thread 1: frames 839, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.243 | 1.0 |
| process | 1.801 | 1.0 |
| AudioServer::update | 0.011 | 1.0 |
| physics | 0.008 | 1.0 |
| Physics Step | 0.007 | 0.4 |
| physics_process | 0.002 | 0.4 |
| 2D physics | 0.002 | 0.4 |
| PhysicsServer3D::sync | 0.001 | 0.4 |
| PhysicsServer2D::sync | 0.001 | 0.4 |
| prepare | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
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
| engine C++ (servers/) | 4.243 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.575 |
| engine C++ (main/) | 0.241 |
| GDScript: other scripts, with engine calls made from them | 0.011 |
| engine C++ (platform/) | 0.007 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.238 | 3.238 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.541 | 0.541 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.301 | 0.301 | 2.0 |
| process | main/main.cpp:5061 | 0.218 | 1.801 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.127 | 0.136 | 41.2 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.121 | 0.325 | 18.0 |
| _intersect_tubes | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4011 | 0.117 | 0.239 | 12.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.084 | 0.084 | 1.0 |
| _box_distance | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4070 | 0.070 | 0.070 | 140.3 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:3604 | 0.064 | 0.395 | 4.0 |
| _intersect_knots | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4033 | 0.047 | 0.047 | 12.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.047 | 3.597 | 1.0 |
| _ray_segment | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4052 | 0.040 | 0.040 | 78.2 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.039 | 0.039 | 1249.5 |
| intersect_link_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5487 | 0.032 | 0.052 | 4.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.023 | 0.322 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.021 | 0.021 | 2.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.020 | 0.020 | 2.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.019 | 0.090 | 1.0 |
| intersect_ray | res://addons/xr_editor/logic_graph/blueprint_boxes.gd:666 | 0.018 | 0.036 | 4.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.017 | 0.345 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.017 | 0.022 | 15.5 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.867 | 1.0 |
| intersect_wire | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:5514 | 0.016 | 0.023 | 24.1 |
| _cast | res://addons/xr_editor/ui/panel_surface.gd:626 | 0.016 | 0.016 | 24.1 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.844 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.220 |
| res://addons/xr_editor/xr/simulator.gd | 0.072 |
| res://addons/xr_editor/tools/manipulator.gd | 0.069 |
| res://addons/xr_editor/core/feature_settings.gd | 0.056 |
| res://addons/xr_editor/ui/panels.gd | 0.046 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.043 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.040 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.027 |
| res://addons/xr_editor/xr/rig.gd | 0.022 |
| res://addons/xr_editor/tools/icons.gd | 0.021 |
| res://addons/xr_editor/xr/session.gd | 0.013 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/blueprints/document.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.008 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.003 |

### 05 closed

Thread 1: frames 837, mean Main::iteration 6.06 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.353 | 1.0 |
| process | 0.688 | 1.0 |
| AudioServer::update | 0.011 | 1.0 |
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
| RenderingServer::sync | 0.000 | 1.0 |
| xr_server->_process | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.4 |
| NavigationServer2D::physics_process | 0.000 | 0.4 |
| main loop iteration prepare | 0.000 | 0.4 |
| main loop iteration end | 0.000 | 0.4 |
| setup | 0.000 | 0.4 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.352 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.495 |
| engine C++ (main/) | 0.216 |
| engine C++ (platform/) | 0.006 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.894 | 4.894 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.199 | 0.199 | 14.7 |
| process | main/main.cpp:5061 | 0.193 | 0.688 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.109 | 0.109 | 2.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.080 | 0.080 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.043 | 5.056 | 1.0 |
| cast_segment | res://addons/xr_editor/tools/manipulator.gd:484 | 0.020 | 0.020 | 2.0 |
| find_at_point | res://addons/xr_editor/tools/manipulator.gd:475 | 0.016 | 0.016 | 2.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.015 | 0.113 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.015 | 0.037 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:547 | 0.014 | 0.014 | 0.0 |
| AudioServer::update | main/main.cpp:5111 | 0.011 | 0.011 | 1.0 |
| update | res://addons/xr_editor/xr/simulator.gd:427 | 0.010 | 0.010 | 1.0 |
| _update_poses | res://addons/xr_editor/xr/simulator.gd:335 | 0.010 | 0.020 | 1.0 |
| _update_hover | res://addons/xr_editor/tools/manipulator.gd:465 | 0.010 | 0.064 | 2.0 |
| _update_inputs | res://addons/xr_editor/xr/simulator.gd:357 | 0.008 | 0.026 | 1.0 |
| _update_pointer | res://addons/xr_editor/ui/panels.gd:824 | 0.008 | 0.031 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:472 | 0.007 | 0.010 | 1.0 |
| _takes_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:3290 | 0.007 | 0.008 | 2.0 |
| button_input | res://addons/xr_editor/core/feature_settings.gd:1089 | 0.007 | 0.007 | 12.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.007 | 0.012 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1072 | 0.006 | 0.012 | 12.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.006 | 0.006 | 2.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.006 | 6.068 | 1.0 |
| button_hand | res://addons/xr_editor/core/feature_settings.gd:1084 | 0.006 | 0.006 | 14.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.090 |
| res://addons/xr_editor/xr/simulator.gd | 0.066 |
| res://addons/xr_editor/tools/manipulator.gd | 0.065 |
| res://addons/xr_editor/core/feature_settings.gd | 0.051 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.041 |
| res://addons/xr_editor/xr/hand.gd | 0.023 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.022 |
| res://addons/xr_editor/xr/rig.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.020 |
| res://addons/xr_editor/tools/icons.gd | 0.019 |
| res://addons/xr_editor/xr/session.gd | 0.012 |
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
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.001 |
| res://addons/xr_editor/xr/standalone.gd | 0.001 |
