# Frame rate on the standalone headset, 2026-10-31T19-33-37

Source: `logs/quest_2026-10-31T19-33-37.log` (logcat via scripts/quest.py), Meta runtime counters (VrApi), from 10 s after each session reached FOCUSED until it lost focus or ended.

| process | seconds | display | fps mean | fps min | full-rate seconds | stale frames | app GPU ms | GPU % | CPU % | GPU level | memory PSS | editor loop fps | editor late frames / 5 s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| editor | 437 | 72 Hz | 57.5 | 3 | 19 % | 7258 | 14.66 | 88 | 50 | 4 | 2849 MiB | 57.3 | 19.3 |
