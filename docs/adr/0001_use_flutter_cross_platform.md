# 1. Use Flutter for Android and iOS Cross-Platform Target

## Status
Accepted

## Context
The HandCart application is required to target both Android and iOS platforms from a single codebase while providing native rendering performance, predictable UI fidelity, and rapid iteration capabilities. Maintaining separate native codebases (Kotlin/Compose for Android and Swift/SwiftUI for iOS) would double maintenance effort and create behavioral drift for shopping cart domain logic.

## Decision
We select Flutter as the cross-platform framework. The Dart codebase targets Android and iOS natively with ahead-of-time compilation.

## Alternatives
- Kotlin Multiplatform (KMP) with Compose Multiplatform: Still maturing on iOS, ecosystem smaller for turn-key UI widgets.
- React Native: Relies on JavaScript bridge and platform-specific native views, introducing occasional styling disparities between platforms.
- Native Android (Jetpack Compose) and Native iOS (SwiftUI): Maximum platform fidelity, but requires synchronizing two independent codebases and double engineering overhead.

## Consequences
- Single codebase for business logic, catalog queries, and cart operations.
- Platform channels available for native platform-specific integrations when required.
- Requires Flutter SDK and Dart runtime toolchain on developer machines.
