
### 01 closed

Thread 1: frames 610, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 4.588 | 1.0 |
| RenderingServer::draw | 1.949 | 1.0 |
| process | 1.820 | 1.0 |
| physics | 0.015 | 1.0 |
| Physics Step | 0.015 | 0.5 |
| AudioServer::update | 0.012 | 1.0 |
| physics_process | 0.009 | 0.5 |
| 2D physics | 0.003 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.000 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.5 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 4.421 |
| engine C++ (servers/) | 1.950 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.526 |
| engine C++ (main/) | 0.501 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 4.378 | 4.378 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.405 | 1.405 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.007 | 1.129 | 1.0 |
| process | main/main.cpp:5061 | 0.293 | 1.820 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.175 | 4.588 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.166 | 0.167 | 14.6 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.115 | 0.115 | 2.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.107 | 0.107 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1930.0 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.059 | 0.059 | 1930.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.046 | 0.046 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.038 | 0.038 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.035 | 1.574 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.028 | 0.028 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.015 | 0.110 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.012 | 0.012 | 2.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.011 | 0.011 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.010 | 0.037 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.009 | 0.009 | 0.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.008 | 0.008 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 8.396 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.007 | 0.053 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1056 | 0.007 | 0.014 | 14.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.183 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.077 |
| res://addons/xr_editor/core/feature_settings.gd | 0.053 |
| res://addons/xr_editor/tools/manipulator.gd | 0.025 |
| res://addons/xr_editor/xr/rig.gd | 0.025 |
| res://addons/xr_editor/xr/hand.gd | 0.025 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.020 |
| res://addons/xr_editor/xr/session.gd | 0.018 |
| res://addons/xr_editor/ui/panels.gd | 0.018 |
| res://addons/xr_editor/tools/locomotion.gd | 0.012 |
| res://addons/xr_editor/tools/icons.gd | 0.010 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
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
| res://addons/xr_editor/tools/undo.gd | 0.002 |

### 02 open

Thread 1: frames 609, mean Main::iteration 8.40 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.052 | 1.0 |
| xr_server->_process | 2.724 | 1.0 |
| process | 2.592 | 1.0 |
| physics | 0.018 | 1.0 |
| Physics Step | 0.018 | 0.5 |
| AudioServer::update | 0.014 | 1.0 |
| physics_process | 0.011 | 0.5 |
| 2D physics | 0.003 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.049 |
| engine C++ (modules/) | 2.526 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.242 |
| engine C++ (main/) | 0.575 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.478 | 2.478 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.774 | 1.774 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.135 | 1.263 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.561 | 0.562 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.399 | 0.399 | 2.0 |
| process | main/main.cpp:5061 | 0.337 | 2.592 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.200 | 2.724 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.133 | 0.351 | 18.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.132 | 0.142 | 41.1 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.126 | 0.126 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.064 | 0.064 | 1934.3 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.062 | 0.062 | 1934.3 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.046 | 0.046 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.045 | 2.247 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.042 | 0.042 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.042 | 0.042 | 1250.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.030 | 0.030 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.026 | 0.379 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.022 | 0.107 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.020 | 0.674 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.019 | 0.025 | 15.5 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.019 | 0.019 | 1.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.016 | 0.016 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.317 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.469 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.160 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/xr/hand.gd | 0.031 |
| res://addons/xr_editor/xr/rig.gd | 0.029 |
| res://addons/xr_editor/ui/panels.gd | 0.027 |
| res://addons/xr_editor/tools/manipulator.gd | 0.027 |
| res://addons/xr_editor/xr/session.gd | 0.020 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |

### 03 open_graph100

