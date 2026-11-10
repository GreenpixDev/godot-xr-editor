# Замеры кадра

Вынесено из CLAUDE.md.

Замер кадра (Link на 90 Гц): `godot --path . --editor --xr-mode on --log-file logs/xr_bench.log res://benchmarks/empty.tscn -- --xre-benchmark` → надеть шлем; замер ждёт состояния FOCUSED, идёт ~4 мин (сегменты ABBA: UI открыт / скрыт / скрыт / открыт) и сам закрывает редактор. Меню и диалоги редактора во время замера не трогать: это отдельные окна, они сбивают темп кадров. Тот же замер есть в Project → Tools (в русском интерфейсе — Проект → Инструменты) → «XR Editor: Measure Frame Time», без автозакрытия. Результаты — в `benchmarks/results/`. Метрики и их смысл — в `gdextension/src/frame_timer.h` и в docstring `frametime_report.py`.

## Прочие команды

```bash
py scripts/xr_extensions.py ["<манифест рантайма.json>"] [фильтр]  # расширения рантайма; по умолчанию XR_RUNTIME_JSON или активный рантайм
py benchmarks/quest_fps_report.py logs/quest_<время>.log  # темп кадров редактора и игр на шлеме по счётчикам рантайма Meta (VrApi); CSV и отчёт в benchmarks/results/
godot --path . --editor                       # обычный редактор
godot --path . --editor --xr-mode on          # редактор с принудительным OpenXR (спайк)
mkdir -p logs && godot --path . --editor --xr-mode on --log-file logs/xr.log   # то же с логом в файл
godot --path . --log-file logs/xr_game.log res://benchmarks/xr_game_check.tscn  # контроль: обычная XR-игра без редактора
py benchmarks/frametime_report.py benchmarks/results/frametime_<stamp>.csv  # сводка, гистограмма и график замера кадра
godot --path . --editor --xr-mode on --log-file logs/xr_handoff.log -- --xre-handoff  # замер передачи шлема игре и обратно
godot --path . --editor --xr-mode off --log-file logs/shots.log res://benchmarks/play_check.tscn -- --xre-shot-blueprint-vr  # снимки графа GreenCube с головы в build/shots/ (с сохранёнными настройками Settings), редактор закрывается сам
py scripts/xr_editor.py [сцена] -- --xre-session-frames  # покадровый замер (CPU, GPU) каждого отрезка, пока шлем у редактора: до игры и после каждого возврата; CSV в benchmarks/results/
py scripts/quest.py --scene res://benchmarks/play_check.tscn -- --xre-graph-lab [--xre-graph-lab-editor | --xre-graph-lab-game | --xre-graph-lab-compat | --xre-graph-lab-base]  # цена открытого графа по шагам (D-151, D-152, D-155): части холста; с -editor — части редактора и плагина (контроллеры держать в руках); с -game — база GPU, настройки и холст в игровом процессе, затем тот же процесс на Compatibility; с -compat — сразу Compatibility, если он не запустился сам; с -base — из чего состоит база GPU в самом редакторе, затем редактор на Compatibility. Разбор по шагам: py benchmarks/quest_lab_steps.py logs/quest_<time>.log
```

## Подробности основных команд

```bash
py scripts/xr_editor.py [--runtime auto|steamvr|meta|off|sim] [--fallback off|sim] [--mirror] [--hide-ui] [--check] [--no-restart] [сцена] [-- --xre-benchmark]  # редактор: в VR на рантайме, который видит шлем, иначе без VR; sim — VR-вид в окне без шлема (D-057), --fallback sim — он же, если ни один рантайм не видит шлем; --mirror — со шлемом ещё и окно с его видом на столе (D-118, в замере кадра — поле headset_view_on_desktop); --hide-ui — 2D-интерфейс скрыт и окно редактора свёрнуто, пока пользователь в VR (шлем у редактора или открыто окно sim), развернуть окно — интерфейс виден до trigger или grip (D-119; замер ABBA на время прогона это отключает, поле desktop_ui_hidden_in_headset); уже открытый на проекте редактор сам закрывает и запускает заново; лог в logs/editor_<рантайм>_<время>.log
scripts/check.sh                              # все скрипты парсятся и типизированы, headless-тесты инструментов, панелей, моделей контроллеров и play-mode проходят, нативная библиотека и плагин грузятся в headless-редакторе, инспектор в шлеме работает в нём; языковой сервер headless-редакторов — на порту LSP_PORT (по умолчанию 6097, не 6005), иначе Rider, подключённый к 6005, просит их разобрать скрипты worktree из .claude/ и ошибки LSP валят проверку
scripts/build_gdextension.sh android          # нативная часть под Android arm64 для автономного шлема (NDK 29.0.14206865 в %LOCALAPPDATA%\Android\Sdk\ndk или ANDROID_NDK_ROOT)
py scripts/quest.py [--scene res://...] [--engine=--verbose] [--no-deploy] [--no-open] [--no-log] [--unattended] [-- --xre-benchmark]  # шлем по USB: копирует проект, закрывает и открывает редактор, VR открывается сам (на сцене, если задана); лог в logs/quest_<время>.log; --unattended — прогоны ИИ, в шлеме автор или нет (D-161): датчик присутствия и Guardian выключены, лог сам останавливается после `graph lab: done`, затем оба включаются обратно
py scripts/quest_link.py on|off [--restore]|status  # только для прогонов ИИ (D-161): шлем в Link по кабелю и обратно через adb (Air Link в шлеме выключен); off --restore возвращает датчик и Guardian
scripts/build_gdextension.sh                  # собрать gdextension/ в addons/xr_editor/bin/ (редактор перед этим закрыть)
py scripts/build_engine.py tracy|perfetto|tools  # Godot 4.7.2 с профайлером (D-160): редактор Windows с Tracy, APK для Quest с Perfetto, инструменты разбора
py scripts/xr_editor.py --tracy [--tracy-delay S] [--tracy-sec S] [--unattended] ... -- --xre-graph-lab --xre-graph-lab-stress  # редактор с Tracy, запись на каждом шаге лаборатории; --godot PATH — любой другой бинарник; --unattended — прогоны ИИ (D-162): редактор закрывается после `graph lab: done` или `leaving for Compatibility`, через 240 с без строки лаборатории прогон бросается
py benchmarks/tracy_steps.py logs/editor_<рантайм>_<время>  # зоны движка и GDScript по шагам, мс на кадр
py benchmarks/tracy_process.py logs/editor_<рантайм>_<время> [--summary]  # что внутри `process`: по вложенности зон, части плагина и C++ узлов
py scripts/quest.py --perfetto [--install] [--perfetto-delay S] [--perfetto-sec S] [--perfetto-categories godot[,godot_scripting]] ... -- --xre-graph-lab --xre-graph-lab-base  # редактор с Perfetto на Quest (свой пакет рядом со Store), трасса на каждом шаге, по умолчанию только зоны движка (зоны GDScript ломают вложенность, D-162); --package NAME — другой пакет редактора
py benchmarks/perfetto_steps.py logs/quest_<время>  # то же для трасс Perfetto; подробности — docs/profiling_builds.md
```
