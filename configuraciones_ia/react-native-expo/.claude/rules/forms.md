# Forms — React Hook Form + Zod

## Three files per form (`features/x/forms/`)

| File | Responsibility |
|---|---|
| `schema.ts` | Zod schema with **UI types** (Date, number, enums) + `type XFormValues = z.infer<…>`. Messages are i18n keys |
| `toFormValues.ts` | domain model → form values (defaults, `null` → `''`) |
| `toRequest.ts` | form values → request DTO. Absorbs API quirks: `''` → `null`, `MM/dd/yyyy`, numbers vs strings, mutually exclusive keys, resending read-only fields |

All three are pure and unit-tested.

## Lifecycle

```tsx
const profile = useProfile();
const mutation = useUpdateProfile();
const form = useForm<ProfileFormValues>({
  resolver: zodResolver(profileSchema),
  values: profile.data ? toFormValues(profile.data) : undefined, // `values`, not defaultValues, for server data
});

const onSubmit = form.handleSubmit((values) =>
  mutation.mutate(toRequest(values, profile.data), {
    onError: (error) => applyServerError(form, error), // 400 with path → setError; rest → banner
  }),
);

<Button disabled={!form.formState.isDirty || mutation.isPending} onPress={onSubmit} title={t('save')} />
```

- Fields only through `src/ui/form` wrappers: `FormTextField`, `FormPhoneField` (999-999-9999),
  `FormSelect`, `FormDateField`, `FormCheckbox`… They wrap `Controller` and show the error.
- `applyServerError` lives in `src/core/api` and uses `ApiError.fieldErrors`.
- Keyboard: `KeyboardAwareScrollView` from `react-native-keyboard-controller`.
- Multi-step flows sharing a form: `FormProvider` in the route `_layout.tsx` (Direct Deposit edit → review).
- `useFieldArray` for repeated rows (hours per day, emergency contacts).

## Drafts

| Form | Draft |
|---|---|
| Announcement | server (draft endpoint) |
| Short forms | memory only |
| Direct Deposit, compensation | **never persisted** (no MMKV, no autosave) |

## Per-form notes (SHR)

| Form | Note |
|---|---|
| Time Off | `useFieldArray` hours/day (default 8, max 8); 400 "Request fufilled…" = success; one component for Home and Time Off |
| Direct Deposit | rules in `domain/allocation.ts` + `superRefine`; no autocorrect; one pending change at a time |
| Emergency contacts | send full list on save |
| Profile | fixed enums in `domain/enums.ts`; read-modify-write |
| Compensation (SM) | OT 1.5× computed on change; min blocks / max warns; may hit 428 |
| Announcement | tentap-editor limited to `p strong em u ul ol li a img`; audience as discriminated union |
