logs/editor_sim_2026-11-10T19-33-35 (benchmarks/tracy_process.py)

| Step | `process` | Graph scripts (`blueprints.gd` _process) | Ray routing from the panels (`_takes_pointer`) | Panels without the routing | Manipulator | `process` own C++ | Simulator | Lab | Other scripts |
|---|---|---|---|---|---|---|---|---|---|
| 01 closed | 0.776 | 0.120 | 0.010 | 0.043 | 0.104 | 0.240 | 0.087 | 0.042 | 0.130 |
| 02 open | 1.682 | 0.664 | 0.315 | 0.082 | 0.105 | 0.243 | 0.088 | 0.043 | 0.142 |
| 03 open_big2 | 2.047 | 0.888 | 0.497 | 0.073 | 0.102 | 0.228 | 0.082 | 0.045 | 0.132 |
| 04 open | 1.728 | 0.675 | 0.317 | 0.079 | 0.111 | 0.258 | 0.092 | 0.047 | 0.149 |
| 05 open_big2 | 2.209 | 0.949 | 0.533 | 0.079 | 0.111 | 0.255 | 0.090 | 0.048 | 0.144 |
| 06 closed | 0.796 | 0.130 | 0.010 | 0.042 | 0.117 | 0.230 | 0.086 | 0.046 | 0.135 |

### 01 closed

