---
name: rn-form
description: Builds a form in an existing feature with local state, pure rules in domain/, the shared useFormState helper, a toRequest mapper and a never-retried mutation, plus tests. Use for any new form or when moving an ad-hoc form to the standard.
allowed-tools: Read, Glob, Grep, Write, Edit, Bash(npx tsc:*), Bash(npx jest:*)
---

# rn-form

Read `.claude/rules/forms.md` (and `security-pii.md` for bank, compensation or password forms).

1. Rules in `domain/<topic>.ts`: field checks, cross-field rules, totals, hints, `canSend`.
   Pure, unit-tested (valid, each invalid case, edge cases of the API guide).
2. `toRequest` in `data/mappers.ts`: domain values → body (`''` → `null`, `MM/dd/yyyy`, numbers vs
   strings, exclusive keys, read-only fields resent as read). Unit-tested.
3. Mutation via `rn-query` conventions if it doesn't exist (never retried; lost-answer rule;
   `meta.sensitive` when needed).
4. Component: `useFormState({ initial, mutation })` from `@/core/form-state`; fields from `@/ui`
   (`TextField`, `Select`, `DateRangeField`…) showing `form.fieldError(name)`; `formError` as a
   banner. Save disabled `!form.isDirty || mutation.isPending`. No `try` in the component.
   `KeyboardAwareScreen` for pages with fields; every opening starts fresh (`useOpenings` + `key`).
5. Flow over two screens → Context in that route's `_layout.tsx`.
6. Never persist drafts for Direct Deposit, compensation or passwords.
7. Component test (RNTL, by role and name): Save disabled until a change; a server 400 naming a
   field shows under that field; the write is sent once.
