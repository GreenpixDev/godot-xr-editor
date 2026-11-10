
### 01 closed

Thread 1: frames 609, mean Main::iteration 8.42 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 5.249 | 1.0 |
| RenderingServer::draw | 2.219 | 1.0 |
| process | 0.903 | 1.0 |
| AudioServer::update | 0.025 | 1.0 |
| physics | 0.019 | 1.0 |
| Physics Step | 0.018 | 0.5 |
| physics_process | 0.013 | 0.5 |
| PhysicsServer3D::sync | 0.002 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.001 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 5.008 |
| engine C++ (servers/) | 2.218 |
| engine C++ (main/) | 0.686 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.510 |
| engine C++ (platform/) | 0.029 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 4.941 | 4.941 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.519 | 1.519 | 2.0 |
| process | main/main.cpp:5061 | 0.394 | 0.903 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.242 | 5.249 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.218 | 0.220 | 14.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.148 | 0.148 | 2.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.136 | 0.136 | 1.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.061 | 0.061 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.059 | 0.059 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.043 | 1.732 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.034 | 0.034 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.032 | 0.032 | 0.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.029 | 8.449 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.025 | 0.025 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.019 | 0.140 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.015 | 0.015 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.013 | 0.013 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.012 | 0.047 | 2.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.011 | 0.011 | 1.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.010 | 0.039 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.010 | 0.015 | 1.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.010 | 0.010 | 2.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.009 | 0.041 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1056 | 0.009 | 0.016 | 14.0 |
| update_input | res://addons/xr_editor/xr/hand.gd:92 | 0.008 | 0.016 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.099 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.070 |
| res://addons/xr_editor/core/feature_settings.gd | 0.065 |
| res://addons/xr_editor/xr/hand.gd | 0.032 |
| res://addons/xr_editor/xr/rig.gd | 0.032 |
| res://addons/xr_editor/xr/session.gd | 0.028 |
| res://addons/xr_editor/tools/manipulator.gd | 0.027 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.026 |
| res://addons/xr_editor/ui/panels.gd | 0.023 |
| res://addons/xr_editor/tools/locomotion.gd | 0.017 |
| res://addons/xr_editor/tools/icons.gd | 0.015 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.010 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.003 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.003 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |

### 02 open

Thread 1: frames 608, mean Main::iteration 8.38 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 3.911 | 1.0 |
| RenderingServer::draw | 3.083 | 1.0 |
| process | 1.366 | 1.0 |
| physics | 0.016 | 1.0 |
| Physics Step | 0.016 | 0.5 |
| AudioServer::update | 0.014 | 1.0 |
| physics_process | 0.011 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| 2D physics | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 3.698 |
| engine C++ (servers/) | 3.081 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.008 |
| engine C++ (main/) | 0.598 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 3.648 | 3.648 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.782 | 1.782 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.578 | 0.579 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.407 | 0.407 | 2.0 |
| process | main/main.cpp:5061 | 0.348 | 1.366 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.214 | 3.911 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.135 | 0.355 | 18.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.134 | 0.144 | 41.1 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.126 | 0.126 | 1.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.050 | 0.050 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.045 | 0.045 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.043 | 0.043 | 1250.2 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.041 | 2.256 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.031 | 0.031 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.025 | 0.382 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.023 | 0.111 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.021 | 0.684 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.019 | 0.019 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.019 | 0.024 | 15.5 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.014 | 0.014 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.013 | 0.013 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.011 | 0.011 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.010 | 0.041 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.475 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.165 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.068 |
| res://addons/xr_editor/core/feature_settings.gd | 0.059 |
| res://addons/xr_editor/xr/hand.gd | 0.032 |
| res://addons/xr_editor/xr/rig.gd | 0.029 |
| res://addons/xr_editor/ui/panels.gd | 0.028 |
| res://addons/xr_editor/tools/manipulator.gd | 0.024 |
| res://addons/xr_editor/xr/session.gd | 0.023 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/xr_editor/tools/icons.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |

### 03 open_graph100

