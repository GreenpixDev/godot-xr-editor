logs/editor_sim_2026-11-10T19-30-23 (benchmarks/tracy_process.py)

| Step | `process` | Graph scripts (`blueprints.gd` _process) | Ray routing from the panels (`_takes_pointer`) | Panels without the routing | Manipulator | `process` own C++ | Simulator | Lab | Other scripts |
|---|---|---|---|---|---|---|---|---|---|
| 01 closed | 0.775 | 0.119 | 0.010 | 0.043 | 0.106 | 0.236 | 0.087 | 0.042 | 0.132 |
| 02 open | 1.652 | 0.644 | 0.308 | 0.080 | 0.103 | 0.246 | 0.087 | 0.043 | 0.141 |
| 03 open_big2 | 2.138 | 0.897 | 0.510 | 0.077 | 0.113 | 0.258 | 0.091 | 0.047 | 0.146 |
| 04 open | 1.658 | 0.633 | 0.305 | 0.077 | 0.104 | 0.255 | 0.090 | 0.046 | 0.147 |
| 05 open_big2 | 2.162 | 0.909 | 0.516 | 0.078 | 0.115 | 0.259 | 0.090 | 0.048 | 0.147 |
| 06 closed | 0.785 | 0.127 | 0.009 | 0.042 | 0.114 | 0.230 | 0.084 | 0.045 | 0.135 |

### 01 closed

