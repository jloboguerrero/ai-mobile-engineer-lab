# Components & screens

## Shape

- Function components, **named exports**. Default export only in route files.
- Props typed with `type XProps = { … }` (alphabetical, `on*` callbacks last). Destructure in
  the signature.
- One component per file; tiny private sub-components may live below it.
- No business logic in JSX: compute in `domain/` or a hook, render the result.
- No `try`, no `useQueryClient` in `.tsx` (lint).

## Screens (`presentation/screens`)

- A screen receives whose data it shows (`userId`, `employeeId`), the viewer's flags and links
  as props from the route. It never asks who is signed in.
- A page is `Screen`, or `KeyboardAwareScreen` when it has fields.
- First read: `PageLoading` / `PageError` (`ui/page-note.tsx`); a card: `CardLoading` / `CardNote`.
  Each card loads and fails on its own (no wholesale Suspense).
- Every screen handles pending / error / empty / data.
- Pull to refresh with `usePullToRefresh(run)`; a tab that must refresh on focus uses
  `useRefreshOnFocus(keys)`.
- A pushed page goes back with `useStackBack(fallback)`; Android back closes what is on top
  (`useAndroidBack`).
- A screen keyed by `current.id` starts over on an assignment switch.

## Lists

- FlatList today (every long list is paged); FlashList when a list becomes unbounded.
- Stable `keyExtractor`; empty state via `ListEmptyComponent`; paging via `onEndReached`.

## Images

`expo-image`, never RN `Image`. S3 photo URLs expire in 15 min and load **without** the
Authorization header; on failure re-read the profile once.

## Sheets, dialogs, toasts

`Sheet` / `Dialog` / `ToastHost` from `src/ui`, opened with `visible`. `<ToastHost onlyNew />` in
the shell: nothing from a previous session is shown.

## Accessibility (WCAG 2.2 AA)

1. Every control has a role and an accessible name, and reports its state.
2. A name says what and whom: "Approve time off for Jordan Lee".
3. Touch targets ≥ 44 pt / 48 dp (`hitSlop`).
4. Text scales; cap `maxFontSizeMultiplier` only on fixed-height chrome.
5. Contrast ≥ 4.5:1 with theme tokens; never colour alone.
6. Sheets/dialogs modal to the screen reader; a surface over the app takes focus.
7. Toasts and status lines are live regions.
8. Animations beyond a fade respect Reduce Motion.
9. Tests find elements by role and name; VoiceOver + TalkBack pass before review.

## Plain words

"your employer", "pay", "hours". Never EOR, batch, bill code, paycode.
