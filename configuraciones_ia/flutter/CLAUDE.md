# Flutter Project — Claude Instructions

This file is a **routing index**, not a manual. It is paid for on every request, so it
stays small; the detail lives in `.claude/rules/` and loads only when relevant.

## Stack

Flutter + Dart, `flutter_bloc`, `flutter_modular` (DI + routing), `equatable`,
feature-first Clean Architecture. Adjust the "Stack" and "Commands" sections below to
match the actual project before relying on them.

## Commands

```bash
flutter analyze              # static analysis — must be clean before any commit
dart format .                # format — required, single quotes, trailing commas
flutter test                 # unit + bloc tests
flutter test --coverage      # with coverage
dart run build_runner build --delete-conflicting-outputs   # generated code (mocks, json)
```

## Architecture (10 lines)

Feature-first, Clean Architecture, dependencies point inward
(`presentation → domain ← data`):

```
lib/features/<feature>/
├── module.dart                # DI binds + routes (flutter_modular)
├── data/{datasources,models,repositories}/
├── domain/{entities,repositories,usecases}/
└── presentation/{bloc,screens}/
```

## Rules index — read on demand

| Working on… | Read first |
|---|---|
| Folder layout, barrels, new feature | `.claude/rules/architecture.md` |
| Bloc/event/state files | `.claude/rules/bloc.md` |
| `module.dart`, DI, routes | `.claude/rules/di-modular.md` |
| File/class naming, member order, imports | `.claude/rules/naming-and-style.md` |
| try/catch, exceptions, `Result` | `.claude/rules/error-handling.md` |
| Any test file | `.claude/rules/testing.md` |

## Always-on rules (apply to every edit, no need to look them up)

1. Single quotes, required trailing commas, explicit types — no `dynamic`.
2. Never use `print()` — the linter forbids it (`avoid_print`).
3. Wrap fire-and-forget futures in `unawaited(...)`.
4. In every bloc handler, check `if (isClosed) return;` after each `await`, before `emit`.
5. Named parameters are alphabetical, in constructors and call sites alike.
6. Keep files ≤150 lines; split before 300. Widgets get extracted, not nested deeper.
7. Never hand-edit `*.g.dart`, `*.mocks.dart`, `*.freezed.dart`, or `lib/generated/**` —
   regenerate with `build_runner` instead.
8. Never add a third-party dependency to a feature's `pubspec.yaml` directly — see
   `architecture.md` for where dependencies actually live in this repo's setup.
9. Domain layer imports nothing from `package:flutter` and no HTTP client.
10. UI comes from the shared design-system package, not hardcoded colors/spacing.

## How to work in this repo

- Prefer `grep`/`glob` over reading whole files; read line ranges, not entire files,
  when you only need one function.
- Use a subagent for open-ended search or research — it burns its own context window,
  not this one.
- Reading files, running `flutter analyze`/`flutter test`/`git status`/`git diff` needs
  no confirmation — it's allow-listed in `.claude/settings.json`.
- Never commit or push without being asked. `/ship` prepares a commit message; it does
  not run `git commit`.
- If a feature-scoped spec exists (see `docs/04-spec-driven-workflow.md`), follow it —
  don't improvise architecture the spec already decided.
