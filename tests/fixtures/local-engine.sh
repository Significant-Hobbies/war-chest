#!/bin/sh
# Test double for launch arguments only. Never starts Godot or accesses saves.
printf '%s\n' "$@" > "$WAR_CHEST_TEST_ARGS"
