#!/usr/bin/env python3
"""Puts a Quest connected to this PC by USB into Link and back, over adb, for runs nobody
watches in the headset (D-161). Not for the Rider configurations: they leave the headset as it is.

  on      The proximity sensor and Guardian off (the headset lies on a desk awake, without a
          boundary setup), the Link service and its dialogs closed, the headset's USB reconnected
          (svc usb resetUsbGadget, as a cable pulled and plugged back; adb is gone for a second).
          The Link service then shows "Enable Link?"; its primary button is tapped where
          uiautomator puts it. Done when the headset's log shows frames from the PC and the Meta
          service's log on this PC a new session.
  off     The Link service stopped: the headset is standalone again. The sensor and Guardian
          stay off for the run that follows (quest.py --unattended); --restore turns them on.
  status  The headset's top activity, USB functions, Guardian pause and whether Link streams.

Needs Air Link off in the headset (otherwise the service connects over Wi-Fi with no dialog),
the Meta Horizon Link app on this PC, and the PC trusted by the headset once.

Usage: py scripts/quest_link.py on|off|status [--restore]
Standard library only.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
import time
from pathlib import Path

import quest

LINK_SERVICE = quest.LINK_SERVICE
DIALOG = "OculusLinkAvailableDialogActivity"
STREAMING = f"{LINK_SERVICE}/com.oculus.xrstreamingclient.MainActivity"
PRIMARY_BUTTON = f"{LINK_SERVICE}:id/oc_dialog_primary_button"
UI_DUMP = "/sdcard/xre_link_ui.xml"
NODE = re.compile(r"<node [^>]*>")
BOUNDS = re.compile(r'bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"')
FRAME = re.compile(r"Frames: .*?frame=\[(-?\d+),(-?\d+)\]")
# The Meta service's line when a Link session starts on this PC.
PC_SESSION = re.compile(r"New session started in wireless mode: (\d)")
PC_LOGS = Path(os.environ.get("LOCALAPPDATA", "")) / "Oculus"


def service_windows(adb: quest.Adb) -> list[str]:
    """The Link service's windows, the topmost first."""
    return [line.strip() for line in adb.run("shell", "dumpsys window windows", check=False).splitlines()
            if re.match(r"\s*Window #\d+ Window\{", line) and LINK_SERVICE in line]


def streaming(adb: quest.Adb) -> bool:
    return STREAMING in quest.top_activity(adb)


def stop_service(adb: quest.Adb) -> None:
    adb.run("shell", f"am force-stop {LINK_SERVICE}", check=False)


def reconnect_usb(adb: quest.Adb) -> None:
    """As a cable pulled and plugged back: the Link service starts and offers Link. adb drops for a moment."""
    subprocess.run([adb.path, "shell", "svc usb resetUsbGadget"], capture_output=True, timeout=30)
    try:
        subprocess.run([adb.path, "wait-for-device"], capture_output=True, timeout=60)
    except subprocess.TimeoutExpired:
        sys.exit("quest_link: adb didn't come back after the USB reconnect; plug the cable again")


def wait_for(adb: quest.Adb, what: str, seconds: float) -> bool:
    limit = time.time() + seconds
    while time.time() < limit:
        if what in quest.top_activity(adb):
            return True
        time.sleep(1)
    return False


def primary_button(adb: quest.Adb) -> tuple[int, int, str] | None:
    """Centre of the dialog's primary button in display coordinates, and its text."""
    for _ in range(5):
        adb.run("shell", f"uiautomator dump {UI_DUMP}", check=False)
        xml = adb.run("shell", f"cat {UI_DUMP}", check=False)
        for node in NODE.findall(xml):
            if f'resource-id="{PRIMARY_BUTTON}"' in node and (bounds := BOUNDS.search(node)):
                x1, y1, x2, y2 = map(int, bounds.groups())
                text = re.search(r'text="([^"]*)"', node)
                adb.run("shell", f"rm -f {UI_DUMP}", check=False)
                return (x1 + x2) // 2, (y1 + y2) // 2, text.group(1) if text else ""
        time.sleep(1)
    return None


def window_origin(adb: quest.Adb, activity: str) -> tuple[int, int]:
    """Where the window of [activity] lies on the display: uiautomator gives bounds in the window."""
    lines = adb.run("shell", "dumpsys window windows", check=False).splitlines()
    inside = False
    for line in lines:
        if re.match(r"\s*Window #\d+ Window\{", line):
            inside = activity in line
        elif inside and (frame := FRAME.search(line)):
            return int(frame.group(1)), int(frame.group(2))
    return 0, 0


