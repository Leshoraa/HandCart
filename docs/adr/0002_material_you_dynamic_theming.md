# 2. Material You Dynamic Theming Integration

## Status
Accepted

## Context
Modern Android devices running Android 12+ (API 31+) feature the Monet engine, extracting dynamic color palettes based on the user's wallpaper. Using static hardcoded colors prevents the application from blending naturally with the user's system preferences. Furthermore, the application must run gracefully on iOS and older Android systems where system wallpaper palette extraction is unavailable.

## Decision
We integrate the `dynamic_color` plugin (`DynamicColorBuilder`) at the root application level.
- When the host OS provides dynamic light and dark ColorScheme palettes, the application dynamically adopts them.
- When dynamic extraction is unavailable (iOS, desktop, or older Android), the theme gracefully falls back to a deterministic brand seed color (`0xFF006C50`).
- All UI components strictly reference `Theme.of(context).colorScheme` rather than hardcoded color constants.

## Alternatives
- Static brand theme: Simple, but violates native Android Material You platform guidelines.
- Custom wallpaper parser: High maintenance, fragile, and duplicates platform APIs.

## Consequences
- The application automatically adapts to system wallpaper changes on Android 12+.
- Full backward compatibility with iOS and non-Monet devices via deterministic fallback.
- Components maintain WCAG accessible contrast ratios derived by the Material 3 ColorScheme engine.
