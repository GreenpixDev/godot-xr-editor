# Frame rate on the standalone headset, 2026-10-07T21-47-03

Source: `logs/quest_2026-10-07T21-47-03.log` (logcat via scripts/quest.py), Meta runtime counters (VrApi), from 10 s after each session reached FOCUSED until it lost focus or ended.

| process | seconds | display | fps mean | fps min | full-rate seconds | stale frames | app GPU ms | GPU % | CPU % | GPU level | memory PSS | editor loop fps | editor late frames / 5 s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| editor | 70 | 72 Hz | 61.3 | 39 | 43 % | 859 | 14.95 | 94 | 14 | 4 | 1903 MiB | 61.3 | 7.0 |
| game res://benchmarks/play_check.tscn | 42 | 72 Hz | 72.6 | 72 | 100 % | 0 | 8.78 | 75 | 5 | 2 | 598 MiB |  |  |
| editor | 63 | 72 Hz | 70.5 | 54 | 84 % | 180 | 10.64 | 85 | 14 | 4 | 1883 MiB | 69.0 | 0.4 |
