# Стрессовый прогон лаборатории в sim-режиме на ПК (2026-11-09)

> **Устарело (2026-11-09, позже).** Снято до того, как вид стал считаться по границам геометрии и сцена стресса встала кубом за столом: раскладка вида и объектов другая, числа с таблицами Quest и ПК по Link не сравнивать. Актуально: [stage1_summary_2026-11-09.md](stage1_summary_2026-11-09.md), [lab_pc_link_2026-11-09.md](lab_pc_link_2026-11-09.md).

`py scripts/xr_editor.py --runtime sim --hide-ui res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress`, окно sim 1280×800, Forward+, RTX 4060, шаги по 10 с, отчёты по 5 с. Разбор: `py benchmarks/quest_lab_steps.py logs/editor_sim_2026-11-09T15-11-54.log`. Время рендера вьюпортов на ПК вернулось нулями (как в D-152); счётчики — настоящие. Окно sim — один вид, не два глаза, поэтому GPU и заполнение с Quest не сравнимы; цена CPU и число объектов — сравнимы по порядку.

logs/editor_sim_2026-11-09T15-11-54.log
| Step | reports | fps | VR view CPU | VR view GPU | process | Calls |
|---|---|---|---|---|---|---|
| closed | 2 | 165 | 0.00 | 0.00 | 8.52 | 70 |
| open | 2 | 165 | 0.00 | 0.00 | 9.24 | 447 |
| open_graph100 | 2 | 129 | 0.00 | 0.00 | 14.16 | 1404 |
| open_graph250 | 2 | 73 | 0.00 | 0.00 | 21.85 | 2885 |
| open_graph500 | 2 | 47 | 0.00 | 0.00 | 30.91 | 4550 |
| open | 2 | 165 | 0.00 | 0.00 | 9.69 | 447 |
| closed | 2 | 165 | 0.00 | 0.00 | 11.61 | 70 |
| closed_scene1k | 2 | 165 | 0.00 | 0.00 | 9.64 | 82 |
| closed_scene5k | 2 | 165 | 0.00 | 0.00 | 9.92 | 83 |
| closed_scene20k | 2 | 97 | 0.00 | 0.00 | 16.03 | 88 |
| closed | 2 | 165 | 0.00 | 0.00 | 9.07 | 70 |
| open_scene5k | 2 | 159 | 0.00 | 0.00 | 11.22 | 460 |
| open | 2 | 165 | 0.00 | 0.00 | 9.67 | 447 |
| closed | 2 | 165 | 0.00 | 0.00 | 10.69 | 70 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 29 | 29 | 11728 | 20 | 21 |
| closed | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 386 | 388 | 91638 | 20 | 21 |
| open | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 1343 | 1350 | 316120 | 20 | 21 |
| open_graph100 | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph100 | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | (graph of 100 block(s), 112 wire(s)) | | | | | | | |
| open_graph250 | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 2824 | 2838 | 689146 | 20 | 21 |
| open_graph250 | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph250 | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | (graph of 250 block(s), 280 wire(s)) | | | | | | | |
| open_graph500 | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 4489 | 4509 | 1098802 | 20 | 21 |
| open_graph500 | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph500 | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | (graph of 500 block(s), 560 wire(s)) | | | | | | | |
| open | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 386 | 388 | 91634 | 20 | 21 |
| open | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| closed | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 29 | 29 | 11728 | 20 | 21 |
| closed | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| closed_scene1k | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 30 | 655 | 19240 | 31 | 21 |
| closed_scene1k | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene1k | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| closed_scene1k | (scene of 1000 object(s) added) | | | | | | | |
| closed_scene5k | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 30 | 2817 | 45184 | 32 | 21 |
| closed_scene5k | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene5k | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| closed_scene5k | (scene of 5000 object(s) added) | | | | | | | |
| closed_scene20k | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 30 | 9956 | 130852 | 37 | 21 |
| closed_scene20k | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene20k | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| closed_scene20k | (scene of 20000 object(s) added) | | | | | | | |
| closed | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 29 | 29 | 11728 | 20 | 21 |
| closed | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_scene5k | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 387 | 3176 | 125106 | 32 | 21 |
| open_scene5k | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_scene5k | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_scene5k | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_scene5k | (scene of 5000 object(s) added) | | | | | | | |
| open | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 386 | 388 | 91638 | 20 | 21 |
| open | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| closed | XRESimulator/XRESimulatorWindow | 0.00 | 0.00 | 29 | 29 | 11728 | 20 | 21 |
| closed | @SubViewportContainer@10230/@SubViewport@10231 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
