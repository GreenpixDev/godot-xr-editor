# Шлемы и ввод: что редактор может считать доступным

2026-10-05 · Steam Hardware Survey за сентябрь 2026, Khronos OpenXR Inventory (данные, которые присылают сами производители рантаймов), исходники Godot 4.7.2-stable (`modules/openxr`), документация производителей. Источники — в конце.

Документ отвечает на вопрос, какой ввод можно считать доступным на большинстве шлемов, чтобы на нём строить взаимодействие в редакторе. Объём он не расширяет: эксперимент идёт на одном шлеме (Quest 2 по Link), а поддержка других шлемов и трекинга рук не нужна для задач T1–T3. Речь о том, чтобы дизайн ввода не закрыл эту дорогу.

**Почему считаем по Steam, а не по мировым продажам.** Редактор — процесс Godot на Windows с OpenXR внутри. Пользователь автономного Quest без ПК его не запустит. Поэтому значимая аудитория — ПК-VR, а лучший доступный её срез — Steam Hardware Survey. У опроса есть известные сбои (резкие скачки в 2022 году), так что доли — ориентир, а не точное значение. Опрос считает шлемы, а не контроллеры: владелец старого Vive мог давно купить контроллеры Index.

## Кто в ПК-VR (Steam, сентябрь 2026)

Доля среди пользователей Steam с VR-шлемом (сами такие пользователи — 1,35% аудитории Steam).

| Семейство контроллеров | Шлемы и доли | Сумма |
| --- | --- | --- |
| Meta Touch (все поколения) | Quest 3 — 26,90; Quest 2 — 25,80; Quest 3S — 11,07; Rift S — 3,40; Rift — 1,80; Quest Pro — 1,53; Quest — 0,43 | **70,93%** |
| Index и шлемы Lighthouse без своих контроллеров | Index — 10,83; Bigscreen Beyond — 1,27; Pimax — 0,67 | **12,77%** |
| Pico | Pico 4 — 4,76; Neo 3 — 0,65; Neo 2 — 0,02 | **5,43%** |
| PS VR2 Sense | PS VR2 — 2,31 | **2,31%** |
| Прочие «как Touch» (HTC) | Vive Focus Vision — 0,26; XR Elite — 0,16; Cosmos — 0,16 | **0,58%** |
| Палочки Vive (без стика и кнопок) | Vive — 2,26; Vive Pro — 0,72; Vive Pro 2 — 0,58 | **3,56%** |
| Windows Mixed Reality | WMR — 1,85 (убита в Windows 11 24H2, работает только на 23H2 и Windows 10) | **1,85%** |
| Остальное | iVRy, Riftcat, PS VR, DK1/DK2, Varjo, «Other» | **2,56%** |

Steam Frame вышел в сентябре 2026 и своей строки в опросе ещё не получил. Samsung Galaxy XR в опросе тоже нет: на ПК он попадает только через Virtual Desktop или Steam Link.

## Контроллеры

Нажимаемые входы, доступные приложению, на пару контроллеров. Системную кнопку (Meta, Home, PS, Steam, Windows) всегда забирает рантайм, в счёт она не идёт.

| Контроллер | Стик | Тачпад | Лицевые кнопки | Меню для приложения | Триггер | Грип | Ёмкостные датчики | Кнопок на пару | Профиль OpenXR |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Meta Touch, Touch Plus (Quest 2/3/3S, Rift S) | ✓ + клик | — | 2 (A/B, X/Y) | только левый | аналог | аналог | кнопки, стик, триггер, упор для большого пальца | 11 | `oculus/touch_controller`, `meta/touch_controller_plus` |
| Touch Pro (Quest Pro) | ✓ + клик | — | 2 | только левый | аналог | аналог | то же + давление на упоре, наконечник-стилус | 11 | `facebook/touch_controller_pro` |
| Pico 4, 4 Ultra | ✓ + клик | — | 2 | только левый | аналог | аналог | стик, триггер, кнопки | 11 | `bytedance/pico4_controller`, `pico4s_controller` |
| PS VR2 Sense | ✓ + клик | — | 2 (△□ / ○×) | оба (Create / Options) | аналог | кнопка L1/R1 | касание пальцев | 12 | своего нет, SteamVR переназначает |
| Valve Index | ✓ + клик | ✓ (с силой нажатия) | 2 (A/B) | **нет** | аналог + клик | аналог + сила | все пять пальцев | 10 | `valve/index_controller` |
| Steam Frame | ✓ + клик | — | 4 (ABXY справа, крестовина слева) | оба (View / Menu) | аналог + клик | аналог + клик | все входы и рукоять | 18 | `valve/frame_controller_valve`; без него рантайм выдаёт себя за Touch |
| Палочки Vive | **нет** | ✓ + клик | **нет** | оба | аналог + клик | **цифровой** | только тачпад | 8 | `htc/vive_controller` |
| WMR | ✓ + клик | ✓ + клик | **нет** | оба | аналог | **цифровой** | только тачпад | 10 | `microsoft/motion_controller` |
| Galaxy XR (продаются отдельно, $250) | ✓ | — | 2 | — | аналог | аналог | заявлены | ≈ как Touch | нет данных |

