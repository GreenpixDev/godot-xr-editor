# Frame rate on the standalone headset, 2026-10-31T10-33-08

Source: `logs/quest_2026-10-31T10-33-08.log` (logcat via scripts/quest.py), Meta runtime counters (VrApi), from 10 s after each session reached FOCUSED until it lost focus or ended.

| process | seconds | display | fps mean | fps min | full-rate seconds | stale frames | app GPU ms | GPU % | CPU % | GPU level | memory PSS | editor loop fps | editor late frames / 5 s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| editor | 55 | 72 Hz | 45.7 | 4 | 2 % | 1725 | 15.99 | 77 | 35 | 4 | 2458 MiB | 46.7 | 109.2 |
| editor | 158 | 72 Hz | 52.0 | 5 | 35 % | 3556 | 13.71 | 78 | 32 | 4 | 2536 MiB | 53.3 | 97.8 |