Frames 839, mean Main::iteration 6.05 ms; `process` 0.775 ms, of it its own C++ 0.236 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.236 | 30% |
| plugin: graph (logic_graph/) | 0.124 | 16% |
| plugin: tools (tools/) | 0.123 | 16% |
| plugin: simulator (xr/simulator.gd) | 0.078 | 10% |
| plugin: controllers, rays, rig (xr/) | 0.071 | 9% |
| plugin: core (core/) | 0.059 | 8% |
| plugin: lab (telemetry/graph_lab.gd) | 0.042 | 5% |
| plugin: panels and UI (ui/) | 0.037 | 5% |
| plugin: other (playmode) | 0.005 | 1% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.119 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.106 | 1.0 |
| _process | xr/simulator.gd:319 | 0.074 | 1.0 |
| _process | ui/panels.gd:208 | 0.053 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.042 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.029 | 1.0 |
| _process | xr/session.gd:188 | 0.023 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
| _process | tools/undo.gd:24 | 0.016 | 1.0 |
| _process | xr/simulator.gd:474 | 0.014 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.010 | 1.0 |
| _process | tools/icons.gd:69 | 0.010 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.005 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.119 |
| _process_frame | logic_graph/blueprints.gd:804 | 0.118 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.118 |
| _process | tools/manipulator.gd:296 | 0.106 |
| _process_frame | tools/manipulator.gd:298 | 0.105 |
| _process_frame | tools/manipulator.gd:302 | 0.104 |
| _update_hover | tools/manipulator.gd:332 | 0.076 |
| _update_hover | tools/manipulator.gd:465 | 0.075 |
| _process | xr/simulator.gd:319 | 0.074 |
| _process | ui/panels.gd:208 | 0.053 |
| is_action_pressed | xr/rig.gd:83 | 0.050 |
| _update_pointer | logic_graph/blueprints.gd:865 | 0.043 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.042 |
| _process | telemetry/graph_lab.gd:361 | 0.042 |
| _update_pointer | ui/panels.gd:222 | 0.036 |
| _update_pointer | ui/panels.gd:824 | 0.036 |
| _update_inputs | xr/simulator.gd:325 | 0.031 |
| _update_inputs | xr/simulator.gd:357 | 0.031 |
| binding_of | core/feature_settings.gd:1114 | 0.031 |
| _process | tools/locomotion.gd:108 | 0.029 |
| get_action_hand | xr/rig.gd:78 | 0.029 |
| get_binding | core/feature_settings.gd:1115 | 0.026 |
| _update_poses | xr/simulator.gd:324 | 0.026 |
| _update_poses | xr/simulator.gd:335 | 0.025 |
| get_binding | core/feature_settings.gd:1099 | 0.025 |
| cast_segment | tools/manipulator.gd:484 | 0.023 |
| _process | xr/session.gd:188 | 0.023 |
| find_at_point | tools/manipulator.gd:475 | 0.020 |
| _report | telemetry/graph_lab.gd:379 | 0.019 |
| _report | telemetry/graph_lab.gd:493 | 0.019 |
| _report_frames | telemetry/graph_lab.gd:499 | 0.019 |
| _report_frames | telemetry/graph_lab.gd:503 | 0.019 |
| get_action_hand | xr/rig.gd:87 | 0.019 |
| _process | tools/selection_counter.gd:87 | 0.018 |
| binding_of | xr/rig.gd:79 | 0.017 |
| _refresh_views | telemetry/graph_lab.gd:510 | 0.017 |
| _refresh_views | telemetry/graph_lab.gd:545 | 0.017 |
| _process | tools/undo.gd:24 | 0.016 |
| hover_actions | logic_graph/blueprints.gd:3025 | 0.016 |
| hover_actions | logic_graph/blueprint_canvas.gd:3193 | 0.016 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| cast_segment | tools/manipulator.gd:484 | 0.023 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.020 | 2.0 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.017 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.015 | 1.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _update_pointer | ui/panels.gd:824 | 0.009 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.009 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.008 | 2.0 |
| button_input | core/feature_settings.gd:1124 | 0.008 | 12.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1119 | 0.007 | 14.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| preset_binding | core/feature_settings.gd:1107 | 0.007 | 12.0 |
| _process_frame | tools/manipulator.gd:302 | 0.006 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.006 | 1.0 |
| update_input | xr/hand.gd:92 | 0.006 | 2.0 |
| get_values | core/feature_settings.gd:1041 | 0.006 | 2.0 |
| set_pose | xr/simulator.gd:353 | 0.006 | 2.0 |
| show_ray | xr/hand.gd:168 | 0.005 | 2.0 |
| get_binding | core/feature_settings.gd:1099 | 0.005 | 12.0 |
| set_pose | xr/simulator.gd:354 | 0.005 | 2.0 |
| is_action_pressed | xr/rig.gd:83 | 0.005 | 5.0 |
| find_at_point | tools/icons.gd:152 | 0.005 | 2.0 |
| cast_segment | tools/icons.gd:118 | 0.004 | 2.0 |
| _process | xr/session.gd:188 | 0.004 | 1.0 |
| binding_of | core/feature_settings.gd:1114 | 0.004 | 12.0 |
| get | core/feature_settings.gd:1108 | 0.003 | 12.0 |
| hover_actions | logic_graph/blueprint_canvas.gd:3193 | 0.003 | 2.0 |
| _process | telemetry/graph_lab.gd:361 | 0.003 | 1.0 |
| is_holding | logic_graph/blueprints.gd:2330 | 0.003 | 2.0 |
| _update_desktop_ui | xr/session.gd:575 | 0.003 | 1.0 |
| _process | ui/palette.gd:156 | 0.003 | 1.0 |
| get_layout | core/feature_settings.gd:1083 | 0.003 | 12.0 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.003 | 1.0 |
| poll_trigger | ui/virtual_keyboard.gd:233 | 0.003 | 2.0 |
| _process | tools/clipboard.gd:96 | 0.003 | 1.0 |

### 02 open

