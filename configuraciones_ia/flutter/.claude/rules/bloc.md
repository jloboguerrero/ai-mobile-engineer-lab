# Bloc conventions

- State management is `flutter_bloc` only (no Riverpod, Provider, GetX, Cubit-only mix
  unless the project has established otherwise).
- One bloc = **three files**, joined with `part`/`part of`:
  - `bloc.dart` — the class, all real imports live here only
  - `event.dart` — `part of 'bloc.dart';`
  - `state.dart` — `part of 'bloc.dart';`
- Trigger changes by `bloc.add(SomeEvent())`. Never expose public methods on the bloc
  that mutate state directly.
- Handlers are named `_on<EventName>` and registered in the constructor body, in the
  same order the events are declared.
- **After every `await` inside a handler, check `if (isClosed) return;` before the next
  `emit(...)`.** This is the single most-violated rule when writing async handlers —
  check it explicitly before finishing any bloc edit.
- Constructor dependencies are optional with a DI fallback, so the bloc is testable
  without the DI container:
  ```dart
  MedicationBloc({UpdateMedicationStatusUsecase? updateMedicationStatusUsecase})
    : _updateMedicationStatusUsecase =
          updateMedicationStatusUsecase ?? Modular.get<UpdateMedicationStatusUsecase>(),
      super(const MedicationInitialState(MedicationModel())) {
    on<UpdateMedicationStatusEvent>(_onUpdateMedicationStatusEvent);
  }
  ```

## Events and states shape

```dart
// event.dart
part of 'bloc.dart';

@immutable
sealed class NewPasswordEvent extends Equatable {
  const NewPasswordEvent();
  @override
  List<Object?> get props => [];
}

final class LoadAuthorizationKeyEvent extends NewPasswordEvent {
  const LoadAuthorizationKeyEvent({required this.authorizationKey});
  final String authorizationKey;
  @override
  List<Object?> get props => [authorizationKey];
}
```

```dart
// state.dart — one payload Model carried by every state
part of 'bloc.dart';

@immutable
sealed class NewPasswordState extends Equatable {
  const NewPasswordState(this.model);
  final NewPasswordModel model;
  @override
  List<Object> get props => [model];
}

final class NewPasswordInitial extends NewPasswordState {
  const NewPasswordInitial(super.model);
}

final class SendingResetPasswordState extends NewPasswordState {
  const SendingResetPasswordState(super.model);
}

class NewPasswordModel extends Equatable {
  const NewPasswordModel({
    this.authorizationKey = '',
    this.password = '',
    this.passwordValid = false,
  });

  final String authorizationKey;
  final String password;
  final bool passwordValid;

  NewPasswordModel copyWith({...}) { ... }

  bool get showButton => passwordValid && password.isNotEmpty;

  @override
  List<Object?> get props => [authorizationKey, password, passwordValid];
}
```

Key points: `sealed class` bases, `final class` leaves, `@immutable`, `Equatable`.
Events end in `Event`. States end in `State` except the `<Name>Initial` marker. The
mutable payload class ends in `Model` and lives inside `state.dart`, holding all the
UI-relevant data as one object that every state carries via `super.model`.

## Screen wiring

```dart
class NewPasswordScreen extends StatelessWidget {
  const NewPasswordScreen({required this.authorizationKey});
  final String authorizationKey;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<NewPasswordBloc>()
        ..add(LoadAuthorizationKeyEvent(authorizationKey: authorizationKey)),
      child: BlocListener<NewPasswordBloc, NewPasswordState>(
        listener: _listener,
        child: const _NewPasswordContent(),
      ),
    );
  }

  void _listener(BuildContext context, NewPasswordState state) { ... }
}
```

The public `*Screen` widget only wires the bloc + listener; the real UI lives in a
private `_XContent` widget. Feature-local sub-widgets are pulled in via
`part 'widgets/some_widget.dart';` when they're tightly coupled to the screen.
