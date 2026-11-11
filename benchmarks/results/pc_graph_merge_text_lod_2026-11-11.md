# Луч, слияние, текст и детали по расстоянию: замеры ПК (2026-11-10…11)

Ветка `claude/graph-perf-merge-text-lod-6478fc`, записи [D-169](../../docs/decisions.md)…[D-172](../../docs/decisions.md). ПК с RTX 4060, сборка редактора с Tracy (D-160), шлема нет: `py scripts/xr_editor.py --runtime sim --hide-ui --unattended --tracy [--engine=--rendering-method --engine=mobile] res://benchmarks/play_check.tscn -- --xre-graph-lab …`. Руки симулятора неподвижны и направлены на граф. Сырые логи и таблицы — [raw_2026-11-10c](raw_2026-11-10c/).

**Миллисекунды ПК на Quest не переносятся.** Переносятся счётчики видимых вызовов, состав и доли. Окно ПК ограничено 165 Гц (6,05 мс кадра), поэтому `Main::iteration` и `RenderingServer::draw` сравнимы только там, где кадр дольше. Tracy ставит зону на каждый вызов GDScript и раздувает частые короткие функции. Числа разных дней сравнивать нельзя: в таблицах — одного сеанса.

## Шаг 1. Выбор лучом (D-169)

`--xre-graph-lab-base --xre-graph-lab-steps=closed,open,open_big2,open,open_big2`, 2026-11-10, `benchmarks/tracy_process.py`, мс на кадр (два шага через «/»):

| Forward+ | Each call + Script | Per frame + Script | Each call + Native | Per frame + Native |
|---|---|---|---|---|
| `process`, BlueCube | 1,744 / 1,753 | 1,643 / 1,681 | 1,727 / 1,467 | 1,357 / 1,364 |
| `process`, ×2 | 2,137 / 2,192 | 2,000 / 2,050 | 1,890 / 1,894 | 1,594 / 1,650 |
| `canvas.intersect_ray`, ×2 | 0,753 | 0,485 | 0,399 | 0,242 |
| расчётов за кадр | 4 | 2 | 4 | 2 |

Mobile, `process` ×2: 2,23–2,29 → 1,58–1,63 мс (Per frame + Native). Вызовы отрисовки не меняются.

## Шаги 2–3. Слияние частей и текста (D-170, D-171)

`--xre-graph-lab-base --xre-graph-lab-steps=closed,open,open_big2,open,open_big2`, 2026-11-11, видимые вызовы вида VR:

| | Mobile BlueCube | Mobile ×2 | Forward+ BlueCube | Forward+ ×2 |
|---|---|---|---|---|
| Per node, надписи (как раньше) | 318 | 580 | 350 | 635 |
| Ports merged (D-168) | 284 | 512 | 343 | 617 |
| Card merged (D-170) | 246 | 436 | 314 | 563 |
| Per node + Merged text (D-171) | 281 | 506 | 276 | 486 |
| Card merged + Merged text | **209** | **362** | 240 | 415 |

Tracy, Mobile, `draw_graph.end` BlueCube / ×2: 0,21 / 0,31–0,34 мс (Per node) → 0,17 / 0,26 (Card merged) → 0,16 / 0,21–0,23 (Card merged + текст). Страховка слияния `_merge_changed` — 0,06 мс на кадр, с надписями 0,07–0,09 (при закрытом графе 0,002). Перестройка BlueCube (`built in`, Mobile): 87 мс → 129 (Card merged) → 96 (текст) → 158 (оба).

Вид (GPU-тест `test_blueprint_render.gd`, 1024 × 768, разница больше 3/255 против Per node и надписей): Card merged — 1–13 пикселей, текст — 0–10 (до 13/255), оба — 3–14; допуск 16.

## Шаг 4. Детали по расстоянию (D-172)

`--xre-graph-lab-stress --xre-graph-lab-steps=open,open_big2,open_big4,open_graph100,open_graph250,open_graph500`, 2026-11-11. «Все новые» — By distance + Card merged + Merged text + Per frame + Native.

| Видимые вызовы | Mobile Full | Mobile By distance | Mobile все новые | Forward+ Full | Forward+ все новые |
|---|---|---|---|---|---|
| `open` (BlueCube) | 318 | 133 | 126 | 351 | 143 |
| `open_big2` | 580 | 190 | 180 | 636 | 205 |
| `open_big4` | 1104 | 319 | 301 | 1203 | 340 |
| `open_graph100` | 1104 | 319 | 301 | 1206 | 340 |
| `open_graph250` | 2676 | 57 | 57 | 2862 | 65 |
| `open_graph500` | 5295 | 56 | 56 | 5703 | 64 |

| Tracy, мс на кадр | Mobile Full | Mobile By distance | Mobile все новые | Forward+ Full | Forward+ все новые |
|---|---|---|---|---|---|
| `process` 100 / 250 / 500 | 2,46 / 4,14 / 7,56 | 2,05 / 3,03 / 4,66 | 1,38 / 2,00 / 3,17 | 2,60 / 4,20 / 8,73 | 1,45 / 1,96 / 3,29 |
| `draw_graph.end` 100 / 250 / 500 | 0,52 / 1,20 / 2,73 | 0,26 / 0,15 / 0,15 | 0,18 / 0,10 / 0,11 | 0,63 / 1,29 / 3,06 | 0,21 / 0,13 / 0,14 |
| `Main::iteration` 500 | 15,69 | 6,06 | 6,23 | 17,66 | 6,29 |
| `_apply_levels` 500 | — | 0,002 | 0,39 | — | 0,51 |

При кадрировании лаборатории голова дальше 2,4 м даже от BlueCube, и он теряет детали: 318 → 133 вызова. На 250–500 блоках почти всё уходит в L3 (один меш). Пороги — расчёт, их проверяет автор в шлеме.

## Что не измерено

- Всё на шлеме: GPU и fps, CPU по Perfetto, чёткость слитого текста, вид и переключение уровней. Команды — [quest_graph_performance.md](../../docs/quest_graph_performance.md), раздел «Прогоны луча, слияния, текста и деталей».
- GPU вида на ПК: время рендера вьюпорта в окне sim шумит сильнее разницы.
- Цена наведения при движущихся руках в лаборатории (руки неподвижны). По пробе в headless сведение одной карточки — 0,22 мс, раз на смену наведения; тест подтверждает, что без изменений пересведений нет.
- Сборка `Distant` на шлеме: в headless на ПК 5,5 мс на 424 плиты L3 с лентами, раз на 0,1 м сдвига головы.
- Переход сразу всех уровней при открытии большого графа: 211 мс на 500 блоков (headless).
