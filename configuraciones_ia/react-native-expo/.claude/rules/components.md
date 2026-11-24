# Components & screens

## Shape

- Function components, **named exports** (`export function TimeOffCard`). Default export only
  in `app/` route files (Expo Router requires it — done via re-export).
- Props typed with a `type XProps = { … }` (sorted alphabetically, callbacks `on*` last).
  Destructure in the signature.
- One component per file; tiny private sub-components may live in the same file below it.
- No business logic in JSX: compute in the hook or a `domain/` function, render the result.

## Screen pattern

```tsx
export function TimeOffScreen() {
  const { t } = useTranslation('timeoff');
  const summary = useTimeOffSummary();

  if (summary.isPending) return <ScreenSkeleton />;
  if (summary.error) return <ErrorState error={summary.error} onRetry={summary.refetch} />;

  return (
    <Screen title={t('title')}>
      <TimeOffBalances summary={summary.data} />
    </Screen>
  );
}
```

- Screen = data hook(s) + state branches + composition of feature components.
- Every screen handles **pending / error / empty / data**. `ErrorState` maps `ApiError.kind` → copy.
- Pull-to-refresh with `refetch`; never a manual "reload" state.
- Screens never navigate after sign-in/out (guards do it, see `navigation-auth.md`).

## Lists

- `FlashList` for anything that can exceed ~20 rows; `estimatedItemSize` optional in v2 but give
  `keyExtractor`. `renderItem` defined outside JSX or memoized.
- Empty state via `ListEmptyComponent`; pagination via `onEndReached`.

## Images

`expo-image` (`Image` from `expo-image`), never RN `Image`. S3 photo URLs expire in 15 min →
`cachePolicy="memory-disk"` with key independent of the signed query string.

## Accessibility (users: low-end Android, gloves, outdoors)

- Touch targets ≥ 44 pt (`hitSlop` if visually smaller).
- `accessibilityRole`, `accessibilityLabel` on every touchable/icon-only button (base components
  in `src/ui` require them by type).
- Dynamic Type: allow scaling, cap with `maxFontSizeMultiplier` (from tokens).
- High contrast semantic tokens; never color as the only signal.
- Plain words: "your employer", "pay", "hours". Never EOR, batch, bill code, paycode.

## Performance

- Don't create objects/arrays/functions inline in props of memoized children or FlashList items.
- Heavy screens: split into components so re-renders stay local.
- Sheets: `@gorhom/bottom-sheet`; toasts: `sonner-native`; keyboard: `react-native-keyboard-controller`.
