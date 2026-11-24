# Naming, ordering, imports

## Files

| Kind | Name | Example |
|---|---|---|
| Component / screen | `PascalCase.tsx` | `TimeOffCard.tsx`, `TimeOffScreen.tsx` |
| Hook | `useCamelCase.ts` (or grouped in `queries.ts`) | `useCountdown.ts` |
| Module / function file | `camelCase.ts` | `timeoffApi.ts`, `mappers.ts`, `toRequest.ts` |
| Store | `xStore.ts` | `sessionStore.ts` |
| Test | next to the file, `.test.ts(x)` | `mappers.test.ts` |
| Route (Expo Router) | kebab-case, dictated by URL | `app/(app)/pay/direct-deposit/edit.tsx` |
| Folder | kebab-case for features, lowercase for layers | `team-requests/`, `data/` |

No `index.ts` barrels inside layers — the only barrels are the feature `index.ts`, `src/ui/index.ts`
and `src/core/<module>/index.ts`.

## Identifiers

| Role | Convention | Example |
|---|---|---|
| API factory | `createXApi` → instance `xApi` | `createTimeOffApi`, `timeoffApi` |
| Query key factory | `xKeys` | `timeoffKeys.summary(id)` |
| queryOptions builder | `xQuery` | `summaryQuery(id)` |
| Query hook | `useX` (noun) | `useTimeOffSummary` |
| Mutation hook | `useVerbX` | `useRequestTimeOff` |
| Mapper | `toX` | `toSummary`, `toRequest`, `toFormValues` |
| Zod schema / type | `xSchema` / `XFormValues` | `timeOffSchema` |
| Domain type | `PascalCase`, no suffix | `TimeOffSummary`, `Assignment` |
| DTO type | `XDto` | `SummaryDto` |
| Props | `XProps` | `TimeOffCardProps` |
| Boolean | `is/has/can/should` | `canRequest` |
| Event prop / handler | `onX` prop, `handleX` inside | `onPress={handleSubmit}` |
| Constants | `SCREAMING_SNAKE` only for true constants | `MAX_HOURS_PER_DAY` |

- `type` over `interface` (unions, mapped types); `interface` only for extendable public contracts.
- Unions of string literals over TS `enum` (except where the API enum is generated).
- Named exports everywhere except Expo Router route files.
- Comments in English unless the file is already Spanish.

## Alphabetical ordering (enforced, autofix)

`eslint-plugin-perfectionist` sorts and `eslint --fix` (run by the hook) fixes it:

- **JSX props**: alphabetical; `key`/`ref` first; `on*` callbacks last group.
- **Object keys** and destructuring, **type/interface members**, **union members**, **enums**,
  **named imports/exports**: alphabetical.
- Blank line = partition: sorting restarts after an empty line (use it to keep intentional groups).
- Exceptions where order has meaning: query key factories (`queries/keys.ts`, rule off), arrays
  (steps, tabs, routes — arrays are never sorted), function parameters (positional — prefer a
  single object param when > 2, whose keys then get sorted).

```tsx
<Button
  key={item.id}
  disabled={!isDirty || isPending}
  icon="send"
  title={t('send')}
  variant="primary"
  onLongPress={showHelp}
  onPress={onSubmit}
/>
```

## Import order (enforced, autofix)

Groups separated by a blank line, alphabetical inside each:

1. `react`, `react-native` (and their subpaths)
2. `expo`, `expo-*`, `@expo/*`, `expo-router`
3. third-party (`@tanstack/*`, `axios`, `date-fns`, `react-hook-form`, `zod`, `zustand`…)
4. internal alias `@/core/*`, `@/ui`, `@/features/*`
5. relative (`../`, `./`)
6. type-only imports (`import type …`), same internal ordering
7. side-effect imports (`import './setup'`)

```ts
import { useMemo } from 'react';
import { View } from 'react-native';

import { useLocalSearchParams } from 'expo-router';

import { useQuery } from '@tanstack/react-query';
import { format } from 'date-fns';

import { logger } from '@/core/logger';
import { useCurrentEmployeeId } from '@/features/session';
import { Button, Card } from '@/ui';

import { timeoffApi } from '../di';
import { timeoffKeys } from './keys';

import type { TimeOffSummary } from '../domain/types';
```

- Always `@/` alias for anything outside the current feature. Relative only within the feature,
  max `../` one level (deeper → use `@/features/x/...` is forbidden too; restructure).
