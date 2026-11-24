---
description: Regenerate API types from shr-be Swagger and report drift against features' DTO Picks
allowed-tools: Read, Glob, Grep, Bash(npm run api:types:*), Bash(git diff:*), Bash(npx tsc:*)
---

1. `npm run api:types` (openapi-typescript → `src/core/api/generated/`).
2. `git diff --stat src/core/api/generated/` — summarize added/removed/changed schemas.
3. `npx tsc --noEmit` — any error in `features/*/data/dto.ts` or mappers means a field we depend
   on changed. List them as `feature | field | change`.
4. Don't edit generated files. Propose mapper/DTO fixes; apply only if asked.
