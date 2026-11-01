# Frame rate on the standalone headset, 2026-11-01T11-27-07

Source: `logs/quest_2026-11-01T11-27-07.log` (logcat via scripts/quest.py), Meta runtime counters (VrApi), from 10 s after each session reached FOCUSED until it lost focus or ended.

| process | seconds | display | fps mean | fps min | full-rate seconds | stale frames | app GPU ms | GPU % | CPU % | GPU level | memory PSS | editor loop fps | editor late frames / 5 s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| editor | 524 | 72 Hz | 61.3 | 7 | 22 % | 6911 | 13.69 | 90 | 34 | 4 | 2542 MiB | 60.9 | 1.1 |
