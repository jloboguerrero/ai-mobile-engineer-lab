# Testing

## Levels

| Level | What | Tool |
|---|---|---|
| Unit | `domain/` rules & use cases, mappers, `toRequest`/`toFormValues`, Zod schemas, `ApiError` mapping | Jest |
| Integration | hooks and screens against fake HTTP: real `api` client + real query client + MSW | RNTL + MSW |
| E2E | login → Home, request time off, approve request, switch assignment | Maestro (`e2e/*.yaml`) |

## Layout

- Tests **next to the code**: `mappers.ts` → `mappers.test.ts`, `TimeOffScreen.tsx` → `TimeOffScreen.test.tsx`.
- MSW handlers per feature: `features/x/mocks/handlers.ts`, fixtures `features/x/mocks/fixtures.ts`
  built from the API guide examples (with fake PII). Global server in `test/msw/server.ts`.
- Test utils in `test/`: `renderWithProviders` (QueryClient with `retry: false`, i18n `en`, theme,
  safe-area), `createTestQueryClient`, `signInAs(profile)` store helper.

## No mocks of our own modules

Test real code: don't `jest.mock('../data/timeoffApi')`. Intercept HTTP with MSW. Use cases get
plain fake deps (they take deps as args). `jest.mock` only for native modules without JS impl
(secure-store, MMKV → in-memory mocks in `test/setup.ts`).

## Must-have integration cases (SHR quirks)

- 401 `message: 'Unauthorized'` → signs out with `reason: 'expired'`.
- 401 other message → `denied`, stays signed in.
- 428 → change-reason sheet → resend with headers.
- Time off 400 "Request fufilled…" → treated as success.
- 5xx → generic copy, body never rendered.
- GET 503 retried; POST never retried (assert request count with MSW).

## Shape

```tsx
describe('TimeOffScreen', () => {
  it('shows balances when summary loads', async () => {
    server.use(http.get('*/time-off/employee/:id/summary', () => HttpResponse.json(summaryFixture)));
    renderWithProviders(<TimeOffScreen />, { session: signedInWorker });
    expect(await screen.findByText('24 hours available')).toBeOnTheScreen();
  });
});
```

- Query by role/text/label (what the user sees), `testID` only as last resort (and for Maestro).
- `findBy*` for async, `userEvent` over `fireEvent`.
- Descriptions read as behaviour: `'disables Send while the request is pending'`.

## Done means

`npx tsc --noEmit`, `npm run lint`, `npm test` pass. New mapper/rule/schema/toRequest → unit test.
New screen or mutation → at least one integration test covering success + one error kind.
E2E login in tests: legacy QA account or token deep link, **development builds only**.
