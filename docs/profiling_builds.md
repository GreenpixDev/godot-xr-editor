# Сборки движка с профайлером: шаги 1.5 и 1.6

Инструкция для прогонов шагов 1.5 (Tracy, ПК) и 1.6 (Perfetto, Quest) плана [performance_plan.md](performance_plan.md). Решение и отличия от официальной сборки — [D-160](decisions.md). Остальные правила замеров — в [quest_graph_performance.md](quest_graph_performance.md) (обрезка логов, сверка вида, порядок прогонов).

## Что где лежит

Всё вне репозитория, в `%LOCALAPPDATA%\xre` (переопределяется `XRE_ENGINE_DIR`):

| Путь | Что |
|---|---|
| `godot\` | исходник Godot 4.7.2-stable (`ed1daf0bf`), не изменён: `build_engine.py` отказывается собирать, если отслеживаемые файлы отличаются от тега |
| `godot\bin\godot.windows.editor.x86_64.console.exe` | редактор с Tracy (1.5); рядом `.exe` и `.pdb` |
| `godot\bin\android_editor_builds\android_editor-horizonos-release-perfetto.apk` | редактор для Quest с Perfetto (1.6), пакет `org.godotengine.editor.v4.meta.release` |
| `tracy-0.14.1\` | исходник клиента Tracy, вкомпилирован в движок |
| `tracy-0.14.1-windows\` | `tracy-profiler.exe` (окно), `tracy-capture.exe`, `tracy-csvexport.exe` той же версии |
| `perfetto-v58.2-windows\` | `trace_processor_shell.exe` для разбора трасс на ПК |

На этой машине стоит только Visual Studio 18 Insiders (MSVC 14.51), а SCons ищет компилятор через `vswhere` без `-prerelease` и предварительную версию не видит. Поэтому `build_engine.py` запускает SCons через обёртку, которая добавляет `-prerelease` к этому запросу; исходник движка и его скрипты сборки не меняются.

Собрать заново или докачать инструменты (редактор Windows с нуля собрался за ~15 минут на Ryzen 7 5700X; сборки идут по одной: дерево исходников общее):

```bash
py scripts/build_engine.py tracy
```

```bash
py scripts/build_engine.py perfetto
```

```bash
py scripts/build_engine.py tools
```

## 1.5. Tracy на ПК

### Как устроено

- Сборка с `TRACY_ON_DEMAND`: движок пишет зоны, только пока подключён `tracy-capture`. `xr_editor.py --tracy` подключает его на каждом шаге лаборатории: через `--tracy-delay` с (по умолчанию 3) после строки `graph lab: <шаг>`, на `--tracy-sec` с (по умолчанию 5). Файлы: `logs/editor_<рантайм>_<время>_tracy_<n>_<шаг>.tracy`.
- Зоны: движок (`GodotProfileZone`: `Main::iteration`, рендер, сцена…) и **каждый вызов функции GDScript** с файлом и строкой, а также вызовы методов движка из скрипта (их время приписано вызывающему файлу).
- Разбор — после прогона: `benchmarks/tracy_steps.py` выгружает зоны `tracy-csvexport` и печатает по каждому шагу: кадры и средний `Main::iteration`; собственное время по областям (скрипты плагина, другие скрипты, `servers/rendering`, `scene`, `editor`…); топ зон по собственному времени; GDScript по файлам. Считается только главный поток (поток с `Main::iteration`). Все времена — мс на кадр.
- Выборка стека (sampling) работает, только если редактор запущен от администратора, и в CSV не попадает. Для чисел запускать **не** от администратора; от администратора — только чтобы посмотреть C++ без зон в окне `tracy-profiler.exe`.

### Известное поведение сборки

- **При закрытии редактор падает** (`FATAL: Condition "!is_main_thread_assigned.clear_if_set()"` в `Thread::release_main_thread`, код выхода 3), в том числе после `--version`. Записи и лог к этому моменту готовы, на данные не влияет. Официальная сборка (MinGW) так не падает. Причина не установлена; гипотеза — порядок инициализации `thread_local Thread::caller_id` у MSVC.
- Запись, начатая внутри одного длинного кадра (построение графа на 250–500 блоков длится больше секунды), не содержит ни одного целого `Main::iteration`; `tracy_steps.py` так и пишет. При задержке по умолчанию (3 с) такого не было; с `--xre-lab-fast` (шаги по 1 с) — было.
- Проверено 2026-11-10 без окна (`--runtime sim --engine=--headless`, `--xre-lab-fast`, запись 0,5 с с 0,2 с): все 14 шагов `stress` записаны, функции плагина (`blueprint_canvas.gd`, `session.gd`, `hand.gd`…) в таблицах есть. Время рендера в таком прогоне нулевое (рендер фиктивный), поэтому числа из него не берутся.

### Ограничения чисел

- Зона на каждый вызов GDScript и на каждый вызов движка из скрипта стоит времени даже без подключения (поиск источника на каждый вызов). Часто вызываемые короткие функции раздуваются сильнее всего. Числа Tracy сравнивать только с числами Tracy; абсолютное время кадра — из прогонов без профайлера.
- Компилятор MSVC, а не MinGW GCC, как у официальной сборки ([D-160](decisions.md)): та же причина.
- Накладные расходы оценивает прогон 3 ниже.

### Прогоны

Перед прогонами `scripts/build_gdextension.sh` не нужен: плагин тот же. Редактор, открытый на проекте, скрипт закроет сам. Шлем по Link или окно sim — как решит автор; команды ниже этого не выбирают.

1. Стресс-прогон (около 2,5 мин, 14 шагов по 10 с), заодно проверка записи:

```bash
py scripts/xr_editor.py --tracy --fallback sim --hide-ui res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress
```

После `graph lab: done` закрыть редактор. На каждом шаге должна появиться строка `xr_editor: tracy: logs/..._tracy_NN_<шаг>.tracy`. Затем:

```bash
py benchmarks/tracy_steps.py logs/editor_<рантайм>_<время>
```

В таблицах должны быть зоны `res://addons/xr_editor/...`. Если в шаге «No Main::iteration zones» — запись не подключилась (порт 8086 занят другим процессом с Tracy?).

