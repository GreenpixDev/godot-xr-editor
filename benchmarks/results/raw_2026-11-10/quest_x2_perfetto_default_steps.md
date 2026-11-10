
benchmarks/results/raw_2026-11-10/quest_x2_perfetto_default.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| open | 8 | 72 | 0 | 9.95 | 13.1 | 0.81 | 525 | 2/4 | 3 | 327 |
| open_big2 | 7 | 63 | 9 | 13.75 | 15.8 | 0.97 | 525 | 3/4 | 3 | 589 |
| open | 7 | 72 | 0 | 9.77 | 12.9 | 0.80 | 525 | 2/4 | 3 | 327 |
| open_big2 | 8 | 64 | 8 | 13.85 | 16.3 | 0.97 | 525 | 3/4 | 3 | 589 |
| closed | 7 | 72 | 0 | 5.72 | 5.7 | 0.53 | 441 | 2/2 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| open | XRESession/XREViewport | 1.26 | 11.11 | 302 | 302 | 80112 | 5 | 0 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.77 | 15.17 | 564 | 564 | 155162 | 5 | 0 |
| open_big2 | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | FunctionsWindow/Viewport | 0.06 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 1.32 | 10.94 | 302 | 302 | 80116 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.71 | 15.26 | 564 | 564 | 155182 | 5 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.06 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.36 | 6.45 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |

Plugin scripts, the step's last lab report (ms per frame):
| Step | n | graph scripts | facing | ray routing | manipulator | process (lab) |
|---|---|---|---|---|---|---|
| 01 open | 1 | 1.90 | 0.26 | 0.91 | 0.33 | 25.44 |
| 02 open_big2 | 1 | 2.15 | 0.37 | 1.20 | 0.31 | 28.46 |
| 03 open | 1 | 1.93 | 0.26 | 0.92 | 0.33 | 25.60 |
| 04 open_big2 | 1 | 1.99 | 0.33 | 1.10 | 0.28 | 25.57 |
| 05 closed | 1 | 0.41 | 0.00 | 0.03 | 0.37 | 17.82 |

Perfetto zones (benchmarks/perfetto_steps.py logs/quest_2026-11-10T18-56-08, D-162: category godot only):

### 01 open

Slices without an end, left out: 3.
Thread VkThread: frames 207, mean Main::iteration 13.86 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.021 | 5.021 | 1.0 |
| driver->command_buffer_end | godot | 2.339 | 2.339 | 1.0 |
| xrWaitFrame | godot | 1.856 | 1.856 | 1.0 |
| draw_graph.end | godot | 1.543 | 1.543 | 1.0 |
| render viewport | godot | 1.504 | 1.511 | 17.0 |
| extension wrappers on_process | godot | 0.300 | 0.300 | 1.0 |
| xr_server->end_frame | godot | 0.277 | 0.277 | 1.0 |
| xr_server->_process | godot | 0.243 | 2.421 | 1.0 |
| driver->command_pool_reset | godot | 0.228 | 0.228 | 1.0 |
| _execute_frame | godot | 0.103 | 0.103 | 1.0 |
| xr_server->pre_render | godot | 0.078 | 0.078 | 1.0 |
| physics_process | godot | 0.076 | 0.076 | 0.8 |
| scene->update | godot | 0.036 | 0.036 | 1.0 |
| render viewports | godot | 0.022 | 1.533 | 1.0 |

### 02 open_big2

Slices without an end, left out: 6.
Thread VkThread: frames 187, mean Main::iteration 15.88 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.789 | 5.789 | 1.0 |
| driver->command_buffer_end | godot | 3.210 | 3.210 | 1.0 |
| render viewport | godot | 2.023 | 2.029 | 17.2 |
| draw_graph.end | godot | 1.896 | 1.896 | 1.0 |
| driver->fence_wait | godot | 1.374 | 1.374 | 1.0 |
| driver->command_pool_reset | godot | 0.343 | 0.343 | 1.0 |
| xr_server->end_frame | godot | 0.252 | 0.252 | 1.0 |
| extension wrappers on_process | godot | 0.246 | 0.246 | 1.0 |
| xr_server->_process | godot | 0.223 | 0.526 | 1.0 |
| _execute_frame | godot | 0.118 | 0.118 | 1.0 |
| physics_process | godot | 0.081 | 0.081 | 1.0 |
| xr_server->pre_render | godot | 0.073 | 0.073 | 1.0 |
| xrWaitFrame | godot | 0.039 | 0.039 | 1.0 |
| scene->update | godot | 0.035 | 0.035 | 1.0 |

### 03 open

