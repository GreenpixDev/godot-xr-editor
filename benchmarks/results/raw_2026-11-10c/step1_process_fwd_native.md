
### 01 closed

Frames 839, mean Main::iteration 6.05 ms; `process` 0.961 ms, of it its own C++ 0.307 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.307 | 32% |
| plugin: tools (tools/) | 0.151 | 16% |
| plugin: graph (logic_graph/) | 0.151 | 16% |
| plugin: simulator (xr/simulator.gd) | 0.098 | 10% |
| plugin: controllers, rays, rig (xr/) | 0.087 | 9% |
| plugin: core (core/) | 0.066 | 7% |
| plugin: lab (telemetry/graph_lab.gd) | 0.050 | 5% |
| plugin: panels and UI (ui/) | 0.045 | 5% |
| plugin: other (playmode) | 0.006 | 1% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.145 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.126 | 1.0 |
| _process | xr/simulator.gd:319 | 0.092 | 1.0 |
| _process | ui/panels.gd:208 | 0.061 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.050 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.034 | 1.0 |
| _process | xr/session.gd:188 | 0.031 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.022 | 1.0 |
| _process | tools/undo.gd:24 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.017 | 1.0 |
| _process | xr/rig.gd:54 | 0.014 | 1.0 |
| _process | tools/icons.gd:69 | 0.013 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.012 | 1.0 |
| _process | ui/palette.gd:156 | 0.008 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.007 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.002 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.145 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.144 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.143 |
| _process | tools/manipulator.gd:296 | 0.126 |
| _process_frame | tools/manipulator.gd:298 | 0.125 |
| _process_frame | tools/manipulator.gd:302 | 0.124 |
| _update_hover | tools/manipulator.gd:332 | 0.092 |
| _process | xr/simulator.gd:319 | 0.092 |
| _update_hover | tools/manipulator.gd:465 | 0.092 |
| _process | ui/panels.gd:208 | 0.061 |
| is_action_pressed | xr/rig.gd:83 | 0.054 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.051 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.051 |
| _process | telemetry/graph_lab.gd:361 | 0.050 |
| _update_pointer | ui/panels.gd:222 | 0.042 |
| _update_pointer | ui/panels.gd:824 | 0.042 |
| _update_inputs | xr/simulator.gd:325 | 0.037 |
| _update_inputs | xr/simulator.gd:357 | 0.037 |
| _process | tools/locomotion.gd:108 | 0.034 |
| _update_poses | xr/simulator.gd:324 | 0.033 |
| binding_of | core/feature_settings.gd:1136 | 0.033 |
| _update_poses | xr/simulator.gd:335 | 0.033 |
| _process | xr/session.gd:188 | 0.031 |
| get_action_hand | xr/rig.gd:78 | 0.031 |
| get_binding | core/feature_settings.gd:1137 | 0.029 |
| cast_segment | tools/manipulator.gd:484 | 0.028 |
| get_binding | core/feature_settings.gd:1121 | 0.027 |
| find_at_point | tools/manipulator.gd:475 | 0.026 |
| _process | tools/selection_counter.gd:87 | 0.022 |
| hover_actions | logic_graph/blueprints.gd:3027 | 0.020 |
| get_action_hand | xr/rig.gd:87 | 0.020 |
| hover_actions | logic_graph/blueprint_canvas.gd:3299 | 0.019 |
| _report | telemetry/graph_lab.gd:379 | 0.019 |
| _report | telemetry/graph_lab.gd:493 | 0.019 |
| _report_frames | telemetry/graph_lab.gd:499 | 0.019 |
| _report_frames | telemetry/graph_lab.gd:503 | 0.019 |
| binding_of | xr/rig.gd:79 | 0.019 |
| is_action_pressed | tools/locomotion.gd:109 | 0.018 |
| _process | tools/undo.gd:24 | 0.017 |
| _process | xr/simulator.gd:474 | 0.017 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| cast_segment | tools/manipulator.gd:484 | 0.028 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.026 | 2.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.019 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.018 | 1.0 |
| _update_poses | xr/simulator.gd:335 | 0.016 | 1.0 |
| update | xr/simulator.gd:427 | 0.016 | 1.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _update_hover | tools/manipulator.gd:465 | 0.013 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.011 | 1.0 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| button_input | core/feature_settings.gd:1146 | 0.009 | 12.0 |
| _process | tools/icons.gd:69 | 0.009 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.009 | 2.0 |
| _process | tools/locomotion.gd:108 | 0.009 | 1.0 |
| _process | xr/simulator.gd:474 | 0.009 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.008 | 14.0 |
| set_pose | xr/simulator.gd:353 | 0.008 | 2.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.008 | 12.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.008 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| update_input | xr/hand.gd:92 | 0.007 | 2.0 |
| get_values | core/feature_settings.gd:1063 | 0.007 | 2.0 |
| show_ray | xr/hand.gd:168 | 0.007 | 2.0 |
| set_pose | xr/simulator.gd:354 | 0.007 | 2.0 |
| _process | xr/session.gd:188 | 0.006 | 1.0 |
| get_binding | core/feature_settings.gd:1121 | 0.006 | 12.0 |
| is_action_pressed | xr/rig.gd:83 | 0.005 | 5.0 |
| find_at_point | tools/icons.gd:152 | 0.005 | 2.0 |
| cast_segment | tools/icons.gd:118 | 0.005 | 2.0 |
| _update_desktop_ui | xr/session.gd:575 | 0.004 | 1.0 |
| binding_of | core/feature_settings.gd:1136 | 0.004 | 12.0 |
| _process | telemetry/graph_lab.gd:361 | 0.004 | 1.0 |
| is_holding | logic_graph/blueprints.gd:2332 | 0.004 | 2.0 |
| hover_actions | logic_graph/blueprint_canvas.gd:3299 | 0.004 | 2.0 |
| _process | ui/palette.gd:156 | 0.004 | 1.0 |
| update | xr/desktop_ui.gd:47 | 0.004 | 1.0 |
| get | core/feature_settings.gd:1130 | 0.004 | 12.0 |
| _process | tools/clipboard.gd:96 | 0.004 | 1.0 |
| poll_trigger | ui/virtual_keyboard.gd:233 | 0.004 | 2.0 |
| get_cmdline_user_args | telemetry/graph_lab.gd:370 | 0.004 | 1.0 |

