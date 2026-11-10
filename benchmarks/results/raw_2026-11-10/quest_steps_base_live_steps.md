
benchmarks/results/raw_2026-11-10/quest_steps_base_live.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 7 | 72 | 0 | 8.68 | 6.7 | 0.74 | 441 | 2/2 | 3 | 10 |
| closed_vr_off | 7 | 72 | 0 | 8.36 | 11.6 | 0.72 | 441 | 2/2 | 3 | 10 |
| closed_views_off | 7 | 72 | 0 | 8.58 | 6.9 | 0.72 | 441 | 2/2 | 3 | 10 |
| closed_root_off | 7 | 72 | 0 | 5.67 | 5.4 | 0.53 | 441 | 2/2 | 3 | 10 |
| closed_lean | 7 | 72 | 0 | 6.97 | 5.5 | 0.62 | 441 | 2/2 | 3 | 10 |
| closed_scene_off | 7 | 72 | 0 | 7.21 | 14.0 | 0.64 | 441 | 2/2 | 3 | 0 |
| closed_empty | 7 | 72 | 0 | 5.38 | 5.2 | 0.51 | 441 | 2/2 | 3 | 1 |
| closed | 7 | 72 | 0 | 8.05 | 13.5 | 0.69 | 441 | 2/2 | 3 | 11 |
| open | 8 | 72 | 0 | 12.45 | 14.7 | 0.97 | 525 | 2/4 | 3 | 328 |
| open_dimmer_off | 7 | 72 | 0 | 12.47 | 14.7 | 0.99 | 525 | 2/4 | 3 | 327 |
| open_ui_off | 7 | 72 | 0 | 12.47 | 14.7 | 0.99 | 525 | 2/4 | 3 | 306 |
| open_all_off | 7 | 72 | 0 | 8.91 | 13.7 | 0.75 | 490 | 2/2 | 3 | 41 |
| open_views_off | 7 | 72 | 0 | 12.46 | 14.9 | 0.99 | 525 | 2/4 | 3 | 308 |
| open_root_off | 7 | 72 | 0 | 9.88 | 12.2 | 0.81 | 525 | 2/4 | 3 | 328 |
| open_lean | 7 | 68 | 12 | 11.88 | 12.9 | 0.89 | 525 | 5/4 | 3 | 328 |
| open | 7 | 71 | 2 | 12.42 | 14.8 | 0.98 | 525 | 2/4 | 3 | 328 |
| open_big2 | 8 | 54 | 18 | 16.46 | 20.0 | 0.98 | 525 | 5/4 | 3 | 590 |
| closed | 7 | 72 | 0 | 8.62 | 14.9 | 0.74 | 441 | 2/2 | 3 | 12 |
| compat_closed | 8 | 72 | 2 | 4.29 | 4.1 | 0.41 | 441 | 2/2 | 3 | 25 |
| compat_closed_vr_off | 7 | 72 | 0 | 4.28 | 4.3 | 0.43 | 441 | 2/2 | 3 | 25 |
| compat_closed_empty | 7 | 72 | 0 | 1.18 | 3.7 | 0.19 | 441 | 2/2 | 3 | 0 |
| compat_open | 10 | 72 | 0 | 6.89 | 10.3 | 0.58 | 525 | 2/2 | 3 | 410 |
| compat_open_ui_off | 7 | 72 | 0 | 7.02 | 10.6 | 0.61 | 490 | 2/2 | 3 | 388 |
| compat_open_all_off | 7 | 72 | 0 | 4.69 | 6.7 | 0.46 | 490 | 2/2 | 3 | 55 |
| compat_open_big2 | 8 | 72 | 0 | 9.02 | 14.1 | 0.74 | 490 | 5/3 | 3 | 732 |
| compat_open | 7 | 72 | 0 | 7.26 | 11.1 | 0.64 | 441 | 2/2 | 3 | 410 |
| compat_closed | 7 | 72 | 0 | 4.26 | 4.5 | 0.43 | 490 | 2/2 | 3 | 26 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.33 | 7.36 | 5 | 5 | 50 | 5 | 0 |
| closed | root | 0.04 | 1.32 | 0 | 0 | 0 | 0 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_vr_off | XRESession/XREViewport | 0.33 | 7.36 | 5 | 5 | 50 | 5 | 0 |
| closed_vr_off | root | 0.04 | 1.32 | 0 | 0 | 0 | 0 | 0 |
| closed_vr_off | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_views_off | XRESession/XREViewport | 0.33 | 7.29 | 5 | 5 | 50 | 5 | 0 |
| closed_views_off | root | 0.04 | 1.31 | 0 | 0 | 0 | 0 | 0 |
| closed_views_off | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_root_off | XRESession/XREViewport | 0.33 | 6.40 | 5 | 5 | 50 | 5 | 0 |
| closed_root_off | root | 0.04 | 1.61 | 0 | 0 | 0 | 0 | 0 |
| closed_root_off | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_lean | XRESession/XREViewport | 0.38 | 4.92 | 5 | 5 | 50 | 5 | 0 |
| closed_lean | root | 0.04 | 1.55 | 0 | 0 | 0 | 0 | 0 |
| closed_lean | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene_off | XRESession/XREViewport | 0.29 | 4.89 | 0 | 0 | 0 | 0 | 0 |
| closed_scene_off | root | 0.04 | 1.41 | 0 | 0 | 0 | 0 | 0 |
| closed_scene_off | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_empty | XRESession/XREViewport | 0.17 | 3.56 | 1 | 1 | 12 | 0 | 0 |
| closed_empty | root | 0.04 | 1.11 | 0 | 0 | 0 | 0 | 0 |
| closed_empty | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | XRESession/XREViewport | 0.34 | 7.31 | 6 | 6 | 62 | 5 | 0 |
| closed | root | 0.04 | 1.29 | 0 | 0 | 0 | 0 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | XRESession/XREViewport | 1.29 | 11.16 | 303 | 303 | 80124 | 5 | 0 |
| open | root | 0.04 | 1.18 | 0 | 0 | 0 | 0 | 0 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_dimmer_off | XRESession/XREViewport | 1.17 | 10.87 | 302 | 302 | 80102 | 5 | 0 |
| open_dimmer_off | root | 0.04 | 1.36 | 0 | 0 | 0 | 0 | 0 |
| open_dimmer_off | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_dimmer_off | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_dimmer_off | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_ui_off | XRESession/XREViewport | 1.23 | 11.14 | 301 | 301 | 80124 | 5 | 0 |
| open_ui_off | root | 0.04 | 1.35 | 0 | 0 | 0 | 0 | 0 |
| open_ui_off | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_ui_off | Badge/Viewport | 0.12 | 0.06 | 0 | 0 | 0 | 0 | 10 |
| open_ui_off | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_all_off | XRESession/XREViewport | 0.45 | 6.90 | 16 | 16 | 1608 | 5 | 0 |
| open_all_off | root | 0.04 | 1.21 | 0 | 0 | 0 | 0 | 0 |
| open_all_off | Badge/Viewport | 0.13 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open_all_off | FunctionsWindow/Viewport | 0.07 | 0.14 | 0 | 0 | 0 | 0 | 10 |
| open_all_off | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_views_off | XRESession/XREViewport | 1.24 | 11.09 | 303 | 303 | 80104 | 5 | 0 |
| open_views_off | root | 0.04 | 1.42 | 0 | 0 | 0 | 0 | 0 |
| open_views_off | FunctionsWindow/Viewport | 0.07 | 0.14 | 0 | 0 | 0 | 0 | 10 |
| open_views_off | Badge/Viewport | 0.11 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open_views_off | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_root_off | XRESession/XREViewport | 1.23 | 11.06 | 303 | 303 | 80128 | 5 | 0 |
| open_root_off | root | 0.04 | 1.35 | 0 | 0 | 0 | 0 | 0 |
| open_root_off | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_root_off | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_root_off | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_lean | XRESession/XREViewport | 1.06 | 9.84 | 303 | 303 | 80124 | 5 | 0 |
| open_lean | root | 0.03 | 1.41 | 0 | 0 | 0 | 0 | 0 |
| open_lean | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_lean | FunctionsWindow/Viewport | 0.06 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_lean | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | XRESession/XREViewport | 1.20 | 10.26 | 303 | 303 | 80104 | 5 | 0 |
| open | root | 0.04 | 1.78 | 0 | 0 | 0 | 0 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | XRESession/XREViewport | 1.54 | 14.90 | 565 | 565 | 155214 | 5 | 0 |
| open_big2 | root | 0.03 | 1.35 | 0 | 0 | 0 | 0 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.05 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | XRESession/XREViewport | 0.38 | 6.51 | 7 | 7 | 74 | 5 | 0 |
| closed | root | 0.04 | 1.30 | 0 | 0 | 0 | 0 | 0 |
| closed | Badge/Viewport | 0.11 | 0.06 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| compat_closed | XRESession/XREViewport | 0.67 | 0.00 | 25 | 25 | 50 | 0 | 0 |
| compat_closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| compat_closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| compat_closed_vr_off | XRESession/XREViewport | 0.67 | 0.00 | 25 | 25 | 50 | 0 | 0 |
| compat_closed_vr_off | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| compat_closed_vr_off | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| compat_closed_empty | XRESession/XREViewport | 0.18 | 0.00 | 0 | 0 | 0 | 0 | 0 |
| compat_closed_empty | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| compat_closed_empty | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| compat_open | XRESession/XREViewport | 3.22 | 0.00 | 390 | 390 | 80108 | 0 | 0 |
| compat_open | Badge/Viewport | 0.43 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| compat_open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| compat_open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| compat_open_ui_off | XRESession/XREViewport | 3.24 | 0.00 | 388 | 388 | 80088 | 0 | 0 |
| compat_open_ui_off | Badge/Viewport | 0.41 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| compat_open_ui_off | FunctionsWindow/Viewport | 0.25 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| compat_open_ui_off | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| compat_open_ui_off | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| compat_open_all_off | XRESession/XREViewport | 0.78 | 0.00 | 35 | 35 | 1596 | 0 | 0 |
| compat_open_all_off | Badge/Viewport | 0.42 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| compat_open_all_off | FunctionsWindow/Viewport | 0.26 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| compat_open_all_off | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| compat_open_all_off | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| compat_open_big2 | XRESession/XREViewport | 4.87 | 0.00 | 712 | 712 | 155182 | 0 | 0 |
| compat_open_big2 | Badge/Viewport | 0.41 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| compat_open_big2 | FunctionsWindow/Viewport | 0.24 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| compat_open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| compat_open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| compat_open | XRESession/XREViewport | 3.30 | 0.00 | 390 | 390 | 80092 | 0 | 0 |
| compat_open | Badge/Viewport | 0.43 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| compat_open | FunctionsWindow/Viewport | 0.26 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| compat_open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| compat_open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| compat_closed | XRESession/XREViewport | 0.78 | 0.00 | 26 | 26 | 62 | 0 | 0 |
| compat_closed | Badge/Viewport | 0.42 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| compat_closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| compat_closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |

Lab lines, the step's last report (fps, VR view render CPU/GPU, TIME_PROCESS, draw calls; graph scripts):

benchmarks/results/raw_2026-11-10/quest_steps_base_live.log
| Step | fps | view CPU | view GPU | process | calls | graph scripts | facing | rays | manip |
|---|---|---|---|---|---|---|---|---|---|
| closed | 71 | 0.33 | 7.36 | 17.54 | 10 | 0.31 | 0.00 | 0.03 | 0.29 |
| closed_vr_off | 72 | 0.33 | 7.36 | 18.79 | 10 | 0.32 | 0.00 | 0.03 | 0.28 |
| closed_views_off | 72 | 0.33 | 7.29 | 17.06 | 10 | 0.31 | 0.00 | 0.03 | 0.29 |
| closed_root_off | 72 | 0.33 | 6.40 | 16.24 | 10 | 0.31 | 0.00 | 0.03 | 0.29 |
| closed_lean | 72 | 0.38 | 4.92 | 23.60 | 10 | 0.34 | 0.00 | 0.03 | 0.33 |
| closed_scene_off | 71 | 0.29 | 4.89 | 26.97 | 0 | 0.31 | 0.00 | 0.03 | 0.23 |
| closed_empty | 71 | 0.17 | 3.56 | 16.11 | 1 | 0.31 | 0.00 | 0.03 | 0.21 |
| closed | 72 | 0.34 | 7.31 | 19.04 | 11 | 0.31 | 0.00 | 0.03 | 0.24 |
| open | 72 | 1.29 | 11.16 | 26.50 | 328 | 1.76 | 0.25 | 0.90 | 0.27 |
| open_dimmer_off | 71 | 1.17 | 10.87 | 27.18 | 327 | 1.61 | 0.22 | 0.76 | 0.24 |
| open_ui_off | 72 | 1.23 | 11.14 | 25.60 | 306 | 1.86 | 0.25 | 0.85 | 0.26 |
| open_all_off | 72 | 0.45 | 6.90 | 24.69 | 41 | 1.46 | 0.15 | 0.62 | 0.27 |
| open_views_off | 71 | 1.24 | 11.09 | 28.57 | 308 | 1.78 | 0.25 | 0.84 | 0.27 |
| open_root_off | 72 | 1.23 | 11.06 | 23.22 | 328 | 1.70 | 0.25 | 0.82 | 0.25 |
| open_lean | 65 | 1.06 | 9.84 | 23.07 | 328 | 1.35 | 0.19 | 0.67 | 0.22 |
| open | 71 | 1.20 | 10.26 | 25.66 | 328 | 1.75 | 0.25 | 0.94 | 0.26 |
| open_big2 | 54 | 1.54 | 14.90 | 27.67 | 590 | 1.73 | 0.30 | 0.98 | 0.22 |
| closed | 72 | 0.38 | 6.51 | 23.12 | 12 | 0.35 | 0.00 | 0.03 | 0.33 |
| compat_closed | 72 | 0.67 | 0.00 | 15.49 | 25 | 0.30 | 0.00 | 0.03 | 0.28 |
| compat_closed_vr_off | 72 | 0.67 | 0.00 | 15.49 | 25 | 0.30 | 0.00 | 0.03 | 0.27 |
| compat_closed_empty | 72 | 0.18 | 0.00 | 15.20 | 0 | 0.30 | 0.00 | 0.03 | 0.21 |
| compat_open | 72 | 3.22 | 0.00 | 22.71 | 410 | 1.68 | 0.24 | 0.85 | 0.25 |
| compat_open_ui_off | 72 | 3.24 | 0.00 | 21.83 | 388 | 1.66 | 0.24 | 0.85 | 0.24 |
| compat_open_all_off | 72 | 0.78 | 0.00 | 18.90 | 55 | 1.37 | 0.14 | 0.64 | 0.25 |
| compat_open_big2 | 68 | 4.87 | 0.00 | 26.64 | 732 | 1.98 | 0.35 | 1.14 | 0.24 |
| compat_open | 72 | 3.30 | 0.00 | 22.89 | 410 | 1.69 | 0.24 | 0.86 | 0.25 |
| compat_closed | 72 | 0.78 | 0.00 | 16.03 | 26 | 0.33 | 0.00 | 0.03 | 0.32 |