def pc_log() -> Path | None:
    logs = sorted(PC_LOGS.glob("Service_*.txt"), key=lambda path: path.stat().st_mtime)
    return logs[-1] if logs else None


def pc_session_since(log: Path | None, offset: int) -> str | None:
    """The Meta service's new session line written after [offset], if any."""
    current = pc_log()
    if current is None:
        return None
    start = offset if current == log else 0
    with open(current, "rb") as file:
        file.seek(start)
        text = file.read().decode("utf-8", errors="replace")
    found = PC_SESSION.search(text)
    return found.group(0) if found else None


def headset_frames(adb: quest.Adb) -> str | None:
    """The Link client's line of glitches, which it prints while frames from the PC come in."""
    for line in reversed(adb.run("logcat", "-d", "-s", "xrstreaming:*", check=False).splitlines()):
        if "Glitches:" in line:
            return line.strip()
    return None


def link_on(adb: quest.Adb) -> int:
    quest.set_unattended(adb, True)
    if streaming(adb):
        print("quest_link: Link already streams")
        return 0
    # A Godot editor left open in the headset (after quest.py --unattended) stays on top of the Link dialog.
    quest.close_editors(adb)
    stop_service(adb)
    log = pc_log()
    offset = log.stat().st_size if log else 0
    print("quest_link: reconnecting the headset's USB")
    reconnect_usb(adb)
    if not wait_for(adb, DIALOG, 30):
        print(f"quest_link: no Link dialog; top is {quest.top_activity(adb)}. Is Air Link off and the Meta Horizon Link app running?",
              file=sys.stderr)
        return 1
    # The service's splash screen stays a moment after the dialog is up.
    windows = service_windows(adb)
    for _ in range(10):
        if len(windows) == 1 and DIALOG in windows[0]:
            break
        time.sleep(1)
        windows = service_windows(adb)
    if len(windows) != 1 or DIALOG not in windows[0]:
        # Panels lie on each other at the display's corner: a tap goes to the topmost one.
        print(f"quest_link: other Link windows are above or beside the dialog, not tapping: {windows}", file=sys.stderr)
        return 1
    button = primary_button(adb)
    if button is None:
        print("quest_link: the dialog's primary button wasn't found, not tapping", file=sys.stderr)
        return 1
    x, y, text = button
    origin_x, origin_y = window_origin(adb, DIALOG)
    adb.run("logcat", "-c", check=False)
    print(f"quest_link: tapping '{text}' at {x + origin_x},{y + origin_y}")
    adb.run("shell", f"input tap {x + origin_x} {y + origin_y}", check=False)
    limit = time.time() + 45
    frames = session = None
    while time.time() < limit and not (frames and session):
        time.sleep(2)
        frames = frames or (headset_frames(adb) if streaming(adb) else None)
        session = session or pc_session_since(log, offset)
    if not frames:
        print(f"quest_link: Link doesn't stream; top is {quest.top_activity(adb)}", file=sys.stderr)
        return 1
    print(f"quest_link: headset: {frames[frames.find('Glitches'):]}")
    print(f"quest_link: PC: {session or 'no new session line in the Meta service log'}")
    if session and session.endswith("1"):
        print("quest_link: warning: the PC reports a wireless session, not USB", file=sys.stderr)
    return 0


def link_off(adb: quest.Adb, restore: bool) -> int:
    stop_service(adb)
    time.sleep(2)
    print(f"quest_link: Link off; top is {quest.top_activity(adb)}")
    if restore:
        quest.set_unattended(adb, False)
    return 0


def status(adb: quest.Adb) -> int:
    print(f"top: {quest.top_activity(adb)}")
    print(f"usb: {adb.run('shell', 'getprop sys.usb.config', check=False).strip()}")
    print(f"guardian pause: {adb.run('shell', f'getprop {quest.GUARDIAN_PAUSE}', check=False).strip() or '0'}")
    print(f"link streams: {streaming(adb)}")
    return 0


def main() -> int:
    sys.stdout.reconfigure(line_buffering=True)
    args = sys.argv[1:]
    if not args or args[0] not in ("on", "off", "status"):
        print(__doc__)
        return 2
    path = quest.find_adb()
    if path is None:
        print("quest_link: adb not found", file=sys.stderr)
        return 1
    adb = quest.Adb(path)
    state = adb.run("get-state", check=False).strip()
    if state != "device":
        print(f"quest_link: no headset over adb ({state}); connect it by USB and allow USB debugging", file=sys.stderr)
        return 1
    if args[0] == "on":
        return link_on(adb)
    if args[0] == "off":
        return link_off(adb, "--restore" in args)
    return status(adb)


if __name__ == "__main__":
    sys.exit(main())
