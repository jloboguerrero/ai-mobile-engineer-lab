# Forms — local state + pure rules + `useFormState`

No form library (React Compiler compatibility, full control over custom forms such as Direct
Deposit allocations or hours per day). What every form shares lives in one helper.

## Pieces

| Piece | Where | Responsibility |
|---|---|---|
| Rules | `domain/<topic>.ts` (`request.ts`, `draft.ts`) | validation, totals, hints, `canSend` — pure, tested |
| `useFormState` | `core/form-state.ts` | values + initial values → `isDirty`; field errors; server error mapping; submit state |
| `toRequest` | `data/mappers.ts` | domain values → request body (API quirks) |
| Mutation | `presentation/queries/mutations.ts` | the write, never retried |

## `useFormState` contract

```ts
const form = useFormState({ initial: toFormValues(profile), mutation: save });
form.values / form.set('mobilePhone', v) / form.isDirty
form.fieldError('mobilePhone')   // local rule or a server 400 that names the field
form.formError                    // any other failure, via errorText
form.submit(() => save.mutate(toRequest(form.values, profile)))   // blocked while isPending
```

- Save disabled with `!form.isDirty || save.isPending`. The component keeps no busy flag.
- A 400 that names a field (`emergencyContact.0.workEmail must be an email`) → that field's error;
  anything else → `formError`.
- No `try` in the component: the write is a mutation; react in `mutate`'s callbacks.

## Lifecycle

- Every opening starts from a fresh form (`useOpenings` + `key`).
- A refusal keeps the form as it is with shr-be's reason. Nothing is resent by itself.
- Keyboard: `KeyboardAwareScreen` (keyboard-controller once the dev build has it).
- Bank inputs: `autoCorrect={false}`, `autoComplete="off"`, `textContentType="none"`.

## Drafts

| Form | Draft |
|---|---|
| Announcement | server (draft endpoint) |
| Short forms | memory only, while mounted |
| Direct Deposit, compensation, passwords | **never persisted**; `meta.sensitive`, short `gcTime` |

## Per-form notes (SHR)

| Form | Note |
|---|---|
| Time Off | hours per day for the range (`daysOf`, `checkRequest`); 400 "Request fufilled…" = success; one component for Home and Time Off |
| Direct Deposit | allocation rules in `domain/draft.ts`; editor + review; capture blocked; `submitOrFind` |
| Emergency contacts / Profile | full list on save; fixed enums; read-modify-write |
| Change Password | `gcTime: 0`; success message in the hook's `onSuccess` |
| Compensation (SM) | OT 1.5× on rate change; min blocks / max warns; 428 |
| Announcement | HTML limited to `p strong em u ul ol li a img`; exclusive audience keys |