Thread 1: frames 435, mean Main::iteration 11.76 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.278 | 1.0 |
| process | 3.671 | 1.0 |
| xr_server->_process | 2.775 | 1.0 |
| physics | 0.025 | 1.0 |
| Physics Step | 0.025 | 0.7 |
| physics_process | 0.016 | 0.7 |
| AudioServer::update | 0.015 | 1.0 |
| 2D physics | 0.003 | 0.7 |
| PhysicsServer3D::sync | 0.002 | 0.7 |
| PhysicsServer2D::sync | 0.001 | 0.7 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.7 |
| NavigationServer2D::physics_process | 0.001 | 0.7 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| 3D physics | 0.000 | 0.7 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.7 |
| main loop iteration prepare | 0.000 | 0.7 |
| main loop iteration end | 0.000 | 0.7 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.276 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 3.320 |
| engine C++ (modules/) | 2.565 |
| engine C++ (main/) | 0.599 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.516 | 2.516 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.472 | 2.472 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.423 | 1.424 | 16.9 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.155 | 1.275 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 1.047 | 1.047 | 2.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.577 | 0.614 | 201.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.455 | 1.325 | 61.6 |
| process | main/main.cpp:5061 | 0.340 | 3.671 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.211 | 2.775 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.146 | 0.146 | 4768.9 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.125 | 0.125 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.073 | 1.405 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.060 | 0.077 | 59.1 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.060 | 0.060 | 1936.4 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.058 | 0.058 | 1936.4 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.056 | 3.607 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.047 | 0.047 | 0.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.043 | 0.043 | 1.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.042 | 0.042 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.031 | 0.031 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.028 | 0.028 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.022 | 0.108 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.021 | 1.708 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4458 | 0.018 | 0.458 | 157.9 |
| physics_process | main/main.cpp:5000 | 0.016 | 0.016 | 0.7 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 1.497 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.348 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.166 |
| res://addons/xr_editor/core/feature_settings.gd | 0.059 |
| res://addons/xr_editor/xr/hand.gd | 0.033 |
| res://addons/xr_editor/xr/rig.gd | 0.030 |
| res://addons/xr_editor/ui/panels.gd | 0.028 |
| res://addons/xr_editor/tools/manipulator.gd | 0.027 |
| res://addons/xr_editor/xr/session.gd | 0.023 |
| res://addons/xr_editor/tools/locomotion.gd | 0.015 |
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

### 04 open_graph250

Thread 1: frames 280, mean Main::iteration 18.26 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 8.289 | 1.0 |
| process | 5.939 | 1.0 |
| xr_server->_process | 4.053 | 1.0 |
| physics | 0.042 | 1.0 |
| Physics Step | 0.042 | 1.1 |
| physics_process | 0.027 | 1.1 |
| AudioServer::update | 0.020 | 1.0 |
| 2D physics | 0.006 | 1.1 |
| PhysicsServer3D::sync | 0.003 | 1.1 |
| PhysicsServer2D::sync | 0.002 | 1.1 |
| NavigationServer3D::physics_process | 0.001 | 1.1 |
| NavigationServer2D::physics_process | 0.001 | 1.1 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.1 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| setup | 0.001 | 1.1 |
| main loop iteration prepare | 0.000 | 1.1 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration end | 0.000 | 1.1 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 8.286 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 5.550 |
| engine C++ (modules/) | 3.807 |
| engine C++ (main/) | 0.694 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.011 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 3.746 | 3.746 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 3.354 | 3.355 | 17.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.560 | 2.560 | 2.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 1.954 | 1.954 | 2.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 1.426 | 1.517 | 515.7 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.221 | 1.342 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 1.110 | 3.260 | 149.6 |
| process | main/main.cpp:5061 | 0.375 | 5.939 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.363 | 0.363 | 11862.1 |
| xr_server->_process | main/main.cpp:4965 | 0.248 | 4.053 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.175 | 3.454 | 0.5 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.146 | 0.146 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.145 | 0.186 | 147.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.079 | 4.634 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.077 | 0.077 | 0.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.060 | 0.060 | 1945.8 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.058 | 0.058 | 1.0 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.058 | 0.058 | 1945.8 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.054 | 0.054 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4458 | 0.050 | 1.269 | 440.4 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.042 | 0.042 | 1.0 |
| set_instance_transform | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4497 | 0.032 | 0.032 | 515.7 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.029 | 0.029 | 1.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2957 | 0.028 | 0.028 | 149.1 |
| physics_process | main/main.cpp:5000 | 0.027 | 0.027 | 1.1 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 3.555 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.453 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.187 |
| res://addons/xr_editor/core/feature_settings.gd | 0.066 |
| res://addons/xr_editor/xr/hand.gd | 0.037 |
| res://addons/xr_editor/xr/rig.gd | 0.034 |
| res://addons/xr_editor/ui/panels.gd | 0.033 |
| res://addons/xr_editor/xr/session.gd | 0.029 |
| res://addons/xr_editor/tools/manipulator.gd | 0.029 |
| res://addons/xr_editor/tools/locomotion.gd | 0.018 |
| res://addons/xr_editor/tools/icons.gd | 0.015 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.010 |
| res://addons/xr_editor/ui/palette.gd | 0.008 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.005 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.005 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.004 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.003 |

### 05 open_graph500

