#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit).
# SHR responses carry full SSN and bank account numbers. This blocks the three ways
# they usually leak: console.*, logging/Sentry-ing a raw response, and sensitive field
# names used outside data/ (mappers) or tests.
set -uo pipefail

input="$(cat)"
file_path="$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty')"

[ -z "$file_path" ] && exit 0
[[ "$file_path" != *.ts && "$file_path" != *.tsx ]] && exit 0
[ ! -f "$file_path" ] && exit 0

is_test=0
[[ "$file_path" == *.test.ts || "$file_path" == *.test.tsx || "$file_path" == *.fixture.ts || "$file_path" == *.fixture.tsx || "$file_path" == */tools/mock-api/* ]] && is_test=1

problems=""

if [ $is_test -eq 0 ] && [[ "$file_path" != */core/monitoring.ts ]]; then
  hits="$(grep -nE '\bconsole\.(log|info|warn|error|debug)\(' "$file_path")"
  [ -n "$hits" ] && problems+=$'\n'"console.* is forbidden — report unexpected failures with reportError from @/core/monitoring:"$'\n'"$hits"
fi

hits="$(grep -nE '(reportError|Sentry\.(captureMessage|addBreadcrumb|setContext|setExtra))\([^)]*(\b(response|res|raw|dto|payload)\b|\.data\b)' "$file_path")"
[ -n "$hits" ] && problems+=$'\n'"Never log/send raw responses or DTOs (they contain PII):"$'\n'"$hits"

if [ $is_test -eq 0 ] && [[ "$file_path" != */data/* ]] && [[ "$file_path" != */core/api*.ts ]] && [[ "$file_path" != */direct-deposit/* ]]; then
  hits="$(grep -nE '\b(ssn|socialSecurity|accountNumber|routingNumber|bankAccountNumber)\b' "$file_path" | grep -vE 'last4|masked|Last4|Masked')"
  [ -n "$hits" ] && problems+=$'\n'"Sensitive field outside data/ (and Direct Deposit) — mappers must drop it (only last4/masked may travel):"$'\n'"$hits"
fi

if [ -n "$problems" ]; then
  echo "PII/logging guard failed for $file_path:$problems" >&2
  echo "See .claude/rules/security-pii.md." >&2
  exit 2
fi
exit 0
