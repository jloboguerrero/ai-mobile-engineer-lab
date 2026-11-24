---
description: Pre-PR check — format, lint, typecheck, test, and a proposed commit message. Does not commit.
allowed-tools: Read, Glob, Grep, Bash(npx prettier:*), Bash(npx eslint:*), Bash(npm run lint:*), Bash(npm run verify:*), Bash(npx tsc:*), Bash(npm test:*), Bash(npx expo install --check:*), Bash(git status:*), Bash(git diff:*), Bash(git log:*)
---

Prepare this change for review without committing:

1. `npx prettier --write` + `npx eslint --fix` on changed files.
2. `npm run verify` (typecheck, lint, format:check, tests, expo-doctor) — must be clean; fix
   (respecting `.claude/rules/`) or report exactly what blocks.
3. If `package.json` changed: `npx expo install --check`. If native config changed (`app.json`,
   `app.config.ts`, plugins, native deps): say a **new development build** is needed and OTA won't
   cover it (runtimeVersion = fingerprint).
4. If i18n changed: confirm `en.ts` and `es.ts` have the same keys (tsc checks it).
5. If mock data changed: `node tools/mock-api/privacy-scan.mjs`.
6. Fill `docs/pull-request-template.md` (privacy, accessibility, tests; say which checks were done
   on a phone).
7. Summarize the diff and propose a conventional commit message in English (`feat:`, `fix:`…)
   with a body that says why. **Do not run `git commit`.**
