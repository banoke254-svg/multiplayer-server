#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-24580}"
GODOT="${GODOT:-godot}"

"$GODOT" --headless --path . res://online_relay_server.tscn -- --port="$PORT"
