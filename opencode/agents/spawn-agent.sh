#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
set -euo pipefail

# Spawn an autonomous opencode agent (headless server + resilient driver).
# View it in the zellij "agents" tab via ~/.config/opencode/agents/agent-viewer.sh,
# manage it from the "dashboard" tab (stop/restart).
# Usage: ~/.config/opencode/agents/spawn-agent.sh <feature-name> ["<task prompt>"]

FEATURE_NAME="${1:?Usage: spawn-agent.sh <feature-name> [prompt]}"
PROMPT="${2:-}"
ROOT="$(git rev-parse --show-toplevel)"
TASK_DIR="$ROOT/.opencode-agents/tasks"
REPORT_DIR="$ROOT/.opencode-agents/reports"
AGENTS_ROOT="$(dirname "$ROOT")/headstad-agents"
BRANCH="feature/$FEATURE_NAME"
WT="$AGENTS_ROOT/$FEATURE_NAME"
MODEL="opencode/mimo-v2.5-free"

TASK_FILE="$TASK_DIR/$FEATURE_NAME.md"
REPORT_FILE="$REPORT_DIR/$FEATURE_NAME.md"
PORT_FILE="$ROOT/.opencode-agents/$FEATURE_NAME.port"
PID_FILE="$ROOT/.opencode-agents/$FEATURE_NAME.pids"
LOG_FILE="$REPORT_DIR/$FEATURE_NAME.serve.log"
DRIVER_LOG="$REPORT_DIR/$FEATURE_NAME.driver.log"

if [ ! -f "$TASK_FILE" ]; then
  [ -n "$PROMPT" ] || { echo "error: new feature needs a prompt"; exit 1; }
fi

# --- Isolated worktree setup ----------------------------------------------

git -C "$ROOT" branch "$BRANCH" origin/test 2>/dev/null \
  || git -C "$ROOT" branch "$BRANCH" test 2>/dev/null \
  || echo "branch $BRANCH already exists, reusing"
[ -d "$WT" ] || git -C "$ROOT" worktree add "$WT" "$BRANCH"

NX_MAIN="$ROOT/packages/nexura"
if [ -f "$WT/.gitmodules" ] && [ ! -e "$WT/packages/nexura/.git" ]; then
  git -C "$NX_MAIN" branch "$BRANCH" "$(git -C "$NX_MAIN" rev-parse origin/test 2>/dev/null || echo test)" 2>/dev/null || true
  git -C "$WT" -c protocol.file.allow=always submodule update --init --reference "$NX_MAIN" packages/nexura
  git -C "$WT/packages/nexura" checkout -q -B "$BRANCH" "$(git -C "$NX_MAIN" rev-parse "$BRANCH")"
fi

# --- Task spec (only written on first creation) -----------------------------

mkdir -p "$TASK_DIR" "$REPORT_DIR"
if [ ! -f "$TASK_FILE" ]; then
  cat > "$TASK_FILE" <<EOF
# Task: $FEATURE_NAME

$PROMPT

## Environment

You are working in an isolated git worktree: $WT
- headstad branch: $BRANCH (from test)
- nexura branch:   $BRANCH (from test)

Commit to these branches when done. Do NOT touch ~/projects/headstad.

## Workflow (see docs/agent/implement-new-feature.md)

1. Read the requirements above.
2. Build the feature with clean, simple, and minimal code.
3. Review the code and simplify — reduce lines where possible.
4. Ensure all linting, typechecks, and vue-tsc checks pass.
5. Commit changes to the feature branches.
6. Append a '## Summary' section to your report file describing what
   you did and which choices you made (and why), BEFORE setting
   Status to completed.

## Rules

1. Avoid casting.
2. Use proper types defined in types.ts (packages/nexura/packages/core/src/types.ts).
3. Prefer built-in UI components.
4. For new endpoints, use data.ts functions for CRUD. Create an override only if custom logic is needed.
5. Avoid nested if statements. Avoid unnecessary or duplicate guards.
6. Keep code clean and minimal.

---
Status: in_progress
Started: $(date -Iseconds)
EOF
else
  sed -i 's/^Status:.*/Status: in_progress/' "$TASK_FILE"
fi

[ -f "$REPORT_FILE" ] || printf '# Report: %s\n\nWorking...\n' "$FEATURE_NAME" > "$REPORT_FILE"

"$SCRIPT_DIR/agent-start.sh" "$FEATURE_NAME"
echo "Spawned agent: $FEATURE_NAME"
