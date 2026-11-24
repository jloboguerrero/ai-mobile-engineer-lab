# Architecture — feature-first + Clean Architecture "lite"

Each feature has three layers: **domain → data → presentation**. Use cases only where a flow
orchestrates. No repositories, no DI container, no barrels. A layer with nothing in it is not
created (a read-only feature may have only `data/` and `presentation/`).

## Tree

```
src/
  app/                           # Expo Router: routes and layouts ONLY
    _layout.tsx                  # fonts, splash, restoreSession, Stack.Protected, sign-out cleanup list
    sign-in.tsx · oauth/callback.tsx
    (app)/_layout.tsx            # AccountProvider, TermsGate, top bar, Tabs (+ Tabs.Protected)
    (app)/(home)/ work/ time-off/ pay/ me/ people/
  app-config.ts                  # brand, User-Agent, storage prefix, cache folders, error-body adapter,
                                 # dead-token rule. Imports nothing
  translations.ts                # every i18n catalog; only the root layout imports it
  core/                          # api, api-error, session, secure-store, query, cache, files, upload,
                                 # file-caches(.web), hrefs, i18n, format/, monitoring, screen-privacy, form-state
  ui/                            # theme.ts + kit components + locales/ (imports only ui)
  features/
    account/ employee/ auth/     # shared domain
    <area>/                      # every other feature
tools/  mock-api/ (scenarios + privacy-scan) · preview/ (screenshots vs prototype)
docs/   architecture.md · adr/ · pull-request-template.md
```

## Feature anatomy

```
features/time-off/
  domain/          pure TS: no react, react-native, axios, tanstack, expo-router
    types.ts       TimeOffSummary, TimeOffCard, TimeOffRequest…
    dates.ts · request.ts · summary.ts   pure rules, tests next to them
    usecases/      only flows that orchestrate (hooks-and-usecases.md)
  data/
    raw.ts         raw response types: ONLY the fields the app reads
    fetchers.ts    fetchSummary(employeeId) → api.get → mapper; write functions
    mappers.ts     raw → domain (allow-list) · domain → request body (toRequest)
  presentation/
    queries/
      keys.ts      timeOffKeys
      queries.ts   timeOffQueries (queryOptions + CachePolicy) + one-line hooks
      mutations.ts useRequestTimeOff, invalidateTimeOff(), useRefreshTimeOff()
    components/
    screens/
  locales/
    en.ts · es.ts  `export const en = {…} as const`; es typed against en
```

## Dependency rules (lint: `import/no-restricted-paths`, zones read from disk)

| From | May import |
|---|---|
| `src/app` | features, ui, core, app-config; `translations.ts` only in the root layout |
| `src/features/<x>` | its own folder, the shared domain (`account`, `employee`, `auth`), ui, core, app-config |
| `src/ui` | only `src/ui` |
| `src/core` | only `src/core` and `app-config.ts` |
| `src/app-config.ts` | nothing |

Inside a feature:

| Layer | May import |
|---|---|
| `domain` | only `domain` (and pure `@/core/format/*`) |
| `data` | `domain`, `core` |
| `presentation/queries` | `data`, `domain`, `core` |
| `presentation/components`, `screens` | `presentation/queries`, `domain`, `ui`, `core` — **never `data`** |

Other lint guards: `expo-secure-store` only in `core/secure-store.ts`; `axios` only in core;
`account-provider` only in routes; no `.role` comparison outside `capabilities.ts`; no `try` and no
`useQueryClient` in `.tsx`; `no-console` except `core/monitoring.ts`; `import/no-cycle`.

When two features meet on one screen, **the route composes them**. Something two features need
moves down to `core` or `ui`. Adding to `SHARED_FEATURES` is an ADR, not a lint fix.

## Principles

1. **Server is the source of truth** → TanStack Query. Client state is session, current
   assignment, toast, URL params and local state.
2. **Derive, don't store**: role, capabilities, tabs and scope come from the current assignment.
3. **PII minimum, proven**: allow-list mappers + privacy contract tests; nothing persisted but
   secure-store and the cache folders Log Out empties.
4. **Copyable**: `core`, `ui`, `app-config.ts`, lint/TS/Jest config, tools and docs are copied to
   Staffology; features and routes are replaced.
5. **Decisions are recorded** in `docs/adr/`; changing one means a new ADR.

## Where does it go?

| Thing | Place |
|---|---|
| New endpoint read | `data/raw.ts` + `data/mappers.ts` (+ privacy test) + `data/fetchers.ts` + query in `presentation/queries` |
| New write | function in `data/fetchers.ts` + `useMutation` in `presentation/queries/mutations.ts` |
| Business rule (pure) | `domain/<topic>.ts` |
| Flow with several calls/rules | `domain/usecases/` |
| Role decision | `features/account/capabilities.ts` |
| Link to a page | builder in `core/hrefs.ts` |
| Cross-cutting infra | `src/core/*` |
| Generic visual component | `src/ui/*` |
| New route | `src/app/...` thin route + screen in `presentation/screens` |
| Words | `features/x/locales/en.ts` + `es.ts` |

## What we don't do (binding — change only through a new ADR)

Redux/Zustand/MobX · barrel `index.ts` per feature · generated API client or types · zod for
responses · persisted query cache · repositories / DI container · wholesale Suspense · coverage
gate · snapshot tests · Detox · Storybook · remote logging · Session Replay / screenshots to a
crash reporter · `href: null` to hide a tab.
