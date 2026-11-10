
### 01 closed

Slices without an end, left out: 5.
Thread VkThread: frames 206, mean Main::iteration 14.13 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 6.963 | 6.963 | 1.0 |
| xrWaitFrame | godot | 3.775 | 3.775 | 1.0 |
| draw_graph.end | godot | 0.945 | 0.945 | 1.0 |
| render viewport | godot | 0.428 | 0.434 | 15.1 |
| rasterizer->blit_render_targets_to_screen | godot | 0.404 | 0.404 | 1.0 |
| _execute_frame | godot | 0.353 | 0.353 | 1.0 |
| extension wrappers on_process | godot | 0.293 | 0.293 | 1.0 |
| xr_server->end_frame | godot | 0.256 | 0.256 | 1.0 |
| xr_server->_process | godot | 0.239 | 4.328 | 1.0 |
| physics_process | godot | 0.081 | 0.081 | 0.9 |

### 02 open

Slices without an end, left out: 5.
Thread VkThread: frames 182, mean Main::iteration 16.30 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 7.418 | 7.418 | 1.0 |
| draw_graph.end | godot | 3.828 | 3.828 | 1.0 |
| render viewport | godot | 1.566 | 1.573 | 17.2 |
| _execute_frame | godot | 1.300 | 1.300 | 1.0 |
| rasterizer->blit_render_targets_to_screen | godot | 0.933 | 0.933 | 1.0 |
| driver->command_pool_reset | godot | 0.246 | 0.246 | 1.0 |
| xr_server->end_frame | godot | 0.246 | 0.246 | 1.0 |
| extension wrappers on_process | godot | 0.221 | 0.221 | 1.0 |
| xr_server->_process | godot | 0.196 | 0.477 | 1.0 |
| physics_process | godot | 0.075 | 0.075 | 1.0 |

### 03 open_graph100

Slices without an end, left out: 3.
Thread VkThread: frames 100, mean Main::iteration 29.02 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 12.000 | 12.000 | 1.0 |
| draw_graph.end | godot | 8.700 | 8.700 | 1.0 |
| render viewport | godot | 3.418 | 3.425 | 17.0 |
| _execute_frame | godot | 3.080 | 3.080 | 1.0 |
| driver->command_pool_reset | godot | 0.536 | 0.536 | 1.0 |
| xr_server->end_frame | godot | 0.262 | 0.262 | 1.0 |
| extension wrappers on_process | godot | 0.221 | 0.221 | 1.0 |
| xr_server->_process | godot | 0.195 | 0.541 | 1.0 |
| rasterizer->blit_render_targets_to_screen | godot | 0.147 | 0.147 | 1.0 |
| xrWaitFrame | godot | 0.110 | 0.110 | 1.0 |

### 04 open_graph250

Slices without an end, left out: 3.
Thread VkThread: frames 50, mean Main::iteration 58.78 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| draw_graph.end | godot | 21.892 | 21.892 | 1.0 |
| process | godot | 21.450 | 21.450 | 1.0 |
| render viewport | godot | 7.908 | 7.914 | 17.3 |
| _execute_frame | godot | 5.639 | 5.639 | 1.0 |
| driver->command_pool_reset | godot | 1.100 | 1.100 | 1.0 |
| xrWaitFrame | godot | 0.313 | 0.313 | 1.0 |
| xr_server->end_frame | godot | 0.285 | 0.285 | 1.0 |
| extension wrappers on_process | godot | 0.228 | 0.228 | 1.0 |
| xr_server->_process | godot | 0.199 | 0.756 | 1.0 |
| physics_process | godot | 0.089 | 0.089 | 3.6 |

### 05 open_graph500

Slices without an end, left out: 6.
No whole Main::iteration slice: the trace fell inside one long frame (a graph being built), or no engine zones reached it (see _perfetto_info.txt).

### 06 open