Thread 1: frames 200, mean Main::iteration 25.44 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 14.091 | 1.0 |
| process | 8.120 | 1.0 |
| xr_server->_process | 3.150 | 1.0 |
| physics | 0.050 | 1.0 |
| Physics Step | 0.049 | 1.5 |
| physics_process | 0.031 | 1.5 |
| AudioServer::update | 0.024 | 1.0 |
| 2D physics | 0.007 | 1.5 |
| PhysicsServer3D::sync | 0.003 | 1.5 |
| PhysicsServer2D::sync | 0.002 | 1.5 |
| NavigationServer3D::physics_process | 0.001 | 1.5 |
| NavigationServer2D::physics_process | 0.001 | 1.5 |
| OS::add_frame_delay | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.5 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| setup | 0.001 | 1.5 |
| main loop iteration prepare | 0.001 | 1.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration end | 0.000 | 1.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 14.118 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 7.723 |
| engine C++ (modules/) | 2.881 |
| engine C++ (main/) | 0.761 |
| GDScript: other scripts, with engine calls made from them | 0.014 |
| engine C++ (platform/) | 0.012 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 6.923 | 6.925 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 4.016 | 4.016 | 2.0 |
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.814 | 2.814 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.684 | 2.684 | 2.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 2.191 | 5.039 | 294.4 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 1.500 | 1.599 | 516.3 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.304 | 1.428 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.755 | 0.755 | 23552.4 |
| process | main/main.cpp:5061 | 0.407 | 8.120 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.350 | 5.402 | 0.5 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.295 | 0.378 | 291.9 |
| xr_server->_process | main/main.cpp:4965 | 0.271 | 3.150 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.156 | 0.156 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.121 | 6.872 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.119 | 0.119 | 0.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1932.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.061 | 0.061 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.059 | 0.059 | 1.0 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.059 | 0.059 | 1932.0 |
| focus_paint | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:2957 | 0.056 | 0.056 | 293.9 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4458 | 0.054 | 1.347 | 443.9 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.043 | 0.043 | 1.0 |
| set_instance_transform | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4497 | 0.036 | 0.036 | 516.3 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4428 | 0.034 | 4.952 | 280.9 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4441 | 0.034 | 0.412 | 291.9 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 5.534 |
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.587 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.206 |
| res://addons/xr_editor/core/feature_settings.gd | 0.072 |
| res://addons/xr_editor/xr/hand.gd | 0.042 |
| res://addons/xr_editor/xr/rig.gd | 0.039 |
| res://addons/xr_editor/ui/panels.gd | 0.036 |
| res://addons/xr_editor/xr/session.gd | 0.035 |
| res://addons/xr_editor/tools/manipulator.gd | 0.031 |
| res://addons/xr_editor/tools/locomotion.gd | 0.021 |
| res://addons/xr_editor/tools/icons.gd | 0.017 |
| res://addons/blueprints/document.gd | 0.014 |
| res://addons/xr_editor/tools/outline.gd | 0.012 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.011 |
| res://addons/xr_editor/ui/palette.gd | 0.008 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.008 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.007 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.006 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.006 |
| res://addons/xr_editor/ui/panel_window.gd | 0.005 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.004 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.004 |

### 06 open

Thread 1: frames 609, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 2.970 | 1.0 |
| xr_server->_process | 2.897 | 1.0 |
| process | 2.502 | 1.0 |
| physics | 0.017 | 1.0 |
| Physics Step | 0.017 | 0.5 |
| AudioServer::update | 0.012 | 1.0 |
| physics_process | 0.010 | 0.5 |
| 2D physics | 0.003 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.000 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 2.969 |
| engine C++ (modules/) | 2.707 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.177 |
| engine C++ (main/) | 0.544 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.662 | 2.662 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.752 | 1.752 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.103 | 1.226 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.562 | 0.563 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.355 | 0.355 | 2.0 |
| process | main/main.cpp:5061 | 0.317 | 2.502 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.192 | 2.897 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.130 | 0.342 | 18.1 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.129 | 0.139 | 41.4 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.123 | 0.123 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1938.3 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.059 | 0.059 | 1938.3 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.047 | 2.174 | 1.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.043 | 0.043 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.041 | 0.041 | 1254.1 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.040 | 0.040 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.027 | 0.027 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.025 | 0.369 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.021 | 0.103 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.020 | 0.020 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.020 | 0.655 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.018 | 0.023 | 15.6 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.013 | 0.013 | 2.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.280 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.455 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.156 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/xr/hand.gd | 0.030 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/ui/panels.gd | 0.026 |
| res://addons/xr_editor/tools/manipulator.gd | 0.026 |
| res://addons/xr_editor/xr/session.gd | 0.019 |
| res://addons/xr_editor/tools/locomotion.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/icons.gd | 0.011 |
| res://addons/xr_editor/tools/outline.gd | 0.009 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.005 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/ui/panel_window.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |

