# ADR 0001: Shopping Planner State Management with InheritedNotifier

## Status
Accepted

## Context
The HandCart application pivoted from a generic retail catalog to an interactive Shopping Planner and Expense Tracker. The application organizes shopping by store/market, featuring:
1. Store list selection with aggregate budget tracking.
2. Store-specific product list (vertical 1-column layout) with live quantity steppers `[- 1 +]`.
3. Quick shopping note memos per store.
4. Live total expense calculations calculated across each store's items.

We required a predictable, testable, and reactive state management architecture without introducing heavy third-party framework overhead.

## Decision
We implemented `ShoppingPlannerController` extending Flutter's native `ChangeNotifier`, distributed across the widget hierarchy via `ShoppingPlannerScope` (`InheritedNotifier`).

The controller encapsulates:
- Store collection and active stores.
- Store product catalogs.
- In-memory product quantity mappings.
- Per-store shopping notes and checklist memos.
- Dynamic computation of store item count, store total price, and overall planned expense.

## Alternatives
1. **Riverpod (`flutter_riverpod`)**:
   - Provides dependency injection, but introduces third-party overhead for a self-contained shopping planner.
2. **Bloc / Cubit (`flutter_bloc`)**:
   - Explicit state transitions, but adds boilerplate for simple synchronous counter increments and note updates.

## Consequences
- **Positive**:
  - Zero external state management dependencies.
  - O(1) quantity lookups and clear unidirectional data flow.
  - Decoupled business logic that is thoroughly tested via unit tests without needing widget bindings.
  - Clean lifecycle management: controllers are disposed safely on application termination.
- **Negative / Trade-offs**:
  - When persistent local database storage (e.g. SQLite / Hive) is integrated, the controller will need repository abstractions.