Frames 853, mean Main::iteration 6.05 ms; `process` 1.652 ms, of it its own C++ 0.246 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.246 | 15% |
| plugin: graph (logic_graph/) | 0.894 | 54% |
| plugin: tools (tools/) | 0.129 | 8% |
| plugin: panels and UI (ui/) | 0.106 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.079 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.076 | 5% |
| plugin: core (core/) | 0.061 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.043 | 3% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.644 | 1.0 |
| _process | ui/panels.gd:208 | 0.388 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.103 | 1.0 |
| _process | xr/simulator.gd:319 | 0.075 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.043 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.029 | 1.0 |
| _process | xr/session.gd:188 | 0.024 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.019 | 1.0 |
| _process | tools/undo.gd:24 | 0.018 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
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
| _process | logic_graph/blueprints.gd:802 | 0.644 |
| _process_frame | logic_graph/blueprints.gd:804 | 0.642 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.642 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.412 |
| _process | ui/panels.gd:208 | 0.388 |
| _update_pointer | ui/panels.gd:222 | 0.366 |
| _update_pointer | ui/panels.gd:824 | 0.365 |
| _update_pointer | logic_graph/blueprints.gd:865 | 0.337 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.337 |
| takes_pointer | ui/panels.gd:888 | 0.312 |
| takes_pointer | logic_graph/blueprints.gd:3286 | 0.311 |
| _takes_pointer | logic_graph/blueprints.gd:3288 | 0.308 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.308 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:3933 | 0.306 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4016 | 0.305 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.248 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4017 | 0.226 |
| intersect_ray | logic_graph/blueprints.gd:3318 | 0.219 |
| intersect_ray | logic_graph/blueprints.gd:2928 | 0.193 |
| face_user | logic_graph/blueprint_canvas.gd:2476 | 0.106 |
| _process | tools/manipulator.gd:296 | 0.103 |
| _process_frame | tools/manipulator.gd:298 | 0.101 |
| _process_frame | tools/manipulator.gd:302 | 0.101 |
| _update_target_wires | logic_graph/blueprints.gd:889 | 0.096 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.095 |
| face_user | logic_graph/blueprints.gd:849 | 0.095 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2483 | 0.092 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.092 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.078 |
| _process | xr/simulator.gd:319 | 0.075 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.074 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.073 |
| _update_hover | tools/manipulator.gd:332 | 0.070 |
| _update_hover | tools/manipulator.gd:465 | 0.070 |
| intersect_link_wire | logic_graph/blueprints.gd:6981 | 0.057 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.056 |
| is_action_pressed | xr/rig.gd:83 | 0.050 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.049 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.048 |
| _link_wire_hit | logic_graph/blueprints.gd:3314 | 0.047 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.122 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.073 | 140.2 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.067 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.049 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4071 | 0.042 | 78.1 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.034 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4451 | 0.029 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.025 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4464 | 0.022 | 18.0 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.020 | 1.0 |
| find_at_point | tools/manipulator.gd:475 | 0.020 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:667 | 0.020 | 4.0 |
| cast_segment | tools/manipulator.gd:484 | 0.018 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.018 | 1.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5620 | 0.017 | 24.0 |
| _cast | ui/panel_surface.gd:626 | 0.017 | 24.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4559 | 0.016 | 15.5 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.016 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.015 | 0.5 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.014 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.012 | 128.2 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.009 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.009 | 18.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5625 | 0.009 | 24.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6075 | 0.009 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.008 | 1.0 |
| button_input | core/feature_settings.gd:1124 | 0.008 | 12.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| button_hand | core/feature_settings.gd:1119 | 0.007 | 14.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| preset_binding | core/feature_settings.gd:1107 | 0.007 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.007 | 78.1 |

### 03 open_big2

