
### 01 closed

Frames 841, mean Main::iteration 6.05 ms; `process` 0.799 ms, of it its own C++ 0.247 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.247 | 31% |
| plugin: graph (logic_graph/) | 0.128 | 16% |
| plugin: tools (tools/) | 0.126 | 16% |
| plugin: simulator (xr/simulator.gd) | 0.082 | 10% |
| plugin: controllers, rays, rig (xr/) | 0.071 | 9% |
| plugin: core (core/) | 0.058 | 7% |
| plugin: lab (telemetry/graph_lab.gd) | 0.045 | 6% |
| plugin: panels and UI (ui/) | 0.038 | 5% |
| plugin: other (playmode) | 0.005 | 1% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.123 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.107 | 1.0 |
| _process | xr/simulator.gd:319 | 0.077 | 1.0 |
| _process | ui/panels.gd:208 | 0.052 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.045 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.028 | 1.0 |
| _process | xr/session.gd:188 | 0.025 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
| _process | tools/undo.gd:24 | 0.016 | 1.0 |
| _process | xr/simulator.gd:474 | 0.014 | 1.0 |
| _process | tools/icons.gd:69 | 0.011 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.010 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.123 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.122 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.121 |
| _process | tools/manipulator.gd:296 | 0.107 |
| _process_frame | tools/manipulator.gd:298 | 0.105 |
| _process_frame | tools/manipulator.gd:302 | 0.105 |
| _update_hover | tools/manipulator.gd:332 | 0.077 |
| _process | xr/simulator.gd:319 | 0.077 |
| _update_hover | tools/manipulator.gd:465 | 0.077 |
| _process | ui/panels.gd:208 | 0.052 |
| is_action_pressed | xr/rig.gd:83 | 0.047 |
| _process | telemetry/graph_lab.gd:361 | 0.045 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.044 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.043 |
| _update_pointer | ui/panels.gd:222 | 0.036 |
| _update_pointer | ui/panels.gd:824 | 0.036 |
| _update_inputs | xr/simulator.gd:325 | 0.032 |
| _update_inputs | xr/simulator.gd:357 | 0.032 |
| binding_of | core/feature_settings.gd:1136 | 0.030 |
| _process | tools/locomotion.gd:108 | 0.028 |
| get_action_hand | xr/rig.gd:78 | 0.028 |
| _update_poses | xr/simulator.gd:324 | 0.027 |
| _update_poses | xr/simulator.gd:335 | 0.026 |
| get_binding | core/feature_settings.gd:1137 | 0.026 |
| _process | xr/session.gd:188 | 0.025 |
| cast_segment | tools/manipulator.gd:484 | 0.025 |
| get_binding | core/feature_settings.gd:1121 | 0.024 |
| find_at_point | tools/manipulator.gd:475 | 0.020 |
| _report | telemetry/graph_lab.gd:379 | 0.019 |
| _report | telemetry/graph_lab.gd:493 | 0.019 |
| _report_frames | telemetry/graph_lab.gd:499 | 0.018 |
| _report_frames | telemetry/graph_lab.gd:503 | 0.018 |
| get_action_hand | xr/rig.gd:87 | 0.018 |
| _process | tools/selection_counter.gd:87 | 0.018 |
| hover_actions | logic_graph/blueprints.gd:3027 | 0.017 |
| binding_of | xr/rig.gd:79 | 0.017 |
| hover_actions | logic_graph/blueprint_canvas.gd:3299 | 0.016 |
| _refresh_views | telemetry/graph_lab.gd:510 | 0.016 |
| _refresh_views | telemetry/graph_lab.gd:545 | 0.016 |
| _process | tools/undo.gd:24 | 0.016 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| cast_segment | tools/manipulator.gd:484 | 0.025 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.020 | 2.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.016 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.016 | 1.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.014 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _update_pointer | ui/panels.gd:824 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.008 | 2.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.006 | 1.0 |
| set_pose | xr/simulator.gd:353 | 0.006 | 2.0 |
| get_values | core/feature_settings.gd:1063 | 0.006 | 2.0 |
| update_input | xr/hand.gd:92 | 0.006 | 2.0 |
| show_ray | xr/hand.gd:168 | 0.005 | 2.0 |
| get_binding | core/feature_settings.gd:1121 | 0.005 | 12.0 |
| set_pose | xr/simulator.gd:354 | 0.005 | 2.0 |
| is_action_pressed | xr/rig.gd:83 | 0.005 | 5.0 |
| _process | xr/session.gd:188 | 0.004 | 1.0 |
| find_at_point | tools/icons.gd:152 | 0.004 | 2.0 |
| cast_segment | tools/icons.gd:118 | 0.004 | 2.0 |
| binding_of | core/feature_settings.gd:1136 | 0.004 | 12.0 |
| get | core/feature_settings.gd:1130 | 0.004 | 12.0 |
| _update_desktop_ui | xr/session.gd:575 | 0.003 | 1.0 |
| hover_actions | logic_graph/blueprint_canvas.gd:3299 | 0.003 | 2.0 |
| _process | ui/palette.gd:156 | 0.003 | 1.0 |
| update | xr/desktop_ui.gd:47 | 0.003 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.003 | 1.0 |
| is_holding | logic_graph/blueprints.gd:2332 | 0.003 | 2.0 |
| _process | tools/clipboard.gd:96 | 0.003 | 1.0 |
| get_cmdline_user_args | telemetry/graph_lab.gd:370 | 0.003 | 1.0 |
| get | xr/simulator.gd:330 | 0.003 | 17.0 |

