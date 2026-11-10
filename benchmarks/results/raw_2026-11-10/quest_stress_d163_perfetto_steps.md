
### 01 closed

Slices without an end, left out: 5.
Thread VkThread: frames 211, mean Main::iteration 13.84 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | godot | 7.102 | 7.102 | 1.0 |
| process | godot | 3.290 | 3.290 | 1.0 |
| draw_graph.end | godot | 1.022 | 1.022 | 1.0 |
| render viewport | godot | 0.458 | 0.464 | 15.1 |
| extension wrappers on_process | godot | 0.394 | 0.394 | 1.0 |
| _execute_frame | godot | 0.369 | 0.369 | 1.0 |
| xr_server->_process | godot | 0.311 | 7.842 | 1.0 |
| xr_server->end_frame | godot | 0.274 | 0.274 | 1.0 |
| physics_process | godot | 0.110 | 0.110 | 0.8 |
| driver->command_pool_reset | godot | 0.080 | 0.080 | 1.0 |

### 02 open

Slices without an end, left out: 5.
Thread VkThread: frames 180, mean Main::iteration 16.54 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.662 | 5.662 | 1.0 |
| draw_graph.end | godot | 3.916 | 3.916 | 1.0 |
| _execute_frame | godot | 2.334 | 2.334 | 1.0 |
| render viewport | godot | 1.569 | 1.596 | 17.1 |
| rasterizer->blit_render_targets_to_screen | godot | 1.439 | 1.439 | 1.0 |
| xr_server->end_frame | godot | 0.406 | 0.406 | 1.0 |
| driver->command_pool_reset | godot | 0.294 | 0.294 | 1.0 |
| extension wrappers on_process | godot | 0.237 | 0.237 | 1.0 |
| xr_server->_process | godot | 0.208 | 0.522 | 1.0 |
| physics_process | godot | 0.077 | 0.077 | 1.0 |

### 03 open_graph100

Slices without an end, left out: 5.
Thread VkThread: frames 106, mean Main::iteration 27.95 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 8.937 | 8.937 | 1.0 |
| draw_graph.end | godot | 8.453 | 8.453 | 1.0 |
| _execute_frame | godot | 4.064 | 4.064 | 1.0 |
| render viewport | godot | 3.392 | 3.435 | 17.2 |
| rasterizer->blit_render_targets_to_screen | godot | 1.599 | 1.599 | 1.0 |
| driver->command_pool_reset | godot | 0.608 | 0.608 | 1.0 |
| xr_server->end_frame | godot | 0.255 | 0.255 | 1.0 |
| extension wrappers on_process | godot | 0.212 | 0.212 | 1.0 |
| xr_server->_process | godot | 0.193 | 0.444 | 1.0 |
| physics_process | godot | 0.078 | 0.078 | 1.7 |

### 04 open_graph250

Slices without an end, left out: 6.
Thread VkThread: frames 50, mean Main::iteration 58.34 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| draw_graph.end | godot | 21.711 | 21.711 | 1.0 |
| process | godot | 20.534 | 20.534 | 1.0 |
| render viewport | godot | 8.055 | 8.062 | 17.3 |
| _execute_frame | godot | 6.464 | 6.464 | 1.0 |
| driver->command_pool_reset | godot | 1.208 | 1.208 | 1.0 |
| xr_server->end_frame | godot | 0.283 | 0.283 | 1.0 |
| xrWaitFrame | godot | 0.256 | 0.256 | 1.0 |
| extension wrappers on_process | godot | 0.226 | 0.226 | 1.0 |
| xr_server->_process | godot | 0.207 | 0.704 | 1.0 |
| physics_process | godot | 0.088 | 0.088 | 3.6 |

### 05 open_graph500

Slices without an end, left out: 6.
Thread VkThread: frames 20, mean Main::iteration 146.64 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| draw_graph.end | godot | 49.670 | 49.670 | 1.0 |
| _execute_frame | godot | 45.302 | 45.302 | 1.1 |
| process | godot | 32.324 | 32.324 | 1.1 |
| render viewport | godot | 16.599 | 16.605 | 17.6 |
| driver->command_pool_reset | godot | 2.455 | 2.455 | 1.1 |
| _free_pending_resources | godot | 1.112 | 1.112 | 1.1 |
| xr_server->end_frame | godot | 0.422 | 0.422 | 1.1 |
| extension wrappers on_process | godot | 0.272 | 0.272 | 1.1 |
| xr_server->_process | godot | 0.242 | 0.563 | 1.1 |
| physics_process | godot | 0.127 | 0.127 | 8.4 |