### 02 open

Frames 839, mean Main::iteration 6.06 ms; `process` 1.727 ms, of it its own C++ 0.310 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.310 | 18% |
| plugin: graph (logic_graph/) | 0.793 | 46% |
| plugin: tools (tools/) | 0.155 | 9% |
| plugin: panels and UI (ui/) | 0.121 | 7% |
| plugin: simulator (xr/simulator.gd) | 0.097 | 6% |
| plugin: controllers, rays, rig (xr/) | 0.092 | 5% |
| plugin: core (core/) | 0.085 | 5% |
| plugin: lab (telemetry/graph_lab.gd) | 0.053 | 3% |
| other GDScript | 0.013 | 1% |
| plugin: other (playmode) | 0.006 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.617 | 1.0 |
| _process | ui/panels.gd:208 | 0.347 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.121 | 1.0 |
| _process | xr/simulator.gd:319 | 0.091 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.053 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.034 | 1.0 |
| _process | xr/session.gd:188 | 0.033 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.022 | 1.0 |
| _process | tools/undo.gd:24 | 0.019 | 1.0 |
| _process | xr/simulator.gd:474 | 0.015 | 1.0 |
| _process | tools/icons.gd:69 | 0.013 | 1.0 |
| _process | xr/rig.gd:54 | 0.013 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.012 | 1.0 |
| _process | ui/palette.gd:156 | 0.008 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.007 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.006 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.002 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.617 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.615 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.615 |
| _process | ui/panels.gd:208 | 0.347 |
| _update_pointer | ui/panels.gd:222 | 0.322 |
| _update_pointer | ui/panels.gd:824 | 0.322 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.270 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.270 |
| takes_pointer | ui/panels.gd:888 | 0.260 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.260 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.256 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.255 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.239 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3737 | 0.237 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.236 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.141 |
| _process | tools/manipulator.gd:296 | 0.121 |
| _process_frame | tools/manipulator.gd:298 | 0.119 |
| _process_frame | tools/manipulator.gd:302 | 0.119 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.116 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.114 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.112 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.111 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.111 |
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.110 |
| face_user | logic_graph/blueprints.gd:851 | 0.099 |
| intersect_ray | logic_graph/blueprints.gd:2930 | 0.099 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.096 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.095 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.092 |
| _process | xr/simulator.gd:319 | 0.091 |
| _update_hover | tools/manipulator.gd:332 | 0.083 |
| _update_hover | tools/manipulator.gd:465 | 0.083 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.068 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.067 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.058 |
| is_action_pressed | xr/rig.gd:83 | 0.055 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.054 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.053 |
| _process | telemetry/graph_lab.gd:361 | 0.053 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.110 | 4.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.073 | 4.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.042 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.028 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.028 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.025 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.023 | 18.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.022 | 4.0 |
| cast_segment | tools/manipulator.gd:484 | 0.022 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.022 | 1.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.020 | 1.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.018 | 24.0 |
| _cast | ui/panel_surface.gd:626 | 0.017 | 24.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.017 | 15.5 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.017 | 2.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.017 | 0.5 |
| _update_poses | xr/simulator.gd:335 | 0.016 | 1.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.016 | 4.0 |
| get_values | core/feature_settings.gd:1063 | 0.016 | 6.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| update | xr/simulator.gd:427 | 0.015 | 1.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.013 | 12.0 |
| _update_pointer | ui/panels.gd:824 | 0.013 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.012 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.011 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.011 | 24.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.010 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.010 | 12.0 |
| _process | tools/icons.gd:69 | 0.010 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.010 | 18.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| _process | xr/simulator.gd:474 | 0.008 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.008 | 14.0 |
| set_pose | xr/simulator.gd:353 | 0.008 | 2.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.008 | 12.0 |
| append | core/feature_settings.gd:1068 | 0.007 | 27.0 |
| update_input | xr/hand.gd:92 | 0.007 | 2.0 |

