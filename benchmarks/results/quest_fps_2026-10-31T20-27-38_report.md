# Frame rate on the standalone headset, 2026-10-31T20-27-38

Source: `logs/quest_2026-10-31T20-27-38.log` (logcat via scripts/quest.py), Meta runtime counters (VrApi), from 10 s after each session reached FOCUSED until it lost focus or ended.

| process | seconds | display | fps mean | fps min | full-rate seconds | stale frames | app GPU ms | GPU % | CPU % | GPU level | memory PSS |
|---|---|---|---|---|---|---|---|---|---|---|---|
| editor | 7 | 72 Hz | 56.9 | 3 | 43 % | 131 | 10.72 | 48 | 50 | 2 | 2044 MiB |
| game res://benchmarks/graph_runtime_lab.tscn | 15 | 72 Hz | 69.9 | 52 | 80 % | 72 | 9.24 | 89 | 46 | 4 | 1208 MiB |
