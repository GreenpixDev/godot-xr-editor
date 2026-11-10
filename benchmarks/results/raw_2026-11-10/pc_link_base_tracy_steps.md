
### 01 closed

Thread 1: frames 608, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 4.417 | 1.0 |
| RenderingServer::draw | 1.987 | 1.0 |
| process | 1.951 | 1.0 |
| AudioServer::update | 0.015 | 1.0 |
| physics | 0.015 | 1.0 |
| Physics Step | 0.014 | 0.5 |
| physics_process | 0.010 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.5 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| 2D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 4.225 |
| engine C++ (servers/) | 1.984 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.624 |
| engine C++ (main/) | 0.555 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 4.177 | 4.177 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.405 | 1.405 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.076 | 1.198 | 1.0 |
| process | main/main.cpp:5061 | 0.327 | 1.951 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.193 | 4.417 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.178 | 0.180 | 14.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.121 | 0.121 | 2.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.114 | 0.114 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1930.0 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.058 | 0.058 | 1930.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.049 | 0.049 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.043 | 0.043 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.036 | 1.586 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.029 | 0.029 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.118 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.015 | 0.015 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.013 | 0.013 | 2.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.012 | 0.012 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.040 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.010 | 0.010 | 0.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.008 | 0.008 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.008 | 0.012 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 8.393 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.008 | 0.057 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.253 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.083 |
| res://addons/xr_editor/core/feature_settings.gd | 0.056 |
| res://addons/xr_editor/tools/manipulator.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.027 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.020 |
| res://addons/xr_editor/ui/panels.gd | 0.019 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |

### 02 closed_vr_off

Thread 1: frames 609, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 4.375 | 1.0 |
| RenderingServer::draw | 1.994 | 1.0 |
| process | 1.984 | 1.0 |
| physics | 0.015 | 1.0 |
| Physics Step | 0.015 | 0.5 |
| AudioServer::update | 0.014 | 1.0 |
| physics_process | 0.010 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| 2D physics | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 4.175 |
| engine C++ (servers/) | 1.991 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.646 |
| engine C++ (main/) | 0.575 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 4.123 | 4.123 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.383 | 1.383 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.082 | 1.205 | 1.0 |
| process | main/main.cpp:5061 | 0.338 | 1.984 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.201 | 4.375 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.189 | 0.190 | 14.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.123 | 0.123 | 2.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.122 | 0.122 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1930.0 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.058 | 0.058 | 1930.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.051 | 0.051 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.046 | 0.046 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.036 | 1.567 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.032 | 0.032 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.032 | 0.032 | 0.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.123 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.014 | 0.014 | 2.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.013 | 0.013 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.042 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.010 | 0.010 | 0.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.009 | 0.009 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.009 | 0.013 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.009 | 8.395 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.008 | 0.058 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.261 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.086 |
| res://addons/xr_editor/core/feature_settings.gd | 0.057 |
| res://addons/xr_editor/xr/hand.gd | 0.029 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/tools/manipulator.gd | 0.028 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.019 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/logic_graph/token_editor.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |

### 03 closed_views_off

Thread 1: frames 610, mean Main::iteration 8.40 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 4.477 | 1.0 |
| RenderingServer::draw | 1.957 | 1.0 |
| process | 1.939 | 1.0 |
| physics | 0.014 | 1.0 |
| Physics Step | 0.014 | 0.5 |
| AudioServer::update | 0.013 | 1.0 |
| physics_process | 0.010 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.5 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| 2D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 4.284 |
| engine C++ (servers/) | 1.955 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.616 |
| engine C++ (main/) | 0.550 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 4.235 | 4.235 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.374 | 1.374 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.068 | 1.191 | 1.0 |
| process | main/main.cpp:5061 | 0.322 | 1.939 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.194 | 4.477 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.180 | 0.181 | 14.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.121 | 0.121 | 2.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.111 | 0.111 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1933.2 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.058 | 0.058 | 1933.2 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.053 | 0.053 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.043 | 0.043 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.036 | 1.555 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.029 | 0.029 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.118 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.013 | 0.013 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.013 | 0.013 | 2.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.011 | 0.011 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.040 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.010 | 0.010 | 0.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.009 | 0.009 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 8.407 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.008 | 0.012 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.008 | 0.057 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.245 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.082 |
| res://addons/xr_editor/core/feature_settings.gd | 0.056 |
| res://addons/xr_editor/tools/manipulator.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.027 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.020 |
| res://addons/xr_editor/ui/panels.gd | 0.019 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |

### 04 closed_root_off

Thread 1: frames 610, mean Main::iteration 8.38 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 6.005 | 1.0 |
| process | 1.871 | 1.0 |
| RenderingServer::draw | 0.486 | 1.0 |
| physics | 0.014 | 1.0 |
| Physics Step | 0.013 | 0.5 |
| AudioServer::update | 0.012 | 1.0 |
| physics_process | 0.009 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| NavigationServer3D::physics_process | 0.000 | 0.5 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 5.823 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.560 |
| engine C++ (main/) | 0.525 |
| engine C++ (servers/) | 0.483 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 5.777 | 5.777 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.029 | 1.150 | 1.0 |
| process | main/main.cpp:5061 | 0.311 | 1.871 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.183 | 6.005 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.160 | 0.161 | 14.6 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.112 | 0.112 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.096 | 0.096 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.061 | 0.061 | 1935.9 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.057 | 0.057 | 1935.9 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.046 | 0.046 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.041 | 0.041 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.031 | 0.031 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.015 | 0.114 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.010 | 0.039 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.009 | 0.009 | 0.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.008 | 0.008 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 8.384 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.008 | 0.011 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.008 | 0.055 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1056 | 0.007 | 0.014 | 14.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.007 | 0.007 | 1.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.007 | 0.026 | 1.0 |
| update_input | res://addons/xr_editor/xr/hand.gd:92 | 0.007 | 0.012 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.205 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.079 |
| res://addons/xr_editor/core/feature_settings.gd | 0.055 |
| res://addons/xr_editor/tools/manipulator.gd | 0.026 |
| res://addons/xr_editor/xr/rig.gd | 0.026 |
| res://addons/xr_editor/xr/hand.gd | 0.026 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.022 |
| res://addons/xr_editor/xr/session.gd | 0.019 |
| res://addons/xr_editor/ui/panels.gd | 0.018 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/xr_editor/tools/icons.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.007 |
| res://addons/xr_editor/ui/palette.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |

### 05 closed_lean

Thread 1: frames 609, mean Main::iteration 8.37 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 4.725 | 1.0 |
| process | 1.966 | 1.0 |
| RenderingServer::draw | 1.662 | 1.0 |
| physics | 0.015 | 1.0 |
| Physics Step | 0.014 | 0.5 |
| AudioServer::update | 0.013 | 1.0 |
| physics_process | 0.010 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.5 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 4.534 |
| engine C++ (servers/) | 1.659 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.641 |
| engine C++ (main/) | 0.551 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 4.486 | 4.486 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.106 | 1.106 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.088 | 1.211 | 1.0 |
| process | main/main.cpp:5061 | 0.325 | 1.966 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.192 | 4.725 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.171 | 0.172 | 14.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.114 | 0.114 | 2.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.109 | 0.109 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1933.2 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.059 | 0.059 | 1933.2 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.048 | 0.048 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.043 | 0.043 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.035 | 1.274 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.031 | 0.031 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.028 | 0.028 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.120 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.013 | 0.013 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.013 | 0.013 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.041 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.010 | 0.010 | 0.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.009 | 0.009 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.008 | 0.012 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 8.380 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.008 | 0.057 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1056 | 0.008 | 0.014 | 14.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.266 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.084 |
| res://addons/xr_editor/core/feature_settings.gd | 0.057 |
| res://addons/xr_editor/tools/manipulator.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.027 |
| res://addons/xr_editor/xr/rig.gd | 0.027 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.020 |
| res://addons/xr_editor/ui/panels.gd | 0.019 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |

### 06 closed_scene_off

Thread 1: frames 613, mean Main::iteration 8.37 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 4.871 | 1.0 |
| process | 1.963 | 1.0 |
| RenderingServer::draw | 1.510 | 1.0 |
| physics | 0.015 | 1.0 |
| Physics Step | 0.015 | 0.5 |
| AudioServer::update | 0.014 | 1.0 |
| physics_process | 0.010 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.5 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 4.673 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.632 |
| engine C++ (servers/) | 1.507 |
| engine C++ (main/) | 0.565 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 4.624 | 4.624 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.078 | 1.200 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 0.958 | 0.958 | 2.0 |
| process | main/main.cpp:5061 | 0.331 | 1.963 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.199 | 4.871 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.165 | 0.167 | 14.7 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.116 | 0.116 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.104 | 0.104 | 2.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1933.1 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.058 | 0.058 | 1933.1 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.051 | 0.051 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.044 | 0.044 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.036 | 1.119 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.031 | 0.031 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.028 | 0.028 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.119 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.013 | 0.013 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.040 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.010 | 0.010 | 0.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.009 | 0.009 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.009 | 0.013 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 8.380 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.008 | 0.059 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1056 | 0.008 | 0.015 | 14.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.254 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.083 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/tools/manipulator.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.027 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.023 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.019 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |

### 07 closed_empty

Thread 1: frames 608, mean Main::iteration 8.37 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 5.400 | 1.0 |
| process | 2.017 | 1.0 |
| RenderingServer::draw | 0.925 | 1.0 |
| physics | 0.015 | 1.0 |
| Physics Step | 0.015 | 0.5 |
| AudioServer::update | 0.015 | 1.0 |
| physics_process | 0.010 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| ScriptServer::frame | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 5.198 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.678 |
| engine C++ (servers/) | 0.922 |
| engine C++ (main/) | 0.578 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 5.146 | 5.146 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.110 | 1.233 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 0.429 | 0.429 | 2.0 |
| process | main/main.cpp:5061 | 0.339 | 2.017 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.203 | 5.400 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.124 | 0.126 | 14.7 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.116 | 0.116 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.086 | 0.086 | 2.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.063 | 0.063 | 1933.2 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.059 | 0.059 | 1933.2 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.053 | 0.053 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.046 | 0.046 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.036 | 0.572 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.028 | 0.028 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.124 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.015 | 0.015 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.013 | 0.013 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.042 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.010 | 0.010 | 0.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.009 | 0.009 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.009 | 0.013 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.009 | 0.059 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.009 | 8.381 | 1.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.008 | 0.030 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.290 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.087 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/tools/manipulator.gd | 0.029 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.024 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.019 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |

### 08 closed

Thread 1: frames 609, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 4.371 | 1.0 |
| process | 2.006 | 1.0 |
| RenderingServer::draw | 1.993 | 1.0 |
| physics | 0.016 | 1.0 |
| Physics Step | 0.016 | 0.5 |
| AudioServer::update | 0.014 | 1.0 |
| physics_process | 0.011 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 4.166 |
| engine C++ (servers/) | 1.991 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.663 |
| engine C++ (main/) | 0.587 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 4.114 | 4.114 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.395 | 1.395 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.097 | 1.219 | 1.0 |
| process | main/main.cpp:5061 | 0.343 | 2.006 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.207 | 4.371 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.190 | 0.192 | 14.7 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.122 | 0.122 | 2.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.117 | 0.117 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1936.3 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.058 | 0.058 | 1936.3 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.051 | 0.051 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.046 | 0.046 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.036 | 1.574 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.034 | 0.034 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.030 | 0.030 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.016 | 0.123 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.014 | 0.014 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.041 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.011 | 0.011 | 0.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.009 | 0.009 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.009 | 0.013 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.009 | 8.395 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.008 | 0.058 | 1.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.008 | 0.029 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.277 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.086 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/xr/hand.gd | 0.029 |
| res://addons/xr_editor/tools/manipulator.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.024 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.020 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.002 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |

### 09 open

Thread 1: frames 607, mean Main::iteration 8.42 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.187 | 1.0 |
| process | 2.812 | 1.0 |
| xr_server->_process | 2.397 | 1.0 |
| physics | 0.018 | 1.0 |
| Physics Step | 0.017 | 0.5 |
| AudioServer::update | 0.017 | 1.0 |
| physics_process | 0.012 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.188 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.427 |
| engine C++ (modules/) | 2.173 |
| engine C++ (main/) | 0.644 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.010 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.115 | 2.115 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.791 | 1.791 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.242 | 1.369 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.631 | 0.633 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.429 | 0.429 | 2.0 |
| process | main/main.cpp:5061 | 0.376 | 2.812 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.226 | 2.397 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.138 | 0.362 | 18.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.137 | 0.147 | 41.2 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.131 | 0.131 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.064 | 0.064 | 1937.5 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.060 | 0.060 | 1937.5 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.052 | 0.052 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.052 | 0.052 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.051 | 2.301 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.043 | 0.043 | 1250.2 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.033 | 0.033 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.029 | 0.029 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.027 | 0.391 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.024 | 0.118 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.022 | 0.716 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.021 | 0.021 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.019 | 0.025 | 15.5 |
| AudioServer::update | main/main.cpp:5111 | 0.017 | 0.017 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.015 | 0.015 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.428 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.490 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.178 |
| res://addons/xr_editor/core/feature_settings.gd | 0.063 |
| res://addons/xr_editor/xr/hand.gd | 0.035 |
| res://addons/xr_editor/xr/rig.gd | 0.031 |
| res://addons/xr_editor/tools/manipulator.gd | 0.031 |
| res://addons/xr_editor/ui/panels.gd | 0.031 |
| res://addons/xr_editor/xr/session.gd | 0.024 |
| res://addons/xr_editor/tools/locomotion.gd | 0.015 |
| res://addons/xr_editor/tools/icons.gd | 0.014 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.012 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |

### 10 open_dimmer_off

Thread 1: frames 608, mean Main::iteration 8.40 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 3.205 | 1.0 |
| RenderingServer::draw | 2.603 | 1.0 |
| process | 2.569 | 1.0 |
| physics | 0.015 | 1.0 |
| Physics Step | 0.014 | 0.5 |
| AudioServer::update | 0.014 | 1.0 |
| physics_process | 0.010 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 3D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.5 |
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
| engine C++ (modules/) | 3.011 |
| engine C++ (servers/) | 2.599 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.218 |
| engine C++ (main/) | 0.569 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.962 | 2.962 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.390 | 1.390 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.113 | 1.236 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.556 | 0.558 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.353 | 0.353 | 2.0 |
| process | main/main.cpp:5061 | 0.339 | 2.569 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.196 | 3.205 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.136 | 0.355 | 18.1 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.133 | 0.143 | 41.1 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.128 | 0.128 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1935.2 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.058 | 0.058 | 1935.2 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.044 | 0.044 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.043 | 1.807 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.043 | 0.043 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.042 | 0.042 | 1252.1 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.026 | 0.026 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.025 | 0.383 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.022 | 0.107 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.020 | 0.678 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.019 | 0.025 | 15.6 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.017 | 0.017 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.014 | 0.014 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.292 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.473 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.160 |
| res://addons/xr_editor/core/feature_settings.gd | 0.059 |
| res://addons/xr_editor/xr/hand.gd | 0.031 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/ui/panels.gd | 0.027 |
| res://addons/xr_editor/tools/manipulator.gd | 0.027 |
| res://addons/xr_editor/xr/session.gd | 0.020 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/xr_editor/tools/icons.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |

### 11 open_ui_off

Thread 1: frames 585, mean Main::iteration 8.68 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.362 | 1.0 |
| process | 3.075 | 1.0 |
| xr_server->_process | 2.207 | 1.0 |
| AudioServer::update | 0.024 | 1.0 |
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
| engine C++ (servers/) | 3.358 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.642 |
| engine C++ (modules/) | 1.959 |
| engine C++ (main/) | 0.721 |
| GDScript: other scripts, with engine calls made from them | 0.014 |
| engine C++ (platform/) | 0.011 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.987 | 1.987 | 2.0 |
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 1.894 | 1.894 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.344 | 1.477 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.621 | 0.623 | 16.7 |
| process | main/main.cpp:5061 | 0.419 | 3.075 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.393 | 0.393 | 2.0 |
| xr_server->_process | main/main.cpp:4965 | 0.249 | 2.207 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.141 | 0.141 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.140 | 0.370 | 18.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.139 | 0.150 | 41.1 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.068 | 0.068 | 1935.3 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.064 | 0.064 | 0.0 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.062 | 0.062 | 1935.3 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.060 | 0.060 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.058 | 0.058 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.050 | 2.457 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.045 | 0.045 | 1250.1 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.031 | 0.031 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.028 | 0.401 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.025 | 0.130 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.024 | 0.024 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.024 | 0.754 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.024 | 0.024 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.020 | 0.026 | 15.5 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.016 | 0.016 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.577 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.509 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.191 |
| res://addons/xr_editor/core/feature_settings.gd | 0.069 |
| res://addons/xr_editor/xr/hand.gd | 0.038 |
| res://addons/xr_editor/xr/rig.gd | 0.034 |
| res://addons/xr_editor/tools/manipulator.gd | 0.034 |
| res://addons/xr_editor/ui/panels.gd | 0.033 |
| res://addons/xr_editor/xr/session.gd | 0.028 |
| res://addons/xr_editor/tools/locomotion.gd | 0.016 |
| res://addons/xr_editor/tools/icons.gd | 0.015 |
| res://addons/blueprints/document.gd | 0.014 |
| res://addons/xr_editor/tools/outline.gd | 0.013 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.010 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.007 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.003 |