### 03 open_big2

Frames 841, mean Main::iteration 6.06 ms; `process` 1.890 ms, of it its own C++ 0.274 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.274 | 14% |
| plugin: graph (logic_graph/) | 1.031 | 55% |
| plugin: tools (tools/) | 0.147 | 8% |
| plugin: panels and UI (ui/) | 0.112 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.089 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.085 | 5% |
| plugin: core (core/) | 0.082 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.051 | 3% |
| other GDScript | 0.013 | 1% |
| plugin: other (playmode) | 0.006 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.754 | 1.0 |
| _process | ui/panels.gd:208 | 0.438 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.117 | 1.0 |
| _process | xr/simulator.gd:319 | 0.084 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.051 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.031 | 1.0 |
| _process | xr/session.gd:188 | 0.028 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.020 | 1.0 |
| _process | tools/undo.gd:24 | 0.019 | 1.0 |
| _process | xr/simulator.gd:474 | 0.014 | 1.0 |
| _process | xr/rig.gd:54 | 0.012 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.012 | 1.0 |
| _process | tools/icons.gd:69 | 0.012 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.007 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.754 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.753 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.752 |
| _process | ui/panels.gd:208 | 0.438 |
| _update_pointer | ui/panels.gd:222 | 0.414 |
| _update_pointer | ui/panels.gd:824 | 0.414 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.399 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3737 | 0.396 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.395 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.362 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.361 |
| takes_pointer | ui/panels.gd:888 | 0.359 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.358 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.355 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.354 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.225 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.189 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.188 |
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.184 |
| intersect_ray | logic_graph/blueprints.gd:2930 | 0.175 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.167 |
| face_user | logic_graph/blueprints.gd:851 | 0.155 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.152 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.151 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.128 |
| _process | tools/manipulator.gd:296 | 0.117 |
| _process_frame | tools/manipulator.gd:298 | 0.116 |
| _process_frame | tools/manipulator.gd:302 | 0.115 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.105 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.105 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.105 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.104 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.084 |
| _process | xr/simulator.gd:319 | 0.084 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4711 | 0.081 |
| _update_hover | tools/manipulator.gd:332 | 0.081 |
| _update_hover | tools/manipulator.gd:465 | 0.081 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.076 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.072 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.071 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.184 | 4.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.147 | 4.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.066 | 4.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.040 | 32.5 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.037 | 0.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.031 | 30.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.028 | 2.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.027 | 40.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.026 | 0.5 |
| cast_segment | tools/manipulator.gd:484 | 0.024 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.023 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.021 | 1.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.020 | 18.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.020 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.020 | 4.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.016 | 2.0 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| get_values | core/feature_settings.gd:1063 | 0.016 | 6.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.015 | 4.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.015 | 0.0 |
| _update_poses | xr/simulator.gd:335 | 0.014 | 1.0 |
| update | xr/simulator.gd:427 | 0.014 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.013 | 40.0 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.011 | 1.0 |
| _update_inputs | xr/simulator.gd:357 | 0.011 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.010 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.009 | 12.0 |
| _process | tools/icons.gd:69 | 0.009 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| button_hand | core/feature_settings.gd:1141 | 0.008 | 14.0 |
| _process | xr/simulator.gd:474 | 0.008 | 1.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| focus_paint | logic_graph/blueprint_canvas.gd:3077 | 0.007 | 32.0 |
| set_pose | xr/simulator.gd:353 | 0.007 | 2.0 |
| append | core/feature_settings.gd:1068 | 0.007 | 27.0 |

