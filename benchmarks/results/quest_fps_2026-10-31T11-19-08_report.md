# Frame rate on the standalone headset, 2026-10-31T11-19-08

Source: `logs/quest_2026-10-31T11-19-08.log` (logcat via scripts/quest.py), Meta runtime counters (VrApi), from 10 s after each session reached FOCUSED until it lost focus or ended.

| process | seconds | display | fps mean | fps min | full-rate seconds | stale frames | app GPU ms | GPU % | CPU % | GPU level | memory PSS | editor loop fps | editor late frames / 5 s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| editor | 196 | 72 Hz | 52.8 | 7 | 2 % | 3980 | 13.84 | 81 | 38 | 4 | 2547 MiB | 51.8 | 74.4 |
