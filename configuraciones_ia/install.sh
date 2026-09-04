#!/usr/bin/env bash
# install.sh — copy the Flutter AI-engineering kit into a target project.
#
# Usage:
#   ./install.sh <path-to-flutter-project> [--dry-run]
#
# Copies flutter/{.claude,.cursor,AGENTS.md,analysis_options.yaml} into the
# target. Never overwrites an existing CLAUDE.md — writes CLAUDE.md.new next
# to it instead, and tells you to merge by hand. Makes hooks executable.

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/flutter"
DEST=""
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    *) DEST="$arg" ;;
  esac
done

if [ -z "$DEST" ]; then
  echo "Usage: $0 <path-to-flutter-project> [--dry-run]" >&2
  exit 1
fi

if [ ! -d "$DEST" ]; then
  echo "Target directory does not exist: $DEST" >&2
  exit 1
fi

echo "Installing kit from $KIT_DIR into $DEST"
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

# CLAUDE.md — never clobber an existing one.
if [ -f "$DEST/CLAUDE.md" ]; then
  echo "CLAUDE.md already exists at destination — writing CLAUDE.md.new instead."
  copy "$KIT_DIR/CLAUDE.md" "$DEST/CLAUDE.md.new"
else
  copy "$KIT_DIR/CLAUDE.md" "$DEST/CLAUDE.md"
fi

copy "$KIT_DIR/AGENTS.md" "$DEST/AGENTS.md"

if [ -f "$DEST/analysis_options.yaml" ]; then
  echo "analysis_options.yaml already exists — writing analysis_options.yaml.new instead."
  copy "$KIT_DIR/analysis_options.yaml" "$DEST/analysis_options.yaml.new"
else
  copy "$KIT_DIR/analysis_options.yaml" "$DEST/analysis_options.yaml"
fi

copy "$KIT_DIR/.claude" "$DEST/.claude"
copy "$KIT_DIR/.cursor" "$DEST/.cursor"

if [ "$DRY_RUN" -eq 0 ]; then
  chmod +x "$DEST"/.claude/hooks/*.sh 2>/dev/null || true
fi

echo
echo "Done. Review CLAUDE.md.new / analysis_options.yaml.new if they were created"
echo "instead of overwriting existing files, and merge by hand."
