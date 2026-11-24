---
name: rn-query
description: Adds one query or mutation to an existing feature end to end — raw type (only read fields), allow-list mapper + privacy contract test, fetcher + stubNetwork test, key, queryOptions with a CachePolicy and one-line hook (or useMutation with invalidation), mock API scenario. Use when a feature needs a new endpoint, not for a new feature.
allowed-tools: Read, Glob, Grep, Write, Edit, Bash(npx tsc:*), Bash(npx jest:*), Bash(npx eslint:*)
---

# rn-query

Read `.claude/rules/data-and-api.md` and `server-state.md` first.

1. From the API guide: method, path, params, the fields the screen needs, the sensitive fields in
   the answer, quirks (a 400 that means success, an empty 200, a bare-text body).
2. `data/raw.ts`: a `RawX` type with only the fields read.
3. `data/mappers.ts`: `toX(raw)` copying each field by name + **privacy contract test**
   (`SENSITIVE` / `leaksOf`) in `mappers.test.ts`.
4. `data/fetchers.ts`: `fetchX(id, signal)` returning the domain type, or a write function that
   decides what a lost answer means. Test with `stubNetwork` (quirk + one failure kind).
5. `presentation/queries/keys.ts`: a key under the right root, kind before the id.
6. Read → `xxxQueries.x(id)` with a `CachePolicy` + `useX(id)` one-liner taking whose data it reads.
   Write → `useVerbX(id)` with `mutationKey: [root, verb]`, never retried; cache work in
   `onSuccess`; `meta.sensitive` + short `gcTime` for bank numbers or passwords. Another
   feature's keys only through its `invalidateX()`.
7. If it orchestrates several calls, a use case in `domain/usecases/` receiving the fetchers as a
   parameter (`hooks-and-usecases.md`).
8. Mock API: the route with made-up data; `node tools/mock-api/privacy-scan.mjs`.
9. `npx tsc --noEmit` + `npx jest src/features/<x>`.
