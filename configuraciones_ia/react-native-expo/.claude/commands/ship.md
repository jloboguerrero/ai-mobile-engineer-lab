---
description: Pre-PR check — format, lint, typecheck, test, and a proposed commit message. Does not commit.
allowed-tools: Read, Glob, Grep, Bash(npx prettier:*), Bash(npx eslint:*), Bash(npm run lint:*), Bash(npx tsc:*), Bash(npm test:*), Bash(npx expo install --check:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*)
---

Prepare this change for review without committing:

1. `npx prettier --write` + `npx eslint --fix` on changed files.
2. `npm run lint` and `npx tsc --noEmit` — must be clean; fix (respecting `.claude/rules/`) or
   report exactly what blocks.
3. `npm test` — full suite. Report pass/fail; never skip failures silently.
4. If `package.json` changed: `npx expo install --check`. If native config changed
   (`app.config.ts`, plugins, native deps): say a **new dev build** is needed and OTA won't cover it
   (runtimeVersion = fingerprint).
5. If i18n changed: confirm en + es have the same keys.
6. Summarize the diff and propose a commit message (imperative). **Do not run `git commit`.**
