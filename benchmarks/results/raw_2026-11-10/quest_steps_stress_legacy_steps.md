
benchmarks/results/raw_2026-11-10/quest_steps_stress_legacy.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 7 | 72 | 0 | 5.69 | 5.4 | 0.53 | 525 | 2/2 | 3 | 10 |
| open | 8 | 72 | 0 | 10.02 | 13.2 | 0.81 | 441 | 2/4 | 3 | 327 |
| open_graph100 | 8 | 36 | 36 | 24.88 | 29.9 | 0.98 | 525 | 5/4 | 3 | 1113 |
| open_graph250 | 9 | 18 | 72 | 49.73 | 50.3 | 0.98 | 525 | 5/4 | 3 | 2685 |
| open_graph500 | 22 | 4 | 72 | 274.42 | -174.4 | 1.00 | 525 | 5/4 | 3 | 5305 |
| open | 8 | 72 | 0 | 9.99 | 14.0 | 0.81 | 525 | 2/4 | 3 | 327 |
| closed | 7 | 72 | 0 | 5.73 | 5.5 | 0.53 | 441 | 2/2 | 3 | 11 |
| closed_scene1k | 7 | 39 | 38 | 22.61 | 24.7 | 0.99 | 525 | 5/4 | 3 | 1961 |
| closed_scene5k | 7 | 13 | 72 | 74.85 | 25.2 | 1.00 | 525 | 5/4 | 3 | 8461 |
| closed_scene20k | 17 | 4 | 72 | 224.70 | -124.7 | 1.00 | 525 | 3/4 | 3 | 31013 |
| closed | 7 | 72 | 0 | 5.73 | 5.4 | 0.53 | 441 | 2/2 | 3 | 11 |
| open_scene5k | 7 | 11 | 72 | 87.45 | 12.5 | 1.00 | 525 | 5/4 | 3 | 10147 |
| open | 7 | 72 | 0 | 10.08 | 12.8 | 0.82 | 525 | 3/4 | 3 | 327 |
| closed | 7 | 72 | 0 | 5.72 | 5.5 | 0.53 | 441 | 2/2 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.33 | 6.41 | 5 | 5 | 50 | 5 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 1.34 | 11.09 | 302 | 302 | 80108 | 5 | 0 |
| open | Badge/Viewport | 0.13 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | XRESession/XREViewport | 3.02 | 27.61 | 1088 | 1088 | 305318 | 5 | 0 |
| open_graph100 | FunctionsWindow/Viewport | 0.06 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph100 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | (graph of 100 block(s), 112 wire(s)) | | | | | | | |
| open_graph250 | XRESession/XREViewport | 7.34 | 55.28 | 2660 | 2660 | 755718 | 5 | 0 |
| open_graph250 | FunctionsWindow/Viewport | 0.05 | 0.15 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | Badge/Viewport | 0.10 | 0.09 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph250 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph250 | (graph of 250 block(s), 280 wire(s)) | | | | | | | |
| open_graph500 | XRESession/XREViewport | 18.95 | 301.04 | 5280 | 5280 | 1502218 | 5 | 0 |
| open_graph500 | FunctionsWindow/Viewport | 0.07 | 0.17 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph500 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph500 | (graph of 500 block(s), 560 wire(s)) | | | | | | | |
| open | XRESession/XREViewport | 1.44 | 11.04 | 302 | 302 | 80100 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.14 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.13 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.35 | 6.46 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.11 | 0.06 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed_scene1k | XRESession/XREViewport | 2.76 | 25.80 | 956 | 956 | 11462 | 1005 | 0 |
| closed_scene1k | Badge/Viewport | 0.11 | 0.06 | 0 | 0 | 0 | 0 | 10 |
| closed_scene1k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene1k | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed_scene1k | (scene of 1000 object(s) added) | | | | | | | |
| closed_scene5k | XRESession/XREViewport | 11.47 | 83.27 | 3456 | 3456 | 41462 | 5005 | 0 |
| closed_scene5k | Badge/Viewport | 0.11 | 0.06 | 0 | 0 | 0 | 0 | 10 |
| closed_scene5k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene5k | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed_scene5k | (scene of 5000 object(s) added) | | | | | | | |
| closed_scene20k | XRESession/XREViewport | 48.93 | 251.30 | 11008 | 11008 | 132086 | 20005 | 0 |
| closed_scene20k | Badge/Viewport | 0.11 | 0.06 | 0 | 0 | 0 | 0 | 10 |
| closed_scene20k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene20k | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed_scene20k | (scene of 20000 object(s) added) | | | | | | | |
| closed | XRESession/XREViewport | 0.35 | 6.46 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.11 | 0.06 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_scene5k | XRESession/XREViewport | 11.07 | 97.17 | 5122 | 5122 | 137924 | 5005 | 0 |
| open_scene5k | Badge/Viewport | 0.10 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open_scene5k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_scene5k | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_scene5k | (scene of 5000 object(s) added) | | | | | | | |
| open | XRESession/XREViewport | 1.39 | 11.20 | 302 | 302 | 80104 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.08 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.13 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.35 | 6.45 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.16 | 0.06 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |

Lab lines, the step's last report (fps, VR view render CPU/GPU, TIME_PROCESS, draw calls; graph scripts):

benchmarks/results/raw_2026-11-10/quest_steps_stress_legacy.log
| Step | fps | view CPU | view GPU | process | calls | graph scripts | facing | rays | manip |
|---|---|---|---|---|---|---|---|---|---|
| closed | 72 | 0.33 | 6.41 | 16.57 | 10 | 0.32 | 0.00 | 0.03 | 0.29 |
| open | 71 | 1.34 | 11.09 | 25.71 | 327 | 2.72 | 1.18 | 0.85 | 0.34 |
| open_graph100 | 35 | 3.02 | 27.61 | 35.82 | 1113 | 5.15 | 3.28 | 1.53 | 0.26 |
| open_graph250 | 17 | 7.34 | 55.28 | 65.10 | 2685 | 11.69 | 7.88 | 3.54 | 0.29 |
| open_graph500 | 3 | 18.95 | 301.04 | 302.41 | 5305 | 26.45 | 15.80 | 9.65 | 0.36 |
| open | 70 | 1.44 | 11.04 | 28.87 | 327 | 2.81 | 1.22 | 0.91 | 0.35 |
| closed | 72 | 0.35 | 6.46 | 16.57 | 11 | 0.35 | 0.00 | 0.03 | 0.35 |
| closed_scene1k | 40 | 2.76 | 25.80 | 35.60 | 1961 | 0.30 | 0.00 | 0.03 | 0.30 |
| closed_scene5k | 12 | 11.47 | 83.27 | 86.92 | 8461 | 0.29 | 0.00 | 0.02 | 0.30 |
| closed_scene20k | 3 | 48.93 | 251.30 | 253.37 | 31013 | 0.32 | 0.00 | 0.03 | 0.33 |
| closed | 72 | 0.35 | 6.46 | 16.39 | 11 | 0.35 | 0.00 | 0.03 | 0.35 |
| open_scene5k | 10 | 11.07 | 97.17 | 98.07 | 10147 | 1.99 | 0.86 | 0.65 | 0.27 |
| open | 72 | 1.39 | 11.20 | 25.50 | 327 | 2.66 | 1.17 | 0.85 | 0.33 |
| closed | 72 | 0.35 | 6.45 | 16.52 | 11 | 0.35 | 0.00 | 0.03 | 0.35 |

