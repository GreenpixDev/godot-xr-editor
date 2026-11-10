# Профайлеры: Tracy на ПК (шаг 1.5) и Perfetto на Quest (шаг 1.6), 2026-11-10

План — [performance_plan.md](../../docs/performance_plan.md), шаги 1.5 и 1.6. Сборки — [D-160](../../docs/decisions.md), [profiling_builds.md](../../docs/profiling_builds.md). Все прогоны без автора ([D-161](../../docs/decisions.md)): шлем лежал на столе, датчик присутствия и Guardian выключены. Голова неподвижна, поэтому цены поворота карточек к голове в этих числах нет. Сравнивать их с прогонами со стола, а не с прогонами 2026-11-09 в надетом шлеме.

Железо: ПК — Windows 11, RTX 4060, Meta Horizon (Oculus 1.208.0), Quest 2 по Link, 120 Гц (кадр 8,33 мс). Quest 2 — Adreno 650, рантайм Oculus 209.165.0, 72 Гц (кадр 13,9 мс). Движок — Godot 4.7.2 из исходников тега с профайлером (`production=yes debug_symbols=yes`): на ПК MSVC и `profiler=tracy`, на Quest `profiler=perfetto` (пакет `org.godotengine.editor.v4.meta.release`). Сцена `res://benchmarks/play_check.tscn`, граф BlueCube.

## Выводы

Главные числа — из повторных прогонов `stress` после правки лаборатории ([D-163](../../docs/decisions.md)), таблицы в разделе «Чистые кривые роста». Остальные прогоны дня шли до правки, и их CPU включает добавку от опроса вьюпортов.

- **Сам замер лаборатории в `base` и `stress` стоил на Quest 2–3,5 мс CPU на кадр.** До правки `_measure` каждый кадр читал время ~1930 вьюпортов редактора, хотя рисуют из них 5–7. После правки (читаются только рисующие) `process` в `closed` на Quest — 2,7–3,3 мс против 6–7,5 мс; в обычной лаборатории без опроса — 3,5 мс. На ПК `graph_lab.gd` подешевел с 1,2–1,6 до 0,11–0,18 мс на кадр. Числа CPU прогонов `base` и `stress` до 2026-11-10 13:00 на Quest завышены на эту величину; числа GPU — нет (строки `view` до и после правки совпадают).
- **Quest: открытый граф упирается в CPU потока рендера.** `Main::iteration` идёт на потоке `VkThread` и при 72 Гц почти не ждёт `xrWaitFrame` (0,02–0,06 мс в открытых шагах). При открытом BlueCube 15,4–16,5 мс кадра делятся так:
  - `process` (скрипты плагина и ноды редактора) — 4,8–5,7 мс;
  - `RenderingServer::draw` (подготовка и запись отрисовки) — 9,8–10,2 мс.

  Рост с размером графа:

  | Граф | Кадр | `process` | `RenderingServer::draw` |
  |---|---|---|---|
  | 100 блоков | 27,9 мс | 8,9 мс | 18,5 мс |
  | 250 блоков | 58,3 мс | 20,5 мс | 37,5 мс |
  | 500 блоков | 146,6 мс | 32,3 мс | 114,3 мс |

  Подготовка отрисовки растёт быстрее скриптов.
- **Quest: сцены упираются в GPU.** В `closed_scene5k` из 83 мс кадра 58 мс — собственное время `_execute_frame` (отправка кадра и ожидание GPU), при GPU 99–100 % и App 74 мс по VrApi. `process` при этом 2,4 мс.
- **Разбить `process` по функциям на Quest нельзя без правки движка.** Зоны GDScript (категория `godot_scripting`) ломают вложенность всех зон: в 4.7.2 у `PerfettoScriptTracer` не инициализировано поле `tracing`, и пропущенный `TRACE_EVENT_BEGIN` получает лишний `TRACE_EVENT_END` ([D-162](../../docs/decisions.md)). Трассы этого дня записаны только с категорией `godot`: зоны движка вложены правильно, а функции GDScript в трассу не попадают. Разбивку по функциям дал Tracy на ПК, ниже.
- **ПК: на больших графах растут стрелки проводов в `blueprint_canvas.gd`.**
  - Скрипты плагина в `open_graph500` стоят 6,4 мс на кадр, из них `blueprint_canvas.gd` — 5,6 мс. Это почти целиком раскладка стрелок: `_lay_arrows` 5,5 мс (раз в два кадра), `_arrows_on` 295 вызовов за кадр, `_put_arrow` 515, `get_point` 23 591.
  - На 100 блоках файл стоит 1,5 мс, на 250 — 3,6 мс.
  - Это вход шага 2.1.
