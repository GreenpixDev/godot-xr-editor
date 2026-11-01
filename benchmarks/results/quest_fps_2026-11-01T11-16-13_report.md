# Frame rate on the standalone headset, 2026-11-01T11-16-13

Source: `logs/quest_2026-11-01T11-16-13.log` (logcat via scripts/quest.py), Meta runtime counters (VrApi), from 10 s after each session reached FOCUSED until it lost focus or ended.

| process | seconds | display | fps mean | fps min | full-rate seconds | stale frames | app GPU ms | GPU % | CPU % | GPU level | memory PSS | editor loop fps | editor late frames / 5 s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| editor | 518 | 72 Hz | 61.4 | 7 | 16 % | 6625 | 13.40 | 92 | 35 | 4 | 2502 MiB | 61.5 | 0.8 |