Frames 832, mean Main::iteration 6.11 ms; `process` 0.776 ms, of it its own C++ 0.240 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.240 | 31% |
| plugin: graph (logic_graph/) | 0.125 | 16% |
| plugin: tools (tools/) | 0.122 | 16% |
| plugin: simulator (xr/simulator.gd) | 0.078 | 10% |
| plugin: controllers, rays, rig (xr/) | 0.069 | 9% |
| plugin: core (core/) | 0.057 | 7% |
| plugin: lab (telemetry/graph_lab.gd) | 0.042 | 5% |
| plugin: panels and UI (ui/) | 0.037 | 5% |
| plugin: other (playmode) | 0.005 | 1% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.120 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.104 | 1.0 |
| _process | xr/simulator.gd:319 | 0.074 | 1.0 |
| _process | ui/panels.gd:208 | 0.053 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.042 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.027 | 1.0 |
| _process | xr/session.gd:188 | 0.023 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
| _process | tools/undo.gd:24 | 0.016 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.010 | 1.0 |
| _process | tools/icons.gd:69 | 0.010 | 1.0 |
| _process | xr/rig.gd:54 | 0.010 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.120 |
| _process_frame | logic_graph/blueprints.gd:804 | 0.119 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.118 |
| _process | tools/manipulator.gd:296 | 0.104 |
| _process_frame | tools/manipulator.gd:298 | 0.103 |
| _process_frame | tools/manipulator.gd:302 | 0.102 |
| _update_hover | tools/manipulator.gd:332 | 0.075 |
| _update_hover | tools/manipulator.gd:465 | 0.074 |
| _process | xr/simulator.gd:319 | 0.074 |
| _process | ui/panels.gd:208 | 0.053 |
| is_action_pressed | xr/rig.gd:83 | 0.047 |
| _update_pointer | logic_graph/blueprints.gd:865 | 0.043 |
| _process | telemetry/graph_lab.gd:361 | 0.042 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.042 |
| _update_pointer | ui/panels.gd:222 | 0.036 |
| _update_pointer | ui/panels.gd:824 | 0.036 |
| _update_inputs | xr/simulator.gd:325 | 0.031 |
| _update_inputs | xr/simulator.gd:357 | 0.030 |
| binding_of | core/feature_settings.gd:1114 | 0.029 |
| _process | tools/locomotion.gd:108 | 0.027 |
| get_action_hand | xr/rig.gd:78 | 0.027 |
| _update_poses | xr/simulator.gd:324 | 0.026 |
| get_binding | core/feature_settings.gd:1115 | 0.025 |
| _update_poses | xr/simulator.gd:335 | 0.025 |
| get_binding | core/feature_settings.gd:1099 | 0.024 |
| cast_segment | tools/manipulator.gd:484 | 0.023 |
| _process | xr/session.gd:188 | 0.023 |
| find_at_point | tools/manipulator.gd:475 | 0.020 |
| _report | telemetry/graph_lab.gd:379 | 0.019 |
| _report | telemetry/graph_lab.gd:493 | 0.019 |
| _report_frames | telemetry/graph_lab.gd:499 | 0.019 |
| _report_frames | telemetry/graph_lab.gd:503 | 0.019 |
| get_action_hand | xr/rig.gd:87 | 0.018 |
| _process | tools/selection_counter.gd:87 | 0.018 |
| _refresh_views | telemetry/graph_lab.gd:510 | 0.017 |
| _refresh_views | telemetry/graph_lab.gd:545 | 0.017 |
| binding_of | xr/rig.gd:79 | 0.016 |
| hover_actions | logic_graph/blueprints.gd:3025 | 0.016 |
| _process | tools/undo.gd:24 | 0.016 |
| hover_actions | logic_graph/blueprint_canvas.gd:3193 | 0.016 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| cast_segment | tools/manipulator.gd:484 | 0.023 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.020 | 2.0 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.016 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.016 | 1.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.009 | 1.0 |
| _update_pointer | ui/panels.gd:824 | 0.009 | 2.0 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.008 | 2.0 |
| button_input | core/feature_settings.gd:1124 | 0.008 | 12.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1119 | 0.007 | 14.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.006 | 1.0 |
| preset_binding | core/feature_settings.gd:1107 | 0.006 | 12.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.006 | 1.0 |
| get_values | core/feature_settings.gd:1041 | 0.006 | 2.0 |
| set_pose | xr/simulator.gd:353 | 0.006 | 2.0 |
| update_input | xr/hand.gd:92 | 0.005 | 2.0 |
| set_pose | xr/simulator.gd:354 | 0.005 | 2.0 |
| show_ray | xr/hand.gd:168 | 0.005 | 2.0 |
| is_action_pressed | xr/rig.gd:83 | 0.005 | 5.0 |
| get_binding | core/feature_settings.gd:1099 | 0.005 | 12.0 |
| find_at_point | tools/icons.gd:152 | 0.005 | 2.0 |
| _process | xr/session.gd:188 | 0.004 | 1.0 |
| cast_segment | tools/icons.gd:118 | 0.004 | 2.0 |
| binding_of | core/feature_settings.gd:1114 | 0.004 | 12.0 |
| _process | telemetry/graph_lab.gd:361 | 0.003 | 1.0 |
| is_holding | logic_graph/blueprints.gd:2330 | 0.003 | 2.0 |
| get | core/feature_settings.gd:1108 | 0.003 | 12.0 |
| hover_actions | logic_graph/blueprint_canvas.gd:3193 | 0.003 | 2.0 |
| _update_desktop_ui | xr/session.gd:575 | 0.003 | 1.0 |
| update | xr/desktop_ui.gd:47 | 0.003 | 1.0 |
| poll_trigger | ui/virtual_keyboard.gd:233 | 0.003 | 2.0 |
| get_layout | core/feature_settings.gd:1083 | 0.003 | 12.0 |
| _process | tools/clipboard.gd:96 | 0.003 | 1.0 |
| _process | ui/palette.gd:156 | 0.003 | 1.0 |

### 02 open

