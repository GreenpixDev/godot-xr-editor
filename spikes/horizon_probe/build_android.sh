#!/usr/bin/env bash
# Spike only: builds the plugin's native library for Android arm64 with the
# main build script and copies it into the probe project, next to a
# .gdextension that lists only Android.
set -euo pipefail
cd "$(dirname "$0")/../.."
scripts/build_gdextension.sh android
lib=xre_native.android.template_debug.arm64.so
dest=spikes/horizon_probe/addons/xre_native/bin
mkdir -p "$dest"
cp "addons/xr_editor/bin/$lib" "$dest/"
echo "build_android: OK ($dest/$lib)"