### 04 open

Frames 843, mean Main::iteration 6.05 ms; `process` 1.467 ms, of it its own C++ 0.247 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.247 | 17% |
| plugin: graph (logic_graph/) | 0.697 | 48% |
| plugin: tools (tools/) | 0.127 | 9% |
| plugin: panels and UI (ui/) | 0.101 | 7% |
| plugin: simulator (xr/simulator.gd) | 0.080 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.076 | 5% |
| plugin: core (core/) | 0.075 | 5% |
| plugin: lab (telemetry/graph_lab.gd) | 0.047 | 3% |
| other GDScript | 0.012 | 1% |
| plugin: other (playmode) | 0.005 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.552 | 1.0 |
| _process | ui/panels.gd:208 | 0.292 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.100 | 1.0 |
| _process | xr/simulator.gd:319 | 0.076 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.047 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.028 | 1.0 |
| _process | xr/session.gd:188 | 0.025 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.018 | 1.0 |
| _process | tools/undo.gd:24 | 0.017 | 1.0 |
| _process | xr/simulator.gd:474 | 0.013 | 1.0 |
| _process | xr/rig.gd:54 | 0.012 | 1.0 |
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
| _process | logic_graph/blueprints.gd:804 | 0.552 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.550 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.550 |
| _process | ui/panels.gd:208 | 0.292 |
| _update_pointer | ui/panels.gd:222 | 0.270 |
| _update_pointer | ui/panels.gd:824 | 0.270 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.244 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.244 |
| takes_pointer | ui/panels.gd:888 | 0.220 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.220 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.217 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.216 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.210 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3737 | 0.208 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.207 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.119 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.104 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.100 |
| _process | tools/manipulator.gd:296 | 0.100 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.099 |
| _process_frame | tools/manipulator.gd:298 | 0.098 |
| _process_frame | tools/manipulator.gd:302 | 0.098 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.096 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.096 |
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.096 |
| face_user | logic_graph/blueprints.gd:851 | 0.093 |
| intersect_ray | logic_graph/blueprints.gd:2930 | 0.092 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.090 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.089 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.081 |
| _process | xr/simulator.gd:319 | 0.076 |
| _update_hover | tools/manipulator.gd:332 | 0.067 |
| _update_hover | tools/manipulator.gd:465 | 0.067 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.059 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.058 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.050 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.049 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.049 |
| is_action_pressed | xr/rig.gd:83 | 0.048 |
| _process | telemetry/graph_lab.gd:361 | 0.047 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.096 | 4.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.065 | 4.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.037 | 4.0 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.025 | 0.5 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.025 | 2.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.022 | 18.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.020 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.019 | 4.0 |
| find_at_point | tools/manipulator.gd:475 | 0.019 | 2.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.018 | 1.0 |
| cast_segment | tools/manipulator.gd:484 | 0.018 | 2.0 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.016 | 15.5 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.016 | 24.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.016 | 0.5 |
| _cast | ui/panel_surface.gd:626 | 0.015 | 24.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.015 | 2.0 |
| get_values | core/feature_settings.gd:1063 | 0.014 | 6.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.014 | 0.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.014 | 4.0 |
| _update_poses | xr/simulator.gd:335 | 0.013 | 1.0 |
| update | xr/simulator.gd:427 | 0.012 | 1.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.012 | 12.0 |
| _update_pointer | ui/panels.gd:824 | 0.011 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.010 | 1.0 |
| _update_inputs | xr/simulator.gd:357 | 0.010 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.010 | 2.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.009 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.009 | 24.0 |
| button_input | core/feature_settings.gd:1146 | 0.008 | 12.0 |
| _pin_hand | ui/panels.gd:699 | 0.007 | 7.0 |
| _process | tools/icons.gd:69 | 0.007 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.007 | 14.0 |
| _process_frame | tools/manipulator.gd:302 | 0.007 | 1.0 |
| _process | xr/simulator.gd:474 | 0.007 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.007 | 1.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| update_input | xr/hand.gd:92 | 0.006 | 2.0 |
| _bounds | logic_graph/blueprint_boxes.gd:939 | 0.006 | 8.0 |
| append | core/feature_settings.gd:1068 | 0.006 | 27.0 |

