
### 01 closed

Frames 841, mean Main::iteration 6.05 ms; `process` 0.851 ms, of it its own C++ 0.263 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.263 | 31% |
| plugin: graph (logic_graph/) | 0.138 | 16% |
| plugin: tools (tools/) | 0.134 | 16% |
| plugin: simulator (xr/simulator.gd) | 0.084 | 10% |
| plugin: controllers, rays, rig (xr/) | 0.077 | 9% |
| plugin: core (core/) | 0.061 | 7% |
| plugin: lab (telemetry/graph_lab.gd) | 0.048 | 6% |
| plugin: panels and UI (ui/) | 0.040 | 5% |
| plugin: other (playmode) | 0.006 | 1% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.133 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.113 | 1.0 |
| _process | xr/simulator.gd:319 | 0.079 | 1.0 |
| _process | ui/panels.gd:208 | 0.058 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.048 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.030 | 1.0 |
| _process | xr/session.gd:188 | 0.025 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.019 | 1.0 |
| _process | tools/undo.gd:24 | 0.018 | 1.0 |
| _process | xr/simulator.gd:474 | 0.015 | 1.0 |
| _process | xr/rig.gd:54 | 0.012 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.133 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.132 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.131 |
| _process | tools/manipulator.gd:296 | 0.113 |
| _process_frame | tools/manipulator.gd:298 | 0.111 |
| _process_frame | tools/manipulator.gd:302 | 0.111 |
| _update_hover | tools/manipulator.gd:332 | 0.080 |
| _update_hover | tools/manipulator.gd:465 | 0.079 |
| _process | xr/simulator.gd:319 | 0.079 |
| _process | ui/panels.gd:208 | 0.058 |
| is_action_pressed | xr/rig.gd:83 | 0.052 |
| _process | telemetry/graph_lab.gd:361 | 0.048 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.047 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.046 |
| _update_pointer | ui/panels.gd:222 | 0.040 |
| _update_pointer | ui/panels.gd:824 | 0.039 |
| _update_inputs | xr/simulator.gd:325 | 0.033 |
| _update_inputs | xr/simulator.gd:357 | 0.033 |
| binding_of | core/feature_settings.gd:1136 | 0.032 |
| get_action_hand | xr/rig.gd:78 | 0.031 |
| _process | tools/locomotion.gd:108 | 0.030 |
| get_binding | core/feature_settings.gd:1137 | 0.028 |
| _update_poses | xr/simulator.gd:324 | 0.027 |
| _update_poses | xr/simulator.gd:335 | 0.026 |
| get_binding | core/feature_settings.gd:1121 | 0.026 |
| cast_segment | tools/manipulator.gd:484 | 0.025 |
| _process | xr/session.gd:188 | 0.025 |
| get_action_hand | xr/rig.gd:87 | 0.020 |
| _report | telemetry/graph_lab.gd:379 | 0.020 |
| _report | telemetry/graph_lab.gd:493 | 0.020 |
| _report_frames | telemetry/graph_lab.gd:499 | 0.020 |
| _report_frames | telemetry/graph_lab.gd:503 | 0.020 |
| find_at_point | tools/manipulator.gd:475 | 0.020 |
| _process | tools/selection_counter.gd:87 | 0.019 |
| binding_of | xr/rig.gd:79 | 0.018 |
| hover_actions | logic_graph/blueprints.gd:3027 | 0.018 |
| _process | tools/undo.gd:24 | 0.018 |
| _refresh_views | telemetry/graph_lab.gd:510 | 0.018 |
| _refresh_views | telemetry/graph_lab.gd:545 | 0.018 |
| hover_actions | logic_graph/blueprint_canvas.gd:3299 | 0.017 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| cast_segment | tools/manipulator.gd:484 | 0.025 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.020 | 2.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.018 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.017 | 1.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.016 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.014 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.012 | 2.0 |
| _update_pointer | ui/panels.gd:824 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.009 | 2.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.007 | 1.0 |
| update_input | xr/hand.gd:92 | 0.006 | 2.0 |
| get_values | core/feature_settings.gd:1063 | 0.006 | 2.0 |
| set_pose | xr/simulator.gd:353 | 0.006 | 2.0 |
| show_ray | xr/hand.gd:168 | 0.006 | 2.0 |
| get_binding | core/feature_settings.gd:1121 | 0.005 | 12.0 |
| is_action_pressed | xr/rig.gd:83 | 0.005 | 5.0 |
| set_pose | xr/simulator.gd:354 | 0.005 | 2.0 |
| find_at_point | tools/icons.gd:152 | 0.005 | 2.0 |
| _process | xr/session.gd:188 | 0.005 | 1.0 |
| cast_segment | tools/icons.gd:118 | 0.004 | 2.0 |
| _process | telemetry/graph_lab.gd:361 | 0.004 | 1.0 |
| binding_of | core/feature_settings.gd:1136 | 0.004 | 12.0 |
| get | core/feature_settings.gd:1130 | 0.004 | 12.0 |
| is_holding | logic_graph/blueprints.gd:2332 | 0.004 | 2.0 |
| _update_desktop_ui | xr/session.gd:575 | 0.004 | 1.0 |
| hover_actions | logic_graph/blueprint_canvas.gd:3299 | 0.004 | 2.0 |
| _process | tools/clipboard.gd:96 | 0.003 | 1.0 |
| _process | ui/palette.gd:156 | 0.003 | 1.0 |
| poll_trigger | ui/virtual_keyboard.gd:233 | 0.003 | 2.0 |
| get_layout | core/feature_settings.gd:1105 | 0.003 | 12.0 |
| get_cmdline_user_args | telemetry/graph_lab.gd:370 | 0.003 | 1.0 |

