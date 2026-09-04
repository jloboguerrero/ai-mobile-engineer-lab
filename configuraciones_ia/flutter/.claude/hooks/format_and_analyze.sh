#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit).
# Formats the touched .dart file and runs `flutter analyze` on it.
# Exit 2 on ANY analyzer finding (error, warning, or info — avoid_print and
# prefer_single_quotes are `info`-level lints, not `error`, so this must not
# be scoped to `error` only) so Claude sees the output and fixes it without
# the human needing to look.
set -uo pipefail

input="$(cat)"
file_path="$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')"

[ -z "$file_path" ] && exit 0
[[ "$file_path" != *.dart ]] && exit 0
[ ! -f "$file_path" ] && exit 0

dart format "$file_path" >/dev/null 2>&1

analyze_output="$(flutter analyze "$file_path" 2>&1)"
analyze_status=$?

if [ $analyze_status -ne 0 ] && echo "$analyze_output" | grep -qE '^\s*(error|warning|info)\s+•'; then
  echo "flutter analyze found issues in $file_path (this blocks on any error/warning/info-level finding, since several of this repo's rules — avoid_print, prefer_single_quotes — are info-level lints):" >&2
  echo "$analyze_output" >&2
  exit 2
fi

exit 0
