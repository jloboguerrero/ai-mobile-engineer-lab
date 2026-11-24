---
description: Design a feature spec, then scaffold it against this project's React Native conventions
argument-hint: <short feature description>
allowed-tools: Read, Glob, Grep, Write, Edit, AskUserQuestion, Bash(ls:*), Bash(npx tsc:*), Bash(npm test:*)
---

Feature request: $ARGUMENTS

1. If a `/spec` skill is available and `specs/` exists, run the spec flow first (`/spec` → human
   approves → `/spec-impl`). Don't duplicate it here.
2. Otherwise, for non-trivial features, ask the `rn-architect` agent for a plan first.
3. Use the `rn-feature` skill to scaffold `src/features/<slug>/` + route.
4. Run `npx tsc --noEmit` and the feature tests; report.
5. Skeleton only — no business logic beyond the first endpoint unless asked.