### 07 closed

Thread 1: frames 611, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 4.239 | 1.0 |
| process | 2.146 | 1.0 |
| RenderingServer::draw | 1.978 | 1.0 |
| physics | 0.016 | 1.0 |
| Physics Step | 0.016 | 0.5 |
| AudioServer::update | 0.012 | 1.0 |
| physics_process | 0.009 | 0.5 |
| 2D physics | 0.003 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.000 | 0.5 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 4.067 |
| engine C++ (servers/) | 1.976 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.830 |
| engine C++ (main/) | 0.524 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 4.021 | 4.021 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.408 | 1.408 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.075 | 1.387 | 1.0 |
| process | main/main.cpp:5061 | 0.317 | 2.146 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.177 | 0.178 | 14.7 |
| xr_server->_process | main/main.cpp:4965 | 0.173 | 4.239 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.164 | 0.164 | 1933.9 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.146 | 0.146 | 1933.9 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.120 | 0.120 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.112 | 0.112 | 2.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.045 | 0.045 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.041 | 0.041 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.039 | 1.578 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.033 | 0.033 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.026 | 0.026 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.019 | 0.132 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.012 | 0.012 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.012 | 0.012 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.041 | 2.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.010 | 0.010 | 1.0 |
| physics_process | main/main.cpp:5000 | 0.009 | 0.009 | 0.5 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 8.397 | 1.0 |
| _process_frame | res://addons/xr_editor/tools/manipulator.gd:302 | 0.008 | 0.058 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.008 | 0.012 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1056 | 0.008 | 0.015 | 14.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.442 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.092 |
| res://addons/xr_editor/core/feature_settings.gd | 0.057 |
| res://addons/xr_editor/xr/rig.gd | 0.028 |
| res://addons/xr_editor/tools/manipulator.gd | 0.028 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.026 |
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
| res://addons/xr_editor/tools/undo.gd | 0.002 |

### 08 closed_scene1k

Thread 1: frames 611, mean Main::iteration 8.40 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 3.383 | 1.0 |
| RenderingServer::draw | 2.986 | 1.0 |
| process | 2.002 | 1.0 |
| physics | 0.017 | 1.0 |
| Physics Step | 0.017 | 0.5 |
| AudioServer::update | 0.014 | 1.0 |
| physics_process | 0.010 | 0.5 |
| 2D physics | 0.003 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 3.184 |
| engine C++ (servers/) | 2.983 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.675 |
| engine C++ (main/) | 0.565 |
| engine C++ (platform/) | 0.008 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 3.137 | 3.137 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.955 | 1.955 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.097 | 1.222 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.607 | 0.608 | 14.7 |
| process | main/main.cpp:5061 | 0.328 | 2.002 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.200 | 3.383 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.125 | 0.125 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.116 | 0.116 | 2.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.063 | 0.063 | 1933.2 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.060 | 0.060 | 1933.2 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.049 | 0.049 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.042 | 0.042 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.039 | 2.130 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.034 | 0.034 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.033 | 0.033 | 0.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.019 | 0.134 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.017 | 0.017 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.014 | 0.014 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.041 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.010 | 0.010 | 0.5 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.009 | 0.009 | 2.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.008 | 8.408 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.008 | 0.033 | 1.0 |
| preset_binding | res://addons/xr_editor/core/feature_settings.gd:1056 | 0.008 | 0.015 | 14.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.278 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.095 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/xr/rig.gd | 0.029 |
| res://addons/xr_editor/xr/hand.gd | 0.028 |
| res://addons/xr_editor/tools/manipulator.gd | 0.028 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.026 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.019 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/xr_editor/tools/icons.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
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

### 09 closed_scene5k

Thread 1: frames 611, mean Main::iteration 8.38 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 4.720 | 1.0 |
| process | 2.053 | 1.0 |
| xr_server->_process | 1.589 | 1.0 |
| physics | 0.017 | 1.0 |
| Physics Step | 0.017 | 0.5 |
| AudioServer::update | 0.014 | 1.0 |
| physics_process | 0.010 | 0.5 |
| 2D physics | 0.002 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 4.717 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.727 |
| engine C++ (modules/) | 1.393 |
| engine C++ (main/) | 0.561 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.437 | 2.437 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 1.863 | 1.864 | 14.7 |
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 1.347 | 1.347 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.141 | 1.266 | 1.0 |
| process | main/main.cpp:5061 | 0.326 | 2.053 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.198 | 1.589 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.123 | 0.123 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.119 | 0.119 | 2.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.063 | 0.063 | 1933.2 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.060 | 0.060 | 1933.2 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.046 | 0.046 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.041 | 0.041 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.038 | 2.615 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.033 | 0.033 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.030 | 0.030 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.020 | 0.020 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.019 | 0.138 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.014 | 0.014 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.013 | 0.013 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.042 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.010 | 0.010 | 0.5 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.009 | 8.393 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.009 | 0.033 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.008 | 0.012 | 1.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.008 | 0.008 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.322 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.097 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/xr/rig.gd | 0.029 |
| res://addons/xr_editor/tools/manipulator.gd | 0.029 |
| res://addons/xr_editor/xr/hand.gd | 0.029 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.027 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.020 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/xr_editor/tools/icons.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |

