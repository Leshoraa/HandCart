# ADR 0002: Material 3 Expressive Design and Dynamic Color System

## Status
Accepted

## Context
HandCart targets modern Android and iOS mobile platforms, demanding an expressive Material 3 (Material You) user interface that honors user system personalization (wallpaper accent color extraction on Android 12+) while maintaining crisp contrast, soft elevations, and readable typography.

## Decision
We implemented Material 3 using the `dynamic_color` plugin wrapped in `DynamicColorBuilder`, falling back to an organic deep forest green seed (`#006C50`) when dynamic colors are unavailable. The UI uses borderless surface cards with subtle elevation blur (`alpha: 0.035`, `blurRadius: 10`, `offset: (0, 3)`), squircle action buttons, stadium filter chips, and pill steppers.

## Alternatives
1. **Hardcoded Static Green Palette**:
   - Consistent across all platforms, but ignores Material You user wallpaper accents on Android 12+.
2. **Heavy Outlined Card Borders**:
   - Provides strict visual separation, but feels dated, cluttered in a 2-column grid, and conflicts with modern Material 3 flat expressive elevation styling.

## Consequences
- **Positive**:
  - Automatically personalizes to user device wallpapers on Android 12+.
  - Elegant fallback for iOS and older Android versions.
  - Soft, modern card depth with clean 2-column responsive layout.
- **Negative / Trade-offs**:
  - Requires maintaining coherent contrast ratios across dynamic primaryContainer and surfaceContainer tint variations.
