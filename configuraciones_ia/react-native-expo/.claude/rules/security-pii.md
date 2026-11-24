# Security & PII

SHR user/employee responses include **full SSN and bank account numbers**. A manager will hold
other people's HR data. Treat every raw response as radioactive.

## May live

| Value | Where |
|---|---|
| Session token, `exp`, kind, Cognito `AccessToken`, last assignment chosen | secure-store via `core/secure-store.ts` (`WHEN_UNLOCKED_THIS_DEVICE_ONLY`, `STORAGE_PREFIX`, one key per value) |
| Mapped data (after an allow-list mapper) | memory, query cache |
| Full bank numbers | only Direct Deposit queries, its draft and submit mutation — `sensitive` |
| Downloads and upload copies | `CACHE_FOLDERS` (`app-config.ts`) and pickers' folders, emptied on sign-out |
| Profile photos | expo-image caches, cleared on sign-out |
| PKCE verifier, `state` | memory only |

## Never

- Persisted anywhere else: no AsyncStorage, no MMKV, no query persister.
- In a log or report: no `console.*` outside `core/monitoring.ts`; `reportError` context is an
  allow-list (`area`, a fixed lowercase `key`). An `ApiError`'s message names its kind only.
- In a link, route param or push payload: ids and view names only.
- On screen unmasked: SSN as last 4 (`XXX-XX-1234`), accounts as `••••6789` outside the editor.
- In a screenshot of the Direct Deposit editor/review (`usePreventScreenCapture`), or in the iOS
  app switcher (blurred everywhere). Pay statements are not blocked.

## Code

- Sensitive field names (`ssn`, `accountNumber`, `routingNumber`) only in `data/` (raw type +
  mapper) and Direct Deposit; the hook `check_pii_logging.sh` blocks them elsewhere.
- Every mapper has a privacy contract test (`testing.md`).
- Variables with full numbers or a password: `meta: { sensitive: true }`, short `gcTime`.
- Bank inputs: `autoCorrect={false}`, `autoComplete="off"`, `textContentType="none"`.
- `.env` holds only public `EXPO_PUBLIC_` values. Never commit `.env.local`, keys, certificates.
- Fixtures and mock data are made up: `example.com`, SSN `000-00-0000`, numbers starting `000`,
  phones on `555`. Run `privacy-scan.mjs` after changing the mock.

## Monitoring (`core/monitoring.ts`)

The only module that will know the crash reporter. When Sentry is added: `sendDefaultPii: false`;
no Session Replay or screenshots; no `extraErrorDataIntegration`; no `setUser` with an email;
`beforeBreadcrumb` turns URLs into route templates; `beforeSend` drops request data.