### 10 closed_scene20k

Thread 1: frames 305, mean Main::iteration 16.75 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 10.924 | 1.0 |
| xr_server->_process | 3.429 | 1.0 |
| process | 2.350 | 1.0 |
| physics | 0.045 | 1.0 |
| Physics Step | 0.045 | 1.0 |
| physics_process | 0.028 | 1.0 |
| AudioServer::update | 0.023 | 1.0 |
| 2D physics | 0.007 | 1.0 |
| PhysicsServer3D::sync | 0.003 | 1.0 |
| PhysicsServer2D::sync | 0.002 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 2D navigation | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| 3D physics | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| setup | 0.001 | 1.0 |
| main loop iteration prepare | 0.001 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| main loop iteration end | 0.000 | 1.0 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 10.920 |
| engine C++ (modules/) | 3.166 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.977 |
| engine C++ (main/) | 0.715 |
| engine C++ (platform/) | 0.011 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 6.123 | 6.125 | 14.6 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 4.300 | 4.300 | 2.0 |
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 3.103 | 3.103 | 1.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.271 | 1.398 | 1.0 |
| process | main/main.cpp:5061 | 0.373 | 2.350 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.265 | 3.429 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.142 | 0.142 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.138 | 0.138 | 2.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.063 | 0.063 | 0.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.062 | 0.062 | 1936.3 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.061 | 0.061 | 1936.3 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.055 | 0.055 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.051 | 4.516 | 1.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.051 | 0.051 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.031 | 0.031 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.031 | 0.031 | 1.0 |
| physics_process | main/main.cpp:5000 | 0.028 | 0.028 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.023 | 0.023 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.022 | 0.158 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.015 | 0.015 | 2.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.013 | 0.048 | 2.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.012 | 0.043 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.012 | 0.047 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.011 | 0.016 | 1.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.011 | 16.765 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.493 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.112 |
| res://addons/xr_editor/core/feature_settings.gd | 0.066 |
| res://addons/xr_editor/xr/rig.gd | 0.035 |
| res://addons/xr_editor/xr/hand.gd | 0.034 |
| res://addons/xr_editor/tools/manipulator.gd | 0.032 |
| res://addons/xr_editor/xr/session.gd | 0.032 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.031 |
| res://addons/xr_editor/ui/panels.gd | 0.023 |
| res://addons/xr_editor/tools/locomotion.gd | 0.019 |
| res://addons/xr_editor/tools/icons.gd | 0.016 |
| res://addons/xr_editor/tools/outline.gd | 0.012 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.011 |
| res://addons/xr_editor/ui/palette.gd | 0.008 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.007 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.007 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.004 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.003 |
| res://addons/xr_editor/xr/standalone.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |

### 11 closed

Thread 1: frames 610, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 4.322 | 1.0 |
| process | 2.023 | 1.0 |
| RenderingServer::draw | 2.015 | 1.0 |
| physics | 0.018 | 1.0 |
| Physics Step | 0.017 | 0.5 |
| AudioServer::update | 0.013 | 1.0 |
| physics_process | 0.010 | 0.5 |
| 2D physics | 0.003 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 4.125 |
| engine C++ (servers/) | 2.012 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 1.695 |
| engine C++ (main/) | 0.563 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 4.076 | 4.076 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.428 | 1.428 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.116 | 1.238 | 1.0 |
| process | main/main.cpp:5061 | 0.328 | 2.023 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.198 | 4.322 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.185 | 0.186 | 14.7 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.116 | 0.116 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.115 | 0.115 | 2.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.061 | 0.061 | 1933.2 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.059 | 0.059 | 1933.2 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.051 | 0.051 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.043 | 0.043 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.037 | 1.601 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.030 | 0.030 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.019 | 0.136 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.013 | 0.013 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.013 | 0.013 | 2.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.011 | 0.011 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.011 | 0.041 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.010 | 0.010 | 0.5 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.009 | 8.397 | 1.0 |
| _process | res://addons/xr_editor/tools/locomotion.gd:108 | 0.008 | 0.033 | 1.0 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.008 | 0.012 | 1.0 |
| driver->command_pool_reset | servers/rendering/rendering_device.cpp:8054 | 0.008 | 0.008 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.294 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.096 |
| res://addons/xr_editor/core/feature_settings.gd | 0.058 |
| res://addons/xr_editor/xr/rig.gd | 0.029 |
| res://addons/xr_editor/tools/manipulator.gd | 0.029 |
| res://addons/xr_editor/xr/hand.gd | 0.029 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.027 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/ui/panels.gd | 0.019 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/xr_editor/tools/icons.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.002 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/xr_editor/logic_graph/blueprint_boxes.gd | 0.002 |
| res://addons/xr_editor/tools/undo.gd | 0.002 |

