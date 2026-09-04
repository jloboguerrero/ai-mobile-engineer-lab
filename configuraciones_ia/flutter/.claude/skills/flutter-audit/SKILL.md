---
name: flutter-audit
description: Audits a diff (working tree changes, or against a given git ref) against this project's six rule files and reports violations as a file:line table. Use before opening a PR, or whenever asked to review Dart code for repo-standard compliance rather than general code review.
allowed-tools: Read, Glob, Grep, Bash(git diff:*), Bash(git status:*), Bash(flutter analyze:*)
---

# flutter-audit

A cheap, mechanical pass — not a general code review. It only checks the six rules
below; for correctness/design issues use `/code-review` instead.

## Steps

1. Get the diff: `git diff <ref>...HEAD` if a ref is given, else `git diff` +
   `git status --short` for the working tree.
2. For each changed `.dart` file, check it against these rule files (read each once,
   not per-file):
   - `.claude/rules/architecture.md` — layer boundaries, barrel usage, `screens/` naming
   - `.claude/rules/bloc.md` — sealed/final/Model shape, `isClosed` guard present
   - `.claude/rules/di-modular.md` — bind order, `BindConfig` disposal present
   - `.claude/rules/naming-and-style.md` — member order, `I*`/`*Impl` naming, alpha params
   - `.claude/rules/error-handling.md` — try/catch lives in the bloc, not lower layers
   - `.claude/rules/testing.md` — new bloc/usecase/repository has a matching test file
3. Also run `flutter analyze` on the changed files and fold any errors/warnings in.
4. Report a table: `file:line | rule | violation`. No violations found is a valid,
   good outcome — say so plainly, don't invent nitpicks to fill the table.
5. Do not fix anything unless asked — this skill reports, it doesn't edit.