Slices without an end, left out: 3.
Thread VkThread: frames 180, mean Main::iteration 16.53 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 7.730 | 7.730 | 1.0 |
| draw_graph.end | godot | 4.093 | 4.093 | 1.0 |
| render viewport | godot | 1.806 | 1.813 | 17.1 |
| rasterizer->blit_render_targets_to_screen | godot | 0.880 | 0.880 | 1.0 |
| _execute_frame | godot | 0.677 | 0.677 | 1.0 |
| driver->command_pool_reset | godot | 0.255 | 0.255 | 1.0 |
| xr_server->end_frame | godot | 0.249 | 0.249 | 1.0 |
| extension wrappers on_process | godot | 0.219 | 0.219 | 1.0 |
| xr_server->_process | godot | 0.192 | 0.452 | 1.0 |
| xr_server->pre_render | godot | 0.080 | 0.080 | 1.0 |

### 07 closed

Slices without an end, left out: 5.
Thread VkThread: frames 211, mean Main::iteration 14.11 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 7.486 | 7.486 | 1.0 |
| xrWaitFrame | godot | 1.950 | 1.950 | 1.0 |
| rasterizer->blit_render_targets_to_screen | godot | 1.588 | 1.588 | 1.0 |
| draw_graph.end | godot | 0.987 | 0.987 | 1.0 |
| render viewport | godot | 0.504 | 0.511 | 15.1 |
| _execute_frame | godot | 0.326 | 0.326 | 1.0 |
| extension wrappers on_process | godot | 0.275 | 0.275 | 1.0 |
| xr_server->end_frame | godot | 0.265 | 0.265 | 1.0 |
| xr_server->_process | godot | 0.224 | 2.468 | 1.0 |
| driver->command_pool_reset | godot | 0.087 | 0.087 | 1.0 |

### 08 closed_scene1k

Slices without an end, left out: 6.
Thread VkThread: frames 105, mean Main::iteration 28.07 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| _execute_frame | godot | 13.809 | 13.809 | 1.0 |
| process | godot | 5.917 | 5.917 | 1.0 |
| render viewport | godot | 2.934 | 3.078 | 15.2 |
| draw_graph.end | godot | 2.395 | 2.395 | 1.0 |
| xrWaitFrame | godot | 1.801 | 1.801 | 1.0 |
| xr_server->end_frame | godot | 0.259 | 0.259 | 1.0 |
| extension wrappers on_process | godot | 0.253 | 0.253 | 1.0 |
| xr_server->_process | godot | 0.211 | 2.285 | 1.0 |
| rasterizer->blit_render_targets_to_screen | godot | 0.160 | 0.160 | 1.0 |
| OpenXR: acquire swapchain | godot | 0.144 | 0.144 | 1.0 |

### 09 closed_scene5k

Slices without an end, left out: 5.
Thread VkThread: frames 34, mean Main::iteration 83.48 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| _execute_frame | godot | 58.253 | 58.253 | 1.0 |
| render viewport | godot | 12.472 | 12.478 | 15.9 |
| draw_graph.end | godot | 7.443 | 7.443 | 1.1 |
| process | godot | 6.398 | 6.398 | 1.0 |
| xrWaitFrame | godot | 1.060 | 1.060 | 1.0 |
| xr_server->end_frame | godot | 0.277 | 0.277 | 1.0 |
| extension wrappers on_process | godot | 0.239 | 0.239 | 1.0 |
| xr_server->_process | godot | 0.206 | 1.525 | 1.0 |
| driver->command_pool_reset | godot | 0.106 | 0.106 | 1.0 |
| physics_process | godot | 0.097 | 0.097 | 5.2 |

### 10 closed_scene20k

Slices without an end, left out: 5.
Thread VkThread: frames 11, mean Main::iteration 253.80 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| _execute_frame | godot | 183.720 | 183.720 | 1.0 |
| render viewport | godot | 46.820 | 46.827 | 16.4 |
| draw_graph.end | godot | 22.311 | 22.311 | 1.1 |
| process | godot | 5.333 | 5.333 | 1.1 |
| xr_server->end_frame | godot | 0.442 | 0.442 | 1.1 |
| extension wrappers on_process | godot | 0.254 | 0.254 | 1.1 |
| xr_server->_process | godot | 0.215 | 0.521 | 1.1 |
| driver->command_pool_reset | godot | 0.130 | 0.130 | 1.1 |
| physics_process | godot | 0.114 | 0.114 | 8.7 |
| xr_server->pre_render | godot | 0.076 | 0.076 | 1.1 |

