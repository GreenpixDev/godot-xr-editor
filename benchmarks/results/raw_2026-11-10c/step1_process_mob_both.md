
### 01 closed

Frames 835, mean Main::iteration 6.07 ms; `process` 0.815 ms, of it its own C++ 0.254 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.254 | 31% |
| plugin: graph (logic_graph/) | 0.130 | 16% |
| plugin: tools (tools/) | 0.129 | 16% |
| plugin: simulator (xr/simulator.gd) | 0.082 | 10% |
| plugin: controllers, rays, rig (xr/) | 0.074 | 9% |
| plugin: core (core/) | 0.059 | 7% |
| plugin: lab (telemetry/graph_lab.gd) | 0.044 | 5% |
| plugin: panels and UI (ui/) | 0.038 | 5% |
| plugin: other (playmode) | 0.005 | 1% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.125 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.109 | 1.0 |
| _process | xr/simulator.gd:319 | 0.077 | 1.0 |
| _process | ui/panels.gd:208 | 0.053 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.044 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.030 | 1.0 |
| _process | xr/session.gd:188 | 0.026 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
| _process | tools/undo.gd:24 | 0.016 | 1.0 |
| _process | xr/simulator.gd:474 | 0.014 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.005 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.125 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.124 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.124 |
| _process | tools/manipulator.gd:296 | 0.109 |
| _process_frame | tools/manipulator.gd:298 | 0.108 |
| _process_frame | tools/manipulator.gd:302 | 0.108 |
| _update_hover | tools/manipulator.gd:332 | 0.080 |
| _update_hover | tools/manipulator.gd:465 | 0.079 |
| _process | xr/simulator.gd:319 | 0.077 |
| _process | ui/panels.gd:208 | 0.053 |
| is_action_pressed | xr/rig.gd:83 | 0.049 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.045 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.044 |
| _process | telemetry/graph_lab.gd:361 | 0.044 |
| _update_pointer | ui/panels.gd:222 | 0.037 |
| _update_pointer | ui/panels.gd:824 | 0.036 |
| _update_inputs | xr/simulator.gd:325 | 0.032 |
| _update_inputs | xr/simulator.gd:357 | 0.032 |
| _process | tools/locomotion.gd:108 | 0.030 |
| binding_of | core/feature_settings.gd:1136 | 0.030 |
| get_action_hand | xr/rig.gd:78 | 0.028 |
| _update_poses | xr/simulator.gd:324 | 0.027 |
| _update_poses | xr/simulator.gd:335 | 0.027 |
| get_binding | core/feature_settings.gd:1137 | 0.026 |
| _process | xr/session.gd:188 | 0.026 |
| cast_segment | tools/manipulator.gd:484 | 0.025 |
| get_binding | core/feature_settings.gd:1121 | 0.024 |
| find_at_point | tools/manipulator.gd:475 | 0.021 |
| get_action_hand | xr/rig.gd:87 | 0.018 |
| _process | tools/selection_counter.gd:87 | 0.018 |
| _report | telemetry/graph_lab.gd:379 | 0.018 |
| _report | telemetry/graph_lab.gd:493 | 0.018 |
| _report_frames | telemetry/graph_lab.gd:499 | 0.018 |
| _report_frames | telemetry/graph_lab.gd:503 | 0.018 |
| hover_actions | logic_graph/blueprints.gd:3027 | 0.018 |
| binding_of | xr/rig.gd:79 | 0.017 |
| hover_actions | logic_graph/blueprint_canvas.gd:3299 | 0.017 |
| is_action_pressed | tools/locomotion.gd:109 | 0.016 |
| _refresh_views | telemetry/graph_lab.gd:510 | 0.016 |
| _refresh_views | telemetry/graph_lab.gd:545 | 0.016 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| cast_segment | tools/manipulator.gd:484 | 0.025 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.021 | 2.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.017 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.016 | 1.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.014 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _update_pointer | ui/panels.gd:824 | 0.010 | 2.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.008 | 2.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.006 | 1.0 |
| update_input | xr/hand.gd:92 | 0.006 | 2.0 |
| get_values | core/feature_settings.gd:1063 | 0.006 | 2.0 |
| set_pose | xr/simulator.gd:353 | 0.006 | 2.0 |
| show_ray | xr/hand.gd:168 | 0.006 | 2.0 |
| set_pose | xr/simulator.gd:354 | 0.005 | 2.0 |
| get_binding | core/feature_settings.gd:1121 | 0.005 | 12.0 |
| is_action_pressed | xr/rig.gd:83 | 0.005 | 5.0 |
| _process | xr/session.gd:188 | 0.005 | 1.0 |
| find_at_point | tools/icons.gd:152 | 0.005 | 2.0 |
| cast_segment | tools/icons.gd:118 | 0.004 | 2.0 |
| binding_of | core/feature_settings.gd:1136 | 0.004 | 12.0 |
| _process | telemetry/graph_lab.gd:361 | 0.004 | 1.0 |
| is_holding | logic_graph/blueprints.gd:2332 | 0.003 | 2.0 |
| _update_desktop_ui | xr/session.gd:575 | 0.003 | 1.0 |
| hover_actions | logic_graph/blueprint_canvas.gd:3299 | 0.003 | 2.0 |
| get | core/feature_settings.gd:1130 | 0.003 | 12.0 |
| _process | ui/palette.gd:156 | 0.003 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.003 | 1.0 |
| update | xr/desktop_ui.gd:47 | 0.003 | 1.0 |
| get_cmdline_user_args | telemetry/graph_lab.gd:370 | 0.003 | 1.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.003 | 1.0 |