Thread 1: frames 584, mean Main::iteration 8.73 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.357 | 1.0 |
| process | 2.431 | 1.0 |
| xr_server->_process | 0.905 | 1.0 |
| physics | 0.018 | 1.0 |
| Physics Step | 0.017 | 0.5 |
| AudioServer::update | 0.016 | 1.0 |
| physics_process | 0.012 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.001 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.362 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.064 |
| engine C++ (modules/) | 0.683 |
| engine C++ (main/) | 0.617 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.644 | 2.644 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.447 | 1.449 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.933 | 0.933 | 2.0 |
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 0.632 | 0.632 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.581 | 0.618 | 200.7 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.459 | 1.339 | 61.5 |
| process | main/main.cpp:5061 | 0.354 | 2.431 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.223 | 0.905 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.148 | 0.148 | 4758.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.128 | 0.128 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.075 | 1.422 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.062 | 0.080 | 59.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.052 | 3.656 | 1.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.046 | 0.046 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.046 | 0.046 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.034 | 0.034 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.032 | 0.032 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.032 | 0.032 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.022 | 0.111 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.021 | 1.729 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4458 | 0.018 | 0.461 | 157.7 |
| AudioServer::update | main/main.cpp:5111 | 0.016 | 0.016 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.014 | 0.014 | 2.0 |
| set_instance_transform | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4497 | 0.013 | 0.013 | 200.7 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2957 | 0.013 | 0.013 | 61.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 1.515 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.168 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.073 |
| res://addons/xr_editor/core/feature_settings.gd | 0.059 |
| res://addons/xr_editor/xr/hand.gd | 0.032 |
| res://addons/xr_editor/ui/panels.gd | 0.029 |
| res://addons/xr_editor/xr/rig.gd | 0.029 |
| res://addons/xr_editor/xr/session.gd | 0.025 |
| res://addons/xr_editor/tools/manipulator.gd | 0.024 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/xr_editor/tools/icons.gd | 0.014 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.003 |

### 04 open_graph250

Thread 1: frames 289, mean Main::iteration 17.62 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 8.752 | 1.0 |
| process | 4.709 | 1.0 |
| xr_server->_process | 4.094 | 1.0 |
| physics | 0.038 | 1.0 |
| Physics Step | 0.038 | 1.1 |
| physics_process | 0.028 | 1.1 |
| AudioServer::update | 0.023 | 1.0 |
| PhysicsServer3D::sync | 0.003 | 1.1 |
| PhysicsServer2D::sync | 0.002 | 1.1 |
| OS::add_frame_delay | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 1.1 |
| NavigationServer3D::physics_process | 0.001 | 1.1 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| 2D physics | 0.001 | 1.1 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.1 |
| setup | 0.000 | 1.1 |
| main loop iteration prepare | 0.000 | 1.1 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration end | 0.000 | 1.1 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 8.761 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 4.305 |
| engine C++ (modules/) | 3.828 |
| engine C++ (main/) | 0.728 |
| GDScript: other scripts, with engine calls made from them | 0.014 |
| engine C++ (platform/) | 0.011 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 3.759 | 3.759 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 3.611 | 3.613 | 16.9 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.641 | 2.641 | 2.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 2.063 | 2.063 | 2.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 1.438 | 1.531 | 513.8 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 1.138 | 3.317 | 149.0 |
| process | main/main.cpp:5061 | 0.390 | 4.709 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.370 | 0.370 | 11818.8 |
| xr_server->_process | main/main.cpp:4965 | 0.267 | 4.094 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.180 | 3.516 | 0.5 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.153 | 0.153 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.151 | 0.193 | 146.5 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.096 | 4.828 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.077 | 0.077 | 0.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.061 | 0.061 | 1.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.057 | 0.057 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4458 | 0.049 | 1.276 | 438.9 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.041 | 0.041 | 1.0 |
| set_instance_transform | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4497 | 0.032 | 0.032 | 513.8 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.031 | 0.031 | 1.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2957 | 0.030 | 0.030 | 148.5 |
| physics_process | main/main.cpp:5000 | 0.028 | 0.028 | 1.1 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.025 | 3.868 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.024 | 0.127 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4481 | 0.024 | 0.024 | 513.8 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 3.622 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.193 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.128 |
| res://addons/xr_editor/core/feature_settings.gd | 0.068 |
| res://addons/xr_editor/xr/hand.gd | 0.037 |
| res://addons/xr_editor/xr/rig.gd | 0.034 |
| res://addons/xr_editor/ui/panels.gd | 0.034 |
| res://addons/xr_editor/xr/session.gd | 0.032 |
| res://addons/xr_editor/tools/manipulator.gd | 0.027 |
| res://addons/xr_editor/tools/locomotion.gd | 0.019 |
| res://addons/xr_editor/tools/icons.gd | 0.016 |
| res://addons/blueprints/document.gd | 0.014 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.010 |
| res://addons/xr_editor/ui/palette.gd | 0.008 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.004 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.003 |