### 11 closed

Slices without an end, left out: 6.
Thread VkThread: frames 210, mean Main::iteration 14.14 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 7.387 | 7.387 | 1.0 |
| xrWaitFrame | godot | 1.980 | 1.980 | 1.0 |
| rasterizer->blit_render_targets_to_screen | godot | 1.586 | 1.586 | 1.0 |
| draw_graph.end | godot | 1.030 | 1.030 | 1.0 |
| render viewport | godot | 0.528 | 0.537 | 15.1 |
| _execute_frame | godot | 0.336 | 0.336 | 1.0 |
| extension wrappers on_process | godot | 0.278 | 0.278 | 1.0 |
| xr_server->end_frame | godot | 0.268 | 0.268 | 1.0 |
| xr_server->_process | godot | 0.241 | 2.517 | 1.0 |
| xr_server->pre_render | godot | 0.098 | 0.098 | 1.0 |

### 12 open_scene5k

Slices without an end, left out: 5.
Thread VkThread: frames 28, mean Main::iteration 100.76 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| _execute_frame | godot | 68.762 | 68.762 | 1.0 |
| render viewport | godot | 11.931 | 11.938 | 17.6 |
| draw_graph.end | godot | 9.287 | 9.287 | 1.0 |
| process | godot | 9.234 | 9.234 | 1.0 |
| xrWaitFrame | godot | 0.924 | 0.924 | 1.0 |
| driver->command_pool_reset | godot | 0.313 | 0.313 | 1.0 |
| xr_server->end_frame | godot | 0.307 | 0.307 | 1.0 |
| extension wrappers on_process | godot | 0.237 | 0.237 | 1.0 |
| xr_server->_process | godot | 0.200 | 1.380 | 1.0 |
| physics_process | godot | 0.099 | 0.099 | 6.2 |

### 13 open

Slices without an end, left out: 3.
Thread VkThread: frames 180, mean Main::iteration 16.55 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 7.629 | 7.629 | 1.0 |
| draw_graph.end | godot | 4.093 | 4.093 | 1.0 |
| render viewport | godot | 1.724 | 1.732 | 17.1 |
| rasterizer->blit_render_targets_to_screen | godot | 0.958 | 0.958 | 1.0 |
| _execute_frame | godot | 0.830 | 0.830 | 1.0 |
| driver->command_pool_reset | godot | 0.257 | 0.257 | 1.0 |
| xr_server->end_frame | godot | 0.246 | 0.246 | 1.0 |
| extension wrappers on_process | godot | 0.219 | 0.219 | 1.0 |
| xr_server->_process | godot | 0.194 | 0.471 | 1.0 |
| xr_server->pre_render | godot | 0.074 | 0.074 | 1.0 |

### 14 closed

Slices without an end, left out: 3.
Thread VkThread: frames 211, mean Main::iteration 14.10 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 7.529 | 7.529 | 1.0 |
| xrWaitFrame | godot | 1.902 | 1.902 | 1.0 |
| rasterizer->blit_render_targets_to_screen | godot | 1.620 | 1.620 | 1.0 |
| draw_graph.end | godot | 0.970 | 0.970 | 1.0 |
| render viewport | godot | 0.472 | 0.479 | 15.1 |
| _execute_frame | godot | 0.338 | 0.338 | 1.0 |
| extension wrappers on_process | godot | 0.275 | 0.275 | 1.0 |
| xr_server->end_frame | godot | 0.268 | 0.268 | 1.0 |
| xr_server->_process | godot | 0.227 | 2.423 | 1.0 |
| xr_server->pre_render | godot | 0.091 | 0.091 | 1.0 |