### 02 open

Frames 839, mean Main::iteration 6.05 ms; `process` 1.446 ms, of it its own C++ 0.260 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.260 | 18% |
| plugin: graph (logic_graph/) | 0.643 | 44% |
| plugin: tools (tools/) | 0.131 | 9% |
| plugin: panels and UI (ui/) | 0.107 | 7% |
| plugin: simulator (xr/simulator.gd) | 0.084 | 6% |
| plugin: controllers, rays, rig (xr/) | 0.079 | 5% |
| plugin: core (core/) | 0.076 | 5% |
| plugin: lab (telemetry/graph_lab.gd) | 0.048 | 3% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.475 | 1.0 |
| _process | ui/panels.gd:208 | 0.321 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.102 | 1.0 |
| _process | xr/simulator.gd:319 | 0.079 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.048 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.030 | 1.0 |
| _process | xr/session.gd:188 | 0.027 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
| _process | tools/undo.gd:24 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | tools/icons.gd:69 | 0.012 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.002 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.475 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.473 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.473 |
| _process | ui/panels.gd:208 | 0.321 |
| _update_pointer | ui/panels.gd:222 | 0.298 |
| _update_pointer | ui/panels.gd:824 | 0.298 |
| takes_pointer | ui/panels.gd:888 | 0.244 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.243 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.240 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.239 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.163 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.163 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.153 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.141 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3748 | 0.123 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.123 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.103 |
| _process | tools/manipulator.gd:296 | 0.102 |
| _process_frame | tools/manipulator.gd:298 | 0.101 |
| _process_frame | tools/manipulator.gd:302 | 0.100 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.099 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.099 |
| face_user | logic_graph/blueprints.gd:851 | 0.091 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.088 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.088 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.081 |
| _process | xr/simulator.gd:319 | 0.079 |
| _update_hover | tools/manipulator.gd:332 | 0.070 |
| _update_hover | tools/manipulator.gd:465 | 0.069 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.060 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.060 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.059 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.059 |
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.057 |
| is_action_pressed | xr/rig.gd:83 | 0.049 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.049 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.049 |
| _process | telemetry/graph_lab.gd:361 | 0.048 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.048 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.045 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.057 | 2.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.039 | 2.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.037 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.025 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.025 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.022 | 18.0 |
| find_at_point | tools/manipulator.gd:475 | 0.020 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.020 | 1.0 |
| cast_segment | tools/manipulator.gd:484 | 0.019 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.018 | 1.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.016 | 15.5 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.016 | 24.0 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.015 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.015 | 0.5 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.015 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| get_values | core/feature_settings.gd:1063 | 0.014 | 6.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.014 | 4.0 |
| _update_poses | xr/simulator.gd:335 | 0.014 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.011 | 2.0 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.009 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.009 | 24.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.009 | 18.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.007 | 7.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.007 | 6.0 |
| update_input | xr/hand.gd:92 | 0.006 | 2.0 |
| append | core/feature_settings.gd:1068 | 0.006 | 27.0 |

### 03 open_big2

