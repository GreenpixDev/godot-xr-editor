
benchmarks/results/raw_2026-11-10/quest_x2_store_merged.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 7 | 72 | 0 | 5.65 | 5.4 | 0.52 | 525 | 2/2 | 3 | 10 |
| open | 8 | 72 | 0 | 9.75 | 12.1 | 0.79 | 441 | 2/4 | 3 | 293 |
| open_big2 | 8 | 66 | 8 | 13.41 | 15.7 | 0.96 | 525 | 2/4 | 3 | 521 |
| open | 7 | 72 | 0 | 9.63 | 12.5 | 0.79 | 525 | 2/4 | 3 | 293 |
| open_big2 | 7 | 65 | 8 | 13.38 | 16.9 | 0.95 | 525 | 2/4 | 3 | 521 |
| open_big2 | 8 | 65 | 8 | 13.50 | 16.6 | 0.97 | 525 | 3/4 | 3 | 521 |
| closed | 7 | 72 | 0 | 5.70 | 5.6 | 0.53 | 441 | 2/2 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.34 | 6.41 | 5 | 5 | 50 | 5 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 1.27 | 10.94 | 268 | 268 | 80112 | 5 | 0 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.78 | 14.75 | 496 | 496 | 155158 | 5 | 0 |
| open_big2 | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | FunctionsWindow/Viewport | 0.06 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 1.31 | 11.19 | 268 | 268 | 80112 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.99 | 14.79 | 496 | 496 | 155182 | 5 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.81 | 14.88 | 496 | 496 | 155158 | 5 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.06 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.36 | 6.45 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.09 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |

Plugin scripts, the step's last lab report (ms per frame):
| Step | n | graph scripts | facing | ray routing | manipulator | process (lab) |
|---|---|---|---|---|---|---|
| 01 closed | 1 | 0.33 | 0.00 | 0.03 | 0.29 | 17.09 |
| 02 open | 1 | 1.63 | 0.23 | 0.83 | 0.29 | 23.60 |
| 03 open_big2 | 1 | 1.99 | 0.34 | 1.13 | 0.28 | 28.47 |
| 04 open | 1 | 1.81 | 0.25 | 0.88 | 0.32 | 23.78 |
| 05 open_big2 | 1 | 2.24 | 0.38 | 1.28 | 0.31 | 27.16 |
| 06 open_big2 | 1 | 1.98 | 0.34 | 1.14 | 0.28 | 26.83 |
| 07 closed | 1 | 0.37 | 0.00 | 0.03 | 0.35 | 17.02 |
