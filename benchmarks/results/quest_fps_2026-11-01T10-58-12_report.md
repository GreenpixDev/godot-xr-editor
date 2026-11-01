# Frame rate on the standalone headset, 2026-11-01T10-58-12

Source: `logs/quest_2026-11-01T10-58-12.log` (logcat via scripts/quest.py), Meta runtime counters (VrApi), from 10 s after each session reached FOCUSED until it lost focus or ended.

| process | seconds | display | fps mean | fps min | full-rate seconds | stale frames | app GPU ms | GPU % | CPU % | GPU level | memory PSS | editor loop fps | editor late frames / 5 s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| editor | 535 | 72 Hz | 62.5 | 3 | 21 % | 6337 | 13.55 | 91 | 29 | 4 | 2471 MiB | 62.3 | 1.0 |