Frames 843, mean Main::iteration 6.05 ms; `process` 1.630 ms, of it its own C++ 0.258 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.258 | 16% |
| plugin: graph (logic_graph/) | 0.834 | 51% |
| plugin: tools (tools/) | 0.135 | 8% |
| plugin: panels and UI (ui/) | 0.102 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.081 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.078 | 5% |
| plugin: core (core/) | 0.076 | 5% |
| plugin: lab (telemetry/graph_lab.gd) | 0.047 | 3% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.550 | 1.0 |
| _process | ui/panels.gd:208 | 0.433 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.107 | 1.0 |
| _process | xr/simulator.gd:319 | 0.076 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.047 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.029 | 1.0 |
| _process | xr/session.gd:188 | 0.026 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
| _process | tools/undo.gd:24 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | xr/rig.gd:54 | 0.012 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.550 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.548 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.548 |
| _process | ui/panels.gd:208 | 0.433 |
| _update_pointer | ui/panels.gd:222 | 0.411 |
| _update_pointer | ui/panels.gd:824 | 0.410 |
| takes_pointer | ui/panels.gd:888 | 0.359 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.358 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.355 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.355 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.246 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.234 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3748 | 0.216 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.215 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.181 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.181 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.160 |
| face_user | logic_graph/blueprints.gd:851 | 0.149 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.146 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.146 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.121 |
| _process | tools/manipulator.gd:296 | 0.107 |
| _process_frame | tools/manipulator.gd:298 | 0.106 |
| _process_frame | tools/manipulator.gd:302 | 0.105 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.102 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.101 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.100 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.100 |
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.099 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.099 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.098 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.082 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4711 | 0.079 |
| _process | xr/simulator.gd:319 | 0.076 |
| _update_hover | tools/manipulator.gd:332 | 0.074 |
| _update_hover | tools/manipulator.gd:465 | 0.074 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.071 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.068 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.067 |
| _link_wire_hit | logic_graph/blueprints.gd:7017 | 0.051 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.099 | 2.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.082 | 2.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.064 | 4.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.039 | 32.5 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.036 | 0.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.031 | 30.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.025 | 40.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.025 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.024 | 0.5 |
| cast_segment | tools/manipulator.gd:484 | 0.022 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.020 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.020 | 1.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.018 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.016 | 2.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.016 | 4.0 |
| _cast | ui/panel_surface.gd:626 | 0.015 | 24.0 |
| get_values | core/feature_settings.gd:1063 | 0.014 | 6.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.014 | 4.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.012 | 40.0 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.011 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.010 | 9.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.007 | 7.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| focus_paint | logic_graph/blueprint_canvas.gd:3077 | 0.007 | 32.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| update_input | xr/hand.gd:92 | 0.006 | 2.0 |

### 04 open

Frames 839, mean Main::iteration 6.05 ms; `process` 1.345 ms, of it its own C++ 0.235 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.235 | 17% |
| plugin: graph (logic_graph/) | 0.612 | 45% |
| plugin: tools (tools/) | 0.121 | 9% |
| plugin: panels and UI (ui/) | 0.096 | 7% |
| plugin: simulator (xr/simulator.gd) | 0.075 | 6% |
| plugin: controllers, rays, rig (xr/) | 0.073 | 5% |
| plugin: core (core/) | 0.072 | 5% |
| plugin: lab (telemetry/graph_lab.gd) | 0.045 | 3% |
| other GDScript | 0.011 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.454 | 1.0 |
| _process | ui/panels.gd:208 | 0.299 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.095 | 1.0 |
| _process | xr/simulator.gd:319 | 0.071 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.045 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.027 | 1.0 |
| _process | xr/session.gd:188 | 0.023 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.017 | 1.0 |
| _process | tools/undo.gd:24 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.012 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.010 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.005 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.454 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.453 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.452 |
| _process | ui/panels.gd:208 | 0.299 |
| _update_pointer | ui/panels.gd:222 | 0.278 |
| _update_pointer | ui/panels.gd:824 | 0.277 |
| takes_pointer | ui/panels.gd:888 | 0.230 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.229 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.226 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.226 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.158 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.157 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.143 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.131 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3748 | 0.115 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.115 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.102 |
| _process | tools/manipulator.gd:296 | 0.095 |
| _process_frame | tools/manipulator.gd:298 | 0.093 |
| _process_frame | tools/manipulator.gd:302 | 0.093 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.092 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.092 |
| face_user | logic_graph/blueprints.gd:851 | 0.091 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.089 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.088 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.079 |
| _process | xr/simulator.gd:319 | 0.071 |
| _update_hover | tools/manipulator.gd:332 | 0.065 |
| _update_hover | tools/manipulator.gd:465 | 0.064 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.059 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.058 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.056 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.056 |
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.054 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.049 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.048 |
| is_action_pressed | xr/rig.gd:83 | 0.047 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.047 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.046 |
| _process | telemetry/graph_lab.gd:361 | 0.045 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.054 | 2.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.037 | 4.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.035 | 2.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.025 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.024 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.022 | 18.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.019 | 1.0 |
| cast_segment | tools/manipulator.gd:484 | 0.018 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.018 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.017 | 1.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.017 | 15.5 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.016 | 24.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.015 | 0.5 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.015 | 2.0 |
| _cast | ui/panel_surface.gd:626 | 0.015 | 24.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.015 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| get_values | core/feature_settings.gd:1063 | 0.014 | 6.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.014 | 4.0 |
| _update_poses | xr/simulator.gd:335 | 0.012 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.011 | 2.0 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.009 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.009 | 2.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.008 | 24.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _pin_hand | ui/panels.gd:699 | 0.007 | 7.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.007 | 6.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| update_input | xr/hand.gd:92 | 0.006 | 2.0 |
| append | core/feature_settings.gd:1068 | 0.006 | 27.0 |