### 02 open

Frames 839, mean Main::iteration 6.06 ms; `process` 1.643 ms, of it its own C++ 0.270 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.270 | 16% |
| plugin: graph (logic_graph/) | 0.801 | 49% |
| plugin: tools (tools/) | 0.142 | 9% |
| plugin: panels and UI (ui/) | 0.113 | 7% |
| plugin: simulator (xr/simulator.gd) | 0.085 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.082 | 5% |
| plugin: core (core/) | 0.080 | 5% |
| plugin: lab (telemetry/graph_lab.gd) | 0.051 | 3% |
| other GDScript | 0.013 | 1% |
| plugin: other (playmode) | 0.006 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.518 | 1.0 |
| _process | ui/panels.gd:208 | 0.446 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.113 | 1.0 |
| _process | xr/simulator.gd:319 | 0.079 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.051 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.030 | 1.0 |
| _process | xr/session.gd:188 | 0.025 | 1.0 |
| _process | tools/undo.gd:24 | 0.020 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.019 | 1.0 |
| _process | xr/simulator.gd:474 | 0.014 | 1.0 |
| _process | xr/rig.gd:54 | 0.012 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.012 | 1.0 |
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
| _process | logic_graph/blueprints.gd:804 | 0.518 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.517 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.516 |
| _process | ui/panels.gd:208 | 0.446 |
| _update_pointer | ui/panels.gd:222 | 0.422 |
| _update_pointer | ui/panels.gd:824 | 0.422 |
| takes_pointer | ui/panels.gd:888 | 0.364 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.363 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.360 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.359 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.269 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.255 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3748 | 0.237 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.236 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.179 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.179 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.172 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.171 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.139 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4273 | 0.126 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.116 |
| _process | tools/manipulator.gd:296 | 0.113 |
| _process_frame | tools/manipulator.gd:298 | 0.111 |
| _process_frame | tools/manipulator.gd:302 | 0.111 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.107 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.106 |
| face_user | logic_graph/blueprints.gd:851 | 0.104 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.101 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.101 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.086 |
| _process | xr/simulator.gd:319 | 0.079 |
| _update_hover | tools/manipulator.gd:332 | 0.077 |
| _update_hover | tools/manipulator.gd:465 | 0.076 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.063 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.062 |
| is_action_pressed | xr/rig.gd:83 | 0.054 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.054 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.053 |
| _process | telemetry/graph_lab.gd:361 | 0.051 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.051 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.070 | 6.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.041 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.039 | 70.1 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.038 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.031 | 0.5 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.028 | 6.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.027 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.024 | 18.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.023 | 1.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.022 | 39.0 |
| find_at_point | tools/manipulator.gd:475 | 0.021 | 2.0 |
| cast_segment | tools/manipulator.gd:484 | 0.021 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.019 | 1.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.018 | 15.5 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.018 | 24.0 |
| _cast | ui/panel_surface.gd:626 | 0.017 | 24.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.017 | 2.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.017 | 0.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.017 | 4.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.016 | 0.5 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.015 | 4.0 |
| get_values | core/feature_settings.gd:1063 | 0.015 | 6.0 |
| _update_poses | xr/simulator.gd:335 | 0.014 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.012 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.010 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.009 | 18.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.009 | 24.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.008 | 14.0 |
| _process | xr/simulator.gd:474 | 0.008 | 1.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.008 | 12.0 |

