# Testing

## Levels

| Level | What | Tool |
|---|---|---|
| Unit | `domain/` rules and use cases, mappers, `toRequest`, capabilities, `ApiError` | Jest |
| Privacy | one contract test per mapper (`SENSITIVE` / `leaksOf`) | Jest |
| Integration | fetchers with `stubNetwork`; hooks with `WithQueryClient`; components by role and name | RNTL 14 |
| E2E | login → Home, request time off, approve request, switch assignment | Maestro against the mock API (later) |

## Layout and helpers

- Tests **next to the code** as `name.test.ts(x)`, never under `src/app`.
- Shared data in `*.fixture.ts` files that only tests import:
  - `core/network.fixture.ts` — `stubNetwork`, `failureOf`
  - `core/query.fixture.tsx` — `WithQueryClient`, `settledQuery`, `dropFinishedWrites`
  - `core/secure-store.fixture.ts` — `memorySecureStore`
  - `features/employee/sensitive.fixture.ts` — `SENSITIVE`, `leaksOf`
- No mocking library and never a real server. Use cases take plain fakes as deps.
- RNTL 14: `render`, `fireEvent`, `rerender` are async — await them. A file that renders a
  `useMutation` calls `dropFinishedWrites()` or a single-file run never exits.
- Tests run in America/Los_Angeles. Local days with `new Date(y, m, d)`; shr-be instants as ISO
  strings with `Z`.

## Privacy contract test (every mapper, same PR)

```ts
it('keeps nothing sensitive', () => {
  const raw = { ...rawSummary, ssn: SENSITIVE.ssn, bankAccounts: [SENSITIVE.account] };
  expect(leaksOf(toSummary(raw))).toEqual([]);
});
```

## Must-have cases (SHR quirks)

- 401 `Unauthorized` → session ends; any other 401 → `forbidden`, stays signed in.
- GET 503 resent; a write never resent (assert one request).
- Time off 400 "Request fufilled…" → success.
- 5xx → generic sentence, body never rendered.
- 428 → change-reason sheet → resend with headers.
- `pickCurrentAssignment`: picked gone → stored → oldest.

## Rules

- **Every logic fix lands with a regression test that fails without it.**
- No coverage percentage, no snapshot tests.
- Query by role and accessible name (`getByRole('button', { name: 'Save' })`); `testID` only when
  nothing accessible can tell elements apart (and for Maestro).

## Done means

`npm run verify` passes (at least typecheck, lint and tests).
