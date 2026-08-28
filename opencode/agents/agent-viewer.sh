#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Interactive agent viewer: fuzzy-pick an agent, view it fullscreen.
# Exit the attached TUI to return to the picker.
ROOT="$(git rev-parse --show-toplevel)"
PORT_DIR="$ROOT/.opencode-agents"

while true; do
  # Build "name  port" list from running servers
  entries=()
  for pf in "$PORT_DIR"/*.port; do
    [ -f "$pf" ] || continue
    name="$(basename "$pf" .port)"
    port="$(cat "$pf")"
    if curl -s -o /dev/null --max-time 1 "http://localhost:$port"; then
      status="$(grep -m1 'Status:' "$PORT_DIR/tasks/$name.md" 2>/dev/null | awk '{print $2}')"
      entries+=("$name ($status)")
    fi
  done

  [ ${#entries[@]} -eq 0 ] && { echo "no running agents. spawn one first."; sleep 3; continue; }

  sel="$(printf '%s\n' "${entries[@]}" | fzf --height=100% --reverse --border \
      --header='select agent (esc quits)' \
      --preview="python3 $SCRIPT_DIR/agents-dashboard.py --once" --preview-window=right:60%:wrap)"

  [ -z "$sel" ] && break
  name="${sel%% *}"
  port="$(cat "$PORT_DIR/$name.port")"

  opencode attach "http://localhost:$port"
  clear
done
