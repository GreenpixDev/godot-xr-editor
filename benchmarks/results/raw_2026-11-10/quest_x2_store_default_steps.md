
benchmarks/results/raw_2026-11-10/quest_x2_store_default.log
| Step | s | fps | Stale | App | Rest | GPU% | GPU MHz | Levels | Fov | Calls |
|---|---|---|---|---|---|---|---|---|---|---|
| closed | 8 | 72 | 0 | 5.64 | 5.5 | 0.53 | 525 | 2/2 | 3 | 10 |
| open | 8 | 72 | 0 | 9.90 | 12.4 | 0.81 | 483 | 2/4 | 3 | 327 |
| open_big2 | 7 | 65 | 7 | 13.73 | 16.4 | 0.97 | 525 | 5/4 | 3 | 589 |
| open | 7 | 72 | 0 | 9.77 | 12.3 | 0.80 | 525 | 2/4 | 3 | 327 |
| open_big2 | 7 | 63 | 10 | 13.84 | 16.9 | 0.97 | 525 | 2/4 | 3 | 589 |
| open_big2 | 8 | 65 | 8 | 13.89 | 16.0 | 0.98 | 525 | 3/4 | 3 | 589 |
| closed | 7 | 72 | 0 | 5.71 | 5.5 | 0.53 | 441 | 2/2 | 3 | 11 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.33 | 6.39 | 5 | 5 | 50 | 5 | 0 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 1.27 | 11.06 | 302 | 302 | 80112 | 5 | 0 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.60 | 15.13 | 564 | 564 | 155162 | 5 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.06 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open | XRESession/XREViewport | 1.31 | 10.90 | 302 | 302 | 80084 | 5 | 0 |
| open | FunctionsWindow/Viewport | 0.07 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.98 | 15.22 | 564 | 564 | 155182 | 5 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.07 | 0.14 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.12 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| open_big2 | XRESession/XREViewport | 1.83 | 15.31 | 564 | 564 | 155150 | 5 | 0 |
| open_big2 | FunctionsWindow/Viewport | 0.06 | 0.13 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | Badge/Viewport | 0.11 | 0.07 | 0 | 0 | 0 | 0 | 10 |
| open_big2 | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_big2 | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |
| closed | XRESession/XREViewport | 0.35 | 6.44 | 6 | 6 | 62 | 5 | 0 |
| closed | Badge/Viewport | 0.15 | 0.06 | 0 | 0 | 0 | 0 | 10 |
| closed | @SubViewportContainer@10100/@SubViewport@10101 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | root | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 180 |

Plugin scripts, the step's last lab report (ms per frame):
| Step | n | graph scripts | facing | ray routing | manipulator | process (lab) |
|---|---|---|---|---|---|---|
| 01 closed | 1 | 0.32 | 0.00 | 0.03 | 0.29 | 16.71 |
| 02 open | 1 | 1.78 | 0.25 | 0.87 | 0.31 | 23.70 |
| 03 open_big2 | 1 | 1.75 | 0.31 | 0.99 | 0.25 | 28.50 |
| 04 open | 1 | 1.75 | 0.25 | 0.87 | 0.31 | 24.63 |
| 05 open_big2 | 1 | 2.28 | 0.39 | 1.27 | 0.31 | 27.76 |
| 06 open_big2 | 1 | 2.05 | 0.36 | 1.15 | 0.29 | 27.13 |
| 07 closed | 1 | 0.35 | 0.00 | 0.03 | 0.34 | 16.45 |