Состав входов по профилям сверен с метаданными профилей в Godot 4.7.2 (`modules/openxr/action_map/openxr_interaction_profile_metadata.cpp` и `modules/openxr/extensions/*_controller_extension.cpp`). Строки про PS VR2 и Galaxy XR взяты из материалов производителей и обзоров, в OpenXR-метаданных их нет.

**Как рантаймы обходятся с чужими контроллерами.** Приложение предлагает привязки для одного-двух профилей, а рантайм переназначает их на реальный контроллер:

- SteamVR сам строит привязку для контроллера, которого приложение не знает, на основе привязки похожего контроллера. Например, аналоговый грип Touch он переносит на кнопку-грип WMR. Для Steam Frame Valve описывает порядок прямо: сначала ищется привязка к `khr/generic_controller`, затем к Touch.
- Рантайм Meta и Virtual Desktop (VDXR) понимают Touch напрямую.
- `khr/generic_controller` (2025) задуман как общий запасной профиль: триггер, грип, стик, две кнопки. Но в Khronos Inventory его пока не заявил ни один рантайм, включая Meta (PC) 1.205 и SteamVR 2.14. Опираться только на него рано.

Привязки к Touch, которые уже есть в `XREEditorControllers`, в принципе покрывают все шлемы выше через SteamVR. Как именно SteamVR раскладывает кнопки Touch на палочки Vive или Index, решает он сам. Это надо проверять на железе.

## Трекинг рук

| Шлем | Оптический трекинг на самом шлеме | На ПК через OpenXR | Условие на ПК |
| --- | --- | --- | --- |
| Quest 2 / 3 / 3S / Pro | ✓ | Link: `XR_EXT_hand_tracking`, `XR_EXT_hand_interaction`, `XR_META_simultaneous_hands_and_controllers` | Только с **Developer Runtime Features** в приложении Meta Horizon Link, а для этого нужен аккаунт разработчика. В обычном режиме рантайм Meta (PC) этих расширений не объявляет |
| | | Steam Link и SteamVR: `XR_EXT_hand_tracking` | SteamVR 2.8+ (с октября 2024); включается в настройках контроллеров SteamVR |
| | | Virtual Desktop (VDXR): `XR_EXT_hand_tracking` | С версии 1.30; VDXR при этом сообщает, что руки отслеживаются, даже когда в них контроллеры |
| Pico 4 / 4 Ultra | ✓ (на шлеме и `XR_EXT_hand_tracking`, и `XR_EXT_hand_interaction`) | через SteamVR (Pico Connect) | Не подтверждено: пользователи пишут, что положение рук приходит, а жесты пальцев — нет |
| Galaxy XR | ✓ (основной ввод, контроллеры опциональны) | через Virtual Desktop или Steam Link | Проброс рук на ПК не проверен |
| Vive Focus Vision, XR Elite | ✓ | через VIVE Streaming | Доля 0,4% |
| Index, Steam Frame | ✗ | SteamVR отдаёт `XR_EXT_hand_tracking`, но суставы берутся из ёмкостных датчиков контроллера (data source `CONTROLLER`) | Рука держит контроллер — щипок или жест в воздухе не распознать |
| Rift, Rift S, палочки Vive, WMR, PS VR2, Bigscreen Beyond | ✗ | — | — |

