#!/usr/bin/env python3
"""Copies this spike to a standalone headset over USB and opens it in the Godot
editor's panel there; Play in that panel runs it in the headset as a game.
This closes the Godot editor in the headset, without saving.

Usage: py spikes/comp_layer/deploy_quest.py
Standard library only.
"""

from __future__ import annotations

import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent.parent / "scripts"))
import quest  # noqa: E402

FILES = ("project.godot", "main.tscn", "probe.gd")
REMOTE = f"{quest.REMOTE_PARENT}/comp_layer"
PROJECT_FILE = "file:///storage/emulated/0/Documents/Godot/comp_layer/project.godot"


def main() -> int:
    path = quest.find_adb()
    if path is None:
        print("deploy_quest: adb not found", file=sys.stderr)
        return 1
    adb = quest.Adb(path)
    quest.check_headset(adb)
    adb.shell(f"mkdir -p '{REMOTE}'")
    for name in FILES:
        adb.run("push", str(HERE / name), f"{REMOTE}/{name}")
    adb.shell(f"am force-stop {quest.PACKAGE}")
    adb.shell(f"am start -a android.intent.action.VIEW -d '{PROJECT_FILE}' -n {quest.PROJECT_MANAGER}")
    print("deploy_quest: opened in the headset; press Play in the editor's panel")
    return 0


if __name__ == "__main__":
    sys.exit(main())