### 12 open_scene5k

Thread 1: frames 521, mean Main::iteration 9.82 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 5.787 | 1.0 |
| process | 2.632 | 1.0 |
| xr_server->_process | 1.362 | 1.0 |
| physics | 0.022 | 1.0 |
| Physics Step | 0.022 | 0.6 |
| AudioServer::update | 0.016 | 1.0 |
| physics_process | 0.014 | 0.6 |
| 2D physics | 0.003 | 0.6 |
| PhysicsServer3D::sync | 0.002 | 0.6 |
| PhysicsServer2D::sync | 0.001 | 0.6 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.6 |
| process 3D navigation | 0.001 | 1.0 |
| NavigationServer2D::physics_process | 0.001 | 0.6 |
| ScriptServer::frame | 0.001 | 1.0 |
| 3D physics | 0.000 | 0.6 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.6 |
| main loop iteration prepare | 0.000 | 0.6 |
| main loop iteration end | 0.000 | 0.6 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 5.790 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.277 |
| engine C++ (modules/) | 1.148 |
| engine C++ (main/) | 0.602 |
| GDScript: other scripts, with engine calls made from them | 0.012 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 2.854 | 2.854 | 2.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 2.228 | 2.229 | 16.9 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.171 | 1.291 | 1.0 |
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 1.099 | 1.099 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.386 | 0.386 | 2.0 |
| process | main/main.cpp:5061 | 0.343 | 2.632 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.215 | 1.362 | 1.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.129 | 0.129 | 1.0 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.127 | 0.331 | 18.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.125 | 0.134 | 41.1 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.061 | 0.061 | 1935.0 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.058 | 0.058 | 1935.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.046 | 0.046 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.044 | 0.044 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.043 | 3.305 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.039 | 0.039 | 1250.4 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.038 | 0.038 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.032 | 0.032 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.028 | 0.028 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.024 | 0.358 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.022 | 0.108 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.020 | 0.658 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.017 | 0.022 | 15.5 |
| AudioServer::update | main/main.cpp:5111 | 0.016 | 0.016 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.014 | 0.014 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.354 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.449 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.164 |
| res://addons/xr_editor/core/feature_settings.gd | 0.059 |
| res://addons/xr_editor/xr/hand.gd | 0.033 |
| res://addons/xr_editor/xr/rig.gd | 0.030 |
| res://addons/xr_editor/ui/panels.gd | 0.028 |
| res://addons/xr_editor/tools/manipulator.gd | 0.027 |
| res://addons/xr_editor/xr/session.gd | 0.023 |
| res://addons/xr_editor/tools/locomotion.gd | 0.015 |
| res://addons/xr_editor/tools/icons.gd | 0.013 |
| res://addons/blueprints/document.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |

### 13 open

