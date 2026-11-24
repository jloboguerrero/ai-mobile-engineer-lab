# Navigation & auth — Expo Router

## Routes are thin

`app/**` files (except `_layout.tsx`) are one line:

```tsx
export { TimeOffScreen as default } from '@/features/timeoff';
```

Params: read with `useLocalSearchParams<{ id: string }>()` **inside the feature screen**, validate
with Zod if they come from deep links/push.

## Guards — screens never navigate after login/logout

```tsx
// app/_layout.tsx
<Stack screenOptions={{ headerShown: false }}>
  <Stack.Protected guard={!signedIn}>
    <Stack.Screen name="(auth)" />
  </Stack.Protected>
  <Stack.Protected guard={signedIn && needsTerms}>
    <Stack.Screen name="terms" />
  </Stack.Protected>
  <Stack.Protected guard={signedIn && bootError}>
    <Stack.Screen name="no-access" />
  </Stack.Protected>
  <Stack.Protected guard={signedIn && ready}>
    <Stack.Screen name="(app)" />
  </Stack.Protected>
</Stack>
```

Sign-in/out changes **state**; the router redirects. No `router.replace('/home')` after login.
Splash stays up (`SplashScreen.preventAutoHideAsync`) while `status === 'hydrating'`.

## Tabs by profile

`(app)/(tabs)/_layout.tsx` reads `useProfile()` (derived from current assignment `jobPosition`,
**never from the token groups**) and hides tabs with `href: null`:
- worker: Home · My Work · Time Off · Pay · Me
- dm / sm: Home · My Work · Time Off · Team · Me (Pay inside Me)

## Single Sign (IOP) — PKCE

- `expo-auth-session` + PKCE; authorize endpoint hardcoded (discovery needs `platform_guid`).
- Verifier and `state` only in memory.
- `oauth/callback.tsx` receives the deep link → `POST /user/iop-login { code, redirectUri, codeVerifier }`
  **exactly once**: single-flight by `code`, `retry: 0`, block double tap. Timeout → new authorize,
  never resend the same code (IOP revokes the first tokens).
- Scheme per environment: `simplifyhr-qa://oauth/callback` (from `app.config.ts` by `APP_VARIANT`).

## Legacy (Cognito)

`POST /user/signIn` (PascalCase response, Bearer = `IdToken`). `passwordResetRequired` → reset flow.
Store `AccessToken` only to sign out of Cognito.

## Terms (EULA)

Single mutation (audit + email to HR) → `setQueryData(bootstrapKey, { …, needsTerms: false })`.
"I Agree" enabled only at scroll end ("Go to end" button). Cancel = full signOut.

## Session expiry (~1 h, no refresh)

1. Proactive timer to `exp` (re-evaluated on `AppState → active`), warning ~5 min before.
2. `exp` check before every request (interceptor).
3. 401 with `message === 'Unauthorized'`.
→ `signOut({ reason: 'expired' })` + banner "Continue with Single Sign" (1 tap while IOP cookie lives).

## Log out — order matters

1. Unregister push token (ignore failure)
2. Cognito signOut if legacy (no retry, in `finally`)
3. Clear secure-store keys
4. `queryClient.clear()`
5. Reset stores
6. `status: 'signedOut', reason: 'manual'`

## Deep links & push taps

Push/deeplink while signed out → save pending route in memory → after bootstrap, navigate
(switching assignment first if payload `employeeId` ≠ current). Payload validated with Zod;
`routeFor(payload)` in `features/notifications` is the only place that maps payload → route.
