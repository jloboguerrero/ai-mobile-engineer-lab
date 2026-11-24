---
name: rn-feature
description: Scaffolds a complete feature under src/features/<name>/ (domain / data / presentation / locales en+es, privacy contract test, fetcher test) and its thin route in src/app, following this project's React Native + Expo conventions. Use when starting a brand-new feature, before writing its code by hand.
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(ls:*), Bash(npx tsc:*), Bash(npx eslint:*), Bash(npx jest:*)
---

# rn-feature

Applies `.claude/rules/architecture.md`, `data-and-api.md`, `server-state.md`,
`naming-and-style.md`, `i18n.md` and `testing.md`. Read them first — this skill doesn't restate them.

## Inputs (ask or infer)

- feature slug (kebab-case, e.g. `time-off`, `requests`) and its camel form (`timeOff`)
- first endpoint: method + path + **which response fields the screen needs** (and which sensitive
  fields shr-be puts in that answer — the API guide says)
- whose data: `employeeId` (assignment), `userId` (person) or `scope` (manager team)
- cache policy (`standard`, `perSession`, `reference`, `live(ms)`, `sensitive`)
- does it write? (adds a fetcher + mutation)

## Steps

1. Check `src/features/` for collisions; read one existing layered feature to match real import
   paths and helpers — prefer it over the templates when they differ.
2. Create from `templates/` replacing `{{feature}}` (camel), `{{Feature}}` (Pascal), `{{slug}}`
   (kebab), `{{Entity}}`, `{{path}}`:
   - `domain/types.ts`
   - `data/raw.ts`, `data/mappers.ts` + `mappers.test.ts` (privacy contract), `data/fetchers.ts` + `fetchers.test.ts`
   - `presentation/queries/keys.ts`, `queries.ts` (+ `mutations.ts` if it writes)
   - `presentation/screens/{{slug}}-screen.tsx` (+ `.test.tsx`)
   - `locales/en.ts` **and** `locales/es.ts`
3. Register the catalogs in `src/translations.ts` (en and es), add the thin route under
   `src/app/(app)/...` (template `route.tsx`), a link builder in `core/hrefs.ts` if other pages
   link to it, and a tab inside `Tabs.Protected` only if a capability decides it.
4. Add the endpoint to the mock API (`tools/mock-api/mocks/`) with made-up data and run
   `node tools/mock-api/privacy-scan.mjs`.
5. Run `npx tsc --noEmit`, `npx eslint src/features/{{slug}}` and `npx jest src/features/{{slug}}`.
6. Stop at the skeleton with one endpoint wired end to end. No extra business logic.