### 05 open_big2

Frames 854, mean Main::iteration 6.06 ms; `process` 1.894 ms, of it its own C++ 0.279 ms.

| Inside `process`: own time by group | ms/frame | Share |
|---|---|---|
| `process` own C++ (editor and engine nodes, no zones) | 0.279 | 15% |
| plugin: graph (logic_graph/) | 1.030 | 54% |
| plugin: tools (tools/) | 0.149 | 8% |
| plugin: panels and UI (ui/) | 0.110 | 6% |
| plugin: simulator (xr/simulator.gd) | 0.090 | 5% |
| plugin: controllers, rays, rig (xr/) | 0.085 | 4% |
| plugin: core (core/) | 0.080 | 4% |
| plugin: lab (telemetry/graph_lab.gd) | 0.052 | 3% |
| other GDScript | 0.013 | 1% |
| plugin: other (playmode) | 0.006 | 0% |
| plugin: telemetry, other | 0.001 | 0% |

| Direct child of `process` (total) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.745 | 1.0 |
| _process | ui/panels.gd:208 | 0.444 | 1.0 |
| _process | tools/manipulator.gd:296 | 0.118 | 1.0 |
| _process | xr/simulator.gd:319 | 0.084 | 1.0 |
| _process | telemetry/graph_lab.gd:361 | 0.052 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.031 | 1.0 |
| _process | xr/session.gd:188 | 0.028 | 1.0 |
| _process | tools/selection_counter.gd:87 | 0.020 | 1.0 |
| _process | tools/undo.gd:24 | 0.019 | 1.0 |
| _process | xr/simulator.gd:474 | 0.015 | 1.0 |
| _process | xr/rig.gd:54 | 0.012 | 1.0 |
| _process | tools/icons.gd:69 | 0.012 | 1.0 |
| _process | tools/clipboard.gd:96 | 0.011 | 1.0 |
| _process | ui/palette.gd:156 | 0.007 | 1.0 |
| _process | playmode/play_mode.gd:135 | 0.007 | 1.0 |
| _process | ui/panel_window.gd:181 | 0.005 | 1.0 |
| _process | tools/object_shortcut.gd:168 | 0.002 | 1.0 |
| _process | playmode/transition_screen.gd:84 | 0.001 | 1.0 |
| _notification | xr/rig.gd:130 | 0.001 | 1.0 |
| _process | ui/panel_surface.gd:442 | 0.001 | 1.0 |

| Zone inside `process` (total, with what it calls) | Source | ms/frame |
|---|---|---|
| _process | logic_graph/blueprints.gd:804 | 0.745 |
| _process_frame | logic_graph/blueprints.gd:806 | 0.744 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.743 |
| _process | ui/panels.gd:208 | 0.444 |
| _update_pointer | ui/panels.gd:222 | 0.421 |
| _update_pointer | ui/panels.gd:824 | 0.420 |
| intersect_ray | logic_graph/blueprint_canvas.gd:3736 | 0.401 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3737 | 0.398 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.397 |
| takes_pointer | ui/panels.gd:888 | 0.366 |
| takes_pointer | logic_graph/blueprints.gd:3288 | 0.365 |
| _takes_pointer | logic_graph/blueprints.gd:3290 | 0.362 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.361 |
| _update_pointer | logic_graph/blueprints.gd:867 | 0.358 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.357 |
| intersect_ray | logic_graph/blueprints.gd:3320 | 0.229 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4180 | 0.191 |
| _intersect_wires | logic_graph/blueprint_canvas.gd:4263 | 0.190 |
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.186 |
| intersect_ray | logic_graph/blueprints.gd:2930 | 0.172 |
| face_user | logic_graph/blueprint_canvas.gd:2570 | 0.166 |
| face_user | logic_graph/blueprints.gd:851 | 0.154 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:2577 | 0.151 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.150 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.132 |
| _process | tools/manipulator.gd:296 | 0.118 |
| _process_frame | tools/manipulator.gd:298 | 0.116 |
| _process_frame | tools/manipulator.gd:302 | 0.116 |
| intersect_link_wire | logic_graph/blueprints.gd:6989 | 0.108 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.107 |
| _update_target_wires | logic_graph/blueprints.gd:891 | 0.104 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.103 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.084 |
| _process | xr/simulator.gd:319 | 0.084 |
| _update_hover | tools/manipulator.gd:332 | 0.082 |
| _update_hover | tools/manipulator.gd:465 | 0.082 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4711 | 0.081 |
| _link_wire_hit | logic_graph/blueprints.gd:3316 | 0.079 |
| _point_at_link_wire | logic_graph/blueprints.gd:3007 | 0.073 |
| _point_at_link_wire | logic_graph/blueprints.gd:7012 | 0.072 |