### 06 open

Slices without an end, left out: 3.
Thread VkThread: frames 193, mean Main::iteration 15.44 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 4.824 | 4.824 | 1.0 |
| draw_graph.end | godot | 3.762 | 3.762 | 1.0 |
| _execute_frame | godot | 2.534 | 2.534 | 1.0 |
| render viewport | godot | 1.527 | 1.534 | 17.0 |
| rasterizer->blit_render_targets_to_screen | godot | 1.380 | 1.380 | 1.0 |
| driver->command_pool_reset | godot | 0.291 | 0.291 | 1.0 |
| xr_server->end_frame | godot | 0.253 | 0.253 | 1.0 |
| extension wrappers on_process | godot | 0.226 | 0.226 | 1.0 |
| xr_server->_process | godot | 0.196 | 0.468 | 1.0 |
| physics_process | godot | 0.071 | 0.071 | 0.9 |

### 07 closed

Slices without an end, left out: 3.
Thread VkThread: frames 216, mean Main::iteration 13.89 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| rasterizer->blit_render_targets_to_screen | godot | 7.433 | 7.433 | 1.0 |
| process | godot | 2.709 | 2.709 | 1.0 |
| draw_graph.end | godot | 1.038 | 1.038 | 1.0 |
| render viewport | godot | 0.545 | 0.553 | 15.0 |
| xrWaitFrame | godot | 0.476 | 0.476 | 1.0 |
| _execute_frame | godot | 0.347 | 0.347 | 1.0 |
| extension wrappers on_process | godot | 0.281 | 0.281 | 1.0 |
| xr_server->end_frame | godot | 0.280 | 0.280 | 1.0 |
| xr_server->_process | godot | 0.247 | 1.024 | 1.0 |
| driver->command_pool_reset | godot | 0.088 | 0.088 | 1.0 |

### 08 closed_scene1k

Slices without an end, left out: 3.
Thread VkThread: frames 107, mean Main::iteration 27.77 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| _execute_frame | godot | 15.340 | 15.340 | 1.0 |
| render viewport | godot | 2.943 | 3.513 | 15.0 |
| rasterizer->blit_render_targets_to_screen | godot | 2.470 | 2.470 | 1.0 |
| draw_graph.end | godot | 2.440 | 2.440 | 1.0 |
| process | godot | 2.351 | 2.351 | 1.0 |
| OpenXR: acquire swapchain | godot | 0.570 | 0.570 | 1.0 |
| xrWaitFrame | godot | 0.546 | 0.546 | 1.0 |
| xr_server->end_frame | godot | 0.265 | 0.265 | 1.0 |
| extension wrappers on_process | godot | 0.249 | 0.249 | 1.0 |
| xr_server->_process | godot | 0.215 | 1.028 | 1.0 |

### 09 closed_scene5k

Slices without an end, left out: 5.
Thread VkThread: frames 34, mean Main::iteration 84.30 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| _execute_frame | godot | 60.654 | 60.654 | 1.0 |
| render viewport | godot | 12.319 | 12.406 | 15.4 |
| draw_graph.end | godot | 7.705 | 7.705 | 1.0 |
| process | godot | 2.404 | 2.404 | 1.0 |
| xr_server->end_frame | godot | 0.281 | 0.281 | 1.0 |
| xrWaitFrame | godot | 0.258 | 0.258 | 1.0 |
| extension wrappers on_process | godot | 0.231 | 0.231 | 1.0 |
| xr_server->_process | godot | 0.210 | 0.716 | 1.0 |
| driver->command_pool_reset | godot | 0.112 | 0.112 | 1.0 |
| physics_process | godot | 0.104 | 0.104 | 5.2 |

### 10 closed_scene20k

