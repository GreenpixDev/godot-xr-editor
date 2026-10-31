# Frame rate on the standalone headset, 2026-10-31T20-37-29

Source: `logs/quest_2026-10-31T20-37-29.log` (logcat via scripts/quest.py), Meta runtime counters (VrApi), from 10 s after each session reached FOCUSED until it lost focus or ended.

| process | seconds | display | fps mean | fps min | full-rate seconds | stale frames | app GPU ms | GPU % | CPU % | GPU level | memory PSS |
|---|---|---|---|---|---|---|---|---|---|---|---|
| editor | 6 | 72 Hz | 44.8 | 3 | 33 % | 175 | 8.82 | 43 | 58 | 4 | 2169 MiB |
| game res://benchmarks/graph_runtime_lab.tscn | 167 | 72 Hz | 64.8 | 30 | 69 % | 1489 | 12.36 | 85 | 39 | 4 | 1179 MiB |
