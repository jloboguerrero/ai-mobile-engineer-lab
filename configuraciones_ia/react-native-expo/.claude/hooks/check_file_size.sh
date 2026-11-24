#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit).
# .ts/.tsx: warn > WARN, block > BLOCK. app/** route files must stay tiny (re-export only).
# Exempt: tests, generated, i18n json, tokens.
set -uo pipefail

WARN_LINES="${CLAUDE_WARN_LINES:-250}"
BLOCK_LINES="${CLAUDE_BLOCK_LINES:-450}"
ROUTE_LINES=15

input="$(cat)"
file_path="$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')"

[ -z "$file_path" ] && exit 0
[[ "$file_path" != *.ts && "$file_path" != *.tsx ]] && exit 0
[ ! -f "$file_path" ] && exit 0
case "$file_path" in
  *.test.ts|*.test.tsx|*/generated/*|*/tokens/*|*/mocks/*) exit 0 ;;
esac

lines="$(wc -l < "$file_path" | tr -d ' ')"
rel="${file_path#"${CLAUDE_PROJECT_DIR:-$PWD}"/}"

if [[ "$rel" == app/* ]] && [[ "$(basename "$rel")" != _layout.tsx ]] && [ "$lines" -gt "$ROUTE_LINES" ]; then
  echo "$rel is $lines lines. Route files in app/ only re-export a screen: export { TimeOffScreen as default } from '@/features/timeoff'. Move the code into the feature." >&2
  exit 2
fi

if [ "$lines" -gt "$BLOCK_LINES" ]; then
  echo "$rel is $lines lines (limit $BLOCK_LINES). Split it: extract components into ui/components/, logic into a hook or domain/ function." >&2
  exit 2
fi

if [ "$lines" -gt "$WARN_LINES" ]; then
  echo "Note: $rel is $lines lines (target <= $WARN_LINES). Consider splitting."
fi
exit 0
