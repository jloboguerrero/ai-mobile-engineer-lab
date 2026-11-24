# Server state — TanStack Query v5

Almost everything in this app is server state. If it comes from the API, it lives here.

## Keys — hierarchical factory per feature

```ts
// features/timeoff/queries/keys.ts   (perfectionist sort-objects off here: order = hierarchy)
export const timeoffKeys = {
  all: ['timeoff'] as const,
  employee: (employeeId: string) => [...timeoffKeys.all, employeeId] as const,
  summary: (employeeId: string) => [...timeoffKeys.employee(employeeId), 'summary'] as const,
  history: (employeeId: string, filters: HistoryFilters) =>
    [...timeoffKeys.employee(employeeId), 'history', filters] as const,
};
```

Exported from the feature `index.ts` for cross-feature invalidation.

| Data belongs to… | Key includes |
|---|---|
| Assignment (time off, job, timesheet) | `employeeId` |
| Person (paystubs, tax, documents, signatures, notifications, profile) | `userId` / nothing |
| Manager scope (people, requests, audience) | `scope` (`{ siteId }` or `{ departmentId }`) |

Switching assignment = changing `currentEmployeeId` in the store → keys change → refetch. No
manual invalidation needed.

## `queryOptions` + hook

```ts
// features/timeoff/queries/queries.ts
import { queryOptions, useQuery } from '@tanstack/react-query';

import { useCurrentEmployeeId } from '@/features/session';

import { timeoffApi } from '../di';
import { timeoffKeys } from './keys';

export const summaryQuery = (employeeId: string) =>
  queryOptions({
    queryFn: () => timeoffApi.getSummary(employeeId),
    queryKey: timeoffKeys.summary(employeeId),
    staleTime: 60_000,
  });

export const useTimeOffSummary = () => {
  const employeeId = useCurrentEmployeeId();
  return useQuery(summaryQuery(employeeId));
};
```

- Reuse the same `queryOptions` in hooks, `prefetchQuery`, `ensureQueryData`, `setQueryData`.
- `select` for derived views (filtering, sorting); keep `queryFn` returning the full mapped model.
- Hooks return the query object (or a narrow `{ data, isPending, error, refetch }`); screens
  branch on `isPending` / `error` / `data`.

## Defaults (`src/core/query/queryClient.ts`)

- Queries: `retry: (n, e) => n < 3 && e instanceof ApiError && [502, 503, 504].includes(e.status ?? 0)`.
- Mutations: `retry: false`. **Never retry writes.**
- `focusManager` ↔ `AppState`; `onlineManager` ↔ NetInfo.
- **Never persist the cache to disk** (PII). No `persistQueryClient`.

| Data | staleTime |
|---|---|
| Session bootstrap | `Infinity` |
| Catalogs (paycodes, titles, site names) | 1 h |
| Paystubs, tax, documents | 5 min |
| Time off, requests, notifications | 30–60 s |

## Lists

Normalize pagination in `data/` to `Page<T>` → `useInfiniteQuery` + `FlashList`
(`onEndReached` → `fetchNextPage` guarded by `hasNextPage && !isFetchingNextPage`).
Non-paginated lists: `useQuery` + `select`.

## Mutations

```ts
export const useRequestTimeOff = () => {
  const queryClient = useQueryClient();
  const employeeId = useCurrentEmployeeId();
  return useMutation({
    mutationFn: (values: TimeOffRequest) => timeoffApi.requestTimeOff(employeeId, values),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: timeoffKeys.employee(employeeId) }),
  });
};
```

- Submit disabled with `isPending`. Invalidate by **prefix** in `onSuccess`.
- Optimistic updates only for cheap & reversible things (mark notification read).
- Single-flight for non-idempotent calls that must happen once (`iop-login` by `code`): guard
  with a ref/`mutation.isPending` and `retry: 0`.

## Outside TanStack

Binary downloads (a "download & share" mutation, file deleted on close), pure UI state
(`useState`), and disk persistence (none).

## Anti-patterns

- `useEffect(() => { fetch().then(setData) }, [])` — use `useQuery`.
- `const [items, setItems] = useState(query.data)` — derive or use `select`.
- Putting query data in Zustand.
- String keys built ad hoc in a component (`['timeoff', id]`) — always use the factory.
- `refetchInterval` polling in v1 except the documented notification Plan B (60 s, foreground only).
