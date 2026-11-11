
benchmarks/results/raw_2026-11-11/quest_mtl_stress_all.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 6 | 72 | 0 | 5.63 | 5.3 | 0.52 | 525 | 2/2 | 3 | 10 |
| open | 9 | 72 | 0 | 8.38 | 10.0 | 0.71 | 441 | 2/2 | 3 | 148 |
| open_big2 | 8 | 72 | 0 | 8.47 | 10.4 | 0.70 | 466 | 2/2 | 3 | 189 |
| open_big4 | 8 | 72 | 0 | 9.53 | 12.6 | 0.78 | 525 | 2/4 | 3 | 313 |
| open_graph100 | 8 | 72 | 0 | 9.55 | 12.3 | 0.78 | 525 | 2/4 | 3 | 313 |
| open_graph250 | 9 | 72 | 0 | 7.52 | 11.2 | 0.63 | 441 | 2/3 | 3 | 140 |
| open_graph500 | 9 | 71 | 3 | 6.18 | 12.3 | 0.55 | 525 | 5/4 | 3 | 66 |
| open | 9 | 72 | 0 | 6.47 | 8.3 | 0.57 | 490 | 2/2 | 3 | 66 |
| closed | 7 | 72 | 0 | 5.71 | 5.7 | 0.53 | 441 | 2/2 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.34 | 6.37 | 5 | 5 | 50 | 5 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 0.82 | 9.04 | 123 | 123 | 37268 | 5 | 0 |
| open | Badge/Viewport | 0.12 | 0.15 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 0.97 | 9.34 | 164 | 164 | 50410 | 5 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.07 | 0.15 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.13 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big4 | XRESession/XREViewport | 1.63 | 10.70 | 288 | 288 | 95690 | 5 | 0 |
| open_big4 | Badge/Viewport | 0.14 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big4 | FunctionsWindow/Viewport | 0.08 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_big4 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big4 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | XRESession/XREViewport | 1.65 | 10.70 | 288 | 288 | 95690 | 5 | 0 |
| open_graph100 | Badge/Viewport | 0.14 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | FunctionsWindow/Viewport | 0.08 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph100 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | (graph of 100 block(s), 112 wire(s)) | | | | | | | |
| open_graph250 | XRESession/XREViewport | 0.86 | 8.33 | 115 | 115 | 43662 | 5 | 0 |
| open_graph250 | FunctionsWindow/Viewport | 0.07 | 0.16 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | Badge/Viewport | 0.12 | 0.09 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph250 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph250 | (graph of 250 block(s), 280 wire(s)) | | | | | | | |
| open_graph500 | XRESession/XREViewport | 0.62 | 6.65 | 41 | 41 | 28650 | 5 | 0 |
| open_graph500 | FunctionsWindow/Viewport | 0.06 | 0.15 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | Badge/Viewport | 0.11 | 0.09 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph500 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph500 | (graph of 500 block(s), 560 wire(s)) | | | | | | | |
| open | XRESession/XREViewport | 0.54 | 6.85 | 41 | 41 | 6306 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.15 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.13 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.36 | 6.44 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.13 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
