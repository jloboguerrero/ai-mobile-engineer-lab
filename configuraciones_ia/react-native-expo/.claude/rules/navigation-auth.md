# Navigation & auth — Expo Router

## Routes are thin

A route file under `src/app/` (not `_layout.tsx`) reads `useAccount()`, `useCapabilities()` and
`useLocalSearchParams()`, builds links with `core/hrefs.ts`, and renders a feature screen with
ids, flags and links as props. Nothing else: no queries, no `useState`, no sheets.

```tsx
// src/app/(app)/pay/index.tsx
export default function PayRoute() {
  const { account, current } = useAccount();
  const { view } = useLocalSearchParams<{ view?: string }>();
  return (
    <PayScreen
      assignments={account.assignments}
      employeeId={current.id}
      statementHref={statementHref}
      userId={account.userId}
      view={view}
    />
  );
}
```

- A page's sub-view lives in the URL (`?view=history`) so a link or notification can open it.
- Route params carry ids and view names, never a name, email or number from a record.
- Nothing that is not a route lives in `src/app` (tests included).

## Guards — screens never navigate after sign-in/out

```tsx
// src/app/_layout.tsx
<Stack.Protected guard={signedIn}><Stack.Screen name="(app)" /></Stack.Protected>
<Stack.Protected guard={!signedIn}><Stack.Screen name="sign-in" /></Stack.Protected>
```

Sign-in/out changes **state**; the router redirects. The splash stays up until fonts are loaded
and `restoreSession()` has run.

## Tabs by capability

```tsx
// src/app/(app)/_layout.tsx
export const unstable_settings = { anchor: '(home)' };
<Tabs.Screen name="(home)" /> <Tabs.Screen name="work" /> <Tabs.Screen name="time-off" />
<Tabs.Protected guard={capabilities.payTab}><Tabs.Screen name="pay" /></Tabs.Protected>
<Tabs.Protected guard={capabilities.peopleTab}><Tabs.Screen name="people" /></Tabs.Protected>
<Tabs.Screen name="me" />
```

- **Never `href: null`** to hide a tab. When a guard turns false the person lands on the anchor.
- Manager Layout A: People in Pay's slot, Pay under Me.

## Capabilities (`features/account/capabilities.ts`)

- `managerScopeOf(assignment)` → `{ role: 'sm', siteId, key } | { role: 'dm', siteId, departmentId, key } | null`.
- `capabilitiesOf(assignment)` → flags (`payTab`, `peopleTab`, `requests`, `editTimeOff`,
  `requestCompensation`, `writeAnnouncements`…) + `scope`.
- `scopeParams(scope)` / `grantParams(assignment)` → the scope id to send.
- The role comes from the assignment's `jobPosition`, **never** from the token groups.
- Lint refuses `.role === 'sm'` anywhere else. A new role or capability = one change here + test.

## Single Sign (IOP) — PKCE (development build required)

- `expo-auth-session` + PKCE; authorize endpoint hardcoded (discovery needs `platform_guid`).
- Verifier and `state` only in memory.
- `POST /user/iop-login { code, redirectUri, codeVerifier }` **exactly once**: single-flight by
  `code`, no retry, block double tap. Timeout → new authorize, never resend the same code.
- Scheme per environment (`simplifyhr-qa://oauth/callback`) from `app.config.ts`.

## Legacy (Cognito)

`POST /user/signIn` (Bearer = `IdToken`). `passwordResetRequired` → reset flow. Keep
`AccessToken` only for `POST /user/signOut` (not awaited on Log Out).

## Terms

`TermsGate` over the shell until accepted (inline on iOS, takes screen reader focus).
`acceptOrFind` use case. Cancel = end of session.

## Session expiry (~1 h, no refresh)

1. `bearer()` checks `exp` before every call; expired → session ends, call never sent.
2. A 401 with message exactly `Unauthorized` ends the session; any other 401 is `forbidden`.
3. **Warning before expiry**: a timer at `exp − 5 min` (re-evaluated on `AppState → active`) opens
   a sheet "Your session expires in 5 min" → **Stay signed in** re-authenticates with Single Sign
   **in place** (no navigation; the IOP cookie usually makes it instant) and replaces the token.
   An open form is not lost. "Later" dismisses it.
4. If it expires anyway: `signedOut` with `expired: true` → Sign in says so.

## Sign-out cleanup — one explicit list (`src/app/_layout.tsx`)

However the session ends, `endSession` deletes the secure-store keys and the root layout runs:
1. `queryClient.clear()`
2. `clearFileCaches()`
3. `Image.clearMemoryCache()` + `Image.clearDiskCache()`
4. `clearToast()`
5. (with push) unregister the device token

A new place that holds personal data adds a line here in the same PR. No registry, no event bus.

## Deep links & push taps

Signed out → keep the pending route in memory → after sign-in and `loadAccount`, navigate
(switching assignment first if the payload's `employeeId` differs). Notification routing is
role-aware (worker `/pay`, manager Pay under Me) and lives at app level.
