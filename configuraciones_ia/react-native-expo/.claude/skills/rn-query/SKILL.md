---
name: rn-query
description: Adds one query or mutation to an existing feature end to end — DTO Pick, mapper + test, api function, key, queryOptions/hook (or useMutation with prefix invalidation), MSW handler + fixture, integration test. Use when a feature needs a new endpoint, not for a new feature.
allowed-tools: Read, Glob, Grep, Write, Edit, Bash(npx tsc:*), Bash(npm test:*)
---

# rn-query

Read `.claude/rules/data-and-api.md` and `server-state.md` first.

1. Find the endpoint in `src/core/api/generated/` and in the API guide notes; decide key scope
   (`employeeId` / `userId` / `scope`) and `staleTime` from the table in `server-state.md`.
2. `data/dto.ts`: add a `Pick<>` with only the fields used.
3. `data/mappers.ts`: `toX(dto)` + unit test (include a case proving PII fields are dropped).
4. `data/xApi.ts`: method returning the domain type. Known quirks handled here with a comment.
5. `queries/keys.ts`: new key under the right parent so prefix invalidation works.
6. Query → `xQuery` queryOptions + `useX` hook. Mutation → `useVerbX` with `onSuccess`
   invalidation by prefix; no `retry`; single-flight if non-idempotent.
7. `mocks/handlers.ts` + `fixtures.ts`; integration test for success + one `ApiError.kind`.
   For mutations, assert the POST was sent exactly once.
8. Export from `index.ts` only what another feature needs.
9. `npx tsc --noEmit` + `npm test -- src/features/<x>`.
