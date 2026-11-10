
### 01 closed

Frames 840, mean Main::iteration 6.05 ms; `process` 0.750 ms, of it its own C++ 0.234 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.234 | 31% |
| plugin: graph (logic_graph/) | 0.121 | 16% |
| plugin: tools (tools/) | 0.119 | 16% |
| plugin: simulator (xr/simulator.gd) | 0.075 | 10% |
| plugin: controllers, rays, rig (xr/) | 0.066 | 9% |
| plugin: core (core/) | 0.054 | 7% |
| plugin: lab (telemetry/graph_lab.gd) | 0.041 | 5% |
| plugin: panels and UI (ui/) | 0.035 | 5% |
| plugin: other (playmode) | 0.005 | 1% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.116 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.101 | 1.0 |
| _process | xr/simulator.gd:319 | 0.070 | 1.0 |
| _process | ui/panels.gd:208 | 0.050 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.041 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.026 | 1.0 |
| _process | xr/session.gd:188 | 0.022 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.017 | 1.0 |
| _process | tools/undo.gd:24 | 0.014 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | tools/icons.gd:69 | 0.010 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.010 | 1.0 |
| _process | xr/rig.gd:54 | 0.010 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.005 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.116 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.115 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.115 |
| _process | tools/manipulator.gd:296 | 0.101 |
| _process_frame | tools/manipulator.gd:298 | 0.099 |
| _process_frame | tools/manipulator.gd:302 | 0.099 |
| _update_hover | tools/manipulator.gd:332 | 0.072 |
| _update_hover | tools/manipulator.gd:465 | 0.072 |
| _process | xr/simulator.gd:319 | 0.070 |
| _process | ui/panels.gd:208 | 0.050 |
| is_action_pressed | xr/rig.gd:83 | 0.044 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.041 |
| _process | telemetry/graph_lab.gd:361 | 0.041 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.040 |
| _update_pointer | ui/panels.gd:222 | 0.035 |
| _update_pointer | ui/panels.gd:824 | 0.034 |
| _update_inputs | xr/simulator.gd:325 | 0.029 |
| _update_inputs | xr/simulator.gd:357 | 0.029 |
| binding_of | core/feature_settings.gd:1136 | 0.027 |
| _process | tools/locomotion.gd:108 | 0.026 |
| get_action_hand | xr/rig.gd:78 | 0.026 |
| _update_poses | xr/simulator.gd:324 | 0.024 |
| _update_poses | xr/simulator.gd:335 | 0.024 |
| get_binding | core/feature_settings.gd:1137 | 0.024 |
| cast_segment | tools/manipulator.gd:484 | 0.023 |
| _process | xr/session.gd:188 | 0.022 |
| get_binding | core/feature_settings.gd:1121 | 0.022 |
| find_at_point | tools/manipulator.gd:475 | 0.019 |
| _report | telemetry/graph_lab.gd:379 | 0.018 |
| _report | telemetry/graph_lab.gd:493 | 0.018 |
| _report_frames | telemetry/graph_lab.gd:499 | 0.018 |
| _report_frames | telemetry/graph_lab.gd:503 | 0.018 |
| _process | tools/selection_counter.gd:87 | 0.017 |
| get_action_hand | xr/rig.gd:87 | 0.017 |
| hover_actions | logic_graph/blueprints.gd:3027 | 0.016 |
| binding_of | xr/rig.gd:79 | 0.016 |
| _refresh_views | telemetry/graph_lab.gd:510 | 0.016 |
| _refresh_views | telemetry/graph_lab.gd:545 | 0.016 |
| hover_actions | logic_graph/blueprint_canvas.gd:3299 | 0.015 |
| _process | tools/undo.gd:24 | 0.014 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| cast_segment | tools/manipulator.gd:484 | 0.023 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.019 | 2.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.016 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.015 | 1.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.012 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.009 | 1.0 |
| _update_pointer | ui/panels.gd:824 | 0.009 | 2.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.008 | 2.0 |
| button_input | core/feature_settings.gd:1146 | 0.007 | 12.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.006 | 1.0 |
| _process | xr/simulator.gd:474 | 0.006 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.006 | 14.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.006 | 12.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.006 | 1.0 |
| get_values | core/feature_settings.gd:1063 | 0.006 | 2.0 |
| set_pose | xr/simulator.gd:353 | 0.006 | 2.0 |
| update_input | xr/hand.gd:92 | 0.005 | 2.0 |
| show_ray | xr/hand.gd:168 | 0.005 | 2.0 |
| get_binding | core/feature_settings.gd:1121 | 0.005 | 12.0 |
| set_pose | xr/simulator.gd:354 | 0.005 | 2.0 |
| is_action_pressed | xr/rig.gd:83 | 0.005 | 5.0 |
| find_at_point | tools/icons.gd:152 | 0.004 | 2.0 |
| _process | xr/session.gd:188 | 0.004 | 1.0 |
| cast_segment | tools/icons.gd:118 | 0.004 | 2.0 |
| is_holding | logic_graph/blueprints.gd:2332 | 0.004 | 2.0 |
| binding_of | core/feature_settings.gd:1136 | 0.004 | 12.0 |
| _update_desktop_ui | xr/session.gd:575 | 0.003 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.003 | 1.0 |
| hover_actions | logic_graph/blueprint_canvas.gd:3299 | 0.003 | 2.0 |
| get | core/feature_settings.gd:1130 | 0.003 | 12.0 |
| _process | ui/palette.gd:156 | 0.003 | 1.0 |
| poll_trigger | ui/virtual_keyboard.gd:233 | 0.003 | 2.0 |
| _process | tools/clipboard.gd:96 | 0.003 | 1.0 |
| update | xr/desktop_ui.gd:47 | 0.003 | 1.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.003 | 1.0 |

