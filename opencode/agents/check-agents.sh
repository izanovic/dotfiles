#!/usr/bin/env bash
# Colored status board for spawned agents
set -uo pipefail

ROOT="$(git rev-parse --show-toplevel)"
TASK_DIR="$ROOT/.opencode-agents/tasks"
REPORT_DIR="$ROOT/.opencode-agents/reports"
AGENTS_ROOT="$(dirname "$ROOT")/headstad-agents"
STALL_SECS=180

# --- colors -----------------------------------------------------------------
R=$'\e[31m' G=$'\e[32m' Y=$'\e[33m' C=$'\e[36m' DIM=$'\e[2m' B=$'\e[1m' X=$'\e[0m'

draw_box() { # $1=color $2=title $3=body(with \n)
  local color="$1" title="$2" body="$3"
  local maxw=0 line
  local lines=()
  while IFS= read -r line; do lines+=("$line"); (( ${#line} > maxw )) && maxw=${#line}; done <<< "$body"
  local top="${color}┌─ ${B}${title}${X}${color} ─$(printf '─%.0s' $(seq $((maxw - ${#title} - 4))))${X}"
  echo "$top"
  for line in "${lines[@]}"; do
    printf '%s│%s %s\n' "$color" "$X" "$line"
  done
  echo "${color}└$(printf '─%.0s' $(seq $((maxw + 1))))${X}"
}

bar() { # $1=pct(0-100) $2=width
  local pct=$1 w=${2:-24} filled empty
  filled=$(( pct * w / 100 ))
  empty=$(( w - filled ))
  local color=$G
  (( pct < 34 )) && color=$C
  (( pct >= 99 )) && color=$B$G
  local blocks="" spaces=""
  (( filled > 0 )) && blocks=$(printf '█%.0s' $(seq $filled))
  (( empty > 0 )) && spaces=$(printf '░%.0s' $(seq $empty))
  printf "%s%s%s${X} %3d%%" "$color" "$blocks" "${DIM}${spaces}" "$pct"
}

for task in "$TASK_DIR"/*.md; do
  [ -f "$task" ] || continue
  name="$(basename "$task" .md)"
  wt="$AGENTS_ROOT/$name"
  nx="$wt/packages/nexura"
  status="$(grep -m1 'Status:' "$task" | awk '{print $2}')"

  # --- process state --------------------------------------------------------
  pid="$(pgrep -f "opencode run.*tasks/$name\.md" | head -1)"
  model=""; [ -n "$pid" ] && model="$(tr '\0' ' ' < "/proc/$pid/cmdline" | grep -oP '(?<=-m opencode/)[^ ]+' || true)"

  # --- git facts ------------------------------------------------------------
  branch="-"; dirty=0; commits=0; nx_branch="-"; nx_dirty=0; nx_commits=0
  if git -C "$wt" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$wt" branch --show-current 2>/dev/null)
    dirty=$(git -C "$wt" status --short 2>/dev/null | wc -l)
    commits=$(git -C "$wt" log --oneline origin/test..HEAD 2>/dev/null | wc -l)
    nx_branch=$(git -C "$nx" branch --show-current 2>/dev/null)
    nx_dirty=$(git -C "$nx" status --short 2>/dev/null | wc -l)
    nx_commits=$(git -C "$nx" log --oneline test..HEAD 2>/dev/null | wc -l)
  fi

  # --- activity -------------------------------------------------------------
  report="$REPORT_DIR/$name.md"
  idle="?"; recent=no
  if [ -f "$report" ]; then
    age=$(( $(date +%s) - $(stat -c %Y "$report") ))
    idle="$(( age / 60 ))m"
    (( age < STALL_SECS )) && recent=yes
  fi

  # --- state color ----------------------------------------------------------
  color=$R; state="DEAD"
  if [ "$status" = "completed" ]; then
    color=$G; state="DONE"
  elif [ -n "$pid" ]; then
    if [ "$recent" = yes ]; then color=$G; state="RUNNING"; else color=$Y; state="STALLED"; fi
  fi

  # --- progress -------------------------------------------------------------
  pct=0; step="queued"
  [ -d "$wt" ] && { pct=15; step="setup"; }
  (( dirty + nx_dirty > 0 )) && { pct=45; step="building"; }
  (( commits + nx_commits > 0 )) && { pct=75; step="review/verify"; }
  [ "$status" = "completed" ] && { pct=100; step="done"; }

  body=$(cat <<EOF
state: ${color}${B}${state}${X}  pid: ${pid:-—}  model: ${model:-default}  idle: ${idle}
step:  $(bar "$pct")
now:   ${B}${step}${X}
repo:  ${branch} ${DIM}(+${commits} commits, ${dirty} changed)${X}
nexura:${nx_branch} ${DIM}(+${nx_commits} commits, ${nx_dirty} changed)${X}
last:  $(grep -v '^$' "$report" 2>/dev/null | tail -n 2 | tr '\n' ' ' | cut -c1-"$(( $(tput cols 2>/dev/null || echo 100) - 12 ))")
EOF
)
  draw_box "$color" "$name" "$body"
  echo ""
done

[ -n "$(ls -A "$TASK_DIR" 2>/dev/null)" ] || echo "${DIM}no agents spawned${X}"
