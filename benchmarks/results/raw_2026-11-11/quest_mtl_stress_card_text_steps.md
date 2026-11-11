
benchmarks/results/raw_2026-11-11/quest_mtl_stress_card_text.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 7 | 72 | 0 | 5.65 | 5.4 | 0.52 | 525 | 2/2 | 3 | 10 |
| open | 9 | 72 | 0 | 9.19 | 11.2 | 0.75 | 441 | 2/3 | 3 | 218 |
| open_big2 | 8 | 72 | 0 | 10.84 | 14.3 | 0.88 | 490 | 2/4 | 3 | 371 |
| open_big4 | 8 | 54 | 18 | 16.65 | 19.8 | 0.98 | 525 | 5/4 | 3 | 677 |
| open_graph100 | 8 | 54 | 18 | 16.63 | 20.2 | 0.98 | 525 | 5/4 | 3 | 677 |
| open_graph250 | 10 | 29 | 44 | 31.15 | 37.1 | 0.97 | 525 | 5/4 | 3 | 1595 |
| open_graph500 | 13 | 6 | 72 | 177.32 | -77.3 | 1.00 | 525 | 5/4 | 3 | 3125 |
| open | 8 | 72 | 0 | 9.12 | 11.6 | 0.74 | 525 | 2/2 | 3 | 218 |
| closed | 7 | 72 | 0 | 5.69 | 5.5 | 0.53 | 441 | 2/2 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.32 | 6.39 | 5 | 5 | 50 | 5 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 1.11 | 10.70 | 193 | 193 | 80112 | 5 | 0 |
| open | Badge/Viewport | 0.14 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.42 | 12.01 | 346 | 346 | 155158 | 5 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big4 | XRESession/XREViewport | 1.94 | 18.25 | 652 | 652 | 305262 | 5 | 0 |
| open_big4 | FunctionsWindow/Viewport | 0.05 | 0.19 | 0 | 0 | 0 | 0 | 10 |
| open_big4 | Badge/Viewport | 0.10 | 0.09 | 0 | 0 | 0 | 0 | 10 |
| open_big4 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big4 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | XRESession/XREViewport | 1.84 | 18.26 | 652 | 652 | 305354 | 5 | 0 |
| open_graph100 | FunctionsWindow/Viewport | 0.05 | 0.19 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | Badge/Viewport | 0.10 | 0.09 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph100 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph100 | (graph of 100 block(s), 112 wire(s)) | | | | | | | |
| open_graph250 | XRESession/XREViewport | 3.90 | 34.55 | 1570 | 1570 | 755718 | 5 | 0 |
| open_graph250 | FunctionsWindow/Viewport | 0.05 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph250 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph250 | (graph of 250 block(s), 280 wire(s)) | | | | | | | |
| open_graph500 | XRESession/XREViewport | 8.12 | 194.66 | 3100 | 3100 | 1502218 | 5 | 0 |
| open_graph500 | FunctionsWindow/Viewport | 0.05 | 0.19 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | Badge/Viewport | 0.10 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph500 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_graph500 | (graph of 500 block(s), 560 wire(s)) | | | | | | | |
| open | XRESession/XREViewport | 1.03 | 10.05 | 193 | 193 | 80100 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.15 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.13 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.34 | 6.43 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.16 | 0.08 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
