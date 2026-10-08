# Frame rate on the standalone headset, 2026-10-07T22-03-46

Source: `logs/quest_2026-10-07T22-03-46.log` (logcat via scripts/quest.py), Meta runtime counters (VrApi), from 10 s after each session reached FOCUSED until it lost focus or ended.

| process | seconds | display | fps mean | fps min | full-rate seconds | stale frames | app GPU ms | GPU % | CPU % | GPU level | memory PSS | editor loop fps | editor late frames / 5 s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| editor | 40 | 72 Hz | 68.2 | 6 | 80 % | 222 | 9.59 | 79 | 20 | 4 | 1887 MiB | 71.2 | 4.4 |
| game res://benchmarks/play_check.tscn | 2 | 72 Hz | 72.0 | 72 | 100 % | 2 | 10.17 | 88 | 5 | 4 | 618 MiB |  |  |
| editor | 45 | 72 Hz | 72.0 | 72 | 100 % | 1 | 8.83 | 76 | 15 | 2 | 1930 MiB | 71.9 | 0.0 |
