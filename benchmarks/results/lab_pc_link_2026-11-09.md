# ПК со шлемом (Quest 2 по Link), кривые роста (D-157, 2026-11-09)

Windows 11, редактор Godot 4.7.2 на Forward+ (Vulkan), Meta Horizon (Oculus 1.208.0), Quest 2 по Link, дисплей 120 Гц (бюджет кадра 8,3 мс). Команда: `py scripts/xr_editor.py --fallback sim --hide-ui res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress`; лог `logs/editor_meta_2026-11-09T20-56-29.log`. Вид сверен проверкой `--xre-graph-lab-pose` (лог `logs/editor_meta_2026-11-09T20-54-52.log`, снимки: граф на 500 блоков, стол и сцена целиком в кадре).

## Выводы

| Что | fps | process мс | Вызовов в виде | Объектов в виде |
|---|---|---|---|---|
| closed | 119–120 | 9,5–11,9 | 6 | 6 |
| open (BlueCube) | 119 | 11,7 | 370 | 372 |
| граф 100 блоков | 68 | 18,9 | 1329 | 1338 |
| граф 250 блоков | 58 | 43,1 | 3246 | 3270 |
| граф 500 блоков | 27 | 109,2 | 6451 | 6490 |
| сцена 1k объектов | 120 | 10,6 | 7 | 990 |
| сцена 5k | 120 | 12,8 | 7 | 3951 |
| сцена 20k | 60 | 19,3 | 7 | 11652 |
| сцена 5k и граф | 83 | 14,6 | 372 | 5104 |

- **Сцена против графа.** Forward+ склеивает одинаковые кубы автоинстансингом: 11652 объекта рисуются 7 вызовами и дают 60 fps. Тот же граф из тысяч разных карточек и подписей так не склеивается: 1329 вызовов, 68 fps. На Quest (Mobile) склейки нет, и 1k объектов стоят как граф на 100 блоков (D-159, лог шлема). Гипотеза для этапа 2, не проверенная: на Mobile склейка вызовов (MultiMesh, общий меш карточек) снизила бы и CPU, и GPU графа.
- **fps ПК при открытом BlueCube держит 119–120**; ломается он между 27 блоками и 100: 68 fps при дисплее 120 Гц.
- **Время `process` не чистый CPU.** Это `Performance.TIME_PROCESS` главного потока: при загруженном GPU он ждёт его, поэтому рост от 18,9 до 109 мс (500 блоков) нельзя целиком отнести на счёт CPU графа. Для CPU по функциям нужен Tracy (1.5).

## Что на ПК не измерено и почему

- **Время рендера вида** (`viewport_get_measured_render_time_*`) на ПК по-прежнему 0, и в настоящей сессии Link тоже: причина не найдена. В таблицах ниже колонки CPU и GPU вида нулевые, счётчики вызовов и объектов настоящие.
- **`--engine=--gpu-profile` (шаг 1.3) на ПК бесполезен.** Движок печатает «GPU PROFILE» раз в секунду, но во всех 169 блоках одно и то же: total 0,804 мс, стадии Setup Sky 0,15, Tonemap 0,15, Glow 0,23, Render CanvasItems 0,11, ни одного отличия между шагами. Это профиль окна редактора, не XR-вида. Лог `logs/editor_meta_2026-11-09T20-59-54.log`. GPU ПК надо мерить снаружи: PresentMon, Nsight или счётчики карты; не сделано.

