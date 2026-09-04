# Naming, member order, imports

## Files

`snake_case.dart`, named after the **concept**, not the layer role — the abstract
contract and its implementation can share a filename in different directories:

- `domain/repositories/medication_repository.dart` → `IMedicationRepository`
- `data/repositories/medication_repository.dart` → `MedicationRepositoryImpl`

Common suffixes: `_repository.dart`, `_usecase.dart`, `_screen.dart`,
`_datasource.dart`, `_entity.dart`, `_model.dart`, `_module.dart`, `_ext.dart`. There is
no `_page.dart`, no `_widget.dart`, no `_repository_impl.dart` in this style — the
"Impl" lives in the class name, not the filename.

## Classes

| Role | Convention | Example |
|---|---|---|
| Abstract contract | `IThing` | `INewPasswordRepository` |
| Implementation | `ThingImpl` | `NewPasswordRepositoryImpl` |
| Use case | `VerbNounUsecase`, single `execute()` method | `ResetPasswordUsecase` |
| Entity | `XEntity extends Equatable` | `MedicationEntity` |
| Model (data layer) | `XModel extends XEntity`, `factory XModel.fromJson(...)` | `MedicationModel` |
| Module | `XModule` (feature), `XModuleExported` (cross-package) | `WalletCoreModulesExported` |
| Private widget/class | `_` prefix | `_NewPasswordContent` |

## Member order inside a class

This repo's style deviates from the common Dart default — **`final` fields come after
the constructor**, not before:

1. `static const` fields
2. Constructor(s) — `const X({required this.a}) : _b = b;`, private fields assigned via
   the initializer list
3. Named factories (`factory X.fromJson(...)`)
4. `final` instance fields
5. `@override` members
6. Public methods / getters
7. Private methods (`_onXEvent`, `_listener`, `_handleResponse`)

Constructors are `const` wherever possible.

## Formatting

- Named parameters: **alphabetical order**, in both constructors and call sites.
- Trailing commas: required.
- Quotes: single.
- Explicit return and parameter types — avoid `dynamic`.
- Comments: in English unless the surrounding file is already in Spanish — match the
  file, don't mix.

## Import order (5 groups, blank line between each)

1. `dart:*` — alphabetical
2. `package:` third-party — alphabetical
3. `package:flutter` — its own group when other third-party packages are also present
4. Local/project packages — alphabetical, prefer barrel imports over deep paths
5. Relative imports — alphabetical

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mobile_design_system/mobile_design_system.dart';
import 'package:mobile_patient_core/mobile_patient_core.dart';

import 'bloc/_bloc.dart';
import 'utils/_utils.dart';
```

BLoC files: real imports only in `bloc.dart`; `event.dart`/`state.dart` are
`part of 'bloc.dart'` and carry no imports of their own.
