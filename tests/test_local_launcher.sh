#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
LOCAL_TEST_ROOT=$(mktemp -d /private/tmp/war-chest-launcher.XXXXXX)
LOCAL_FIXTURE="$LOCAL_TEST_ROOT/Game With Spaces"
mkdir -p "$LOCAL_FIXTURE/runtime/Godot.app/Contents/MacOS"
cp scripts/local/launch.sh "$LOCAL_FIXTURE/launch.sh"
cp tests/fixtures/local-engine.sh "$LOCAL_FIXTURE/runtime/Godot.app/Contents/MacOS/Godot"
chmod +x "$LOCAL_FIXTURE/runtime/Godot.app/Contents/MacOS/Godot"
printf 'test pack\n' > "$LOCAL_FIXTURE/War Chest.pck"
export WAR_CHEST_TEST_ARGS="$LOCAL_TEST_ROOT/arguments.txt"
cd "$LOCAL_FIXTURE"
shasum -a 256 'War Chest.pck' runtime/Godot.app/Contents/MacOS/Godot launch.sh > SHA256SUMS
sh launch.sh check > "$LOCAL_TEST_ROOT/check.log"
test ! -e "$WAR_CHEST_TEST_ARGS"
sh launch.sh practice > "$LOCAL_TEST_ROOT/practice.log"
grep -Fx -- '--pocket-demo' "$WAR_CHEST_TEST_ARGS"
grep -Fx -- "$LOCAL_FIXTURE/War Chest.pck" "$WAR_CHEST_TEST_ARGS"
grep -Fx -- '--log-file' "$WAR_CHEST_TEST_ARGS"
sh launch.sh play > "$LOCAL_TEST_ROOT/play.log"
if grep -Fq -- '--pocket-demo' "$WAR_CHEST_TEST_ARGS"; then exit 1; fi
grep -Fx -- "$LOCAL_FIXTURE/War Chest.pck" "$WAR_CHEST_TEST_ARGS"
LOCAL_BEFORE=$(shasum -a 256 "$WAR_CHEST_TEST_ARGS")
if sh launch.sh bad > "$LOCAL_TEST_ROOT/bad.log" 2>&1; then exit 1; else test "$?" -eq 2; fi
test "$LOCAL_BEFORE" = "$(shasum -a 256 "$WAR_CHEST_TEST_ARGS")"
mv 'War Chest.pck' 'War Chest.pck.saved'
if sh launch.sh practice > "$LOCAL_TEST_ROOT/missing.log" 2>&1; then exit 1; fi
grep -Fq 'local game is incomplete' "$LOCAL_TEST_ROOT/missing.log"
mv 'War Chest.pck.saved' 'War Chest.pck'
printf 'changed test pack\n' > 'War Chest.pck'
if sh launch.sh practice > "$LOCAL_TEST_ROOT/changed.log" 2>&1; then exit 1; fi
grep -Fq 'missing or changed' "$LOCAL_TEST_ROOT/changed.log"
test "$LOCAL_BEFORE" = "$(shasum -a 256 "$WAR_CHEST_TEST_ARGS")"
echo "LOCAL LAUNCHER: preflight, practice/play flags, space-safe paths, logging, invalid mode, missing/tampered pack passed"
echo "Isolated diagnostic fixtures retained at: $LOCAL_TEST_ROOT"