### 02 open

Frames 839, mean Main::iteration 6.07 ms; `process` 1.816 ms, of it its own C++ 0.296 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.296 | 16% |
| plugin: graph (logic_graph/) | 0.943 | 52% |
| plugin: tools (tools/) | 0.145 | 8% |
| plugin: panels and UI (ui/) | 0.113 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.088 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.081 | 4% |
| plugin: core (core/) | 0.080 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.050 | 3% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.006 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.683 | 1.0 |
| _process | ui/panels.gd:208 | 0.420 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.115 | 1.0 |
| _process | xr/simulator.gd:319 | 0.083 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.050 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.031 | 1.0 |
| _process | xr/session.gd:188 | 0.028 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.020 | 1.0 |
| _process | tools/undo.gd:24 | 0.018 | 1.0 |
| _process | xr/simulator.gd:474 | 0.014 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.012 | 1.0 |
| _process | tools/icons.gd:69 | 0.012 | 1.0 |
| _process | xr/rig.gd:54 | 0.012 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.683 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.681 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.681 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.427 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3737 | 0.425 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.424 |
| _process | ui/panels.gd:208 | 0.420 |
| _update_pointer | ui/panels.gd:222 | 0.398 |
| _update_pointer | ui/panels.gd:824 | 0.397 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.353 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.352 |
| takes_pointer | ui/panels.gd:888 | 0.340 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.339 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.336 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.335 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.312 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.311 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.252 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.232 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4273 | 0.229 |
| intersect_ray | logic_graph/blueprints.gd:2930 | 0.196 |
| _process | tools/manipulator.gd:296 | 0.115 |
| _process_frame | tools/manipulator.gd:298 | 0.113 |
| _process_frame | tools/manipulator.gd:302 | 0.112 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.110 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.104 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.104 |
| face_user | logic_graph/blueprints.gd:851 | 0.098 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.094 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.094 |
| _process | xr/simulator.gd:319 | 0.083 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.083 |
| _update_hover | tools/manipulator.gd:332 | 0.079 |
| _update_hover | tools/manipulator.gd:465 | 0.078 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.074 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.072 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.060 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.059 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.051 |
| is_action_pressed | xr/rig.gd:83 | 0.051 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.125 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.072 | 140.2 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.072 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.051 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.042 | 78.1 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.036 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.028 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.026 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.023 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.023 | 18.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.021 | 1.0 |
| cast_segment | tools/manipulator.gd:484 | 0.021 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.020 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.020 | 4.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.017 | 24.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.017 | 15.5 |
| _cast | ui/panel_surface.gd:626 | 0.017 | 24.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.016 | 0.5 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.016 | 2.0 |
| get_values | core/feature_settings.gd:1063 | 0.015 | 6.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.015 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.015 | 1.0 |
| update | xr/simulator.gd:427 | 0.014 | 1.0 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.012 | 128.2 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.010 | 24.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.010 | 18.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.009 | 12.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| _process | xr/simulator.gd:474 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |

### 03 open_big2

