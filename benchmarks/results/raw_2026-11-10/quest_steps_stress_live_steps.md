
benchmarks/results/raw_2026-11-10/quest_steps_stress_live.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 7 | 72 | 0 | 10.68 | 3.0 | 0.87 | 525 | 2/4 | 3 | 10 |
| open | 8 | 54 | 20 | 16.48 | 19.6 | 0.98 | 525 | 5/4 | 3 | 327 |
| open_graph100 | 8 | 31 | 44 | 29.66 | 35.6 | 0.99 | 525 | 5/4 | 3 | 1113 |
| open_graph250 | 8 | 17 | 71 | 52.75 | 47.2 | 0.98 | 525 | 5/4 | 3 | 2685 |
| open_graph500 | 23 | 4 | 72 | 277.75 | -177.8 | 1.00 | 525 | 2/4 | 3 | 5305 |
| open | 8 | 59 | 16 | 15.26 | 17.3 | 0.99 | 525 | 5/4 | 3 | 327 |
| closed | 7 | 72 | 0 | 10.80 | 4.3 | 0.87 | 525 | 2/4 | 3 | 11 |
| closed_scene1k | 7 | 32 | 45 | 28.37 | 29.7 | 0.99 | 525 | 5/4 | 3 | 1961 |
| closed_scene5k | 7 | 11 | 72 | 81.11 | 18.9 | 1.00 | 525 | 5/4 | 3 | 8461 |
| closed_scene20k | 17 | 4 | 72 | 235.47 | -135.5 | 1.00 | 525 | 5/4 | 3 | 31015 |
| closed | 7 | 72 | 0 | 10.89 | 14.2 | 0.88 | 525 | 2/4 | 3 | 6 |
| open_scene5k | 8 | 10 | 72 | 95.69 | 4.3 | 0.99 | 525 | 5/4 | 3 | 10327 |
| open | 7 | 58 | 16 | 15.37 | 17.7 | 0.99 | 525 | 5/4 | 3 | 327 |
| closed | 7 | 72 | 0 | 10.74 | 14.3 | 0.87 | 525 | 2/4 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.34 | 5.77 | 5 | 5 | 50 | 5 | 0 |
| closed | root | 0.04 | 1.47 | 0 | 0 | 0 | 0 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | XRESession/XREViewport | 1.05 | 10.97 | 302 | 302 | 80112 | 5 | 0 |
| open | root | 0.03 | 1.29 | 0 | 0 | 0 | 0 | 0 |
| open | Badge/Viewport | 0.10 | 0.12 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph100 | XRESession/XREViewport | 2.93 | 25.40 | 1088 | 1088 | 305318 | 5 | 0 |
| open_graph100 | root | 0.04 | 1.20 | 0 | 0 | 0 | 0 | 0 |
| open_graph100 | FunctionsWindow/Viewport | 0.06 | 0.20 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | Badge/Viewport | 0.10 | 0.09 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph100 | (graph of 100 block(s), 112 wire(s)) | | | | | | | |
| open_graph250 | XRESession/XREViewport | 6.63 | 48.96 | 2660 | 2660 | 755718 | 5 | 0 |
| open_graph250 | root | 0.04 | 1.24 | 0 | 0 | 0 | 0 | 0 |
| open_graph250 | FunctionsWindow/Viewport | 0.05 | 0.17 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | Badge/Viewport | 0.10 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph250 | (graph of 250 block(s), 280 wire(s)) | | | | | | | |
| open_graph500 | XRESession/XREViewport | 17.01 | 294.61 | 5280 | 5280 | 1502218 | 5 | 0 |
| open_graph500 | root | 0.06 | 1.34 | 0 | 0 | 0 | 0 | 0 |
| open_graph500 | FunctionsWindow/Viewport | 0.07 | 0.12 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph500 | (graph of 500 block(s), 560 wire(s)) | | | | | | | |
| open | XRESession/XREViewport | 1.09 | 9.66 | 302 | 302 | 80092 | 5 | 0 |
| open | root | 0.03 | 1.43 | 0 | 0 | 0 | 0 | 0 |
| open | FunctionsWindow/Viewport | 0.06 | 0.14 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.10 | 0.09 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | XRESession/XREViewport | 0.39 | 6.02 | 6 | 6 | 62 | 5 | 0 |
| closed | root | 0.04 | 1.44 | 0 | 0 | 0 | 0 | 0 |
| closed | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene1k | XRESession/XREViewport | 2.83 | 24.79 | 956 | 956 | 11462 | 1005 | 0 |
| closed_scene1k | root | 0.04 | 1.32 | 0 | 0 | 0 | 0 | 0 |
| closed_scene1k | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed_scene1k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene1k | (scene of 1000 object(s) added) | | | | | | | |
| closed_scene5k | XRESession/XREViewport | 12.03 | 81.87 | 3456 | 3456 | 41462 | 5005 | 0 |
| closed_scene5k | root | 0.04 | 1.22 | 0 | 0 | 0 | 0 | 0 |
| closed_scene5k | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed_scene5k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene5k | (scene of 5000 object(s) added) | | | | | | | |
| closed_scene20k | XRESession/XREViewport | 45.17 | 252.68 | 11010 | 11010 | 132110 | 20005 | 0 |
| closed_scene20k | root | 0.04 | 1.42 | 0 | 0 | 0 | 0 | 0 |
| closed_scene20k | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed_scene20k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene20k | (scene of 20000 object(s) added) | | | | | | | |
| closed | XRESession/XREViewport | 0.34 | 5.90 | 6 | 6 | 62 | 0 | 0 |
| closed | root | 0.04 | 1.47 | 0 | 0 | 0 | 0 | 0 |
| closed | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_scene5k | XRESession/XREViewport | 11.01 | 97.75 | 5302 | 5302 | 140120 | 5005 | 0 |
| open_scene5k | root | 0.04 | 1.37 | 0 | 0 | 0 | 0 | 0 |
| open_scene5k | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_scene5k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_scene5k | (scene of 5000 object(s) added) | | | | | | | |
| open | XRESession/XREViewport | 1.07 | 9.68 | 302 | 302 | 80100 | 5 | 0 |
| open | root | 0.03 | 1.47 | 0 | 0 | 0 | 0 | 0 |
| open | FunctionsWindow/Viewport | 0.06 | 0.16 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.10 | 0.10 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | XRESession/XREViewport | 0.37 | 6.03 | 6 | 6 | 62 | 5 | 0 |
| closed | root | 0.04 | 1.42 | 0 | 0 | 0 | 0 | 0 |
| closed | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |

Lab lines, the step's last report (fps, VR view render CPU/GPU, TIME_PROCESS, draw calls; graph scripts):

benchmarks/results/raw_2026-11-10/quest_steps_stress_live.log
| Step | fps | view CPU | view GPU | process | calls | graph scripts | facing | rays | manip |
|---|---|---|---|---|---|---|---|---|---|
| closed | 72 | 0.34 | 5.77 | 22.58 | 10 | 0.35 | 0.00 | 0.04 | 0.29 |
| open | 54 | 1.05 | 10.97 | 28.27 | 327 | 1.47 | 0.21 | 0.79 | 0.26 |
| open_graph100 | 30 | 2.93 | 25.40 | 40.75 | 1113 | 2.68 | 0.56 | 1.77 | 0.28 |
| open_graph250 | 17 | 6.63 | 48.96 | 68.73 | 2685 | 4.96 | 1.12 | 3.70 | 0.25 |
| open_graph500 | 3 | 17.01 | 294.61 | 305.32 | 5305 | 13.72 | 3.23 | 9.93 | 0.32 |
| open | 58 | 1.09 | 9.66 | 27.15 | 327 | 1.45 | 0.21 | 0.81 | 0.26 |
| closed | 72 | 0.39 | 6.02 | 20.81 | 11 | 0.40 | 0.00 | 0.03 | 0.38 |
| closed_scene1k | 30 | 2.83 | 24.79 | 41.61 | 1961 | 0.32 | 0.00 | 0.03 | 0.31 |
| closed_scene5k | 11 | 12.03 | 81.87 | 88.55 | 8461 | 0.30 | 0.00 | 0.03 | 0.30 |
| closed_scene20k | 4 | 45.17 | 252.68 | 263.68 | 31015 | 0.33 | 0.00 | 0.03 | 0.32 |
| closed | 72 | 0.34 | 5.90 | 18.78 | 6 | 0.37 | 0.00 | 0.03 | 0.35 |
| open_scene5k | 9 | 11.01 | 97.75 | 110.03 | 10327 | 1.37 | 0.19 | 0.76 | 0.27 |
| open | 59 | 1.07 | 9.68 | 27.25 | 327 | 1.40 | 0.20 | 0.77 | 0.26 |
| closed | 72 | 0.37 | 6.03 | 23.88 | 11 | 0.39 | 0.00 | 0.03 | 0.36 |

