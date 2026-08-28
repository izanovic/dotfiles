#!/usr/bin/env bash
set -euo pipefail

# Stop an agent: kill driver + server.
# Usage: agent-stop.sh <feature-name>

NAME="${1:?Usage: agent-stop.sh <feature-name>}"
ROOT="$(git rev-parse --show-toplevel)"
PORT_FILE="$ROOT/.opencode-agents/$NAME.port"
PID_FILE="$ROOT/.opencode-agents/$NAME.pids"

# kill driver (matches task path in cmdline)
pkill -f "tasks/$NAME\.md" 2>/dev/null || true

# kill server
if [ -f "$PID_FILE" ]; then
  kill "$(cat "$PID_FILE")" 2>/dev/null || true
  rm -f "$PID_FILE"
fi
rm -f "$PORT_FILE"

sed -i 's/^Status:.*/Status: stopped/' "$ROOT/.opencode-agents/tasks/$NAME.md" 2>/dev/null || true
echo "$NAME stopped"
