# ADR 0001: State Management Architecture with InheritedNotifier

## Status
Accepted

## Context
The HandCart application requires reactive cart state management to coordinate cart item counts, badge indicators, bottom bar visibility, and pricing calculations across the catalog (`HomePage`) and checkout screen (`CartPage`). We needed a robust, lightweight state management pattern without adding heavyweight external dependencies for a focused retail assistant app.

## Decision
We adopted Flutter's native `ChangeNotifier` encapsulated within an `InheritedNotifier` (`CartScope`). The root `HandCartApp` instantiates `CartController` and injects it down the widget tree using `CartScope`. Presentation widgets access the controller via `CartScope.of(context)`.

## Alternatives
1. **Riverpod (`flutter_riverpod`)**:
   - Offers compile-time safety and provider caching, but introduces third-party dependency maintenance and boilerplate for a straightforward scope.
2. **Bloc / Cubit (`flutter_bloc`)**:
   - Provides explicit event-state transitions, but introduces significant boilerplate with events, states, and streams that are unnecessary for synchronous local cart mutations.
3. **Vanilla ValueNotifier**:
   - Lightweight, but less cohesive when aggregating multiple interdependent properties (items map, quantity counters, subtotal, tax calculations).

## Consequences
- **Positive**:
  - Zero external state management dependencies.
  - Predictable unidirectional data flow and clean widget lifecycles.
  - Immediate reactivity with O(1) lookups using an internal `Map<String, CartItem>`.
  - Easy unit testing of `CartController` without needing Flutter widget bindings.
- **Negative / Trade-offs**:
  - For very large apps with asynchronous remote state synchronization, migration to a dedicated repository/provider pattern would be needed.