Thread 1: frames 611, mean Main::iteration 8.39 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| RenderingServer::draw | 3.026 | 1.0 |
| xr_server->_process | 2.703 | 1.0 |
| process | 2.624 | 1.0 |
| physics | 0.018 | 1.0 |
| Physics Step | 0.018 | 0.5 |
| AudioServer::update | 0.015 | 1.0 |
| physics_process | 0.010 | 0.5 |
| 2D physics | 0.003 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| ScriptServer::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.000 | 0.5 |
| 3D physics | 0.000 | 0.5 |
| RenderingServer::sync | 0.000 | 1.0 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (servers/) | 3.026 |
| engine C++ (modules/) | 2.495 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.279 |
| engine C++ (main/) | 0.583 |
| GDScript: other scripts, with engine calls made from them | 0.013 |
| engine C++ (platform/) | 0.009 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 2.446 | 2.446 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.762 | 1.762 | 2.0 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.163 | 1.289 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.591 | 0.593 | 16.9 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.366 | 0.366 | 2.0 |
| process | main/main.cpp:5061 | 0.335 | 2.624 | 1.0 |
| xr_server->_process | main/main.cpp:4965 | 0.209 | 2.703 | 1.0 |
| _put_arrow | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4476 | 0.133 | 0.142 | 41.1 |
| _arrows_on | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4437 | 0.132 | 0.349 | 18.0 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.122 | 0.122 | 1.0 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.064 | 0.064 | 1935.2 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.060 | 0.060 | 1935.2 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.049 | 0.049 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.044 | 0.044 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.042 | 2.189 | 1.0 |
| get_point | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4448 | 0.042 | 0.042 | 1250.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.032 | 0.032 | 0.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.031 | 0.031 | 1.0 |
| _lay_arrows | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4418 | 0.024 | 0.376 | 0.5 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.023 | 0.110 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.021 | 0.681 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.021 | 0.021 | 1.0 |
| _arrow_color | res://addons/xr_editor/logic_graph/blueprint_canvas.gd:4465 | 0.018 | 0.024 | 15.5 |
| AudioServer::update | main/main.cpp:5111 | 0.015 | 0.015 | 1.0 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.013 | 0.013 | 2.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.344 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.468 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.166 |
| res://addons/xr_editor/core/feature_settings.gd | 0.059 |
| res://addons/xr_editor/xr/hand.gd | 0.032 |
| res://addons/xr_editor/xr/rig.gd | 0.029 |
| res://addons/xr_editor/ui/panels.gd | 0.028 |
| res://addons/xr_editor/tools/manipulator.gd | 0.027 |
| res://addons/xr_editor/xr/session.gd | 0.021 |
| res://addons/xr_editor/tools/locomotion.gd | 0.014 |
| res://addons/blueprints/document.gd | 0.013 |
| res://addons/xr_editor/tools/icons.gd | 0.012 |
| res://addons/xr_editor/tools/outline.gd | 0.010 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.009 |
| res://addons/xr_editor/ui/palette.gd | 0.006 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.006 |
| res://addons/xr_editor/logic_graph/focus.gd | 0.005 |
| res://addons/xr_editor/tools/clipboard.gd | 0.005 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.004 |
| res://addons/xr_editor/ui/panel_window.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |

### 14 closed

Thread 1: frames 590, mean Main::iteration 8.65 ms.

| Frame phase (main/main.cpp, total time) | ms/frame | Calls/frame |
|---|---|---|
| xr_server->_process | 3.898 | 1.0 |
| process | 2.587 | 1.0 |
| RenderingServer::draw | 2.134 | 1.0 |
| physics | 0.021 | 1.0 |
| Physics Step | 0.021 | 0.5 |
| AudioServer::update | 0.016 | 1.0 |
| physics_process | 0.013 | 0.5 |
| 2D physics | 0.003 | 0.5 |
| PhysicsServer3D::sync | 0.001 | 0.5 |
| PhysicsServer2D::sync | 0.001 | 0.5 |
| process 2D navigation | 0.001 | 1.0 |
| OS::add_frame_delay | 0.001 | 1.0 |
| prepare | 0.001 | 1.0 |
| process 3D navigation | 0.001 | 1.0 |
| GDExtensionManager::frame | 0.001 | 1.0 |
| NavigationServer3D::physics_process | 0.001 | 0.5 |
| NavigationServer2D::physics_process | 0.001 | 0.5 |
| ScriptServer::frame | 0.000 | 1.0 |
| RenderingServer::sync | 0.000 | 1.0 |
| 3D physics | 0.000 | 0.5 |
| setup | 0.000 | 0.5 |
| main loop iteration prepare | 0.000 | 0.5 |
| main loop iteration end | 0.000 | 0.5 |

