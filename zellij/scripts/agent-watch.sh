#!/usr/bin/env bash
# Live pane for one agent: follows the agent across restarts.
# When the server dies (stop/restart), waits and reattaches to the new port
# in this same pane, so dashboards actions update the existing view.
NAME="${1:?Usage: agent-watch.sh <feature-name>}"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo /home/izanovic/projects/headstad)"
PORT_FILE="$ROOT/.opencode-agents/$NAME.port"

while true; do
  if [ -s "$PORT_FILE" ]; then
    port="$(cat "$PORT_FILE")"
    if curl -s -o /dev/null --max-time 1 "http://localhost:$port"; then
      clear
      opencode attach "http://localhost:$port"
      # Attach exited: server died/restarted, or the user backed out.
      sleep 1
      continue
    fi
    echo "[$NAME] server on $port not responding, waiting..."
  else
    echo "[$NAME] stopped — waiting for restart..."
  fi
  sleep 2
done
