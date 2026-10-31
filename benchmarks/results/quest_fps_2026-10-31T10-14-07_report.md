# Frame rate on the standalone headset, 2026-10-31T10-14-07

Source: `logs/quest_2026-10-31T10-14-07.log` (logcat via scripts/quest.py), Meta runtime counters (VrApi), from 10 s after each session reached FOCUSED until it lost focus or ended.

| process | seconds | display | fps mean | fps min | full-rate seconds | stale frames | app GPU ms | GPU % | CPU % | GPU level | memory PSS | editor loop fps | editor late frames / 5 s |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| editor | 206 | 72 Hz | 60.0 | 3 | 41 % | 2975 | 13.13 | 80 | 33 | 4 | 2771 MiB | 60.0 | 32.6 |
