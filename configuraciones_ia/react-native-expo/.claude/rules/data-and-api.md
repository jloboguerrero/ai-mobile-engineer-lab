# Data layer — HTTP, DTOs, mappers, errors

## Clients (`src/core/api/client.ts`)

- `api` — authenticated axios instance. Request interceptor: checks `exp` **before** sending
  (expired → `signOut({ reason: 'expired' })` and abort), sets `Authorization: Bearer`, sets
  `User-Agent` containing `iPhone` or `Android; Mobile` (shr-be audit trail needs it).
- `publicApi` — no Authorization, only for the public routes (iop-login, signIn, forgot…).
- Both: base URL from `env.API_URL`, timeout, response interceptor → `toApiError`.
- shr-be has **no path prefix**: the path is exactly what you call (`/time-off/employee/:id/summary`).

## `ApiError` (`src/core/api/ApiError.ts`)

Every failure leaving `core/api` is an `ApiError`. Nothing above sees `AxiosError`.

```ts
export type ApiErrorKind =
  | 'changeReason' // 428 — needs X-Change-Reason-Code/Note
  | 'conflict'     // 409
  | 'denied'       // 401 with message !== 'Unauthorized' → "not yours" / assignment ended
  | 'forbidden'    // 403 'Forbidden resource' — role lacks permission
  | 'network'      // no response / timeout
  | 'notFound'     // 404
  | 'server'       // 5xx — never show body
  | 'sessionExpired' // 401 with message === 'Unauthorized'
  | 'tooLarge'     // 413
  | 'validation';  // 400 / 422

export class ApiError extends Error {
  constructor(
    readonly kind: ApiErrorKind,
    readonly status: number | undefined,
    readonly userMessage: string,        // customData.title → message → generic
    readonly fieldErrors?: Record<string, string>, // 400 with path → RHF setError
    readonly changeReason?: { notice: string; reasonCodes: string[] },
  ) { super(userMessage); }
}
```

- Text: `customData.title` → `message` → generic i18n key. A 500 **never** shows its body.
- `sessionExpired` → interceptor calls `signOut({ reason: 'expired' })` once (single-flight).
- `denied` does NOT sign out. If it's the current assignment → re-bootstrap, switch to the
  first assignment, toast. Handled in `features/session`, not in each screen.
- **428**: `useChangeReasonMutation` in `core/api` opens a sheet with `notice`/`reasonCodes`
  and resends with headers. Max 3, always user-initiated. Closing = cancel.
- Known quirks belong to the feature mapper, e.g. time off `400 "Request fufilled…"` = success
  (handled in `timeoffApi.requestTimeOff`, documented with a comment).

## No try/catch in UI or hooks

- `xApi` functions throw `ApiError` (from the interceptor). They don't catch.
- TanStack surfaces it: `query.error`, `mutation.error`, `onError`.
- `try/catch` only in **use cases** that orchestrate and must translate a known failure into a
  domain outcome (e.g. `bootstrapSession`: 400 "No Employee records" → `{ status: 'noAccess' }`).
- UI decides by `error.kind`, never by status number or message string.

## DTOs

- Generated with **openapi-typescript** from shr-be Swagger into `src/core/api/generated/`
  (`npm run api:types`; CI fails on drift). Never hand-edit.
- `features/x/data/dto.ts` narrows: `type SummaryDto = Pick<components['schemas']['X'], 'a' | 'b'>`.
  Only the fields we read. This documents what the app depends on.

## Mappers

- One mapper per endpoint response: `toSummary(dto): TimeOffSummary`. Pure, unit-tested.
- The cache stores the **mapped** model, never the raw response.
- Drop: SSN (keep `last4ssn` only), bank account/routing numbers (keep masked last4), anything unused.
- Normalize: dates (`MM/dd/yyyy` / ISO → calendar date vs instant, see `i18n.md`), enums
  (string → union), nullables (`''` → `null`), pagination → `Page<T> = { items; total; nextPage? }`.
- Profile is read-modify-write: the model **does** keep `firstName`, `lastName`, `dob` to resend
  them unchanged; never SSN or bank data.

## API factory shape

```ts
// features/timeoff/data/timeoffApi.ts
import type { AxiosInstance } from 'axios';

import { toSummary } from './mappers';

import type { SummaryDto } from './dto';
import type { TimeOffSummary } from '../domain/types';

export const createTimeOffApi = (http: AxiosInstance) => ({
  getSummary: async (employeeId: string): Promise<TimeOffSummary> => {
    const { data } = await http.get<SummaryDto>(`/time-off/employee/${employeeId}/summary`);
    return toSummary(data);
  },
});

export type TimeOffApi = ReturnType<typeof createTimeOffApi>;
```

```ts
// features/timeoff/di.ts
import { api } from '@/core/api';

import { createTimeOffApi } from './data/timeoffApi';

export const timeoffApi = createTimeOffApi(api);
```

## Files (binary)

Downloads (paystub PDF, signed docs) are authenticated binaries, no presigned links:
`core/files/download.ts` → cache dir with Bearer → share → delete on close. Uploads:
pick → normalize (HEIC→JPEG, resize, name + MIME) → validate (Zod) → upload. **Never retry uploads**;
re-read state first. Profile photo: exactly 512×512 JPEG.