### 05 open_big2

Frames 841, mean Main::iteration 6.05 ms; `process` 1.581 ms, of it its own C++ 0.243 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.243 | 15% |
| plugin: graph (logic_graph/) | 0.816 | 52% |
| plugin: tools (tools/) | 0.130 | 8% |
| plugin: panels and UI (ui/) | 0.099 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.078 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.076 | 5% |
| plugin: core (core/) | 0.075 | 5% |
| plugin: lab (telemetry/graph_lab.gd) | 0.047 | 3% |
| other GDScript | 0.011 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.537 | 1.0 |
| _process | ui/panels.gd:208 | 0.424 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.103 | 1.0 |
| _process | xr/simulator.gd:319 | 0.074 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.047 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.029 | 1.0 |
| _process | xr/session.gd:188 | 0.024 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
| _process | tools/undo.gd:24 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.012 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.010 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.005 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.537 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.536 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.535 |
| _process | ui/panels.gd:208 | 0.424 |
| _update_pointer | ui/panels.gd:222 | 0.402 |
| _update_pointer | ui/panels.gd:824 | 0.401 |
| takes_pointer | ui/panels.gd:888 | 0.351 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.351 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.347 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.347 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.239 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.227 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3748 | 0.210 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.209 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.177 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.177 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.160 |
| face_user | logic_graph/blueprints.gd:851 | 0.149 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.147 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.147 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.122 |
| _process | tools/manipulator.gd:296 | 0.103 |
| _process_frame | tools/manipulator.gd:298 | 0.101 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.101 |
| _process_frame | tools/manipulator.gd:302 | 0.101 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.100 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.098 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.098 |
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.096 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.094 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.094 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.083 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4711 | 0.080 |
| _process | xr/simulator.gd:319 | 0.074 |
| _update_hover | tools/manipulator.gd:332 | 0.071 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.071 |
| _update_hover | tools/manipulator.gd:465 | 0.071 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.067 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.067 |
| _link_wire_hit | logic_graph/blueprints.gd:7017 | 0.052 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.096 | 2.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.080 | 2.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.065 | 4.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.040 | 32.5 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.035 | 0.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.031 | 30.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.025 | 40.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.024 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.024 | 2.0 |
| cast_segment | tools/manipulator.gd:484 | 0.022 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.019 | 1.0 |
| find_at_point | tools/manipulator.gd:475 | 0.019 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.017 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.016 | 2.0 |
| _cast | ui/panel_surface.gd:626 | 0.015 | 24.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.015 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| get_values | core/feature_settings.gd:1063 | 0.014 | 6.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.014 | 4.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.012 | 40.0 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.011 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.010 | 9.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.009 | 2.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.007 | 7.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| focus_paint | logic_graph/blueprint_canvas.gd:3077 | 0.007 | 32.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| update_input | xr/hand.gd:92 | 0.006 | 2.0 |