Frames 853, mean Main::iteration 6.05 ms; `process` 1.682 ms, of it its own C++ 0.243 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.243 | 14% |
| plugin: graph (logic_graph/) | 0.920 | 55% |
| plugin: tools (tools/) | 0.131 | 8% |
| plugin: panels and UI (ui/) | 0.109 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.080 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.076 | 5% |
| plugin: core (core/) | 0.062 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.043 | 3% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.664 | 1.0 |
| _process | ui/panels.gd:208 | 0.397 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.105 | 1.0 |
| _process | xr/simulator.gd:319 | 0.076 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.043 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.028 | 1.0 |
| _process | xr/session.gd:188 | 0.024 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.019 | 1.0 |
| _process | tools/undo.gd:24 | 0.018 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
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
| _process | logic_graph/blueprints.gd:802 | 0.664 |
| _process_frame | logic_graph/blueprints.gd:804 | 0.663 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.663 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.426 |
| _process | ui/panels.gd:208 | 0.397 |
| _update_pointer | ui/panels.gd:222 | 0.375 |
| _update_pointer | ui/panels.gd:824 | 0.375 |
| _update_pointer | logic_graph/blueprints.gd:865 | 0.353 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.352 |
| takes_pointer | ui/panels.gd:888 | 0.319 |
| takes_pointer | logic_graph/blueprints.gd:3286 | 0.318 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:3933 | 0.317 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4016 | 0.316 |
| _takes_pointer | logic_graph/blueprints.gd:3288 | 0.315 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.314 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.257 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4017 | 0.233 |
| intersect_ray | logic_graph/blueprints.gd:3318 | 0.225 |
| intersect_ray | logic_graph/blueprints.gd:2928 | 0.202 |
| face_user | logic_graph/blueprint_canvas.gd:2476 | 0.106 |
| _process | tools/manipulator.gd:296 | 0.105 |
| _process_frame | tools/manipulator.gd:298 | 0.103 |
| _process_frame | tools/manipulator.gd:302 | 0.103 |
| _update_target_wires | logic_graph/blueprints.gd:889 | 0.099 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.098 |
| face_user | logic_graph/blueprints.gd:849 | 0.095 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2483 | 0.092 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.092 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.080 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.077 |
| _process | xr/simulator.gd:319 | 0.076 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.075 |
| _update_hover | tools/manipulator.gd:332 | 0.072 |
| _update_hover | tools/manipulator.gd:465 | 0.071 |
| intersect_link_wire | logic_graph/blueprints.gd:6981 | 0.058 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.057 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.051 |
| is_action_pressed | xr/rig.gd:83 | 0.050 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.050 |
| _link_wire_hit | logic_graph/blueprints.gd:3314 | 0.048 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.126 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.075 | 140.2 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.069 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.051 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4071 | 0.043 | 78.1 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.034 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4451 | 0.028 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.026 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4464 | 0.023 | 18.0 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.021 | 1.0 |
| find_at_point | tools/manipulator.gd:475 | 0.020 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:667 | 0.020 | 4.0 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.019 | 1.0 |
| cast_segment | tools/manipulator.gd:484 | 0.019 | 2.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5620 | 0.018 | 24.0 |
| _cast | ui/panel_surface.gd:626 | 0.017 | 24.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4559 | 0.017 | 15.5 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.016 | 2.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.015 | 4.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.015 | 0.5 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.013 | 128.2 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.009 | 18.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6075 | 0.009 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5625 | 0.009 | 24.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.008 | 1.0 |
| button_input | core/feature_settings.gd:1124 | 0.008 | 12.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| button_hand | core/feature_settings.gd:1119 | 0.008 | 14.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| preset_binding | core/feature_settings.gd:1107 | 0.007 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.007 | 78.1 |

### 03 open_big2

