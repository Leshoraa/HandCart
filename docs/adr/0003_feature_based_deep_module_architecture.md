# 3. Feature-Based Deep Module Architecture

## Status
Accepted

## Context
Initial scaffolding generated shallow directories (`data/models/`, `presentation/pages/`, `presentation/widgets/`, `constants/`, `utils/`) where each directory contained only a single file. This shallow fragmentation created artificial cognitive boundaries without meaningful encapsulation, violating engineering rules against shallow wrappers, premature abstraction, and dumping grounds.

## Decision
We organize code strictly around cohesive feature boundaries (`catalog`, `cart`) and deep infrastructure (`core/theme`).
- Each feature encapsulates its models, data access/boundaries, state handling, and views within a single folder.
- Sub-components private to a specific view are kept in the same file or package scope with private visibility (`_`).
- Business logic (such as tax calculations, quantity invariants, and search filtering) is strictly decoupled from UI widgets into controllers and repositories.
- Zero dead code: unnecessary abstractions, unused widgets, and single-constant files are eliminated.

## Alternatives
- Clean Architecture Layer-First (`data/`, `domain/`, `presentation/` global layers): Introduces excessive boilerplate and file hopping for small cohesive mobile features.
- Single God File: Puts all models, state, and UI in `main.dart`, which breaks cohesion, testability, and separation of concerns.

## Consequences
- High cohesion: developers can understand and modify a feature by reading a small, localized set of files.
- Small public surface: implementation details remain internal to feature modules.
- Testability: repositories and controllers are easily unit tested in isolation without Flutter widget rendering overhead.
