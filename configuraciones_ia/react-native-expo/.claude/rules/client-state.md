# Client state — no store library

TanStack holds server data. What is left is small, and lives in the simplest place that works.

| State | Where |
|---|---|
| Session (token, exp, kind, expired flag) | `core/session.ts`: external store with `useSyncExternalStore` (~30 lines), values in secure-store one key each |
| Current assignment | `AccountProvider` (`features/account/account-provider.tsx`): `useState` for the picked id, persisted in secure-store |
| Toast | `ui/toast.tsx` small store |
| A page's sub-view (`?view=history`), a selected id | URL params (`useLocalSearchParams`) — a link or notification can open it |
| Sheet open, filter, tab inside a component | local `useState` |
| A flow shared by 2–3 screens (Direct Deposit edit → review) | Context scoped to that route's `_layout.tsx` |

## Session

```ts
type SessionState = {
  expired: boolean;                       // Sign in says "your session expired"
  session: Session | null;
  status: 'loading' | 'signedIn' | 'signedOut';
};
```

- `useSession()` in React; `getSessionState()` outside React (interceptors, push listeners).
- `restoreSession()` at launch, `startSession(session)`, `endSession({ expired })`.

## Account

- `useAccount()` → `{ account, current, switchTo }`; `useCapabilities()` → flags + scope.
  **Routes only** (lint): a feature receives ids and flags as props.
- Which assignment is current is decided by the use case `pickCurrentAssignment`
  (picked → stored → oldest), not inline in the provider.
- `switchTo` stores the choice and calls `invalidateAccount()`; queries keyed by `employeeId`
  refetch by themselves.

## Rules

1. **Derive, don't store**: role, capabilities, tabs and scope come from `current`.
2. **No server data in client state.**
3. **Reset on sign-out**: the root layout's cleanup list (`navigation-auth.md`).
4. Adding a store needs a reason written in an ADR; no store library.
