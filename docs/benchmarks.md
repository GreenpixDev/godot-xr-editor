# Замеры кадра

Вынесено из AGENTS.md.

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
godot --path . --editor --xr-mode off --log-file logs/shots.log res://benchmarks/play_check.tscn -- --xre-shot-blueprint-vr  # снимки графа GreenCube с головы в build/shots/ (с сохранёнными настройками Features), редактор закрывается сам
py scripts/xr_editor.py [сцена] -- --xre-session-frames  # покадровый замер (CPU, GPU) каждого отрезка, пока шлем у редактора: до игры и после каждого возврата; CSV в benchmarks/results/
```

## Подробности основных команд

```bash
py scripts/xr_editor.py [--runtime auto|steamvr|meta|off|sim] [--fallback off|sim] [--check] [--no-restart] [сцена] [-- --xre-benchmark]  # редактор: в VR на рантайме, который видит шлем, иначе без VR; sim — VR-вид в окне без шлема (D-057), --fallback sim — он же, если ни один рантайм не видит шлем; уже открытый на проекте редактор сам закрывает и запускает заново; лог в logs/editor_<рантайм>_<время>.log
scripts/check.sh                              # все скрипты парсятся и типизированы, headless-тесты инструментов, панелей, моделей контроллеров и play-mode проходят, нативная библиотека и плагин грузятся в headless-редакторе, инспектор в шлеме работает в нём
scripts/build_gdextension.sh android          # нативная часть под Android arm64 для автономного шлема (NDK 29.0.14206865 в %LOCALAPPDATA%\Android\Sdk\ndk или ANDROID_NDK_ROOT)
py scripts/quest.py [--scene res://...] [--engine=--verbose] [--no-deploy] [--no-open] [--no-log] [-- --xre-benchmark]  # шлем по USB: копирует проект, закрывает и открывает редактор, VR открывается сам (на сцене, если задана); лог в logs/quest_<время>.log
scripts/build_gdextension.sh                  # собрать gdextension/ в addons/xr_editor/bin/ (редактор перед этим закрыть)
```