### 03 open_big2

Frames 839, mean Main::iteration 6.06 ms; `process` 2.000 ms, of it its own C++ 0.277 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.277 | 14% |
| plugin: graph (logic_graph/) | 1.138 | 57% |
| plugin: tools (tools/) | 0.148 | 7% |
| plugin: panels and UI (ui/) | 0.112 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.088 | 4% |
| plugin: controllers, rays, rig (xr/) | 0.083 | 4% |
| plugin: core (core/) | 0.081 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.052 | 3% |
| other GDScript | 0.013 | 1% |
| plugin: other (playmode) | 0.006 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | ui/panels.gd:208 | 0.687 | 1.0 |
| _process | logic_graph/blueprints.gd:804 | 0.615 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.118 | 1.0 |
| _process | xr/simulator.gd:319 | 0.082 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.052 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.030 | 1.0 |
| _process | xr/session.gd:188 | 0.026 | 1.0 |
| _process | tools/undo.gd:24 | 0.020 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.020 | 1.0 |
| _process | xr/simulator.gd:474 | 0.014 | 1.0 |
| _process | xr/rig.gd:54 | 0.012 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.012 | 1.0 |
| _process | tools/icons.gd:69 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.007 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | ui/panels.gd:208 | 0.687 |
| _update_pointer | ui/panels.gd:222 | 0.663 |
| _update_pointer | ui/panels.gd:824 | 0.663 |
| _process | logic_graph/blueprints.gd:804 | 0.615 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.613 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.613 |
| takes_pointer | ui/panels.gd:888 | 0.606 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.605 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.601 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.600 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.485 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.471 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3748 | 0.451 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.451 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.325 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.324 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.272 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4273 | 0.254 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.202 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.202 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.182 |
| face_user | logic_graph/blueprints.gd:851 | 0.170 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.167 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.166 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.130 |
| _process | tools/manipulator.gd:296 | 0.118 |
| _process_frame | tools/manipulator.gd:298 | 0.116 |
| _process_frame | tools/manipulator.gd:302 | 0.115 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.109 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.109 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.106 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.105 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.091 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.089 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4711 | 0.088 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.087 |
| _process | xr/simulator.gd:319 | 0.082 |
| _update_hover | tools/manipulator.gd:332 | 0.081 |
| _update_hover | tools/manipulator.gd:465 | 0.080 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.075 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.127 | 6.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.093 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.087 | 133.2 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.065 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.047 | 6.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.044 | 78.1 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.044 | 0.5 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.043 | 32.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.034 | 30.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.029 | 40.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.028 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.027 | 0.5 |
| cast_segment | tools/manipulator.gd:484 | 0.025 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.023 | 1.0 |
| find_at_point | tools/manipulator.gd:475 | 0.021 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.020 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.018 | 2.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.017 | 4.0 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.016 | 4.0 |
| get_values | core/feature_settings.gd:1063 | 0.015 | 6.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.014 | 1.0 |
| update | xr/simulator.gd:427 | 0.014 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.013 | 40.0 |
| _update_pointer | ui/panels.gd:824 | 0.013 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.012 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.012 | 124.1 |
| _measure | telemetry/graph_lab.gd:472 | 0.011 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.010 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.009 | 12.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| button_hand | core/feature_settings.gd:1141 | 0.008 | 14.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| focus_paint | logic_graph/blueprint_canvas.gd:3077 | 0.008 | 32.0 |
| _process | xr/simulator.gd:474 | 0.008 | 1.0 |