Slices without an end, left out: 6.
Thread VkThread: frames 209, mean Main::iteration 14.21 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.370 | 5.370 | 1.0 |
| driver->command_buffer_end | godot | 2.256 | 2.256 | 1.0 |
| xrWaitFrame | godot | 1.905 | 1.905 | 1.0 |
| render viewport | godot | 1.592 | 1.599 | 17.2 |
| draw_graph.end | godot | 1.526 | 1.526 | 1.0 |
| extension wrappers on_process | godot | 0.294 | 0.294 | 1.0 |
| xr_server->end_frame | godot | 0.277 | 0.277 | 1.0 |
| driver->command_pool_reset | godot | 0.249 | 0.249 | 1.0 |
| xr_server->_process | godot | 0.248 | 2.468 | 1.0 |
| _execute_frame | godot | 0.098 | 0.098 | 1.0 |
| physics_process | godot | 0.078 | 0.078 | 0.9 |
| xr_server->pre_render | godot | 0.078 | 0.078 | 1.0 |
| scene->update | godot | 0.037 | 0.037 | 1.0 |
| render viewports | godot | 0.022 | 1.621 | 1.0 |

### 04 open_big2

Slices without an end, left out: 6.
Thread VkThread: frames 187, mean Main::iteration 15.94 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.697 | 5.697 | 1.0 |
| driver->command_buffer_end | godot | 3.155 | 3.155 | 1.0 |
| render viewport | godot | 2.053 | 2.068 | 17.1 |
| draw_graph.end | godot | 1.933 | 1.933 | 1.0 |
| driver->fence_wait | godot | 1.468 | 1.468 | 1.0 |
| driver->command_pool_reset | godot | 0.338 | 0.338 | 1.0 |
| xr_server->end_frame | godot | 0.258 | 0.258 | 1.0 |
| extension wrappers on_process | godot | 0.253 | 0.253 | 1.0 |
| xr_server->_process | godot | 0.222 | 0.532 | 1.0 |
| _execute_frame | godot | 0.120 | 0.120 | 1.0 |
| physics_process | godot | 0.083 | 0.083 | 1.0 |
| xr_server->pre_render | godot | 0.073 | 0.073 | 1.0 |
| xrWaitFrame | godot | 0.040 | 0.040 | 1.0 |
| scene->update | godot | 0.035 | 0.035 | 1.0 |

### 05 closed

Slices without an end, left out: 5.
Thread VkThread: frames 210, mean Main::iteration 14.14 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | godot | 8.507 | 8.507 | 1.0 |
| process | godot | 2.935 | 2.935 | 1.0 |
| driver->command_buffer_end | godot | 0.637 | 0.637 | 1.0 |
| render viewport | godot | 0.401 | 0.407 | 15.1 |
| extension wrappers on_process | godot | 0.284 | 0.284 | 1.0 |
| draw_graph.end | godot | 0.282 | 0.282 | 1.0 |
| xr_server->end_frame | godot | 0.262 | 0.262 | 1.0 |
| xr_server->_process | godot | 0.240 | 9.053 | 1.0 |
| _execute_frame | godot | 0.083 | 0.083 | 1.0 |
| physics_process | godot | 0.075 | 0.075 | 0.9 |
| driver->command_pool_reset | godot | 0.073 | 0.073 | 1.0 |
| xr_server->pre_render | godot | 0.070 | 0.070 | 1.0 |
| scene->update | godot | 0.037 | 0.037 | 1.0 |
| driver->fence_wait | godot | 0.029 | 0.029 | 1.0 |

| Step | Main::iteration | xrWaitFrame | driver->fence_wait | driver->command_buffer_end | process | RenderingServer::draw | draw_graph.end | _execute_frame | render viewport | extension wrappers on_process |
|---|---|---|---|---|---|---|---|---|---|---|
| open | 13.865 | 1.856 | 0.020 | 2.339 | 5.021 | 6.272 | 1.543 | 0.103 | 1.511 | 0.300 |
| open_big2 | 15.882 | 0.039 | 1.374 | 3.210 | 5.789 | 9.475 | 1.896 | 0.118 | 2.029 | 0.246 |
| open | 14.214 | 1.905 | 0.020 | 2.256 | 5.370 | 6.280 | 1.526 | 0.098 | 1.599 | 0.294 |
| open_big2 | 15.936 | 0.040 | 1.468 | 3.155 | 5.697 | 9.569 | 1.933 | 0.120 | 2.068 | 0.253 |
| closed | 14.141 | 8.507 | 0.029 | 0.637 | 2.935 | 2.013 | 0.282 | 0.083 | 0.407 | 0.284 |