## Таблица. Прогон `--xre-graph-lab-stress` на ПК
logs/editor_meta_2026-11-09T20-56-29.log
| Step | reports | fps | VR view CPU | VR view GPU | process | Calls |
|---|---|---|---|---|---|---|
| closed | 2 | 119 | 0.00 | 0.00 | 9.51 | 26 |
| open | 2 | 119 | 0.00 | 0.00 | 11.72 | 410 |
| open_graph100 | 2 | 68 | 0.00 | 0.00 | 18.92 | 1369 |
| open_graph250 | 2 | 58 | 0.00 | 0.00 | 43.10 | 3286 |
| open_graph500 | 2 | 27 | 0.00 | 0.00 | 109.20 | 6491 |
| open | 2 | 120 | 0.00 | 0.00 | 11.60 | 406 |
| closed | 2 | 120 | 0.00 | 0.00 | 10.99 | 26 |
| closed_scene1k | 2 | 120 | 0.00 | 0.00 | 10.63 | 36 |
| closed_scene5k | 2 | 120 | 0.00 | 0.00 | 12.79 | 39 |
| closed_scene20k | 2 | 60 | 0.00 | 0.00 | 19.25 | 44 |
| closed | 2 | 120 | 0.00 | 0.00 | 9.60 | 26 |
| open_scene5k | 2 | 83 | 0.00 | 0.00 | 14.57 | 423 |
| open | 2 | 118 | 0.00 | 0.00 | 13.58 | 410 |
| closed | 2 | 120 | 0.00 | 0.00 | 11.89 | 26 |

Viewports, the last report of each step (ms per frame; calls, objects and primitives of the last frame):
| Step | View | CPU | GPU | Visible calls | Objects | Primitives | Shadow calls | Canvas calls |
|---|---|---|---|---|---|---|---|---|
| closed | XRESession/XREViewport | 0.00 | 0.00 | 6 | 6 | 62 | 20 | 0 |
| closed | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | XRESession/XREViewport | 0.00 | 0.00 | 370 | 372 | 80108 | 20 | 0 |
| open | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | XRESession/XREViewport | 0.00 | 0.00 | 1329 | 1338 | 305314 | 20 | 0 |
| open_graph100 | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph100 | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph100 | (graph of 100 block(s), 112 wire(s)) | | | | | | | |
| open_graph250 | XRESession/XREViewport | 0.00 | 0.00 | 3246 | 3270 | 755718 | 20 | 0 |
| open_graph250 | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph250 | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph250 | (graph of 250 block(s), 280 wire(s)) | | | | | | | |
| open_graph500 | XRESession/XREViewport | 0.00 | 0.00 | 6451 | 6490 | 1502218 | 20 | 0 |
| open_graph500 | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_graph500 | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_graph500 | (graph of 500 block(s), 560 wire(s)) | | | | | | | |
| open | XRESession/XREViewport | 0.00 | 0.00 | 370 | 372 | 80100 | 16 | 0 |
| open | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| closed | XRESession/XREViewport | 0.00 | 0.00 | 6 | 6 | 62 | 20 | 0 |
| closed | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| closed_scene1k | XRESession/XREViewport | 0.00 | 0.00 | 7 | 990 | 11870 | 29 | 0 |
| closed_scene1k | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene1k | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| closed_scene1k | (scene of 1000 object(s) added) | | | | | | | |
| closed_scene5k | XRESession/XREViewport | 0.00 | 0.00 | 7 | 3951 | 47402 | 32 | 0 |
| closed_scene5k | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene5k | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| closed_scene5k | (scene of 5000 object(s) added) | | | | | | | |
| closed_scene20k | XRESession/XREViewport | 0.00 | 0.00 | 7 | 11652 | 139814 | 37 | 0 |
| closed_scene20k | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed_scene20k | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| closed_scene20k | (scene of 20000 object(s) added) | | | | | | | |
| closed | XRESession/XREViewport | 0.00 | 0.00 | 6 | 6 | 62 | 20 | 0 |
| closed | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_scene5k | XRESession/XREViewport | 0.00 | 0.00 | 372 | 5104 | 136900 | 31 | 0 |
| open_scene5k | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open_scene5k | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_scene5k | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open_scene5k | (scene of 5000 object(s) added) | | | | | | | |
| open | XRESession/XREViewport | 0.00 | 0.00 | 370 | 372 | 80108 | 20 | 0 |
| open | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| open | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| open | FunctionsWindow/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
| closed | XRESession/XREViewport | 0.00 | 0.00 | 6 | 6 | 62 | 20 | 0 |
| closed | @SubViewportContainer@10250/@SubViewport@10251 | 0.00 | 0.00 | 2 | 2 | 824 | 0 | 0 |
| closed | Badge/Viewport | 0.00 | 0.00 | 0 | 0 | 0 | 0 | 10 |
