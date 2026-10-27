# Структура репозитория

Вынесено из CLAUDE.md. Читать, когда нужно понять, где лежит модуль или тест.

```
addons/xr_editor/          плагин (всё, что поставляется)
  plugin.cfg, plugin.gd    точка входа EditorPlugin; владеет XREDocument
  core/                    XREDocument и его реализации; варианты фич для сравнения (XREFeatureSettings, D-039);
                           история шлема для отмены и повтора (XREHistory, D-087)
  xr/                      XR-сессия в процессе редактора (XRESession), риг (XRERig), контроллер: луч и кнопки (XREHand),
                           модель контроллера по профилю OpenXR с движущимися кнопками (XREControllerModel);
                           автономный шлем (D-018): общее для редактора и игры (XREStandalone), открыть VR из 2D-панели (XREStandaloneLauncher);
                           VR-вид без шлема в окне, клавиатура и мышь вместо контроллеров (XRESimulator, D-057)
  xr/controller_models/    glTF контроллеров из WebXR Input Profiles, папка на контроллер (D-010)
  tools/                   инструменты VR-слоя: манипуляция и удаление (XREManipulator), снап (XRESnap), обводка рёбер выбора и наведения (XREOutline, рёбра меша — XREEdgeMesh) с запасной рамкой (XREBoundsBox),
                           значки нод без геометрии — пока света (XREIcons), полёт и поворот стиками (XRELocomotion),
                           отмена и повтор кнопками A и B (XREUndo, D-087), шорткат выделенного объекта: удалить, копировать, переименовать, Blueprint (XREObjectShortcut, D-088, D-121),
                           счётчик выделенного на левой руке (XRESelectionCounter, D-123), буфер обмена на левой руке (XREClipboard, D-128)
  ui/                      меню в шлеме: палитра объектов в окне Objects (XREPalette, XREObjectsTab, D-045); кнопки на дуге поверх всего — шорткат объекта и меню провода (XREArcMenu, D-090); панели (XREPanels): хост с вводом от луча (XREPanelSurface),
                           лаунчер вкладок по X как Navigator Meta (XRETabLauncher, XRETabIcons, D-041, D-042), окна с угловыми ручками и Control Bar
                           с закреплением на руке (XREPanelWindow, D-040 — D-042), вкладки сцены, инспектора с прокси документа,
                           сигналов и файлов (XRE*Tab, XREInspectorProxy), настроек вариантов фич (XRESettingsTab), отладки — частота кадров (XREDebugTab); дальше — радиальное меню
  playmode/                запуск игры из шлема (XREPlayMode) и возврат из неё: автозагрузка XREReturnToEditor, работает только в игре;
                           экран загрузки на время перехода, общий для редактора и игры (XRETransitionScreen)
  telemetry/               замеры спайка: время кадра (XREFrameBenchmark), передача шлема игре (XREHandoffBenchmark)
  xr_editor.gdextension    подключение нативной библиотеки (Windows x86_64, Android arm64)
  bin/                     собранные библиотеки (не в git, собирает scripts/build_gdextension.sh [android])
addons/blueprints/         отдельный аддон Blueprints 2D (D-021): ресурс графа, компилятор GDScript, документ и плоский редактор; не зависит от XR.
                           С D-051: сигнатуры вызовов (XREBlueprintFunctions), глобальные функции (XREBlueprintGlobals), библиотека (XREBlueprintLibrary),
                           токен запуска (XREBlueprintRun), база действий (XREBlueprintActions) и меню добавления (XREBlueprintActionMenu);
                           операторы блока Operator — типы и вычисление (XREBlueprintOperators, D-065)
addons/xr_editor/logic_graph/ пространственные карточки и XR-адаптер общего документа Blueprints (D-025); окна Параметры, меню Add block и Tokens — вкладки окон панелей (XREBlueprintFormTab, D-044, D-051);
                           параметры в графе (D-052): фишки (XREBlueprintTokens, XREBlueprintTokenTray, XREBlueprintValuePanel), лепестки членов (XREBlueprintPetals), ящики переменных в графе (XREBlueprintBoxes, D-078); окно Vector с 3D-стрелками (XREBlueprintVectorTab, XREBlueprintVectorPanel, D-061);
                           окно Color — 2D-пикер или глобус цветов (XREBlueprintColorTab, XREBlueprintColorPanel, D-064), пипетка — цвет материала (XREBlueprintColorSampler);
                           ярлык объекта с пунктиром к нему: Blueprint в сцене, «+», корзина и × в графе (XREBlueprintBadge, D-085)
                           и её модель в руке вместо контроллера (XREBlueprintPipette, D-065);
                           прозрачность того, что заслоняет ввод (XREBlueprintFade, D-066);
                           фокусировка на карточке или ящике под лучом — светлее, остальное темнее или прозрачное (XREBlueprintFocus, D-072)
gdextension/               C++ (GDExtension): src/, godot-cpp/ (сабмодуль), thirdparty/openxr/
benchmarks/                эталонные сцены (empty, xr_view_check, xr_game_check — контрольная XR-игра, xr_handoff_game — игра для замера передачи,
                           manipulation_check — ручная проверка манипуляции в шлеме, play_check — ручная проверка play-mode),
                           frametime_report.py (отчёт по замеру), quest_fps_report.py (темп кадров на автономном шлеме по логу quest.py),
                           results/ (сырые CSV и отчёты замеров, в git)
project.godot              хост-проект для разработки (OpenXR и XR-шейдеры включены)
openxr_action_map.tres     action map по умолчанию, создан Godot (в редакторе не используется)
scripts/check.sh           проверка без шлема
scripts/parse_all.gd       загрузчик всех скриптов для check.sh
scripts/test_tools.gd      headless-тесты пикера, снапа, значков, манипуляции, палитры, удаления и полёта с фейковыми трекерами (для check.sh)
scripts/test_controller_model.gd  headless-тест выбора модели контроллера (для check.sh)
scripts/test_play_mode.gd  headless-тест play-mode: кнопка, возврат, аргументы игры (для check.sh)
scripts/test_panels.gd     headless-тест панелей: панель на руке, окна, вкладки, прокси инспектора (для check.sh)
scripts/test_simulator.gd  headless-тест VR-вида без шлема: клавиши и мышь → голова, руки, кнопки; раскладка NonVR (для check.sh)
scripts/test_history.gd    headless-тест истории шлема: шаги, отмена настроек и выделения, кнопки A и B (для check.sh)
scripts/test_inspector.gd  тест инспектора в шлеме внутри headless-редактора; плагин запускает его по `-- --xre-test-inspector` (для check.sh)
scripts/test_blueprints.gd        тесты графа, сохранения, undo/redo, компиляции и выполнения Blueprints (для check.sh)
scripts/test_blueprint_editor.gd  тест Blueprints внутри редактора: граф, назначение скрипта и история сцены (для check.sh)
scripts/test_blueprint_vr.gd      тест VR-графа в headless-редакторе с фейковыми контроллерами (для check.sh)
scripts/shot_blueprint_vr.gd      снимки графа с головы в обычном редакторе с GPU, без XR (D-056): build/shots/*.png
scripts/xr_extensions.py   расширения OpenXR-рантайма без шлема и без Godot
scripts/xr_editor.py       запуск редактора: сам выбирает рантайм со шлемом (SteamVR, Meta) или запуск без VR
scripts/quest.py           автономный шлем по USB (adb): копирует проект, открывает редактор в VR, показывает и пишет лог
.run/XR Editor.run.xml     конфигурация запуска Rider: scripts/xr_editor.py --fallback sim (без шлема — VR-вид в окне)
scripts/build_gdextension.sh  сборка нативной части: Windows (MSVC) или android (NDK); CMake и Ninja из Visual Studio
docs/                      план и дневник решений (на русском)
spikes/                    отдельные проекты спайков, не часть плагина (.gdignore): horizon_probe/ — редактор на Horizon OS (D-017), с сырыми логами
```

Модули по мере надобности — не заводить пустыми папками: в аддоне `logic_graph/`, `telemetry/`; в корне `study/` (протокол, анкеты, анализ).
