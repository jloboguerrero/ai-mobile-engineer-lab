# React Native + Expo Project — Claude Instructions

This file is a **routing index**, not a manual. It is paid for on every request, so the
detail lives in `.claude/rules/` and loads only when relevant.

## Stack

Expo SDK (current) · New Architecture · **development build (not Expo Go)** · React Compiler ·
TypeScript strict · Expo Router (typed routes) · TanStack Query v5 · axios · i18next (en + es) ·
expo-secure-store · `StyleSheet` + `ui/theme.ts` · lucide-react-native · expo-image ·
Jest + RNTL + network stubs · Maestro · EAS Build/Update/Submit · Bitbucket Pipelines.

No global store library, no DI container, no repositories, no barrels, no zod, no generated
API client, no persisted cache — see `.claude/rules/architecture.md` "What we don't do".

Feature-first + Clean Architecture "lite" (domain / data / presentation). Adjust "Stack" and
"Commands" to the real project before relying on them.

## Commands

```bash
npm run verify                   # typecheck + lint + format:check + tests + expo-doctor (gate before push)
npm run typecheck                # tsc --noEmit
npm run lint                     # eslint (expo + layers + perfectionist + tanstack), 0 warnings
npx eslint --fix <file>          # autofix ordering (imports, props, keys)
npm test                         # jest, once (never watch)
npx jest <path>                  # one file / folder
npm run mock                     # stand-in shr-be with scenarios (tools/mock-api)
node tools/mock-api/privacy-scan.mjs   # after any change to mock data
npx expo install <pkg>           # add a dependency (never plain npm i)
npx expo start --dev-client      # run on the development build
maestro test e2e/                # E2E smoke flows (later)
```

## Architecture (short)

```
src/app/                Expo Router — routes + layouts only. Routes read useAccount /
                        useCapabilities / params and pass ids, flags and links as props
src/app-config.ts       what makes this app SimplifyHR on shr-be (imports nothing)
src/translations.ts     registers every catalog (only the root layout imports it)
src/core/               api, api-error, session, secure-store, query, cache, files, upload,
                        hrefs, i18n, format/, monitoring, screen-privacy, form-state
src/ui/                 design system: theme.ts + components + locales (imports only ui)
src/features/<x>/
  domain/        types.ts · pure rules (*.ts) · usecases/ (only orchestration)
  data/          raw.ts · fetchers.ts · mappers.ts (allow-list + toRequest)
  presentation/  queries/ (keys · queries · mutations) · components/ · screens/
  locales/       en.ts · es.ts
```

Layers: `app → features → ui, core`; `core` imports nothing above it; `ui` imports only `ui`.
Inside a feature: `domain` ← `data` ← `presentation/queries` ← `components`/`screens`
(never `data` from components). Features import each other only from the shared domain
(`account`, `employee`, `auth`).

## Rules index — read on demand

| Working on… | Read first |
|---|---|
| Folders, new feature, layers, what we don't do | `.claude/rules/architecture.md` |
| HTTP, raw types, mappers, `ApiError`, 401/428 | `.claude/rules/data-and-api.md` |
| `useQuery`/`useMutation`, keys, `CachePolicy` | `.claude/rules/server-state.md` |
| Session, current assignment, toast, URL state | `.claude/rules/client-state.md` |
| Custom hooks vs use cases | `.claude/rules/hooks-and-usecases.md` |
| Components, screens, lists, a11y | `.claude/rules/components.md` |
| Routes, guards, capabilities, login/logout, expiry | `.claude/rules/navigation-auth.md` |
| Any form | `.claude/rules/forms.md` |
| Styles, theme | `.claude/rules/styling-ds.md` |
| Texts, dates, numbers | `.claude/rules/i18n.md` |
| Naming, import order, sorting | `.claude/rules/naming-and-style.md` |
| Storage, logging, monitoring, PII | `.claude/rules/security-pii.md` |
| Any test file | `.claude/rules/testing.md` |

## Always-on rules (apply to every edit)

1. TS strict. No `any`; `as` only inside mappers/tests with a one-line reason.
2. No `console.*` outside `core/monitoring.ts`; unexpected failures go through `reportError`.
   Never log responses, tokens or PII.
3. Routes are thin: read account/capabilities/params, build links in `core/hrefs.ts`, render a
   feature screen. No queries, no state, no sheets in route files.
4. Every role decision goes through `features/account/capabilities.ts`. Never compare `.role`.
5. Server data lives in TanStack Query. Never copy query data into `useState`. No `useQueryClient`
   in screens: refresh/invalidate through hooks (`useRefreshX`, `invalidateX()`).
6. Never resend writes: mutations and queries `retry: false` (the API client resends GETs only);
   each write decides what a lost answer means. Submit disabled while `isPending`.
7. Every response goes through an allow-list mapper with a privacy contract test.
   SSN / full bank numbers never leave `data/` (except Direct Deposit, tagged `sensitive`).
8. Failures are `ApiError`: read with `apiErrorOf`, show with `errorText`. Only a 401 with
   message exactly `Unauthorized` ends the session.
9. Styles only from `ui/theme.ts` tokens; user-facing text only via i18n keys (en + es together).
10. No `try` in `.tsx` files nor in `use*` hooks (React Compiler skips them). Use a mutation,
    a promise chain or a `.ts` module.
11. Add deps with `npx expo install`. Never edit `ios/` or `android/` (CNG).
12. Rules of hooks; complete effect deps; derive values instead of syncing with `useEffect`.
13. Alphabetical order (props, object keys, types, named imports) and grouped imports
    `react → expo → third-party → @/ → relative → type` — eslint `perfectionist` enforces it.
14. Files ≤250 lines target, 450 hard limit (hook blocks). Split into feature components.
15. Every logic fix lands with a regression test that fails without it.

## How to work in this repo

- Read `docs/architecture.md` and `docs/adr/` before changing structure. Changing a decision
  of an ADR means writing a new ADR.
- Grep before read; read line ranges of big files.
- Features still on the old flat `api.ts` are migrated one feature per PR, without changing
  behaviour; new code always uses the layered layout.
- Subagents for open-ended search (`Explore`) or planning (`rn-architect`).
- Hooks run prettier + eslint --fix on every edited `.ts/.tsx`; don't re-run manually per line.
- Never commit or push without being asked. `/ship` proposes a message, doesn't commit.
- If an approved spec exists in `specs/`, follow it — don't re-decide architecture.
