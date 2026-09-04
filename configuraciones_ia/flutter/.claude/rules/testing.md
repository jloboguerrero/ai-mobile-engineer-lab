# Testing

- `test/` mirrors the `lib/` path exactly:
  `lib/features/shared/bloc/app_config/app_config_bloc.dart` →
  `test/features/shared/bloc/app_config/app_config_bloc_test.dart`.
- Mocking: `mockito` + `build_runner` codegen. `*.mocks.dart` files are generated and
  **committed** — never hand-edit them, regenerate with
  `dart run build_runner build --delete-conflicting-outputs`.
- Bloc tests use `bloc_test`.

## Shape of a bloc test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'app_config_bloc_test.mocks.dart';

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<AppPreferences>(onMissingStub: OnMissingStub.returnDefault),
  ],
)
void main() {
  late AppPreferences appPreferences;

  setUp(() async {
    appPreferences = MockAppPreferences();
  });

  AppConfigBloc buildBloc() => AppConfigBloc(preferences: appPreferences);

  group('AppConfigBloc', () {
    blocTest(
      'emits [AppConfigThemeLoadedState] when add AppInitEvent',
      build: buildBloc,
      act: (bloc) => bloc.add(AppInitEvent(appBrightness: Brightness.dark)),
      expect: () => [isA<AppConfigThemeLoadedState>()],
    );
  });
}
```

Conventions:
- `late` dependencies + `setUp` to construct mocks fresh per test.
- A local `buildBloc()` helper instead of repeating the constructor call.
- One `group` per bloc/class under test.
- `blocTest` descriptions read as `'emits [X] when add YEvent'`.
- Prefer `isA<SomeState>()` when only the type matters, a full equatable instance when
  the payload matters too.

Before considering an implementation task done: `flutter test` must pass, and any new
bloc/usecase/repository should have a corresponding test file, not just the happy path.