### 02 open

Frames 840, mean Main::iteration 6.05 ms; `process` 1.357 ms, of it its own C++ 0.235 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.235 | 17% |
| plugin: graph (logic_graph/) | 0.616 | 45% |
| plugin: tools (tools/) | 0.123 | 9% |
| plugin: panels and UI (ui/) | 0.102 | 8% |
| plugin: simulator (xr/simulator.gd) | 0.076 | 6% |
| plugin: core (core/) | 0.073 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.071 | 5% |
| plugin: lab (telemetry/graph_lab.gd) | 0.044 | 3% |
| other GDScript | 0.011 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.458 | 1.0 |
| _process | ui/panels.gd:208 | 0.304 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.097 | 1.0 |
| _process | xr/simulator.gd:319 | 0.072 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.044 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.027 | 1.0 |
| _process | xr/session.gd:188 | 0.022 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
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
| _process | logic_graph/blueprints.gd:804 | 0.458 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.457 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.457 |
| _process | ui/panels.gd:208 | 0.304 |
| _update_pointer | ui/panels.gd:222 | 0.282 |
| _update_pointer | ui/panels.gd:824 | 0.282 |
| takes_pointer | ui/panels.gd:888 | 0.230 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.229 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.227 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.226 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.161 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.161 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.144 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.131 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3748 | 0.116 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.115 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.100 |
| _process | tools/manipulator.gd:296 | 0.097 |
| _process_frame | tools/manipulator.gd:298 | 0.096 |
| _process_frame | tools/manipulator.gd:302 | 0.095 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.093 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.093 |
| face_user | logic_graph/blueprints.gd:851 | 0.090 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.087 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.087 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.080 |
| _process | xr/simulator.gd:319 | 0.072 |
| _update_hover | tools/manipulator.gd:332 | 0.066 |
| _update_hover | tools/manipulator.gd:465 | 0.065 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.059 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.058 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.055 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.054 |
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.052 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.050 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.049 |
| is_action_pressed | xr/rig.gd:83 | 0.047 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.047 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.045 |
| _process | telemetry/graph_lab.gd:361 | 0.044 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.052 | 2.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.038 | 2.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.036 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.025 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.024 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.022 | 18.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.019 | 1.0 |
| find_at_point | tools/manipulator.gd:475 | 0.018 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.018 | 1.0 |
| cast_segment | tools/manipulator.gd:484 | 0.017 | 2.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.016 | 24.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.016 | 15.5 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.016 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.015 | 0.5 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.015 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.014 | 4.0 |
| get_values | core/feature_settings.gd:1063 | 0.014 | 6.0 |
| _update_poses | xr/simulator.gd:335 | 0.012 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.011 | 2.0 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.009 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.009 | 18.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.009 | 24.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.008 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _pin_hand | ui/panels.gd:699 | 0.007 | 7.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.006 | 6.0 |
| append | core/feature_settings.gd:1068 | 0.006 | 27.0 |
| update_input | xr/hand.gd:92 | 0.006 | 2.0 |

### 03 open_big2