Frames 856, mean Main::iteration 6.05 ms; `process` 2.138 ms, of it its own C++ 0.258 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.258 | 12% |
| plugin: graph (logic_graph/) | 1.348 | 63% |
| plugin: tools (tools/) | 0.141 | 7% |
| plugin: panels and UI (ui/) | 0.104 | 5% |
| plugin: simulator (xr/simulator.gd) | 0.082 | 4% |
| plugin: controllers, rays, rig (xr/) | 0.077 | 4% |
| plugin: core (core/) | 0.062 | 3% |
| plugin: lab (telemetry/graph_lab.gd) | 0.047 | 2% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.897 | 1.0 |
| _process | ui/panels.gd:208 | 0.587 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.113 | 1.0 |
| _process | xr/simulator.gd:319 | 0.078 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.047 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.029 | 1.0 |
| _process | xr/session.gd:188 | 0.024 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.020 | 1.0 |
| _process | tools/undo.gd:24 | 0.018 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.897 |
| _process_frame | logic_graph/blueprints.gd:804 | 0.895 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.895 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.757 |
| _process | ui/panels.gd:208 | 0.587 |
| _update_pointer | ui/panels.gd:222 | 0.564 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:3933 | 0.564 |
| _update_pointer | ui/panels.gd:824 | 0.564 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4016 | 0.563 |
| _update_pointer | logic_graph/blueprints.gd:865 | 0.521 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.520 |
| takes_pointer | ui/panels.gd:888 | 0.513 |
| takes_pointer | logic_graph/blueprints.gd:3286 | 0.513 |
| _takes_pointer | logic_graph/blueprints.gd:3288 | 0.510 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.509 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.473 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4017 | 0.440 |
| intersect_ray | logic_graph/blueprints.gd:3318 | 0.400 |
| intersect_ray | logic_graph/blueprints.gd:2928 | 0.357 |
| face_user | logic_graph/blueprint_canvas.gd:2476 | 0.164 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.159 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.155 |
| face_user | logic_graph/blueprints.gd:849 | 0.153 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2483 | 0.150 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.150 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.116 |
| _process | tools/manipulator.gd:296 | 0.113 |
| _process_frame | tools/manipulator.gd:298 | 0.111 |
| _process_frame | tools/manipulator.gd:302 | 0.110 |
| _update_target_wires | logic_graph/blueprints.gd:889 | 0.100 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.099 |
| intersect_link_wire | logic_graph/blueprints.gd:6981 | 0.094 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.093 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.093 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4464 | 0.082 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.082 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4071 | 0.080 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4448 | 0.079 |
| _update_hover | tools/manipulator.gd:332 | 0.078 |
| _update_hover | tools/manipulator.gd:465 | 0.078 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.215 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.155 | 266.3 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.138 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.082 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4071 | 0.080 | 156.2 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.056 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4451 | 0.040 | 0.5 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4464 | 0.039 | 32.6 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4559 | 0.030 | 30.1 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5620 | 0.026 | 40.0 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.025 | 2.0 |
| cast_segment | tools/manipulator.gd:484 | 0.024 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.023 | 0.5 |
| find_at_point | tools/manipulator.gd:475 | 0.022 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.021 | 248.3 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.021 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:667 | 0.019 | 4.0 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.019 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.016 | 2.0 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.015 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5625 | 0.013 | 40.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.012 | 156.2 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6075 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1124 | 0.009 | 12.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.007 | 7.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1119 | 0.007 | 14.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| preset_binding | core/feature_settings.gd:1107 | 0.007 | 12.0 |

### 04 open

