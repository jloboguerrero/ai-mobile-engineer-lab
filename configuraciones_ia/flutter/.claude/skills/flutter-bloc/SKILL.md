---
name: flutter-bloc
description: Adds a new bloc (event.dart/state.dart/bloc.dart trio) to an existing feature, following this project's exact pattern (sealed events/states, single Model payload, isClosed guard, DI fallback), plus its bloc_test file. Use when a feature needs new/additional state management, not for scaffolding a whole feature.
allowed-tools: Read, Glob, Grep, Write, Edit
---

# flutter-bloc

Read `.claude/rules/bloc.md` and `.claude/rules/testing.md` before generating anything —
this skill applies those patterns, it does not restate them.

## Steps

1. Find an existing bloc in the target feature (or a sibling feature) to confirm the
   real import paths and package name — don't guess them.
2. Create `presentation/bloc/<name>/bloc.dart`, `event.dart`, `state.dart` following the
   shape in `.claude/rules/bloc.md`:
   - `sealed class` event/state bases, `final class` leaves, `@immutable`, `Equatable`.
   - One `<Name>Model` class in `state.dart` carrying all UI-relevant fields, with
     `copyWith`.
   - Every async handler ends with `if (isClosed) return;` right after each `await`,
     before the next `emit`.
   - Constructor dependencies optional with `?? Modular.get<T>()` fallback.
3. Register the bloc in the feature's `module.dart` under the `// Blocs` section, with
   `BindConfig(onDispose: (bloc) => unawaited(bloc.close()))`.
4. Write `test/.../bloc_test.dart` using `bloc_test`, mirroring the lib path — one
   `blocTest` per event, description `'emits [X] when add YEvent'`.
5. Run `flutter analyze` and `flutter test <path>` before reporting done.