Frames 835, mean Main::iteration 6.09 ms; `process` 2.047 ms, of it its own C++ 0.228 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.228 | 11% |
| plugin: graph (logic_graph/) | 1.327 | 65% |
| plugin: tools (tools/) | 0.126 | 6% |
| plugin: panels and UI (ui/) | 0.099 | 5% |
| plugin: simulator (xr/simulator.gd) | 0.075 | 4% |
| plugin: controllers, rays, rig (xr/) | 0.072 | 3% |
| plugin: core (core/) | 0.059 | 3% |
| plugin: lab (telemetry/graph_lab.gd) | 0.045 | 2% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.888 | 1.0 |
| _process | ui/panels.gd:208 | 0.570 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.102 | 1.0 |
| _process | xr/simulator.gd:319 | 0.070 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.045 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.026 | 1.0 |
| _process | xr/session.gd:188 | 0.022 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.017 | 1.0 |
| _process | tools/undo.gd:24 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.012 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | xr/rig.gd:54 | 0.010 | 1.0 |
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
| _process | logic_graph/blueprints.gd:802 | 0.888 |
| _process_frame | logic_graph/blueprints.gd:804 | 0.887 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.887 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.757 |
| _process | ui/panels.gd:208 | 0.570 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:3933 | 0.569 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4016 | 0.568 |
| _update_pointer | ui/panels.gd:222 | 0.550 |
| _update_pointer | ui/panels.gd:824 | 0.549 |
| _update_pointer | logic_graph/blueprints.gd:865 | 0.530 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.529 |
| takes_pointer | ui/panels.gd:888 | 0.501 |
| takes_pointer | logic_graph/blueprints.gd:3286 | 0.500 |
| _takes_pointer | logic_graph/blueprints.gd:3288 | 0.497 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.496 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.479 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4017 | 0.445 |
| intersect_ray | logic_graph/blueprints.gd:3318 | 0.392 |
| intersect_ray | logic_graph/blueprints.gd:2928 | 0.366 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.163 |
| face_user | logic_graph/blueprint_canvas.gd:2476 | 0.159 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.159 |
| face_user | logic_graph/blueprints.gd:849 | 0.149 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2483 | 0.146 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.146 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.114 |
| _process | tools/manipulator.gd:296 | 0.102 |
| _process_frame | tools/manipulator.gd:298 | 0.101 |
| _process_frame | tools/manipulator.gd:302 | 0.100 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.094 |
| _update_target_wires | logic_graph/blueprints.gd:889 | 0.094 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.093 |
| intersect_link_wire | logic_graph/blueprints.gd:6981 | 0.093 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.092 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4071 | 0.081 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4464 | 0.081 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.081 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4448 | 0.078 |
| _update_hover | tools/manipulator.gd:332 | 0.071 |
| _process | xr/simulator.gd:319 | 0.070 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.214 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.159 | 266.3 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.133 | 4.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4071 | 0.081 | 156.2 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.081 | 12.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.055 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4451 | 0.039 | 0.5 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4464 | 0.038 | 32.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4559 | 0.030 | 30.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5620 | 0.026 | 40.0 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.025 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.022 | 248.3 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.022 | 0.5 |
| cast_segment | tools/manipulator.gd:484 | 0.021 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.020 | 1.0 |
| find_at_point | tools/manipulator.gd:475 | 0.019 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:667 | 0.019 | 4.0 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.018 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.016 | 2.0 |
| _cast | ui/panel_surface.gd:626 | 0.015 | 24.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.014 | 4.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.013 | 156.2 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5625 | 0.012 | 40.0 |
| _update_poses | xr/simulator.gd:335 | 0.012 | 1.0 |
| update | xr/simulator.gd:427 | 0.011 | 1.0 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.009 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6075 | 0.009 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1124 | 0.008 | 12.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| button_hand | core/feature_settings.gd:1119 | 0.007 | 14.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| focus_paint | logic_graph/blueprint_canvas.gd:2974 | 0.007 | 32.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| _process | xr/simulator.gd:474 | 0.006 | 1.0 |

### 04 open

