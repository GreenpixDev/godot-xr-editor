
benchmarks/results/raw_2026-11-11/quest_mtl_stress_card.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 7 | 72 | 0 | 5.64 | 5.3 | 0.51 | 525 | 2/2 | 3 | 10 |
| open | 9 | 72 | 0 | 9.39 | 12.3 | 0.77 | 441 | 2/4 | 3 | 255 |
| open_big2 | 7 | 69 | 4 | 12.41 | 14.9 | 0.96 | 525 | 3/4 | 3 | 445 |
| open_big4 | 8 | 44 | 29 | 20.75 | 24.5 | 0.98 | 525 | 5/4 | 3 | 825 |
| open_graph100 | 8 | 44 | 29 | 20.80 | 24.5 | 0.98 | 525 | 5/4 | 3 | 825 |
| open_graph250 | 9 | 24 | 50 | 37.48 | 44.9 | 0.98 | 525 | 5/4 | 3 | 1965 |
| open_graph500 | 18 | 4 | 72 | 225.55 | -125.6 | 1.00 | 525 | 5/4 | 3 | 3865 |
| open | 8 | 72 | 0 | 9.48 | 12.8 | 0.78 | 525 | 2/3 | 3 | 255 |
| closed | 7 | 72 | 0 | 5.69 | 5.5 | 0.53 | 441 | 2/2 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.32 | 6.37 | 5 | 5 | 50 | 5 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 1.36 | 10.55 | 230 | 230 | 80112 | 5 | 0 |
| open | Badge/Viewport | 0.13 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.77 | 13.60 | 420 | 420 | 155158 | 5 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.06 | 0.17 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.11 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big4 | XRESession/XREViewport | 2.56 | 22.92 | 800 | 800 | 305262 | 5 | 0 |
| open_big4 | FunctionsWindow/Viewport | 0.05 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_big4 | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big4 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big4 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | XRESession/XREViewport | 2.57 | 22.97 | 800 | 800 | 305354 | 5 | 0 |
| open_graph100 | FunctionsWindow/Viewport | 0.05 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph100 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | (graph of 100 block(s), 112 wire(s)) | | | | | | | |
| open_graph250 | XRESession/XREViewport | 6.25 | 41.75 | 1940 | 1940 | 755718 | 5 | 0 |
| open_graph250 | Badge/Viewport | 0.10 | 0.09 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | FunctionsWindow/Viewport | 0.05 | 0.14 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph250 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph250 | (graph of 250 block(s), 280 wire(s)) | | | | | | | |
| open_graph500 | XRESession/XREViewport | 13.83 | 250.90 | 3840 | 3840 | 1502218 | 5 | 0 |
| open_graph500 | FunctionsWindow/Viewport | 0.05 | 0.18 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph500 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph500 | (graph of 500 block(s), 560 wire(s)) | | | | | | | |
| open | XRESession/XREViewport | 1.41 | 10.97 | 230 | 230 | 80104 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.14 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.12 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.34 | 6.43 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.12 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
