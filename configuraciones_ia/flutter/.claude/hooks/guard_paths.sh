#!/usr/bin/env bash
# PreToolUse hook (Edit|Write|MultiEdit).
# Blocks writes to generated/build/secret paths, and blocks adding a dependency
# directly to a feature's pubspec.yaml (this repo centralizes deps elsewhere).
# Exit 2 = block the tool call; stderr is shown to the model.
set -euo pipefail

input="$(cat)"
file_path="$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')"

[ -z "$file_path" ] && exit 0

blocked_patterns='\.g\.dart$|\.freezed\.dart$|\.mocks\.dart$|/lib/generated/|/build/|/\.dart_tool/|build_config/.*\.json$|\.env(\..*)?$|\.jks$|\.keystore$'

if echo "$file_path" | grep -qE "$blocked_patterns"; then
  echo "Blocked: '$file_path' is generated/build/secret and must not be hand-edited. Regenerate with build_runner or edit the source it derives from instead." >&2
  exit 2
fi

# Block editing a feature-level pubspec.yaml to add a dependency — this project's
# convention (see .claude/rules/architecture.md) is to centralize third-party deps.
if echo "$file_path" | grep -qE 'features/.*pubspec\.yaml$'; then
  echo "Blocked: don't add dependencies to a feature's pubspec.yaml directly. See .claude/rules/architecture.md for where dependencies belong in this project." >&2
  exit 2
fi

exit 0