### 12 open_all_off

Thread 1: frames 607, mean Main::iteration 8.40 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 3.123 | 1.0 |
| process | 2.680 | 1.0 |
| RenderingServer::draw | 2.554 | 1.0 |
| AudioServer::update | 0.022 | 1.0 |
| physics | 0.021 | 1.0 |
| Physics Step | 0.021 | 0.5 |
| physics_process | 0.015 | 0.5 |
| PhysicsServer3D::sync | 0.002 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.001 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 2.861 |
| engine C++ (servers/) | 2.551 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.230 |
| engine C++ (main/) | 0.751 |
| GDScript: other scripts, with engine calls made from them | 0.015 |
| engine C++ (platform/) | 0.011 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.793 | 2.793 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.693 | 1.693 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.295 | 1.425 | 1.0 |
| process | main/main.cpp:5061 | 0.435 | 2.680 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.314 | 0.316 | 16.9 |
| xr_server->_process | main/main.cpp:4965 | 0.264 | 3.123 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.184 | 0.184 | 2.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.147 | 0.147 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.066 | 0.066 | 1935.2 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.066 | 0.066 | 1.0 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.061 | 0.061 | 1935.2 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.059 | 0.059 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.043 | 1.945 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.034 | 0.034 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.033 | 0.033 | 0.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.028 | 0.044 | 18.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.026 | 0.074 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.025 | 0.129 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.025 | 0.427 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.022 | 0.022 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.019 | 0.019 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.016 | 0.016 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.015 | 0.015 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.012 | 0.049 | 2.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.012 | 0.040 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.487 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.193 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.181 |
| res://addons/xr_editor/core/feature_settings.gd | 0.069 |
| res://addons/xr_editor/xr/hand.gd | 0.038 |
| res://addons/xr_editor/ui/panels.gd | 0.034 |
| res://addons/xr_editor/xr/rig.gd | 0.034 |
| res://addons/xr_editor/tools/manipulator.gd | 0.033 |
| res://addons/xr_editor/xr/session.gd | 0.029 |
| res://addons/xr_editor/tools/locomotion.gd | 0.017 |
| res://addons/xr_editor/tools/icons.gd | 0.016 |
| res://addons/blueprints/document.gd | 0.015 |
| res://addons/xr_editor/tools/outline.gd | 0.012 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.011 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.007 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.005 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.004 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.003 |

### 13 open_views_off

Thread 1: frames 606, mean Main::iteration 8.40 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 2.899 | 1.0 |
| RenderingServer::draw | 2.874 | 1.0 |
| process | 2.605 | 1.0 |
| physics | 0.016 | 1.0 |
| AudioServer::update | 0.016 | 1.0 |
| Physics Step | 0.016 | 0.5 |
| physics_process | 0.011 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| 2D physics | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 2.871 |
| engine C++ (modules/) | 2.694 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.244 |
| engine C++ (main/) | 0.593 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.643 | 2.643 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.717 | 1.717 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.131 | 1.253 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.512 | 0.513 | 16.6 |
| process | main/main.cpp:5061 | 0.348 | 2.605 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.336 | 0.336 | 2.0 |
| xr_server->_process | main/main.cpp:4965 | 0.206 | 2.899 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.134 | 0.351 | 18.1 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.132 | 0.141 | 41.1 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.124 | 0.124 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1935.2 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.059 | 0.059 | 1935.2 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.049 | 0.049 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.045 | 0.045 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.042 | 0.042 | 1252.1 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.041 | 2.116 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.033 | 0.033 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.030 | 0.030 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.025 | 0.379 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.022 | 0.109 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.021 | 0.679 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.020 | 0.020 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.018 | 0.024 | 15.6 |
| AudioServer::update | main/main.cpp:5111 | 0.016 | 0.016 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.014 | 0.014 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.310 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.470 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.163 |
| res://addons/xr_editor/core/feature_settings.gd | 0.059 |
| res://addons/xr_editor/xr/hand.gd | 0.031 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/ui/panels.gd | 0.028 |
| res://addons/xr_editor/tools/manipulator.gd | 0.027 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |

### 14 open_root_off

