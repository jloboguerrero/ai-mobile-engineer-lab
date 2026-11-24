#!/usr/bin/env bash
# loop.sh — headless iteration loop for an approved spec.
#
# Iterates `claude -p` against a spec's implementation plan, validating each
# iteration with the stack's static checks + tests, until the acceptance
# criteria pass or --max-iter is reached. Never commits, never pushes, never
# skips permissions — runs under whatever .claude/settings.json allows.
#
# Usage:
#   scripts/loop.sh --spec specs/03-notifications.md [--max-iter 5] [--dry-run]
#
# Requires: claude CLI on PATH, jq, a Flutter or React Native/Expo project root as cwd.
# Stack is detected: pubspec.yaml → flutter; package.json → react-native-expo.

set -euo pipefail

SPEC=""
MAX_ITER=5
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    --spec) SPEC="$2"; shift 2 ;;
    --max-iter) MAX_ITER="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [ -z "$SPEC" ]; then
  echo "Usage: $0 --spec <path-to-spec.md> [--max-iter N] [--dry-run]" >&2
  exit 1
fi

if [ ! -f "$SPEC" ]; then
  echo "Spec not found: $SPEC" >&2
  exit 1
fi

if ! grep -qiE '\*\*(Status|Estado)\:\*\*\s*(Approved|Aprobado|Aprovado|Approuvé|Genehmigt|Approvato)' "$SPEC"; then
  echo "Refusing to loop: $SPEC does not appear to be Approved. This loop only" >&2
  echo "iterates on approved specs — approve it (a human decision) first, or" >&2
  echo "use /spec to keep drafting it." >&2
  exit 1
fi

if [ -n "$(git status --short 2>/dev/null)" ] && [ "$DRY_RUN" -eq 0 ]; then
  echo "Working tree is dirty. Commit, stash, or run in an isolated worktree" >&2
  echo "before looping — this script will not stash on your behalf." >&2
  exit 1
fi

if [ -f pubspec.yaml ]; then
  STACK=flutter
  TOOLS="Read,Edit,Write,Grep,Glob,Bash(flutter analyze:*),Bash(flutter test:*),Bash(dart format:*)"
elif [ -f package.json ]; then
  STACK=react-native-expo
  TOOLS="Read,Edit,Write,Grep,Glob,Bash(npx tsc:*),Bash(npx eslint:*),Bash(npm run lint:*),Bash(npm test:*),Bash(npx jest:*)"
else
  echo "Can't detect stack (no pubspec.yaml or package.json in cwd)." >&2
  exit 1
fi

verify() {  # returns 0 when static checks and tests are clean
  if [ "$STACK" = flutter ]; then
    flutter analyze 2>&1 | tee -a "$1" | grep -q '^\s*error' && return 1
    flutter test 2>&1 | tee -a "$1" | grep -qE '^\s*(No tests found\s*$|.*failed.*)' && return 1
  else
    npx tsc --noEmit 2>&1 | tee -a "$1" || return 1
    npm run lint 2>&1 | tee -a "$1" || return 1
    npm test -- --ci 2>&1 | tee -a "$1" || return 1
  fi
  return 0
}

LOG_DIR=".loop/$(basename "${SPEC%.md}")-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$LOG_DIR"
echo "Logging to $LOG_DIR"

if [ "$DRY_RUN" -eq 1 ]; then
  echo "[dry-run] Would iterate up to $MAX_ITER times against $SPEC."
  exit 0
fi

for i in $(seq 1 "$MAX_ITER"); do
  echo "=== Iteration $i/$MAX_ITER ==="

  prompt="Implement the next unfinished step of the plan in $SPEC. Follow \
CLAUDE.md and .claude/rules/*.md exactly. Make the smallest change that \
completes one plan step and leaves the system runnable. Do not commit. \
Stop after this one step."

  claude -p "$prompt" --allowedTools "$TOOLS" \
    2>&1 | tee "$LOG_DIR/iter-$i-transcript.log"

  echo "--- verifying ---" | tee -a "$LOG_DIR/iter-$i-check.log"
  if verify "$LOG_DIR/iter-$i-check.log"; then
    echo "Static checks and tests clean after iteration $i ($STACK)."
    echo "Acceptance criteria are not verified automatically — review $SPEC's"
    echo "acceptance criteria list by hand before calling this done."
    break
  else
    echo "Checks failing after iteration $i — continuing to next iteration."
  fi

  git diff --stat | tee -a "$LOG_DIR/iter-$i-diffstat.log"
done

echo
echo "Loop finished. Working tree left uncommitted — review the diff:"
git status --short
echo
echo "Next: verify acceptance criteria in $SPEC by hand, then commit yourself."