- **ПК: при BlueCube и меньших графах кадр держит 120 Гц с запасом.** `xrWaitFrame` (простой) — 3–5,5 мс из 8,4 мс. Скрипты плагина: 0,46–0,59 мс при закрытом графе, 1,0–1,2 мс при открытом BlueCube.
- **Накладные расходы профайлеров** (по одному прогону на сборку):
  - Quest, GPU: App по VrApi у сборки с трассами, той же сборки без трасс и Store совпадает в пределах 0,3 мс (`open`: 13,78, 13,73 и 13,67 мс). App — время GPU, CPU-цену сборки он не показывает.
  - Quest, CPU: время скриптов графа по строкам лаборатории (`graph lab: graph scripts`) у обеих Perfetto-сборок выше, чем у Store: `open` 2,22 и 2,13 мс против 1,96 мс, `open_big2` 3,30 и 3,43 против 2,91 мс. То есть +10–15 % на скриптах, и без записи трассы тоже. Вероятная причина — `PerfettoScriptTracer` правит `HashSet` на каждом вызове GDScript при любой категории. Поэтому `process` в трассах Quest немного завышен против Store.
  - ПК: fps `stress` у Tracy-сборки с записью, без записи и у официальной: graph100 — 101, 112, 107; graph250 — 60, 50, 59; graph500 — 40, 38, 39; `open_scene5k` — 106, 94, 119. `process` лаборатории на graph500 — 36,2, 34,0 и 31,4 мс, на graph250 — 22,6, 27,6 и 22,0 мс. По одному прогону разницу сборок от разброса не отделить.

## Прогоны

| Что | Команда | Лог | Итог |
|---|---|---|---|
| Quest, `stress`, Perfetto | `py scripts/quest.py --unattended --perfetto --scene res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress` | `logs/quest_2026-11-10T11-56-03` | 14 трасс; в `open_graph500` нет целого кадра (построение 3,9 с и секундный кадр после него заняли окно трассы) |
| Quest, `base`, Perfetto | то же с `--xre-graph-lab-base` | `logs/quest_2026-11-10T12-00-41` | 27 трасс, включая 9 `compat_*` (поток `GLThread`) |
| Quest, `base`, сборка Perfetto без трасс | `py scripts/quest.py --unattended --package org.godotengine.editor.v4.meta.release …-base` | `logs/quest_2026-11-10T12-07-39.log` | для накладных расходов |
| Quest, `base`, Store | `py scripts/quest.py --unattended …-base` | `logs/quest_2026-11-10T12-14-02.log` | для накладных расходов |
| Quest, обычная лаборатория, Perfetto (контроль без опроса вьюпортов) | `py scripts/quest.py --unattended --perfetto --scene res://benchmarks/play_check.tscn -- --xre-graph-lab` | `logs/quest_2026-11-10T12-52-13` | 24 трассы, все с целыми кадрами |
| Quest, `stress` после D-163, Perfetto | `py scripts/quest.py --unattended --perfetto --perfetto-delay 6 --scene res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress` | `logs/quest_2026-11-10T13-33-35` | 14 трасс, все с целыми кадрами |
| ПК по Link, `stress` после D-163, Tracy | как ниже | `logs/editor_meta_2026-11-10T13-37-54` | 14 записей |
| ПК по Link, `stress`, Tracy | `py scripts/xr_editor.py --runtime meta --hide-ui --unattended --tracy res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress` | `logs/editor_meta_2026-11-10T12-21-44` | 14 записей по 5 с, все с целыми кадрами |
| ПК по Link, `base`, Tracy | то же с `--xre-graph-lab-base` | `logs/editor_meta_2026-11-10T12-30-03` | 18 шагов Forward+; на `leaving for Compatibility` редактор закрыт, шагов `compat_*` на ПК нет |
| ПК, `stress`, Tracy-сборка без записи | `py scripts/xr_editor.py --runtime meta --hide-ui --unattended --godot "$LOCALAPPDATA/xre/godot/bin/godot.windows.editor.x86_64.console.exe" …-stress` | `logs/editor_meta_2026-11-10T12-33-36.log` | для накладных расходов |
| ПК, `stress`, официальная сборка | `py scripts/xr_editor.py --runtime meta --hide-ui --unattended …-stress` | `logs/editor_meta_2026-11-10T12-36-28.log` | для накладных расходов |