| Zone inside `process` (own) | Source | ms/frame | Calls/frame |
|---|---|---|---|
| pick | logic_graph/blueprint_canvas.gd:4266 | 0.186 | 4.0 |
| _intersect_ray | logic_graph/blueprint_canvas.gd:3870 | 0.147 | 4.0 |
| intersect_link_wire | logic_graph/blueprint_canvas.gd:5873 | 0.069 | 4.0 |
| _list_arrows | logic_graph/blueprint_canvas.gd:4727 | 0.040 | 32.5 |
| lay | logic_graph/blueprint_canvas.gd:4714 | 0.037 | 0.5 |
| _arrow_color | logic_graph/blueprint_canvas.gd:4823 | 0.031 | 30.0 |
| _update_pointer | logic_graph/blueprints.gd:2797 | 0.027 | 2.0 |
| intersect_wire | logic_graph/blueprint_canvas.gd:5900 | 0.027 | 40.0 |
| _lay_arrows | logic_graph/blueprint_canvas.gd:4700 | 0.025 | 0.5 |
| cast_segment | tools/manipulator.gd:484 | 0.025 | 2.0 |
| find_at_point | tools/manipulator.gd:475 | 0.023 | 2.0 |
| _update_target_wires | logic_graph/blueprints.gd:4181 | 0.021 | 1.0 |
| intersect_ray | logic_graph/blueprint_boxes.gd:692 | 0.020 | 4.0 |
| _box_distance | logic_graph/blueprint_canvas.gd:4345 | 0.020 | 18.0 |
| _process_frame | logic_graph/blueprints.gd:824 | 0.020 | 1.0 |
| _takes_pointer | logic_graph/blueprints.gd:3295 | 0.016 | 2.0 |
| _cast | ui/panel_surface.gd:626 | 0.016 | 24.0 |
| find_children | telemetry/graph_lab.gd:547 | 0.016 | 0.0 |
| _link_wire_hit | logic_graph/blueprints.gd:6987 | 0.015 | 4.0 |
| get_values | core/feature_settings.gd:1063 | 0.015 | 6.0 |
| _update_poses | xr/simulator.gd:335 | 0.014 | 1.0 |
| update | xr/simulator.gd:427 | 0.014 | 1.0 |
| intersect_ray | logic_graph/blueprint_canvas.gd:5905 | 0.014 | 40.0 |
| _update_pointer | ui/panels.gd:824 | 0.012 | 2.0 |
| _measure | telemetry/graph_lab.gd:472 | 0.011 | 1.0 |
| _update_hover | tools/manipulator.gd:465 | 0.011 | 2.0 |
| _update_inputs | xr/simulator.gd:357 | 0.011 | 1.0 |
| _ray_over_plates | logic_graph/blueprints.gd:6083 | 0.010 | 1.0 |
| button_input | core/feature_settings.gd:1146 | 0.009 | 12.0 |
| _process | tools/icons.gd:69 | 0.009 | 1.0 |
| _pin_hand | ui/panels.gd:699 | 0.008 | 7.0 |
| _process | xr/simulator.gd:474 | 0.008 | 1.0 |
| _process | tools/locomotion.gd:108 | 0.008 | 1.0 |
| button_hand | core/feature_settings.gd:1141 | 0.008 | 14.0 |
| _process_frame | tools/manipulator.gd:302 | 0.008 | 1.0 |
| focus_paint | logic_graph/blueprint_canvas.gd:3077 | 0.007 | 32.0 |
| intersect_ray | ui/panel_surface.gd:286 | 0.007 | 18.0 |
| preset_binding | core/feature_settings.gd:1129 | 0.007 | 12.0 |
| set_pose | xr/simulator.gd:353 | 0.007 | 2.0 |
| update_input | xr/hand.gd:92 | 0.007 | 2.0 |
