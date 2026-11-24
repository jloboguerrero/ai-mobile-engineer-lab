# Naming, ordering, imports

## Files

| Kind | Name | Example |
|---|---|---|
| Any `.ts` / `.tsx` | **kebab-case** | `request-sheet.tsx`, `pick-current-assignment.ts` |
| Test | next to the file, `.test.ts(x)` | `mappers.test.ts` |
| Fixture (tests only) | `.fixture.ts(x)` | `network.fixture.ts`, `sensitive.fixture.ts` |
| Web-preview variant | sibling `.web.ts` with the same exports | `transfer.web.ts` |
| Route | kebab-case, dictated by URL | `src/app/(app)/pay/stub/[id].tsx` |
| Folder | kebab-case | `time-off/`, `direct-deposit/` |

**No barrel `index.ts`** anywhere (Metro does not tree-shake native bundles; barrels invite cycles).
Import the file: `@/ui/button`, `@/features/account/capabilities`.

## Identifiers

| Role | Convention | Example |
|---|---|---|
| Fetcher | `fetchX` / verb for writes | `fetchSummary`, `sendTimeOffRequest` |
| Mapper | `toX` | `toSummary`, `toRequest` |
| Raw type | `RawX` | `RawSummary` |
| Query keys | `xxxKeys` | `timeOffKeys.summary(id)` |
| Query options | `xxxQueries.x(...)` | `timeOffQueries.summary(id)` |
| Query hook | `useX` (noun) | `useTimeOffSummary(employeeId)` |
| Mutation hook | `useVerbX` | `useRequestTimeOff(employeeId)` |
| Cross-feature refresh | `invalidateX()` | `invalidateAccount()` |
| Use case | verb phrase | `pickCurrentAssignment`, `submitOrFind` |
| Domain type | `PascalCase`, no suffix | `TimeOffSummary`, `Assignment` |
| Props | `XProps` | `TimeOffRequestSheetProps` |
| Boolean | `is/has/can/should` | `canSend` |
| Event prop / handler | `onX` prop | `onPress`, `onClose` |
| Constants | `SCREAMING_SNAKE` only for true constants | `DEFAULT_HOURS` |

- `type` over `interface`; unions of string literals over `enum`.
- Named exports everywhere except route files.
- Comments in English and explain **why** (a server quirk, a platform trap), not what.

## Alphabetical ordering (enforced, autofix)

`eslint-plugin-perfectionist`; `eslint --fix` (run by the hook) fixes it:

- **JSX props**: alphabetical; `key`/`ref` first; `on*` callbacks last.
- **Object keys**, destructuring, **type members**, **union members**, **named imports/exports**.
- Blank line = partition (sorting restarts).
- Exceptions where order has meaning: `presentation/queries/keys.ts`, `core/cache.ts`, arrays
  (steps, tabs, routes), positional function parameters (prefer one object param when > 2).

```tsx
<Button
  key={item.id}
  disabled={!form.isDirty || save.isPending}
  loading={save.isPending}
  title={t('save')}
  variant="primary"
  onPress={submit}
/>
```

## Import order (enforced, autofix)

Groups separated by a blank line, alphabetical inside each:

1. `react`, `react-native` (and subpaths)
2. `expo`, `expo-*`, `@expo/*`, `expo-router`
3. third-party (`@tanstack/*`, `axios`, `date-fns`, `i18next`, `lucide-react-native`…)
4. internal alias `@/…`
5. relative (`../`, `./`)
6. type-only imports (`import type …`)
7. side-effect imports (`import '@/translations'`)

```ts
import { useState } from 'react';
import { StyleSheet, View } from 'react-native';

import { useLocalSearchParams } from 'expo-router';

import { useQuery } from '@tanstack/react-query';
import { format } from 'date-fns';

import { CachePolicy } from '@/core/cache';
import { Button } from '@/ui/button';

import { fetchSummary } from '../../data/fetchers';
import { timeOffKeys } from './keys';

import type { TimeOffSummary } from '../../domain/types';
```

- `@/` for anything outside the current feature; relative inside the feature.