Frames 842, mean Main::iteration 6.05 ms; `process` 2.232 ms, of it its own C++ 0.282 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.282 | 13% |
| plugin: graph (logic_graph/) | 1.383 | 62% |
| plugin: tools (tools/) | 0.144 | 6% |
| plugin: panels and UI (ui/) | 0.107 | 5% |
| plugin: simulator (xr/simulator.gd) | 0.086 | 4% |
| plugin: controllers, rays, rig (xr/) | 0.080 | 4% |
| plugin: core (core/) | 0.080 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.050 | 2% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.006 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.933 | 1.0 |
| _process | ui/panels.gd:208 | 0.605 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.116 | 1.0 |
| _process | xr/simulator.gd:319 | 0.081 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.050 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.030 | 1.0 |
| _process | xr/session.gd:188 | 0.027 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.019 | 1.0 |
| _process | tools/undo.gd:24 | 0.019 | 1.0 |
| _process | xr/simulator.gd:474 | 0.014 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.011 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.933 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.931 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.931 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.769 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3737 | 0.767 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.766 |
| _process | ui/panels.gd:208 | 0.605 |
| _update_pointer | ui/panels.gd:222 | 0.583 |
| _update_pointer | ui/panels.gd:824 | 0.583 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.570 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.569 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.545 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.545 |
| takes_pointer | ui/panels.gd:888 | 0.531 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.530 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.527 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.526 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.478 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4273 | 0.445 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.404 |
| intersect_ray | logic_graph/blueprints.gd:2930 | 0.366 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.168 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.158 |
| face_user | logic_graph/blueprints.gd:851 | 0.156 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.156 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.153 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.152 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.121 |
| _process | tools/manipulator.gd:296 | 0.116 |
| _process_frame | tools/manipulator.gd:298 | 0.114 |
| _process_frame | tools/manipulator.gd:302 | 0.113 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.102 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.102 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.098 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.097 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4295 | 0.092 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.083 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.082 |
| _process | xr/simulator.gd:319 | 0.081 |
| _update_hover | tools/manipulator.gd:332 | 0.081 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.221 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.156 | 266.3 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.140 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.083 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.079 | 156.2 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.059 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.041 | 0.5 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.039 | 32.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.031 | 30.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.027 | 2.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.026 | 40.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.025 | 0.5 |
| cast_segment | tools/manipulator.gd:484 | 0.024 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.023 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.021 | 248.3 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.021 | 1.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.020 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.020 | 4.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.016 | 2.0 |
| get_values | core/feature_settings.gd:1063 | 0.016 | 6.0 |
| _cast | ui/panel_surface.gd:626 | 0.015 | 24.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.015 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.014 | 1.0 |
| update | xr/simulator.gd:427 | 0.014 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.013 | 40.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4295 | 0.013 | 156.2 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.011 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.010 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.009 | 12.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| _process | xr/simulator.gd:474 | 0.008 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.007 | 7.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |

### 04 open

Frames 840, mean Main::iteration 6.07 ms; `process` 1.624 ms, of it its own C++ 0.239 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.239 | 15% |
| plugin: graph (logic_graph/) | 0.876 | 54% |
| plugin: tools (tools/) | 0.125 | 8% |
| plugin: panels and UI (ui/) | 0.098 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.076 | 5% |
| plugin: core (core/) | 0.074 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.072 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.046 | 3% |
| other GDScript | 0.011 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.638 | 1.0 |
| _process | ui/panels.gd:208 | 0.382 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.100 | 1.0 |
| _process | xr/simulator.gd:319 | 0.072 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.046 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.027 | 1.0 |
| _process | xr/session.gd:188 | 0.023 | 1.0 |
| _process | tools/undo.gd:24 | 0.018 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.012 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.010 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.005 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.004 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.638 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.637 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.636 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.405 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3737 | 0.403 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.402 |
| _process | ui/panels.gd:208 | 0.382 |
| _update_pointer | ui/panels.gd:222 | 0.361 |
| _update_pointer | ui/panels.gd:824 | 0.361 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.338 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.337 |
| takes_pointer | ui/panels.gd:888 | 0.312 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.311 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.308 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.307 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.300 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.300 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.243 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4273 | 0.221 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.215 |
| intersect_ray | logic_graph/blueprints.gd:2930 | 0.191 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.104 |
| _process | tools/manipulator.gd:296 | 0.100 |
| _process_frame | tools/manipulator.gd:298 | 0.098 |
| _process_frame | tools/manipulator.gd:302 | 0.098 |
| face_user | logic_graph/blueprints.gd:851 | 0.094 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.093 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.093 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.091 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.091 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.076 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.073 |
| _process | xr/simulator.gd:319 | 0.072 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.071 |
| _update_hover | tools/manipulator.gd:332 | 0.068 |
| _update_hover | tools/manipulator.gd:465 | 0.068 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.055 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.054 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.048 |
| is_action_pressed | xr/rig.gd:83 | 0.048 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.119 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.071 | 140.2 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.064 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.048 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.041 | 78.1 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.033 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.027 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.024 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.022 | 18.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.019 | 1.0 |
| find_at_point | tools/manipulator.gd:475 | 0.019 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.019 | 4.0 |
| cast_segment | tools/manipulator.gd:484 | 0.019 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.018 | 1.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.016 | 15.5 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.016 | 24.0 |
| _cast | ui/panel_surface.gd:626 | 0.015 | 24.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.015 | 0.5 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.015 | 2.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.014 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| get_values | core/feature_settings.gd:1063 | 0.014 | 6.0 |
| _update_poses | xr/simulator.gd:335 | 0.012 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.012 | 128.2 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.009 | 1.0 |
| _update_inputs | xr/simulator.gd:357 | 0.009 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.008 | 24.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _pin_hand | ui/panels.gd:699 | 0.007 | 7.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4295 | 0.006 | 78.1 |