Slices without an end, left out: 5.
Thread VkThread: frames 11, mean Main::iteration 254.51 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| _execute_frame | godot | 185.884 | 185.884 | 1.0 |
| render viewport | godot | 47.616 | 47.622 | 16.4 |
| draw_graph.end | godot | 22.539 | 22.539 | 1.1 |
| process | godot | 2.510 | 2.510 | 1.1 |
| xr_server->end_frame | godot | 0.469 | 0.469 | 1.1 |
| extension wrappers on_process | godot | 0.256 | 0.256 | 1.1 |
| xr_server->_process | godot | 0.218 | 0.525 | 1.1 |
| driver->command_pool_reset | godot | 0.145 | 0.145 | 1.1 |
| physics_process | godot | 0.122 | 0.122 | 8.7 |
| Physics Step | godot | 0.081 | 0.325 | 8.7 |

### 11 closed

Slices without an end, left out: 5.
Thread VkThread: frames 214, mean Main::iteration 13.90 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | godot | 3.902 | 3.902 | 1.0 |
| rasterizer->blit_render_targets_to_screen | godot | 3.562 | 3.562 | 1.0 |
| process | godot | 3.067 | 3.067 | 1.0 |
| draw_graph.end | godot | 1.029 | 1.029 | 1.0 |
| render viewport | godot | 0.493 | 0.499 | 15.0 |
| extension wrappers on_process | godot | 0.347 | 0.347 | 1.0 |
| _execute_frame | godot | 0.346 | 0.346 | 1.0 |
| xr_server->_process | godot | 0.287 | 4.566 | 1.0 |
| xr_server->end_frame | godot | 0.280 | 0.280 | 1.0 |
| physics_process | godot | 0.091 | 0.091 | 0.8 |

### 12 open_scene5k

Slices without an end, left out: 5.
Thread VkThread: frames 28, mean Main::iteration 101.47 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| _execute_frame | godot | 75.477 | 75.477 | 1.0 |
| render viewport | godot | 12.823 | 12.850 | 18.2 |
| draw_graph.end | godot | 10.103 | 10.103 | 1.1 |
| process | godot | 5.404 | 5.404 | 1.1 |
| xrWaitFrame | godot | 0.807 | 0.807 | 1.0 |
| driver->command_pool_reset | godot | 0.349 | 0.349 | 1.0 |
| xr_server->end_frame | godot | 0.342 | 0.342 | 1.0 |
| extension wrappers on_process | godot | 0.247 | 0.247 | 1.0 |
| xr_server->_process | godot | 0.224 | 1.296 | 1.0 |
| physics_process | godot | 0.107 | 0.107 | 6.5 |

### 13 open

Slices without an end, left out: 3.
Thread VkThread: frames 187, mean Main::iteration 15.97 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.485 | 5.485 | 1.0 |
| draw_graph.end | godot | 4.251 | 4.251 | 1.0 |
| _execute_frame | godot | 1.885 | 1.885 | 1.0 |
| render viewport | godot | 1.746 | 1.781 | 17.0 |
| rasterizer->blit_render_targets_to_screen | godot | 1.068 | 1.068 | 1.0 |
| driver->command_pool_reset | godot | 0.322 | 0.322 | 1.0 |
| xr_server->end_frame | godot | 0.264 | 0.264 | 1.0 |
| extension wrappers on_process | godot | 0.239 | 0.239 | 1.0 |
| xr_server->_process | godot | 0.210 | 0.498 | 1.0 |
| physics_process | godot | 0.076 | 0.076 | 1.0 |

### 14 closed

Slices without an end, left out: 5.
Thread VkThread: frames 215, mean Main::iteration 13.87 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| rasterizer->blit_render_targets_to_screen | godot | 7.873 | 7.873 | 1.0 |
| process | godot | 2.784 | 2.784 | 1.0 |
| draw_graph.end | godot | 1.041 | 1.041 | 1.0 |
| render viewport | godot | 0.472 | 0.478 | 15.1 |
| _execute_frame | godot | 0.356 | 0.356 | 1.0 |
| xr_server->end_frame | godot | 0.282 | 0.282 | 1.0 |
| extension wrappers on_process | godot | 0.274 | 0.274 | 1.0 |
| xr_server->_process | godot | 0.243 | 0.566 | 1.0 |
| driver->command_pool_reset | godot | 0.089 | 0.089 | 1.0 |
| physics_process | godot | 0.074 | 0.074 | 0.8 |
