# Dependency injection — flutter_modular

Every feature is a `Module`. Registration order and comments matter for readability
and are consistent across this codebase's style:

```dart
final class NewPasswordModule extends Module {
  static const routeName = '/auth/new-password/';

  @override
  void binds(Injector i) {
    // Repositories
    i.addLazySingleton<NewPasswordRepositoryImpl>(
      () => NewPasswordRepositoryImpl(
        iNewPasswordDatasource: NewPasswordDatasourceImpl(
          httpClient: Modular.get<ApiWithoutTokenImpl>(),
        ),
      ),
    );

    // Usecases
    i.addSingleton<ResetPasswordUsecase>(
      () => ResetPasswordUsecase(
        iNewPasswordRepository: i<NewPasswordRepositoryImpl>(),
      ),
    );

    // Blocs
    i.add(
      NewPasswordBloc.new,
      config: BindConfig<NewPasswordBloc>(
        onDispose: (bloc) => unawaited(bloc.close()),
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      Modular.initialRoute,
      child: (_) => NewPasswordScreen(authorizationKey: r.args.data ?? ''),
    );
  }
}
```

## Rules

1. `static const routeName` at the top of the module, if the feature is routed.
2. `binds()` is organized in this order, each with a `// Section` comment: Repositories
   → Usecases → Blocs. Don't interleave.
3. **Every bloc bind must dispose the bloc**:
   `config: BindConfig<XBloc>(onDispose: (bloc) => unawaited(bloc.close()))`.
4. Prefer constructor tear-offs (`NewPasswordBloc.new`) over lambdas when the
   constructor signature matches exactly.
5. Cross-package sharing goes through a `*ModuleExported extends Module` with
   `exportedBinds(Injector i)`, imported by the composing module — never by one
   feature reaching into another feature's `module.dart` directly.
6. Constructor DI params are named after the interface, camelCase, keeping the `i`
   prefix: `required INewPasswordRepository iNewPasswordRepository`, assigned to
   `_iNewPasswordRepository`.