Порядок: Quest с выключенным Link, затем `quest_link.py on`, прогоны ПК, `quest_link.py off --restore`. Шагов `away` (выход из фокуса) не было ни в одном прогоне. Трассы и записи (`.pftrace`, `.tracy`) лежат в `logs/` и в git не входят. Сжатые логи и полные таблицы разборщиков — в [raw_2026-11-10/](raw_2026-11-10/).

Шаги `compat_*` на ПК не измерены: второй экземпляр редактора (`OS.create_instance`) на ПК не проверен, а `tracy-capture` подключился бы к первому экземпляру на порту 8086.

## Чистые кривые роста (stress после D-163)

Quest: `logs/quest_2026-11-10T13-33-35`, трасса 3 с с шестой секунды шага (`--perfetto-delay 6`: так в `open_graph500` попадают целые кадры после построения графа). ПК по Link: `logs/editor_meta_2026-11-10T13-37-54`, запись 5 с с третьей секунды. Шагов `away` нет, 2D-окно не открывалось. Полные таблицы — `raw_2026-11-10/*_d163_*_steps.md`.

### Quest (Perfetto, мс на кадр)

| Шаг | Main::iteration | xrWaitFrame | process | RenderingServer::draw |
|---|---|---|---|---|
| closed | 13,84 | 7,10 | 3,29 | 2,59 |
| open | 16,54 | 0,06 | 5,66 | 10,24 |
| open_graph100 | 27,95 | 0,02 | 8,94 | 18,46 |
| open_graph250 | 58,34 | 0,26 | 20,53 | 37,47 |
| open_graph500 | 146,64 | 0,03 | 32,32 | 114,30 |
| open | 15,44 | 0,03 | 4,82 | 10,01 |
| closed | 13,89 | 0,48 | 2,71 | 10,04 |
| closed_scene1k | 27,77 | 0,55 | 2,35 | 24,22 |
| closed_scene5k | 84,30 | 0,26 | 2,40 | 80,99 |
| closed_scene20k | 254,51 | 0,03 | 2,51 | 251,36 |
| closed | 13,90 | 3,90 | 3,07 | 6,08 |
| open_scene5k | 101,47 | 0,81 | 5,40 | 98,70 |
| open | 15,97 | 0,03 | 5,49 | 9,84 |
| closed | 13,87 | 0,03 | 2,78 | 10,38 |

В закрытых шагах после большого графа или сцены `RenderingServer::draw` держится на 6–10 мс, против 2,6 мс в первом `closed`. Это почти целиком собственное время `rasterizer->blit_render_targets_to_screen`: 7,4 мс во втором `closed`. Кадр всё равно 13,9 мс (72 Гц), а `xrWaitFrame` при этом почти нулевой, так что это, вероятно, ожидание кадра рантаймом в другом месте (образ цепочки OpenXR). Не проверено.

### ПК по Link (Tracy, мс на кадр)

| Шаг | Кадр | xr_server->_process | RenderingServer::draw | process | Скрипты плагина | Первый файл плагина |
|---|---|---|---|---|---|---|
| closed | 8,42 | 5,25 | 2,22 | 0,90 | 0,51 | blueprints.gd 0,10 |
| open | 8,38 | 3,91 | 3,08 | 1,37 | 1,01 | blueprint_canvas.gd 0,48 |
| open_graph100 | 8,73 | 0,91 | 5,36 | 2,43 | 2,06 | blueprint_canvas.gd 1,52 |
| open_graph250 | 17,62 | 4,09 | 8,75 | 4,71 | 4,31 | blueprint_canvas.gd 3,62 |
| open_graph500 | 24,56 | 3,17 | 14,54 | 6,78 | 6,36 | blueprint_canvas.gd 5,60 |
| open | 8,40 | 3,26 | 3,48 | 1,63 | 1,20 | blueprint_canvas.gd 0,54 |
| closed | 8,39 | 5,35 | 2,09 | 0,92 | 0,59 | graph_lab.gd 0,18 |
| closed_scene1k | 8,38 | 4,51 | 3,02 | 0,83 | 0,48 | blueprints.gd 0,10 |
| closed_scene5k | 8,39 | 2,74 | 4,79 | 0,84 | 0,50 | blueprints.gd 0,10 |
| closed_scene20k | 16,76 | 4,76 | 10,99 | 0,95 | 0,58 | graph_lab.gd 0,11 |
| closed | 8,39 | 5,53 | 2,05 | 0,78 | 0,46 | blueprints.gd 0,09 |
| open_scene5k | 8,95 | 1,26 | 6,26 | 1,39 | 1,02 | blueprint_canvas.gd 0,47 |
| open | 8,45 | 3,77 | 3,25 | 1,41 | 1,04 | blueprint_canvas.gd 0,48 |
| closed | 8,43 | 5,48 | 2,05 | 0,88 | 0,55 | graph_lab.gd 0,17 |

