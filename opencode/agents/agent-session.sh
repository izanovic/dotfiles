#!/usr/bin/env bash
set -euo pipefail

# Resolve the headless driver's opencode session id for an agent.
# Prints the session id; empty output if unknown.
# Resolution order: .opencode-agents/<name>.session file, then a scan of
# the server's sessions for one whose first user message references the
# task file (works retroactively for agents spawned before tracking).
# Usage: agent-session.sh <feature-name>

NAME="${1:?Usage: agent-session.sh <feature-name>}"
ROOT="$(git rev-parse --show-toplevel)"
DATA="$ROOT/.opencode-agents"

[ -s "$DATA/$NAME.session" ] && { cat "$DATA/$NAME.session"; exit 0; }

PORT=""
[ -f "$DATA/$NAME.port" ] && PORT="$(cat "$DATA/$NAME.port")"
[ -n "$PORT" ] || exit 0

python3 - "$PORT" "$DATA/tasks/$NAME.md" <<'PY'
import json, sys, urllib.request

port, marker = sys.argv[1], sys.argv[2]
base = f"http://localhost:{port}"
try:
    with urllib.request.urlopen(f"{base}/session", timeout=5) as r:
        sessions = json.load(r)
except Exception:
    sys.exit(0)

sessions.sort(key=lambda s: s.get("time", {}).get("updated", 0), reverse=True)
for s in sessions[:40]:
    try:
        with urllib.request.urlopen(f"{base}/session/{s['id']}/message", timeout=8) as r:
            msgs = json.load(r)
    except Exception:
        continue
    first = next((m for m in msgs
                  if (m.get("info") or m).get("role") == "user"), None)
    if not first:
        continue
    text = " ".join(
        p.get("text", "") for p in first.get("parts", [])
        if isinstance(p, dict) and p.get("type") == "text")
    if marker in text:
        print(s["id"])
        break
PY
