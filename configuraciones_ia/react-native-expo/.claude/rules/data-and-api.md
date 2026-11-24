# Data layer — HTTP, raw types, mappers, errors

## Clients (`src/core/api.ts`)

- `api` — authenticated axios instance. Request interceptor: `bearer()` checks `exp` **before**
  sending (expired → `endSession({ expired: true })` and reject with `ApiError` kind `session`,
  status 0, never sent), sets `Authorization: Bearer`. `User-Agent` from `app-config.ts`
  (`iPhone` / `Android; Mobile`: shr-be's audit trail).
- `publicApi` — no Authorization: sign-in and password routes only.
- Response interceptor: axios error → `ApiError` (config, headers and body dropped: Bearer, bank
  numbers). Resends **GET only** on 502/503/504, 3 times (200/400/800 ms). Never a write.
- shr-be has **no path prefix**: the path is exactly what you call.
- `axios` is imported only in core (lint).

## `ApiError` (`src/core/api-error.ts`)

```ts
type ApiErrorKind = 'changeReason' | 'forbidden' | 'invalid' | 'notFound' | 'offline' | 'server' | 'session';
```

| Kind | When | Screen does |
|---|---|---|
| `offline` | status 0, timeout | "No connection"; for a write, find out whether it arrived |
| `session` | 401 with message exactly `Unauthorized`, or expired token never sent | nothing: Sign in shows |
| `forbidden` | any other 401, and 403 | the area's note; `isRecordUnavailable` → ended assignment |
| `notFound` | 404 | the area's note |
| `invalid` | other 4xx | shr-be's words via `errorText` |
| `changeReason` | 428 | change-reason sheet → resend with `X-Change-Reason-Code/Note`, user-initiated, max 3 |
| `server` | 5xx | "Something went wrong" — never the body |

- Read with `apiErrorOf(error)`, never `instanceof` or a cast of `response.data`.
- `errorText(error)`: `customData.title` → `message` → status. A feature with its own sentence
  checks its case first and falls back (`saveErrorText`, `signInErrorText`).
- The dead-token rule lives in `app-config.ts` (`isDeadToken`) with tests.

## Raw types (`data/raw.ts`)

- Written by hand, **only the fields the app reads**. Adding a field = the app depends on it.
- No generated types, no zod. Guards against data that does not match its type stay
  (`?? []`, `|| fallback`): shr-be's data is not always what its types say.

## Mappers (`data/mappers.ts`) — the privacy rule

- Every response goes through a mapper that **copies each kept field by name**. A raw answer never
  reaches the cache or a component.
- The Employee record keeps SSN last 4 and each bank account's last 4. Full bank numbers exist
  only in Direct Deposit reads (tagged `sensitive`).
- Nested objects are copied field by field too; copying one whole is allowed only on purpose and
  documented (profile address and emergency contacts: the save sends them back).
- **Every mapper has a privacy contract test** (`testing.md`): a raw answer carrying `SENSITIVE`
  values where shr-be puts them → `leaksOf(mapped)` is empty.
- `toRequest` (domain → body) absorbs API quirks: `''` → `null`, `MM/dd/yyyy`, numbers vs strings,
  mutually exclusive keys, read-only fields resent as read.

## Fetchers (`data/fetchers.ts`)

```ts
import { api } from '@/core/api';

import type { TimeOffSummary } from '../domain/types';

import { toSummary } from './mappers';
import type { RawSummary } from './raw';

export async function fetchSummary(employeeId: string, signal?: AbortSignal): Promise<TimeOffSummary> {
  const response = await api.get<RawSummary>(`/time-off/employee/${employeeId}/summary`, { signal });
  return toSummary(response.data);
}
```

- Plain exported functions; they return domain types. No factories, no classes.
- Known quirks handled here (or in the use case) with a comment, e.g. time off
  `400 "Request fufilled…"` = success.
- A write decides what a lost answer means: look the result up (`submitOrFind`, `lostAnswer`)
  or report "may have arrived" (`isUnanswered`). Never resend.
- `try` belongs in these `.ts` modules, never in a component or a `use*` hook.

## Files (binary)

- Downloads: `downloadFile` (`core/files.ts`) to a `CACHE_FOLDERS` folder, written to
  `<name>.part` and renamed when complete; Bearer via `authorizedHeaders()`.
- Native uploads: `uploadFile` (`core/upload.ts`), foreground session, never resent. Documents
  one at a time (the API rewrites the document).
- Normalize before upload: HEIC → JPEG, profile photo exactly 512×512, name with extension and a
  real MIME type.
- What differs on the web preview lives in a sibling `.web.ts` with the same exports.
