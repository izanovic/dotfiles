#!/usr/bin/env bash
set -euo pipefail

# Sync nexura submodule to the same branch as headstad.
# E.g. when headstad is on "test", nexura checks out "test" too.

ROOT="$(git rev-parse --show-toplevel)"
SUBMODULE="$ROOT/packages/nexura"

CURRENT_BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || echo "")"
[ -z "$CURRENT_BRANCH" ] && exit 0

# Check if the submodule repo has a matching branch
if git -C "$SUBMODULE" rev-parse --verify "$CURRENT_BRANCH" >/dev/null 2>&1; then
  git -C "$SUBMODULE" checkout "$CURRENT_BRANCH"
  git -C "$SUBMODULE" pull --ff-only origin "$CURRENT_BRANCH" 2>/dev/null || true
  git add "$SUBMODULE"
fi
