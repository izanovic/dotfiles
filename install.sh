#!/usr/bin/env bash

set -euo pipefail

CONFIG_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$CONFIG_DIR"

echo "Installing configs from: $CONFIG_REPO"
echo

for source in "$CONFIG_REPO"/*; do
  name="$(basename "$source")"

  # Don't symlink the Git repo's own files
  [[ "$name" == ".git" ]] && continue
  [[ "$name" == "install.sh" ]] && continue

  target="$CONFIG_DIR/$name"

  # Already correctly linked
  if [[ -L "$target" && "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then
    echo "✓ $name already linked"
    continue
  fi

  # Existing file/directory: move it out of the way
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/"
    echo "→ Backed up existing $name"
  fi

  ln -s "$source" "$target"
  echo "✓ Linked $name"
done

echo
echo "Done."

if [[ -d "$BACKUP_DIR" ]]; then
  echo
  echo "Existing configs were backed up to:"
  echo "  $BACKUP_DIR"
fi
