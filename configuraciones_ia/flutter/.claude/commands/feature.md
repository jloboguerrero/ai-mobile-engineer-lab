---
description: Design a feature spec, then scaffold it against this project's conventions
argument-hint: <short feature description>
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion, Bash(ls:*), Bash(flutter analyze:*)
---

Feature request: $ARGUMENTS

1. If a `/spec` skill is available and `specs/` conventions apply to this repo, run the
   spec-driven flow first (design via `/spec`, get it to `Approved`, then `/spec-impl`
   to branch and implement) — don't duplicate that flow here.
2. Otherwise, use the `flutter-feature` skill to scaffold
   `lib/features/<slug>/` (module + data/domain/presentation + a first bloc), following
   `.claude/rules/architecture.md`, `.claude/rules/bloc.md`, `.claude/rules/di-modular.md`.
3. Register the new module in the parent module's routes.
4. Run `flutter analyze` on the new files and report the result.
5. Do not write tests or implement business logic beyond the stub unless asked —
   this command produces the skeleton; use `flutter-bloc` or manual edits for the rest.
