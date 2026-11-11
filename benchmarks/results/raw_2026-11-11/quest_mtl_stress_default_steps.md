
benchmarks/results/raw_2026-11-11/quest_mtl_stress_default.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 7 | 72 | 0 | 5.65 | 5.5 | 0.53 | 525 | 2/2 | 3 | 10 |
| open | 8 | 72 | 0 | 9.92 | 12.2 | 0.81 | 441 | 2/4 | 3 | 327 |
| open_big2 | 7 | 66 | 8 | 13.68 | 16.9 | 0.97 | 525 | 3/4 | 3 | 589 |
| open_big4 | 8 | 36 | 36 | 24.89 | 29.9 | 0.99 | 525 | 5/4 | 3 | 1113 |
| open_graph100 | 8 | 36 | 36 | 24.88 | 30.1 | 0.99 | 525 | 5/4 | 3 | 1113 |
| open_graph250 | 8 | 18 | 54 | 49.78 | 50.2 | 0.99 | 525 | 5/4 | 3 | 2685 |
| open_graph500 | 22 | 4 | 72 | 279.48 | -179.5 | 1.00 | 525 | 2/4 | 3 | 5305 |
| open | 8 | 72 | 0 | 9.64 | 12.5 | 0.80 | 508 | 2/3 | 3 | 327 |
| closed | 7 | 72 | 0 | 5.70 | 5.6 | 0.53 | 441 | 2/2 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.33 | 6.39 | 5 | 5 | 50 | 5 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 1.24 | 11.06 | 302 | 302 | 80112 | 5 | 0 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.85 | 15.12 | 564 | 564 | 155158 | 5 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.07 | 0.15 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big4 | XRESession/XREViewport | 2.77 | 27.58 | 1088 | 1088 | 305266 | 5 | 0 |
| open_big4 | FunctionsWindow/Viewport | 0.05 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_big4 | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big4 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big4 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | XRESession/XREViewport | 2.71 | 27.59 | 1088 | 1088 | 305354 | 5 | 0 |
| open_graph100 | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | FunctionsWindow/Viewport | 0.05 | 0.12 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph100 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | (graph of 100 block(s), 112 wire(s)) | | | | | | | |
| open_graph250 | XRESession/XREViewport | 6.50 | 55.29 | 2660 | 2660 | 755718 | 5 | 0 |
| open_graph250 | FunctionsWindow/Viewport | 0.05 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph250 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph250 | (graph of 250 block(s), 280 wire(s)) | | | | | | | |
| open_graph500 | XRESession/XREViewport | 16.88 | 306.50 | 5280 | 5280 | 1502218 | 5 | 0 |
| open_graph500 | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | FunctionsWindow/Viewport | 0.07 | 0.12 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph500 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph500 | (graph of 500 block(s), 560 wire(s)) | | | | | | | |
| open | XRESession/XREViewport | 1.36 | 10.86 | 302 | 302 | 80100 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.35 | 6.44 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