Thread 1: frames 607, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 4.654 | 1.0 |
| process | 2.570 | 1.0 |
| RenderingServer::draw | 1.144 | 1.0 |
| physics | 0.016 | 1.0 |
| Physics Step | 0.015 | 0.5 |
| AudioServer::update | 0.013 | 1.0 |
| physics_process | 0.011 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 4.455 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.217 |
| engine C++ (servers/) | 1.140 |
| engine C++ (main/) | 0.578 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 4.405 | 4.405 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.115 | 1.237 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.544 | 0.546 | 16.8 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.359 | 0.359 | 1.0 |
| process | main/main.cpp:5061 | 0.342 | 2.570 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.201 | 4.654 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.133 | 0.352 | 18.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.133 | 0.143 | 41.1 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.101 | 0.101 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1938.4 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.058 | 0.058 | 1938.4 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.050 | 0.050 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.043 | 0.043 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.042 | 0.042 | 1250.1 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.034 | 0.034 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.033 | 0.033 | 0.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.025 | 0.380 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.022 | 0.107 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.020 | 0.674 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.019 | 0.025 | 15.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.018 | 0.018 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.013 | 0.013 | 1.0 |
| physics_process | main/main.cpp:5000 | 0.011 | 0.011 | 0.5 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.042 | 2.0 |
| _ray_over_plates | res://addons/xr_editor/logic_graph/blueprints.gd:6063 | 0.010 | 0.018 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.294 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.469 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.160 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/xr/hand.gd | 0.031 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/ui/panels.gd | 0.027 |
| res://addons/xr_editor/tools/manipulator.gd | 0.027 |
| res://addons/xr_editor/xr/session.gd | 0.020 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |

### 15 open_lean

Thread 1: frames 610, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 3.247 | 1.0 |
| process | 2.570 | 1.0 |
| RenderingServer::draw | 2.542 | 1.0 |
| physics | 0.016 | 1.0 |
| Physics Step | 0.015 | 0.5 |
| AudioServer::update | 0.015 | 1.0 |
| physics_process | 0.011 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| 2D physics | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 3.041 |
| engine C++ (servers/) | 2.539 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.208 |
| engine C++ (main/) | 0.594 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.992 | 2.992 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.330 | 1.330 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.104 | 1.225 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.553 | 0.555 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.352 | 0.352 | 2.0 |
| process | main/main.cpp:5061 | 0.349 | 2.570 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.208 | 3.247 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.132 | 0.347 | 18.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.131 | 0.140 | 41.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.128 | 0.128 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1935.2 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.057 | 0.057 | 1935.2 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.046 | 0.046 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.044 | 0.044 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.043 | 1.747 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.042 | 0.042 | 1248.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.027 | 0.027 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.025 | 0.375 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.022 | 0.108 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.020 | 0.673 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.019 | 0.024 | 15.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.018 | 0.018 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.015 | 0.015 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.014 | 0.014 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.281 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.465 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.162 |
| res://addons/xr_editor/core/feature_settings.gd | 0.060 |
| res://addons/xr_editor/xr/hand.gd | 0.031 |
| res://addons/xr_editor/xr/rig.gd | 0.029 |
| res://addons/xr_editor/ui/panels.gd | 0.028 |
| res://addons/xr_editor/tools/manipulator.gd | 0.028 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |

### 16 open

Thread 1: frames 607, mean Main::iteration 8.41 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.081 | 1.0 |
| process | 2.717 | 1.0 |
| xr_server->_process | 2.573 | 1.0 |
| AudioServer::update | 0.023 | 1.0 |
| physics | 0.017 | 1.0 |
| Physics Step | 0.017 | 0.5 |
| physics_process | 0.012 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| GDExtensionManager::frame | 0.001 | 1.0 |
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
| engine C++ (servers/) | 3.078 |
| engine C++ (modules/) | 2.355 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.336 |
| engine C++ (main/) | 0.634 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.010 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.301 | 2.301 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.786 | 1.786 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.184 | 1.308 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.596 | 0.598 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.378 | 0.378 | 2.0 |
| process | main/main.cpp:5061 | 0.368 | 2.717 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.219 | 2.573 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.136 | 0.355 | 18.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.133 | 0.143 | 40.9 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.127 | 0.127 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.063 | 0.063 | 1932.0 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.059 | 0.059 | 1932.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.049 | 0.049 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.049 | 2.236 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.048 | 0.048 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.043 | 0.043 | 1245.9 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.033 | 0.033 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.029 | 0.029 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.026 | 0.383 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.023 | 0.114 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.023 | 0.023 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.022 | 0.698 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.019 | 0.019 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.019 | 0.025 | 15.5 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.015 | 0.015 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.367 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.479 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.171 |
| res://addons/xr_editor/core/feature_settings.gd | 0.062 |
| res://addons/xr_editor/xr/hand.gd | 0.034 |
| res://addons/xr_editor/xr/rig.gd | 0.030 |
| res://addons/xr_editor/ui/panels.gd | 0.029 |
| res://addons/xr_editor/tools/manipulator.gd | 0.029 |
| res://addons/xr_editor/xr/session.gd | 0.023 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/xr_editor/tools/icons.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |

### 17 open_big2

Thread 1: frames 603, mean Main::iteration 8.45 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.621 | 1.0 |
| process | 2.955 | 1.0 |
| xr_server->_process | 1.863 | 1.0 |
| AudioServer::update | 0.016 | 1.0 |
| physics | 0.016 | 1.0 |
| Physics Step | 0.016 | 0.5 |
| physics_process | 0.011 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| 2D physics | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.620 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.591 |
| engine C++ (modules/) | 1.654 |
| engine C++ (main/) | 0.601 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.910 | 1.910 | 2.0 |
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 1.604 | 1.604 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.122 | 1.244 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.858 | 0.860 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.536 | 0.536 | 2.0 |
| process | main/main.cpp:5061 | 0.352 | 2.955 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.285 | 0.304 | 93.8 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.245 | 0.688 | 32.7 |
| xr_server->_process | main/main.cpp:4965 | 0.210 | 1.863 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.124 | 0.124 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.078 | 0.078 | 2430.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.061 | 0.061 | 1938.4 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.058 | 0.058 | 1938.4 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.047 | 0.047 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.045 | 0.045 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.043 | 2.512 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.042 | 0.734 | 0.5 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.034 | 0.034 | 0.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.033 | 0.043 | 30.1 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.031 | 0.031 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.026 | 0.026 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.022 | 0.108 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.020 | 1.033 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.016 | 0.016 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.014 | 0.014 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.301 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.825 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.163 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/xr/hand.gd | 0.032 |
| res://addons/xr_editor/ui/panels.gd | 0.028 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/tools/manipulator.gd | 0.027 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/xr_editor/tools/icons.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |

### 18 closed

Thread 1: frames 607, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 3.972 | 1.0 |
| process | 2.363 | 1.0 |
| RenderingServer::draw | 2.024 | 1.0 |
| AudioServer::update | 0.017 | 1.0 |
| physics | 0.017 | 1.0 |
| Physics Step | 0.017 | 0.5 |
| physics_process | 0.012 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 3D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| 2D physics | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 3.769 |
| engine C++ (servers/) | 2.020 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.987 |
| engine C++ (main/) | 0.623 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 3.712 | 3.712 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.378 | 1.378 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.162 | 1.494 | 1.0 |
| process | main/main.cpp:5061 | 0.377 | 2.363 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.210 | 0.211 | 14.7 |
| xr_server->_process | main/main.cpp:4965 | 0.205 | 3.972 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.174 | 0.174 | 1933.9 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.154 | 0.154 | 1933.9 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.126 | 0.126 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.123 | 0.123 | 2.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.056 | 0.056 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.050 | 0.050 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.038 | 1.562 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.034 | 0.034 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.034 | 0.034 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.020 | 0.143 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.017 | 0.017 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.015 | 0.015 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.012 | 0.044 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.012 | 0.012 | 0.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.011 | 0.011 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.010 | 0.014 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.009 | 8.395 | 1.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.009 | 0.033 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.009 | 0.066 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.554 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.101 |
| res://addons/xr_editor/core/feature_settings.gd | 0.063 |
| res://addons/xr_editor/tools/manipulator.gd | 0.033 |
| res://addons/xr_editor/xr/hand.gd | 0.032 |
| res://addons/xr_editor/xr/rig.gd | 0.031 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.029 |
| res://addons/xr_editor/xr/session.gd | 0.024 |
| res://addons/xr_editor/ui/panels.gd | 0.021 |
| res://addons/xr_editor/tools/locomotion.gd | 0.015 |
| res://addons/xr_editor/tools/icons.gd | 0.014 |
| res://addons/xr_editor/tools/outline.gd | 0.012 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
