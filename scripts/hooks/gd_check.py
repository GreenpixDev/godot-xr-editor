"""PostToolUse hook: parse and type-check a GDScript right after Claude edits it.

Reads the hook JSON from stdin, and for a .gd file inside a Godot project runs
`godot --headless --check-only -s <file>` (about 0.3 s). Exit 2 puts the engine's
errors in front of Claude; any other outcome stays silent. A file that refers to a
class_name added in the same session may fail until `godot --headless --import` has
rebuilt the global class cache; scripts/check.sh does that before its own run.
"""
import json
import os
import shutil
import subprocess
import sys

TIMEOUT_SECONDS = 60


def project_root(path: str) -> str | None:
	"""Nearest parent folder of [path] with a project.godot, so a worktree checks against itself."""
	folder = os.path.dirname(os.path.abspath(path))
	while True:
		if os.path.isfile(os.path.join(folder, "project.godot")):
			return folder
		parent = os.path.dirname(folder)
		if parent == folder:
			return None
		folder = parent


def main() -> int:
	try:
		event = json.load(sys.stdin)
		path = event["tool_input"]["file_path"]
	except (ValueError, KeyError, TypeError):
		return 0
	if not path.endswith(".gd") or not os.path.isfile(path):
		return 0
	root = project_root(path)
	godot = shutil.which("godot") or shutil.which("godot.cmd")
	if root is None or godot is None:
		return 0
	res_path = "res://" + os.path.relpath(path, root).replace(os.sep, "/")
	try:
		run = subprocess.run(
			[godot, "--headless", "--xr-mode", "off", "--path", root, "--check-only", "-s", res_path],
			capture_output=True, text=True, timeout=TIMEOUT_SECONDS,
		)
	except (subprocess.TimeoutExpired, OSError):
		return 0
	if run.returncode == 0:
		return 0
	output = (run.stdout + run.stderr).strip()
	sys.stderr.write("gd_check: %s does not parse or type-check:\n%s\n" % (res_path, output))
	return 2


if __name__ == "__main__":
	sys.exit(main())
