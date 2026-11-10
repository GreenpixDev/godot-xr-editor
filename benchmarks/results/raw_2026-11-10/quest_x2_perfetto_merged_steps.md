
benchmarks/results/raw_2026-11-10/quest_x2_perfetto_merged.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 7 | 72 | 0 | 5.67 | 5.2 | 0.53 | 525 | 2/2 | 3 | 10 |
| open | 8 | 72 | 0 | 9.77 | 12.9 | 0.79 | 441 | 3/4 | 3 | 293 |
| open_big2 | 8 | 64 | 8 | 13.50 | 16.3 | 0.95 | 525 | 2/4 | 3 | 521 |
| open | 7 | 72 | 0 | 9.71 | 12.8 | 0.80 | 525 | 2/4 | 3 | 293 |
| open_big2 | 7 | 66 | 6 | 13.45 | 15.6 | 0.97 | 525 | 5/4 | 3 | 521 |
| closed | 7 | 72 | 0 | 5.71 | 5.7 | 0.53 | 525 | 2/2 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.31 | 6.42 | 5 | 5 | 50 | 5 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 1.30 | 10.94 | 268 | 268 | 80112 | 5 | 0 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.91 | 14.84 | 496 | 496 | 155158 | 5 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.07 | 0.15 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.12 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 1.35 | 10.78 | 268 | 268 | 80080 | 5 | 0 |
| open | Badge/Viewport | 0.13 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.79 | 14.75 | 496 | 496 | 155182 | 5 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.06 | 0.14 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.36 | 6.45 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |

Plugin scripts, the step's last lab report (ms per frame):
| Step | n | graph scripts | facing | ray routing | manipulator | process (lab) |
|---|---|---|---|---|---|---|
| 01 closed | 1 | 0.31 | 0.00 | 0.03 | 0.28 | 14.95 |
| 02 open | 1 | 1.89 | 0.27 | 0.92 | 0.33 | 25.24 |
| 03 open_big2 | 1 | 2.37 | 0.41 | 1.31 | 0.33 | 27.67 |
| 04 open | 1 | 1.88 | 0.26 | 0.92 | 0.33 | 25.12 |
| 05 open_big2 | 1 | 2.10 | 0.36 | 1.18 | 0.30 | 24.65 |
| 06 closed | 1 | 0.39 | 0.00 | 0.03 | 0.37 | 17.83 |

Perfetto zones (benchmarks/perfetto_steps.py logs/quest_2026-11-10T18-59-45, D-162: category godot only):

### 01 closed

Slices without an end, left out: 5.
Thread VkThread: frames 207, mean Main::iteration 14.08 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | godot | 9.339 | 9.339 | 1.0 |
| process | godot | 2.467 | 2.467 | 1.0 |
| driver->command_buffer_end | godot | 0.496 | 0.496 | 1.0 |
| render viewport | godot | 0.333 | 0.338 | 15.1 |
| extension wrappers on_process | godot | 0.257 | 0.257 | 1.0 |
| draw_graph.end | godot | 0.239 | 0.239 | 1.0 |
| xr_server->end_frame | godot | 0.223 | 0.223 | 1.0 |
| xr_server->_process | godot | 0.211 | 9.834 | 1.0 |
| _execute_frame | godot | 0.075 | 0.075 | 1.0 |
| physics_process | godot | 0.064 | 0.064 | 0.9 |
| xr_server->pre_render | godot | 0.061 | 0.061 | 1.0 |
| driver->command_pool_reset | godot | 0.056 | 0.056 | 1.0 |
| driver->fence_wait | godot | 0.047 | 0.047 | 1.0 |
| scene->update | godot | 0.030 | 0.030 | 1.0 |

### 02 open

Slices without an end, left out: 3.
Thread VkThread: frames 214, mean Main::iteration 13.87 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 4.969 | 4.969 | 1.0 |
| xrWaitFrame | godot | 2.240 | 2.240 | 1.0 |
| driver->command_buffer_end | godot | 2.071 | 2.071 | 1.0 |
| render viewport | godot | 1.557 | 1.564 | 17.1 |
| draw_graph.end | godot | 1.501 | 1.501 | 1.0 |
| extension wrappers on_process | godot | 0.282 | 0.282 | 1.0 |
| xr_server->end_frame | godot | 0.269 | 0.269 | 1.0 |
| driver->command_pool_reset | godot | 0.241 | 0.241 | 1.0 |
| xr_server->_process | godot | 0.240 | 2.782 | 1.0 |
| _execute_frame | godot | 0.112 | 0.112 | 1.0 |
| xr_server->pre_render | godot | 0.080 | 0.080 | 1.0 |
| physics_process | godot | 0.072 | 0.072 | 0.8 |
| scene->update | godot | 0.038 | 0.038 | 1.0 |
| driver->fence_wait | godot | 0.019 | 0.019 | 1.0 |

### 03 open_big2

