# React Native + Expo Project — Claude Instructions

This file is a **routing index**, not a manual. It is paid for on every request, so the
detail lives in `.claude/rules/` and loads only when relevant.

## Stack

Expo (current SDK, New Architecture, **dev build — not Expo Go**) · TypeScript strict ·
Expo Router · TanStack Query v5 (server state) · Zustand (client state, 2–3 small stores) ·
axios · React Hook Form + Zod · Unistyles 3 · i18next (en + es) · expo-secure-store + MMKV ·
FlashList · expo-image · Jest + RNTL + MSW · Maestro · EAS Build/Update/Submit.

Feature-first + Clean Architecture "lite". Adjust "Stack" and "Commands" to the real
project before relying on them.

## Commands

```bash
npx tsc --noEmit                 # typecheck — must be clean before any commit
npm run lint                     # eslint (expo + boundaries + perfectionist + tanstack)
npx eslint --fix <file>          # autofix ordering (imports, props, keys)
npm test                         # jest (unit + RNTL/MSW integration)
npm test -- <path>               # one file / folder
npm run api:types                # openapi.json → src/core/api/generated (never hand-edit)
npx expo install <pkg>           # add a native-compatible dependency (never plain npm i)
npx expo install --check         # SDK version alignment
npx expo start --dev-client      # run on a dev build
maestro test e2e/                # E2E smoke flows
```

## Architecture (short)

```
app/                    Expo Router — ROUTES ONLY, 1-line files re-exporting a screen
src/core/               api, query, session, push, files, config, i18n, logger
src/ui/                 design system: tokens → theme → primitives → components → form → layout
src/features/<x>/
  data/      xApi.ts · dto.ts · mappers.ts
  domain/    types.ts · rules.ts · enums.ts · (usecases only if orchestration)
  queries/   keys.ts · queries.ts · mutations.ts
  forms/     schema.ts · toFormValues.ts · toRequest.ts
  ui/        components/ · screens/
  i18n/      en.json · es.json
  di.ts      composition root (factories wired to api)
  index.ts   public API — the ONLY thing other code may import
```

Dependency direction: `app → features(index) → core, ui`; `ui → nothing`; `core ↛ features`.

## Rules index — read on demand

| Working on… | Read first |
|---|---|
| Folders, new feature, boundaries | `.claude/rules/architecture.md` |
| HTTP, DTOs, mappers, `ApiError`, 401/428 | `.claude/rules/data-and-api.md` |
| `useQuery`/`useMutation`, keys, cache | `.claude/rules/server-state.md` |
| Zustand stores, session, assignment | `.claude/rules/client-state.md` |
| Custom hooks vs use cases | `.claude/rules/hooks-and-usecases.md` |
| Components, screens, lists, a11y | `.claude/rules/components.md` |
| Routes, guards, login/logout, deep links | `.claude/rules/navigation-auth.md` |
| Any form | `.claude/rules/forms.md` |
| Styles, tokens, theme | `.claude/rules/styling-ds.md` |
| Texts, dates, numbers | `.claude/rules/i18n.md` |
| Naming, import order, sorting | `.claude/rules/naming-and-style.md` |
| Storage, logging, Sentry, PII | `.claude/rules/security-pii.md` |
| Any test file | `.claude/rules/testing.md` |

## Always-on rules (apply to every edit)

1. TS strict. No `any`; `as` only inside mappers/tests with a one-line reason.
2. No `console.*` — use `@/core/logger`. Never log responses, tokens or PII.
3. `app/` files only re-export a screen from `@/features/<x>` — no logic, no hooks.
4. Import another feature only through its `index.ts`. Never its internals.
5. Server data lives in TanStack Query. Never copy query data into `useState` or Zustand.
6. Never retry writes: mutations `retry: false`; submit disabled while `isPending`.
7. Mappers DTO → domain keep only used fields. SSN / bank numbers never leave `data/`.
8. Errors reach the UI only as `ApiError` (`kind`). 401 signs out **only** when
   `message === 'Unauthorized'`; any other 401 is `denied`.
9. Styles only from `@/ui` semantic tokens; user-facing text only via i18n (en + es).
10. Add deps with `npx expo install`. Never edit `ios/` or `android/` (CNG) — use
    `app.config.ts` / config plugins.
11. Never hand-edit generated files (`src/core/api/generated/**`, `src/ui/tokens/generated/**`).
12. Rules of hooks; complete effect deps; derive values instead of syncing with `useEffect`.
13. Alphabetical order (props, object keys, types, named imports) and grouped imports
    `react → expo → third-party → @/ → relative → type` — eslint `perfectionist` enforces it.
14. Files ≤250 lines target, 450 hard limit (hook blocks). Split into feature components.

## How to work in this repo

- Grep before read; read line ranges of big files.
- Subagents for open-ended search (`Explore`) or planning (`rn-architect`).
- Hooks run prettier + eslint --fix on every edited `.ts/.tsx`; don't re-run manually per line.
- Never commit or push without being asked. `/ship` proposes a message, doesn't commit.
- If an approved spec exists in `specs/`, follow it — don't re-decide architecture.