**Итого.** Железо с оптическим трекингом рук есть примерно у 71% ПК-VR (Quest 1/2/3/3S/Pro, Pico 4, Vive Focus Vision и XR Elite). Но ни один путь на ПК не даёт его без ручной настройки. Для основного пути — Quest по Link — трекинг закрыт режимом разработчика. Steam Frame, Index и PS VR2 трекинга рук не имеют совсем.

## Общий знаменатель

| Уровень | Что входит | Доля ПК-VR |
| --- | --- | --- |
| **A. Есть у всех контроллеров** | Поза головы; две позы на руку (grip и aim); аналоговый триггер; грип, но только как кнопка (у Vive и WMR он цифровой); одна 2D-ось (стик или тачпад); вибрация | ≈ 97% (всё, кроме «Остального») |
| **B. Почти у всех** | Плюс две лицевые кнопки на руку и клик стика | ≈ 92% (без Vive и WMR) |
| **C. У большинства** | Плюс кнопка меню, у Touch и Pico — только на левом контроллере | ≈ 85% (нет у Index и шлемов Lighthouse) |
| **Не база** | Ёмкостные касания, тачпад, сила нажатия, бампер и крестовина Frame, оптический трекинг рук, трекинг взгляда | у разных шлемов разное; руки на ПК по умолчанию — 0% |

## Что это значит для редактора

1. **Основной сценарий задач T1–T3 строится на уровне A плюс 3D-интерфейс.** Триггер — выбор и нажатие, грип — захват объекта и двуручный захват мира, луч от aim-позы. Всё остальное делается через палитру на недоминантной руке и контекстное меню у объекта.
2. **Кнопки уровня B — ускорители, а не единственный путь.** Undo, redo, снап-модификатор, телепорт и вызов радиального меню вешаются на лицевые кнопки и стик, но каждая команда дублируется кнопкой в палитре. Так редактор работает и на палочках Vive, и (в будущем) на руках.
3. **Кнопка меню — не единственный путь к чему-либо важному.** У Index её нет. У Touch и Pico она только на левом контроллере: левше с переставленной доминантной рукой меню достанется на рабочей руке.
4. **Один контроллер даёт 5 действий на руку** (две кнопки, клик стика, триггер, грип) плюс стик и меню. Это около 10 привязок на пару — потолок для «горячих клавиш». Остальное — в 3D-интерфейс.
5. **Аналоговость грипа не использовать как параметр** (например, сила захвата): у Vive, WMR и, судя по раскладке, PS VR2 грип — кнопка. Аналоговым можно считать только триггер.
6. **Ёмкостные датчики — только для подсказок** (например, подписать кнопку, когда на неё лёг палец), но не для действий.
7. **Трекинг рук — future work, но совместимость закладывается дизайном.** Профиль `ext/hand_interaction_ext` даёт aim-позу, щипок (`pinch_ext`, аналог триггера) и хват (`grasp_ext`, аналог грипа) — ровно уровень A без 2D-оси. Если основной сценарий держится на уровне A и 3D-интерфейсе, руки потом подключаются как ещё один набор привязок. Единственное, что придётся заменить, — действия на стике: радиальное меню и телепорт.

## Godot 4.7.2 и текущий код

- `XREEditorControllers` предлагает привязки для `oculus/touch_controller` и `khr/simple_controller`. Для Quest по Link этого хватает; на SteamVR и VDXR остальные контроллеры, скорее всего, заработают через переназначение (не проверено).
- Godot регистрирует обёртку трекинга рук, только если включена настройка `xr/openxr/extensions/hand_tracking`. По умолчанию она выключена (`main/main.cpp:2892`, регистрация — `modules/openxr/register_types.cpp:230`). Профиль `ext/hand_interaction_ext` запрашивается только при `xr/openxr/extensions/hand_interaction_profile` (тоже `false` и требует перезапуска). В нашем `project.godot` нет ни той, ни другой.
- Наш action set собственный (движок в редакторе action map не грузит), поэтому для рук ему понадобятся свои привязки к `ext/hand_interaction_ext`. Работает ли трекинг рук в процессе редактора вообще, не проверялось.

