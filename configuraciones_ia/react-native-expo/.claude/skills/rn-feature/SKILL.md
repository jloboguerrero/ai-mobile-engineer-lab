---
name: rn-feature
description: Scaffolds a complete feature under src/features/<name>/ (data/domain/queries/forms/ui/i18n + di.ts + index.ts + MSW mocks + tests) and its 1-line route in app/, following this project's React Native + Expo conventions. Use when starting a brand-new feature, before writing its code by hand.
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(ls:*), Bash(npx tsc:*), Bash(npx eslint:*), Bash(npm test:*)
---

# rn-feature

Applies `.claude/rules/architecture.md`, `data-and-api.md`, `server-state.md`,
`naming-and-style.md` and `i18n.md`. Read them first — this skill doesn't restate them.

## Inputs (ask or infer)

- feature slug (kebab-case, e.g. `timeoff`, `team-requests`) and camel/Pascal forms
- first endpoint: method + path + which response fields the screen needs
- key scope: `employeeId` (assignment), `userId` (person) or `scope` (manager)
- does it have a form? (adds `forms/` + mutation)

## Steps

1. Check `src/features/` for collisions; read one existing feature (`di.ts`, `queries.ts`, a
   screen) to match real import paths — prefer it over the templates when they differ.
2. Look up the DTO in `src/core/api/generated/` (if not there: tell the user to run `npm run api:types`).
3. Create from `templates/` replacing `{{feature}}` (camel, e.g. `timeOff`), `{{Feature}}` (Pascal),
   `{{slug}}` (kebab), `{{Entity}}`, `{{path}}`:
   - `data/{{feature}}Api.ts`, `data/dto.ts`, `data/mappers.ts` (+ `mappers.test.ts`)
   - `domain/types.ts`
   - `queries/keys.ts`, `queries/queries.ts` (+ `mutations.ts` if form)
   - `forms/schema.ts`, `forms/toRequest.ts` (+ tests) if form
   - `ui/screens/{{Feature}}Screen.tsx` (+ `.test.tsx`)
   - `i18n/en.json` **and** `i18n/es.json`
   - `mocks/handlers.ts`, `mocks/fixtures.ts` (fake PII only)
   - `di.ts`, `index.ts`
4. Register: i18n namespace in `src/core/i18n/setup.ts`, MSW handlers in `test/msw/handlers.ts`,
   route file in `app/` (1 line), tab in `(tabs)/_layout.tsx` if applicable.
5. Run `npx tsc --noEmit` and `npm test -- src/features/{{slug}}`; report results.
6. Stop at the skeleton with one endpoint wired end to end. No extra business logic.
