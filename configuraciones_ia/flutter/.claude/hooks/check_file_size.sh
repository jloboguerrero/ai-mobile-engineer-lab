#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit).
# Warns past 150 lines, blocks (exit 2) new/edited files past 300 — based on
# this codebase's real p90 (~134 lines/file). Non-fatal warning goes to stdout
# so it doesn't interrupt the flow; the hard block goes to stderr with exit 2.
set -uo pipefail

WARN_LINES=150
BLOCK_LINES=300

input="$(cat)"
file_path="$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')"

[ -z "$file_path" ] && exit 0
[[ "$file_path" != *.dart ]] && exit 0
[ ! -f "$file_path" ] && exit 0

lines="$(wc -l < "$file_path" | tr -d ' ')"

if [ "$lines" -gt "$BLOCK_LINES" ]; then
  echo "$file_path is $lines lines (limit ${BLOCK_LINES}). Split it — extract a widget, a usecase, or a private helper class into its own file before continuing." >&2
  exit 2
fi

if [ "$lines" -gt "$WARN_LINES" ]; then
  echo "Note: $file_path is $lines lines (target <= ${WARN_LINES}). Consider splitting it."
fi

exit 0
