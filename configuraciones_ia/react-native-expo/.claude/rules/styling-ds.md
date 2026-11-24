# Styling & design system — `StyleSheet` + `ui/theme.ts`

## Theme (`src/ui/theme.ts`)

- `Colors`, `Space`, `Radius`, `Font`, `Type`, `Motion`, `textStyle()`.
- Values come from the web design system (shr-fe `design-system/variables.css` +
  `theme-adapter.css`) and the prototype's "modern" layer. **Each value comments the CSS variable
  it comes from**, so a DS change can be followed.
- `Type` tokens are aliases of exact values (pixel fidelity to the prototype), not a scale.
- Light theme only until product confirms dark mode.

## Writing styles

```tsx
import { StyleSheet, View } from 'react-native';

import { Colors, Radius, Space } from '@/ui/theme';

export function TimeOffTile({ children }: TimeOffTileProps) {
  return <View style={styles.tile}>{children}</View>;
}

const styles = StyleSheet.create({
  tile: { backgroundColor: Colors.tile, borderRadius: Radius.md, gap: Space.s2, padding: Space.s4 },
});
```

- `StyleSheet.create` at the bottom of the file; keys sorted.
- No hex colours, no magic numbers for spacing or font sizes outside `theme.ts`
  (`0`, `1` hairlines and `100%` are fine).
- Text: a `Type` token when one names the style, else `textStyle()`.
- No inline `style={{…}}` except truly dynamic values (animated, measured, insets).
- Animations: `useNativeDriver: Motion.nativeDriver`; Reanimated for new gesture-driven UI.

## Kit (`src/ui`)

`Screen`, `KeyboardAwareScreen`, `PageHeader`, `PageTabs`, `PageLoading/PageError`, `CardNote`,
`SectionCard`, `Sheet`, `Dialog`, `Select`, `TextField`, `SearchField`, `DateRangeField`,
`Button`, `IconButton`, `Chip`, `StatusPill`, `Banner`, `Toast`, `Avatar`, `Fab`…

- `src/ui` imports only `src/ui`; words come as props or from `ui/locales`.
- Business components (TimeOffCard, PaystubRow) live in their feature.
- Staffology: copy `src/ui`, swap `theme.ts` values and `logo.tsx`.
- Design conformance: the screenshot harness against the prototype (`tools/preview`), not Storybook.