Frames 854, mean Main::iteration 6.06 ms; `process` 1.728 ms, of it its own C++ 0.258 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.258 | 15% |
| plugin: graph (logic_graph/) | 0.934 | 54% |
| plugin: tools (tools/) | 0.139 | 8% |
| plugin: panels and UI (ui/) | 0.104 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.084 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.078 | 5% |
| plugin: core (core/) | 0.064 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.047 | 3% |
| other GDScript | 0.013 | 1% |
| plugin: other (playmode) | 0.006 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.675 | 1.0 |
| _process | ui/panels.gd:208 | 0.396 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.111 | 1.0 |
| _process | xr/simulator.gd:319 | 0.079 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.047 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.029 | 1.0 |
| _process | xr/session.gd:188 | 0.025 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.020 | 1.0 |
| _process | tools/undo.gd:24 | 0.019 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.012 | 1.0 |
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
| _process | logic_graph/blueprints.gd:802 | 0.675 |
| _process_frame | logic_graph/blueprints.gd:804 | 0.673 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.673 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.425 |
| _process | ui/panels.gd:208 | 0.396 |
| _update_pointer | ui/panels.gd:222 | 0.373 |
| _update_pointer | ui/panels.gd:824 | 0.373 |
| _update_pointer | logic_graph/blueprints.gd:865 | 0.351 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.350 |
| takes_pointer | ui/panels.gd:888 | 0.321 |
| takes_pointer | logic_graph/blueprints.gd:3286 | 0.320 |
| _takes_pointer | logic_graph/blueprints.gd:3288 | 0.317 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.316 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:3933 | 0.316 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4016 | 0.315 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.256 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4017 | 0.232 |
| intersect_ray | logic_graph/blueprints.gd:3318 | 0.224 |
| intersect_ray | logic_graph/blueprints.gd:2928 | 0.202 |
| _process | tools/manipulator.gd:296 | 0.111 |
| face_user | logic_graph/blueprint_canvas.gd:2476 | 0.111 |
| _process_frame | tools/manipulator.gd:298 | 0.110 |
| _process_frame | tools/manipulator.gd:302 | 0.109 |
| _update_target_wires | logic_graph/blueprints.gd:889 | 0.102 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.101 |
| face_user | logic_graph/blueprints.gd:849 | 0.099 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2483 | 0.096 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.096 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.082 |
| _process | xr/simulator.gd:319 | 0.079 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.077 |
| _update_hover | tools/manipulator.gd:332 | 0.076 |
| _update_hover | tools/manipulator.gd:465 | 0.075 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.075 |
| intersect_link_wire | logic_graph/blueprints.gd:6981 | 0.060 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.059 |
| is_action_pressed | xr/rig.gd:83 | 0.052 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.051 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.050 |
| _link_wire_hit | logic_graph/blueprints.gd:3314 | 0.050 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.125 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.075 | 140.2 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.068 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.051 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4071 | 0.043 | 78.1 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.036 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4451 | 0.030 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.026 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4464 | 0.023 | 18.0 |
| find_at_point | tools/manipulator.gd:475 | 0.022 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.021 | 1.0 |
| cast_segment | tools/manipulator.gd:484 | 0.020 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:667 | 0.020 | 4.0 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.019 | 1.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5620 | 0.018 | 24.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4559 | 0.017 | 15.5 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.016 | 2.0 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.016 | 0.5 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.015 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.012 | 128.1 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6075 | 0.009 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5625 | 0.009 | 24.0 |
| button_input | core/feature_settings.gd:1124 | 0.009 | 12.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| button_hand | core/feature_settings.gd:1119 | 0.008 | 14.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| preset_binding | core/feature_settings.gd:1107 | 0.007 | 12.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.007 | 78.1 |

### 05 open_big2