## Quest: зоны движка по шагам (Perfetto, мс на кадр)

Прогоны до правки D-163: `process` включает 2–3,5 мс опроса вьюпортов.

`py benchmarks/perfetto_steps.py logs/quest_<время> --zone Main::iteration --zone xrWaitFrame --zone process --zone RenderingServer::draw`. Трасса — 3 с с третьей секунды шага. Полные таблицы с топом зон — `raw_2026-11-10/quest_*_perfetto_steps.md`.

### stress

| Шаг | Main::iteration | xrWaitFrame | process | RenderingServer::draw |
|---|---|---|---|---|
| closed | 14,13 | 3,78 | 6,96 | 2,73 |
| open | 16,30 | 0,05 | 7,42 | 8,35 |
| open_graph100 | 29,02 | 0,11 | 12,00 | 16,32 |
| open_graph250 | 58,78 | 0,31 | 21,45 | 37,20 |
| open_graph500 | нет целого кадра | | | |
| open | 16,53 | 0,03 | 7,73 | 8,25 |
| closed | 14,11 | 1,95 | 7,49 | 4,05 |
| closed_scene1k | 28,07 | 1,80 | 5,92 | 20,08 |
| closed_scene5k | 83,48 | 1,06 | 6,40 | 78,30 |
| closed_scene20k | 253,80 | 0,03 | 5,33 | 248,12 |
| closed | 14,14 | 1,98 | 7,39 | 4,16 |
| open_scene5k | 100,76 | 0,92 | 9,23 | 90,19 |
| open | 16,55 | 0,04 | 7,63 | 8,38 |
| closed | 14,10 | 1,90 | 7,53 | 4,05 |

### base

| Шаг | Main::iteration | xrWaitFrame | process | RenderingServer::draw |
|---|---|---|---|---|
| closed | 14,09 | 2,24 | 5,95 | 5,26 |
| closed_vr_off | 14,20 | 3,37 | 7,08 | 3,02 |
| closed_views_off | 14,28 | 1,93 | 7,17 | 4,54 |
| closed_root_off | 14,14 | 4,35 | 7,00 | 2,00 |
| closed_lean | 14,14 | 2,21 | 7,33 | 3,85 |
| closed_scene_off | 14,14 | 3,60 | 7,43 | 2,37 |
| closed_empty | 14,10 | 2,70 | 6,83 | 3,79 |
| closed | 14,15 | 0,04 | 7,01 | 6,43 |
| open | 16,41 | 0,04 | 7,30 | 8,55 |
| open_dimmer_off | 16,57 | 0,03 | 7,68 | 8,27 |
| open_ui_off | 16,12 | 0,03 | 7,52 | 8,04 |
| open_all_off | 14,20 | 1,12 | 8,68 | 3,77 |
| open_views_off | 16,41 | 0,03 | 7,60 | 8,21 |
| open_root_off | 14,46 | 0,49 | 7,68 | 5,75 |
| open_lean | 15,76 | 0,04 | 7,42 | 7,78 |
| open | 16,45 | 0,03 | 7,60 | 8,24 |
| open_big2 | 21,17 | 0,06 | 9,11 | 11,52 |
| closed | 14,18 | 1,98 | 7,61 | 3,96 |
| compat_closed | 14,04 | 6,56 | 5,46 | 1,43 |
| compat_closed_vr_off | 14,12 | 5,36 | 6,45 | 1,64 |
| compat_closed_empty | 14,10 | 5,48 | 6,58 | 1,34 |
| compat_open | 13,98 | 0,90 | 7,63 | 4,96 |
| compat_open_ui_off | 14,47 | 1,51 | 7,96 | 4,45 |
| compat_open_all_off | 14,11 | 2,30 | 8,62 | 2,49 |
| compat_open_big2 | 17,12 | 0,03 | 9,37 | 7,19 |
| compat_open | 14,33 | 0,79 | 7,83 | 5,14 |
| compat_closed | 14,12 | 4,63 | 7,03 | 1,75 |

