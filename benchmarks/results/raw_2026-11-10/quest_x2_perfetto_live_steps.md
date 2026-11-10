
benchmarks/results/raw_2026-11-10/quest_x2_perfetto_live.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 7 | 72 | 0 | 8.18 | 13.9 | 0.71 | 441 | 2/2 | 3 | 10 |
| open | 8 | 70 | 2 | 12.69 | 15.0 | 0.96 | 525 | 2/4 | 3 | 327 |
| open_big2 | 8 | 52 | 20 | 16.62 | 19.9 | 0.96 | 525 | 5/4 | 3 | 589 |
| open | 7 | 72 | 0 | 12.41 | 14.7 | 0.99 | 525 | 2/4 | 3 | 327 |
| open_big2 | 7 | 51 | 21 | 16.84 | 21.1 | 0.96 | 525 | 5/4 | 3 | 589 |
| closed | 7 | 72 | 0 | 8.32 | 14.1 | 0.72 | 441 | 2/2 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.33 | 5.54 | 5 | 5 | 50 | 5 | 0 |
| closed | root | 0.04 | 1.90 | 0 | 0 | 0 | 0 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | XRESession/XREViewport | 1.20 | 10.59 | 302 | 302 | 80112 | 5 | 0 |
| open | root | 0.04 | 1.54 | 0 | 0 | 0 | 0 | 0 |
| open | Badge/Viewport | 0.13 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | XRESession/XREViewport | 1.56 | 15.53 | 564 | 564 | 155162 | 5 | 0 |
| open_big2 | root | 0.03 | 1.29 | 0 | 0 | 0 | 0 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.06 | 0.19 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.11 | 0.10 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | XRESession/XREViewport | 1.22 | 11.01 | 302 | 302 | 80084 | 5 | 0 |
| open | root | 0.04 | 1.19 | 0 | 0 | 0 | 0 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.21 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.12 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | XRESession/XREViewport | 1.59 | 15.54 | 564 | 564 | 155182 | 5 | 0 |
| open_big2 | root | 0.03 | 1.30 | 0 | 0 | 0 | 0 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.06 | 0.18 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.11 | 0.11 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | XRESession/XREViewport | 0.42 | 6.10 | 6 | 6 | 62 | 5 | 0 |
| closed | root | 0.04 | 1.56 | 0 | 0 | 0 | 0 | 0 |
| closed | Badge/Viewport | 0.15 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |

Plugin scripts, the step's last lab report (ms per frame):
| Step | n | graph scripts | facing | ray routing | manipulator | process (lab) |
|---|---|---|---|---|---|---|
| 01 closed | 1 | 0.32 | 0.00 | 0.03 | 0.28 | 20.29 |
| 02 open | 1 | 1.94 | 0.27 | 0.97 | 0.34 | 29.47 |
| 03 open_big2 | 1 | 1.83 | 0.31 | 1.01 | 0.27 | 29.28 |
| 04 open | 1 | 1.96 | 0.27 | 0.93 | 0.34 | 27.82 |
| 05 open_big2 | 1 | 1.82 | 0.31 | 1.02 | 0.27 | 29.23 |
| 06 closed | 1 | 0.38 | 0.00 | 0.03 | 0.38 | 25.29 |

Perfetto zones (benchmarks/perfetto_steps.py logs/quest_2026-11-10T19-03-09, D-162: category godot only):

### 01 closed