2. База, как для 1.1 на ПК (шаги по 10 с, запись 5 с с третьей секунды):

```bash
py scripts/xr_editor.py --tracy --fallback sim --hide-ui res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-base
```

Во второй половине `base` лаборатория открывает новый редактор на Compatibility (`OS.create_instance`; первый не закрывается). Новый процесс — та же сборка с Tracy, но его строки могут не дойти до `xr_editor.py`; тогда шагов `compat_*` в записи не будет — так и записать. Не проверено. После прогона закрыть все окна редактора.

Сравнить зоны по шагам (имена зон — из первой таблицы):

```bash
py benchmarks/tracy_steps.py logs/editor_<рантайм>_<время> --zone Main::iteration --zone face_user
```

3. Накладные расходы: тот же `stress` на сборке с Tracy без записи и на официальной сборке, fps и время кадра — из строк `graph lab: frames …` лога (как в [lab_pc_link_2026-11-09.md](../benchmarks/results/lab_pc_link_2026-11-09.md)):

```bash
py scripts/xr_editor.py --godot "$LOCALAPPDATA/xre/godot/bin/godot.windows.editor.x86_64.console.exe" --fallback sim --hide-ui res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress
```

```bash
py scripts/xr_editor.py --fallback sim --hide-ui res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress
```

Команда для Git Bash; в PowerShell путь пишется `"$env:LOCALAPPDATA\xre\godot\bin\godot.windows.editor.x86_64.console.exe"`.

### Что прислать или записать

- Пути логов и папку `.tracy` каждого прогона; вывод `tracy_steps.py` в `benchmarks/results/lab_tracy_<дата>.md` с командой, железом и рантаймом в шапке.
- Ответы на вопросы шага 1.5: сколько на кадр стоят скрипты плагина и какие функции; сколько — редактор Godot (`editor/`); сколько — подготовка отрисовки (`servers/rendering`); что растёт с размером графа и сцены (`stress`). Это вход для шагов 2.1 и этапа 4.
- Отношение кадра Tracy-сборки без записи к официальной (прогон 3).

## 1.6. Perfetto на Quest

Шаг плана — только если 1.1–1.5 не объяснят CPU на Quest.