Frames 855, mean Main::iteration 6.05 ms; `process` 1.658 ms, of it its own C++ 0.255 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.255 | 15% |
| plugin: graph (logic_graph/) | 0.884 | 53% |
| plugin: tools (tools/) | 0.133 | 8% |
| plugin: panels and UI (ui/) | 0.101 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.082 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.077 | 5% |
| plugin: core (core/) | 0.062 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.046 | 3% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.633 | 1.0 |
| _process | ui/panels.gd:208 | 0.382 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.104 | 1.0 |
| _process | xr/simulator.gd:319 | 0.077 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.046 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.030 | 1.0 |
| _process | xr/session.gd:188 | 0.024 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.020 | 1.0 |
| _process | tools/undo.gd:24 | 0.018 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.633 |
| _process_frame | logic_graph/blueprints.gd:804 | 0.632 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.632 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.403 |
| _process | ui/panels.gd:208 | 0.382 |
| _update_pointer | ui/panels.gd:222 | 0.360 |
| _update_pointer | ui/panels.gd:824 | 0.359 |
| _update_pointer | logic_graph/blueprints.gd:865 | 0.327 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.326 |
| takes_pointer | ui/panels.gd:888 | 0.309 |
| takes_pointer | logic_graph/blueprints.gd:3286 | 0.308 |
| _takes_pointer | logic_graph/blueprints.gd:3288 | 0.305 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.304 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:3933 | 0.300 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4016 | 0.299 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.243 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4017 | 0.221 |
| intersect_ray | logic_graph/blueprints.gd:3318 | 0.217 |
| intersect_ray | logic_graph/blueprints.gd:2928 | 0.187 |
| face_user | logic_graph/blueprint_canvas.gd:2476 | 0.105 |
| _process | tools/manipulator.gd:296 | 0.104 |
| _process_frame | tools/manipulator.gd:298 | 0.102 |
| _process_frame | tools/manipulator.gd:302 | 0.102 |
| _update_target_wires | logic_graph/blueprints.gd:889 | 0.096 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.095 |
| face_user | logic_graph/blueprints.gd:849 | 0.094 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2483 | 0.091 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.091 |
| _process | xr/simulator.gd:319 | 0.077 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.077 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.072 |
| _update_hover | tools/manipulator.gd:332 | 0.071 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.071 |
| _update_hover | tools/manipulator.gd:465 | 0.070 |
| intersect_link_wire | logic_graph/blueprints.gd:6981 | 0.056 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.055 |
| is_action_pressed | xr/rig.gd:83 | 0.050 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.048 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.047 |
| _link_wire_hit | logic_graph/blueprints.gd:3314 | 0.047 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.120 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.071 | 140.2 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.065 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.048 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4071 | 0.041 | 78.1 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.033 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4451 | 0.029 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.024 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4464 | 0.022 | 18.0 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.020 | 1.0 |
| find_at_point | tools/manipulator.gd:475 | 0.020 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:667 | 0.019 | 4.0 |
| cast_segment | tools/manipulator.gd:484 | 0.019 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.018 | 1.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5620 | 0.017 | 24.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4559 | 0.016 | 15.5 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.016 | 2.0 |
| _cast | ui/panel_surface.gd:626 | 0.015 | 24.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.014 | 0.5 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.014 | 4.0 |
| _update_poses | xr/simulator.gd:335 | 0.014 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.011 | 128.1 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6075 | 0.009 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5625 | 0.009 | 24.0 |
| button_input | core/feature_settings.gd:1124 | 0.009 | 12.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.007 | 7.0 |
| button_hand | core/feature_settings.gd:1119 | 0.007 | 14.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| preset_binding | core/feature_settings.gd:1107 | 0.007 | 12.0 |
| get_values | core/feature_settings.gd:1041 | 0.006 | 2.0 |

### 05 open_big2