Frames 838, mean Main::iteration 6.06 ms; `process` 1.594 ms, of it its own C++ 0.248 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.248 | 16% |
| plugin: graph (logic_graph/) | 0.822 | 52% |
| plugin: tools (tools/) | 0.132 | 8% |
| plugin: panels and UI (ui/) | 0.101 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.079 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.074 | 5% |
| plugin: core (core/) | 0.074 | 5% |
| plugin: lab (telemetry/graph_lab.gd) | 0.046 | 3% |
| other GDScript | 0.011 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.542 | 1.0 |
| _process | ui/panels.gd:208 | 0.427 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.105 | 1.0 |
| _process | xr/simulator.gd:319 | 0.074 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.046 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.028 | 1.0 |
| _process | xr/session.gd:188 | 0.024 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
| _process | tools/undo.gd:24 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.012 | 1.0 |
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
| _process | logic_graph/blueprints.gd:804 | 0.542 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.540 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.540 |
| _process | ui/panels.gd:208 | 0.427 |
| _update_pointer | ui/panels.gd:222 | 0.405 |
| _update_pointer | ui/panels.gd:824 | 0.404 |
| takes_pointer | ui/panels.gd:888 | 0.353 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.353 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.350 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.349 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.242 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.229 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3748 | 0.213 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.212 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.180 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.179 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.160 |
| face_user | logic_graph/blueprints.gd:851 | 0.150 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.147 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.146 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.122 |
| _process | tools/manipulator.gd:296 | 0.105 |
| _process_frame | tools/manipulator.gd:298 | 0.103 |
| _process_frame | tools/manipulator.gd:302 | 0.103 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.100 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.100 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.099 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.099 |
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.097 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.095 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.095 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.083 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4711 | 0.080 |
| _process | xr/simulator.gd:319 | 0.074 |
| _update_hover | tools/manipulator.gd:332 | 0.072 |
| _update_hover | tools/manipulator.gd:465 | 0.072 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.070 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.068 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.068 |
| _link_wire_hit | logic_graph/blueprints.gd:7017 | 0.052 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.097 | 2.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.082 | 2.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.063 | 4.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.039 | 32.5 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.035 | 0.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.031 | 30.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.026 | 40.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.024 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.024 | 0.5 |
| cast_segment | tools/manipulator.gd:484 | 0.022 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.019 | 1.0 |
| find_at_point | tools/manipulator.gd:475 | 0.019 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.018 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.016 | 2.0 |
| _cast | ui/panel_surface.gd:626 | 0.015 | 24.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.015 | 4.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.015 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| get_values | core/feature_settings.gd:1063 | 0.014 | 6.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.012 | 40.0 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.011 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.010 | 9.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.007 | 7.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| focus_paint | logic_graph/blueprint_canvas.gd:3077 | 0.007 | 32.0 |
| append | core/feature_settings.gd:1068 | 0.006 | 27.0 |

### 04 open

Frames 841, mean Main::iteration 6.05 ms; `process` 1.364 ms, of it its own C++ 0.238 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.238 | 17% |
| plugin: graph (logic_graph/) | 0.622 | 46% |
| plugin: tools (tools/) | 0.124 | 9% |
| plugin: panels and UI (ui/) | 0.098 | 7% |
| plugin: simulator (xr/simulator.gd) | 0.077 | 6% |
| plugin: core (core/) | 0.073 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.072 | 5% |
| plugin: lab (telemetry/graph_lab.gd) | 0.044 | 3% |
| other GDScript | 0.011 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.457 | 1.0 |
| _process | ui/panels.gd:208 | 0.307 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.097 | 1.0 |
| _process | xr/simulator.gd:319 | 0.073 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.044 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.028 | 1.0 |
| _process | xr/session.gd:188 | 0.023 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
| _process | tools/undo.gd:24 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.012 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | xr/rig.gd:54 | 0.010 | 1.0 |
| _process | tools/icons.gd:69 | 0.010 | 1.0 |
| _process | ui/palette.gd:156 | 0.006 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.005 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.457 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.455 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.455 |
| _process | ui/panels.gd:208 | 0.307 |
| _update_pointer | ui/panels.gd:222 | 0.285 |
| _update_pointer | ui/panels.gd:824 | 0.285 |
| takes_pointer | ui/panels.gd:888 | 0.236 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.235 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.232 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.232 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.159 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.158 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.146 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.133 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3748 | 0.118 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.117 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.103 |
| _process | tools/manipulator.gd:296 | 0.097 |
| _process_frame | tools/manipulator.gd:298 | 0.095 |
| _process_frame | tools/manipulator.gd:302 | 0.095 |
| face_user | logic_graph/blueprints.gd:851 | 0.092 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.092 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.091 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.089 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.089 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.083 |
| _process | xr/simulator.gd:319 | 0.073 |
| _update_hover | tools/manipulator.gd:332 | 0.065 |
| _update_hover | tools/manipulator.gd:465 | 0.065 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.062 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.061 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.057 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.057 |
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.055 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.050 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.050 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.049 |
| is_action_pressed | xr/rig.gd:83 | 0.047 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.046 |
| _process | telemetry/graph_lab.gd:361 | 0.044 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.055 | 2.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.038 | 4.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.037 | 2.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.025 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.024 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.022 | 18.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.019 | 1.0 |
| cast_segment | tools/manipulator.gd:484 | 0.018 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.018 | 1.0 |
| find_at_point | tools/manipulator.gd:475 | 0.018 | 2.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.017 | 24.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.017 | 15.5 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.015 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.015 | 0.5 |
| _cast | ui/panel_surface.gd:626 | 0.015 | 24.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.015 | 4.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.014 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| get_values | core/feature_settings.gd:1063 | 0.014 | 6.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.011 | 2.0 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.009 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.009 | 24.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _pin_hand | ui/panels.gd:699 | 0.007 | 7.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.007 | 6.0 |
| _process | xr/simulator.gd:474 | 0.006 | 1.0 |
| append | core/feature_settings.gd:1068 | 0.006 | 27.0 |
| set_pose | xr/simulator.gd:353 | 0.006 | 2.0 |

