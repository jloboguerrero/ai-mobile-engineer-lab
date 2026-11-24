# Security & PII

SHR user/employee responses include **full SSN and bank account numbers**. Treat every raw
response as radioactive.

## Where things are stored

| Value | Where |
|---|---|
| Token, `exp`, session kind, email, userId, Cognito AccessToken | expo-secure-store (one key per value) |
| Last `employeeId` per user, language, dismissed banners | MMKV |
| PKCE verifier, `state` | memory only |
| Direct deposit form, compensation form | memory only |
| Password, raw user/employee responses, query cache | **never** |

## Logging

- `logger` (`src/core/logger`) is the only logger. `no-console` is an error; hook `check_pii_logging.sh` blocks it.
- Log events and ids of *entities* (`requestId`), never people data, bodies, headers or tokens.
- Sentry: `beforeSend` / `beforeBreadcrumb` strip request/response bodies, `Authorization`,
  query strings and personal ids. Tags: environment, app version, profile (`worker|dm|sm`).
- Never put PII in navigation params or push payloads (`{ type, entityId, employeeId? }` only).

## Code

- Sensitive field names (`ssn`, `accountNumber`, `routingNumber`) may appear only in `data/`
  (DTO + mapper dropping them) and `core/api`. Domain/UI use `last4ssn`, `maskedAccount`.
- Inputs for bank data: `autoCorrect={false}`, `autoComplete="off"`, `secureTextEntry` where
  appropriate, `textContentType="none"`.
- Downloads go to the cache dir and are deleted after share/close.
- Shared phones: logout clears everything listed above (see `navigation-auth.md`). IOP logout is
  local only — warn in copy.
- Env config validated with Zod at startup (`core/config/env.ts`); no secrets in the bundle
  (client id / platform guid are public identifiers).