### Как устроено

- Сборка с `profiler=perfetto`: движок пишет те же зоны (категории `godot` и `godot_scripting`, у функций GDScript — аргументы «source file» и «line number») в системный сервис трассировки Android. В трассу они попадают, только пока она пишется.
- **`quest.py` по умолчанию пишет только категорию `godot`** (зоны движка): зоны GDScript в 4.7.2 ломают вложенность всех зон ([D-162](decisions.md)). `--perfetto-categories godot,godot_scripting` их возвращает, но тогда верно только число вызовов, а не времена.
- Пакет `org.godotengine.editor.v4.meta.release` ставится рядом с редактором из Store, тот не трогается. Проект в `/sdcard/Documents/Godot` общий; настройки редактора у пакета свои.
- `quest.py --perfetto` ставит APK, если его нет в шлеме (`--install` — поставить заново), выдаёт ему доступ ко всем файлам (`appops … MANAGE_EXTERNAL_STORAGE allow`), копирует проект, открывает редактор этого пакета и на каждом шаге лаборатории пишет трассу: через `--perfetto-delay` с (3) на `--perfetto-sec` с (3). Файлы: `logs/quest_<время>_perfetto_<n>_<шаг>.pftrace`. Перед первой трассой: `logs/quest_<время>_perfetto_info.txt` — конфиг и вывод `perfetto --query` (какие источники данных есть в шлеме, подключён ли процесс Godot).
- В трассе кроме зон: переключения потоков и частоты CPU и GPU (ftrace), стадии и счётчики GPU (`gpu.renderstages.oculus`, `gpu.counters.oculus`). Стадии GPU Quest 2 отдаёт только в подробном режиме — вместе с `--gpu-profile` (+~10 % к GPU).
- Разбор: `benchmarks/perfetto_steps.py` — те же таблицы, что у Tracy: поток с `Main::iteration` (на Android это поток рендера, не главный поток Java), топ зон по собственному времени, GDScript по файлам. Трассу целиком смотреть в https://ui.perfetto.dev или в MQDH.

### Прогоны

`scripts/build_gdextension.sh android` — если нативная часть менялась после последней сборки под Android.

1. Стресс-прогон, заодно проверка (первый запуск нового пакета: в шлеме могут спросить разрешения — разрешить; если редактор не видит проект, открыть его в менеджере проектов один раз руками):

```bash
py scripts/quest.py --perfetto --scene res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress
```

После `graph lab: done` — Ctrl+C. Затем:

```bash
py benchmarks/perfetto_steps.py logs/quest_<время>
```

В таблицах должны быть зоны `Main::iteration` и функции с файлами `res://addons/xr_editor/...`. Если в шагах «No Main::iteration slices» — зоны движка не дошли до сервиса трассировки: посмотреть `_perfetto_info.txt` (есть ли `track_event` от процесса `org.godotengine.editor.v4.meta.release`) и сообщить автору, сборку не менять.

2. База:

```bash
py scripts/quest.py --perfetto --scene res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-base
```

С трассами стадий GPU (подробный режим профилировщика GPU, сравнивать только внутри прогона):

```bash
py scripts/quest.py --perfetto --gpu-profile --scene res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-base
```

3. Накладные расходы: та же сборка без трасс и редактор из Store, App и fps из строк VrApi (`benchmarks/quest_lab_steps.py`):

```bash
py scripts/quest.py --package org.godotengine.editor.v4.meta.release --scene res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-base
```

```bash
py scripts/quest.py --scene res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-base
```

Остановка: `adb shell am force-stop org.godotengine.editor.v4.meta.release`.

### Что прислать или записать

- Логи, `.pftrace`, `_perfetto_info.txt`; вывод `perfetto_steps.py` в `benchmarks/results/lab_perfetto_<дата>.md`.
- CPU на Quest по функциям: плагин, редактор Godot, рендер — по шагам `base`; сравнение с ПК (1.5).

## Что проверено при подготовке (2026-11-10)

