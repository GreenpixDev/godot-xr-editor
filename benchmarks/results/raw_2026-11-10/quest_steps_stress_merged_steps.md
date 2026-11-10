
benchmarks/results/raw_2026-11-10/quest_steps_stress_merged.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 7 | 72 | 0 | 5.67 | 5.3 | 0.52 | 525 | 2/2 | 3 | 10 |
| open | 9 | 72 | 0 | 9.79 | 12.0 | 0.79 | 441 | 2/4 | 3 | 293 |
| open_graph100 | 8 | 41 | 31 | 21.81 | 26.1 | 0.98 | 525 | 5/4 | 3 | 977 |
| open_graph250 | 9 | 21 | 52 | 43.19 | 52.9 | 0.98 | 525 | 5/4 | 3 | 2345 |
| open_graph500 | 21 | 4 | 72 | 256.69 | -156.7 | 1.00 | 525 | 5/4 | 3 | 4625 |
| open | 8 | 72 | 0 | 9.48 | 12.5 | 0.78 | 525 | 2/3 | 3 | 293 |
| closed | 7 | 72 | 0 | 5.71 | 5.4 | 0.53 | 490 | 2/2 | 3 | 11 |
| closed_scene1k | 7 | 41 | 34 | 21.54 | 24.9 | 0.99 | 441 | 5/4 | 3 | 1961 |
| closed_scene5k | 7 | 12 | 72 | 74.52 | 25.5 | 1.00 | 525 | 5/4 | 3 | 8461 |
| closed_scene20k | 17 | 4 | 72 | 223.46 | -123.5 | 1.00 | 525 | 5/4 | 3 | 31013 |
| closed | 7 | 72 | 0 | 5.73 | 5.5 | 0.53 | 525 | 2/2 | 3 | 11 |
| open_scene5k | 7 | 11 | 72 | 87.07 | 12.9 | 0.99 | 441 | 5/4 | 3 | 10293 |
| open | 7 | 72 | 0 | 9.50 | 12.4 | 0.78 | 525 | 2/3 | 3 | 293 |
| closed | 7 | 72 | 0 | 5.72 | 5.4 | 0.53 | 525 | 2/2 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.33 | 6.41 | 5 | 5 | 50 | 5 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 1.27 | 10.88 | 268 | 268 | 80112 | 5 | 0 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | XRESession/XREViewport | 2.71 | 24.27 | 952 | 952 | 305310 | 5 | 0 |
| open_graph100 | FunctionsWindow/Viewport | 0.05 | 0.14 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph100 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | (graph of 100 block(s), 112 wire(s)) | | | | | | | |
| open_graph250 | XRESession/XREViewport | 6.22 | 48.58 | 2320 | 2320 | 755718 | 5 | 0 |
| open_graph250 | FunctionsWindow/Viewport | 0.05 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph250 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph250 | (graph of 250 block(s), 280 wire(s)) | | | | | | | |
| open_graph500 | XRESession/XREViewport | 15.40 | 281.50 | 4600 | 4600 | 1502218 | 5 | 0 |
| open_graph500 | FunctionsWindow/Viewport | 0.06 | 0.18 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph500 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph500 | (graph of 500 block(s), 560 wire(s)) | | | | | | | |
| open | XRESession/XREViewport | 1.40 | 10.59 | 268 | 268 | 80096 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.14 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.12 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.35 | 6.44 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed_scene1k | XRESession/XREViewport | 2.79 | 24.94 | 956 | 956 | 11462 | 1005 | 0 |
| closed_scene1k | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed_scene1k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene1k | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed_scene1k | (scene of 1000 object(s) added) | | | | | | | |
| closed_scene5k | XRESession/XREViewport | 11.99 | 83.52 | 3456 | 3456 | 41462 | 5005 | 0 |
| closed_scene5k | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed_scene5k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene5k | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed_scene5k | (scene of 5000 object(s) added) | | | | | | | |
| closed_scene20k | XRESession/XREViewport | 45.46 | 251.21 | 11008 | 11008 | 132086 | 20005 | 0 |
| closed_scene20k | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed_scene20k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene20k | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed_scene20k | (scene of 20000 object(s) added) | | | | | | | |
| closed | XRESession/XREViewport | 0.34 | 6.45 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_scene5k | XRESession/XREViewport | 10.41 | 97.53 | 5268 | 5268 | 140120 | 5005 | 0 |
| open_scene5k | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_scene5k | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_scene5k | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_scene5k | (scene of 5000 object(s) added) | | | | | | | |
| open | XRESession/XREViewport | 1.39 | 10.63 | 268 | 268 | 80100 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.35 | 6.46 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |

Lab lines, the step's last report (fps, VR view render CPU/GPU, TIME_PROCESS, draw calls; graph scripts):

benchmarks/results/raw_2026-11-10/quest_steps_stress_merged.log
| Step | fps | view CPU | view GPU | process | calls | graph scripts | facing | rays | manip |
|---|---|---|---|---|---|---|---|---|---|
| closed | 72 | 0.33 | 6.41 | 16.86 | 10 | 0.32 | 0.00 | 0.03 | 0.29 |
| open | 72 | 1.27 | 10.88 | 23.50 | 293 | 1.71 | 0.25 | 0.86 | 0.30 |
| open_graph100 | 41 | 2.71 | 24.27 | 32.59 | 977 | 2.40 | 0.48 | 1.60 | 0.25 |
| open_graph250 | 21 | 6.22 | 48.58 | 57.17 | 2345 | 4.88 | 1.11 | 3.42 | 0.25 |
| open_graph500 | 4 | 15.40 | 281.50 | 283.36 | 4625 | 12.03 | 2.84 | 8.58 | 0.29 |
| open | 72 | 1.40 | 10.59 | 23.45 | 293 | 1.73 | 0.25 | 0.88 | 0.31 |
| closed | 71 | 0.35 | 6.44 | 16.51 | 11 | 0.35 | 0.00 | 0.03 | 0.34 |
| closed_scene1k | 41 | 2.79 | 24.94 | 35.03 | 1961 | 0.31 | 0.00 | 0.03 | 0.30 |
| closed_scene5k | 12 | 11.99 | 83.52 | 79.72 | 8461 | 0.31 | 0.00 | 0.03 | 0.30 |
| closed_scene20k | 4 | 45.46 | 251.21 | 252.02 | 31013 | 0.30 | 0.00 | 0.03 | 0.29 |
| closed | 72 | 0.34 | 6.45 | 15.78 | 11 | 0.36 | 0.00 | 0.03 | 0.35 |
| open_scene5k | 10 | 10.41 | 97.53 | 100.37 | 10293 | 1.33 | 0.19 | 0.69 | 0.26 |
| open | 72 | 1.39 | 10.63 | 23.45 | 293 | 1.74 | 0.25 | 0.87 | 0.31 |
| closed | 72 | 0.35 | 6.46 | 16.30 | 11 | 0.36 | 0.00 | 0.03 | 0.34 |

