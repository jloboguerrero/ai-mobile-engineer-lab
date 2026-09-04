---
description: Audit the current diff (or a given ref) against this project's coding rules
argument-hint: '[git-ref] (defaults to working tree changes)'
allowed-tools: Read, Glob, Grep, Bash(git diff:*), Bash(git status:*), Bash(flutter analyze:*)
---

Run the `flutter-audit` skill against: ${ARGUMENTS:-the working tree changes}.

Report a `file:line | rule | violation` table. If there are no violations, say so
plainly — don't invent nitpicks. This is a mechanical rules check, not a full code
review; suggest `/code-review` for correctness/design concerns.