Frames 853, mean Main::iteration 6.07 ms; `process` 2.209 ms, of it its own C++ 0.255 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.255 | 12% |
| plugin: graph (logic_graph/) | 1.421 | 64% |
| plugin: tools (tools/) | 0.138 | 6% |
| plugin: panels and UI (ui/) | 0.107 | 5% |
| plugin: simulator (xr/simulator.gd) | 0.081 | 4% |
| plugin: controllers, rays, rig (xr/) | 0.077 | 3% |
| plugin: core (core/) | 0.063 | 3% |
| plugin: lab (telemetry/graph_lab.gd) | 0.048 | 2% |
| other GDScript | 0.013 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.949 | 1.0 |
| _process | ui/panels.gd:208 | 0.612 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.111 | 1.0 |
| _process | xr/simulator.gd:319 | 0.077 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.048 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.028 | 1.0 |
| _process | xr/session.gd:188 | 0.024 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.019 | 1.0 |
| _process | tools/undo.gd:24 | 0.018 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.012 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
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
| _process | logic_graph/blueprints.gd:802 | 0.949 |
| _process_frame | logic_graph/blueprints.gd:804 | 0.947 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.947 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.800 |
| _process | ui/panels.gd:208 | 0.612 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:3933 | 0.598 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4016 | 0.597 |
| _update_pointer | ui/panels.gd:222 | 0.590 |
| _update_pointer | ui/panels.gd:824 | 0.590 |
| _update_pointer | logic_graph/blueprints.gd:865 | 0.557 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.557 |
| takes_pointer | ui/panels.gd:888 | 0.537 |
| takes_pointer | logic_graph/blueprints.gd:3286 | 0.537 |
| _takes_pointer | logic_graph/blueprints.gd:3288 | 0.533 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.533 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.501 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4017 | 0.467 |
| intersect_ray | logic_graph/blueprints.gd:3318 | 0.419 |
| intersect_ray | logic_graph/blueprints.gd:2928 | 0.382 |
| face_user | logic_graph/blueprint_canvas.gd:2476 | 0.172 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.169 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.166 |
| face_user | logic_graph/blueprints.gd:849 | 0.160 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2483 | 0.157 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.157 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.124 |
| _process | tools/manipulator.gd:296 | 0.111 |
| _process_frame | tools/manipulator.gd:298 | 0.110 |
| _process_frame | tools/manipulator.gd:302 | 0.109 |
| _update_target_wires | logic_graph/blueprints.gd:889 | 0.103 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.103 |
| intersect_link_wire | logic_graph/blueprints.gd:6981 | 0.101 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.100 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.098 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.087 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4464 | 0.087 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4071 | 0.085 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4448 | 0.084 |
| _update_hover | tools/manipulator.gd:332 | 0.078 |
| _update_hover | tools/manipulator.gd:465 | 0.077 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.226 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.166 | 266.3 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.145 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.087 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4071 | 0.085 | 156.2 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.061 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4451 | 0.042 | 0.5 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4464 | 0.041 | 32.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4559 | 0.032 | 30.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5620 | 0.027 | 40.0 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.027 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.024 | 0.5 |
| cast_segment | tools/manipulator.gd:484 | 0.023 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.023 | 248.3 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.022 | 1.0 |
| find_at_point | tools/manipulator.gd:475 | 0.022 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.020 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:667 | 0.020 | 4.0 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.016 | 2.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.016 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.013 | 156.2 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5625 | 0.013 | 40.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6075 | 0.010 | 1.0 |
| button_input | core/feature_settings.gd:1124 | 0.008 | 12.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| button_hand | core/feature_settings.gd:1119 | 0.008 | 14.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| focus_paint | logic_graph/blueprint_canvas.gd:2974 | 0.007 | 32.0 |
| preset_binding | core/feature_settings.gd:1107 | 0.007 | 12.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |

### 06 closed

