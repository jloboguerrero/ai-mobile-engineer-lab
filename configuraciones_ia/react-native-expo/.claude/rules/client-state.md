# Client state — Zustand

Zustand holds **only** what the server can't tell us: who is signed in and which assignment
is selected. 2–3 small stores, total. If you're about to add a 4th store, stop and ask.

## Stores

| Store | Holds | Persisted |
|---|---|---|
| `sessionStore` (`core/session`) | `SessionState` union | token parts in expo-secure-store (one key per value) |
| `assignmentStore` (`features/session`) | `currentEmployeeId` | MMKV, keyed by `userId` |
| `prefsStore` (optional) | language override, dismissed banners | MMKV |

```ts
type SessionState =
  | { status: 'hydrating' }
  | { session: Session; status: 'signedIn' }
  | { reason?: 'expired' | 'manual'; status: 'signedOut' };
```

Use a discriminated union, never a bag of booleans (`isLoggedIn`, `isLoading`…).

## Rules

1. **Select narrowly**: `useSessionStore((s) => s.status)` — never `useSessionStore()` whole.
   For multiple fields use `useShallow`.
2. **Actions live in the store** (`signIn`, `signOut`, `setCurrentEmployeeId`); components
   don't `setState` directly.
3. **Derive, don't store**: profile (`employee | dm | sm`), tabs and scope come from
   `useCurrentAssignment()` = bootstrap query data + `currentEmployeeId`. Never store them.
4. **No server data in stores** (see `server-state.md`).
5. **Reset on logout**: `signOut` resets every store and calls `queryClient.clear()`.
6. Outside React (interceptors, push listeners) use `useSessionStore.getState()`.
7. Stores are created in plain modules; tests reset them in `beforeEach`
   (`useSessionStore.setState(initialState, true)`).

## UI state

Local `useState`/`useReducer` for toggles, sheet open, selected tab. Shared between 2–3
sibling screens of one flow → React Context scoped to that route `_layout` (e.g. the
Direct Deposit `FormProvider`). Not Zustand.
