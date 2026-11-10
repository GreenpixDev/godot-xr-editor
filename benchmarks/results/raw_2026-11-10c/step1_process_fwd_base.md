
### 01 closed

Frames 839, mean Main::iteration 6.05 ms; `process` 0.795 ms, of it its own C++ 0.244 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.244 | 31% |
| plugin: graph (logic_graph/) | 0.129 | 16% |
| plugin: tools (tools/) | 0.125 | 16% |
| plugin: simulator (xr/simulator.gd) | 0.080 | 10% |
| plugin: controllers, rays, rig (xr/) | 0.072 | 9% |
| plugin: core (core/) | 0.058 | 7% |
| plugin: lab (telemetry/graph_lab.gd) | 0.044 | 5% |
| plugin: panels and UI (ui/) | 0.038 | 5% |
| plugin: other (playmode) | 0.005 | 1% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.124 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.107 | 1.0 |
| _process | xr/simulator.gd:319 | 0.075 | 1.0 |
| _process | ui/panels.gd:208 | 0.054 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.044 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.029 | 1.0 |
| _process | xr/session.gd:188 | 0.024 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
| _process | tools/undo.gd:24 | 0.016 | 1.0 |
| _process | xr/simulator.gd:474 | 0.014 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.010 | 1.0 |
| _process | tools/icons.gd:69 | 0.010 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.124 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.123 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.122 |
| _process | tools/manipulator.gd:296 | 0.107 |
| _process_frame | tools/manipulator.gd:298 | 0.105 |
| _process_frame | tools/manipulator.gd:302 | 0.105 |
| _update_hover | tools/manipulator.gd:332 | 0.077 |
| _update_hover | tools/manipulator.gd:465 | 0.076 |
| _process | xr/simulator.gd:319 | 0.075 |
| _process | ui/panels.gd:208 | 0.054 |
| is_action_pressed | xr/rig.gd:83 | 0.048 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.044 |
| _process | telemetry/graph_lab.gd:361 | 0.044 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.044 |
| _update_pointer | ui/panels.gd:222 | 0.037 |
| _update_pointer | ui/panels.gd:824 | 0.036 |
| _update_inputs | xr/simulator.gd:325 | 0.031 |
| _update_inputs | xr/simulator.gd:357 | 0.031 |
| binding_of | core/feature_settings.gd:1136 | 0.030 |
| _process | tools/locomotion.gd:108 | 0.029 |
| get_action_hand | xr/rig.gd:78 | 0.028 |
| _update_poses | xr/simulator.gd:324 | 0.026 |
| _update_poses | xr/simulator.gd:335 | 0.026 |
| get_binding | core/feature_settings.gd:1137 | 0.026 |
| cast_segment | tools/manipulator.gd:484 | 0.024 |
| _process | xr/session.gd:188 | 0.024 |
| get_binding | core/feature_settings.gd:1121 | 0.024 |
| find_at_point | tools/manipulator.gd:475 | 0.020 |
| _report | telemetry/graph_lab.gd:379 | 0.019 |
| _report | telemetry/graph_lab.gd:493 | 0.019 |
| _report_frames | telemetry/graph_lab.gd:499 | 0.018 |
| _report_frames | telemetry/graph_lab.gd:503 | 0.018 |
| _process | tools/selection_counter.gd:87 | 0.018 |
| get_action_hand | xr/rig.gd:87 | 0.018 |
| hover_actions | logic_graph/blueprints.gd:3027 | 0.017 |
| binding_of | xr/rig.gd:79 | 0.017 |
| _refresh_views | telemetry/graph_lab.gd:510 | 0.017 |
| _refresh_views | telemetry/graph_lab.gd:545 | 0.017 |
| hover_actions | logic_graph/blueprint_canvas.gd:3299 | 0.016 |
| _process | tools/undo.gd:24 | 0.016 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| cast_segment | tools/manipulator.gd:484 | 0.024 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.020 | 2.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.017 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.016 | 1.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _update_pointer | ui/panels.gd:824 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.009 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.008 | 2.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.006 | 1.0 |
| get_values | core/feature_settings.gd:1063 | 0.006 | 2.0 |
| set_pose | xr/simulator.gd:353 | 0.006 | 2.0 |
| update_input | xr/hand.gd:92 | 0.006 | 2.0 |
| show_ray | xr/hand.gd:168 | 0.006 | 2.0 |
| set_pose | xr/simulator.gd:354 | 0.005 | 2.0 |
| get_binding | core/feature_settings.gd:1121 | 0.005 | 12.0 |
| is_action_pressed | xr/rig.gd:83 | 0.005 | 5.0 |
| find_at_point | tools/icons.gd:152 | 0.004 | 2.0 |
| _process | xr/session.gd:188 | 0.004 | 1.0 |
| cast_segment | tools/icons.gd:118 | 0.004 | 2.0 |
| binding_of | core/feature_settings.gd:1136 | 0.004 | 12.0 |
| _process | telemetry/graph_lab.gd:361 | 0.003 | 1.0 |
| is_holding | logic_graph/blueprints.gd:2332 | 0.003 | 2.0 |
| hover_actions | logic_graph/blueprint_canvas.gd:3299 | 0.003 | 2.0 |
| get | core/feature_settings.gd:1130 | 0.003 | 12.0 |
| _process | tools/clipboard.gd:96 | 0.003 | 1.0 |
| _process | ui/palette.gd:156 | 0.003 | 1.0 |
| _update_desktop_ui | xr/session.gd:575 | 0.003 | 1.0 |
| get_cmdline_user_args | telemetry/graph_lab.gd:370 | 0.003 | 1.0 |
| poll_trigger | ui/virtual_keyboard.gd:233 | 0.003 | 2.0 |
| get | xr/simulator.gd:330 | 0.003 | 17.0 |

