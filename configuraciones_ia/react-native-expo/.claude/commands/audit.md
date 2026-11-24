---
description: Audit the current diff (or a given ref) against this project's React Native rules
argument-hint: '[git-ref] (defaults to working tree changes)'
allowed-tools: Read, Glob, Grep, Bash(git diff:*), Bash(git status:*), Bash(npx eslint:*), Bash(npx tsc:*)
---

Run the `rn-audit` skill against: ${ARGUMENTS:-the working tree changes}.

Report a `file:line | rule | violation` table. No violations → say so plainly. Mechanical
rules check, not code review; suggest `/code-review` for correctness.
