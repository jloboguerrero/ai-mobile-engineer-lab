---
name: rn-audit
description: Audits a diff (working tree or against a git ref) against this project's React Native rule files and lint/typecheck output, reporting violations as a file:line table. Use before a PR or when asked to check code for repo-standard compliance rather than general code review.
allowed-tools: Read, Glob, Grep, Bash(git diff:*), Bash(git status:*), Bash(npx eslint:*), Bash(npx tsc:*)
---

# rn-audit

Mechanical pass — for correctness/design use `/code-review`.

1. Diff: `git diff <ref>...HEAD` if a ref is given, else `git diff` + `git status --short`.
2. Run `npx eslint <changed .ts/.tsx>` and `npx tsc --noEmit`; fold results in
   (covers ordering, layers, role comparisons, try/useQueryClient in tsx, no-console, hooks deps).
3. Check by reading (lint can't): read each rule file once.
   - `architecture.md` — thin routes; components don't import `data/`; domain pure; nothing from
     the "what we don't do" list
   - `data-and-api.md` — raw types only read fields; allow-list mapper; failures read with `apiErrorOf`
   - `server-state.md` — key factory; `CachePolicy`; hooks take ids; no query data in state;
     mutations never retried; other features' keys via `invalidateX()`
   - `hooks-and-usecases.md` — orchestration in a use case, not in a component or provider
   - `forms.md` — rules in domain; `useFormState`; Save disabled rule
   - `i18n.md` — no hardcoded strings; en + es both updated
   - `styling-ds.md` — no hex / magic numbers outside `theme.ts`
   - `security-pii.md` — no PII in logs/params/push/storage; sign-out list updated if a new
     place holds personal data
   - `testing.md` — new mapper has a privacy contract test; logic fix has a regression test
4. Report `file:line | rule | violation`, most severe first. None found is a valid outcome.
5. Don't fix unless asked.
