# Architecture — feature-first Clean Architecture

Dependencies point inward: **Presentation → Domain ← Data**. Every feature is a
self-contained module:

```
lib/features/<feature>/
├── module.dart                              # Module: binds + routes
├── data/
│   ├── data.dart                            # layer barrel (no underscore)
│   ├── datasources/
│   │   ├── _datasources.dart                # leaf barrel (underscore prefix)
│   │   └── <feature>_datasource.dart        # I*Datasource + *DatasourceImpl, same file
│   └── repositories/
│       ├── _repositories.dart
│       └── <feature>_repository.dart        # *RepositoryImpl
├── domain/
│   ├── domain.dart
│   ├── repositories/
│   │   ├── _repositories.dart
│   │   └── <feature>_repository.dart        # abstract I*Repository contract
│   └── usecases/
│       ├── _usecases.dart
│       └── <verb_noun>_usecase.dart
└── presentation/
    ├── presentation.dart
    ├── bloc/
    │   ├── _bloc.dart
    │   └── <name>/{bloc.dart, event.dart, state.dart}
    └── screens/                              # NOT "pages/" — this repo uses "screens"
        ├── screens.dart
        └── <name>_screen.dart
```

## Rules

- **Domain layer never imports `package:flutter`** and never talks to a network client
  (`dio`, `http`) directly. It may depend on shared value types (e.g. `Equatable`).
- **Data layer** maps API/DB responses to models; models extend domain entities.
- **Presentation layer** is UI + state only — no business logic inside `build()`.
- **Barrels, three tiers:**
  - leaf directory → underscore-prefixed barrel (`_datasources.dart`, `_repositories.dart`,
    `_entities.dart`, `_usecases.dart`, `_bloc.dart`, `_widgets.dart`)
  - layer root → no underscore (`data.dart`, `domain.dart`, `presentation.dart`,
    `screens.dart`)
  - package root → `lib/<package_name>.dart`
  - Prefer importing the barrel over deep relative paths when one exists.
- **Dependencies**: if this project uses a shared "dependencies" package (a barrel
  package that re-exports third-party + local packages), add new third-party packages
  there — not to a feature's own `pubspec.yaml`. Check whether that pattern applies
  before adding a dependency; if this is a single-app project without that package,
  this rule doesn't apply.
- Screens dir is `screens/`; there is no `*_page.dart` suffix in this codebase's style.
- Cross-feature/cross-package sharing goes through a `*ModuleExported` class with
  `exportedBinds(Injector i)`, imported by the app's root module — not by features
  importing each other's internals directly.