### Контроль: обычная лаборатория без опроса вьюпортов

`logs/quest_2026-11-10T12-52-13`, та же сборка и та же сцена, шаги обычной лаборатории (без `_fix_foveation`, поэтому GPU-части с `base` не сравнивать).

| Шаг | Main::iteration | xrWaitFrame | process | RenderingServer::draw |
|---|---|---|---|---|
| closed | 13,87 | 6,63 | 3,49 | 2,83 |
| open | 15,79 | 0,09 | 5,00 | 10,10 |
| open_ports_off | 14,56 | 0,04 | 5,31 | 8,62 |
| open_text_off | 14,41 | 0,67 | 6,18 | 6,91 |
| open_wires_off | 14,92 | 0,04 | 4,73 | 9,49 |
| open_all_off | 13,88 | 4,40 | 5,62 | 3,09 |
| open_service_off_text_off | 13,88 | 3,01 | 3,38 | 6,74 |
| open_big2 | 20,82 | 0,04 | 6,50 | 13,75 |
| open_big4 | 30,60 | 0,12 | 10,00 | 20,31 |
| open (последний) | 16,08 | 0,03 | 5,24 | 10,24 |
| closed (последний) | 13,87 | 6,96 | 3,46 | 2,53 |

Полная таблица — `raw_2026-11-10/quest_plain_perfetto_steps.md`.

Кадр на потоке рендера держится около 14,1 мс и в закрытых шагах — это 72 Гц: CPU в них не предел, а `xrWaitFrame` и прочее ожидание заполняют остаток. Цифры `process` меряют, сколько CPU уходит на ноды, а не что ограничивает fps.

## ПК по Link: фазы кадра и скрипты плагина (Tracy, мс на кадр)

Прогоны до правки D-163: «Скрипты плагина» включают 1,0–1,4 мс опроса вьюпортов в `graph_lab.gd`.

`py benchmarks/tracy_steps.py logs/editor_meta_<время>`, запись 5 с с третьей секунды шага, главный поток. «Скрипты плагина» — собственное время зон GDScript из `res://addons/xr_editor/` вместе с вызовами движка из них. Полные таблицы — `raw_2026-11-10/pc_link_*_tracy_steps.md`.

### stress

| Шаг | Кадр | xr_server->_process | RenderingServer::draw | process | Скрипты плагина | Первый файл плагина |
|---|---|---|---|---|---|---|
| closed | 8,39 | 4,59 | 1,95 | 1,82 | 1,53 | graph_lab.gd 1,18 |
| open | 8,40 | 2,72 | 3,05 | 2,59 | 2,24 | graph_lab.gd 1,32 |
| open_graph100 | 11,76 | 2,78 | 5,28 | 3,67 | 3,32 | blueprint_canvas.gd 1,50 |
| open_graph250 | 18,26 | 4,05 | 8,29 | 5,94 | 5,55 | blueprint_canvas.gd 3,56 |
| open_graph500 | 25,44 | 3,15 | 14,09 | 8,12 | 7,72 | blueprint_canvas.gd 5,53 |
| open | 8,39 | 2,90 | 2,97 | 2,50 | 2,18 | graph_lab.gd 1,28 |
| closed | 8,39 | 4,24 | 1,98 | 2,15 | 1,83 | graph_lab.gd 1,44 |
| closed_scene1k | 8,40 | 3,38 | 2,99 | 2,00 | 1,68 | graph_lab.gd 1,28 |
| closed_scene5k | 8,38 | 1,59 | 4,72 | 2,05 | 1,73 | graph_lab.gd 1,32 |
| closed_scene20k | 16,75 | 3,43 | 10,92 | 2,35 | 1,98 | graph_lab.gd 1,49 |
| closed | 8,39 | 4,32 | 2,02 | 2,02 | 1,70 | graph_lab.gd 1,29 |
| open_scene5k | 9,82 | 1,36 | 5,79 | 2,63 | 2,28 | graph_lab.gd 1,35 |
| open | 8,39 | 2,70 | 3,03 | 2,62 | 2,28 | graph_lab.gd 1,34 |
| closed | 8,65 | 3,90 | 2,13 | 2,59 | 2,07 | graph_lab.gd 1,62 |

Последний `closed` — не замер: в этом шаге открылось 2D-окно редактора (`editor's 2D window shown`, затем ошибки `sync_action_sets`), лаборатория `away` не записала, последний отчёт шага — 68 fps и 964 вызова. В двух других прогонах `stress` того же часа этот шаг — 119–120 fps и 26 вызовов.

