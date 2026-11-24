---
name: rn-audit
description: Audits a diff (working tree or against a git ref) against this project's React Native rule files and lint/typecheck output, reporting violations as a file:line table. Use before a PR or when asked to check code for repo-standard compliance rather than general code review.
allowed-tools: Read, Glob, Grep, Bash(git diff:*), Bash(git status:*), Bash(npx eslint:*), Bash(npx tsc:*)
---

# rn-audit

Mechanical pass — for correctness/design use `/code-review`.

1. Diff: `git diff <ref>...HEAD` if a ref is given, else `git diff` + `git status --short`.
2. Run `npx eslint <changed .ts/.tsx>` and `npx tsc --noEmit`; fold results in
   (covers ordering, boundaries, no-console, hooks deps, any).
3. Check by reading (lint can't): read each rule file once.
   - `architecture.md` — app/ route files 1-line; ui/ doesn't call xApi; domain/ pure
   - `data-and-api.md` — DTO is a Pick; mapper drops PII; no try/catch in UI/hooks; UI branches on `kind`
   - `server-state.md` — key factory used; no query data copied to state/store; mutations no retry; prefix invalidation
   - `client-state.md` — narrow selectors; no new store without reason
   - `forms.md` — three files; `values` for server data; Save disabled rule
   - `i18n.md` — no hardcoded strings; en + es both updated
   - `styling-ds.md` — no hex / magic numbers; tokens only
   - `security-pii.md` — no PII in logs/params/push/storage
   - `testing.md` — new mapper/rule/schema has a test; new screen/mutation has integration test
4. Report `file:line | rule | violation`, most severe first. None found is a valid outcome.
5. Don't fix unless asked.
