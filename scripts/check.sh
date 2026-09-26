#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
GODOT_BIN="${GODOT_BIN:-/Users/sarthak/Downloads/war-chest-tools/Godot.app/Contents/MacOS/Godot}"
CHECK_LOG=$(mktemp -t war-chest-check)
"$GODOT_BIN" --headless --path . --editor --import --quit > "$CHECK_LOG" 2>&1
if rg -n 'SCRIPT ERROR|Parse Error|Compile Error|ERROR:' "$CHECK_LOG"; then
  exit 1
fi
"$GODOT_BIN" --headless --path . --script tests/test_game.gd > "$CHECK_LOG" 2>&1
cat "$CHECK_LOG"
if rg -n 'SCRIPT ERROR|ERROR:|FAIL:' "$CHECK_LOG"; then
  exit 1
fi
rg 'RULE TESTS: [0-9]+ checks, 0 failures' "$CHECK_LOG"
"$GODOT_BIN" --headless --path . --script tests/test_campaign.gd > "$CHECK_LOG" 2>&1
cat "$CHECK_LOG"
if rg -n 'SCRIPT ERROR|ERROR:|FAIL:' "$CHECK_LOG"; then exit 1; fi
rg 'CAMPAIGN TEST: 0 failures' "$CHECK_LOG"
"$GODOT_BIN" --headless --path . --script tests/test_siege.gd > "$CHECK_LOG" 2>&1
cat "$CHECK_LOG"
if rg -n 'SCRIPT ERROR|ERROR:|FAIL:' "$CHECK_LOG"; then exit 1; fi
rg 'SIEGE TESTS: [0-9]+ checks, 0 failures' "$CHECK_LOG"
"$GODOT_BIN" --headless --path . --script tests/test_pocket_ui.gd -- --pocket-demo > "$CHECK_LOG" 2>&1
cat "$CHECK_LOG"
if rg -n 'SCRIPT ERROR|ERROR:|FAIL:' "$CHECK_LOG"; then exit 1; fi
rg 'POCKET UI TEST: 0 failures' "$CHECK_LOG"
"$GODOT_BIN" --headless --path . --script tests/test_expansion.gd > "$CHECK_LOG" 2>&1
cat "$CHECK_LOG"
if rg -n 'SCRIPT ERROR|ERROR:|FAIL:' "$CHECK_LOG"; then exit 1; fi
rg 'EXPANSION TESTS: [0-9]+ checks, 0 failures' "$CHECK_LOG"
"$GODOT_BIN" --headless --path . --script tests/test_mastery.gd > "$CHECK_LOG" 2>&1
cat "$CHECK_LOG"
if rg -n 'SCRIPT ERROR|ERROR:|FAIL:' "$CHECK_LOG"; then exit 1; fi
rg 'MASTERY TESTS: [0-9]+ checks, 0 failures' "$CHECK_LOG"
"$GODOT_BIN" --headless --path . --script tests/test_motion.gd -- --pocket-demo > "$CHECK_LOG" 2>&1
cat "$CHECK_LOG"
if rg -n 'SCRIPT ERROR|ERROR:|FAIL:' "$CHECK_LOG"; then exit 1; fi
rg 'MOTION TESTS: [0-9]+ checks, 0 failures' "$CHECK_LOG"
"$GODOT_BIN" --headless --path . --script tests/test_onboarding.gd -- --pocket-demo > "$CHECK_LOG" 2>&1
cat "$CHECK_LOG"
if rg -n 'SCRIPT ERROR|ERROR:|FAIL:' "$CHECK_LOG"; then exit 1; fi
rg 'ONBOARDING TESTS: [0-9]+ checks, 0 failures' "$CHECK_LOG"
"$GODOT_BIN" --headless --path . --script tests/test_journey.gd > "$CHECK_LOG" 2>&1
cat "$CHECK_LOG"
if rg -n 'SCRIPT ERROR|ERROR:|FAIL:' "$CHECK_LOG"; then exit 1; fi
rg 'JOURNEY TESTS: [0-9]+ checks, 0 failures' "$CHECK_LOG"
"$GODOT_BIN" --headless --path . --script tests/test_journey_ui.gd -- --pocket-demo > "$CHECK_LOG" 2>&1
cat "$CHECK_LOG"
if rg -n 'SCRIPT ERROR|ERROR:|FAIL:' "$CHECK_LOG"; then exit 1; fi
rg 'JOURNEY UI TESTS: [0-9]+ checks, 0 failures' "$CHECK_LOG"
"$GODOT_BIN" --headless --path . --script tests/test_stability.gd -- --pocket-demo > "$CHECK_LOG" 2>&1
cat "$CHECK_LOG"
if rg -n 'SCRIPT ERROR|ERROR:|FAIL:' "$CHECK_LOG"; then exit 1; fi
rg 'STABILITY TESTS: [0-9]+ checks, 0 failures' "$CHECK_LOG"
"$GODOT_BIN" --headless --path . --script tests/test_opening.gd -- --pocket-demo > "$CHECK_LOG" 2>&1
cat "$CHECK_LOG"
if rg -n 'SCRIPT ERROR|ERROR:|FAIL:' "$CHECK_LOG"; then exit 1; fi
rg 'OPENING TESTS: [0-9]+ checks, 0 failures' "$CHECK_LOG"
"$GODOT_BIN" --headless --path . --script tests/test_opening_boot.gd -- --pocket-demo --banner-opening > "$CHECK_LOG" 2>&1
cat "$CHECK_LOG"
if rg -n 'SCRIPT ERROR|ERROR:|FAIL:' "$CHECK_LOG"; then exit 1; fi
rg 'OPENING BOOT TESTS: [0-9]+ checks, 0 failures' "$CHECK_LOG"