### 05 open_graph500

Thread 1: frames 207, mean Main::iteration 24.56 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 14.538 | 1.0 |
| process | 6.780 | 1.0 |
| xr_server->_process | 3.170 | 1.0 |
| physics | 0.045 | 1.0 |
| Physics Step | 0.045 | 1.5 |
| physics_process | 0.032 | 1.5 |
| AudioServer::update | 0.026 | 1.0 |
| PhysicsServer3D::sync | 0.003 | 1.5 |
| PhysicsServer2D::sync | 0.003 | 1.5 |
| NavigationServer2D::physics_process | 0.002 | 1.5 |
| NavigationServer3D::physics_process | 0.001 | 1.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| 2D physics | 0.001 | 1.5 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.5 |
| main loop iteration prepare | 0.001 | 1.5 |
| setup | 0.001 | 1.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration end | 0.000 | 1.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 14.565 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 6.359 |
| engine C++ (modules/) | 2.901 |
| engine C++ (main/) | 0.756 |
| GDScript: other scripts, with engine calls made from them | 0.015 |
| engine C++ (platform/) | 0.012 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 7.158 | 7.160 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 4.114 | 4.114 | 2.0 |
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.830 | 2.830 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.768 | 2.768 | 2.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 2.232 | 5.089 | 294.9 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 1.492 | 1.588 | 514.5 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.764 | 0.764 | 23591.4 |
| process | main/main.cpp:5061 | 0.406 | 6.780 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.358 | 5.485 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.306 | 0.392 | 292.4 |
| xr_server->_process | main/main.cpp:4965 | 0.270 | 3.170 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.162 | 0.162 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.125 | 7.059 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.115 | 0.115 | 0.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.078 | 0.078 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.062 | 0.062 | 1.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2957 | 0.059 | 0.059 | 294.4 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4458 | 0.053 | 1.334 | 442.4 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.045 | 0.045 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4428 | 0.036 | 5.000 | 281.4 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4441 | 0.034 | 0.426 | 292.4 |
| set_instance_transform | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4497 | 0.033 | 0.033 | 514.5 |
| physics_process | main/main.cpp:5000 | 0.032 | 0.032 | 1.5 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.030 | 0.030 | 1.0 |
| driver->command_buffer_end | servers/rendering/rendering_device.cpp:8124 | 0.030 | 0.030 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 5.596 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.207 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.180 |
| res://addons/xr_editor/core/feature_settings.gd | 0.070 |
| res://addons/xr_editor/xr/hand.gd | 0.039 |
| res://addons/xr_editor/xr/rig.gd | 0.036 |
| res://addons/xr_editor/ui/panels.gd | 0.035 |
| res://addons/xr_editor/xr/session.gd | 0.034 |
| res://addons/xr_editor/tools/manipulator.gd | 0.027 |
| res://addons/xr_editor/tools/locomotion.gd | 0.018 |
| res://addons/xr_editor/tools/icons.gd | 0.016 |
| res://addons/blueprints/document.gd | 0.015 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/ui/palette.gd | 0.008 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.008 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.004 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.004 |

### 06 open