### 05 open_big2

Frames 839, mean Main::iteration 6.06 ms; `process` 1.650 ms, of it its own C++ 0.259 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.259 | 16% |
| plugin: graph (logic_graph/) | 0.847 | 51% |
| plugin: tools (tools/) | 0.138 | 8% |
| plugin: panels and UI (ui/) | 0.104 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.082 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.077 | 5% |
| plugin: core (core/) | 0.076 | 5% |
| plugin: lab (telemetry/graph_lab.gd) | 0.047 | 3% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.006 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.552 | 1.0 |
| _process | ui/panels.gd:208 | 0.444 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.109 | 1.0 |
| _process | xr/simulator.gd:319 | 0.078 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.047 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.030 | 1.0 |
| _process | xr/session.gd:188 | 0.026 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.019 | 1.0 |
| _process | tools/undo.gd:24 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | tools/icons.gd:69 | 0.011 | 1.0 |
| _process | xr/rig.gd:54 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.006 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.001 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.552 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.551 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.550 |
| _process | ui/panels.gd:208 | 0.444 |
| _update_pointer | ui/panels.gd:222 | 0.421 |
| _update_pointer | ui/panels.gd:824 | 0.421 |
| takes_pointer | ui/panels.gd:888 | 0.368 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.367 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.364 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.363 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.249 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.237 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3748 | 0.220 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.219 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.181 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.181 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.163 |
| face_user | logic_graph/blueprints.gd:851 | 0.152 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.149 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.149 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.126 |
| _process | tools/manipulator.gd:296 | 0.109 |
| _process_frame | tools/manipulator.gd:298 | 0.108 |
| _process_frame | tools/manipulator.gd:302 | 0.107 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.106 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.105 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.104 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.103 |
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.103 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.098 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.097 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.083 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4711 | 0.080 |
| _process | xr/simulator.gd:319 | 0.078 |
| _update_hover | tools/manipulator.gd:332 | 0.076 |
| _update_hover | tools/manipulator.gd:465 | 0.076 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.075 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.068 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.067 |
| _link_wire_hit | logic_graph/blueprints.gd:7017 | 0.052 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.103 | 2.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.082 | 2.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.066 | 4.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.040 | 32.5 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.036 | 0.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.031 | 30.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.026 | 40.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.025 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.025 | 2.0 |
| cast_segment | tools/manipulator.gd:484 | 0.023 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.021 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.020 | 1.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.019 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.016 | 2.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.015 | 4.0 |
| _cast | ui/panel_surface.gd:626 | 0.015 | 24.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.015 | 4.0 |
| get_values | core/feature_settings.gd:1063 | 0.015 | 6.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.014 | 1.0 |
| update | xr/simulator.gd:427 | 0.013 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.013 | 40.0 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.011 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.010 | 9.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _process | tools/icons.gd:69 | 0.008 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| focus_paint | logic_graph/blueprint_canvas.gd:3077 | 0.007 | 32.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| append | core/feature_settings.gd:1068 | 0.006 | 27.0 |