Frames 839, mean Main::iteration 6.06 ms; `process` 0.796 ms, of it its own C++ 0.230 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.230 | 29% |
| plugin: tools (tools/) | 0.139 | 18% |
| plugin: graph (logic_graph/) | 0.135 | 17% |
| plugin: simulator (xr/simulator.gd) | 0.077 | 10% |
| plugin: controllers, rays, rig (xr/) | 0.070 | 9% |
| plugin: core (core/) | 0.058 | 7% |
| plugin: lab (telemetry/graph_lab.gd) | 0.046 | 6% |
| plugin: panels and UI (ui/) | 0.035 | 4% |
| plugin: other (playmode) | 0.005 | 1% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.130 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.117 | 1.0 |
| _process | xr/simulator.gd:319 | 0.073 | 1.0 |
| _process | ui/panels.gd:208 | 0.052 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.046 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.027 | 1.0 |
| _process | xr/session.gd:188 | 0.023 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.022 | 1.0 |
| _process | tools/undo.gd:24 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.010 | 1.0 |
| _process | xr/rig.gd:54 | 0.010 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.130 |
| _process_frame | logic_graph/blueprints.gd:804 | 0.128 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.128 |
| _process | tools/manipulator.gd:296 | 0.117 |
| _process_frame | tools/manipulator.gd:298 | 0.116 |
| _process_frame | tools/manipulator.gd:302 | 0.115 |
| _update_hover | tools/manipulator.gd:332 | 0.076 |
| _update_hover | tools/manipulator.gd:465 | 0.075 |
| _process | xr/simulator.gd:319 | 0.073 |
| _process | ui/panels.gd:208 | 0.052 |
| is_action_pressed | xr/rig.gd:83 | 0.049 |
| _process | telemetry/graph_lab.gd:361 | 0.046 |
| _update_pointer | logic_graph/blueprints.gd:865 | 0.043 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.042 |
| _update_pointer | ui/panels.gd:222 | 0.036 |
| _update_pointer | ui/panels.gd:824 | 0.035 |
| _update_inputs | xr/simulator.gd:325 | 0.031 |
| _update_inputs | xr/simulator.gd:357 | 0.031 |
| binding_of | core/feature_settings.gd:1114 | 0.030 |
| get_action_hand | xr/rig.gd:78 | 0.028 |
| _process | tools/locomotion.gd:108 | 0.027 |
| get_binding | core/feature_settings.gd:1115 | 0.026 |
| _update_poses | xr/simulator.gd:324 | 0.025 |
| _update_poses | xr/simulator.gd:335 | 0.025 |
| get_binding | core/feature_settings.gd:1099 | 0.024 |
| cast_segment | tools/manipulator.gd:484 | 0.024 |
| _process | xr/session.gd:188 | 0.023 |
| _process | tools/selection_counter.gd:87 | 0.022 |
| find_at_point | tools/manipulator.gd:475 | 0.020 |
| _report | telemetry/graph_lab.gd:379 | 0.020 |
| _report | telemetry/graph_lab.gd:493 | 0.020 |
| _report_frames | telemetry/graph_lab.gd:499 | 0.020 |
| _report_frames | telemetry/graph_lab.gd:503 | 0.020 |
| get_action_hand | xr/rig.gd:87 | 0.018 |
| _refresh_views | telemetry/graph_lab.gd:510 | 0.017 |
| _refresh_views | telemetry/graph_lab.gd:545 | 0.017 |
| binding_of | xr/rig.gd:79 | 0.017 |
| _process | tools/undo.gd:24 | 0.017 |
| hover_actions | logic_graph/blueprints.gd:3025 | 0.016 |
| _update_outlines | tools/manipulator.gd:371 | 0.016 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| cast_segment | tools/manipulator.gd:484 | 0.024 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.020 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.017 | 1.0 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.017 | 2.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.012 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.009 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1124 | 0.009 | 12.0 |
| _update_pointer | ui/panels.gd:824 | 0.008 | 2.0 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.008 | 2.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1119 | 0.007 | 14.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| preset_binding | core/feature_settings.gd:1107 | 0.007 | 12.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.006 | 1.0 |
| set_wire_shown | logic_graph/blueprint_canvas.gd:2112 | 0.006 | 7.0 |
| get_values | core/feature_settings.gd:1041 | 0.006 | 2.0 |
| set_pose | xr/simulator.gd:353 | 0.006 | 2.0 |
| is_action_pressed | xr/rig.gd:83 | 0.005 | 5.0 |
| update_input | xr/hand.gd:92 | 0.005 | 2.0 |
| get_binding | core/feature_settings.gd:1099 | 0.005 | 12.0 |
| set_pose | xr/simulator.gd:354 | 0.005 | 2.0 |
| show_ray | xr/hand.gd:168 | 0.005 | 2.0 |
| _update_parts | tools/outline.gd:275 | 0.005 | 1.0 |
| find_at_point | tools/icons.gd:152 | 0.005 | 2.0 |
| _pick_clear | tools/selection_counter.gd:120 | 0.004 | 1.0 |
| _process | xr/session.gd:188 | 0.004 | 1.0 |
| cast_segment | tools/icons.gd:118 | 0.004 | 2.0 |
| _update_outlines | tools/manipulator.gd:995 | 0.004 | 1.0 |
| binding_of | core/feature_settings.gd:1114 | 0.004 | 12.0 |
| _process | telemetry/graph_lab.gd:361 | 0.004 | 1.0 |
| get | core/feature_settings.gd:1108 | 0.003 | 12.0 |
| _process | tools/clipboard.gd:96 | 0.003 | 1.0 |
| is_holding | logic_graph/blueprints.gd:2330 | 0.003 | 2.0 |
| is_free_for | xr/hand.gd:127 | 0.003 | 9.0 |
