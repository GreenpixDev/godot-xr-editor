# Инструкции для Codex и помощников проекта

VR-редактор сцен для Godot 4.7 в виде EditorPlugin, дипломная работа (2026–2027). Научный результат — паттерны взаимодействия и числа из эксперимента.

## Правка CLAUDE.md

Файл читается в каждой сессии: пиши без воды. Добавляй только то, что нужно почти всегда; остальное — в `docs/`, со ссылкой. Одна строка на правило, без обоснований и примеров. Состояние и история — в `docs/status.md` и `docs/decisions.md`.

## Документы

Читать по необходимости:

- [docs/plan.md](docs/plan.md) — источник истины: RQ1–RQ3, MVP, архитектура, T1–T3, сроки.
- [docs/decisions.md](docs/decisions.md) — дневник решений (D-001…).
- [docs/status.md](docs/status.md) — что сделано и проверено в шлеме.
- [docs/structure.md](docs/structure.md) — дерево репозитория.
- [docs/conventions.md](docs/conventions.md) — обоснования инвариантов и правил кода, подводные камни Godot 4.7.
- [docs/pitfalls.md](docs/pitfalls.md) — подводные камни OpenXR, Quest, SteamVR, Windows; читать перед работой с XR-сессией, нативной частью, play-mode.
- [docs/benchmarks.md](docs/benchmarks.md) — замеры кадра и прочие команды.
- [docs/vr_ui.md](docs/vr_ui.md) — термины интерфейса в шлеме.
- [docs/blueprints.md](docs/blueprints.md), [docs/blueprints_vr.md](docs/blueprints_vr.md), [docs/vr_feature_map.md](docs/vr_feature_map.md) — Blueprints и карта функций.

## Жёсткие ограничения

- Godot 4.7.x без обновлений (установлен 4.7.2: `godot` в Git Bash, `godot.cmd` в PowerShell, `%LOCALAPPDATA%\Programs\Godot\`). API 4.8+ не использовать.
- Объём: с 2026-10-21 проект — полноценный продукт, ограничение «только T1–T3» снято (остальные ограничения в силе).
- Движок не форкаем: нет хука — обход в GDScript/GDExtension, затем PR в upstream.
- Версии закреплены: godot-cpp 10.0.0-stable, OpenXR 1.1.54, MSVC 14.51, Android NDK r29 (29.0.14206865). Смена — запись в `docs/decisions.md`.
- Данные участников (аудио, анкеты, логи с идентификаторами) — только в `study/data/raw/` (в .gitignore), не в git.

## Архитектурные инварианты

Отступление — только с записью в `docs/decisions.md`. Обоснования — в [docs/conventions.md](docs/conventions.md).

1. Сцена меняется только через `XREDocument`; `EditorInterface`, `EditorUndoRedoManager` и запись в ноды сцены напрямую запрещены. Перетаскивание: `preview_transform` каждый кадр и один `commit_transform`.
2. VR-слой не попадает в .tscn: не под `get_edited_scene_root()`, без `owner`, на отдельном visual layer.
3. Один `World3D`: XR-`SubViewport` берёт `world_3d` вьюпорта редактора, копий нет.
4. Бюджет кадра 11,1 мс: в покадровом коде нет аллокаций, `get_node`, `find_child`, рейкастов по всей сцене.
5. Каждая операция логируется: тип, источник (3D-инструмент или 2D-панель), время.
6. Граф логики — `.tres` рядом со сценой, компилируется в читаемый `.gd`.
7. Вариант фичи — значение настройки `XREFeatureSettings.DEFINITIONS` (или новая настройка), меняется через `XREDocument.set_feature`; первый вариант — по умолчанию. Не ветка, не константа, не флаг. Каждый вариант покрыт тестом, в `decisions.md` — запись о сравнении.

## Команды

```bash
py scripts/xr_editor.py [--runtime auto|steamvr|meta|off|sim] [--fallback off|sim] [--no-restart] [сцена]  # редактор; sim — VR-вид в окне без шлема
scripts/check.sh                       # проверка без шлема, в конце `check: OK`
scripts/build_gdextension.sh [android] # нативная часть
py scripts/quest.py [--scene res://...] [--no-deploy]  # автономный шлем по USB
```

Подробности команд и остальные команды — в [docs/benchmarks.md](docs/benchmarks.md).

## Проверка

- После изменения GDScript — `scripts/check.sh` (до `check: OK`). После C++ — сначала `scripts/build_gdextension.sh` (без предупреждений /W4), затем `check.sh`.
- Открытый редактор перезапускать без вопроса: проверка в шлеме — `py scripts/xr_editor.py [сцена]`; перед `build_gdextension.sh` и `check.sh` редактор закрыть, после запустить. `--no-restart` — только по просьбе автора.
- Поведение в шлеме удалённо не проверить, `--runtime sim` его не заменяет. Для VR-изменений дай чек-лист: что запустить, что сделать, что должно произойти, что прислать. Не писать «работает» до подтверждения пользователя.
- Числа — только из замеров, не из оценок.

## Выбор инструментов

- Поиск символов и структуры — ast-index; если результата достаточно, другими инструментами не дублируй.
- Типы, ссылки, рефакторинг, диагностика — JetBrains MCP; передавай `projectPath` (или `rootFolder` `C:/Users/aniku/Projects/godot-xr-editor`). Для `.gd` диагностики IDE нет: ошибки показывает `scripts/check.sh`.
- Перед поиском после правок убедись, что индекс свежий: `ast-index watch` или `ast-index update`.
- CLI — через Bash Claude Code (хук RTK); в терминале IDE — `rtk` явно. Полный git diff — `rtk bypass git diff`.
- Перед правкой читай точный участок исходника, не сводку.
- Документацию библиотек, SDK, API и CLI берёт Context7 (`resolve-library-id` → `query-docs`, один вопрос на тему), не память и не веб-поиск. Не для рефакторинга и общих понятий.
- Приложения сам не запускай: давай эквивалент конфигурации `.run/*.run.xml` блоком `bash` (одна команда на блок, есть кнопка Run); нет конфигурации — предложи создать. По просьбе запускай через конфигурацию IDE (JetBrains MCP: `get_run_configurations`, `execute_run_configuration`).
- Python — `py`, не `python`/`python3`; многострочный код — через файл, не heredoc.

## Код

- GDScript 4.7, `@tool` на каждом скрипте аддона (исключение — `playmode/return_to_editor.gd`).
- Типизация обязательна: `untyped_declaration`, `unsafe_property_access`, `unsafe_method_access` — ошибки.
- Глобальные классы с префиксом `XRE`; файлы snake_case; отступы табами.
- Код, комментарии, коммиты — на английском; `docs/` и общение — на русском.
- `##` doc-комментарии на публичных классах и методах.
- Сигналы из `_enter_tree` отключать в `_exit_tree`.
- C++ (`gdextension/src/`): C++17, стиль движка (`p_`, `r_`), классы в ClassDB с префиксом `XRE`, покадровый код не аллоцирует.
- Подводные камни Godot 4.7 — в [docs/conventions.md](docs/conventions.md).

## Дневник решений

Решение, которое пришлось бы объяснять на защите (выбор API, отказ от подхода, результат спайка, обход движка), — новая запись в `docs/decisions.md` по шаблону. Старые не переписываются: пересмотр — новая запись со ссылкой.
