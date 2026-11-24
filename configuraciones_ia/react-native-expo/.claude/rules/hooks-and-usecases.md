# Custom hooks vs use cases

A **hook** (`useX`) gives a component state, data or effects. In React a custom hook replaces
what a Bloc/Cubit did in Flutter. A **use case** is a plain async/pure function in `domain/`
for orchestration or business rules — no React inside.

## Decision

| Situation | Do |
|---|---|
| Screen needs one endpoint | hook in `queries/` → `xApi` (no use case) |
| Write to one endpoint | `useMutation` in `queries/mutations.ts` |
| Several calls + rules (bootstrap, pick assignment, build timesheet weeks) | use case in `domain/usecases/` called from a `queryFn`/`mutationFn` |
| Pure calculation (allocation sums 100 %, hours left) | function in `domain/rules.ts` |
| Form state | React Hook Form (`forms.md`) |
| Global auth state | Zustand (`client-state.md`) |
| UI-only behaviour reused by screens (debounce, keyboard, countdown) | hook in `ui/` or `core/` |

## Flutter → React equivalences

| Flutter | React here |
|---|---|
| Bloc/Cubit that fetches | `useQuery` hook |
| Bloc emitting loading/success/error states | `query.isPending` / `query.error` / `query.data` |
| Form bloc | React Hook Form + Zod |
| Global bloc (auth) | Zustand store |
| `BlocListener` (side effect on state change) | `onSuccess`/`onError` of mutation, or route guard |
| `isClosed` guard after await | not needed: TanStack ignores results for unmounted observers |
| InheritedWidget / Provider | React Context |
| `flutter_modular` binds | factories + `di.ts` |
| `Modular.get<T>()` fallback in constructor | factory takes deps as args; tests use MSW |
| Usecase class with `execute()` | plain function `bootstrapSession(deps, args)` |
| ThemeData / ThemeExtension | Unistyles theme |
| `Equatable` | not needed — structural data, compare with selectors/`useShallow` |

## Use case shape

```ts
// features/session/domain/usecases/bootstrapSession.ts
export type BootstrapDeps = Pick<SessionApi, 'getEmployees' | 'getMemberAccess' | 'getSites' | 'getUser'>;

export const bootstrapSession = async (deps: BootstrapDeps, session: Session): Promise<Bootstrap> => {
  const [user, access, employees] = await Promise.all([
    deps.getUser(session.email),
    deps.getMemberAccess(session.userId),
    deps.getEmployees(session.userId),
  ]);
  // validations as the web does …
  return { assignments: toAssignments(employees, await deps.getSites(ids)), needsTerms: !user.agreedToTermsDate, user };
};
```

Deps are passed in (typed as `Pick` of the API) → unit test with plain fakes, no MSW needed.

## Hook rules

- Name `useX`; return an object, not a tuple, when > 2 values.
- Complete dependency arrays (`react-hooks/exhaustive-deps` is an error).
- Prefer deriving during render over `useEffect` + `setState`. `useEffect` is for syncing with
  something **outside** React (AppState, timers, listeners) and always returns cleanup.
- `useMemo`/`useCallback` only when there is a measured cost or a referential-equality need
  (deps of another hook, memoized child, FlashList `renderItem`).
