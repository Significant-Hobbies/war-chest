#!/bin/sh
set -eu
cd "$(dirname "$0")"
LOCAL_GAME_DIR=$(pwd)
LOCAL_ENGINE="$LOCAL_GAME_DIR/runtime/Godot.app/Contents/MacOS/Godot"
LOCAL_PACK="$LOCAL_GAME_DIR/War Chest.pck"
LOCAL_MODE="${1:-play}"
case "$LOCAL_MODE" in play|practice|check|verify) ;; *) echo "Use play, practice, check or verify." >&2; exit 2 ;; esac
if [ ! -x "$LOCAL_ENGINE" ] || [ ! -s "$LOCAL_PACK" ] || [ ! -s SHA256SUMS ]; then
  echo "The local game is incomplete. Keep the entire War Chest Local folder together." >&2
  exit 1
fi
if ! shasum -a 256 -c SHA256SUMS; then
  echo "A local game file is missing or changed. Rebuild before playing." >&2
  exit 1
fi
if [ "$LOCAL_MODE" = check ]; then
  echo "Local runtime, game pack and launchers verified. No game or save was opened."
  exit 0
fi
mkdir -p logs
LOCAL_LOG_DIR=$(mktemp -d "$LOCAL_GAME_DIR/logs/session.XXXXXX")
if [ "$LOCAL_MODE" = verify ]; then
  LOCAL_FAILURE=0
  for LOCAL_SUITE in journey journey_ui onboarding motion opening; do
    LOCAL_LOG="$LOCAL_LOG_DIR/$LOCAL_SUITE.log"
    if ! "$LOCAL_ENGINE" --headless --main-pack "$LOCAL_PACK" --log-file "$LOCAL_LOG_DIR/$LOCAL_SUITE-engine.log" \
      --script "res://tests/test_$LOCAL_SUITE.gd" -- --pocket-demo > "$LOCAL_LOG" 2>&1; then
      LOCAL_FAILURE=1
    fi
    cat "$LOCAL_LOG"
    if ! grep -Eq 'TESTS: [0-9]+ checks, 0 failures' "$LOCAL_LOG"; then LOCAL_FAILURE=1; fi
    if grep -Eq 'SCRIPT ERROR|ERROR:|FAIL:' "$LOCAL_LOG"; then LOCAL_FAILURE=1; fi
  done
  echo "Verification logs: $LOCAL_LOG_DIR"
  if [ "$LOCAL_FAILURE" -ne 0 ]; then
    echo "Verification is not clean. Inspect the logs; no player save was opened."
    exit 1
  fi
  echo "Packaged gameplay checks passed. Native graphics/background stability still need a playtest."
  exit 0
fi
echo "Session log: $LOCAL_LOG_DIR/game.log"
if [ "$LOCAL_MODE" = practice ]; then
  echo "Practice: temporary progress only; existing saves and settings are untouched."
  exec "$LOCAL_ENGINE" --main-pack "$LOCAL_PACK" --log-file "$LOCAL_LOG_DIR/game.log" -- --pocket-demo --banner-opening
fi
echo "Campaign: uses your existing War Chest save and autosaves progress."
exec "$LOCAL_ENGINE" --main-pack "$LOCAL_PACK" --log-file "$LOCAL_LOG_DIR/game.log"