### 02 open

Frames 841, mean Main::iteration 6.05 ms; `process` 1.744 ms, of it its own C++ 0.263 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.263 | 15% |
| plugin: graph (logic_graph/) | 0.928 | 53% |
| plugin: tools (tools/) | 0.136 | 8% |
| plugin: panels and UI (ui/) | 0.109 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.084 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.079 | 5% |
| plugin: core (core/) | 0.078 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.048 | 3% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.673 | 1.0 |
| _process | ui/panels.gd:208 | 0.411 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.108 | 1.0 |
| _process | xr/simulator.gd:319 | 0.079 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.048 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.030 | 1.0 |
| _process | xr/session.gd:188 | 0.026 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.019 | 1.0 |
| _process | tools/undo.gd:24 | 0.018 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.012 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.673 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.672 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.671 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.420 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3737 | 0.418 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.417 |
| _process | ui/panels.gd:208 | 0.411 |
| _update_pointer | ui/panels.gd:222 | 0.389 |
| _update_pointer | ui/panels.gd:824 | 0.388 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.348 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.348 |
| takes_pointer | ui/panels.gd:888 | 0.333 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.332 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.329 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.329 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.309 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.308 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.251 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4273 | 0.228 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.228 |
| intersect_ray | logic_graph/blueprints.gd:2930 | 0.193 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.110 |
| _process | tools/manipulator.gd:296 | 0.108 |
| _process_frame | tools/manipulator.gd:298 | 0.107 |
| _process_frame | tools/manipulator.gd:302 | 0.106 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.102 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.102 |
| face_user | logic_graph/blueprints.gd:851 | 0.098 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.095 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.095 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.081 |
| _process | xr/simulator.gd:319 | 0.079 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.075 |
| _update_hover | tools/manipulator.gd:332 | 0.074 |
| _update_hover | tools/manipulator.gd:465 | 0.073 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.072 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.059 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.058 |
| is_action_pressed | xr/rig.gd:83 | 0.050 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.050 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.123 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.072 | 140.2 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.068 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.049 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.041 | 78.1 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.034 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.031 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.026 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.022 | 18.0 |
| find_at_point | tools/manipulator.gd:475 | 0.021 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.020 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.020 | 4.0 |
| cast_segment | tools/manipulator.gd:484 | 0.020 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.019 | 1.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.017 | 24.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.017 | 15.5 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.016 | 2.0 |
| get_values | core/feature_settings.gd:1063 | 0.015 | 6.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.015 | 0.5 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.015 | 4.0 |
| _update_poses | xr/simulator.gd:335 | 0.014 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.012 | 128.2 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.010 | 24.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.009 | 18.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |

### 03 open_big2

Frames 839, mean Main::iteration 6.06 ms; `process` 2.137 ms, of it its own C++ 0.255 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.255 | 12% |
| plugin: graph (logic_graph/) | 1.341 | 63% |
| plugin: tools (tools/) | 0.137 | 6% |
| plugin: panels and UI (ui/) | 0.103 | 5% |
| plugin: simulator (xr/simulator.gd) | 0.081 | 4% |
| plugin: controllers, rays, rig (xr/) | 0.077 | 4% |
| plugin: core (core/) | 0.077 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.049 | 2% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.897 | 1.0 |
| _process | ui/panels.gd:208 | 0.594 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.111 | 1.0 |
| _process | xr/simulator.gd:319 | 0.076 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.049 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.029 | 1.0 |
| _process | xr/session.gd:188 | 0.025 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
| _process | tools/undo.gd:24 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.010 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.897 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.896 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.895 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.753 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3737 | 0.751 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.750 |
| _process | ui/panels.gd:208 | 0.594 |
| _update_pointer | ui/panels.gd:222 | 0.571 |
| _update_pointer | ui/panels.gd:824 | 0.571 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.561 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.561 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.525 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.525 |
| takes_pointer | ui/panels.gd:888 | 0.521 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.520 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.517 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.516 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.472 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4273 | 0.439 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.399 |
| intersect_ray | logic_graph/blueprints.gd:2930 | 0.355 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.163 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.159 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.155 |
| face_user | logic_graph/blueprints.gd:851 | 0.152 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.149 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.149 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.116 |
| _process | tools/manipulator.gd:296 | 0.111 |
| _process_frame | tools/manipulator.gd:298 | 0.109 |
| _process_frame | tools/manipulator.gd:302 | 0.108 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.099 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.099 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.094 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.094 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4295 | 0.092 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.080 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.080 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.079 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4711 | 0.077 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.214 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.155 | 266.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.135 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.080 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.079 | 156.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.056 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.042 | 0.5 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.038 | 32.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.030 | 30.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.026 | 40.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.025 | 2.0 |
| cast_segment | tools/manipulator.gd:484 | 0.024 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.022 | 0.5 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.022 | 248.0 |
| find_at_point | tools/manipulator.gd:475 | 0.021 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.020 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.019 | 4.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.019 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.015 | 2.0 |
| _cast | ui/panel_surface.gd:626 | 0.015 | 24.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| get_values | core/feature_settings.gd:1063 | 0.015 | 6.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.014 | 4.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.014 | 40.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4295 | 0.013 | 156.0 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.009 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |

### 04 open

