#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
GODOT_BIN="${GODOT_BIN:-/Users/sarthak/Downloads/war-chest-tools/Godot.app/Contents/MacOS/Godot}"
exec "$GODOT_BIN" --path . "$@"
