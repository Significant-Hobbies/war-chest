#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
LOCAL_BUILD_ROOT=$(pwd)
GODOT_BIN="${GODOT_BIN:-/Users/sarthak/Downloads/war-chest-tools/Godot.app/Contents/MacOS/Godot}"
LOCAL_GODOT_APP="${GODOT_BIN%/Contents/MacOS/Godot}"
LOCAL_OUTPUT="${1:-$LOCAL_BUILD_ROOT/builds/War Chest Local}"
case "$LOCAL_OUTPUT" in /*) ;; *) LOCAL_OUTPUT="$LOCAL_BUILD_ROOT/$LOCAL_OUTPUT" ;; esac
if [ ! -x "$GODOT_BIN" ] || [ ! -f "$LOCAL_GODOT_APP/Contents/Info.plist" ]; then
  echo "Set GODOT_BIN to the executable inside your Godot.app." >&2
  exit 1
fi
if [ -e "$LOCAL_OUTPUT" ]; then
  echo "Local build already exists: $LOCAL_OUTPUT" >&2
  echo "Move it aside before rebuilding; this script never overwrites a build." >&2
  exit 1
fi
mkdir -p "$LOCAL_OUTPUT/logs" "$LOCAL_OUTPUT/runtime"
"$GODOT_BIN" --headless --path "$LOCAL_BUILD_ROOT" \
  --log-file "$LOCAL_OUTPUT/logs/pack.log" --script scripts/pack_local.gd -- "$LOCAL_OUTPUT"
test -s "$LOCAL_OUTPUT/War Chest.pck"
# Keep the official app unmodified; no signing/security changes or downloads.
ditto "$LOCAL_GODOT_APP" "$LOCAL_OUTPUT/runtime/Godot.app"
cp scripts/local/launch.sh "$LOCAL_OUTPUT/launch.sh"
cp "scripts/local/Play War Chest.command" "$LOCAL_OUTPUT/Play War Chest.command"
cp "scripts/local/Practice War Chest.command" "$LOCAL_OUTPUT/Practice War Chest.command"
cp "scripts/local/Verify Local Game.command" "$LOCAL_OUTPUT/Verify Local Game.command"
cp scripts/local/START-HERE.txt "$LOCAL_OUTPUT/START-HERE.txt"
cp ASSETS.md "$LOCAL_OUTPUT/ASSET-PROVENANCE.md"
chmod +x "$LOCAL_OUTPUT/launch.sh" "$LOCAL_OUTPUT/Play War Chest.command" \
  "$LOCAL_OUTPUT/Practice War Chest.command" "$LOCAL_OUTPUT/Verify Local Game.command"
cd "$LOCAL_OUTPUT"
shasum -a 256 "War Chest.pck" runtime/Godot.app/Contents/MacOS/Godot \
  launch.sh "Play War Chest.command" "Practice War Chest.command" \
  "Verify Local Game.command" GODOT-NOTICES.txt content-manifest.json > SHA256SUMS
sh launch.sh check
echo "Local build prepared: $LOCAL_OUTPUT"
echo "This is a bundled local runner, not a notarized/exported release."
