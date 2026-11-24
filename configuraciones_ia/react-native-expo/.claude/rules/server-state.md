# Server state — TanStack Query v5

Almost everything in this app is server state. If it comes from the API, it lives here, in
`presentation/queries/`.

## Keys (`keys.ts`)

```ts
export const timeOffKeys = {
  all: ['time-off'] as const,
  summary: (employeeId: string) => [...timeOffKeys.all, 'summary', employeeId] as const,
  histories: (employeeId: string) => [...timeOffKeys.all, 'history', employeeId] as const,
  history: (employeeId: string, year: string) => [...timeOffKeys.histories(employeeId), year] as const,
};
```

- Root `all`, then the **kind before the id**, so a prefix means one kind of read.
- Ordering of this file carries meaning (perfectionist `sort-objects` is off here).

| Data belongs to… | Key includes |
|---|---|
| Assignment (time off, job, timesheet) | `employeeId` |
| Person (paystubs, tax, documents, signatures, notifications, profile) | `userId` |
| Manager team (people, requests) | `scope.key` |

## Queries (`queries.ts`)

```ts
export const timeOffQueries = {
  summary: (employeeId: string) =>
    queryOptions({
      queryFn: ({ signal }) => fetchSummary(employeeId, signal),
      queryKey: timeOffKeys.summary(employeeId),
      ...CachePolicy.standard,
    }),
};

export function useTimeOffSummary(employeeId: string) {
  return useQuery(timeOffQueries.summary(employeeId));
}
```

- Hooks are one-liners (+ `enabled` or a stable `select`). They **take** whose data they read
  (`userId`, `employeeId`); they never ask the session.
- Reuse the same `xxxQueries.x(...)` for `prefetchQuery`, `ensureQueryData`, typed `setQueryData`.
- `select` for derived views; `queryFn` returns the full mapped model.
- `placeholderData: keepPreviousData` when a filter change must keep rows on screen.

## `CachePolicy` (`core/cache.ts`) — spread one, don't write numbers

| Policy | Settings | Used for |
|---|---|---|
| `standard` | stale 30 s | default |
| `perSession` | stale 5 min | assignments, User, tax info, permissions |
| `reference` | never stale | paycodes |
| `live(ms)` | refetch every `ms` while in front | announcements (2 min), unread count (1 min) until push |
| `sensitive` | stale 0, gc 60 s, `meta.sensitive` | Direct Deposit (full numbers) |

A query with its own rule writes its numbers next to the reason.

## Client defaults (`core/query.ts`)

- Queries **and** mutations `retry: false` (the API client already resends GETs).
- `focusManager` ↔ `AppState`: coming back refreshes what is on screen; timers stop in background.
- Query/mutation caches report via `reportError` only: no answer, 5xx, or a non-`ApiError` (bug).
- **Never persist the cache.** A future persister/devtools must drop `meta.sensitive` entries.

## Mutations (`mutations.ts`)

```ts
export function useRequestTimeOff(employeeId: string) {
  return useMutation({
    mutationFn: (request: TimeOffRequest) => sendTimeOffRequest(employeeId, request),
    mutationKey: ['time-off', 'request'],
    onSuccess: () => invalidateTimeOff(employeeId),
  });
}
```

- `mutationKey: [root, verb]`. Never retried.
- Cache work in the write function or the hook's `onSuccess` (runs even after the screen is gone);
  UI reactions in `mutate(vars, { onSuccess, onError })`. A message the person must get even after
  unmount goes in the hook's `onSuccess` too.
- Variables with full bank numbers or a password: `meta: { sensitive: true }` + short `gcTime`.
- Optimistic updates only for cheap & reversible things (mark notification read).
- Single-flight for calls that must happen once (`iop-login` by `code`).

## Cross-feature and screens

- A feature never writes another's keys: export `invalidateXxx()` next to the keys.
- **Screens don't use `useQueryClient`** (lint). Refresh/prefetch through hooks here:
  `useRefreshTimeOff(employeeId)`, `usePullToRefresh(run)`, `useRefreshOnFocus(keys)`.
- On an assignment switch, screens are keyed by `current.id` and start over.

## Anti-patterns

- `useEffect(() => { fetch().then(setData) }, [])` — use `useQuery`.
- `const [items, setItems] = useState(query.data)` — derive or `select`.
- Ad-hoc keys in a component (`['time-off', id]`) — always the factory.
- Numbers for `staleTime` without a reason — spread a `CachePolicy`.