### 04 open

Frames 840, mean Main::iteration 6.06 ms; `process` 1.681 ms, of it its own C++ 0.284 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.284 | 17% |
| plugin: graph (logic_graph/) | 0.811 | 48% |
| plugin: tools (tools/) | 0.147 | 9% |
| plugin: panels and UI (ui/) | 0.110 | 7% |
| plugin: simulator (xr/simulator.gd) | 0.090 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.085 | 5% |
| plugin: core (core/) | 0.081 | 5% |
| plugin: lab (telemetry/graph_lab.gd) | 0.053 | 3% |
| other GDScript | 0.013 | 1% |
| plugin: other (playmode) | 0.006 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.520 | 1.0 |
| _process | ui/panels.gd:208 | 0.450 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.116 | 1.0 |
| _process | xr/simulator.gd:319 | 0.084 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.053 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.031 | 1.0 |
| _process | xr/session.gd:188 | 0.028 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.020 | 1.0 |
| _process | tools/undo.gd:24 | 0.020 | 1.0 |
| _process | xr/simulator.gd:474 | 0.015 | 1.0 |
| _process | xr/rig.gd:54 | 0.012 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.012 | 1.0 |
| _process | tools/icons.gd:69 | 0.012 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.007 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.002 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.520 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.518 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.517 |
| _process | ui/panels.gd:208 | 0.450 |
| _update_pointer | ui/panels.gd:222 | 0.426 |
| _update_pointer | ui/panels.gd:824 | 0.426 |
| takes_pointer | ui/panels.gd:888 | 0.370 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.369 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.366 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.365 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.272 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.259 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3748 | 0.240 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.239 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.177 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.177 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.172 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.172 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.139 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4273 | 0.126 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.116 |
| _process | tools/manipulator.gd:296 | 0.116 |
| _process_frame | tools/manipulator.gd:298 | 0.114 |
| _process_frame | tools/manipulator.gd:302 | 0.114 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.108 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.108 |
| face_user | logic_graph/blueprints.gd:851 | 0.104 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.101 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.101 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.087 |
| _process | xr/simulator.gd:319 | 0.084 |
| _update_hover | tools/manipulator.gd:332 | 0.078 |
| _update_hover | tools/manipulator.gd:465 | 0.078 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.064 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.063 |
| is_action_pressed | xr/rig.gd:83 | 0.054 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.053 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.053 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.053 |
| _process | telemetry/graph_lab.gd:361 | 0.053 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.071 | 6.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.043 | 2.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.039 | 4.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.039 | 70.1 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.032 | 0.5 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.028 | 6.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.027 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.024 | 18.0 |
| find_at_point | tools/manipulator.gd:475 | 0.022 | 2.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.022 | 39.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.022 | 1.0 |
| cast_segment | tools/manipulator.gd:484 | 0.021 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.020 | 1.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.018 | 15.5 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.018 | 24.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.017 | 2.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.017 | 4.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.016 | 0.5 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.015 | 4.0 |
| get_values | core/feature_settings.gd:1063 | 0.015 | 6.0 |
| _update_poses | xr/simulator.gd:335 | 0.015 | 1.0 |
| update | xr/simulator.gd:427 | 0.014 | 1.0 |
| _update_pointer | ui/panels.gd:824 | 0.013 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.012 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.012 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.011 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.010 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.010 | 24.0 |
| button_input | core/feature_settings.gd:1146 | 0.009 | 12.0 |
| _process | tools/icons.gd:69 | 0.009 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process | xr/simulator.gd:474 | 0.008 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.008 | 14.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |

### 05 open_big2

Frames 838, mean Main::iteration 6.06 ms; `process` 2.050 ms, of it its own C++ 0.302 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.302 | 15% |
| plugin: graph (logic_graph/) | 1.142 | 56% |
| plugin: tools (tools/) | 0.156 | 8% |
| plugin: panels and UI (ui/) | 0.114 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.093 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.087 | 4% |
| plugin: core (core/) | 0.082 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.053 | 3% |
| other GDScript | 0.013 | 1% |
| plugin: other (playmode) | 0.006 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | ui/panels.gd:208 | 0.700 | 1.0 |
| _process | logic_graph/blueprints.gd:804 | 0.605 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.123 | 1.0 |
| _process | xr/simulator.gd:319 | 0.088 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.053 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.032 | 1.0 |
| _process | xr/session.gd:188 | 0.030 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.021 | 1.0 |
| _process | tools/undo.gd:24 | 0.019 | 1.0 |
| _process | xr/simulator.gd:474 | 0.015 | 1.0 |
| _process | xr/rig.gd:54 | 0.013 | 1.0 |
| _process | tools/icons.gd:69 | 0.013 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.012 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.007 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.006 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.002 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | ui/panels.gd:208 | 0.700 |
| _update_pointer | ui/panels.gd:222 | 0.676 |
| _update_pointer | ui/panels.gd:824 | 0.675 |
| takes_pointer | ui/panels.gd:888 | 0.617 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.616 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.613 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.612 |
| _process | logic_graph/blueprints.gd:804 | 0.605 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.604 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.603 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.488 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.475 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3748 | 0.455 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.454 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.324 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.323 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.271 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4273 | 0.252 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.199 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.199 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.177 |
| face_user | logic_graph/blueprints.gd:851 | 0.164 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.161 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.161 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.133 |
| _process | tools/manipulator.gd:296 | 0.123 |
| _process_frame | tools/manipulator.gd:298 | 0.121 |
| _process_frame | tools/manipulator.gd:302 | 0.121 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.110 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.109 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.109 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.108 |
| _process | xr/simulator.gd:319 | 0.088 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.087 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.086 |
| _update_hover | tools/manipulator.gd:332 | 0.086 |
| _update_hover | tools/manipulator.gd:465 | 0.085 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.085 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4711 | 0.084 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.081 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.130 | 6.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.096 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.085 | 133.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.068 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.047 | 6.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.044 | 0.5 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.043 | 78.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.041 | 32.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.033 | 30.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.028 | 40.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.028 | 2.0 |
| cast_segment | tools/manipulator.gd:484 | 0.026 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.026 | 0.5 |
| find_at_point | tools/manipulator.gd:475 | 0.024 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.022 | 1.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.020 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.018 | 2.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.017 | 4.0 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| get_values | core/feature_settings.gd:1063 | 0.016 | 6.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.016 | 4.0 |
| _update_poses | xr/simulator.gd:335 | 0.015 | 1.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| update | xr/simulator.gd:427 | 0.015 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.015 | 40.0 |
| _update_pointer | ui/panels.gd:824 | 0.013 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.013 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.012 | 124.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.012 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.011 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.010 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.009 | 12.0 |
| _process | tools/icons.gd:69 | 0.009 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| button_hand | core/feature_settings.gd:1141 | 0.008 | 14.0 |
| _process | xr/simulator.gd:474 | 0.008 | 1.0 |
| focus_paint | logic_graph/blueprint_canvas.gd:3077 | 0.007 | 32.0 |