`xr_server->_process` — почти целиком `xrWaitFrame`, то есть ожидание рантайма. В шагах на 120 fps это запас кадра.

### base (Forward+)

| Шаг | Кадр | xr_server->_process | RenderingServer::draw | process | Скрипты плагина | Первый файл плагина |
|---|---|---|---|---|---|---|
| closed | 8,39 | 4,42 | 1,99 | 1,95 | 1,62 | graph_lab.gd 1,25 |
| closed_vr_off | 8,39 | 4,38 | 1,99 | 1,98 | 1,65 | graph_lab.gd 1,26 |
| closed_views_off | 8,40 | 4,48 | 1,96 | 1,94 | 1,62 | graph_lab.gd 1,25 |
| closed_root_off | 8,38 | 6,01 | 0,49 | 1,87 | 1,56 | graph_lab.gd 1,21 |
| closed_lean | 8,37 | 4,73 | 1,66 | 1,97 | 1,64 | graph_lab.gd 1,27 |
| closed_scene_off | 8,37 | 4,87 | 1,51 | 1,96 | 1,63 | graph_lab.gd 1,25 |
| closed_empty | 8,37 | 5,40 | 0,93 | 2,02 | 1,68 | graph_lab.gd 1,29 |
| closed | 8,39 | 4,37 | 1,99 | 2,01 | 1,66 | graph_lab.gd 1,28 |
| open | 8,42 | 2,40 | 3,19 | 2,81 | 2,43 | graph_lab.gd 1,43 |
| open_dimmer_off | 8,40 | 3,21 | 2,60 | 2,57 | 2,22 | graph_lab.gd 1,29 |
| open_ui_off | 8,68 | 2,21 | 3,36 | 3,08 | 2,64 | graph_lab.gd 1,58 |
| open_all_off | 8,40 | 3,12 | 2,55 | 2,68 | 2,23 | graph_lab.gd 1,49 |
| open_views_off | 8,40 | 2,90 | 2,87 | 2,61 | 2,24 | graph_lab.gd 1,31 |
| open_root_off | 8,39 | 4,65 | 1,14 | 2,57 | 2,22 | graph_lab.gd 1,29 |
| open_lean | 8,39 | 3,25 | 2,54 | 2,57 | 2,21 | graph_lab.gd 1,28 |
| open | 8,41 | 2,57 | 3,08 | 2,72 | 2,34 | graph_lab.gd 1,37 |
| open_big2 | 8,45 | 1,86 | 3,62 | 2,96 | 2,59 | graph_lab.gd 1,30 |
| closed | 8,39 | 3,97 | 2,02 | 2,36 | 1,99 | graph_lab.gd 1,55 |

## Ограничения

- Зоны редактора Godot (`editor/`) в 4.7.2 не размечены: их время входит в собственное время `process` и других зон, но отдельной строкой не видно. На ПК `process` без скриптов плагина — около 0,3–0,4 мс.
- На ПК Tracy добавляет зону на каждый вызов GDScript и на каждый вызов движка из скрипта, поэтому часто вызываемые короткие функции (`get_point`, опрос вьюпортов в `_measure`) раздуты. Порядок мест надёжен, абсолютные числа — только относительно других чисел Tracy.
- На ПК компилятор MSVC, у официальной сборки — MinGW ([D-160](../../docs/decisions.md)). При выходе редактор с Tracy падает (известно, D-160); в этих прогонах его закрывал `xr_editor.py --unattended`.
- На Quest трасса пишет все процессы. Поток с кадром выбирается по числу `Main::iteration`; в шагах `compat_*` это `GLThread` нового процесса, как и должно быть.
- Голова неподвижна (D-161): поворота карточек к голове нет, поэтому `open_graph100` на ПК даёт 101–112 fps против 68 fps 2026-11-09 в надетом шлеме.

## Что дальше

- Шаг 2.1: раскладка стрелок проводов (`_lay_arrows`, `_arrows_on`, `_put_arrow`, `get_point`) — главный рост скриптов плагина с размером графа на ПК.
- Выводы этапа 1 о CPU на Quest, взятые из `base` и `stress` до D-163, пересчитать по новым числам (`process` ниже на 2–3,5 мс).
- Разбивка `process` на Quest по функциям: нужна правка движка (`bool tracing = false;`, D-162, по условиям D-157 — форк) или Tracy на Quest. Решает автор.