Frames 852, mean Main::iteration 6.06 ms; `process` 1.753 ms, of it its own C++ 0.266 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.266 | 15% |
| plugin: graph (logic_graph/) | 0.929 | 53% |
| plugin: tools (tools/) | 0.137 | 8% |
| plugin: panels and UI (ui/) | 0.105 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.085 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.080 | 5% |
| plugin: core (core/) | 0.079 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.052 | 3% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.006 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.672 | 1.0 |
| _process | ui/panels.gd:208 | 0.409 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.110 | 1.0 |
| _process | xr/simulator.gd:319 | 0.080 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.052 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.031 | 1.0 |
| _process | xr/session.gd:188 | 0.026 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.019 | 1.0 |
| _process | tools/undo.gd:24 | 0.018 | 1.0 |
| _process | xr/simulator.gd:474 | 0.014 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.672 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.671 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.670 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.421 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3737 | 0.418 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.418 |
| _process | ui/panels.gd:208 | 0.409 |
| _update_pointer | ui/panels.gd:222 | 0.386 |
| _update_pointer | ui/panels.gd:824 | 0.386 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.348 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.347 |
| takes_pointer | ui/panels.gd:888 | 0.334 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.333 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.330 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.329 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.311 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.310 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.253 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4273 | 0.230 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.228 |
| intersect_ray | logic_graph/blueprints.gd:2930 | 0.194 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.112 |
| _process | tools/manipulator.gd:296 | 0.110 |
| _process_frame | tools/manipulator.gd:298 | 0.108 |
| _process_frame | tools/manipulator.gd:302 | 0.108 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.102 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.102 |
| face_user | logic_graph/blueprints.gd:851 | 0.100 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.097 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.097 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.082 |
| _process | xr/simulator.gd:319 | 0.080 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.076 |
| _update_hover | tools/manipulator.gd:332 | 0.075 |
| _update_hover | tools/manipulator.gd:465 | 0.074 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.073 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.059 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.058 |
| _process | telemetry/graph_lab.gd:361 | 0.052 |
| is_action_pressed | xr/rig.gd:83 | 0.051 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.124 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.073 | 140.2 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.068 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.049 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.042 | 78.1 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.035 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.031 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.025 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.023 | 18.0 |
| find_at_point | tools/manipulator.gd:475 | 0.021 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.021 | 1.0 |
| cast_segment | tools/manipulator.gd:484 | 0.020 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.019 | 4.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.019 | 1.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.017 | 24.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.017 | 15.5 |
| find_children | telemetry/graph_lab.gd:547 | 0.016 | 0.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.016 | 0.5 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.016 | 2.0 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.015 | 4.0 |
| get_values | core/feature_settings.gd:1063 | 0.015 | 6.0 |
| _update_poses | xr/simulator.gd:335 | 0.014 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.013 | 128.2 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.011 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.010 | 24.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.008 | 14.0 |
| _process | xr/simulator.gd:474 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |

### 05 open_big2

Frames 838, mean Main::iteration 6.05 ms; `process` 2.192 ms, of it its own C++ 0.259 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.259 | 12% |
| plugin: graph (logic_graph/) | 1.387 | 63% |
| plugin: tools (tools/) | 0.138 | 6% |
| plugin: panels and UI (ui/) | 0.104 | 5% |
| plugin: simulator (xr/simulator.gd) | 0.082 | 4% |
| plugin: core (core/) | 0.078 | 4% |
| plugin: controllers, rays, rig (xr/) | 0.077 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.048 | 2% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.927 | 1.0 |
| _process | ui/panels.gd:208 | 0.613 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.111 | 1.0 |
| _process | xr/simulator.gd:319 | 0.077 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.048 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.029 | 1.0 |
| _process | xr/session.gd:188 | 0.025 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
| _process | tools/undo.gd:24 | 0.018 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.010 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.927 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.926 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.925 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.778 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3737 | 0.776 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.775 |
| _process | ui/panels.gd:208 | 0.613 |
| _update_pointer | ui/panels.gd:222 | 0.591 |
| _update_pointer | ui/panels.gd:824 | 0.590 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.581 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.580 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.542 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.542 |
| takes_pointer | ui/panels.gd:888 | 0.539 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.538 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.535 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.534 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.488 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4273 | 0.454 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.413 |
| intersect_ray | logic_graph/blueprints.gd:2930 | 0.366 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.172 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.165 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.161 |
| face_user | logic_graph/blueprints.gd:851 | 0.160 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.157 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.157 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.121 |
| _process | tools/manipulator.gd:296 | 0.111 |
| _process_frame | tools/manipulator.gd:298 | 0.110 |
| _process_frame | tools/manipulator.gd:302 | 0.109 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.101 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.100 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.098 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.097 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4295 | 0.094 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.084 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.083 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4711 | 0.081 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.081 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.221 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.161 | 266.3 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.139 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.083 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.081 | 156.2 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.060 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.045 | 0.5 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.040 | 32.6 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.031 | 30.1 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.026 | 40.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.026 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.024 | 0.5 |
| cast_segment | tools/manipulator.gd:484 | 0.024 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.022 | 248.3 |
| find_at_point | tools/manipulator.gd:475 | 0.021 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.021 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.020 | 4.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.019 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.016 | 2.0 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| get_values | core/feature_settings.gd:1063 | 0.015 | 6.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.015 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4295 | 0.013 | 156.2 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.013 | 40.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
