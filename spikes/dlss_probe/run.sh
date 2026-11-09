#!/usr/bin/env bash
# Runs the probe with the layer on, for this process only. Arguments go to the probe; --xr-off drops stereo's shader variants.
cd "$(dirname "$0")"
win="$(cygpath -w "$PWD")"
export VK_LAYER_PATH="$win"
export VK_INSTANCE_LAYERS=VK_LAYER_XRE_dlss
export XRE_DLSS_SDK="$win\\sdk"
export XRE_DLSS_DATA="$win\\build"
export XRE_DLSS_LOG="$win\\build\\layer.log"
timeout 280 godot --path . -s res://probe.gd -- "$@"