Thread 1: frames 605, mean Main::iteration 8.40 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.476 | 1.0 |
| xr_server->_process | 3.257 | 1.0 |
| process | 1.626 | 1.0 |
| AudioServer::update | 0.021 | 1.0 |
| physics | 0.020 | 1.0 |
| Physics Step | 0.020 | 0.5 |
| physics_process | 0.014 | 0.5 |
| PhysicsServer3D::sync | 0.002 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| 2D physics | 0.001 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.472 |
| engine C++ (modules/) | 3.008 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.196 |
| engine C++ (main/) | 0.715 |
| GDScript: other scripts, with engine calls made from them | 0.015 |
| engine C++ (platform/) | 0.011 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.942 | 2.942 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.889 | 1.889 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.769 | 0.771 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.444 | 0.444 | 2.0 |
| process | main/main.cpp:5061 | 0.415 | 1.626 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.251 | 3.257 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.149 | 0.396 | 18.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.149 | 0.160 | 41.3 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.146 | 0.146 | 1.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.060 | 0.060 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.058 | 0.058 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.050 | 2.412 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.048 | 0.048 | 1250.1 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.040 | 0.040 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.034 | 0.034 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.030 | 0.429 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.027 | 0.135 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.026 | 0.802 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.026 | 0.026 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.022 | 0.028 | 15.5 |
| AudioServer::update | main/main.cpp:5111 | 0.021 | 0.021 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.016 | 0.016 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.014 | 0.014 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.013 | 0.051 | 2.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.012 | 0.041 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.541 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.203 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.085 |
| res://addons/xr_editor/core/feature_settings.gd | 0.070 |
| res://addons/xr_editor/xr/hand.gd | 0.038 |
| res://addons/xr_editor/xr/rig.gd | 0.035 |
| res://addons/xr_editor/ui/panels.gd | 0.034 |
| res://addons/xr_editor/xr/session.gd | 0.030 |
| res://addons/xr_editor/tools/manipulator.gd | 0.028 |
| res://addons/xr_editor/tools/locomotion.gd | 0.017 |
| res://addons/xr_editor/tools/icons.gd | 0.016 |
| res://addons/blueprints/document.gd | 0.015 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.010 |
| res://addons/xr_editor/ui/palette.gd | 0.008 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.007 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.007 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.004 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.003 |

### 07 closed

Thread 1: frames 611, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 5.348 | 1.0 |
| RenderingServer::draw | 2.090 | 1.0 |
| process | 0.921 | 1.0 |
| AudioServer::update | 0.016 | 1.0 |
| physics | 0.016 | 1.0 |
| Physics Step | 0.015 | 0.5 |
| physics_process | 0.011 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 5.152 |
| engine C++ (servers/) | 2.087 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.585 |
| engine C++ (main/) | 0.572 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 5.098 | 5.098 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.471 | 1.471 | 2.0 |
| process | main/main.cpp:5061 | 0.336 | 0.921 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.198 | 0.199 | 14.7 |
| xr_server->_process | main/main.cpp:4965 | 0.198 | 5.348 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.126 | 0.126 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.118 | 0.118 | 2.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:426 | 0.061 | 0.061 | 3.4 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.051 | 0.051 | 1.0 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:427 | 0.049 | 0.049 | 3.4 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.048 | 0.048 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.039 | 1.650 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.035 | 0.035 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.029 | 0.029 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.019 | 0.136 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.016 | 0.016 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.014 | 0.014 | 2.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.011 | 0.011 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.041 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.011 | 0.011 | 0.5 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:414 | 0.010 | 0.123 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.009 | 0.013 | 1.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.009 | 0.033 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.009 | 8.398 | 1.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.008 | 0.008 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.183 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.096 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/tools/manipulator.gd | 0.027 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.027 |
| res://addons/xr_editor/xr/session.gd | 0.024 |
| res://addons/xr_editor/ui/panels.gd | 0.020 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/xr_editor/tools/icons.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |

### 08 closed_scene1k

Thread 1: frames 608, mean Main::iteration 8.38 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 4.505 | 1.0 |
| RenderingServer::draw | 3.021 | 1.0 |
| process | 0.827 | 1.0 |
| physics | 0.016 | 1.0 |
| AudioServer::update | 0.016 | 1.0 |
| Physics Step | 0.016 | 0.5 |
| physics_process | 0.011 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 4.293 |
| engine C++ (servers/) | 3.018 |
| engine C++ (main/) | 0.603 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.477 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 4.237 | 4.237 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.966 | 1.966 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.617 | 0.618 | 14.8 |
| process | main/main.cpp:5061 | 0.350 | 0.827 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.214 | 4.505 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.128 | 0.128 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.122 | 0.122 | 2.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.052 | 0.052 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.049 | 0.049 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.040 | 2.151 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.031 | 0.031 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.019 | 0.139 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.018 | 0.018 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.016 | 0.016 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.014 | 0.014 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.011 | 0.011 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.042 | 2.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.010 | 0.034 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.009 | 0.013 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.009 | 8.394 | 1.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.009 | 0.009 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:414 | 0.008 | 0.012 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.008 | 0.035 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1056 | 0.008 | 0.014 | 14.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.098 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.070 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/xr/hand.gd | 0.029 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.027 |
| res://addons/xr_editor/tools/manipulator.gd | 0.025 |
| res://addons/xr_editor/xr/session.gd | 0.025 |
| res://addons/xr_editor/ui/panels.gd | 0.021 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/xr_editor/tools/icons.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |

### 09 closed_scene5k

Thread 1: frames 608, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.785 | 1.0 |
| xr_server->_process | 2.735 | 1.0 |
| process | 0.842 | 1.0 |
| physics | 0.016 | 1.0 |
| Physics Step | 0.016 | 0.5 |
| AudioServer::update | 0.016 | 1.0 |
| physics_process | 0.011 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.782 |
| engine C++ (modules/) | 2.527 |
| engine C++ (main/) | 0.595 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.495 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.476 | 2.476 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.466 | 2.466 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.884 | 1.885 | 14.7 |
| process | main/main.cpp:5061 | 0.347 | 0.842 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.209 | 2.735 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.131 | 0.131 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.120 | 0.120 | 2.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.046 | 0.046 | 1.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.045 | 0.045 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.040 | 2.649 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.034 | 0.034 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.031 | 0.031 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.021 | 0.021 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.021 | 0.145 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.016 | 0.016 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.015 | 0.015 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.012 | 0.043 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.011 | 0.011 | 0.5 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.010 | 0.035 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.009 | 0.014 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.009 | 8.395 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:414 | 0.009 | 0.012 | 1.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.009 | 0.009 | 2.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.008 | 0.035 | 1.0 |
| update_input | res://addons/xr_editor/xr/hand.gd:92 | 0.008 | 0.015 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.102 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.075 |
| res://addons/xr_editor/core/feature_settings.gd | 0.059 |
| res://addons/xr_editor/xr/hand.gd | 0.030 |
| res://addons/xr_editor/xr/rig.gd | 0.029 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.029 |
| res://addons/xr_editor/tools/manipulator.gd | 0.026 |
| res://addons/xr_editor/xr/session.gd | 0.025 |
| res://addons/xr_editor/ui/panels.gd | 0.021 |
| res://addons/xr_editor/tools/locomotion.gd | 0.015 |
| res://addons/xr_editor/tools/icons.gd | 0.014 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.003 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.002 |

### 10 closed_scene20k

Thread 1: frames 304, mean Main::iteration 16.76 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 10.992 | 1.0 |
| xr_server->_process | 4.760 | 1.0 |
| process | 0.952 | 1.0 |
| physics | 0.039 | 1.0 |
| Physics Step | 0.039 | 1.0 |
| physics_process | 0.028 | 1.0 |
| AudioServer::update | 0.025 | 1.0 |
| PhysicsServer3D::sync | 0.003 | 1.0 |
| PhysicsServer2D::sync | 0.002 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| 2D physics | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| main loop iteration prepare | 0.001 | 1.0 |
| setup | 0.001 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration end | 0.000 | 1.0 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 11.004 |
| engine C++ (modules/) | 4.502 |
| engine C++ (main/) | 0.703 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.583 |
| engine C++ (platform/) | 0.011 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 6.109 | 6.110 | 14.7 |
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 4.435 | 4.435 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.391 | 4.391 | 2.0 |
| process | main/main.cpp:5061 | 0.371 | 0.952 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.259 | 4.760 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.140 | 0.140 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.138 | 0.138 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.063 | 0.063 | 0.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.059 | 0.059 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.056 | 4.613 | 1.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.047 | 0.047 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.038 | 0.038 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.031 | 0.031 | 1.0 |
| physics_process | main/main.cpp:5000 | 0.028 | 0.028 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.025 | 0.025 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.021 | 0.157 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.017 | 0.017 | 2.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.013 | 0.044 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.013 | 0.048 | 2.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.011 | 0.016 | 1.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.011 | 0.011 | 2.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.011 | 16.770 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.010 | 0.045 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:414 | 0.010 | 0.014 | 1.0 |
| driver->command_buffer_end | servers/rendering/rendering_device.cpp:8124 | 0.009 | 0.009 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.113 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.111 |
| res://addons/xr_editor/core/feature_settings.gd | 0.065 |
| res://addons/xr_editor/xr/rig.gd | 0.033 |
| res://addons/xr_editor/xr/hand.gd | 0.032 |
| res://addons/xr_editor/xr/session.gd | 0.032 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.031 |
| res://addons/xr_editor/tools/manipulator.gd | 0.028 |
| res://addons/xr_editor/ui/panels.gd | 0.024 |
| res://addons/xr_editor/tools/locomotion.gd | 0.018 |
| res://addons/xr_editor/tools/icons.gd | 0.016 |
| res://addons/xr_editor/tools/outline.gd | 0.012 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.011 |
| res://addons/xr_editor/ui/palette.gd | 0.008 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.003 |
| res://addons/xr_editor/xr/standalone.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |

### 11 closed

Thread 1: frames 609, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 5.529 | 1.0 |
| RenderingServer::draw | 2.054 | 1.0 |
| process | 0.784 | 1.0 |
| physics | 0.015 | 1.0 |
| Physics Step | 0.015 | 0.5 |
| AudioServer::update | 0.014 | 1.0 |
| physics_process | 0.011 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 5.327 |
| engine C++ (servers/) | 2.052 |
| engine C++ (main/) | 0.566 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.457 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 5.274 | 5.274 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.447 | 1.447 | 2.0 |
| process | main/main.cpp:5061 | 0.327 | 0.784 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.203 | 5.529 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.191 | 0.192 | 14.7 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.123 | 0.123 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.114 | 0.114 | 2.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.056 | 0.056 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.047 | 0.047 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.038 | 1.620 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.030 | 0.030 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.018 | 0.134 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.014 | 0.014 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.040 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.011 | 0.011 | 0.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.010 | 0.010 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.009 | 0.012 | 1.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.009 | 0.032 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.009 | 8.394 | 1.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.008 | 0.008 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:414 | 0.008 | 0.011 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1056 | 0.008 | 0.015 | 14.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.008 | 0.033 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.093 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.068 |
| res://addons/xr_editor/core/feature_settings.gd | 0.057 |
| res://addons/xr_editor/xr/hand.gd | 0.027 |
| res://addons/xr_editor/xr/rig.gd | 0.027 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.026 |
| res://addons/xr_editor/tools/manipulator.gd | 0.024 |
| res://addons/xr_editor/xr/session.gd | 0.023 |
| res://addons/xr_editor/ui/panels.gd | 0.020 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |

### 12 open_scene5k

Thread 1: frames 572, mean Main::iteration 8.95 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 6.258 | 1.0 |
| process | 1.390 | 1.0 |
| xr_server->_process | 1.264 | 1.0 |
| physics | 0.018 | 1.0 |
| Physics Step | 0.018 | 0.5 |
| AudioServer::update | 0.018 | 1.0 |
| physics_process | 0.013 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| 2D physics | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 6.260 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.024 |
| engine C++ (modules/) | 0.968 |
| engine C++ (main/) | 0.695 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.010 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 3.298 | 3.298 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 2.231 | 2.232 | 16.9 |
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 0.916 | 0.916 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.394 | 0.394 | 2.0 |
| process | main/main.cpp:5061 | 0.354 | 1.390 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.297 | 1.264 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.137 | 0.137 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.131 | 0.343 | 18.1 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.129 | 0.139 | 41.2 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.047 | 0.047 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.046 | 3.762 | 1.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.045 | 0.045 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.041 | 0.041 | 1252.4 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.037 | 0.037 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.032 | 0.032 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.029 | 0.029 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.024 | 0.370 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.023 | 0.114 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.021 | 0.681 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.018 | 0.024 | 15.6 |
| AudioServer::update | main/main.cpp:5111 | 0.018 | 0.018 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.015 | 0.015 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.013 | 0.013 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.042 | 2.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.010 | 0.036 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.465 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.170 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.076 |
| res://addons/xr_editor/core/feature_settings.gd | 0.060 |
| res://addons/xr_editor/xr/hand.gd | 0.033 |
| res://addons/xr_editor/ui/panels.gd | 0.030 |
| res://addons/xr_editor/xr/rig.gd | 0.029 |
| res://addons/xr_editor/xr/session.gd | 0.026 |
| res://addons/xr_editor/tools/manipulator.gd | 0.024 |
| res://addons/xr_editor/tools/locomotion.gd | 0.015 |
| res://addons/xr_editor/tools/icons.gd | 0.014 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.003 |