Slices without an end, left out: 3.
Thread VkThread: frames 210, mean Main::iteration 14.01 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | godot | 5.385 | 5.385 | 1.0 |
| rasterizer->blit_render_targets_to_screen | godot | 3.423 | 3.423 | 1.0 |
| process | godot | 2.415 | 2.415 | 1.0 |
| draw_graph.end | godot | 0.796 | 0.796 | 1.0 |
| render viewport | godot | 0.374 | 0.379 | 15.1 |
| extension wrappers on_process | godot | 0.332 | 0.332 | 1.0 |
| _execute_frame | godot | 0.304 | 0.304 | 1.0 |
| xr_server->_process | godot | 0.267 | 6.009 | 1.0 |
| xr_server->end_frame | godot | 0.236 | 0.236 | 1.0 |
| physics_process | godot | 0.086 | 0.086 | 0.9 |
| driver->command_pool_reset | godot | 0.068 | 0.068 | 1.0 |
| xr_server->pre_render | godot | 0.063 | 0.063 | 1.0 |
| scene->update | godot | 0.032 | 0.032 | 1.0 |
| RenderingServer::draw | godot | 0.028 | 5.437 | 1.0 |

### 02 open

Slices without an end, left out: 3.
Thread VkThread: frames 210, mean Main::iteration 14.18 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 4.515 | 4.515 | 1.0 |
| draw_graph.end | godot | 3.307 | 3.307 | 1.0 |
| _execute_frame | godot | 2.987 | 2.987 | 1.0 |
| render viewport | godot | 1.325 | 1.491 | 17.1 |
| rasterizer->blit_render_targets_to_screen | godot | 0.386 | 0.386 | 1.0 |
| xr_server->end_frame | godot | 0.276 | 0.276 | 1.0 |
| extension wrappers on_process | godot | 0.274 | 0.274 | 1.0 |
| driver->command_pool_reset | godot | 0.237 | 0.237 | 1.0 |
| xr_server->_process | godot | 0.231 | 0.584 | 1.0 |
| OpenXR: acquire swapchain | godot | 0.167 | 0.167 | 1.0 |
| xr_server->pre_render | godot | 0.090 | 0.090 | 1.0 |
| physics_process | godot | 0.072 | 0.072 | 0.9 |
| xrWaitFrame | godot | 0.062 | 0.062 | 1.0 |
| scene->update | godot | 0.038 | 0.038 | 1.0 |

### 03 open_big2

Slices without an end, left out: 6.
Thread VkThread: frames 154, mean Main::iteration 19.31 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 4.986 | 4.986 | 1.0 |
| _execute_frame | godot | 4.637 | 4.637 | 1.0 |
| draw_graph.end | godot | 4.492 | 4.492 | 1.0 |
| rasterizer->blit_render_targets_to_screen | godot | 1.912 | 1.912 | 1.0 |
| render viewport | godot | 1.772 | 1.791 | 17.1 |
| driver->command_pool_reset | godot | 0.321 | 0.321 | 1.0 |
| xr_server->end_frame | godot | 0.249 | 0.249 | 1.0 |
| extension wrappers on_process | godot | 0.240 | 0.240 | 1.0 |
| xr_server->_process | godot | 0.211 | 0.603 | 1.0 |
| xrWaitFrame | godot | 0.136 | 0.136 | 1.0 |
| physics_process | godot | 0.080 | 0.080 | 1.2 |
| xr_server->pre_render | godot | 0.068 | 0.068 | 1.0 |
| scene->update | godot | 0.035 | 0.035 | 1.0 |
| OpenXR: acquire swapchain | godot | 0.020 | 0.020 | 1.0 |

### 04 open

Slices without an end, left out: 3.
Thread VkThread: frames 208, mean Main::iteration 14.35 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.207 | 5.207 | 1.0 |
| draw_graph.end | godot | 3.735 | 3.735 | 1.0 |
| _execute_frame | godot | 1.929 | 1.929 | 1.0 |
| render viewport | godot | 1.491 | 1.535 | 17.0 |
| extension wrappers on_process | godot | 0.297 | 0.297 | 1.0 |
| rasterizer->blit_render_targets_to_screen | godot | 0.295 | 0.295 | 1.0 |
| xr_server->end_frame | godot | 0.278 | 0.278 | 1.0 |
| driver->command_pool_reset | godot | 0.256 | 0.256 | 1.0 |
| xr_server->_process | godot | 0.248 | 0.663 | 1.0 |
| xrWaitFrame | godot | 0.098 | 0.098 | 1.0 |
| xr_server->pre_render | godot | 0.080 | 0.080 | 1.0 |
| physics_process | godot | 0.073 | 0.073 | 0.9 |
| OpenXR: acquire swapchain | godot | 0.044 | 0.044 | 1.0 |
| scene->update | godot | 0.040 | 0.040 | 1.0 |

