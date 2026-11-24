#!/usr/bin/env bash
# install.sh — copy an AI-engineering kit into a target project.
#
# Usage:
#   ./install.sh <stack> <path-to-project> [--dry-run]
#     stack: flutter | react-native-expo
#   ./install.sh <path-to-project> [--dry-run]       # legacy form → flutter
#
# Never overwrites an existing CLAUDE.md or lint config — writes <file>.new next to it.
# Makes hooks executable.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACK=""
DEST=""
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    flutter|react-native-expo) STACK="$arg" ;;
    *) DEST="$arg" ;;
  esac
done
STACK="${STACK:-flutter}"
KIT_DIR="$ROOT/$STACK"

if [ -z "$DEST" ]; then
  echo "Usage: $0 <flutter|react-native-expo> <path-to-project> [--dry-run]" >&2
  exit 1
fi
[ -d "$DEST" ] || { echo "Target directory does not exist: $DEST" >&2; exit 1; }
[ -d "$KIT_DIR" ] || { echo "Unknown stack: $STACK" >&2; exit 1; }

echo "Installing $STACK kit from $KIT_DIR into $DEST"
[ "$DRY_RUN" -eq 1 ] && echo "(dry run — nothing will be written)"

copy() {
  local src="$1" dst="$2"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "would copy: $src -> $dst"
  else
    mkdir -p "$(dirname "$dst")"
    cp -R "$src" "$dst"
    echo "copied: $dst"
  fi
}

copy_safe() {  # never clobber
  local name="$1"
  [ -e "$KIT_DIR/$name" ] || return 0
  if [ -e "$DEST/$name" ]; then
    echo "$name already exists — writing $name.new instead."
    copy "$KIT_DIR/$name" "$DEST/$name.new"
  else
    copy "$KIT_DIR/$name" "$DEST/$name"
  fi
}

copy_safe CLAUDE.md
copy "$KIT_DIR/AGENTS.md" "$DEST/AGENTS.md"

case "$STACK" in
  flutter) copy_safe analysis_options.yaml ;;
  react-native-expo) copy_safe eslint.config.js ;;
esac

if [ -d "$DEST/.claude" ] && [ "$DRY_RUN" -eq 0 ]; then
  # merge into existing .claude without deleting what's there
  mkdir -p "$DEST/.claude"
  cp -R "$KIT_DIR/.claude/." "$DEST/.claude/"
  echo "merged: $DEST/.claude"
else
  copy "$KIT_DIR/.claude" "$DEST/.claude"
fi
copy "$KIT_DIR/.cursor" "$DEST/.cursor"

if [ "$DRY_RUN" -eq 0 ]; then
  chmod +x "$DEST"/.claude/hooks/*.sh 2>/dev/null || true
fi

echo
echo "Done. Merge any *.new files by hand."
if [ "$STACK" = "react-native-expo" ]; then
  echo "Lint deps: npx expo install -- --save-dev eslint eslint-config-expo eslint-plugin-perfectionist eslint-plugin-boundaries @tanstack/eslint-plugin-query eslint-config-prettier prettier"
  echo "Hooks need: jq."
fi
