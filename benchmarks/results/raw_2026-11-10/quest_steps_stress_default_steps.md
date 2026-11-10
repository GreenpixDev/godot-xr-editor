
benchmarks/results/raw_2026-11-10/quest_steps_stress_default.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 7 | 72 | 0 | 5.69 | 4.9 | 0.53 | 525 | 2/2 | 3 | 10 |
| open | 8 | 72 | 0 | 9.95 | 12.6 | 0.81 | 441 | 2/4 | 3 | 327 |
| open_graph100 | 7 | 36 | 36 | 24.86 | 30.0 | 0.99 | 525 | 5/4 | 3 | 1113 |
| open_graph250 | 9 | 18 | 54 | 49.81 | 50.2 | 0.99 | 525 | 5/4 | 3 | 2685 |
| open_graph500 | 22 | 4 | 72 | 267.10 | -167.1 | 1.00 | 525 | 5/4 | 3 | 5305 |
| open | 8 | 72 | 0 | 9.64 | 12.2 | 0.77 | 525 | 2/3 | 3 | 327 |
| closed | 7 | 72 | 0 | 5.72 | 5.5 | 0.53 | 490 | 2/2 | 3 | 11 |
| closed_scene1k | 7 | 39 | 38 | 22.08 | 32.6 | 0.99 | 441 | 5/4 | 3 | 1961 |
| closed_scene5k | 7 | 12 | 72 | 74.47 | 25.5 | 1.00 | 525 | 5/4 | 3 | 8461 |
| closed_scene20k | 16 | 4 | 72 | 224.74 | -124.7 | 1.00 | 525 | 5/4 | 3 | 31013 |
| closed | 7 | 72 | 0 | 5.72 | 5.5 | 0.53 | 525 | 2/2 | 3 | 11 |
| open_scene5k | 8 | 11 | 72 | 87.93 | 12.1 | 0.99 | 441 | 5/4 | 3 | 10327 |
| open | 7 | 72 | 0 | 9.49 | 12.5 | 0.77 | 525 | 2/3 | 3 | 327 |
| closed | 7 | 72 | 0 | 5.71 | 5.5 | 0.53 | 490 | 2/2 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.31 | 6.41 | 5 | 5 | 50 | 5 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 1.27 | 11.06 | 302 | 302 | 80112 | 5 | 0 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | XRESession/XREViewport | 2.65 | 27.60 | 1088 | 1088 | 305302 | 5 | 0 |
| open_graph100 | FunctionsWindow/Viewport | 0.05 | 0.12 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | Badge/Viewport | 0.10 | 0.06 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph100 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | (graph of 100 block(s), 112 wire(s)) | | | | | | | |
| open_graph250 | XRESession/XREViewport | 6.51 | 55.31 | 2660 | 2660 | 755718 | 5 | 0 |
| open_graph250 | FunctionsWindow/Viewport | 0.05 | 0.12 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | Badge/Viewport | 0.10 | 0.06 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph250 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph250 | (graph of 250 block(s), 280 wire(s)) | | | | | | | |
| open_graph500 | XRESession/XREViewport | 15.62 | 294.40 | 5280 | 5280 | 1502218 | 5 | 0 |
| open_graph500 | FunctionsWindow/Viewport | 0.06 | 0.15 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph500 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph500 | (graph of 500 block(s), 560 wire(s)) | | | | | | | |
| open | XRESession/XREViewport | 1.39 | 10.88 | 302 | 302 | 80092 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.35 | 6.45 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed_scene1k | XRESession/XREViewport | 2.74 | 25.83 | 956 | 956 | 11462 | 1005 | 0 |
| closed_scene1k | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed_scene1k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene1k | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed_scene1k | (scene of 1000 object(s) added) | | | | | | | |
| closed_scene5k | XRESession/XREViewport | 11.53 | 83.50 | 3456 | 3456 | 41462 | 5005 | 0 |
| closed_scene5k | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed_scene5k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene5k | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed_scene5k | (scene of 5000 object(s) added) | | | | | | | |
| closed_scene20k | XRESession/XREViewport | 46.81 | 251.60 | 11008 | 11008 | 132086 | 20005 | 0 |
| closed_scene20k | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed_scene20k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene20k | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed_scene20k | (scene of 20000 object(s) added) | | | | | | | |
| closed | XRESession/XREViewport | 0.35 | 6.44 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_scene5k | XRESession/XREViewport | 10.66 | 97.42 | 5302 | 5302 | 140108 | 5005 | 0 |
| open_scene5k | Badge/Viewport | 0.10 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open_scene5k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_scene5k | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_scene5k | (scene of 5000 object(s) added) | | | | | | | |
| open | XRESession/XREViewport | 1.37 | 10.81 | 302 | 302 | 80096 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.08 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.35 | 6.44 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |

Lab lines, the step's last report (fps, VR view render CPU/GPU, TIME_PROCESS, draw calls; graph scripts):

benchmarks/results/raw_2026-11-10/quest_steps_stress_default.log
| Step | fps | view CPU | view GPU | process | calls | graph scripts | facing | rays | manip |
|---|---|---|---|---|---|---|---|---|---|
| closed | 72 | 0.31 | 6.41 | 13.70 | 10 | 0.29 | 0.00 | 0.03 | 0.27 |
| open | 72 | 1.27 | 11.06 | 23.87 | 327 | 1.82 | 0.26 | 0.88 | 0.31 |
| open_graph100 | 36 | 2.65 | 27.60 | 34.38 | 1113 | 2.42 | 0.50 | 1.70 | 0.25 |
| open_graph250 | 18 | 6.51 | 55.31 | 61.35 | 2685 | 4.78 | 1.14 | 3.27 | 0.24 |
| open_graph500 | 3 | 15.62 | 294.40 | 295.98 | 5305 | 12.27 | 2.83 | 8.62 | 0.30 |
| open | 72 | 1.39 | 10.88 | 24.28 | 327 | 1.83 | 0.26 | 0.90 | 0.31 |
| closed | 71 | 0.35 | 6.45 | 16.36 | 11 | 0.35 | 0.00 | 0.03 | 0.35 |
| closed_scene1k | 39 | 2.74 | 25.83 | 35.84 | 1961 | 0.29 | 0.00 | 0.03 | 0.30 |
| closed_scene5k | 12 | 11.53 | 83.50 | 85.35 | 8461 | 0.29 | 0.00 | 0.03 | 0.29 |
| closed_scene20k | 4 | 46.81 | 251.60 | 252.60 | 31013 | 0.31 | 0.00 | 0.03 | 0.31 |
| closed | 72 | 0.35 | 6.44 | 16.52 | 11 | 0.35 | 0.00 | 0.03 | 0.35 |
| open_scene5k | 10 | 10.66 | 97.42 | 100.32 | 10327 | 1.37 | 0.19 | 0.70 | 0.26 |
| open | 72 | 1.37 | 10.81 | 23.39 | 327 | 1.78 | 0.26 | 0.88 | 0.32 |
| closed | 72 | 0.35 | 6.44 | 16.60 | 11 | 0.35 | 0.00 | 0.03 | 0.35 |