### 05 open_big2

Slices without an end, left out: 6.
Thread VkThread: frames 146, mean Main::iteration 20.33 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.101 | 5.101 | 1.0 |
| draw_graph.end | godot | 4.719 | 4.719 | 1.0 |
| _execute_frame | godot | 4.186 | 4.186 | 1.0 |
| rasterizer->blit_render_targets_to_screen | godot | 3.057 | 3.057 | 1.0 |
| render viewport | godot | 1.854 | 1.860 | 17.2 |
| driver->command_pool_reset | godot | 0.306 | 0.306 | 1.0 |
| xr_server->end_frame | godot | 0.241 | 0.241 | 1.0 |
| extension wrappers on_process | godot | 0.232 | 0.232 | 1.0 |
| xr_server->_process | godot | 0.208 | 0.604 | 1.0 |
| xrWaitFrame | godot | 0.148 | 0.148 | 1.0 |
| physics_process | godot | 0.082 | 0.082 | 1.2 |
| xr_server->pre_render | godot | 0.070 | 0.070 | 1.0 |
| scene->update | godot | 0.035 | 0.035 | 1.0 |
| frame_profile | godot | 0.017 | 0.017 | 1.0 |

### 06 closed

Slices without an end, left out: 3.
Thread VkThread: frames 210, mean Main::iteration 14.18 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | godot | 4.700 | 4.700 | 1.0 |
| process | godot | 3.343 | 3.343 | 1.0 |
| rasterizer->blit_render_targets_to_screen | godot | 2.865 | 2.865 | 1.0 |
| draw_graph.end | godot | 1.011 | 1.011 | 1.0 |
| render viewport | godot | 0.466 | 0.472 | 15.1 |
| _execute_frame | godot | 0.355 | 0.355 | 1.0 |
| extension wrappers on_process | godot | 0.353 | 0.353 | 1.0 |
| xr_server->_process | godot | 0.287 | 5.363 | 1.0 |
| xr_server->end_frame | godot | 0.262 | 0.262 | 1.0 |
| physics_process | godot | 0.098 | 0.098 | 0.9 |
| driver->command_pool_reset | godot | 0.090 | 0.090 | 1.0 |
| xr_server->pre_render | godot | 0.071 | 0.071 | 1.0 |
| scene->update | godot | 0.039 | 0.039 | 1.0 |
| RenderingServer::draw | godot | 0.018 | 5.316 | 1.0 |

| Step | Main::iteration | xrWaitFrame | driver->fence_wait | driver->command_buffer_end | process | RenderingServer::draw | draw_graph.end | _execute_frame | render viewport | extension wrappers on_process |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 14.008 | 5.385 | 0.005 | 0.007 | 2.415 | 5.437 | 0.796 | 0.304 | 0.379 | 0.332 |
| open | 14.175 | 0.062 | 0.008 | 0.011 | 4.515 | 8.975 | 3.307 | 2.987 | 1.491 | 0.274 |
| open_big2 | 19.305 | 0.136 | 0.008 | 0.009 | 4.986 | 13.594 | 4.492 | 4.637 | 1.791 | 0.240 |
| open | 14.349 | 0.098 | 0.008 | 0.012 | 5.207 | 8.324 | 3.735 | 1.929 | 1.535 | 0.297 |
| open_big2 | 20.331 | 0.148 | 0.008 | 0.010 | 5.101 | 14.599 | 4.719 | 4.186 | 1.860 | 0.232 |
| closed | 14.179 | 4.700 | 0.005 | 0.010 | 3.343 | 5.316 | 1.011 | 0.355 | 0.472 | 0.353 |
