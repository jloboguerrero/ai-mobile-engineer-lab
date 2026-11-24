#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit).
# prettier --write + eslint --fix on the touched .ts/.tsx file (fixes import/prop/key
# ordering automatically), then fails (exit 2) on any remaining eslint error so the
# model fixes it. Optional typecheck: CLAUDE_HOOK_TSC=1 (slow on big repos).
set -uo pipefail

input="$(cat)"
file_path="$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')"

[ -z "$file_path" ] && exit 0
[[ "$file_path" != *.ts && "$file_path" != *.tsx ]] && exit 0
[ ! -f "$file_path" ] && exit 0

cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0
[ ! -d node_modules ] && exit 0   # project not installed yet — nothing to run

npx --no-install prettier --write "$file_path" >/dev/null 2>&1

lint_output="$(npx --no-install eslint --fix --max-warnings=0 "$file_path" 2>&1)"
lint_status=$?
if [ $lint_status -ne 0 ]; then
  echo "eslint found issues in $file_path after --fix (ordering is auto-fixed; what's left needs a real change):" >&2
  echo "$lint_output" >&2
  exit 2
fi

if [ "${CLAUDE_HOOK_TSC:-0}" = "1" ]; then
  tsc_output="$(npx --no-install tsc --noEmit --incremental 2>&1)"
  if [ $? -ne 0 ]; then
    echo "tsc --noEmit failed:" >&2
    echo "$tsc_output" | head -40 >&2
    exit 2
  fi
fi

exit 0
