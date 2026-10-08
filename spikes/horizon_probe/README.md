# Спайк: редактор Godot в шлеме без ПК (Horizon OS)

Отдельный проект Godot — не часть плагина. Отвечает на вопрос: можно ли открыть редактор Godot 4.7.2 на Quest в окне с погружением (а не 2D-панелью) без форка движка и держать там XR-вид. Итог и числа — [D-017](../../docs/decisions.md); перенос плагина — D-018.

Основной проект его не видит (`spikes/.gdignore`).

## Состав

- `addons/horizon_probe/plugin.gd` — пробник. В редакторе на панели добавляет Project → Tools → «Horizon Probe: Open Editor in Immersive Mode»: `OS.create_instance(["--xr-mode", "on", "<путь>/project.godot"])`. В открытом так редакторе показывает 3D-сцену в шлеме и меряет темп кадров: четыре отрезка по 30 с ABBA, интерфейс редактора показан / спрятан. Лог — в Output (logcat, тег `godot`) и в `probe_logs/`.
- `addons/xre_native/xre_native.gdextension` — нативная библиотека плагина (`gdextension/`), собранная под Android arm64 (`scripts/build_gdextension.sh android`, затем `build_android.sh` копирует её сюда). Без неё — прогоны 1–4, с ней — 5–6.
- `probe_scene.tscn` — пол, три кубика и надпись.
- `results/` — сырые данные: `probe_logs/` (логи пробника с шлема) и выдержки logcat по прогонам (строки Godot, рантайма Meta `VrApi`, состояния сессии; ежекадровый шум движка `active_sets.is_empty()` вырезан, подряд идущие одинаковые строки свёрнуты).

## Прогоны (Quest 2, Horizon OS, редактор Godot 4.7.2 из Horizon Store)

| № | Дата | Что | Лог пробника | logcat |
|---|---|---|---|---|
| 1 | 2026-10-06 23:14 | без нативной части, Update Continuously выкл. | `immersive_2026-10-06T23-14-51` | `runs1-3_gdscript_only` |
| 2 | 23:22 | без нативной части, Update Continuously вкл. | `immersive_2026-10-06T23-22-02` | там же |
| 3 | 23:26 | то же; восстановилось после снятия шлема | `immersive_2026-10-06T23-26-00` | там же (буфер logcat начало потерял) |
| 4 | 23:34 | пробник v2: спрятан весь корневой вьюпорт — XR-вид пропал вместе с ним (ошибка пробника) | `immersive_2026-10-06T23-34-09` | `run4_probe_v2` |
| 5 | 2026-10-07 20:47 | с нативной частью; шлем снимали во время замера | `immersive_2026-10-07T20-47-47` | `run5_native_headset_removed` |
| 6 | 20:52 | с нативной частью, чистый прогон | `immersive_2026-10-07T20-52-39` | `run6_native_clean` |

## Повторить

1. `scripts/build_gdextension.sh android`, затем `spikes/horizon_probe/build_android.sh` (копирует библиотеку в пробник).
2. Скопировать папку на шлем (без `.godot/` и `probe_logs/`) в `/sdcard/Documents/Godot/horizon_probe` и открыть: `adb shell am start -a android.intent.action.VIEW -d file:///storage/emulated/0/Documents/Godot/horizon_probe/project.godot -n org.godotengine.editor.v4.meta/org.godotengine.editor.ProjectManager`.
3. В шлеме: Project → Tools → «Horizon Probe: Open Editor in Immersive Mode», шлем не снимать ~2,5 мин.
