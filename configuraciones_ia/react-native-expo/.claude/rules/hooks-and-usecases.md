# Custom hooks vs use cases

A **hook** (`useX`) gives a component data, state or effects. The TanStack hooks in
`presentation/queries` play the role a Bloc/Cubit played in Flutter. A **use case** is a business
flow that orchestrates several calls or rules in order: a plain function in `domain/usecases/`,
no React inside. **It is not state management** — state stays in TanStack.

## Decision

| Situation | Do |
|---|---|
| Screen needs one endpoint | hook in `presentation/queries` → `data/fetchers` → mapper (no use case) |
| Write to one endpoint | `useMutation` in `presentation/queries/mutations.ts` |
| Several calls + rules in order | use case in `domain/usecases/`, called from a `queryFn`/`mutationFn` |
| Pure calculation (allocation sums 100 %, hours per day, weeks) | function in `domain/<topic>.ts` |
| Form state | local state + `useFormState` (`forms.md`) |
| Who is signed in / current assignment | `core/session.ts`, `AccountProvider` (`client-state.md`) |
| UI behaviour reused by screens (back, pull to refresh, keyboard) | hook in `ui/` or `core/` |

## Use cases in this app (5–8, not more)

| Use case | Feature |
|---|---|
| `loadAccount` — user + member access + assignments + sites + checks | account |
| `pickCurrentAssignment` — picked → stored → oldest | account |
| `submitOrFind` — send Direct Deposit; after no answer, look it up | pay |
| `acceptOrFind` — accept Terms; after a refusal, re-read the record | terms |
| `uploadBatch` — documents one at a time, re-read folders | documents |
| `decideTimeOff` (manager) — still Pending? → PUT → refresh counts | requests |
| `requestCompensation` (SM) — PUT with change reason (428) | people |

## Shape

```ts
// features/account/domain/usecases/pick-current-assignment.ts — pure
export function pickCurrentAssignment(assignments: Assignment[], pickedId: string | null, storedId: string | null) {
  return (
    assignments.find((a) => a.id === pickedId) ??
    assignments.find((a) => a.id === storedId) ??
    assignments[0] ??
    null
  );
}
```

- Pure use cases take plain values → unit tests without stubs.
- Async use cases **receive the fetchers they call as a parameter** (a plain object of
  functions), so `domain/` stays pure and lint keeps it so. The caller in
  `presentation/queries` passes the real ones:

```ts
// domain/usecases/submit-or-find.ts
export type SubmitOrFindDeps = {
  findSince: (since: Date) => Promise<DepositRequest | null>;
  submit: (draft: DepositDraft) => Promise<DepositRequest>;
};
export async function submitOrFind(draft: DepositDraft, deps: SubmitOrFindDeps, now = new Date()) { … }

// presentation/queries/mutations.ts
mutationFn: (draft) => submitOrFind(draft, { findSince: fetchRequestSince, submit: submitDeposit }),
```

- That is a parameter, not a DI layer: no container, no interfaces, no factories. Tests pass plain
  fakes (or the real fetchers with `stubNetwork`).
- `try` is allowed here (translating a known failure into an outcome), never in components/hooks.

## Flutter → here

| Flutter | Here |
|---|---|
| Bloc/Cubit that fetches | `useQuery` hook in `presentation/queries` |
| Bloc states loading/success/error | `query.isPending` / `query.error` / `query.data` |
| Form bloc | `useFormState` + pure rules in `domain` |
| Global auth bloc | `core/session.ts` |
| `BlocListener` | `onSuccess`/`onError`, or a route guard |
| InheritedWidget / Provider | `AccountProvider` (Context) |
| `flutter_modular` binds / `Modular.get` | direct imports; `.web.ts` siblings and fixtures to substitute |
| UseCase `execute()` | function in `domain/usecases/` |
| ThemeData | `ui/theme.ts` |

## Hook rules

- Name `useX`; return an object, not a tuple, when > 2 values.
- Complete dependency arrays. Derive during render instead of `useEffect` + `setState`;
  `useEffect` only to sync with something outside React (AppState, timers), with cleanup.
- No `try` inside `use*` hooks (React Compiler skips the hook silently).
- `useMemo`/`useCallback` rarely: React Compiler memoizes.