### 05 open_big2

Frames 842, mean Main::iteration 6.05 ms; `process` 2.292 ms, of it its own C++ 0.288 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.288 | 13% |
| plugin: graph (logic_graph/) | 1.420 | 62% |
| plugin: tools (tools/) | 0.149 | 7% |
| plugin: panels and UI (ui/) | 0.111 | 5% |
| plugin: simulator (xr/simulator.gd) | 0.089 | 4% |
| plugin: controllers, rays, rig (xr/) | 0.083 | 4% |
| plugin: core (core/) | 0.081 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.051 | 2% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.006 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.946 | 1.0 |
| _process | ui/panels.gd:208 | 0.634 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.119 | 1.0 |
| _process | xr/simulator.gd:319 | 0.084 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.051 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.031 | 1.0 |
| _process | xr/session.gd:188 | 0.028 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.020 | 1.0 |
| _process | tools/undo.gd:24 | 0.018 | 1.0 |
| _process | xr/simulator.gd:474 | 0.014 | 1.0 |
| _process | tools/icons.gd:69 | 0.012 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.012 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.946 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.944 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.944 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.792 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3737 | 0.790 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.789 |
| _process | ui/panels.gd:208 | 0.634 |
| _update_pointer | ui/panels.gd:222 | 0.611 |
| _update_pointer | ui/panels.gd:824 | 0.611 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.583 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.582 |
| takes_pointer | ui/panels.gd:888 | 0.556 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.556 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.553 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.553 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.552 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.552 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.489 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4273 | 0.455 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.423 |
| intersect_ray | logic_graph/blueprints.gd:2930 | 0.370 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.170 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.162 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.159 |
| face_user | logic_graph/blueprints.gd:851 | 0.158 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.155 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.154 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.126 |
| _process | tools/manipulator.gd:296 | 0.119 |
| _process_frame | tools/manipulator.gd:298 | 0.117 |
| _process_frame | tools/manipulator.gd:302 | 0.116 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.103 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.103 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.102 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.101 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4295 | 0.094 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.084 |
| _process | xr/simulator.gd:319 | 0.084 |
| _update_hover | tools/manipulator.gd:332 | 0.083 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.083 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4286 | 0.225 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.159 | 266.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.149 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4308 | 0.084 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4327 | 0.081 | 156.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.063 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.041 | 0.5 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.039 | 32.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.031 | 30.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.028 | 2.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.027 | 40.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.026 | 0.5 |
| cast_segment | tools/manipulator.gd:484 | 0.026 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.024 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4291 | 0.022 | 248.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.021 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.021 | 4.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.020 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.016 | 2.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.016 | 4.0 |
| get_values | core/feature_settings.gd:1063 | 0.016 | 6.0 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| _update_poses | xr/simulator.gd:335 | 0.015 | 1.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| update | xr/simulator.gd:427 | 0.014 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.014 | 40.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4295 | 0.013 | 156.0 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.011 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.010 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.009 | 12.0 |
| _process | tools/icons.gd:69 | 0.009 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process | xr/simulator.gd:474 | 0.008 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.008 | 18.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