| Own time by area | ms/frame |
|---|---|
| engine C++ (modules/) | 3.695 |
| engine C++ (servers/) | 2.135 |
| GDScript: plugin (res://addons/xr_editor/), with engine calls made from it | 2.074 |
| engine C++ (main/) | 0.749 |
| engine C++ (platform/) | 0.033 |
| GDScript: other scripts, with engine calls made from them | 0.016 |

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | modules/openxr/openxr_api.cpp:2355 | 3.640 | 3.640 | 1.0 |
| driver->fence_wait | servers/rendering/rendering_device.cpp:8218 | 1.316 | 1.316 | 1.9 |
| _measure | res://addons/xr_editor/telemetry/graph_lab.gd:406 | 1.228 | 1.565 | 1.0 |
| process | main/main.cpp:5061 | 0.494 | 2.587 | 1.0 |
| render viewport | servers/rendering/renderer_viewport.cpp:864 | 0.290 | 0.292 | 14.7 |
| xr_server->_process | main/main.cpp:4965 | 0.211 | 3.898 | 1.0 |
| draw_graph.end | servers/rendering/rendering_device.cpp:8122 | 0.190 | 0.190 | 1.9 |
| viewport_get_measured_render_time_cpu | res://addons/xr_editor/telemetry/graph_lab.gd:418 | 0.176 | 0.176 | 1934.1 |
| viewport_get_measured_render_time_gpu | res://addons/xr_editor/telemetry/graph_lab.gd:419 | 0.156 | 0.156 | 1934.1 |
| xr_server->end_frame | servers/rendering/rendering_server_default.cpp:119 | 0.124 | 0.124 | 1.0 |
| xr_server->pre_render | servers/rendering/rendering_server_default.cpp:87 | 0.057 | 0.057 | 1.0 |
| rasterizer->blit_render_targets_to_screen | servers/rendering/renderer_viewport.cpp:979 | 0.052 | 1.495 | 1.0 |
| _execute_frame | servers/rendering/rendering_device.cpp:7874 | 0.050 | 0.050 | 1.0 |
| extension wrappers on_process | modules/openxr/openxr_api.cpp:2413 | 0.049 | 0.049 | 1.0 |
| find_children | res://addons/xr_editor/telemetry/graph_lab.gd:471 | 0.034 | 0.034 | 0.0 |
| OS_Windows::run | platform/windows/os_windows.cpp:2351 | 0.033 | 8.685 | 1.0 |
| _process_frame | res://addons/xr_editor/logic_graph/blueprints.gd:819 | 0.020 | 0.152 | 1.0 |
| AudioServer::update | main/main.cpp:5111 | 0.016 | 0.016 | 1.0 |
| scene->update | servers/rendering/rendering_server_default.cpp:95 | 0.013 | 0.013 | 1.0 |
| _update_pointer | res://addons/xr_editor/logic_graph/blueprints.gd:2792 | 0.013 | 0.047 | 2.0 |
| physics_process | main/main.cpp:5000 | 0.013 | 0.013 | 0.5 |
| driver->command_buffer_begin | servers/rendering/rendering_device.cpp:8068 | 0.012 | 0.012 | 1.9 |
| _process | res://addons/xr_editor/tools/icons.gd:69 | 0.010 | 0.014 | 1.0 |
| _update_target_wires | res://addons/xr_editor/logic_graph/blueprints.gd:4161 | 0.010 | 0.018 | 1.0 |
| _process | res://addons/xr_editor/xr/session.gd:185 | 0.009 | 0.036 | 1.0 |

| GDScript file (own time, summed) | ms/frame |
|---|---|
| res://addons/xr_editor/telemetry/graph_lab.gd | 1.623 |
| res://addons/xr_editor/logic_graph/blueprints.gd | 0.108 |
| res://addons/xr_editor/core/feature_settings.gd | 0.063 |
| res://addons/xr_editor/tools/manipulator.gd | 0.033 |
| res://addons/xr_editor/xr/rig.gd | 0.032 |
| res://addons/xr_editor/xr/hand.gd | 0.031 |
| res://addons/xr_editor/logic_graph/blueprint_canvas.gd | 0.030 |
| res://addons/xr_editor/xr/session.gd | 0.025 |
| res://addons/xr_editor/ui/panels.gd | 0.021 |
| res://addons/xr_editor/tools/locomotion.gd | 0.016 |
| res://addons/xr_editor/tools/icons.gd | 0.015 |
| res://addons/xr_editor/tools/outline.gd | 0.012 |
| res://addons/blueprints/graph.gd | 0.011 |
| res://addons/xr_editor/tools/selection_counter.gd | 0.010 |
| res://addons/xr_editor/xr/desktop_ui.gd | 0.008 |
| res://addons/xr_editor/ui/palette.gd | 0.007 |
| res://addons/xr_editor/playmode/play_mode.gd | 0.006 |
| res://addons/xr_editor/tools/clipboard.gd | 0.006 |
| res://addons/xr_editor/ui/virtual_keyboard.gd | 0.004 |
| res://addons/xr_editor/logic_graph/blueprint_petals.gd | 0.004 |
| res://addons/xr_editor/ui/panel_surface.gd | 0.003 |
| res://addons/xr_editor/logic_graph/blueprint_badge.gd | 0.003 |
| res://addons/xr_editor/telemetry/fps_history.gd | 0.002 |
| res://addons/xr_editor/playmode/transition_screen.gd | 0.002 |
| res://addons/blueprints/functions.gd | 0.002 |