Frames 842, mean Main::iteration 6.05 ms; `process` 2.162 ms, of it its own C++ 0.259 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.259 | 12% |
| plugin: graph (logic_graph/) | 1.366 | 63% |
| plugin: tools (tools/) | 0.143 | 7% |
| plugin: panels and UI (ui/) | 0.105 | 5% |
| plugin: simulator (xr/simulator.gd) | 0.082 | 4% |
| plugin: controllers, rays, rig (xr/) | 0.078 | 4% |
| plugin: core (core/) | 0.063 | 3% |
| plugin: lab (telemetry/graph_lab.gd) | 0.048 | 2% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.909 | 1.0 |
| _process | ui/panels.gd:208 | 0.594 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.115 | 1.0 |
| _process | xr/simulator.gd:319 | 0.077 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.048 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.029 | 1.0 |
| _process | xr/session.gd:188 | 0.024 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.019 | 1.0 |
| _process | tools/undo.gd:24 | 0.018 | 1.0 |
| _process | xr/simulator.gd:474 | 0.014 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.909 |
| _process_frame | logic_graph/blueprints.gd:804 | 0.908 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.907 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.767 |
| _process | ui/panels.gd:208 | 0.594 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:3933 | 0.575 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4016 | 0.574 |
| _update_pointer | ui/panels.gd:222 | 0.572 |
| _update_pointer | ui/panels.gd:824 | 0.571 |
| _update_pointer | logic_graph/blueprints.gd:865 | 0.530 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.529 |
| takes_pointer | ui/panels.gd:888 | 0.520 |
| takes_pointer | logic_graph/blueprints.gd:3286 | 0.519 |
| _takes_pointer | logic_graph/blueprints.gd:3288 | 0.516 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.515 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.482 |
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4017 | 0.448 |
| intersect_ray | logic_graph/blueprints.gd:3318 | 0.404 |
| intersect_ray | logic_graph/blueprints.gd:2928 | 0.363 |
| face_user | logic_graph/blueprint_canvas.gd:2476 | 0.166 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.162 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.158 |
| face_user | logic_graph/blueprints.gd:849 | 0.155 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2483 | 0.152 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.152 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.118 |
| _process | tools/manipulator.gd:296 | 0.115 |
| _process_frame | tools/manipulator.gd:298 | 0.113 |
| _process_frame | tools/manipulator.gd:302 | 0.113 |
| _update_target_wires | logic_graph/blueprints.gd:889 | 0.100 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.099 |
| intersect_link_wire | logic_graph/blueprints.gd:6981 | 0.096 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.095 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.093 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.084 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4464 | 0.082 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4071 | 0.080 |
| _update_hover | tools/manipulator.gd:332 | 0.080 |
| _update_hover | tools/manipulator.gd:465 | 0.079 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4448 | 0.079 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _intersect_tubes | logic_graph/blueprint_canvas.gd:4030 | 0.220 | 12.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4089 | 0.158 | 266.3 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3623 | 0.137 | 4.0 |
| _intersect_knots | logic_graph/blueprint_canvas.gd:4052 | 0.084 | 12.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4071 | 0.080 | 156.2 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5593 | 0.058 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4451 | 0.042 | 0.5 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4464 | 0.039 | 32.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4559 | 0.030 | 30.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5620 | 0.026 | 40.0 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.026 | 2.0 |
| cast_segment | tools/manipulator.gd:484 | 0.025 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4437 | 0.024 | 0.5 |
| _box_distance | logic_graph/blueprint_canvas.gd:4035 | 0.022 | 248.3 |
| find_at_point | tools/manipulator.gd:475 | 0.021 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.021 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:667 | 0.020 | 4.0 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.019 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.016 | 2.0 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6979 | 0.015 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5625 | 0.013 | 40.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| _ray_segment | logic_graph/blueprint_canvas.gd:4039 | 0.013 | 156.2 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.011 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6075 | 0.010 | 1.0 |
| button_input | core/feature_settings.gd:1124 | 0.009 | 12.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| _process | xr/simulator.gd:474 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1119 | 0.007 | 14.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| preset_binding | core/feature_settings.gd:1107 | 0.007 | 12.0 |

### 06 closed

