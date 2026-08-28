#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
set -euo pipefail

# Start (or resume) an agent: ensure server is up + launch resilient driver.
# Usage: agent-start.sh <feature-name>

NAME="${1:?Usage: agent-start.sh <feature-name>}"
ROOT="$(git rev-parse --show-toplevel)"
sed -i 's/^Status:.*/Status: in_progress/' "$ROOT/.opencode-agents/tasks/$NAME.md" 2>/dev/null || true
AGENTS_ROOT="$(dirname "$ROOT")/headstad-agents"
WT="$AGENTS_ROOT/$NAME"
MODEL="opencode/mimo-v2.5-free"
PORT_FILE="$ROOT/.opencode-agents/$NAME.port"
PID_FILE="$ROOT/.opencode-agents/$NAME.pids"
REPORT_FILE="$ROOT/.opencode-agents/reports/$NAME.md"
LOG_FILE="$ROOT/.opencode-agents/reports/$NAME.serve.log"
DRIVER_LOG="$ROOT/.opencode-agents/reports/$NAME.driver.log"
TASK_FILE="$ROOT/.opencode-agents/tasks/$NAME.md"
SESSION_FILE="$ROOT/.opencode-agents/$NAME.session"

# --- server -----------------------------------------------------------------
if [ -f "$PORT_FILE" ] && curl -s -o /dev/null --max-time 2 "http://localhost:$(cat "$PORT_FILE")"; then
  PORT="$(cat "$PORT_FILE")"
else
  PORT="$(python3 -c 'import socket; s=socket.socket(); s.bind(("localhost",0)); print(s.getsockname()[1]); s.close()')"
  nohup opencode serve --port "$PORT" > "$LOG_FILE" 2>&1 &
  echo "$!" > "$PID_FILE"
  echo "$PORT" > "$PORT_FILE"
  sleep 2
fi

# --- driver (retries through transient provider failures) ---------------------
# All attempts reuse one session (via <name>.session) so manual instructions
# given during a dashboard takeover survive retries and resumes.
echo "[driver] started $(date +%H:%M:%S)" >> "$DRIVER_LOG"
touch "$ROOT/.opencode-agents/reports/$NAME.md"
nohup bash -c '
  attempts=0
  while [ $attempts -lt 30 ]; do
    sess_args=()
    if [ -s "'"$SESSION_FILE"'" ]; then
      sess_args=(-s "$(cat "'"$SESSION_FILE"'")")
    fi
    if opencode run --auto --title "agent '"$NAME"'" "${sess_args[@]}" \
      -m '"$MODEL"' --attach "http://localhost:'"$PORT"'" \
      "Read '"$TASK_FILE"' and execute the task fully. Work only inside '"$WT"'. If you already did part of the task, continue where you left off. Write progress updates to '"$ROOT/.opencode-agents/reports/$NAME.md"'. When the task is finished: first append a ## Summary section to '"$REPORT_FILE"' describing exactly what you did and which choices you made (and why), then update Status in the task file to completed."; then
      break
    fi
    "'"$SCRIPT_DIR"'/agent-session.sh" '"$NAME"' > "'"$SESSION_FILE"'" 2>/dev/null || true
    attempts=$((attempts+1))
    echo "[driver] attempt $attempts failed ($(date +%H:%M:%S)), retrying in 20s" >> "'"$DRIVER_LOG"'"
    sleep 20
  done
' >> "$DRIVER_LOG" 2>&1 &

echo "$NAME started on port $PORT"
