
### 01 closed

Slices without an end, left out: 5.
Thread VkThread: frames 205, mean Main::iteration 14.17 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | godot | 8.761 | 8.761 | 1.0 |
| process | godot | 2.786 | 2.786 | 1.0 |
| driver->command_buffer_end | godot | 0.629 | 0.629 | 1.0 |
| render viewport | godot | 0.371 | 0.377 | 15.1 |
| extension wrappers on_process | godot | 0.294 | 0.294 | 1.0 |
| draw_graph.end | godot | 0.265 | 0.265 | 1.0 |
| xr_server->end_frame | godot | 0.246 | 0.246 | 1.0 |
| xr_server->_process | godot | 0.235 | 9.313 | 1.0 |
| _execute_frame | godot | 0.084 | 0.084 | 1.0 |
| xr_server->pre_render | godot | 0.073 | 0.073 | 1.0 |
| physics_process | godot | 0.069 | 0.069 | 0.9 |
| driver->command_pool_reset | godot | 0.062 | 0.062 | 1.0 |

### 02 open

Slices without an end, left out: 6.
Thread VkThread: frames 214, mean Main::iteration 13.87 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 4.926 | 4.926 | 1.0 |
| xrWaitFrame | godot | 2.274 | 2.274 | 1.0 |
| driver->command_buffer_end | godot | 2.246 | 2.246 | 1.0 |
| draw_graph.end | godot | 1.514 | 1.514 | 1.0 |
| render viewport | godot | 1.447 | 1.454 | 17.2 |
| extension wrappers on_process | godot | 0.277 | 0.277 | 1.0 |
| xr_server->end_frame | godot | 0.260 | 0.260 | 1.0 |
| xr_server->_process | godot | 0.233 | 2.804 | 1.0 |
| driver->command_pool_reset | godot | 0.224 | 0.224 | 1.0 |
| _execute_frame | godot | 0.098 | 0.098 | 1.0 |
| xr_server->pre_render | godot | 0.077 | 0.077 | 1.0 |
| physics_process | godot | 0.069 | 0.069 | 0.8 |

### 03 open_big2

Slices without an end, left out: 6.
Thread VkThread: frames 187, mean Main::iteration 15.91 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 6.132 | 6.132 | 1.0 |
| driver->command_buffer_end | godot | 3.314 | 3.314 | 1.0 |
| render viewport | godot | 2.060 | 2.069 | 17.1 |
| draw_graph.end | godot | 1.989 | 1.989 | 1.0 |
| driver->fence_wait | godot | 0.776 | 0.776 | 1.0 |
| driver->command_pool_reset | godot | 0.366 | 0.366 | 1.0 |
| extension wrappers on_process | godot | 0.262 | 0.262 | 1.0 |
| xr_server->end_frame | godot | 0.255 | 0.255 | 1.0 |
| xr_server->_process | godot | 0.224 | 0.535 | 1.0 |
| _execute_frame | godot | 0.128 | 0.128 | 1.0 |
| physics_process | godot | 0.077 | 0.077 | 1.0 |
| xr_server->pre_render | godot | 0.072 | 0.072 | 1.0 |

### 04 open

Slices without an end, left out: 6.
Thread VkThread: frames 210, mean Main::iteration 14.21 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.478 | 5.478 | 1.0 |
| driver->command_buffer_end | godot | 2.174 | 2.174 | 1.0 |
| xrWaitFrame | godot | 1.920 | 1.920 | 1.0 |
| render viewport | godot | 1.569 | 1.577 | 17.0 |
| draw_graph.end | godot | 1.478 | 1.478 | 1.0 |
| extension wrappers on_process | godot | 0.296 | 0.296 | 1.0 |
| xr_server->end_frame | godot | 0.274 | 0.274 | 1.0 |
| xr_server->_process | godot | 0.243 | 2.481 | 1.0 |
| driver->command_pool_reset | godot | 0.241 | 0.241 | 1.0 |
| _execute_frame | godot | 0.101 | 0.101 | 1.0 |
| xr_server->pre_render | godot | 0.077 | 0.077 | 1.0 |
| physics_process | godot | 0.072 | 0.072 | 0.9 |

### 05 open_big2

Slices without an end, left out: 6.
Thread VkThread: frames 181, mean Main::iteration 16.38 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 6.470 | 6.470 | 1.0 |
| driver->command_buffer_end | godot | 3.553 | 3.553 | 1.0 |
| render viewport | godot | 2.197 | 2.204 | 17.2 |
| draw_graph.end | godot | 2.087 | 2.087 | 1.0 |
| driver->fence_wait | godot | 0.423 | 0.423 | 1.0 |
| driver->command_pool_reset | godot | 0.372 | 0.372 | 1.0 |
| extension wrappers on_process | godot | 0.275 | 0.275 | 1.0 |
| xr_server->end_frame | godot | 0.268 | 0.268 | 1.0 |
| xr_server->_process | godot | 0.232 | 0.561 | 1.0 |
| _execute_frame | godot | 0.126 | 0.126 | 1.0 |
| physics_process | godot | 0.081 | 0.081 | 1.0 |
| xr_server->pre_render | godot | 0.075 | 0.075 | 1.0 |

### 06 closed

Slices without an end, left out: 4.
Thread VkThread: frames 210, mean Main::iteration 14.14 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | godot | 8.700 | 8.700 | 1.0 |
| process | godot | 2.879 | 2.879 | 1.0 |
| driver->command_buffer_end | godot | 0.634 | 0.634 | 1.0 |
| render viewport | godot | 0.390 | 0.396 | 15.1 |
| extension wrappers on_process | godot | 0.293 | 0.293 | 1.0 |
| draw_graph.end | godot | 0.274 | 0.274 | 1.0 |
| xr_server->end_frame | godot | 0.249 | 0.249 | 1.0 |
| xr_server->_process | godot | 0.238 | 9.253 | 1.0 |
| physics_process | godot | 0.071 | 0.071 | 0.9 |
| driver->command_pool_reset | godot | 0.069 | 0.069 | 1.0 |
| xr_server->pre_render | godot | 0.068 | 0.068 | 1.0 |
| _execute_frame | godot | 0.064 | 0.064 | 1.0 |

| Step | Main::iteration | xrWaitFrame | driver->fence_wait | RenderingServer::draw | process | draw_graph.end | driver->command_buffer_end |
|---|---|---|---|---|---|---|---|
| closed | 14.167 | 8.761 | 0.029 | 1.937 | 2.786 | 0.265 | 0.629 |
| open | 13.871 | 2.274 | 0.018 | 6.058 | 4.926 | 1.514 | 2.246 |
| open_big2 | 15.907 | 0.032 | 0.776 | 9.110 | 6.132 | 1.989 | 3.314 |
| open | 14.208 | 1.920 | 0.026 | 6.132 | 5.478 | 1.478 | 2.174 |
| open_big2 | 16.379 | 0.035 | 0.423 | 9.257 | 6.470 | 2.087 | 3.553 |
| closed | 14.144 | 8.700 | 0.027 | 1.938 | 2.879 | 0.274 | 0.634 |