Frames 842, mean Main::iteration 6.05 ms; `process` 0.785 ms, of it its own C++ 0.230 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.230 | 29% |
| plugin: tools (tools/) | 0.136 | 17% |
| plugin: graph (logic_graph/) | 0.131 | 17% |
| plugin: simulator (xr/simulator.gd) | 0.076 | 10% |
| plugin: controllers, rays, rig (xr/) | 0.070 | 9% |
| plugin: core (core/) | 0.058 | 7% |
| plugin: lab (telemetry/graph_lab.gd) | 0.045 | 6% |
| plugin: panels and UI (ui/) | 0.035 | 4% |
| plugin: other (playmode) | 0.005 | 1% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.127 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.114 | 1.0 |
| _process | xr/simulator.gd:319 | 0.071 | 1.0 |
| _process | ui/panels.gd:208 | 0.051 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.045 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.028 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.022 | 1.0 |
| _process | xr/session.gd:188 | 0.022 | 1.0 |
| _process | tools/undo.gd:24 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.010 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:802 | 0.127 |
| _process_frame | logic_graph/blueprints.gd:804 | 0.125 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.125 |
| _process | tools/manipulator.gd:296 | 0.114 |
| _process_frame | tools/manipulator.gd:298 | 0.112 |
| _process_frame | tools/manipulator.gd:302 | 0.112 |
| _update_hover | tools/manipulator.gd:332 | 0.072 |
| _update_hover | tools/manipulator.gd:465 | 0.072 |
| _process | xr/simulator.gd:319 | 0.071 |
| _process | ui/panels.gd:208 | 0.051 |
| is_action_pressed | xr/rig.gd:83 | 0.049 |
| _process | telemetry/graph_lab.gd:361 | 0.045 |
| _update_pointer | logic_graph/blueprints.gd:865 | 0.041 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.040 |
| _update_pointer | ui/panels.gd:222 | 0.034 |
| _update_pointer | ui/panels.gd:824 | 0.033 |
| _update_inputs | xr/simulator.gd:325 | 0.030 |
| _update_inputs | xr/simulator.gd:357 | 0.030 |
| binding_of | core/feature_settings.gd:1114 | 0.030 |
| _process | tools/locomotion.gd:108 | 0.028 |
| get_action_hand | xr/rig.gd:78 | 0.028 |
| get_binding | core/feature_settings.gd:1115 | 0.026 |
| _update_poses | xr/simulator.gd:324 | 0.025 |
| _update_poses | xr/simulator.gd:335 | 0.024 |
| get_binding | core/feature_settings.gd:1099 | 0.024 |
| cast_segment | tools/manipulator.gd:484 | 0.023 |
| _process | tools/selection_counter.gd:87 | 0.022 |
| _process | xr/session.gd:188 | 0.022 |
| _report | telemetry/graph_lab.gd:379 | 0.019 |
| _report | telemetry/graph_lab.gd:493 | 0.019 |
| _report_frames | telemetry/graph_lab.gd:499 | 0.018 |
| _report_frames | telemetry/graph_lab.gd:503 | 0.018 |
| get_action_hand | xr/rig.gd:87 | 0.018 |
| find_at_point | tools/manipulator.gd:475 | 0.018 |
| binding_of | xr/rig.gd:79 | 0.017 |
| _process | tools/undo.gd:24 | 0.017 |
| _refresh_views | telemetry/graph_lab.gd:510 | 0.016 |
| _refresh_views | telemetry/graph_lab.gd:545 | 0.016 |
| _update_outlines | tools/manipulator.gd:371 | 0.016 |
| _update_outlines | tools/manipulator.gd:995 | 0.015 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| cast_segment | tools/manipulator.gd:484 | 0.023 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.018 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:822 | 0.017 | 1.0 |
| _update_pointer | logic_graph/blueprints.gd:2795 | 0.016 | 2.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.012 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.009 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1124 | 0.008 | 12.0 |
| _update_pointer | ui/panels.gd:824 | 0.008 | 2.0 |
| _takes_pointer | logic_graph/blueprints.gd:3293 | 0.008 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4173 | 0.008 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| preset_binding | core/feature_settings.gd:1107 | 0.007 | 12.0 |
| button_hand | core/feature_settings.gd:1119 | 0.007 | 14.0 |
| _process_frame | tools/manipulator.gd:302 | 0.006 | 1.0 |
| set_wire_shown | logic_graph/blueprint_canvas.gd:2112 | 0.006 | 7.0 |
| get_values | core/feature_settings.gd:1041 | 0.006 | 2.0 |
| update_input | xr/hand.gd:92 | 0.006 | 2.0 |
| set_pose | xr/simulator.gd:353 | 0.005 | 2.0 |
| is_action_pressed | xr/rig.gd:83 | 0.005 | 5.0 |
| show_ray | xr/hand.gd:168 | 0.005 | 2.0 |
| get_binding | core/feature_settings.gd:1099 | 0.005 | 12.0 |
| _update_parts | tools/outline.gd:275 | 0.005 | 1.0 |
| set_pose | xr/simulator.gd:354 | 0.005 | 2.0 |
| find_at_point | tools/icons.gd:152 | 0.005 | 2.0 |
| _pick_clear | tools/selection_counter.gd:120 | 0.004 | 1.0 |
| _process | xr/session.gd:188 | 0.004 | 1.0 |
| cast_segment | tools/icons.gd:118 | 0.004 | 2.0 |
| _update_outlines | tools/manipulator.gd:995 | 0.004 | 1.0 |
| binding_of | core/feature_settings.gd:1114 | 0.004 | 12.0 |
| _process | tools/clipboard.gd:96 | 0.003 | 1.0 |
| get | core/feature_settings.gd:1108 | 0.003 | 12.0 |
| _process | telemetry/graph_lab.gd:361 | 0.003 | 1.0 |
| hover_actions | logic_graph/blueprint_canvas.gd:3193 | 0.003 | 2.0 |
| is_holding | logic_graph/blueprints.gd:2330 | 0.003 | 2.0 |
