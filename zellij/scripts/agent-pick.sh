#!/usr/bin/env bash
# Fuzzy-pick a running agent; view it fullscreen outside the popup.
# Exit the attached TUI to return to the picker. Alt+f toggles this popup.
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo /home/izanovic/projects/headstad)"
PORT_DIR="$ROOT/.opencode-agents"

while true; do
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
      --header='select agent (esc closes picker · Alt+f toggles popup)' \
      --preview="python3 $ROOT/scripts/agents-dashboard.py --once" --preview-window=right:60%:wrap)"

  [ -z "$sel" ] && sleep 5 && clear && continue
  name="${sel%% *}"
  port="$(cat "$PORT_DIR/$name.port")"

  # Hide the picker, open the agent fullscreen in its own pane,
  # bring the picker back when the attach exits.
  zellij action toggle-floating-panes > /dev/null 2>&1
  zellij action new-pane --direction down --close-on-exit --name "$name" \
    --cwd "$ROOT" -- opencode attach "http://localhost:$port" > /dev/null 2>&1
  zellij action toggle-fullscreen > /dev/null 2>&1
  clear
  zellij action toggle-floating-panes > /dev/null 2>&1
done
