#!/usr/bin/env bash
# Fill the current zellij tab with one watcher pane per running agent, stacked.
# Panes run agent-watch.sh so they follow an agent across restarts: the same
# pane reattaches to the new server instead of dying and being re-added.
# Only spawns extra panes when this pane is focused, so boot-time runs never
# inject panes into whichever tab the user is looking at.
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo /home/izanovic/projects/headstad)"
PORT_DIR="$ROOT/.opencode-agents"
WATCH="/home/izanovic/.config/zellij/scripts/agent-watch.sh"
MARKER="__AGENT_STACK_PANE__"

echo "$MARKER"
sleep 3

probe="$(mktemp)"
timeout 5 zellij action dump-screen "$probe" > /dev/null 2>&1
focused_here=$(grep -c "$MARKER" "$probe" 2>/dev/null || true)
rm -f "$probe"

running=()
for pf in "$PORT_DIR"/*.port; do
  [ -f "$pf" ] || continue
  port="$(cat "$pf")"
  if curl -s -o /dev/null --max-time 1 "http://localhost:$port"; then
    running+=("$(basename "$pf" .port)")
  fi
done

if [ ${#running[@]} -eq 0 ]; then
  echo "no running agents."
  exec bash
fi

if [ "$focused_here" -gt 0 ]; then
  for name in "${running[@]:1}"; do
    zellij action new-pane --direction down --close-on-exit --name "$name" \
      --cwd "$ROOT" -- bash "$WATCH" "$name" > /dev/null 2>&1
    sleep 0.3
  done
fi

first="${running[0]}"
exec bash "$WATCH" "$first"