- Редактор с Tracy собран и работает; запись по шагам и `tracy_steps.py` проверены прогоном без окна (выше).
- APK собран (160 МБ): пакет `org.godotengine.editor.v4.meta.release`, версия `4.7.2.stable-meta`, только `arm64-v8a`, подпись Android Debug, не отладочный; внутри `libgodotopenxrvendors.so` (плагин вендора) и `libgodot_android.so` со строками Perfetto и категорией `godot_scripting`.
- Конфиг трассы из `quest.py` принят `perfetto` v58.2 (запись 1 с через локальный `traced` на ПК); `perfetto_steps.py` проверен на синтетической трассе с зонами и на пустой.

## Проверка со шлемом (2026-11-10, Quest 2, Android 14)

Быстрые прогоны `stress` с `--xre-lab-fast` (шаги по 1 с, записи 0,5–0,6 с) — проверка цепочки, не замер.

- **ПК, Tracy, окно sim (Forward+ на Vulkan):** все 14 шагов записаны; средний `Main::iteration` сходится с fps лога (6,05 мс при 164 fps), вложенность цела, функции плагина и рендер разложены. Лог `logs/editor_sim_2026-11-10T10-18-14.log`.
- **Quest, Perfetto:** APK ставится рядом с редактором из Store, проект открывается без ручных шагов, лаборатория доходит до `done`. Зоны движка и функции GDScript (с файлом в «Source») доходят до трассы. Лог `logs/quest_2026-11-10T10-14-45.log`.
- **Quest, Perfetto — вложенность зон сломана.** `Main::iteration` в трассе длится в среднем 2 мс при шаге между кадрами 17 мс и лежит на глубине 1, сотни других слайсов висят на верхнем уровне. Собственное время и «мс на кадр» из `perfetto_steps.py` поэтому неверны; число вызовов — верно. Вероятная причина — движок 4.7.2: в `PerfettoScriptTracer` поле `bool tracing;` не инициализировано (`core/profiling/profiling.h:145`), и лишний `TRACE_EVENT_END` закрывает чужой слайс. Решение — писать только зоны движка ([D-162](decisions.md)); с ним вложенность верна.
- **`traced_chunks_discarded`** растёт на 1 с каждой трассой: это счётчик службы за всё время её работы, а не потеря этой трассы. `perfetto_steps.py` его больше не считает потерей (D-162).
- **Источники GPU** на Quest 2 называются `gpu.renderstages.oculus` и `gpu.counters.oculus` и появляются только в подробном режиме `ovrgpuprofiler`, то есть вместе с `--gpu-profile`.
- Каждая трасса занимает около 2 с (запуск, запись, `adb pull`): при шагах по 10 с это не мешает, при 1 с часть шагов пропускается.
- Ошибка разбора `hand_panel.gd:51` (`get_icon_name()` на `XREPanelTab`) в логе шлема — старая, есть в логах с 2026-11-01 и с редактором из Store.

## Прогоны без автора (2026-11-10)

Итоги и таблицы — [lab_profilers_2026-11-10.md](../benchmarks/results/lab_profilers_2026-11-10.md), решение — [D-162](decisions.md). Порядок (D-161): Quest с выключенным Link, затем `quest_link.py on`, прогоны ПК, `quest_link.py off --restore`.

```bash
py scripts/quest.py --unattended --perfetto --scene res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress
```

```bash
py scripts/xr_editor.py --runtime meta --hide-ui --unattended --tracy res://benchmarks/play_check.tscn -- --xre-graph-lab --xre-graph-lab-stress
```

- `quest.py --unattended` будит шлем, закрывает оба редактора, лог закрывается после `done`; `xr_editor.py --unattended` закрывает редактор после `done` или `leaving for Compatibility`. Оба бросают прогон после 240 с без строки лаборатории.
- На Quest шаги `compat_*` записываются: поток кадра — `GLThread` нового процесса. На ПК `base` кончается на `leaving for Compatibility`: второй экземпляр редактора там не проверен, а `tracy-capture` подключился бы к первому.
- Шаг `open_graph500` с задержкой 3 с на Quest не попадает в трассу: построение графа (3,9 с) и следующий кадр (~1 с) занимают окно.

## Не проверено

- Шаги `compat_*` во второй половине `base` на ПК.
- Трасса Perfetto вместе с `--gpu-profile` (стадии GPU на одной шкале с зонами).