### 13 open

Thread 1: frames 605, mean Main::iteration 8.45 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 3.766 | 1.0 |
| RenderingServer::draw | 3.253 | 1.0 |
| process | 1.412 | 1.0 |
| AudioServer::update | 0.018 | 1.0 |
| physics | 0.017 | 1.0 |
| Physics Step | 0.017 | 0.5 |
| physics_process | 0.012 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| 2D physics | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 3.480 |
| engine C++ (servers/) | 3.251 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.042 |
| engine C++ (main/) | 0.686 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 3.427 | 3.427 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.894 | 1.894 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.642 | 0.643 | 17.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.387 | 0.387 | 2.0 |
| process | main/main.cpp:5061 | 0.357 | 1.412 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.287 | 3.766 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.136 | 0.359 | 18.1 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.136 | 0.145 | 41.2 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.133 | 0.133 | 1.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.050 | 0.050 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.048 | 0.048 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.045 | 2.349 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.043 | 0.043 | 1254.2 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.033 | 0.033 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.032 | 0.032 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.025 | 0.387 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.023 | 0.117 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.022 | 0.022 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.022 | 0.705 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.019 | 0.025 | 15.6 |
| AudioServer::update | main/main.cpp:5111 | 0.018 | 0.018 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.015 | 0.015 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.012 | 0.012 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.043 | 2.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.009 | 0.035 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.484 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.173 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.071 |
| res://addons/xr_editor/core/feature_settings.gd | 0.061 |
| res://addons/xr_editor/xr/hand.gd | 0.033 |
| res://addons/xr_editor/xr/rig.gd | 0.030 |
| res://addons/xr_editor/ui/panels.gd | 0.030 |
| res://addons/xr_editor/xr/session.gd | 0.025 |
| res://addons/xr_editor/tools/manipulator.gd | 0.024 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/xr_editor/tools/icons.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |

### 14 closed

Thread 1: frames 605, mean Main::iteration 8.43 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 5.479 | 1.0 |
| RenderingServer::draw | 2.049 | 1.0 |
| process | 0.876 | 1.0 |
| physics | 0.015 | 1.0 |
| Physics Step | 0.015 | 0.5 |
| AudioServer::update | 0.013 | 1.0 |
| physics_process | 0.010 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| 2D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 5.244 |
| engine C++ (servers/) | 2.049 |
| engine C++ (main/) | 0.595 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 0.552 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 5.191 | 5.191 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.456 | 1.456 | 2.0 |
| process | main/main.cpp:5061 | 0.325 | 0.876 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.236 | 5.479 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.187 | 0.188 | 14.7 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.121 | 0.121 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.114 | 0.114 | 2.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:426 | 0.053 | 0.053 | 3.4 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.051 | 0.051 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.046 | 0.046 | 1.0 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:427 | 0.042 | 0.042 | 3.4 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.038 | 1.629 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:487 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.030 | 0.030 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.018 | 0.131 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.014 | 0.014 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.013 | 0.013 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.011 | 0.011 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.040 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.010 | 0.010 | 0.5 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:414 | 0.010 | 0.107 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.009 | 8.437 | 1.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.009 | 0.031 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.009 | 0.012 | 1.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.008 | 0.008 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 0.165 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.092 |
| res://addons/xr_editor/core/feature_settings.gd | 0.057 |
| res://addons/xr_editor/xr/rig.gd | 0.027 |
| res://addons/xr_editor/xr/hand.gd | 0.027 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.026 |
| res://addons/xr_editor/tools/manipulator.gd | 0.026 |
| res://addons/xr_editor/xr/session.gd | 0.022 |
| res://addons/xr_editor/ui/panels.gd | 0.019 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
