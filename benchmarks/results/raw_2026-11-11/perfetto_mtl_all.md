
### 01 closed

Slices without an end, left out: 5.
Thread VkThread: frames 204, mean Main::iteration 14.29 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | godot | 9.012 | 9.012 | 1.0 |
| process | godot | 2.785 | 2.785 | 1.0 |
| driver->command_buffer_end | godot | 0.570 | 0.570 | 1.0 |
| render viewport | godot | 0.343 | 0.349 | 15.1 |
| extension wrappers on_process | godot | 0.278 | 0.278 | 1.0 |
| draw_graph.end | godot | 0.259 | 0.259 | 1.0 |
| xr_server->end_frame | godot | 0.253 | 0.253 | 1.0 |
| xr_server->_process | godot | 0.235 | 9.546 | 1.0 |
| _execute_frame | godot | 0.090 | 0.090 | 1.0 |
| physics_process | godot | 0.073 | 0.073 | 0.9 |
| driver->command_pool_reset | godot | 0.068 | 0.068 | 1.0 |
| xr_server->pre_render | godot | 0.066 | 0.066 | 1.0 |

### 02 open

Slices without an end, left out: 3.
Thread VkThread: frames 215, mean Main::iteration 13.86 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 4.608 | 4.608 | 1.0 |
| xrWaitFrame | godot | 3.700 | 3.700 | 1.0 |
| driver->command_buffer_end | godot | 1.542 | 1.542 | 1.0 |
| render viewport | godot | 1.375 | 1.382 | 17.1 |
| draw_graph.end | godot | 1.046 | 1.046 | 1.0 |
| extension wrappers on_process | godot | 0.301 | 0.301 | 1.0 |
| xr_server->end_frame | godot | 0.286 | 0.286 | 1.0 |
| xr_server->_process | godot | 0.247 | 4.270 | 1.0 |
| driver->command_pool_reset | godot | 0.170 | 0.170 | 1.0 |
| xr_server->pre_render | godot | 0.105 | 0.105 | 1.0 |
| _execute_frame | godot | 0.105 | 0.105 | 1.0 |
| physics_process | godot | 0.076 | 0.076 | 0.8 |

### 03 open_big2

Slices without an end, left out: 3.
Thread VkThread: frames 210, mean Main::iteration 14.16 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.126 | 5.126 | 1.0 |
| driver->command_buffer_end | godot | 2.195 | 2.195 | 1.0 |
| xrWaitFrame | godot | 1.923 | 1.923 | 1.0 |
| render viewport | godot | 1.686 | 1.693 | 17.1 |
| draw_graph.end | godot | 1.633 | 1.633 | 1.0 |
| extension wrappers on_process | godot | 0.286 | 0.286 | 1.0 |
| xr_server->end_frame | godot | 0.274 | 0.274 | 1.0 |
| xr_server->_process | godot | 0.250 | 2.479 | 1.0 |
| driver->command_pool_reset | godot | 0.235 | 0.235 | 1.0 |
| _execute_frame | godot | 0.107 | 0.107 | 1.0 |
| physics_process | godot | 0.076 | 0.076 | 0.9 |
| xr_server->pre_render | godot | 0.076 | 0.076 | 1.0 |

### 04 open

Slices without an end, left out: 3.
Thread VkThread: frames 210, mean Main::iteration 14.20 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 4.832 | 4.832 | 1.0 |
| xrWaitFrame | godot | 4.019 | 4.019 | 1.0 |
| driver->command_buffer_end | godot | 1.466 | 1.466 | 1.0 |
| render viewport | godot | 1.342 | 1.350 | 17.0 |
| draw_graph.end | godot | 1.026 | 1.026 | 1.0 |
| extension wrappers on_process | godot | 0.270 | 0.270 | 1.0 |
| xr_server->end_frame | godot | 0.269 | 0.269 | 1.0 |
| xr_server->_process | godot | 0.236 | 4.544 | 1.0 |
| driver->command_pool_reset | godot | 0.175 | 0.175 | 1.0 |
| _execute_frame | godot | 0.098 | 0.098 | 1.0 |
| xr_server->pre_render | godot | 0.087 | 0.087 | 1.0 |
| physics_process | godot | 0.072 | 0.072 | 0.9 |

### 05 open_big2

Slices without an end, left out: 3.
Thread VkThread: frames 210, mean Main::iteration 14.16 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| process | godot | 5.232 | 5.232 | 1.0 |
| driver->command_buffer_end | godot | 2.254 | 2.254 | 1.0 |
| render viewport | godot | 1.757 | 1.764 | 17.1 |
| draw_graph.end | godot | 1.668 | 1.668 | 1.0 |
| xrWaitFrame | godot | 1.633 | 1.633 | 1.0 |
| extension wrappers on_process | godot | 0.287 | 0.287 | 1.0 |
| xr_server->end_frame | godot | 0.274 | 0.274 | 1.0 |
| driver->command_pool_reset | godot | 0.254 | 0.254 | 1.0 |
| xr_server->_process | godot | 0.241 | 2.179 | 1.0 |
| _execute_frame | godot | 0.107 | 0.107 | 1.0 |
| xr_server->pre_render | godot | 0.077 | 0.077 | 1.0 |
| physics_process | godot | 0.074 | 0.074 | 0.9 |

### 06 closed

Slices without an end, left out: 6.
Thread VkThread: frames 210, mean Main::iteration 14.14 ms.

| Zone | Source | Own ms/frame | Total ms/frame | Calls/frame |
|---|---|---|---|---|
| xrWaitFrame | godot | 8.672 | 8.672 | 1.0 |
| process | godot | 2.895 | 2.895 | 1.0 |
| driver->command_buffer_end | godot | 0.628 | 0.628 | 1.0 |
| render viewport | godot | 0.392 | 0.399 | 15.1 |
| extension wrappers on_process | godot | 0.281 | 0.281 | 1.0 |
| draw_graph.end | godot | 0.279 | 0.279 | 1.0 |
| xr_server->end_frame | godot | 0.251 | 0.251 | 1.0 |
| xr_server->_process | godot | 0.236 | 9.210 | 1.0 |
| driver->command_pool_reset | godot | 0.071 | 0.071 | 1.0 |
| physics_process | godot | 0.071 | 0.071 | 0.9 |
| xr_server->pre_render | godot | 0.070 | 0.070 | 1.0 |
| _execute_frame | godot | 0.070 | 0.070 | 1.0 |

| Step | Main::iteration | xrWaitFrame | driver->fence_wait | RenderingServer::draw | process | draw_graph.end | driver->command_buffer_end |
|---|---|---|---|---|---|---|---|
| closed | 14.291 | 9.012 | 0.017 | 1.828 | 2.785 | 0.259 | 0.570 |
| open | 13.859 | 3.700 | 0.020 | 4.859 | 4.608 | 1.046 | 1.542 |
| open_big2 | 14.158 | 1.923 | 0.051 | 6.456 | 5.126 | 1.633 | 2.195 |
| open | 14.203 | 4.019 | 0.025 | 4.696 | 4.832 | 1.026 | 1.466 |
| open_big2 | 14.156 | 1.633 | 0.055 | 6.650 | 5.232 | 1.668 | 2.254 |
| closed | 14.139 | 8.672 | 0.030 | 1.959 | 2.895 | 0.279 | 0.628 |
