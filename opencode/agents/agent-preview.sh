#!/usr/bin/env bash
set -euo pipefail

# Start or stop a quasar dev server for an agent worktree.
# Usage: agent-preview.sh <feature-name> [start|stop|status|url]

NAME="${1:?Usage: agent-preview.sh <feature-name> [start|stop|status|url]}"
ACTION="${2:-start}"
ROOT="$(git rev-parse --show-toplevel)"
AGENTS_ROOT="$(dirname "$ROOT")/headstad-agents"
WT="$AGENTS_ROOT/$NAME"
PREVIEW_PORT_FILE="$ROOT/.opencode-agents/$NAME.preview-port"
PREVIEW_PID_FILE="$ROOT/.opencode-agents/$NAME.preview-pids"
PREVIEW_LOG="$ROOT/.opencode-agents/reports/$NAME.preview.log"

# Base port for agent previews (each agent gets ROOT + offset)
BASE_PORT=9100

get_port() {
  local hash=$(echo -n "$NAME" | cksum | cut -d' ' -f1)
  echo $(( BASE_PORT + (hash % 900) ))
}

is_running() {
  if [ -f "$PREVIEW_PID_FILE" ]; then
    local pid=$(cat "$PREVIEW_PID_FILE")
    if kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
  fi
  return 1
}

start_server() {
  if is_running; then
    cat "$PREVIEW_PORT_FILE" 2>/dev/null
    return 0
  fi

  if [ ! -d "$WT" ]; then
    echo "error: worktree not found at $WT" >&2
    return 1
  fi

  local port=$(get_port)
  
  mkdir -p "$(dirname "$PREVIEW_LOG")"
  
  # Ensure dependencies are installed (output to log only)
  cd "$WT"
  if [ ! -d "node_modules" ]; then
    echo "[$(date +%H:%M:%S)] Installing dependencies..." >> "$PREVIEW_LOG"
    yarn install 2>> "$PREVIEW_LOG" >> "$PREVIEW_LOG"
  fi
  
  # Start quasar dev in the worktree (all output to log)
  nohup yarn dev:web -p "$port" >> "$PREVIEW_LOG" 2>&1 &
  local pid=$!
  
  echo "$pid" > "$PREVIEW_PID_FILE"
  echo "$port" > "$PREVIEW_PORT_FILE"
  
  # Wait briefly for server to start
  sleep 2
  
  echo "$port"
}

stop_server() {
  if [ -f "$PREVIEW_PID_FILE" ]; then
    local pid=$(cat "$PREVIEW_PID_FILE")
    kill "$pid" 2>/dev/null || true
    pkill -P "$pid" 2>/dev/null || true
    rm -f "$PREVIEW_PID_FILE" "$PREVIEW_PORT_FILE"
    echo "stopped"
  else
    echo "not running"
  fi
}

status() {
  if is_running; then
    echo "running on http://localhost:$(cat "$PREVIEW_PORT_FILE" 2>/dev/null)"
  else
    echo "not running"
  fi
}

url() {
  if is_running; then
    cat "$PREVIEW_PORT_FILE" 2>/dev/null
  else
    start_server
  fi
}

case "$ACTION" in
  start)  start_server ;;
  stop)   stop_server ;;
  status) status ;;
  url)    url ;;
  *)      echo "unknown action: $ACTION (use start|stop|status|url)" >&2 ; exit 1 ;;
esac
