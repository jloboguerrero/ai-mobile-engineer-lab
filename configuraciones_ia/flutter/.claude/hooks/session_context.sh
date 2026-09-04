#!/usr/bin/env bash
# SessionStart hook.
# Injects cheap, high-value context up front so the model doesn't have to
# spend tool calls discovering it: current branch, working tree status, and
# whether a specs/ folder (spec-driven workflow) exists.
#
# Command hooks must emit JSON — plain stdout is ignored by Claude Code.
# `additionalContext` goes silently into the model's context; `systemMessage`
# is what's shown to the user in the terminal.
set -uo pipefail

branch="$(git branch --show-current 2>/dev/null || echo 'not a git repo')"
status="$(git status --short 2>/dev/null)"

if [ -n "$status" ]; then
  tree_state="dirty"
else
  tree_state="clean"
fi

if [ -d "specs" ]; then
  spec_count="$(find specs -maxdepth 1 -name '*.md' | wc -l | tr -d ' ')"
  specs_line="specs/: $spec_count spec file(s) present"
else
  specs_line="specs/: not present (no spec-driven workflow in this repo yet)"
fi

context="## Session context
- Branch: $branch
- Working tree: $tree_state"
if [ "$tree_state" = "dirty" ]; then
  context="$context
\`\`\`
$status
\`\`\`"
fi
context="$context
- $specs_line"

summary="branch $branch, tree $tree_state, $specs_line"

jq -n \
  --arg ctx "$context" \
  --arg msg "Session context: $summary" \
  '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: $ctx
    },
    systemMessage: $msg
  }'

exit 0