## Решения для дневника

Если вывод принимается, его стоит закрепить записью D-00x: «Базовый ввод — уровень A (поза, триггер, грип как кнопка, 2D-ось) плюс 3D-интерфейс; кнопки — ускорители; трекинг рук — future work, совместимость через `ext/hand_interaction_ext`». Основание — таблицы выше. На защите это ответ на вопрос «почему не руки» и «будет ли это работать не на Quest».

## Источники

- [Steam Hardware & Software Survey, сентябрь 2026 (VR Headsets)](https://store.steampowered.com/hwsurvey/Steam-Hardware-Software-Survey-Welcome-to-Steam); обзор месяца — [MIXED](https://mixed-news.com/en/steam-hardware-survey-september-2026-quest-3-pico-4-ps-vr2/); о сбоях опроса — [UploadVR, 2022](https://www.uploadvr.com/steam-hardware-survey-unreliable/)
- Khronos OpenXR Inventory: [матрица расширений](https://github.khronos.org/OpenXR-Inventory/runtime_extension_support.html), файлы `runtimes/meta_pc.json`, `meta_pc_dev_mode.json` (Oculus 1.205.0), `valve_steamvr.json` (SteamVR 2.14.4), `bytedance_pico_4_ultra.json`, `android_xr.json` в [репозитории](https://github.com/KhronosGroup/OpenXR-Inventory)
- Godot 4.7.2-stable: `modules/openxr/register_types.cpp`, `main/main.cpp`, `modules/openxr/action_map/openxr_interaction_profile_metadata.cpp`, `modules/openxr/extensions/` (`openxr_hand_tracking_extension.cpp`, `openxr_hand_interaction_extension.cpp`, `openxr_khr_generic_controller_extension.cpp`, `openxr_valve_controller_extension.cpp`, `openxr_pico_controller_extension.cpp`)
- Steam Frame: [Steamworks — Steam Frame Input](https://partner.steamgames.com/doc/steamhardware/steamframe/input), [Valve Unity OpenXR utils](https://github.com/ValveSoftware/Unity/blob/main/com.valvesoftware.openxr.utils/Documentation~/index.md), [Wikipedia](https://en.wikipedia.org/wiki/Steam_Frame), [PC Gamer, обзор](https://www.pcgamer.com/hardware/vr-hardware/valve-steam-frame-review/)
- Meta: [Touch Plus — справка](https://www.meta.com/help/quest/163579713458590/), [Touch Plus — OpenXR](https://developers.meta.com/horizon/documentation/native/pc/native-touch-plus-controllers); трекинг рук по Link только в режиме разработчика — [SenseGlove docs](https://unreal.docs.senseglove.com/2.7/getting-started/enabling-xr-ext-hand-tracking-vr-headsets/pcvr-mode/)
- SteamVR: [проброс трекинга рук Quest в Steam Link, SteamVR 2.8](https://roadtovr.com/valve-steam-link-quest-hand-tracking-2-8-release/); [автоматическое переназначение контроллеров](https://www.uploadvr.com/steamvr-automatic-controller-rebinding-update/)
- Virtual Desktop: [трекинг рук через VDXR](https://mixed-news.com/en/virtual-desktop-update-enables-quest-hand-tracking-on-pc-via-vdxr/)
- PS VR2: [раскладка Sense](https://www.techradar.com/news/psvr-2-controllers), [PS VR2 на ПК](https://www.playstation.com/en-gb/support/hardware/pc-ps-vr2-set-up/)
- Pico на ПК: [Pico Connect](https://mixed-news.com/en/pico-os-5-9-0-pico-connect/), [жесты не доходят через SteamVR](https://ask.vrchat.com/t/hand-tracking-with-pico-4-ultra-in-steamvr/42047)
- Galaxy XR: [контроллеры продаются отдельно](https://www.androidauthority.com/samsung-galaxy-xr-accessory-prices-3608962/), [ввод](https://www.androidcentral.com/gaming/virtual-reality/samsung-galaxy-xr)
- WMR: [удалена в Windows 11 24H2](https://www.uploadvr.com/windows-11-24h2-kills-windows-mr-support/)