Slices without an end, left out: 3.
Thread VkThread: frames 190, mean Main::iteration 15.68 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.926 | 5.926 | 1.0 |
| driver->command_buffer_end | godot | 3.416 | 3.416 | 1.0 |
| render viewport | godot | 2.068 | 2.075 | 17.0 |
| draw_graph.end | godot | 2.004 | 2.004 | 1.0 |
| driver->fence_wait | godot | 0.579 | 0.579 | 1.0 |
| driver->command_pool_reset | godot | 0.344 | 0.344 | 1.0 |
| xr_server->end_frame | godot | 0.264 | 0.264 | 1.0 |
| extension wrappers on_process | godot | 0.261 | 0.261 | 1.0 |
| xr_server->_process | godot | 0.227 | 0.544 | 1.0 |
| _execute_frame | godot | 0.136 | 0.136 | 1.0 |
| physics_process | godot | 0.079 | 0.079 | 0.9 |
| xr_server->pre_render | godot | 0.074 | 0.074 | 1.0 |
| scene->update | godot | 0.038 | 0.038 | 1.0 |
| xrWaitFrame | godot | 0.038 | 0.038 | 1.0 |

### 04 open

Slices without an end, left out: 6.
Thread VkThread: frames 209, mean Main::iteration 14.21 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.331 | 5.331 | 1.0 |
| driver->command_buffer_end | godot | 2.167 | 2.167 | 1.0 |
| xrWaitFrame | godot | 2.109 | 2.109 | 1.0 |
| draw_graph.end | godot | 1.547 | 1.547 | 1.0 |
| render viewport | godot | 1.526 | 1.533 | 17.1 |
| extension wrappers on_process | godot | 0.288 | 0.288 | 1.0 |
| xr_server->end_frame | godot | 0.270 | 0.270 | 1.0 |
| xr_server->_process | godot | 0.246 | 2.663 | 1.0 |
| driver->command_pool_reset | godot | 0.243 | 0.243 | 1.0 |
| _execute_frame | godot | 0.106 | 0.106 | 1.0 |
| xr_server->pre_render | godot | 0.078 | 0.078 | 1.0 |
| physics_process | godot | 0.076 | 0.076 | 0.9 |
| scene->update | godot | 0.038 | 0.038 | 1.0 |
| driver->fence_wait | godot | 0.019 | 0.019 | 1.0 |

### 05 open_big2

Slices without an end, left out: 6.
Thread VkThread: frames 195, mean Main::iteration 15.33 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.430 | 5.430 | 1.0 |
| driver->command_buffer_end | godot | 2.983 | 2.983 | 1.0 |
| render viewport | godot | 1.987 | 1.994 | 17.1 |
| draw_graph.end | godot | 1.889 | 1.889 | 1.0 |
| driver->fence_wait | godot | 1.515 | 1.515 | 1.0 |
| driver->command_pool_reset | godot | 0.305 | 0.305 | 1.0 |
| xr_server->end_frame | godot | 0.245 | 0.245 | 1.0 |
| extension wrappers on_process | godot | 0.244 | 0.244 | 1.0 |
| xr_server->_process | godot | 0.216 | 0.510 | 1.0 |
| _execute_frame | godot | 0.121 | 0.121 | 1.0 |
| physics_process | godot | 0.074 | 0.074 | 0.9 |
| xr_server->pre_render | godot | 0.071 | 0.071 | 1.0 |
| scene->update | godot | 0.037 | 0.037 | 1.0 |
| xrWaitFrame | godot | 0.033 | 0.033 | 1.0 |

### 06 closed

Slices without an end, left out: 3.
Thread VkThread: frames 210, mean Main::iteration 14.14 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | godot | 8.541 | 8.541 | 1.0 |
| process | godot | 2.944 | 2.944 | 1.0 |
| driver->command_buffer_end | godot | 0.635 | 0.635 | 1.0 |
| render viewport | godot | 0.407 | 0.413 | 15.1 |
| extension wrappers on_process | godot | 0.300 | 0.300 | 1.0 |
| draw_graph.end | godot | 0.280 | 0.280 | 1.0 |
| xr_server->end_frame | godot | 0.259 | 0.259 | 1.0 |
| xr_server->_process | godot | 0.245 | 9.110 | 1.0 |
| _execute_frame | godot | 0.075 | 0.075 | 1.0 |
| physics_process | godot | 0.074 | 0.074 | 0.9 |
| driver->command_pool_reset | godot | 0.073 | 0.073 | 1.0 |
| xr_server->pre_render | godot | 0.071 | 0.071 | 1.0 |
| scene->update | godot | 0.036 | 0.036 | 1.0 |
| driver->fence_wait | godot | 0.029 | 0.029 | 1.0 |

| Step | Main::iteration | xrWaitFrame | driver->fence_wait | driver->command_buffer_end | process | RenderingServer::draw | draw_graph.end | _execute_frame | render viewport | extension wrappers on_process |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 14.082 | 9.339 | 0.047 | 0.496 | 2.467 | 1.699 | 0.239 | 0.075 | 0.338 | 0.257 |
| open | 13.875 | 2.240 | 0.019 | 2.071 | 4.969 | 6.034 | 1.501 | 0.112 | 1.564 | 0.282 |
| open_big2 | 15.680 | 0.038 | 0.579 | 3.416 | 5.926 | 9.049 | 2.004 | 0.136 | 2.075 | 0.261 |
| open | 14.209 | 2.109 | 0.019 | 2.167 | 5.331 | 6.145 | 1.547 | 0.106 | 1.533 | 0.288 |
| open_big2 | 15.331 | 0.033 | 1.515 | 2.983 | 5.430 | 9.273 | 1.889 | 0.121 | 1.994 | 0.244 |
| closed | 14.141 | 8.541 | 0.029 | 0.635 | 2.944 | 1.995 | 0.280 | 0.075 | 0.413 | 0.300 |
