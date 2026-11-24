---
name: rn-form
description: Builds a form in an existing feature with React Hook Form + Zod using the three-file pattern (schema, toFormValues, toRequest), src/ui Form* fields, applyServerError, the save mutation and tests. Use for any new form or when refactoring an ad-hoc form to the standard.
allowed-tools: Read, Glob, Grep, Write, Edit, Bash(npx tsc:*), Bash(npm test:*)
---

# rn-form

Read `.claude/rules/forms.md` (and `security-pii.md` for bank/compensation forms).

1. `forms/schema.ts`: Zod with UI types; messages are i18n keys (add en + es).
   Cross-field rules via `superRefine`; reuse `domain/rules.ts` functions, don't duplicate.
2. `forms/toFormValues.ts` (model → values) and `forms/toRequest.ts` (values → DTO, quirks).
   Unit-test both, including round trip `toRequest(toFormValues(model))`.
3. Mutation via `rn-query` conventions if it doesn't exist.
4. Screen/component: `useForm({ resolver: zodResolver(schema), values })`, fields from
   `@/ui` (`FormTextField`, `FormSelect`, `FormDateField`…), `handleSubmit` → `mutate` with
   `onError: (e) => applyServerError(form, e)`. Save disabled `!isDirty || isPending`.
   `KeyboardAwareScrollView`. `useFieldArray` for repeated rows.
5. Multi-screen flow → `FormProvider` in the route `_layout.tsx`.
6. Never persist drafts for Direct Deposit / compensation.
7. Integration test: valid submit sends the expected body once; server 400 with path shows the
   field error; invalid input keeps Save disabled.
