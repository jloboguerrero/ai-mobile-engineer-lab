#!/usr/bin/env bash
# SessionStart hook. Emits JSON: additionalContext (model) + systemMessage (user).
set -uo pipefail
cd "${CLAUDE_PROJECT_DIR:-$PWD}" || exit 0

branch="$(git branch --show-current 2>/dev/null || echo 'not a git repo')"
status="$(git status --short 2>/dev/null)"
tree_state="clean"; [ -n "$status" ] && tree_state="dirty"

expo_sdk="unknown"; rn="unknown"
if [ -f package.json ]; then
  expo_sdk="$(jq -r '.dependencies.expo // "not installed"' package.json)"
  rn="$(jq -r '.dependencies["react-native"] // "not installed"' package.json)"
fi

if [ -d specs ]; then
  specs_line="specs/: $(find specs -maxdepth 1 -name '*.md' | wc -l | tr -d ' ') spec file(s)"
else
  specs_line="specs/: not present"
fi

features="none"
[ -d src/features ] && features="$(ls src/features 2>/dev/null | tr '\n' ' ')"

context="## Session context
- Branch: $branch · tree: $tree_state
- expo: $expo_sdk · react-native: $rn · APP_VARIANT: ${APP_VARIANT:-unset (development)}
- Features: $features
- $specs_line"
if [ "$tree_state" = "dirty" ]; then
  context="$context
\`\`\`
$status
\`\`\`"
fi

jq -n --arg ctx "$context" --arg msg "Session: $branch ($tree_state), expo $expo_sdk, $specs_line" \
  '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$ctx},systemMessage:$msg}'
exit 0
