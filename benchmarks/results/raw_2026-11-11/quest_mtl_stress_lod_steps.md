
benchmarks/results/raw_2026-11-11/quest_mtl_stress_lod.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 7 | 72 | 0 | 5.66 | 4.9 | 0.53 | 525 | 2/2 | 3 | 10 |
| open | 8 | 72 | 0 | 8.85 | 10.6 | 0.71 | 441 | 2/2 | 3 | 176 |
| open_big2 | 8 | 72 | 0 | 9.00 | 11.5 | 0.76 | 441 | 2/2 | 3 | 199 |
| open_big4 | 8 | 72 | 0 | 9.88 | 14.4 | 0.81 | 441 | 2/4 | 3 | 333 |
| open_graph100 | 8 | 72 | 0 | 9.88 | 14.1 | 0.81 | 525 | 2/4 | 3 | 333 |
| open_graph250 | 9 | 72 | 2 | 7.26 | 12.3 | 0.62 | 525 | 5/4 | 3 | 146 |
| open_graph500 | 9 | 66 | 6 | 6.21 | 16.2 | 0.52 | 441 | 5/4 | 3 | 66 |
| open | 8 | 72 | 0 | 6.49 | 8.7 | 0.57 | 525 | 2/2 | 3 | 66 |
| closed | 7 | 72 | 0 | 5.71 | 5.6 | 0.53 | 441 | 2/2 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.30 | 6.40 | 5 | 5 | 50 | 5 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 0.85 | 9.79 | 151 | 151 | 37268 | 5 | 0 |
| open | Badge/Viewport | 0.13 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.02 | 10.01 | 174 | 174 | 50410 | 5 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.07 | 0.15 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.13 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big4 | XRESession/XREViewport | 1.60 | 11.05 | 308 | 308 | 95690 | 5 | 0 |
| open_big4 | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big4 | FunctionsWindow/Viewport | 0.07 | 0.12 | 0 | 0 | 0 | 0 | 10 |
| open_big4 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big4 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | XRESession/XREViewport | 1.64 | 10.93 | 308 | 308 | 95690 | 5 | 0 |
| open_graph100 | Badge/Viewport | 0.13 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph100 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | (graph of 100 block(s), 112 wire(s)) | | | | | | | |
| open_graph250 | XRESession/XREViewport | 0.83 | 8.32 | 121 | 121 | 43662 | 5 | 0 |
| open_graph250 | FunctionsWindow/Viewport | 0.06 | 0.16 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | Badge/Viewport | 0.11 | 0.09 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph250 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph250 | (graph of 250 block(s), 280 wire(s)) | | | | | | | |
| open_graph500 | XRESession/XREViewport | 0.53 | 6.75 | 41 | 41 | 28650 | 5 | 0 |
| open_graph500 | FunctionsWindow/Viewport | 0.05 | 0.14 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | Badge/Viewport | 0.10 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph500 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph500 | (graph of 500 block(s), 560 wire(s)) | | | | | | | |
| open | XRESession/XREViewport | 0.53 | 6.87 | 41 | 41 | 6306 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.15 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.13 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.35 | 6.44 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.11 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
