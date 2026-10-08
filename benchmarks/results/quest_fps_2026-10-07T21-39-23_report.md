# Frame rate on the standalone headset, 2026-10-07T21-39-23

Source: `logs/quest_2026-10-07T21-39-23.log` (logcat via scripts/quest.py), Meta runtime counters (VrApi), from 10 s after each session reached FOCUSED until it lost focus or ended.

| process | seconds | display | fps mean | fps min | full-rate seconds | stale frames | app GPU ms | GPU % | CPU % | GPU level | memory PSS | editor loop fps | editor late frames / 5 s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| editor | 86 | 72 Hz | 39.2 | 32 | 0 % | 2943 | 22.71 | 99 | 10 | 4 | 1906 MiB | 38.7 | 193.0 |
| game res://benchmarks/play_check.tscn | 57 | 72 Hz | 72.7 | 72 | 100 % | 0 | 8.95 | 76 | 6 | 2 | 621 MiB |  |  |
| editor | 77 | 72 Hz | 39.3 | 29 | 0 % | 2625 | 22.20 | 97 | 10 | 4 | 1969 MiB | 39.1 | 195.0 |
