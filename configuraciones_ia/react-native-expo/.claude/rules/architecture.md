# Architecture — feature-first + Clean Architecture "lite"

Layers per feature: **data → domain → queries/hooks → ui**. Not every layer is mandatory:
a feature that only reads one endpoint may have no `domain/rules.ts` and no `forms/`.

## Tree

```
app/                              # Expo Router — routes ONLY
  _layout.tsx                     # providers + Stack.Protected guards (allowed to have logic)
  (auth)/sign-in.tsx ...
  oauth/callback.tsx
  terms.tsx · no-access.tsx
  (app)/(tabs)/_layout.tsx        # tabs derived from profile (worker / dm / sm)
  (app)/(tabs)/timeoff.tsx        # export { TimeOffScreen as default } from '@/features/timeoff';
  (app)/pay/direct-deposit/_layout.tsx   # FormProvider shared by edit + review
  dev/ui.tsx                      # component catalog (development builds only)
src/
  core/      api/ query/ session/ push/ files/ config/ i18n/ logger/
  ui/        tokens/ theme/ primitives/ components/ form/ layout/ index.ts
  features/  auth/ session/ announcements/ notifications/ work/ timeoff/
             pay/ profile/ documents/ esign/ team-requests/ team-people/
scripts/     tokens.ts (DS CSS → TS) · api-types.ts (openapi.json → DTO types)
e2e/         Maestro flows
```

## Feature anatomy

```
features/timeoff/
  data/       timeoffApi.ts   # createTimeOffApi(http) — endpoints, returns DOMAIN types
              dto.ts          # Pick<> of generated types, only what we read/send
              mappers.ts      # toSummary(dto) → TimeOffSummary  (drops unused/PII fields)
  domain/     types.ts        # domain types (no axios, no react)
              rules.ts        # pure functions: canRequest(summary), totalHours(days)
              enums.ts
              usecases/       # only when orchestrating several calls/rules
  queries/    keys.ts         # timeoffKeys factory
              queries.ts      # queryOptions(...) + useX hooks
              mutations.ts    # useRequestTimeOff ...
  forms/      schema.ts · toFormValues.ts · toRequest.ts
  ui/         components/     # feature-only components (business components live here)
              screens/        # TimeOffScreen.tsx, TimeOffHistoryScreen.tsx
  i18n/       en.json · es.json
  di.ts       export const timeoffApi = createTimeOffApi(api);
  index.ts    public API: screens, hooks other features need, keys for invalidation
```

## Dependency rules (enforced by `eslint-plugin-boundaries`)

| From | May import |
|---|---|
| `src/ui` | only `src/ui` (no core, no features, no i18n instance — texts come in as props) |
| `src/core` | `core`, `ui` |
| `src/features/x` | `core`, `ui`, other features **only via `@/features/y` (index.ts)** |
| `app/` | `@/features/*` index, `@/ui`, `@/core` (layouts/providers) |

Inside a feature:
- `domain/` imports nothing from `react`, `react-native`, `axios`, `@tanstack/*`. Pure TS.
- `data/` never imports from `ui/` or `queries/`.
- `ui/` never calls `xApi` directly — always through a hook in `queries/`.

## Principles

1. **Server is the source of truth** → TanStack Query. Zustand only for session and current assignment.
2. **Derive, don't store**: profile, tabs and scope are computed from the current assignment.
3. **PII minimum**: mappers drop SSN, bank numbers, anything unused. Never persist the query cache.
4. **Copyable**: `core`, `ui` and each feature must be copyable to the Staffology app without
   dragging other features. If a feature needs another's internals, expose it in `index.ts`
   or move it to `core`.
5. **Business components live in their feature**; `src/ui` is generic (Button, Card, Sheet,
   FormTextField…). Promote to `ui` only when a 2nd feature needs it and it has no business words.

## When adding something, where does it go?

| Thing | Place |
|---|---|
| New endpoint call | `features/x/data/xApi.ts` + mapper + dto |
| Business rule (pure) | `features/x/domain/rules.ts` |
| Data for a screen | hook in `features/x/queries/` |
| Cross-cutting infra (http, session, files, push) | `src/core/*` |
| Generic visual component | `src/ui/components/` |
| New route | `app/...` 1-line file + screen in the feature |
| Env value / flag | `src/core/config/env.ts` (Zod) / `flags.ts` |
