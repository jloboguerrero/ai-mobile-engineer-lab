---
name: flutter-feature
description: Scaffolds a complete feature-first Clean Architecture feature (module + data/domain/presentation layers + barrels + a first bloc) matching this project's conventions. Use when starting a new feature from scratch, before writing any of its code by hand.
allowed-tools: Read, Glob, Grep, Write, AskUserQuestion, Bash(ls:*)
---

# flutter-feature

Scaffolds one feature folder end to end, following `.claude/rules/architecture.md`,
`.claude/rules/bloc.md`, `.claude/rules/di-modular.md`, and
`.claude/rules/naming-and-style.md`. Read those four files first — this skill applies
them, it doesn't restate them.

## When to use

The user wants a brand-new feature (e.g. "add a notifications feature") and nothing
under `lib/features/<name>/` exists yet.

## Steps

1. Ask (or infer from the request) the feature's kebab-case name, its first entity, and
   its first usecase — you need at least one of each to scaffold meaningfully.
2. Check `lib/features/` for naming collisions and for the actual package/import prefix
   this project uses (read one existing feature's `module.dart` if any exists, to match
   real conventions instead of the generic templates below).
3. Create the folder tree from `templates/` (see below), substituting the feature name,
   entity name, and usecase name into filenames and class names.
4. Register the new `XModule` in the parent module that composes feature routes —
   search for where sibling modules are imported (e.g. `AppModule` or a `_GlobalModule`)
   and add the import + child route, matching the existing entries' style exactly.
5. Run `flutter analyze` on the new files before reporting done.
6. Do not write business logic beyond the stub — this skill produces the skeleton with
   one real usecase call wired through; the user fills in the rest.

## templates/

`templates/` holds the eight base files (datasource, repository ×2, entity, model,
usecase, module, bloc ×3, screen) with `{{Feature}}`/`{{feature}}`/`{{Entity}}`
placeholders. Read the matching rule file before instantiating each one rather than
guessing the shape from memory.
