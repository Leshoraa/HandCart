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
- Asynchronous loading of stores, products, and product quantities.
- CRUD operations coordinated through `StoreRepository` and `ProductRepository`.
- Per-store shopping notes and product quantity updates.
- Dynamic computation of store item count, store total price, and overall planned expense.

The repositories persist data through `AppDatabase` using SQLite (`sqflite`). The
controller updates its in-memory state only after the corresponding repository
operation succeeds. `ShoppingPlannerScope` remains the reactive UI boundary;
SQLite and repositories provide persistence rather than replacing that state
management design.

## Alternatives
1. **Riverpod (`flutter_riverpod`)**:
   - Provides dependency injection, but introduces third-party overhead for a self-contained shopping planner.
2. **Bloc / Cubit (`flutter_bloc`)**:
   - Explicit state transitions, but adds boilerplate for simple synchronous counter increments and note updates.

## Consequences
- **Positive**:
  - No additional state management dependency.
  - Persistent store, product, note, pin, and quantity data through SQLite.
  - Repository-backed operations keep storage concerns out of presentation widgets.
  - Controller behavior can be tested using repository fakes without native database bindings.
  - Controllers are disposed with the application lifecycle.
- **Negative / Trade-offs**:
  - Repository methods are asynchronous, so the UI must handle loading and storage errors.
  - The current automated suite uses in-memory repository fakes for controller and widget tests; SQLite persistence across an Android process restart still requires device-level verification.
